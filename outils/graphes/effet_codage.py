"""L'effet de la lecture sur le codage Iconclass (lot 5) : le codage des graphes de référence contre celui des graphes
du lecteur (outils/graphes/coder_graphes.pl), mêmes requêtes, même noyau, même budget.

Usage : python outils/graphes/effet_codage.py CODAGE_REFERENCE.json CODAGE_LECTEUR.json [--json SORTIE.json]

Pour chaque genre de texte : le statut de la notation visée (positif : elle devrait être établie ; négatif : elle ne
devrait pas l'être ; indéterminé : rien n'est attendu) dans les deux codages ; puis, par texte, les codes positifs
(établissables, candidats, conditionnels) des deux codages : communs, propres à la référence (ce que la lecture
fait perdre), propres au lecteur (ce qu'elle fait gagner, à tort ou à raison : rien ne dit ici lequel). La référence
n'est pas un codage juste : c'est le codage d'un graphe juste ; la différence ne mesure que la lecture."""
import argparse
import collections
import json
from pathlib import Path

POSITIFS = ("etabli", "etablissable", "candidat")


def charger(p):
    return {(r["k"], r["genre"]): r for r in json.loads(Path(p).read_text(encoding="utf-8"))}


def codes(r, quoi):
    return set(r.get(quoi) or [])


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("reference")
    ap.add_argument("lecteur")
    ap.add_argument("--json")
    a = ap.parse_args()
    R, L = charger(a.reference), charger(a.lecteur)
    communs = sorted(set(R) & set(L))
    vise = collections.defaultdict(collections.Counter)
    for k in communs:
        g = k[1] if k[1] in ("positif", "negatif", "indetermine") else "variante"
        vise[g][(R[k]["statut"], L[k]["statut"])] += 1
    print(f"{len(communs)} textes\n")
    print("Notation visée, statut (graphe de référence → graphe du lecteur) :\n")
    for g, c in vise.items():
        print(f"- {g} : " + ", ".join(f"{a} → {b} : {n}" for (a, b), n in sorted(c.items(), key=lambda x: -x[1])))
    print("\nCodes par texte (moyennes) :\n")
    print("| codes | référence | lecteur | communs | perdus par la lecture | ajoutés par la lecture | Jaccard moyen |")
    print("|---|---|---|---|---|---|---|")
    out = {"vise": {g: {f"{a}>{b}": n for (a, b), n in c.items()} for g, c in vise.items()}}
    for quoi in ("etablissables", "candidats", "conditionnels"):
        nr = nl = nc = 0
        jac = []
        for k in communs:
            a_, b_ = codes(R[k], quoi), codes(L[k], quoi)
            nr += len(a_)
            nl += len(b_)
            nc += len(a_ & b_)
            if a_ | b_:
                jac.append(len(a_ & b_) / len(a_ | b_))
        n = max(len(communs), 1)
        print(f"| {quoi} | {nr / n:.1f} | {nl / n:.1f} | {nc / n:.1f} | {(nr - nc) / n:.1f} | {(nl - nc) / n:.1f} |"
              f" {sum(jac) / max(len(jac), 1):.2f} |")
        out[quoi] = {"reference": nr / n, "lecteur": nl / n, "communs": nc / n,
                     "jaccard": sum(jac) / max(len(jac), 1)}
    if a.json:
        Path(a.json).write_text(json.dumps(out, ensure_ascii=False, indent=1), encoding="utf-8")


if __name__ == "__main__":
    main()
