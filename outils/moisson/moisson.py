"""Moisson des corpus de référence (cahier des charges, § 12.1 et annexe A) : titres d'œuvres et codes Iconclass posés
par des humains, depuis RKDimages (titres EN, codes des documentalistes du RKD) et Wikidata P1257 (libellés EN et FR).

Les données vont hors du dépôt (DOSSIER) ; seul ce script et le manifeste qu'il écrit décrivent la moisson.

Sortie, dans DOSSIER :
  rkd.jsonl, wikidata.jsonl   une œuvre par ligne : {"id", "source", "titres": {"en": …, "fr": …}, "codes": [...],
                              "collection", "rkd"} ; triée par id, codes triés, sans doublon
  corpus.jsonl                les deux, dédoublonnés par œuvre (une œuvre de Wikidata qui porte un identifiant RKDimages
                              présent dans la moisson du RKD est écartée : ses codes viennent souvent du RKD par un robot),
                              avec "partie" : "dev" ou "test"
  manifeste.json              date, requêtes, nombres, empreintes, licences

Séparation développement / test : par collection (Wikidata P195) quand elle est connue, sinon par œuvre ; une
collection entière va d'un seul côté. Le tirage est une empreinte (sha256) du nom de la collection : stable, sans aléa.

Usage : python outils/moisson/moisson.py DOSSIER [--part-test 0.3]
"""
import argparse
import csv
import datetime
import hashlib
import io
import json
import sys
import time
import urllib.parse
import urllib.request
from pathlib import Path

AGENT = "oedipamaas-moisson/0.1 (offline Iconclass evaluation)"
RKD = "https://api.rkd.triply.cc/datasets/rkd/RKD-Knowledge-Graph/services/SPARQL/sparql"
WIKIDATA = "https://query.wikidata.org/sparql"
ICONCLASS = "http://iconclass.org/"

REQUETE_RKD = """PREFIX crm: <http://www.cidoc-crm.org/cidoc-crm/>
SELECT ?obj ?titre ?c WHERE {
  ?obj crm:P65_shows_visual_item ?v . ?v crm:P2_has_type ?c .
  FILTER(STRSTARTS(STR(?c), "http://iconclass.org/"))
  ?obj crm:P1_is_identified_by ?a .
  ?a crm:P72_has_language <http://vocab.getty.edu/aat/300388277> ; crm:P190_has_symbolic_content ?titre .
} LIMIT %d OFFSET %d"""

REQUETE_WIKIDATA = """SELECT ?item ?code ?en ?fr ?coll ?rkd WHERE {
  ?item wdt:P1257 ?code .
  OPTIONAL { ?item rdfs:label ?en FILTER(lang(?en) = "en") }
  OPTIONAL { ?item rdfs:label ?fr FILTER(lang(?fr) = "fr") }
  OPTIONAL { ?item wdt:P195 ?coll }
  OPTIONAL { ?item wdt:P350 ?rkd }
} ORDER BY ?item ?code LIMIT %d OFFSET %d"""


def sparql_csv(point, requete, essais=4):
    url = point + "?" + urllib.parse.urlencode({"query": requete})
    for i in range(essais):
        try:
            req = urllib.request.Request(url, headers={"Accept": "text/csv", "User-Agent": AGENT})
            with urllib.request.urlopen(req, timeout=300) as r:
                return list(csv.DictReader(io.StringIO(r.read().decode("utf-8"))))
        except Exception as e:  # réseau ou serveur : on attend et on réessaie
            if i == essais - 1:
                raise
            print(f"  nouvel essai après {e}", file=sys.stderr)
            time.sleep(10 * 2 ** i)


def pages(point, gabarit, taille):
    offset = 0
    while True:
        lignes = sparql_csv(point, gabarit % (taille, offset))
        if not lignes:
            return
        yield from lignes
        print(f"  {point.split('/')[2]} : {offset + len(lignes)} lignes", file=sys.stderr)
        if len(lignes) < taille:
            return
        offset += taille
        time.sleep(1)


def code_de(uri):
    return urllib.parse.unquote(uri[len(ICONCLASS):]) if uri.startswith(ICONCLASS) else uri


def ecrire_jsonl(chemin, oeuvres):
    with open(chemin, "w", encoding="utf-8") as f:
        for o in sorted(oeuvres, key=lambda o: o["id"]):
            f.write(json.dumps(o, ensure_ascii=False, sort_keys=True) + "\n")
    return hashlib.sha256(Path(chemin).read_bytes()).hexdigest()


def moisson_rkd():
    oeuvres = {}
    for l in pages(RKD, REQUETE_RKD, 10000):
        ident = l["obj"].rsplit("/", 1)[-1]
        o = oeuvres.setdefault(ident, {"id": f"rkd:{ident}", "source": "rkd", "titres": {}, "codes": set(),
                                        "collection": None, "rkd": ident})
        o["titres"].setdefault("en", l["titre"])
        o["codes"].add(code_de(l["c"]))
    return [dict(o, codes=sorted(o["codes"])) for o in oeuvres.values()]


def moisson_wikidata():
    oeuvres = {}
    for l in pages(WIKIDATA, REQUETE_WIKIDATA, 20000):
        q = l["item"].rsplit("/", 1)[-1]
        o = oeuvres.setdefault(q, {"id": f"wd:{q}", "source": "wikidata", "titres": {}, "codes": set(),
                                   "collection": None, "rkd": None})
        for lang in ("en", "fr"):
            if l.get(lang):
                o["titres"].setdefault(lang, l[lang])
        if l.get("coll") and not o["collection"]:
            o["collection"] = l["coll"].rsplit("/", 1)[-1]
        if l.get("rkd") and not o["rkd"]:
            o["rkd"] = l["rkd"]
        o["codes"].add(l["code"])
    return [dict(o, codes=sorted(o["codes"])) for o in oeuvres.values() if o["titres"]]


def partie(o, part_test):
    cle = o["collection"] or o["id"]
    h = int(hashlib.sha256(cle.encode()).hexdigest()[:8], 16) / 0xFFFFFFFF
    return "test" if h < part_test else "dev"


def main(dossier, part_test=0.3):
    d = Path(dossier)
    d.mkdir(parents=True, exist_ok=True)
    debut = datetime.datetime.now(datetime.timezone.utc).isoformat(timespec="seconds")
    rkd = moisson_rkd()
    h_rkd = ecrire_jsonl(d / "rkd.jsonl", rkd)
    wd = moisson_wikidata()
    h_wd = ecrire_jsonl(d / "wikidata.jsonl", wd)
    deja = {o["rkd"] for o in rkd}
    wd_seuls = [o for o in wd if not (o["rkd"] and o["rkd"] in deja)]
    corpus = [dict(o, partie=partie(o, part_test)) for o in rkd + wd_seuls]
    h_c = ecrire_jsonl(d / "corpus.jsonl", corpus)
    compte = lambda os, cle: sum(1 for o in os if cle(o))  # noqa: E731
    manifeste = {
        "date": debut, "agent": AGENT, "part_test": part_test,
        "sources": {
            "rkd": {"point": RKD, "requete": REQUETE_RKD, "licence": "ODC-By 1.0 (RKD, attribution)",
                    "oeuvres": len(rkd), "sha256": h_rkd},
            "wikidata": {"point": WIKIDATA, "requete": REQUETE_WIKIDATA, "licence": "CC0",
                         "oeuvres": len(wd), "ecartees_doublons_rkd": len(wd) - len(wd_seuls), "sha256": h_wd}},
        "corpus": {"oeuvres": len(corpus), "sha256": h_c,
                   "dev": compte(corpus, lambda o: o["partie"] == "dev"),
                   "test": compte(corpus, lambda o: o["partie"] == "test"),
                   "titre_en": compte(corpus, lambda o: "en" in o["titres"]),
                   "titre_fr": compte(corpus, lambda o: "fr" in o["titres"])}}
    (d / "manifeste.json").write_text(json.dumps(manifeste, ensure_ascii=False, indent=1, sort_keys=True) + "\n")
    print(json.dumps(manifeste["corpus"]))
    return manifeste


if __name__ == "__main__":
    a = argparse.ArgumentParser(description=__doc__.split("\n")[0])
    a.add_argument("dossier")
    a.add_argument("--part-test", type=float, default=0.3)
    x = a.parse_args()
    main(x.dossier, x.part_test)
