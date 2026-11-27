"""Les outils des bancs de la phase 1 (docs/BANCS_PHASE1.md) : la répartition versée est celle que l'outil recalcule,
elle est une partition, et le validateur refuse un cas de développement qui emploie le côté de qualification."""
import copy, hashlib, json, pathlib, sys

R = pathlib.Path(__file__).resolve().parent.parent
sys.path.insert(0, str(R / "outils" / "bancs"))
import repartir, valider_cas  # noqa: E402

INV = json.loads((R / "bancs/phase1/inventaire.json").read_text())
REP = json.loads((R / "bancs/phase1/repartition.json").read_text())


def test_repartition_versee_recalculee():
    brut = (R / "bancs/phase1/inventaire.json").read_bytes()
    assert REP["inventaire_sha256"] == hashlib.sha256(brut).hexdigest()
    r = repartir.repartir(INV, REP["graine"])
    assert r["familles_lexicales"] == REP["familles_lexicales"]
    assert r["constructions"] == REP["constructions"]


def test_partition():
    lex = REP["familles_lexicales"]
    assert not set(lex["developpement"]) & set(lex["qualification"])
    assert sorted(lex["developpement"] + lex["qualification"]) == sorted(INV["familles_lexicales"]["liste"])
    for f, ps in INV["familles"].items():
        for p, cs in ps["phenomenes"].items():
            x = REP["constructions"][f][p]
            assert sorted(x["developpement"] + x["qualification"]) == sorted(cs)
            assert not set(x["developpement"]) & set(x["qualification"])
            if len(cs) >= 2:
                assert x["developpement"] and x["qualification"]


def test_vue_de_developpement():
    v = json.loads((R / "bancs/phase1/developpement.json").read_text())
    assert v["familles_lexicales"] == REP["familles_lexicales"]["developpement"]
    for f, x in v["familles"].items():
        for p, cs in x["phenomenes"].items():
            assert cs == REP["constructions"][f][p]["developpement"]


def cas_type():
    f, ps = "evenements_etats", REP["constructions"]["evenements_etats"]
    p = next(p for p, x in ps.items() if x["developpement"])
    return {"id": "ee-t1", "famille": f, "phenomenes": [{"famille": f, "phenomene": p, "construction": ps[p]["developpement"][0]}],
            "pivot": {"lemme": "sleep", "cle_de_sens": "sleep%2:29:00::", "famille_lexicale": REP["familles_lexicales"]["developpement"][0]},
            "langue": "en", "sorte": "positif", "description": "A man sleeps.", "definition": "sleeping man",
            "statut_attendu": "etablie", "hypotheses_attendues": [], "connaissances_supposees": [],
            "operations_requises": ["lecture"], "extensions_requises": ["aucune"], "justification": "—",
            "variantes": [{"variation": "traduction", "description": "Un homme dort.", "sorte": "positif",
                           "statut_attendu": "etablie", "hypotheses_attendues": []}]}


def test_validateur_accepte_et_refuse():
    c = cas_type()
    assert valider_cas.controler([c], INV, REP, "developpement") == []
    # une construction de qualification, dans un cas de développement
    q = copy.deepcopy(c)
    p = next(p for p, x in REP["constructions"]["evenements_etats"].items() if x["qualification"])
    q["phenomenes"][0] = {"famille": "evenements_etats", "phenomene": p,
                          "construction": REP["constructions"]["evenements_etats"][p]["qualification"][0]}
    assert any("qualification" in e for e in valider_cas.controler([q], INV, REP, "developpement"))
    # une famille lexicale de qualification
    q = copy.deepcopy(c)
    q["pivot"]["famille_lexicale"] = REP["familles_lexicales"]["qualification"][0]
    assert any("qualification" in e for e in valider_cas.controler([q], INV, REP, "developpement"))
    # le même cas n'est pas un cas de qualification
    assert any("aucune construction" in e for e in valider_cas.controler([c], INV, REP, "qualification"))
    # des hypothèses sans etablie_sous_hypotheses
    q = copy.deepcopy(c)
    q["hypotheses_attendues"] = ["sens"]
    assert valider_cas.controler([q], INV, REP, "developpement")
    # une clé de sens d'un autre lemme
    q = copy.deepcopy(c)
    q["pivot"]["cle_de_sens"] = "dream%2:29:00::"
    assert valider_cas.controler([q], INV, REP, "developpement")
