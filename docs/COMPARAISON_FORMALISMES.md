# La comparaison argumentée des formalismes (version 1, 27/11)

**La question posée.** Quels formalismes peuvent fonder la représentation sémantique d'oedipamaas ? Ce que chacun
permet de représenter, ce qu'il ne permet pas, et comment il pourrait contribuer au problème propre au projet : décider,
avec une preuve vérifiable, qu'une description satisfait une définition d'Iconclass.

**Ce sur quoi ce document s'appuie :**
- `docs/ETAT_DE_L_ART_SEMANTIQUE.md` : l'état de l'art, ses références vérifiées et son tableau comparatif ;
- `docs/AUDIT_EXPRESSIVITE.md` : ce que le langage actuel ne peut pas dire ;
- `docs/FONDEMENTS_SEMANTIQUES.md` : ce que la représentation doit garantir.

**Ce qu'il n'est pas.** Ni une prescription d'architecture, ni une liste de composants à intégrer. Il dit, pour
chaque extension que l'audit établit nécessaire, ce que la littérature offre et ce que nous en prenons, ou non, et
pourquoi.

## 1. La conclusion d'abord

Aucun formalisme ne résout le problème tel qu'il est posé. Il réunit trois choses que la littérature traite séparément :
- une **normalisation** (« la mort de X », « X meurt », « X est mort ») ;
- une **inférence définitionnelle et contextuelle** (« liquide doré pressé d'olives », huile) ;
- une **décision justifiée** sous incertitude lexicale et dans des contextes non factuels (ce qui est figuré n'est pas
  ce qui est vrai).

Le format actuel du projet est le bon substrat :
- un graphe néo-davidsonien plat, à assertions identifiées et qualifiées ;
- une logique à quatre valeurs ;
- des requêtes existentielles positives.

Les formalismes riches lui apportent des **morceaux précis**, non un remplacement :

| besoin établi par l'audit | ce que la littérature offre | ce que nous en prenons |
|---|---|---|
| la canonisation des états (chauve, calvitie) | états réifiés en éventualités (Parsons ; les états « kimiens » de Maienborn) | **décidé** (§ 3) : l'état réifié, distinct des propriétés ordinaires |
| l'ancrage temporel des événements | structure d'événement, état résultant, aspect (Moens et Steedman ; Pustejovsky ; le treillis d'aspect d'UMR ; Inchoative_of de FrameNet ; les post-situations d'ESO) | les **valeurs d'ancrage** (en cours, antérieur, imminent) et la relation événement → état résultant, avec deux statuts |
| les contextes de contenu et l'emboîtement des sources | boîtes de la DRT, dépendances modales d'UMR vers des « conceveurs », sémantique de la dépiction | des **contextes emboîtés**, avec la règle d'accessibilité de la DRT pour les référents |
| la classification par définition | logiques de description (EL), réécriture de requêtes | des **définitions de forme EL** (∃, ⊓, en arbre) dépliées dans les requêtes |
| les dérivations qui créent des référents | règles existentielles faiblement acycliques | la **condition de terminaison** imposée à l'ensemble des règles |
| l'abduction | abduction pondérée (Hobbs et al. 1993), programmation logique abductive (Kakas, Kowalski et Toni 1992) | des **hypothèses déclarées**, à coûts fixés, jamais certifiantes |
| les cadres et les rôles | FrameNet, VerbNet, PropBank, SemLink | des **connaissances** dans K (rôles, relations entre cadres), non un format |
| les niveaux de représentation | CIDOC CRM, ICON (Panofsky), structure d'Iconclass | un **alignement** pour l'interopérabilité ; la sémantique interne reste celle des contextes |

## 2. Les formalismes, un à un

### 2.1 La sémantique néo-davidsonienne (Davidson ; Parsons ; Dowty pour les rôles)

**Ce qu'elle permet :** un événement comme individu, des participants par rôles ; compter, qualifier ou nier un
événement sans nier ses participants. C'est déjà le langage actuel.

**Ce qu'elle ne permet pas, seule :**
- la portée des négations et des modalités ;
- le temps ;
- les contextes ;
- des rôles nets. Les proto-rôles de Dowty expliquent pourquoi patient et thème sont durs à séparer, et pourquoi la
  convention doit être fixée et non devinée.

**Ce que nous gardons :** tout. Le fondement ne change pas.

### 2.2 La DRT et la SDRT (Kamp ; Kamp et Reyle ; Asher et Lascarides)

**Ce qu'elle permet :**
- des référents de discours, et leur accessibilité, qui règle l'anaphore ;
- des boîtes emboîtées pour la négation, la modalité, le conditionnel et les attitudes ;
- la quantification.
- Boxer et le Parallel Meaning Bank en donnent des réalisations.

**Ce qu'elle ne permet pas :** le savoir lexical (death et die ne se rencontrent pas d'eux-mêmes) et l'inférence
définitionnelle. Ses outils de qualité sont pour l'anglais.

**Ce que nous prenons :** l'idée de **contextes emboîtés comme objets de premier rang**, et la règle d'accessibilité.
- Un référent introduit dans le contenu d'une vision n'est pas un référent du monde figuré.
- Une coréférence ne traverse pas une frontière de contexte de l'intérieur vers l'extérieur.
- C'est la généralisation des qualificatifs plats (`docs/FONDEMENTS_SEMANTIQUES.md`, § 2.5), sans adopter le langage
  complet des DRS.

**Ce que nous ne prenons pas :** la compositionnalité de Montague sous-jacente, et l'analyseur. La lecture reste celle
du projet.

### 2.3 MRS et la sous-spécification (Copestake et al. 2005 ; l'ERG)

**Ce qu'elle permet :** la portée sous-spécifiée des quantificateurs et des négations, résolue plus tard ; une grammaire
large de l'anglais.

**Ce qu'elle ne permet pas :** le français, à qualité comparable ; le savoir lexical.

**Ce que nous en tirons :** une leçon pour la **compilation des libellés**. Une portée ambiguë d'un libellé (« not »,
« each ») doit être gardée sous-spécifiée, puis résolue explicitement, ou rendue partielle. Elle ne doit pas être
tranchée par une heuristique. Aucun composant n'est adopté.

### 2.4 AMR, UMR, UCCA, DMRS et EDS (Banarescu et al. 2013 ; Van Gysel et al. 2021)

**Ce que l'AMR permet :** un graphe enraciné et typé, proche du nôtre, où une nominalisation va au verbe. Mais elle n'a
ni temps, ni portée des quantificateurs. Par Bos (2016), elle est décidable sans variables récurrentes, au prix de
l'expressivité.

**Ce que l'UMR ajoute :** l'aspect, un nœud de portée, des dépendances modales vers des conceveurs. C'est la
représentation en graphe la plus proche de ce que l'audit demande.

**Ce qui nous retient de l'adopter comme format :** ces outils ont peu d'analyseurs, presque rien en français, et des
annotations faites pour des phrases, non pour des définitions. Ils ne portent pas de preuves.

**Ce que nous prenons :** le **treillis d'aspect d'UMR** pour les valeurs de l'ancrage temporel, et ses dépendances
modales comme modèle des chemins de contextes. Ce sont des inspirations de conception, citées comme telles.

### 2.5 FrameNet, VerbNet, PropBank, NomBank, SemLink ; Dicovalence, LVF, le Réseau Lexical du Français

**Ce qu'ils sont :** des ressources, non des formalismes de vérité.
- Ils donnent les cadres, leurs éléments et leurs relations (Inheritance, Causative_of, Inchoative_of, Precedes) ;
- les classes de verbes et leurs rôles ;
- l'unification du nom et du verbe d'un même prédicat ;
- et, en français, les valences et les fonctions lexicales (S0, A0).

**Ce qu'ils ne permettent pas :** une inférence avec un statut.
- Une relation entre cadres ne dit pas si elle est une implication ou une connaissance typique.
- VerbNet contredit parfois la convention du banc. La contre-expertise de #16 en relève un cas (« crown »).

**Ce que nous prenons :** des **connaissances de K**, chacune étiquetée par sa sorte et sa direction de négation
(`docs/FONDEMENTS_SEMANTIQUES.md`, § 2.6), dans des modules séparés par licence. Ce sont des sources de règles
candidates, à mesurer famille par famille ; aucune n'est adoptée en bloc.

### 2.6 Le temps, l'espace, la cause, la méréologie (Allen ; RCC-8 ; ISO-TimeML et ISO-Space ; Simons ; Casati et Varzi)

**Ce qu'ils permettent :** des calculs complets de relations temporelles et topologiques, et une méréologie axiomatisée.

**Ce qu'ils ne permettent pas ici :** une image fixe ne donne pas d'intervalles. Ce que les libellés demandent est
l'ancrage au moment figuré, non une algèbre d'intervalles. Les calculs complets coûtent cher (Allen est NP-complet en
général).

**Ce que nous prenons :**
- une **méréologie minimale** : partie_de transitive, tout supposé ou impliqué selon la partie ;
- des **concepts de relation** pour les prépositions ;
- **rien des algèbres complètes,** tant que la narration continue est différée.

### 2.7 La modalité, les attitudes, la dépiction ; Belnap et les bitreillis

**Ce que permettent Kratzer et les mondes possibles :** la force et le fond conversationnel des modaux. Pour une image,
cette finesse n'est demandée par aucun libellé observé.

**Ce que dit la sémantique de la dépiction :**
- Zimmermann (2016), Abusch (2020) et Greenberg (2013, 2021) font du figuré un **contexte intensionnel**, comme la
  croyance ;
- le CIDOC CRM en fait une **relation extensionnelle** (P62 *depicts*, de portée E1).
- La portée « représente » du projet est une version plate et correcte de la première vue.
- **Une conséquence à fixer :** sous la portée du figuré, un nom désigne le personnage figuré, non l'individu
  historique. Les faits historiques (le lieu et la date de la mort d'Ignace) ne sont pas importés dans la scène. C'est
  une règle d'admissibilité, à écrire avec les contextes.

**Belnap (1977) et les bitreillis :** gardés tels quels. Les valeurs se calculent **par contexte et par énonciateur**,
puis s'agrègent. Une contradiction entre l'auteur et une source citée reste confinée, comme le noyau le fait déjà par
le type « documentaire ».

### 2.8 Les logiques de description et OWL 2 (Baader et al.)

**Ce qu'elles permettent :** la classification et la vérification d'instance, en monde ouvert, avec des complexités
connues.
- EL est polynomial, pour la subsomption comme pour les instances ;
- ALC est EXPTIME-complet pour la subsomption ;
- QL a une complexité AC0 en données pour la réponse aux requêtes.

**Ce qu'elles ne permettent pas :** les quatre valeurs, sans extension (il existe des logiques de description
paracohérentes, non outillées ici) ; les contextes. Et leur négation (ALC) est classique, non une négation de
l'auteur.

**Ce que nous prenons :** la **forme des définitions**. Une définition d'Iconclass ou une glose compilée comme concept
EL (genre ⊓ ∃rôle.différence, en arbre) se déplie dans une requête existentielle positive.
- Le dépliage est une réécriture de requêtes ;
- il termine si les définitions sont acycliques ;
- et la classification reste dans le fragment du noyau.
- La négation de la définition, si elle en a une, passe par `non/1`, c'est-à-dire par un appui négatif de l'auteur,
  jamais par l'absence.

### 2.9 Les règles existentielles et la terminaison

**Ce qu'elles permettent :** des règles qui créent des référents (une partie a un tout, un état a un événement qui
l'a causé), avec une **acyclicité faible** qui garantit la terminaison du chaînage.

**Ce que nous prenons :** la condition. L'ensemble des règles de déduction et d'abduction est vérifié faiblement
acyclique avant d'entrer dans K, ou il est borné en profondeur. La vérification est un test de K, à chaque version.

### 2.10 L'abduction (Peirce ; Hobbs, Stickel, Appelt et Martin 1993 ; Kakas, Kowalski et Toni 1992)

**Ce qu'elle permet :** des explications à coûts, des contraintes d'intégrité, une interprétation comme meilleure
explication.

**Ce qu'elle ne permet pas :** une justification au sens fort. Elle établit une plausibilité. Sa complexité est Σ2P
en général, et NP pour le cas de Horn.

**Ce que nous prenons :**
- des **hypothèses déclarées**, dirigées par la requête, à coûts fixés à l'avance, minimales et conjointement
  satisfaisables ;
- jamais un statut `etablie` ;
- **pas de statut intermédiaire** (décision du § 3) : une classification par une définition est déductive si la
  suffisance de la définition est établie, une hypothèse sinon.

### 2.11 Les ontologies d'événements et de situations (DOLCE et DnS ; SEM ; LODE ; ESO ; le calcul des événements)

**Ce qu'elles permettent :**
- les **descriptions** et les situations qui les satisfont, chez DnS : c'est exactement la relation entre une
  définition et une scène ;
- les pré- et post-situations, chez ESO ;
- les fluents, dans le calcul des événements.

**Ce qui ne nous convient pas :** ce sont des ontologies OWL, ou une logique avec négation par échec, pour le calcul
des événements. Ni l'un ni l'autre ne s'accorde avec un monde ouvert à quatre valeurs sans adaptation.

**Ce que nous prenons :** la distinction de DnS (une description, une situation qui la satisfait) comme vocabulaire
des fondements, et les post-situations d'ESO comme source candidate des conséquences d'état, à mesurer.

### 2.12 Le CIDOC CRM, ICON et la structure d'Iconclass

**Ce qu'ils offrent :**
- **le CRM** dit l'objet, son histoire, ce qu'il figure (P62), ce qu'il porte (P138) ;
- **ICON** formalise les niveaux de Panofsky ;
- **Iconclass,** dans sa documentation, dit qu'une notation « incorpore tous ses termes plus larges ».

**Ce que nous prenons :**
- **un alignement pour l'interopérabilité,** pour publier une preuve dans le vocabulaire du CRM, sans en faire la
  sémantique interne ;
- **l'héritage dans la hiérarchie,** à **typer** comme `docs/FONDEMENTS.md`, § 3.4 l'a établi.
  - Un enfant hérite d'une espèce, d'une personne ou d'un récit. Il n'hérite pas des conditions d'une rubrique : un lion
    n'a pas à montrer « earth as celestial body ».
  - La phrase de la documentation ne contredit pas ce typage : un terme plus large d'une rubrique ne pose aucune
    condition.

## 3. Les décisions de la propriétaire (27/11, quatrième message)

1. **La forme canonique des états : l'option B**, les états réifiés en éventualités, avec leur porteur, qualifiables,
   situés dans le temps et reliés aux autres éventualités.
   - **Pas indistinctement :** les propriétés ordinaires restent des propriétés, et on distingue les états, les
     processus et les événements de changement.
   - L'ontologie commune est étudiée avant la syntaxe : `docs/ONTOLOGIE_EVENTUALITES.md`.
2. **Aucun statut intermédiaire « par définition lexicale ».**
   - La provenance lexicale et le statut épistémique sont deux dimensions distinctes.
   - Une définition lexicalement attestée fonde une conclusion déductive si sa suffisance est établie ; sinon, elle
     reste une hypothèse (`docs/FONDEMENTS_SEMANTIQUES.md`, § 2.7).

Les autres questions ouvertes de l'état de l'art (§ 15) sont rangées par la trajectoire :
- la distributivité et le nombre : les bancs de la phase 1 ;
- la co-localisation dans une scène, et la narration continue : différées ;
- le « ~ » d'Iconclass : à confirmer auprès de la documentation complète ;
- la terminaison : un test de K (§ 2.9) ;
- le monde clos local d'« (other) » : la phase 3, avec `non/1`, borné aux notations sœurs ;
- le français : une mesure sur les descriptions françaises, non une décision a priori.
