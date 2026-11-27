# Les bancs de la phase 1 : le protocole (version 1, 27/11)

**La décision de la propriétaire** (quatrième message, § 7 et 8) : lancer la construction des bancs de la phase 1, avec
neuf familles. Présenter les bancs, leur protocole, leur couverture et les décisions sémantiques restant ouvertes
**avant** de lancer les extensions du moteur.

**Ce que la phase ne fait pas :** aucune règle, aucune extension, aucun réglage. Un banc est écrit d'après une
spécification, et il échoue avant la phase qui le fera passer (`docs/TRAJECTOIRE.md`).

Ce document précise le plan de `docs/QUALIFICATION_SEMANTIQUE.md`, § 2, sans le remplacer.

## 1. Ce qu'est un banc de la phase 1

**Un ensemble de cas de base,** chacun avec ses variantes, par famille.
- Un cas de base est un triplet : une description d'œuvre, une définition, et le statut que la **sémantique cible**
  lui donne.
- La sémantique cible est celle des fondements (`docs/FONDEMENTS_SEMANTIQUES.md`), de l'ontologie des éventualités
  (`docs/ONTOLOGIE_EVENTUALITES.md`) et de la spécification des opérations (`docs/SPECIFICATION_OPERATIONS.md`). Ce
  n'est pas le comportement du moteur actuel.
- **Le statut attendu se lit relativement à K,** et K est écrit dans le cas : les connaissances qu'il suppose, avec leur
  sorte et leur attestation (§ 4). Sans elles, le statut ne serait pas déterminé.

**Les deux côtés.**
- **Le développement** sert à spécifier et à mettre au point.
- **La qualification** sert à mesurer, une fois. Elle est écrite par une autre session, et n'est jamais versée dans le
  dépôt (§ 3.3).

## 2. L'inventaire

`bancs/phase1/inventaire.json` liste, pour chaque famille, ses phénomènes, et pour chaque phénomène ses constructions,
c'est-à-dire les réalisations de surface d'un phénomène. Il liste aussi les **familles lexicales** : les fichiers
lexicographiques de WordNet 3.0.

| famille | phénomènes | constructions |
|---|---|---|
| événements, états, processus, situations | 10 | 30 |
| sémantique compositionnelle | 10 | 28 |
| cadres et structures argumentales | 6 | 17 |
| référence, identité, coréférence, quantification | 6 | 21 |
| relations spatiales, temporelles, causales, méréologiques | 5 | 16 |
| modalités, alternatives, négation, contextes | 7 | 21 |
| niveaux de représentation des descriptions d'œuvres | 5 | 14 |
| définitions conceptuelles, classification | 6 | 10 |
| phénomènes iconographiques | 6 | 17 |
| **total** | **61** | **174** |

Il y a **44 familles lexicales** : tous les fichiers de WordNet sauf `noun.Tops`.

**Les phénomènes iconographiques couverts** (décision de la propriétaire) :
- la narration continue ;
- la juxtaposition d'épisodes ;
- les représentations emboîtées : tableau dans le tableau, miroir, vision figurée, tapisserie ;
- l'événement historique et l'événement figuré ;
- les niveaux de signification : préiconographique, iconographique, iconologique ;
- l'identification des personnages : par le nom, par les attributs, par le contexte narratif, par une inscription ;
- les personnifications, dans la famille des niveaux de représentation.

**Une limite, dite :** l'inventaire est écrit par la session de développement, qui connaît donc les noms des
constructions de qualification. Pour cela, la session de qualification peut ajouter une **troisième strate, « hors
inventaire »** : des constructions qu'elle seule propose, déclarées comme telles. La couverture de l'inventaire est
alors mesurée, et non supposée.

## 3. La répartition, avant tout cas

### 3.1 La méthode

`outils/bancs/repartir.py` fait la répartition. Elle est déterministe pour une graine et un inventaire, et elle écrit
l'empreinte de l'inventaire.
- **Les familles lexicales :** réparties dans chaque partie du discours, environ 70/30. `adv.all`, seul de sa
  catégorie, reste en développement.
- **Les constructions :** réparties dans chaque phénomène, environ 70/30, avec au moins une de chaque côté quand le
  phénomène en a deux ou plus.
- **Les cas de base sont écrits de chaque côté, séparément.** Un cas de qualification n'est jamais une variante, une
  traduction ou une adaptation d'un cas de développement.
- **Les variantes restent du côté de leur cas** (`docs/QUALIFICATION_SEMANTIQUE.md`, § 2.3).

**La règle des cas.**
- **Un cas de développement :** toutes ses constructions, et la famille lexicale de son pivot, sont de développement.
- **Un cas de qualification :** au moins l'une d'elles est de qualification, et de préférence les deux.

### 3.2 Le tirage, fait le 27/11

**La graine :** 20261127.

**Le résultat :**
- les familles lexicales : 31 en développement, 13 en qualification ;
- les constructions : 112 en développement, 62 en qualification.

**C'est le premier tirage, et il est gardé tel quel.** Retirer pour un résultat plus commode serait choisir la
répartition.
- Seul `adv.all` a été ajouté à l'inventaire, avant tout cas. Il avait été oublié, et il est seul de sa catégorie. Les
  répartitions des constructions et des autres familles n'ont pas changé, ce qui a été vérifié.

**Ce que le tirage implique :**
- `adj.ppl` (les adjectifs participiaux) et `noun.state` (les noms d'état) sont en qualification.
  - Les cas d'état de développement passent donc par d'autres pivots : un verbe (`verb.body`, `verb.change`,
    `verb.stative`), un adjectif ordinaire (`adj.all`), un nom d'attribut (`noun.attribute`).
  - La qualification mesurera ainsi la généralisation aux noms d'état et aux participes lexicalisés. Ce n'est pas un
    défaut.
- `noun.animal`, `noun.group`, `noun.communication`, `verb.contact` et `verb.perception` sont aussi en qualification.
  - Les foules, les inscriptions nommées, les gestes de contact et la vision passent par d'autres familles en
    développement.
- **Deux phénomènes n'ont qu'une construction :** `condition_necessaire` et `mots_sans_structure`. Elle est en
  développement. Leur qualification ne peut passer que par une famille lexicale de qualification.

**Une limite, dite :** la famille lexicale porte sur le **pivot** seul, le sens du mot qui porte le phénomène
principal. Les autres mots d'un cas sont libres. C'est un axe grossier, que la séparation par cas de base et par
construction complète.

### 3.3 Ce que reçoit chaque côté

**Les rédacteurs de développement** reçoivent la **vue de développement**, `bancs/phase1/developpement.json`, et non la
répartition entière. Ils reçoivent aussi les documents de fondements et ce protocole.

**La session de qualification,** lancée par la propriétaire, reçoit :
- l'inventaire ;
- `bancs/phase1/repartition.json` ;
- ce protocole et les documents de fondements ;
- jamais les cas de développement.

Elle écrit ses cas hors du dépôt, sur le support du jeu indépendant (`docs/QUALIFICATION_SEMANTIQUE.md`, § 4.1), et
les contrôle avec :

```bash
python3 outils/bancs/valider_cas.py bancs/phase1/inventaire.json bancs/phase1/repartition.json qualification CAS.json --wordnet DICT
```

## 4. La forme d'un cas

Un fichier par famille : une liste de cas de base, en JSON.

| champ | contenu |
|---|---|
| `id` | unique, préfixé par la famille (`ee-007`) |
| `famille` | la famille du phénomène principal |
| `phenomenes` | `[{famille, phenomene, construction}]`, le principal d'abord ; les suivants font la composition |
| `pivot` | `{lemme, cle_de_sens, famille_lexicale}` : le **sens** (une clé de WordNet 3.0) du mot qui porte le phénomène principal ; pour une description française, le sens anglais correspondant |
| `langue` | `fr` ou `en`, la langue de la description |
| `sorte` | `positif`, `negatif`, `indetermine`, `contre_modele` (§ 2.1 du plan) |
| `description` | la description d'une œuvre, de deux à six phrases, dans le style d'une notice ou d'un cartel |
| `definition` | une définition de style Iconclass, en anglais, **inventée** : jamais un libellé réel, jamais une notation |
| `statut_attendu` | `etablie`, `etablie_sous_hypotheses`, `contradictoire`, `non_certifiee`, `ecartee`, `inconnue` (`docs/NOYAU.md`, § 4) |
| `hypotheses_attendues` | si et seulement si `etablie_sous_hypotheses` : `sens`, `equivalence_non_attestee`, `condition_suffisante_non_attestee`, `consequence_conditionnelle`, `connaissance_typique`, `hypothese_interpretative`, `abduction`, `identite`, `relation_inconnue` |
| `connaissances_supposees` | `[{sorte, contenu, attestee, source}]` (`source` exigé si attestée, § 4.1) : ce que K contient pour ce cas, **et rien d'autre**. Les sortes sont celles des fondements (§ 2.7) ; `attestee` dit si une attestation fonde l'entrée |
| `operations_requises` | `lecture`, `canonisation`, `deduction`, `classification`, `abduction`, ou `aucune` |
| `extensions_requises` | les extensions du langage sans lesquelles le statut ne peut pas être atteint (voir la liste du validateur), ou `aucune` |
| `justification` | pourquoi ce statut, avec la section des fondements, de l'ontologie ou de la spécification qui le fixe |
| `variantes` | `[{variation, description, sorte, statut_attendu, hypotheses_attendues}]`, les variations du § 2.2 du plan, la définition et K inchangés |
| `decision_ouverte` | facultatif : `{question, statut_selon_l_option: {option: statut}}`, quand les documents ne fixent pas le statut |
| `graphe_attendu`, `requete_attendue` | facultatifs : quand la représentation est déjà fixée par le langage actuel |


**Les valeurs admises** (les mêmes que celles du validateur) :
- `sorte` : `contre_modele`, `indetermine`, `negatif`, `positif` ;
- `statut_attendu` : `contradictoire`, `ecartee`, `etablie`, `etablie_sous_hypotheses`, `inconnue`, `non_certifiee` ;
- `hypotheses_attendues` : `abduction`, `condition_suffisante_non_attestee`, `connaissance_typique`, `consequence_conditionnelle`, `equivalence_non_attestee`, `hypothese_interpretative`, `identite`, `relation_inconnue`, `sens` ;
- `connaissances_supposees[].sorte` : `condition_necessaire`, `condition_suffisante`, `connaissance_typique`, `consequence_conditionnelle`, `distinction_documentaire`, `equivalence_etablie`, `hypothese_interpretative`, `identite_documentaire`, `implication`, `relation_inconnue` ;
- `operations_requises` : `abduction`, `aucune`, `canonisation`, `classification`, `deduction`, `lecture` ;
- `extensions_requises` : `abduction`, `ancrage_temporel`, `aucune`, `base_de_definitions`, `collection`, `contenu_d_inscription`, `contexte_d_eventualite`, `contexte_emboite`, `etat_reifie`, `evenement_participant`, `identite_entre_situations`, `modificateur_non_intersectif`, `negation_dans_la_requete`, `plusieurs_situations`, `quantification_enoncee`, `referent_conceptuel`, `relation_entre_eventualites`, `situation_referent` ;
- `variantes[].variation` : `ajout_figure_non_liee`, `ajout_negation_non_liee`, `changement_de_modalite`, `changement_de_participant`, `changement_de_portee`, `changement_de_temps`, `composition`, `inversion_des_roles`, `paraphrase`, `traduction`.

**Les principes de rédaction :**
- **le statut se lit sur la définition et K seuls,** jamais sur une connaissance du monde implicite. Ce que le cas
  suppose est écrit dans `connaissances_supposees`. Une connaissance absente de cette liste n'existe pas pour le cas ;
- **une hypothèse de sens** (`sens`) ne figure que si la conclusion dépend d'un choix entre des sens que le texte laisse
  ouverts. Si tous les sens admis conduisent à la même conclusion, la supervaluation l'établit (D30) ;
- **une connaissance non attestée ne fonde pas une déduction.** Une équivalence ou une condition suffisante sans
  attestation donne au mieux `etablie_sous_hypotheses`, et jamais `etablie` (fondements, § 2.7) ;
- **l'absence n'est jamais une preuve négative.** `ecartee` demande un appui négatif dit, une distinction documentaire
  ou une contrainte du texte (D31). Le monde clos est refusé ;
- **une quantification énoncée** (« seul », « tous ») est représentée comme une assertion du texte. Elle n'est jamais
  inférée ;
- **un rôle inversé n'est pas une preuve négative :** son statut est `inconnue` ;
- **le figuré, l'œuvre, l'histoire, la source et le contenu d'une vision** sont des contextes distincts. Ce qui n'est
  pas dans le contexte de la figuration n'établit rien.

**Les variantes, pour chaque cas de base :**
- au moins cinq variantes, d'au moins quatre variations différentes ;
- dont une **traduction** ;
- et au moins une variante dont le statut **diffère** de celui du cas de base : un changement de portée, de modalité ou
  de temps, ou une inversion des rôles.

### 4.1 Les précisions après la première relecture (27/11, provisoires jusqu'à la décision de la propriétaire)

Trois relectures indépendantes ont trouvé 111 lignes de désaccord, dont 54 de sûreté, sur la version 1 des cas (gardée
telle quelle : `v1_avant_relecture/`). Trois causes reviennent. Elles demandent une règle, non des corrections au cas
par cas. Les règles ci-dessous sont **provisoires** : ce sont des décisions de la propriétaire (`docs/DECISIONS_PHASE1.md`), et chacune garde,
par une `decision_ouverte`, le statut selon l'autre option.

**1. Ce que contient K pour un cas.** « Les connaissances supposées, et rien d'autre » était trop strict pour être
appliqué : presque tous les cas `etablie` reposent sur des inclusions de WordNet non écrites. La règle devient :
- **implicites :** les relations de WordNet 3.0 dont le moteur se sert déjà, l'hyperonymie et l'instance (`@`, `@i`)
  et la méronymie de partie (`%p`), entre **sens** ; le passage d'un mot français à un sens par WOLF ;
- **à écrire, avec leur source :** tout le reste. Cela comprend les alias de noms entre langues (« l'Enfant » et
  « the Christ Child »), les équivalences entre mots, les connaissances typiques, les conditions et les restrictions de
  sélection ;
- **ne valent pas attestation :** une glose seule (FONDEMENTS § 2.7 : c'est une relation inconnue), une antonymie
  (elle ne donne pas d'appui négatif : NOYAU § 1.1), une hypothèse de rédaction ;
- **le champ `source`** est exigé pour toute connaissance `attestee: true` : la ressource et l'élément (une clé de sens
  et un pointeur, une entrée nommée). Le validateur le contrôle.

**2. Le régime des sens.** NOYAU § 2 (D30) prend tous les sens que K donne au mot. Le protocole parlait des sens « que le
texte laisse ouverts », c'est-à-dire d'une désambiguïsation par le contexte qui n'est pas spécifiée (X7).
- **Quand le statut dépend de ce choix,** le cas porte une `decision_ouverte` avec deux options : `tous_les_sens`
  (D30 sans désambiguïsation) et `sens_fixe_par_le_contexte`.
- **Le statut retenu est le plus prudent.** D'ordinaire, `etablie_sous_hypotheses` avec `sens` pour un lien positif,
  et `inconnue` pour une négation.

**3. Les incompatibilités.** Aucune sorte de connaissance ne dit que deux types s'excluent (debout et assis, éveillé et
endormi), et aucune antonymie n'en tient lieu. Un contre-modèle qui en dépend reste `inconnue` ; une `decision_ouverte`
donne le statut si une sorte « incompatibilité attestée » était admise.

**Les autres corrections du schéma :**
- `extensions_requises` et `decision_ouverte` sont admis aussi sur une variante, quand elle demande plus que son cas
  ou que son statut dépend d'une autre décision ;
- l'extension `contenu_d_inscription` est ajoutée : ce que dit le texte d'une inscription. Sa réalisation est différée
  (`docs/TRAJECTOIRE.md`), mais un cas peut en dépendre ;
- entre `non_certifiee` et `inconnue`, le plus prudent est `inconnue` : `non_certifiee` dit qu'une substitution vraie
  existe.

## 5. La composition et la couverture

**Les quotas** (décision de la propriétaire), par famille principale :
- au moins **40 %** des cas de base combinent deux phénomènes ou plus, dont un d'une autre famille ;
- au moins **10 %** en combinent trois ou plus.

**La matrice famille × famille,** soit 36 paires, est couverte entièrement. Chaque famille compose avec chacune des
huit autres au moins une fois, donc chaque paire au moins deux fois.

**La couverture de l'inventaire :** chaque construction du côté est employée au moins une fois, comme phénomène
principal ou composé.

**Les sortes, par famille :**
- au moins 30 % de positifs ;
- au moins 20 % de négatifs ou de contre-modèles ;
- au moins 15 % d'indéterminés.

## 6. Les rédacteurs, et ce qu'ils ne voient pas

**Les rédacteurs de développement** sont des agents de la session de développement. Ils ne voient :
- ni le code du moteur, du lecteur ou du compilateur ;
- ni aucune sortie du système ;
- ni les anciens jeux et bancs ;
- ni les données d'Iconclass ;
- ni le jeu indépendant.

Ils lisent les documents de fondements, ce protocole et la vue de développement. Ils peuvent consulter WordNet par
`outils/bancs/sens.py`, qui ne lit que WordNet.

**La relecture :**
- chaque fichier est contrôlé par `outils/bancs/valider_cas.py`, pour la forme, le côté, les clés de sens et les
  quotas ;
- puis un autre agent relit les statuts attendus contre les documents. Les désaccords sont listés, non tranchés en
  silence ;
- **la propriétaire juge un échantillon** (D23). L'accord entre agents n'est pas une validation humaine.

## 7. Ce que les bancs serviront à mesurer, et comment

- **Avant toute phase,** le moteur actuel est passé sur le banc de développement, une fois, pour établir le point de
  départ. C'est un constat, non un objectif.
- **Chaque phase** de la trajectoire désigne les cas qu'elle doit faire passer : ceux dont `operations_requises` et
  `extensions_requises` sont dans son périmètre. Elle ne doit faire régresser aucun autre cas, ni aucune sûreté.
- **Les relations métamorphiques** entre un cas et ses variantes sont mesurées pour elles-mêmes : une invariance violée
  est une erreur, même si les deux statuts sont faux de la même manière.
- **Une erreur de sûreté** est un statut plus fort que l'attendu : `etablie` pour `etablie_sous_hypotheses`, `inconnue`
  ou `ecartee`, ou `ecartee` pour `inconnue`. Elle est comptée à part, et elle prime sur la couverture.
- **La qualification,** une fois, après la validation des bancs par la propriétaire.
