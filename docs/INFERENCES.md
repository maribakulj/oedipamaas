# Ce qu'il faut fournir au noyau : quatre opérations, cinq familles d'inférences, une expérience contrôlée

Les décisions du 27/11 (second message de la propriétaire) :
- l'architecture du noyau n'est pas rouverte ;
- il s'agit de déterminer expérimentalement ce que nous devons lui fournir pour qu'il accomplisse réellement sa
  fonction.

Qu'aucun échec de l'expérience croisée ne soit attribué au noyau (`docs/EXPERIENCE_CROISEE.md`, § 10) ne démontre pas
que son expressivité suffit au raisonnement iconographique. Ce document :
- distingue quatre opérations ;
- étudie une à une les inférences contextuelles que les échecs demandent, et les regroupe en familles ;
- mesure, dans une petite expérience contrôlée, ce qu'apportent la canonisation, les connaissances lexicales, le
  raisonnement situationnel et la classification par définition.

L'étude des ressources réutilisables est `docs/ETAT_DE_L_ART_INFERENCE.md`.

## 1. Quatre opérations

| opération | ce qu'elle fait | ce qu'elle produit | son statut |
|---|---|---|---|
| **canonisation** | réécrit la description et le libellé vers une même forme : un nom d'action et son verbe, un nom d'état et son adjectif, un nom d'agent et l'événement dont il est l'agent | une autre écriture de la même assertion | une équivalence, ou rien. Une réécriture qui n'est vraie que pour un sens est sous l'hypothèse de ce sens (D30) |
| **déduction** | tire de K et du graphe ce qui en suit nécessairement : hyperonymie, implication (snore ⇒ sleep), cause (kill ⇒ die), état et événement (mort ⇒ mourir) | une conclusion | certaine, sous les seules hypothèses de sens |
| **abduction** | propose ce qui expliquerait le texte : le tout dont une partie est décrite, la situation que des indices évoquent | une hypothèse, jamais une assertion du texte | toujours une hypothèse, avec sa provenance ; elle ne rend jamais un code « établi » |
| **classification** | range une chose ou une situation décrite sous une catégorie : « l'organe de l'odorat » est un nez | une catégorie | déductive si la définition est nécessaire et suffisante et entièrement appariée ; une hypothèse sinon, c'est-à-dire presque toujours |

Le noyau sait déjà distinguer une conclusion déductive d'une conclusion sous hypothèses de sens (D30).

Il reste à lui fournir :
- les réécritures de la canonisation, appliquées des deux côtés ;
- des connaissances de déduction plus riches que l'hyperonymie ;
- des hypothèses abductives et des classifications, chacune avec sa provenance, et que ses preuves citent.

Une conclusion qui cite une hypothèse n'est pas établie (§ 5).

## 2. Cinq familles d'inférences contextuelles

- **F1, équivalence sémantique :** deux expressions disent la même chose (une paraphrase définitionnelle, une
  nominalisation, une locution). Exemples : « l'organe de l'odorat » et nez ; « frozen to death » et die of cold.
- **F2, conséquence logique :** ce qui suit nécessairement, par un lien lexical : un pré est un lieu extérieur ;
  ronfler implique dormir.
- **F3, connaissance des situations :** ce qu'une situation comporte typiquement. Des tombes font un cimetière ; des
  époux en tenue de noces, des mariés ; un casier à homard, une pêche.
- **F4, relation entre états et événements :** l'état résultant, la cause, les pré- et post-conditions. Un corps sans
  vie suppose que quelqu'un est mort ; un prisonnier, qu'il a été emprisonné.
- **F5, hypothèse interprétative :** ce qu'une lecture prête au texte. Une intention (« le poignard levé » : tenter de
  tuer) ; un sens figuré (le « feu » biblique comme éclair) ; l'identification d'une invocation, d'une œuvre ou d'un
  personnage par ses traits.

## 3. Le catalogue (`inference/catalogue.json` sur la branche de données)

**Ce qui a été catalogué.** Les 41 échecs de (graphe de référence, requête de référence) v2 dont le diagnostic compte
une inférence contextuelle. Chacun a été relu, avec son texte, son graphe et sa requête, et donne **48 inférences**.

**Ce que dit chaque entrée :**
- ce que le texte dit, et ce que le libellé demande ;
- l'opération et la famille ;
- le statut proposé : certain, hypothèse, ou hors de portée de cette couche ;
- une ressource candidate et une remarque.

Les gloses de WordNet citées ont été vérifiées sur les fichiers de WordNet 3.0. Quatre citations de mémoire étaient
fausses ou imprécises (transept, upholster, foredeck, weight) : elles ont été corrigées.

Ce sont des décisions d'agent, **provisoires**.

| famille | inférences | opérations | statut proposé |
|---|---|---|---|
| F1 équivalence sémantique | 18 | classification 13, canonisation 5 | certain 5, hypothèse 12, hors de portée 1 |
| F2 conséquence logique | 1 | classification 1 | hypothèse 1 |
| F3 connaissance des situations | 15 | abduction 8, classification 7 | hypothèse 15 |
| F4 états et événements | 4 | déduction 4 | certain 3, hypothèse 1 |
| F5 hypothèse interprétative | 10 | abduction 8, classification 2 | hypothèse 8, hors de portée 2 |
| **total** | **48** | classification 23, abduction 16, canonisation 5, déduction 4 | certain 8, hypothèse 37, hors de portée 3 |

**Ce que montre le catalogue :**
- **La classification est l'opération la plus fréquente (23 sur 48).** La moitié de ces cas sont des définitions
  appariables presque mot pour mot à une glose de WordNet : nez, tonsure, transept, grêle, vinaigre, huile d'olive,
  monstre.
- **Huit inférences seulement peuvent être certaines :**
  - les cinq canonisations (nom d'agent, locution, tracer pour écrire, « parmi » pour l'appartenance) ;
  - trois conséquences d'état (prisonnier ⇒ emprisonnement, corps sans vie ⇒ mourir, supplice de martyre ⇒ mort).
  - Les transformer toutes en règles certaines serait faux.
- **Les traiter toutes en hypothèses indistinctes serait faux aussi.** Les hypothèses F3 (une situation typique) n'ont
  pas le même poids que les F5 (une interprétation), et le catalogue garde la différence.
- **Trois inférences sont hors de portée de cette couche :** la chemise à la reine, le Spinario, Pulchra ut luna. Ce
  sont des identifications encyclopédiques ou iconographiques : une liaison d'entités, une connaissance iconographique
  réutilisée (Wikidata, Iconclass), non des règles écrites à la main.

## 4. Ce qui n'est pas fait, et ne doit pas l'être

- Aucune règle n'est écrite pour une notation, ni pour un motif iconographique.
- Aucune ressource produite par un grand modèle de langue (ATOMIC-10x, COMET…) n'est utilisée : ce serait une
  circularité avec la contrainte « aucun LLM à l'exécution ».
- Une hypothèse n'est jamais assertée : une conclusion qui en cite une reste « sous hypothèses ».

## 5. L'expérience contrôlée

**Le protocole** (`outils/inference/experience.pl`, `outils/inference/analyser.py`). Le noyau n'est pas modifié.
- **Les données :** les graphes de référence et les requêtes de référence du banc v2.
- **Les textes :** tous ceux dont la notation a une requête de référence évaluable, soit 117 en développement et 197
  en validation : positifs, négatifs, indéterminés et variantes. Le gabarit non instancié et le texte contesté sont
  exclus.
- **Le même noyau, les mêmes connaissances K, les mêmes budgets.**

Chaque couche **ajoute** au graphe des assertions. Chaque assertion ajoutée a sa provenance (règle, famille,
ressource, statut, source), les qualificatifs de sa source (une source niée donne une assertion niée) et un
identifiant propre. Les preuves du noyau disent ensuite lesquelles une conclusion cite. Toutes les couches sont
dirigées par la requête : une assertion n'est ajoutée que si son mot est un mot de la requête, comme une abduction est
dirigée par ce qu'elle explique, et cela borne l'inflation.

Les quatre couches. Leurs ressources sont toutes dans WordNet 3.0, et le français y passe par l'alignement de WOLF,
dont les sens sont ceux de WordNet.

| couche | opération | règles | ressource | statut |
|---|---|---|---|---|
| C | canonisation | nominalisation ↔ événement, nom de rôle ↔ événement et rôle (agent, undergoer, instrument…), nom d'état ↔ adjectif, dans les deux sens | liens morphosémantiques (15 329), dérivations, attributs | certain si le lien vaut pour tous les sens du mot source et que la relation est une équivalence (event, state, dérivation) ; hypothèse pour les noms de rôle |
| L | connaissances lexicales | adjectifs similaires, tête d'un composé sans concept, nom propre partiel | similar_to ; la tête du composé ; les alias de la requête | hypothèse |
| S | raisonnement situationnel | implication et cause entre verbes, état → événement, partie → tout | entailment, cause, dérivations et liens morphosémantiques d'état, méronymie avec héritage par l'hyperonymie | certain pour l'implication, la cause et l'état direct (tous les sens) ; hypothèse sinon |
| D | classification par définition | une entité est classée T si sa tête atteint le genre de la glose de T et si assez de mots de la différence (le tiers, un au moins) se retrouvent, par leurs sens, dans son voisinage admissible | gloses de WordNet | toujours hypothèse |

**Les configurations :**
- la base ;
- chaque couche seule ;
- C+L+S, puis C+L+S+D ;
- C+L+S+D sans chacune des couches, pour l'ablation.

**Les mesures :**
- les positifs en échec à la base qu'une configuration améliore, déductivement ou seulement sous hypothèses ;
- les atomes manquants qu'elle satisfait ;
- les faux positifs sur les négatifs et les variantes ;
- les indéterminés établis ;
- l'inflation en assertions ajoutées.

### 5.1 Les résultats

Positifs en échec à la base : 34 en développement, 38 en validation. Ils manquent de 69 et 83 atomes, soit deux par
texte en moyenne.

| configuration | dév. : repris (déductif / sous hyp.) | dév. : atomes repris | val. : repris (déductif / sous hyp.) | val. : atomes repris | faux positifs (dév. / val.) | assertions ajoutées par texte (dév. / val.) |
|---|---|---|---|---|---|---|
| base | 0 / 0 | 0 / 69 | 0 / 0 | 0 / 83 | 0 / 0 | 0 / 0 |
| C | 0 / 1 | 6 | 0 / 0 | 3 | 0 / 0 | 0,1 / 0,2 |
| L | 0 / 0 | 3 | 0 / 0 | 6 | 0 / 0 | 0,3 / 0,2 |
| S | 0 / 1 | 1 | 0 / 1 | 6 | 0 / 0 | 0,1 / 0,3 |
| D | 0 / 0 | 1 | 0 / 1 | 9 | 0 / 1 | 0,2 / 1,2 |
| C+L+S | 0 / 2 | 10 | 0 / 2 | 16 | 0 / 0 | 0,5 / 0,7 |
| C+L+S+D | 0 / 2 | 10 | 0 / 3 | 22 | 0 / 3 | 0,6 / 2,0 |
| sans C | 0 / 1 | 5 | 0 / 2 | 19 | 0 / 1 | 0,5 / 1,7 |
| sans L | 0 / 2 | 7 | 0 / 2 | 16 | 0 / 2 | 0,4 / 1,7 |
| sans S | 0 / 1 | 9 | 0 / 2 | 18 | 0 / 3 | 0,6 / 1,7 |

Aucun indéterminé n'est établi, dans aucune configuration.

**Les cinq textes repris, tous sous hypothèses, relus un à un :**
- **44G31 (C, `c_nom_de_role`) :** le geôlier est l'agent d'emprisonner. La conclusion est juste, et l'hypothèse
  plausible.
- **46C215(WINDLASS) (S, `s_partie_tout`) :** un guindeau est une partie de navire. La conclusion est juste.
- **31A4155 (S, `s_partie_tout`) :** une sangle est une partie d'un appareil orthopédique (brace), donc il y aurait un
  appareil. La conclusion est juste ; la raison est faible.
- **41C67 (D) :** le liquide doré pressé d'olives est classé huile. La conclusion est juste, mais l'appariement passe
  par un seul mot de la glose (substance).
- **11I72(JUDAS ISCARIOT)1 (C+L) :** « begin » donne « founder » par le lien agent, et « Judas » donne l'alias. La
  conclusion coïncide avec le libellé ; la raison est faible.

**Les trois faux positifs, tous de C+L+S+D :**
- **31AA5333, négatif :** la glose de la tonsure trouve « monk » dans le texte, sans voir ce qui est rasé.
- **11QQ7121(TRANSEPT), négatif :** la glose de transept trouve church dans le texte.
- **11H(IGNATIUS OF ANTIOCH)131, variante aux rôles inversés :** une règle définie par sa glose, plus un nom de rôle
  et un nom partiel.

Chaque fois, D en est la cause, seule ou avec C et L. C, L et S n'en produisent aucun, ni sur les 76 négatifs (39 et 37) ni sur
les 84 variantes.

### 5.2 Ce que l'expérience établit

1. **Une ressource lexicale, même riche, ne suffit pas à atteindre les cibles.**
   - Avec C, L et S, 2 positifs sur 34 sont repris en développement et 2 sur 38 en validation, tous **sous
     hypothèses**.
   - Atome par atome, les couches satisfont 10 des 69 atomes manquants en développement, et 16 des 83 en validation.
     Elles atteignent donc le bon atome, mais il reste les autres : une cible en échec manque en moyenne de deux atomes
     de natures différentes.
2. **Aucune conclusion déductive n'est gagnée.**
   - Les liens que nous tenions pour des équivalences (nominalisation, état) ou des implications (entailment, cause)
     ne sont certains que s'ils valent pour tous les sens du mot source (D30). Ici, pas une conclusion n'en cite un qui
     le soit.
   - **La canonisation par les mots reste donc hypothétique tant que les sens ne sont pas choisis.** La
     désambiguïsation (X7) est une condition de la déduction, non un raffinement.
3. **La sûreté tient pour C, L et S, pas pour D.**
   - C, L et S n’ajoutent aucun faux positif sur 76 négatifs et 84 variantes.
   - D en ajoute 3 en validation, pour un seul positif repris.
   - Une classification par définition qui ne regarde que les mots, et non leur structure (qui est rasé, de quoi la
     croix est le bras), n'est pas sûre. La suite est celle de l'étude : compiler les gloses en graphes par le lecteur,
     pour que le noyau les apparie comme des requêtes.
4. **Ce qui manque n'est surtout pas dans WordNet.**
   - D'abord les connaissances de situation (F3) et les interprétations (F5) : 23 des 48 inférences du catalogue.
   - Ensuite les conventions de représentation que les ressources lexicales ne touchent pas : patient ou thème, relation
     ou lieu d'un événement, propriété ou événement. Elles relèvent de la canonisation des rôles et des relations (X6),
     non du lexique.
5. **Ce que le noyau doit recevoir, sans changer d'architecture :**
   - **des assertions ajoutées, avec leur provenance et leurs qualificatifs.** L'expérience montre qu'il suffit de leur
     donner un identifiant : les preuves les citent, et le statut se calcule ensuite ;
   - **un statut « sous hypothèse d'inférence »** reconnu par le codage. Le mécanisme existe pour les dérivations du lot
     3 (`conditionnel_par_derivation`), et il suffit de l'étendre à ces assertions. Le noyau, lui, ne change pas ;
   - **des sens choisis** (X7), pour qu'une canonisation et une implication deviennent certaines ;
   - **des définitions structurées** (gloses compilées en graphes), à la place des sacs de mots ;
   - **des connaissances de situation et d'état** : FrameNet (Causative_of, Inchoative_of), VerbNet (post-états),
     plus tard ConceptNet comme générateur d'hypothèses. Elles se mesurent par la même expérience, une ressource à la
     fois.

**Ce que l'expérience ne dit pas :** que ces couches seraient inutiles sur des graphes du lecteur ou sur d'autres
textes. Les textes du banc sont écrits pour décrire sans nommer, ce qui rend la tâche plus difficile que des notices
réelles.

### 5.3 Limites

- **Une seule source de connaissances :** WordNet 3.0, avec ses liens morphosémantiques et ses gloses. FrameNet,
  VerbNet, ConceptNet et les ressources françaises propres (Réseau Lexical du Français, Lexique-Grammaire,
  JeuxDeMots) ne sont pas encore essayés. L'étude les recommande comme suite.
- **La couche D est un appariement par sacs de sens, et non une compilation des gloses en graphes** par le lecteur
  (ce que l'étude recommande). C'est une borne basse de ce qu'apporte la classification par définition.
  - Elle a été mise au point en regardant huit textes de la validation, en violation du protocole, qui réserve la
    validation à la décision. Seules deux corrections de principe ont été faites (les verbes modaux parmi les mots
    vides, l'admissibilité des indices), et aucun seuil n'a été réglé. Ses résultats en validation sont donc à lire
    avec cette réserve.
- **Une première passe sans D est gardée** (`inference/essai1/`). Elle compte comme repris un texte déjà établi sous
  hypothèse à la base (47C35) ; l'analyse ne compte maintenant qu'une amélioration sur la base.
- **Les causes et le catalogue sont des décisions d'agent,** non validées. Les textes sont peu nombreux, et aucun
  intervalle n'est donné.

### 5.4 Reproduction

M la branche de données ; WN les fichiers Prolog de WordNet 3.0 ; R les ressources.

```bash
python outils/inference/morphosemantique.py R/morphosemantic-links.xls M/inference/morphosemantique.pl
```

```bash
swipl outils/inference/experience.pl BASE WN M/inference/morphosemantique.pl \
  M/banc_graphes/v2/faits_reference_JEU_v2.json M/banc_graphes/v2/requetes_reference_JEU_v2.json \
  M/inference/cibles_JEU.json M/inference/experience_JEU.json
```

```bash
python outils/inference/analyser.py M/croise/v2/causes_ref_ref_v2.json vertical=M/inference/experience_vertical.json \
  validation_m1=M/inference/experience_validation_m1.json --json M/inference/analyse.json
```
