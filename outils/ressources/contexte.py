"""Couverture des sens utiles : 30 occurrences en contexte (corpus Joconde).

Usage :
  python3 -I outils/ressources/contexte.py tirer      -> fiche à juger
  python3 -I outils/ressources/contexte.py depouiller -> couverture des sens utiles

Tirage (graine 20261128) de 30 occurrences de mots pleins, un lemme au plus
une fois, stratifié par catégorie : NOUN 14, VERB 7, ADJ 5, ADV 2, PROPN 2.
Pour chaque occurrence, l'agent note le sens que demande le contexte :
  - le synset WordNet 3.0 adéquat (cherché dans WordNet même si aucune
    ressource ne le propose), ou « - » s'il n'en existe pas ;
  - les ressources patrimoniales dont un concept correspond à ce sens.
Jugements : outils/ressources/jugements/contexte.tsv
(colonnes : n, lemme, synset_utile, patrimoniaux_corrects, commentaire).
Un sens est « utile » s'il est celui que le contexte demande. Jugement d'agent.
"""
import json
import os
import random
import re
import sys
import zipfile
from collections import defaultdict

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from commun import SORTIE, RESSOURCES, Index, WordNet, RES_WN, RES_PAT  # noqa: E402
from mesurer import garder, lire_corpus  # noqa: E402

GRAINE = 20261128
ICI = os.path.dirname(os.path.abspath(__file__))
JUG = os.path.join(ICI, "jugements", "contexte.tsv")
FICHE = os.path.join(SORTIE, "fiche_contexte.txt")
QUOTAS = {"NOUN": 14, "VERB": 7, "ADJ": 5, "ADV": 2, "PROPN": 2}


def etiquettes_concepts():
    """URI de concept -> description courte (liste, libellé, parent)."""
    lab, parent, sch = {}, {}, {}
    d = os.path.join(RESSOURCES, "joconde_vocabulaires")
    for f in os.listdir(d):
        if not f.endswith(".ttl"):
            continue
        t = open(os.path.join(d, f), encoding="utf-8", errors="replace").read()
        for b in t.split("\n\n"):
            m = re.match(r"<([^>]+)> a skos:Concept", b)
            if not m:
                continue
            ml = re.search(r'skos:prefLabel "([^"]*)"@fr', b)
            mb = re.search(r"skos:broader <([^>]+)>", b)
            lab[m.group(1)] = ml.group(1) if ml else "?"
            sch[m.group(1)] = f[:-4]
            if mb:
                parent[m.group(1)] = mb.group(1)
    out = {}
    for u in lab:
        out[u] = "%s:%s < %s" % (sch[u], lab[u], lab.get(parent.get(u, ""), "-"))
    z = zipfile.ZipFile(os.path.join(RESSOURCES, "aat", "explicit.zip"))
    for l in z.open("AATOut_1Subjects.nt"):
        l = l.decode("utf-8", "replace")
        if "#parentStringAbbrev>" in l:
            m = re.match(r'<http://vocab.getty.edu/aat/(\d+)> \S+ "(.*)" \.', l)
            if m:
                out["aat:" + m.group(1)] = "aat < " + m.group(2)[:120]
    ic = {}
    dd = os.path.join(RESSOURCES, "iconclass", "txt", "en")
    for f in os.listdir(dd):
        for l in open(os.path.join(dd, f), encoding="utf-8"):
            if "|" in l:
                n, tx = l.rstrip("\n").split("|", 1)
                ic[n] = "iconclass " + n + " : " + tx[:100]
    return out, ic


def tirer():
    wn = WordNet()
    idx = {r: Index(r) for r in RES_WN + RES_PAT}
    docs = lire_corpus("joconde")
    occs = []
    for d in docs:
        for ip, ph in enumerate(d["phrases"]):
            for iw, (t, lem, up) in enumerate(ph["mots"]):
                if up in QUOTAS and garder(lem, up):
                    occs.append((d["id"], ip, iw, t, lem, up, ph["texte"]))
    rnd = random.Random(GRAINE)
    rnd.shuffle(occs)
    pris, vus = [], set()
    for o in occs:
        k = (o[4].lower(), o[5])
        if k in vus or sum(1 for p in pris if p[5] == o[5]) >= QUOTAS[o[5]]:
            continue
        vus.add(k)
        pris.append(o)
        if len(pris) == sum(QUOTAS.values()):
            break
    etiq, ic = etiquettes_concepts()
    rows = []
    with open(FICHE, "w", encoding="utf-8") as f:
        for n, (doc, ip, iw, t, lem, up, ph) in enumerate(pris, 1):
            prop = {r: idx[r].chercher(lem, up) for r in RES_WN}
            union = sorted(set().union(*prop.values()))
            f.write("\n### %d. %s (%s) « %s » — %s\n%s\n" % (n, lem, up, t, doc, ph[:600]))
            for s in union:
                lex, mots, gl = wn.info(s) or ("?", [], "")
                fl = ",".join(r for r in RES_WN if s in prop[r])
                f.write("   %s %-16s %-30s %s  [%s]\n" % (s, lex, " ".join(mots[:4])[:30], gl[:110], fl))
            for r in RES_PAT:
                cs = idx[r].chercher(lem, up)
                for c in sorted(cs)[:8]:
                    desc = etiq.get(c) or ic.get(c) or c
                    f.write("   PAT %-14s %s\n" % (r, desc[:150]))
            rows.append({"n": n, "doc": doc, "lemme": lem, "upos": up, "forme": t,
                         "propositions": {r: sorted(prop[r]) for r in RES_WN},
                         "patrimoniaux": {r: sorted(idx[r].chercher(lem, up)) for r in RES_PAT}})
    json.dump(rows, open(os.path.join(SORTIE, "plan_contexte.json"), "w"), indent=1, ensure_ascii=False)
    print(len(pris), "occurrences ->", FICHE, file=sys.stderr)


def depouiller():
    wn = WordNet()
    rows = json.load(open(os.path.join(SORTIE, "plan_contexte.json"), encoding="utf-8"))
    jug = {}
    for l in open(JUG, encoding="utf-8"):
        if l.startswith("#") or not l.strip():
            continue
        c = l.rstrip("\n").split("\t")
        jug[int(c[0])] = c
    res = {"occurrences": len(rows), "sens_utile_absent_de_wordnet": 0, "par_ressource": {}, "detail": []}
    cpt = defaultdict(int)
    lexn = defaultdict(lambda: defaultdict(int))
    for r in rows:
        j = jug[r["n"]]
        utile = j[2]
        pats = set(x for x in j[3].split(",") if x and x != "-")
        if utile == "-":
            res["sens_utile_absent_de_wordnet"] += 1
        utiles = set(utile.split("|")) if utile != "-" else set()
        couverts = [k for k, v in r["propositions"].items() if utiles & set(v)]
        couverts += [p for p in pats]
        for k in couverts:
            cpt[k] += 1
        fam = wn.lexname(sorted(utiles)[0]) if utiles else "hors_WordNet"
        lexn[fam]["n"] += 1
        for k in couverts:
            lexn[fam][k] += 1
        union_wn = any(utiles & set(v) for v in r["propositions"].values())
        union_tout = union_wn or bool(pats)
        cpt["UNION_WN"] += union_wn
        cpt["UNION_TOUT"] += union_tout
        cpt["WOLF+WoNeF_F+DBnary_filtre"] += any(utiles & set(r["propositions"][k]) for k in ("wolf", "wonef_f", "dbnary_filtre"))
        cpt["WOLF+patrimoniaux"] += bool(utiles & set(r["propositions"]["wolf"])) or bool(pats)
        cpt["WOLF+WoNeF_F+DBnary_filtre+patrimoniaux"] += any(utiles & set(r["propositions"][k]) for k in ("wolf", "wonef_f", "dbnary_filtre")) or bool(pats)
        cpt["sens_utile_dans_WordNet"] += bool(utiles)
        # le lemme est présent dans WOLF mais sans le sens utile : silence masqué par du bruit
        cpt["wolf_lemme_present_sens_utile_absent"] += bool(r["propositions"]["wolf"]) and not (utiles & set(r["propositions"]["wolf"]))
        cpt["lemme_dans_wolf"] += bool(r["propositions"]["wolf"])
        res["detail"].append({"n": r["n"], "lemme": r["lemme"], "upos": r["upos"], "utile": utile, "famille": fam,
                              "couvert_par": couverts, "wolf_nb_sens": len(r["propositions"]["wolf"]), "commentaire": j[4] if len(j) > 4 else ""})
    res["par_ressource"] = dict(cpt)
    res["par_famille"] = {k: dict(v) for k, v in lexn.items()}
    json.dump(res, open(os.path.join(SORTIE, "contexte_resultats.json"), "w"), indent=1, ensure_ascii=False)
    print(json.dumps(res, indent=1, ensure_ascii=False))


if __name__ == "__main__":
    {"tirer": tirer, "depouiller": depouiller}[sys.argv[1]]()
