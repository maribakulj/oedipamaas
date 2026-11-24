"""Analyse une liste de textes avec Stanza et écrit leur CoNLL-U, à la compilation seulement (D18).

Usage : python outils/definitions/stanza_conllu.py LANGUE ENTREE.jsonl SORTIE.jsonl [MODELES]

ENTREE.jsonl : une ligne par texte, {"k": rang, "texte": "..."} ; SORTIE.jsonl : {"k": rang, "conllu": "..."}, dans le
même ordre. Le CoNLL-U suit la forme que lit oedipamaas/socle/conllu.pl (celle d'UDPipe 1) : positions en caractères
dans MISC (TokenRange=debut:fin), mots composés (« du » → « de le ») sur une ligne de plage. C'est la frontière du
cahier : changer d'analyseur ne change rien au reste du moteur.

Segmentation : les libellés sont segmentés ici, par une règle simple, et donnés à Stanza déjà segmentés : son
segmenteur anglais prend « saint » pour une contraction (« sai » + « nt », comme « ain't »), et les libellés
d'Iconclass n'ont pas de contractions. Un mot : une suite de lettres, de chiffres, de traits d'union ou
d'apostrophes internes ; l'élision française (« l' », « d' », « qu' ») et le possessif anglais (« 's ») sont détachés ;
toute autre ponctuation est un mot à elle seule.

Stanza 1.10.1 (Apache 2.0), modèles UD par défaut de la langue (anglais : EWT ; français : combinés), licences des
treebanks UD (CC BY-SA) ; modèles dans /home/user/donnees/stanza (MODELES)."""
import json
import re
import sys

MOT = re.compile(r"[^\W_]+(?:[-'’][^\W_]+)*|[^\w\s]", re.UNICODE)
ELISION = re.compile(r"^((?:[lLdDjJmMnNsStTcC]|[qQ]u|[lL]orsqu|[pP]uisqu|[jJ]usqu)['’])(.+)$")


def segmenter(texte, langue):
    """Les mots d'un libellé et leurs positions : [(mot, debut, fin)]."""
    out = []
    for m in MOT.finditer(texte):
        mot, d = m.group(0), m.start()
        e = ELISION.match(mot) if langue == "fr" else None
        if e:
            out.append((e.group(1), d, d + len(e.group(1))))
            out.append((e.group(2), d + len(e.group(1)), m.end()))
        elif langue == "en" and re.search(r"['’]s$", mot) and len(mot) > 2:
            out.append((mot[:-2], d, m.end() - 2))
            out.append((mot[-2:], m.end() - 2, m.end()))
        else:
            out.append((mot, d, m.end()))
    return out


class Une:
    """Une phrase vue comme un document d'une phrase."""
    def __init__(self, phrase):
        self.sentences = [phrase]


def conllu(doc, positions):
    lignes = []
    k = 0
    for s in doc.sentences:
        for t in s.tokens:
            d, f = positions[k][1], positions[k][2]
            k += 1
            plage = f"TokenRange={d}:{f}"
            if len(t.words) > 1:
                ids = [w.id for w in t.words]
                lignes.append(f"{ids[0]}-{ids[-1]}\t{t.text}\t_\t_\t_\t_\t_\t_\t_\t{plage}")
                for w in t.words:
                    lignes.append(ligne(w, "_"))
            else:
                lignes.append(ligne(t.words[0], plage))
        lignes.append("")
    return "\n".join(lignes) + "\n"


def ligne(w, misc):
    return "\t".join([str(w.id), w.text, w.lemma or "_", w.upos or "_", w.xpos or "_", w.feats or "_",
                      str(w.head if w.head is not None else 0), w.deprel or "_", "_", misc])


def main(langue, entree, sortie, modeles="/home/user/donnees/stanza"):
    import stanza
    processeurs = "tokenize,mwt,pos,lemma,depparse" if langue == "fr" else "tokenize,pos,lemma,depparse"
    nlp = stanza.Pipeline(langue, dir=modeles, processors=processeurs, download_method=None, verbose=False,
                          tokenize_pretokenized=True, pos_batch_size=3000, depparse_batch_size=3000)
    textes = [json.loads(l) for l in open(entree, encoding="utf-8")]
    with open(sortie, "w", encoding="utf-8") as out:
        pas = 500
        for i in range(0, len(textes), pas):
            lot = textes[i:i + pas]
            segs = [segmenter(t["texte"], langue) or [(".", 0, 0)] for t in lot]
            doc = nlp([[m for m, _, _ in sg] for sg in segs])         # une phrase par libellé, un seul appel
            assert len(doc.sentences) == len(segs)
            for t, phrase, sg in zip(lot, doc.sentences, segs):
                out.write(json.dumps({"k": t["k"], "conllu": conllu(Une(phrase), sg)}, ensure_ascii=False) + "\n")
            print(f"{langue} {i + len(lot)}/{len(textes)}", file=sys.stderr, flush=True)


if __name__ == "__main__":
    main(*sys.argv[1:])
