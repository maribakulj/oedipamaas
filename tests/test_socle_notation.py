"""Grammaire de la notation (socle 1.0, pièce 1) : cas écrits à la main, et, si ICONCLASS_DATA désigne une copie du
dépôt iconclass/data, toutes les notations de base et un échantillon fixe de notations à clé."""
import os
import random
import re
from pathlib import Path

import pytest

janus = pytest.importorskip("janus_swi")
ICI = Path(__file__).resolve().parent.parent / "oedipamaas" / "socle"
janus.consult(str(ICI / "notation.pl"))


def analyse(a):
    r = janus.query_once("notation:analyser(A, _N), format(atom(S), '~q', [_N])", {"A": a})
    return r["S"] if r["truth"] else None


def normale(a):
    r = janus.query_once("notation:normaliser(A, F)", {"A": a})
    return r["F"] if r["truth"] else None


def ancetres(a):
    return {x["P"] for x in janus.query("notation:ancetre_syntaxique(A, P)", {"A": a})}


def test_formes():
    assert analyse("25F23(LION)(+12)") == ("[chiffre(2),chiffre(5),lettre('F'),chiffre(2),chiffre(3),nom('LION'),"
                                           "cle([chiffre(1),chiffre(2)])]")
    assert analyse("11HH(MARY MAGDALENE)") == "[chiffre(1),chiffre(1),double('H'),nom('MARY MAGDALENE')]"
    assert analyse("61B2(...)") == "[chiffre(6),chiffre(1),lettre('B'),chiffre(2),gabarit]"
    assert analyse("11H(JEROME)36") == "[chiffre(1),chiffre(1),lettre('H'),nom('JEROME'),chiffre(3),chiffre(6)]"
    assert analyse("83(BOCCACCIO, Decamerone)") == "[chiffre(8),chiffre(3),nom('BOCCACCIO, Decamerone')]"
    assert analyse("49E1(+52(GYROSCOPE))") == ("[chiffre(4),chiffre(9),lettre('E'),chiffre(1),"
                                               "cle([chiffre(5),chiffre(2),nom('GYROSCOPE')])]")
    assert analyse("31A:61B2(...)").startswith("composee([[chiffre(3)")
    assert analyse("11J") is None and analyse("") is None and analyse("(LION)") is None


def test_forme_machine():
    assert normale("25 F 23 (LION) (+12)") == "25F23(LION)(+12)"
    assert normale("11HH(  MARY   MAGDALENE )") == "11HH(MARY MAGDALENE)"
    assert normale("61B2(...) : 31D14") == "61B2(...):31D14"


def test_ancetres():
    assert ancetres("25F23(LION)(+12)") == {"2", "25", "25F", "25F2", "25F23", "25F23(LION)", "25F23(LION)(+1)",
                                            "25F23(LION)(+12)"}
    assert ancetres("11HH(MARY MAGDALENE)") == {"1", "11", "11HH", "11HH(MARY MAGDALENE)"}
    assert ancetres("31A:61B") == {"3", "31", "31A", "6", "61", "61B", "31A:61B"}
    assert janus.query_once("notation:parent_syntaxique('25F23(LION)(+12)', P)")["P"] == "25F23(LION)(+1)"
    assert janus.query_once("notation:parent_syntaxique('25F23(LION)(+1)', P)")["P"] == "25F23(LION)"
    assert janus.query_once("notation:sans_cle('25F23(LION)(+12)', B)")["B"] == "25F23(LION)"
    assert janus.query_once("notation:profondeur('11H(JEROME)36', N)")["N"] == 6


TOKEN = re.compile(r"\([^)]*\)|[A-Z]{1,2}|\d")      # découpage de la mesure hiérarchique (préfixes de jetons)


def prefixes_mesure(code):
    out, cur = set(), ""
    for t in TOKEN.findall(code):
        cur += t
        out.add(cur)
    return out


DONNEES = os.environ.get("ICONCLASS_DATA")


@pytest.mark.skipif(not DONNEES, reason="ICONCLASS_DATA non défini (copie du dépôt iconclass/data)")
def test_toutes_les_notations():
    d = Path(DONNEES)
    notations = [x[2:] for x in (d / "notations.txt").read_text(encoding="utf-8").splitlines() if x.startswith("N ")]
    assert len(notations) > 40000
    rates = [n for n in notations if normale(n) != n]
    assert not rates, rates[:20]
    # sans clé, les ancêtres syntaxiques sont les préfixes de jetons de la mesure hiérarchique
    ecarts = [n for n in notations[::7] if ancetres(n) != prefixes_mesure(n)]
    assert not ecarts, ecarts[:20]
    # notations à clé : chaque notation de l'échantillon avec chaque suffixe de sa famille
    familles, k = {}, None
    for x in (d / "keys.txt").read_text(encoding="utf-8").splitlines():
        if x.startswith("K "):
            k = x[2:]
        elif x[:2] in ("S ", "; ") and k:
            familles.setdefault(k, []).append(x[2:])
    famille_de, n = {}, None
    for x in (d / "notations.txt").read_text(encoding="utf-8").splitlines():
        if x.startswith("N "):
            n = x[2:]
        elif x.startswith("K ") and n:
            famille_de[n] = x[2:]
    tirage = random.Random(20261123).sample(sorted(famille_de), 300)
    for n in tirage:
        for s in familles.get(famille_de[n], []):
            if "q" in s:
                continue
            a = f"{n}(+{s})"
            assert normale(a) == a, a
