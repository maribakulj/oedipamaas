# La trajectoire d'implémentation (version 1, 27/11)

**Ce qui est proposé.** Un ordre de travail qui préserve les acquis du noyau. Chaque phase :
- a une spécification écrite avant le code ;
- a son banc (`docs/QUALIFICATION_SEMANTIQUE.md`), qui échoue avant elle ;
- étend l'oracle et le moteur de référence quand elle touche à la logique ;
- est mesurée sur les jeux de développement avancé **sans y être réglée**.

Aucune phase ne vise une métrique. Une phase est finie quand son banc passe, que ses mutants sont détectés et qu'aucune
sûreté n'est perdue ailleurs.

**Ce qui ne bouge pas :** la logique du noyau (Belnap, certification, identité, supervaluation des sens, lectures
conjointes), le vérificateur indépendant, l'oracle et le principe « la précision d'abord ».

## Phase 0 — les instruments (faite le 27/11)

- **La mesure de l'admissibilité effective** des prémisses, selon le noyau (`outils/graphes/premisses.pl`).
- **La présence des textes** dans les comparaisons appariées (`apparier.py`).
- **La monotonie mise à l'épreuve,** et corrigée (`tests/plunit/test_monotonie.pl`).
- **Le jeu de qualification indépendant,** tiré et scellé.
- **L'audit de l'expressivité** et les fondements sémantiques.

## Phase 1 — les bancs par famille, avant tout code (à valider)

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

## Phase 4 — la classification par dépliage des définitions

**Ce qui est à faire :**
- les définitions d'une ressource (les gloses de WordNet d'abord), **compilées en requêtes par le compilateur des
  libellés** ;
- chacune étiquetée équivalence ou typique, d'après une mesure par famille ;
- le dépliage côté requête pour les équivalences, avec sa terminaison vérifiée et la définition citée par la preuve ;
- le comparateur d'inclusion, pour vérifier le dépliage ;
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

## Phase 6 — l'ancrage temporel et les contextes de contenu (extensions du langage d'assertions)

**Ce qui est à faire :**
- la version 2 de `docs/ASSERTIONS.md` ;
- **l'ancrage des événements :** en cours, antérieur, imminent ;
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
- `abduire/5` (§ 4 de la spécification) : des hypothèses dirigées, admissibles, conjointes, minimales, à coûts fixés à
  l'avance ;
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

- la narration continue (plusieurs moments figurés) et les relations d'ordre entre événements figurés ;
- les espèces et les génériques ;
- le contenu textuel des inscriptions ;
- toute ressource produite par un grand modèle de langue ;
- tout générateur neuronal de candidats qui limiterait ce que le moteur examine.
