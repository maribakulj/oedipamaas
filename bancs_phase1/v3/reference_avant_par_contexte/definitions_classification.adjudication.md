# Adjudication de la référence sémantique : definitions_classification

Éléments : 165 ; accord sur le statut 0.836, kappa 0.789, accord sur les valeurs 0.836 (comparaison de A et B).

Règles appliquées : guide `ANNOTATION_REFERENCE.md` (§ 7, précisions 1.1), `INTERPRETATIONS_ADMISSIBLES.md` (IA), `ONTOLOGIE_EVENTUALITES.md` (ONT). Une dépendance retient le statut de l'option la plus prudente sur les deux axes.

## Bilan

- accords complets (statut, valeurs et forme) : 123 (dont 5 dont le statut change par la précision 1.1)
- désaccords de fond (statut ou valeurs) : 29 — tranchés : 10 ; dépendances : 19
- désaccords de forme seulement (natures, contextes, dimensions) : 13 — gardés comme accords : 7 ; repris : 6
- dépendances appliquées, par thème : inversion de rôles (K* : asymétrie) (5); contexte : statue et décor (5); élément non mentionné apporté par la connaissance typique d'un type (4); convention d'évaluation : situation unique (4); inscription et figure : légende gravée (1)
- dépendances signalées sur des accords (non appliquées) : symbole non dit (connaissance typique) (5)

Statuts de référence des cas de base : dc-001 `etablie`, dc-002 `etablie`, dc-003 `inconnue`, dc-004 `etablie_sous_hypotheses`, dc-005 `divergent`, dc-006 `ecartee`, dc-007 `etablie_sous_hypotheses`, dc-008 `ecartee`, dc-009 `etablie_sous_hypotheses`, dc-010 `etablie_sous_hypotheses`, dc-011 `etablie_sous_hypotheses`, dc-012 `inconnue`, dc-013 `etablie_sous_hypotheses`, dc-014 `divergent`, dc-015 `etablie_sous_hypotheses`, dc-016 `ecartee`, dc-017 `etablie`, dc-018 `inconnue`, dc-019 `etablie`, dc-020 `inconnue`, dc-021 `ecartee`, dc-022 `inconnue`, dc-023 `inconnue`, dc-024 `etablie`

## Désaccords de fond

### dc-001#4

- A : `etablie_sous_hypotheses` ; B : `etablie_sous_hypotheses` ; champs en désaccord : valeurs, natures, contextes
- **Référence : `inconnue`** (adjudication)
- Satisfaction contextuelle : `principal > état d'origine` → `etablie_sous_hypotheses`
- Raison : Le bas du corps est brisé : dans l'œuvre actuelle, la queue de poisson n'est ni dite ni niée (N, A explicite, B ne dit rien de V pour l'œuvre actuelle) ; dans l'état d'origine, elle n'est que possible. Par la précision 1.1 § 1, le statut se lit sur l'œuvre telle que la notice la décrit ; l'état d'origine est un contexte (IA § 7.3), non une convention, et va dans satisfactions_contextuelles.

### dc-002#4

- A : `non_certifiee` ; B : `inconnue` ; champs en désaccord : statut, valeurs, natures
- **Référence : `inconnue`** (adjudication)
- Raison : La tête est couverte d'un capuchon : aucune tonsure n'est figurée. « Il avait reçu la tonsure à Saint-Denis » vient de la rubrique, qui raconte l'histoire de l'homme et ne décrit pas l'image : elle ne satisfait rien (guide § 3), et seules les inclusions analytiques passent d'un contexte à l'autre (décision 21). Le non_certifiee de A demanderait en outre que l'état résultant d'un rite tienne au moment figuré. Même tenue pour une dépendance, l'option prudente est inconnue.

### dc-007#4

- A : `etablie_sous_hypotheses` ; B : `non_certifiee` ; champs en désaccord : statut, natures, contextes
- **Référence : `inconnue`** (dependance)
- Raison : Seuls la lecture, le vieillard et la cabane de branchages sont dits de la figure ; la solitude au désert vient de la légende gravée, qui raconte sa vie. A (esh, connaissance typique) et B (non_certifiee, source citée) lisent l'inscription de deux façons que les principes ne départagent pas, et une troisième (récit) ne satisfait rien. Dépendance ; on retient inconnue.
- Dépendance d1 [inscription et figure : légende gravée ; décision 20 (l'étiquette : source citée ou titre, reste) ; décision 21] : La légende gravée (« il vécut seul au désert pendant quarante ans ») est-elle une source citée qui parle du figuré, un texte inscrit dont le contenu passe à la figure par un lien typique, ou un récit de la vie de l'homme qui ne décrit pas l'image ? Options : source citée parlant du figuré → `non_certifiee` ; texte inscrit, lien titulus-figure typique, désert du moment figuré supposé → `etablie_sous_hypotheses` ; récit de vie : rien ne passe à la figuration (guide § 3 ; décision 21) → `inconnue`. Retenu : `inconnue`. option la plus prudente sur les deux axes : elle n'affirme ni un V ni un F que l'autre option n'affirme pas.

### dc-011#4

- A : `inconnue` ; B : `ecartee` ; champs en désaccord : statut, valeurs
- **Référence : `inconnue`** (dependance)
- Raison : Rôles inversés : le vieillard aveugle guide le garçon. Que « guider » soit asymétrique au même moment (B) est une entrée que la décision 9 laisse ouverte (« la liste des relations asymétriques ») ; A n'y voit aucun appui négatif. Dépendance ; on retient inconnue.
- Dépendance d1 [inversion de rôles (K* : asymétrie) ; décision 9 (la liste des relations asymétriques reste)] : Inversion de rôles : « guider » (le vieillard guide le garçon ; la définition demande le garçon guidant le vieillard) est-elle une relation asymétrique (R(x, y) exclut R(y, x) au même moment), donc un appui négatif ? Options : asymétrie analytique → `ecartee` ; asymétrie non attestée → `inconnue`. Retenu : `inconnue`. option la plus prudente sur les deux axes : elle n'affirme ni un V ni un F que l'autre option n'affirme pas (ecartee affirmerait un F que l'autre option n'affirme pas).

### dc-012

- A : `etablie_sous_hypotheses` ; B : `inconnue` ; champs en désaccord : statut, valeurs, natures
- **Référence : `inconnue`** (dependance)
- Raison : La femme à l'enfant sur un âne est dite ; Joseph menant l'âne n'est mentionné nulle part. Le titre « La Fuite en Égypte » est un texte, qui ne satisfait rien seul (guide § 3). Que Joseph soit supposé parce qu'une Fuite en Égypte le comporte d'ordinaire (A) est une connaissance typique qui n'explique aucune observation ; B la refuse. Dépendance ; on retient inconnue.
- Dépendance d1 [élément non mentionné apporté par la connaissance typique d'un type ; guide §§ 1 et 3 ; décision 24 (non fixé)] : Joseph menant l'âne, que la description ne mentionne pas, peut-il être supposé parce que une Fuite en Égypte (reconnue au titre, à l'âne et au palmier) le comporte d'ordinaire ? Options : admis comme connaissance typique → `etablie_sous_hypotheses` ; non admis : le silence n'appuie rien, et la connaissance typique n'explique ici aucune observation → `inconnue`. Retenu : `inconnue`. option la plus prudente sur les deux axes : elle n'affirme ni un V ni un F que l'autre option n'affirme pas.

### dc-012#0

- A : `etablie_sous_hypotheses` ; B : `inconnue` ; champs en désaccord : statut, valeurs, natures
- **Référence : `inconnue`** (dependance)
- Raison : La femme à l'enfant sur un âne est dite ; Joseph menant l'âne n'est mentionné nulle part. Le titre « La Fuite en Égypte » est un texte, qui ne satisfait rien seul (guide § 3). Que Joseph soit supposé parce qu'une Fuite en Égypte le comporte d'ordinaire (A) est une connaissance typique qui n'explique aucune observation ; B la refuse. Dépendance ; on retient inconnue.
- Dépendance d1 [élément non mentionné apporté par la connaissance typique d'un type ; guide §§ 1 et 3 ; décision 24 (non fixé)] : Joseph menant l'âne, que la description ne mentionne pas, peut-il être supposé parce que une Fuite en Égypte (reconnue au titre, à l'âne et au palmier) le comporte d'ordinaire ? Options : admis comme connaissance typique → `etablie_sous_hypotheses` ; non admis : le silence n'appuie rien, et la connaissance typique n'explique ici aucune observation → `inconnue`. Retenu : `inconnue`. option la plus prudente sur les deux axes : elle n'affirme ni un V ni un F que l'autre option n'affirme pas.

### dc-012#4

- A : `etablie_sous_hypotheses` ; B : `inconnue` ; champs en désaccord : statut, valeurs, natures
- **Référence : `inconnue`** (dependance)
- Raison : La femme à l'enfant sur un âne est dite ; Joseph menant l'âne n'est mentionné nulle part. Le titre « La Fuite en Égypte » est un texte, qui ne satisfait rien seul (guide § 3). Que Joseph soit supposé parce qu'une Fuite en Égypte le comporte d'ordinaire (A) est une connaissance typique qui n'explique aucune observation ; B la refuse. Dépendance ; on retient inconnue.
- Dépendance d1 [élément non mentionné apporté par la connaissance typique d'un type ; guide §§ 1 et 3 ; décision 24 (non fixé)] : Joseph menant l'âne, que la description ne mentionne pas, peut-il être supposé parce que une Fuite en Égypte (reconnue au titre, à l'âne et au palmier) le comporte d'ordinaire ? Options : admis comme connaissance typique → `etablie_sous_hypotheses` ; non admis : le silence n'appuie rien, et la connaissance typique n'explique ici aucune observation → `inconnue`. Retenu : `inconnue`. option la plus prudente sur les deux axes : elle n'affirme ni un V ni un F que l'autre option n'affirme pas.

### dc-012#5

- A : `etablie_sous_hypotheses` ; B : `inconnue` ; champs en désaccord : statut, valeurs, natures
- **Référence : `inconnue`** (dependance)
- Raison : La femme à l'enfant sur un âne est dite ; Joseph menant l'âne n'est mentionné nulle part. Le titre « La Fuite en Égypte » est un texte, qui ne satisfait rien seul (guide § 3). Que Joseph soit supposé parce qu'une Fuite en Égypte le comporte d'ordinaire (A) est une connaissance typique qui n'explique aucune observation ; B la refuse. Dépendance ; on retient inconnue.
- Dépendance d1 [élément non mentionné apporté par la connaissance typique d'un type ; guide §§ 1 et 3 ; décision 24 (non fixé)] : Joseph menant l'âne, que la description ne mentionne pas, peut-il être supposé parce que une Fuite en Égypte (reconnue au titre, à l'âne et au palmier) le comporte d'ordinaire ? Options : admis comme connaissance typique → `etablie_sous_hypotheses` ; non admis : le silence n'appuie rien, et la connaissance typique n'explique ici aucune observation → `inconnue`. Retenu : `inconnue`. option la plus prudente sur les deux axes : elle n'affirme ni un V ni un F que l'autre option n'affirme pas.
- paraphrase_infidele : true — Paraphrase (même langue), non traduction : elle omet le titre « La Fuite en Égypte », une information qui appuyait l'identification ; infidélité réelle, sans effet sur le statut (inconnue). A l'avait signalée sous le champ traduction_infidele, qui ne vaut que pour une traduction.

### dc-015#4

- A : `divergent` ; B : `etablie_sous_hypotheses` ; champs en désaccord : statut, valeurs, natures, contextes
- **Référence : `ecartee`** (adjudication)
- Satisfaction contextuelle : `principal > état d'origine` → `etablie_sous_hypotheses`
- Raison : « Ce verre a été perdu lors du remontage » : par la signification de « perdre », le verre de la tour n'est plus dans le vitrail ; la seule tour citée n'est pas à ses côtés dans l'œuvre actuelle (F pour les référents cités, comme « remplacer » en dc-016, où A et B s'accordent). A l'écrit ; B ne juge que l'état d'origine et dit lui-même que « la tour n'est plus dans le vitrail ». Par la précision 1.1 § 1, le statut se lit sur l'œuvre telle que la notice la décrit ; l'état d'origine est un contexte (IA § 7.3), non une convention, et va dans satisfactions_contextuelles. A écrivait divergent : une différence de contextes n'en donne jamais.

### dc-018

- A : `etablie` ; B : `divergent` ; champs en désaccord : statut, valeurs, dimensions, contextes
- **Référence : `inconnue`** (dependance)
- Satisfaction contextuelle : `principal > décor de la scène (fiction scénique)` → `etablie`
- Raison : A (etablie dans le contexte du décor) et B (divergent : F matériel, V scénique) s'accordent sur une chose : dans la fiction scénique, le décor figure un laurier. Par la précision 1.1 § 1, c'est une satisfaction contextuelle, non une lecture, et le divergent de B ne tient pas. Sur le contexte principal (la scène d'opéra), le statut dépend de la lecture de « laurier de carton », que les principes laissent ouverte (décisions 13 et 31) : on retient inconnue.
- Dépendance d1 [contexte : statue et décor ; décisions 13 et 31 (« la statue et le décor », reste)] : « Un laurier de carton peint » : une matière (un laurier fait de carton, comme « un ange de marbre » au sens matière, IA § 7.5), un modificateur privatif (un objet de carton, qui n'est pas un arbre), ou un décor qui figure un laurier dans la fiction scénique ? Le premier donne V sur le principal, le deuxième F, le troisième F ou N sur le principal et V dans le décor. Options : matière : un laurier de carton est un laurier → `etablie (principal)` ; privatif ou décor : l'objet de carton n'est pas un arbre → `ecartee (principal)`. Retenu : `inconnue`. option la plus prudente sur les deux axes : elle n'affirme ni un V ni un F que l'autre option n'affirme pas ; sur le décor, A et B s'accordent : V.

### dc-018#0

- A : `etablie` ; B : `divergent` ; champs en désaccord : statut, valeurs, dimensions, contextes
- **Référence : `inconnue`** (dependance)
- Satisfaction contextuelle : `principal > décor de la scène (fiction scénique)` → `etablie`
- Raison : A (etablie dans le contexte du décor) et B (divergent : F matériel, V scénique) s'accordent sur une chose : dans la fiction scénique, le décor figure un laurier. Par la précision 1.1 § 1, c'est une satisfaction contextuelle, non une lecture, et le divergent de B ne tient pas. Sur le contexte principal (la scène d'opéra), le statut dépend de la lecture de « laurier de carton », que les principes laissent ouverte (décisions 13 et 31) : on retient inconnue.
- Dépendance d1 [contexte : statue et décor ; décisions 13 et 31 (« la statue et le décor », reste)] : « Un laurier de carton peint » : une matière (un laurier fait de carton, comme « un ange de marbre » au sens matière, IA § 7.5), un modificateur privatif (un objet de carton, qui n'est pas un arbre), ou un décor qui figure un laurier dans la fiction scénique ? Le premier donne V sur le principal, le deuxième F, le troisième F ou N sur le principal et V dans le décor. Options : matière : un laurier de carton est un laurier → `etablie (principal)` ; privatif ou décor : l'objet de carton n'est pas un arbre → `ecartee (principal)`. Retenu : `inconnue`. option la plus prudente sur les deux axes : elle n'affirme ni un V ni un F que l'autre option n'affirme pas ; sur le décor, A et B s'accordent : V.

### dc-018#3

- A : `etablie` ; B : `divergent` ; champs en désaccord : statut, valeurs, dimensions, contextes
- **Référence : `inconnue`** (dependance)
- Satisfaction contextuelle : `principal > décor de la scène (fiction scénique)` → `etablie`
- Raison : A (etablie dans le contexte du décor) et B (divergent : F matériel, V scénique) s'accordent sur une chose : dans la fiction scénique, le décor figure un laurier. Par la précision 1.1 § 1, c'est une satisfaction contextuelle, non une lecture, et le divergent de B ne tient pas. Sur le contexte principal (la scène d'opéra), le statut dépend de la lecture de « laurier de carton », que les principes laissent ouverte (décisions 13 et 31) : on retient inconnue.
- Dépendance d1 [contexte : statue et décor ; décisions 13 et 31 (« la statue et le décor », reste)] : « Un laurier de carton peint » : une matière (un laurier fait de carton, comme « un ange de marbre » au sens matière, IA § 7.5), un modificateur privatif (un objet de carton, qui n'est pas un arbre), ou un décor qui figure un laurier dans la fiction scénique ? Le premier donne V sur le principal, le deuxième F, le troisième F ou N sur le principal et V dans le décor. Options : matière : un laurier de carton est un laurier → `etablie (principal)` ; privatif ou décor : l'objet de carton n'est pas un arbre → `ecartee (principal)`. Retenu : `inconnue`. option la plus prudente sur les deux axes : elle n'affirme ni un V ni un F que l'autre option n'affirme pas ; sur le décor, A et B s'accordent : V.
- paraphrase_infidele : false — B la signale (« tient lieu du lieu », musiciens omis) : nuance sans effet, tenue pour fidèle.

### dc-018#4

- A : `etablie` ; B : `divergent` ; champs en désaccord : statut, valeurs, dimensions, contextes
- **Référence : `inconnue`** (dependance)
- Satisfaction contextuelle : `principal > décor de la scène (fiction scénique)` → `etablie`
- Raison : A (etablie dans le contexte du décor) et B (divergent : F matériel, V scénique) s'accordent sur une chose : dans la fiction scénique, le décor figure un laurier. Par la précision 1.1 § 1, c'est une satisfaction contextuelle, non une lecture, et le divergent de B ne tient pas. Sur le contexte principal (la scène d'opéra), le statut dépend de la lecture de « laurier de carton », que les principes laissent ouverte (décisions 13 et 31) : on retient inconnue.
- Dépendance d1 [contexte : statue et décor ; décisions 13 et 31 (« la statue et le décor », reste)] : « Un laurier de carton peint » : une matière (un laurier fait de carton, comme « un ange de marbre » au sens matière, IA § 7.5), un modificateur privatif (un objet de carton, qui n'est pas un arbre), ou un décor qui figure un laurier dans la fiction scénique ? Le premier donne V sur le principal, le deuxième F, le troisième F ou N sur le principal et V dans le décor. Options : matière : un laurier de carton est un laurier → `etablie (principal)` ; privatif ou décor : l'objet de carton n'est pas un arbre → `ecartee (principal)`. Retenu : `inconnue`. option la plus prudente sur les deux axes : elle n'affirme ni un V ni un F que l'autre option n'affirme pas ; sur le décor, A et B s'accordent : V.

### dc-018#5

- A : `etablie_sous_hypotheses` ; B : `divergent` ; champs en désaccord : statut, valeurs, dimensions, contextes
- **Référence : `inconnue`** (dependance)
- Satisfaction contextuelle : `principal > décor de la scène (fiction scénique)` → `etablie_sous_hypotheses`
- Raison : A (etablie dans le contexte du décor) et B (divergent : F matériel, V scénique) s'accordent sur une chose : dans la fiction scénique, le décor figure un laurier. Par la précision 1.1 § 1, c'est une satisfaction contextuelle, non une lecture, et le divergent de B ne tient pas. Sur le contexte principal (la scène d'opéra), le statut dépend de la lecture de « laurier de carton », que les principes laissent ouverte (décisions 13 et 31) : on retient inconnue. Ici le décor n'est que peut-être un laurier.
- Dépendance d1 [contexte : statue et décor ; décisions 13 et 31 (« la statue et le décor », reste)] : « Un laurier de carton peint » : une matière (un laurier fait de carton, comme « un ange de marbre » au sens matière, IA § 7.5), un modificateur privatif (un objet de carton, qui n'est pas un arbre), ou un décor qui figure un laurier dans la fiction scénique ? Le premier donne V sur le principal, le deuxième F, le troisième F ou N sur le principal et V dans le décor. Options : matière : un laurier de carton est un laurier → `etablie (principal)` ; privatif ou décor : l'objet de carton n'est pas un arbre → `ecartee (principal)`. Retenu : `inconnue`. option la plus prudente sur les deux axes : elle n'affirme ni un V ni un F que l'autre option n'affirme pas ; sur le décor, A et B s'accordent : V.

### dc-019#3

- A : `etablie` ; B : `etablie_sous_hypotheses` ; champs en désaccord : statut, dimensions, natures, contextes
- **Référence : `etablie`** (adjudication)
- Raison : « Portrait of a lady, perhaps Marie-Anne de Bourbon, princesse de Conti, as Diana » : « perhaps » est dans l'apposition, fermée par la virgule ; « as Diana » se rattache à « portrait of a lady ». Le texte ne laisse pas au lecteur compétent une portée large : ce n'est pas un point (guide § 2). Croissant et arc sont dits : etablie (A). B gardait la portée large, sous identification iconographique.

### dc-020

- A : `inconnue` ; B : `ecartee_sous_hypotheses` ; champs en désaccord : statut, valeurs, dimensions
- **Référence : `inconnue`** (adjudication)
- Raison : « Prétendu » n'engage pas (décision 29, tranchée) : ni « il est moine », ni « il ne l'est pas ». La lecture privative de B (faux moine : F) donne à « prétendu » la force d'une négation que le principe lui refuse ; froc et capuchon sont un costume. Un renard peut être moine dans une fable (dc-020#6, accord etablie) : aucune incompatibilité d'espèce. Inconnue (A).

### dc-020#0

- A : `inconnue` ; B : `ecartee_sous_hypotheses` ; champs en désaccord : statut, valeurs, dimensions
- **Référence : `inconnue`** (adjudication)
- Raison : « Prétendu » n'engage pas (décision 29, tranchée) : ni « il est moine », ni « il ne l'est pas ». La lecture privative de B (faux moine : F) donne à « prétendu » la force d'une négation que le principe lui refuse ; froc et capuchon sont un costume. Un renard peut être moine dans une fable (dc-020#6, accord etablie) : aucune incompatibilité d'espèce. Inconnue (A).

### dc-020#4

- A : `inconnue` ; B : `ecartee_sous_hypotheses` ; champs en désaccord : statut, valeurs, dimensions
- **Référence : `inconnue`** (adjudication)
- Raison : « Prétendu » n'engage pas (décision 29, tranchée) : ni « il est moine », ni « il ne l'est pas ». La lecture privative de B (faux moine : F) donne à « prétendu » la force d'une négation que le principe lui refuse ; froc et capuchon sont un costume. Un renard peut être moine dans une fable (dc-020#6, accord etablie) : aucune incompatibilité d'espèce. Inconnue (A).

### dc-020#5

- A : `inconnue` ; B : `ecartee_sous_hypotheses` ; champs en désaccord : statut, valeurs, dimensions
- **Référence : `inconnue`** (adjudication)
- Raison : « Qui se donne pour moine » rapporte une prétention du renard ; comme « prétendu », elle n'engage pas (décision 29, tranchée) : ni « il est moine », ni « il ne l'est pas ». La lecture privative de B (faux moine : F) donne à « prétendu » la force d'une négation que le principe lui refuse ; froc et capuchon sont un costume. Un renard peut être moine dans une fable (dc-020#6, accord etablie) : aucune incompatibilité d'espèce. Inconnue (A).
- paraphrase_infidele : false — B la signale (feuillet rogné omis) : omission sans effet ; « qui se donne pour moine » rend « prétendu moine », tenue pour fidèle.

### dc-022

- A : `inconnue` ; B : `ecartee` ; champs en désaccord : statut, valeurs
- **Référence : `inconnue`** (dependance)
- Raison : Rôles inversés avec un même objet : la jeune fille donne la pomme au jeune homme. Que le transfert d'un même objet entre les mêmes personnes au même moment soit asymétrique (B) est une entrée que la décision 9 laisse ouverte ; A n'y voit aucun appui négatif. Dépendance ; on retient inconnue.
- Dépendance d1 [inversion de rôles (K* : asymétrie) ; décision 9 (la liste des relations asymétriques reste)] : Inversion de rôles avec un même objet : « donner » (la même pomme, entre les mêmes personnes) est-elle une relation asymétrique (R(x, y) exclut R(y, x) au même moment), donc un appui négatif ? Options : asymétrie analytique → `ecartee` ; asymétrie non attestée → `inconnue`. Retenu : `inconnue`. option la plus prudente sur les deux axes : elle n'affirme ni un V ni un F que l'autre option n'affirme pas (ecartee affirmerait un F que l'autre option n'affirme pas).

### dc-022#0

- A : `inconnue` ; B : `ecartee` ; champs en désaccord : statut, valeurs
- **Référence : `inconnue`** (dependance)
- Raison : Rôles inversés avec un même objet : la jeune fille donne la pomme au jeune homme. Que le transfert d'un même objet entre les mêmes personnes au même moment soit asymétrique (B) est une entrée que la décision 9 laisse ouverte ; A n'y voit aucun appui négatif. Dépendance ; on retient inconnue.
- Dépendance d1 [inversion de rôles (K* : asymétrie) ; décision 9 (la liste des relations asymétriques reste)] : Inversion de rôles avec un même objet : « donner » (la même pomme, entre les mêmes personnes) est-elle une relation asymétrique (R(x, y) exclut R(y, x) au même moment), donc un appui négatif ? Options : asymétrie analytique → `ecartee` ; asymétrie non attestée → `inconnue`. Retenu : `inconnue`. option la plus prudente sur les deux axes : elle n'affirme ni un V ni un F que l'autre option n'affirme pas (ecartee affirmerait un F que l'autre option n'affirme pas).

### dc-022#2

- A : `inconnue` ; B : `ecartee` ; champs en désaccord : statut, valeurs
- **Référence : `inconnue`** (dependance)
- Raison : Rôles inversés avec un même objet : la jeune fille donne la pomme au jeune homme. Que le transfert d'un même objet entre les mêmes personnes au même moment soit asymétrique (B) est une entrée que la décision 9 laisse ouverte ; A n'y voit aucun appui négatif. Dépendance ; on retient inconnue.
- Dépendance d1 [inversion de rôles (K* : asymétrie) ; décision 9 (la liste des relations asymétriques reste)] : Inversion de rôles avec un même objet : « donner » (la même pomme, entre les mêmes personnes) est-elle une relation asymétrique (R(x, y) exclut R(y, x) au même moment), donc un appui négatif ? Options : asymétrie analytique → `ecartee` ; asymétrie non attestée → `inconnue`. Retenu : `inconnue`. option la plus prudente sur les deux axes : elle n'affirme ni un V ni un F que l'autre option n'affirme pas (ecartee affirmerait un F que l'autre option n'affirme pas).
- paraphrase_infidele : false — B la signale (« s'agenouille » pour « agenouillé ») : nuance d'aspect sans effet, tenue pour fidèle.

### dc-022#4

- A : `inconnue` ; B : `ecartee` ; champs en désaccord : statut, valeurs
- **Référence : `inconnue`** (dependance)
- Raison : Rôles inversés avec un même objet : la jeune fille donne la pomme au jeune homme. Que le transfert d'un même objet entre les mêmes personnes au même moment soit asymétrique (B) est une entrée que la décision 9 laisse ouverte ; A n'y voit aucun appui négatif. Dépendance ; on retient inconnue.
- Dépendance d1 [inversion de rôles (K* : asymétrie) ; décision 9 (la liste des relations asymétriques reste)] : Inversion de rôles avec un même objet : « donner » (la même pomme, entre les mêmes personnes) est-elle une relation asymétrique (R(x, y) exclut R(y, x) au même moment), donc un appui négatif ? Options : asymétrie analytique → `ecartee` ; asymétrie non attestée → `inconnue`. Retenu : `inconnue`. option la plus prudente sur les deux axes : elle n'affirme ni un V ni un F que l'autre option n'affirme pas (ecartee affirmerait un F que l'autre option n'affirme pas).

### dc-023

- A : `etablie_sous_hypotheses` ; B : `inconnue` ; champs en désaccord : statut, valeurs, natures
- **Référence : `inconnue`** (dependance)
- Raison : Deux registres, deux situations : l'ange parle à Joseph au registre supérieur ; les bergers veillent au registre inférieur. Sur la page, l'ange est au-dessus d'eux ; dans leur scène, aucun ange. Que « with an angel above them » demande une seule situation n'est pas fixé (décision 14, reste) : A le traite en convention, B en exige une. Dépendance ; on retient inconnue, la classe V ne tenant que sous une convention.
- Dépendance d1 [convention d'évaluation : situation unique ; décision 14 (reste ouverte)] : Le libellé (« shepherds watching their flocks at night, with an angel above them ») demande-t-il que ses conditions soient satisfaites dans une même situation ? Options : une seule situation demandée (convention) → `inconnue` ; l'image entière suffit (convention : hypothèse de nature convention) → `etablie_sous_hypotheses`. Retenu : `inconnue`. option la plus prudente sur les deux axes : elle n'affirme ni un V ni un F que l'autre option n'affirme pas ; la classe V ne tient que sous une convention que la sémantique n'a pas fixée.

### dc-023#0

- A : `etablie_sous_hypotheses` ; B : `inconnue` ; champs en désaccord : statut, valeurs, natures
- **Référence : `inconnue`** (dependance)
- Raison : Deux registres, deux situations : l'ange parle à Joseph au registre supérieur ; les bergers veillent au registre inférieur. Sur la page, l'ange est au-dessus d'eux ; dans leur scène, aucun ange. Que « with an angel above them » demande une seule situation n'est pas fixé (décision 14, reste) : A le traite en convention, B en exige une. Dépendance ; on retient inconnue, la classe V ne tenant que sous une convention.
- Dépendance d1 [convention d'évaluation : situation unique ; décision 14 (reste ouverte)] : Le libellé (« shepherds watching their flocks at night, with an angel above them ») demande-t-il que ses conditions soient satisfaites dans une même situation ? Options : une seule situation demandée (convention) → `inconnue` ; l'image entière suffit (convention : hypothèse de nature convention) → `etablie_sous_hypotheses`. Retenu : `inconnue`. option la plus prudente sur les deux axes : elle n'affirme ni un V ni un F que l'autre option n'affirme pas ; la classe V ne tient que sous une convention que la sémantique n'a pas fixée.

### dc-023#2

- A : `etablie_sous_hypotheses` ; B : `inconnue` ; champs en désaccord : statut, valeurs, natures
- **Référence : `inconnue`** (dependance)
- Raison : Deux registres, deux situations : l'ange parle à Joseph au registre supérieur ; les bergers veillent au registre inférieur. Sur la page, l'ange est au-dessus d'eux ; dans leur scène, aucun ange. Que « with an angel above them » demande une seule situation n'est pas fixé (décision 14, reste) : A le traite en convention, B en exige une. Dépendance ; on retient inconnue, la classe V ne tenant que sous une convention.
- Dépendance d1 [convention d'évaluation : situation unique ; décision 14 (reste ouverte)] : Le libellé (« shepherds watching their flocks at night, with an angel above them ») demande-t-il que ses conditions soient satisfaites dans une même situation ? Options : une seule situation demandée (convention) → `inconnue` ; l'image entière suffit (convention : hypothèse de nature convention) → `etablie_sous_hypotheses`. Retenu : `inconnue`. option la plus prudente sur les deux axes : elle n'affirme ni un V ni un F que l'autre option n'affirme pas ; la classe V ne tient que sous une convention que la sémantique n'a pas fixée.

### dc-023#4

- A : `etablie_sous_hypotheses` ; B : `inconnue` ; champs en désaccord : statut, valeurs, natures
- **Référence : `inconnue`** (dependance)
- Raison : Deux registres, deux situations : l'ange parle à Joseph au registre supérieur ; les bergers veillent au registre inférieur. Sur la page, l'ange est au-dessus d'eux ; dans leur scène, aucun ange. Que « with an angel above them » demande une seule situation n'est pas fixé (décision 14, reste) : A le traite en convention, B en exige une. Dépendance ; on retient inconnue, la classe V ne tenant que sous une convention.
- Dépendance d1 [convention d'évaluation : situation unique ; décision 14 (reste ouverte)] : Le libellé (« shepherds watching their flocks at night, with an angel above them ») demande-t-il que ses conditions soient satisfaites dans une même situation ? Options : une seule situation demandée (convention) → `inconnue` ; l'image entière suffit (convention : hypothèse de nature convention) → `etablie_sous_hypotheses`. Retenu : `inconnue`. option la plus prudente sur les deux axes : elle n'affirme ni un V ni un F que l'autre option n'affirme pas ; la classe V ne tient que sous une convention que la sémantique n'a pas fixée.

### dc-024#2

- A : `etablie_sous_hypotheses` ; B : `etablie` ; champs en désaccord : statut, valeurs, natures, contextes
- **Référence : `inconnue`** (adjudication)
- Satisfaction contextuelle : `principal > état d'origine` → `etablie`
- Raison : Le disque de lumière « that once encircled his head is entirely lost » ; seul son contour incisé subsiste. Dans l'œuvre actuelle, un contour incisé ne dit ni ne nie un nimbe (N, A explicite ; B ne dit rien de V pour l'œuvre actuelle). Contrairement à dc-015#4, quelque chose du nimbe reste, qui peut encore le figurer : on n'en tire pas de F. Par la précision 1.1 § 1, le statut se lit sur l'œuvre telle que la notice la décrit ; l'état d'origine est un contexte (IA § 7.3), non une convention, et va dans satisfactions_contextuelles.

### dc-024#3

- A : `etablie_sous_hypotheses` ; B : `etablie_sous_hypotheses` ; champs en désaccord : valeurs, natures, contextes
- **Référence : `inconnue`** (adjudication)
- Satisfaction contextuelle : `principal > état d'origine` → `etablie_sous_hypotheses`
- Raison : « May once have been encircled… now hard to make out » : dans l'œuvre actuelle, rien n'est affirmé (N) ; dans l'état d'origine, le nimbe n'est que possible. Par la précision 1.1 § 1, le statut se lit sur l'œuvre telle que la notice la décrit ; l'état d'origine est un contexte (IA § 7.3), non une convention, et va dans satisfactions_contextuelles.

## Désaccords de forme (statut et valeurs communs)

### dc-005

- A : `divergent` ; B : `divergent` ; champs en désaccord : natures
- **Référence : `divergent`** (accord)
- Raison : Accord de A et B (divergent) sur un point de sens de la définition : « cyclops » trait figuré (l'œil unique, réfuté par la négation dite) ou désignation du personnage de la fable (V). Profil retenu : celui de B, qui nomme l'hypothèse de la classe désignative (Polyphème est un Cyclope dans la fable) ; A n'en écrit pas, sans changer les valeurs.

### dc-005#0

- A : `divergent` ; B : `divergent` ; champs en désaccord : natures
- **Référence : `divergent`** (accord)
- Raison : Accord de A et B (divergent) sur un point de sens de la définition : « cyclops » trait figuré (l'œil unique, réfuté par la négation dite) ou désignation du personnage de la fable (V). Profil retenu : celui de B, qui nomme l'hypothèse de la classe désignative (Polyphème est un Cyclope dans la fable) ; A n'en écrit pas, sans changer les valeurs.

### dc-005#1

- A : `divergent` ; B : `divergent` ; champs en désaccord : natures
- **Référence : `divergent`** (accord)
- Raison : Accord de A et B (divergent) sur un point de sens de la définition : « cyclops » trait figuré (l'œil unique, réfuté par la négation dite) ou désignation du personnage de la fable (V). Profil retenu : celui de B, qui nomme l'hypothèse de la classe désignative (Polyphème est un Cyclope dans la fable) ; A n'en écrit pas, sans changer les valeurs.
- paraphrase_infidele : false — signalée par B pour une omission ou une nuance sans effet sur la signification jugée : tenue pour fidèle.

### dc-005#2

- A : `etablie_sous_hypotheses` ; B : `etablie_sous_hypotheses` ; champs en désaccord : natures, contextes
- **Référence : `etablie_sous_hypotheses`** (adjudication)
- Satisfaction contextuelle : `principal > état d'origine` → `etablie_sous_hypotheses`
- Raison : A et B s'accordent sur le statut. Restructuré par la précision 1.1 § 1 : sur l'œuvre actuelle, la lecture descriptive n'a ni appui ni négation (le front est abîmé : N) et la lecture désignative donne V ; l'œil unique possible de l'état d'origine est une satisfaction contextuelle, non une classe du principal. Statut inchangé.

### dc-005#3

- A : `etablie_sous_hypotheses` ; B : `etablie_sous_hypotheses` ; champs en désaccord : natures, contextes
- **Référence : `etablie_sous_hypotheses`** (adjudication)
- Satisfaction contextuelle : `principal > état d'origine` → `etablie_sous_hypotheses`
- Raison : A et B s'accordent sur le statut. « Selon Ovide » parle du géant de la fable, non de la figure (une source qui raconte, guide § 3) ; c'est l'auteur qui dit que le programme suit Ovide : l'énonciateur de la satisfaction d'origine est l'auteur, sous abduction (B), non la source citée (A). Restructuré par la précision 1.1 § 1 comme dc-005#2.

### dc-005#4

- A : `divergent` ; B : `divergent` ; champs en désaccord : natures
- **Référence : `divergent`** (accord)
- Raison : Accord de A et B (divergent) sur un point de sens de la définition : « cyclops » trait figuré (l'œil unique, réfuté par la négation dite) ou désignation du personnage de la fable (V). Profil retenu : celui de B, qui nomme l'hypothèse de la classe désignative (Polyphème est un Cyclope dans la fable) ; A n'en écrit pas, sans changer les valeurs.

### dc-005#5

- A : `divergent` ; B : `divergent` ; champs en désaccord : natures
- **Référence : `divergent`** (accord)
- Raison : Accord de A et B (divergent) sur un point de sens de la définition : « cyclops » trait figuré (l'œil unique, réfuté par la négation dite) ou désignation du personnage de la fable (V). Profil retenu : celui de B, qui nomme l'hypothèse de la classe désignative (Polyphème est un Cyclope dans la fable) ; A n'en écrit pas, sans changer les valeurs.

### dc-012#2

- A : `etablie_sous_hypotheses` ; B : `etablie_sous_hypotheses` ; champs en désaccord : natures
- **Référence : `etablie_sous_hypotheses`** (accord)
- Raison : Accord de A et B (etablie_sous_hypotheses). Profil retenu : celui de B, le plus explicite. désaccord de forme seulement (natures) : statut et valeurs communs ; natures des hypothèses : A ['abduction'], B ['identification_iconographique'].

### dc-012#3

- A : `non_certifiee` ; B : `non_certifiee` ; champs en désaccord : natures
- **Référence : `non_certifiee`** (accord)
- Raison : Accord de A et B (non_certifiee). Profil retenu : celui de A, le plus explicite. désaccord de forme seulement (natures) : statut et valeurs communs ; natures des hypothèses : A ['identification_iconographique'], B ∅.

### dc-019

- A : `etablie` ; B : `etablie` ; champs en désaccord : contextes
- **Référence : `etablie`** (adjudication)
- Raison : A et B s'accordent sur etablie ; ils ne diffèrent que par le libellé du contexte. Le portrait historié (décision 34) a deux relations, le modèle réel et le personnage figuré : Diane est figurée dans la figuration même de l'œuvre, non dans un contexte emboîté. Contexte : principal.

### dc-019#0

- A : `etablie` ; B : `etablie` ; champs en désaccord : contextes
- **Référence : `etablie`** (adjudication)
- Raison : A et B s'accordent sur etablie ; ils ne diffèrent que par le libellé du contexte. Le portrait historié (décision 34) a deux relations, le modèle réel et le personnage figuré : Diane est figurée dans la figuration même de l'œuvre, non dans un contexte emboîté. Contexte : principal.

### dc-019#1

- A : `etablie` ; B : `etablie` ; champs en désaccord : contextes
- **Référence : `etablie`** (adjudication)
- Raison : A et B s'accordent sur etablie ; ils ne diffèrent que par le libellé du contexte. Le portrait historié (décision 34) a deux relations, le modèle réel et le personnage figuré : Diane est figurée dans la figuration même de l'œuvre, non dans un contexte emboîté. Contexte : principal.

### dc-019#5

- A : `etablie` ; B : `etablie` ; champs en désaccord : contextes
- **Référence : `etablie`** (adjudication)
- Raison : A et B s'accordent sur etablie ; ils ne diffèrent que par le libellé du contexte. Le portrait historié (décision 34) a deux relations, le modèle réel et le personnage figuré : Diane est figurée dans la figuration même de l'œuvre, non dans un contexte emboîté. Contexte : principal.

## Accords repris (précisions 1.1, dépendances signalées, fidélité)

### dc-001#0

- A : `etablie` ; B : `etablie`
- **Référence : `etablie`** (accord)
- Raison : Accord de A et B (etablie). Profil retenu : celui de A, le plus explicite.
- paraphrase_infidele : false — signalée par B pour une omission ou une nuance sans effet sur la signification jugée : tenue pour fidèle.

### dc-003

- A : `etablie` ; B : `etablie`
- **Référence : `inconnue`** (accord)
- Satisfaction contextuelle : `principal > vision de la religieuse` → `etablie`
- Raison : Accord de A et B : l'ange tenant le vase du vin de la messe (un calice, par la signification) n'est que dans la vision de la religieuse, et la définition ne nomme aucun contexte. Par la précision 1.1 § 1, le statut se lit sur le contexte principal (N) ; la satisfaction dans la vision va dans satisfactions_contextuelles.

### dc-003#0

- A : `etablie` ; B : `etablie`
- **Référence : `inconnue`** (accord)
- Satisfaction contextuelle : `principal > vision de la religieuse` → `etablie`
- Raison : Accord de A et B : l'ange tenant le vase du vin de la messe (un calice, par la signification) n'est que dans la vision de la religieuse, et la définition ne nomme aucun contexte. Par la précision 1.1 § 1, le statut se lit sur le contexte principal (N) ; la satisfaction dans la vision va dans satisfactions_contextuelles.

### dc-003#2

- A : `etablie` ; B : `etablie`
- **Référence : `inconnue`** (accord)
- Satisfaction contextuelle : `principal > vision de la religieuse` → `etablie`
- Raison : Accord de A et B : l'ange tenant le vase du vin de la messe (un calice, par la signification) n'est que dans la vision de la religieuse, et la définition ne nomme aucun contexte. Par la précision 1.1 § 1, le statut se lit sur le contexte principal (N) ; la satisfaction dans la vision va dans satisfactions_contextuelles.

### dc-003#3

- A : `etablie` ; B : `etablie`
- **Référence : `inconnue`** (accord)
- Satisfaction contextuelle : `principal > vision de la religieuse` → `etablie`
- Raison : Accord de A et B : l'ange tenant le vase du vin de la messe (un calice, par la signification) n'est que dans la vision de la religieuse, et la définition ne nomme aucun contexte. Par la précision 1.1 § 1, le statut se lit sur le contexte principal (N) ; la satisfaction dans la vision va dans satisfactions_contextuelles.

### dc-006#1

- A : `ecartee` ; B : `ecartee`
- **Référence : `ecartee`** (accord)
- Raison : Accord de A et B (ecartee). Profil retenu : celui de A, le plus explicite.
- paraphrase_infidele : false — signalée par B pour une omission ou une nuance sans effet sur la signification jugée : tenue pour fidèle.

### dc-010

- A : `etablie_sous_hypotheses` ; B : `etablie_sous_hypotheses`
- **Référence : `etablie_sous_hypotheses`** (accord)
- Raison : Accord de A et B : crâne et sablier sont dits ; l'allusion à la fugacité de la vie, non dite, repose sur la connaissance typique de la vanité. Dépendance signalée (même thème que nr-023 : un symbole non dit), non appliquée à un accord.
- Dépendance d1 [symbole non dit (connaissance typique) ; guide § 1 ; décision 24 (non fixé)] (signalée, non appliquée) : Une signification symbolique que l'auteur ne dit pas (le crâne et le sablier comme allusion à la fugacité de la vie) peut-elle être apportée comme hypothèse de connaissance typique, sans observation qu'elle explique ? Options : admise comme connaissance typique → `etablie_sous_hypotheses` ; non admise : le symbole doit être dit → `inconnue`. Retenu : `etablie_sous_hypotheses`. Dépendance signalée, non appliquée : A et B s'accordent, et la référence d'un accord est leur jugement commun (consigne, étape 1).

### dc-010#0

- A : `etablie_sous_hypotheses` ; B : `etablie_sous_hypotheses`
- **Référence : `etablie_sous_hypotheses`** (accord)
- Raison : Accord de A et B : crâne et sablier sont dits ; l'allusion à la fugacité de la vie, non dite, repose sur la connaissance typique de la vanité. Dépendance signalée (même thème que nr-023 : un symbole non dit), non appliquée à un accord.
- Dépendance d1 [symbole non dit (connaissance typique) ; guide § 1 ; décision 24 (non fixé)] (signalée, non appliquée) : Une signification symbolique que l'auteur ne dit pas (le crâne et le sablier comme allusion à la fugacité de la vie) peut-elle être apportée comme hypothèse de connaissance typique, sans observation qu'elle explique ? Options : admise comme connaissance typique → `etablie_sous_hypotheses` ; non admise : le symbole doit être dit → `inconnue`. Retenu : `etablie_sous_hypotheses`. Dépendance signalée, non appliquée : A et B s'accordent, et la référence d'un accord est leur jugement commun (consigne, étape 1).

### dc-010#1

- A : `etablie_sous_hypotheses` ; B : `etablie_sous_hypotheses`
- **Référence : `etablie_sous_hypotheses`** (accord)
- Raison : Accord de A et B : crâne et sablier sont dits ; l'allusion à la fugacité de la vie, non dite, repose sur la connaissance typique de la vanité. Dépendance signalée (même thème que nr-023 : un symbole non dit), non appliquée à un accord.
- Dépendance d1 [symbole non dit (connaissance typique) ; guide § 1 ; décision 24 (non fixé)] (signalée, non appliquée) : Une signification symbolique que l'auteur ne dit pas (le crâne et le sablier comme allusion à la fugacité de la vie) peut-elle être apportée comme hypothèse de connaissance typique, sans observation qu'elle explique ? Options : admise comme connaissance typique → `etablie_sous_hypotheses` ; non admise : le symbole doit être dit → `inconnue`. Retenu : `etablie_sous_hypotheses`. Dépendance signalée, non appliquée : A et B s'accordent, et la référence d'un accord est leur jugement commun (consigne, étape 1).

### dc-010#4

- A : `etablie_sous_hypotheses` ; B : `etablie_sous_hypotheses`
- **Référence : `etablie_sous_hypotheses`** (accord)
- Raison : Accord de A et B : crâne et sablier sont dits ; l'allusion à la fugacité de la vie, non dite, repose sur la connaissance typique de la vanité. Dépendance signalée (même thème que nr-023 : un symbole non dit), non appliquée à un accord.
- Dépendance d1 [symbole non dit (connaissance typique) ; guide § 1 ; décision 24 (non fixé)] (signalée, non appliquée) : Une signification symbolique que l'auteur ne dit pas (le crâne et le sablier comme allusion à la fugacité de la vie) peut-elle être apportée comme hypothèse de connaissance typique, sans observation qu'elle explique ? Options : admise comme connaissance typique → `etablie_sous_hypotheses` ; non admise : le symbole doit être dit → `inconnue`. Retenu : `etablie_sous_hypotheses`. Dépendance signalée, non appliquée : A et B s'accordent, et la référence d'un accord est leur jugement commun (consigne, étape 1).

### dc-010#5

- A : `etablie_sous_hypotheses` ; B : `etablie_sous_hypotheses`
- **Référence : `etablie_sous_hypotheses`** (accord)
- Raison : Accord de A et B : crâne et sablier sont dits ; l'allusion à la fugacité de la vie, non dite, repose sur la connaissance typique de la vanité. Dépendance signalée (même thème que nr-023 : un symbole non dit), non appliquée à un accord.
- Dépendance d1 [symbole non dit (connaissance typique) ; guide § 1 ; décision 24 (non fixé)] (signalée, non appliquée) : Une signification symbolique que l'auteur ne dit pas (le crâne et le sablier comme allusion à la fugacité de la vie) peut-elle être apportée comme hypothèse de connaissance typique, sans observation qu'elle explique ? Options : admise comme connaissance typique → `etablie_sous_hypotheses` ; non admise : le symbole doit être dit → `inconnue`. Retenu : `etablie_sous_hypotheses`. Dépendance signalée, non appliquée : A et B s'accordent, et la référence d'un accord est leur jugement commun (consigne, étape 1).

### dc-013#1

- A : `etablie_sous_hypotheses` ; B : `etablie_sous_hypotheses`
- **Référence : `etablie_sous_hypotheses`** (accord)
- Raison : Accord de A et B (etablie_sous_hypotheses). Profil retenu : celui de A, le plus explicite.
- paraphrase_infidele : false — signalée par B pour une omission ou une nuance sans effet sur la signification jugée : tenue pour fidèle.

### dc-014#5

- A : `divergent` ; B : `divergent`
- **Référence : `divergent`** (accord)
- Raison : Accord de A et B (divergent). Profil retenu : celui de A, le plus explicite.
- paraphrase_infidele : false — signalée par B pour une omission ou une nuance sans effet sur la signification jugée : tenue pour fidèle.

### dc-017#1

- A : `etablie` ; B : `etablie`
- **Référence : `etablie`** (accord)
- Raison : Accord de A et B (etablie). Profil retenu : celui de A, le plus explicite.
- paraphrase_infidele : false — signalée par B pour une omission ou une nuance sans effet sur la signification jugée : tenue pour fidèle.

### dc-021#5

- A : `etablie` ; B : `etablie`
- **Référence : `inconnue`** (accord)
- Satisfaction contextuelle : `principal > estampe épinglée au mur` → `etablie`
- Raison : Accord de A et B : la jeune femme au crâne dans son giron n'est que dans l'estampe figurée au mur ; la définition ne nomme aucun contexte. Par la précision 1.1 § 1, le statut se lit sur le principal, où la femme prie sans crâne mentionné (N).

### dc-024#1

- A : `etablie` ; B : `etablie`
- **Référence : `etablie`** (accord)
- Raison : Accord de A et B (etablie). Profil retenu : celui de A, le plus explicite.
- paraphrase_infidele : false — signalée par B pour une omission ou une nuance sans effet sur la signification jugée : tenue pour fidèle.

