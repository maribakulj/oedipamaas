# La spécification des opérations : canonisation, déduction, classification, abduction (version 1, 27/11)

Ce document spécifie les quatre opérations que `docs/FONDEMENTS_SEMANTIQUES.md` distingue. Pour chacune, il dit :
- ce qu'elle reçoit et ce qu'elle rend ;
- ses invariants ;
- le statut de ce qu'elle produit ;
- ce que la preuve en garde ;
- ce que le vérificateur contrôle ;
- les contre-exemples qu'un banc doit contenir avant toute réalisation.

Il ne décrit aucun code existant : c'est la cible. Le prototype des couches d'inférence (`outils/inference/`) en est
une approximation, non une réalisation.

**Les notations :**
- G, un graphe validé ; Q, une requête bien formée ; K, les connaissances ;
- σ, une substitution ; A, une assertion ; ctx(A), son chemin de contextes (`docs/FONDEMENTS_SEMANTIQUES.md`, § 2.5).
- Un terme `derive(Id, Sorte, Regle, Ressource, Sources, Statut)` décrit une assertion produite par une opération.

## 1. La canonisation

**La signature :** `canoniser(+G, -G')` et `canoniser_requete(+Q, -Q')`, par **la même table de règles**.

**Ce qu'est une règle :** `equivalence(Forme1, Forme2, Condition, Ressource)`.
- Forme1 et Forme2 sont des motifs d'assertions (ou d'atomes, côté requête).
- Condition est une condition sur les **sens** (un sens, ou tous les sens d'un mot, D30), jamais sur la syntaxe seule.
- La règle réécrit Forme1 en Forme2, la forme canonique, des deux côtés.

**Les invariants** (§ 3.1 des fondements). Pour tout G : les référents, les rôles, les chemins de contextes, l'ancrage
temporel et les polarités de G' sont ceux de G, et M(G') = M(G).
- Une règle dont la Condition ne vaut que pour un sens produit G' **sous l'hypothèse de ce sens** : la réécriture
  porte l'hypothèse `sens_suppose(Occurrence, Mot, Sens)`, et le noyau la traite comme toute hypothèse de sens.

**Ce qu'elle ne fait pas :**
- elle n'ajoute aucun référent, aucun événement nouveau (une nominalisation **devient** l'événement : elle ne s'y
  ajoute pas) ;
- elle ne choisit pas un rôle par la syntaxe ;
- elle ne transforme aucune implication en réécriture.

**La preuve :** une solution sur G' cite les assertions de G' ; chaque assertion réécrite garde `origine(A, Regle)`,
l'assertion de G dont elle vient et la règle.

**Le vérificateur :** il refait la réécriture à partir de G et de la table, avec la version de la table, et vérifie
l'origine de chaque assertion citée.

**Les contre-exemples du banc :**
- « death of Anna » (un nom d'action) contre « Anna dies » : équivalents pour le sens événementiel ;
- « death » au sens de la Mort personnifiée : pas d'équivalence ;
- « building » (le bâtiment) : pas un nom d'action ;
- « a fallen angel », « a burning house », « a praying figure » : aucun rôle par la seule syntaxe ;
- « trade card », « parish church », « fusée de signalisation » : aucune propriété par la seule syntaxe ;
- une réécriture sous une négation (« pas de calvitie » ⇒ « pas chauve ») : permise parce que c'est une
  équivalence.

## 2. La déduction

**La signature :**
- **dans le noyau, inchangé :** les liens positifs et négatifs par `sous/2` et `inclus/2` ;
- **à côté :** `deduire(+G, +K, -D)`, qui produit des assertions dérivées D par des **implications** et des
  **conséquences conditionnelles** de K.

**Ce qu'est une règle :** `implication(Premisses, Conclusion, Condition, Ressource, Negation)`.
- **Les sortes :** entailment, cause (kill ⇒ die du patient), état résultant (dead ⇐ die antérieur), partie
  obligatoire (un pont de navire ⇒ un navire). Toutes sont dirigées.
- **Negation :** le sens dans lequel la règle transmet une négation, `contraposition` ou `aucun` (§ 3.3 des fondements).
- **Condition :** ce qui doit être établi pour que la règle s'applique (le porteur est une personne ; la partie est
  obligatoire). Si elle n'est pas établie, la règle ne s'applique pas déductivement. Elle peut s'appliquer sous
  hypothèse (§ 4).

**Les invariants :**
- une assertion dérivée a le chemin de contextes de ses prémisses, et son ancrage temporel est celui que la règle dit
  (la conséquence d'un événement en cours est en cours ou postérieure ; la cause d'un état est antérieure) ;
- **une prémisse niée ne fonde rien :** `deduire` ne part que de prémisses positives admissibles ;
- une négation n'est propagée que par contraposition, et seulement si la règle le permet ;
- **la terminaison :** les règles ne créent de référent qu'en nombre borné par le graphe (une partie a un tout, au plus
  un par règle et par partie), et le calcul est un point fixe borné.

**Le statut :** `derive(Id, implication, …, certain)` si chaque prémisse est appuyée sans hypothèse et si chaque
condition est établie. Sinon, la dérivation porte les hypothèses de ses prémisses et de ses conditions.

**La preuve :** l'assertion dérivée est citée comme une assertion. La preuve contient le terme `derive/6`, et
récursivement ceux de ses sources.

**Le vérificateur :** il refait chaque dérivation citée (la règle existe dans K à cette version ; ses prémisses sont
des appuis admissibles ; sa condition est établie ou dans les hypothèses), et vérifie l'ancrage et le contexte.

**Les contre-exemples du banc :**
- « pas de lion » n'établit pas « pas de félin » ; « pas de félin » établit « pas de lion » ;
- « Goliath ne tue pas David » n'établit pas « David ne meurt pas » ;
- « un corps sans vie » établit une mort **antérieure**, et n'établit pas « un homme meurt » au sens d'une mort figurée
  en cours ;
- « un pont » établit un navire seulement si la partie est obligatoire (le pont d'un navire, non d'une maison) ;
- une dérivation dont la prémisse est seulement possible (`modalite(possible)`) ne produit rien de déductif.

## 3. La classification

**Deux réalisations, selon la sorte de la définition** (audit, § 3.8).

**3.1 Le dépliage, côté requête, pour une définition qui est une équivalence.**
- **L'opération :** `deplier(+Q, +Definitions, -Q')` remplace un atome `type(X, T)` (ou `evenement`, `propriete`) par
  `ou([type(X, T), Def_T(X)])`.
  - Def_T est la définition de T compilée en requête, ses variables renommées hors de Q.
  - C'est une réécriture de requête, comme dans les ontologies légères ; le noyau n'est pas touché.
- **La condition :** Def_T est une **équivalence** (nécessaire et suffisante), selon la ressource. Le comparateur
  d'inclusion vérifie que Def_T ⊆ type(X, T) n'est pas contredit par K (aucun contre-exemple), et la preuve cite
  la définition employée.
- **Le statut :** déductif, sous les hypothèses de sens de la définition (le sens de T qu'elle définit).
- **La terminaison :** le dépliage est borné (une profondeur, pas de définition circulaire, ce que vérifie un graphe
  des dépendances).
- **Les contre-exemples du banc :**
  - « l'organe de l'odorat » établit nez par la définition de nose, si elle est tenue pour une équivalence ;
  - « un être humain au-dessus de la taille, serpent en dessous » établit monstre seulement si la définition de monster
    est structurée : des parties humaine et animale, **reliées** à l'être ;
  - « un moine » n'établit pas « tonsure » : le faux positif de la couche D est la preuve qu'un appariement non
    structuré ne suffit pas.

**3.2 La dérivation, côté graphe, pour une définition typique ou partielle.**
- **L'opération :** `classer(+G, +Definitions, -D)` produit `derive(Id, classification, …, hypothese)` :
  `type(X, T)` pour une entité X dont le graphe satisfait la définition de T jusqu'à un seuil fixé à l'avance.
  - L'appariement est structuré : le noyau évalue Def_T(X) comme une requête, sous X lié.
  - Le seuil porte sur les atomes satisfaits de Def_T, jamais sur une similarité de mots.
- **Le statut :** toujours une hypothèse.

## 4. L'abduction

**La signature :** `abduire(+G, +Q, +K, +Budget, -Explications)`.
- Une explication est un ensemble H de **assertions supposées** : des entités, des événements, des relations, des
  classifications, des sens, des prémisses graduées. Avec H, Q est établie : M(G ∪ H) ⊨ Q.
- H est proposé par des connaissances typiques ou interprétatives, chacune avec sa ressource.

**Les contraintes sur H** (§ 4 des fondements) :
- **admissible :** aucune hypothèse n'est niée par G ou par K ; aucune ne contredit une autre ;
- **conjointement satisfaisable :** les sens supposés par H et par les appuis de la preuve forment des lectures
  conjointes (lot 4) ;
- **minimale :** aucun sous-ensemble strict de H ne suffit ;
- **dirigée :** chaque hypothèse sert un atome de Q (abduction dirigée par ce qu'elle explique, ce qui borne
  l'inflation).

**Le coût et le rang :**
- chaque sorte de connaissance a un coût, fixé à l'avance et jamais réglé sur la validation : équivalence 0,
  implication 0, conséquence conditionnelle (condition supposée) 1, connaissance typique 2, hypothèse interprétative 4 ;
- les explications sont classées par coût total, puis par nombre d'hypothèses.
- C'est l'abduction pondérée (Hobbs et al.), restreinte à des hypothèses que la preuve nomme.

**Le statut :** `etablie_sous_hypotheses`, avec H dans la preuve. **Jamais `etablie`.** Le codage en fait
`conditionnel_par_inference`, en extension de `conditionnel_par_derivation` (lot 3).

**Le vérificateur :** il vérifie que G ∪ H établit Q (la preuve habituelle), que chaque hypothèse de H est proposée par
une connaissance de K à cette version, que H est admissible et conjointement satisfaisable, et que H est minimal.

**Les contre-exemples du banc :**
- « un geôlier tourne la clé » fait supposer un emprisonnement (connaissance typique), mais aucune explication ne doit
  le rendre `etablie` ;
- « un moine » ne fait pas supposer une tonsure **figurée** quand le texte dit « les cheveux longs » : l'hypothèse est
  contredite ;
- « un portrait de mariage » fait supposer des mariés, non une noce figurée en cours ;
- deux hypothèses qui demandent deux sens d'une même occurrence ne sont pas dans la même explication.

## 5. Ce que les quatre opérations demandent au noyau

**Rien dans sa logique.** Ce qu'il faut :
- un graphe G' (canonisé) et un ensemble D d'assertions dérivées, chacune avec son identifiant et son terme `derive/6`.
  L'expérience des couches montre que le noyau les cite déjà par leur identifiant ;
- **l'extension du format des preuves :** les termes `derive/6` et `origine/2`, et les sortes d'hypothèses nouvelles ;
- **l'extension du vérificateur,** qui refait canonisation, dérivations, dépliages et explications ;
- **l'extension du codage :** le statut `conditionnel_par_inference`.

Les extensions du langage établies par l'audit (ancrage temporel, contextes de contenu, référents conceptuels,
`non/1`) sont, elles, des changements du langage d'assertions et du langage des requêtes. Le noyau les reçoit par
**sa spécification** : une version 0.4 de `docs/NOYAU.md`, son oracle et ses bancs, avant le code.
