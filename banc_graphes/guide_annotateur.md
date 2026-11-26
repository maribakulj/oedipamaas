## 2. Le schéma d'un graphe annoté

Un fichier JSON : une liste d'objets, un par texte.

```json
{"k": 12, "genre": "positif", "langue": "en", "texte": "…",
 "entites":    [{"id": "e1", "tete": "man", "mention": "A young man", "proprietes": ["young"],
                 "noms": ["Jerome"], "polarite": "pos", "modalite": "affirme", "portee": "represente",
                 "enonciateur": "auteur"}],
 "evenements": [{"id": "v1", "predicat": "sing", "mention": "singing", "nom_d_action": null,
                 "roles": {"agent": ["e1"]}}],
 "relations":  [{"id": "r1", "sujet": "e1", "relation": "in", "objet": "e2"}],
 "coref":      [["e1", "e3"]],
 "distinct":   [["e1", "e4"]],
 "alternatives": [["e5", "e6"]],
 "notes": "…"}
```

- `k`, `genre`, `langue`, `texte` : recopiés du texte donné.
- Les qualificatifs (`polarite`, `modalite`, `portee`, `enonciateur`) peuvent être omis quand ils ont leur valeur par
  défaut (`pos`, `affirme`, `represente`, `auteur`) ; une propriété ou un nom qui en a d'autres s'écrit en objet :
  `{"propriete": "crowned", "polarite": "neg"}`, `{"nom": "Peter", "modalite": "probable"}`.
- `mention` : le groupe nominal ou le mot tel qu'il est écrit dans le texte (une sous-chaîne exacte) ; s'il apparaît
  plusieurs fois, les mentions sont prises dans l'ordre du texte.
- `notes` : facultatif, une phrase sur un choix difficile.

## 3. Les conventions d'annotation

**Ce que l'on annote.** Le sens du texte, pas sa syntaxe : ce que la phrase dit de la scène ou de l'œuvre. On
n'invente rien que le texte ne dise ; on n'omet rien qu'il dise.

**Les entités.** Une entité par mention d'un référent : chaque groupe nominal dont la tête est un nom (personnes,
animaux, objets, lieux, parties du corps, vêtements, éléments du décor, l'œuvre elle-même, son support).
- `tete` : le lemme du nom tête, dans la langue du texte, en minuscules, au singulier (`man`, `tree`, `homme`,
  `arbre`) ; un composé que le dictionnaire donne comme une unité garde ses mots (`ring finger`, `coat of arms`,
  `pomme de terre`, `mal de tête`) ; un nom propre seul (« Hercules ») a pour tête son nom en minuscules
  (`hercules`) et le nom dans `noms`.
- Les **pronoms** ne sont pas des entités : leurs rôles et relations vont à l'entité qu'ils désignent selon le sens
  (« a bishop who anoints his head and consecrates him » : *his* et *him* sont le saint, non l'évêque) ; à sens égal,
  la mention la plus proche avant eux.
- Deux mentions du même référent (« a saint… the old man ») sont deux entités, réunies par `coref`. Un attribut
  nominal (« the man is a saint ») : deux entités et une `coref`.
- `nombre` : seulement quand le texte dit un nombre (« two angels » : 2) ; un pluriel sans nombre n'en a pas.
- `proprietes` : les adjectifs et les participes qui qualifient le référent, au lemme (`young`, `red`, `crowned`,
  `jeune`, `rouge`, `couronné`) ; un nom en apposition de matière ou d'espèce (« a stone bridge ») : `stone`.

**Les événements.** Une action ou une situation : un verbe conjugué, un participe ou un infinitif qui dit une action
(« singing », « kneeling »), ou un nom d'action (« the crucifixion of Christ », « le dressage des chiens »).
- `predicat` : le lemme du verbe, à l'infinitif, dans la langue du texte (`sing`, `kneel`, `crucify`, `dresser`) ;
  pour un nom d'action, le verbe correspondant (`crucify`), et le nom lui-même dans `nom_d_action` (`crucifixion`) ;
  un nom d'action sans verbe usuel garde le nom comme prédicat (`battle`).
- Un participe qui décrit une posture ou une action en cours (« a kneeling man », « the man, praying ») est un
  événement dont le référent a son rôle, non une propriété ; un participe qui décrit un état résultant (« a broken
  sword », « crowned ») est une propriété ; un participe qui a son propre complément (« couronnés de myrte »,
  « crowned with laurel ») est un événement, le complément en instrument.
- Les verbes de simple présence ou de figuration (« is shown », « appears », « there is », « we see », « est
  représenté ») ne sont pas des événements : ils disent seulement que l'entité est figurée ; une apparition dans la
  scène (« apparaît en songe à un évêque ») est un événement.

**Les rôles** (`roles` : rôle → liste d'entités) :
- `agent` : celui qui fait l'action ou qui l'éprouve (sujet d'un verbe actif, complément d'agent d'un passif ; le
  sujet de *voir*, *regarder*, *prier*, *se tenir*) ;
- `patient` : ce qui subit l'action et en est changé (tué, brisé, lavé, guéri, couronné) ;
- `theme` : ce qui est déplacé, tenu, porté, donné, regardé, ou dont on parle, sans en être changé ;
- `instrument` : ce avec quoi l'action est faite ; `destinataire` : à qui l'on donne, montre, dit ;
- `lieu` : où se passe l'action (« stands in a meadow » : la prairie).
Le passif se ramène à l'actif (« the lion is strangled by Hercules » : Hercule agent, le lion patient). Un rôle que
le texte ne dit pas n'est pas écrit (pas d'agent supposé). Le lieu d'une action, complément du verbe (« stands on the
bank », « se tient près d'un lit »), est le rôle `lieu` ; le lieu d'une entité, dit dans son groupe nominal ou par
*être* (« a meadow beneath the trees », « le livre est sur la table »), est une relation. Un rôle et une relation ne
relient que des **entités** : un nom d'action qui est lui-même participant (« la rupture… foudroyé ») est aussi
annoté comme entité (sa tête : le nom), et c'est cette entité qui reçoit le rôle. La cause, le but et la manière sans
préposition (« paisiblement », « au loin ») ne sont pas annotés.

**Les relations** (`sujet`, `relation`, `objet`, orientées : le sujet est ce dont on dit la relation) :
- les prépositions de lieu et de position, au lemme de la préposition dans la langue du texte (`in`, `on`, `beneath`,
  `beside`, `sur`, `sous`, `à côté de`) : « a meadow beneath the trees » : la prairie, `beneath`, les arbres ;
- la possession et le complément du nom : `of` ou `de`, du possédé vers le possesseur (« his hand », « la main du
  saint » : la main, `of` / `de`, l'homme) ; les parties du corps aussi ;
- un verbe de relation stative peut être un événement (« holds », « tient ») : on l'écrit en **événement** avec ses
  rôles (agent, theme), jamais en relation ;
- une préposition qui ne dit ni un lieu ni la possession et qu'aucun rôle ne couvre (la cause, l'origine, le résultat :
  « grimaçant sous une migraine », « changed into a wolf », « snatched from ») : une relation, au lemme de la
  préposition, du référent qu'elle qualifie vers son complément.

**La négation, la modalité, la portée, l'énonciateur** (les qualificatifs d'une entité, d'un nom, d'une propriété,
d'un événement ou d'une relation) :
- `polarite: "neg"` : ce que le texte nie. « without any instrument », « no accompanist », « il n'y a pas de lion » :
  l'entité niée. « he does not hold a book » : l'événement nié (et le livre a `modalite: "non_affirme"`). « not
  crowned » : la propriété niée.
- `modalite` : `probable` (« probably », « sans doute »), `possible` (« perhaps », « may be »), `traditionnel`
  (« traditionally identified as »), `ancien` (« formerly attributed to »), `non_affirme` (mentionné sans être
  affirmé : l'objet d'un verbe nié, le contenu d'une question), `titre` (dit seulement par le titre de l'œuvre) ;
- `portee` : `represente` (ce que l'image montre ; défaut), `oeuvre` (l'objet matériel : la toile, le panneau, l'état,
  la technique, le cadre), `autre_oeuvre` (une autre œuvre), `source` (un récit, un texte, une légende racontée et non
  montrée), `histoire` (provenance, attribution, commande), `non_ancre` (le texte ne rattache pas l'énoncé à l'image :
  biographie, style, jugement) ;
- `enonciateur` : `auteur` (défaut), ou `{"cite": "Vasari"}` quand le texte attribue l'énoncé à une source (« according
  to Vasari »).
- `alternatives` : des hypothèses exclusives que le texte donne (« a book or a scroll ») : la liste de leurs entités
  (ou événements).
- `distinct` : seulement quand le texte dit que deux mentions sont deux référents différents (« another man », « l'un…
  l'autre ») ; sans cela, deux mentions non coréférentes n'ont pas d'identité dite.

**Les cas difficiles** : choisir ce qui suit le sens, et le dire dans `notes`. Ne pas laisser un texte sans graphe.

*Décisions d'adjudication du 27/11* (après les deux vagues ; provisoires, à valider par la propriétaire ; elles
tranchent les ambiguïtés que les annotateurs ont signalées, et l'adjudication les applique à tous les graphes) :
- **la double négation** (« no snake is raised », « aucun maillet n'est frappé », « aucun nom n'accompagne ») :
  l'entité est niée ; l'événement dont elle est participant prend `modalite: "non_affirme"` (rien ne dit qu'il a
  lieu) ; un verbe nié sans quantificateur (« he does not hold a book ») : l'événement nié, l'objet `non_affirme` ;
- **l'état dit par *être* et un participe** (« est assis », « est agenouillé », « is seated ») : l'événement de la
  posture, son sujet en agent (ce n'est pas un passif) ;
- **le peintre et la composition** (« the painter emphasises the light ») : le peintre a la portée `histoire`, ses
  actes sur l'image la portée `oeuvre` ; une légende ou une inscription de l'œuvre : `oeuvre` ; un récit, une notice
  citée : `source` ;
- **une identité seulement possible** (« she could be Diana or a huntress ») : chaque identité est une entité de
  modalité `possible`, réunies en `alternatives`, sans `coref` ; une seule identité possible (« it may be a
  merchant's emblem ») : l'entité de modalité `possible`, sans `coref` ;
- **des propriétés exclusives** (« réelle ou imaginaire ») : chacune avec `modalite: "possible"` ;
- **les pronoms quantifiés** (« l'un… l'autre », « certains… d'autres », « one of them ») : des entités, de tête le
  nom qu'ils reprennent s'il est dit (« l'un des hommes » : `homme`), sinon le pronom ; « chacun », « personne »,
  « nothing » vont à leur référent, ou nient (« nothing lies in the pans » : l'événement nié) ;
- **la direction** (« towards », « vers ») : le rôle `lieu` ; **le temps** (« pendant l'épidémie ») et **la manière**,
  avec ou sans préposition : non annotés ;
- **un objet qui « se dresse », « lies », « hangs », « s'élève »** : sa simple présence, et sa position en relation ;
  un être animé : l'événement ;
- **le complément d'agent d'un participe passif** (« accompagné d'un phylactère ») : `agent` ; un point de vue (« vu
  du dehors ») : non annoté ;
- **les entités du titre** reprises dans le corps : l'entité du titre a `modalite: "titre"`, une `coref` la relie à
  sa reprise ;
- **les composés** que le dictionnaire donne comme une unité restent une unité (« jeune fille », « vieil homme » non :
  `homme` + `vieux`) ;
- **le contenu d'une inscription** (« Jésus de Nazareth, roi des Juifs ») : l'inscription est une entité ; son texte
  n'est pas annoté comme des assertions sur la scène.

*Précisions du 26/11, après la double annotation du développement* : les pronoms (selon le sens), le participe à
complément, l'apparition, les prépositions sans rôle, le lieu (rôle ou relation), les rôles et relations entre
entités seulement. Elles disent ce que l'annotateur avait fait en suivant le sens ;
les références du développement sont adjugées d'après elles.

