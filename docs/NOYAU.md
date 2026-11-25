# Le noyau logique : requêtes, satisfaction, preuves (M0, 25 novembre 2026)

Ce document est la partie formelle de FONDEMENTS v3 (`docs/PLAN_V1.md`, C1 et C2) : le langage des requêtes, leur
satisfaction sur le graphe d'un texte, la forme des preuves et ce que le vérificateur contrôle. Le code suit ce texte :
`oedipamaas/socle/requetes.pl` (forme des requêtes), `satisfaction.pl` (le moteur), `verificateur.pl` (le
vérificateur, écrit à part). Les tests (`tests/plunit/test_noyau.pl`) ne portent que sur des graphes et des requêtes
écrits à la main : aucune erreur de langue ne peut y masquer une erreur de logique.

## 1. Le graphe d'un texte

Les assertions de `docs/ASSERTIONS.md`, sans changement : `entite/3`, `nom/4`, `propriete/4`, `evenement/3`,
`role/3`, `relation/5`, `coref/2`, `nombre/2`, `polarite/2`, `modalite/2`, `portee/2`, `enonciateur/2`,
`alternative/2`, `passage/3`.

- **Les référents** sont les classes de coréférence : deux entités liées par `coref/2` (fermeture réflexive,
  symétrique, transitive) sont un même référent ; son représentant est le plus petit identifiant. Un nom, un type,
  une propriété d'un membre valent pour la classe. Seule la coréférence établie est dans le graphe (`coref/2`) ; la
  coréférence possible n'y entre pas (elle servira aux hypothèses, C9).
- **L'état d'une assertion**, pour une condition qui demande le contexte C :
  - `pos` : polarité positive, modalité « affirmé », énonciateur « auteur », hors de toute alternative, portée C ;
  - `neg` : polarité négative, modalité « affirmé », portée C (quel que soit l'énonciateur) ;
  - aucun état sinon (une hypothèse, un titre, une citation, un autre contexte) : l'assertion ne prouve rien et ne
    contredit rien ici.
  Un rôle (`role/3`, sans identifiant propre) a l'état de son événement.
- **Les contextes demandés** : la figuration (types, noms, propriétés, événements, rôles, relations, nombres) demande
  la portée `represente` ; le classement de l'œuvre (`genre`) demande la portée `oeuvre` (un portrait accroché au mur
  d'une scène n'est pas le genre de l'œuvre).

## 2. Les connaissances

Le moteur ne connaît aucun mot : il interroge un module de connaissances K, qui donne quatre primitives.

| Primitive | Sens |
|---|---|
| `K:sens(Categorie, Mot, Type)` | un mot du texte (catégorie `n`, `v`, `a`, `r` pour une relation) désigne ce type ; un mot peut en désigner plusieurs |
| `K:sous(Type, TypeParent)` | un pas de hiérarchie : Type est directement sous TypeParent (hyperonymie, instance) |
| `K:cle_de_nom(Nom, Cle)` | la forme normalisée d'un nom propre |
| `K:alias(Cle1, Cle2)` | deux noms d'un même individu, établi (variantes et mots clés d'Iconclass) |

et `K:version(V)`. La production branche WordNet, WOLF et Iconclass sur ces primitives ; les tests, un petit module
écrit à la main. Un **lien** est le chemin qui justifie une correspondance : `chemin(Mot, [T0, T1, …, Tn])` avec
`K:sens(Cat, Mot, T0)` et `K:sous(Ti, Ti+1)` ; `cle(C)` ou `alias(C, K)` pour un nom.

## 3. Le langage des requêtes

Une requête est `requete(Id, Formule)`. Les variables s'écrivent `v(Nom)`. Une formule :

```
F ::= et([F, …]) | ou([F, …]) | Atome | Contrainte
Atome ::= type(X, T)            le référent X a un type égal ou plus spécifique que T
        | nom(X, [Cle, …])      X porte l'un de ces noms (ou un alias établi)
        | propriete(X, P)       X a la propriété P (ou plus spécifique)
        | evenement(E, P)       E est un événement de prédicat P (ou plus spécifique)
        | role(E, R, X)         X a le rôle R dans E (agent, patient, theme, instrument, destinataire, lieu)
        | relation(X, R, Y)     une relation orientée R de X vers Y (ou plus spécifique)
        | genre(T)              l'œuvre est de genre T (ou plus spécifique) : un prédicat de l'œuvre, sans variable
Contrainte ::= meme(X, Y) | distincts(X, Y) | nombre(X, K)
```

- Toutes les variables sont **existentielles**, de portée la requête entière ; une variable de deux branches d'un
  `ou` est la même variable.
- **Aucune distinction implicite** : deux variables peuvent tomber sur le même référent, sauf `distincts(X, Y)` ; elles
  tombent sur le même référent si `meme(X, Y)`.
- `nombre(X, K)` : le texte dit que X est au nombre de K (`nombre/2`).
- Une requête est **bien formée** si chaque variable apparaît dans au moins un atome (pas seulement dans une
  contrainte), si un `ou` a au moins deux branches et un `et` au moins une, et si la sorte de chaque variable est
  unique (référent ou événement : premier argument de `evenement` et de `role`).

**Le fragment.** Ce sont des formules existentielles positives (∃, ∧, ∨) à atomes typés, avec égalité et
différence, évaluées sur un graphe fini : l'équivalent d'unions de requêtes conjonctives. Il n'y a pas de négation
dans une requête, et aucune négation par échec dans une preuve. L'évaluation termine : le graphe est fini, la requête
aussi, la hiérarchie des types est sans cycle. Son coût est celui d'un homomorphisme de graphes, exponentiel dans le
nombre de variables seulement ; le moteur lie d'abord les atomes les plus sélectifs (§ 4).

## 4. La satisfaction

Une **substitution** σ associe à chaque variable un référent (une classe) ou un événement du graphe. Sous σ, un atome a
des **appuis** : les assertions qui le portent, avec leur lien ; chacun est `pos` ou `neg` (§ 1). La valeur de l'atome
sous σ (Belnap) :

| appuis pos | appuis neg | valeur |
|---|---|---|
| aucun | aucun | inconnu |
| oui | aucun | vrai |
| aucun | oui | faux |
| oui | oui | contradictoire |

Une contrainte est vraie ou fausse sous σ, sans appui.

La valeur d'une formule sous σ se compose sur les paires (positif, négatif) : ¬p = (p⁻, p⁺) ; p ∧ q = (p⁺ ∧ q⁺,
p⁻ ∨ q⁻) ; p ∨ q = (p⁺ ∨ q⁺, p⁻ ∧ q⁻). Le moteur énumère les substitutions **complètes** (chaque variable liée par un
appui de l'un de ses atomes) et classe chacune :

- **vraie** : la formule est vraie sous σ ;
- **contredite** : la formule est fausse sous σ (une condition n'est portée que par une assertion niée : « la femme ne
  tient pas l'enfant ») ;
- **contradictoire** : une condition y a des appuis des deux signes (deux énonciateurs, ou le texte se contredit).

Le résultat d'une requête sur un graphe :

| Résultat | Condition |
|---|---|
| `etablie(Sigmas)` | au moins une substitution vraie ; toutes les substitutions vraies sont données (une notation peut être portée par plusieurs référents) |
| `contradictoire(Sigmas)` | aucune vraie, au moins une contradictoire |
| `ecartee(Sigmas)` | aucune vraie ni contradictoire, au moins une contredite : écartée **pour ces référents** |
| `inconnue(Partiel)` | aucune substitution complète ; `Partiel` dit quels atomes ont au moins un appui positif quelque part (une correspondance partielle, jamais une preuve) |

Un rôle inversé n'est pas une preuve négative : « Goliath tranche la tête de David » ne donne pas de substitution
vraie à « David tranche la tête de Goliath », et ne la contredit pas (résultat `inconnue`). Une substitution
contredite n'écarte pas la configuration ailleurs : si l'œuvre montre aussi l'autre scène, la requête est établie
par elle.

**L'ordre de liaison** : à chaque pas, le moteur choisit, parmi les atomes non encore satisfaits, celui qui a le moins
d'appuis compatibles avec les variables déjà liées (un nom propre, un type rare, un rôle d'un événement déjà lié) ;
les contraintes sont vérifiées dès que leurs variables sont liées ; un `ou` est développé quand il ne reste plus
d'atome à lier hors de lui.

**La limite de calcul** : au-delà de 200 substitutions complètes pour une requête, le moteur s'arrête et le résultat
porte `incomplet` ; il n'est jamais présenté comme complet.

## 5. La preuve

```
preuve(Id, Versions, Regime, Sigma, Justifications)
  Versions        [noyau(V), connaissances(V)]
  Regime          figuration | classement
  Sigma           [v(Nom)-Valeur, …]       (un référent : son représentant ; un événement : son identifiant)
  Justifications  [j(Chemin, Atome, Appui), …]
     Chemin       la position de l'atome dans la formule (liste d'indices à partir de 1)
     Appui        appui(Assertion, Entite, Passage, Lien) pour un atome ; contrainte pour une contrainte
```

Une preuve justifie une **sélection** d'atomes : tous les enfants d'un `et`, au moins un enfant d'un `ou`. Elle ne
cite que des appuis `pos`.

## 6. Le vérificateur

Un programme distinct (`verificateur.pl`), qui ne partage avec le moteur que ce document, le graphe et les primitives
de K. Il accepte une preuve si et seulement si :

1. les versions de la preuve sont celles du noyau et de K ;
2. la sélection justifiée satisfait la formule (un `et` : tous ses enfants ; un `ou` : au moins un) ;
3. chaque chemin désigne bien l'atome cité, et chaque atome justifié l'est une fois ;
4. chaque appui existe dans le graphe, est dans l'état `pos` pour le contexte de son atome, et correspond à σ (son
   entité est dans la classe de la valeur de la variable, son événement est la valeur de la variable) ;
5. chaque lien est valide pour K (chaque pas du chemin est une primitive `sens` ou `sous`, il finit au type demandé ;
   un nom passe par `cle_de_nom`, puis l'égalité ou un `alias`) ;
6. chaque contrainte est vraie sous σ ;
7. aucun atome justifié n'a, sous σ, d'appui `neg` dans le graphe (sinon la conclusion serait contradictoire).

Il certifie qu'une conclusion découle de ses prémisses (le graphe, K, la requête). Il ne certifie ni que la requête
dit le libellé (la fiabilité du compilateur, mesurée par famille, C3), ni que le graphe dit le texte (la fidélité du
lecteur, mesurée sur graphes annotés, C6), ni que le texte dit vrai de l'image (hors de portée du moteur). La sortie
dira à quel niveau tient chaque code.

**Le banc de mutations** : chaque preuve d'un test est altérée de toutes les façons suivantes, et chaque altération
doit être rejetée : un appui retiré ; un appui remplacé par une assertion inexistante ; un appui nié ; une valeur de σ
changée ; un rôle changé ; un pas de lien inventé ; un chemin déplacé vers une autre branche ; une version changée.
