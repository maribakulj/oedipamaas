# Les fondements conceptuels d'oedipamaas (25 novembre 2026)

Ce document fixe ce que le système affirme, et pourquoi. Il remplace, pour la reconnaissance des sujets, la méthode des
profils et des conditions de `docs/PLAN_F3.md` (§ 2), qui empilait des critères (seuil de rareté, « deux appuis »,
élément absent des sœurs, saillance) ajustés après avoir vu les erreurs : chacun était général, leur empilement ne
l'était pas. Les mesures qui l'ont montré sont dans `docs/mesures/F3.md`.

## 1. Le problème

- **Entrée** : un texte écrit par un humain (ou par un descripteur d'images) sur une œuvre : cartel, notice, catalogue,
  texte savant, description visuelle ; en français ou en anglais.
- **Sortie** : les notations d'Iconclass que l'image porte, chacune avec sa preuve ; « établie » seulement si la preuve
  est complète (la précision d'abord), « candidate » sinon.
- **Connaissance** : Iconclass (libellés, mots clés, hiérarchie, gabarits) et WordNet ; rien d'iconographique écrit
  à la main.

Une notation d'Iconclass s'applique à une image quand l'image montre ce que la notation désigne. Le système ne voit pas
l'image : il sait seulement ce que le texte dit qu'elle montre. Toute la construction découle de ces deux phrases.

## 2. Trois principes

### P1. Une seule lecture, pour le texte et pour Iconclass

Un libellé d'Iconclass est une courte description de ce qu'une image montre : « David beheads Goliath with a sword »,
« the apples of the Hesperides carried off by Hercules », « beasts of prey: lion ». Il se lit donc avec le **même
lecteur** que les textes, dans le **même langage d'assertions** (`docs/ASSERTIONS.md`) : des référents (avec leur nom ou
leur type), des événements (avec leurs rôles), des relations. Ce que le libellé affirme est la **définition** de la
notation.

- La définition d'une notation est celle de son libellé propre, plus celle de ses ancêtres (94L332 hérite de 94L
  « Hercules » : un épisode de l'histoire d'Hercule montre Hercule), plus celle de son gabarit (11H(PETER)5 :
  « Pierre » et « activités miraculeuses »).
- Ce que le libellé ne donne pas pour certain n'est pas dans la définition : « possible attributes: … » (des indices
  pour identifier une personne, pas des conditions), « who may be shown kneeling » (modalité « possible », que le
  lecteur marque déjà), les alternatives (« or », « alternatively »), les parenthèses de renvoi (« (Acts 6:1-6) »,
  « (Ripa) ») et les autres noms (« Hercules (Heracles) » : un synonyme).
- Les conventions d'écriture d'Iconclass (rubriques en majuscules, « (story of) », « (with NAME) », « - » et « ~ » des
  gabarits, « : » entre la catégorie et le terme défini) sont la grammaire de ses libellés : elles s'écrivent une fois,
  comme les règles de langue, et ne contiennent aucune iconographie.

Conséquence : la preuve T1 (un nom explicite) et la preuve T2 (une chose décrite) du moteur actuel sont les cas d'une
définition à un seul référent (« Hercules », « lion ») ; un épisode est une définition à plusieurs référents et un
événement. Il n'y a pas une méthode pour les noms, une pour les choses et une pour les épisodes : il y en a une.

### P2. Rien n'est dans l'image si le texte ne l'y met pas

Un texte sur une œuvre parle de deux mondes : ce que l'image montre, et le monde réel (l'artiste, la création,
l'histoire et la réception de l'œuvre, l'œuvre comme objet). Une assertion n'est **représentée** que si le texte
l'**autorise** par un de ces moyens, tous linguistiques :

1. un **pont** : un verbe ou un nom de représentation (« depicts X », « X is shown », « Portrait de X », « study of a
   young woman ») ; ses compléments sont représentés, son sujet est l'artiste ou l'œuvre (monde réel) ;
2. un **repère de l'image** : un cadre du plan de l'image (« on the left », « au premier plan ») ou une deixis
   (« here », « on voit ») ;
3. la **continuité** avec un référent représenté : ses actions, ses attributs, ses parties, ses relations, et ce qui
   le reprend (pronom, possessif, même nom, même groupe nominal défini) ;
4. le **genre du texte** : une description visuelle (la sortie d'un descripteur d'images) est représentée de bout en
   bout.

Le temps du verbe n'est pas une autorisation. Le « présent de description » de l'ancrage version 2 était une
présomption, mesurée à 38 % de précision (`docs/mesures/F3.md`) : il est retiré. Ce que le texte n'autorise pas n'est
pas nié pour autant (absence de mention ≠ négation) ; il ne fonde simplement rien.

### P3. Indexer, c'est vérifier une implication

Une notation est **établie** si et seulement si sa définition (P1) se retrouve tout entière dans les assertions
représentées du texte (P2) : il existe une correspondance de chaque référent, événement et relation de la définition
vers une assertion représentée du texte, telle que :

- **un nom** correspond au même nom (normalisé) ;
- **un type** correspond à un type égal ou plus spécifique : le texte peut dire « a lamb » là où la définition dit
  « animal », jamais l'inverse. En anglais, par les sens de WordNet (le sens de la définition est celui que la couche
  de sens aligne sur la notation, F2) ; en français, sans wordnet, par l'égalité des lemmes avec le libellé français ;
- **un événement ou une relation** correspond à un prédicat égal ou plus spécifique (même règle), avec ses rôles
  **sans contradiction** : un rôle que le texte et la définition donnent tous les deux doit coïncider (« Goliath
  beheads David » n'est pas 71H1443) ; un rôle que l'un des deux ne donne pas ne confirme ni n'infirme. C'est la
  lecture en monde ouvert d'un lecteur incomplet, des deux côtés.

La preuve d'une notation établie est cette correspondance : chaque élément de la définition, l'assertion du texte qui
le porte, son passage, son autorisation (P2), le sens qui justifie le type. Elle se vérifie indépendamment, comme les
preuves actuelles.

Ce qui en découle, sans règle supplémentaire :

- **les ancêtres** : si une notation est établie, ses ancêtres le sont (leurs définitions sont incluses) ; on rend la
  plus précise ;
- **les sœurs** : il n'y a plus de « condition différentielle ». Si la définition de 94L332 n'est pas impliquée
  (« holding the apples » n'est pas « carried off »), 94L332 n'est pas établie ; si celle de 94L l'est (« Hercules »
  représenté), c'est 94L qui l'est. Deux sœurs dont les définitions sont toutes deux impliquées sont toutes deux vraies ;
- **les gabarits à nom** : une notation à nom (61B2(...) « historical person (with NAME) ») a une définition avec un
  nom à remplir ; le texte le remplit. Quand Iconclass a une place propre pour ce nom (11H(PETER) pour saint Pierre),
  la place propre l'emporte sur le gabarit générique : c'est la règle d'Iconclass lui-même ;
- **les genres** : « landscapes » (25H), « portrait » se définissent comme les autres : établis quand le texte dit que
  l'image est un paysage, un portrait (par un pont : « this landscape », « Portrait du comte »). Un paysage déduit de
  « des collines et une mesa » est une inférence que ni Iconclass ni WordNet ne fondent : il reste candidat ;
- **le sujet principal** : parmi les notations établies, celle qui porte sur le référent que le texte présente par un
  pont. C'est une présentation du résultat, pas une condition de vérité ;
- **les candidats** : les notations dont la définition est impliquée en partie (avec ce qui manque), ou identifiées par
  leurs attributs seuls (Jérôme par le lion et le crâne, sans son nom).

## 3. Ce qui est retiré, et pourquoi

| Retiré | Pourquoi |
|---|---|
| les profils comme sacs de mots | ils ignorent la structure : « la vision de l'âme de Scholastique en colombe » partageait ses mots avec « Scholastique tient une colombe » |
| le seuil de rareté dans la décision | une quantité réglée ; la rareté ne sert plus qu'à l'efficacité (quelles définitions essayer d'abord), jamais à décider |
| « au moins deux appuis », « un élément qu'aucune sœur n'a » | remplacés par l'implication de toute la définition |
| la saillance comme condition | elle désigne le sujet principal, elle ne rend rien vrai |
| le présent de description | une présomption (P2) |
| les liens de dérivation de WordNet | « hold » n'est pas « holder » ; la spécificité des types et des prédicats passe par l'hyperonymie seule |

## 4. Ce qui est écrit à la main

Seulement des règles de langue et la grammaire des libellés d'Iconclass, chacune justifiée par une classe
linguistique : les classes fermées, les verbes et noms de représentation (ponts), les cadres du plan de l'image et la
deixis, les verbes de fabrication et d'histoire de l'œuvre, la négation, la modalité, les conventions d'écriture
d'Iconclass (§ 2, P1). Aucune liste d'objets, de personnes, d'attributs ou d'épisodes.

## 5. Les limites, dites d'avance

- **Le lecteur est imparfait, des deux côtés.** Sur les libellés, il reconnaît bien les référents et les prédicats
  (« David », « Goliath », « behead », « sword »), moins bien les rôles (« carried off by Hercules » : les pommes en
  agent). La règle des rôles sans contradiction protège la précision, pas le rappel. Si les définitions sont trop
  souvent fausses, on change d'analyseur par la frontière CoNLL-U, on n'ajoute pas de rustines (même règle que pour les
  textes).
- **Le rappel sera bas** : l'implication stricte établit peu, et c'est voulu (précision d'abord). Ce qui manque reste
  candidat, avec ce qui manque.
- **Le français** n'a pas de wordnet : ses types ne se comparent que par égalité de lemmes avec les libellés français ;
  sa couverture se mesure à part.
- **La continuité** (P2, 3) demande de relier un pronom ou un groupe nominal défini à son référent d'une phrase à
  l'autre ; c'est une règle de langue (accord, proximité, référent représenté le plus récent), et ses erreurs se
  mesurent.
- **Une lacune d'Iconclass reste une lacune** : un libellé qui ne décrit pas ce qu'on voit (« Thebaid » pour l'ermite)
  ne se rattrape pas à la main.

## 6. L'ordre du travail

Chaque étape a sa mesure, sur le banc de développement ; le banc de qualification reste scellé jusqu'à la fin ; le
critère de réussite de `docs/PLAN_F3.md` (précision des sujets établis et de tous les codes établis ≥ 0,85, rappel des
sujets ≥ 0,30) ne change pas.

1. **Les définitions** : lire les libellés d'Iconclass en définitions (P1). Mesure : justesse de 40 définitions tirées
   au hasard, jugée à l'aveugle (référents, prédicats, rôles, conditions optionnelles bien écartées).
2. **L'autorisation** : l'ancrage par ponts, repères et continuité (P2). Mesure : rappel des 97 éléments de la
   référence, précision jugée à l'aveugle sur 200 éléments.
3. **L'implication** : la correspondance et sa preuve (P3). Mesure : précision et rappel des notations établies, sujets
   et composants, avec la cause de chaque erreur (définition, autorisation, type, rôle).
4. **La qualification** : une seule mesure sur le banc scellé.

Les pièges de `docs/PLAN_F3.md` (§ 4) restent en vigueur, en particulier : une correction est une règle générale
justifiée par une famille d'au moins trois cas, et elle passe par ces principes ; si une famille d'erreurs ne peut pas
se corriger sans les contredire, c'est le principe qu'on réexamine, par écrit, avant de coder.
