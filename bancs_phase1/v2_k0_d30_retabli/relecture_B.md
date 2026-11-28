# Relecture B : référence et quantification, espace, partie et temps, modalités et contextes

**Ce que j'ai relu :** les familles `reference_quantification` (rq), `espace_partie_temps` (ep) et
`modalite_negation_contextes` (mn), et leurs fichiers `.questions.md`. Je les ai relues contre `docs/BANCS_PHASE1.md`
(§ 4 surtout), `docs/FONDEMENTS_SEMANTIQUES.md` (FS), `docs/ONTOLOGIE_EVENTUALITES.md` (ONT),
`docs/SPECIFICATION_OPERATIONS.md` (SPEC), `docs/NOYAU.md` (§ 1, § 2 et § 4.4) et `docs/QUALIFICATION_SEMANTIQUE.md`
§ 2 (QS).

**Ce que je n'ai pas fait :**
- je n'ai modifié aucun cas ;
- je n'ai lu ni code, ni sortie du système, ni inventaire ou répartition, ni autre relecture.

**WordNet :** je l'ai consulté par `sens.py` et par les fichiers `data.*`.

**Les règles de cette relecture :**
- je ne tranche aucun désaccord : je les liste ;
- « ouvert » veut dire que, selon moi, les documents ne fixent pas le statut ;
- une erreur de sûreté suit la définition du protocole (§ 7) : un statut plus fort que ce que les documents et le K du
  cas justifient.

## 1. Le résumé chiffré

### 1.1 Ce que j'ai relu

| famille | cas de base | variantes | `decision_ouverte` |
|---|---|---|---|
| reference_quantification | 24 | 152 | 4 |
| espace_partie_temps | 24 | 138 | 4 |
| modalite_negation_contextes | 24 | 124 | 5 |
| **total** | **72** | **414** | **13** |

### 1.2 Les désaccords, par gravité

Une ligne du tableau peut porter sur plusieurs variantes d'un cas, ou sur plusieurs cas quand le motif est le même.

| gravité | lignes | cas ou variantes touchés (environ) |
|---|---|---|
| sûreté | 26 (dont 2 faibles : un écart lexical ou un sens laissé ouvert) | environ 95 statuts, dont une ligne systémique de 14 cas (D30 sur la négation) |
| trop faible | 2 | 5 |
| connaissance non fondée | 6 | plus de 25 cas, surtout en ep |
| incohérence | 5 | 10 |
| décision ouverte mal posée | 3 | 9 |
| qualité | 3 | 14 |
| **total** | **45** | |

### 1.3 L'échantillon WordNet (point 4 de la consigne)

Les cas déclarent 77 connaissances, dont 67 `attestee: true`. Parmi elles, environ 25 annoncent une inclusion, une
identité ou une méronymie lexicale. J'en ai vérifié 22 dans les fichiers `data.*` :

**Les inclusions confirmées :**
- husband, wife ⊑ spouse ;
- Peter, instance d'Apostle ;
- Mary = Virgin_Mary = Madonna, un seul synset ;
- Hercules = Heracles, un seul synset ;
- slay ⊑ kill, et kill a pour cause die ;
- king ⊑ sovereign ⊑ ruler ;
- climb_up = climb, un seul synset ;
- hand = give, synonymes ;
- deck a pour holonyme de partie ship ;
- foredeck ⊑ deck ;
- john_the_baptist et john sont deux synsets.

**Ce qui n'est pas confirmé :**
- **mainmast :** aucune méronymie, seulement la glose (ep-002) ;
- **« Baptist » :** son seul sens est « follower of Baptistic doctrines » (rq-019, ep-013) ;
- **Tobias :** il n'est pas dans WordNet (rq-003) ;
- **« Gethsemane », « Christ Child », « Holy Family » :** ils sont absents de WordNet, et aucun K ne les donne ;
- **above / below :** WordNet les donne pour antonymes adverbiaux, ce qui n'atteste pas une converse (ep-005) ;
- **wear / clothe :** deux synsets, reliés par la seule glose de wear (ep-012).

## 2. Le tableau des désaccords

Les abréviations : ESH = `etablie_sous_hypotheses`, K = les `connaissances_supposees` du cas, « #n » = la variante n.

### 2.1 Sûreté

| identifiant | statut écrit | statut proposé | raison | section |
|---|---|---|---|---|
| rq-023 (et #1, #2, #6) | ecartee | inconnue | **La négation va dans le mauvais sens.** « Seulement les saintes femmes » implique « seulement des femmes », non l'inverse. Nier la première ne nie donc pas la seconde. La justification admet que Pierre et Jean ne réfutent rien sans K. Il ne reste aucun appui négatif de la définition. | FS § 3.3 (un appui négatif de A ne dit rien de B quand A ⇒ B) ; § 2.6 |
| mn-004 (et #1, #4, #5) | ecartee | ouvert (inconnue d'après D30) | « angel » a 4 sens dans WordNet. Une négation n'est certaine que si chaque nœud du type demandé est inclus dans chaque sens du mot nié : elle n'est ici que possible, et « ne réfute rien ». Le rédacteur le sait (mn, Q4) et suppose que la lecture fixe le sens, sans `decision_ouverte`. | NOYAU § 2 (D30) ; FS § 7 (supervaluation gardée) |
| D30, systémique : rq-007 (embrace, 3 sens), rq-022#5 (alone, 4), ep-003#5 (cart, 2), ep-004#4 (beard, 5), ep-006#4 (hold), ep-012#4 (leaf, 3), ep-016#5 (kiss, 2), ep-020#4 (strike), ep-023 (crow, 3), ep-024 (wash), mn-005 (crown, 4), mn-006#2 (sacrifice, 4), mn-017 (bless, 4), mn-018#3 (die, 11) | ecartee | ouvert (inconnue si D30 vaut pour la négation telle qu'elle est écrite) | Le même motif que mn-004, avec ses variantes `traduction`, `paraphrase` et `ajout_*`. Seuls ep-008#3 (kneel) et mn-002#3 (weep), monosèmes, y échappent. Les familles rq et ep ne posent pas la question. ep-001 applique pourtant D30 au lien positif (deck, d'où ESH [sens]). | NOYAU § 2 (D30) ; BANCS § 4 (hypothèse de sens) |
| mn-021 (et #1, #3, #5) | etablie | ESH [sens] | king ⊑ ruler ne vaut que pour king%1:18:00::. « king » a 11 sens, dont la pièce d'échecs et la carte. Un lien positif n'est certain que si chaque sens atteint le type. Le rédacteur le reconnaît (mn, Q4 : « une hypothèse de sens que je n'ai pas écrite »). | NOYAU § 2 (D30) ; BANCS § 4 |
| mn-024#2 | etablie | inconnue | « fleeing into Egypt » n'est dit que par le titre, qui n'est jamais une prémisse. Rien de ce qui suit n'est dans K : « la Vierge » pour Mary, la Sainte Famille comme collection, « assise sur un âne » pour riding. | NOYAU § 1 (titre) ; BANCS § 4 |
| mn-006#3 | etablie | inconnue | La définition demande « in place of Isaac ». La variante ne dit aucune substitution : Abraham sacrifie le bélier, Isaac délié à côté. La condition distinctive manque. | BANCS § 4 ; NOYAU § 4.4 |
| mn-005 (et #1, #5) ; mn-005#2 | ecartee ; etablie (#2) | inconnue ; inconnue | Le texte nie « le Christ couronne **sa mère** ». Que sa mère soit la Vierge n'est ni dit ni dans K : sans coréférence dite, les deux classes ne sont ni fusionnées (identité en monde ouvert) ni réfutées pour la Vierge. Le même pas fonde l'`etablie` de #2. #4, qui dit « la Vierge », n'est pas touchée. | NOYAU § 1 ; FS § 3.1 (invariant 1) |
| rq-024 (et #1, #2, #6, #7) | etablie | inconnue | Rien ne relie « jardin des Oliviers » (ou Garden of Olives) à « Garden of Gethsemane » : ni K, ni WordNet. En français, « dorment » (un verbe) contre « asleep » (un adjectif d'état) demande aussi une équivalence absente de K. Seule #1 dit « asleep ». | BANCS § 4 (« une connaissance absente de cette liste n'existe pas ») ; SPEC § 1 |
| rq-015 (et #1, #2, #6) | etablie | ouvert (inconnue) | « Lot's two daughters giving him wine » est un pluriel non marqué, et une seule des filles donne. Que l'acte d'un membre satisfasse le prédicat du groupe n'est fondé nulle part. rq-010 et rq-011, dans la même famille, tiennent cette ambiguïté pour bloquante. | FS § 2.6 (ambiguïté non résolue par défaut) |
| rq-008#5 | ecartee | inconnue | « au nombre de deux **sur ce fragment** » compte les figures conservées, un fait de l'œuvre lacunaire. Il ne dit pas le nombre du groupe figuré. Les rédacteurs le laissent eux-mêmes ouvert (rq, Q11 et Q12). La variation est aussi mal nommée (participant). | FS § 2.5 ; NOYAU § 4.1 ; BANCS § 4 (pas de monde clos) |
| rq-016 (et #1, #2, #6, #7) | etablie | inconnue (ESH avec K) | La définition demande « fighting the Hydra, striking it ». Le texte ne dit que frapper. strike ⇒ fight n'est ni dans K ni dans WordNet (fight%2:33:00:: est de verb.competition). | BANCS § 4 |
| rq-010#3 | etablie | inconnue | « set a single crown on her head » n'est pas le verbe crown. L'équivalence n'est pas dans K. | BANCS § 4 ; SPEC § 1 (pas de canonisation sans attestation) |
| rq-009#3 | etablie | inconnue | « bows his head in grief » (le nom grief) contre « grieving » (le verbe grieve) : aucune équivalence dans K. Le texte dit aussi « deathbed », puis « the bier », de la définition, sans que leur coréférence soit dite. | BANCS § 4 ; SPEC § 1 |
| rq-011#3 ; mn-010#2 ; mn-014 (et #1, #3, #5) ; mn-016 (et #1, #4, #6) | etablie | ouvert (inconnue sans K) | « l'Enfant », « the Child », « the new-born Child » sont lus comme « the Christ Child ». Ce n'est pas une entrée de WordNet, et aucun K ne le dit. rq-010 met pourtant dans K l'identité Virgin = Mary, pour un cas où elle n'est pas nécessaire. | BANCS § 4 ; NOYAU § 2 (`cle_de_nom`, alias) |
| ep-013 (et #1, #2, #5, #6) | etablie | inconnue (ESH avec K) | « holds out » (hold_out%2:29:00:: : « thrust or extend out ») et « présente » ne sont pas « holding ». L'alias « the Baptist » est marqué attesté, alors que le seul sens de « Baptist » dans WordNet est « follower of Baptistic doctrines ». | BANCS § 4 ; FS § 2.7 (attestation) |
| rq-019 (et #1, #2, #6) | etablie | ESH [identite] ou inconnue | « le Baptiste » est attesté comme nom partiel de Jean-Baptiste, sans ressource : WordNet ne le donne pas. AUDIT § 3.4 (3), cité par le cas, en fait une désambiguïsation, non une égalité. Le rédacteur le signale (rq, Q16). Le statut `etablie` en dépend. | FS § 2.7 ; NOYAU § 2 (alias établi) |
| ep-022 (et #1, #6) | etablie | ESH | K pose « sortir du tombeau ⊑ rise from the tomb (sens de la résurrection) » comme une implication attestée. C'est une identification interprétative, non une inclusion lexicale. #2, en anglais (« rises »), n'en a pas besoin : la traduction cache l'écart. | FS § 2.7 (hypothèse interprétative) ; BANCS § 4 |
| ep-011 (et #1, #2, #5) ; ep-015 (et #1, #2, #6) | etablie | ESH [sens] (si les conditions ne sont pas attestées) | La supervaluation sur les sens de « de » ne vaut que par des conditions nécessaires de sélection marquées attestées. Les rédacteurs les disent « hypothèse de rédaction à valider » (ep, Q11). Pour ep-011 s'ajoutent deux choses : l'équivalence « thorn crown ⇔ made_of thorn » n'a pas de source, et « couronne d'épines » est lexicalisé (crown_of_thorns, 3 sens ; ep, Q12). | FS § 2.7 ; BANCS § 4 |
| ep-017 (et #1, #6) ; ep-020#3 ; mn-009#2 ; ep-014#4 | etablie | ESH [identite] ou inconnue | Ces alias de traduction manquent dans K : Tobie/Tobias, Moïse/Moses, Jean-Baptiste/John the Baptist, Dieu le Père/God the Father. La famille rq les écrit, pour des cas identiques (rq-003, rq-018). | BANCS § 4 ; NOYAU § 2 (alias) |
| mn-023#4 | etablie | ouvert (non_certifiee) | Dans « As the Golden Legend tells it, St Margaret is shown… », « according to » peut se rattacher à l'assertion, ce qui donne une source citée. Le rédacteur le dit ambigu (mn, Q10) et ne met pas de `decision_ouverte`. | NOYAU § 4.4 |
| rq-006#2 | etablie | inconnue | « Le mari et sa femme » ne dit pas « couple ». Une coordination n'est pas une collection « married couple » sans K, ce qu'admet le rédacteur (rq, Q10). | FS § 2.6 ; BANCS § 4 |
| rq-002#4 | etablie | ouvert | « à sa droite » a deux antécédents possibles, l'évêque et l'autel. La justification ne traite que le diacre, alors que le cas tient l'ambiguïté de « il » pour bloquante. Pas de K d'orientation non plus, alors que rq-006 en écrit une. | NOYAU § 1 (C9) |
| ep-012#3 | etablie | ESH | L'équivalence « be clothed in ⇔ wear » est marquée attestée. WordNet ne la donne pas : deux synsets, une glose, donc une relation inconnue par défaut. Le K « un prédicat de la collection vêtue vaut pour chacun » est aussi posé comme attesté, sans fondement (rq, Q8, le juge non écrit). | FS § 2.7 (« le défaut d'une glose est relation inconnue ») |
| ep-005#1 | etablie | ESH [equivalence_non_attestee] | La converse above(X, Y) ⇔ below(Y, X) est marquée attestée. WordNet ne donne qu'une antonymie entre adverbes, et FS § 3.2 ne range pas les converses parmi les canonisations (ep, Q10). | FS § 3.2 ; SPEC § 1 |
| faible : mn-011 (et #3, #5) ; mn-020 (et #3, #5) | etablie | ouvert (ESH [sens]) | Le mot français laisse deux sens ouverts : « ciel » (sky ou heaven) contre « heaven » ; « phylactère » (phylactery, la seule entrée de WordNet, ou banderole) contre « scroll ». | BANCS § 4 (hypothèse de sens) ; NOYAU § 2 |
| faible : rq-012 ; mn-001#2 ; mn-015 | etablie | ouvert | Ce sont des écarts lexicaux sans K. enormous et huge sont deux synsets, satellites de large ; « slung from a pole » contre « on a pole ». « vieil » contre « aged ». « the dead Christ » contre « dead body of Christ ». | BANCS § 4 |

### 2.2 Trop faible

| identifiant | statut écrit | statut proposé | raison | section |
|---|---|---|---|---|
| mn-003 (et #1, #3, #5) | inconnue | ESH [connaissance_typique] | K contient une connaissance typique (la couronne de laurier, la palme), qui explique des observations affirmées. Aucune explication concurrente n'est dans K. Les documents fixent donc l'abduction et son statut, comme rq-020 le fait. La `decision_ouverte` présente comme ouverte une option que les documents tranchent, et `operations_requises` omet l'abduction. | SPEC § 4 ; FS § 2.7 et § 5 |
| mn-009 | inconnue | ouvert (ESH ?) | La connaissance typique explique le soldat, l'épée et le plat. La justification les dit « déjà expliqués par l'ordre ». Mais l'ordre est une observation, non une explication concurrente calculée par K. Le rejet n'est pas fondé dans SPEC § 4. | SPEC § 4 |

### 2.3 Connaissance non fondée

| identifiant | statut écrit | statut proposé | raison | section |
|---|---|---|---|---|
| ep (systémique) : ep-001, ep-002, ep-011, ep-013, ep-014, ep-015, ep-016 | (divers) | — | Les rédacteurs disent eux-mêmes marquer `attestee: true` « par hypothèse de rédaction » : les parties obligatoires (ep, Q5) et les restrictions de sélection (ep, Q11). mainmast n'a aucune méronymie dans WordNet, seulement la glose. | FS § 2.7 (une attestation, c'est la ressource et une validation) |
| conventions de lecture et méta-énoncés posés en implications attestées : rq-002, ep-002, ep-004, ep-006, ep-007, ep-008, ep-009, ep-010, ep-017, ep-018, ep-021, ep-023, ep-024 | — | — | Ces entrées ne sont pas des connaissances de K : « même type des deux côtés », « aucune connaissance de K n'exclut… », « K ne contient ni… », « no ship nie tout ship » (alors que le texte dit « visible »). Une entrée qui dit ce que K ne contient pas ne peut être `attestee`. | BANCS § 4 (K : ce qu'il contient, et rien d'autre) |
| alias de traduction : rq-003, rq-015, rq-018, rq-021, rq-022, rq-024 | etablie | etablie si l'alias est réellement attesté, sinon ESH [identite] | Les formes françaises (Tobie, Loth, Jean-Baptiste, Holopherne, Jérôme, Pierre) ne sont pas dans WordNet, et Tobias non plus. Aucune ressource n'est nommée (rq, Q18). | FS § 2.7 ; NOYAU § 2 |
| ep-014 | inconnue | — | « Dieu désigne Dieu le Père dans ce contexte iconographique » est une identification contextuelle, une connaissance typique ou une hypothèse interprétative, non une implication attestée. L'option `etablie` de la `decision_ouverte` en dépend : voir § 2.5. | FS § 2.7 |
| rq-006 | etablie | — | L'équivalence « à la gauche de Y ⇔ gauche_de_la_figure » est marquée attestée sans ressource. Elle est superflue : la description et la définition disent la même chose. Le statut ne dépend pas d'elle. | FS § 2.7 |
| rq-020 | ESH | — | « John » n'est pas, dans WordNet, un nom de Jean-Baptiste : le lemme john donne l'évangéliste, le roi Jean, etc. L'entrée « nom partiel de deux individus » est donc une connaissance de rédaction. Le statut, sous hypothèse, n'est pas touché. | FS § 2.7 |

### 2.4 Incohérence

| identifiant | statut écrit | statut proposé | raison | section |
|---|---|---|---|---|
| rq-004#6 ; rq-021#5 | inconnue ; contradictoire | (statut acceptable) | Ces variantes `ajout_figure_non_liee` ajoutent une figure liée, un second antécédent ou une troisième personne qui contredit « alone ». QS § 2.2 attend « statut conservé » pour cette variation. Il faut une autre variation (rq, Q2 et Q30). | QS § 2.2 |
| rq-008#5 ; rq-013#3 ; mn-006#3 | — | — | La variation ne réalise pas ce qu'elle annonce. Un changement de nombre est nommé `changement_de_participant`. Un changement de contenu (Abraham sacrifie le bélier) est nommé `changement_de_modalite`. | BANCS § 4 ; QS § 2.2 |
| rq-003#4 | inconnue | ouvert (non_certifiee) | « Le marché de 1512 nomme ce personnage Tobie » est une source qui parle de l'image. rq-007#5 (un inventaire) et rq-008#4 (un restaurateur), dans la même famille, en font `non_certifiee`. | NOYAU § 4.4 |
| mn-012#6 | non_certifiee | inconnue (sans K) | « il reçoit d'elle une bague » contre « handing » : la converse receive / hand n'est pas dans K, alors qu'ep-005 écrit la sienne. Sans elle, l'atome n'a pas d'appui, même cité. | SPEC § 1 ; BANCS § 4 |
| traductions dont le besoin en K diffère : ep-022 / #2 ; rq-024 / #1 ; ep-017 / #2 | même statut | — | Le cas de base français demande une connaissance absente ou non fondée (sortir/rise, dorment/asleep, Tobie/Tobias), et la traduction anglaise ne la demande pas. L'invariance de traduction n'est donc assurée que si le K est réel. | QS § 2.2 |

### 2.5 Décision ouverte mal posée

| identifiant | statut écrit | statut proposé | raison | section |
|---|---|---|---|---|
| rq-014 (et #1, #2, #6, #7) ; rq-013#3 | ecartee | ouvert (inconnue, la plus prudente) | Les rédacteurs écrivent (rq, Q11) que les deux compilations de « the twelve apostles », le nombre exact ou au moins douze membres distincts, donnent `ecartee` ou `inconnue`. Il manque une `decision_ouverte`, et le statut retenu n'est pas le plus prudent. | BANCS § 4 (`decision_ouverte`) ; NOYAU § 4.1 |
| rq-017 | inconnue | inconnue (ce n'est pas ouvert) | La `decision_ouverte` demande si l'identité Minerva = Athena peut être supposée. SPEC § 4 tranche : une hypothèse qui n'explique aucune observation (l'identité ne sert que la requête) est inadmissible. Le statut est juste, mais la question n'est pas ouverte. | SPEC § 4 |
| ep-014 ; ep-014#3 | inconnue ; ecartee | ESH sous l'option 2 ; #3 ouvert | Sous l'option 2, l'option `etablie` repose sur un K non fondé (§ 2.3) : ce serait au mieux ESH. #3 (« Dieu lui-même n'est pas figuré ») vaut `ecartee` sous l'option 1, mais `contradictoire` sous l'option 2 : le Dieu présent par sa main est nié. La variante dépend de la décision du cas sans le dire. | FS § 2.4 ; NOYAU § 4.4 |

### 2.6 Qualité

| identifiant | statut écrit | statut proposé | raison | section |
|---|---|---|---|---|
| rq-002, rq-005, rq-009, rq-010, rq-011, rq-017, rq-020, ep-002, ep-009 | — | — | Le protocole demande une variante qui change de statut par la portée, la modalité, le temps ou une inversion des rôles. Ici, aucune ne le fait : le changement passe par `composition` ou `changement_de_participant`. | BANCS § 4 (variantes) |
| rq-002#3, #5, #6 ; rq-017#5 | inconnue | — | Ces variantes ne mesurent rien : le cas de base est déjà `inconnue` pour une autre raison (le pronom ambigu, l'alias non établi). Le temps, l'inversion ou la figure ajoutée n'y ont aucun effet observable. | QS § 2.2 |
| ep-017 ; ep-021 | — | — | **ep-017 :** dans « …avant de le vider, à droite, sous le regard de l'ange », le rattachement de « à droite » est ambigu, et c'est lui qui porte la narration continue. **ep-021 :** le K « no ship nie tout ship » ignore « visible », que dit le texte. Le statut n'en dépend pas, mais la description et le K ne disent pas la même chose. | — |

## 3. Les questions où les documents ne tranchent pas, en plus de celles des rédacteurs

1. **D30 vaut-il pour la négation, dans la sémantique cible ?** NOYAU § 1.1 prend pour exemple « pas de lion : aucun lion
   n'est figuré ». NOYAU § 2 (D30) n'en fait qu'une négation possible dès que le mot nié est polysémique, ce qui est le
   cas de lion, angel, crown ou bless. Les deux passages ne disent pas la même chose.
   - Seule la famille mn pose la question (mn, Q4), sans `decision_ouverte` ; rq et ep ne la posent pas.
   - Elle décide d'environ la moitié des `ecartee` des trois familles.
   - Si la lecture fixe le sens (C7), il faut le dire. La phase ne spécifie pas C7 (ep, Q4).
2. **La monotonie des quantifications énoncées.** FS § 2.6 représente « seul », « seulement », « tous ». Il ne dit pas
   comment elles se combinent avec les inclusions de K, ni dans quel argument la négation se propage : la restriction
   ou la portée (rq-023, rq-023#3).
3. **Le passage du français à un sens anglais.** BANCS § 4 ne le règle que pour le pivot. Plusieurs cas français
   reposent sur une traduction lexicale qui change de lemme ou de catégorie : dorment / asleep, sortir / rise, ciel /
   heaven, phylactère / scroll, vieil / aged. Est-ce de la lecture (C7) ou une connaissance de K, qui devrait alors être
   écrite ?
4. **Les descriptions définies qui servent de noms.** « l'Enfant », « la Vierge », « sa mère », « le Baptiste » :
   sont-ce des noms (`nom/4`, une clé, un alias), des noms communs (sens, D30) ou des coréférences à écrire ? Les cas
   les traitent des trois manières.
5. **Une entrée de K qui est une convention de lecture** (« même type des deux côtés », l'orientation d'une
   préposition) **est-elle une connaissance ?** Si oui, que serait son attestation ? Si non, la sorte `implication`
   ne convient pas.
6. **`non_certifiee` à la place d'`inconnue` est-il une erreur de sûreté ?** BANCS § 7 ne la range pas parmi les
   erreurs de sûreté. Le cas se pose en mn-012#6 et rq-003#4.
7. **Une modalité non affirmée qui énonce le contenu même d'une abduction** (« traditionnellement identifiée comme la
   Victoire », avec ses attributs typiques) : est-elle une observation à expliquer, une explication concurrente, ou
   rien ? SPEC § 4 ne le dit pas (mn-003).
8. **La négation de l'existence d'un tout dont une partie est figurée** (« Dieu n'est pas figuré : seule sa main… »,
   ep-014#3) : est-ce une contradiction, ou une précision du contexte ? La question tient à celle d'ep, Q2.
9. **Une figure qui crée un antécédent ou contredit une quantification est-elle « non liée » ?** QS § 2.2 ne le dit
   pas. Il manque une variation (rq-004#6, rq-021#5).

**Une remarque, qui ne tranche rien :** les erreurs de sûreté les plus nettes ne viennent pas d'une lecture différente
des documents. Elles viennent de connaissances qui manquent dans K, ou qui y sont marquées attestées sans ressource.
Le cas rq-023 est l'exception : c'est une erreur de logique.
