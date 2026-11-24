"""Analyse une liste de textes avec Stanza et écrit leur CoNLL-U, à la compilation seulement (D18).

Usage : python outils/definitions/stanza_conllu.py LANGUE ENTREE.jsonl SORTIE.jsonl [MODELES]

ENTREE.jsonl : une ligne par texte, {"k": rang, "texte": "..."} ; SORTIE.jsonl : {"k": rang, "conllu": "..."}, dans le
même ordre. Le CoNLL-U suit la forme que lit oedipamaas/socle/conllu.pl (celle d'UDPipe 1) : positions en caractères
dans MISC (TokenRange=debut:fin), mots composés (« du » → « de le ») sur une ligne de plage. C'est la frontière du
cahier : changer d'analyseur ne change rien au reste du moteur.

Stanza 1.10.1 (Apache 2.0), modèles UD par défaut de la langue (anglais : EWT ; français : combinés), licences des
treebanks UD (CC BY-SA) ; modèles dans /home/user/donnees/stanza (MODELES)."""
import json
import sys


def conllu(doc):
    lignes = []
    for s in doc.sentences:
        for t in s.tokens:
            plage = f"TokenRange={t.start_char}:{t.end_char}"
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
                          tokenize_batch_size=256, pos_batch_size=3000, depparse_batch_size=3000)
    textes = [json.loads(l) for l in open(entree, encoding="utf-8")]
    with open(sortie, "w", encoding="utf-8") as out:
        pas = 500
        for i in range(0, len(textes), pas):
            lot = textes[i:i + pas]
            docs = nlp.bulk_process([stanza.Document([], text=t["texte"]) for t in lot])
            for t, d in zip(lot, docs):
                out.write(json.dumps({"k": t["k"], "conllu": conllu(d)}, ensure_ascii=False) + "\n")
            print(f"{langue} {i + len(lot)}/{len(textes)}", file=sys.stderr, flush=True)


if __name__ == "__main__":
    main(*sys.argv[1:])
