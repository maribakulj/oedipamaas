# L'organisation des agents et la délégation entre modèles (28/11)

**Le principe, fixé par la propriétaire :**
- la qualité scientifique, formelle et technique est une contrainte absolue ;
- une tâche va au modèle le moins coûteux dont on a raisonnablement établi qu'il la fait à qualité égale ;
- l'équivalence ne se présume pas : elle se qualifie, sur un petit échantillon, par des critères indépendants du modèle
  (§ 6).

La politique courte est dans `CLAUDE.md`. Ce document en donne le détail. Les instructions propres à chaque rôle sont
dans `.claude/agents/<rôle>.md`.

## 1. Ce que l'environnement prend en charge (vérifié le 28/11, Claude Code 2.1.332)

- **Le frontmatter d'un sous-agent** (`.claude/agents/<nom>.md`) prend en charge, entre autres champs : `name`,
  `description`, `tools`, `disallowedTools`, `model` (`opus`, `sonnet`, `haiku`, un identifiant complet, ou `inherit`),
  `effort` (`low` à `max`, selon le modèle), `permissionMode`, `maxTurns` et `color`. Les fichiers ajoutés pendant une
  session sont pris en compte sans la redémarrer. Source : la documentation des sous-agents de Claude Code.
- **Quel modèle s'applique.** L'ordre est le suivant :
  1. le paramètre `model` passé à l'outil Agent ;
  2. le `model` du frontmatter ;
  3. `CLAUDE_CODE_SUBAGENT_MODEL` ;
  4. le modèle de la conversation.

  Aucune de ces variables n'est définie dans l'environnement. **L'orchestrateur ne passe donc pas de `model` à l'appel :
  c'est le frontmatter qui décide.**
- **Quel effort s'applique.** `effort` du frontmatter fixe l'effort du sous-agent. Seule `CLAUDE_CODE_EFFORT_LEVEL`
  passerait avant lui, et elle n'est pas définie.
- **Le modèle effectivement employé se vérifie** dans la transcription du sous-agent, par le champ `model` de ses
  réponses, et non par son nom ni par sa spécialité :
  ```bash
  grep -o '"model":"[^"]*"' ~/.claude/projects/<projet>/<session>/subagents/agent-<id>.jsonl | sort | uniq -c
  ```
  Le résultat est consigné au journal (§ 7).
- **Ce qui a été constaté le 28/11 :**
  - la session a d'abord refusé l'appel par `subagent_type`, alors que le dossier `.claude/agents/` venait d'être créé
    comme lien symbolique ;
  - une fois le lien remplacé par un vrai dossier, les rôles sont apparus après quelques minutes ;
  - les agents lancés entre-temps ont été appelés comme agents généraux, avec le `model` et l'`effort` du rôle passés
    explicitement, et un prompt qui leur fait lire d'abord le fichier du rôle.

  Leur modèle a été vérifié dans la transcription, comme pour les autres. Le dossier doit être un vrai dossier : un lien
  symbolique ne semble pas suivi.

## 2. Les rôles

| agent | modèle | effort | ce qu'il fait |
|---|---|---|---|
| `formal-architect` | opus | high | fondements, décisions formelles et ontologiques, propriétés de sûreté, expressivité, contradictions entre spécifications, contre-modèles difficiles |
| `semantic-auditor` | opus | high | revue ciblée des modifications critiques (noyau, vérificateur, oracle, interpréteur de référence) ; adjudication des désaccords sémantiques complexes |
| `prolog-engineer` | sonnet | high | implémentation Prolog d'après une spécification approuvée |
| `python-engineer` | sonnet | high | implémentation Python : outils, validateurs, adaptateurs, interpréteur de référence |
| `test-engineer` | sonnet | high | tests unitaires, génératifs, différentiels et métamorphiques, écrits d'après la spécification et non d'après le code |
| `semantic-annotator` | sonnet | high | annotation indépendante des bancs, au niveau (a), selon le guide |
| `formal-representer` | sonnet | high | représentation formelle des cas dans le langage de référence (nr-1), sans voir la référence ; **délégation en qualification** (§ 6) |
| `researcher` | sonnet | high | études bibliographiques et analyses de ressources, avec des références vérifiées |
| `code-reviewer` | sonnet | high | première revue indépendante d'une implémentation ; lecture et exécution seulement |
| `data-operator` | haiku | low | inventaires, extractions, manifestes, archivage, conversions simples, contrôles de format |
| `ci-investigator` | haiku | low | extraction des résultats de CI et première analyse des journaux |

**L'orchestrateur** est la session principale (Opus). Il garde :
- les corrections de la proposition de sûreté ;
- les décisions formelles ;
- la spécification de la supervaluation ;
- les arbitrages conceptuels ;
- l'intégration (commits, PR, fusions) ;
- la synthèse.

Il ne fait pas lui-même l'implémentation ordinaire qui peut être déléguée. Il ne relit pas les résultats bruts : il lit
les synthèses et les fichiers qu'elles citent.

**Un script plutôt qu'un modèle** dès qu'une tâche est déterministe : un comptage, une somme de contrôle, une
comparaison de statuts, un manifeste.

## 3. Le contrat d'une tâche déléguée

Chaque délégation donne, et seulement ce qui est nécessaire :

```
Objectif :
Spécification : fichiers et sections à lire (pas tout le corpus des fondements, pas l'historique)
Périmètre : ce que la tâche touche
Invariants : ce qui doit rester vrai
Interdit : ce qu'elle ne lit pas et ce qu'elle ne modifie pas
Critères d'acceptation :
Tests attendus :
Escalade : quand s'arrêter et remonter (§ 5)
Sortie : le fichier de résultats détaillés ; la synthèse à rendre
```

**Les règles communes,** rappelées dans chaque fichier d'agent :
- **Les agents ne commitent ni ne poussent.** C'est l'orchestrateur qui le fait, après la revue. Une seule exception : l'archivage
  mécanique sur la branche de données, quand le contrat le demande (`data-operator`). La ligne `Co-Authored-By` du
  commit nomme alors le modèle qui l'a fait.

  Cette exception est validée par la propriétaire, à trois conditions :
  - l'archivage est mécanique, contrôlé, et limité au périmètre autorisé ;
  - les caches, les fichiers `.pyc` et les artefacts régénérables inutiles en sont exclus ;
  - **la licence de chaque ressource est vérifiée avant tout archivage public**, puisque le dépôt est public. Un
    fichier tiré d'une ressource dont la licence n'est pas vérifiée n'est pas archivé. Il est seulement décrit, avec
    son empreinte et le moyen de le régénérer.
- **Chaque agent a son propre dossier de brouillon**, sous le scratchpad de la session : `<scratchpad>/<rôle>_<tâche>/`.
  Ne jamais partager un dossier entre deux agents, en particulier entre deux annotateurs (une indépendance a été perdue
  ainsi, `BANCS_PHASE1.md`, § 9.5).
- **Les résultats détaillés vont dans des fichiers.** Le rapport final est une synthèse courte qui cite ces fichiers et
  nomme le modèle employé.
- **Les données restent hors des branches de code.** Elles vont sous `/home/user/donnees/` et sur la branche orpheline
  `donnees/banc-graphes`.
- **La séparation entre développement et qualification est impérative.** Aucun agent n'ouvre :
  - `/home/user/donnees/banc_qualif/reference.json`, `/home/user/donnees/banc_qualif2/reference_*.json`,
    `/home/user/donnees/banc_scelle/reference.json`, ni aucun `reference_autorisee.json` ;
  - le jeu indépendant : `jeu.json` de la branche `donnees/qualification-independante`,
    `/home/user/donnees/qualification_independante/`, le worktree `/home/user/oedipamaas-qualif-wt` ;
  - les scripts de construction de ces jeux : `build_ref.py`, `verif.py`, `build1.py`, `check1.py`, `build_ref2.py`,
    `verify_ref2.py`, `build3.py`, `check3.py`.
- **L'oracle, les références et les critères d'acceptation ne se modifient jamais d'après les sorties du moteur.** Un test
  ne s'ajuste pas pour faire passer une implémentation. On ne désactive aucun test. On garde les mesures défavorables et
  anciennes. Pas de repli silencieux.
- **Aucune information personnelle de la propriétaire** dans une requête extérieure.
- Le français pour les documents et les rapports.

## 4. La vérification et l'indépendance

- **Celui qui implémente n'est pas celui qui vérifie.** Pour une implémentation ordinaire, la première revue
  indépendante est faite par `code-reviewer` (Sonnet), qui reçoit la spécification et le code, non le raisonnement de
  l'implémenteur.
- **Les tests d'une spécification** sont écrits par `test-engineer`, d'après la spécification. Il peut lire le code pour
  l'interface, non pour en tirer les valeurs attendues.
- **Pour une modification critique,** Opus (`semantic-auditor` ou l'orchestrateur) fait en plus une revue ciblée : les
  invariants, les contre-exemples et l'adéquation à la spécification. Sont critiques les modifications :
  - du noyau, du vérificateur et de l'oracle ;
  - de l'interpréteur de référence ;
  - des règles de certification ;
  - d'une référence de banc.

  Cette revue ne refait pas tout le travail : elle porte sur ce qui peut rompre la sûreté.
- **Les annotateurs et les rédacteurs de représentations formelles** ne voient ni le code du moteur, ni ses sorties, ni
  les statuts relatifs à K, ni la référence adjugée, ni le travail des autres annotateurs, ni `inventaire.json` ou
  `repartition.json`.

## 5. L'escalade

Un agent s'arrête et remonte, à l'orchestrateur ou au modèle supérieur, quand :
- la spécification est ambiguë ou contradictoire ;
- une décision conceptuelle est nécessaire ;
- un invariant paraît violé ;
- une preuve ou une réfutation est contestable ;
- l'oracle et le moteur divergent sans explication ;
- deux corrections successives n'ont pas résolu le problème ;
- la tâche dépasse manifestement ce qu'il peut garantir.

**L'escalade donne :**
- ce qui est fait ;
- les tentatives ;
- les contre-exemples, minimaux ;
- la difficulté exacte ;
- les fichiers.

L'agent supérieur reprend à partir de là, sans refaire l'exploration.

Les décisions de la propriétaire ne sont jamais prises par un agent. Elles sont formulées par l'orchestrateur, avec leurs
options, et soumises à la propriétaire.

## 6. La qualification de la délégation

**Une famille de tâches n'est déléguée à un modèle moins coûteux qu'après une comparaison ciblée,** quand l'équivalence
est incertaine. La comparaison se fait sur un petit échantillon représentatif, déjà traité par Opus, avec des critères
fixés d'avance et indépendants du modèle :
- l'accord avec la référence ou avec le résultat attendu ;
- les erreurs et les omissions ;
- les défauts de sûreté non détectés : un statut plus fort que la référence sur un axe, une certification indue ;
- le taux de reprise nécessaire ;
- les escalades ;
- la consommation, quand elle est accessible (le nombre de jetons du sous-agent).

On élargit la délégation par étapes, et on ne lance pas de grande campagne redondante pour comparer.

**La décision de la propriétaire (28/11).** L'organisation est validée, ainsi que la délégation de l'annotation et de la
représentation formelle à Sonnet, à deux conditions : les contrôles par échantillonnage et les arbitrages indépendants
continuent. Les pilotes ne démontrent pas une équivalence générale entre Sonnet et Opus. La consommation par cas du
pilote de représentation formelle est élevée. On regroupe donc les missions pour amortir l'apprentissage des
spécifications. On mesure, quand c'est possible, la consommation **totale** d'une tâche : reprises, arbitrages et
coordination compris.

| famille de tâches | état |
|---|---|
| implémentation, tests, revue de code, documentation technique, études | déléguée à Sonnet (capacité établie pour des contrats explicites ; l'implémentation reste revue) |
| inventaires, extractions, manifestes, CI | déléguée à Haiku, ou à un script ; le résultat se vérifie mécaniquement |
| annotation sémantique des bancs (niveau (a)) | **déléguée à Sonnet le 28/11** après le pilote (`docs/mesures/QUALIFICATION_DELEGATION.md`, § 1) ; désaccords arbitrés à l'aveugle par Opus |
| représentation formelle des cas (nr-1) | **déléguée à Sonnet le 28/11** après le pilote (même document, § 2), par lots ; écarts revus par Opus |
| adjudication des désaccords complexes, décisions formelles, sûreté | Opus |

**Un biais à garder en tête :** la référence adjugée vient d'annotations Opus. L'accord avec elle favorise Opus. La
comparaison regarde donc aussi les écarts de sûreté, sur chaque axe, et fait juger les désaccords par `semantic-auditor`
sur un échantillon, sans lui dire quel modèle a produit quoi.

## 7. Le journal des délégations

Chaque tâche importante y est inscrite, avec :
- l'agent et le modèle vérifié ;
- l'effort ;
- les escalades et leurs raisons ;
- le rapport.

| date | tâche | agent | modèle vérifié | effort | escalade | rapport |
|---|---|---|---|---|---|---|
| 28/11 | bancs v3 : annotations A et B, adjudications, représentations formelles des cas de base, langage de référence | agents généraux | Opus (hérité de la session, avant cette organisation) | — | — | `BANCS_PHASE1.md` § 9.5, `docs/mesures/FORMEL_BANCS.md` |
| 28/11 | vérification de la configuration (champs du frontmatter, ordre de priorité du modèle) | claude-code-guide | non vérifié (agent intégré) | — | — | § 1 |
| 28/11 | état de la CI de `claude/bancs-v3` | ci-investigator (agent général, modèle et effort passés à l'appel) | Haiku (transcription : 13 réponses) | low | — | brouillon `ci-investigator_bancs-v3/ci.md` ; un commit sans exécution, poussé avec le suivant |
| 28/11 | L22 : implémentation du statut local ER_H | python-engineer (idem) | Sonnet (65 réponses) | high | 2 doutes de spécification remontés, tranchés par l'orchestrateur ; la spécification a été corrigée deux fois | commit 5b37eb4 |
| 28/11 | L22 : tests d'après la spécification | test-engineer (idem) | Sonnet (68) | high | 4 doutes remontés et tranchés | 51 tests, 8 mutations tuées |
| 28/11 | L22 : première revue indépendante | code-reviewer | Sonnet (50) | high | — | 6 mutations vivantes, renvoyées aux tests ; 3 doutes tranchés |
| 28/11 | pilote : représentation formelle de 16 cas de base, déjà écrits par Opus | formal-representer (idem) | Sonnet (45) | high | — | `QUALIFICATION_DELEGATION.md`, § 2 |
| 28/11 | pilote : annotation de 9 cas et de leurs variantes (62 éléments) | semantic-annotator (idem) | Sonnet (13) | high | — | même document, § 1 |
| 28/11 | arbitrage à l'aveugle des 16 désaccords du pilote d'annotation | semantic-auditor | Opus (27) | high | 2 contradictions de spécification remontées | même document, § 1 |
| 28/11 | audit des langages : inventaire mécanique | data-operator | Haiku (26) | low | — | `/home/user/donnees/audit_langages/` |
| 28/11 | audit des langages : étude comparative et expérimentation Python / Prolog | researcher | Sonnet (92) | high | 5 points remontés (`AUDIT_LANGAGES.md` § 7.3) | `docs/AUDIT_LANGAGES.md` |
| 28/11 | archivage des pilotes et de l'audit sur `donnees/banc-graphes` | data-operator | Haiku | low | — | commit 5279353 ; un fichier de 22 Mo exclu, régénérable |
| 28/11 | audit des langages : arbitrage | orchestrateur | Opus | — | — | `docs/ARCHITECTURE_LANGAGES.md` |
