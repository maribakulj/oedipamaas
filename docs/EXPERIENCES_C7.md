# Le plan d'expériences de C7 : ressources formelles, petits modèles, approches hybrides

Décision du 27/11 : aucune architecture de compréhension linguistique n'est choisie avant d'avoir mesuré les
approches ; pas d'accumulation de règles ad hoc ; une progression mesurable de la qualité des graphes, puis la mesure
de son effet réel sur les annotations Iconclass. Ce document fixe le protocole ; l'étude de l'état de l'art
(`docs/ETAT_DE_L_ART_C7.md`) donne les candidats, le banc (`docs/BANC_GRAPHES.md`) les mesures.

## 1. L'hypothèse architecturale principale : une canonisation commune

Les libellés d'Iconclass (compilés en requêtes, C3) et les descriptions (lues en graphes, C6 et C7) sont ramenés **à
la même forme canonique** : celle du guide du banc (une action est un événement, ses participants ont des rôles, les
qualificatifs disent ce qui est affirmé de l'image). Le noyau compare deux objets de même forme ; une transformation
n'est jamais appliquée d'un seul côté. Conséquences pour les expériences :
- chaque approche candidate produit des graphes dans cette forme (le format de `outils/graphes/lire.pl`), et est
  mesurée par le même comparateur ; une sortie dans une autre forme passe par une canonisation explicite, mesurée à
  part (comme E1, jugée « non conforme », § 4 du guide) ;
- une approche retenue pour les descriptions doit l'être aussi pour les libellés, ou dire pourquoi la forme
  canonique est atteinte autrement de ce côté (la mesure C3 : `outils/requetes/comparer.pl`).

## 2. Ce qu'on mesure, et dans quel ordre

Le critère premier est la **sûreté** : une assertion que le texte nie, modalise, attribue à une source ou à une autre
œuvre ne doit pas devenir une prémisse admissible (la « promotion » du comparateur). La première mesure du lecteur
(`docs/mesures/V2.md`) donne 73 à 81 % de promotions parmi les assertions non admissibles qui ont une correspondante,
surtout des portées (le lecteur met presque tout en `represente`), puis des modalités, des négations et des
citations, et aucun nombre. D'où l'ordre :

| priorité | tâche | mesures (banc, `comparer_graphes.py`) |
|---|---|---|
| 1 | **qualificatifs** : nombres, négations (et leur portée), modalités, portées (`oeuvre`, `source`, `histoire`…), sources citées, alternatives | promotions (par motif), rétrogradations, F1 des qualificatifs, F1 qualifiée des entités et événements |
| 2 | **rôles** : patient et thème (le lecteur n'écrit jamais `theme`), participants indirects (coordination, contrôle, participes détachés : 0 % de justes), sujets d'états (« est assis ») | F1 des rôles, matrice de confusion, analyse par construction (`analyse_roles.py`) |
| 3 | **relations** orientées (rappel 0,19 à 0,35) et complément du nom | F1 des relations |
| 4 | **coréférence** (rappel 0,04 sur les textes longs) | F1 des paires, et l'effet sur les rôles (référents par classes ou par mentions) |
| 5 | **sens** des mots (D30 : les hypothèses de sens) | l'étude, § 11, E5 : rappel d'ensemble, calibration |

Puis, pour toute approche qui améliore les graphes : **l'effet sur le codage** (`outils/graphes/coder_graphes.pl`),
graphes du lecteur contre graphes de référence codés par les mêmes requêtes : la part des erreurs de codage qui vient
de la lecture, et ce que l'approche en reprend.

## 3. Les approches à comparer, par tâche

Trois familles, pour chaque tâche ; chacune est un **adaptateur** qui produit des graphes au format de `lire.pl` (à
partir de la même analyse Stanza quand il en faut une), sans toucher au noyau.

**A. Ressources formelles et règles sur l'arbre de dépendances** (déterministes, explicables, sans apprentissage) :
- qualificatifs : listes de déclencheurs et règles de portée sur l'arbre (de la famille NegEx / ConText, adaptées au
  français) ; les nombres par `nummod` et `NumType` ; les portées par un lexique des supports et des techniques
  (toile, panneau, cadre…) et des verbes de composition ; les sources par les verbes et locutions de citation
  (« selon », « according to ») ;
- rôles : les cadres de valence (PropBank et NomBank, VerbNet, Verb∋Net et Dicovalence pour le français, par
  SemLink ou la Predicate Matrix) appliqués aux fonctions syntaxiques (sujet, objet, oblique, passif) ;
- coréférence : règles syntaxiques sûres (apposition, attribut, relatif).

**B. Petits modèles spécialisés** (hors ligne, sur processeur ; aucun grand modèle de langue à l'exécution) :
- négation et incertitude : classifieurs de déclencheurs et de portée (entraînés sur des corpus annotés en anglais ;
  le français est à vérifier) ;
- rôles : étiqueteurs de rôles sémantiques (PropBank ou VerbAtlas ; multilingues pour le français) ;
- coréférence : un modèle de coréférence de Stanza (anglais), un modèle léger dédié ;
- sens : UKB (graphes), à classer seulement (l'étude, § 6).
Chaque modèle est mesuré avec sa taille, son temps sur processeur, sa licence, ses données d'entraînement, et sa
couverture du français.

**C. Approches hybrides** : les règles proposent, un petit modèle tranche les cas que les règles laissent ouverts, ou
l'inverse ; et l'asymétrie de la sûreté : **dans le doute, non admissible** (une assertion dont la portée ou la
modalité est incertaine est donnée comme hypothèse, jamais comme prémisse).

## 4. Le protocole

1. **Les jeux.** Le développement du banc (120 graphes) pour mettre au point ; la validation (204) pour comparer et
   choisir, lue mais jamais réglée dessus (familles de ≥ 3 cas aussi présentes dans le développement) ; aucun des
   deux n'est un corpus de qualification : celui-ci sera un corpus indépendant de **descriptions réelles** (notices,
   cartels), annoté et validé humainement (§ 6).
2. **La référence de comparaison.** Le lecteur actuel, sans normalisation (la mesure du lot 1 et celle du banc).
3. **Une expérience = une tâche, une approche, une version.** Elle produit des graphes au format de `lire.pl`, son
   rapport (les tables du comparateur, les promotions, la matrice des rôles, l'analyse par construction, les temps),
   et sa commande de reproduction ; ses sorties sont gardées avec les autres (rien n'est effacé, même défavorable).
4. **Les critères de décision**, dans l'ordre :
   - aucune hausse des promotions (la sûreté d'abord : une approche qui gagne du rappel en promouvant n'est pas
     retenue) ;
   - le gain de F1 qualifiée sur la tâche, sur la validation, avec un intervalle (rééchantillonnage des textes) qui ne
     contient pas zéro ;
   - pas de perte ailleurs (les autres catégories, les autres langues) ;
   - le coût (temps sur processeur, mémoire, taille, licence compatible avec une base redistribuable) ;
   - l'effet sur le codage Iconclass (§ 2).
5. **L'écart au plafond.** L'accord des annotateurs (F1 0,89 à 0,98 sur les catégories structurantes, 0,65 à 0,68
   sur les modalités et les portées) borne ce qu'une mesure peut montrer ; une catégorie dont l'accord est bas
   demande d'abord une précision du guide, pas une approche.

## 5. Les premières expériences

| # | tâche | approches | pourquoi d'abord |
|---|---|---|---|
| X1 | nombres | A (UD : `nummod`, `NumType`) | aucun nombre lu ; la règle est formelle, non ad hoc |
| X2 | portées et sources | A (lexique des supports et techniques, verbes de composition, locutions de citation) contre C (A, et « dans le doute, non admissible ») | la première cause des promotions |
| X3 | négations et modalités | A (déclencheurs et portée sur l'arbre) contre B (classifieur de portée) contre C | promotions ; rappel 0,41 à 0,50 des négations |
| X4 | rôles | A (valences : PropBank, VerbNet, Verb∋Net, Dicovalence) contre B (étiqueteur de rôles) contre C | patient et thème, participants indirects |
| X5 | coréférence | A (règles sûres) contre B (modèle de Stanza, anglais) | l'effet sur les rôles et les relations |

Chaque expérience commence par un relevé des ressources (licence, couverture des deux langues, accès hors ligne) ;
une ressource inaccessible ou incompatible est notée, non contournée en silence.

## 6. Ce que le banc n'est pas encore

Les 324 graphes sont un **banc de développement à consolider** : écrits d'après un guide encore précisé, annotés et
adjugés par des agents ; l'accord entre agents n'est pas une validation humaine. Il faut encore :
- la relecture humaine d'un échantillon de chaque jeu (la propriétaire, D23), qui mesure l'accord agents / humain ;
- un **corpus indépendant de descriptions réelles** (notices et cartels d'institutions, en français et en anglais),
  annoté humainement d'après le guide, sur lequel les approches retenues seront qualifiées une fois.
