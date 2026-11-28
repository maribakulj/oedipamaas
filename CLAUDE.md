# oedipamaas : consignes pour Claude Code

Moteur hors ligne qui relie des descriptions d'œuvres (français, anglais) à des notations Iconclass, avec des preuves
vérifiables. Pas de LLM à l'exécution. Tout le travail (docs, commits, PR) est en français.

## Politique de délégation (détail : `docs/ORGANISATION_AGENTS.md`)

- **La qualité est une contrainte absolue.** À qualité égale, on prend le modèle le moins coûteux dont la capacité est
  établie. Un script déterministe passe avant un modèle.
- **La session principale (Opus) orchestre :** fondements, décisions formelles, sûreté, supervaluation, arbitrages,
  adjudication des désaccords complexes, revue ciblée des modifications critiques, intégration, synthèse. Elle ne fait
  pas l'implémentation ordinaire.
- **Sonnet produit :** implémentation, tests, revue de code, documentation technique, études, annotation et
  représentation formelle des bancs (ces deux dernières en qualification).
- **Haiku exécute :** inventaires, extractions, manifestes, CI, contrôles mécaniques.
- **Les agents sont dans `.claude/agents/`,** avec leur modèle et leur effort dans le frontmatter. On ne passe pas de
  `model` à l'appel. Le modèle effectivement employé se vérifie dans la transcription et s'inscrit au journal (§ 7).
- **Chaque délégation suit le contrat :** objectif, spécification utile, périmètre, invariants, interdits, critères
  d'acceptation, tests, escalade, sortie. Elle donne le contexte nécessaire, pas davantage.
- **Celui qui implémente ne vérifie pas.** Les tests viennent de la spécification. Une modification critique (noyau,
  vérificateur, oracle, interpréteur de référence, certification, références) reçoit en plus une revue Opus ciblée.
- **On escalade** sur une ambiguïté, une décision conceptuelle, un invariant violé, une preuve contestable, une divergence
  inexpliquée entre l'oracle et le moteur, ou un échec répété. L'escalade transmet ce qui est fait.
- **Les synthèses remontent, les résultats détaillés restent dans des fichiers.** On parallélise seulement le travail
  indépendant, et chaque agent a son propre dossier de brouillon.

## Règles permanentes

- **Les données ne vont jamais dans une branche de code.** Elles vont sous `/home/user/donnees/` et sur la branche
  orpheline `donnees/banc-graphes`.
- **Développement et qualification restent séparés.** On n'ouvre ni les références scellées, ni le jeu indépendant, ni
  leurs scripts de construction : la liste est au § 3 de `docs/ORGANISATION_AGENTS.md`.
- **L'oracle, les références et les critères d'acceptation ne se modifient jamais d'après les sorties du moteur.** On ne
  désactive aucun test. On garde les mesures défavorables et anciennes. Pas de repli silencieux.
- **Les décisions de la propriétaire ne sont prises par aucun agent.** On les formule, avec leurs options.
- **Aucune information personnelle de la propriétaire** dans une requête extérieure. Aucun identifiant de modèle dans
  les fichiers du dépôt, hormis le frontmatter des agents et le journal des délégations.
- **Commits :** un message en français. Les **PR :** un corps en français, avec la mention « Ne pas fusionner
  automatiquement ». **Fusions :** des commits de fusion, avec un contrôle de la CI après chacune.
