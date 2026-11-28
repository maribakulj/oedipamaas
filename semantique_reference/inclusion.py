"""Le comparateur d'inclusion entre requêtes (docs/LANGAGE_REFERENCE.md, § 3.11 ; étude § 2.6 ; NOYAU § 8, repris
comme cas particulier, non recopié).

Q1 ⊆ Q2 (relativement à K) : toute description où Q1 est établie établit Q2. La méthode est celle de Chandra et
Merlin, sur la sémantique du langage : pour chaque sélection S1 de Q1, un homomorphisme h d'une sélection S2 de Q2
dans S1 (chaque atome de S2 est entraîné par son image : même prédicat, même valeur, type de S1 ⊑ type de S2).

**La transmission de la négation (l'étape 3 de NOYAU § 8)** est ici une conséquence de la sémantique, non une
vérification de plus : les appuis négatifs des types passent par la même inclusion que les appuis positifs (§ 3.5,
RS 13 ; l'étude § 5.2 : « tous deux par inclus »), et l'ordre des types est transitif (connaissances.py). Ce qui nie
S2 sous σ ∘ h nie donc S1 sous σ. Deux exceptions restent, comme dans le noyau : une identité `meme` de S2 envoyée sur
une seule variable de S1 sans coréférence dite (le « jumeau ») ; une chaîne de `meme_individu` (une distinction
entre ses bouts ne réfute aucun de ses maillons).

Le comparateur rend `oui` avec un homomorphisme par sélection (h dépend de la sélection : § 3.12), `non` avec un
contre-exemple (une description où Q1 est établie et Q2 ne l'est pas), ou `indetermine` avec sa raison : une
construction hors de la méthode (Non, Compte, Existe, ⊥), un cas insatisfiable, ou Q2 établie sur le graphe canonique
sans homomorphisme (une règle de K, dont la transmission de la négation n'est pas vérifiée).
"""
from __future__ import annotations

from dataclasses import dataclass, field, replace
from typing import Optional

from .connaissances import ordre
from .interprete import Base, VIDE, options_neg, options_pos, selections, solutions, sortes_de
from .syntaxe import (RACINE, Alternatifs, Assertion, Atome, Compte, Concept, Conjonction, Connaissances, Contexte,
                      Description, Existe, Inconnu, Non, Proposition, Qualification, Referent, Selon, Union, Var)


@dataclass
class Verdict:
    verdict: str  # oui | non | indetermine
    homomorphismes: list = field(default_factory=list)  # [(n° sélection de Q1, n° sélection de Q2, h)]
    contre_exemple: Optional[Description] = None
    raison: str = ""


def _types_resolus(t) -> bool:
    if isinstance(t, (Alternatifs, Inconnu)):
        return False
    if isinstance(t, (Union, Conjonction)):
        return all(_types_resolus(m) for m in t.membres)
    return True


def _hors_methode(F) -> Optional[str]:
    """Les constructions hors de la méthode (étude § 2.6, point 5) : elles donnent `indetermine`."""
    for S in selections(F):
        for f in S:
            if isinstance(f, (Non, Compte, Existe)):
                return f"construction hors de la méthode : {type(f).__name__}"
            if isinstance(f, Atome) and f.type is not None and not _types_resolus(f.type):
                return "type indéterminé (⊥) ou non résolu"
    return None


@dataclass
class _Selection:
    """Une sélection normalisée : les variables fusionnées par `meme`, les types d'une variable conjoints."""
    rep: dict          # variable d'origine -> représentant
    atomes: list       # atomes (non identitaires), sur les représentants
    meme_classes: set  # représentants dont la classe vient d'au moins un `meme`
    distincts: set     # paires (frozenset) de représentants
    individus: set     # paires (frozenset) de représentants liés par meme_individu directement
    meme_s2: list      # (X, Y) des `meme` (pour la sélection de droite)
    insatisfiable: bool = False


def _normaliser(S) -> _Selection:
    variables = sorted({t.nom for a in S for t in a.args if isinstance(t, Var)} |
                       {a.contexte.nom for a in S if isinstance(a.contexte, Var)})
    parent = {v: v for v in variables}

    def r(x):
        while parent[x] != x:
            x = parent[x]
        return x
    memes = []
    for a in S:
        if a.pred == "meme":
            x, y = a.args[0].nom, a.args[1].nom
            memes.append((x, y))
            rx, ry = r(x), r(y)
            if rx != ry:
                parent[max(rx, ry)] = min(rx, ry)
    rep = {v: r(v) for v in variables}
    meme_classes = {rep[x] for (x, y) in memes if x != y}

    def m(t):
        return Var(rep[t.nom]) if isinstance(t, Var) else t
    atomes, distincts, individus = [], set(), set()
    par_cle = {}
    insat = False
    for a in S:
        if a.pred == "meme":
            continue
        args = tuple(m(t) for t in a.args)
        ctx = m(a.contexte) if isinstance(a.contexte, Var) else a.contexte
        if a.pred == "distinct":
            if args[0] == args[1]:
                insat = True
            distincts.add(frozenset((args[0].nom, args[1].nom)))
            continue
        if a.pred == "meme_individu":
            individus.add(frozenset((args[0].nom, args[1].nom)))
            continue
        if a.pred in ("type", "propriete"):
            par_cle.setdefault((a.pred, args, ctx), []).append(a.type)
            continue
        atomes.append(replace(a, args=args, contexte=ctx))
    for (p, args, ctx), types in par_cle.items():
        t = types[0] if len(types) == 1 else Conjonction(tuple(types))
        atomes.append(Atome(p, args, type=t, contexte=ctx))
    return _Selection(rep, atomes, meme_classes, distincts, individus, memes, insat)


def _homomorphisme(o, s2: _Selection, s1: _Selection, S2_orig) -> list:
    """Les homomorphismes h : var(S2) → var(S1) (sur les représentants) tels que chaque atome de S2 est entraîné
    par son image dans S1, et que les identités de S2 se transmettent. Rend [(h, manque)] où manque est None ou la
    raison d'un défaut de transmission (le jumeau)."""
    out = []
    atomes2 = s2.atomes

    def rec(k, h):
        if k == len(atomes2):
            out.append(dict(h))
            return
        a = atomes2[k]
        for b in s1.atomes:
            if b.pred != a.pred or len(b.args) != len(a.args):
                continue
            if a.pred == "nom":
                if not o.meme_cle(a.valeur, b.valeur):
                    continue
            elif a.valeur != b.valeur:
                continue
            # une inclusion qui passe par une entrée non attestée n'est qu'une hypothèse : elle ne licencie rien
            if a.type is not None and o.sous(b.type, a.type) != frozenset():
                continue
            h2, ok = dict(h), True
            paires = list(zip(a.args, b.args))
            if isinstance(a.contexte, Var) or isinstance(b.contexte, Var):
                paires.append((a.contexte, b.contexte))
            for (x, y) in paires:
                if isinstance(x, Var) and isinstance(y, Var):
                    if h2.get(x.nom, y.nom) != y.nom:
                        ok = False
                        break
                    h2[x.nom] = y.nom
                elif x != y:
                    ok = False
                    break
            if ok:
                rec(k + 1, h2)
    rec(0, {})
    variables2 = sorted({t.nom for a in S2_orig for t in a.args if isinstance(t, Var)})
    resultats = []
    for h in out:
        # les variables de S2 qui ne sont que dans des identités : à envoyer sur une variable de S1
        manque = None
        h = dict(h)
        for v in variables2:
            rv = s2.rep[v]
            if rv not in h:
                manque = manque or "variable sans atome"
        if manque:
            continue
        hh = {v: h[s2.rep[v]] for v in variables2}
        ok = True
        for (x, y) in s2.meme_s2:
            if hh[x] != hh[y]:
                ok = False
                break
            if x != y and hh[x] not in s1.meme_classes:
                manque = ("jumeau", hh[x])
        for pr in s2.distincts:
            a, b = sorted(pr) if len(pr) == 2 else (next(iter(pr)),) * 2
            if frozenset((h[a], h[b])) not in s1.distincts:
                ok = False
        for pr in s2.individus:
            a, b = sorted(pr) if len(pr) == 2 else (next(iter(pr)),) * 2
            if h[a] == h[b]:
                if h[a] not in s1.meme_classes:
                    manque = ("jumeau", h[a])
            elif frozenset((h[a], h[b])) not in s1.individus:
                ok = False
        if ok:
            resultats.append((hh, manque))
    return resultats


def graphe_canonique(S1: _Selection, sortes: dict, jumeau: Optional[str] = None) -> Optional[Description]:
    """La description canonique d'une sélection normalisée (NOYAU § 8, adapté) : un référent par variable,
    introduit par son type (ou par un concept frais), une assertion positive, affirmée, de l'auteur, par atome ;
    les distinctions, les identités, les contextes ouverts. Rien n'y est nié. Avec `jumeau`, un référent coréférent
    au porteur et distinct de lui (le contre-exemple d'une identité non transmise)."""
    reps = sorted(set(S1.rep.values()))
    refs, asser, ctxs = [], [], [Contexte(RACINE, "figuration")]
    types = {a.args[0].nom: a for a in S1.atomes if a.pred == "type" and a.contexte is None}
    situation = {}
    for a in S1.atomes:
        if a.pred == "dans":
            x, s = a.args[0].nom, a.args[1].nom
            if situation.get(x, s) != s:
                return None
            situation[x] = s
    ouverts = {}
    for a in S1.atomes:
        if a.pred == "contexte_ouvert":
            ouverts[a.args[0].nom] = (a.args[1].nom, a.valeur)
    for v in reps:
        s = sortes.get(v, "individu")
        if s == "contexte":
            continue
        if s == "situation":
            refs.append(Referent(f"r_{v}", "situation"))
            continue
        s = "individu" if s in (None, "entite") else s
        t = types[v].type if v in types else Concept(f"$var:{v}")
        refs.append(Referent(f"r_{v}", s, RACINE, f"r_{situation[v]}" if v in situation else None, f"i_{v}"))
        asser.append(Assertion(f"i_{v}", Atome("type", (f"r_{v}",), type=t)))
    for c, (e, sorte) in ouverts.items():
        ctxs.append(Contexte(f"c_{c}", sorte, RACINE, f"r_{e}"))
    n = 0
    for a in S1.atomes:
        if a.pred in ("dans", "contexte_ouvert") or (a.pred == "type" and a.contexte is None):
            continue
        args = tuple(f"r_{t.nom}" if isinstance(t, Var) else t for t in a.args)
        ctx = RACINE if a.contexte is None else f"c_{a.contexte.nom}"
        n += 1
        asser.append(Assertion(f"a{n}", replace(a, args=args, contexte=None), Qualification(contexte=ctx)))
    for pr in S1.distincts:
        a, b = sorted(pr)
        n += 1
        asser.append(Assertion(f"a{n}", Atome("distinct", (f"r_{a}", f"r_{b}"))))
    for pr in S1.individus:
        if len(pr) == 1:
            continue  # meme_individu(x, x) : vrai par la classe même
        a, b = sorted(pr)
        n += 1
        asser.append(Assertion(f"a{n}", Atome("meme_individu", (f"r_{a}", f"r_{b}"))))
    if jumeau is not None:
        r = next(x for x in refs if x.id == f"r_{jumeau}")
        refs.append(replace(r, id="r_jumeau", introduit_par="i_jumeau"))
        t = types[jumeau].type if jumeau in types else Concept(f"$var:{jumeau}")
        asser += [Assertion("i_jumeau", Atome("type", ("r_jumeau",), type=t)),
                  Assertion("m_jumeau", Atome("meme", ("r_jumeau", f"r_{jumeau}"))),
                  Assertion("d_jumeau", Atome("distinct", ("r_jumeau", f"r_{jumeau}")))]
    return Description("canonique", contextes=tuple(ctxs), referents=tuple(refs), assertions=tuple(asser))


def etablie_sur(D: Description, Q, K: Connaissances, sortes: dict) -> bool:
    """Q est-elle établie sur D (une solution certifiée sans hypothèse, dans le contexte principal) ?"""
    base = Base(D, K, {})
    s = dict(sortes)
    s.update(sortes_de(Q))
    for (sigma, _) in solutions(base, Q, {}, RACINE, s):
        if any(not o.hyps and o.enonciateurs <= {"auteur"} for o in options_pos(base, Q, sigma, RACINE, s)) and \
                not any(not o.hyps for o in options_neg(base, Q, sigma, RACINE, s)):
            return True
    return False


def comparer(Q1, Q2, K: Connaissances, sortes1: Optional[dict] = None, sortes2: Optional[dict] = None) -> Verdict:
    """Q1 ⊆ Q2 ? (étude § 2.6, NOYAU § 8). Rend oui (avec h : var(Q2) → var(Q1) par sélection de Q1), non (avec un
    contre-exemple) ou indetermine (avec sa raison)."""
    sortes1, sortes2 = dict(sortes1 or {}), dict(sortes2 or {})
    for F in (Q1, Q2):
        r = _hors_methode(F)
        if r:
            return Verdict("indetermine", raison=r)
    o = ordre(K)
    S1s, S2s = selections(Q1), selections(Q2)
    homs = []
    for n1, S1 in enumerate(S1s):
        s1 = _normaliser(S1)
        if s1.insatisfiable:
            return Verdict("indetermine", raison=f"cas non établi (sélection {n1} insatisfiable)")
        s_rep = {s1.rep[v]: sortes1.get(v) for v in s1.rep}
        can = graphe_canonique(s1, s_rep)
        if can is None:
            return Verdict("indetermine", raison=f"cas non établi (sélection {n1} : deux situations pour une variable)")
        # étape 1 : le graphe canonique établit son cas (sinon le cas est insatisfiable pour le langage)
        Q1n = _formule_normalisee(s1)
        if not etablie_sur(can, Q1n, K, s_rep):
            return Verdict("indetermine", raison=f"cas non établi (sélection {n1})")
        trouve, jumeau = None, None
        for n2, S2 in enumerate(S2s):
            s2 = _normaliser(S2)
            for (h, manque) in _homomorphisme(o, s2, s1, S2):
                if manque is None:
                    trouve = (n1, n2, h)
                    break
                jumeau = jumeau or manque
            if trouve:
                break
        if trouve:
            homs.append(trouve)
            continue
        if jumeau is not None:
            ce = graphe_canonique(s1, s_rep, jumeau=jumeau[1])
            if ce is not None and etablie_sur(ce, Q1n, K, s_rep) and not etablie_sur(ce, Q2, K, sortes2):
                return Verdict("non", contre_exemple=ce, raison=f"identité non transmise (jumeau, sélection {n1})")
            return Verdict("indetermine", raison="identité non transmise")
        if not etablie_sur(can, Q2, K, sortes2):
            return Verdict("non", contre_exemple=can, raison=f"contre-exemple : le graphe canonique de la sélection {n1}")
        return Verdict("indetermine", raison=f"Q2 établie sur le graphe canonique de la sélection {n1} sans "
                                             "homomorphisme (une règle de K : la négation n'est pas vérifiée)")
    return Verdict("oui", homomorphismes=homs)


def _formule_normalisee(s: _Selection):
    from .syntaxe import Et
    atomes = list(s.atomes)
    for pr in s.distincts:
        a, b = sorted(pr)
        atomes.append(Atome("distinct", (Var(a), Var(b))))
    for pr in s.individus:
        a, b = sorted(pr) if len(pr) == 2 else (next(iter(pr)),) * 2
        atomes.append(Atome("meme_individu", (Var(a), Var(b))))
    return Et(tuple(atomes)) if len(atomes) != 1 else atomes[0]


def composer(sigma: dict, h: dict) -> dict:
    """σ ∘ h : la substitution de Q2 que donne une substitution σ de Q1 et h : var(Q2) → var(Q1)."""
    return {v: sigma[w] for v, w in h.items() if w in sigma}
