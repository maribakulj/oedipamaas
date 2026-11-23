"""Tests sans étiquettes : petite base Iconclass construite dans les tests (lignes CC0 d'Iconclass), descriptions
synthétiques, déterminisme."""

from __future__ import annotations

import json
import math
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
        r = [f"N {n}"] + (["K 25Fk"] if n == "25F23(LION)" else [])
        if enfants:
            r.append(f"C {enfants[0]}")
            r += [f"; {e}" for e in enfants[1:]]
        recs.append("\n".join(r) + "\n$")
    (depot / "notations.txt").write_text("\n".join(recs) + "\n")
    (depot / "txt" / "en").mkdir(parents=True)
    (depot / "kw" / "en").mkdir(parents=True)
    (depot / "txt" / "en" / "txt_en_mini.txt").write_text("".join(f"{n}|{t}\n" for n, t in TEXTES.items()))
    (depot / "kw" / "en" / "kw_en_mini.txt").write_text("".join(f"{n}|{k}\n" for n, ks in MOTS.items() for k in ks))
    (depot / "keys.txt").write_text("K 25Fk\nS 0\n; 12\n; 22\n$\n")
    (depot / "txt" / "en" / "txt_en_keys.txt").write_text("25Fk0|variant\n25Fk12|heraldic animals\n25Fk22|male animal\n")
    (depot / "kw" / "en" / "kw_en_keys.txt").write_text("25Fk12|heraldry\n25Fk22|male\n")
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


# Poids écrits pour les tests seulement (vérifier le chemin de la décision) ; les vrais poids s'apprennent.
POIDS_TEST = {"nom": 2.0, "attributs_idf": 0.3, "dcov_sujet": 3.0, "lex_sujet": 1.0, "exact_tete_autre": 3.0,
              "exact_mot_autre": 2.0, "source_ancetre": 1.0, "participants_part": 1.0, "ancetre": -3.0,
              "recit_sans_sujet": -2.0}


@pytest.fixture(scope="module")
def moteur_poids(base_mini, tmp_path_factory):
    from oedipamaas.moteur import Moteur
    f = tmp_path_factory.mktemp("poids") / "poids.json"
    f.write_text(json.dumps({"version": "test", "poids": POIDS_TEST, "moyenne": {k: 0.0 for k in POIDS_TEST},
                             "ecart": {k: 1.0 for k in POIDS_TEST}, "biais": -3.0, "k": 5, "seuil": 0.5,
                             "critere": "p"}))
    return Moteur(base_mini, f)


def code(s, n):
    return next((c for c in s["codes"] if c["code"] == n), None)


def test_noms_et_leur_contexte():
    from oedipamaas.recherche import fragments_de_noms
    assert ("jerome", 1, "honorifique") in fragments_de_noms("subject.title", "Saint Jerome in the wilderness")
    assert ("mark", 2, "reference") in fragments_de_noms("subject.title", "Last Supper (Mark 14)")
    assert fragments_de_noms("persons.who", "Saint John the Baptist") == [("john the baptist", 0, "personne")]


def test_traits_du_saint(moteur):
    s = moteur.coder(lire(jerome, "jerome"))
    j = code(s, "11H(JEROME)")
    assert j and j["traits"]["nom"] == 1.0 and j["traits"]["nom_personne"] == 1.0
    c = code(s, "11H(CATHERINE)")                      # « book » est aussi l'un de ses attributs : candidate
    assert c is None or c["traits"].get("attributs_idf", 0) < j["traits"]["attributs_idf"]


def test_identite_requise(moteur):
    """Un code à nom propre (et ses sous-rubriques) affirme une identité : sans nom ni attribut vus, il n'est pas
    proposé, même si le titre ressemble à un de ses épisodes."""
    d = {"subject": {"title": "an old man as penitent in the desert"},
         "entities": [{"id": "e1", "type": "man", "attributes": ["old"]}]}
    assert not any(c["code"].startswith("11H(JEROME)") for c in moteur.coder(lire(d, "x"))["codes"])


def test_episode_par_titre_et_source(moteur, moteur_poids):
    s = moteur.coder(lire(david, "david"))
    bon, voisin = code(s, "71H1443"), code(s, "71H1442")
    assert bon["traits"]["source_ancetre"] == 1.0
    assert bon["traits"]["dcov_sujet"] > voisin["traits"].get("dcov_sujet", 0.0)
    s = moteur_poids.coder(lire(david, "david"))
    assert code(s, "71H1443")["p_catalogue"] > code(s, "71H1442")["p_catalogue"]


def test_sans_poids_rien_n_est_retenu(moteur):
    assert not retenus(moteur.coder(lire(david, "david")))


def test_lion_objet_situe(moteur_poids):
    d = {"entities": [{"id": "e1", "type": "lion", "attributes": [], "box": [0.1, 0.2, 0.5, 0.9]}],
         "keywords": ["lion"]}
    s = moteur_poids.coder(lire(d, "lion"))
    assert "25F23(LION)" in retenus(s)
    assert "25F23(LION)" in s["objets"][0]["codes"] and s["objets"][0]["boite"] == [0.1, 0.2, 0.5, 0.9]


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


def test_ancetres_candidats_et_projection(moteur_poids):
    s = moteur_poids.coder(lire(jerome, "jerome"))
    replis = [c for c in s["codes"] if any(p["regle"] == "repli_sur_ancetre" for p in c["preuves"])]
    assert all(c["traits"].get("ancetre") == 1.0 for c in replis)
    gardes = retenus(s)
    for n in gardes:                                                   # aucun retenu n'est l'ancêtre d'un autre
        assert not any(n in moteur_poids.base.ancetres(m) for m in gardes if m != n)


def test_alias_wikidata(tmp_path):
    from oedipamaas.wikidata import alias, alias_valide
    assert not alias_valide("Jr") and not alias_valide("Jer.") and alias_valide("Hieronymus")
    f = tmp_path / "p1256.json"
    f.write_text(json.dumps({"results": {"bindings": [
        {"v": {"value": "11H(JEROME)"}, "libelles": {"value": "Hieronymus|Jr|Saint Jerome"}}]}}))
    assert alias(f) == {"11H(JEROME)": ["hieronymus", "saint jerome"]}


def test_cles(base_mini):
    """Une clé d'Iconclass évoquée par la description donne le code à clé, avec les traits de la clé (option)."""
    from oedipamaas.moteur import Moteur
    moteur = Moteur(base_mini, cles=True)
    assert not any("(+" in c["code"] for c in Moteur(base_mini).coder(lire(
        {"entities": [{"id": "e1", "type": "lion", "attributes": ["heraldic"]}]}, "x"))["codes"])
    cles = json.loads((base_mini / "cles.json").read_text())
    assert cles["25Fk"]["12"]["texte"] == "heraldic animals" and "heraldry" in cles["25Fk"]["12"]["mots"]
    d = {"entities": [{"id": "e1", "type": "lion", "attributes": ["heraldic"]}], "keywords": ["lion", "heraldry"]}
    s = moteur.coder(lire(d, "lion"))
    c = code(s, "25F23(LION)(+12)")
    assert c and c["traits"]["cle"] == 1.0 and c["traits"]["cle_exacte"] == 1.0
    assert "heraldic animals" in c["iconclass"]
    assert moteur.base.ancetres("25F23(LION)(+12)")[0] == "25F23(LION)"


def test_decision_par_arbres(base_mini, tmp_path):
    """Arbres exportés (format du noyau de calibration) : une souche sur « dcov_sujet » ; le bon épisode passe."""
    from oedipamaas.moteur import Moteur
    traits = ["dcov_sujet"]
    souche = [[0, 0.5, True, 1, 2, False, 0.0], [0, 0.0, True, 0, 0, True, -2.0], [0, 0.0, True, 0, 0, True, 2.0]]
    poids = {"version": "test", "poids": {}, "moyenne": {}, "ecart": {}, "biais": -9.0, "k": 5, "seuil": 0.5,
             "critere": "p", "arbres": {"traits": traits, "base": 0.0, "foret": [souche], "k": 5, "seuil": 0.5,
                                        "critere": "p"}}
    f = tmp_path / "poids.json"
    f.write_text(json.dumps(poids))
    s = Moteur(base_mini, f, decision="arbres").coder(lire(david, "david"))
    c = code(s, "71H1443")
    assert abs(c["p_catalogue"] - 1 / (1 + math.exp(-2.0))) < 1e-3 and c["statut"] == "retenu"
    assert not retenus(Moteur(base_mini, f).coder(lire(david, "david")))   # logistique au biais -9 : rien


def test_seconde_probabilite(base_mini, tmp_path):
    """Un bloc « exacte » dans les poids donne p_exact à chaque code, sans changer la décision."""
    from oedipamaas.moteur import Moteur
    exacte = {"poids": {"dcov_sujet": 1.0}, "moyenne": {"dcov_sujet": 0.0}, "ecart": {"dcov_sujet": 1.0}, "biais": 0.0}
    poids = {"version": "test", "poids": POIDS_TEST, "moyenne": {k: 0.0 for k in POIDS_TEST},
             "ecart": {k: 1.0 for k in POIDS_TEST}, "biais": -3.0, "k": 5, "seuil": 0.5, "critere": "p",
             "exacte": exacte}
    f = tmp_path / "poids.json"
    f.write_text(json.dumps(poids))
    s = Moteur(base_mini, f).coder(lire(david, "david"))
    c = code(s, "71H1443")
    assert 0.5 < c["p_exact"] < 1.0
    sans = {k: v for k, v in poids.items() if k != "exacte"}
    f.write_text(json.dumps(sans))
    s2 = Moteur(base_mini, f).coder(lire(david, "david"))
    assert [x["code"] for x in s2["codes"] if x["statut"] == "retenu"] == retenus(s)


def test_structure_image(base_mini):
    """Option structure de l'image : l'entité située qui appuie un code (taille relative, centre, plan) et la relation
    dont les deux bouts et le prédicat sont dans le libellé ; sans l'option, aucun de ces traits."""
    from oedipamaas.moteur import Moteur
    d = {"subject": {"title": "David beheading Goliath"},
         "entities": [{"id": "e1", "type": "David", "attributes": ["sling"], "plane": "foreground",
                       "box": [0.25, 0.25, 0.75, 0.75]},
                      {"id": "e2", "type": "Goliath", "attributes": ["giant"], "plane": "background",
                       "box": [0.0, 0.0, 0.2, 0.2]}],
         "relations": [["e1", "beheads", "e2"], ["e1", "left_of", "e2"]]}
    s = Moteur(base_mini, structure_image=True).coder(lire(d, "david-situe"))
    t = code(s, "71H1443")["traits"]
    assert t["saillance_aire"] == 1.0 and t["saillance_centre"] == 1.0 and t["plan_foreground"] == 1.0
    assert t["entites_appui"] == 2.0 and t["relation_bouts"] == 2.0
    assert t["relation_predicat"] == 1.0 and t["relation_complete"] == 1.0 and t["relations_nb"] == 2.0
    sans = Moteur(base_mini).coder(lire(d, "david-situe"))
    noms = {k for c in sans["codes"] for k in c["traits"]}
    assert not noms & {"saillance_aire", "entites_appui", "relation_bouts", "relations_nb", "plan_foreground"}


class FauxSens:
    """Index sémantique de test : toutes les notations permises par le masque à 0,6, dans l'ordre des ids."""

    def __init__(self, ids):
        self.ids = ids
        self.modele_nom, self.revision = "faux", "0"

    def encoder(self, textes):
        return None

    def voisins(self, texte_mention, masque, top=10):
        return [(n, 0.6) for n, ok in zip(self.ids, masque) if ok][:top]


def test_noms_libres(base_mini):
    """Un nom écrit inconnu d'Iconclass (« Bavo ») propose le parent d'un gabarit « with NAME » et le gabarit
    instancié ; un nom connu (« Jerome ») et un mot commun en tête de mention (« Lion ») ne passent pas ; sans l'option,
    rien."""
    from oedipamaas.moteur import Moteur
    m = Moteur(base_mini, noms_libres=True)
    m.sem = FauxSens(sorted(m.base.n))
    d = {"subject": {"title": "Saint Bavo with a falcon"}, "persons": [{"who": "Jerome"}],
         "keywords": ["Lion"]}
    s = m.coder(lire(d, "bavo"))
    c = code(s, "11H(...)".replace("(...)", "(BAVO)"))
    assert c["traits"]["gabarit"] == 1.0 and c["traits"]["nom_ecrit_sim"] == 0.6
    assert c["traits"]["nom_ecrit_champ_sujet"] == 1.0
    p = code(s, "11H")
    assert p["traits"]["nom_ecrit"] == 1.0
    noms = {x["code"] for x in s["codes"]}
    assert not {n for n in noms if n.endswith("(JEROME)") and n != "11H(JEROME)"}
    assert not any(n.endswith("(LION)") and n != "25F23(LION)" for n in noms)
    m.noms_libres = False
    assert not any("nom_ecrit" in x["traits"] for x in m.coder(lire(d, "bavo"))["codes"])


def test_selection_f1(base_mini, tmp_path):
    """Sélection par F1 attendu : ni k ni seuil ; le bon épisode est retenu, ses ancêtres sont implicites ; un g très
    grand (vérité attendue énorme) fait retenir davantage qu'un g petit ; sans g appris, refus."""
    from oedipamaas.moteur import Moteur
    poids = {"version": "test", "poids": POIDS_TEST, "moyenne": {k: 0.0 for k in POIDS_TEST},
             "ecart": {k: 1.0 for k in POIDS_TEST}, "biais": -3.0, "k": 1, "seuil": 0.99, "critere": "p",
             "f1_attendu": {"facteur": 1.0, "g": 4.0}}
    f = tmp_path / "poids.json"
    f.write_text(json.dumps(poids))
    s = Moteur(base_mini, f, selection="f1").coder(lire(david, "david"))
    assert "71H1443" in retenus(s), retenus(s)
    assert s["versions"]["poids"].endswith(" f1")
    poids["f1_attendu"]["g"] = 40.0
    f.write_text(json.dumps(poids))
    large = Moteur(base_mini, f, selection="f1").coder(lire(david, "david"))
    assert len(retenus(large)) >= len(retenus(s))
    del poids["f1_attendu"]
    f.write_text(json.dumps(poids))
    with pytest.raises(ValueError):
        Moteur(base_mini, f, selection="f1")


def test_cli_expliquer(base_mini, tmp_path, capsys):
    """Contrat de la commande « expliquer » : elle lit la sortie de Moteur.coder telle qu'elle est (sans score ni
    contribution) et n'échoue pas."""
    from oedipamaas.cli import main
    d = tmp_path / "jerome.json"
    d.write_text(json.dumps(jerome), encoding="utf-8")
    main(["expliquer", str(base_mini), str(d), "--top", "3"])
    sortie = capsys.readouterr().out
    codes = [x.split()[0] for x in sortie.splitlines() if x and not x.startswith(" ")]
    assert codes and len(codes) <= 3, sortie
    assert all("sans poids" in x for x in sortie.splitlines() if x and not x.startswith(" ")), sortie
