"""Clés (+…) (socle 1.0, R3) : petite famille factice (vue, positions, sexe et âge), WordNet réel (WORDNET_PROLOG,
WORDNET_DICT) ; sauté si WordNet n'est pas disponible."""
import os
import tempfile
from pathlib import Path

import pytest

janus = pytest.importorskip("janus_swi")
SOCLE = Path(__file__).resolve().parent.parent / "oedipamaas" / "socle"
WNP, WND = os.environ.get("WORDNET_PROLOG"), os.environ.get("WORDNET_DICT")

NOTATIONS = "N 3\nC 31\nK 31k\n$\nN 31\nC 31A\nK 31k\n$\nN 31A\nK 31k\n$\nN 4\n$\n"
KEYS = "K 31k\nS 0\n; 1\n; 3\n; 31\n; 33\n; 5\n; 51\n; 54\n; 5q1\n$\n"
TEXTES_CLES = ("31k0|variant\n31k1|front view\n31k3|sideview, profile\n31k31|left side visible\n31k33|seen from above\n"
               "31k5|positions (of the human figure)\n31k51|standing\n31k54|kneeling\n")


@pytest.mark.skipif(not (WNP and WND), reason="WORDNET_PROLOG et WORDNET_DICT non définis")
def test_cles():
    from oedipamaas.socle import faits_description as fd
    from oedipamaas.socle.compiler_iconclass import compiler
    from oedipamaas.socle.compiler_wordnet import compiler as compiler_wn
    with tempfile.TemporaryDirectory() as t:
        d = Path(t) / "depot"
        for p in ("txt/en", "kw/en"):
            (d / p).mkdir(parents=True)
        (d / "notations.txt").write_text(NOTATIONS, encoding="utf-8")
        (d / "keys.txt").write_text(KEYS, encoding="utf-8")
        (d / "txt/en/txt_en_keys.txt").write_text(TEXTES_CLES, encoding="utf-8")
        (d / "txt/en/txt_en_0_1.txt").write_text("31A|the human figure\n", encoding="utf-8")
        (d / "COMMIT").write_text("essai\n")
        base = Path(t) / "base"
        compiler(d, base)
        compiler_wn(WNP, WND, base)
        janus.query_once(f"load_files('{base / 'iconclass.pl'}', [redefine_module(true)])")
        janus.query_once(f"load_files('{base / 'wordnet.pl'}', [redefine_module(true)])")
        for f in ("lexique.pl", "description.pl", "recherche.pl", "specialisation.pl", "cles.pl"):
            janus.consult(str(SOCLE / f))
        janus.query_once("morphologie:indexer")
        janus.query_once("abolish_all_tables")
        for nom, but in (("lexique_index.pl", "lexique:construire_index"), ("cles_index.pl", "cles:construire_cles")):
            janus.query_once(f"{but}('{base / nom}')")
            janus.query_once(f"load_files('{base / nom}', [redefine_module(true)])")
        assert janus.query_once("cles_index:cle_parent('31k', '54', P)")["P"] == "5"
        assert not janus.query_once("cles_index:cle_parent('31k', '5q1', _)")["truth"]    # les queues : jamais
        assert not janus.query_once("cles_index:cle_parent('31k', '0', _)")["truth"]      # la variante : jamais
        # la clé doit être prouvée dans la même unité que la notation : « human figure » soutient 31A, ses
        # attributs « kneeling » et « seen in profile » donnent les clés ; « standing », dit d'une autre entité, non
        fd.charger(janus, {"entities": [{"id": "e1", "type": "human figure", "attributes": ["kneeling", "seen in profile"]},
                                        {"id": "e2", "type": "tree", "attributes": ["standing"]}],
                           "keywords": [], "subject": {}})
        janus.query_once("specialisation:decrire")
        c = janus.query_once("cles:cles_decrites('31A', C)")["C"]
        assert "31A(+54)" in c and "31A(+3)" in c, c       # à genoux, de profil
        assert "31A(+51)" not in c and "31A(+5)" not in c and "31A(+1)" not in c, c
        assert janus.query_once("cles:cles_decrites('4', C)")["C"] == []                  # pas de famille de clés
