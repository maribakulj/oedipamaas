# Les décisions sémantiques ouvertes de la phase 1 (version 1, 27/11)

**Pour qui :** la propriétaire, avant toute extension du moteur (`docs/BANCS_PHASE1.md`, en tête : « présenter […] les
décisions sémantiques restant ouvertes **avant** de lancer les extensions »).

**Ce que ce document ne fait pas :** il ne tranche rien. Chaque décision a au plus une recommandation, marquée comme
telle. Rien ici ne change un cas.

## 1. D'où viennent ces décisions

**Les sources.** Les décisions ont été relevées en écrivant le banc de développement de la phase 1 :
- **216 cas de base et 1 286 variantes,** en neuf familles de 24 cas, écrits par des rédacteurs qui ne voyaient ni le
  code ni les sorties ;
- **les neuf fichiers `.questions.md`** des rédacteurs ;
- **trois relectures indépendantes** (A, B et C), qui ont listé 111 lignes de désaccord, dont 54 de sûreté ;
- **une révision** de chaque famille, après les relectures et selon le § 4.1 du protocole ;
- **une harmonisation** de toutes les familles, selon la règle « Ce que D30 dit exactement » (§ 4.1, point 2) et les sens
  français de WOLF ;
- les corrections de noms d'extensions de `CONSOLIDATION.md`, sans effet sur les statuts.

**Les règles provisoires du § 4.1 de `docs/BANCS_PHASE1.md`.** Trois causes de désaccord revenaient. Elles ont reçu une
règle, provisoire jusqu'à la décision de la propriétaire :
1. **ce que contient K :** sont implicites l'hyperonymie et l'instance de WordNet 3.0 (`@`, `@i`), la méronymie de
   partie (`%p`) et le passage d'un mot français à un sens par WOLF. Tout le reste s'écrit dans le cas, avec sa
   source. Une glose seule, une antonymie ou une hypothèse de rédaction ne valent pas attestation ;
2. **le régime des sens :** quand le statut dépend du choix d'un sens, le cas porte une `decision_ouverte` à deux
   options, `tous_les_sens` (D30 sans désambiguïsation) et `sens_fixe_par_le_contexte`. Le statut retenu est le plus
   prudent. Un mot de la définition est un type lemme ; un lien est certain si chaque sens du mot du texte l'atteint ;
   une négation est certaine si chaque sens du type demandé est inclus dans chaque sens du mot nié. Les rôles et les
   relations sont des concepts de la lecture, hors de K ;
3. **les incompatibilités :** aucune sorte de connaissance ne dit que deux types s'excluent. Un contre-modèle qui en
   dépend reste `inconnue`, avec une `decision_ouverte`.

**Le principe.** Chaque cas dont le statut dépend d'un choix porte une `decision_ouverte` : la question et le statut
selon chaque option. Le statut écrit est celui de l'option la plus prudente. Trancher une décision, c'est donc
remplacer ce statut par celui de l'option choisie, sans réécrire les cas.

**Trois limites à ce principe,** constatées au comptage :
- **les variantes qui suivent leur cas.** Une `decision_ouverte` de cas couvre aussi des variantes qui n'en portent
  pas (une paraphrase, une traduction de même statut). Elles changent avec le cas ;
- **les décisions sans `decision_ouverte`.** Quelques décisions touchent des statuts qu'aucun champ ne porte : la
  réfutation D41 sur des verbes à un seul sens (décision 6), les prémisses graduées dans les variantes (décision 22),
  l'ancrage temporel des variantes de temps (décision 26) ;
- **18 `decision_ouverte` sans effet :** toutes leurs options donnent le même statut (section 3.6).

**Comment les cas sont comptés.** Un script lit les 216 cas et leurs variantes.
- « **DO** » : une `decision_ouverte` dont les options donnent des statuts différents. Il y en a 204 en tout, 119 sur
  des cas et 85 sur des variantes ; 186 ont un effet.
- « **suiveuses** » : les variantes de paraphrase, de traduction ou d'ajout qui ont le statut et les hypothèses de leur
  cas, sans `decision_ouverte` propre. Ce compte est approché.
- « **statuts concernés** » : la somme des deux. Le banc a 1 502 statuts (216 + 1 286).
- Les identifiants sont ceux des fichiers. « #n » est la n-ième variante, à partir de 1.

## 2. Les décisions

Elles sont regroupées par thème. Les thèmes et les décisions vont du plus lourd au plus léger. La lourdeur compte le
nombre de statuts qui en dépendent et la portée sur l'architecture.

**Les documents, en abrégé :** FS = `FONDEMENTS_SEMANTIQUES.md`, ONT = `ONTOLOGIE_EVENTUALITES.md`,
SPEC = `SPECIFICATION_OPERATIONS.md`, NOYAU = `NOYAU.md`, AUDIT = `AUDIT_EXPRESSIVITE.md`,
QS = `QUALIFICATION_SEMANTIQUE.md`, BANCS = `BANCS_PHASE1.md`, TRAJ = `TRAJECTOIRE.md`.

---

### Thème I. Les sens et le lexique de K

#### 1. Le régime des sens : tous les sens (D30) ou la désambiguïsation par le contexte (X7)

**La question.** Un mot polysémique du texte prend-il tous les sens que K lui donne, ou le sens que le contexte
fixe ? Le protocole parlait des sens « que le texte laisse ouverts », NOYAU les prend tous.

**Les options.**
- **`tous_les_sens`** (D30 à la lettre) :
  - *moteur :* le noyau tel qu'il est. K ne choisit aucun sens en silence ;
  - *statuts :* un lien positif par un mot polysémique donne `etablie_sous_hypotheses` [sens]. Une négation d'un mot
    polysémique n'est que possible : elle ne réfute rien, et le statut est `inconnue`. Seules réfutent les négations
    où le mot nié et le type demandé n'ont qu'un sens (weep, behead, kneel, flee) ;
- **`sens_fixe_par_le_contexte`** :
  - *moteur :* une désambiguïsation (X7) qui exclut des sens par le contexte. Elle n'est pas spécifiée ;
  - *statuts :* `etablie` pour les liens, `ecartee` pour les négations, quand le contexte fixe le sens.

**Les documents.**
- En tension : BANCS § 4 (« que le texte laisse ouverts ») et NOYAU § 2 (D30 : « La désambiguïsation selon le contexte
  relève de C7 ; K ne choisit plus de sens en silence »).
- NOYAU se contredit en partie : § 1.1 donne « pas de lion : aucun lion n'est figuré » comme un appui négatif, alors
  que § 2 rend possible seulement la négation d'un mot polysémique comme « lion » (relecture B, question 1).
- Muets : TRAJ, phase 8 (« la désambiguïsation (X7) ») ne la spécifie pas ; phase 2 : « C'est mesuré, non contourné ».

**Les cas.**
- **111 DO** ne dépendent que de ce choix :
  - 80 liens positifs. 76 vont de `etablie_sous_hypotheses` à `etablie` ; co-015 va dans l'autre sens (« belle-mère » :
    mother-in-law sous tous les sens, stepmother sous le sens du contexte) ; rq-006, rq-013 et mn-016 vont de
    `inconnue` à `etablie` ;
  - 29 négations, de `inconnue` à `ecartee` ;
  - 2 désaccords entre l'auteur et une source (mn-012#3, ee-021#4, décision 17).
- **14 DO** de plus mêlent ce choix à un autre (un alias, un rattachement, une condition).
- **144 variantes suiveuses.**
- **Statuts concernés : 269.** De plus, 311 statuts portent l'hypothèse `sens`, dont 140 n'ont qu'elle.
- Exemples : sa-001 (« hands » vers give), ee-002 (cavalier, donne, manteau, nu), sa-002 (« donne » nié, 44 sens),
  ee-003 (« dead » nié, 17 sens), mn-004 (« angels » nié, 4 sens).

**Recommandation de la session de développement :** garder `tous_les_sens` comme statut attendu tant que X7 n'est pas
spécifiée.
- C'est la règle écrite du noyau (NOYAU § 2), et c'est la seule qui ne suppose pas une opération absente.
- L'autre option donnerait 29 `ecartee` sur un fondement que personne n'a écrit.
- Quand X7 sera spécifiée, un sens fixé par le contexte devrait entrer dans la preuve comme une hypothèse nommée, avec
  ce qui l'a fixé, et non comme un fait.
- Le prix est dit à la section 3.5 : presque plus aucun cas négatif n'est `ecartee`.

#### 2. Le type d'un mot de la définition : un lemme ou un sens

**La question.** Le compilateur type-t-il un mot de la définition par son lemme, ou par un sens choisi ? La règle
provisoire (§ 4.1, point 2) dit : un type lemme, sauf si la définition donne une clé de sens.

**Les options.**
- **un type lemme :**
  - *moteur :* le compilateur actuel (NOYAU § 3, D27 : `type(X, T)` avec T un mot) ;
  - *statuts :* le même lemme des deux côtés donne un lien certain, par la lexicalisation (NOYAU § 2) ;
- **un sens choisi :**
  - *moteur :* une désambiguïsation des libellés, côté requête ;
  - *statuts :* d'après les révisions, presque tous les `etablie` passent à `etablie_sous_hypotheses` [sens]. La
    révision de `co-` l'avait d'abord appliqué : ses 10 cas de base `etablie` y sont tous passés ; l'harmonisation en
    a remonté 5.

**Les documents.**
- En tension : FS § 2.7 (« Les connaissances portent sur des sens […], non sur des lemmes ») et NOYAU § 2-3 (le mot de
  la requête est un type ; ses sens sont pris par D27).
- SPEC § 1 type les règles de canonisation par des sens, et § 3.1 parle des « hypothèses de sens de l'entrée », sans
  dire si elles figurent dans la preuve (questions de `dc-`, 23).

**Les cas.** Tous les statuts `etablie` : 29 cas de base et 148 variantes. Ce compte est un majorant, non un calcul.
Exemples : ee-011#3 (« Icarus falls »), sa-003 (ascend, heaven, chariot), mn-021 (king contre ruler).

**Recommandation de la session de développement :** garder la règle provisoire pour les mots des libellés, et
réserver les sens aux entrées de la base de définitions.
- FS § 2.7 parle des connaissances de K, non des mots d'un libellé.
- Typer chaque mot d'un libellé par un sens demanderait une désambiguïsation des libellés, aussi peu spécifiée que X7.
- C'est déjà la convention écrite de la famille `dc-`.

#### 3. Les sens français : WOLF tel quel, ses bruits et ses lacunes

**La question.** Pour un mot français, les sens sont ceux de WOLF. WOLF donne des sens bruités (« couronne » au sens de
Stan Laurel, « tenir » a 52 sens), et il ignore des mots et des expressions. Faut-il prendre WOLF tel quel, le compléter,
ou autre chose ?

**Les options.**
- **WOLF tel quel** (la règle provisoire) :
  - *moteur :* aucune ressource de plus ;
  - *statuts :* presque tout cas français positif est sous l'hypothèse `sens`. Un mot ou une expression absents de WOLF
    ne donnent aucun lien, et le statut est `inconnue` ;
- **WOLF complété** par une table de mots et d'expressions, écrite dans K avec sa source et validée :
  - *moteur :* une ressource de plus, versionnée ;
  - *statuts :* les lacunes se referment une à une, par la version de K ;
- **la polysémie du mot anglais correspondant :**
  - *statuts :* ce que les révisions de `sa-`, `ee-` et `dc-` avaient d'abord fait. L'harmonisation l'a retiré, et
    BANCS § 6 l'exclut.

**Les documents.** BANCS § 4.1 (point 1) et § 6 fixent WOLF. FS § 8 : « les ressources […] couvrent mal le
français ». Aucun document ne dit quoi faire d'une expression absente.

**Les cas.**
- **238 statuts** de textes français portent l'hypothèse `sens`. **83 statuts** portent `equivalence_non_attestee`,
  surtout pour un mot français sans lien vers le lemme anglais.
- **64 traductions sur 216** n'ont pas le statut de leur cas. Dans 63 d'entre elles, c'est le côté français qui est
  plus faible :
  - 46 ont `etablie` en anglais, `etablie_sous_hypotheses` en français ;
  - 15 ont `etablie` ou `etablie_sous_hypotheses` en anglais, `inconnue` en français ;
  - 2 ont `ecartee` en anglais, `inconnue` en français.
- **8 DO** dépendent d'un mot absent de WOLF (« si WOLF donnait… »), avec 8 suiveuses.
- **Les mots et expressions sans lien** relevés par les révisions :
  - absents : nature morte, créature imaginaire, jeune homme, couronne d'épines, couronne de laurier, côte à côte,
    personnifier, pommelé, moniale, tueur, couronner, couché, légionnaire, gaulois, songe, larron, fugacité ;
  - sans le sens attendu : filer (get_cracking seul), gril (grill), Force (aucun de ses 26 sens n'est fortitude),
    laboureur, élus (un jeu de cartes), bandeau (headband seul), droite (des sens de ligne).
- Exemples : dc-013#1 (gril), ee-011#1 (laboureur), nr-019#1 (Force), co-018#1 (moniale).

**Recommandation de la session de développement :** garder WOLF tel quel pour les statuts attendus, et écrire une
table française de mots et d'expressions comme un travail de K de la phase 2.
- Inventer une correspondance serait une hypothèse de rédaction, que le § 4.1 exclut.
- Les écarts de traduction se mesurent alors comme une couverture lexicale, non comme des erreurs (section 3.1).

#### 4. Ce que contient K, et ce qui l'atteste

**La question.** Qu'est-ce qui compte comme attestation d'une connaissance ? Six points restent ouverts :
- une **glose** WordNet, adaptée ou non ;
- un **pointeur de dérivation** (`+`) entre un nom et un verbe ;
- un **document du projet** cité comme « entrée nommée » (FS § 1.2 pour « fabulous ») ;
- la **condition** d'une conséquence conditionnelle (« blind » ⇒ un aveuglement antérieur, « si la cécité n'est pas de
  naissance ») : qui l'établit ?
- les **restrictions de sélection** (« la possession exige un possesseur animé ») ;
- l'**obligation d'une partie** : la méronymie ne dit pas si la partie est obligatoire.

**Les options.**
- **la lettre de FS § 2.7 :** une attestation, c'est une ressource et une validation. Une glose est une relation
  inconnue. Un pointeur de dérivation est une ressource sans validation. Un document de la propriétaire est une
  validation ;
- **une lecture large :** une ressource suffit, et la glose ou le pointeur attestent ;
- *moteur, dans les deux cas :* les sortes et leurs directions de négation (TRAJ, phase 5), le champ `source` (§ 4.1) ;
- *statuts :* une connaissance non attestée donne au mieux `etablie_sous_hypotheses`, et ne propage aucune négation.

**Les documents.** FS § 2.7 (« Le défaut d'une glose est relation inconnue » ; l'attestation demande « une validation
(humaine, ou une seconde ressource indépendante) ») ; FS § 8 (« qui atteste la suffisance ») ; SPEC § 2 (la Condition
d'une règle) ; BANCS § 4.1, point 1. La grille de relecture C admettait la glose, les fondements non (relecture C,
question 5).

**Les cas.**
- **Les gloses :** 7 DO (dc-001, dc-024, dc-005, dc-008, nr-017#1, sa-024, mn-020) et 17 suiveuses, soit
  **24 statuts**. K contient 34 relations inconnues, toutes non attestées.
- **Les pointeurs de dérivation** pris pour source : ee-001, ee-010, ee-011, ee-012. Leur effet sur les statuts n'a
  pas été compté.
- **Un document du projet** pris pour source : co-003, co-004, co-005. Le statut n'en dépend pas, d'après la révision.
- **Les conditions :** 13 statuts portent `consequence_conditionnelle` (ee-004, ee-018, ep-001).

**Recommandation de la session de développement :** appliquer FS § 2.7 à la lettre.
- Une glose est une relation inconnue. Un pointeur de dérivation n'atteste qu'avec une validation.
- Une décision écrite de la propriétaire vaut validation, à côté d'une ressource. C'est ce que font co-003 et co-005 :
  le synset de WordNet, et FS § 1.2.
- La condition d'une conséquence conditionnelle s'établit par une assertion du texte, jamais par la ressource qui
  donne la règle.
- L'obligation d'une partie demande sa propre attestation (voir aussi la décision 37).

#### 5. Les noms propres : alias entre langues, noms partiels

**La question.** Le noyau a `cle_de_nom`, `alias` et `distincts_documentes` (NOYAU § 2). Trois points restent ouverts :
- `cle_de_nom` normalise-t-il les noms entre les langues (Tobie et Tobias, Pierre et Peter, NICOLAVS et Nicholas) ?
- un nom partiel (« St John », « le Baptiste », « John ») est-il un alias, une distinction, ou une désambiguïsation ?
- les co-lemmes d'un synset d'instance (« St. John » dans le synset de l'Évangéliste) sont-ils des alias établis ?

**Les options.**
- **`cle_de_nom` normalise entre les langues :**
  - *statuts :* les alias disparaissent de K, et les cas français remontent à `etablie` ;
- **un alias écrit dans K,** attesté par un synset d'instance de WordNet et la forme de WOLF, non attesté sinon :
  - *statuts :* l'hypothèse `identite` pour les noms sans ressource (Tobie, Agar, Siméon, Salomé, KATHERINA) ;
- **pour un nom partiel :** un alias établi (`etablie`), une hypothèse d'identité avec l'ambiguïté rapportée
  (`etablie_sous_hypotheses`), ou rien sans un autre indice (`inconnue`).

**Les documents.** NOYAU § 2 (les primitives) ; AUDIT § 3.4 (3) (« une désambiguïsation des noms, non une égalité de
chaînes ») ; BANCS § 4.1, point 1 (les alias s'écrivent). Les sortes de K du protocole n'ont pas d'« alias » : les cas
emploient `identite_documentaire`.

**Les cas.**
- **11 DO** (co-022#3, co-022#4, co-024#3, dc-015#3, nr-013, pi-001, pi-014, pi-017, rq-003, rq-016, rq-024) et 17
  suiveuses, soit **28 statuts**.
- 54 statuts portent l'hypothèse `identite`. 57 cas écrivent un alias : 64 entrées, dont 31 non attestées.
- Exemples : pi-001 (Tobie / Tobias), rq-024 (Pierre / Peter et Jean / John), pi-014 (« St John »), rq-020 (« John »),
  rq-017 (Minerva et Athena, « counterpart of »).

**Recommandation de la session de développement :** `cle_de_nom` ne normalise pas entre les langues.
- Un alias entre langues s'écrit dans K. Il est attesté par un synset d'instance et la forme de WOLF, comme les cas le
  font déjà ; sinon il donne l'hypothèse `identite`.
- Les co-lemmes d'un synset sont des alias établis de cet individu.
- Quand une forme est aussi le nom partiel d'un autre individu documenté, c'est une désambiguïsation (AUDIT § 3.4) :
  une hypothèse d'identité, l'ambiguïté rapportée. Pour pi-014, c'est l'option `etablie_sous_hypotheses`.

---

### Thème II. La négation et la réfutation

#### 6. La négation d'une description entière (D41) : la cible ou le noyau 0.3

**La question.** « Le Christ ne couronne pas sa mère », face à « Christ crowning the Virgin ». La cible donne
`ecartee`. Le noyau 0.3 ne dérive pas cette réfutation quand aucun autre événement n'est dit (D41), ni pour une entité
restreinte niée (« aucun ange au-dessus de l'étable »). D41 est-elle une incomplétude à lever, ou la sémantique voulue ?

**Les options.**
- **la cible :**
  - *moteur :* une règle de plus dans la table de NOYAU § 1.1 : la négation d'une description réfute une conjonction
    de la requête qui la couvre exactement ;
  - *statuts :* `ecartee` pour ces référents ;
- **le noyau 0.3 :**
  - *moteur :* inchangé ;
  - *statuts :* `inconnue`. Ce n'est pas une erreur de sûreté.

**Les documents.** FS § 1.1 (v_D(Δ) = F) ; NOYAU § 1.1 (« une perte dans le sens sûr », journal D41) ; QS § 2.2
(« écartée si niée »). Aucune extension ni opération du validateur ne nomme ce changement : les cas portent
`extensions_requises: aucune` (questions de `mn-`, 3, et de `nr-`, 10).

**Les cas.**
- **7 statuts `ecartee` aujourd'hui** en dépendent : ce sont des verbes à un seul sens, que D30 ne touche pas
  (sa-004#3, ee-007#6, ee-009#5, mn-002#3, ep-007#7, ep-008#3, ep-015#7).
- **16 statuts** de la décision 1 donnent `ecartee` sous `sens_fixe_par_le_contexte` par cette même réfutation : 14
  événements niés (sa-002, sa-012, sa-018, mn-005, mn-017, rq-007, pi-011, pi-016, ep-023, ep-024, ee-008#5,
  ee-014#5, ee-015#6, dc-021#3), une entité restreinte (nr-003), et co-018#5.

**Recommandation de la session de développement :** confirmer la cible, `ecartee`.
- NOYAU la dit lui-même saine, et dit que sa limite est une perte.
- Inscrire la levée de D41 dans la version 0.4 du noyau, avec `non/1` (TRAJ, phase 3), qui touche déjà aux appuis
  négatifs.
- Lui donner un nom dans la liste des extensions, pour qu'une phase désigne ces cas (section 3.7).

#### 7. Les incompatibilités et l'antonymie

**La question.** Debout et assis, éveillé et endormi, intact et brisé, jeune et vieux, devant et derrière, couronné et
« uncrowned » : aucune sorte de connaissance ne dit que deux types s'excluent. Faut-il une sorte « incompatibilité » ?
Et l'antonymie de WordNet peut-elle l'attester ?

**Les options.**
- **aucune incompatibilité** (la règle provisoire, § 4.1, point 3) :
  - *statuts :* un contre-modèle par un état ou une posture contraires reste `inconnue` ;
- **une sorte « incompatibilité attestée »,** A ⇒ ¬B, avec la contraposition :
  - *moteur :* une sorte de K de plus, avec sa direction de négation (TRAJ, phase 5) ;
  - *statuts :* ces contre-modèles passent à `ecartee` ;
- **pour la source :** l'antonymie de WordNet comme attestation, comme ressource à valider, ou jamais. Pour les adjectifs
  de degré (young / old), la même classe de comparaison est exigée (décision 30).

**Les documents.** FS § 2.7 (une liste fermée, sans incompatibilité) ; FS § 3.3 (la négation ne passe que par une
implication ou une équivalence) ; NOYAU § 1.1 ; BANCS § 4.1, points 1 et 3. Muet : ONT § 6 (les postures, les adjectifs
de degré).

**Les cas.**
- **11 DO** (co-001#3, co-012, co-023#5, ep-008, ep-012, ee-006#3, ee-007#5, ee-024#3, nr-006, nr-018, sa-022) et
  19 suiveuses, soit **30 statuts**.
- D'autres justifications le disent sans `decision_ouverte` : sa-005, sa-019, sa-021, ep-009, rq-023.
- Les rédacteurs de `sa-` y voient « le point qui produit le plus de contre-modèles que l'humain jugerait écartés ».
- Exemples : sa-022 (Jacob éveillé contre « asleep »), nr-018 (« youth » contre « old »), ee-024#3 (« stands intact »).

**Recommandation de la session de développement :** admettre une sorte « incompatibilité établie » (A ⇒ ¬B, qui
transmet le positif de A en négatif de B, et le positif de B en négatif de A).
- Elle est attestée comme les autres sortes : une ressource et une validation. L'antonymie de WordNet peut en être la
  ressource, non l'attestation à elle seule.
- Un antonyme morphologique (« uncrowned ») suit la même règle.
- C'est une connaissance dite, non un monde clos : FS § 3.3 la traite déjà, comme une implication à conclusion niée.

#### 8. La contraposition et les prémisses négatives (SPEC § 2)

**La question.** SPEC § 2 dit que « `deduire` ne part que de prémisses positives admissibles », et aussi qu'« une
négation n'est propagée que par contraposition ». Or la réfutation par une condition nécessaire part d'une négation
(« does not hold his quill » réfute « writing with a quill »). Laquelle des deux phrases l'emporte, et dans quelle
opération ? Et comment une condition structurée (« un œil unique au milieu du front ») est-elle réfutée par la négation
d'une de ses parties (« aucun œil au milieu du front ») ?

**Les options.**
- **la contraposition dans `deduire` :** `deduire` produit aussi des assertions niées ;
- **la contraposition à l'évaluation :** `deduire` reste positif. La contraposition se fait par le lien négatif du noyau
  pour une inclusion, et par la classification pour une condition nécessaire établie (SPEC § 3, tableau) ;
- **aucune contraposition depuis une prémisse niée :**
  - *statuts :* ces cas restent `inconnue` même avec une condition attestée.

**Les documents.** SPEC § 2 (les deux phrases) ; SPEC § 3, tableau (« réfutation par la négation de la définition ») ;
FS § 2.7 (« déductive pour la réfutation ») ; FS § 3.3.

**Les cas.** 4 DO (sa-024, dc-005, dc-008, nr-017#1) et 10 suiveuses, soit **14 statuts**. Tous dépendent aussi de
l'attestation de la condition (décision 4). dc-006 (`ecartee`) n'en dépend pas : il passe par une inclusion de WordNet
(unicorn ⊑ imaginary_creature), que le lien négatif du noyau traite déjà.

**Recommandation de la session de développement :** la contraposition à l'évaluation.
- `deduire` ne produit que des assertions positives.
- Une condition nécessaire établie réfute par la classification, comme SPEC § 3 le dit.
- La réfutation d'une condition structurée par la négation d'une partie suit la règle de la décision 6.
- Écrire cette lecture dans une version 1.2 de SPEC.

#### 9. Les exclusions analytiques des relations, et le rôle inversé

**La question.** Si K disait que « au-dessus » est asymétrique, qu'« avant » est un ordre strict, ou qu'au-dessus et
au-dessous sont des converses, une inversion des rôles donnerait `ecartee`. Le principe « un rôle inversé n'est pas une
preuve négative » vaut-il faute de K, ou même avec K ?

**Les options.**
- **même avec K :** une inversion reste `inconnue` ;
- **faute de K :** une asymétrie ou un ordre attestés écartent. Une converse attestée est une canonisation.

**Les documents.** BANCS § 4 (« son statut est `inconnue` ») ; NOYAU § 4.4 (l'exemple d'un événement, Goliath et
David) ; QS § 2.2 (« jamais établie », ce qui n'exclut pas `ecartee`) ; FS § 1.2 (« les inclusions analytiques de K
valent dans tout contexte ») ; FS § 3.2 (les converses ne figurent pas parmi les canonisations).

**Les cas.** 50 variantes d'inversion, toutes `inconnue`, dont 12 en `ep-` sur des relations spatiales ou temporelles.
Une converse : ep-005#1, `etablie_sous_hypotheses` [equivalence_non_attestee]. Aucune DO. Exemples : ep-005 (au-dessus /
au-dessous), ep-017 et ep-018 (avant), pi-004 (précède / suit).

**Recommandation de la session de développement :** faute de K.
- L'exemple de NOYAU § 4.4 porte sur un événement, où rien n'exclut l'inversion.
- Pour une relation spatiale ou d'ordre, l'asymétrie est analytique. Attestée, elle peut écarter, et QS § 2.2 le permet.
- Une converse attestée entre dans la table de canonisation (TRAJ, phase 2).

#### 10. Les négations impliquées : substitution, contraste

**La question.** « Le copiste a remplacé les tenailles par le livre » ; « Abraham, qui dans le tableau lève le couteau
de la main droite, le lève ici de la main gauche ». Ces phrases impliquent une absence. La lecture doit-elle écrire
cette absence comme une négation dite ?

**Les options.**
- **non :** `inconnue`. Une substitution informe sur l'autre œuvre ;
- **oui :** la lecture écrit l'assertion niée, et le statut est `ecartee`.

**Les documents.** BANCS § 4 (`ecartee` demande « un appui négatif dit, une distinction documentaire ou une contrainte du
texte », D31). Aucun document ne parle des substitutions ni des contrastes.

**Les cas.** 2 DO (dc-016, nr-006) et 6 suiveuses, soit **8 statuts**.

**Recommandation de la session de développement :** `inconnue`.
- Une implication du texte n'est pas une négation dite.
- La question se rouvre si la lecture (TRAJ, phase 8) spécifie de telles assertions, écrites et visibles dans le
  graphe.

#### 11. La négation dans les requêtes : la portée de `non/1`, le rôle nié seul

**La question.**
- « L'Enfant n'a aucune auréole » : dans `non(A)`, une variable qui n'apparaît que sous `non` est-elle existentielle à
  l'intérieur (¬∃h) ou à l'extérieur ?
- « slain not with a sword but with an axe » : comment écrire un rôle nié d'un événement affirmé ? NOYAU § 1.1 dit
  qu'« un rôle n'est pas nié seul ».

**Les options.**
- **pour la portée :** à l'intérieur, ou à l'extérieur. Seule la première donne le sens voulu ;
- **pour le rôle nié :** une extension avec `non/1`, ou une limite déclarée.

**Les documents.** AUDIT § 3.6 (4) (`non(A)` sur un atome) ; NOYAU § 1.1 ; TRAJ, phase 3. Muets sur la portée.

**Les cas.** La portée : mn-016 et ses 3 suiveuses, soit **4 statuts**. Le rôle nié : aucun cas, le rédacteur l'a
évité (sa-008).

**Recommandation de la session de développement :** dans `non(A)`, une variable liée seulement sous `non` est
existentielle à l'intérieur. Le rôle nié d'un événement affirmé se spécifie avec `non/1` dans la version 0.4 du noyau.

#### 12. La négation d'une relation vers un référent conceptuel

**La question.** « Ces objets ne sont pas des signes de la fugacité » ; « elle n'est pas la Prudence ». NOYAU § 1.1
exige, pour un appui négatif, que chaque entité de la relation soit présente. Un concept ne l'est jamais. L'exigence
vaut-elle pour lui ?

**Les options.**
- **l'exigence vaut :** `inconnue` ;
- **le concept n'a pas de présence à vérifier :** `ecartee`.

**Les documents.** NOYAU § 1 et § 1.1 ; AUDIT § 3.7 (« une sorte de référent conceptuel (non figuré, sans présence à
vérifier) ») ; FS § 2.1.

**Les cas.** 2 DO de variantes (nr-016#2, pi-019#5). pi-024 a été réécrit pour éviter la même question pour un lieu
absent (« la ville n'est pas Alexandrie »).

**Recommandation de la session de développement :** dans la spécification des référents conceptuels (TRAJ, phase 6),
lever l'exigence de présence pour l'argument conceptuel seul. L'argument figuré reste présent. C'est ce que dit AUDIT
§ 3.7.

---

### Thème III. Les contextes, les situations, les figurations

#### 13. La satisfaction à travers un emboîtement : vision, tableau dans le tableau, tapisserie, statue, décor

**La question.** Une définition qui ne nomme aucun contexte (« Christ on the cross between the two thieves ») est-elle
satisfaite par une scène figurée seulement dans une figuration emboîtée : un tableau peint au mur, une tapisserie, un
rêve dans une nuée, une vision, une statue d'ange, un laurier de carton sur une scène ?

**Les options.**
- **seul le monde figuré de premier niveau :**
  - *statuts :* `inconnue` ;
- **une figuration emboîtée satisfait, comme sujet secondaire :**
  - *moteur :* une évaluation sur les chemins de contextes, qui change l'admissibilité ;
  - *statuts :* `etablie`, ou `etablie_sous_hypotheses` sous les sens ;
- **pour la statue et le décor,** une lecture de plus : un ange de matière marbre (le type gardé), ou un objet privatif.

**Les documents.** FS § 2.5 (« un référent du contenu d'une vision n'est pas un référent du monde figuré ») ; FS § 2.3 et
ONT § 3 (la situation emboîtée a son moment) ; BANCS § 4 (« ce qui n'est pas dans le contexte de la figuration n'établit
rien »). Muets : FS § 8, ONT § 6. La pratique d'Iconclass indexe souvent le sujet d'un tableau dans le tableau.

**Les cas.**
- **7 DO** (pi-007, ee-023, mn-022, nr-021, dc-003, co-014, dc-018) et 23 suiveuses, soit **30 statuts**.
- 13 justifications en parlent. 14 cas et 3 variantes portent `contexte_emboite` (sa-007#4, sa-015#5).
- Le miroir n'a aucune construction de développement.

**Recommandation de la session de développement :** seul le premier niveau fixe le statut.
- C'est la séparation des contextes de FS § 2.5, et le principe du § 4 du protocole.
- Si la propriétaire veut indexer le sujet d'un emboîtement, c'est une règle de classement, à écrire à part, comme
  « (other) X » (FS § 2.6) : elle ne change pas ce qui est établi dans le figuré.

#### 14. La satisfaction relative à une situation

**La question.** Une définition dont les éléments sont répartis sur deux registres ou deux épisodes est-elle satisfaite ?
Quand une définition doit-elle l'être dans une seule situation ? Deux éventualités d'une même situation sont-elles
simultanées ?

**Les options.**
- **sur l'œuvre entière :**
  - *moteur :* le noyau actuel (une requête sur tout le graphe) ;
  - *statuts :* `etablie` ;
- **dans une même situation :**
  - *moteur :* les situations comme référents (ONT § 4, l'hypothèse de travail) ;
  - *statuts :* `inconnue` quand les éléments sont dans deux situations.

**Les documents.** ONT § 4 (« une satisfaction peut être relative à une situation ») ; ONT § 6 et FS § 8 (ouvert) ; ONT
§ 3 (un moment par situation).

**Les cas.** 3 DO (ee-019, pi-005, dc-023) et 10 suiveuses, soit **13 statuts**. 11 cas portent `situation_referent` et
2 variantes `plusieurs_situations`. Exemples aussi : pi-004 (registres), co-022#4 (narration continue).

**Recommandation de la session de développement :** dans une même situation, quand le texte distingue des situations.
- Sur tout le graphe quand il n'en distingue pas : c'est la situation implicite de ONT § 4, qui garde le comportement
  actuel comme cas particulier.
- Les atomes de l'œuvre (`genre`) restent évalués sur l'œuvre.

#### 15. L'identité d'un personnage entre situations

**La question.** Deux figures nommées « saint Martin », dans deux scènes, figurent-elles le même individu quand le texte
ne le dit pas ? Une reprise (« la même jeune femme », un pronom) d'une scène à l'autre est-elle une coréférence ?

**Les options.**
- **le même nom suffit :** `etablie` ;
- **le même nom fonde une hypothèse d'identité,** symétrique de la distinction supposée : `etablie_sous_hypotheses` ;
- **il faut une identité dite :** `inconnue` ;
- **pour la reprise :** une coréférence, qui fusionnerait les figures, ou la relation « même individu dans une autre
  situation ».

**Les documents.** ONT § 3 (« une relation […] qui ne fusionne pas les figures ») ; FS § 2.3 ; NOYAU § 1 (la distinction
supposée) ; ONT § 6 et FS § 8 (ouvert). TRAJ diffère la réalisation.

**Les cas.** 1 DO (pi-003) et 3 suiveuses, soit **4 statuts**. 5 cas et 2 variantes portent `identite_entre_situations`.
Exemples aussi : pi-001, pi-004, ee-019, pi-002 (« another young man »).

**Recommandation de la session de développement :** le même nom seul fonde une hypothèse d'identité (`identite`),
symétrique de la distinction supposée de NOYAU § 1. Une reprise explicite d'une situation à l'autre produit la relation
« même individu dans une autre situation », jamais une coréférence.

#### 16. « Selon » : une source citée sur le figuré, ou un contexte de source

**La question.** « According to the Medici inventory, the panel showed… » fait de l'inventaire un énonciateur cité :
`non_certifiee`. « Selon les Actes, Hérode fit emprisonner Pierre » ouvre un contexte de source : `inconnue`.
« The painter shows St Margaret, according to the Golden Legend, emerging… » : c'est l'auteur qui affirme. Aucun document
ne donne le critère.

**Les options.**
- **un critère par la nature de X :** un document sur l'œuvre (inventaire, catalogue, notice, restaurateur, programme)
  parle du figuré ; un texte du récit (Évangile, Légende dorée) parle de son monde ;
- **un critère par la portée de l'assertion :** ce que dit la phrase, l'image ou le récit ;
- *statuts :* `non_certifiee`, `inconnue` ou `etablie`, selon la lecture.

**Les documents.** NOYAU § 4.4 (la source citée) ; ASSERTIONS (la portée `source`) ; FS § 2.5 (l'énonciateur est une
propriété du chemin de contextes).

**Les cas.**
- **3 DO** (nr-024, ep-021, nr-009) et 9 suiveuses, soit **12 statuts**.
- Le banc a 32 statuts `non_certifiee`. 26 d'entre eux viennent d'une description qui dit « selon », « according to »
  ou « d'après ».
- Exemples aussi : mn-023, sa-006, rq-007#5, rq-021#7, co-009.

**Recommandation de la session de développement :** écrire le critère par la nature de X, avec une exception.
- Quand l'auteur affirme lui-même ce qui est figuré, X n'est que la source du sujet.
- Dans le doute, `inconnue` (§ 4.1).
- Le critère ne règle pas nr-009, où le critique cité parle par métaphore.

#### 17. L'auteur contre une source citée, et l'ordre de sûreté

**La question.** « Selon le catalogue, elle prie ; en réalité, elle ne prie pas. » Est-ce `contradictoire`
(documentaire), ou l'auteur l'emporte-t-il ? Et où se rangent `contradictoire`, `non_certifiee` et
`etablie_sous_hypotheses` pour la sûreté ?

**Les options.**
- **`contradictoire` documentaire :** NOYAU § 4.3-4.4 ;
- **l'auteur l'emporte :** `ecartee` ou `etablie` selon le côté de l'auteur ;
- *sous D30 :* une négation seulement possible ne contredit rien. mn-012#3 devient alors `etablie_sous_hypotheses`, et
  ee-021#4 `non_certifiee`.

**Les documents.** FS § 2.5 (« Une contradiction entre sources reste confinée, documentaire ») ; NOYAU § 4.3-4.4 ; BANCS
§ 7 (l'erreur de sûreté ne range pas `contradictoire`) ; BANCS § 4.1 (seulement `non_certifiee` contre `inconnue`).

**Les cas.** 2 DO de variantes (mn-012#3, ee-021#4). Le banc a 2 variantes `contradictoire`.

**Recommandation de la session de développement :** garder `contradictoire` documentaire.
- FS § 2.5 dit la même chose que NOYAU : « confinée » veut dire locale à l'atome, et « documentaire » est le nom que
  NOYAU lui donne.
- Écrire dans BANCS § 7 que `contradictoire` et `non_certifiee` sont deux statuts sans certification, plus faibles
  que `etablie_sous_hypotheses`.

#### 18. Copie et « d'après »

**La question.** « Copy of an Adoration », « d'après un tableau perdu », « woven after a cartoon » : le sujet du modèle
passe-t-il à la copie ? La glose de copy (« similar or identical ») ne dit pas sur quoi porte la ressemblance.

**Les options.**
- **non :** la mention du modèle est une assertion sur une autre œuvre. `inconnue` ;
- **sous hypothèse :** la mention est une observation, que l'hypothèse « la copie figure une Adoration » explique.
  `etablie_sous_hypotheses`.

**Les documents.** SPEC § 3.2 et § 4 (une hypothèse doit expliquer des éléments observés) ; FS § 2.5 (les autres œuvres).

**Les cas.** 1 DO (nr-002) et 3 suiveuses, soit **4 statuts**. 10 justifications en parlent (nr-001 à nr-006, ee-021,
ep-007, dc-016, pi-007).

**Recommandation de la session de développement :** non, `inconnue`. La mention d'un modèle n'est pas une assertion sur
le figuré de la copie, et l'hypothèse n'explique aucune observation de la copie (SPEC § 4). Une copie rognée ou
inversée le montre.

#### 19. L'état de conservation

**La question.** Ce que l'œuvre figurait et ne montre plus (« of the Christ Child once seated on her lap, only the feet
survive », « la partie supérieure est perdue », « la corne a été découpée ») est-il encore figuré ? Le dessin sous-jacent
révélé par réflectographie fait-il partie du figuré ?

**Les options.**
- **ce que l'œuvre montre aujourd'hui :** le reste relève de l'histoire de l'objet. `inconnue` ;
- **ce que l'œuvre a été faite pour figurer :** `etablie` par les vestiges, ou `etablie_sous_hypotheses` pour le dessin
  sous-jacent.

**Les documents.** FS § 2.5 (l'œuvre, l'histoire) ; ONT § 3 (le temps des seules situations figurées). Aucun document ne
traite l'état de conservation.

**Les cas.** 2 DO (nr-012, nr-013#5) et 3 suiveuses, soit **5 statuts**. Des variantes de portée en dépendent sans DO :
dc-006, dc-024, ee-014, rq-008#5, rq-014.

**Recommandation de la session de développement :** ce que l'œuvre montre aujourd'hui. Ce qu'elle montrait est de
l'histoire de l'objet ; un dessin sous-jacent est un autre niveau de l'œuvre, non le figuré.

#### 20. Le contenu des inscriptions, les titres, les étiquettes

**La question.**
- Le texte d'une inscription (« S. KATHERINA », un phylactère, « slain at Calais ») est-il une assertion sur la scène,
  un contenu, ou un indice ?
- Le lien entre un titulus et la figure voisine est-il une convention attestable ou une connaissance typique ?
- Une inscription du cadre nomme-t-elle la figure ?
- Une signature se distingue-t-elle d'un nom de figure ?
- Une étiquette de restaurateur est-elle une source citée ou un titre ?

**Les options.**
- **un contenu :** le contexte d'une inscription, qui n'appuie rien du figuré. Le lien au personnage est typique.
  `etablie_sous_hypotheses` au mieux ;
- **un nom de la figure :** `etablie` quand le titulus est une convention ; pour dc-014, l'inscription bloque
  l'identification par l'attribut, et le statut est `inconnue`.

**Les documents.** FS § 2.5 (le contexte de « ce qu'une inscription porte ») ; FS § 8 (ouvert) ; AUDIT § 3.7 (une
extension de moindre priorité) ; TRAJ (différé) ; BANCS § 4.1 (l'extension `contenu_d_inscription`).

**Les cas.** 1 DO (dc-014) et 3 suiveuses. 5 cas et 8 variantes portent `contenu_d_inscription`, et 11 justifications en
parlent. Exemples : pi-017 (NICOLAVS), nr-015 (KATHERINA), mn-024 (un titre inscrit au revers), pi-017#4 (l'étiquette).

**Recommandation de la session de développement :** un contenu.
- Le texte inscrit ouvre un contexte et n'appuie rien du figuré.
- Le lien d'un titulus à une figure est une connaissance typique, sauf si l'auteur le dit (« porte son nom »).
- Une étiquette de tiers est une source citée si elle décrit ce que l'image montre, un titre sinon.
- Pour dc-014, la règle donne l'option « contenu de l'œuvre ».

#### 21. Ce qui passe de la désignation, de la source et de l'histoire au figuré

**La question.**
- Sainte Eulalie est martyre « selon la Passion » : la figure est-elle une « female martyr » ?
- Polyphème est nommé, mais l'auteur nie l'œil unique : « the cyclops Polyphemus » est-il réfuté ?
- Judith est-elle une femme par K ?
- Un marché de 1512 qui nomme le personnage, des archives qui disent un mariage : valent-ils pour le figuré ?

**Les options.**
- **rien ne passe** sans une assertion de l'auteur sur le figuré, sauf les inclusions analytiques de K ;
- **la désignation transmet le type** de l'individu désigné (la pratique d'Iconclass) ;
- **pour une définition qui joint un type et un nom :** une conjonction, `ecartee` si la condition est attestée ; ou un
  nom avec une épithète non compilée, `etablie_sous_hypotheses`.

**Les documents.** FS § 1.2 (« Les faits encyclopédiques ne valent que dans le monde réel » ; la désignation) ; FS § 3.4 ;
FONDEMENTS.md § 4.2 (la désignation, citée par FS).

**Les cas.** 1 DO (dc-005) et 4 suiveuses, soit **5 statuts**. Sans DO : dc-004, pi-021 (judith @i heroine @ woman),
pi-016 (le genre des noms propres), pi-023 et pi-024 (un lieu réel), rq-003#4.

**Recommandation de la session de développement :** rien ne passe sans une assertion de l'auteur.
- Seules les inclusions analytiques de K sur le synset d'instance passent, comme pour pi-021.
- Une définition qui joint un type et un nom se compile en conjonction : elle demande les deux.

---

### Thème IV. Les modalités et l'abduction

#### 22. Les prémisses graduées (peut-être, probablement, traditionnellement) et « semble »

**La question.** `probable` et `traditionnel` ne sont jamais des prémisses. Peuvent-ils fonder une conclusion sous
hypothèse ? Et « elle semble pleurer » est-il une modalité, ou l'apparence de ce qui est figuré ?

**Les options.**
- **refusée :** `inconnue`. Aucune sorte d'hypothèse du protocole ne représente une prémisse graduée ;
- **admise comme hypothèse :**
  - *moteur :* une sorte d'hypothèse de plus, dans le protocole, le validateur et les preuves ;
  - *statuts :* `etablie_sous_hypotheses` ;
- **pour « semble » :** une modalité (`probable` ou `possible`), ou une apparence affirmée (`etablie`).

**Les documents.** AUDIT § 3.6 (5) (« ils pourraient fonder une conclusion sous hypothèse ») ; FS § 5 (la sorte
« prémisse graduée ») ; SPEC § 4 (H contient des « prémisses graduées ») ; QS § 2.2 (« établie seulement si
affirmée ») ; BANCS § 4 (la liste des hypothèses, sans elle). ASSERTIONS ne range pas « semble ».

**Les cas.**
- **3 DO** (mn-001, mn-002, dc-009) et 9 suiveuses, soit **12 statuts**.
- Sans DO, **65 variantes de modalité** `inconnue` disent « peut-être », « probablement », « traditionnellement » ou
  l'équivalent. C'est un majorant par mots-clés, qui compte aussi les modalités possibles.
- 27 statuts viennent d'un texte qui dit « semble » ou « appears to ».
- Exemples aussi : nr-008, rq-005, rq-014.

**Recommandation de la session de développement :** admettre l'opération pour `probable` et `traditionnel`, non pour
`possible`.
- Ajouter une sorte d'hypothèse `premisse_graduee`, réalisée avec l'abduction (TRAJ, phase 7). SPEC § 4 la compte déjà
  dans H.
- Lire « semble » comme `probable`.

#### 23. L'abduction à deux explications de même coût

**La question.** Deux explications de même coût conduisent à deux notations : deux saints au même attribut, Judith ou
Salomé, Persée ou David, « St John ». SPEC § 4 dit que l'ambiguïté est « rapportée, jamais tranchée ». Quel est alors le
statut de chaque notation ?

**Les options.**
- **chaque notation est `etablie_sous_hypotheses`,** la concurrente dans la preuve ;
- **l'ambiguïté bloque :** `inconnue`.

**Les documents.** SPEC § 4 (« Le statut : `etablie_sous_hypotheses`, avec H, les observations expliquées et les
concurrentes dans la preuve ») ; FS § 5 (« l'ambiguïté est rapportée. Elle n'est pas tranchée en silence ») ; TRAJ,
phase 7.

**Les cas.**
- **5 DO** (mn-019, pi-022, pi-014, ep-003, nr-023) et 15 suiveuses, soit **20 statuts**.
- Des questions voisines, sans DO :
  - une concurrente absente de K, et un agent inconnu comme concurrente par défaut (sa-017, co-011) ;
  - l'attestation de l'unicité d'un attribut (dc-013 à dc-016) ;
  - des explications qui se recouvrent en partie (pi-020, réglé à la révision).

**Recommandation de la session de développement :** chaque notation est `etablie_sous_hypotheses`, la concurrente dans
la preuve. C'est ce que SPEC § 4 écrit au paragraphe « Le statut ». Rapporter une ambiguïté, c'est la garder dans la
preuve, non retirer la conclusion.

#### 24. Ce qu'une abduction explique

**La question.**
- Un titre, une identification « traditionnelle », la mention d'un modèle ou une alternative du texte sont-ils des
  observations à expliquer ?
- Des éléments typiques (un soldat à l'épée, un plat) suffisent-ils à abduire un événement en cours, ici une
  décollation ?

**Les options.**
- **une observation est une assertion de l'auteur dans le contexte figuré :** le reste ne s'explique pas ;
- **toute assertion de D est une observation :** un titre ou une alternative en sont ;
- *statuts :* `inconnue` ou `etablie_sous_hypotheses`, selon l'option.

**Les documents.** FS § 5 (« une explication explique des éléments observés, des assertions de D ») ; SPEC § 4 (le
contre-exemple du portrait de mariage : « des mariés, non une noce figurée en cours »). ASSERTIONS : un titre est
« un indice, jamais une preuve ».

**Les cas.** 1 DO (mn-009) et 3 suiveuses, soit **4 statuts**. nr-002 est compté à la décision 18. Sans DO : sa-020
(« soit debout, soit assis »), rq-018 (le nom dans le seul titre), mn-003, dc-012, co-010.

**Recommandation de la session de développement :** une observation est une assertion admissible de l'auteur dans le
contexte figuré.
- Un titre, une identification traditionnelle, la mention d'un modèle ou une alternative ne sont pas expliqués. Ils
  rendent seulement une hypothèse inadmissible quand ils la nient.
- Un événement en cours ne s'abduit pas des seuls éléments typiques, comme le dit SPEC § 4.

#### 25. Le seuil d'appariement partiel

**La question.** SPEC § 3.2 exige un seuil sur les atomes satisfaits, « fixé à l'avance », sans le donner. Se compte-t-il
en atomes de la structure ou en attributs typiques ? Un attribut contraire non nié (« la tête est nue » contre
« chapeau ») compte-t-il contre ?

**Les options.** Un seuil atteint (`etablie_sous_hypotheses`) ou non (`inconnue`).

**Les documents.** SPEC § 3.2.

**Les cas.** 1 DO (dc-009) et 3 suiveuses, soit **4 statuts**.

**Recommandation de la session de développement :** fixer le seuil avant la phase 4, en atomes de la structure de
l'entrée. Un attribut contraire non nié ne compte pas contre : ce serait un monde clos. Aucune valeur n'est proposée ici.

---

### Thème V. Le temps et les éventualités

#### 26. L'ancrage temporel : en cours, imminent, accompli s'excluent-ils ? « S'apprêter à »

**La question.**
- Dans une même situation, un événement ancré « imminent » (« sur le point de frapper », la hache levée) est-il un appui
  négatif du même événement « en cours » ?
- Où passe la frontière entre la phase préparatoire et l'imminence : « s'apprête à », « about to », « sur le point
  de », le geste suspendu ?
- Un type défini par un événement accompli (martyr, veuve) vaut-il pour une mort imminente ?

**Les options.**
- **les ancrages ne s'excluent pas :** `inconnue` ;
- **ils s'excluent dans une même situation :** `ecartee` ;
- **pour la frontière :** lexicale (« s'apprête » contre « about to »), ou par la figuration.

**Les documents.** ONT § 1.2 (« Abraham s'apprête à sacrifier Isaac » est l'en cours ; « ces trois figurations ne disent
pas la même chose ») ; ONT § 2 ; FS § 2.2 et § 2.3 ; QS § 2.2 (« selon la définition »). Muet sur l'exclusion.

**Les cas.**
- **3 DO** (ee-009, co-008, co-009) et 10 suiveuses, soit **13 statuts**.
- Sans DO, **44 des 63 variantes de temps** sont `inconnue`. Le rédacteur d'`ee-` estime qu'« une bonne partie »
  passeraient à `ecartee` si les ancrages s'excluent.
- 28 descriptions disent « s'apprête », « about to », « sur le point de » ou « preparing to ».
- Exemples : ee-008 (« s'apprête à »), ee-009 (l'épée levée), dc-004#2 (une martyre qui s'avance vers le bourreau).

**Recommandation de la session de développement :** dans une même situation, les ancrages d'un même événement
s'excluent.
- Un ancrage n'a qu'une valeur par rapport au moment de la situation. Un ancrage dit « imminent » ou « antérieur » est
  donc une contrainte du texte (D31) contre « en cours ». C'est une propriété du langage, non une connaissance de K.
- « S'apprêter à » est l'en cours (ONT § 1.2) ; « sur le point de » et « about to » sont l'imminent ; le geste suspendu
  reste une question de lecture.
- Un type défini par un événement accompli ne vaut pas pour un événement imminent.
- Pour « ancien », voir la décision 29.

#### 27. Les relations entre éventualités : « avant de », « pendant que », le but, l'ordre de lecture

**La question.**
- « Il saisit le poisson avant de le vider » : l'événement à venir est-il figuré ?
- « A pendant que B » dit-il une inclusion (asymétrique) ou un recouvrement ?
- Le but (« pour le frapper ») ouvre-t-il un contexte propre ?
- L'ordre de lecture des registres (de haut en bas, de gauche à droite) est-il une connaissance typique ?
- La succession de deux situations implique-t-elle la précédence de leurs événements ?

**Les options.**
- **une lecture stricte :** aucune relation tirée de la mise en page ni de la seule coprésence ; « pendant que » comme
  simultanéité orientée ; le but dans un contexte propre ;
- **une lecture large :** l'ordre de lecture typique, un recouvrement symétrique ;
- *statuts :* `inconnue` contre `etablie` (ep-022, variante d'inversion ; ep-018).

**Les documents.** ONT § 2 (« S tient pendant E », la succession) ; AUDIT § 3.3 (4) (les contextes d'un événement :
ordonné, tenté, vu, rêvé) et § 3.5 (4) ; FS § 2.4.

**Les cas.** Aucune DO. 15 cas et 3 variantes portent `relation_entre_eventualites`. Exemples : ep-017, ep-018, ep-019 à
ep-022, ee-001, pi-004.

**Recommandation de la session de développement :** la lecture stricte.
- Aucune relation temporelle n'est tirée de la mise en page ni de la seule coprésence.
- « Pendant que » est la simultanéité de ONT § 2, orientée.
- Le but ouvre un contexte propre, comme l'ordre ou la tentative. Un événement introduit par « avant de » et non figuré
  relève de ce contexte.

#### 28. Les rôles : patient, thème, porteur ; les postures ; direction et destination

**La question.**
- La convention de rôle n'est pas écrite (AUDIT § 3.3 renvoie à `BANC_GRAPHES.md`). L'objet déplacé ou porté est-il un
  thème ? Le ressuscité, un patient ? Quel rôle porte le sujet de « wear » ?
- Les postures sont-elles des états ou des processus maintenus, et quel rôle a leur porteur ?
- Une direction (« towards heaven ») satisfait-elle une destination (« to heaven ») ? Un mouvement n'a-t-il qu'une
  destination ? Le véhicule est-il un rôle ?
- Le passif (« est couronnée ») est-il un état ou un événement ?

**Les options.** Une convention à fixer. *Statuts :* aucun aujourd'hui. Les définitions et les textes reçoivent la même
convention, et aucun des 216 cas n'a de `graphe_attendu`.

**Les documents.** AUDIT § 3.3 ; ONT § 1.2 (le porteur « a quelque chose d'un agent ») ; ONT § 6 ; FS § 3.2 (le rôle
dépend de la classe du verbe).

**Les cas.** Aucun statut. Exemples : sa-015 à sa-022, sa-003, sa-004, ee-013#3, co-023, co-024. 21 justifications
parlent de posture ou de porteur.

**Recommandation de la session de développement :** fixer la convention dans `BANC_GRAPHES.md` avant la phase 2 :
- le thème pour l'objet déplacé ou porté, le patient pour l'objet changé ;
- le porteur, distinct de l'agent, pour un état et une posture ;
- une direction ne satisfait pas une destination.

---

### Thème VI. La composition

#### 29. Les modificateurs non intersectifs : « prétendu », « ancien »

**La question.** FS § 1.2 ne connaît que deux classes : les privatifs (« faux ») et ceux de mode d'existence
(« fabuleux »). L'inventaire range « prétendu » parmi les privatifs, alors qu'un prétendu prophète peut en être un.
« Ancien évêque » : un privatif, ou un ancrage antérieur de la fonction ?

**Les options.**
- **pour « prétendu » :** privatif (`ecartee`), non engageant (ni N ni non-N : `inconnue`), ou marque d'énonciation
  (`non_certifiee`) ;
- **pour « ancien » :** privatif (`ecartee`) ; ancrage antérieur exclusif du présent (`ecartee`) ; ancrage non exclusif,
  avec une abduction par les attributs (`etablie_sous_hypotheses`) ; rien de fixé (`inconnue`) ;
- *moteur :* l'extension des modificateurs (TRAJ, phase 6, S4).

**Les documents.** FS § 1.2 (« un faux pistolet n'est pas un pistolet, dans aucun contexte ») ; AUDIT § 3.2 (4) (« un
ancien évêque n'est plus évêque » ; à défaut, le lecteur rend l'atome de type non admissible, une valeur N et non F) ;
ONT § 2.

**Les cas.** 4 DO (co-008, co-009, co-010, dc-020) et 14 suiveuses, soit **18 statuts**.

**Recommandation de la session de développement :** trois classes au lieu de deux.
- « Prétendu » et « so-called » sont non engageants : `inconnue`.
- « Ancien » n'est pas privatif : un ancien évêque l'a été. C'est un ancrage antérieur, exclusif du présent
  (décision 26). Le type est nié au moment figuré et affirmé à un moment antérieur.
- Cela donne `ecartee` pour « ancien moine » contre « moine », comme AUDIT § 3.2 le dit, et permet d'écrire une
  définition « former bishop ».

#### 30. Les adjectifs de degré et le superlatif

**La question.** « The youngest of the apostles » établit-il « young » ? Quelle est la classe de comparaison d'un
adjectif de degré (« un jeune évêque » contre « young man ») ?

**Les options.**
- **le superlatif n'implique pas le positif :** `inconnue` ;
- **une connaissance typique superlatif ⇒ positif :** `etablie_sous_hypotheses`.

**Les documents.** ONT § 6 (« relatives à une classe de comparaison ») ; FS § 8. Aucune sorte de connaissance n'est
prévue.

**Les cas.** 2 DO (co-002, nr-018) et 7 suiveuses, soit **9 statuts**. nr-018 dépend aussi de la décision 7.

**Recommandation de la session de développement :** le superlatif relatif n'implique pas le positif (le plus jeune des
vieillards n'est pas jeune). La classe de comparaison est celle du nom tête de la description. L'exclusion entre jeune
et vieux relève des incompatibilités (décision 7), à classe égale.

#### 31. Les composés et leur relation implicite

**La question.**
- La relation implicite d'un composé (« gold crown » : la matière) est-elle typique ou attestée, et par quoi ?
- Une unité lexicalisée de WordNet (crown_of_thorns, young_man) se lit-elle comme ce lemme, ou par la construction
  (« N de N », « homme » et « jeune ») ?
- « Un ange de marbre » : un ange de matière marbre, ou une statue ?
- Le champ `attestee` d'une connaissance typique dit-il « attestée comme typique » ou « attestée comme vraie » ?

**Les options.**
- **le lemme lexicalisé, des deux côtés :** pour dc-024#1, `inconnue`, puisque « jeune homme » est absent de WOLF ;
- **la construction :** dc-024#1 devient `etablie_sous_hypotheses` ;
- **la relation implicite :** une connaissance typique (`etablie_sous_hypotheses`), ou une relation attestée (`etablie`).

**Les documents.** FS § 3.2 (« le composé nominal et une propriété : sa relation implicite n'est pas une propriété » ;
l'exigence de symétrie) ; FS § 8 (les relations implicites couvrent mal le français) ; AUDIT § 3.2 (3) ; SPEC § 1.

**Les cas.** 3 DO (co-014, dc-018, dc-024#1) et 7 suiveuses, soit **10 statuts**. co-014 et dc-018 dépendent aussi de
la décision 13. Sans effet sur le statut : co-011, co-012, co-013, ep-011.

**Recommandation de la session de développement :**
- Une unité lexicalisée se lit comme ce lemme, des deux côtés, avec tous ses sens. C'est l'exigence de symétrie de FS
  § 3.2.
- La relation implicite d'un composé non lexicalisé est une connaissance typique.
- Pour une connaissance typique, `attestee` dit qu'une ressource nommée la donne pour typique : c'est sa provenance,
  non sa vérité (FS § 2.7).
- La statue et le décor relèvent de la décision 13.

#### 32. Les listes « e.g. » et le pluriel d'un libellé

**La question.** « Musical instruments, e.g. lute, viol » : une chalemie, absente de la liste, satisfait-elle la
définition ? Un pluriel de libellé (« instruments ») demande-t-il deux membres ?

**Les options.**
- **pour « e.g. » :** une liste fermée (`inconnue`), ou ouverte, le terme général pour seule condition (`etablie`) ;
- **pour le pluriel :** un membre suffit (`etablie`), ou deux (`etablie_sous_hypotheses`, la lecture retenue).

**Les documents.** FS § 3.2 (« l'énumération et la disjonction : une affaire de type de libellé ») ; FS § 2.6 (les
collections dites, non le pluriel d'un libellé).

**Les cas.** 1 DO (co-019), qui porte sur le cas et sur sa variante #3.

**Recommandation de la session de développement :** « e.g. » donne le terme général pour seule condition : la liste est
faite d'exemples. Le pluriel reste sans recommandation : il dépend de la pratique de classement, que les bancs ne
connaissent pas.

#### 33. Les alternatives : le raisonnement par cas

**La question.** « Either a monk or a nun » : chaque branche satisfait la définition « hermit, monk or nun ». NOYAU § 1
exclut des prémisses les assertions sous alternative. Le raisonnement par cas est-il admis ?

**Les options.**
- **non :** `inconnue` ;
- **oui :** l'option écrite par co-018 (`etablie_sous_hypotheses`).

**Les documents.** NOYAU § 1 (« hors de toute alternative ») ; NOYAU § 4.2 ; muets : FS, SPEC.

**Les cas.** co-018#4, par la DO de son cas. Voisins : sa-020, mn-019 (une alternative énoncée par le texte).

**Recommandation de la session de développement :** l'admettre quand chaque branche d'une alternative de l'auteur
satisfait la définition. C'est le principe de la supervaluation, une conclusion commune à toutes les lectures (NOYAU
§ 2), que les décisions 38 et 39 reprennent. Une hypothèse qui choisit une branche n'explique rien : sa-020 reste
`inconnue`.

#### 34. « Portrait de X en Y »

**La question.** Dans un portrait historié, Y est-il le personnage figuré, ou un rôle que la figure joue ? NOYAU § 1 n'a
pas de relation « figure X sous les traits de Y ».

**Les options.**
- **Y désigne le personnage figuré :** `etablie` ;
- **Y n'est qu'un rôle :** il reste l'identification par les attributs, `etablie_sous_hypotheses`.

**Les documents.** FS § 1.2 (« sous la figuration, un nom désigne le personnage figuré ») ; NOYAU § 1. Aucun document ne
décrit le portrait historié.

**Les cas.** 1 DO (dc-019) et 3 suiveuses, soit **4 statuts**.

**Recommandation de la session de développement :** Y désigne le personnage figuré, et X le modèle, par une relation de
l'œuvre à une personne réelle, comme pour un portrait. Les deux ne sont pas en concurrence : ce sont deux relations
différentes, non deux identités.

---

### Thème VII. L'espace et les parties

#### 35. Les rôles et les relations comme concepts de la lecture ; la table des prépositions

**La question.** La règle provisoire (§ 4.1, point 2, dernier alinéa) fait des rôles et des relations des concepts du
langage d'assertions, produits par la lecture, hors de K. FS § 2.4 dit au contraire que « K ordonne les sens des
prépositions comme ceux des noms ». Quelle règle, et avec quelle table (de, of, sur, on, pour, pendant que, sa, with) ?

**Les options.**
- **la règle provisoire :** une préposition polysémique donne plusieurs lectures, et l'hypothèse `sens` quand l'atome en
  dépend ;
- **des mots de K soumis à D30 :** avant cette règle, la révision de `ep-` avait conclu que deux mots de relation
  différents ne donnent aucun lien. Une vingtaine de statuts y étaient passés à `inconnue` (ep-004, ep-011, ep-015,
  ep-022, et d'autres variantes), puis sont remontés.

**Les documents.** FS § 2.4 ; AUDIT § 3.5 (3) (« le mot de la relation devient un concept […] que K hiérarchise ») ;
BANCS § 4.1, point 2 ; AUDIT § 3.5 (3) encore (« Aujourd'hui chaque préposition est son propre sens (D20) »).

**Les cas.** 3 DO (ep-004, ep-015, nr-008) et 9 suiveuses, soit **12 statuts**. Exemples aussi : ep-011, ep-013,
rq-019.

**Recommandation de la session de développement :** garder la règle provisoire, et la compléter par une table écrite.
- La table va de la préposition aux concepts (partie_de, possession, matière, représentation, position), en français
  et en anglais, avec sa polysémie.
- La hiérarchie entre concepts de relation va dans K, ce qui accorde FS § 2.4 et AUDIT § 3.5.
- La table se fait en phase 2 ; la lecture la produit en phase 8.

#### 36. Le cadre de référence : la gauche et la droite

**La question.** « À droite », sans point de référence, sur un tympan à Christ frontal : la droite du spectateur ou celle
du Christ ? La latéralité d'une partie du corps (« sa main gauche ») est-elle toujours intrinsèque ? Devant et derrière
posent la même question.

**Les options.** Le cadre du spectateur (`inconnue` dans ep-009), ou celui de la figure principale
(`etablie_sous_hypotheses`). Ou bien l'ambiguïté de cadre est une polysémie, sous D30.

**Les documents.** AUDIT § 3.5 (3) (« la gauche du spectateur ou celle du personnage ») ; BANCS § 4.1 (« reste une
question ouverte »).

**Les cas.** 2 DO (ep-008, ep-009) et 6 suiveuses, soit **8 statuts**. Exemples aussi : ep-010, dc-015 (« to her
right »), nr-001.

**Recommandation de la session de développement :**
- « À droite de X », X une figure, se lit dans le cadre de X.
- « À droite » sans point de référence est une position dans l'image : une relation de l'œuvre, non du figuré.
- La latéralité d'une partie du corps est intrinsèque.

#### 37. Partie et tout

**La question.**
- Un rôle passe-t-il de la partie au tout (la foudre frappe le grand mât : le navire est-il frappé ?), ou d'un objet
  porté à la partie qui le porte (elle baise l'anneau : baise-t-elle la main ?) ?
- Le tout d'une partie figurée seule (la main de Dieu sort d'un nuage) est-il présent, et reçoit-il l'agent ?
- Une partie facultative détachée (une roue contre un mur) appelle-t-elle un tout supposé ?
- La possession inaliénable (« lui tranche la tête ») est-elle une relation de partie ?

**Les options.**
- **aucun transfert sans une règle de K ;** le tout impliqué n'est pas présent : `inconnue` ;
- **le tout est présent par sa partie** et reçoit l'agent : `etablie_sous_hypotheses` ;
- **un tout supposé par abduction typique,** l'ambiguïté rapportée : `etablie_sous_hypotheses`.

**Les documents.** FS § 2.4 (« impliqué si la partie est obligatoire, supposé sinon ») ; FS § 3.4 (« une partie n'est
pas son tout ») ; SPEC § 2 (la partie obligatoire) ; AUDIT § 3.5 (5).

**Les cas.** 2 DO (ep-003, ep-014) et 6 suiveuses, soit **8 statuts**. 13 statuts portent
`consequence_conditionnelle`, surtout pour l'obligation d'une partie (ep-001). Exemples aussi : ep-002, ep-016,
nr-011.

**Recommandation de la session de développement :**
- Aucun rôle ne passe de la partie au tout sans une règle de K, d'une sorte dirigée à ajouter avec celles de la phase 5.
- Le tout d'une partie figurée seule est impliqué, non présent, et ne reçoit pas de rôle.
- Une partie détachée n'appelle un tout supposé que si ce tout explique une observation (SPEC § 4).

---

### Thème VIII. La référence et la quantification

#### 38. Distributif et collectif

**La question.** « Two angels crown her » satisfait-il « crowned by angels », vrai dans les deux lectures ? Le choix de
la lecture distributive d'un pluriel ambigu est-il une hypothèse, et de quelle sorte ? La distributivité d'un prédicat
(dormir, être assis) vient-elle de K ou du verbe ?

**Les options.**
- **la supervaluation sur les lectures :** une conclusion vraie dans les deux lectures est établie (rq-010 : `etablie`) ;
- **l'ambiguïté bloque :** `inconnue` ;
- **une lecture supposée comme hypothèse :** `etablie_sous_hypotheses` (rq-011). Aucune sorte d'hypothèse ne la nomme.

**Les documents.** FS § 2.6 (« le cas indécidé, qui reste une ambiguïté et n'est pas résolu par défaut ») ; NOYAU § 2
(D30, pour les seuls sens) ; AUDIT § 3.4 (2).

**Les cas.** 3 DO (rq-010, rq-011, co-019 pour son pluriel) et 6 suiveuses, soit **9 statuts**. 13 cas portent
`collection`. Les rédacteurs de `rq-` y voient « la question la plus lourde de la famille : toute phrase plurielle non
marquée en dépend ».

**Recommandation de la session de développement :** la supervaluation sur les lectures.
- Une conclusion vraie dans toutes les lectures est établie. Ce n'est pas résoudre l'ambiguïté par défaut : c'est le
  principe de D30.
- Une conclusion vraie dans une seule lecture reste `inconnue`, tant que la lecture ne produit pas d'hypothèse nommée
  (TRAJ, phase 8).
- La distributivité d'un prédicat vient de la sorte de son éventualité, dans K, non de la syntaxe.

#### 39. Ambiguïtés de structure : pronom, rattachement, portée

**La question.** Un pronom à deux antécédents, un participe détaché (« le bénissant »), une relative qui peut porter sur
deux noms, la portée de « perhaps » dans une coordination, un complément partagé : une ambiguïté de structure donne-t-elle
une alternative, une lecture préférée par la norme, ou une hypothèse nommée ? Aucune sorte d'hypothèse ne la représente.

**Les options.**
- **une alternative :** `inconnue` ;
- **une lecture préférée** (le nom tête, le sujet) : `etablie` ;
- **une hypothèse de lecture nommée,** ou `identite` pour le pronom : `etablie_sous_hypotheses`.

**Les documents.** NOYAU § 1 (C9 : « La coréférence possible n'est pas dans le graphe ») ; BANCS § 4 (la liste des
hypothèses) ; FS § 8 (« les rôles des participes »).

**Les cas.** 3 DO (sa-010, sa-011, rq-002) et 8 suiveuses, soit **11 statuts**. Exemples aussi : sa-014, co-017,
rq-004#6.

**Recommandation de la session de développement :** une alternative, `inconnue`, avec la supervaluation de la
décision 38 quand toutes les lectures satisfont la définition. Une hypothèse de lecture nommée serait une extension de la
lecture (phase 8), à décider avec celle des sens.

#### 40. « Seul », « tous », « tous sauf » : l'audit et les fondements se contredisent

**La question.**
- AUDIT § 3.4 (4) dit que « seul », « tous » et « aucun autre » ne demandent pas d'extension : la propriété `seul`, le
  nombre ou une négation dite suffisent. FS § 2.6 et § 7 comptent les quantifications énoncées parmi ce qui doit
  changer, sur une collection et un domaine.
- Quel est le domaine par défaut : la scène, l'œuvre, la marge ?
- « Tous sauf X » affirme-t-il que X n'a pas la propriété ?
- « Seul avec son lion » : un exclusif quantifie-t-il sur les personnes ou sur toutes les figures ?

**Les options.**
- **l'audit :** pas d'extension ; « Judith et Holopherne seuls » ne s'écrit pas comme une solitude conjointe ;
- **les fondements :** l'extension `quantification_enoncee` (S5) ;
- **pour l'exception :** elle nie la propriété de X (`ecartee` possible), ou retire seulement X du domaine (`inconnue`).

**Les documents.** AUDIT § 3.4 (4) et la proposition 1 (§ 2) ; FS § 2.6 et § 7 ; BANCS § 4 (« représentée comme une
assertion du texte »).

**Les cas.** Aucune DO. 5 cas portent `quantification_enoncee` : dc-007, rq-011, rq-021, rq-023, rq-024. Exemples :
rq-021#5 (une troisième personne contre « alone » : `contradictoire`), rq-022#4 (« seul avec son lion », hypothèse
`sens`). « Tous sauf » n'est employé par aucun cas : les rédacteurs l'ont évité.

**Recommandation de la session de développement :** suivre les fondements, qui fixent la sémantique cible (BANCS § 1).
- Une quantification énoncée est une assertion sur une collection et un domaine.
- Le domaine par défaut est la situation figurée.
- L'audit reste juste pour un « seul » qui porte sur un individu.
- L'exception ne reçoit pas de recommandation : aucun cas n'en dépend.

---

### Les questions que la révision tient pour réglées par les documents, à confirmer

La révision a retiré ou refusé ces `decision_ouverte`. La propriétaire peut confirmer ou rouvrir chacune.
- **dc-007 :** une condition nécessaire satisfaite ne propose pas d'abduction (FS § 2.7 : « jamais pour
  l'établissement » ; SPEC § 3.1, § 4). `inconnue`.
- **rq-017 :** l'identité Minerva = Athena, tirée de « counterpart of », n'explique aucune observation et est
  inadmissible (SPEC § 4). `inconnue`.
- **mn-003 :** l'abduction par une connaissance typique est fixée par SPEC § 4, et l'identification traditionnelle n'est
  pas une concurrente. `etablie_sous_hypotheses`.
- **rq-014 :** « the twelve apostles » demande le nombre exact du groupe (FS § 2.6 : « exactement n »). « Au moins k »
  n'est qu'une approximation du langage actuel. `ecartee`. La relecture B tenait la question pour ouverte.
- **sa-007#5, sa-016#4 :** « s'apprêter à » est l'en cours (ONT § 1.2). `etablie_sous_hypotheses`.
- **pi-020 :** une concurrente qui n'explique pas les mêmes observations n'est pas une concurrente (SPEC § 4). Elle est
  retirée. `etablie_sous_hypotheses`.
- **rq-003#4 :** un marché passé avant l'œuvre est un fait de l'histoire, non une source sur l'image. `inconnue`. La
  relecture B proposait `non_certifiee`.
- **ep-012#3, rq-019#1, nr-005#3 :** le même mot des deux côtés (un distributif dit, « of », « death ») ne demande aucun
  choix de sens.

### Les questions relevées sans cas dont le statut dépende

Elles n'ont pas la forme d'une décision, faute de cas. Elles se poseront avec l'extension qui les touche.
- **le mode d'existence et les notations d'animaux réels :** un lynx fabuleux satisfait-il « lynx » ? Est-ce la
  convention sur les sœurs (FS § 2.6) qui l'exclut ? Aucun cas n'a été écrit (questions de `co-`, A6) ;
- **le passif d'état et le passif d'action** (« la Vierge est couronnée ») ; **le participe** d'un verbe à la fois
  transitif et pronominal (« desséché ») ; **le participe d'un inergatif** (« ayant dansé ») ;
- **la matière de l'œuvre et la matière figurée**, pour une sculpture (co-013) ;
- **le possessif et la parenté** (« sa fillette » n'est pas « her daughter », co-015#3) ;
- **un titre privatif** (« Le Faux Prophète », co-010) : rend-il l'hypothèse de type non admissible ?
- **un nom propre homographe d'un concept** (« Prudence Maréchal », nr-020), et **le concept d'une personnification** :
  un lemme ou un sens (nr-016 à nr-024) ;
- **le genre des noms propres** (Holofernes n'est pas, par l'hyperonymie, un homme, pi-021) ;
- **le niveau iconologique** porté par un cadre ou une devise (pi-020, variante), et la concurrence entre une raison
  matérielle donnée par le texte et un symbole (nr-023) ;
- **le miroir et l'identification par le contexte narratif :** dans l'inventaire, sans construction de développement.

## 3. Les questions de méthode des bancs

Elles ne sont pas sémantiques. Elles décident pourtant de ce que les bancs mesureront.

### 3.1 La relation « traduction : même statut », violée par K

**Le constat.** QS § 2.2 attend le même statut pour une traduction.
- **64 traductions sur 216** ont un autre statut, et dans 63 d'entre elles le côté français est plus faible
  (décision 3).
- **16 autres** ont le même statut, mais d'autres hypothèses.
- **4 paraphrases sur 214** changent aussi de statut, pour la même cause : une équivalence que K n'atteste pas
  (ee-006 et ee-011 l'ont signalé).
- L'écart vient de K : les lacunes et la polysémie de WOLF, les alias non attestés. Il ne vient ni de la sémantique ni
  du moteur.

**Les options.**
- l'invariance stricte : réécrire les cas pour que K soit symétrique ;
- une invariance relative à K : la traduction mesure aussi la couverture lexicale ;
- une invariance mesurée sous `sens_fixe_par_le_contexte` seulement.

**Recommandation de la session de développement :** une invariance relative à K.
- Chaque traduction de statut différent devrait dire sa cause (un mot absent de WOLF, un alias non attesté), dans un
  champ.
- La mesure métamorphique ne la compterait pas comme une erreur, mais comme une couverture lexicale.

### 3.2 La sorte d'un cas quand K change son statut

**Le constat.** La sorte d'un cas de base dit l'intention du rédacteur ; son statut dit ce que K permet.
- 66 des 95 positifs ne sont pas `etablie` : 64 sont `etablie_sous_hypotheses`, 2 sont `inconnue`.
- 62 des 67 négatifs et contre-modèles ne sont pas `ecartee` : 61 sont `inconnue`, et co-015 est
  `etablie_sous_hypotheses`.
- Les familles ont classé différemment un cas sous hypothèses : `positif` ou `indetermine`, selon la famille. Un cas
  `contradictoire` n'a pas de sorte (dc-006, variante).

**Les options.** La sorte suit l'intention, ou la sorte suit le statut.

**Recommandation de la session de développement :** la sorte suit l'intention, comme la révision de `co-` l'a fait.
L'écart entre l'intention et le statut est ce que le jugement humain d'un échantillon (D23) doit voir. Les quotas du § 5
se comptent alors sur l'intention.

### 3.3 Les définitions réécrites et les textes adaptés aux trous de WOLF

**Le constat.** La révision a réécrit des définitions, surtout pour retirer une connaissance fausse relevée par une
relecture. L'harmonisation a interdit de réécrire une définition avec les mots du texte, et en a rétabli une partie.
Il reste :
- **des définitions réécrites, gardées :**
  - **mn-** : mn-001, mn-004, mn-010, mn-011, mn-014, mn-015, mn-016 (mn-021 et mn-024 sont rétablies) ;
  - **pi-** : pi-001, pi-002, pi-005, pi-008, pi-013, pi-017, pi-019, pi-021, pi-024 ;
  - **co-** : co-001, co-008, co-009, co-015, co-016, co-017, co-021, co-022, co-023 (co-010 est rétablie) ;
  - **sa-** : sa-010, sa-012, sa-016, sa-020 (sa-001 est rétablie) ;
  - **rq-** : rq-002, rq-006, rq-009, rq-011, rq-012, rq-015, rq-016, rq-023, rq-024 ;
  - **ep-** : ep-005, ep-012, ep-014, ep-015 ;
  - **dc-** : dc-007 (« in the desert »), dc-015 (« to her right ») ;
  - **nr-** : nr-001 (« beside them » retiré) ;
  - **ee-** : aucune. Toutes les réécritures ont été rétablies : ee-001, ee-004, ee-010, ee-017, ee-018, ee-019 ;
- **des variantes rédigées en anglais dans un cas français,** faute de mots dans WOLF ou pour garder un lien de même
  lemme : dc-004#2, dc-012#2, mn-003#6, mn-016#7, nr-003#3, nr-017#5, pi-005#6, rq-002#8, rq-002#9, rq-023#7 ;
- **des cas dont la langue de base a changé :** co-001 et co-007 passent en anglais (« filer », « pommelé ») ; co-002 et
  co-020 passent en français, pour l'équilibre ; sa-011 passe en anglais (« cruche », « pichet », « broc » sans lien
  vers jug) ;
- **des mots français remplacés dans les textes :**
  - en `pi-` : songe → rêve, larron → voleur, festoyer → banqueter, fugacité → brièveté, pupitre → bureau, cabinet de
    travail → bureau, couché → étendu, tendu de → suspendu, la locution de « signifier » → le verbe ;
  - ailleurs : desséché → flétri (co-021), haranguer → prêche (co-010), bourreaux → tortionnaires (ee-010),
    Gaulish → Gallic (ee-016#1), Tobie → Samson (ep-017), sortant → émergeant (sa-006#1), couronne → guirlande
    (sa-017#1) ;
- **des variantes ajoutées sur des mots à un seul sens,** pour garder une variante `ecartee` : ep-007#7 (s'agenouiller),
  ep-015#7 (décapiter), ep-022#7 (tombeau), et des noms niés (pi-005#6, pi-014#6, pi-022#7, rq-004#7).

**La question.** Ces réécritures retirent des pas lexicaux que les cas ne testaient pas, d'après leurs auteurs. Elles
rendent aussi le banc plus facile qu'un texte réel. Faut-il les garder ?

**Recommandation de la session de développement :** les garder, et les lister dans le protocole comme « définitions
alignées ». La propriétaire en juge un échantillon (D23). La mesure des pas lexicaux ne doit pas compter ces cas comme
des pas réussis.

### 3.4 Les cas sans variante de statut différent

**Le constat.** BANCS § 4 demande au moins une variante de statut différent « : un changement de portée, de modalité ou
de temps, ou une inversion des rôles ».
- 12 cas n'en ont aucune de ces quatre variations : co-004, co-012, dc-021, dc-022, ep-009, mn-006, nr-018, rq-006,
  rq-013, rq-017, rq-019, rq-022.
- **ep-009** n'a aucune variante de statut différent, de quelque variation que ce soit.
- La cause est la même partout. Un cas `inconnue` faute de structure ne remonte par aucune portée, modalité ou temps.
  Une négation qui l'aurait abaissé n'est plus `ecartee` sous D30. Les révisions de `dc-` et `ep-` l'ont dit.
- La révision de `co-` lit la liste après les deux-points comme des exemples ; d'autres la lisent comme fermée.

**Recommandation de la session de développement :** admettre un changement de participant ou une composition comme
variante de statut différent, quand le cas est `inconnue` faute de structure. Exiger toujours au moins une variante de
statut différent, et donc reprendre ep-009.

### 3.5 Le déséquilibre des statuts

**Le constat, après l'harmonisation :**

| statut | cas de base | variantes |
|---|---|---|
| `inconnue` | 112 (52 %) | 788 (61 %) |
| `etablie_sous_hypotheses` | 67 (31 %) | 286 (22 %) |
| `etablie` | 29 (13 %) | 148 (12 %) |
| `ecartee` | 5 (2 %) | 33 (3 %) |
| `non_certifiee` | 3 (1 %) | 29 (2 %) |
| `contradictoire` | 0 | 2 |

- Les cas `etablie` de base, par famille : 1 en `dc-`, `ee-` et `nr-` ; 3 en `ep-` et `mn-` ; 4 en `pi-` ; 5 en `co-` et
  `rq-` ; 6 en `sa-`.
- Les 5 `ecartee` de base ne dépendent d'aucune négation d'un mot polysémique : un mot à un sens (co-007, dc-006), une
  distinction dite (pi-002), un nom nié (pi-024), un nombre (rq-014).
- La cause principale est la décision 1 : sous `tous_les_sens`, une négation d'un mot courant ne réfute rien, et un
  mot français courant ne donne qu'une hypothèse.
- Chaque `decision_ouverte` garde l'autre statut : la répartition sous chaque option est donc calculable.

**Recommandation de la session de développement :** ne pas ajouter de cas pour rééquilibrer avant les décisions 1 à 3.
Recalculer la répartition sous les options choisies, puis juger si les quotas de sortes du § 5 suffisent, ou s'il faut
des quotas de statuts.

### 3.6 La forme des `decision_ouverte`

**Le constat.**
- **18 `decision_ouverte` sont sans effet :** toutes leurs options donnent le même statut. Ce sont co-004, co-008#3,
  co-013, co-020, co-022, co-024, dc-005#7, ep-001, ep-011, ep-013#2, ep-019#2, ep-022, ee-001#3, ee-002#4, mn-005#2,
  mn-007, mn-011, pi-005#3. Plusieurs ne disent que « la base ne dépend d'aucun sens ».
- **Une `decision_ouverte` de cas porte parfois sur ses variantes,** par des options marquées « #n » : co-001, co-006,
  co-011, co-016, co-017, co-018, co-023. Le validateur n'accepte qu'une `decision_ouverte` par cas ou par variante.
- **Plusieurs questions dans une seule `decision_ouverte` :** les options combinent un alias et un sens (rq-003, rq-016,
  rq-024, pi-001, pi-017, nr-013), ou un rattachement et un sens (sa-010).

**Recommandation de la session de développement :**
- retirer les `decision_ouverte` sans effet ;
- admettre une liste de `decision_ouverte`, chacune nommant la décision de ce document dont elle dépend ;
- reporter sur la variante une option marquée « #n ».
Trancher se ferait alors décision par décision, mécaniquement.

### 3.7 Ce qui ne désigne pas sa phase

**Le constat.** Une phase désigne ses cas par `operations_requises` et `extensions_requises` (BANCS § 7). Certains
statuts dépendent d'un changement qu'aucun nom de la liste ne désigne :
- la levée de D41 (décision 6) ;
- les prémisses graduées (décision 22) ;
- l'incompatibilité (décision 7) ;
- la supervaluation sur les lectures (décision 38).
Ces cas portent `aucune`, et aucune phase ne les fera passer. Pour pi-014, le statut retenu ne demande aucune extension,
mais l'autre option en demande : la règle « ce sans quoi le statut ne peut pas être atteint » ne dit pas laquelle des
options compte.

**Recommandation de la session de développement :** ajouter un nom pour chacun de ces changements dans la liste du
validateur. Pour une `decision_ouverte`, déclarer les extensions de chaque option.

### 3.8 Les variations sans nom, et le pivot

**Le constat.**
- **Des variantes n'ont pas de variation qui leur convienne :** lever une ambiguïté, ajouter un indice (un nom, un
  attribut), changer un modificateur, ajouter ou retirer une condition, changer la structure des situations. Elles sont
  rangées en `composition` ou en `changement_de_participant`.
- **Une ré-inversion** (dc-022#2, quand le cas de base est déjà inversé) n'a pas de relation métamorphique juste.
- **Une figure « non liée »** qui devient un second antécédent ou contredit « alone » (rq-004#6, rq-021#5) n'est pas
  non liée.
- **Le pivot** n'a pas de règle pour une relation (une préposition sans entrée WordNet), une modalité (l'opérateur ou le
  mot qualifié), un participe (le verbe ou l'adjectif lexicalisé) ou un composé lexicalisé (le composé ou sa tête).
  L'axe des familles lexicales n'y mesure pas la même chose d'un rédacteur à l'autre.

**Recommandation de la session de développement :**
- ajouter les variations `desambiguisation` et `ajout_d_indice`, de relation « écrite au cas par cas » ;
- donner à la ré-inversion la relation « même statut que le cas non inversé » ;
- écrire la règle du pivot : le mot de contenu sur lequel porte le phénomène, jamais l'opérateur.

## 4. Le tableau récapitulatif

Les statuts concernés : DO et suiveuses (section 1). « — » : aucune DO ; la ligne donne alors ce qui en dépend autrement.
La phase est celle de `docs/TRAJECTOIRE.md` que la décision conditionne ; « Sn » est le rang de spécification.

| n° | décision | statuts concernés | exemples | phase | spécification |
|---|---|---|---|---|---|
| 1 | régime des sens (D30 contre X7) | 269 (125 DO) ; 311 portent `sens` | sa-001, sa-002, ee-003 | 2 (limite), 8 (X7) | S6 |
| 2 | type lemme ou sens de la définition | jusqu'à 177 `etablie` | ee-011#3, mn-021 | 4 | S7 |
| 3 | sens français : WOLF | 63 traductions plus faibles ; 16 (8 DO) | dc-013#1, nr-019#1 | 2 (K) | S6 |
| 4 | contenu et attestation de K | 24 (7 DO) ; 13 `consequence_conditionnelle` | dc-001, nr-017#1, ee-001 | 4, 5 | S7 |
| 5 | alias entre langues, noms partiels | 28 (11 DO) ; 54 `identite` | pi-001, rq-024, pi-014 | 2 (K), 7 | S8 |
| 6 | négation d'une description entière (D41) | 7 `ecartee` ; 16 sous l'autre option du 1 | sa-004#3, mn-005 | 3 (noyau 0.4) | — |
| 7 | incompatibilités, antonymie | 30 (11 DO) | sa-022, nr-018, ee-024#3 | 5 | S6 |
| 8 | contraposition, prémisses négatives | 14 (4 DO) | sa-024, dc-005 | 4, 5 | S6, S7 |
| 9 | exclusions analytiques, rôle inversé | — ; 50 inversions `inconnue` | ep-005, ep-017 | 2, 5 | S6 |
| 10 | négations impliquées | 8 (2 DO) | dc-016, nr-006 | 8 | — |
| 11 | portée de `non/1`, rôle nié seul | 4 (1 DO) | mn-016, sa-008 | 3 | — |
| 12 | négation vers un concept | 2 (2 DO) | nr-016#2, pi-019#5 | 6 | S2 |
| 13 | satisfaction à travers un emboîtement | 30 (7 DO) | pi-007, ee-023, mn-022 | 6 | S2 |
| 14 | satisfaction relative à une situation | 13 (3 DO) | ee-019, pi-005 | 6 | S1, S3 |
| 15 | identité entre situations | 4 (1 DO) | pi-003, pi-001 | 6 (différé) | S3 |
| 16 | « selon » : source citée ou portée « source » | 12 (3 DO) ; 26 `non_certifiee` | nr-024, ep-021 | 6, 8 | S2 |
| 17 | auteur contre source, ordre de sûreté | 2 (2 DO) | mn-012#3, ee-021#4 | 6 | S2 |
| 18 | copie et « d'après » | 4 (1 DO) | nr-002 | 6, 7 | S2, S8 |
| 19 | état de conservation | 5 (2 DO) | nr-012, nr-013#5 | 6 | S2 |
| 20 | inscriptions, titres, étiquettes | 4 (1 DO) ; 13 `contenu_d_inscription` | dc-014, pi-017 | différé ; 6 | S2 |
| 21 | désignation, source, histoire | 5 (1 DO) | dc-005, dc-004, pi-021 | 4 | S4, S7 |
| 22 | prémisses graduées, « semble » | 12 (3 DO) ; jusqu'à 65 variantes | mn-001, mn-002 | 7 | S8 |
| 23 | abduction à deux explications de même coût | 20 (5 DO) | mn-019, pi-022, pi-014 | 7 | S8 |
| 24 | ce qu'une abduction explique | 4 (1 DO) | mn-009, sa-020 | 7 | S8 |
| 25 | seuil d'appariement partiel | 4 (1 DO) | dc-009 | 4 | S7 |
| 26 | ancrage temporel, « s'apprêter à » | 13 (3 DO) ; jusqu'à 44 variantes | ee-009, ee-008 | 6 | S3 |
| 27 | relations entre éventualités | — ; 18 `relation_entre_eventualites` | ep-018, ep-022 | 6 | S3 |
| 28 | rôles, postures, direction | 0 | sa-015, sa-019 | 2 (convention), 8 | S1 |
| 29 | « prétendu », « ancien » | 18 (4 DO) | co-008, co-010, dc-020 | 6 | S4 |
| 30 | adjectifs de degré, superlatif | 9 (2 DO) | co-002, nr-018 | 6 | S1, S4 |
| 31 | composés, relation implicite | 10 (3 DO) | co-014, dc-024#1 | 2, 7 | S6 |
| 32 | listes « e.g. », pluriel d'un libellé | 2 (1 DO) | co-019 | 4 | S7 |
| 33 | raisonnement par cas | 1 (1 DO) | co-018#4 | 3 (noyau 0.4) | S6 |
| 34 | « portrait de X en Y » | 4 (1 DO) | dc-019 | 4 | S7 |
| 35 | rôles et relations hors K, table des prépositions | 12 (3 DO) | ep-004, ep-015, nr-008 | 2, 8 | S6 |
| 36 | cadre de référence | 8 (2 DO) | ep-008, ep-009 | 8 | S6 |
| 37 | partie et tout | 8 (2 DO) | ep-014, ep-003 | 5 | S6 |
| 38 | distributif et collectif | 9 (3 DO) ; 13 `collection` | rq-010, rq-011 | 6 | S5 |
| 39 | ambiguïtés de structure | 11 (3 DO) | sa-010, rq-002 | 8 | — |
| 40 | « seul », « tous », « tous sauf » | — ; 5 `quantification_enoncee` | rq-021, rq-022 | 6 | S5 |

Les décisions de méthode (section 3) conditionnent la mesure de la phase 1 elle-même et la qualification (phase 9).
