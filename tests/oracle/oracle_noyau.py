"""Oracle indépendant de la sémantique du noyau logique (docs/NOYAU.md, version 0.3, avec les amendements du
cycle 7 : prémisses d'existence et d'événement d'un appui, distinction établie et nombre à existence niée, `meme`
dans une classe, distinction supposée au sens large, genre nié par une entité nue seulement ; et les décisions du
27/11 : D30, la polysémie (sens conceptuels, liens certains ou hypothèses de sens, négations certaines ou seulement
possibles, hypothèses sens_suppose et negation_autre_sens) ; D50, un nom nié d'un porteur absent ne conteste rien ;
D31, la portée et les fondements des réfutations, que l'oracle ne calcule pas : le banc ne compare que les statuts).

Ce module est écrit d'après docs/NOYAU.md (§ 1, § 1.1, § 2, § 3, § 4.1 à 4.5) et docs/ASSERTIONS.md seuls :
aucun fichier Prolog du moteur (oedipamaas/) n'a été lu pour l'écrire. Les seuls fichiers Prolog lus sont les
données des tests génératifs (tests/plunit/connaissances_gen.pl et le générateur
tests/plunit/generateur_noyau.pl), reproduits en Python au § 6 pour le banc « gen ». Il sert de troisième
voix dans un banc différentiel (differentiel.py) contre le moteur optimisé (satisfaction.pl) et le moteur de
référence (satisfaction_reference.pl).

Principe : la lisibilité prime sur la vitesse. Chaque fonction cite le paragraphe qu'elle met en œuvre.
Là où le texte est ambigu, la lecture choisie est notée « LECTURE » dans le code et rassemblée dans
AMBIGUITES (en bas du fichier).

Contenu :
  1. le graphe (§ 1, ASSERTIONS.md) et les états des appuis ;
  2. le module de connaissances K (§ 2) ;
  3. les requêtes (§ 3) : arbres de tuples ;
  4. la satisfaction (§ 4.1 à 4.4) : statut(graphe, K, requete), sans budget ;
  5. un générateur aléatoire de cas, et leur écriture en Prolog ;
  6. la reproduction en Python du K et du générateur des tests génératifs (connaissances_gen.pl).

Représentation d'une requête (§ 3) : des tuples
    ('et', [F, ...])  ('ou', [F, ...])
    ('type', X, T)  ('nom', X, [Cle, ...])  ('propriete', X, P)  ('evenement', E, P)
    ('role', E, R, X)  ('relation', X, R, Y)  ('genre', T)
    ('meme', X, Y)  ('distincts', X, Y)  ('nombre', X, K)
où les positions de variable portent le nom de la variable (une chaîne, 'x', 'y', 'e').
"""

from __future__ import annotations

import functools
import itertools
import random
import re
from dataclasses import dataclass, field
from typing import Optional

# ---------------------------------------------------------------------------------------------------------
# 1. Le graphe d'un texte (§ 1 ; docs/ASSERTIONS.md, « Termes » et « Validation »)
# ---------------------------------------------------------------------------------------------------------

AUTEUR = "auteur"


def cite(x: str):
    """ASSERTIONS.md : `enonciateur(A, cite(X))`, une autorité citée."""
    return ("cite", x)


POLARITES = ("pos", "neg")
MODALITES = ("affirme", "probable", "possible", "traditionnel", "ancien", "non_affirme", "titre")
PORTEES = ("represente", "oeuvre", "autre_oeuvre", "source", "histoire", "non_ancre")
ROLES = ("agent", "patient", "theme", "instrument", "destinataire", "lieu")

# § 1 : « une condition qui demande le contexte C (represente pour la figuration, oeuvre pour le classement) ».
FIGURATION = "represente"
CLASSEMENT = "oeuvre"


@dataclass(frozen=True)
class Qualif:
    """ASSERTIONS.md : chaque identifiant d'assertion porte exactement un terme de chaque qualificatif."""
    polarite: str = "pos"
    modalite: str = "affirme"
    portee: str = "represente"
    enonciateur: object = AUTEUR


@dataclass(frozen=True)
class Graphe:
    """Les assertions d'un document (ASSERTIONS.md, « Termes »), hors texte/doc/passage (fixés).

    entites      : (E, Tete)                    entite(E, Tete, p)
    noms         : (A, E, Nom)                  nom(A, E, Nom, p)
    proprietes   : (A, E, Prop)                 propriete(A, E, Prop, p)
    evenements   : (V, Predicat)                evenement(V, Predicat, p)
    roles        : (V, Role, E)                 role(V, Role, E)
    relations    : (A, E1, Rel, E2)             relation(A, E1, Rel, E2, p)
    corefs       : (E1, E2)                     coref(E1, E2)
    distincts    : (E1, E2)                     distinct(E1, E2)
    nombres      : (E, N)                       nombre(E, N)
    qualifs      : ((Id, Qualif), ...)          polarite/2, modalite/2, portee/2, enonciateur/2
    alternatives : (G, (A1, A2, ...))           alternative(G, [A1, A2, ...])
    """
    entites: tuple = ()
    noms: tuple = ()
    proprietes: tuple = ()
    evenements: tuple = ()
    roles: tuple = ()
    relations: tuple = ()
    corefs: tuple = ()
    distincts: tuple = ()
    nombres: tuple = ()
    qualifs: tuple = ()          # tuple de (Id, Qualif), pour rester hachable
    alternatives: tuple = ()

    def qualif(self, ident) -> Qualif:
        for i, q in self.qualifs:
            if i == ident:
                return q
        raise KeyError(ident)

    def ids_entites(self):
        return [e for e, _ in self.entites]

    def ids_evenements(self):
        return [v for v, _ in self.evenements]

    def ids_assertions(self):
        """ASSERTIONS.md : les identifiants d'assertion sont E d'une entité, V d'un événement, A d'un nom,
        d'une propriété ou d'une relation."""
        return (self.ids_entites() + self.ids_evenements() + [a for a, _, _ in self.noms]
                + [a for a, _, _ in self.proprietes] + [a for a, _, _, _ in self.relations])


def valider(g: Graphe) -> list:
    """ASSERTIONS.md, « Validation » : la liste des erreurs (vide si tout va bien).
    Sert seulement à garantir que les générateurs ne tirent que des graphes valides."""
    erreurs = []
    ids = g.ids_assertions() + [gid for gid, _ in g.alternatives]
    if len(ids) != len(set(ids)):
        erreurs.append("identifiants non uniques")
    ents, evs, asserts = set(g.ids_entites()), set(g.ids_evenements()), set(g.ids_assertions())
    for _, e, _ in g.noms + g.proprietes:
        if e not in ents:
            erreurs.append(("entite inconnue", e))
    for _, e1, _, e2 in g.relations:
        if e1 not in ents or e2 not in ents:
            erreurs.append(("entite inconnue", e1, e2))
    for v, r, e in g.roles:
        if v not in evs or e not in ents or r not in ROLES:
            erreurs.append(("role", v, r, e))
    for e1, e2 in g.corefs + g.distincts:
        if e1 not in ents or e2 not in ents:
            erreurs.append(("coref/distinct hors entites", e1, e2))
    for e, n in g.nombres:
        if e not in ents or not (isinstance(n, int) and n >= 1):
            erreurs.append(("nombre", e, n))
    qids = [i for i, _ in g.qualifs]
    if sorted(qids) != sorted(asserts):
        erreurs.append("qualificatifs : exactement un de chaque par assertion")
    for i, q in g.qualifs:
        if (q.polarite not in POLARITES or q.modalite not in MODALITES or q.portee not in PORTEES
                or not (q.enonciateur == AUTEUR or (isinstance(q.enonciateur, tuple)
                                                    and q.enonciateur[0] == "cite"))):
            erreurs.append(("qualificatif", i))
    for gid, membres in g.alternatives:
        if len(membres) < 2 or any(m not in asserts for m in membres):
            erreurs.append(("alternative", gid))
    return erreurs


# --- § 1, « Les référents » -------------------------------------------------------------------------------

@functools.lru_cache(maxsize=None)
def classe_de(g: Graphe, e) -> frozenset:
    """§ 1 : la classe de coréférence établie de e (fermeture réflexive, symétrique, transitive de coref/2)."""
    classe = {e}
    change = True
    while change:
        change = False
        for a, b in g.corefs:
            if (a in classe) != (b in classe):
                classe |= {a, b}
                change = True
    return frozenset(classe)


def representant(g: Graphe, e):
    """§ 1 : le représentant d'une classe est son plus petit identifiant (ordre standard des atomes)."""
    return min(classe_de(g, e))


def membres(g: Graphe, r) -> frozenset:
    """Les entités de la classe dont r est le représentant."""
    return classe_de(g, r)


@functools.lru_cache(maxsize=None)
def referents(g: Graphe) -> list:
    """§ 4.1 : les valeurs d'une variable de référent sont les représentants de classe."""
    return sorted({representant(g, e) for e in g.ids_entites()})


# --- § 1, « L'état d'un appui » ---------------------------------------------------------------------------

def dans_une_alternative(g: Graphe, a) -> bool:
    """§ 1 : « hors de toute alternative »."""
    return any(a in m for _, m in g.alternatives)


def qualifiee(g: Graphe, a, polarite: str, contexte: str) -> bool:
    """§ 1 : polarité donnée, modalité « affirmé », portée C, hors de toute alternative."""
    q = g.qualif(a)
    return (q.polarite == polarite and q.modalite == "affirme" and q.portee == contexte
            and not dans_une_alternative(g, a))


def presente(g: Graphe, e, contexte: str) -> bool:
    """§ 1 : une entité **présente** : positive, affirmée, de portée C, hors de toute alternative. C'est
    l'entité citée elle-même, pas un autre membre de sa classe."""
    return qualifiee(g, e, "pos", contexte)


def presente_selon_auteur(g: Graphe, e, contexte: str) -> bool:
    """§ 1 (D25) : présente, et d'énonciateur `auteur`."""
    return presente(g, e, contexte) and g.qualif(e).enonciateur == AUTEUR


def etat(g: Graphe, a, entites_parlees, contexte: str):
    """§ 1 : l'état d'un appui, ('pos', Q), ('neg', Q) ou None.

    a : l'identifiant dont les qualificatifs s'appliquent (pour un rôle, son événement) ;
    entites_parlees : les entités dont l'assertion parle, autres qu'elle-même (l'entité citée par un nom ou
    une propriété, les deux entités d'une relation, le participant d'un rôle).
    - pos(Q) : polarité positive, affirmé, portée C, hors alternative, chaque entité dont elle parle présente ;
      Q est l'énonciateur de l'assertion si chacune de ces entités est présente selon l'auteur, et sinon
      l'énonciateur de celle qui ne l'est pas (D25) ;
    - neg(Q) : polarité négative, affirmé, portée C, hors alternative, chaque entité dont elle parle, autre
      qu'elle-même, présente ; Q l'énonciateur de l'assertion ;
    - aucun état sinon."""
    q = g.qualif(a)
    if not all(presente(g, e, contexte) for e in entites_parlees):
        return None
    if qualifiee(g, a, "pos", contexte):
        non_auteur = [g.qualif(e).enonciateur for e in entites_parlees
                      if g.qualif(e).enonciateur != AUTEUR]
        # LECTURE : si plusieurs entités ne sont pas de l'auteur, Q est l'énonciateur de la première ; seul
        # compte ici que Q ne soit pas `auteur`.
        return ("pos", non_auteur[0] if non_auteur else q.enonciateur)
    if qualifiee(g, a, "neg", contexte):
        return ("neg", q.enonciateur)
    return None


# ---------------------------------------------------------------------------------------------------------
# 2. Les connaissances (§ 2)
# ---------------------------------------------------------------------------------------------------------

CATEGORIES = ("n", "v", "a", "r")


@dataclass(frozen=True)
class Connaissances:
    """§ 2. sens : paires (Mot, Type), pour toutes les catégories (le K de test ne distingue pas les
    catégories) ; sous et inclus : arcs (Type, Parent) ; cles : paires (Nom, Cle) de cle_de_nom ; alias :
    paires (Cle1, Cle2), **non closes** (le noyau les clôt, D33) ; distincts_documentes : (Cle1, Cle2, Source).
    module : le nom du module Prolog ; fichier : le fichier Prolog s'il existe déjà (None : à écrire)."""
    sens_paires: frozenset
    sous: frozenset
    inclus: frozenset
    cles: frozenset
    alias: frozenset
    distincts_documentes: frozenset
    version: str = "oracle_2"
    module: str = "k_oracle"
    fichier: Optional[str] = None

    @functools.cached_property
    def _sens(self) -> dict:
        d = {}
        for m, t in self.sens_paires:
            d.setdefault(m, set()).add(t)
        return d

    def sens(self, mot) -> set:
        """K:sens(Cat, Mot, Type), toutes catégories confondues."""
        return self._sens.get(mot, set())

    @functools.cached_property
    def _cles(self) -> dict:
        return dict(self.cles)

    def cle_de_nom(self, nom):
        """K:cle_de_nom(Nom, Cle)."""
        return self._cles.get(nom)

    @functools.cached_property
    def _composantes_alias(self) -> dict:
        """§ 2 (D33) : l'alias est clos par le noyau (réflexif, symétrique, transitif), quel que soit K."""
        comp = {}
        for a, b in self.alias:
            ca, cb = comp.get(a, {a}), comp.get(b, {b})
            u = ca | cb
            for x in u:
                comp[x] = u
        return comp

    def alias_eq(self, c1, c2) -> bool:
        return c1 == c2 or c2 in self._composantes_alias.get(c1, ())

    @functools.lru_cache(maxsize=None)
    def atteint(self, arcs_nom: str, depart, arrivee) -> bool:
        """§ 2 : existe-t-il un chemin simple [depart, ..., arrivee] (longueur zéro permise) par les arcs
        donnés ? Un chemin simple existe exactement quand arrivee est atteignable : parcours en largeur, chaque
        nœud vu une fois (la hiérarchie peut avoir des cycles)."""
        arcs = getattr(self, arcs_nom)
        vus, front = {depart}, [depart]
        while front:
            n = front.pop()
            if n == arrivee:
                return True
            for t, p in arcs:
                if t == n and p not in vus:
                    vus.add(p)
                    front.append(p)
        return False


def est_concept(t) -> bool:
    """§ 2 (D27) : un identifiant de concept est un entier."""
    return isinstance(t, int) and not isinstance(t, bool)


def sens_conceptuels(K: Connaissances, mot) -> set:
    """§ 2, « La polysémie » (D30) : les sens conceptuels d'un mot sont ses identifiants de concepts (les entiers que
    K lui donne), s'il en a ; sinon ses sens tels que K les donne (le mot lui-même, D20)."""
    s = K.sens(mot)
    concepts = {t for t in s if est_concept(t)}
    return concepts if concepts else set(s)


def lien_positif(K: Connaissances, mot, type_demande) -> bool:
    """§ 2 : chemin(Mot, [T0, ..., Tn]) : T0 un sens conceptuel du mot (D30), K:sous(Ti, Ti+1), Tn le type demandé.
    Un mot du texte va vers un type plus général."""
    return any(K.atteint("sous", t0, type_demande) for t0 in sens_conceptuels(K, mot))


def lien_certain(K: Connaissances, mot, type_demande) -> bool:
    """§ 2 (D30) : un lien positif est **certain** si chacun des sens conceptuels du mot atteint le type demandé ;
    sinon il ne fonde qu'une hypothèse de sens, sens_suppose(Mot, Type)."""
    sc = sens_conceptuels(K, mot)
    return bool(sc) and all(K.atteint("sous", t0, type_demande) for t0 in sc)


def noeuds_du_type(K: Connaissances, type_demande) -> set:
    """§ 2 (D27, D30) : les nœuds du type demandé : le type lui-même si c'est un identifiant de concept (un entier),
    sinon ses sens conceptuels."""
    return {type_demande} if est_concept(type_demande) else sens_conceptuels(K, type_demande)


def force_negation(K: Connaissances, type_demande, mot) -> Optional[str]:
    """§ 2 : chemin_inclus(Type, [S0, ..., Sn], Mot) : S0 un nœud du type demandé, K:inclus(Si, Si+1), Sn un sens
    conceptuel du mot nié (nier un type plus général nie les plus spécifiques), par la seule inclusion.
    D30 : la négation est 'certaine' si chaque nœud du type demandé est inclus dans chaque sens conceptuel du mot
    nié ; 'possible' si un couple seulement l'est (elle ne réfute rien, ne contredit rien) ; None sinon."""
    couples = [(s0, sn) for s0 in noeuds_du_type(K, type_demande) for sn in sens_conceptuels(K, mot)]
    inclus = [K.atteint("inclus", s0, sn) for s0, sn in couples]
    if couples and all(inclus):
        return "certaine"
    if any(inclus):
        return "possible"
    return None


def lien_negatif(K: Connaissances, type_demande, mot, force: str = "certaine") -> bool:
    """Un lien négatif de la force demandée ('certaine' : un appui négatif ; 'possible' : D30, une négation qui ne
    fonde qu'une hypothèse negation_autre_sens sur ce qu'elle touche)."""
    return force_negation(K, type_demande, mot) == force


def cle_correspond(K: Connaissances, cle_texte, cles_demandees) -> bool:
    """§ 3 : « X porte l'un de ces noms (ou un alias établi) », l'alias clos (§ 2, D33)."""
    if cle_texte is None:
        return False
    return any(K.alias_eq(cle_texte, c) for c in cles_demandees)


# ---------------------------------------------------------------------------------------------------------
# 3. Le langage des requêtes (§ 3)
# ---------------------------------------------------------------------------------------------------------

ATOMES = ("type", "nom", "propriete", "evenement", "role", "relation", "genre")
CONTRAINTES = ("meme", "distincts", "nombre")


def est_atome(f) -> bool:
    return f[0] in ATOMES


def est_contrainte(f) -> bool:
    return f[0] in CONTRAINTES


def variables_feuille(f) -> list:
    """Les variables d'un atome ou d'une contrainte (§ 3), dans l'ordre des arguments."""
    t = f[0]
    if t in ("type", "nom", "propriete", "evenement", "nombre"):
        return [f[1]]
    if t in ("role", "relation"):
        return [f[1], f[3]]
    if t in ("meme", "distincts"):
        return [f[1], f[2]]
    if t == "genre":
        return []
    raise ValueError(f)


def feuilles(f, chemin=()):
    """Toutes les feuilles de la formule, avec leur chemin (indices à partir de 1, § 5)."""
    if f[0] in ("et", "ou"):
        for i, enfant in enumerate(f[1], start=1):
            yield from feuilles(enfant, chemin + (i,))
    else:
        yield chemin, f


def variables(f) -> list:
    """Les variables de la formule."""
    return sorted({v for _, feuille in feuilles(f) for v in variables_feuille(feuille)})


def sortes(f) -> dict:
    """§ 3 : la sorte d'une variable : événement si elle est premier argument de `evenement` ou de `role`,
    référent si elle est un autre argument d'atome. Les contraintes ne donnent pas de sorte : une contrainte
    sur une variable d'événement est un défaut à part (`contrainte_sur_evenement`, D35).
    Rend {variable: ensemble des sortes où elle apparaît dans un atome}."""
    s = {}
    for _, feuille in feuilles(f):
        if not est_atome(feuille):
            continue
        for i, v in enumerate(variables_feuille(feuille)):
            evt = feuille[0] in ("evenement", "role") and i == 0
            s.setdefault(v, set()).add("evenement" if evt else "referent")
    return s


def selections(f, chemin=()):
    """§ 4.3 : une sélection prend tous les enfants d'un `et` et un enfant d'un `ou`.
    Rend la liste des sélections, chacune un tuple de (chemin, feuille)."""
    if f[0] == "et":
        parts = [selections(enfant, chemin + (i,)) for i, enfant in enumerate(f[1], start=1)]
        return [tuple(itertools.chain.from_iterable(choix)) for choix in itertools.product(*parts)]
    if f[0] == "ou":
        return [s for i, enfant in enumerate(f[1], start=1) for s in selections(enfant, chemin + (i,))]
    return [((chemin, f),)]


def defaut_de_forme(f) -> Optional[str]:
    """§ 3 : une requête est bien formée si
    - chaque variable apparaît dans au moins un atome ;
    - un `ou` a au moins deux branches et un `et` au moins une ;
    - la sorte de chaque variable est unique ;
    - dans chaque sélection qui contient une contrainte, ses variables sont celles d'atomes de la sélection ;
    - aucune contrainte n'est distincts(X, X) ;
    - aucune contrainte ne porte sur une variable d'événement (D35).
    Rend None si elle l'est, sinon le nom du premier défaut trouvé."""
    def operateurs_ok(g):
        if g[0] == "et":
            return len(g[1]) >= 1 and all(operateurs_ok(e) for e in g[1])
        if g[0] == "ou":
            return len(g[1]) >= 2 and all(operateurs_ok(e) for e in g[1])
        return est_atome(g) or est_contrainte(g)
    if not operateurs_ok(f):
        return "operateur"
    vars_atomes = {v for _, x in feuilles(f) if est_atome(x) for v in variables_feuille(x)}
    if set(variables(f)) - vars_atomes:
        return "variable_sans_atome"
    so = sortes(f)
    if any(len(s) != 1 for s in so.values()):
        return "sorte"
    for _, x in feuilles(f):
        if est_contrainte(x) and any(so.get(v) == {"evenement"} for v in variables_feuille(x)):
            return "contrainte_sur_evenement"
    if any(x[0] == "distincts" and x[1] == x[2] for _, x in feuilles(f)):
        return "distincts_reflexif"
    for sel in selections(f):
        dans_atomes = {v for _, x in sel if est_atome(x) for v in variables_feuille(x)}
        for _, x in sel:
            if est_contrainte(x) and not set(variables_feuille(x)) <= dans_atomes:
                return "contrainte_non_liee"
    return None


def bien_formee(f) -> bool:
    return defaut_de_forme(f) is None


# ---------------------------------------------------------------------------------------------------------
# 4.1 Les valeurs des atomes et des contraintes
# ---------------------------------------------------------------------------------------------------------

INCONNU, VRAI, FAUX, CONTRADICTOIRE = (0, 0), (1, 0), (0, 1), (1, 1)
NOM_VALEUR = {INCONNU: "inconnu", VRAI: "vrai", FAUX: "faux", CONTRADICTOIRE: "contradictoire"}


@dataclass(frozen=True)
class Appui:
    """Un appui positif d'un atome : son énonciateur Q (§ 1), l'assertion, et le mot de l'appui (la tête, le
    prédicat, la propriété, la relation, ou la clé du nom), qui sert à reformer la prémisse (§ 4.3) ; les entités que
    l'appui cite (§ 4.3, 0.3 amendée : leur existence est une prémisse) et, pour un rôle, son événement ; certain :
    le lien de l'appui est certain (D30 : chaque sens conceptuel du mot atteint le type demandé), sinon l'appui ne
    certifie que sous l'hypothèse sens_suppose(Mot, Type)."""
    enonciateur: object
    assertion: object
    mot: object
    cites: tuple = ()
    evenement: object = None
    certain: bool = True


def contexte_de(atome) -> str:
    """§ 1 : genre(T) est une condition de classement (contexte oeuvre), les autres de figuration."""
    return CLASSEMENT if atome[0] == "genre" else FIGURATION


def appuis_positifs(g: Graphe, K: Connaissances, atome, sigma: dict) -> list:
    """§ 4.1 et § 1 : les appuis positifs (lien positif, état pos) d'un atome dont les variables sont liées.
    « Un nom, un type, une propriété d'un membre valent pour la classe » (LECTURE : les relations et les rôles
    aussi : leurs variables désignent des référents)."""
    C = contexte_de(atome)
    t = atome[0]
    res = []
    if t == "type":
        _, x, T = atome
        for e, tete in g.entites:
            if representant(g, e) == sigma[x] and lien_positif(K, tete, T):
                st = etat(g, e, [], C)
                if st and st[0] == "pos":
                    res.append(Appui(st[1], e, tete, (e,), certain=lien_certain(K, tete, T)))
    elif t == "nom":
        _, x, cles = atome
        for a, e, nom in g.noms:
            cle = K.cle_de_nom(nom)
            if representant(g, e) == sigma[x] and cle_correspond(K, cle, cles):
                st = etat(g, a, [e], C)
                if st and st[0] == "pos":
                    res.append(Appui(st[1], a, cle, (e,)))
    elif t == "propriete":
        _, x, P = atome
        for a, e, prop in g.proprietes:
            if representant(g, e) == sigma[x] and lien_positif(K, prop, P):
                st = etat(g, a, [e], C)
                if st and st[0] == "pos":
                    res.append(Appui(st[1], a, prop, (e,), certain=lien_certain(K, prop, P)))
    elif t == "relation":
        _, x, R, y = atome
        for a, e1, rel, e2 in g.relations:
            if (representant(g, e1) == sigma[x] and representant(g, e2) == sigma[y]
                    and lien_positif(K, rel, R)):
                st = etat(g, a, [e1, e2], C)
                if st and st[0] == "pos":
                    res.append(Appui(st[1], a, rel, (e1, e2), certain=lien_certain(K, rel, R)))
    elif t == "evenement":
        _, ev, P = atome
        for v, pred in g.evenements:
            # LECTURE : l'assertion d'un événement ne parle d'aucune entité ; ses participants sont dans ses
            # rôles (§ 1 : « le participant d'un rôle »).
            if v == sigma[ev] and lien_positif(K, pred, P):
                st = etat(g, v, [], C)
                if st and st[0] == "pos":
                    res.append(Appui(st[1], v, pred, certain=lien_certain(K, pred, P)))
    elif t == "role":
        _, ev, R, x = atome
        for v, r, e in g.roles:
            # § 1 : « Un rôle positif a l'état de son événement et demande son participant présent. »
            if v == sigma[ev] and r == R and representant(g, e) == sigma[x]:
                st = etat(g, v, [e], C)
                if st and st[0] == "pos":
                    res.append(Appui(st[1], ("role", v, r, e), r, (e,), v))
    elif t == "genre":
        _, T = atome
        for e, tete in g.entites:
            if lien_positif(K, tete, T):
                st = etat(g, e, [], C)
                if st and st[0] == "pos":
                    # AMBIGUITES, premisse_genre : l'existence de l'entité de portée oeuvre est-elle aussi lue dans
                    # le contexte de la figuration ? Lecture : non (variante 'figuration' : oui).
                    cites = (e,) if LECTURES["existence_genre"] == "figuration" else ()
                    res.append(Appui(st[1], e, tete, cites, certain=lien_certain(K, tete, T)))
    return res


def entite_nue(g: Graphe, e) -> bool:
    """§ 1.1 : une entité **nue** : rien d'autre n'en est dit (ni nom, propriété, relation, rôle, nombre,
    distinction). LECTURE : toute assertion qui la cite compte, quels que soient ses qualificatifs ; la
    coréférence n'est pas « dite de » l'entité (elle n'est pas dans la liste)."""
    return not (any(x[1] == e for x in g.noms) or any(x[1] == e for x in g.proprietes)
                or any(e in (x[1], x[3]) for x in g.relations) or any(x[2] == e for x in g.roles)
                or any(x[0] == e for x in g.nombres) or any(e in x for x in g.distincts))


def appuis_negatifs(g: Graphe, K: Connaissances, atome, sigma: dict, force: str = "certaine") -> list:
    """§ 1.1 : les appuis négatifs d'un atome dont les variables sont liées (une liste d'identifiants
    d'assertions niées ; une liste de noms en demande une par clé). Rien d'autre ne nie un atome.
    force='possible' (D30) : les négations qui remplissent les mêmes conditions mais dont le lien négatif n'est que
    possible (un couple de sens seulement) : elles ne sont pas des appuis négatifs (aucune valeur négative) ; elles
    ne fondent que l'hypothèse negation_autre_sens de ce qu'elles touchent. Un nom n'a pas de sens : jamais possible."""
    C = contexte_de(atome)
    neg = lambda T, w: lien_negatif(K, T, w, force)
    t = atome[0]
    res = []
    if t == "type":
        # entite(E, W) nue, dans une classe qui a un membre présent : type(X, T) sous σ(X) cette classe ;
        # nue et seule dans sa classe : type(X, T) pour tout référent ; restreinte : rien.
        _, x, T = atome
        for e, tete in g.entites:
            st = etat(g, e, [], C)
            if not (st and st[0] == "neg" and entite_nue(g, e) and neg(T, tete)):
                continue
            classe = classe_de(g, e)
            if len(classe) == 1:
                res.append(e)
            elif representant(g, e) == sigma[x] and (any(presente(g, m, C) for m in classe)
                                                     or not LECTURES["classe_presente"]):
                res.append(e)
    elif t == "nom":
        # nom(A, E, Nom) nié, E présente : nom(X, Ks) si chaque clé de Ks est niée ainsi (D24).
        _, x, cles = atome
        if force != "certaine":
            return []
        par_cle = []
        for k in cles:
            niees = [a for a, e, nom in g.noms
                     if representant(g, e) == sigma[x] and cle_correspond(K, K.cle_de_nom(nom), [k])
                     and (st := etat(g, a, [e], C)) and st[0] == "neg"]
            if not niees:
                return []
            par_cle.append(niees)
        res.append(tuple(sorted({a for n in par_cle for a in n})))
    elif t == "propriete":
        _, x, P = atome
        for a, e, prop in g.proprietes:
            if representant(g, e) == sigma[x] and neg(P, prop):
                st = etat(g, a, [e], C)
                if st and st[0] == "neg":
                    res.append(a)
    elif t == "relation":
        _, x, R, y = atome
        for a, e1, rel, e2 in g.relations:
            if (representant(g, e1) == sigma[x] and representant(g, e2) == sigma[y]
                    and neg(R, rel)):
                st = etat(g, a, [e1, e2], C)
                if st and st[0] == "neg":
                    res.append(a)
    elif t == "evenement":
        # evenement(N, W) nié et ses rôles : evenement(V, P) pour un autre événement V présent qui a, pour
        # chaque rôle de N, le même rôle vers un membre de la même classe ; P inclus dans W.
        _, ev, P = atome
        V = sigma[ev]
        v_present = qualifiee(g, V, "pos", C)
        if v_present:
            for N, pred in g.evenements:
                if N == V or not neg(P, pred):
                    continue
                roles_n = [(r, e) for (n, r, e) in g.roles if n == N]
                # LECTURE : l'événement nié parle des participants de ses rôles, qui doivent être présents
                # (§ 1 : « chaque entité dont elle parle, autre qu'elle-même, présente »).
                st = etat(g, N, [e for _, e in roles_n] if LECTURES["evenement_participants"] else [], C)
                if not (st and st[0] == "neg"):
                    continue
                # LECTURE : le rôle de V vers un membre de la même classe est une assertion role/3 de V, quel
                # que soit l'état de son participant (V, lui, est présent).
                if all(any(v2 == V and r2 == r and representant(g, e2) == representant(g, e)
                           for (v2, r2, e2) in g.roles) for r, e in roles_n):
                    res.append(N)
    elif t == "role":
        pass                                          # § 1.1 : un rôle n'est pas nié seul
    elif t == "genre":
        # entite(E, W) **nue** de portée oeuvre : genre(T), T inclus dans W (0.3 amendée : « pas un portrait mort »
        # ne nie pas le genre). Nue au sens de la ligne 4 de la table (entite_nue).
        _, T = atome
        for e, tete in g.entites:
            st = etat(g, e, [], C)
            if st and st[0] == "neg" and neg(T, tete) and (entite_nue(g, e) or not GENRE_NU):
                res.append(e)
    return res


GENRE_NU = True    # § 1.1 (0.3 amendée) : seule une entité nue de portée oeuvre nie genre(T)

# Les lectures choisies là où le texte est ambigu (AMBIGUITES), et leur variante, pour mesurer leur effet dans le
# banc (differentiel.py --lecture cle=valeur). Les valeurs par défaut sont la lecture de l'oracle.
LECTURES = {
    "classe_presente": True,          # § 1.1, ligne 4 : la classe d'une entité niée nue doit avoir un membre présent
    "evenement_participants": True,   # § 1.1 : l'événement nié demande ses participants présents
    "noms_porteur": "etat",           # § 1, § 4.1 : les noms « portés » par une classe (distinction supposée, et
                                      # exclusion de la documentaire) : état pos ('etat'), ou seulement les
                                      # qualificatifs du nom, porteur non vérifié ('qualifie')
    "porte_conteste": True,           # § 4.1 : un nom contesté est-il « porté » (exclusion de la documentaire) ?
    # § 4.1 (version 0.3, décision du cycle 6) : l'exclusion de la documentaire compte tout nom affirmé positivement
    # dans la classe, quels que soient ses qualificatifs et son porteur, contesté ou non ('polarite') ; l'ancienne
    # lecture de l'oracle : les noms dans l'état pos ('etat')
    "exclusion_documentaire": "polarite",
    # § 4.3 (0.3 amendée) : l'existence de l'entité qui appuie un genre (portée oeuvre) n'est lue que dans le contexte
    # du classement, où elle est la prémisse reformée genre(W) ('oeuvre') ; variante : aussi comme type(X, W) dans le
    # contexte de la figuration ('figuration' : « pas de chien » figuré ôte sa prémisse au genre « chien »)
    "existence_genre": "oeuvre",
    # § 4.3 (0.3 amendée) : une distinction établie à l'existence niée ne certifie pas `distincts`, sans empêcher une
    # distinction documentaire ou supposée qui tient par ailleurs ('independante') ; variante : dès qu'une distinction
    # établie existe entre les deux classes, seules les distinctions établies peuvent certifier ('etablie_prime')
    "distinction_niee": "independante",
    # § 4.1 : un nom « qu'une assertion niée de la classe contredit » : appui négatif, porteur présent ('etat') ; variante :
    # toute assertion de nom niée affirmée, de portée figuration, hors alternative, porteur non vérifié ('qualifie')
    "conteste": "etat",
    # D30 : une négation seulement possible de l'existence d'une entité d'une distinction établie ou d'un nombre :
    # sans effet ('ignoree', § 6 point 7 n'en parle que pour les atomes) ; variante : l'hypothèse negation_autre_sens
    # ('hypothese', § 2 : « une conclusion positive qu'elle touche »)
    "existence_contrainte": "ignoree",
}


def lie(atome, sigma) -> bool:
    return all(v in sigma for v in variables_feuille(atome))


def valeur_atome(g, K, atome, sigma) -> tuple:
    """§ 4.1 : (0,0) si une variable n'est pas liée ; sinon (un appui positif ?, un appui négatif ?)."""
    if not lie(atome, sigma):
        return INCONNU
    return (int(bool(appuis_positifs(g, K, atome, sigma))), int(bool(appuis_negatifs(g, K, atome, sigma))))


def a_un_appui(g, K, atome, sigma) -> bool:
    """§ 4.4 : l'atome, entièrement lié, a sous σ un appui de l'un ou l'autre signe."""
    return lie(atome, sigma) and valeur_atome(g, K, atome, sigma) != INCONNU


def reforme(atome, mot):
    """§ 4.3 : la prémisse d'un appui : l'atome reformé avec le mot même de l'appui (`type(X, W)` pour une
    entité de mot W, `nom(X, [Clé])` pour un nom, etc.)."""
    t = atome[0]
    if t in ("type", "propriete", "evenement"):
        return (t, atome[1], mot)
    if t == "nom":
        return ("nom", atome[1], [mot])
    if t == "relation":
        return ("relation", atome[1], mot, atome[3])
    if t == "role":
        return atome
    if t == "genre":
        return ("genre", mot)
    raise ValueError(atome)


def tete_de(g: Graphe, e):
    """Le mot (la tête) de l'entité e : entite(E, W)."""
    return next(t for x, t in g.entites if x == e)


def atome_existence(g, e):
    """§ 4.3 (0.3 amendée) : l'existence d'une entité, comme atome : type(X, W) sous σ(X) la classe de e, W le mot
    de e ; rend (atome, σ)."""
    return ("type", "_x", tete_de(g, e)), {"_x": representant(g, e)}


def atome_evenement(g, v):
    """§ 4.3 (0.3 amendée) : l'événement d'un rôle, comme atome : evenement(E, P) sous σ(E) = v, P le prédicat de v."""
    pred = next(p for x, p in g.evenements if x == v)
    return ("evenement", "_e", pred), {"_e": v}


def existence_niee(g, K, e) -> bool:
    """§ 4.3 (0.3 amendée) : l'existence d'une entité est niée si le type de son mot est nié pour sa classe :
    type(X, W) sous σ(X) la classe de e, W le mot de e, a un appui négatif (§ 1.1) ; « un homme nommé Pierre ;
    il n'y a pas d'homme »."""
    return bool(appuis_negatifs(g, K, *atome_existence(g, e)))


def evenement_nie(g, K, v) -> bool:
    """§ 4.3 (0.3 amendée) : la prémisse d'un rôle qu'est son événement est niée si l'atome de prédicat de cet
    événement, evenement(E, P) sous σ(E) = v, P le prédicat de v, a un appui négatif (§ 1.1)."""
    return bool(appuis_negatifs(g, K, *atome_evenement(g, v)))


def premisse_niee(g, K, atome, sigma, ap: Appui) -> bool:
    """§ 4.3 (0.3 amendée) : une prémisse de l'appui est niée (certainement, D30) :
    (a) l'atome reformé avec le mot même de l'appui a un appui négatif ;
    (b) l'existence d'une entité que l'appui cite est niée (existence_niee) ;
    (c) pour un rôle, son événement est nié (evenement_nie).
    LECTURE (AMBIGUITES, premisse_genre) : l'appui d'un genre (une entité de portée oeuvre) ne cite aucune entité de
    figuration ; son existence, dans le contexte oeuvre, est la prémisse (a), genre(W)."""
    if appuis_negatifs(g, K, reforme(atome, ap.mot), sigma):
        return True
    if any(existence_niee(g, K, e) for e in ap.cites):
        return True
    return ap.evenement is not None and evenement_nie(g, K, ap.evenement)


def instancier(atome, sigma):
    """§ 5 (D30) : l'atome d'une hypothèse negation_autre_sens(Atome), instancié par σ (référents par leur
    représentant de classe, événements par leur identifiant) ; une liste de clés devient un tuple."""
    return tuple(sigma.get(a, a) if isinstance(a, str) and a in sigma else (tuple(a) if isinstance(a, list) else a)
                 for a in atome)


def hypothese_negation(g, K, atome, sigma) -> set:
    """D30 : si l'atome (lié) n'a qu'une négation possible (aucune certaine : celle-là le nierait), l'hypothèse
    negation_autre_sens(Atome) ; sinon rien."""
    if appuis_negatifs(g, K, atome, sigma, "possible") and not appuis_negatifs(g, K, atome, sigma):
        return {("negation_autre_sens", instancier(atome, sigma))}
    return set()


def type_demande(atome):
    """Le type demandé d'un atome à lien (le T de sens_suppose(Mot, T))."""
    return atome[1] if atome[0] == "genre" else atome[2]


def hypotheses_appui(g, K, atome, sigma, ap: Appui) -> set:
    """§ 2 et § 6, point 7 (D30) : les hypothèses que demande un appui (dont aucune prémisse n'est niée) :
    - sens_suppose(Mot, Type) si son lien n'est pas certain ;
    - negation_autre_sens(A) pour une négation seulement possible de l'assertion citée reformée avec son mot, de
      l'existence d'une entité citée (type(X, W) de sa classe), de l'événement d'un rôle (evenement(V, P))."""
    h = set()
    if not ap.certain:
        h.add(("sens_suppose", ap.mot, type_demande(atome)))
    h |= hypothese_negation(g, K, reforme(atome, ap.mot), sigma)
    for e in ap.cites:
        h |= hypothese_negation(g, K, *atome_existence(g, e))
    if ap.evenement is not None:
        h |= hypothese_negation(g, K, *atome_evenement(g, ap.evenement))
    return h


def certification_atome(g, K, atome, sigma) -> Optional[tuple]:
    """§ 4.3 : l'atome est vrai (1,0) avec un appui positif de l'auteur du texte dont **aucune prémisse n'est
    niée** (premisse_niee). Un appui à prémisse niée laisse l'atome vrai, non certifiable.
    D30 : parmi les appuis admissibles, celui qui demande le moins d'hypothèses (à égalité : le premier dans l'ordre
    standard de la liste des hypothèses), plus l'hypothèse d'une négation seulement possible de l'atome lui-même.
    Rend None (non certifiable) ou le tuple trié des hypothèses (vide : certifié sans hypothèse)."""
    if valeur_atome(g, K, atome, sigma) != VRAI:
        return None
    candidats = [tuple(sorted(hypotheses_appui(g, K, atome, sigma, ap), key=repr))
                 for ap in appuis_positifs(g, K, atome, sigma)
                 if ap.enonciateur == AUTEUR and not premisse_niee(g, K, atome, sigma, ap)]
    if not candidats:
        return None
    meilleur = min(candidats, key=lambda h: (len(h), repr(h)))
    return tuple(sorted(set(meilleur) | hypothese_negation(g, K, atome, sigma), key=repr))


def atome_certifiable(g, K, atome, sigma) -> bool:
    """§ 4.3 : certifiable, avec ou sans hypothèses (certification_atome)."""
    return certification_atome(g, K, atome, sigma) is not None


# --- § 1 et § 4.1 : les trois régimes de distinction ------------------------------------------------------

DISTINCT_SELON_AUTEUR = True   # voir AMBIGUITES, distinct_present


def distinction_etablie(g: Graphe, r1, r2) -> list:
    """§ 1 : distinct(E1, E2) entre un membre de chacune des deux classes (dans un ordre ou l'autre) ; r1 == r2
    donne les distinctions dans la classe (§ 4.1, `meme` : « coréférents et distincts à la fois »).
    LECTURE (D45, journal) : une distinction ne compte qu'entre entités présentes selon l'auteur."""
    res = []
    for a, b in g.distincts:
        if {representant(g, a), representant(g, b)} != {r1, r2}:
            continue
        if DISTINCT_SELON_AUTEUR and not (presente_selon_auteur(g, a, FIGURATION)
                                          and presente_selon_auteur(g, b, FIGURATION)):
            continue
        res.append((a, b))
    return res


def nom_conteste(g: Graphe, K: Connaissances, r, cle) -> bool:
    """§ 4.1 : un nom « qu'une assertion niée de la classe contredit » : nom(X, [Clé]) a un appui négatif (état neg,
    § 1 : porteur présent). Variante LECTURES['conteste'] = 'qualifie' (AMBIGUITES, conteste_porteur) : une assertion
    de nom niée de la classe, affirmée, de portée figuration, hors alternative, quel que soit l'état de son porteur."""
    if LECTURES["conteste"] == "qualifie":
        return any(representant(g, e) == r and cle_correspond(K, K.cle_de_nom(nom), [cle])
                   and qualifiee(g, a, "neg", FIGURATION) for a, e, nom in g.noms)
    return bool(appuis_negatifs(g, K, ("nom", "_x", [cle]), {"_x": r}))


def noms_portes(g: Graphe, K: Connaissances, r, auteur_seul: bool, porteur: bool = True) -> set:
    """Les clés des noms de la classe r dans l'état pos (au contexte de figuration) ; auteur_seul : d'un appui
    de l'auteur (de l'auteur, d'un porteur présent selon l'auteur, § 1) ; porteur=False : la présence du porteur
    n'est pas vérifiée (variante 'qualifie' de LECTURES['noms_porteur'])."""
    cles = set()
    for a, e, nom in g.noms:
        cle = K.cle_de_nom(nom)
        if representant(g, e) == r and cle is not None:
            st = etat(g, a, [e] if porteur else [], FIGURATION)
            if st and st[0] == "pos" and (not auteur_seul or st[1] == AUTEUR):
                cles.add(cle)
    return cles


def noms_affirmes(g: Graphe, K: Connaissances, r) -> set:
    """Les clés des noms de la classe r dont la polarité est positive, quels que soient leurs autres qualificatifs et
    leur porteur (§ 4.1 : ce qu'une classe « porte » pour exclure une distinction documentaire)."""
    return {K.cle_de_nom(nom) for a, e, nom in g.noms
            if representant(g, e) == r and K.cle_de_nom(nom) is not None and g.qualif(a).polarite == "pos"}


def noms_admissibles(g, K, r) -> set:
    """§ 4.1 : les noms admissibles : de l'auteur, d'un porteur présent selon l'auteur, qu'aucune assertion niée
    de la classe ne contredit."""
    return {c for c in noms_portes(g, K, r, auteur_seul=True) if not nom_conteste(g, K, r, c)}


def distinction_documentaire(g, K, r1, r2) -> list:
    """§ 1 et § 4.1 : des noms admissibles des deux classes que K donne pour deux individus
    (K:distincts_documentes(C1, C2, S), lu dans les deux sens : LECTURE), et seulement si aucune des deux classes
    ne porte, à alias près, le nom documenté de l'autre (D26).
    LECTURE : un nom admissible fonde la distinction s'il est la clé documentée elle-même (pas un alias d'elle) ;
    « porter » compte tout nom dans l'état pos, de tout énonciateur, même contesté.
    Rend la liste des (C1, C2, S) qui la fondent."""
    if r1 == r2:
        return []
    a1, a2 = noms_admissibles(g, K, r1), noms_admissibles(g, K, r2)
    porteur = LECTURES["noms_porteur"] == "etat"
    if LECTURES["exclusion_documentaire"] == "polarite":
        p1, p2 = noms_affirmes(g, K, r1), noms_affirmes(g, K, r2)
    else:
        p1, p2 = noms_portes(g, K, r1, False, porteur), noms_portes(g, K, r2, False, porteur)
    if not LECTURES["porte_conteste"]:
        p1 = {c for c in p1 if not nom_conteste(g, K, r1, c)}
        p2 = {c for c in p2 if not nom_conteste(g, K, r2, c)}
    res = []
    for (c1, c2, s) in K.distincts_documentes:
        for d1, d2 in ((c1, c2), (c2, c1)):
            if DOC_PAR_ALIAS:
                fonde = any(K.alias_eq(k, d1) for k in a1) and any(K.alias_eq(k, d2) for k in a2)
            else:
                fonde = d1 in a1 and d2 in a2
            if (fonde and not any(K.alias_eq(k, d2) for k in p1)
                    and not any(K.alias_eq(k, d1) for k in p2)):
                res.append((c1, c2, s))
    return res


DOC_PAR_ALIAS = False   # voir AMBIGUITES, documentaire_alias


def distinction_documentaire_interne(g, K, r) -> list:
    """§ 4.1, `meme` (0.3 amendée) : dans une classe, « deux noms admissibles que K dit deux individus »
    (K:distincts_documentes(C1, C2, S), C1 et C2 tous deux admissibles pour la classe r) donnent (1,1).
    LECTURE : l'exclusion « à alias près » (D26) est propre à deux classes et ne s'applique pas ici (la classe porte
    les deux noms par hypothèse) ; un nom admissible compte s'il est la clé documentée elle-même (DOC_PAR_ALIAS)."""
    a = noms_admissibles(g, K, r)
    res = []
    for (c1, c2, s) in K.distincts_documentes:
        if DOC_PAR_ALIAS:
            fonde = any(K.alias_eq(k, c1) for k in a) and any(K.alias_eq(k, c2) for k in a)
        else:
            fonde = c1 in a and c2 in a
        if fonde:
            res.append((c1, c2, s))
    return res


def distinction_supposee(g, K, r1, r2) -> bool:
    """§ 1 et § 4.1 : les deux classes portent des noms propres, tous différents, sans alias connu ni distinction
    contraire. Elle ne repose que sur des noms d'un porteur présent qu'aucune assertion niée de la classe ne
    contredit (il en faut dans chaque classe), et (0.3 amendée) aucun nom que l'une porte **au sens large** (toute
    assertion de nom positive, quels que soient ses autres qualificatifs et son porteur, contestée ou non :
    noms_affirmes) n'est, à alias près (alias clos), un nom que l'autre porte au sens large.
    LECTURE : les noms du fondement dans l'état pos, de tout énonciateur ; « distinction contraire » n'ajoute rien
    de vérifiable (le graphe ne dit l'identité que par coref, qui ferait une seule classe)."""
    if r1 == r2:
        return False
    porteur = LECTURES["noms_porteur"] == "etat"
    n1 = {c for c in noms_portes(g, K, r1, False, porteur) if not nom_conteste(g, K, r1, c)}
    n2 = {c for c in noms_portes(g, K, r2, False, porteur) if not nom_conteste(g, K, r2, c)}
    if not n1 or not n2:
        return False
    if any(K.alias_eq(a, b) for a in n1 for b in n2):
        return False
    return not any(K.alias_eq(a, b) for a in noms_affirmes(g, K, r1) for b in noms_affirmes(g, K, r2))


def nombres_presents(g, r, auteur_seul=False) -> list:
    """§ 1 et § 4.1 : les nombres des membres **présents** de la classe (nombre/2 vaut ce que vaut son entité)."""
    pred = presente_selon_auteur if auteur_seul else presente
    return [n for e, n in g.nombres if representant(g, e) == r and pred(g, e, FIGURATION)]


def valeur_contrainte(g, K, c, sigma) -> tuple:
    """§ 4.1, table des contraintes (quatre valeurs, D29). Une contrainte dont une variable n'est pas liée vaut
    inconnu.
    - meme(X, Y) : positif si même classe ; négatif si une distinction établie (entre entités présentes selon
      l'auteur) ou documentaire entre les deux classes ; dans la classe, une telle distinction, ou deux noms
      admissibles que K dit deux individus, donnent (1,1) (0.3 amendée) ;
    - distincts(X, Y) : positif si classes différentes et distinction établie, documentaire ou supposée (la
      table met la supposée dans la colonne de l'appui positif : « vraie sous hypothèse » ; elle n'est
      certifiable que comme hypothèse, § 4.3) ; jamais négatif (la même classe : (0,0)) ;
    - nombre(X, K) : positif si un membre présent a le nombre K, négatif si un membre présent a un autre nombre."""
    if not lie(c, sigma):
        return INCONNU
    t = c[0]
    if t == "meme":
        r1, r2 = sigma[c[1]], sigma[c[2]]
        neg = bool(distinction_etablie(g, r1, r2) or distinction_documentaire(g, K, r1, r2)
                   or (r1 == r2 and distinction_documentaire_interne(g, K, r1)))
        return (int(r1 == r2), int(neg))
    if t == "distincts":
        r1, r2 = sigma[c[1]], sigma[c[2]]
        pos = r1 != r2 and bool(distinction_etablie(g, r1, r2) or distinction_documentaire(g, K, r1, r2)
                                or distinction_supposee(g, K, r1, r2))
        return (int(pos), 0)
    if t == "nombre":
        r, k = sigma[c[1]], c[2]
        ns = nombres_presents(g, r)
        return (int(any(n == k for n in ns)), int(any(n != k for n in ns)))
    raise ValueError(c)


def hypotheses_existence_contrainte(g, K, entites) -> set:
    """D30, variante LECTURES['existence_contrainte'] = 'hypothese' (AMBIGUITES, existence_contrainte) : une négation
    seulement possible de l'existence d'une entité d'une distinction établie ou d'un nombre demande l'hypothèse
    negation_autre_sens ; lecture de l'oracle ('ignoree') : seule une négation certaine compte (§ 6, point 7 n'énumère
    d'hypothèses de négation que pour les atomes)."""
    if LECTURES["existence_contrainte"] != "hypothese":
        return set()
    h = set()
    for e in entites:
        h |= hypothese_negation(g, K, *atome_existence(g, e))
    return h


def contrainte_certifiee(g, K, c, sigma) -> Optional[tuple]:
    """§ 4.3 : une contrainte sélectionnée est « vraie et certifiable (ou vraie sous hypothèse) ».
    `nombre` n'est certifiable que si un membre présent selon l'auteur a ce nombre (§ 4.1) ; une distinction établie
    ou un nombre ne le sont que si l'existence de leurs entités n'est pas niée (0.3 amendée, existence_niee).
    LECTURE (AMBIGUITES, distinction_existence_niee) : une distinction établie dont une entité a l'existence niée
    ne certifie pas `distincts`, mais n'empêche pas une distinction documentaire, ni une supposée (hypothèse), si
    elles tiennent par ailleurs.
    Rend None (non certifiable) ou le tuple des hypothèses (vide : vraie) ; la justification qui en demande le
    moins est retenue."""
    v = valeur_contrainte(g, K, c, sigma)
    if v != VRAI:
        return None
    if c[0] == "nombre":
        r, k = sigma[c[1]], c[2]
        cands = [hypotheses_existence_contrainte(g, K, [e]) for e, n in g.nombres
                 if n == k and representant(g, e) == r and presente_selon_auteur(g, e, FIGURATION)
                 and not existence_niee(g, K, e)]
        return tuple(sorted(min(cands, key=len), key=repr)) if cands else None
    if c[0] == "distincts":
        r1, r2 = sigma[c[1]], sigma[c[2]]
        etablies = [(a, b) for a, b in distinction_etablie(g, r1, r2)
                    if not existence_niee(g, K, a) and not existence_niee(g, K, b)]
        if (LECTURES["distinction_niee"] == "etablie_prime" and distinction_etablie(g, r1, r2)
                and not etablies):
            return None
        cands = [hypotheses_existence_contrainte(g, K, [a, b]) for a, b in etablies]
        if distinction_documentaire(g, K, r1, r2):
            cands.append(set())
        if distinction_supposee(g, K, r1, r2):
            cands.append({("distinction_supposee", c[1], c[2])})
        # aucune : vraie par une distinction établie à l'existence niée
        return tuple(sorted(min(cands, key=len), key=repr)) if cands else None
    return ()


# ---------------------------------------------------------------------------------------------------------
# 4.2 La valeur d'une formule
# ---------------------------------------------------------------------------------------------------------

def valeur_formule(g, K, f, sigma) -> tuple:
    """§ 4.2 : p ∧ q = (p⁺ ∧ q⁺, p⁻ ∨ q⁻) ; p ∨ q = (p⁺ ∨ q⁺, p⁻ ∧ q⁻)."""
    if f[0] == "et":
        vs = [valeur_formule(g, K, e, sigma) for e in f[1]]
        return (int(all(p for p, _ in vs)), int(any(n for _, n in vs)))
    if f[0] == "ou":
        vs = [valeur_formule(g, K, e, sigma) for e in f[1]]
        return (int(any(p for p, _ in vs)), int(all(n for _, n in vs)))
    if est_atome(f):
        return valeur_atome(g, K, f, sigma)
    return valeur_contrainte(g, K, f, sigma)


# ---------------------------------------------------------------------------------------------------------
# Domaines et substitutions (§ 4.1, § 4.4)
# ---------------------------------------------------------------------------------------------------------

def domaine(g: Graphe, f, v) -> list:
    """§ 4.1 : une variable se lie à un référent (représentant de classe) ou à un événement, selon sa sorte."""
    sorte = next(iter(sortes(f)[v]))
    return g.ids_evenements() if sorte == "evenement" else referents(g)


NON_LIEE = object()


def substitutions_partielles(g, f, vs=None):
    """§ 4.4 : toutes les substitutions partielles des variables (« une variable : non liée, ou chaque valeur de
    son domaine », § 7). Chacune est un frozenset de paires (variable, valeur)."""
    vs = variables(f) if vs is None else vs
    choix = [[NON_LIEE] + domaine(g, f, v) for v in vs]
    for valeurs in itertools.product(*choix):
        yield frozenset((v, val) for v, val in zip(vs, valeurs) if val is not NON_LIEE)


def ancree(g, K, f, sigma: frozenset) -> bool:
    """§ 4.4 : chaque variable liée est **ancrée** : un atome de la formule qui la contient, entièrement lié, a
    sous σ un appui de l'un ou l'autre signe."""
    s = dict(sigma)
    for v in s:
        if not any(est_atome(x) and v in variables_feuille(x) and a_un_appui(g, K, x, s)
                   for _, x in feuilles(f)):
            return False
    return True


def minimales(substitutions) -> list:
    """§ 4.4 : les substitutions minimales au sens de l'inclusion des liaisons."""
    subs = list(substitutions)
    return [s for s in subs if not any(t < s for t in subs)]


# ---------------------------------------------------------------------------------------------------------
# 4.3 La certification
# ---------------------------------------------------------------------------------------------------------

def solutions_certifiables(g, K, f) -> list:
    """§ 4.3 : une sélection (tous les enfants d'un et, un enfant d'un ou) et la substitution de ses seules
    variables, telle que chaque atome sélectionné est certifiable (vrai, un appui de l'auteur à la prémisse non
    niée) et chaque contrainte sélectionnée vraie et certifiable (ou vraie sous hypothèse).
    Rend une liste de (selection, sigma, hypotheses) ; hypotheses vide : solution vraie."""
    sols = []
    for sel in selections(f):
        vs = sorted({v for _, x in sel for v in variables_feuille(x)})
        domaines = [domaine(g, f, v) for v in vs]
        for valeurs in itertools.product(*domaines):
            sigma = dict(zip(vs, valeurs))
            ok, hyps = True, []
            for _, x in sel:
                if est_atome(x):
                    h = certification_atome(g, K, x, sigma)
                    if h is None:
                        ok = False
                        break
                    hyps.extend(h)
                else:
                    c = contrainte_certifiee(g, K, x, sigma)
                    if c is None:
                        ok = False
                        break
                    hyps.extend(c)
            if ok:
                sols.append((sel, frozenset(sigma.items()), tuple(sorted(set(hyps), key=repr))))
    return sols


# ---------------------------------------------------------------------------------------------------------
# 4.4 Le résultat d'une requête
# ---------------------------------------------------------------------------------------------------------

@dataclass
class Vue:
    """§ 4.4 et § 7 : ce que l'on retient ; le statut en découle."""
    statut: str
    certifiables: list = field(default_factory=list)
    contradictoires: list = field(default_factory=list)
    non_certifiees: list = field(default_factory=list)
    fausses: list = field(default_factory=list)


class MalFormee(ValueError):
    pass


def vue(g: Graphe, K: Connaissances, requete, ancrage: bool = True) -> Vue:
    """§ 4.4 : les substitutions examinées sont les substitutions partielles des variables de la formule dont
    chaque variable liée est ancrée. On retient les solutions certifiables (§ 4.3), et les substitutions
    minimales de valeur contradictoire, fausse, et vraie non certifiable.
    Une substitution vraie est non certifiable si aucune solution certifiable n'est « sous elle »
    (LECTURE : dont la substitution est incluse dans la sienne)."""
    f = requete
    defaut = defaut_de_forme(f)
    if defaut:
        raise MalFormee(defaut)
    sols = solutions_certifiables(g, K, f)
    contra, fausses, vraies_nc = [], [], []
    for sigma in substitutions_partielles(g, f):
        if ancrage and not ancree(g, K, f, sigma):
            continue
        v = valeur_formule(g, K, f, dict(sigma))
        if v == CONTRADICTOIRE:
            contra.append(sigma)
        elif v == FAUX:
            fausses.append(sigma)
        elif v == VRAI and not any(s_sol <= sigma for _, s_sol, _ in sols):
            vraies_nc.append(sigma)
    contra, fausses, vraies_nc = minimales(contra), minimales(fausses), minimales(vraies_nc)
    # La table du § 4.4, dans son ordre.
    if any(not h for _, _, h in sols):
        s = "etablie"
    elif sols:
        s = "etablie_sous_hypotheses"
    elif contra:
        s = "contradictoire"
    elif vraies_nc:
        s = "non_certifiee"
    elif fausses:
        s = "ecartee"
    else:
        s = "inconnue"
    return Vue(s, sols, contra, vraies_nc, fausses)


def statut(graphe: Graphe, K: Connaissances, requete, ancrage: bool = True) -> str:
    """§ 4.4 : le statut d'une requête, sans budget (jamais `incomplet`) ; `mal_formee` si elle ne l'est pas
    (§ 3 : une erreur, jamais un résultat)."""
    try:
        return vue(graphe, K, requete, ancrage).statut
    except MalFormee:
        return "mal_formee"


# ---------------------------------------------------------------------------------------------------------
# 5. Le K de l'oracle, le générateur, l'écriture en Prolog
# ---------------------------------------------------------------------------------------------------------

TETES = ("lion", "felin", "animal", "chien", "chat", "matou", "homme", "saint", "personne", "livre", "objet")
TYPES_DEMANDES = TETES + ("bete", 1, 2, 3, 4, 6)
PROPRIETES = ("couronne", "coiffe", "rouge", "couleur", "agenouille")
PREDICATS = ("tuer", "trancher", "frapper", "agir", "faire", "tenir", "occire")
RELATIONS = ("tient", "touche", "sur", "pres_de", "regarde")
NOMS_PROPRES = ("David", "Goliath", "Saül", "Jérôme", "Hieronymus", "Sophronius")
CLES_DEMANDEES = ("DAVID", "GOLIATH", "SAÜL", "JÉRÔME", "HIERONYMUS", "SOPHRONIUS", "PAUL")


def k_de_test() -> Connaissances:
    """Le K des cas tirés par l'oracle :
    - une hiérarchie avec un cycle (agir ⇄ faire), deux pas de lexicalisation qui ne sont pas des inclusions
      (animal → bete, tuer → occire) ;
    - des identifiants de concept entiers (D27) : 1 entre lion et felin ;
    - des mots polysémiques (D30), dont les sens conceptuels sont des entiers qui se lexicalisent en leur lemme
      (un pas de `sous`, jamais d'`inclus`) : « chat » (3 sous felin, 2 sous objet ; K lui donne aussi le sens
      « chat » lui-même, qui n'est pas conceptuel puisqu'il a des entiers), « couronne » (8 sous coiffe, 9 sans
      parent), « sur » (4 sous pres_de, 5 sous touche), « tenir » (6 sous agir, 7 sans parent) ; « matou » n'a pour
      sens que le concept 3 (le chat félin : un mot monosémique dont le sens n'est pas lui-même) ;
    - un alias non clos (JÉRÔME → HIERONYMUS, SOPHRONIUS → HIERONYMUS : JÉRÔME et SOPHRONIUS ne le sont que par
      fermeture, D33) ;
    - deux paires documentées distinctes, dans un seul sens : (DAVID, GOLIATH), (SAÜL, HIERONYMUS) ; SAÜL et
      JÉRÔME ne sont distincts qu'à alias près."""
    inclus = {("lion", "felin"), ("lion", 1), (1, "felin"), ("felin", "animal"), ("chien", "animal"),
              (3, "felin"), (2, "objet"), (8, "coiffe"), (4, "pres_de"), (5, "touche"), (6, "agir"),
              ("saint", "homme"), ("homme", "personne"), ("livre", "objet"),
              ("rouge", "couleur"), ("trancher", "tuer"), ("tuer", "frapper"), ("frapper", "agir"),
              ("agir", "faire"), ("faire", "agir"), ("tient", "touche")}
    lexicalisations = {(3, "chat"), (2, "chat"), (3, "matou"), (8, "couronne"), (9, "couronne"), (4, "sur"),
                       (5, "sur"), (6, "tenir"), (7, "tenir")}
    sous = inclus | lexicalisations | {("animal", "bete"), ("tuer", "occire")}
    polysemes = {"chat": (3, 2), "couronne": (8, 9), "sur": (4, 5), "tenir": (6, 7), "matou": (3,)}
    mots = (set(t for t in TYPES_DEMANDES if not est_concept(t)) | set(PROPRIETES) | set(PREDICATS)
            | set(RELATIONS)) - {"matou", "couronne", "sur", "tenir"}
    sens = {(m, m) for m in mots} | {(m, c) for m, cs in polysemes.items() for c in cs}
    cles = {(n, n.upper()) for n in NOMS_PROPRES}
    alias = {("JÉRÔME", "HIERONYMUS"), ("SOPHRONIUS", "HIERONYMUS")}
    dd = {("DAVID", "GOLIATH", "bible"), ("SAÜL", "HIERONYMUS", "vita")}
    return Connaissances(frozenset(sens), frozenset(sous), frozenset(inclus), frozenset(cles),
                         frozenset(alias), frozenset(dd), version="oracle_3")


def _qualif_aleatoire(rng: random.Random) -> Qualif:
    return Qualif(
        polarite="pos" if rng.random() < 0.72 else "neg",
        modalite="affirme" if rng.random() < 0.8 else rng.choice(MODALITES[1:]),
        portee="represente" if rng.random() < 0.85 else rng.choice(PORTEES[1:]),
        enonciateur=AUTEUR if rng.random() < 0.8 else cite("z"))


def graphe_aleatoire(rng: random.Random) -> Graphe:
    """Un petit graphe valide : un à quatre entités, au plus deux événements (le second souvent avec les rôles
    du premier, pour la négation d'un événement), des noms (dont des alias et des paires documentées), des
    propriétés, des rôles, des relations, des négations (d'entités nues ou restreintes), des citations, des
    modalités et des portées variées, des coréférences, des distinctions, des nombres, des alternatives."""
    n_ent = rng.randint(1, 4)
    ents = [f"e{i}" for i in range(1, n_ent + 1)]
    entites = tuple((e, rng.choice(TETES)) for e in ents)
    qualifs = {e: _qualif_aleatoire(rng) for e in ents}
    compteur = itertools.count(1)
    noms = []
    for _ in range(rng.choice((0, 1, 2, 2, 3, 3))):
        a = f"a{next(compteur)}"
        e = rng.choice(ents)
        n = rng.choice(NOMS_PROPRES)
        if noms and rng.random() < 0.25:      # un même nom deux fois : appuis de signes opposés
            e, n = rng.choice(noms)[1:]
        noms.append((a, e, n))
        qualifs[a] = _qualif_aleatoire(rng)
    proprietes = []
    for _ in range(rng.choice((0, 0, 1, 1, 2))):
        a = f"a{next(compteur)}"
        proprietes.append((a, rng.choice(ents), rng.choice(PROPRIETES)))
        qualifs[a] = _qualif_aleatoire(rng)
    evenements, roles = [], []
    for i in range(1, rng.choice((0, 1, 1, 2, 2)) + 1):
        v = f"v{i}"
        evenements.append((v, rng.choice(PREDICATS)))
        qualifs[v] = _qualif_aleatoire(rng)
        if i == 2 and rng.random() < 0.5:     # les rôles du premier, vers un membre de la même classe
            for (_, r, e) in [x for x in roles if x[0] == "v1"]:
                if rng.random() < 0.85:
                    roles.append((v, r, e))
            continue
        for _ in range(rng.choice((0, 1, 2, 2))):
            r = (v, rng.choice(("agent", "agent", "patient", "theme", "instrument")), rng.choice(ents))
            if r not in roles:
                roles.append(r)
    relations = []
    for _ in range(rng.choice((0, 0, 1, 1, 2))):
        a = f"a{next(compteur)}"
        relations.append((a, rng.choice(ents), rng.choice(RELATIONS), rng.choice(ents)))
        qualifs[a] = _qualif_aleatoire(rng)
    corefs = []
    if n_ent >= 2:
        for _ in range(rng.choice((0, 0, 1, 1, 2))):
            p = tuple(rng.sample(ents, 2))
            if p not in corefs and p[::-1] not in corefs:
                corefs.append(p)
    distincts = []
    if n_ent >= 2:
        for _ in range(rng.choice((0, 0, 1))):
            # parfois dans une même classe : `meme` coréférents et distincts à la fois (1,1)
            p = tuple(rng.sample(ents, 2))
            if p not in distincts and p not in corefs and p[::-1] not in corefs:
                distincts.append(p)
    nombres = []
    for e in ents:
        if rng.random() < 0.2:
            nombres.append((e, rng.randint(1, 3)))
    ids = list(qualifs)
    alternatives = []
    if rng.random() < 0.12 and len(ids) >= 2:
        alternatives.append(("g1", tuple(rng.sample(ids, 2))))
    g = Graphe(entites=entites, noms=tuple(noms), proprietes=tuple(proprietes),
               evenements=tuple(evenements), roles=tuple(roles), relations=tuple(relations),
               corefs=tuple(corefs), distincts=tuple(distincts), nombres=tuple(nombres),
               qualifs=tuple(sorted(qualifs.items())), alternatives=tuple(alternatives))
    assert not valider(g), valider(g)
    return g


def _atome_aleatoire(rng: random.Random, g: Graphe):
    """Un atome ou une contrainte, souvent tiré du graphe pour que les requêtes aient des appuis."""
    def mot(choix_graphe, choix_tous):
        return rng.choice(choix_graphe) if choix_graphe and rng.random() < 0.6 else rng.choice(choix_tous)
    x = rng.choice(("x", "x", "y"))
    y = "y" if x == "x" else "x"
    k = rng.random()
    if k < 0.22:
        return ("type", x, mot([t for _, t in g.entites], TYPES_DEMANDES))
    if k < 0.36:
        cles = rng.sample(CLES_DEMANDEES, rng.choice((1, 1, 2)))
        if g.noms and rng.random() < 0.5:
            cles = [rng.choice(g.noms)[2].upper()] + (cles[:1] if rng.random() < 0.3 else [])
        return ("nom", x, cles)
    if k < 0.46:
        return ("propriete", x, mot([p for _, _, p in g.proprietes], PROPRIETES))
    if k < 0.56:
        return ("evenement", "e", mot([p for _, p in g.evenements], PREDICATS))
    if k < 0.66:
        return ("role", "e", mot([r for _, r, _ in g.roles], ("agent", "patient", "theme")), x)
    if k < 0.76:
        return ("relation", x, mot([r for _, _, r, _ in g.relations], RELATIONS), y)
    if k < 0.84:
        return ("meme", "x", "y")
    if k < 0.94:
        return ("distincts", "x", "y")
    return ("nombre", x, rng.randint(1, 3))


def _formule_aleatoire(rng, g, profondeur):
    if profondeur == 0 or rng.random() < 0.3:
        return _atome_aleatoire(rng, g)
    op = rng.choice(("et", "et", "ou"))
    n = rng.randint(2, 3) if op == "ou" else rng.randint(1, 3)
    return (op, [_formule_aleatoire(rng, g, profondeur - 1) for _ in range(n)])


def requete_aleatoire(rng: random.Random, g: Graphe):
    """Une requête bien formée (§ 3), de profondeur au plus deux, aux variables x, y (référents) et e
    (événement). On tire jusqu'à en obtenir une bien formée. Une fois sur cinq, le gabarit de deux référents
    nommés et de leur distinction (ou de leur identité). Une fois sur trente, une requête mal formée (§ 3 :
    contrainte sur une variable d'événement, distincts(X, X)), qui doit donner une erreur."""
    if rng.random() < 0.033:
        return rng.choice((
            ("et", [("evenement", "e", rng.choice(PREDICATS)), ("meme", "e", "e")]),
            ("et", [("role", "e", "agent", "x"), (rng.choice(("meme", "distincts")), "e", "x")]),
            ("et", [("evenement", "e", rng.choice(PREDICATS)), ("nombre", "e", 1)]),
            ("et", [("type", "x", rng.choice(TETES)), ("distincts", "x", "x")])))
    if rng.random() < 0.2:
        k1, k2 = rng.choice(CLES_DEMANDEES), rng.choice(CLES_DEMANDEES)
        if len(g.noms) >= 2 and rng.random() < 0.8:
            n1, n2 = rng.sample(g.noms, 2)
            k1, k2 = n1[2].upper(), n2[2].upper()
        elif g.noms and rng.random() < 0.7:
            k1 = rng.choice(g.noms)[2].upper()
        corps = [("nom", "x", [k1]), ("nom", "y", [k2]), (rng.choice(("distincts", "distincts", "meme")), "x", "y")]
        if rng.random() < 0.4:
            corps.insert(0, ("type", "x", rng.choice(TYPES_DEMANDES)))
        return ("et", corps)
    while True:
        f = _formule_aleatoire(rng, g, rng.choice((1, 2, 2)))
        if bien_formee(f):
            return f


def cas_aleatoires(graine: int, n: int, jeu: str = "oracle"):
    """n cas (graphe, requête), à graine fixe ; jeu 'oracle' (K et générateur de ce module) ou 'gen' (K et
    générateur des tests génératifs, § 6)."""
    rng = random.Random(graine)
    for _ in range(n):
        if jeu == "gen":
            g = graphe_gen(rng)
            yield g, requete_gen(rng)
        else:
            g = graphe_aleatoire(rng)
            yield g, requete_aleatoire(rng, g)


# --- Écriture en Prolog -----------------------------------------------------------------------------------

def pl_atome(s) -> str:
    if re.fullmatch(r"[a-z][A-Za-z0-9_]*", s):
        return s
    return "'" + s.replace("\\", "\\\\").replace("'", "\\'") + "'"


def pl_terme(t) -> str:
    if isinstance(t, bool):
        raise TypeError(t)
    if isinstance(t, int):
        return str(t)
    if isinstance(t, str):
        return pl_atome(t)
    if isinstance(t, tuple) and t and t[0] == "cite":
        return f"cite({pl_atome(t[1])})"
    raise TypeError(t)


def pl_graphe(g: Graphe) -> str:
    """Le graphe comme liste de termes Prolog, avec les qualificatifs complets, un texte("x"), un
    doc(fr, inconnu) et un passage (ASSERTIONS.md)."""
    T = pl_terme
    termes = ['texte("x")', "doc(fr, inconnu)", "passage(p, 0, 1)"]
    termes += [f"entite({T(e)}, {T(t)}, p)" for e, t in g.entites]
    termes += [f"nom({T(a)}, {T(e)}, {T(n)}, p)" for a, e, n in g.noms]
    termes += [f"propriete({T(a)}, {T(e)}, {T(p)}, p)" for a, e, p in g.proprietes]
    termes += [f"evenement({T(v)}, {T(p)}, p)" for v, p in g.evenements]
    termes += [f"role({T(v)}, {T(r)}, {T(e)})" for v, r, e in g.roles]
    termes += [f"relation({T(a)}, {T(e1)}, {T(r)}, {T(e2)}, p)" for a, e1, r, e2 in g.relations]
    termes += [f"coref({T(a)}, {T(b)})" for a, b in g.corefs]
    termes += [f"distinct({T(a)}, {T(b)})" for a, b in g.distincts]
    termes += [f"nombre({T(e)}, {n})" for e, n in g.nombres]
    for i, q in g.qualifs:
        termes += [f"polarite({T(i)}, {q.polarite})", f"modalite({T(i)}, {q.modalite})",
                   f"portee({T(i)}, {q.portee})", f"enonciateur({T(i)}, {T(q.enonciateur)})"]
    termes += [f"alternative({T(gid)}, [{', '.join(T(m) for m in ms)}])" for gid, ms in g.alternatives]
    return "[" + ", ".join(termes) + "]"


def pl_formule(f) -> str:
    """La formule au format du § 3 : variables v(Nom)."""
    V = lambda v: f"v({pl_atome(v)})"
    T = pl_terme
    t = f[0]
    if t in ("et", "ou"):
        return f"{t}([{', '.join(pl_formule(e) for e in f[1])}])"
    if t in ("type", "propriete", "evenement"):
        return f"{t}({V(f[1])}, {T(f[2])})"
    if t == "nom":
        return f"nom({V(f[1])}, [{', '.join(T(c) for c in f[2])}])"
    if t == "role":
        return f"role({V(f[1])}, {T(f[2])}, {V(f[3])})"
    if t == "relation":
        return f"relation({V(f[1])}, {T(f[2])}, {V(f[3])})"
    if t == "genre":
        return f"genre({T(f[1])})"
    if t in ("meme", "distincts"):
        return f"{t}({V(f[1])}, {V(f[2])})"
    if t == "nombre":
        return f"nombre({V(f[1])}, {f[2]})"
    raise ValueError(f)


def pl_connaissances(K: Connaissances) -> str:
    """Le module K de l'oracle, en faits Prolog : module k_oracle, sept primitives exportées."""
    T = pl_terme
    cle = lambda p: (str(type(p[0])), str(p[0]), str(type(p[1])), str(p[1]))
    lignes = [":- encoding(utf8).",
              f":- module({K.module}, [sens/3, sous/2, inclus/2, cle_de_nom/2, alias/2,",
              "                     distincts_documentes/3, version/1]).", ""]
    lignes += [f"sens({c}, {T(m)}, {T(t)})." for m, t in sorted(K.sens_paires, key=cle) for c in CATEGORIES]
    lignes += [f"sous({T(a)}, {T(b)})." for a, b in sorted(K.sous, key=cle)]
    lignes += [f"inclus({T(a)}, {T(b)})." for a, b in sorted(K.inclus, key=cle)]
    lignes += [f"cle_de_nom({T(n)}, {T(c)})." for n, c in sorted(K.cles)]
    lignes += [f"alias({T(a)}, {T(b)})." for a, b in sorted(K.alias)]
    lignes += [f"distincts_documentes({T(a)}, {T(b)}, {T(s)})." for a, b, s in sorted(K.distincts_documentes)]
    lignes += [f"version({T(K.version)})."]
    return "\n".join(lignes) + "\n"


# ---------------------------------------------------------------------------------------------------------
# 6. Le K et le générateur des tests génératifs (tests/plunit/connaissances_gen.pl, test_noyau_generatif.pl),
#    reproduits en Python (les données seulement ; la sémantique reste celle des § 1 à 4 ci-dessus)
# ---------------------------------------------------------------------------------------------------------

TETES_GEN = ("a", "a1", "a2", "b", "b1", "top", "c1", "lemme_a", "poly", "nom_propre")
NOMS_GEN = ("x", "xa", "y", "z")


class _ToutAtome(dict):
    """sens(_, W, W) :- atom(W) : tout atome est son propre sens (pas un entier) ; sens(_, poly, 801),
    sens(_, poly, 802) : un mot polysémique (D30)."""
    def get(self, mot, defaut=None):
        if not isinstance(mot, str):
            return set()
        return {mot, 801, 802} if mot == "poly" else {mot}


def k_gen(fichier: str) -> Connaissances:
    """connaissances_gen.pl : sens(_, W, W) pour tout atome, et poly polysémique (801, 802) ; sous (un cycle
    c1 ⇄ c2, un pas de lexicalisation lemme_a → a ; 801 → a1, 802 → b1, et leur lexicalisation 801, 802 → poly) ;
    inclus = sous sauf depuis lemme_a et vers poly ; cle_de_nom = upcase_atom ; distincts_documentes('X', 'Z', gen) ;
    alias('XA', 'X')."""
    sous = {("a1", "a"), ("a2", "a"), ("a", "top"), ("b1", "b"), ("b", "top"), ("p1", "p"), ("q", "p0"),
            ("p", "p0"), ("r1", "r"), ("s1", "s"), ("c1", "c2"), ("c2", "c1"), ("lemme_a", "a"),
            (801, "a1"), (802, "b1"), (801, "poly"), (802, "poly")}
    inclus = {(a, b) for a, b in sous if a != "lemme_a" and b != "poly"}
    noms = set(NOMS_GEN) | {"X", "XA", "Y", "Z"}
    K = Connaissances(frozenset(), frozenset(sous), frozenset(inclus),
                      frozenset((n, n.upper()) for n in noms), frozenset({("XA", "X")}),
                      frozenset({("X", "Z", "gen")}), version="gen 1", module="connaissances_gen",
                      fichier=fichier)
    K.__dict__["_sens"] = _ToutAtome()
    return K


def graphe_gen(rng: random.Random) -> Graphe:
    """graphe_aleatoire/1 de tests/plunit/generateur_noyau.pl (mêmes lois, autre générateur pseudo-aléatoire)."""
    p = lambda x: rng.random() < x
    ents = [f"e{i}" for i in range(1, rng.randint(1, 5) + 1)]
    entites = tuple((e, rng.choice(TETES_GEN)) for e in ents)
    noms1 = [(f"n_{e}", e, rng.choice(NOMS_GEN)) for e in ents if p(0.5)]
    noms2 = [(f"m_{e}", e, n0 if p(0.6) else rng.choice(("x", "y"))) for (_, e, n0) in noms1 if p(0.4)]
    props = [(f"q_{e}", e, rng.choice(("r", "r1"))) for e in ents if p(0.3)]
    evs = [(f"v{j}", rng.choice(("p", "p1", "q"))) for j in range(1, rng.randint(0, 2) + 1)]
    roles = [(v, r, rng.choice(ents)) for v, _ in evs for r in ("agent", "patient", "theme") if p(0.6)]
    rels = []
    for e1 in ents:
        if p(0.3):
            rels.append((f"r_{e1}", e1, rng.choice(("s", "s1")), rng.choice(ents)))
    cor = [(a, b) for a in ents for b in ents if a < b and p(0.15)]
    dis = [(a, b) for a in ents for b in ents if a < b and (a, b) not in cor and p(0.15)]
    nbs = [(e, rng.randint(1, 3)) for e in ents if p(0.2)]
    ids = sorted([e for e in ents] + [a for a, _, _ in noms1 + noms2] + [a for a, _, _ in props]
                 + [v for v, _ in evs] + [a for a, _, _, _ in rels])
    qualifs = {}
    for a in ids:
        x = rng.random()
        qualifs[a] = Qualif(polarite="neg" if p(0.2) else "pos", modalite="possible" if p(0.1) else "affirme",
                            portee="represente" if x < 0.8 else ("oeuvre" if x < 0.93 else "histoire"),
                            enonciateur=cite("z") if p(0.1) else AUTEUR)
    alts = (("g1", (ids[0], ids[1])),) if len(ids) >= 2 and p(0.1) else ()
    g = Graphe(entites=entites, noms=tuple(noms1 + noms2), proprietes=tuple(props), evenements=tuple(evs),
               roles=tuple(roles), relations=tuple(rels), corefs=tuple(cor), distincts=tuple(dis),
               nombres=tuple(nbs), qualifs=tuple(sorted(qualifs.items())), alternatives=alts)
    assert not valider(g), valider(g)
    return g


def requete_gen(rng: random.Random):
    """requete_aleatoire/1 de tests/plunit/generateur_noyau.pl."""
    if rng.random() < 0.3:
        k1 = rng.choice((["X"], ["XA"]))
        k2 = rng.choice((["Y"], ["Z"]))
        c = rng.choice((("distincts", "x", "y"), ("meme", "x", "y")))
        return ("et", [("nom", "x", k1), ("nom", "y", k2), c])
    ref = lambda: rng.choice(("x", "y", "z"))

    def atome():
        i = rng.randint(1, 7)
        if i == 1:
            return ("type", ref(), rng.choice(("a", "a1", "b", "top", "c2", "lemme_a", "poly", "b1")))
        if i == 2:
            return ("nom", ref(), rng.choice((["X"], ["Y"], ["Z"], ["X", "Y"])))
        if i == 3:
            return ("propriete", ref(), rng.choice(("r", "r1")))
        if i == 4:
            return ("evenement", "e", rng.choice(("p", "p0", "q")))
        if i == 5:
            return ("role", "e", rng.choice(("agent", "patient", "theme")), ref())
        if i == 6:
            return ("relation", ref(), rng.choice(("s", "s1")), ref())
        return ("genre", rng.choice(("a", "top")))

    def contrainte():
        x, y, i = ref(), ref(), rng.randint(1, 3)
        return ("meme", x, y) if i == 1 else ("distincts", x, y) if i == 2 else ("nombre", x, rng.randint(1, 3))

    def formule(pr):
        x = rng.random()
        if pr > 0 and x < 0.25:
            return ("ou", [formule(pr - 1) for _ in range(rng.randint(2, 3))])
        if pr > 0 and x < 0.55:
            return ("et", [formule(pr - 1) for _ in range(rng.randint(1, 3))])
        if x < 0.8:
            return atome()
        return contrainte()

    for _ in range(500):
        f = formule(rng.randint(1, 3))
        if bien_formee(f):
            return f
    return ("genre", "a")


# ---------------------------------------------------------------------------------------------------------
# Les ambiguïtés relevées dans docs/NOYAU.md (0.3), et la lecture choisie
# ---------------------------------------------------------------------------------------------------------

AMBIGUITES = [
    # (clé, texte) ; « Moteurs : » dit la lecture qu'ont les deux moteurs (banc différentiel du 26/11), quand elle
    # diffère ; LECTURES donne la variante pour la mesurer.
    ("classe", "§ 1 : « Un nom, un type, une propriété d'un membre valent pour la classe » ne cite ni les "
     "relations ni les rôles. Lecture : eux aussi valent pour la classe (les variables désignent des référents)."),
    ("enonciateur_multiple", "§ 1 : Q est « l'énonciateur de celle qui ne l'est pas » : si les deux entités d'une "
     "relation ne sont pas de l'auteur, laquelle ? Lecture : la première ; sans effet sur le statut (seul compte "
     "Q ≠ auteur)."),
    ("evenement_parle", "§ 1 et § 1.1 : l'assertion d'un événement parle-t-elle des participants de ses rôles ? "
     "Lecture : non pour l'appui positif de evenement(E, P) (les participants sont dans les rôles) ; oui pour un "
     "événement nié : la description niée comprend ses rôles (« evenement(N, W) et ses rôles »), et § 1 demande, pour "
     "neg(Q), « chaque entité dont elle parle, autre qu'elle-même, présente », le participant d'un rôle étant de "
     "celles-là. Moteurs : les participants de l'événement nié ne sont pas vérifiés "
     "(LECTURES['evenement_participants'] = False)."),
    ("evenement_role_de_V", "§ 1.1 : « un autre événement V présent qui a, pour chaque rôle de N, le même rôle vers "
     "un membre de la même classe » : le rôle de V doit-il être un appui positif (participant présent) ? Lecture : "
     "une assertion role/3 de V suffit ; V, lui, est présent (positif, affirmé, portée C, hors alternative ; de tout "
     "énonciateur). Moteurs : de même."),
    ("entite_nue", "§ 1.1 : « rien d'autre n'en est dit » : une assertion hypothétique, citée ou hors portée qui "
     "cite l'entité compte-t-elle ? Lecture : toute assertion nom/propriete/relation/role/nombre/distinct qui la "
     "cite compte, quels que soient ses qualificatifs ; coref ne compte pas. Moteurs : de même."),
    ("entite_nue_classe", "§ 1.1 : une entité niée nue dans une classe de plusieurs membres dont aucun n'est "
     "présent : aucune des deux lignes ne s'applique (le texte est explicite : « dans une classe qui a un membre "
     "présent »). Lecture : aucun appui négatif. Moteurs : appui négatif pour cette classe "
     "(LECTURES['classe_presente'] = False) : un écart au texte, pas une ambiguïté."),
    ("genre_nu", "§ 1.1 (tranché par l'amendement du cycle 7) : seule une entité **nue** de portée oeuvre nie "
     "genre(T) (« pas un portrait mort » ne nie pas le genre). Lecture : nue au sens de la ligne 4 de la table "
     "(entite_nue) ; GENRE_NU = True. Moteurs : de même."),
    ("distinct_present", "§ 4.1 (amendé) le dit pour `meme` : une distinction établie ne compte qu'« entre entités "
     "présentes selon l'auteur ». Lecture : de même pour `distincts`, pour la valeur comme pour la certification "
     "(DISTINCT_SELON_AUTEUR = True). Moteurs : de même."),
    ("documentaire_sens", "§ 2 : distincts_documentes(C1, C2, S) est-il symétrique ? Lecture : oui, lu dans les deux "
     "sens (deux individus différents). Moteurs : de même."),
    ("documentaire_alias", "§ 4.1 : un nom admissible fonde-t-il la distinction documentaire s'il n'est qu'un alias "
     "de la clé documentée ? Lecture : non, la clé elle-même (DOC_PAR_ALIAS = False) ; l'alias ne sert qu'à "
     "l'exclusion « à alias près ». Moteurs : de même."),
    ("documentaire_porte", "§ 4.1 : « aucune des deux classes ne porte, à alias près, le nom documenté de "
     "l'autre » : quels noms sont portés ? Lecture : tout nom dans l'état pos (porteur présent), de tout "
     "énonciateur, même contesté par une assertion niée de la classe. Moteurs : un nom contesté n'est pas porté "
     "(LECTURES['porte_conteste'] = False), et un nom dont le porteur n'est pas présent l'est "
     "(LECTURES['noms_porteur'] = 'qualifie')."),
    ("noms_porteur", "§ 1 et § 4.1 : les noms « portés » par une classe (distinction supposée, exclusion de la "
     "documentaire) demandent-ils leur porteur présent ? Lecture : oui : § 1 ne donne d'état pos à un nom que si "
     "l'entité citée est présente, et une assertion sans état « n'appuie rien, dans un sens ni dans l'autre ». "
     "Moteurs : seuls les qualificatifs du nom comptent (LECTURES['noms_porteur'] = 'qualifie') ; c'est prudent pour "
     "l'exclusion (« tous différents »), mais pas pour le fondement : un nom porté par une entité seulement possible, "
     "ou niée, fonde une distinction supposée (etablie_sous_hypotheses où le texte donne inconnue)."),
    ("supposee_noms", "§ 1 et § 4.1 (amendé) : les noms qui fondent une distinction supposée : de tout énonciateur ? "
     "Lecture : oui (état pos, porteur présent, tout énonciateur), un nom contredit ne fonde rien ; l'exclusion « aucun "
     "nom que l'une porte n'est, à alias près, un nom que porte l'autre » compte les noms au sens large (toute "
     "assertion de nom positive, quels que soient ses qualificatifs et son porteur, contestée ou non : noms_affirmes). "
     "Moteurs : de même."),
    ("conteste_porteur", "§ 4.1 : « qu'aucune assertion niée de la classe ne contredit » (noms admissibles, noms de la "
     "supposée) : l'assertion de nom niée doit-elle avoir l'état neg (§ 1 : son porteur présent) ? Tranché par la "
     "décision D50 du 27/11 (§ 4.1 : « de porteur présent ») : oui, la lecture de l'oracle "
     "(LECTURES['conteste'] = 'etat', par défaut). Moteurs : de même depuis D50 (banc ciblé : un nom nié d'un porteur "
     "seulement possible, nié ou d'une autre portée ne conteste ni la documentaire, ni la supposée, ni le (1,1) de "
     "`meme` ; la variante 'qualifie' y donne trois désaccords)."),
    ("premisse_existence", "§ 4.3 (amendé) : l'existence d'une entité citée par un appui : type(X, W) sous σ(X) sa "
     "classe, W son mot, sans appui négatif (§ 1.1, contexte de la figuration). Entités citées : l'entité d'un type, "
     "le porteur d'un nom ou d'une propriété, les deux entités d'une relation, le participant d'un rôle ; l'assertion "
     "d'un événement n'en cite aucune (evenement_parle). Moteurs : de même."),
    ("premisse_evenement", "§ 4.3 (amendé) : l'événement d'un rôle est nié si evenement(E, P) sous σ(E) = cet "
     "événement, P son propre prédicat, a un appui négatif (§ 1.1 : un autre événement nié qui a les mêmes rôles). "
     "Moteurs : de même."),
    ("premisse_genre", "§ 4.3 (amendé) : l'appui d'un genre est une entité de portée oeuvre ; son existence est-elle "
     "lue aussi comme type(X, W) dans le contexte de la figuration (« pas de chien » figuré ôte-t-il sa prémisse au "
     "genre chien) ? Lecture : non, le contexte est celui de la condition (§ 1 : oeuvre), où l'existence est la "
     "prémisse reformée genre(W) (LECTURES['existence_genre'] = 'oeuvre'). Moteurs : ils divergent entre eux : le "
     "moteur de référence lit 'oeuvre', le moteur optimisé 'figuration' (genre(chien) : etablie contre "
     "non_certifiee) ; un défaut d'un des deux moteurs quelle que soit la lecture retenue."),
    ("distinction_existence_niee", "§ 4.3 (amendé) : « une distinction établie [...] n'[est] certifiable que si "
     "l'existence de [ses] entités n'est pas niée » : une telle distinction empêche-t-elle de certifier `distincts` "
     "par une distinction documentaire, ou de le supposer ? Lecture : non, ce sont des appuis indépendants (§ 4.1 : "
     "« distinction établie ou documentaire » ; LECTURES['distinction_niee'] = 'independante'). Moteurs (les deux) : "
     "dès qu'une distinction établie existe entre les classes, seules les établies certifient ('etablie_prime') : "
     "ajouter distinct(e1, e2) fait passer etablie à non_certifiee (non monotone) ; un défaut des moteurs d'après le "
     "texte."),
    ("meme_interne", "§ 4.1 (amendé) : dans une classe, « deux noms admissibles que K dit deux individus » donnent "
     "(1,1). Lecture : les deux clés documentées elles-mêmes (pas un alias, comme documentaire_alias), toutes deux "
     "admissibles pour la classe ; l'exclusion « à alias près » (D26), propre à deux classes, ne s'applique pas. "
     "Moteurs : de même."),
    ("supposee_valeur", "§ 4.1 : la distinction supposée est-elle un appui positif de distincts(X, Y) (valeur "
     "(1,0)) ou seulement une hypothèse de certification ? La table la met dans la colonne de l'appui positif "
     "(« supposée : vraie sous hypothèse ») : elle donne la valeur (1,0), et n'est certifiable que comme hypothèse "
     "(§ 4.3) ; une substitution vraie par elle seule, dont un atome n'est dit que par une source citée, est donc "
     "non certifiable. (Première lecture de l'oracle 0.3 : hypothèse seulement, valeur (0,0) ; corrigée d'après la "
     "table.) Moteurs : de même."),
    ("distinction_contraire", "§ 1 : « sans alias connu ni distinction contraire » : rien d'autre à vérifier "
     "qu'alias (le graphe ne dit l'identité que par coref)."),
    ("nombre_double", "§ 4.1 : un membre présent au nombre K et un autre à un autre nombre : (1,1)."),
    ("distincts_meme_classe", "§ 4.1 : distincts(X, Y) sur la même classe vaut (0,0) ; la substitution reste "
     "examinée, elle n'est jamais une solution."),
    ("sous_elle", "§ 4.3 : « aucune solution certifiable sous elle » : dont la substitution est incluse dans la "
     "sienne."),
    ("ancrage", "§ 4.4 : l'atome qui ancre une variable doit avoir toutes ses variables liées ; une contrainte "
     "n'ancre rien."),
    ("premisse_role", "§ 4.3 : la prémisse reformée d'un rôle est le rôle lui-même, jamais nié (§ 1.1) ; ses autres "
     "prémisses (amendement du cycle 7) sont l'existence de son participant et son événement (premisse_existence, "
     "premisse_evenement)."),
    ("sens_categorie", "§ 2 : la catégorie employée par chaque atome n'est pas dite ; les K de test donnent le "
     "même sens pour les quatre catégories, la question ne se pose pas."),
    ("genre_tete", "§ 3 : genre(T) est lu sur les entités de portée oeuvre (§ 1.1, dernière ligne, et § 1 : "
     "contexte oeuvre pour le classement), avec un lien positif de leur tête vers T."),
    ("polysemie_appui", "§ 2 (D30) : une négation seulement possible « ne réfute rien et ne contredit rien » : est-elle "
     "un appui négatif pour l'ancrage (§ 4.4 : « un appui de l'un ou l'autre signe ») ? Lecture : non, elle n'est un "
     "appui d'aucun signe (ni valeur négative, ni ancrage) ; elle ne fonde qu'une hypothèse sur ce qu'elle touche. "
     "Moteurs : le moteur optimisé de même ; le moteur de référence ancre une variable sur une négation seulement "
     "possible (et(nombre(x, 3), propriete(x, couronne)), le seul membre au nombre 2, « pas de couronne » polysémique : "
     "ecartee contre inconnue) : les deux moteurs divergent, un défaut de la référence d'après le texte."),
    ("polysemie_meme_mot", "§ 2 (D30) : « chaque nœud du type demandé [...] inclus dans chaque sens conceptuel du mot "
     "nié » : type(X, poly) contre « pas de poly » (poly aux sens 801, 802) n'est qu'une négation possible (801 n'est "
     "pas inclus dans 802). Lecture : littérale (chaque couple). Moteurs : de même."),
    ("polysemie_lemme", "§ 2 : le lien positif finit au type demandé lui-même (Tn), quand ses nœuds (lien négatif) sont "
     "ses sens conceptuels : un mot dont le seul sens est un entier n'atteint son propre lemme que si K a le pas de "
     "lexicalisation (le K de l'oracle donne sous(3, matou)). Moteurs : de même."),
    ("existence_contrainte", "§ 2 et § 4.3 (D30) : une négation seulement possible de l'existence d'une entité d'une "
     "distinction établie ou d'un nombre demande-t-elle negation_autre_sens ? § 2 dit « une conclusion positive "
     "qu'elle touche » ; § 6, point 7 n'énumère ces hypothèses que pour les atomes (l'atome, l'assertion citée, "
     "l'existence d'une entité citée, l'événement d'un rôle). Lecture : non (LECTURES['existence_contrainte'] = "
     "'ignoree') ; variante 'hypothese'. Moteurs : 'ignoree'. Moins prudent que le § 2 pris à la lettre "
     "(distinct(e1, e2), e1 « matou » coréférent d'un lion, « pas de chat » : etablie, et non sous hypothèse) ; "
     "à préciser dans le texte."),
    ("hypotheses_termes", "§ 5 (D30) : les termes des hypothèses : sens_suppose(Mot, Type) (le mot de l'appui, le type "
     "de l'atome) ; negation_autre_sens(A), A l'atome instancié par σ (référents par représentant, événements par "
     "identifiant) : l'atome lui-même, l'assertion citée reformée avec son mot, type(R, W) pour l'existence d'une entité "
     "de mot W et de classe R, evenement(V, P) pour l'événement V de prédicat P d'un rôle. Seul le statut est "
     "comparé : qu'une solution ait ou non une hypothèse ne dépend pas du choix entre appuis à égalité."),
    ("refutations_d31", "§ 4.4 (D31) : les éléments de `ecartee` (refutation(Sigma, substitution, Fondements)) ne sont "
     "pas calculés par l'oracle ; le banc ne compare que les statuts."),
    ("forme_reference", "§ 3 et § 7 : le moteur de référence (statut_reference/4) ne contrôle pas la forme de la "
     "requête (il rend un statut pour distincts(X, X) ou une contrainte sur un événement) ; satisfaire/4 rend une "
     "erreur. Le banc ne compare que satisfaire/4 sur ces cas."),
]
