# La répartition des responsabilités entre les langages : l'arbitrage (28/11, validé par la propriétaire)

**La question de la propriétaire.** Python a été choisi pour plusieurs composants sans décision architecturale
comparative. Faut-il le garder, le remplacer en partie ou en totalité par Clojure, réserver Clojure à la construction de
K, ou recentrer le projet sur Prolog ? Deux contraintes s'appliquent :
- ni troisième langage par préférence, ni complexité inutile ;
- aucune duplication d'un mécanisme de raisonnement entre langages, sauf pour la vérification indépendante.

**L'instruction :**
- l'inventaire mécanique, fait par script : `/home/user/donnees/audit_langages/inventaire.tsv` ;
- l'étude comparative et une expérimentation en Python et en Prolog : `docs/AUDIT_LANGAGES.md`, avec ses scripts sous
  `/home/user/donnees/audit_langages/` ;
- l'arbitrage ci-dessous, validé par la propriétaire le 28/11, avec les précisions du § 4.

Rien n'a été réécrit, et aucune dépendance n'a été ajoutée.

## 1. Ce que l'audit établit

1. **Le moteur s'exécute en Prolog seul.** La commande ne charge ni Python ni Janus, comme l'exige le cahier des
   charges (`CAHIER_DES_CHARGES.md`, l. 259). Stanza n'y entre que comme processus externe et optionnel, par la frontière
   CoNLL-U.
2. **Les seules lignes Python qui raisonnent sont la vérification indépendante** : l'oracle du noyau et l'interpréteur
   de référence, 4 928 lignes. Leur duplication avec le noyau est voulue. Elle a déjà trouvé des défauts que les deux
   moteurs Prolog partageaient (`QUALIFICATION_NOYAU.md`, cycle 6). Le reste de Python se répartit ainsi :
   - mesure et expérimentation : 5 646 lignes ;
   - historique (version 0.2) : 3 005 ;
   - compilation des ressources : 741 ;
   - glue NLP : 217.
3. **Une seule bibliothèque Python est sans équivalent : Stanza.** `numpy` et `sentence-transformers` ne servent qu'à
   la version 0.2.
4. **La transformation représentative du futur K est aussi faisable en Python qu'en Prolog.** Elle prend WOLF et WoNeF
   vers WordNet 3.0, avec la provenance, les alignements, les versions, les statuts, neuf invariants, le vote et la
   compilation en faits. Les deux versions donnent le même résultat, à l'octet près, sur les 218 076 entrées, et
   détectent les 16 défauts injectés. Python est 5 à 9 fois plus rapide, sans optimisation d'aucun côté ; la taille est
   la même. Les deux versions ont le même auteur : leur accord ne prouve pas leur justesse.
5. **SWI-Prolog lit le Turtle sans rien installer.** Il charge 303 670 triplets SKOS en 2,7 s, et 994 427 triplets de
   DBnary (60 Mo) en 10,4 s. Python demanderait une bibliothèque RDF qui n'est pas installée. L'échelle complète de
   DBnary et de l'AAT n'est pas mesurée.
6. **Des duplications ne sont pas justifiées :**
   - la table des deux axes de statut est copiée quatre fois en Python, et les copies diffèrent ;
   - le codage des synsets est écrit en Python et en Prolog ;
   - deux raisonneurs Prolog coexistent : `raisonnement.pl`, déclaré remplacé, est encore appelé par la commande.

## 2. L'arbitrage

**B (Python remplacé par Clojure) est écarté.**
- **Il ne supprime pas Python :** Stanza resterait, donc trois chaînes d'outils.
- **Il réécrirait jusqu'à 12 750 lignes** et obligerait à rejouer les mesures et l'historique différentiel de l'oracle.
- **Il n'apporte aucune capacité dont le projet ait besoin.** L'expérimentation montre une divergence née d'un
  changement de bibliothèque (la mise en minuscules de « İ ») : c'est exactement le risque d'un portage.

**C (Clojure pour K) est écarté pour l'instant.**
- **Il ajoute un troisième langage** et une troisième définition exécutable du schéma de K, à côté de l'interface du
  noyau (Prolog) et de la syntaxe de l'interpréteur de référence (Python).
- **Ses atouts face à Python sont réels, face à Prolog non.** Ce sont les données immuables, `spec` et `malli`, EDN, et
  Jena avec SHACL. Prolog a déjà des termes immuables, la base de faits que consomme le noyau, la lecture RDF native et
  des règles déclaratives pour les invariants. Le relationnel pur (`core.logic`), les contraintes finies et les macros
  ne feraient que dupliquer ce que SWI-Prolog offre, et dont le projet n'a pas besoin aujourd'hui.
- **Le seul avantage propre serait Jena et SHACL,** c'est-à-dire la validation de grands graphes RDF. K ne valide pas
  des graphes : elle filtre et compile des sous-ensembles.
- **On rouvrira la question** si l'un de deux besoins mesurés apparaît : une validation de graphes à grande échelle, ou
  l'échec de SWI-Prolog sur DBnary et l'AAT complets, sans filtrage possible.
- **L'expérimentation en Clojure n'est pas nécessaire** pour décider. Elle ne pourrait changer la décision qu'en montrant
  un de ces besoins, que l'étude n'a pas trouvé. Je ne demande donc pas l'installation de Clojure. Si la propriétaire
  la veut malgré tout, c'est possible : le JDK est présent, et il faudrait un accès à Maven Central.

**Entre A et D, je propose D-minimal : le code nouveau de K en Prolog, sans migrer l'existant.**
- **Une seule définition de K du côté qui raisonne.** Le schéma des entrées et leurs invariants (pas d'entrée sans
  source, pas d'alignement sans version, un statut attesté ou non, un vote qui classe sans attester) vivent à côté de
  l'interface de K que consomme le noyau (`NOYAU.md`, § 2). La seconde définition est celle de l'interpréteur de
  référence, qui est voulue indépendante. Avec A, K aurait sa définition dans le constructeur Python, une autre dans
  l'interface Prolog, et une troisième dans l'interpréteur de référence, écrit dans le même langage que le constructeur.
  La tentation d'un code partagé y userait l'indépendance.
- **La compilation est native.** La sortie de K est du Prolog, écrit par `~q` sans traduction de syntaxe. L'essai Python
  a montré la fragilité inverse : un caractère de contrôle écrit brut.
- **La lecture RDF est disponible sans dépendance.**
- **Le prix,** que la mise en œuvre doit payer explicitement :
  - **le risque d'un échec silencieux,** observé une fois dans l'essai : en Prolog, un échec passe pour une issue
    normale. La règle « aucun repli silencieux » se traduit donc en conventions obligatoires :
    - lever une erreur quand un ensemble attendu est vide ;
    - `must_be` aux frontières ;
    - des tests plunit qui vérifient le déterminisme et le nombre d'entrées produites ;
  - **la lenteur,** qui reste acceptable hors ligne si l'échelle complète tient ;
  - **les fichiers `.xls`,** à remplacer par les exports Turtle ou CSV des mêmes vocabulaires.

**Ce que Python garde, et pourquoi :**

| composant | rôle | décision |
|---|---|---|
| `tests/oracle/`, `semantique_reference/` | vérification indépendante | garder en Python : la diversité de langage s'ajoute à l'indépendance du procédé |
| outils de mesure et d'expérimentation | ils comptent et comparent, ne raisonnent pas | garder : migrer coûterait sans rien apporter |
| glue Stanza | analyseur de référence, appelé comme processus externe | garder, et épingler la version dans `pyproject.toml` (avec `xlrd` tant qu'il sert) |
| compilateurs de ressources existants (`compiler_wordnet.py`, etc.) | compilation de l'ancienne base | garder jusqu'à ce que K en Prolog les remplace, puis les retirer après une comparaison différentielle des sorties |
| version 0.2 (`oedipamaas/*.py`, `sentence-transformers`, `numpy`) | historique | figer ; la retirer est une décision de la propriétaire |

**Les duplications à corriger, quelle que soit l'architecture** (petites, sans nouvelle dépendance) :
- **une seule table des deux axes** pour les outils de mesure, importée de l'interpréteur de référence, qui définit les
  statuts de (a). Les quatre copies actuelles ont des écarts : un `non_certifiee` signé n'y est pas lu de la même façon ;
- **le codage des synsets,** écrit une fois dans le contrat de K et lu par les deux côtés ;
- **`raisonnement.pl` :** la commande doit passer au noyau et à `codage.pl`, ou le module doit être reclassé. C'est une
  décision de la propriétaire (`AUDIT_LANGAGES.md`, § 7.3, point 1).

## 3. Avant tout développement de K

Ce sont des préalables à D, ou à toute autre architecture :
1. **Mesurer SWI-Prolog sur DBnary et l'AAT complets** : temps, mémoire, et une stratégie de filtrage par flux si le
   chargement complet ne tient pas. C'est une mesure mécanique, à faire par script.
2. **Unifier le vocabulaire des statuts de K.** Il en existe deux : `attestee` / `non_attestee` dans le langage de
   référence ; `propose` / `attesté` / `rejeté` dans la mesure des ressources. Je propose de garder les trois valeurs : un
   rejet est un fait positif (une entrée examinée et refusée), distinct d'une absence. Il faut alors l'écrire aussi dans
   le langage de référence. C'est une décision de la propriétaire.
3. **Trancher ce qui atteste un postulat de K\*** : la question ouverte de `FORMEL_BANCS.md`, § 2.2, que les deux pilotes
   ont rencontrée.
4. **Clarifier la licence des vocabulaires Joconde.** 13 des 16 exports déclarent CC-BY-SA, alors que la mesure retenait
   la Licence ouverte Etalab.
5. **Écrire la normalisation des chaînes dans la spécification** : NFC, puis pliage de casse complet, puis NFC. La
   version 2 de l'expérimentation l'a validée dans les deux langages. Ajouter aussi le contrôle des 16 entrées WOLF
   corrompues (U+009C à la place de « œ »).
6. **Trancher entre PLAN_V1 et le cahier des charges** sur une bibliothèque Python d'appel au moteur.

**La suite, une fois l'arbitrage validé :**
1. l'orchestrateur écrit la spécification de K ;
2. `prolog-engineer` l'implémente ;
3. `test-engineer` écrit les tests d'après la spécification ;
4. `code-reviewer` fait la première revue ;
5. `semantic-auditor` revoit les invariants et la certification.

La correction de la table des axes va à `python-engineer`.

## 4. La décision de la propriétaire (28/11)

**D-minimal est validé.** La nouvelle K se construit en Prolog. Python garde les composants existants et la
vérification indépendante. Clojure n'est pas introduit à ce stade.

**Une décision pragmatique et révisable.** Ce n'est pas une démonstration de la supériorité de Prolog sur Clojure.
Clojure n'a pas été expérimenté, et ses avantages ne se réduisent pas à Jena ou à SHACL : transformations
fonctionnelles, structures persistantes, traitement de données. Le § 2 de ce document est à lire avec cette réserve :
il écarte Clojure pour ce projet et à ce stade, pas en général.

**Les précisions qui s'imposent à la suite :**
- **Prolog est le langage du moteur et de la construction sémantique de K.** L'importation, la transformation et la
  validation des ressources sont des opérations clairement distinctes du raisonnement.
- **Une spécification unique, neutre et versionnée de K** sert de contrat à toutes les implémentations. L'unité du
  langage ne garantit pas, à elle seule, l'unité de la sémantique.
- **On ne migre aucun composant existant sans nécessité démontrée.**
- **Le pilote démontre la faisabilité de K en Prolog sur deux ressources, non sa robustesse générale.** Avant de le
  reprendre comme fondement, on reproduit et on examine :
  - la correspondance exacte des versions (INV7) et l'exhaustivité d'un vote (INV8) ;
  - les empreintes des données effectivement lues ;
  - les ambiguïtés des identifiants et des séparateurs ;
  - la provenance dans les faits compilés, et l'arité des faits lus ;
  - les données mal formées, les ensembles vides, et toute déduplication silencieuse.

  Le résultat défavorable du mutant M01 est gardé : on clarifie la spécification avant d'en changer l'attendu.
- **Les mesures sur DBnary et l'AAT complets** comparent le chargement intégral et le traitement par flux. On ne charge
  pas un graphe entier quand une extraction ciblée suffit.
- **Les statuts de K sont `proposée`, `attestée` et `rejetée`.** Ce sont des statuts de qualification des connaissances,
  distincts des valeurs logiques et des statuts de satisfaction des requêtes.
  - Le rejet d'une inclusion n'est pas une preuve de disjonction entre les concepts.
  - On garde chaque jugement avec sa source, son périmètre, sa version, et ses éventuelles contradictions avec d'autres.
    Un jugement de validation n'écrase jamais en silence les précédents.
  - Les postulats formels de la sémantique de référence se distinguent des connaissances attestées par une ressource
    externe.
- **La coexistence de deux raisonneurs actifs est un défaut architectural prioritaire.**
  - La commande publique appelle le noyau actuel par `codage.pl`, avec ses mécanismes de vérification et de
    certification.
  - L'intégration se prépare sans toucher aux fondements sémantiques, et sans prétendre que le noyau est qualifié pour
    la production.
  - Les fonctions de `raisonnement.pl` encore légitimement réutilisées sont séparées de l'ancien algorithme.
  - L'ancien raisonneur reste comme baseline historique, derrière des commandes explicitement identifiées comme telles.
- **L'interface :** une API publique indépendante du langage, par un protocole JSON/JSONL versionné. Un client Python
  facultatif peut l'appeler, sans dupliquer de logique métier et sans devenir une dépendance du moteur. Il n'y a donc
  pas de contradiction entre PLAN_V1 et le cahier des charges. Les dépendances de compilation, d'expérimentation, de
  lecture linguistique et d'exécution du noyau sont distinguées.
- **La normalisation des chaînes** garde les formes d'origine. Elle distingue les clés de recherche, les clés de vote et
  les identifiants conceptuels, et n'efface aucune distinction sémantique ou documentaire.
- **Sont validés :** la clarification des licences Joconde et le signalement des entrées WOLF corrompues.
- **Pas de chantier de réécriture générale.** La suite reste centrée sur les fondements exécutables, la qualification
  du langage de référence, l'intégration du noyau actuel et les besoins démontrés de K.
