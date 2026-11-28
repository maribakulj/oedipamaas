# Adjudication : Espace, partie et temps (`espace_partie_temps`)

> **Précision de la session principale (28/11) :** le compte « une seule justification identique sur 72 » porte sur les seuls cas de base, et sur les trois familles du groupe ensemble. Sur les cas et les variantes, l'adjudicateur en compte 9 sur 503 (3 par famille), toutes de courtes citations du texte suivies de « V ».


> Pour ce groupe, les deux annotateurs ont utilisé le même dossier de brouillon, et l'indépendance de B par rapport à A n'est pas garantie (aucun signe de copie : accord comparable au groupe 1, une seule justification identique sur 72).

## Bilan

- éléments : 171 (cas et variantes) ; accord de statut 0.924, kappa 0.904 (comparaison) ;
- désaccords de statut ou de valeurs : 15 ; tranchés : 3 ; dépendances : 12 ;
- différences de points ou d'hypothèses seulement (accords, notés) : 20 ;
- accords dont le statut de référence change par les précisions 1.1 : 0 (aucun).

**La règle de prudence des dépendances.** Pour chaque dépendance, le statut retenu est celui de l'option la plus prudente sur les deux axes : il n'affirme ni un V ni un F que l'autre option n'affirme pas. Quand aucune option ne l'est sur les deux axes (l'une affirme un V, l'autre un F), je retiens leur partie commune, classe par classe : la valeur que les deux options affirment, N sinon ; le statut se lit sur ce profil, et je le dis à chaque fois.

**La convention de l'imminence (précision 1.1.2).** Partout où une classe imminente est F, elle l'est par l'exclusivité des ancrages (décision 26, IA § 6.2), règle que les deux annotateurs appliquent. La convention « l'imminent compte comme en cours » (guide § 3), non tranchée, n'est pas une valeur de point ; sous elle, la classe serait V avec une hypothèse de nature `convention`. Les statuts sont écrits sans elle ; la note figure dans la raison de chaque élément concerné.

## 1. Les désaccords

### ep-003#3

- **A :** `non_certifiee` (F/N/V). Selon le catalogue cité, la roue appartenait à une charrette que le graveur a ensuite effacée : dans l'état actuel, pas de charrette (valeur citée) ; dans l'état antérieur, une charrette (citée). L'auteur, lui, ne dit qu'une roue.
- **B :** `non_certifiee` (F). Selon le catalogue cité, la charrette a été effacée de la planche : elle ne figure donc plus. Négation venue du seul énonciateur cité.
- **Décision :** `non_certifiee` — profil : {} → N ; {} → F (cite)
- **Raison :** Le statut est commun (non_certifiee) ; A écrit aussi l'état antérieur et la valeur de l'auteur. Précision 1.1.1 : l'état antérieur de la planche est un autre contexte ; il va dans satisfactions_contextuelles et ne fait pas le statut. Dans le contexte principal, l'auteur ne dit qu'une roue (N) ; seul le catalogue cité dit l'absence de charrette (F) : non_certifiee, la polarité gardée dans le profil (doute de A). Le doute de B (l'histoire de la planche comme contexte non figuratif) ne vaut pas ici : le catalogue décrit les états de l'image.
- **Satisfaction contextuelle :** principal > état antérieur de la planche → `non_certifiee` (V, cite) — la charrette, effacée depuis, n'est dite que par le catalogue cité

### ep-006

- **A :** `ecartee_sous_hypotheses` (F/N). « la couronne » : l'article défini dit une couronne unique dans la scène, ou seulement la couronne saillante. Unique : elle repose sur la tête, elle n'est donc pas tenue au-dessus par des anges, et les anges soulèvent le manteau : F. Saillante : une autre couronne n'est pas exclue, mais rien ne la dit : N.
- **B :** `inconnue` (N). La couronne repose déjà sur la tête ; les anges soulèvent le manteau. Qu'ils tiennent une couronne au-dessus de sa tête n'est pas dit ; ce n'est pas exclu pour une autre couronne : N.
- **Dépendance :** `inconnue` — profil : {"p1": "unique_dans_la_scene"} → N ; {"p1": "saillante_seulement"} → N
- **Raison :** La couronne citée repose sur la tête, et les anges soulèvent le manteau : A et B s'accordent sur les faits. Le F de A ne tient que par l'unicité du défini.
- **d1 — unicité de l'article défini.** « la couronne repose déjà sur sa tête » : le défini dit-il une couronne unique dans la scène (alors aucune couronne n'est tenue au-dessus de la tête : F), ou seulement la couronne saillante, une autre n'étant ni dite ni exclue (N) ?
  - option : point admis : F si unique, N sinon (A) → `ecartee_sous_hypotheses`
  - option : pas de point : une couronne non citée n'est pas exclue (B) → `inconnue`
  - retenu : `inconnue`. Statut de référence : celui de l'option la plus prudente sur les deux axes (elle n'affirme ni un V ni un F que l'autre option n'affirme pas).

### ep-006#0

- **A :** `ecartee_sous_hypotheses` (F/N). Reformulation : même défini, même profil.
- **B :** `inconnue` (N). Paraphrase fidèle : même jugement que le cas.
- **Dépendance :** `inconnue` — profil : {"p1": "unique_dans_la_scene"} → N ; {"p1": "saillante_seulement"} → N
- **Raison :** La couronne citée repose sur la tête, et les anges soulèvent le manteau : A et B s'accordent sur les faits. Le F de A ne tient que par l'unicité du défini.
- **d1 — unicité de l'article défini.** « la couronne repose déjà sur sa tête » : le défini dit-il une couronne unique dans la scène (alors aucune couronne n'est tenue au-dessus de la tête : F), ou seulement la couronne saillante, une autre n'étant ni dite ni exclue (N) ?
  - option : point admis : F si unique, N sinon (A) → `ecartee_sous_hypotheses`
  - option : pas de point : une couronne non citée n'est pas exclue (B) → `inconnue`
  - retenu : `inconnue`. Statut de référence : celui de l'option la plus prudente sur les deux axes (elle n'affirme ni un V ni un F que l'autre option n'affirme pas).

### ep-006#1

- **A :** `ecartee_sous_hypotheses` (F/N). Traduction fidèle : « the crown already rests on her head ».
- **B :** `inconnue` (N). Traduction fidèle : même jugement que le cas.
- **Dépendance :** `inconnue` — profil : {"p1": "unique_dans_la_scene"} → N ; {"p1": "saillante_seulement"} → N
- **Raison :** La couronne citée repose sur la tête, et les anges soulèvent le manteau : A et B s'accordent sur les faits. Le F de A ne tient que par l'unicité du défini.
- **d1 — unicité de l'article défini.** « la couronne repose déjà sur sa tête » : le défini dit-il une couronne unique dans la scène (alors aucune couronne n'est tenue au-dessus de la tête : F), ou seulement la couronne saillante, une autre n'étant ni dite ni exclue (N) ?
  - option : point admis : F si unique, N sinon (A) → `ecartee_sous_hypotheses`
  - option : pas de point : une couronne non citée n'est pas exclue (B) → `inconnue`
  - retenu : `inconnue`. Statut de référence : celui de l'option la plus prudente sur les deux axes (elle n'affirme ni un V ni un F que l'autre option n'affirme pas).

### ep-006#3

- **A :** `ecartee_sous_hypotheses` (F/N). « aucun ange ne la tient » nie que des anges tiennent la couronne posée ; il ne dit rien d'une autre couronne. Même profil que le cas, appuyé en plus par la négation dans la lecture unique.
- **B :** `ecartee` (F). « aucun ange ne la tient » et la couronne citée repose sur la tête : la seule couronne citée n'est pas tenue par des anges au-dessus de la tête. F pour les référents cités.
- **Dépendance :** `ecartee_sous_hypotheses` — profil : {"p1": "unique_dans_la_scene"} → F ; {"p1": "saillante_seulement"} → N
- **Raison :** Négation dite de la couronne citée. B, qui juge le cas N faute d'exclure une autre couronne, juge ici F pour les référents cités : la question de principe est celle de mn-009.
- **d1 — unicité de l'article défini ; réfutation pour les référents cités.** « la couronne repose déjà sur sa tête, et aucun ange ne la tient » : la négation porte sur « la » couronne. Réfute-t-elle la définition existentielle seulement si cette couronne est la seule (A), ou dès qu'elle est réfutée pour les référents cités (B, IA § 2.5 : `ecartee` affirme la réfutation « pour les référents cités ») ?
  - option : F seulement sous l'unicité du défini (A) → `ecartee_sous_hypotheses`
  - option : F pour les référents cités, sans point (B) → `ecartee`
  - retenu : `ecartee_sous_hypotheses`. Statut de référence : celui de l'option la plus prudente sur les deux axes (elle n'affirme ni un V ni un F que l'autre option n'affirme pas). F dans la lecture « unique » (les deux l'affirment), N dans la lecture « saillante » (seul B y affirme F).

### ep-006#4

- **A :** `ecartee_sous_hypotheses` (F/N). C'est sainte Catherine qui trône et porte la couronne ; la Vierge n'est pas dite. Couronne unique : elle est sur la tête de Catherine, non tenue au-dessus de la Vierge : F ; sinon N.
- **B :** `inconnue` (N). Sainte Catherine trône, non la Vierge ; et aucune couronne n'est tenue : N.
- **Dépendance :** `inconnue` — profil : {"p1": "unique_dans_la_scene"} → N ; {"p1": "saillante_seulement"} → N
- **Raison :** La couronne citée repose sur la tête, et les anges soulèvent le manteau : A et B s'accordent sur les faits. Le F de A ne tient que par l'unicité du défini. Sainte Catherine trône : la Vierge n'est pas dite ; même dépendance pour le F de A.
- **d1 — unicité de l'article défini.** « la couronne repose déjà sur sa tête » : le défini dit-il une couronne unique dans la scène (alors aucune couronne n'est tenue au-dessus de la tête : F), ou seulement la couronne saillante, une autre n'étant ni dite ni exclue (N) ?
  - option : point admis : F si unique, N sinon (A) → `ecartee_sous_hypotheses`
  - option : pas de point : une couronne non citée n'est pas exclue (B) → `inconnue`
  - retenu : `inconnue`. Statut de référence : celui de l'option la plus prudente sur les deux axes (elle n'affirme ni un V ni un F que l'autre option n'affirme pas).

### ep-006#5

- **A :** `ecartee_sous_hypotheses` (F/N). Le donateur est sans effet.
- **B :** `inconnue` (N). Ajout d'un élément sans rapport avec la définition : même jugement que le cas.
- **Dépendance :** `inconnue` — profil : {"p1": "unique_dans_la_scene"} → N ; {"p1": "saillante_seulement"} → N
- **Raison :** La couronne citée repose sur la tête, et les anges soulèvent le manteau : A et B s'accordent sur les faits. Le F de A ne tient que par l'unicité du défini.
- **d1 — unicité de l'article défini.** « la couronne repose déjà sur sa tête » : le défini dit-il une couronne unique dans la scène (alors aucune couronne n'est tenue au-dessus de la tête : F), ou seulement la couronne saillante, une autre n'étant ni dite ni exclue (N) ?
  - option : point admis : F si unique, N sinon (A) → `ecartee_sous_hypotheses`
  - option : pas de point : une couronne non citée n'est pas exclue (B) → `inconnue`
  - retenu : `inconnue`. Statut de référence : celui de l'option la plus prudente sur les deux axes (elle n'affirme ni un V ni un F que l'autre option n'affirme pas).

### ep-010#6

- **A :** `ecartee` (F/V). L'avant-bras gauche manque : dans l'œuvre telle qu'elle est, pas de main gauche, donc pas de livre tenu de cette main : F. Le guide cité décrit le livre, dans l'état d'origine.
- **B :** `ecartee` (F). L'auteur dit l'avant-bras gauche aujourd'hui perdu : sans main gauche, il ne tient rien de la gauche dans l'œuvre actuelle. F. Le guide cité décrit un état antérieur.
- **Décision :** `ecartee` — profil : {} → F
- **Raison :** Le statut est commun (ecartee). L'auteur dit l'avant-bras gauche perdu : dans l'œuvre telle que la notice la décrit, rien n'est tenu de la main gauche (incompatibilité analytique). Précision 1.1.1 : l'état d'origine, que A met dans le profil, va dans satisfactions_contextuelles. Le doute de A (le F tiendrait à une convention, § 7.3) est levé par la même précision : le statut se lit sur le contexte principal ; ce n'est pas une hypothèse de nature convention.
- **Satisfaction contextuelle :** principal > état d'origine → `non_certifiee` (V, cite) — le guide cité décrit le livre tenu de la main gauche, avant la perte de l'avant-bras

### ep-015#2

- **A :** `divergent` (F/V). « avec sa propre épée » : le possesseur peut être le sujet, David, ou « lui », Goliath. David : l'épée est à David, non celle de Goliath : F ; Goliath : V.
- **B :** `etablie_sous_hypotheses` (N/V). « sa propre épée » : celle du sujet, David, ou celle de Goliath (« lui »). Goliath : V. David : l'épée de David n'est pas dite celle de Goliath ; ce n'est pas exclu (épée prise) : N.
- **Dépendance :** `etablie_sous_hypotheses` — profil : {"p1": "Goliath"} → V ; {"p1": "David"} → N
- **Raison :** A et B ont le même point de coréférence ; ils divergent sur la valeur de la lecture David.
- **d1 — incompatibilité de possession (un contraire lexical fonde-t-il un F ?).** Dans la lecture David, l'épée est « sa propre épée ». Cela exclut-il analytiquement qu'elle soit « Goliath's own sword », ou n'est-ce qu'une opposition (une épée prise change de main) ?
  - option : exclusion analytique : F dans la lecture David (A) → `divergent`
  - option : pas d'exclusion attestée : N dans la lecture David (B) → `etablie_sous_hypotheses`
  - retenu : `etablie_sous_hypotheses`. Statut de référence : celui de l'option la plus prudente sur les deux axes (elle n'affirme ni un V ni un F que l'autre option n'affirme pas). Le V de la lecture Goliath est affirmé par les deux.

### ep-016

- **A :** `etablie_sous_hypotheses` (V). La paysanne se penche pour baiser l'anneau de l'évêque. L'anneau n'est pas la main ; le baisement de l'anneau vaut d'ordinaire baisement de la main : V sous cette connaissance typique.
- **B :** `divergent` (F/V). « bends to kiss » : elle baise l'anneau en se penchant (en cours) ou se penche pour le baiser (imminent : F, décision 26). En cours, il faut encore que baiser l'anneau soit baiser la main : V sous hypothèse.
- **Dépendance :** `etablie_sous_hypotheses` — profil : {"p1": "en_cours"} → V [connaissance_typique : baiser l'anneau de l'évêque, porté au doigt, c'est lui baiser la main] ; {"p1": "imminent"} → N
- **Raison :** A et B s'accordent sur l'hypothèse de l'anneau (connaissance typique).
- **d1 — ancrage du but (« bends to kiss », « s'incline pour baiser » ; frontière lexicale de la décision 26).** La construction de but figure-t-elle le baiser en cours, le geste en étant la phase préparatoire (ONT § 1.2), sans point (A), ou laisse-t-elle ouverte une lecture imminente, appui négatif du baiser en cours (B) ?
  - option : pas de point (A) → `etablie_sous_hypotheses`
  - option : point admis : en cours V, imminent F (B) → `divergent`
  - retenu : `etablie_sous_hypotheses`. Aucune des deux options n'est la plus prudente sur les deux axes (l'une affirme un V ou un F que l'autre n'affirme pas) : je retiens leur partie commune, classe par classe (la valeur que les deux options affirment, N sinon), et le statut qui s'en lit. V sous l'hypothèse de l'anneau dans la lecture en cours (les deux l'affirment) ; N dans la lecture imminente (seul B y affirme F). Le statut est celui de A.

### ep-016#1

- **A :** `etablie_sous_hypotheses` (V). Traduction fidèle : « s'incline pour baiser l'anneau ».
- **B :** `divergent` (F/V). Traduction fidèle : même jugement que le cas.
- **Dépendance :** `etablie_sous_hypotheses` — profil : {"p1": "en_cours"} → V [connaissance_typique : baiser l'anneau de l'évêque, porté au doigt, c'est lui baiser la main] ; {"p1": "imminent"} → N
- **Raison :** A et B s'accordent sur l'hypothèse de l'anneau (connaissance typique). Traduction fidèle (« s'incline pour baiser »).
- **d1 — ancrage du but (« bends to kiss », « s'incline pour baiser » ; frontière lexicale de la décision 26).** La construction de but figure-t-elle le baiser en cours, le geste en étant la phase préparatoire (ONT § 1.2), sans point (A), ou laisse-t-elle ouverte une lecture imminente, appui négatif du baiser en cours (B) ?
  - option : pas de point (A) → `etablie_sous_hypotheses`
  - option : point admis : en cours V, imminent F (B) → `divergent`
  - retenu : `etablie_sous_hypotheses`. Aucune des deux options n'est la plus prudente sur les deux axes (l'une affirme un V ou un F que l'autre n'affirme pas) : je retiens leur partie commune, classe par classe (la valeur que les deux options affirment, N sinon), et le statut qui s'en lit. V sous l'hypothèse de l'anneau dans la lecture en cours (les deux l'affirment) ; N dans la lecture imminente (seul B y affirme F). Le statut est celui de A.

### ep-016#2

- **A :** `etablie` (V). « bends to kiss the hand of the old bishop » : V.
- **B :** `divergent` (F/V). La main est dite ; reste l'ancrage : V ou F.
- **Dépendance :** `etablie_sous_hypotheses` — profil : {"p1": "en_cours"} → V ; {"p1": "imminent"} → N
- **Raison :** La main est dite ; reste l'ancrage du but.
- **d1 — ancrage du but (« bends to kiss », « s'incline pour baiser » ; frontière lexicale de la décision 26).** La construction de but figure-t-elle le baiser en cours, le geste en étant la phase préparatoire (ONT § 1.2), sans point (A), ou laisse-t-elle ouverte une lecture imminente, appui négatif du baiser en cours (B) ?
  - option : pas de point (A) → `etablie`
  - option : point admis : en cours V, imminent F (B) → `divergent`
  - retenu : `etablie_sous_hypotheses`. Aucune des deux options n'est la plus prudente sur les deux axes (l'une affirme un V ou un F que l'autre n'affirme pas) : je retiens leur partie commune, classe par classe (la valeur que les deux options affirment, N sinon), et le statut qui s'en lit. V dans la lecture en cours (les deux l'affirment, sans hypothèse) ; N dans la lecture imminente. V n'étant affirmé que dans une lecture, etablie_sous_hypotheses.

### ep-016#5

- **A :** `etablie_sous_hypotheses` (V). La négation porte sur le fichu.
- **B :** `divergent` (F/V). « The woman wears no headscarf » : sans rapport. Même jugement.
- **Dépendance :** `etablie_sous_hypotheses` — profil : {"p1": "en_cours"} → V [connaissance_typique : baiser l'anneau de l'évêque, porté au doigt, c'est lui baiser la main] ; {"p1": "imminent"} → N
- **Raison :** A et B s'accordent sur l'hypothèse de l'anneau (connaissance typique). La négation porte sur le fichu, sans effet.
- **d1 — ancrage du but (« bends to kiss », « s'incline pour baiser » ; frontière lexicale de la décision 26).** La construction de but figure-t-elle le baiser en cours, le geste en étant la phase préparatoire (ONT § 1.2), sans point (A), ou laisse-t-elle ouverte une lecture imminente, appui négatif du baiser en cours (B) ?
  - option : pas de point (A) → `etablie_sous_hypotheses`
  - option : point admis : en cours V, imminent F (B) → `divergent`
  - retenu : `etablie_sous_hypotheses`. Aucune des deux options n'est la plus prudente sur les deux axes (l'une affirme un V ou un F que l'autre n'affirme pas) : je retiens leur partie commune, classe par classe (la valeur que les deux options affirment, N sinon), et le statut qui s'en lit. V sous l'hypothèse de l'anneau dans la lecture en cours (les deux l'affirment) ; N dans la lecture imminente (seul B y affirme F). Le statut est celui de A.

### ep-023#5

- **A :** `ecartee` (F). Pierre a déjà quitté la cour en pleurant : le reniement est antérieur, appui négatif du reniement en cours.
- **B :** `inconnue` (N). Le coq chante, mais Pierre a quitté la cour en pleurant ; son reniement n'est pas dit, ni exclu par un ancrage dit : N.
- **Décision :** `inconnue` — profil : {} → N
- **Raison :** Je suis B. Le reniement n'est pas dit ; son antériorité vient du récit (Pierre pleure après avoir renié), non d'un ancrage dit par l'auteur. Avoir quitté la cour n'exclut pas analytiquement de renier. Un appui négatif ne vient ni d'une implication non attestée ni du silence (guide § 3 ; IA § 6.3, décision 10).

### ep-024#2

- **A :** `ecartee_sous_hypotheses` (F). Le moment figuré est l'essuyage ; le lavement n'est qu'antérieur et possible. S'il a eu lieu, son ancrage antérieur est un appui négatif du lavement en cours : F sous l'hypothèse ; sinon rien.
- **B :** `etablie_sous_hypotheses` (N/V). L'essuyage est en cours ; le lavement est peut-être antérieur. Lavement figuré en cours : non dit, N. Succession : sous l'hypothèse, le lavement précède l'essuyage : V.
- **Dépendance :** `inconnue` — profil : {"d1": "lavement_figure"} → N ; {"d1": "succession_figuree"} → N
- **Raison :** L'essuyage est en cours ; le lavement n'est que possible et antérieur. A et B admettent ailleurs (ep-017#4) un point analogue sur « before gutting it » ; la lecture « succession » de B demanderait pourtant le lavement figuré, ce que le texte ne dit pas même sous l'hypothèse.
- **d1 — forme du libellé (« X-ing before Y-ing ») ; antériorité modalisée comme appui négatif.** La définition demande-t-elle le lavement figuré en cours, ou la succession lavement-essuyage ? Et un lavement « perhaps » antérieur fonde-t-il, sous l'hypothèse qu'il a eu lieu, un appui négatif du lavement en cours (décision 26) ?
  - option : pas de point ; lavement en cours demandé ; F sous l'abduction du lavement antérieur (A) → `ecartee_sous_hypotheses`
  - option : point admis ; lavement figuré : N ; succession : V sous l'abduction (B) → `etablie_sous_hypotheses`
  - retenu : `inconnue`. Aucune des deux options n'est la plus prudente sur les deux axes (l'une affirme un V ou un F que l'autre n'affirme pas) : je retiens leur partie commune, classe par classe (la valeur que les deux options affirment, N sinon), et le statut qui s'en lit. Lecture « lavement figuré » : A y affirme F, B N ; lecture « succession » : B y affirme V, A ne l'admet pas. Aucune valeur n'est commune : N partout.

## 2. Accords dont les points ou les hypothèses diffèrent

Le statut et les valeurs sont communs ; la référence prend le profil le plus explicite et note la différence.

- **ep-002#3** (`etablie_sous_hypotheses`) : Profil retenu : A. Les hypothèses diffèrent de nature sans changer les valeurs : A ['abduction'] ; B ['connaissance_typique'].
- **ep-008#2** (`ecartee`) : Profil retenu : B (le plus explicite). Les points diffèrent sans changer les valeurs : A aucun ; B ['sens (définition) « kneeling before the risen Christ »'].
- **ep-008#3** (`ecartee`) : Profil retenu : B (le plus explicite). Les points diffèrent sans changer les valeurs : A aucun ; B ['sens (définition) « kneeling before the risen Christ »'].
- **ep-014** (`etablie_sous_hypotheses`) : Profil retenu : A. Les points diffèrent sans changer les valeurs : A ['forme_du_libelle « God the Father blessing ... from the clouds »'] ; B ['sens (définition) « God the Father blessing »']. Les hypothèses diffèrent de nature sans changer les valeurs : A ['identification_iconographique'] ; B ['connaissance_typique'].
- **ep-014#0** (`etablie_sous_hypotheses`) : Profil retenu : A. Les points diffèrent sans changer les valeurs : A ['forme_du_libelle « God the Father blessing ... from the clouds »'] ; B ['sens (définition) « God the Father blessing »']. Les hypothèses diffèrent de nature sans changer les valeurs : A ['identification_iconographique'] ; B ['connaissance_typique'].
- **ep-014#1** (`etablie_sous_hypotheses`) : Profil retenu : A. Les points diffèrent sans changer les valeurs : A ['forme_du_libelle « God the Father blessing ... from the clouds »'] ; B ['sens (définition) « God the Father blessing »']. Les hypothèses diffèrent de nature sans changer les valeurs : A ['identification_iconographique'] ; B ['connaissance_typique'].
- **ep-014#2** (`divergent`) : Profil retenu : A. Les points diffèrent sans changer les valeurs : A ['forme_du_libelle « God the Father blessing ... from the clouds »'] ; B ['sens (définition) « God the Father blessing »']. Les hypothèses diffèrent de nature sans changer les valeurs : A ['identification_iconographique'] ; B ['connaissance_typique'].
- **ep-014#3** (`etablie`) : Profil retenu : B (le plus explicite). Les points diffèrent sans changer les valeurs : A aucun ; B ['sens (définition) « God the Father blessing »'].
- **ep-014#4** (`etablie_sous_hypotheses`) : Profil retenu : A. Les points diffèrent sans changer les valeurs : A ['forme_du_libelle « God the Father blessing ... from the clouds »'] ; B ['sens (définition) « God the Father blessing »']. Les hypothèses diffèrent de nature sans changer les valeurs : A ['identification_iconographique'] ; B ['connaissance_typique'].
- **ep-014#5** (`ecartee`) : Profil retenu : B (le plus explicite). Les points diffèrent sans changer les valeurs : A aucun ; B ['sens (définition) « God the Father blessing »'].
- **ep-014#6** (`non_certifiee`) : Profil retenu : B (le plus explicite). Les points diffèrent sans changer les valeurs : A aucun ; B ['sens (définition) « God the Father blessing »']. Les hypothèses diffèrent de nature sans changer les valeurs : A aucune ; B ['connaissance_typique'].
- **ep-017#2** (`ecartee`) : Profil retenu : B (le plus explicite). Les points diffèrent sans changer les valeurs : A aucun ; B ['forme_du_libelle (définition) « seizing the fish before gutting it »'].
- **ep-018#2** (`etablie`) : Profil retenu : B (le plus explicite). Les points diffèrent sans changer les valeurs : A aucun ; B ['forme_du_libelle (définition) « offering their sacrifices before Cain slays Abel »'].
- **ep-019#2** (`etablie_sous_hypotheses`) : Profil retenu : A. Les hypothèses diffèrent de nature sans changer les valeurs : A ['identification_iconographique'] ; B ['abduction'].
- **ep-024** (`ecartee`) : Profil retenu : B (le plus explicite). Les points diffèrent sans changer les valeurs : A aucun ; B ['forme_du_libelle (définition) « washing [...] with her tears before drying them with her hair »'].
- **ep-024#0** (`ecartee`) : Profil retenu : B (le plus explicite). Les points diffèrent sans changer les valeurs : A aucun ; B ['forme_du_libelle (définition) « washing [...] with her tears before drying them with her hair »'].
- **ep-024#1** (`ecartee`) : Profil retenu : B (le plus explicite). Les points diffèrent sans changer les valeurs : A aucun ; B ['forme_du_libelle (définition) « washing [...] with her tears before drying them with her hair »'].
- **ep-024#3** (`inconnue`) : Profil retenu : B (le plus explicite). Les points diffèrent sans changer les valeurs : A aucun ; B ['forme_du_libelle (définition) « washing [...] with her tears before drying them with her hair »'].
- **ep-024#4** (`ecartee`) : Profil retenu : B (le plus explicite). Les points diffèrent sans changer les valeurs : A aucun ; B ['forme_du_libelle (définition) « washing [...] with her tears before drying them with her hair »'].
- **ep-024#5** (`etablie`) : Profil retenu : B (le plus explicite). Les points diffèrent sans changer les valeurs : A aucun ; B ['forme_du_libelle (définition) « washing [...] with her tears before drying them with her hair »'].

## 3. Les précisions 1.1 appliquées aux autres éléments

- **ep-015#4** (`divergent`) : note : Précision 1.1.2 : le point d'ancrage (phase préparatoire contre imminence) est un point du texte ; la classe imminente est F par l'exclusivité des ancrages (décision 26, IA § 6.2), que les deux annotateurs appliquent. La convention « l'imminent compte comme en cours » (guide § 3), non tranchée, n'est pas une valeur du point : sous elle, la classe imminente serait V, avec une hypothèse de nature co
- **ep-016#0** (`etablie_sous_hypotheses`) : fidélité : B la marque `traduction_infidele` : le passif « is kissed » fixe le baiser en cours et efface la lecture imminente. C'est une reformulation en anglais : le champ serait `paraphrase_infidele` (guide § 7). Elle n'est infidèle que si « bends to kiss » admet la lecture imminente, ce qui est la dépendance d1 du cas : non tranché. Le jugement de la variante telle qu'elle est est le même sous les deux options.
- **ep-019#5** (`divergent`) : note : Précision 1.1.2 : le point d'ancrage (phase préparatoire contre imminence) est un point du texte ; la classe imminente est F par l'exclusivité des ancrages (décision 26, IA § 6.2), que les deux annotateurs appliquent. La convention « l'imminent compte comme en cours » (guide § 3), non tranchée, n'est pas une valeur du point : sous elle, la classe imminente serait V, avec une hypothèse de nature co
- **ep-020** (`ecartee_sous_hypotheses`) : note : Précision 1.1.2 : le point d'ancrage (phase préparatoire contre imminence) est un point du texte ; la classe imminente est F par l'exclusivité des ancrages (décision 26, IA § 6.2), que les deux annotateurs appliquent. La convention « l'imminent compte comme en cours » (guide § 3), non tranchée, n'est pas une valeur du point : sous elle, la classe imminente serait V, avec une hypothèse de nature co
- **ep-020#0** (`ecartee_sous_hypotheses`) : note : Précision 1.1.2 : le point d'ancrage (phase préparatoire contre imminence) est un point du texte ; la classe imminente est F par l'exclusivité des ancrages (décision 26, IA § 6.2), que les deux annotateurs appliquent. La convention « l'imminent compte comme en cours » (guide § 3), non tranchée, n'est pas une valeur du point : sous elle, la classe imminente serait V, avec une hypothèse de nature co
- **ep-020#1** (`ecartee_sous_hypotheses`) : note : Précision 1.1.2 : le point d'ancrage (phase préparatoire contre imminence) est un point du texte ; la classe imminente est F par l'exclusivité des ancrages (décision 26, IA § 6.2), que les deux annotateurs appliquent. La convention « l'imminent compte comme en cours » (guide § 3), non tranchée, n'est pas une valeur du point : sous elle, la classe imminente serait V, avec une hypothèse de nature co
- **ep-020#4** (`ecartee_sous_hypotheses`) : note : Précision 1.1.2 : le point d'ancrage (phase préparatoire contre imminence) est un point du texte ; la classe imminente est F par l'exclusivité des ancrages (décision 26, IA § 6.2), que les deux annotateurs appliquent. La convention « l'imminent compte comme en cours » (guide § 3), non tranchée, n'est pas une valeur du point : sous elle, la classe imminente serait V, avec une hypothèse de nature co

## 4. Les statuts de référence des cas de base

| cas | A | B | référence | source |
|---|---|---|---|---|
| ep-001 | etablie | etablie | `etablie` | accord |
| ep-002 | etablie | etablie | `etablie` | accord |
| ep-003 | inconnue | inconnue | `inconnue` | accord |
| ep-004 | etablie | etablie | `etablie` | accord |
| ep-005 | etablie | etablie | `etablie` | accord |
| ep-006 | ecartee_sous_hypotheses | inconnue | `inconnue` | dependance |
| ep-007 | etablie | etablie | `etablie` | accord |
| ep-008 | divergent | divergent | `divergent` | accord |
| ep-009 | divergent | divergent | `divergent` | accord |
| ep-010 | etablie | etablie | `etablie` | accord |
| ep-011 | etablie | etablie | `etablie` | accord |
| ep-012 | inconnue | inconnue | `inconnue` | accord |
| ep-013 | etablie | etablie | `etablie` | accord |
| ep-014 | etablie_sous_hypotheses | etablie_sous_hypotheses | `etablie_sous_hypotheses` | accord |
| ep-015 | etablie | etablie | `etablie` | accord |
| ep-016 | etablie_sous_hypotheses | divergent | `etablie_sous_hypotheses` | dependance |
| ep-017 | etablie | etablie | `etablie` | accord |
| ep-018 | etablie_sous_hypotheses | etablie_sous_hypotheses | `etablie_sous_hypotheses` | accord |
| ep-019 | etablie | etablie | `etablie` | accord |
| ep-020 | ecartee_sous_hypotheses | ecartee_sous_hypotheses | `ecartee_sous_hypotheses` | accord |
| ep-021 | non_certifiee | non_certifiee | `non_certifiee` | accord |
| ep-022 | etablie | etablie | `etablie` | accord |
| ep-023 | ecartee | ecartee | `ecartee` | accord |
| ep-024 | ecartee | ecartee | `ecartee` | accord |
