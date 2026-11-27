# Les données du banc de graphes et des mesures (branche de données)

Branche orpheline : aucune histoire commune avec le code, jamais fusionnée. Le code, le guide et les commandes de
reproduction sont sur la branche du code (`docs/BANC_GRAPHES.md`, § 5 ; `docs/mesures/V2.md`).

- `banc_graphes/` : les textes du banc (une fiche sur cinq des jeux de développement et de validation M1), les lots,
  le guide remis aux annotateurs, les annotations brutes (`annotations/` : A, un annotateur par lot ; B1, la seconde
  annotation d'un texte sur cinq), l'adjudication (`adjudication/` : lots, graphes adjugés, journaux), les références
  (`reference_JEU_brute.json`, `reference_JEU_adjugee.json`, et `reference_JEU.json`, harmonisée : **la
  référence**), l'harmonisation (`outils/harmoniser.py`, journaux), les graphes du lecteur (`lecteur_*.json.gz`), les
  résultats bruts des mesures (`mesures/`), l'échantillon de relecture humaine (`relecture/`).
- `reference_d30/` : la mesure de référence du lot 1 (codage de bout en bout, trois réglages, par tranches, avec la
  description de chaque passe ; le comparateur des requêtes ; `protocole_delai_mur/` : les passes du premier
  protocole, à délai de mur, gardées).
- `croise/` : l'expérience croisée du 27/11 (`docs/EXPERIENCE_CROISEE.md` sur la branche du code) : les quatre
  conditions par texte, les échecs, les sondes de K, et `causes_ref_ref.json`, les causes de chaque échec, **décidées
  par un agent, provisoires**.
- `banc_graphes/v2/` : la version 2 du banc, par errata (`errata.json`, `journal_v2.json`) ; la version 1 est
  intacte (`docs/EXPERIENCE_CROISEE.md`, § 10). `croise/v2/` : l'expérience croisée sur v1 avec pronoms et sur v2,
  ses tableaux, et `causes_ref_ref_v2.json` (décisions d'agent, **provisoires**).
- `inference/` : le catalogue des inférences (décisions d'agent, **provisoires**) et l'expérience contrôlée des
  couches (`docs/INFERENCES.md`) ; `essai1/`, sa première passe, gardée.
- `c3_corrections/` : les mesures avant / après des corrections du compilateur C3 (PR #16), et leurs passes
  intermédiaires ; son propre `MANIFESTE.json`.
- `surete_lecteur/` : les expériences de sûreté du lecteur (PR #17), en une archive `tar.xz` (910 Mo décompressés),
  et son `MANIFESTE.json` (l'empreinte de chaque fichier de l'archive).
- `c3_contre_expertise/` : la contre-expertise de #16 (PR #18) ; `jugements.json` : des décisions d'agent,
  **provisoires** ; son propre `MANIFESTE.json`.
- `bancs_phase1/` : les bancs de développement de la phase 1 (`docs/BANCS_PHASE1.md`) : `dev/` (les cas par famille, les
  questions, les relectures, les révisions, la couverture), `v1_avant_relecture/` (la première version, gardée) ; son
  propre `MANIFESTE.json`. Accord entre agents, non validé par la propriétaire. Aucun cas de qualification ici.
- `premisses/` : l'admissibilité effective des prémisses selon le noyau, et les comparaisons appariées des versions
  A et S de la sûreté du lecteur sur cette mesure ; son propre `MANIFESTE.json`.
- `MANIFESTE.json` : chaque fichier (taille, SHA-256, rôle, statut), et les commits des passes.

**Statut** : tout ce qui vient des annotateurs et des adjudicateurs est un **accord entre agents**, non une validation
humaine ; aucun élément n'est encore relu par une personne. Ce banc est un banc de développement, à consolider puis à
compléter par un corpus indépendant de descriptions réelles annoté humainement ; il n'est pas un corpus de
qualification. Les fichiers `*.json.gz` sont du JSON compressé (`gunzip -k`).
