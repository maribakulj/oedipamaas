# État de l'art : la représentation sémantique formelle

> **Statut.** Étude bibliographique et critique, faite le 27 novembre 2026 par un agent de recherche. Elle ne modifie
> rien dans le dépôt. Elle complète `docs/ETAT_DE_L_ART_C7.md`, qui recense surtout les **ressources et les
> analyseurs**. Ici, l'objet est différent : les **formalismes** (ce qu'ils peuvent dire, ce qu'ils ne peuvent pas
> dire, à quel coût de calcul) et leur pertinence pour un problème précis. Le problème est de décider, avec une preuve
> vérifiable, qu'une description libre d'une œuvre satisfait une définition iconographique.
>
> **Ce qui est vérifié, et comment.** Chaque référence porte une marque.
> - **[vérifié]** : j'ai vu la notice sur une source primaire ou faisant autorité. Ce sont l'API Crossref (résolution
>   des DOI), les fichiers BibTeX de l'ACL Anthology, la Stanford Encyclopedia of Philosophy (SEP), l'API de HAL, les
>   sites officiels (W3C, ISO, CIDOC, Iconclass, IJCAI) et, pour quelques livres sans DOI, des notices de
>   bibliothèque ou des comptes rendus indexés. La source de la vérification est précisée quand elle n'est pas un DOI
>   ni l'ACL Anthology.
> - **[non vérifié]** : la référence vient de ma mémoire, ou seulement de bibliographies secondaires concordantes. Je
>   ne la garde que si elle est importante, et je le dis.
>
> Une notice vérifiée garantit l'existence, les auteurs, l'année, le titre et le support. Elle ne garantit pas que
> **mon résumé du contenu** soit exact. Pour une quinzaine de travaux, j'ai lu le texte ou un extrait (résumé, PDF,
> définitions officielles) : AMR, Bos 2016, UMR, CIDOC CRM 7.1.3 (P62, P138, E36), l'aide d'Iconclass, OWL 2
> Profiles, l'entrée DRT de la SEP. Ils sont signalés « lu ». Pour les autres, le résumé du contenu vient de ma
> connaissance de la littérature.
>
> **Relecture (27/11).** Un constat [L] a été corrigé après vérification sur le tableur des liens morphosémantiques :
> die → death y est relié par les synsets (§ 13.2). Le reste de l'étude est celui de l'agent. Ses recommandations sont
> discutées, et parfois nuancées, dans `docs/COMPARAISON_FORMALISMES.md`. C'est le cas de l'héritage dans la
> hiérarchie, à typer comme le dit `docs/FONDEMENTS.md`, § 3.4.
>
> **Constats empiriques.** Quelques constats viennent de lectures **en lecture seule** des ressources déjà installées
> hors du dépôt : WordNet 3.0, le fichier des liens morphosémantiques de Princeton, FrameNet 1.7 et VerbNet 3.3. Ils
> sont marqués **[L]**. Ils servent à tester les affirmations sur les exemples d'échec du projet.

---

## Table des matières

0. Résumé
1. Le problème, posé formellement
2. Sémantique des événements, rôles, aspect, états, situations, causalité
3. Sémantique compositionnelle et sous-spécification (Montague, MRS, ERG, sémantique des trous, glue)
4. DRT, SDRT, Boxer et le Parallel Meaning Bank
5. Cadres et structure argumentale (FrameNet, VerbNet, PropBank, NomBank, SemLink, ressources françaises)
6. Représentations en graphes : AMR, UMR, UCCA, DMRS/EDS, les tâches MRP
7. Référence, identité, coréférence, quantification, pluriels, génériques, descriptions définies
8. Relations spatiales, temporelles, causales et méréologiques
9. Modalité, alternatives, négation, contextes intensionnels et sémantique de la dépiction ; logique de Belnap
10. Les niveaux propres aux descriptions d'œuvres : CIDOC CRM, Panofsky, ICON, structure d'Iconclass
11. Définitions, classification et abduction (logiques de description, OWL 2, prototypes, gloses, abduction)
12. Ontologies d'événements et de situations (DOLCE/DnS, SEM, LODE, ESO, calcul des situations et des événements)
13. Ressources lexicales formelles (WordNet, liens morphosémantiques, Lexique génératif, LCS, fonctions lexicales)
14. Tableau comparatif
15. Questions ouvertes
16. Références

---

## 0. Résumé

**Le constat principal.** Aucun formalisme de la littérature ne résout le problème tel qu'il est posé. Le problème
réunit trois choses que la littérature traite d'habitude séparément :

1. une **normalisation** des représentations, pour que « la mort de X », « X meurt » et « X est mort » se rencontrent ;
2. une **inférence définitionnelle et contextuelle**, pour que « liquide doré pressé des olives » donne « huile » ;
3. une **décision justifiée**, avec une preuve, sous incertitude lexicale et dans des contextes non factuels (ce qui
   est dépeint n'est pas ce qui est vrai).

Les formalismes « riches » (DRT, MRS, Montague) traitent bien la portée, la négation et les contextes. Ils ne disent
presque rien du point 2. Les ressources lexicales (FrameNet, VerbNet, WordNet, Lexique génératif, fonctions lexicales)
portent le savoir du point 1 et une partie du point 2. Elles n'ont pas de sémantique d'inférence propre. Les logiques
de description et les règles existentielles donnent le cadre de calcul du point 3, avec des garanties de
décidabilité. L'abduction donne le cadre de la plausibilité. Elle ne produit pas de **justification** au sens fort.

**Ce qui changerait le plus, pour le moins cher.** Trois idées de la littérature visent directement les classes
d'échec observées. Aucune n'oblige à changer d'architecture.

- **Réifier les états comme des éventualités** (Parsons ; Maienborn pour les états « kimiens »). Une propriété
  `bald(x)` devient un état `s` de type *baldness* dont `x` est le porteur. Le nom d'état (« calvitie ») et
  l'adjectif (« chauve ») désignent alors le même objet. C'est la réponse au couple *bald/baldness*.
- **Donner aux prédicats une structure d'événement avec état résultant** (Moens et Steedman ; Pustejovsky 1991 ;
  Dowty ; VerbNet et sa version GL ; la relation *Inchoative_of* de FrameNet ; les post-situations d'ESO). Avec elle,
  « corps sans vie » donne l'état *mort*, et l'état *mort* donne l'événement *mourir*, sous une condition explicite.
  C'est la réponse au couple *lifeless body → died*.
- **Compiler le sens complet d'une définition à partir de sa place dans la hiérarchie** : « chaque notation incorpore
  tous ses termes plus larges », dit la documentation d'Iconclass. Ce n'est pas un formalisme. C'est la propriété la
  plus directement exploitable de la classification elle-même.

**Ce qui ne se résout pas par la représentation.** Les inférences du type *liquide pressé des olives → huile*,
*organe de l'odorat → nez* et *mari et femme posant pour un portrait de mariage → mariés* ne sont pas des problèmes de
format. Ce sont des problèmes de **savoir définitionnel** (gloses, qualia, cadres) et de **statut épistémique**. La
première est presque une définition (WordNet : *olive oil* = « oil from olives » [L]). La deuxième en est une
(*nose* : « the organ of smell… » [L]). La troisième est une **abduction** : un portrait de mariage ne prouve pas que
les personnes sont en train de se marier. La littérature (Hobbs et al. 1993 ; Kakas, Kowalski et Toni 1992) donne le
moyen de **nommer l'hypothèse** dans la preuve, comme le noyau le fait déjà pour les sens des mots. Elle ne dispense
pas de **distinguer** les deux statuts.

**Le point le plus original pour ce projet : la dépiction.** La philosophie et la sémantique de l'image (Zimmermann
2016 ; Abusch 2020 ; Greenberg 2013, 2021) et le CIDOC CRM traitent « ce qui est dépeint » de façons opposées. Pour
la sémantique, c'est un **contexte intensionnel**, comme la croyance. Pour le CRM, c'est une **relation extensionnelle**
vers une entité (lu : P62 *depicts*, de portée E1). Le qualificateur de portée « dépeint / œuvre / histoire / source /
autre œuvre / commentaire » du projet est une version plate et correcte de la première vue. La DRT (boîtes étiquetées)
et l'UMR (dépendances modales vers des « conceveurs ») en donnent des versions plus générales.

---

## 1. Le problème, posé formellement

### 1.1 Ce qui est décidé

On note **D** l'ensemble des assertions qualifiées tirées d'une description, **L** la requête tirée d'une définition
(une étiquette), et **K** le savoir lexical (WordNet 3.0, son alignement français, les règles du noyau). La question
« la description satisfait-elle la définition ? » se lit, dans le cas certain, comme une **conséquence logique** :

> K ∪ D ⊨ ∃x̄. L(x̄), restreint au contexte « dépeint ».

L(x̄) est une conjonction (avec disjonctions et négations) d'atomes du type `type(X,W)`, `event(E,W)`,
`role(E,R,X)`, `relation(X,R,Y)`, `property(X,W)`, `name(X,[…])`.

Trois remarques en découlent.

1. **C'est un problème de réponse à une requête conjonctive sous une ontologie.** Quand K se réduit à des faits, la
   question est l'existence d'un **homomorphisme** de la requête vers les faits. Le problème est NP-complet en
   complexité combinée (Chandra et Merlin 1977). Il est polynomial en complexité de données (requête fixe). Les
   requêtes du projet sont petites ; c'est la taille et la forme de K qui comptent.
2. **La forme des règles de K fixe la décidabilité.** Des règles de Horn sans variable nouvelle (Datalog) donnent un
   calcul terminant et polynomial en données. Des règles qui **introduisent** un individu ont la forme
   `dead(x) → ∃e. event(e, die) ∧ role(e, patient, x)`. On les appelle règles existentielles, ou TGD (*tuple-generating
   dependencies*). Ce sont exactement celles dont on a besoin pour passer d'un état à l'événement qui l'a produit, ou
   d'un nom d'agent à l'événement. Avec ces règles, la réponse aux requêtes est **indécidable en général**. Elle redevient
   décidable sous des conditions syntaxiques connues :
   - l'acyclicité faible, qui garantit que la « chasse » termine (Fagin, Kolaitis, Miller et Popa 2005) ;
   - les fragments gardés de Datalog± (Calì, Gottlob et Lukasiewicz 2012) ;
   - les logiques de description de la famille EL (§ 11).

   Un noyau Prolog qui crée des termes de Skolem pour ces individus est dans ce cadre. Il termine si le graphe des
   règles est faiblement acyclique. **C'est une propriété à vérifier sur les règles, pas à supposer.**
3. **Le cas incertain n'est pas une conséquence logique.** La supervaluation sur les sens (Fine 1975) déjà en place
   en est une généralisation propre : un lien est **super-vrai** s'il vaut pour toutes les précisions admissibles
   (ici, tous les sens). Sinon, il n'est vrai que « sous hypothèse de sens ». L'abduction (§ 11) généralise la même idée
   aux hypothèses d'interprétation. Elle doit rester **un statut distinct** de la conséquence.

### 1.2 Les classes d'échec, relues dans ce cadre

| Classe d'échec observée | Nature formelle | Section |
|---|---|---|
| nom / événement (*death / die*) | deux lexicalisations d'une même éventualité ; besoin d'une nominalisation typée | 2, 5, 6, 13 |
| propriété / nom d'état (*bald / baldness*) | prédicat vs état réifié (état kimien) | 2, 13 |
| nom d'action / verbe | idem, côté événement (*the crucifixion* / *crucify*) | 5, 13 |
| rôle locatif / relation spatiale | deux encodages d'une même relation de lieu ; besoin d'une forme canonique | 2, 8, 13 |
| nom d'agent / participant (*the killer* / *x kills*) | règle existentielle nom → événement | 1.1, 13 |
| inférence contextuelle (*liquide pressé des olives → huile*) | savoir définitionnel (glose, qualia) + appariement partiel | 11, 13 |
| état → événement (*corps sans vie → mort*) | état résultant d'une structure d'événement | 2, 12 |
| rôle social inféré (*mari et femme… portrait de mariage → mariés*) | abduction ; hypothèse à nommer | 11 |
| classification par définition | subsomption et vérification d'instance (logiques de description) | 11 |

### 1.3 Ce qu'une représentation doit offrir ici

Les sections suivantes jugent chaque formalisme selon six critères. Les critères sont dérivés du problème, pas des
formalismes :

- **Normalisation.** Deux paraphrases usuelles ont-elles la même forme, ou une forme reliée par des règles sûres ?
- **Contextes.** Peut-on dire « dépeint », « selon la source », « non asserté », sans perdre la portée ?
- **Portée de la négation** et des quantificateurs, au moins dans les étiquettes (*sans*, *aucun*, *(other)*).
- **Calcul.** L'inférence est-elle décidable, et à quel coût ?
- **Preuves.** Le calcul laisse-t-il une trace lisible et vérifiable ?
- **Outillage hors ligne**, de préférence en français et en anglais.

---

## 2. Sémantique des événements, rôles, aspect, états, situations, causalité

### 2.1 Davidson et la sémantique néo-davidsonienne

**Ce que le formalisme représente.** Davidson (1967) ajoute aux verbes d'action un argument d'**événement**. Une
phrase devient une quantification existentielle sur cet événement. Les modificateurs adverbiaux deviennent des
conjoints :

> *Jones butters the toast in the bathroom with a knife*
> ∃e. butter(e, jones, toast) ∧ in(e, bathroom) ∧ with(e, knife)

L'effacement d'un modificateur devient l'élimination d'un conjoint. C'est l'argument central : il explique pourquoi
la phrase longue implique les phrases courtes sans postuler un verbe différent par nombre de modificateurs.

Castañeda (1967), dans son commentaire, propose de **séparer aussi les arguments** du verbe. La version
« néo-davidsonienne » de Parsons (1990) écrit :

> ∃e. butter(e) ∧ Agent(e, jones) ∧ Theme(e, toast) ∧ In(e, bathroom)

Parsons étend la quantification aux **états** (*Hold*) et distingue l'événement achevé (*Cul*). Higginbotham (1985)
intègre la position d'événement dans l'interface syntaxe-sémantique (identification thématique des modifieurs).
Kratzer (1996) défend une position intermédiaire : seul l'**argument externe** (l'agent) est séparé du verbe ;
l'argument interne reste un argument du prédicat.

**Ce qu'il ne représente pas, ou mal.**

- Le **temps** et l'**aspect** : l'événement n'est pas situé, et rien ne distingue « est en train de mourir » de
  « est mort ».
- La **négation** et la **quantification** mal placées. « Aucun chien n'a aboyé » n'est pas ∃e.¬bark(e). Champollion
  (2015) montre que la clôture existentielle de l'événement doit prendre la portée la plus basse, et donne une
  composition qui le garantit.
- Le **rattachement** des modificateurs : *with a knife* modifie-t-il l'événement ou le couteau ? La forme logique ne le
  dit pas, l'analyseur doit trancher.

**Propriétés formelles.** Le fragment existentiel-conjonctif est du premier ordre, sans quantificateur universel.
L'implication entre deux formes de ce fragment est un homomorphisme de requêtes conjonctives (§ 1.1). C'est
décidable, et en pratique rapide pour des phrases. La compositionnalité est assurée si la clôture de l'événement est
bien placée (Champollion 2015). Hobbs (1985, « Ontological promiscuity ») pousse la logique jusqu'au bout. Il réifie
**tout** prédicat en éventualité, y compris les états et les négations, pour garder une forme plate du premier ordre.
C'est, à peu près, la forme que le projet a adoptée.

**Pour ce problème.** La représentation actuelle (`event(E, W)`, `role(E, R, X)`) est déjà néo-davidsonienne. Ce que la
littérature ajoute, ce sont deux mises en garde :

- les **rôles** ne sont pas des primitives stables (§ 2.2) ;
- la réification devrait s'étendre aux **états** (§ 2.4), faute de quoi la représentation garde une asymétrie : les
  événements sont des individus, les propriétés ne le sont pas. C'est l'origine du couple *bald/baldness*.

### 2.2 Les rôles thématiques et leurs problèmes : les proto-rôles de Dowty

**Le problème.** Les listes de rôles (agent, patient, thème, instrument, destinataire, lieu…) n'ont jamais reçu de
définitions qui s'appliquent de façon cohérente à tous les verbes. Dowty (1991) en tire la conséquence. Il remplace
les rôles discrets par deux **proto-rôles** définis par des implications lexicales :

- **Proto-Agent** : participation volontaire, sentience ou perception, cause d'un événement ou d'un changement
  d'état, mouvement, existence indépendante de l'événement.
- **Proto-Patient** : subit un changement d'état, thème incrémental, affecté causalement, immobile par rapport à un
  autre participant, existence dépendante de l'événement.

Le **principe de sélection des arguments** dit que l'argument qui a le plus de propriétés de Proto-Agent est réalisé
comme sujet.

**Conséquence pour l'appariement.** Si la description et la définition sont analysées par des chaînes différentes, ou
par la même chaîne sur des constructions différentes, leurs rôles peuvent diverger sans que le sens diverge.

- « The bishop is holding a heart » : le *heart* est-il thème ou patient ?
- « The death of Ignatius » : *Ignatius* est-il patient ou thème de *die* ?

Un appariement **exact** des étiquettes de rôle crée des faux négatifs. Trois remèdes existent dans la littérature :

1. des **rôles propres au prédicat**, comme les éléments de cadre de FrameNet ou les Arg0–Arg5 de PropBank, avec des
   correspondances explicites (§ 5) ;
2. un **treillis de rôles compatibles**, par exemple *patient* ⊑ *undergoer* ⊒ *theme*, c'est-à-dire une
   généralisation contrôlée ;
3. un appariement sur les **propriétés de proto-rôle** plutôt que sur les étiquettes.

**Pour ce problème.** La solution 2 est la moins chère et la plus compatible avec des preuves lisibles. Chaque
généralisation de rôle devient une étape nommée de la preuve.

### 2.3 Structure des événements et aspect

**Les classes.** Vendler (1957) distingue quatre classes de prédicats : **états** (*know*, *love*), **activités**
(*run*), **accomplissements** (*build a house*) et **achèvements** (*reach the top*, *die*). Les critères sont la durée,
la télicité et la dynamicité.

**Les décompositions.** Dowty (1979) décompose ces classes en opérateurs d'une logique d'intervalles : **DO** pour
l'agentivité, **BECOME** pour le changement, **CAUSE** pour la causalité. On obtient par exemple :

> kill(x, y) ≈ CAUSE(DO(x, …), BECOME(¬alive(y)))

Bach (1986) donne une **algèbre des éventualités** parallèle à celle des pluriels et des noms de masse de Link (§ 7).
Les processus sont « massifs », les événements « comptables ».

**Le noyau de Moens et Steedman.** Moens et Steedman (1988) structurent l'événement en un **noyau** à trois parties :
un **processus préparatoire**, une **culmination** et un **état conséquent**. Ils traitent les changements d'aspect
(progressif, parfait, adverbes de durée) comme des **coercitions** d'un type à l'autre dans ce noyau. Pour eux, le
parfait *has died* parle de l'état conséquent.

**Les sous-événements de Pustejovsky.** Pustejovsky (1991a, « The syntax of event structure ») donne une structure de
sous-événements : **S** (état), **P** (processus) et **T** (transition, c'est-à-dire un processus ou un événement suivi
d'un état). *Die* est une transition dont le second sous-événement est l'état *dead*. *Close the door* est une
transition [P act(x, door)] → [S closed(door)].

**Ce qui en résulte pour l'appariement.** Ces structures donnent un **état résultant** à chaque prédicat télique. Trois
inférences deviennent formulables :

- *corps sans vie* → état dead(x) ;
- dead(x) → il y a eu un événement die(e) de patient x ;
- *le serpent d'airain est posé sur un mât* → état résultant on(serpent, mât).

La deuxième et la troisième méritent des statuts différents.

- **dead → die** est presque analytique. Est mort ce qui a vécu et a cessé de vivre. La règle est sûre pour un être
  animé. Elle exige une **condition** (« x a été vivant ») qui est une présupposition lexicale.
- **on(serpent, mât) → set(e) ∧ theme(e, serpent) ∧ goal(e, mât)** n'est **pas** une conséquence. Être sur un mât ne
  prouve pas qu'on y a été posé, même si, pour un artefact, c'est l'explication la plus probable. C'est une
  **abduction** (§ 11).

La structure d'événement ne tranche pas entre les deux. Elle rend la distinction **écrivable**.

### 2.4 États, événements et processus : états davidsoniens et états kimiens

Maienborn (2005 ; 2008) montre que les « états » ne forment pas une classe homogène.

- Les **états davidsoniens** sont *sit*, *stand*, *sleep*, *wait*, *shine*. Ils se situent dans l'espace, se perçoivent
  (*I saw him sleeping*) et se modifient par des adverbes de manière. Ce sont des éventualités au sens de Davidson.
- Les **états kimiens** sont *be tall*, *be bald*, *know*, *resemble*, *own*, ainsi que la copule et la plupart des
  adjectifs. Ils ne se localisent pas, ne se perçoivent pas comme tels et refusent la plupart des modifieurs de
  manière. Maienborn les analyse, après Kim (1976, « Events as property exemplifications »), comme des **objets
  abstraits d'exemplification** d'une propriété par un porteur à un temps. Ils ont un temps, mais pas de lieu.

**Pourquoi c'est pertinent.** Le couple *bald / baldness* est un état kimien sous deux lexicalisations. WordNet glose
*baldness* comme « the condition of having no hair on the top of the head », et relie *bald* (adjectif) à *baldness*
(nom) par un pointeur dérivationnel [L]. Il suffit de réifier la propriété :

> property(x, bald) ⇔ ∃s. state(s, baldness) ∧ holder(s, x)

« La calvitie de X » et « X est chauve » ont alors la même représentation. La distinction de Maienborn indique ce
qu'il ne faut **pas** faire. Il ne faut pas traiter tous les états comme des événements localisables. Sinon,
`relation(s, in, Y)` (« la calvitie dans la chapelle ») deviendrait une inférence admise.

**Pour la dépiction.** Les états davidsoniens (*sitting*, *kneeling*, *holding*) sont **dépeignables** : on les voit.
Les états kimiens le sont parfois (*bald*, *old*) et parfois non (*know*, *own*, *married*). C'est une piste pour
filtrer les définitions dont une condition n'est pas visible et ne peut être que déduite ou dite par le titre.

### 2.5 Les situations : Barwise et Perry, Kratzer

**Barwise et Perry.** La sémantique des situations (Barwise et Perry 1983) remplace les mondes possibles complets par
des **situations partielles**. Une situation *supporte* (s ⊨ σ) certains faits élémentaires (*infons*), et ne dit
rien des autres. Deux conséquences sont importantes ici.

- La **partialité** distingue « s supporte ¬σ » de « s ne supporte pas σ ». C'est exactement la distinction
  « faux » / « inconnu » de la logique de Belnap utilisée par le noyau (§ 9).
- Les **attitudes** et la **perception** (*see*, *believe*) prennent des situations, et non des propositions, pour
  objets. Une image est, très naturellement, une situation partielle qu'on voit.

**Kratzer.** Kratzer (1989 ; voir son entrée de la SEP, révisée en 2021) fait des situations des **parties de mondes**,
ordonnées par la relation de partie. Elle introduit l'**exemplification** : une situation exemplifie une proposition
si elle la rend vraie sans contenir de partie superflue. L'entrée de la SEP distingue aussi les **situations-sujets**
(*topic situations*) austiniennes. Ce sont les situations dont parle un énoncé, et l'énoncé est vrai **de** cette
situation.

**Pour ce problème.** Le qualificateur de portée du projet fait déjà ce travail. Il indexe chaque assertion par une
situation-sujet : la scène dépeinte, l'œuvre, son histoire, le texte source, une autre œuvre. La sémantique des
situations dit trois choses de plus.

1. Ces situations sont **partielles**. L'absence d'une assertion ne vaut pas sa négation. C'est cohérent avec
   l'hypothèse du monde ouvert (§ 11) et avec Belnap.
2. Elles peuvent être **parties** l'une de l'autre. Une scène dans un registre d'un retable fait partie de la scène du
   retable. Le projet n'a pas de relation de partie entre portées.
3. Une définition est satisfaite par **une** situation qui l'exemplifie. Pour une image à plusieurs scènes, il faut
   que les conjoints de la définition soient satisfaits **dans la même scène**. Sinon « Adam et Ève tenant le fruit »
   serait satisfait par Adam dans une scène et Ève tenant un fruit dans une autre. C'est le problème classique de la
   **co-localisation** des conjoints, et le format plat actuel ne l'empêche pas si toutes les scènes partagent la
   même portée « dépeint ».

### 2.6 États résultants et causalité

Dowty (1979) analyse la causation lexicale par CAUSE et BECOME. Levin et Rappaport Hovav (1995 ; 2005) organisent les
verbes par **gabarits de structure d'événement** :

- [x ACT⟨MANIÈRE⟩] pour les verbes de manière ;
- [[x ACT] CAUSE [BECOME [y ⟨ÉTAT⟩]]] pour les verbes de résultat causatifs ;
- [BECOME [y ⟨ÉTAT⟩]] pour les inchoatifs.

Ils montrent que ces gabarits prédisent la réalisation des arguments. Rappaport Hovav et Levin (2010) défendent la
**complémentarité manière / résultat** : une racine verbale lexicalise une manière **ou** un résultat, pas les deux.
L'analyse contrefactuelle de la causalité (Lewis 1973) est l'autre grande tradition. Elle est plus philosophique
qu'opératoire ici.

**Pour ce problème.**

- Les verbes de **résultat** (*kill*, *break*, *set on*, *make*) donnent des états résultants dépeignables. Ce sont
  eux qui permettent de satisfaire une définition événementielle par une description d'état (« un serpent de bronze
  sur un mât »).
- Les verbes de **manière** (*hammer*, *whip*, *pour*) se voient en cours. Ils sont dépeints au milieu du processus,
  et leur résultat n'est pas impliqué.
- La complémentarité donne un critère simple : **seuls** les prédicats à composante de résultat autorisent l'inférence
  « état → événement » (avec hypothèse), et **aucun** prédicat de manière ne l'autorise.

### 2.7 Outils et ressources

Il n'existe pas d'« outil de sémantique des événements » en soi. Les ressources qui en portent le savoir sont :

- **VerbNet** : prédicats sémantiques indexés par phase d'événement (*start(E)*, *during(E)*, *end(E)* dans
  VerbNet 3.3 [L]) et sous-événements explicites dans GL-VerbNet (Brown et al. 2019 ; 2022) ;
- **FrameNet** : relations *Causative_of*, *Inchoative_of* et *Precedes* entre cadres ;
- **ESO** : pré- et post-situations des événements (§ 12) ;
- les annotations d'**aspect** de l'UMR (§ 6).

Tout se lit hors ligne. Le détail est dans les sections 5, 6, 12 et 13.

### 2.8 Pour Oedipamaas

**Ce que ça changerait.**

- **Réifier les états kimiens** : `property(X, bald)` équivaut à `state(S, baldness), holder(S, X)`. C'est une règle
  bidirectionnelle sûre, à condition que la nominalisation adjectif → nom soit fournie par le lexique (pointeur
  dérivationnel de WordNet [L], fonction lexicale S0 du RL-fr, § 13).
- **Ajouter une structure d'état résultant** aux prédicats téliques, tirée de VerbNet, de FrameNet *Inchoative_of* ou
  d'ESO. Deux statuts de règles doivent être distingués :
  - « état → événement » **analytique**, sous condition (*dead → died*, si animé) ;
  - « état → événement » **abductif** (*on a pole → was set on a pole*).
- **Un treillis de rôles** plutôt qu'une égalité de rôles, chaque généralisation étant une étape de preuve.
- **La co-localisation** : un identifiant de scène, ou situation, dans la portée « dépeint », pour que tous les
  conjoints d'une définition soient satisfaits dans la même scène.

**Ce que ça ne changerait pas.** L'inférence contextuelle (*oil*, *nose*, *bride*) relève du savoir définitionnel
(§ 11, § 13).

**Risques.** Les règles existentielles état → événement créent des individus nouveaux. Il faut garantir l'acyclicité
faible (§ 1.1) : par exemple, interdire qu'une règle événement → état résultant et une règle état → événement se
relancent mutuellement sans fin. Il faut aussi éviter le **double comptage** : l'événement inféré et un événement
explicite du même type doivent pouvoir être identifiés, ce qui pose une question de coréférence d'événements.

---

## 3. Sémantique compositionnelle et sous-spécification

### 3.1 Montague et la théorie des types

**Ce que le formalisme représente.** Montague (1973, « The proper treatment of quantification in ordinary English »,
dit PTQ) traduit un fragment de l'anglais dans une **logique intensionnelle typée**. Les types de base sont *e*
(entités), *t* (valeurs de vérité) et *s* (indices, ou mondes-temps). Les types complexes sont des fonctions
⟨a, b⟩. La traduction est un **homomorphisme** de l'algèbre syntaxique vers l'algèbre sémantique : c'est la définition
précise de la compositionnalité.

Les syntagmes nominaux quantifiés reçoivent le type ⟨⟨e,t⟩,t⟩, celui des quantificateurs généralisés (Barwise et
Cooper 1981, § 7). La portée est obtenue par **quantification dans**. Les contextes intensionnels sont traités par les
mondes et le type *s* : *seek a unicorn* sans existence de licorne.

**Ce qu'il ne représente pas.** Montague ne dit rien du **lexique**. *Die* et *death* ne reçoivent aucune relation : ce
sont des constantes. Il ne dit rien non plus du discours (pas d'anaphore inter-phrastique), ni des événements. Ces
derniers peuvent être ajoutés ; Champollion (2015) le fait.

**Propriétés formelles.** La logique d'ordre supérieur typée est **indécidable** en général. On ne raisonne pas dans
cette logique. On s'en sert pour **construire** des formes logiques, puis on réduit (β-réduction) vers une formule
du premier ordre, quand c'est possible, pour l'inférence. La compositionnalité est stricte. Elle a un coût : une
ambiguïté de portée donne plusieurs dérivations.

**Pour ce problème.** Le λ-calcul est un bon **outil de construction** pour les étiquettes, qui sont courtes et
formulaires. Une petite grammaire typée des étiquettes (« X holding Y », « X ~ Y », « (other) X (with NAME) »)
donnerait des requêtes dont la forme est garantie. Pour les descriptions libres, Montague n'apporte rien sans une
grammaire à large couverture (§ 3.2).

### 3.2 La sous-spécification : MRS, l'ERG et les outils DELPH-IN

**Ce que le formalisme représente.** La **Minimal Recursion Semantics** (Copestake, Flickinger, Pollard et Sag 2005)
représente le sens d'une phrase comme un **sac plat de prédications élémentaires**. Chacune porte une étiquette
(*handle*). La portée n'est pas fixée : elle est **contrainte** par des relations *qeq* (égalité modulo
quantificateurs) entre trous et étiquettes. Une MRS sous-spécifiée représente d'un coup toutes les lectures de
portée. On en **résout** une quand on en a besoin. Copestake, Lascarides et Flickinger (2001) donnent l'algèbre de
construction compositionnelle de ces structures.

La MRS est produite par l'**English Resource Grammar** (ERG), une grammaire HPSG de large couverture développée
depuis les années 1990 (Flickinger 2000). Le consortium DELPH-IN fournit les outils :

- l'analyseur **ACE** (*Answer Constraint Engine*, site consulté), en C, qui fonctionne hors ligne sur CPU ;
- les bibliothèques **PyDelphin** pour manipuler les MRS ;
- les bancs arborés.

Deux formes dérivées sont des graphes :

- **DMRS**, la MRS « de dépendances » (Copestake 2009, « Slacker semantics ») ;
- **EDS**, les *Elementary Dependency Structures* (Oepen et Lønning 2006).

Bender, Flickinger, Oepen, Packard et Copestake (2015) défendent une **séparation des couches** : la grammaire donne
la part du sens qui est **compositionnelle** ; le reste (coréférence, sens lexical, pragmatique) vient d'autres
modules.

**Ce qu'il ne représente pas.**

- Les **sens lexicaux** : les prédicats de l'ERG sont des lemmes avec une distinction grossière (`_hold_v_1`), sans
  synset.
- Le **discours**, et le savoir du monde.
- Le **français** : à ma connaissance, aucune grammaire DELPH-IN du français n'atteint la couverture de l'ERG
  [non vérifié].

**Propriétés formelles.** La MRS est une **description** de formules, pas une formule. La résolution d'une MRS en
formules complètes est un problème de contraintes de dominance. Koller, Niehren et Thater (2003) montrent l'équivalence
entre la sémantique des trous et les contraintes de dominance, et Fuchss et al. (2004) relient MRS aux contraintes de
dominance. Pour les MRS « bien formées » (nets), l'énumération des lectures est efficace. Le raisonnement **sur**
les MRS non résolues, sans énumération, n'a pas de calcul de conséquence général.

**Pour ce problème.** La parenté est frappante. Le format du projet (assertions plates avec identifiants) **est**
une MRS sans trous ni contraintes *qeq*. Les qualificateurs par assertion (polarité, modalité, portée) jouent le rôle
que les étiquettes et les trous jouent en MRS, mais **assertion par assertion**. Cela suffit pour une négation
atomique (« X ne tient pas le fruit »). Cela ne suffit pas pour une négation qui porte sur une **conjonction**
(« personne ne tient le fruit » ≠ « quelqu'un ne tient pas le fruit »), ni pour un quantificateur dans la portée d'un
autre.

La MRS montre **l'extension minimale** : attacher les qualificateurs non plus aux assertions mais à un **contexte**
(une étiquette de groupe), et laisser les contextes s'emboîter. C'est aussi, à la notation près, ce que fait la DRT
(§ 4).

### 3.3 La sémantique des trous et la sémantique glue

**La sémantique des trous.** La *hole semantics* (Bos 1996, « Predicate logic unplugged ») généralise l'idée de la
MRS à n'importe quel langage logique « débranché ». Les formules ont des trous et des étiquettes, et des contraintes
de dominance entre eux. Bos l'applique à la logique des prédicats et aux DRS. Reyle (1993) avait donné, avec l'UDRT,
une DRT sous-spécifiée **et** un calcul de déduction direct sur les représentations non résolues. C'est l'une des
rares propositions de raisonnement sans énumération des lectures.

**La sémantique glue.** La *glue semantics* (Dalrymple, dir., 1999) compose les sens en **logique linéaire** à partir
des structures fonctionnelles de LFG. Chaque ressource sémantique est consommée exactement une fois, et les lectures
de portée sont les différentes **preuves** de la même conclusion.

**Pour ce problème.** La sémantique glue est élégante. Elle suppose une grammaire LFG, et n'a pas d'outillage
français à large couverture que je connaisse. La sémantique des trous est utile **conceptuellement** : elle dit qu'on
peut garder un format plat et ajouter la portée par des contraintes, sans réécrire le format.

### 3.4 Pour Oedipamaas

**Ce que ça changerait.**

- **Côté étiquettes** : une petite grammaire compositionnelle typée, avec λ-termes et une portée explicite pour
  *(other)*, *without*, *not* et *with NAME*. Elle donnerait des requêtes dont chaque partie est justifiée par une
  règle de grammaire, donc citable dans une preuve. Les étiquettes sont un langage contrôlé de fait. C'est l'endroit où
  la compositionnalité stricte paie.
- **Côté format** : passer des qualificateurs par assertion à des qualificateurs par **contexte emboîtable**. C'est
  l'extension minimale, dans l'esprit de MRS et de la sémantique des trous.

**Ce que ça ne changerait pas.** Aucune de ces théories ne résout la normalisation lexicale ni l'inférence
contextuelle.

**Risques.** L'ERG est l'analyseur symbolique le plus précis disponible pour l'anglais, et il tourne hors ligne. Il
n'existe pas d'équivalent français. L'adopter créerait une asymétrie anglais / français dans la chaîne. Sur des
descriptions libres, longues et parfois fautives, la couverture d'une grammaire de précision est inférieure à celle
d'un analyseur statistique. Je n'ai pas vérifié de chiffre récent ; c'est à mesurer.

---

## 4. Discourse Representation Theory, SDRT, Boxer et le Parallel Meaning Bank

### 4.1 La DRT

**Ce que le formalisme représente.** La DRT (Kamp 1981 ; Kamp et Reyle 1993 ; Kamp, van Genabith et Reyle 2011 pour
la version longue) représente un discours par une **DRS** ⟨U, Con⟩ : un univers de **référents** de discours et un
ensemble de **conditions**. Ses traits distinctifs sont les suivants (lu : entrée DRT de la SEP, Geurts, Beaver et
Maier, révisée en 2024).

- Les indéfinis introduisent des référents. Ils n'ont pas de quantificateur propre.
- La **négation**, le **conditionnel** et la **quantification** sont des **sous-DRS** :
  - ¬K est une sous-DRS dont les référents sont confinés. « Pedro n'a pas d'âne » ne fournit pas d'antécédent à un
    « il » ultérieur.
  - K ⇒ K′ : la boîte antécédent est accessible à la boîte conséquent. Cela donne aux indéfinis de l'antécédent une
    force universelle (phrases « à âne »).
  - Un quantificateur est une condition duplexe K (Q x) K′, avec une restriction et une portée.
- L'**accessibilité** est une relation réflexive et transitive entre DRS. Elle détermine quels référents peuvent servir
  d'antécédents à une anaphore. Elle traverse les frontières de phrases.
- Les attitudes, les modalités et le discours rapporté sont des **boîtes étiquetées** (par exemple, une DRS de
  croyance attachée à un agent). La version de Kamp, van Genabith et Reyle (2011) détaille ces représentations.

**Ce qu'il ne représente pas.** La DRT ne donne pas de lexique, ni de rôles canoniques (ils viennent d'ailleurs). Elle
n'impose pas de structure rhétorique (c'est la SDRT). Elle ne traite pas la vérité dans la fiction ou l'image en tant
que telle, même si les boîtes étiquetées s'y prêtent (Maier 2017, § 9).

**Propriétés formelles.** Une DRS se traduit en logique du premier ordre. La DRT a donc la complexité de cette logique :
la validité est semi-décidable. Les fragments sans conditionnel ni quantificateur universel retombent dans le
fragment existentiel-conjonctif avec négation, qui est décidable. La construction des DRS est compositionnelle dans
les versions à λ-DRT (Boxer, § 4.3).

**Pour ce problème.** La DRT est **le formalisme qui correspond le mieux aux qualificateurs du projet** :

| Qualificateur du projet | Équivalent DRT |
|---|---|
| polarité neg | condition ¬K, référents confinés |
| modalité « non asserté » | boîte modale ◇K, ou boîte d'attitude |
| portée (dépeint / œuvre / histoire / source / autre œuvre / commentaire) | boîtes étiquetées par une situation ou un contexte |
| énonciateur (auteur / source citée) | boîte d'attitude « selon s » |
| alternatives | disjonction K ∨ K′ |
| coréférence, distinction | égalité de référents ; résolution sous accessibilité |

La différence est qu'en DRT ces contextes **s'emboîtent** et **contraignent l'anaphore**. Dans le format plat, un
référent introduit sous une négation peut être réutilisé à tort par une autre assertion. Dans « il n'y a pas de
serpent ; il est en bronze », le second « il » ne peut pas désigner le serpent. L'accessibilité est **la** règle qui
manque pour empêcher ces liens.

### 4.2 La SDRT

**Ce que le formalisme représente.** La SDRT (Asher et Lascarides 2003) segmente le discours en unités reliées par des
**relations rhétoriques** : *Narration*, *Elaboration*, *Explanation*, *Background*, *Contrast*, *Result*… Elle les
infère par une logique non monotone (la *glue logic*) à partir d'indices lexicaux et de savoir du monde. La structure
contraint à son tour l'anaphore (la **frontière droite**) et l'ordre temporel : *Narration* implique la succession,
*Explanation* l'antériorité de la cause.

**Pour ce problème.** Une description d'œuvre mêle des segments de **dépiction** (« à gauche, un homme tient… »), de
**contexte** (« commandé en 1520 par… »), d'**interprétation** (« symbole de la Passion ») et de **citation** (« selon
la Légende dorée… »). Ce sont, en SDRT, des segments reliés par *Background*, *Elaboration* ou *Commentary*. Le
qualificateur de portée du projet est une approximation de cette segmentation au niveau des assertions. La SDRT
donnerait deux gains :

1. propager une portée à **tout un segment** (une phrase qui commence par « Selon la légende » colore les suivantes,
   jusqu'à une rupture) ;
2. ordonner les événements d'une scène narrative.

**Limite.** Il n'existe pas, à ma connaissance, d'analyseur SDRT complet et robuste, hors ligne, pour le français
[non vérifié]. Les analyseurs de discours existants prédisent des structures, avec les incertitudes d'un classifieur.

### 4.3 Boxer, le Groningen Meaning Bank et le Parallel Meaning Bank

**Boxer.** Boxer (Bos 2008 ; 2015) construit des DRS à large couverture pour l'anglais, à partir d'analyses CCG. Les
événements sont néo-davidsoniens, et les rôles sont tirés de VerbNet (d'après ma connaissance des articles). Les DRS sont traduisibles en logique du premier
ordre et utilisées avec des démonstrateurs et des constructeurs de modèles.

**Les banques de sens.** Le **Groningen Meaning Bank** (Bos et al. 2017) a annoté des textes anglais de DRS.
Le **Parallel Meaning Bank** (Abzianidze et al. 2017) étend l'annotation à des traductions alignées. La publication
de 2017 annonce l'anglais, l'allemand, l'italien et le néerlandais. Les DRS du PMB utilisent des sens WordNet et des
rôles de type VerbNet [contenu non vérifié dans les données]. **Le français n'y figure pas**, d'après les sources
consultées (la page « about » du PMB cite aussi le japonais et le chinois). Le site du PMB était indisponible (erreur
503) au moment de la vérification.

**Pour ce problème.** Le PMB est la preuve qu'une représentation de type DRS, **plus** des sens WordNet, **plus**
des rôles, est annotable à grande échelle et analysable automatiquement. C'est l'architecture la plus proche du
projet dans la littérature. Il y a deux écarts. Le PMB vise la phrase et le petit texte, pas l'appariement avec des
définitions. Et ses analyseurs récents sont neuronaux.

### 4.4 Pour Oedipamaas

**Ce que ça changerait.**

- Adopter la **structure de boîtes** de la DRT comme sémantique des qualificateurs : un contexte par portée et par
  énonciateur, des contextes emboîtables, et une **règle d'accessibilité** pour la coréférence. C'est une
  réinterprétation du format, pas un changement d'architecture : les assertions restent plates, chacune porte un
  identifiant de contexte, et les contextes forment un arbre.
- La satisfaction d'une définition devient : **il existe une boîte du type « dépeint »** (et ses boîtes accessibles)
  qui vérifie la requête.

**Ce que ça ne changerait pas.** Le lexique et l'inférence contextuelle.

**Risques.** La résolution de l'anaphore sous accessibilité suppose une analyse fiable de la portée de la négation et
des attitudes dans les descriptions. Des erreurs à ce niveau créent des faux négatifs nouveaux (un référent confiné
à tort). La SDRT est hors de portée d'un outillage hors ligne fiable en français. Une segmentation par **indices
explicites** (« selon », « d'après », « la légende rapporte », « le titre »), sans relations rhétoriques complètes,
est plus réaliste.

---

## 5. Cadres et structure argumentale

### 5.1 FrameNet et les relations entre cadres

**Ce que la ressource représente.** FrameNet (Fillmore 1982 pour la sémantique des cadres ; Baker, Fillmore et Lowe
1998 pour la ressource ; Ruppenhofer et al. pour la documentation de référence) décrit des **cadres**. Un cadre est une
situation schématique avec ses **éléments** (FE) : *core*, périphériques et extra-thématiques. Il est évoqué par des
**unités lexicales** (LU) **de toutes catégories** : verbes, noms, adjectifs. Des relations relient les cadres entre
eux. Dans FrameNet 1.7, j'ai relevé [L] dix types de relations : *Inheritance*, *Using*, *Subframe*, *Perspective_on*,
*Precedes*, *Causative_of*, *Inchoative_of*, *See_also*, *ReFraming_Mapping* et *Metaphor*.

**Constats sur les exemples du projet [L]** (FrameNet 1.7, 1 221 cadres, 13 572 unités lexicales dans `luIndex.xml`) :

- Le cadre **Death** est évoqué par *die.v*, *death.n*, *perish.v*, *demise.n*, *starvation.n*… Le verbe et le nom
  évoquent **le même cadre**, avec le même FE *Protagonist*. Le couple *death / die* est donc unifié au niveau du
  cadre.
- Le cadre **Dead_or_alive** contient *dead.a*, *lifeless.a*, *deceased.a*, *alive.a*… Et la relation
  **Death *Inchoative_of* Dead_or_alive** existe. *Killing *Causative_of* Death* aussi. La chaîne *lifeless → dead →
  Death → Killing* est donc **explicite** dans FrameNet, avec le type de chaque lien (inchoatif, causatif).
- **Personal_relationship** contient *husband.n*, *wife.n*, *spouse.n*, *couple.n*, *married.a*… ; *wedding.n*
  évoque **Forming_relationships**, et *Forming_relationships* est *Inchoative_of* *Personal_relationship*. En
  revanche, **ni *bride.n* ni *groom.n* (au sens marié) ne sont des unités lexicales de FrameNet 1.7**. *Groom.v* est
  dans *Grooming*. Le cas *mari et femme → mariés* n'est donc pas couvert directement.
- *bald.a*, *baldness.n* et *olive.n* ne sont pas des unités lexicales de FrameNet 1.7. *oil.n* est dans *Food* et
  *Substance*. *nose.n* est dans *Body_parts*. *press.v* n'est pas dans un cadre d'extraction de substance.

**Ce que FrameNet ne représente pas.**

- Pas de **sémantique d'inférence** : les relations entre cadres ne sont pas des axiomes logiques. *Inheritance*
  ressemble à une subsomption, mais *Using* ou *See_also* n'ont pas de lecture logique fixe.
- Pas de **définitions** des objets (*olive oil*).
- Une **couverture inégale** : le lexique de base des scènes iconographiques (vêtements, gestes, attributs, objets
  rituels) n'est que partiellement couvert.

**Propriétés formelles.** C'est un réseau, pas une logique. On peut le traduire en règles. Par exemple, *Inheritance*
avec correspondance des FE devient une subsomption de rôles, et *Inchoative_of* une règle d'état résultant. La
décidabilité est alors celle des règles choisies (§ 1.1).

### 5.2 VerbNet et GL-VerbNet

**Ce que la ressource représente.** VerbNet (Kipper Schuler 2005 ; Kipper, Korhonen, Ryant et Palmer 2008) organise
les verbes anglais en **classes de Levin** étendues. Chaque classe porte des **rôles thématiques** (Agent, Theme,
Destination, Instrument…), des **cadres syntaxiques**, et pour chaque cadre des **prédicats sémantiques** indexés par
phase.

Dans VerbNet 3.3 [L], 329 fichiers de classes, la classe *put-9.1* donne `motion(during(E), Theme)` et
`path_rel(start(E), Theme, ?Initial_Location, ch_of_loc, …)`, puis une relation de lieu à la fin de l'événement.
L'**état résultant** est donc lisible : Theme est à Destination à end(E).

La version **GL-VerbNet** (Brown et al. 2019, sur les verbes de transfert ; Brown et al. 2022 pour l'ensemble)
remplace ces phases par une **structure de sous-événements** inspirée du Lexique génératif : e1, e2, e3, avec des
prédicats comme `has_location`, `¬has_state`, `cause`. Les états avant et après deviennent explicites. Les fichiers
installés localement sont en version 3.3, donc **sans** cette structure GL.

**Ce qu'elle ne représente pas.** Les noms et les adjectifs (VerbNet ne contient que des verbes). Les rôles sont
généraux, avec les problèmes vus au § 2.2.

**Pour ce problème.** VerbNet est la meilleure source d'**états résultants** typés pour les verbes. C'est la base de
la règle « *set on a pole* → on(serpent, mât) à la fin », et inversement pour l'hypothèse abductive.

### 5.3 PropBank, NomBank, SemLink

- **PropBank** (Palmer, Gildea et Kingsbury 2005) annote des rôles **propres à chaque sens de verbe** (Arg0–Arg5,
  ArgM). Arg0 est en général proto-agent, Arg1 proto-patient. C'est le vocabulaire de rôles d'AMR (§ 6).
- **NomBank** (Meyers et al. 2004) annote les **arguments des noms** avec les mêmes rôles que PropBank. *His death*
  reçoit le sens de *die* avec *his* comme Arg1. C'est **exactement** l'information qui manque pour le couple nom /
  événement : quel argument du nom correspond à quel rôle du verbe.
- **SemLink** (Stowe et al. 2021 pour SemLink 2.0) relie les trois ressources : PropBank, VerbNet et FrameNet. Il
  donne pour un sens verbal ses correspondances de rôles d'une ressource à l'autre. La version 2.0 vise VerbNet 3.3,
  les cadres PropBank unifiés et FrameNet 1.7 (d'après la description de l'article et du dépôt).

### 5.4 Les ressources françaises

- **French FrameNet (projet ASFALDA)**. Candito et al. (2014) décrivent la construction des cadres et du lexique, par
  **domaines notionnels**, avec environ une centaine de cadres. Djemaa, Candito, Muller et Vieu (2016) décrivent
  l'annotation de quatre domaines (transactions commerciales, positions cognitives, causalité, communication
  verbale). La notice HAL de 2016 indique 98 cadres, 662 mots évoquant un cadre, 872 sens et environ 13 000
  annotations. Ces domaines **ne couvrent pas** l'essentiel du vocabulaire iconographique (mort, supplice, gestes,
  vêtements, objets).
- **Verb∋Net**. Pradet, Danlos et de Chalendar (2014), puis Danlos, Pradet, Barque, Nakamura et Constant (2016),
  adaptent VerbNet au français à partir de **LVF** et du **Lexique-Grammaire**. Les classes VerbNet sont peuplées de
  verbes français et les alternances sont adaptées.
- **Dicovalence**. Ce dictionnaire de valence de plus de 3 700 verbes et plus de 8 000 cadres a été réalisé à Louvain
  (van den Eynde et Mertens). Il suit l'**approche pronominale** : chaque place argumentale est définie par les
  pronoms qu'elle accepte. Mertens (2010) le convertit pour le TAL. Il est distribué sous licence LGPL-LR (d'après le
  manuel et la notice ORTOLANG trouvés en ligne).
- **LVF** (*Les Verbes français*, Dubois et Dubois-Charlier 1997, [non vérifié directement]). C'est une classification
  sémantico-syntaxique de très large couverture, présentée par François, Le Pesant et Leeman (2007). Une version
  « LVF+1 » est diffusée par le RALI (Montréal) (page consultée).

### 5.5 Pour Oedipamaas

**Ce que ça changerait.** Les cadres sont **la réponse la plus directe** à la classe d'échec « catégorie
grammaticale ». Un verbe, un nom et un adjectif qui évoquent le même cadre (*die / death*, *dead / lifeless*) se
rencontrent au niveau du cadre. Deux usages possibles, du plus léger au plus lourd :

1. **Index de normalisation** : FrameNet sert seulement à dire que deux lemmes de catégories différentes évoquent le
   même cadre, avec la correspondance de leurs FE. On garde la représentation lemme + rôle, et on ajoute une règle
   d'équivalence par cadre. Chaque règle est citable dans une preuve (« *death.n* et *die.v* évoquent Death, FE
   Protagonist »).
2. **Représentation par cadres** : les événements et les états deviennent des instances de cadres. C'est plus
   uniforme, mais c'est une deuxième couche de polysémie. *Hold.v* évoque sept cadres dans FrameNet 1.7 [L]. Il faudra
   donc une supervaluation sur les cadres en plus des sens.

**Ce que ça ne changerait pas.** Les lacunes de couverture (*bride*, *bald*, *olive* absents [L]) et l'absence de
définitions. Les ressources françaises sont **trop partielles** pour porter seules la normalisation côté français. Le
chemin réaliste passe par l'alignement WordNet français → synsets anglais → cadres (via les correspondances
WordNet-FrameNet, ou VerbNet pour les verbes).

**Risques.** Les relations entre cadres n'ont pas de sémantique logique fixe. Il faut choisir, relation par relation,
la règle qu'on en tire, et l'écrire comme un axiome nommé. *Inchoative_of* donne « état résultant ». *Causative_of*
donne « cause ». *Inheritance* donne une subsomption. *Using* ne donne **rien** de sûr.

---

## 6. Représentations en graphes : AMR, UMR, UCCA, DMRS/EDS, MRP

### 6.1 AMR

**Ce que le formalisme représente** (lu : Banarescu et al. 2013). L'AMR (*Abstract Meaning Representation*)
représente une phrase comme un **graphe orienté enraciné étiqueté**. Les nœuds sont des concepts : des sens PropBank
(`die-01`) ou des lemmes. Les arcs sont des rôles : `:ARG0`, `:ARG1`, `:location`, `:mod`, `:polarity`… Les
**réentrances** représentent la coréférence intra-phrastique.

L'AMR **abstrait la syntaxe** : « he described her as a genius », « his description of her: genius » et « she was a
genius, according to his description » reçoivent **le même** AMR. Les nominalisations sont ramenées au verbe :
« the boy's destruction of the room » donne `destroy-01`, et l'article précise : « We never say "destruction-01" in
AMR ».

**Ce qu'il ne représente pas** (lu, même article). L'AMR ne représente pas la morphologie flexionnelle du **temps** et
du **nombre**. Il omet les **articles**. Il n'a **pas de quantificateur universel**. La négation est un attribut
`:polarity -` sans portée explicite. Des extensions ont été proposées : temps et aspect (Donatelli, Regan, Croft et
Schneider 2018) ; quantification et portée (Pustejovsky, Lai et Xue 2019).

**Propriétés formelles** (lu : Bos 2016). Bos donne une syntaxe récursive des AMR et une **traduction systématique
vers la logique du premier ordre**, avec un traitement propre de la négation. Les AMR **sans variables récurrentes**
sont dans le **fragment à deux variables** de la logique du premier ordre, qui est **décidable**. La définition
courante de l'AMR ne permet d'exprimer qu'**un quantificateur universel par phrase au plus**. Une extension simple de
la syntaxe et de la traduction suffit à représenter la projection et la portée.

**Pour ce problème.** L'AMR fait **par construction** la normalisation nom / verbe que le projet cherche :
`destroy-01`, jamais `destruction-01`. C'est l'argument le plus fort en sa faveur. Trois réserves :

1. la normalisation repose sur l'annotateur ou sur l'analyseur, et les analyseurs AMR sont neuronaux ;
2. l'AMR n'a pas de mécanisme de contexte (portée dépeinte, source) ;
3. les sens PropBank sont plus grossiers que les synsets WordNet, et le lien entre les deux n'est que partiel.

### 6.2 UMR

**Ce que le formalisme représente** (lu : Van Gysel et al. 2021). L'UMR (*Uniform Meaning Representation*) part de
l'AMR et l'étend dans deux directions.

- **Au niveau de la phrase** :
  - une annotation d'**aspect** à cinq valeurs de base, *State*, *Habitual*, *Activity*, *Endeavor* et *Performance*,
    organisées en **treillis** avec des valeurs plus fines et plus grossières. *Performance* est utilisé pour les
    processus qui atteignent un état résultant achevé ; il correspond aux achèvements et accomplissements de Vendler ;
  - un nœud **scope** optionnel pour la portée relative des quantificateurs et de la négation, avec une conversion
    vers la logique du premier ordre.
- **Au niveau du document** : des **dépendances de coréférence, temporelles et modales**, qui peuvent franchir les
  frontières de phrase. Les dépendances modales relient les événements à des **conceveurs** (*conceivers*, par
  exemple l'auteur) avec une **force modale** et une polarité. Les valeurs sont tirées de FactBank : affirmatif
  complet, affirmatif partiel, affirmatif neutre, négatif neutre… Les événements sous un prédicat modal ou un prédicat
  de discours rapporté reçoivent les annotations MODAL et QUOT.

**Pour ce problème.** La **dépendance modale** de l'UMR est la version la plus proche, dans la littérature des
représentations en graphes, des qualificateurs « énonciateur », « modalité » et « polarité » du projet. Elle est plus
riche : la force est graduée, et l'emboîtement est possible (l'auteur rapporte la croyance d'un sénateur, qui est
neutre sur un événement). Le treillis d'aspect est aussi directement utile : *State* vs *Performance* est la
distinction état / événement achevé du § 2. L'UMR n'a **pas** de notion de dépiction. On pourrait la loger comme un
conceveur particulier (« l'œuvre ») sous l'auteur.

### 6.3 UCCA

L'UCCA (Abend et Rappoport 2013) est une annotation **multilingue et grossière**. Elle découpe le texte en **scènes**
(*Scenes*), chacune avec une relation principale qui est un **processus** (P) ou un **état** (S), des participants
(A), des adverbiaux (D) et des éléments de liaison. Elle est faite pour être annotée par des non-spécialistes, et ne
dépend pas d'une langue.

**Pour ce problème.** L'idée de **scène** et la distinction P / S rejoignent les §§ 2.4 et 2.5. Le niveau de détail
(pas de sens lexicaux, pas de rôles fins) est trop faible pour la vérification de définitions.

### 6.4 DMRS et EDS ; la comparaison des tâches MRP

- **DMRS et EDS** sont les formes en graphe de la MRS (§ 3.2). Ce sont des graphes de dépendances sémantiques dérivés
  d'une analyse grammaticale. Ils sont donc **cohérents par construction**, et dépendent de la couverture de l'ERG.
- **Les tâches MRP** (Oepen et al. 2019 ; 2020 ; notices vérifiées, liste des cadres de mémoire) ont unifié dans un même format de graphe et une même métrique
  plusieurs cadres : DM et PSD (dépendances bilexicales), EDS, UCCA, AMR, puis, en 2020, les graphes DRS (DRG) et PTG,
  ainsi qu'un volet multilingue. Leur apport principal est la **comparaison** : les cadres diffèrent par l'**ancrage**
  (nœuds liés aux mots ou non), la **compositionnalité** et la **granularité**. Il n'y a pas de cadre qui domine sur
  tous les axes.

### 6.5 Pour Oedipamaas

**Ce que ça changerait.** Ces cadres apportent surtout des **conventions de normalisation éprouvées**. On peut les
adopter sans adopter les analyseurs :

- ramener les nominalisations d'événements au prédicat verbal (convention AMR) ;
- typer l'aspect par un treillis (UMR) ;
- représenter la modalité et l'énonciation par des dépendances vers des conceveurs (UMR) ;
- garder une portée explicite par un nœud de portée (UMR, Pustejovsky et al. 2019).

**Ce que ça ne changerait pas.** Les analyseurs de ces cadres sont presque tous neuronaux. Leur qualité en français est
faible (voir les chiffres de `docs/ETAT_DE_L_ART_C7.md`, § 4.2). Ils rendent une analyse unique, sans hypothèses
nommées, ce qui contredit le principe de ne jamais choisir un sens en silence.

**Risques.** Adopter AMR comme format pivot ferait perdre ce que le projet a déjà : les sens WordNet, la portée par
assertion et l'énonciateur. Le bon usage est l'**emprunt de conventions**, pas l'adoption du format.

---

## 7. Référence, identité, coréférence, quantification, pluriels, génériques, descriptions définies

### 7.1 Descriptions définies et noms propres

**Les théories.** Russell (1905) analyse « le F est G » comme ∃x(F(x) ∧ ∀y(F(y) → y = x) ∧ G(x)) : existence,
unicité, prédication. Strawson (1950) objecte que l'existence et l'unicité sont **présupposées**, pas assertées. Les
deux positions et leurs suites sont présentées dans l'entrée « Descriptions » de la SEP (Ludlow). En DRT, une
définie est une **anaphore** : on cherche un référent accessible, et à défaut on l'accommode.

**Pour ce problème.** Les définitions iconographiques contiennent des définies qui ne sont **pas** des descriptions
uniques au sens de Russell. Elles désignent par un **rôle** : « *the* bishop of Antioch, Ignatius ». La condition
pertinente n'est pas l'unicité dans la scène. C'est l'**identité** entre une figure dépeinte et un individu
historique ou légendaire. Cette identité est donnée de trois façons :

- par un nom (« Ignace ») ;
- par une description de rôle (« l'évêque d'Antioche ») ;
- par des **attributs** (« possible attributes: heart »).

Le format `name(X, [aliases])` couvre le premier cas. Le deuxième se traite par une règle d'identification
définitionnelle. Le troisième est **abductif** (§ 9.4, § 11) : un cœur ne prouve pas qu'il s'agit d'Ignace.

### 7.2 Quantificateurs généralisés

Barwise et Cooper (1981) traitent les déterminants comme des relations entre ensembles : *every*, *some*, *most*,
*two*, *no*. Ils dégagent des universaux, dont la **conservativité** : Q(A, B) ⇔ Q(A, A ∩ B). Pour le projet, le seul
quantificateur explicite est le fait `number`. Les définitions iconographiques utilisent peu de quantificateurs.
Les cas sont « *three* kings », « *two* angels », « *(other)* diseases », « *several* saints ». Les descriptions en
utilisent davantage (« *all* the apostles », « *none* of the figures »). Le quantificateur *no* et la négation des
définitions (« without », « not ») sont les seuls à poser un problème de portée (§ 3, § 4).

### 7.3 Pluriels et groupes : Link

**Ce que le formalisme représente.** Link (1983) donne une **sémantique en treillis** des pluriels et des noms de
masse. Le domaine contient des atomes et des **sommes** (a ⊕ b). Un prédicat pluriel est la fermeture par somme du
singulier : `*man`. Les lectures **distributives** (chacun tient un fruit) et **collectives** (ils soulèvent ensemble
la table) se distinguent par l'application du prédicat aux atomes ou à la somme. Landman (2000) combine cette algèbre
avec les événements : les rôles s'appliquent à des sommes, et l'on peut sommer les événements.

**Pour ce problème.** Le format du projet n'a pas de sommes.

- « **Adam and Eve** holding the fruit » est ambigu entre une lecture **collective** (ensemble ils tiennent un fruit)
  et une lecture **distributive**. Une description « Ève tend le fruit à Adam » satisfait-elle la définition ? Si
  *holding* est distributif, non : Adam ne tient pas le fruit. Si c'est un rôle sur la somme, oui. Le choix est une
  **ambiguïté**, et la supervaluation en donne un traitement propre : satisfait sous la lecture collective, non
  satisfait sous la lecture distributive, donc « sous hypothèse ».
- « **husband and wife** posing » : la somme (le couple) est l'agent de *pose*. *Couple.n* est dans le cadre
  *Personal_relationship* de FrameNet [L].
- Les définitions **collectives** (« a group of… », « the twelve apostles ») demandent un individu-groupe avec ses
  membres. WordNet a la **méronymie de membre** (`#m` / `%m` [L]).

### 7.4 Génériques et espèces : Carlson

Carlson (1977) analyse les pluriels nus comme des **noms d'espèces** (*kinds*). « Dogs are barking » réalise
l'espèce dans des stades ; « dogs bark » est générique. L'entrée de la SEP sur les généralisations génériques (Leslie
et Lerner) fait le point sur les théories ultérieures.

**Pour ce problème.** Les **définitions** sont des descriptions d'espèces de scènes : « monsters ~ reptiles »,
« contagious diseases ». Les **descriptions** parlent d'individus. Satisfaire une définition, c'est, pour une
instance, **réaliser l'espèce**. C'est l'opération de vérification d'instance des logiques de description (§ 11).
Elle n'a rien de générique. Les phrases génériques de la description (« le lion symbolise la force ») relèvent de la
portée « commentaire » : ce ne sont pas des faits sur la scène.

### 7.5 Coréférence et distinction

La coréférence intra- et inter-phrastique est traitée en DRT par l'accessibilité (§ 4), en AMR par la réentrance (dans
la phrase seulement), et en UMR par des dépendances de coréférence au niveau du document. Les faits `same` et
`distinct` du projet sont une version plate et correcte. Deux points de la littérature sont utiles.

- **Hypothèse du nom unique.** Les logiques de description ne la font pas par défaut (deux noms peuvent désigner le
  même individu). Prolog la fait implicitement (deux constantes distinctes sont distinctes). Le projet a choisi des
  identifiants **et** des faits `distinct` explicites. C'est la position la plus prudente, et elle doit être gardée :
  deux mentions (« un homme », « le saint ») ne sont pas distinctes par défaut.
- **Coréférence d'événements.** Une description peut mentionner deux fois le même événement (« il est crucifié… la
  crucifixion a lieu… »). C'est aussi le problème du double comptage, quand une règle infère un événement déjà
  mentionné (§ 2.8).

### 7.6 Pour Oedipamaas

**Ce que ça changerait.**

- Ajouter des **individus-sommes** (groupes) avec une relation de membre, et traiter la distributivité comme une
  ambiguïté soumise à la supervaluation.
- Typer les identifications d'individus : par **nom**, par **rôle définitionnel**, par **attribut**. Seules les deux
  premières peuvent être certaines.

**Ce que ça ne changerait pas.** L'inférence contextuelle.

**Risques.** Les sommes augmentent le nombre d'homomorphismes possibles, donc le coût de l'appariement. Il faut aussi
une règle claire pour le nombre : « two angels » contre une description avec trois anges. Avec la lecture « au moins
deux », la définition est satisfaite ; avec « exactement deux », elle ne l'est pas. Iconclass ne dit pas lequel. C'est
une question à poser au propriétaire, pas à la littérature.

---

## 8. Relations spatiales, temporelles, causales et méréologiques

### 8.1 Le temps : l'algèbre des intervalles d'Allen

**Ce que le formalisme représente.** Allen (1983) définit **13 relations de base** entre intervalles : *before*,
*meets*, *overlaps*, *starts*, *during*, *finishes*, leurs inverses, et *equals*. Le raisonnement se fait par
propagation de contraintes, avec une table de composition. La consistance de chemin est polynomiale, mais
**incomplète** pour l'algèbre complète.

**Propriétés formelles.** La satisfiabilité d'un réseau de contraintes dans l'algèbre complète est **NP-complète**.
Nebel et Bürckert (1995) identifient la sous-classe **ORD-Horn** : c'est la sous-classe traitable maximale contenant
les relations de base, et la consistance de chemin y est complète.

**ISO-TimeML.** ISO-TimeML (Pustejovsky, Lee, Bunt et Romary 2010 ; norme ISO 24617-1, édition de 2012 citée dans la
littérature, édition courante non vérifiée) annote les **événements** (EVENT), les **expressions temporelles**
(TIMEX3) et des **liens**. Les TLINK sont des relations temporelles dérivées d'Allen. Les **SLINK** sont des relations
de **subordination** : modale, factive, contre-factive, évidentielle, négative, conditionnelle. Les ALINK sont
aspectuels.

**Pour ce problème.** Le temps explicite est rarement nécessaire : une image dépeint en général un moment. Il devient
nécessaire dans trois cas :

1. les **images narratives continues**, où plusieurs moments sont dépeints ;
2. les définitions qui ordonnent (« after the flood », « before his martyrdom ») ;
3. la relation **événement → état résultant** (§ 2.3), qui suppose « avant / après ».

Pour les trois, l'ordre partiel *before* / *overlaps* suffit. L'algèbre complète d'Allen n'est pas nécessaire.
Les **SLINK** d'ISO-TimeML sont, en revanche, une typologie utile des contextes non factuels, à rapprocher du
qualificateur de modalité.

### 8.2 L'espace : RCC-8 et ISO-Space

**Ce que le formalisme représente.** Le **RCC** (*Region Connection Calculus*, Randell, Cui et Cohn 1992) part d'une
relation primitive de **connexion** C(x, y) entre régions. Il en définit **huit** relations de base, le RCC-8 :
DC (déconnecté), EC (contact extérieur), PO (chevauchement partiel), EQ (égal), TPP et NTPP (partie propre
tangentielle ou non), et leurs inverses.

**Propriétés formelles.** La satisfiabilité dans RCC-8 complet est **NP-complète**. Renz et Nebel (1999) identifient
une sous-classe traitable maximale (Ĥ8) contenant les relations de base.

**ISO-Space.** ISO-Space (Pustejovsky, Moszkowicz et Verhagen 2011 ; norme ISO 24617-7, deuxième édition de 2020)
annote les **lieux**, les **entités spatiales**, les **chemins**, les **événements de mouvement**, et trois types de
liens : topologiques (QSLINK, fondés sur RCC-8), d'orientation (OLINK) et de mouvement (MOVELINK).

**Pour ce problème.** Les prépositions des définitions (« on a pole », « in a cave », « under a tree », « at the
feet of ») sont des relations spatiales **qualitatives et grossières**. Deux remarques.

- L'**image** n'est pas l'espace. Une relation dépeinte est une relation dans la **projection** 2D. « On » dans une
  image peut être un **support** dans la scène (le serpent est fixé sur le mât) ou une **superposition** dans le plan
  (le serpent passe devant le mât). La sémantique de l'espace pictural (Greenberg 2021, § 9) traite précisément cet
  écart.
- La classe d'échec « **rôle locatif / relation spatiale** » demande une **forme canonique unique** :
  `role(E, location, Y)` et `relation(X, in, Y)` doivent pouvoir se rencontrer. La règle est simple quand l'événement
  et son participant sont au même endroit : si E est en Y et X est un participant de E, alors X est en Y (sous
  hypothèse pour certains rôles). Mais elle **n'est pas** universelle : dans « He threw the stone into the river »,
  l'agent n'est pas dans la rivière. La Lexical Conceptual Structure de Jackendoff (§ 13) donne la forme canonique la
  plus nette : des fonctions de lieu (AT, IN, ON) et de chemin (TO, FROM, VIA) qui s'appliquent aussi bien aux
  événements qu'aux objets.

### 8.3 Méréologie et méréotopologie

**Ce que le formalisme représente.** La méréologie est la théorie formelle de la **relation de partie** (Simons 1987 ;
entrée « Mereology » de la SEP, Varzi). Ses axiomes vont de la méréologie de base (ordre partiel) à la méréologie
extensionnelle générale (supplémentation forte, existence des sommes). La **méréotopologie** (Casati et Varzi 1999)
lui ajoute la **connexion**, d'où le RCC, pour parler de contact, de frontières et de trous.

**Côté lexique.** WordNet distingue **trois méronymies** [L] : de partie (`#p` / `%p`), de membre (`#m` / `%m`) et de
substance (`#s` / `%s`). *Nose* (organe) est une partie de *face* ; *olive oil* a pour holonyme de substance **olive**
(« small ovoid fruit of the European olive tree; important food and source of oil » [L]). La relation entre *olive
oil* et *olive*, dont on a besoin pour « pressé des olives », **existe donc dans WordNet**, comme méronymie de
substance.

**Pour ce problème.** Le projet n'exprime la partie que par des prépositions (*of*). Or au moins trois relations
distinctes passent par *of* : partie (le nez de X), substance (l'huile d'olive) et possession (le manteau de X). Les
définitions en ont besoin : « the organ of smell », « hands of X », « relics of ». Une relation `part_of` typée
(partie, membre, substance) avec les axiomes de la méréologie de base (transitivité pour partie, **pas** pour
membre), et alimentée par WordNet, est une extension petite et sûre.

### 8.4 La causalité

Trois représentations de la causalité coexistent dans la littérature.

1. **Lexicale** : CAUSE dans les décompositions (Dowty 1979 ; Levin et Rappaport Hovav), *Causative_of* dans
   FrameNet, `cause` dans VerbNet.
2. **Contrefactuelle** : Lewis (1973), et l'entrée de la SEP sur les théories contrefactuelles de la causalité
   (Menzies et Beebee).
3. **Dynamique** : *Initiates* et *Terminates* du calcul des événements (§ 12).

Pour le projet, seule la première est opératoire. Elle suffit pour relier un événement causatif (*kill*) à son
résultat (*dead*).

### 8.5 Pour Oedipamaas

**Ce que ça changerait.**

- Une relation **`part_of` typée** (partie, membre, substance), alimentée par la méronymie de WordNet. Elle sert
  « organ of smell → nose », « oil from olives » et les groupes.
- Une **forme canonique des relations de lieu**, avec une règle explicite et typée de passage rôle locatif ↔ relation
  spatiale, valable pour certains rôles seulement.
- Un ordre **avant / après** minimal, réservé aux états résultants et aux images narratives.

**Ce que ça ne changerait pas.** RCC-8 et Allen complets sont **disproportionnés** : leurs distinctions fines (EC vs
PO, *meets* vs *overlaps*) ne sont jamais exprimées dans les définitions, ni décidables à partir d'une description
textuelle.

**Risques.** Confondre la relation spatiale dans la scène avec la relation dans le plan de l'image. Il faut décider,
pour chaque préposition, si elle est lue « dans la scène » (par défaut) ou « dans l'image » (« in the foreground »,
« at the left »). Ce sont deux portées différentes.

---

## 9. Modalité, alternatives, négation, contextes intensionnels, dépiction ; logique de Belnap

### 9.1 Mondes possibles et modalité de Kratzer

**Les théories.** La sémantique des mondes possibles (entrée « Possible Worlds » de la SEP, Menzel) interprète la
nécessité et la possibilité comme des quantifications sur des mondes accessibles. Kratzer (1977 ; 2012) relativise les
modaux à une **base modale**, c'est-à-dire un ensemble de propositions (ce qu'on sait, les circonstances), et à une
**source d'ordre** (les normes, les souhaits, le cours normal des choses). *Must* et *can* sont alors une
quantification universelle ou existentielle sur les mondes de la base les mieux classés.

**Pour ce problème.** La modalité « non asserté » du projet regroupe plusieurs choses que Kratzer distingue :

- l'**épistémique** : « probablement saint Pierre » ;
- la **déontique** ou **téléologique**, rare ici ;
- les **alternatives** : « saint Pierre ou saint Paul ».

Les alternatives sont une disjonction : la définition est satisfaite si **toutes** les branches la satisfont
(certain), ou si **une** branche la satisfait (sous hypothèse). C'est la même logique que la supervaluation sur les
sens. Elle est cohérente avec ce que le noyau fait déjà.

### 9.2 Contextes intensionnels : discours rapporté et attitudes

Dans « selon la *Légende dorée*, Ignace fut livré aux lions », le contenu est **sous un énonciateur**. Il ne s'agit pas
d'un fait de la scène, ni d'un fait historique asserté par l'auteur. La DRT (boîtes d'attitude, § 4), l'UMR
(dépendances modales vers des conceveurs, et l'annotation QUOT, § 6.2) et ISO-TimeML (SLINK évidentiel, § 8.1) en
donnent des représentations. Le qualificateur « énonciateur » du projet est le même objet, aplati.

### 9.3 La sémantique de la dépiction

C'est le point le plus spécifique au projet, et le plus mal servi par les formalismes de TAL.

**La dépiction est un contexte intensionnel.** Zimmermann (2016, « Painting and opacity ») étudie l'**opacité** des
verbes de dépiction et des rapports de dépiction : *paint*, *depict*, *portray*, *represent*. « Le tableau représente
une licorne » n'implique pas qu'il existe une licorne. « Le tableau représente Ignace » ne permet pas de substituer
salva veritate tout autre nom du même individu : on ne peut pas passer à « le tableau représente l'auteur de sept
lettres ». C'est le comportement des verbes intensionnels étudiés depuis Montague (*seek*). La notice du chapitre
est vérifiée ; je n'ai pas pu consulter le texte, et ce résumé vient de ma connaissance de la littérature.

**Le contenu d'une image comme ensemble de mondes.** Abusch (2020, « Possible-worlds semantics for pictures ») et
Greenberg (2013, « Beyond resemblance » ; 2021, « Semantics of pictorial space ») donnent aux images une sémantique
**propositionnelle**. Le contenu d'une image est l'ensemble des mondes, ou des couples monde-point de vue, qui se
**projettent** sur elle selon une règle géométrique (une projection perspective, par exemple). Il en découle trois
propriétés, qui sont des thèses de ces auteurs ou des conséquences directes de leur cadre (résumé de ma part, notices
vérifiées).

1. Une image est **très spécifique** sur certaines choses (formes, disposition spatiale, couleurs visibles) et **très
   peu** sur d'autres. Elle ne fixe pas l'identité des individus, le nom des personnages, les relations invisibles
   (parenté, mariage, intention) ni les événements passés ou futurs.
2. Une image ne contient **ni négation, ni disjonction, ni quantification universelle** au sens où un texte en
   contient. « Il n'y a pas de serpent » n'est pas dépeignable comme tel. Une absence se voit seulement comme la
   présence d'autre chose à cet endroit.
3. L'**identité** d'une figure (« c'est Ignace ») n'est pas dans le contenu projectif. Elle vient d'un
   **conventionnel** : titre, inscription, attributs, tradition. C'est précisément le niveau **iconographique** de
   Panofsky (§ 10).

L'entrée « Depiction » de la SEP (Hyman et Bantinaki, révisée en 2025) présente les théories rivales de la dépiction :
ressemblance, expérience (*seeing-in*), théories structurales ou sémiotiques. Walton (1990, *Mimesis as
Make-Believe*) analyse les images comme des **accessoires dans un jeu de faire-semblant**. Ce qui est « vrai dans
l'image » est ce qu'on doit imaginer. Maier (2017) traite les **noms fictionnels** dans une sémantique
psychologiste de type DRT : ce sont des référents de discours dans des représentations mentales, sans porteur réel.

**Pour ce problème.** Trois conséquences directes.

1. **La satisfaction est relative à un contexte de dépiction**, pas au monde : DEPICT(œuvre, φ). Le qualificateur de
   portée « dépeint » est la bonne idée. Il faut le lire comme un **opérateur intensionnel**, et en tirer les
   conséquences. Les faits dépeints ne doivent pas se mélanger aux faits historiques (Ignace est mort à Rome ; la scène
   ne le montre pas forcément). Et les **noms** sous dépiction désignent des personnages (des rôles dans une
   fiction ou une tradition), pas forcément des individus historiques.
2. **La description est un discours sur un contenu dépeint.** Il y a deux niveaux d'intensionnalité : l'auteur
   asserte que l'œuvre dépeint que φ. Et les définitions iconographiques mélangent le **dépeignable** (« holding the
   fruit ») et le **non dépeignable** (« bishop of Antioch », « (with NAME) », « contagious diseases »). Pour le non
   dépeignable, une description ne peut satisfaire la définition que par un **nom**, un **titre** ou une
   **identification par attributs** (abductive). Cette typologie des conditions d'une définition est sans doute le
   gain le plus concret de cette littérature pour le projet.
3. **La négation dans une définition** (« without », « not ») porte sur le contenu dépeint. Une description qui ne
   mentionne pas X ne prouve pas que X est absent de l'image (monde ouvert ; § 9.4). La définition « sans X » ne peut
   donc être **certaine** que si la description dit explicitement l'absence, ce qui est rare. Sinon elle est
   « inconnue ».

**Ce que le CIDOC CRM fait à la place** (§ 10.1). La propriété P62 *depicts* a pour portée E1 *CRM Entity* :
quelque chose est dépeint, et ce quelque chose est une entité. C'est une vue **extensionnelle**. Elle convient à la
documentation (cette photographie dépeint la reine Élisabeth II). Elle convient mal à la fiction et à l'iconographie
(ce tableau dépeint un dragon). Le CRM ne prétend pas faire une sémantique de la dépiction. Il fournit une relation
documentaire.

### 9.4 Négation, monde ouvert, logique de Belnap et bitreillis

**Belnap.** Belnap (1977, « A useful four-valued logic ») propose quatre valeurs pour un ordinateur qui reçoit des
informations de plusieurs sources : **T** (dit vrai), **F** (dit faux), **B** (dit vrai et dit faux : contradiction
reçue) et **N** (rien de dit). Ces valeurs forment deux ordres.

- L'ordre de **vérité** va de F à T, avec B et N incomparables entre eux.
- L'ordre de **connaissance** (ou d'information) va de N à B, avec T et F incomparables entre eux.

La négation échange T et F et fixe B et N. La conséquence (« de premier degré ») ne permet pas de tout déduire d'une
contradiction : c'est une logique **paraconsistante** (entrée de la SEP, Priest, Tanaka et Weber).

**Les bitreillis.** Ginsberg (1988) généralise cette structure en **bitreillis** : deux treillis sur le même ensemble,
l'un de vérité, l'autre de connaissance. Il en fait un cadre uniforme pour le raisonnement par défaut, les
probabilités et les sources multiples. Fitting (1991) en tire une sémantique de la **programmation logique** : le
point fixe d'un opérateur monotone pour l'ordre de connaissance. Arieli et Avron (1996) en étudient la conséquence.

**Négation par échec et négation explicite.** Prolog interprète ¬p comme « p n'est pas prouvable » (négation par
échec, Clark 1978, avec la sémantique de complétion). C'est une hypothèse de **monde clos**. Les logiques de
description (§ 11) et la sémantique des situations (§ 2.5) sont en **monde ouvert**. La logique à quatre valeurs du
projet a l'avantage de séparer les deux :

- F : la description dit que non ;
- N : la description ne dit rien.

Le risque est qu'une négation par échec de Prolog réintroduise le monde clos en silence, par exemple dans une règle
`\+ type(X, serpent)`.

**La supervaluation.** La supervaluation sur les sens (Fine 1975) produit des **lacunes** : vrai sous certains sens,
faux sous d'autres, donc ni super-vrai ni super-faux. Belnap traite des **excès** (B) et des lacunes (N). Les deux se
combinent si l'on garde deux dimensions distinctes. La première est l'**information reçue** (T, F, B, N par contexte et
par énonciateur). La seconde est la **robustesse à l'interprétation** : vrai pour toutes les lectures, ou pour
certaines. Le statut « sous hypothèse de sens » appartient à la seconde dimension.

**Pour ce problème.**

- **Calculer les valeurs de Belnap par contexte.** Une contradiction entre l'auteur et une source citée (« l'auteur
  dit X ; selon la légende, non-X ») n'est **pas** une valeur B dans la scène dépeinte. C'est T dans un contexte et F
  dans un autre. Le qualificateur d'énonciateur doit être appliqué **avant** l'agrégation de Belnap.
- **Garder la négation explicite séparée de la négation par échec**, et n'utiliser cette dernière qu'à l'intérieur du
  noyau (pour la recherche), jamais pour conclure F.
- **Ne pas confondre** la valeur N (rien n'est dit) et le statut « sous hypothèse » (dit, mais pas pour tous les
  sens).

### 9.5 Pour Oedipamaas

**Ce que ça changerait.**

- **Typer les conditions des définitions**, ce qui est le gain principal de la sémantique de la dépiction :
  - **dépeignables** : objets, gestes, postures, dispositions, états davidsoniens ;
  - **conventionnelles** : identités, noms, rôles ;
  - **non dépeignables** : relations sociales, causes, histoire, maladies sans signe visible.

  Chaque type a sa propre façon d'être satisfait. Les dépeignables le sont par une assertion de portée « dépeint ».
  Les conventionnelles par un nom, un titre ou un attribut. Les non dépeignables par une assertion explicite de la
  description, de toute portée.
- Lire la portée « dépeint » comme un **opérateur intensionnel** : pas d'export des faits historiques vers la scène, et
  des noms qui désignent des personnages.
- Calculer **Belnap par contexte et par énonciateur**, puis agréger.

**Ce que ça ne changerait pas.** L'appariement lexical.

**Risques.** La frontière dépeignable / non dépeignable est parfois floue : *old*, *dead* (un corps), *married* (une
alliance ?). Le typage des conditions demande un jugement humain sur un échantillon de définitions. La classification est grande : il faudra **mesurer**, sur un échantillon, la part de chaque type avant
d'en faire une règle.

---

## 10. Les niveaux propres aux descriptions d'œuvres

### 10.1 CIDOC CRM (ISO 21127)

**Ce que le modèle représente.** Le CIDOC CRM est une ontologie de référence pour la documentation du patrimoine
(Doerr 2003). La version officielle courante est la **7.1.3** (février 2024, statut « Official (ISO
Correspondence) », page des versions consultée). La norme correspondante est **ISO 21127:2023**, troisième édition.
Meghini et Doerr (2018) en donnent une expression en **logique du premier ordre**. Le modèle est **centré sur les
propriétés** et sur les **événements** : la plupart des faits documentaires (production, acquisition, modification,
attribution) sont des événements avec des participants, des lieux et des dates.

**Ce qui concerne la dépiction** (lu, définitions officielles de la version 7.1.3) :

- **P62 *depicts*** relie un E24 *Physical Human-Made Thing* à un **E1 *CRM Entity***. La note de portée dit :
  « Depicting is meant in the sense that an instance of E24 Physical Human-Made Thing intentionally shows, through
  its optical qualities or form, a representation of the entity depicted ». La propriété porte un raffinement
  **P62.1 *mode of depiction*** (un E55 *Type*).
- **E36 *Visual Item*** désigne « the intellectual or conceptual aspects of recognisable marks and images », c'est-à-dire
  le **prototype** visuel, indépendant de son support physique. La note précise que P62 « can be regarded as a
  shortcut of the more fully developed path » : E24 → **P65 *shows visual item*** → E36 → **P138 *represents*** → E1.
  Ce chemin, en plus, « captures the optical features of the depiction ».
- **P138 *represents*** va de E36 à E1. Sa note dit : « Any entity may be represented visually ». Elle porte P138.1
  *mode of representation*.
- Côté événements, **E5 *Event*** comprend « distinct, delimited and coherent processes and interactions of a
  material nature ». **E7 *Activity*** comprend les « actions intentionally carried out by instances of E39 Actor that
  result in changes of state ». **E3 *Condition State*** est l'état d'une chose physique sur une durée.
- Pour les **interprétations**, la classe **E13 *Attribute Assignment*** (sous-classe de E7) comprend « the actions
  of making assertions about one property of an object or any single relation between two items or concepts ». C'est
  l'acte d'attribution, avec son auteur et sa date. La propriété P129 *is about* (E89 → E1) existe aussi ; je n'ai pas
  relu sa note.

**Ce qu'il ne représente pas.**

- La dépiction est **extensionnelle** : l'objet dépeint est une entité E1. Dans l'exemple officiel de P62, *La Liberté
  guidant le peuple* (E22) dépeint la révolution de Juillet (E7). Rien ne distingue « dépeint un dragon » (aucun
  dragon n'existe) de « dépeint la reine ». Il faut créer une entité-personnage, ou passer par un **type** (E55).
- Le **contenu dépeint** (qui fait quoi dans la scène) n'est pas modélisé au-delà de « dépeint X ». Les rôles dans la
  scène ne sont pas dans le CRM.

**Propriétés formelles.** L'ontologie est exprimable en OWL et en logique du premier ordre (Meghini et Doerr 2018).
C'est une ontologie de **documentation**, pas un calcul d'inférence lexicale.

**Pour ce problème.** Le CRM confirme, et nomme, la distinction de portée du projet :

| Portée du projet | CIDOC CRM |
|---|---|
| l'œuvre elle-même | E22 *Human-Made Object* (E24) |
| ce qui est dépeint | P62, ou P65 → E36 → P138 |
| l'histoire de l'œuvre | E12 *Production*, E8 *Acquisition*, E11 *Modification* (des E5 / E7) |
| une interprétation, une attribution | E13 *Attribute Assignment* |
| une source textuelle | E33 *Linguistic Object* / E73 *Information Object*, P129 *is about* |

Les noms de classes de ce tableau figurent dans la version 7.1.3 ; seules les notes de P62, P138, E36, E5, E7 et
E13 ont été relues.

C'est utile pour **nommer** les portées et pour un éventuel export. Ce n'est **pas** utile pour décider la
satisfaction, puisque le CRM ne représente pas le contenu de la scène.

### 10.2 Les niveaux de Panofsky et leur formalisation (ICON)

**Les trois niveaux.** Panofsky (1939, *Studies in Iconology*, chapitre d'introduction ; résumé de ma part) distingue
trois strates de sens :

1. le **sujet primaire ou naturel**, factuel et expressif (un homme, un fruit, un geste de chagrin), objet de la
   **description pré-iconographique** ;
2. le **sujet secondaire ou conventionnel** (Adam et Ève, la Chute, l'allégorie de la Prudence), objet de
   l'**analyse iconographique**, qui demande la connaissance des sources textuelles et des types ;
3. la **signification intrinsèque ou contenu**, objet de l'**interprétation iconologique** (les valeurs « symboliques »
   d'une époque).

Chaque niveau est contrôlé par un « principe correctif » historique : l'histoire du style, l'histoire des types,
l'histoire des symptômes culturels.

**ICON.** L'ontologie ICON (Sartini, Baroncini, van Erp, Tomasi et Gangemi 2023) formalise ce schéma pour décrire des
**interprétations** d'œuvres. D'après l'article et la documentation w3id :

- elle modélise les **reconnaissances** aux niveaux pré-iconographique, iconographique et iconologique ;
- la version 2.1.0 a ajouté les classes *Preiconographical Subject*, *Iconographical Subject* et *Iconological Subject*
  (avec *Material*, *Color* et *Role*) ;
- elle est évaluée par des questions de compétence, de la reconnaissance simple à des scénarios complexes.

Les interprétations sont attribuées à un auteur et à des sources, ce qui rejoint le qualificateur d'énonciateur.

**Pour ce problème.** Le schéma de Panofsky est **exactement** la structure de l'inférence demandée.

- La **description** est surtout pré-iconographique (« un vieillard en habit d'évêque tenant un cœur »), avec des
  îlots iconographiques (« saint Ignace »).
- La **définition** est iconographique (« the bishop of Antioch, Ignatius »).
- Passer de l'une à l'autre, c'est une **identification** (sujet primaire → sujet secondaire). Elle est sûre quand un
  nom ou un titre la donne. Elle est **abductive** quand elle repose sur des attributs (§ 11).

ICON donne le vocabulaire pour **enregistrer** ces identifications avec leur niveau et leur auteur. Il ne donne pas le
moyen de les **calculer**.

### 10.3 La structure d'Iconclass (d'après sa documentation)

**Ce que la documentation décrit** (lu : page d'aide « basics » d'Iconclass ; Couprie 1983 pour une présentation
ancienne).

- **Dix divisions principales** (0 à 9). Les divisions 1 à 5 sont générales et 6 à 9 spéciales : 7 est la Bible, 9 la
  mythologie classique. La division 0, l'art abstrait, a été ajoutée en 1996.
- **Une hiérarchie notationnelle.** Un deuxième chiffre donne jusqu'à neuf subdivisions, une majuscule un troisième
  niveau (25 lettres, J exclu), puis des chiffres de nouveau. La documentation dit que chaque notation « incorporates
  all of its iconographical broader terms ». Le texte qui explique la notation est son **corrélat textuel**, c'est-à-dire
  la **définition** du concept.
- **Le texte entre parenthèses.** À certains endroits, une formule comme « with NAME » invite à insérer un nom, un
  nombre, ou les deux, entre parenthèses : 25G41(ROSE). Les places vides comme 25G41(…) font partie du système. Les
  noms explicites n'apparaissent dans le navigateur que s'ils ont une **garantie littéraire** dans la bibliographie
  Iconclass.
- **Les clés** (*keys*), entre parenthèses avec un signe +, ajoutent une nuance : 25F23(LION)(+12) est un lion
  héraldique. Certaines clés se prolongent par une **queue** de chiffres : 25FF241(+511) est une licorne dont la corne
  est placée de façon inhabituelle.
- **Le doublement de lettres** change le sens de façon prédéfinie, souvent vers une sorte d'opposé : 25F est
  « animals », 25FF « fabulous animals » ; 31AA est « female », ce qui implique « male » pour 31A.
- **Les chiffres structurels** ont un sens fixe dans une plage déclarée (par exemple, 2 pour une aventure amoureuse
  sous 92B, les dieux). Ils ne sont pas signalés par un symbole, et ne se reconnaissent donc pas dans une suite de
  chiffres.
- **Le tilde « ~ ».** La page d'aide consultée ne le définit pas. Dans les corrélats observés (« fabulous animals ~
  mammals », « fabulous animals ~ reptiles »), il sépare le terme parent de la subdivision. C'est une **inférence de
  ma part** à partir de la disposition, pas une définition documentée.
- **Les données** sont publiées sur le dépôt GitHub `iconclass/data`, sous licence CC0-1.0 d'après la page du dépôt.
  Le fichier principal est `notations.txt`, avec `keys.txt`. La documentation des fichiers se trouve sur la page d'aide
  « data ».

**Ce qui en découle pour la satisfaction.**

1. **Le sens d'une définition n'est pas son corrélat seul.** « monsters ~ reptiles », lu isolément, est presque vide.
   Avec le parent (« fabulous animals »), il devient « animal fabuleux de type reptile ». La requête doit être
   **compilée à partir du chemin** dans la hiérarchie, au moins jusqu'au premier ancêtre qui porte une condition. C'est
   la seule propriété formelle d'Iconclass qui soit garantie par sa documentation.
2. **Les clés sont des modificateurs compositionnels** du corrélat. Une notation avec clé est la conjonction de la
   notation de base et du sens de la clé, sous réserve que la clé soit « context-sensitive », ce que dit la
   documentation.
3. **Les doublements de lettres** sont des oppositions (*female / male*, *animals / fabulous animals*). Ce sont des
   **disjonctions exclusives** utiles pour conclure F (pas seulement N) quand la description tranche.
4. **« (with NAME) » et « (…) »** sont des **variables** de la définition. Le nom doit être unifié avec un nom de la
   description.
5. **« possible attributes: heart… »** n'est pas une condition de la définition. C'est un **indice** d'identification.
   Exiger l'attribut produirait des faux négatifs. L'accepter seul comme preuve d'identité produirait des faux
   positifs. Son statut est abductif (§ 11).
6. **« (other) … »** est une **exclusion relative aux sœurs** : « (other) contagious diseases » signifie « une maladie
   contagieuse qui n'est **aucune** de celles nommées par les notations sœurs ». C'est une négation à portée large,
   calculable seulement en **monde fermé sur les sœurs** (la liste des sœurs est finie et connue). Elle exige que la
   description **nomme** une maladie identifiable. Sinon, la valeur est N, pas T.

### 10.4 Pour Oedipamaas

**Ce que ça changerait.**

- **Compiler les requêtes depuis le chemin hiérarchique**, avec les clés, les doublements et les variables NAME. C'est
  probablement le gain le plus simple et le plus général de toute cette étude.
- Typer chaque condition de requête par **niveau de Panofsky** : pré-iconographique (dépeignable) ou iconographique
  (identification). C'est la même typologie qu'au § 9.5.
- Traiter « possible attributes » comme des **indices abductifs** et « (other) » comme une **négation sur les sœurs**.

**Ce que ça ne changerait pas.** Le CRM et ICON sont des vocabulaires d'enregistrement. Ils n'aident pas au calcul.

**Risques.** La sémantique des clés et des chiffres structurels n'est pas uniforme : elle dépend de la plage où ils
s'appliquent. Il faut lire la documentation de chaque clé, et non généraliser. La lecture du « ~ » est une hypothèse
à confirmer auprès de la documentation complète ou des éditeurs d'Iconclass.

---

## 11. Définitions, classification et abduction

### 11.1 Les logiques de description

**Ce que le formalisme représente.** Une logique de description (Baader et al., *The Description Logic Handbook*,
2003, deuxième édition 2007 ; Baader, Horrocks, Lutz et Sattler 2017 pour l'introduction de référence) décrit des
**concepts** (classes) à partir de concepts atomiques et de **rôles** (relations binaires). Dans **ALC**, les
constructeurs sont ¬, ⊓, ⊔, ∃r.C et ∀r.C. Une **TBox** contient des axiomes C ⊑ D (inclusion) et C ≡ D
(définition). Une **ABox** contient des assertions C(a) et r(a, b).

Les raisonnements standard sont :

- la **satisfiabilité** d'un concept ;
- la **subsomption** (C ⊑ D est-il conséquence de la TBox ?) ;
- la **classification** (calculer toutes les subsomptions entre concepts nommés) ;
- la **vérification d'instance** (a est-il un C ?) ;
- la **réponse aux requêtes conjonctives**.

La sémantique est **en monde ouvert**. Il n'y a pas d'hypothèse du nom unique par défaut en OWL.

**Propriétés formelles.**

- Pour ALC, la satisfiabilité d'un concept sans TBox est **PSPACE-complète** (Schmidt-Schauß et Smolka 1991).
  Avec une TBox générale, elle est EXPTIME-complète (résultat classique exposé dans le Handbook).
- **EL** (⊓, ∃, ⊤) garde une subsomption **polynomiale** même avec des TBox générales. Baader, Brandt et Lutz (2005,
  « Pushing the EL envelope ») montrent qu'on peut y ajouter ⊥, des nominaux, des domaines concrets et des inclusions
  de rôles complexes sans perdre la traitabilité. La plupart des autres ajouts rendent la subsomption intraitable,
  souvent EXPTIME-complète.
- Les **profils OWL 2** (W3C, recommandation du 11 décembre 2012, lue) sont tous deux PTIME-complets pour les tâches
  principales (**OWL 2 EL** et **OWL 2 RL**). OWL 2 QL est NLogSpace-complet, avec une réponse aux requêtes en AC0 en
  complexité de données.

**Ce qu'il ne représente pas.**

- Les relations **n-aires** (un événement à trois participants se réifie, comme en néo-davidsonien).
- Les **variables partagées en cycle** : « Adam et Ève tiennent **le même** fruit » est une requête conjonctive
  cyclique, qui n'est pas un concept.
- Le **défaut** et l'exception (OWL est monotone).
- Les **contextes** (dépeint / source) : il faut des extensions, ou un graphe nommé par contexte.

**Pour ce problème.** Une définition iconographique est un **concept**, et la satisfaction est une **vérification
d'instance** sur la scène. Par exemple :

> AdamEveHoldingFruit ≡ Scene ⊓ ∃hasPart.(Holding ⊓ ∃agent.Adam ⊓ ∃theme.Fruit) ⊓ ∃hasPart.(… Eve …)

La **classification par définition** (subsomption entre définitions) est aussi utile. Elle détecte les définitions
redondantes, calcule les plus spécifiques satisfaites, et vérifie la hiérarchie d'Iconclass contre les corrélats
compilés. EL suffit pour la plupart des définitions iconographiques, qui sont des conjonctions et des existentiels.
La négation (« without ») et « (other) » sortent d'EL. On peut les traiter **hors** de la logique, dans le noyau de
Belnap, par une vérification séparée.

### 11.2 Prototypes et définitions

**Deux théories des concepts.** La théorie classique des concepts (conditions nécessaires et suffisantes) et la théorie
des **prototypes** (Rosch 1975 ; entrée « Concepts » de la SEP, Margolis et Laurence) s'opposent. Pour la seconde, la
catégorisation est graduelle et fondée sur la ressemblance à un prototype. L'entrée « Definitions » de la SEP (Gupta et
Mackereth) distingue les définitions **stipulatives** et **descriptives**, et les définitions **réelles** et
**nominales**.

**Pour ce problème.** Les corrélats d'Iconclass sont des définitions **stipulatives** d'un système de classement. La
documentation dit que le corrélat « is the actual definition ». Mais leurs **termes** (« monster », « bishop »,
« contagious disease ») sont des concepts ordinaires, souvent prototypiques. La satisfaction a donc deux étages :

1. la **structure** de la définition, logique et compositionnelle ;
2. l'**application des termes**, lexicale, parfois graduelle, et parfois abductive.

Le projet a raison de traiter le premier étage en logique stricte. Pour le second, la supervaluation sur les sens est
une approximation **prudente** de la gradualité : elle refuse de conclure quand les sens divergent.

### 11.3 Les gloses de WordNet comme définitions

**eXtended WordNet.** Harabagiu, Miller et Moldovan (1999) proposent d'enrichir WordNet en **analysant et
désambiguïsant ses gloses**. Moldovan et Rus (2001) transforment les gloses en **formes logiques** (*Logic Form
Transformation*), utilisées en question-réponse avec le démonstrateur COGEX (Moldovan, Clark, Harabagiu et Hodges
2007). Clark, Fellbaum, Hobbs et al. (2008) ajoutent à WordNet des axiomes tirés des gloses et des liens
morphosémantiques pour l'implication textuelle.

**Constats sur les exemples du projet [L]** (WordNet 3.0) :

- *nose* (05598147) : « the organ of smell and entrance to the respiratory tract; the prominent part of the face… ».
  La description « l'organe de l'odorat » reprend **mot pour mot** le début de la glose. Une forme logique de la glose
  (organ(x) ∧ of(x, y) ∧ smell(y)) permettrait une identification par **définition**.
- *olive oil* (07674508) : « oil from olives ». L'hyperonyme *vegetable oil* (07673397) : « any of a group of liquid
  edible fats that are obtained from plants ».
- La chaîne d'hyperonymes de *oil* et d'*olive oil* passe par *lipid*, *macromolecule*, *molecule*… **« Liquid »
  n'est pas un hyperonyme** d'*olive oil*. Il n'apparaît que dans les **gloses** (*oil* : « a slippery or viscous
  liquid or liquefiable substance not miscible with water » ; *vegetable oil* : « liquid edible fats »). La taxinomie
  seule ne peut donc pas relier « golden liquid pressed from olives » à *olive oil*. Les gloses et la méronymie de
  substance (*olive* holonyme d'*olive oil*, § 8.3) le peuvent.
- *bride* a deux sens : « a woman who has recently been married » et « a woman participant in her own marriage
  ceremony », avec *wedding* (« a party of people at a wedding ») comme holonyme de membre. *groom / bridegroom* a la
  même structure.

**Ce que ça montre.** Le savoir nécessaire aux inférences contextuelles **est dans WordNet**, mais dans les **gloses**
et dans des relations peu utilisées (méronymie de substance), pas dans la taxinomie. Les gloses ne sont pas des
définitions nécessaires et suffisantes. Elles sont écrites pour un lecteur humain : genre prochain et différence
spécifique, souvent incomplètes. Une identification par glose mérite donc un **statut à part** : « par définition
lexicale », plus fort qu'une hypothèse, moins fort qu'une subsomption.

### 11.4 L'abduction

**Les théories.**

- **Peirce** décrit l'abduction comme l'inférence vers une hypothèse explicative (entrée « Abduction » de la SEP,
  Douven, révisée en 2025). Harman (1965) la reformule en **inférence à la meilleure explication**.
- **Hobbs, Stickel, Appelt et Martin (1993)** font de l'interprétation d'un texte une abduction : interpréter, c'est
  trouver la **preuve de coût minimal** de la forme logique du texte. Les littéraux qu'on ne peut pas prouver sont
  **supposés**, à un coût. L'**unification** de deux hypothèses (*factoring*) réduit le coût, ce qui produit la
  coréférence et la résolution des ambiguïtés. C'est l'**abduction pondérée**.
- **Kakas, Kowalski et Toni (1992)** définissent la **programmation logique abductive**. Un programme P, un ensemble
  d'**abductibles** A et des **contraintes d'intégrité** IC étant donnés, une explication d'un but G est un ensemble
  Δ ⊆ A tel que P ∪ Δ ⊨ G et que P ∪ Δ satisfasse IC.
- **Paul (1993)** passe en revue les approches : par couverture d'ensembles (diagnostic) et logiques.
- **Eiter et Gottlob (1995)** établissent la complexité de l'abduction logique. Décider l'existence d'une explication
  est Σ2P-complet dans le cas propositionnel général, et NP-complet pour les théories de Horn (résumé de ma part des
  résultats principaux de l'article).
- **Ovchinnikova et al. (2011)** et **Ovchinnikova (2012)** appliquent l'abduction pondérée (système Mini-TACITUS) avec
  une base d'axiomes tirée de **WordNet et FrameNet**, évaluée sur l'implication textuelle (RTE-2).

**Plausibilité et justification.** Une conclusion abductive n'est **pas** une preuve de la conclusion. C'est une preuve
de « la conclusion, **si** les hypothèses Δ ». La littérature est claire sur ce point. Le coût mesure la plausibilité,
pas la vérité. Pour un système qui doit produire des preuves vérifiables, l'abduction est acceptable à trois
conditions :

1. les **abductibles sont déclarés** : quels prédicats peut-on supposer (une identité par attribut, un événement à
   partir de son état résultant non analytique, un rôle social à partir d'un contexte) ?
2. chaque hypothèse **figure dans la preuve**, comme les hypothèses de sens aujourd'hui ;
3. les **contraintes d'intégrité** bloquent les hypothèses contradictoires avec la description (`distinct`, polarité
   négative, F de Belnap).

**Pour ce problème.** Les trois exemples d'inférence contextuelle se rangent ainsi.

| Exemple | Type d'inférence | Statut proposé |
|---|---|---|
| « l'organe de l'odorat » → *nose* | identification par glose | **par définition lexicale** |
| « liquide doré pressé des olives » → *oil* | appariement partiel avec la glose, la méronymie de substance et les qualia | **hypothèse** (appariement partiel) |
| « corps sans vie » → *died* | état → événement, analytique sous condition | **certain** sous condition (animé) |
| « mari et femme posant pour un portrait de mariage » → *bride and groom* | rôle social inféré du contexte | **hypothèse abductive** |
| « évêque tenant un cœur » → *Ignace* | identification par attribut | **hypothèse abductive** |

### 11.5 Pour Oedipamaas

**Ce que ça changerait.**

- Traiter les **définitions comme des concepts EL** compilés (§ 10.3), et la satisfaction comme une vérification
  d'instance. La négation, « (other) » et les clés d'opposition sont traitées à part dans le noyau à quatre valeurs.
- Introduire un statut **« par définition lexicale »** (identification par glose).
- Introduire une **abduction déclarée** : une liste fermée d'abductibles, des hypothèses visibles dans la preuve et des
  contraintes d'intégrité. C'est l'extension naturelle du mécanisme « sous hypothèse de sens ».

**Ce que ça ne changerait pas.** La qualité des gloses. Une glose incomplète ou mal analysée donne une forme logique
fausse. Les gloses françaises (alignement) sont plus rares, et le plus souvent absentes.

**Risques.**

- **La complexité.** L'abduction est Σ2P-complète en général. En pratique, il faut **borner** : profondeur, nombre
  d'hypothèses, abductibles seulement aux feuilles de la preuve.
- **La confusion des statuts.** Si un score de plausibilité finit par trier les résultats « certains », le système
  perd sa propriété principale. La plausibilité doit trier **à l'intérieur** du statut « sous hypothèse », jamais entre
  les statuts.

---

## 12. Ontologies d'événements et de situations

### 12.1 DOLCE et Descriptions and Situations

**DOLCE.** DOLCE (Borgo, Ferrario, Gangemi, Guarino et Masolo 2022, pour la présentation de référence récente)
distingue les **endurants** (objets, qui persistent en étant entièrement présents à chaque instant), les
**perdurants** (événements, processus, états, qui ont des parties temporelles), les **qualités** et les **abstraits**.
Il les relie par la **participation**.

**DnS.** Le motif *Descriptions and Situations* (Gangemi et Mika 2003) ajoute une distinction entre :

- une **Description** : une théorie, un plan, une norme, un récit, avec ses **concepts** ou **rôles** ;
- une **Situation** : une configuration d'entités qui **satisfait** (*satisfies*) la description. Les entités y sont
  **classées** par les concepts de la description.

La version OWL légère, DOLCE+DnS Ultralite (DUL), est publiée sur le site ontologydesignpatterns.org (fichier accessible
lors de la vérification).

**Pour ce problème.** DnS est la **formulation ontologique exacte du problème** : une définition iconographique est une
Description (avec ses rôles : Adam, Ève, le fruit, l'acte de tenir), et une scène dépeinte est une Situation qui la
satisfait ou non. DnS ne donne **pas d'algorithme** de satisfaction ; *satisfies* est une relation primitive. Mais il
fournit un vocabulaire standard pour **publier** les résultats, et pour distinguer la définition (Description) de son
instance (Situation).

### 12.2 SEM, LODE et les événements du CRM

- **SEM** (*Simple Event Model*, van Hage, Malaisé, Segers, Hollink et Schreiber 2011) est un modèle minimal :
  *Event*, *Actor*, *Place*, *Time*, avec des types et des rôles. Il est conçu pour intégrer des sources hétérogènes,
  avec des contraintes faibles et la possibilité de **points de vue** (une assertion vaut « selon » une source). Je
  n'ai pas relu le détail des propriétés de point de vue.
- **LODE** (*Linking Open Descriptions of Events*, Shaw, Troncy et Hardman 2009) est encore plus minimal : un
  événement, ses agents, son lieu et son temps, pour l'interopérabilité des données liées.
- **Les événements du CIDOC CRM** (§ 10.1) servent l'histoire de l'objet (production, acquisition), pas le contenu de
  la scène.

**Pour ce problème.** Ces modèles décrivent des événements **réels et documentés** avec un faible engagement
sémantique. Ils n'ont ni structure interne d'événement ni état résultant. Ils résolvent un **autre problème** :
l'intégration de données. Seule l'idée de **point de vue** de SEM recoupe le qualificateur d'énonciateur.

### 12.3 ESO, l'ontologie des événements et des situations impliquées

**Ce que la ressource représente.** ESO (Segers, Vossen, Rospocher, Serafini, Laparra et Rigau 2015 ; Segers et al.
2016 pour l'application et l'évaluation) formalise **ce qui précède et ce qui suit** un événement : ses
**pré-situations** et **post-situations**, et les rôles des entités affectées. Elle réutilise et relie WordNet, SUMO
et FrameNet. Le dépôt indique une correspondance complète avec SUMO au niveau des classes, et avec FrameNet au niveau
des classes et des rôles. La version 2.0 (stable) a été développée pour le projet NewsReader. Dans l'évaluation de
2016, **50 %** des événements typés et enrichis par des assertions ESO sont corrects.

**Pour ce problème.** ESO est la ressource la plus proche du besoin « état ↔ événement » : elle donne, pour des
classes d'événements alignées sur FrameNet, les **états avant et après**. Ses limites sont sa **taille** (une
ontologie de quelques centaines de classes, d'après mon souvenir [non vérifié]), son orientation vers l'actualité
économique et politique, et une précision mesurée modeste.

### 12.4 Calcul des situations et calcul des événements

**Le calcul des situations.** Il est dû à McCarthy et Hayes (1969). Une situation y est l'état du monde après une suite
d'actions, et les **fluents** sont les propriétés qui varient d'une situation à l'autre. Le **problème du cadre**
consiste à dire ce qui ne change pas sans l'énumérer (entrée « The Frame Problem » de la SEP, Shanahan).

**Le calcul des événements.** Kowalski et Sergot (1986) le définissent, et Shanahan (1999) en donne une version
simplifiée. Les prédicats sont *Happens(a, t)*, *Initiates(a, f, t)*, *Terminates(a, f, t)* et *HoldsAt(f, t)*.
L'**inertie** dit qu'un fluent initié tient tant qu'il n'est pas terminé. En Prolog, elle s'écrit avec la négation par
échec :

> HoldsAt(f, t) ← Happens(a, t1) ∧ Initiates(a, f, t1) ∧ t1 < t ∧ ¬Clipped(t1, f, t)

Van Lambalgen et Hamm (2005) font du calcul des événements, en programmation logique avec contraintes, la base d'une
sémantique du **temps et de l'aspect** du langage naturel. Mueller (2006 ; deuxième édition 2015) en donne un exposé
complet, avec un raisonneur.

**Pour ce problème.**

- *Initiates(die(x), dead(x))* est la règle d'état résultant du § 2. Le calcul des événements en est la formulation
  standard, et il se programme directement en Prolog.
- L'**inertie** n'est pas le besoin. Une image est un instantané : on n'a pas à calculer ce qui tient encore.
- Le **sens inverse** (de *HoldsAt(dead(x))* à *Happens(die(x))*) n'est pas une déduction du calcul des événements. C'est
  une **abduction** : chercher un événement qui explique le fluent. Shanahan (2000) en a fait un planificateur
  abductif.
- **Attention à la négation par échec** dans la règle d'inertie : elle introduit un monde clos (§ 9.4).

### 12.5 Pour Oedipamaas

**Ce que ça changerait.**

- **Adopter le vocabulaire DnS** pour nommer les objets : une définition est une Description, une scène une Situation,
  la relation est *satisfies*. C'est un gain de clarté, pas de calcul.
- **Écrire les états résultants** sous forme de clauses *Initiates* (et *Terminates*), alimentées par VerbNet,
  FrameNet *Inchoative_of* et ESO. Le sens inverse est traité comme une abduction déclarée (§ 11.4), sauf pour les cas
  analytiques.

**Ce que ça ne changerait pas.** SEM et LODE n'apportent rien au calcul.

**Risques.** ESO et FrameNet sont en anglais, avec une couverture partielle. Il faudra mesurer combien de définitions
d'Iconclass font intervenir un état résultant couvert.

---

## 13. Ressources lexicales formelles

### 13.1 Les relations de WordNet

**Ce que la ressource représente.** WordNet (Miller 1995 ; Fellbaum, dir., 1998) organise le lexique anglais en
**synsets** reliés par des relations sémantiques et lexicales :

- l'hyperonymie et l'hyponymie, avec la distinction entre classes et instances ;
- trois méronymies (partie, membre, substance) ;
- l'antonymie (pour les adjectifs) ;
- l'**implication** et la **cause** entre verbes ;
- l'**attribut** (adjectif ↔ nom d'attribut) ;
- les adjectifs relationnels (*pertainyms*) ;
- les **formes dérivationnellement reliées** (pointeur `+`), qui sont **non typées**.

**Constats sur les exemples du projet [L]** (WordNet 3.0) :

- *death* (07355491, « the event of dying or departure from life » ; 11444117, « the permanent end of all life
  functions… ») a des pointeurs dérivationnels `+` vers *die* (00358431, 02109818). Le lien nom / verbe **existe**, mais
  **sans type** : il ne dit pas que *death* est l'événement de *die*, ni lequel des arguments de *die* correspond au
  possesseur de *death*.
- *bald* (adjectif, 00210848) a un pointeur `+` vers *baldness* (14457041). Même constat.
- Le synset *die* (00358431) a 18 lemmes (*decease*, *perish*, *pass away*, *kick the bucket*…) et 28 pointeurs. Les sens de *die* dans WordNet sont nombreux. Le
  synset 01555034 (« cut or shape with a die ») est un homographe. La supervaluation sur les sens doit donc porter
  aussi sur ces liens.

### 13.2 Les liens morphosémantiques

Fellbaum, Osherson et Clark (2009) **typent** une partie des liens dérivationnels verbe → nom. Le fichier publié par
Princeton (`morphosemantic-links.xls`), que j'ai téléchargé et compté [L], contient **17 739 liens**, tous du type
(sens verbal, sens nominal). Ils se répartissent en **14 relations** :

| Relation | Nombre | Relation | Nombre |
|---|---|---|---|
| event | 8 158 | state | 528 |
| agent | 3 043 | property | 318 |
| result | 1 439 | location | 288 |
| by-means-of | 1 273 | material | 114 |
| undergoer | 878 | vehicle | 87 |
| instrument | 813 | body-part | 43 |
| uses | 740 | destination | 17 |

**Constats sur les exemples du projet [L].**

- *crucify* → *crucifixion* est typé **event**. *kill* → *killer* est typé **agent** et **by-means-of**. *kill* →
  *kill* (« the act of terminating a life ») est typé **event**.
- **Le couple de mots *die* → *death* n'y figure pas,** mais les **sens** sont reliés. Les seules lignes au lemme *die*
  sont *die* (outil) → *die* (instrument).
  - La ligne *decease* (2:30:00) → *decease* (1:11:00), typée **event**, relie le synset verbal 200358431 (die,
    decease, perish…) au synset nominal 107355491 (death, decease, expiry).
  - Au niveau des sens, celui du noyau, die#1 → death#1 est donc un lien **event**. Correction faite après vérification
    sur le tableur, le 27/11 : le premier constat lisait les couples de mots, non les synsets.
  - La leçon : ces liens se lisent par synset, jamais par lemme.
- Aucun couple **adjectif → nom** n'y figure (le fichier ne contient que des couples verbe → nom). *bald → baldness*
  n'est donc pas typé.

**Ce que ça montre.** Les liens morphosémantiques sont **la** ressource prévue pour les classes d'échec « nom
d'action / verbe » et « nom d'agent / participant ». *die / death* y est, par les synsets (§ ci-dessus). Leur couverture
est **trouée** ailleurs : les adjectifs ne sont pas couverts, et la couverture des couples réels reste à mesurer par
synset. Il faut les **compléter**
par les pointeurs dérivationnels non typés, avec un type par défaut. Le type par défaut se tire de la catégorie
lexicale du nom dans WordNet (`noun.event`, `noun.act` → event ; `noun.person` → agent ; `noun.state` → state). Le type
inféré doit rester **distinct** du type documenté dans la preuve.

### 13.3 Le Lexique génératif et les qualia

**Ce que la théorie représente.** Le Lexique génératif (Pustejovsky 1991b ; 1995) donne à chaque entrée nominale une
**structure de qualia** à quatre rôles :

- **formel** : ce qu'est la chose, son type (un liquide) ;
- **constitutif** : de quoi elle est faite, ses parties (de la graisse végétale) ;
- **télique** : sa fonction (cuisiner, oindre) ;
- **agentif** : son origine (presser des olives).

S'y ajoutent une structure d'événement (§ 2.3), une structure argumentale, et des mécanismes de composition : la
**coercition de type** (*begin a book* → begin reading), la **co-composition** et le **liage sélectif**.

**Pour ce problème.** Les qualia sont **exactement** la forme du savoir qu'emploient les descriptions qui décrivent
sans nommer :

| Description | Rôle de qualia | Concept |
|---|---|---|
| « golden **liquid** » | formel | *oil* |
| « **pressed from olives** » | agentif | *olive oil* |
| « the organ **of smell** » | télique | *nose* |
| « the instrument of his **martyrdom** » | télique, relatif à un événement | (selon le saint) |

Le Lexique génératif explique aussi pourquoi les artefacts se désignent si souvent par leur **fonction** ou leur
**origine**.

**Limite.** Il n'existe pas, à ma connaissance, de lexique de qualia **libre, de large couverture et aligné sur
WordNet** [non vérifié]. Les qualia doivent être **extraits des gloses**, qui contiennent souvent le genre (formel), le
« made from / obtained from » (agentif) et le « used for » (télique). Ou bien ils doivent être écrits à la main pour le
vocabulaire iconographique. La GL-VerbNet (§ 5.2) intègre la structure d'événement du Lexique génératif, pas les qualia
des noms.

### 13.4 La Lexical Conceptual Structure de Jackendoff

**Ce que le formalisme représente.** Jackendoff (1990, *Semantic Structures*) décompose le sens en **catégories
ontologiques** (THING, EVENT, STATE, PLACE, PATH, PROPERTY…) et en **fonctions** :

- GO, BE, STAY, CAUSE, INCH, LET ;
- des fonctions de lieu (AT, IN, ON, UNDER) et de chemin (TO, FROM, TOWARD, VIA).

L'hypothèse des **relations thématiques** étend la même structure à des champs sémantiques (spatial, possessif,
identificationnel, temporel). Exemples :

> « The serpent is set on the pole » ≈ [CAUSE (x, [GO (serpent, [TO [ON (pole)]])])]
> État résultant : [BE (serpent, [AT [ON (pole)]])]

**Pour ce problème.** La LCS donne **une seule forme** au lieu, qu'il soit exprimé par un rôle d'événement
(`role(E, location, Y)`) ou par une relation entre objets (`relation(X, on, Y)`). C'est la classe d'échec « rôle
locatif / relation spatiale ». Elle donne aussi l'état résultant d'un mouvement causé (GO → BE). Il n'y a **pas de
ressource à large couverture** en LCS. Des lexiques LCS de verbes anglais ont été construits dans les années 1990
[non vérifié]. Le gain est conceptuel : choisir une **forme canonique du lieu** inspirée de la LCS.

### 13.5 Les fonctions lexicales de la théorie Sens-Texte et le Réseau lexical du français

**Ce que le formalisme représente.** Les **fonctions lexicales** de Mel'čuk (1996) sont des relations
lexico-sémantiques **standard**, en nombre limité (quelques dizaines de fonctions simples), qui associent à une unité
lexicale d'autres unités. Quelques fonctions utiles ici (définitions standard de la théorie, résumé de ma part) :

- **S0** (nom de même sens) : S0(*mourir*) = *mort* ; S0(*chauve*) = *calvitie* ;
- **V0** (verbe) et **A0** (adjectif) de même sens ;
- **S1** (nom typique du premier actant) : S1(*tuer*) = *meurtrier* ;
- **S2**, **Sinstr**, **Sloc**, **Sres** : nom du deuxième actant, de l'instrument, du lieu, du résultat ;
- **Syn**, **Anti**, **Gener** (générique) ;
- **Magn** (intensification) ;
- **Oper1**, **Func0**, **Real1** (verbes supports et de réalisation) ;
- **Caus**, **Incep**, **Fin**, **Liqu** (causer, commencer, cesser, éliminer).

**Le Réseau lexical du français.** Le RL-fr (*French Lexical Network*, Lux-Pogodalla et Polguère 2011 ; Polguère 2014)
est un **réseau** de lexies françaises reliées par ces fonctions et par des liens de dérivation et de
copolysémie. Il a commencé par une nomenclature de français fondamental d'environ 3 800 vocables. D'après l'annonce de
sa diffusion (LINGUIST List, 2017), il est distribué sur **ORTOLANG** sous licence **CC BY 4.0**. La page ORTOLANG
n'a pas pu être lue directement ; la licence et la version courantes sont donc à confirmer.

**Pour ce problème.** Les fonctions lexicales sont **la typologie la plus complète** des classes d'échec « catégorie
grammaticale » :

| Classe d'échec | Fonction lexicale |
|---|---|
| nom / événement | S0, V0 |
| propriété / nom d'état | S0 de l'adjectif, A0 du nom |
| nom d'agent / participant | S1, S2, Sinstr, Sloc |
| état résultant | Sres ; Caus, Incep, Fin pour les passages causatifs et inchoatifs |

Et le RL-fr est **en français**, alors que les liens morphosémantiques de WordNet sont en anglais. Les limites sont la
**couverture** (bien plus petite que WordNet) et l'**absence d'alignement** sur les synsets de WordNet. Les lexies du
RL-fr sont des sens propres au réseau, et l'alignement sur WordNet serait une source nouvelle de polysémie.

### 13.6 Pour Oedipamaas

**Ce que ça changerait.**

- **Un module de normalisation dérivationnelle typée**, avec trois sources par ordre de confiance :
  1. les liens morphosémantiques (typés) ;
  2. les fonctions lexicales du RL-fr (typées, pour le français) ;
  3. les pointeurs dérivationnels de WordNet, avec un type par défaut tiré de la catégorie lexicale.

  Le type documenté et le type par défaut restent distincts dans la preuve.
- **Un extracteur de qualia à partir des gloses** (genre → formel ; « from / made of / obtained from » → agentif et
  constitutif ; « used for / organ of » → télique). Il est limité au vocabulaire des définitions iconographiques.
- **Une forme canonique du lieu** inspirée de la LCS.

**Ce que ça ne changerait pas.** La polysémie : chaque lien lexical est un lien **entre sens**. La supervaluation doit
continuer de s'appliquer.

**Risques.** Les gloses sont hétérogènes, et l'extraction de qualia par patrons est bruitée. Il faut traiter chaque
qualia extrait comme une **hypothèse lexicale**, pas comme un fait. L'alignement RL-fr ↔ WordNet est un projet en soi.

---

## 14. Tableau comparatif

**Légende.** ++ : traité centralement ; + : traité partiellement, ou par extension connue ; – : absent ; s.o. : sans
objet. « Outils » désigne des outils ou données utilisables **hors ligne**. « Fr » désigne les ressources ou outils
pour le français. Les jugements de la colonne « Décidabilité » portent sur le **calcul associé** au formalisme, quand
il y en a un.

| Formalisme / ressource | Év./rôles | États | Situations | Quantif. | Portée nég./mod. | Dépiction / intens. | Partie-tout | Temps | Défin. / classif. | Abduction | Compos. | Décidabilité | Outils | Fr |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| Davidson / néo-davidsonien | ++ | + (Parsons) | – | ∃ seul | – | – | – | – | – | – | + (Champollion) | fragment ∃∧ : décidable | s.o. | s.o. |
| Structure d'év. (Moens-Steedman, Pustejovsky, Dowty) | ++ | ++ (résultat) | – | – | – | – | – | + (phases) | – | – | + | dépend des règles | via VerbNet, FN, ESO | – |
| États kimiens (Maienborn) | + | ++ | – | – | – | – | – | + | – | – | + | s.o. | – | – |
| Situations (Barwise-Perry, Kratzer) | + | + | ++ (partielles) | + | + | + (perception, attitudes) | ++ (partie de situation) | + | – | – | + | variable | – | – |
| Montague / théorie des types | + (par ajout) | – | – | ++ | ++ | ++ (intensions) | – | + | – | – | ++ | indécidable (ordre sup.) | construction seule | – |
| MRS / ERG (DELPH-IN) | ++ | + | – | ++ (sous-spéc.) | ++ | + | – | + (traits) | – | – | ++ | résolution efficace (nets) | ++ (ACE, PyDelphin) | – |
| Sém. des trous / UDRT / glue | + | – | – | ++ | ++ | + | – | – | – | – | ++ | énumération ; UDRT : déduction directe | + | – |
| DRT | ++ | + | + | ++ | ++ (boîtes) | ++ (boîtes étiquetées) | – | ++ | – | – | ++ (λ-DRT) | ≡ FOL : semi-décidable | via Boxer | – |
| SDRT | + | – | – | + | ++ (discours) | + | – | ++ (relations) | – | + (glue logic) | + | non monotone | – | – |
| Boxer / GMB / PMB | ++ | + | – | ++ | ++ | + | – | + | – | – | ++ | FOL + démonstrateurs | + (données PMB) | – (pas de fr. dans le PMB) |
| FrameNet | ++ (FE) | + (cadres d'état) | + (scènes) | – | – | – | + (Body_parts…) | + (Precedes) | + (Inheritance) | – | – | réseau, pas de logique | ++ (FN 1.7) | + (ASFALDA, ~100 cadres) |
| VerbNet / GL-VerbNet | ++ | ++ (sous-évts) | – | – | – | – | – | + (phases) | + (classes) | – | – | s.o. | ++ (3.3 local ; GL en ligne) | + (Verb∋Net) |
| PropBank / NomBank / SemLink | ++ (noms inclus) | + | – | – | – | – | – | – | – | – | – | s.o. | ++ | – |
| Dicovalence / LVF | + (valence) | – | – | – | – | – | – | – | + (classes LVF) | – | – | s.o. | + | ++ |
| AMR | ++ (nominal. → verbe) | + | – | – (1 ∀ max) | + (:polarity) | – | + (:part) | – | – | – | + | 2 variables : décidable (Bos 2016) | analyseurs neuronaux | faible |
| UMR | ++ | ++ (aspect) | – | ++ (nœud scope) | ++ (dépendance modale) | + (conceveurs) | + | ++ (doc.) | – | – | + | traduction FOL | outils d'annotation, peu d'analyseurs | – |
| UCCA | + (scènes) | + (S vs P) | + (scènes) | – | – | – | – | – | – | – | – | s.o. | + | + (annotations multilingues) |
| DMRS / EDS | ++ | + | – | + | + | – | – | – | – | – | ++ | graphes | ++ (via ERG) | – |
| Allen / ISO-TimeML | + (EVENT) | – | – | – | + (SLINK) | + (SLINK) | – | ++ | – | – | – | IA complet NP-c. ; ORD-Horn polyn. | + | + |
| RCC-8 / ISO-Space | + (mouvement) | – | – | – | – | – | ++ (topologie) | – | – | – | – | NP-c. ; Ĥ8 polyn. | + | – |
| Méréologie / méréotopologie | – | – | + | – | – | – | ++ | – | – | – | – | selon axiomes | WordNet (méronymies) | via WOLF / OMW |
| Modalité de Kratzer | – | – | + | + | ++ | + | – | – | – | – | ++ | selon la logique modale | – | – |
| Sém. de la dépiction (Zimmermann, Abusch, Greenberg) | – | – | + | – | + (pas de nég. picturale) | ++ | + (espace pictural) | – | – | – | + | s.o. | – | – |
| Belnap / bitreillis | – | – | + (partialité) | – | ++ (nég. locale ; B/N) | + (par contexte) | – | – | – | – | ++ | décidable (1er degré) | noyau du projet | s.o. |
| CIDOC CRM | + (histoire de l'objet) | + (E3) | – | – | – | + (P62, extensionnel) | + (P46…) | ++ (E52) | + (E55) | – | – | OWL / FOL | ++ | + (trad.) |
| Panofsky / ICON | – | – | + | – | – | ++ (niveaux) | – | – | + | + (interprétation) | – | OWL | + (ICON) | – |
| Structure d'Iconclass | – | – | – | – | + ((other), doublements) | + (attributs) | – | – | ++ (hiérarchie) | – | + (clés) | s.o. | ++ (données CC0) | + (multilingue) |
| Logiques de description / OWL 2 EL | + (réifié) | + | – | ∃ (EL), ∀ (ALC) | – (EL) ; ¬ (ALC) | – | + (rôles) | – | ++ | – | – | EL : PTIME ; ALC : PSPACE / EXPTIME | ++ (raisonneurs) | s.o. |
| Abduction (Hobbs, ALP) | + | + | – | – | + (IC) | – | – | – | + | ++ | – | Σ2P-c. ; Horn : NP-c. | + (Mini-TACITUS, ALP) | – |
| DOLCE / DnS | + | ++ (perdurants) | ++ (satisfies) | – | – | + (descriptions) | ++ | + | ++ (descriptions) | – | – | OWL | + (DUL) | – |
| SEM / LODE | + | – | – | – | – | + (points de vue, SEM) | – | + | – | – | – | OWL | + | – |
| ESO | + | ++ (pré/post) | ++ | – | – | – | – | + | + | – | – | OWL | + | – |
| Calcul des événements | ++ | ++ (fluents) | + | – | + (NAF) | – | – | ++ | – | + (planif. abductive) | – | Prolog ; indécidable en général | + | s.o. |
| WordNet + liens morphosém. | + (14 relations, v→n) | + (state) | – | – | – | – | ++ (3 méronymies) | – | ++ (hyperonymie, gloses) | – | – | s.o. | ++ (local) | ++ (alignement) |
| Lexique génératif (qualia) | + | + | – | – | – | – | + (constitutif) | + | ++ (qualia) | + (coercition) | ++ | s.o. | – (pas de lexique large) | – |
| LCS (Jackendoff) | ++ | ++ (BE) | – | – | – | – | – | + | + | – | ++ | s.o. | – | – |
| Fonctions lexicales / RL-fr | + (S1, S2…) | + (S0 adj.) | – | – | – | – | – | – | + (Gener, Syn) | – | – | s.o. | + (RL-fr) | ++ |
| **Format actuel du projet** (pour comparaison) | ++ | – | – (portée plate) | ∃ + number | + (par assertion) | + (portée « dépeint ») | – (prépositions) | – | + (WordNet) | + (sens seulement) | – | Prolog ; à vérifier (§ 1.1) | ++ | + |

**Lecture du tableau.** Aucune ligne n'est complète. Trois groupes se complètent :

1. **pour la portée et les contextes** : DRT et UMR, auxquels la sémantique de la dépiction ajoute ce qui est propre
   aux images ;
2. **pour la normalisation et les états** : la structure d'événement, les états kimiens, les cadres et les liens
   morphosémantiques ou les fonctions lexicales ;
3. **pour le calcul et la classification** : EL, les règles existentielles faiblement acycliques et l'abduction
   déclarée.

Le format actuel est déjà le bon **substrat plat**. Les extensions proposées dans les sections « Pour Oedipamaas »
s'y ajoutent sans le remplacer.

---

## 15. Questions ouvertes

1. **Le statut des règles état → événement.** Faut-il une liste fermée des cas analytiques (*dead → died*), et une
   abduction pour tous les autres ? Qui valide la liste ?
2. **La co-localisation.** Une définition doit-elle être satisfaite dans **une seule scène** ? Comment identifier les
   scènes à partir d'une description libre (indices « à gauche », « au registre supérieur », « dans le fond ») ?
3. **La distributivité.** « Adam and Eve holding the fruit » : lecture collective, distributive, ou supervaluation sur
   les deux ? La réponse change le taux de satisfaction.
4. **Le nombre.** « Two angels » signifie-t-il « au moins deux » ou « exactement deux » ? Iconclass ne le dit pas
   dans la documentation consultée.
5. **Le « ~ » d'Iconclass.** Sa lecture comme séparateur parent / subdivision est une inférence. Elle est à confirmer
   par la documentation complète ou par les éditeurs.
6. **La typologie des conditions** (dépeignable / conventionnelle / non dépeignable). Quelle est la part de chaque
   type dans les définitions ? Cela se mesure sur un échantillon annoté par un humain.
7. **Un troisième statut.** Faut-il un statut « par définition lexicale » (identification par glose), entre « certain »
   et « sous hypothèse » ? Comment l'afficher dans les preuves sans brouiller les statuts existants ?
8. **La terminaison.** Les règles existentielles (état → événement, nom d'agent → événement, qualia → concept)
   forment-elles un ensemble **faiblement acyclique** ? C'est à vérifier formellement sur le jeu de règles réel.
9. **Belnap par contexte.** À quel niveau agréger les valeurs : par énonciateur, par portée, puis globalement ? Une
   contradiction entre l'auteur et une source citée doit-elle remonter comme B, ou rester confinée ?
10. **Le français.** Les ressources typées (liens morphosémantiques, FrameNet, VerbNet, ESO) sont anglaises. Le chemin
    par l'alignement WordNet est-il assez précis, ou faut-il investir dans le RL-fr (fonctions lexicales) malgré sa
    couverture ? Seule une mesure sur les descriptions françaises du corpus peut trancher.
11. **La dépiction et les noms.** Sous la portée « dépeint », un nom désigne-t-il l'individu historique ou le
    personnage ? Faut-il interdire l'import des faits historiques (lieu et date de la mort d'Ignace) dans la scène ?
12. **Le monde clos local.** « (other) X » demande un monde clos sur les notations sœurs. Où s'arrête ce monde clos, et
    comment l'empêcher de s'étendre aux autres négations ?

---

## 16. Références

Les références sont classées par ordre alphabétique. La mention entre crochets indique le statut de vérification, et
la source quand ce n'est pas un DOI ou l'ACL Anthology. « Lu » signifie que j'ai lu le texte, le résumé ou les
définitions citées.

### A–B

- Abend, O. et Rappoport, A. (2013). Universal Conceptual Cognitive Annotation (UCCA). *Proceedings of the 51st Annual
  Meeting of the ACL (Volume 1: Long Papers)*, p. 228–238. ACL Anthology P13-1023. https://aclanthology.org/P13-1023/
  [vérifié]
- Abusch, D. (2020). Possible-worlds semantics for pictures. *The Wiley Blackwell Companion to Semantics*. Wiley.
  DOI 10.1002/9781118788516.sem003 [vérifié, notice ; texte non consulté]
- Abzianidze, L., Bjerva, J., Evang, K., Haagsma, H., van Noord, R., Ludmann, P., Nguyen, D.-D. et Bos, J. (2017). The
  Parallel Meaning Bank: Towards a multilingual corpus of translations annotated with compositional meaning
  representations. *Proceedings of EACL 2017 (Volume 2: Short Papers)*, p. 242–247. DOI 10.18653/v1/E17-2039
  [vérifié]
- Allen, J. F. (1983). Maintaining knowledge about temporal intervals. *Communications of the ACM*, 26(11), p. 832–843.
  DOI 10.1145/182.358434 [vérifié]
- Arieli, O. et Avron, A. (1996). Reasoning with logical bilattices. *Journal of Logic, Language and Information*, 5(1).
  DOI 10.1007/BF00215626 [vérifié]
- Asher, N. et Lascarides, A. (2003). *Logics of Conversation*. Cambridge University Press (Studies in Natural
  Language Processing). [vérifié : notice de l'université d'Édimbourg et catalogues]
- Baader, F., Brandt, S. et Lutz, C. (2005). Pushing the EL envelope. *Proceedings of IJCAI-05*, p. 364–369 (364–368
  selon la page IJCAI). https://ijcai.org/proceedings/2005/15 [vérifié : ijcai.org, dblp]
- Baader, F., Calvanese, D., McGuinness, D., Nardi, D. et Patel-Schneider, P. (dir.) (2003 ; 2e éd. 2007). *The
  Description Logic Handbook*. Cambridge University Press. DOI 10.1017/CBO9780511711787 (2e éd.) [vérifié]
- Baader, F., Horrocks, I., Lutz, C. et Sattler, U. (2017). *An Introduction to Description Logic*. Cambridge
  University Press. DOI 10.1017/9781139025355 [vérifié]
- Bach, E. (1986). The algebra of events. *Linguistics and Philosophy*, 9(1), p. 5–16. DOI 10.1007/BF00627432
  [vérifié]
- Baker, C. F., Fillmore, C. J. et Lowe, J. B. (1998). The Berkeley FrameNet project. *Proceedings of COLING-ACL 1998,
  Volume 1*, p. 86–90. DOI 10.3115/980845.980860 [vérifié]
- Banarescu, L., Bonial, C., Cai, S., Georgescu, M., Griffitt, K., Hermjakob, U., Knight, K., Koehn, P., Palmer, M.
  et Schneider, N. (2013). Abstract Meaning Representation for sembanking. *Proceedings of the 7th Linguistic
  Annotation Workshop and Interoperability with Discourse*, p. 178–186. ACL Anthology W13-2322. [vérifié ; lu]
- Barwise, J. et Cooper, R. (1981). Generalized quantifiers and natural language. *Linguistics and Philosophy*, 4(2),
  p. 159–219. DOI 10.1007/BF00350139 [vérifié]
- Barwise, J. et Perry, J. (1983). *Situations and Attitudes*. MIT Press (Bradford Books). [vérifié : comptes rendus
  indexés, *Journal of Symbolic Logic* 51(2), 1986, DOI 10.1017/S0022481200031376, et *Language* 62(2), 1986]
- Belnap, N. D. (1977). A useful four-valued logic. Dans J. M. Dunn et G. Epstein (dir.), *Modern Uses of
  Multiple-Valued Logic*, Reidel, p. 5–37. DOI 10.1007/978-94-010-1161-7_2 [vérifié]
- Bender, E. M., Flickinger, D., Oepen, S., Packard, W. et Copestake, A. (2015). Layers of interpretation: On grammar
  and compositionality. *Proceedings of the 11th International Conference on Computational Semantics (IWCS)*,
  p. 239–249. ACL Anthology W15-0128. [vérifié]
- Borgo, S., Ferrario, R., Gangemi, A., Guarino, N., Masolo, C. et al. (2022). DOLCE: A descriptive ontology for
  linguistic and cognitive engineering. *Applied Ontology*, 17(1), p. 45–69. DOI 10.3233/AO-210259 [vérifié]
- Bos, J. (1996). Predicate logic unplugged. Dans P. Dekker et M. Stokhof (dir.), *Proceedings of the Tenth Amsterdam
  Colloquium*, p. 133–143. [vérifié : notice BibTeX de l'auteur, let.rug.nl ; le colloque a eu lieu en décembre 1995]
- Bos, J. (2008). Wide-coverage semantic analysis with Boxer. *Semantics in Text Processing. STEP 2008 Conference
  Proceedings*, p. 277–286. ACL Anthology W08-2222. [vérifié]
- Bos, J. (2015). Open-domain semantic parsing with Boxer. *Proceedings of NODALIDA 2015*, p. 301–304. ACL Anthology
  W15-1841. [vérifié]
- Bos, J. (2016). Squib: Expressive power of Abstract Meaning Representations. *Computational Linguistics*, 42(3),
  p. 527–535. DOI 10.1162/COLI_a_00257 [vérifié ; lu (résumé et introduction)]
- Bos, J., Basile, V., Evang, K., Venhuizen, N. et Bjerva, J. (2017). The Groningen Meaning Bank. Dans *Handbook of
  Linguistic Annotation*, Springer, p. 463–496. DOI 10.1007/978-94-024-0881-2_18 [vérifié]
- Brown, S. W., Bonn, J., Gung, J., Zaenen, A., Pustejovsky, J. et Palmer, M. (2019). VerbNet representations:
  Subevent semantics for transfer verbs. *Proceedings of the First International Workshop on Designing Meaning
  Representations*, p. 154–163. DOI 10.18653/v1/W19-3318 [vérifié]
- Brown, S. W., Bonn, J., Kazeminejad, G., Zaenen, A., Pustejovsky, J. et Palmer, M. (2022). Semantic representations
  for NLP using VerbNet and the Generative Lexicon. *Frontiers in Artificial Intelligence*, 5. DOI
  10.3389/frai.2022.821697 [vérifié]

### C–F

- Calì, A., Gottlob, G. et Lukasiewicz, T. (2012). A general Datalog-based framework for tractable query answering
  over ontologies. *Journal of Web Semantics*, 14, p. 57–83. DOI 10.1016/j.websem.2012.03.001 [vérifié]
- Candito, M., Amsili, P., Barque, L., Benamara, F., de Chalendar, G., Djemaa, M., Haas, P., Huyghe, R., Mathieu, Y. Y.,
  Muller, P., Sagot, B. et Vieu, L. (2014). Developing a French FrameNet: Methodology and first results. *Proceedings of
  LREC'14*, p. 1372–1379. ACL Anthology L14-1411. [vérifié]
- Carlson, G. N. (1977). A unified analysis of the English bare plural. *Linguistics and Philosophy*, 1(3),
  p. 413–457. DOI 10.1007/BF00353456 [vérifié]
- Casati, R. et Varzi, A. C. (1999). *Parts and Places: The Structures of Spatial Representation*. MIT Press. DOI
  10.7551/mitpress/5253.001.0001 [vérifié]
- Casati, R. et Varzi, A. Events. *Stanford Encyclopedia of Philosophy* (première publication 2002 ; révision 2025).
  https://plato.stanford.edu/entries/events/ [vérifié]
- Castañeda, H.-N. (1967). Comments. Dans N. Rescher (dir.), *The Logic of Decision and Action*, University of
  Pittsburgh Press, p. 104–112. [non vérifié : bibliographies secondaires concordantes ; gardé, car c'est l'origine de
  la séparation des arguments]
- Champollion, L. (2015). The interaction of compositional semantics and event semantics. *Linguistics and
  Philosophy*, 38(1), p. 31–66. DOI 10.1007/s10988-014-9162-8 [vérifié]
- Chandra, A. K. et Merlin, P. M. (1977). Optimal implementation of conjunctive queries in relational data bases.
  *Proceedings of the 9th Annual ACM Symposium on Theory of Computing*, p. 77–90. DOI 10.1145/800105.803397 [vérifié]
- CIDOC CRM Special Interest Group. *CIDOC Conceptual Reference Model*, version 7.1.3 (février 2024).
  https://cidoc-crm.org/versions-of-the-cidoc-crm ; définitions : https://cidoc-crm.org/html/cidoc_crm_v7.1.3.html
  [vérifié ; lu : P62, P138, E36, E5, E7, E13]
- Clark, K. L. (1978). Negation as failure. Dans *Logic and Data Bases*, Plenum, p. 293–322. DOI
  10.1007/978-1-4684-3384-5_11 [vérifié]
- Clark, P., Fellbaum, C., Hobbs, J. R., Harrison, P., Murray, W. R. et Thompson, J. (2008). Augmenting WordNet for
  deep understanding of text. *Semantics in Text Processing. STEP 2008 Conference Proceedings*, p. 45–57. DOI
  10.3115/1626481.1626486 [vérifié ; le sixième auteur vient de ma mémoire]
- Copestake, A. (2009). Slacker semantics: Why superficiality, dependency and avoidance of commitment can be the right
  way to go. *Proceedings of EACL 2009*, p. 1–9. ACL Anthology E09-1001. [vérifié]
- Copestake, A., Flickinger, D., Pollard, C. et Sag, I. A. (2005). Minimal Recursion Semantics: An introduction.
  *Research on Language and Computation*, 3(2–3), p. 281–332. DOI 10.1007/s11168-006-6327-9 [vérifié]
- Copestake, A., Lascarides, A. et Flickinger, D. (2001). An algebra for semantic construction in constraint-based
  grammars. *Proceedings of the 39th Annual Meeting of the ACL*, p. 140–147. DOI 10.3115/1073012.1073031 [vérifié]
- Couprie, L. D. (1983). Iconclass: An iconographic classification system. *Art Libraries Journal*, 8(2), p. 32–49.
  DOI 10.1017/S0307472200003436 [vérifié]
- Dalrymple, M. (dir.) (1999). *Semantics and Syntax in Lexical Functional Grammar: The Resource Logic Approach*. MIT
  Press. DOI 10.7551/mitpress/6169.001.0001 [vérifié]
- Danlos, L., Pradet, Q., Barque, L., Nakamura, T. et Constant, M. (2016). Un Verbenet du français. *Traitement
  Automatique des Langues*, 57(1), p. 33–58. ACL Anthology 2016.tal-1.2. [vérifié]
- Davidson, D. (1967). The logical form of action sentences. Dans N. Rescher (dir.), *The Logic of Decision and
  Action*, University of Pittsburgh Press, p. 81–120. DOI 10.2307/jj.13027259.6 [vérifié ; la pagination couvre
  aussi les commentaires et les réponses]
- Djemaa, M., Candito, M., Muller, P. et Vieu, L. (2016). Corpus annotation within the French FrameNet: A
  domain-by-domain methodology. *Proceedings of LREC'16*, p. 3794–3801. ACL Anthology L16-1601. [vérifié]
- Doerr, M. (2003). The CIDOC Conceptual Reference Module: An ontological approach to semantic interoperability of
  metadata. *AI Magazine*, 24(3), p. 75–92. DOI 10.1609/aimag.v24i3.1720 [vérifié]
- Donatelli, L., Regan, M., Croft, W. et Schneider, N. (2018). Annotation of tense and aspect semantics for
  sentential AMR. *Proceedings of LAW-MWE-CxG-2018*, p. 96–108. ACL Anthology W18-4912. [vérifié]
- Douven, I. Abduction. *Stanford Encyclopedia of Philosophy* (première publication 2011 ; révision 2025).
  https://plato.stanford.edu/entries/abduction/ [vérifié]
- Dowty, D. R. (1979). *Word Meaning and Montague Grammar*. Reidel (Studies in Linguistics and Philosophy). DOI
  10.1007/978-94-009-9473-7 [vérifié]
- Dowty, D. (1991). Thematic proto-roles and argument selection. *Language*, 67(3), p. 547–619. DOI 10.2307/415037
  [vérifié]
- Dubois, J. et Dubois-Charlier, F. (1997). *Les Verbes français*. Larousse. [non vérifié directement ; présenté par
  François, Le Pesant et Leeman 2007 ; version LVF+1 : https://rali.iro.umontreal.ca/rali/?q=fr/lvf, page consultée]
- Eiter, T. et Gottlob, G. (1995). The complexity of logic-based abduction. *Journal of the ACM*, 42(1), p. 3–42. DOI
  10.1145/200836.200838 [vérifié]
- Fagin, R., Kolaitis, P. G., Miller, R. J. et Popa, L. (2005). Data exchange: Semantics and query answering.
  *Theoretical Computer Science*, 336(1), p. 89–124. DOI 10.1016/j.tcs.2004.10.033 [vérifié]
- Fellbaum, C. (dir.) (1998). *WordNet: An Electronic Lexical Database*. MIT Press. DOI
  10.7551/mitpress/7287.001.0001 [vérifié]
- Fellbaum, C., Osherson, A. et Clark, P. E. (2009). Putting semantics into WordNet's « morphosemantic » links. Dans
  *Human Language Technology. Challenges of the Information Society* (LNCS), Springer, p. 350–358. DOI
  10.1007/978-3-642-04235-5_30 [vérifié ; le titre du volume vient de ma mémoire] ; fichier de données :
  https://wordnetcode.princeton.edu/standoff-files/morphosemantic-links.xls [vérifié : téléchargé et compté]
- Fillmore, C. J. (1982). Frame semantics. Dans The Linguistic Society of Korea (dir.), *Linguistics in the Morning
  Calm*, Hanshin, p. 111–137. [non vérifié : notices secondaires concordantes ; gardé, texte fondateur]
- Fine, K. (1975). Vagueness, truth and logic. *Synthese*, 30(3–4), p. 265–300. DOI 10.1007/BF00485047 [vérifié]
- Fitting, M. (1991). Bilattices and the semantics of logic programming. *Journal of Logic Programming*, 11(2),
  p. 91–116. DOI 10.1016/0743-1066(91)90014-G [vérifié]
- Flickinger, D. (2000). On building a more efficient grammar by exploiting types. *Natural Language Engineering*,
  6(1), p. 15–28. DOI 10.1017/S1351324900002370 [vérifié]
- François, J., Le Pesant, D. et Leeman, D. (2007). Présentation de la classification des *Verbes Français* de Jean
  Dubois et Françoise Dubois-Charlier. *Langue française*, 153, p. 3–19. DOI 10.3917/lf.153.0003 [vérifié]
- Fuchss, R., Koller, A., Niehren, J. et Thater, S. (2004). Minimal recursion semantics as dominance constraints.
  *Proceedings of the 42nd Annual Meeting of the ACL*. DOI 10.3115/1218955.1218987 [vérifié]

### G–K

- Gangemi, A. et Mika, P. (2003). Understanding the Semantic Web through descriptions and situations. *On The Move to
  Meaningful Internet Systems 2003: ODBASE* (LNCS), Springer, p. 689–706. DOI 10.1007/978-3-540-39964-3_44 [vérifié]
- Geurts, B., Beaver, D. I. et Maier, E. Discourse Representation Theory. *Stanford Encyclopedia of Philosophy*
  (première publication 2007 ; révision 2024). https://plato.stanford.edu/entries/discourse-representation-theory/
  [vérifié ; lu]
- Ginsberg, M. L. (1988). Multivalued logics: A uniform approach to reasoning in artificial intelligence.
  *Computational Intelligence*, 4(3), p. 265–316. DOI 10.1111/j.1467-8640.1988.tb00280.x [vérifié]
- Greenberg, G. (2013). Beyond resemblance. *The Philosophical Review*, 122(2), p. 215–287. DOI
  10.1215/00318108-1963716 [vérifié, notice ; texte non consulté]
- Greenberg, G. (2021). Semantics of pictorial space. *Review of Philosophy and Psychology*, 12(4), p. 847–887. DOI
  10.1007/s13164-020-00513-6 [vérifié, notice ; texte non consulté]
- Gupta, A. et Mackereth, S. Definitions. *Stanford Encyclopedia of Philosophy* (première publication 2008 ;
  révision 2023). https://plato.stanford.edu/entries/definitions/ [vérifié]
- Hamm, F. et van Lambalgen, M. : voir van Lambalgen et Hamm (2005).
- Harabagiu, S. M., Miller, G. A. et Moldovan, D. I. (1999). WordNet 2 — A morphologically and semantically enhanced
  resource. *SIGLEX99: Standardizing Lexical Resources*. ACL Anthology W99-0501. [vérifié]
- Harman, G. H. (1965). The inference to the best explanation. *The Philosophical Review*, 74(1), p. 88 sq. DOI
  10.2307/2183532 [vérifié]
- Higginbotham, J. (1985). On semantics. *Linguistic Inquiry*, 16(4), p. 547–593. [non vérifié : bibliographies
  secondaires concordantes ; gardé, référence demandée]
- Hobbs, J. R. (1985). Ontological promiscuity. *Proceedings of the 23rd Annual Meeting of the ACL*, p. 60–69. DOI
  10.3115/981210.981218 [vérifié]
- Hobbs, J. R., Stickel, M. E., Appelt, D. E. et Martin, P. (1993). Interpretation as abduction. *Artificial
  Intelligence*, 63(1–2), p. 69–142. DOI 10.1016/0004-3702(93)90015-4 [vérifié]
- Hyman, J. et Bantinaki, K. Depiction. *Stanford Encyclopedia of Philosophy* (première publication 2017 ; révision
  2025). https://plato.stanford.edu/entries/depiction/ [vérifié]
- Iconclass. Aide en ligne, « Basics ». https://iconclass.org/help/basics [vérifié ; lu] ; données :
  https://github.com/iconclass/data (licence CC0-1.0 indiquée sur la page du dépôt) [vérifié]
- ISO 21127:2023. *Information and documentation — A reference ontology for the interchange of cultural heritage
  information*, 3e édition. https://www.iso.org/standard/85100.html [vérifié : page ISO, via les résultats de
  recherche ; l'accès direct à iso.org a été refusé (403)]
- ISO 24617-1:2012. *Language resource management — Semantic annotation framework — Part 1: Time and events
  (SemAF-Time, ISO-TimeML)*. [non vérifié : l'édition courante n'a pas été confirmée]
- ISO 24617-7:2020. *Language resource management — Semantic annotation framework — Part 7: Spatial information
  (ISOspace)*, 2e édition, qui remplace l'édition de 2014. [vérifié : page ISO, via les résultats de recherche ; accès
  direct à iso.org refusé]
- Jackendoff, R. (1990). *Semantic Structures*. MIT Press. [vérifié : compte rendu indexé, *Language* 68(2), 1992,
  DOI 10.2307/416952]
- Kakas, A. C., Kowalski, R. A. et Toni, F. (1992). Abductive logic programming. *Journal of Logic and Computation*,
  2(6), p. 719–770. DOI 10.1093/logcom/2.6.719 [vérifié]
- Kamp, H. (1981). A theory of truth and semantic representation. Dans J. A. G. Groenendijk, T. M. V. Janssen et
  M. B. J. Stokhof (dir.), *Formal Methods in the Study of Language*, Mathematical Centre Tracts 135, Mathematisch
  Centrum, Amsterdam, p. 277–322. [vérifié : scan du volume au CWI et notices ; réimpression : DOI
  10.1093/oso/9780195136975.003.0013]
- Kamp, H. et Reyle, U. (1993). *From Discourse to Logic*. Kluwer (Studies in Linguistics and Philosophy). DOI
  10.1007/978-94-017-1616-1 [vérifié]
- Kamp, H., van Genabith, J. et Reyle, U. (2011). Discourse Representation Theory. Dans D. Gabbay et F. Guenthner
  (dir.), *Handbook of Philosophical Logic*, vol. 15, Springer, p. 125–394. DOI 10.1007/978-94-007-0485-5_3 [vérifié ;
  les directeurs et le volume viennent de ma mémoire]
- Kim, J. (1976). Events as property exemplifications. Dans M. Brand et D. Walton (dir.), *Action Theory*, Reidel,
  p. 159–177. DOI 10.1007/978-94-010-9074-2_9 [vérifié]
- Kipper, K., Korhonen, A., Ryant, N. et Palmer, M. (2008). A large-scale classification of English verbs. *Language
  Resources and Evaluation*, 42(1), p. 21–40. DOI 10.1007/s10579-007-9048-2 [vérifié ; en ligne dès 2007]
- Kipper Schuler, K. (2005). *VerbNet: A Broad-Coverage, Comprehensive Verb Lexicon*. Thèse de doctorat, University of
  Pennsylvania. [non vérifié : citée de façon concordante, parfois datée de 2006 ; gardée, référence de VerbNet]
- Koller, A., Niehren, J. et Thater, S. (2003). Bridging the gap between underspecification formalisms: Hole semantics
  as dominance constraints. *Proceedings of EACL 2003*, p. 195 sq. DOI 10.3115/1067807.1067834 [vérifié ; le
  sous-titre vient de ma mémoire]
- Kowalski, R. et Sergot, M. (1986). A logic-based calculus of events. *New Generation Computing*, 4(1), p. 67–95. DOI
  10.1007/BF03037383 [vérifié]
- Kratzer, A. (1977). What « must » and « can » must and can mean. *Linguistics and Philosophy*, 1(3), p. 337–355. DOI
  10.1007/BF00353453 [vérifié]
- Kratzer, A. (1989). An investigation of the lumps of thought. *Linguistics and Philosophy*, 12(5), p. 607–653. DOI
  10.1007/BF00627775 [vérifié]
- Kratzer, A. (1996). Severing the external argument from its verb. Dans *Phrase Structure and the Lexicon*, Springer
  (Studies in Natural Language and Linguistic Theory), p. 109–137. DOI 10.1007/978-94-015-8617-7_5 [vérifié]
- Kratzer, A. (2012). *Modals and Conditionals: New and Revised Perspectives*. Oxford University Press. DOI
  10.1093/acprof:oso/9780199234684.001.0001 [vérifié]
- Kratzer, A. Situations in natural language semantics. *Stanford Encyclopedia of Philosophy* (première publication
  2007 ; révision 2021). https://plato.stanford.edu/entries/situations-semantics/ [vérifié ; lu (extraits)]

### L–O

- Landman, F. (2000). *Events and Plurality*. Kluwer (Studies in Linguistics and Philosophy). DOI
  10.1007/978-94-011-4359-2 [vérifié]
- Leslie, S.-J. et Lerner, A. Generic generalizations. *Stanford Encyclopedia of Philosophy* (première publication
  2016 ; révision 2022). https://plato.stanford.edu/entries/generics/ [vérifié]
- Levin, B. et Rappaport Hovav, M. (1995). *Unaccusativity: At the Syntax-Lexical Semantics Interface*. MIT Press.
  [vérifié : notices de bibliothèque et compte rendu, *Studies in Language* 21(2), 1997, DOI 10.1075/sl.21.2.11lin]
- Levin, B. et Rappaport Hovav, M. (2005). *Argument Realization*. Cambridge University Press. DOI
  10.1017/CBO9780511610479 [vérifié]
- Lewis, D. (1973). Causation. *The Journal of Philosophy*, 70(17), p. 556 sq. DOI 10.2307/2025310 [vérifié]
- Link, G. (1983). The logical analysis of plurals and mass terms: A lattice-theoretical approach. Dans *Meaning, Use,
  and Interpretation of Language*, De Gruyter, p. 302–323. DOI 10.1515/9783110852820.302 [vérifié]
- Ludlow, P. Descriptions. *Stanford Encyclopedia of Philosophy* (première publication 2004 ; révision 2022).
  https://plato.stanford.edu/entries/descriptions/ [vérifié]
- Lux-Pogodalla, V. et Polguère, A. (2011). Construction of a French Lexical Network: Methodological issues.
  *Proceedings of the First International Workshop on Lexical Resources (WoLeR 2011)*, Ljubljana, p. 54–61. HAL
  hal-00686467. [vérifié : API HAL]
- Maienborn, C. (2005). On the limits of the Davidsonian approach: The case of copula sentences. *Theoretical
  Linguistics*, 31(3), p. 275–316. DOI 10.1515/thli.2005.31.3.275 [vérifié]
- Maienborn, C. (2008). On Davidsonian and Kimian states. Dans *Existence: Semantics and Syntax*, Springer (Studies in
  Linguistics and Philosophy), p. 107–130. DOI 10.1007/978-1-4020-6197-4_4 [vérifié ; le titre du volume vient de ma
  mémoire]
- Maier, E. (2017). Fictional names in psychologistic semantics. *Theoretical Linguistics*, 43(1–2), p. 1–45. DOI
  10.1515/tl-2017-0001 [vérifié]
- Margolis, E. et Laurence, S. Concepts. *Stanford Encyclopedia of Philosophy* (première publication 2005 ;
  révision 2019). https://plato.stanford.edu/entries/concepts/ [vérifié]
- McCarthy, J. et Hayes, P. J. (1969). Some philosophical problems from the standpoint of artificial intelligence.
  *Machine Intelligence 4*. Réimpression dans *Readings in Artificial Intelligence* (1981), p. 431–450. DOI
  10.1016/B978-0-934613-03-3.50033-7 [vérifié : réimpression ; l'édition de 1969 vient de ma mémoire]
- Meghini, C. et Doerr, M. (2018). A first-order logic expression of the CIDOC conceptual reference model.
  *International Journal of Metadata, Semantics and Ontologies*, 13(2), p. 131 sq. DOI 10.1504/IJMSO.2018.098393
  [vérifié]
- Mel'čuk, I. (1996). Lexical functions: A tool for the description of lexical relations in a lexicon. Dans
  *Lexical Functions in Lexicography and Natural Language Processing*, John Benjamins (Studies in Language Companion
  Series 31), p. 37–102. DOI 10.1075/slcs.31.08mel [vérifié]
- Menzies, P. et Beebee, H. Counterfactual theories of causation. *Stanford Encyclopedia of Philosophy* (première
  publication 2001 ; révision 2024). https://plato.stanford.edu/entries/causation-counterfactual/ [vérifié]
- Menzel, C. Possible worlds. *Stanford Encyclopedia of Philosophy* (première publication 2013 ; révision 2016).
  https://plato.stanford.edu/entries/possible-worlds/ [vérifié]
- Mertens, P. (2010). Restrictions de sélection et réalisations syntagmatiques dans DICOVALENCE. Conversion vers un
  format utilisable en TAL. *Actes de TALN 2010, articles longs*, p. 311–320. ACL Anthology
  2010.jeptalnrecital-long.32. [vérifié]
- Meyers, A., Reeves, R., Macleod, C., Szekely, R., Zielinska, V., Young, B. et Grishman, R. (2004). The NomBank
  project: An interim report. *Proceedings of the Workshop Frontiers in Corpus Annotation at HLT-NAACL 2004*,
  p. 24–31. ACL Anthology W04-2705. [vérifié]
- Miller, G. A. (1995). WordNet: A lexical database for English. *Communications of the ACM*, 38(11), p. 39–41. DOI
  10.1145/219717.219748 [vérifié]
- Moens, M. et Steedman, M. (1988). Temporal ontology and temporal reference. *Computational Linguistics*, 14(2),
  p. 15–28. ACL Anthology J88-2003. [vérifié]
- Moldovan, D., Clark, C., Harabagiu, S. et Hodges, D. (2007). COGEX: A semantically and contextually enriched logic
  prover for question answering. *Journal of Applied Logic*, 5(1), p. 49–69. DOI 10.1016/j.jal.2005.12.005 [vérifié]
- Moldovan, D. et Rus, V. (2001). Logic form transformation of WordNet and its applicability to question answering.
  *Proceedings of the 39th Annual Meeting of the ACL*, p. 402–409. DOI 10.3115/1073012.1073064 [vérifié]
- Montague, R. (1973). The proper treatment of quantification in ordinary English. Dans J. Hintikka, J. Moravcsik et
  P. Suppes (dir.), *Approaches to Natural Language*, Reidel, p. 221–242. DOI 10.1007/978-94-010-2506-5_10 [vérifié ;
  les directeurs viennent de ma mémoire]
- Mueller, E. T. (2006 ; 2e éd. 2015). *Commonsense Reasoning: An Event Calculus Based Approach*. Morgan Kaufmann /
  Elsevier. Chapitre « The Event Calculus », DOI 10.1016/B978-012369388-4/50059-X (1re éd.) [vérifié]
- Nebel, B. et Bürckert, H.-J. (1995). Reasoning about temporal relations: A maximal tractable subclass of Allen's
  interval algebra. *Journal of the ACM*, 42(1), p. 43–66. DOI 10.1145/200836.200848 [vérifié]
- Oepen, S., Abend, O., Hajič, J., Hershcovich, D., Kuhlmann, M., O'Gorman, T., Xue, N., Chun, J., Straka, M. et
  Urešová, Z. (2019). MRP 2019: Cross-framework meaning representation parsing. *Proceedings of the Shared Task on
  Cross-Framework Meaning Representation Parsing at CoNLL 2019*, p. 1–27. DOI 10.18653/v1/K19-2001 [vérifié]
- Oepen, S., Abend, O., Abzianidze, L., Bos, J., Hajič, J., Hershcovich, D., Li, B., O'Gorman, T., Xue, N. et Zeman,
  D. (2020). MRP 2020: The second shared task on cross-framework and cross-lingual meaning representation parsing.
  *Proceedings of the CoNLL 2020 Shared Task*, p. 1–22. DOI 10.18653/v1/2020.conll-shared.1 [vérifié]
- Oepen, S. et Lønning, J. T. (2006). Discriminant-based MRS banking. *Proceedings of LREC'06*. ACL Anthology
  L06-1214. [vérifié]
- Ovchinnikova, E. (2012). *Integration of World Knowledge for Natural Language Understanding*. Atlantis Press. DOI
  10.2991/978-94-91216-53-4 [vérifié]
- Ovchinnikova, E., Montazeri, N., Alexandrov, T., Hobbs, J., McCord, M. C. et Mulkar-Mehta, R. (2011). Abductive
  reasoning with a large knowledge base for discourse processing. *Proceedings of IWCS 2011*. ACL Anthology W11-0124.
  [vérifié]

### P–Z

- Packard, W. *ACE: the Answer Constraint Engine*. https://sweaglesw.org/linguistics/ace/ [vérifié : site ; l'auteur
  vient de ma mémoire]
- Palmer, M., Gildea, D. et Kingsbury, P. (2005). The Proposition Bank: An annotated corpus of semantic roles.
  *Computational Linguistics*, 31(1), p. 71–106. DOI 10.1162/0891201053630264 [vérifié]
- Panofsky, E. (1939). *Studies in Iconology: Humanistic Themes in the Art of the Renaissance*. Oxford University
  Press. Réédition Routledge (2018), DOI 10.4324/9780429497063 [vérifié : réédition ; l'édition de 1939 vient de ma
  mémoire]
- Parsons, T. (1990). *Events in the Semantics of English: A Study in Subatomic Semantics*. MIT Press (Current Studies
  in Linguistics 19). [vérifié : PhilPapers et notices de bibliothèque]
- Paul, G. (1993). Approaches to abductive reasoning: An overview. *Artificial Intelligence Review*, 7(2),
  p. 109–152. DOI 10.1007/BF00849080 [vérifié]
- Polguère, A. (2014). From writing dictionaries to weaving lexical networks. *International Journal of
  Lexicography*, 27(4), p. 396–418. DOI 10.1093/ijl/ecu017 [vérifié]
- Pradet, Q., Danlos, L. et de Chalendar, G. (2014). Adapting VerbNet to French using existing resources.
  *Proceedings of LREC'14*, p. 1122–1126. ACL Anthology L14-1204. [vérifié]
- Priest, G., Tanaka, K. et Weber, Z. Paraconsistent logic. *Stanford Encyclopedia of Philosophy* (première
  publication 1996 ; révision 2026). https://plato.stanford.edu/entries/logic-paraconsistent/ [vérifié]
- Pustejovsky, J. (1991a). The syntax of event structure. *Cognition*, 41(1–3), p. 47–81. DOI
  10.1016/0010-0277(91)90032-Y [vérifié]
- Pustejovsky, J. (1991b). The Generative Lexicon. *Computational Linguistics*, 17(4), p. 409–441. ACL Anthology
  J91-4003. [vérifié]
- Pustejovsky, J. (1995). *The Generative Lexicon*. MIT Press. DOI 10.7551/mitpress/3225.001.0001 [vérifié]
- Pustejovsky, J., Lai, K. et Xue, N. (2019). Modeling quantification and scope in Abstract Meaning Representations.
  *Proceedings of the First International Workshop on Designing Meaning Representations*, p. 28–33. DOI
  10.18653/v1/W19-3303 [vérifié]
- Pustejovsky, J., Lee, K., Bunt, H. et Romary, L. (2010). ISO-TimeML: An international standard for semantic
  annotation. *Proceedings of LREC'10*. ACL Anthology L10-1027. [vérifié]
- Pustejovsky, J., Moszkowicz, J. L. et Verhagen, M. (2011). ISO-Space: The annotation of spatial information in
  language. *Proceedings of the Sixth Joint ISO-ACL SIGSEM Workshop on Interoperable Semantic Annotation (ISA-6)*,
  Oxford. [vérifié : actes ISA-6, sigsem.uvt.nl ; la graphie du deuxième auteur varie selon les sources]
- Randell, D. A., Cui, Z. et Cohn, A. G. (1992). A spatial logic based on regions and connection. *Proceedings of the
  3rd International Conference on Principles of Knowledge Representation and Reasoning (KR'92)*, Morgan Kaufmann,
  p. 165–176. [non vérifié sur la source primaire : notices bibliographiques concordantes ; gardé, texte fondateur du
  RCC]
- Rappaport Hovav, M. et Levin, B. (2010). Reflections on manner/result complementarity. Dans *Lexical Semantics,
  Syntax, and Event Structure*, Oxford University Press, p. 21–38. DOI 10.1093/acprof:oso/9780199544325.003.0002
  [vérifié]
- Renz, J. et Nebel, B. (1999). On the complexity of qualitative spatial reasoning: A maximal tractable fragment of
  the Region Connection Calculus. *Artificial Intelligence*, 108(1–2), p. 69–123. DOI 10.1016/S0004-3702(99)00002-8
  [vérifié]
- Reyle, U. (1993). Dealing with ambiguities by underspecification: Construction, representation and deduction.
  *Journal of Semantics*, 10(2), p. 123–179. DOI 10.1093/jos/10.2.123 [vérifié]
- Rosch, E. (1975). Cognitive representations of semantic categories. *Journal of Experimental Psychology: General*,
  104(3), p. 192–233. DOI 10.1037/0096-3445.104.3.192 [vérifié]
- Ruppenhofer, J., Ellsworth, M., Petruck, M. R. L., Johnson, C. R. et Scheffczyk, J. (2006). *FrameNet II: Extended
  Theory and Practice*. International Computer Science Institute, Berkeley. Distribué avec les données FrameNet.
  [vérifié : notice ICSI et copies de 2006 ; une révision de 2016 avec C. F. Baker comme coauteur est souvent citée,
  mais je n'ai **pas** pu la vérifier]
- Russell, B. (1905). On denoting. *Mind*, 14(56), p. 479–493. DOI 10.1093/mind/XIV.4.479 [vérifié]
- Sagot, B. et Fišer, D. (2008). Building a free French wordnet from multilingual resources. *OntoLex 2008*,
  Marrakech. HAL inria-00614708. [vérifié : API HAL]
- Sartini, B., Baroncini, S., van Erp, M., Tomasi, F. et Gangemi, A. (2023). ICON: An ontology for comprehensive
  artistic interpretations. *ACM Journal on Computing and Cultural Heritage*, 16(3), p. 1–38. DOI 10.1145/3594724 ;
  ontologie : https://w3id.org/icon/ontology/ [vérifié]
- Schmidt-Schauß, M. et Smolka, G. (1991). Attributive concept descriptions with complements. *Artificial
  Intelligence*, 48(1), p. 1–26. DOI 10.1016/0004-3702(91)90078-X [vérifié]
- Segers, R., Vossen, P., Rospocher, M., Serafini, L., Laparra, E. et Rigau, G. (2015). ESO: A frame based ontology
  for events and implied situations. *Proceedings of MAPLEX 2015*. [vérifié : notice de la VU Amsterdam]
- Segers, R., Rospocher, M., Vossen, P., Laparra, E., Rigau, G. et Minard, A.-L. (2016). The Event and Implied
  Situation Ontology (ESO): Application and evaluation. *Proceedings of LREC'16*, p. 1463–1470. ACL Anthology
  L16-1233. [vérifié]
- Shanahan, M. (1999). The event calculus explained. Dans *Artificial Intelligence Today* (LNCS 1600), Springer,
  p. 409–430. DOI 10.1007/3-540-48317-9_17 [vérifié ; le titre du volume vient de ma mémoire]
- Shanahan, M. (2000). An abductive event calculus planner. *Journal of Logic Programming*, 44(1–3), p. 207–240. DOI
  10.1016/S0743-1066(99)00077-1 [vérifié]
- Shanahan, M. The frame problem. *Stanford Encyclopedia of Philosophy* (première publication 2004 ; révision 2016).
  https://plato.stanford.edu/entries/frame-problem/ [vérifié]
- Shaw, R., Troncy, R. et Hardman, L. (2009). LODE: Linking open descriptions of events. *The Semantic Web (ASWC
  2009)* (LNCS), Springer, p. 153–167. DOI 10.1007/978-3-642-10871-6_11 [vérifié]
- Simons, P. (1987). *Parts: A Study in Ontology*. Clarendon Press / Oxford University Press. Édition Oxford
  Scholarship Online : DOI 10.1093/acprof:oso/9780199241460.001.0001 [vérifié : édition de 2000 ; la date de 1987 vient
  de ma mémoire]
- Stowe, K., Preciado, J., Conger, K., Brown, S. W., Kazeminejad, G., Gung, J. et Palmer, M. (2021). SemLink 2.0:
  Chasing lexical resources. *Proceedings of the 14th International Conference on Computational Semantics (IWCS)*,
  p. 222–227. ACL Anthology 2021.iwcs-1.21. [vérifié]
- Strawson, P. F. (1950). On referring. *Mind*, 59(235), p. 320–344. DOI 10.1093/mind/LIX.235.320 [vérifié]
- van Hage, W. R., Malaisé, V., Segers, R., Hollink, L. et Schreiber, G. (2011). Design and use of the Simple Event
  Model (SEM). *Journal of Web Semantics*, 9(2), p. 128–136. DOI 10.1016/j.websem.2011.03.003 [vérifié]
- van Lambalgen, M. et Hamm, F. (2005). *The Proper Treatment of Events*. Blackwell. DOI 10.1002/9780470759257
  [vérifié]
- Van Gysel, J. E. L., Vigus, M., Chun, J., Lai, K., Moeller, S. et al. (2021). Designing a Uniform Meaning
  Representation for natural language processing. *KI – Künstliche Intelligenz*, 35(3–4), p. 343–360. DOI
  10.1007/s13218-021-00722-w [vérifié ; lu (version auteur, NSF PAR)]
- Varzi, A. Mereology. *Stanford Encyclopedia of Philosophy* (première publication 2003 ; révision 2026).
  https://plato.stanford.edu/entries/mereology/ [vérifié]
- Vendler, Z. (1957). Verbs and times. *The Philosophical Review*, 66(2), p. 143 sq. DOI 10.2307/2182371 [vérifié]
- Walton, K. L. (1990). *Mimesis as Make-Believe: On the Foundations of the Representational Arts*. Harvard
  University Press. [vérifié : comptes rendus indexés, p. ex. *Philosophy and Phenomenological Research* 51(2), 1991,
  DOI 10.2307/2108138 ; l'éditeur et le sous-titre viennent de ma mémoire]
- W3C (2012). *OWL 2 Web Ontology Language Profiles (Second Edition)*. Recommandation du 11 décembre 2012. B. Motik,
  B. Cuenca Grau, I. Horrocks, Z. Wu, A. Fokoue et C. Lutz (dir.). https://www.w3.org/TR/owl2-profiles/ [vérifié ; lu]
- Zimmermann, T. E. (2016). Painting and opacity. Dans *Von Rang und Namen*, mentis (Brill), p. 425–451. DOI
  10.30965/9783957438775_023 [vérifié, notice ; texte non consulté]

### Ressources consultées localement [L] (lecture seule, hors du dépôt)

- WordNet 3.0 (`/home/user/donnees/WordNet-3.0/dict/`) : synsets et pointeurs de *death*, *die*, *bald*,
  *baldness*, *nose*, *olive oil*, *oil*, *vegetable oil*, *bride*, *groom*, *olive*.
- Liens morphosémantiques (`/home/user/donnees/ressources/morphosemantic-links.xls`, même empreinte MD5 que le
  fichier téléchargé chez Princeton) : 17 739 liens, 14 relations.
- FrameNet 1.7 (`/home/user/donnees/ressources/framenet_v17.zip`) : 1 221 cadres, 13 572 unités lexicales ; cadres
  Death, Dead_or_alive, Placing, Personal_relationship ; relations entre cadres.
- VerbNet 3.3 (`/home/user/donnees/ressources/verbnet-3.3.tar.gz`) : 329 classes ; classe put-9.1.
