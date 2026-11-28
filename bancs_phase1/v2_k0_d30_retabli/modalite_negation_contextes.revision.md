# Révision de modalite_negation_contextes après la relecture B et BANCS § 4.1 (27/11)

**Ce qui a été révisé :**
- les désaccords de `relecture_B.md` qui portent sur `mn-` (§ 2 du tableau, et les questions 6 et 7) ;
- le § 4.1 du protocole, appliqué à tous les cas ;
- la version d'avant est gardée dans le scratchpad de la session (`mn/avant_revision.json`).

**Le résultat du validateur, avec --quotas :** 24 cas de base, 124 variantes, 0 erreur ; 23 cas composés ≥2, 15 cas ≥3.

**Les nombres :**
- **28 statuts changés** : 23 vers plus faible, 5 vers plus fort (tous en mn-003).
- **`decision_ouverte`** : 5 avant, 10 après.
  - **Ajoutées :** mn-004, 005, 009, 016, 017, 020.
  - **Retirée :** mn-003.

## 1. Les désaccords de la relecture B

### Corrigés

| désaccord | décision | ce qui a changé |
|---|---|---|
| mn-004 (et #1, #4, #5) : négation de « angel », 4 sens (D30) | corrigé | `inconnue`, avec une `decision_ouverte` (`tous_les_sens` : inconnue ; `sens_fixe_par_le_contexte` : ecartee). La définition dit « the Virgin… with the Child… angels present », pour éviter « Madonna » et « attended by », qui n'étaient pas dans K. |
| D30 systémique : mn-005, mn-006#2, mn-017, mn-018#3 | corrigé | mn-005 (et #1, #4, #5) et mn-017 (et #1, #4, #6) : `inconnue`, avec une `decision_ouverte` sur le sens. mn-006#2 et mn-018#3 : `inconnue`, la raison ajoutée à la justification du cas (une variante ne porte pas de `decision_ouverte`). |
| mn-021 (et #1, #3, #5) : king ⊑ ruler ne vaut que pour un sens | corrigé autrement | La définition dit maintenant « a king ordering… » : le lien vers le même lemme vaut pour tous les sens, par lexicalisation (NOYAU § 2). L'inclusion king ⊑ sovereign ⊑ ruler est retirée de K. Le statut reste `etablie`, et le cas mesure toujours ce qu'il doit mesurer, le contenu d'un ordre. |
| mn-024#2 : « fleeing into Egypt » n'est dit que par le titre ; Mary, Holy Family, riding ne sont pas dans K | corrigé | La définition devient « the Virgin holding the Child, seated on a donkey led by Joseph ». La variante 2 dit « la Vierge, tenant l'Enfant, est assise sur un âne que Joseph mène » : `etablie` sans K. Le cas de base reste `inconnue` : seul le titre suggère le sujet. |
| mn-006#3 : « in place of Isaac » n'est pas dit ; variation mal nommée | corrigé | La description dit « sacrifices the ram on the altar in place of Isaac, whom an angel has released ». La variation devient `changement_de_participant`. Le statut reste `etablie`. |
| mn-005 (et #1, #5) ; mn-005#2 : « sa mère » n'est pas « la Vierge » | corrigé | Les descriptions disent « la Vierge, sa mère » / « the Virgin, his mother ». Le statut est fixé par le point D30 ci-dessus. |
| mn-010#2, mn-014 (et #1, #3, #5), mn-016 (et #1, #4, #6) : « Christ Child » n'est dans aucun K | corrigé | Les définitions disent « the Child » (même lemme que « l'Enfant », « the Child »). mn-016 passe de plus en `inconnue` par D30 (« auréole », 3 sens), avec une `decision_ouverte` à trois options. |
| mn-009#2 : alias Jean-Baptiste / John the Baptist absent de K | corrigé | K reçoit une entrée `identite_documentaire`, non attestée : le synset 11087359 existe, mais rien n'atteste le passage du nom français. La variante 2 devient `etablie_sous_hypotheses` [identite]. |
| mn-023#4 : « As the Golden Legend tells it… is shown » se rattache de façon ambiguë | corrigé | La paraphrase dit « Following the Golden Legend, the painter represents St Margaret emerging… », où l'auteur affirme sans ambiguïté. Le statut reste `etablie`. |
| mn-011 (et #3, #5) : « ciel » contre « heaven » | corrigé | La condition « reaching to heaven » est retirée de la définition. Le cas porte sur le contenu du rêve, non sur le ciel. |
| mn-020 (et #3, #5) : « phylactère » contre « scroll » | corrigé | WordNet ne donne à phylactery que l'étui juif, qui n'atteint pas scroll. Le cas passe en `etablie_sous_hypotheses` [sens], avec une `decision_ouverte`. La traduction anglaise, qui dit « scroll », reste `etablie`. La rupture de la relation de traduction est signalée (questions, Q17). |
| mn-001#2 : « vieil » contre « aged » | corrigé | La définition dit « old hermit ». |
| mn-015 : « the dead Christ » contre « dead body of Christ » | corrigé | La définition dit « the dead Christ being lowered from the cross, a man on a ladder supporting the body ». « Standing » est retiré, car il n'était pas dit. La paraphrase #3 n'emploie plus « take down » ni « holds », mais « lower » et « supports ». |
| mn-003 (et #1, #3, #5) : l'abduction par la connaissance typique est fixée par SPEC § 4 | corrigé (accepté) | Le cas passe en `etablie_sous_hypotheses` [connaissance_typique], #4 compris. Les opérations deviennent lecture et abduction, les extensions abduction et referent_conceptuel. La `decision_ouverte` est retirée : l'identification traditionnelle conduit à la même notation, elle n'est pas une concurrente. La question de la relecture (Q7) est reprise en Q16. |
| mn-009 : le rejet de l'abduction n'est pas fondé par SPEC § 4 | corrigé | L'argument « l'ordre explique déjà » est retiré. Une `decision_ouverte` est ajoutée : une abduction par des éléments typiques donne-t-elle l'événement en cours ? Le contre-exemple du portrait de mariage (SPEC § 4) fonde l'option `inconnue`, la plus prudente, qui est retenue. |
| mn-012#6 : la converse receive / hand n'est pas dans K | corrigé | La paraphrase dit « c'est une bague que la dame lui remet », sans converse. Le statut reste `non_certifiee`. |

### Contestés

Aucun désaccord n'est contesté. Deux corrections ne suivent pas le statut que la relecture proposait :
- **mn-021 :** la définition est changée, au lieu de passer le cas en ESH [sens].
- **mn-024#2 :** la définition et la variante sont réécrites, au lieu de passer la variante en `inconnue`.

Dans les deux cas, j'ai retiré le pas lexical non fondé que la relecture relevait, et le statut `etablie` repose
maintenant sur des liens de même lemme.

## 2. Les autres changements faits par le § 4.1

- **Le champ `source` des connaissances attestées.** La seule connaissance attestée qui reste est celle de mn-018 :
  slay ⇒ die, contraposition seule. J'ai vérifié sa source dans data.verb :
  - slay%2:41:00:: est dans le synset 02482425 (murder/slay) ;
  - ce synset a pour hyperonyme `@` kill, 01323958 ;
  - kill a un pointeur de cause `>` vers die, 00358431.
- **Les alias entre langues.**
  - **mn-023 :** une entrée « sainte Marguerite » / « St Margaret » est ajoutée, non attestée : Margaret n'est pas dans
    WordNet. La traduction #1 devient `etablie_sous_hypotheses` [identite].
  - **mn-019#1 :** « Persée » n'a pas d'alias écrit. Son statut, `inconnue`, n'en dépend pas.
- **Le régime des sens.**
  - Les cinq négations de mots polysémiques sont traitées comme ci-dessus : mn-004, 005, 016, 017, et les variantes
    mn-006#2 et mn-018#3.
  - **Ce qui reste `ecartee` :** mn-002#3, car « weep » est monosème ; et mn-016#2, une affirmation qui rend faux
    non(A), sans négation d'un mot polysémique.
  - **Les liens positifs :** je les tiens pour certains quand le mot est le même des deux côtés (questions, Q18).
- **Les incompatibilités.** Aucun cas de la famille ne dépend d'une incompatibilité : les changements de participant
  (homme / femme, apôtre / évêque, Vierge / paysanne) sont déjà `inconnue`, faute d'appui. Aucune `decision_ouverte`
  n'a donc été ajoutée pour ce motif.
- **Les extensions.** Les noms corrigés par la session principale sont gardés (CONSOLIDATION.md) : mn-011, 016, 021
  et 022. mn-003 reçoit abduction et referent_conceptuel.
- **Le fichier de questions.** Il reçoit Q16 à Q20 : l'identification traditionnelle dans l'abduction, les
  traductions qui changent le statut, le critère du même lemme, une négation possible face à une affirmation (mn-012#3),
  et « la Vierge » face au lemme The_Virgin.

## 3. Harmonisation (BANCS § 4.1, point 2, « Ce que D30 dit exactement »)

**La méthode.** Chaque mot dont dépend un atome de la définition a été recalculé sur WordNet 3.0 (fichiers `data.*`,
pointeurs `@` et `@i`) et, pour le français, sur WOLF (omw-1.4, fra), par un script de consultation qui reste dans le
scratchpad de la session (`mn/wn_lien.py`, `mn/liens*.txt`).
- **Un lien positif** est certain si chaque sens du mot du texte atteint le lemme de la définition.
- **Une négation** est certaine si chaque sens du type demandé est inclus dans chaque sens du mot nié.
- **Le statut retenu** est celui de l'option `tous_les_sens`.

**Les définitions rétablies** (consigne de la coordinatrice) :
- **mn-021** revient à « a ruler ordering… ». Seul king%1:18:00:: atteint ruler, sur les 10 sens de king : le cas et
  ses variantes 1, 3 et 5 passent en `etablie_sous_hypotheses` [sens]. La paraphrase 3 dit maintenant « has ordered ».
- **mn-024** revient à « the Holy Family fleeing into Egypt: Mary with the Child riding a donkey, led by Joseph ». La
  variante 2, rétablie, devient `inconnue` : elle ne dit ni la fuite, ni Mary (Vierge : 3 sens sur 11), ni riding. Une
  variante 6 dit tout cela, et passe en `etablie_sous_hypotheses` [sens, equivalence_non_attestee]. Une entrée
  « Sainte Famille ⇔ Holy Family » est ajoutée à K, non attestée.
- **Les autres définitions modifiées à la révision** (mn-001, 004, 010, 011, 014, 015, 016) ne sont pas rétablies.
  Elles avaient été changées à la demande de la relecture B. Le pas lexical retiré (Christ Child, aged, attended by,
  heaven, dead body) n'était pas le phénomène testé. Je le signale pour décision.

**Les statuts changés : 25 plus faibles, aucun plus fort, un hors de l'ordre de sûreté.**
- **Vers `etablie_sous_hypotheses` [sens], des mots français polysémiques dans WOLF :**
  - mn-001#2 (vieux 7/19, ermite 2/3) ;
  - mn-012#2 (dame 3/15, remettre 2/18, chevalier 2/5) ;
  - mn-013#1 (homme, Vierge, Enfant) ;
  - mn-014, #3 et #5 (Vierge, allaiter 1/2, Enfant) ;
  - mn-015#1 (mort, descendre 1/16 vers lower…) ;
  - mn-018#2 (dragon 4/8, mourir 7/16).
- **Vers `etablie_sous_hypotheses` [sens], un mot anglais :** mn-011#1 (go up 1/7 vers ascend, go down 3/8 vers
  descend).
- **Vers `etablie_sous_hypotheses`, avec une équivalence non attestée ajoutée à K parce que le mot du texte n'a aucun
  lien vers le lemme :**
  - mn-002#2 (sits / seated) ;
  - mn-003#2 (couronne de laurier, absente de WOLF) ;
  - mn-005#2 (couronner, absent de WOLF) ;
  - mn-007, #4 et #5 (debout / standing) ;
  - mn-011, #3 et #5 (couché / lying, avec d'autres sens) ;
  - mn-021 (voir plus haut) ;
  - mn-023#1 (sortir de / emerge, avec l'identité).
- **mn-003, #3, #4 et #5 :** le statut ne change pas, mais `sens` et `equivalence_non_attestee` s'ajoutent à
  `connaissance_typique`. Une variante 6, en anglais et `etablie`, est ajoutée pour garder un statut différent.
- **mn-020, #3 et #5 :** « phylactère » n'a aucun lien vers scroll (WOLF : 2 sens). La raison passe du sens à une
  équivalence non attestée, ajoutée à K, et la `decision_ouverte` est réécrite.
- **mn-016#2, de `ecartee` à `inconnue` :** la réfutation de non(A) passe par auréole (1 sens sur 2) et Enfant (6 sur
  12). La variante porte une `decision_ouverte`. Une variante 7, en anglais, garde `ecartee` : halo et child y donnent
  des liens certains.
- **mn-024#2, de `etablie` à `inconnue` :** voir plus haut.
- **Hors de l'ordre de sûreté : mn-012#3, de `contradictoire` à `etablie_sous_hypotheses` [sens].** La négation citée
  n'est que possible (remettre : 2 sens sur 18). Elle ne contredit donc rien sous `tous_les_sens`. La variante porte une
  `decision_ouverte` (`sens_fixe_par_le_contexte` : contradictoire).

**Ce qui ne change pas :**
- **Les négations recalculées restent `inconnue` :** angel, crown, sacrifice, bless, halo, die. Elles ne sont que
  possibles.
- **Les négations certaines restent `ecartee` :** mn-002#3, car weep est monosème, et mn-016#7.
- **Les cas anglais restent `etablie` quand le même lemme est des deux côtés :** mn-006#3, mn-008#2, mn-010#2, mn-013,
  mn-015, mn-017#2, mn-019#2, mn-022#2, mn-023.
- **Aucun statut affaibli à tort à la révision n'a été trouvé.**

**Les `decision_ouverte`, après l'harmonisation :** 14 sur les cas de base, 9 sur des variantes.

**Les cas de base, par statut :** inconnue 14, etablie_sous_hypotheses 6, etablie 3, non_certifiee 1.

**Le validateur, avec --quotas :** 24 cas de base, 127 variantes, 0 erreur ; 23 cas composés ≥2, 15 cas ≥3.

## 4. Rétablissement (28/11)

**La décision de la propriétaire :** rétablir ce que la révision et l'harmonisation avaient modifié pour contourner une
lacune de WOLF ou de WordNet. Les statuts sont recalculés par la règle du § 4.1, point 2 : les sens WOLF, et les seules
connaissances déjà écrites dans K. Aucune entrée n'a été ajoutée à K pour relever un statut. La version d'avant le
rétablissement est gardée dans le scratchpad de la session (`mn/avant_retablissement.json`).

### Ce qui revient

| élément | ce qui revient (version 1) | statut avant → après |
|---|---|---|
| mn-001, définition | « aged hermit… » | inchangé : la base reste `inconnue` ; #2 reste `etablie_sous_hypotheses` [sens] (vieil n'atteint aged que par 3 sens sur 19) |
| mn-004, définition | « Madonna and Child enthroned, attended by angels » | #2 : etablie → **inconnue** (« the Virgin » n'atteint madonna par aucun de ses 3 sens ; « attended by » n'a pas de lien) ; la base reste `inconnue` |
| mn-010, définition | « the new-born Christ Child… » | #2 : etablie → **inconnue** (Christ Child n'est pas dans WordNet ; « the Child » ne l'atteint pas) |
| mn-011, définition | « …a ladder reaching to heaven… » | inchangé : la base reste `etablie_sous_hypotheses` (ciel : 2 sens sur 3 vers heaven, déjà sous hypothèse de sens) ; #1 reste `etablie_sous_hypotheses` |
| mn-011#3, texte | « Jacob dort ; il voit en songe une échelle dressée jusqu'au ciel… » | etablie_sous_hypotheses → **inconnue** (dormir n'a pas de lien vers asleep ; songe est absent de WOLF) |
| mn-012#6, texte | « il reçoit d'elle une bague » | non_certifiee → **inconnue** (receive / recevoir n'a pas de lien vers hand) |
| mn-013#3, texte | « he prays with joined hands » | etablie → **inconnue** (le verbe pray n'a pas de lien vers prayer) |
| mn-014, définition | « the Virgin seated, nursing the Christ Child » | base : etablie_sous_hypotheses → **inconnue** ; #1 etablie → inconnue ; #3 et #5 etablie_sous_hypotheses → inconnue. La `decision_ouverte` est retirée : le statut ne dépend plus d'un sens |
| mn-015, définition | « the dead body of Christ being lowered…, a man standing on a ladder supporting it » | base : etablie → **inconnue** (« standing » n'est pas dit ; Christ n'atteint body par aucun sens) ; #1 etablie_sous_hypotheses → inconnue ; #3 et #5 etablie → inconnue. « Standing » est rétabli dans le doute : je l'avais retiré moi-même, sans demande de la relecture |
| mn-015#3, texte | « take the dead Christ down…, holds the body » | etablie → inconnue (voir la ligne ci-dessus) |
| mn-016, définition | « the haloed Virgin presenting the naked Christ Child, the Child without a halo » | inchangé : la base reste `inconnue` |
| mn-016#7 | variante anglaise ajoutée à l'harmonisation, dans un cas français, pour garder un lien de même lemme | **retirée** (elle était `ecartee`) |
| mn-003#6 | même motif | **retirée** (elle était `etablie`) |
| mn-021#3, texte | « At the command of the king… » | etablie_sous_hypotheses → **inconnue** (le nom command n'a pas de lien vers order) |

mn-021 et mn-024 (la définition, et le texte de #2) avaient déjà été rétablis à l'harmonisation.

### Ce qui n'est pas rétabli, parce que c'était une correction de fond

- **mn-005 :** « la Vierge, sa mère ». La coréférence n'était pas dite (relecture B ; FS § 3.1, invariant 1).
- **mn-006#3 :** le texte ne réalisait ni sa condition (« in place of Isaac ») ni sa variation (relecture B).
- **mn-023#4 :** le rattachement ambigu de « according to » était une erreur de sûreté possible (relecture B).
- **Les connaissances retirées de K :** l'inclusion king ⊑ ruler de mn-021, enlevée à la révision puis rétablie avec
  sa source.
- **Les équivalences non attestées ajoutées à K à l'harmonisation** (sits / seated, couronner, debout, couché,
  phylactère, sortir de, couronne de laurier, Sainte Famille) sont gardées. Ce ne sont pas des réécritures du texte :
  elles écrivent dans K, comme le § 4.1 le demande, ce que le cas suppose. Elles laissent le statut sous hypothèse,
  jamais `etablie`.
- **mn-024#6** (en français) est gardée : c'est une variante ajoutée, non un texte modifié.

### Les autres changements, demandés par le validateur

- Chaque variante déclare maintenant sa `langue` : celle de l'autre langue pour une traduction, celle du cas sinon.
- Trois `decision_ouverte` dont les deux options donnaient le même statut sont retirées : mn-005#2, mn-007 et mn-011.

### Les cas sans variante de statut différent (notés, non réécrits)

| cas | pourquoi |
|---|---|
| mn-003 | la variante #6 a été retirée |
| mn-004 | #2 est devenue `inconnue` |
| mn-010 | #2 est devenue `inconnue` |
| mn-014 | Christ Child |
| mn-015 | standing et body |
| mn-016 | la variante #7 a été retirée |
| mn-006 | une conséquence de la révision, non du rétablissement : la variante de statut différent (#3) est un `changement_de_participant`, que le validateur ne compte pas |

### Les nombres

- **Statuts changés :** 2 cas de base (mn-014 et mn-015, vers `inconnue`) et 11 variantes, tous plus faibles. Aucun
  n'est plus fort. Deux variantes sont retirées.
- **Les cas de base, par statut :** inconnue 16, etablie_sous_hypotheses 5, etablie 2, non_certifiee 1.
- **Les `decision_ouverte` :** 11 sur les cas de base, 7 sur des variantes.

**Le validateur, avec --quotas :** 24 cas de base, 125 variantes, 0 erreur, 7 exigences non remplies. Ce sont les 7
cas ci-dessus, sans variante de portée, de modalité, de temps ou d'inversion qui change de statut. Les quotas sont
atteints : 23 cas composés ≥2, 15 cas ≥3.
