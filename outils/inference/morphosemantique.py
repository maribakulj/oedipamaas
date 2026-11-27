"""Les liens morphosémantiques de WordNet 3.0 (Princeton, « morphosemantic-links.xls ») en faits Prolog.

Usage : python outils/inference/morphosemantique.py morphosemantic-links.xls SORTIE.pl

Chaque ligne du tableur relie un sens de verbe (arg1) à un sens de nom (arg2) par l'une de 14 relations (agent,
body-part, by-means-of, destination, event, instrument, location, material, property, result, state, undergoer, uses,
vehicle). Sortie : ms(Relation, SynsetVerbe, SynsetNom), dédoublonné (les lignes ne diffèrent parfois que par la
graphie du verbe), avec en tête la source et l'empreinte SHA-256 du tableur."""
import hashlib
import sys

import xlrd


def main():
    src, out = sys.argv[1], sys.argv[2]
    h = hashlib.sha256(open(src, "rb").read()).hexdigest()
    sh = xlrd.open_workbook(src).sheet_by_index(0)
    faits = set()
    for r in range(1, sh.nrows):
        row = sh.row_values(r)
        rel, v, n = str(row[2]).strip().replace("-", "_"), int(row[1]), int(row[4])
        faits.add((rel, v, n))
    with open(out, "w", encoding="utf-8") as f:
        f.write(f"% liens morphosémantiques de WordNet 3.0 ; source {src.split('/')[-1]} sha256 {h}\n")
        f.write(":- dynamic ms/3.\n")
        for rel, v, n in sorted(faits):
            f.write(f"ms({rel},{v},{n}).\n")
    print(f"{len(faits)} liens")


if __name__ == "__main__":
    main()
