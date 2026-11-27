# Révision de evenements_etats après la relecture A

La version 1 (avant révision) est gardée dans le répertoire de travail de la session :
`/tmp/claude-0/-home-user-oedipamaas/d0859811-5c3e-5c8f-a763-617b9258ee72/scratchpad/v1_evenements_etats.json`.

**Le bilan :**
- 60 statuts changent (bases et variantes), tous vers un statut plus faible, aucun vers un statut plus fort ;
- 4 `decision_ouverte` avant la révision, 20 après ;
- 157 variantes au lieu de 155 (deux ajoutées) ;
- le validateur, lancé avec `--quotas`, rend 0 erreur.

## 1. Les désaccords de la relecture

### 1.1 Sûreté

| désaccord | réponse | ce qui a changé |
|---|---|---|
| **ee-005**, et ses variantes #1, #7 et #3 : « avoir peur ⇔ frightened » n'est pas attestée | **corrigé** | L'entrée de K passe à `attestee: false`, avec ce que WordNet donne réellement : fear = afraid (attribut), la dérivation fear → fearful, et frightened comme satellite d'afraid. La base, #1 et #7 passent à `etablie_sous_hypotheses` [`equivalence_non_attestee`, `sens`]. #3 (« n'a pas peur ») passe à `inconnue`, la négation ne se propageant pas sans équivalence (F § 3.3). La paraphrase #2 garde « avoir peur » : l'adjectif aurait changé le statut par la seule forme. Le texte dit « bondit hors de l'eau », pour suivre « leaping » de la définition. |
| **ee-001**, et ses variantes #1, #2, #6, #7 et #4 : « asleep » n'est pas relié à « dormir » | **corrigé**, autrement que proposé | La définition dit « sleeping », le verbe du texte, au lieu de « asleep » : il n'y a plus d'équivalence à attester. Elle dit aussi « on a woman's knees », car « genoux » n'est pas « lap ». Mais « dormir » a deux sens : la base et #1, #2, #6, #7 passent à `etablie_sous_hypotheses` [`sens`], avec une `decision_ouverte`. #4 (« ne dort pas ») passe à `inconnue`. L'équivalence sommeil ⇔ dormir (#2) a pour source le pointeur de dérivation 14024882 + 00014742. |
| **ee-002**, et ses variantes #1, #2, #7 ; **ee-023#3** : « tend » ou « hands » ne donnent pas « giving » | **corrigé** | Le texte dit « donne » et « gives » partout, comme la définition. ee-002 passe pourtant à `etablie_sous_hypotheses` [`sens`], pour une autre raison : « nu » (naked) a cinq sens. Une `decision_ouverte` est ajoutée, et #5 (« n'est pas nu ») passe à `inconnue`. ee-023#3 reste `etablie` : « gives » est le mot de la définition, et le pivot (« scene ») n'y intervient pas (convention en 3). |
| **ee-013#3** : une direction n'est pas un terme | **corrigé** | La variante dit « walk … to the walled town », et non plus « towards ». Elle est renommée `composition` (elle ajoute la construction de destination). Elle passe à `etablie_sous_hypotheses` [`sens`], car « walk » a dix sens, avec une `decision_ouverte`. |
| **ee-015#3** : « before Perseus » n'est pas appuyé | **corrigé** | La variante dit « In the centre, before Perseus, who holds out the head of Medusa, … ». Elle reste `etablie`. |
| **D1**, les 16 négations d'un mot polysémique de la famille | **corrigé** pour 14, **contesté** pour 2 | `inconnue`, avec une `decision_ouverte` qui donne `ecartee` sous `sens_fixe_par_le_contexte`, pour : ee-002#5, ee-003 et #1, #2, #6, #7, ee-008#5, ee-014#5, ee-015#6, ee-020#5, ee-022#4, ee-024 et #1, #6. **Contesté pour ee-007#6 et ee-009#5 :** « weep » (weep%2:29:00::) et « behead » (behead%2:35:00::) n'ont qu'un sens dans WordNet 3.0. La règle de N § 2 (D30), appliquée à la lettre, rend la négation certaine : chaque nœud du type demandé est inclus dans chaque sens du mot nié. Ces deux variantes restent `ecartee` ; la note sous D1 exclut d'ailleurs les mots à sens unique. |

### 1.2 Connaissance non fondée

| désaccord | réponse | ce qui a changé |
|---|---|---|
| **ee-004** : « blind ⇒ un aveuglement antérieur » est marqué attesté sans ressource | **corrigé** | L'entrée passe à `attestee: false` (« blinded » est un satellite de « blind », et la condition est une hypothèse de rédaction). Le statut reste `etablie_sous_hypotheses` ; on y ajoute l'hypothèse `sens`, « blind » ayant trois sens. « Stride ⊑ walk » est une hyperonymie, désormais implicite (§ 4.1, 1 : 01919711 @ 01904930). La définition dit « hunter » au lieu de « giant », que le texte ne donne que comme modificateur. #3 passe à `etablie_sous_hypotheses` [`sens`], le verbe « blind » ayant trois sens. |
| **ee-018** : la condition « et non une lente dégradation » n'a pas de ressource | **corrigé** | La conséquence conditionnelle passe à `attestee: false`. Son contenu cite les deux verbes que WordNet relie à ruin%1:06:00:: : « fall into ruin » et « reduce to ruins ». La ressource laisse donc elle-même les deux origines ouvertes. La converse « derrière ⇔ devant », marquée attestée sans source, est retirée : la définition dit « behind him », et le texte « Behind the young man ». La base et ses variantes prennent aussi l'hypothèse `sens` (« ruin » a six sens). #3 passe à `etablie_sous_hypotheses` [`sens`]. |

### 1.3 Incohérence

| désaccord | réponse | ce qui a changé |
|---|---|---|
| **ee-006#2** : une paraphrase change le statut | **corrigé** | La paraphrase garde la locution (« who is in a rage ») et le statut de la base, `etablie_sous_hypotheses` [`equivalence_non_attestee`, `sens`]. |
| **ee-011#3** : le verbe fall est polysémique aussi | **corrigé** | La variante passe à `etablie_sous_hypotheses` [`sens`]. La `decision_ouverte` du cas, renommée `tous_les_sens` / `sens_fixe_par_le_contexte`, couvre la variante. La source de l'équivalence est précisée : la dérivation de 07362386 vers 01972298, c'est-à-dire fall%2:38:03:: et non fall%2:38:00:: comme l'écrivait la version 1. |
| **ee-012#2** : la variation n'est pas un changement de participant | **corrigé** | Renommée `composition` : elle ajoute la construction `complement_d_agent`. |
| **ee-013#3** : même cause | **corrigé** | Renommée `composition` (voir 1.1). |
| **ee-020#3** : même cause | **corrigé** | La variante est réécrite : le même couple est montré « during their wedding feast ». Elle est nommée `changement_de_temps`. |
| **ee-024#3** : même cause | **corrigé** | Renommée `changement_de_modalite`. La négation y est remplacée par un antonyme, ce qui est un changement de polarité. |
| **ee-019#3** : deux situations réunies sous `changement_de_temps` | **contesté** | La variante ne change ni les participants ni la portée : elle place au même moment deux éventualités que la base met à deux moments, dans deux scènes successives. C'est ce que mesure la variation de temps, « l'ancrage temporel » (QUALIFICATION § 2.2). Pour l'ontologie, le moment figuré est celui d'une situation (O § 3) : réunir les deux scènes en une, c'est donner aux deux éventualités le même moment. Le nom est gardé. |

### 1.4 Qualité

| désaccord | réponse | ce qui a changé |
|---|---|---|
| **ee-012, ee-013** : aucune variante ne change de statut par la portée, la modalité, le temps ou une inversion | **corrigé** | Une variante `changement_de_modalite` est ajoutée à chacun : une source citée (un inventaire) dit la configuration demandée. Elle est `non_certifiee`, et le statut diffère de la base. |
| **ee-004#3, ee-008#2, ee-010, ee-016#1** : K incomplet, ou lien lexical non dit | **corrigé** | ee-004#3 : stride @ walk est implicite (§ 4.1, 1). ee-008#2 : la paraphrase garde « sacrifier » ; « immoler » (immolate, un seul sens, @ sacrifice%2:40:01::) aurait levé l'hypothèse de sens par la forme seule. ee-010 : « bourreaux » devient « tortionnaires » (torturer, un seul sens). ee-016#1 : « Gaulish » devient « Gallic », que WordNet connaît, et l'hypothèse `sens` couvre ses deux sens. |
| **ee-009#5** : la description est écrite pour la négation | **corrigé** | Nouveau texte : « Judith, her sword lowered, does not behead Holofernes: she turns towards the entrance of the tent, where her maidservant beckons. » |

### 1.5 Les questions générales de la relecture (§ 3) qui touchent la famille

- **Q1 (une glose atteste-t-elle ?) :** il n'y a plus d'équivalence fondée sur une glose dans la famille. ee-001 ne passe plus par « asleep », et sommeil ⇔ dormir repose sur un pointeur de dérivation (voir 3, convention c).
- **Q2 (« s'apprêter à ») :** ee-008 garde la lecture « en cours » de O § 1.2. Il passe à `etablie_sous_hypotheses` pour la seule polysémie de « sacrifier ».
- **Q6 (« unbroken ») :** dans ee-024, ce mot n'apparaît que dans le commentaire des critiques, de portée `non_ancre`. Il n'appuie aucune négation.
- **Q10 (l'attestation d'une connaissance typique) :** ee-020 passe à `attestee: false`, aucune ressource n'ayant été consultée.
- **Q12 (qui ferme un sens) :** ee-003 porte maintenant une `decision_ouverte` à deux options, comme ee-011.

## 2. Les autres changements faits par le § 4.1

**Les sources.** Le champ `source` est ajouté à chaque connaissance attestée, avec la clé, l'offset et le pointeur, tous vérifiés dans `data.*` :
- ee-001 : sommeil ⇔ dormir, dérivation 14024882 + 00014742 ;
- ee-006 : rage @ anger, 07516997 @ 07516354 ;
- ee-010 :
  - flagellation%1:04:00:: + flagellate (01398443), et flagellate @ flog%2:35:00:: (01411085) ;
  - jesus @i prophet @ religious_person @ person ;
- ee-011 : fall%1:11:00:: + fall%2:38:03:: ;
- ee-012 : baptism + baptize%2:32:00:: ;
- ee-016 : legionnaire%1:18:00:: @ soldier%1:18:00::.

**Les entrées passées à `attestee: false`.**
- ee-004, ee-005, ee-018 et ee-020 : voir le § 1.
- ee-017 : lifeless ⇒ dead (un pointeur de similarité `&`, qui n'est pas une inclusion) et dead ⇒ mort antérieure (posée par O § 5, sans ressource). La base reste `inconnue`.

**Le régime des sens** (des `decision_ouverte` `tous_les_sens` / `sens_fixe_par_le_contexte`, statut le plus prudent). En plus des cas du § 1 :
- ee-008 : « sacrifier », quatre sens ;
- ee-010 : un seul des deux sens de « flagellation » a le pointeur de dérivation ;
- ee-014 : « bâtir », dix sens ;
- ee-016 : « gaulois », la Gaule ou la France ; « légionnaire », deux sens ;
- ee-022 : « nu », cinq sens ;
- ee-003#3 et ee-024#2 : les variantes affirmées ;
- ee-007#1 : la traduction « pleurer » ;
- ee-017#3 : « tuer » ;
- ee-021 : « prier », deux sens. La variante niée par l'auteur passe de `contradictoire` à `non_certifiee` sous `tous_les_sens`.

Ces cas passent à `etablie_sous_hypotheses` [`sens`], et leurs négations à `inconnue`.

**Les incompatibilités.** Les variantes fondées sur un antonyme restent `inconnue`. Une `decision_ouverte` dit leur statut si une incompatibilité attestée était admise :
- ee-001#3 (« s'est réveillé ») et ee-002#4 (« vêtu ») : `inconnue` sous les deux options, l'événement demandé étant de toute façon antérieur ;
- ee-006#3 (« in front of ») : `ecartee` si une incompatibilité était admise ;
- ee-007#5 (« below ») : de même ;
- ee-024#3 (« intact ») : de même.

**Les définitions corrigées :**
- ee-001 : « sleeping », « knees » ;
- ee-004 : « hunter » ;
- ee-010 : « attached to », « torturers » ;
- ee-017 : « killing » ; « slaying » (slay) est plus spécifique que « kill », que dit « tuer » ;
- ee-018 : « behind him » ;
- ee-019 : « addresses », le verbe du texte (« s'adresse à »).

**Les extensions sur les variantes.** Le champ est désormais admis sur une variante :
- `ancrage_temporel` sur les variantes de temps de ee-001, ee-002, ee-003, ee-005, ee-006, ee-007, ee-010, ee-014, ee-015, ee-016, ee-018 et ee-024 ;
- `contenu_d_inscription` sur ee-002#6.

## 3. Les conventions que j'ai dû prendre, et qui restent à décider

**a. Le régime des sens n'est appliqué qu'aux mots décisifs.** Il porte sur le mot pivot, que le cas déclare comme un sens, et sur les mots dont la négation décide. Les autres mots de la définition sont pris comme des mots : un même mot des deux côtés est atteint par la lexicalisation (N § 2, `sous`). Appliqué à chaque mot polysémique (« man », « cut », « hold »), le régime ferait passer presque tous les cas à `etablie_sous_hypotheses`. Il faut dire si une définition est compilée en sens ou en mots.

**b. WOLF n'est pas consultable ici.** J'ai prêté à un mot français les sens de son équivalent anglais usuel. Les statuts des cas français dépendent de cette supposition.

**c. Un pointeur de dérivation est accepté pour source.** C'est le cas entre un nom d'action ou d'état et son verbe, ou son adjectif (ee-001, ee-010, ee-011, ee-012). Mais FONDEMENTS § 2.7 demande en plus une validation (« une seconde ressource indépendante ») ; à la lettre, ces équivalences ne seraient pas attestées, et ces cas passeraient à `etablie_sous_hypotheses` [`equivalence_non_attestee`].

**d. Une seule `decision_ouverte` par cas.** Le validateur refuse une liste. Quand un cas porte plusieurs questions (ee-001, ee-007, ee-021, ee-024), elles sont réunies dans une seule, et les options nomment la variante qu'elles concernent. Le champ gagnerait à admettre une liste, ou une `decision_ouverte` par variante.

**e. Entre `contradictoire` et `non_certifiee`.** Le § 4.1 ne range pas ces deux statuts l'un par rapport à l'autre. J'ai tenu `non_certifiee` pour le plus prudent (ee-021#4), parce qu'il ne suppose aucun appui négatif.

## 4. Harmonisation (régime D30 de BANCS_PHASE1 § 4.1, 2, et sens français de WOLF)

**Ce que cette passe remplace.** La règle est maintenant écrite (« Ce que D30 dit exactement ») et les sens français sont ceux de WOLF (`outils/bancs/sens_fr.py`). Elle remplace les conventions a, b et d du § 3 :
- **a :** un mot de la définition est un type lemme, et la règle vaut pour chaque mot dont un atome dépend, non pour le pivot seul ;
- **b :** les mots français ont maintenant les sens de WOLF ;
- **d :** une variante porte désormais sa propre `decision_ouverte`.

La convention c (le pointeur de dérivation pris pour source) et la convention e (`non_certifiee` tenu pour plus prudent que `contradictoire`) restent.

**Comment les liens ont été calculés.** Pour chaque mot dont un atome de la définition dépend, j'ai fait le calcul suivant (helper personnel, `scratchpad/liens.py`, qui lit `data.*` et `index.*` de WordNet 3.0 et exécute `sens_fr.py`) :
- **lien positif :** chaque sens du mot du texte remonte-t-il, par `@` et `@i`, à un synset qui contient le lemme de la définition ?
- **négation :** chaque sens du lemme demandé est-il inclus dans chaque sens du mot nié ?

Les principaux résultats :
- **sans lien du tout :** dormir → asleep (0/2) ; genou → lap (0/3) ; bord → riverbank (0/9) ; adresser → speak (0/12) ; laboureur → ploughman (0/3) ;
- **absents de WOLF :** légionnaire, gaulois, enchaîné, cruche ; « emmener » n'y a que *convene* ;
- **certains :** cheveu → hair, bondir → leap, vieillard → old man, tortionnaire → torturer, romain → roman, grotte → cave, vérité → truth, et « flagellation » (un seul sens WOLF) ;
- **le reste** se partage : une partie des sens WOLF atteint le lemme, l'autre non, d'où une hypothèse de sens (homme → man 14/20, tuer → slay 1/17, parler → speak 5/8, etc.) ;
- **négations :** celles de dead, broken, nu, dormir, sacrifier, bâtir et feast ne sont que possibles ; celles de weep et de behead, mots à un seul sens, sont certaines.

**Les définitions de la version 1 sont rétablies.** La consigne d'harmonisation interdit de réécrire une définition avec les mots du texte. J'ai donc annulé les réécritures faites à la révision :
- ee-001 : « asleep », « lap » ;
- ee-004 : « giant » ;
- ee-010 : « tied » ;
- ee-017 : « slaying » ;
- ee-018 : « in front of » ;
- ee-019 : « speaks to ».

Les pas lexicaux qu'elles évitaient sont gardés, avec leur statut prudent. Quand il n'y a aucun lien, K reçoit une équivalence non attestée : dormir ⇔ asleep, « sur les genoux » ⇔ « in the lap », la converse derrière ⇔ devant, et légionnaire, gaulois, enchaîné, emmener (ee-016).

**Les descriptions corrigées.** Il s'agit seulement de mots qui empêchaient un atome d'avoir le moindre appui, sans rapport avec le phénomène testé :
- ee-003 : « his courtiers around him », « his curtained bed » ;
- ee-004 : « The giant » devient la tête nominale, et « a hunter's bow » remplace « his bow » ;
- ee-005 : « sur la rive », et « towards him » dans la traduction ;
- ee-011 : « in a wide coastal landscape », « a ploughman at work » ;
- ee-013#3 : « accompanied by » ;
- ee-019 : « parle à » et « speaks to » ;
- ee-020#3 : « is seated ».

**Les statuts changés par cette passe : 12, dont 9 plus forts et 3 plus faibles.**

| cas | avant | après | sens | pourquoi |
|---|---|---|---|---|
| ee-002#1, ee-008#1, ee-014#1, ee-016#1, ee-022#1 | `etablie_sous_hypotheses` | `etablie` | plus fort | Ce sont des traductions anglaises qui emploient les lemmes mêmes de la définition : un lien certain. La révision avait pris le mot de la définition pour un sens choisi. |
| ee-003#3, ee-024#2 | `etablie_sous_hypotheses` | `etablie` | plus fort | « The king is dead », « is broken » : le même lemme des deux côtés, donc un lien certain (seule la négation de ces mots reste possible). |
| ee-011#3 | `etablie_sous_hypotheses` | `etablie` | plus fort | « Icarus falls » : le même lemme que la définition. L'hypothèse de sens ne tient qu'au nom « fall ». |
| ee-013#3 | `etablie_sous_hypotheses` | `etablie` | plus fort | « walk » est le même lemme des deux côtés. |
| ee-011#1 | `etablie_sous_hypotheses` | `inconnue` | plus faible | « laboureur » n'atteint pas « ploughman » dans WOLF : l'atome n'a aucun appui. |
| ee-012#2 | `etablie` | `etablie_sous_hypotheses` | plus faible | « baptême » (WOLF : début, baptême, christening), « homme » et « jeune homme » n'atteignent la définition que par une partie de leurs sens. |
| ee-019#3 | `etablie` | `etablie_sous_hypotheses` | plus faible | « parler » (WOLF : cinq sens sur huit vers speak). |

**Les hypothèses ajoutées sans changement de statut** (le statut était déjà `etablie_sous_hypotheses`) :
- `equivalence_non_attestee` dans ee-001 (base, #1, #2, #6, #7), ee-016 (base, #2, #7) et ee-018 (base et variantes) ;
- `sens` dans ee-018#1.

**Les `decision_ouverte`.**
- Elles sont gardées seulement là où le statut change selon l'option. Pour les variantes, une `decision_ouverte` propre remplace les options regroupées au niveau du cas.
- Il y en a 11 sur les cas (ee-002, -003, -008, -009, -010, -011, -014, -019, -022, -023, -024) et 18 sur les variantes. Avant cette passe, il y en avait 20 sur les cas et aucune sur les variantes.
- Les cas où le statut est le même sous les deux options n'en portent plus (ee-001, ee-004, ee-006, ee-016, ee-018) ; ils gardent l'hypothèse `sens` dans leur liste.

**Les cas de base par statut, après :**

| statut | cas |
|---|---|
| `etablie_sous_hypotheses` | 12 |
| `inconnue` | 10 |
| `etablie` | 1 (ee-007) |
| `non_certifiee` | 1 |

Le seul cas de base anglais établi est ee-007. Tous les cas de base français positifs sont sous hypothèse de sens, la polysémie de WOLF étant large pour les mots courants (homme, femme, tenir, porter, donner).

**Une question qui reste, et qui pèse sur la mesure : la traduction n'est plus invariante.** Avec WOLF, la traduction d'un cas anglais établi est souvent `etablie_sous_hypotheses` (ee-007#1), parfois `inconnue` (ee-011#1, faute d'un lien laboureur → ploughman), et celle d'un cas français est souvent `etablie` (ee-002#1, ee-008#1, ee-014#1, ee-016#1, ee-022#1). La relation métamorphique « traduction : même statut » (QUALIFICATION § 2.2) est donc violée par la sémantique cible elle-même, et non par le moteur. Il faudrait la redéfinir relativement à K et à WOLF, ou ne mesurer que l'invariance sous le régime `sens_fixe_par_le_contexte`.
