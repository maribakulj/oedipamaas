"""Analyse un texte avec Stanza et écrit son CoNLL-U (D20 : un petit modèle de langue local, jamais un LLM).

Usage : python oedipamaas/socle/stanza_textes.py LANGUE ENTREE.txt SORTIE.conllu [MODELES]

Le CoNLL-U a la forme que lit conllu.pl (celle d'UDPipe 1 : positions TokenRange=debut:fin dans MISC) : c'est la
frontière du cahier, changer d'analyseur ne change rien au reste du moteur (udpipe.pl choisit l'analyseur).

Segmentation. Stanza ne sert qu'à couper les phrases ; les mots sont segmentés ici, par la même règle que les libellés
(outils/definitions/stanza_conllu.py), parce que le segmenteur anglais de Stanza prend « saint » pour une contraction
(« sai » + « nt ») : un mot est une suite de lettres, chiffres, traits d'union ou apostrophes internes ; l'élision
française (« l' », « d' », « qu' ») et, en anglais, les contractions (« n't », « 's », « 're », « 've », « 'll », « 'd »,
« 'm ») sont détachées ; toute autre ponctuation est un mot à elle seule. Puis catégories, lemmes et syntaxe par Stanza,
sur les mots donnés.

Stanza 1.10.1 (Apache 2.0), modèles UD par défaut (licences CC BY-SA des treebanks), dans MODELES
(/home/user/donnees/stanza par défaut ; réglage OEDIPAMAAS_STANZA)."""
import os
import re
import sys

MOT = re.compile(r"[^\W_]+(?:[-'’][^\W_]+)*|[^\w\s]", re.UNICODE)
ELISION = re.compile(r"^((?:[lLdDjJmMnNsStTcC]|[qQ]u|[lL]orsqu|[pP]uisqu|[jJ]usqu)['’])(.+)$")
CONTRACTION = re.compile(r"^(.+?)(n['’]t|['’](?:s|re|ve|ll|d|m))$", re.IGNORECASE)


def segmenter(texte, langue, debut=0, fin=None):
    """Les mots d'un passage et leurs positions dans le texte : [(mot, debut, fin)]."""
    fin = len(texte) if fin is None else fin
    out = []
    for m in MOT.finditer(texte, debut, fin):
        mot, d = m.group(0), m.start()
        if langue == "fr" and (e := ELISION.match(mot)):
            out.append((e.group(1), d, d + len(e.group(1))))
            out.append((e.group(2), d + len(e.group(1)), m.end()))
        elif langue == "en" and (c := CONTRACTION.match(mot)) and len(c.group(1)) >= 1:
            out.append((c.group(1), d, d + len(c.group(1))))
            out.append((c.group(2), d + len(c.group(1)), m.end()))
        else:
            out.append((mot, d, m.end()))
    return out


def ligne(w, misc):
    return "\t".join([str(w.id), w.text, w.lemma or "_", w.upos or "_", w.xpos or "_", w.feats or "_",
                      str(w.head if w.head is not None else 0), w.deprel or "_", "_", misc])


def main(langue, entree, sortie, modeles=None):
    import stanza
    modeles = modeles or os.environ.get("OEDIPAMAAS_STANZA", "/home/user/donnees/stanza")
    texte = open(entree, encoding="utf-8").read()
    phrases = stanza.Pipeline(langue, dir=modeles, processors="tokenize", download_method=None, verbose=False)
    segs = []
    for s in phrases(texte).sentences:
        sg = segmenter(texte, langue, s.tokens[0].start_char, s.tokens[-1].end_char)
        if sg:
            segs.append(sg)
    proc = "tokenize,mwt,pos,lemma,depparse" if langue == "fr" else "tokenize,pos,lemma,depparse"
    nlp = stanza.Pipeline(langue, dir=modeles, processors=proc, download_method=None, verbose=False,
                          tokenize_pretokenized=True, pos_batch_size=3000, depparse_batch_size=3000)
    lignes = []
    if segs:
        doc = nlp([[m for m, _, _ in sg] for sg in segs])
        for phrase, sg in zip(doc.sentences, segs):
            for t, (_, d, f) in zip(phrase.tokens, sg):
                plage = f"TokenRange={d}:{f}"
                if len(t.words) > 1:
                    ids = [w.id for w in t.words]
                    lignes.append(f"{ids[0]}-{ids[-1]}\t{t.text}\t_\t_\t_\t_\t_\t_\t_\t{plage}")
                    lignes += [ligne(w, "_") for w in t.words]
                else:
                    lignes.append(ligne(t.words[0], plage))
            lignes.append("")
    with open(sortie, "w", encoding="utf-8") as out:
        out.write("\n".join(lignes) + "\n")


if __name__ == "__main__":
    main(*sys.argv[1:])
