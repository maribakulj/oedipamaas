"""Les générateurs aléatoires de l'oracle de propriétés (graine fixe, bibliothèque standard) :
des descriptions, des définitions, des K et des points, petits, bien formés (RF1 à RF31), qui exercent chaque
construction du langage (docs/LANGAGE_REFERENCE.md). Ils tirent des cas ; ils n'en écrivent pas les réponses.
"""
from __future__ import annotations

import random
from dataclasses import replace

from semantique_reference.json_concret import exclusion, exclusion_conjointe, implication
from semantique_reference.syntaxe import (RACINE, Alias, Alternative, Alternatifs, Antonymie, Assertion, Atome,
                                          Cas, Compte, Concept, Conjonction, Connaissances, Contexte, Definition,
                                          DefinitionK, Description, Distinction, Et, Existe, Garde, Inclusion,
                                          Incompatibilite, Non, OppositionTypique, Ou, Point, Preference,
                                          Proposition, Provenance, Qualification, Quantification, Referent, Regle,
                                          Source, Typique, Union, Var, NATURES_NON_LEXICALES, ancrage, distinct,
                                          meme, meme_individu, nom, propriete, relation, role, type_)

CONCEPTS = [f"c{k}" for k in range(7)]
RELATIONS = ["rel_a", "rel_b"]
CLES = ["k1", "k2", "k3"]
SRC = Source("generateur", "tirage", "aucune")


def tirer_K(rng: random.Random, concepts=CONCEPTS) -> Connaissances:
    """Un K tiré : une hiérarchie (avec, parfois, un cycle et une inclusion non attestée), des incompatibilités,
    une règle, une définition conceptuelle, une connaissance typique, des alias et une distinction, et des entrées
    sans effet (antonymie, opposition typique)."""
    e = []
    n = 0
    for i, c in enumerate(concepts):
        for d in concepts[i + 1:]:
            if rng.random() < 0.22:
                n += 1
                e.append(Inclusion(f"inc{n}", c, d, SRC, "attestee" if rng.random() < 0.85 else "non_attestee"))
    for r in RELATIONS[:1]:
        e.append(Inclusion("inc_rel", "rel_a", "rel_b", SRC))
    if rng.random() < 0.15:
        e.append(Inclusion("inc_cycle", concepts[-1], concepts[2], SRC))
    if rng.random() < 0.6:
        a, b = rng.sample(concepts, 2)
        e.append(Incompatibilite("incomp1", a, b, rng.choice(["type", "propriete"]), ("porteur", "contexte"),
                                 source=SRC, statut="attestee" if rng.random() < 0.8 else "non_attestee"))
    if rng.random() < 0.3:
        a, b = rng.sample(concepts, 2)
        e.append(Incompatibilite("incomp_etat", a, b, "etat", ("porteur", "moment", "contexte"), source=SRC))
    if rng.random() < 0.5:
        a, b = rng.sample(concepts, 2)
        sorte = rng.choice(["implication", "condition_suffisante", "condition_necessaire",
                            "consequence_conditionnelle"])
        e.append(Regle("regle1", sorte, (("x", "individu"),), (type_(Var("x"), a),), (propriete(Var("x"), b),),
                       SRC, "attestee" if rng.random() < 0.8 else "non_attestee"))
    if rng.random() < 0.3:
        a, b = rng.sample(concepts, 2)
        e.append(DefinitionK("defk1", a, ("x", "individu"), suffisante=(propriete(Var("x"), b),),
                             necessaire=(propriete(Var("x"), b),),
                             statut_suffisance=rng.choice(["etablie", "non_etablie"]),
                             statut_necessite=rng.choice(["etablie", "non_etablie"]), source=SRC))
    if rng.random() < 0.3:
        a, b = rng.sample(concepts, 2)
        e.append(Typique("typ1", a, b, "type", SRC))
    if rng.random() < 0.4:
        e.append(Alias("al1", "k1", "k2", SRC))
    if rng.random() < 0.4:
        e.append(Distinction("dist1", "k1", "k3", SRC))
    if rng.random() < 0.2:
        a, b = rng.sample(concepts, 2)
        e += [Antonymie("ant1", a, b, SRC), OppositionTypique("opp1", a, b, SRC)]
    if any(isinstance(x, Alias) for x in e) and any(isinstance(x, Distinction) for x in e):
        e = [x for x in e if not (isinstance(x, Distinction) and x.cle1 == "k1" and x.cle2 == "k2")]
    return Connaissances("Kgen", tuple(e))


def _type(rng, points_sens, cote_points=None):
    r = rng.random()
    if points_sens and r < 0.3:
        return Alternatifs(rng.choice(points_sens))
    if r < 0.42:
        a, b = rng.sample(CONCEPTS, 2)
        return Union((Concept(a), Concept(b)))
    if r < 0.5:
        a, b = rng.sample(CONCEPTS, 2)
        return Conjonction((Concept(a), Concept(b)))
    return Concept(rng.choice(CONCEPTS))


def _qualif(rng, ctx, negatif=False, permettre_supposee=True):
    r = rng.random()
    enonc = "auteur" if rng.random() < 0.85 else "cite:X"
    if permettre_supposee and r < 0.1:
        return Qualification("neg" if negatif else "pos", "supposee", enonc, ctx, rng.choice(NATURES_NON_LEXICALES),
                             None)
    if r < 0.14:
        return Qualification("neg" if negatif else "pos", "possible", enonc, ctx)
    return Qualification("neg" if negatif else "pos", "affirme", enonc, ctx)


def tirer_description(rng: random.Random, n_refs=None, avec_points=True, avec_alternative=True,
                      avec_contextes=True) -> Description:
    """Une description tirée : 2 à 4 individus, parfois un état et son porteur, parfois un contexte de vision ouvert
    par l'état et un contexte d'histoire (non figuratif), des points de D (sens, structure) et leurs contraintes,
    des assertions de toutes les sortes, parfois une alternative de l'auteur."""
    n = n_refs or rng.randint(2, 4)
    ctxs = [Contexte(RACINE, "figuration")]
    refs, asser = [], []
    points, contraintes = [], []
    if avec_points:
        for k in range(rng.randint(0, 2)):
            dom = rng.sample(CONCEPTS, rng.randint(2, 3))
            if rng.random() < 0.2:
                dom.append("⊥")
            points.append(Point(f"p{k}", "D", "sens", tuple(dom), ancre=f"i_r{k}"))
        if rng.random() < 0.5:
            points.append(Point("q", "D", "structure", ("a", "b")))
    sens = [p.id for p in points if p.dimension == "sens"]
    situations = ["s1"] + (["s2"] if rng.random() < 0.4 else [])
    for s in situations:
        refs.append(Referent(s, "situation"))
    for k in range(n):
        rid = f"r{k}"
        sit = rng.choice(situations)
        refs.append(Referent(rid, "individu", RACINE, sit, f"i_{rid}"))
        t = Alternatifs(f"p{k}") if f"p{k}" in sens else _type(rng, sens)
        asser.append(Assertion(f"i_{rid}", type_(rid, t), _qualif(rng, RACINE, permettre_supposee=False),
                               provenance=Provenance("d", "fr", k, 10 * k, 10 * k + 5, f"mention {k}")))
    etat = rng.random() < 0.4
    if etat:
        refs.append(Referent("e1", "etat", RACINE, "s1", "i_e1"))
        asser.append(Assertion("i_e1", type_("e1", rng.choice(CONCEPTS))))
        asser.append(Assertion("por_e1", role("e1", "porteur", "r0")))
        if rng.random() < 0.7:
            asser.append(Assertion("anc_e1", ancrage("e1", rng.choice(["en_cours", "anterieure"]))))
    vision = avec_contextes and etat and rng.random() < 0.5
    if vision:
        ctxs.append(Contexte("v", "vision", RACINE, "e1"))
    histoire = avec_contextes and rng.random() < 0.3
    if histoire:
        ctxs.append(Contexte("h", "histoire", RACINE))
    contextes_possibles = [RACINE] * 4 + (["v"] if vision else []) + (["h"] if histoire else [])
    individus = [f"r{k}" for k in range(n)]
    m = 0
    for _ in range(rng.randint(2, 6)):
        m += 1
        aid = f"a{m}"
        ctx = rng.choice(contextes_possibles)
        x, y = rng.choice(individus), rng.choice(individus)
        r = rng.random()
        garde = Garde((("q", (rng.choice(["a", "b"]),)),)) if "q" in [p.id for p in points] and rng.random() < 0.35 \
            else Garde()
        if r < 0.22:
            asser.append(Assertion(aid, propriete(x, rng.choice(CONCEPTS)), _qualif(rng, ctx), garde))
        elif r < 0.34:
            asser.append(Assertion(aid, relation(rng.choice(RELATIONS), x, y), _qualif(rng, ctx), garde))
        elif r < 0.42:
            asser.append(Assertion(aid, nom(x, rng.choice(CLES)), _qualif(rng, ctx), garde))
        elif r < 0.54:
            asser.append(Assertion(aid, Proposition((), (type_(x, rng.choice(CONCEPTS)),)),
                                   _qualif(rng, ctx, negatif=True), garde))
        elif r < 0.6:
            asser.append(Assertion(aid, Proposition((("z", "individu"),), (type_(Var("z"), rng.choice(CONCEPTS)),)),
                                   _qualif(rng, ctx, negatif=True), garde))
        elif r < 0.68:
            asser.append(Assertion(aid, Proposition((), (propriete(x, rng.choice(CONCEPTS)),
                                                         relation(rng.choice(RELATIONS), x, y))),
                                   _qualif(rng, ctx, negatif=True), garde))
        elif r < 0.73:
            asser.append(Assertion(aid, Proposition((), (propriete(x, rng.choice(CONCEPTS)),)),
                                   _qualif(rng, ctx, negatif=True), garde))
        elif r < 0.78:
            asser.append(Assertion(aid, Quantification("aucun", None, ("z", "individu"),
                                                       (type_(Var("z"), rng.choice(CONCEPTS)),)),
                                   _qualif(rng, ctx), garde))
        elif r < 0.83 and x != y:
            asser.append(Assertion(aid, distinct(x, y), _qualif(rng, RACINE)))
        elif r < 0.88 and x != y:
            rx = next(q for q in refs if q.id == x)
            ry = next(q for q in refs if q.id == y)
            if rx.situation == ry.situation:
                asser.append(Assertion(aid, meme(x, y), Qualification(), garde))
            else:
                asser.append(Assertion(aid, meme_individu(x, y), _qualif(rng, RACINE)))
        elif r < 0.92:
            asser.append(Assertion(aid, Quantification("tous", None, ("z", "individu"),
                                                       (type_(Var("z"), rng.choice(CONCEPTS)),),
                                                       (propriete(Var("z"), rng.choice(CONCEPTS)),)),
                                   _qualif(rng, ctx), garde))
        else:
            asser.append(Assertion(aid, propriete(x, rng.choice(CONCEPTS)),
                                   Qualification("pos", "supposee", "auteur", ctx, rng.choice(NATURES_NON_LEXICALES),
                                                 f"hyp {aid}")))
    alternatives = []
    if avec_alternative and rng.random() < 0.2:
        x = rng.choice(individus)
        asser.append(Assertion("alt_a", propriete(x, rng.choice(CONCEPTS))))
        asser.append(Assertion("alt_b", propriete(x, rng.choice(CONCEPTS))))
        alternatives.append(Alternative("alt", (("alt_a",), ("alt_b",))))
    # les contraintes de D : sur un point, sur plusieurs points, une implication entre valeurs
    for p in points:
        if rng.random() < 0.3:
            contraintes.append(exclusion(f"x_{p.id}", p.id, [rng.choice(p.domaine)], "texte : catégorie"))
    if len(points) >= 2 and rng.random() < 0.4:
        a, b = rng.sample(points, 2)
        contraintes.append(exclusion_conjointe("xc", [{a.id: rng.choice(a.domaine), b.id: rng.choice(b.domaine)}],
                                               "lecteur : accord"))
    if len(points) >= 2 and rng.random() < 0.3:
        a, b = rng.sample(points, 2)
        contraintes.append(implication("imp", {a.id: rng.choice(a.domaine)}, b.id, [rng.choice(b.domaine)],
                                       b.domaine, "texte : identité dite"))
    prefs = []
    for p in points:
        if rng.random() < 0.5:
            prefs.append(Preference(f"pr_{p.id}", p.id, tuple(rng.sample(p.domaine, len(p.domaine))), (),
                                    "fréquence (une préférence)"))
    return Description("dgen", "fr", "", tuple(ctxs), tuple(refs), tuple(asser), tuple(alternatives),
                       tuple(points), tuple(contraintes), tuple(prefs))


def _feuille_type(rng, v, points_delta):
    t = _type(rng, points_delta)
    return Atome("type", (Var(v),), type=t)


def tirer_formule(rng: random.Random, variables, points_delta, profondeur=0, avec_non=True):
    """Une formule tirée sur des variables d'individus : un noyau conjonctif qui lie chaque variable, et des
    feuilles de toutes les sortes (∧, ∨, ¬ gardée, ∃, quantification explicite)."""
    noyau = [_feuille_type(rng, v, points_delta) for v in variables]
    extras = []
    compteur = iter(range(100))
    for _ in range(rng.randint(0, 3)):
        r = rng.random()
        v = rng.choice(variables)
        if r < 0.2:
            extras.append(Atome("propriete", (Var(v),), type=Concept(rng.choice(CONCEPTS))))
        elif r < 0.32 and len(variables) >= 2:
            a, b = rng.sample(variables, 2)
            extras.append(Atome("relation", (Var(a), Var(b)), type=Concept(rng.choice(RELATIONS))))
        elif r < 0.4:
            extras.append(Atome("nom", (Var(v),), valeur=rng.choice(CLES)))
        elif r < 0.5 and avec_non:
            extras.append(Non(Atome("type", (Var(v),), type=Concept(rng.choice(CONCEPTS)))))
        elif r < 0.56 and avec_non:
            w = f"w{next(compteur)}"
            extras.append(Non(Existe(((w, "individu"),), Atome("type", (Var(w),), type=Concept(rng.choice(CONCEPTS))))))
        elif r < 0.62 and len(variables) >= 2:
            a, b = rng.sample(variables, 2)
            extras.append(Atome(rng.choice(["distinct", "meme", "meme_individu"]), (Var(a), Var(b))))
        elif r < 0.7:
            c1, c2 = rng.sample(CONCEPTS, 2)
            extras.append(Ou((Atome("propriete", (Var(v),), type=Concept(c1)),
                              Atome("type", (Var(v),), type=Concept(c2)))))
        elif r < 0.75 and avec_non:
            u = f"u{next(compteur)}"
            extras.append(Compte(rng.choice(["au_moins", "aucun"]), rng.choice([1, 2]), (u, "individu"),
                                 Atome("type", (Var(u),), type=Concept(rng.choice(CONCEPTS)))))
        elif r < 0.8 and avec_non:
            extras.append(Non(Et((Atome("propriete", (Var(v),), type=Concept(rng.choice(CONCEPTS))),
                                  Atome("type", (Var(v),), type=Concept(rng.choice(CONCEPTS)))))))
        else:
            extras.append(Atome("propriete", (Var(v),), type=Concept(rng.choice(CONCEPTS))))
    corps = noyau + extras
    rng.shuffle(corps)
    F = Et(tuple(corps)) if len(corps) > 1 else corps[0]
    if rng.random() < 0.25:
        G = Et(tuple(_feuille_type(rng, v, points_delta) for v in variables))
        F = Ou((F, G))
    return F


def tirer_definition(rng: random.Random, avec_points=True, avec_non=True) -> Definition:
    points = []
    if avec_points and rng.random() < 0.5:
        points.append(Point("pd", "Δ", "sens", tuple(rng.sample(CONCEPTS, 2))))
    variables = ["X"] if rng.random() < 0.45 else ["X", "Y"]
    F = tirer_formule(rng, variables, [p.id for p in points], avec_non=avec_non)
    contraintes = []
    if points and rng.random() < 0.2:
        contraintes.append(exclusion("x_pd", "pd", [points[0].domaine[0]], "place de la notation"))
    return Definition("qgen", "", "en", tuple((v, "individu") for v in variables), F, None,
                      points=tuple(points), contraintes=tuple(contraintes))


def tirer_cas(rng: random.Random, **kw) -> Cas:
    return Cas("gen", tirer_description(rng, **{k: v for k, v in kw.items() if k in
                                                ("n_refs", "avec_points", "avec_alternative", "avec_contextes")}),
               tirer_definition(rng, avec_points=kw.get("avec_points", True), avec_non=kw.get("avec_non", True)),
               tirer_K(rng))


def affaiblir(rng: random.Random, F, K: Connaissances):
    """Une formule plus faible (pour tirer des paires Q1 ⊆ Q2) : un conjoint retiré, ou un type généralisé par une
    inclusion de K, ou un membre ajouté à une union."""
    inc = [e for e in K.entrees if isinstance(e, Inclusion) and e.statut == "attestee"]

    def gen(t):
        if isinstance(t, Concept):
            sup = [e.sur for e in inc if e.sous == t.id]
            if sup and rng.random() < 0.6:
                return Concept(rng.choice(sup))
            if rng.random() < 0.3:
                return Union((t, Concept(rng.choice(CONCEPTS))))
        return t

    def rec(G):
        if isinstance(G, Atome):
            return replace(G, type=gen(G.type)) if G.type is not None else G
        if isinstance(G, Et):
            enfants = [rec(g) for g in G.enfants]
            garde = [g for g in enfants if not (isinstance(g, Atome) and g.pred == "type")]
            if len(enfants) > 1 and rng.random() < 0.4 and garde:
                enfants.remove(rng.choice(garde))
            return Et(tuple(enfants)) if len(enfants) > 1 else enfants[0]
        if isinstance(G, Ou):
            return Ou(tuple(rec(g) for g in G.enfants))
        return G
    return rec(F)
