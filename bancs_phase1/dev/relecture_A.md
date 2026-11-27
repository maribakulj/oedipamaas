# Relecture A : événements et états, compositionnalité, structures argumentales

**Ce qui est relu :** `evenements_etats.json` (`ee-`), `compositionnalite.json` (`co-`) et
`structures_argumentales.json` (`sa-`), avec leurs fichiers `.questions.md`. Ces fichiers n'ont pas été modifiés.

**Les documents lus :** `docs/BANCS_PHASE1.md` (§ 4 surtout), `docs/FONDEMENTS_SEMANTIQUES.md`,
`docs/ONTOLOGIE_EVENTUALITES.md`, `docs/SPECIFICATION_OPERATIONS.md`, `docs/NOYAU.md` (§ 1, § 2, § 4.4) et
`docs/QUALIFICATION_SEMANTIQUE.md` § 2.

**Le seul outil employé :** WordNet 3.0, par `outils/bancs/sens.py` et par une lecture directe de `data.*` et
`index.sense`, pour suivre les pointeurs `@`, `@i`, `&`, `+`, `=` et `!`. Aucun code n'a été lu, aucune sortie du
système non plus.

**Comment lire ce rapport.** Je n'ai tranché aucun désaccord : chacun est listé. Plusieurs reprennent une question que
le rédacteur a lui-même posée dans son fichier `.questions.md`. Je le signale par « (signalé : X) », mais le
désaccord est compté quand le statut écrit n'est pas le plus prudent, ou quand aucun champ `decision_ouverte` ne le
porte.

## 1. Le résumé chiffré

| famille | cas de base | variantes | total relu |
|---|---|---|---|
| evenements_etats | 24 | 155 | 179 |
| compositionnalite | 24 | 141 | 165 |
| structures_argumentales | 24 | 141 | 165 |
| **total** | **72** | **437** | **509** |

Le tableau du § 2 a **33 lignes**. Certaines regroupent plusieurs cas ou variantes de même cause.

| gravité | lignes | cas ou variantes touchés |
|---|---|---|
| sûreté (statut plus fort que ce que les documents et K justifient) | 14 | 45 |
| trop faible | 2 | 2 |
| connaissance non fondée (sans effet propre sur le statut, ou déjà comptée en sûreté) | 5 | 11 cas, plus les correspondances fr → en |
| incohérence (entre variantes, ou entre familles) | 4 | 9 |
| décision ouverte mal posée | 4 | 41, dont 34 `ecartee` à risque de sûreté (ligne D1) |
| qualité | 4 | 15 |

**La vérification dans WordNet.** J'ai contrôlé **38 des 88 entrées** de `connaissances_supposees`, plus d'une sur
trois, et toutes les inclusions annoncées.
- **Confirmées (25) :**
  - les hyperonymies : rage ⊑ anger, jesus ⊑ person (par une instance), legionnaire ⊑ soldier, lion ⊑ animal,
    lynx ⊑ animal, lute ⊑ musical_instrument, shawm ⊑ musical_instrument, slayer ⊑ person, guardian_angel ⊑ angel ;
  - un même synset : mythical et fabulous (le sens `unreal`) ;
  - un sens unique : dappled, imaginary, mythical ;
  - une dérivation : flagellation ↔ flog, baptism ↔ baptize ;
  - une glose qui suffit : raise%2:29:00 (« raise from the dead ») ;
  - stepmother et mother-in-law non inclus dans mother (ce que dit le cas) ;
  - les clés de old, wither, imprison, crown, dance, alleged, hold, read, woman, wilderness, avec des gloses qui
    conviennent.
- **Fausses (5) :**
  - apostle%1:18:02 ⊑ man ;
  - little_girl ⊑ child ;
  - hand%2:40:00 ⊑ give%2:40:00 (ce sont deux synsets frères sous transfer) ;
  - « avoir peur ⇔ frightened » donné pour une équivalence (fear a pour attribut afraid ; frightened est un satellite
    d'afraid, glosé « made afraid ») ;
  - haranguer ⇔ preach.
- **Attestées sans ressource (5) :** « former » est privatif ; « blind » entraîne un aveuglement antérieur ; « ruin »
  entraîne une destruction (la condition est inventée) ; « écrire avec P ⇒ tenir P » ; « tendre ⇔ give ».
- **Fondées sur une glose seule (3) :** dormir ⇔ endormi (« sleep : be asleep »), sit ⇔ seated (« sit : be seated »),
  et le sens retenu pour former%5:00:01 (le sens qui convient est %5:00:02).

## 2. Les désaccords

**Les abréviations :**
- **esh** : `etablie_sous_hypotheses`.
- **Les documents :** **F** = FONDEMENTS_SEMANTIQUES, **O** = ONTOLOGIE_EVENTUALITES, **S** = SPECIFICATION_OPERATIONS,
  **N** = NOYAU, **B** = BANCS_PHASE1.

### 2.1 Sûreté

| id | gravité | statut écrit | statut proposé | raison | section |
|---|---|---|---|---|---|
| co-016, et ses variantes #1, #2, #5, #6 | sûreté (K non fondée) | etablie | inconnue (esh si l'on ajoute à K un lien girl → child non attesté) | La définition demande « child ». K donne little_girl%1:18:00 ⊑ child%1:18:00 pour attesté, mais c'est faux dans WordNet 3.0 : little_girl ⊑ female ⊑ person, sans passer par child. Il n'y a donc aucun lien positif. | B § 4 ; F § 2.7 ; N § 2 |
| sa-001, et ses variantes #1, #2, #6 | sûreté (K non fondée) | etablie | esh [sens], ou inconnue | « hand%2:40:00 ⊑ give%2:40:00 » est faux. hand%2:40:00 est le synset 02230772 {pass, hand, reach, …, give}, c'est-à-dire give%2:40:06 ; son hyperonyme est transfer, comme celui de give%2:40:00 : ce sont des frères. Au mieux, la définition est satisfaite par une lecture de « give » au sens 2:40:06, ce qui demande une hypothèse de sens, puisque « hands » a aussi le sens « guide ». | N § 2 (D30) ; F § 2.7 |
| ee-005, et ses variantes #1, #7 (etablie) et #3 (ecartee) | sûreté (K non fondée) | etablie ; ecartee pour #3 | esh [equivalence_non_attestee] ; inconnue pour #3 | « avoir peur ⇔ frightened%5:00:00:afraid:00 » est donné pour une équivalence établie et attestée. WordNet donne seulement fear avec pour attribut afraid, et frightened comme satellite d'afraid, glosé « made afraid », donc un état résultant. Ce n'est pas une équivalence attestée : elle ne canonise rien, et elle ne propage pas la négation de #3 (« n'a pas peur »). La paraphrase #2 (« effrayé ») n'en dépend pas. | F § 2.7, § 3.2, § 3.3 ; S § 1 |
| co-008, et ses variantes #1, #2, #5, #6 | sûreté | ecartee | ouvert : inconnue ; esh [connaissance_typique] par la mitre et la crosse ; ou ecartee | L'écart repose sur « former est privatif », marqué attesté sans aucune ressource. WordNet ne dit rien de tel, et le sens cité, %5:00:01, n'est pas celui des personnes (%5:00:02). F § 1.2 définit le privatif par « dans aucun contexte » ; un ancien évêque l'a été. C'est donc un état ou une fonction antérieure, c'est-à-dire la question de la `decision_ouverte` de ee-009 (les ancrages s'excluent-ils ?), que ee tranche au plus prudent par `inconnue`. Il faut une `decision_ouverte`. (signalé : co A4) | F § 1.2 ; O § 2, § 3 ; B § 4 |
| co-009, et ses variantes #1, #2, #5 | sûreté | ecartee | ouvert : inconnue au plus prudent | Même cause que co-008 : « the former queen » ne dit pas une non-reine dans aucun contexte, mais une reine qui ne l'est plus. Il faut décider entre un privatif et un ancrage antérieur. | F § 1.2 ; O § 2 |
| sa-024, et ses variantes #1, #3, #6 | sûreté | ecartee | ouvert : inconnue au plus prudent | La réfutation passe par une condition nécessaire, « écrire avec P ⇒ tenir P », marquée attestée. Aucune ressource ne la donne : la glose de write%2:36:01, « mark or trace on a surface », ne dit rien de la tenue. De plus, S § 2 dit que « `deduire` ne part que de prémisses positives » ; le rédacteur pose cette contradiction (Q16), mais garde `ecartee` sans `decision_ouverte`. | F § 2.7 ; S § 2, § 3 |
| co-010#3 | sûreté (K non fondée) | etablie | esh, ou inconnue | La définition dit « preaching », la variante « harangue ». K donne « haranguer ⇔ preach » pour attesté. Dans WordNet, harangue%2:32:00 ⊑ address/speak, et preach%2:32:02 (« deliver a sermon ») n'en est ni un hyperonyme ni un équivalent. | F § 2.7 ; N § 2 |
| ee-001, et ses variantes #1, #2, #6, #7 (etablie) et #4 (ecartee) | sûreté | etablie ; ecartee pour #4 | esh [equivalence_non_attestee], ou inconnue | La définition demande « asleep » (un adjectif) ; le texte dit « dort » (un verbe). K ne contient que sommeil (nom) ⇔ dormir (verbe). WordNet n'a aucun pointeur entre asleep et sleep%2:29:00, seulement la glose « be asleep », et asleep a trois sens (dont « dead »). Or une canonisation demande une équivalence établie (F § 3.2). Incohérence entre familles : sa-022 inscrit précisément « dormir ⇔ endormi » comme attestée. | F § 3.2 ; S § 1 ; B § 4 |
| co-023#5 | sûreté | ecartee | inconnue | « sits uncrowned » est un antonyme morphologique. Aucune connaissance de K ne dit qu'uncrowned entraîne la négation de crowned. Les rédacteurs de ee (A2) et de sa (Q12, `decision_ouverte` de sa-022) mettent `inconnue` pour un antonyme seul : cette variante tranche l'inverse sans le dire. | F § 2.7, § 3.3 ; B § 4 (pas de monde clos) |
| ee-002 et ses variantes #1, #2, #7 ; ee-023#3 | sûreté (K vide) | etablie | esh [sens], ou inconnue | La définition dit « giving ». Le texte dit « tend son manteau à » (tendre, c'est présenter ou offrir, non donner) ou « hands » (voir sa-001 : hand n'est pas inclus dans give%2:40:00). K est vide pour ces cas. | N § 2 ; B § 4 |
| co-015#3 | sûreté | etablie | esh, ou inconnue | « une mère tend une pomme à sa fillette » demande deux liens absents de K, ou posés sans ressource : « tendre ⇔ give » (attestée, sans source) et « sa fillette » ⇒ « her daughter » (fillette, c'est little girl, et le possessif ne dit pas la filiation). | B § 4 ; F § 2.7 |
| ee-013#3 ; sa-004#2 | sûreté (à confirmer) | etablie | ouvert : inconnue au plus prudent | Dans ee-013, la base exige le terme du mouvement (« walking to a town ») ; la variante ne dit qu'une direction (« towards … approaching its gate »). Dans sa-004, « vers l'Égypte » est lu comme « into Egypt ». La question direction / destination est ouverte (sa Q8), et ces deux variantes la tranchent dans le sens fort. | O § 1.2 ; AUDIT § 3.3, cité par les cas |
| ee-015#3 | sûreté (mineure) | etablie | inconnue, sauf si « before Perseus » n'est pas un atome | La définition demande « before Perseus ». La variante ne dit que « Perseus, at the right » et « in the centre a warrior » : aucune relation de position n'est appuyée. | N § 4.3 |
| sa-019#2 ; sa-022#2 | sûreté (connaissance fondée sur une glose) | etablie pour #2 de sa-019 ; ecartee pour #2 de sa-022 | esh pour sa-019#2 ; inconnue pour sa-022#2 | sit ⇔ seated et dormir ⇔ endormi sont marquées « attestées » sur la seule glose (« be seated », « be asleep ») ; WordNet n'a aucun pointeur entre ces mots. Or F § 2.7 dit : « le défaut d'une glose est relation inconnue ». Sans équivalence établie, la négation (« ne dort pas ») ne se propage pas. | F § 2.7, § 3.3 |

### 2.2 Trop faible

| id | gravité | statut écrit | statut proposé | raison | section |
|---|---|---|---|---|---|
| sa-007#5 | trop faible (incohérence entre familles) | inconnue | etablie, ou une `decision_ouverte` | « saint Luc, le pinceau levé, s'apprête à peindre » est la phase préparatoire. O § 1.2 la range expressément dans l'**en cours** (« Abraham s'apprête à sacrifier Isaac »), et ee-008 en tire `etablie`. | O § 1.2 |
| sa-016#4 | trop faible (incohérence entre familles) | inconnue | esh [sens] | « le Christ s'apprête à relever le fils » : même raison. La justification lit « s'apprête » comme une imminence, contre O § 1.2. | O § 1.2 |

### 2.3 Connaissance non fondée

| id | gravité | statut écrit | statut proposé | raison | section |
|---|---|---|---|---|---|
| co-002 | connaissance non fondée | inconnue | (inchangé) | « apostle%1:18:02 ⊑ man » est attesté à tort. C'est le mauvais sens (« ardent supporter of a cause » ; l'apôtre est %1:18:00), et aucun des deux n'atteint man, seulement person. Sans effet sur les statuts : #3 dit « a young man ». | B § 4 |
| ee-004 (base et variantes) | connaissance non fondée | esh [consequence_conditionnelle] ; etablie pour #3 | (le statut tient ; l'attestation n'est pas fondée) | « blind ⇒ un aveuglement antérieur, sauf de naissance » est marqué attesté, alors qu'aucune relation WordNet ne le donne (blinded est un satellite de blind, glosé « deprived of sight »). #3 emploie aussi stride ⊑ walk, réel dans WordNet mais absent de K. | F § 2.7 ; B § 4 |
| ee-018 | connaissance non fondée (mineure) | esh [consequence_conditionnelle] | (inchangé) | ruin%1:06:00, « a ruined building », avec un pointeur de dérivation vers ruin (verbe) : la base est plausible. La condition (« et non une lente dégradation ») n'a pas de ressource. | F § 2.7 |
| co-023 | connaissance non fondée (mineure) | etablie | (inchangé) | « at the right hand of ⇔ beside » est écrit comme une équivalence ; ce n'est qu'une implication (beside n'entraîne pas la droite). La direction positive suffit au cas ; une négation de « beside » mal propagée serait fausse. | F § 2.7 (direction de négation) |
| co-001, co-002, co-006, co-009, co-013, co-017, co-018, et les correspondances fr → en de co-003 à co-024 | connaissance non fondée (forme de K) | — | — | Des entrées d'« implication » sont tautologiques (« woman%1:18:00 est le type demandé par woman ») ; des correspondances lexicales français → anglais sont écrites `equivalence_etablie` attestée, sans ressource (aucun WordNet français n'est nommé). Elles gonflent K de fausses attestations. (signalé : co F2, ee D4) | F § 2.7 ; B § 4 |

### 2.4 Incohérence

| id | gravité | statut écrit | statut proposé | raison | section |
|---|---|---|---|---|---|
| ee-006#2 | incohérence | etablie (la base est esh) | la même que la base, ou une autre variation | Une paraphrase (« angry ») change le statut. La raison n'est pas dite dans le cas ; elle ne l'est que dans le fichier de questions. La relation métamorphique « même statut » est violée. (signalé : ee D2) | QUALIFICATION § 2.2 ; B § 7 |
| ee-011#3 | incohérence ; sûreté possible | etablie (la base est esh [sens]) | esh [sens], ou une `decision_ouverte` | « Icarus falls » : le verbe fall a une trentaine de sens, et seuls certains atteignent fall%2:38:00. L'écart avec la base ne tient donc pas à la forme verbale, comme le dit D2, mais à la fermeture du sens par le contexte (« headlong into the sea »), qui est la question de la `decision_ouverte` du cas. | N § 2 (D30) ; B § 4 |
| co-013#1 | incohérence | esh [sens] (la base est esh [connaissance_typique]) | esh [connaissance_typique], ou une `decision_ouverte` | La traduction change la sorte d'hypothèse. Aucune connaissance de K ne porte sur les sens de « de » : l'hypothèse `sens` n'a pas de fondement dans le cas. (signalé : co B2) | B § 4 ; QUALIFICATION § 2.2 |
| ee-012#2, ee-013#3, ee-019#3, ee-020#3, ee-024#3, co-012#3 | incohérence (la variation ne réalise pas celle qui est annoncée) | — | renommer la variation, ou la sortir des relations métamorphiques | Ce que font ces variantes : ee-012#2 ajoute un agent et un patient ; ee-013#3 ajoute une destination ; ee-020#3 remplace toute la description ; ee-024#3 retire la négation (« intact »). Toutes sont nommées `changement_de_participant`. co-012#3 change le lieu, et non la portée ; ee-019#3 réunit deux situations sous le nom `changement_de_temps`. (signalé en partie : ee F1, co F3, sa Q25) | QUALIFICATION § 2.2 |

### 2.5 Décision ouverte mal posée

| id | gravité | statut écrit | statut proposé | raison | section |
|---|---|---|---|---|---|
| D1 : les variantes niées d'un mot polysémique, 34 en tout (voir la note sous le tableau) | décision ouverte mal posée (risque de sûreté) | ecartee | ouvert : inconnue si N § 2 s'applique à la lettre | N § 2 (D30) : une négation n'est certaine que si chaque nœud du type demandé est inclus dans **chaque** sens du mot nié ; sinon elle ne réfute rien. Les cas tiennent le sens pour fixé par le contexte, alors qu'aucun document ne dit qui le fixe : la lecture (C7) ou K. L'option la moins prudente est prise, sans `decision_ouverte`. (signalé : ee A1, co A1-A2, sa Q17) | N § 2 ; B § 4 |
| co-019, et ses variantes #1, #2, #6 ; co-019#3 | décision ouverte mal posée | etablie ; inconnue pour #3 | ouvert : pour le pluriel, un seul luth satisfait-il « musical instruments » ? ; pour #3, etablie si « e.g. » est non exhaustif | Le pluriel de la définition n'est pas fixé par F § 2.6 : un risque de sûreté pour la base. Pour #3, « e.g. » marque une liste non exhaustive, et K atteste shawm ⊑ musical_instrument : sous la lecture que « e.g. » dit, le statut serait `etablie`. Ni l'un ni l'autre n'a de `decision_ouverte`. (signalé pour #3 : co C2) | F § 2.6, § 3.2 |
| co-018#4 | décision ouverte mal posée | inconnue | ouvert (inconnue au plus prudent) | « either a monk or a nun » : chaque branche de l'alternative satisfait la disjonction de la définition. L'option prudente est prise, mais le statut dépend d'un point non tranché, le raisonnement par cas, qui n'est porté par aucune `decision_ouverte`. (signalé : co C3) | N § 1, § 4.2 |
| sa-022 (la `decision_ouverte` sur l'antonymie) | décision ouverte mal posée (mineure) | inconnue | inconnue (les documents tranchent) | La liste des sortes de connaissances (F § 2.7) est fermée et ne compte aucune incompatibilité ; F § 3.3 ne propage la négation que par l'implication ou l'équivalence. Les documents fixent donc `inconnue` ; l'option `ecartee` relève d'une extension future, non d'une lecture ouverte. | F § 2.7, § 3.3 |

**La ligne D1 en détail.** Les 34 variantes :
- **evenements_etats (16) :** ee-002#5, ee-003 et #1, #2, #6, #7, ee-007#6, ee-008#5, ee-009#5, ee-014#5, ee-015#6,
  ee-020#5, ee-022#4, ee-024 et #1, #6 ;
- **compositionnalite (1) :** co-018#5 ;
- **structures_argumentales (17) :** sa-002 et #1, #2, #6, sa-004#3, sa-010#2, sa-011#3, sa-012 et #1, #3, #5, #6,
  sa-017#3, sa-018 et #1, #3, #5.

Ne sont **pas** concernées : co-004#4 et la famille co-007, qui nient un mot à sens unique (mythique, pommelé) ;
ee-010#3 et ee-013#5, qui passent par un nombre.

### 2.6 Qualité

| id | gravité | statut écrit | statut proposé | raison | section |
|---|---|---|---|---|---|
| ee-012, ee-013, co-002, co-014, co-015 | qualité (protocole) | — | — | Aucune variante ne change de statut par un changement de portée, de modalité, de temps ou par une inversion des rôles : seule une variante de participant le fait. | B § 4, les variantes |
| ee-004#3 (stride ⊑ walk), ee-008#2 (immoler ⊑ sacrifier), ee-010 (bourreau → torturer), ee-016#1 (« Gaulish »), co-012#3 (alpage → « mountain landscape »), sa-015 (« the feet » → « his feet ») | qualité (K incomplet, ou lien lexical non dit) | etablie | etablie si K les reçoit | Les cas : stride ⊑ walk et immolate ⊑ sacrifice existent dans WordNet, mais ne sont pas dans K ; bourreau, c'est d'abord executioner, qui n'est pas inclus dans torturer ; « Gaulish » est absent de WordNet 3.0 ; l'alpage ne donne pas un « paysage de montagne » sans connaissance ; la partie « ses pieds » n'est qu'une anaphore associative. Lu à la lettre (« rien d'autre »), chacun de ces cas serait une erreur de sûreté. (signalé : ee D3, D4) | B § 4 |
| ee-009#5, sa-004#3, co-004#4 | qualité (description) | — | — | Ces formules ne sont pas plausibles pour une notice : « Against the usual formula, Judith does not behead… », « Cette fois, la Sainte Famille ne fuit pas vers l'Égypte », « Ce lynx n'a rien de mythique ». Elles sont écrites pour la négation. | B § 4 (le style d'une notice) |
| sa-015 | qualité (justification) | — | — | La justification dit que l'extension est notée `ancrage_temporel` « faute d'un nom propre », alors que le champ porte déjà `relation_entre_eventualites`, après la correction notée dans CONSOLIDATION.md. Le texte n'a pas été mis à jour. | — |

**Les `decision_ouverte` relues, et trouvées bien posées.** La question est vraiment ouverte, et le statut retenu est
le plus prudent, dans ee-009, ee-011, ee-019, ee-023, co-002, co-010, co-014, sa-010 et sa-011.

**Les définitions.** Aucune ne contient de notation. Je n'ai pas pu vérifier qu'aucune ne reprend un libellé réel,
puisque les données d'Iconclass sont exclues. « fabulous animal » reprend le nom de la queue FF citée par F § 1.2, et
« the Holy Family fleeing into Egypt » est très proche d'un libellé usuel : la propriétaire pourrait le vérifier.

## 3. Les questions que les documents ne tranchent pas, en plus de celles des rédacteurs

1. **Une glose peut-elle attester une équivalence ?**
   - F § 2.7 dit que « le défaut d'une glose est relation inconnue ». Les cas marquent pourtant attestées des
     équivalences tirées d'une seule glose : sa-019 (« be seated ») et sa-022 (« be asleep »).
   - ee-001 omet la même équivalence. Il faut une règle, et une seule pour les trois familles.
2. **« S'apprêter à » est-il toujours l'en cours ?**
   - O § 1.2 en donne un seul exemple. Les familles divergent : ee-008 met `etablie`, sa-007#5 et sa-016#4 mettent
     `inconnue`.
   - Il faut dire si la frontière est lexicale (« s'apprête », « is preparing to » contre « sur le point de »,
     « about to ») ou si elle tient à la figuration (le geste suspendu).
3. **« Ancien », « former » : un privatif ou un ancrage antérieur ?**
   - L'inventaire range « ancien » parmi les privatifs, alors que F § 1.2 définit le privatif par « dans aucun
     contexte ».
   - Si c'est un ancrage, co-008 et co-009 dépendent de la `decision_ouverte` de ee-009 (les ancrages s'excluent-ils
     ?), et le statut pourrait même être esh par les attributs typiques (co-008).
4. **Le pluriel d'une définition** (« musical instruments », co-019) : demande-t-il une collection de deux membres
   au moins, ou un seul suffit-il ? F § 2.6 traite des collections dites, non du pluriel d'un libellé.
5. **Une condition nécessaire employée pour réfuter doit-elle venir d'une ressource ?** Peut-elle être une
   connaissance du monde, comme « écrire avec P ⇒ tenir P » (sa-024) ? Et dans quelle opération : S § 2 l'interdit à
   `deduire`, et S § 3 la place dans la classification.
6. **Les antonymes morphologiques** (« uncrowned », co-023#5 ; « unbroken », dans ee-024) : une négation de l'atome,
   ou un antonyme sans force négative ? La `decision_ouverte` de sa-022 ne couvre que les antonymes lexicaux.
7. **Le possessif et la parenté** (« sa fillette » comme « her daughter », co-015#3) : la lecture peut-elle tirer
   une relation de filiation d'un possessif ? Aucune convention n'est écrite.
8. **Une entrée d'inventaire qui nomme le sujet** (« the panel showed 'Venus emerging from the sea' », sa-006) :
   une source citée sur le figuré (`non_certifiee`) ou un titre (un indice, `inconnue`) ? Ce point s'ajoute au
   critère général de « selon » (sa Q18).
9. **La règle de certitude des négations (N § 2) vaut-elle pour les événements niés, ou seulement pour les types ?**
   - Les rédacteurs ont posé la question pour les adjectifs (dead, broken).
   - Elle touche aussi tous les verbes niés : donner, offrir, porter, bénir, verser.
   - Si elle vaut, presque aucun cas négatif sur un verbe courant n'est `ecartee`.
10. **L'attestation d'une connaissance typique.** ee-020 et co-008 mettent `attestee: true`, sa-017, sa-020, co-013
    et co-014 mettent `false` : le champ n'a pas le même sens d'une famille à l'autre (signalé pour co seulement, en
    B2).
11. **Une configuration figurée seulement dans une figuration emboîtée.** ee-023 porte une `decision_ouverte` ;
    sa-007#4, sa-015#5 et co-014 donnent `inconnue` sans y renvoyer. Les statuts sont prudents, mais une même
    décision devrait être citée par tous les cas qui en dépendent.
12. **Qui ferme un sens ?** Le critère est appliqué de façon inégale :
    - fermé par le contexte : ee-003, co-006, sa-001, sa-018 ;
    - laissé ouvert : ee-011, co-004#3.
    Le même texte, relu par un autre agent, peut donc changer d'`etablie` en esh.
