"""La qualification du comparateur de graphes (outils/graphes/comparer_graphes.py), sur des graphes écrits ici :
l'alignement (optimal contre glouton, mentions répétées), les référents (classes de coréférence ou mentions), les
assertions entièrement qualifiées et la sûreté (promotions), la matrice des rôles, le jugement des dérivations
(canonisées, avec leurs dépendances), et des propriétés métamorphiques (identité, renommage)."""
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


def pos(texte, m, n=0):
    i = -1
    for _ in range(n + 1):
        i = texte.find(m, i + 1)
    return [i, i + len(m)]


def faits(role_agent="e_1", role_patient="e_2", coref=True, rel=("e_3", "e_4"), pol_rel="neg"):
    f = [["texte", TEXTE], ["entite", "e_1", "nom_propre", "p1"], ["nom", "n1", "e_1", "Hercules", "p1"],
         ["entite", "e_2", "lion", "p2"], ["entite", "e_3", "hero", "p3"], ["entite", "e_4", "club", "p4"],
         ["evenement", "v_1", "strangle", "p5"], ["role", "v_1", "agent", role_agent],
         ["role", "v_1", "patient", role_patient], ["relation", "r_1", rel[0], "hold", rel[1], "p3"],
         ["polarite", "e_4", "neg"], ["polarite", "r_1", pol_rel],
         ["passage", "p1", *pos(TEXTE, "Hercules")], ["passage", "p2", *pos(TEXTE, "lion")],
         ["passage", "p3", *pos(TEXTE, "hero")], ["passage", "p4", *pos(TEXTE, "club")],
         ["passage", "p5", *pos(TEXTE, "strangles")]]
    if coref:
        f.append(["coref", "e_1", "e_3"])
    return {"k": 1, "genre": "positif", "langue": "en", "texte": TEXTE, "faits": f, "derivations": []}


def resultat(g, ref=REF, **kw):
    return cg.comparer(cg.depuis_reference(ref), cg.depuis_faits(g), **kw)


def table(g, **kw):
    return resultat(g, **kw).comptes.table()


# --- un graphe juste ; les rôles et les relations -------------------------------------------------------------------

def test_graphe_juste():
    t = table(faits())
    for cat in ("roles", "relations", "noms", "evenements"):
        s, q = t["structure:" + cat], t["qualifiee:" + cat]
        assert s["f1"] == 1.0 and q["f1"] == 1.0, (cat, s, q)
    assert t["qualificatif:negations"]["f1"] == 1.0 and t["structure:coref"]["f1"] == 1.0
    assert t["structure:entites"]["vp"] == 3          # la tête d'un nom propre n'est pas une entité du graphe


def test_roles_inverses_et_confusion():
    res = resultat(faits(role_agent="e_2", role_patient="e_1"))
    t = res.comptes.table()
    assert t["structure:roles"]["vp"] == 0 and t["structure:roles"]["ref"] == 2
    assert res.confusion[("agent", "patient")] == 1 and res.confusion[("patient", "agent")] == 1


def test_relation_orientee():
    assert table(faits(rel=("e_4", "e_3")))["structure:relations"]["vp"] == 0


# --- les référents : avec et sans les coréférences de référence ------------------------------------------------------

def test_referents_classes_ou_mentions():
    g = faits(rel=("e_1", "e_4"))                     # la relation dite d'Hercule, la référence la dit du héros
    assert table(g)["structure:relations"]["vp"] == 1                         # même référent
    assert table(g, referents="mentions")["structure:relations"]["vp"] == 0   # pas la même mention


# --- les assertions qualifiées et la sûreté -------------------------------------------------------------------------

def test_assertion_qualifiee_et_promotion():
    res = resultat(faits(pol_rel="pos"))              # « ne tient pas » lu « tient »
    t = res.comptes.table()
    assert t["structure:relations"]["vp"] == 1 and t["qualifiee:relations"]["vp"] == 0
    assert res.securite["promotion"] == 1 and res.securite["promotion_neg"] == 1


def test_promotion_d_une_hypothese():
    ref = dict(REF, entites=[dict(e, modalite="possible") if e["id"] == "e2" else e for e in REF["entites"]])
    res = cg.comparer(cg.depuis_reference(ref), cg.depuis_faits(faits()))
    assert res.securite["promotion_modalite"] == 1


# --- l'alignement --------------------------------------------------------------------------------------------------

def test_hongrois_optimal_contre_glouton():
    assert cg.hongrois([[3, 2], [2, None]]) == {0: 1, 1: 0}      # 2 + 2 > 3


def test_alignement_optimal_sur_des_mentions():
    ref = {"e1": ("man", (0, 5)), "e2": ("man", (10, 15))}
    pred = {"x": ("man", (12, 15)), "y": ("man", (2, 5))}
    assert cg.aligner(ref, pred, "optimal") == {"e1": "y", "e2": "x"}


def test_mentions_repetees_et_ordre():
    texte = "The man sees the man."
    ref = {"k": 2, "genre": "positif", "langue": "en", "texte": texte,
           "entites": [{"id": "e1", "tete": "man", "mention": "man"}, {"id": "e2", "tete": "man", "mention": "man"}],
           "evenements": [{"id": "v1", "predicat": "see", "mention": "sees", "roles": {"agent": "e1", "theme": "e2"}}]}
    lu = {"k": 2, "genre": "positif", "langue": "en", "texte": texte, "derivations": [],
          "faits": [["entite", "a", "man", "pa"], ["entite", "b", "man", "pb"], ["evenement", "v", "see", "pv"],
                    ["role", "v", "agent", "a"], ["role", "v", "theme", "b"],
                    ["passage", "pa", 4, 7], ["passage", "pb", 17, 20], ["passage", "pv", 8, 12]]}
    juste = cg.comparer(cg.depuis_reference(ref), cg.depuis_faits(lu)).comptes.table()["structure:roles"]
    assert juste["f1"] == 1.0
    inverse = cg.comparer(cg.depuis_reference(ref, ordre_inverse=True), cg.depuis_faits(lu)).comptes.table()
    assert inverse["structure:roles"]["vp"] == 0     # la mesure dépend de l'ordre des mentions répétées


def test_mot_entier():
    assert cg.occurrences("he holds; hold it", "hold") == [(10, 14)]


# --- propriétés métamorphiques ------------------------------------------------------------------------------------

def test_accord_identique():
    t = cg.comparer(cg.depuis_reference(REF), cg.depuis_reference(REF)).comptes.table()
    assert all(v["f1"] in (1.0, None) for v in t.values()), t


def test_renommage_des_identifiants():
    g = faits()
    ren = {"e_1": "z9", "e_2": "z8", "e_3": "z7", "e_4": "z6", "v_1": "w1", "r_1": "q1"}
    g2 = dict(g, faits=[[ren.get(x, x) if isinstance(x, str) else x for x in f] for f in g["faits"]])
    assert table(g) == table(g2)


# --- les dérivations ----------------------------------------------------------------------------------------------

def juger(lu):
    return cg.juger_derivations(lu, cg.depuis_reference(REF), cg.depuis_faits(lu), "optimal", "classes")


def test_e1_non_conforme_et_redondante():
    lu = faits()
    lu["derivations"] = [{"fait": ["entite", "nv_v_1_strangling", "strangling", "p5"], "regle": "e1",
                          "statut": "hypothetique", "sources": [["evenement", "v_1", "strangle", "p5"]]},
                         {"fait": ["relation", "nr_v_1_strangling_e_2", "nv_v_1_strangling", "of", "e_2", "p5"],
                          "regle": "e1", "statut": "hypothetique",
                          "sources": [["evenement", "v_1", "strangle", "p5"], ["role", "v_1", "patient", "e_2"]]}]
    j = juger(lu)["e1"]
    assert j["non_conforme"] == 2 and j["redondante"] == 2
    assert j["gain"] == 0 and j["erreur_regle"] == 0 and j["erreur_heritee"] == 0


def test_r1_gain():
    lu = faits()
    lu["faits"] = [f for f in lu["faits"] if f != ["role", "v_1", "patient", "e_2"]] + [["role", "v_1", "theme", "e_2"]]
    lu["derivations"] = [{"fait": ["role", "v_1", "patient", "e_2"], "regle": "r1", "statut": "hypothetique",
                          "sources": [["role", "v_1", "theme", "e_2"]]}]
    assert juger(lu)["r1"]["gain"] == 1


def test_erreur_de_la_regle_ou_heritee():
    lu = faits()
    lu["faits"].append(["role", "v_1", "patient", "e_4"])
    lu["derivations"] = [
        # sources justes (le lion est bien un participant) : l'agent ajouté est l'erreur de la règle
        {"fait": ["role", "v_1", "agent", "e_2"], "regle": "r2", "statut": "hypothetique",
         "sources": [["evenement", "v_1", "strangle", "p5"], ["role", "v_1", "patient", "e_2"]]},
        # source fausse (le club n'est pas un participant de l'étranglement) : l'erreur est héritée de la lecture
        {"fait": ["role", "v_1", "theme", "e_4"], "regle": "r1", "statut": "hypothetique",
         "sources": [["role", "v_1", "patient", "e_4"]]}]
    j = juger(lu)
    assert j["r2"]["erreur_regle"] == 1 and j["r1"]["erreur_heritee"] == 1


def test_dependances_suivies():
    lu = faits()
    d1 = {"fait": ["evenement", "ve_e_2_x", "roar", "p2"], "regle": "e2", "statut": "hypothetique",
          "sources": [["entite", "e_2", "lion", "p2"]]}
    d2 = {"fait": ["role", "ve_e_2_x", "agent", "e_2"], "regle": "r2", "statut": "hypothetique",
          "sources": [["evenement", "ve_e_2_x", "roar", "p2"], ["role", "ve_e_2_x", "theme", "e_2"]]}
    d3 = {"fait": ["role", "ve_e_2_x", "theme", "e_2"], "regle": "e2", "statut": "hypothetique",
          "sources": [["entite", "e_2", "lion", "p2"]]}
    chaine = cg.requises(d2, [d1, d2, d3], lu["faits"])
    assert {d["regle"] for d in chaine} == {"e2", "r2"} and len(chaine) == 3
