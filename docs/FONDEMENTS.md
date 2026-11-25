# Les fondements conceptuels d'oedipamaas — version 2 (25 novembre 2026)

**Version 3 en cours** (`docs/PLAN_V1.md`, M0). Sa partie formelle est écrite : `docs/NOYAU.md` (langage des
requêtes, quatre valeurs, substitution globale, preuves, vérificateur). Elle remplace ici le § 4 pour la logique de la
projection, et retire la disjonction des catégories de WordNet et le principe du nom unique (§ 2). Le reste de C1 et
C2 (contextes, modalités, axiomes de disjonction explicites, exclusions et « (other) » en monde ouvert) suit.

**Amendement (25 novembre, décision de la propriétaire).** Les définitions sont « sûres d'abord » : tout ce que le
libellé dit est exigé, sauf ce que la grammaire d'Iconclass marque sûrement comme facultatif (alternatives, exemples,
renvois, numéros, « possible attributes », biographie d'un individu) ; l'analyse syntaxique n'ajoute que des
contraintes. Une erreur de lecture rend une définition trop forte, pas trop faible. Mesures : `docs/mesures/V2.md`.

**Statut.** La version 1 de ce document (même jour) a été soumise à une contre-expertise indépendante. Verdict :
« pas justes en l'état, réparables sans changer d'architecture, par des corrections de fond ». Les fautes relevées, et
reconnues : (1) un libellé d'Iconclass n'est pas uniformément une description d'image (rubriques, individus,
concepts) ; (2) l'héritage littéral des ancêtres est absurde (un lion n'a pas à montrer « earth as celestial body ») ;
(3) jeter les alternatives et les parenthèses rend les définitions fausses dans les deux sens ; (4) surtout, **montrer
n'est pas identifier** : Iconclass code d'abord qui est représenté et quel épisode, et un texte le *désigne* (« his
Eleventh Labor: stealing … the Hesperides ») bien plus qu'il ne décrit le geste littéral du libellé (« carried
off ») ; (5) la règle des genres contredisait la clôture par les ancêtres, la règle des rôles en monde ouvert
contredisait l'exigence des référents, et rien ne peut se contredire sans types disjoints. La version 2 corrige ces
points. Elle remplace la méthode des profils et des conditions de `docs/PLAN_F3.md` (§ 2), dont l'empilement de
critères ajustés après les erreurs (seuil de rareté, « deux appuis », élément absent des sœurs, saillance) était du
bricolage ; les mesures qui l'ont montré sont dans `docs/mesures/F3.md`.

## 1. Le problème

- **Entrée** : un texte humain (ou d'un descripteur d'images) sur une œuvre : cartel, notice, catalogue, texte savant,
  description visuelle ; français ou anglais.
- **Sortie** : les notations d'Iconclass de l'image, chacune avec sa preuve ; « établie » si la preuve est complète
  (la précision d'abord), « candidate » sinon, avec ce qui manque.
- **Connaissance** : Iconclass et des ressources de langue (WordNet ; d'autres à décider, § 7) ; rien d'iconographique
  écrit à la main.

Le système ne voit pas l'image ; il sait ce que le texte en dit. Or un texte dit d'une image **trois choses de nature
différente**, et Iconclass les code toutes les trois :

| Relation | Ce que le texte affirme | Niveau (Panofsky) | Exemples d'Iconclass |
|---|---|---|---|
| **figuration** | ce que l'image montre : des figures, des choses, des actions visibles | pré-iconographique | 25F23 lion, 41B2 hearth and stove, 31AA nude woman |
| **désignation** | ce que l'image est : qui est représenté, quel épisode, quelle allégorie | iconographique | 11H(PETER), 94L332, 24C19 Venus (planet) personifiée |
| **classement de l'œuvre** | de quel genre est l'image | — | 25H landscapes, 61B2(…)1 portrait, 34 nature morte |

Chacune a sa sémantique et sa preuve (§ 4). La version 1 les confondait en une seule implication.

## 2. Le cadre formel : des graphes conceptuels à contextes

Le langage d'assertions (`docs/ASSERTIONS.md`) est lu comme un **graphe conceptuel** (Sowa) : des concepts typés (un
référent, son type, son nom), des relations (rôles d'un événement, relations entre référents), et des **contextes
emboîtés** qui disent de quoi parle chaque partie du texte :

- le contexte de **l'œuvre** (support, technique, inscriptions, genre, état) ;
- à l'intérieur, le contexte du **figuré** (ce que l'image montre) ;
- à l'intérieur, le contexte du **signifié** (ce que les figures sont ou représentent : « depicted his model as a
  courtesan », « Venus is personified as a nude female figure », « girls symbolizing the three Graces ») ;
- à côté, les contextes du **monde réel** (l'artiste, l'histoire, la réception) et des **autres œuvres** (l'œuvre
  d'après, l'autre fragment, le verso).

Les types sont ordonnés par l'hyperonymie de WordNet ; deux types de fichiers lexicographiques différents de WordNet
(noun.person, noun.location, noun.artifact, noun.animal…) sont **disjoints** : c'est la seule source de contradiction
entre noms communs, avec le principe du nom unique entre noms propres. Une notation d'Iconclass est un graphe (ou un
ensemble de graphes alternatifs) écrit dans le même langage ; la vérification est une **projection** d'un graphe dans
l'autre (Sowa), dont la sémantique et la complexité sont connues, et que Prolog fait naturellement.

## 3. Les définitions : lire Iconclass (P1)

### 3.1 Même langage, pas forcément même analyseur

Les libellés sont lus dans le **même langage d'assertions** que les textes. Ils forment un corpus fermé, télégraphique,
compilé une fois hors ligne : rien n'oblige à les analyser avec l'analyseur des textes ; un analyseur plus fort, non
LLM, peut servir à la compilation, par la frontière CoNLL-U (décision § 7). La justesse des définitions se mesure, par
type de libellé.

### 3.2 La typologie des libellés

Un libellé n'a pas une sémantique uniforme. Son type se calcule par sa grammaire (les conventions d'écriture
d'Iconclass) et par WordNet, et chaque type a une sémantique, écrite une fois :

| Type | Reconnu par | Sémantique de la notation |
|---|---|---|
| **rubrique** | division et section (un ou deux caractères), titres en majuscules, termes collectifs du métalangage | aucune condition propre ; atteinte seulement par ses descendants |
| **classe** | un groupe nominal (« lion », « hearth and stove », « courtesan, hetaera ») ; « : » après une catégorie dont le terme est l'hyponyme (« other birds: dove ») | un référent figuré dont le type est sous l'une des têtes (« , » et « and » font une union de classes ; le nombre est neutre) |
| **scène** | un prédicat avec ses participants (« David beheads Goliath with a sword », « bath of Venus ») | des référents et un événement ; voir désignation (§ 4.2) |
| **individu** | une personne d'Iconclass (gabarits 11H(…), 11HH(…), 61B2(…), nom propre avec description biographique : « the apostle Peter, first bishop of Rome ») | **identité** : le nom (ou une variante) ; la description biographique n'est qu'une contrainte de compatibilité |
| **attribut ou partie** | « attributes of X: Y », « parts of … : Y » (nom relationnel avant « : ») | une relation : Y figuré **et rattaché à** X |
| **genre ou mode** | les mots de la représentation dans le libellé (« landscapes », « portrayed alone », « view of », « representations ») | un prédicat sur l'œuvre (classement, § 4.3), jamais un référent figuré |
| **concept** | division 5, « (alleg.) », Ripa, personnifications (« Youth, Adolescence, 'Iuventus' ») | une désignation allégorique : exige un pont allégorique (« personified as », « symbolizing », « allegory of ») |

### 3.3 Les parenthèses et les connecteurs se classent, ils ne se jettent pas

| Fonction | Exemples | Traitement |
|---|---|---|
| synonyme, autre nom | « Hercules (Heracles) », « Lucy (Lucia) » | variante de nom (identité) |
| désambiguïsation | « Venus (planet) », « Tigris (river) » | garde le type |
| définition | « Madonna (i.e. Mary with the Christ-child) » | fait partie de la définition |
| valeur symbolique | « hand (Father), lamb (Son), dove (Holy Ghost) » | signifié |
| alternative | « or », « alternatively », « (or standing beside) », « and/or » | ensemble de graphes alternatifs |
| exclusion | « (not in biblical context) », « (except the earth) » | condition négative (§ 4.4) |
| classe résiduelle | « (other) … » | défaut en monde fermé (§ 4.4) |
| modificateur | « (high) », « (open) », « (nude) », « (female) », « (doctrine on) » | **exigé** : il porte parfois toute la distinction de la notation (jugement 4 des définitions, `docs/mesures/V2.md`) ; quand il n'est qu'un détail, la définition n'est que trop forte |
| renvoi, numéro | « (Ripa) », « (Exodus 20:3-17) », « (11) » | hors définition ; le numéro d'un cycle (« the Twelve Labours: (11) ») est une variante de désignation (« Eleventh Labor ») |
| « possible attributes: … » | listes des individus | indices d'identification, jamais des conditions |
| « ~ » | « temple ~ Egyptian religion » | une qualification de la branche : exigée si elle distingue la notation de ses sœurs (§ 4.2), sinon compatible |

### 3.4 L'héritage est typé

La hiérarchie d'Iconclass mêle « est un » (lion sous beasts of prey), « épisode de » (94L332 sous 94L « (story of)
Hercules ») et « rubrique » (lion sous 2 « Nature »). Une notation hérite des conditions de son parent :

- si la tête de son libellé est un hyponyme (WordNet) de celle du parent : l'enfant est une espèce du parent ;
- si le parent est un récit ou une personne (« (story of) NOM », un gabarit à nom) : l'enfant en exige la personne ;
- sinon le parent est une rubrique pour elle : aucune condition.

### 3.5 Une définition par langue, unifiées

Les libellés anglais et français d'une même notation ne disent pas toujours la même chose (31D13 « adolescent, young
woman, maiden » / « adolescente, jeune fille »). Ils sont lus tous les deux ; l'alignement des deux (même notation,
mêmes positions dans la définition) donne un **lexique bilingue tiré d'Iconclass**, qui rattache les mots français aux
sens de WordNet des mots anglais correspondants (la voie F2 pour le français, abandonnée sans raison et reprise ici).
Le français ne se réduit pas à l'égalité de lemmes.

## 4. Les trois relations de preuve (P3)

Toutes se vérifient sur des assertions **autorisées** (§ 5) et **sans contradiction** (types disjoints, noms uniques,
rôles donnés des deux côtés qui diffèrent).

### 4.1 La figuration (classes, attributs, parties)

Une notation de classe est établie si un référent du contexte **figuré** a un type égal ou plus spécifique que l'une de
ses têtes, au sens que la couche de sens aligne sur la notation (F2), et dans un contexte de polarité positive (sous
une négation, l'ordre s'inverse : « angels without wings » n'établit pas « wing »). Un attribut ou une partie demande
de plus le rattachement à son porteur. La correspondance des mots traverse les catégories seulement par les
dérivations **typées** (un événement, un état, une propriété : « bathing » → bath ; jamais un agent ou un instrument :
« hold » ↛ holder) si la ressource est admise (§ 7).

### 4.2 La désignation (individus, épisodes, allégories)

- **Un individu** est établi si le texte nomme (ou reprend) un référent figuré par son nom ou une variante (§ 3.3),
  avec une description compatible : « saint Pierre » est 11H(PETER) sans que le texte dise « premier évêque de Rome ».
- **Un épisode** se définit, comme en logique classique, par son **genre prochain** et sa **différence spécifique**,
  calculés sur l'arbre : le genre est ce qu'il a en commun avec ses sœurs (le récit, la personne : 94L, Hercule) ; la
  différence est ce que sa définition a et que ses sœurs n'ont pas (les pommes des Hespérides, le onzième travail).
  Il est établi si le genre est établi (la personne désignée) **et** si le texte désigne la différence, dans le
  figuré ou dans une proposition qui dit ce qu'est l'image (« after completing his Eleventh Labor: stealing three
  golden apples… ») ; le reste de la définition doit seulement être compatible avec le figuré. Si la différence
  n'est désignée pour aucune sœur, c'est le genre qui est établi (94L), pas une sœur au hasard ; si elle l'est pour
  deux sœurs, les deux le sont.
- **Une allégorie** (type concept) est établie si un pont allégorique la désigne.

C'est la « condition différentielle » de la méthode précédente, mais définie sur les définitions structurées et
calculée, non plus sur des sacs de mots avec un seuil.

### 4.3 Le classement de l'œuvre (genres et modes)

Le genre est une propriété de l'œuvre, dans le contexte de **l'œuvre** : il se vérifie contre ce que le texte dit de
l'œuvre, pas contre les référents figurés. Il est établi si un pont dont le sujet est **cette œuvre** a pour complément
un nom de genre (« this landscape », « Portrait du comte ») ou un complément qui relève tout entier d'une branche de
genre (« this image of the sandy hills leading up to a mesa » : collines et mesa, sous les reliefs de 25H). Une
colline figurée dans un portrait établit 25H113 « hill » (figuration), jamais 25H « landscapes » (classement) : la
clôture par les ancêtres vaut dans la hiérarchie de la figuration, pas d'une relation à l'autre.

### 4.4 Les défauts en monde fermé, énoncés comme tels

Trois règles ne sont pas des implications mais des défauts (vrais faute de mieux), dérivés d'Iconclass lui-même ;
chacune est écrite, motivée, et mesurée à part :

- **la place propre l'emporte** : une personne nommée qui a sa place dans Iconclass (11H(PETER)) n'est pas codée par
  le gabarit générique 61B2(NOM) ; sans place propre, 61B2(NOM) ;
- **« (other) »** : une classe résiduelle s'applique si aucune sœur nommée ne s'applique ;
- **les exclusions** (« not in biblical context ») : vraies si le texte ne donne pas le contexte exclu.

La décision D16 (« not in biblical context » seulement sans événement) est révoquée ou réécrite sous cette forme.

### 4.5 Le sujet principal

C'est une règle de décision, mesurée par le critère : la notation désignée (§ 4.2) ou de classement (§ 4.3) qui porte
sur le complément du pont dont le sujet est cette œuvre ; à défaut, sur la première phrase figurée de la description.

## 5. L'autorisation : ce que le texte met dans l'image (P2)

Une assertion n'entre dans le contexte figuré que si le texte l'y met :

1. **un pont dont le sujet est cette œuvre** : un verbe ou un nom de représentation (« depicts X », « Portrait de
   X »), désambiguïsé (« Soutine's study of Dutch market scenes » : « study » n'est pas ici l'œuvre ; « le fragment de
   panneau A représente » : une autre œuvre si ce n'est pas celle du texte) ; l'identité de « cette œuvre » (recto,
   verso, fragments, album, œuvre d'après) est tenue ;
2. **un repère du plan de l'image** (« on the left », « au premier plan ») ou une deixis (« here », « on voit »), dans
   le contexte figuré seulement : « en bas au centre » sur une annotation situe le support, pas le figuré ;
3. **la continuité bornée** avec un référent figuré : ses parties (méronymie de WordNet), ce qu'il tient et porte, ses
   attributs, sa reprise (pronom, possessif, même nom, groupe nominal défini) ; jamais par la parenté ni la possession
   sociale (« le fils du maréchal » ne met pas le maréchal dans l'image) ; et la continuité **s'arrête** au passé
   raconté (parfait, « after », « having », « has just ») : on code le moment montré, pas l'histoire racontée ;
4. **le genre du texte** : une description visuelle est figurée de bout en bout.

Le temps du verbe n'autorise rien (le « présent de description » était une présomption, mesurée à 38 %) ; il peut
bloquer la continuité (3). L'absence de mention ne nie rien.

## 6. Ce qui est retiré

| Retiré | Pourquoi |
|---|---|
| les profils comme sacs de mots | la structure est perdue (Scholastique tenant une colombe ≠ la vision de son âme en colombe) |
| le seuil de rareté dans la décision | une quantité réglée ; la rareté ne sert plus qu'à choisir quelles définitions essayer d'abord |
| « deux appuis », « un élément qu'aucune sœur n'a » | remplacés par le genre et la différence calculés sur des définitions structurées |
| la saillance comme condition | remplacée par la règle du sujet principal (§ 4.5), assumée comme telle |
| le présent de description | une présomption |
| l'implication littérale du libellé pour les épisodes et les individus | montrer n'est pas identifier (§ 1) |
| jeter les parenthèses et les alternatives | elles se classent (§ 3.3) |
| la dérivation non typée | « hold » n'est pas « holder » |

## 7. Ce qui est écrit à la main, et les décisions à prendre

**Écrit à la main** : des règles de langue (classes fermées, ponts, repères, deixis, verbes de fabrication et
d'histoire, négation, modalité, temps qui bloque) et la **grammaire des libellés d'Iconclass** (§ 3.2 et 3.3), qui
est plus grande qu'annoncé dans la version 1 mais ne contient aucune iconographie : elle dit comment Iconclass écrit,
pas ce que les images montrent.

**Décisions de la propriétaire** (à inscrire dans `DECISIONS.md`) :

- **D17 — ressources de langue au-delà de WordNet.** Les liens morphosémantiques de WordNet (Princeton, même
  licence : dérivations typées événement / agent / instrument) ; éventuellement VerbNet, FrameNet, NomBank (rôles et
  paraphrases verbe / nom). Ce sont des ressources de langue, pas d'iconographie.
- **D18 — un analyseur plus fort, à la compilation seulement**, pour lire les libellés (non LLM, par CoNLL-U ;
  licence à vérifier).
- **D19 — la mesure.** Une sous-référence « autorisée par le texte » (la référence actuelle contient des codes que
  seul le titre fonde, contraires à D15) ; et un banc de qualification plus grand : 40 textes donnent une dizaine de
  sujets établis, dont la borne de confiance ne certifie pas 0,85 (le cahier demande 150 à 200 jugements par type).

## 8. Les limites, dites d'avance

- **Un plafond structurel** : sur les 21 sujets du banc de développement, environ 7 sont hors d'atteinte de toute
  méthode fondée sur ce que le texte affirme (le nom n'est que dans le titre ; une inférence que rien ne fonde ; l'objet
  lui-même ; la partie pour le tout ; un hyperonyme). Ce n'est pas un défaut à corriger.
- **Le lecteur se trompe**, des deux côtés ; la règle des rôles protège des omissions, pas des erreurs ; la justesse
  des définitions et de l'autorisation se mesure.
- **Le rappel restera modeste** ; la précision d'abord. Estimation de la contre-expertise avec ces corrections : une
  dizaine de sujets sur 21 en anglais, précision des sujets plausible, précision de tous les codes incertaine en
  anglais et improbable en français tant que le lexique bilingue (§ 3.5) n'est pas fait.
- **Une lacune d'Iconclass reste une lacune.**

## 9. L'ordre du travail

Le critère de `docs/PLAN_F3.md` ne change pas (précision des sujets établis et de tous les codes établis ≥ 0,85,
rappel des sujets ≥ 0,30), mesuré aussi sur la sous-référence autorisée (D19).

1. **La typologie et les définitions** (§ 3) : la justesse se mesure **par type** de libellé (au moins 20 définitions
   jugées à l'aveugle par type), pas sur un tirage global qui ne couvre ni les individus ni les épisodes.
2. **Les contextes et l'autorisation** (§ 2 et 5) : rappel des 97 éléments, précision jugée à l'aveugle.
3. **Les trois relations** (§ 4), chacune avec sa mesure et la cause de chaque erreur.
4. **La qualification** sur le banc scellé.

Les règles de `docs/PLAN_F3.md` (§ 4) restent en vigueur : une correction est une règle générale justifiée par une
famille d'au moins trois cas, et elle passe par ces principes ; si une famille d'erreurs ne peut pas se corriger sans
les contredire, c'est le principe qu'on réexamine, par écrit, avant de coder.
