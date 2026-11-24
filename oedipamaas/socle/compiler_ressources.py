"""Compile les ressources de langue de D17 en faits Prolog (module ressources), hors ligne, une fois.

Usage : python -m oedipamaas.socle.compiler_ressources DOSSIER_RESSOURCES SORTIE/

Pour l'instant : les liens morphosémantiques de WordNet 3.0 (Princeton, « morphosemantic-links.xls », même licence que
WordNet) : 17 739 liens entre un sens verbal et un sens nominal dérivé, typés (event, agent, instrument, result,
state, property, location, uses, body-part, by-means-of, material, vehicle, undergoer, destination).
  morphosem(SynsetVerbe, Verbe, Relation, SynsetNom, Nom)
Les synsets sont au format de l'édition Prolog (1xxxxxxxx nom, 2xxxxxxxx verbe). Transcription sans jugement ; quelles
relations le moteur utilise est une décision du moteur (docs/FONDEMENTS.md, § 4.1), pas du compilateur.
Et WOLF, le WordNet libre du français (Benoît Sagot, Darja Fišer ; CeCILL-C), dans l'édition de l'Open Multilingual
Wordnet 1.4 (omw-1.4/fra/wn-data-fra.tab), aligné sur les synsets de WordNet 3.0 :
  wolf(Synset, Lemme)          un mot français d'un synset (« lion » : 102129165)
VerbNet, FrameNet et NomBank seront compilés ici quand le moteur les intégrera, un par un (D17)."""
import hashlib
import json
import sys
from pathlib import Path


def q(s):
    return "'" + s.replace("\\", "\\\\").replace("'", "\\'") + "'"


def lemme(cle):
    return cle.split("%", 1)[0].replace("_", " ")


def compiler(dossier, sortie):
    import xlrd                                     # dépendance de compilation seulement
    dossier, sortie = Path(dossier), Path(sortie)
    src = dossier / "morphosemantic-links.xls"
    feuille = xlrd.open_workbook(str(src)).sheet_by_index(0)
    chemin = sortie / "ressources.pl"
    n = 0
    with open(chemin, "w", encoding="utf-8") as out:
        out.write(":- module(ressources, [morphosem/5, wolf/2]).\n:- encoding(utf8).\n")
        for i in range(1, feuille.nrows):
            v = feuille.row_values(i)
            if len(v) < 5 or not v[0]:
                continue
            out.write(f"morphosem({int(v[1])}, {q(lemme(v[0]))}, {q(v[2])}, {int(v[4])}, {q(lemme(v[3]))}).\n")
            n += 1
        wolf = dossier / "omw" / "omw-1.4" / "fra" / "wn-data-fra.tab"
        nw = 0
        if wolf.exists():
            prefixe = {"n": 1, "v": 2, "a": 3, "s": 3, "r": 4}
            for ligne in wolf.read_text(encoding="utf-8").splitlines():
                champs = ligne.split("\t")
                if len(champs) == 3 and champs[1] == "fra:lemma" and "-" in champs[0]:
                    off, pos = champs[0].split("-")
                    if pos in prefixe:
                        out.write(f"wolf({prefixe[pos] * 100000000 + int(off)}, {q(champs[2].strip())}).\n")
                        nw += 1
    manifeste = {"source": "WordNet 3.0 morphosemantic links (Princeton), morphosemantic-links.xls ; WOLF (OMW 1.4)",
                 "licence": "WordNet 3.0 license (Princeton University) ; WOLF : CeCILL-C", "comptes": {"morphosem": n, "wolf": nw},
                 "sha256_sources": {src.name: hashlib.sha256(src.read_bytes()).hexdigest(),
                                    "wn-data-fra.tab": hashlib.sha256(wolf.read_bytes()).hexdigest() if wolf.exists() else None},
                 "sha256": {"ressources.pl": hashlib.sha256(chemin.read_bytes()).hexdigest()}}
    (sortie / "manifeste-ressources.json").write_text(json.dumps(manifeste, ensure_ascii=False, indent=1) + "\n",
                                                      encoding="utf-8")
    return manifeste


if __name__ == "__main__":
    if len(sys.argv) != 3:
        raise SystemExit(__doc__)
    print(json.dumps(compiler(*sys.argv[1:]), ensure_ascii=False))
