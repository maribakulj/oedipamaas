# Révision de compositionnalite (co-) après la relecture A

**Ce qui a été fait :**
- relu BANCS_PHASE1 § 4 (les valeurs admises) et le nouveau § 4.1 ;
- traité un à un les désaccords de `relecture_A.md` qui portent sur `co-` ;
- appliqué le § 4.1 à tous les cas.

**Les outils :**
- les faits de WordNet ont été vérifiés par `sens.py` et par une lecture directe de `data.*` et `index.sense`
  (pointeurs `@`, `@i`, `%p`, `>`) ;
- la version 1 est gardée dans mon répertoire de travail, et non dans `dev/`.

**Le validateur :** 24 cas de base, 141 variantes, 0 erreur ; composés ≥ 2 : 21, ≥ 3 : 8 (quotas atteints).

**Une convention, dite parce qu'elle décide de beaucoup de statuts.** La requête d'une définition est typée par des
**sens** (FONDEMENTS § 2.7 : les connaissances portent sur des sens), et non par des lemmes.
- Un mot polysémique de la description ne donne donc un lien certain que si **tous** ses sens atteignent le sens
  demandé (NOYAU § 2, D30).
- Presque aucun mot courant ne le fait. Par le § 4.1, 2, presque tous les cas positifs passent donc de `etablie` à
  `etablie_sous_hypotheses` [sens], avec une `decision_ouverte` (`tous_les_sens` / `sens_fixe_par_le_contexte`).
- Si la propriétaire décide que la requête est typée par le lemme (la lexicalisation de NOYAU § 2 rendrait alors
  certain un mot identique des deux côtés), une bonne part de ces statuts redevient `etablie`.

## 1. Les désaccords de la relecture

| désaccord | décision | ce qui a changé, ou pourquoi |
|---|---|---|
| **co-016**, et #1, #2, #5, #6 : little_girl ⊑ child donné pour attesté, faux | **corrigé** | Vérifié : little_girl%1:18:00:: ⊑ female ⊑ person, sans child. L'entrée fausse est retirée. La définition dit maintenant « girl », au sens girl%1:18:02::, le synset même de little_girl. Plutôt que de laisser un cas positif sans lien, je corrige la définition. Les statuts passent à `etablie_sous_hypotheses` [sens], à cause de lead et hand (§ 4.1, 2). |
| **co-008**, et #1, #2, #5, #6 : « former est privatif » attesté sans ressource ; mauvais sens | **corrigé** | Le pivot passe à former%5:00:02:past:00 (le sens des personnes). L'entrée est mise à `attestee: false`. Le statut passe de `ecartee` à `inconnue`, avec une `decision_ouverte` : privatif → `ecartee` ; ancrage antérieur exclusif → `ecartee` ; ancrage non exclusif avec abduction par les attributs → esh ; rien de fixé → `inconnue` (retenu). Elle renvoie à celle d'ee-009. La connaissance typique « mitre et crosse » passe à `attestee: false` (aucune ressource). La définition et la description sont simplifiées (« before a cave » : grotto ⊑ cave dans WordNet), pour que les variantes positives ne demandent pas un lien désert → wilderness absent de K. |
| **co-009**, et #1, #2, #5 : même cause | **corrigé** | Même traitement : `inconnue`, avec une `decision_ouverte`. L'alias Vasthi ⇔ Vashti est écrit en `identite_documentaire` non attestée ; il ne sert pas à la définition. La description dit « leaves the palace », au lieu de « walks out through the palace gate », pour éviter une équivalence non dite. |
| **co-010#3** : haranguer ⇔ preach attesté à tort | **corrigé** | Vérifié : harangue%2:32:00:: n'est ni synonyme ni hyponyme de preach. L'entrée est retirée, et la définition dit « haranguing a group of soldiers ». #3 passe à esh [sens]. |
| **co-023#5** : « uncrowned » traité comme une négation | **corrigé** | `ecartee` → `inconnue`. La `decision_ouverte` donne `ecartee` si une incompatibilité (ou une négation morphologique) attestée était admise (§ 4.1, 3). |
| **co-015#3** : tendre ⇔ give, et « sa fillette » ⇒ « her daughter » | **corrigé** | La définition dit « mother holding out an apple to a little girl », et #3 « à une fillette » (le possessif ne dit pas la filiation). « tendre ⇔ hold out » est écrit, non attesté. #3 passe à esh [sens, equivalence_non_attestee]. **Une erreur de plus, que la relecture n'a pas vue :** la version 1 disait qu'aucun sens de « belle-mère » n'atteint mother. C'est faux : mother-in-law%1:18:00:: ⊑ mother%1:18:00:: (pointeur `@`). La base dépend donc du sens : esh sous `tous_les_sens`, `inconnue` sous le sens fixé par le contexte (« la fillette de son époux »). `inconnue` est retenu, avec une `decision_ouverte`. |
| **co-002** : apostle%1:18:02 ⊑ man, faux | **corrigé** | L'entrée est retirée. La justification dit qu'apostle%1:18:00:: n'atteint que person, ce qui renforce `inconnue`. |
| **co-023** : « at the right hand of ⇔ beside » écrit comme une équivalence | **corrigé** | La définition dit maintenant « seated at the right hand of Christ », comme le texte : aucune connaissance n'est plus nécessaire. L'entrée est retirée. |
| **Forme de K** (co-001, 002, 006, 009, 013, 017, 018, et les correspondances fr → en) | **corrigé** | Les entrées tautologiques (« X est le type demandé par x ») sont retirées. Les correspondances entre un mot français et un sens passent par WOLF, implicite (§ 4.1, 1) : elles sont retirées de K. Restent écrites, `attestee: false`, les équivalences entre expressions (« vêtu de ⇔ in », « tendre ⇔ hold out », « trancher son manteau… ⇔ cut his cloak in two ») et les alias de noms. |
| **co-013#1** : l'hypothèse `sens` sans fondement | **corrigé** | La connaissance typique de matière couvre maintenant « N de N(matière) » comme « N(matière) N ». La traduction porte les mêmes hypothèses que la base, [connaissance_typique, sens]. |
| **co-012#3** : la variation n'est pas un changement de portée | **corrigé** | Elle est renommée `changement_de_participant` (le lieu figuré, un référent, change). La description dit « dans un paysage de montagnes », au lieu d'« un alpage », pour ne pas demander alpage → paysage de montagne (signalé en qualité). Statut esh [sens]. |
| **co-019**, et #1, #2, #6 ; #3 : le pluriel, et « e.g. » | **corrigé** | La description a maintenant deux instruments, tous deux exemples (un luth et une viole). La base ne dépend plus ni du pluriel ni de la lecture de la liste ; elle dépend des sens (esh [sens]). #3 (une chalemie et une flûte à bec) a maintenant une `decision_ouverte` : liste fermée → `inconnue` (retenu) ; liste ouverte → esh. |
| **co-018#4** : le raisonnement par cas sans `decision_ouverte` | **corrigé** | Il est porté par la `decision_ouverte` du cas : sans raisonnement par cas → `inconnue` (retenu) ; avec → esh. |
| **D1, co-018#5** : la négation d'un verbe polysémique (read) | **corrigé** | `ecartee` → `inconnue`. La `decision_ouverte` donne `ecartee` si la négation est certaine et si D41 est levée. |
| **Qualité, co-002** : aucune variante ne change de statut par la modalité, la portée, le temps ou une inversion des rôles | **corrigé** | #3 est renommée `changement_de_modalite` : « young » passe du non-dit (le superlatif) à l'affirmé (« is shown as a young man »). |
| **Qualité, co-014** : même remarque | **corrigé** | #3 est une vraie variante de portée : l'ange passe du décor sculpté (un contexte emboîté) au monde figuré (« un ange vivant, apparu dans la lumière »). Statut esh [sens]. |
| **Qualité, co-015** : même remarque | **contesté** | La condition qui manque à la base est un **type** (belle-mère n'est pas mère). Aucun changement de portée, de modalité ou de temps ne fait d'une belle-mère une mère sans changer le participant, et une inversion des rôles n'élève jamais un statut (BANCS § 4 ; NOYAU § 4.4). Le § 4 donne ces quatre variations après deux points, comme les exemples d'une variante de statut différent, et non comme une liste fermée. La variante de participant (#3) la remplit. Inventer une portée ou une modalité serait une variante factice. La même raison vaut pour co-012. |
| **Qualité, co-004#4** : « Ce lynx n'a rien de mythique », formule peu plausible | **corrigé** | Réécrit en phrase de notice (« À la différence des créatures mythiques peintes dans les feuillets voisins, ce lynx n'est pas mythique… »). « mythique » a un seul sens : `ecartee` est gardé, ce que la relecture admet. |
| **Question 11** : co-014 ne renvoie pas à la décision sur les figurations emboîtées | **corrigé** | La justification et la `decision_ouverte` renvoient à la décision ouverte d'ee-023. |
| **Question 12** : co-006 tient le sens pour fermé par le contexte | **corrigé** | Il ne l'est plus. La restriction de sélection (« red », d'un vêtement) est écrite en K, `attestee: false`. Le cas passe à esh [sens], avec une `decision_ouverte`. |
| **Question 10** : le sens de `attestee` pour une connaissance typique | **corrigé** | Toutes les connaissances typiques de co- sont `attestee: false` (aucune ressource nommée). La seule connaissance typique qui avait `true` (co-008) est corrigée. |

## 2. Les autres changements, par le § 4.1

**Les sources.** Il reste trois connaissances `attestee: true`, chacune avec un `source` :
- **co-003 et co-004 :** fabulous%5:00:00:unreal:00 est un modificateur de mode d'existence, d'après FONDEMENTS § 1.2
  (entrée nommée, « fabulous animals », « lynx fabuleux ») et le synset WordNet (mythical en est membre) ;
- **co-005 :** imaginary%5:00:00:unreal:00, d'après FONDEMENTS § 1.2 (« une créature imaginaire ») ;
- **co-011 :** kill%2:35:00:: cause die%2:30:00::, par le pointeur `>` de data.verb.
- **Une réserve, que je signale :** tenir un document de la propriétaire pour une attestation est mon interprétation
  du § 4.1 (« une entrée nommée »). Si ce n'est pas admis, co-003 et co-005 portent aussi `equivalence_non_attestee`,
  sans changer de statut.

**Les gloses et les hypothèses de rédaction.** Elles sont passées à `attestee: false`, et leur sorte est corrigée quand
il le faut :
- co-011 : « slayer » est une glose seule, donc `relation_inconnue`. L'hypothèse devient [relation_inconnue, sens] ;
- co-010 : la glose de « alleged » ;
- les classes de verbes (inaccusatif, inergatif, transitif résultatif) en co-020 à co-024 ;
- la conséquence dead ⇐ die en co-011 ;
- la relation implicite du composé de lieu en co-012.

**Le régime des sens.** Il ajoute 21 `decision_ouverte` (il y en avait 3 ; il y en a 24, une par cas).
- **Cas de base passés de `etablie` à `etablie_sous_hypotheses` [sens] :** co-001, 003, 005, 006, 016, 017, 018,
  019, 021, 023.
- **Cas de base qui ne dépendent d'aucun sens :** co-004, 007 (« pommelé », un seul sens), 020, 022, 024. Leur
  `decision_ouverte` porte sur les variantes positives.

**Les alias de noms.** Ils sont écrits en `identite_documentaire` non attestée :
- **Salomé ⇔ Salome** (co-022). Les variantes #3 et #4 passent à esh [sens, identite]. La définition ne nomme plus
  Hérode : il n'y avait aucun alias Hérode ⇔ Herod ;
- **saint Pierre ⇔ Saint Peter** (co-024, #3 : esh [sens, identite]) ;
- **Vasthi ⇔ Vashti** (co-009, sans effet).

**Les incompatibilités** (§ 4.1, 3) :
- **co-012, la base :** une ville et un paysage de montagne. Le statut reste `inconnue`, avec l'option
  `incompatibilite_attestee` → `ecartee` ;
- **co-001#3 :** homme et femme ;
- **co-023#5 :** crowned et uncrowned ;
- **co-006#4 :** bleu et rouge. Elle reste `inconnue` dans les deux options.

**Les extensions sur une variante**, désormais admises :
- co-003#3 et co-021#3 ajoutent `contenu_d_inscription` ;
- co-022#4 (la narration continue) ajoute `plusieurs_situations` et `identite_entre_situations`.

**Les définitions modifiées,** pour que le statut ne repose pas sur une connaissance non dite :
- co-001 « old woman spinning » : la quenouille instrument contre la quenouille objet ;
- co-008 « … before a cave » ;
- co-009 « queen leaving a palace » ;
- co-010 « haranguing » ;
- co-015 « to a little girl » ;
- co-016 « girl » ;
- co-017 : sans « and Child » ;
- co-021 « with a vine twining about its trunk » ;
- co-022 « Salome dancing » ;
- co-023 « at the right hand of Christ ».

## 3. Le bilan des statuts

**Avant et après :**
- **cas de base :** 10 `etablie`, 2 esh, 3 `ecartee`, 9 `inconnue` → 0 `etablie`, 12 esh, 1 `ecartee`, 11 `inconnue` ;
- **variantes :** 44 `etablie`, 9 esh, 13 `ecartee`, 75 `inconnue` → 0 `etablie`, 53 esh, 4 `ecartee`, 84 `inconnue`.

**Les statuts changés : 65 (12 cas de base, 53 variantes), tous vers le plus faible.**
- `etablie` → esh : 10 cas de base et 44 variantes ;
- `ecartee` → `inconnue` : 2 cas de base (co-008, co-009) et 9 variantes (co-008 #1, #2, #5, #6 ; co-009 #1, #2, #5 ;
  co-018#5 ; co-023#5) ;
- aucun vers le plus fort.

**Les `decision_ouverte` :** 3 avant, 24 après.

**Les sortes ne changent pas :** 12 positifs, 7 négatifs ou contre-modèles, 5 indéterminés.
- Deux cas de sorte « négatif » (co-008) ou « contre-modèle » (co-009) ont maintenant le statut `inconnue`.
- La sorte dit l'intention du cas (le texte vise le contraire), et le statut dit ce que les documents permettent de
  conclure.

## 4. Harmonisation (BANCS_PHASE1 § 4.1, 2, « Ce que D30 dit exactement »)

**Ce qui change par rapport à la révision.**
- La révision typait la définition par des **sens**. La règle la type par des **lemmes**.
- Un lien est certain si **chaque sens du mot du texte** atteint le lemme de la définition (par `@`, `@i`, puis la
  lexicalisation). Le même lemme des deux côtés est donc certain.
- Une négation est certaine si chaque sens du lemme demandé est inclus dans chaque sens du mot nié.
- Les mots français prennent les sens de WOLF (`sens_fr.py`), et non ceux du mot anglais.
- J'ai tout recalculé, base et variantes, avec un petit outil personnel qui ne lit que WordNet et la sortie de
  `sens_fr.py`. Il est dans `lien_co.py`, dans mon répertoire de travail.
- Quand le statut dépend d'un sens, la `decision_ouverte` garde les deux options, et le statut retenu est celui de
  `tous_les_sens`. Plusieurs variantes portent maintenant leur propre `decision_ouverte`.

**Bilan : 31 statuts changés (6 de base, 25 variantes), dont 25 plus forts et 6 plus faibles.**

**Plus forts : remontés à `etablie`.** Les mots du texte sont les lemmes de la définition. C'est l'affaiblissement à
tort de la révision qui est corrigé.
- **cas de base :** co-001, co-006, co-016, co-017, co-018 ;
- **variantes :** co-001 #2, #5, #6 ; co-005#1 ; co-006 #2, #6 ; co-007#3 ; co-009#3 ; co-016 #2, #5, #6 ;
  co-017 #2, #5 ; co-018 #2, #6 ; co-021#1.

**Plus fort, de `inconnue` à `etablie_sous_hypotheses` : co-015 et #2, #5, #6.**
- « belle-mère » a dans WOLF deux sens, mother-in-law (⊑ mother) et stepmother.
- Le statut de `tous_les_sens` est donc établi sous l'hypothèse de sens (et sous l'équivalence non attestée
  « tendre ⇔ hold out »). Le sens fixé par le contexte, stepmother, donnerait `inconnue`, que la décision garde.
- La sorte reste `contre_modele`. **À juger par la propriétaire :** la règle fait d'un contre-modèle voulu un cas sous
  hypothèse.

**Plus faibles.**
- **co-004#4, de `ecartee` à `inconnue` :** la négation de « mythique » (un sens) n'est que possible contre le lemme
  « fabulous », qui a trois sens. La relecture avait accepté `ecartee`, en raisonnant sur le sens et non sur le lemme.
- **co-007#1, de `ecartee` à `inconnue` :** « pommelé » est absent de WOLF.
- **co-001#1 :** « filer » n'a dans WOLF que le sens get_cracking.
- **co-011#1 :** « tueur » est absent de WOLF.
- **co-018#1 :** « moniale » est absente de WOLF.
- **co-023#1 :** « couronner » et « couronné » sont absents de WOLF.
- Les quatre derniers passent de `etablie_sous_hypotheses` à `inconnue`. Chacun porte une `decision_ouverte` : si WOLF
  avait le mot, le statut serait celui de l'anglais. **L'invariance de la traduction est rompue par la couverture de la
  ressource, non par la sémantique.** C'est une mesure, et je l'ai gardée telle quelle.

**Les changements de langue de la base.** Je les ai faits pour garder un cas de base qui teste le phénomène, et non une
lacune de WOLF.
- **co-001 et co-007 passent en anglais :** « filer » et « pommelé » sont absents ou inutilisables. La version
  française devient la traduction, avec son statut.
- **co-002 et co-020 passent en français,** pour l'équilibre des langues (12 et 12). Leur statut ne dépend d'aucun
  sens.

**Les mots du texte changés, et jamais ceux d'une définition.**
- **co-021 :** « desséché » devient « flétri ». « dessécher » et « desséché » sont absents de WOLF, ce qui rendait le
  cas inconnu sans rien tester. « flétrir » a un seul sens, wither%2:30:01::, et le pivot le suit.
- **co-010 :** le texte dit « prêche », et la définition reprend son mot de la version 1 (« preaching »).
  - « haranguer » n'a dans WOLF que le sens orate.
  - La révision avait réécrit la définition en « haranguing » : elle est rétablie, conformément à la consigne de ne pas
    réécrire une définition avec les mots du texte.
  - Le pivot suit WOLF : alleged%5:00:00:questionable:00.

**Une réserve.** La révision avait déjà retouché neuf définitions : co-001, co-008, co-009, co-015, co-016, co-017,
co-021, co-022 et co-023.
- Chaque fois, c'était pour retirer une connaissance fausse ou non fondée que la relecture avait relevée.
- Je ne les ai pas défaites. Aucun de ces pas lexicaux n'était le phénomène testé par le cas.
- La propriétaire peut juger qu'il fallait les garder, avec un statut prudent.
- Le cas le plus net est co-016 : « child » devient « girl ». Avec « child », la base serait `inconnue`, puisque
  little_girl n'atteint pas child.

**Après l'harmonisation.**
- **cas de base :** 5 `etablie`, 8 `etablie_sous_hypotheses`, 1 `ecartee` (co-007), 10 `inconnue` ;
- **variantes :** 16 `etablie`, 36 `etablie_sous_hypotheses`, 2 `ecartee`, 87 `inconnue`.

**Le validateur :** 24 cas, 141 variantes, 0 erreur, quotas atteints (composés ≥ 2 : 21, ≥ 3 : 8).
