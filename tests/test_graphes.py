"""Le comparateur de graphes du banc de référence (outils/graphes/comparer_graphes.py), sur des graphes écrits ici :
l'alignement par la tête et par la portée, les rôles jugés par référent (classes de coréférence), l'orientation des
relations, les négations, l'accord de deux annotations identiques, le jugement des dérivations."""
import importlib.util
from pathlib import Path

ICI = Path(__file__).resolve().parents[1]
spec = importlib.util.spec_from_file_location("cg", ICI / "outils" / "graphes" / "comparer_graphes.py")
cg = importlib.util.module_from_spec(spec)
spec.loader.exec_module(cg)

TEXTE = "Hercules strangles the lion; the hero does not hold a club."
REF = {"k": 1, "genre": "positif", "langue": "en", "texte": TEXTE,
       "entites": [{"id": "e1", "tete": "hercules", "mention": "Hercules", "noms": ["Hercules"]},
                   {"id": "e2", "tete": "lion", "mention": "the lion"},
                   {"id": "e3", "tete": "hero", "mention": "the hero"},
                   {"id": "e4", "tete": "club", "mention": "a club", "polarite": "neg"}],
       "evenements": [{"id": "v1", "predicat": "strangle", "mention": "strangles",
                       "roles": {"agent": "e1", "patient": "e2"}}],
       "relations": [{"id": "r1", "sujet": "e3", "relation": "hold", "objet": "e4", "polarite": "neg"}],
       "coref": [["e1", "e3"]]}


def pos(m, n=0):
    i = -1
    for _ in range(n + 1):
        i = TEXTE.find(m, i + 1)
    return [i, i + len(m)]


def faits(role_agent="e_1", role_patient="e_2", coref=True, rel=("e_3", "e_4")):
    f = [["texte", TEXTE], ["entite", "e_1", "nom_propre", "p1"], ["nom", "n1", "e_1", "Hercules", "p1"],
         ["entite", "e_2", "lion", "p2"], ["entite", "e_3", "hero", "p3"], ["entite", "e_4", "club", "p4"],
         ["evenement", "v_1", "strangle", "p5"], ["role", "v_1", "agent", role_agent],
         ["role", "v_1", "patient", role_patient], ["relation", "r_1", rel[0], "hold", rel[1], "p3"],
         ["polarite", "e_4", "neg"], ["polarite", "r_1", "neg"],
         ["passage", "p1", *pos("Hercules")], ["passage", "p2", *pos("lion")], ["passage", "p3", *pos("hero")],
         ["passage", "p4", *pos("club")], ["passage", "p5", *pos("strangles")]]
    if coref:
        f.append(["coref", "e_1", "e_3"])
    return {"k": 1, "genre": "positif", "langue": "en", "texte": TEXTE, "faits": f, "derivations": []}


def table(g):
    return cg.comparer(cg.depuis_reference(REF), cg.depuis_faits(g)).table()


def test_graphe_juste():
    t = table(faits())
    for cat in ("roles", "relations", "noms", "negations", "coref", "evenements"):
        assert t[cat]["rappel"] == 1.0 and t[cat]["precision"] == 1.0, (cat, t[cat])
    # la tête d'un nom propre n'est pas comptée comme une entité du graphe (référence : « hercules »)
    assert t["entites"]["vp"] == 3


def test_roles_inverses():
    t = table(faits(role_agent="e_2", role_patient="e_1"))
    assert t["roles"]["vp"] == 0 and t["roles"]["ref"] == 2
    assert t["roles_macro"]["vp"] == 0


def test_relation_jugee_par_referent():
    # la relation est dite du héros ; sans la coréférence, son sujet n'est plus Hercule pour la référence ? Si : le
    # héros est aligné sur sa propre mention, de la classe d'Hercule dans la référence
    t = table(faits(coref=False))
    assert t["relations"]["vp"] == 1 and t["coref"]["vp"] == 0 and t["coref"]["ref"] == 1


def test_relation_orientee():
    t = table(faits(rel=("e_4", "e_3")))
    assert t["relations"]["vp"] == 0


def test_accord_identique():
    r = cg.depuis_reference(REF)
    t = cg.comparer(r, cg.depuis_reference(REF)).table()
    assert all(v["f1"] in (1.0, None) for v in t.values()), t


def test_derivation_jugee():
    g = cg.depuis_faits(faits(role_patient="e_9"))           # le patient manque (e_9 n'existe pas)
    base = cg.comparer(cg.depuis_reference(REF), g).table()["roles"]["vp"]
    h = cg.ajouter_faits(g, [["role", "v_1", "patient", "e_2"]])
    assert cg.comparer(cg.depuis_reference(REF), h).table()["roles"]["vp"] == base + 1
