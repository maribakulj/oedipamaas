"""Les échecs de l'expérience croisée, et des indices de leur cause (27/11).

Usage : python outils/croise/diagnostiquer.py CROISE.json REFERENCES.json REQUETES_REF.json [--condition C] [--json SORTIE]

Un échec de la condition C (reference_reference par défaut : graphe de référence, requête de référence) :
  - texte positif : la condition suffisante de la notation visée n'est pas établie (ni sous hypothèses) ;
  - texte négatif : elle est établie (un faux positif).
Pour chaque échec, chaque atome manquant de la requête (partiel/2 du noyau) est rapproché de ce que le graphe de
référence dit : le mot demandé est-il une tête d'entité, un prédicat d'événement, une propriété, une relation, un nom
du graphe ? un composé (un espace) ? un mot que le graphe dit autrement (un prédicat pour un type, une propriété pour
une relation…) ? Ce sont des indices : la cause de chaque échec est ensuite décidée cas par cas (incompatibilité de
représentation, connaissances lexicales manquantes, désambiguïsation, limite du noyau, inférence contextuelle
manquante, erreur de référence), et notée avec sa raison."""
import argparse
import collections
import json
import re
from pathlib import Path


def norm(x):
    return " ".join(str(x).lower().replace("_", " ").replace("'", " ").split())


def mots_du_graphe(g):
    t = {norm(e["tete"]) for e in g.get("entites", [])}
    noms = {norm(n if isinstance(n, str) else n["nom"]) for e in g.get("entites", []) for n in e.get("noms", [])}
    props = {norm(p if isinstance(p, str) else p["propriete"]) for e in g.get("entites", []) for p in e.get("proprietes", [])}
    preds = {norm(v["predicat"]) for v in g.get("evenements", [])} | {norm(v["nom_d_action"]) for v in g.get("evenements", []) if v.get("nom_d_action")}
    rels = {norm(r["relation"]) for r in g.get("relations", [])}
    return {"tete": t, "nom": noms, "propriete": props, "predicat": preds, "relation": rels}


ATOME = re.compile(r"^(\w+)\((.*)\)$")


def indice(atome, M):
    m = ATOME.match(atome.replace(" ", ""))
    if not m:
        return "illisible"
    f, args = m.group(1), m.group(2)
    mot = None
    q = re.findall(r"'([^']*)'|,([a-zà-ÿ_A-Z0-9]+)\)?$", atome)
    parties = [a.strip() for a in re.split(r",(?![^\[]*\])", atome[atome.index("(") + 1:-1])]
    if f in ("type", "propriete", "evenement", "genre"):
        mot = parties[-1]
    elif f == "relation":
        mot = parties[1]
    elif f == "nom":
        mot = parties[-1]
    elif f == "role":
        return f"rôle {parties[1]}"
    mot = norm(mot.strip("'[]")) if mot else ""
    ou = [k for k, s in M.items() if mot in s]
    attendu = {"type": "tete", "genre": "tete", "propriete": "propriete", "evenement": "predicat",
               "relation": "relation", "nom": "nom"}.get(f)
    if attendu in ou:
        return f"« {mot} » est bien un(e) {attendu} du graphe : la contrainte jointe échoue (variables, rôles, autres atomes)"
    if ou:
        return f"« {mot} » est dans le graphe comme {', '.join(ou)}, non comme {attendu} : représentation"
    proches = [(k, w) for k, s in M.items() for w in s if mot and (mot in w or w in mot) and len(w) > 2]
    if proches:
        return f"« {mot} » absent ; proche : {', '.join(f'{w} ({k})' for k, w in proches[:4])}"
    return f"« {mot} » absent du graphe{' (composé)' if ' ' in mot else ''} : lexique (hyperonymie, synonymie) ou inférence"


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("croise")
    ap.add_argument("references")
    ap.add_argument("requetes")
    ap.add_argument("--condition", default="reference_reference")
    ap.add_argument("--json")
    a = ap.parse_args()
    X = json.loads(Path(a.croise).read_text(encoding="utf-8"))
    R = {(g["k"], g["genre"]): g for g in json.loads(Path(a.references).read_text(encoding="utf-8"))}
    Q = {q["k"]: q for q in json.loads(Path(a.requetes).read_text(encoding="utf-8"))}
    ETABLI = ("etablie", "etablie_sous_hypotheses")
    echecs = []
    for x in X:
        c = x["conditions"][a.condition]
        s = c["satisfaction"]
        positif = x["genre"] == "positif"
        negatif = x["genre"] == "negatif"
        if s == "sans_requete" or not (positif or negatif):
            continue
        if (positif and s not in ETABLI) or (negatif and s in ETABLI):
            g = R[(x["k"], x["genre"])]
            M = mots_du_graphe(g)
            man = (c.get("partiel") or {}).get("manquants", [])
            echecs.append({"k": x["k"], "genre": x["genre"], "notation": x["notation"], "compilation": x["compilation"],
                           "satisfaction": s, "requete": Q[x["k"]]["suffisante"], "nature_ref": Q[x["k"]].get("nature"),
                           "texte": g["texte"], "manquants": man,
                           "satisfaits": (c.get("partiel") or {}).get("satisfaits", []),
                           "indices": [indice(m, M) for m in man], "hypotheses": c.get("hypotheses", [])})
    for e in echecs:
        print(f"\n## k {e['k']} {e['genre']} {e['notation']} ({e['compilation']}) : {e['satisfaction']}")
        print(f"   requête : {e['requete']}")
        print(f"   texte   : {e['texte'][:300]}")
        for m, i in zip(e["manquants"], e["indices"]):
            print(f"   - manque {m} : {i}")
    print(f"\n{len(echecs)} échecs ({collections.Counter(e['genre'] for e in echecs)})")
    if a.json:
        Path(a.json).write_text(json.dumps(echecs, ensure_ascii=False, indent=1), encoding="utf-8")


if __name__ == "__main__":
    main()
