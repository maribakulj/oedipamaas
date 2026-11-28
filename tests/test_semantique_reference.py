"""L'oracle de propriétés de la sémantique de référence (docs/LANGAGE_REFERENCE.md, § 6 ; étude
docs/INTERPRETATIONS_ADMISSIBLES.md, § 9.6, propriétés T1 à T24).

Il éprouve des PROPRIÉTÉS sur des cas tirés au hasard (graine fixe) et sur des exemples écrits ; il ne recopie
aucune table de décisions. Les propriétés que la version 1.1 de l'étude énonce trop fort sont testées sous leur
forme corrigée, et leur contre-exemple est un test (« Ce que l'interpréteur a révélé », § 7 du document).
"""
from __future__ import annotations

import itertools
import random
import sys
from collections import Counter
from dataclasses import replace
from pathlib import Path

import pytest

ICI = Path(__file__).resolve().parent
sys.path.insert(0, str(ICI.parent))
sys.path.insert(0, str(ICI))

from semantique_reference import formation, inclusion, interprete as I, json_concret as J  # noqa: E402
from semantique_reference.syntaxe import *  # noqa: E402,F401,F403
from semantique_reference.json_concret import exclusion, exclusion_conjointe, implication  # noqa: E402
from semantique_reference_gen import CONCEPTS, affaiblir, tirer_cas, tirer_description, tirer_K  # noqa: E402

import os  # noqa: E402

N = int(os.environ.get("SEMREF_N", "60"))  # cas tirés par propriété
GRAINE = int(os.environ.get("SEMREF_GRAINE", "20261128"))  # graine fixée ; la variable sert aux essais


def cas_tires(n=N, graine=GRAINE, **kw):
    rng = random.Random(graine)
    out = []
    while len(out) < n:
        c = tirer_cas(rng, **kw)
        assert formation.verifier(c) == [], [str(d) for d in formation.verifier(c)]
        out.append(c)
    return out


CAS = cas_tires()


def statuts_par_i(ev_profil):
    return {tuple(sorted(i.items())): c.statut for c in ev_profil.classes for i in c.interpretations}


# =============================================================================================================
# Outils : l'énumération exhaustive des substitutions (la définition, sans la recherche par arbres)
# =============================================================================================================

def statut_par_enumeration(base, Dl, ctx):
    """Le statut local par la définition : toutes les substitutions partielles des variables libres (chaque
    variable non liée ou liée à une classe de sa sorte), chacune évaluée par `ligne` (déf. 5)."""
    sortes = dict(Dl.variables)
    sortes.update(I.sortes_de(Dl.suffisante))
    sortes.update(I.sortes_de(Dl.necessaire))
    variables = sorted(I.libres(Dl.suffisante) | I.libres(Dl.necessaire))
    doms = []
    for v in variables:
        if sortes.get(v) == "contexte":
            doms.append([None] + list(base.contextes))
        else:
            doms.append([None] + base.classes(sortes.get(v)))
    sels = [frozenset(v for f in S for v in I.libres(f)) & set(I.libres(Dl.suffisante))
            for S in I.selections(Dl.suffisante)]
    lignes = []
    for valeurs in itertools.product(*doms):
        s = {v: x for v, x in zip(variables, valeurs) if x is not None}
        lignes.append(I.ligne(base, Dl, s, ctx, sortes, solution=frozenset(s) in sels))
    return I.statut_local(lignes)[0]


# =============================================================================================================
# T1 à T3 : l'espace d'interprétation
# =============================================================================================================

def test_T1_I_est_exactement_les_interpretations_sans_violation():
    """T1 : I = { i ∈ Ω : aucune contrainte dure violée } ; il ne dépend d'aucune préférence."""
    for c in CAS:
        pts = I.points_du_cas(c)
        cs = I.contraintes_du_cas(c)
        attendu = {tuple(sorted(i.items())) for i in I.omega(pts) if all(not I.viole(i, k) for k in cs)}
        calcule = {tuple(sorted(i.items())) for i in I.interpretations_admissibles(c)}
        assert calcule == attendu
        sans_pref = replace(c, description=replace(c.description, preferences=()))
        assert {tuple(sorted(i.items())) for i in I.interpretations_admissibles(sans_pref)} == attendu


def test_T2_independance_de_D_et_de_Delta():
    """T2 : aucune contrainte dure ne couple P_D et P_Δ (RF12) ; I = I_D × I_Δ."""
    for c in CAS:
        pD = {p.id for p in c.description.points}
        pQ = {p.id for p in c.definition.points}
        for k in I.contraintes_du_cas(c):
            pts = {p for comb in k.interdits for (p, _) in comb}
            assert not (pts & pD and pts & pQ)
        Ic = {tuple(sorted(i.items())) for i in I.interpretations_admissibles(c)}
        ID = {tuple(sorted((p, v) for p, v in i.items() if p in pD)) for i in I.interpretations_admissibles(c)}
        IQ = {tuple(sorted((p, v) for p, v in i.items() if p in pQ)) for i in I.interpretations_admissibles(c)}
        assert len(Ic) == len(ID) * len(IQ)
    # une contrainte qui couple D et Δ est une faute de formation
    c = CAS[0]
    D = replace(c.description, points=(Point("pD", "D", "sens", ("c0", "c1")),))
    Dl = replace(c.definition, points=(Point("pQ", "Δ", "sens", ("c0", "c1")),),
                 contraintes=(exclusion_conjointe("mauvaise", [{"pD": "c0", "pQ": "c1"}], "même lemme"),))
    assert any(d.regle == 12 for d in formation.verifier(replace(c, description=D, definition=Dl)))


def test_T3_une_valeur_par_point_dans_chaque_preuve():
    """T3 : aucune preuve n'emploie deux valeurs d'un même point. Chaque preuve est relative à une interprétation
    (une fonction) ; on vérifie de plus qu'aucune assertion qu'elle cite n'est absente sous une interprétation de
    sa classe (sa garde y est vraie)."""
    for c in CAS:
        asser = {a.id: a for a in c.description.assertions}
        for p in I.profils(c).values():
            for cl in p.classes:
                for i in cl.interpretations:
                    assert set(i) == {q.id for q in I.points_du_cas(c)}
                # déf. 8 : la classe est certifiée par une preuve par cas, une preuve sous chaque i de la classe
                for i, r in zip(cl.interpretations, cl.resultats):
                    assert r.cle() == cl.resultat.cle()
                    for b in r.branches:
                        for l in b.lignes:
                            for o in l.preuves_plus + l.preuves_moins:
                                for a in o.bases:
                                    assert I.garde_vraie(asser[a].garde, i), (a, i)


# =============================================================================================================
# T4 à T6 : le résultat local, le profil, dérivation et certification
# =============================================================================================================

def test_T4_resultat_local_resolution_et_enumeration():
    """T4 (lu au § 3.12 : l'oracle du noyau 0.3 ne peut pas évaluer les constructions nouvelles, et
    l'indépendance interdit de l'importer) : pour toute i, le résultat local est (a) celui de la description et de
    la définition résolues ρ(D, i), ρ(Δ, i), évaluées comme un cas sans point, et (b) celui de l'énumération
    exhaustive des substitutions (la définition), égal à celui de la recherche par arbres."""
    for c in CAS[:40]:
        for i in I.interpretations_admissibles(c):
            r = I.resultats_sous_i(c, i, I.Budget(None))
            sans_points = Cas("sans", I.resoudre_description(c.description, i),
                              I.resoudre_definition(c.definition, {}) if not c.definition.points else
                              I.resoudre_definition(c.definition, i), c.connaissances)
            r2 = I.resultats_sous_i(sans_points, {}, I.Budget(None))
            assert {k: v.cle() for k, v in r.items()} == {k: v.cle() for k, v in r2.items()}
            D = I.resoudre_description(c.description, i)
            Dl = I.resoudre_definition(c.definition, i)
            if len(I.libres(Dl.suffisante)) > 2:
                continue
            for w, b in zip(I.branches_de(D), r[RACINE].branches):
                base = I.Base(D, c.connaissances, w)
                assert statut_par_enumeration(base, Dl, RACINE) == b.statut, (c, i, w)


def test_T5_le_profil_partitionne_I():
    """T5 : les classes partitionnent I ; chaque classe porte, par contexte et par substitution, la valeur de
    Belnap, les hypothèses et leur nature, les énonciateurs, la certification, la complétude."""
    for c in CAS:
        for p in I.profils(c).values():
            vues = [tuple(sorted(i.items())) for cl in p.classes for i in cl.interpretations]
            assert sorted(vues) == sorted(tuple(sorted(i.items())) for i in p.I)
            assert len(set(vues)) == len(vues)
            for cl in p.classes:
                r = cl.resultat
                assert r.statut in I.STATUTS_LOCAUX and isinstance(r.complet, bool)
                for H in r.hypotheses:
                    assert all(h.nature in NATURES_NON_LEXICALES for h in H)
                for b in r.branches:
                    for l in b.lignes:
                        assert l.valeur in "NVFB" and isinstance(l.enonc_plus, frozenset)


def test_T6_certification_et_derivation():
    """T6 : C⁺ ⇒ D⁺ et non D⁻ ; C⁻ ⇒ D⁻ et non D⁺ ; val = (D⁺, D⁻). Sous des hypothèses H, de même avec D⁺_H,
    D⁻_H (déf. 2, lue sur la requête entière : § 3.6)."""
    for c in CAS:
        for i in I.interpretations_admissibles(c):
            D = I.resoudre_description(c.description, i)
            Dl = I.resoudre_definition(c.definition, i)
            sortes = dict(Dl.variables)
            sortes.update(I.sortes_de(Dl.suffisante))
            for w in I.branches_de(D):
                base = I.Base(D, c.connaissances, w)
                for ctx in I.contextes_figuratifs(D):
                    b = I.evaluer_branche(base, Dl, ctx, I.Budget(None))
                    for l in b.lignes:
                        s = l.sigma_dict()
                        pos = I.options_pos(base, Dl.suffisante, s, ctx, sortes)
                        neg = I.options_neg(base, Dl.necessaire, s, ctx, sortes)
                        assert l.d_plus == any(not o.hyps for o in pos)
                        assert l.d_moins == any(not o.hyps for o in neg)
                        assert l.valeur == {(0, 0): "N", (1, 0): "V", (0, 1): "F", (1, 1): "B"}[
                            (int(l.d_plus), int(l.d_moins))]
                        for H in l.c_plus:
                            assert any(o.hyps <= H for o in pos) and not any(o.hyps <= H for o in neg)
                            if not H:
                                assert l.d_plus and not l.d_moins
                        for H in l.c_moins:
                            assert any(o.hyps <= H for o in neg) and not any(o.hyps <= H for o in pos)
                            if not H:
                                assert l.d_moins and not l.d_plus


# =============================================================================================================
# T7, T8 : la table et son dual ; la déf. 11
# =============================================================================================================

LOCAUX = ["E", "E_H", "R", "R_H", "B", "NC+", "NC-", "N", "?"]


def profils_abstraits(jusqua=4):
    for k in range(jusqua + 1):
        yield from itertools.combinations_with_replacement(LOCAUX, k)


def test_T8_la_table_est_une_fonction():
    """T8 : les douze conditions de la déf. 10 s'excluent deux à deux et couvrent tout profil (énumération des
    profils sur les neuf statuts locaux, NC avec son signe, jusqu'à quatre classes)."""
    n = 0
    for prof in profils_abstraits(4):
        assert len(I.lignes_satisfaites(list(prof))) == 1, prof
        n += 1
    assert n == sum(len(list(itertools.combinations_with_replacement(LOCAUX, k))) for k in range(5))


def test_T7_aucune_priorite_de_signe():
    """T7 (proposition 3) : Syn(Π̄) est le dual de Syn(Π), sur tous les profils abstraits et sur les cas tirés."""
    for prof in profils_abstraits(4):
        nom, ligne, signe = I.syn_statuts(list(prof))
        nom2, _, signe2 = I.syn_statuts(I.dual_statuts(list(prof)))
        assert (nom2, signe2) == I.dual_nom(nom, signe)
    for c in CAS:
        for p in I.profils(c).values():
            st = p.statuts()
            assert I.dual_nom(*[x for k, x in enumerate(I.syn_statuts(st)) if k != 1]) == \
                tuple(x for k, x in enumerate(I.syn_statuts(I.dual_statuts(st))) if k != 1)


def test_def11_ordre_et_garanties():
    """Déf. 11 : les relations de couverture écrites ; et ce que chaque coordonnée garantit, vérifié sur tous les
    profils abstraits : ℓ⁺ ≥ 1 ⇒ une classe a une dérivation positive ; ℓ⁺ ≥ 2 ⇒ une classe est certifiée
    positivement ; ℓ⁺ = 3 ⇒ toutes, sans hypothèse ; de même pour ℓ⁻."""
    inf = I.inferieur
    assert inf(("etablie_sous_hypotheses", ""), ("etablie", "")) and not inf(("etablie", ""), ("divergent", ""))
    assert not inf(("divergent", ""), ("etablie", "")) and inf(("contradictoire", ""), ("divergent", ""))
    assert inf(("non_certifiee", "+"), ("contradictoire", "")) and inf(("inconnue", ""), ("non_certifiee", "-"))
    assert I.niveaux("aucune_interpretation") == (0, 0)  # jamais (3, 3) : pas de certification par vacuité
    derive = {"+": {"E", "E_H", "B", "NC+"}, "-": {"R", "R_H", "B", "NC-"}}
    certifie = {"+": {"E", "E_H"}, "-": {"R", "R_H"}}
    for prof in profils_abstraits(4):
        nom, _, s = I.syn_statuts(list(prof))
        for signe, l in zip("+-", I.niveaux(nom, s)):
            if l >= 1:
                assert set(prof) & derive[signe], (prof, nom)
            if l >= 2:
                assert set(prof) & certifie[signe]
            if l == 3:
                assert set(prof) == ({"E"} if signe == "+" else {"R"})
    # Syn n'est pas monotone pour ≤ (§ 3.5 de l'étude) : {B, N} donne (1, 1), {B, V} donne (2, 0)
    assert I.niveaux(*I.syn_statuts(["B", "N"])[::2]) == (1, 1)
    assert I.niveaux(*I.syn_statuts(["B", "E"])[::2]) == (2, 0)


# =============================================================================================================
# T9, T10 : l'ensemble vide, les témoins
# =============================================================================================================

def vider(c):
    """Une contrainte qui exclut toutes les valeurs d'un point de D (et, sans point, la combinaison vide)."""
    p = Point("pz", "D", "structure", ("u", "v"))
    D = replace(c.description, points=c.description.points + (p,),
                contraintes=c.description.contraintes + (exclusion("tout", "pz", ["u", "v"], "test"),))
    return replace(c, description=D)


def test_T9_ensemble_vide():
    """T9 : I = ∅ ⇒ Syn = aucune_interpretation, aucune preuve, aucune notation écartée de l'index."""
    for c in CAS[:20]:
        v = vider(c)
        ev = I.evaluer(v)
        assert ev.principal.nom == "aucune_interpretation" and ev.principal.niveaux == (0, 0)
        assert all(not p.classes for p in ev.profils.values())
        assert not ev.principal.couverture_plus and not ev.principal.couverture_moins and not ev.principal.temoins
        assert I.index_retient(v)


def test_T10_temoins():
    """T10 : toute affirmation partielle cite un témoin qui satisfait toutes les contraintes de sa composante ;
    aucune classe n'a un domaine vide ; chaque cylindre cité est habité."""
    for c in CAS:
        cs = I.contraintes_du_cas(c)
        ev = I.evaluer(c)
        for ctx, s in ev.statuts.items():
            p = ev.profils[ctx]
            for t in s.temoins:
                assert not any(I.viole(t, k) for k in cs)
            for cl in p.classes:
                assert cl.interpretations
                for h in cl.cylindres:
                    assert any(I.dans_cylindre(i, h) for i in cl.interpretations)
                    assert all(any(tuple(sorted(i.items())) == tuple(sorted(j.items())) for j in cl.interpretations)
                               for i in p.I if I.dans_cylindre(i, h))
            for h in s.couverture_plus + s.couverture_moins:
                assert any(I.dans_cylindre(i, h) for i in p.I)


# =============================================================================================================
# T11 à T13 : contraintes ajoutées, monotonie, natures
# =============================================================================================================

PREVU = {  # § 8.4 de l'étude, complété (§ 7 du document) : ce que devient Syn quand une contrainte réduit I
    "etablie": {"etablie", "aucune_interpretation"},
    "ecartee": {"ecartee", "aucune_interpretation"},
    "inconnue": {"inconnue", "aucune_interpretation"},
    "aucune_interpretation": {"aucune_interpretation"},
}


def test_T11_ajout_d_une_contrainte():
    """T11 : si I' ⊆ I, le statut local de chaque i ∈ I' est inchangé, et Syn(Π') est l'un de ceux que le § 8.4
    prévoit ; un profil divergent peut devenir, de plus, contradictoire, non_certifiee ou inconnue (test suivant)."""
    rng = random.Random(GRAINE + 11)
    for c in CAS:
        pts = c.description.points
        if not pts:
            continue
        p = rng.choice(pts)
        c2 = replace(c, description=replace(c.description, contraintes=c.description.contraintes +
                                            (exclusion("ajoutee", p.id, [rng.choice(p.domaine)], "test"),)))
        ev1, ev2 = I.evaluer(c), I.evaluer(c2)
        s1, s2 = statuts_par_i(ev1.profils[RACINE]), statuts_par_i(ev2.profils[RACINE])
        assert set(s2) <= set(s1)
        for i, st in s2.items():
            assert st == s1[i]
        n1, n2 = ev1.principal.nom, ev2.principal.nom
        if n1 in PREVU:
            assert n2 in PREVU[n1], (n1, n2)
        assert n2 == I.syn_statuts([s1[i] for i in s2])[0]


def test_T11_revele_divergent_peut_devenir_contradictoire():
    """Ce que l'interpréteur a révélé (§ 7) : le § 8.4 de l'étude dit qu'un profil divergent « peut devenir
    n'importe quel statut d'un seul signe, ou le rester ». Il peut aussi devenir contradictoire (ou non_certifiee,
    inconnue) : les classes des deux signes disparaissent, une classe B reste."""
    assert I.syn_statuts(["E", "R", "B"])[0] == "divergent"
    assert I.syn_statuts(["B"])[0] == "contradictoire"
    c = exemple_divergent(avec_b=True)
    ev = I.evaluer(c)
    assert ev.principal.nom == "divergent"
    c2 = replace(c, description=replace(c.description, contraintes=(exclusion("x", "cadre", ["intrinseque",
                                                                                              "spectateur"], "t"),)))
    assert I.evaluer(c2).principal.nom == "contradictoire"


def ajouter_assertion(rng, c):
    D = c.description
    refs = [r.id for r in D.referents if r.sorte == "individu"]
    x = rng.choice(refs)
    r = rng.random()
    if r < 0.3:
        a = Assertion("ajout", propriete(x, rng.choice(CONCEPTS)))
    elif r < 0.6:
        a = Assertion("ajout", Proposition((), (type_(x, rng.choice(CONCEPTS)),)), Qualification(polarite="neg"))
    elif r < 0.8:
        a = Assertion("ajout", nom(x, rng.choice(["k1", "k2", "k3"])))
    else:
        a = Assertion("ajout", Proposition((("z", "individu"),), (type_(Var("z"), rng.choice(CONCEPTS)),)),
                      Qualification(polarite="neg"))
    return replace(c, description=replace(D, assertions=D.assertions + (a,)))


def ajouter_k(rng, c):
    K = c.connaissances
    a, b = rng.sample(CONCEPTS, 2)
    r = rng.random()
    if r < 0.4:
        e = Inclusion("k_ajout", a, b, Source("test"))
    elif r < 0.7:
        e = Incompatibilite("k_ajout", a, b, rng.choice(["type", "propriete"]), ("porteur", "contexte"),
                            source=Source("test"))
    else:
        e = Regle("k_ajout", "implication", (("x", "individu"),), (type_(Var("x"), a),),
                  (propriete(Var("x"), b),), Source("test"))
    return replace(c, connaissances=Connaissances(K.version, K.entrees + (e,)))


def test_T12_monotonie_des_derivations():
    """T12 (lemme 1) : ajouter une entrée à K ou une assertion au graphe ne retire aucun D⁺ ni aucun D⁻, à i, w,
    contexte et σ fixés."""
    rng = random.Random(GRAINE + 12)
    for c in CAS:
        c2 = ajouter_assertion(rng, c) if rng.random() < 0.5 else ajouter_k(rng, c)
        assert formation.verifier(c2) == []
        for i in I.interpretations_admissibles(c):
            D1, D2 = I.resoudre_description(c.description, i), I.resoudre_description(c2.description, i)
            Dl = I.resoudre_definition(c.definition, i)
            sortes = dict(Dl.variables)
            sortes.update(I.sortes_de(Dl.suffisante))
            for w in I.branches_de(D1):
                b1, b2 = I.Base(D1, c.connaissances, w), I.Base(D2, c2.connaissances, w)
                for ctx in I.contextes_figuratifs(D1):
                    for l in I.evaluer_branche(b1, Dl, ctx, I.Budget(None)).lignes:
                        l2 = I.ligne(b2, Dl, l.sigma_dict(), ctx, sortes, l.solution)
                        assert l2.d_plus >= l.d_plus and l2.d_moins >= l.d_moins, (l, l2)


def natures_possibles(c):
    out = {a.qualification.nature for a in c.description.assertions if a.qualification.modalite == "supposee"}
    for e in c.connaissances.entrees:
        if getattr(e, "statut", "attestee") != "attestee":
            out.add("connaissance_non_attestee")
        if isinstance(e, Typique):
            out.add("connaissance_typique")
        if isinstance(e, DefinitionK) and "non_etablie" in (e.statut_suffisance, e.statut_necessite):
            out.add("abduction")
    if "non_etablie" in (c.definition.statut_suffisance, c.definition.statut_necessite):
        out.add("abduction")
    return out


def test_T13_conservation_des_natures():
    """T13 : le multiensemble des (nature, contenu) du résultat est l'union de ceux des classes ; aucune nature ne
    change (chaque nature vient d'une assertion supposée ou d'une entrée de K de cette nature) ; les choix de
    lecture ne viennent que des points (ils ne sont jamais des hypothèses du résultat)."""
    for c in CAS:
        possibles = natures_possibles(c)
        ev = I.evaluer(c)
        for ctx, s in ev.statuts.items():
            p = ev.profils[ctx]
            attendu = Counter((k, h) for k, cl in enumerate(p.classes) for H in cl.resultat.hypotheses for h in H)
            assert Counter(s.hypotheses) == attendu
            for (_, h) in s.hypotheses:
                assert h.nature != "lecture" and h.nature in possibles, (h, possibles)
            for h in s.couverture_plus + s.couverture_moins:
                assert set(h) <= {q.id for q in I.points_du_cas(c)}
        # une assertion supposée garde sa nature et son contenu jusqu'au résultat
        for a in c.description.assertions:
            if a.qualification.modalite == "supposee":
                for p in ev.profils.values():
                    for cl in p.classes:
                        for H in cl.resultat.hypotheses:
                            for h in H:
                                if h.contenu == (a.qualification.contenu or a.id):
                                    assert h.nature == a.qualification.nature


def test_T14_hypotheses_d_une_autre_nature():
    """T14 : une couverture totale dont une classe a des hypothèses non lexicales n'est jamais etablie ni
    ecartee."""
    for c in CAS:
        for s, p in zip(I.evaluer(c).statuts.values(), I.evaluer(c).profils.values()):
            if any(cl.resultat.hypotheses and any(cl.resultat.hypotheses) for cl in p.classes):
                assert s.nom not in ("etablie", "ecartee")
    for prof in profils_abstraits(3):
        if "E_H" in prof:
            assert I.syn_statuts(list(prof))[0] != "etablie"
        if "R_H" in prof:
            assert I.syn_statuts(list(prof))[0] != "ecartee"


def test_T15_profils_meles():
    """T15 : V et F ⇒ divergent, avec deux preuves de signes opposés ; une seule classe B n'est jamais
    divergent."""
    for c in CAS + [exemple_divergent()]:
        ev = I.evaluer(c)
        for ctx, s in ev.statuts.items():
            st = set(ev.profils[ctx].statuts())
            if st & {"E", "E_H"} and st & {"R", "R_H"} and "?" not in st:
                assert s.nom == "divergent" and s.couverture_plus and s.couverture_moins
                p = ev.profils[ctx]
                assert any(l.c_plus for cl in p.classes for b in cl.resultat.branches for l in b.lignes)
                assert any(l.c_moins for cl in p.classes for b in cl.resultat.branches for l in b.lignes)
            if st == {"B"}:
                assert s.nom == "contradictoire"


def test_T16_substitutions():
    """T16 : etablie ⇔ chaque classe a une solution certifiée sans hypothèse ; « uniforme » ⇔ une mention commune
    par variable à travers les classes (et les branches)."""
    for c in CAS + [exemple_rq010(), exemple_co018_alternative()]:
        ev = I.evaluer(c)
        p, s = ev.profils[RACINE], ev.principal
        certif = all(any(l.c_plus and frozenset() in l.c_plus for l in b.lignes)
                     for cl in p.classes for b in cl.resultat.branches)
        assert (s.nom == "etablie") == (bool(p.classes) and certif)
        # « uniforme » recalculé indépendamment : une mention par variable, essayée parmi toutes les mentions
        cas_ = []
        for cl in p.classes:
            if cl.statut in ("E", "E_H"):
                for r in cl.resultats:
                    for b in r.branches:
                        cas_.append([dict(l.sigma) for l in b.lignes if l.c_plus])
        mentions = sorted({r.id for r in c.description.referents})
        variables = sorted({v for sols in cas_ for sol in sols for v in sol})
        commun = False
        if cas_ and all(cas_):
            for mu in itertools.product(mentions, repeat=len(variables)):
                m = dict(zip(variables, mu))
                if all(any(all(m[v] in sol[v] for v in sol) and set(sol) <= set(m) for sol in sols) for sols in cas_):
                    commun = True
                    break
        assert s.uniforme_plus == commun or not all(set(sol) == set(variables) for sols in cas_ for sol in sols)


# =============================================================================================================
# T17 à T20 : composantes, interruption, préférences, index
# =============================================================================================================

def test_T17_calcul_par_composantes():
    """T17 : le profil calculé par composantes (les seuls points dont dépend le résultat, fermés par les
    contraintes) est égal au profil calculé sur Ω entier."""
    rng = random.Random(GRAINE + 17)
    for c in CAS[:40]:
        # un point inutile, relié ou non par une contrainte à un point utile
        q = Point("inutile", "D", "portee", ("x", "y", "z"))
        cs = list(c.description.contraintes)
        if c.description.points and rng.random() < 0.6:
            p = rng.choice(c.description.points)
            cs.append(exclusion_conjointe("lien", [{p.id: p.domaine[0], "inutile": "x"}], "test"))
        c2 = replace(c, description=replace(c.description, points=c.description.points + (q,), contraintes=tuple(cs)))
        a = I.profils(c2)
        b = I.profils(c2, par_composantes=True)
        for ctx in a:
            assert statuts_par_i(a[ctx]) == statuts_par_i(b[ctx])
            assert [sorted(tuple(sorted(i.items())) for i in cl.interpretations) for cl in a[ctx].classes] == \
                   [sorted(tuple(sorted(i.items())) for i in cl.interpretations) for cl in b[ctx].classes]


def test_T18_interruption():
    """T18 : avec un budget tiré, une classe interrompue sans solution ni réfutation certifiée est ?, et Syn =
    incomplet ; une classe E (ou R) trouvée avant l'interruption reste E (ou R) ; aucune autre conclusion."""
    rng = random.Random(GRAINE + 18)
    vus = Counter()
    for c in CAS:
        complet = statuts_par_i(I.profils(c)[RACINE])
        budget = rng.randint(0, 12)
        ev = I.evaluer(c, budget=budget)
        partiel = statuts_par_i(ev.profils[RACINE])
        assert set(partiel) == set(complet)
        for i, st in partiel.items():
            assert st in (complet[i], "?"), (st, complet[i])
            if st in ("E", "R"):
                assert complet[i] == st
            vus[st == "?"] += 1
        if "?" in partiel.values():
            assert ev.principal.nom == "incomplet" and ev.principal.niveaux == (0, 0)
    assert vus[True] and vus[False]


def test_T19_preferences():
    """T19 : permuter ou retirer les préférences ne change ni I, ni le profil, ni Syn ; seul l'ordre des classes
    et des cylindres change (l'ensemble des cylindres maximaux est canonique)."""
    rng = random.Random(GRAINE + 19)
    for c in CAS:
        prefs = [replace(p, ordre=tuple(rng.sample(p.ordre, len(p.ordre)))) for p in c.description.preferences]
        for autre in (replace(c, description=replace(c.description, preferences=tuple(prefs))),
                      replace(c, description=replace(c.description, preferences=()))):
            e1, e2 = I.evaluer(c), I.evaluer(autre)
            for ctx in e1.profils:
                assert statuts_par_i(e1.profils[ctx]) == statuts_par_i(e2.profils[ctx])
                assert e1.statuts[ctx].nom == e2.statuts[ctx].nom
                cyl = lambda s: sorted(tuple(sorted(h.items())) for h in s)
                assert cyl(e1.statuts[ctx].couverture_plus) == cyl(e2.statuts[ctx].couverture_plus)
                assert cyl(e1.statuts[ctx].couverture_moins) == cyl(e2.statuts[ctx].couverture_moins)


def test_T20_index():
    """T20 : toute notation dont une classe admissible a une valeur V, B ou NC est retenue ; une réfutation ne
    retire aucune notation (ajouter une négation ne fait jamais passer de « retenue » à « écartée »)."""
    rng = random.Random(GRAINE + 20)
    for c in CAS:
        ev = I.evaluer(c)
        derive = any(l.d_plus for p in ev.profils.values() for cl in p.classes for b in cl.resultat.branches
                     for l in b.lignes)
        if derive:
            assert I.index_retient(c)
        if I.index_retient(c):
            D = c.description
            x = next(r.id for r in D.referents if r.sorte == "individu")
            neg = Assertion("neg_ajout", Proposition((), (type_(x, rng.choice(CONCEPTS)),)),
                            Qualification(polarite="neg"))
            assert I.index_retient(replace(c, description=replace(D, assertions=D.assertions + (neg,))))
    # avec une condition nécessaire plus faible que la suffisante (RF26), l'index lit la nécessaire
    c = exemple_definition_structuree()
    assert I.index_retient(c)


# =============================================================================================================
# T21, T22 : les propositions de sûreté, par le comparateur d'inclusion
# =============================================================================================================

def paires(n=80, graine=GRAINE + 21):
    rng = random.Random(graine)
    out = []
    while len(out) < n:
        c = tirer_cas(rng, avec_points=False, avec_non=False)
        Q1 = c.definition.suffisante
        if len(out) % 3 == 2:  # une paire indépendante : le plus souvent `non`
            autre = tirer_cas(rng, avec_points=False, avec_non=False).definition
            if autre.variables != c.definition.variables:
                continue
            Q2 = autre.suffisante
        else:
            Q2 = affaiblir(rng, Q1, c.connaissances)
        out.append((c, Q1, Q2))
    return out


def test_comparateur_contre_exemples_et_raisons():
    """Le comparateur (§ 3.11) : chaque `non` a un contre-exemple où Q1 est établie et Q2 ne l'est pas ; chaque
    `oui` a un homomorphisme par sélection de Q1 ; la réflexivité vaut hors de ⊥."""
    raisons = Counter()
    for (c, Q1, Q2) in PAIRES:
        s = dict(c.definition.variables)
        v = inclusion.comparer(Q1, Q2, c.connaissances, s, s)
        raisons[(v.verdict, v.raison.split(" (")[0].split(" :")[0])] += 1
        if v.verdict == "non":
            ce = v.contre_exemple
            sortes = {k.replace("r_", ""): x for k, x in s.items()}
            assert not inclusion.etablie_sur(ce, Q2, c.connaissances, s)
        if v.verdict == "oui":
            assert sorted(a for (a, _, _) in v.homomorphismes) == list(range(len(I.selections(Q1))))
        assert inclusion.comparer(Q1, Q1, c.connaissances, s, s).verdict in ("oui", "indetermine")
    assert raisons


PAIRES = paires()


def test_T21_surete_positive():
    """T21 (proposition 1, point 1) : pour des paires avec oui(Q1 ⊆ Q2) et des descriptions tirées,
    D⁺(Q1, σ) ⇒ D⁺(Q2, σ ∘ h⁺)."""
    rng = random.Random(GRAINE + 210)
    verdicts = Counter()
    for (c, Q1, Q2) in PAIRES:
        s = dict(c.definition.variables)
        v = inclusion.comparer(Q1, Q2, c.connaissances, s, s)
        verdicts[v.verdict] += 1
        if v.verdict != "oui":
            continue
        for _ in range(3):
            D = tirer_description(rng, avec_points=False, avec_alternative=False)
            base = I.Base(D, c.connaissances, {})
            for n1, S1 in enumerate(I.selections(Q1)):
                h = next(hh for (a, b, hh) in v.homomorphismes if a == n1)
                for (sigma, _) in I.solutions_selection(base, S1, {}, RACINE, s):
                    if any(not o.hyps for o in I.options_pos(base, Q1, sigma, RACINE, s)):
                        assert any(not o.hyps for o in I.options_pos(base, Q2, inclusion.composer(sigma, h),
                                                                     RACINE, s)), (Q1, Q2, sigma)
    assert verdicts["oui"] >= 20 and verdicts["non"] >= 5, verdicts


def test_T22_surete_negative():
    """T22 (proposition 2, point 1) : pour des paires avec oui(Q2 ⊆ Q1), D⁻(Q1, τ ∘ h⁻) ⇒ D⁻(Q2, τ), sélection
    par sélection (h⁻ dépend de la sélection de Q2), pour τ close par les identités de Q2 (h⁻ envoie une variable
    sur une classe de `meme` : § 3.12, révélé par la graine 5) ; et le lion ailé, écrit à la main, pour la paire de
    sens contraire (test_lion_aile)."""
    rng = random.Random(GRAINE + 220)
    n_ok = 0
    for (c, Q1, Q2) in PAIRES:
        # ici Q2 ⊆ Q1 se lit : la plus forte (Q1 tirée) est incluse dans l'affaiblie (Q2) ; on renomme
        forte, faible = Q1, Q2
        s = dict(c.definition.variables)
        v = inclusion.comparer(forte, faible, c.connaissances, s, s)
        if v.verdict != "oui":
            continue
        for _ in range(3):
            D = tirer_description(rng, avec_points=False, avec_alternative=False)
            base = I.Base(D, c.connaissances, {})
            for n2, S2 in enumerate(I.selections(forte)):
                h = next(hh for (a, b, hh) in v.homomorphismes if a == n2)
                vars2 = sorted({x for f in S2 for x in I.libres(f)})
                doms = [[None] + base.classes("individu") for _ in vars2]
                rep = inclusion._normaliser(S2).rep
                for valeurs in itertools.product(*doms):
                    tau = {x: y for x, y in zip(vars2, valeurs) if y is not None}
                    # τ clos par les identités de Q2 (§ 3.12) : h⁻ envoie une variable sur une classe de `meme`
                    if any(tau.get(a) != tau.get(b) for a in vars2 for b in vars2 if rep.get(a) == rep.get(b)):
                        continue
                    if any(not o.hyps for o in I.options_neg(base, faible, inclusion.composer(tau, h), RACINE, s)):
                        assert any(not o.hyps for o in I.refutations_selection(base, S2, tau, RACINE, s)), \
                            (forte, faible, tau)
                        n_ok += 1
    assert n_ok >= 10


# =============================================================================================================
# T23, T24 : certification séparée, contextes
# =============================================================================================================

def test_T23_certification_separee():
    """T23, sous sa forme corrigée (§ 7) : sur un K tiré et un K plus petit, chaque C⁺ du petit K a, dans le
    grand, la valeur V ou B (D⁺ se garde : lemme 1), jamais F ni N ; de même pour C⁻. L'étude écrit « C⁺ ou B » :
    c'est trop fort, voir test_T23_revele_certification_vers_nc."""
    rng = random.Random(GRAINE + 23)
    for c in CAS:
        petit = Connaissances("petit", tuple(e for e in c.connaissances.entrees if rng.random() < 0.5))
        cp = replace(c, connaissances=petit)
        for i in I.interpretations_admissibles(c):
            D = I.resoudre_description(c.description, i)
            Dl = I.resoudre_definition(c.definition, i)
            sortes = dict(Dl.variables)
            sortes.update(I.sortes_de(Dl.suffisante))
            for w in I.branches_de(D):
                bp, bg = I.Base(D, petit, w), I.Base(D, c.connaissances, w)
                for ctx in I.contextes_figuratifs(D):
                    for l in I.evaluer_branche(bp, Dl, ctx, I.Budget(None)).lignes:
                        lg = I.ligne(bg, Dl, l.sigma_dict(), ctx, sortes, l.solution)
                        if frozenset() in l.c_plus:
                            assert lg.valeur in ("V", "B")
                        if frozenset() in l.c_moins:
                            assert lg.valeur in ("F", "B")


def test_T23_revele_certification_vers_nc():
    """Ce que l'interpréteur a révélé (§ 7) : un C⁺ du petit K peut devenir, dans le grand, une vérité non
    certifiée (NC⁺) : une incompatibilité ajoutée nie la prémisse de l'appui (« une lionne ») sans nier la
    requête (« un félin »). La valeur reste V : ni F, ni N, ni B."""
    D = Description("lionne", referents=(Referent("x", "individu", introduit_par="a1"),),
                    assertions=(Assertion("a1", type_("x", "lionne")), Assertion("a2", propriete("x", "male"))))
    Q = Definition("felin", variables=(("X", "individu"),), suffisante=type_(V("X"), "felin"))
    petit = Connaissances("petit", (Inclusion("i1", "lionne", "felin", Source("t")),))
    grand = Connaissances("grand", petit.entrees + (Incompatibilite("inc", "male", "lionne", "type",
                                                                    ("porteur", "contexte"), source=Source("t")),
                                                    Regle("r", "implication", (("x", "individu"),),
                                                          (propriete(V("x"), "male"),), (type_(V("x"), "male"),),
                                                          Source("t"))))
    assert I.evaluer(Cas("p", D, Q, petit)).principal.nom == "etablie"
    ev = I.evaluer(Cas("g", D, Q, grand))
    assert ev.profils[RACINE].classes[0].statut == "NC+"
    assert ev.principal.nom == "non_certifiee" and ev.principal.signe == "+"


def test_T24_contexte_non_figuratif():
    """T24 : une classe dont les appuis ne sont que dans un contexte non figuratif n'est jamais V dans figuré."""
    for c in CAS:
        D = c.description
        if any(x.sorte == "vision" for x in D.contextes):
            continue
        ctxs = D.contextes + (Contexte("hist", "histoire", RACINE),)
        refs = tuple(replace(r, contexte="hist", situation=None) if r.sorte != "situation" else
                     replace(r, contexte="hist") for r in D.referents)
        asser = tuple(replace(a, qualification=replace(a.qualification, contexte="hist")) for a in D.assertions)
        c2 = replace(c, description=replace(D, contextes=ctxs, referents=refs, assertions=asser))
        assert formation.verifier(c2) == [], [str(d) for d in formation.verifier(c2)]
        ev = I.evaluer(c2)
        assert set(ev.profils) == {RACINE}
        for cl in ev.profils[RACINE].classes:
            assert cl.statut in ("N", "R", "R_H", "NC-") or not any(l.d_plus for b in cl.resultat.branches
                                                                      for l in b.lignes)


# =============================================================================================================
# D'autres propriétés : provenance, traduction, négation, silence, syntaxe concrète, formation
# =============================================================================================================

def test_provenance_sans_effet():
    """RF19 : la provenance n'a aucun effet sémantique."""
    for c in CAS[:30]:
        D = c.description
        c2 = replace(c, description=replace(D, assertions=tuple(replace(a, provenance=Provenance("autre", "en", 9,
                                                                                                  0, 1, "x"))
                                                                 for a in D.assertions)))
        e1, e2 = I.evaluer(c), I.evaluer(c2)
        assert {k: statuts_par_i(p) for k, p in e1.profils.items()} == {k: statuts_par_i(p)
                                                                          for k, p in e2.profils.items()}


def renommer(c, rng):
    """Une « traduction » qui garde le sens : les référents, les assertions et les points renommés, l'ordre des
    assertions permuté, la langue et la provenance changées (étude § 2.7 : l'invariance porte sur le profil)."""
    D, Dl = c.description, c.definition
    m = {r.id: ("t_" + r.id) for r in D.referents}
    ma = {a.id: ("t_" + a.id) for a in D.assertions}
    mp = {p.id: ("t_" + p.id) for p in D.points}

    def t(x):
        return m.get(x, x) if isinstance(x, str) else x

    def ty(T):
        if isinstance(T, Alternatifs):
            return Alternatifs(mp.get(T.point, T.point))
        if isinstance(T, (Union, Conjonction)):
            return type(T)(tuple(ty(u) for u in T.membres))
        return T

    def at(a):
        return replace(a, args=tuple(t(x) for x in a.args), type=ty(a.type) if a.type is not None else None)

    def contenu(cn):
        if isinstance(cn, Atome):
            return at(cn)
        if isinstance(cn, Proposition):
            return replace(cn, atomes=tuple(at(x) for x in cn.atomes))
        return replace(cn, restriction=tuple(at(x) for x in cn.restriction), portee=tuple(at(x) for x in cn.portee),
                       membres=tuple(t(x) for x in cn.membres), situation=t(cn.situation))
    asser = [replace(a, id=ma[a.id], contenu=contenu(a.contenu), provenance=Provenance("trad", "en"),
                     garde=Garde(tuple((mp[p], v) for p, v in a.garde.conditions))) for a in D.assertions]
    rng.shuffle(asser)
    refs = tuple(replace(r, id=m[r.id], situation=t(r.situation), introduit_par=ma.get(r.introduit_par))
                 for r in D.referents)
    ctxs = tuple(replace(x, ouvert_par=t(x.ouvert_par)) for x in D.contextes)
    pts = tuple(replace(p, id=mp[p.id]) for p in D.points)
    cs = tuple(replace(k, interdits=tuple(tuple(sorted((mp[p], v) for p, v in comb)) for comb in k.interdits))
               for k in D.contraintes)
    prefs = tuple(replace(p, point=mp.get(p.point, p.point)) for p in D.preferences)
    alts = tuple(replace(al, branches=tuple(tuple(ma[x] for x in b) for b in al.branches)) for al in D.alternatives)
    D2 = replace(D, langue="en", contextes=ctxs, referents=refs, assertions=tuple(asser), points=pts, contraintes=cs,
                 preferences=prefs, alternatives=alts)
    return replace(c, description=D2), mp


def test_invariance_de_traduction_au_niveau_des_profils():
    """Étude § 2.7 : en (a), une traduction fidèle a le même profil, à la correspondance des points près (non le
    seul nom du statut). Ici, une traduction qui garde les concepts : même profil, mêmes classes, même Syn."""
    rng = random.Random(GRAINE + 27)
    for c in CAS[:40]:
        c2, mp = renommer(c, rng)
        assert formation.verifier(c2) == []
        e1, e2 = I.evaluer(c), I.evaluer(c2)
        for ctx in e1.profils:
            s1 = statuts_par_i(e1.profils[ctx])
            s2 = {tuple(sorted((next((k for k, v in mp.items() if v == p), p), x) for p, x in i)): st
                  for i, st in statuts_par_i(e2.profils[ctx]).items()}
            assert s1 == s2
            assert e1.statuts[ctx].nom == e2.statuts[ctx].nom
            # les natures se gardent ; les contenus citent des identifiants, renommés par la traduction
            assert sorted(h.nature for _, h in e1.statuts[ctx].hypotheses) == \
                sorted(h.nature for _, h in e2.statuts[ctx].hypotheses)


def test_negation_propositionnelle_echange_les_appuis():
    """§ 3.5 : D⁺(¬F) = D⁻(F) et D⁻(¬F) = D⁺(F) ; ¬¬F a la valeur de F ; la négation n'est jamais satisfaite par une
    absence (sans aucune négation dans la description, ¬F n'a aucun appui positif)."""
    rng = random.Random(GRAINE + 30)
    for c in CAS[:40]:
        for i in I.interpretations_admissibles(c)[:3]:
            D = I.resoudre_description(c.description, i)
            Dl = I.resoudre_definition(c.definition, i)
            F = Dl.suffisante
            s = dict(Dl.variables)
            s.update(I.sortes_de(F))
            base = I.Base(D, c.connaissances, {})
            for (sigma, _) in I.solutions(base, F, {}, RACINE, s)[:5]:
                sig = {k: v for k, v in sigma.items() if k in I.libres(F)}
                p, n = I.options_pos(base, F, sig, RACINE, s), I.options_neg(base, F, sig, RACINE, s)
                assert I.options_pos(base, Non(F), sig, RACINE, s) == n
                assert I.options_neg(base, Non(F), sig, RACINE, s) == p
                assert I.options_pos(base, Non(Non(F)), sig, RACINE, s) == p
    # le silence
    for c in CAS[:40]:
        D = c.description
        pos = tuple(a for a in D.assertions if a.qualification.polarite == "pos" and
                    not isinstance(a.contenu, Quantification))
        K = Connaissances("sans_neg", tuple(e for e in c.connaissances.entrees if isinstance(e, (Inclusion, Antonymie,
                                                                                               OppositionTypique,
                                                                                               Typique))))
        c2 = replace(c, description=replace(D, assertions=pos, alternatives=()), connaissances=K)
        if formation.verifier(c2):
            continue
        # sans négation dans la description (ni distinction dite), une feuille ¬G, « aucun » n'a jamais d'appui
        # positif ; et une requête sans négation n'a jamais d'appui négatif
        pos2 = tuple(a for a in pos if not (isinstance(a.contenu, Atome) and a.contenu.pred == "distinct"))
        c2 = replace(c2, description=replace(c2.description, assertions=pos2))
        ev = I.evaluer(c2)
        negatives = [f for S in I.selections(c2.definition.suffisante) for f in S
                     if isinstance(f, Non) or (isinstance(f, Compte) and f.quant == "aucun")]
        for i in I.interpretations_admissibles(c2):
            D2 = I.resoudre_description(c2.description, i)
            Dl = I.resoudre_definition(c2.definition, i)
            base = I.Base(D2, K, {})
            s = dict(Dl.variables)
            s.update(I.sortes_de(Dl.suffisante))
            for (sigma, _) in I.solutions(base, Et(tuple(f for S in I.selections(Dl.suffisante) for f in S
                                                         if isinstance(f, Atome) and f.pred == "type")), {},
                                          RACINE, s):
                for f in negatives:
                    f = I.resoudre_formule(f, i)
                    assert not I.options_pos_feuille(base, f, sigma, RACINE, s), (f, sigma)
        if not negatives:
            for p in ev.profils.values():
                for cl in p.classes:
                    assert cl.statut not in ("R", "R_H", "NC-", "B"), cl.statut


def test_antonymie_et_opposition_typique_ne_nient_rien():
    """Étude § 6.1 : une antonymie lexicale et une opposition typique ne donnent jamais un appui négatif."""
    D = Description("roi", referents=(Referent("k", "individu", introduit_par="a1"),),
                    assertions=(Assertion("a1", type_("k", "roi")), Assertion("a2", propriete("k", "vivant"))))
    Q = Definition("mort", variables=(("X", "individu"),), suffisante=et(type_(V("X"), "roi"),
                                                                         propriete(V("X"), "mort")))
    for e in (Antonymie("ant", "vivant", "mort", Source("WordNet !")),
              OppositionTypique("opp", "vivant", "mort", Source("t"))):
        assert I.evaluer(Cas("c", D, Q, Connaissances("k", (e,)))).principal.nom == "inconnue"
    inc = Incompatibilite("inc", "vivant", "mort", "propriete", ("porteur", "contexte"), source=Source("attestée"))
    assert I.evaluer(Cas("c", D, Q, Connaissances("k", (inc,)))).principal.nom == "ecartee"


def test_syntaxe_concrete_aller_retour():
    """§ 4 : la syntaxe concrète est une traduction : lire(écrire(x)) = x, pour les cas tirés et les exemples."""
    for c in CAS + [exemple_rq010(), exemple_pi003(), exemple_mn004_b(), exemple_definition_structuree()]:
        d = J.ecrire_cas(c)
        assert J.lire_cas(d) == c
        import json
        assert J.lire_cas(json.loads(json.dumps(d))) == c


def test_formation_mutations_detectees():
    """§ 2 : une mutation de chaque espèce est rejetée, avec la règle qu'elle viole."""
    c = exemple_pi003()
    assert formation.verifier(c) == [], [str(d) for d in formation.verifier(c)]
    D, Dl = c.description, c.definition

    def regles(c2):
        return {d.regle for d in formation.verifier(c2)}
    a0 = D.assertions[0]
    mutations = {
        1: replace(c, description=replace(D, assertions=D.assertions + (a0,))),
        2: replace(c, description=replace(D, contextes=D.contextes + (Contexte("orph", "emboite", "inconnu"),))),
        3: replace(c, description=replace(D, contextes=D.contextes + (Contexte("v2", "vision", RACINE, None),))),
        5: replace(c, description=replace(D, referents=D.referents + (Referent("fantome", "individu"),))),
        8: replace(c, definition=replace(Dl, suffisante=et(Dl.suffisante, type_(V("X"), Union((Concept("a"),)))))),
        9: replace(c, description=replace(D, points=(Point("vide", "D", "sens", ()),))),
        12: replace(c, description=replace(D, points=(Point("pD", "D", "sens", ("a", "b")),)),
                    definition=replace(Dl, points=(Point("pQ", "Δ", "sens", ("a", "b")),),
                                       contraintes=(exclusion_conjointe("x", [{"pD": "a", "pQ": "b"}], "t"),))),
        14: replace(c, description=replace(D, assertions=D.assertions + (
            Assertion("sup", propriete("m1", "x"), Qualification(modalite="supposee", nature="inventee")),))),
        15: replace(c, description=replace(D, assertions=D.assertions + (
            Assertion("negat", propriete("m1", "x"), Qualification(polarite="neg")),))),
        16: replace(c, description=replace(D, assertions=D.assertions + (
            Assertion("q", Quantification("seul", None, ("z", "individu"), (type_(Var("z"), "x"),))),))),
        17: replace(c, description=replace(D, assertions=D.assertions + (Assertion("mm", meme("m1", "m2")),))),
        19: replace(c, description=replace(D, assertions=D.assertions + (
            Assertion("prov", propriete("m1", "x"), provenance=Provenance(debut=5, fin=2)),))),
        21: replace(c, definition=replace(Dl, variables=Dl.variables + (("Libre", "individu"),),
                                          suffisante=et(Dl.suffisante, Non(type_(V("Libre"), "x"))))),
        22: replace(c, definition=replace(Dl, suffisante=Ou((Dl.suffisante, Non(type_(V("X"), "x")))))),
        23: replace(c, definition=replace(Dl, suffisante=et(Dl.suffisante, Atome("distinct", (V("X"), V("X")))))),
        24: replace(c, definition=replace(Dl, suffisante=Ou((Dl.suffisante,)))),
        30: replace(c, description=replace(D, assertions=D.assertions + (
            Assertion("lect", propriete("m1", "x"), Qualification(modalite="supposee", nature="lecture")),))),
    }
    for regle, c2 in mutations.items():
        assert regle in regles(c2), (regle, [str(d) for d in formation.verifier(c2)])
    # RF26 : une condition suffisante qui n'implique pas la condition nécessaire
    mauvaise = replace(c, definition=replace(Dl, necessaire=type_(V("X"), "inconnu_de_K")))
    assert 26 in regles(mauvaise)
    # RF28 : une paire alias et distincte
    K = Connaissances("k", (Alias("a", "k1", "k2", Source("t")), Distinction("d", "k2", "k1", Source("t"))))
    assert 28 in regles(replace(c, connaissances=K))
    # chaque message cite sa règle
    for d in formation.verifier(mutations[12]):
        assert str(d).startswith(f"RF{d.regle} (")


# =============================================================================================================
# Les exemples écrits (étude § 1 à § 8)
# =============================================================================================================

def cas_simple(assertions, referents, Q, K=Connaissances(), points=(), contraintes=(), contextes=None,
               alternatives=(), preferences=()):
    D = Description("d", referents=tuple(referents), assertions=tuple(assertions), points=tuple(points),
                    contraintes=tuple(contraintes), alternatives=tuple(alternatives), preferences=tuple(preferences),
                    contextes=contextes or (Contexte(RACINE, "figuration"),))
    return Cas("c", D, Q, K)


X, Y = V("X"), V("Y")


def test_lion_aile_dans_les_deux_sens():
    """Étude § 2.6 : Q_sys = un lion ailé, Q_ref = un lion. Q_sys ⊆ Q_ref (oui), Q_ref ⊄ Q_sys (non) ; sur
    « un lion, sans ailes », Q_sys est écartée, Q_ref établie : seul le positif est licencié ; le rapporter pour la
    notation serait une erreur e⁻_der. L'inverse : sur « un lion », Q_sys est établie, Q_ref inconnue."""
    K = Connaissances()
    ref = Definition("ref", variables=(("X", "individu"),), suffisante=type_(X, "lion"))
    sys_ = Definition("sys", variables=(("X", "individu"),), suffisante=et(type_(X, "lion"), propriete(X, "aile")))
    v1 = inclusion.comparer(sys_.suffisante, ref.suffisante, K)
    v2 = inclusion.comparer(ref.suffisante, sys_.suffisante, K)
    assert v1.verdict == "oui" and v2.verdict == "non"
    assert I.signes_licencies(v1.verdict, v2.verdict) == {"+"}
    refs = [Referent("e", "individu", introduit_par="a1")]
    D1 = [Assertion("a1", type_("e", "lion")),
          Assertion("a2", Proposition((), (propriete("e", "aile"),)), Qualification(polarite="neg"))]
    ps = I.evaluer(cas_simple(D1, refs, sys_))
    pr = I.evaluer(cas_simple(D1, refs, ref))
    assert ps.principal.nom == "ecartee" and pr.principal.nom == "etablie"
    sm, sr = ps.profils[RACINE].statuts(), pr.profils[RACINE].statuts()
    assert I.mesures(sm, sr)["e-_der"] == 1  # le comparateur muté, qui licencie le négatif, est détecté
    rapporte = [I.restreindre(s, I.signes_licencies(v1.verdict, v2.verdict)) for s in sm]
    assert I.mesures(rapporte, sr) == {k: 0 for k in I.mesures(rapporte, sr)}
    # l'inverse
    D2 = [Assertion("a1", type_("e", "lion"))]
    ps2, pr2 = I.evaluer(cas_simple(D2, refs, ref)), I.evaluer(cas_simple(D2, refs, sys_))
    assert ps2.principal.nom == "etablie" and pr2.principal.nom == "inconnue"
    assert I.mesures(ps2.profils[RACINE].statuts(), pr2.profils[RACINE].statuts())["e+_der"] == 1
    # « pas de lion » réfute les deux : le négatif se transmet dans ce sens (Q_ref ⊆ … non ; Q_sys ⊆ Q_ref oui)
    D3 = [Assertion("a1", Proposition((("x", "individu"),), (type_(V("x"), "lion"),)),
                    Qualification(polarite="neg"))]
    assert I.evaluer(cas_simple(D3, [], ref)).principal.nom == "ecartee"
    assert I.evaluer(cas_simple(D3, [], sys_)).principal.nom == "ecartee"


def test_ensemble_vide_personnification():
    """Étude § 3.7 (a) : une restriction de sélection appliquée hors de son domaine vide I ; le système rend
    aucune_interpretation, jamais etablie par vacuité ; rien n'est écarté de l'index. Restreinte à son domaine de
    validité (le littéral), elle ne s'applique pas à une personnification (contexte emboîté)."""
    K = Connaissances("k", (
        RestrictionSelection("rs", "tendre", "agent", "anime", ("figuration", "emboite"), Source("VerbNet [à vérifier]")),
        Incompatibilite("inc", "anime", "abstraction", "type", ("porteur", "contexte"), source=Source("t")),
        Inclusion("i1", "mort_concept", "abstraction", Source("t"))))
    refs = [Referent("m", "individu", introduit_par="a1"), Referent("e", "changement", introduit_par="a2"),
            Referent("s", "individu", introduit_par="a3")]
    A = [Assertion("a1", type_("m", "mort_concept")), Assertion("a2", type_("e", "tendre")),
         Assertion("a3", type_("s", "sablier")), Assertion("a4", role("e", "agent", "m")),
         Assertion("a5", role("e", "theme", "s"))]
    Q = Definition("q", variables=(("X", "individu"),), suffisante=type_(X, "mort_concept"))
    ev = I.evaluer(cas_simple(A, refs, Q, K))
    assert ev.principal.nom == "aucune_interpretation" and not ev.profils[RACINE].classes
    assert I.index_retient(cas_simple(A, refs, Q, K))
    K2 = replace(K, entrees=(replace(K.entrees[0], domaine=("vision",)),) + K.entrees[1:])
    assert I.evaluer(cas_simple(A, refs, Q, K2)).principal.nom == "etablie"


def exemple_mn004_b():
    """mn-004 au niveau (b) (étude § 1.3, § 3.7 (c)) : trois sens de « angels » de chaque côté, « aucun ange dans
    la composition » ; la négation n'atteint que les couples où le sens de Δ est inclus dans celui de D."""
    sens = ("wn30:09538915-n", "oc:personne_sainte", "oc:investisseur")
    pts = [Point("d1", "D", "sens", sens, "angels (D)")]
    A = [Assertion("v", type_("vierge", "oc:vierge")), Assertion("aucun", Quantification(
        "aucun", None, ("z", "individu"), (type_(Var("z"), Alternatifs("d1")),)))]
    refs = [Referent("vierge", "individu", introduit_par="v")]
    Q = Definition("mn-004", variables=(("X", "individu"), ("M", "individu")),
                   suffisante=et(type_(V("M"), "oc:vierge"), type_(X, Alternatifs("d2"))),
                   points=(Point("d2", "Δ", "sens", sens, "angels (Δ)"),))
    return cas_simple(A, refs, Q, points=pts,
                      preferences=[Preference("dom", "d1", sens, (), "le domaine religieux (une préférence)")])


def test_mn004_aucun_ange():
    """mn-004 : neuf couples ; les trois diagonaux F, les six autres N ; Syn = ecartee_sous_hypotheses, couverture
    par trois cylindres (non par un seul : « d1 = d2 » n'est pas un cylindre), le préféré d'abord."""
    ev = I.evaluer(exemple_mn004_b())
    p = ev.profils[RACINE]
    st = Counter(p.statuts())
    assert st == Counter({"R": 3, "N": 6})
    s = ev.principal
    assert s.nom == "ecartee_sous_hypotheses" and s.ligne == 9
    assert len(s.couverture_moins) == 3
    assert s.couverture_moins[0] == {"d1": ("wn30:09538915-n",), "d2": ("wn30:09538915-n",)}
    # au niveau (a), le contexte fixe le sens des deux côtés : une seule interprétation, F
    c = exemple_mn004_b()
    a = replace(c, description=replace(c.description, contraintes=(exclusion("ctx", "d1", ["oc:personne_sainte",
                                                                                           "oc:investisseur"],
                                                                             "jugement (a)"),)),
                definition=replace(c.definition, contraintes=(exclusion("ctxq", "d2", ["oc:personne_sainte",
                                                                                      "oc:investisseur"],
                                                                        "jugement (a)"),)))
    assert I.evaluer(a).principal.nom == "ecartee"


def exemple_rq010():
    """rq-010 : « Two angels crown her », collectif ou distributif (un point de pluriel)."""
    col, dis = Garde((("p1", ("collective",)),)), Garde((("p1", ("distributive",)),))
    refs = [Referent("v", "individu", introduit_par="iv"), Referent("g", "collection", introduit_par="ig"),
            Referent("a1", "individu", introduit_par="ia1"), Referent("a2", "individu", introduit_par="ia2"),
            Referent("e0", "changement", introduit_par="ie0"), Referent("e1", "changement", introduit_par="ie1"),
            Referent("e2", "changement", introduit_par="ie2")]
    A = [Assertion("iv", type_("v", "oc:vierge")), Assertion("ig", type_("g", "wn30:09538915-n")),
         Assertion("ia1", type_("a1", "wn30:09538915-n")), Assertion("ia2", type_("a2", "wn30:09538915-n")),
         Assertion("ie0", type_("e0", "oc:couronner"), garde=col),
         Assertion("r0a", role("e0", "agent", "g"), garde=col), Assertion("r0t", role("e0", "theme", "v"), garde=col),
         Assertion("ie1", type_("e1", "oc:couronner"), garde=dis), Assertion("ie2", type_("e2", "oc:couronner"),
                                                                                garde=dis),
         Assertion("r1a", role("e1", "agent", "a1"), garde=dis), Assertion("r1t", role("e1", "theme", "v"), garde=dis),
         Assertion("r2a", role("e2", "agent", "a2"), garde=dis), Assertion("r2t", role("e2", "theme", "v"), garde=dis)]
    Q = Definition("rq-010", "the Virgin crowned by angels",
                   variables=(("V", "individu"), ("E", "changement"), ("A", "entite")),
                   suffisante=et(type_(V("V"), "oc:vierge"), type_(V("E"), "oc:couronner"),
                                 role(V("E"), "theme", V("V")), role(V("E"), "agent", V("A")),
                                 type_(V("A"), "wn30:09538915-n")))
    return cas_simple(A, refs, Q, points=[Point("p1", "D", "pluriel", ("collective", "distributive"))])


def test_rq010_pour_tout_i_il_existe_sigma():
    """rq-010 (étude § 3.7 (d)) : etablie par cas ∀i∃σ, non uniforme ; l'approximation ∃σ∀i du noyau 0.3 ne
    l'établit pas."""
    ev = I.evaluer(exemple_rq010())
    p, s = ev.profils[RACINE], ev.principal
    assert s.nom == "etablie" and not s.uniforme_plus
    assert not I.etablie_uniformement(p)
    assert len(p.classes) == 2


def test_rq010_calcul_interrompu():
    """Étude § 3.7 (f) : le budget s'épuise après la lecture collective, établie, avant la distributive :
    {collective : E ; distributive : ?}, Syn = incomplet, non etablie_sous_hypotheses [collective]."""
    c = exemple_rq010()
    ev = I.evaluer(c, budget=1)
    st = statuts_par_i(ev.profils[RACINE])
    assert st[(("p1", "collective"),)] == "E" and st[(("p1", "distributive"),)] == "?"
    assert ev.principal.nom == "incomplet"


def exemple_co018_alternative(def_moine_seul=False):
    """co-018#4 de l'étude (le banc v3 la numérote n = 3) : « a seated figure, either a monk or a nun » — une
    alternative de l'auteur, traitée par cas."""
    refs = [Referent("f", "individu", introduit_par="if"), Referent("b", "individu", introduit_par="ib"),
            Referent("e", "processus", introduit_par="ie")]
    A = [Assertion("if", type_("f", "oc:figure")), Assertion("ib", type_("b", "oc:livre")),
         Assertion("ie", type_("e", "oc:lire")), Assertion("ra", role("e", "agent", "f")),
         Assertion("rt", role("e", "theme", "b")),
         Assertion("moine", type_("f", "oc:moine")), Assertion("moniale", type_("f", "oc:moniale"))]
    t = Concept("oc:moine") if def_moine_seul else Union((Concept("oc:ermite"), Concept("oc:moine"),
                                                          Concept("oc:moniale")))
    Q = Definition("co-018", "hermit, monk or nun reading a book",
                   variables=(("X", "individu"), ("E", "processus"), ("B", "individu")),
                   suffisante=et(type_(X, t), type_(V("E"), "oc:lire"), role(V("E"), "agent", X),
                                 role(V("E"), "theme", V("B")), type_(V("B"), "oc:livre")))
    return cas_simple(A, refs, Q, alternatives=[Alternative("alt", (("moine",), ("moniale",)))])


def test_co018_alternative_union_et_conjonction():
    """Étude § 3.4 et la distinction demandée par la propriétaire :
    - une ALTERNATIVE de l'auteur se traite par cas : la définition, vraie dans chaque branche, est etablie ; vraie
      dans une seule (« monk reading »), elle est inconnue (les branches rapportées), jamais
      etablie_sous_hypotheses : choisir une branche serait une abduction, non une lecture ;
    - une UNION de concepts (« x : moine ∪ moniale ») appuie le type union, non chacun de ses membres ;
    - un ensemble de concepts ALTERNATIFS (un point) donne une classe par valeur ;
    - une CONJONCTION appuie chacun de ses membres."""
    assert I.evaluer(exemple_co018_alternative()).principal.nom == "etablie"
    ev = I.evaluer(exemple_co018_alternative(def_moine_seul=True))
    assert ev.principal.nom == "inconnue"
    assert [b.statut for b in ev.profils[RACINE].classes[0].resultat.branches] == ["E", "N"]
    assert not ev.principal.hypotheses
    refs = [Referent("f", "individu", introduit_par="a")]
    moine_ou = Union((Concept("oc:moine"), Concept("oc:moniale")))
    qu = Definition("u", variables=(("X", "individu"),), suffisante=type_(X, Union((Concept("oc:ermite"),
                                                                                    Concept("oc:moine"),
                                                                                    Concept("oc:moniale")))))
    qm = Definition("m", variables=(("X", "individu"),), suffisante=type_(X, "oc:moine"))
    union = [Assertion("a", type_("f", moine_ou))]
    assert I.evaluer(cas_simple(union, refs, qu)).principal.nom == "etablie"
    assert I.evaluer(cas_simple(union, refs, qm)).principal.nom == "inconnue"
    point = [Assertion("a", type_("f", Alternatifs("p")))]
    pts = [Point("p", "D", "sens", ("oc:moine", "oc:moniale"))]
    ev = I.evaluer(cas_simple(point, refs, qm, points=pts))
    assert Counter(ev.profils[RACINE].statuts()) == Counter({"E": 1, "N": 1})
    assert ev.principal.nom == "etablie_sous_hypotheses" and ev.principal.couverture_plus == [{"p": ("oc:moine",)}]
    conj = [Assertion("a", type_("f", Conjonction((Concept("oc:moine"), Concept("oc:ermite")))))]
    assert I.evaluer(cas_simple(conj, refs, qm)).principal.nom == "etablie"
    # la négation : nier l'union nie chacun de ses membres ; nier chacun des membres nie l'union
    nie_u = [Assertion("a", type_("f", "oc:figure")),
             Assertion("n", Proposition((), (type_("f", moine_ou),)), Qualification(polarite="neg"))]
    assert I.evaluer(cas_simple(nie_u, refs, qm)).principal.nom == "ecartee"
    nie_m = [Assertion("a", type_("f", "oc:figure")),
             Assertion("n1", Proposition((), (type_("f", "oc:moine"),)), Qualification(polarite="neg")),
             Assertion("n2", Proposition((), (type_("f", "oc:moniale"),)), Qualification(polarite="neg"))]
    qmm = Definition("mm", variables=(("X", "individu"),), suffisante=type_(X, moine_ou))
    assert I.evaluer(cas_simple(nie_m, refs, qmm)).principal.nom == "ecartee"


def exemple_pi003(identite="supposee", sens_ouverts=False):
    """pi-003 : saint Martin partage son manteau ; la nuit suivante, Martin endormi voit en rêve le Christ vêtu de
    cette moitié de manteau. Deux situations, un contexte de rêve, meme_individu entre les moitiés (dit), et
    l'identité de Martin entre les situations (supposée : nature identite ; ou dite)."""
    refs = [Referent("s1", "situation"), Referent("s2", "situation"),
            Referent("m1", "individu", RACINE, "s1", "im1"), Referent("p", "individu", RACINE, "s1", "ip"),
            Referent("h1", "individu", RACINE, "s1", "ih1"), Referent("e1", "changement", RACINE, "s1", "ie1"),
            Referent("m2", "individu", RACINE, "s2", "im2"), Referent("d", "etat", RACINE, "s2", "id"),
            Referent("e2", "processus", RACINE, "s2", "ie2"),
            Referent("c", "individu", "reve", None, "ic"), Referent("w", "etat", "reve", None, "iw"),
            Referent("h2", "individu", "reve", None, "ih2")]
    ctxs = (Contexte(RACINE, "figuration"), Contexte("reve", "reve", RACINE, "e2"))
    tm = Alternatifs("pm") if sens_ouverts else Concept("oc:saint_martin")
    A = [Assertion("im1", type_("m1", tm), provenance=Provenance("pi-003", "fr", 1, 9, 23, "saint Martin")),
         Assertion("nm1", nom("m1", "martin")),
         Assertion("ip", type_("p", "oc:pauvre")), Assertion("ih1", type_("h1", "oc:moitie_manteau")),
         Assertion("ie1", type_("e1", "oc:donner")), Assertion("r1", role("e1", "agent", "m1")),
         Assertion("r2", role("e1", "theme", "h1")), Assertion("r3", role("e1", "destinataire", "p")),
         Assertion("im2", type_("m2", tm)), Assertion("nm2", nom("m2", "martin")),
         Assertion("id", type_("d", "oc:endormi")), Assertion("rd", role("d", "porteur", "m2")),
         Assertion("ie2", type_("e2", "oc:voir_en_reve")), Assertion("rv", role("e2", "agent", "m2")),
         Assertion("succ", succede("s1", "s2")),
         Assertion("ic", type_("c", "oc:christ"), Qualification(contexte="reve")),
         Assertion("ih2", type_("h2", "oc:moitie_manteau"), Qualification(contexte="reve")),
         Assertion("iw", type_("w", "oc:vetu"), Qualification(contexte="reve")),
         Assertion("rw1", role("w", "porteur", "c"), Qualification(contexte="reve")),
         Assertion("rw2", role("w", "theme", "h2"), Qualification(contexte="reve")),
         Assertion("mh", meme_individu("h2", "h1"), Qualification(contexte="reve"),
                   provenance=Provenance("pi-003", "fr", 2, 0, 0, "cette moitié"))]
    if identite == "supposee":
        A.append(Assertion("mm", meme_individu("m1", "m2"),
                           Qualification(modalite="supposee", nature="identite",
                                         contenu="Martin de la première scène = Martin du rêve (même nom)")))
    elif identite == "dite":
        A.append(Assertion("mm", meme_individu("m1", "m2")))
    M, M2, E1, E2, B, H1, H2, Ch, W, S1, S2, St, Cx = (V(n) for n in ("M", "M2", "E1", "E2", "B", "H1", "H2", "Ch",
                                                                      "W", "S1", "S2", "St", "Cx"))
    Q = Definition("pi-003", "St Martin dividing his cloak … the same Martin, asleep, seeing in a dream Christ …",
                   variables=(("M", "individu"), ("M2", "individu"), ("E1", "changement"), ("E2", "processus"),
                              ("B", "individu"), ("H1", "individu"), ("H2", "individu"), ("Ch", "individu"),
                              ("W", "etat"), ("S1", "situation"), ("S2", "situation"), ("St", "etat"),
                              ("Cx", "contexte")),
                   suffisante=et(type_(M, Alternatifs("qm") if sens_ouverts else "oc:saint_martin"),
                                 type_(E1, "oc:donner"), role(E1, "agent", M),
                                 role(E1, "destinataire", B), type_(B, "oc:pauvre"), role(E1, "theme", H1),
                                 type_(H1, "oc:moitie_manteau"), dans(E1, S1),
                                 meme_individu(M, M2), type_(St, "oc:endormi"), role(St, "porteur", M2),
                                 type_(E2, "oc:voir_en_reve"), role(E2, "agent", M2), dans(E2, S2),
                                 succede(S1, S2), contexte_ouvert(Cx, E2, "reve"),
                                 type_(Ch, "oc:christ", Cx), type_(W, "oc:vetu", Cx),
                                 role(W, "porteur", Ch, Cx), role(W, "theme", H2, Cx), meme_individu(H2, H1)),
                   points=(Point("qm", "Δ", "sens", ("oc:saint_martin", "oc:martin_pape")),) if sens_ouverts else ())
    pts = [Point("pm", "D", "sens", ("oc:saint_martin", "oc:martin_pape"), "saint Martin")] if sens_ouverts else []
    return cas_simple(A, refs, Q, contextes=ctxs, points=pts)


def test_pi003_natures_conservees():
    """pi-003 (étude § 3.7 (b), § 8.4) : identité supposée ⇒ etablie_sous_hypotheses, l'hypothèse de nature
    identite ; identité dite ⇒ etablie ; aucune identité ⇒ inconnue ; avec des sens ouverts, les deux natures
    restent distinctes : [lecture(sens) : le cylindre] et [identite : Martin] (n_perdue sinon)."""
    ev = I.evaluer(exemple_pi003("supposee"))
    s = ev.principal
    assert s.nom == "etablie_sous_hypotheses" and s.ligne == 5
    assert [h.nature for _, h in s.hypotheses] == ["identite"]
    assert I.evaluer(exemple_pi003("dite")).principal.nom == "etablie"
    assert I.evaluer(exemple_pi003("aucune")).principal.nom == "inconnue"
    ev2 = I.evaluer(exemple_pi003("supposee", sens_ouverts=True))
    s2 = ev2.principal
    assert s2.nom == "etablie_sous_hypotheses" and s2.ligne == 6
    assert {h.nature for _, h in s2.hypotheses} == {"identite"}
    assert s2.couverture_plus and all(set(h) <= {"pm", "qm"} for h in s2.couverture_plus)
    # la mesure n_perdue : une sortie qui rend l'identité comme un choix de lecture (ou l'efface) la perd
    st = ev.profils[RACINE].statuts()
    hs = [cl.resultat.hypotheses for cl in ev.profils[RACINE].classes for _ in cl.interpretations]
    assert I.mesures(["E"] * len(st), st, None, hs)["n_perdue"] == 1
    lecture = [(frozenset({Hypothese("lecture", "Martin")}),)] * len(st)
    assert I.mesures(st, st, lecture, hs)["n_perdue"] == 1


def exemple_divergent(avec_b=False):
    """ep-009 schématisé (étude § 3.7 (c), exemple 3) : un point de cadre de référence ; la lecture intrinsèque
    établit, celle du spectateur écarte (l'incompatibilité attestée d'un ordre et de son inverse)."""
    gi, gs = Garde((("cadre", ("intrinseque",)),)), Garde((("cadre", ("spectateur",)),))
    refs = [Referent("j", "individu", introduit_par="ij"), Referent("v", "individu", introduit_par="iv")]
    A = [Assertion("ij", type_("j", "oc:jean")), Assertion("iv", type_("v", "oc:vierge")),
         Assertion("ri", relation("oc:droite_de", "j", "v"), garde=gi),
         Assertion("rs", relation("oc:gauche_de", "j", "v"), garde=gs)]
    pts = [Point("cadre", "D", "cadre_de_reference", ("intrinseque", "spectateur") + (("mixte",) if avec_b else ()))]
    if avec_b:
        gm = Garde((("cadre", ("mixte",)),))
        A += [Assertion("rm1", relation("oc:droite_de", "j", "v"), garde=gm),
              Assertion("rm2", relation("oc:gauche_de", "j", "v"), garde=gm)]
    K = Connaissances("k", (Incompatibilite("ordre", "oc:droite_de", "oc:gauche_de", "relation",
                                            ("porteur", "contexte"), source=Source("décision 9")),))
    Q = Definition("ep-009", variables=(("X", "individu"), ("Y", "individu")),
                   suffisante=et(type_(X, "oc:jean"), type_(Y, "oc:vierge"), relation("oc:droite_de", X, Y)))
    return cas_simple(A, refs, Q, K, points=pts,
                      preferences=[Preference("conv", "cadre", ("spectateur", "intrinseque") +
                                              (("mixte",) if avec_b else ()), (), "convention non attestée")])


def test_profil_divergent_et_contradiction_interne():
    """Étude § 3.7 (c) : un profil divergent garde les deux preuves ; une contradiction DANS une interprétation
    (B) n'est pas une divergence ENTRE interprétations ; une contradiction entre l'auteur et une source citée est
    documentaire."""
    ev = I.evaluer(exemple_divergent())
    s = ev.principal
    assert s.nom == "divergent" and s.niveaux == (2, 2)
    assert s.couverture_plus == [{"cadre": ("intrinseque",)}] and s.couverture_moins == [{"cadre": ("spectateur",)}]
    assert len(s.temoins) == 2
    refs = [Referent("x", "individu", introduit_par="a")]
    Q = Definition("q", variables=(("X", "individu"),), suffisante=type_(X, "oc:lion"))
    interne = [Assertion("a", type_("x", "oc:lion")),
               Assertion("n", Proposition((), (type_("x", "oc:lion"),)), Qualification(polarite="neg"))]
    ev = I.evaluer(cas_simple(interne, refs, Q))
    assert ev.principal.nom == "contradictoire"
    l = ev.profils[RACINE].classes[0].resultat.branches[0].lignes[0]
    assert l.valeur == "B" and l.contradiction == "interne"
    doc = [Assertion("a", type_("x", "oc:lion")),
           Assertion("n", Proposition((), (type_("x", "oc:lion"),)),
                     Qualification(polarite="neg", enonciateur="cite:catalogue"))]
    l = I.evaluer(cas_simple(doc, refs, Q)).profils[RACINE].classes[0].resultat.branches[0].lignes[0]
    assert l.valeur == "B" and l.contradiction == "documentaire"


def exemple_definition_structuree():
    """Une définition comme paire (suffisante, nécessaire) : « un martyr » est établi par « saint avec une palme »
    (suffisante, non établie : une abduction), réfuté par la négation de « saint » (nécessaire, établie)."""
    refs = [Referent("s", "individu", introduit_par="a")]
    A = [Assertion("a", type_("s", "oc:saint")), Assertion("b", propriete("s", "oc:palme"))]
    Q = Definition("martyr", variables=(("X", "individu"),),
                   suffisante=et(type_(X, "oc:saint"), propriete(X, "oc:palme")), necessaire=type_(X, "oc:saint"),
                   statut_suffisance="non_etablie", statut_necessite="etablie")
    return cas_simple(A, refs, Q)


def test_conditions_necessaires_et_suffisantes_structurees():
    """§ 1.9 et § 3.6 : val = (D⁺(suffisante), D⁻(nécessaire)) ; une suffisance non établie ne fonde qu'une
    hypothèse de nature abduction ; la nécessité établie réfute sans hypothèse."""
    c = exemple_definition_structuree()
    assert formation.verifier(c) == []
    s = I.evaluer(c).principal
    assert s.nom == "etablie_sous_hypotheses" and [h.nature for _, h in s.hypotheses] == ["abduction"]
    D = replace(c.description, assertions=(Assertion("a", type_("s", "oc:figure")),
                                           Assertion("n", Proposition((), (type_("s", "oc:saint"),)),
                                                     Qualification(polarite="neg"))))
    assert I.evaluer(replace(c, description=D)).principal.nom == "ecartee"


def test_quantifications_enoncees_et_de_requete():
    """§ 1.7, RS 4, RS 10, RS 11 : « aucun » réfute pour tout référent (et la réfutation est uniforme, sans
    substitution) ; « tous » déduit la portée ; « seul » nie la restriction d'un troisième établi distinct
    (rq-021#5 : contradictoire) ; les quantifications de la requête (au moins, exactement, aucun, tous, seul)."""
    z = ("z", "individu")
    refs = [Referent("a1", "individu", introduit_par="i1"), Referent("a2", "individu", introduit_par="i2"),
            Referent("j", "individu", introduit_par="ij"), Referent("h", "individu", introduit_par="ih"),
            Referent("t", "individu", introduit_par="it")]
    base_A = [Assertion("i1", type_("a1", "oc:apotre")), Assertion("i2", type_("a2", "oc:apotre")),
              Assertion("ij", type_("j", "oc:judith")), Assertion("ih", type_("h", "oc:holopherne")),
              Assertion("it", type_("t", "oc:personne")), Assertion("d12", distinct("a1", "a2"))]
    K = Connaissances("k", (Inclusion("x1", "oc:apotre", "oc:personne", Source("t")),
                            Inclusion("x2", "oc:judith", "oc:personne", Source("t")),
                            Inclusion("x3", "oc:holopherne", "oc:personne", Source("t"))))
    tous = Assertion("q", Quantification("tous", None, z, (type_(Var("z"), "oc:apotre"),),
                                         (propriete(Var("z"), "oc:endormi"),)))
    Q1 = Definition("dort", variables=(("X", "individu"),), suffisante=et(type_(X, "oc:apotre"),
                                                                         propriete(X, "oc:endormi")))
    assert I.evaluer(Cas("c", Description("d", referents=tuple(refs), assertions=tuple(base_A + [tous])), Q1, K)
                     ).principal.nom == "etablie"
    Q2 = Definition("deux", variables=(("X", "individu"),),
                    suffisante=et(type_(X, "oc:personne"),
                                  Compte("au_moins", 2, ("u", "individu"), type_(Var("u"), "oc:apotre"))))
    assert I.evaluer(Cas("c", Description("d", referents=tuple(refs), assertions=tuple(base_A)), Q2, K)
                     ).principal.nom == "etablie"
    exact = Assertion("ex", Quantification("exactement", 1, z, (type_(Var("z"), "oc:apotre"),)))
    assert I.evaluer(Cas("c", Description("d", referents=tuple(refs), assertions=tuple(base_A + [exact])), Q2, K)
                     ).principal.nom == "contradictoire"
    seul = Assertion("seul", Quantification("seul", None, z, (type_(Var("z"), "oc:personne"),), (), ("j", "h")))
    Q3 = Definition("seuls", variables=(("J", "individu"), ("H", "individu")),
                    suffisante=et(type_(V("J"), "oc:judith"), type_(V("H"), "oc:holopherne"),
                                  Compte("seul", None, ("u", "individu"), type_(Var("u"), "oc:personne"), None,
                                         (V("J"), V("H")))))
    A = [Assertion("i1", type_("j", "oc:judith")), Assertion("ih", type_("h", "oc:holopherne")), seul]
    r2 = [Referent("j", "individu", introduit_par="i1"), Referent("h", "individu", introduit_par="ih")]
    assert I.evaluer(Cas("c", Description("d", referents=tuple(r2), assertions=tuple(A)), Q3, K)
                     ).principal.nom == "etablie"
    # sans l'énoncé, l'exclusivité n'est jamais appuyée par le silence
    assert I.evaluer(Cas("c", Description("d", referents=tuple(r2), assertions=tuple(A[:2])), Q3, K)
                     ).principal.nom == "inconnue"
    # rq-021#5 : une troisième personne, établie distincte, contredit « seul »
    A5 = A + [Assertion("it", type_("t", "oc:personne")), Assertion("dj", distinct("t", "j")),
              Assertion("dh", distinct("t", "h"))]
    r5 = r2 + [Referent("t", "individu", introduit_par="it")]
    assert I.evaluer(Cas("c", Description("d", referents=tuple(r5), assertions=tuple(A5)), Q3, K)
                     ).principal.nom == "contradictoire"


def test_incompatibilite_indexee_par_le_moment():
    """Étude § 6.2 (ee-002, variante de temps) : « vêtu » maintenant, « nu » au moment du don, antérieur : aucun
    appui négatif ; au même moment, dans la même situation : un appui négatif. L'ancrage est exclusif (RS 6)."""
    K = Connaissances("k", (Incompatibilite("inc", "oc:vetu", "oc:nu", "etat", ("porteur", "moment", "contexte"),
                                            source=Source("à valider")),))
    refs = [Referent("s0", "situation"), Referent("m", "individu", RACINE, "s0", "im"),
            Referent("v", "etat", RACINE, "s0", "iv")]

    def cas(anc):
        A = [Assertion("im", type_("m", "oc:mendiant")), Assertion("iv", type_("v", "oc:vetu")),
             Assertion("rv", role("v", "porteur", "m")), Assertion("av", ancrage("v", anc))]
        S = V("S")
        Q = Definition("nu", variables=(("Z", "individu"), ("S", "etat"), ("T", "situation")),
                       suffisante=et(type_(V("Z"), "oc:mendiant"), type_(S, "oc:nu"), role(S, "porteur", V("Z")),
                                     dans(S, V("T")), dans(V("Z"), V("T")), ancrage(S, "anterieure")))
        return Cas("c", Description("d", referents=tuple(refs), assertions=tuple(A)), Q, K)
    def refutation_par_l_incompatibilite(c):
        """Une réfutation certifiée qui ne lie pas S : celle de la proposition niée que fonde l'incompatibilité."""
        p = I.evaluer(c).profils[RACINE]
        return any(l.c_moins and "S" not in dict(l.sigma) and "Z" in dict(l.sigma)
                   for cl in p.classes for b in cl.resultat.branches for l in b.lignes)
    assert not refutation_par_l_incompatibilite(cas("en_cours"))
    assert refutation_par_l_incompatibilite(cas("anterieure"))
    assert I.evaluer(cas("anterieure")).principal.nom == "ecartee"


def test_revele_refutation_pour_des_referents():
    """Ce que l'interpréteur a révélé (§ 7) : le statut local R est l'« écartée pour ces référents » de NOYAU
    § 4.4 (déf. 5), et la déf. 10 en fait `ecartee` pour la notation (ℓ⁻ = 3), sans distinguer une réfutation
    fermée (σ vide : « aucun ange ») d'une réfutation qui porte sur un référent qu'aucun autre atome ne retient.
    Ici, « vêtu maintenant » et « nu, antérieur » : l'incompatibilité ne s'applique pas (autre moment), mais
    l'exclusivité de l'ancrage réfute « S = l'état vêtu » pour l'atome ancrage(S, antérieure) ; rien d'autre n'étant
    dit, Syn = ecartee. Le jugement de référence serait inconnue. L'interpréteur suit la version 1.1 à la lettre et
    le signale par l'attribut refutation_fermee = False et la liste des réfutations citées."""
    K = Connaissances("k", ())
    refs = [Referent("s0", "situation"), Referent("m", "individu", RACINE, "s0", "im"),
            Referent("v", "etat", RACINE, "s0", "iv")]
    A = [Assertion("im", type_("m", "oc:mendiant")), Assertion("iv", type_("v", "oc:vetu")),
         Assertion("rv", role("v", "porteur", "m")), Assertion("av", ancrage("v", "en_cours"))]
    S = V("S")
    Q = Definition("nu", variables=(("Z", "individu"), ("S", "etat")),
                   suffisante=et(type_(V("Z"), "oc:mendiant"), type_(S, "oc:nu"), role(S, "porteur", V("Z")),
                                 ancrage(S, "anterieure")))
    s = I.evaluer(Cas("c", Description("d", referents=tuple(refs), assertions=tuple(A)), Q, K)).principal
    assert s.nom == "ecartee" and not s.refutation_fermee
    assert all(x.get("S") == frozenset({"v"}) for _, x in s.refutations)
    # une réfutation fermée, elle, est signalée comme telle (mn-004 au niveau (a))
    c = exemple_mn004_b()
    a = replace(c, description=replace(c.description, contraintes=(exclusion("ctx", "d1", ["oc:personne_sainte",
                                                                                           "oc:investisseur"],
                                                                             "jugement (a)"),)),
                definition=replace(c.definition, contraintes=(exclusion("ctxq", "d2", ["oc:personne_sainte",
                                                                                      "oc:investisseur"],
                                                                        "jugement (a)"),)))
    s = I.evaluer(a).principal
    assert s.nom == "ecartee" and s.refutation_fermee and s.refutations == [(0, {})]


def test_hypothese_typique_et_non_attestee_gardent_leur_nature():
    """Définition 4, la règle de conservation : une connaissance typique et une inclusion non attestée fondent
    des hypothèses de leur nature, jamais fondues dans une autre."""
    refs = [Referent("x", "individu", introduit_par="a")]
    A = [Assertion("a", type_("x", "oc:tonsure"))]
    Q = Definition("moine", variables=(("X", "individu"),), suffisante=type_(X, "oc:moine"))
    K1 = Connaissances("k", (Typique("t", "oc:tonsure", "oc:moine", "type", Source("t")),))
    s = I.evaluer(cas_simple(A, refs, Q, K1)).principal
    assert s.nom == "etablie_sous_hypotheses" and [h.nature for _, h in s.hypotheses] == ["connaissance_typique"]
    K2 = Connaissances("k", (Inclusion("i", "oc:tonsure", "oc:moine", Source("glose"), "non_attestee"),))
    s = I.evaluer(cas_simple(A, refs, Q, K2)).principal
    assert [h.nature for _, h in s.hypotheses] == ["connaissance_non_attestee"]


def test_d30_cas_particulier():
    """§ 5 : D30 (NOYAU 0.3) est le cas particulier « points de D sans contrainte, mot de la définition lu comme
    l'UNION des sens de son lemme ». Un lien certain (tous les sens de D atteignent l'union) donne etablie ; un
    lien seulement possible donne etablie_sous_hypotheses (le sens supposé est un cylindre). La décision 3 de la
    propriétaire fait du mot de la définition un point (des concepts ALTERNATIFS) : la même description donne alors
    etablie_sous_hypotheses."""
    K = Connaissances("k", (Inclusion("i1", "lion_animal", "felin", Source("WordNet")),
                            Inclusion("i2", "lion_celebrite", "personne", Source("WordNet"))))
    refs = [Referent("x", "individu", introduit_par="a")]
    A = [Assertion("a", type_("x", Alternatifs("pl")))]
    certain = [Point("pl", "D", "sens", ("lion_animal",))]
    possible = [Point("pl", "D", "sens", ("lion_animal", "lion_celebrite"))]
    union_lemme = Definition("felin", variables=(("X", "individu"),),
                             suffisante=type_(X, Union((Concept("felin"), Concept("chat_lemme")))))
    assert I.evaluer(cas_simple(A, refs, union_lemme, K, points=certain)).principal.nom == "etablie"
    s = I.evaluer(cas_simple(A, refs, union_lemme, K, points=possible)).principal
    assert s.nom == "etablie_sous_hypotheses" and s.couverture_plus == [{"pl": ("lion_animal",)}]
    # le même lemme des deux côtés : l'union des sens de « lion » (D30) établit ; un point (décision 3) non
    q_union = Definition("lion", variables=(("X", "individu"),),
                         suffisante=type_(X, Union((Concept("lion_animal"), Concept("lion_celebrite")))))
    assert I.evaluer(cas_simple(A, refs, q_union, K, points=possible)).principal.nom == "etablie"
    q_point = replace(q_union, suffisante=type_(X, Alternatifs("ql")),
                      points=(Point("ql", "Δ", "sens", ("lion_animal", "lion_celebrite")),))
    s = I.evaluer(cas_simple(A, refs, q_point, K, points=possible)).principal
    assert s.nom == "etablie_sous_hypotheses" and len(s.couverture_plus) == 2
