# definitions_classification : la révision après la relecture C

La version 1 a été relue par la relecture C, puis révisée selon BANCS_PHASE1 § 4.1. La version 1 est gardée telle
quelle : /tmp/claude-0/-home-user-oedipamaas/d0859811-5c3e-5c8f-a763-617b9258ee72/scratchpad/dc_v1.json.

Le validateur rend 0 erreur avec `--quotas` : 24 cas de base, 141 variantes, 24 cas composés, dont 7 à trois phénomènes.

**Deux conventions, écrites ici** parce que les statuts en dépendent :
- **les mots d'une définition sont compilés au niveau du mot** (NOYAU § 3 : `type(X, T)` avec T un mot ; § 2, D27). Seules
  les entrées de la base de définitions portent sur des sens (FONDEMENTS § 2.7). Il s'ensuit :
  - un lien positif du même mot est certain, par lexicalisation ;
  - la négation d'un mot polysémique n'est que possible sous D30, parce que chaque sens du type demandé doit être inclus
    dans chaque sens du mot nié ;
- **le passage par WOLF des mots français n'a pas pu être vérifié.** Quand un verbe ou un nom français a des sens qui
  n'atteignent pas le mot de la définition (donner, conduire, guider, tenir, tirer, lire, tour, roue, fuite, laurier),
  la liste prudente porte `sens`.

## 1. Les désaccords de la relecture C

| désaccord | réponse | ce qui a changé, ou pourquoi |
|---|---|---|
| dc-010 (+#1, #2, #5, #6), sûreté : l'atome « still life » sans appui | **corrigé** | La description dit maintenant le genre (« Still life, oil on panel » ; « Nature morte »), de portée œuvre, et `genre(T)` est appuyé. Le statut reste `etablie_sous_hypotheses`, avec `sens` en plus. La connaissance typique passe à `attestee: false` : aucune ressource n'est nommée. |
| dc-014#4, sûreté : l'inscription « peut-être ajoutée » reste sur le cadre | **corrigé** | `etablie_sous_hypotheses` devient `inconnue`, sorte `negatif`, comme le cas de base sous l'option prudente. |
| dc-012#2, sûreté (ouvert) : « (flight into Egypt) », étiquette ou atome de situation | **corrigé** | La variante devient un vrai changement de modalité, du titre au figuré (« Le panneau figure la Fuite en Égypte… »). Son statut est `etablie_sous_hypotheses` [identite, sens], la forme prudente sous les deux options : l'alias Marie/Mary n'est pas attesté, et le mot « Fuite », polysémique, appuierait l'atome de situation. |
| dc-002#3, sûreté (faible) : « ne porte pas » contre « with » | **corrigé** | `ecartee` devient `inconnue`. K n'identifie pas les deux relations (NOYAU § 1.1 ; FONDEMENTS § 3.1). |
| dc-003 (K) : glose réécrite et donnée pour attestée | **corrigé** | L'entrée devient `relation_inconnue`, `attestee: false`, avec la glose réelle (« a bowl-shaped drinking vessel; especially the Eucharistic cup »). #2 passe de `etablie` à `etablie_sous_hypotheses` [relation_inconnue, sens], et l'option forte de la décision ouverte aussi. |
| dc-015 (K) : « à droite ⇒ à côté », non fondée et fausse | **corrigé** | L'implication est retirée. La définition demande maintenant le côté : « St Barbara with a tower to her right ». La relation est dite par le texte, du point de vue de la figure. |
| dc-004 (K) : glose réécrite ; dans #2, la mort est imminente, non accomplie | **corrigé** | L'entrée devient `relation_inconnue` non attestée, avec la glose réelle (« voluntarily suffers death »). #2 ne s'appuie plus sur la périphrase : le figuré dit « la martyre Eulalie », et le statut est `etablie_sous_hypotheses` [sens] (tenir → hold, sous WOLF). La question de l'ancrage temporel d'un type défini par un événement accompli reste ouverte (relecture, question 9). |
| dc-007 (K) : la solitude est la glose de hermit%1:18:00::, non du pivot | **corrigé** | La condition de solitude passe à `attestee: false`, et la variante qui la niait n'est plus `ecartee`. S'y ajoute une condition attestée par WordNet : hermit%1:18:01:: ⊑ eremite ⊑ religious, pointeurs `@`, vérifiés dans data.noun. Elle ne réfute pas non plus « religieux » nié : sous D30, le mot « hermit » a aussi le sens hermit%1:18:00::, qui n'est pas inclus dans religious. La définition dit maintenant « in the desert », car desert%1:15:00:: n'est pas ⊑ wilderness. |
| noms entre langues (dc-012#2, dc-015#2, #3) | **corrigé** | Des alias sont écrits dans K, en `identite_documentaire` non attestée : Marie/Mary, Barbe/Barbara, Polyphème/Polyphemus. Les variantes passent à `identite`, et la négation de « Barbe » ne réfute plus « Barbara » (dc-015#3 : `ecartee` devient `inconnue`). |
| sens et contexte (dc-013) | **corrigé** | dc-013, dc-014, dc-015, dc-016, dc-019, dc-010, dc-001, dc-024 et dc-002 portent `sens` dans leurs hypothèses. Exclure un sens par le contexte demande une restriction de sélection que K ne contient pas. Aucun de ces statuts ne change : ils sont tous `etablie_sous_hypotheses`, sauf ceux qui deviennent `etablie_sous_hypotheses` par la règle 1. |
| dc-022#2 : la ré-inversion étiquetée `inversion_des_roles` | **corrigé** | L'étiquette devient `changement_de_participant`. Le statut passe de `etablie` à `etablie_sous_hypotheses` [sens] (« donner », par WOLF). |
| dc-005 : décision ouverte manquante (compilation de « the cyclops Polyphemus ») | **corrigé** | Une `decision_ouverte` est ajoutée, à trois options : `condition_non_attestee` (`inconnue`), `condition_attestee_conjonction_type_et_nom` (`ecartee`), `epithete_non_compilee_alias_admis` (`etablie`). Par la règle 1 du § 4.1, le statut retenu passe de `ecartee` à `inconnue`. |
| dc-007 : décision ouverte mal posée, les documents tranchent | **corrigé (accepté)** | La `decision_ouverte` est retirée. La justification cite FONDEMENTS § 2.7 et SPECIFICATION § 3, § 3.1 et § 4. Le statut reste `inconnue`. |
| dc-012 (forme) : aucune variante de statut différent n'est de portée, de modalité ou de temps | **corrigé** | #2 est maintenant un `changement_de_modalite`, du titre au figuré. |
| dc-004#4, étiquette : « On sait que… » | **corrigé** | Le texte devient une vraie modalité : « tient peut-être une palme ». Le statut reste `inconnue`. |
| dc-011#3, étiquette : ajout d'un mot | **corrigé** | Le cas de base dit maintenant « peut-être aveugle ». #3 (« aveugle », affirmé) est donc un vrai changement de modalité. #4 devient la négation (« qui n'est pas aveugle »), en `inconnue` sous D30. |
| dc-008#4, étiquette : une négation remplacée par une affirmation | **contesté** | Passer de « n'est pas chevalin » à « est chevalin » est le changement de modalité de QUALIFICATION § 2.2, qui énumère « affirmé, possible, traditionnel, nié ». La variante est gardée sous ce nom, et réécrite (« c'est un centaure »). Son statut devient `etablie_sous_hypotheses` [sens] : le type est dit, et « tirer » est polysémique. |
| dc-012#2, dc-020#3, étiquette « composition » | **dc-012#2 corrigé ; dc-020#3 contesté** | dc-020#3 compose bien un deuxième phénomène (compositionnalité, `adjectif_privatif/ancien`) : c'est la `composition` de QUALIFICATION § 2.2. Son statut devient `inconnue` (ci-dessous). |

## 2. Les autres changements faits par le § 4.1

**Règle 1 : les attestations.**
- **Une glose seule, réécrite et donnée pour « validée », passe à `relation_inconnue`, `attestee: false`,** avec la glose
  réelle :
  - mermaid (dc-001), chalice (dc-003), martyr (dc-004), blind (dc-011), halo (dc-024).
  - dc-001 et dc-024 passent de `etablie` à `etablie_sous_hypotheses` [relation_inconnue, sens]. Ils gagnent une
    `decision_ouverte` (`glose_relation_inconnue` contre `equivalence_attestee`, qui donnerait `etablie`), les
    opérations `classification` et `abduction`, et l'extension `abduction`.
- **Les conditions nécessaires tirées d'une glose passent à `attestee: false`** : cyclops (dc-005), unicorn (dc-006),
  centaur (dc-008), la solitude de hermit (dc-007).
  - Une relation non attestée ne propage pas la négation (FONDEMENTS § 3.3).
  - **dc-005 et dc-008 passent de `ecartee` à `inconnue`,** avec leurs variantes. Ils gagnent une `decision_ouverte`
    (attestée : `ecartee`) et une variante de modalité positive : dc-005#7 `etablie_sous_hypotheses` [identite, sens] ;
    dc-008#4 [sens].
- **dc-006 est refondu sur une condition nécessaire réellement attestée.** WordNet 3.0 donne le pointeur `@` de
  10737964 (unicorn%1:18:00::) vers 09483738 (imaginary_creature%1:18:00::), vérifié dans data.noun.
  - L'auteur nie « an imaginary creature » du cheval. Les deux mots sont monosémiques, et la négation est certaine.
  - Le statut reste `ecartee`, et c'est maintenant le seul `ecartee` de base de la famille.
  - La négation de la corne passe en variante `composition`, en `inconnue`.
  - Opérations : `lecture` ; extensions : `aucune`.
- **L'implication « chevalin » (dc-008) passe à `attestee: false`.** Ce n'est pas une relation de WordNet.
- **Les connaissances typiques passent à `attestee: false`** (dc-009, 010, 013, 014, 015, 016, 019), parce qu'aucune
  ressource n'est nommée. Les statuts ne changent pas, car une connaissance typique ne donne de toute façon qu'une
  hypothèse identifiée.
- **Les distinctions documentaires Étienne/Laurent (dc-013) et Barbe/Catherine (dc-014) passent à `attestee: false`.**
  Les statuts restent `inconnue`, l'option prudente : la justification dit que, sans une distinction attestée, l'abduction
  pourrait rester admissible.
- **Il reste deux entrées attestées,** toutes deux avec un `source` qui donne la clé de sens et les pointeurs `@` : dc-006
  et dc-007.
- **dc-014 reçoit l'extension `contenu_d_inscription`.**

**Règle 2 : le régime des sens.**
- **Les négations d'un mot polysémique de la définition passent de `ecartee` à `inconnue`.** Sous D30, une telle négation
  n'est que possible.
  - dc-009#4 (« not a pilgrim ») ;
  - dc-020#3 et #4 (« ancien moine », « n'est pas un moine » : monk a aussi le sens monk%1:18:01::) ;
  - dc-021#3 (« does not hold ») ;
  - dc-007#2 (« religieux »).
- **Des liens positifs par un mot français polysémique passent de `etablie` à `etablie_sous_hypotheses` [sens]** :
  dc-011#3, dc-018#3, dc-020#2, dc-022#2.
- **`sens` est ajouté** aux hypothèses de toutes les conclusions sous hypothèse dont la structure ou l'attribut porte sur
  un sens.

**Règle 3 : les incompatibilités.**
- La variante dc-002#7 est retirée. Le prêtre y était « agenouillé » contre « standing » : un contre-modèle par
  incompatibilité, qui n'aurait été qu'`inconnue`, et le schéma n'admet pas de `decision_ouverte` sur une variante.
- Aucun autre cas n'en dépend.

**Les autres changements :**
- **dc-007 :**
  - le cas de base dit « peut-être un ermite » ;
  - une variante de modalité est ajoutée (« Un ermite… »), en `etablie_sous_hypotheses` [sens] ;
  - la définition dit « in the desert ».
- **dc-009 :**
  - le cas de base dit « perhaps a pilgrim » ;
  - #3 est l'affirmation (« A pilgrim… »), en `etablie` : le même mot, en anglais ;
  - « along a road » devient « on a road », pour que la relation soit celle de la définition ;
  - la `decision_ouverte` a une troisième option : le possible comme prémisse graduée.
- **dc-020 :** une variante de modalité est ajoutée (« Un renard, devenu moine »), en `etablie_sous_hypotheses` [sens].
- **dc-023 :** « watch over » devient « watch », pour que le verbe soit celui de la définition (watch_over est un autre
  lemme).

## 3. Les chiffres

**Les statuts changés : 36.**
- Cas de base : 4, tous plus faibles. dc-001 et dc-024 passent de `etablie` à `etablie_sous_hypotheses` ; dc-005 et
  dc-008, de `ecartee` à `inconnue`.
- Variantes : 32.
  - 30 plus faibles.
  - 2 plus forts, dc-008#4 et dc-009#3. Ce sont deux variantes réécrites, pour être de vrais changements de modalité, non
    des statuts relevés sur le même texte.
- Variantes ajoutées : 3 (dc-005#7, dc-007#6, dc-020#7). Variante retirée : 1 (dc-002#7).

**Les `decision_ouverte` : 9 avant, 12 après.**
- Retirée : dc-007.
- Ajoutées : dc-001, dc-005, dc-008, dc-024.

**Les cas de base :**
- sortes : 8 positifs, 5 négatifs, 4 contre-modèles, 7 indéterminés ;
- statuts : 15 `inconnue`, 7 `etablie_sous_hypotheses`, 1 `etablie`, 1 `ecartee`.

## 4. Les limites qui restent

- **Deux cas n'ont de variante de statut différent que par un changement de participant ou une composition :** dc-021
  (la relation absente, ajoutée) et dc-022 (la ré-inversion).
  - Pour un cas de base `inconnue`, faute de structure, aucun changement de portée, de modalité ou de temps ne peut
    relever le statut.
  - La seule variante plus faible possible, la négation de la relation, n'est plus `ecartee` sous D30.
  - La règle du § 4 sur les variantes devrait le prévoir.
- **Le schéma n'admet de `decision_ouverte` qu'au niveau du cas** (relecture, question 7). Plusieurs variantes sont donc
  mises au statut prudent, et leur question n'est écrite que dans la justification : dc-002#3, dc-007#2, dc-009#4,
  dc-012#2, dc-015#3, dc-020#3 et #4, dc-021#3.
- **Sous D30 strict, la négation d'un mot polysémique de la définition ne réfute presque jamais,** même par ce mot
  lui-même (« n'est pas un moine »). La construction `refutation_par_la_negation_d_une_condition` n'a plus qu'un `ecartee`
  de base (dc-006, deux mots monosémiques). Si la propriétaire admet que la définition soit compilée au sens du pivot, ou
  le sens fixé par le contexte, plusieurs `ecartee` reviennent : dc-005, dc-008 (si les conditions sont attestées),
  dc-007#2, dc-009#4, dc-020#3 et #4.
- **WOLF n'a pas pu être consulté.** Les hypothèses `sens` des variantes françaises sont posées par prudence, non
  vérifiées.

## 5. Harmonisation (BANCS § 4.1, point 2, « Ce que D30 dit exactement »)

Version avant la passe : /tmp/claude-0/-home-user-oedipamaas/d0859811-5c3e-5c8f-a763-617b9258ee72/scratchpad/dc_v2.json.

Tous les cas et toutes les variantes ont été repassés, atome par atome.
- **Le mot de la définition est un type lemme.** C'était déjà la convention de la révision (§ 0) : aucun statut n'avait
  été affaibli parce qu'un mot de la définition aurait été traité comme un sens. Les entrées de la base de définitions
  et les connaissances typiques portent, elles, sur des clés de sens.
- **Les mots français ont été vérifiés avec WOLF** (`sens_fr.py`). La polysémie française n'est pas celle du mot anglais.

### 5.1 Les statuts changés : 5

**Plus fort (1).**
- **dc-012#2, de `etablie_sous_hypotheses` [identite, sens] à `etablie`.** Dans WOLF, « fuite » n'a que les sens leak,
  escape (la plante) et drain, et n'atteint pas flight. Rédigée en français, la variante serait donc `inconnue` sous
  l'option « atome de situation ».
  - Elle est désormais rédigée en anglais : « depicts the Flight into Egypt: Mary, holding the Child, is seated on a
    donkey that Joseph leads ».
  - Chaque mot de la définition y a le même lemme, et l'alias Marie/Mary n'est plus nécessaire.
  - Elle reste un changement de modalité : le titre devient une assertion du figuré.

**Plus faibles (4).** Dans les quatre cas, un mot français est absent de WOLF, ou un de ses sens n'atteint pas le type.
- **dc-006#1 (traduction), de `ecartee` à `inconnue`.** « Créature imaginaire » est absent de WOLF. La lecture n'a donc
  qu'une créature avec la propriété « imaginaire » : une entité restreinte niée, qui n'appuie rien (NOYAU § 1.1).
- **dc-010#1 (traduction), de `etablie_sous_hypotheses` à `inconnue`.** « Nature morte » est absent de WOLF : l'atome
  `genre(still life)` n'a plus d'appui.
- **dc-013#1 (traduction), de `etablie_sous_hypotheses` à `inconnue`.** « Gril » n'a dans WOLF que grill et grillroom.
  Il n'atteint ni le lemme gridiron de la définition, ni gridiron%1:06:00:: de la connaissance typique.
- **dc-024#1 (traduction), de `etablie_sous_hypotheses` à `inconnue`.** « Jeune homme » est absent de WOLF. La variante
  porte sa propre `decision_ouverte` : si le compilateur fait de « young man » un homme avec la propriété « young », et
  non le lemme young_man, le statut est `etablie_sous_hypotheses`.

Ces quatre traductions violent l'invariance « même statut » du plan. La violation vient de K (des lacunes de WOLF), non
de la lecture ni du raisonnement. Elles sont gardées telles quelles, comme des cas qui testent un pas lexical.

### 5.2 Les autres corrections

**Une variante récrite sans changer de statut.**
- dc-004#2 est rédigée en anglais : « palme » est absent de WOLF, et l'atome « palm » n'aurait aucun appui. Son statut
  reste `etablie_sous_hypotheses` [sens] : « woman » n'atteint pas « female » par tous ses sens.

**Un texte corrigé.**
- dc-013#2 (paraphrase) disait « carries a gridiron ». Carry n'atteint pas hold, que la définition demande. Le texte dit
  maintenant « holds ».

**Une hypothèse ajoutée.**
- dc-009#2 : + `sens`. La structure typique porte sur des sens de mots polysémiques (staff, hat, shell).

**Des options de `decision_ouverte` recalculées sous D30.**
- dc-005 : l'option « épithète non compilée » passe de `etablie` à `etablie_sous_hypotheses`. Les mots français
  « tenir » et « lyre » ne sont pas certains.
- dc-018 : le composé intersectif donne `etablie_sous_hypotheses`, car « laurier » a dans WOLF les sens bay. L'option
  privative donne `inconnue`, car la négation de « laurel » n'est pas certaine.
- dc-020 : l'option privative est scindée. `privatif_tous_les_sens` donne `inconnue`, parce que « moine » a dans WOLF
  aussi le sens Thelonious Monk. `privatif_sens_fixe_par_le_contexte` donne `ecartee`.

**Des `decision_ouverte` ajoutées sur des variantes** (admis par le § 4.1) : 18.
- Les négations d'un mot polysémique de la définition, options `tous_les_sens` (`inconnue`) et
  `sens_fixe_par_le_contexte` (`ecartee`) : dc-007#2, dc-009#4, dc-011#4, dc-020#3, dc-020#4, dc-021#3.
- L'alias Barbe/Barbara : dc-015#3.
- Les liens positifs sous la seule hypothèse de sens, `tous_les_sens` (`etablie_sous_hypotheses`) contre
  `sens_fixe_par_le_contexte` (`etablie`) : dc-004#2, dc-007#6, dc-008#4, dc-011#3, dc-018#2, dc-018#3, dc-020#2,
  dc-020#7, dc-022#2.
- dc-005#7 et dc-024#1.

**Ce que WOLF a confirmé.**
- Lemme certain : « martyre », « centaure », « pèlerin », « prêcher », « lire », « miroir », « aveugle » (pour le seul
  lien positif) et « Colisée » (monosémique).
- Lemme non certain, d'où `sens` : « tenir », « donner », « conduire », « guider », « tirer », « tour », « roue »,
  « laurier », « pomme », « oie », « prêtre » (le sens clergyman), « autel » (ara), « cyclope » (mohawk), « ermite »
  (eremite), « arc ».

**Les cas de base sont inchangés.** 15 `inconnue`, 7 `etablie_sous_hypotheses`, 1 `etablie`, 1 `ecartee`.
