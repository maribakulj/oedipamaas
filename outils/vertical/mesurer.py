"""Les comptes du prototype vertical (sortie de outils/vertical/projeter.pl).

Usage : python outils/vertical/mesurer.py RESULTATS.json FICHES.json

Pour chaque genre de texte (positif, négatif, indéterminé) : le statut de la notation visée (établie, établie par un
descendant, candidate, contredite, absente), par strate ; et le nombre de codes établis autres que la notation visée
et de sa branche (à juger : faux positifs possibles), tel que projeter.pl le calcule sur l'arbre canonique
d'Iconclass (champ « hors_branche ») ; jamais par les préfixes des notations."""
import collections
import json
import sys


def main(res, fiches):
    R = json.load(open(res, encoding="utf-8"))
    strate = {f["k"]: f["strate"] for f in json.load(open(fiches, encoding="utf-8"))}
    for g in ("positif", "negatif", "indetermine"):
        c, cs, autres = collections.Counter(), collections.defaultdict(collections.Counter), 0
        for r in R:
            v = r.get(g, {"statut": "absent"})
            c[v["statut"]] += 1
            cs[strate.get(r["k"], "?")][v["statut"]] += 1
            if v["statut"] not in ("delai", "erreur") and "hors_branche" not in v:
                raise SystemExit("résultats sans « hors_branche » : relancer outils/vertical/projeter.pl")
            autres += len(v.get("hors_branche", []))
        print(f"\n{g} : {dict(c)} ; codes établis autres : {autres}")
        for s, cc in sorted(cs.items()):
            print(f"  {s:20} {dict(cc)}")


if __name__ == "__main__":
    main(*sys.argv[1:])
