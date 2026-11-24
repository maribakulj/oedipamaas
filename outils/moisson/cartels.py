"""Cartels et descriptions d'œuvres en prose, librement réutilisables, pour mesurer le moteur sur ce qu'il doit lire
(cahier des charges, D15 : les descriptions, jamais le titre seul).

  cleveland DOSSIER   Cleveland Museum of Art, API d'accès ouvert (données CC0) : champs description et
                      wall_description (texte du cartel), en anglais
  chicago DOSSIER     Art Institute of Chicago, API (description sous CC BY 4.0, le reste CC0), en anglais
  wikipedia DOSSIER   Wikipédia FR et EN (CC BY-SA 4.0) : articles d'œuvres qui portent des codes Iconclass dans
                      Wikidata (P1257) ; on garde les sections de description (« Description », « Composition »…)

Chaque source écrit DOSSIER/<source>.jsonl (un document par ligne : id, langue, titre, description, codes s'il y en a,
licence, url) et DOSSIER/<source>.manifeste.json. Requêtes lentes et répétées sur erreur (429 : on attend). Les textes
restent hors du dépôt.

Usage : python outils/moisson/cartels.py cleveland|chicago|wikipedia DOSSIER
"""
import datetime
import hashlib
import html
import json
import re
import sys
import time
import urllib.parse
import urllib.request
from pathlib import Path

AGENT = "oedipamaas-moisson/0.1 (offline Iconclass evaluation)"


def obtenir(url, essais=6, pause=1.0):
    for i in range(essais):
        try:
            req = urllib.request.Request(url, headers={"User-Agent": AGENT, "Accept": "application/json"})
            with urllib.request.urlopen(req, timeout=120) as r:
                time.sleep(pause)
                return json.loads(r.read().decode("utf-8"))
        except urllib.error.HTTPError as e:
            attente = 30 * (i + 1) if e.code == 429 else 5 * (i + 1)
            print(f"  {e.code} ; nouvel essai dans {attente} s", file=sys.stderr)
            time.sleep(attente)
        except Exception as e:  # réseau
            print(f"  {e} ; nouvel essai", file=sys.stderr)
            time.sleep(5 * (i + 1))
    return None


def sans_balises(t):
    t = re.sub(r"<[^>]+>", " ", t or "")
    return re.sub(r"\s+", " ", html.unescape(t)).strip()


def ecrire(dossier, source, docs, extra):
    d = Path(dossier)
    d.mkdir(parents=True, exist_ok=True)
    p = d / f"{source}.jsonl"
    with open(p, "w", encoding="utf-8") as f:
        for o in sorted(docs, key=lambda o: o["id"]):
            f.write(json.dumps(o, ensure_ascii=False, sort_keys=True) + "\n")
    m = dict(extra, date=datetime.datetime.now(datetime.timezone.utc).isoformat(timespec="seconds"), documents=len(docs),
             sha256=hashlib.sha256(p.read_bytes()).hexdigest())
    (d / f"{source}.manifeste.json").write_text(json.dumps(m, ensure_ascii=False, indent=1) + "\n")
    print(json.dumps(m, ensure_ascii=False))


def cleveland(dossier):
    base = "https://openaccess-api.clevelandart.org/api/artworks/"
    docs, skip = [], 0
    champs = "id,title,description,wall_description,type,url,share_license_status"
    while True:
        d = obtenir(f"{base}?has_image=1&limit=1000&skip={skip}&fields={champs}", pause=0.5)
        if not d or not d.get("data"):
            break
        for x in d["data"]:
            texte = " ".join(t for t in (sans_balises(x.get("wall_description")), sans_balises(x.get("description"))) if t)
            if len(texte) >= 120 and x.get("share_license_status") == "CC0":
                docs.append({"id": f"cma:{x['id']}", "langue": "en", "titre": x.get("title") or "", "description": texte,
                             "type": x.get("type"), "licence": "CC0", "url": x.get("url"), "codes": []})
        skip += 1000
        print(f"  cleveland : {skip} lues, {len(docs)} gardées", file=sys.stderr)
    ecrire(dossier, "cleveland", docs, {"source": base, "licence": "CC0"})


def chicago(dossier):
    base = "https://api.artic.edu/api/v1/artworks/search"
    docs, page = [], 1
    q = json.dumps({"query": {"exists": {"field": "description"}}})
    while True:
        url = f"{base}?params={urllib.parse.quote(q)}&fields=id,title,description,artwork_type_title&limit=100&page={page}"
        d = obtenir(url, pause=1.1)
        if not d or not d.get("data"):
            break
        for x in d["data"]:
            texte = sans_balises(x.get("description"))
            if len(texte) >= 120:
                docs.append({"id": f"aic:{x['id']}", "langue": "en", "titre": x.get("title") or "", "description": texte,
                             "type": x.get("artwork_type_title"), "licence": "CC BY 4.0 (description)",
                             "url": f"https://www.artic.edu/artworks/{x['id']}", "codes": []})
        tot = d.get("pagination", {}).get("total_pages", page)
        print(f"  chicago : page {page}/{tot}, {len(docs)} gardées", file=sys.stderr)
        if page >= tot or page >= 100:          # l'API plafonne la pagination de recherche
            break
        page += 1
    ecrire(dossier, "chicago", docs, {"source": base, "licence": "description CC BY 4.0, reste CC0"})


SECTIONS = {"fr": re.compile(r"^(description|composition|sujet|analyse|iconographie|l'œuvre|l'oeuvre|le tableau)", re.I),
            "en": re.compile(r"^(description|composition|subject|iconography|the painting|analysis|content)", re.I)}


def sections_de_description(texte, langue):
    """Les sections dont le titre annonce une description, dans l'extrait en texte brut (titres « == … == »)."""
    morceaux = re.split(r"\n(=+)\s*(.+?)\s*=+\n", "\n" + texte)
    gardes = []
    for i in range(1, len(morceaux) - 2, 3):
        titre, corps = morceaux[i + 1], morceaux[i + 2]
        if SECTIONS[langue].match(titre.strip()) and len(corps.strip()) >= 80:
            gardes.append(corps.strip())
    return "\n".join(gardes)


def wikipedia(dossier):
    sparql = """SELECT ?item ?code ?article WHERE {
  ?item wdt:P1257 ?code . ?article schema:about ?item ; schema:isPartOf <https://%s.wikipedia.org/> .
}"""
    docs = []
    for langue in ("fr", "en"):
        r = obtenir("https://query.wikidata.org/sparql?" + urllib.parse.urlencode(
            {"query": sparql % langue, "format": "json"}), pause=1.0)
        par = {}
        for b in (r or {}).get("results", {}).get("bindings", []):
            o = par.setdefault(b["article"]["value"], {"item": b["item"]["value"].rsplit("/", 1)[-1], "codes": set()})
            o["codes"].add(b["code"]["value"])
        print(f"  wikipedia {langue} : {len(par)} articles", file=sys.stderr)
        for k, (url, o) in enumerate(sorted(par.items())):
            titre = urllib.parse.unquote(url.rsplit("/", 1)[-1]).replace("_", " ")
            d = obtenir(f"https://{langue}.wikipedia.org/w/api.php?" + urllib.parse.urlencode(
                {"action": "query", "prop": "extracts", "explaintext": 1, "titles": titre, "format": "json",
                 "formatversion": 2}), pause=1.5)
            pages = (d or {}).get("query", {}).get("pages", [])
            texte = pages[0].get("extract", "") if pages else ""
            desc = sections_de_description(texte, langue)
            if len(desc) >= 120:
                docs.append({"id": f"wp{langue}:{o['item']}", "langue": langue, "titre": titre, "description": desc[:4000],
                             "codes": sorted(o["codes"]), "licence": "CC BY-SA 4.0", "url": url})
            if k % 50 == 0:
                print(f"  wikipedia {langue} : {k}/{len(par)}, {len(docs)} gardés", file=sys.stderr)
    ecrire(dossier, "wikipedia", docs, {"source": "Wikidata P1257 + Wikipédia FR/EN", "licence": "CC BY-SA 4.0"})


if __name__ == "__main__":
    if len(sys.argv) != 3 or sys.argv[1] not in ("cleveland", "chicago", "wikipedia"):
        raise SystemExit(__doc__)
    {"cleveland": cleveland, "chicago": chicago, "wikipedia": wikipedia}[sys.argv[1]](sys.argv[2])
