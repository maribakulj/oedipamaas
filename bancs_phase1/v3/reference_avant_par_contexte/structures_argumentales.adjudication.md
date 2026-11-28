# Adjudication de la référence sémantique (niveau a) : structures_argumentales

Adjudication des annotations A et B, selon `docs/ANNOTATION_REFERENCE.md` (y compris les précisions 1.1 du § 7), `docs/INTERPRETATIONS_ADMISSIBLES.md` (§§ 2, 3, 6, 7, et le tableau des décisions du § 8.3 qu'ils citent) et `docs/ONTOLOGIE_EVENTUALITES.md`. Les fichiers A et B ne sont pas modifiés.

## Bilan

- éléments : 167 ; désaccords listés par la comparaison : 29 (dont 23 sur le statut ou les valeurs)
- références : 143 par accord (dont 4 dont le statut change par la précision 1.1), 19 par adjudication, 5 par dépendance
- dépendances par thème : ancrage préparatoire / imminent 3, inversion de rôles 2

**La règle des dépendances.** Le statut retenu est celui que toutes les options affirment, sur les deux axes : on n'affirme ni un V ni un F qu'une option n'affirme pas. Quand aucune option n'est elle-même prudente sur les deux axes, la référence retient leur partie commune, et le dit.

## Les désaccords et leur décision

### sa-001#2

- A : ecartee (F) ; B : inconnue (N)
- **référence : inconnue** (dependance)
- raison : Inversion des rôles avec le même objet ; décision 9. Dépendance.
- **dépendance** (inversion de rôles) — K : asymétrie d'une relation entre les mêmes participants (décision 9 : une inversion n'est négative que par une asymétrie attestée ; la liste des relations asymétriques reste à faire)
  - question : « A young deacon hands a closed book to the saint, who receives it » réfute-t-il « a saint giving a book to a deacon » ? Le transfert d'un même livre est-il asymétrique au même moment ?
  - option « le même livre ne passe pas dans les deux sens au même moment : F (A) » : ecartee
  - option « aucune asymétrie attestée : le don du saint n'est ni dit ni nié (B) » : inconnue
  - retenu : **inconnue**. L'option « aucune asymétrie attestée » n'affirme ni V ni F ; l'autre affirme un F qu'elle n'affirme pas. La référence retient la plus prudente : inconnue.

### sa-001#3

- A : etablie_sous_hypotheses (V) ; B : etablie_sous_hypotheses (NV)
- **référence : etablie_sous_hypotheses** (adjudication)
- raison : « seems » est un point (modalité ou apparence), et une prémisse graduée est une hypothèse d'une sorte propre, non un silence (INTERP § 8.3, décision 22). La classe « apparence » donne V ; la classe « modalisé » donne V sous l'hypothèse de la prémisse graduée, non N. A et B s'accordent sur etablie_sous_hypotheses ; le profil réunit le point de B et l'hypothèse de A.

### sa-003#3

- A : ecartee (F) ; B : divergent (FV)
- **référence : inconnue** (dependance)
- raison : « about to ascend », le char encore à terre, les nuées closes : A et B s'accordent sur l'imminent sans phase préparatoire. A conclut F, B divergent par une classe sous convention, ce que le guide § 7.2 exclut. La convention n'est pas tranchée : dépendance.
- **dépendance** (ancrage préparatoire / imminent) — convention d'évaluation : l'ancrage imminent (décision 26 ; guide § 7.2 ; ONT § 1.2 range la phase préparatoire dans l'en cours)
  - question : L'imminent compte-t-il comme en cours, pour une définition au participe présent ? (A et B s'accordent : aucune phase préparatoire n'est dite ; l'ancrage est imminent.)
  - option « oui : l'imminent compte comme en cours » : etablie_sous_hypotheses — V sous la convention et l'abduction que l'ascension se fera dans le char prêt
  - option « non : l'ancrage imminent est un appui négatif du en cours (INTERP § 6.2) » : ecartee — F
  - retenu : **inconnue**. « oui » affirme un V que « non » n'affirme pas, « non » un F que « oui » n'affirme pas : la partie commune ne contient ni V ni F, d'où inconnue. B range à tort la convention parmi les lectures (« divergent ») : guide § 7.2.

### sa-006#2

- A : etablie_sous_hypotheses (V) ; B : etablie_sous_hypotheses (NV)
- **référence : etablie_sous_hypotheses** (adjudication)
- raison : « seems » est un point (modalité ou apparence), et une prémisse graduée est une hypothèse d'une sorte propre, non un silence (INTERP § 8.3, décision 22). La classe « apparence » donne V ; la classe « modalisé » donne V sous l'hypothèse de la prémisse graduée, non N. A et B s'accordent sur etablie_sous_hypotheses ; le profil réunit le point de B et l'hypothèse de A.

### sa-007#3

- A : etablie (V) ; B : etablie (V)
- **référence : inconnue** (accord)
- satisfaction contextuelle : « principal > petit tableau sur le chevalet » : etablie
- raison : Accord de A et B : la définition est satisfaite dans le petit tableau figuré sur le chevalet. Précision 1.1 (1) : le statut se lit sur le contexte principal, où la Vierge est « seule » dans la loggia et saint Luc n'est pas figuré : N (la quantification « seule » porte sur la loggia et ne ferme pas tout le figuré), inconnue ; le tableau emboîté va dans satisfactions_contextuelles.

### sa-007#4

- A : divergent (FV) ; B : divergent (FV)
- **référence : etablie_sous_hypotheses** (dependance)
- raison : A et B posent le même point (phase préparatoire ou imminent) et concluent divergent ; B ajoute une classe sous convention. Une convention n'est pas une lecture (guide § 7.2) ; elle n'est pas tranchée : dépendance, la référence retient la partie commune.
- **dépendance** (ancrage préparatoire / imminent) — convention d'évaluation : l'ancrage imminent (décision 26 ; guide § 7.2 ; ONT § 1.2 range la phase préparatoire dans l'en cours)
  - question : L'imminent compte-t-il comme en cours, pour une définition au participe présent ?
  - option « oui : l'imminent compte comme en cours (hypothèse de nature convention) » : etablie_sous_hypotheses — V (phase préparatoire) ; V sous convention (imminent)
  - option « non : l'ancrage imminent est un appui négatif du en cours (INTERP § 6.2) » : divergent — V (phase préparatoire) ; F (imminent)
  - retenu : **etablie_sous_hypotheses**. Aucune option n'est prudente sur les deux axes : « oui » affirme un V (lecture imminente) que « non » n'affirme pas, « non » un F (lecture imminente) que « oui » n'affirme pas. La référence garde ce que les deux affirment : V sous la lecture de la phase préparatoire, N sous la lecture imminente ; d'où etablie_sous_hypotheses (choix : phase préparatoire).

### sa-008#4

- A : etablie_sous_hypotheses (V) ; B : etablie_sous_hypotheses (V)
- **référence : etablie_sous_hypotheses** (accord)
- raison : Accord de A et B sur le statut et les valeurs ; profil de B. Diffèrent : dimensions. B pose le point de « apparently » ; sous les deux classes, V (l'instrument dit, ou l'abduction du cas de base). Mêmes valeurs.

### sa-009#4

- A : etablie_sous_hypotheses (V) ; B : etablie_sous_hypotheses (NV)
- **référence : etablie_sous_hypotheses** (adjudication)
- raison : « Seemingly » est un point (modalité ou apparence), et une prémisse graduée est une hypothèse d'une sorte propre, non un silence (INTERP § 8.3, décision 22). La classe « apparence » donne V ; la classe « modalisé » donne V sous l'hypothèse de la prémisse graduée, non N. A et B s'accordent sur etablie_sous_hypotheses ; le profil réunit le point de B et l'hypothèse de A.

### sa-014

- A : etablie_sous_hypotheses (V) ; B : inconnue (N)
- **référence : etablie_sous_hypotheses** (adjudication)
- raison : « perhaps anoints » est une prémisse graduée de l'auteur : la décision 22 (INTERP § 8.3) en fait une hypothèse d'une sorte propre, non une absence d'information ; la valeur est V sous cette hypothèse (A). B la tient pour N, ce que la décision 22 exclut. La sorte de l'hypothèse reste ouverte (« avec l'abduction ») : elle est notée abduction, avec la mention « prémisse graduée ».

### sa-014#0

- A : etablie_sous_hypotheses (V) ; B : inconnue (N)
- **référence : etablie_sous_hypotheses** (adjudication)
- raison : « lui oint peut-être » est une prémisse graduée de l'auteur : la décision 22 (INTERP § 8.3) en fait une hypothèse d'une sorte propre, non une absence d'information ; la valeur est V sous cette hypothèse (A). B la tient pour N, ce que la décision 22 exclut. La sorte de l'hypothèse reste ouverte (« avec l'abduction ») : elle est notée abduction, avec la mention « prémisse graduée ».

### sa-014#2

- A : etablie_sous_hypotheses (V) ; B : inconnue (N)
- **référence : etablie_sous_hypotheses** (adjudication)
- raison : « possibly anoints » est une prémisse graduée de l'auteur : la décision 22 (INTERP § 8.3) en fait une hypothèse d'une sorte propre, non une absence d'information ; la valeur est V sous cette hypothèse (A). B la tient pour N, ce que la décision 22 exclut. La sorte de l'hypothèse reste ouverte (« avec l'abduction ») : elle est notée abduction, avec la mention « prémisse graduée ».

### sa-014#5

- A : etablie_sous_hypotheses (V) ; B : inconnue (N)
- **référence : etablie_sous_hypotheses** (adjudication)
- raison : « perhaps anoints » est une prémisse graduée de l'auteur : la décision 22 (INTERP § 8.3) en fait une hypothèse d'une sorte propre, non une absence d'information ; la valeur est V sous cette hypothèse (A). B la tient pour N, ce que la décision 22 exclut. La sorte de l'hypothèse reste ouverte (« avec l'abduction ») : elle est notée abduction, avec la mention « prémisse graduée ».

### sa-015#4

- A : etablie (V) ; B : etablie (V)
- **référence : inconnue** (accord)
- satisfaction contextuelle : « principal > petite scène sculptée sur le flanc du sarcophage » : etablie
- raison : Accord de A et B : la définition est satisfaite dans la petite scène sculptée sur le sarcophage. Précision 1.1 (1) : le champ principal montre la Mise au tombeau et ne satisfait rien (N, inconnue) ; la scène emboîtée va dans satisfactions_contextuelles.

### sa-016

- A : etablie_sous_hypotheses (V) ; B : etablie_sous_hypotheses (NV)
- **référence : etablie_sous_hypotheses** (adjudication)
- raison : A et B posent le même point de sens sur « relève » et s'accordent sur etablie_sous_hypotheses. Sous le sens physique, B donne N ; A donne V sous une identification iconographique, nature d'hypothèse que le guide prévoit (§ 1, § 3). L'épisode est nommé par l'auteur (Naïm, le fils de la veuve, la civière) : la question du seuil d'une identification ne se pose pas ici. Profil de A.

### sa-016#0

- A : etablie_sous_hypotheses (V) ; B : etablie_sous_hypotheses (NV)
- **référence : etablie_sous_hypotheses** (adjudication)
- raison : A et B posent le même point de sens sur « relève » et s'accordent sur etablie_sous_hypotheses. Sous le sens physique, B donne N ; A donne V sous une identification iconographique, nature d'hypothèse que le guide prévoit (§ 1, § 3). L'épisode est nommé par l'auteur (Naïm, le fils de la veuve, la civière) : la question du seuil d'une identification ne se pose pas ici. Profil de A.

### sa-016#1

- A : etablie_sous_hypotheses (V) ; B : etablie_sous_hypotheses (NV)
- **référence : etablie_sous_hypotheses** (adjudication)
- raison : A et B posent le même point de sens sur « relève » et s'accordent sur etablie_sous_hypotheses. Sous le sens physique, B donne N ; A donne V sous une identification iconographique, nature d'hypothèse que le guide prévoit (§ 1, § 3). L'épisode est nommé par l'auteur (Naïm, le fils de la veuve, la civière) : la question du seuil d'une identification ne se pose pas ici. Profil de A.

### sa-016#2

- A : non_certifiee (NV) ; B : non_certifiee (NV)
- **référence : non_certifiee** (accord)
- raison : « dit-on » : l'action n'est pas prise en charge par l'auteur ; A et B s'accordent sur non_certifiee. Profil de A (classe N de l'auteur, et le sens physique sous l'identification, comme au cas de base).

### sa-016#3

- A : divergent (FV) ; B : divergent (FNV)
- **référence : etablie_sous_hypotheses** (dependance)
- raison : A et B posent le point d'ancrage et concluent divergent ; B ajoute une classe sous convention, ce que le guide § 7.2 range parmi les hypothèses. Le sens physique est traité comme au cas de base (V sous l'identification). Convention non tranchée : dépendance, partie commune retenue.
- **dépendance** (ancrage préparatoire / imminent) — convention d'évaluation : l'ancrage imminent (décision 26 ; guide § 7.2 ; ONT § 1.2 range la phase préparatoire dans l'en cours)
  - question : L'imminent compte-t-il comme en cours, pour une définition au participe présent ?
  - option « oui : l'imminent compte comme en cours (hypothèse de nature convention) » : etablie_sous_hypotheses — V (phase préparatoire, deux sens) ; V sous convention (imminent)
  - option « non : l'ancrage imminent est un appui négatif du en cours (INTERP § 6.2) » : divergent — V (phase préparatoire) ; F (imminent)
  - retenu : **etablie_sous_hypotheses**. Aucune option n'est prudente sur les deux axes : « oui » affirme un V (lecture imminente) que « non » n'affirme pas, « non » un F (lecture imminente) que « oui » n'affirme pas. La référence garde ce que les deux affirment : V sous la lecture de la phase préparatoire, N sous la lecture imminente ; d'où etablie_sous_hypotheses (choix : phase préparatoire).

### sa-016#5

- A : etablie_sous_hypotheses (V) ; B : etablie_sous_hypotheses (NV)
- **référence : etablie_sous_hypotheses** (adjudication)
- raison : A et B posent le même point de sens sur « relève » et s'accordent sur etablie_sous_hypotheses. Sous le sens physique, B donne N ; A donne V sous une identification iconographique, nature d'hypothèse que le guide prévoit (§ 1, § 3). L'épisode est nommé par l'auteur (Naïm, le fils de la veuve, la civière) : la question du seuil d'une identification ne se pose pas ici. Profil de A.

### sa-017#1

- A : ecartee_sous_hypotheses (F) ; B : ecartee (F)
- **référence : ecartee** (adjudication)
- raison : « Her loose hair is bare » et la couronne tenue en main réfutent « wearing a wreath of roses » pour la seule figure citée. La conjonction réfutée réfute la sélection, que la jeune femme soit Dorothée ou non (INTERP § 6.4 ; § 2.5, pour les référents cités) : l'identification n'est pas une condition du F. ecartee (B), non ecartee_sous_hypotheses (A).

### sa-017#2

- A : ecartee_sous_hypotheses (F) ; B : ecartee (F)
- **référence : ecartee** (adjudication)
- raison : « who does not wear the wreath of roses » : négation dite (guide § 3). Le F vaut pour la seule figure citée, quelle que soit son identité : ecartee (B).

### sa-019#4

- A : inconnue (N) ; B : inconnue (N)
- **référence : inconnue** (accord)
- satisfaction contextuelle : « principal > état d'origine » : inconnue
- raison : Accord de A et B sur le statut et les valeurs ; profil de A. Diffèrent : natures, contextes. A garde la classe de l'état d'origine (N) ; B ne la pose pas. Mêmes valeurs. Précision 1.1 (1) : « principal > état d'origine » (inconnue) va dans satisfactions_contextuelles ; le statut se lit sur le contexte principal.

### sa-020

- A : divergent (FNV) ; B : inconnue (N)
- **référence : inconnue** (adjudication)
- satisfaction contextuelle : « principal > état d'origine » : inconnue
- raison : Précision 1.1 (1) et (3). Dans l'œuvre actuelle, le bas est perdu : la station debout n'est ni dite ni niée (N, inconnue). L'état d'origine est un autre contexte ; l'alternative de l'auteur n'est pas une ambiguïté et se traite par cas : N avec les branches. A range les branches en classes V et F sous abduction et conclut divergent ; B conclut inconnue, qui est retenu.

### sa-020#0

- A : divergent (FNV) ; B : inconnue (N)
- **référence : inconnue** (adjudication)
- satisfaction contextuelle : « principal > état d'origine » : inconnue
- raison : Précision 1.1 (1) et (3). Dans l'œuvre actuelle, le bas est perdu : la station debout n'est ni dite ni niée (N, inconnue). L'état d'origine est un autre contexte ; l'alternative de l'auteur n'est pas une ambiguïté et se traite par cas : N avec les branches. A range les branches en classes V et F sous abduction et conclut divergent ; B conclut inconnue, qui est retenu.

### sa-020#2

- A : divergent (FNV) ; B : inconnue (N)
- **référence : inconnue** (adjudication)
- satisfaction contextuelle : « principal > état d'origine » : inconnue
- raison : Précision 1.1 (1) et (3). Dans l'œuvre actuelle, le bas est perdu : la station debout n'est ni dite ni niée (N, inconnue). L'état d'origine est un autre contexte ; l'alternative de l'auteur n'est pas une ambiguïté et se traite par cas : N avec les branches. A range les branches en classes V et F sous abduction et conclut divergent ; B conclut inconnue, qui est retenu.

### sa-020#4

- A : divergent (FNV) ; B : inconnue (N)
- **référence : inconnue** (adjudication)
- satisfaction contextuelle : « principal > état d'origine » : inconnue
- raison : Précision 1.1 (1) et (3). Dans l'œuvre actuelle, le bas est perdu : la station debout n'est ni dite ni niée (N, inconnue). L'état d'origine est un autre contexte ; l'alternative de l'auteur n'est pas une ambiguïté et se traite par cas : N avec les branches. A range les branches en classes V et F sous abduction et conclut divergent ; B conclut inconnue, qui est retenu.

### sa-021#4

- A : divergent (FV) ; B : inconnue (N)
- **référence : inconnue** (adjudication)
- satisfaction contextuelle : « principal > état d'origine » : etablie_sous_hypotheses
- raison : « upright » qualifie le fragment (« an upright fragment set into the wall ») : c'est la position de l'objet, non la posture figurée, et rien ne dit la posture actuelle du chevalier : N dans l'œuvre actuelle (B), non F (A, qui en doute lui-même). Précision 1.1 (1) : l'état d'origine va dans satisfactions_contextuelles, V sous la prémisse graduée (décision 22).

### sa-023#2

- A : ecartee (F) ; B : inconnue (N)
- **référence : inconnue** (dependance)
- raison : A et B s'accordent sur la structure (le roi est sujet de « remet »). Reste l'inversion des rôles avec le même objet : dépendance.
- **dépendance** (inversion de rôles) — K : asymétrie d'une relation entre les mêmes participants (décision 9 : une inversion n'est négative que par une asymétrie attestée ; la liste des relations asymétriques reste à faire)
  - question : Le sujet de « lui remet une épée » est le roi : « le roi remet une épée à la Justice » réfute-t-il « Justice presenting a sword to a kneeling king » ?
  - option « le même objet ne passe pas dans les deux sens au même moment : F (A) » : ecartee
  - option « aucune asymétrie attestée : le don de la Justice n'est ni dit ni nié (B) » : inconnue
  - retenu : **inconnue**. L'option « aucune asymétrie attestée » n'affirme ni V ni F ; l'autre affirme un F qu'elle n'affirme pas. La référence retient la plus prudente : inconnue.

### sa-023#4

- A : etablie_sous_hypotheses (V) ; B : etablie_sous_hypotheses (NV)
- **référence : etablie_sous_hypotheses** (adjudication)
- raison : « semble » est un point (modalité ou apparence), et une prémisse graduée est une hypothèse d'une sorte propre, non un silence (INTERP § 8.3, décision 22). La classe « apparence » donne V ; la classe « modalisé » donne V sous l'hypothèse de la prémisse graduée, non N. A et B s'accordent sur etablie_sous_hypotheses ; le profil réunit le point de B et l'hypothèse de A.

## Les accords corrigés par la précision 1.1 (hors liste de la comparaison)

- **sa-008#3** : statut commun « non_certifiee » → **inconnue** ; « principal > état d'origine » : non_certifiee
- **sa-011#6** : statut commun « non_certifiee » → **inconnue** ; « principal > état d'origine » : non_certifiee
- **sa-017#4** : statut commun « non_certifiee » → **inconnue** ; « principal > état d'origine » : non_certifiee
- **sa-020#3** : statut commun « etablie_sous_hypotheses » → **inconnue** ; « principal > état d'origine » : etablie_sous_hypotheses

## Les statuts de référence des cas de base

| cas | statut de référence | source |
|---|---|---|
| sa-001 | etablie | accord |
| sa-002 | ecartee | accord |
| sa-003 | etablie | accord |
| sa-004 | ecartee | accord |
| sa-005 | etablie | accord |
| sa-006 | non_certifiee | accord |
| sa-007 | etablie | accord |
| sa-008 | etablie_sous_hypotheses | accord |
| sa-009 | etablie | accord |
| sa-010 | etablie_sous_hypotheses | accord |
| sa-011 | etablie_sous_hypotheses | accord |
| sa-012 | ecartee | accord |
| sa-013 | etablie | accord |
| sa-014 | etablie_sous_hypotheses | adjudication |
| sa-015 | etablie | accord |
| sa-016 | etablie_sous_hypotheses | adjudication |
| sa-017 | etablie_sous_hypotheses | accord |
| sa-018 | ecartee | accord |
| sa-019 | etablie | accord |
| sa-020 | inconnue | adjudication |
| sa-021 | etablie | accord |
| sa-022 | ecartee | accord |
| sa-023 | etablie | accord |
| sa-024 | ecartee | accord |
