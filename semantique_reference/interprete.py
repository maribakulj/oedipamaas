"""L'interpréteur de référence du langage (docs/LANGAGE_REFERENCE.md, § 3), indépendant du moteur Prolog.

Il réalise la sémantique la plus simple : énumérer Ω, garder les interprétations qui ne violent aucune contrainte dure,
résoudre la description et la définition sous chaque interprétation, calculer sous chacune un modèle de Belnap par
contexte (la clôture des faits signés), évaluer la définition, former le profil, appliquer la table. Lisible avant
d'être rapide. Chaque fonction cite la définition qu'elle réalise : « déf. n » renvoie à
docs/INTERPRETATIONS_ADMISSIBLES.md (version 1.1), « § n » et « RS n » au document du langage.

Il n'importe rien de oedipamaas/ ni de tests/oracle/.
"""
from __future__ import annotations

import itertools
from dataclasses import dataclass, field, replace
from typing import Optional

from .connaissances import ordre
from .syntaxe import (RACINE, SORTES_CONTEXTE_FIGURATIVES, SORTES_EVENTUALITE, VALEUR_INCONNUE, Alternatifs,
                      Assertion, Atome, Cas, Compte, Concept, Conjonction, Connaissances, Contrainte, Definition,
                      DefinitionK, Description, Et, Existe, Hypothese, Incompatibilite, Inconnu, INCONNU, Non, Ou,
                      Proposition, Quantification, Regle, RestrictionSelection, Selon, Typique, Union, Var)

# ==============================================================================================================
# § 3.1 Les interprétations : Ω, les contraintes dures, I (étude § 2.1, § 3.3, § 3.4)
# ==============================================================================================================


def points_du_cas(cas: Cas) -> list:
    """P = P_D ⊎ P_Δ (étude § 2.1)."""
    return list(cas.description.points) + list(cas.definition.points)


def omega(points) -> list:
    """Ω = ∏_{p ∈ P} V(p) (étude § 2.1). Les points dans l'ordre de leurs identifiants ; chaque i est un dict."""
    pts = sorted(points, key=lambda p: p.id)
    out = []
    for valeurs in itertools.product(*[p.domaine for p in pts]):
        out.append({p.id: v for p, v in zip(pts, valeurs)})
    return out


def viole(i: dict, c: Contrainte) -> bool:
    """i viole c si la restriction de i à pts(c) est une combinaison interdite (étude § 3.3, § 3.4)."""
    for combinaison in c.interdits:
        if all(i.get(p) == v for (p, v) in combinaison):
            return True
    return False


def contraintes_derivees(cas: Cas) -> list:
    """§ 3.1, RS 2 : les contraintes que K fonde. Une restriction de sélection attestée exclut une combinaison de
    valeurs (le sens du prédicat, le sens de l'argument) si une incompatibilité attestée de forme `type` sépare le
    type requis du type de la valeur, et seulement dans un contexte de son domaine de validité (étude § 3.3, § 4.5,
    § 3.7 (e)). Les gardes de l'assertion et des introductions sont ajoutées à la combinaison. Côté D seulement
    (côté Δ, les contraintes sont écrites ; § 3.12)."""
    D, K = cas.description, cas.connaissances
    o = ordre(K)
    ctx_sorte = {c.id: c.sorte for c in D.contextes}
    points = {p.id: p for p in D.points}
    refs = {r.id: r for r in D.referents}
    asser = {a.id: a for a in D.assertions}
    restrictions = [e for e in K.entrees if isinstance(e, RestrictionSelection) and e.statut == "attestee"]
    incomp = [e for e in K.entrees if isinstance(e, Incompatibilite) and e.statut == "attestee" and e.forme == "type"]
    if not restrictions or not incomp:
        return []

    def type_intro(rid):
        r = refs.get(rid)
        if r is None or r.introduit_par not in asser:
            return None, ()
        a = asser[r.introduit_par]
        if isinstance(a.contenu, Atome) and a.contenu.pred == "type":
            return a.contenu.type, a.garde.conditions
        return None, ()

    def valeurs(t):  # [(condition ou None, type concret)]
        if isinstance(t, Alternatifs) and t.point in points:
            return [((t.point, v), Concept(v) if v != VALEUR_INCONNUE else INCONNU) for v in points[t.point].domaine]
        if t is None:
            return []
        return [(None, t)]

    def incompatible(requis, t):
        for inc in incomp:
            for (x, y) in ((inc.a, inc.b), (inc.b, inc.a)):
                if o.sous(Concept(requis), Concept(x)) is not None and o.sous(t, Concept(y)) is not None:
                    return inc
        return None

    out = []
    for a in D.assertions:
        c = a.contenu
        if not (isinstance(c, Atome) and c.pred == "role" and a.qualification.polarite == "pos"):
            continue
        e, x = c.args
        te, ge = type_intro(e)
        tx, gx = type_intro(x)
        for R in restrictions:
            if R.role != c.valeur or ctx_sorte.get(a.qualification.contexte) not in R.domaine:
                continue
            interdits = []
            for (ce, ve) in valeurs(te):
                if isinstance(ve, Inconnu) or o.sous(ve, Concept(R.predicat)) is None:
                    continue
                for (cx, vx) in valeurs(tx):
                    if isinstance(vx, Inconnu):
                        continue
                    inc = incompatible(R.requis, vx)
                    if inc is None:
                        continue
                    base = [p for p in (ce, cx) if p is not None]
                    gardes = list(a.garde.conditions) + list(ge) + list(gx)
                    for comb in itertools.product(*[[(p, v) for v in vs] for (p, vs) in gardes]):
                        tout = tuple(sorted(set(base) | set(comb)))
                        # une combinaison qui donne deux valeurs à un même point est vide : elle n'interdit rien
                        if len({p for p, _ in tout}) == len(tout):
                            interdits.append(tout)
            if interdits:
                out.append(Contrainte(f"rs:{R.id}:{a.id}", "restriction_de_selection", tuple(sorted(set(interdits))),
                                      source=f"{R.id} + incompatibilité attestée", sorte="restriction_de_selection"))
    return out


def contraintes_du_cas(cas: Cas) -> list:
    """Les contraintes dures : celles de D, celles de Δ, et celles que K fonde (§ 3.1)."""
    return list(cas.description.contraintes) + list(cas.definition.contraintes) + contraintes_derivees(cas)


def cle_preference(i: dict, preferences) -> tuple:
    """L'ordre des préférences (étude § 4.4) : il n'ordonne que l'examen et l'affichage, jamais I (T19)."""
    cle = []
    for pr in preferences:
        if pr.point is not None and pr.ordre:
            v = i.get(pr.point)
            cle.append(pr.ordre.index(v) if v in pr.ordre else len(pr.ordre))
        elif pr.couplage:
            vs = [i.get(p) for p in pr.couplage]
            cle.append(0 if len(set(vs)) == 1 else 1)
    return tuple(cle)


def interpretations_admissibles(cas: Cas, points=None, contraintes=None) -> list:
    """I = { i ∈ Ω : i ne viole aucune contrainte dure } (étude § 3.4, T1). Ordonné par les préférences, puis par
    l'ordre de Ω ; l'ensemble ne dépend d'aucune préférence."""
    pts = points_du_cas(cas) if points is None else points
    cs = contraintes_du_cas(cas) if contraintes is None else contraintes
    I = [i for i in omega(pts) if not any(viole(i, c) for c in cs)]
    prefs = list(cas.description.preferences) + list(cas.definition.preferences)
    rang = {id(i): n for n, i in enumerate(I)}
    return sorted(I, key=lambda i: (cle_preference(i, prefs), rang[id(i)]))


def composantes(points, contraintes) -> list:
    """Les composantes de l'hypergraphe des contraintes dures (étude § 3.7 (e), règle e1)."""
    parent = {p.id: p.id for p in points}

    def racine(x):
        while parent[x] != x:
            x = parent[x]
        return x
    for c in contraintes:
        pts = sorted({p for comb in c.interdits for (p, _) in comb if p in parent})
        for a, b in zip(pts, pts[1:]):
            ra, rb = racine(a), racine(b)
            if ra != rb:
                parent[max(ra, rb)] = min(ra, rb)
    groupes = {}
    for p in parent:
        groupes.setdefault(racine(p), set()).add(p)
    return sorted(groupes.values(), key=lambda g: min(g))


# ==============================================================================================================
# § 3.2 La résolution : G_i = ρ(D, i), Q_i = ρ(Δ, i) (étude § 2.1)
# ==============================================================================================================


def resoudre_type(t, i: dict):
    """Sous i, un type d'ensemble de concepts alternatifs devient le concept choisi (ou ⊥) ; une union et une
    conjonction restent ce qu'elles sont (§ 1.4)."""
    if isinstance(t, Alternatifs):
        v = i[t.point]
        return INCONNU if v == VALEUR_INCONNUE else Concept(v)
    if isinstance(t, Union):
        return Union(tuple(resoudre_type(m, i) for m in t.membres))
    if isinstance(t, Conjonction):
        return Conjonction(tuple(resoudre_type(m, i) for m in t.membres))
    return t


def resoudre_atome(a: Atome, i: dict) -> Atome:
    return replace(a, type=resoudre_type(a.type, i)) if a.type is not None else a


def garde_vraie(garde, i: dict) -> bool:
    """Une garde est vraie sous i si chacune de ses conditions l'est (§ 1.6, G 10)."""
    return all(i.get(p) in vals for (p, vals) in garde.conditions)


def resoudre_contenu(c, i):
    if isinstance(c, Atome):
        return resoudre_atome(c, i)
    if isinstance(c, Proposition):
        return replace(c, atomes=tuple(resoudre_atome(a, i) for a in c.atomes))
    if isinstance(c, Quantification):
        return replace(c, restriction=tuple(resoudre_atome(a, i) for a in c.restriction),
                       portee=tuple(resoudre_atome(a, i) for a in c.portee))
    return c


def resoudre_description(D: Description, i: dict) -> Description:
    """ρ(D, i) : les assertions dont la garde est vraie, les types résolus ; plus aucun point (§ 3.2)."""
    asser = tuple(replace(a, contenu=resoudre_contenu(a.contenu, i), garde=replace(a.garde, conditions=()))
                  for a in D.assertions if garde_vraie(a.garde, i))
    presentes = {a.id for a in asser}
    alts = tuple(replace(al, branches=tuple(tuple(x for x in b if x in presentes) for b in al.branches))
                 for al in D.alternatives)
    return replace(D, assertions=asser, alternatives=alts, points=(), contraintes=(), preferences=())


def resoudre_formule(F, i: dict):
    """ρ(Δ, i) : un `Selon` devient la formule de la valeur choisie ; les types sont résolus (§ 3.2)."""
    if F is None:
        return None
    if isinstance(F, Atome):
        return resoudre_atome(F, i)
    if isinstance(F, Et):
        return Et(tuple(resoudre_formule(f, i) for f in F.enfants))
    if isinstance(F, Ou):
        return Ou(tuple(resoudre_formule(f, i) for f in F.enfants))
    if isinstance(F, Non):
        return Non(resoudre_formule(F.corps, i))
    if isinstance(F, Existe):
        return Existe(F.variables, resoudre_formule(F.corps, i))
    if isinstance(F, Compte):
        return replace(F, restriction=resoudre_formule(F.restriction, i), portee=resoudre_formule(F.portee, i))
    if isinstance(F, Selon):
        for (v, f) in F.cas:
            if v == i[F.point]:
                return resoudre_formule(f, i)
        raise ValueError(f"Selon({F.point}) sans cas pour {i[F.point]}")
    raise TypeError(F)


def resoudre_definition(Dl: Definition, i: dict) -> Definition:
    return replace(Dl, suffisante=resoudre_formule(Dl.suffisante, i),
                   necessaire=resoudre_formule(Dl.necessaire if Dl.necessaire is not None else Dl.suffisante, i),
                   points=(), contraintes=(), preferences=())


# ==============================================================================================================
# § 3.3 Les fondements d'un appui
# ==============================================================================================================


@dataclass(frozen=True)
class Fond:
    """Ce sur quoi repose un appui (déf. 2, déf. 3) : les énonciateurs (`auteur`, `cite:X`), les assertions
    employées (les prémisses), les entrées de K, les hypothèses non lexicales (avec leur nature, déf. 4)."""
    enonciateurs: frozenset = frozenset()
    bases: frozenset = frozenset()
    k: frozenset = frozenset()
    hyps: frozenset = frozenset()

    def __or__(self, o: "Fond") -> "Fond":
        return Fond(self.enonciateurs | o.enonciateurs, self.bases | o.bases, self.k | o.k, self.hyps | o.hyps)

    def domine(self, o: "Fond") -> bool:
        return (self.hyps <= o.hyps and self.enonciateurs <= o.enonciateurs and self.bases <= o.bases
                and self.k <= o.k)


VIDE = Fond()
MAX_OPTIONS = 24


def minimiser(options) -> list:
    """Les fondements minimaux (aucun n'est dominé par un autre) ; borné pour rester lisible."""
    uniques = list(dict.fromkeys(options))
    out = [o for o in uniques if not any(p is not o and p != o and p.domine(o) for p in uniques)]
    out.sort(key=lambda o: (len(o.hyps), len(o.enonciateurs), len(o.bases), sorted(map(str, o.hyps)),
                            sorted(o.enonciateurs), sorted(o.bases)))
    return out[:MAX_OPTIONS]


def produit(a: list, b: list) -> list:
    return minimiser([x | y for x in a for y in b])


AUTEUR = "auteur"


def de_l_auteur(o: Fond) -> bool:
    return o.enonciateurs <= {AUTEUR}


# ==============================================================================================================
# § 3.3 Le modèle de Belnap sous (i, w) : la base des faits signés, close par K et par le langage
# ==============================================================================================================

PREDS_TYPES = ("type", "propriete", "relation")
PREDS_SANS_CONTEXTE = ("dans", "succede", "meme", "distinct", "meme_individu")


@dataclass(frozen=True)
class Fait:
    """Un appui positif : un atome clos (des référents), un contexte, ses fondements."""
    atome: Atome
    ctx: Optional[str]
    fond: Fond


@dataclass(frozen=True)
class Niee:
    """Une proposition niée : ¬∃ locales. ∧ atomes, dans un contexte, avec ses fondements. Toute négation du langage
    s'y ramène (§ 3.3, RS 6) : une assertion négative, « aucun », la contraposition d'une règle de K, une
    incompatibilité indexée, l'exclusivité de l'ancrage et de la situation."""
    locales: tuple  # noms
    atomes: tuple
    ctx: Optional[str]
    fond: Fond


@dataclass(frozen=True)
class Enonce:
    """Une quantification énoncée gardée telle quelle, pour les quantifications de la requête (§ 3.5, RS 11)."""
    q: Quantification
    ctx: str
    fond: Fond


class BudgetEpuise(Exception):
    pass


class Budget:
    """Le budget du calcul (étude § 3.7 (f)) : un nombre de substitutions examinées."""

    def __init__(self, n: Optional[int]):
        self.reste = n

    def depenser(self, n: int = 1):
        if self.reste is None:
            return
        if self.reste < n:
            self.reste = 0
            raise BudgetEpuise()
        self.reste -= n


def _repr(classe) -> str:
    return min(classe)


class Base:
    """§ 3.3 : le modèle de Belnap de la description résolue ρ(D, i), dans la branche w de ses alternatives, clos
    par K et par les propriétés du langage. Il porte, par contexte, des faits positifs et des propositions niées,
    chacun avec ses fondements."""

    def __init__(self, D: Description, K: Connaissances, w: dict):
        self.D, self.K, self.ordre = D, K, ordre(K)
        self.contextes = {c.id: c for c in D.contextes}
        dans_alt = {x: (al.id, n) for al in D.alternatives for n, b in enumerate(al.branches) for x in b}
        self.assertions = {a.id: a for a in D.assertions
                           if a.id not in dans_alt or w.get(dans_alt[a.id][0]) == dans_alt[a.id][1]}
        self.referents = {r.id: r for r in D.referents}
        self.situations = [r.id for r in D.referents if r.sorte == "situation"]
        # Les référents présents et le fondement de leur introduction (RS 1 : un appui dit de quoi il parle).
        self.intro: dict[str, Fond] = {}
        for r in D.referents:
            if r.introduit_par is None:
                self.intro[r.id] = VIDE
                continue
            a = self.assertions.get(r.introduit_par)
            if a is None or a.qualification.polarite != "pos" or a.qualification.modalite == "possible":
                continue
            self.intro[r.id] = self._fond_propre(a)
        # Les classes de coréférence (RS 1) : la fermeture des `meme` affirmés de l'auteur entre présents.
        parent = {r: r for r in self.intro}

        def racine(x):
            while parent[x] != x:
                x = parent[x]
            return x
        for a in self.assertions.values():
            c = a.contenu
            q = a.qualification
            if isinstance(c, Atome) and c.pred == "meme" and q.polarite == "pos" and q.modalite == "affirme":
                x, y = c.args
                if x in parent and y in parent:
                    rx, ry = racine(x), racine(y)
                    if rx != ry:
                        parent[max(rx, ry)] = min(rx, ry)
        groupes = {}
        for r in parent:
            groupes.setdefault(racine(r), set()).add(r)
        self._classe = {r: frozenset(groupes[racine(r)]) for r in parent}
        self.faits: dict[str, list] = {}
        self._cles_faits = set()
        self.niees: list = []
        self._cles_niees = set()
        self.enonces: list = []
        self._construire()
        self._cloturer()

    # --- les fondements -------------------------------------------------------------------------------------
    def _fond_propre(self, a: Assertion) -> Fond:
        q = a.qualification
        hyps = frozenset()
        if q.modalite == "supposee":
            hyps = frozenset({Hypothese(q.nature, q.contenu or a.id)})
        return Fond(frozenset({q.enonciateur}), frozenset({a.id}), frozenset(), hyps)

    def _fond_de(self, a: Assertion, ids) -> Optional[Fond]:
        """Le fondement d'un appui tiré de a : le sien et l'introduction de chaque référent qu'il cite (RS 1). None si
        un référent cité n'est pas présent : l'assertion n'appuie rien."""
        f = self._fond_propre(a)
        for x in ids:
            if x not in self.intro:
                return None
            if self.referents.get(x) is not None and self.referents[x].introduit_par == a.id:
                continue
            f = f | self.intro[x]
        return f

    def classe(self, x) -> Optional[frozenset]:
        if isinstance(x, frozenset):
            return x
        return self._classe.get(x)

    def classes(self, sorte=None) -> list:
        vues = []
        for c in dict.fromkeys(self._classe.values()):
            if sorte is None or compatible(sorte, self.sorte_classe(c)):
                vues.append(c)
        return vues

    def sorte_classe(self, c) -> str:
        return self.referents[_repr(c)].sorte

    # --- l'ajout ---------------------------------------------------------------------------------------------
    def ajouter_fait(self, f: Fait) -> bool:
        cle = (f.atome, f.ctx, f.fond.enonciateurs, f.fond.hyps)
        if cle in self._cles_faits:
            return False
        self._cles_faits.add(cle)
        self.faits.setdefault(f.atome.pred, []).append(f)
        return True

    def ajouter_niee(self, n: Niee) -> bool:
        cle = (n.locales, n.atomes, n.ctx, n.fond.enonciateurs, n.fond.hyps)
        if cle in self._cles_niees:
            return False
        self._cles_niees.add(cle)
        self.niees.append(n)
        return True

    # --- RS 1 à RS 5 : ce que disent les assertions ----------------------------------------------------------
    def _construire(self):
        for a in self.assertions.values():
            q, c = a.qualification, a.contenu
            if q.modalite == "possible":
                continue  # RS 1 : seule une assertion affirmée (ou supposée, sous son hypothèse) appuie
            ctx = q.contexte
            if isinstance(c, Atome) and q.polarite == "pos":
                f = self._fond_de(a, [x for x in c.args if isinstance(x, str)])
                if f is None:
                    continue
                if c.pred == "meme":
                    continue  # la coréférence fait les classes ; elle n'est pas un fait de plus
                self.ajouter_fait(Fait(c, None if c.pred in PREDS_SANS_CONTEXTE else ctx, f))
            elif isinstance(c, Proposition) and q.polarite == "neg":
                consts = [x for at in c.atomes for x in at.args if isinstance(x, str)]
                f = self._fond_de(a, consts)
                if f is None:
                    continue
                self.ajouter_niee(Niee(tuple(n for (n, _) in c.locales), c.atomes, ctx, f))
            elif isinstance(c, Quantification) and q.polarite == "pos":
                consts = [x for at in c.restriction + c.portee for x in at.args if isinstance(x, str)] + list(c.membres)
                f = self._fond_de(a, consts)
                if f is None:
                    continue
                self.enonces.append(Enonce(c, ctx, f))
                if c.quant == "aucun":  # RS 4 : « aucun » est la négation d'une proposition, sur son domaine
                    x = c.variable[0]
                    atomes = c.restriction + c.portee
                    if c.situation is not None:
                        atomes = atomes + (Atome("dans", (Var(x), c.situation)),)
                    self.ajouter_niee(Niee((x,), atomes, ctx, f))
        # RS 5 : la situation d'un référent est un fait de structure, unique.
        for rid, r in self.referents.items():
            if rid in self.intro and r.situation is not None:
                self.ajouter_fait(Fait(Atome("dans", (rid, r.situation)), None, self.intro[rid]))

    # --- la clôture (RS 6 à RS 10) ---------------------------------------------------------------------------
    def _cloturer(self):
        for _ in range(12):
            change = False
            change |= self._rs_langage()
            change |= self._rs_regles()
            change |= self._rs_typiques()
            change |= self._rs_incompatibilites()
            change |= self._rs_quantifications()
            if not change:
                return

    def _contextes_actifs(self):
        return sorted({f.ctx for fs in self.faits.values() for f in fs if f.ctx is not None} | {RACINE})

    def _rs_langage(self) -> bool:
        """RS 6 : une éventualité n'a qu'un ancrage par rapport au moment de sa situation (étude § 6.2 : « une
        incompatibilité du langage », non une connaissance de K). L'appartenance à une situation, elle, n'est pas un
        fondement négatif : l'étude (§ 6.3, « et seulement cela ») ne l'y range pas ; une version antérieure de cet
        interpréteur l'avait fait, et le test de pi-003 l'a montré (§ 7 du document)."""
        change = False
        from .syntaxe import ANCRAGES
        for f in list(self.faits.get("ancrage", [])):
            for autre in ANCRAGES:
                if autre != f.atome.valeur:
                    change |= self.ajouter_niee(Niee((), (Atome("ancrage", f.atome.args, valeur=autre),), f.ctx,
                                                     f.fond))
        return change

    def _fond_k(self, e, nature_defaut="connaissance_non_attestee", contenu=None) -> Fond:
        hyps = frozenset()
        if getattr(e, "statut", "attestee") != "attestee":
            hyps = frozenset({Hypothese(nature_defaut, contenu or e.id)})
        return Fond(frozenset(), frozenset(), frozenset({e.id}), hyps)

    def _regles_effectives(self):
        """Les règles de K, et celles que fondent les définitions conceptuelles (G 21d, G 21e)."""
        for e in self.K.entrees:
            if isinstance(e, Regle):
                yield e, self._fond_k(e), e.sorte != "consequence_conditionnelle"
            elif isinstance(e, DefinitionK):
                x, s = e.variable
                tete = (Atome("type", (Var(x),), type=Concept(e.concept)),)
                vars_ = (e.variable,) + tuple(e.locales)
                if e.suffisante:
                    fk = self._fond_k(e)
                    if e.statut_suffisance != "etablie":
                        fk = fk | Fond(hyps=frozenset({Hypothese("abduction", f"suffisance de {e.id}")}))
                    yield Regle(e.id + ":suff", "condition_suffisante", vars_, e.suffisante, tete), fk, True
                if e.necessaire:
                    fk = self._fond_k(e)
                    if e.statut_necessite != "etablie":
                        fk = fk | Fond(hyps=frozenset({Hypothese("abduction", f"nécessité de {e.id}")}))
                    yield Regle(e.id + ":nec", "condition_necessaire", vars_, tete, e.necessaire), fk, True

    def _rs_regles(self) -> bool:
        """RS 7 : une règle de K transmet le vrai de la prémisse à la conclusion ; sauf une conséquence
        conditionnelle, elle transmet aussi le faux de la conclusion à la prémisse (la contraposition ; étude § 6.3,
        point 5 ; docs/FONDEMENTS_SEMANTIQUES.md § 3.3)."""
        change = False
        for (r, fk, contrapose) in self._regles_effectives():
            sortes = dict(r.variables)
            for ctx in self._contextes_actifs():
                for (sigma, opts) in solutions_selection(self, tuple(r.premisse), {}, ctx, sortes):
                    for at in r.conclusion:
                        if all(sigma.get(v.nom) is not None for v in at.args if isinstance(v, Var)):
                            clos = instancier(at, sigma)
                            for o in opts:
                                change |= self.ajouter_fait(Fait(clos, None if clos.pred in PREDS_SANS_CONTEXTE
                                                                 else ctx, o | fk))
                if not contrapose:
                    continue
                vp = {v.nom for at in r.premisse for v in at.args if isinstance(v, Var)}
                vc = sorted({v.nom for at in r.conclusion for v in at.args if isinstance(v, Var)} & vp)
                for valeurs in itertools.product(*[self.classes(sortes.get(v)) for v in vc]):
                    tau = dict(zip(vc, valeurs))
                    for o in refutations_selection(self, tuple(r.conclusion), tau, ctx):
                        locales = tuple(sorted(vp - set(vc)))
                        atomes = tuple(instancier(at, tau) for at in r.premisse)
                        change |= self.ajouter_niee(Niee(locales, atomes, ctx, o | fk))
        return change

    def _rs_typiques(self) -> bool:
        """RS 8 : une connaissance typique ne déduit rien ; elle fonde une hypothèse de nature connaissance_typique
        (étude, déf. 4)."""
        change = False
        for e in self.K.entrees:
            if not isinstance(e, Typique) or e.forme not in ("type", "propriete"):
                continue
            for f in list(self.faits.get(e.forme, [])):
                if self.ordre.sous(f.atome.type, Concept(e.a)) is None:
                    continue
                x = f.atome.args[0]
                h = Fond(hyps=frozenset({Hypothese("connaissance_typique", f"{e.id}({x})")}), k=frozenset({e.id}))
                change |= self.ajouter_fait(Fait(Atome(e.forme, (x,), type=Concept(e.b)), f.ctx, f.fond | h))
        return change

    def _rs_incompatibilites(self) -> bool:
        """RS 9 : une incompatibilité attestée et indexée donne la négation de l'autre type pour le même porteur,
        dans le même contexte, et au même moment si elle est indexée par le moment (étude § 6.2). Les deux sens."""
        change = False
        for e in self.K.entrees:
            if not isinstance(e, Incompatibilite):
                continue
            fk = self._fond_k(e)
            for (a, b) in ((e.a, e.b), (e.b, e.a)):
                if e.forme in ("type", "propriete", "relation"):
                    for f in list(self.faits.get(e.forme, [])):
                        if self.ordre.sous(f.atome.type, Concept(a)) is None:
                            continue
                        n = Niee((), (Atome(e.forme, f.atome.args, type=Concept(b)),), f.ctx, f.fond | fk)
                        change |= self.ajouter_niee(n)
                elif e.forme == "etat":
                    for f in list(self.faits.get("type", [])):
                        ev = f.atome.args[0]
                        r = self.referents.get(ev)
                        if r is None or r.sorte != "etat" or self.ordre.sous(f.atome.type, Concept(a)) is None:
                            continue
                        for p in self.faits.get("role", []):
                            if p.atome.valeur != "porteur" or p.ctx != f.ctx or \
                                    self.classe(p.atome.args[0]) != self.classe(ev):
                                continue
                            x = p.atome.args[1]
                            atomes = [Atome("type", (Var("_S"),), type=Concept(b)),
                                      Atome("role", (Var("_S"), x), valeur="porteur")]
                            fond = f.fond | p.fond | fk
                            if "moment" in e.indexation:
                                anc = [g for g in self.faits.get("ancrage", []) if g.ctx == f.ctx and
                                       self.classe(g.atome.args[0]) == self.classe(ev)]
                                if r.situation is None or not anc:
                                    continue  # sans moment connu, l'incompatibilité indexée ne s'applique pas
                                g = anc[0]
                                atomes += [Atome("dans", (Var("_S"), r.situation)),
                                           Atome("ancrage", (Var("_S"),), valeur=g.atome.valeur)]
                                fond = fond | g.fond
                            change |= self.ajouter_niee(Niee(("_S",), tuple(atomes), f.ctx, fond))
        return change

    def _domaine(self, q: Quantification, ctx: str) -> list:
        """Le domaine d'une quantification énoncée : les classes qui ont un fait dans son contexte (et dans sa
        situation si elle est donnée) ; étude § 6.4 (le domaine par défaut est la situation du chemin)."""
        out = []
        for c in self.classes(q.variable[1] if q.variable[1] not in ("entite", None) else None):
            if q.variable[1] == "entite" and self.sorte_classe(c) not in ("individu", "collection"):
                continue
            if not any(f.ctx == ctx and any(self.classe(x) == c for x in f.atome.args if isinstance(x, str))
                       for fs in self.faits.values() for f in fs):
                continue
            if q.situation is not None and not any(self.referents[m].situation == q.situation for m in c):
                continue
            out.append(c)
        return out

    def _rs_quantifications(self) -> bool:
        """RS 10 : « tous » (et « tous sauf ») déduit la portée de chaque élément du domaine qui satisfait la
        restriction, et contrapose ; « seul » nie la restriction de tout élément du domaine établi distinct des
        seuls (étude § 6.4). Un élément « sauf » n'est retiré que s'il est établi distinct des exceptions."""
        change = False
        for en in self.enonces:
            q, ctx = en.q, en.ctx
            x = q.variable[0]
            membres = [self.classe(m) for m in q.membres if self.classe(m) is not None]
            for c in self._domaine(q, ctx):
                distinctions = []
                if q.quant in ("tous_sauf", "seul"):
                    if c in membres:
                        continue
                    ok = True
                    for m in membres:
                        d = distinction(self, c, m)
                        if not d:
                            ok = False
                            break
                        distinctions.append(d[0])
                    if not ok:
                        continue
                fd = en.fond
                for d in distinctions:
                    fd = fd | d
                sigma = {x: c}
                if q.quant in ("tous", "tous_sauf"):
                    for (s2, opts) in solutions_selection(self, q.restriction, sigma, ctx, {x: q.variable[1]}):
                        for at in q.portee:
                            clos = instancier(at, s2)
                            for o in opts:
                                change |= self.ajouter_fait(Fait(clos, None if clos.pred in PREDS_SANS_CONTEXTE
                                                                 else ctx, o | fd))
                    for o in refutations_selection(self, q.portee, sigma, ctx):
                        n = Niee((), tuple(instancier(at, sigma) for at in q.restriction), ctx, o | fd)
                        change |= self.ajouter_niee(n)
                elif q.quant == "seul":
                    n = Niee((), tuple(instancier(at, sigma) for at in q.restriction), ctx, fd)
                    change |= self.ajouter_niee(n)
        return change


def compatible(sorte_var, sorte_ref) -> bool:
    """La sorte d'une variable admet-elle celle d'un référent ? `entite` : individu ou collection (§ 1.1)."""
    if sorte_var is None:
        return True
    if sorte_var == "entite":
        return sorte_ref in ("individu", "collection")
    return sorte_var == sorte_ref


def instancier(at: Atome, sigma: dict) -> Atome:
    """Remplace les variables liées par le représentant de leur classe (ou l'identifiant du contexte)."""
    args = []
    for x in at.args:
        if isinstance(x, Var) and sigma.get(x.nom) is not None:
            v = sigma[x.nom]
            args.append(_repr(v) if isinstance(v, frozenset) else v)
        else:
            args.append(x)
    ctx = at.contexte
    if isinstance(ctx, Var) and sigma.get(ctx.nom) is not None:
        ctx = sigma[ctx.nom]
    return replace(at, args=tuple(args), contexte=ctx)


# ==============================================================================================================
# § 3.4 Les appuis positifs (RS 1, RS 12)
# ==============================================================================================================


def _valeur_terme(base: Base, t, sigma: dict):
    """La valeur d'un terme : la classe d'un référent, ou celle que σ donne à une variable (None si non liée)."""
    if isinstance(t, Var):
        return sigma.get(t.nom)
    if t in base.contextes and t not in base._classe:
        return t
    return base.classe(t)


def _ctx_effectif(at: Atome, sigma: dict, ctx):
    if at.pred in PREDS_SANS_CONTEXTE:
        return None
    if at.contexte is None:
        return ctx
    if isinstance(at.contexte, Var):
        return sigma.get(at.contexte.nom, "?non-lie")
    return at.contexte


def _hyps_k(ids) -> frozenset:
    return frozenset(Hypothese("connaissance_non_attestee", i) for i in ids)


def distinction(base: Base, c1, c2) -> list:
    """Les fondements d'une distinction entre deux classes : établie par le texte (`distinct`), ou documentaire
    (deux clés que K dit de deux individus, aucune classe ne portant la clé de l'autre ; NOYAU § 4.1)."""
    out = []
    for f in base.faits.get("distinct", []):
        a, b = (base.classe(x) for x in f.atome.args)
        if (a, b) in ((c1, c2), (c2, c1)):
            out.append(f.fond)
    noms1 = [f for f in base.faits.get("nom", []) if base.classe(f.atome.args[0]) == c1]
    noms2 = [f for f in base.faits.get("nom", []) if base.classe(f.atome.args[0]) == c2]
    for f1 in noms1:
        for f2 in noms2:
            d = base.ordre.distinction_documentee(f1.atome.valeur, f2.atome.valeur)
            if d is None:
                continue
            if any(base.ordre.meme_cle(g.atome.valeur, f2.atome.valeur) for g in noms1) or \
               any(base.ordre.meme_cle(g.atome.valeur, f1.atome.valeur) for g in noms2):
                continue
            out.append(f1.fond | f2.fond | Fond(k=frozenset({d.id})))
    return minimiser(out)


def _chemin_meme_individu(base: Base, c1, c2) -> list:
    """Un chemin de `meme_individu` entre deux classes (une équivalence, sans fusion ; étude § 7.4)."""
    if c1 == c2:
        return [VIDE]
    voisins = {}
    for f in base.faits.get("meme_individu", []):
        a, b = (base.classe(x) for x in f.atome.args)
        voisins.setdefault(a, []).append((b, f.fond))
        voisins.setdefault(b, []).append((a, f.fond))
    vus = {c1: VIDE}
    file = [c1]
    while file:
        x = file.pop(0)
        for (y, fd) in voisins.get(x, ()):
            if y not in vus:
                vus[y] = vus[x] | fd
                file.append(y)
    return [vus[c2]] if c2 in vus else []


def appuis(base: Base, at: Atome, sigma: dict, ctx) -> list:
    """Les appuis positifs d'un atome entièrement lié sous σ, dans le contexte ctx (§ 3.4, RS 12) :
    - un atome typé est appuyé par des faits du même prédicat, de mêmes arguments, dans le même contexte, dont la
      conjonction des types est incluse dans le type demandé (le treillis de K) ;
    - les autres, par un fait égal (un nom à alias près) ;
    - meme : la même classe ; distinct : une distinction ; meme_individu : un chemin d'identités ;
    - contexte_ouvert(C, E) : le contexte C est un enfant du contexte d'évaluation, ouvert par E, de la sorte dite."""
    vals = [_valeur_terme(base, t, sigma) for t in at.args]
    if any(v is None for v in vals):
        return []
    ce = _ctx_effectif(at, sigma, ctx)
    p = at.pred
    if p == "meme":
        return [VIDE] if vals[0] == vals[1] else []
    if p == "distinct":
        return distinction(base, vals[0], vals[1])
    if p == "meme_individu":
        return _chemin_meme_individu(base, vals[0], vals[1])
    if p == "contexte_ouvert":
        c = base.contextes.get(vals[0])
        if c is None or c.parent != ctx or c.sorte != at.valeur or c.ouvert_par not in vals[1]:
            return []
        return [base.intro.get(c.ouvert_par, VIDE)]
    candidats = [f for f in base.faits.get(p, []) if f.ctx == ce and
                 all(base.classe(x) == v for x, v in zip(f.atome.args, vals))]
    if p in PREDS_TYPES:
        out, reussis = [], []
        for k in (1, 2, 3):
            for combo in itertools.combinations(range(len(candidats)), k):
                if any(set(r) <= set(combo) for r in reussis):
                    continue
                types = [candidats[j].atome.type for j in combo]
                t = types[0] if k == 1 else Conjonction(tuple(types))
                r = base.ordre.sous(t, at.type)
                if r is None:
                    continue
                reussis.append(combo)
                fd = Fond(hyps=_hyps_k(r))
                for j in combo:
                    fd = fd | candidats[j].fond
                out.append(fd)
        return minimiser(out)
    out = []
    for f in candidats:
        if p == "nom":
            if base.ordre.meme_cle(f.atome.valeur, at.valeur):
                out.append(f.fond)
        elif f.atome.valeur == at.valeur:
            out.append(f.fond)
    return minimiser(out)


def liaisons_positives(base: Base, at: Atome, sigma: dict, ctx, sortes: dict) -> list:
    """Les extensions de σ qui donnent à l'atome un appui positif, avec leurs fondements : (σ', options)."""
    libres = [t.nom for t in at.args if isinstance(t, Var) and sigma.get(t.nom) is None]
    if isinstance(at.contexte, Var) and sigma.get(at.contexte.nom) is None:
        return []
    if not libres:
        o = appuis(base, at, sigma, ctx)
        return [(sigma, o)] if o else []
    candidats = []
    p = at.pred
    if p == "contexte_ouvert":
        for c in base.contextes.values():
            if c.parent == ctx and c.sorte == at.valeur and c.ouvert_par in base._classe:
                candidats.append((c.id, base.classe(c.ouvert_par)))
    elif p == "meme":
        a, b = at.args
        va, vb = _valeur_terme(base, a, sigma), _valeur_terme(base, b, sigma)
        if va is not None:
            candidats.append((va, va))
        elif vb is not None:
            candidats.append((vb, vb))
    elif p == "meme_individu":
        for c1 in base.classes():
            for c2 in base.classes():
                candidats.append((c1, c2))
    else:
        ce = _ctx_effectif(at, sigma, ctx)
        for f in base.faits.get(p, []):
            if f.ctx == ce:
                candidats.append(tuple(base.classe(x) for x in f.atome.args))
    out = []
    vus = set()
    for valeurs in candidats:
        s2 = dict(sigma)
        ok = True
        for t, v in zip(at.args, valeurs):
            if isinstance(t, Var):
                if s2.get(t.nom) is None:
                    sv = sortes.get(t.nom)
                    if isinstance(v, frozenset):
                        if sv == "contexte" or not compatible(sv, base.sorte_classe(v)):
                            ok = False
                            break
                    elif sv not in (None, "contexte"):
                        ok = False
                        break
                    s2[t.nom] = v
                elif s2[t.nom] != v:
                    ok = False
                    break
            elif _valeur_terme(base, t, sigma) != v:
                ok = False
                break
        if not ok:
            continue
        cle = tuple(sorted((k, str(sorted(v)) if isinstance(v, frozenset) else v) for k, v in s2.items()))
        if cle in vus:
            continue
        vus.add(cle)
        o = appuis(base, at, s2, ctx)
        if o:
            out.append((s2, o))
    return out


# ==============================================================================================================
# § 3.5 Les formules : sélections, appuis des feuilles, valeurs D⁺ et D⁻
# ==============================================================================================================


def selections(F) -> list:
    """Les sélections de F (sa forme disjonctive) : chaque sélection est une suite de feuilles — atomes, Non,
    Existe, Compte (§ 3.5). Un `Selon` doit avoir été résolu."""
    if isinstance(F, (Atome, Non, Existe, Compte)):
        return [(F,)]
    if isinstance(F, Et):
        out = [()]
        for f in F.enfants:
            out = [a + b for a in out for b in selections(f)]
        return out
    if isinstance(F, Ou):
        return [s for f in F.enfants for s in selections(f)]
    raise TypeError(f"formule non résolue : {F!r}")


def libres(F) -> set:
    """Les variables libres d'une formule (§ 1.8)."""
    if F is None:
        return set()
    if isinstance(F, Atome):
        s = {t.nom for t in F.args if isinstance(t, Var)}
        if isinstance(F.contexte, Var):
            s.add(F.contexte.nom)
        return s
    if isinstance(F, (Et, Ou)):
        return set().union(*[libres(f) for f in F.enfants]) if F.enfants else set()
    if isinstance(F, Non):
        return libres(F.corps)
    if isinstance(F, Existe):
        return libres(F.corps) - {n for (n, _) in F.variables}
    if isinstance(F, Compte):
        return (libres(F.restriction) | libres(F.portee)) - {F.variable[0]} | {m.nom for m in F.membres}
    if isinstance(F, Selon):
        return set().union(*[libres(f) for (_, f) in F.cas])
    if isinstance(F, tuple):
        return set().union(*[libres(f) for f in F]) if F else set()
    raise TypeError(F)


def sortes_de(F, acc=None) -> dict:
    """Les sortes déclarées par les Existe et les Compte d'une formule."""
    acc = {} if acc is None else acc
    if isinstance(F, (Et, Ou)):
        for f in F.enfants:
            sortes_de(f, acc)
    elif isinstance(F, Non):
        sortes_de(F.corps, acc)
    elif isinstance(F, Existe):
        acc.update(dict(F.variables))
        sortes_de(F.corps, acc)
    elif isinstance(F, Compte):
        acc[F.variable[0]] = F.variable[1]
        sortes_de(F.restriction, acc)
        sortes_de(F.portee, acc)
    return acc


def _atomes_conjonctifs(F):
    """Les atomes d'une formule purement conjonctive (sinon None)."""
    if isinstance(F, Atome):
        return (F,)
    if isinstance(F, Et) and all(isinstance(f, (Atome, Et)) for f in F.enfants):
        out = ()
        for f in F.enfants:
            a = _atomes_conjonctifs(f)
            if a is None:
                return None
            out += a
        return out
    return None


def _choisir(base, restants, sigma):
    """L'ordre de liaison (lisibilité d'abord) : un atome qui lie ; les autres feuilles une fois leurs variables liées."""
    def lies(f):
        return all(sigma.get(v) is not None for v in libres(f))
    for f in restants:
        if isinstance(f, Atome) and f.pred == "contexte_ouvert":
            return f
    for f in restants:
        if isinstance(f, Atome) and f.pred not in ("meme", "meme_individu", "distinct") and \
                not (isinstance(f.contexte, Var) and sigma.get(f.contexte.nom) is None) and \
                (any(isinstance(t, Var) and sigma.get(t.nom) is not None for t in f.args) or lies(f)):
            return f
    for f in restants:
        if isinstance(f, Atome) and f.pred not in ("meme", "meme_individu", "distinct") and \
                not (isinstance(f.contexte, Var) and sigma.get(f.contexte.nom) is None):
            return f
    for f in restants:
        if isinstance(f, Atome) and (lies(f) or f.pred in ("meme", "meme_individu", "distinct")):
            if f.pred == "meme" and not lies(f) and not any(sigma.get(v) is not None for v in libres(f)):
                continue
            return f
    for f in restants:
        if lies(f):
            return f
    return None


def solutions_selection(base: Base, S: tuple, sigma0: dict, ctx, sortes: dict) -> list:
    """Les arbres positifs d'une sélection (déf. 1) : les σ ⊇ σ0 qui lient ses variables et donnent à chaque
    feuille un appui positif, avec leurs fondements minimaux."""
    out = []

    def rec(restants, sigma, opts):
        if not restants:
            out.append((sigma, opts))
            return
        f = _choisir(base, restants, sigma)
        if f is None:
            return
        reste = tuple(g for g in restants if g is not f)
        if isinstance(f, Atome):
            for (s2, o) in liaisons_positives(base, f, sigma, ctx, sortes):
                no = produit(opts, o)
                if no:
                    rec(reste, s2, no)
        else:
            o = options_pos_feuille(base, f, sigma, ctx, sortes)
            if o:
                rec(reste, sigma, produit(opts, o))
    rec(tuple(S), dict(sigma0), [VIDE])
    return out


def solutions(base: Base, F, sigma0: dict, ctx, sortes: dict) -> list:
    """Les arbres positifs de F : ceux de ses sélections."""
    out = []
    for S in selections(F):
        out.extend(solutions_selection(base, S, sigma0, ctx, sortes))
    return out


def options_pos(base: Base, F, sigma: dict, ctx, sortes: dict) -> list:
    """D⁺(F, σ) avec ses fondements (déf. 1) : une sélection dont chaque feuille a un appui positif sous σ, sans
    lier de variable de plus."""
    out = []
    for S in selections(F):
        if not all(sigma.get(v) is not None for f in S for v in libres(f)):
            continue
        combos = [VIDE]
        for f in S:
            if isinstance(f, Atome):
                o = appuis(base, f, sigma, ctx)
            else:
                o = options_pos_feuille(base, f, sigma, ctx, sortes)
            combos = produit(combos, o)
            if not combos:
                break
        out.extend(combos)
    return minimiser(out)


def options_neg(base: Base, F, sigma: dict, ctx, sortes: dict) -> list:
    """D⁻(F, σ) avec ses fondements (§ 3.5, RS 13) : chaque sélection de F est réfutée sous σ."""
    combos = [VIDE]
    for S in selections(F):
        o = refutations_selection(base, S, sigma, ctx, sortes)
        combos = produit(combos, o)
        if not combos:
            return []
    return combos


def options_pos_feuille(base: Base, f, sigma, ctx, sortes) -> list:
    """L'appui positif d'une feuille non atomique (§ 3.5) :
    Non(G) : la négation échange les appuis : D⁺(¬G) = D⁻(G) ;
    Existe(x̄, G) : un arbre positif de G qui étend σ sur x̄ ;
    Compte : RS 11."""
    if isinstance(f, Non):
        return options_neg(base, f.corps, sigma, ctx, sortes)
    if isinstance(f, Existe):
        s2 = dict(sortes)
        s2.update(dict(f.variables))
        sig = {k: v for k, v in sigma.items() if k not in dict(f.variables)}
        return minimiser([o for (_, os) in solutions(base, f.corps, sig, ctx, s2) for o in os])
    if isinstance(f, Compte):
        return compte_pos(base, f, sigma, ctx, sortes)
    if isinstance(f, Atome):
        return appuis(base, f, sigma, ctx)
    raise TypeError(f)


def options_neg_feuille(base: Base, f, sigma, ctx, sortes) -> list:
    """L'appui négatif d'une feuille non atomique : D⁻(¬G) = D⁺(G) ; D⁻(∃x̄ G) = D⁻(G) sans lier x̄ (une
    réfutation qui vaut pour toute valeur) ; Compte : RS 11."""
    if isinstance(f, Non):
        return options_pos(base, f.corps, sigma, ctx, sortes)
    if isinstance(f, Existe):
        sig = {k: v for k, v in sigma.items() if k not in dict(f.variables)}
        s2 = dict(sortes)
        s2.update(dict(f.variables))
        return options_neg(base, f.corps, sig, ctx, s2)
    if isinstance(f, Compte):
        return compte_neg(base, f, sigma, ctx, sortes)
    raise TypeError(f)


# --- les négations : la proposition niée qu'une sélection entraîne (§ 3.5, RS 13) -----------------------------

def homomorphismes(base: Base, source: tuple, cible: tuple, sigma: dict, ctx_source, ctx_eval,
                   locales=None, etendre=False, fixe=None) -> list:
    """Les homomorphismes h de la proposition `source` dans les atomes `cible` (§ 3.5, RS 13) : chaque atome source
    a une image cible qui l'entraîne (même prédicat, même valeur, même contexte, type de la cible ⊑ type de la
    source) ; une constante (un référent) de la source va sur un terme cible dont la classe est la sienne ; une
    variable locale de la source va, de façon cohérente, sur n'importe quel terme cible, lié ou non.
    Avec `etendre`, une variable cible non liée peut être liée pour recevoir une constante ; le résultat donne alors
    l'extension de σ. Rend [(extension, hypothèses de K non attestées)]."""
    locales = set(locales or ())
    out = []

    def rec(k, m, ext, hyps):
        if k == len(source):
            out.append((dict(ext), hyps))
            return
        a = source[k]
        for b in cible:
            if b.pred != a.pred or len(b.args) != len(a.args):
                continue
            if a.pred == "nom":
                if not base.ordre.meme_cle(a.valeur, b.valeur):
                    continue
            elif a.valeur != b.valeur:
                continue
            if a.pred not in PREDS_SANS_CONTEXTE and ctx_source is not None:
                s_ctx = dict(sigma)
                s_ctx.update(ext)
                if _ctx_effectif(b, s_ctx, ctx_eval) != ctx_source:
                    continue
            h2 = hyps
            if a.type is not None:
                r = base.ordre.sous(b.type, a.type)
                if r is None:
                    continue
                h2 = h2 | _hyps_k(r)
            m2, ext2, ok = dict(m), dict(ext), True
            for (sa, sb) in zip(a.args, b.args):
                if isinstance(sa, Var) and sa.nom in locales:
                    if sa.nom in m2:
                        if m2[sa.nom] != sb:
                            ok = False
                            break
                    else:
                        if fixe and sa.nom in fixe and fixe[sa.nom] != sb:
                            ok = False
                            break
                        m2[sa.nom] = sb
                    continue
                cs = _valeur_terme(base, sa, sigma) if not isinstance(sa, Var) else sigma.get(sa.nom)
                if cs is None:
                    ok = False
                    break
                if isinstance(sb, Var):
                    vb = ext2.get(sb.nom, sigma.get(sb.nom))
                    if vb is None:
                        if etendre:
                            ext2[sb.nom] = cs
                            continue
                        ok = False
                        break
                    if vb != cs:
                        ok = False
                        break
                elif _valeur_terme(base, sb, sigma) != cs:
                    ok = False
                    break
            if ok:
                rec(k + 1, m2, ext2, h2)
    rec(0, {}, {}, frozenset())
    return out


def _niees_unaires(base: Base, at: Atome):
    for n in base.niees:
        if len(n.atomes) == 1 and n.atomes[0].pred == at.pred:
            yield n


def refutations_atome(base: Base, at: Atome, sigma: dict, ctx, etendre=False) -> list:
    """L'appui négatif d'un atome seul (§ 3.5, RS 13, cas unaire) :
    - un atome typé est réfuté si son type est inclus dans l'union des types niés de son prédicat pour les mêmes
      arguments (le treillis de K : nier A et nier B nie A ∪ B) ;
    - les autres, par une proposition niée égale ;
    - meme et meme_individu, par une distinction (la même classe dite deux donne B) ; distinct n'est jamais réfuté
      (la même classe : une substitution invalide, non une réfutation ; NOYAU § 4.1).
    Avec `etendre`, rend [(extension de σ, fondement)]."""
    p = at.pred
    if p in ("meme", "meme_individu"):
        vals = [_valeur_terme(base, t, sigma) for t in at.args]
        out = []
        if all(v is not None for v in vals):
            out = [({}, o) for o in distinction(base, vals[0], vals[1])]
        elif etendre:
            for f in base.faits.get("distinct", []):
                a, b = (base.classe(x) for x in f.atome.args)
                for (x, y) in ((a, b), (b, a)):
                    ext, ok = {}, True
                    for t, v in zip(at.args, (x, y)):
                        cur = _valeur_terme(base, t, sigma)
                        if cur is None and isinstance(t, Var):
                            if ext.get(t.nom, v) != v:
                                ok = False
                            ext[t.nom] = v
                        elif cur != v:
                            ok = False
                    if ok:
                        out.append((ext, f.fond))
        return out if etendre else minimiser([o for (_, o) in out])
    if p in ("distinct", "contexte_ouvert"):
        return []
    # les extensions possibles : celles qu'exige chaque proposition niée unaire, et l'extension vide
    groupes = {(): []}
    for n in _niees_unaires(base, at):
        for (ext, hk) in homomorphismes(base, n.atomes, (replace(at, type=n.atomes[0].type)
                                                       if at.type is not None else at,), sigma, n.ctx, ctx,
                                        locales=n.locales, etendre=etendre):
            cle = tuple(sorted((k, tuple(sorted(v)) if isinstance(v, frozenset) else v) for k, v in ext.items()))
            groupes.setdefault(cle, []).append((n, ext, hk))
    out = []
    for cle, membres in groupes.items():
        ext = dict(membres[0][1]) if membres else {}
        applicables = list(membres) + [m for c2, ms in groupes.items() if c2 != cle and set(c2) < set(cle)
                                       for m in ms]
        if not applicables:
            continue
        if at.type is None:
            for (n, e, hk) in applicables:
                out.append((ext, n.fond | Fond(hyps=_hyps_k(hk))))
            continue
        reussis = []
        for k in (1, 2, 3):
            for combo in itertools.combinations(range(len(applicables)), k):
                if any(set(r) <= set(combo) for r in reussis):
                    continue
                types = [applicables[j][0].atomes[0].type for j in combo]
                t = types[0] if k == 1 else Union(tuple(types))
                r = base.ordre.sous(at.type, t)
                if r is None:
                    continue
                reussis.append(combo)
                fd = Fond(hyps=_hyps_k(r))
                for j in combo:
                    fd = fd | applicables[j][0].fond | Fond(hyps=_hyps_k(applicables[j][2]))
                out.append((ext, fd))
    if etendre:
        return out
    return minimiser([o for (e, o) in out if not e])


def _atomes_de_selection(S: tuple) -> tuple:
    """Les atomes d'une sélection, et ceux du corps conjonctif de ses feuilles Existe (leurs variables locales
    restent non liées) : ce que la sélection entraîne."""
    out = []
    for f in S:
        if isinstance(f, Atome):
            out.append(f)
        elif isinstance(f, Existe):
            a = _atomes_conjonctifs(f.corps)
            if a:
                out.extend(a)
    return tuple(out)


def refutations_selection(base: Base, S: tuple, sigma: dict, ctx, sortes=None, etendre=False) -> list:
    """Une sélection est réfutée sous σ (§ 3.5, RS 13) si l'une de ses feuilles l'est, ou si ses atomes entraînent
    une proposition niée de la base (un homomorphisme de la proposition dans la sélection : étude § 6.4, D41). La
    réfutation porte sur la conjonction entière. Avec `etendre`, rend les extensions de σ qui la réfutent."""
    sortes = sortes or {}
    out = []
    for f in S:
        if isinstance(f, Atome):
            r = refutations_atome(base, f, sigma, ctx, etendre)
            out.extend(r)
        elif etendre:
            out.extend(_extensions_feuille(base, f, sigma, ctx, sortes))
        else:
            out.extend(options_neg_feuille(base, f, sigma, ctx, sortes))
    atomes = _atomes_de_selection(S)
    for n in base.niees:
        if len(n.atomes) == 1:
            continue  # le cas unaire est celui de refutations_atome (et des feuilles Existe)
        for (ext, hk) in homomorphismes(base, n.atomes, atomes, sigma, n.ctx, ctx, locales=n.locales,
                                        etendre=etendre):
            if etendre:
                out.append((ext, n.fond | Fond(hyps=_hyps_k(hk))))
            elif not ext:
                out.append(n.fond | Fond(hyps=_hyps_k(hk)))
    if etendre:
        return out
    return minimiser(out)


def _extensions_feuille(base, f, sigma, ctx, sortes) -> list:
    """Les extensions de σ qui réfutent une feuille non atomique (pour la recherche des réfutations minimales)."""
    out = []
    if isinstance(f, Non):
        for (s2, os) in solutions(base, f.corps, sigma, ctx, sortes):
            ext = {k: v for k, v in s2.items() if k not in sigma and k in libres(f)}
            for o in os:
                out.append((ext, o))
    elif isinstance(f, Existe):
        loc = dict(f.variables)
        s2 = dict(sortes)
        s2.update(loc)
        for ext in liaisons_refutantes(base, f.corps, {k: v for k, v in sigma.items() if k not in loc}, ctx, s2):
            if not any(k in loc for k in ext):
                e = {k: v for k, v in ext.items() if k not in sigma}
                out.append((e, VIDE))
    elif isinstance(f, Compte):
        vs = sorted(v for v in libres(f) if sigma.get(v) is None)
        for valeurs in itertools.product(*[base.classes(sortes.get(v)) for v in vs]):
            s2 = dict(sigma)
            s2.update(dict(zip(vs, valeurs)))
            for o in compte_neg(base, f, s2, ctx, sortes):
                out.append((dict(zip(vs, valeurs)), o))
    return out


def _compatibles(a: dict, b: dict) -> bool:
    return all(b.get(k, v) == v for k, v in a.items())


def _minimales(liaisons: list) -> list:
    uniques = []
    for l in liaisons:
        if l not in uniques:
            uniques.append(l)
    return [l for l in uniques if not any(m != l and all(l.get(k) == v for k, v in m.items()) for m in uniques)]


def liaisons_refutantes(base: Base, F, sigma0: dict, ctx, sortes: dict) -> list:
    """Les extensions minimales de σ0 sous lesquelles F est réfutée (§ 3.5) : chaque sélection l'est (déf. 1,
    les arbres négatifs, généralisés aux propositions niées)."""
    # On ne garde pas que les extensions minimales : une extension plus grande peut porter une réfutation d'un
    # autre fondement (de l'auteur, quand la plus petite n'est que d'une source citée), et la certification en dépend.
    par_selection = []
    for S in selections(F):
        exts = _uniques([e for (e, _) in refutations_selection(base, S, sigma0, ctx, sortes, etendre=True)])
        if not exts:
            return []
        par_selection.append(exts)
    combos = [dict()]
    for exts in par_selection:
        nouveaux = []
        for c in combos:
            for e in exts:
                if _compatibles(c, e):
                    d = dict(c)
                    d.update(e)
                    nouveaux.append(d)
        combos = _uniques(nouveaux)
    return [c for c in combos if _bien_sortee(base, c, sortes)]


def _bien_sortee(base: Base, sigma: dict, sortes: dict) -> bool:
    """Chaque variable liée l'est à une valeur de sa sorte (RF20 ; une classe de référents, ou un contexte)."""
    for v, x in sigma.items():
        s = sortes.get(v)
        if isinstance(x, frozenset):
            if s == "contexte" or not compatible(s, base.sorte_classe(x)):
                return False
        elif s not in (None, "contexte"):
            return False
    return True


def _uniques(liaisons: list) -> list:
    out = []
    for l in liaisons:
        if l not in out:
            out.append(l)
    return out


# --- RS 11 : les quantifications de la requête ---------------------------------------------------------------

def _enonces(base, ctx, quants):
    return [en for en in base.enonces if en.ctx == ctx and en.q.quant in quants]


def _comme_constantes(atomes: tuple, sigma: dict) -> tuple:
    return tuple(instancier(a, sigma) for a in atomes)


def _entraine(base, source_atomes, source_locales, cible_atomes, ctx, fixe=None) -> list:
    """source est entraînée par cible : un homomorphisme de source dans cible (les variables de cible non liées)."""
    return homomorphismes(base, source_atomes, cible_atomes, {}, ctx, ctx, locales=source_locales, fixe=fixe)


def _distincts_deux_a_deux(base, classes_opts, n) -> list:
    out = []
    for combo in itertools.combinations(classes_opts, n):
        fd = [VIDE]
        ok = True
        for (c, os) in combo:
            fd = produit(fd, os)
        for (a, _), (b, _) in itertools.combinations(combo, 2):
            d = distinction(base, a, b)
            if not d:
                ok = False
                break
            fd = produit(fd, d)
        if ok:
            out.extend(fd)
    return minimiser(out)


def _solutions_quant(base, f: Compte, sigma, ctx, sortes, formule=None) -> list:
    x = f.variable[0]
    s2 = dict(sortes)
    s2[x] = f.variable[1]
    sig = {k: v for k, v in sigma.items() if k != x}
    par_classe = {}
    for (s, os) in solutions(base, formule if formule is not None else f.restriction, sig, ctx, s2):
        if s.get(x) is not None:
            par_classe.setdefault(s[x], []).extend(os)
    return [(c, minimiser(os)) for c, os in par_classe.items()]


def compte_pos(base: Base, f: Compte, sigma: dict, ctx, sortes: dict) -> list:
    """RS 11, l'appui positif d'une quantification de la requête :
    au_moins(n) : n solutions de la restriction deux à deux établies distinctes, ou un énoncé « au moins m » ou
      « exactement m » (m ≥ n) dont la description entraîne la restriction ;
    exactement(n) : un énoncé « exactement n » de description équivalente ;
    aucun x. R : D⁻(∃x R) ;
    tous x. R → P : un énoncé « tous » dont la restriction est plus large et la portée plus étroite ;
    seul x. R → x ∈ M : un énoncé « seul » dont les seuls sont parmi σ(M) et dont la restriction est plus large."""
    x = f.variable[0]
    R = _atomes_conjonctifs(f.restriction) if f.restriction is not None else None
    Rc = _comme_constantes(R, sigma) if R else None
    out = []
    if f.quant == "aucun":
        return options_neg(base, Existe((f.variable,), f.restriction), sigma, ctx, sortes)
    if f.quant == "au_moins":
        sols = _solutions_quant(base, f, sigma, ctx, sortes)
        if f.n <= 1:
            out.extend(o for (_, os) in sols for o in os)
        else:
            out.extend(_distincts_deux_a_deux(base, sols, f.n))
        if Rc:
            for en in _enonces(base, ctx, ("au_moins", "exactement")):
                if en.q.n is not None and en.q.n >= f.n:
                    y = en.q.variable[0]
                    phi = en.q.restriction + en.q.portee
                    if _entraine(base, Rc, (x,), phi, ctx, fixe={x: Var(y)}):
                        out.append(en.fond)
    elif f.quant == "exactement":
        if Rc:
            for en in _enonces(base, ctx, ("exactement",)):
                if en.q.n == f.n:
                    y = en.q.variable[0]
                    phi = en.q.restriction + en.q.portee
                    if _entraine(base, Rc, (x,), phi, ctx, fixe={x: Var(y)}) and \
                            _entraine(base, phi, (y,), tuple(replace(a, args=tuple(Var(x) if a2 == Var(x) else a2
                                                                                  for a2 in a.args)) for a in Rc),
                                      ctx, fixe={y: Var(x)}):
                        out.append(en.fond)
    elif f.quant == "tous":
        P = _atomes_conjonctifs(f.portee) if f.portee is not None else ()
        Pc = _comme_constantes(P, sigma) if P is not None else None
        if Rc is not None and Pc is not None:
            for en in _enonces(base, ctx, ("tous",)):
                y = en.q.variable[0]
                if _entraine(base, en.q.restriction, (y,), Rc, ctx, fixe={y: Var(x)}) and \
                        _entraine(base, Pc, (x,), en.q.portee, ctx, fixe={x: Var(y)}):
                    out.append(en.fond)
    elif f.quant == "seul":
        ms = [sigma.get(m.nom) for m in f.membres]
        if Rc is not None and all(m is not None for m in ms):
            for en in _enonces(base, ctx, ("seul",)):
                y = en.q.variable[0]
                seuls = [base.classe(e) for e in en.q.membres]
                if all(s in ms for s in seuls) and _entraine(base, en.q.restriction, (y,), Rc, ctx, fixe={y: Var(x)}):
                    out.append(en.fond)
    return minimiser(out)


def compte_neg(base: Base, f: Compte, sigma: dict, ctx, sortes: dict) -> list:
    """RS 11, l'appui négatif d'une quantification de la requête :
    au_moins(n) : D⁻(∃x R), ou un énoncé « exactement m » (m < n) dont la description est entraînée par R ;
    exactement(n) : un énoncé « exactement m » (m ≠ n) de description équivalente, n + 1 solutions distinctes,
      ou D⁻(∃x R) pour n ≥ 1 ;
    aucun x. R : D⁺(∃x R) ;
    tous x. R → P : un contre-exemple (R appuyé, P réfuté) ;
    seul x. R → x ∈ M : un élément qui satisfait R, établi distinct de chaque σ(M)."""
    x = f.variable[0]
    R = _atomes_conjonctifs(f.restriction) if f.restriction is not None else None
    Rc = _comme_constantes(R, sigma) if R else None
    out = []
    if f.quant == "aucun":
        return options_pos(base, Existe((f.variable,), f.restriction), sigma, ctx, sortes)
    if f.quant in ("au_moins", "exactement") and (f.n or 0) >= 1:
        out.extend(options_neg(base, Existe((f.variable,), f.restriction), sigma, ctx, sortes))
    if f.quant == "au_moins" and Rc:
        for en in _enonces(base, ctx, ("exactement",)):
            if en.q.n is not None and en.q.n < f.n:
                y = en.q.variable[0]
                phi = en.q.restriction + en.q.portee
                if _entraine(base, phi, (y,), Rc, ctx, fixe={y: Var(x)}):
                    out.append(en.fond)
    if f.quant == "exactement":
        sols = _solutions_quant(base, f, sigma, ctx, sortes)
        out.extend(_distincts_deux_a_deux(base, sols, f.n + 1) if f.n + 1 <= len(sols) else [])
        if Rc:
            for en in _enonces(base, ctx, ("exactement",)):
                if en.q.n is not None and en.q.n != f.n:
                    y = en.q.variable[0]
                    phi = en.q.restriction + en.q.portee
                    if _entraine(base, Rc, (x,), phi, ctx, fixe={x: Var(y)}) and \
                            _entraine(base, phi, (y,), Rc, ctx, fixe={y: Var(x)}):
                        out.append(en.fond)
    if f.quant == "tous" and f.portee is not None:
        for (c, os) in _solutions_quant(base, f, sigma, ctx, sortes):
            s2 = dict(sigma)
            s2[x] = c
            neg = options_neg(base, f.portee, s2, ctx, sortes)
            out.extend(produit(os, neg))
    if f.quant == "seul":
        ms = [sigma.get(m.nom) for m in f.membres]
        if all(m is not None for m in ms):
            for (c, os) in _solutions_quant(base, f, sigma, ctx, sortes):
                if c in ms:
                    continue
                acc = os
                for m in ms:
                    acc = produit(acc, distinction(base, c, m))
                out.extend(acc)
    return minimiser(out)


# ==============================================================================================================
# § 3.6 à § 3.8 Le résultat sous une interprétation : lignes, certification, statut local (déf. 2, 5)
# ==============================================================================================================

STATUTS_LOCAUX = ("E", "E_H", "R", "R_H", "B", "NC+", "NC-", "N", "?")


@dataclass(frozen=True)
class Ligne:
    """Une substitution examinée et ce qu'en dit le modèle (déf. 5) : la valeur de Belnap (D⁺, D⁻) sans
    hypothèse, les ensembles minimaux d'hypothèses sous lesquels elle est certifiée de chaque signe (C⁺, C⁻ ; une
    liste vide : pas certifiée ; [∅] : certifiée sans hypothèse), les énonciateurs de chaque signe, la sorte d'une
    contradiction, et si c'est une solution (σ lie exactement une sélection)."""
    sigma: tuple  # ((variable, classe ou contexte), …) trié
    d_plus: bool
    d_moins: bool
    c_plus: tuple
    c_moins: tuple
    enonc_plus: frozenset
    enonc_moins: frozenset
    contradiction: Optional[str]
    solution: bool
    preuves_plus: tuple = ()
    preuves_moins: tuple = ()

    @property
    def valeur(self) -> str:
        return {(False, False): "N", (True, False): "V", (False, True): "F", (True, True): "B"}[
            (self.d_plus, self.d_moins)]

    def sigma_dict(self) -> dict:
        return dict(self.sigma)


def _sigma_cle(sigma: dict) -> tuple:
    return tuple(sorted(sigma.items(), key=lambda kv: kv[0]))


def premisses_niees(base: Base, o: Fond) -> bool:
    """Une prémisse d'un appui est niée (déf. 2 ; NOYAU § 4.3) : une assertion employée, reprise telle qu'elle est
    dite, a un appui négatif (sous les hypothèses de l'appui)."""
    for b in o.bases:
        a = base.assertions.get(b)
        if a is None or not isinstance(a.contenu, Atome) or a.contenu.pred in ("meme", "distinct", "meme_individu"):
            continue
        at = a.contenu
        ctx = a.qualification.contexte
        for n in refutations_selection(base, (at,), {}, ctx):
            if n.hyps <= o.hyps:
                return True
    return False


def _hyps_signe(Dl: Definition, signe: str) -> Fond:
    """Une condition dont le statut n'est pas établi ne fonde qu'une hypothèse (§ 1.9 ; FS § 4 : une classification
    par une définition d'un autre statut est une abduction)."""
    if signe == "+" and Dl.statut_suffisance != "etablie":
        return Fond(hyps=frozenset({Hypothese("abduction", f"suffisance de {Dl.id}")}))
    if signe == "-" and Dl.statut_necessite != "etablie":
        return Fond(hyps=frozenset({Hypothese("abduction", f"nécessité de {Dl.id}")}))
    return VIDE


def ligne(base: Base, Dl: Definition, sigma: dict, ctx, sortes: dict, solution: bool) -> Ligne:
    """Les valeurs et les certifications d'une substitution (déf. 1, déf. 2, révisées au § 3.6) :
    val = (D⁺(suffisante, σ), D⁻(nécessaire, σ)) ;
    C⁺ sous H : une solution dont un arbre positif n'a que des appuis de l'auteur, de prémisses non niées, sous H,
      et aucun appui négatif de la définition sous σ et H ;
    C⁻ sous H : un arbre négatif dont les fondements sont de l'auteur (ou du texte, ou de K), sous H, et aucun
      appui positif de la définition sous σ et H."""
    vn = libres(Dl.necessaire)
    hp, hn = _hyps_signe(Dl, "+"), _hyps_signe(Dl, "-")
    pos = [o | hp for o in options_pos(base, Dl.suffisante, sigma, ctx, sortes)]
    neg = [o | hn for o in options_neg(base, Dl.necessaire, {k: v for k, v in sigma.items() if k in vn}, ctx, sortes)]
    d_plus = any(not o.hyps for o in pos)
    d_moins = any(not o.hyps for o in neg)
    c_plus = []
    if solution:
        for o in pos:
            if de_l_auteur(o) and not premisses_niees(base, o) and not any(n.hyps <= o.hyps for n in neg):
                c_plus.append(o)
    c_moins = []
    for o in neg:
        if de_l_auteur(o) and not any(p.hyps <= o.hyps for p in pos):
            c_moins.append(o)

    def mini_h(os):
        hs = list(dict.fromkeys(o.hyps for o in os))
        return tuple(h for h in hs if not any(g < h for g in hs))
    ep = frozenset().union(*[o.enonciateurs for o in pos if not o.hyps]) if d_plus else frozenset()
    en = frozenset().union(*[o.enonciateurs for o in neg if not o.hyps]) if d_moins else frozenset()
    contradiction = None
    if d_plus and d_moins:
        interne = False
        for e in ep | en:
            if any(not o.hyps and o.enonciateurs <= {e} for o in pos) and \
                    any(not o.hyps and o.enonciateurs <= {e} for o in neg):
                interne = True
        contradiction = "interne" if interne else "documentaire"
    return Ligne(_sigma_cle(sigma), d_plus, d_moins, mini_h(c_plus), mini_h(c_moins), ep, en, contradiction,
                 solution, tuple(c_plus[:3]), tuple(c_moins[:3]))


@dataclass(frozen=True)
class ResultatBranche:
    """Le résultat dans une branche des alternatives de l'auteur (déf. 5)."""
    statut: str
    lignes: tuple
    hyps_plus: tuple = ()   # ensembles minimaux d'hypothèses (E_H)
    hyps_moins: tuple = ()  # (R_H)
    complet: bool = True


def statut_local(lignes) -> tuple:
    """Le statut local (déf. 5, NOYAU § 4.4 étendu ; § 3.7) : une solution certifiée sans hypothèse (E), sous des
    hypothèses non lexicales (E_H), une substitution contradictoire (B), une vraie non certifiable (NC+), une
    réfutation certifiée sans hypothèse (R), sous hypothèses (R_H), une fausse non certifiable (NC−), rien (N).
    Rend (statut, hypothèses minimales du signe)."""
    def mini(hs):
        hs = list(dict.fromkeys(hs))
        return tuple(sorted((h for h in hs if not any(g < h for g in hs)), key=lambda h: (len(h), sorted(map(str, h)))))
    cp = [h for l in lignes for h in l.c_plus]
    if any(not h for h in cp):
        return "E", ()
    if cp:
        return "E_H", mini(cp)
    if any(l.d_plus and l.d_moins for l in lignes):
        return "B", ()
    if any(l.d_plus for l in lignes):
        return "NC+", ()
    cm = [h for l in lignes if not l.d_plus for h in l.c_moins]
    if any(not h for h in cm):
        return "R", ()
    if cm:
        return "R_H", mini(cm)
    if any(l.d_moins for l in lignes):
        return "NC-", ()
    return "N", ()


def retenues(lignes) -> tuple:
    """Les lignes que garde le résultat (NOYAU § 4.4) : les solutions certifiées, les substitutions minimales
    contradictoires, fausses et vraies non certifiables."""
    def minimales(ls):
        out = []
        for l in ls:
            s = set(l.sigma)
            if not any(set(m.sigma) < s for m in ls):
                out.append(l)
        return out
    certifiees = [l for l in lignes if l.c_plus]
    refutees = minimales([l for l in lignes if l.c_moins and not l.d_plus])  # y compris sous hypothèses (R_H)
    b = minimales([l for l in lignes if l.d_plus and l.d_moins])
    f = minimales([l for l in lignes if l.d_moins and not l.d_plus])
    v = minimales([l for l in lignes if l.d_plus and not l.d_moins and not l.c_plus])
    out = list(dict.fromkeys(certifiees + refutees + b + f + v))
    return tuple(sorted(out, key=lambda l: (str(l.sigma), l.valeur)))


def evaluer_branche(base: Base, Dl: Definition, ctx, budget: Budget) -> ResultatBranche:
    """Le résultat sous (i, w), dans le contexte ctx (déf. 5). La recherche : les arbres positifs de la condition
    suffisante, les réfutations minimales de la condition nécessaire, et leurs réunions ; chacune est ensuite
    évaluée par définition (ligne). C'est complet : D⁺ et D⁻ ne font que croître quand σ lie plus de variables.
    Le budget (étude § 3.7 (f)) : interrompu, le résultat est E si une solution certifiée sans hypothèse a été
    trouvée, R si aucune substitution n'a d'appui positif et qu'une réfutation certifiée a été trouvée, ? sinon."""
    sortes = dict(Dl.variables)
    sortes.update(sortes_de(Dl.suffisante))
    sortes.update(sortes_de(Dl.necessaire))
    lignes = []
    vus = set()
    phase_positive_complete = False
    try:
        positives = []
        for (s, _) in solutions(base, Dl.suffisante, {}, ctx, sortes):
            s = {k: v for k, v in s.items() if k in libres(Dl.suffisante)}
            cle = _sigma_cle(s)
            if cle in vus:
                continue
            vus.add(cle)
            budget.depenser()
            l = ligne(base, Dl, s, ctx, sortes, solution=True)
            lignes.append(l)
            positives.append(s)
        phase_positive_complete = True
        negatives = liaisons_refutantes(base, Dl.necessaire, {}, ctx, sortes)
        candidats = list(negatives)
        for p in positives:
            for n in negatives:
                if _compatibles(p, n):
                    d = dict(p)
                    d.update(n)
                    candidats.append(d)
        for s in candidats:
            cle = _sigma_cle(s)
            if cle in vus:
                continue
            vus.add(cle)
            budget.depenser()
            lignes.append(ligne(base, Dl, s, ctx, sortes, solution=False))
    except BudgetEpuise:
        st, hs = statut_local(lignes)
        if st == "E":
            return ResultatBranche("E", retenues(lignes), (), (), complet=False)
        if phase_positive_complete and not any(l.d_plus for l in lignes) and st == "R":
            return ResultatBranche("R", retenues(lignes), (), (), complet=False)
        return ResultatBranche("?", retenues(lignes), (), (), complet=False)
    st, hs = statut_local(lignes)
    return ResultatBranche(st, retenues(lignes), hs if st == "E_H" else (), hs if st == "R_H" else (), True)


@dataclass(frozen=True)
class ResultatLocal:
    """R(i) dans un contexte (déf. 5) : le statut local, les hypothèses minimales non lexicales de son signe (avec
    leur nature), le résultat de chaque branche des alternatives de l'auteur, la complétude."""
    statut: str
    hypotheses: tuple
    branches: tuple
    complet: bool

    def cle(self) -> tuple:
        """Ce qui fait la classe (déf. 6, lue au § 3.9) : le statut, les hypothèses, et les lignes gardées, les
        substitutions écrites sur leurs classes de mentions."""
        def resume(l: Ligne):
            sig = tuple((k, tuple(sorted(v)) if isinstance(v, frozenset) else v) for k, v in l.sigma)
            return (sig, l.valeur, tuple(sorted(tuple(sorted(map(str, h))) for h in l.c_plus)),
                    tuple(sorted(tuple(sorted(map(str, h))) for h in l.c_moins)))
        return (self.statut, tuple(tuple(sorted(map(str, h))) for h in self.hypotheses),
                tuple(tuple(sorted(resume(l) for l in b.lignes)) for b in self.branches), self.complet)


def combiner_branches(rs: list) -> tuple:
    """Une alternative de l'auteur se traite par cas (§ 3.8, extension signalée au § 3.12) : sous i, la valeur est
    le consensus des branches (ce qui vaut dans toutes : D⁺ si chaque branche a D⁺, D⁻ si chacune a D⁻), certifiée
    d'un signe si chaque branche l'est. Une branche n'est jamais une hypothèse à choisir. Rend (statut, hyps)."""
    if len(rs) == 1:
        r = rs[0]
        return r.statut, (r.hyps_plus or r.hyps_moins)
    if any(r.statut == "?" for r in rs):
        return "?", ()
    dp = all(r.statut in ("E", "E_H", "NC+", "B") for r in rs)
    dm = all(r.statut in ("R", "R_H", "NC-", "B") for r in rs)

    def unions(listes):
        acc = [frozenset()]
        for l in listes:
            acc = list(dict.fromkeys(a | h for a in acc for h in l))
        return tuple(h for h in acc if not any(g < h for g in acc))
    if dp and not dm:
        if all(r.statut == "E" for r in rs):
            return "E", ()
        if all(r.statut in ("E", "E_H") for r in rs):
            return "E_H", unions([r.hyps_plus or (frozenset(),) for r in rs])
        return "NC+", ()
    if dm and not dp:
        if all(r.statut == "R" for r in rs):
            return "R", ()
        if all(r.statut in ("R", "R_H") for r in rs):
            return "R_H", unions([r.hyps_moins or (frozenset(),) for r in rs])
        return "NC-", ()
    if dp and dm:
        return "B", ()
    return "N", ()


def branches_de(D: Description) -> list:
    """Les branches w : une branche par alternative de l'auteur, toutes les combinaisons (§ 3.8)."""
    alts = list(D.alternatives)
    if not alts:
        return [{}]
    return [dict(zip([a.id for a in alts], choix)) for choix in itertools.product(*[range(len(a.branches))
                                                                                    for a in alts])]


def contextes_figuratifs(D: Description) -> list:
    """Les contextes où une définition peut être satisfaite (étude § 7.1 ; guide § 3)."""
    return [c.id for c in D.contextes if c.sorte in SORTES_CONTEXTE_FIGURATIVES]


def resultats_sous_i(cas: Cas, i: dict, budget: Budget, contextes=None) -> dict:
    """R(i) pour chaque contexte figuratif (déf. 5) : la résolution, la base de chaque branche, l'évaluation."""
    D = resoudre_description(cas.description, i)
    Dl = resoudre_definition(cas.definition, i)
    ctxs = contextes or contextes_figuratifs(D)
    bases = [Base(D, cas.connaissances, w) for w in branches_de(D)]
    out = {}
    for ctx in ctxs:
        rs = []
        for b in bases:
            try:
                rs.append(evaluer_branche(b, Dl, ctx, budget))
            except BudgetEpuise:
                rs.append(ResultatBranche("?", (), complet=False))
        st, hs = combiner_branches(rs)
        out[ctx] = ResultatLocal(st, tuple(hs), tuple(rs), all(r.complet for r in rs))
    return out


# ==============================================================================================================
# § 3.9 Le profil, les classes, les cylindres, la robustesse (déf. 6, 7, 8, 9)
# ==============================================================================================================


@dataclass
class Classe:
    """Une classe du profil (déf. 6) : ses interprétations, son résultat, sa description exacte par des cylindres
    maximaux, un témoin (étude § 3.7 (a))."""
    interpretations: list
    resultat: ResultatLocal
    cylindres: list = field(default_factory=list)
    resultats: list = field(default_factory=list)  # le résultat de chaque interprétation : une preuve par cas (déf. 8)

    @property
    def statut(self) -> str:
        return self.resultat.statut

    @property
    def temoin(self) -> dict:
        return self.interpretations[0]


@dataclass
class Profil:
    """Le profil Π = (I, R) restreint à un contexte (déf. 6) : les classes, dans l'ordre des préférences."""
    contexte: str
    I: list
    classes: list
    points: list
    complet: bool
    preferences: list = field(default_factory=list)

    def statuts(self) -> list:
        """Le statut local de chaque interprétation (la suite des I^λ)."""
        return [c.statut for c in self.classes for _ in c.interpretations]


def dans_cylindre(i: dict, h: dict) -> bool:
    return all(i[p] in vs for p, vs in h.items())


def cylindres_maximaux(X: list, I: list, points, preferences=(), limite=50000) -> list:
    """La description exacte d'une partie X de I par des cylindres (déf. 6, déf. 7) : l'ensemble des cylindres
    maximaux h tels que ∅ ≠ [h] ⊆ X. Cet ensemble est canonique (il ne dépend d'aucune préférence) ; les préférences
    ne font que l'ordonner (T19). Un recouvrement minimal n'est pas unique (§ 3.12)."""
    if not X:
        return []
    cles_X = {tuple(sorted(i.items())) for i in X}
    variables = [p for p in sorted(points, key=lambda p: p.id) if len({i[p.id] for i in I}) > 1]
    if not variables or len(X) == len(I):
        return [{}]
    choix = []
    for p in variables:
        vals = [v for v in p.domaine if any(i[p.id] == v for i in I)]
        parties = [frozenset(c) for k in range(1, len(vals) + 1) for c in itertools.combinations(vals, k)]
        choix.append(parties)
    total = 1
    for c in choix:
        total *= len(c)
    if total > limite:
        return [{p.id: (i[p.id],) for p in variables} for i in X]  # repli : les singletons
    valides = []
    for combo in itertools.product(*choix):
        h = {p.id: vs for p, vs in zip(variables, combo)}
        dedans = [i for i in I if dans_cylindre(i, h)]
        if dedans and all(tuple(sorted(i.items())) in cles_X for i in dedans):
            valides.append(h)

    def plus_grand(a, b):  # b ⊋ a
        return a != b and all(a[p] <= b[p] for p in a)
    maximaux = [h for h in valides if not any(plus_grand(h, g) for g in valides)]
    out = []
    for h in maximaux:
        out.append({p: tuple(v for v in next(q for q in variables if q.id == p).domaine if v in vs)
                    for p, vs in h.items() if len(vs) < len({i[p] for i in I})})
    rang = lambda h: min(cle_preference(i, preferences) for i in X if dans_cylindre(i, h))
    out.sort(key=lambda h: (rang(h), sorted(h.items())))
    return out


def profils(cas: Cas, budget: Optional[int] = None, par_composantes: bool = False, contextes=None) -> dict:
    """Le profil de chaque contexte figuratif (déf. 6). Sans budget : complet. `par_composantes` : le calcul ne
    porte que sur les points dont dépend le résultat, fermés par les contraintes (étude § 3.6, § 3.7 (e)) ; le
    profil obtenu doit être le même (T17)."""
    pts = points_du_cas(cas)
    cs = contraintes_du_cas(cas)
    I = interpretations_admissibles(cas, pts, cs)
    prefs = list(cas.description.preferences) + list(cas.definition.preferences)
    ctxs = contextes or contextes_figuratifs(cas.description)
    b = Budget(budget)
    par_ctx = {c: {} for c in ctxs}
    ordre_cles = {c: [] for c in ctxs}
    memo = {}
    utiles = points_utilises(cas, cs) if par_composantes else None
    for i in I:
        if utiles is not None:
            cle_i = tuple(sorted((p, v) for p, v in i.items() if p in utiles))
            if cle_i in memo:
                res = memo[cle_i]
            else:
                res = _resultats_ou_interrompu(cas, i, b, ctxs)
                memo[cle_i] = res
        else:
            res = _resultats_ou_interrompu(cas, i, b, ctxs)
        for c in ctxs:
            k = res[c].cle()
            if k not in par_ctx[c]:
                par_ctx[c][k] = Classe([], res[c])
                ordre_cles[c].append(k)
            par_ctx[c][k].interpretations.append(i)
            par_ctx[c][k].resultats.append(res[c])
    out = {}
    for c in ctxs:
        classes = [par_ctx[c][k] for k in ordre_cles[c]]
        for cl in classes:
            cl.cylindres = cylindres_maximaux(cl.interpretations, I, pts, prefs)
        out[c] = Profil(c, I, classes, pts, all(cl.resultat.complet for cl in classes), prefs)
    return out


def _resultats_ou_interrompu(cas, i, budget, ctxs):
    if budget.reste == 0:
        return {c: ResultatLocal("?", (), (), False) for c in ctxs}
    return resultats_sous_i(cas, i, budget, ctxs)


def points_utilises(cas: Cas, contraintes) -> set:
    """Les points dont dépend le résultat : ceux des gardes et des types de D et de Δ, fermés par les contraintes
    (étude § 3.6, la localité ; § 3.7 (e), règle e1)."""
    u = set()

    def types(t):
        if isinstance(t, Alternatifs):
            u.add(t.point)
        elif isinstance(t, (Union, Conjonction)):
            for m in t.membres:
                types(m)

    def atomes(a):
        if isinstance(a, Atome):
            if a.type is not None:
                types(a.type)
        elif isinstance(a, Proposition):
            for x in a.atomes:
                atomes(x)
        elif isinstance(a, Quantification):
            for x in a.restriction + a.portee:
                atomes(x)

    def formule(F):
        if F is None:
            return
        if isinstance(F, Atome):
            atomes(F)
        elif isinstance(F, (Et, Ou)):
            for f in F.enfants:
                formule(f)
        elif isinstance(F, (Non,)):
            formule(F.corps)
        elif isinstance(F, Existe):
            formule(F.corps)
        elif isinstance(F, Compte):
            formule(F.restriction)
            formule(F.portee)
        elif isinstance(F, Selon):
            u.add(F.point)
            for (_, f) in F.cas:
                formule(f)
    for a in cas.description.assertions:
        for (p, _) in a.garde.conditions:
            u.add(p)
        atomes(a.contenu)
    formule(cas.definition.suffisante)
    formule(cas.definition.necessaire)
    tous = points_du_cas(cas)
    for comp in composantes(tous, contraintes):
        if comp & u:
            u |= comp
    return u


def robustesse(profil: Profil) -> dict:
    """La robustesse (déf. 7) : pour chaque statut local λ et pour chaque signe, totale, partielle ou nulle, et sa
    couverture par des cylindres maximaux."""
    I = profil.I
    out = {}
    groupes = {"+": ("E", "E_H"), "-": ("R", "R_H")}
    groupes.update({s: (s,) for s in STATUTS_LOCAUX})
    for nom, statuts in groupes.items():
        X = [i for c in profil.classes if c.statut in statuts for i in c.interpretations]
        if not X:
            r = "nulle"
        elif len(X) == len(I):
            r = "totale"
        else:
            r = "partielle"
        out[nom] = (r, cylindres_maximaux(X, I, profil.points, profil.preferences) if X else [])
    return out


def _cas_certifies(profil: Profil, signe: str) -> list:
    """Pour chaque (classe, branche) d'un signe, les substitutions certifiées, sur leurs mentions."""
    out = []
    for c in profil.classes:
        if c.statut not in (("E", "E_H") if signe == "+" else ("R", "R_H")):
            continue
        for b in c.resultat.branches:
            sols = []
            for l in b.lignes:
                if (signe == "+" and l.c_plus) or (signe == "-" and l.c_moins and not l.d_plus):
                    sols.append({k: v for k, v in l.sigma})
            out.append(sols)
    return out


def uniforme(profil: Profil, signe: str = "+") -> bool:
    """Une conclusion d'un signe est uniforme (déf. 7) si une même substitution, au sens des mentions, est
    certifiée dans chaque classe et chaque branche de ce signe (∃σ∀i) ; par cas sinon (∀i∃σ_i)."""
    cas = _cas_certifies(profil, signe)
    if not cas or any(not sols for sols in cas):
        return False
    for s0 in cas[0]:
        variables = sorted(s0)
        for mentions in itertools.product(*[sorted(s0[v]) if isinstance(s0[v], frozenset) else [s0[v]]
                                            for v in variables]):
            mu = dict(zip(variables, mentions))
            if all(any(sorted(s) == variables and all((mu[v] in s[v]) if isinstance(s[v], frozenset) else
                                                      mu[v] == s[v] for v in variables) for s in sols)
                   for sols in cas):
                return True
    return False


# ==============================================================================================================
# § 3.10 Le statut synthétique et son ordre (déf. 10, 11) ; le dual (proposition 3)
# ==============================================================================================================

LIGNES = {
    1: "aucune_interpretation", 2: "incomplet", 3: "divergent", 4: "etablie", 5: "etablie_sous_hypotheses",
    6: "etablie_sous_hypotheses", 7: "ecartee", 8: "ecartee_sous_hypotheses", 9: "ecartee_sous_hypotheses",
    10: "contradictoire", 11: "non_certifiee", 12: "inconnue",
}


def lignes_satisfaites(statuts: list) -> list:
    """Les lignes de la table de la définition 10 dont la condition est vraie pour ce profil (la suite des statuts
    locaux de I). Chaque condition est écrite telle quelle, indépendamment des autres : T8 vérifie qu'il y en a
    exactement une."""
    I = statuts
    n = len(I)

    def ens(*ls):
        return [s for s in I if s in ls]
    Ip, Im, Iq = ens("E", "E_H"), ens("R", "R_H"), ens("?")
    out = []
    if n == 0:
        out.append(1)
    if n and Iq:
        out.append(2)
    if n and not Iq and Ip and Im:
        out.append(3)
    if n and len(ens("E")) == n:
        out.append(4)
    if n and len(Ip) == n and ens("E_H"):
        out.append(5)
    if n and not Iq and 0 < len(Ip) < n and not Im:
        out.append(6)
    if n and len(ens("R")) == n:
        out.append(7)
    if n and len(Im) == n and ens("R_H"):
        out.append(8)
    if n and not Iq and 0 < len(Im) < n and not Ip:
        out.append(9)
    if n and not Iq and not Ip and not Im and ens("B"):
        out.append(10)
    if n and not Iq and not Ip and not Im and not ens("B") and ens("NC+", "NC-"):
        out.append(11)
    if n and len(ens("N")) == n:
        out.append(12)
    return out


def signe_nc(statuts: list) -> str:
    s = set(statuts)
    return {frozenset({"NC+"}): "+", frozenset({"NC-"}): "-", frozenset({"NC+", "NC-"}): "+-"}.get(
        frozenset(s & {"NC+", "NC-"}), "")


@dataclass
class StatutSynthetique:
    """Syn(Π) (déf. 10) : un nom et ses attributs — la ligne de la table, le signe d'un NC, la couverture de chaque
    signe, les hypothèses non lexicales par classe avec leur nature, l'uniformité, les classes citées et leurs
    témoins. Il résume le profil ; il ne le remplace pas."""
    nom: str
    ligne: int
    signe: str = ""
    couverture_plus: list = field(default_factory=list)
    couverture_moins: list = field(default_factory=list)
    hypotheses: list = field(default_factory=list)  # [(indice de classe, Hypothese)]
    uniforme_plus: bool = False
    uniforme_moins: bool = False
    temoins: list = field(default_factory=list)
    contexte: str = RACINE
    refutations: list = field(default_factory=list)  # [(indice de classe, σ)] des classes R, R_H
    refutation_fermee: bool = False  # chaque classe R, R_H a une réfutation certifiée de σ vide (« aucun »)

    @property
    def niveaux(self) -> tuple:
        return niveaux(self.nom, self.signe)


def syn_statuts(statuts: list) -> tuple:
    """Le nom de Syn pour une suite de statuts locaux (déf. 10) : (nom, ligne, signe du NC)."""
    ls = lignes_satisfaites(statuts)
    if len(ls) != 1:
        raise AssertionError(f"la table n'est pas une fonction sur {statuts}: lignes {ls}")
    return LIGNES[ls[0]], ls[0], (signe_nc(statuts) if ls[0] == 11 else "")


def syn(profil: Profil) -> StatutSynthetique:
    """Syn(Π) avec ses attributs (déf. 10 ; étude § 3.7 (a) à (f))."""
    nom, ligne_, s = syn_statuts(profil.statuts())
    rb = robustesse(profil) if profil.I else {"+": ("nulle", []), "-": ("nulle", [])}
    hyps = []
    for k, c in enumerate(profil.classes):
        for H in c.resultat.hypotheses:
            for h in sorted(H):
                hyps.append((k, h))
    temoins = [c.temoin for c in profil.classes if c.statut in ("E", "E_H", "R", "R_H")] if ligne_ in (3, 6, 9) else []
    # § 3.12 : la déf. 10 ne distingue pas une réfutation fermée (« aucun ange » : σ vide) d'une réfutation « pour
    # ces référents » (NOYAU § 4.4), qui peut porter sur un référent qu'aucun autre atome ne retient. On les cite.
    refs, fermees = [], []
    for k, c in enumerate(profil.classes):
        if c.statut not in ("R", "R_H"):
            continue
        sig = [dict(l.sigma) for b in c.resultat.branches for l in b.lignes if l.c_moins and not l.d_plus]
        refs.extend((k, x) for x in sig)
        fermees.append(any(not x for x in sig))
    return StatutSynthetique(nom, ligne_, s, rb["+"][1], rb["-"][1], hyps,
                             uniforme(profil, "+"), uniforme(profil, "-"), temoins, profil.contexte, refs,
                             bool(fermees) and all(fermees))


DUAL_LOCAL = {"E": "R", "R": "E", "E_H": "R_H", "R_H": "E_H", "NC+": "NC-", "NC-": "NC+", "B": "B", "N": "N", "?": "?"}
DUAL_NOM = {"etablie": "ecartee", "ecartee": "etablie", "etablie_sous_hypotheses": "ecartee_sous_hypotheses",
            "ecartee_sous_hypotheses": "etablie_sous_hypotheses"}


def dual_statuts(statuts: list) -> list:
    """Le profil dual Π̄ (proposition 3), lu sur les statuts locaux."""
    return [DUAL_LOCAL[s] for s in statuts]


def dual_nom(nom: str, signe: str = "") -> tuple:
    return DUAL_NOM.get(nom, nom), {"+": "-", "-": "+"}.get(signe, signe)


NIVEAUX = {
    "etablie": (3, 0), "etablie_sous_hypotheses": (2, 0), "ecartee": (0, 3), "ecartee_sous_hypotheses": (0, 2),
    "divergent": (2, 2), "contradictoire": (1, 1), "inconnue": (0, 0), "incomplet": (0, 0),
    "aucune_interpretation": (0, 0),
}


def niveaux(nom: str, signe: str = "") -> tuple:
    """(ℓ⁺, ℓ⁻) d'un statut synthétique (déf. 11)."""
    if nom == "non_certifiee":
        return {"+": (1, 0), "-": (0, 1), "+-": (1, 1)}[signe]
    return NIVEAUX[nom]


def inferieur(a: tuple, b: tuple) -> bool:
    """S ≤ S' (déf. 11) sur les couples (nom, signe)."""
    (p1, m1), (p2, m2) = niveaux(*a), niveaux(*b)
    return p1 <= p2 and m1 <= m2


# ==============================================================================================================
# § 3.11 L'index, la sûreté mesurée, l'approximation ∃σ∀i (étude § 3.6, déf. 12)
# ==============================================================================================================


def index_retient(cas: Cas) -> bool:
    """L'index (étude § 3.6) : une notation n'est écartée de l'examen que si I ≠ ∅ et que sa condition nécessaire
    n'a d'appui positif, même sous hypothèse, dans aucune interprétation, aucun contexte figuratif, aucune branche.
    Une réfutation ne retire rien."""
    I = interpretations_admissibles(cas)
    if not I:
        return True
    for i in I:
        D = resoudre_description(cas.description, i)
        Dl = resoudre_definition(cas.definition, i)
        sortes = dict(Dl.variables)
        sortes.update(sortes_de(Dl.necessaire))
        for w in branches_de(D):
            base = Base(D, cas.connaissances, w)
            for ctx in contextes_figuratifs(D):
                if solutions(base, Dl.necessaire, {}, ctx, sortes):
                    return True
    return False


def etablie_uniformement(profil: Profil) -> bool:
    """L'approximation ∃σ∀i du noyau 0.3 (étude § 3.5, « ∀i∃σ contre ∃σ∀i ») : une même substitution certifiée
    sans hypothèse dans toute interprétation."""
    return bool(profil.I) and all(c.statut == "E" for c in profil.classes) and uniforme(profil, "+")


def signes_licencies(verdict_sys_ref: str, verdict_ref_sys: str) -> set:
    """Les signes que le comparateur licencie pour la notation (étude § 2.6) : le positif si Q_sys ⊆ Q_ref, le
    négatif si Q_ref ⊆ Q_sys. `indetermine` et `non` ne licencient rien."""
    s = set()
    if verdict_sys_ref == "oui":
        s.add("+")
    if verdict_ref_sys == "oui":
        s.add("-")
    return s


def restreindre(statut: str, signes: set) -> str:
    """Le statut local rapporté pour la notation, quand seuls certains signes sont licenciés (étude § 2.6, la
    sémantique paraconsistante : une valeur B donne D⁺ sous S⁺_Q, D⁻ sous S⁻_Q)."""
    if "+" not in signes:
        statut = {"E": "N", "E_H": "N", "NC+": "N", "B": "NC-"}.get(statut, statut)
    if "-" not in signes:
        statut = {"R": "N", "R_H": "N", "NC-": "N", "B": "NC+"}.get(statut, statut)
    return statut


def _natures(hs) -> list:
    return sorted({h.nature for H in hs for h in H})


def mesures(statuts_m: list, statuts_r: list, hyps_m=None, hyps_r=None, divergent_r=False, complet_m=True) -> dict:
    """Les mesures de sûreté (déf. 12), sur des interprétations appariées (i' ~ i) : pour chaque i, le statut local
    mesuré et celui de référence, et leurs hypothèses."""
    hyps_m = hyps_m or [()] * len(statuts_m)
    hyps_r = hyps_r or [()] * len(statuts_r)
    m = {"e+_der": 0, "e+_cert": 0, "e-_der": 0, "e-_cert": 0, "d_nr": 0, "n_perdue": 0}
    for sm, sr, hm, hr in zip(statuts_m, statuts_r, hyps_m, hyps_r):
        if sm in ("E", "E_H"):
            if sr in ("R", "R_H", "NC-", "N"):
                m["e+_der"] += 1
            elif sr == "B":
                m["e+_cert"] += 1
        if sm in ("R", "R_H"):
            if sr in ("E", "E_H", "NC+", "N"):
                m["e-_der"] += 1
            elif sr == "B":
                m["e-_cert"] += 1
        if sm in ("E", "E_H", "R", "R_H") and sr in ("E", "E_H", "R", "R_H"):
            if (sm in ("E", "R") and sr in ("E_H", "R_H")) or _natures(hm) != _natures(hr) and hm and hr:
                m["n_perdue"] += 1
    if divergent_r and complet_m:
        nom = syn_statuts(statuts_m)[0] if statuts_m else "aucune_interpretation"
        if nom != "divergent":
            m["d_nr"] += 1
    return m


# ==============================================================================================================
# Le point d'entrée : évaluer un cas
# ==============================================================================================================


@dataclass
class Evaluation:
    """Ce que rend l'interpréteur pour un cas : le profil et le statut synthétique de chaque contexte figuratif ;
    le statut du cas se lit sur le contexte principal (guide § 7, précision 1)."""
    profils: dict
    statuts: dict

    @property
    def principal(self) -> StatutSynthetique:
        return self.statuts[RACINE]


def evaluer(cas: Cas, budget: Optional[int] = None, par_composantes: bool = False) -> Evaluation:
    ps = profils(cas, budget=budget, par_composantes=par_composantes)
    return Evaluation(ps, {c: syn(p) for c, p in ps.items()})
