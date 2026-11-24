"""Les comptes du prototype vertical (sortie de outils/vertical/projeter.pl).

Usage : python outils/vertical/mesurer.py RESULTATS.json FICHES.json

Pour chaque genre de texte (positif, négatif, indéterminé) : le statut de la notation visée (établie, établie par un
descendant, candidate, contredite, absente), par strate ; et le nombre de codes établis autres que la notation visée
et ses ancêtres (à juger : faux positifs possibles)."""
import collections
import json
import sys


def ancetre(a, n):
    return n != a and n.startswith(a.split("(")[0]) and len(a) < len(n)


def main(res, fiches):
    R = json.load(open(res, encoding="utf-8"))
    strate = {f["k"]: f["strate"] for f in json.load(open(fiches, encoding="utf-8"))}
    for g in ("positif", "negatif", "indetermine"):
        c, cs, autres = collections.Counter(), collections.defaultdict(collections.Counter), 0
        for r in R:
            v = r.get(g, {"statut": "absent"})
            c[v["statut"]] += 1
            cs[strate.get(r["k"], "?")][v["statut"]] += 1
            autres += sum(1 for e in v.get("etablis", []) if e != r["notation"] and not ancetre(e, r["notation"])
                          and not ancetre(r["notation"], e))
        print(f"\n{g} : {dict(c)} ; codes établis autres : {autres}")
        for s, cc in sorted(cs.items()):
            print(f"  {s:20} {dict(cc)}")


if __name__ == "__main__":
    main(*sys.argv[1:])
