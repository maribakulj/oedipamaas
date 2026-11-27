# Phénomènes iconographiques : la révision après la relecture C, puis l'harmonisation du régime des sens

Le fichier révisé est `phenomenes_iconographiques.json`. Il contient 24 cas de base et 145 variantes : une variante a été
ajoutée à pi-022, et deux variantes ont été remplacées (pi-005#6, pi-014#6). La version 1 est gardée hors du dépôt, dans
le brouillon de session.

Les numéros de variante (#n) comptent à partir de 1, comme dans la relecture.

## 1. Les désaccords de la relecture C

| id | gravité | réponse | ce qui a changé, ou pourquoi |
|---|---|---|---|
| pi-001 (+#1, #2, #6) | sûreté | **corrigé** | Les trois atomes sans appui sont réparés. La description dit maintenant « les yeux de son père aveugle », et la définition dit « guided » et « rubbing », les mots de la description. Ces cas ne testent aucun pas lexical : la version 1 contenait par erreur des inclusions qui n'existent pas dans WordNet (guide ⊑ accompany, rub ⊑ anoint). L'alias Tobie / Tobias n'a aucune source (pas de synset) : `attestee: false`. Le cas passe à `etablie_sous_hypotheses [identite, sens]`, avec une `decision_ouverte` sur la normalisation des noms et sur les sens. La traduction anglaise, qui dit « Tobias », est `etablie`. |
| pi-002#4 | sûreté | **corrigé** | La définition dit « the same son, in rags, kneeling among the pigs » et « riding away from his father's farmhouse », plus « reduced to herding swine ». La variante #4 est `etablie` sans passer par un nom d'agent. Le cas de base reste `ecartee`, par la distinction dite (« another young man »). |
| pi-003#3 | sûreté | **corrigé** | « Un pauvre » devient « un mendiant » (beggar), partout dans le cas, et « tranche » devient « partage » (share). L'option `etablie` de la décision ouverte n'a plus ce défaut. Avec WOLF (harmonisation), #3 est `etablie_sous_hypotheses [sens]`. |
| pi-005#3 | sûreté | **corrigé** | La définition dit « desert », le mot de la description : wilderness n'est pas un hyperonyme de desert%1:15:00::. Les alias Agar / Hagar et Ismaël / Ishmael n'ont pas de source : #3 est `etablie_sous_hypotheses [identite, sens]`. |
| pi-008 (+#1, #2, #5, #6) | sûreté | **corrigé** | La définition dit « a duke feasting at a long table, the wall behind him hung with a tapestry in which hunters pursue a stag », avec les mots et les participants de la description : ni pursue ⇒ hunt, ni nom d'agent, ni composé. « Behind the diners » devient « behind him » (le duc), et la description dit « behind the duke ». L'équivalence feast (nom) / feast (verbe) est retirée de K : elle n'est plus nécessaire. « Mounted » est retiré de la définition, car « à cheval » n'a pas d'équivalent dans WOLF. |
| pi-019#5 | sûreté (ouvert) | **corrigé** | De `ecartee` à `inconnue`. La relation niée va vers un référent conceptuel, jamais présent, et NOYAU § 1.1 exige des entités présentes. La variante porte sa propre `decision_ouverte` : `ecartee` si le concept était admis et les sens fixés. |
| pi-019 (+#1, #6) | sûreté | **corrigé** | La description dit « Ces objets signifient la brièveté de la vie humaine », avec le verbe de la définition. La locution « faire de ces objets des signes de » demandait une équivalence absente de K. « Fugacité » n'est pas dans WOLF : il est remplacé par « brièveté », dont un sens sur deux atteint transience. « Still life » est retiré de la définition : « nature morte » n'est pas dans WOLF. Avec l'harmonisation, le cas est `etablie_sous_hypotheses [sens]`, et sa traduction anglaise est `etablie`. |
| pi-019#3 | qualité | **corrigé** | La source citée n'est plus un historien réel : c'est « le catalogue d'une vente de 1898 ». Le statut `non_certifiee` ne change pas. |
| pi-020 (+#1, #2, #4, #5) | trop faible | **corrigé** | La relecture a raison : la « concurrente » (un saint pénitent absent) n'expliquait pas les mêmes observations, puisqu'elle ne rend pas compte de la bougie éteinte. Elle est retirée, et le cas passe d'`inconnue` à `etablie_sous_hypotheses [connaissance_typique]`. La définition demande « a skull beside an extinguished candle », et la version 1 ne disait pas « beside » : les descriptions le disent maintenant. La sorte passe d'`indetermine` à `positif`. |
| pi-020 (K) | connaissance non fondée | **corrigé** | L'entrée « saint pénitent absent » est retirée : c'était une hypothèse de rédaction, écrite pour créer une concurrente. L'implication « snuff out ⇒ extinguished » est retirée : la description dit « extinguished ». La connaissance typique restante est `attestee: false`. |
| noms entre langues (pi-015#3, pi-022#4, et l'incohérence) | incohérence | **corrigé** | Chaque alias de nom dont un statut dépend est écrit dans K (`identite_documentaire`) : 009, 010, 013, 015, 017, 022, 023 et 024. La source est le synset WordNet et ses lemmes, avec la forme française par WOLF ; `sens_fr.py` confirme par exemple Jérôme → jerome%1:18:00:: et Pierre → peter%1:18:00::. Pour les noms sans synset (Tobie, Agar, Ismaël, la forme latine Nicolaus), l'alias est `attestee: false`, et le statut porte l'hypothèse `identite` (001, 005#3, 017). La question « K:cle_de_nom normalise-t-il entre les langues ? » reste dans les `decision_ouverte` de 001 et 017. |
| sens et contexte (pi-012) | incohérence | **corrigé** | pi-012 a maintenant une `decision_ouverte` (`tous_les_sens`, `sens_fixe_par_le_contexte`). Le statut retenu, `etablie_sous_hypotheses [sens]`, est celui de `tous_les_sens` : dragon%1:05:02:: (le lézard) n'atteint pas imaginary_creature, ce que les pointeurs `@` de WordNet confirment. La négation « is not asleep » (#4) porte sur un adjectif à trois sens (sommeil, mort, engourdi) : elle n'est que possible, et passe d'`ecartee` à `inconnue`. |
| pi-005, pi-014, pi-020, pi-022 : pas de variante de statut différent par portée, modalité, temps ou inversion | qualité (forme) | **corrigé** | Changement de modalité par un nom nié, qui ne dépend d'aucun sens (D24) : pi-005#6 (en anglais : « not Hagar and Ishmael »), `ecartee` ; pi-014#6 (« is not John the Evangelist »), `ecartee` ; pi-022#7, nouvelle (« n'est pas Judith »), `ecartee`. Pour pi-020, le changement de temps (#6) donne maintenant un statut différent du cas de base (`inconnue` contre `etablie_sous_hypotheses`). |

Aucun désaccord n'est contesté. La relecture déclarait conformes deux statuts, pi-011 et pi-016 (`ecartee`). Ils sont
pourtant affaiblis par le § 4.1 (voir 2.1) : ce changement vient de la règle nouvelle, non d'un désaccord.

## 2. Les autres changements faits par le § 4.1

### 2.1 Le régime des sens, pour les négations

- **pi-011, et #1, #2, #5 :** d'`ecartee` à `inconnue`, avec une `decision_ouverte` (`tous_les_sens` : `inconnue` ;
  `sens_fixe_par_le_contexte` : `ecartee`). La négation de « voir » ou « see » n'est certaine que si chaque sens du
  prédicat demandé est inclus dans chaque sens du verbe nié. Ce n'est pas le cas.
- **pi-016, et #1, #2, #5, #6 :** même chose pour « hold ».
- **pi-021#6** (« does not hold ») : d'`ecartee` à `inconnue`.
- **pi-003#4 :** la variante niait l'état (« n'est pas endormi », un mot polysémique). Elle nie maintenant le nom
  (« le dormeur n'est pas saint Martin »). Une clé de nom n'a pas de sens, et le statut reste `ecartee`.
- **pi-024 (`ecartee`) et pi-002 (`ecartee`) sont gardés.** Le premier nie un nom, ce qui ne dépend d'aucun sens. Le
  second repose sur une distinction dite.

### 2.2 Le régime des sens, pour les liens positifs

- **pi-021 :** « Judith » a aussi le sens du livre, judith%1:10:00::, qui n'atteint pas woman. Le cas passe à
  `etablie_sous_hypotheses [sens]`, avec une `decision_ouverte`.
- **pi-021, la définition :** elle ne demande plus « a severed head » mais « a head ». Ce pas n'était pas l'objet du cas,
  et aucun mot français de WOLF n'atteint sever. La composition « objet résultant » est donc retirée de ce cas. Le pas
  préiconographique, Judith ⊑ woman, est gardé.

### 2.3 Les connaissances et les sources

- **Les connaissances typiques ne sont plus marquées `attestee: true`.** Aucune ressource n'a été consultée pour elles.
  Cela touche 014, 015, 016, 017, 020 et 022.
  - L'abduction ne demande pas d'attestation (FONDEMENTS § 2.7), et les statuts `etablie_sous_hypotheses` sont gardés.
- **Les implications de WordNet ont un `source`**, avec les pointeurs vérifiés dans `data.noun` :
  - pi-012 : dragon%1:18:02:: @ mythical_monster @ monster @ imaginary_creature ;
  - pi-021 : judith%1:18:00:: @i heroine%1:18:00:: @ woman%1:18:00::.
- **pi-014 :** l'entrée « relation inconnue » devient une `distinction_documentaire`, de source deux synsets d'instance :
  john%1:18:00:: et john_the_baptist%1:18:00::.
  - Une entrée `relation_inconnue` reste. « St. John » est un lemme de l'Évangéliste ; la `decision_ouverte` a une option
    de plus : `etablie` si les co-lemmes d'un synset valent alias.
- **pi-017 :** l'inscription demande l'extension `contenu_d_inscription`. Le statut de base passe d'`etablie` à
  `etablie_sous_hypotheses [identite, sens]`, car l'alias latin n'est pas attesté.
- **pi-017#4 :** l'étiquette de restaurateur passe de `non_certifiee` à `inconnue`. La lecture est ambiguë entre une
  source citée et un titre, et le plus prudent est `inconnue` (§ 4.1).
- **`extensions_requises` est maintenant écrit sur les variantes qui demandent plus que leur cas :**
  - 009#3, 010#3, 014#3, 015#3, 016#3 ;
  - 017#3, 018#3, 019#5 ;
  - 020#3, 020#6, 021#3, 022#4.
- **Les incompatibilités :** aucun cas n'en dépend. Les contre-modèles reposent sur une distinction dite, une négation
  ou une portée.

## 3. Harmonisation (BANCS § 4.1, point 2, « Ce que D30 dit exactement »)

**La méthode.**
- **Pour chaque mot français dont un atome dépend,** les sens WOLF ont été lus avec `sens_fr.py`. J'ai vérifié, sens
  par sens, que le lemme anglais de la définition est dans le synset ou dans un hyperonyme (`@`, `@i` de `data.*`), avec
  un petit script de contrôle tenu hors du dépôt.
- **Pour un mot anglais :** quand c'est le même lemme des deux côtés, le lien est certain.
- **Le résultat :** presque tous les mots français ont au moins un sens WOLF qui n'atteint pas le lemme anglais (fiel,
  œil, guider, manteau, salle, tableau, lion, tenir, voir, signifier, ville…). Tout cas français positif devient donc
  `etablie_sous_hypotheses [sens]` sous `tous_les_sens`. Il porte une `decision_ouverte` (`sens_fixe_par_le_contexte` :
  le statut antérieur), au niveau du cas ou de la variante.
- **Une exception :** pi-007#3 (« le Christ en croix entre les deux voleurs »). Christ, croix et voleur ont tous leurs
  sens qui atteignent le lemme, et il reste `etablie`.

**Les statuts changés par l'harmonisation, tous plus faibles,** d'`etablie` à `etablie_sous_hypotheses`, ou par une
hypothèse `sens` ajoutée :
- **cas de base :**
  - pi-013 et pi-019 : `etablie` → `etablie_sous_hypotheses` ;
  - pi-001, pi-015 et pi-017 : `etablie_sous_hypotheses`, avec `sens` en plus ;
- **variantes françaises de cas français :**
  - 001#2, 001#6 ;
  - 003#3 ;
  - 005#3 ;
  - 009#3 ;
  - 011#3 ;
  - 013#2, 013#5 ;
  - 015#2, 015#3, 015#5 ;
  - 017#2, 017#3, 017#5 ;
  - 019#2, 019#6 ;
  - 022#3, 022#4 ;
  - 024#6 ;
- **traductions françaises de cas anglais :**
  - 004#1, 006#1, 008#1, 010#1 : d'`etablie` à `etablie_sous_hypotheses [sens]` ;
  - 020#1 et 021#1 : `etablie_sous_hypotheses`, avec `sens` ajouté.
- **Aucun statut n'a été remonté par l'harmonisation.** Aucun cas ne traitait un mot de la définition comme un sens
  choisi. L'hypothèse `sens` de pi-012 et de pi-021 tient à un sens du mot du **texte** (dragon le lézard, Judith le
  livre), comme la règle le demande.

**Des mots absents de WOLF ont été remplacés** dans les descriptions françaises. Sinon l'atome n'avait aucun appui, ce
qui donnait `inconnue` et non une hypothèse :

| absent ou sans sens utile | remplacé par |
|---|---|
| songe | rêve |
| larron | voleur |
| festoyer | banqueter |
| fugacité | brièveté |
| pupitre (aucun sens vers desk) | bureau |
| cabinet de travail (aucun sens vers study) | bureau |
| couché | étendu |
| tendu de (aucun sens vers hang) | suspendu |
| la locution du verbe signifier | le verbe signifier |

**Où l'harmonisation demande de ne pas réécrire une définition, et ce que j'ai fait :**
- J'ai modifié les définitions de 001, 002, 005, 008, 013, 017, 019, 021 et 024. Ces cas testent un phénomène
  iconographique (narration, registres, tapisserie, nom, inscription, iconologie, lieu), non un pas lexical. Les pas
  retirés étaient des erreurs de la version 1 (des inclusions fausses dans WordNet) ou des mots sans équivalent dans
  WOLF.
- Les pas lexicaux que des cas testent sont gardés, avec leur statut prudent : Judith ⊑ woman (pi-021) et
  dragon ⊑ imaginary_creature (pi-012).
- **C'est un choix discutable**, que je signale : il revient à la propriétaire de dire si ces définitions devaient garder
  leurs pas.

**Ce qui en résulte pour la mesure métamorphique.**
- Les traductions entre un texte français et un texte anglais n'ont plus le même statut : `etablie_sous_hypotheses
  [sens]` d'un côté, `etablie` de l'autre. Cela vaut pour 001, 004, 006, 008, 010, 013 et 019.
- L'écart vient de la polysémie de WOLF, non de la sémantique. Il disparaît sous l'option `sens_fixe_par_le_contexte`.
- La relation « traduction : même statut » de QUALIFICATION § 2.2 doit être lue sous cette option, sinon elle comptera
  ces écarts comme des violations.

## 4. Les chiffres

- **Les cas de base, par statut :** `inconnue` 10, `etablie_sous_hypotheses` 8, `etablie` 4, `ecartee` 2.
- **Les cas de base, par sorte :** positif 12, contre-modèle 5, indéterminé 4, négatif 3.
- **Les statuts changés depuis la version 1** (cas et variantes, révision et harmonisation) : 41 plus faibles, 7 plus
  forts.
  - Les 7 plus forts : pi-020 et ses variantes #1, #2, #4 et #5, à cause de la concurrente retirée ; pi-005#6 et
    pi-014#6, qui sont des variantes remplacées.
  - pi-022#7 est nouvelle.
- **Les `decision_ouverte` :** 6 cas en version 1 ; 13 cas et 12 variantes après.
- **Le validateur :** `24 cas de base, 145 variantes, 0 erreurs` ; `phenomenes_iconographiques : 24 cas, composés ≥2 :
  24, ≥3 : 12`.
