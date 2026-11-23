# Suivi des travaux vers la V1

Référence : `CAHIER_DES_CHARGES.md`. Branche de travail : `claude/dazzling-archimedes-4ip3qp` (jamais `main`).

## Règles de la boucle

1. Une tâche à la fois, dans l'ordre ; chaque tâche finie est testée, committée, poussée, puis cochée ici.
2. Ne jamais abaisser un seuil, ni modifier ou supprimer un test pour le faire passer. Un test existant qui
   entérine un défaut corrigé (ex. la division 86) est mis à jour **en disant pourquoi** dans le commit.
3. Aucune donnée dans le dépôt (§ 15 de `CONCEPTION.md`) : sources, bases compilées, corpus et sorties vont dans
   `/home/user/donnees/` ; seuls les scripts, les manifestes et les mesures agrégées entrent au dépôt.
4. **Décision ouverte** (§ 15 du cahier) : prendre l'option recommandée, l'écrire dans `DECISIONS.md` avec le statut
   *provisoire — à valider*, et continuer. Ne rien rendre irréversible sur une décision provisoire.
5. **Blocage** (réseau, outil, droit) : noter dans « Journal » ci-dessous la cause exacte, passer à la tâche suivante
   non dépendante.
6. Le journal en bas de ce fichier reçoit une ligne par itération : date, tâche, résultat.

## J0 — Remise en état

- [x] **E1 Environnement.** SWI-Prolog récent (≥ 9.2, PPA `swi-prolog/stable` ou compilation ; les paquets Ubuntu 9.0
      sont trop anciens pour Janus), `janus-swi`, `pytest` ; cloner `iconclass/data` (`GIT_LFS_SKIP_SMUDGE=1 git clone
      --depth 1 https://github.com/iconclass/data /home/user/donnees/iconclass-data`) ; WordNet 3.0 Prolog + `dict`
      (wordnetcode.princeton.edu) ; compiler la base ; faire passer toute la suite de tests, y compris celles qui
      demandent `ICONCLASS_DATA`, `WORDNET_PROLOG`, `WORDNET_DICT`. Écrire les commandes exactes dans
      `docs/INSTALLATION.md`. (Le script d'installation de l'environnement cloud sera enregistré au réveil : il demande
      une approbation.)
- [x] **J0.1 Licence.** `LICENSE` (MIT), champ `license` de `pyproject.toml`, fichiers `.pl` du socle dans
      `package-data`.
- [x] **J0.2 Une seule hiérarchie.** `decision:plus_specifiques` sur `arbre:ancetre` ; `preuve()` de
      `socle/moteur.py` calcule les ancêtres par Prolog, pas par préfixe de chaîne ; tests sur `11H(...)` /
      `11H(JEROME)` et une lettre doublée.
- [x] **J0.3 Noms libres.** Une notation `BASE(NOM)` construite par `noms.pl` a pour parent son gabarit `BASE(...)`
      (ou la base quand le gabarit n'est pas une notation) ; `arbre:valide/1`, `ancetre/2`, `profondeur_arbre/2` la
      traitent ; tests.
- [x] **J0.4 Division 86.** Exclue avant la sélection des K premiers dans `decision:retenus/2` ; test mis à jour.
- [x] **J0.5 `f1_attendu`.** Brancher la sélection par espérance du F1 hiérarchique (référence : `_choix_f1` de la
      0.2, `moteur.py`) si le réglage exporté l'exige, sinon retirer le fait du compilateur ; documenter le choix.
- [x] **J0.6 Clés.** `cles:appuis_de/3` accepte les appuis de toute nature admise (pont WordNet, spécialisation), pas
      seulement `egal` ; test.
- [x] **J0.7 `oedipamaas expliquer`.** Corriger `cli.py` (`score`, `contribution`) ; test de contrat de la CLI.
- [x] **J0.8 Négation et relations (transitoire).** Négation reconnue dans la mention et pas seulement au début
      (« depicted without a lion ») ; `cadres:unite_liee/2` respecte le sens de la relation ; tests. (Remplacés au J1
      par les assertions.)
- [ ] **J0.9 Intégration continue.** `.github/workflows/tests.yml` : tests sans base à chaque poussée. Si la poussée
      d'un workflow est refusée (droits), le noter et garder le fichier hors dépôt.
- [ ] **J0.10 Moisson des corpus.** `outils/moisson/` : RKDimages (SPARQL par pages) et Wikidata P1257 (libellés EN et
      FR), sortie JSONL dans `/home/user/donnees/corpus/` avec manifeste (date, requête, empreinte, licence) ;
      dédoublonnage par œuvre entre sources ; séparation développement / test par collection.
- [ ] **J0.11 Mesure de référence.** Script d'évaluation (H-F1, F1 exact, rappel des candidats@N) ; mesures de BM25 et
      du socle actuel (candidats) sur les titres EN moissonnés ; résultats agrégés dans `docs/mesures/J0.md`.

Critère de sortie J0 : tous les tests passent ; la mesure de référence est rejouable depuis les scripts et le manifeste.

## J1 — Le contrat (à commencer quand J0 est fini)

- [ ] **J1.1 Langage d'assertions.** `docs/ASSERTIONS.md` (noms, arités, sens, prémisse admissible, § 5 du cahier) et
      validateur `socle/assertions.pl` ; tests.
- [ ] **J1.2 UDPipe.** Binaire ou liaison UDPipe 1 et modèles FR et EN (UD épinglés) ; licences des modèles dans
      `DECISIONS.md` ; segmentation avec positions en caractères.
- [ ] **J1.3 Lecture du CoNLL-U** en Prolog (DCG), positions conservées.
- [ ] **J1.4 Règles d'interprétation** FR et EN : têtes et noms, propriétés rattachées, négation et sa portée, rôles
      (actif et passif), coordination ; titres simples ; tout le reste dans `incompris`.
- [ ] **J1.5 Paires minimales** : 100 paires FR et EN (`tests/paires/`), en `plunit`.
- [ ] **J1.6 T1, T2, T6 de bout en bout** sur les assertions, preuves avec passages, sortie du § 9.
- [ ] **J1.7 Commande Prolog** : texte ou JSONL en entrée, JSONL et manifeste en sortie, sans Python.

Critère de sortie J1 : les paires passent ; un titre et un cartel courts donnent des codes établis avec preuves
vérifiées. **Point de décision humain : la boucle s'arrête ici.**

## Journal

- 2026-11-23 — création du suivi ; boucle lancée sur J0.
- 2026-11-23 — E1 : SWI-Prolog 11.0.0 (PPA), Janus, Iconclass `0595358`, WordNet 3.0 ; 37 tests passent avec les données réelles ; base compilée (index dérivés en cours). Script d'installation cloud à enregistrer au réveil (approbation).
- 2026-11-23 — J0.1 : licence MIT, sources Prolog du socle empaquetées.
- 2026-11-23 — J0.2 : decision:plus_specifiques et preuve() sur arbre:ancetre ; test du gabarit 11H(...) ancêtre de 11H(JEROME) ; 37 tests passent.
- 2026-11-23 — J0.3 : nom libre enfant de son gabarit (arbre:gabarit_de/2), valide, ancêtres et profondeur ; clé d'un nom libre selon la famille du gabarit ; vérifié sur la base réelle (25F711(BUTTERFLY) → 25F711(...) → … → 2) ; 37 tests passent.
- 2026-11-23 — J0.4 : division 86 écartée avant la sélection des k premiers ; test de décision mis à jour (le défaut y était entériné).
- 2026-11-23 — J0.5 : branché : critère « f1 » du réglage → decision:choix_f1/3, reprise exacte de _choix_f1 (0.2), testée contre une référence Python pour trois g ; lambdas yall remplacées par des prédicats.
- 2026-11-23 — J0.6 : appuis des clés : égalité, lien WordNet admis depuis un sens dominant, mots propres décrits (spécialisation) ; un premier essai avec tous les sens donnait « debout » à la figure par l'entité voisine — le test existant l'a bloqué, d'où la restriction aux sens dominants.
- 2026-11-23 — J0.7 : « expliquer » lit p_catalogue et valeur ; test de contrat qui reproduit le KeyError sur l'ancien code et passe avec la correction.
- 2026-11-23 — J0.8 : négation coupée au mot négatif (no, not, without, neither, nor, never, lack of, absence of) et postposée (absent, missing, invisible) ; cadres:unite_liee/2 suit le sens de la relation ; 39 tests passent.
