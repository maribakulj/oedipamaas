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
| D14 | moyenne | Comparateur : transitivité, renommage, insatisfiables, taxinomie non testés ; pas de mutation du comparateur | OUVERT |
| D15 | moyenne | Pas de mutation du vérificateur | CORRIGÉ (cycle 3) : 15 défauts injectés dans le vérificateur, tous détectés ; mutations du graphe à empreinte recalculée |
| D16 | moyenne | Pas d'oracle indépendant des deux moteurs pour les fragments finis (les deux moteurs Prolog sont écrits d'après la même spécification) | OUVERT |
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
| D30 | moyenne | Polysémie : un mot établit tous ses sens, nier un sens nie le lemme (L-D8) | décision du propriétaire (voir § 8) |
| D31 | moyenne | Statut `ecartee` pour une réfutation inversée, ou d'une source citée seule (L-D9, L-D10) ; `meme` réfuté par K (L-D12) | décision du propriétaire |
| D32 | moyenne | Budget épuisé : `etablie_sous_hypotheses` affirme « aucune vraie » (L-D11) | CORRIGÉ (cycle 3) |
| D33 | basse | Alias non clos (L-D14, I-D7) | CORRIGÉ (cycle 3) |
| D34 | basse | Spécification : `non_certifiee` absent du § 4.4, ancrage au § 7 seul, porteur « positif » ambigu (L-D13, L-D15, O) | CORRIGÉ (cycle 3) |
| D35 | basse | Contrainte entre un événement et un référent acceptée (L-D17) | CORRIGÉ (cycle 3) |
| D36 | basse | Alternatives jamais exploitées (L-D16, sens sûr) ; nom propre nié sans effet (L-D18, dépend du lecteur) | DOCUMENTÉ |
| D41 | basse | Réfutation d'une conjonction de la requête qui couvre exactement une description niée (« la femme ne tient pas l'enfant ») non dérivée : perte dans le sens sûr | DOCUMENTÉ (NOYAU § 1.1) |
| D42 | haute | Graphe non clos (variables libres) accepté par `valider` ; le vérificateur accepte une preuve forgée (V-V1) | OUVERT |
| D43 | haute | Recherche des liens exponentielle (tous les chemins simples), hors budget ; vérificateur sans borne (V-X1) | OUVERT |
| D44 | moyenne | Requêtes non closes ou cycliques admises par `bien_formee` (V-R3, B1) ; `bien_formee` exponentiel en `ou` (V-X3) ; `valider` quadratique, hors limite de temps (V-X2) | OUVERT |
| D45 | basse | Identifiants entiers, variables `v(1)`, options invalides, `satisfaire_lot` qui échoue en silence (V-R1, R2, B2 à B5) ; `distinct` vers une entité seulement possible (V-V4) ; passage d'un appui non contrôlé (V-V8) ; budget dépendant de l'ordre des faits et réinitialisé par un appel imbriqué (V-D1 à D3) | OUVERT |
| D37 | critique | Comparateur : la normalisation n'est pas une équivalence, `oui` faux (I-N1 à N4) | en cours |
| D38 | critique | Comparateur : le type de Q1 devient un mot avec tous ses sens (I-A2), types entiers (I-D3) | en cours |
| D39 | grave | Comparateur : distinction documentaire du graphe canonique, cas non contrôlés, insatisfiables, noms de variables (I-D2, D4, D5) | en cours |
| D40 | grave | Comparateur : certification non monotone (négation, lexicalisation hors `inclus`) (I-D1, D6) | en cours |

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
  du moteur et 15 du vérificateur, tous détectés. La reproduction de L donne l'attendu pour tous les cas du périmètre ;
  restent D30 (polysémie), D31 (sens d'`ecartee`), D36 (alternatives, nom propre nié), qui ne sont pas corrigés.
- Questions pour le propriétaire (décisions non bloquantes, l'option prudente est prise en attendant) :
  1. **Polysémie (D30)** : faut-il exiger qu'un lien positif vaille pour chaque sens du mot (supervaluation), ce qui
     ferait perdre beaucoup de rappel en français (WOLF prend tous les sens), ou garder la lecture actuelle ?
  2. **`ecartee` (D31)** : une substitution fausse dont les atomes d'identification sont seulement inconnus (« Jean
     n'aime pas Marie » pour « Marie aime Jean ») et une réfutation par une seule source citée donnent `ecartee` ;
     faut-il un statut qui garde la source, ou exiger une réfutation de l'auteur ?

## 7. Garanties établies, garanties absentes, limites

(complété en fin de mission)

## 8. Prochain travail

1. D11, D12, D13 : tests des entrées invalides, de la concurrence, de la reproductibilité.
2. D16 : un oracle indépendant (dans un autre langage, Python), pour un fragment fini, comparé aux deux moteurs.
3. D14, D15 : qualification du comparateur (propriétés, mutations) ; mutations du vérificateur.
4. Revue adversariale par des contradicteurs indépendants ; vérification de leurs contre-exemples.
5. D17, D18 : pertes du compilateur.
