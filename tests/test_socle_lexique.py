"""Lexique (socle 1.0, pièce 3) : index des formes d'Iconclass et pont WordNet. Petit Iconclass factice et WordNet
réel (WORDNET_PROLOG, WORDNET_DICT) ; sauté si WordNet n'est pas disponible."""
import os
import tempfile
from pathlib import Path

import pytest

janus = pytest.importorskip("janus_swi")
SOCLE = Path(__file__).resolve().parent.parent / "oedipamaas" / "socle"
WNP, WND = os.environ.get("WORDNET_PROLOG"), os.environ.get("WORDNET_DICT")

NOTATIONS = "N 11H(...)\nC 11H(JEROME)\n$\nN 11H(JEROME)\n$\nN 25F23(LION)\n$\nN 31A231\n$\n"
LIBELLES = ("11H(...)|male saint (with NAME)\n"
            "11H(JEROME)|Jerome, Father of the Church; possible attributes: book, cardinal's hat, lion, skull\n"
            "25F23(LION)|beasts of prey, predatory animals: lion\n31A231|kneeling figure\n")
MOTS = "25F23(LION)|lion\n31A231|kneeling\n11H(JEROME)|Jerome\n"
MOTS_DE = "25F23(LION)|Löwe\n"
RENVOIS = "KW1 genuflecting\nREF see\nKW2 kneeling\n$\n"


@pytest.mark.skipif(not (WNP and WND), reason="WORDNET_PROLOG et WORDNET_DICT non définis")
def test_index_et_pont():
    from oedipamaas.socle.compiler_iconclass import compiler
    from oedipamaas.socle.compiler_wordnet import compiler as compiler_wn
    with tempfile.TemporaryDirectory() as t:
        d = Path(t) / "depot"
        for p in ("txt/en", "kw/en", "kw/de"):
            (d / p).mkdir(parents=True)
        (d / "notations.txt").write_text(NOTATIONS, encoding="utf-8")
        (d / "keys.txt").write_text("", encoding="utf-8")
        (d / "txt/en/txt_en_0_1.txt").write_text(LIBELLES, encoding="utf-8")
        (d / "kw/en/kw_en_0_1.txt").write_text(MOTS, encoding="utf-8")
        (d / "kw/de/kw_de_0_1.txt").write_text(MOTS_DE, encoding="utf-8")
        (d / "kw/en/kw_en_refs.txt").write_text(RENVOIS, encoding="utf-8")
        (d / "COMMIT").write_text("essai\n")
        compiler(d, Path(t) / "base")
        compiler_wn(WNP, WND, Path(t) / "base")
        janus.query_once(f"load_files('{Path(t) / 'base' / 'iconclass.pl'}', [redefine_module(true)])")
        janus.query_once(f"load_files('{Path(t) / 'base' / 'wordnet.pl'}', [redefine_module(true)])")
        janus.consult(str(SOCLE / "lexique.pl"))
        janus.query_once("morphologie:indexer")
        janus.query_once("abolish_all_tables")
        index = Path(t) / "base" / "lexique_index.pl"
        janus.query_once(f"lexique:construire_index('{index}')")
        janus.query_once(f"load_files('{index}', [redefine_module(true)])")

        def notations(forme):
            return sorted({(x["N"], str(x["S"])) for x in janus.query("lexique_index:entree(F, N, _S), "
                                                                       "term_string(_S, S)", {"F": forme})})
        assert notations("kneel") == [("31A231", "mot_cle(en)"), ("31A231", "mot_libelle")]   # lemme du mot clé
        assert ("25F23(LION)", "mot_cle(de)") in notations("löwe")
        assert ("11H(JEROME)", "attribut") in notations("cardinals hat")     # apostrophes retirées des deux côtés
        assert ("31A231", "renvoi(kneeling)") in notations("genuflecting")
        voisins = {(x["G"], x["R"], x["P"]) for x in janus.query("lexique:voisin(F, G, R, P)", {"F": "backrest"})}
        assert ("chair", "partie_de", 1) in voisins
        assert janus.query_once("lexique:voisin(crosier, crozier, R, P)")["R"] == "synonyme"
        assert janus.query_once("lexique:voisin(knob, handle, R, P)")["R"] == "hyperonyme"
        g = janus.query_once("lexique:generalite_forme(entity, P, N)")
        assert g["P"] == 0 and g["N"] > 50000
