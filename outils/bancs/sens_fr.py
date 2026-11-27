"""Les sens d'un lemme français dans WOLF (par l'Open Multilingual Wordnet 1.4, fichier wn-data-fra.tab), avec, pour
chaque synset de WordNet 3.0, ses clés de sens anglaises, son fichier lexicographique et sa glose : l'aide des
rédacteurs de cas pour les descriptions françaises (docs/BANCS_PHASE1.md, § 4.1). Ne lit que WordNet et WOLF.

    python3 outils/bancs/sens_fr.py DICT WN-DATA-FRA.TAB LEMME [CATEGORIE]      (CATEGORIE : n, v, a, r)"""
import os, sys

F = {"n": "noun", "v": "verb", "a": "adj", "s": "adj", "r": "adv"}
T = {"1": "n", "2": "v", "3": "a", "4": "r", "5": "a"}


def main():
    dico, tab, lemme = sys.argv[1], sys.argv[2], sys.argv[3].lower()
    cat = sys.argv[4] if len(sys.argv) > 4 else None
    syns = []
    for l in open(tab, encoding="utf-8"):
        if l.startswith("#"):
            continue
        p = l.rstrip("\n").split("\t")
        if len(p) == 3 and p[1] == "fra:lemma" and p[2].lower() == lemme:
            off, c = p[0].split("-")
            c = "a" if c == "s" else c
            if not cat or c == cat:
                syns.append((off, c))
    if not syns:
        print(f"{lemme} : absent de WOLF")
        return
    cles = {}
    noms = {int(l.split()[0]): l.split()[1] for l in open(os.path.join(dico, "lexnames"))}
    for l in open(os.path.join(dico, "index.sense")):
        cle, off = l.split()[:2]
        cles.setdefault((off, T[cle.split("%")[1][0]]), []).append(cle)
    for off, c in sorted(set(syns)):
        with open(os.path.join(dico, "data." + F[c])) as d:
            d.seek(int(off))
            ligne = d.readline()
        g = ligne.split(" | ", 1)[1].strip()
        ks = cles.get((off, c), [])
        lf = noms[int(ks[0].split(":")[1])] if ks else "?"
        print(f"{off}-{c}\t{lf}\t{' '.join(ks)}\t{g}")


if __name__ == "__main__":
    main()
