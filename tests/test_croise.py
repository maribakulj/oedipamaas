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


def test_attribution():
    a = tb.attribution(X)
    assert a["lecteur_perd"] == ["N1"] and a["lecteur_gagne"] == ["N2"]
    assert a["compilateur_sans_requete"] == 1 and a["compilateur_perd"] == [] and a["echecs_reference_reference"] == 1


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
