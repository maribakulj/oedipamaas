"""Les tableaux de l'expérience croisée (outils/croise/tableaux.py) : la définition d'un échec, l'attribution entre
conditions, et le contrôle de complétude des causes (un échec sans cause, une cause sans échec, une cause mal formée)."""
import importlib.util
import json
import sys
from pathlib import Path

import pytest

ICI = Path(__file__).resolve().parents[1]
spec = importlib.util.spec_from_file_location("tb", ICI / "outils" / "croise" / "tableaux.py")
tb = importlib.util.module_from_spec(spec)
spec.loader.exec_module(tb)


def texte(k, genre, **sat):
    cs = {c: {"satisfaction": sat.get(c, "inconnue"), "qualification": "sans_suffisante"} for c in tb.CONDITIONS}
    return {"k": k, "genre": genre, "notation": f"N{k}", "conditions": cs}


X = [texte(1, "positif", reference_reference="etablie", lecteur_reference="inconnue", reference_compilee="etablie"),
     texte(2, "positif", lecteur_reference="etablie_sous_hypotheses", reference_compilee="sans_requete"),
     texte(3, "negatif", reference_reference="etablie_sous_hypotheses"),
     texte(4, "negatif"),
     texte(5, "variante_negation", reference_reference="etablie")]


def test_echec():
    assert [x["k"] for x in X if tb.echec(x)] == [2, 3]   # un positif non établi, un négatif établi ; pas la variante


def test_echec_sans_requete():
    assert not tb.echec(texte(6, "positif", reference_reference="sans_requete"))


def test_attribution_par_niveau():
    a = tb.attribution(X)
    assert a["lecteur"]["passages"] == {"deductive->non_etablie": ["N1"], "non_etablie->sous_hypotheses": ["N2"]}
    assert a["lecteur"]["perd_la_deduction"] == 1 and a["lecteur"]["gagne_la_deduction"] == 0
    assert a["compilateur"]["passages"] == {} and a["compilateur"]["non_evaluables"] == {"requete_absente": 1}


def test_issues_non_evaluees():
    x = texte(7, "positif", reference_reference="interrompu")
    assert tb.issue(x, "reference_reference") == "interrompue" and not tb.echec(x)
    g = dict(texte(8, "positif"), notation="31A4623(...)")
    assert tb.issue(g, "reference_reference") == "gabarit_non_instancie" and not tb.echec(g)
    assert tb.echec(g, definition="v1")                       # la v1 le comptait comme un échec
    n = texte(9, "negatif", reference_reference="etablie_sous_hypotheses")
    assert tb.echec(n) and not tb.echec(n, contestes={(9, "negatif")})
    assert tb.issue(n, "reference_reference", {(9, "negatif")}) == "conteste"
    with pytest.raises(SystemExit):
        tb.issue(texte(10, "positif", reference_reference="statut_inconnu"), "reference_reference")


def test_sous_hypotheses_est_un_echec_de_la_deduction():
    x = texte(11, "positif", reference_reference="etablie_sous_hypotheses")
    assert tb.echec(x) and not tb.echec(x, definition="v1")


def cause(k, genre, cs=("inference",)):
    return {"jeu": "j", "k": k, "genre": genre, "notation": f"N{k}", "causes": list(cs), "principale": cs[0],
            "raison": "", "statut": "decision_d_agent_provisoire"}


def lancer(tmp_path, causes, monkeypatch):
    fc, fx, fs = tmp_path / "causes.json", tmp_path / "croise.json", tmp_path / "sortie.json"
    fc.write_text(json.dumps(causes), encoding="utf-8")
    fx.write_text(json.dumps(X), encoding="utf-8")
    monkeypatch.setattr(sys, "argv", ["tableaux.py", str(fc), f"j={fx}", "--json", str(fs)])
    tb.main()
    return json.loads(fs.read_text(encoding="utf-8"))


def test_complet(tmp_path, monkeypatch):
    s = lancer(tmp_path, [cause(2, "positif", ("lexique", "inference")), cause(3, "negatif", ("erreur_reference",))],
               monkeypatch)
    assert s["j"]["causes"]["principale"] == {"lexique": 1, "erreur_reference": 1}
    assert s["j"]["causes"]["toutes"] == {"lexique": 1, "inference": 1, "erreur_reference": 1}


@pytest.mark.parametrize("causes", [
    [cause(2, "positif")],                                                     # un échec sans cause
    [cause(2, "positif"), cause(3, "negatif"), cause(4, "negatif")],           # une cause sans échec
    [cause(2, "positif"), cause(2, "positif"), cause(3, "negatif")],           # en double
    [cause(2, "positif", ("intuition",)), cause(3, "negatif")],                # une cause inconnue
])
def test_incomplet(tmp_path, monkeypatch, causes):
    with pytest.raises(SystemExit):
        lancer(tmp_path, causes, monkeypatch)
    assert not (tmp_path / "sortie.json").exists()


# --- les versions du banc (outils/graphes/version_banc.py) -------------------------------------------------------------

spec_v = importlib.util.spec_from_file_location("vb", ICI / "outils" / "graphes" / "version_banc.py")
vb = importlib.util.module_from_spec(spec_v)
spec_v.loader.exec_module(vb)

REFS = [{"k": 1, "genre": "positif", "evenements": [{"id": "v1", "predicat": "tenir", "mention": "se tient"}]}]
REQS = [{"k": 1, "suffisante": "requete('X', type(v(x), poids))", "necessaire": None}]


def erratum(**kw):
    e = {"id": "E1", "jeu": "j", "k": 1, "genre": "positif", "objet": "graphe", "operation": "predicat",
         "element": "v1", "avant": "tenir", "apres": "se tenir", "raison": "", "nature": "erreur_manifeste"}
    e.update(kw)
    return e


def test_version_applique_sans_toucher_l_ancienne():
    sorties, journal, defauts = vb.appliquer({"errata": [erratum()]}, {"j": (REFS, REQS)})
    assert not defauts and len(journal) == 1
    assert sorties["j"][0][0]["evenements"][0]["predicat"] == "se tenir"
    assert REFS[0]["evenements"][0]["predicat"] == "tenir"              # la version précédente est intacte


def test_version_refuse_un_erratum_qui_ne_s_applique_pas():
    for e in (erratum(avant="porter"), erratum(element="v9"), erratum(jeu="autre"),
              erratum(objet="requete", operation="remplacer", avant={"suffisante": "autre"}, apres={})):
        assert vb.appliquer({"errata": [e]}, {"j": (REFS, REQS)})[2]
    assert vb.appliquer({"errata": [erratum(), erratum()]}, {"j": (REFS, REQS)})[2]     # en double
