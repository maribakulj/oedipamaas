# Adjudication de la référence sémantique (niveau a) : evenements_etats

Adjudication des annotations A et B, selon `docs/ANNOTATION_REFERENCE.md` (y compris les précisions 1.1 du § 7), `docs/INTERPRETATIONS_ADMISSIBLES.md` (§§ 2, 3, 6, 7, et le tableau des décisions du § 8.3 qu'ils citent) et `docs/ONTOLOGIE_EVENTUALITES.md`. Les fichiers A et B ne sont pas modifiés.

## Bilan

- éléments : 181 ; désaccords listés par la comparaison : 30 (dont 13 sur le statut ou les valeurs)
- références : 159 par accord (dont 5 dont le statut change par la précision 1.1), 10 par adjudication, 12 par dépendance
- dépendances par thème : ancrage préparatoire / imminent 9, inversion de rôles 3

**La règle des dépendances.** Le statut retenu est celui que toutes les options affirment, sur les deux axes : on n'affirme ni un V ni un F qu'une option n'affirme pas. Quand aucune option n'est elle-même prudente sur les deux axes, la référence retient leur partie commune, et le dit.

## Les désaccords et leur décision

### ee-001#4

- A : etablie_sous_hypotheses (V) ; B : etablie_sous_hypotheses (NV)
- **référence : etablie_sous_hypotheses** (adjudication)
- raison : « semble » est un point (modalité ou apparence), et une prémisse graduée est une hypothèse d'une sorte propre, non un silence (INTERP § 8.3, décision 22). La classe « apparence » donne V ; la classe « modalisé » donne V sous l'hypothèse de la prémisse graduée, non N. A et B s'accordent sur etablie_sous_hypotheses ; le profil réunit le point de B et l'hypothèse de A.

### ee-002#2

- A : ecartee (F) ; B : inconnue (N)
- **référence : inconnue** (dependance)
- raison : Les rôles sont inversés avec le même objet. Le F de A repose sur l'asymétrie du transfert, que la décision 9 ne tient pour négative que si elle est attestée ; elle ne l'est pas encore. Dépendance.
- **dépendance** (inversion de rôles) — K : asymétrie d'une relation entre les mêmes participants (décision 9 : une inversion n'est négative que par une asymétrie attestée ; la liste des relations asymétriques reste à faire)
  - question : « Un mendiant nu tend un manteau rouge à un cavalier » réfute-t-il « le cavalier donne son manteau au mendiant » ? Le transfert d'un même objet entre les mêmes personnes est-il asymétrique au même moment, et « un manteau » est-il « son manteau » ?
  - option « le don a une direction unique pour un même objet au même moment : F pour les référents cités (A) » : ecartee
  - option « aucune asymétrie attestée ; le don du cavalier n'est ni dit ni nié (B) » : inconnue
  - retenu : **inconnue**. L'option « aucune asymétrie attestée » n'affirme ni V ni F ; l'autre affirme un F qu'elle n'affirme pas. La référence retient la plus prudente : inconnue.

### ee-002#5

- A : ecartee (F) ; B : divergent (FV)
- **référence : ecartee** (adjudication)
- satisfaction contextuelle : « principal > état d'origine » : etablie_sous_hypotheses
- raison : Œuvre actuelle : « il ne subsiste qu'un cavalier » est une quantification dite qui exclut le mendiant et le don (guide § 3) : F, comme le jugent A et B. L'état d'origine est un autre contexte (guide § 7.1 ; décision 19) : il va dans satisfactions_contextuelles et ne fait pas « divergent » (contre B). Le statut se lit sur le contexte principal : ecartee.

### ee-003#3

- A : etablie_sous_hypotheses (V) ; B : inconnue (N)
- **référence : etablie_sous_hypotheses** (adjudication)
- raison : « may already be dead » est une prémisse graduée de l'auteur : la décision 22 (INTERP § 8.3) en fait une hypothèse d'une sorte propre, non une absence d'information ; la valeur est V sous cette hypothèse (A). B la tient pour N, ce que la décision 22 exclut. La sorte de l'hypothèse reste ouverte (« avec l'abduction ») : elle est notée abduction, avec la mention « prémisse graduée ».

### ee-004#3

- A : etablie_sous_hypotheses (V) ; B : etablie_sous_hypotheses (NV)
- **référence : etablie_sous_hypotheses** (adjudication)
- raison : « seems » est un point (modalité ou apparence), et une prémisse graduée est une hypothèse d'une sorte propre, non un silence (INTERP § 8.3, décision 22). La classe « apparence » donne V ; la classe « modalisé » donne V sous l'hypothèse de la prémisse graduée, non N. A et B s'accordent sur etablie_sous_hypotheses ; le profil réunit le point de B et l'hypothèse de A.

### ee-005#3

- A : inconnue (N) ; B : inconnue (N)
- **référence : inconnue** (accord)
- raison : Accord de A et B sur le statut et les valeurs ; profil de B. Diffèrent : dimensions. B explicite la coréférence de « lui » (deux classes N) ; A ne la pose pas. Mêmes valeurs.

### ee-006#4

- A : etablie_sous_hypotheses (V) ; B : inconnue (N)
- **référence : etablie_sous_hypotheses** (adjudication)
- raison : « perhaps in a rage » est une prémisse graduée de l'auteur : la décision 22 (INTERP § 8.3) en fait une hypothèse d'une sorte propre, non une absence d'information ; la valeur est V sous cette hypothèse (A). B la tient pour N, ce que la décision 22 exclut. La sorte de l'hypothèse reste ouverte (« avec l'abduction ») : elle est notée abduction, avec la mention « prémisse graduée ».

### ee-007#3

- A : etablie_sous_hypotheses (V) ; B : etablie_sous_hypotheses (V)
- **référence : etablie_sous_hypotheses** (accord)
- raison : Accord de A et B sur le statut et les valeurs ; profil de B. Diffèrent : natures. Mêmes valeurs ; B distingue deux hypothèses (le lien typique de l'inscription à la figure, décision 20 ; l'abduction du visage caché), A n'en pose qu'une.

### ee-008

- A : divergent (FV) ; B : divergent (FV)
- **référence : etablie_sous_hypotheses** (dependance)
- raison : A et B lisent tous deux « s'apprête à sacrifier » comme un point d'ancrage (phase préparatoire ou imminent) et s'accordent sur divergent ; B ajoute une classe V sous la convention de l'imminent. Une convention n'est pas une lecture (guide § 7.2) : elle n'ouvre pas de classe, elle conditionne la valeur de la classe imminente. Cette convention n'est pas tranchée : dépendance, et la référence retient la partie commune des deux options.
- **dépendance** (ancrage préparatoire / imminent) — convention d'évaluation : l'ancrage imminent (décision 26 ; guide § 7.2 ; ONT § 1.2 range la phase préparatoire dans l'en cours)
  - question : L'imminent compte-t-il comme en cours, pour une définition au participe présent ?
  - option « oui : l'imminent compte comme en cours (hypothèse de nature convention) » : etablie_sous_hypotheses — V (phase préparatoire) ; V sous convention (imminent)
  - option « non : l'ancrage imminent est un appui négatif du en cours (INTERP § 6.2) » : divergent — V (phase préparatoire) ; F (imminent)
  - retenu : **etablie_sous_hypotheses**. Aucune option n'est prudente sur les deux axes : « oui » affirme un V (lecture imminente) que « non » n'affirme pas, « non » un F (lecture imminente) que « oui » n'affirme pas. La référence garde ce que les deux affirment : V sous la lecture de la phase préparatoire, N sous la lecture imminente ; d'où etablie_sous_hypotheses (choix : phase préparatoire).

### ee-008#0

- A : divergent (FV) ; B : divergent (FV)
- **référence : etablie_sous_hypotheses** (dependance)
- raison : A et B lisent tous deux « is preparing to sacrifice » comme un point d'ancrage (phase préparatoire ou imminent) et s'accordent sur divergent ; B ajoute une classe V sous la convention de l'imminent. Une convention n'est pas une lecture (guide § 7.2) : elle n'ouvre pas de classe, elle conditionne la valeur de la classe imminente. Cette convention n'est pas tranchée : dépendance, et la référence retient la partie commune des deux options.
- **dépendance** (ancrage préparatoire / imminent) — convention d'évaluation : l'ancrage imminent (décision 26 ; guide § 7.2 ; ONT § 1.2 range la phase préparatoire dans l'en cours)
  - question : L'imminent compte-t-il comme en cours, pour une définition au participe présent ?
  - option « oui : l'imminent compte comme en cours (hypothèse de nature convention) » : etablie_sous_hypotheses — V (phase préparatoire) ; V sous convention (imminent)
  - option « non : l'ancrage imminent est un appui négatif du en cours (INTERP § 6.2) » : divergent — V (phase préparatoire) ; F (imminent)
  - retenu : **etablie_sous_hypotheses**. Aucune option n'est prudente sur les deux axes : « oui » affirme un V (lecture imminente) que « non » n'affirme pas, « non » un F (lecture imminente) que « oui » n'affirme pas. La référence garde ce que les deux affirment : V sous la lecture de la phase préparatoire, N sous la lecture imminente ; d'où etablie_sous_hypotheses (choix : phase préparatoire).

### ee-008#1

- A : divergent (FV) ; B : divergent (FV)
- **référence : etablie_sous_hypotheses** (dependance)
- raison : A et B lisent tous deux « se prépare à immoler » comme un point d'ancrage (phase préparatoire ou imminent) et s'accordent sur divergent ; B ajoute une classe V sous la convention de l'imminent. Une convention n'est pas une lecture (guide § 7.2) : elle n'ouvre pas de classe, elle conditionne la valeur de la classe imminente. Cette convention n'est pas tranchée : dépendance, et la référence retient la partie commune des deux options.
- **dépendance** (ancrage préparatoire / imminent) — convention d'évaluation : l'ancrage imminent (décision 26 ; guide § 7.2 ; ONT § 1.2 range la phase préparatoire dans l'en cours)
  - question : L'imminent compte-t-il comme en cours, pour une définition au participe présent ?
  - option « oui : l'imminent compte comme en cours (hypothèse de nature convention) » : etablie_sous_hypotheses — V (phase préparatoire) ; V sous convention (imminent)
  - option « non : l'ancrage imminent est un appui négatif du en cours (INTERP § 6.2) » : divergent — V (phase préparatoire) ; F (imminent)
  - retenu : **etablie_sous_hypotheses**. Aucune option n'est prudente sur les deux axes : « oui » affirme un V (lecture imminente) que « non » n'affirme pas, « non » un F (lecture imminente) que « oui » n'affirme pas. La référence garde ce que les deux affirment : V sous la lecture de la phase préparatoire, N sous la lecture imminente ; d'où etablie_sous_hypotheses (choix : phase préparatoire).

### ee-008#2

- A : divergent (FV) ; B : divergent (FV)
- **référence : inconnue** (dependance)
- raison : A admet un point d'ancrage (phase préparatoire, le geste engagé, ou imminent) et conclut divergent ; B lit « sur le point de » comme univoquement imminent et conclut divergent par une classe sous convention, ce que le guide § 7.2 exclut. Deux questions restent ouvertes : la frontière lexicale de « sur le point de » comme point (décision 26) et la convention de l'imminent. La référence retient ce que toutes les options affirment : rien.
- **dépendance** (ancrage préparatoire / imminent) — espace (un point d'ancrage pour « sur le point de » : décision 26, « reste : la frontière lexicale (« s'apprête », « about to ») comme point de D ») et convention d'évaluation : l'ancrage imminent (décision 26 ; guide § 7.2 ; ONT § 1.2 range la phase préparatoire dans l'en cours)
  - question : « sur le point de » laisse-t-il une lecture de phase préparatoire (en cours) à côté de l'imminent ? Et l'imminent compte-t-il comme en cours ?
  - option « point admis, sans convention (A) » : divergent — V (préparatoire) ; F (imminent)
  - option « point admis, avec la convention » : etablie_sous_hypotheses — V (préparatoire) ; V sous convention (imminent)
  - option « imminent seul, sans convention (B sans sa classe sous convention) » : ecartee — F
  - option « imminent seul, avec la convention (B) » : etablie_sous_hypotheses — V sous convention
  - retenu : **inconnue**. Aucun V n'est affirmé par toutes les options (« imminent seul, sans convention » donne ecartee), aucun F non plus (les options avec la convention n'en ont pas). Ce que toutes affirment ne contient ni V ni F : inconnue. B range à tort la convention parmi les lectures (« divergent ») : guide § 7.2.

### ee-008#6

- A : divergent (FV) ; B : divergent (FV)
- **référence : etablie_sous_hypotheses** (dependance)
- raison : A et B lisent tous deux « s'apprête à sacrifier » comme un point d'ancrage (phase préparatoire ou imminent) et s'accordent sur divergent ; B ajoute une classe V sous la convention de l'imminent. Une convention n'est pas une lecture (guide § 7.2) : elle n'ouvre pas de classe, elle conditionne la valeur de la classe imminente. Cette convention n'est pas tranchée : dépendance, et la référence retient la partie commune des deux options.
- **dépendance** (ancrage préparatoire / imminent) — convention d'évaluation : l'ancrage imminent (décision 26 ; guide § 7.2 ; ONT § 1.2 range la phase préparatoire dans l'en cours)
  - question : L'imminent compte-t-il comme en cours, pour une définition au participe présent ?
  - option « oui : l'imminent compte comme en cours (hypothèse de nature convention) » : etablie_sous_hypotheses — V (phase préparatoire) ; V sous convention (imminent)
  - option « non : l'ancrage imminent est un appui négatif du en cours (INTERP § 6.2) » : divergent — V (phase préparatoire) ; F (imminent)
  - retenu : **etablie_sous_hypotheses**. Aucune option n'est prudente sur les deux axes : « oui » affirme un V (lecture imminente) que « non » n'affirme pas, « non » un F (lecture imminente) que « oui » n'affirme pas. La référence garde ce que les deux affirment : V sous la lecture de la phase préparatoire, N sous la lecture imminente ; d'où etablie_sous_hypotheses (choix : phase préparatoire).

### ee-009

- A : divergent (FV) ; B : divergent (FV)
- **référence : inconnue** (dependance)
- raison : A admet un point d'ancrage (phase préparatoire, le geste engagé, ou imminent) et conclut divergent ; B lit « about to strike » comme univoquement imminent et conclut divergent par une classe sous convention, ce que le guide § 7.2 exclut. Deux questions restent ouvertes : la frontière lexicale de « about to strike » comme point (décision 26) et la convention de l'imminent. La référence retient ce que toutes les options affirment : rien.
- **dépendance** (ancrage préparatoire / imminent) — espace (un point d'ancrage pour « about to strike » : décision 26, « reste : la frontière lexicale (« s'apprête », « about to ») comme point de D ») et convention d'évaluation : l'ancrage imminent (décision 26 ; guide § 7.2 ; ONT § 1.2 range la phase préparatoire dans l'en cours)
  - question : « about to strike » laisse-t-il une lecture de phase préparatoire (en cours) à côté de l'imminent ? Et l'imminent compte-t-il comme en cours ?
  - option « point admis, sans convention (A) » : divergent — V (préparatoire) ; F (imminent)
  - option « point admis, avec la convention » : etablie_sous_hypotheses — V (préparatoire) ; V sous convention (imminent)
  - option « imminent seul, sans convention (B sans sa classe sous convention) » : ecartee — F
  - option « imminent seul, avec la convention (B) » : etablie_sous_hypotheses — V sous convention
  - retenu : **inconnue**. Aucun V n'est affirmé par toutes les options (« imminent seul, sans convention » donne ecartee), aucun F non plus (les options avec la convention n'en ont pas). Ce que toutes affirment ne contient ni V ni F : inconnue. B range à tort la convention parmi les lectures (« divergent ») : guide § 7.2.

### ee-009#0

- A : divergent (FV) ; B : divergent (FV)
- **référence : inconnue** (dependance)
- raison : A admet un point d'ancrage (phase préparatoire, le geste engagé, ou imminent) et conclut divergent ; B lit « sur le point de frapper » comme univoquement imminent et conclut divergent par une classe sous convention, ce que le guide § 7.2 exclut. Deux questions restent ouvertes : la frontière lexicale de « sur le point de frapper » comme point (décision 26) et la convention de l'imminent. La référence retient ce que toutes les options affirment : rien.
- **dépendance** (ancrage préparatoire / imminent) — espace (un point d'ancrage pour « sur le point de frapper » : décision 26, « reste : la frontière lexicale (« s'apprête », « about to ») comme point de D ») et convention d'évaluation : l'ancrage imminent (décision 26 ; guide § 7.2 ; ONT § 1.2 range la phase préparatoire dans l'en cours)
  - question : « sur le point de frapper » laisse-t-il une lecture de phase préparatoire (en cours) à côté de l'imminent ? Et l'imminent compte-t-il comme en cours ?
  - option « point admis, sans convention (A) » : divergent — V (préparatoire) ; F (imminent)
  - option « point admis, avec la convention » : etablie_sous_hypotheses — V (préparatoire) ; V sous convention (imminent)
  - option « imminent seul, sans convention (B sans sa classe sous convention) » : ecartee — F
  - option « imminent seul, avec la convention (B) » : etablie_sous_hypotheses — V sous convention
  - retenu : **inconnue**. Aucun V n'est affirmé par toutes les options (« imminent seul, sans convention » donne ecartee), aucun F non plus (les options avec la convention n'en ont pas). Ce que toutes affirment ne contient ni V ni F : inconnue. B range à tort la convention parmi les lectures (« divergent ») : guide § 7.2.

### ee-009#1

- A : divergent (FV) ; B : divergent (FV)
- **référence : inconnue** (dependance)
- raison : A admet un point d'ancrage (phase préparatoire, le geste engagé, ou imminent) et conclut divergent ; B lit « about to strike » comme univoquement imminent et conclut divergent par une classe sous convention, ce que le guide § 7.2 exclut. Deux questions restent ouvertes : la frontière lexicale de « about to strike » comme point (décision 26) et la convention de l'imminent. La référence retient ce que toutes les options affirment : rien.
- **dépendance** (ancrage préparatoire / imminent) — espace (un point d'ancrage pour « about to strike » : décision 26, « reste : la frontière lexicale (« s'apprête », « about to ») comme point de D ») et convention d'évaluation : l'ancrage imminent (décision 26 ; guide § 7.2 ; ONT § 1.2 range la phase préparatoire dans l'en cours)
  - question : « about to strike » laisse-t-il une lecture de phase préparatoire (en cours) à côté de l'imminent ? Et l'imminent compte-t-il comme en cours ?
  - option « point admis, sans convention (A) » : divergent — V (préparatoire) ; F (imminent)
  - option « point admis, avec la convention » : etablie_sous_hypotheses — V (préparatoire) ; V sous convention (imminent)
  - option « imminent seul, sans convention (B sans sa classe sous convention) » : ecartee — F
  - option « imminent seul, avec la convention (B) » : etablie_sous_hypotheses — V sous convention
  - retenu : **inconnue**. Aucun V n'est affirmé par toutes les options (« imminent seul, sans convention » donne ecartee), aucun F non plus (les options avec la convention n'en ont pas). Ce que toutes affirment ne contient ni V ni F : inconnue. B range à tort la convention parmi les lectures (« divergent ») : guide § 7.2.

### ee-009#5

- A : divergent (FV) ; B : divergent (FV)
- **référence : inconnue** (dependance)
- raison : A admet un point d'ancrage (phase préparatoire, le geste engagé, ou imminent) et conclut divergent ; B lit « about to strike » comme univoquement imminent et conclut divergent par une classe sous convention, ce que le guide § 7.2 exclut. Deux questions restent ouvertes : la frontière lexicale de « about to strike » comme point (décision 26) et la convention de l'imminent. La référence retient ce que toutes les options affirment : rien.
- **dépendance** (ancrage préparatoire / imminent) — espace (un point d'ancrage pour « about to strike » : décision 26, « reste : la frontière lexicale (« s'apprête », « about to ») comme point de D ») et convention d'évaluation : l'ancrage imminent (décision 26 ; guide § 7.2 ; ONT § 1.2 range la phase préparatoire dans l'en cours)
  - question : « about to strike » laisse-t-il une lecture de phase préparatoire (en cours) à côté de l'imminent ? Et l'imminent compte-t-il comme en cours ?
  - option « point admis, sans convention (A) » : divergent — V (préparatoire) ; F (imminent)
  - option « point admis, avec la convention » : etablie_sous_hypotheses — V (préparatoire) ; V sous convention (imminent)
  - option « imminent seul, sans convention (B sans sa classe sous convention) » : ecartee — F
  - option « imminent seul, avec la convention (B) » : etablie_sous_hypotheses — V sous convention
  - retenu : **inconnue**. Aucun V n'est affirmé par toutes les options (« imminent seul, sans convention » donne ecartee), aucun F non plus (les options avec la convention n'en ont pas). Ce que toutes affirment ne contient ni V ni F : inconnue. B range à tort la convention parmi les lectures (« divergent ») : guide § 7.2.

### ee-010#4

- A : etablie_sous_hypotheses (V) ; B : inconnue (N)
- **référence : etablie_sous_hypotheses** (adjudication)
- raison : « représente peut-être » est une prémisse graduée de l'auteur : la décision 22 (INTERP § 8.3) en fait une hypothèse d'une sorte propre, non une absence d'information ; la valeur est V sous cette hypothèse (A). B la tient pour N, ce que la décision 22 exclut. La sorte de l'hypothèse reste ouverte (« avec l'abduction ») : elle est notée abduction, avec la mention « prémisse graduée ».

### ee-012#2

- A : etablie_sous_hypotheses (V) ; B : inconnue (N)
- **référence : etablie_sous_hypotheses** (adjudication)
- raison : « Peut-être un baptême » est une prémisse graduée de l'auteur : la décision 22 (INTERP § 8.3) en fait une hypothèse d'une sorte propre, non une absence d'information ; la valeur est V sous cette hypothèse (A). B la tient pour N, ce que la décision 22 exclut. La sorte de l'hypothèse reste ouverte (« avec l'abduction ») : elle est notée abduction, avec la mention « prémisse graduée ». Les deux autres hypothèses sont celles du cas de base.

### ee-013#5

- A : etablie_sous_hypotheses (V) ; B : etablie_sous_hypotheses (V)
- **référence : etablie_sous_hypotheses** (accord)
- raison : Accord de A et B sur le statut et les valeurs ; profil de B. Diffèrent : dimensions. B pose le point de « apparently » (décision 22) ; A une abduction. Mêmes valeurs.

### ee-013#7

- A : non_certifiee (NV) ; B : etablie_sous_hypotheses (V)
- **référence : non_certifiee** (adjudication)
- raison : Une abduction explique une observation, c'est-à-dire une assertion admissible de l'auteur dans le chemin figuré (décision 24). Ici l'auteur ne pose que les voyageurs et l'inconnu ; la ville et le but ne sont que dans l'inventaire cité. L'abduction du cas de base n'a donc plus d'observation (contre B) : la valeur ne vient que de la source, non_certifiee (A).

### ee-016#5

- A : etablie_sous_hypotheses (V) ; B : etablie_sous_hypotheses (V)
- **référence : etablie_sous_hypotheses** (accord)
- raison : Accord de A et B sur le statut et les valeurs ; profil de A. Diffèrent : natures. A tient « peut-être gaulois » pour une prémisse graduée (décision 22) ; B fonde la même valeur sur une connaissance typique (le torque). Deux explications concurrentes de la même classe (décision 23) ; mêmes valeurs.

### ee-018#4

- A : ecartee (F) ; B : inconnue (N)
- **référence : inconnue** (dependance)
- raison : Inversion des rôles entre les mêmes participants ; le F de A demande une asymétrie que la décision 9 ne tient pas encore pour attestée. Dépendance.
- **dépendance** (inversion de rôles) — K : asymétrie d'une relation entre les mêmes participants (décision 9 : une inversion n'est négative que par une asymétrie attestée ; la liste des relations asymétriques reste à faire)
  - question : « An old man carries a young man on his shoulders » réfute-t-il « a man carrying an old man on his shoulders » ? « Porter sur ses épaules » est-il asymétrique entre les mêmes personnes au même moment (et « young » exclut-il « old » pour le porté, décision 30) ?
  - option « porter est asymétrique et le porté, jeune, n'est pas vieux : F pour les référents cités (A) » : ecartee
  - option « aucune asymétrie attestée : l'homme portant un vieillard n'est ni dit ni nié (B) » : inconnue
  - retenu : **inconnue**. L'option « aucune asymétrie attestée » n'affirme ni V ni F ; l'autre affirme un F qu'elle n'affirme pas. La référence retient la plus prudente : inconnue.

### ee-018#5

- A : ecartee (F) ; B : inconnue (N)
- **référence : ecartee** (adjudication)
- raison : « The ruins of the city are described only in the inscription on the back » est une quantification dite (« only ») : les ruines ne sont données que par le texte du revers, donc pas par la figuration de la face (guide § 3 ; INTERP § 6.4). B le reconnaît (« non figurées ») mais conclut N ; c'est un F fondé sur une quantification, non sur un silence. L'inscription, contexte de texte, ne satisfait rien.

### ee-023

- A : etablie (V) ; B : etablie (V)
- **référence : inconnue** (accord)
- satisfaction contextuelle : « principal > tapisserie figurée au mur du fond » : etablie
- raison : Accord de A et B sur le statut et les valeurs ; profil de A. Diffèrent : contextes. Précision 1.1 (1) : « principal > tapisserie figurée au mur du fond » (etablie) va dans satisfactions_contextuelles ; le statut se lit sur le contexte principal. Le statut commun « etablie » devient « inconnue » : une satisfaction dans un autre contexte ne donne pas son statut à l'œuvre (retenir la notation reste une décision documentaire).

### ee-023#0

- A : etablie (V) ; B : etablie (V)
- **référence : inconnue** (accord)
- satisfaction contextuelle : « principal > tapisserie figurée au mur du fond » : etablie
- raison : Accord de A et B sur le statut et les valeurs ; profil de A. Diffèrent : contextes. Précision 1.1 (1) : « principal > tapisserie figurée au mur du fond » (etablie) va dans satisfactions_contextuelles ; le statut se lit sur le contexte principal. Le statut commun « etablie » devient « inconnue » : une satisfaction dans un autre contexte ne donne pas son statut à l'œuvre (retenir la notation reste une décision documentaire).

### ee-023#1

- A : etablie (V) ; B : etablie (V)
- **référence : inconnue** (accord)
- satisfaction contextuelle : « principal > tapisserie figurée au mur du fond » : etablie
- raison : Accord de A et B sur le statut et les valeurs ; profil de A. Diffèrent : contextes. Précision 1.1 (1) : « principal > tapisserie figurée au mur du fond » (etablie) va dans satisfactions_contextuelles ; le statut se lit sur le contexte principal. Le statut commun « etablie » devient « inconnue » : une satisfaction dans un autre contexte ne donne pas son statut à l'œuvre (retenir la notation reste une décision documentaire).

### ee-023#3

- A : ecartee (F) ; B : inconnue (N)
- **référence : inconnue** (dependance)
- satisfaction contextuelle : « principal > tapisserie figurée au mur du fond » : inconnue
- raison : Précision 1.1 (1) : la scène n'est que dans la tapisserie figurée ; le contexte principal ne satisfait rien (N, inconnue) et la tapisserie va dans satisfactions_contextuelles. Dans ce contexte, inversion des rôles avec le même objet : dépendance, inconnue retenu.
- **dépendance** (inversion de rôles) — K : asymétrie d'une relation entre les mêmes participants (décision 9 : une inversion n'est négative que par une asymétrie attestée ; la liste des relations asymétriques reste à faire)
  - question : Dans la tapisserie figurée, « one of three goddesses handing an apple to a shepherd » réfute-t-il « a shepherd giving an apple to one of three goddesses » ?
  - option « le don d'une même pomme a une direction unique : F dans la tapisserie (A) » : ecartee
  - option « aucune asymétrie attestée : le don du berger n'est ni dit ni nié (B) » : inconnue
  - retenu : **inconnue**. L'option « aucune asymétrie attestée » n'affirme ni V ni F ; l'autre affirme un F qu'elle n'affirme pas. La référence retient la plus prudente : inconnue.

### ee-023#4

- A : etablie (V) ; B : etablie (V)
- **référence : inconnue** (accord)
- satisfaction contextuelle : « principal > tapisserie figurée au mur du fond » : etablie
- raison : Accord de A et B sur le statut et les valeurs ; profil de A. Diffèrent : contextes. Précision 1.1 (1) : « principal > tapisserie figurée au mur du fond » (etablie) va dans satisfactions_contextuelles ; le statut se lit sur le contexte principal. Le statut commun « etablie » devient « inconnue » : une satisfaction dans un autre contexte ne donne pas son statut à l'œuvre (retenir la notation reste une décision documentaire).

### ee-023#5

- A : etablie_sous_hypotheses (V) ; B : inconnue (N)
- **référence : inconnue** (adjudication)
- satisfaction contextuelle : « principal > tapisserie figurée au mur du fond » : etablie_sous_hypotheses
- raison : Précision 1.1 (1) : le contexte principal ne satisfait rien (inconnue). Dans la tapisserie, « may show » est une prémisse graduée (décision 22) : V sous cette hypothèse et sous l'identification iconographique qui donne les trois déesses (A) ; le N de B ne repose que sur la réserve modale.

## Les accords corrigés par la précision 1.1 (hors liste de la comparaison)

- **ee-014#3** : statut commun « divergent » → **ecartee** ; « principal > état d'origine » : etablie

## Les statuts de référence des cas de base

| cas | statut de référence | source |
|---|---|---|
| ee-001 | etablie | accord |
| ee-002 | etablie | accord |
| ee-003 | ecartee | accord |
| ee-004 | etablie_sous_hypotheses | accord |
| ee-005 | etablie | accord |
| ee-006 | etablie | accord |
| ee-007 | etablie | accord |
| ee-008 | etablie_sous_hypotheses | dependance |
| ee-009 | inconnue | dependance |
| ee-010 | etablie | accord |
| ee-011 | divergent | accord |
| ee-012 | etablie_sous_hypotheses | accord |
| ee-013 | etablie_sous_hypotheses | accord |
| ee-014 | etablie | accord |
| ee-015 | etablie_sous_hypotheses | accord |
| ee-016 | etablie | accord |
| ee-017 | ecartee | accord |
| ee-018 | etablie | accord |
| ee-019 | inconnue | accord |
| ee-020 | ecartee | accord |
| ee-021 | non_certifiee | accord |
| ee-022 | etablie | accord |
| ee-023 | inconnue | accord |
| ee-024 | ecartee | accord |
