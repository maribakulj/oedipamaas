# La spécification des opérations : canonisation, déduction, classification, abduction (version 1.1, 27/11)

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

**Ce qu'est une règle :** `equivalence(Forme1, Forme2, Condition, Provenance, Attestation)`. C'est une équivalence
**établie** : sa provenance (la ressource) et son attestation (la validation qui la confirme) sont deux champs
distincts. Une règle sans attestation n'est pas une canonisation.
- Forme1 et Forme2 sont des motifs d'assertions (ou d'atomes, côté requête), typés par des sens, jamais par des lemmes.
- Condition est une condition sur les **sens** (un sens, ou tous les sens d'un mot, D30), jamais sur la syntaxe seule.
- La règle réécrit Forme1 en Forme2, la forme canonique, des deux côtés.

**Les invariants** (§ 3.1 des fondements). Pour tout G : les référents, les rôles, les chemins de contextes, l'ancrage
temporel et les polarités de G' sont ceux de G, et v_{G'} = v_G (la valuation de Belnap, `docs/FONDEMENTS_SEMANTIQUES.md`, § 1.1).
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

**Les définitions viennent d'une base de définitions conceptuelles** (`docs/FONDEMENTS_SEMANTIQUES.md`, § 2.7) :
- chaque entrée relie un **sens** à une **structure** (un motif d'assertions typées par des sens) ;
- chaque entrée a un statut **par direction** (suffisance, nécessité), sa provenance et son attestation ;
- le compilateur des libellés renvoie aux entrées, et une entrée sert de nombreuses notations.

**Le statut d'une entrée décide de l'opération :**

| statut | ce que la classification en fait | statut de la conclusion |
|---|---|---|
| équivalence établie | dépliage côté requête, dans les deux directions (établir, réfuter) | déductive, sous les hypothèses de sens |
| condition suffisante établie | dépliage côté requête pour établir | déductive |
| condition nécessaire établie | condition nécessaire du libellé ; réfutation par la négation de la définition | déductive pour réfuter, jamais pour établir |
| connaissance typique, relation inconnue | dérivation côté graphe, comme hypothèse | sous hypothèse |

**Ce qui établit une suffisance ou une équivalence :** une **attestation**, c'est-à-dire la ressource qui la donne pour
telle, et une validation qui la confirme. L'absence de contre-exemple dans K **ne suffit pas** : en monde ouvert, K est
incomplet. Le comparateur d'inclusion peut montrer qu'un dépliage est **faux** (un contre-exemple), jamais qu'il est
juste.

**3.1 Le dépliage, côté requête, pour une définition suffisante ou équivalente établie.**
- **L'opération :** `deplier(+Q, +Base, -Q')` remplace un atome `type(X, T)` (ou `evenement`, `propriete`) par
  `ou([type(X, T), Def_T(X)])`, où Def_T est la structure de l'entrée, ses variables renommées hors de Q.
  - C'est une réécriture de requête ; le noyau n'est pas touché.
  - La preuve cite l'entrée, sa version et son attestation.
- **Le statut :** déductif, sous les hypothèses de sens de l'entrée (le sens de T qu'elle définit).
- **La terminaison :** le dépliage est borné, et le graphe des dépendances entre entrées est acyclique.
- **Les contre-exemples du banc :**
  - « l'organe de l'odorat » établit nez si la définition de nose est **attestée** suffisante ; sinon, c'est une
    hypothèse ;
  - « un être humain au-dessus de la taille, serpent en dessous » ne satisfait la définition de monstre que si sa
    structure demande des parties humaine et animale **reliées** à l'être ;
  - « un moine » n'établit pas « tonsure », par aucune définition : le faux positif de la couche D le montre.

**3.2 La dérivation, côté graphe, pour une connaissance typique ou une relation inconnue.**
- **L'opération :** `classer(+G, +Base, -D)` propose `type(X, T)` comme hypothèse, quand le graphe satisfait la
  structure de l'entrée, sous X lié.
  - L'appariement est structuré : le noyau évalue Def_T(X) comme une requête.
  - Un appariement partiel n'est accepté que selon un seuil sur les atomes satisfaits, fixé à l'avance, jamais une
    similarité de mots.
- **Le statut :** une hypothèse, soumise aux exigences de l'abduction (§ 4) : elle doit expliquer des éléments
  observés, et elle est comparée aux classifications concurrentes.

## 4. L'abduction

**Ce qu'elle produit.** `abduire(+G, +K, +Budget, -Explications)` produit des **explications des éléments observés** :
- une explication est un ensemble H d'**assertions supposées** (entités, éventualités, relations, classifications,
  sens, prémisses graduées) ;
- pour un sous-ensemble O des assertions de G, les **observations expliquées**, H et K impliquent O (O est dit vrai
  dans v_{H}, selon les connaissances employées) ;
- chaque hypothèse de H vient d'une connaissance identifiée : sa ressource, sa version, sa sorte (typique,
  interprétative, conséquence conditionnelle à condition supposée, relation inconnue).

**Ce qu'elle n'est pas.** Elle ne se réduit pas à ajouter des prémisses pour satisfaire une requête.
- Une hypothèse qui n'explique aucune observation est inadmissible, même si elle satisfait une requête.
- La requête n'est évaluée qu'**après**, sur G augmenté de chaque explication retenue. Elle peut guider la recherche,
  elle ne justifie rien.

**Les contraintes sur H :**
- **admissible :** aucune hypothèse n'est niée par G ou par K ; aucune ne contredit une autre ;
- **conjointement satisfaisable :** avec les sens supposés de la preuve (lot 4), à travers les dérivations ;
- **minimale :** aucun sous-ensemble strict de H n'explique les mêmes observations ;
- **comparée :** les explications concurrentes des mêmes observations sont calculées.

**Le coût et la comparaison :**
- chaque sorte de connaissance a un coût, fixé à l'avance et jamais réglé sur la validation : conséquence
  conditionnelle (condition supposée) 1, connaissance typique 2, relation inconnue 3, hypothèse interprétative 4 ;
- une explication est jugée par ce qu'elle explique (les observations couvertes) et par son coût ;
- deux explications qui couvrent les mêmes observations, à des coûts voisins (un écart fixé à l'avance), et qui
  conduisent à des notations différentes rendent une **ambiguïté rapportée**, jamais tranchée en silence.
- C'est l'abduction pondérée (Hobbs et al.), avec des hypothèses que la preuve nomme et des concurrentes qu'elle
  garde.

**Le statut :** `etablie_sous_hypotheses`, avec H, les observations expliquées et les concurrentes dans la preuve.
**Jamais `etablie`.** Le codage en fait `conditionnel_par_inference`, en extension de `conditionnel_par_derivation`
(lot 3).

**Le vérificateur :**
- H ∪ G établit la requête ;
- chaque hypothèse est proposée par une connaissance de K à cette version, et explique les observations qu'elle dit ;
- H est admissible, conjointement satisfaisable et minimal ;
- les concurrentes déclarées sont bien des explications des mêmes observations.

**Les contre-exemples du banc :**
- « un geôlier tourne la clé » : l'emprisonnement explique le geôlier et la clé, mais ne rend rien `etablie` ;
- « un moine aux cheveux longs » : l'hypothèse d'une tonsure figurée est contredite ;
- « un portrait de mariage » : des mariés, non une noce figurée en cours ;
- une hypothèse qui ne rend compte d'aucune assertion du texte, mais satisferait la requête : rejetée ;
- deux explications concurrentes au même coût (deux saints portant le même attribut) : une ambiguïté rapportée ;
- deux hypothèses qui demandent deux sens d'une même occurrence : jamais dans la même explication.

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
