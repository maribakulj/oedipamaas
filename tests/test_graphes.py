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
    # non évaluée, jamais « redondante » ni juste : le contenu canonisé est déjà lu, la forme propre d'E1 n'est pas jugée
    assert j["non_conforme"] == 2 and j["non_evaluee"] == 2 and j["redondante"] == 0
    assert j["non_evaluee_sources_justes"] == 2
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


def test_gain_et_erreur_d_une_meme_transformation():
    lu = faits()
    lu["faits"] = [f for f in lu["faits"] if f != ["role", "v_1", "agent", "e_1"]]
    d1 = {"fait": ["role", "v_1", "agent", "e_1"], "regle": "r2", "statut": "hypothetique",
          "sources": [["evenement", "v_1", "strangle", "p5"], ["role", "v_1", "patient", "e_2"]]}
    # d2 dépend de d1 (non lue) : sa chaîne ajoute l'agent juste et le thème faux
    d2 = {"fait": ["role", "v_1", "theme", "e_4"], "regle": "r1", "statut": "hypothetique",
          "sources": [["role", "v_1", "agent", "e_1"]]}
    lu["derivations"] = [d1, d2]
    j = juger(lu)
    assert j["r2"]["gain"] == 1 and j["r2"]["elements_faux"] == 0
    assert j["r1"]["gain"] == 0 and j["r1"]["gain_et_erreur_regle"] == 1
    assert j["r1"]["elements_justes"] >= 1 and j["r1"]["elements_faux"] >= 1


def derivation_fausse(regle, source):
    return {"fait": ["relation", "rx", "e_2", "near", "e_4", "p2"], "regle": regle, "statut": "hypothetique",
            "sources": [source]}


def test_sources_etiquette_du_role():
    lu = faits()
    lu["faits"] = [f for f in lu["faits"] if f != ["role", "v_1", "patient", "e_2"]] + [["role", "v_1", "theme", "e_2"]]
    source = ["role", "v_1", "theme", "e_2"]          # la référence dit patient
    lu["derivations"] = [derivation_fausse("p1", source)]
    j = juger(lu)["p1"]
    assert j["erreur_heritee"] == 1 and j["sources_fausses:etiquette_role"] == 1
    lu["derivations"] = [derivation_fausse("r1", source)]   # R1 réécrit cette étiquette : elle n'est pas jugée
    assert juger(lu)["r1"]["erreur_regle"] == 1


def test_sources_qualificatifs():
    lu = faits()
    source = ["entite", "e_4", "club", "p4"]
    lu["derivations"] = [derivation_fausse("p1", source)]
    assert juger(lu)["p1"]["erreur_regle"] == 1             # le club est nié des deux côtés : la source est juste
    lu["faits"] = [f for f in lu["faits"] if f != ["polarite", "e_4", "neg"]]
    j = juger(lu)["p1"]
    assert j["erreur_heritee"] == 1 and j["sources_fausses:qualificatifs"] == 1


def test_sources_predicat_de_relation():
    lu = faits()
    lu["faits"] = [f if f[:2] != ["relation", "r_1"] else ["relation", "r_1", "e_3", "carry", "e_4", "p3"]
                   for f in lu["faits"]]
    lu["derivations"] = [derivation_fausse("p1", ["relation", "r_1", "e_3", "carry", "e_4", "p3"])]
    j = juger(lu)["p1"]
    assert j["erreur_heritee"] == 1 and j["sources_fausses:relation"] == 1


def test_source_reecrite_par_p1():
    lu = faits()
    lu["faits"].append(["propriete", "q_1", "e_2", "crouching", "p2"])     # la référence n'a pas cette propriété
    d = {"fait": ["evenement", "v_9", "crouch", "p2"], "regle": "p1", "statut": "hypothetique",
         "sources": [["propriete", "q_1", "e_2", "crouching", "p2"]]}
    lu["derivations"] = [d]
    assert juger(lu)["p1"]["erreur_regle"] == 1      # le porteur (le lion) est juste : l'erreur est celle de la règle
    lu["derivations"] = [dict(d, sources=[["propriete", "q_1", "e_9", "crouching", "p2"]])]
    lu["faits"] += [["entite", "e_9", "cat", "p9"], ["propriete", "q_1", "e_9", "crouching", "p2"]]
    j = juger(lu)["p1"]
    assert j["erreur_heritee"] == 1 and j["sources_fausses:mention"] == 1


# --- la couverture des assertions admissibles, et les intervalles par fiche -------------------------------------------

def test_couverture_et_promotion_se_lisent_ensemble():
    juste = cg.metriques_surete(resultat(faits()).securite)
    assert juste["taux_promotion"] == 0 and juste["couverture_admissible"] == 1
    tout_nie = faits()
    tout_nie["faits"] += [["polarite", x, "neg"] for x in ("e_1", "e_2", "e_3", "v_1", "n1")]
    m = cg.metriques_surete(resultat(tout_nie).securite)
    assert m["taux_promotion"] == 0 and m["couverture_admissible"] == 0     # aucune promotion, aucune couverture
    rien_nie = faits(pol_rel="pos")
    assert cg.metriques_surete(resultat(rien_nie).securite)["taux_promotion"] > 0


def test_intervalles_par_fiche():
    r1, r2 = resultat(faits()), resultat(faits(role_patient="e_4"))
    par_texte = {(1, "positif"): r1, (1, "variante_negation"): r1, (2, "positif"): r2}
    iv = cg.intervalles(par_texte, tirages=200)
    assert iv["fiches"] == 2                       # deux fiches, non trois textes
    b, h = iv["intervalles"]["structure:roles"]
    assert 0 < b <= h <= 1
    assert iv == cg.intervalles(par_texte, tirages=200)                      # reproductible (graine)


def test_precision_des_admissibles_compte_les_sans_correspondante():
    juste = cg.metriques_surete(resultat(faits()).securite)
    assert juste["precision_admissible"] == 1
    lu = faits()
    lu["faits"] += [["entite", "e_9", "dragon", "p9"]]          # admissible, sans correspondante dans la référence
    S = resultat(lu).securite
    assert S["graphe_admissible_sans_correspondante"] == 1
    assert cg.metriques_surete(S)["precision_admissible"] < 1


def test_intervalles_apparies_et_jalon():
    a = {(1, "positif"): resultat(faits(pol_rel="pos")), (2, "positif"): resultat(faits(pol_rel="pos"))}
    b = {(1, "positif"): resultat(faits()), (2, "positif"): resultat(faits())}
    app = cg.intervalles_apparies(a, b, tirages=100)
    assert app["fiches"] == 2 and app["a"]["surete:taux_promotion"] > 0 and app["b"]["surete:taux_promotion"] == 0
    assert app["rapport_promotion"][1] == 0
    j = cg.jalon(app)
    assert j["promotions_divisees_par_deux"] and j["couverture_gardee"] and j["atteint"]
    assert not cg.jalon(cg.intervalles_apparies(b, a, tirages=100))["atteint"]   # l'inverse : pas de réduction
    same = cg.intervalles_apparies(a, a, tirages=100)
    assert all(lo == hi == 0 for lo, hi in same["difference"].values())          # A contre A : différence nulle


# --- l'admissibilité effective des prémisses (premisses.pl), et la présence des textes (apparier.py) ------------------

import json as _json
import shutil as _shutil
import subprocess as _subprocess

import pytest as _pytest


def test_id_reference():
    assert cg.id_reference("e1_n0") == "e1#nom0" and cg.id_reference("e12_q3") == "e12#prop3"
    assert cg.id_reference("v1") == "v1" and cg.id_reference("r_1") == "r_1"


def test_surete_effective_compte_ce_que_le_noyau_admet():
    lu = faits()
    pr = ({"e1": "pos_auteur", "e2": "aucun", "e3": "pos_auteur", "e4": "neg_auteur", "v1": "pos_auteur",
           "e1_n0": "pos_auteur", "r1": "neg_auteur"},
          [["v1", "agent", "e1", "pos_auteur"], ["v1", "patient", "e2", "aucun"]])
    pg = ({"e_1": "pos_auteur", "e_2": "pos_auteur", "e_3": "pos_auteur", "e_4": "neg_auteur", "v_1": "pos_auteur",
           "n1": "pos_auteur", "r_1": "neg_auteur"},
          [["v_1", "agent", "e_1", "pos_auteur"], ["v_1", "patient", "e_2", "pos_auteur"]])
    S = cg.comparer(cg.depuis_reference(REF), cg.depuis_faits(lu), premisses=(pr, pg)).securite
    m = cg.metriques_surete_effective(S)
    assert S["eff_promotion"] == 1 and S["eff_reference_non_premisse"] >= 1      # le lion : pas une prémisse
    assert m["taux_promotion_effectif_roles"] == 1 and m["couverture_effective_roles"] == 1


@_pytest.mark.skipif(_shutil.which("swipl") is None, reason="swipl absent")
def test_premisses_pl_suit_la_semantique_du_noyau(tmp_path):
    f = [["texte", "t"], ["doc", "fr", "description"], ["entite", "e1", "lion", "p1"], ["polarite", "e1", "neg"], ["modalite", "e1", "affirme"],
         ["portee", "e1", "represente"], ["enonciateur", "e1", "auteur"],
         ["propriete", "q1", "e1", "mort", "p1"], ["polarite", "q1", "pos"], ["modalite", "q1", "affirme"],
         ["portee", "q1", "represente"], ["enonciateur", "q1", "auteur"],
         ["entite", "e2", "homme", "p2"], ["polarite", "e2", "pos"], ["modalite", "e2", "affirme"],
         ["portee", "e2", "represente"], ["enonciateur", "e2", "auteur"],
         ["evenement", "v1", "tuer", "p3"], ["polarite", "v1", "pos"], ["modalite", "v1", "affirme"],
         ["portee", "v1", "represente"], ["enonciateur", "v1", "auteur"],
         ["role", "v1", "agent", "e2"], ["role", "v1", "patient", "e1"],
         ["passage", "p1", 0, 1], ["passage", "p2", 0, 1], ["passage", "p3", 0, 1]]
    entree, sortie = tmp_path / "g.json", tmp_path / "p.json"
    entree.write_text(_json.dumps([{"k": 1, "genre": "positif", "faits": f}]), encoding="utf-8")
    _subprocess.run(["swipl", str(ICI / "outils" / "graphes" / "premisses.pl"), str(entree), str(sortie)], check=True,
                    capture_output=True)
    x = _json.loads(sortie.read_text(encoding="utf-8"))[0]
    assert x["statut"] == "valide"
    # la propriété est affirmée, positive, de l'image : ses qualificatifs la diraient admissible ; son porteur est nié
    assert x["etats"]["q1"] == "aucun" and x["etats"]["e1"] == "neg_auteur" and x["etats"]["e2"] == "pos_auteur"
    roles = {(v, r): e for v, r, _, e in x["roles"]}
    assert roles[("v1", "agent")] == "pos_auteur" and roles[("v1", "patient")] == "aucun"


spec_ap = importlib.util.spec_from_file_location("ap", ICI / "outils" / "graphes" / "apparier.py")
ap = importlib.util.module_from_spec(spec_ap)
spec_ap.loader.exec_module(ap)


def test_presence_de_tous_les_textes():
    R = {(1, "positif"): {}, (1, "negatif"): {}}
    A = {(1, "positif"): {"faits": []}, (1, "negatif"): {"faits": "erreur"}}
    B = {(1, "positif"): {"faits": []}}
    defauts, erreurs = ap.controler_presence(R, A, B)
    assert defauts and "absents de B" in defauts[0] and erreurs["A"] == [(1, "negatif")]
    assert ap.controler_presence(R, A, A)[0] == []
    att = ap.textes_attendus([{"k": 1, "positif": "x", "negatif": "y", "variantes": {"negation": "z"}}], 5)
    assert att == {(1, "positif"), (1, "negatif"), (1, "variante_negation")}
    assert "attendus absents" in ap.controler_presence(R, A, A, att)[0][0]
