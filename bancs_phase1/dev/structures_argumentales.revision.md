# Révision de structures_argumentales après la relecture A et le § 4.1 du protocole

Je suis parti du fichier tel qu'il était, `extensions_requises` de sa-015 compris, puisque ce champ avait déjà été
corrigé hors de ma rédaction. Les numéros de variante (#n) suivent la relecture : ils commencent à 1. Les WordNet cités
ont été vérifiés avec `sens.py` et dans `data.verb`.

## 1. Les désaccords de la relecture A

| désaccord | décision | ce qui a changé, ou pourquoi |
|---|---|---|
| sa-001, #1, #2, #6 (hand ⊑ give, sûreté) | **corrigé** | L'inclusion est fausse : hand%2:40:00 est dans le synset 02230772 {pass, hand, reach, pass_on, turn_over, give}, dont l'hyperonyme est 02220461 (transfer), comme celui de give%2:40:00. L'entrée de K est retirée et la définition devient « a saint handing a book to a deacon ». « hands » a deux sens (hand%2:40:00 et hand%2:38:00, « guide ») : le cas et les variantes #1, #2, #6 passent à `etablie_sous_hypotheses` [sens], avec une `decision_ouverte` (`tous_les_sens` / `sens_fixe_par_le_contexte`). |
| sa-024, #1, #3, #6 (condition nécessaire non fondée, sûreté) | **corrigé** | La condition « écrire avec P ⇒ tenir P » est une hypothèse de rédaction : elle passe à `attestee: false`. Une condition non attestée ne réfute rien, la négation de hold (36 sens) n'est que possible, et S § 2 ne permet pas clairement la contraposition depuis une prémisse niée. Le cas et #1, #3, #6 passent à `inconnue`, avec une `decision_ouverte` (l'option `sens_fixe_et_condition_necessaire_attestee` donne `ecartee`). `operations_requises` devient `lecture`. La variante affirmée #2 passe à `etablie_sous_hypotheses` [sens] (write a 10 sens). |
| sa-004#2 (« vers l'Égypte » lu comme « into Egypt », sûreté) | **corrigé** | La description dit maintenant « fuit la Judée pour gagner l'Égypte », une destination et non une direction. Le statut passe à `etablie_sous_hypotheses` [identite] : l'alias la Sainte Famille / the Holy Family n'est pas attestable, holy_family étant absent de WordNet 3.0. |
| sa-019#2 (sit ⇔ seated sur une glose, sûreté) | **corrigé** | L'entrée devient une `relation_inconnue`, `attestee: false`. La variante passe à `etablie_sous_hypotheses` [relation_inconnue, sens], car sit a 10 sens. La justification dit que l'invariance de la paraphrase est rompue faute d'une équivalence attestée. |
| sa-022#2 (dormir ⇔ endormi sur une glose, sûreté) | **corrigé** | L'entrée devient une `relation_inconnue`, `attestee: false`. La négation ne se propage plus : la variante #2 « ne dort pas » passe de `ecartee` à `inconnue`. |
| sa-007#5 (« s'apprête à peindre », trop faible) | **corrigé** | O § 1.2 range « s'apprêter à » dans la phase préparatoire, donc dans l'en cours. La variante prend le statut du cas, `etablie_sous_hypotheses` [sens] (et non `etablie`, puisque paint est polysémique). Sa sorte devient `positif`. |
| sa-016#4 (« s'apprête à relever », trop faible) | **corrigé** | Même raison. La variante passe à `etablie_sous_hypotheses` [sens], sorte `positif`. |
| D1, sa-002 et #1, #2, #6 ; sa-010#2 ; sa-011#3 ; sa-012 et #1, #3, #5, #6 ; sa-017#3 ; sa-018 et #1, #3, #5 (négations de mots polysémiques) | **corrigé** | Le § 4.1.2 est appliqué : ces cas et variantes passent de `ecartee` à `inconnue`. sa-002, sa-012 et sa-018 portent une `decision_ouverte` (`tous_les_sens` : inconnue ; `sens_fixe_par_le_contexte` : ecartee). Pour sa-010 et sa-011, la question de sens est jointe à la `decision_ouverte` de rattachement déjà présente. |
| D1, sa-004#3 | **contesté** | flee n'a qu'un sens dans WordNet 3.0 (flee%2:38:00, vérifié avec `sens.py`). Par N § 2 (D30), la négation est donc certaine : chaque nœud du type demandé est inclus dans l'unique sens du mot nié. Le statut `ecartee` est gardé. La conjonction est fausse par l'atome d'événement, quel que soit l'alias non attesté du nom de groupe (N § 4.2). Ce qui n'est pas vérifiable : la polysémie de « fuir » dans WOLF. J'ai pris pour règle d'employer la polysémie du lemme anglais correspondant (voir le § 3). Pour la qualité, la description a été réécrite : la négation est justifiée par un pendant, une « Fuite en Égypte » du même atelier. |
| sa-022, la `decision_ouverte` sur l'antonymie (mal posée) | **contesté** | Le § 4.1.3 (nouveau) exige précisément pour une incompatibilité une `decision_ouverte` qui donne le statut si une sorte « incompatibilité attestée » était admise. Elle est gardée et reformulée : l'option `sans_incompatibilite` (`inconnue`, retenue) et l'option `incompatibilite_attestee_admise` (`ecartee`). Sur le fond, la relecture a raison, et la question le dit : les documents actuels fixent `inconnue`. |
| sa-004#3 (qualité, formule « Cette fois ») | **corrigé** | La description a été réécrite (voir ci-dessus). |
| sa-015 (qualité, justification et « the feet ») | **corrigé** | La justification cite maintenant `relation_entre_eventualites`, et le champ ne porte plus que cette extension. La description et les variantes disent « from his feet » et « de ses pieds ». La variante de temps porte `relation_entre_eventualites`, la variante emboîtée `contexte_emboite`. |
| Question 8 de la relecture, sa-006 (inventaire ou titre) | **corrigé** | La description est réécrite : « According to the Medici inventory of 1492, Venus was shown there emerging from the sea ». L'inventaire est un énonciateur cité qui décrit le figuré, et non un titre entre guillemets. Le statut `non_certifiee` est gardé, de même dans les variantes #1, #4, #5, #6. |
| Question 11 de la relecture (emboîtement, sa-007#4, sa-015#5) | **corrigé** | Les justifications renvoient à la `decision_ouverte` d'ee-023, et les variantes portent `extensions_requises: ["contexte_emboite"]`. |
| Question 12 de la relecture (qui ferme un sens : sa-001, sa-018) | **corrigé** | Voir sa-001 et D1 : les deux cas ont une `decision_ouverte` et prennent le statut le plus prudent. |

## 2. Les autres changements faits par le § 4.1

**Le régime des sens (§ 4.1.2), appliqué au mot pivot de chaque cas.** Quand le mot qui porte le phénomène principal est
polysémique et qu'un seul de ses sens atteint le sens que demande la définition, le statut positif devient
`etablie_sous_hypotheses` [sens], avec une `decision_ouverte` dans le cas de base.
- **Les cas de base :**
  - sa-003 (ascend, 8 sens) ;
  - sa-005 (descend, 4) ;
  - sa-007 (paint, 4) ;
  - sa-013 (raise, 27) ;
  - sa-015 (lower, 5) ;
  - sa-023 (present, 13).
- **Leurs variantes positives :** traduction, paraphrase, ajout.
- **Les variantes positives d'autres cas :**
  - sa-002#3 (give) ;
  - sa-006#2 (emerge, 5) ;
  - sa-011#2 (pour, 6) ;
  - sa-012#2 (offer, 13) ;
  - sa-014#2 (anoint, 2) ;
  - sa-018#2 (wear, 9) ;
  - sa-020#2 (standing, 6) ;
  - sa-022#3 (asleep, 3, dont « dead ») ;
  - sa-024#2 (write, 10).
- **sa-017** ajoute `sens` à `connaissance_typique`, sans `decision_ouverte` : le statut ne dépend pas de l'option.
- **sa-016** reste `etablie_sous_hypotheses` [sens], sans `decision_ouverte` : le contexte ne ferme pas le sens, donc les deux options donnent le même statut.
- **Restent `etablie`,** parce que leur pivot n'a qu'un sens dans WordNet 3.0 :
  - sa-008#2 (slay) ;
  - sa-009 (weep) ;
  - sa-019 (seated) ;
  - sa-021 (recumbent).

**Les alias de noms entre langues (§ 4.1.1),** écrits en `identite_documentaire` :
- **attestés,** avec la clé du synset d'instance de WordNet 3.0 et le rattachement de la forme française par WOLF :
  - Élie / Elijah (sa-003) ;
  - Vénus / Venus (sa-006) ;
  - saint Luc / Saint Luke et la Vierge / the Virgin (sa-007) ;
  - Marie Madeleine / Mary Magdalene (sa-009) ;
  - Judith, et Holopherne / Holofernes (sa-013) ;
  - le Christ / Christ (sa-015, sa-016, sa-018) ;
  - la Vierge (sa-019) ;
  - saint Jean-Baptiste (sa-020) ;
  - saint Jérôme (sa-024).
- **non attestés :**
  - la Sainte Famille, absente de WordNet (sa-004) ;
  - Siméon, car simeon%1:18:00 est le patriarche, un autre individu (sa-010) ;
  - Tobie / Tobias, absent (sa-014).

**Les définitions retouchées pour ne pas dépendre d'un alias non écrit :**
- sa-010 et sa-012 : « the Christ child » devient « the Child » ;
- sa-016 : « of Nain » est retiré ;
- sa-020 : « the Lamb » devient « a lamb ».

**Les attestations retirées ou revues :**
- sa-016 : l'implication tirée de la seule glose de raise%2:29:00 est retirée (elle n'était pas requise) ;
- sa-004 : l'équivalence « Sainte Famille = Marie, Joseph, l'Enfant », sans source, est retirée (elle n'était pas requise) ;
- sa-022 : l'antonymie éveillé / endormi passe à `attestee: false`.
- Chaque entrée `attestee: true` a maintenant un `source`.

**Les incompatibilités (§ 4.1.3) :**
- la `decision_ouverte` de sa-022 est reformulée selon la règle ;
- les justifications de sa-005, sa-019 et sa-021 disent qu'une posture ou un état contraire ne nie rien sans une incompatibilité attestée. Ce sont des variantes `inconnue`, et le cas de base n'en dépend pas, donc il n'y a pas de `decision_ouverte` pour elles.

**Les extensions portées par des variantes :**
- `ancrage_temporel` : sa-003#4, sa-011#5, sa-019#4 ;
- `relation_entre_eventualites` : sa-015#3 ;
- `contexte_emboite` : sa-007#4, sa-015#5 ;
- `contenu_d_inscription` : sa-009#4, sa-024#5.

**Les variantes ajoutées,** pour garder une variante de statut différent par un changement de portée, après les passages à `inconnue` :
- sa-010#6 : un catalogue de restauration cité, `non_certifiee` ;
- sa-011#7 : un catalogue de vente cité, `non_certifiee`.

## 3. Ce qui reste à décider

- **Le type d'une définition : un mot, ou le sens du pivot ?**
  - J'ai appliqué le § 4.1.2 au seul mot pivot, en tenant le type de la définition pour le sens du pivot.
  - Les noms communs non pivots (book, deacon, sword…) sont tenus pour certains, parce que le texte et la définition emploient le même mot (N § 2 : la lexicalisation, d'un sens vers son lemme, est un pas de `sous`).
  - Si les définitions sont compilées en sens pour tous leurs mots, presque tous les cas deviennent `etablie_sous_hypotheses`.
- **La polysémie d'un mot français dans WOLF.** Je ne pouvais pas la consulter, puisque WOLF est hors des fichiers autorisés. J'ai pris celle du lemme anglais correspondant, ce qui garde l'invariance de la traduction. C'est une approximation, dite dans chaque justification.
- **Le compte des changements.**
  - 61 statuts ont changé : 59 vers un statut plus faible, 2 vers un statut plus fort (sa-007#5 et sa-016#4, `inconnue` → `etablie_sous_hypotheses`).
  - `decision_ouverte` : 3 avant, 14 après.
  - Il y a 143 variantes.

## 4. Harmonisation (la règle D30 de BANCS_PHASE1 § 4.1.2, « Ce que D30 dit exactement »)

**Comment la règle est appliquée.**
- **Un mot de la définition est un type lemme.**
  - Le lien d'un mot du texte est certain si chacun de ses sens atteint ce lemme : par hyperonymie et instance, puis par la lexicalisation.
  - Le calcul est fait sur WordNet 3.0 (`data.*`, pointeurs `@` et `@i`) par un outil de rédaction, `sa_lien.py` dans le répertoire temporaire.
  - Pour un mot français, les sens sont ceux de WOLF (`sens_fr.py`).
- **Une négation est certaine** si chaque sens du type demandé est inclus dans chaque sens du mot nié.
- **La règle porte sur les mots pleins** dont dépend un atome de la définition : noms, verbes, adjectifs. Les rôles et les relations spatiales (« au-dessus », « from ») sont tenus pour des concepts de la lecture (FONDEMENTS § 2.4), et les noms propres passent par les alias de K.
- **Quand WOLF ne relie aucun sens du mot français au lemme de la définition,** une correspondance est écrite dans K, `attestee: false`. Elle donne l'hypothèse `equivalence_non_attestee`.

**Ce que je retire de la révision.**
- **J'avais traité le sens du pivot comme le type de la définition.** C'était faux : les cas anglais dont le texte emploie le lemme de la définition redeviennent `etablie`.
- **J'avais pris la polysémie anglaise pour les mots français.** C'était faux aussi : WOLF est maintenant consulté.
- **La définition de sa-001 reprend « giving ».** Le cas teste le pas lexical hand → give, et la révision l'avait remplacée par « handing » ; ce remplacement est annulé. hand%2:40:00 contient le lemme give dans son synset, hand%2:38:00 non : `etablie_sous_hypotheses` [sens], avec la `decision_ouverte`.

**Les statuts changés : 22, dont 19 plus forts et 3 plus faibles.**

| cas ou variante | avant | après | pourquoi |
|---|---|---|---|
| sa-003, #2, #6 | esh | etablie | ascend, heaven, chariot, fire : le même lemme des deux côtés |
| sa-005#1 (traduction anglaise) | esh | etablie | les mots de la définition |
| sa-006#2 | esh | etablie | emerge, sea : le même lemme |
| sa-007, #1, #2, #5, #6 | esh | etablie | peindre → paint (4/4), pinceau → brush (1/1) dans WOLF : certains |
| sa-011#2 | esh | etablie | description de base passée en anglais (voir plus bas) : les mots de la définition |
| sa-012#2, sa-014#2, sa-024#2 | esh | etablie | les variantes affirmées emploient les lemmes de la définition |
| sa-013#1 (traduction anglaise) | esh | etablie | les mots de la définition |
| sa-015, #2, #6 | esh | etablie | body, lower, cross, nail, draw, foot : le même lemme |
| sa-023#1 (traduction anglaise) | esh | etablie | presents, sword, kneeling, king |
| sa-009#1 (traduction) | etablie | esh [sens] | pleurer → weep 1/7, pied → foot 10/11 |
| sa-019#1 (traduction) | etablie | esh [equivalence_non_attestee, sens] | « genoux » n'atteint pas lap (0/3), et giron est absent de WOLF |
| sa-021#1 (traduction) | etablie | esh [equivalence_non_attestee, sens] | « couché » est absent de WOLF |

**Les hypothèses changées sans changement de statut.**
- **sa-005, sa-013 :** [equivalence_non_attestee, sens], puisque « endormi » n'atteint pas sleeping dans WOLF.
- **sa-016 :** [equivalence_non_attestee, sens, relation_inconnue].
  - Aucun des 11 sens de « relever » n'atteint raise.
  - « from the dead » ne vient que de la glose de raise%2:29:00, écrite comme une relation inconnue.
  - La traduction anglaise est [sens, relation_inconnue].
- **sa-017 :** [connaissance_typique] seule, puisque wear est le même lemme ; la traduction est [connaissance_typique, sens].
- **sa-023 :** [equivalence_non_attestee, sens], puisque « remettre » n'atteint present par aucun de ses 18 sens.
- **sa-002#3 et sa-018#2 :** [equivalence_non_attestee, sens], par gentilhomme → nobleman, bourse → purse et « couronne d'épines », absente de WOLF.
- **sa-015#1 :** [equivalence_non_attestee, sens], par arracher → draw (0/2).

**Les statuts confirmés par le calcul.**
- **Les négations restent `inconnue` :**
  - give, 44 sens demandés ;
  - offer, 13 ;
  - wear, 9, avec 42 sens pour « porter » ;
  - bless ;
  - pour ;
  - sleep ;
  - hold.
- **La seule négation certaine est celle de sa-004#3, `ecartee` :** fuir n'a qu'un sens dans WOLF (flee%2:38:00), et flee n'en a qu'un dans WordNet. Les autres variantes, sa-004#2 compris, sont inchangées.

**Les descriptions touchées, sans réécrire aucune définition.**
- **sa-011 : la langue de base passe à l'anglais.**
  - Le texte français devient la traduction, et la répartition des langues passe à 13 en / 11 fr.
  - La raison : aucun mot français du récipient n'atteint jug dans WOLF (cruche est absent ; pichet, broc, carafe : 0 sens). Aucune variante française ne pouvait donc différer du cas par la portée, la modalité, le temps ou les rôles, comme le § 4 l'exige.
  - Le pas lexical reste testé dans la traduction (`inconnue`), avec la correspondance non attestée cruche / jug.
- **Deux traductions prennent le mot exact de l'anglais :** « émergeant » au lieu de « sortant » (sa-006#1) et « guirlande » au lieu de « couronne » (sa-017#1). Sortir n'atteint pas emerge (0/14), couronne n'atteint pas wreath (0/8). Ce sont des choix de traduction ; les cas ne testent pas ces mots.

**Les decision_ouverte.**
- **Cas de base : 14 → 8.** Elles sont retirées là où le statut ne dépend plus d'un choix de sens :
  - le lien est devenu certain : sa-003, sa-007, sa-015 ;
  - une correspondance non attestée garde l'hypothèse quelle que soit l'option : sa-005, sa-013, sa-023.
- **Variantes : 4 ajoutées,** sur sa-003#1, sa-009#1, sa-020#2 et sa-022#3.

**Les cas de base par statut, après :** 6 etablie, 6 etablie_sous_hypotheses, 1 non_certifiee, 11 inconnue.
