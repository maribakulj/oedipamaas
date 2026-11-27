# Révision de espace_partie_temps après la relecture B

**Ce qui a servi :**
- `relecture_B.md`, les lignes qui portent sur `ep-` ;
- `docs/BANCS_PHASE1.md` § 4 et § 4.1, nouveau ;
- WordNet 3.0, par `sens.py` et par les fichiers `data.noun` et `data.verb`, pour les pointeurs `@`, `@i` et `#p`.

**Le résultat, en bref :**
- tous les désaccords sont corrigés, sauf ep-012#3 qui est contesté (point 6), et la translittération des prépositions et des verbes français qui reste une limite déclarée (§ 3) ;
- 46 statuts changent, mesurés sur les variantes qui gardent leur variation : tous vers plus faible, aucun vers plus fort ;
- les `decision_ouverte` passent de 4 à 12 ;
- 8 variantes sont ajoutées et 1 est remplacée : 146 variantes en tout ;
- la copie de la version 1 est dans le scratchpad (`ep_v1.json`).

## 1. Les désaccords de la relecture

1. **D30 et la négation : ep-003#5, ep-004#4, ep-006#4, ep-012#4, ep-016#5, ep-020#4, ep-023, ep-024 (sûreté). Corrigé.**
   - Chaque négation porte sur un mot polysémique :
     - cart : 2 sens ;
     - beard : 5 sens ;
     - hold et angel ;
     - leaf : 3 sens ;
     - kiss : 2 sens, et hand ;
     - frapper ;
     - crow : 3 sens ;
     - wash.
   - Elle n'est donc que possible (NOYAU § 2).
   - Les variantes concernées passent d'`ecartee` à `inconnue`.
   - Les bases ep-023 et ep-024 passent d'`ecartee` à `inconnue`, avec leurs paraphrases, traductions, ajouts et, pour ep-023, l'inversion. Chacune reçoit une `decision_ouverte` (`tous_les_sens` : inconnue ; `sens_fixe_par_le_contexte` : ecartee), selon le § 4.1, point 2.
   - Il fallait encore une variante de statut différent : ep-023 et ep-024 en reçoivent une nouvelle, `changement_de_modalite`, où l'événement est affirmé (`etablie`). Pour ep-024, elle porte `extensions_requises` : `relation_entre_eventualites`, `identite_entre_situations`, `plusieurs_situations`.
   - ep-008#3 (kneel, un seul sens) reste `ecartee`.

2. **ep-013 : « holds out », et l'alias « the Baptist » marqué attesté (sûreté). Corrigé.**
   - Les descriptions disent maintenant « holds » et « tient ».
   - L'alias est écrit comme `identite_documentaire` avec `attestee: false`. WordNet ne donne que baptist%1:18:00:: (follower of Baptistic doctrines).
   - Le cas de base et les variantes #1, #2, #5 et #6 passent d'`etablie` à `etablie_sous_hypotheses` [identite]. Une connaissance non attestée donne au mieux un statut sous hypothèse (FONDEMENTS § 2.7). C'est l'option « ESH avec K » de la relecture.
   - La restriction de sélection sur « of » a été retirée : « of » est le même mot des deux côtés, et la relation n'y demande pas de choix de sens.

3. **ep-022 : « sortir du tombeau ⊑ rise » donné pour attesté (sûreté). Corrigé.**
   - L'entrée devient une `hypothese_interpretative`, non attestée.
   - Le cas de base et les variantes #1, #2 et #6 passent à `etablie_sous_hypotheses` [hypothese_interpretative].
   - La traduction #2 dit maintenant « comes out of the tomb », pour avoir le même besoin de K : l'invariance de traduction est rétablie.
   - #5 (la notice citée) passe de `non_certifiee` à `inconnue`, le plus prudent (§ 4.1), puisque la vérité y passerait aussi par l'hypothèse.

4. **ep-011 et ep-015 : la supervaluation sur « de » ne tient que par des restrictions non fondées (sûreté). Corrigé.**
   - Les restrictions sont réécrites comme `relation_inconnue`, non attestées.
   - **ep-011 :** `etablie_sous_hypotheses` [sens, equivalence_non_attestee]. Le composé « thorn crown » n'a pas de source ; la lecture lexicalisée (crown_of_thorns, 3 sens) est notée dans K et dans la `decision_ouverte`. Les variantes #1, #2 et #5 suivent.
   - **ep-015 :** `etablie_sous_hypotheses` [sens], avec une `decision_ouverte` (sens fixé : etablie).
     - La description est réécrite : « Goliath, le géant philistin… le décapite avec l'épée du géant ».
     - La définition devient « beheading ». La reprise « le géant » est fondée par l'apposition, sans K (WordNet donne Goliath @i warrior, non giant), et « lui tranche la tête » ne dépend plus d'une équivalence trancher / cut off.
     - Les variantes #1, #2 et #6 sont en ESH [sens].

5. **Les alias de traduction absents : ep-017, ep-020#3, ep-014#4 (sûreté). Corrigé.**
   - **ep-017 :** Tobie et Tobias (absent de WordNet) sont remplacés par Samson, même nom dans les deux langues (samson%1:18:00::). La description est réécrite, ce qui règle aussi l'ambiguïté du rattachement de « à droite » (point 12). Les statuts sont inchangés : `etablie`.
   - **ep-020#3 :** l'alias Moïse / Moses est écrit dans K, non attesté. La variante passe d'`etablie` à `etablie_sous_hypotheses` [identite].
   - **ep-014 :** la définition devient « God blessing a martyr from the clouds », et #4 dit « Dieu, en buste ». « Dieu » passe à god par WOLF, qui est implicite (§ 4.1), et « Dieu le Père / God the Father » n'est plus demandé. #4 reste `etablie`.

6. **ep-012#3 : « be clothed in ⇔ wear » et la distributivité marqués attestés (sûreté). Contesté, après réécriture.**
   - Les descriptions disent maintenant « Each of them wears a garment of… », et la définition « Adam and Eve each wearing a garment of fig leaves ».
   - Avec les mots de la définition et le distributif dit, ni l'équivalence ni la règle de distributivité ne sont plus nécessaires, et toutes deux sont retirées de K.
   - « Of » est le même mot des deux côtés.
   - #3 reste donc `etablie`, ce que je conteste contre la proposition ESH, qui portait sur l'ancienne formulation. Fondement : BANCS § 4.1, point 1 ; FONDEMENTS § 2.6, le distributif énoncé.

7. **ep-005#1 : la converse above / below marquée attestée (sûreté). Corrigé.**
   - L'entrée devient `equivalence_etablie` avec `attestee: false` : WordNet ne donne qu'une antonymie.
   - #1 passe d'`etablie` à `etablie_sous_hypotheses` [equivalence_non_attestee].
   - La définition dit maintenant « Christ's head », comme la description.

8. **Les attestations « par hypothèse de rédaction » : ep-001, 002, 011, 013, 014, 015, 016. Corrigé.**
   - Chaque entrée `attestee: true` a une `source` WordNet (clé, offset, pointeur). Les autres sont mises à `attestee: false`.
   - **ep-001 :** deck%1:06:00:: #p ship est confirmé. La méronymie ne dit pas que la partie est **obligatoire** (la condition de SPECIFICATION_OPERATIONS § 2) : la règle partie ⇒ tout ne s'applique que sous hypothèse, `consequence_conditionnelle`.
     - Le cas de base et les variantes #1, #2 et #6 passent à ESH [sens, consequence_conditionnelle].
     - #3 (foredeck @ deck) passe d'`etablie` à ESH [consequence_conditionnelle].
   - **ep-002 :** mainmast n'a pas de méronymie ; la source donne mainmast @ mast #p sailing_vessel. Le statut est inchangé (`inconnue`).

9. **Les conventions de lecture et les méta-énoncés posés comme implications attestées : ep-002, 004, 006, 007, 008, 009, 010, 017, 018, 021, 023, 024. Corrigé.**
   - Les entrées « même type des deux côtés », « K ne contient ni… » et « no ship nie tout ship » sont retirées.
   - Ce qui reste nécessaire est écrit en `relation_inconnue` non attestée : sur / au-dessus, before / behind, la convention de la figure frontale, peau / feuille, les prépositions françaises.

10. **ep-014 et ep-014#3 : une décision ouverte mal posée. Corrigé.**
    - L'option « le tout est présent » vaut maintenant `etablie_sous_hypotheses`, et non plus `etablie` : la lecture partie_de de « de » n'est pas attestée, et Dieu n'est pas un homo (hand #p homo).
    - #3 (« Dieu lui-même n'est pas figuré ») passe d'`ecartee` à `inconnue`. Il dépendait de la décision (écartée sous la première option, contradictoire sous la seconde), et la justification le dit.
    - Une variante `changement_de_portee` (`non_certifiee`) est ajoutée pour garder un changement de statut par la portée.

11. **ep-002 et ep-009 : aucune variante ne change de statut par la portée, la modalité, le temps ou l'inversion (qualité). Corrigé.**
    - Chacun reçoit une variante `changement_de_portee`, où une notice citée décrit la scène demandée (`non_certifiee`, NOYAU § 4.4).

12. **ep-017 (« à droite » ambigu) et ep-021 (le K ignore « visible ») : qualité. Corrigé.**
    - ep-017 est réécrit (point 5).
    - Pour ep-021, l'entrée de K est retirée, et la justification parle de « no ship is visible ».

13. **Les traductions dont le besoin en K diffère : ep-022 / #2 et ep-017 / #2 (incohérence). Corrigé** par les points 3 et 5.

## 2. Les autres changements faits pour le § 4.1

- **ep-003 :**
  - K est réécrit : wheel #p wheeled_vehicle et cart @ wagon @ wheeled_vehicle, avec sources ; la connaissance typique reste non attestée.
  - #5 (« no cart ») passe à `inconnue` (point 1).
  - Une variante `changement_de_portee` (`non_certifiee`) est ajoutée.
- **ep-004 :**
  - Le possessif « sa » contre le « with » de la définition demande un choix entre partie_de et possession, qu'aucune restriction attestée ne fait.
  - Le cas de base et les variantes #1, #2, #5 et #6 passent d'`etablie` à `etablie_sous_hypotheses` [sens], avec une `decision_ouverte`.
  - La méronymie beard #p face et #p adult_male_body est sourcée.
- **ep-007 :** le passage de « devant » et « derrière » aux relations before et behind est écrit en K non attesté. Le statut reste `etablie`, sous la réserve générale du § 3.
- **ep-008 :** une `decision_ouverte` sur l'incompatibilité (§ 4.1, point 3) est ajoutée : inconnue ; écartée si une incompatibilité attestée était admise et le cadre intrinsèque ; inconnue dans le cadre du spectateur.
- **ep-009 :** l'absence d'incompatibilité gauche / droite est rappelée dans la justification ; la convention de la figure frontale est mise en non attestée.
- **ep-010 :**
  - K se réduit à Peter @i Apostle, avec sa source.
  - La variante `composition` (`contradictoire`) est remplacée par une variante `changement_de_portee` (`non_certifiee`). La contradiction passait par la négation de « book », un mot polysémique, et n'était donc pas fondée sous D30.
- **ep-012 :** une `decision_ouverte` sur l'incompatibilité est ajoutée (inconnue ; écartée si l'incompatibilité était attestée), ainsi qu'une variante `changement_de_portee` (`non_certifiee`).
- **ep-016 :** une variante `changement_de_portee` (`non_certifiee`) est ajoutée, puisque #5 est devenue `inconnue`.
- **ep-018 et ep-019 :** les entrées de K sont sourcées (slay%2:41:00:: @ kill%2:35:00:: ; climb_up et climb sont un même synset).
- **ep-020 :** l'alias Moïse / Moses est écrit (non attesté) ; #4 (« ne le frappe pas encore ») passe à `inconnue` (point 1).
- **ep-021 :** K est vide ; la justification cite le § 4.1 (entre `non_certifiee` et `inconnue`, inconnue).

## 3. Ce qui reste une limite, déclarée et non corrigée

- **Les mots français et leur sens anglais.** Pour les verbes et les noms, le passage d'un mot français à un sens par WOLF est implicite (§ 4.1). Mais je n'ai pas vérifié, mot par mot, que **chaque** sens WOLF d'un mot français (sortir, porter, prendre, frapper, tenir…) atteint le lemme anglais de la définition, ce que D30 exige pour un lien positif certain. Les cas français en `etablie` le sont sous cette réserve. C'est la question 3 de la relecture B.
- **Les prépositions françaises.** devant, derrière, au-dessus de et de n'ont aucune ressource lexicale. Je les traite comme un travail de la lecture, et seul le polysème « de » reçoit une hypothèse de sens quand la définition fixe une relation.
- **ep-005#2 et ep-013#2 :** ces traductions disent « de » là où la définition dit « 's » ou « of ». Elles gardent le statut de leur cas de base, ce qui suppose que « de », « of » et « 's » aient le même ensemble de sens de relation. Rien ne l'atteste.

## 4. Harmonisation (BANCS § 4.1, point 2, « Ce que D30 dit exactement »)

**La méthode.** J'ai repassé chaque mot dont dépend un atome de la définition, dans le cas de base et dans chaque
variante.
- **Lien positif :** chaque sens du mot du texte doit atteindre le lemme de la définition par `@` et `@i`, puis par
  la lexicalisation.
  - Pour l'anglais, j'ai lu les sens dans `index.*` et `data.*`.
  - Pour le français, j'ai pris les sens de WOLF (`sens_fr.py`).
- **Négation :** chaque sens du type demandé doit être inclus dans chaque sens du mot nié.
- **Les mots de relation** (prépositions, possessifs, connecteurs) n'ont de sens ni dans WordNet ni dans WOLF : « de »,
  « sur », « pour », « pendant que », « tandis que », « sa », « his », « with ». Chacun n'est donc que lui-même
  (NOYAU § 2, D20).
  - Le même mot des deux côtés donne un lien certain.
  - Deux mots différents ne donnent **aucun** lien, pas même une hypothèse.
  - Les compléments d'un événement (source, but, lieu, instrument) sont des rôles, sans mot de relation.
- Les définitions sont gardées telles quelles.

**Le bilan des statuts.** Comptés sur le cas de base et chaque variante :

| sens du changement | nombre |
|---|---|
| plus fort | 1 |
| plus faible | 32 |
| latéral (même statut, autre hypothèse) | 1 |

**Plus fort (1) :**
- **ep-015#2**, la traduction anglaise, passe d'ESH [sens] à `etablie`. « The giant's sword » emploie le même mot de
  relation, « 's », que « Goliath's own sword ». Le choix de sens imposé par la révision était donc à tort.

**Latéral (1) :**
- **ep-020#3** passe d'ESH [identite] à ESH [sens]. L'alias Moïse / Moses est attesté par WOLF (11193392-n), et le
  K est mis à jour. Mais frapper, rocher, bâton et eau n'atteignent leur lemme que par une partie de leurs sens WOLF.

**Plus faible : les mots de relation français sans lien (aucun lien, donc `inconnue`).**
- **ep-004 :** le cas de base et les variantes #1, #2, #5 et #6 passent d'ESH [sens] à `inconnue`. Le possessif
  (« sa », « his ») n'est pas « with ».
- **ep-011 :** le cas de base et les variantes #1 et #5 passent d'ESH à `inconnue`. « Sur » n'est pas « on ». La
  traduction anglaise reste ESH [sens, equivalence_non_attestee] ; crown_of_thorns n'atteint crown que par 1 sens
  sur 3.
- **ep-015 :** le cas de base et les variantes #1 et #6 passent d'ESH à `inconnue`. « Du » n'est pas « 's ».
- **ep-022 :** le cas de base et les variantes #1 et #6 passent d'ESH [hypothese_interpretative] à `inconnue`.
  « Pendant que » et « tandis que » ne sont pas « while ».
- **ep-005#2, ep-006#3 et ep-013#2** passent d'`etablie` ou d'ESH à `inconnue`. Ce sont « de la tête du Christ »,
  « sa tête » et « la tête du Baptiste ». ep-005#2 dit aussi « plane », absent de WOLF.
- **ep-019#2** passe d'`etablie` à `inconnue` : « pour voir » n'est pas « in order to ».
- **ep-003#3** passe d'`etablie` à `inconnue`. La définition relie farmyard et cart par « with », que le texte ne
  dit pas. Seule la notice citée (#7) dit « a farmyard with a cart » (`non_certifiee`).

**Plus faible : les mots lexicaux français dont un sens WOLF n'atteint pas le lemme.**
- **ep-007 :** le cas de base et les variantes #1 et #6 passent d'`etablie` à `inconnue`.
  - « Couché » n'est pas dans WOLF, et « coucher » n'y donne que lay / put_down : aucun lien vers lie.
  - Devant et derrière ne sont, de plus, qu'en hypothèse.
  - La traduction anglaise reste `etablie`.
- **ep-009 :** #3 passe d'`etablie` à `inconnue`, et #7 de `non_certifiee` à `inconnue`.
  - « Élus » n'a dans WOLF qu'un sens, un jeu de cartes ; « damnés » est absent.
  - La `decision_ouverte` est réécrite : le cadre de référence ne décide plus rien sans lien lexical.
- **ep-017 :** le cas de base et les variantes #1 et #6 passent d'`etablie` à ESH [sens].
  - Les mots en cause : tuer (die), lion (capricorn), prendre, avant (ahead, above).
  - Une `decision_ouverte` est ajoutée (`tous_les_sens` / `sens_fixe_par_le_contexte`).
  - La traduction anglaise reste `etablie`.
- **ep-002#3, ep-010#2 et ep-014#4** passent d'`etablie` à ESH [sens], chacune avec sa propre `decision_ouverte`.
  Les mots en cause sont frapper ; Pierre, tenir, livre, gauche, main ; Dieu et bénir.
- **ep-002#6 et ep-014#7** passent de `non_certifiee` à `inconnue`, avec une `decision_ouverte` de variante. La vérité
  dite par la source passe par un lien qui n'est qu'une hypothèse. Entre `non_certifiee` et `inconnue`, le plus
  prudent est `inconnue` (§ 4.1).

**Inchangés après vérification :**
- **les cas anglais :** les mêmes lemmes des deux côtés, ou des liens certains. St._Peter n'a qu'un sens, instance
  d'Apostle ; climb_up est dans le synset de climb ;
- **les négations :** crow, wash, cart, kiss, hold, beard, leaf et frapper sont possibles, donc `inconnue`. Kneel est
  certaine, donc ep-008#3 reste `ecartee`.

**Les variantes ajoutées (3).** Ce sont des négations certaines, en `changement_de_modalite`, toutes `ecartee`, pour
rendre une variante de statut différent aux cas français devenus `inconnue` :

| cas | négation | sens WOLF | sens anglais |
|---|---|---|---|
| ep-007 | « ne s'agenouille pas » | 1 | kneel%2:35:00::, 1 sens |
| ep-015 | « ne le décapite pas » | 1 | behead%2:35:00::, 1 sens |
| ep-022 | « aucun tombeau n'est figuré » | 1 | tomb%1:06:00::, 1 sens |

L'alias Jérôme / Jerome est ajouté, attesté par WOLF (11083064-n). Pour ep-001, Jonas / Jonah est attesté par WOLF
(11089868-n).

**Ce qui reste non conforme, et qu'aucune réécriture honnête ne règle.** Six cas français n'ont plus de variante de
statut différent par la portée, la modalité, le temps ou l'inversion : ep-002, 004, 006, 009, 011 et 014.
- Tout atome positif y passe par un mot français dont un sens WOLF manque, ou par un mot de relation sans lien.
- Aucune négation certaine n'y est constructible : tous leurs mots sont polysémiques.
- Leur traduction anglaise diffère parfois du cas de base, et la relation métamorphique de la traduction (QS § 2.2)
  est alors violée par le K, non par le cas.

**La question, à poser.** Les mots de relation (de / of, sur / on, pour / in order to, pendant que / while, sa /
with) n'ont aucun sens dans les ressources implicites de K.
- **Conséquence :** toute définition anglaise qui contient une relation est inconnue pour toute description française,
  et pour toute paraphrase anglaise qui change le mot de relation.
- **Ce qu'il faudrait :** une table de relations (AUDIT § 3.5, (3) : « le mot de la relation devient un concept »),
  ou le dire comme une limite voulue des bancs.

**Les cas de base, par statut :**

| statut | nombre | cas |
|---|---|---|
| `inconnue` | 18 | |
| `etablie_sous_hypotheses` | 3 | ep-001, 013, 017 |
| `etablie` | 3 | ep-005, 010, 019 |

**Les `decision_ouverte` :** 15 au niveau des cas, et 6 sur des variantes.

**Le validateur :** `24 cas de base, 149 variantes, 0 erreurs ; composés ≥2 : 21, ≥3 : 7`.

### 4.1 Précision : les rôles et les relations ne passent pas par K (BANCS § 4.1, point 2, dernier tiret)

**Ce qui change.** Les prépositions, les possessifs et les connecteurs (de, sur, pour, pendant que, tandis que, au-dessus
de, sa, his, with…) sont des concepts du langage d'assertions, produits par la lecture. Ils ne sont pas soumis à la
règle des sens de K.
- La « cause 1 » de la section 4 était donc fausse : leur absence de WordNet et de WOLF ne rend aucun lien
  `inconnue`.
- **La règle appliquée maintenant :**
  - la même construction des deux côtés donne une relation certaine. C'est le cas du génitif (de, of, 's, possessif)
    contre le génitif ;
  - une construction polysémique du texte (de, 's, possessif) donne une hypothèse `sens`, avec une
    `decision_ouverte`, quand la définition fixe une lecture : « with » (avoir une partie), « own » (possession), le
    composé de matière ;
  - la cause 2, les mots lexicaux par WOLF, est gardée telle quelle.

**Les statuts changés : 19 plus forts, 1 plus faible.**
- **ep-004 :** le cas de base et les variantes #1, #2, #5 et #6 passent d'`inconnue` à ESH [sens]. « Sa » et « his »
  contre « with » : la lecture partie ou possession. S'y ajoute « ermite » (WOLF).
- **ep-006#3** (temps) passe d'`inconnue` à ESH [sens]. « Au-dessus de » et « sa tête » sont des relations de la
  lecture ; ange, tenir, couronne, Vierge et tête sont en hypothèse par WOLF.
- **ep-011 :** le cas de base et les variantes #1 et #5 passent d'`inconnue` à ESH [sens, equivalence_non_attestee].
  « Sur » ne bloque plus. Restent le « de » de matière, le composé non attesté et WOLF.
- **ep-013#2** (fr) passe d'`inconnue` à ESH [identite, sens]. « De » et « of » sont le même génitif ; s'y ajoutent
  l'alias non attesté et tête, tenir, plat (WOLF).
- **ep-015 :** le cas de base et les variantes #1 et #6 passent d'`inconnue` à ESH [sens]. « Du » est polysémique, et
  « own » fixe la possession.
- **ep-015#2 (en) redescend** d'`etablie` à ESH [sens]. C'est le seul changement plus faible : « the giant's » est
  un génitif polysémique, et la définition fixe la possession. La remontée de la section 4 reposait sur la règle,
  fausse, « même mot, lien certain » pour une relation que la définition précise.
- **ep-019#2** (fr) passe d'`inconnue` à ESH [identite, sens]. « Pour » est une relation de but de la lecture ;
  « voir » est en hypothèse par WOLF. L'alias Zachée / Zacchaeus est écrit dans K, non attesté : ni WordNet ni WOLF
  ne le donnent.
- **ep-022 :** le cas de base et les variantes #1 et #6 passent d'`inconnue` à ESH [sens, hypothese_interpretative].
  « Pendant que » ne bloque plus. Restent « soldat » (WOLF, troop) et l'identification interprétative.
- **ep-002#6 et ep-014#7** (les notices citées) reviennent d'`inconnue` à `non_certifiee`. Je corrige ici mon propre
  raisonnement de la section 4 :
  - un lien positif partiel reste un appui, et la valeur de la substitution est vraie ;
  - l'hypothèse de sens ne porte que sur la certification (NOYAU § 2 et § 4.3) ;
  - une source citée n'étant jamais certifiable, le statut est `non_certifiee` sous les deux options, et ces deux
    variantes perdent leur `decision_ouverte`.
  - Les verdicts lexicaux de la cause 2 ne changent pas.

**Inchangés :**
- **ep-005#2 :** « plane » n'est pas dans WOLF, c'est la cause 2, donc la variante reste `inconnue`. « De la tête du
  Christ » contre « Christ's head » est le même génitif, donc certain.
- **ep-003#3 :** « farmyard with a cart » demande une relation entre la cour et le chariot, que le texte ne dit pas.
  Il dit seulement « etching of a farmyard » et « behind her stands a cart ». La lecture ne la produit pas, et la
  variante reste `inconnue`. Seule la notice citée (#7) la dit.
- **ep-009 :** il reste sans variante de statut différent. « Élus » et « damnés » n'ont aucun lien WOLF (cause 2),
  et aucune négation certaine n'y est constructible. Le cadre de « à droite » reste une question ouverte (§ 4.1).
- **Les variantes de statut différent sont rétablies** pour ep-002 (#6), 004 (#4), 006 (#3), 011 (#4 et #6) et 014
  (#7).

**Les cas de base, par statut :**

| statut | nombre | cas |
|---|---|---|
| `inconnue` | 14 | |
| `etablie_sous_hypotheses` | 7 | ep-001, 004, 011, 013, 015, 017, 022 |
| `etablie` | 3 | ep-005, 010, 019 |

**Les `decision_ouverte` :** 15 sur les cas, 7 sur les variantes.

**Le validateur :** `24 cas de base, 149 variantes, 0 erreurs ; composés ≥2 : 21, ≥3 : 7`.
