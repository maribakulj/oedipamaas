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
- **Ce que D30 dit exactement** (`docs/NOYAU.md`, § 2), et que les cas appliquent tous de la même façon :
  - **un mot de la définition est un type lemme,** comme le compilateur le produit, sauf si la définition donne une
    clé de sens. Ce n'est pas un sens choisi ;
  - **un lien positif** va d'un mot du **texte** vers ce type. Il est **certain** si **chacun des sens du mot du texte**
    atteint le type, par hyperonymie et instance, puis par la lexicalisation vers le lemme de la définition. Sinon, il
    ne fonde qu'une hypothèse de sens. En particulier, **le même lemme des deux côtés donne un lien certain**, car
    chaque sens se lexicalise vers son lemme ;
  - **une négation** du texte est **certaine** si chaque sens du type demandé est inclus dans chaque sens du mot nié,
    par la seule inclusion, sans lexicalisation. Sinon, elle n'est que possible : elle ne réfute rien ;
  - **pour un mot français,** les sens sont ceux de WOLF (`outils/bancs/sens_fr.py`), non ceux du mot anglais
    correspondant ;
  - **ce n'est pas le pivot seul :** la règle vaut pour chaque mot dont un atome de la définition dépend.
  - **les rôles et les relations ne passent pas par K :** un rôle (agent, patient, thème…) et une relation spatiale,
    méréologique ou temporelle (« au-dessus de », « à droite de », « pendant que », « de » de partie) sont des
    **concepts du langage d'assertions**, que la lecture produit à partir de la préposition ou de la construction, en
    français comme en anglais. Ils ne sont pas soumis à la règle des sens de K. Une préposition **polysémique** (le
    « de » de partie, de possession, de matière, de représentation) donne plusieurs lectures. Si l'atome de la
    définition dépend de laquelle, c'est une hypothèse `sens`, avec une `decision_ouverte`. C'est le phénomène
    `preposition_polysemique`, non un défaut de K. Le cadre de référence de « à droite » et « à gauche » reste une
    question ouverte.

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
`outils/bancs/sens.py`, qui ne lit que WordNet, et les sens d'un mot français dans WOLF par `outils/bancs/sens_fr.py`
(l'Open Multilingual Wordnet 1.4, `wn-data-fra.tab`), qui ne lit que WordNet et WOLF. La polysémie d'un mot français
est celle de WOLF, non celle du mot anglais correspondant : « couronne » y a, entre autres, le sens de Stan Laurel.

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

## 8. L'état du côté développement, le 28/11 (à valider par la propriétaire)

**Les cas.** 216 cas de base (24 par famille) et 1 286 variantes. Ils sont sur la branche `donnees/banc-graphes`, dans
`bancs_phase1/`, avec leurs questions, les trois relectures, les révisions, la couverture (`dev/COUVERTURE.md`) et la
version 1 d'avant relecture. Le validateur passe sur l'ensemble, quotas compris.

**La couverture.** Les 112 constructions de développement sont toutes employées, et chacune comme phénomène principal.
Les 36 paires de familles sont toutes composées. Les cas sont écrits pour moitié en français, pour moitié en anglais.

**Le chemin suivi :**
1. la rédaction ;
2. trois relectures indépendantes : 111 lignes de désaccord, dont 54 de sûreté ;
3. une révision de chaque famille, où chaque désaccord est corrigé ou contesté par écrit ;
4. une harmonisation selon le § 4.1.

**Les statuts des cas de base :**

| statut | version 1 | après harmonisation |
|---|---|---|
| `etablie` | 79 | 29 |
| `etablie_sous_hypotheses` | 19 | 67 |
| `ecartee` | 27 | 5 |
| `non_certifiee` | 4 | 3 |
| `inconnue` | 87 | 112 |

Les `decision_ouverte` passent de 43 à 204.

**Ce que les bancs montrent déjà :**
- **sous D30 à la lettre, avec WOLF, le français ne donne presque aucun lien certain.** 1 cas de base français sur 108
  est `etablie`, contre 28 sur 108 en anglais ;
- sous l'option `sens_fixe_par_le_contexte`, les cas et variantes `etablie` passent de 177 à 251, et les `ecartee` de
  38 à 65.

**Les décisions à prendre** sont dans `docs/DECISIONS_PHASE1.md` : 40 décisions sémantiques et les questions de
méthode des bancs. Parmi ces dernières :
- les textes et les définitions que des rédacteurs ont adaptés aux trous de WOLF ;
- la relation « traduction : même statut ».

**Ce qui n'est pas fait :**
- le jugement d'un échantillon par la propriétaire (D23) ;
- les cas de qualification, qu'écrit une autre session ;
- le passage du moteur actuel sur le banc, qui donnera le point de départ (§ 7).

## 9. La version 3 des bancs (lancée le 28/11 sur la décision de la propriétaire ; les bancs ne sont pas qualifiés)

**Les décisions de la propriétaire** (28/11) qui la fondent :
- les bancs ne sont pas encore des références définitives ;
- trois niveaux de statut ;
- la supervaluation sur les interprétations contextuellement admissibles ;
- les définitions typées par des concepts ;
- les textes d'origine rétablis ;
- des incompatibilités attestées et indexées ;
- la satisfaction dans un contexte emboîté ;
- une représentation formelle et un K formel ;
- la traduction qui garde le statut de référence ;
- les décisions regroupées en principes.

Les principes sont dans `docs/INTERPRETATIONS_ADMISSIBLES.md`, la notation dans `docs/NOTATION_REFERENCE.md`.

### 9.1 Ce qui est fait

- **Les textes et définitions d'origine sont rétablis** dans les neuf familles, là où les rédacteurs les avaient
  adaptés aux lacunes de WOLF ou de WordNet. Chaque élément rétabli est listé dans le fichier `.revision.md` de sa
  famille.
- **Les statuts relatifs à K0-d30 sont recalculés** sur les textes rétablis. Ce sont les statuts démontrables sous le K
  du 28/11 : WordNet et WOLF tels quels, tous leurs sens. L'état est gardé dans
  `/home/user/donnees/bancs_phase1/v2_k0_d30_retabli/`.
- **Rien n'est substitué :** la version 1, d'avant relecture, et les jugements relatifs à D30 sont tous gardés.
- **Le validateur contrôle les exigences du protocole** (`--exigences`) :
  - les variantes et les traductions (langue déclarée, même statut de référence) ;
  - les sortes ;
  - la couverture des constructions et des paires ;
  - la cohérence des décisions ouvertes.

  L'exigence d'une variante de statut différent porte sur le statut de référence dès qu'un cas en a un.

### 9.2 Le schéma 3 d'un cas

| champ | niveau | contenu |
|---|---|---|
| `statut_reference`, `hypotheses_reference`, `justification_reference` | (a) | le jugement sur la signification, par supervaluation sur les interprétations admissibles ; ni WordNet, ni WOLF, ni le noyau |
| `statut_attendu` (et à terme une table par K nommé) | (b) | le statut démontrable relativement à K0-d30, conservé tel quel |
| `dependances` | (a) et (b) | les dimensions dont le statut dépend (sens, structure, coréférence, portée, pluriel, cadre, ancrage, contexte, identité, forme du libellé, entrée de K), avec le statut par option ; elles remplacent la `decision_ouverte` à question unique |
| `representation_reference`, `connaissances_formelles` | — | la notation de référence et le K formel, quand les constructions sont spécifiées |
| `historique` | — | les statuts des versions précédentes (v1, K0-d30), jamais effacés |

La `sorte` suit l'intention du cas, donc le niveau (a), et jamais la seule couverture de K.

### 9.3 La procédure du jugement de référence (a)

1. **Deux annotateurs indépendants,** qui n'ont écrit ni relu le cas, jugent le statut de référence de chaque cas et de
   chaque variante. Ils lisent la description et la définition. Ils ne voient pas les statuts relatifs à K, et
   n'ouvrent ni WordNet ni WOLF.
2. **Chaque jugement donne :**
   - le statut ;
   - les points d'ambiguïté que le sens laisse ouverts, et les valeurs admissibles ;
   - les dépendances ;
   - une justification selon les principes.
3. **Un adjudicateur liste les désaccords.** Ceux qui tiennent à un principe non tranché deviennent des dépendances. Les
   autres sont tranchés par écrit, avec leur raison.
4. **La propriétaire juge un échantillon** (D23), stratifié par famille et par écart entre (a) et (b).
5. **Le statut (b) est contrôlé contre (a).** Un (b) plus fort que (a) signale une erreur de K ou de représentation
   (`docs/INTERPRETATIONS_ADMISSIBLES.md`, § 2.6), et le cas est revu.

### 9.4 La mesure du moteur actuel, point de départ

1. **Les textes** passent par le lecteur actuel.
2. **Les définitions** sont compilées comme des libellés de scène, par un adaptateur de mesure, sans changer le
   compilateur.
3. **Le noyau** évalue chaque paire ; c'est le niveau (c).
4. **Les comptes** se font par famille, sorte et langue :
   - les écarts (c) / (b) et (c) / (a) ;
   - les erreurs de sûreté : une affirmation de (c) absente de (b) ou de (a) ;
   - les relations métamorphiques, sur le niveau (a).

**Aucune référence n'est modifiée d'après ces résultats.**

### 9.5 L'état de la version 3, le 28/11

**Les bancs ne sont pas qualifiés.** Les références (a) sont adjugées par des agents d'un même modèle ; leur accord
n'est pas une validation humaine (D23). L'échantillon de la propriétaire reste à faire.

**Le jugement de référence (a)** suit la procédure du § 9.3 et le guide `docs/ANNOTATION_REFERENCE.md`.
- **Deux annotations indépendantes par famille,** sur des cas sans statut (`v3/a_annoter/`), sans K ni sortie du moteur.
  Toutes sont gardées (`v3/annotations/<famille>.{A,B}.json`), avec leurs comparaisons (`v3/comparaisons/`).

  | famille | accord sur le statut | kappa |
  |---|---|---|
  | evenements_etats | 0,94 | 0,92 |
  | compositionnalite | 0,92 | 0,89 |
  | structures_argumentales | 0,92 | 0,89 |
  | reference_quantification | 0,93 | 0,90 |
  | espace_partie_temps | 0,92 | 0,90 |
  | modalite_negation_contextes | 0,89 | 0,85 |
  | niveaux_representation | 0,69 | 0,60 |
  | definitions_classification | 0,84 | 0,79 |
  | phenomenes_iconographiques | 0,89 | 0,86 |

- **Une limite de l'indépendance, dans le groupe 2** (reference_quantification, espace_partie_temps,
  modalite_negation_contextes) : des annotateurs A et B ont partagé des dossiers de brouillon. Aucun signe de copie
  n'a été trouvé, l'accord y est comparable à celui du groupe 1, et 9 justifications identiques sur 503 éléments. Les
  trois fichiers `.adjudication.md` du groupe le disent. Refaire l'annotation B du groupe dans un dossier isolé est une
  décision à prendre.
- **L'adjudication** tranche par écrit ou fait d'un désaccord une dépendance nommée, en gardant le statut le plus prudent
  sur les deux axes. 130 éléments sur 1 494 ont des dépendances. Les plus fréquentes : le symbole non dit (20), le seuil
  de l'identification iconographique (16 ; 7 de plus pour le lien titre-image), la situation unique (10), l'asymétrie
  d'une relation (8, plus 5 inversions de rôles), la convention de l'imminent (8, plus 10 frontières lexicales),
  le contraire lexical (6), l'unicité de l'article défini (5).
- **La règle par contexte** (guide, § 7.1, corrigée) a changé 64 statuts adjugés : 38 `inconnue` → `etablie`, 8 →
  `etablie_sous_hypotheses`, 5 → `non_certifiee`, 1 → `ecartee`, 1 → `ecartee_sous_hypotheses`, 6 `ecartee` et 5
  `etablie_sous_hypotheses` → `par_contexte`. L'ancien statut est gardé dans `historique.statut_contexte_principal`.

**Les cas au schéma 3** (`v3/cas/`, `outils/bancs/migrer_v3.py`, `reporter_reference.py`) portent les trois niveaux.
Chaque statut relatif porte son K nommé (`K0-d30` : les connaissances, le langage, la représentation, la sémantique et
la date, `v3/cas/K.json`). K0-d30 est une convention historique, non la sémantique cible.

**Les exigences du protocole** (`valider_cas.py --exigences`), jugées sur le statut sémantique et son contexte : 9
manquent, contre 69 sur K0-d30. Ce sont de vrais manques (co-012, dc-006, dc-022, mn-006, pi-005, rq-009, rq-017,
rq-020, sa-004) : la seule variante qui y change le résultat est un changement de participant ou une composition, qui ne
compte pas comme variation différenciante. Aucune variante n'a été ajoutée pour les remplir ; elles restent signalées.

**Les trois niveaux comparés** (`outils/bancs/comparer_niveaux.py`, `docs/mesures/NIVEAUX_BANCS.md`), sur 1 494
éléments, par axe (déf. 11), les axes comptés à part :

| | égal | plus faible (positif / négatif) | plus fort (positif / négatif) |
|---|---|---|---|
| (b) contre (a) | 499 | 727 / 316 | 6 / 1 |
| (c) contre (a) | 301 | 900 / 346 | 10 / 0 |
| (c) contre (b) | 1 056 | 393 / 30 | 20 / 0 |

**Les 7 éléments où (b) est plus fort que (a), examinés un par un.** Aucun ne conduit à réviser (a) ; aucun n'est
corrigé dans (b), qui reste l'état historique.

| élément | (a) | (b) | la cause |
|---|---|---|---|
| ee-008 #0 (« is preparing to sacrifice »), sa-007 #4 (« s'apprête à peindre »), ep-016 #2 (« bends to kiss ») | etablie_sous_hypotheses | etablie | la convention de l'imminent : (a) garde un point d'ancrage (en cours ou imminent) dont une valeur est `N`, `V` sous la convention ; K0-d30 lisait la phase préparatoire comme en cours sans ce point. L'écart se ferme ou se confirme avec la décision sur l'imminent |
| ee-013 #4 (« three travellers … » contre « two travellers ») | divergent | ecartee | la représentation de (b) lit le nombre du libellé comme exact ; (a) garde les deux lectures (au moins deux, `V` sous l'abduction du but ; exactement deux, `F`). (b) est plus fort sur l'axe négatif |
| ee-021 #3 (« selon le catalogue, elle prie ; en réalité, elle ne prie pas ») | ecartee | non_certifiee | un effet du statut synthétique, non une erreur de K : le profil de (a) garde la classe `V` de l'énonciateur cité, mais la négation de l'auteur décide du statut (déf. 10). (b) ne voit pas la négation de l'auteur. C'est un argument de plus pour mesurer la sûreté sur les profils |
| ep-010 #5 (« holds … a closed book in his left [hand]. In his left hand St Peter holds no book ») | contradictoire | etablie_sous_hypotheses | (b) perd l'appui négatif de la phrase niée : la dérivation positive est valide, sa certification ne l'est pas (le contre-exemple du lion ailé, étude 1.1, § 2.6) |
| rq-020 #3 (« pointing to a lamb ») contre « the Lamb » | etablie_sous_hypotheses | etablie | la lecture D30 de la définition : le mot « Lamb » y est l'union des sens de son lemme, qui contient l'agneau ordinaire ; (a) lit le concept (l'Agneau de Dieu) et demande une identification iconographique. C'est ce que la décision 3 remplace par des alternatives (`docs/LANGAGE_REFERENCE.md`, § 5) |

**Les 10 éléments où (c) est plus fort que (a)** sont tous sur l'axe positif et tous des erreurs strictes. Ils sont
analysés dans `docs/mesures/MESURE_INITIALE_BANCS.md`, § 7 : 4 du compilateur réel (rq-014), 4 du lecteur sur le
discours cité ou rapporté (ep-003 #6, ep-016 #6, mn-023 #1, #2), 1 d'un référent conceptuel lu comme figuré (dc-017 #2),
1 d'un ordre d'éventualités ni lu ni compilé (sa-015 #2). Deux accords de statut avec (a) reposent sur une dérivation
fausse (sa-015 #4, rq-010 #1), et 8 conclusions sous hypothèses plus faibles que (a) aussi (ee-023, co-014 #0, co-016).
Un accord de statut n'est pas une preuve correcte : e⁺_der et e⁺_cert restent à mesurer.

**Le langage formel de référence** (`docs/LANGAGE_REFERENCE.md`, `semantique_reference/`) a sa syntaxe abstraite, ses
règles de formation, sa sémantique, un interpréteur indépendant du moteur et un oracle de propriétés
(`tests/test_semantique_reference.py`). Cinq cas réels y sont écrits (ee-002, mn-004, rq-010, co-018 #3, pi-003) ; leur
niveau (a) calculé égale la référence adjugée.

**Les représentations formelles des cas de base** (`v3/formel/`, `docs/mesures/FORMEL_BANCS.md`) ont été écrites par
trois rédacteurs qui n'ont vu ni la référence adjugée, ni K0-d30, ni le moteur, puis recalculées par l'interpréteur et
comparées à la référence (`outils/bancs/comparer_formel.py`).
- 197 cas sont représentés, 18 ne le sont pas (ce qui leur manque est écrit), et 1 n'est pas fait (co-018).
- 168 des 197 ont le même statut et le même contexte que la référence.
- Les écarts tiennent surtout à trois règles :
  - la portée d'une réfutation (L6), 8 cas ;
  - l'attestation des postulats de K\*, 11 cas ;
  - le seuil d'une identification ou d'une abduction, 5 cas.
- Aucun côté n'a été réécrit d'après l'autre. Les variantes restent à représenter.

**Les données** sont dans `/home/user/donnees/bancs_phase1/v3/` et archivées sur la branche `donnees/banc-graphes`
(`bancs_phase1/v3/`).
