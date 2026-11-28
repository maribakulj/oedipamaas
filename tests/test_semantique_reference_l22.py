"""L22, le statut local ER_H (docs/LANGAGE_REFERENCE.md, § 3.7 « L22, une même substitution certifiée de chaque signe
sous des hypothèses différentes », avec § 3.8 pour le consensus des branches et § 3.10 pour la table de la déf. 10).

Les valeurs attendues viennent de la spécification, jamais de l'interpréteur : chaque test dit la règle qu'il applique.
Les cas sont écrits dans la syntaxe concrète (`json_concret.lire_cas`, § 4) ; l'oracle des figures (`attendu_figures`)
ré-applique à la main la déf. 2 (C⁺, C⁻) et l'ordre du § 3.7 sur un modèle minimal à deux concepts incompatibles.

Variables d'environnement : SEMREF_L22_N (cas tirés), SEMREF_L22_GRAINE (graine des tirages).

Doutes de lecture (marqués « DOUTE » dans le texte) :
 - D1 (résolu par l'orchestrateur) : hyps_moins est l'ensemble des réunions minimales d'un ensemble de C⁻ par ligne
   certifiée positive ; une réfutation d'une autre substitution n'y entre pas.
 - D2 (résolu) : le consensus de plusieurs branches ER_H réunit deux à deux un ensemble par branche, puis minimise.
 - D4 : les mesures d'un système ER_H contre une référence d'un seul signe (lues signe par signe : son côté positif
   contre une référence R est une erreur e⁺_der) ; la spécification dit « ER_H compte à la fois comme E_H et comme R_H ».
 - D3 : l'interface qui expose les deux familles d'un résultat multi-branches (`ResultatLocal`) n'est pas fixée par la
   spécification ; le test lit `hyps_plus` / `hyps_moins` de `ResultatLocal`, et de `ResultatBranche`.
"""
from __future__ import annotations

import itertools
import json
import os
import random
import sys
from pathlib import Path

import pytest

ICI = Path(__file__).resolve().parent
sys.path.insert(0, str(ICI.parent))
sys.path.insert(0, str(ICI))

from semantique_reference import banc, formation, interprete as I, json_concret as J  # noqa: E402
from semantique_reference.syntaxe import RACINE, Hypothese  # noqa: E402
from semantique_reference_gen import tirer_cas  # noqa: E402

N = int(os.environ.get("SEMREF_L22_N", "40"))
GRAINE = int(os.environ.get("SEMREF_L22_GRAINE", "20261128"))

LOCAUX_10 = ["E", "E_H", "R", "R_H", "ER_H", "B", "NC+", "NC-", "N", "?"]
NATURE_A = "identification_iconographique"
NATURE_B = "connaissance_typique"


def profils_abstraits(jusqua=4, statuts=LOCAUX_10):
    for k in range(jusqua + 1):
        yield from itertools.combinations_with_replacement(statuts, k)


# =============================================================================================================
# Les cas : des figures, chacune avec une assertion « type(s, A) » et une « type(s, B) » (A et B incompatibles)
# =============================================================================================================

K_INCOMPATIBLES = {"version": "K-L22", "entrees": [
    {"entree": "incompatibilite", "id": "inc_AB", "a": "A", "b": "B", "forme": "type",
     "indexation": ["porteur", "contexte"], "source": {"ressource": "test L22"}, "statut": "attestee"}]}


def _assertion(ident, figure, concept, etat, nature, contenu):
    """etat : 'aff' (affirmée, sans hypothèse) ou 'sup' (supposée, sous l'hypothèse (nature, contenu))."""
    a = {"id": ident, "contenu": {"atome": {"pred": "type", "args": [figure], "type": concept}}}
    if etat == "sup":
        a["qualification"] = {"modalite": "supposee", "nature": nature, "contenu": contenu}
    return a


def cas_figures(figures, but="A", alternatives=None, hors_alternative=None, supplementaires=(), K=K_INCOMPATIBLES,
                identifiant="l22"):
    """Un cas à une définition « type(X, but) » et une figure par élément de `figures` : (etat_A, etat_B), chacun
    parmi 'none', 'aff', 'sup'. Chaque hypothèse supposée a un contenu à elle (h_A<k>, h_B<k>)."""
    refs, asser = [], []
    for k, (ea, eb) in enumerate(figures):
        s = f"s{k}"
        refs.append({"id": s, "sorte": "individu", "introduit_par": f"i_{s}"})
        asser.append({"id": f"i_{s}", "contenu": {"atome": {"pred": "type", "args": [s], "type": "figure"}}})
        if ea != "none":
            asser.append(_assertion(f"{s}_A", s, "A", ea, NATURE_A, f"h_A{k}"))
        if eb != "none":
            asser.append(_assertion(f"{s}_B", s, "B", eb, NATURE_B, f"h_B{k}"))
    asser.extend(supplementaires)
    d = {"id": "d", "langue": "fr", "texte": "", "contextes": [{"id": RACINE, "sorte": "figuration"}],
         "referents": refs, "assertions": asser}
    if alternatives:
        d["alternatives"] = alternatives
    return J.lire_cas({
        "notation": "nr-1", "id": identifiant, "description": d, "connaissances": K,
        "definition": {"id": "q", "variables": [["X", "individu"]],
                       "suffisante": {"pred": "type", "args": ["?X"], "type": but}}})


def evaluer_cas(c):
    assert formation.verifier(c) == [], [str(f) for f in formation.verifier(c)]
    ev = I.evaluer(c)
    prof = ev.profils[RACINE]
    assert len(prof.classes) == 1  # aucun point : une seule interprétation, une seule classe
    cl = prof.classes[0]
    return ev, cl, cl.resultat


def natures(famille):
    """Une famille d'ensembles d'hypothèses, réduite aux natures (triée) : [(nature, …), …]."""
    return sorted(tuple(sorted(h.nature for h in H)) for H in famille)


# =============================================================================================================
# L'oracle des figures : la déf. 2 et l'ordre du § 3.7, appliqués à la main
# =============================================================================================================

NOM_SYN_UNE_CLASSE = {"E": "etablie", "E_H": "etablie_sous_hypotheses", "R": "ecartee",
                      "R_H": "ecartee_sous_hypotheses", "ER_H": "divergent", "B": "contradictoire",
                      "N": "inconnue"}


def attendu_figures(figures, but="A"):
    """Le statut local attendu (§ 3.6, § 3.7) et les natures des deux familles, pour des figures indépendantes.
    Pour une figure : le côté positif est le concept `but`, le côté négatif son incompatible (RS 9).
      - D⁺ sans hypothèse : le positif est affirmé ; D⁻ sans hypothèse : le négatif est affirmé.
      - C⁺ : une solution (le positif existe) dont l'unique appui est sous H (∅ si affirmé), sans appui négatif sous H :
        un négatif affirmé (sous ∅ ⊆ H) l'exclut ; un négatif supposé, d'une autre hypothèse, ne l'exclut pas.
      - C⁻ : l'appui négatif sous H' (∅ si affirmé), sans appui positif sous H' : un positif affirmé l'exclut ;
        un positif supposé, d'une autre hypothèse, ne l'exclut pas.
    Puis l'ordre du § 3.7 (E, E_H, ER_H, B, NC+, R, R_H, NC-, N)."""
    nat_pos, nat_neg = (NATURE_A, NATURE_B) if but == "A" else (NATURE_B, NATURE_A)
    lignes = []
    for ea, eb in figures:
        pos, neg = (ea, eb) if but == "A" else (eb, ea)
        d_plus, d_moins = pos == "aff", neg == "aff"
        c_plus = []
        if pos != "none" and neg != "aff":
            c_plus = [() if pos == "aff" else (nat_pos,)]
        c_moins = []
        if neg != "none" and pos != "aff":
            c_moins = [() if neg == "aff" else (nat_neg,)]
        if pos == "none" and neg == "none":
            continue
        lignes.append(dict(d_plus=d_plus, d_moins=d_moins, c_plus=c_plus, c_moins=c_moins))
    cp = [h for l in lignes for h in l["c_plus"]]
    if any(h == () for h in cp):
        return "E", [], []
    if cp:
        if any(l["c_plus"] and not l["c_moins"] for l in lignes):
            return "E_H", sorted(cp), []
        # hyps_moins : une réunion d'un ensemble de C⁻ par ligne certifiée positive (§ 3.7, L22) ; ici chaque ligne
        # certifiée positive n'a qu'un C⁻, de la nature du négatif : un seul ensemble, de m hypothèses
        m = sum(1 for l in lignes if l["c_plus"])
        return "ER_H", sorted(cp), [tuple([nat_neg] * m)]
    if any(l["d_plus"] and l["d_moins"] for l in lignes):
        return "B", [], []
    if any(l["d_plus"] for l in lignes):
        return "NC+", [], []
    cm = [h for l in lignes if not l["d_plus"] for h in l["c_moins"]]
    if any(h == () for h in cm):
        return "R", [], []
    if cm:
        return "R_H", [], sorted(cm)
    if any(l["d_moins"] for l in lignes):
        return "NC-", [], []
    return "N", [], []


ETATS = ["none", "aff", "sup"]
FIGURES_NON_VIDES = [(a, b) for a in ETATS for b in ETATS if (a, b) != ("none", "none")]


def verifier_figures(figures, but="A"):
    c = cas_figures(figures, but=but)
    ev, cl, rl = evaluer_cas(c)
    st, hp, hm = attendu_figures(figures, but)
    assert rl.statut == st, (figures, but, rl.statut, st)
    b = rl.branches[0]
    assert b.statut == st == cl.statut
    if st == "ER_H":
        assert natures(b.hyps_plus) == [h for h in hp] and natures(b.hyps_moins) == [h for h in hm], (figures, but)
    if st == "E_H":
        assert natures(b.hyps_plus) == hp and not b.hyps_moins, (figures, but)
    if st == "R_H":
        assert natures(b.hyps_moins) == hm and not b.hyps_plus, (figures, but)
    if st in ("E", "R", "B", "NC+", "NC-", "N"):
        assert not b.hyps_plus and not b.hyps_moins
    if st in NOM_SYN_UNE_CLASSE:
        assert ev.principal.nom == NOM_SYN_UNE_CLASSE[st], (figures, ev.principal.nom)
    return rl


# =============================================================================================================
# 1. L'exemple minimal (§ 3.7, L22)
# =============================================================================================================

def test_exemple_minimal_statut_local_ER_H():
    """§ 3.7, L22 : D a deux assertions supposées sur la même figure, type(s, A) [identification_iconographique] et
    type(s, B) [connaissance_typique] ; A et B incompatibles dans K ; Δ demande type(X, A). Une seule substitution,
    certifiée positive sous H₁ et négative sous H₂ : statut local ER_H, hyps_plus de nature
    identification_iconographique, hyps_moins de nature connaissance_typique."""
    c = cas_figures([("sup", "sup")])
    ev, cl, rl = evaluer_cas(c)
    assert cl.statut == rl.statut == "ER_H"
    b = rl.branches[0]
    assert b.statut == "ER_H"
    assert natures(b.hyps_plus) == [(NATURE_A,)]
    assert natures(b.hyps_moins) == [(NATURE_B,)]
    # le résultat (la classe du profil) garde les deux familles (DOUTE D3 sur le nom des attributs)
    assert natures(rl.hyps_plus) == [(NATURE_A,)] and natures(rl.hyps_moins) == [(NATURE_B,)]
    # chaque famille ne contient aucun ensemble vide : la ligne est doublement conditionnelle
    assert all(len(H) == 1 for H in b.hyps_plus + b.hyps_moins)
    # la ligne gardée : une substitution certifiée de chaque signe, sans appui sans hypothèse
    (ligne,) = [l for l in b.lignes if l.c_plus]
    assert ligne.c_plus and ligne.c_moins and all(ligne.c_plus) and all(ligne.c_moins)
    assert ligne.valeur == "N"  # sans hypothèse, la valeur est (0, 0) ; V sous H₁, F sous H₂, B sous H₁ ∪ H₂


def test_exemple_minimal_statut_synthetique_divergent_2_2():
    """§ 3.7, L22 et § 3.10 : un profil qui contient ER_H tombe sur la ligne « des classes V et des classes F » :
    divergent, (ℓ⁺, ℓ⁻) = (2, 2)."""
    ev, cl, rl = evaluer_cas(cas_figures([("sup", "sup")]))
    s = ev.principal
    assert s.nom == "divergent" and s.niveaux == (2, 2)
    assert ev.profils[RACINE].statuts() == ["ER_H"]
    assert s.ligne == 3


def test_exemple_minimal_negatifs():
    """Les exemples négatifs du minimal : une seule des deux assertions supposées ne donne pas ER_H (E_H : rien ne
    conteste la solution ; R_H : aucune solution) ; la même hypothèse des deux côtés ne certifie rien ; et la
    permutation du but échange les deux familles."""
    assert verifier_figures([("sup", "none")]).statut == "E_H"
    assert verifier_figures([("none", "sup")]).statut == "R_H"
    # même hypothèse (nature et contenu) des deux côtés : chaque appui négatif (positif) est sous la même H, donc
    # C⁺ et C⁻ sont vides (« F_n n'a aucun appui négatif sous σ et H ») ; sans hypothèse, la valeur est (0, 0)
    mem = {"modalite": "supposee", "nature": NATURE_A, "contenu": "meme"}
    refs = [{"id": "s0", "sorte": "individu", "introduit_par": "i_s0"}]
    asser = [{"id": "i_s0", "contenu": {"atome": {"pred": "type", "args": ["s0"], "type": "figure"}}},
             {"id": "x_A", "contenu": {"atome": {"pred": "type", "args": ["s0"], "type": "A"}}, "qualification": mem},
             {"id": "x_B", "contenu": {"atome": {"pred": "type", "args": ["s0"], "type": "B"}}, "qualification": mem}]
    c = J.lire_cas({"notation": "nr-1", "id": "meme_h", "connaissances": K_INCOMPATIBLES,
                    "description": {"id": "d", "referents": refs, "assertions": asser},
                    "definition": {"id": "q", "variables": [["X", "individu"]],
                                   "suffisante": {"pred": "type", "args": ["?X"], "type": "A"}}})
    ev, cl, rl = evaluer_cas(c)
    assert rl.statut == "N" and ev.principal.nom == "inconnue"


def test_exemple_minimal_dual_les_familles_sont_echangees():
    """Proposition 3 (dual), lue sur le cas : demander B au lieu de A, sur la même description, échange le rôle des
    deux assertions : ER_H, avec hyps_plus de nature connaissance_typique et hyps_moins de nature
    identification_iconographique (les deux familles sont échangées)."""
    _, _, rl = evaluer_cas(cas_figures([("sup", "sup")], but="B"))
    assert rl.statut == "ER_H"
    b = rl.branches[0]
    assert natures(b.hyps_plus) == [(NATURE_B,)]
    assert natures(b.hyps_moins) == [(NATURE_A,)]


# =============================================================================================================
# 2. Une autre substitution seulement positive sous hypothèse : E_H ; 3. une solution certifiée sans hypothèse : E
# =============================================================================================================

def test_autre_substitution_positive_sous_hypothese_reste_E_H():
    """§ 3.7, L22 point 2 : une seconde figure certifiée A sous une identification, sans réfutation (C⁻ vide). Une
    solution non contestée suffit à la conclusion existentielle ; la réfutation qui porte sur une autre substitution
    n'y retire rien : E_H, sans changement (hyps_plus : les deux hypothèses, hyps_moins vide)."""
    c = cas_figures([("sup", "sup"), ("sup", "none")])
    ev, cl, rl = evaluer_cas(c)
    assert rl.statut == "E_H"
    b = rl.branches[0]
    assert natures(b.hyps_plus) == [(NATURE_A,), (NATURE_A,)]  # CP : les deux figures
    assert not b.hyps_moins
    assert ev.principal.nom == "etablie_sous_hypotheses" and ev.principal.niveaux == (2, 0)
    # la ligne de la seconde figure est certifiée positive, sans C⁻ ; celle de la première est doublement conditionnelle
    cert = [l for l in b.lignes if l.c_plus]
    assert len(cert) == 2 and sorted(bool(l.c_moins) for l in cert) == [False, True]


def test_solution_certifiee_sans_hypothese_reste_E():
    """§ 3.7, L22 point 1 : ∅ ∈ CP donne E, sans changement, même si une autre ligne est doublement conditionnelle."""
    c = cas_figures([("sup", "sup"), ("aff", "none")])
    ev, cl, rl = evaluer_cas(c)
    assert rl.statut == "E" and not rl.branches[0].hyps_plus and not rl.branches[0].hyps_moins
    assert ev.principal.nom == "etablie" and ev.principal.niveaux == (3, 0)
    # un négatif seulement supposé sur la figure affirmée ne retire pas ∅ : C⁺ = {∅} (C⁻ vide sous ∅)
    assert verifier_figures([("sup", "sup"), ("aff", "sup")]).statut == "E"


# =============================================================================================================
# L'oracle des figures : tous les cas d'une et de deux figures, et des tirages de trois
# =============================================================================================================

@pytest.mark.parametrize("but", ["A", "B"])
def test_figures_isolees(but):
    """Les neuf états d'une figure (hors le vide) : le statut local et les familles attendus par le § 3.7."""
    for f in FIGURES_NON_VIDES:
        verifier_figures([f], but)


def test_deux_figures_toutes_combinaisons():
    """Deux figures indépendantes, toutes les combinaisons (ordre sans importance) : l'ordre du § 3.7."""
    vus = {}
    for f, g in itertools.combinations_with_replacement(FIGURES_NON_VIDES, 2):
        rl = verifier_figures([f, g])
        vus[rl.statut] = vus.get(rl.statut, 0) + 1
    # l'énumération exerce les trois statuts de l'ordre modifié, et ER_H y est atteint
    assert {"E", "E_H", "ER_H", "R", "R_H", "B"} <= set(vus), vus


def test_figures_tirees_trois():
    rng = random.Random(GRAINE)
    for _ in range(max(10, N // 2)):
        n = rng.randint(3, 4)
        fig = [rng.choice(FIGURES_NON_VIDES) for _ in range(n)]
        verifier_figures(fig, rng.choice(["A", "B"]))


def test_ordre_des_figures_sans_effet():
    """Le statut local et les familles ne dépendent pas de l'ordre des figures (une propriété de l'ensemble)."""
    rng = random.Random(GRAINE + 1)
    for _ in range(max(6, N // 4)):
        fig = [rng.choice(FIGURES_NON_VIDES) for _ in range(3)]
        autre = fig[::-1]
        a = evaluer_cas(cas_figures(fig))[2]
        b = evaluer_cas(cas_figures(autre))[2]
        assert a.statut == b.statut and natures(a.hyps_plus) == natures(b.hyps_plus) \
            and natures(a.hyps_moins) == natures(b.hyps_moins)


def test_hyps_moins_deux_figures_positives_contestees_sous_H2_et_H3():
    """§ 3.7, L22 (hyps_moins) : deux figures certifiées positives, l'une contestée sous H2, l'autre sous H3 : les
    réunions minimales d'un C⁻ par ligne donnent un seul ensemble {H2, H3} (sous lui, tout candidat positif est
    réfuté) ; hyps_plus garde les deux hypothèses positives séparées."""
    _, _, rl = evaluer_cas(cas_figures([("sup", "sup"), ("sup", "sup")]))
    b = rl.branches[0]
    assert rl.statut == "ER_H"
    assert natures(b.hyps_plus) == [(NATURE_A,), (NATURE_A,)]
    assert natures(b.hyps_moins) == [(NATURE_B, NATURE_B)]
    assert {h.contenu for H in b.hyps_moins for h in H} == {"h_B0", "h_B1"}
    assert natures(rl.hyps_moins) == [(NATURE_B, NATURE_B)]  # DOUTE D3 validé


def test_hyps_moins_une_refutation_d_une_autre_substitution_n_y_entre_pas():
    """§ 3.7, L22 (hyps_moins) : une figure B affirmée sans hypothèse (A absent) est réfutée sans hypothèse, mais elle
    ne porte pas sur une substitution certifiée positive : ∅ n'entre pas dans hyps_moins, qui reste {H2} ; la
    réfutation reste une ligne gardée (réfutation citée)."""
    for autres in ([("none", "aff")], [("none", "aff"), ("none", "sup")]):
        _, _, rl = evaluer_cas(cas_figures([("sup", "sup")] + autres))
        b = rl.branches[0]
        assert rl.statut == "ER_H" and natures(b.hyps_plus) == [(NATURE_A,)]
        assert natures(b.hyps_moins) == [(NATURE_B,)], autres
        assert any(l.c_moins and not l.d_plus and not l.c_plus for l in b.lignes)  # la réfutation citée


# =============================================================================================================
# 4. T8 sur les dix statuts locaux ; la table de la déf. 10
# =============================================================================================================

def test_T8_dix_statuts_une_seule_ligne():
    """T8 (§ 3.10) : sur tous les profils de zéro à quatre classes et des dix statuts locaux, exactement une ligne
    de la déf. 10 vaut."""
    n = 0
    for prof in profils_abstraits(4):
        assert len(I.lignes_satisfaites(list(prof))) == 1, prof
        n += 1
    assert n == sum(len(list(itertools.combinations_with_replacement(LOCAUX_10, k))) for k in range(5)) == 1001


def test_ER_H_est_dans_I_plus_et_dans_I_moins():
    """§ 3.7, L22 : ER_H appartient à I⁺ (avec E, E_H) et à I⁻ (avec R, R_H) : tout profil qui le contient, sans « ? »,
    est sur la ligne « des classes V et des classes F » (divergent, ligne 3, (2, 2)) ; avec « ? », sur la ligne 2
    (incomplet), comme tout profil à classe inconnue."""
    for prof in profils_abstraits(4):
        if "ER_H" not in prof:
            continue
        nom, ligne, signe = I.syn_statuts(list(prof))
        if "?" in prof:
            assert (nom, ligne) == ("incomplet", 2), prof
        else:
            assert (nom, ligne) == ("divergent", 3), prof
            assert I.niveaux(nom, signe) == (2, 2)


def test_profil_E_H_et_ER_H_est_divergent():
    """§ 3.7, L22 : un profil {E_H, ER_H} donne divergent ; la ligne « toutes certifiées positives, dont une sous
    hypothèses » demande I⁻ = ∅, et sa duale I⁺ = ∅."""
    for prof, ligne in ((["E_H", "ER_H"], 3), (["ER_H", "E_H", "E_H"], 3), (["R_H", "ER_H"], 3), (["E", "ER_H"], 3),
                        (["ER_H"], 3), (["ER_H", "ER_H"], 3)):
        nom, l, _ = I.syn_statuts(prof)
        assert (nom, l) == ("divergent", ligne), prof
        assert I.niveaux(nom) == (2, 2)
    # sans ER_H, les profils de la ligne 5 et de sa duale (ligne 8) sont inchangés
    assert I.syn_statuts(["E_H", "E_H"])[:2] == ("etablie_sous_hypotheses", 5)
    assert I.syn_statuts(["R_H", "R"])[:2] == ("ecartee_sous_hypotheses", 8)


def test_def11_garanties_sur_les_dix_statuts():
    """Déf. 11 (§ 3.10), sur les profils des dix statuts : ℓ ≥ 1 ⇒ une classe a une dérivation de ce signe ; ℓ ≥ 2 ⇒
    une classe est certifiée ; ℓ = 3 ⇒ toutes, sans hypothèse. ER_H dérive et certifie les deux signes."""
    derive = {"+": {"E", "E_H", "ER_H", "B", "NC+"}, "-": {"R", "R_H", "ER_H", "B", "NC-"}}
    certifie = {"+": {"E", "E_H", "ER_H"}, "-": {"R", "R_H", "ER_H"}}
    for prof in profils_abstraits(4):
        nom, _, s = I.syn_statuts(list(prof))
        for signe, l in zip("+-", I.niveaux(nom, s)):
            if l >= 1:
                assert set(prof) & derive[signe], (prof, nom)
            if l >= 2:
                assert set(prof) & certifie[signe], (prof, nom)
            if l == 3:
                assert set(prof) == ({"E"} if signe == "+" else {"R"}), (prof, nom)


# =============================================================================================================
# 5. Le dual
# =============================================================================================================

def test_dual_local_ER_H_sur_ER_H():
    """Proposition 3 : le dual envoie ER_H sur ER_H ; le dual est une involution sur les dix statuts."""
    assert I.DUAL_LOCAL["ER_H"] == "ER_H"
    assert set(I.DUAL_LOCAL) >= set(LOCAUX_10)
    for s in LOCAUX_10:
        assert I.DUAL_LOCAL[I.DUAL_LOCAL[s]] == s
    assert I.dual_statuts(["ER_H", "E", "R_H"]) == ["ER_H", "R", "E_H"]


def test_T7_dix_statuts():
    """T7 (proposition 3) : Syn(Π̄) est le dual de Syn(Π), sur tous les profils des dix statuts jusqu'à quatre
    classes ; en particulier sur ceux qui contiennent ER_H (divergent est son propre dual)."""
    for prof in profils_abstraits(4):
        nom, _, signe = I.syn_statuts(list(prof))
        nom2, _, signe2 = I.syn_statuts(I.dual_statuts(list(prof)))
        assert (nom2, signe2) == I.dual_nom(nom, signe), prof
    assert I.syn_statuts(["ER_H"])[0] == I.syn_statuts(I.dual_statuts(["ER_H"]))[0] == "divergent"
    assert I.niveaux("divergent") == (2, 2)  # le dual échange ℓ⁺ et ℓ⁻ : (2, 2) est stable


def test_T7_sur_le_profil_d_un_cas_ER_H():
    """T7 sur le profil réel de l'exemple minimal."""
    ev, _, _ = evaluer_cas(cas_figures([("sup", "sup")]))
    st = ev.profils[RACINE].statuts()
    assert st == ["ER_H"]
    assert I.syn_statuts(I.dual_statuts(st))[0] == I.dual_nom(*I.syn_statuts(st)[::2])[0] == "divergent"


# =============================================================================================================
# 6. Le consensus des branches (§ 3.7, § 3.8), signe par signe
# =============================================================================================================

H_PLUS = Hypothese(NATURE_A, "hp")
H_MOINS = Hypothese(NATURE_B, "hm")
H_AUTRE = Hypothese("identite", "ho")
H_AUTRE2 = Hypothese("convention", "ho2")
POSITIFS, NEGATIFS = {"E", "E_H", "ER_H"}, {"R", "R_H", "ER_H"}


def branche(statut, hp_extra=None, hm_extra=None):
    """Une branche abstraite du statut dit, avec des hypothèses du signe qui convient (hp_extra, hm_extra : des
    hypothèses d'une autre nature, pour distinguer les branches)."""
    hp = (frozenset({H_PLUS} | ({hp_extra} if hp_extra else set())),) if statut in ("E_H", "ER_H") else ()
    hm = (frozenset({H_MOINS} | ({hm_extra} if hm_extra else set())),) if statut in ("R_H", "ER_H") else ()
    return I.ResultatBranche(statut, (), hp, hm, True)


def statut_attendu_consensus(combo):
    """§ 3.7, L22 (consensus signe par signe) : le côté positif vaut si toutes les branches sont dans {E, E_H, ER_H},
    le négatif si toutes sont dans {R, R_H, ER_H} ; les deux seulement si toutes sont ER_H (le résultat est ER_H) ; un
    seul côté donne E, E_H, R ou R_H par les règles existantes (une branche ER_H y apportant la famille du signe, donc
    E_H ou R_H dès qu'une branche l'est) ; si aucun côté ne vaut, ER_H compte comme B dans les règles existantes."""
    s = set(combo)
    if s == {"ER_H"}:
        return "ER_H"
    if "ER_H" in s and s <= POSITIFS:
        return "E_H"
    if "ER_H" in s and s <= NEGATIFS:
        return "R_H"
    return I.combiner_branches([branche("B" if x == "ER_H" else x) for x in combo])[0]


def test_consensus_signe_par_signe_tous_les_melanges():
    """§ 3.7, L22 : le consensus, signe par signe, sur tous les mélanges de une à trois branches des dix statuts."""
    n = 0
    for k in range(1, 4):
        for combo in itertools.product(LOCAUX_10, repeat=k):
            if "ER_H" not in combo:
                continue
            assert I.combiner_branches([branche(s) for s in combo])[0] == statut_attendu_consensus(combo), combo
            n += 1
    assert n > 200


def test_consensus_exemples_de_la_specification():
    """§ 3.7, L22 : {ER_H, E} donne E_H ; {ER_H, R} donne R_H ; {ER_H, ER_H} donne ER_H ; {ER_H} donne ER_H. Et la
    règle ne vaut que par signe : {ER_H, E} n'est pas ER_H (la branche E ne certifie pas le négatif), {ER_H, B} et
    {ER_H, NC+} se lisent comme {B, B} et {B, NC+}."""
    c = I.combiner_branches
    assert c([branche("ER_H"), branche("E")])[0] == "E_H"
    assert c([branche("E"), branche("ER_H")])[0] == "E_H"
    assert c([branche("ER_H"), branche("E_H", H_AUTRE)])[0] == "E_H"
    assert c([branche("ER_H"), branche("R")])[0] == "R_H"
    assert c([branche("R_H", hm_extra=H_AUTRE), branche("ER_H")])[0] == "R_H"
    assert c([branche("ER_H"), branche("ER_H")])[0] == "ER_H"
    assert c([branche("ER_H")])[0] == "ER_H"
    # aucun côté ne vaut : ER_H compte comme B
    assert c([branche("ER_H"), branche("B")])[0] == c([branche("B"), branche("B")])[0] == "B"
    assert c([branche("ER_H"), branche("NC+")])[0] == c([branche("B"), branche("NC+")])[0] == "NC+"
    assert c([branche("ER_H"), branche("NC-")])[0] == c([branche("B"), branche("NC-")])[0] == "NC-"
    assert c([branche("ER_H"), branche("N")])[0] == c([branche("B"), branche("N")])[0]
    assert c([branche("ER_H"), branche("?")])[0] == "?"
    # un mélange des deux signes : ni E ni R
    assert c([branche("E"), branche("R"), branche("ER_H")])[0] == c([branche("E"), branche("R"), branche("B")])[0]


def test_consensus_hypotheses_par_signe():
    """§ 3.7, L22 : les ensembles d'hypothèses sont les réunions minimales d'un ensemble du signe par branche, ∅ pour
    une branche E (ou R). {ER_H, E} : la famille positive de la branche ER_H seule ; {ER_H, E_H} : la réunion de leurs
    ensembles positifs ; {ER_H, R} : la famille négative de la branche ER_H ; {ER_H, R_H} : leur réunion ; {ER_H,
    ER_H} identiques : les mêmes deux familles (DOUTE D2 : l'union de deux familles différentes n'est pas testée)."""
    c = I.combiner_branches
    st, hs = c([branche("ER_H"), branche("E")])
    assert natures(hs) == [(NATURE_A,)]
    st, hs = c([branche("ER_H"), branche("E_H", hp_extra=H_AUTRE)])
    assert natures(hs) == [tuple(sorted((NATURE_A, "identite")))]
    st, hs = c([branche("ER_H"), branche("R")])
    assert natures(hs) == [(NATURE_B,)]
    st, hs = c([branche("ER_H"), branche("R_H", hm_extra=H_AUTRE2)])
    assert natures(hs) == [tuple(sorted((NATURE_B, "convention")))]
    st, hs = c([branche("ER_H"), branche("ER_H")])
    assert st == "ER_H"
    plus, moins = hs  # DOUTE D3 : la forme du second terme pour ER_H (le couple des deux familles)
    assert natures(plus) == [(NATURE_A,)] and natures(moins) == [(NATURE_B,)]


def test_consensus_deux_branches_ER_H_reunion_deux_a_deux():
    """§ 3.7, L22 (D2 résolu) : le consensus de deux branches ER_H réunit un ensemble par branche, puis minimise. Deux
    familles différentes : {P1} et {P2} donnent {P1 ∪ P2} (l'union des familles donnerait {P1}, {P2}) ; deux ensembles
    dans une branche donnent deux réunions."""
    P1, P2, P3 = (Hypothese(NATURE_A, "p1"), Hypothese("identite", "p2"), Hypothese("convention", "p3"))
    M1, M2 = Hypothese(NATURE_B, "m1"), Hypothese("abduction", "m2")
    b1 = I.ResultatBranche("ER_H", (), (frozenset({P1}),), (frozenset({M1}),), True)
    b2 = I.ResultatBranche("ER_H", (), (frozenset({P2}),), (frozenset({M2}),), True)
    st, (plus, moins) = I.combiner_branches([b1, b2])
    assert st == "ER_H"
    assert set(plus) == {frozenset({P1, P2})} and set(moins) == {frozenset({M1, M2})}
    b3 = I.ResultatBranche("ER_H", (), (frozenset({P1}), frozenset({P3})), (frozenset({M1}),), True)
    st, (plus, moins) = I.combiner_branches([b3, b2])
    assert set(plus) == {frozenset({P1, P2}), frozenset({P3, P2})} and set(moins) == {frozenset({M1, M2})}
    # la minimalité : une réunion qui en contient une autre est écartée
    b4 = I.ResultatBranche("ER_H", (), (frozenset({P1}),), (frozenset({M1}),), True)
    b5 = I.ResultatBranche("ER_H", (), (frozenset({P1}), frozenset({P1, P2})), (frozenset({M1}),), True)
    st, (plus, moins) = I.combiner_branches([b4, b5])
    assert set(plus) == {frozenset({P1})}


def _alternatives(branche1, branche2):
    return [{"id": "alt", "branches": [branche1, branche2]}]


A1 = {"id": "a1", "contenu": {"atome": {"pred": "type", "args": ["s0"], "type": "A"}},
      "qualification": {"modalite": "supposee", "nature": NATURE_A, "contenu": "h1"}}
A2 = {"id": "a2", "contenu": {"atome": {"pred": "type", "args": ["s0"], "type": "B"}},
      "qualification": {"modalite": "supposee", "nature": NATURE_B, "contenu": "h2"}}


def _cas_alternative(autre_branche):
    return cas_figures([("none", "none")], supplementaires=[A1, A2] + autre_branche,
                       alternatives=_alternatives(["a1", "a2"], [a["id"] for a in autre_branche]))


def test_consensus_cas_ER_H_et_E_donne_E_H():
    """§ 3.7, L22, sur un cas : une alternative de l'auteur dont une branche porte les deux assertions supposées (ER_H)
    et l'autre un type(s, A) affirmé (E) : E_H, sous la famille positive de la branche ER_H (la branche E ne certifie
    pas le signe négatif)."""
    a3 = {"id": "a3", "contenu": {"atome": {"pred": "type", "args": ["s0"], "type": "A"}}}
    ev, cl, rl = evaluer_cas(_cas_alternative([a3]))
    assert [b.statut for b in rl.branches] == ["ER_H", "E"]
    assert rl.statut == "E_H" and cl.statut == "E_H"
    assert natures(rl.hypotheses) == [(NATURE_A,)]
    assert ev.principal.nom == "etablie_sous_hypotheses" and ev.principal.niveaux == (2, 0)


def test_consensus_cas_ER_H_et_R_donne_R_H():
    """§ 3.7, L22, sur un cas : branches {ER_H, R} : R_H, sous la famille négative de la branche ER_H."""
    a3 = {"id": "a3", "contenu": {"atome": {"pred": "type", "args": ["s0"], "type": "B"}}}
    ev, cl, rl = evaluer_cas(_cas_alternative([a3]))
    assert [b.statut for b in rl.branches] == ["ER_H", "R"]
    assert rl.statut == "R_H" and natures(rl.hypotheses) == [(NATURE_B,)]
    assert ev.principal.nom == "ecartee_sous_hypotheses" and ev.principal.niveaux == (0, 2)


def test_consensus_cas_ER_H_et_B_compte_comme_B():
    """§ 3.7, L22, sur un cas : branches {ER_H, B} (la seconde affirme A et B) : aucun côté ne vaut, ER_H compte
    comme B : le résultat de {B, B}, B."""
    a3 = {"id": "a3", "contenu": {"atome": {"pred": "type", "args": ["s0"], "type": "A"}}}
    a4 = {"id": "a4", "contenu": {"atome": {"pred": "type", "args": ["s0"], "type": "B"}}}
    _, _, rl = evaluer_cas(_cas_alternative([a3, a4]))
    assert [b.statut for b in rl.branches] == ["ER_H", "B"] and rl.statut == "B"


def test_consensus_cas_deux_branches_ER_H():
    """§ 3.7, L22 : {ER_H, ER_H} donne ER_H. Deux branches ER_H identiques (même figure, deux variantes d'une
    assertion sans rapport) : les mêmes familles (DOUTE D2 : seuls les cas où les lectures de « union » coïncident)."""
    base = [A1, A2,
            {"id": "x1", "contenu": {"atome": {"pred": "type", "args": ["s0"], "type": "truc"}}},
            {"id": "x2", "contenu": {"atome": {"pred": "type", "args": ["s0"], "type": "machin"}}}]
    c = cas_figures([("none", "none")], supplementaires=base, alternatives=_alternatives(["x1"], ["x2"]))
    _, _, rl = evaluer_cas(c)
    assert [b.statut for b in rl.branches] == ["ER_H", "ER_H"] and rl.statut == "ER_H"
    assert natures(rl.hyps_plus) == [(NATURE_A,)] and natures(rl.hyps_moins) == [(NATURE_B,)]  # DOUTE D3


def test_consensus_cas_deux_branches_ER_H_aux_hypotheses_differentes():
    """§ 3.7, L22 (D2 résolu), sur un cas où les deux lectures diffèrent : chaque branche porte ses deux assertions
    supposées, d'autres hypothèses ; le consensus réunit {h1} et {h1'} en un ensemble, {h2} et {h2'} en un autre."""
    def sup(i, concept, nature, contenu):
        return {"id": i, "contenu": {"atome": {"pred": "type", "args": ["s0"], "type": concept}},
                "qualification": {"modalite": "supposee", "nature": nature, "contenu": contenu}}
    asser = [sup("b1A", "A", NATURE_A, "h1"), sup("b1B", "B", NATURE_B, "h2"),
             sup("b2A", "A", NATURE_A, "h1p"), sup("b2B", "B", NATURE_B, "h2p")]
    c = cas_figures([("none", "none")], supplementaires=asser,
                    alternatives=_alternatives(["b1A", "b1B"], ["b2A", "b2B"]))
    _, _, rl = evaluer_cas(c)
    assert [b.statut for b in rl.branches] == ["ER_H", "ER_H"] and rl.statut == "ER_H"
    assert [sorted(h.contenu for h in H) for H in rl.hyps_plus] == [["h1", "h1p"]]
    assert [sorted(h.contenu for h in H) for H in rl.hyps_moins] == [["h2", "h2p"]]


# =============================================================================================================
# 6 bis. Les mesures et la restriction des signes (§ 3.7, L22 : « Les mesures » et « Partout ailleurs »)
# =============================================================================================================

def test_mesures_signe_par_signe_ER_H():
    """§ 3.7, L22 : une référence ER_H n'est jamais « l'autre signe » ; une référence ER_H et un système ER_H ne font
    aucune erreur (e⁺_der, e⁺_cert, e⁻_der, e⁻_cert, d_nr)."""
    erreurs = ("e+_der", "e+_cert", "e-_der", "e-_cert", "d_nr")
    zero = {k: 0 for k in erreurs}
    hyps = [(frozenset({H_PLUS}),)]
    for sys_ in LOCAUX_10:
        if sys_ in ("?",):
            continue
        m = I.mesures([sys_], ["ER_H"])
        if sys_ in ("E", "E_H", "R", "R_H", "ER_H"):  # un système qui certifie un signe : la référence l'admet
            assert {k: m[k] for k in erreurs} == zero, (sys_, m)
    m = I.mesures(["ER_H"], ["ER_H"])
    assert {k: m[k] for k in erreurs} == zero
    m = I.mesures(["ER_H"], ["ER_H"], hyps_m=hyps, hyps_r=hyps)
    assert m == {k: 0 for k in m}  # aucune erreur et aucune nature perdue : mêmes hypothèses
    assert I.mesures(["ER_H"], ["ER_H"], divergent_r=True)["d_nr"] == 0  # un système ER_H est divergent, comme la référence
    # (DOUTE D4 : le système ER_H contre une référence d'un seul signe compte comme E_H et comme R_H, signe par signe :
    # son côté positif contre une référence R est une erreur e⁺_der, son côté négatif contre E une erreur e⁻_der.)
    assert I.mesures(["ER_H"], ["R"])["e+_der"] == 1 and I.mesures(["ER_H"], ["E"])["e-_der"] == 1
    assert I.mesures(["ER_H"], ["E_H"])["e+_der"] == 0 and I.mesures(["ER_H"], ["R_H"])["e-_der"] == 0


def test_restriction_des_signes_ER_H():
    """§ 3.7, L22 : la restriction envoie ER_H sur R_H quand le signe + n'est pas licencié, sur E_H quand le signe −
    ne l'est pas, sur N quand aucun ne l'est ; elle le laisse tel quel quand les deux le sont."""
    assert I.restreindre("ER_H", {"+", "-"}) == "ER_H"
    assert I.restreindre("ER_H", {"-"}) == "R_H"
    assert I.restreindre("ER_H", {"+"}) == "E_H"
    assert I.restreindre("ER_H", set()) == "N"
    # les autres statuts sont inchangés par cette règle
    assert I.restreindre("E_H", {"-"}) == "N" and I.restreindre("R_H", {"+"}) == "N"
    assert I.restreindre("E", {"+"}) == "E" and I.restreindre("R", {"-"}) == "R"


# =============================================================================================================
# 7. L22b : la certification exclut déjà les cas ouverts
# =============================================================================================================

def test_L22b_description_nie_A_sans_hypothese_une_hypothese_donne_A():
    """§ 3.7, L22b : une ligne certifiée positive sous H n'a jamais d'appui négatif connu sans hypothèse (C⁺ : « F_n n'a
    aucun appui négatif sous σ et H », ∅ ⊆ H). La description nie A sans hypothèse (« s n'est pas un A », affirmé) ;
    une hypothèse donnerait A (type(s, A) supposé). C⁺ est vide ; la réfutation est certifiée sans hypothèse (C⁻ = {∅},
    aucun appui positif sans hypothèse) : le statut est R, ni E_H, ni ER_H."""
    asser = [{"id": "nie", "contenu": {"non": {"atomes": [{"pred": "type", "args": ["s0"], "type": "A"}]}},
              "qualification": {"polarite": "neg"}},
             {"id": "hyp", "contenu": {"atome": {"pred": "type", "args": ["s0"], "type": "A"}},
              "qualification": {"modalite": "supposee", "nature": NATURE_A, "contenu": "h1"}}]
    ev, cl, rl = evaluer_cas(cas_figures([("none", "none")], supplementaires=asser))
    assert rl.statut not in ("E_H", "ER_H", "E")
    assert rl.statut == "R" and ev.principal.nom == "ecartee"
    for l in rl.branches[0].lignes:
        assert not l.c_plus  # aucune ligne certifiée positive


def test_L22b_par_incompatibilite_affirmee():
    """§ 3.7, L22b, même cas par l'incompatibilité de K : type(s, B) affirmé nie type(s, A) sans hypothèse (RS 9) ;
    type(s, A) supposé ne donne pas E_H. Statut R."""
    rl = verifier_figures([("sup", "aff")])
    assert rl.statut == "R" and not rl.branches[0].hyps_plus


def test_L22b_inverse_positif_sans_hypothese_negatif_sous_H():
    """§ 3.7, L22b, l'inverse : un positif sans hypothèse et un négatif seulement supposé : C⁻ exclu par l'appui positif
    sous ∅ ⊆ H ; C⁺ = {∅} : E, ni R_H ni ER_H."""
    rl = verifier_figures([("aff", "sup")])
    assert rl.statut == "E" and not rl.branches[0].hyps_moins


def test_L22b_aucune_ligne_certifiee_des_deux_signes_avec_un_appui_sans_hypothese():
    """§ 3.7, L22b, propriété sur les figures : une ligne certifiée de l'un des signes sous H n'a jamais l'appui
    contraire sans hypothèse (sur les neuf états d'une figure, but A et B)."""
    for but in ("A", "B"):
        for f in FIGURES_NON_VIDES:
            b = evaluer_cas(cas_figures([f], but=but))[2].branches[0]
            for l in b.lignes:
                if l.c_plus:
                    assert not l.d_moins, (f, but)
                if l.c_moins:
                    assert not l.d_plus, (f, but)


# =============================================================================================================
# Une propriété générale sur des cas tirés : le statut local est celui que la règle du § 3.7 lit sur les lignes
# =============================================================================================================

def cas_tires(n, graine):
    rng = random.Random(graine)
    out = []
    while len(out) < n:
        c = tirer_cas(rng)
        assert formation.verifier(c) == [], [str(d) for d in formation.verifier(c)]
        out.append(c)
    return out


def minimaux(hs):
    hs = list(dict.fromkeys(hs))
    return [h for h in hs if not any(g < h for g in hs)]


def propriete_statut_sur_lignes(cas):
    """§ 3.7, L22 : avec CP l'union des C⁺ des lignes gardées (elles gardent toute solution certifiée), le statut d'une
    branche complète est E si ∅ ∈ CP ; E_H si CP ≠ ∅ et qu'une ligne certifiée positive a un C⁻ vide ; ER_H si CP ≠ ∅
    et que toute ligne certifiée positive a un C⁻ non vide ; autrement ni E, ni E_H, ni ER_H. hyps_plus de E_H et d'ER_H
    sont les ensembles minimaux de CP ; hyps_moins d'un ER_H, les réunions minimales d'un C⁻ par ligne certifiée
    positive."""
    n_er = 0
    for c in cas:
        for p in I.profils(c).values():
            for cl in p.classes:
                for b in cl.resultat.branches:
                    if not b.complet or b.statut == "?":
                        continue
                    cp = [h for l in b.lignes for h in l.c_plus]
                    if any(not h for h in cp):
                        attendu = "E"
                    elif cp:
                        attendu = "E_H" if any(l.c_plus and not l.c_moins for l in b.lignes) else "ER_H"
                    else:
                        attendu = None
                    if attendu is None:
                        assert b.statut not in ("E", "E_H", "ER_H"), (c.id, b.statut)
                        continue
                    assert b.statut == attendu, (c.id, b.statut, attendu)
                    if attendu in ("E_H", "ER_H"):
                        assert set(b.hyps_plus) == set(minimaux(cp))
                    if attendu == "ER_H":
                        n_er += 1
                        assert b.hyps_moins
                        # hyps_moins : les réunions minimales d'un C⁻ par ligne certifiée positive
                        choix = itertools.product(*[l.c_moins for l in b.lignes if l.c_plus])
                        assert set(b.hyps_moins) == set(minimaux([frozenset().union(*ch) for ch in choix]))
    return n_er


def test_statut_lu_sur_les_lignes_gardees_cas_tires():
    """§ 3.7, L22 (voir `propriete_statut_sur_lignes`), sur les cas de tirer_cas. Le tirage ne produit presque jamais
    un ER_H (une assertion supposée sur chacun de deux concepts incompatibles) : la propriété est surtout exercée
    sur les cas dirigés ci-dessous."""
    n_er = propriete_statut_sur_lignes(cas_tires(N, GRAINE))
    print(f"branches ER_H dans les cas tirés : {n_er}")


# =============================================================================================================
# Des cas dirigés vers ER_H : la description tirée par tirer_cas, plus deux assertions supposées de natures
# différentes sur des individus, deux concepts incompatibles dans K, et une définition type(X, a)
# =============================================================================================================

def cas_dirige(rng):
    """Un cas bien formé de tirer_cas, dont on remplace la définition par type(X, a), à qui l'on ajoute, pour un à trois
    individus de D, type(r, a) supposé [identification_iconographique] et, presque toujours, type(r, b) supposé
    [connaissance_typique], avec a et b incompatibles dans K (le reste du tirage : contextes, points, gardes, négations,
    alternatives, hiérarchie de K, est gardé : il bruite le cas)."""
    from dataclasses import replace
    from semantique_reference.syntaxe import (Assertion, Cas, Connaissances, Definition, Incompatibilite,
                                              Qualification, Source, V, type_)
    from semantique_reference_gen import CONCEPTS
    c = tirer_cas(rng)
    D = c.description
    inds = [r.id for r in D.referents if r.sorte == "individu"]
    a, b = rng.sample(CONCEPTS, 2)
    K = Connaissances(c.connaissances.version, tuple(
        e for e in c.connaissances.entrees if not isinstance(e, Incompatibilite)) + (
        Incompatibilite("inc_dir", a, b, "type", ("porteur", "contexte"), source=Source("gen")),))
    ajouts = []
    for k, r in enumerate(rng.sample(inds, min(len(inds), rng.randint(1, 3)))):
        ajouts.append(Assertion(f"dirA{k}", type_(r, a),
                                Qualification("pos", "supposee", "auteur", RACINE, NATURE_A, f"hA{k}")))
        if rng.random() < 0.85:
            ajouts.append(Assertion(f"dirB{k}", type_(r, b),
                                    Qualification("pos", "supposee", "auteur", RACINE, NATURE_B, f"hB{k}")))
    D = replace(D, assertions=D.assertions + tuple(ajouts))
    Dl = Definition("qdir", variables=(("X", "individu"),), suffisante=type_(V("X"), a))
    return Cas("dirige", D, Dl, K)


def cas_diriges(n, graine):
    rng = random.Random(graine)
    out = []
    while len(out) < n:
        c = cas_dirige(rng)
        assert formation.verifier(c) == [], [str(d) for d in formation.verifier(c)]
        out.append(c)
    return out


def test_proportion_ER_H_des_cas_diriges():
    """Le générateur dirigé exerce ER_H : au moins un cas sur cinq a une branche ER_H (la proportion est rapportée)."""
    cas = cas_diriges(N, GRAINE)
    avec = sum(1 for c in cas if any("ER_H" in p.statuts() for p in I.profils(c).values()))
    print(f"cas dirigés avec une classe ER_H : {avec}/{len(cas)}")
    assert avec * 5 >= len(cas), (avec, len(cas))


def test_statut_lu_sur_les_lignes_gardees_cas_diriges():
    """§ 3.7, L22, sur les cas dirigés (voir `propriete_statut_sur_lignes`) ; et le générateur atteint ER_H."""
    n_er = propriete_statut_sur_lignes(cas_diriges(N, GRAINE + 3))
    print(f"branches ER_H dans les cas dirigés : {n_er}")
    assert n_er > 0


def test_attributs_de_syn_sur_les_cas_diriges():
    """§ 3.7, L22 (« partout ailleurs, ER_H compte à la fois comme E_H et comme R_H ») et § 3.10, sur les cas dirigés :
    la couverture de chaque signe est celle des classes de I⁺ = {E, E_H, ER_H} (resp. I⁻ = {R, R_H, ER_H}) ; sur la
    ligne 3 (divergent), les témoins sont ceux des classes certifiées d'un signe (dont ER_H) ; les réfutations citées sont
    les lignes réfutées sans D⁺ des classes de I⁻."""
    vus = 0
    for c in cas_diriges(N, GRAINE + 5):
        ev = I.evaluer(c)
        for ctx, p in ev.profils.items():
            if "ER_H" not in p.statuts():
                continue
            s = ev.statuts[ctx]
            vus += 1
            for signe, ens, couv in (("+", {"E", "E_H", "ER_H"}, s.couverture_plus),
                                     ("-", {"R", "R_H", "ER_H"}, s.couverture_moins)):
                X = [i for cl in p.classes if cl.statut in ens for i in cl.interpretations]
                assert X
                assert couv == I.cylindres_maximaux(X, p.I, p.points, p.preferences), (c.id, signe)
            if s.ligne == 3:
                assert s.temoins == [cl.temoin for cl in p.classes
                                     if cl.statut in {"E", "E_H", "R", "R_H", "ER_H"}], c.id
            cites = [(k, dict(l.sigma)) for k, cl in enumerate(p.classes) if cl.statut in {"R", "R_H", "ER_H"}
                     for b in cl.resultat.branches for l in b.lignes if l.c_moins and not l.d_plus]
            assert s.refutations == cites, c.id
    assert vus > 0


# =============================================================================================================
# 8. La non-régression : les cinq cas réels n'ont aucun ER_H
# =============================================================================================================

def _cas_des_dossiers():
    out = []
    for chemin in banc.dossiers():
        d = json.loads(chemin.read_text(encoding="utf-8"))
        out.extend(J.lire_cas(x) for x in d["cas"])
    return out


def test_cinq_cas_reels_aucun_ER_H():
    """§ 3.7, L22 / § 8 : le profil des cinq cas réels (ee-002, mn-004, rq-010, pi-003, co-018 : toutes leurs variantes)
    ne contient aucun ER_H, dans aucun contexte, aucune classe, aucune branche. (Les statuts attendus sont ceux de
    test_semantique_reference_exemples.py.)"""
    cas = _cas_des_dossiers()
    assert len(cas) >= 15
    assert {p.stem for p in banc.dossiers()} >= {"ee-002", "mn-004", "rq-010", "pi-003", "co-018"}
    for c in cas:
        ev = I.evaluer(c)
        for ctx, p in ev.profils.items():
            assert "ER_H" not in p.statuts(), (c.id, ctx)
            for cl in p.classes:
                assert cl.resultat.statut != "ER_H" and all(b.statut != "ER_H" for b in cl.resultat.branches), c.id


# =============================================================================================================
# Les attributs de Syn pour un profil qui contient ER_H (§ 3.7, L22 ; § 3.9 ; § 3.10) : cas construits à un point de D
# =============================================================================================================

def _sup(ident, figure, concept, nature, contenu, garde):
    return {"id": ident, "contenu": {"atome": {"pred": "type", "args": [figure], "type": concept}},
            "qualification": {"modalite": "supposee", "nature": nature, "contenu": contenu}, "garde": garde}


def cas_gardes(specs, figures=1):
    """Un point p de D (v1, v2) ; pour chaque (figure, valeur, contenu_A, contenu_B), les deux assertions supposées de la
    figure, gardées par p = valeur : sous cette valeur la figure est ER_H, sous l'autre elle ne porte rien (N)."""
    refs = [{"id": f"s{k}", "sorte": "individu", "introduit_par": f"i_s{k}"} for k in range(figures)]
    asser = [{"id": f"i_s{k}", "contenu": {"atome": {"pred": "type", "args": [f"s{k}"], "type": "figure"}}}
             for k in range(figures)]
    for (k, val, ha, hb) in specs:
        g = {"p": [val]}
        asser.append(_sup(f"A_{k}_{val}", f"s{k}", "A", NATURE_A, ha, g))
        asser.append(_sup(f"B_{k}_{val}", f"s{k}", "B", NATURE_B, hb, g))
    d = {"id": "d", "contextes": [{"id": RACINE, "sorte": "figuration"}], "referents": refs, "assertions": asser,
         "points": [{"id": "p", "cote": "D", "dimension": "structure", "domaine": ["v1", "v2"]}]}
    return J.lire_cas({"notation": "nr-1", "id": "gardes", "description": d, "connaissances": K_INCOMPATIBLES,
                       "definition": {"id": "q", "variables": [["X", "individu"]],
                                      "suffisante": {"pred": "type", "args": ["?X"], "type": "A"}}})


def evaluer_gardes(c):
    assert formation.verifier(c) == [], [str(f) for f in formation.verifier(c)]
    ev = I.evaluer(c)
    return ev, ev.profils[RACINE], ev.principal


def test_syn_profil_ER_H_et_N_couverture_des_deux_signes():
    """§ 3.7, L22 (ER_H compte dans I⁺ et dans I⁻) et déf. 7 : un profil {ER_H, N} (ER_H sous p = v1, N sous p = v2) :
    divergent ; la couverture de chaque signe est le cylindre p = v1 ; la robustesse de chaque signe est partielle."""
    ev, p, s = evaluer_gardes(cas_gardes([(0, "v1", "h1", "h2")]))
    assert p.statuts() == ["ER_H", "N"] and s.nom == "divergent" and s.ligne == 3
    assert s.couverture_plus == [{"p": ("v1",)}] and s.couverture_moins == [{"p": ("v1",)}]
    rb = I.robustesse(p)
    assert rb["+"][0] == "partielle" and rb["-"][0] == "partielle" and rb["ER_H"][0] == "partielle"
    assert rb["+"][1] == rb["-"][1] == rb["ER_H"][1] == [{"p": ("v1",)}]


def test_syn_profil_ER_H_seul_couverture_totale_des_deux_signes():
    """Déf. 7 : ER_H sous toute interprétation : la robustesse des deux signes est totale, la couverture est tout I."""
    ev, p, s = evaluer_gardes(cas_gardes([(0, "v1", "h1", "h2"), (0, "v2", "h1b", "h2b")]))
    assert p.statuts() == ["ER_H", "ER_H"]
    rb = I.robustesse(p)
    assert rb["+"][0] == "totale" and rb["-"][0] == "totale"
    assert s.couverture_plus == [{}] == s.couverture_moins


def test_syn_temoins_d_un_profil_divergent_avec_ER_H():
    """§ 3.10 : sur la ligne « des classes V et des classes F », les témoins sont ceux des classes certifiées ; une classe
    ER_H est certifiée des deux signes : son témoin est cité."""
    _, p, s = evaluer_gardes(cas_gardes([(0, "v1", "h1", "h2")]))
    assert s.temoins == [{"p": "v1"}]  # ER_H sous p = v1 ; la classe N n'est pas citée
    _, p, s = evaluer_gardes(cas_gardes([(0, "v1", "h1", "h2"), (0, "v2", "h1b", "h2b")]))
    assert s.temoins == [{"p": "v1"}, {"p": "v2"}]


def test_syn_refutations_citees_d_une_classe_ER_H():
    """§ 3.7, L22 et L6 : une classe ER_H est certifiée négativement : sa réfutation (la substitution X = la figure) est
    citée avec l'indice de sa classe ; une réfutation qui porte sur une autre substitution (une seconde figure B
    affirmée, A absent) reste citée, au titre de L6 ; aucune n'est fermée (σ non vide)."""
    _, p, s = evaluer_gardes(cas_gardes([(0, "v1", "h1", "h2")]))
    assert [(k, sorted(sg)) for k, sg in s.refutations] == [(0, ["X"])]
    assert not s.refutation_fermee
    c = cas_figures([("sup", "sup"), ("none", "aff")])  # une figure ER_H, une réfutation d'une autre substitution
    ev, cl, rl = evaluer_cas(c)
    assert rl.statut == "ER_H"
    ref = ev.principal.refutations
    assert len(ref) == 2 and {k for k, _ in ref} == {0}
    assert {tuple(sorted((v, tuple(sorted(x)) if isinstance(x, frozenset) else x) for v, x in sg.items()))
            for _, sg in ref} == {(("X", ("s0",)),), (("X", ("s1",)),)}


def test_syn_uniformite_d_un_profil_ER_H():
    """Déf. 7 (§ 3.9) : une même substitution certifiée dans chaque classe de ce signe : uniforme. ER_H certifie les deux
    signes : la même figure sous p = v1 et p = v2 (classes aux hypothèses différentes) est uniforme des deux signes ; deux
    figures différentes ne le sont pas (par cas) ; une classe ER_H seule est uniforme des deux signes."""
    _, _, s = evaluer_gardes(cas_gardes([(0, "v1", "h1", "h2")]))
    assert s.uniforme_plus and s.uniforme_moins  # la classe N n'est pas de ces signes
    _, _, s = evaluer_gardes(cas_gardes([(0, "v1", "h1", "h2"), (0, "v2", "h1b", "h2b")]))
    assert s.uniforme_plus and s.uniforme_moins
    _, _, s = evaluer_gardes(cas_gardes([(0, "v1", "h1", "h2"), (1, "v2", "h1b", "h2b")], figures=2))
    assert not s.uniforme_plus and not s.uniforme_moins


def test_deux_classes_ER_H_aux_familles_differentes_restent_deux():
    """§ 3.9 (déf. 6, L5) : deux interprétations de même résultat (même statut, mêmes hypothèses, mêmes lignes) sont dans
    la même classe ; deux ER_H aux familles différentes (h1/h2 sous v1, h1b/h2b sous v2) sont deux classes."""
    _, p, _ = evaluer_gardes(cas_gardes([(0, "v1", "h1", "h2"), (0, "v2", "h1b", "h2b")]))
    assert len(p.classes) == 2 and all(cl.statut == "ER_H" for cl in p.classes)
    fam = [({h.contenu for H in cl.resultat.hyps_plus for h in H}, {h.contenu for H in cl.resultat.hyps_moins for h in H})
           for cl in p.classes]
    assert fam == [({"h1"}, {"h2"}), ({"h1b"}, {"h2b"})]
    # et les mêmes hypothèses sous les deux valeurs : une seule classe
    _, p, _ = evaluer_gardes(cas_gardes([(0, "v1", "h1", "h2"), (0, "v2", "h1", "h2")]))
    assert len(p.classes) == 1 and p.classes[0].statut == "ER_H"


def test_cle_d_un_resultat_ER_H_distingue_les_familles():
    """§ 3.9 (déf. 6) : la clé d'une classe porte les deux familles d'un ER_H : deux résultats de même statut, mêmes
    hypothèses réunies, mêmes branches et mêmes lignes, dont les familles diffèrent (hyps_plus et hyps_moins échangées),
    n'ont pas la même clé ; les mêmes familles, la même clé."""
    P, M = frozenset({Hypothese(NATURE_A, "p")}), frozenset({Hypothese(NATURE_B, "m")})
    union = (P | M,)
    br = I.ResultatBranche("ER_H", (), (P,), (M,), True)

    def rl(hp, hm):
        return I.ResultatLocal("ER_H", union, (br,), True, hyps_plus=hp, hyps_moins=hm)
    assert rl((P,), (M,)).cle() == rl((P,), (M,)).cle()
    assert rl((P,), (M,)).cle() != rl((M,), (P,)).cle()
    assert rl((P,), (M,)).cle() != rl((P,), ()).cle()


# =============================================================================================================
# Le budget : un ER_H interrompu est « ? » (§ 3.7 (f), L3)
# =============================================================================================================

def test_budget_ER_H_interrompu_donne_inconnu():
    """§ 3.7, règle du budget et L3 : une classe interrompue est E si une solution certifiée sans hypothèse a été trouvée,
    R sous la condition de la règle, « ? » sinon ; ER_H, comme E_H, certifie sous hypothèses : interrompu, il est « ? »
    (NOYAU § 4.5 : on ne conclut pas « sous hypothèses » après une interruption). Les trois substitutions du cas (deux
    figures ER_H, une réfutation d'une troisième) coûtent trois unités : avec deux, le calcul est interrompu après
    avoir lu ER_H sur les deux premières."""
    c = cas_figures([("sup", "sup"), ("sup", "sup"), ("none", "sup")])
    complet = I.evaluer(c)
    assert complet.profils[RACINE].statuts() == ["ER_H"] and complet.principal.nom == "divergent"
    for budget in (1, 2):
        ev = I.evaluer(c, budget=budget)
        cl = ev.profils[RACINE].classes[0]
        assert cl.statut == "?" and not cl.resultat.complet, budget
        assert cl.resultat.branches[0].statut == "?" and not cl.resultat.branches[0].hyps_plus
        assert ev.principal.nom == "incomplet"
    # le même budget interrompt E_H en « ? » (L3)
    cE = cas_figures([("sup", "none"), ("sup", "none"), ("none", "sup")])
    assert I.evaluer(cE).profils[RACINE].statuts() == ["E_H"]
    assert I.evaluer(cE, budget=2).profils[RACINE].statuts() == ["?"]
    # un budget suffisant ne change rien
    assert I.evaluer(c, budget=3).profils[RACINE].statuts() == ["ER_H"]


def test_budget_ER_H_dans_une_branche_donne_inconnu():
    """§ 3.8 et § 3.7 (f) : une branche interrompue est « ? » et le consensus est « ? » (comme les autres statuts) ;
    {ER_H, ?} n'est jamais ER_H."""
    assert I.combiner_branches([branche("ER_H"), I.ResultatBranche("?", (), (), (), False)])[0] == "?"


# =============================================================================================================
# Le dual avec ses familles (proposition 3 ; § 3.7, L22)
# =============================================================================================================

def test_dual_familles():
    """Proposition 3 : le dual envoie ER_H sur ER_H en échangeant hyps_plus et hyps_moins ; E_H et R_H, qui ne portent
    qu'une famille, la portent de l'autre côté ; c'est une involution ; et le dual de l'exemple minimal (but A) est le
    résultat de l'exemple demandant B (but B)."""
    P, M = (frozenset({H_PLUS}),), (frozenset({H_MOINS}),)
    assert I.dual_familles("ER_H", P, M) == ("ER_H", M, P)
    assert I.dual_familles("E_H", P, ()) == ("R_H", (), P)
    assert I.dual_familles("R_H", (), M) == ("E_H", M, ())
    assert I.dual_familles("E", (), ()) == ("R", (), ())
    for st in ("ER_H", "E_H", "R_H", "E", "R", "B", "N"):
        a = I.dual_familles(st, P, M)
        assert I.dual_familles(*a) == (st, P, M), st
    _, _, rA = evaluer_cas(cas_figures([("sup", "sup")], but="A"))
    _, _, rB = evaluer_cas(cas_figures([("sup", "sup")], but="B"))
    st, hp, hm = I.dual_familles(rA.statut, rA.hyps_plus, rA.hyps_moins)
    assert st == rB.statut == "ER_H"
    assert natures(hp) == natures(rB.hyps_plus) and natures(hm) == natures(rB.hyps_moins)


def test_mesures_ER_H_contre_N_une_erreur_de_chaque_signe():
    """Déf. 12, décision confirmée : un système ER_H contre une référence N fait une erreur de chaque signe, comptées à
    part ; E contre N : une erreur positive seulement ; R contre N : une négative seulement."""
    m = I.mesures(["ER_H"], ["N"])
    assert m["e+_der"] == 1 and m["e-_der"] == 1
    m = I.mesures(["E"], ["N"])
    assert m["e+_der"] == 1 and m["e-_der"] == 0
    m = I.mesures(["R"], ["N"])
    assert m["e+_der"] == 0 and m["e-_der"] == 1
