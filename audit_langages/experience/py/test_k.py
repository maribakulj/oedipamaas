"""Tests pytest de la version Python : chaque mutant doit rendre exactement les violations attendues (écrites à la main)."""
import collections
import os
from pathlib import Path

import pytest

import construire_k as K

MUT = Path(os.environ["MUTANTS_DIR"])
PIVOT = K.lire_pivot(os.environ["WN30_IDS"])
ATTENDUS = collections.defaultdict(set)
for ligne in (MUT / "attendus.tsv").read_text(encoding="utf-8").splitlines():
    m, c, i = ligne.split("\t")
    ATTENDUS[m].add((c, i))


@pytest.mark.parametrize("fichier", sorted(MUT.glob("M*.tsv")), ids=lambda p: p.stem)
def test_mutant(fichier):
    obtenu = {(v.code, v.id) for v in K.controler(K.lire_k(fichier), PIVOT)}
    assert obtenu == ATTENDUS[fichier.stem]


def test_compilation_refusee_sur_une_base_fautive():
    with pytest.raises(ValueError):
        K.compiler(K.lire_k(MUT / "M06_vote_atteste.tsv"), PIVOT)
