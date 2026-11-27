# Le plan de qualification sémantique (version 1, 27/11)

La demande (troisième message de la propriétaire, § 6) : ne pas faire des 74 échecs de l'expérience croisée la liste
des cas à faire passer par de nouvelles règles. Ils servent de **contre-exemples révélant des familles de problèmes**.

Ce plan prévoit :
- des **bancs systématiques indépendants**, un par famille ;
- une **qualification à grande échelle** sur les familles de définitions d'Iconclass ;
- **un jeu de qualification réellement indépendant,** préservé dès maintenant.

Les baselines lexicales et neuronales sont des comparaisons scientifiques. Elles ne dictent pas l'architecture.

## 1. Le statut des jeux existants

Les jeux déjà consultés sont désormais des **jeux de développement avancé** :
- le développement et la validation M1 (fiches, requêtes de référence, banc de graphes v1 et v2) ;
- les échantillons de mesure.

Aucune décision de qualification ne s'appuie plus sur eux. Ils servent à mettre au point et à diagnostiquer.

Les jeux scellés (`banc_qualif*`, `banc_scelle`) restent fermés. Ce plan ne les ouvre pas, et il ne les tient pas non
plus pour suffisants : ils ont été construits avant les familles de ce plan.

## 2. Les bancs par famille

Chaque famille de l'audit (`docs/AUDIT_EXPRESSIVITE.md`, § 3) a son banc. Un banc est **un ensemble de cas écrits à
partir d'une spécification**, avant toute réalisation.

### 2.1 Ce qu'est un cas

- **La forme :** un triplet (description, définition, statut attendu), avec le graphe attendu de la description et la
  requête attendue de la définition. On sépare ainsi l'erreur de lecture, l'erreur de compilation et l'erreur de
  raisonnement, comme dans l'expérience croisée.
- **Le statut attendu** est écrit d'après les fondements (`docs/FONDEMENTS_SEMANTIQUES.md`) et la spécification des
  opérations, **jamais** d'après la sortie du système.
- **Quatre sortes de cas :**
  - **positifs :** la définition est satisfaite ;
  - **négatifs :** le texte dit le contraire, ou une configuration voisine qui ne la satisfait pas ;
  - **indéterminés :** le texte ne permet pas de conclure ;
  - **contre-modèles :** un texte qui satisfait tout sauf la condition distinctive.

### 2.2 Les variations, sur chaque cas de base

| variation | ce qu'elle mesure | relation attendue (métamorphique) |
|---|---|---|
| paraphrase (lexicale, syntaxique : actif et passif, nominalisation, relative, apposition) | l'invariance de la canonisation | même statut |
| traduction (français, anglais) | l'invariance de la langue | même statut |
| changement de participant (un autre référent du même type, d'un autre type) | les rôles et les types | même statut, ou inconnu si le type ne convient plus |
| inversion des rôles | les rôles | jamais établie (un rôle inversé n'est pas une preuve négative) |
| changement de portée (dans l'image, sur l'œuvre, dans une source, une autre œuvre) | les contextes | non établie hors du figuré |
| changement de modalité (affirmé, possible, traditionnel, nié) | les modalités | établie seulement si affirmée ; écartée si niée (atome nié) |
| changement de temps (en cours, antérieur, imminent) | l'ancrage temporel (une extension) | selon la définition |
| ajout d'une figure non liée | la monotonie (hors identité) | statut conservé |
| ajout d'une négation non liée | l'indépendance des négations | statut conservé |
| composition de deux phénomènes (négation et partie ; modalité et rôle ; contenu d'une vision et personnification) | les interactions | écrit au cas par cas |

### 2.3 Les familles, et la taille visée

| famille | exemples de constructions | taille visée (cas de base × variations) |
|---|---|---|
| événements et états | nom d'action et verbe ; état et événement ; conséquence et événement ; processus et accompli | 60 × 8 |
| compositionnalité | adjectifs intersectifs, subsectifs, privatifs ; composés nominaux (matière, but, lieu, partie) ; participes de verbes inaccusatifs, inergatifs, causatifs | 80 × 6 |
| structures argumentales | patient et thème ; participants indirects ; direction, source, destination | 60 × 8 |
| référence et quantification | coréférence ; distributif et collectif ; nombres ; « seul », « tous » dits ; noms partiels | 60 × 6 |
| espace, partie, temps | prépositions polysémiques ; partie et tout ; avant et après | 60 × 6 |
| modalité, négation, contextes | négations atomiques et de descriptions ; alternatives ; sources ; contenus de vision, d'ordre, d'inscription | 80 × 8 |
| niveaux de représentation | personnifications, symboles, allégories ; œuvre et figuré ; titre | 40 × 6 |
| définitions et classification | une définition appariée (structure exacte, structure partielle, mots seulement) | 60 × 6 |
| phénomènes iconographiques | narration continue ; juxtaposition d'épisodes ; personnifications ; représentations emboîtées (tableau dans le tableau, vision, miroir) ; événement historique et événement figuré ; niveaux de signification ; identification de personnages (par le nom, par les attributs) | 60 × 6 |

**Les phénomènes composés** (décision de la propriétaire) sont substantiellement représentés, pour que le système ne
soit pas qualifié sur des cas isolés :
- au moins **40 % des cas de base** de chaque banc combinent deux phénomènes ou plus, dont au moins un d'une autre
  famille ;
- au moins **10 %** en combinent trois ou plus.
- Les compositions sont choisies dans une matrice famille × famille fixée à l'avance, couverte entièrement.

**Ce qui assure l'indépendance des bancs** (décision de la propriétaire : la séparation se fait **avant** la génération
des variantes, par cas de base, par familles lexicales et par constructions) :
1. **l'inventaire d'abord :** pour chaque famille, la liste des **constructions** (les réalisations d'un phénomène) et
   des **familles lexicales** (les fichiers lexicographiques de WordNet du mot pivot), écrite avant tout cas ;
2. **la répartition, ensuite, tirée avec une graine :** chaque construction et chaque famille lexicale est mise en
   développement ou en qualification (`outils/bancs/repartir.py`).
   - **Un cas de développement** n'emploie que des constructions et des familles lexicales de développement.
   - **Un cas de qualification** emploie au moins une construction ou une famille lexicale de qualification.
3. **les cas de base, puis seulement leurs variantes :** les variantes d'un cas (§ 2.2) restent dans son côté. Une
   paraphrase d'un cas de développement n'est jamais un cas de qualification ;
4. **les auteurs :** les cas sont écrits par des agents qui ne voient ni le code ni les sorties.
   - Les cas de développement sont écrits par des agents de la session de développement.
   - Les cas de qualification sont écrits par des agents d'une **autre session**, lancée par la propriétaire, qui ne
     reçoivent que l'inventaire, la répartition et le guide. Leurs sorties ne sont pas versées dans le dépôt (§ 4).
   - Un échantillon est jugé par la propriétaire (D23). L'accord entre agents n'est pas une validation humaine.

### 2.4 Les tests génératifs et métamorphiques

- **Les relations du § 2.2, tirées automatiquement** sur les graphes du banc de référence et sur des graphes tirés
  (comme `tests/plunit/test_monotonie.pl` le fait pour l'ajout d'une figure).
- **Pour chaque extension du langage :**
  - l'oracle Python (`tests/oracle/`) est étendu d'après la spécification seule ;
  - le moteur de référence est étendu ;
  - le différentiel est exigé sans désaccord, comme pour le noyau 0.3.
- **L'injection de défauts :** chaque règle de canonisation, chaque sorte de connaissance et chaque contrôle du
  vérificateur a un mutant qu'un banc doit détecter.

## 3. La qualification à grande échelle sur les familles de définitions d'Iconclass

**L'objet :** les définitions, non les textes. Le but est de savoir, pour chaque famille de libellés, si la requête
compilée dit ce que dit le libellé.

### 3.1 Les familles

Elles viennent de la typologie de `docs/FONDEMENTS.md`, § 3.2 :
- les rubriques ;
- les classes ;
- les scènes ;
- les individus, et les gabarits à nom ;
- les attributs et les parties ;
- les genres ;
- les concepts : personnifications et allégories ;
- les queues (« ~ », lettres doublées) et les clés.

### 3.2 La méthode

1. **Un échantillon stratifié :** une graine, un tirage par famille, proportionnel à la taille de la famille, avec un
   minimum de 50 libellés par famille. L'échantillon est tiré parmi les libellés qui n'ont servi à aucune mise au
   point (les jeux de développement sont exclus).
2. **Pour chaque libellé :**
   - une requête de référence écrite à la main, d'après le guide des requêtes, par deux annotateurs indépendants, puis
     adjugée ;
   - le jugement de l'équivalence de la requête compilée par le comparateur d'inclusion (`inclusion.pl`) : exacte, trop
     forte, trop faible, indéterminée.
3. **Pour chaque famille :** les taux, avec des intervalles de Wilson. La sûreté d'abord : aucune requête « compilée »
   ne doit être trop faible ; la borne haute de Wilson est fixée à l'avance.
4. **Une seconde étape :** des textes écrits pour ces libellés (positifs, négatifs, indéterminés, variantes du § 2.2),
   et l'expérience croisée complète : les quatre conditions graphe × requête, sur un jeu neuf.

## 4. Le jeu de qualification indépendant

**Ce qui est préservé dès maintenant** (avant toute nouvelle mise au point) :
- un tirage, avec une graine publiée, de 400 notations ;
- leurs libellés ;
- un sous-ensemble de 100 notations pour les textes.

**Ce qui est exclu du tirage :**
- toute notation des jeux de développement, de validation, des bancs et des échantillons consultés ;
- toute notation qui en est un ancêtre ou un descendant direct. Sinon, une mise au point sur un parent fuit vers
  l'enfant.

**Comment il est gardé :**
- le jeu est écrit hors de portée des agents de développement, avec une empreinte publiée dans le dépôt (§ 4.1) ;
- il n'est ouvert qu'une fois, pour la qualification, et après que la propriétaire a validé les bancs du § 2 ;
- les requêtes de référence et les textes de ce jeu sont écrits par des annotateurs qui n'ont travaillé sur aucun
  autre jeu ;
- la validation humaine d'un échantillon est faite avant l'ouverture.

**Le tirage est fait** (27/11, `outils/qualification/tirer_jeu_independant.py`) :
- **la graine :** 20261127 ;
- **le tirage :** 400 notations parmi 37 266 éligibles, dont 100 pour les textes ;
- **les strates :** 1 : 114, 2 : 26, 3 : 27, 4 : 65, 5 : 9, 6 : 1, 7 : 52, 8 : 14, 9 : 92 ;
- **les exclusions :** 2 114 notations exclues directement, puis leurs ancêtres et leurs descendants directs. Exclure
  tous les descendants retirerait des divisions entières, à cause des codes courts comme 25H ;
- **l'empreinte SHA-256 du contenu :** `8d91ac6a57a0b6a58748510f799285b5abbfb6fd9c1aa94df126d2514dd2c927` ;
- **la conservation, aujourd'hui :** sur la branche orpheline `donnees/qualification-independante`. Ni l'agent qui l'a
  tiré ni personne n'a lu son contenu ; seul le résumé du tirage l'a été.
  - **Ce jeu est gelé, non scellé** (précision de la propriétaire) : une branche d'un dépôt que les agents peuvent
    lire n'est pas hors de leur portée. Il ne doit pas être ouvert ;
- **ce qui n'est pas vérifié :** le recouvrement avec les bancs scellés anciens. Leurs références ne sont pas lues.

### 4.1 La conservation hors de portée des agents (à organiser avec la propriétaire)

Une proposition, qui demande des gestes de la propriétaire :
1. **Copier** `jeu.json` et son résumé hors du dépôt, sur un support qu'aucune session de développement ne monte. Vérifier
   l'empreinte publiée.
2. **Vérifier le recouvrement** avec les anciens bancs scellés (`banc_qualif*`, `banc_scelle`), sur ce même support :
   relancer `outils/qualification/tirer_jeu_independant.py` avec leurs références dans `--exclure`.
   - Si le jeu change, l'ancien est gardé et la nouvelle empreinte publiée.
   - L'outil ne lit les références que pour en extraire des notations.
3. **Retirer la branche** `donnees/qualification-independante` du dépôt, une fois la copie vérifiée. C'est une
   suppression : elle est faite par la propriétaire, ou à sa demande expresse.
4. **Pour la suite,** les requêtes de référence et les textes de qualification sont écrits par une session distincte, et
   déposés directement sur ce support, jamais dans le dépôt.
5. **À la qualification,** une session de mesure reçoit le jeu, une seule fois, et le journal de son ouverture est
   publié.

**Les textes :** pour une part, des **descriptions réelles** (notices et cartels d'institutions, sous une licence
compatible), et non seulement des textes écrits pour le banc. L'écart entre les deux est l'une des mesures.

## 5. Les baselines

Elles sont des comparaisons, jamais des composants obligatoires :
- **lexicale :** l'appariement des mots du libellé et du texte, avec les sens de WordNet, sans structure ;
- **de recherche :** BM25 et des plongements hors ligne, par similarité texte–libellé ;
- **neuronale :** un classifieur d'implication textuelle (NLI) hors ligne, multilingue, sur les paires (texte,
  libellé reformulé). Il est mesuré sur les mêmes jeux, avec la même distinction entre positifs, négatifs et
  indéterminés, et avec la même mesure de sûreté sur les négatifs et les variantes.

**Ce qu'elles mesurent :** ce qu'un système sans structure obtient. Si une baseline fait mieux sur une famille, c'est
un signal sur la représentation de cette famille, non une raison d'adopter la baseline comme générateur obligatoire de
candidats (`docs/FONDEMENTS_SEMANTIQUES.md`, § 5).

## 6. Les critères de passage

**Pour chaque extension ou opération (`docs/TRAJECTOIRE.md`) :**
- son banc de famille passe en entier ;
- l'oracle et le différentiel sont sans désaccord ;
- les mutants sont détectés ;
- aucune perte de sûreté sur les autres bancs ;
- la mesure sur les jeux de développement avancé est faite et publiée, sans y avoir été réglée.

**Pour la qualification (§ 3 et § 4) :** les taux de chaque famille, avec leurs intervalles, et les critères de sûreté
fixés avant l'ouverture du jeu indépendant.
