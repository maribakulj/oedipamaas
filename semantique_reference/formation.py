"""Les règles de formation du langage de référence (docs/LANGAGE_REFERENCE.md, § 2).

`verifier(cas)` rend la liste des défauts ; chaque message commence par la règle qu'il cite (« RF12 (indépendance) :
… »). Un cas bien formé n'a aucun défaut. Les avertissements (`avertissements(cas)`) ne rendent pas un cas mal formé.
"""
from __future__ import annotations

from dataclasses import dataclass

from .syntaxe import (COTES, DIMENSIONS, MODALITES, NATURES, NATURES_NON_LEXICALES, POLARITES, PREDICATS,
                      QUANTIFICATEURS_ENONCES, QUANTIFICATEURS_REQUETE, RACINE, ROLES, SORTES_CONTEXTE,
                      SORTES_CONTEXTE_OUVERTES, SORTES_EVENTUALITE, SORTES_REFERENT, SORTES_REGLE, SORTES_VARIABLE,
                      STATUTS_CONDITION, STATUTS_K, VALEUR_INCONNUE, ANCRAGES, FORMES, INDEXATIONS, Alias,
                      Alternatifs, Antonymie, Assertion, Atome, Cas, Compte, Concept, Conjonction, Connaissances,
                      DefinitionK, Distinction, Equivalence, Et, Existe, Inclusion, Incompatibilite, Inconnu, Non,
                      OppositionTypique, Ou, Partie, Proposition, Quantification, Regle, RestrictionSelection, Selon,
                      Typique, Union, Var)

REGLES = {
    1: ("identifiants", "les identifiants sont uniques dans leur espèce (contextes, référents, assertions, "
                        "alternatives, points, contraintes, préférences, entrées de K)"),
    2: ("arbre des contextes", "les contextes forment un arbre de racine `principal`, de sorte `figuration` : chaque "
                               "parent existe, sans cycle"),
    3: ("contextes ouverts", "un contexte ouvert (vision, rêve, parole, contrat, inscription) nomme l'éventualité "
                             "qui l'ouvre, un référent d'éventualité d'un contexte ancêtre"),
    4: ("sortes", "chaque référent, variable et contexte a une sorte de la liste"),
    5: ("référents", "un référent a un contexte existant ; sa situation, si elle est donnée, est une situation du "
                     "même contexte ou d'un ancêtre ; il est introduit par une assertion positive type(r, T) "
                     "(sauf une situation)"),
    6: ("accessibilité", "un référent cité par une assertion du contexte π est d'un contexte ancêtre de π, ou de π "
                         "(l'accessibilité de la DRT)"),
    7: ("arguments", "chaque atome a le nombre d'arguments de son prédicat, un type s'il est typé, une valeur si "
                     "elle est attendue ; un rôle relie une éventualité ; porteur est le rôle d'un état ; un "
                     "ancrage porte sur une éventualité et prend une valeur de la liste ; dans et succede portent "
                     "sur des situations"),
    8: ("types", "une union ou une conjonction a au moins deux membres ; un ensemble de concepts alternatifs "
                 "renvoie à un point de sens du même côté ; ⊥ n'est écrit que comme valeur de point"),
    9: ("points", "un point a un côté (D ou Δ), une dimension de la liste, un domaine non vide sans répétition ; "
                  "un point de sens a pour valeurs des concepts ou ⊥"),
    10: ("gardes", "une garde porte sur des points existants du même côté, avec des valeurs de leur domaine, au "
                   "plus une condition par point"),
    11: ("une valeur par point", "une interprétation est une fonction : une garde ne demande pas deux valeurs "
                                 "disjointes d'un même point, une combinaison interdite ne nomme pas deux fois un "
                                 "point"),
    12: ("indépendance", "une contrainte dure ne relie jamais un point de D et un point de Δ (étude § 3.4)"),
    13: ("contraintes et préférences", "une contrainte a une source et des combinaisons interdites de points et "
                                       "de valeurs existants ; une préférence ordonne des valeurs existantes et "
                                       "n'interdit rien"),
    14: ("qualifications", "polarité, modalité, énonciateur (`auteur` ou `cite:X`) et contexte existant ; une "
                           "assertion supposée a une nature non lexicale (définition 4) ; une assertion affirmée "
                           "n'en a pas"),
    15: ("négation propositionnelle", "une assertion négative a pour contenu une proposition (∃ locales. ∧ "
                                      "atomes) ; une assertion positive est atomique ou une quantification ; chaque "
                                      "variable locale apparaît dans un atome ; les constantes sont des référents"),
    16: ("quantifications énoncées", "la variable est dans la restriction ; restriction et portée n'ont d'autres "
                                     "variables que la sienne ; seul et tous_sauf nomment des membres existants ; "
                                     "exactement et au_moins ont un nombre (≥ 1 pour au_moins)"),
    17: ("identités", "meme (la coréférence, qui fusionne) relie deux référents de même sorte, de même contexte et "
                      "de même situation, positive, affirmée, de l'auteur ; distinct ne relie jamais un référent "
                      "à lui-même ; meme_individu relie deux individus ou collections, à travers situations et "
                      "contextes"),
    18: ("alternatives", "une alternative de l'auteur a au moins deux branches non vides ; une assertion est dans "
                         "une branche au plus ; un référent introduit dans une branche n'est cité que dans elle"),
    19: ("provenance", "une provenance a 0 ≤ début ≤ fin, dans la longueur du texte s'il est donné ; elle n'a "
                       "aucun effet sémantique"),
    20: ("variables", "chaque variable de la définition est déclarée une fois, avec une sorte ; les variables d'un "
                      "Existe ou d'un Compte sont locales, sans ombrage d'une variable déclarée"),
    21: ("portée", "chaque variable libre de la définition apparaît dans un atome hors de toute négation (la "
                   "restriction au domaine) ; aucune variable libre n'est non déclarée"),
    22: ("négation gardée", "dans chaque sélection, les variables libres d'une feuille Non, Existe ou Compte sont "
                            "liées par un atome positif de la même sélection, hors d'elle"),
    23: ("identités de requête", "les variables d'un meme, distinct ou meme_individu sont liées par des atomes non "
                                 "identitaires de la même sélection ; jamais distinct(X, X)"),
    24: ("connecteurs", "Et a au moins un enfant, Ou au moins deux ; un Selon porte sur un point de Δ et a un cas "
                        "par valeur de son domaine ; un Compte a un quantificateur de la liste, un nombre s'il le "
                        "demande, une restriction qui contient sa variable, une portée pour tous, des membres pour "
                        "seul"),
    25: ("contextes de requête", "une variable de contexte est liée, dans chaque sélection où elle sert, par un "
                                 "atome contexte_ouvert"),
    26: ("conditions structurées", "les variables libres de la condition nécessaire sont parmi celles de la "
                                   "condition suffisante ; chaque condition a un statut de la liste ; la condition "
                                   "suffisante implique la condition nécessaire (le comparateur ne rend pas `non`)"),
    27: ("entrées de K", "chaque entrée a un identifiant, une source (ressource), un statut de la liste ; une "
                         "incompatibilité a une forme et une indexation qui contient porteur et contexte ; une "
                         "règle n'emploie que ses variables déclarées et sa prémisse n'est pas vide"),
    28: ("cohérence des noms", "aucune paire de clés n'est à la fois alias (par la clôture) et distincte"),
    29: ("côtés", "les points de D ne servent qu'à la description, ceux de Δ qu'à la définition"),
    30: ("hypothèses", "une hypothèse de lecture n'est jamais écrite : les lectures sont des points ; la nature d'une "
                       "assertion supposée est l'une des natures non lexicales"),
    31: ("contextes d'évaluation", "la description a au moins un contexte figuratif, la racine"),
}


@dataclass(frozen=True)
class Defaut:
    regle: int
    message: str

    def __str__(self):
        return f"RF{self.regle} ({REGLES[self.regle][0]}) : {self.message}"


def _vars_atome(a: Atome) -> set:
    s = {t.nom for t in a.args if isinstance(t, Var)}
    if isinstance(a.contexte, Var):
        s.add(a.contexte.nom)
    return s


def _types_de(t):
    if isinstance(t, (Union, Conjonction)):
        for m in t.membres:
            yield from _types_de(m)
    yield t


def _verifier_type(t, points: dict, cote: str, ou: str, out: list):
    """RF8."""
    for u in _types_de(t):
        if isinstance(u, (Union, Conjonction)) and len(u.membres) < 2:
            out.append(Defaut(8, f"{ou} : {type(u).__name__} à moins de deux membres"))
        if isinstance(u, Alternatifs):
            p = points.get(u.point)
            if p is None:
                out.append(Defaut(8, f"{ou} : l'ensemble de concepts alternatifs renvoie au point inconnu {u.point}"))
            elif p.cote != cote:
                out.append(Defaut(29, f"{ou} : le point {u.point} est du côté {p.cote}, employé du côté {cote}"))
            elif p.dimension != "sens":
                out.append(Defaut(8, f"{ou} : le point {u.point} n'est pas un point de sens"))
        if isinstance(u, Inconnu):
            out.append(Defaut(8, f"{ou} : ⊥ écrit comme type (il n'est qu'une valeur de point)"))
        if u is None:
            pass


def _verifier_atome(a: Atome, ou: str, out: list, points: dict, cote: str, requete=False):
    """RF7."""
    if a.pred not in PREDICATS:
        out.append(Defaut(7, f"{ou} : prédicat inconnu {a.pred}"))
        return
    n, type_, valeur = PREDICATS[a.pred]
    if len(a.args) != n:
        out.append(Defaut(7, f"{ou} : {a.pred} demande {n} argument(s)"))
    if type_ and a.type is None:
        out.append(Defaut(7, f"{ou} : {a.pred} demande un type"))
    if not type_ and a.type is not None:
        out.append(Defaut(7, f"{ou} : {a.pred} n'a pas de type"))
    if valeur and a.valeur is None:
        out.append(Defaut(7, f"{ou} : {a.pred} demande une valeur"))
    if a.pred == "role" and a.valeur not in ROLES:
        out.append(Defaut(7, f"{ou} : rôle inconnu {a.valeur}"))
    if a.pred == "ancrage" and a.valeur not in ANCRAGES:
        out.append(Defaut(7, f"{ou} : ancrage inconnu {a.valeur}"))
    if a.pred == "contexte_ouvert" and not requete:
        out.append(Defaut(7, f"{ou} : contexte_ouvert n'est écrit que dans une requête (la description déclare "
                             "ses contextes)"))
    if a.type is not None:
        _verifier_type(a.type, points, cote, ou, out)


def _sortes_refs(D) -> dict:
    return {r.id: r.sorte for r in D.referents}


def _verifier_args_sortes(a: Atome, sorte_de, ou: str, out: list):
    """RF7 : les sortes des arguments."""
    def s(t):
        return sorte_de(t)
    if a.pred == "role" and len(a.args) == 2:
        se = s(a.args[0])
        if se is not None and se not in SORTES_EVENTUALITE:
            out.append(Defaut(7, f"{ou} : le premier argument d'un rôle est une éventualité ({se})"))
        if a.valeur == "porteur" and se is not None and se != "etat":
            out.append(Defaut(7, f"{ou} : porteur est le rôle d'un état ({se})"))
    if a.pred == "ancrage" and a.args:
        se = s(a.args[0])
        if se is not None and se not in SORTES_EVENTUALITE:
            out.append(Defaut(7, f"{ou} : un ancrage porte sur une éventualité ({se})"))
    if a.pred == "dans" and len(a.args) == 2:
        if s(a.args[1]) not in (None, "situation"):
            out.append(Defaut(7, f"{ou} : le second argument de dans est une situation"))
    if a.pred == "succede" and len(a.args) == 2:
        for t in a.args:
            if s(t) not in (None, "situation"):
                out.append(Defaut(7, f"{ou} : succede relie des situations"))


def _ancetres(ctxs: dict, c: str) -> list:
    out, vus = [], set()
    while c is not None and c not in vus:
        vus.add(c)
        out.append(c)
        c = ctxs[c].parent if c in ctxs else None
    return out


def verifier_description(D, K=None, autres=frozenset()) -> list:
    out = []
    ctxs = {}
    for c in D.contextes:
        if c.id in ctxs:
            out.append(Defaut(1, f"contexte {c.id} déclaré deux fois"))
        ctxs[c.id] = c
    # RF2, RF31
    if RACINE not in ctxs or ctxs[RACINE].sorte != "figuration" or ctxs[RACINE].parent is not None:
        out.append(Defaut(2, "la racine `principal`, de sorte figuration, sans parent, manque"))
        out.append(Defaut(31, "aucun contexte d'évaluation figuratif à la racine"))
    for c in D.contextes:
        if c.sorte not in SORTES_CONTEXTE:
            out.append(Defaut(4, f"contexte {c.id} : sorte inconnue {c.sorte}"))
        if c.id != RACINE and c.parent is None:
            out.append(Defaut(2, f"contexte {c.id} sans parent"))
        if c.parent is not None and c.parent not in ctxs:
            out.append(Defaut(2, f"contexte {c.id} : parent inconnu {c.parent}"))
        vus, x = set(), c.id
        while x is not None and x in ctxs:
            if x in vus:
                out.append(Defaut(2, f"contexte {c.id} : cycle"))
                break
            vus.add(x)
            x = ctxs[x].parent
    refs = {}
    for r in D.referents:
        if r.id in refs:
            out.append(Defaut(1, f"référent {r.id} déclaré deux fois"))
        refs[r.id] = r
    for c in D.contextes:  # RF3
        if c.sorte in SORTES_CONTEXTE_OUVERTES:
            if c.ouvert_par is None:
                out.append(Defaut(3, f"contexte {c.id} ({c.sorte}) : l'éventualité qui l'ouvre manque"))
            else:
                e = refs.get(c.ouvert_par)
                if e is None or e.sorte not in SORTES_EVENTUALITE:
                    out.append(Defaut(3, f"contexte {c.id} : {c.ouvert_par} n'est pas une éventualité déclarée"))
                elif e.contexte not in _ancetres(ctxs, c.parent):
                    out.append(Defaut(3, f"contexte {c.id} : {c.ouvert_par} n'est pas d'un contexte ancêtre"))
    asser = {}
    for a in D.assertions:
        if a.id in asser:
            out.append(Defaut(1, f"assertion {a.id} déclarée deux fois"))
        asser[a.id] = a
    points = {}
    for p in D.points:
        if p.id in points:
            out.append(Defaut(1, f"point {p.id} déclaré deux fois"))
        points[p.id] = p
    for r in D.referents:  # RF4, RF5
        if r.sorte not in SORTES_REFERENT:
            out.append(Defaut(4, f"référent {r.id} : sorte inconnue {r.sorte}"))
        if r.contexte not in ctxs:
            out.append(Defaut(5, f"référent {r.id} : contexte inconnu {r.contexte}"))
        if r.situation is not None:
            s = refs.get(r.situation)
            if s is None or s.sorte != "situation":
                out.append(Defaut(5, f"référent {r.id} : {r.situation} n'est pas une situation déclarée"))
            elif r.contexte in ctxs and s.contexte not in _ancetres(ctxs, r.contexte):
                out.append(Defaut(5, f"référent {r.id} : sa situation n'est pas de son contexte ni d'un ancêtre"))
        if r.sorte != "situation":
            a = asser.get(r.introduit_par)
            if a is None:
                out.append(Defaut(5, f"référent {r.id} : l'assertion qui l'introduit manque"))
            elif not (isinstance(a.contenu, Atome) and a.contenu.pred == "type" and a.contenu.args == (r.id,)
                      and a.qualification.polarite == "pos"):
                out.append(Defaut(5, f"référent {r.id} : {a.id} n'est pas une assertion positive type({r.id}, T)"))
            elif a.qualification.contexte != r.contexte:
                out.append(Defaut(5, f"référent {r.id} : introduit dans un autre contexte que le sien"))
    sorte_de = lambda t: refs[t].sorte if isinstance(t, str) and t in refs else None
    for a in D.assertions:
        q = a.qualification
        ou = f"assertion {a.id}"
        # RF14
        if q.polarite not in POLARITES or q.modalite not in MODALITES:
            out.append(Defaut(14, f"{ou} : polarité ou modalité inconnue"))
        if not (q.enonciateur == "auteur" or q.enonciateur.startswith("cite:")):
            out.append(Defaut(14, f"{ou} : énonciateur {q.enonciateur} (auteur ou cite:X)"))
        if q.contexte not in ctxs:
            out.append(Defaut(14, f"{ou} : contexte inconnu {q.contexte}"))
        if q.modalite == "supposee":
            if q.nature == "lecture":
                out.append(Defaut(30, f"{ou} : une hypothèse de lecture est un point, non une assertion supposée"))
            elif q.nature not in NATURES_NON_LEXICALES:
                out.append(Defaut(14, f"{ou} : une assertion supposée a une nature non lexicale ({q.nature})"))
        elif q.nature is not None:
            out.append(Defaut(14, f"{ou} : une assertion {q.modalite} n'a pas de nature d'hypothèse"))
        # RF10, RF11 : la garde
        vus_pts = set()
        for (p, vals) in a.garde.conditions:
            if p in vus_pts:
                out.append(Defaut(11, f"{ou} : deux conditions sur le point {p}"))
            vus_pts.add(p)
            pt = points.get(p)
            if pt is None:
                out.append(Defaut(10, f"{ou} : garde sur le point inconnu {p}"))
            elif pt.cote != "D":
                out.append(Defaut(29, f"{ou} : garde sur le point {p} de Δ"))
            elif not set(vals) <= set(pt.domaine) or not vals:
                out.append(Defaut(10, f"{ou} : garde sur {p} avec des valeurs hors du domaine"))
        # RF19
        pr = a.provenance
        if pr.debut is not None or pr.fin is not None:
            if pr.debut is None or pr.fin is None or not (0 <= pr.debut <= pr.fin):
                out.append(Defaut(19, f"{ou} : offsets incohérents ({pr.debut}, {pr.fin})"))
            elif D.texte and pr.fin > len(D.texte):
                out.append(Defaut(19, f"{ou} : offsets hors du texte"))
        c = a.contenu
        consts = []
        if isinstance(c, Atome):
            if q.polarite == "neg":
                out.append(Defaut(15, f"{ou} : une assertion négative a pour contenu une proposition"))
            _verifier_atome(c, ou, out, points, "D")
            _verifier_args_sortes(c, sorte_de, ou, out)
            if any(isinstance(t, Var) for t in c.args):
                out.append(Defaut(15, f"{ou} : une assertion positive n'a pas de variable"))
            consts = [t for t in c.args if isinstance(t, str)]
            if c.pred == "meme":  # RF17
                x, y = c.args
                rx, ry = refs.get(x), refs.get(y)
                if rx and ry and (rx.sorte != ry.sorte or rx.contexte != ry.contexte or rx.situation != ry.situation):
                    out.append(Defaut(17, f"{ou} : meme relie deux référents de sortes, contextes ou situations "
                                          "différents (la coréférence ne traverse pas les situations : "
                                          "meme_individu)"))
                if q.polarite != "pos" or q.modalite != "affirme" or q.enonciateur != "auteur":
                    out.append(Defaut(17, f"{ou} : meme est positive, affirmée, de l'auteur"))
            if c.pred == "distinct" and len(c.args) == 2 and c.args[0] == c.args[1]:
                out.append(Defaut(17, f"{ou} : distinct({c.args[0]}, {c.args[0]})"))
            if c.pred == "meme_individu":
                for t in c.args:
                    if sorte_de(t) not in (None, "individu", "collection"):
                        out.append(Defaut(17, f"{ou} : meme_individu relie des individus ou des collections"))
        elif isinstance(c, Proposition):
            if q.polarite != "neg":
                out.append(Defaut(15, f"{ou} : une proposition n'est assertée que niée"))
            locs = {n for (n, _) in c.locales}
            for (n, s) in c.locales:
                if s not in SORTES_VARIABLE + ("entite",):
                    out.append(Defaut(4, f"{ou} : sorte inconnue {s} pour {n}"))
                if not any(n in _vars_atome(x) for x in c.atomes):
                    out.append(Defaut(15, f"{ou} : la variable locale {n} n'apparaît dans aucun atome"))
            if not c.atomes:
                out.append(Defaut(15, f"{ou} : une proposition vide"))
            loc_sortes = dict(c.locales)
            for x in c.atomes:
                _verifier_atome(x, ou, out, points, "D")
                _verifier_args_sortes(x, lambda t: loc_sortes.get(t.nom) if isinstance(t, Var) else sorte_de(t),
                                      ou, out)
                for t in x.args:
                    if isinstance(t, Var) and t.nom not in locs:
                        out.append(Defaut(15, f"{ou} : variable {t.nom} non locale"))
                    elif isinstance(t, str):
                        consts.append(t)
        elif isinstance(c, Quantification):
            if c.quant not in QUANTIFICATEURS_ENONCES:
                out.append(Defaut(16, f"{ou} : quantificateur inconnu {c.quant}"))
            x = c.variable[0]
            if not any(x in _vars_atome(t) for t in c.restriction):
                out.append(Defaut(16, f"{ou} : la variable {x} n'est pas dans la restriction"))
            for t in c.restriction + c.portee:
                _verifier_atome(t, ou, out, points, "D")
                for u in t.args:
                    if isinstance(u, Var) and u.nom != x:
                        out.append(Defaut(16, f"{ou} : variable {u.nom} autre que {x}"))
                    elif isinstance(u, str):
                        consts.append(u)
            if c.quant in ("seul", "tous_sauf") and not c.membres:
                out.append(Defaut(16, f"{ou} : {c.quant} nomme ses membres"))
            for m in c.membres:
                consts.append(m)
            if c.quant in ("exactement", "au_moins") and (c.n is None or c.n < (1 if c.quant == "au_moins" else 0)):
                out.append(Defaut(16, f"{ou} : {c.quant} demande un nombre"))
            if c.quant in ("tous", "tous_sauf") and not c.portee:
                out.append(Defaut(16, f"{ou} : {c.quant} demande une portée"))
            if c.situation is not None and sorte_de(c.situation) != "situation":
                out.append(Defaut(16, f"{ou} : {c.situation} n'est pas une situation"))
        else:
            out.append(Defaut(15, f"{ou} : contenu inconnu"))
        for t in consts:  # RF6
            r = refs.get(t)
            if r is None:
                if t not in ctxs:
                    out.append(Defaut(15, f"{ou} : référent inconnu {t}"))
                continue
            if q.contexte in ctxs and r.contexte not in _ancetres(ctxs, q.contexte):
                out.append(Defaut(6, f"{ou} : {t} (du contexte {r.contexte}) n'est pas accessible depuis "
                                     f"{q.contexte}"))
    # RF18
    dans_branche = {}
    for al in D.alternatives:
        if len(al.branches) < 2 or any(not b for b in al.branches):
            out.append(Defaut(18, f"alternative {al.id} : au moins deux branches non vides"))
        for n, b in enumerate(al.branches):
            for x in b:
                if x in dans_branche:
                    out.append(Defaut(18, f"alternative {al.id} : {x} est dans deux branches"))
                if x not in asser:
                    out.append(Defaut(18, f"alternative {al.id} : assertion inconnue {x}"))
                dans_branche[x] = (al.id, n)
    for r in D.referents:
        if r.introduit_par in dans_branche:
            br = dans_branche[r.introduit_par]
            for a in D.assertions:
                cs = _constantes(a.contenu)
                if r.id in cs and dans_branche.get(a.id) != br:
                    out.append(Defaut(18, f"{r.id}, introduit dans une branche de {br[0]}, est cité par {a.id} "
                                          "hors d'elle"))
    out.extend(_verifier_points(D.points, D.contraintes, D.preferences, "D", autres))
    return out


def _constantes(c) -> set:
    if isinstance(c, Atome):
        return {t for t in c.args if isinstance(t, str)}
    if isinstance(c, Proposition):
        return {t for a in c.atomes for t in a.args if isinstance(t, str)}
    if isinstance(c, Quantification):
        return {t for a in c.restriction + c.portee for t in a.args if isinstance(t, str)} | set(c.membres)
    return set()


def _verifier_points(points, contraintes, preferences, cote, autres=frozenset()) -> list:
    out = []
    pts = {}
    for p in points:
        if p.cote not in COTES:
            out.append(Defaut(9, f"point {p.id} : côté inconnu {p.cote}"))
        if p.cote != cote:
            out.append(Defaut(29, f"point {p.id} du côté {p.cote} déclaré du côté {cote}"))
        if p.dimension not in DIMENSIONS:
            out.append(Defaut(9, f"point {p.id} : dimension inconnue {p.dimension}"))
        if not p.domaine or len(set(p.domaine)) != len(p.domaine):
            out.append(Defaut(9, f"point {p.id} : domaine vide ou répété"))
        if p.dimension == "sens" and any(not isinstance(v, str) for v in p.domaine):
            out.append(Defaut(9, f"point {p.id} : un point de sens a pour valeurs des concepts ou ⊥"))
        pts[p.id] = p
    for c in contraintes:
        if not c.source:
            out.append(Defaut(13, f"contrainte {c.id} sans source"))
        for comb in c.interdits:
            ps = [p for (p, _) in comb]
            if len(set(ps)) != len(ps):
                out.append(Defaut(11, f"contrainte {c.id} : une combinaison nomme deux fois un point"))
            for (p, v) in comb:
                if p in autres:
                    out.append(Defaut(12, f"contrainte {c.id} : le point {p} est de l'autre côté que {cote} (une "
                                          "contrainte dure ne relie jamais D et Δ)"))
                elif p not in pts:
                    out.append(Defaut(13, f"contrainte {c.id} : point inconnu {p}"))
                elif v not in pts[p].domaine:
                    out.append(Defaut(13, f"contrainte {c.id} : valeur {v} hors du domaine de {p}"))
    for pr in preferences:
        if pr.point is not None:
            if pr.point not in pts and cote == "D":
                out.append(Defaut(13, f"préférence {pr.id} : point inconnu {pr.point}"))
            elif pr.point in pts and not set(pr.ordre) <= set(pts[pr.point].domaine):
                out.append(Defaut(13, f"préférence {pr.id} : valeurs hors du domaine"))
    return out


def _parcourir(F, f):
    f(F)
    if isinstance(F, (Et, Ou)):
        for g in F.enfants:
            _parcourir(g, f)
    elif isinstance(F, Non):
        _parcourir(F.corps, f)
    elif isinstance(F, Existe):
        _parcourir(F.corps, f)
    elif isinstance(F, Compte):
        _parcourir(F.restriction, f)
        if F.portee is not None:
            _parcourir(F.portee, f)
    elif isinstance(F, Selon):
        for (_, g) in F.cas:
            _parcourir(g, f)


def _sans_selon(F, i_par_defaut):
    """Une formule où chaque Selon est remplacé par la disjonction de ses cas (pour les contrôles de portée)."""
    if isinstance(F, Selon):
        cas = [_sans_selon(g, i_par_defaut) for (_, g) in F.cas]
        return cas[0] if len(cas) == 1 else Ou(tuple(cas))
    if isinstance(F, Et):
        return Et(tuple(_sans_selon(g, i_par_defaut) for g in F.enfants))
    if isinstance(F, Ou):
        return Ou(tuple(_sans_selon(g, i_par_defaut) for g in F.enfants))
    if isinstance(F, Non):
        return Non(_sans_selon(F.corps, i_par_defaut))
    if isinstance(F, Existe):
        return Existe(F.variables, _sans_selon(F.corps, i_par_defaut))
    if isinstance(F, Compte):
        from dataclasses import replace
        return replace(F, restriction=_sans_selon(F.restriction, i_par_defaut),
                       portee=_sans_selon(F.portee, i_par_defaut) if F.portee is not None else None)
    return F


def verifier_formule(F, declarees: dict, points: dict, ou: str) -> list:
    """RF20 à RF25, pour une formule de la définition."""
    from .interprete import libres, selections
    out = []
    if F is None:
        return [Defaut(24, f"{ou} : formule absente")]
    locales_vues = []

    def visite(G):
        if isinstance(G, Et) and len(G.enfants) < 1:
            out.append(Defaut(24, f"{ou} : Et sans enfant"))
        if isinstance(G, Ou) and len(G.enfants) < 2:
            out.append(Defaut(24, f"{ou} : Ou à moins de deux enfants"))
        if isinstance(G, Selon):
            p = points.get(G.point)
            if p is None:
                out.append(Defaut(24, f"{ou} : Selon sur un point inconnu ou de D ({G.point})"))
            elif sorted(map(str, (v for v, _ in G.cas))) != sorted(map(str, p.domaine)):
                out.append(Defaut(24, f"{ou} : Selon({G.point}) n'a pas un cas par valeur"))
        if isinstance(G, Existe):
            for (n, s) in G.variables:
                locales_vues.append(n)
                if s not in SORTES_VARIABLE + ("entite",):
                    out.append(Defaut(4, f"{ou} : sorte inconnue {s} pour {n}"))
        if isinstance(G, Compte):
            locales_vues.append(G.variable[0])
            if G.quant not in QUANTIFICATEURS_REQUETE:
                out.append(Defaut(24, f"{ou} : quantificateur inconnu {G.quant}"))
            if G.quant in ("au_moins", "exactement") and G.n is None:
                out.append(Defaut(24, f"{ou} : {G.quant} demande un nombre"))
            if G.variable[0] not in libres(_sans_selon(G.restriction, None)) | _toutes_vars(G.restriction):
                out.append(Defaut(24, f"{ou} : la restriction ne contient pas {G.variable[0]}"))
            if G.quant == "tous" and G.portee is None:
                out.append(Defaut(24, f"{ou} : tous demande une portée"))
            if G.quant == "seul" and not G.membres:
                out.append(Defaut(24, f"{ou} : seul demande des membres"))
        if isinstance(G, Atome):
            _verifier_atome(G, ou, out, points, "Δ", requete=True)
            if G.pred == "distinct" and G.args[0] == G.args[1]:
                out.append(Defaut(23, f"{ou} : distinct({G.args[0].nom}, {G.args[0].nom})"))
            for t in G.args:
                if isinstance(t, str):
                    out.append(Defaut(7, f"{ou} : une requête n'a que des variables pour arguments ({t})"))
    _parcourir(F, visite)
    # RF20 : pas d'ombrage, pas de double déclaration
    for n in locales_vues:
        if n in declarees:
            out.append(Defaut(20, f"{ou} : la variable locale {n} ombre une variable déclarée"))
    if len(set(locales_vues)) != len(locales_vues):
        out.append(Defaut(20, f"{ou} : une variable locale déclarée deux fois"))
    G = _sans_selon(F, None)
    lib = libres(G)
    for v in lib:
        if v not in declarees:
            out.append(Defaut(21, f"{ou} : la variable {v} n'est pas déclarée"))
    # RF21, RF22, RF23, RF25, par sélection
    sortes = dict(declarees)
    for S in selections(G):
        positifs = set()
        for f in S:
            if isinstance(f, Atome) and f.pred not in ("meme", "distinct", "meme_individu"):
                positifs |= {t.nom for t in f.args if isinstance(t, Var)}
                if isinstance(f.contexte, Var):
                    positifs.add(f.contexte.nom)
        for f in S:
            if isinstance(f, (Non, Existe, Compte)):
                manque = libres(f) - positifs
                if manque:
                    out.append(Defaut(22, f"{ou} : {sorted(manque)} libres dans {type(f).__name__} sans garde "
                                          "positive dans la sélection"))
            if isinstance(f, Atome) and f.pred in ("meme", "distinct", "meme_individu"):
                manque = {t.nom for t in f.args} - positifs
                if manque:
                    out.append(Defaut(23, f"{ou} : {sorted(manque)} d'une identité ne sont liées par aucun atome"))
            if isinstance(f, Atome) and isinstance(f.contexte, Var):
                c = f.contexte.nom
                if not any(isinstance(g, Atome) and g.pred == "contexte_ouvert" and g.args[0] == Var(c) for g in S):
                    out.append(Defaut(25, f"{ou} : la variable de contexte {c} n'est liée par aucun contexte_ouvert"))
    tous_positifs = set()
    for S in selections(G):
        for f in S:
            if isinstance(f, Atome) and f.pred not in ("meme", "distinct", "meme_individu"):
                tous_positifs |= _vars_atome(f)
    for v in lib:
        if v in declarees and v not in tous_positifs:
            out.append(Defaut(21, f"{ou} : la variable {v} n'apparaît dans aucun atome positif"))
    return out


def _toutes_vars(F) -> set:
    s = set()

    def f(G):
        if isinstance(G, Atome):
            s.update(_vars_atome(G))
    if F is not None:
        _parcourir(F, f)
    return s


def verifier_definition(Dl, autres=frozenset()) -> list:
    out = []
    pts = {}
    for p in Dl.points:
        if p.id in pts:
            out.append(Defaut(1, f"point {p.id} déclaré deux fois"))
        pts[p.id] = p
    declarees = {}
    for (n, s) in Dl.variables:
        if n in declarees:
            out.append(Defaut(20, f"variable {n} déclarée deux fois"))
        if s not in SORTES_VARIABLE + ("entite",):
            out.append(Defaut(4, f"variable {n} : sorte inconnue {s}"))
        declarees[n] = s
    out.extend(verifier_formule(Dl.suffisante, declarees, pts, "condition suffisante"))
    if Dl.necessaire is not None:
        out.extend(verifier_formule(Dl.necessaire, declarees, pts, "condition nécessaire"))
        from .interprete import libres
        if not libres(_sans_selon(Dl.necessaire, None)) <= libres(_sans_selon(Dl.suffisante, None)):
            out.append(Defaut(26, "les variables libres de la condition nécessaire ne sont pas parmi celles de la "
                                  "condition suffisante"))
    if Dl.statut_suffisance not in STATUTS_CONDITION or Dl.statut_necessite not in STATUTS_CONDITION:
        out.append(Defaut(26, "statut de condition inconnu"))
    out.extend(_verifier_points(Dl.points, Dl.contraintes, Dl.preferences, "Δ", autres))
    return out


def verifier_connaissances(K: Connaissances) -> list:
    out = []
    ids = set()
    for e in K.entrees:
        if e.id in ids:
            out.append(Defaut(1, f"entrée de K {e.id} déclarée deux fois"))
        ids.add(e.id)
        if not e.source.ressource:
            out.append(Defaut(27, f"entrée {e.id} sans source"))
        if e.statut not in STATUTS_K:
            out.append(Defaut(27, f"entrée {e.id} : statut inconnu {e.statut}"))
        if isinstance(e, Incompatibilite):
            if e.forme not in FORMES or not {"porteur", "contexte"} <= set(e.indexation) or \
                    not set(e.indexation) <= set(INDEXATIONS):
                out.append(Defaut(27, f"incompatibilité {e.id} : forme ou indexation (porteur et contexte requis)"))
        if isinstance(e, Typique) and e.forme not in FORMES:
            out.append(Defaut(27, f"connaissance typique {e.id} : forme inconnue"))
        if isinstance(e, Regle):
            if e.sorte not in SORTES_REGLE or not e.premisse:
                out.append(Defaut(27, f"règle {e.id} : sorte inconnue ou prémisse vide"))
            decl = {n for (n, _) in e.variables}
            for a in e.premisse + e.conclusion:
                if _vars_atome(a) - decl:
                    out.append(Defaut(27, f"règle {e.id} : variable non déclarée {sorted(_vars_atome(a) - decl)}"))
        if isinstance(e, DefinitionK):
            if e.statut_suffisance not in STATUTS_CONDITION or e.statut_necessite not in STATUTS_CONDITION:
                out.append(Defaut(27, f"définition {e.id} : statut de condition inconnu"))
            decl = {e.variable[0]} | {n for (n, _) in e.locales}
            for a in e.suffisante + e.necessaire:
                if _vars_atome(a) - decl:
                    out.append(Defaut(27, f"définition {e.id} : variable non déclarée"))
    from .connaissances import Ordre
    o = Ordre(K)
    for d in o.distinctions:
        if o.meme_cle(d.cle1, d.cle2):
            out.append(Defaut(28, f"{d.id} : {d.cle1} et {d.cle2} sont alias et distincts"))
    return out


def verifier(cas: Cas) -> list:
    """Tous les défauts d'un cas (RF1 à RF31)."""
    pd = frozenset(p.id for p in cas.description.points)
    pq = frozenset(p.id for p in cas.definition.points)
    out = verifier_description(cas.description, cas.connaissances, pq)
    out.extend(verifier_definition(cas.definition, pd))
    out.extend(verifier_connaissances(cas.connaissances))
    # RF26 : la condition suffisante implique la condition nécessaire, sous chaque interprétation de Δ
    Dl = cas.definition
    if Dl.necessaire is not None and Dl.necessaire != Dl.suffisante and not any(d.regle in (20, 21, 22, 24)
                                                                                 for d in out):
        from .inclusion import comparer
        from .interprete import omega, resoudre_formule, sortes_de
        for i in omega(Dl.points) or [{}]:
            fs, fn = resoudre_formule(Dl.suffisante, i), resoudre_formule(Dl.necessaire, i)
            s = dict(Dl.variables)
            v = comparer(fs, fn, cas.connaissances, s, s)
            if v.verdict == "non":
                out.append(Defaut(26, f"sous {i}, la condition suffisante n'implique pas la condition nécessaire "
                                      f"({v.raison})"))
    return out


def avertissements(cas: Cas) -> list:
    """Ce qui n'est pas une faute mais se signale : une condition dont l'implication n'est pas décidée."""
    out = []
    Dl = cas.definition
    if Dl.necessaire is not None and Dl.necessaire != Dl.suffisante:
        from .inclusion import comparer
        from .interprete import omega, resoudre_formule
        for i in omega(Dl.points) or [{}]:
            v = comparer(resoudre_formule(Dl.suffisante, i), resoudre_formule(Dl.necessaire, i), cas.connaissances,
                         dict(Dl.variables), dict(Dl.variables))
            if v.verdict == "indetermine":
                out.append(f"RF26 : sous {i}, l'implication suffisante ⇒ nécessaire est indéterminée ({v.raison})")
    return out
