"""Les sens d'un lemme dans WordNet 3.0, avec leur clé, leur fichier lexicographique et leur glose : l'aide des
rédacteurs de cas (docs/BANCS_PHASE1.md, § 4). Ne lit que WordNet.

    python3 outils/bancs/sens.py DICT LEMME [CATEGORIE]      (CATEGORIE : n, v, a, r)"""
import os, sys

T = {"1": "n", "2": "v", "3": "a", "4": "r", "5": "a"}
F = {"n": "noun", "v": "verb", "a": "adj", "r": "adv"}


def main():
    dico, lemme = sys.argv[1], sys.argv[2].replace(" ", "_").lower()
    cat = sys.argv[3] if len(sys.argv) > 3 else None
    noms = {int(l.split()[0]): l.split()[1] for l in open(os.path.join(dico, "lexnames"))}
    for l in open(os.path.join(dico, "index.sense")):
        cle, off, num, _ = l.split()
        if not cle.startswith(lemme + "%"):
            continue
        t = T[cle.split("%")[1][0]]
        if cat and t != cat:
            continue
        with open(os.path.join(dico, "data." + F[t])) as d:
            d.seek(int(off))
            g = d.readline().split(" | ", 1)[1].strip()
        print(f"{cle}\t{noms[int(cle.split(':')[1])]}\t{num}\t{g}")


if __name__ == "__main__":
    main()
