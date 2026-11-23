"""Arbre d'Iconclass (socle 1.0, pièce 2) : petit Iconclass factice compilé par le vrai compilateur, puis, si
ICONCLASS_DATA désigne une copie du dépôt iconclass/data, la base complète."""
import os
import tempfile
from pathlib import Path

import pytest

janus = pytest.importorskip("janus_swi")
SOCLE = Path(__file__).resolve().parent.parent / "oedipamaas" / "socle"

NOTATIONS = """N 1
C 11
$
N 11
C 11H
; 11HH
$
N 11H
C 11H(...)
; 11HH
$
N 11H(...)
C 11H(...)3
; 11H(JEROME)
$
N 11H(JEROME)
C 11H(JEROME)3
K 11k
$
N 11H(JEROME)3
C 11H(JEROME)36
$
N 11H(JEROME)36
$
N 11HH
C 11HH(...)
$
N 11HH(...)
$
N 11H(...)3
$
N 2
C 25
$
N 25
C 25G
$
N 25G
C 25G3
$
N 25G3
C 25G3(PEAR-TREE)
; 25G3(PLUM-TREE)
$
N 25G3(PEAR-TREE)
C 25G3(...)
$
N 25G3(PLUM-TREE)
C 25G3(...)
$
"""
KEYS = """K 11k
S 0
; 1
; 11
; 3
$
"""


@pytest.fixture(scope="module")
def petit():
    from oedipamaas.socle.compiler_iconclass import compiler
    with tempfile.TemporaryDirectory() as t:
        d = Path(t) / "depot"
        (d / "txt" / "en").mkdir(parents=True)
        (d / "kw" / "en").mkdir(parents=True)
        (d / "notations.txt").write_text(NOTATIONS, encoding="utf-8")
        (d / "keys.txt").write_text(KEYS, encoding="utf-8")
        (d / "txt" / "en" / "txt_en_0_1.txt").write_text("11H(JEROME)|Jerome\n", encoding="utf-8")
        (d / "COMMIT").write_text("essai\n")
        compiler(d, Path(t) / "base")
        janus.consult(str(Path(t) / "base" / "iconclass.pl"))
        janus.consult(str(SOCLE / "arbre.pl"))
        yield


def un(q, v="X"):
    r = janus.query_once(q)
    return r[v] if r["truth"] else None


def tous(q, v="X"):
    return sorted(x[v] for x in janus.query(q))


def test_petit_arbre(petit):
    assert un("arbre:parent('11HH', X)") == "11" and un("arbre:jumeau('11HH', X)") == "11H"
    assert un("arbre:parent('11H(JEROME)', X)") == "11H(...)"         # un nom listé est enfant du gabarit
    assert tous("arbre:ancetre('11H(JEROME)36', X)") == ["1", "11", "11H", "11H(...)", "11H(JEROME)",
                                                          "11H(JEROME)3"]
    assert un("arbre:parent('25G3(...)', X)") == "25G3(PEAR-TREE)"    # défaut : premier parent cité
    assert un("arbre:autre_parent('25G3(...)', X)") == "25G3(PLUM-TREE)"
    assert tous("arbre:racine(X)") == ["1", "2"]
    assert un("arbre:enfants('11H', X)") == ["11H(...)"]
    assert un("arbre:parent('11H(JEROME)(+11)', X)") == "11H(JEROME)(+1)"
    assert un("arbre:parent('11H(JEROME)(+1)', X)") == "11H(JEROME)"
    assert janus.query_once("arbre:valide('11H(JEROME)(+11)')")["truth"]
    assert not janus.query_once("arbre:valide('11H(JEROME)(+2)')")["truth"]   # suffixe hors de la famille
    assert not janus.query_once("arbre:valide('11H(...)3(+1)')")["truth"]      # pas de famille de clés
    # un nom libre : enfant de son gabarit, comme un nom listé ; ce qui le suit a pour parent son préfixe
    assert un("arbre:parent('11H(NOUVEAU)', X)") == "11H(...)"
    assert un("arbre:parent('11H(NOUVEAU)3', X)") == "11H(NOUVEAU)"
    assert tous("arbre:ancetre('11H(NOUVEAU)3', X)") == ["1", "11", "11H", "11H(...)", "11H(NOUVEAU)"]
    assert un("arbre:profondeur_arbre('11H(NOUVEAU)', X)") == 4
    assert janus.query_once("arbre:valide('11H(NOUVEAU)')")["truth"]
    assert janus.query_once("arbre:valide('11H(NOUVEAU)3')")["truth"]
    assert un("arbre:gabarit_de('11H(NOUVEAU)3', X)") == "11H(...)3"
    assert not janus.query_once("arbre:valide('11HH(NOUVEAU)3')")["truth"]   # 11HH(...)3 n'existe pas
    assert not janus.query_once("arbre:valide('25G(NOUVEAU)')")["truth"]     # 25G n'a pas de gabarit
    assert un("arbre:parent('11H(JEROME)', X)") == "11H(...)"               # un nom listé ne change pas


DONNEES = os.environ.get("ICONCLASS_DATA")


@pytest.mark.skipif(not DONNEES, reason="ICONCLASS_DATA non défini (copie du dépôt iconclass/data)")
def test_base_complete():
    from oedipamaas.socle.compiler_iconclass import compiler
    with tempfile.TemporaryDirectory() as t:
        m = compiler(DONNEES, t)
        assert m["comptes"]["n"] > 40000
        janus.query_once(f"load_files('{Path(t) / 'iconclass.pl'}', [redefine_module(true)])")
        janus.consult(str(SOCLE / "arbre.pl"))
        janus.query_once("abolish_all_tables")
        jumeaux = un("aggregate_all(count, distinct(_N, (iconclass:enfant(_, _N, _), arbre:jumeau(_N, _))), X)")
        sans_parent = un("aggregate_all(count, (iconclass:n(_N), \\+ arbre:racine(_N), \\+ arbre:parent(_N, _)), X)")
        autres = tous("arbre:autre_parent(_N, X)")
        racines = tous("arbre:racine(X)")
        assert un("arbre:jumeau('11DD31', X)") == "11D31" and un("arbre:parent('11DD31', X)") == "11DD3"
    assert jumeaux == 2632, jumeaux                       # comptes de l'étude d'Iconclass (commit 0595358)
    assert sans_parent == 0, sans_parent
    # défaut connu : 25GG3(...), enfant de 25GG3, est aussi cité par deux arbres fruitiers
    assert autres == ["25G3(PEAR-TREE)", "25G3(PLUM-TREE)"], autres
    assert racines == [str(i) for i in range(10)], racines
