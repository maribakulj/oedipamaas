# Adjudication : Référence et quantification (`reference_quantification`)

> **Précision de la session principale (28/11) :** le compte « une seule justification identique sur 72 » porte sur les seuls cas de base, et sur les trois familles du groupe ensemble. Sur les cas et les variantes, l'adjudicateur en compte 9 sur 503 (3 par famille), toutes de courtes citations du texte suivies de « V ».


> Pour ce groupe, les deux annotateurs ont utilisé le même dossier de brouillon, et l'indépendance de B par rapport à A n'est pas garantie (aucun signe de copie : accord comparable au groupe 1, une seule justification identique sur 72).

## Bilan

- éléments : 183 (cas et variantes) ; accord de statut 0.929, kappa 0.904 (comparaison) ;
- désaccords de statut ou de valeurs : 14 ; tranchés : 3 ; dépendances : 11 ;
- différences de points ou d'hypothèses seulement (accords, notés) : 14 ;
- accords dont le statut de référence change par les précisions 1.1 : 0 (aucun).

**La règle de prudence des dépendances.** Pour chaque dépendance, le statut retenu est celui de l'option la plus prudente sur les deux axes : il n'affirme ni un V ni un F que l'autre option n'affirme pas. Quand aucune option ne l'est sur les deux axes (l'une affirme un V, l'autre un F), je retiens leur partie commune, classe par classe : la valeur que les deux options affirment, N sinon ; le statut se lit sur ce profil, et je le dis à chaque fois.

**La convention de l'imminence (précision 1.1.2).** Partout où une classe imminente est F, elle l'est par l'exclusivité des ancrages (décision 26, IA § 6.2), règle que les deux annotateurs appliquent. La convention « l'imminent compte comme en cours » (guide § 3), non tranchée, n'est pas une valeur de point ; sous elle, la classe serait V avec une hypothèse de nature `convention`. Les statuts sont écrits sans elle ; la note figure dans la raison de chaque élément concerné.

## 1. Les désaccords

### rq-002#2

- **A :** `ecartee_sous_hypotheses` (F). Les places sont inversées : l'évêque est à la droite du diacre. Sous l'hypothèse que les deux figures ont la même orientation, le diacre est à la gauche de l'évêque, ce qui réfute « a deacon standing at his right », quel que soit l'antécédent de « il ».
- **B :** `inconnue` (N). Ici l'évêque est à la droite du diacre, non l'inverse. Que le diacre soit à la droite de l'évêque n'est pas dit ; ce n'est pas exclu analytiquement (deux figures tournées en sens contraire sont chacune à la droite de l'autre). Quelle que soit la reprise de « Il », une des deux conditions reste sans appui : N.
- **Dépendance :** `inconnue` — profil : {"p1": "eveque"} → N ; {"p1": "diacre"} → N
- **Raison :** A réfute sous l'hypothèse d'une orientation commune ; B juge N. Le texte ne dit pas l'orientation des figures (contrairement à rq-006#2, où « assis côte à côte sur un banc » la donne) ; la question de principe est ouverte : dépendance d1.
- **d1 — fondement d'un F (connaissance typique).** L'évêque est à la droite du diacre ; la définition demande le diacre à la droite de l'évêque. Une connaissance typique (deux figures côte à côte sont orientées de même) peut-elle fonder un F sous hypothèse ? Le guide § 4 admet « des F sous hypothèses » ; IA § 6.3 ne compte parmi les appuis négatifs ni l'opposition typique ni une implication non attestée, et la droite intrinsèque de l'un ne dit rien de celle de l'autre.
  - option : oui : l'orientation commune est une hypothèse connaissance_typique, et l'inversion réfute « at his right » quel que soit l'antécédent de « il » (A) → `ecartee_sous_hypotheses`
  - option : non : sans orientation dite, une des deux conditions reste sans appui, N (B) → `inconnue`
  - retenu : `inconnue`. Statut de référence : celui de l'option la plus prudente sur les deux axes (elle n'affirme ni un V ni un F que l'autre option n'affirme pas).

### rq-008#2

- **A :** `inconnue` (N). L'auteur les nomme nymphes. Nymphes et Grâces ne s'excluent pas analytiquement, mais rien ne dit que ce soient les Grâces : N.
- **B :** `etablie_sous_hypotheses` (V). « Trois nymphes » : nymphe et Grâce ne sont pas incompatibles, mais l'auteur ne dit pas Grâces. Le schéma (trois nues enlacées, la centrale de dos) les identifie : V sous identification iconographique.
- **Dépendance :** `inconnue` — profil : {} → N
- **Raison :** A et B s'accordent sur les faits ; ils divergent sur le seuil d'une identification iconographique.
- **d1 — seuil de l'identification iconographique.** « Trois nymphes, nues, enlacées, celle du centre vue de dos » : le schéma des Grâces peut-il fonder une hypothèse d'identification (guide § 1) quand l'auteur donne lui-même une autre désignation ? Nymphe et Grâce ne s'excluent pas.
  - option : oui : V sous identification_iconographique (B) → `etablie_sous_hypotheses`
  - option : non : la désignation de l'auteur arrête l'identification ; N (A) → `inconnue`
  - retenu : `inconnue`. Statut de référence : celui de l'option la plus prudente sur les deux axes (elle n'affirme ni un V ni un F que l'autre option n'affirme pas).

### rq-008#4

- **A :** `divergent` (F/V). « au nombre de deux sur ce fragment » : deux Grâces figurées, nombre dit. Si « three » exige trois figures : F (l'œuvre telle qu'elle est). Si « the three Graces » nomme seulement le groupe : V.
- **B :** `ecartee` (F). « au nombre de deux sur ce fragment » : nombre dit. Dans l'œuvre telle qu'elle est, deux Grâces, non trois : F.
- **Dépendance :** `ecartee_sous_hypotheses` — profil : {"p1": "trois_figurees_exigees"} → F ; {"p1": "nom_du_groupe"} → N
- **Raison :** Le désaccord tient à la lecture de « three » dans le libellé, que les principes ne fixent pas.
- **d1 — nombre du libellé lu comme exact (forme du libellé).** « au nombre de deux sur ce fragment » : nombre dit. « the three Graces » exige-t-il trois figures figurées, ou nomme-t-il seulement le groupe, dont deux membres figurés suffiraient ?
  - option : trois figures exigées, pas de point : F (B) → `ecartee`
  - option : point admis : F si trois figures exigées, V si le nom du groupe suffit (A) → `divergent`
  - retenu : `ecartee_sous_hypotheses`. Aucune des deux options n'est la plus prudente sur les deux axes (l'une affirme un V ou un F que l'autre n'affirme pas) : je retiens leur partie commune, classe par classe (la valeur que les deux options affirment, N sinon), et le statut qui s'en lit. F dans la lecture « trois figures exigées » (les deux options l'affirment) ; N dans la lecture « nom du groupe » (seule la seconde y affirme V).
- **Satisfaction contextuelle :** principal > état d'origine → `inconnue` (N, auteur) — « fragment » : le relief entier a pu montrer les trois figures ; rien n'en est dit (doutes de A et de B). Précision 1.1.1 : ce contexte ne fait pas le statut.

### rq-011#3

- **A :** `ecartee` (F). « offrent ensemble ... un unique coffret » : un seul présent, offert en commun ; « chacun un présent » est réfuté par la quantification dite.
- **B :** `ecartee_sous_hypotheses` (F/N). Offrande collective dite. « unique » borne-t-il les coffrets seulement (N : d'autres présents ne sont pas exclus) ou les présents (un seul présent en tout, ce qui exclut que chacun en offre un : F) ?
- **Décision :** `ecartee_sous_hypotheses` — profil : {"p1": "unique_coffret"} → N ; {"p1": "unique_present"} → F
- **Raison :** Je suis B. « un unique coffret » est une quantification dite sur les coffrets ; qu'il soit le seul présent n'est pas dit. Dans la lecture littérale, d'autres présents ne sont pas exclus, et le silence ne réfute rien (guide § 3 ; IA § 6.4-6.5 : un domaine restreint ne ferme pas le monde). Le F n'est fondé que dans la lecture où « unique » borne les présents. Dans cette lecture, F suppose aussi que l'offrande commune d'un même présent ne vaut pas « each offering a gift » ; c'est la lecture de la définition que A et B partagent (doute de A).

### rq-011#7

- **A :** `etablie_sous_hypotheses` (N/V). La lecture de l'auteur reste ambiguë ; le livret cité précise la lecture distributive, ce qui est une valeur citée, non un choix de lecture.
- **B :** `etablie_sous_hypotheses` (V). L'auteur garde l'ambiguïté du cas. Distributif : V (auteur). Collectif : la précision « chacun des Rois offre son propre présent » ne vient que du livret cité, qui décrit le tableau : V (cité).
- **Décision :** `etablie_sous_hypotheses` — profil : {"p1": "distributive"} → V ; {"p1": "collective"} → N ; {"p1": "collective"} → V (cite)
- **Raison :** Le statut est commun (etablie_sous_hypotheses) ; les valeurs diffèrent par la façon d'écrire la valeur citée. Dans la lecture collective, l'auteur ne dit pas que chacun offre un présent : N (A) ; le livret cité donne V, qui ne vient que de lui (guide § 3, `enonciateur`). B écrit la classe collective « V (cité) » et efface la valeur de l'auteur ; je garde les deux lignes, comme A. Que le livret parle du tableau, non du récit, est le point de chemin de IA § 7.5 ; A et B le lisent ainsi.

### rq-012#3

- **A :** `ecartee` (F). Ils se baissent pour soulever la grappe : elle n'est pas encore soulevée, donc pas encore portée. Porter est un processus, sans phase préparatoire figurée en cours.
- **B :** `divergent` (F/V). « about to set off », « bend down to lift » : le soulèvement est le début du portage (en cours) ou le portage n'a pas commencé (imminent). En cours : V ; imminent : F (décision 26).
- **Dépendance :** `ecartee_sous_hypotheses` — profil : {"p1": "phase_preparatoire"} → N ; {"p1": "imminent"} → F
- **Raison :** Le désaccord porte sur la frontière lexicale de la décision 26 (« about to », « bend down to »), que IA § 8.3 laisse ouverte. Précision 1.1.2 : le point d'ancrage (phase préparatoire contre imminence) est un point du texte ; la classe imminente est F par l'exclusivité des ancrages (décision 26, IA § 6.2), que les deux annotateurs appliquent. La convention « l'imminent compte comme en cours » (guide § 3), non tranchée, n'est pas une valeur du point : sous elle, la classe imminente serait V, avec une hypothèse de nature convention. Le statut est écrit sans elle.
- **d1 — ancrage (« about to », phase préparatoire d'une activité).** Se baisser pour soulever la grappe est-il la phase préparatoire d'un portage en cours (ONT § 1.2, qui la range dans l'en cours pour un événement de changement), ou le portage, une activité, n'a-t-il pas commencé (ancrage imminent, appui négatif par la décision 26) ?
  - option : pas de point : le portage n'a pas commencé, F (A) → `ecartee`
  - option : point admis : V en phase préparatoire, F si imminent (B) → `divergent`
  - retenu : `ecartee_sous_hypotheses`. Aucune des deux options n'est la plus prudente sur les deux axes (l'une affirme un V ou un F que l'autre n'affirme pas) : je retiens leur partie commune, classe par classe (la valeur que les deux options affirment, N sinon), et le statut qui s'en lit. F dans la lecture imminente (les deux l'affirment), N dans la lecture préparatoire (seul B y affirme V).

### rq-012#6

- **A :** `inconnue` (N). Deux hommes marchent une perche sur les épaules ; la grappe et les espions ne sont que dans le verset imprimé, qui raconte et ne décrit pas l'image : N.
- **B :** `etablie_sous_hypotheses` (V). L'image décrite : deux hommes, une perche sur les épaules ; ni espions ni grappe ne sont dits. Le verset raconte. Sous le lien typique du verset à l'image : V.
- **Dépendance :** `inconnue` — profil : {} → N
- **Raison :** A et B s'accordent : le verset est un contexte de récit, non de figuration. Ils divergent sur le lien typique qui le relierait à l'image. Comparer ep-002#3, où les deux acceptent l'hypothèse parce qu'elle explique une observation dite (le mât qui se fend) ; ici, la grappe n'est pas observée.
- **d1 — seuil de l'identification (lien d'un texte imprimé à son image).** L'image décrite : deux hommes, une perche sur les épaules. Le verset imprimé dessous raconte que les espions portèrent une grappe sur un bâton. Le lien typique du texte à l'image (décision 20) peut-il fonder que les hommes sont les espions et que la perche porte une grappe, objet que la description de l'image ne dit pas ? Le guide § 3 : une source qui raconte, ou un titre seul, ne satisfait rien.
  - option : oui : V sous connaissance_typique (B) → `etablie_sous_hypotheses`
  - option : non : le verset raconte ; N (A) → `inconnue`
  - retenu : `inconnue`. Statut de référence : celui de l'option la plus prudente sur les deux axes (elle n'affirme ni un V ni un F que l'autre option n'affirme pas).

### rq-019#3

- **A :** `etablie` (V). « la tête de saint Jean » : avec Salomé, le bourreau et le plat, le contexte ne laisse que le Baptiste. V.
- **B :** `etablie_sous_hypotheses` (V). « saint Jean » est un nom partiel ; le récit de Salomé fixe le Baptiste. V sous hypothèse.
- **Dépendance :** `etablie_sous_hypotheses` — profil : {} → V [identification_iconographique : « saint Jean » dont la tête est tendue à Salomé sur un plat est le Baptiste]
- **Raison :** Les deux annotateurs donnent V ; ils divergent sur la nature de ce qui fixe le Baptiste.
- **d1 — seuil de l'identification (nom partiel).** « la tête de saint Jean », tendue à Salomé sur un plat : le contexte fixe-t-il le Baptiste sans point (guide § 2), ou l'identification reste-t-elle une hypothèse (guide § 1 ; IA § 7.4 et décision 5 : un nom partiel est un point d'identité) ?
  - option : le contexte suffit : etablie (A) → `etablie`
  - option : hypothèse d'identification : V sous hypothèse (B) → `etablie_sous_hypotheses`
  - retenu : `etablie_sous_hypotheses`. Statut de référence : celui de l'option la plus prudente sur les deux axes (elle n'affirme ni un V ni un F que l'autre option n'affirme pas). Ici, elle n'affirme V que sous l'hypothèse ; aucune option n'affirme de F.

### rq-022

- **A :** `inconnue` (N). Jérôme prie à genoux devant le crucifix : dit. « alone » n'est pas dit ; le lion, un animal, ne fait pas compagnie au sens de « seul » (sans autre personne) : N.
- **B :** `ecartee_sous_hypotheses` (F/N). « alone » : sans autre personne, ou sans aucun compagnon (animal compris). Sans autre personne : l'exclusivité n'est pas dite : N. Sans compagnon : son lion dort à ses pieds : F.
- **Dépendance :** `inconnue` — profil : {"d1": "sans_autre_personne"} → N ; {"d1": "sans_aucun_compagnon"} → N
- **Raison :** Jérôme prie devant le crucifix : dit. Dans la lecture « sans autre personne », l'exclusivité n'est pas dite : N (A et B). Le F de B ne vaut que dans la lecture « sans aucun compagnon », que A n'admet pas.
- **d1 — domaine de « alone » (sens, définition).** « St Jerome praying alone » : « alone » veut-il dire sans autre personne (le lion, son attribut constant, ne compte pas ; « seul avec son lion » est du français ordinaire), ou sans aucun compagnon, animal compris ? Les principes ne fixent pas le domaine ; A écarte la seconde lecture (doute), B l'admet.
  - option : pas de point : « alone » = sans autre personne (A) → `inconnue`
  - option : point admis : sans autre personne / sans aucun compagnon (B) → `ecartee_sous_hypotheses`
  - retenu : `inconnue`. Statut de référence : celui de l'option la plus prudente sur les deux axes (elle n'affirme ni un V ni un F que l'autre option n'affirme pas).

### rq-022#0

- **A :** `inconnue` (N). Traduction fidèle.
- **B :** `ecartee_sous_hypotheses` (F/N). Traduction fidèle : même jugement que le cas.
- **Dépendance :** `inconnue` — profil : {"d1": "sans_autre_personne"} → N ; {"d1": "sans_aucun_compagnon"} → N
- **Raison :** Jérôme prie devant le crucifix : dit. Dans la lecture « sans autre personne », l'exclusivité n'est pas dite : N (A et B). Le F de B ne vaut que dans la lecture « sans aucun compagnon », que A n'admet pas. Traduction fidèle.
- **d1 — domaine de « alone » (sens, définition).** « St Jerome praying alone » : « alone » veut-il dire sans autre personne (le lion, son attribut constant, ne compte pas ; « seul avec son lion » est du français ordinaire), ou sans aucun compagnon, animal compris ? Les principes ne fixent pas le domaine ; A écarte la seconde lecture (doute), B l'admet.
  - option : pas de point : « alone » = sans autre personne (A) → `inconnue`
  - option : point admis : sans autre personne / sans aucun compagnon (B) → `ecartee_sous_hypotheses`
  - retenu : `inconnue`. Statut de référence : celui de l'option la plus prudente sur les deux axes (elle n'affirme ni un V ni un F que l'autre option n'affirme pas).

### rq-022#1

- **A :** `inconnue` (N). Reformulation.
- **B :** `ecartee_sous_hypotheses` (F/N). Paraphrase fidèle : même jugement que le cas.
- **Dépendance :** `inconnue` — profil : {"d1": "sans_autre_personne"} → N ; {"d1": "sans_aucun_compagnon"} → N
- **Raison :** Jérôme prie devant le crucifix : dit. Dans la lecture « sans autre personne », l'exclusivité n'est pas dite : N (A et B). Le F de B ne vaut que dans la lecture « sans aucun compagnon », que A n'admet pas. Reformulation fidèle.
- **d1 — domaine de « alone » (sens, définition).** « St Jerome praying alone » : « alone » veut-il dire sans autre personne (le lion, son attribut constant, ne compte pas ; « seul avec son lion » est du français ordinaire), ou sans aucun compagnon, animal compris ? Les principes ne fixent pas le domaine ; A écarte la seconde lecture (doute), B l'admet.
  - option : pas de point : « alone » = sans autre personne (A) → `inconnue`
  - option : point admis : sans autre personne / sans aucun compagnon (B) → `ecartee_sous_hypotheses`
  - retenu : `inconnue`. Statut de référence : celui de l'option la plus prudente sur les deux axes (elle n'affirme ni un V ni un F que l'autre option n'affirme pas).

### rq-022#3

- **A :** `etablie` (V). « seul avec son lion » : seul, au sens d'aucune autre personne : V.
- **B :** `divergent` (F/V). « seul avec son lion » : aucune autre personne (V), mais un compagnon animal (F).
- **Dépendance :** `etablie_sous_hypotheses` — profil : {"d1": "sans_autre_personne"} → V ; {"d1": "sans_aucun_compagnon"} → N
- **Raison :** « seul avec son lion » : aucune autre personne, dit ; un compagnon animal, dit.
- **d1 — domaine de « alone » (sens, définition).** « St Jerome praying alone » : « alone » veut-il dire sans autre personne (le lion, son attribut constant, ne compte pas ; « seul avec son lion » est du français ordinaire), ou sans aucun compagnon, animal compris ? Les principes ne fixent pas le domaine ; A écarte la seconde lecture (doute), B l'admet.
  - option : pas de point : « alone » = sans autre personne (A) → `etablie`
  - option : point admis : sans autre personne / sans aucun compagnon (B) → `divergent`
  - retenu : `etablie_sous_hypotheses`. Aucune des deux options n'est la plus prudente sur les deux axes (l'une affirme un V ou un F que l'autre n'affirme pas) : je retiens leur partie commune, classe par classe (la valeur que les deux options affirment, N sinon), et le statut qui s'en lit. V dans la lecture « sans autre personne » (les deux l'affirment) ; N dans la lecture « sans aucun compagnon » (seul B y affirme F).

### rq-022#5

- **A :** `inconnue` (N). Comme le cas ; un pèlerin chemine au loin.
- **B :** `ecartee_sous_hypotheses` (F/N). Le pèlerin au loin ne dit rien de l'exclusivité : même jugement que le cas.
- **Dépendance :** `inconnue` — profil : {"d1": "sans_autre_personne"} → N ; {"d1": "sans_aucun_compagnon"} → N
- **Raison :** Jérôme prie devant le crucifix : dit. Dans la lecture « sans autre personne », l'exclusivité n'est pas dite : N (A et B). Le F de B ne vaut que dans la lecture « sans aucun compagnon », que A n'admet pas. Le pèlerin au loin ne change rien : A et B lisent « seul » relativement au lieu de la prière.
- **d1 — domaine de « alone » (sens, définition).** « St Jerome praying alone » : « alone » veut-il dire sans autre personne (le lion, son attribut constant, ne compte pas ; « seul avec son lion » est du français ordinaire), ou sans aucun compagnon, animal compris ? Les principes ne fixent pas le domaine ; A écarte la seconde lecture (doute), B l'admet.
  - option : pas de point : « alone » = sans autre personne (A) → `inconnue`
  - option : point admis : sans autre personne / sans aucun compagnon (B) → `ecartee_sous_hypotheses`
  - retenu : `inconnue`. Statut de référence : celui de l'option la plus prudente sur les deux axes (elle n'affirme ni un V ni un F que l'autre option n'affirme pas).

### rq-024#1

- **A :** `etablie_sous_hypotheses` (V). Le lieu n'est plus dit ; Pierre dort pendant la prière du Christ. Gethsémani n'est que supposé, par l'identification de la scène.
- **B :** `etablie` (V). Paraphrase fidèle : même jugement que le cas.
- **Décision :** `etablie_sous_hypotheses` — profil : {} → V [identification_iconographique : la scène du Christ priant à l'écart près des trois apôtres endormis est au jardin de Gethsémani]
- **Raison :** Je suis A. B juge la paraphrase fidèle et reprend le jugement du cas sans l'examiner ; elle perd le lieu, que la définition demande (« in the Garden of Gethsemane »). C'est une reformulation en français : `paraphrase_infidele`, non `traduction_infidele` (guide § 7, dernier alinéa). Jugée telle qu'elle est : Gethsémani ne vient que de l'identification de la scène (guide § 1) : V sous hypothèse. Si l'on tenait que le contexte suffit (la question du seuil de rq-019#3), l'option prudente resterait celle-ci.
- **Fidélité :** Reformulation dans la même langue qui perd « Au jardin des Oliviers », que la définition demande.

## 2. Accords dont les points ou les hypothèses diffèrent

Le statut et les valeurs sont communs ; la référence prend le profil le plus explicite et note la différence.

- **rq-006#4** (`non_certifiee`) : Profil retenu : A (le plus explicite). Les hypothèses diffèrent de nature sans changer les valeurs : A ['identite'] ; B aucune.
- **rq-013#3** (`etablie_sous_hypotheses`) : Profil retenu : A. Les hypothèses diffèrent de nature sans changer les valeurs : A ['identification_iconographique'] ; B ['connaissance_typique'].
- **rq-015** (`etablie`) : Profil retenu : B (le plus explicite). Les points diffèrent sans changer les valeurs : A aucun ; B ['forme_du_libelle (définition) « one of his two daughters »'].
- **rq-015#0** (`etablie`) : Profil retenu : B (le plus explicite). Les points diffèrent sans changer les valeurs : A aucun ; B ['forme_du_libelle (définition) « one of his two daughters »'].
- **rq-015#1** (`etablie`) : Profil retenu : B (le plus explicite). Les points diffèrent sans changer les valeurs : A aucun ; B ['forme_du_libelle (définition) « one of his two daughters »'].
- **rq-015#2** (`inconnue`) : Profil retenu : B (le plus explicite). Les points diffèrent sans changer les valeurs : A aucun ; B ['forme_du_libelle (définition) « one of his two daughters »'].
- **rq-015#3** (`etablie_sous_hypotheses`) : Profil retenu : B (le plus explicite). Les hypothèses diffèrent de nature sans changer les valeurs : A aucune ; B ['connaissance_typique'].
- **rq-015#4** (`divergent`) : Profil retenu : B (le plus explicite). Les points diffèrent sans changer les valeurs : A ['ancrage « is about to hand him »'] ; B ['ancrage « one is about to hand him a shallow cup of wine »', 'forme_du_libelle (définition) « one of his two daughters »']. Précision 1.1.2 : le point d'ancrage (phase préparatoire contre imminence) est un point du texte ; la classe imminente est F par l'exclusivité des ancrages (décision 26, IA § 6.2), que les deux annotateurs appliquent. La convention « l'imminent compte comme en cours » (guide § 3), non tranchée, n'est pas une valeur du point : sous elle, la classe imminente serait V, avec une hypothèse de nature convention. Le statut est écrit sans elle.
- **rq-015#5** (`etablie`) : Profil retenu : B (le plus explicite). Les points diffèrent sans changer les valeurs : A aucun ; B ['forme_du_libelle (définition) « one of his two daughters »'].
- **rq-016#4** (`etablie_sous_hypotheses`) : Profil retenu : A. Les hypothèses diffèrent de nature sans changer les valeurs : A ['abduction'] ; B ['identification_iconographique'].
- **rq-017#4** (`etablie_sous_hypotheses`) : Profil retenu : A. Les hypothèses diffèrent de nature sans changer les valeurs : A ['abduction'] ; B ['identification_iconographique'].
- **rq-018#3** (`etablie_sous_hypotheses`) : Profil retenu : A. Les hypothèses diffèrent de nature sans changer les valeurs : A ['abduction'] ; B ['identification_iconographique'].
- **rq-022#2** (`etablie`) : Profil retenu : B (le plus explicite). Les points diffèrent sans changer les valeurs : A aucun ; B ['sens (définition) « alone »'].  La dépendance d1 du cas (domaine de « alone ») est ici sans effet : les deux options donnent le même statut.
- **rq-022#4** (`ecartee`) : Profil retenu : B (le plus explicite). Les points diffèrent sans changer les valeurs : A aucun ; B ['sens (définition) « alone »'].  La dépendance d1 du cas (domaine de « alone ») est ici sans effet : les deux options donnent le même statut.

## 3. Les précisions 1.1 appliquées aux autres éléments

- **rq-002#4** (`divergent`) : note : Précision 1.1.2 : le point d'ancrage (phase préparatoire contre imminence) est un point du texte ; la classe imminente est F par l'exclusivité des ancrages (décision 26, IA § 6.2), que les deux annotateurs appliquent. La convention « l'imminent compte comme en cours » (guide § 3), non tranchée, n'est pas une valeur du point : sous elle, la classe imminente serait V, avec une hypothèse de nature co
- **rq-004#3** (`divergent`) : note : Précision 1.1.2 : le point d'ancrage (phase préparatoire contre imminence) est un point du texte ; la classe imminente est F par l'exclusivité des ancrages (décision 26, IA § 6.2), que les deux annotateurs appliquent. La convention « l'imminent compte comme en cours » (guide § 3), non tranchée, n'est pas une valeur du point : sous elle, la classe imminente serait V, avec une hypothèse de nature co
- **rq-011#1** (`inconnue`) : fidélité : Reformulation dans la même langue : le passif à sujet indéfini singulier fixe un seul présent et efface la lecture distributive du cas.

## 4. Les statuts de référence des cas de base

| cas | A | B | référence | source |
|---|---|---|---|---|
| rq-001 | etablie | etablie | `etablie` | accord |
| rq-002 | etablie_sous_hypotheses | etablie_sous_hypotheses | `etablie_sous_hypotheses` | accord |
| rq-003 | etablie | etablie | `etablie` | accord |
| rq-004 | etablie | etablie | `etablie` | accord |
| rq-005 | inconnue | inconnue | `inconnue` | accord |
| rq-006 | etablie | etablie | `etablie` | accord |
| rq-007 | ecartee | ecartee | `ecartee` | accord |
| rq-008 | etablie | etablie | `etablie` | accord |
| rq-009 | etablie_sous_hypotheses | etablie_sous_hypotheses | `etablie_sous_hypotheses` | accord |
| rq-010 | etablie | etablie | `etablie` | accord |
| rq-011 | etablie_sous_hypotheses | etablie_sous_hypotheses | `etablie_sous_hypotheses` | accord |
| rq-012 | etablie | etablie | `etablie` | accord |
| rq-013 | etablie | etablie | `etablie` | accord |
| rq-014 | ecartee | ecartee | `ecartee` | accord |
| rq-015 | etablie | etablie | `etablie` | accord |
| rq-016 | etablie | etablie | `etablie` | accord |
| rq-017 | etablie_sous_hypotheses | etablie_sous_hypotheses | `etablie_sous_hypotheses` | accord |
| rq-018 | etablie_sous_hypotheses | etablie_sous_hypotheses | `etablie_sous_hypotheses` | accord |
| rq-019 | etablie | etablie | `etablie` | accord |
| rq-020 | etablie_sous_hypotheses | etablie_sous_hypotheses | `etablie_sous_hypotheses` | accord |
| rq-021 | etablie | etablie | `etablie` | accord |
| rq-022 | inconnue | ecartee_sous_hypotheses | `inconnue` | dependance |
| rq-023 | ecartee | ecartee | `ecartee` | accord |
| rq-024 | etablie | etablie | `etablie` | accord |
