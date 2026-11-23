"""Morphologie (socle 1.0, pièce 3) sur WordNet 3.0 compilé : si WORDNET_PROLOG (dossier prolog/ de WNprolog 3.0) et
WORDNET_DICT (dossier dict/ de WordNet 3.0) sont définis ; sinon le test est sauté."""
import os
import tempfile
from pathlib import Path

import pytest

janus = pytest.importorskip("janus_swi")
SOCLE = Path(__file__).resolve().parent.parent / "oedipamaas" / "socle"
WNP, WND = os.environ.get("WORDNET_PROLOG"), os.environ.get("WORDNET_DICT")


@pytest.mark.skipif(not (WNP and WND), reason="WORDNET_PROLOG et WORDNET_DICT non définis")
def test_lemmes():
    from oedipamaas.socle.compiler_wordnet import compiler
    with tempfile.TemporaryDirectory() as t:
        m = compiler(WNP, WND, t)
        assert m["comptes"]["s"] > 200000 and m["comptes"]["exc"] > 6000
        assert sum(m["lignes_mal_formees_ecartees"].values()) < 10
        janus.consult(str(Path(t) / "wordnet.pl"))
        janus.consult(str(SOCLE / "morphologie.pl"))
        attendu = {"mice": ["mouse"], "kneeling": ["kneel", "kneeling"], "crowns of thorns": ["crown of thorns"],
                   "putti": ["putto"], "beheads": ["behead"], "women": ["woman"], "crucifixes": ["crucifix"],
                   "leaves": ["leaf", "leave"], "wolves": ["wolf"], "grisaille": ["grisaille"],
                   "Saint Jerome": ["saint jerome"]}
        for mot, lemmes in attendu.items():
            r = janus.query_once("morphologie:tous_lemmes(M, L)", {"M": mot})
            assert r["L"] == lemmes, (mot, r["L"])
        assert janus.query_once("morphologie:lemmes(sleeping, v, L)")["L"] == ["sleep"]
        assert janus.query_once("morphologie:lemme(haloes, L)")["L"] == "halo"
