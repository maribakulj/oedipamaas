# Audit des responsabilités de Python et de Prolog, et étude comparative de quatre architectures

Version 1, 28/11/2026. Rôle : `researcher`. **Document d'étude : il ne décide rien.** Aucune recommandation finale ; §7
donne les options et ce qui les départage. L'arbitrage revient à l'orchestrateur.

**Marques.** Chaque affirmation porte sa nature :
- « lu » : lu dans un fichier du dépôt `/home/user/oedipamaas-v3-wt` (branche `claude/bancs-v3`), chemin et ligne donnés ;
- « mesuré » : calculé ici, script et sortie dans `experience/` ou `classification/` ;
- « vérifié (doc) » : page de documentation ou référence ouverte le 28/11/2026 (liste au §8) ;
- « inféré » : ma conclusion, à ne pas prendre pour la source ;
- « non vérifié » : à confirmer.

**Ce que je n'ai pas fait.** Je n'ai modifié aucun fichier du dépôt. Je n'ai ouvert ni les références scellées, ni le jeu
indépendant, ni les scripts listés dans mon rôle. Je n'ai pas lu tout le code : j'ai lu les en-têtes de chaque famille de
fichiers et les fichiers d'entrée, de noyau et d'oracle nécessaires pour classer. Je n'ai pas lancé la suite de tests du
dépôt (comptages statiques seulement). Je n'ai **pas installé Clojure** ni téléchargé quoi que ce soit pour lui. Les
requêtes web ne contenaient aucune information sur la propriétaire ni sur le projet (recherches sur des noms de
bibliothèques, de langages et d'articles publiés).

---

## 0. Résumé

1. **Python n'est pas dans le chemin d'exécution du moteur actuel.** La commande `swipl oedipamaas/socle/commande.pl`
   est « en Prolog seul : ni Python, ni Janus » (lu : `oedipamaas/socle/oedipamaas.pl`, en-tête). Elle lance UDPipe 1
   (binaire C++) et, en option, Stanza comme **processus externe** (`process_create(path(python3), …)`, lu :
   `udpipe.pl:59`), par la frontière CoNLL-U. Le Cahier des charges exige « ni Python ni Janus à l'exécution »
   (`CAHIER_DES_CHARGES.md:259`).
2. **Python, c'est 15 989 lignes de code (108 fichiers) contre 9 718 pour Prolog (89 fichiers)** (inventaire,
   `inventaire.tsv`). Par catégorie primaire (§1.2) : 3 005 lignes Python historiques ; 741 de compilation des
   connaissances ; 5 646 d'outils de mesure ; 6 368 d'oracle et d'interpréteur de référence ; 217 de glue NLP ; 12 pour le
   moteur lui-même.
3. **Tout ce que Python « raisonne » est de la vérification indépendante.** Les 4 928 lignes Python qui dérivent des
   conclusions logiques sont `tests/oracle/` (1 422) et `semantique_reference/` (3 506) (mesuré,
   `classification_fichiers.tsv`). Selon mon classement, aucun autre fichier Python ne dérive un statut ou une preuve (`comparer_formel.py` appelle l'interpréteur de référence pour recalculer des statuts, il ne les dérive pas lui-même).
4. **La duplication de raisonnement entre langages existe et est justifiée par la vérification indépendante** : noyau
   Prolog (×2) face à l'oracle Python, d'après `NOYAU.md` seul. Le journal de qualification dit que cet oracle a relevé des
   défauts que les deux moteurs Prolog partageaient (`QUALIFICATION_NOYAU.md`, D16, cycle 6). Ce qui fait
   l'indépendance, c'est d'abord le procédé (lecture de la spécification seule), pas le langage (inféré : les deux effets
   ne sont pas séparables sur ces données).
5. **D'autres duplications ne sont pas justifiées** : la table des deux axes de statut est copiée quatre fois en Python ;
   le codage des synsets (n=1, v=2, a=3, r=4) est écrit en Python et en Prolog ; `raisonnement.pl`, déclaré « remplacé »,
   est encore appelé par la commande et par K ; `sujets.pl`, « abandonné », fournit encore `ferme/2` au compilateur.
6. **Stanza est la seule bibliothèque Python sans équivalent** pour la suite. `sentence-transformers` et `numpy` ne servent
   qu'à la version 0.2 (historique) ; les outils de mesure n'importent ni `numpy` ni `scipy` (inventaire).
7. **Expérimentation faite** (§6) : une transformation représentative de K (WOLF et WoNeF vers WordNet 3.0, provenance,
   alignements, versions, statuts, neuf invariants, vote, compilation en faits Prolog), écrite en Python et en Prolog.
   Les deux produisent le même `k.tsv` à l'octet près, à l'échelle de 400 synsets et à l'échelle complète (218 076
   entrées) ; chacune détecte les 16 défauts injectés, sans fausse alerte sur le témoin. Elle a fait apparaître une
   ambiguïté de la spécification (la mise en minuscules, divergente entre les deux langages) et une cascade non prévue
   (M01). **Clojure n'a pas été exécuté** : il est décrit au §6.7 avec ce qu'il faut pour l'exécuter.
8. **Constats collatéraux à trancher** (§7.3) : la licence des listes Joconde (les exports déclarent `CC-BY-SA`, la
   mesure dit « aucun triplet de licence ») ; un vocabulaire de statuts en deux versions ; 16 entrées WOLF corrompues
   (7 mots dont « œ » est devenu U+009C : cœur, œil, œuvre…).

---

## 1. Classification

### 1.1 Méthode (reproductible)

- Entrée : `inventaire.tsv` (197 fichiers `.py` et `.pl`, mécanique, fourni) et `par_dossier.tsv`.
- Classement : `classification/classer.py` (règles écrites, lisibles, ordonnées) → `classification/classification_fichiers.tsv`
  (une ligne par fichier : catégories, « raisonne », note). Lecture seule, `python3 -I`.
- Graphe de chargement Prolog : `classification/graphe_charge.py` (fermeture des `use_module` internes). Résultats (mesuré) :
  la CLI charge 14 modules (3 225 lignes brutes) ; `codage.pl` (noyau + compilateur) en charge 12.
- **« Raisonne »** : *oui* = dérive des conclusions logiques qui comptent pour une preuve ou un statut ; *amont* = produit
  les prémisses ou les définitions dont dépend un statut, sans en dériver (le lecteur, le compilateur C3, K) ; *non* = n'en
  dérive aucune (mesure, transformation de format, glue, tests).
- Une catégorie primaire par fichier sert aux sommes ; les rôles secondaires sont dans la table. Les fichiers non couverts
  par l'inventaire : `tests/test_semantique_reference_l22.py` (non suivi par git à la date de l'inventaire).
- Limites : le classement est mon jugement sur lecture des en-têtes et des appels ; il peut être contesté fichier par
  fichier dans le TSV. Les shells `outils/mesure/*.sh` (2 fichiers, troisième langage de script) ne sont pas dans
  l'inventaire.

### 1.2 Sommes par catégorie primaire (mesuré)

| Cat. | Contenu | Python (fichiers / lignes) | Prolog (fichiers / lignes) |
|---|---|---|---|
| (a) | historique ou abandonné | 29 / 3 005 | 19 / 1 738 |
| (b) | nécessaire à l'exécution du moteur actuel (CLI, noyau, K, tests du moteur) | 2 / 12 | 39 / 4 240 |
| (c) | compilation des connaissances | 7 / 741 | 4 / 137 |
| (d) | transformations symboliques (canonisation, C3, C7) | 0 / 0 | 10 / 2 182 |
| (e) | outils expérimentaux et de mesure | 53 / 5 646 | 16 / 1 108 |
| (f) | oracle indépendant | 14 / 6 368 | 1 / 313 |
| (g) | dépendances NLP (glue seulement) | 3 / 217 | 0 / 0 |
| | total | 108 / 15 989 | 89 / 9 718 |

(b) Prolog comprend les 2 139 lignes de `tests/plunit/`. (f) Prolog est `satisfaction_reference.pl`, moteur de référence écrit
dans le même langage que le noyau.

### 1.3 Tableau par composant

Colonnes : taille en fichiers / lignes de code ; catégories (la première est la primaire) ; appelé par ; appelle ;
raisonne ? « Py » = Python, « Pl » = Prolog. Les groupes se recouvrent un peu (deux fichiers Stanza sont comptés aussi
dans leur dossier d'outils).

| # | Composant | Langage, taille | Cat. | Appelé par | Appelle | Raisonne ? |
|---|---|---|---|---|---|---|
| 1 | `oedipamaas/*.py` (v0.2 : `cli`, `moteur`, `recherche`, `semantique`, `base`, `lecture`, `texte`, `references`, `wikidata`) | Py 10 / 1 435 | (a) | le script déclaré par `pyproject.toml` (`oedipamaas = oedipamaas.cli:main`), `tests/test_moteur.py` | Janus → `regles.pl`, `numpy`, `sentence-transformers`, Wikidata (réseau) | non (BM25, régression logistique ; règles Prolog) |
| 2 | `oedipamaas/regles/regles.pl` | Pl 1 / 74 | (a) | `moteur.py` v0.2 | — | règles de la 0.2, pas de preuve au sens actuel |
| 3 | Chaîne 1.0, Python : `moteur`, `coder`, `candidats`, `faits_description`, `compiler_decision`, `construire_base` | Py 6 / 342 | (a) ; `construire_base` aussi (c) | `tests/test_socle_*.py`, `outils/mesure/*` (BM25), `INSTALLATION.md` (construire_base) | Janus, modules Prolog 1.0 | non |
| 4 | Chaîne 1.0, Prolog : `cadres`, `cles`, `decision`, `description`, `lexique`, `noms`, `preuve`, `recherche`, `specialisation`, `traits` | Pl 10 / 1 045 | (a) | chaîne 1.0 | `arbre`, `notation`, `libelles`, `morphologie` | oui (décision apprise compilée en clauses, preuve lexicale), mais abandonné |
| 5 | Méthode des profils et premier jet de projection : `sujets.pl`, `hypotheses.pl`, `projection.pl`, `outils/sujets/`, `outils/vertical/projeter.pl` | Py 2 / 115 ; Pl 8 / 619 | (a) | **`sujets.pl` est encore chargé par `definitions.pl`, `libelles_iconclass.pl`, `scene.pl`** (`sujets:ferme/2`, lu) | — | `hypotheses`, `projection` : oui (abandonnés) |
| 6 | Commande et lecteur : `commande`, `oedipamaas`, `udpipe`, `conllu`, `interpretation` (lecteur C7), `mondes` | Pl 6 / 1 146 | (b), (d) | shell `swipl commande.pl`, tous les `outils/*.pl`, tests | UDPipe 1 (binaire, `process_create`), Stanza (`python3`, en option, `OEDIPAMAAS_ANALYSEUR=stanza`), `raisonnement.pl`, `assertions` | **amont** : le lecteur fixe polarité, modalité, portée, qui conditionnent les statuts |
| 7 | Noyau logique : `assertions`, `requetes`, `satisfaction`, `verificateur` | Pl 4 / 984 | (b) | `codage.pl`, `interpretation.pl` (satisfaction), outils de mesure, `tests/plunit`, oracle (différentiel) | K (`connaissances_*`), `library(assoc, time, solution_sequences)`, tabling | **oui** (statuts, preuves, contrôle des preuves) |
| 8 | K actuel : `connaissances_commun/en/fr` + faits compilés (`wordnet.qlf`, `ressources.qlf`, `iconclass.qlf` ; la base fait 620 Mo hors dépôt) | Pl 3 / 44 | (b), (c) | noyau, `codage.pl` | `raisonnement:normaliser_nom` | amont |
| 9 | Pièces Iconclass partagées : `arbre`, `notation`, `morphologie`, `libelles`, `sens` | Pl 5 / 515 | (b) (partagées avec (a)) | CLI (`arbre`, `notation` ; `morphologie` et `sens` chargés dynamiquement), chaîne 1.0 (`libelles`) | — | amont |
| 10 | `raisonnement.pl` (ancien T1/T2) | Pl 1 / 242 | (b), (a) | **CLI** (`raisonnement:coder`, lu `oedipamaas.pl:127`), K (`normaliser_nom`), `definitions.pl` (6 appels) | `arbre`, `assertions`, `notation` | **oui** (codes « établis » de la CLI actuelle) ; `HISTORIQUE.md` le dit « remplacé » |
| 11 | Couche Iconclass du noyau : `codage`, `inclusion`, `normalisation` (canonisation C7.3) | Pl 3 / 420 | (d), (b) | `outils/vertical`, `outils/bancs`, `outils/croise`, tests | noyau, K | `codage`, `inclusion` : **oui** ; `normalisation` : amont |
| 12 | Compilateur C3 : `definitions`, `requetes_iconclass`, `libelles_iconclass`, `compilation`, `scene` | Pl 5 / 932 | (d) | `outils/definitions/compiler_definitions.pl`, `outils/requetes/*`, `test_compilateur.pl` | `sujets.pl`, Stanza (via `lire_libelles.pl`) | amont (définit ce qui compte pour une preuve) |
| 13 | Compilateurs Python : `compiler_iconclass`, `compiler_wordnet`, `compiler_ressources` | Py 3 / 237 | (c), (b) | procédure `INSTALLATION.md`, tests `test_socle_*` | `git`, `xlrd` (xls des liens morphosémantiques) | non (transcription ; pas de provenance fine) |
| 14 | Compilation hors ligne : `outils/definitions/` (`lire_libelles.pl`, `compiler_definitions.pl`, `tirage_*.pl`, `stanza_conllu.py`), `outils/requetes/` | Py 1 / 60 ; Pl 7 / 256 | (c), (d) | exécution manuelle | Stanza (processus), UDPipe, `definitions.pl` | non |
| 15 | `outils/ressources/` : `lexiques`, `commun`, `manifeste`, `corpus`, `echantillon`, `contexte`, `mesurer` | Py 7 / 1 206 | (c), (e), (g) | exécution manuelle (`python3 -I`) | Stanza (`corpus.py`), lecture de WOLF, WoNeF, DBnary, Joconde, AAT, Iconclass ; **le Turtle est lu par expressions régulières** (« pas de bibliothèque RDF disponible », lu : `lexiques.py`) | non (mesure ; le vote est compté, pas calculé dans K). **C'est le prototype Python de la future construction de K** |
| 16 | Outils de mesure : `outils/bancs`, `croise`, `graphes`, `inference`, `mesure`, `moisson`, `noyau`, `qualification`, `vertical` | Py 47 / 4 524 ; Pl 13 / 989 | (e) | manuel ; `tests/test_bancs`, `test_croise`, `test_graphes`, `test_mesure_bancs` | `swipl` (sous-processus : `mesurer_moteur.py`, `injection.py`), noyau, `semantique_reference` (`comparer_formel.py`), Stanza, `xlrd` | non (comparaisons, bootstrap, tableaux) ; `premisses.pl` et `comparer.pl` appellent le noyau |
| 17 | Mutation du noyau : `outils/noyau/injection.py` | Py 1 / 245 | (e), (f) | manuel | `swipl` + `plunit` sur une copie altérée de `satisfaction.pl` | non (test des tests) |
| 18 | Oracle Python du noyau : `tests/oracle/oracle_noyau.py`, `differentiel.py` | Py 2 / 1 422 | (f) | `tests/test_oracle.py` (pytest) | `swipl` (les deux moteurs Prolog, un seul appel) | **oui** (réécriture de la sémantique de NOYAU.md) |
| 19 | Interpréteur de référence du langage : `semantique_reference/` | Py 8 / 3 506 (stdlib seule) | (f) | `tests/test_semantique_reference*.py`, `outils/bancs/comparer_formel.py` | — (n'importe rien de `oedipamaas/` ni de `tests/oracle/`) | **oui** (sémantique du langage de référence, plus large que le noyau 0.3) |
| 20 | Moteur de référence Prolog : `satisfaction_reference.pl` | Pl 1 / 313 | (f), (b) | `tests/plunit`, oracle différentiel | — | **oui** (même langage que le noyau) |
| 21 | Tests Prolog : `tests/plunit/` | Pl 22 / 2 139 (≈ 248 `test(` : comptage statique) | (b) | `tests/test_plunit.py` (un `swipl` par fichier), `swipl -g run_tests` | noyau, générateurs | non (ils vérifient) |
| 22 | Tests Python | Py 0.2 : 2 / 276 ; chaîne 1.0 : 9 / 837 ; oracle et référence : 6 / 2 862 ; outils : 4 / 524 | (a), (a), (f), (e) | `pytest` (≈ 180 `def test_`, comptage statique) | `swipl`, Janus | non |

### 1.4 Constats de classification

1. **Le chemin d'exécution est entièrement Prolog** (hors UDPipe et l'option Stanza). Python y est présent par un
   processus externe optionnel. *Lu* : `oedipamaas.pl` (en-tête), `udpipe.pl:50-62`, `CAHIER_DES_CHARGES.md:259`.
2. **Deux raisonneurs coexistent dans le moteur Prolog.** La commande appelle `raisonnement:coder` (T1/T2, de la génération
   précédente) ; le noyau, `codage.pl` et le compilateur C3 ne sont appelés que par les outils de mesure et les tests
   (lu : imports de `oedipamaas.pl` ; `codage.pl` n'est atteint par aucun import de la CLI). `HISTORIQUE.md` classe
   `raisonnement.pl` « remplacé par l'implication de FONDEMENTS § 4 ». **Décision conceptuelle nécessaire** pour classer
   proprement ce fichier et la CLI (§7.3, point 1).
3. **Des modules « abandonnés » restent des dépendances vivantes** : `sujets.pl` (`ferme/2`, mots-outils) pour C3 ;
   `raisonnement:normaliser_nom` pour K (`connaissances_commun.pl`) ; `libelles.pl` et `sens.pl` selon un drapeau
   d'environnement. Le test « charger le noyau ne charge ni Iconclass ni WordNet » (`NOYAU.md`, en-tête) ne couvre pas
   ces dépendances (inféré : il parle des modules Iconclass et WordNet).
4. **L'empaquetage Python décrit l'ancien moteur** : `pyproject.toml` déclare la version 0.2.0 et son point d'entrée
   `cli:main` ; `README.md` renvoie à `swipl commande.pl` pour le moteur actuel. `PLAN_V1.md:467` demande « CLI et
   bibliothèque Python » pour l'appel, alors que le Cahier exige « ni Python ni Janus à l'exécution ». **Tension à
   arbitrer** (§7.3, point 2).
5. **Les dépendances réelles ne sont pas toutes déclarées** : `pyproject.toml` n'a aucune dépendance obligatoire ; Stanza
   (1.10.1 installé ici, avec `torch` 2.15.0+cpu) et `xlrd` (2.0.2) n'y figurent pas ; leurs versions ne sont fixées que
   dans les documents (`DECISIONS.md`, D18 bis). `sentence-transformers` n'est pas installé ici (mesuré : import).
6. **Les versions minimales de SWI-Prolog divergent** : README « ≥ 9.1 », INSTALLATION « ≥ 9.2 » (Janus), version réelle
   11.0.0 (lu, mesuré).
7. **Test de la classification (a) trop forte** : trois fichiers de test de la chaîne 1.0 (`test_socle_arbre`, `notation`,
   `morphologie`) testent des pièces encore partagées avec le moteur actuel.
8. **La seule décision écrite sur Python est une phrase du Cahier** : « Les compilateurs restent en Python (outils de
   construction hors ligne) » (`CAHIER_DES_CHARGES.md:214`), sans comparaison d'alternatives (lu). Elle couvre les
   compilateurs ; elle ne couvre ni les outils de mesure (5 646 lignes), ni l'oracle, ni le futur constructeur de K.

### 1.5 Les dépendances (g) et leur usage réel

| Dépendance | Usage réel | Où | Statut |
|---|---|---|---|
| Stanza 1.10.1 (Python, PyTorch) | lecture des libellés Iconclass à la compilation (D18 bis) ; lecture des textes, en option (D20) | `stanza_conllu.py` (60 l.), `stanza_textes.py` (53 l.), `corpus.py` (104 l.) | **vivante**, appelée comme processus ; modèles 648 Mo hors dépôt ; code Apache 2.0, modèles CC BY-SA (d'après `DECISIONS.md`) |
| UDPipe 1.4.0 (C++) | analyseur par défaut des textes | `udpipe.pl` (`process_create`) | vivante ; code MPL 2.0, **modèles CC BY-NC-SA 4.0** (D7 ; Straka et al. 2016, résultat de recherche) |
| `sentence-transformers`, `numpy` | recherche sémantique de la 0.2 ; CI installe `numpy` pour `tests/test_moteur.py` | `oedipamaas/semantique.py`, `recherche.py`, `moteur.py` | historique (a) ; `numpy` n'est importé par aucun outil de mesure (inventaire) |
| `xlrd` | lecture des liens morphosémantiques (`.xls`) | `compiler_ressources.py`, `outils/inference/morphosemantique.py` | vivante, compilation seulement |
| `janus-swi` | pont Python → Prolog des chaînes 0.2 et 1.0, et de plusieurs tests | `coder.py`, `construire_base.py`, `tests/test_socle_*` | historique pour l'exécution ; la CLI n'en dépend pas |
| `pytest` | lance chaque fichier plunit et l'oracle | `tests/test_plunit.py`, `tests/test_oracle.py` | vivante (CI) |

---

## 2. Ce que Python apporte réellement

### 2.1 Composant par composant

« A égal » = une autre langue fait aussi bien sans nouvelle dépendance ; « mieux » = je vois un avantage ;
« moins bien » ; « ? » = non établi. Les colonnes Prolog et Clojure sont des **jugements inférés** appuyés sur la
documentation citée au §5 et sur l'expérience du §6 ; le seul chiffre Clojure est celui d'une page de documentation.

| Composant | Ce que Python apporte | En Prolog (SWI 11) | En Clojure (JVM) |
|---|---|---|---|
| Stanza (g) | **bibliothèque sans équivalent** : le pipeline neuronal mesuré supérieur à UDPipe 1 (rappel de la scène 0,948 contre 0,897 ; D20 bis) | l'accès se fait déjà par processus et CoNLL-U : **Python reste nécessaire, mais comme exécutable, pas comme langage de développement** (inféré) | idem : Clojure appellerait le même processus ; `libpython-clj` intègre Python à la JVM mais exige une installation Python et, sous JDK 17, le module « foreign » (vérifié (doc)). Stanza expose un client vers Stanford CoreNLP (Java), mais ce ne sont pas les mêmes modèles (résumé de l'article, vérifié) |
| `sentence-transformers`, `numpy` | recherche sémantique de la 0.2 (historique) | sans objet (a) | sans objet (a) |
| Outillage de test | `pytest` : lance les fichiers plunit et l'oracle ; saute les tests sans données. **Pas de bibliothèque de tests à propriétés** (Hypothesis n'est pas utilisée) : les générateurs sont écrits à la main, en Prolog (`generateur_noyau.pl`) puis reproduits en Python (`oracle_noyau.py §6`, `semantique_reference_gen.py`) | **plunit suffit** : `swipl -g run_tests -t halt` rend le code de sortie ; options `forall(Generateur)`, `condition`, `throws`, `all/set` (vérifié (doc)). Le CI pourrait lancer plunit sans Python (inféré) | `clojure.test` est livré avec le langage (non vérifié ici) ; `test.check` (QuickCheck, EPL-1.0, v1.1.3) et `clojure.spec` produisent des générateurs depuis les spécifications (vérifié (doc)) |
| Compilateurs Iconclass, WordNet, ressources (c) | `pathlib`, `json`, `hashlib`, `re` de la bibliothèque standard ; 237 lignes ; **écrit vite** | **A égal ou mieux pour WordNet** : l'édition WNprolog est déjà du Prolog (le compilateur filtre des lignes mal formées et ajoute les exceptions) ; **moins bien pour le `.xls`** : aucun lecteur xls dans la distribution (non vérifié) | A égal (EDN/JSON/XML) ; `.xls` via bibliothèque Java (non vérifié) |
| Construction de K (futur, prototype : `outils/ressources/lexiques.py`) | bibliothèque standard riche (`bz2`, `zipfile`, `xml.etree`, `csv`) ; **pas d'analyseur RDF installé** (rdflib absent ici, lu : `lexiques.py` le dit) → expressions régulières | **A égal ou mieux pour l'ingestion** : `library(sgml)`, `semweb/turtle`, `rdf11`, `rdf_ntriples`, `unicode`, `json` sont présents (mesuré : `use_module` réussi sur 21 bibliothèques). Mesure : 303 670 triplets SKOS (th285) en 2,7 s CPU ; 994 427 triplets de DBnary fr (60 Mo) en 10,4 s, pic 237 Mio | **mieux pour RDF à grande échelle et validation** : Apache Jena (API RDF, SPARQL, stockage TDB, API d'inférence, module SHACL) (vérifié (doc)) ; mais aucune de ces bibliothèques n'est installée ici |
| Outils de mesure (e) | **glue, statistiques simples (bootstrap en stdlib), tableaux Markdown** ; 5 646 lignes ; écrit vite, lisible | possible (le projet a déjà 989 lignes d'outils Prolog qui lisent et écrivent du JSON) ; plus long pour la mise en forme (inféré) | possible ; données immuables et EDN adaptés aux tableaux (inféré) |
| Oracle et interpréteur de référence (f) | **bibliothèque standard seule**, `dataclasses`, `itertools`, `functools` ; indépendance de langage vis-à-vis du noyau Prolog | possible (c'est déjà `satisfaction_reference.pl`), mais **même langage que le noyau**, donc partage les idiomes (négation par échec, indexation) | possible, indépendance de langage conservée ; coût : réécrire 4 928 lignes et rejouer les mesures |
| Pont vers Prolog | **Janus** (bidirectionnel, intégré à SWI ; README du dépôt : SWI-Prolog ≥ 9.1 ; vérifié (doc) pour l'interface) ; sa limite : binaires liés à une version précise de Python et de SWI-Prolog (FAQ, résumé de recherche) | **sans objet** : la CLI n'en dépend pas | **JPL** : interface Java ↔ Prolog bidirectionnelle (page du paquet, vérifié (doc)) |

### 2.2 Synthèse (inféré)

- **Vitesse d'écriture.** Je ne peux pas la mesurer. Un indice : à spécification égale, 159 lignes en Python contre 167 en
  Prolog (§6.4). Le temps d'exécution à l'échelle complète est d'environ 5 à 9 fois plus court en Python dans mes versions non
  optimisées. Pour la compilation, la vitesse n'est pas un critère décisif (reconstruction rare).
- **Pure glue** : la majorité des 11 061 lignes Python « non raisonnantes » (outils de mesure, moisson, compilateurs,
  glue Stanza) : lecture, agrégation, mise en forme.
- **Sans équivalent** : Stanza, et seulement lui.
- **Ce qui ne nécessite pas Python** : le chemin d'exécution, les tests Prolog, l'orchestration du CI (plunit rend un code
  de sortie), le futur construire-K dans la mesure où SWI-Prolog contient déjà l'ingestion RDF.

---

## 3. Duplications de mécanismes de raisonnement

| # | Mécanisme | Où | Justifiée par l'indépendance ? | Note |
|---|---|---|---|---|
| D1 | Satisfaction, certification, valeur de Belnap, polysémie (noyau 0.3) | `satisfaction.pl` (optimisé, 467 l.), `satisfaction_reference.pl` (Prolog, 313 l.), `tests/oracle/oracle_noyau.py` (Python, 1 189 l.) et, plus large, `semantique_reference/interprete.py` (Python, 1 802 l.) | **Oui** (lu : `NOYAU.md §7`, `QUALIFICATION_NOYAU.md` D16) | Journal : l'oracle Python, écrit « d'après NOYAU.md seul », a relevé quatre désaccords où les deux moteurs Prolog s'accordaient contre le texte (cycle 6, A à D), puis D55 (défaut du moteur de référence) ; « 0 désaccord sur 5 000 cas » après correction. **Inféré** : l'indépendance vient du procédé (un lecteur qui n'a lu que la spécification) autant que du langage ; je ne peux pas séparer les deux effets |
| D2 | Comparateur d'inclusion de requêtes | `inclusion.pl` (146 l.) ; `semantique_reference/inclusion.py` (265 l.) | **Oui**, même logique (le langage de référence est un banc d'essai pour NOYAU 0.4) | `LANGAGE_REFERENCE.md §6, §7` : R1 et R2 relevés par l'interpréteur |
| D3 | Ordre des statuts sur deux axes (déf. 11) | **quatre copies Python** : `interprete.py:2246` (`NIVEAUX`), `comparer_formel.py:27`, `comparer_niveaux.py:16`, `mesurer_moteur.py:83` (`AXES`) | **Non** : ce sont des outils de mesure, pas des oracles | Les copies diffèrent (lu) : `NIVEAUX` traite `non_certifiee` par son signe ; `comparer_formel.py` le fait dans `axes_nc` ; `comparer_niveaux.py` et `mesurer_moteur.py` lui donnent toujours (1, 0). Remède indépendant du langage : une définition importée |
| D4 | Générateurs de cas et K de test | `generateur_noyau.pl`, `connaissances_gen.pl` ; reproduits en Python (`oracle_noyau.py §6`) ; `tests/semantique_reference_gen.py` (277 l.) | Oui pour la reproduction (indépendance du jeu), à surveiller | trois générateurs à maintenir |
| D5 | Codage des synsets en entiers (n=1, v=2, a=3, s=3, r=4) | `compiler_ressources.py:47` ; `connaissances_commun.pl` (`prefixe/2`) ; mon `construire_k` | **Non** | contrat de K non écrit une seule fois |
| D6 | Normalisation des noms propres (`cle_de_nom`) | `raisonnement:normaliser_nom` (Prolog) ; reproduite dans l'oracle (K de test) | Oui pour l'oracle | le module « remplacé » est encore la définition de référence |
| D7 | Raisonnement du moteur actuel : T1/T2 et noyau | `raisonnement.pl` (CLI) contre `codage.pl` + noyau (outils) | **Non** : deux raisonneurs dans le même langage | voir §1.4, constat 2 |
| D8 | Lecture de WordNet 3.0 | `compiler_wordnet.py` (édition Prolog) ; `outils/ressources/commun.py` (WNDB) ; `valider_cas.py` (fichiers lexicographiques) ; mon `extraire_echantillon.py` | Non | données, pas du raisonnement |

**Futur K, risque de duplication** (inféré) : le schéma d'une entrée de K (source, version, statut, attestation) existe déjà
comme syntaxe abstraite en Python (`semantique_reference/syntaxe.py`, `Connaissances`) et comme interface Prolog
(`K:sens/3`, `K:version/1` : `NOYAU.md §2`). Un constructeur de K dans un troisième langage en ajoute une troisième
définition ; dans l'un des deux, il la fusionne avec une qui existe déjà. L'indépendance de la définition côté
interpréteur de référence est un bénéfice voulu ; celle du constructeur ne l'est pas.

---

## 4. Les quatre architectures

### 4.1 Définitions précises (ce que j'ai retenu)

- **A. Python-Prolog conservé.** Rien ne migre. La future K est construite en Python (extension de `outils/ressources/`),
  compilée en faits Prolog. L'oracle reste en Python.
- **B. Python remplacé, en partie ou en totalité, par Clojure.** B-total supprimerait Python ; **cela suppose de remplacer
  Stanza** (par CoreNLP ou UDPipe via la JVM), donc de rejouer D18 bis et D20 bis, ou d'appeler Stanza comme exécutable
  Python externe, ce qui fait de B-total un B-partiel. B-partiel : Clojure pour les compilateurs, la construction de K, les
  outils de mesure et éventuellement l'oracle ; Python réduit à Stanza.
- **C. Clojure pour K, Python réservé aux composants scientifiques.** Clojure construit K ; Python garde Stanza, les outils
  de mesure et l'oracle tels quels (ils sont déjà « scientifiques » : statistiques simples et vérification).
- **D. Recentrage sur Prolog.** K construite en Prolog ; les compilateurs migrables (237 lignes) et, au choix, les outils
  de mesure passent en Prolog ; Python garde Stanza (processus) et l'oracle. D-minimal : seul le code nouveau est en
  Prolog, rien n'est migré.

**B et C diffèrent par l'étendue de la migration**, pas par le nombre de langages : tous deux ont trois chaînes d'outils
(SWI-Prolog, Python, JVM) tant que Stanza est requise (inféré).

### 4.2 Tableau comparatif

| Critère | A. Python-Prolog | B. Clojure remplace Python | C. Clojure pour K ; Python scientifique | D. Recentrage Prolog |
|---|---|---|---|---|
| **Cohérence : où vit chaque mécanisme** | Raisonnement : Prolog (exécution) ; Python (vérification). K : construction en Python, consommation en Prolog ; invariants de K côté construction en Python et côté sémantique en Prolog | Raisonnement : Prolog ; vérification : Clojure (si l'oracle migre) ; K : Clojure. Python résiduel (Stanza) | Raisonnement : Prolog ; vérification : Python ; K : Clojure → **trois définitions du schéma de K** (spec EDN, interface Prolog, `Connaissances` Python) | Raisonnement et K : Prolog ; vérification : Python ; **deux définitions** du schéma de K, dont une indépendante voulue |
| **Rigueur : spécifications exécutables** | Invariants en fonctions Python (38 l. dans mon essai) ; pas de langage de spécification déclaratif | `clojure.spec` / `malli` : schémas en données ; validation, génération (vérifié (doc)) ; les invariants relationnels entre enregistrements restent des fonctions | Idem B pour K | Une règle Prolog par invariant (`violation/2`, 33 l.), proche de l'énoncé ; peu de garde-fous de forme natifs (dicts typés, `must_be`) |
| **Rigueur : vérification indépendante** | Conservée (oracle Python, 4 928 l. qui raisonnent) | Conservée par le langage si l'oracle migre en Clojure, **mais** 4 928 lignes à réécrire et l'historique différentiel (5 000 puis ≈ 20 000 cas sans désaccord) à rejouer | Conservée (oracle Python intact) | Conservée (oracle Python intact) ; risque inverse : si on la fait en Prolog, elle perd l'indépendance de langage |
| **Rigueur : déterminisme, reproductibilité** | Python 3.13, SWI 11.0.0 ; Stanza non épinglée dans `pyproject` | + JDK, Maven (versions épinglables dans `deps.edn`) : une chaîne d'approvisionnement de plus | idem B | Une chaîne en moins pour K ; Stanza reste à épingler |
| **Maintenabilité : langages et chaînes** | 2 langages, pip + PPA SWI + UDPipe (C++) + 2 scripts shell | 3 (Clojure, Prolog, Python minimal) ; + JVM, Clojure CLI, Maven | 3 | 2 ; Python limité à l'oracle et à Stanza |
| **Maintenabilité : compétences, CI** | Rôles d'agents `prolog-engineer` et `python-engineer` existent (`ORGANISATION_AGENTS.md §2`) ; CI GitHub existante | **Aucun rôle Clojure** : à qualifier selon §6 du même document ; CI à étendre (JDK, cache Maven) | idem B | Rôle Prolog existant ; CI simplifiable (pas de `numpy`, `pytest` nécessaire seulement pour l'oracle) |
| **Coût de migration** | Nul | **Élevé** (B-total ; B-partiel selon l'étendue) : jusqu'à ≈ 12 750 lignes touchées (c + e + f, tests compris), toutes les mesures à rejouer | **Faible à moyen** : code nouveau en Clojure ; les compilateurs Python peuvent rester ou migrer (237 l.) | **Faible (D-minimal)** à **moyen (D-complet)** : compilateurs (237 l.) ; outils de mesure (5 646 l.) seulement si on le décide |
| **Risque pour tests et mesures acquis** | Nul | **Élevé** (un portage change les bibliothèques sous-jacentes ; mon essai a trouvé une divergence de ce type entre Python et Prolog, §6.5) | Faible (aucun existant touché) | Faible (D-minimal) ; moyen si les outils migrent |
| **Adéquation à K : sources, provenance, versions** | Dataclasses figées + TSV/JSON (mon essai) | Maps immuables + EDN avec étiquettes (`#inst`, étiquettes propres : vérifié (doc)) | idem B | Faits Prolog ; la notation Prolog est la sortie de compilation elle-même |
| **Adéquation à K : statuts et invariants** | Contrôles impératifs | `spec`/`malli`, génération de cas | idem B | Règles déclaratives, tests plunit avec `forall` |
| **Adéquation à K : fédération de ressources hétérogènes** | stdlib pour tab/XML/zip/bz2 ; **RDF : dépendance à ajouter** (rdflib non installée) | JVM : Jena (RDF, SPARQL, TDB, SHACL) ; **à télécharger** | idem B | tab/XML/Turtle/N-Triples dans la distribution (mesuré) ; xls : non ; passage à l'échelle complet de DBnary/AAT **non mesuré** |
| **Adéquation à K : compilation vers le noyau** | Écriture de faits à la main (j'ai dû écrire l'échappement : un caractère de contrôle est sorti brut) | idem (chaînes) | idem | `format` avec `~q` : écriture native des chaînes et des atomes ; pas de traduction de syntaxe à écrire |

Aucune ligne ne somme ni ne classe les colonnes.

### 4.3 Notes par architecture (ce qui est établi, ce qui ne l'est pas)

**A.** Établi : zéro coût, tous les tests et mesures restent valides. Non établi : si le prototype Python de K
(`outils/ressources/`, lecture du Turtle par expressions régulières) tient pour DBnary et l'AAT sans dépendance RDF ; les
bibliothèques RDF Python n'ont pas été installées ni mesurées.

**B.** Établi : Stanza impose Python ou un changement d'analyseur. Non établi : la capacité des agents à écrire du Clojure
de qualité égale (`ORGANISATION_AGENTS.md §6` : « l'équivalence ne se présume pas »). Non exécuté : toute la pile
Clojure.

**C.** Établi : aucune migration obligatoire ; le troisième langage entre par du code nouveau. Non établi : le gain réel
de Clojure sur Python pour la construction de K est **non mesuré** ; il tient aux bibliothèques JVM (Jena) et à `spec`, pas
à une capacité de langage absente de Python ou de Prolog.

**D.** Établi : l'ingestion RDF/SKOS et la compilation en faits sont natives (mesuré) ; l'oracle peut rester en Python.
Non établi : le comportement de SWI-Prolog sur le Turtle complet de DBnary (1,30 Go décompressés ; extrapolation linéaire
de 60 Mo : ≈ 230 s CPU et ≈ 5 Go de mémoire pour tout charger, **non mesurée**) ; la lecture du `.xls` ; le risque
d'échecs silencieux (§6.5).

---

## 5. Chevauchements entre Clojure et Prolog

Sources : documentation citée au §8. Je dis explicitement ce qui est lu dans la documentation et ce que j'infère.

| Axe | Prolog (SWI 11) | Clojure | Capacité propre | Duplication |
|---|---|---|---|---|
| **Programmation relationnelle** | Unification, retour arrière en profondeur, coupure, négation par échec, tabling SLG ; sections du manuel : tabling à subsomption de réponses (dirigé par modes), sémantique bien fondée, tabling incrémental, monotone, partagé (sommaire, vérifié (doc)) | `core.logic` 1.1.1 : « Prolog-like relational programming, constraint logic programming, and nominal logic programming » ; implémentation de miniKanren d'après la thèse de Byrd (README, vérifié (doc)). API : `conda`, `condu`, `nafc`, `tabled`, `defne` (cljdoc, vérifié (doc)) | Prolog (inféré) : tabling, base de faits dynamique, recherche déterministe. Clojure : relations pures et recherche complète (miniKanren : lecture de Byrd 2009 et Friedman et al. 2005, non reprise ici) | **Réécrire le noyau en `core.logic` serait de la duplication coûteuse** : le noyau utilise `call_with_time_limit`, `:- table`, `assert/retract` par module, 24 lignes contenant `\+` dans `satisfaction.pl`, `findall`, `forall` (lu : `grep`). Ces mécanismes n'ont pas d'équivalent relationnel direct (inféré) |
| **Manipulation symbolique** | Termes, unification, DCG (utilisées : `notation.pl`), `term_to_atom`, dicts | Données immuables, destructuration, macros ; code comme données | Prolog : la sortie compilée du projet est déjà du Prolog (aucune sérialisation). Clojure : valeurs persistantes et égalité par valeur (« All of the Clojure collections are immutable and persistent » ; « proper value equality semantics », vérifié (doc)) | Les termes Prolog sont immuables hors `setarg` (inféré) : l'immutabilité n'est pas un avantage propre de Clojure face à Prolog, elle l'est face à Python |
| **Représentation des connaissances** | Faits et modules ; `.qlf` ; indexation de clauses ; `library(semweb/*)` | EDN : « extensible data notation », sans schéma, avec étiquettes (vérifié (doc)) ; `spec`/`malli` pour les schémas | Clojure : schémas en données et génération. Prolog : faits directement consultables par le noyau | EDN et faits Prolog sont deux sérialisations du même contenu ; une seule doit être la source (§7) |
| **Satisfaction de contraintes** | `library(clpfd)` (Triska 2012), CHR (« K.U.Leuven CHR system » : vérifié (doc)). **Note** : le manuel indique « Development of this library has moved to SICStus Prolog » (vérifié (doc)) | `clojure.core.logic.fd` : `fd/in`, `fd/interval`, `distinct`… (cljdoc) ; solveurs JVM existants (non vérifié) | Aucune des deux n'est requise aujourd'hui : « Ce qui n'est pas nécessaire : un solveur de contraintes général dans le noyau » (lu : `INTERPRETATIONS_ADMISSIBLES.md §9.7`) | Si la supervaluation demande un solveur plus tard, SWI en a déjà deux (CLP(FD), CHR) ; passer à `core.logic.fd` ne ferait que dupliquer |
| **Métaprogrammation** | `term_expansion/2`, `goal_expansion/2` : crochets de réécriture au chargement, étendus par module ; limites : interactions difficiles, macros non exportables, mal outillées (vérifié (doc)). Le dépôt n'utilise ni `term_expansion`, ni `goal_expansion`, ni CHR, ni `clpfd` (lu : `grep` sur tous les `.pl`) | Macros : « the compiler to be extended by user code » ; `defmacro`, `&form`, `&env` (vérifié (doc)) | Clojure (inféré) : macros plus uniformes ; hygiène et `syntax-quote` non couverts par la page consultée (**non vérifié**). Prolog : DCG traduites par expansion | Pas de besoin identifié pour K (la compilation de K est une écriture de faits) |

**Où un langage apporterait une capacité que l'autre n'a pas (inféré, à partir des sources ci-dessus) :**
- Clojure/JVM : **bibliothèques RDF et validation de graphes** (Jena : SHACL ; SHACL est une Recommandation du W3C du
  20/07/2017, « a language for validating RDF graphs against a set of conditions ») ; `spec`/`malli` comme schémas en
  données avec génération de cas (`s/gen` repose sur `test.check`).
- Prolog : **le noyau, ses garanties et sa base de faits** ; l'ingestion RDF de base sans installation ; l'écriture
  native de la sortie compilée ; la proximité avec l'énoncé d'un invariant.
- Aucun : relationnel pur, contraintes finies, macros : **duplication** pour ce projet.

---

## 6. Expérimentation

### 6.1 Pourquoi la faire

Le §4 laisse ouvertes trois questions que seul un essai éclaire : (i) à quoi ressemble la construction d'une entrée de K
(provenance, alignements, versions, statuts, invariants, vote) dans chaque langage ; (ii) si les invariants sont
contrôlables de façon comparable ; (iii) si une duplication volontaire (deux implémentations) révèle des défauts de
spécification. L'étude ne pouvait pas conclure sur (i) à (iii) sans exécution. **Je n'ai pas pu exécuter Clojure** (consigne).

### 6.2 Conception

Spécification neutre : `experience/spec/SPEC.md`, écrite avant les implémentations ; révisée deux fois : INV5 (domaine du statut) avant la première exécution, la normalisation du vote après l'exécution à l'échelle complète (§6.5).
- **Entrées** (lues seulement, jamais exécutées ; `python3 -I`) : WOLF dans OMW 1.4 (`wn-data-fra.tab`, CeCILL-C), WoNeF
  0.1 F-score (`wonef-fscore-0.1.xml.bz2`, du 03/07/2013 ; licence discordante, traitée CC-BY-SA par prudence comme dans
  `MESURE_RESSOURCES_LEXICALES.md §10`), WordNet 3.0 (`dict/data.*`) pour l'ensemble des identifiants du pivot. Leurs
  empreintes SHA-256 sont dans les sources de K.
- **Sorties** (`k.tsv`, quatre types) : **S** sources (ressource, version, empreinte, couche de licence, famille) ;
  **A** alignements (de ressource/version/identifiant vers `WordNet 3.0`) ; **E** entrées `lexicalisation` (lemme français,
  synset, source, localisateur, méthode, statut, attestation) ; **V** votes (par couple lemme normalisé × synset : familles,
  rang, entrées). Statuts du langage de référence : `attestee` / `non_attestee`. Un littéral `_EMPTY_` ne crée aucune entrée
  (une absence vaut « inconnu »).
- **Neuf invariants** contrôlés : `INV1` pas d'entrée sans source (ressource, version, empreinte) ; `INV2` pas d'alignement
  sans version aux deux bouts ; `INV3` alignement vers WordNet 3.0 et vers un identifiant existant ; `INV4` **un vote classe
  sans attester** ; `INV5` attestée ⇔ attestation ; `INV6` unicité des identifiants ; `INV7` toute entrée est alignée ;
  `INV8` rang du vote = nombre de **familles** distinctes (les versions d'une même famille ne comptent qu'une fois, d'après
  `MESURE_RESSOURCES_LEXICALES.md §7.3`) ; `INV9` couche de licence cohérente.
- **Compilation** vers des faits Prolog (`k_federe` : `k_source/6`, `k_sens/5` = `K:sens/3` plus entrée et statut,
  `k_vote/4`), **refusée** si une violation existe.
- **Mutants** : 18 bases (1 saine, 16 à défaut unique, 1 témoin légitime), attendus écrits à la main d'après la spécification.

### 6.3 Protocole

- **Critères** : (1) correction contre les invariants (défauts détectés ; fausses alertes sur le témoin) ; (2) accord des
  deux implémentations (octets de `k.tsv`, termes des faits compilés) ; (3) lisibilité : **je n'ai pas de mesure
  indépendante** ; proxies : lignes de code par section (`commun/loc.py`), jugement qualitatif d'un seul lecteur (moi),
  signalé comme tel ; (4) taille ; (5) temps (médiane de 5 essais pour l'échantillon, 3 pour l'échelle complète ; pic de
  mémoire) ; (6) dépendances ; (7) testabilité : suite native de chaque langage (pytest ; plunit).
- **Échantillon** : 400 synsets tirés par empreinte (`sha256(graine:identifiant)`, graine `audit-langages-1`), stratifiés :
  200 présents dans WOLF et WoNeF, 100 WOLF seul, 100 WoNeF seul (population : 34 264 / 24 827 / 19 415) → 524 lignes
  WOLF, 300 éléments `SYNSET` WoNeF, 656 littéraux non vides. **Échelle complète** : 78 506 synsets, 102 671 couples WOLF,
  115 405 couples WoNeF.
- **Équité** : l'extraction (bz2, tirage) est commune ; chaque langage lit lui-même le tab et le XML (ElementTree contre
  `library(sgml)` + `xpath`), calcule les alignements, les entrées, les votes, contrôle, compile.
- **Limites** : un seul auteur pour les deux versions (l'accord entre elles n'est **pas** une preuve de justesse) ;
  pas d'optimisation ; les mutants et la spécification sont de moi.

### 6.4 Résultats (mesuré)

Reproduction : `experience/rejouer.sh SORTIE_DIR` (dossier neuf ; `... complet` pour l'échelle complète).

**Correction.**

| | Python | Prolog |
|---|---|---|
| `k.tsv` à 400 synsets (2 765 lignes : 3 S, 600 A, 1 180 E, 982 V) | identique à l'octet (`cmp`) | identique |
| `k.tsv` à l'échelle complète (112 770 A, 218 076 E, 179 918 V) | identique à l'octet | identique |
| Faits compilés, 400 synsets (1 180 `k_sens`, 982 `k_vote`) | termes identiques | termes identiques (2 165) |
| Faits compilés, échelle complète | termes identiques (397 997) ; **octets différents** : 16 entrées avec U+009C (Python l'écrit brut, Prolog l'échappe) | (idem) |
| Violations sur la base saine, 400 synsets et échelle complète | 0 | 0 |
| Mutants avec défaut (sur l'échantillon de 400 synsets) : défaut attendu détecté / manqué | 16 / 0 | 16 / 0 |
| Témoin légitime (M15) : fausses alertes | 0 | 0 |
| Bases dont la sortie est **exactement** l'attendu (saine, 16 fautives, témoin) | 17 / 18 | 17 / 18 |
| Compilation d'une base fautive | refusée (`ValueError`) | refusée (`compilation_refusee`) |

Un cas sort de l'attendu (M01, source inexistante) : les deux implémentations rendent **un résultat de plus** que mon attendu :
`INV8_VOTE` sur le vote qui cite l'entrée orpheline (la famille ne peut plus être établie). **Je n'ai pas modifié
l'attendu** d'après la sortie. C'est une ambiguïté de la spécification (INV8 ne dit pas si un vote dont une entrée n'a pas
de source viole aussi INV8). Les deux suites natives rendent le même résultat : pytest « 18 réussis, 1 échec (M01) »,
plunit « 18 réussis, 1 échec (M01) ».

**Taille** (lignes de code hors blancs, commentaires, docstrings ; `commun/loc.py`).

| Section | Python | Prolog |
|---|---|---|
| modèle des données | 21 | 6 |
| lecture / écriture du format canonique | 14 | 23 |
| construire | 41 | 65 |
| contrôler (9 invariants) | 38 | 33 |
| compiler + ligne de commande | 36 | 30 |
| total (hors en-tête) | **150** (159 avec l'en-tête) | **157** (167) |
| tests natifs (pytest ; plunit) | 18 | 22 |

**Temps et mémoire** (médiane ; `commun/chrono.py`).

| Étape | 400 synsets, Python | 400 synsets, Prolog | Échelle complète, Python | Échelle complète, Prolog |
|---|---|---|---|---|
| construire | 56 ms | 81 ms | 3,9 s (4,7 ; 3,9 ; 3,7), 661 Mio | 17,7 s (18,1 ; 17,4 ; 17,7), 686 Mio |
| contrôler | 87 ms | 252 ms | 2,6 s, 468 Mio | 22,8 s (22,0 ; 22,8 ; 25,0), 690 Mio |
| compiler | 74 ms | 213 ms | 3,4 s, 556 Mio | 25,2 s, 796 Mio |
| démarrage de l'interpréteur nu | 24 ms | 11 ms | | |

**Dépendances.** Python : bibliothèque standard seule (`xml.etree`, `unicodedata`, `dataclasses`, `json`). Prolog : bibliothèques
livrées avec SWI-Prolog 11.0.0 (`sgml`, `xpath`, `unicode`, `json`, `readutil`, `apply`, `lists`, `pairs`). Aucune
installation.

**Mesures annexes sur le Turtle** (`commun/turtle_prolog.pl`, `library(semweb/turtle)` et `rdf11`) :
liste Joconde th291 : 22 764 triplets en 0,18 s CPU ; th285 : 303 670 triplets, 32 895 concepts SKOS, 2,7 s CPU ;
DBnary fr (60 premiers Mo du Turtle, tronqués à la dernière phrase complète) : 994 427 triplets en 10,4 s, pic 237 Mio.

### 6.5 Ce que l'essai a montré (observations ; certaines sont anecdotiques)

1. **Une divergence de spécification n'est apparue qu'à l'échelle complète** et seulement parce que deux langages ont été
   exécutés : la v1 disait « minuscules ». Pour « İstanbul » (U+0130), `str.lower()` de Python donne deux caractères
   (correspondance complète), `string_lower/2` de SWI-Prolog un seul (correspondance simple) : deux clés de vote
   différentes (un vote côté Prolog contre deux côté Python, sur 179 918 : `resultats/v1_divergence/`). La v2 précise « NFC, pliage de casse complet,
   NFC » ; elle donne la même clé dans les deux langages sur les 90 836 lemmes distincts (vérifié). La divergence de la
   v1 est **gardée**. *Lecture (inférée)* : c'est l'argument pour qu'une duplication d'implémentation soit tolérée quand
   la spécification a des termes du métier flous ; ici elle a coûté une exécution de plus et a trouvé une vraie
   ambiguïté.
2. **Défaut silencieux côté Prolog (mon erreur, un seul auteur).** Ma première version de `construire_wonef` ne produisait
   aucune entrée WoNeF : `xpath(Lit, self(text), …)` échouait, le `forall` avec `Lits == [] -> true` masquait l'échec, le
   programme rendait le code 0. Seul le `cmp` contre la sortie Python l'a montré. Trois autres erreurs relevées à la relecture
   (une coupure qui masquait des violations, une énumération sous-liée, un type atome/chaîne). Python : aucune erreur
   fonctionnelle à la première exécution. **Inféré, à confirmer sur d'autres auteurs** : en Prolog, l'échec est une
   issue normale ; la règle du projet « aucun repli silencieux » demande donc un motif défensif explicite (lever une erreur
   quand un ensemble attendu est vide) ; en Python l'exception est la valeur par défaut.
3. **Écriture des faits Prolog.** `~q` écrit les chaînes avec leur échappement ; ma version Python, écrite à la main, a
   émis le caractère de contrôle U+009C brut dans un littéral : il se charge dans SWI-Prolog (218 076 faits), mais n'est pas
   l'écriture canonique. C'est une fragilité de la traduction de syntaxe, pas une erreur de logique.
4. **Faits sur les données** (mesuré, indépendants du langage) : les 112 770 alignements pointent tous vers un identifiant
   de WordNet 3.0 (INV3 : 0 violation) ; **16 entrées WOLF (7 lemmes distincts : cœur, œil, œillet, œsophage, œuvre, manœuvre, nœud) contiennent U+009C à la place de « œ »** (l'octet 0x9C est « œ » en cp1252 : **inféré** : un défaut de décodage dans le fichier OMW) ; 849 littéraux WoNeF sans `lnote` ; sélecteurs WoNeF :
   72 460 `monosemous`, 15 531 `levenshtein`, 8 727 `uniq`, 7 755 `multiplesource`, 4 326 `hyperhypo`, 2 905 `hyperlike`,
   1 998 `simsyn`, 854 `meroholo` ; **81 % des 179 918 couples (lemme, synset) n'ont qu'une famille** (145 627), 19 %
   (34 291) deux. Le chiffre 81 % est un fait de construction, pas une précision : voir `MESURE_RESSOURCES_LEXICALES.md §7.3`
   pour ce que vaut le nombre de familles.
5. **Les deux langages donnent des résultats de correction équivalents sur cet essai** (16 / 16 défauts détectés,
   0 fausse alerte) : sur ce critère, **aucun ne se détache** (inféré, avec les limites du §6.3).

### 6.6 Ce que l'essai ne montre pas

- Il ne dit rien de Clojure : ni la taille, ni la lisibilité, ni la correction.
- Il ne prouve pas que la construction de K sur DBnary ou l'AAT complets tient en Prolog ; une extrapolation linéaire
  existe (§4.3, D) mais n'est pas une mesure.
- Il ne mesure pas la lisibilité par un lecteur indépendant ; il ne mesure pas le coût d'écriture par un agent.
- Il ne teste pas le vote lui-même comme jugement de qualité (la valeur du vote est dans `MESURE_RESSOURCES_LEXICALES.md §7`).
- Les temps de Prolog ne sont pas optimisés (contrôle par `assertz` et énumération) : un facteur 5 à 9 n'est pas une
  propriété du langage (inféré).

### 6.7 La version Clojure : décrite, non exécutée

**Ce qu'elle serait** (conception, **non vérifiée** à l'exécution) :
- `deps.edn` avec `org.clojure/clojure` (la page des outils cite la version 1.12.0 comme exemple) ; pour l'XML : `org.clojure/data.xml`
  (**non vérifié** qu'il convienne à cette version) ; `clojure.spec.alpha` (le guide de spec est « written against Clojure 1.9.0 or higher » : vérifié (doc) ; que
  `spec.alpha` soit une dépendance du jar Clojure : **non vérifié ici**) ; option `malli` (EPL-2.0 ; vérifié (doc)) et
  `org.clojure/test.check` (EPL-1.0, v1.1.3 ; vérifié (doc)) pour les tests génératifs.
- Quatre types de données comme maps immuables ; une spécification `s/keys` par type ; les invariants entre enregistrements
  comme neuf fonctions pures sur la base (`group-by`, ensembles) ; un `clojure.test` qui rejoue les 18 bases ; sortie EDN
  triée puis conversion vers le même `k.tsv` pour comparaison à l'octet ; faits Prolog écrits par formatage de chaînes (même
  problème d'échappement qu'en Python, §6.5.3).
- Pas de `core.logic` : la construction de K n'a pas de recherche relationnelle à faire (inféré).

**Ce qu'il faudrait pour l'exécuter** (à soumettre à la propriétaire, **rien n'a été installé**) :
1. Le JDK est déjà présent (`openjdk 21.0.13`, mesuré).
2. Installer le Clojure CLI (`clj`/`clojure`) *ou* disposer des jars (clojure, spec.alpha, core.specs.alpha, data.xml, et pour les
   tests `test.check`) : **téléchargement depuis Maven Central ou Clojars**, soit un accès réseau et un cache `~/.m2`
   (la page des outils décrit ce mécanisme ; vérifié (doc)). Le volume exact n'est pas mesuré.
3. Un `deps.edn` figeant les versions ; lancer les mêmes étapes (une variante de `rejouer.sh`) et
   comparer `k.tsv` et les termes compilés avec `cmp` et `comparer_faits.pl`.
4. Effort d'écriture estimé : de l'ordre de la taille des deux autres versions (150 à 170 lignes) ; **estimation
   non mesurée**.

---

## 7. Éléments de décision

Pas de recommandation. Pour chaque option : ce qui l'impose ou la départage.

### 7.1 Ce qui départage les architectures

| Question à trancher | Si la réponse est… | … alors (inféré) |
|---|---|---|
| **Stanza reste-t-elle l'analyseur de référence (D20) ?** | oui | Python reste en production ; B-total est exclu sans rejouer D18 bis et D20 bis ; la comparaison porte sur C contre A contre D |
| **L'indépendance de l'oracle tient-elle au langage ou au procédé ?** | au procédé (« lire la spécification seule ») | l'oracle peut vivre dans n'importe quel langage ; réécrire en Clojure n'apporte rien de plus que ce qu'apporte le procédé |
| | au langage (différent de Prolog) | Python ou Clojure ; garder Python évite 4 928 lignes de réécriture (A, C, D) |
| **La future K a-t-elle besoin d'une bibliothèque RDF à grande échelle (DBnary 1,30 Go de Turtle décompressé ; AAT 139 Mo en N-Triples compressés) avec validation SHACL ?** | oui, avec validation de graphes | Jena (JVM) est le seul des trois à l'offrir ici, au prix d'un troisième langage (C, B) |
| | non : on filtre puis on compile des sous-ensembles | SWI-Prolog le fait déjà sans installation (D), sous réserve d'une mesure sur DBnary et l'AAT complets ; Python demande `rdflib` (A) |
| **Le schéma des entrées de K doit-il exister en une seule définition exécutable ?** | oui | éviter C : trois définitions (EDN/spec, Prolog, Python) ; préférer D (deux, dont une voulue indépendante) ou A |
| **Quel risque est acceptable pour les mesures acquises ?** | aucun | A, C ou D-minimal ; B est le plus risqué |
| **Qui écrit le code ?** (`ORGANISATION_AGENTS.md §6`) | une qualification de rôle est exigée avant tout nouveau langage | le coût d'entrée de Clojure inclut la qualification d'un rôle d'agent |

### 7.2 Résumé de ce que chaque option implique

- **A** : continuer en Python pour K ; garder l'oracle ; coût nul ; deux chaînes. Conserve la lecture du Turtle par
  expressions régulières tant qu'aucune bibliothèque RDF n'est ajoutée.
- **B** : le plus cohérent *si* Stanza est remplacée ou isolée en exécutable ; le plus coûteux ; le plus risqué.
- **C** : Clojure pour le code nouveau de K ; le moins invasif des deux options Clojure ; trois langages, trois définitions du
  schéma de K.
- **D** : K en Prolog ; deux langages ; cohérence maximale du raisonnement et de la compilation ; il faut mesurer le passage
  à l'échelle sur DBnary et l'AAT ; la règle « aucun repli silencieux » demande un motif défensif dans le code Prolog
  (§6.5, observation 2).

### 7.3 Points à trancher ou à clarifier (escalades) avant tout développement de K

1. **`raisonnement.pl` et la CLI** : la commande actuelle appelle le raisonneur T1/T2 ; le noyau + `codage.pl` ne sont
   appelés que par les outils et les tests. Options : (i) la CLI reste sur T1/T2 jusqu'à la bascule vers `codage.pl` ;
   (ii) la CLI bascule d'abord ; (iii) T1/T2 est classé « (b), à retirer » et K cesse de dépendre de
   `raisonnement:normaliser_nom`. La classification (b)/(a) de ce fichier en dépend.
2. **Python à l'appel (PLAN_V1) contre « ni Python ni Janus à l'exécution » (CAHIER §11)** : une bibliothèque Python
   d'appel est-elle un emballage (Janus) ou hors périmètre ? Le `pyproject.toml` actuel pointe sur l'ancienne CLI.
3. **Vocabulaire des statuts de K** : `LANGAGE_REFERENCE.md §1.10` : `attestee` / `non_attestee` (deux valeurs) ;
   `MESURE_RESSOURCES_LEXICALES.md §11.2` : `propose` / `attesté` / `rejeté` (trois valeurs, dont `rejeté`, fait positif).
   Mon essai a suivi le premier ; le second contient une distinction (le rejet) que le premier n'a pas.
4. **Licence des listes Joconde (contradiction constatée)** : `MESURE_RESSOURCES_LEXICALES.md §10` écrit « Licence ouverte
   Etalab ; l'export Turtle ne porte aucun triplet de licence ». Mesure : **13 des 16 exports** (th284 à th306 sauf th302,
   th305 et th306) déclarent `dcterms:rights "CC-BY-SA"` sur leur `skos:ConceptScheme` (lu :
   `/home/user/donnees/ressources/joconde_vocabulaires/th*.ttl`, expression régulière sur le bloc du schéma) ; en outre
   2 188 occurrences de `dcterms:rights "Wikidata_rest"` (th305 : 2 187 ; th290 : 1). Si CC-BY-SA est la licence effective, la couche
   « licence » de K change (partage à l'identique). **Non tranché ici.**
5. **Où vivent les invariants de K** : à la construction (Python/Prolog/Clojure), au chargement (module `k_federe` qui se
   contrôle) ou dans la sémantique (noyau et interpréteur de référence : « une entrée non attestée ne fonde qu'une
   hypothèse »). Les trois ne sont pas équivalents ; en choisir un évite la duplication.
6. **Les quatre copies de la table des statuts (D3)** : indépendamment du langage, une copie suffit.
7. **Qualité des données de WOLF dans OMW** : 16 entrées corrompues (U+009C pour « œ »). À signaler à la construction (un onzième
   invariant, ou un statut de lemme).
8. **Épinglage des versions** : Stanza 1.10.1 et `xlrd` ne sont pas dans `pyproject.toml`.

---

## 8. Références (vérifiées le 28/11/2026)

**Articles et ouvrages**
- Qi, P., Zhang, Y., Zhang, Y., Bolton, J., Manning, C. D. (2020). *Stanza: A Python Natural Language Processing Toolkit for Many
  Human Languages*. ACL 2020, System Demonstrations, p. 101-108. DOI 10.18653/v1/2020.acl-demos.14. https://aclanthology.org/2020.acl-demos.14/
- Reimers, N., Gurevych, I. (2019). *Sentence-BERT: Sentence Embeddings using Siamese BERT-Networks*. EMNLP-IJCNLP 2019, p. 3982-3992.
  DOI 10.18653/v1/D19-1410. https://aclanthology.org/D19-1410/
- Straka, M., Hajič, J., Straková, J. (2016). *UDPipe: Trainable Pipeline for Processing CoNLL-U Files…*. LREC 2016, p. 4290-4297.
  https://aclanthology.org/L16-1680/ (licences : code MPL 2.0, modèles CC BY-NC-SA 4.0, d'après le résumé de recherche).
- Wielemaker, J., Schrijvers, T., Triska, M., Lager, T. (2012). *SWI-Prolog*. Theory and Practice of Logic Programming 12(1-2) : 67-96.
  DOI 10.1017/S1471068411000494.
- Swift, T., Andersen, C. (2023). *The Janus System: Multi-paradigm Programming in Prolog and Python*. arXiv:2308.15893.
  https://arxiv.org/abs/2308.15893 (résumé consulté ; texte intégral non ouvert).
- Desouter, B., Van Dooren, M., Schrijvers, T. (2015). *Tabling as a Library with Delimited Control*. TPLP 15(4-5) : 419-433.
  DOI 10.1017/S1471068415000137.
- Frühwirth, T. (1998). *Theory and practice of constraint handling rules*. Journal of Logic Programming 37(1-3) : 95-138.
  DOI 10.1016/S0743-1066(98)10005-5 (d'après des notices de catalogue).
- Triska, M. (2012). *The Finite Domain Constraint Solver of SWI-Prolog*. FLOPS 2012, LNCS 7294 : 307-316.
  DOI 10.1007/978-3-642-29822-6_24.
- Wielemaker, J., Schreiber, G., Wielinga, B. (2003). *Prolog-based Infrastructure for RDF: Scalability and Performance*. ISWC 2003,
  LNCS 2870 : 644-658.
- Byrd, W. E. (2009). *Relational Programming in miniKanren: Techniques, Applications, and Implementations*. Thèse, Indiana University.
- Friedman, D. P., Byrd, W. E., Kiselyov, O. (2005). *The Reasoned Schemer*. MIT Press (2ᵉ éd., avec J. Hemann, 2018).
- Hickey, R. (2020). *A History of Clojure*. Proc. ACM Program. Lang. 4 (HOPL), art. 71. DOI 10.1145/3386321.
- W3C, *SKOS Simple Knowledge Organization System Reference*, Recommandation du 18/08/2009 ; *PROV-O*, Recommandation du 30/04/2013 ;
  *Shapes Constraint Language (SHACL)*, Recommandation du 20/07/2017 (https://www.w3.org/TR/skos-reference/, /prov-o/, /shacl/).

**Documentation (pages ouvertes le 28/11/2026)**
- SWI-Prolog : tabling (`pldoc/man?section=tabling`) ; `library(clpfd)` (`section=clpfd`, avec la mention de
  déplacement du développement vers SICStus lue dans le HTML) ; `library(json)` ; PlUnit ; Janus ; chapitre CHR ;
  `term_expansion/2` ; paquet JPL (https://www.swi-prolog.org/packages/jpl/).
- Clojure : `reference/macros`, `reference/data_structures`, `guides/spec`, `guides/deps_and_cli` (https://clojure.org/) ;
  `clojure/core.logic` (README, v1.1.1) et cljdoc (`clojure.core.logic` 1.1.1) ; `metosin/malli` ; `edn-format/edn` ;
  `clojure/test.check` (v1.1.3, EPL-1.0) ; `clj-python/libpython-clj`.
- Apache Jena (https://jena.apache.org/) et son module SHACL (https://jena.apache.org/documentation/shacl/).

**Références non vérifiées** : l'énoncé précis d'avantages de Clojure sur Python/Prolog hors des pages citées ; l'existence de
solveurs de contraintes JVM nommés ; l'hygiène des macros Clojure ; la disponibilité de `data.xml` pour la version cible ;
un lecteur `.xls` pour SWI-Prolog.

---

## Annexe : fichiers produits

| Fichier | Rôle |
|---|---|
| `/home/user/donnees/audit_langages/AUDIT_LANGAGES.md` | ce document |
| `/home/user/donnees/audit_langages/classification/classer.py`, `classification_fichiers.tsv`, `graphe_charge.py` | classification par fichier, graphe de chargement Prolog |
| `/home/user/donnees/audit_langages/experience/spec/SPEC.md` | spécification neutre (v2) |
| `.../experience/py/construire_k.py`, `test_k.py` | version Python et ses tests (pytest) |
| `.../experience/pl/construire_k.pl`, `test_k.pl` | version Prolog et ses tests (plunit) |
| `.../experience/commun/` | extraction de l'échantillon, mutants, lanceur, comparaison de faits, chronomètre, lignes de code, mesure Turtle |
| `.../experience/echantillon/s400/`, `echantillon_complet/` | entrées extraites (MANIFESTE avec empreintes) |
| `.../experience/mutants/s400/` | 18 bases (M00 à M17) et `attendus.tsv` (écrits à la main) |
| `.../experience/resultats/` | `k_*.tsv`, faits compilés, temps, mutants, divergence de la v1 (`v1_divergence/`) |
| `.../experience/rejouer.sh` | rejeu de bout en bout dans un dossier neuf |

Les sorties à l'échelle complète (≈ 170 Mo : `k_*.tsv`, faits compilés) ne sont pas conservées ; seuls leurs temps
(`resultats/complet_v2/chrono_complet.tsv`) et la divergence de la v1 le sont. `rejouer.sh SORTIE complet` les régénère
(≈ 2 minutes).
