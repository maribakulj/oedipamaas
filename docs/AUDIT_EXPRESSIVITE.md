# Audit de l'expressivité : le langage d'assertions, le langage des requêtes, l'interface K (27/11)

La demande (troisième message de la propriétaire, § 4) : pour chaque famille de phénomènes sémantiques, distinguer
cinq cas.
- **(1) représentable et correctement traité ;**
- **(2) représentable, mais mal extrait (lecteur) ou mal compilé (C3) ;**
- **(3) demande des connaissances supplémentaires (K) ;**
- **(4) demande une extension du langage** (assertions ou requêtes) ;
- **(5) demande une opération de raisonnement supplémentaire.**

La règle : ne présumer ni que le noyau est insuffisant, ni que son expressivité suffit. Quand une extension est
nécessaire, démontrer pourquoi les constructions existantes ne suffisent pas.

Ce document est un audit, non une spécification. Les extensions qu'il établit nécessaires sont reprises, avec leurs
alternatives, dans `docs/FONDEMENTS_SEMANTIQUES.md`.

## 1. Ce qui est audité

### 1.1 Le langage d'assertions (`docs/ASSERTIONS.md`, `oedipamaas/socle/assertions.pl`)

**La signature.**

| prédicat | rôle |
|---|---|
| `entite(E, Tete, P)` | un référent |
| `nom(A, E, Nom, P)` | un nom propre |
| `propriete(A, E, Mot, P)` | une propriété |
| `nombre(E, N)` | un entier |
| `evenement(V, Predicat, P)` | un événement |
| `role(V, R, E)` | un rôle, `R` parmi agent, patient, theme, instrument, destinataire, lieu |
| `relation(A, E1, Mot, E2, P)` | une relation orientée |
| `coref(E1, E2)`, `distinct(E1, E2)` | identité et différence |
| `alternative(G, [A…])` | des assertions mutuellement exclusives |

**Les qualificatifs.** Un par assertion et par catégorie :
- `polarite` (pos, neg) ;
- `modalite` (affirme, probable, possible, traditionnel, ancien, non_affirme, titre) ;
- `portee` (represente, oeuvre, autre_oeuvre, source, histoire, non_ancre) ;
- `enonciateur` (auteur, cite(X)).

**Les faits de structure, vérifiés par le code :**
- **F1.** Le troisième argument d'un rôle est une **entité** (`entite_inconnue`) : aucun événement n'est le
  participant d'un autre.
- **F2.** Les deux arguments d'une relation sont des **entités** : aucune relation ne relie deux événements, ni un
  événement et une entité.
- **F3.** Les qualificatifs portent sur une assertion entière et sont **plats** : une seule portée, un seul énonciateur
  (auteur, ou une source citée, sans emboîtement), une seule modalité.
- **F4.** Il n'y a aucun terme de temps, d'ordre, de durée ou d'aspect, aucun terme de situation distinct de
  l'événement, aucune quantification autre que l'existence des entités et `nombre/2`, aucun contenu propositionnel
  (ce que dit une inscription, ce qu'un personnage voit, rêve ou ordonne).

### 1.2 Le langage des requêtes (`docs/NOYAU.md`, § 3 ; `requetes.pl`)

- **La forme :** `et`, `ou`, des atomes (`type`, `nom`, `propriete`, `evenement`, `role`, `relation`, `genre`) et des
  contraintes (`meme`, `distincts`, `nombre`).
- **Le fragment :** des formules existentielles positives, l'équivalent d'unions de requêtes conjonctives avec égalité
  et différence. Il n'y a **pas de négation dans une requête**.
- **F5.** Comme dans les assertions, le troisième argument de `role` est une variable de référent (une sorte unique par
  variable ; `bien_formee/2`).

### 1.3 L'interface K (`docs/NOYAU.md`, § 2)

| primitive | ce qu'elle porte |
|---|---|
| `sens/3` | mot → type |
| `sous/2` | un pas vers le général |
| `inclus/2` | l'inclusion sémantique seulement |
| `cle_de_nom/2`, `alias/2`, `distincts_documentes/3` | les noms et leur identité |
| `version/1` | la version |

**F6.** Toutes les primitives relient des **mots, des types ou des noms**, jamais des assertions entre elles. Aucune ne
peut rendre vrai un atome d'après d'autres assertions sur le même référent ; seul l'atome `type(X, T)` utilise la
hiérarchie, à partir de la tête de l'entité.

### 1.4 Deux définitions de l'admissibilité

Elles ne coïncident pas.
- **`assertions:admissible/2`** exige qu'un événement ait tous ses participants admissibles. Elle est employée par des
  modules plus anciens (`scene.pl`, `projection.pl`).
- **Le noyau** (`satisfaction.pl`, `docs/NOYAU.md`, § 1) garde l'événement admissible pour lui-même et traite chaque
  rôle à part : un rôle demande son événement et son participant présents.

La seconde est celle des preuves. **La première devrait être alignée sur elle, ou retirée,** et c'est un défaut de
maintenance, non une limite d'expressivité. La mesure de sûreté suit maintenant la seconde (`outils/graphes/premisses.pl`,
`docs/mesures/V2.md`), au niveau de l'appui contextuellement admissible. Elle ne mesure pas encore la prémisse
réellement certifiable, qui dépend aussi de K et des contraintes (`docs/mesures/V2.md`).

## 2. Deux résultats généraux

**Proposition 1 (monotonie).** Si un graphe G établit une requête Q sous σ, et si G' ajoute à G des assertions
positives, affirmées, de l'auteur, de portée `represente`, hors de toute alternative et sans aucune négation, alors G'
établit Q sous σ, pourvu que le budget de calcul ne soit pas épuisé (un graphe plus grand peut rendre le calcul
`incomplet`, ce qui n'est pas une conclusion).
- **Pourquoi :**
  - les appuis positifs de chaque atome de Q sous σ restent ceux de G (§ 4.1 de NOYAU : un appui est une assertion et
    un lien de K, et rien de ce qui est ajouté ne retire une assertion ni un lien) ;
  - aucun appui négatif n'apparaît, puisque rien de nié n'est ajouté ;
  - les prémisses de la certification (porteurs présents, existence non niée, événement d'un rôle) ne dépendent que
    d'assertions qui restent ;
  - une coréférence ajoutée fusionne des classes, mais un appui de G reste un appui sous la classe fusionnée.
  - Le seul point qui demande attention est `entite/3` **nue** : une entité niée cesse d'être nue si l'on ajoute ce qui
    en parle, et sa négation perd de la portée. Or G' n'ajoute rien de nié, et une perte de négation ne retire aucune
    certification (§ 1.1 de NOYAU).
- **Statut, après mise à l'épreuve** (`tests/plunit/test_monotonie.pl`) : **la proposition est fausse telle quelle pour
  les contraintes d'identité**, et c'est voulu.
  - Un nom ajouté peut défaire une distinction documentaire (D26). Avec X et Z documentés comme deux individus,
    `distincts` est établie ; si le porteur de Z porte aussi X, elle ne l'est plus.
  - Une coréférence ajoutée rend contradictoire une identité entre deux noms que K dit deux individus (D12).
  - Deux contre-exemples écrits à la main le montrent. Le générateur du noyau ne les avait pas produits.
- **La proposition corrigée :** elle vaut pour les requêtes **sans contrainte `meme` ni `distincts`**. Elle vaut
  aussi, pour toute requête, si l'extension n'ajoute ni nom ni coréférence.
  - Mise à l'épreuve sur 3 000 tirages par variante (graines 20261201 et 20261202) :
    - sans nom ajouté, 396 cas établis étendus, tous restés établis ;
    - avec des noms, 346 cas, aucun contre-exemple, ni sur l'identité ni ailleurs.
    - Le générateur n'atteint donc pas les cas d'identité : seuls les deux cas écrits les montrent. C'est une limite du
      générateur, à corriger avant de s'y fier pour l'identité.
  - L'argument ci-dessus reste écrit, non démontré mécaniquement.
- **Conséquence :** une condition non monotone, que l'ajout d'une figure affirmée (sans nom ni coréférence) peut rendre
  fausse, n'est exprimable par aucune requête. Exemples : « seul », « sans », « aucun », « tous », « seulement ».

**Proposition 2 (indiscernabilité).** Deux situations que le langage d'assertions écrit par le même graphe, et dont un
libellé distingue les conditions de vérité, demandent une extension : aucune requête ne sépare deux graphes identiques.
C'est la forme des démonstrations du § 3. Quand l'une des deux situations peut être écrite autrement avec les termes
existants, c'est un défaut d'extraction, de compilation ou de connaissances, non de langage.

## 3. L'audit, famille par famille

Fréquences dans les libellés (`txt/en` d'Iconclass, 44 336 libellés) : des expressions régulières, donc des
**majorants bruités** (« not in biblical context » compte comme une négation). L'ordre de grandeur suffit ici.

### 3.1 Événements, états, processus, situations

**(1) Représentable et traité :**
- un événement et ses participants (néo-davidsonien : un individu d'événement, des rôles) ;
- un état adjectival comme propriété (`nu`, `mort`, `endormi`) ;
- un état nominal comme entité (`calvitie`).

**(2) Mal extrait ou mal compilé :**
- le choix entre ces formes : « death » ou die, « chauve » ou calvitie, « imprisonment » ou imprison, « singer » ou un
  homme qui chante. Le langage a les deux formes, et le lecteur et le compilateur n'en choisissent pas la même. C'est la
  première cause des échecs de représentation (`docs/EXPERIENCE_CROISEE.md`).

**(3) Connaissances :**
- les liens entre un événement et son état résultant (die → dead), entre un nom d'action et son verbe, entre un nom
  d'agent et son événement. Ils existent dans les ressources (liens morphosémantiques, VerbNet, FrameNet), mais K ne
  les porte pas (`docs/INFERENCES.md`).

**(4) Extension nécessaire : l'ancrage temporel et aspectuel des événements par rapport au moment figuré.**
- **La démonstration.**
  - Soit (a) « Anna meurt sous les yeux de ses compagnes » et (b) « le corps sans vie d'Anna est tiré des eaux ».
  - Le libellé « death of Anna » vise (a). Il peut viser (b) au sens large, mais 96D(ANNA)68 (« mort d'Anna ») n'est
    pas « funérailles », et Iconclass distingue l'épisode de ses suites.
  - Si la conséquence de (b), « Anna est morte », est écrite comme `evenement(v, die)` de portée `represente`, (a) et
    (b) ont le même graphe pour cet atome : la conséquence est confondue avec l'événement, ce que la propriétaire
    exclut.
  - Si elle n'est pas écrite, (b) ne dit plus rien de la mort, que le texte implique pourtant.
  - Aucune valeur de portée ne convient : `histoire` dit la provenance de l'œuvre, `non_ancre` un commentaire.
- **Ce qui manque :** pouvoir dire qu'un événement est figuré **en cours**, ou **antérieur** au moment figuré (son
  résultat est visible), ou **imminent** (« sur le point de »).
- **Fréquence :** « after », « before », « while » et apparentés, environ 3 % des libellés. Exemples :
  - « she kneels before Christ after having touched his robe » (73C464) ;
  - « Orion, while asleep, is blinded by Oenopion » (94Q61) : un état simultané d'un événement ;
  - « raising a child from the dead » (11H(FRANCIS OF PAOLA)52) : un changement d'état.

**(5) Opération :** une déduction des conséquences d'un événement et des préconditions d'un état, qui produit des
événements ancrés « antérieurs », jamais « en cours ».

### 3.2 Sémantique compositionnelle

**(1) Représentable et traité :** l'adjectif intersectif (« un lion rouge » : un lion, rouge) et le complément de nom
comme relation.

**(2) Mal extrait :**
- le composé nominal non lexicalisé (« trade card », « fusée de signalisation ») ;
- la coordination (une énumération de libellé, distributive ou collective) ;
- le participe (« praying figure »).

Le langage a de quoi les écrire, mais leur sens n'est pas une règle syntaxique. La contre-expertise de #16 juge ces
opérations.

**(3) Connaissances :**
- la relation implicite d'un composé (matière, but, lieu, partie, agent) ;
- la classe sémantique d'un adjectif.

**(4) Extension nécessaire : les modificateurs non intersectifs du type.**
- **La démonstration.**
  - `propriete(X, W)` ajoute une propriété au référent, qui garde son type : « un faux pistolet » donne
    `entite(E, pistolet)` et `propriete(_, E, faux)`, donc `type(X, pistolet)` établi.
  - Or un faux pistolet n'est pas un pistolet (un adjectif privatif). Un « animal fabuleux » ~ lynx (25FF23) n'est pas
    un lynx réel, et un « ancien évêque » n'est plus évêque.
  - Avec `propriete/4`, (a) « un pistolet en bois » et (b) « un faux pistolet » donnent le même atome `type`.
- **Ce qui manque :** un modificateur qui porte sur le type, non sur le référent. À défaut, le lecteur doit au moins
  rendre non admissible l'atome de type d'une tête privative.
- **Fréquence :** « fabulous », « fantastic », « imaginary », « false » et apparentés, de l'ordre de 2 %, presque tous
  dans les queues `FF` et `GG` (animaux et plantes fabuleux), où la queue dit justement ce statut.

### 3.3 Cadres sémantiques et structures argumentales

**(1) Représentable et traité :** six rôles, actif et passif ramenés aux mêmes rôles.

**(2) Mal extrait :**
- patient ou thème (le lecteur n'écrit jamais `theme`) ;
- les participants indirects (0 juste sur 861 en validation) ;
- la direction et la source, écrites `lieu` ou relation selon les cas (« towards the sky », « from heaven »).

Les relations orientées suffisent à les écrire. C'est une convention à fixer (`docs/BANC_GRAPHES.md`), puis une
extraction.

**(3) Connaissances :**
- les cadres et leurs éléments (FrameNet), les valences (VerbNet, PropBank) ;
- les relations entre cadres (Causative_of, Inchoative_of).

**(4) Extension nécessaire : un événement comme participant (contenu propositionnel).**
- **La démonstration.**
  - Par F1 et F5, aucun rôle ne peut avoir un événement pour valeur.
  - Soit (a) « Dieu ordonne à Ézéchiel de ne pas porter le deuil » et (b) « Dieu ordonne à Ézéchiel de prophétiser ».
    Sans le contenu de l'ordre, (a) et (b) ont le même graphe : `ordonner`, agent Dieu, destinataire Ézéchiel.
  - Écrire ce contenu comme un événement du graphe, `porter le deuil` nié et de portée `represente`, l'affirme ou le
    nie **de la scène**. Or l'ordre porte sur ce qui doit être fait, non sur ce qui est figuré.
  - La qualification plate (F3) n'a aucune valeur pour « sous la portée de l'ordre ». Même cas pour « attempt to kill »
    (97C41, compilé aujourd'hui en un prédicat composé qui n'a plus de lien avec kill), « vision of the seven stars »,
    « remembering Joseph », « asking him to heal her daughter » (73C431), un rêve, le texte d'une inscription.
- **Ce qui manque :** un rôle dont la valeur est un événement, avec un **contexte** propre à cet événement (ordonné,
  tenté, vu en vision, rêvé, écrit). Ses assertions n'appuient alors pas le monde figuré.
- **Fréquence :** « attempt », « order », « vision », « dream », « wish », « ask » et apparentés, environ 2,5 %.

**(5) Opération :** aucune de plus. L'extension (4) est une affaire de représentation et d'admissibilité : un événement
sous un contexte n'est pas une prémisse du monde figuré.

### 3.4 Référence, identité, coréférence, quantification

**(1) Représentable et traité, avec une sémantique soigneusement qualifiée** (D22 à D35, D50) :
- les référents comme classes de coréférence, l'identité en monde ouvert, les trois régimes de distinction ;
- les noms et leurs alias ;
- le nombre dit.

**(2) Mal extrait :**
- la coréférence (rappel 0,04 sur les textes longs) ;
- les pluriels distributifs (« Adam et Ève tenant chacun un fruit » : deux événements) ou collectifs (« le couple
  tient le gâteau » : un) ;
- le nombre (aucun lu avant X1).

**(3) Connaissances :** les alias partiels des noms propres (« Jean » pour Jean-Baptiste). C'est une désambiguïsation
des noms, non une égalité de chaînes (`docs/INFERENCES.md`).

**(4) Pas d'extension pour l'universel et l'exclusif, et c'est voulu.**
- Par la proposition 1, « seul », « tous », « aucun autre » ne sont pas exprimables par une requête.
- Il ne faut pas les rendre exprimables par le monde clos : le silence d'un texte ne dit pas l'absence.
- Ils ne sont fondés que si le texte les dit (« Judith et Holopherne restés seuls », 71U427 ; « alone », 31A54k1). La
  propriété `seul`, le nombre, ou une négation dite (§ 3.6) les écrivent. C'est donc (2), non (4).

**Reste représentable :** « au moins k » par k variables distinctes. « Plusieurs » et « un groupe » restent vagues.

**(4) À examiner : les génériques et les espèces.**
- « The lion as symbol of… », « a type of altarpiece in which saints are presented » : la portée `non_ancre` les met
  hors de la figuration, ce qui est sûr.
- Mais une espèce (le lion comme espèce) n'est pas un référent figuré. Un libellé qui la vise (un symbole d'espèce) ne
  peut pas s'écrire sur un référent présent.
- **Fréquence :** inconnue. À mesurer avant toute décision.

### 3.5 Relations spatiales, temporelles, causales, méréologiques

**(1) Représentable et traité :** les relations spatiales entre entités, nommées par leur préposition, orientées.

**(2) Mal extrait :** la relation contre le lieu d'un événement (« hoisted on a pole » : `lieu`, ou relation `on`).

**(3) Connaissances :**
- **le sens des prépositions.** Aujourd'hui chaque préposition est son propre sens (D20), et « of » écrit la partie,
  la possession, la matière, la représentation (« portrait of »), l'agent.
  - **La démonstration :** « the hand of the man », « the sword of the man », « the portrait of the man » ont le même
    atome `relation(_, of, _)`. Le libellé « hands with finger-tips against each other » (31A25231) est alors satisfait
    par une possession aussi bien que par une partie. Un faux positif est possible.
  - Le langage suffit si le mot de la relation devient un concept (partie_de, possession, matière…) que K hiérarchise,
    comme un type : c'est (3) et (2), non (4).
- **le cadre de référence spatial :** la gauche du spectateur ou celle du personnage.

**(4) Extension nécessaire : les relations entre événements (temps et cause).**
- **La démonstration.** Par F2, aucune relation ne relie deux événements.
  - « Hercules kills Geryon, … after having slain the dog Orthrus » et l'ordre inverse ont le même graphe, la
    conjonction des deux événements.
  - « The plague of hail: Moses raises his rod … and hail and fire fall » (71E11727) ne demande que la coprésence, ce
    qui est représentable. Mais un libellé qui fait d'un événement la cause ou le but d'un autre (« to cover the
    retreat of the Greek fleet », 98B(LEONIDAS I)68) ne s'écrit pas.
- **Ce qui manque :** des relations d'ordre et de cause entre événements, ou l'ancrage du § 3.1, qui en couvre une
  partie (un événement antérieur au moment figuré).
- **Fréquence :** le temps, environ 3 % ; la cause et le but explicites, moins de 0,3 %.

**(5) Opération : la méréologie.**
- Qu'une partie implique son tout (« foredeck » ⇒ ship) et que « partie de » soit transitive (un doigt d'une main d'un
  homme est un doigt de l'homme), ce n'est pas une inclusion de types. `sous/2` et `inclus/2` ne relient que des types
  (F6).
- Il faut une opération qui dérive, avec sa provenance, une relation ou une entité. Le tout supposé est une hypothèse,
  sauf partie obligatoire.

### 3.6 Modalités, alternatives, négation, contextes discursifs

**(1) Représentable et traité, avec le soin du noyau 0.3 :**
- la négation d'une assertion : ce que nie une assertion niée, sans répartition sur les conjonctions ;
- les alternatives, la modalité non affirmée, la source citée, le titre ;
- une prémisse n'est que de l'auteur, affirmée, figurée, hors alternative, porteurs présents.

**(2) Mal extrait :** les négations et les modalités sont vues à moitié par le lecteur actuel (X3).

**(3) Connaissances :** rien de propre.

**(4) Extension nécessaire : une négation dans les requêtes, comme appui négatif exigé.**
- **La démonstration.**
  - « The flames do not harm them » (11H(CRISPIN & CRISPINIAN)64) et « lower angel(s) without wings » (11GG1921)
    demandent que le texte **dise** une négation.
  - Par la proposition 1, aucune requête positive ne l'exige : la requête la plus forte écrivable, les saints et les
    flammes, ou un ange, est aussi satisfaite quand les flammes les brûlent ou quand l'ange a des ailes.
- **Ce qui manque :** un atome `non(A)`, vrai sous σ si A a un **appui négatif de l'auteur** (la valeur (0,1) de
  Belnap). Ce n'est jamais l'absence d'appui positif : pas de monde clos, pas de négation par échec.
  - Le noyau calcule déjà les appuis négatifs et les arbres négatifs (§ 4.5 de NOYAU).
  - L'extension porte sur la requête et la certification : une solution certifiable qui exige un appui négatif
    certifiable.
  - La proposition 1 ne tient plus pour ces requêtes, et c'est voulu.
- **Fréquence :** « not », « without » et apparentés, environ 5 %. Une partie est une convention documentaire (« not in
  biblical context »), qui relève du classement, non de la scène.

**(4) Extension nécessaire, liée au § 3.3 : les contextes emboîtés.**
- Une source citée qui cite une autre source, ou ce qu'un personnage dit, voit ou rêve dans la scène, n'a pas de place
  dans un énonciateur à un seul niveau (F3).

**(5) Opération : les prémisses graduées.**
- `probable`, `traditionnel` (« traditionnellement identifié comme saint Jérôme ») ne sont jamais des prémisses,
  et c'est sûr.
- Mais ils pourraient fonder une conclusion **sous hypothèse**, nommée comme telle. Il faut une opération qui fasse
  entrer ces assertions dans les hypothèses d'une preuve, comme un sens supposé.

### 3.7 Les niveaux de représentation propres aux descriptions d'œuvres

**(1) Représentable et traité :**
- la portée sépare ce que l'image représente, l'objet (technique, support : `oeuvre`, et `genre(T)` pour le
  classement), son histoire, une source textuelle, une autre œuvre, le commentaire non ancré ;
- le titre est une modalité.

**(2) Mal extrait :** les portées (« la figure », « la scène », « le fond » : la polysémie, X2).

**(4) Extension nécessaire : les référents abstraits et la relation de figuration.**
- **La démonstration.**
  - « Personification of the morning, 'Aurora' » (23R110) : une figure **représente** un concept. Le concept, le matin
    ou la Justice, n'est pas un référent présent dans l'image.
  - Or une relation n'est une prémisse que si ses deux entités sont présentes (§ 1 de NOYAU). Une relation
    `personnifie(figure, matin)` n'appuie donc rien tant que le matin n'est pas une entité figurée, et l'écrire figurée
    serait faux.
  - La convention actuelle, `type(personification)` et `nom(X, [MATIN])`, fait du concept un **nom** de la figure.
    « Une femme nommée Aurore » et « la personnification de l'aurore » ont alors le même graphe.
- **Ce qui manque :** une sorte de référent **conceptuel** (non figuré, sans présence à vérifier), et les relations de
  figuration (figure, personnifie, symbolise, est l'attribut de) entre un référent figuré et un concept.
- **Fréquence :** personnification, symbole, allégorie, « represented as », environ 3,5 %.

**(4) Extension nécessaire, de moindre priorité : le contenu d'une inscription,** un texte et non une assertion sur la
scène (le guide ne l'annote pas).

### 3.8 Définitions, classification, abduction

**(1) Représentable et traité :**
- une requête est une **définition** : une condition suffisante, et une nécessaire, tirées du libellé ;
- l'inclusion des requêtes est décidée par un comparateur sûr (§ 8 de NOYAU) ;
- la classification par hyperonymie (un lion est un félin) passe par K.

**(2) Mal compilé :** les gabarits, les queues, les « possible attributes » (C3).

**(3) Connaissances :**
- **des définitions conceptuelles :** « monster : an imaginary creature usually having various human and animal
  parts » (WordNet), « tonsure », « nose » ;
- **des connaissances typiques d'identification :** les « possible attributes » d'Iconclass, 11,5 % des libellés (la
  croix en X de saint André).
- Les deux existent dans des ressources, Iconclass compris. Les réutiliser n'est pas écrire des règles
  iconographiques, mais il faut les tenir pour ce qu'elles sont : une définition, ou un indice typique.

**(5) Opération nécessaire : la classification par définition.**
- **La démonstration.**
  - Par F6, aucune primitive de K ne rend vrai `type(X, T)` à partir de ce que le graphe dit d'autre sur X : seule la
    tête de l'entité compte.
  - Donc « un être humain au-dessus de la taille, serpent en dessous » n'établit `type(X, monster)` par aucun K.
- **Deux réalisations possibles,** sans toucher au noyau :
  - **le dépliage de requête,** côté libellé : remplacer `type(X, T)` par `ou(type(X, T), Def_T(X))`, où Def_T est la
    définition compilée en requête.
    - C'est une **déduction** si Def_T est nécessaire et suffisante (une équivalence), et le comparateur d'inclusion
      peut le vérifier. C'est la réécriture de requêtes des ontologies légères (§ 5 de FONDEMENTS_SEMANTIQUES).
    - Ce n'est qu'une **condition suffisante** si la définition est seulement suffisante.
  - **la dérivation,** côté graphe : ajouter `type(X, T)` avec sa provenance, comme hypothèse, quand la définition est
    typique ou appariée en partie. L'expérience des couches (D) montre qu'un appariement par sacs de mots n'est pas
    sûr : il faut la structure.

**(5) Opération nécessaire : l'abduction.**
- Les hypothèses du noyau sont aujourd'hui de trois sortes : distinction supposée, sens supposé, négation d'un autre
  sens.
- L'abduction ajoute des hypothèses d'une autre sorte : une entité ou un événement supposés, une classification
  supposée, une prémisse graduée.
- **Ce qu'il faut :**
  - étendre le format des preuves et le vérificateur, non la logique ;
  - que les hypothèses soient **conjointement satisfaisables** (les lectures conjointes du lot 4 en sont le cas des
    sens) ;
  - que chacune garde ses assertions sources et sa règle.
  - Le mécanisme de provenance existe : `conditionnel_par_derivation` (lot 3), et les identifiants cités par les
    preuves, que l'expérience des couches exploite.

## 4. Synthèse

| famille | (1) traité | (2) extraction ou compilation | (3) connaissances | (4) extension du langage | (5) opération |
|---|---|---|---|---|---|
| événements, états, situations | événement, rôles, état adjectival ou nominal | le choix de la forme (nom ou événement, propriété ou nom d'état) | liens événement, état et nom (morphosémantiques, VerbNet) | **ancrage temporel et aspectuel** des événements au moment figuré | déduction des conséquences et des préconditions |
| compositionnalité | adjectif intersectif, complément | composés, coordination, participes | relations implicites des composés, classes d'adjectifs | **modificateur non intersectif du type** (privatif) | — |
| cadres, structures argumentales | six rôles | patient et thème, indirects, direction | cadres, valences, relations entre cadres | **un événement comme participant**, avec son contexte | — |
| référence, quantification | classes, identité en monde ouvert, noms, nombre | coréférence, distributif et collectif, nombre | alias partiels (désambiguïsation) | non pour l'universel (voulu) ; à examiner pour les espèces | — |
| espace, temps, cause, partie | relations spatiales orientées | relation ou lieu | **sens des prépositions** (partie, possession, matière…) | **relations entre événements** | méréologie (partie ⇒ tout, transitivité) |
| modalité, négation, contextes | négation d'assertion, alternatives, sources, titre | négations et modalités | — | **`non(A)` dans les requêtes** (appui négatif exigé) ; contextes emboîtés | prémisses graduées comme hypothèses |
| niveaux de représentation | portées, genre | portées polysémiques | — | **référents conceptuels et relations de figuration** ; contenu d'inscription | — |
| définitions, classification, abduction | requêtes-définitions, inclusion sûre | gabarits, queues, attributs | définitions, attributs typiques | — | **classification par définition** (dépliage ou dérivation) ; **abduction** (hypothèses conjointes, provenance) |

**Ce qui n'est pas en cause :**
- la logique du noyau (Belnap, la certification, la supervaluation des sens, le régime de l'identité) : aucune des
  démonstrations ci-dessus ne passe par elle ;
- le fragment des requêtes, qui n'a besoin que d'une négation par appui négatif.

**Ce qui l'est :**
- **trois extensions du langage d'assertions :** l'ancrage temporel, l'événement participant sous un contexte, les
  référents conceptuels ;
- **une extension du langage des requêtes :** `non/1` ;
- **une extension de K :** les sens des relations, et des relations entre types de catégories différentes (nom et
  verbe, adjectif et nom) ;
- **deux opérations :** la classification et l'abduction. La canonisation et la déduction sont à spécifier, non à
  créer (`docs/INFERENCES.md`).

**Ce qui reste à vérifier avant toute décision :**
- la proposition 1 est mise à l'épreuve (`test_monotonie.pl`) et corrigée : elle ne vaut pas pour l'identité ;
- les fréquences, sur un échantillon jugé à la main plutôt que par expressions régulières ;
- pour chaque extension, un banc de contre-exemples qui échoue aujourd'hui (`docs/QUALIFICATION_SEMANTIQUE.md`).
