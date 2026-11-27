# Les fondements sémantiques d'oedipamaas (version 1, 27/11)

**Ce que ce document fait.** Il fait pour la représentation sémantique ce que `docs/NOYAU.md` a fait pour la logique :
- fixer ce qu'une description et une définition **veulent dire** ;
- fixer ce que chaque opération a le droit de faire de ce sens ;
- fixer ce qui doit être vrai pour qu'une conclusion soit justifiée.

**Ses rapports aux autres documents :**
- `docs/FONDEMENTS.md` (v2) a posé le cadre conceptuel : des graphes à contextes emboîtés, et les trois relations de
  preuve (figuration, désignation, classement).
- `docs/NOYAU.md` en a écrit la logique.
- `docs/AUDIT_EXPRESSIVITE.md` établit ce que le langage actuel ne peut pas dire.
- `docs/COMPARAISON_FORMALISMES.md` compare les formalismes qui le pourraient. L'état de l'art vérifié est
  `docs/ETAT_DE_L_ART_SEMANTIQUE.md`.
- `docs/SPECIFICATION_OPERATIONS.md` spécifie les quatre opérations.
- `docs/QUALIFICATION_SEMANTIQUE.md` dit comment on saura que c'est juste.
- `docs/TRAJECTOIRE.md` dit dans quel ordre le faire.

**Ce qu'il n'est pas.** Il ne choisit pas un formalisme existant pour l'adopter en bloc. Il ne réécrit pas le noyau.

## 1. Le problème, en termes de vérité

**Une description.** Une description D d'une œuvre est un ensemble d'énoncés d'un auteur, et d'autres sources qu'il
cite, sur plusieurs objets :
- l'œuvre comme objet ;
- ce qu'elle représente ;
- ce que ses figures signifient ;
- son histoire ;
- d'autres œuvres et d'autres textes.

**Le modèle.** On ne connaît pas l'image ; on connaît ce que D en affirme. On note **M(D)** l'ensemble des situations
figurées compatibles avec ce que l'auteur affirme, en monde ouvert : ce qui n'est pas dit n'est ni vrai ni faux.

**Une définition.** Une définition Δ_N d'une notation N décrit un ensemble de situations, celles que N couvre (ou un
ensemble d'œuvres, pour le classement ; ou l'identité d'un individu, pour la désignation).

**La justification attendue** (l'idéal) :
- N est **établie** si toute situation de M(D) satisfait Δ_N : D, avec les connaissances K, **implique** Δ_N ;
- N est **écartée pour ces référents** si aucune ne la satisfait sous la liaison considérée ;
- N est **inconnue** sinon.
- Une conclusion **sous hypothèses** H est établie dans M(D ∪ H), H étant explicite, admissible et conjointement
  satisfaisable avec D et K (§ 4).

**Ce que le noyau fait de cet idéal.** Il en calcule une **approximation sûre** :
- des formules existentielles positives ;
- quatre valeurs pour séparer ce que le texte affirme de ce qu'il nie ;
- une certification qui n'accepte que les prémisses de l'auteur.

« Sûre » veut dire : ce qu'il établit est impliqué (relativement à K et à la lecture), et il peut ne pas établir ce qui
l'est. C'est le sens de « la précision d'abord ».

**Ce que la représentation doit garantir en retour.** Tout ce qui sépare deux ensembles M(D) différents doit être
représentable : c'est le critère d'indiscernabilité de l'audit (§ 2, proposition 2). Toute opération sur la
représentation doit respecter M(D) : c'est le critère du § 3.

## 2. L'ontologie de la représentation

Ce dont on parle, et ce que chaque sorte d'objet permet de dire.

### 2.1 Les individus et leurs types

**Un référent.** C'est une classe de mentions coréférentes (`docs/NOYAU.md`, § 1), en monde ouvert pour l'identité.

**Son type.** Il vient de la tête nominale de ses mentions, et K l'ordonne. Un type n'est pas un mot : D30 fait
porter les liens par les sens.

**Trois choses distinctes, qui ne se confondent pas :**
- **un individu figuré**, un référent présent dans le monde figuré ;
- **une espèce** (le lion comme espèce, « fabulous animals ») ;
- **un concept**, que figure une personnification ou un symbole (la Justice, le Matin). Le concept n'est pas présent
  dans l'image : il est **signifié** par un individu figuré (`docs/FONDEMENTS.md`, § 2, le contexte du signifié). Aucun
  des deux n'est réductible à un nom propre de la figure (audit, § 3.7).

### 2.2 Les événements, les états, les situations

- **Un événement** est un individu, à la manière néo-davidsonienne : un prédicat (un sens de verbe ou de nom d'action)
  et des participants par rôles. C'est la forme du langage actuel. Elle est gardée : c'est elle qui permet de compter,
  de qualifier, de nier un événement sans nier ses participants (§ 1.1 de NOYAU).
- **Un état** est ce qui tient au moment figuré, sans changement : « nu », « mort », « endormi », « chauve ».
  Sa forme canonique est une décision ouverte (`docs/COMPARAISON_FORMALISMES.md`, § 3) : une propriété, ou un état
  réifié en éventualité, avec le même ancrage temporel qu'un événement. Ce qui suit vaut pour la première option.
  - Il s'écrit comme une propriété du référent quand la langue l'exprime par un adjectif ou un participe adjectival.
  - Le choix entre propriété et nom d'état (« chauve » ou « calvitie ») est une affaire de **canonisation**, non de
    sens : l'un et l'autre ont les mêmes conditions de vérité, et la forme canonique est fixée une fois, des deux
    côtés (§ 3.2).
- **Un processus** est un événement en cours au moment figuré (« il court »). L'opposition entre processus et
  événement accompli n'est pas visible dans une image fixe, mais elle l'est dans un libellé. Elle relève de l'ancrage
  temporel (§ 2.3).
- **Une situation** est ce qu'un cadre décrit : une noce, une bataille, un repas, une pêche. Ce n'est pas un individu
  de plus, mais une **configuration** d'événements, d'états et de participants, dont les participants ont des rôles
  propres au cadre (la mariée, le marié, l'officiant).
  - Un nom de rôle de cadre (« bride ») désigne un participant **par son rôle dans une situation**. Il ne désigne pas la
    situation, et la situation peut n'être pas figurée : un portrait de mariage figure des époux après la cérémonie.

### 2.3 Le temps figuré

Une image fixe figure **un moment**. Un texte, et surtout un libellé, situent des événements par rapport à lui. Le
langage actuel ne le sait pas dire (audit, § 3.1). La représentation distingue, pour chaque événement :
- **en cours :** figuré en train d'avoir lieu ;
- **antérieur :** accompli avant le moment figuré, dont l'image montre le résultat (un corps sans vie : la mort est
  antérieure) ;
- **imminent :** sur le point d'avoir lieu (« about to strike ») ;
- **hors du temps figuré :** un récit, une biographie, ce que dit une source. C'est déjà la portée.

Un libellé qui demande un événement figuré demande un événement **en cours**, sauf s'il dit autre chose (« after »,
« death of » au sens du résultat).

L'ordre entre événements (« after having touched his robe ») se ramène, pour une image fixe, à cet ancrage. Un ordre
explicite entre deux événements en cours n'a de sens que pour une narration continue, où plusieurs moments sont
figurés. Ce cas est rare, et il est différé.

### 2.4 Les relations

- **Les relations entre individus** sont nommées par un concept de relation, non par une préposition : la partie, la
  possession, la matière, la représentation, la position (sur, sous, devant, à gauche de, du point de vue d'un
  spectateur ou d'une figure), la parenté.
  - La préposition est un mot polysémique comme un autre. Ses sens sont des concepts de relation, et K les ordonne
    (partie_de ⊑ rattaché_à).
  - Aujourd'hui, chaque préposition est son propre sens : « of » confond la partie et la possession (audit, § 3.5).
- **La méréologie :** « partie de » est transitive. Une partie n'est pas son tout, et un tout n'est pas sa partie : un
  « pont » n'est pas un navire ; il en implique un, selon une connaissance de la partie obligatoire, ou le suppose,
  selon une connaissance typique.
- **Les relations entre événements :** la cause, le but. Elles sont rares dans les libellés (moins de 0,3 %). Elles
  sont représentables comme des rôles dont la valeur est un événement (§ 2.5).

### 2.5 Les contextes

**Ce qu'est un contexte.** Une assertion est vraie **dans un contexte**. Les contextes de `docs/FONDEMENTS.md`, § 2,
sont :
- l'œuvre ;
- le figuré ;
- le signifié ;
- le monde réel (histoire, attribution) ;
- les autres œuvres ;
- les textes sources.

La portée actuelle en est la **projection plate**, une valeur par assertion. Elle suffit pour séparer ce que l'image
montre du reste ; elle ne suffit pas pour deux choses.
- **Les contextes ouverts par un événement :** ce qu'un personnage voit en vision, rêve, ordonne, tente, dit ; ce
  qu'une inscription porte. Les assertions de ce contenu ne sont pas vraies du monde figuré. Elles sont vraies dans le
  contexte du contenu de cet événement (audit, § 3.3).
- **L'emboîtement des sources :** une source qui en cite une autre.

**L'énonciateur et la modalité** sont des propriétés du **chemin** de contextes, non de l'assertion seule. « Selon
l'auteur, le texte biblique dit que Dieu ordonne à Ézéchiel de ne pas porter le deuil » a trois niveaux : l'auteur, la
source, le contenu de l'ordre.

**La règle d'admissibilité,** généralisée : une assertion est une prémisse du monde figuré si
- son chemin de contextes est (auteur, affirmé, figuré) ;
- et chacun de ses porteurs et participants l'est aussi.

C'est la règle actuelle (§ 1 de NOYAU), réécrite pour des chemins. Une assertion d'un contexte de contenu est une
prémisse **de ce contenu**, et ne peut servir qu'à une requête qui demande ce contenu (« vision de sept étoiles »).

### 2.6 Les définitions et les connaissances

K contient, et doit séparer, cinq sortes de connaissances. Leur statut décide de ce qu'une conclusion en tire.

| sorte | exemple | ce qu'elle permet | statut d'une conclusion qui l'emploie |
|---|---|---|---|
| **équivalence** | « olive oil » ≡ oil from olives (si la glose est une définition) ; un nom d'action ≡ l'événement de son verbe, pour un sens | la canonisation, le dépliage d'une définition dans les deux sens | déductive, sous les hypothèses de sens |
| **implication** | lion ⊑ félin ; snore ⇒ sleep ; kill ⇒ die (cause) | la déduction, dans un sens seulement | déductive |
| **conséquence conditionnelle** | « corps sans vie » ⇒ quelqu'un est mort, si le corps est celui d'une personne ; partie ⇒ tout, si la partie est obligatoire | la déduction, sa condition établie | déductive si la condition est établie ; sous hypothèse si elle est supposée |
| **connaissance typique** | les « possible attributes » d'Iconclass (la croix en X de saint André) ; un portrait de mariage figure des mariés | l'abduction : proposer, jamais conclure | sous hypothèse, défaisable |
| **hypothèse interprétative** | « le poignard levé » ⇒ l'intention de tuer ; le « feu » biblique est l'éclair | l'abduction, au coût le plus haut | sous hypothèse, nommée comme interprétation |

**Ce que K porte aujourd'hui.** Seulement des implications entre types (`sous/2`, `inclus/2`), et des égalités et
différences de noms. Les quatre autres sortes s'ajoutent comme des connaissances **distinctes**, jamais fondues dans
`sous/2`.

**La question de fond.** Ce qui fait d'une glose une définition (une équivalence) ou une description typique (une
connaissance typique) n'est pas décidable par le texte de la glose. C'est une propriété de la ressource, à établir
par ressource et par famille, et à mesurer (`docs/QUALIFICATION_SEMANTIQUE.md`).

## 3. La canonisation : une forme commune, non une collection de réécritures

### 3.1 Ce qui doit être préservé

Une canonisation c, appliquée à une description et à une définition, est **correcte** si M(c(D)) = M(D) pour toute D,
et Δ(c(N)) = Δ(N). Il en découle cinq invariants, que chaque règle doit montrer qu'elle respecte :
1. **les référents :** ni fusion ni scission sans une coréférence ou une distinction dite ;
2. **les rôles :** le participant garde son rapport à l'événement (agent, patient, thème…) ;
3. **la portée et le contexte :** une assertion reste dans son chemin de contextes ;
4. **la temporalité :** une conséquence n'est pas réécrite en l'événement, et un état n'est pas réécrit en un
   événement figuré en cours ;
5. **la polarité :** une assertion niée reste niée. Une réécriture sous une négation n'est permise que si elle est une
   équivalence. Une implication ne passe pas une négation (§ 3.3).

### 3.2 Ce qui est une canonisation, et ce qui n'en est pas une

**Ce qui en est une : les équivalences.**
- un nom d'action et l'événement de son verbe, **pour un sens** : la forme canonique est l'événement ;
- un nom d'état et l'adjectif (« calvitie », « chauve ») : la forme canonique est la propriété ;
- un pronominal et sa forme lexicale (« se tenir ») : la forme canonique est celle que K connaît ;
- un passif et son actif : déjà ramenés aux mêmes rôles ;
- une locution et son verbe (« prendre la fuite », fuir), **si K la donne pour une équivalence**.

**Ce qui n'en est pas une, et passe par une autre opération :**
- **un nom d'agent et un participant d'événement :** « singer » n'équivaut pas à « quelqu'un qui chante maintenant ».
  Le nom dit un rôle habituel ou un métier. Passer de l'un à l'autre est une connaissance typique, ou une conséquence
  conditionnelle selon le cadre.
- **un participe et un rôle :** le participe présent ne donne pas l'agent (« a burning house » : la maison ne fait
  rien) ; le participe passé ne donne pas le patient (« a fallen angel » : il n'a rien subi d'un agent). Le rôle dépend
  de la classe du verbe (inaccusatif ou inergatif, causatif), que donnent les ressources de valence. Ce n'est pas une
  règle syntaxique.
- **un composé nominal et une propriété :** la relation implicite d'un composé (matière, but, lieu, partie, agent)
  n'est pas une propriété de la tête.
- **une énumération et une disjonction :** dans un libellé d'Iconclass, une liste énumère ce que la notation couvre
  (« oil, vinegar, sauces ») : c'est une disjonction **de la définition**. Dans une scène (« bride and groom »), une
  coordination dit une conjonction. La différence tient au type de libellé (`docs/FONDEMENTS.md`, § 3.2), non à la
  virgule.
- **le choix d'un sens :** l'ordre des sens de WordNet suit une fréquence dans un corpus, non la sémantique d'Iconclass.
  Choisir le premier sens n'est pas canoniser, c'est supposer un sens, et cela s'écrit comme une hypothèse de sens
  (D30).

**L'exigence de symétrie.** Une forme canonique est la même des deux côtés, ou la règle n'est pas appliquée. Une
réécriture appliquée aux requêtes seulement, ou aux graphes seulement, crée des échecs ou des succès qui ne disent rien
du sens.

### 3.3 La négation et les implications

Soit K ⊨ A → B : A implique B (un lion est un félin ; tuer cause mourir).
- Un appui **positif** de A est un appui positif de B : c'est la direction des liens positifs du noyau.
- Un appui **négatif** de B est un appui négatif de A, par contraposition (« pas de félin » nie « lion ») : c'est la
  direction de `inclus/2` dans le noyau.
- Un appui négatif de A ne dit **rien** de B (« pas de lion » ne nie pas « félin »).
- Une négation n'est donc jamais propagée dans le sens de l'implication.
- Une **équivalence** la propage dans les deux sens.
- Une **conséquence conditionnelle** ou une **connaissance typique** ne la propage dans aucun : nier une conséquence
  typique ne nie pas sa cause.

Chaque connaissance ajoutée à K doit dire dans quel sens elle transmet la négation. Le comparateur d'inclusion l'exige
déjà des types (§ 8 de NOYAU : un lien « transmet la négation »).

### 3.4 Les trois confusions à exclure

- **Une conséquence n'est pas l'événement :** un corps sans vie implique une mort **antérieure**, non une mort figurée
  en cours (§ 2.3).
- **Une partie n'est pas son tout :** un pont de navire implique, ou fait supposer, un navire ; il n'est pas de type
  navire. Le tout est un autre référent, relié par partie_de.
- **Un participant n'est pas la situation :** la mariée n'est pas la noce ; un geôlier n'est pas l'emprisonnement. Le
  nom de rôle d'un participant fait supposer la situation ; il ne l'est pas.

## 4. Les hypothèses et les preuves

**Les hypothèses.** Une conclusion sous hypothèses est établie dans M(D ∪ H). H doit être :
- **explicite :** chaque hypothèse est un terme de la preuve, avec sa sorte (sens supposé, distinction supposée,
  négation d'un autre sens, assertion dérivée typique ou interprétative, prémisse graduée), ses assertions sources, son
  contexte, la connaissance et la règle qui la proposent ;
- **admissible :** une hypothèse ne contredit aucune assertion de l'auteur, y compris par une négation de K ;
- **conjointement satisfaisable,** à travers les dérivations :
  - une occurrence n'a qu'un sens dans toute la preuve, y compris quand une dérivation l'emploie (les lectures
    conjointes du lot 4, étendues aux sources des dérivations) ;
  - deux hypothèses dont K dit qu'elles s'excluent ne sont pas dans la même preuve ;
  - une hypothèse n'est pas niée par une autre conclusion de la même preuve ;
- **minimale :** aucune hypothèse inutile.

**Les preuves gardent :**
- les assertions sources (identifiants), et leurs chemins de contextes ;
- les connaissances employées, avec leur ressource, leur version, leur sorte et leur statut ;
- les règles d'opération, avec leur nom et leur version ;
- les hypothèses.

**Le vérificateur** refait chaque pas : il ne fait confiance à aucune opération.

## 5. L'indexation et les modèles neuronaux

**L'indexation** (décision du 27/11, troisième message). Elle n'est acceptable que si elle préserve les garanties du
raisonnement exhaustif. Une notation N peut être écartée de l'examen sans être évaluée **seulement** si une condition
nécessaire de N est prouvablement sans appui positif dans le graphe :
- avec le même K ;
- sous toute hypothèse permise.

C'est le rôle des conditions nécessaires et de l'index de `codage.pl`. La mesure du lot 1 confronte déjà le mode
indexé au mode exhaustif.

Toute autre sélection (par similarité, par un modèle, par fréquence) **propose un ordre d'examen**. Elle ne retire
jamais une notation de ce que le moteur a le droit d'examiner.

**Les modèles neuronaux** peuvent servir :
- à la **lecture** (une analyse, une désambiguïsation) ;
- à **proposer des hypothèses**, alors écrites comme telles, avec le modèle pour source.

Ils ne définissent ni la sémantique d'une assertion, ni la validité d'une conclusion. Une conclusion qui n'a pour appui
qu'une sortie de modèle est, au mieux, sous hypothèse.

## 6. Ce qui est gardé, ce qui doit changer

**Ce qui est gardé, sans changement :**
- le noyau logique : Belnap, la certification, le régime de l'identité, la supervaluation des sens, les lectures
  conjointes, les preuves, le vérificateur ;
- les trois relations de preuve de `docs/FONDEMENTS.md` ;
- le langage d'assertions dans ses termes actuels.

**Ce qui doit changer**, chaque fois démontré par l'audit et à faire passer par un banc avant le code :
- l'ancrage temporel des événements ;
- les contextes ouverts par un événement ;
- les référents conceptuels ;
- l'atome `non/1` des requêtes ;
- les connaissances séparées par sorte, avec leur direction de négation ;
- les opérations de classification et d'abduction, et l'extension des preuves aux hypothèses d'inférence.

L'ordre est dans `docs/TRAJECTOIRE.md`.

**Ce qui reste ouvert :**
- comment savoir qu'une glose est une définition (§ 2.6) ;
- comment fixer la canonisation des rôles des participes et des composés sans heuristique : les ressources de valence
  et de relations implicites existent, mais leur couverture du français est faible ;
- la narration continue (plusieurs moments figurés) ;
- les espèces et les génériques.
