# Qualification formelle du noyau (journal de travail)

Ce fichier est le journal de la mission de qualification autonome (26/11). Il est tenu à jour à chaque cycle, pour
qu'une interruption ne perde rien. Branche : `claude/dazzling-archimedes-4ip3qp` ; PR ouverte : maribakulj/oedipamaas#6
(non mergée : la mission demande de ne pas merger automatiquement).

## 1. Périmètre et principes

Chantiers C1 à C6 du plan V1 ; priorité au noyau (`requetes.pl`, `satisfaction.pl`, `satisfaction_reference.pl`,
`verificateur.pl`, `assertions.pl`) et au comparateur (`inclusion.pl`, `outils/requetes/comparer.pl`). La compilation
massive d'Iconclass reste suspendue. Principes : monde ouvert ; pas de noms uniques implicites ; identité établie /
distinction établie / hypothèse / ignorance ; aucune conclusion déductive par défaut ; propagation taxonomique
conforme à la relation ; contextes, sources, modalités, portées séparés ; quatre valeurs composées ; valeur,
certification, recherche et agrégation séparées ; aucune conclusion négative d'un calcul incomplet ; aucune preuve
acceptée sans validation positive complète ; aucune construction non représentable simplifiée en condition positive ;
aucune garantie annoncée sans justification ; noyau indépendant d'Iconclass.

## 2. État au début de la mission (noyau 0.2, commit a040a9b)

Corrigé dans le lot précédent (contre-exemples dans `tests/plunit/test_noyau_semantique.pl`) : négation taxonomique
(descend, par inclusion seulement) ; distinction en monde ouvert (trois régimes) ; Belnap séparé de la certification ;
admissibilité des porteurs ; budget ; vérificateur strict ; comparateur avec noms alternatifs en cas séparés,
porteurs, contraintes en assertions, `indetermine` ; refus des constructions négatives et modales du compilateur.

## 3. Défauts : liste priorisée

Statuts : OUVERT, REPRODUIT (test échouant écrit), CORRIGÉ (test passant, cause corrigée), DOCUMENTÉ (limite admise),
REJETÉ (examiné, pas un défaut : raison donnée).

| # | Gravité | Défaut | Statut |
|---|---|---|---|
| D1 | haute | Négation taxonomique dans le mauvais sens (audit 1, § 4) | CORRIGÉ (0.2) |
| D2 | haute | `distincts` fondé sur la différence des représentants : noms uniques implicites (audit 1, § 5) | CORRIGÉ (0.2) |
| D3 | haute | Composition des quatre valeurs incomplète : faux ∧ inconnu perdu (audit 2, § 4) | CORRIGÉ (0.2) |
| D4 | haute | Admissibilité affaiblie : porteur non vérifié, asymétrie positif / négatif (audits 1 § 7, 2 § 7) | CORRIGÉ (0.2) |
| D5 | haute | Vérificateur : régime, variables étrangères, double liaison, termes parasites, forme, graphe (audits 1 § 8, 2 § 3) | CORRIGÉ (0.2) |
| D6 | haute | Comparateur : premier nom seul, propriété sans porteur, `distincts` (audit 2, § 2) | CORRIGÉ (0.2) |
| D7 | haute | Compilateur : polarité des libellés ignorée (audit 2, § 5) | CORRIGÉ (0.2) |
| D8 | moyenne | Limite de solutions prise pour un budget ; conclusion négative d'un calcul incomplet (audit 1, § 12) | CORRIGÉ (0.2) |
| D9 | moyenne | Test de coréférence qui ne teste rien (audit 2, § 1) | CORRIGÉ (0.2) |
| D10 | moyenne | Tests génératifs : angles morts, distributions non publiées (audit 2, § 8) | CORRIGÉ en partie (0.2) ; contextes imbriqués et portées mêlées : OUVERT |
| D11 | moyenne | Entrées invalides : comportement non testé (graphe invalide, requête mal formée, preuve mal formée) | CORRIGÉ (cycle 2) |
| D12 | moyenne | Isolation et concurrence non testées au-delà d'un cas | CORRIGÉ (cycle 2) : concurrence et modules temporaires testés |
| D13 | moyenne | Reproductibilité (même entrée, même sortie, empreinte) non testée | CORRIGÉ (cycle 2) |
| D14 | moyenne | Comparateur : transitivité, renommage, insatisfiables, taxinomie non testés ; pas de mutation du comparateur | CORRIGÉ (cycle 5) : `test_inclusion_generatif.pl` (modèles), 27 tests écrits, 7 défauts injectés détectés |
| D15 | moyenne | Pas de mutation du vérificateur | CORRIGÉ (cycle 3) : 14 défauts injectés dans le vérificateur, tous détectés ; mutations du graphe à empreinte recalculée |
| D16 | moyenne | Pas d'oracle indépendant des deux moteurs pour les fragments finis (les deux moteurs Prolog sont écrits d'après la même spécification) | CORRIGÉ (cycle 6) : oracle Python d'après NOYAU.md seul ; 0 désaccord sur 5 000 cas ; `tests/test_oracle.py` |
| D17 | moyenne | Compilateur : couverture lexicale par sous-chaîne (`couvert/2`), fausse complétude (audit 1, § 11) | CORRIGÉ (cycle 1) |
| D18 | moyenne | Compilateur : la personne héritée devient une variable indépendante (coprésence prise pour participation) (audit 1, § 11) | CORRIGÉ (cycle 1) |
| D19 | basse | Contrat : les types des requêtes sont des atomes, les synsets des entiers (audit 2, § 6) | CORRIGÉ (cycle 2) |
| D20 | basse | `sens(_, _, W, W)` : un mot désigne le lemme lui-même ; mot, concept, référent confondus (audit 2, § 6) | DOCUMENTÉ (C7) |
| D21 | basse | Pas de limite de temps ni de mémoire (seulement un budget d'appuis) | CORRIGÉ en partie (cycle 2) : limite de temps ; pas de limite de mémoire (celle de la pile de SWI-Prolog) |

Défauts trouvés au cycle 3 par les contradicteurs (rapports : `scratchpad/audit_logique/rapport.md` = L,
`scratchpad/audit_inclusion/rapport.md` = I, oracle Python = O ; chaque cas reproduit est repris dans
`tests/plunit/test_noyau_semantique.pl` ou `test_inclusion.pl`). Numérotation propre à ce journal :

| # | Gravité | Défaut | Statut |
|---|---|---|---|
| D22 | haute | Entité niée lue comme « ce référent n'est pas un W » seulement : « un lion ; pas de lion » établi (mutation du vérificateur) | CORRIGÉ (cycle 3, avec D23) |
| D23 | haute | La négation d'une description est répartie sur ses atomes : « l'homme ne terrasse pas » écarte « un homme attaque », « Goliath ne décapite pas David » écarte l'inverse, « pas de lion mort » écarte tout lion (L-D2, L-W) | CORRIGÉ (cycle 3) |
| D24 | haute | Liste de noms réfutée par la négation d'un seul nom (L-D1, I-D1) | CORRIGÉ (cycle 3) |
| D25 | haute | Porteur présent selon une source citée seulement : certifié (L-D3) | CORRIGÉ (cycle 3) |
| D26 | haute | Distinction documentaire tirée de noms non admissibles, contredits ou partagés (L-D4) | CORRIGÉ (cycle 3) |
| D27 | haute | Type entier jamais nié : le lien négatif passe le type demandé par `sens` (L-D5) | CORRIGÉ (cycle 3) |
| D28 | haute | `nombre` lu sans qualificatifs : une hypothèse établit (L-D6) | CORRIGÉ (cycle 3) |
| D29 | moyenne | Contraintes à trois valeurs : coréférence et distinction ensemble, deux nombres : `etablie` (L-D7) | CORRIGÉ (cycle 3) |
| D30 | moyenne | Polysémie : un mot établit tous ses sens, nier un sens nie le lemme (L-D8) | CORRIGÉ (cycle 8, décision du 27/11) : liens certains ou hypothèses de sens ; négations certaines ou possibles ; l'anglais prend tous les sens |
| D31 | moyenne | Statut `ecartee` pour une réfutation inversée, ou d'une source citée seule (L-D9, L-D10) ; `meme` réfuté par K (L-D12) | CORRIGÉ (cycle 8, décision du 27/11) : réfutations gardées, avec leur portée (la substitution) et leurs fondements (auteur, source citée, documentaire avec sa source, texte) |
| D32 | moyenne | Budget épuisé : `etablie_sous_hypotheses` affirme « aucune vraie » (L-D11) | CORRIGÉ (cycle 3) |
| D33 | basse | Alias non clos (L-D14, I-D7) | CORRIGÉ (cycle 3) |
| D34 | basse | Spécification : `non_certifiee` absent du § 4.4, ancrage au § 7 seul, porteur « positif » ambigu (L-D13, L-D15, O) | CORRIGÉ (cycle 3) |
| D35 | basse | Contrainte entre un événement et un référent acceptée (L-D17) | CORRIGÉ (cycle 3) |
| D36 | basse | Alternatives jamais exploitées (L-D16, sens sûr) ; nom propre nié sans effet (L-D18, dépend du lecteur) | DOCUMENTÉ |
| D41 | basse | Réfutation d'une conjonction de la requête qui couvre exactement une description niée (« la femme ne tient pas l'enfant ») non dérivée : perte dans le sens sûr | DOCUMENTÉ (NOYAU § 1.1) |
| D42 | haute | Graphe non clos (variables libres) accepté par `valider` ; le vérificateur accepte une preuve forgée (V-V1) | CORRIGÉ (cycle 4) : `non_clos`, `cyclique`, `mot`, `identifiant` |
| D43 | haute | Recherche des liens exponentielle (tous les chemins simples), hors budget ; vérificateur sans borne (V-X1) | CORRIGÉ (cycle 4) : parcours en largeur, chaque nœud vu une fois, dans les trois programmes ; essai sur 2^24 chemins |
| D44 | moyenne | Requêtes non closes ou cycliques admises par `bien_formee` (V-R3, B1) ; `bien_formee` exponentiel en `ou` (V-X3) ; `valider` quadratique, hors limite de temps (V-X2) | CORRIGÉ en partie (cycle 4) : requêtes closes et acycliques exigées ; liaison des contraintes linéaire ; la limite de temps couvre la validation ; `valider` reste quadratique |
| D45 | basse | Identifiants entiers, variables `v(1)`, options invalides, `satisfaire_lot` qui échoue en silence (V-R1, R2, B2 à B5) ; `distinct` vers une entité seulement possible (V-V4) ; passage d'un appui non contrôlé (V-V8) ; budget dépendant de l'ordre des faits et réinitialisé par un appel imbriqué (V-D1 à D3) | CORRIGÉ en partie (cycle 4) : identifiants atomiques, variables atomiques, options contrôlées, lot sans échec silencieux, distinction entre entités présentes selon l'auteur, passage contrôlé, budget propre à l'appel ; reste DOCUMENTÉ : sous un budget épuisé, ce qui est trouvé dépend de l'ordre d'exploration (le statut `incomplet` le dit) ; la preuve choisie parmi plusieurs dépend de l'ordre des faits (toutes sont valides) |
| D46 | moyenne | Entité niée nue d'une classe sans membre présent lue comme existentielle (O-A) ; participants d'un événement nié non exigés présents (O-B) ; noms d'un porteur absent dans la distinction supposée (O-C) ; nom contesté non compté contre la documentaire (O-D) | CORRIGÉ (cycle 6) |
| D47 | critique | Comparateur : un `meme` de Q2 sans coréférence correspondante dans Q1 donne des `oui` faux (F-B1) | CORRIGÉ (cycle 7) : contre-exemple « jumeau » |
| D48 | haute | Prémisses non contrôlées : un rôle certifié par un événement que l'auteur nie (F-B2) ; un appui dont le porteur n'existe pas selon le texte (F-B3) ; distinction établie et nombre de même | CORRIGÉ (cycle 7) |
| D49 | moyenne | Le vérificateur rejette une preuve juste (distinction vers une entité citée : F-N1) et accepte une requête mal formée (F-N4) ; `genre` nié par une description restreinte (F-N2) ; hypothèse malgré un nom possible partagé (F-N3) ; `meme` non réfuté par K dans une classe (F-N5) | CORRIGÉ (cycle 7) |
| D50 | basse | Un nom nié dont le porteur n'est que possible, nié ou d'une autre portée contredit-il le nom de la classe ? Les moteurs : oui ; l'oracle (§ 1 : « aucun état sinon ») : non ; aucune lecture n'est uniformément prudente (O, cycle 7) | CORRIGÉ (cycle 8, décision du 27/11) : lecture de l'oracle ; l'information n'est pas une contestation logique |
| D51 | moyenne | Une distinction établie dont l'existence d'une entité est niée empêchait la documentaire et la supposée (non monotone) ; le genre recevait une prémisse d'existence du contexte de la figuration (le moteur optimisé seul : les deux moteurs divergeaient) (O, cycle 7) | CORRIGÉ (cycle 7) |
| D52 | haute | Codage : l'indicateur d'incomplétude du noyau perdu dans le résultat Iconclass (relecture du propriétaire, 27/11) | CORRIGÉ (cycle 8) : `annexe(Complet, Necessaire)` jusqu'à la sortie |
| D53 | haute | Codage : l'index excluait les types entiers et ne fermait pas les alias comme le noyau ; des requêtes établissables n'étaient pas essayées en mode indexé | CORRIGÉ (cycle 8) : test d'égalité des résultats positifs indexé / exhaustif, écrit et génératif |
| D54 | haute | Codage : seule la condition suffisante évaluée ; une suffisante écartée donnait « ecarte » (une notation réfutée) | CORRIGÉ (cycle 8) : suffisante et nécessaire évaluées séparément ; `suffisante_ecartee` ne réfute pas la notation |
| D55 | moyenne | Moteur de référence : une négation seulement possible ancrait une variable (statut `ecartee` là où l'optimisé dit `inconnue`) (oracle, cycle 8) | CORRIGÉ (cycle 8) |
| D56 | haute | Une négation seulement possible de l'existence d'une entité d'une distinction établie ou d'un nombre ne donne pas d'hypothèse (les deux moteurs et l'oracle ; le § 2 pris à la lettre en demanderait une) ; le dernier audit (U-B2) le tient pour bloquant | CORRIGÉ (cycle 9) |
| D57 | haute | Distinction documentaire certifiée sur des noms dont le porteur n'existe pas selon le texte (U-B1) | CORRIGÉ (cycle 9) |
| D58 | moyenne | Conclusions sous hypothèses qu'aucune lecture ne satisfait (hypothèses de sens et de négation non confrontées ; « pomme ; pas de fruit ; pas d'objet ») (U-B3) | CORRIGÉ (cycle 9) : un appui sans lecture ne certifie rien ; les hypothèses ne sont pas confrontées entre elles au-delà de cette condition |
| D59 | basse | Fondements d'une réfutation : `texte` perdu quand K réfute aussi (U-N2) ; codage : une requête mal formée faisait disparaître la notation (U-N3) | CORRIGÉ (cycle 9) |
| D37 | critique | Comparateur : la normalisation n'est pas une équivalence, `oui` faux (I-N1 à N4) | CORRIGÉ (cycle 5) |
| D38 | critique | Comparateur : le type de Q1 devient un mot avec tous ses sens (I-A2), types entiers (I-D3) | CORRIGÉ (cycle 5) |
| D39 | grave | Comparateur : distinction documentaire du graphe canonique, cas non contrôlés, insatisfiables, noms de variables (I-D2, D4, D5) | CORRIGÉ (cycle 5) |
| D40 | grave | Comparateur : certification non monotone (négation, lexicalisation hors `inclus`) (I-D1, D6) | CORRIGÉ (cycle 5) |

## 4. Commandes de reproduction

```bash
cd tests/plunit && LANG=C.UTF-8 swipl -g run_tests -t halt test_noyau.pl
cd tests/plunit && LANG=C.UTF-8 swipl -g run_tests -t halt test_noyau_semantique.pl
cd tests/plunit && LANG=C.UTF-8 swipl -g run_tests -t halt test_noyau_generatif.pl
cd tests/plunit && LANG=C.UTF-8 swipl -g run_tests -t halt test_inclusion.pl
python3 outils/noyau/injection.py
python -m pytest -q
```

## 5. Résultats exacts (début de mission)

- `test_noyau.pl` : 51 / 51 ; `test_noyau_semantique.pl` : 3 tests (45 sous-tests) ; `test_inclusion.pl` : 13 / 13 ;
  `test_noyau_generatif.pl` : 5 / 5 sur 1 500 cas ; injection : 10 défauts sur 10 détectés ; pytest : 47 / 47.

## 6. Journal des cycles

### Cycle 1 (26/11) : D17, D18

- **D17.** Attendu : un mot plein du libellé n'est couvert que par un atome qui le porte comme mot entier (sinon une
  requête incomplète passe pour compilée : sens dangereux). Contre-exemple minimal : `couvert([type(v(x), woman)],
  man)` réussissait ; `couvert([nom(v(x), ['ANTONY'])], ant)` aussi. Tests : `tests/plunit/test_compilateur.pl`
  (6 tests, 2 échouaient). Correction : comparaison par mots entiers (`mots_du_terme/2`). 6 / 6.
- **D18.** Attendu : la personne héritée d'un récit, ajoutée comme une variable sans lien, dit une présence, pas une
  participation ; la requête n'est plus connexe et doit être partielle. Cause : la connexité était calculée avant
  l'héritage. Correction : `liens_apres_heritage/3` recalcule la connexité après. Pas de test sans données (l'héritage
  lit l'arbre d'Iconclass) ; effet mesuré sur toute la base : 14 320 compilations portent la raison.
- Effet des deux : 19 457 → 17 432 requêtes compilées (sur 81 394), dans le sens prudent.
- Lancés en parallèle : trois contradicteurs (sémantique, vérificateur et robustesse, inclusion) et un oracle Python
  écrit d'après la spécification seule (D16).

### Cycle 2 (26/11) : D11, D12, D13, D19, D21

- `tests/plunit/test_noyau_robustesse.pl` (20 tests), écrit d'abord ; trois échouaient :
  - une entrée qui n'est pas `requete/2` faisait **échouer** `satisfaire/4` en silence (au lieu d'une erreur
    structurée) : corrigé (`requete_mal_formee(inconnu, [pas_une_requete(Q)])`) ;
  - un type entier (un identifiant de concept de K, comme un synset) était refusé par la forme des requêtes et du
    vérificateur, alors que K en emploie (D19) : la forme admet un atome ou un entier ; le moteur de référence aussi ;
  - pas de limite de temps (D21) : option `temps(S)` ; dépassée, `resultat(incomplet, [temps_depasse], incomplet)`.
- Passent sans correction : graphe non liste, terme inconnu, identifiant double, qualificatif manquant, rôle vers un
  événement absent (erreurs `graphe_invalide`) ; requête mal formée ; vérificateur sur graphe invalide, preuve non
  close, liste impropre ; reproductibilité, ordre des faits sans effet, empreinte indépendante de l'ordre ; appels
  concurrents égaux aux appels en série ; aucun module temporaire laissé, même après une erreur.

### Cycle 3 (26/11) : négation des descriptions, qualifications, mutation du vérificateur (noyau 0.3)

- Point de départ : la mutation du vérificateur (D15) ; quatre des dix défauts injectés n'étaient pas détectés, parce
  que les altérations du graphe changeaient l'empreinte (rejet par le contrôle des versions, pas par le contrôle visé).
  Mutations à empreinte recalculée : le vérificateur acceptait une preuve de « lion » sur « un lion ; une étude : pas
  de lion » (D22).
- Quatre contradicteurs indépendants (sémantique L, vérificateur et robustesse V, inclusion I, oracle Python O, ce
  dernier écrit d'après NOYAU.md seul) ; leurs rapports sont dans le scratchpad de la session (`audit_logique/`,
  `audit_verificateur/`, `audit_inclusion/`, `oracle/`). Chaque contre-exemple a été relancé ici ; ceux du noyau sont
  repris dans `test_noyau_semantique.pl` (31 cas nouveaux), `test_noyau_robustesse.pl` (2), `test_noyau.pl`
  (mutations, 3 cas).
- Ma première correction de D22 (« une entité niée nie le type de tout référent ») était fausse : L a montré qu'elle
  rendait contradictoires « un lion ; pas de lion mort » et « l'ange tient une épée ; le saint ne tient pas d'épée ».
  La racine est D23 : la polarité nie une description. Règles retenues (NOYAU § 1.1) : entité nue prédicative ou
  existentielle, entité restreinte sans appui négatif, événement nié contre un autre événement présent de mêmes rôles,
  rôle jamais nié seul. Le cas `une_autre_action_niee_ne_nie_pas_celle_ci`, écrit au début du cycle avec l'attendu
  `etablie`, est gardé sous un autre nom avec l'attendu `contradictoire` (lecture la plus prudente : un événement nié
  sans rôle nie tout événement de ce prédicat) ; le test ancien `variantes:negation` passe de `ecartee` à `inconnue`
  (la réfutation, juste, n'est plus dérivée : D41, perte dans le sens sûr), avec la raison en commentaire.
- Ajouté sans contre-exemple d'audit : une prémisse niée ne certifie pas (« une lionne ; pas de lionne » ne certifie
  pas « un lion » : `non_certifiee`), trouvé par la mutation `negation_ajoutee` sur le cas `fauve`.
- Erreur interne : `resoudre/6` rendait `inconnue` complète si la vue échouait (L-S4) ; c'est maintenant une erreur.
- Résultats : `test_noyau` 51 / 51 ; `test_noyau_semantique` 3 tests, 144 sous-tests (48 cas × 3) ; `test_noyau_robustesse`
  22 / 22 ; `test_noyau_generatif` 5 / 5 ; `test_inclusion` 13 / 13 ; `test_compilateur` 6 / 6 ; injection : 18 défauts
  du moteur et 14 du vérificateur, tous détectés (écrit d’abord « 15 » par erreur de compte). La reproduction de L donne l'attendu pour tous les cas du périmètre ;
  restent D30 (polysémie), D31 (sens d'`ecartee`), D36 (alternatives, nom propre nié), qui ne sont pas corrigés.
- Questions pour le propriétaire (décisions non bloquantes, l'option prudente est prise en attendant) :
  1. **Polysémie (D30)** : faut-il exiger qu'un lien positif vaille pour chaque sens du mot (supervaluation), ce qui
     ferait perdre beaucoup de rappel en français (WOLF prend tous les sens), ou garder la lecture actuelle ?
  2. **`ecartee` (D31)** : une substitution fausse dont les atomes d'identification sont seulement inconnus (« Jean
     n'aime pas Marie » pour « Marie aime Jean ») et une réfutation par une seule source citée donnent `ecartee` ;
     faut-il un statut qui garde la source, ou exiger une réfutation de l'auteur ?

### Cycle 4 (26/11) : robustesse (D42 à D45)

- Tests écrits d'après le rapport V, puis corrections : `test_noyau_robustesse.pl` passe de 22 à 37 tests (graphe non
  clos, vérificateur sur graphe non clos, identifiant entier, passage de l'appui, distinction vers une entité
  possible, hiérarchie en losanges à 2^24 chemins pour les deux moteurs et le vérificateur, requête non close,
  contrainte non close, requête cyclique, vérificateur sur requête cyclique, variable non atomique, options
  invalides, nom non atomique, lot avec un intrus, liaison des contraintes sur 2^30 sélections).
- Les liens sont cherchés par un parcours en largeur (un plus court chemin) : les preuves peuvent citer un autre
  chemin qu'avant, toujours valide. Le § 3 de NOYAU.md disait le coût « exponentiel dans le nombre de variables
  seulement » : c'était faux pour les liens (V-X1) ; c'est vrai maintenant, le coût d'un lien étant borné par le
  nombre de nœuds atteignables de K.
- Résultats : `test_noyau` 51 / 51, `test_noyau_semantique` 141 sous-tests, `test_noyau_robustesse` 37 / 37,
  `test_noyau_generatif` 5 / 5, `test_inclusion` 13 / 13 ; injection : 32 défauts sur 32 détectés (18 + 14).

### Cycle 5 (26/11) : le comparateur (D14, D37 à D40)

- Définition récrite (NOYAU § 8) : Q1 ⊆ Q2 si tout graphe de K⁺ où Q1 est établie établit Q2 ; K⁺ ajoute à K un mot
  par nœud (« $noeud:T ») et un nom par clé : un type de requête n'est plus lu comme un mot du texte (I-A2 : « lion »
  est aussi une célébrité). Conséquence : sur les K réels, deux requêtes qui n'emploient pas le même lemme sont
  rarement comparables (un lemme est un puits de la hiérarchie) ; c'est le sens strict, voulu.
- Méthode : chaque cas est contrôlé (son graphe canonique doit établir Q1, sinon `indetermine(cas_non_etabli)` :
  I-D4) ; une preuve de Q2 n'est acceptée que sans distinction documentaire (I-D2) et si chaque lien transmet la
  négation (I-D6 et la non-monotonie de la certification) ; un lien qui ne la transmet pas donne un contre-exemple
  construit (« pas de T2 ») ou `indetermine` ; une normalisation qui échoue ou change le graphe canonique donne
  `indetermine` (I-N1 à N4) ; identifiants par table (I-D5) ; types entiers (I-D3) ; noms et alias (I-D1, I-D7)
  corrigés par le noyau 0.3 (D24, D33). `outils/requetes/comparer.pl` ne perd plus une paire en silence (`echec`).
- L'argument de sûreté est écrit (NOYAU § 8), non démontré mécaniquement. Il est mis à l'épreuve par
  `test_inclusion_generatif.pl` : 300 paires (affaiblissements et tirages), chaque `oui` confronté à des modèles
  (graphe canonique d'un cas + graphe aléatoire + coréférences vers les porteurs + négations ciblées), chaque `non` à
  son contre-exemple, réflexivité, renommage, transitivité. Contre le comparateur ancien (commit 8b8cb9d), ce banc
  échoue : un `oui` faux (lexicalisation `lemme_a` → `a` sous une négation) et un `non` dont le contre-exemple
  n'établit pas Q1 ; contre le nouveau, il passe. Distribution des verdicts (graine 20261130) : 228 `oui`, 70 `non`,
  2 `indetermine` (deux prédicats pour un événement) ; réflexivité : 296 `equivalentes`, 4 `indetermine`.
- `test_inclusion.pl` : 13 → 27 tests (contre-exemples de l'audit I avec graphes-témoins évalués par le moteur).
- Injection : 7 défauts du comparateur (cas non contrôlé, négation non transmise, distinction documentaire, normalisation
  prise pour une équivalence, noms en conjonction, type pris pour un mot, sous hypothèses pris pour établi), tous
  détectés.
- Limites : la distinction documentaire, la négation non transmise d'une propriété, d'un prédicat ou d'une relation
  donnent `indetermine` (pas de contre-exemple construit) ; la normalisation n'est pas intégrée (un graphe canonique
  qu'elle change est indéterminé) ; le fragment exclut deux prédicats pour un événement.

### Cycle 6 (26/11) : l'oracle indépendant (D16, D46)

- L'oracle Python (écrit par un agent qui n'a lu que NOYAU.md, ASSERTIONS.md, le K de test et le générateur) a été
  remis à niveau pour la version 0.3 par le même procédé. Sur 2 × 500 et 2 × 2 000 cas (deux générateurs, plusieurs
  graines), il restait quatre désaccords, tous des cas où les deux moteurs s'accordaient contre le texte ou sur une
  lecture que le texte ne fixait pas :
  - A (défaut des moteurs) : une entité niée nue dans une classe dont aucun membre n'est présent était lue comme
    existentielle ; le § 1.1 ne le dit pas : rien ;
  - B : un événement nié dont un participant n'est pas présent réfutait ; le § 1 demande présents ceux dont une
    assertion niée parle : corrigé dans les trois programmes ;
  - C et D : les noms d'une classe pour les distinctions ; tranché par la lecture prudente (hypothèse : porteur
    présent, nom non contesté ; exclusion de la documentaire : tout nom affirmé), écrit au § 4.1 ; l'oracle a reçu
    cette lecture (`LECTURES["exclusion_documentaire"]`), comme décision de la spécification, pas comme copie des
    moteurs.
- Après correction : 0 désaccord sur 5 000 cas (`python3 tests/oracle/differentiel.py`, `--jeu gen`, `--graine 7`,
  `-n 2000`, `-n 2000 --jeu gen --graine 3`). Distribution (graine par défaut, 500 cas, jeu de l'oracle) : etablie 58,
  ecartee 28, inconnue 380, non_certifiee 20, contradictoire 1, mal formées 13 ; jeu gen : etablie 65, sous
  hypothèses 1, ecartee 30, inconnue 389, non_certifiee 14, contradictoire 1.
- Quatre cas ajoutés au banc sémantique (51 cas). Mon attendu du cas D était faux (j'avais écrit `inconnue` ; le
  § 4.1 donne `etablie_sous_hypotheses`, comme l'oracle) : corrigé, avec la raison.
- Noté, non corrigé : le moteur de référence ne contrôle pas la forme des requêtes (il rend un statut sur une requête
  mal formée) ; il n'est appelé que sur des requêtes déjà contrôlées.

### Cycle 7 (26/11) : audit final (F), trois défauts bloquants

- Contradicteur neuf (le code et la spécification, sans mes conclusions), rapport dans `scratchpad/audit_final/`. Trois
  défauts bloquants, tous reproduits ici :
  - B1 (comparateur) : `type(x, saint)` ⊆ `et([type(x, saint), type(y, homme), meme(x, y)])` rendu `oui`, alors que
    « un saint, coréférent à un autre saint et distinct de lui » établit Q1 et rend Q2 contradictoire (`meme` a quatre
    valeurs). Le § 8 disait à tort que les contraintes transmettent la négation par construction. Corrigé : un `meme`
    de Q2 n'est sûr que sur une classe que Q1 dit une par une coréférence ; sinon contre-exemple « jumeau ». Le test
    ancien `identite` attendait `equivalentes` : faux, l'inclusion n'est que dans un sens (`incluse`) ; corrigé avec la
    raison.
  - B2 : « la femme tient l'enfant ; la femme ne tient pas l'enfant » certifiait les rôles seuls ; B3 : « un homme
    nommé Pierre ; il n'y a pas d'homme » certifiait le nom. La racine : la prémisse d'un appui n'était contrôlée que
    par son assertion propre. Corrigé dans les trois programmes : existence des porteurs, événement d'un rôle,
    entités d'une distinction établie et d'un nombre.
- Non bloquants, corrigés : N1 (le vérificateur exige maintenant, comme les moteurs, des entités présentes selon
  l'auteur pour une distinction), N2 (`genre` nié seulement par une entité nue), N3 (aucune hypothèse de distinction
  entre deux classes qui portent un même nom, à quelque titre que ce soit), N4 (le vérificateur refuse une contrainte
  sur des événements), N5 (`meme` contredit dans une classe que K dit deux individus). Conséquence de N3 : le cas
  `nom_conteste_porte_contre_la_documentaire` passe de `etablie_sous_hypotheses` à `ecartee` (raison dans le cas).
- Un défaut de ma correction, trouvé par un avertissement du compilateur : le vérificateur prenait K non lié dans la
  justification d'une distinction établie (elle aurait été rejetée par erreur) ; corrigé.
- Tests : `test_noyau_semantique` 60 cas, `test_noyau_robustesse` 38, `test_inclusion` 28, `test_inclusion_generatif`
  (les modèles ont maintenant des jumeaux) ; mutations du graphe « porteur inexistant » et « événement du rôle nié ».
- L'oracle a reçu les amendements (agent qui ne lit que la spécification) ; 0 désaccord sur les bancs standard, mais
  ceux-ci n'exercent presque pas les amendements : ses bancs ciblés (environ 12 000 cas) ont trouvé D51 (corrigé, deux
  cas au banc sémantique) et D50 (soumis au propriétaire). Après correction : 0 désaccord sur les bancs standard.

### Cycle 8 (27/11) : décisions du propriétaire (D30, D31, D50) et codage (D52 à D54)

- D30 : sens conceptuels ; liens certains ou hypothèses de sens (`sens_suppose`) ; négations certaines ou possibles
  (`negation_autre_sens`, une hypothèse, jamais une réfutation) ; appui retenu au moindre nombre d'hypothèses ; le
  vérificateur exige exactement les hypothèses que demandent les appuis cités ; le comparateur transmet la négation
  dans les deux sens ; l'anglais prend tous les sens de WordNet (le premier sens était une désambiguïsation cachée :
  les mesures de l'anglais changeront, c'est l'affaire de C7). K de test : « pomme » (deux concepts), « poly » dans le
  K génératif. Sept cas sémantiques (dont L-D8a à c) ; trois défauts injectés, détectés.
- D31 : `refutation(Sigma, substitution, Fondements)` ; deux tests (source citée, documentaire avec sa source).
- D50 : lecture de l'oracle ; un cas sémantique. L'information (un nom nié d'un porteur absent) n'est pas exposée comme
  indice : elle reste dans le graphe ; la rendre visible est un travail de présentation, hors du noyau.
- L'oracle a reçu D30, D31 et D50 (d'après la spécification seule ; un K d'oracle avec de vrais polysèmes ; quatre
  oracles volontairement faux, tous détectés par ses bancs). Un désaccord : D55, un défaut du moteur de référence,
  corrigé, avec un cas au banc sémantique. Ensuite : 0 désaccord sur les bancs standard et sur environ 20 000 cas
  biaisés vers les polysèmes et les négations.
- Codage (D52 à D54) : `tests/plunit/test_codage.pl` (11 tests : type entier, alias en chaîne, indexé = exhaustif écrit
  et sur 120 graphes tirés, suffisante écartée et nécessaire établie, nécessaire seule, incomplétude jusqu'à la sortie,
  aucun statut de notation réfutée) ; `coder/5` (K, normalisation, budget en options) ; `satisfaire_lot/5`.

### Cycle 9 (27/11) : le dernier audit (U)

- Contradicteur neuf sur 4b35732 puis 438b05f (rapport : `scratchpad/audit_ultime/`). Trois défauts bloquants,
  reproduits ici : U-B1 (D57), U-B2 (D56, que j'avais classé limite basse), U-B3 (D58). Corrigés dans les deux
  moteurs et le vérificateur ; cinq cas au banc sémantique ; trois défauts injectés, détectés.
- Non bloquants : U-N2 et U-N3 corrigés (D59) ; U-N4 (un porteur coréférent à une entité niée, conforme au § 4.3 qui
  ne contrôle que l'entité citée) et U-N5 (hypothèses en trop dans le sens sûr ; avec WordNet, une négation certaine
  est rare : « un lion ; pas de lion » sort `conditionnel`, pas `contradictoire`) sont des limites, inscrites au § 7.
- L'oracle reçoit la lecture B2 par défaut (il l'avait déjà, en variante : c'est maintenant la lettre du § 4.3) ;
  0 désaccord sur les bancs standard. Il n'encode pas B1 ni B3 : ces deux règles ne sont vérifiées que par les deux
  moteurs Prolog, le vérificateur et les cas écrits (limite inscrite au § 7).
- Ce qui a tenu selon U : mutations des preuves D30 toutes rejetées ; aucune `etablie` démentie par une lecture hors
  de la famille U-B2 sur 28 000 tirages ; aucun `oui` faux du comparateur sur 4 000 paires et 14 060 modèles ; index
  du codage complet.

## 7. Garanties établies, garanties absentes, limites

Rien ci-dessous n'est une démonstration formelle : un test qui passe, ou l'accord de quatre programmes, n'en est pas
une. « Établi » veut dire : écrit dans la spécification, implanté dans les trois programmes Prolog écrits séparément
et dans l'oracle Python écrit d'après la spécification seule, et confronté à des attendus qui ne dépendent d'aucun
d'eux (contre-exemples écrits à la main, graphes-témoins, mutations).

**Établi au sens ci-dessus (état final, commit de ce journal)**
- Composition des quatre valeurs (Belnap) des atomes et des contraintes ; certification séparée de la valeur.
- Monde ouvert : aucune distinction implicite ; trois régimes de distinction ; une hypothèse ne donne jamais un
  statut déductif ; aucune hypothèse entre deux classes qui portent un même nom, à quelque titre que ce soit.
- Négation : par inclusion seulement, vers le bas ; jamais répartie sur une description (§ 1.1) ; une liste de noms
  niée seulement si chaque nom l'est ; une assertion niée demande présents ceux dont elle parle.
- Certification : appuis de l'auteur, porteurs présents selon l'auteur, aucune prémisse niée (l'assertion avec son
  mot, l'existence de ses entités, l'événement d'un rôle) ; contraintes vraies et certifiables.
- Aucune conclusion négative d'un calcul incomplet (budget, temps) ; aucune erreur interne changée en résultat ;
  entrées invalides refusées par des erreurs structurées.
- Vérificateur : contrôle positif de chaque point ; 16 défauts injectés, tous détectés ; forgeur exhaustif des audits
  V et F (3 000 + 1 500 + 6 000 cas) : aucune preuve acceptée hors des solutions de la référence.
- Les deux moteurs : même vue sur 1 500 cas tirés, et 4 500 + 3 000 des audits ; 21 défauts injectés dans le moteur
  optimisé, tous détectés.
- Oracle : 0 désaccord avec les deux moteurs sur 5 000 cas tirés (deux générateurs, plusieurs graines) et sur les
  bancs ciblés de l'agent, hors D50.
- Coût polynomial des liens et de la bonne forme ; liaison des contraintes sans énumérer les sélections.
- Comparateur : définition sur K⁺ ; chaque `oui` des 300 paires tirées tient sur ses modèles tirés (avec négations
  ciblées et jumeaux) ; chaque `non` a un contre-exemple valide ; 8 défauts injectés, tous détectés ; le banc échoue
  contre le comparateur ancien.

**Absent (non garanti)**
- Aucune preuve mécanique : ni de la sémantique, ni de l'équivalence des moteurs, ni de l'argument de sûreté du
  comparateur (NOYAU § 8, écrit, non démontré).
- Une erreur de la spécification elle-même n'est vue par aucun des programmes : seuls les audits contradictoires s'en
  protègent ; le dernier (F) en a trouvé trois, bloquantes, toutes corrigées ; aucun audit après lui.
- Décisions du propriétaire, en attente : D30 (polysémie : un mot établit chacun de ses sens), D31 (sens d'`ecartee`
  pour une réfutation d'une source citée seule, ou sous des atomes d'identification inconnus ; et `meme` réfuté par
  K), D50 (nom nié d'un porteur absent).
- Incomplétudes dans le sens sûr : D41 (réfutation d'une conjonction qui couvre une description niée), D36
  (alternatives couvertes par une requête disjonctive) ; le comparateur rend `indetermine` pour une distinction
  documentaire, une négation non transmise hors des types, une normalisation qui change le graphe canonique.
- D30 et WordNet : une négation certaine demande que chaque sens du type soit inclus dans chaque sens du mot nié ;
  avec des mots très polysémiques, presque aucune négation ne l'est, et la protection contre les contradictions se
  réduit à des conclusions conditionnelles (`conditionnel`, jamais `etabli`). Une désambiguïsation (C7) la rendra
  plus fine. Les hypothèses d'une conclusion conditionnelle ne sont confrontées entre elles que par la condition
  d'une lecture au moins par appui.
- L'oracle Python n'encode pas les règles du dernier audit B1 (documentaire et existence des porteurs) et B3 (appui
  sans lecture).
- La prémisse d'existence porte sur l'entité citée, pas sur les autres membres de sa classe (U-N4).
- Pas de limite de mémoire ; `valider` quadratique ; sous un budget épuisé, ce qui est trouvé dépend de l'ordre
  d'exploration (le statut `incomplet` le dit).
- La justesse du lecteur et du compilateur n'est pas l'objet de ces tests (`docs/mesures/`).

## 8. Prochain travail

1. Décisions du propriétaire : D30, D31, D50.
2. Un nouvel audit contradictoire indépendant de l'état final (le dernier a trouvé des défauts bloquants : la
   correction n'a pas été revue par un contradicteur neuf).
3. D10 : contextes imbriqués et portées mêlées dans le générateur.
4. Reprise de la compilation d'Iconclass : après 1 et 2 ; les mesures provisoires du comparateur qualifié sont dans
   `docs/mesures/V2.md` (cycle 5) et restent provisoires.

## 9. Rapport final (27/11, version intermédiaire du noyau)

**État initial** (commit a040a9b, noyau 0.2) : 51 tests déterministes, 15 contre-exemples, 1 500 cas génératifs,
10 défauts injectés dans le moteur, aucun dans le vérificateur ni le comparateur, pas d'oracle indépendant, un
comparateur dont les `oui` n'étaient pas contrôlés.

**État final** (noyau 0.3 avec les décisions D30, D31, D50 du 27/11) : `test_noyau` 51, `test_noyau_semantique`
74 cas × 3, `test_noyau_robustesse` 40, `test_noyau_generatif` 5 (1 500 cas), `test_inclusion` 29,
`test_inclusion_generatif` 4 (300 paires), `test_codage` 12, `test_compilateur` 6, `tests/test_oracle.py` 2 ; pytest
complet : 53 verts ; CI verte ; 51 défauts injectés (26 moteur, 17 vérificateur, 8 comparateur), tous détectés ;
oracle indépendant : 0 désaccord sur les bancs standard.

**Défauts** : D1 à D59 au § 3, avec gravité, statut, contre-exemple et correction ; les cycles 1 à 9 au § 6. Trois
audits contradictoires successifs ont chacun trouvé des défauts bloquants (cycles 3, 7, 9) ; ceux du dernier sont
corrigés, et aucune contre-expertise n'a encore porté sur leurs corrections.

**Mesures** : `docs/mesures/V2.md` (provisoires ; l'anglais changera avec D30, qui retire le premier sens implicite).

**Ce qui n'est pas qualifié** : ni M1 ni la V1. Ce lot qualifie le noyau logique, le vérificateur, le comparateur et
la couche de codage au sens du § 7 (tests, oracle, mutations, audits), pas le lecteur, le compilateur, la
désambiguïsation, ni les mesures de bout en bout.

**Suite recommandée** (décision du propriétaire du 27/11) : intégrer ce lot comme version intermédiaire du noyau ;
reprendre C3 (compilation des définitions), C6 (qualité des graphes extraits), C7 (désambiguïsation) et des mesures
indépendantes de bout en bout ; un nouvel audit du noyau quand C7 changera les sens qu'il reçoit.

## 10. Limites connues à l'intégration, et lots suivants (relecture du propriétaire du 27/11)

La PR maribakulj/oedipamaas#6 est intégrée comme **version intermédiaire** du noyau, non comme une qualification
définitive de M1. Les points suivants sont connus, documentés ici et dans le code, et chacun fera l'objet d'un lot
ciblé, évalué et reproductible. Le centre du développement passe à C3, C6 et C7.

| # | Limite | Où | Conséquence en attendant | Lot |
|---|---|---|---|---|
| L1 | Les hypothèses de sens sont rattachées aux lemmes, pas aux occurrences ni aux assertions, et ne sont pas confrontées entre elles : deux lectures exclusives d'une même occurrence justifient ensemble une conclusion conditionnelle (`pomme_vegetal_et_objet`) | `satisfaction.pl`, `satisfaction_reference.pl`, `verificateur.pl` ; NOYAU § 2 | les codes `conditionnel` ne sont pas des annotations exploitables automatiquement (dit dans `codage.pl`) | hypothèses par occurrence : `sens_suppose(Assertion, Sens)`, satisfaisabilité conjointe des hypothèses d'une solution |
| L2 | `normalisation.pl` ajoute des inférences non valides : participant unique à la fois agent, patient et thème ; complément d'un nom d'action lu comme patient ; dérivation morphologique prise pour une équivalence | `normalisation.pl` | ses ajouts sont des prémisses certifiables ; le comparateur rend `indetermine` quand elle change un graphe canonique | prochain point critique (C7) |
| L3 | Les assertions dérivées n'ont pas de provenance (règle, assertions sources, hypothèses), et rien ne distingue une transformation certaine d'une transformation hypothétique | `normalisation.pl`, ASSERTIONS.md | une normalisation incertaine peut introduire silencieusement une prémisse certifiable | avec L2 : assertions dérivées qualifiées (`derive(A, Regle, Sources, Hypotheses)`), les hypothétiques jamais prémisses déductives |
| L4 | L'égalité indexé / exhaustif compare les notations et leurs statuts, pas les substitutions ni les référents | `tests/plunit/test_codage.pl` | une différence de preuve entre les modes passerait inaperçue | comparer les preuves (σ, appuis) |
| L5 | Le codage ne garde de la condition nécessaire que son statut, pas ses éléments (preuves, réfutations, fondements) | `codage.pl` | la raison d'une nécessaire écartée ou contradictoire n'est pas visible | garder `resultat/3` entier dans l'annexe |
| L6 | Les mesures sur les connaissances réelles n'ont pas été refaites après D30 (l'anglais prend maintenant tous les sens de WordNet) ; performances et effet de la polysémie sur les statuts non mesurés | `docs/mesures/V2.md` | les mesures provisoires du cycle 5 sont antérieures à D30 | remesurer (dév., validation), temps et distribution des statuts, part des `conditionnel` |

Autres limites du noyau, inchangées (§ 7) : aucune preuve mécanique ; incomplétudes dans le sens sûr (D36, D41) ;
négations certaines rares avec WordNet ; l'oracle n'encode pas la règle B1 du dernier audit (B3 l'est depuis le
lot 4, comme le cas d'un atome des lectures conjointes) ; `valider` quadratique, pas de limite de mémoire.
L'architecture du noyau n'est pas rouverte.

**L1, lot 4 (branche `claude/c7-sens-par-occurrence`).** Une hypothèse de sens nomme son occurrence
(`sens_suppose(Occurrence, Mot, Type)`, l'occurrence étant l'assertion de l'appui), et les lectures d'une solution
sont conjointes : pour chaque occurrence, un même sens conceptuel atteint chacun des types demandés, sans que
l'assertion, prise en ce sens, soit niée de façon certaine (NOYAU § 2, § 4.3, § 6 point 9). Le choix des appuis est
fait ensemble (la première combinaison, dans l'ordre lexicographique, dont les lectures sont conjointes) dans les deux
moteurs ; le vérificateur a un contrôle de plus (`lectures_conjointes`) ; l'oracle Python suit la même règle, écrite
d'après le texte, et son générateur tire une fois sur huit deux types au même référent quand une tête est polysémique.
Contre-exemples : `pomme_vegetal_et_objet` devient `non_certifiee` (attendu changé, raison gardée dans le cas) ;
deux mentions coréférentes de « pomme » reçoivent chacune son sens ; un choix qui doit revenir sur le premier atome
(pomme, poire) ; une « lyre » dont le seul sens commun aux deux types est nié (les deux lectures séparées restent
possibles). Mesures : banc différentiel (2 × 4 000 cas, graine 20261128) sans désaccord ; le même oracle contre les
moteurs d'avant le lot 4 : 17 désaccords, tous `non_certifiee` contre `etablie_sous_hypotheses` (le banc voit donc la
règle) ; injection de défauts : quatre défauts du moteur et un du vérificateur ajoutés, 56 sur 56 détectés (30 du moteur, 18 du vérificateur, 8 du comparateur) ; deux mutants devenus équivalents (le filtre B3 des candidats, et le contrôle des lectures du vérificateur, que les lectures conjointes contiennent) retirent désormais les contrôles redondants ensemble. Reste : les négations
seulement possibles ne sont pas confrontées aux sens supposés, et aucun sens n'est choisi d'après le texte (C7) ; les
codes `conditionnel` restent non exploitables automatiquement.

