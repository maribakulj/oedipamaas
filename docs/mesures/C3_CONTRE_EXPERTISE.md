# Contre-expertise des transformations de la PR #16 (C3)

La propriétaire a suspendu la PR maribakulj/oedipamaas#16. Son rapport, `docs/mesures/C3_CORRECTIONS.md`, se trouve sur
la branche de cette PR. Elle demande une contre-expertise de ses transformations sémantiques. La question n'est pas
d'ajouter des exceptions aux règles, mais de savoir **si les opérations elles-mêmes sont fondées**. Il faut garder les
corrections indépendantes qui sont justifiées, ainsi que tous les résultats expérimentaux.

Ce document juge les six opérations visées, trie les autres corrections de #16 et mesure la branche qui ne garde que
les corrections fondées.

## 1. La méthode

**Le critère : la forme commune.** La canonisation commune des descriptions et des libellés est la forme du guide du
banc (`docs/BANC_GRAPHES.md`, guide des annotateurs). C'est elle que les graphes de référence suivent.
- Un participe de posture ou d'action en cours (« a kneeling man ») est un événement.
- Un participe d'état résultant (« a broken sword », « crowned ») est une propriété.
- Un participe qui a son propre complément (« crowned with laurel ») est un événement.
- `patient` est ce qui est changé ; `theme` ce qui est déplacé, tenu, porté ou placé. Le sujet d'une posture est
  `agent`.
- Un nom d'action est un événement. Un nom d'action sans verbe usuel garde le nom.
- Un nom en apposition de matière ou d'espèce (« a stone bridge ») est une propriété. Un composé que le dictionnaire
  donne comme une unité reste une unité.

Une opération du compilateur qui donne aux libellés une autre forme ne peut pas rencontrer les graphes qui suivent
le guide.

**Les sites.** Un site est une partie de libellé où une opération de #16 change quelque chose.
- `outils/mesure/sites_c3.pl` parcourt toutes les parties de libellés de la base (139 092, dans les deux langues). Il
  applique chaque opération de #16 **seule** aux conditions lues sans les corrections, et note ce qu'elle change.
- Il tourne sur une copie de la branche de #16 (`54805da`) et appelle ses prédicats internes.
- 28 356 sites sont trouvés : `contre_expertise/sites_pr16.jsonl` sur la branche de données.

**Les échantillons.** Un même libellé revient souvent : le gabarit « saint writing, studying, teaching, dictating » est
recopié pour chaque saint. Les sites sont donc réduits aux **libellés distincts** avant le tirage, et les deux comptes
sont donnés.
- Le tirage est fait à graine fixe (20261127) par `outils/mesure/echantillonner_c3.py` : 30 libellés par opération
  principale, 15 pour les autres.
- Chaque cas est jugé à la main contre le guide : juste, faux ou indécidable. Les jugements sont dans
  `contre_expertise/jugements.json`, avec la raison de chaque cas faux.
- Ce sont des décisions d'agent, **provisoires**.

**Les contrôles systématiques.** Ils portent sur tous les sites, non sur un échantillon, et chacun repose sur une
ressource indépendante de #16 :
- `roles_verbnet.py` : les rôles que VerbNet 3.3 donne au sujet et à l'objet de chaque verbe, ramenés aux rôles du
  guide ;
- `actions_sens_c3.pl` : les sens de WordNet et de WOLF des noms d'action, et ceux qui sont des actions liées au
  verbe ;
- `composes_c3.pl` : la lexicalisation des composés et la classe lexicale des modifieurs ;
- `coherence_c3.py` : ce que les graphes du banc écrivent là où #16 réécrit les requêtes.

## 2. Les six opérations

### 2.1 Le participe présent assimilé à un agent

**Ce que fait #16.** `participes/5` (`requetes_iconclass.pl`) prend une propriété dont le mot est, dans l'analyse du
libellé, un VERB `VerbForm=Part`. Si le participe est au présent (`Tense=Pres`), elle en fait un événement dont le
porteur est l'**agent** ; sinon le **patient**.

**Les sites.** 682, soit 205 libellés distincts.

**L'échantillon** (30 libellés distincts) : **26 justes, 4 faux**.
- Les justes sont des actions agentives : écrivant, baptisant, dansant, priant, combattant, pillant.
- Les quatre faux ont un sujet non agentif. Trois sont des inaccusatifs ou des verbes d'émission : « jouets
  tournant », « puits jaillissant », « rod flowering ». Le quatrième, « feu dévorant », est un adjectif, avec un lemme
  faux (« dévoir »).

**Le contrôle par VerbNet** (anglais, libellés distincts) :
- 14 justes : le sujet n'est jamais qu'agent ;
- 25 ambigus : agent dans une classe, autre chose dans une autre ;
- 4 faux : jamais agent.

Le temps du participe ne dit pas le rôle : c'est la structure argumentale du verbe qui le dit. Le guide le dit aussi :
« le participant unique est l'agent ou le thème selon le verbe ».

**Verdict : fondée seulement sous une condition vérifiable.** Le participe présent épithète ou apposé dit bien une
action en cours, donc un événement, comme le veut le guide. Mais son porteur n'est l'agent que si le verbe est
agentif.
- La condition se vérifie dans une ressource de structure argumentale : en anglais, VerbNet donne le rôle agent au
  sujet dans toutes les classes du verbe.
- Sinon, le rôle n'est pas décidable sans le sens du verbe, ce qui est la désambiguïsation (X7).
- En français, il n'y a pas de ressource locale (Verb∋Net n'est pas installé). La condition n'est pas vérifiable : la
  requête doit rester partielle.
- Un participe que la langue lexicalise comme adjectif (« dévorant », « shining ») est une autre lecture : elle relève
  de la même désambiguïsation.

### 2.2 Le participe passé assimilé à un patient

**Ce que fait #16.** La même règle, au passé : un événement, et le porteur comme **patient**.

**Les sites.** 5 142, soit 2 967 libellés distincts.

**L'échantillon** (30 libellés distincts) : **6 justes, 21 faux, 3 indécidables**. Les fautes sont de trois sortes,
qui tiennent toutes à l'opération elle-même :
- **l'état résultant :** l'homme guéri, la tête coupée, drawn sword, glazed verandah, la main paralysée. Le guide écrit
  une propriété, et #16 un événement : la requête ne rencontre plus le graphe ;
- **la posture :** assis, agenouillée. Le guide écrit un événement dont le sujet est l'**agent** ;
- **le déplacé, le placé, le tenu :** placed on a bier, gardés à l'intérieur, dissimulé dans, dressée. C'est un `theme`,
  non un patient.
- S'y ajoutent une figuration (« represented as », que le guide ne compte pas comme un événement) et une modalité
  perdue (« cannot be hid »).

**Le contrôle par VerbNet** (anglais, libellés distincts, l'objet pour un verbe transitif, le sujet sinon) :
- 199 justes ;
- 344 ambigus ;
- **471 faux**, où VerbNet ne donne jamais le rôle patient (crown, place, keep, send, bless, represent…) ;
- 50 hors de VerbNet.

**Verdict : non fondée.** Le participe passé ne dit ni qu'il y a un événement (l'état résultant est une propriété), ni
le rôle du porteur (patient, theme, ou agent pour une posture).
- Ce qui serait fondé à la place, et vérifiable :
  - **l'événement** seulement quand le participe a son propre complément dans l'analyse (`obl`, `obj`, complément
    d'agent), ou quand il est un passif verbal (avec un auxiliaire), comme le dit le guide ;
  - **le rôle** de l'objet donné par la structure argumentale du verbe (VerbNet), quand elle est univoque ;
  - sinon, **la propriété du lecteur, telle quelle**, qui est la forme du guide pour un état.
- Ce n'est pas une liste d'exceptions : ce sont les conditions du guide, que le compilateur peut lire dans l'arbre et
  dans une ressource.

### 2.3 La coordination ou l'énumération assimilée à une disjonction

**Ce que fait #16.** `enumeration/2` reconnaît une liste à virgules sans verbe conjugué ni nom propre, dont chaque
segment a une tête. Une scène à une seule partie devient la disjonction de ses segments (`alternatives/7`), comme
une classe ; de même les aspects d'une personne (`requete_de_partie/4`).

**Les sites.** Scènes : 847, soit 682 libellés distincts. Aspects : 9 146, soit 321 libellés distincts.

**Les échantillons :**
- **scènes (30 libellés distincts) : 17 justes, 13 faux ;**
- **aspects (15) : 12 justes, 3 faux.**

Les justes suivent la convention des libellés d'Iconclass : une liste de termes énumère ce que la notation couvre
(« mist, fog », « rugby, football », « avenue, boulevard, promenade, esplanade », « crown, leper, ring, sceptre » pour
les attributs possibles d'un saint).

Les faux sont de trois sortes :
- **le matériel partagé (8 scènes, 2 aspects) :** un argument ou un modifieur porte sur toute la liste.
  - Exemples : « discovery, finding *of witch* », « administering, taking *medicine* », « *accident with* wagon,
    freight wagon, cart », « destruction, détérioration *environnementale* ».
  - Le premier segment, pris seul, ne dit pas la notation : la requête devient trop faible.
  - C'est l'ambiguïté de portée de la coordination ([A, B] of C, ou A, [B of C]), que la syntaxe seule ne tranche pas.
- **la coordination conjonctive (3) :** « martyr taken before a heathen ruler, and refusing… » décrit le même martyr ;
  « debout sur une jambe, l'autre jambe tenue sur le côté » est une seule posture.
- **les listes d'exemples et les alternatives internes (2 scènes, 1 aspect) :** « des souliers, du riz » après
  « p.ex. » ; « l'alcool, des drogues ou des stimulants » ; « standard with chi-rho monogram or cross ».

**Verdict : fondée seulement sous une condition vérifiable.** La disjonction est la bonne lecture d'une liste de
**désignations complètes et parallèles**.
- La condition se lit dans l'arbre : chaque segment est un constituant de même catégorie, sans dépendant qu'un autre
  segment pourrait partager. Aucun segment n'a de complément ou de modifieur placé à une extrémité de la liste, où sa
  portée est ambiguë ; aucun segment n'est verbal (une coordination de prédicats sur le même participant est
  conjonctive).
- Hors de cette condition, la portée n'est pas décidable par la syntaxe : la requête doit rester partielle.
- #16 ne vérifie que l'absence de verbe conjugué et de nom propre, ce qui ne suffit pas.

### 2.4 La nominalisation déterminée par le premier sens lexical

**Ce que fait #16.** `actions/5` et `verbe_d_action/4` traitent une requête réduite à `type(x, N)`.
- En anglais : si le **premier sens** de N dans WordNet est une action (noun.act, noun.event, noun.process,
  noun.phenomenon) et que N est la nominalisation d'un verbe V, la requête devient `evenement(x, V)`.
- Pour un gérondif : si V se déduit de la forme par une règle de suffixe.
- En français : si le sens de WOLF dont les mots anglais ont le plus d'occurrences annotées est une action.

**Les sites.** 1 062, soit 423 libellés distincts.

**L'échantillon** (30 libellés distincts) : **23 justes, 5 faux, 2 indécidables**.
- Les justes sont des activités : bleaching, angling, sailing, inspection, divorce.
- Les cinq faux :
  - quatre noms polysémiques dont le libellé ne dit pas l'acte : occupations (un métier), smoke (la fumée), snow (la
    neige), Obedience (une vertu) ;
  - un nom d'action sans verbe usuel, « bataille » → batailler, alors que le guide garde le nom.

**Le contrôle systématique** (`actions_sens.json`, 423 libellés distincts) :
- **univoques : 179** (144 en anglais, 35 en français). Tous les sens du nom sont des actions liées au verbe ;
- **polysémiques : 198** (142 en anglais, 56 en français). Au moins un sens n'est pas une action : le premier sens,
  ou en français le plus fréquent, décide à la place du libellé ;
- **sans lien : 46** (anglais). Le verbe vient de la règle de suffixe du gérondif, sans lien lexical.

L'ordre des sens de WordNet suit la fréquence d'annotation dans SemCor : c'est une statistique, non une sémantique.
D30 l'a établi pour le noyau : un lien n'est certain que s'il vaut pour tous les sens.

**Verdict : non fondée telle qu'implémentée. L'opération elle-même (nom d'action ↔ événement) est fondée,
sous deux conditions :**
- elle porte sur **des sens**, non sur un mot : l'équivalence n'est certaine que si tous les sens du nom sont des
  actions reliées au verbe (179 cas sur 423), et sinon elle est une hypothèse de sens, au même titre que D30 ;
- elle s'applique **des deux côtés** (§ 2.6).

Un nom d'action sans verbe usuel garde le nom (guide). La règle de suffixe sans lien lexical n'est pas une
connaissance.

### 2.5 La composition nominale assimilée à une propriété

**Ce que fait #16.** `composes_syntaxiques/5` traite un nom modifieur (`compound` dans l'analyse) qui n'a pas d'autre
condition : il devient une **propriété** de sa tête (« card{trade} »). Ensuite, `composes/2` réunit la propriété et la
tête en un seul type quand la langue lexicalise le composé, sous trois graphies : « M H », « MH », « M-H ».

**Les sites.** 3 155, soit 1 392 libellés distincts.

**L'échantillon** (30 libellés distincts) : **12 justes, 15 faux, 3 indécidables**.
- Les justes :
  - les composés lexicalisés, que `composes/2` réunit : opera house, water polo, mouth organ, patron saint ;
  - les matières : stone tablets, linen girdle.
- Les faux sont les autres relations implicites :
  - partie ou lieu : city wall, church interior ;
  - thème : fruit harvest, film explicator ;
  - but : circumcision set, bulb field ;
  - et des erreurs d'analyse.

**Le contrôle systématique** (`composes.json`, 1 448 paires distinctes modifieur–tête, en anglais) :
- **lexicalisés : 344 (24 %)**, un seul concept : une équivalence lexicale ;
- **matière ou espèce dans tous les sens du modifieur : 44 (3 %)**, la propriété du guide ;
- mixtes : 231 (16 %), certains sens seulement ;
- **autre relation : 738 (51 %)**, aucun sens de matière ou d'espèce ;
- inconnus : 91 (6 %).

La relation implicite d'un composé nominal (matière, but, lieu, partie, agent, thème…) n'est pas dite par sa forme.
La réduire à une propriété affirme une relation que le libellé ne dit pas.

**La graphie soudée.** Pour un adjectif et un nom, elle donne un autre mot : « black bird » n'est pas « blackbird ».
#16 l'étend à tous les cas de `composes/2`.

**Verdict : non fondée, sauf deux cas.**
- **Le composé lexicalisé est fondé :** c'est une équivalence lexicale. Sa graphie soudée ou à trait d'union est fondée
  pour deux noms (« trade mark », « trademark »), non pour un adjectif et un nom.
- **La matière ou l'espèce** dans tous les sens du modifieur suit la forme du guide. Cette condition est vérifiable, à
  la manière de D30.
- **Ailleurs, la requête doit rester partielle.** Les deux variables sans lien du libellé lu font déjà dire `non_lie`
  au compilateur. La relation implicite est à fixer par la sémantique commune, non par une réécriture.

### 2.6 L'incohérence entre la canonisation des graphes et celle des requêtes

**Ce que fait #16.** Trois opérations ne touchent que les requêtes :
- D2 réécrit les noms d'action en événements ;
- D7 réécrit tous les participes en événements ;
- D3 réécrit les modifieurs en propriétés.

Le lecteur, lui, n'est pas changé.

**La mesure** (`coherence.json`, les deux jeux du banc) :
- **Les noms d'action.** Les graphes de référence écrivent 227 événements à nom d'action, selon le guide. Sur les
  mêmes textes, le lecteur écrit **l'entité de ce nom dans 219 cas** et l'événement dans 18. Une requête réécrite en
  événement ne rencontre donc pas le graphe du lecteur, dans 96 % des cas où le texte le dit.
- **Les participes.** Les graphes de référence gardent environ 250 propriétés de participe (compte approché, par la
  terminaison) : ce sont les états du guide. Le lecteur écrit 233 propriétés dont le mot est un verbe. Une requête qui
  en fait des événements ne rencontre ni l'une ni l'autre.
- **Ce que l'expérience croisée en a vu.** Dans #16, la variante de négation de 47G3355 cesse d'être un faux positif.
  Le rapport de #16 l'attribue lui-même à un effet de forme : la requête dit `evenement(upholster)`, et le lecteur
  garde l'entité « upholstering ». La sûreté n'a pas changé. La même cause fait perdre la notation à un texte positif
  qui la dit.

**Verdict : non fondé.** Une canonisation n'est une canonisation que si elle s'applique des deux côtés, ou si elle
réécrit les deux côtés vers une même forme. Réécrire un seul côté crée deux formes, et des succès ou des échecs dus à
la forme. C'est le principe de la canonisation commune (`docs/EXPERIENCES_C7.md`, § 1), et l'expérience contrôlée
(`docs/INFERENCES.md`) l'applique comme alignement des deux côtés.

### 2.7 Les rôles des sujets partagés (une opération voisine)

**Ce que fait #16.** `sujets_partages/4` traite deux verbes coordonnés quand le second n'a pas de sujet. Il prend le
sujet du premier, comme **patient** si le second est un passif, comme **agent** sinon.

**Les sites.** 482, soit 450 libellés distincts.

**L'échantillon** (15 libellés distincts) : **10 justes, 2 faux, 3 indécidables**. Les deux faux sont « fleuri » (un
thème) et « driven away » (un thème).
- Partager le sujet dans une coordination de prédicats est fondé : c'est la syntaxe.
- Le rôle par la voix ne l'est pas, pour la même raison qu'au § 2.2.

**Verdict : fondée pour le partage, non fondée pour le rôle**, qui relève de la structure argumentale du verbe,
comme au § 2.1.

## 3. Les autres corrections de #16

| correction | où | jugement | gardée |
|---|---|---|---|
| D4 : le singulier d'un lemme pluriel que la langue ne connaît pas (« organes » → organe sexuel) | `singulier/3`, `mots_non_couverts/4` | une normalisation morphologique, appliquée seulement si le pluriel est inconnu et le singulier connu ; aucune lecture sémantique | oui |
| D5 : en français, la tête d'un gabarit est le mot que le libellé nomme après « : » (« fusée », non « eruca sativa ») | `tetes_du_nom/4`, `terme_francais/2` | le libellé dit lui-même son terme ; les mots de WOLF pour tous les sens anglais du nom n'en sont pas | oui |
| D6 : le genre d'un gabarit qu'aucun sens du nom n'atteint dans K n'est pas exigé, et la requête est partielle | `genre_compatible/3` | une conjonction insatisfaisable par construction ; la raison rend la requête partielle, jamais compilée | oui |
| D8 : la glose d'une personne (« the schoolmaster, martyr and bishop, Cassian of Imola ») n'est pas une condition ; la personne est donnée par ses noms | `compiler_/7`, `glose/2` | la glose identifie la personne, elle ne dit pas ce que l'image montre | oui ; les aspects sont ceux de main, sans la disjonction de D1 |
| le complément du nom de forme génitive que l'analyseur n'a pas relié (« contrôle des naissances ») | `complements_non_lus/5` | la réparation d'une erreur d'analyse, par la relation littérale « de », la forme du lecteur. Échantillon : 14 justes sur 15 ; le faux est « à propos des possessions », dont la préposition est « à propos de » | oui |
| la pluralité distincte (« différents mammifères ») rend la requête partielle | `mots_non_couverts/4` | une garde : les requêtes ne comptent pas les référents | oui |
| l'ellipse : un segment qui a son propre modifieur ne reprend pas le contexte ; en français, le contexte avant est ce qui précède la tête | `definitions.pl` | la reconstruction d'une ellipse ne vaut que pour un segment réduit à sa tête ; en français, les modifieurs suivent la tête | oui |
| D3 : la graphie soudée dans `composes/2` (« black bird » → blackbird) | `compose_de/3` | non une équivalence pour un adjectif et un nom (§ 2.5) | non ; gardée seulement pour deux noms, dans le composé lexicalisé |
| D7 : le complément de matière (« of brass » : aussi propriété) | `matieres/3` | dépend du premier sens (« substance ») ; en français, d'une condition sur les sens qui n'est pas celle de D30 | non |
| D7 : les participes, D1 : les énumérations, D2 : les noms d'action, D3 : les modifieurs en propriétés, les rôles des sujets partagés | § 2 | non fondés tels qu'implémentés | non |
| la garde de 68aeb3f (l'exemption de `evenement_sans_participant`) | `raison/5` | n'existe que pour annuler une exemption ajoutée par 9a1f61d : main a déjà la règle sans exemption | sans objet |
| la garde de 54805da (un gérondif de liste reste une alternative) | `enumeration/2` | dépend de D1 | non |

## 4. La branche `claude/c3-corrections-fondees`

Elle part de main (`18638de`) et ne garde que les corrections du § 3 marquées « oui », avec le composé lexicalisé du
§ 2.5 (`composes_lexicalises/5`).

**Les tests** (`tests/plunit/test_compilateur.pl`) :
- chaque correction a son test, et 15 tests échouent sur le code de main ;
- deux tests de non-régression gardent ce que la contre-expertise écarte : un composé non lexicalisé n'est pas changé
  en propriété, et un adjectif et un nom ne sont jamais soudés ;
- toutes les suites pytest et plunit passent.

**La mesure.** Les mêmes outils que #16 (`outils/mesure/c3_corrections.sh`, `resumer_c3.py`), sur les mêmes jeux :
avant (main `18638de`) et après (cette branche).

Les sorties sont dans `contre_expertise/avant/` et `contre_expertise/apres/`, et le résumé dans `resume.json` ;
`outils/mesure/transitions_c3.py` donne les transitions fiche par fiche.

**Les statuts de compilation** (200 fiches par jeu) :
- compilées : 48 → 49 en développement, 41 → 46 en validation ;
- partielles : 84 → 83, et 92 → 87.

**La comparaison aux requêtes de référence :**
- exactes : 19 → 20 en développement, 21 → 24 en validation.
- **Compilées et trop faibles,** les requêtes dangereuses : **2 → 1** en développement, et 2 → 2 en validation.
  - En développement, celle de 49E39311(PELICAN) devient partielle par D6.
  - Les deux de validation (31B6263, 45M2) existaient avant les deux branches.

Les transitions, jugées une à une :
- **devenues exactes :**
  - 31A22361 (« organe sexuel » : D4, puis le composé de WOLF) ;
  - 23U23 « water clock », 41D14 « fashion designer » et 46C151 « rack railway » (le composé lexicalisé) ;
  - 31A532 (partielle → compilée) ;
- **devenues plus fortes, jamais plus faibles :** 25F35(PEACOCK) et 25F37(WOODCOCK). La tête française nommée par le
  libellé, avec son genre, passe d'« incomparable » à « trop forte » ;
- **devenues partielles,** donc jamais qualifiées : 46E43(ROCKET) (le genre inatteignable, D6), 49E39311(PELICAN) ;
- **devenues compilées sans requête de référence pour les juger** : 26C21, 45A231 (le complément relié), et 44G1231
  « croix sur la place du marché », incomparable. C'est la lecture littérale « place de marché » ; la forme commune de
  « place du marché » reste à fixer.

**L'expérience croisée** (positifs ; établis déductivement / sous hypothèses) :

| jeu | condition | avant (main) | après (cette branche) | #16 |
|---|---|---|---|---|
| développement | lecteur, compilée | 2 / 0 | 4 / 0 | 4 / 0 |
| développement | référence, compilée | 2 / 0 | 3 / 0 | 4 / 0 |
| validation | lecteur, compilée | 1 / 1 | 1 / 1 | 0 / 2 |
| validation | référence, compilée | 0 / 1 | 0 / 1 | 0 / 1 |

- **Les conditions à requête de référence ne changent pas,** ni les négatifs, les indéterminés et les variantes.
- **Aucune interruption, aucune erreur,** avant comme après.

Chaque établissement qui change :
- **42A111** (contrôle des naissances, contraception), dans les deux conditions à requête compilée : un vrai gain,
  qualifié `etablissable`. C'est le complément relié et le contexte français de l'ellipse : le même gain que #16.
- **46E43(ROCKET),** lecteur : la requête partielle `type(x, fusée)` est établie, qualifiée `candidat`. Ce n'est pas un
  gain : elle est partielle.
- **Ce qui ne change pas :**
  - le succès fortuit de 46B355 (« trade card ») demeure : le composé n'est pas lexicalisé, il reste en deux variables
    et la requête reste partielle, qualifiée `candidat` ;
  - le faux positif du lecteur sur la variante de négation de 47G3355 demeure. C'est une faute de sûreté du lecteur
    (`docs/mesures/SURETE_LECTEUR.md`, option `negations`). #16 ne la cachait que par une différence de forme (§ 2.6).
- **Ce que #16 avait de plus,** et que cette branche n'a pas :
  - 11H(CASSIAN)32, établie par une requête partielle (`candidat`) ;
  - la disparition des succès fortuits ou faux de 46B355 et 47G3355, obtenue par des réécritures d'un seul côté.

**En somme :** les corrections fondées gardent le seul gain qualifié de #16 (42A111), retirent une requête dangereuse
et rendent cinq requêtes compilées et exactes, sans aucun effet de forme.

## 5. Limites

- **Les jugements sont ceux d'un agent,** contre le guide, sur des échantillons de 15 à 30 libellés distincts par
  opération. Les contrôles systématiques (VerbNet, sens de WordNet et de WOLF, lexicalisation, classes lexicales) n'en
  dépendent pas, mais VerbNet n'est pas le guide :
  - son rôle `Theme` pour « crown » contredit l'exemple du guide (« couronné » : patient) ;
  - VerbNet ne couvre pas le français.
- **Le compte des participes de la référence est approché,** par la terminaison.
- **Les conditions proposées au § 2 ne sont pas implémentées.** Elles demandent une représentation que la sémantique
  commune doit fixer d'abord : le rôle par la structure argumentale, la portée d'une coordination, la relation
  implicite d'un composé, la canonisation des noms d'action des deux côtés. Ce sont des questions de fondements, non
  des règles à ajouter au compilateur.
- **La mesure de #16 n'est pas refaite.** Ses sorties sont sur la branche de données, dans `c3_corrections/`.

## 6. Reproduction

C16 est une copie de la branche de #16 (`git archive origin/claude/c3-corrections`) ; VN est VerbNet 3.3 décompressé
(`ressources/verbnet-3.3.tar.gz`) ; D est le dossier des données, et O `D/c3_contre_expertise`.

```bash
swipl outils/mesure/sites_c3.pl C16/oedipamaas/socle BASE O/sites_pr16.jsonl
```

```bash
python outils/mesure/echantillonner_c3.py O/sites_pr16.jsonl O/echantillons.json
```

```bash
python outils/mesure/voir_echantillon_c3.py O/echantillons.json participe_patient
```

```bash
python outils/mesure/roles_verbnet.py VN O/sites_pr16.jsonl O/roles_verbnet.json
```

```bash
swipl outils/mesure/actions_sens_c3.pl BASE O/sites_pr16.jsonl O/actions_sens.json
```

```bash
swipl outils/mesure/composes_c3.pl BASE O/sites_pr16.jsonl O/composes.json
```

```bash
python outils/mesure/coherence_c3.py D/banc_graphes O/coherence.json
```

Les mesures avant et après, puis leur résumé :

```bash
COMMIT=18638de… bash outils/mesure/c3_corrections.sh BASE D O/avant
```

```bash
bash outils/mesure/c3_corrections.sh BASE D O/apres
```

```bash
python outils/mesure/resumer_c3.py O/avant O/apres --json O/resume.json
```

```bash
python outils/mesure/transitions_c3.py O/avant O/apres
```
