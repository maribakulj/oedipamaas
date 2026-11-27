# Révision de reference_quantification après la relecture B

**Ce qui a servi :**
- `docs/BANCS_PHASE1.md`, § 4 (les valeurs admises) et § 4.1 (nouveau) ;
- les lignes `rq-` de `relecture_B.md`.

**La version 1** est gardée à part, hors du dépôt : `scratchpad/rq/v1.json`. Les numéros « #n » sont ceux de la
relecture : la n-ième variante, en comptant à partir de 1.

**Le bilan :**
- 24 cas de base, 159 variantes (152 avant) ;
- 0 erreur au validateur, quotas atteints ;
- `decision_ouverte` : 4 avant, 8 après.

## 1. Les désaccords de la relecture

### 1.1 Sûreté

| désaccord | décision | ce qui change, ou pourquoi |
|---|---|---|
| **rq-023** (et #1, #2, #6) : la négation va dans le mauvais sens | **corrigé** | `ecartee` → `inconnue`, et la sorte devient `contre_modele`. La relecture a raison : « seulement des saintes femmes » implique « seulement des femmes », et sa négation ne dit rien de la seconde (FS § 3.3). La définition dit aussi « tomb » au lieu de « sepulchre » : dans WordNet, sepulchre ⊑ tomb (@ 03455033), et l'inclusion inverse n'existe pas. #3 reste `etablie` : « ne se tiennent que les saintes femmes » implique « seulement des femmes ». |
| **D30, systémique : rq-007** (embrace, 3 sens) | **corrigé** | Base, #1, #2 et #6 passent de `ecartee` à `inconnue`. Une `decision_ouverte` est ajoutée : `tous_les_sens` donne `inconnue`, `sens_fixe_par_le_contexte` donne `ecartee`. On retient le plus prudent (§ 4.1, 2). |
| **D30, systémique : rq-022#5** (alone, 4 sens) | **corrigé** | `ecartee` → `inconnue`. La même question est posée, mais une variante ne peut pas porter de `decision_ouverte`. |
| **rq-024** (et #1, #2, #6, #7) : Gethsemane, dorment / asleep | **corrigé** | La définition devient « Peter sleeping while Christ prays » : Gethsemane est absent de WordNet, et le jardin n'était pas requis. #1 dit « sleeping ». Le cas de base français dépend aussi des alias Pierre / Peter et Jean / John, non attestés : `etablie` → `etablie_sous_hypotheses` [identite], avec une `decision_ouverte`. Mêmes changements pour #2, #6 et #7. #1, en anglais, reste `etablie` : la distinction documentaire Peter / John a sa source, deux synsets d'instances. |
| **rq-015** (et #1, #2, #6) : un membre agit, le prédicat est collectif | **corrigé** (la définition) | La définition dit ce que le texte décrit : « Lot given wine by one of his two daughters ». Il ne reste aucun prédicat de groupe, donc aucune lecture distributive ou collective à choisir. La base, #2 et #6 restent `etablie`. #1 (Loth, en français) passe à `etablie_sous_hypotheses` [identite], faute d'alias attesté. |
| **rq-008#5** : le fragment compte les figures conservées | **corrigé** | `ecartee` → `inconnue`. La variation devient `changement_de_portee` : c'est bien un fait de l'œuvre lacunaire (FS § 2.5). |
| **rq-016** : strike n'implique pas fight | **corrigé** (la définition) | La définition devient « Heracles striking the Hydra with his club ». Le statut change pour une autre raison, au § 2 : l'alias Hercule / Heracles, en français, n'est pas attesté. |
| **rq-010#3** : « set a single crown » n'est pas le verbe crown | **corrigé** | Le texte devient « Together, the two angels crown her with a single crown ». Le statut `etablie` reste. |
| **rq-009#3** : grief contre grieving, deathbed contre bier | **corrigé** | Le texte et la définition sont réécrits : « lies on a bier », « stand at the bier, grieving », « each of them grieves ». La définition devient « St Peter grieving at the bier on which the Virgin lies ». #3 reste `etablie`. |
| **rq-011#3** : l'Enfant contre the Christ Child | **corrigé** (la définition) | La définition dit « to the Child ». « Enfant » → child est un mot commun, qui passe par WOLF (implicite, § 4.1, 1). |
| **rq-019** (et #1, #2, #6) : « le Baptiste » sans ressource | **corrigé** | L'alias passe à `attestee: false` : le seul sens de baptist est « follower of Baptistic doctrines ». La restriction de sélection de « de » (partie, et non possession) n'est pas attestée non plus : c'est un choix de sens. Le statut passe de `etablie` à `etablie_sous_hypotheses` [identite, sens], avec une `decision_ouverte` (`tous_les_sens`, `sens_fixe_par_le_contexte`, et `sens_fixe_par_le_contexte_et_alias_atteste` → `etablie`). L'implication hand ⊑ give est retirée : elle était inutile, puisque la définition dit hand. |
| **rq-006#2** : « le mari et sa femme » n'est pas une collection | **corrigé** | La paraphrase garde le nom de collection : « Les deux époux, le mari et sa femme, sont assis… ». La définition devient « two spouses seated side by side… ». Dans WordNet, married_couple n'est relié à spouse que par une méronymie de membre (%m), qui n'est pas implicite. |
| **rq-002#4** : « à sa droite » a deux antécédents, l'évêque et l'autel | **corrigé** | Le texte de la base et des variantes dit « à la droite de l'évêque ». Seul « Il » reste ambigu, et c'est le phénomène du cas. La définition dit « raising » : dans la traduction, raise et elevate n'ont qu'un synset commun. |
| **faible : rq-012** : enormous contre huge, slung from contre on a pole | **corrigé** | La définition devient « the two spies jointly carrying a bunch of grapes on a pole ». Le texte dit « on a pole », et « jointly » des deux côtés : together n'est pas dans les synsets de jointly. |

### 1.2 Connaissance non fondée

| désaccord | décision | ce qui change, ou pourquoi |
|---|---|---|
| **rq-002** : méta-énoncé posé en implication attestée | **corrigé** | L'entrée « aucune connaissance de K n'exclut… » est retirée. |
| **alias de traduction : rq-003, rq-015, rq-018, rq-021, rq-022, rq-024** | **corrigé** | Chaque alias français passe à `attestee: false`, avec la mention « aucune ressource consultée ». Les statuts qui en dépendent passent à `etablie_sous_hypotheses` [identite] : la base de rq-003, 016, 019 et 024, et des variantes françaises (voir la liste du § 3). Une `decision_ouverte` à deux options (`alias_atteste` → `etablie`, `alias_non_atteste` → `etablie_sous_hypotheses`) est posée sur chaque cas de base qui en dépend. rq-018, rq-021 et rq-022 n'en ont pas : leur base n'en dépend pas. |
| **rq-006** : l'orientation est attestée sans ressource | **corrigé** | L'entrée est retirée : elle était superflue. Il ne reste que husband, wife ⊑ spouse, avec leur source. |
| **rq-020** : « John, nom partiel de deux individus » est une connaissance de rédaction | **corrigé** | L'entrée passe à `attestee: false` : WordNet ne donne John que pour l'apôtre et pour le roi Jean. La distinction documentaire Baptiste / évangéliste est retirée : elle ne servait pas. Le statut, `etablie_sous_hypotheses` [identite, connaissance_typique], ne change pas. |

### 1.3 Incohérence

| désaccord | décision | ce qui change, ou pourquoi |
|---|---|---|
| **rq-004#6 ; rq-021#5** : `ajout_figure_non_liee` pour une figure liée | **corrigé** | La variation devient `composition`. Les statuts restent : `inconnue` et `contradictoire`. |
| **rq-008#5 ; rq-013#3** : un changement de nombre nommé `changement_de_participant` | **corrigé** | rq-008#5 devient `changement_de_portee`, rq-013#3 devient `composition`. |
| **rq-003#4** : le marché de 1512 serait une source sur l'image (`non_certifiee`) | **contesté** | Un marché passé avant l'œuvre nomme le personnage à peindre. C'est un fait de l'histoire (portée `histoire`), non le témoignage d'une source sur ce que l'image montre, comme un inventaire (rq-007#5) ou un restaurateur (rq-008#4). NOYAU § 1 : aucun état hors du contexte demandé. Dans le doute, BANCS § 4.1 tient `inconnue` pour plus prudent que `non_certifiee`. Le statut reste `inconnue`. |
| **traductions dont le besoin en K diffère : rq-024 / #1** | **constaté, non corrigeable ici** | La base française demande les alias Pierre / Peter, non attestés : `etablie_sous_hypotheses`. La traduction anglaise ne les demande pas : `etablie`. Il en va de même pour rq-003 / #1, rq-016 / #1 et rq-015 (#1 en français). L'invariance de traduction (QS § 2.2) n'est assurée que si l'alias est réellement dans K. C'est un écart attendu, dû à K, à signaler à la mesure métamorphique. |

### 1.4 Décision ouverte mal posée

| désaccord | décision | ce qui change, ou pourquoi |
|---|---|---|
| **rq-014** (et #1, #2, #6, #7) ; **rq-013#3** : nombre exact ou au moins douze ? | **contesté** | La sémantique cible fixe la lecture : « the twelve apostles » est une collection avec son nombre (FS § 2.6 : « un référent de groupe, ses membres quand ils sont dits, son nombre » ; les quantifications énoncées, « exactement n »). Un groupe dont le nombre dit est dix a un appui négatif de nombre(X, 12) sous cette liaison (NOYAU § 4.1). L'écartement vaut pour ce référent seulement (D31). « Au moins k par k variables distinctes » (AUDIT § 3.4) est une approximation du langage actuel, non la sémantique cible. Ce n'est pas non plus D30 : un nombre est une contrainte, non un mot nié. Ma question Q11 était mal posée : elle portait sur la compilation, non sur la cible. Le statut reste `ecartee`, de même pour rq-013#3. |
| **rq-017** : l'identité Minerva = Athena n'explique aucune observation | **corrigé** | La `decision_ouverte` est retirée. La glose « counterpart of » est une relation inconnue, qui ne permet que l'abduction (FS § 2.7). Une hypothèse qui n'explique aucune observation est inadmissible (SPEC § 4). Le statut `inconnue` est fixé. L'extension devient `contenu_d_inscription` (§ 4.1). Différence avec les alias de traduction (§ 1.2) : ceux-là sont écrits dans K comme des identités non attestées, et une équivalence non attestée donne au mieux `etablie_sous_hypotheses` (BANCS § 4). Le sort d'une hypothèse d'identité dépend donc de la sorte de l'entrée de K, ce que les documents ne disent pas explicitement. |

### 1.5 Qualité

| désaccord | décision | ce qui change, ou pourquoi |
|---|---|---|
| **rq-002, 005, 009, 010, 011, 017, 020** : aucune variante ne change de statut par la portée, la modalité, le temps ou l'inversion | **corrigé** | Une variante est ajoutée à chacun. `changement_de_portee` vers `non_certifiee` (une source citée parle de l'image) pour rq-002, 005, 009, 010 et 011. rq-017#4 passe au catalogue qui dit « Athena » (`non_certifiee`). rq-020 reçoit une variante `changement_de_modalite` (« what may be a lamb » : `inconnue`). |
| **rq-002#3, #5, #6** : les variantes ne mesurent rien | **contesté en partie** | Ces variantes testent des relations de sûreté : une inversion des rôles n'est jamais établie, une figure non liée conserve le statut (QS § 2.2). Elles deviennent observables dès qu'un moteur résout le pronom par défaut (par exemple vers l'antécédent le plus proche). Elles sont gardées. La variante de portée ajoutée (#7) donne au cas une variation dont l'effet se voit. |
| **rq-017#5** : la variante ne mesure rien | **corrigé** | Elle est remplacée par une variante de modalité, « perhaps Athena » (`inconnue`), à comparer avec #3 (Athena affirmé : `etablie`). |

## 2. Les autres changements faits par le § 4.1

- **Chaque connaissance `attestee: true` a une `source`.** Il en reste quatre :
  - rq-006 : husband et wife @ spouse ;
  - rq-009 : Peter @i Apostle ;
  - rq-016 : le synset 09578005, Hercules = Heracles ;
  - rq-024 : deux synsets d'instances, Peter et John.
- **Ont été vérifiés dans data.noun :** les offsets, les pointeurs `@` et `@i`, et les clés d'index.sense.
- **Tout le reste passe à `attestee: false`,** ou est retiré :
  - les alias de traduction ;
  - « le Baptiste » ;
  - la restriction de sélection de « de » ;
  - l'entrée « John » de rq-020 ;
  - la glose de Minerva (déjà fausse) ;
  - les connaissances typiques (déjà fausses).
- **Les connaissances retirées, parce qu'inutiles ou de rédaction :**
  - rq-002 : le méta-énoncé ;
  - rq-006 : l'orientation ;
  - rq-010 : Virgin = Mary, inutile puisque la définition dit « the Virgin », comme le texte. Le synset 11161412 l'attesterait d'ailleurs.
  - rq-019 : hand ⊑ give ;
  - rq-020 : la distinction documentaire.
- **Un alias pour une variante seulement :** rq-004. La base anglaise n'en a pas besoin, mais la traduction française (Jérôme) le demande. L'entrée est écrite dans K, non attestée, et #1 passe à `etablie_sous_hypotheses` [identite].
- **Les écarts lexicaux trouvés en appliquant la règle,** hors de la relecture :
  - rq-006#1 : « sit » contre « seated » ;
  - rq-008#1 : « naked » contre « nude » (un même synset, mais naked a d'autres sens) ;
  - rq-002 : raise contre elevate.
  Les textes ont été alignés.
- **Une variante ajoutée qui fait écarter par un nom nié :** rq-004#7, « not Saint Jerome … but Saint Onuphrius », `ecartee`. La négation d'un nom n'est pas touchée par D30 (NOYAU § 1.1 : une clé niée). La famille garde ainsi des `ecartee` qui ne dépendent pas du choix d'un sens : rq-014, rq-004#7, rq-013#3.
- **Le régime des sens, tel que je l'ai appliqué, et ses limites :**
  - **une négation d'un mot polysémique :** `inconnue`, avec une `decision_ouverte` sur la base (rq-007), ou sans elle sur une variante (rq-022#5) ;
  - **un lien positif où le texte et la définition emploient le même lemme anglais :** je le tiens pour certain par D30. Chaque sens du mot atteint le lemme par la lexicalisation (`sous`, NOYAU § 2). Si les définitions étaient compilées vers un sens fixé et non vers un mot, presque tous les cas `etablie` de toutes les familles passeraient à `etablie_sous_hypotheses` [sens]. C'est une question à trancher, et je ne l'ai pas tranchée en silence ;
  - **un mot français :** je l'ai tenu pour passé par WOLF au sens qui correspond au mot anglais de la définition (§ 4.1, 1 : implicite). Je n'ai pas pu consulter WOLF : je ne sais pas si « élever », « seul » ou « tendre » y ont d'autres sens qui n'atteignent pas le lemme anglais. Les cas français en dépendent tous ;
  - **le choix du sens d'une préposition :** `etablie_sous_hypotheses` [sens] (rq-019).
- **Les incompatibilités :** aucun cas de la famille n'en dépend. Les variantes où une incompatibilité aurait joué (rq-006#3, rq-011#4, rq-012#3, rq-023) étaient déjà `inconnue`.

## 3. Les statuts changés

**Les cas de base :** 6 changements, tous vers un statut plus faible.
- rq-003, rq-016, rq-019 et rq-024 : `etablie` → `etablie_sous_hypotheses`.
- rq-007 et rq-023 : `ecartee` → `inconnue`.

**Les variantes :** 24 vers un statut plus faible, 1 vers un statut plus fort.
- **Vers un statut plus faible :**
  - `etablie` → `etablie_sous_hypotheses` : rq-003#2, #6 ; rq-004#1 ; rq-015#1 ; rq-016#2, #6, #7 ; rq-018#3 ; rq-019#1, #2, #6 ; rq-021#1 ; rq-022#3 ; rq-024#2, #6, #7.
  - `ecartee` → `inconnue` : rq-007#1, #2, #6 ; rq-008#5 ; rq-022#5 ; rq-023#1, #2, #6.
- **Vers un statut plus fort :** rq-017#4, `inconnue` → `non_certifiee`. Son texte a changé : le catalogue dit maintenant « Athena ».

**Les variantes ajoutées :** 7, soit rq-002#7, rq-004#7, rq-005#7, rq-009#7, rq-010#7, rq-011#8 et rq-020#7.

**Les sortes des cas de base :**
- 13 positifs ;
- 6 négatifs ou contre-modèles (2 négatifs, 4 contre-modèles) ;
- 5 indéterminés.

## 4. Harmonisation : le régime des sens de BANCS § 4.1, point 2

**Ce que dit « Ce que D30 dit exactement » :**
- un mot de la définition est un type lemme ;
- un lien positif est certain si **chacun** des sens du mot du texte atteint ce lemme (par `@` et `@i`, puis par la lexicalisation) ;
- pour un mot français, ces sens sont ceux de WOLF.

**Comment je l'ai vérifié.** Pour chaque mot dont dépend un atome de la définition, dans la base et dans chaque variante
de statut positif, j'ai calculé si chaque sens atteint le lemme. Les sens français viennent de `sens_fr.py` ; les
fermetures d'hyperonymie et d'instance sont calculées sur `data.*` de WordNet 3.0.
- Le script de contrôle, hors du dépôt : `scratchpad/rq/atteint.py`.
- La version d'avant l'harmonisation : `scratchpad/rq/v2_avant_harmonisation.json`.
- Aucune définition n'a été réécrite.

**Le résultat :**
- **cas de base :** 4 statuts plus faibles, 0 plus fort. Les hypothèses changent dans 3 autres cas : [sens] y est ajouté.
- **variantes :** 20 statuts plus faibles, 0 plus fort. Les hypothèses changent dans 13 autres variantes, dont une
  qui en perd une ([sens] retiré à rq-019#1).
- **variantes ajoutées :** 4. Elles redonnent une variante qui change de statut, là où toutes les variantes françaises
  sont devenues `inconnue`.
- **decision_ouverte :** 10.

**Ce que dit la vérification, mot par mot :**
- **Le même lemme anglais des deux côtés est certain.** Les cas anglais de base (rq-001, 004, 012, 014, 015, 020, 021)
  ne changent pas.
- **Presque tous les mots français ont, dans WOLF, un sens qui n'atteint pas le lemme anglais :**
  - tenir → hold : 33 sur 52 ;
  - élever → raise : 18 sur 26 ;
  - crâne → skull : 1 sur 2 (cranium hors) ;
  - calice → chalice : calyx hors ;
  - jeune → young : 2 sur 11 ;
  - porter → carry : 33 sur 42 ;
  - Grâce → grace : 5 sur 10 ;
  - nu → nude : 1 sur 12 ;
  - prier → pray : 2 sur 8 ;
  - frapper → strike : 8 sur 12 ;
  - offrir → offer : 14 sur 35 ;
  - fille → daughter : 1 sur 9 ;
  - donner → give : 53 sur 102 ;
  - tente → tent : 1 sur 2 ;
  - montrer → point : 6 sur 23 ;
  - femme → woman : 7 sur 8 ;
  - époux → spouse : marriage hors.
  D'où l'hypothèse `sens`, avec une `decision_ouverte` (`tous_les_sens` / `sens_fixe_par_le_contexte`) sur les cas de
  base.
- **Sont certains :** évêque, diacre, mari, assis, gauche, lire, pénitent, hydre, massue, prêcher, agneau, crucifix,
  tombeau, dormir, apôtre, vin, raisin, espion, Christ.
- **Certains mots n'atteignent jamais le lemme,** ou n'ont aucun sens dans WOLF. Le statut devient `inconnue`. C'est un
  pas lexical, que le cas garde :
  - « frapper » → beat : 0 sur 12 ;
  - « tendre » → hand : 0 sur 9 ;
  - « droite » → right : WOLF n'a que des sens de ligne ;
  - « tenir » → stand : 0 sur 52, et « se tenir » n'a pas d'entrée ;
  - « personnifier » : aucune entrée ;
  - « côte à côte » : aucune entrée, ni side_by_side dans WordNet ;
  - hold → with : la définition de rq-017 dit « with spear and shield ».

**Les statuts changés, et pourquoi :**

| cas ou variante | avant | après | pourquoi |
|---|---|---|---|
| rq-006 (base), #2, #6 | `etablie` | `inconnue` | « côte à côte » n'a aucun sens WOLF. Une `decision_ouverte` dit `etablie` si le sens est fixé par le contexte. La sorte de la base devient `indetermine`. |
| rq-008 (base), #2, #7 | `etablie` | `etablie_sous_hypotheses` [sens] | Grâce et nu, avec une `decision_ouverte`. |
| rq-013 (base), #2, #6, #7 | `etablie` | `inconnue` | « personnifier » est absent de WOLF, avec une `decision_ouverte`. La sorte devient `indetermine`. #3 reste `ecartee` : c'est un nombre, sans lien lexical. |
| rq-019 (base), #2, #6 | `etablie_sous_hypotheses` | `inconnue` | Aucun sens de « tendre » n'atteint hand. La `decision_ouverte` est retirée : le statut ne dépend plus d'aucun choix. La sorte devient `indetermine`. |
| rq-003, rq-016, rq-024 (bases) et leurs variantes françaises | `etablie_sous_hypotheses` [identite] | `etablie_sous_hypotheses` [identite, sens] | Le statut ne change pas. La `decision_ouverte` combine désormais l'alias et le sens. |
| rq-001#2, rq-005#5, rq-011#3, rq-012#1 | `etablie` | `etablie_sous_hypotheses` [sens] | Des mots français. |
| rq-012#2 | `etablie` | `etablie_sous_hypotheses` [sens] | bear → carry : 5 sens sur 13. |
| rq-015#1, rq-021#1, rq-022#3 | — | [identite, sens] | Le sens s'ajoute à l'alias. rq-022#4 avait déjà [identite, sens]. |
| rq-020#1 | — | [identite, connaissance_typique, sens] | « montrer ». |
| rq-004#1 | `etablie_sous_hypotheses` | `inconnue` | frapper → beat. |
| rq-002#4 | `etablie` | `inconnue` | droite → right. |
| rq-002#7 | `non_certifiee` | `inconnue` | La relation de position n'a aucun appui. |
| rq-017#3 | `etablie` | `inconnue` | hold → with. |
| rq-017#4 | `non_certifiee` | `inconnue` | hold → with. |
| rq-023#3 | `etablie` | `inconnue` | se tenir → stand. |
| rq-019#1 | [identite, sens] | [identite] | Le statut ne change pas ; c'est l'hypothèse qui disparaît. « of » est le même lemme dans la traduction et dans la définition : traiter « of » comme un sens choisi était une erreur, corrigée. |

**Les variantes ajoutées** emploient les lemmes de la définition ; aucune définition n'a été réécrite :
- rq-002#8 (`composition`) : `etablie` ;
- rq-002#9 (`changement_de_portee`) : `non_certifiee` ;
- rq-017#7 (`changement_de_participant`) : `etablie` ;
- rq-023#7 (`changement_de_modalite`) : `etablie`.

**Ce que je n'ai pas soumis à la règle, et pourquoi :**
- **les prépositions seules** (de, devant, sur, à) : elles ne sont ni dans WordNet ni dans WOLF. Leur sens est une
  affaire de K (FONDEMENTS § 2.4), une question ouverte. Le choix de « de » (partie ou possession) de rq-019 reste
  une hypothèse dans la base, désormais `inconnue` pour une autre raison ;
- **« alone », « seul », « seulement » :** je les compile en quantification énoncée (FONDEMENTS § 2.6), non en type
  lemme. Leurs sens n'ont donc pas été comptés, sauf la portée de l'exclusivité dans rq-022#4.

**Les cas de base, par statut, après l'harmonisation :**

| statut | nombre | cas |
|---|---|---|
| `inconnue` | 13 | rq-002, 005, 006, 007, 009, 010, 011, 013, 017, 018, 019, 022, 023 |
| `etablie` | 5 | rq-001, 004, 012, 015, 021 |
| `etablie_sous_hypotheses` | 5 | rq-003, 008, 016, 020, 024 |
| `ecartee` | 1 | rq-014 |

**Les sortes :**
- 10 positifs (42 %) ;
- 6 négatifs ou contre-modèles (25 %) ;
- 8 indéterminés (33 %).
