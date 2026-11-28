# Les interprétations admissibles : trois niveaux de statut, la supervaluation, les contraintes (version 1.1, 28/11)

**Pour qui :** la propriétaire, avant la spécification des extensions (`docs/TRAJECTOIRE.md`, S2 à S8).

**Journal des révisions.**
- **Version 1 (28/11).** L'étude initiale.
- **Version 1.1 (28/11), d'après trois décisions de la propriétaire sur la version 1.**
  - **R1, les réfutations sous hypothèses : l'option B est choisie** (§ 3.5). L'agrégation ne donne aucune priorité à un
    signe. Une définition établie dans certaines interprétations et écartée dans d'autres garde les deux, avec leurs
    preuves et leurs conditions. Trois choses sont distinguées : la valeur de Belnap dans une interprétation, la
    robustesse à travers les interprétations, la certification. Une contradiction dans une interprétation (B) n'est pas
    une divergence entre interprétations. Le statut synthétique est une fonction du **profil** ; il ne le remplace pas
    (§ 3.5, définitions 4 à 11).
  - **R2, la sûreté est corrigée** (§ 2.5, § 2.6). « Q_sys implique Q_ref » ne garantit que le signe positif. Le signe
    négatif demande l'inclusion inverse (le lion ailé, § 2.6). La validité d'une dérivation et celle de sa certification
    sont séparées. Les mesures de sûreté gardent les deux (§ 2.8).
  - **R3, la supervaluation est complétée** (§ 3.7) : l'ensemble vide, les hypothèses d'une autre nature qu'un choix de
    lecture, les profils mêlés, les substitutions qui varient, les contraintes non locales, les calculs interrompus. Les
    hypothèses gardent leur nature à travers l'agrégation (définition 4).
  - **Ce qui en dépend est corrigé :** § 2.2, § 2.3, § 2.7, § 3.6, § 5.3 à § 5.5, § 6.3, § 8.3 (décisions 1 et 17),
    § 8.4, § 9. L'interpréteur de référence reçoit une liste de propriétés testables (§ 9.6).
  - **Des renvois seulement :** § 1.3 et § 1.4 (le nom `ecartee_sous_hypotheses`), § 4.4 (la mesure h_vacante), § 7.1
    (le statut par chemin est Syn), § 9.8 (le contenu de S2).
  - **Ce qui ne change pas :** le reste de § 1, § 3.1 à § 3.4, § 4, § 6.1, § 6.2, § 6.4, § 6.5, § 7, les principes P1 à
    P8 (validés par la propriétaire), § 8.1 et § 8.2. La preuve par cas et la distinction ∀i∃σ / ∃σ∀i, validées, sont
    gardées.

**Ce que ce document fait.** C'est une étude de fondements. Il prend pour données les décisions de la propriétaire du
28/11, rappelées ci-dessous. Il en tire :
- une définition formelle de trois niveaux de statut, et leurs relations (§ 2) ;
- un espace d'interprétation commun à la description et à la définition, avec ses contraintes (§ 3) ;
- la séparation des exclusions et des préférences (§ 4) ;
- la règle D30 réécrite en termes d'interprétations admissibles, des deux côtés (§ 5) ;
- l'incompatibilité, la négation et la quantification explicite, indexées (§ 6) ;
- la satisfaction relative à un chemin de contextes et à une situation (§ 7) ;
- le regroupement des 40 décisions de `docs/DECISIONS_PHASE1.md` sous huit principes, et leur combinaison (§ 8) ;
- ce que cela demande à chaque composant, et l'ordre de spécification mis à jour (§ 9).

**Ce qu'il ne fait pas.** Il ne code rien. Il ne fixe aucune syntaxe. Il ne change aucun cas et ne recompte aucun
statut. Il ne rediscute pas ce que la propriétaire a tranché. Ce qu'il ajoute est marqué **proposition**.

**Les décisions de la propriétaire (28/11), prises comme données** (celles de la version 1 ; les trois décisions sur la
version 1 sont au journal) **:**
1. **Trois niveaux de statut, distincts :** (a) le statut sémantique de référence, fondé sur la signification de la
   description et de la définition ; (b) le statut démontrable relativement à un ensemble explicite de connaissances K
   et à une représentation formelle correcte ; (c) le statut effectivement obtenu par le système complet. Les limites
   de WordNet, de WOLF ou du noyau ne déterminent pas (a).
2. **Le régime des sens :** ni tous les sens du dictionnaire, ni un sens unique imposé par une heuristique. Le principe
   est la supervaluation sur les interprétations contextuellement admissibles, la désambiguïsation étudiée comme une
   satisfaction de contraintes. Une exclusion démontrée n'est pas une préférence. Le principe s'étend aux ambiguïtés
   syntaxiques, aux coréférences, aux portées, aux lectures collectives et distributives.
3. **Les types des définitions :** le lemme n'est pas un type définitif. Les requêtes portent sur des concepts, des
   sens ou des ensembles de sens explicitement admissibles. L'identité du lemme ne démontre pas l'identité du concept.
   La définition est désambiguïsée symétriquement avec la description.
5. **Les incompatibilités** sont attestées et contextualisées dans K. Incompatibilité logique, antonymie lexicale et
   opposition typique ne se confondent pas. Deux états peuvent être incompatibles pour le même porteur, au même moment,
   dans le même contexte, et compatibles à des moments différents. La négation est reprise dans le cadre d'une
   représentation propositionnelle et d'une quantification explicite. Le silence du texte n'est pas une preuve négative.
6. **Les représentations emboîtées et les situations :** une scène représentée dans un tableau figuré, une vision ou un
   récit satisfait une définition dans son propre contexte. La notation retournée garde le chemin de représentation et
   la situation. Cette satisfaction contextuelle n'est pas la décision documentaire de retenir la notation pour l'œuvre
   principale. L'identité du personnage désigné n'est pas celle de ses occurrences figurées.
9. **Les 40 décisions** sont regroupées par principes et par dépendances. Elles se combinent explicitement.

**Les contraintes de toujours :** le noyau Belnap et sa certification sont gardés, sans faire obstacle à une extension
démontrée nécessaire ; pas de refonte générale ; pas de formalisme pour lui-même ; pas de modèle neuronal obligatoire ;
une indexation qui préserve l'exhaustivité ; l'abduction distincte de la déduction.

**Les abréviations** sont celles de `docs/DECISIONS_PHASE1.md` : FS, ONT, SPEC, NOYAU, AUDIT, QS, BANCS, TRAJ ; DEC
pour ce document-là, « décision n » pour sa n-ième décision ; ÉdA pour `docs/ETAT_DE_L_ART_SEMANTIQUE.md`.
**Les données lexicales** sont lues dans WordNet 3.0 et dans WOLF (OMW 1.4), tels que le projet les a.

## 1. Le problème, par trois exemples

### 1.1 ee-002 : le cavalier et le mendiant

**Le cas.**
- D : « Un cavalier en armure, monté sur un cheval blanc, donne son manteau rouge à un mendiant nu, assis au bord du
  chemin. »
- Δ : « a horseman giving his cloak to a naked beggar ».
- Écrit : `etablie_sous_hypotheses` [sens]. La `decision_ouverte` : `tous_les_sens` donne ce statut,
  `sens_fixe_par_le_contexte` donne `etablie`. La traduction anglaise est `etablie`.

**Ce que dit le sens.** Un lecteur compétent n'a qu'une lecture. Le cavalier est un homme à cheval ; il donne, au sens
d'un transfert ; le manteau est un vêtement ; le mendiant est nu au moment du don. Chaque condition de Δ est remplie.
Le statut de référence est `etablie`.

**Ce que K permet.** « cavalier » a onze sens dans WOLF : un adjectif (*flippant*), un verbe (*knight*, adouber), la
pièce d'échecs, deux sens de document (*rider*, « a clause appended to a legislative bill » ; *check*, l'addition),
*cavalryman*, *horseman*, *knight* (la personne), *passenger*, *rider* d'un animal, *rider* d'un véhicule.
- **La structure** (un nom, après un déterminant) exclut l'adjectif et le verbe. C'est une exclusion démontrée.
- **Une restriction de sélection** de « donner » (l'agent d'un transfert est animé) exclurait la pièce d'échecs et les
  deux sens de document, si elle est attestée, avec l'incompatibilité entre artefact et animé.
- **Il reste six sens de personne.** Un seul, *horseman* (10185793, « a man skilled in equitation »), est inclus dans
  un sens de « horseman ». *Cavalryman* est un soldat ; *horseman* est un hyponyme de *rider*, non l'inverse.
- **Côté Δ,** « horseman » a deux sens : l'écuyer (10185793) et l'éleveur (*horse_fancier*, 10185682). Aucune
  contrainte du libellé n'exclut l'éleveur.
- **Donc,** même avec toutes les contraintes attestables, le statut démontrable est `etablie_sous_hypotheses`, sous
  l'hypothèse conjointe « cavalier ↦ 10185793 ; horseman ↦ 10185793 ». L'écart avec (a) vient de K : la glose de
  WordNet ne dit pas « qui monte un cheval », et rien n'atteste que « monté sur un cheval » fait d'un *rider* un
  *horseman*.

**Ce que fait le système.** Le noyau 0.3, sur le graphe juste, donne le statut écrit : des sens supposés (D30). Le
système complet n'a pas été passé sur le banc (BANCS § 8). Pour la traduction, D30 donne `etablie` par la
lexicalisation, puisque « horseman » est des deux côtés. La décision 3 de la propriétaire n'accepte plus cette preuve :
l'éleveur de chevaux en est le contre-exemple.

**Une variante.** « Un mendiant, désormais vêtu du manteau rouge que le cavalier en armure vient de lui donner,
s'éloigne. » Écrit : `inconnue` sous les deux options de l'incompatibilité vêtu / nu. C'est juste : le mendiant est vêtu
**maintenant** ; il pouvait être nu **au moment du don**. L'incompatibilité est indexée par le moment (§ 6.2).

### 1.2 ee-003 : le roi qui n'est pas mort

**Le cas.**
- D : « An old king lies on his curtained bed, his courtiers around him. The king is not dead: his eyes are open and he
  stretches out a hand towards his eldest son, who kneels at the bedside. »
- Δ : « a dead king lying on his bed, his courtiers around him ».
- Écrit : `inconnue`. La `decision_ouverte` : `ecartee` si le contexte fixe le sens de « dead ».

**Ce que dit le sens.** Le texte nie que le seul roi soit mort ; Δ demande un roi mort. Le statut de référence est
`ecartee` pour ce roi.

**Ce que K permet.** « dead » a dix-sept sens dans WordNet.
- **Les marques syntaxiques de WordNet** excluent quatre sens, selon l'emploi. Deux sont attributifs seulement
  (« dead(a) » : *stagnant*, *utter*) et ne valent pas dans « is not dead ». Deux sont prédicatifs seulement
  (« dead(p) » : *very tired*, *unresponsive*) et ne valent pas dans l'épithète de Δ.
- **Il en reste quinze de chaque côté.** La négation n'est certaine que si chaque sens admissible de Δ est inclus dans
  chaque sens admissible de D. Ce n'est pas le cas : « not dead » au sens de *numb* ne nie pas *no longer having life*.
- **Le statut démontrable est donc `inconnue`,** ou une réfutation sous hypothèse (§ 3.5).
- **Une autre voie existe.** « He stretches out a hand towards his eldest son » fait du roi l'agent d'une action
  volontaire. Si K attestait que l'agent d'une action volontaire est vivant au moment de l'action, et que *vivant* et
  *dead* (00095280) s'excluent pour un même porteur, au même moment, dans le même contexte, le roi aurait un appui
  négatif de *dead* (00095280), quel que soit le sens de « not dead ». Il ne resterait que le sens de Δ (§ 5). Aucune
  ressource du projet n'atteste aujourd'hui la première connaissance ; l'antonymie *dead* / *alive* de WordNet est une
  ressource pour la seconde, non une attestation (décision 7).
- **« His eyes are open »** n'est qu'une opposition typique : un mort peut avoir les yeux ouverts. Elle ne donne aucun
  appui négatif (§ 6.1).

**Ce que fait le système.** Le noyau 0.3 donne `inconnue` (D30). L'ancien K anglais, qui prenait le premier sens de
WordNet, aurait donné `ecartee`, et juste par hasard : le premier sens de « dead » est le bon ici. Le premier sens de
« cloak » est « anything that covers or conceals », celui de « crown » est la Couronne, la monarchie. L'ordre des sens
n'est pas un fait de la scène.

**Une variante.** « According to the chronicle the panel illustrates, he died three days later. » La mort est dans le
contexte d'une source, et trois jours plus tard. Elle ne contredit pas « not dead » au moment figuré (§ 6.2).

### 1.3 mn-004 : aucun ange

**Le cas.**
- D : « The Virgin is enthroned with the Child on her knee, between four standing saints. No angels appear in the
  composition. The upper part of the gold ground is lost. »
- Δ : « the Virgin enthroned with the Child on her knee, angels present ».
- Écrit : `inconnue`. La `decision_ouverte` : `ecartee` si le contexte fixe le sens de « angels ».

**Ce que dit le sens.** « No angels appear in the composition » est une quantification négative, sur le domaine de la
composition. Sous la convention que la définition porte sur ce que l'œuvre montre (décision 19, recommandation), le
statut de référence est `ecartee`. Sous l'autre convention (ce que l'œuvre a été faite pour figurer), la partie perdue
du fond laisse la question ouverte : `inconnue`. Le statut de référence dépend donc d'une **convention de contexte**, non
des sens.

**Ce que K permet.** « angel » a quatre sens : l'être spirituel (09538915), une personne d'une sainteté exceptionnelle,
un investisseur de théâtre, et Angel Falls, une instance.
- **La structure** (un nom commun au pluriel) exclut l'instance. C'est une exclusion démontrée.
- **Il reste trois sens de chaque côté.** La négation n'est certaine que pour les couples où le sens de Δ est inclus
  dans celui de D : les trois couples diagonaux. Elle est vraie dans trois interprétations sur neuf.
- **Aucune contrainte attestable** n'exclut qu'un investisseur ou une sainte personne « appear in the composition ».
  Même si la place de la notation fixait le sens de Δ (§ 5.1), le côté D resterait ouvert.
- **Le statut démontrable** est `inconnue`, ou `ecartee_sous_hypotheses`, sous le choix « angels (D) ↦ 09538915 » (§ 3.5,
  § 3.7 (c)). Le
  domaine religieux et le même lemme **préfèrent** cette hypothèse : ils l'ordonnent en tête, ils ne l'établissent pas.

**Ce que fait le système.** Le noyau 0.3 donne `inconnue` : la règle de l'entité nue niée, seule dans sa classe (NOYAU
§ 1.1), plus D30. Cette règle est une approximation de la quantification explicite, avec un domaine implicite (§ 6.4).

### 1.4 Ce que montrent les trois exemples

| cas | (a) le sens | (b) K du cas, règles provisoires | (b) avec les contraintes attestables | (c) noyau 0.3 sur le graphe juste |
|---|---|---|---|---|
| ee-002 | `etablie` | `etablie_sous_hypotheses` [5 sens supposés] | `etablie_sous_hypotheses` [cavalier, horseman] | (b), provisoire |
| ee-002, traduction | `etablie` | `etablie` (même lemme) | `etablie_sous_hypotheses` [horseman], sauf typage de Δ | `etablie` |
| ee-003 | `ecartee` | `inconnue` | `ecartee` si deux connaissances et le sens de Δ sont attestés | `inconnue` |
| mn-004 | `ecartee` (convention 19) | `inconnue` | `ecartee_sous_hypotheses` [angels ↦ 09538915] (§ 3.5) | `inconnue` |

- **Les trois niveaux diffèrent,** et chaque écart a une cause nommée : une glose, un inventaire des sens, une
  contrainte absente, une convention de contexte, une règle du noyau.
- **Le statut écrit des bancs est un statut (b),** relatif au K du cas et aux règles provisoires (BANCS § 4.1). Son
  `inconnue` veut dire « K ne permet pas de conclure », non « le sens ne décide pas ».
- **Tous les sens, sans contrainte,** confond (a) et (b). **Un sens imposé** par une heuristique peut rendre (c) plus
  fort que (b).
- **Le contexte agit de deux façons, à ne pas confondre :** il exclut (la structure exclut l'adjectif « cavalier ») ou
  il préfère (le domaine religieux préfère l'ange spirituel).

## 2. Les trois niveaux de statut

### 2.1 Les données

- **D** est la description, **Δ** le libellé d'une notation N.
- **C = (C_D, C_Δ)** est le contexte d'interprétation. C_D : la langue, le genre de la notice, l'œuvre. C_Δ : la place
  de N dans Iconclass (ses ancêtres, ses clés), la langue du libellé.
- **P = P_D ⊎ P_Δ** est l'ensemble des **points d'ambiguïté** de D et de Δ (§ 3.1). Chaque point p a une dimension et
  un domaine V(p).
- **Ω = ∏_{p ∈ P} V(p).** Une **interprétation** i ∈ Ω choisit une valeur pour chaque point.
- **Sous i, la représentation est univoque :** G_i = ρ(D, i) est un graphe, Q_i = ρ(Δ, i) une requête. Aucun point n'y
  reste ouvert.
- **Sous i et avec des connaissances K,** le noyau donne à Q_i sur G_i une valeur de Belnap par substitution et un
  statut st_K(i) (NOYAU § 4.4). Ce statut n'a aucune hypothèse de lecture. Il peut en avoir d'une autre sorte :
  abduction, connaissance non attestée.

### 2.2 (a) Le statut de référence

- **I(D, Δ, C) ⊆ Ω** est l'ensemble des interprétations **contextuellement admissibles**, selon la signification de D et
  de Δ dans C. C'est un fait sémantique. Il est **jugé** (le rédacteur, la relecture, l'échantillon de D23). Aucun K ne
  le calcule.
- **K\*** désigne les postulats de signification des concepts en jeu : inclusions et incompatibilités analytiques,
  identités. K\* n'est pas une ressource ; c'est ce que la signification impose.
- **st\*(i)** est le statut de Q_i sur G_i avec K\* (FS § 1.1).
- **Π_a(D, Δ, C)** est le profil (définition 6, § 3.5) des résultats sous K\* sur I(D, Δ, C). **S_a = Syn(Π_a)** en est
  le statut synthétique (définition 10). Le profil est le jugement ; S_a le résume.
- Les limites de WordNet, de WOLF ou du noyau n'y entrent pas.

### 2.3 (b) Le statut démontrable

- **K** est un ensemble explicite et versionné de connaissances attestées, **contraintes comprises** (§ 3.3).
- **V_K(p)** est le domaine que K donne à un point : les sens de K, et la valeur ⊥ quand l'inventaire n'est pas tenu pour
  complet (§ 3.2).
- **I_K(D, Δ, C) = { i ∈ Ω_K : i satisfait toute contrainte dure de K qui s'applique à D et à Δ }.**
- **ρ est correcte :** G_i ne dit rien de plus que D lu selon i, et Q_i ne demande rien de moins que Δ lu selon i.
- **Π_b** est le profil des résultats st_K(i) sur I_K ; **S_b = Syn(Π_b).**

### 2.4 (c) Le statut obtenu

Le système produit ses points P^sys, ses contraintes, son ensemble I^sys, ses graphes G^sys_i et ses requêtes
Q^sys_i. Il calcule son profil Π_c avec son moteur et son budget, et S_c = Syn(Π_c).

### 2.5 Ce qu'affirme un résultat : dérivation et certification, par signe (révisé en 1.1)

Deux résultats se comparent par ce qu'ils **affirment**, non par leur nom. Une affirmation a un **signe** (positif,
négatif) et une **force** (dérivée, certifiée). Les quatre se définissent sous une interprétation i, pour une
substitution σ, à un niveau L ∈ {\*, K, sys} : K\* et G_i pour (a), K et G_i pour (b), K et G^sys_i pour (c).

**Définition 1 (dérivations).**
- **D⁺_L(i, σ) = 1** si Q_i a sous σ un **arbre positif** (NOYAU § 4.5) : chaque atome sélectionné a un appui positif,
  de tout énonciateur.
- **D⁻_L(i, σ) = 1** si Q_i a sous σ un **arbre négatif** : un enfant d'un `et`, tous ceux d'un `ou`, chaque atome lié
  par un appui négatif (§ 6.3).
- **val_L(i, σ) = (D⁺, D⁻)** est la valeur de Belnap de Q_i sous σ : N = (0,0), V = (1,0), F = (0,1), B = (1,1).

**Définition 2 (certifications).**
- **C⁺_L(i, σ)** : une solution certifiable (NOYAU § 4.3). C'est une dérivation positive dont les appuis sont de
  l'auteur, admissibles, de prémisses non niées, **et** l'absence d'appui négatif connu pour ses atomes.
- **C⁻_L(i, σ)** (nouveau, option B) : une **réfutation certifiable**. C'est une dérivation négative dont les fondements
  sont l'auteur, le texte ou une distinction documentaire (NOYAU § 4.4), **et** l'absence d'appui positif connu de Q_i
  sous σ.
- **La symétrie :** chaque certification est une dérivation d'un signe, plus l'absence connue de l'autre signe. La
  dérivation affirme quelque chose du niveau plus exigeant. L'absence est relative à K et au graphe : c'est le monde
  ouvert, des deux côtés.

**Lemme 1 (monotonie), admis comme en version 1.** À i fixée, D⁺ et D⁻ ne font que croître quand K grandit (plus de
liens, plus d'incompatibilités) et quand le graphe dit plus (NOYAU § 4.5). C⁺ et C⁻ ne sont pas monotones : une
connaissance nouvelle peut allumer l'autre signe, et la valeur devient B.

**Définition 3 (les affirmations d'un résultat).** Un résultat de niveau L affirme quatre ensembles de triplets
(i, σ, H), où H est la liste des hypothèses non lexicales requises (définition 4) :
- A⁺_der(L) = { (i, σ, H) : D⁺_L(i, σ) = 1 sous H } et A⁺_cert(L) = { (i, σ, H) : C⁺_L(i, σ) sous H } ;
- A⁻_der(L) et A⁻_cert(L), de même pour le signe négatif.

**L'axe positif** d'un résultat est (A⁺_der, A⁺_cert). **L'axe négatif** est (A⁻_der, A⁻_cert). Ce que chaque statut
synthétique garantit sur chaque axe est au § 3.5 (définition 11).

### 2.6 Les relations entre les niveaux : deux propositions de sûreté (révisé en 1.1)

**La correction de la version 1.** La version 1 affirmait qu'avec « Q^sys_i implique Q_i », tout ce que le système
affirme, des deux signes, vaut au niveau supérieur. C'est faux pour le signe négatif. Une requête plus forte est plus
facile à réfuter : sa réfutation ne réfute pas une requête plus faible. Le contre-exemple est plus bas.

**Les conditions sur K et sur la représentation.**
- **(K1) K est correct :** chacune de ses entrées est vraie selon K\*. Donc tout appui de K, d'un signe ou de l'autre,
  est un appui de K\*.
- **(K2) Les exclusions de K sont correctes :** I(D, Δ, C) ⊆ I_K. Un sens de référence absent de V_K y est représenté par
  ⊥.
- **(R) ρ est exacte,** en deux moitiés par signe :
  - **(R_G)** G_i ne dit rien de plus que D lu selon i (pour les dérivations), **et rien de moins** (pour les
    certifications : un graphe qui oublie une négation de D certifie à tort) ;
  - **(R_Q)** Q_i demande Δ lu selon i, ni plus ni moins.

**Les conditions sur le système.** Pour chaque i ∈ I_K, une interprétation i' ∈ I^sys lui correspond (à une
correspondance des points près ; on écrit i' ~ i).
- **(S_I)** Toute i ∈ I_K a une correspondante : le système n'exclut rien sans une contrainte de K.
- **(S_G)** G^sys_{i'} ≼ G_i : chaque assertion du premier est une assertion du second, avec les mêmes qualificatifs.
  Une classe de G^sys_{i'} est incluse dans une classe de G_i ; une substitution de l'un se lit dans l'autre.
- **(S⁺_Q)** **Q^sys_{i'} ⊆ Q_i** au sens de NOYAU § 8, avec l'homomorphisme h⁺ : var(Q_i) → var(Q^sys_{i'}) qu'il
  construit.
- **(S⁻_Q)** **Q_i ⊆ Q^sys_{i'}** au sens de NOYAU § 8, avec h⁻ : var(Q^sys_{i'}) → var(Q_i).
- **(S_M)** Le moteur est correct ; ses preuves, des deux signes, sont acceptées par le vérificateur.

**Proposition 1 (sûreté positive).** Sous (K1), (K2), (R), (S_I), (S_G), (S⁺_Q) et (S_M), pour toute i ∈ I(D, Δ, C),
toute i' ~ i et toute substitution σ de Q^sys_{i'} :
1. **la dérivation se transmet :** D⁺_sys(i', σ) = 1 entraîne D⁺_\*(i, σ ∘ h⁺) = 1 ;
2. **la certification ne se transmet que sans contradiction manquante :** C⁺_sys(i', σ) entraîne C⁺_\*(i, σ ∘ h⁺) si et
   seulement si D⁻_\*(i, σ ∘ h⁺) = 0. Une condition suffisante : chaque appui négatif de Q_i dans (G_i, K\*) est l'image
   d'un appui négatif de Q^sys_{i'} dans (G^sys_{i'}, K). Elle demande que le lecteur n'ait oublié aucune négation, que
   K ait les incompatibilités et les inclusions pertinentes, et que le comparateur transmette la négation (NOYAU § 8,
   étape 3).

**Pourquoi.** (1) : l'homomorphisme de Q_i dans le graphe canonique de Q^sys_{i'} porte chaque appui positif de Q^sys
vers un appui de Q_i (NOYAU § 8) ; (S_G) et le lemme 1 le portent de (c) à (a) ; (K2) garantit que i est bien une
interprétation de (b). (2) : C⁺ = D⁺ et l'absence de D⁻ ; l'absence est relative.

**Proposition 2 (sûreté négative).** Sous (K1), (K2), (R), (S_I), (S_G), (S⁻_Q) et (S_M), pour toute i ∈ I(D, Δ, C),
toute i' ~ i et toute substitution τ de Q_i :
1. **la dérivation se transmet, par substitution :** si D⁻_sys(i', τ ∘ h⁻) = 1, alors D⁻_\*(i, τ) = 1. Une réfutation du
   système pour σ ne porte sur Q_i que si σ se factorise par h⁻ (σ = τ ∘ h⁻). Sinon, rien ne se transmet ;
2. **la certification ne se transmet que sans établissement manquant :** C⁻_sys(i', τ ∘ h⁻) entraîne C⁻_\*(i, τ) si et
   seulement si D⁺_\*(i, τ) = 0. Un appui positif de Q_i que le système n'a pas (un lien absent de K, une assertion
   oubliée) fait de la référence un B.

**Pourquoi.** (1) : Q_i ⊆ Q^sys_{i'} demande, à l'étape 3 de NOYAU § 8, que ce qui nie Q^sys nie Q_i : c'est la
transmission de la négation, dans ce sens-là. (2) : l'homomorphisme porte tout appui positif de Q_i vers un appui positif
de Q^sys ; si Q^sys n'en a aucun dans G^sys, Q_i n'en a aucun dans G^sys ; mais G_i et K\* peuvent en avoir.

**Les deux arguments** sont écrits, non démontrés mécaniquement. Ils supposent le lemme 1.

**Le contre-exemple du lion ailé.**
- **Q_ref** = ∃x `type(x, lion)`. **Q_sys** = ∃x `type(x, lion)` ∧ `propriete(x, ailé)`.
- Q_sys ⊆ Q_ref : le graphe canonique de Q_sys établit Q_ref, et « pas de lion » nie les deux. Q_ref ⊄ Q_sys.
- **D :** « un lion, sans ailes ». Le graphe : `entite(e, lion)` positive ; `propriete(e, ailé)` négative.
- **Sous σ = {x ↦ e} :** Q_sys vaut F (l'atome `propriete` est nié) et sa réfutation est certifiable. Q_ref vaut V, et il
  est certifié.
- **Le système écrirait `ecartee`, la référence est `etablie`.** La proposition 1 n'est pas en défaut : le système
  n'affirme rien de positif. La proposition 2 ne s'applique pas : (S⁻_Q) est faux.
- **L'inverse.** Q_sys = un lion, Q_ref = un lion ailé, D = « un lion ». Q_sys est `etablie`, Q_ref `inconnue` : une
  erreur positive ; (S⁺_Q) est faux. Mais « pas de lion » réfute les deux : (S⁻_Q) est vrai, la réfutation se
  transmet.

**La sémantique paraconsistante.** Les deux propositions portent sur D⁺ et D⁻ séparément, qui sont monotones. Elles ne
portent pas sur la négation classique : un appui négatif du noyau n'est pas l'absence d'un appui positif (monde ouvert ;
NOYAU § 1.1 ne décompose pas une négation de conjonction ; un lien négatif ne prend que `inclus`). Une inclusion des
appuis positifs ne donne donc pas, à elle seule, la contraposée : il faut la vérifier, c'est l'étape 3 du comparateur.
Une valeur B de Q^sys donne D⁺ en référence sous (S⁺_Q), D⁻ sous (S⁻_Q), et B sous les deux.

**Corollaire (l'équivalence).** Les deux signes ne se transmettent ensemble que si Q^sys_{i'} ≡ Q_i (les deux
inclusions). Avec une seule inclusion, le système ne rapporte, pour la notation, que le signe licite. L'autre signe est
gardé comme information sur Q^sys, hors du statut de la notation.

**Ce que cela impose au comparateur d'inclusion (NOYAU § 8).**
1. Il est appelé **dans les deux sens,** par classe d'interprétations : Q^sys_{i'} contre Q_i.
2. Il rend **l'homomorphisme** (h⁺ ou h⁻), pour traduire les substitutions.
3. Son étape 3 (la transmission de la négation) sert le positif dans un sens et le négatif dans l'autre. Elle ne change
   pas ; on change ce qu'on en conclut.
4. Un verdict `indetermine` ne licencie aucun signe ; `non` non plus.
5. Les atomes nouveaux (types par ensembles de sens, `non/1`, quantifications, chemins, `meme_individu`) entrent dans la
   méthode avec leurs règles de transmission, ou donnent `indetermine`.
6. Son banc reçoit le lion ailé dans les deux sens, et une mutation : un comparateur qui licencie le négatif par
   l'inclusion positive doit être détecté.

**Ce que cela impose au vérificateur (NOYAU § 6).**
1. Il contrôle les **réfutations** comme les solutions : l'arbre négatif, ses fondements, et l'absence d'appui positif de
   Q sous σ dans le graphe et K (un contrôle fini).
2. Sur un banc, il contrôle que chaque signe rapporté pour la notation est licencié par le verdict du comparateur dans
   le bon sens.
3. Il contrôle la nature de chaque hypothèse (définition 4).
4. **Il ne peut pas voir une erreur de certification :** il certifie relativement à K et au graphe. Une contradiction qui
   manque à K lui est invisible ; seules les mesures du § 2.8 la voient.

**Ce que cela donne sur les statuts synthétiques,** de (b) à (a), sous (K1), (K2) et (R) (de (c) à (b), sous les
conditions (S) du signe en jeu).
- **S_b = `etablie`** : chaque i ∈ I_K a C⁺_K, donc chaque i ∈ I(D, Δ, C) a D⁺_\*. Chaque classe de (a) est V ou B.
  S_a ∈ {`etablie`, `etablie_sous_hypotheses`, `contradictoire`, `aucune_interpretation`}. Jamais `divergent`,
  `ecartee` ni `inconnue`.
- **S_b = `ecartee`,** symétriquement : S_a ∈ {`ecartee`, `ecartee_sous_hypotheses`, `contradictoire`,
  `aucune_interpretation`}.
- **S_b = `etablie_sous_hypotheses`(h)** : ou bien [h] ∩ I(D, Δ, C) = ∅ (h est vacante en (a) : K n'a pas l'exclusion),
  ou bien les classes de [h] en (a) sont V ou B. De même pour `ecartee_sous_hypotheses`, avec F ou B.
- **S_b = `divergent`** : chaque signe, sur ses classes, comme ci-dessus.
- **Sur les dérivations,** (c) ⊆ (b) ⊆ (a), signe par signe, sous les conditions du signe. **Sur les certifications,**
  aucune inclusion n'est garantie : les écarts se mesurent (§ 2.8).
- **Une dérivation de (b) absente de (a), observée sur un cas, réfute (K1), (K2) ou (R).** C'est un test de K.
- **Une certification de (b) que (a) contredit** (la classe est B en (a)) n'est pas une réfutation de K : c'est une
  connaissance qui manque à K. Elle n'est pas pour autant ignorée : c'est une erreur de certification, mesurée à part.

**Ce que mesure chaque écart.**

| écart | ce qu'il mesure | exemples |
|---|---|---|
| (a) → (b) | K : l'inventaire des sens, les inclusions, les incompatibilités, les contraintes absentes ; la représentation : ce que le langage ne peut pas dire | ee-002 (la glose de *horseman*) ; mn-004 (aucune contrainte sur « angels ») ; ee-019 (sans situations, une représentation correcte ne peut pas fusionner les deux figures, et reste plus faible) |
| (b) → (c) | la lecture (assertions, points, contraintes du lecteur), la compilation, le raisonnement (D41, l'approximation ∃σ∀i du § 3.5, le budget) | sa-004#3 et les six autres `ecartee` de la décision 6, que le noyau 0.3 ne dérive pas |

### 2.7 Les deux mesures de la traduction

Soit D' une traduction de D.
- **En (a),** Π_a(D', Δ, C) = Π_a(D, Δ, C), à la correspondance des points près, donc S_a(D') = S_a(D). La traduction
  garde le sens : c'est l'invariance stricte de QS § 2.2. Elle porte sur le profil, non sur le seul nom du statut.
- **En (b),** Π_b(D') peut différer de Π_b(D). L'écart mesure la **couverture de K** dans les deux langues (WOLF contre
  WordNet), non une erreur. Il se lit aussi sur les hypothèses : ee-002 en a cinq en français, deux en anglais.
- **En (c),** l'écart à (b) mesure le lecteur de chaque langue.

La recommandation de DEC § 3.1 (« une invariance relative à K ») devient : l'invariance en (a), la mesure en (b).

### 2.8 Ce que cela change pour les bancs, et les mesures de sûreté (révisé en 1.1)

- **Deux profils par cas :** `profil_reference`, le niveau (a), jugé (le guide `docs/ANNOTATION_REFERENCE.md`) ;
  `profil_K`, le niveau (b), calculé sur le K du cas. Chacun a son statut synthétique. Le `statut_attendu` actuel est un
  statut (b) sous les règles provisoires.
- **La `sorte`,** qui suit l'intention (DEC § 3.2), est une approximation de (a).

**Les mesures.** Elles comparent un profil mesuré Π_m à un profil de référence Π_r : (c) contre (b), (c) contre (a), ou
(b) contre (a). Elles se comptent sur les couples (cas, classe i de Π_r), avec i' ~ i dans Π_m. Elles se lisent par
substitution quand Π_r donne ses substitutions (niveau (b)), par classe sinon (le guide d'annotation ne note pas les
substitutions). Une affirmation de Π_m sous des hypothèses non lexicales H se juge **en accordant H** : la référence
évalue la classe sous H.

**Définition 12 (les mesures de sûreté).** Elle est numérotée après celles du § 3.5, dont elle emploie le profil.
1. **e⁺_der, l'erreur positive de dérivation :** Π_m certifie le positif dans i' (C⁺, sous H), et la référence n'a
   aucune dérivation positive dans i (sa valeur y est F ou N). Une violation de la proposition 1, point 1.
2. **e⁺_cert, l'erreur positive de certification :** Π_m certifie le positif dans i', et la référence y a les deux
   dérivations (sa valeur est B). La dérivation est bonne ; une contradiction pertinente manque au niveau mesuré (à K,
   ou au graphe du lecteur).
3. **e⁻_der, l'erreur négative :** Π_m certifie le négatif dans i' (C⁻), et la référence n'a aucune dérivation négative
   dans i (V ou N). Une violation de la proposition 2, point 1. On compte à part **e⁻_cert,** la réfutation certifiée
   là où la référence est B : un établissement manque au niveau mesuré.
4. **d_nr, la divergence non rapportée :** Π_r est divergent (des classes certifiées des deux signes), Π_m a été calculé
   complètement, et le résultat que Π_m rend pour la notation n'a pas les deux signes, avec leurs preuves et leurs
   conditions. Le même contrôle vaut à l'intérieur du système : un profil divergent dont la sortie (la notation rendue,
   l'index, le classement) ne garde qu'un signe.
5. **n_perdue, l'hypothèse dont la nature a été perdue :** une hypothèse de Π_m dont la nature diffère de celle de la
   référence (une abduction rendue comme un choix de lecture, une identité supposée rendue comme un sens), ou une
   hypothèse **effacée** (Π_m affirme sans condition ce que la référence n'affirme que sous H).

**Ce qui n'est pas une erreur, et se mesure aussi.**
- **h_vacante :** Π_m affirme sous un choix h tel que [h] ∩ I_r = ∅. K n'a pas l'exclusion (co-015, § 4.4).
- **Un affaiblissement :** Π_m n'affirme rien, ou affirme sous un choix, là où Π_r affirme sans condition. C'est un écart
  de K ou du lecteur (§ 2.6, le tableau des écarts).

**Comment on les publie.** Six nombres, chacun en taux de cas et en taux de classes : e⁺_der, e⁺_cert, e⁻_der,
e⁻_cert, d_nr, n_perdue. Ils ne s'additionnent jamais. Les erreurs de dérivation, d_nr et n_perdue sont des **erreurs
de sûreté** : un système correct n'en fait aucune sous les conditions du § 2.6. Les erreurs de certification sont des
**erreurs de certification** : un système correct en fait tant que K ou le lecteur sont incomplets, et chacune est
rapportée avec sa cause (l'entrée de K, ou la négation du texte, qui manque).

**Des exemples.**
- **e⁻_der :** le lion ailé (§ 2.6), si le système rapporte la réfutation de Q_sys comme celle de la notation.
- **e⁺_der :** l'inverse (« un lion » contre « un lion ailé ») ; ou la traduction d'ee-002 si l'identité du lemme
  « horseman » est prise pour une identité de concept et que la référence juge l'éleveur (le cas ne le juge pas : c'est
  le risque que la décision 3 retire).
- **e⁺_cert :** une variante de sa-022 où D dit aussi que Jacob dort. En (a), « éveillé » et « endormi » s'excluent : la
  classe est B. Un K sans cette incompatibilité certifie « Jacob asleep ». La dérivation est bonne ; la certification
  est fausse.
- **d_nr :** ep-009 lu selon § 3.7 (c), si le système ne rend que la lecture intrinsèque.
- **n_perdue :** pi-003, si l'identité de Martin entre les deux situations (nature `identite`) est rendue comme un
  choix de sens ; co-018#4, si une branche de l'alternative est choisie et rendue comme un choix de lecture (c'est une
  abduction, § 3.4).

**La décision 17 (BANCS § 7)** se rédige avec ces mesures : l'ordre de sûreté se lit sur les affirmations, signe par
signe, et la certification à part.

## 3. L'espace d'interprétation

### 3.1 Les points d'ambiguïté

Un point est ancré à une occurrence : son côté (description ou définition), l'assertion ou la position dans le libellé,
le mot.

| dimension | le point | son domaine | côté | exemple du banc |
|---|---|---|---|---|
| sens lexical | une occurrence d'un mot plein | les sens de K, et ⊥ | D, Δ | « cavalier » (ee-002), « dead » (ee-003) |
| sens d'une relation | une préposition, une construction | les concepts de relation de la table (décision 35) | D, Δ | « de » de partie, de possession, de matière (ep-004) |
| structure | un participe détaché, une relative, un complément, une unité lexicalisée | les têtes de rattachement ; l'unité ou la construction | D, Δ | « le bénissant » (sa-010) ; « jeune homme » (dc-024#1) |
| coréférence | un pronom, une reprise | les antécédents, et un référent nouveau | D | « Il élève le calice » (rq-002) |
| portée | une négation, une modalité, un quantificateur | les ordres de portée | D, Δ | « perhaps » dans une coordination (décision 39) |
| lecture d'un pluriel | un groupe sujet d'un prédicat | collective, distributive | D, Δ | « Two angels crown her » (rq-010) ; « offrent un présent » (rq-011) |
| cadre de référence | « à droite », « devant » | intrinsèque (de X), spectateur, image | D, Δ | ep-009 |
| ancrage temporel | une éventualité | en cours, antérieure, imminente, hors du temps figuré | D, Δ | « about to strike » (ee-009) ; « s'apprête à » (décision 26) |
| contexte | une assertion dont le chemin n'est pas fixé | les chemins candidats | D | « selon X » (décision 16) ; « un ange de marbre » (décisions 13, 31) |
| identité | deux figures ; un nom partiel | même individu ou non ; les individus documentés | D | « saint Martin » deux fois (pi-003) ; « St John » (pi-014) |
| forme du libellé | une liste, un pluriel | liste d'exemples ou liste fermée ; au moins un, au moins deux | Δ | « e.g. lute, viol » ; « instruments » (co-019) |

### 3.2 Les domaines

- **En (a),** V(p) contient les valeurs que la langue permet.
- **En (b),** V_K(p) contient celles que K connaît. **La condition d'inventaire :** si le sens voulu manque à K et que
  tous les sens de K atteignent le type demandé, (b) conclurait à tort. Il faut donc que K **déclare** la complétude de
  son inventaire pour un lexique (proposition) : tenue pour WordNet sur les noms communs anglais, comme une partie de
  (K1) ; non tenue pour les lacunes connues de WOLF (la liste de la décision 3), où le domaine reçoit ⊥. Sous ⊥, aucun
  lien et aucune négation.
- **D20** (un mot sans concept est son propre sens) devient ⊥ (proposition, § 5.2).

### 3.3 Les contraintes

**Ce qu'est une contrainte.** c = (pts(c), Interdits(c), source(c), sorte(c)), où pts(c) ⊆ P et
Interdits(c) ⊆ ∏_{p ∈ pts(c)} V(p). Une contrainte est **dure** (elle exclut) ou une **préférence** (§ 4).

**Les contraintes dures, par sorte.**

| sorte | ce qu'elle exclut | source | exemple |
|---|---|---|---|
| catégorie, marques syntaxiques | les sens d'une autre catégorie ; un adjectif attributif seul en emploi prédicatif, prédicatif seul en épithète | l'analyse ; les marques « (a) » et « (p) » de WordNet | « cavalier » adjectif ; « dead(a) » dans « is not dead » |
| nombre, nom propre | les sens d'instance pour un nom commun au pluriel | WordNet (`@i`) et la morphologie | Angel Falls dans « no angels » |
| cadre de sous-catégorisation | les sens dont le cadre ne s'accorde pas à la construction | les cadres de phrase de WordNet, VerbNet, DICOVALENCE | « donner X à Y » exclut « donner sur » |
| restriction de sélection | les sens d'un argument dont le type est incompatible avec la restriction du sens du prédicat | VerbNet, DICOVALENCE (Mertens 2010), **plus** une incompatibilité de types attestée | l'agent animé d'un transfert exclut la pièce d'échecs [restriction de VerbNet à vérifier] |
| accord | les antécédents d'un autre genre ou d'un autre nombre | la grammaire | « Il » exclut « Marie » |
| composition | les combinaisons mal typées | les règles de composition | « couronne d'épines » : l'unité ou la construction (décision 31) |
| marqueur de contexte | les chemins que le texte exclut | le texte : « in a cloud above him his dream is shown » | mn-022 |
| identité dite | les identités et distinctions contraires | le texte : « la même jeune femme », « un autre homme » | ee-019, pi-002 |
| connaissance documentaire | les combinaisons contredites | K : distinction documentaire, alias | « St John » : deux individus documentés distincts (pi-014) |

**Deux précisions.**
- **Une restriction de sélection n'exclut** qu'avec une incompatibilité attestée entre le type restreint et le type de
  la valeur (artefact contre animé). Elle ne vaut que dans les contextes où elle est attestée (§ 4.5).
- **Les contraintes du lecteur** (catégorie, rattachement, accord) reposent sur des faits d'analyse. Ces faits sont des
  prémisses du graphe, au même titre que ses assertions. Le vérificateur refait l'exclusion à partir d'eux ; il ne
  certifie pas que l'analyse est juste (NOYAU § 6, dernier alinéa).

### 3.4 Les interprétations admissibles

- **I_K = { i ∈ Ω_K : pour toute contrainte dure c, la restriction de i à pts(c) n'est pas dans Interdits(c) }.**
- **Une valeur v du point p est exclue** si aucune i ∈ I_K n'a i(p) = v. L'exclusion est démontrée : elle suit des
  contraintes citées et de leurs sources.
- **L'indépendance (proposition) :** aucune contrainte dure ne relie un point de D et un point de Δ. Donc
  I_K = I_K(D, C_D) × I_K(Δ, C_Δ). Trois raisons :
  - une contrainte qui choisirait la lecture de D d'après Δ ferait dépendre la lecture de la réponse ;
  - elle romprait l'inclusion des requêtes (NOYAU § 8), qui compare des requêtes sans aucune description ;
  - elle romprait l'index, qui doit servir la même requête à toutes les descriptions.
  Une **préférence** couplée (« même lemme, même sens ») reste permise : elle ordonne.
- **Une alternative de l'auteur n'est pas une ambiguïté.** « Either a monk or a nun » (co-018#4) dit que l'une ou
  l'autre est vraie : la disjonction est l'information. Ses branches sont des **cas** pour la supervaluation (une
  conclusion vraie dans chaque branche est établie). Elles ne sont pas des **valeurs à choisir** : une hypothèse qui
  choisit une branche ajoute une information que D ne donne pas. C'est une abduction, qui doit expliquer des
  observations (décision 33, sa-020).

### 3.5 La supervaluation : le profil, la robustesse, la certification, le statut synthétique (révisé en 1.1)

**La décision de la propriétaire (R1).** L'option B est choisie. L'agrégation de la version 1 donnait la priorité au
positif (une seule classe `etablie` faisait le statut, quelles que soient les autres). Elle est remplacée. Trois choses
sont distinguées :
- la **valeur de Belnap** de la requête dans une interprétation, par substitution (définition 1) ;
- la **robustesse** de cette valeur à travers les interprétations (définition 7) ;
- la **certification** (définitions 2 et 8).

Une contradiction **dans** une interprétation (B) n'est pas une **divergence** entre interprétations (V dans l'une, F
dans l'autre). Le statut synthétique est une fonction du profil (définition 10). Il ne le remplace pas.

**Les hypothèses de lecture sont des choix** (version 1, gardé). Une hypothèse de lecture est un **cylindre**
h = ⋀_{p ∈ H} (p ∈ W_p), avec W_p ⊊ V(p). Elle s'écrit `choix(Point, Valeurs)`. [h] = { i ∈ I : i satisfait h }. Elle
est **admissible** si [h] ≠ ∅. Une union finie de cylindres décrit n'importe quelle partie de I.

**Définition 4 (hypothèse, nature).** Une hypothèse est un couple (ν, contenu). Sa **nature** ν est prise dans :
- `lecture(d)`, d une dimension du § 3.1 : un choix sur un point. `lecture(sens)` est l'hypothèse **lexicale** ;
  `sens_suppose` et `negation_autre_sens` du noyau en sont des formes (§ 5.4) ;
- `identite` : une identité ou une distinction de figures que le texte ne laisse pas ouverte comme une lecture, et que
  fonde une préférence (le même nom, des noms différents) : `distinction_supposee`, `meme_individu` supposé (§ 7.4). Un
  nom partiel (« St John », pi-014) est, lui, un point de dimension identité : son choix est de nature
  `lecture(identite)` ;
- `abduction` : une explication d'observations (SPEC § 4), y compris le choix d'une branche d'une alternative de
  l'auteur (§ 3.4) ;
- `connaissance_typique` et `identification_iconographique` : une connaissance non analytique (le guide d'annotation,
  § 1) ;
- `convention` : une convention d'évaluation non tranchée (§ 8.4).

**La règle de conservation.** La nature d'une hypothèse est fixée quand elle naît. Aucune étape ne la change : ni la
factorisation en classes, ni l'agrégation, ni la preuve, ni le statut synthétique. Deux hypothèses de natures
différentes ne se fondent jamais en une. Un choix de lecture n'est pas une abduction : il sélectionne une lecture que le
texte a ; une abduction ajoute une explication du monde.

**Définition 5 (le résultat sous une interprétation).** Pour i ∈ I, le noyau, sur (G_i, Q_i, K), dans chaque chemin π et
chaque situation s (§ 7.1), rend R(i) :
- **pour chaque substitution examinée σ** (NOYAU § 4.4) : la valeur val_i(π, s, σ) ∈ {N, V, F, B} ; les énonciateurs
  E⁺_i(σ) et E⁻_i(σ) des appuis de chaque signe (`auteur`, `cite(X)`) ; la certification de chaque signe (C⁺, C⁻, ou
  aucune, avec sa raison) ; les hypothèses H_i(σ) requises, toutes d'une nature autre que `lecture` (la lecture est
  fixée par i) ;
- **le statut local** st(i) : le statut de NOYAU § 4.4, étendu par la réfutation certifiable (définition 2). Ses valeurs
  sont E (`etablie`), E_H (établie sous des hypothèses non lexicales), R (`ecartee`), R_H (écartée sous des hypothèses
  non lexicales), B (`contradictoire`), NC (`non_certifiee`), N (`inconnue`), ? (`incomplet`) ;
- **un drapeau** `complet`.

**Dans une interprétation, l'ordre du noyau reste.** Le statut local garde l'ordre de NOYAU § 4.4 : une solution
certifiable, puis une contradictoire, puis une vraie non certifiable, puis une fausse. Ce n'est pas une priorité d'un
signe. La requête est existentielle, et deux substitutions parlent de deux référents : une fausse dit « pas ceux-ci »,
une vraie dit « ceux-là ». Rien n'est perdu : R(i) garde toute la vue (NOYAU § 7), les fausses comprises.

**NC a un signe (proposition, pour NOYAU 0.4).** NOYAU 0.3 rend `non_certifiee` une vérité qui passe par la seule parole
d'une source citée, mais `ecartee` une réfutation dont les fondements sont tous `cite(X)`. La symétrie demande NC⁻ pour
celle-ci : une réfutation par la seule parole d'une source. Sans cette décision, la table ci-dessous lit NOYAU 0.3, et
l'asymétrie est signalée. Avec les chemins du § 7.5, la question se réduit : une assertion « selon X » est dans le
chemin de X.

**Les substitutions se comparent par mentions.** Sous i, la valeur d'une variable est une classe de coréférence de G_i.
Les classes varient avec les points de coréférence. Deux substitutions σ_i et σ_j sont **la même au sens des mentions**
si, pour chaque variable X, σ_i(X) et σ_j(X) ont une mention commune.

**Définition 6 (le profil).** Le profil est Π = (I, R), R : I → résultats. Deux interprétations de même résultat, à la
comparaison des substitutions par mentions près, sont dans la même **classe**. Le profil se donne par classes : pour
chaque classe c, une description exacte de [c] (une union de cylindres), et R(c), c'est-à-dire, par chemin et situation
et par substitution, la valeur de Belnap, les hypothèses non lexicales avec leur nature, les énonciateurs, la
certification, la complétude. Le profil sur I = ∅ est le **profil vide**.

**Définition 7 (la robustesse).** Pour chaque statut local λ, I^λ = { i ∈ I : st(i) = λ }. Les I^λ partitionnent I. On
pose **I⁺ = I^E ∪ I^{E_H}** et **I⁻ = I^R ∪ I^{R_H}**.
- La robustesse d'un λ, ou d'un signe, est **totale** si I^λ = I ≠ ∅, **partielle** si ∅ ≠ I^λ ⊊ I, **nulle** si
  I^λ = ∅.
- Elle se décrit par un recouvrement minimal de I^λ par des cylindres h_1 ∨ … ∨ h_k, les plus préférés d'abord (§ 4.4).
- Une conclusion d'un signe est de plus **uniforme** si les substitutions de ses classes sont la même au sens des
  mentions (∃σ∀i), et **par cas** sinon (∀i∃σ_i).

**Définition 8 (la certification par classe).** Une classe c est **certifiée positivement** si une preuve acceptée par le
vérificateur établit Q sous chaque i ∈ [c] (une preuve par cas peut couvrir plusieurs classes, § 5.5) ; **négativement**
si une réfutation acceptée le fait. Un statut synthétique est certifié si chaque classe qu'il cite l'est, avec un
recouvrement complet de son domaine et, pour une affirmation partielle, un témoin d'admissibilité (§ 3.7, (a) et (e)).
Les classes B, NC, N et ? ne sont certifiées d'aucun signe.

**Définition 9 (l'ordre des profils).** Soient Π et Π' deux profils sur un même I, à la correspondance des points près.
Π ≤⁺ Π' si chaque affirmation positive de Π (définition 3), dérivée ou certifiée, est impliquée par une affirmation de
même force de Π' : la même i, une substitution la même au sens des mentions, des hypothèses H' ⊆ H, de mêmes natures.
≤⁻ se définit de même. **Π ≤ Π'** si Π ≤⁺ Π' et Π ≤⁻ Π'. C'est l'ordre exact de l'information. Les mesures de sûreté
(définition 12) se lisent sur lui.

**Définition 10 (le statut synthétique).** Syn(Π) est donné par la table suivante. Les lignes 2 à 12 supposent I ≠ ∅ :
sans cela, « I^E = I » serait vrai par vacuité. Ainsi, les lignes s'excluent deux à deux et couvrent tous les profils :
l'ordre des lignes ne compte pas.

| | condition sur le profil | Syn(Π) | ce que le résultat cite |
|---|---|---|---|
| 1 | I = ∅ | `aucune_interpretation` | les contraintes qui vident I ; aucune preuve |
| 2 | I ≠ ∅, I^? ≠ ∅ | `incomplet` | les classes calculées, chacune avec son statut local |
| 3 | I^? = ∅, I⁺ ≠ ∅, I⁻ ≠ ∅ | `divergent` | les deux recouvrements, les deux familles de preuves, chacune avec ses conditions |
| 4 | I^E = I | `etablie` | une preuve par cas sur I |
| 5 | I⁺ = I, I^{E_H} ≠ ∅ | `etablie_sous_hypotheses`, couverture totale | la preuve par cas ; les hypothèses non lexicales de chaque classe, par nature |
| 6 | I^? = ∅, ∅ ≠ I⁺ ⊊ I, I⁻ = ∅ | `etablie_sous_hypotheses`, couverture h | la preuve sous h (et, s'il y en a, ses hypothèses non lexicales) ; les autres classes et leurs statuts |
| 7 | I^R = I | `ecartee` | une réfutation par cas sur I |
| 8 | I⁻ = I, I^{R_H} ≠ ∅ | `ecartee_sous_hypotheses`, couverture totale | la réfutation par cas ; les hypothèses non lexicales, par nature |
| 9 | I^? = ∅, ∅ ≠ I⁻ ⊊ I, I⁺ = ∅ | `ecartee_sous_hypotheses`, couverture h | la réfutation sous h ; les autres classes et leurs statuts |
| 10 | I^? = I⁺ = I⁻ = ∅, I^B ≠ ∅ | `contradictoire` | les classes B, chacune interne ou documentaire (NOYAU § 4.3), et leur couverture |
| 11 | I^? = I⁺ = I⁻ = I^B = ∅, I^{NC} ≠ ∅ | `non_certifiee` | les classes NC, leurs énonciateurs, leur signe |
| 12 | I^N = I | `inconnue` | le partiel de chaque classe ; jamais une preuve |

**Les attributs.** Syn rend un nom et des attributs : la couverture de chaque signe (I, ou les cylindres) ; les
hypothèses non lexicales, par classe et par nature ; l'uniformité des substitutions ; le chemin et la situation de
chaque classe. Le nom `etablie_sous_hypotheses` couvre deux choses que ses attributs séparent : une couverture partielle
par des choix de lecture (ligne 6), une couverture totale sous des hypothèses d'une autre nature (ligne 5). Les deux
peuvent se cumuler (une classe de la ligne 6 peut demander une abduction). De même pour `ecartee_sous_hypotheses`.

**Pourquoi ces noms.** Ce sont ceux du guide d'annotation, plus `incomplet`, dont le guide n'a pas besoin. Un nom
`contradictoire_sous_hypotheses` n'est pas proposé : une classe B n'est certifiée d'aucun signe, et l'attribut de
couverture suffit à dire où elle vaut. `divergent` nomme une robustesse, non une valeur : c'est voulu, puisque la
divergence n'est pas une valeur de Belnap.

**Proposition 3 (aucune priorité de signe).** Soit Π̄ le profil dual : on échange V et F dans chaque valeur, D⁺ et D⁻,
E et R, E_H et R_H, et le signe de chaque NC ; B, N et ? restent. Alors Syn(Π̄) est le dual de Syn(Π) : `etablie` et
`ecartee` s'échangent, de même que `etablie_sous_hypotheses` et `ecartee_sous_hypotheses` ; les autres noms sont fixes.
**Pourquoi :** les lignes 4 et 7, 5 et 8, 6 et 9 s'échangent ; les lignes 1, 2, 3, 10, 11 et 12 sont invariantes. C'est
une propriété testable (§ 9.6, T7).

**Les deux préséances qui restent, et pourquoi ce ne sont pas des priorités de signe.**
- **Ligne 2 :** un calcul incomplet ne conclut pas (NOYAU, D32). La classe non calculée pourrait avoir tout statut. Une
  classe où une solution certifiable a été trouvée avant l'interruption est E, non ? (NOYAU § 4.5) ; de même une classe
  où une réfutation certifiable et l'absence de tout appui positif ont été établies.
- **Lignes 6, 9, 10 et 11 :** une classe certifiée d'un signe nomme le statut avant une classe B, NC ou N. C'est une
  préséance de la certification sur son absence, la même pour les deux signes. Les classes B restent dans le profil, et
  leur couverture dans les attributs.

**Définition 11 (l'ordre des statuts synthétiques).** Chaque statut a deux coordonnées : ce qu'il **garantit** sur l'axe
positif (ℓ⁺) et sur l'axe négatif (ℓ⁻). Les niveaux : 0, rien ; 1, une dérivation sans certification ; 2, une
certification sur une partie de I, ou sous des hypothèses non lexicales ; 3, une certification sur tout I, sans
hypothèse.

| statut | ℓ⁺ | ℓ⁻ |
|---|---|---|
| `etablie` | 3 | 0 |
| `etablie_sous_hypotheses` | 2 | 0 |
| `ecartee` | 0 | 3 |
| `ecartee_sous_hypotheses` | 0 | 2 |
| `divergent` | 2 | 2 |
| `contradictoire` | 1 | 1 |
| `non_certifiee`, signe + / signe − / les deux | 1 / 0 / 1 | 0 / 1 / 1 |
| `inconnue`, `incomplet`, `aucune_interpretation` | 0 | 0 |

**S ≤ S'** si ℓ⁺(S) ≤ ℓ⁺(S') et ℓ⁻(S) ≤ ℓ⁻(S'). C'est un ordre partiel sur les couples ; sur les noms, un préordre, où
les trois derniers sont équivalents en affirmation et distincts en diagnostic. Ses relations de couverture :
`etablie` > `etablie_sous_hypotheses` > `non_certifiee`(+) > `inconnue` ; `ecartee` > `ecartee_sous_hypotheses` >
`non_certifiee`(−) > `inconnue` ; `divergent` > `etablie_sous_hypotheses`, `ecartee_sous_hypotheses`, `contradictoire` ;
`contradictoire` > `non_certifiee`(+), `non_certifiee`(−). `etablie` et `divergent` sont incomparables, comme `etablie`
et `ecartee`.

**Trois lectures de cet ordre.**
- **`aucune_interpretation` est en (0, 0),** non en (3, 3). « Pour toute i ∈ ∅ » est vrai par vacuité ; ce n'est jamais
  une certification (§ 3.7 (a)).
- **Syn n'est pas monotone pour ≤.** Le profil {B, N} donne `contradictoire`, (1, 1). Le profil {B, V}, plus informé,
  donne `etablie_sous_hypotheses`, (2, 0) : la coordonnée négative du nom baisse, la classe B reste dans le profil.
  C'est pourquoi la sûreté se mesure sur les profils (définitions 9 et 12), jamais sur les seuls noms.
- **La sûreté en noms** n'est qu'un résumé : un niveau mesuré dont le nom a ℓ⁺ ≥ 2 affirme des dérivations positives
  dans les classes citées ; la proposition 1 dit quand elles valent en référence. De même pour ℓ⁻ et la proposition 2.

**Les remarques de la version 1, gardées.**
- **La valeur par interprétation reste celle de Belnap.** La supervaluation ne mêle pas B et N : B est un excès
  d'information sous i ; la robustesse aux interprétations est une seconde dimension (ÉdA § 9.4).
- **∀i∃σ contre ∃σ∀i** (validé par la propriétaire). Le noyau 0.3 certifie une solution dont les liens lexicaux valent pour tous les sens : il existe
  σ telle que, pour toute i, σ est une solution sous i. La supervaluation demande que, pour toute i, il existe σ_i. La
  première forme implique la seconde : c'est une **approximation sûre**. Elles diffèrent quand les interprétations
  donnent des solutions différentes : rq-010 (la lecture collective a un couronnement, la distributive en a deux),
  co-018#4 (deux branches). Il faut donc une **preuve par cas** (§ 9.7). Elle vaut pour les deux signes : une
  réfutation par cas (∀i∃σ_i, σ_i réfutée sous i) est plus faible qu'une réfutation uniforme, et le résultat dit
  laquelle il a (définition 7 ; § 3.7 (d)).
- **Une hypothèse de lecture n'est pas une abduction** (SPEC § 4) : c'est la règle de conservation de la définition 4.

### 3.6 Le calcul

- **La localité.** Un atome ne dépend que des points de ses appuis et de son type. Le produit ne se prend que sur les
  points des atomes d'une sélection, **fermés par les contraintes** : tout point relié à eux par une contrainte dure, de
  proche en proche, en fait partie (§ 3.7 (e)). De deux à six points dans les cas du banc.
- **Le filtrage.** Tout filtrage qui ne retire que des valeurs sans extension admissible donne un sur-ensemble de I_K.
  Il est sûr pour les affirmations **universelles** (« pour toute i ») : elles valent alors a fortiori sur I_K. Il ne
  l'est pas pour les affirmations **existentielles** (« sous h », une classe d'un profil divergent) : une classe du
  sur-ensemble peut être vide. Celles-ci demandent un témoin (§ 3.7 (e)). La consistance d'arc (Mackworth 1977 [non
  vérifiée]) est un tel filtrage. L'oracle énumère exactement ; le moteur peut filtrer.
- **Le coût.** Décider I⁺ = I est une quantification universelle sur les solutions d'un problème de contraintes, coûteuse
  en général. La localité la borne en pratique. Un budget épuisé donne, classe par classe, la règle du § 3.7 (f).
- **L'indexation préserve l'exhaustivité** (FS § 6). L'index retient N si une interprétation admissible peut l'établir,
  même sous hypothèse : il prend l'union des valeurs admissibles, jamais la seule valeur préférée. Une notation n'est
  écartée de l'examen que si une condition nécessaire établie est sans appui positif dans **toute** interprétation
  admissible, **et que I n'est pas vide** : sur I = ∅, rien n'est écarté par vacuité (§ 3.7 (a)). Une réfutation, même
  certaine, ne retire pas une notation de l'index : elle se rapporte (option B), elle ne filtre pas.

### 3.7 Six situations limites de la supervaluation (nouveau en 1.1)

Chacune reçoit une règle et un exemple. Les exemples sont des cas cités dans ce document ; une variante construite est
dite telle. Aucun statut du banc n'est recompté.

**(a) L'ensemble vide d'interprétations.**
- **Règle a1.** Si I = ∅, Syn = `aucune_interpretation`. Aucune preuve, aucune réfutation, aucune notation certifiée, ni
  écartée de l'index. Le résultat cite les contraintes qui vident I.
- **Règle a2.** Une affirmation sous h exige [h] ≠ ∅, démontré par un **témoin** : une interprétation de [h] qui
  satisfait toutes les contraintes dures de la composante de h (e).
- **Règle a3.** En (b), I_K = ∅ avec I(D, Δ, C) ≠ ∅ réfute (K2) : une contrainte de K exclut une lecture de référence.
  C'est un test de K, non un statut.
- **Exemple.** La personnification du § 4.5 (famille `nr-`) : une restriction de sélection « l'agent est animé »,
  appliquée hors de son domaine de validité, exclut tous les sens de « la Mort » qui tend un sablier. I_K = ∅ : le
  système rend `aucune_interpretation`, jamais `etablie` par vacuité, et le banc y lit une exclusion fausse.
- **Remarque.** Deux constatations contraires du texte (« la même femme », « une autre femme », des mêmes figures) ne
  doivent pas vider I : une contradiction dite est une valeur B (§ 4.2), non une exclusion. Le lecteur les représente
  comme deux assertions, non comme deux contraintes.

**(b) Une conclusion qui exige déjà une hypothèse autre qu'un choix de lecture.**
- **Règle b1.** Sous i, le noyau peut rendre E_H ou R_H : la conclusion demande une hypothèse non lexicale (identité,
  abduction, connaissance typique, convention). La classe porte cette hypothèse avec sa nature (définition 4).
- **Règle b2.** L'agrégation ne fond pas cette hypothèse dans le choix de lecture : le résultat cite des couples
  (h_j, H_j), « dans les lectures h_j, sous les hypothèses H_j ». La conclusion est vraie si la lecture vraie est dans
  un h_j et que son H_j est vrai.
- **Règle b3.** Une couverture totale sous des H_j non vides est `etablie_sous_hypotheses` (ligne 5), jamais `etablie`.
- **Exemple.** pi-003. Les classes où les sens des mots français atteignent Δ ont `etablie` sous l'hypothèse
  (`identite`, « Martin de la première scène = Martin du rêve »). Le résultat cite
  ([lecture(sens) : les sens qui atteignent Δ], [identite : Martin]). Une sortie qui écrirait « sous hypothèses [sens,
  identité] » sans les natures perdrait l'information (mesure n_perdue).

**(c) Les profils mêlés : établissement, réfutation, contradiction, indétermination.**
- **Règle c1.** La table de la définition 10 s'applique telle quelle. V et F ensemble donnent `divergent`. Un signe et
  des classes B, NC ou N donnent le statut sous hypothèses de ce signe, les autres classes rapportées.
- **Règle c2.** Une classe B se distingue d'un profil divergent : B est une contradiction **dans** une lecture (deux
  appuis contraires sous la même i), la divergence est un désaccord **entre** lectures.
- **Exemple 1, mn-004** (sous la convention de l'œuvre actuelle). Neuf couples de sens ; les trois couples diagonaux
  sont F, les six autres N. Syn = `ecartee_sous_hypotheses`, couverture [angels (D) = angels (Δ)], le cylindre préféré
  d'abord (09538915 des deux côtés). Les six classes N sont rapportées.
- **Exemple 2, co-015.** *mother-in-law* donne V, *stepmother* N : `etablie_sous_hypotheses`, couverture
  [belle-mère ↦ *mother-in-law*], une hypothèse « non préférée » (§ 4.4).
- **Exemple 3, ep-009** (lecture d'analyse, D et Δ schématisés ; le cas n'est pas recompté). Δ : « saint Jean à la
  droite de la Vierge ». D : « à droite, saint Jean », avec un point de cadre de référence. Lecture intrinsèque : V. Lecture du spectateur, la
  Vierge étant dite de face : saint Jean est à la gauche de la Vierge ; avec l'incompatibilité attestée d'une relation
  d'ordre et de son inverse (décision 9), F. Syn = `divergent` : la lecture intrinsèque établit, celle du spectateur
  écarte, et le résultat garde les deux preuves. La convention « à droite = droite du spectateur dans une notice »,
  non attestée, n'est qu'une préférence (§ 4.3) : elle ordonne les deux, elle n'en retire aucune.
- **Exemple 4, la variante de sa-022** (§ 2.8). Une seule lecture, B : `contradictoire`, interne.

**(d) Des conclusions certaines dont les substitutions diffèrent selon les interprétations.**
- **Règle d1.** `etablie` demande une solution certifiée dans chaque classe (∀i∃σ_i), non la même (∃σ∀i). Le résultat
  rend la famille (i ↦ σ_i), écrite sur les mentions, et dit si elle est uniforme (définition 7).
- **Règle d2.** Il en va de même du négatif. Une réfutation est relative à ses référents (NOYAU § 4.4) : si σ_i varie,
  ce qui est réfuté dépend de la lecture. Le résultat dit « dans la lecture h_j, Q est réfutée pour σ_j ». Il ne dit
  jamais « Q est réfutée pour σ_1 » sans condition, sauf si σ_1 est réfutée dans toutes les classes.
- **Règle d3.** Une substitution se compare d'une lecture à l'autre par ses mentions, puisque les classes de
  coréférence varient avec les points de coréférence.
- **Exemple 1, rq-010.** « Two angels crown her » : la lecture collective a un couronnement, la distributive en a deux.
  Une définition qui demande un ange qui la couronne est `etablie` par cas : un événement dans la première lecture,
  l'un des deux dans la seconde. La famille n'est pas uniforme ; l'ancien ∃σ∀i ne l'établissait pas.
- **Exemple 2, co-018#4.** « Either a monk or a nun » : chaque branche a sa solution, et une définition que les deux
  branches satisfont est `etablie` par cas. Les branches sont des cas de la preuve, non des choix (§ 3.4).
- **Exemple 3, rq-002** (variante construite). « Il élève le calice » : si deux antécédents restaient après l'accord,
  une réfutation pour l'un ne vaudrait que dans la lecture où « il » est celui-là.

**(e) Les contraintes conjointes dont les effets ne se déterminent pas localement.**
- **Règle e1.** Le domaine du calcul est la **composante** des points d'une sélection dans l'hypergraphe des
  contraintes dures (deux points sont voisins si une contrainte les touche tous deux). L'exclusion d'une valeur se juge
  sur la composante entière, non sur le seul point.
- **Règle e2.** Les affirmations universelles peuvent se calculer sur un sur-ensemble filtré (§ 3.6). Les affirmations
  existentielles (une classe non vide, [h] ≠ ∅) demandent un témoin sur la composante entière : une affectation de tous
  ses points qui satisfait toutes ses contraintes. Le vérificateur le contrôle en temps linéaire.
- **Règle e3.** Une classe dont l'admissibilité n'est pas décidée rend le calcul incomplet, sauf si le statut
  synthétique et les couvertures citées sont les mêmes qu'elle soit vide ou non. On calcule les deux.
- **Règle e4.** L'indépendance de D et de Δ (§ 3.4) reste : les composantes ne traversent jamais d'un côté à l'autre.
- **Exemple, ee-002.** La restriction « l'agent d'un transfert est animé » ne vaut que pour le sens de transfert de
  « donner ». Le cadre « donner X à Y » exclut « donner sur ». L'exclusion de la pièce d'échecs pour « cavalier » dépend
  donc du point de « donner » : elle se juge sur la composante {donner, cavalier}. Vu seul, le point « cavalier » garde
  la pièce d'échecs ; c'est sûr pour « établie dans toute lecture », pas pour « écartée sous h » si h choisit la pièce.

**(f) Les interruptions et les calculs incomplets.**
- **Règle f1.** Une classe dont le calcul est interrompu est ?, sauf si une solution certifiable y a été trouvée (elle
  est E ou E_H, NOYAU § 4.5), ou une réfutation certifiable avec l'absence établie de tout appui positif (R ou R_H).
- **Règle f2.** Une classe non atteinte par l'énumération est ?.
- **Règle f3.** Si une classe est ?, Syn = `incomplet` (ligne 2). Le profil garde les classes calculées, chacune avec son
  statut local et sa preuve. Aucune affirmation sur I entier, ni « sous h » dans le sens de « pas ailleurs », n'en est
  tirée (D32).
- **Règle f4.** Une erreur interne est une erreur, jamais un ? (NOYAU § 4.5).
- **Exemple, rq-010.** Si le budget s'épuise après la lecture collective, établie, et avant la distributive, le profil
  porte {collective : E ; distributive : ?} et Syn = `incomplet`, non `etablie_sous_hypotheses` [collective].

## 4. Exclusions et préférences

### 4.1 Deux choses différentes

- **Une exclusion** retire des interprétations de I. Elle suit de contraintes dures. Chacune est citée dans la preuve,
  avec sa source. Elle peut changer le statut : établir, réfuter.
- **Une préférence** est un ordre partiel ≼ sur les valeurs ou les interprétations. Elle ne retire rien de I. Elle
  ordonne les hypothèses, l'ordre d'examen, les notations rendues. Elle n'établit rien, ne réfute rien, et ne retire rien
  de l'index.

### 4.2 Ce qui est une exclusion démontrée

1. **Une restriction de sélection attestée,** avec l'incompatibilité attestée des types (la pièce d'échecs, ee-002).
2. **Une contrainte du texte :** la catégorie, les marques syntaxiques, le cadre de sous-catégorisation, l'accord, un
   marqueur de contexte, une identité ou une distinction dite.
3. **Une connaissance documentaire :** une distinction documentaire (St John l'Évangéliste et St John le Baptiste).
4. **Côté Δ :** la place de la notation, quand K atteste le sens qu'elle impose (§ 5.1).

**Une incompatibilité entre deux états dits n'exclut pas une lecture.** Si une lecture rend le texte contradictoire,
l'exclure cacherait une contradiction, une valeur B. Elle donne un appui négatif (§ 6). L'incompatibilité de types
n'exclut qu'à l'intérieur d'une restriction de sélection : la lecture y est mal formée, non contradictoire.

### 4.3 Ce qui n'en est pas une

- **La fréquence et le premier sens.** L'ordre de WordNet vient de comptes d'annotation. Le premier sens de « cloak » ou
  de « crown » n'est pas celui d'une scène.
- **Un modèle statistique de désambiguïsation,** neuronal ou non (FS § 6).
- **L'association sélectionnelle** (Resnik [non vérifiée]) : une préférence mesurée, non une restriction.
- **« Un sens par discours »** (Gale, Church et Yarowsky [non vérifiée]) et **« même lemme, même sens ».**
- **La cohérence du domaine** (le contexte religieux de mn-004) et **la cohérence du discours** (« not dead: his eyes
  are open » est une explication, au sens de la SDRT ; Asher et Lascarides 2003).
- **Une norme grammaticale souvent violée :** « le participe détaché se rapporte au sujet » (sa-010).
- **Une convention de genre non attestée :** « à droite » est la droite du spectateur dans une notice (ep-009). Une
  convention écrite dans un guide de catalogage nommé serait une contrainte (proposition).
- **La typicité :** les « possible attributes » d'Iconclass.

### 4.4 Ce que fait une préférence

- **Elle ordonne les hypothèses.** La première hypothèse citée est la plus préférée. Les concurrentes sont rapportées.
- **Un exemple, co-015.** « Une belle-mère tend une pomme à la fillette de son époux », contre « mother holding out an
  apple to a little girl ». « Belle-mère » a deux sens dans WOLF : *mother-in-law* (inclus dans *mother*) et
  *stepmother* (qui ne l'est pas). « La fillette de son époux » préfère *stepmother* ; rien ne rend *mother-in-law* mal
  formé. Le statut (b) est donc `etablie_sous_hypotheses` [belle-mère ↦ *mother-in-law*], hypothèse marquée « non
  préférée ».
  - La préférence ne peut pas non plus abaisser ce statut à `inconnue` : ce serait en faire une exclusion.
  - Si le jugement de référence n'admet que *stepmother*, S_a = `inconnue`, et l'hypothèse de (b) est vide en (a). C'est
    un écart de K, qui n'a pas l'exclusion, non une erreur de sûreté (§ 2.6) : la mesure h_vacante (§ 2.8).
- **Elle ne change pas les coûts de l'abduction,** fixés à l'avance par sorte (SPEC § 4) (proposition).

### 4.5 Les restrictions de sélection et la figuration

- **Une personnification, une allégorie, une statue qui s'anime, un rêve** font d'un concept ou d'un objet un agent. Une
  restriction de sélection y est violée, et la lecture n'est pas mal formée : c'est une coercition (Pustejovsky 1995).
- **Proposition :** une restriction porte son domaine de validité, le contexte littéral du monde figuré. Hors de ce
  domaine (une personnification dite, un contexte de vision), elle n'est qu'une préférence.
- **Le risque :** les restrictions de sélection seront la première source d'exclusions, et une exclusion fausse est une
  perte de sûreté. La famille `nr-` est leur banc de contre-exemples.

## 5. Les types des définitions

### 5.1 La définition est un texte comme un autre

- **Le libellé a ses points** (P_Δ) : sens, relations, structure, lecture d'un pluriel, cadre, ancrage, forme du libellé.
  Il a son contexte C_Δ.
- **Une requête porte sur un concept, un sens ou un ensemble de sens explicitement admissibles :** `type(X, q)`, où q
  est un point de Δ et V_I(q) son domaine après les exclusions. « Explicitement » veut dire : chaque exclusion est citée,
  avec sa source.
- **Les sources des contraintes de Δ** sont celles de D (structure, sélection, accord), plus C_Δ : la place de la
  notation (ses ancêtres), ses clés, et une **annotation validée des sens des libellés**. Cette annotation est une
  ressource de K, faite une fois par concept dans la base de définitions conceptuelles (FS § 2.7) (proposition).

### 5.2 L'identité du lemme n'est pas l'identité du concept

- **Deux exemples :** « horseman », l'écuyer et l'éleveur (ee-002) ; « dead », dix-sept sens des deux côtés (ee-003).
- **Le pas de lexicalisation** (d'un sens vers son lemme, un pas de `sous`) ne sert plus à atteindre un type de requête.
  Une requête typée par des sens s'atteint par la seule inclusion. Le lien positif et le lien négatif deviennent
  symétriques : tous deux par `inclus`.
- **D20** (un mot sans concept est son propre sens) : proposition, la valeur ⊥, sauf une équivalence écrite dans K.
  Sinon, un même mot inconnu des deux côtés serait encore une identité de lemme.
- **Les noms propres :** une même clé n'est pas un même individu (« St John », pi-014). Un nom est un point d'identité,
  de domaine les individus documentés qui portent cette forme. Les alias sont dans K (décision 5).

### 5.3 D30, réécrit

**Les notations.** Un atome α = `type(X, q)` ; σ(X) une classe c ; un appui a, une assertion sur un membre de c, de mot w
à l'occurrence o, de point p_o. On note ⊑ la clôture réflexive et transitive de `inclus` (hyperonymie, instance).

**Les appuis, sous une interprétation i.**
- **Un appui positif** de α sous i : a est positive et admissible (NOYAU § 1), et i(p_o) ⊑ i(q).
- **Un appui négatif** de α sous i : a est négative, sous les conditions de NOYAU § 1.1, et i(q) ⊑ i(p_o) ; ou une
  incompatibilité attestée et indexée (§ 6).
- Il en va de même pour `propriete`, `evenement` et `relation`, les relations prenant leurs points dans la table de la
  décision 35.

**La règle.**
- **α est établi sans hypothèse** si, dans toute interprétation admissible (de ses points, conjointement avec ceux des
  autres atomes de la sélection), il a un appui positif et aucun appui négatif. La preuve couvre I.
- **α est établi sous h** s'il l'est dans toute interprétation de [h].
- **Une négation est certaine** si elle est un appui négatif dans toute interprétation admissible. Si elle ne l'est que
  dans une partie, elle fait des classes F (ou B, si un appui positif y vaut aussi) dans le profil. Le statut
  synthétique en suit la table du § 3.5 : une réfutation sous h, ou un profil divergent, ou une conclusion positive sous
  h dont les classes B sont rapportées (révisé en 1.1, option B).
- **Une négation seulement possible ne se change plus en hypothèse positive par défaut.** NOYAU 0.3 établit sous
  `negation_autre_sens` une conclusion que touche une négation possible : c'était une priorité du positif. Sous la
  supervaluation, la classe où la négation vise le sens demandé est F ou B, celle où elle en vise un autre est V, et la
  table décide. `negation_autre_sens` reste l'abréviation d'un choix, de nature `lecture(sens)` (§ 5.4).

**La comparaison.**

| règle | lien positif certain | négation certaine |
|---|---|---|
| D30 actuel (NOYAU § 2) | pour tout s_D ∈ V(p_o), il existe s ∈ sens(L) tel que s_D ⊑ s (puis la lexicalisation vers L) | pour tout s_D ∈ V(p_o) et tout s ∈ sens(L) : s ⊑ s_D |
| symétrique, sans contrainte | pour tout s_D ∈ V(p_o) et tout s_Δ ∈ V(q) : s_D ⊑ s_Δ | la même |
| symétrique, avec contraintes | pour tout (s_D, s_Δ) admissible sur {p_o, q} : s_D ⊑ s_Δ | pour tout (s_D, s_Δ) admissible : s_Δ ⊑ s_D |

**D30 actuel est le cas particulier « aucune contrainte, toutes les combinaisons admissibles »** du côté de la
description, avec le mot L de la définition lu comme **l'union des sens de son lemme** : un lemme y est satisfait par
l'un quelconque de ses sens. La décision 3 retire cette lecture par défaut ; le mot de la définition devient un point.
- **La négation** ne change pas : la règle actuelle quantifie déjà sur tous les sens du type demandé.
- **Le lien positif** passe de « pour tout, il existe » à « pour tout, pour tout ». Sans contrainte, il est plus strict.
- **Le prix,** dit : les `etablie` du banc qui reposent sur le même lemme (jusqu'à 177, décision 2) deviennent, en (b),
  `etablie_sous_hypotheses`, tant que Δ n'a pas de contrainte. Le remède est le typage attesté de Δ (§ 5.1), non le
  retour au lemme.

### 5.4 Les hypothèses conjointes

- **Une interprétation est une fonction :** une valeur par point. La règle du lot 4 (« une occurrence n'a qu'un sens à
  la fois ») est cette propriété, pour les points lexicaux de D. Elle s'étend à toutes les dimensions, aux points de Δ,
  et à toute la preuve : dérivations et abductions comprises (SPEC § 4 : « deux hypothèses qui demandent deux sens d'une
  même occurrence : jamais dans la même explication »).
- **Les trois sortes d'hypothèses du noyau, et leur nature** (révisé en 1.1, définition 4) :
  - `sens_suppose(Occ, Mot, Type)` = `choix(p_o, { s : s ⊑ Type })`, de nature `lecture(sens)` ;
  - `negation_autre_sens(Atome)` = `choix(p_o', { s : i(q) ⋢ s })`, pour l'occurrence niée o', de nature
    `lecture(sens)` ;
  - `distinction_supposee(X, Y, …)` : de nature **`identite`**, non `lecture`. Le texte ne laisse pas l'identité ouverte
    comme une lecture ; une préférence (des noms différents) la suppose. La version 1 l'écrivait comme un choix ; elle
    peut garder cette forme dans la preuve, mais sa nature reste `identite`, et elle ne se fond jamais dans la classe
    d'interprétations.
  Les anciens termes peuvent rester comme abréviations, pour le vérificateur (proposition).
- **Une hypothèse conjointe est admissible si [h] ≠ ∅,** au regard de toutes les contraintes dures de la composante de
  ses points (§ 3.7 (e)). Le vérificateur le contrôle sur un témoin, une affectation de la composante.
- **« Aucune lecture »** (NOYAU § 2, B3) : l'ensemble des interprétations où l'appui est positif et non nié est vide.
- **Les interprétations concurrentes** sont gardées, comme les explications concurrentes de l'abduction.

### 5.5 Ce que cite une preuve

- **les points employés :** côté, dimension, ancre ; leur domaine V_K(p), avec la version de K ;
- **pour chaque valeur exclue :** la contrainte, sa source, son attestation, et les prémisses du graphe qui la rendent
  applicable ;
- **le signe :** une preuve établit, une réfutation écarte. Les deux ont la même forme (révisé en 1.1) ;
- **les cas :** un recouvrement de son domaine (I, ou [h]) par des cylindres h_1, …, h_k (toute combinaison des valeurs
  des points de la composante est dans un h_j, ou viole une contrainte citée), et pour chaque cas une solution, ou une
  réfutation (σ_j sur les mentions, et les justifications de NOYAU § 5) ;
- **pour chaque cas, ses hypothèses non lexicales,** chacune avec sa nature (définition 4) ;
- **le choix h,** pour une conclusion sous hypothèses de lecture, et **un témoin** de [h] ≠ ∅ (§ 3.7 (a)) ;
- **jamais une preuve sur un domaine vide :** un recouvrement de ∅ n'est pas une preuve ;
- **jamais une préférence** comme fondement. Elle peut figurer comme information, hors de la preuve.

**Une forme (proposition) :** `preuve(Id, Versions, Regime, Signe, Interpretation, Domaine, Cas, Temoins)`, où
`Signe` est `etablit` ou `ecarte`, `Interpretation = [point(P, Domaine_P, Exclusions)]`, `Domaine` est `tout` ou le
choix h, `Cas = [cas(H_j, Sigma_j, Justifications_j, Hypotheses_j)]`, `Hypotheses_j = [hyp(Nature, Contenu)]`, et
`Temoins` une affectation par composante. Une preuve du noyau 0.3 en est le cas d'un seul cas, de signe `etablit`. Un
profil divergent a deux preuves, une de chaque signe, et le résultat les rend toutes deux.

## 6. Incompatibilité et négation

### 6.1 Trois relations distinctes

| relation | ce qu'elle dit | ce qu'elle permet | exemples |
|---|---|---|---|
| **incompatibilité logique ou analytique** | pour tout porteur x, moment t, contexte π : A(x, t, π) entraîne ¬B(x, t, π), pour des sens donnés | un appui négatif, si elle est attestée | mort et vivant ; éveillé et endormi (sa-022) ; debout et assis ; un ordre strict et son inverse (décision 9) |
| **antonymie lexicale** | une relation entre des mots dans des sens (le pointeur « ! » de WordNet : *dead* ! *alive*) ; contraire, contradictoire ou de degré | une ressource pour proposer une incompatibilité, jamais une attestation à elle seule | *young* / *old*, relatifs à une classe de comparaison (nr-018, décision 30) ; *crowned* / *uncrowned* |
| **opposition typique** | A et B vont rarement ensemble | l'abduction seulement (une concurrente, un coût) ; jamais un appui négatif | mort et yeux ouverts (ee-003) ; nu et en armure |

**Les sortes d'incompatibilité :** les **contraires** (debout, assis, couché : deux peuvent être faux), les
**contradictoires relatifs à une présupposition** (mort et vivant, pour un être qui vit ou a vécu), les **types
disjoints** (artefact et animé, qu'emploient les restrictions de sélection).

### 6.2 L'indexation

**L'entrée de K :** `incompatible(A, B, Indexation, Source, Attestation)`, où A et B sont typés par des sens.
L'indexation dit ce qui doit être partagé : le porteur, le moment, le contexte, et pour les adjectifs de degré la classe
de comparaison.

**La règle.** Soit A une prémisse positive, portée par x, de chemin π, dans la situation s, d'ancrage τ par rapport au
moment de s. Soit B demandé de y, dans π', s', τ'. A donne un appui négatif de B(y) si et seulement si :
- `incompatible(A, B)` est attestée ;
- y est dans la classe de x (la même figure, non le même individu : § 7.4) ;
- π = π', s = s', τ = τ'.

**Les exemples.**
- **ee-002, la variante de temps :** « vêtu » tient maintenant ; « nu » est demandé au moment du don, antérieur. Aucun
  appui négatif.
- **ee-003, la variante de la chronique :** la mort est dans le contexte d'une source, et plus tard. Aucun.
- **sa-022 :** « Il est éveillé » et « Jacob asleep » : le même Jacob, la même situation, le même moment. Un appui
  négatif, si l'incompatibilité est attestée.
- **pi-003 :** saint Martin à cheval dans la première scène, endormi dans la seconde. Deux figures, deux situations :
  aucun conflit.

**L'ancrage (décision 26) est une incompatibilité du langage.** Une éventualité n'a qu'un ancrage par rapport au moment
d'une situation. Un ancrage dit « imminent » ou « antérieur » est donc un appui négatif de « en cours » pour la même
éventualité dans la même situation. Ce n'est pas une connaissance de K.

### 6.3 Ce qui donne un appui négatif, et seulement cela

1. une assertion niée de l'auteur (NOYAU § 1.1), sous l'interprétation ;
2. une assertion positive A et une incompatibilité attestée et indexée : la contraposition de A ⇒ ¬B ;
3. une quantification énoncée (§ 6.4) ;
4. une contrainte du texte (une distinction dite, un nombre) ou une distinction documentaire (NOYAU § 4.1) ;
5. une condition nécessaire établie dont la négation est appuyée, par contraposition à l'évaluation (SPEC § 3,
   décision 8).

Chacun vaut sous une interprétation ; il est certain s'il vaut dans toutes ; s'il ne vaut que dans une partie, il fait
des classes F ou B du profil, et la table du § 3.5 en tire le statut, sans priorité d'un signe (révisé en 1.1). Il ne
vaut que pour ses référents (NOYAU § 4.4), qui peuvent varier avec la lecture (§ 3.7 (d)). **Ne donnent jamais d'appui
négatif :** le
silence, une opposition typique, une antonymie seule, une implication du texte qui n'est pas une connaissance attestée
(décision 10), une préférence.

### 6.4 La négation propositionnelle et la quantification explicite

**Une négation porte sur une proposition.** ¬φ, où φ est une description avec ses variables locales, existentielles à
l'intérieur.
- « L'Enfant ne porte aucune auréole » : ¬∃h (auréole(h) ∧ porte(enfant, h)) (mn-016).
- « Pas de lion mort » : ¬∃x (lion(x) ∧ mort(x)). Elle ne nie pas « lion » : c'est NOYAU § 1.1.

**La réfutation d'une sélection (proposition ; elle lève D41).** Une proposition niée ¬φ de l'auteur réfute une
sélection S de la requête sous σ si S, sous σ et sous l'interprétation, implique φ : un homomorphisme de φ dans S, au
sens du comparateur d'inclusion (NOYAU § 8). La réfutation porte sur la conjonction entière, non sur chaque atome. Elle
est sûre : la vérité de S entraîne φ.

**`non/1` dans les requêtes.** `non(φ)` est vrai sous σ et i si l'auteur nie une proposition ψ telle que φ implique ψ :
« pas d'auréole » appuie « pas d'auréole d'or », non l'inverse. Une variable qui n'apparaît que sous `non` y est
existentielle à l'intérieur (décision 11).

**Les quantifications énoncées** sont des assertions : `quant(Q, x, Restriction, Portee, Domaine)`, avec Q parmi
« aucun », « tous », « seul », « exactement n », « au moins n », « tous sauf E », et Domaine une situation dans un
chemin, ou une collection (FS § 2.6, S5).
- **« aucun » :** ¬∃x ∈ Dom R(x). Un appui négatif de `type(X, R)` pour tout référent de Dom, cité ou non, et rien hors
  de Dom. Dans mn-004, Dom est la composition ; « aucun ange au registre inférieur » ne réfuterait pas un ange en haut.
- **« seul » :** pour tout y ∈ Dom, personne(y) entraîne y ∈ {Judith, Holopherne} (rq-021). Un atome qui demande
  l'exclusivité n'est appuyé que par une telle assertion, jamais par le silence. Une troisième personne dans Dom en est
  un appui négatif : `contradictoire` (rq-021#5).
- **« tous » :** pour tout x ∈ Dom, R(x) entraîne P(x). La déduction en tire chaque instance (FS § 2.6).
- **« tous sauf E » :** pour tout x ∈ Dom ∖ {E}, P(x). Que E n'ait pas P est un point (le domaine : « nie P(E) »,
  « retire E seulement »), sauf si K atteste l'implication de la construction (von Fintel 1993 [non vérifiée]). Aucun
  cas n'en dépend.
- **Le domaine par défaut** (proposition, comme la décision 40) : la situation dans le chemin où la quantification est
  dite.

**La règle de l'entité nue niée,** seule dans sa classe (NOYAU § 1.1), est « aucun » avec pour domaine implicite tout le
contexte figuré. Le domaine explicite la précise.

### 6.5 Le silence n'est jamais négatif

- **Aucune règle de ce document ne tire un appui négatif d'une absence.** Un domaine restreint ne ferme pas le monde :
  « aucun ange dans la composition » est dit ; « la composition montre la Vierge et quatre saints » ne dit pas
  « seulement ».
- **mn-004, la variante du contrat :** « The contract of 1398 stipulated that no angels should be painted ». C'est une
  négation dans le contexte d'un contrat, et d'un contenu déontique. Elle n'est pas dans le contexte figuré : `inconnue`.
- **Une lecture exclue ne donne pas F.** Un atome sans interprétation admissible n'a aucun appui : N, non une
  réfutation.

## 7. Contextes, situations, représentations emboîtées

### 7.1 La satisfaction relative à un chemin et à une situation

- **Un chemin π** est une suite de contextes (FS § 2.5) : `figuré`, `figuré · tapisserie(e)`, `figuré · rêve(v)`,
  `source(X)`.
- **Une situation s** est un référent d'une sorte propre (ONT § 4). Chaque chemin en a une ou plusieurs ; une seule,
  implicite, quand le texte n'en distingue pas.
- **Sat(D, Δ, π, s) :** Δ est évaluée avec les prémisses de chemin (auteur, affirmé, π) (FS § 2.5), sur les référents de
  π et ceux que l'accessibilité de la DRT y rend visibles, les atomes ancrés au moment de s.
- **Une définition qui ne nomme aucun contexte est neutre :** elle est satisfaite dans un chemin π, dans son propre
  contexte (décision 6 de la propriétaire).
- **Une définition qui nomme des contextes** est un motif de chemins relatifs : « Pharaoh dreaming of seven lean cows »
  demande un Pharaon dans π, et les vaches dans π · rêve(v), où v est le rêve de ce Pharaon.
- **Les inclusions analytiques valent dans tout contexte ;** les faits encyclopédiques dans le seul monde réel (FS § 1.2).
- **Le résultat** est un ensemble de quadruplets (π, s, statut, preuve). Le statut dans (π, s) est le statut synthétique
  du profil restreint à (π, s) (§ 3.5, définition 10) ;
  le chemin d'une assertion peut lui-même être un point (§ 7.5).

### 7.2 Ce que porte la notation retournée

**La forme :** `notation(N, Chemin, Situation, Statut, Preuve)`. La preuve garde le chemin de chaque prémisse.

**Les exemples.**
- **pi-007 :** « Christ on the cross between the two thieves » est satisfaite dans `figuré · copie(e)`, la copie réduite
  d'un Calvaire peinte au mur, dans la situation de cette copie. Elle ne l'est pas dans `figuré`.
- **ee-023 :** « a shepherd giving an apple to one of three goddesses » l'est dans `figuré · tapisserie(e)`, au statut que
  donnent ses points de sens.
- **mn-022 :** les sept vaches maigres le sont dans `figuré · rêve(v)`, v le rêve de Pharaon.
- **pi-003 :** la définition nomme elle-même le rêve : le Christ portant la moitié du manteau est demandé dans
  `figuré · rêve(Martin, s2)`.

### 7.3 Satisfaction contextuelle et décision documentaire

- **Deux fonctions distinctes.** `sat` dit ce qui est vrai, dans quel chemin et quelle situation : c'est sémantique et
  certifié. `retenir(N, œuvre)` dit si la notation est gardée pour l'œuvre principale : c'est une convention
  d'indexation (la pratique d'Iconclass indexe souvent le sujet d'un tableau dans le tableau).
- **`retenir` est une règle écrite,** avec sa source. Elle s'applique après `sat`, se cite, et ne change jamais le statut
  de `sat`.
- **Une forme (proposition) :** `retenir` rend `principale`, `secondaire(π)` ou `non_retenue`, d'après π et la politique
  documentaire. Par défaut : `principale` si π = `figuré`, `secondaire(π)` sinon. La politique est à la propriétaire.
- **La conservation (décision 19) relève de `sat`, non de `retenir`.** La question est : dans quel contexte Δ est-elle
  évaluée ? Proposition : par défaut, l'œuvre telle qu'elle est ; l'état d'origine est un autre contexte, ouvert par des
  assertions d'histoire ou de conservation (« of the Christ Child once seated on her lap, only the feet survive »).
  mn-004 en dépend : `ecartee` dans l'œuvre actuelle, `inconnue` dans l'état d'origine.
- **« (other) X »,** le monde clos sur les notations sœurs (FS § 2.6), est aussi une convention documentaire.

### 7.4 L'identité du personnage et de ses occurrences

**Trois choses :**
- **l'individu désigné :** saint Martin de Tours, dans le monde réel ou celui de la légende ;
- **la figure :** une occurrence de cet individu, dans un chemin π et une situation s ;
- **les mentions :** les mots du texte.

**Les relations.**
- **La coréférence** relie des mentions d'une même figure, dans la même (π, s). Jamais à travers deux situations : la
  fusion ferait de Martin à cheval et de Martin endormi un seul référent, et « St Martin asleep on horseback » serait
  satisfaite. C'est une conjonction fausse.
- **`meme_individu(f1, f2)`** est une relation d'équivalence entre figures, de situations ou de contextes différents,
  **sans fusion** : aucune propriété ne passe de l'une à l'autre. Une requête la demande explicitement.
- **La désignation** (FS § 1.2) relie une figure à un individu. Deux figures qui désignent le même individu documenté
  sont `meme_individu`.
- **Le nom est un point d'identité.** « Saint Martin » peut désigner plusieurs saints. Le même nom dans deux situations
  fonde un choix, que justifie une préférence : l'hypothèse `identite` de la décision 15, symétrique de la distinction
  supposée.
- **Le texte peut le dire :** « la même jeune femme » (ee-019) donne `meme_individu`, non une coréférence.

**Les exemples.**
- **ee-019 :** Δ « while an angel speaks to her » demande une seule situation. La jeune femme de la première scène (à qui
  l'ange parle) et celle de la seconde (qui tient l'enfant) sont deux figures, `meme_individu`. Aucune situation ne
  satisfait Δ : `inconnue`, en (a) comme en (b). Une représentation qui fusionnerait les figures donnerait `etablie` :
  elle ne serait pas correcte.
- **pi-003 :** « cette moitié de manteau » relie deux objets, le manteau partagé dans la première scène et celui que le
  Christ porte dans le rêve de la seconde : `meme_individu` entre objets, à travers un contexte.
- **La requête de pi-003** demande `meme_individu(X, Y)`, la situation de X différente de celle de Y, et la succession
  des deux (« in a later scene »).

### 7.5 Le contexte comme point d'ambiguïté

- **« Selon X »** (décision 16) : le chemin de l'assertion est un point, de domaine {source(X) parlant du figuré,
  le monde de la source}. La nature de X, si K l'atteste (un document sur l'œuvre, un texte du récit), est une contrainte.
  Sinon, la supervaluation s'applique.
- **« Un ange de marbre »** (décisions 13 et 31) : {un ange de matière marbre dans π, une statue dans π qui figure un ange
  dans π · statue}.
- **Une inscription** (décision 20) : son texte est un contexte. Le lien d'un titulus à une figure est typique, sauf si
  l'auteur le dit.

## 8. Les 40 décisions regroupées

### 8.1 Huit principes

| | principe | ce qu'il dit | fondé sur |
|---|---|---|---|
| **P1** | trois niveaux ; K explicite et attesté | le statut de référence ne dépend pas de K ; le statut démontrable est relatif à un K explicite, versionné, attesté (ressource et validation), dont les exclusions sont des connaissances comme les autres | décision 1 de la propriétaire ; FS § 2.7 |
| **P2** | une représentation commune | les conventions de représentation (rôles, relations, unités lexicalisées) sont les mêmes des deux côtés, et fixées avant les statuts | FS § 3.2 (la symétrie) |
| **P3** | les interprétations admissibles | des points, des domaines, des contraintes dures, des préférences ; établie = vraie dans toutes ; sous hypothèse = un choix nommé ; une preuve par cas | décision 2 de la propriétaire |
| **P4** | la symétrie des définitions | le libellé a ses points ; une requête porte sur des concepts ou des ensembles de sens admissibles ; l'identité du lemme n'établit rien | décision 3 de la propriétaire |
| **P5** | les contextes et les chemins | la satisfaction est relative à un chemin ; l'énonciateur et la modalité sont des propriétés du chemin ; la satisfaction contextuelle n'est pas la décision documentaire | décision 6 de la propriétaire ; FS § 2.5 |
| **P6** | les situations, le temps, l'identité des occurrences | la satisfaction est relative à une situation ; l'ancrage est relatif au moment d'une situation, et exclusif ; `meme_individu` sans fusion | décision 6 de la propriétaire ; ONT § 3-4 |
| **P7** | la négation et l'incompatibilité indexées | un appui négatif est dit ou attesté, et indexé par porteur, moment et contexte ; la négation est propositionnelle ; la quantification est explicite ; le silence n'est jamais négatif | décision 5 de la propriétaire ; FS § 2.6, § 3.3 |
| **P8** | la déduction et l'abduction distinctes | chaque connaissance a sa sorte et sa direction ; la déduction part de prémisses établies ; l'abduction explique des observations et garde ses concurrentes ; un choix de lecture n'est pas une abduction | FS § 4-5 ; SPEC § 2-4 |

### 8.2 Les dépendances

| principe | suppose | pourquoi |
|---|---|---|
| P1 | — | il dit relativement à quoi tout statut se lit |
| P2 | P1 | une convention de représentation est une partie de ρ, dont (b) dépend |
| P3 | P1, P2 | une exclusion est une connaissance attestée (P1) ; les points sont définis sur la représentation (P2) |
| P4 | P3 | les points de Δ sont des points comme les autres |
| P5 | P1 | ce qui traverse les contextes est fixé par K (les inclusions analytiques seules) |
| P6 | P5 | une situation est dans un chemin ; l'ancrage est relatif à elle |
| P7 | P3, P5, P6 | une négation vaut sous une interprétation (P3), et s'indexe par contexte (P5) et par moment (P6) |
| P8 | P1, P3, P7 | les sortes et leur attestation (P1) ; les hypothèses conjointes (P3) ; les directions de négation (P7) |

**L'ordre qui s'en déduit :** P1, P2, P3, P4, P5, P6, P7, P8. Il guide l'ordre de spécification (§ 9.8).

### 8.3 Le tableau des 40 décisions

« Tranché » dit ce que le principe fixe ; « reste » dit ce qui demande encore une décision, ou un travail de K.

| n° | décision | principe | tranché par le principe | reste |
|---|---|---|---|---|
| 1 | régime des sens | P3, P1 | ni tous les sens, ni un sens : la supervaluation sur I_K ; `sens_fixe_par_le_contexte` ne vaut que pour une exclusion citée ; une préférence donne une hypothèse ; l'option B, choisie (§ 3.5) | l'inventaire des contraintes attestées (§ 3.3) |
| 2 | type de la définition | P4 (tranché par la propriétaire) | des ensembles de sens admissibles ; le libellé désambiguïsé comme D | la ressource de typage des libellés et sa validation ; le passage des `etablie` par même lemme |
| 3 | sens français, WOLF | P1 | WOLF ne fixe pas (a) ; (b) est relatif à la version de K ; traduction : même (a), écart de (b) = couverture | compléter WOLF (travail de K, phase 2) ; la déclaration de complétude (⊥) |
| 4 | attestation de K | P1, P8 | une exclusion est attestée comme toute connaissance ; une glose n'exclut rien | les six points (glose, pointeur `+`, document du projet, condition, restriction de sélection, partie obligatoire) ; les ressources de sélection retenues |
| 5 | alias, noms partiels | P3, P1 | un nom partiel est un point d'identité ; supervaluation sur les individus documentés ; les co-lemmes d'une instance sont des alias | `cle_de_nom` entre les langues (ingénierie de K) |
| 6 | négation d'une description (D41) | P7 | une proposition niée réfute une sélection qu'elle couvre (§ 6.4) | la règle dans NOYAU 0.4 |
| 7 | incompatibilités, antonymie | P7 (tranché par la propriétaire) | une sorte attestée et indexée ; l'antonymie est une ressource | la liste, sa validation |
| 8 | contraposition | P8, P7 | la négation suit la direction de chaque connaissance, à l'évaluation | l'opération qui la porte (SPEC 1.2) |
| 9 | rôle inversé | P7 | une inversion n'est négative que par une asymétrie ou un ordre attestés : une incompatibilité entre R(x, y) et R(y, x) | la liste des relations asymétriques ; les converses en canonisation |
| 10 | négations impliquées | P7, P5 | une absence n'est négative que si une proposition du texte l'entraîne par une connaissance attestée ; une substitution parle de l'autre œuvre | l'attestation des implications lexicales (« remplacer ») |
| 11 | portée de `non/1`, rôle nié | P7 | une variable locale à `non` est existentielle à l'intérieur ; un rôle nié est une proposition niée | la syntaxe (NOYAU 0.4) |
| 12 | négation vers un concept | P5 | la présence est relative au contexte ; un concept est du signifié | la spécification des contextes (S3, § 9.8) |
| 13 | satisfaction dans un emboîtement | P5 (tranché par la propriétaire) | satisfaction dans le chemin ; la notation porte le chemin ; la décision documentaire est à part | la politique de `retenir` ; la statue et le décor (un point de contexte) |
| 14 | satisfaction relative à une situation | P6 | une situation ; « while » en demande une ; la situation implicite garde le noyau actuel | quand un libellé sans marque de simultanéité demande une seule situation |
| 15 | identité entre situations | P6 (séparation tranchée par la propriétaire) | `meme_individu` sans fusion ; une reprise dite donne `meme_individu` | le même nom seul : un choix fondé sur une préférence, ou rien |
| 16 | « selon » | P5, P3 | le chemin d'une assertion « selon X » est un point ; la nature de X, attestée, est une contrainte | la table des natures de X |
| 17 | auteur contre source, ordre de sûreté | P5, P1 | la contradiction reste confinée au chemin ; la sûreté se lit sur les affirmations, signe par signe, la certification à part (§ 2.5, § 2.6, définition 12) | la rédaction de BANCS § 7 avec les six mesures |
| 18 | copie, « d'après » | P5, P8 | le modèle est une autre œuvre ; rien ne passe sans une explication d'observations de la copie | — |
| 19 | état de conservation | P5 | l'état d'origine est un autre contexte que l'œuvre actuelle | le contexte d'évaluation par défaut (mn-004 en dépend) |
| 20 | inscriptions, titres | P5, P8 | le texte inscrit est un contexte ; le lien titulus-figure est typique, sauf si l'auteur le dit | l'étiquette d'un tiers : source citée ou titre |
| 21 | désignation, source, histoire | P5, P1 | seules les inclusions analytiques traversent les contextes | — |
| 22 | prémisses graduées, « semble » | P8, P3 | une prémisse graduée est une hypothèse d'une sorte propre, non un choix de lecture ; « semble » est un point (modalité ou apparence) | la sorte d'hypothèse, avec l'abduction |
| 23 | abduction à deux explications de même coût | P8, P3 | l'ambiguïté est rapportée : chaque notation sous hypothèse, la concurrente citée ; la forme de la supervaluation | — |
| 24 | ce qu'une abduction explique | P8, P5 | une observation est une assertion admissible de l'auteur dans le chemin figuré | — |
| 25 | seuil d'appariement | P8 | rien : c'est un paramètre | sa valeur, avant la phase 4 |
| 26 | ancrage temporel | P6, P7 | les ancrages d'une même éventualité, relatifs à une même situation, s'excluent : une propriété du langage | la frontière lexicale (« s'apprête », « about to ») comme point de D |
| 27 | relations entre éventualités | P6, P7 | aucune relation tirée de la mise en page ni de la coprésence : le silence ne dit pas d'ordre | le but comme contexte (S3) |
| 28 | rôles, postures | P2 | une seule convention, des deux côtés | la convention elle-même (`BANC_GRAPHES.md`) |
| 29 | « prétendu », « ancien » | P6, P3 | « ancien » est un ancrage antérieur, nié au moment figuré ; « prétendu » n'engage pas | la liste des classes de modificateurs (S6) |
| 30 | degré, superlatif | P7, P8 | l'incompatibilité de degré s'indexe par la classe de comparaison ; « superlatif ⇒ positif » n'est pas analytique | la représentation de la classe de comparaison |
| 31 | composés | P2, P3 | unité lexicalisée ou construction : un point de structure, sous la même convention des deux côtés ; la relation implicite est typique | l'attestation des relations implicites |
| 32 | « e.g. », pluriel du libellé | P4 | ce sont des points de Δ (une liste d'exemples ; au moins un ou au moins deux) | la pratique de classement pour le pluriel |
| 33 | raisonnement par cas | P3 | une alternative de l'auteur se traite par cas ; choisir une branche est une abduction | — |
| 34 | « portrait de X en Y » | P5 | deux relations : le modèle réel, le personnage figuré | — |
| 35 | prépositions, table | P3, P2 | les concepts de relation sont des points, sous la supervaluation ; leur hiérarchie est dans K | la table (phase 2) |
| 36 | cadre de référence | P3 | le cadre est un point ; une convention de genre attestée est une contrainte | l'attestation de la convention des notices |
| 37 | partie et tout | P8, P5 | aucun transfert sans une règle dirigée ; le tout impliqué n'est pas présent | les règles de K |
| 38 | distributif, collectif | P3 (tranché par la propriétaire) | supervaluation sur les lectures ; une lecture choisie est un choix nommé (rq-011 : sous hypothèse) | la distributivité des prédicats, dans K |
| 39 | ambiguïtés de structure | P3 (tranché par la propriétaire) | chaque ambiguïté est un point ; une norme grammaticale est une préférence (sa-010, rq-002 : sous hypothèse) | l'inventaire des contraintes du lecteur |
| 40 | « seul », « tous », « tous sauf » | P7 | une quantification énoncée, sur un domaine ; le domaine par défaut est la situation | la polarité de l'exception (un point, sans cas) |

**Deux recommandations de DEC changent par les décisions de la propriétaire.** Décision 39 : la session de
développement recommandait une alternative, `inconnue` ; la décision 2 de la propriétaire étend la supervaluation et les
hypothèses nommées aux ambiguïtés syntaxiques et aux coréférences. Décision 13 : seul le premier niveau fixait le statut ;
la décision 6 de la propriétaire fait satisfaire la définition dans son propre contexte, la décision documentaire à part.

### 8.4 La combinaison

**Trois sortes de dépendances.** Une décision ouverte agit sur un cas de l'une de trois façons :
- **sur l'espace :** un point, son domaine, les contraintes qui le fixeraient (sens, structure, coréférence, portée,
  lecture, cadre, contexte, identité) ;
- **sur une convention d'évaluation :** une règle appliquée sous chaque interprétation, non encore décidée (l'exclusivité
  des ancrages, 26 ; la situation unique, 14 ; le contexte de la conservation, 19 ; la retenue documentaire, 13 ; la forme
  « e.g. », 32) ;
- **sur K :** une entrée et son attestation (une incompatibilité, 7 ; un alias, 5 ; une condition, 4).

**Ce que déclare un cas (proposition).**
- **`dependances` :** une liste. Chaque élément nomme sa dimension, la décision de DEC dont il dépend, son objet (un point,
  une convention, une entrée de K) et ses options, chacune avec son effet (des contraintes ajoutées, un domaine changé,
  une règle d'évaluation, une entrée ajoutée ou retirée).
- **`profil` :** les classes d'interprétations et, pour chacune, sous chaque convention : la valeur de Belnap, les
  hypothèses non lexicales avec leur nature, l'énonciateur, le chemin (définition 6). Le rédacteur l'écrit ; c'est
  petit.
- **`statut_reference` :** le jugement (a), son profil et les valeurs qu'il tient pour admissibles ; son nom est
  Syn(Π_a).

**Le calcul.** Pour un vecteur d'options o = (o_1, …, o_m) :
- K_o = K du cas, plus ou moins les entrées des options ; C_o = les contraintes ; I_o = I_{K_o, C_o} ;
- st_o(i) = le statut local du profil, sous les conventions de o ;
- **Π(o)** = le profil (I_o, st_o) et **S(o) = Syn(Π(o))** (§ 3.5, définition 10). On compare les Π(o), non les seuls
  S(o) (§ 3.5, définition 11, la non-monotonie).
- **Par dimension :** S(o) quand seule o_j varie, les autres options aux règles en vigueur. **En combinaison :** S(o).
- **Le statut écrit** est S(o) pour les règles provisoires de BANCS § 4.1. Trancher une décision fixe o_j ; les statuts se
  recalculent mécaniquement.

**Ce que devient `decision_ouverte` :** une liste de dimensions, non une question unique. Cela règle les trois défauts de
DEC § 3.6 : les questions mêlées (rq-003, sa-010), les options marquées « #n », et les `decision_ouverte` sans effet, que
le calcul détecte (S(o) ne dépend pas de o_j).

**Un exemple, mn-004.**

```json
"dependances": [
  {"id": "d1", "dimension": "sens", "decision": 1, "objet": {"cote": "description", "occurrence": "angels"},
   "domaine": ["09538915 être spirituel", "personne sainte", "investisseur", "Angel Falls"],
   "exclusions": [{"valeur": "Angel Falls", "contrainte": "nom commun au pluriel : instance exclue",
                   "source": "WordNet 3.0 (@i) et morphologie", "attestee": true}]},
  {"id": "d2", "dimension": "sens", "decision": 2, "objet": {"cote": "definition", "occurrence": "angels"},
   "domaine": ["09538915 être spirituel", "personne sainte", "investisseur"]},
  {"id": "d3", "dimension": "contexte", "decision": 19, "objet": "contexte d'évaluation",
   "options": ["oeuvre_actuelle", "etat_d_origine"]}
],
"profil": [
  {"classe": {"d1 = d2": true, "d3": "oeuvre_actuelle"}, "valeur": "F", "contexte": "principal",
   "enonciateur": "auteur", "hypotheses": [], "substitution": {"x": "angels (D)"}},
  {"classe": "autres", "valeur": "N", "contexte": "principal", "enonciateur": null, "hypotheses": []}
],
"statut_reference": {"statut": "ecartee", "admissibles": {"d1": ["09538915"], "d2": ["09538915"]},
                     "convention": {"d3": "oeuvre_actuelle"}}
```

Le calcul donne (révisé en 1.1) : sous les règles provisoires, `inconnue` (le statut écrit) ; sous l'option B,
`ecartee_sous_hypotheses`, couverture [d1 = d2], le cylindre préféré [d1 ↦ 09538915, d2 ↦ 09538915] d'abord, les six
classes N rapportées ; avec Δ typé, le choix se réduit à d1 ; sous `etat_d_origine`, toutes les classes sont N :
`inconnue`. Le profil de référence n'a qu'une classe admissible, F : `ecartee`. L'écart de (b) à (a) est un
affaiblissement (définition 12), non une erreur.

**Un exemple, ee-002, variante de temps.** Trois dépendances : les sens (décisions 1 et 3) ; l'exclusivité des ancrages
(26), une convention ; l'incompatibilité vêtu / nu (7), une entrée de K.
- Sous l'exclusivité, le don de D est ancré « antérieur » ; l'atome d'ancrage « en cours » du don demandé est faux pour
  cet événement. La conjonction est fausse pour ces référents : `ecartee`, quel que soit le sens de « donner »
  (proposition d'analyse ; le cas écrit `inconnue`, qui est le statut sans exclusivité).
- L'incompatibilité vêtu / nu est **sans effet** : les deux états ne sont pas au même moment. Le calcul le détecte.

**Un exemple, pi-003.** Il dépend à la fois d'une hypothèse de sens, d'une convention temporelle, d'une condition
d'identité et d'un contexte de représentation :
- les sens des mots français (décisions 1 et 3) ;
- la succession des deux situations : fixée par le texte (« la nuit suivante ») ;
- l'identité de Martin entre les situations (décision 15) : un nom suffit, un choix, ou une identité dite ;
- le contexte du rêve : fixé par le texte (« voit en rêve ») et par la décision 6 de la propriétaire ;
- l'identité de la moitié du manteau : fixée par le texte (« cette moitié »).
Le profil : `etablie` dans les classes où les sens atteignent Δ et où l'identité de Martin tient ; `inconnue` ailleurs. Le
calcul donne : identité dite exigée, `inconnue` (le statut écrit) ; identité supposée, `etablie_sous_hypotheses`, avec
deux hypothèses de natures distinctes, [lecture(sens) : les sens qui atteignent Δ] et [identite : Martin] (§ 3.7 (b)) ;
le nom suffit et les sens sont fixés, `etablie`. Le statut de référence est `etablie`.

**Les variations « désambiguïsation » et « ajout d'indice »** (DEC § 3.8) reçoivent une relation calculable
(proposition, révisée en 1.1).
- **Ajouter une contrainte dure** réduit I à I' ⊆ I. Le statut local de chaque i ∈ I' ne change pas ; seuls les I^λ se
  restreignent. Donc : `etablie` reste `etablie`, ou devient `aucune_interpretation` si I' = ∅ ; de même `ecartee`. Une
  conclusion sous h peut devenir totale (si I' ⊆ [h]) ou disparaître (si I' ∩ [h] = ∅). Un profil `divergent` peut
  devenir n'importe quel statut d'un seul signe, ou le rester. Ces relations se testent (§ 9.6, T11).
- **Ajouter un indice** (une assertion à D) change G_i. D⁺ et D⁻ ne font que croître (lemme 1). Une classe V peut devenir
  B, une F aussi ; une N peut devenir V, F ou B. Les statuts ne sont pas monotones ; les dérivations le sont.

## 9. Ce que cela demande

### 9.1 Au langage d'assertions

- **Des points dans le graphe,** au-delà des sens : des assertions conditionnées par une lecture, de la forme « A, si
  p = v ». Le graphe reste plat ; les points et leurs contraintes s'ajoutent, comme dans la MRS et la sémantique des
  trous (une base plate et des contraintes), ou les représentations à choix (Maxwell et Kaplan [non vérifiée]).
- **La coréférence possible entre dans le graphe comme un point** : C9 est révisé, sans qu'elle devienne une coréférence.
- **Les faits d'analyse du lecteur** dont dépendent les exclusions : la catégorie, le cadre, l'accord.
- **Ce que S3 à S6 apportent :** les chemins, les situations, `meme_individu`, les propositions niées, les
  quantifications.

### 9.2 Aux requêtes

- des types qui sont des points de Δ, de domaine un ensemble de sens admissibles ;
- `non/1`, à variables locales ;
- les atomes de quantification ;
- des motifs de chemins et des variables de situation ;
- la contrainte `meme_individu`.

### 9.3 À K

- **l'inventaire des sens,** avec sa déclaration de complétude par lexique ;
- **un module de contraintes,** versionné : restrictions de sélection avec leur domaine de validité, cadres, marques
  syntaxiques, incompatibilités indexées, conventions de genre attestées ;
- **le typage attesté des libellés,** dans la base de définitions conceptuelles ;
- **un module de préférences, à part,** que la certification ne consulte jamais.

### 9.4 Au noyau

- **Sous une interprétation, la logique ne change pas.** Le pas de lexicalisation n'y sert plus pour une requête typée
  par des sens.
- **Une couche de supervaluation,** au-dessus : l'énumération des cas par composante, filtrée ; l'appel du noyau par
  cas ; le profil ; le statut synthétique (définition 10) ; la preuve et la réfutation par cas (∀i∃σ).
- **Les hypothèses `choix`,** dont deux sortes actuelles sont des cas particuliers, et la nature de chaque hypothèse
  (définition 4), que rien ne change.
- **La réfutation certifiable** (définition 2), les statuts `ecartee_sous_hypotheses`, `divergent` et
  `aucune_interpretation`, et le signe de NC (proposition, § 3.5).
- **Les appuis négatifs nouveaux :** par incompatibilité indexée, par proposition niée (D41), par quantification.
- **La satisfaction par (π, s).**

### 9.5 Au vérificateur

- **Les contrôles du § 5.5 :** les domaines sont ceux de K ; chaque exclusion est refaite ; le recouvrement est complet
  sur la composante ; chaque cas est vérifié comme aujourd'hui ; h est admissible, par son témoin, et listée ; aucune
  hypothèse n'a une préférence pour fondement.
- **Les contrôles nouveaux en 1.1 :** les réfutations, comme les preuves (§ 2.6) ; la nature de chaque hypothèse, d'après
  sa forme (un choix porte sur un point ; une abduction cite les observations qu'elle explique ; une identité supposée
  cite les noms qui la fondent) ; aucun domaine vide ; sur un banc, le signe licencié par le comparateur.
- **Les mutations à ajouter,** chacune devant être rejetée : une exclusion sans source ; une préférence citée comme
  exclusion ; une valeur retirée d'un domaine ; un cas manquant au recouvrement ; une hypothèse vide ; une contrainte qui
  couple un point de D et un point de Δ ; un appui négatif d'un autre moment ou d'une autre situation ; une fusion de
  figures entre situations ; une notation rendue sans son chemin ; et, en 1.1 : un recouvrement de l'ensemble vide ; un
  témoin qui viole une contrainte de la composante ; une hypothèse dont la nature est changée (une abduction ou une
  identité réécrite en choix de lecture) ; une hypothèse non lexicale retirée d'un cas ; une réfutation dont un atome a
  un appui positif sous σ ; une réfutation rendue pour une substitution qui ne se factorise pas par h⁻ ; un signe
  négatif licencié par l'inclusion Q_sys ⊆ Q_ref.

### 9.6 À l'interpréteur de référence (révisé en 1.1)

**Ce qu'il est.** Un programme à écrire ensuite, indépendant de Prolog, d'après ce document seul, comme l'oracle actuel
(NOYAU § 7). Il reçoit la définition la plus simple : énumérer Ω, garder les interprétations qui satisfont toutes les
contraintes dures, évaluer chaque interprétation avec l'oracle actuel (les lectures fixées), former le profil, appliquer
la table. Sans filtrage, sans ordre, sans budget. Le moteur peut filtrer et factoriser ; le test différentiel compare
leurs profils, non leurs seuls statuts.

**Ce qu'il doit calculer : une propriété testable par règle.** Chacune se teste sur des cas écrits à la main et sur des
cas tirés (graine fixe). « Pour tout cas » veut dire : sur tous les cas tirés.

| | règle | propriété testable |
|---|---|---|
| T1 | I (§ 3.4) | l'ensemble calculé est exactement { i ∈ Ω : aucune contrainte dure violée } ; il ne dépend d'aucune préférence |
| T2 | indépendance (§ 3.4) | aucune contrainte dure ne couple P_D et P_Δ ; I = I_D × I_Δ |
| T3 | fonction (§ 5.4) | aucune preuve, aucune réfutation, aucun cas n'emploie deux valeurs d'un même point |
| T4 | résultat local (définition 5) | pour toute i, le résultat local est celui de l'oracle actuel sur (G_i, Q_i, K) |
| T5 | profil (définition 6) | les classes partitionnent I ; chaque classe porte, par chemin, situation et substitution, la valeur de Belnap, les hypothèses non lexicales et leur nature, les énonciateurs, la certification, la complétude |
| T6 | dérivation et certification (définitions 1, 2) | C⁺ ⇒ D⁺ et non D⁻ ; C⁻ ⇒ D⁻ et non D⁺ ; val = (D⁺, D⁻) |
| T7 | aucune priorité de signe (proposition 3) | pour tout profil Π, Syn(Π̄) est le dual de Syn(Π) |
| T8 | la table (définition 10) | les douze conditions s'excluent deux à deux et couvrent tout profil (vérifié par énumération des profils sur les neuf statuts locaux, NC compté avec son signe, jusqu'à quatre classes) |
| T9 | l'ensemble vide (§ 3.7 (a)) | I = ∅ ⇒ Syn = `aucune_interpretation`, aucune preuve, aucune notation écartée de l'index |
| T10 | les témoins (§ 3.7 (a), (e)) | toute affirmation partielle cite un témoin qui satisfait toutes les contraintes de sa composante ; une classe sans témoin n'est pas rendue |
| T11 | ajout d'une contrainte (§ 8.4) | si I' ⊆ I, le statut local de chaque i ∈ I' est inchangé, et Syn(Π') est l'un de ceux que le § 8.4 prévoit |
| T12 | monotonie des dérivations (lemme 1) | ajouter une entrée à K ou une assertion au graphe ne retire aucun D⁺ ni aucun D⁻ |
| T13 | la nature (définition 4) | le multiensemble des (nature, contenu) du résultat est l'union de ceux des classes ; aucune nature ne change ; les choix de lecture ne viennent que des points |
| T14 | hypothèses d'une autre nature (§ 3.7 (b)) | une couverture totale dont une classe a des hypothèses non lexicales n'est jamais `etablie` ni `ecartee` |
| T15 | profils mêlés (§ 3.7 (c)) | V et F ⇒ `divergent`, avec deux preuves de signes opposés ; une seule classe B n'est jamais `divergent` |
| T16 | substitutions (§ 3.7 (d)) | `etablie` ⇔ chaque classe a une solution certifiée ; « uniforme » ⇔ une mention commune par variable à travers les classes ; une réfutation ne se rend sans condition que si elle vaut dans toutes les classes |
| T17 | non-localité (§ 3.7 (e)) | le profil calculé par composantes est égal au profil calculé sur Ω entier |
| T18 | interruption (§ 3.7 (f)) | avec un budget tiré, une classe interrompue sans solution ni réfutation certifiable est ?, et Syn = `incomplet` ; une classe E trouvée avant l'interruption reste E |
| T19 | préférences (§ 4) | permuter ou retirer les préférences ne change ni I, ni le profil, ni Syn ; seul l'ordre des cylindres change |
| T20 | index (§ 3.6) | toute notation dont une classe admissible a une valeur V, B ou NC est retenue ; une réfutation ne retire aucune notation |
| T21 | sûreté positive (proposition 1) | pour des paires (Q1, Q2) avec `oui`(Q1 ⊆ Q2) et des graphes tirés : D⁺(Q1, σ) ⇒ D⁺(Q2, σ ∘ h⁺) |
| T22 | sûreté négative (proposition 2) | pour des paires avec `oui`(Q2 ⊆ Q1) : D⁻(Q1, τ ∘ h⁻) ⇒ D⁻(Q2, τ) ; et le lion ailé est un contre-exemple écrit à la main pour la paire de sens contraire |
| T23 | certification séparée (définition 12) | sur un K tiré et son sous-ensemble tiré, chaque C⁺ du petit K est, dans le grand, C⁺ ou B, jamais F ni N ; de même pour C⁻ |
| T24 | contexte (§ 7.1) | une classe dont les appuis ne sont que dans un contexte non figuratif n'est jamais V dans `figuré` |

### 9.7 Les extensions démontrées nécessaires

| | extension | la démonstration | décision |
|---|---|---|---|
| E1 | des points au-delà des sens, dans le graphe | rq-010 : la lecture distributive a deux couronnements, la collective un. Un seul graphe ne tient les deux qu'en choisissant (ce n'est pas sûr) ou en les perdant (et l'on perd une conclusion vraie dans toutes les lectures) : l'argument d'indiscernabilité d'AUDIT § 2, appliqué aux lectures | propriétaire, 2 |
| E2 | la preuve par cas (∀i∃σ) | rq-010 : chaque lecture a sa solution ; co-018#4 : chaque branche a la sienne. ∃σ∀i ne les établit pas | propriétaire, 2 |
| E3 | des requêtes typées par des sens, et les points de Δ | « horseman » : l'écuyer et l'éleveur. Le lemme établirait une identité de concept fausse | propriétaire, 3 |
| E4 | des contraintes dures, avec leurs sources (K et lecteur) | sans elles, I_K = Ω : D30 sans contrainte, et (b) ne rejoint jamais (a) (ee-002, ee-003) | propriétaire, 2 |
| E5 | les incompatibilités indexées, comme appuis négatifs | sa-022, ee-003 (par l'action), et la variante de temps d'ee-002 qui montre l'index | propriétaire, 5 |
| E6 | la proposition niée (D41) et la quantification explicite | mn-016, rq-021, mn-004 | propriétaire, 5 |
| E7 | la satisfaction par (π, s), et la notation qui porte son chemin | pi-007, ee-023, mn-022 | propriétaire, 6 |
| E8 | `meme_individu` | pi-003, ee-019 | propriétaire, 6 |
| E9 | `ecartee_sous_hypotheses`, `divergent`, le profil et sa table | non démontrée nécessaire à la logique (l'option A était sûre) ; **choisie** pour qu'aucun signe n'ait la priorité, et pour distinguer du silence les réfutations partielles (les 29 négations de la décision 1, les 16 de la décision 6) | propriétaire, R1 (1.1) |
| E10 | la réfutation certifiable, contrôlée par le vérificateur | sans elle, une conclusion négative sous h n'a pas de preuve contrôlable ; le lion ailé montre qu'elle a ses propres conditions | propriétaire, R1 et R2 (1.1) |
| E11 | le comparateur appelé dans les deux sens, par signe | le lion ailé : l'inclusion d'un sens ne licencie que le positif | propriétaire, R2 (1.1) |

**Ce qui n'est pas nécessaire :** un solveur de contraintes général dans le noyau (les domaines sont petits ; l'oracle
énumère ; le moteur filtre) ; une grammaire de précision pour le français ; un modèle neuronal ; l'algèbre d'Allen
complète ; la résolution de toutes les lectures dans le graphe.

### 9.8 L'ordre de spécification, mis à jour (proposition)

| rang | ce qui est spécifié | ancien rang | document |
|---|---|---|---|
| S1 | l'ontologie des éventualités | S1 | ONT (étude faite) |
| S2 | **l'espace d'interprétation :** points, contraintes, supervaluation, `choix` et natures des hypothèses, profil et statut synthétique, preuve et réfutation par cas, types des définitions | nouveau | ce document, puis NOYAU 0.4 (§ 2, § 5, § 6) et l'oracle |
| S3 | les contextes et les situations : satisfaction par (π, s), notation retournée, `meme_individu`, `retenir` à part | S2, et une part de S3 | ASSERTIONS v2, puis le noyau |
| S4 | la temporalité : l'ancrage et son exclusivité, plusieurs situations, la narration | S3 | idem |
| S5 | la négation propositionnelle, la quantification énoncée, les incompatibilités indexées | S5, avec D41 | idem |
| S6 | les modificateurs non intersectifs | S4 | idem |
| S7 | la canonisation et la déduction sur S1 à S6, avec les directions de négation | S6 | SPEC, révisée |
| S8 | la base de définitions conceptuelles et le typage attesté des libellés | S7 | idem |
| S9 | l'abduction | S8 | idem |

**Pourquoi S2 d'abord :** chacune des spécifications S3 à S6 ajoute des dimensions à l'espace (le contexte, l'ancrage,
la lecture, la portée). La supervaluation doit exister pour les recevoir. Les statuts (b) du banc en dépendent déjà
(décisions 1 et 2).

**L'ordre de réalisation** change peu : la couche de supervaluation, d'abord dans l'oracle, avant la phase 3, puisque la
certitude d'un `non(A)` en dépend ; la phase 2 peut canoniser sous une interprétation. Le reste suit TRAJ.

### 9.9 Ce qui n'est pas fait

- aucune syntaxe n'est fixée ;
- aucun statut du banc n'est recompté, ni sous la règle symétrique, ni sous les contraintes ;
- l'inventaire des contraintes n'est pas fait. Les restrictions de VerbNet citées sont à vérifier dans VerbNet 3.3 ;
- les deux propositions de sûreté (§ 2.6) sont écrites, non démontrées mécaniquement ; le lemme 1 (la monotonie des
  dérivations) est admis ;
- le coût de la supervaluation n'est pas borné formellement ;
- la table du statut synthétique (définition 10) est définie, mais n'a été appliquée à aucun cas calculé ;
- le signe de NC (§ 3.5) est une proposition pour NOYAU 0.4, non tranchée ;
- les six mesures de sûreté (définition 12) ne sont calculées sur aucun banc ;
- la politique documentaire (`retenir`) n'est pas proposée en détail ;
- la procédure du jugement de référence (qui juge I(D, Δ, C), sur quel échantillon) n'est pas organisée ;
- la conversion des 204 `decision_ouverte` en listes de dimensions n'est pas faite.

## 10. Les références

**Vérifiées dans ÉdA** (la référence complète y est) :
- **Belnap et Dunn, les bitreillis :** Belnap (1977), « A useful four-valued logic » ; Ginsberg (1988) ; Fitting (1991) ;
  Arieli et Avron (1996).
- **La supervaluation :** Fine (1975), « Vagueness, truth and logic ».
- **La sous-spécification :** Copestake, Flickinger, Pollard et Sag (2005), la MRS ; Copestake, Lascarides et Flickinger
  (2001) ; Bos (1996), la sémantique des trous ; Reyle (1993), l'UDRT et la déduction sur des représentations non
  résolues ; Koller, Niehren et Thater (2003) et Fuchss et al. (2004), les contraintes de dominance.
- **Les contextes et le discours :** Kamp et Reyle (1993) ; Kamp, van Genabith et Reyle (2011), l'accessibilité ; Asher et
  Lascarides (2003), la SDRT et la cohérence du discours.
- **Les situations :** Barwise et Perry (1983) ; Kratzer (1989).
- **Les pluriels et la quantification :** Link (1983) ; Landman (2000) ; Barwise et Cooper (1981).
- **Le temps :** Allen (1983) ; Moens et Steedman (1988).
- **Les ressources lexicales et la sélection :** Fellbaum (1998) et Miller (1995), WordNet ; Sagot et Fišer (2008), WOLF ;
  Kipper Schuler (2005) et Kipper, Korhonen, Ryant et Palmer (2008), VerbNet ; Mertens (2010), les restrictions de
  sélection de DICOVALENCE ; Pustejovsky (1995), la coercition.
- **L'abduction :** Hobbs, Stickel, Appelt et Martin (1993) ; Kakas, Kowalski et Toni (1992).
- **La dépiction :** Walton (1990).
- **L'inclusion des requêtes et le monde clos :** Chandra et Merlin (1977) ; Clark (1978).

**Non vérifiées** (citées de mémoire ; à vérifier avant toute citation dans un autre document) :
- van Fraassen, B. C. (1966). Singular terms, truth-value gaps, and free logic. *The Journal of Philosophy*, 63.
  [non vérifiée] — l'origine de la supervaluation.
- Pinkal, M. (1995). *Logic and Lexicon: The Semantics of the Indefinite*. Kluwer. [non vérifiée] — la supervaluation
  appliquée à l'ambiguïté et à l'imprécision lexicales.
- van Deemter, K. et Peters, S. (dir.) (1996). *Semantic Ambiguity and Underspecification*. CSLI. [non vérifiée] ; et,
  dans ce volume, Poesio sur l'ambiguïté perçue. [non vérifiée]
- Dunn, J. M. (1976). Intuitive semantics for first-degree entailments and « coupled trees ». *Philosophical Studies*,
  29. [non vérifiée] — la sémantique à deux appuis.
- Katz, J. J. et Fodor, J. A. (1963). The structure of a semantic theory. *Language*, 39. [non vérifiée] — les
  restrictions de sélection comme contraintes dures.
- Wilks, Y. (1975). A preferential, pattern-seeking semantics for natural language inference. *Artificial
  Intelligence*, 6. [non vérifiée] — la sémantique des préférences, que ce document sépare des exclusions.
- Resnik, P. (1993). *Selection and Information*. Thèse, University of Pennsylvania ; et (1997), Selectional preference
  and sense disambiguation, atelier ACL SIGLEX. [non vérifiées] — l'association sélectionnelle, une préférence.
- Hirst, G. (1987). *Semantic Interpretation and the Resolution of Ambiguity*. Cambridge University Press. [non
  vérifiée] — la désambiguïsation par contraintes mutuelles.
- Mackworth, A. K. (1977). Consistency in networks of relations. *Artificial Intelligence*, 8. [non vérifiée] — la
  consistance d'arc, un filtrage sûr.
- Navigli, R. (2009). Word sense disambiguation: A survey. *ACM Computing Surveys*, 41(2). [non vérifiée]
- Gale, W. A., Church, K. W. et Yarowsky, D. (1992). One sense per discourse. *Proceedings of the DARPA Speech and
  Natural Language Workshop*. [non vérifiée] — une heuristique, donc une préférence.
- Maxwell, J. T. et Kaplan, R. M. (1991). A method for disjunctive constraint satisfaction. Dans *Current Issues in
  Parsing Technology*, Kluwer. [non vérifiée] — les représentations à choix, des assertions conditionnées par une
  lecture.
- McCarthy, J. (1993). Notes on formalizing context. *Proceedings of IJCAI-93*. [non vérifiée]
- von Fintel, K. (1993). Exceptive constructions. *Natural Language Semantics*, 1. [non vérifiée] — « tous sauf ».
