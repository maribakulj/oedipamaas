"""Mesure du banc d'essai de la refonte (docs/REFONTE.md, § 5) : codes établis par le moteur contre la référence.

Usage : python outils/mesure/banc.py REFERENCE.json SORTIE.jsonl
Un code établi est exact s'il est dans la référence ; juste s'il est un code de la référence ou l'un de ses ancêtres
(trop général mais vrai) ; le rappel compte les codes de la référence retrouvés exactement ou par un descendant."""
import json
import sys

sys.path.insert(0, __file__.rsplit("/", 1)[0])
from mesure import normaliser, prefixes  # noqa: E402


def main(reference, sortie):
    ref = {str(r["n"]): {normaliser(c["code"]) for c in r["codes"]} for r in json.load(open(reference, encoding="utf-8"))}
    et_tot = exact = juste = 0
    trouves = 0
    tot_ref = sum(len(v) for v in ref.values())
    faux = []
    for l in open(sortie, encoding="utf-8"):
        d = json.loads(l)
        g = ref.get(d["document"], set())
        anc = set().union(*[prefixes(c) for c in g]) if g else set()
        codes = {normaliser(c["code"]) for c in d.get("etablis", [])}
        for c in codes:
            et_tot += 1
            exact += c in g
            juste += c in anc
            if c not in anc:
                faux.append((d["document"], c))
        trouves += sum(1 for c in g if any(c in prefixes(x) or x == c for x in codes))
    print(json.dumps({"codes_etablis": et_tot, "precision_exacte": round(exact / max(1, et_tot), 3),
                      "precision_juste": round(juste / max(1, et_tot), 3),
                      "rappel": round(trouves / max(1, tot_ref), 3), "codes_reference": tot_ref,
                      "faux": faux[:40]}, ensure_ascii=False))


if __name__ == "__main__":
    main(*sys.argv[1:3])
