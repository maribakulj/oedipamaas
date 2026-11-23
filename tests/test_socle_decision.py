"""Décision compilée en Prolog (socle 1.0, § 9) : une petite forêt écrite à la main, au format du noyau de
calibration ; les probabilités de Prolog égalent la relecture Python (règle du noyau : à gauche si ≤ seuil), et la
sélection écarte la division 86, suit le réglage (k, seuil, critère), puis garde les plus spécifiques (au sens de l'arbre d'Iconclass, sur un
petit Iconclass factice)."""
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


# un petit Iconclass : les ancêtres se lisent dans l'arbre (11H(JEROME) est enfant du gabarit 11H(...), qui n'en est
# pas un préfixe)
NOTATIONS = "".join(f"N {n}\n" + "".join(f"C {c}\n" for c in cs) + "$\n" for n, cs in [
    ("1", ["11"]), ("11", ["11H"]), ("11H", ["11H(...)"]), ("11H(...)", ["11H(JEROME)"]), ("11H(JEROME)", []),
    ("2", ["25"]), ("25", ["25F"]), ("25F", ["25F2"]), ("25F2", ["25F23"]), ("25F23", []),
    ("3", ["31"]), ("31", ["31A"]), ("31A", []), ("8", ["86"]), ("86", ["86A"]), ("86A", [])])


@pytest.fixture(scope="module")
def petit_iconclass():
    from oedipamaas.socle.compiler_iconclass import compiler
    with tempfile.TemporaryDirectory() as t:
        d = Path(t) / "depot"
        (d / "txt" / "en").mkdir(parents=True)
        (d / "kw" / "en").mkdir(parents=True)
        (d / "notations.txt").write_text(NOTATIONS, encoding="utf-8")
        (d / "keys.txt").write_text("", encoding="utf-8")
        (d / "COMMIT").write_text("essai\n")
        compiler(d, Path(t) / "base")
        janus.query_once(f"load_files('{Path(t) / 'base' / 'iconclass.pl'}', [redefine_module(true)])")
        yield


def relire(x):
    z = POIDS["arbres"]["base"]
    for arbre in FORET:
        i = 0
        while not arbre[i][5]:
            f, seuil, _, g, d, _, _ = arbre[i]
            i = g if x.get(TRAITS[f], 0.0) <= seuil else d
        z += arbre[i][6]
    return 1 / (1 + math.exp(-z))


def test_decision(petit_iconclass):
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
        # sélection : seuil 0,2 (11H écarté), division 86 écartée avant la sélection (86A ne prend pas de place),
        # puis les k = 2 premières espérances p × (prof + 1) : 25F23 (4,2) et 31A (3,6) ; 25F2 (3,5) ne passe pas
        cands = ("[c('25F23', 0.6, [prof-6]), c('25F2', 0.7, [prof-4]), c('31A', 0.9, [prof-3]), "
                 "c('86A', 0.95, [prof-3]), c('11H', 0.1, [prof-3])]")
        r = janus.query_once("atom_to_term(A, _C, _), decision:retenus(_C, X)", {"A": cands})["X"]
        assert r == ["25F23", "31A"], r
        # les plus spécifiques : un ancêtre d'un code retenu n'est pas répété
        cands2 = "[c('25F23', 0.9, [prof-6]), c('25F2', 0.95, [prof-5])]"
        assert janus.query_once("atom_to_term(A, _C, _), decision:retenus(_C, X)", {"A": cands2})["X"] == ["25F23"]
        # au sens de l'arbre, pas des préfixes : le gabarit 11H(...) est un ancêtre de 11H(JEROME)
        cands3 = "[c('11H(JEROME)', 0.9, [prof-5]), c('11H(...)', 0.95, [prof-4])]"
        assert janus.query_once("atom_to_term(A, _C, _), decision:retenus(_C, X)",
                                {"A": cands3})["X"] == ["11H(JEROME)"]


# --- Deux étages : référence Python, celle du noyau de calibration (contexte_image) et de la mesure (ancestors) ------

import re  # noqa: E402

PART = re.compile(r"\d\d?[A-Z]{0,2}\d*(?:\([^)]*\)\d*)*")
TOKEN = re.compile(r"\([^)]*\)|[A-Z]{1,2}|\d")


def ancestors(code):
    out = {code}
    if all(PART.fullmatch(p) for p in code.split(":")):
        for p in code.split(":"):
            cur = ""
            for t in TOKEN.findall(p):
                cur += t
                out.add(cur)
    return out


def relire_foret(base, foret, noms, x):
    z = base
    for arbre in foret:
        i = 0
        while not arbre[i][5]:
            f, seuil, _, g, d, _, _ = arbre[i]
            i = g if x.get(noms[f], 0.0) <= seuil else d
        z += arbre[i][6]
    return 1 / (1 + math.exp(-max(-30.0, min(30.0, z))))


def contexte(p):
    """{code: {nom: valeur}} : la place de chaque candidat dans l'image (modele_calibration.contexte_image)."""
    ordre = sorted(p, key=lambda c: (-p[c], c))
    pmax = p[ordre[0]]
    desc = {}
    for c in p:
        for a in ancestors(c):
            if a != c and a in p and p[c] > desc.get(a, 0.0):
                desc[a] = p[c]
    devant, out = {}, {}
    for r, c in enumerate(ordre, 1):
        anc = [a for a in ancestors(c) if a != c and a in p and ":" not in a]
        proche = max(anc, key=lambda a: (len(ancestors(a)), a), default=None)
        out[c] = {"inv_rang_image": 1.0 / r, "p_sur_max_image": p[c] / pmax if pmax > 0 else 0.0,
                  "max_descendant": desc.get(c, 0.0), "p_ancetre_proche": p[proche] if proche else 0.0,
                  "devant_dans_chapitre": devant.get(c[:1], 0)}
        devant[c[:1]] = devant.get(c[:1], 0) + 1
    return out


CONTEXTE = ["inv_rang_image", "p_sur_max_image", "max_descendant", "p_ancetre_proche", "devant_dans_chapitre"]
ETAGE2 = [  # sur traits + contexte : indices 3 = inv_rang_image, 5 = max_descendant, 6 = p_ancetre_proche
    [[3, 0.6, False, 1, 2, False, 0.0], [5, 0.5, False, 3, 4, False, 0.0], [0, 0.0, False, 0, 0, True, 1.5],
     [0, 0.0, False, 0, 0, True, -0.5], [6, 0.4, False, 5, 6, False, 0.0], [0, 0.0, False, 0, 0, True, 0.2],
     [0, 0.0, False, 0, 0, True, 0.9]],
]


def test_deux_etages():
    from oedipamaas.socle.compiler_decision import compiler
    poids = dict(POIDS, deux_etages={"traits": TRAITS, "contexte": CONTEXTE, "etage1": {"base": -1.0, "foret": FORET},
                                     "etage2": {"base": -0.5, "foret": ETAGE2}, "k": 3, "seuil": 0.1, "critere": "p",
                                     "ecart_relecture": 0.0, "f1_attendu": {"facteur": 1.0, "g": 3.0}})
    cands = {"25F23": {"bm25_direct": 12.0, "part": 0.9, "prof": 5}, "25F2": {"bm25_direct": 11.0, "prof": 4},
             "25F23(LION)": {"bm25_direct": 3.0, "part": 1.0, "prof": 6}, "31A": {"part": 0.2, "prof": 3},
             "61B(+53)": {"bm25_direct": 15.0, "part": 0.7, "prof": 4}, "61B": {"bm25_direct": 1.0, "prof": 3}}
    with tempfile.TemporaryDirectory() as t:
        pj = Path(t) / "poids.json"
        pj.write_text(json.dumps(poids))
        pl = Path(t) / "decision_poids.pl"
        assert compiler(pj, pl)["deux_etages"] == {1: 2, 2: 1}
        janus.query_once(f"load_files('{pl}', [redefine_module(true)])")
        for f in ("notation.pl", "decision.pl"):
            janus.consult(str(SOCLE / f))
        # préfixes par jetons, comme la mesure (la clé est un jeton ; un nom aussi)
        for c in list(cands) + ["11H(JEROME)1", "47H411(+456(...))", "25FF23"]:
            assert set(janus.query_once("decision:prefixes(N, X)", {"N": c})["X"]) == ancestors(c), c
        p1 = {c: relire_foret(-1.0, FORET, TRAITS, x) for c, x in cands.items()}
        ctx = contexte(p1)
        attendu = {c: relire_foret(-0.5, ETAGE2, TRAITS + CONTEXTE, {**x, **ctx[c]}) for c, x in cands.items()}
        terme = "[" + ",".join(f"c({c!r}, [" + ",".join(f"{k}-{v!r}" for k, v in x.items()) + "])"
                               for c, x in cands.items()) + "]"
        r = janus.query_once("atom_to_term(A, _C, _), decision:p_image(_C, _Ps), findall([_N, _P], member(_N-_P, _Ps), X)",
                             {"A": terme})["X"]
        obtenu = dict(r)
        assert set(obtenu) == set(cands)
        for c in cands:
            assert abs(obtenu[c] - attendu[c]) < 1e-12, (c, obtenu[c], attendu[c])
        # le réglage est celui des deux étages
        assert janus.query_once("decision_poids:reglage(K, S, C)")["K"] == 3
