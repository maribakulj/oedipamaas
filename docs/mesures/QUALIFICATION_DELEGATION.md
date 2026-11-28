# La qualification de la délégation : deux pilotes Sonnet (28/11)

**La question :** Sonnet peut-il annoter les bancs au niveau (a), et écrire les représentations formelles des cas, avec
une qualité équivalente à celle d'Opus (`docs/ORGANISATION_AGENTS.md`, § 6) ?

**La méthode :** un petit échantillon déjà traité par Opus, des critères fixés d'avance, et un arbitrage à l'aveugle des
désaccords par Opus (`semantic-auditor`), sans lui dire quel jugement vient de qui.

**Le modèle effectivement employé** a été vérifié dans la transcription de chaque agent. La consommation est donnée en
jetons de sortie et de contexte du sous-agent ; leur prix n'est pas accessible ici.

**Les données :** `/home/user/donnees/bancs_phase1/v3/pilote_sonnet/`.
- `annotation/` : l'entrée, et le fichier `pilote.S.json` ;
- `adjudication/` : les désaccords anonymisés et les verdicts ;
- `cle_adjudication.json` : la clé, que l'arbitre n'a pas vue ;
- `formel/` : les entrées, la sortie et la comparaison.

## 1. L'annotation (niveau (a))

**L'échantillon :** 9 cas de base, un par famille, et toutes leurs variantes, soit 62 éléments. Le cas de chaque famille
a été choisi parmi ceux qui ont une dépendance ou un écart connu. L'échantillon est donc plus difficile que la moyenne.
- **Sonnet :** `semantic-annotator`, effort élevé, le même guide et les mêmes interdits que les annotateurs Opus.
- **Opus :** les annotateurs A et B de la version 3, et la référence adjugée tirée d'eux.

**Contre la référence adjugée, avant l'arbitrage :**

| | même statut | plus fort sur un axe | kappa |
|---|---|---|---|
| Sonnet | 46 | 12 | 0,68 |
| A (Opus) | 60 | 2 | 0,96 |
| B (Opus) | 57 | 5 | 0,90 |

Ces chiffres favorisent Opus par construction : la référence a été adjugée à partir de A et de B.

**L'arbitrage à l'aveugle des 16 désaccords** entre Sonnet et la référence (`adjudication/verdicts.json`) :

| verdict | nombre |
|---|---|
| Sonnet a raison | 8 |
| la référence a raison | 6 |
| aucun des deux | 1 (ee-011 #6) |
| dépendance d'un principe non tranché | 1 (co-024 #3, l'asymétrie d'« emprisonner », décision 9) |

| erreurs écartées par l'arbitre | sûreté | prudence |
|---|---|---|
| de Sonnet | 3 (ee-011 #3, sa-016 #4, pi-001 #3) | 3 |
| de la référence | 3 (ee-011, #0, #1), et 1 de plus dans ee-011 #6 | 5 |

- **Les erreurs de sûreté de Sonnet** sont un F tiré d'un rôle inversé ou d'un autre patient, et un V tiré d'une lecture
  de « falling » qui englobe le résultat.
- **Les erreurs de prudence de Sonnet** viennent de « perhaps » et de « peut-être », traités comme une alternative de
  l'auteur. L'arbitre les range parmi les prémisses graduées, donc parmi les hypothèses (décision 22).
- **Les erreurs de sûreté de la référence** viennent d'un ancrage « accompli » que le texte ne dit pas, pour « the fall of
  Icarus ». L'arbitre note lui-même un doute : rien ne fixe l'ancrage par défaut d'un nom d'événement.

**Ce que cela dit.** Sur cet échantillon, et une fois les désaccords arbitrés, Sonnet a une qualité comparable à celle
de la référence Opus : 54 éléments justes sur 62, contre 52, et autant d'erreurs de sûreté. L'échantillon est petit, et
l'arbitre est unique.

**Neuf éléments de la référence adjugée sont contestés** par l'arbitrage : ee-011, #0, #1, #5, #6, et sa-016, #0, #1,
#5. Ils ne sont pas corrigés ici. Ils sont signalés pour l'échantillon de la propriétaire (D23), et pour la décision
sur l'ancrage d'un nom d'événement.

**Les lacunes du guide que Sonnet a relevées,** et que l'arbitre confirme en partie :
- la réserve de l'auteur (« perhaps », « dit-on ») ;
- une identification apportée par une source citée ;
- quand poser un point d'ambiguïté sur la définition ;
- le format d'une classe à plusieurs preuves.

L'arbitre ajoute deux contradictions entre documents :
- les fondements d'un F, entre le guide (§ 3) et l'étude (§ 6.3), qui ajoute la distinction documentaire ;
- l'exclusivité des ancrages, tranchée au § 6.2 de l'étude et tenue pour ouverte au § 8.4.

**Consommation :** environ 164 000 jetons de contexte pour 62 éléments.

## 2. La représentation formelle (nr-1)

**L'échantillon :** 16 cas de base déjà écrits par les rédacteurs Opus. Huit d'entre eux avaient un écart avec la
référence, choisis exprès. L'échantillon est donc défavorable à Opus, et les taux ne se comparent pas tels quels.

| | représentés | égal à la référence | plus fort | non représentés |
|---|---|---|---|---|
| Sonnet | 15 | 11 | 2 (co-008, mn-006) | 1 (ee-017) |
| Opus, sur les mêmes cas | 14 | 8 | 2 (co-011, mn-006) | 2 (co-008, ep-016) |

- **Les écarts de Sonnet tiennent aux mêmes règles que ceux d'Opus.**
  - La portée d'une réfutation (L6) : mn-006, pour les deux modèles.
  - L'exclusivité de l'ancrage (L8) : co-008, que Sonnet écrit comme un état antérieur, là où Opus le déclarait non
    représentable.
  - L'attestation des postulats de K\* : co-015. Sonnet suit les exemples et marque l'incompatibilité comme attestée ;
    Opus la marquait non attestée.
- **Les défauts du langage relevés** sont les mêmes : la convention de l'imminent, la légende qui identifie une figure, la
  relation de résultat. Sonnet, comme Opus, ne force pas de projection. Il a gardé à part une variante possible d'ee-017,
  et il l'a dit.
- **Aucune représentation n'a de défaut de formation.** Leur aller-retour par la syntaxe concrète est exact.

**Consommation :** environ 393 000 jetons pour 16 cas. Les rédacteurs Opus avaient consommé environ 500 000 jetons pour
72 cas chacun. Une part de l'écart est le coût fixe d'apprendre le langage, amorti sur peu de cas. Le prix par jeton,
plus faible pour Sonnet, n'est pas mesuré ici.

**Une contradiction dans les consignes** est révélée par les deux modèles. Le fichier du rôle dit « attesté seulement si
une ressource le donne », alors que les exemples marquent attestés les postulats de K\* tirés du guide (§ 1). C'est la
question ouverte du § 2.2 de `FORMEL_BANCS.md`. Elle reste à trancher, et le fichier du rôle sera aligné sur la
décision.

## 3. La décision de délégation

- **L'annotation au niveau (a) est déléguée à Sonnet.** Les deux annotateurs indépendants seront Sonnet, chacun dans son
  dossier. Les désaccords sont arbitrés à l'aveugle par Opus, ainsi que les cas où un statut est plus fort sur un axe que
  celui de l'autre annotateur. Un contrôle par échantillon continue à chaque campagne.
- **La représentation formelle est déléguée à Sonnet,** par lots assez grands pour amortir l'apprentissage du langage.
  Opus revoit les écarts avec la référence et les défauts du langage signalés ; il ne refait pas les représentations.
- **Restent à Opus :** l'arbitrage des désaccords, les décisions de principe que ces pilotes ont fait apparaître, et la
  revue des règles de certification.
- **Ce qui ne change pas :** la séparation des données de qualification, l'indépendance des annotateurs et la
  conservation de tous les jugements.
