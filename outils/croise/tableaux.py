"""Les tableaux de l'expérience croisée (27/11) : satisfaction, qualification, attribution, causes.

Usage : python outils/croise/tableaux.py CAUSES.json JEU=CROISE.json [JEU=CROISE.json …] [--json SORTIE]

CROISE.json : la sortie de outils/croise/croiser.pl pour un jeu ; CAUSES.json : les causes décidées cas par cas pour
chaque échec de la condition (graphe de référence, requête de référence), une entrée par échec :
  {"jeu", "k", "genre", "notation", "causes": [...], "principale", "raison", "statut"}
avec causes parmi representation, lexique, desambiguisation, noyau, inference, erreur_reference.

Contrôle de complétude (un seul défaut, et rien n'est écrit) : chaque échec de reference_reference a exactement une
entrée de causes, et chaque entrée correspond à un échec.

Tableaux, par jeu :
  1. la satisfaction de la condition suffisante de la notation visée, par condition et par genre de texte ;
  2. la qualification de la notation (codage.pl, statut/9), par condition et par genre ;
  3. l'attribution, sur les textes positifs : ce que change le lecteur (lecteur_reference contre reference_reference)
     et le compilateur (reference_compilee contre reference_reference), dans les deux sens ;
  4. les causes des échecs de reference_reference : la principale, et toutes (un échec peut en avoir plusieurs).
Les décisions de causes sont celles d'un agent : provisoires tant qu'une personne ne les a pas validées."""
import argparse
import collections
import json
from pathlib import Path

CONDITIONS = ("lecteur_compilee", "lecteur_reference", "reference_compilee", "reference_reference")
ETABLI = ("etablie", "etablie_sous_hypotheses")
CAUSES = ("representation", "lexique", "desambiguisation", "noyau", "inference", "erreur_reference")


def genre_court(g):
    return "variante" if g.startswith("variante_") else g


def echec(x, c="reference_reference"):
    s = x["conditions"][c]["satisfaction"]
    if s == "sans_requete":
        return False
    return (x["genre"] == "positif" and s not in ETABLI) or (x["genre"] == "negatif" and s in ETABLI)


def compte(X, cle):
    t = {}
    for c in CONDITIONS:
        t[c] = {}
        for x in X:
            g = genre_court(x["genre"])
            v = str(x["conditions"][c][cle])
            t[c].setdefault(g, collections.Counter())[v] += 1
    return t


def attribution(X):
    P = [x for x in X if x["genre"] == "positif"]
    ok = lambda x, c: x["conditions"][c]["satisfaction"] in ETABLI
    sans = lambda x, c: x["conditions"][c]["satisfaction"] == "sans_requete"
    return {
        "positifs": len(P),
        "reference_reference_etablie": sum(ok(x, "reference_reference") for x in P),
        "lecteur_perd": sorted(x["notation"] for x in P if ok(x, "reference_reference") and not ok(x, "lecteur_reference")),
        "lecteur_gagne": sorted(x["notation"] for x in P if ok(x, "lecteur_reference") and not ok(x, "reference_reference")),
        "compilateur_sans_requete": sum(sans(x, "reference_compilee") for x in P),
        "compilateur_perd": sorted(x["notation"] for x in P if ok(x, "reference_reference") and not ok(x, "reference_compilee")),
        "compilateur_gagne": sorted(x["notation"] for x in P if ok(x, "reference_compilee") and not ok(x, "reference_reference")),
        "echecs_reference_reference": sum(echec(x) for x in P),
    }


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("causes")
    ap.add_argument("jeux", nargs="+")
    ap.add_argument("--json")
    a = ap.parse_args()
    causes = json.loads(Path(a.causes).read_text(encoding="utf-8"))
    defauts, sortie = [], {}
    vues = collections.Counter((c["jeu"], c["k"], c["genre"]) for c in causes)
    defauts += [f"causes en double : {k}" for k, n in vues.items() if n > 1]
    for c in causes:
        if c["principale"] not in CAUSES or any(x not in CAUSES for x in c["causes"]) or c["causes"][0] != c["principale"]:
            defauts.append(f"causes mal formées : {c['jeu']} {c['k']} {c['genre']}")
    jeux = {}
    for j in a.jeux:
        nom, f = j.split("=", 1)
        jeux[nom] = json.loads(Path(f).read_text(encoding="utf-8"))
    for nom, X in jeux.items():
        E = {(x["k"], x["genre"]) for x in X if echec(x)}
        C = {(c["k"], c["genre"]) for c in causes if c["jeu"] == nom}
        defauts += [f"{nom} : échec sans cause {k}" for k in sorted(E - C)]
        defauts += [f"{nom} : cause sans échec {k}" for k in sorted(C - E)]
    defauts += [f"jeu inconnu : {j}" for j in sorted({c["jeu"] for c in causes} - set(jeux))]
    if defauts:
        print("\n".join(defauts))
        raise SystemExit(1)
    for nom, X in jeux.items():
        cs = [c for c in causes if c["jeu"] == nom]
        sortie[nom] = {
            "satisfaction": compte(X, "satisfaction"),
            "qualification": compte(X, "qualification"),
            "attribution": attribution(X),
            "causes": {"echecs": len(cs),
                       "principale": dict(collections.Counter(c["principale"] for c in cs).most_common()),
                       "toutes": dict(collections.Counter(x for c in cs for x in c["causes"]).most_common()),
                       "seule": dict(collections.Counter(c["principale"] for c in cs if len(c["causes"]) == 1).most_common())},
        }
    for nom, s in sortie.items():
        print(f"\n# {nom}")
        for cle in ("satisfaction", "qualification"):
            print(f"\n## {cle}")
            for c in CONDITIONS:
                print(f"  {c}")
                for g, n in s[cle][c].items():
                    print(f"    {g:12} " + ", ".join(f"{v} {m}" for v, m in sorted(n.items(), key=lambda t: -t[1])))
        print("\n## attribution (positifs)")
        for k, v in s["attribution"].items():
            print(f"  {k}: {v}")
        print("\n## causes des échecs de reference_reference")
        for k, v in s["causes"].items():
            print(f"  {k}: {v}")
    if a.json:
        Path(a.json).write_text(json.dumps(sortie, ensure_ascii=False, indent=1, default=dict), encoding="utf-8")


if __name__ == "__main__":
    main()
