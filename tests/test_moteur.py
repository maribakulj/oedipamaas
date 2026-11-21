"""Tests sans étiquettes : petite base Iconclass construite dans les tests (lignes CC0 d'Iconclass), descriptions
synthétiques, déterminisme."""

from __future__ import annotations

import json
import sys
from pathlib import Path

import pytest

sys.path.insert(0, str(Path(__file__).parent))
from descriptions_synthetiques import david, jerome  # noqa: E402

from oedipamaas import references, texte  # noqa: E402
from oedipamaas.base import attributs, compiler, nom_propre  # noqa: E402
from oedipamaas.lecture import lire  # noqa: E402

NOTATIONS = {
    "1": ["11"], "11": ["11H"], "11H": ["11H(...)"], "11H(...)": ["11H(JEROME)", "11H(CATHERINE)"],
    "11H(JEROME)": ["11H(JEROME)3"], "11H(JEROME)3": ["11H(JEROME)36"], "11H(JEROME)36": [], "11H(CATHERINE)": [],
    "2": ["25"], "25": ["25F"], "25F": ["25F2"], "25F2": ["25F23"], "25F23": ["25F23(LION)"], "25F23(LION)": [],
    "3": ["31"], "31": ["31F"], "31F": ["31F1"], "31F1": ["31F11"], "31F11": [],
    "7": ["71"], "71": ["71H"], "71H": ["71H1"], "71H1": ["71H14"], "71H14": ["71H144"],
    "71H144": ["71H1442", "71H1443"], "71H1442": [], "71H1443": [],
}
TEXTES = {
    "1": "Religion and Magic", "11": "Christian religion", "11H": "saints", "11H(...)": "male saints (with NAME)",
    "11H(JEROME)": "the monk and hermit Jerome (Hieronymus); possible attributes: book, cardinal's hat, crucifix, "
                   "hour-glass, lion, skull, stone",
    "11H(JEROME)3": "personal devotion of St. Jerome",
    "11H(JEROME)36": "St. Jerome as penitent in the desert, half naked, kneeling before a crucifix and holding a stone "
                     "in his hand to beat his breast; a skull (and other 'Vanitas' symbols), sometimes a scorpion and a "
                     "snake beside him",
    "11H(CATHERINE)": "the virgin martyr Catherine of Alexandria; possible attributes: book, crown, dove, palm-branch, "
                      "ring, sword, wheel",
    "2": "Nature", "25": "earth, world as celestial body", "25F": "animals", "25F2": "mammals",
    "25F23": "beasts of prey, predatory animals", "25F23(LION)": "beasts of prey, predatory animals: lion",
    "3": "Human Being, Man in General", "31": "man in a general biological sense", "31F": "death",
    "31F1": "symbols of death", "31F11": "death's head, skull (symbol of Death)",
    "7": "Bible", "71": "Old Testament", "71H": "story of David", "71H1": "David's youth",
    "71H14": "story of David and Goliath (1 Samuel 17)", "71H144": "David fighting Goliath",
    "71H1442": "David slings a stone at Goliath's forehead", "71H1443": "David beheads Goliath with a sword",
}
MOTS = {"11H(JEROME)": ["Jerome (St.)", "lion", "skull", "book"], "25F23(LION)": ["lion"],
        "31F11": ["skull"], "71H1443": ["beheading", "sword"], "71H1442": ["sling", "stone"]}


@pytest.fixture(scope="module")
def base_mini(tmp_path_factory):
    depot = tmp_path_factory.mktemp("iconclass")
    recs = []
    for n, enfants in NOTATIONS.items():
        r = [f"N {n}"]
        if enfants:
            r.append(f"C {enfants[0]}")
            r += [f"; {e}" for e in enfants[1:]]
        recs.append("\n".join(r) + "\n$")
    (depot / "notations.txt").write_text("\n".join(recs) + "\n")
    (depot / "txt" / "en").mkdir(parents=True)
    (depot / "kw" / "en").mkdir(parents=True)
    (depot / "txt" / "en" / "txt_en_mini.txt").write_text("".join(f"{n}|{t}\n" for n, t in TEXTES.items()))
    (depot / "kw" / "en" / "kw_en_mini.txt").write_text("".join(f"{n}|{k}\n" for n, ks in MOTS.items() for k in ks))
    sortie = tmp_path_factory.mktemp("base")
    compiler(depot, sortie)
    return sortie


@pytest.fixture(scope="module")
def moteur(base_mini):
    from oedipamaas.moteur import Moteur
    return Moteur(base_mini)


def retenus(sortie):
    return [c["code"] for c in sortie["codes"] if c["statut"] == "retenu"]


def test_texte():
    assert texte.norme("the Leaves") == "leaf"
    assert texte.racine("beheading") == texte.racine("beheads") == "behead"
    assert texte.jetons("Saint Jerome's lion") == ["saint", "jerome", "lion"]


def test_references():
    assert references.analyser("1 Samuel 17") == [("1 samuel", 17, None, None)]
    assert references.analyser("(OVID, Metamorphoses II:12-30)") == [("ovide metamorphoses", 2, 12, 30)]
    assert references.analyser("Golden Legend") == []
    assert references.recouvre(("genesis", 22, 1, 19), ("genesis", 22, 9, 9))
    assert not references.recouvre(("genesis", 22, 1, 5), ("genesis", 22, 9, 12))


def test_base(base_mini):
    lignes = [json.loads(x) for x in (base_mini / "notations.jsonl").read_text().splitlines()]
    par_n = {r["n"]: r for r in lignes}
    assert par_n["11H(JEROME)"]["propre"] and par_n["11H(JEROME)"]["nom"] == "jerome"
    assert not par_n["25F23(LION)"]["propre"]
    assert par_n["71H14"]["refs"] == [["1 samuel", 17, None, None]]
    assert nom_propre("11H(...)") is None
    assert "cardinal's hat" in attributs(TEXTES["11H(JEROME)"])


def test_lecture_v1_et_v2():
    d2 = lire(david, "david")
    assert d2.format == "v2" and d2.sujet_type == "biblical narrative"
    assert any(m.champ == "subject.source" and m.texte == "1 Samuel 17" for m in d2.mentions)
    d1 = lire({"entities": [{"id": "e1", "type": "lion", "attributes": []}], "relations": [], "scene": ["desert"],
               "identification": {"guess": "Saint Jerome", "based_on": ["lion"], "confidence": 0.7}}, "v1")
    assert d1.format == "v1" and any(m.champ == "subject.title" for m in d1.mentions)


def test_noms_dans_un_titre():
    from oedipamaas.recherche import fragments_de_noms
    assert fragments_de_noms("subject.title", "Saint Jerome in the wilderness") == [("jerome in the wilderness", False)]
    assert fragments_de_noms("subject.title", "Last Supper (Mark 14), engraving by Philips Galle") == []
    assert fragments_de_noms("persons.who", "Saint John the Baptist") == [("john the baptist", True)]


def test_saint_nomme_et_appuye(moteur):
    s = moteur.coder(lire(jerome, "jerome"))
    codes = retenus(s)
    assert any(c.startswith("11H(JEROME)") for c in codes)
    assert "11H(CATHERINE)" not in [c["code"] for c in s["codes"]]   # aucune devinette quand un saint est nommé


def test_nom_sans_appui_bloque(moteur):
    d = {"subject": {"title": "a man", "type": "portrait"}, "persons": [{"who": "Jerome", "recognised_by": []}],
         "entities": [{"id": "e1", "type": "man", "attributes": []}]}
    assert not any(c["code"].startswith("11H(JEROME)") for c in moteur.coder(lire(d, "x"))["codes"])


def test_episode_par_titre_et_source(moteur):
    s = moteur.coder(lire(david, "david"))
    codes = retenus(s)
    # Dans la petite base, les deux épisodes frères sont presque à égalité : repli sur le parent permis, jamais le
    # mauvais épisode.
    assert ("71H1443" in codes or "71H144" in codes) and "71H1442" not in codes


def test_lion_objet_situe(moteur):
    d = {"entities": [{"id": "e1", "type": "lion", "attributes": [], "box": [0.1, 0.2, 0.5, 0.9]}],
         "keywords": ["lion"]}
    s = moteur.coder(lire(d, "lion"))
    assert "25F23(LION)" in retenus(s)
    assert s["objets"][0]["codes"] == ["25F23(LION)"] and s["objets"][0]["boite"] == [0.1, 0.2, 0.5, 0.9]


def test_determinisme(moteur):
    a = json.dumps(moteur.coder(lire(jerome, "j")), sort_keys=True)
    b = json.dumps(moteur.coder(lire(jerome, "j")), sort_keys=True)
    assert a == b


def test_description_illisible(moteur, tmp_path):
    from oedipamaas.lecture import lire_fichier
    f = tmp_path / "mauvaise.json"
    f.write_text(json.dumps({"brut": "pas de json ici"}))
    s = moteur.coder(lire_fichier(f))
    assert "erreur" in s and s["codes"] == []
