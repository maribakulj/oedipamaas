"""Décomposition des libellés (socle 1.0, pièce 2) : petit Iconclass factice ; si ICONCLASS_DATA est défini, des
libellés réels choisis pour chaque séparateur."""
import os
import tempfile
from pathlib import Path

import pytest

janus = pytest.importorskip("janus_swi")
SOCLE = Path(__file__).resolve().parent.parent / "oedipamaas" / "socle"

NOTATIONS = "N 11H(...)\nC 11H(ANDREW)\n$\nN 11H(ANDREW)\nC 11H(ANDREW)1\n; 11H(ANDREW)2\n$\nN 11H(ANDREW)1\n$\n" \
            "N 11H(ANDREW)2\n$\nN 25FF\nC 25FF2\n$\n" \
            "N 25FF2\nC 25FF23\n$\nN 25FF23\n$\nN 81C\n$\nN 11F73\n$\nN 92B1217\n$\n" \
            "N 41A251\n$\nN 41C326\n$\nN 61B\n$\nN 25F711\n$\n"
LIBELLES = """11H(...)|male saint (with NAME)
11H(ANDREW)|the apostle Andrew; possible attributes: book, X-shaped cross, fish (in hand, or on a dish), rope
11H(ANDREW)1|the apostle Andrew; possible attributes: book, X-shaped cross, fish (in hand, or on a dish), rope - specific aspects ~ male saint
11H(ANDREW)2|the apostle Andrew; possible attributes: book, X-shaped cross, fish (in hand, or on a dish), rope - early life of male saint
25FF2|fabulous animals
25FF23|fabulous animals ~ predatory animals
81C|Dante, 'Divina Commedia' : Use 83(DANTE, Divina Commedia)
11F73|specific aspects of Mary ~ Madonna-representations (N.B. secondary notation only)
92B1217|Jupiter wooing Danae; she is usually lying in bed receiving a shower of gold
41A251|study; 'studiolo'; library
41C326|jar, jug (used as drinking-vessel)
61B|historical persons (portraits and scenes from the life)
25F711|insects: butterfly, moth
"""


@pytest.fixture(scope="module")
def petit():
    from oedipamaas.socle.compiler_iconclass import compiler
    with tempfile.TemporaryDirectory() as t:
        d = Path(t) / "depot"
        (d / "txt" / "en").mkdir(parents=True)
        (d / "kw" / "en").mkdir(parents=True)
        (d / "notations.txt").write_text(NOTATIONS, encoding="utf-8")
        (d / "keys.txt").write_text("", encoding="utf-8")
        (d / "txt" / "en" / "txt_en_0_1.txt").write_text(LIBELLES, encoding="utf-8")
        (d / "COMMIT").write_text("essai\n")
        compiler(d, Path(t) / "base")
        janus.query_once(f"load_files('{Path(t) / 'base' / 'iconclass.pl'}', [redefine_module(true)])")
        janus.consult(str(SOCLE / "libelles.pl"))
        janus.query_once("abolish_all_tables")
        yield


def un(q, v="X"):
    r = janus.query_once(q)
    return r[v] if r["truth"] else None


def test_decomposition(petit):
    assert un("libelles:attributs_possibles('11H(ANDREW)', X)") == ["book", "X-shaped cross",
                                                                    "fish (in hand, or on a dish)", "rope"]
    assert un("libelles:partie('11H(ANDREW)1', 2, X)") == "specific aspects ~ male saint"
    assert un("libelles:principal('11H(ANDREW)1', X)") == "the apostle Andrew"
    assert un("libelles:mots_propres('11H(ANDREW)1', X)") == ["aspects", "male", "saint", "specific"]
    assert un("libelles:mots_distinctifs('11H(ANDREW)1', X)") == ["aspects", "specific"]   # la catégorie, pas le saint
    assert un("libelles:mots_propres('25FF23', X)") == ["predatory"]
    assert un("libelles:concept_contexte('25FF23', C, X)") == "predatory animals"
    assert janus.query_once("libelles:consigne('81C', preferer('83(DANTE, Divina Commedia)'))")["truth"]
    assert janus.query_once("libelles:consigne('11F73', secondaire)")["truth"]


def test_elements(petit):
    # ce qui nomme une notation à soi seul : synonymes « ; », éléments « , », sans parenthèses, après « titre: »,
    # avant « ~ », ni attributs possibles ni indices visuels
    assert un("libelles:elements('41A251', X)") == ["study", "'studiolo'", "library"]
    assert un("libelles:elements('41C326', X)") == ["jar", "jug"]
    assert un("libelles:elements('25F711', X)") == ["butterfly", "moth"]
    assert un("libelles:elements('25FF23', X)") == ["fabulous animals"]
    assert un("libelles:elements('11H(ANDREW)', X)") == ["the apostle Andrew"]
    assert un("libelles:elements('92B1217', X)") == ["Jupiter wooing Danae"]
    assert un("libelles:elements('61B', X)") == ["historical persons"]
    assert un("libelles:elements('11H(ANDREW)1', X)") is None             # libellé fabriqué : pas d'éléments
    assert un("libelles:precisions('61B', X)") == ["portraits", "scenes from the life"]
    assert un("libelles:precisions('41C326', X)") == ["used as drinking-vessel"]
    assert un("libelles:precisions('11H(ANDREW)2', X)") is None            # fabriqué : celles de la base
    assert un("libelles:mots_hors_parentheses('61B', X)") == ["historical", "persons"]
    assert un("libelles:principal('11F73', X)") == "specific aspects of Mary ~ Madonna-representations"
    assert un("libelles:indice_visuel('92B1217', X)") == "she is usually lying in bed receiving a shower of gold"
    assert un("libelles:mots_pleins('The Seven Sleepers (children) of Ephesus', X)") == ["children", "ephesus",
                                                                                         "seven", "sleepers"]


DONNEES = os.environ.get("ICONCLASS_DATA")


@pytest.mark.skipif(not DONNEES, reason="ICONCLASS_DATA non défini (copie du dépôt iconclass/data)")
def test_libelles_reels():
    from oedipamaas.socle.compiler_iconclass import compiler
    with tempfile.TemporaryDirectory() as t:
        compiler(DONNEES, t)
        janus.query_once(f"load_files('{Path(t) / 'iconclass.pl'}', [redefine_module(true)])")
        janus.consult(str(SOCLE / "libelles.pl"))
        janus.query_once("abolish_all_tables")
        assert un("libelles:mots_propres('71H1443', X)") == ["beheads", "sword"]
        assert un("libelles:attributs_possibles('11H(ANDREW)131', X)") == ["book", "X-shaped cross", "fish",
                                                                           "fishing-net", "rope", "scroll"]
        # toutes les notations à « possible attributes » donnent une liste non vide
        vides = un("aggregate_all(count, (iconclass:libelle(_N, en, _T), sub_atom(_T, _, _, _, 'possible attributes'),"
                   " \\+ (libelles:attributs_possibles(_N, _A), _A \\== [])), X)")
        assert vides == 0, vides
        # chaque « : Use … » donne une notation préférée ; « Use of Property » (55C) n'est pas une consigne
        manques = un("aggregate_all(count, (iconclass:libelle(_N, en, _T), sub_atom(_T, _, _, _, ' : Use '),"
                     " \\+ libelles:consigne(_N, preferer(_))), X)")
        assert manques == 0, manques
        assert not janus.query_once("libelles:consigne('55C', preferer(_))")["truth"]
