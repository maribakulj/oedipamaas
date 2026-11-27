# L'expérience croisée : graphes × requêtes (27/11)

La question posée par la propriétaire, le 27/11 : de ce qui manque au codage, quelle part revient au lecteur (C6/C7),
au compilateur des libellés (C3), aux connaissances (K) et au raisonnement iconographique ? Sur les 40 textes positifs
du développement, 16 notations sont non prises en charge, 18 partielles et 6 compilées ; sur ces 6, 2 sont
établissables.

## 1. Le protocole

- **Quatre conditions,** pour chaque texte : un graphe et une requête.
  - Le graphe vient du lecteur (`outils/graphes/lire.pl`) ou du banc de référence (`docs/BANC_GRAPHES.md`, mis en
    assertions par `outils/graphes/vers_faits.py`).
  - La requête est compilée du libellé (`outils/requetes/compiler_vertical.pl`) ou c'est la requête de référence
    écrite à la main (`requetes_reference.json` de chaque jeu).
  - Les conditions s'appellent `lecteur_compilee`, `lecteur_reference`, `reference_compilee` et
    `reference_reference`.
- **Ce qui est commun aux quatre :** le même noyau (main après les lots 1 à 6), les mêmes connaissances K, les mêmes
  textes (une fiche sur cinq de chaque jeu), les mêmes budgets (celui du noyau par requête, et 10⁹ inférences par
  condition). Aucune normalisation n'est appliquée.
- **Deux mesures séparées :**
  - la **satisfaction** : le statut que le noyau donne à la condition suffisante de la notation visée (`etablie`,
    `etablie_sous_hypotheses`, `ecartee`, `inconnue`…), avec ses atomes satisfaits et manquants ;
  - la **qualification** : le statut du code par la règle du codage (`codage.pl`, `statut/9`). Une requête de
    référence y est traitée comme une requête compilée de la famille `reference`, jamais justifiée : elle donne au
    mieux `etablissable`, jamais `etabli`.
- **Un échec** de la condition (graphe de référence, requête de référence) est un texte positif dont la condition
  suffisante n'est pas établie (même sous hypothèses), ou un texte négatif dont elle l'est.
- **La cause de chaque échec** a été décidée cas par cas (§ 4), d'après les atomes manquants, le graphe de référence et
  ce que K sait de chaque mot (`outils/croise/sonder.pl`).

## 2. Les résultats

Satisfaction de la condition suffisante, sur les 40 textes positifs de chaque jeu :

| jeu | condition | établie | sous hypothèses | écartée | inconnue | sans requête |
|---|---|---|---|---|---|---|
| développement | lecteur, compilée | 2 | 0 | 0 | 23 | 15 |
| développement | lecteur, référence | 3 | 1 | 0 | 35 | 1 |
| développement | référence, compilée | 2 | 0 | 0 | 23 | 15 |
| développement | référence, référence | 5 | 0 | 0 | 34 | 1 |
| validation M1 | lecteur, compilée | 1 | 1 | 0 | 26 | 12 |
| validation M1 | lecteur, référence | 0 | 2 | 0 | 38 | 0 |
| validation M1 | référence, compilée | 0 | 1 | 1 | 26 | 12 |
| validation M1 | référence, référence | 0 | 1 | 0 | 39 | 0 |

Qualification, sur les mêmes textes :

- **établissable :** 2, 3, 2 et 5 en développement ; 0 en validation.
- **conditionnel** (établie sous hypothèses de sens, non exploitable automatiquement) : 1 en développement (lecteur,
  référence) ; 1, 2, 1 et 1 en validation.
- **Autres statuts en validation :**
  - `candidat` 1 (lecteur, compilée : 46B355, voir § 3) ;
  - `suffisante_ecartee` 1 (référence, compilée : 11H(QUINTIN)0, voir § 3).

**Négatifs.**

- Développement : aucun n'est établi, dans aucune condition.
- Validation : un seul, 44G83, est établi sous hypothèse (libérer → délivrer) dans les quatre conditions, donc
  qualifié `conditionnel`. C'est une erreur de la fiche, non du moteur (§ 4).

**Variantes (validation, 84 textes).** Une seule variante est établie : 47G3355, variante de négation, dans la
condition lecteur et requête compilée, qualifiée `etablissable`.

- C'est une faute de sûreté du lecteur. Le texte dit « not of the upholstering itself », et le lecteur lit
  `upholstering` comme affirmé.
- Sur le graphe de référence, la même requête est `ecartee`, ce qui est juste.

## 3. L'attribution

> Les tableaux de ce § et des §§ 2 et 4 sont ceux de la version 1 du banc et de la définition v1 des échecs
> (`tableaux.py --definition v1` les reproduit). La version 2, la séparation des conclusions déductives et des
> conclusions sous hypothèses, et la complétude sont au § 10.

Sur les textes positifs, on compare les conditions deux à deux :

| | développement | validation M1 |
|---|---|---|
| établies par (référence, référence) | 5 | 1 (47C35, sous hypothèse) |
| le lecteur en perd (lecteur, référence) | 1 : 11H(CASSIAN)32 | 0 |
| le lecteur en gagne | 0 | 1 : 41C67 (sous hypothèse gravy → sauce, parce que le lecteur coupe « gravy boat ») |
| le lecteur, sous hypothèse seulement | 1 : 11HH(LIDWYNA)12, sur sit → study, un sens faux | 0 |
| sans requête compilée | 15 | 12 |
| le compilateur en perd (référence, compilée) | 3 : 11H(CASSIAN)32, 11HH(LIDWYNA)12, 42A111 | 1 : 47C35 |
| le compilateur en gagne | 0 | 1 : 46B355 (fortuit, voir plus bas) |
| échecs de (référence, référence) | 34 | 39 |

**La conclusion de cette expérience.** La limite n'est ni le lecteur ni le compilateur. Même avec le graphe de
référence et la requête écrite à la main, la notation visée n'est établie que pour 5 positifs sur 40 en développement
et pour 1 sur 40 en validation.

- Les parts du lecteur et du compilateur ne peuvent donc pas être mesurées ici au-delà de ce plafond. Elles sont
  bornées par lui : 1 perte du lecteur, 3 et 1 pertes du compilateur, et les 15 et 12 notations sans requête.
- Ce qui manque est au point de rencontre entre la description et le libellé : la représentation commune, les
  connaissances lexicales et l'inférence (§ 4).

**Les succès fortuits du compilateur.** Ils ne comptent pas comme des gains.

- **46B355 :**
  - le compilateur coupe « trade card » en `type(x, trade) ∧ type(y, card)`, deux variables sans lien entre elles ;
  - sur le graphe du lecteur, `trade` vient de « ephemera of trade », et la requête est établie : c'est un succès sans
    raison ;
  - sur le graphe de référence, elle n'est établie que sous l'hypothèse fausse address → sign.
- **11H(QUINTIN)0, écartée :**
  - la requête compilée exige « martyr of Vermand » et des attributs du libellé ;
  - la relation `of` de « companion of Quentin » appuie `relation(martyr, of, Vermand)` ;
  - la substitution est alors fausse par `meme` et `distincts`.
  - La portée est cette substitution seulement (D31). `suffisante_ecartee` ne réfute pas la notation (D54) : le noyau
    fait ce qu'il dit.

## 4. Les causes des échecs de (graphe de référence, requête de référence)

Six causes, définies avant la décision :

- **représentation** (`representation`) : le texte et le libellé disent la même chose sous deux formes que la
  canonisation commune ne rapproche pas. Exemples : un nom contre un événement (death / die), une propriété contre un
  nom (chauve / calvitie), un rôle contre une relation, un événement porté par un autre (« proclame que ce lieu
  s'appellera »), une personnification en femme allégorique contre `type(personification) ∧ nom`.
- **lexique** (`lexique`) : un mot ou un lien manque dans K. Exemples : un composé sans concept (« parish church »,
  « faire sortir », « trade card »), un co-hyponyme (splint / brace), la similarité des adjectifs (acariâtre /
  mauvais), un alias.
- **désambiguïsation** (`desambiguisation`) : le sens ou le référent ne se décide que par le contexte. Exemples :
  testicule → organe sexuel seulement possible sous D30 ; « Jean » est-il Jean-Baptiste ? « Antoine » est-il Antoine
  abbé ? « plante » est-elle celle du pied ?
- **inférence contextuelle** (`inference`) : le texte décrit sans nommer, et le libellé nomme. Exemples : « un liquide
  doré pressé d'olives » pour huile, « l'organe de l'odorat » pour nez, un être mi-homme mi-serpent pour monstre,
  « le sommet du crâne rasé en couronne » pour tonsure. C'est le raisonnement iconographique.
- **limite du noyau** (`noyau`) : le graphe et la requête sont compatibles et K suffit, mais le noyau ne conclut pas.
- **erreur de référence** (`erreur_reference`) : le graphe, la requête de référence ou la fiche sont faux. Exemples :
  une requête en français pour un texte anglais, un nom à remplir resté `A_REMPLIR`, un négatif que le libellé couvre.

Chaque échec reçoit sa ou ses causes, la principale en premier, avec sa raison. La liste est dans
`croise/causes_ref_ref.json` sur la branche de données. Ce sont les décisions d'un agent : **provisoires tant
qu'une personne ne les a pas validées**.

| | développement (34) | validation M1 (40) | total (74) |
|---|---|---|---|
| représentation : principale / présente | 18 / 27 | 11 / 23 | 29 / 50 |
| inférence contextuelle | 11 / 17 | 17 / 24 | 28 / 41 |
| lexique | 4 / 14 | 7 / 17 | 11 / 31 |
| erreur de référence | 1 / 3 | 4 / 5 | 5 / 8 |
| désambiguïsation | 0 / 1 | 1 / 6 | 1 / 7 |
| limite du noyau | 0 / 0 | 0 / 0 | 0 / 0 |

- **Aucun échec n'est dû au noyau.** Chaque fois que le graphe et la requête se rencontrent, la conclusion suit.
- **La représentation domine en développement, l'inférence en validation.** Les textes de validation sont écrits pour
  décrire sans nommer.
- **Les erreurs de référence :**
  - 46B910 : une personnification portée par une entité citée ;
  - 48A9834 : une plante niée là où la requête la veut affirmée ;
  - 46E43(ROCKET) : un composé sans concept gardé en un seul mot, contre le guide ;
  - 31A4623(...) et 48C7326(...) : des requêtes de référence restées `A_REMPLIR` ;
  - 46B3312 : une requête de référence en français pour un texte anglais ;
  - 71A423 : « se tiennent debout » lemmatisé en `tenir`, sans son pronom ;
  - le négatif de 44G83, que le libellé « délivrer un prisonnier » couvre.
  - Ces erreurs sont à corriger dans le banc et les requêtes, après validation.
- **Les alias de noms propres** (« Judas », « Jean », « Antoine », « Ignatius », « Vierge ») sont comptés en
  désambiguïsation : un nom partiel ne désigne le saint que par le contexte.

## 5. Les quatre notations demandées

- **31A22361 (organes sexuels masculins).** Causes : lexique, représentation, désambiguïsation.
  - Compilateur : il écrit `et([type(x, organes), propriete(x, sexuel), propriete(x, mâle)])`. Le lemme est au
    pluriel (« organes »), et le composé est coupé alors que WOLF a le concept « organe sexuel ».
  - Graphe de référence :
    - « appareil génital » a 0 concept ;
    - pénis n'a pas de lien vers organe sexuel ;
    - testicule → organe sexuel n'est que possible (D30) ;
    - masculin → mâle est possible.
  - « Masculin » porte sur le tout (l'appareil génital), et le type n'est atteint que par une partie (testicule) : la
    conjonction échoue.
- **31A3333 (espace parfumé).** Causes : inférence, lexique.
  - La requête compilée et la requête de référence sont toutes deux `type(x, space) ∧ propriete(x, fragrant)`.
  - pavilion atteint structure, pas space.
  - perfumed n'atteint pas fragrant : la similarité des adjectifs n'est pas dans K.
  - Le parfum est porté par la fumée et la senteur, non par l'espace.
- **46E43(ROCKET).** Causes : erreur de référence, représentation, et deux défauts du compilateur.
  - Compilateur :
    - un `ou` des mots de rocket inclut « eruca sativa » (la roquette, une erreur de sens) ;
    - le gabarit du parent, `ou(feu, fumée, lumière, moyen)`, est conjoint sur la même variable x.
  - Graphe de référence : « fusée de signalisation » est gardée en un seul mot, sans concept ; c'est une mauvaise
    application du guide.
  - La fonction de signal est dans le composé, alors que la requête veut un événement et son instrument.
  - Le graphe du lecteur a « fusée » ; seuls signaler et son rôle y manquent.
- **44G31 (emprisonnement).** Causes : inférence, représentation, lexique.
  - La requête compilée dit `type(x, imprisonment)`, la requête de référence `evenement(e, imprison)`. La
    canonisation du côté des libellés n'est pas cohérente.
  - Le graphe a prisoner, chains, dungeon cell et jailer, mais pas d'imprison. Il manque la dérivation
    prisoner ↔ imprison.

## 6. Ce que l'expérience demande à C3

La propriétaire l'a décidé le 27/11 : le compilateur est une piste prioritaire, menée en parallèle du lecteur. Il
n'attend pas C7. Les défauts relevés ici, chacun avec son contre-exemple :

1. **Les énumérations du libellé compilées en conjonction** au lieu d'une disjonction : 47C35 « planing, filing,
   abrading », et la liste « schoolmaster, martyr, bishop » de 11H(CASSIAN)32.
2. **Les noms d'action et les gérondifs compilés en types**, là où la référence veut un événement : upholstering
   (47G3355), imprisonment (44G31), filing (47C35).
3. **Les composés coupés en variables sans lien :**
   - « trade card » (46B355, succès fortuit) ;
   - « contrôle des naissances » (42A111) ;
   - « organe sexuel », dont WOLF a le concept (31A22361).
4. **Les lemmes au pluriel :** « organes » (31A22361).
5. **Les sens faux :** « eruca sativa » pour rocket (46E43(ROCKET)).
6. **Le gabarit du parent conjoint sur la même variable** (46E43(ROCKET)).
7. **Les participes et les compléments de matière :** « made » devient `propriete(make)`, et « of brass » devient
   `type(brass)` plus une relation `of` (71E3242).
8. **La glose descriptive d'un saint dans la condition suffisante :** « martyr of Vermand » et les attributs possibles
   (11H(QUINTIN)0, 11H(CASSIAN)32). Leur place est la condition nécessaire, ou rien.

Les points 2, 3 et 7 relèvent de la canonisation commune, qui reste l'hypothèse principale. Une forme canonique doit
être la même des deux côtés ; le guide du banc est la référence.

## 7. Ce que l'expérience demande au reste

- **Représentation** (50 échecs sur 74 la comptent) : c'est la canonisation commune. Ces cas en sont les
  contre-exemples :
  - les noms d'action et les événements ;
  - les propriétés et les noms d'état (chauve / calvitie, insincérité) ;
  - les compléments de nom d'action (« la clôture de la séance ») ;
  - les verbes de parole qui portent l'événement (« proclame que ce lieu s'appellera ») ;
  - les réciproques (« s'appuient les unes contre les autres ») ;
  - les personnifications.
- **Inférence contextuelle** (41 sur 74) : c'est le raisonnement iconographique. Il doit rester une proposition
  hypothétique, jamais une assertion du texte. Ce qui n'est pas dit n'est pas affirmé, et le statut des codes ainsi
  obtenus doit le montrer.
- **Lexique** (31 sur 74) :
  - les composés sans concept et les alias de noms propres ;
  - la similarité des adjectifs, qui n'est pas dans K ;
  - les co-hyponymes, qui ne sont pas des synonymes et ne doivent pas le devenir.
- **Désambiguïsation** (7 sur 74) : surtout des noms propres partiels.

## 8. Limites

- **Peu de cas :** 40 positifs par jeu et une fiche par texte. Aucun intervalle n'est donné, parce que les effets du
  lecteur et du compilateur se comptent sur les doigts d'une main.
- **Les causes sont décidées par un agent,** à partir des graphes et des sondes de K : elles sont provisoires.
- **Le banc de référence reste un accord entre agents,** sans validation humaine (`docs/BANC_GRAPHES.md`).
- **Les requêtes de référence ont leurs propres erreurs** (§ 4), qui n'ont pas été corrigées avant la mesure : elles y
  sont comptées.

## 9. La reproduction

Les données sont sur la branche `donnees/banc-graphes`, dans `banc_graphes/`, `reference_d30/` et `croise/`. Pour
chaque JEU (`vertical`, `validation_m1`) :

```bash
swipl outils/croise/croiser.pl BASE banc_graphes/lecteur_JEU.json banc_graphes/faits_reference_JEU.json \
  reference_d30/compilees_JEU.json JEU/requetes_reference.json JEU/fiches.json croise/croise_JEU.json
```

```bash
python outils/croise/diagnostiquer.py croise/croise_JEU.json banc_graphes/reference_JEU.json \
  JEU/requetes_reference.json --json croise/echecs_ref_ref_JEU.json
```

```bash
swipl outils/croise/sonder.pl BASE croise/echecs_ref_ref_JEU.json banc_graphes/faits_reference_JEU.json \
  croise/sonde_JEU.json
```

```bash
python outils/croise/classer.py croise/echecs_ref_ref_JEU.json croise/sonde_JEU.json --json croise/classes_JEU.json
```

Puis, une fois les causes décidées :

```bash
python outils/croise/tableaux.py croise/causes_ref_ref.json vertical=croise/croise_vertical.json \
  validation_m1=croise/croise_validation_m1.json --definition v1 --json croise/tableaux.json
```

`tableaux.py` refuse d'écrire si un échec n'a pas de cause, si une cause n'a pas d'échec, ou si une cause est mal
formée (`tests/test_croise.py`).

## 10. La version 2 du banc, et des conclusions séparées

Les demandes du 27/11 (second message) :
- séparer les conclusions établies déductivement des conclusions sous hypothèses ;
- garder les indicateurs de complétude, en distinguant les requêtes absentes, les erreurs, les interruptions et les
  vrais échecs sémantiques ;
- corriger les erreurs manifestes des références dans une nouvelle version du banc, sans toucher aux anciennes mesures ;
- ne pas tenir les diagnostics pour validés.

**Les issues** (`outils/croise/tableaux.py`). Chaque texte reçoit une seule issue par condition.
- **Non évaluées :**
  - `requete_absente` ;
  - `gabarit_non_instancie` : une notation « (...) » dont la clé du nom reste `A_REMPLIR` ;
  - `conteste` : retiré par un erratum ;
  - `graphe_en_erreur`, `erreur`, `interrompue` (la limite d'inférences de la condition) et `incomplete` (le budget du
    noyau).
- **Évaluées :** `etablie` (déductivement), `etablie_sous_hypotheses`, `ecartee`, `non_certifiee`, `contradictoire`
  et `inconnue`.

Dans cette expérience, aucune erreur, aucune interruption et aucun budget épuisé ne se produisent : les tableaux le
montrent par des zéros, et non par leur absence. Les graphes que la validation des assertions signale sont comptés à
part ; ils sont quand même évalués.

**La définition v2 d'un échec,** la seule utilisée depuis :
- un positif évalué dont la suffisante n'est pas établie **déductivement**. Une conclusion seulement sous hypothèses
  est un échec de la déduction, compté à part ;
- un négatif évalué dont la suffisante est établie.

La v1 reste reproductible (`--definition v1`).

**La version 2 du banc** (`outils/graphes/version_banc.py`, `banc_graphes/v2/errata.json`). Dix errata, chacun avec sa
valeur avant, sa valeur après et sa raison. Le contrôle refuse un erratum qui ne s'applique pas exactement.
- **E1 à E8 :** « se tenir » lemmatisé `tenir` dans huit événements de deux fiches (31A46331 et 71A423).
- **E9 :** la requête de référence de 46B3312, écrite en français pour une fiche anglaise, est traduite mot pour mot.
- **E10 :** le négatif de 44G83 est contesté, parce que le libellé le couvre.
- **Ce qui n'est pas corrigé,** faute d'être manifeste, et attend votre décision (liste dans l'errata) :
  - 14 prédicats pronominaux passifs ou réfléchis ;
  - « fusée de signalisation » ;
  - 46B910 et 48A9834.
  - Les gabarits `A_REMPLIR` sont une convention, non une erreur : ils deviennent `gabarit_non_instancie`.
- **Une erreur de conversion, trouvée en chemin.** `vers_faits.py` retirait le pronom de tous les prédicats
  pronominaux (65 dans les références), comme le comparateur le fait pour comparer. Or K distingue « se tenir »
  (2 sens) de « tenir » (52, dont avoir en main).
  - La conversion garde maintenant le pronom ; `--pronoms retirer` reproduit les assertions de la v1.
  - Le lecteur n'écrit jamais le pronom : c'est une question de canonisation commune, à trancher des deux côtés (§ 11).

**Les mesures.** Trois passes, sur les mêmes graphes du lecteur et les mêmes requêtes compilées :
1. la v1 ;
2. la v1 avec les pronoms gardés ;
3. la v2.

- **Aucune issue ne change, ni aucune qualification, dans aucune condition, sur aucun jeu.**
  - 46B3312 corrigée trouve son type et son événement, mais l'événement weigh() n'a pas de participant.
  - 71A423 échoue encore : aucun patient de « tenir ».
- **Le plafond n'est donc pas un artefact des erreurs manifestes.**

**L'attribution v2** (positifs ; trois niveaux : déductive, sous hypothèses, non établie) :

| | développement | validation M1 |
|---|---|---|
| (référence, référence) | 5 déductives, 34 inconnues, 1 requête absente | 0 déductive, 1 sous hypothèses (47C35), 37 inconnues, 2 gabarits non instanciés |
| le lecteur perd la déduction | 2 : 11H(CASSIAN)32 (non établie), 11HH(LIDWYNA)12 (sous l'hypothèse sit → study, un sens faux) | 0 |
| le lecteur gagne | 0 déduction | 1 sous hypothèses : 41C67 (gravy → sauce) |
| le compilateur perd la déduction | 2 : 11H(CASSIAN)32, 42A111 | 0 ; 47C35 passe de sous hypothèses à non établie |
| le compilateur gagne | 0 déduction | 1 sous hypothèses : 46B355 (fortuit, § 3) |
| requêtes compilées absentes (non évaluées) | 15 | 12 |

Dans aucune des deux conditions croisées, une conclusion n'est gagnée **déductivement**. Les seuls gains sont sous
hypothèses de sens, et l'un d'eux est fortuit.

**Les causes v2** (`croise/v2/causes_ref_ref_v2.json`). Les 72 échecs sont ceux de la v1, à trois changements près :
- deux gabarits et le négatif contesté quittent le compte ;
- 47C35, établie sous hypothèse, y entre (désambiguïsation) ;
- le diagnostic de 46B3312 est refait après sa correction (représentation, inférence).

Les causes principales :
- développement (34) : représentation 18, inférence 11, lexique 4, erreur de référence 1 ;
- validation (38) : inférence 17, représentation 12, lexique 7, désambiguïsation 2.

**Le statut des diagnostics.** Les 74 diagnostics de la v1, comme les 72 de la v2, sont des décisions d'agent : chacun
porte le statut `decision_d_agent_provisoire`, et aucun n'est validé. Ils servent à orienter l'expérience contrôlée
(§ 11), non à conclure.

**Ce que « aucune cause noyau » ne dit pas.** Qu'aucun échec ne soit attribué au noyau ne démontre pas que son
expressivité suffit au raisonnement iconographique. Cela dit seulement que, dans ces 72 cas, les échecs surviennent
avant le noyau : le graphe et la requête ne se rencontrent pas. Ce que le noyau devra exprimer (des hypothèses
abductives distinctes des assertions, des conséquences d'événements, des états) se mesure dans l'expérience contrôlée.

Reproduction (BASE la base compilée, B le banc, D les données) :

```bash
python outils/graphes/version_banc.py B/v2/errata.json B/v2 \
  vertical=B/reference_vertical.json,D/vertical/requetes_reference.json \
  validation_m1=B/reference_validation_m1.json,D/validation_m1/requetes_reference.json
```

```bash
python outils/graphes/vers_faits.py B/v2/reference_JEU_v2.json B/v2/faits_reference_JEU_v2.json
```

```bash
swipl outils/croise/croiser.pl BASE B/lecteur_JEU.json B/v2/faits_reference_JEU_v2.json \
  reference_d30/compilees_JEU.json B/v2/requetes_reference_JEU_v2.json D/JEU/fiches.json croise/v2/croise_v2_JEU.json
```

```bash
python outils/croise/tableaux.py croise/v2/causes_ref_ref_v2.json vertical=croise/v2/croise_v2_vertical.json \
  validation_m1=croise/v2/croise_v2_validation_m1.json --errata B/v2/errata.json --json croise/v2/tableaux_v2.json
```
