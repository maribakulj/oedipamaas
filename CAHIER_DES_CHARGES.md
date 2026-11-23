# oedipamaas V1 : cahier des charges

Statut : établi le 23 novembre 2026, après l'audit du socle 1.0 (révision `3fafdc0`) et une série de décisions de
cadrage. Ce document **prime** sur `CONCEPTION.md` là où ils divergent ; `CONCEPTION.md` sera mis à jour pour s'y
conformer (§ 15).

## 0. En bref

1. **Le produit** : un moteur hors ligne, rapide, déterministe, qui lit les textes que les humains ont déjà écrits sur
   les œuvres (cartels, notices, descriptions, textes savants, en français et en anglais) et en tire des codes
   Iconclass, chacun avec sa preuve. Une alternative aux LLM et à l'annotation manuelle, pas un client de l'un ou de
   l'autre.
2. **Critère de réception : l'indexation automatique.** Un code au statut *établi* doit pouvoir être écrit dans une
   base de collections sans relecture. Précision d'abord : l'abstention est un résultat normal ; un code faux présenté
   comme établi est la faute la plus grave.
3. **Aucun LLM à l'exécution.** Un analyseur syntaxique local et épinglé (UDPipe 1) donne la syntaxe ; tout le sens
   (rôles, négation, modalité, portée) et toute l'iconographie sont des règles SWI-Prolog.
4. **Le cœur est un langage d'assertions.** Le moteur ne raisonne pas sur des mots mais sur des assertions typées,
   chacune rattachée à son passage exact du texte. Tout ce qui lit une entrée (texte libre, JSON d'Opus, notice
   structurée) est un adaptateur qui produit ce langage.
5. **Tout Iconclass, certifié par type de preuve.** Les candidats sont cherchés dans toutes les divisions ; un code
   n'est *établi* que si une règle d'un type certifié le démontre. La V1 se définit par la liste de ses types de preuve
   certifiés, valables dans toute la classification, et non par une liste de divisions.

## 1. Thèse du produit

Presque toutes les œuvres exposées ou cataloguées ont un titre, un cartel ou une notice écrits par des spécialistes ;
très peu ont des codes Iconclass. Ce texte est une ressource immense, gratuite, déjà validée par des humains. Le moteur
la transforme en codes :

- **hors ligne et souverain** : rien ne quitte la machine de l'institution ;
- **rapide et sobre** : des millions de notices sur un ordinateur portable, sans GPU, sans coût par document ;
- **rejouable** : mêmes entrées, mêmes versions, mêmes octets en sortie ;
- **vérifiable** : chaque code établi montre le passage qui le justifie et la règle qui l'a tiré ;
- **honnête** : il dit ce qu'il n'a pas compris au lieu de deviner.

Les LLM (dont les descriptions d'Opus) restent utiles **pendant le développement** : comme point de comparaison, comme
entrée possible, comme aide à l'écriture de lexiques et de cas de test. Jamais dans le chemin d'exécution.

## 2. Usages

| Usage | Ce qu'il exige | Rang |
|---|---|---|
| Indexation automatique | précision des codes établis ≥ 95 % ; abstention plutôt qu'erreur | **critère de réception** |
| Aide au catalogage | candidats classés, preuves lisibles, rapport de relecture | servi par la même sortie |
| Données d'entraînement | volume, objets du texte rattachés aux codes, boîtes quand l'entrée en a (Opus) | servi par la même sortie |
| Recherche | mesures par type de preuve, reproductibilité, lignes de base | servi par l'évaluation (§ 12) |

En cas de conflit, l'indexation automatique l'emporte.

## 3. Périmètre

### 3.1. Entrées

| Entrée | V1 | Adaptateur |
|---|---|---|
| Texte libre FR ou EN : descriptions visuelles, cartels, notices, textes savants | oui | segmentation → UDPipe → CoNLL-U → règles d'interprétation (§ 6) |
| Titre seul (« Saint Jérôme pénitent », « Allegory of Vanity ») | oui | grammaire des titres (§ 6.3) |
| JSON d'Opus (schéma du § 13 de `CONCEPTION.md`) et ses variantes | oui | conversion directe en assertions ; les champs en prose passent par l'adaptateur texte |
| Notices structurées (champs titre, sujet, description ; LIDO, Dublin Core, JSON simple) | oui | correspondance de champs déclarée, chaque champ en prose passant par l'adaptateur texte |
| Assertions déjà écrites dans le langage du § 5 | oui | aucun : entrée directe, documentée |

Le moteur **ne dépend d'aucun schéma de descripteur** : le JSON d'Opus n'est qu'une entrée parmi d'autres.

### 3.2. Hors périmètre de la V1

- tout appel à un LLM ou à un service distant pendant le traitement ;
- l'analyse des images (pixels) ;
- les langues autres que le français et l'anglais (l'architecture ne doit pas les exclure : règles par langue sur un
  jeu d'étiquettes universel) ;
- un service HTTP (couche mince sur la bibliothèque, après la V1) ;
- la publication d'une probabilité non calibrée (§ 9) ;
- l'apprentissage en continu.

## 4. Principes non négociables

1. **Précision d'abord.** Toute incertitude (analyse syntaxique douteuse, référent ambigu, modalité, négation,
   alternative, propos qui ne porte pas sur l'image) fait descendre le statut : établi → candidat → abstention.
2. **Pas de preuve sans passage.** Toute prémisse d'un code établi pointe vers un passage du texte (positions en
   caractères) ou vers un fait de la base. Une assertion sans passage vérifiable n'est pas une prémisse.
3. **Indépendance du chemin de découverte.** Une notation trouvée par BM25, WordNet, un nom ou un gabarit est jugée par
   les mêmes conditions logiques.
4. **Une seule hiérarchie.** Un seul prédicat d'ascendance (celui de `arbre.pl`, avec gabarits, noms et lettres
   doublées) sert à la recherche, à la preuve, à la sélection, à la sortie et à l'évaluation.
5. **Isolation par document.** Aucun état d'un document ne subsiste dans le traitement du suivant ; la base est en
   lecture seule.
6. **Déterminisme.** Mêmes entrées, mêmes versions (moteur, base, analyseur et modèle, règles) : mêmes octets.
7. **Aucune donnée d'œuvre dans la base.** Ni Wikidata P1257, ni « depicts », ni codes de catalogues : ces données
   servent à mesurer, jamais à construire les règles (sinon la mesure est faussée).
8. **Langue à la main, iconographie dérivée.** Les règles linguistiques générales (négation, rôles, modalité, discours
   rapporté) sont écrites et testées à la main, pour le français et l'anglais. Toute la connaissance iconographique
   (personnes, attributs, épisodes, gabarits, clés) est tirée par programme d'Iconclass et des sources du § 8.

## 5. Le langage d'assertions (contrat central)

C'est l'interface entre la lecture et le raisonnement. Il est indépendant d'Iconclass, versionné, documenté et
validé à l'entrée du raisonnement. Schéma de principe (les noms définitifs seront fixés au jalon J1) :

| Fait | Sens |
|---|---|
| `doc(D, Langue, Genre)` | le document, sa langue, son genre (titre, cartel, description, texte savant…) |
| `passage(P, D, Debut, Fin)` | un passage du texte source, positions en caractères |
| `entite(E, Tete, P)` | un référent (figure, animal, objet, lieu, inscription), sa tête lexicale, son passage |
| `nom(E, Nom, P)` | un nom propre donné au référent (« Jérôme », « Goliath ») |
| `propriete(E, Prop, P)` | une propriété rattachée à ce référent précis (couronné, agenouillé, nu, rouge…) |
| `nombre(E, N)` | le nombre quand il est dit |
| `evenement(V, Predicat, P)` | une action ou une situation |
| `role(V, Role, E)` | agent, patient, instrument, destinataire, lieu… ; actif et passif ramenés aux mêmes rôles |
| `relation(E1, Rel, E2, P)` | relation orientée entre référents (tient, regarde, à côté de, sur…) |
| `polarite(A, pos\|neg)` | l'assertion A est affirmée ou niée |
| `modalite(A, affirme\|probable\|possible\|traditionnel\|ancien)` | « peut-être », « traditionnellement identifié comme », « autrefois attribué » |
| `portee(A, represente\|oeuvre\|autre_oeuvre\|source\|histoire)` | A porte-t-elle sur ce que l'image représente, sur l'objet (technique, état), sur une autre œuvre, sur une source textuelle, sur l'histoire de l'œuvre ? |
| `enonciateur(A, auteur\|cite(X))` | qui affirme A : l'auteur du texte ou une autorité citée |
| `alternative(G, [A1, A2, …])` | hypothèses mutuellement exclusives (« l'Annonciation ou la Visitation ») |
| `coref(E1, E2)` | deux mentions du même référent (« le saint… il… ») |
| `incompris(P, Raison)` | passage non interprété, avec la raison |

**Prémisse admissible** pour un code établi : une assertion de polarité `pos`, de modalité `affirme`, de portée
`represente`, d'énonciateur `auteur`, hors de toute `alternative`. Une assertion `neg` peut **contredire** un
candidat. Les autres alimentent les candidats, jamais les codes établis.

## 6. La lecture du texte libre

### 6.1. Chaîne

```
texte ─► segmentation (phrases, positions) ─► UDPipe 1 (modèle FR ou EN épinglé) ─► CoNLL-U
      ─► lecture du CoNLL-U (DCG Prolog) ─► règles d'interprétation (Prolog) ─► assertions (§ 5)
```

L'analyseur est un **programme externe** : UDPipe 1, binaire C++ hors ligne, lancé par Prolog (`process_create`) ou
exécuté à l'avance. CoNLL-U est la seule frontière : tout autre analyseur produisant du CoNLL-U (Stanza, UDPipe 2)
peut s'y substituer sans toucher au moteur. Le modèle et sa version font partie des empreintes de la sortie.

### 6.2. Phénomènes linguistiques couverts en V1 (FR et EN)

Chacun a ses règles, ses paires de tests minimales (§ 12.3) et son comportement en cas de doute.

| Phénomène | Exemples | En cas de doute |
|---|---|---|
| négation et sa portée | « sans lion », « no lion is visible », « ni crâne ni livre », « not a sword but a palm » | pas de prémisse positive |
| modalité | « peut-être », « probablement », « semble », « may represent » | candidat |
| identification rapportée ou ancienne | « traditionnellement identifié comme », « formerly called », « autrefois attribué à » | candidat |
| alternative | « l'Annonciation ou la Visitation » | hypothèses exclusives, aucune établie |
| rôles et voix | « David tue Goliath », « Goliath est tué par David », « un ange menacé d'une épée » | pas de code dépendant des rôles |
| rattachement des propriétés | « une femme couronnée à côté d'un homme » | propriété non rattachée : ignorée |
| coréférence simple | pronoms, reprises (« le saint », « la figure ») | référents distincts |
| portée du propos | « d'après une gravure de », « comme dans le tableau de Madrid », « inspiré d'Ovide », provenance, technique | hors `represente` |
| énumération et coordination | « un lion, un crâne et un livre » | chaque élément séparément |

### 6.3. Grammaire des titres

Les titres sont le texte le plus riche en Iconclass et le plus fréquent. Une grammaire dédiée (FR, EN) reconnaît les
formes canoniques : personne + qualificatif (« Saint Jérôme pénitent »), épisode (« Le Sacrifice d'Isaac »), personne
dans un lieu (« Saint Jérôme dans son étude »), allégorie (« Allégorie de la Vanité »), genre (« Nature morte au
homard », « Portrait d'homme »). Un titre est une assertion de portée `represente`, d'énonciateur `auteur` ; un titre
« dit » (« dit *La Belle Jardinière* ») est de modalité `traditionnel`.

## 7. Le raisonnement iconographique

### 7.1. Statuts

| Statut | Sens | Usage |
|---|---|---|
| **établi** | démontré par une règle d'un type certifié, sur des prémisses admissibles (§ 5), sans contradiction | écrit sans relecture |
| **candidat** | plausible (preuve partielle, type non certifié, prémisse non admissible), classé | proposé à la relecture, jamais écrit automatiquement |
| **contredit** | envisagé puis écarté par une négation ou une contradiction, avec la raison | traçabilité |

Un code établi affirme ses ancêtres (au sens du principe 4) ; la sortie ne les répète pas.

### 7.2. Types de preuve

Un type est **certifié** quand sa précision mesurée sur un corpus jamais vu atteint le seuil du § 12.2. La V1 vise la
certification des types T1 à T6 ; T7 à T11 produisent des candidats en V1 et seront certifiés version après version.

| Type | Règle | Conditions minimales |
|---|---|---|
| T1 nom explicite | une personne nommée → sa notation (11H(JEROME), personnages bibliques, dieux, héros) | nom non ambigu, ou ambiguïté levée par le contexte (Jean Baptiste / Évangéliste) ; prémisse admissible |
| T2 chose décrite | un référent décrit → la notation de son concept (lion → 25F23(LION)) | tête du référent, lien lexical égal ou montant (jamais descendant : « oiseau » ne dit pas « aigle ») |
| T3 titre conforme | le titre correspond au libellé ou aux mots clés d'une notation, dans la langue du titre | correspondance de structure, pas de mots isolés |
| T4 clé | une propriété (posture, vue, nombre, matière…) → la clé (+…) de la notation établie | propriété rattachée au même référent que la notation |
| T5 nom libre | un nom typé → le gabarit de son type (25G41(NOM)) | type du gabarit vérifié ; notation construite valide et rattachée à son parent |
| T6 repli | aucune preuve fine → l'ancêtre le plus spécifique démontré | toujours permis |
| T7 identité par attributs | combinaison d'attributs discriminants → la personne | jamais un attribut seul ; rareté calculée sur Iconclass |
| T8 épisode | participants + action + objets, avec rôles → l'épisode | conditions différentielles par rapport aux épisodes voisins |
| T9 spécialisation | d'un code établi, l'enfant dont le trait distinctif est décrit sur le même référent | trait distinctif propre, pas meilleure proportion |
| T10 lettre doublée | trait déclencheur de la section (féminin, opposé, fabuleux…) | sinon le jumeau simple |
| T11 symbole, allégorie | interprétation explicitement attribuée par le texte | jamais déduite de la présence d'un objet |

### 7.3. Recherche des candidats

On garde la recherche à plat du socle (BM25, lexique, WordNet, noms, gabarits, ancêtres) comme **générateur**,
alimenté désormais par les têtes, noms et propriétés des assertions plutôt que par des chaînes. Ses budgets sont des
paramètres, mesurés par une courbe rappel/coût (§ 12.2).

## 8. La base de connaissances

| Ressource | Rôle | Licence |
|---|---|---|
| Iconclass (`iconclass/data`, commit épinglé) | notations, arbre, libellés et mots clés FR et EN, clés, gabarits, renvois | CC0 |
| WordNet 3.0 (Princeton) ou Open English WordNet | lexique anglais, liens montants | type BSD ; CC BY 4.0 |
| Ressource lexicale française (WOLF / Open Multilingual Wordnet, à évaluer) | lexique français relié aux synsets | à vérifier (CeCILL-C pour WOLF) |
| Lemmes et étiquettes d'UDPipe | morphologie FR et EN à l'exécution | modèles UD : licences par treebank, à vérifier |
| Sources textuelles (Bible, Ovide) et index de personnes | indices pour T8 | domaine public ; CC BY(-SA) |

Les compilateurs restent en Python (outils de construction hors ligne) ; la base compilée est **publiée comme fichier
de version** (avec son manifeste et ses empreintes) pour que l'utilisateur n'ait besoin que de SWI-Prolog et d'UDPipe.

## 9. La sortie

Un objet JSON par document (JSONL pour un lot), sérialisation déterministe, plus un `manifeste.json` par lot.

```json
{"document": "inv-1234",
 "versions": {"moteur": "1.0.0+g…", "base": "iconclass <commit> ; wordnet <édition> ; …",
              "analyseur": "udpipe 1.x ; french-gsd-ud-2.x", "regles": "sha256:…", "entree": "sha256:…"},
 "etablis": [
  {"code": "11H(JEROME)", "libelle": "St. Jerome …", "type_preuve": "T1",
   "objet": "e1",
   "preuve": {"regle": "nom_explicite",
              "premisses": [{"assertion": "nom(e1, jerome)", "passage": [0, 14], "texte": "Saint Jérôme"}],
              "iconclass": ["11H(JEROME)"], "sous_preuves": []}}],
 "candidats": [{"code": "…", "type_preuve": "T7", "raison": "attribut seul", "preuve": {}}],
 "contredits": [{"code": "25F23(LION)", "raison": "négation", "passage": [41, 52]}],
 "objets": [{"id": "e1", "tete": "saint", "passage": [0, 14], "boite": null}],
 "incompris": [{"passage": [120, 188], "raison": "portée : autre œuvre"}]}
```

Aucune probabilité dans la V1 : la décision est déterministe, fondée sur les statuts et les types de preuve. Un champ
`p_catalogue` ne sera ajouté qu'après calibration mesurée sur les catalogues de référence.

## 10. Livrables

1. **Bibliothèque Prolog** : un module d'interface stable (`analyser(+Entree, +Options, -Resultat)`).
2. **Commande en ligne** pour le traitement par lot : JSONL ou dossier en entrée, JSONL et manifeste en sortie.
3. **Rapport de relecture HTML statique**, produit par la commande : texte, codes par statut, passages de preuve
   surlignés, incompris ; c'est l'outil du jugement des preuves (§ 12.4).
4. **Base compilée publiée** avec manifeste, et ses compilateurs.
5. **Documentation** : langage d'assertions, types de preuve, limites connues, installation, mise à jour.
6. **Suite de tests** (`plunit`) et intégration continue.
7. **Rapport de qualification** de la V1 (§ 12).

## 11. Exigences non fonctionnelles

| Exigence | Cible |
|---|---|
| Machine | ordinateur portable ordinaire, CPU seul |
| Latence (p95, un cœur) | titre ou cartel court ≤ 100 ms ; texte long (≈ 1 page) ≤ 2 s ; hors chargement de la base |
| Débit | linéaire en nombre de processus (un document par processus à la fois) |
| Chargement | base compilée (`.qlf`) chargée une fois par processus |
| Exécution | SWI-Prolog seul (plus le binaire UDPipe) ; ni Python ni Janus à l'exécution |
| Erreurs | entrée invalide → erreur structurée, comptée dans le manifeste ; jamais une sortie faussement réussie |
| Sécurité | aucun texte d'entrée n'est interprété comme code Prolog |
| Licence | code sous MIT |

## 12. Évaluation et réception

### 12.1. Corpus

- **Catalogues codés Iconclass avec leurs textes** (FR, EN) : sources publiques téléchargées par un script versionné
  (date, requête, empreinte), jamais versées au dépôt (§ 15 de `CONCEPTION.md`). Inventaire en annexe A.
- **Descriptions d'Opus** existantes : comme entrée, et pour comparer le moteur sur une description de modèle et sur le
  cartel humain de la même œuvre.
- **Annotation propre** : un corpus jugé à la main, en particulier pour la précision des codes établis.
- **Séparation stricte** : développement et test sur des collections distinctes ; une même œuvre (ou ses variantes de
  notice) jamais des deux côtés.

### 12.2. Mesures et seuils

| Mesure | Seuil de réception |
|---|---|
| Validité des codes émis (syntaxe, existence, parent) | 100 % |
| Codes établis avec preuve complète et passages vérifiés | 100 % |
| **Précision des codes établis**, par type de preuve certifié, jugée sur le texte | **≥ 95 %**, borne inférieure à 95 % de confiance ≥ 90 % (≈ 150 à 200 jugements par type) |
| Paires minimales (§ 12.3) | 100 % des invariants critiques |
| Déterminisme | sorties identiques à versions identiques |
| Couverture | part des documents ayant au moins un code établi : mesurée et rapportée, sans seuil en V1 |
| Rappel des candidats | rappel@N des codes que le texte permet de soutenir, en courbe selon le budget |
| Qualité d'ensemble | H-F1 et F1 exact contre le catalogue, comparés à BM25 et à la version 0.2 |

La précision des codes établis se juge **sur ce que le texte soutient**, par jugement à la main, et non par simple
comparaison au catalogue : les catalogueurs ne s'accordent qu'à moitié, et un code juste absent du catalogue n'est pas
une erreur.

### 12.3. Paires minimales

Une suite d'au moins 100 paires au jalon J1, 200 à la réception, en FR et en EN. Chaque paire ne diffère que par un
phénomène et énonce l'effet attendu : rôles inversés, négation, modalité, alternative contre conjonction, propriété
déplacée d'un référent à l'autre, titre « dit », propos sur une autre œuvre, répétition des mots, ajout d'une phrase
sans rapport. Invariants : un affaiblissement (affirmation → hypothèse, ajout d'une négation) ne fait jamais monter un
statut ; une phrase sur une autre œuvre ne change rien aux codes de l'œuvre décrite.

### 12.4. Jugement des preuves

Sur un échantillon de chaque type, on juge non seulement le code, mais la preuve : prémisses bien lues, règle
pertinente, conclusion juste. Un bon code avec une fausse preuve est compté comme un échec du type.

## 13. Reprise de l'existant

**Gardé** : compilateurs Iconclass, WordNet et décision ; grammaire des notations (`notation.pl`) ; arbre
(`arbre.pl`) ; libellés (`libelles.pl`) ; lexique et recherche (`lexique.pl`, `recherche.pl`) comme générateur de
candidats ; noms et gabarits (`noms.pl`) ; clés (`cles.pl`) ; tests existants.

**Corrigé d'abord** (jalon J0, défauts confirmés par l'audit) :
- noms libres sans parent ni ancêtres (`noms.pl`, `arbre.pl:36-47`) ;
- double hiérarchie : `plus_specifiques` sur `ancetre_syntaxique` (`decision.pl:145`) et ancêtres par préfixe de
  chaîne dans `preuve()` (`socle/moteur.py:56`) ;
- division 86 retirée après la sélection des K premiers (`decision.pl:139-140`) ;
- `f1_attendu` exporté mais jamais lu ;
- clés limitées aux appuis lexicaux directs (`cles.pl:100`) ;
- `oedipamaas expliquer` cassé (`cli.py:64`) ;
- sens des relations ignoré (`cadres.pl:245-250`) ; négation reconnue en début de mention seulement
  (`recherche.pl:77-81`) — remplacés à terme par le langage d'assertions.

**Remplacé** : `faits_description.py` et `mention/4` comme unité de raisonnement (par les adaptateurs et les
assertions) ; `socle/moteur.py`, `coder.py` et Janus (par l'exécution en Prolog) ; `preuve.pl` et `preuve()` (par
des preuves construites pendant la résolution) ; `specialisation.pl` et `cadres.pl` (par les types T2, T3, T9 sur des
assertions).

**Ligne de base seulement** : la version 0.2 (`moteur.py`, `regles/`) et le socle actuel, mesurés sur les mêmes
corpus. Les branches `relations`, `econome` et `noms` restent des références ; leurs apports (locutions WordNet, noms
composés, lettres doublées) sont repris un par un, chacun avec sa mesure.

## 14. Jalons

Aucune date : chaque jalon a un critère de sortie vérifiable.

| Jalon | Contenu | Critère de sortie |
|---|---|---|
| **J0** Remise en état | corrections du § 13 ; licence MIT ; intégration continue (tests unitaires sans base, et avec base sur demande) ; script de téléchargement des corpus ; mesure de référence de la 0.2 et du socle | les tests passent ; la mesure de référence est rejouable |
| **J1** Le contrat (≈ 4 à 6 semaines) | langage d'assertions v1 et son validateur ; chaîne UDPipe → CoNLL-U → assertions pour les titres et les phrases simples FR et EN (négation, rôles, coordination) ; 100 paires minimales ; T1, T2 et T6 de bout en bout avec preuves et passages ; sortie du § 9 | les paires de J1 passent ; un titre et un cartel courts donnent des codes établis avec preuves vérifiées. **Jalon de décision** : si la chaîne ne tient pas, on revoit l'architecture ici. |
| **J2** La mesure | corpus de développement et de test constitués ; rapport de relecture HTML ; premier jugement des preuves T1, T2 | précision mesurée par type, avec intervalles |
| **J3** Types complets | T3, T4, T5 ; modalité, identification rapportée, alternatives, coréférence simple ; grammaire des titres complète | T1 à T6 au seuil sur le corpus de développement |
| **J4** Textes longs | portée du propos (autre œuvre, source, provenance, technique) ; textes savants ; performances du § 11 | taux d'incompris rapporté ; latence et débit au niveau des cibles |
| **J5** Qualification | mesure sur collections jamais vues ; jugement des preuves ; documentation ; base publiée | tous les seuils du § 12.2 ; sinon, on retire de la liste certifiée les types qui échouent, sans abaisser le seuil |

Après la V1 : T7 à T11 certifiés un par un ; service HTTP ; autres langues ; probabilité calibrée.

## 15. Risques et décisions ouvertes

| Risque | Parade |
|---|---|
| UDPipe 1 se trompe sur les textes d'art (rattachements, vocabulaire) | règles prudentes : un arbre douteux donne de l'abstention ; CoNLL-U permet de changer d'analyseur ; mesure de l'effet de l'analyseur |
| Les cartels réels décrivent peu l'image | grammaire des titres en priorité ; couverture rapportée honnêtement |
| Les textes savants parlent surtout d'autre chose que l'image | portée du propos explicite ; abstention attendue et mesurée |
| Presque aucun corpus français public codé en Iconclass (annexe A) | corpus français annoté à la main dès J2 ; emblèmes de Glasgow si leur usage est autorisé |
| Ressource lexicale française de licence ou de qualité insuffisante | mots clés FR d'Iconclass d'abord ; évaluation de WOLF/OMW au J1 |
| Les codes des catalogues sont incomplets ou d'un style propre | précision jugée sur le texte (§ 12.2) ; le catalogue sert au rappel et à l'H-F1 |
| Travail seul : la langue est un chantier sans fin | liste fermée de phénomènes (§ 6.2) ; tout le reste va dans `incompris` |
| Dérive des règles vers un corpus | séparation par collection ; toute règle accompagnée d'un exemple, d'un contre-exemple et d'une mesure |

**Décisions ouvertes**, à trancher au plus tard au jalon indiqué :
- noms définitifs et sérialisation du langage d'assertions (J1) ;
- ressource lexicale française (J1) ;
- modèles UDPipe retenus et leurs licences (J1) ;
- corpus de référence retenus (J2, d'après l'annexe A) ;
- mise à jour de `CONCEPTION.md` (J1).

## Annexe A. Corpus de référence candidats

Inventaire du 23 novembre 2026 (requêtes d'essai seulement, rien téléchargé). Aucun jeu de référence public n'associe
directement des textes FR ou EN à des codes Iconclass : chaque corpus est à moissonner et à filtrer.

| Corpus | Texte | Codes posés par | Taille | Licence | Accès |
|---|---|---|---|---|---|
| **RKDimages** (RKD Knowledge Graph) | titres EN et NL ; peu de descriptions | documentalistes du RKD | ≈ 76 000 images codées | ODC-By 1.0 (attribution) | SPARQL `api.rkd.triply.cc/…/sparql`, par pages (les requêtes larges expirent) |
| **Wikidata P1257** | libellés courts : ≈ 34 500 EN, ≈ 7 400 FR ; descriptions génériques | mélangé : imports de robots (CbDD, RKD), souvent sans référence | ≈ 64 600 œuvres, ≈ 11 700 codes distincts | CC0 | `query.wikidata.org/sparql` |
| **French Emblems at Glasgow** (et Alciato at Glasgow) | devises et épigrammes **français** du XVIe s., avec traductions anglaises ; codes « image » et « texte » séparés | indexeurs experts | ≈ 1 000 à 3 000 emblèmes (estimation) | droits réservés (université de Glasgow) | pages HTML seulement : moissonnage à autoriser |
| **Rijksmuseum** (OAI-PMH, Linked Art, dumps) | titres et descriptions surtout **néerlandais** ; peu d'anglais | catalogueurs du musée | ≈ 170 000 objets codés | métadonnées CC0 | `data.rijksmuseum.nl/oai`, `id.rijksmuseum.nl` |
| **Europeana** | surtout Rijksmuseum (NL) ; presque rien en FR | fournisseurs | ≈ 316 000 notices citant Iconclass | métadonnées CC0 | API `api.europeana.eu` |
| **Iconclass AI Test Set** (Arkyves) | aucun texte : images et codes | indexeurs d'Arkyves | ≈ 87 700 images | CC0 | `iconclass.org/testset/` ; inutile pour le texte sauf rattachement aux notices d'origine |

Les collections françaises (Joconde/POP, Mandragore, Gallica) indexent avec Garnier ou leurs propres thésaurus, **pas
avec Iconclass**.

Conséquences pour l'évaluation :
- **Anglais** : RKDimages (titres) et Wikidata EN suffisent pour J2 ; ce sont surtout des titres, ce qui sert d'abord
  T1, T2, T3.
- **Français : c'est le vrai manque.** Les sources publiques se limitent aux libellés FR de Wikidata et aux emblèmes de
  Glasgow. L'annotation propre (§ 12.1) devient indispensable pour les cartels, les notices et les textes savants
  français ; les descriptions d'Opus ne fournissent pas de codes de référence.
- **Fuites** : les codes du RKD passent dans Wikidata par des robots, et le Rijksmuseum dans Europeana. On dédoublonne
  par œuvre entre sources avant toute mesure.
- **Biais en faveur du moteur** : beaucoup de titres Wikidata reprennent presque mot pour mot les libellés Iconclass
  (« Rape of the Daughters of Leucippus »), ce qui gonfle T3 ; on rapporte T3 à part, en séparant les titres conformes
  aux libellés des autres.
- **Codes incomplets et hétérogènes** (profondeur, clés, noms) : on normalise, on compte aussi par la hiérarchie, et la
  précision des codes établis reste jugée sur le texte (§ 12.2). Pour Glasgow, on compare un texte d'entrée aux codes
  « texte ».
