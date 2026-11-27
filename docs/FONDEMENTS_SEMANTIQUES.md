# Les fondements sémantiques d'oedipamaas (version 1.1, 27/11)

**Ce que ce document fait.** Il fait pour la représentation sémantique ce que `docs/NOYAU.md` a fait pour la logique :
- fixer ce qu'une description et une définition **veulent dire** ;
- fixer ce que chaque opération a le droit de faire de ce sens ;
- fixer ce qui doit être vrai pour qu'une conclusion soit justifiée.

**La version 1.1** suit les décisions et les précisions de la propriétaire (quatrième message) :
- les états réifiés (`docs/ONTOLOGIE_EVENTUALITES.md`) ;
- aucun statut intermédiaire ;
- la nature paraconsistante des modèles ;
- les extensions réelle et figurée ;
- les situations et la narration ;
- la quantification énoncée ;
- les sortes de définitions ;
- l'abduction explicative.

**Ces fondements ne sont pas tenus pour stabilisés** : les questions ouvertes du § 8 le disent.

**Ses rapports aux autres documents :**
- `docs/FONDEMENTS.md` (v2) a posé le cadre conceptuel : des graphes à contextes emboîtés, et les trois relations de
  preuve (figuration, désignation, classement).
- `docs/NOYAU.md` en a écrit la logique.
- `docs/AUDIT_EXPRESSIVITE.md` établit ce que le langage actuel ne peut pas dire.
- `docs/ONTOLOGIE_EVENTUALITES.md` étudie les éventualités avant toute syntaxe.
- `docs/COMPARAISON_FORMALISMES.md` compare les formalismes, d'après l'état de l'art vérifié
  (`docs/ETAT_DE_L_ART_SEMANTIQUE.md`).
- `docs/SPECIFICATION_OPERATIONS.md` spécifie les quatre opérations.
- `docs/QUALIFICATION_SEMANTIQUE.md` dit comment on saura que c'est juste.
- `docs/TRAJECTOIRE.md` dit dans quel ordre le spécifier, puis le réaliser.

**Ce qu'il n'est pas.** Il ne choisit pas un formalisme existant pour l'adopter en bloc. Il ne réécrit pas le noyau.
Il ne fait pas non plus de la conservation du noyau un principe contre une extension dont la nécessité serait
démontrée.

## 1. Le problème, en termes de vérité

**Une description.** Une description D d'une œuvre est un ensemble d'énoncés d'un auteur, et d'autres sources qu'il
cite, sur plusieurs objets :
- l'œuvre comme objet ;
- ce qu'elle figure ;
- ce que ses figures signifient ;
- son histoire ;
- d'autres œuvres et d'autres textes.

**Une définition.** Une définition Δ_N d'une notation N dit à quelles conditions une œuvre relève de N :
- une configuration figurée, pour la figuration ;
- l'identité d'un individu figuré, pour la désignation ;
- un genre, pour le classement.

### 1.1 Les modèles sont informationnels et à quatre valeurs

Une lecture classique de « l'ensemble des situations compatibles avec D » serait fausse ici. Si D contient une
contradiction (l'auteur dit A, une source dit non-A, ou l'auteur se contredit), aucune situation classique n'est
compatible, et tout s'ensuit. C'est l'explosion, que le noyau évite par construction.

**Les modèles sont donc ceux de Belnap et Dunn.**
- **Un modèle est une valuation à quatre valeurs.** Un modèle v donne à chaque atome sous une liaison, dans un
  contexte et pour un énonciateur, une valeur de **FOUR = {N, V, F, B}** :
  - **N**, rien n'est dit ;
  - **V**, l'atome est dit vrai ;
  - **F**, il est dit faux ;
  - **B**, il est dit vrai et faux.
- **L'ordre d'information :** ces valeurs sont ordonnées par ce qui est dit, N ≤ V, F ≤ B.
- **La valuation de D :** v_D est la plus petite valuation qui contient ce que D affirme et nie, close par les
  connaissances K dans leur direction :
  - une implication transmet le vrai vers la conclusion, et le faux de la conclusion vers les prémisses
    (contraposition) ;
  - une équivalence transmet les deux, dans les deux sens.
- **Les modèles de D :** M(D) = { v : v ≥ v_D }, les valuations qui disent **au moins** ce que dit D. On y ajoute de
  l'information, jamais on n'en retire.
- **La conséquence** est celle de Belnap et Dunn, l'implication de premier degré : un atome dit vrai n'en rend pas
  vrais d'autres sans lien, et une contradiction reste locale, à l'atome qui la porte.
  - C'est ce que calcule le noyau : la paire (appui positif, appui négatif) de chaque atome, et les connecteurs de
    `docs/NOYAU.md`, § 4.2.

**Ce que signifient les statuts.**
- **N est établie** si v_D(Δ_N) = V, sous une liaison certifiable : vrai d'après l'auteur, et non dit faux.
  - Ce n'est pas « vrai dans toute extension » : une information ajoutée peut faire passer un atome de V à B, et la
    conclusion tombe. Le noyau le montre (une négation ajoutée retire une certification).
  - « Établie » est donc **relatif à l'information de D**. C'est voulu : une description ne dit pas tout, et ce qu'on
    certifie, c'est ce qu'elle dit.
- **Écartée pour ces référents :** v_D(Δ_N) = F sous la liaison considérée.
- **Contradictoire :** v_D(Δ_N) = B.
- **Inconnue :** v_D(Δ_N) = N.
- **Sous hypothèses H :** établie avec v_{D∪H}, H explicite, admissible et conjointement satisfaisable (§ 5).

**Ce que le noyau fait de cet idéal.** Il en calcule une **approximation sûre**. Ce qu'il établit est vrai dans v_D
(relativement à K et à la lecture), et il peut ne pas établir ce qui l'est (« la précision d'abord ») :
- des formules existentielles positives ;
- une certification qui n'accepte que les prémisses de l'auteur ;
- des valeurs calculées par contexte et par énonciateur, une contradiction entre sources restant documentaire.

**Ce que la représentation doit garantir en retour.**
- Tout ce qui sépare deux valuations v_D différentes doit être représentable : c'est le critère d'indiscernabilité de
  l'audit.
- Toute opération doit préserver v_D (§ 4).

### 1.2 Une définition, l'extension réelle, l'extension figurée

**Trois choses qui ne se confondent pas :**
- **la définition d'un concept** (son intension) : ce qu'il faut être pour être un dragon, une tonsure, un martyr ;
- **son extension dans le monde réel :** il n'y a pas de dragons ;
- **son extension dans un monde figuré :** l'image figure un dragon, qui est un dragon **de ce monde**.

**Les conséquences :**
- **les contextes ont chacun leur domaine.** Le monde figuré, le monde réel, le signifié, le monde d'une source, celui
  d'une vision emboîtée : un référent appartient à un contexte, et ce qui est vrai de lui l'est dans ce contexte ;
- **les inclusions analytiques de K valent dans tout contexte :** un dragon figuré est une créature figurée. Les faits
  encyclopédiques ne valent que dans le monde réel : la date de la mort de saint Ignace n'est pas importée dans la
  scène ;
- **sous la figuration, un nom désigne le personnage figuré.** Le personnage est relié à l'individu historique par la
  désignation (`docs/FONDEMENTS.md`, § 4.2), non par l'identité ;
- **les modificateurs non intersectifs sont de deux sortes,** à ne pas confondre :
  - **privatifs dans le même contexte :** « un faux pistolet » n'est pas un pistolet, dans aucun contexte ;
  - **de mode d'existence :** « un lynx fabuleux », « une créature imaginaire » sont, dans le monde figuré (ou celui de
    la fable), un lynx ou une créature. Le modificateur dit qu'ils n'ont pas d'extension réelle, et c'est ce que
    demande la queue FF d'Iconclass (« fabulous animals »). Ils ne perdent pas leur type dans le monde figuré.

## 2. L'ontologie de la représentation

### 2.1 Les individus, les espèces, les concepts, les collections

- **Un référent** est une classe de mentions coréférentes (`docs/NOYAU.md`, § 1), en monde ouvert pour l'identité, dans
  un contexte.
- **Son type** vient de la tête nominale de ses mentions, par ses **sens** (D30), et K l'ordonne.
- **Un individu figuré** est présent dans le monde figuré.
- **Une espèce** est un type pris comme objet : « le lion comme symbole », « fabulous animals ».
- **Un concept** est ce que figure une personnification ou un symbole (la Justice, le Matin). Il est **signifié** par un
  individu figuré, non présent dans l'image (audit, § 3.7).
- **Une collection** est un groupe pris comme un tout (« le couple », « les apôtres », « une foule »), avec ses membres
  quand ils sont dits (§ 2.6).

### 2.2 Les éventualités : propriétés, états, processus, événements de changement, situations

C'est la décision B de la propriétaire, et l'ontologie de `docs/ONTOLOGIE_EVENTUALITES.md`.

- **Une propriété ordinaire** caractérise l'individu, indépendamment du moment : rouge, de bois, romain. Elle reste
  une propriété, et **n'est pas** réifiée.
- **Un état** (d'un stade) est réifié en éventualité, avec son **porteur** : nu, endormi, mort, chauve, agenouillé.
  - « Chauve » et « calvitie » ont le même type d'état ; c'est la forme canonique.
  - Un état se qualifie, se situe dans le temps, se relie à d'autres éventualités : résultat de, pendant, cause.
- **Un processus** est une éventualité dynamique sans terme : courir, prier.
- **Un événement de changement** culmine en un état résultant : tuer, mourir, briser. Il peut être figuré en cours
  (sa phase préparatoire), accompli (par son seul résultat) ou imminent.
- **Une situation** est une configuration d'éventualités et de participants. Trois choses sont à distinguer :
  - la **description** d'une situation (un cadre, une définition) ;
  - la **situation** qui la satisfait, un référent possible : localisée, datée, comptable ;
  - les **relations** entre situations : succession, partie, emboîtement, une même description satisfaite deux fois.
  - Les situations ne sont pas exclues comme référents (`docs/ONTOLOGIE_EVENTUALITES.md`, § 4).
  - Un nom de rôle de cadre (« la mariée ») désigne un participant d'une situation, non la situation.

**La sorte d'un mot** (propriété ou état, processus ou événement) est portée par son **sens**, dans K, d'après des
ressources identifiées. Quand elle est inconnue, l'adjectif reste une propriété. On ne crée pas d'éventualité sans
fondement.

### 2.3 Le temps figuré, la narration, l'emboîtement

**Une œuvre figure une ou plusieurs situations, chacune avec son moment.** L'ancrage temporel d'une éventualité se
fait relativement au moment **de sa situation** :
- en cours ;
- antérieure (son résultat tient) ;
- imminente ;
- hors du temps figuré.

**Les cas qui ne sont pas exclus par construction,** même si leur réalisation est différée :
- **la juxtaposition d'épisodes :** plusieurs situations, et une relation de succession ;
- **la narration continue :** plusieurs situations dans un même espace figuré, et le même personnage figuré plusieurs
  fois. Il faut une relation « figure le même individu dans une autre situation », qui ne fusionne pas les figures ;
- **les représentations emboîtées :** un tableau dans le tableau, une tapisserie, un miroir, une vision. Une situation
  est figurée dans un contexte de figuration emboîté.

### 2.4 Les relations

- **Les relations entre individus** sont des concepts de relation, non des prépositions : partie, possession, matière,
  représentation, position, parenté. K ordonne les sens des prépositions comme ceux des noms.
- **La méréologie :** partie_de est transitive. Une partie n'est pas son tout. Le tout est un autre référent, impliqué
  si la partie est obligatoire, supposé sinon.
- **Entre éventualités :** résultat, simultanéité, cause, but, appartenance à une situation, succession de situations.

### 2.5 Les contextes

**Ce qu'est un contexte.** Une assertion est vraie **dans un contexte**, et les contextes s'emboîtent :
- l'œuvre ;
- le figuré, et les figurations emboîtées ;
- le signifié ;
- le monde réel ;
- les autres œuvres ;
- les textes sources ;
- et les contextes ouverts par une éventualité : ce qu'on voit en vision, rêve, ordonne, tente, dit, ce qu'une
  inscription porte.

**La portée actuelle** en est la projection plate, une valeur par assertion.

**L'énonciateur et la modalité** sont des propriétés du **chemin** de contextes. Les valeurs de Belnap se calculent
par contexte et par énonciateur. Une contradiction entre sources reste confinée, documentaire.

**Les références traversent les contextes selon une accessibilité,** à la manière de la DRT :
- un référent du contenu d'une vision n'est pas un référent du monde figuré ;
- un référent du monde figuré est accessible depuis le contenu de la vision d'un de ses personnages.

**L'admissibilité, généralisée :** une assertion est une prémisse d'un contexte C si son chemin est (auteur, affirmé,
C), et si chacun de ses porteurs et participants l'est aussi. C'est la règle du noyau (§ 1 de NOYAU), réécrite pour
des chemins.

### 2.6 La quantification énoncée, sans monde clos

**Deux choses à séparer :**
- **représenter une quantification que le texte énonce :** « tous les apôtres », « seul », « seulement des femmes »,
  « tous sauf Judas », « chacun tient un fruit ». C'est voulu.
- **l'inférer en monde clos,** du silence du texte : c'est refusé. Le texte ne dit pas tout.

**Ce que la représentation doit pouvoir dire :**
- **les collections :** un référent de groupe (Link), ses membres quand ils sont dits, son nombre ;
- **les domaines restreints :** « tous les apôtres de la scène » contre « tous les apôtres » du récit, qui relèvent de
  deux contextes ;
- **les quantifications énoncées,** comme des assertions de l'auteur : tous, aucun autre, seul, exactement n, au moins
  n, sur une collection et un domaine ;
- **les exceptions :** tous sauf X ;
- **la distributivité :** « chacun » (distributif), « ensemble » (collectif), et le cas indécidé, qui reste une
  ambiguïté et n'est pas résolu par défaut.

**Les conséquences :**
- **une quantification énoncée est une prémisse,** et la déduction en tire ce qu'elle dit. « Tous les apôtres
  dorment », plus un apôtre figuré, donne « il dort » ;
- **un libellé exclusif** (« Judith et Holopherne restés seuls ») n'est satisfait que si le texte **énonce**
  l'exclusivité, jamais parce qu'il ne mentionne personne d'autre ;
- **« (other) X »,** le monde clos documentaire sur les notations sœurs, est une convention de classement, bornée aux
  sœurs, et non une quantification sur la scène.

### 2.7 Les connaissances et les définitions

**Deux dimensions indépendantes** (décision de la propriétaire : aucun statut intermédiaire) :
- **la provenance :** d'où vient la connaissance (WordNet, une glose, Iconclass, FrameNet, une validation humaine),
  avec sa version ;
- **le statut épistémique :** ce qu'elle permet de conclure.
  - Une définition lexicalement attestée peut fonder une conclusion **déductive** si sa suffisance est établie.
  - Sinon, elle reste une **hypothèse**.
  - La provenance ne crée jamais un statut à elle seule.

**Les sortes de connaissances,** chacune avec sa direction de négation :

| sorte | ce qu'elle dit | ce qu'elle permet | statut d'une conclusion |
|---|---|---|---|
| **équivalence établie** | Def ⇔ T, la suffisance et la nécessité établies | la canonisation ; le dépliage dans les deux sens | déductive, sous les seules hypothèses de sens |
| **condition suffisante établie** | Def ⇒ T | établir T depuis Def | déductive |
| **condition nécessaire établie** | T ⇒ Def | réfuter T par la négation de Def (contraposition) ; une condition nécessaire d'un libellé | déductive pour la réfutation, jamais pour l'établissement |
| **implication** | lion ⊑ félin ; tuer ⇒ mourir | la déduction, dans son sens | déductive |
| **conséquence conditionnelle** | A ⇒ B si C | la déduction, C établie | déductive si C est établie ; sous hypothèse si C est supposée |
| **connaissance typique** | les « possible attributes » ; un portrait de mariage figure des mariés | l'abduction | sous hypothèse, défaisable |
| **hypothèse interprétative** | le poignard levé, l'intention de tuer | l'abduction, au coût le plus haut | sous hypothèse, nommée comme interprétation |
| **relation inconnue** | une glose dont on ne sait si elle est suffisante, nécessaire ou typique | l'abduction seulement | sous hypothèse |

**Ce qui établit une équivalence ou une suffisance.**
- **Ce qui ne suffit pas :** que K n'ait aucun contre-exemple. En monde ouvert, K est incomplet, et une absence de
  contre-exemple ne prouve rien.
- **Ce qui l'établit :** une **attestation**. La ressource donne la définition pour nécessaire et suffisante, et une
  validation (humaine, ou une seconde ressource indépendante) le confirme. La provenance de l'attestation est gardée.
- **Le défaut d'une glose est « relation inconnue ».**

**Les connaissances portent sur des sens et des structures, non sur des lemmes.**
- Une définition relie un **sens** (un identifiant de concept) à une **structure** : un motif d'assertions dont les
  atomes sont typés par des sens.
- Un lemme n'apparaît que par ses sens.

**Une base de définitions conceptuelles réutilisable.**
- Les définitions ne sont pas écrites libellé par libellé. Un même concept sert de nombreuses notations : le martyre, le
  pèlerin, le monstre, la tonsure, l'ermite, le diable, la Vierge à l'Enfant.
- La base associe à chaque concept :
  - son sens ;
  - sa structure ;
  - son statut par direction (suffisance, nécessité) ;
  - sa provenance et son attestation.
- Le compilateur des libellés y **renvoie,** au lieu de recompiler la définition dans chaque libellé.
- La réutilisation se mesure : combien de notations chaque concept sert.

## 3. La canonisation : une forme commune, non une collection de réécritures

### 3.1 Ce qui doit être préservé

Une canonisation c est **correcte** si v_{c(D)} = v_D pour toute D, et si Δ(c(N)) = Δ(N). Chaque règle doit montrer
qu'elle respecte cinq invariants :
1. **les référents :** ni fusion ni scission sans une coréférence ou une distinction dite ;
2. **les rôles :** le participant garde son rapport à l'éventualité ;
3. **le contexte :** une assertion reste dans son chemin de contextes ;
4. **la temporalité :** une conséquence n'est pas réécrite en l'événement, ni un état en un événement figuré en
   cours ;
5. **la polarité :** une assertion niée reste niée. Une réécriture sous une négation n'est permise que pour une
   équivalence établie.

### 3.2 Ce qui est une canonisation, et ce qui n'en est pas une

**Ce qui en est une : les équivalences établies, des deux côtés.**
- le nom d'action et l'événement, pour un sens ;
- le nom d'état, l'adjectif d'état et l'état réifié (« calvitie », « chauve » : un état) ;
- le pronominal et sa forme lexicale ;
- le passif et l'actif ;
- une locution que K donne pour équivalente.

**Ce qui n'en est pas une, et passe par une autre opération**, comme la contre-expertise de #16 (`docs/mesures/
C3_CONTRE_EXPERTISE.md`) l'a mesuré :
- **le nom d'agent et un participant d'événement :** une connaissance typique ;
- **le participe et un rôle :** le rôle dépend de la classe du verbe, jamais de la seule syntaxe ;
- **le composé nominal et une propriété :** sa relation implicite n'est pas une propriété ;
- **l'énumération et la disjonction :** une affaire de type de libellé, non de virgule ;
- **le choix d'un sens :** une hypothèse de sens, non une canonisation.

**L'exigence de symétrie :** une forme canonique est la même des deux côtés, ou la règle n'est pas appliquée.

### 3.3 La négation et les implications

Soit K ⊨ A → B :
- un appui **positif** de A est un appui positif de B ;
- un appui **négatif** de B est un appui négatif de A (la contraposition) ;
- un appui négatif de A ne dit **rien** de B ;
- une **équivalence établie** propage la négation dans les deux sens ;
- une **conséquence conditionnelle,** une connaissance typique ou une relation inconnue ne la propagent dans aucun.

Chaque connaissance de K dit sa direction de négation.

### 3.4 Les confusions à exclure

- **une conséquence n'est pas l'événement :** un corps sans vie implique une mort antérieure, non une mort figurée en
  cours ;
- **une partie n'est pas son tout ;**
- **un participant n'est pas la situation ;**
- **un concept n'est pas son extension :** un dragon figuré n'est pas un dragon réel ;
- **un personnage figuré n'est pas l'individu historique :** il le désigne.

## 4. Les opérations, en un mot

Elles sont spécifiées dans `docs/SPECIFICATION_OPERATIONS.md`. Chacune garde sa distinction : la déduction et
l'abduction ne se confondent pas.
- **La canonisation** réécrit par des équivalences établies, des deux côtés.
- **La déduction** tire des implications et des conséquences conditionnelles à condition établie. Ce qu'elle produit
  est certain, sous les seules hypothèses de sens.
- **La classification** déplie une définition suffisante ou équivalente établie (déduction), ou propose une
  classification par une définition d'un autre statut (abduction).
- **L'abduction** propose des **explications des éléments observés** (§ 5), jamais des prémisses ajoutées pour
  satisfaire une requête.

## 5. Les hypothèses, l'abduction et les preuves

**Les hypothèses.** Une conclusion sous hypothèses est établie dans v_{D∪H}. H doit être :
- **explicite :** chaque hypothèse est un terme de la preuve, avec :
  - sa sorte : sens supposé, distinction supposée, négation d'un autre sens, assertion supposée, classification
    supposée, prémisse graduée ;
  - ses assertions sources et son contexte ;
  - la connaissance et la règle qui la proposent ;
- **admissible :** elle ne contredit aucune assertion de l'auteur, y compris par une négation de K ;
- **conjointement satisfaisable,** à travers les dérivations : une occurrence n'a qu'un sens dans toute la preuve ;
  deux hypothèses exclusives ne sont pas ensemble ; aucune n'est niée par une autre conclusion de la preuve ;
- **minimale.**

**Ce qu'est une explication** (précision de la propriétaire, § 5) :
- **ce qu'elle explique :** une explication explique des **éléments observés**, des assertions de D. Ce n'est pas la
  requête. Une hypothèse qui n'explique aucune observation n'est pas admissible, même si elle satisfait la requête ;
- **sur quoi elle se fonde :** chaque hypothèse vient d'une connaissance identifiée (ressource, version, sorte) qui
  relie l'hypothèse aux observations qu'elle explique ;
- **ce à quoi elle est comparée :** les explications concurrentes des mêmes observations sont calculées et gardées.
  Si une concurrente d'un coût voisin conduit à une autre notation, ou à aucune, l'ambiguïté est rapportée. Elle n'est
  pas tranchée en silence ;
- **comment la requête intervient :** elle est évaluée **après** l'explication, sur D augmenté de chaque explication
  retenue. Elle peut guider la recherche, elle ne la justifie pas.

**Les preuves gardent :**
- les assertions sources et leurs chemins de contextes ;
- les connaissances employées, avec leur provenance, leur version, leur sorte et leur statut ;
- les règles ;
- les hypothèses, et pour une abduction, les observations expliquées et les explications concurrentes.

**Le vérificateur** refait chaque pas.

## 6. L'indexation et les modèles neuronaux

**L'indexation** n'est acceptable que si elle préserve les garanties du raisonnement exhaustif. Une notation n'est
écartée de l'examen que si une condition nécessaire établie est prouvablement sans appui positif, avec le même K et sous
toute hypothèse permise. Toute autre sélection propose un ordre d'examen, elle ne retire rien.

**Les modèles neuronaux** peuvent servir à la lecture (une analyse, une désambiguïsation) et à proposer des hypothèses,
écrites comme telles, avec le modèle pour source. Ils ne définissent ni la sémantique, ni la validité d'une
conclusion.

## 7. Ce qui est gardé, ce qui change

**Ce qui est gardé :**
- la logique du noyau : Belnap, la certification, le régime de l'identité, la supervaluation des sens, les lectures
  conjointes, les preuves, le vérificateur ;
- les trois relations de preuve de `docs/FONDEMENTS.md` ;
- le langage d'assertions actuel, comme cas particulier : une situation, un moment, des contextes plats.

**Ce qui doit changer.** Les besoins démontrés par l'audit, dont la liste n'est pas tenue pour exhaustive :
- les éventualités réifiées et l'ancrage temporel, relatif à une situation ;
- les contextes emboîtés et ouverts par une éventualité ;
- les référents conceptuels, les espèces et les collections ;
- les quantifications énoncées ;
- les modificateurs non intersectifs, privatifs ou de mode d'existence ;
- `non/1` dans les requêtes ;
- les connaissances séparées par sorte et par direction, sur des sens et des structures, dans une base de définitions
  conceptuelles ;
- la classification et l'abduction explicative, et l'extension des preuves.

L'ordre de spécification, puis celui de réalisation, sont dans `docs/TRAJECTOIRE.md`.

## 8. Les questions ouvertes

- **L'attestation des définitions :** qui atteste la suffisance d'une définition, et comment la validation humaine
  s'organise ;
- **les rôles des participes et des composés :** les ressources de valence et de relations implicites couvrent mal le
  français ;
- **les ressources de l'ontologie des éventualités :** les postures, les noms d'agent habituels, les adjectifs de
  degré (`docs/ONTOLOGIE_EVENTUALITES.md`, § 6) ;
- **la satisfaction relative à une situation,** et l'identité d'un personnage à travers une narration ;
- **les espèces et les génériques ;**
- **le contenu textuel des inscriptions.**
