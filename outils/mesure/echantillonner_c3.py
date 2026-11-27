"""Les échantillons de la contre-expertise de la PR #16 : un tirage au hasard, à graine fixe, parmi les sites de chaque
transformation (outils/mesure/sites_c3.pl), pour un jugement cas par cas.

Usage : python outils/mesure/echantillonner_c3.py SITES.jsonl SORTIE.json [--graine 20261127]

Catégories : le participe lu comme agent (présent) ou comme patient (passé) ; l'énumération d'une scène (partie 1,
type scene : là où #16 en fait une disjonction) et d'un aspect de personne (partie > 1) ; le nom d'action devenu
événement ; le modifieur d'un composé devenu propriété ; le sujet partagé de deux verbes coordonnés ; le complément du
nom relié (français). Un même libellé revient souvent (le gabarit d'un saint, recopié pour chaque saint) : les sites
sont réduits aux libellés distincts (langue, texte du libellé, catégorie) avant le tirage, et les deux comptes sont
donnés. Les sites sont triés avant le tirage : le tirage ne dépend que de la graine."""
import argparse
import collections
import json
import random

TAILLES = {"participe_agent": 30, "participe_patient": 30, "enumeration_scene": 30, "enumeration_aspect": 15,
           "actions": 30, "composes_syntaxiques": 30, "sujets_partages": 15, "complements_non_lus": 15}


def categorie(x):
    if x["op"] == "participes":
        return "participe_agent" if ",agent," in x["apres"] else "participe_patient"
    if x["op"] == "enumeration":
        if x["type"] == "scene" and x["r"] == 1:
            return "enumeration_scene"
        if x["r"] > 1 and x["type"] in ("individu", "recit"):
            return "enumeration_aspect"
        return "enumeration_autre"
    return x["op"]


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("sites")
    ap.add_argument("sortie")
    ap.add_argument("--graine", type=int, default=20261127)
    a = ap.parse_args()
    X = [json.loads(l) for l in open(a.sites, encoding="utf-8")]
    G = collections.defaultdict(list)
    for x in X:
        G[categorie(x)].append(x)
    alea = random.Random(a.graine)
    D = {}
    for k, xs in G.items():
        vus = {}
        for x in sorted(xs, key=lambda x: (x["n"], x["l"], x["r"], x["apres"])):
            vus.setdefault((x["l"], x["libelle"]), x)
        D[k] = list(vus.values())
    E = {"graine": a.graine, "sites": {k: len(v) for k, v in sorted(G.items())},
         "libelles_distincts": {k: len(v) for k, v in sorted(D.items())}, "echantillons": {}}
    for k, n in TAILLES.items():
        xs = D[k]
        E["echantillons"][k] = alea.sample(xs, min(n, len(xs)))
    with open(a.sortie, "w", encoding="utf-8") as f:
        json.dump(E, f, ensure_ascii=False, indent=1)
    print(json.dumps({"sites": E["sites"], "libelles_distincts": E["libelles_distincts"]}, ensure_ascii=False))


if __name__ == "__main__":
    main()
