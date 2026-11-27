# La sûreté du lecteur : X1, X2, X3 (27/11)

Les premières expériences de C7 (`docs/EXPERIENCES_C7.md`, § 3 à 5) : les nombres (X1), les portées et les sources
(X2), les négations et les modalités (X3). Approche A : des règles générales sur l'arbre de dépendances (Stanza),
avec des lexiques venus d'une ressource (K : WordNet, WOLF) ou du guide du banc. Approche C : A, et « dans le doute, non
admissible ». Mesure : la comparaison appariée par fiche au lecteur actuel (`outils/graphes/apparier.py`), et le
premier jalon validé le 27/11 :
- les promotions au moins divisées par deux : borne haute du rapport apparié ≤ 0,5 ;
- au plus cinq points de couverture perdus : borne basse de la différence appariée ≥ −0,05.

**Le jalon n'est atteint par aucune version.** La version A divise les promotions par 1,5 à 1,7 en validation, mais
perd 6 à 8 points de couverture. Une version exploratoire (« certain ») garde la couverture (−1,4 à −2,8 points),
mais ne divise les promotions que par 1,3 à 1,4. Le défaut de sûreté de l'expérience croisée (la variante de
négation de 47G3355, établissable) disparaît dans toutes les versions.

## 1. Le protocole

- **Le lecteur par défaut ne change pas.** Les règles sont des options (`OEDIPAMAAS_SURETE`, une liste séparée par
  des virgules) :
  - `nombres` (X1) ;
  - `portees`, `citations` (X2, approche A) ;
  - `modalites`, `negations` (X3) ;
  - `doute` (approche C) ;
  - `certain` (exploratoire, § 4).
- **Sans option, les faits sont identiques** à ceux du banc (`banc_graphes/lecteur_JEU.json` : 0 différence sur 120
  et 204 textes), et chaque test vérifie aussi le comportement par défaut.
- **Les versions mesurées :**

  | version | options |
  |---|---|
  | A | `nombres,portees,citations,modalites,negations` |
  | C | A + `doute` |
  | S (exploratoire) | A + `certain` |

- **La mise au point s'est faite sur le développement.** La validation a été lue pour décider, et une seule fois pour
  un diagnostic (§ 4), sans réglage.
  - Les règles de X2 viennent du texte du guide : « le peintre a la portée `histoire`, ses actes sur l'image la
    portée `oeuvre` » ; H1 ; H2 ; la liste de `portee`.
  - Le résumé des promotions de la validation (portées « image », « composition », « peintre ») était déjà connu,
    par `docs/mesures/V2.md`, avant l'écriture des règles.
- **`outils/graphes/relire.pl`** refait l'interprétation sur l'analyse en dépendances gardée par `lire.pl`, sans
  Stanza (une minute au lieu de cinq par jeu) ; il a servi à mettre au point.
  - Sans option, il donne les mêmes faits que le banc.
  - Pour chaque version mesurée, la lecture complète par `lire.pl` est refaite, et elle doit donner les mêmes faits
    (§ 6).

## 2. Les règles

Toutes sont dans `oedipamaas/socle/interpretation.pl`. Chacune a son contre-exemple dans
`tests/plunit/test_surete_lecteur.pl` (13 tests), sur une analyse faite à la main et un K minuscule, et le test vérifie
que la règle ne s'applique pas sans son option.

**X1, les nombres.**
- Un numéral cardinal (`nummod`) d'un nom donne `nombre(E, N)`, à partir de 2 (le guide : « un » n'est pas un nombre
  dit).
- La valeur se lit en chiffres, ou d'après la classe fermée des cardinaux simples (anglais, français). Un numéral
  illisible (« several », « vingt-deux ») n'en donne aucun.

**X2, les portées et les sources.**
- **L'auteur désigné** (« the painter », « le peintre ») : `histoire`.
  - « Désigné » veut dire un déterminant défini, démonstratif ou possessif ; « a painter at his easel » est une
    figure.
  - L'auteur est le praticien d'une technique de l'image (peintre, sculpteur, photographe, graveur, dessinateur,
    illustrateur, enlumineur), ou un de ses hyponymes dans K. « Artist » n'est pris que comme mot : ses hyponymes dans
    K comprennent les musiciens.
- **L'œuvre** : `oeuvre`, dans trois cas :
  - désignée, si sa tête est dans K une création, une représentation ou un art (creation, representation, art ;
    création, représentation, art ; WOLF n'a « tableau » que sous art), ou un mot que le guide nomme pour l'objet (la
    toile, le panneau, la feuille, l'état, la technique, le cadre, la composition, l'œuvre, le titre) ; et si elle
    n'est pas l'objet d'une action de figure ;
  - sujet d'un verbe de figuration employé transitivement, sans destinataire (« An anatomical plate shows a nude » ;
    mais « she shows him a book » est une action) ;
  - contenant de la scène (« Dans une gravure fantastique, … »), si c'est une œuvre de façon certaine dans K
    (« dans un paysage », « on the ground » ne le sont pas).
- **Ce qui parle de l'œuvre sans être figuré** (le spectateur, la notice, le catalogue, l'historien, le critique,
  le style, et le complément du nom d'un style : « à la manière de Poussin ») : `non_ancre`.
- **Les actes de l'auteur ou de l'œuvre** (un événement dont ils sont le sujet ou le complément d'agent) : `oeuvre`.
- **Les sources citées** (« according to Vasari », « selon … ») : ce qui dépend du verbe que la citation complète a
  pour énonciateur la source.
- **L'option `doute` (approche C)** ajoute les parties du plan de l'image (le cadre spatial du lecteur : premier plan,
  fond…) et le texte qui accompagne l'œuvre (H1 : caption, légende…), en `oeuvre`.
- **La portée d'une relation reste celle de l'image** (« le centre de la composition »).

**X3, les négations et les modalités.**
- **La question indirecte** (« whether … », « si … ») et la proposition complément d'un verbe nié (« what passes
  between them cannot be read ») : `non_affirme` (le guide : « le contenu d'une question »).
- **La double négation** (décision du 27/11) : l'événement dont le sujet est nié par « no », « aucun » est
  `non_affirme`.
- **Des événements en alternative** (« s'il souffre ou s'il réfléchit ») : `alternative`.
- **L'existence modalisée** (« où apparaissait peut-être la terre ») : le sujet d'un verbe de présence modalisé prend
  sa modalité.
- **Un groupe nominal nié par « not », « pas »** (« only the bone is drawn, not the body »), et les adjectifs d'absence
  « disparu », « manquant » : `neg`. « Gone » est écarté : « his lantern gone out ».

## 3. Les résultats appariés

Lecteur actuel → version, et intervalle à 95 % de la différence appariée (1 000 tirages de fiches, graine 20261127).

**Développement (40 fiches, 120 textes ; mise au point) :**

| | A | C | S (exploratoire) |
|---|---|---|---|
| taux de promotion (lecteur actuel 70,7 %) | 41,4 % [−42,1 ; −17,5] | 37,4 % [−47,8 ; −19,0] | 48,5 % [−36,3 ; −11,8] |
| rapport des promotions | [0,42 ; 0,73] | [0,37 ; 0,70] | [0,50 ; 0,82] |
| couverture (69,5 %) | 68,6 % [−1,9 ; −0,3] | 67,8 % [−2,8 ; −0,6] | 69,1 % [−0,9 ; 0,0] |
| précision des admissibles (71,8 %) | 74,1 % [+1,0 ; +3,6] | 74,5 % [+1,3 ; +4,1] | 73,5 % [+0,7 ; +2,8] |
| pertes ailleurs | aucune | propriétés qualifiées | aucune |
| jalon | non | non | non |

**Validation M1 (40 fiches, 204 textes ; décision) :**

| | A | C | S (exploratoire) |
|---|---|---|---|
| taux de promotion (lecteur actuel 82,0 %) | 51,6 % [−33,8 ; −27,0] | 49,2 % [−36,4 ; −29,4] | 60,0 % [−24,9 ; −19,2] |
| rapport des promotions | [0,59 ; 0,67] | [0,56 ; 0,64] | [0,70 ; 0,76] |
| couverture (72,9 %) | 65,5 % [−8,4 ; −6,4] | 64,5 % [−9,4 ; −7,2] | 70,8 % [−2,8 ; −1,4] |
| précision des admissibles (57,4 %) | 63,0 % [+4,7 ; +6,5] | 63,5 % [+5,1 ; +7,0] | 62,3 % [+4,2 ; +5,6] |
| gains (intervalle > 0) | rôles, entités, événements (qualifiés), modalités, portées, alternatives | les mêmes | les mêmes |
| pertes (intervalle < 0) | propriétés qualifiées [−9,4 ; −5,1], noms qualifiés [−7,4 ; −0,9] | propriétés [−10,6 ; −6,3], noms | propriétés [−5,0 ; −2,0], noms |
| jalon | non (les deux critères) | non (les deux critères) | non (promotions) |

**Les nombres (X1).**
- Développement : F1 structure 1,00 sur 7 nombres.
- Validation : F1 structure 0,91, qualifiée 0,56 à 0,77.
- Le lecteur actuel n'en lisait aucun.
- X1 ne touche pas la sûreté.

**Les options une à une** (`ablation_final_JEU.txt` ; taux de promotion, différence de couverture, en points) :

| option seule | développement : promotions | couverture | validation : promotions | couverture |
|---|---|---|---|---|
| `nombres` | 70,7 % | 0,0 | 82,0 % | 0,0 |
| `portees` | 48,5 % | [−1,8 ; −0,2] | 56,8 % | [−7,4 ; −5,6] |
| `portees,doute` | 44,4 % | [−2,8 ; −0,6] | 54,4 % | [−8,4 ; −6,5] |
| `portees,certain` | 55,6 % | [−0,8 ; 0,0] | 65,6 % | [−1,3 ; −0,6] |
| `citations` | 70,7 % | 0,0 | 81,2 % | [−0,9 ; −0,1] |
| `modalites` | 64,6 % | [−0,2 ; 0,0] | 77,4 % | [−0,9 ; −0,4] |
| `negations` | 69,7 % | 0,0 | 81,6 % | 0,0 |

- **Les portées (X2)** font l'essentiel de la baisse des promotions, et l'essentiel de la perte de couverture.
- **Les modalités (X3)** baissent les promotions de 4 à 6 points pour moins d'un point de couverture.
- **Les citations et les négations** ne changent presque rien. Les négations corrigent cependant la seule faute de
  sûreté de l'expérience croisée (§ 5).

## 4. Pourquoi le jalon n'est pas atteint : le diagnostic

Ce diagnostic a été fait sur la validation, après la décision, et il n'a servi à régler aucune règle de A ni de C. Il
porte sur chaque assertion que A rend non admissible alors que le lecteur actuel la laissait admissible :
- juste, si la référence ne l'admet pas non plus ;
- fausse, si la référence l'admet (une rétrogradation) ;
- sans correspondante.

Le décompte est dans `decisions_validation_m1_A7.txt` (`outils/graphes/decisions_qualificatifs.py`).

| décision | justes | fausses | sans correspondante |
|---|---|---|---|
| `oeuvre` | 434 | 298 | 74 |
| `histoire` | 95 | 1 | 0 |
| `non_ancre` | 44 | 2 | 9 |
| `non_affirme` | 83 | 15 | 30 |
| énonciateur cité | 15 | 14 | 2 |
| alternative | 11 | 2 | 1 |

**Les fausses décisions `oeuvre` viennent de la polysémie.** Les têtes en cause : figure (44), scene / scène (43),
fond (14), plan (11), field (10), foreground (8), background (7), arrangement (7). Chacune n'est une création ou une
représentation que dans un de ses sens. La règle, qui accepte un lien seulement possible, les prend pour l'œuvre.
C'est la raison de la version S (`certain`) : l'œuvre seulement par un lien certain dans K, comme D30 le demande au
noyau.
- **S garde la couverture**, mais perd les vrais cas polysémiques (« the image », « the picture » : seulement
  possibles).
- **S a été définie après la lecture de ce diagnostic.** Elle n'est donc pas une version décidée sur la validation :
  il faudrait un jeu nouveau pour la qualifier.

**Les pertes sur les propriétés qualifiées** viennent de leur portée. Une propriété prend la portée de son entité, comme
dans le lecteur actuel pour les supports et les matériaux. La référence l'écrit le plus souvent sans qualificatif
(`represente`) quand l'entité est l'œuvre.

**Les pertes sur les noms qualifiés** (−3,5 points, [−7,4 ; −0,9]) viennent de deux options à la fois :
- les citations : 79,5 → 77,3 ;
- les modalités : → 78,2.

Seule, aucune n'a un intervalle qui exclut zéro. La citation donne aussi sa source aux noms propres qui en dépendent, et
la référence ne le fait pas toujours.

**Ce qui reste sous le jalon.** Les promotions restantes de A en validation (`detail_validation_m1_A7.json`) sont :

| motif | promotions |
|---|---|
| `non_ancre` | 486 |
| `oeuvre` | 250 |
| `non_affirme` | 153 |
| `neg` | 104 |
| `histoire` | 62 |
| `titre` | 60 |
| `source` | 51 |
| cité | 38 |

Elles se répartissent ainsi :
- les phrases de commentaire, sans tête qui les signale (« décrire », « belong », « relever », « tradition »,
  « interest ») ;
- le texte qui accompagne l'œuvre (« légende », « caption » : l'option `doute` les prend, au prix de la
  couverture) ;
- des matériaux absents de la liste du lecteur (« bois », « bronze ») ;
- les dates (« siècle ») ;
- les entités du titre (X3 ne lit pas le titre).

Le développement en contient trop peu pour mettre au point davantage sans régler sur la validation.

## 5. L'effet sur l'expérience croisée

`outils/croise/croiser.pl` a été relancé avec le graphe des versions A et S à la place du lecteur (conditions
`lecteur_compilee` et `lecteur_reference`, les deux jeux). Résultats :
- **47G3355, variante de négation, n'est plus établissable :** `etablie` / `etablissable` devient `ecartee` /
  `suffisante_ecartee`. C'était la seule faute de sûreté de l'expérience croisée ; le texte dit « not of the
  upholstering itself ».
- **Aucun autre statut ne change,** ni pour les positifs, ni pour les négatifs, ni pour les variantes.
  - Le seul négatif établi reste 44G83, sous hypothèse : c'est l'erreur de la fiche (`docs/EXPERIENCE_CROISEE.md`).
  - Les positifs établis sont les mêmes : la lecture des qualificatifs ne change pas le plafond de rappel.

## 6. Le temps, et le contrôle de la lecture complète

**Le contrôle.** Les lectures complètes par `lire.pl` (Stanza) des versions A et S donnent exactement les mêmes faits
que `relire.pl` : 0 différence sur 120 et 204 textes, pour chaque version (`controle_JEU_V.txt`). Les tableaux du § 3
valent donc pour le lecteur complet.

**Le temps.**
- **Les règles ne coûtent rien de mesurable.** Relire la validation (204 textes, chargement de la base compris) prend
  76,7 s sans option et 75,5 s avec la version A.
- **L'analyse Stanza domine.** Une lecture complète prend 4 à 5 minutes par jeu seule sur la machine, 13 à 20 minutes
  avec quatre lectures en parallèle (`lire_JEU_V.log`).

## 7. Limites

- **Peu de fiches :** 40 par jeu. Le développement n'a que 99 assertions non admissibles appariées, d'où ses intervalles
  larges.
- **La référence est un accord entre agents**, sans validation humaine ; ses conventions (la portée d'une propriété,
  `figure`, `scene`) sont elles-mêmes provisoires.
- **Les lexiques courts** (praticiens, mots de l'objet, discours sur l'œuvre, style) sont tirés du guide ; chaque entrée
  est commentée dans le code. Aucun mot n'est propre à une notation Iconclass.
- **La désambiguïsation lexicale** (X7) est ce qui permettrait de prendre « image » ou « picture » au bon sens sans
  prendre « figure » ou « scene » : le jalon de X2 en dépend.

## 8. Les commandes

Les sorties sont dans `/home/user/donnees/surete_lecteur/` (hors dépôt). Pour une version V d'options O, et chaque JEU :

```bash
OEDIPAMAAS_ANALYSEUR=stanza OEDIPAMAAS_SURETE=O swipl outils/graphes/lire.pl BASE D/JEU/textes.json lecteur_JEU_V.json 5
```

```bash
OEDIPAMAAS_SURETE=O swipl outils/graphes/relire.pl BASE B/lecteur_JEU.json relu_JEU_V.json
```

```bash
python outils/graphes/apparier.py B/reference_JEU.json B/lecteur_JEU.json relu_JEU_V.json --json apparie_JEU_V.json
```

```bash
swipl outils/croise/croiser.pl BASE relu_JEU_V.json B/faits_reference_JEU.json reference_d30/compilees_JEU.json \
  D/JEU/requetes_reference.json D/JEU/fiches.json croise_JEU_V.json
```

Ici, D est le dossier des jeux, B celui du banc (`banc_graphes/`) ; `relire.pl` évite Stanza pour la mise au point.
