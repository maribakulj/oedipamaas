# Questions ouvertes : banc de développement, sémantique compositionnelle (co-)

Les points où les documents sont muets, ambigus ou se contredisent, rencontrés en écrivant les 24 cas. Chacun donne les
cas touchés et le choix fait. Rien n'a été tranché en silence : quand le choix n'est pas fixé, le cas porte une
`decision_ouverte` (co-002, co-010, co-014) ou la question est dite ici.

## A. Les sens et les modificateurs

**A1. Qui ferme l'ambiguïté lexicale : le texte, ou K par supervaluation ?** (co-003, co-004, co-006, co-008, co-009,
co-013, co-019)
- BANCS_PHASE1 § 4 : une hypothèse de sens ne figure que si la conclusion dépend « d'un choix entre des sens que le
  texte laisse ouverts ». NOYAU § 2 (D30) : K prend tous les sens, et la désambiguïsation relève de C7, qui n'est pas
  spécifiée.
- Aucun document ne dit quand le texte « ferme » un sens. J'ai retenu une règle que je n'ai trouvée nulle part : les
  restrictions de sélection et la position syntaxique ferment un sens (« red cloak » n'est pas « visage empourpré » ;
  « ancien » antéposé veut dire « former » ; « former » au sens de « le premier de deux » demande deux antécédents ;
  « lute » au sens de mastic ne se pose pas sur une table). Un sens qui reste plausible ouvre une hypothèse : « un lynx
  fabuleux » (merveilleux ou légendaire, co-004, variante) donne `etablie_sous_hypotheses` [sens].
- Si la règle est plutôt « tous les sens de WordNet », co-006, co-008, co-009 et co-019 deviennent `etablie_sous_hypotheses`
  [sens] ou `inconnue`. Il faut décider.

**A2. Nier un modificateur polysémique : une négation certaine ou seulement possible ?** (co-004, variante
`changement_de_modalite` ; co-007)
- Par NOYAU § 2, une négation n'est certaine que si le type demandé est inclus dans **chaque** sens du mot nié. « Ce lynx
  n'a rien de fabuleux » ne réfuterait donc rien (fabuleux a trois sens), et le cas serait `inconnue`. J'ai écrit la
  variante avec « mythique », qui n'a qu'un sens, pour obtenir `ecartee`. Même chose pour co-007 avec « pommelé ».
- Mais la règle rend presque impossible tout cas négatif sur un adjectif courant (« blanc » a onze sens). Est-ce voulu ?
  Ou bien A1 vaut aussi pour les négations ?

**A3. « Prétendu » n'a pas de place dans FONDEMENTS_SEMANTIQUES § 1.2.** (co-010, `decision_ouverte`)
- Le § 1.2 ne connaît que deux modificateurs non intersectifs : les privatifs et ceux de mode d'existence. L'inventaire
  range « prétendu » parmi les privatifs. Or « un prétendu prophète » peut en être un : l'adjectif est non engageant
  (non subsectif), ou c'est une marque d'énonciation (« selon certains »).
- Options : `inconnue` (non engageant, retenu comme le plus prudent), `ecartee` (privatif), `non_certifiee` (énonciateur
  autre que l'auteur). Il manque une troisième sorte de modificateur, ou une décision qui range « prétendu ».

**A4. Le privatif donne-t-il un appui négatif, ou seulement rend-il le type non admissible ?** (co-008, co-009)
- FONDEMENTS § 1.2 : « un faux pistolet n'est pas un pistolet » (une valeur F). AUDIT_EXPRESSIVITE § 3.2 (4) : « à
  défaut, le lecteur doit au moins rendre non admissible l'atome de type » (une valeur N). J'ai suivi les fondements
  (`ecartee`), l'audit décrivant un repli.
- « Ancien » est un privatif **temporel** : un ancien évêque l'a été. Le privatif doit-il écrire aussi l'état antérieur
  (« était évêque ») avec l'ancrage temporel ? Une définition « former bishop » ne s'écrit pas sans cela, ni sans
  `non/1`.

**A5. Les adjectifs de degré : la classe de comparaison et le superlatif.** (co-002, `decision_ouverte`)
- ONTOLOGIE_EVENTUALITES § 6 laisse ouverte la classe de comparaison. « The youngest of the apostles » n'établit pas
  « young » sans une connaissance, et aucune sorte n'est prévue pour ce lien (implication analytique ? typique ?).
  J'ai retenu `inconnue`.
- Pour l'âge, la classe du libellé (« old woman ») a coïncidé avec celle du texte (co-001). Il manque un cas où elles
  diffèrent (« un jeune évêque » contre « young man ») : je ne l'ai pas écrit, faute de savoir quel statut attendre.

**A6. Le mode d'existence et les notations d'animaux réels.** (co-003, co-004)
- FONDEMENTS § 1.2 : un lynx fabuleux « ne perd pas son type dans le monde figuré ». Il satisferait donc une définition
  « lynx » tout court. Or Iconclass sépare les animaux et les animaux fabuleux (queues FF). Est-ce la convention de
  classement sur les sœurs (FONDEMENTS § 2.6, « (other) X ») qui doit l'exclure, ou la définition de la notation réelle
  qui doit exiger l'extension réelle ? Je n'ai écrit aucun cas « lynx » contre « lynx fabuleux » pour cette raison.

## B. Les composés

**B1. La matière sur un nom d'être animé (« un ange de marbre »).** (co-014, `decision_ouverte`)
- Est-ce un ange de matière marbre (type gardé) ou une statue d'ange (une représentation emboîtée) ? Et une définition de
  figuration est-elle satisfaite par le contenu d'une représentation emboîtée (une statue dans le décor, un tableau dans
  le tableau) ? Les documents disent qu'un référent d'un contexte emboîté n'est pas un référent du monde figuré
  (FONDEMENTS § 2.5), mais ne disent pas si la satisfaction traverse l'emboîtement. J'ai retenu `inconnue`.

**B2. La relation implicite d'un composé : typique ou établie, et attestée par quoi ?** (co-013, co-011, co-012)
- FONDEMENTS § 3.2 exclut la règle syntaxique, mais ne dit pas quelle sorte de connaissance porte la relation (« gold
  crown » : matière). J'en ai fait une connaissance typique, d'où `etablie_sous_hypotheses`. Si une ressource atteste
  la relation pour un couple de sens, on aurait `etablie`. Quelle ressource, et quelle attestation ?
- En traduction, le composé anglais devient une préposition (« couronne d'or ») : la relation passe alors par le sens
  de « de » (`de_matiere`), soit une hypothèse de sens plutôt qu'une connaissance typique. Le statut est le même, mais
  les hypothèses diffèrent (co-013, `traduction`). La relation métamorphique porte-t-elle sur le statut seul ou aussi
  sur les sortes d'hypothèses ?
- Le champ `attestee` d'une connaissance typique : veut-il dire « attestée comme typique » ou « attestée comme vraie » ?
  J'ai mis `false` pour les relations de composés (aucune ressource nommée) et `true` pour les attributs typiques
  (co-008), ce qui n'est pas cohérent sans une définition.

**B3. Le nom d'agent et l'abduction.** (co-011)
- « Dragon-slayer » plus un dragon mort : l'abduction explique les deux observations par « il a tué ce dragon ». K ne
  contient aucune explication concurrente (un autre tueur), donc aucune ambiguïté n'est rapportée. Mais en monde ouvert,
  une concurrente absente de K n'est pas une concurrente exclue : l'abduction doit-elle supposer un agent inconnu comme
  concurrente par défaut ? Le statut resterait `etablie_sous_hypotheses`, mais la preuve changerait.

**B4. Les composés lexicalisés et le pivot.** (co-015, co-016)
- Le pivot d'un composé lexicalisé est-il le composé (stepmother, guardian_angel) ou sa tête ? J'ai pris le composé
  quand WordNet l'a, et la tête sinon (« dragon-slayer » : slayer ; « berger des montagnes » : shepherd ; « gold
  crown » : crown). La famille lexicale du pivot dépend de ce choix.
- La traduction change la construction : « belle-mère » (trait d'union) devient « stepmother » (un seul mot). Le statut
  est le même, mais la variante ne teste plus le trait d'union.

## C. La coordination

**C1. L'ambiguïté structurale n'a pas de sorte d'hypothèse.** (co-017)
- « The founder and first abbess of the convent » : le complément partagé se distribue sous un seul déterminant. Avec
  des déterminants répétés (la traduction française, imposée par le genre), le partage devient ambigu. Les hypothèses
  admises (BANCS § 4) ne comptent que des sens, des connaissances et des identités. Aucune ne dit « lecture
  structurale supposée ». J'ai retenu `etablie` parce que le texte anglais fixe la structure, et j'ai gardé ce statut
  pour la traduction.
- Même question pour « the founder and first abbess », qui pourrait désigner une seule personne : c'est le verbe au
  pluriel qui l'exclut, une information que la lecture doit garder.

**C2. La liste d'exemples (« e.g. ») : ouverte ou fermée ?** (co-019)
- FONDEMENTS § 3.2 dit seulement que l'énumération est une affaire de type de libellé. J'ai choisi un objet (le luth)
  qui est à la fois un exemple et un instrument, pour que le statut ne dépende pas du choix. La variante avec une
  chalemie, instrument absent de la liste, dépend du choix : j'ai retenu `inconnue` (le plus prudent). Si « e.g. » donne
  le terme général pour seule condition, cette variante est `etablie`.

**C3. Une alternative de la description contre une disjonction de la définition.** (co-018, variante « either a monk
or a nun »)
- Chaque branche de l'alternative satisfait la définition « hermit, monk or nun ». Le noyau exclut les assertions sous
  alternative des prémisses (NOYAU § 1), et les fondements ne disent rien du raisonnement par cas. J'ai retenu `inconnue`
  (le plus prudent). Avec le raisonnement par cas, ce serait `etablie`.

**C4. La négation d'une description entière : la cible ou le noyau ?** (co-018, variante « does not read »)
- La valuation cible (FONDEMENTS § 1.1) rend faux « ∃E lire(E) ∧ agent(E, la moniale) » quand le texte nie cette
  description. Le noyau 0.3 ne dérive pas cette réfutation (NOYAU § 1.1, D41 : une perte du côté sûr). J'ai écrit la
  cible, `ecartee`. Le moteur actuel rendra `inconnue`. Il faut confirmer que D41 est une limite à lever, et non la
  sémantique voulue.

## D. Les participes

**D1. Le pivot d'un participe : le verbe ou l'adjectif lexicalisé ?** (co-020)
- WordNet a « fallen » en `adj.all` (quatre sens) et la plupart des participes en `adj.ppl`, qui est en qualification.
  J'ai pris le sens du verbe (fall%2:38:03::, `verb.motion`), comme le suggère le protocole (§ 3.2 : les états passent
  par un verbe). Mais un participe lexicalisé en `adj.all` pourrait légitimement être le pivot, et le côté changerait.

**D2. Le passif d'état et le passif d'action.** (co-023, co-024)
- « La Vierge est couronnée », « saint Pierre est emprisonné », « is crowned » : un état résultant ou un événement en
  cours au passif ? Les documents ne le disent pas. J'ai évité l'ambiguïté en co-023 (« sits crowned ») et l'ai rendue
  sans effet en co-024 (l'agent reste inconnu dans les deux lectures). Un banc devrait la tester de front, une fois la
  règle fixée.

**D3. Le participe français d'un verbe à la fois transitif et pronominal.** (co-021)
- « desséché » vient de « dessécher » (transitif) ou de « se dessécher » (inaccusatif). Le porteur est le même (le
  thème ou le patient), donc le statut aussi. La classe de verbe que la canonisation doit retenir n'est pas dite.

**D4. Le participe d'un inergatif et le temps des définitions.** (co-022)
- « Ayant dansé » dit un processus antérieur, sans état résultant. J'ai supposé qu'un libellé au gérondif (« dancing »)
  demande l'éventualité en cours. Les documents le disent pour les événements de changement (ONTOLOGIE § 1.2), pas pour
  les processus. La variante en narration continue (« au fond, la même Salomé danse ») suppose aussi qu'une définition
  est satisfaite par **une** des situations de l'œuvre (ONTOLOGIE § 4 et § 6, question ouverte).

## E. Les contextes, les titres et les sources

**E1. Le privatif dans un titre.** (co-010)
- « Le Faux Prophète », comme titre, n'est qu'un indice (`modalite(titre)`). J'ai considéré qu'il n'appuie ni ne nie le
  type. Un titre privatif devrait-il au moins rendre l'hypothèse de type non admissible pour l'abduction ?

**E2. « Selon » : sur le récit ou sur l'image ?** (co-009, co-022, co-024)
- « Selon les Actes, Hérode fit emprisonner Pierre » porte sur le récit (portée source), non sur la figure : `inconnue`.
  Si la même phrase était lue comme une source citée **sur la figure**, ce serait `non_certifiee` (NOYAU § 4.4). Le
  critère de lecture n'est pas écrit.

**E3. La matière de l'œuvre contre la matière figurée.** (co-013)
- Un buste en argent doré figure une couronne d'or. J'ai tenu les deux pour des contextes distincts (œuvre et figure),
  sans contradiction. Mais pour une sculpture, la matière de l'œuvre est aussi celle de la chose figurée, au sens
  matériel. Les documents ne traitent pas ce cas.

## F. Le protocole et l'outillage

**F1. La liste des extensions n'est écrite dans aucun document.** BANCS § 4 renvoie à « la liste du validateur ». Je
ne l'ai pas lue, puisqu'elle est dans son code. J'ai retrouvé par essais les noms acceptés : `ancrage_temporel`,
`etat_reifie`, `modificateur_non_intersectif`, `contexte_emboite`, `contexte_d_eventualite`, `evenement_participant`,
`referent_conceptuel`, `collection`, `quantification_enoncee`, `situation_referent`, `plusieurs_situations`,
`identite_entre_situations`, `relation_entre_eventualites`, `base_de_definitions`, `abduction`, `aucune`. Je n'ai
trouvé **aucun nom** pour `non/1` dans les requêtes : aucun cas co- n'en a donc besoin comme condition. « abduction » est
accepté comme extension alors que c'est une opération : je l'ai mis quand le statut passe par l'extension du format des
preuves (co-011, co-013). Je n'ai pas mis `abduction` en co-008, variante ermite (les extensions sont celles du cas de
base). La liste devrait être publiée dans le protocole.

**F2. La correspondance entre un mot français et un sens anglais.** Elle est écrite dans K comme `equivalence_etablie`
attestée, faute d'une sorte prévue. Est-ce la bonne sorte, et quelle ressource l'atteste (un WordNet français) ?

**F3. Les variations ne couvrent pas le changement d'un modificateur.** Remplacer « prétendu » par rien (co-010), un
composé de lieu par un lieu figuré (co-012), une matière par rien (co-014), ce n'est aucune des variations du § 2.2 du
plan. J'ai rangé ces variantes sous `changement_de_modalite`, `changement_de_portee` ou `changement_de_participant`,
faute de mieux. Une variation « changement de modificateur » manque pour cette famille.

**F4. Une traduction ne préserve pas toujours l'ambiguïté.** Un cas abandonné : « the old abbot » (vieux, ou ancien ?)
n'a pas d'équivalent ambigu en français (« le vieil abbé » est âgé, « l'ancien abbé » ne l'est plus). La traduction
change alors le statut, contre la relation métamorphique. Le protocole exige une traduction pour chaque cas : un cas
d'ambiguïté propre à une langue ne peut pas s'y plier.
