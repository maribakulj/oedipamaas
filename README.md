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
- `MANIFESTE.json` : chaque fichier (taille, SHA-256, rôle, statut), et les commits des passes.

**Statut** : tout ce qui vient des annotateurs et des adjudicateurs est un **accord entre agents**, non une validation
humaine ; aucun élément n'est encore relu par une personne. Ce banc est un banc de développement, à consolider puis à
compléter par un corpus indépendant de descriptions réelles annoté humainement ; il n'est pas un corpus de
qualification. Les fichiers `*.json.gz` sont du JSON compressé (`gunzip -k`).
