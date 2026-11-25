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
| D11 | moyenne | Entrées invalides : comportement non testé (graphe invalide, requête mal formée, preuve mal formée) | OUVERT |
| D12 | moyenne | Isolation et concurrence non testées au-delà d'un cas | OUVERT |
| D13 | moyenne | Reproductibilité (même entrée, même sortie, empreinte) non testée | OUVERT |
| D14 | moyenne | Comparateur : transitivité, renommage, insatisfiables, taxinomie non testés ; pas de mutation du comparateur | OUVERT |
| D15 | moyenne | Pas de mutation du vérificateur | OUVERT |
| D16 | moyenne | Pas d'oracle indépendant des deux moteurs pour les fragments finis (les deux moteurs Prolog sont écrits d'après la même spécification) | OUVERT |
| D17 | moyenne | Compilateur : couverture lexicale par sous-chaîne (`couvert/2`), fausse complétude (audit 1, § 11) | CORRIGÉ (cycle 1) |
| D18 | moyenne | Compilateur : la personne héritée devient une variable indépendante (coprésence prise pour participation) (audit 1, § 11) | CORRIGÉ (cycle 1) |
| D19 | basse | Contrat : les types des requêtes sont des atomes, les synsets des entiers (audit 2, § 6) | OUVERT |
| D20 | basse | `sens(_, _, W, W)` : un mot désigne le lemme lui-même ; mot, concept, référent confondus (audit 2, § 6) | DOCUMENTÉ (C7) |
| D21 | basse | Pas de limite de temps ni de mémoire (seulement un budget d'appuis) | OUVERT |

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

## 7. Garanties établies, garanties absentes, limites

(complété en fin de mission)

## 8. Prochain travail

1. D11, D12, D13 : tests des entrées invalides, de la concurrence, de la reproductibilité.
2. D16 : un oracle indépendant (dans un autre langage, Python), pour un fragment fini, comparé aux deux moteurs.
3. D14, D15 : qualification du comparateur (propriétés, mutations) ; mutations du vérificateur.
4. Revue adversariale par des contradicteurs indépendants ; vérification de leurs contre-exemples.
5. D17, D18 : pertes du compilateur.
