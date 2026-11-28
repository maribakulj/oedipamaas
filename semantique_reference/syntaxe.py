"""La syntaxe abstraite du langage de référence (docs/LANGAGE_REFERENCE.md, § 1).

Chaque classe porte, dans sa docstring, la production de la grammaire qu'elle réalise (« G n »). Rien ici ne calcule :
la bonne formation est dans formation.py, la sémantique dans interprete.py, la syntaxe concrète dans json_concret.py.

Ce module n'importe rien du projet (ni oedipamaas/, ni tests/oracle/) : il est écrit d'après la spécification seule.
"""
from __future__ import annotations

from dataclasses import dataclass, field
from typing import Optional

# --------------------------------------------------------------------------------------------------------------
# § 1.1 Les sortes (G 1)
# --------------------------------------------------------------------------------------------------------------

SORTES_EVENTUALITE = ("etat", "processus", "changement")
SORTES_REFERENT = ("individu", "collection", "concept", "situation") + SORTES_EVENTUALITE
SORTES_VARIABLE = SORTES_REFERENT + ("contexte",)

# § 1.3 Les sortes de contextes (G 4). Les figuratifs sont ceux où une définition peut être satisfaite.
SORTES_CONTEXTE_FIGURATIVES = ("figuration", "emboite", "vision", "reve", "etat_d_origine")
SORTES_CONTEXTE_NON_FIGURATIVES = ("oeuvre", "histoire", "source", "titre", "inscription", "deontique", "parole")
SORTES_CONTEXTE = SORTES_CONTEXTE_FIGURATIVES + SORTES_CONTEXTE_NON_FIGURATIVES
# Les contextes ouverts par une éventualité (« voit en rêve », « le contrat stipule ») :
SORTES_CONTEXTE_OUVERTES = ("vision", "reve", "deontique", "parole", "inscription")

RACINE = "principal"

# § 1.6 Les qualifications (G 9)
POLARITES = ("pos", "neg")
MODALITES = ("affirme", "possible", "supposee")
ANCRAGES = ("en_cours", "anterieure", "imminente", "hors_temps")

# § 1.11 Les natures d'hypothèses (définition 4 de docs/INTERPRETATIONS_ADMISSIBLES.md, et une extension signalée :
# `connaissance_non_attestee`, que le § 2.1 de cette étude nomme sans la mettre dans la définition 4).
NATURES = ("lecture", "identite", "abduction", "connaissance_typique", "identification_iconographique",
           "convention", "connaissance_non_attestee")
NATURES_NON_LEXICALES = tuple(n for n in NATURES if n != "lecture")

# § 1.5 Les dimensions des points (§ 3.1 de l'étude)
DIMENSIONS = ("sens", "sens_relation", "structure", "coreference", "portee", "pluriel", "cadre_de_reference",
              "ancrage", "contexte", "identite", "forme_du_libelle")

COTES = ("D", "Δ")


# --------------------------------------------------------------------------------------------------------------
# § 1.4 Les types (G 5)
#   T ::= Concept(c) | ⊥ | Alternatifs(p) | Union(T, …, T) | Conjonction(T, …, T)
# --------------------------------------------------------------------------------------------------------------

@dataclass(frozen=True)
class Concept:
    """G 5a. Un concept (un sens de WordNet `wn30:…`, ou un concept propre `oc:…`). Jamais un lemme."""
    id: str


@dataclass(frozen=True)
class Inconnu:
    """G 5b. ⊥ : le sens voulu manque à l'inventaire de K. Sous ⊥, aucun lien, aucune négation (étude § 3.2)."""


INCONNU = Inconnu()


@dataclass(frozen=True)
class Alternatifs:
    """G 5c. Un ensemble de concepts ALTERNATIFS : un point d'ambiguïté p, dont le domaine V(p) est l'ensemble.
    Une interprétation i en choisit UNE valeur ; sous i, le type est le concept i(p) (ou ⊥)."""
    point: str


@dataclass(frozen=True)
class Union:
    """G 5d. Une UNION de concepts : un type disjonctif, DANS une même interprétation. « x : A ∪ B » dit que x est un
    A ou un B, sans dire lequel ; ce n'est pas un point, et aucune interprétation ne le tranche."""
    membres: tuple


@dataclass(frozen=True)
class Conjonction:
    """G 5e. Une CONJONCTION de types : l'intersection. « x : A ∩ B » dit que x est un A et un B."""
    membres: tuple


TypeExpr = object  # Concept | Inconnu | Alternatifs | Union | Conjonction


# --------------------------------------------------------------------------------------------------------------
# § 1.6 Les termes et les atomes (G 7, G 8)
# --------------------------------------------------------------------------------------------------------------

@dataclass(frozen=True)
class Var:
    """G 7. Une variable (d'une requête, d'une règle de K, d'une proposition niée ou d'une quantification).
    Dans une description, les arguments sont des identifiants de référents (des chaînes)."""
    nom: str


# Les prédicats : nom -> (nombre d'arguments, typé ?, champ `valeur` attendu ?)
PREDICATS = {
    "type": (1, True, False),          # type(x, T)
    "propriete": (1, True, False),     # propriete(x, T) : une propriété ordinaire, non réifiée
    "role": (2, False, True),          # role(e, x) de rôle r (agent, theme, patient, destinataire, porteur, …)
    "relation": (2, True, False),      # relation(x, y) de type R (un type de relation)
    "nom": (1, False, True),           # nom(x) de clé k
    "ancrage": (1, False, True),       # ancrage(e) = a, relatif au moment de la situation de e
    "dans": (2, False, False),         # dans(x, s) : la situation de x (structurel, déclaré sur le référent)
    "succede": (2, False, False),      # succede(s1, s2) : s2 vient après s1
    "nombre": (1, False, True),        # nombre(x) = n
    "meme": (2, False, False),         # coréférence (fusion), dans une même situation et un même contexte
    "distinct": (2, False, False),     # deux individus différents
    "meme_individu": (2, False, False),  # deux figures, un individu, sans fusion
    "contexte_ouvert": (2, False, True),  # requêtes seulement : contexte_ouvert(C, E) de sorte s
}
PREDICATS_IDENTITE = ("meme", "distinct", "meme_individu")
ROLES = ("agent", "patient", "theme", "destinataire", "instrument", "lieu", "porteur", "co_agent")


@dataclass(frozen=True)
class Atome:
    """G 8. Un atome : pred(args) [: type] [= valeur] [@ contexte].
    `contexte` vaut None (le contexte d'évaluation, ou celui de l'assertion) ou, dans une requête, une variable de
    sorte contexte liée par un atome `contexte_ouvert`."""
    pred: str
    args: tuple
    type: object = None
    valeur: object = None
    contexte: object = None


# --------------------------------------------------------------------------------------------------------------
# § 1.8 Les formules des requêtes (G 14)
#   F ::= Atome | Et(F, …) | Ou(F, …) | Non(F) | Existe(x̄, F) | Compte(Q, x, F, F?, ȳ) | Selon(p, v ↦ F)
# --------------------------------------------------------------------------------------------------------------

@dataclass(frozen=True)
class Et:
    """G 14b. La conjonction (au moins un enfant)."""
    enfants: tuple


@dataclass(frozen=True)
class Ou:
    """G 14c. La disjonction (au moins deux enfants)."""
    enfants: tuple


@dataclass(frozen=True)
class Non:
    """G 14d. La négation PROPOSITIONNELLE d'une sous-formule. Paraconsistante : elle échange les appuis ; elle n'est
    jamais satisfaite par une absence."""
    corps: object


@dataclass(frozen=True)
class Existe:
    """G 14e. La quantification existentielle explicite : `variables` est une suite de (nom, sorte), locales."""
    variables: tuple
    corps: object


QUANTIFICATEURS_REQUETE = ("au_moins", "exactement", "aucun", "tous", "seul")


@dataclass(frozen=True)
class Compte:
    """G 14f. Une quantification explicite de la requête :
    au_moins(n) x. R ; exactement(n) x. R ; aucun x. R ; tous x. R → P ; seul x. R → x ∈ {membres}."""
    quant: str
    n: Optional[int]
    variable: tuple  # (nom, sorte)
    restriction: object
    portee: object = None
    membres: tuple = ()


@dataclass(frozen=True)
class Selon:
    """G 14g. Une formule qui dépend d'un point de Δ (forme du libellé, lecture d'un pluriel du libellé…) :
    sous i, la formule est celle de la valeur i(p). `cas` est une suite de (valeur, formule)."""
    point: str
    cas: tuple


# --------------------------------------------------------------------------------------------------------------
# § 1.2 Identifiants et provenance (G 2) ; § 1.6 qualification, garde (G 9, G 10)
# --------------------------------------------------------------------------------------------------------------

@dataclass(frozen=True)
class Provenance:
    """G 2. La provenance textuelle : le document, sa langue, la phrase (à partir de 0), les offsets de caractères
    [debut, fin[ dans le texte, l'extrait. Elle n'a aucun effet sémantique (RF19, et un test le vérifie)."""
    document: Optional[str] = None
    langue: Optional[str] = None
    phrase: Optional[int] = None
    debut: Optional[int] = None
    fin: Optional[int] = None
    extrait: Optional[str] = None


SANS_PROVENANCE = Provenance()


@dataclass(frozen=True)
class Qualification:
    """G 9. polarité, modalité, énonciateur (`auteur` ou `cite:X`), contexte ; et, pour une assertion supposée,
    la nature de l'hypothèse qu'elle est (définition 4) et son contenu."""
    polarite: str = "pos"
    modalite: str = "affirme"
    enonciateur: str = "auteur"
    contexte: str = RACINE
    nature: Optional[str] = None
    contenu: Optional[str] = None


@dataclass(frozen=True)
class Garde:
    """G 10. Une garde : une conjonction de conditions (point, valeurs) ; l'assertion n'existe que dans les
    interprétations qui la satisfont (« A, si p = v », étude § 9.1). Vide : toujours."""
    conditions: tuple = ()


TOUJOURS = Garde()


# --------------------------------------------------------------------------------------------------------------
# § 1.6 et § 1.7 Les contenus d'assertion (G 11, G 12)
# --------------------------------------------------------------------------------------------------------------

@dataclass(frozen=True)
class Proposition:
    """G 11. Une proposition ∃ locales. ∧ atomes ; ses atomes ont pour arguments des référents (chaînes) ou ses
    variables locales (Var). Une assertion NÉGATIVE a toujours une proposition pour contenu : elle nie la conjonction
    entière, qui ne se répartit pas sur ses atomes."""
    locales: tuple  # suite de (nom, sorte)
    atomes: tuple


QUANTIFICATEURS_ENONCES = ("aucun", "tous", "tous_sauf", "seul", "exactement", "au_moins")


@dataclass(frozen=True)
class Quantification:
    """G 12. Une quantification énoncée : Q x ∈ Dom. restriction(x) [→ portée(x)].
    Dom est le contexte de l'assertion, restreint à `situation` si elle est donnée. `membres` : les exceptions de
    `tous_sauf`, ou les seuls de `seul`. `n` : pour `exactement` et `au_moins`."""
    quant: str
    n: Optional[int]
    variable: tuple  # (nom, sorte)
    restriction: tuple  # atomes sur la variable (Var) et des référents
    portee: tuple = ()
    membres: tuple = ()
    situation: Optional[str] = None


@dataclass(frozen=True)
class Assertion:
    """G 13. Une assertion : un identifiant, un contenu, une qualification, une garde, une provenance."""
    id: str
    contenu: object  # Atome | Proposition | Quantification
    qualification: Qualification = Qualification()
    garde: Garde = TOUJOURS
    provenance: Provenance = SANS_PROVENANCE


@dataclass(frozen=True)
class Alternative:
    """G 15. Une alternative de l'AUTEUR (« soit un moine, soit une moniale ») : des branches d'assertions. Ce ne sont
    pas des valeurs à choisir mais des cas : une conclusion vraie dans chaque branche est établie (étude § 3.4)."""
    id: str
    branches: tuple  # suite de suites d'identifiants d'assertions
    provenance: Provenance = SANS_PROVENANCE


# --------------------------------------------------------------------------------------------------------------
# § 1.3 Contextes, référents (G 3, G 4, G 6)
# --------------------------------------------------------------------------------------------------------------

@dataclass(frozen=True)
class Contexte:
    """G 4. Un contexte : sa sorte, son parent (None pour la racine `principal`), l'éventualité qui l'ouvre, sa
    source (pour un contexte `source`). Les contextes forment un arbre ; un chemin est la suite des contextes de la
    racine à l'un d'eux."""
    id: str
    sorte: str
    parent: Optional[str] = None
    ouvert_par: Optional[str] = None
    source: Optional[str] = None


@dataclass(frozen=True)
class Referent:
    """G 6. Un référent (une mention) : sa sorte, son contexte d'origine, sa situation, l'assertion qui l'introduit
    (de la forme type(r, T), positive). Une situation est un référent de sorte `situation`, sans introduction."""
    id: str
    sorte: str
    contexte: str = RACINE
    situation: Optional[str] = None
    introduit_par: Optional[str] = None


# --------------------------------------------------------------------------------------------------------------
# § 1.5 Points, contraintes, préférences (G 16, G 17, G 18)
# --------------------------------------------------------------------------------------------------------------

@dataclass(frozen=True)
class Point:
    """G 16. Un point d'ambiguïté : son côté (D ou Δ), sa dimension, son domaine, son ancre (l'assertion ou le mot
    où il se trouve). Pour la dimension `sens`, les valeurs sont des concepts, ou « ⊥ »."""
    id: str
    cote: str
    dimension: str
    domaine: tuple
    ancre: Optional[str] = None
    provenance: Provenance = SANS_PROVENANCE


VALEUR_INCONNUE = "⊥"


@dataclass(frozen=True)
class Contrainte:
    """G 17. Une contrainte DURE : un ensemble de combinaisons interdites, chacune une suite de (point, valeur).
    `forme` garde la forme écrite : `exclusion` (un point, des valeurs), `exclusion_conjointe` (plusieurs points),
    `implication` (p = v ⇒ q ∈ W), `restriction_de_selection` (dérivée de K)."""
    id: str
    forme: str
    interdits: tuple
    source: str
    sorte: str = "texte"


@dataclass(frozen=True)
class Preference:
    """G 18. Une préférence : un ordre sur les valeurs d'un point (`ordre`, la plus préférée d'abord), ou un couplage
    « même valeur » entre deux points (`couplage`). Elle n'exclut rien."""
    id: str
    point: Optional[str] = None
    ordre: tuple = ()
    couplage: tuple = ()
    source: str = ""


# --------------------------------------------------------------------------------------------------------------
# § 1.12 La description (G 19)
# --------------------------------------------------------------------------------------------------------------

@dataclass(frozen=True)
class Description:
    """G 19. La description D : contextes, référents, assertions, alternatives de l'auteur, points de D, contraintes
    de D, préférences."""
    id: str
    langue: str = "fr"
    texte: str = ""
    contextes: tuple = (Contexte(RACINE, "figuration"),)
    referents: tuple = ()
    assertions: tuple = ()
    alternatives: tuple = ()
    points: tuple = ()
    contraintes: tuple = ()
    preferences: tuple = ()


# --------------------------------------------------------------------------------------------------------------
# § 1.9 La définition : conditions nécessaires et suffisantes structurées (G 20)
# --------------------------------------------------------------------------------------------------------------

STATUTS_CONDITION = ("etablie", "non_etablie")


@dataclass(frozen=True)
class Definition:
    """G 20. La définition Δ d'une notation : une paire (suffisante, nécessaire) de formules, chacune avec son statut
    d'entrée. Une définition qui est une équivalence a les deux égales. `variables` : les variables libres, typées."""
    id: str
    libelle: str = ""
    langue: str = "en"
    variables: tuple = ()  # suite de (nom, sorte)
    suffisante: object = None
    necessaire: object = None
    statut_suffisance: str = "etablie"
    statut_necessite: str = "etablie"
    points: tuple = ()
    contraintes: tuple = ()
    preferences: tuple = ()
    provenance: Provenance = SANS_PROVENANCE


# --------------------------------------------------------------------------------------------------------------
# § 1.10 Les connaissances formelles K (G 21)
# --------------------------------------------------------------------------------------------------------------

STATUTS_K = ("attestee", "non_attestee")


@dataclass(frozen=True)
class Source:
    ressource: str = ""
    element: str = ""
    validation: str = ""


@dataclass(frozen=True)
class Inclusion:
    """G 21a. sous ⊑ sur (hyperonymie, instance) entre concepts (de référents, d'éventualités ou de relations)."""
    id: str
    sous: str
    sur: str
    source: Source = Source()
    statut: str = "attestee"


@dataclass(frozen=True)
class Partie:
    """G 21b. partie ⊑_partie tout : une méronymie entre concepts. Aucune règle d'évaluation dans la version 1
    (décision 37 : aucun transfert sans une règle dirigée ; le tout impliqué n'est pas présent)."""
    id: str
    partie: str
    tout: str
    source: Source = Source()
    statut: str = "attestee"


@dataclass(frozen=True)
class Equivalence:
    """G 21c. a ≡ b entre concepts : les deux inclusions."""
    id: str
    a: str
    b: str
    source: Source = Source()
    statut: str = "attestee"


SORTES_REGLE = ("implication", "condition_suffisante", "condition_necessaire", "consequence_conditionnelle")


@dataclass(frozen=True)
class Regle:
    """G 21d. Une connaissance dirigée entre structures : premisse ⇒ conclusion (des atomes sur des variables).
    - implication, condition_suffisante, condition_necessaire : la déduction dans son sens, et la contraposition
      (le faux de la conclusion vers la prémisse) ;
    - consequence_conditionnelle (A ⇒ B si C ; C est dans la prémisse) : la déduction seulement, aucune négation."""
    id: str
    sorte: str
    variables: tuple  # suite de (nom, sorte)
    premisse: tuple
    conclusion: tuple
    source: Source = Source()
    statut: str = "attestee"


@dataclass(frozen=True)
class DefinitionK:
    """G 21e. Une définition conceptuelle structurée de K : concept T de variable x ; suffisante(x) ⇒ T(x) et
    T(x) ⇒ necessaire(x), chacune avec son statut. Une condition non établie ne fonde qu'une hypothèse
    (d'abduction : une classification supposée, docs/FONDEMENTS_SEMANTIQUES.md § 4)."""
    id: str
    concept: str
    variable: tuple  # (nom, sorte)
    suffisante: tuple = ()
    necessaire: tuple = ()
    statut_suffisance: str = "etablie"
    statut_necessite: str = "etablie"
    locales: tuple = ()
    source: Source = Source()
    statut: str = "attestee"


FORMES = ("type", "propriete", "etat", "relation")


@dataclass(frozen=True)
class Typique:
    """G 21f. a est typiquement b : jamais déductif ; fonde une hypothèse de nature connaissance_typique."""
    id: str
    a: str
    b: str
    forme: str = "type"
    source: Source = Source()
    statut: str = "attestee"


INDEXATIONS = ("porteur", "moment", "contexte")


@dataclass(frozen=True)
class Incompatibilite:
    """G 21g. Une incompatibilité attestée et indexée : pour un même porteur, dans un même contexte, et au même
    moment (même situation, même ancrage) si `moment` est dans l'indexation, a et b s'excluent."""
    id: str
    a: str
    b: str
    forme: str = "type"
    indexation: tuple = ("porteur", "moment", "contexte")
    sorte: str = "logique"
    source: Source = Source()
    statut: str = "attestee"


@dataclass(frozen=True)
class Antonymie:
    """G 21h. Une antonymie lexicale : une ressource, jamais une attestation ; aucun effet sémantique."""
    id: str
    a: str
    b: str
    source: Source = Source()
    statut: str = "attestee"


@dataclass(frozen=True)
class OppositionTypique:
    """G 21i. Une opposition typique : l'abduction seulement ; jamais un appui négatif ; aucun effet ici."""
    id: str
    a: str
    b: str
    source: Source = Source()
    statut: str = "attestee"


@dataclass(frozen=True)
class RestrictionSelection:
    """G 21j. Le rôle `role` d'une éventualité de type ⊑ predicat demande un argument de type `requis`. Elle ne fonde
    une exclusion qu'avec une incompatibilité attestée de forme `type` entre `requis` et le type de la valeur, et
    seulement dans les contextes de sorte `domaine` (le domaine de validité, étude § 4.5)."""
    id: str
    predicat: str
    role: str
    requis: str
    domaine: tuple = ("figuration",)
    source: Source = Source()
    statut: str = "attestee"


@dataclass(frozen=True)
class Alias:
    """G 21k. Deux clés de nom d'un même individu (fermé : réflexif, symétrique, transitif)."""
    id: str
    cle1: str
    cle2: str
    source: Source = Source()
    statut: str = "attestee"


@dataclass(frozen=True)
class Distinction:
    """G 21l. Deux clés de nom de deux individus documentés différents."""
    id: str
    cle1: str
    cle2: str
    source: Source = Source()
    statut: str = "attestee"


ENTREES_K = (Inclusion, Partie, Equivalence, Regle, DefinitionK, Typique, Incompatibilite, Antonymie,
             OppositionTypique, RestrictionSelection, Alias, Distinction)


@dataclass(frozen=True)
class Connaissances:
    """G 21. K : une version et des entrées."""
    version: str = "K"
    entrees: tuple = ()


# --------------------------------------------------------------------------------------------------------------
# § 1.11 Les hypothèses (G 22) et § 1.12 le cas (G 23)
# --------------------------------------------------------------------------------------------------------------

@dataclass(frozen=True, order=True)
class Hypothese:
    """G 22. Une hypothèse : (nature, contenu). Sa nature est fixée quand elle naît ; rien ne la change."""
    nature: str
    contenu: str


@dataclass(frozen=True)
class Cas:
    """G 23. Un cas : une description, une définition, des connaissances."""
    id: str
    description: Description
    definition: Definition
    connaissances: Connaissances = Connaissances()
    remarques: str = ""


# --------------------------------------------------------------------------------------------------------------
# Des constructeurs abrégés, pour écrire les cas à la main (tests, exemples)
# --------------------------------------------------------------------------------------------------------------

def V(nom: str) -> Var:
    return Var(nom)


def C(c) -> object:
    """Un type à partir d'une chaîne (un concept) ou d'un type déjà construit."""
    return Concept(c) if isinstance(c, str) else c


def type_(x, t, ctx=None) -> Atome:
    return Atome("type", (x,), type=C(t), contexte=ctx)


def propriete(x, t, ctx=None) -> Atome:
    return Atome("propriete", (x,), type=C(t), contexte=ctx)


def role(e, r, x, ctx=None) -> Atome:
    return Atome("role", (e, x), valeur=r, contexte=ctx)


def relation(r, x, y, ctx=None) -> Atome:
    return Atome("relation", (x, y), type=C(r), contexte=ctx)


def nom(x, cle, ctx=None) -> Atome:
    return Atome("nom", (x,), valeur=cle, contexte=ctx)


def ancrage(e, a, ctx=None) -> Atome:
    return Atome("ancrage", (e,), valeur=a, contexte=ctx)


def dans(x, s) -> Atome:
    return Atome("dans", (x, s))


def succede(s1, s2) -> Atome:
    return Atome("succede", (s1, s2))


def meme(x, y) -> Atome:
    return Atome("meme", (x, y))


def distinct(x, y) -> Atome:
    return Atome("distinct", (x, y))


def meme_individu(x, y) -> Atome:
    return Atome("meme_individu", (x, y))


def contexte_ouvert(c, e, sorte) -> Atome:
    return Atome("contexte_ouvert", (c, e), valeur=sorte)


def et(*fs) -> Et:
    return Et(tuple(fs))


def ou(*fs) -> Ou:
    return Ou(tuple(fs))
