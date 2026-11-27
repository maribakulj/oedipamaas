# L'ontologie commune des éventualités (version 1, 27/11)

**La décision de la propriétaire** (quatrième message, § 1) : l'option B, réifier les états comme éventualités. Avec
trois exigences :
- distinguer les états, les processus, les événements de changement et les propriétés ordinaires, sans transformer
  indistinctement tous les adjectifs en états ;
- pouvoir qualifier les états, les situer dans le temps et les relier à d'autres éventualités ;
- étudier une ontologie commune **avant** de fixer une syntaxe.

Ce document est cette étude. **Il ne fixe aucune syntaxe :** la syntaxe viendra avec la version 2 du langage
d'assertions (`docs/TRAJECTOIRE.md`), après la validation des bancs. Les références sont celles de
`docs/ETAT_DE_L_ART_SEMANTIQUE.md` : Vendler, Dowty, Bach, Moens et Steedman pour les classes aspectuelles ; Parsons et
Maienborn pour les états ; Carlson pour la distinction entre propriétés de l'individu et propriétés d'un stade ;
Barwise et Perry, Kratzer, et la paire description / situation de DnS pour les situations.

## 1. Les sortes

On distingue cinq sortes. Seules les quatre dernières sont des **éventualités**, c'est-à-dire des individus qu'on peut
qualifier, situer dans le temps et relier à d'autres.

| sorte | définition | exemples | dynamique ? | a un résultat ? | réifiée ? |
|---|---|---|---|---|---|
| **propriété ordinaire** (de l'individu) | une caractérisation de l'individu, qui ne dépend pas du moment figuré | rouge, de bois, romain, grand, barbu (en général), en marbre | — | — | **non** : elle reste une propriété du référent |
| **état** (d'un stade) | une condition que le porteur occupe pendant un intervalle, sans changement interne | nu, endormi, mort, blessé, emprisonné, chauve, agenouillé (une posture) | non | — | **oui** |
| **processus** (activité) | une éventualité dynamique, homogène, sans terme | courir, prier, chanter, pleurer | oui | non | **oui** |
| **événement de changement** (accomplissement, achèvement) | une éventualité dynamique qui culmine en un état résultant | tuer, construire, mourir, arriver, briser, emprisonner | oui | **oui** | **oui** |
| **situation** | une configuration d'éventualités et de participants, que satisfait une description | une noce, une bataille, la Cène, la pêche, une scène | — | — | **à décider** (§ 4) |

### 1.1 Ce qui sépare une propriété ordinaire d'un état

La distinction de Carlson, entre ce qui est vrai de l'individu et ce qui est vrai d'un stade de l'individu. Les tests
sont linguistiques et iconographiques :
- **un état se laisse situer par rapport au moment figuré :** « encore endormi », « déjà mort », « à présent nu ». Une
  propriété ordinaire ne le fait pas : « déjà romain » est étrange ;
- **un état peut résulter d'un événement ou le préparer :** mort ← mourir, emprisonné ← emprisonner, agenouillé ←
  s'agenouiller ;
- **un état peut être nié sans nier l'individu :** « pas encore mort ».

Le même mot peut relever des deux sortes selon son sens et son emploi : « barbu » est d'ordinaire une propriété de
l'individu, mais « un homme qui s'est laissé pousser la barbe » est un état résultant.

**La décision n'est donc pas portée par le lemme.** Elle l'est par le **sens**, dans K, et elle est confirmée par
l'emploi. Les ressources qui la renseignent sont :
- les fichiers lexicographiques de WordNet (`adj.ppl` pour les participes, `verb.stative`) ;
- les relations `state` et `result` des liens morphosémantiques ;
- les cadres d'état de FrameNet (Dead_or_alive, Being_awake, Posture…) ;
- les sous-événements de GL-VerbNet.

Quand aucune ne la renseigne, la sorte est **inconnue**, et l'adjectif reste une propriété. C'est la forme la plus
prudente : on ne crée pas d'éventualité sans fondement.

### 1.2 Ce qui sépare un état d'un processus, un processus d'un événement de changement

- **L'état** n'a pas de dynamique ; **le processus** en a une (« il dort » contre « il court »). Les postures (être
  agenouillé, être assis) sont des états, mais leur porteur les maintient : ce sont les « états davidsoniens » de
  Maienborn. Elles ont un porteur qui a quelque chose d'un agent, ce que la convention de rôle doit fixer.
- **L'événement de changement** a une culmination et un **état résultant** ; le processus n'en a pas.
  - Un événement de changement peut être figuré **en cours** : la phase préparatoire (Moens et Steedman), comme
    « Abraham s'apprête à sacrifier Isaac », « le guerrier frappe ».
  - Il peut être figuré **accompli**, par son seul état résultant (« le corps sans vie »).
  - Il peut être figuré **imminent**.
  - Ces trois figurations ne disent pas la même chose, et les libellés les distinguent.

## 2. Ce qu'on peut dire d'une éventualité

**Son type :** un sens de verbe, de nom d'événement ou d'état, ou d'adjectif d'état. Des formes de surface
différentes ont ainsi le **même type** : « chauve », « calvitie », « être chauve ».

**Ses participants :**
- les rôles d'un événement ou d'un processus (agent, patient, thème…) ;
- **le porteur** d'un état ;
- un rôle de cadre pour une situation (la mariée, l'officiant).

**Ses qualifications :** la polarité, la modalité, le chemin de contextes, comme pour toute assertion. Un état nié
(« pas encore mort ») est une éventualité niée, sans que son porteur le soit.

**Son ancrage temporel,** par rapport au moment de la situation figurée dont il fait partie (§ 3) :
- **en cours :** l'éventualité tient ou se déroule à ce moment ;
- **antérieure :** accomplie avant ; son état résultant tient ;
- **imminente :** sur le point d'avoir lieu ;
- **hors du temps figuré :** un récit, une source, l'histoire. C'est déjà une affaire de contexte.

**Ses relations à d'autres éventualités :**
- **résultat :** S est l'état résultant de E (mort ← mourir) ;
- **simultanéité :** S tient pendant E (« Orion, endormi, est aveuglé ») ;
- **cause :** E1 cause E2 ;
- **appartenance à une situation :** E fait partie de la situation Σ ;
- **succession entre situations :** Σ1 précède Σ2 (la narration, § 3).

## 3. Le temps figuré n'est pas un moment unique

**La précision de la propriétaire** (quatrième message, § 3) : une œuvre ne figure pas nécessairement un moment unique.
La narration continue, la juxtaposition d'épisodes et les représentations emboîtées ne doivent pas être exclues par
construction, même si leur réalisation est différée.

**Ce que l'ontologie dit donc.** Le moment figuré n'est pas celui de l'œuvre, c'est **celui d'une situation figurée**.
Une œuvre figure **une ou plusieurs** situations, chacune avec son moment.
- **Un seul moment :** le cas courant, une situation.
- **La juxtaposition d'épisodes :** un polyptyque, une prédelle, des registres. Plusieurs situations, chacune avec son
  moment, et une relation entre elles, souvent de succession.
- **La narration continue :** plusieurs situations dans un même espace figuré. **Le même personnage y est figuré
  plusieurs fois.**
  - C'est une question d'identité que le noyau doit pouvoir dire : deux figures, un seul individu, à deux moments.
  - Ce n'est ni une coréférence entre deux mentions d'une même figure, ni une distinction entre deux individus.
  - Il faut une relation « figure le même individu dans une autre situation », qui ne fusionne pas les figures.
- **Les représentations emboîtées :** un tableau dans le tableau, une tapisserie, un miroir, une vision, un rêve. Une
  situation est figurée **dans** un contexte de figuration emboîté. C'est un chemin de contextes
  (`docs/FONDEMENTS_SEMANTIQUES.md`, § 2.5), et la situation emboîtée a son propre moment.

L'ancrage temporel d'une éventualité se fait relativement au moment **de sa situation**. Une conséquence n'est pas
l'événement, et elle ne passe pas non plus d'une situation à une autre sans une relation entre elles.

## 4. Les situations peuvent être des référents

**La précision de la propriétaire :** ne pas décider prématurément que les situations ne peuvent pas être des
référents.

Il faut distinguer trois choses (la paire description / situation de DnS, et les situations de Barwise et Perry et de
Kratzer) :
1. **la description d'une situation :** un cadre, une définition d'Iconclass. « Les noces de Cana » est une description,
   dont les rôles (les mariés, le Christ, les serviteurs, les jarres) et les éventualités (changer l'eau en vin) sont
   des conditions ;
2. **la situation qui la satisfait :** dans le monde figuré, une configuration de participants et d'éventualités,
   localisée (« à gauche », « au registre supérieur »), datée par son moment, et qu'on peut compter (« deux scènes »).
   - **C'est un référent :** le texte en parle (« la scène », « l'épisode de droite »), et une définition peut
     l'exiger tout entière (que les conditions soient satisfaites **dans une même situation** : la question de la
     co-localisation de l'état de l'art).
3. **les relations entre situations :** la succession, la partie (un épisode est une partie d'un récit),
   l'emboîtement, et la satisfaction d'une même description par deux situations (deux Annonciations).

**Ce que cela change :**
- **une satisfaction peut être relative à une situation :** une définition est satisfaite par une situation, non par
  l'œuvre entière. Aujourd'hui, le noyau satisfait une requête sur tout le graphe : c'est le cas d'une seule
  situation ;
- **un nom de rôle de cadre** (« la mariée ») désigne un participant **d'une situation**. Il ne désigne pas la
  situation, et ne la fait pas exister à lui seul ;
- **l'hypothèse de travail,** pour la version 2 du langage : les situations sont des référents d'une sorte propre. Une
  œuvre en figure au moins une, implicite quand le texte ne les distingue pas, ce qui garde le comportement actuel
  comme cas particulier.

## 5. Ce que l'ontologie change pour la canonisation et la déduction

**La canonisation :**
- « chauve », « calvitie », « est chauve », « la calvitie de la femme » ont le **même type d'état** et le même porteur :
  la forme canonique est l'état réifié ;
- « rouge », « de bois », « romain » restent des propriétés ;
- un participe résultatif (« brisé », « tombé ») est un **état résultant**, dont l'événement est antérieur et le
  porteur le thème ou le patient selon la classe du verbe. La contre-expertise de #16 l'a montré : ce n'est jamais un
  rôle par la seule syntaxe ;
- un nom d'action (« la mort d'Anna ») est l'événement, ou l'état résultant, selon son sens : la mort comme événement
  (mourir) ou comme état (être mort). C'est une hypothèse de sens tant que le sens n'est pas choisi.

**La déduction :**
- **l'état résultant :** un événement de changement accompli implique son état résultant ;
- **la conséquence conditionnelle :** un état résultant implique un événement antérieur. Elle est analytique sous une
  condition (« mort » implique que l'être a vécu, puis est mort), et seulement abductive ailleurs (« sur un poteau »
  ne dit pas qu'on l'y a mis) ;
- **la négation :**
  - nier un état ne nie pas l'événement qui l'aurait causé (« pas encore mort » ne nie pas qu'on l'a frappé) ;
  - nier l'événement ne nie pas l'état, puisque l'état peut avoir une autre cause ;
  - la contraposition ne vaut que pour les implications analytiques (§ 3.3 des fondements).

## 6. Ce qui reste ouvert

- **les postures :** sont-elles des états ou des processus maintenus ? Et quel rôle donner à leur porteur ?
- **les noms d'agent habituels** (« un chanteur ») : désignent-ils un participant d'un processus figuré, ou une
  propriété de l'individu ? C'est l'opposition entre stade et individu, appliquée aux noms ;
- **les adjectifs de degré** (vieux, jeune, grand) : propriétés ordinaires, mais relatives à une classe de comparaison ;
- **l'identité d'un personnage à travers les situations** d'une narration continue : la relation à ajouter au régime
  de l'identité du noyau (`docs/NOYAU.md`, § 1), sans fusionner les figures ;
- **la satisfaction relative à une situation :** quand une définition doit-elle être satisfaite dans une seule
  situation ? Les bancs de la phase 1 en donnent les cas.
