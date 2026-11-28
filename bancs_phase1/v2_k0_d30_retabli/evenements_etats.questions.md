# Questions ouvertes : evenements_etats (événements, états, processus, situations)

Les points où les documents sont muets, ambigus ou se contredisent, rencontrés en écrivant les 24 cas `ee-001` à
`ee-024`. Pour chacun : ce qui est en cause, les cas concernés, ce que j'ai retenu, et pourquoi c'est provisoire.

## A. La négation et la polysémie

**A1. Les « sens admis » d'une occurrence niée : par le texte, ou tous ceux de K ?**
- NOYAU § 2 (D30) : une négation n'est certaine que si chaque nœud du type demandé est inclus dans **chaque** sens
  conceptuel du mot nié ; sinon elle n'est que possible et ne réfute rien. « Dead » a 17 sens, « broken » 13, « nu »
  et « weep » moins, mais tous plus d'un.
- BANCS_PHASE1 § 4 : une hypothèse de sens ne figure que si le texte laisse les sens ouverts ; NOYAU § 2 renvoie la
  désambiguïsation selon le contexte à C7.
- Lu à la lettre, D30 rend `inconnue` presque toute négation d'un adjectif d'état (« the king is not dead »), parce que
  « dead » a le sens « very tired ». J'ai retenu `ecartee`, en tenant le sens pour fixé par le contexte (« his eyes are
  open »).
- Cas : `ee-003` (base et variantes), `ee-024` (base), les variantes niées de `ee-001`, `ee-002`, `ee-005`, `ee-007`,
  `ee-008`, `ee-014`, `ee-015`, `ee-022`. Si D30 prévaut, tous ces `ecartee` deviennent `inconnue`. C'est l'option
  la plus faible, et je ne l'ai pas prise, faute de savoir qui fixe les sens admis : la lecture, ou K.

**A2. Pas d'incompatibilité (antonymie) dans les sortes de connaissances.**
- « Intact » et « broken », « awake » (« s'est réveillé ») et « asleep », « vêtu » et « nu », « in front of » et
  « behind », « below » et « above » : aucune sorte du tableau de FONDEMENTS § 2.7 ne dit qu'un état en exclut un autre.
  Une implication vers une négation (intact ⇒ ¬broken) n'y figure pas, et les connaissances ne transmettent la négation
  que par contraposition (§ 3.3).
- J'ai donc mis `inconnue` partout où seul l'antonyme est dit : `ee-024` (variante « stands intact »), `ee-001`
  (« s'est réveillé »), `ee-002` (« désormais vêtu »), `ee-006` (« in front of him »), `ee-007` (« below him »).
- La question : faut-il une sorte « incompatibilité » (ou des implications à conclusion niée) ? Sans elle, ces
  configurations voisines ne sont jamais écartées.

**A3. Nier un état pendant un événement en cours.**
- `ee-017`, variante « Abel n'est pas mort : frappé, il tente de se relever » : si K avait « tuer ⇒ mourir », la
  contraposition donnerait-elle « pas mort ⇒ pas tué » ? Un meurtre **en cours** est compatible avec une victime pas
  encore morte. SPECIFICATION_OPERATIONS § 2 dit que l'ancrage de la conséquence d'un événement en cours est « en cours
  ou postérieur », mais ne dit pas comment la contraposition se combine avec l'ancrage. J'ai mis `inconnue` (K ne
  contient d'ailleurs pas cette implication).

## B. Le temps figuré et l'aspect

**B1. Les ancrages s'excluent-ils ?** (`decision_ouverte` dans `ee-009`)
- L'ontologie distingue « en cours », « antérieur » et « imminent », et dit que les libellés les distinguent
  (ONTOLOGIE § 1.2). Elle ne dit pas si un événement ancré « imminent » ou « antérieur » est un appui **négatif** pour
  le même événement « en cours ».
- J'ai retenu `inconnue`, l'option la plus faible, dans `ee-009` et dans les variantes de temps de `ee-001`, `ee-002`,
  `ee-007`, `ee-008`, `ee-010`, `ee-013`, `ee-014`, `ee-015`, `ee-017`, `ee-018`, `ee-024`. Si les ancrages
  s'excluent dans une même situation, une bonne partie de ces variantes deviennent `ecartee`.

**B2. Où passe la frontière entre la phase préparatoire et l'imminence ?**
- ONTOLOGIE § 1.2 range « Abraham s'apprête à sacrifier Isaac » dans l'**en cours** (la phase préparatoire), et sépare
  l'imminent. Mais rien ne dit si « sur le point de », « about to », « la hache levée » (geste suspendu) et
  « s'apprête à » sont des réalisations distinctes, ni si un libellé au progressif (« sacrificing ») est satisfait par la
  phase préparatoire.
- J'ai mis `etablie` pour « s'apprête à » (`ee-008`) et `inconnue` pour « sur le point de » et pour le geste suspendu
  (`ee-008`, variante, et `ee-009`). Pour traduire `ee-008`, j'ai écarté « is about to », que l'anglais lit comme une
  imminence, et pris « is preparing to ». La traduction dépend donc d'une décision qui n'est pas prise.

**B3. Une conséquence conditionnelle attestée, dont la condition n'est pas établie.**
- `ee-004` (« blind » ⇒ un aveuglement antérieur, si la cécité n'est pas de naissance) et `ee-018` (« ruins » ⇒ une
  destruction antérieure, si la ruine ne vient pas d'une dégradation) : j'ai mis `etablie_sous_hypotheses`
  (`consequence_conditionnelle`), d'après FONDEMENTS § 2.7.
- Ce qui n'est pas dit : qui fixe la condition d'une telle connaissance (une ressource ? une validation ?), et si la
  variante « blind from birth » la **nie** (et donne alors `inconnue`) ou ne fait que l'écarter.

**B4. La sorte d'un cas « sous hypothèses ».**
- Le plan (QUALIFICATION_SEMANTIQUE § 2.1) définit les sortes par la satisfaction, et ne dit pas où classer un cas dont
  la conclusion ne tient que sous hypothèse. J'ai classé `ee-004` en `indetermine` et `ee-006`, `ee-011`, `ee-018` en
  `positif`. Ce n'est pas cohérent, et les quotas de sortes en dépendent.

## C. Les situations

**C1. La satisfaction relative à une situation.** (`decision_ouverte` dans `ee-019`)
- ONTOLOGIE § 4 et § 6 laissent ouverte la question de savoir quand une définition doit être satisfaite dans une seule
  situation. Dans `ee-019`, les deux conditions sont satisfaites dans deux registres. J'ai retenu `inconnue`, l'option
  la plus faible ; le graphe plat actuel donnerait `etablie`.
- Une question liée : deux éventualités figurées dans une même situation sont-elles, par là, simultanées ? Une seule
  situation a un seul moment (ONTOLOGIE § 3) : la simultanéité serait alors implicite. J'ai évité de m'en servir
  (`ee-011` ne demande pas « while »), mais `ee-001` (« pendant que ») et `ee-019` en dépendent.

**C2. « La même jeune femme » : une coréférence, ou une identité entre situations ?** (`ee-019`)
- La famille de référence a une construction `designation_reprise` ; l'ontologie (§ 3) interdit de fusionner deux
  figures d'un même individu dans deux situations. J'ai déclaré `identite_entre_situations`, mais la construction
  composée reste une coréférence. Il faut dire laquelle des deux représentations une reprise par « la même » produit,
  quand les deux mentions sont dans deux scènes.

**C3. Une configuration figurée seulement dans une représentation emboîtée.** (`decision_ouverte` dans `ee-023`)
- Une tapisserie figurée dans le tableau figure une scène. Les fondements séparent les contextes (§ 2.5), mais ne disent
  pas si une définition est satisfaite par une figuration emboîtée, ni si elle l'est « comme sujet secondaire ». J'ai
  retenu `inconnue`.

**C4. Un nom de rôle de cadre et l'abduction.** (`ee-020`)
- Un portrait de mariés n'établit pas une noce en cours (SPECIFICATION_OPERATIONS § 4). Mais la variante « No feast is
  shown » nie une **entité nue** de type situation. J'ai appliqué la règle de NOYAU § 1.1 (une entité nue, seule dans
  sa classe, nie le type pour tout référent) et mis `ecartee`. Il n'est pas dit si cette règle vaut pour les
  situations, qui seraient des référents d'une sorte propre.

**C5. Une partie perdue de l'œuvre.** (`ee-014`, variante de portée)
- « La partie supérieure, où l'on voyait autrefois des maçons bâtir une tour, est perdue » : ce que l'œuvre figurait
  et ne figure plus est-il figuré ? La portée n'est ni `represente` ni simplement `oeuvre`. J'ai mis `inconnue`.

## D. Les connaissances et les variantes

**D1. Une équivalence proposée sans attestation n'a pas de sorte propre.** (`ee-006`)
- Le validateur n'accepte pas `equivalence` ; j'ai écrit `equivalence_etablie` avec `attestee: false`, ce qui est
  contradictoire dans les termes (une équivalence n'est établie que par son attestation, FONDEMENTS § 2.7). L'autre
  choix, `relation_inconnue`, perd l'information que la ressource la donne pour une équivalence. L'hypothèse attendue
  (`equivalence_non_attestee` ou `relation_inconnue`) en dépend.

**D2. La paraphrase et la traduction ne gardent pas toujours le statut.**
- Le plan (§ 2.2) attend « même statut » pour la paraphrase et la traduction. Mais le statut dépend de ce que K
  atteste :
  - `ee-006` : « in a rage » donne `etablie_sous_hypotheses` (l'équivalence de la locution n'est pas attestée), et la
    paraphrase « angry » donne `etablie` ;
  - `ee-011` : « the fall of Icarus » donne `etablie_sous_hypotheses` (`sens`), et la paraphrase verbale « Icarus
    falls » donne `etablie`.
- J'ai écrit les statuts que K impose, en signalant ces deux variantes. La question : la relation métamorphique de
  paraphrase est-elle relative à K (et alors la variance est légitime), ou faut-il exiger que K contienne les
  équivalences attestées qui la rendent invariante ?

**D3. Une traduction change la polysémie.**
- `ee-016` : « gaulois » n'a qu'un sens, mais l'anglais « Gallic » en a deux (la Gaule, la France). J'ai traduit par
  « Gaulish », que WordNet 3.0 ignore : la lecture devrait le rattacher à gallic%3:01:00::, sans quoi la traduction
  donnerait `inconnue`.
- `ee-011` : « chute » et « fall » n'ont pas les mêmes sens. `ee-006` : la traduction « en colère » passe directement
  par « colère » et n'emploie plus « rage ⊑ anger ».
- Les variantes de traduction supposent donc une polysémie égale dans les deux langues, ce qui est faux en général.

**D4. Ce que `connaissances_supposees` doit contenir.**
- Le protocole dit « ce que K contient pour ce cas, et rien d'autre ». Je n'y ai pas mis le lexique (homme → man,
  cavalier → horseman, bourreau → torturer, maçon → mason), mais j'y ai mis quelques hyperonymies (rage ⊑ anger,
  legionnaire ⊑ soldier, Christ ⊑ person). La frontière entre la lecture (les sens d'un mot, la traduction) et K
  (les inclusions) n'est pas fixée pour la rédaction des cas, alors qu'un statut `etablie` en dépend à la lettre.
  Les sortes acceptées n'ont rien pour les sens lexicaux.

**D5. Le choix du pivot sous la contrainte des familles lexicales.**
- `noun.state` est en qualification ; pour l'état nominal (`ee-005`, `ee-006`), le pivot passe par `noun.feeling`
  (fear%1:12:00::, rage%1:12:00::), alors que rage, anger, fear ou sorrow ont aussi un sens `noun.state`. Une émotion
  est-elle un état au sens de l'ontologie (un porteur, un intervalle, sans changement interne) ? Ce n'est pas dit, et le
  choix du sens pivot est en partie arbitraire.
- `ee-001` : la paraphrase « pendant son sommeil » passe par sleep%1:26:00:: (`noun.state`), dans une variante.

**D6. Les extensions sont déclarées pour le cas de base, non pour ses variantes.**
- Plusieurs variantes demandent une extension que le cas de base ne demande pas (l'ancrage temporel pour les variantes
  de temps de `ee-002`, `ee-007`, `ee-010`, `ee-014`, `ee-016`). La forme d'un cas n'a pas d'`extensions_requises` par
  variante. De plus, pour un état lu comme propriété des deux côtés (`ee-002`, `ee-003`, `ee-024`), j'ai mis `aucune` :
  le statut est atteint sans réification, même si la sémantique cible réifie. Faut-il déclarer l'extension que demande
  la représentation cible, ou seulement celle sans laquelle le statut n'est pas atteint (la consigne) ?

## E. Les modalités et les sources

**E1. « Semble », « perhaps », « apparently ».**
- J'ai mis `inconnue` : une assertion non affirmée n'appuie rien (NOYAU § 1). FONDEMENTS § 5 connaît une hypothèse
  « assertion supposée », mais la liste des `hypotheses_attendues` ne l'a pas : une modalité possible ne peut donc
  jamais donner `etablie_sous_hypotheses`. Est-ce voulu ? Cas : variantes de `ee-001`, `ee-003`, `ee-004`, `ee-006`,
  `ee-010`, `ee-011`, `ee-012`, `ee-013`, `ee-016`, `ee-019`, `ee-023`.

**E2. Une source citée contre l'auteur.** (`ee-021`, variante)
- « Selon le catalogue, elle prie ; en réalité, elle ne prie pas » : j'ai mis `contradictoire` (un appui positif cité,
  un négatif de l'auteur ; NOYAU § 4.3-4.4, contradictoire documentaire). On pourrait soutenir que la négation de
  l'auteur prime et donne `ecartee`. NOYAU range le contradictoire avant l'écarté, mais la priorité de l'auteur sur une
  source qu'il réfute n'est pas dite.

**E3. À quel objet se rapporte une source citée, sous « d'après » ?** (`ee-021`)
- Dans une gravure « d'après un tableau perdu », une source qui décrit le tableau original parle d'une autre œuvre
  (`autre_oeuvre`), et une source qui décrit la gravure parle du figuré. La lecture doit choisir ; le texte ne le dit
  pas toujours. J'ai écrit la base de sorte que la source porte sur la gravure, et une variante où elle porte sur
  l'original (`inconnue`).

## F. La forme des variantes

**F1. Des variations sans nom.**
- Ajouter le terme d'un mouvement (`ee-013`), les rôles d'un nom nu (`ee-012`) ou le cadre d'une situation (`ee-020`) :
  je les ai rangés en `changement_de_participant`, faute de mieux.
- Réunir deux registres en une scène (`ee-019`) : je l'ai rangé en `changement_de_temps` (un seul moment).
- La liste du § 2.2 du plan n'a pas de variation « ajout ou retrait d'une condition », ni « changement de la structure
  des situations ».

**F2. Un nombre faux écarte, même quand la condition distinctive est inconnue.** (`ee-013`, variante « three
travellers »)
- La conjonction d'un faux et d'un inconnu est fausse (NOYAU § 4.2) : la variante est `ecartee` pour ces référents,
  alors que le terme du mouvement, l'objet du cas, reste inconnu. C'est conforme aux documents, mais la variante
  mesure alors le nombre et non l'aspect.
