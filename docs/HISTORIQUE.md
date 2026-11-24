# Ce qui, dans le dépôt, est historique (25 novembre 2026)

Le dépôt contient trois générations de moteur. Seule la troisième est le moteur en construction ; les deux premières
restent exécutables comme **lignes de base** (la mesure finale compare le moteur à une base simple, `docs/FONDEMENTS.md`
§ 9) et parce que leurs modules Prolog partagent des pièces avec la troisième (`arbre`, `notation`, `libelles`,
`morphologie`). Elles ne sont plus développées. Un audit extérieur (24/11) a jugé le dépôt sur ces fichiers anciens : ce
document dit lesquels ne décrivent plus le moteur.

## Le moteur actuel (troisième génération)

Référence : `CAHIER_DES_CHARGES.md`, `docs/FONDEMENTS.md` (version 2 et amendement), `DECISIONS.md`, `SUIVI.md`.

| Pièce | Fichiers |
|---|---|
| commande, en Prolog | `oedipamaas/socle/commande.pl`, `oedipamaas.pl` |
| lecture des textes (UDPipe, CoNLL-U) | `udpipe.pl`, `conllu.pl`, `interpretation.pl` |
| langage d'assertions et validation | `docs/ASSERTIONS.md`, `assertions.pl` |
| ancrage dans l'image (deux mondes, saillance) | `mondes.pl`, `scene.pl` |
| grammaire des libellés et définitions | `libelles_iconclass.pl`, `definitions.pl`, `outils/definitions/` (Stanza à la compilation, D18) |
| raisonnement et preuves (T1, T2 ; remplacés par l'implication de FONDEMENTS § 4) | `raisonnement.pl`, `sens.pl` |
| essai de la méthode des profils, abandonnée (FONDEMENTS § 6) | `sujets.pl`, `hypotheses.pl`, `outils/sujets/` |
| base | `compiler_iconclass.py`, `compiler_wordnet.py`, `compiler_ressources.py`, `arbre.pl`, `notation.pl`, `morphologie.pl`, `libelles.pl` |
| mesures | `outils/mesure/`, `docs/mesures/` |

## Historique : la version 1.0 (« socle ») — décrite par `CONCEPTION.md`

Une chaîne qui lisait le JSON d'un descripteur d'images (VLM), cherchait des candidats (BM25, WordNet, spécialisation),
calculait des traits et décidait par des arbres appris compilés en Prolog. Remplacée par la lecture de textes libres
et le raisonnement par assertions (J1), puis par les fondements v2. Ses défauts relevés par l'audit (preuve lexicale,
traits, décision statistique, division 86 exclue dans le moteur) sont ceux de cette chaîne.

Fichiers : `oedipamaas/socle/moteur.py`, `coder.py`, `candidats.py`, `faits_description.py`, `compiler_decision.py`,
`construire_base.py` (index de cette chaîne), `traits.pl`, `decision.pl`, `cadres.pl`, `cles.pl`, `lexique.pl`,
`noms.pl`, `preuve.pl`, `recherche.pl`, `specialisation.pl`, `description.pl`. Tests : `tests/test_socle_cles.py`,
`test_socle_decision.py`, `test_socle_lexique.py`, `test_socle_libelles.py`, `test_socle_moteur_ordres.py`,
`test_socle_recherche.py`.

Branches de cette chaîne, toutes trois en retard de 47 commits sur `main` et emboîtées (`relations` ⊂ `econome` ⊂
`noms`) : améliorations des traits, des cadres et de la recherche (relations, explication économe, noms par leurs mots,
locutions de WordNet, lettres doublées). Rien n'y sert le moteur actuel ; à archiver puis supprimer.

## Historique : la version 0.2 — décrite par le `README.md` d'origine

Recherche en Python, modèle de phrases, décision logistique : `oedipamaas/*.py` (`cli.py`, `moteur.py`, `recherche.py`,
`semantique.py`, `texte.py`, `lecture.py`, `references.py`, `wikidata.py`, `base.py`), `oedipamaas/regles/`,
`tests/test_moteur.py`. Elle sert de ligne de base de recherche (BM25 sur les libellés).
