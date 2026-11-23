"""Décision compilée en Prolog (socle 1.0, § 9) : une petite forêt écrite à la main, au format du noyau de
calibration ; les probabilités de Prolog égalent la relecture Python (règle du noyau : à gauche si ≤ seuil), et la
sélection suit le réglage (k, seuil, critère), puis garde les plus spécifiques et retire la division 86."""
import json
import math
import tempfile
from pathlib import Path

import pytest

janus = pytest.importorskip("janus_swi")
SOCLE = Path(__file__).resolve().parent.parent / "oedipamaas" / "socle"

TRAITS = ["bm25_direct", "part", "prof"]
# nœud : [trait, seuil, manque_à_gauche, gauche, droite, feuille, valeur]
FORET = [
    [[0, 10.0, False, 1, 2, False, 0.0], [0, 0.0, False, 0, 0, True, -1.0], [1, 0.5, False, 3, 4, False, 0.0],
     [0, 0.0, False, 0, 0, True, 0.5], [0, 0.0, False, 0, 0, True, 2.0]],
    [[0, 0.0, False, 0, 0, True, 0.25]],                                     # un arbre réduit à une feuille
]
POIDS = {"cible": "essai", "images": 3,
         "arbres": {"traits": TRAITS, "base": -1.5, "foret": FORET, "k": 2, "seuil": 0.2, "critere": "esperance",
                    "ecart_relecture": 0.0, "f1_attendu": {"facteur": 1.0, "g": 4.0}}}


def relire(x):
    z = POIDS["arbres"]["base"]
    for arbre in FORET:
        i = 0
        while not arbre[i][5]:
            f, seuil, _, g, d, _, _ = arbre[i]
            i = g if x.get(TRAITS[f], 0.0) <= seuil else d
        z += arbre[i][6]
    return 1 / (1 + math.exp(-z))


def test_decision():
    from oedipamaas.socle.compiler_decision import compiler
    with tempfile.TemporaryDirectory() as t:
        poids = Path(t) / "poids.json"
        poids.write_text(json.dumps(POIDS))
        pl = Path(t) / "decision_poids.pl"
        assert compiler(poids, pl) == {"arbres": 2, "noeuds": 6, "traits": 3}
        janus.query_once(f"load_files('{pl}', [redefine_module(true)])")
        for f in ("notation.pl", "decision.pl"):
            janus.consult(str(SOCLE / f))
        for x in ({}, {"bm25_direct": 12.0}, {"bm25_direct": 12.0, "part": 0.9}, {"bm25_direct": 5.0, "part": 1.0}):
            traits = "[" + ",".join(f"{k}-{v}" for k, v in x.items()) + "]"
            p = janus.query_once("atom_to_term(A, _T, _), decision:p_catalogue(_T, P)", {"A": traits})["P"]
            assert abs(p - relire(x)) < 1e-12, (x, p, relire(x))
        # sélection : seuil 0,2 (11H écarté), puis les k = 2 premières espérances p × (prof + 1) : 25F23 (4,2) et
        # 86A (3,8) ; 31A (3,6) et 25F2 (3,5) ne passent pas ; la division 86 est retirée à la fin, comme dans la mesure
        cands = ("[c('25F23', 0.6, [prof-6]), c('25F2', 0.7, [prof-4]), c('31A', 0.9, [prof-3]), "
                 "c('86A', 0.95, [prof-3]), c('11H', 0.1, [prof-3])]")
        r = janus.query_once("atom_to_term(A, _C, _), decision:retenus(_C, X)", {"A": cands})["X"]
        assert r == ["25F23"], r
        # les plus spécifiques : un ancêtre d'un code retenu n'est pas répété
        cands2 = "[c('25F23', 0.9, [prof-6]), c('25F2', 0.95, [prof-5])]"
        assert janus.query_once("atom_to_term(A, _C, _), decision:retenus(_C, X)", {"A": cands2})["X"] == ["25F23"]
