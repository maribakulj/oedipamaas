# Questions ouvertes : niveaux de représentation des descriptions d'œuvres (cas de développement nr-001 à nr-024)

Il s'agit des points où les documents (fondements, ontologie, spécification, protocole, NOYAU, ASSERTIONS, audit § 3.7) ne disent rien, restent ambigus ou se contredisent. Je les ai rencontrés en écrivant les cas. Quand un point fixait le statut d'un cas, ce cas porte une `decision_ouverte`, et j'ai retenu l'option la plus prudente.

## 1. Le contenu d'une autre œuvre passe-t-il à la copie, ou à l'œuvre faite « d'après » elle ? (nr-002, nr-005, nr-004 et nr-008 en variante)

- Aucun document ne dit si « copie de X », « d'après X » ou « woven after a cartoon » permettent de conclure à ce que figure l'œuvre décrite.
- La glose WordNet (copy%1:06:00:: « similar or identical ») ne précise pas sur quoi porte la ressemblance. Elle n'a qu'un statut de relation inconnue.
- Spécification § 3.2 : une dérivation par relation inconnue « doit expliquer des éléments observés ». Or l'hypothèse « la copie figure une Adoration » n'explique aucune assertion figurée de la copie. Elle transporte seulement le sujet du modèle.
- On ne sait donc pas si la mention « copy of an Adoration » compte comme une observation que l'hypothèse explique. Si c'est le cas, le statut est `etablie_sous_hypotheses` ; sinon, `inconnue`. J'ai retenu `inconnue` dans nr-002.
- Une copie rognée, réduite ou inversée (nr-002, nr-006) rend ce transfert encore plus douteux. Il faudrait dire s'il est défaisable, et par quoi.

## 2. Une figure dans le contenu d'une vision satisfait-elle une définition qui ne nomme pas de contexte ? (nr-021)

- Les fondements (§ 2.5) disent qu'un référent du contenu d'une vision n'est pas un référent du monde figuré. Le protocole (§ 4) ajoute que ce qui n'est pas dans le contexte de la figuration n'établit rien.
- Mais l'ontologie (§ 3) traite la vision comme une représentation emboîtée, figurée elle aussi.
- Aucun document ne dit si une définition de style Iconclass (« Charity personified… ») est satisfaite par une figuration emboîtée. On ne sait pas non plus si le compilateur doit borner les définitions au premier niveau.
- La même question vaut pour le tableau dans le tableau, la tapisserie et le miroir.

## 3. L'état de conservation borne-t-il le contenu figuré ? (nr-012, nr-011, nr-013 en variante)

- Une figure dont il ne reste que des vestiges (« of the Christ Child once seated on her lap, only the feet survive ») est-elle encore figurée, avec ce qu'on dit qu'elle était ? On ne sait pas non plus si « once » date l'état ancien de l'objet ou une situation figurée. L'ontologie (§ 3) n'ancre le temps que relativement aux situations figurées.
- Le dessin sous-jacent révélé par réflectographie (nr-013, variante de portée) fait-il partie du figuré de l'œuvre ? Est-ce un autre niveau de l'œuvre, ou une « autre œuvre » ? J'ai mis `inconnue` sans pouvoir citer de texte qui le fixe.
- Dans nr-011, le bras brisé de la statue : la partie (le bras) appartient à deux référents, le marbre et le guerrier figuré. La méréologie des fondements (§ 2.4) ne distingue pas la partie d'un objet de la partie d'une figure.

## 4. Les titres, les inscriptions peintes et les signatures : quel est leur statut ? (nr-014, nr-015)

- Les fondements (§ 8) laissent ouvert « le contenu textuel des inscriptions », et l'audit (§ 3.7) en fait une extension de moindre priorité. Le validateur accepte bien l'extension `contexte_emboite`, mais je n'en ai pas trouvé pour le contenu textuel d'une inscription. J'ai donc employé `contexte_emboite`, puisque les fondements (§ 2.5) disent qu'une inscription ouvre un contexte. Il faut confirmer ce choix ou nommer une extension propre.
- Le lien entre un titulus peint et la figure (« S. KATHERINA » près de la tête) : est-ce une connaissance typique (mon choix, d'où `etablie_sous_hypotheses`), ou une convention de lecture qu'on pourrait attester ? Dans le second cas, le statut serait `etablie`.
- Une signature (« IACOBVS F. ») : c'est l'auteur qui dit « signed ». Mais quand le texte rapporte une inscription sans dire si c'est une signature, rien n'indique comment distinguer un nom d'artiste d'un nom de figure.
- Un nom traduit (IACOBVS / James) : la sorte « alias » de NOYAU porte sur l'identité des individus, non sur l'identité des noms. Le validateur n'a pas de sorte de connaissance « alias ». J'ai donc écrit ce lien comme une `equivalence_etablie` entre noms. Il faut une sorte propre, ou la confirmation de ce choix.

## 5. Le niveau iconologique et les symboles non dits (nr-023)

- Une hypothèse interprétative qui lit une couleur comme symbole, quand le texte ne dit aucun symbole, explique-t-elle une observation (le bleu du manteau) ? Le cas est plus difficile quand le texte donne déjà une autre raison (le prix du lapis-lazuli).
- Les fondements (§ 5) imposent de garder les explications concurrentes. Mais ils ne disent pas si une explication donnée par le texte lui-même (un fait matériel, de l'histoire de l'œuvre) concourt avec une explication symbolique (le signifié). Ces deux explications n'appartiennent pas au même contexte.

## 6. Une source citée ou un programme d'archive : énonciateur cité, ou portée « source » ? (nr-024 ; nr-009 ; nr-022 et nr-019 en variante)

- « According to the programme drawn up by Abbot Hugo… » : j'ai lu l'abbé comme un énonciateur cité, d'où `non_certifiee` (NOYAU § 4.4).
- Mais ASSERTIONS donne aussi une portée `source` (un texte, un récit). Si l'on lit l'assertion comme portant sur le programme écrit, il n'y a plus d'appui, et le statut devient `inconnue`. Aucun document ne départage les deux lectures.
- Les deux variantes « le contrat demandait une Fortitude » (nr-019) et « sur le carton préparatoire » (nr-017) posent la même question : elles relèvent de l'histoire ou d'une autre œuvre. J'ai mis `inconnue`.
- Le protocole ne dit pas non plus si `non_certifiee` est plus faible ou plus fort que `inconnue` pour l'erreur de sûreté (§ 7). C'est pourtant ce qu'il faudrait savoir pour choisir « l'option la plus prudente ».

## 7. Le contraste explicite vaut-il négation ? (nr-006)

- « Abraham, qui dans le tableau lève le couteau de la main droite, le lève ici de la main gauche » : ce contraste est-il une négation dite de la main droite dans l'estampe ?
- Le protocole ne connaît que la négation dite, la distinction documentaire et la contrainte du texte (D31). Il ne dit rien des contrastes ni des exclusivités implicites (une main plutôt que l'autre). J'ai mis `inconnue`, la lecture comme négation donnerait `ecartee`.

## 8. Nom propre homographe d'un concept, et sens des concepts personnifiés (nr-020, nr-019, nr-016, nr-021, nr-022, nr-024)

- « Prudence Maréchal » contre « la Prudence » : l'audit (§ 3.7) montre que le langage actuel confond les deux. Mais aucun document ne dit si un portrait d'une personne qui porte le nom d'une vertu peut fonder une hypothèse de portrait historié, ni avec quelle connaissance. J'ai mis `inconnue`.
- La polysémie des noms de concepts : hope, prudence, justice et charity ont chacun plusieurs sens WordNet, et « Force » / « fortitude » traduit mal le français. Je n'ai écrit aucune hypothèse de sens, en supposant que la définition demande le concept par son lemme et que tous les sens l'atteignent. C'est discutable :
  - si la définition est typée par un sens précis (charity%1:07:00::, la vertu), D30 imposerait une hypothèse `sens` dans presque tous les cas de personnification ;
  - la traduction (fr → en) changerait peut-être le nombre de sens.
- Il faut fixer comment une définition de personnification désigne son concept.

## 9. Des adjectifs de degré et des antonymes comme appuis négatifs (nr-018 ; nr-010 en variante)

- Dans nr-018, j'ai fait de « young ⇒ non old », pour une même classe de comparaison, une implication attestée, d'où `ecartee`. L'ontologie (§ 6) laisse ouverts les adjectifs de degré et leur classe de comparaison. Elle ne dit pas non plus si l'antonymie de WordNet peut fonder une négation déductive.
- Dans nr-010 (variante « jeune servante »), où K ne contient pas d'antonymie, j'ai mis `inconnue`. Les deux cas ne sont cohérents que relativement à K.

## 10. Une négation restreinte qui couvre une partie de la définition (nr-003)

- « La copie ne montre aucun ange au-dessus de l'étable » : la sémantique cible réfute la conjonction de la définition, d'où `ecartee`.
- Mais NOYAU (§ 1.1, D41) dit que le noyau 0.3 ne dérive pas cette réfutation. Elle n'est pourtant pas une extension du langage, et le validateur n'a rien pour la nommer. J'ai mis `extensions_requises: aucune`. Faut-il une extension, ou une opération de complétude du noyau, pour que la phase qui doit faire passer ce cas soit désignée ?

## 11. Les modalités traditionnelle et probable sur l'identification (nr-008, nr-019, nr-002 en variante)

- « Traditionally identified as Saint Eustace », « probably Fortitude » : le § 2.2 du plan dit « établie seulement si affirmée ». L'audit (§ 3.6, (5)) envisage pourtant des prémisses graduées comme hypothèses.
- Le validateur n'a pas de sorte d'hypothèse pour une prémisse graduée. J'ai mis `inconnue` partout. Si l'opération est un jour décidée, ces variantes deviendraient `etablie_sous_hypotheses`, avec une sorte d'hypothèse encore à créer.

## 12. Les noms d'extensions du validateur

- Le validateur rejette les noms qu'il ne connaît pas sans donner la liste de ceux qu'il accepte. Pour trouver les noms reconnus, j'ai essayé des noms au hasard jusqu'à ce que le système de permissions me refuse de continuer.
- Je n'ai pas trouvé de nom pour `non/1` dans les requêtes, ni pour le contenu d'une inscription. Aucun de mes cas ne demande `non/1`.
- La liste des extensions acceptées devrait figurer dans le protocole (§ 4 renvoie à « la liste du validateur », que les rédacteurs ne peuvent pas lire).
