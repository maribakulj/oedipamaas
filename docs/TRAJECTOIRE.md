# La trajectoire : l'ordre de spécification et l'ordre de réalisation (version 1.1, 27/11)

**Ce qui est proposé.** Un ordre de travail qui préserve les acquis du noyau. Chaque phase :
- a une spécification écrite avant le code ;
- a son banc (`docs/QUALIFICATION_SEMANTIQUE.md`), qui échoue avant elle ;
- étend l'oracle et le moteur de référence quand elle touche à la logique ;
- est mesurée sur les jeux de développement avancé **sans y être réglée**.

Aucune phase ne vise une métrique. Une phase est finie quand son banc passe, que ses mutants sont détectés et qu'aucune
sûreté n'est perdue ailleurs.

**Ce qui ne bouge pas :** la logique du noyau (Belnap, certification, identité, supervaluation des sens, lectures
conjointes), le vérificateur indépendant, l'oracle et le principe « la précision d'abord ».

## Deux ordres distincts

**La précision de la propriétaire** (quatrième message, § 5) : distinguer l'ordre de spécification de l'ordre de
réalisation. La réification des états, les contextes, la temporalité et les modificateurs non intersectifs doivent être
**spécifiés assez tôt** pour guider la canonisation et la déduction, même s'ils sont **réalisés** plus tard.

**L'ordre de spécification,** chaque point écrit et soumis avant que le suivant ne soit figé :

| rang | ce qui est spécifié | document | ce qu'il guide |
|---|---|---|---|
| S1 | l'ontologie des éventualités : propriétés, états, processus, événements de changement, situations | `docs/ONTOLOGIE_EVENTUALITES.md` (étude faite ; syntaxe à fixer) | la canonisation des états et des noms d'action ; les bancs |
| S2 | les contextes : l'emboîtement, ceux qu'ouvre une éventualité, l'accessibilité, les valeurs par contexte | une version 2 de `docs/ASSERTIONS.md`, puis une version 0.4 de `docs/NOYAU.md` | l'admissibilité ; les contenus ; les représentations emboîtées |
| S3 | la temporalité : l'ancrage relatif à une situation, plusieurs situations, la narration | idem | la déduction des états résultants ; la narration |
| S4 | les modificateurs non intersectifs, privatifs ou de mode d'existence ; les extensions réelle et figurée | idem | la classification ; les créatures fictives |
| S5 | la quantification énoncée : collections, domaines, exceptions, distributivité | idem | les libellés exclusifs ; « tous », « chacun » |
| S6 | la canonisation et la déduction, sur S1 à S5 | `docs/SPECIFICATION_OPERATIONS.md`, révisée | la phase de canonisation |
| S7 | la base de définitions conceptuelles et la classification | idem | le dépliage |
| S8 | l'abduction explicative | idem | l'abduction |

**L'ordre de réalisation** est celui des phases ci-dessous. Il peut commencer plus tôt pour ce qui ne dépend pas de S2 à
S5 : les bancs, la canonisation sur le langage actuel, `non/1`. Il ne réalise une extension qu'une fois **sa
spécification et son banc validés**.

**La conservation du noyau n'est pas un principe contre une extension démontrée nécessaire** : S2 à S5 touchent le
langage et, par sa spécification, le noyau.

## Phase 0 — les instruments (faite le 27/11)

- **La mesure de l'admissibilité effective** des prémisses, selon le noyau (`outils/graphes/premisses.pl`).
- **La présence des textes** dans les comparaisons appariées (`apparier.py`).
- **La monotonie mise à l'épreuve,** et corrigée (`tests/plunit/test_monotonie.pl`).
- **Le jeu de qualification indépendant,** tiré et scellé.
- **L'audit de l'expressivité** et les fondements sémantiques.

## Phase 1 — les bancs par famille, avant tout code (lancée le 27/11)

- **Les cas de base et leurs variations,** écrits d'après les fondements et la spécification des opérations, pour les
  huit familles. La moitié de chaque banc est mise sous scellé.
- **Le jugement humain d'un échantillon** (D23).
- **La fin de la phase :** les bancs sont validés par la propriétaire.
- **Ce qui ne se fait pas encore :** aucune règle, aucune extension.

## Phase 2 — la canonisation commune, sur le langage actuel

**Ce qui est à faire :**
- la table des **équivalences** (§ 1 de la spécification des opérations), appliquée des deux côtés ;
- la forme canonique fixée pour chaque paire : nom d'action et événement, nom d'état et propriété, pronominal ;
- le guide du banc mis à jour ;
- la symétrie vérifiée par un test, chaque règle sur un graphe et sur une requête ;
- la reprise des corrections fondées de C3 (la contre-expertise de #16) dans ce cadre.

**Pourquoi d'abord :** la représentation est la première cause des échecs de l'expérience croisée, et cette phase ne
demande aucune extension du langage.

**Ce qui la limite :** une équivalence n'est certaine que pour un sens. Tant que les sens ne sont pas choisis, la
canonisation reste sous hypothèse de sens (D30). C'est mesuré, non contourné.

## Phase 3 — la négation dans les requêtes (`non/1`)

**Ce qui est à faire :**
- la version 0.4 de `docs/NOYAU.md` : `non(A)` est vrai sous σ si A a un appui négatif de l'auteur, certifiable,
  jamais par absence ;
- le moteur de référence, l'oracle et le moteur optimisé ;
- le vérificateur (une preuve cite l'appui négatif) ;
- le comparateur d'inclusion (la transmission de la négation, dans l'autre sens) ;
- l'injection de défauts ;
- le compilateur : les exclusions des libellés (« without », « not harmed »).

**Pourquoi tôt :** l'extension est petite, la logique qui calcule les appuis négatifs existe, et environ 5 % des
libellés en dépendent.

## Phase 4 — la base de définitions conceptuelles, et la classification par dépliage

**Ce qui est à faire :**
- **la base de définitions conceptuelles** (`docs/FONDEMENTS_SEMANTIQUES.md`, § 2.7) :
  - des entrées par **sens**, à **structure** (des motifs d'assertions typés par des sens), partagées par les notations
    qui emploient le concept ;
  - les gloses d'une ressource (WordNet d'abord) compilées en structures par le compilateur des libellés ;
- **le statut de chaque entrée, par direction :** équivalence établie, condition suffisante, condition nécessaire,
  typique, relation inconnue.
  - Il n'est établi que par une **attestation** (la ressource et une validation). Le défaut est « relation inconnue ».
  - L'absence de contre-exemple dans K n'établit rien ; le comparateur d'inclusion sert à trouver des contre-exemples,
    non à prouver une équivalence ;
- **le dépliage côté requête** pour les entrées suffisantes ou équivalentes établies, avec sa terminaison vérifiée et
  l'entrée citée par la preuve ;
- le banc « définitions et classification », dont les faux positifs de la couche D (le moine pour la tonsure) sont des
  contre-exemples.

**Ce qui ne change pas :** le noyau, puisque c'est une réécriture de requête.

## Phase 5 — les dérivations avec provenance, et leur statut

**Ce qui est à faire :**
- le terme `derive/6` dans les preuves ;
- le vérificateur qui refait chaque dérivation ;
- le statut `conditionnel_par_inference` du codage, en extension de `conditionnel_par_derivation` (lot 3) ;
- les connaissances séparées par sorte (implication, conséquence conditionnelle, typique), avec leur direction de
  négation ;
- les lectures conjointes étendues aux sources des dérivations ;
- **la déduction seulement :** implications et conséquences conditionnelles à condition établie.

Le prototype `outils/inference/` est la base d'essai, non la réalisation.

## Phase 6 — les éventualités, les contextes, le temps, les modificateurs, la quantification (extensions du langage)

Elle réalise S1 à S5. Leur spécification, elle, vient plus tôt (§ « Deux ordres distincts »).

**Ce qui est à faire :**
- la version 2 de `docs/ASSERTIONS.md` ;
- **les états réifiés,** distincts des propriétés ordinaires, et les situations comme référents d'une sorte propre ;
- **l'ancrage des éventualités** par rapport au moment de leur situation (en cours, antérieure, imminente), et
  plusieurs situations par œuvre ;
- **les modificateurs non intersectifs,** privatifs ou de mode d'existence ;
- **les collections et les quantifications énoncées ;**
- **les rôles dont la valeur est un événement,** avec le contexte du contenu (ordre, tentative, vision, rêve, parole,
  inscription) ;
- **les référents conceptuels** et les relations de figuration ;
- la règle d'admissibilité réécrite pour des chemins de contextes (§ 2.5 des fondements), puis la version du noyau qui
  la reçoit, avec l'oracle, le moteur de référence et le vérificateur ;
- le lecteur et le compilateur qui produisent ces termes.

**Pourquoi après :** c'est la phase la plus large. Elle touche les trois langages, et elle ne vaut que si les phases 2
à 5 ont montré, sur leurs bancs, que le reste tient.

## Phase 7 — l'abduction

**Ce qui est à faire :**
- `abduire/4` (§ 4 de la spécification) : des **explications d'éléments observés**, chacune fondée sur une connaissance
  identifiée, admissible, conjointe, minimale, à coûts fixés à l'avance, et comparée aux explications concurrentes
  (une ambiguïté est rapportée, non tranchée) ;
- des connaissances typiques réutilisées : les « possible attributes » d'Iconclass, FrameNet (relations entre cadres),
  ConceptNet en module à licence séparée ;
- **jamais `etablie` :** toujours `etablie_sous_hypotheses`.

## Phase 8 — la lecture alignée sur la représentation

Elle court en parallèle des phases 2 à 7 :
- la sûreté du lecteur (X1 à X3) continue, désactivée par défaut tant que le jalon n'est pas atteint ;
- la désambiguïsation (X7), dont dépendent le jalon et la déduction ;
- les rôles et les relations (X4, X6) ;
- la production des termes des extensions de la phase 6.

## Phase 9 — la qualification

**Ce qui est à faire :**
- la qualification sur les familles de définitions (§ 3 du plan), puis le jeu indépendant (§ 4), une seule fois,
  après la validation des bancs ;
- les baselines, mesurées sur les mêmes jeux.

**La décision des phases suivantes** se prend sur ces mesures.

## Ce qui est volontairement différé

- **la réalisation** de la narration continue, de la juxtaposition d'épisodes et de l'identité d'un personnage à
  travers les situations. Elles ne sont **pas exclues** par la représentation (S1, S3), et les bancs les couvrent
  dès la phase 1 ;
- les espèces et les génériques ;
- le contenu textuel des inscriptions ;
- toute ressource produite par un grand modèle de langue ;
- tout générateur neuronal de candidats qui limiterait ce que le moteur examine.
