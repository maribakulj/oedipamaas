# Relecture C : niveaux de représentation, définitions et classification, phénomènes iconographiques

Relecteur indépendant (C). Fichiers relus, sans modification : `niveaux_representation.json`,
`definitions_classification.json`, `phenomenes_iconographiques.json` et leurs `.questions.md`. Documents de référence :
`docs/BANCS_PHASE1.md` (§ 4 surtout), `docs/FONDEMENTS_SEMANTIQUES.md`, `docs/ONTOLOGIE_EVENTUALITES.md`,
`docs/SPECIFICATION_OPERATIONS.md`, `docs/NOYAU.md` (§ 1, § 2, § 4.4) et `docs/QUALIFICATION_SEMANTIQUE.md` (§ 2).
WordNet 3.0 a été consulté par `outils/bancs/sens.py` et par lecture directe de `data.*` (pointeurs `@`, `#p`, `!`, `\`).

Les désaccords sont listés, et aucun n'est tranché ici. Un statut proposé « ouvert » veut dire que les documents ne
fixent pas le statut, et que celui qui est écrit n'est pas le plus prudent.

## 1. Résumé chiffré

| famille | cas de base | variantes | entrées `attestee: true` |
|---|---|---|---|
| niveaux_representation (nr) | 24 | 120 | 36 |
| definitions_classification (dc) | 24 | 139 | 20 |
| phenomenes_iconographiques (pi) | 24 | 144 | 20 |
| **total** | **72** | **403** | **76** |

**Les contrôles faits :**
- les 72 cas et les 403 variantes ont été relus ;
- les 76 entrées attestées ont été lues. Environ 30 d'entre elles (plus d'une sur trois) ont été vérifiées dans
  WordNet : gloses, hyperonymes, méronymes, antonymes, pertainymes, et l'existence des clés de sens ;
- on a aussi vérifié, pour chaque cas, les quotas de forme du § 4 (cinq variantes, quatre variations, une traduction, une
  variante de statut différent) et la règle « `hypotheses_attendues` si et seulement si `etablie_sous_hypotheses` ».

**Les désaccords, par gravité.** Une entrée du tableau peut couvrir un cas et plusieurs de ses variantes.

| gravité | entrées | cas ou variantes touchés |
|---|---|---|
| sûreté (statut trop fort) | 14 | 33 |
| trop faible | 1 | 5 |
| connaissance non fondée | 8 | 8 cas (dont 4 avec un effet sur un statut) |
| incohérence | 3 | plus de 15 |
| décision ouverte mal posée | 3 | 3 cas |
| qualité | 4 | 12 cas |
| **total** | **33** | |

Parmi les 14 entrées de sûreté, quatre sont « ouvertes » : nr-018, nr-016#2, pi-019#5 et dc-012#2. Les documents ne
tranchent pas, mais le statut écrit est l'option la plus forte. Les dix autres reposent sur un atome de la définition
qu'aucune assertion ni aucune connaissance de K n'appuie.

**Ce qui est solide.** Les contextes sont presque partout bien séparés : copie, « d'après », source, inventaire, titre,
signature, état de conservation. Les rôles inversés sont toujours `inconnue`. L'absence n'est jamais prise pour une
négation. Les décisions ouvertes retiennent l'option la plus faible, sauf les exceptions listées. Les `ecartee` fondés
sur une négation dite et une contraposition de condition nécessaire attestée sont conformes à la cible : nr-003, nr-017,
dc-005, dc-006, dc-008, pi-011, pi-016 et pi-024.

## 2. Le tableau des désaccords

Abréviations : ESH = `etablie_sous_hypotheses` ; « #n » = la n-ième variante ; « (+#…) » = les variantes qui portent la
même erreur.

| id | gravité | statut écrit | proposé | raison | documents |
|---|---|---|---|---|---|
| pi-001 (+#1, #2, #6) | sûreté | etablie | inconnue | Trois atomes de la définition n'ont aucun appui. « Accompanied by the angel » contre « guidé par l'ange » : dans WordNet, lead/guide n'a pas accompany pour hyperonyme. « Anointing the eyes » contre « frotte », « rubbing », « applique » : rub n'est pas ⊑ anoint, qui veut dire « administer an oil or ointment ». « His blind father » : le vieil aveugle n'est jamais dit le père, le texte dit seulement « de retour chez son père ». K ne contient que l'alias Tobie/Tobias. | BANCS § 4 (K seul) ; NOYAU § 2 (lien positif) ; § 1 (coréférence dite) |
| pi-002#4 | sûreté | etablie | inconnue | La définition demande « reduced to herding swine ». La variante dit « kneels among the pigs and eats from their trough », sans le mot « swineherd ». Même avec ce mot, un nom d'agent ne donne qu'une connaissance typique. | FONDEMENTS § 3.2 ; BANCS § 4 |
| pi-003#3 | sûreté | etablie | inconnue | « Un pauvre » (pauper) n'établit pas « a beggar » : WordNet donne beggar ⊑ pauper, et le lien positif ne va que du plus spécifique au plus général. L'option `etablie` de la décision ouverte du cas de base a le même défaut. | NOYAU § 2 |
| pi-005#3 | sûreté | etablie | inconnue | Rien ne relie « désert » à « wilderness » : desert%1:15:00:: a pour hyperonymes tract et biome, non wilderness%1:15:00::, et K ne dit rien. | NOYAU § 2 ; BANCS § 4 |
| pi-008 (+#1, #2, #5, #6) | sûreté | etablie | ouvert (inconnue ou ESH) | « A tapestry of a stag hunt » contre « hunters and hounds pursue a stag ». Pursue n'implique pas hunt (c'est hunt ⊑ pursue). « Hunters », nom d'agent, et « hunting tapestry », composé, ne donnent pas l'événement par la syntaxe. « Behind the diners » pose la même question pour les participants du festin. | FONDEMENTS § 3.2 ; NOYAU § 2 |
| dc-010 (+#1, #2, #5, #6) | sûreté | ESH [connaissance_typique] | inconnue | La définition demande une nature morte (« still life with … »). La description ne la nomme pas, et K ne contient aucune classification de genre. La connaissance typique de K ne vaut elle-même que « dans une nature morte ». L'atome du genre n'a aucun appui. | NOYAU § 4.4 ; SPEC § 4 (l'hypothèse vient d'une connaissance identifiée) |
| dc-014#4 | sûreté | ESH | inconnue | L'inscription « S. BARBARA » reste sur le cadre ; « peut-être ajoutée au XIXe siècle » ne la retire pas. Selon l'option prudente de la décision ouverte du cas (« l'inscription nomme la figure »), l'hypothèse Catherine reste inadmissible, comme dans le cas de base. | FONDEMENTS § 5 (admissible) ; décision ouverte du cas |
| dc-012#2 | sûreté (ouvert) | etablie | ouvert | Le statut suppose que « (flight into Egypt) » est une étiquette et non un atome de situation (question 22 du rédacteur). Si c'est un atome, seul le titre l'appuie, et le statut est `inconnue`. C'est l'option forte d'une question non tranchée. | ONTOLOGIE § 4 ; ASSERTIONS (titre) |
| nr-001 (+#1, #2, #5) | sûreté | etablie | inconnue | « Mary Magdalene weeping beside them » contre « À droite, Marie-Madeleine pleure ». La position dans l'image (« à droite ») n'implique pas « à côté du Christ et de la Vierge », et K ne contient aucune relation de position. | BANCS § 4 ; NOYAU § 2 |
| nr-018 (+#1, #3, #4) | sûreté (ouvert) | ecartee | inconnue | L'appui négatif de « old » est tiré d'une assertion positive (« youth ») par l'antonymie young/old (bien présente dans WordNet). Mais le § 4 n'admet pour `ecartee` qu'un appui négatif dit, une distinction documentaire ou une contrainte du texte. NOYAU § 1.1 ne tire un appui négatif que d'une assertion niée, et les sortes du § 2.7 n'ont pas d'incompatibilité. Le rédacteur le sait (question 9), mais le cas n'a pas de `decision_ouverte` et retient l'option forte. | BANCS § 4 ; NOYAU § 1.1 ; FONDEMENTS § 2.7, § 3.3 ; ONTOLOGIE § 6 (adjectifs de degré) |
| pi-019#5 | sûreté (ouvert) | ecartee | inconnue | « Ces objets ne sont pas des signes de la fugacité » nie une relation dont une entité est un référent conceptuel, non présent dans l'image. Or NOYAU § 1.1 exige, pour un appui négatif, chaque entité de la relation présente. Le rédacteur le signale (question 11), mais retient l'option forte. | NOYAU § 1, § 1.1 ; FONDEMENTS § 2.1 |
| nr-016#2 | sûreté (ouvert) | ecartee | inconnue | Même difficulté : « She is not Prudence: she personifies Truth » nie une relation de personnification vers un concept non présent. Ce cas ne signale pas la question. | NOYAU § 1.1 ; FONDEMENTS § 2.1 ; AUDIT § 3.7 |
| pi-019 (+#1, #6) | sûreté | etablie | ESH ou ouvert | La définition dit « objects … signify », la description « fait de ces objets autant de signes de ». Passer de la locution nominale au verbe est une canonisation, qui demande une équivalence établie. K ne contient que fugacité ⇔ transience. (#2, « signifient », n'est pas touchée.) | FONDEMENTS § 3.2 ; SPEC § 1 |
| dc-002#3 | sûreté (faible) | ecartee | ouvert | « Ne porte pas de tonsure » nie la relation « porter ». La définition demande « with a tonsure », et K n'identifie pas les deux relations. La réfutation n'est sûre que si la lecture les canonise en une même relation. | NOYAU § 1.1 (même prédicat) ; FONDEMENTS § 3.1 |
| pi-020 (+#1, #2, #4, #5) | trop faible | inconnue | ESH [connaissance_typique] (ouvert) | La décision ouverte suppose deux explications « des mêmes objets observés ». Or la vanité explique le crâne et la bougie, le « saint pénitent absent » le crâne et le livre. La concurrente n'explique pas la bougie éteinte, et SPEC § 4 ne rapporte une ambiguïté que pour des explications qui couvrent les mêmes observations. | SPEC § 4 (coût et comparaison) ; FONDEMENTS § 5 |
| dc-003 (K) | connaissance non fondée, effet sur #2 | #2 : etablie | #2 : ESH [equivalence_non_attestee] | « Chalice ⇔ un récipient destiné au vin de la messe » est donné pour « glose WordNet, nécessité et suffisance validées ». La glose réelle dit « a bowl-shaped drinking vessel; especially the Eucharistic cup », et « especially » n'en fait ni une condition nécessaire ni une condition suffisante. L'attestation ne porte pas sur la formule écrite. | FONDEMENTS § 2.7 (ce qui établit une équivalence) |
| dc-015 (K) | connaissance non fondée, effet sur #2 | #2 : etablie | #2 : ESH | « Être à droite de quelqu'un implique être à côté de lui » est donné pour attesté, mais ce n'est pas une relation de WordNet. C'est aussi faux en général : une tour « à sa droite » peut se dresser au loin. Le cas de base reste ESH, avec une hypothèse de plus. | FONDEMENTS § 2.7 ; BANCS § 4 |
| nr-024 (K) | connaissance non fondée, effet sur #2 | #2 : etablie | #2 : ESH [equivalence_non_attestee] | « Signify ⇔ symbolize » est donné pour une équivalence attestée. Dans WordNet, ce sont deux synsets frères sous « mean », non des synonymes, et la définition dit « as a symbol ». | FONDEMENTS § 2.7 ; SPEC § 1 |
| dc-004 (K) | connaissance non fondée, effet sur #2 | #2 : etablie | ouvert | La glose de martyr%1:18:01:: dit « voluntarily suffers death ». K la réécrit « accepte de mourir », toujours sous le label « glose WordNet, validées ». Dans #2, la mort est imminente (la sainte « s'avance vers le bourreau »). Avec la glose réelle, la condition demande une mort accomplie. | FONDEMENTS § 2.7 ; ONTOLOGIE § 1.2 (imminent contre accompli) |
| nr-011 (K) | connaissance non fondée | inconnue | inchangé | « Bras brisé ⇒ blessé » est donné pour attesté, mais n'est ni une inclusion ni une glose de WordNet. Aucun statut n'en dépend : #2 dit « blessé » en toutes lettres. | BANCS § 4 |
| nr-002 (K) | connaissance non fondée | inconnue | inchangé | « “An Adoration of the Magi” nomme une situation qui satisfait la description » est donné pour une équivalence attestée, sans ressource identifiable. Aucun statut du cas n'en dépend, mais l'entrée établirait à tort une variante où la copie serait dite « an Adoration ». | FONDEMENTS § 2.7 ; ONTOLOGIE § 4 (un nom de scène ne fait pas exister la situation) |
| pi-020 (K) | connaissance non fondée | inconnue | voir plus haut | « Un crâne et un livre fermé sont typiquement les attributs d'un saint pénitent absent, sans valeur de vanité » est marqué attesté. Aucune ressource n'est nommée : l'entrée semble écrite pour créer la concurrente. | SPEC § 4 (connaissance identifiée : ressource, version) |
| dc-007 (K) | connaissance non fondée (faible) | inconnue ; #2 : ecartee | inchangé, à vérifier | La condition « hermit ⇒ vit dans la solitude » reprend la glose de hermit%1:18:00:: (« one who lives in solitude »). Le pivot est hermit%1:18:01:: (« retired from society for religious reasons »). La réfutation de #2 dépend de ce choix. | FONDEMENTS § 2.7 (sur des sens, non des lemmes) |
| noms entre langues | incohérence (sûreté possible) | etablie, ecartee | ouvert | Les rédacteurs de pi écrivent les alias entre langues dans K (Tobie/Tobias, Jérôme/Jerome, Agar/Hagar, Marc/Mark, Nicolaus/Nicholas). Les autres s'en passent : nr-001 (Marie-Madeleine), nr-007#2 (Jérôme), nr-008#1 (Eustache), nr-010 (Holopherne), nr-013 (Sébastien), dc-012#2 (Marie), dc-015#2 et #3 (Barbe), pi-015#3 (Pierre), pi-022#4 (Holopherne, dans la famille même qui écrit les alias). Ou bien `K:cle_de_nom` normalise entre les langues, et les entrées de pi sont inutiles. Ou bien ces statuts n'ont pas d'appui. | BANCS § 4 (rien d'autre) ; NOYAU § 2 (`cle_de_nom`, `alias`) |
| sens et contexte | incohérence | etablie, ESH sans `sens` | ouvert | La même règle donne deux résultats. dc-013 juge que le contexte (« holds … in his right hand ») exclut le sens « terrain de football » de gridiron, sans hypothèse de sens. pi-012 juge que « breathing fire » n'exclut pas le sens « lézard » de dragon, faute de connaissance dans K, d'où `sens`. Les deux exclusions demandent pourtant une connaissance du monde absente de K. Même question pour nr-022 (whiteness a un sens d'état moral, whiteness%1:26:00::, sans hypothèse) et pour nr-005#3 (death). | NOYAU § 2 (D30) ; BANCS § 4 (« que le texte laisse ouverts ») |
| dc-022#2 | incohérence | etablie, variation `inversion_des_roles` | variation à renommer | Le cas de base est déjà inversé. La variante le ré-inverse, et son statut `etablie` est juste. Mais le plan donne pour l'inversion la relation « jamais établie » : la mesure métamorphique comptera une violation. | QUALIFICATION § 2.2 ; BANCS § 7 |
| dc-005 | décision ouverte mal posée | ecartee | décision ouverte à ajouter | Le rédacteur (question 11) tient pour ouverte la compilation de « the cyclops Polyphemus », conjonction d'un nom et d'un type ou nom avec épithète. Le cas n'a pas de `decision_ouverte`. L'autre option donnerait `etablie` (nom et lyre établis) : le statut dépend d'une question non tranchée. | BANCS § 4 (`decision_ouverte`) |
| nr-024 | décision ouverte mal posée | non_certifiee | décision ouverte à ajouter | Le rédacteur (question 6) tient pour ouverte la lecture du programme de l'abbé : énonciateur cité (`non_certifiee`) ou portée `source` (`inconnue`). Le cas n'a pas de `decision_ouverte`. Les variantes #1, #3 et #4 suivent. | NOYAU § 4.4 ; BANCS § 4 |
| dc-007 | décision ouverte mal posée | inconnue | inchangé | Les documents semblent trancher la question posée : une condition nécessaire « jamais pour l'établissement » (FONDEMENTS § 2.7, SPEC § 3) ; « un moine n'établit pas tonsure, par aucune définition » (SPEC § 3.1) ; les sortes qui proposent une abduction sont listées sans elle (SPEC § 4). Le statut retenu est bien le prudent. | FONDEMENTS § 2.7 ; SPEC § 3, § 3.1, § 4 |
| dc-012, pi-005, pi-014, pi-020, pi-022 | qualité (forme) | — | — | Aucune variante de statut différent n'est un changement de portée, de modalité ou de temps, ni une inversion. Les statuts différents passent par `composition` ou `changement_de_participant`. | BANCS § 4 (variantes) |
| nr-005, nr-023 (K) | qualité | — | — | Deux clés de sens n'existent pas dans WordNet 3.0 : pyre%1:06:00:: (la clé réelle est pyre%1:14:00::, synonyme de funeral_pyre) et heaven%1:15:00:: (les seules clés sont heaven%1:15:01:: et heaven%1:09:00::). | BANCS § 4 (clés de WordNet 3.0) |
| étiquettes de variation | qualité | — | — | Plusieurs variations ne réalisent pas la variation annoncée. dc-004#4 (« On sait que… ») change l'énonciation et le contexte, non la modalité. dc-011#3 ajoute un mot (« aveugle »). dc-008#4 remplace une négation par une affirmation de contenu. dc-012#2 et dc-020#3 ajoutent une information et s'appellent « composition ». | QUALIFICATION § 2.2 |
| pi-019#3 | qualité | non_certifiee | inchangé | La source citée est un historien réel (Ingvar Bergström), à qui est prêtée une assertion inventée sur une œuvre inventée. Une source fictive suffirait. | — |

## 3. Les questions que les documents ne tranchent pas, en plus de celles des rédacteurs

1. **WordNet est-il dans K par défaut ?** BANCS § 4 dit que K est ce que liste `connaissances_supposees`, « et rien
   d'autre ».
   - Presque tous les cas `etablie` reposent pourtant sur des inclusions non listées : farmhouse ⊑ house, stag ⊑ deer,
     désert/wilderness, guide/accompany.
   - Si la hiérarchie de WordNet est implicite, il faut le dire. Les erreurs de pi-001, pi-003#3 et pi-005#3 sont alors
     des inclusions **fausses** dans WordNet, non seulement absentes de K.
   - Sinon, la plupart des `etablie` des trois familles sont à reprendre.
2. **Les noms propres entre langues.** `K:cle_de_nom` normalise-t-il « Marie-Madeleine » et « Mary Magdalene », « Pierre »
   et « Peter » ? Sinon, un alias doit-il être listé à chaque cas ? Voir l'incohérence ci-dessus.
3. **Une contrariété (l'antonymie) est-elle une source d'appui négatif ?** On peut l'écrire comme une implication à
   conclusion négative, une sorte « incompatibilité », ou ne pas l'admettre. Les sortes du § 2.7 ne la nomment pas, et le
   § 4 du protocole semble l'exclure de `ecartee` (nr-018).
4. **La négation d'une relation vers un référent conceptuel** (personnification, signification). L'exigence de présence
   de NOYAU § 1.1 s'applique-t-elle au concept, qui n'est jamais présent ? (nr-016#2, pi-019#5.) La question 11 de pi la
   pose pour la signification seulement.
5. **Une glose « adaptée » garde-t-elle l'attestation de la glose ?** Les cas dc-003 (chalice), dc-004 (martyr) et
   dc-024 (halo, qui perd « of a saint ») réécrivent la glose et gardent « nécessité et suffisance validées ». Par
   ailleurs, FONDEMENTS § 2.7 fait d'une glose, par défaut, une « relation inconnue ». Il faut dire quand une glose
   compte comme attestation (la grille de relecture l'admet, les fondements demandent une validation).
6. **Des explications qui se recouvrent en partie.** SPEC § 4 ne traite que des explications « des mêmes
   observations ». Que faire de deux explications qui se recouvrent sans coïncider ? Faut-il comparer la couverture avant
   le coût ? (pi-020.)
7. **Une décision ouverte au niveau d'une variante.** Le schéma n'en permet qu'au niveau du cas. Pourtant plusieurs
   variantes ont un statut qui dépend d'une question non tranchée : dc-012#2, dc-014#4, nr-013#5 (le dessin
   sous-jacent), nr-018, pi-019#5. Sans ce champ, le statut le plus prudent n'est pas garanti, et la question ne se voit
   pas.
8. **La relation métamorphique d'une ré-inversion.** Quand le cas de base est lui-même une inversion, quelle relation
   la variante d'inversion doit-elle porter ? (dc-022#2.)
9. **L'ancrage temporel d'un type défini par un événement accompli** (martyr, veuve). Une figure qui va mourir pour sa
   foi est-elle un martyr au moment figuré ? (dc-004#2 ; voir aussi la question 21 de dc, sur la veuve.)
10. **Un critique cité et une métaphore.** nr-009 lit « the picture is “a cavalry charge in feathers” », dit par un
    critique cité, comme une métaphore sans appui (`inconnue`). Avec la règle de nr-024, une assertion d'une source
    citée sur l'œuvre donnerait `non_certifiee`. Les documents ne disent pas comment un modificateur métaphorique
    (« in feathers ») retire l'appui. Il faut aussi dire où `non_certifiee` se place par rapport à `inconnue` pour la
    sûreté (BANCS § 7 ne le range pas).
11. **La portée d'un énoncé ambigu entre l'objet et le figuré** (« son bras droit est brisé », nr-011#2). Seul le
    contexte (l'écharpe, la douleur) fait lire le figuré. Les documents ne disent pas si ce choix est une hypothèse de
    lecture.
