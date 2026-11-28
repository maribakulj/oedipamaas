# Questions ouvertes : modalités, alternatives, négation, contextes (cas mn-001 à mn-024)

Ce fichier liste les points où les documents sont muets, ambigus ou se contredisent. Je les ai rencontrés en écrivant
les cas de développement de la famille. Chaque point donne les cas concernés. Rien n'est tranché ici : quand un cas
en dépend, il porte une `decision_ouverte`, et son statut attendu est l'option la plus prudente.

## 1. Les prémisses graduées : aucune sorte d'hypothèse ne les représente (mn-001, mn-002, mn-003)

- AUDIT § 3.6 (5) dit que `probable` et `traditionnel` « pourraient fonder une conclusion sous hypothèse », grâce à une
  opération qui reste à créer. FONDEMENTS § 5 cite la « prémisse graduée » parmi les sortes d'hypothèses.
- Mais la liste fermée des `hypotheses_attendues` du protocole (§ 4) n'en a pas. Un cas qui choisirait l'option
  « prémisse graduée admise » ne pourrait donc pas écrire son hypothèse.
- **La question :** l'opération est-elle voulue ? Si oui, il faut ajouter la sorte d'hypothèse au protocole et au
  validateur.
- **Ce que font les cas :** ils retiennent `inconnue`, et leur `decision_ouverte` donne `etablie_sous_hypotheses` comme
  autre option.

## 2. « Semble » : une modalité, ou l'apparence de ce qui est figuré ? (mn-002, mn-014)

- ASSERTIONS donne les modalités `probable` et `possible`, mais ne dit pas à laquelle « semble », « appears »,
  « paraît » appartiennent.
- Dans une description d'œuvre, « elle semble pleurer » peut aussi décrire ce que l'image montre : une femme qui a l'air
  de pleurer. Ce serait alors une assertion affirmée sur une apparence.
- **La question :** les documents ne choisissent pas entre ces lectures. Selon la lecture retenue, le statut est
  `inconnue`, `etablie_sous_hypotheses` ou `etablie` (mn-002).

## 3. La réfutation d'une description niée sans autre événement (D41) (mn-005, mn-017, et des variantes de mn-002, mn-006, mn-018)

- « Le Christ ne couronne pas sa mère » face à la définition « Christ crowning the Virgin ».
- NOYAU § 1.1 dit que cette réfutation est saine, mais que le noyau 0.3 ne la dérive pas (D41, une perte dans le sens
  sûr). FONDEMENTS § 1.1 dit qu'elle est fausse dans v_D.
- **Ce que font les cas :** j'ai écrit `ecartee`, d'après la sémantique cible. Le moteur actuel rendra `inconnue` :
  c'est un défaut de couverture, non de sûreté.
- **La question :** confirmer que la cible est bien `ecartee`, et non ce que le noyau sait dériver. Il faut aussi dire
  quelle phase doit lever D41 : aucune opération ni extension de la liste ne la nomme. Ces cas ont donc
  `extensions_requises: aucune`, alors qu'ils exigent un changement du noyau.
- **Un cas voisin :** un événement nié **sans patient** (« he does not bless ») nie toute bénédiction de cet agent, selon
  la lecture la plus prudente du tableau du § 1.1. Pour un verbe transitif employé sans objet (« il ne bénit pas »),
  faut-il le lire comme un événement sans rôle de patient, ou comme un patient implicite ? Cela décide de la portée de
  la négation (mn-017).

## 4. La négation et la polysémie : la négation d'un mot polysémique ne réfute rien (mn-004, et toutes les négations)

- Le protocole demande une hypothèse de sens seulement si le texte laisse les sens ouverts.
- Mais NOYAU § 2 (D30) demande davantage pour qu'une négation soit **certaine** : que le nœud demandé soit inclus dans
  **chaque** sens du mot nié. « No angels » a quatre sens dans WordNet (l'être spirituel, la personne d'une grande
  sainteté, le bailleur de fonds, la cascade). La négation n'est donc que possible, et elle ne réfute rien.
- **Ce que font les cas :** j'ai supposé que la lecture (la désambiguïsation) fixe le sens, et j'ai écrit `ecartee`.
- **La question :** la sémantique cible évalue-t-elle sur le sens choisi par la lecture, ou sur tous les sens de K ? Si
  c'est sur tous les sens, presque aucun cas négatif n'est `ecartee`. Le même problème touche les liens positifs :
  « king » a des sens d'artefact, d'où une hypothèse de sens que je n'ai pas écrite (mn-021).

## 5. Le nom de l'extension `non/1` est introuvable : la seule erreur restante du validateur (mn-016)

- mn-016 demande que le texte **dise** l'absence d'auréole de l'Enfant. C'est l'extension `non/1` de l'audit (§ 3.6 (4)).
- J'ai essayé `non_dans_les_requetes`, `non`, `non_1` et `negation_requete` : le validateur les refuse tous.
- La liste des extensions n'est écrite dans aucun document que j'ai le droit de lire. Le protocole renvoie à « la liste
  du validateur », dont je ne dois pas lire le code.
- **La question :** quel est l'identifiant exact ? Il faut aussi publier la liste des extensions et celle des variations
  dans `docs/BANCS_PHASE1.md`. J'ai dû trouver par essai et erreur que `ajout_figure_non_liee` est accepté et
  `ajout_d_une_figure_non_liee` refusé.

## 6. Les contextes de contenu n'ont pas d'extension propre (mn-011, mn-021, mn-022)

- `contextes_emboites` et `contextes_de_contenu` sont refusés par le validateur. `evenement_participant` est accepté.
- TRAJECTOIRE, phase 6, réunit les deux sous un seul point : « les rôles dont la valeur est un événement, avec le
  contexte du contenu ». J'ai donc mis `evenement_participant` pour le rêve et l'ordre.
- **La question :** les contextes emboîtés (FONDEMENTS § 2.5 ; S2 de TRAJECTOIRE) sont-ils une extension distincte ?
  Pour un rêve figuré dans une nuée (mn-022), ce qui est en jeu, c'est l'emboîtement d'une figuration, non un événement
  participant.

## 7. Dans quel contexte une requête est-elle évaluée ? (mn-022, et la variante « changement de portée » de mn-011)

- FONDEMENTS § 2.5 sépare le monde figuré et le contenu d'une vision : un référent du rêve n'est pas un référent figuré.
- Mais rien ne dit si une définition qui ne nomme aucun contexte (« seven lean cows devouring seven fat cows ») peut
  être satisfaite **dans** une figuration emboîtée : un tableau dans le tableau, une tapisserie, un rêve figuré.
- ONTOLOGIE § 6 laisse ouverte la satisfaction relative à une situation. La question touche aussi la famille des
  phénomènes iconographiques.

## 8. L'abduction quand deux explications concurrentes ont le même coût (mn-019, et mn-003 pour les attributs)

- SPECIFICATION_OPERATIONS § 4 dit qu'une telle ambiguïté est « rapportée, jamais tranchée ». Elle ne dit pas le statut
  de chaque notation. Chacune est-elle `etablie_sous_hypotheses`, l'ambiguïté notée dans la preuve, ou aucune ne
  l'est-elle ?
- Quand le texte énonce lui-même l'alternative (« either Perseus or David »), l'abduction a-t-elle encore un objet ? Et
  l'hypothèse « Perseus » est-elle admissible, alors qu'elle n'explique rien de plus que l'alternative déjà dite ?

## 9. Le désaccord entre l'auteur et une source citée (la variante « contradictoire » de mn-012)

- L'auteur dit que la dame remet une bague, et l'inventaire cité dit qu'elle ne remet rien.
- NOYAU § 4.3 et 4.4 en font un contradictoire documentaire, de statut `contradictoire`. FONDEMENTS § 2.5 dit que les
  valeurs se calculent « par contexte et par énonciateur » et que la contradiction « reste confinée, documentaire ».
  Lu ainsi, l'auteur seul établirait l'atome.
- **Ce que fait le cas :** j'ai suivi NOYAU (`contradictoire`).
- **La question :** les deux documents disent-ils la même chose ?

## 10. « Selon » : une source de l'iconographie, ou l'énonciateur de l'assertion ? (mn-023, mn-012)

- « The painter shows St Margaret, according to the Golden Legend, emerging… » : c'est l'auteur qui affirme ce qui est
  figuré, la Légende n'est que la source du sujet. J'ai donc écrit `etablie`.
- « Selon l'inventaire, la dame remet une bague » : ici, c'est la source qui énonce ce qui est figuré, d'où
  `non_certifiee`.
- Les documents ne donnent aucun critère de rattachement de « selon / according to ». Tout repose sur la lecture, et
  la frontière est fragile. La paraphrase de mn-023 (« As the Golden Legend tells it, St Margaret is shown… ») est
  déjà ambiguë.

## 11. Le titre inscrit sur l'œuvre : une modalité `titre` ou une portée `oeuvre` ? (mn-024)

- Le titre ancien inscrit au revers relève-t-il de la modalité `titre`, de la portée `oeuvre` (une inscription sur
  l'œuvre), ou des deux ?
- Le statut ne change pas (`inconnue`). Mais la représentation attendue n'est pas fixée, et le contenu de
  l'inscription est une question ouverte (FONDEMENTS § 8).

## 12. Le contenu d'une inscription (mn-008, mn-020)

- AUDIT § 3.7 classe le contenu d'une inscription comme une extension de moindre priorité, et FONDEMENTS § 8 le laisse
  ouvert.
- **Ce que font les cas :** j'ai mis `extensions_requises: aucune` dans mn-008 et mn-020. Le statut attendu peut y être
  atteint en omettant le contenu.
- **La question :** est-ce la bonne lecture de « ce sans quoi le statut ne peut pas être atteint » ? Une lecture qui
  ferait du contenu (« slain at Calais ») une assertion figurée donnerait une erreur de sûreté, et le langage actuel n'a
  aucun moyen correct de le représenter. Le même doute vaut pour l'ordre et la parole quand le statut est `inconnue`
  (mn-009, mn-010).

## 13. Le pivot des constructions de modalité et de contenu (tous les cas)

- Le protocole définit le pivot comme « le sens du mot qui porte le phénomène principal ». Pour « peut-être »,
  « semble », « traditionnellement » ou « selon », ce mot peut être l'opérateur lui-même (un adverbe, `adj.all`), ou
  le mot de contenu qu'il qualifie.
- **Ce que font les cas :** j'ai pris en général le mot qualifié (hermit, weep, weary, donor). Pour les contenus, j'ai
  pris le verbe qui ouvre le contexte (order, command, announce, dream, inscribe). Faute de sens WordNet pour un nom
  propre, j'ai pris un mot voisin : identify pour « traditionally identified as Joseph of Arimathea » (mn-015), slay
  pour l'inscription de mn-008.
- **La question :** la règle doit être fixée, sinon l'axe des familles lexicales ne mesure pas la même chose d'un
  rédacteur à l'autre.

## 14. « Tous sauf X » et l'exception (non employé, rencontré en préparant les compositions)

- FONDEMENTS § 2.6 représente « tous sauf Judas ». Il ne dit pas si l'exception **affirme** que Judas n'a pas la
  propriété (une négation, donc `ecartee` possible), ou seulement ne l'affirme pas (`inconnue`).
- J'ai évité cette construction pour cette raison.

## 15. La portée de `non/1` sur une variable existentielle (mn-016)

- « L'Enfant n'a aucune auréole » se lit comme ¬∃h (auréole(h) ∧ de(h, Enfant)). AUDIT § 3.6 définit `non(A)` sur un
  atome, vrai si A a un appui négatif.
- Il ne dit pas si une variable liée seulement sous `non` est existentielle à l'intérieur (« il n'existe pas d'auréole
  de l'Enfant ») ou à l'extérieur (« il existe une chose qui n'est pas une auréole de l'Enfant »). Seule la première
  lecture donne le sens voulu.

## Ajouts après la révision (relecture B et BANCS § 4.1)

## 16. L'identification traditionnelle dans une abduction (mn-003)

- « Traditionnellement identifiée comme la Victoire » dit le contenu même de l'hypothèse que l'abduction tire des
  attributs typiques.
- SPEC § 4 ne dit pas si cette identification est une observation à expliquer, une explication concurrente, ou rien.
- **Ce que fait le cas :** il est passé en `etablie_sous_hypotheses`, comme la relecture le demandait, parce que la
  concurrente éventuelle conduit à la même notation.

## 17. Une traduction qui change le statut (mn-020, mn-023#1, mn-009#2)

- Quand le sens d'un mot (phylactère contre scroll) ou un alias de nom (Marguerite contre Margaret, Jean-Baptiste contre
  John the Baptist) n'est établi que dans une langue, la variante `traduction` n'a plus le statut de son cas. Or QS
  § 2.2 attend « même statut ».
- **La question :** faut-il réécrire ces cas pour que les deux langues soient symétriques ? Ou faut-il admettre que le
  passage du français par WOLF et les alias font partie de ce que la traduction mesure ?

## 18. Le critère « même lemme des deux côtés » (tous les cas positifs)

- **Ce que font les cas :** j'ai tenu pour certain le lien positif quand le mot de la description est le mot de la
  définition, ou sa traduction par WOLF. NOYAU § 2 en donne la raison : la lexicalisation, d'un sens vers son lemme, est
  un pas de `sous`, donc chaque sens atteint le lemme. J'ai écrit une hypothèse de sens seulement quand le lien passe par
  un autre mot (king vers ruler, phylactère vers scroll).
- **La question :** si la définition compilée est typée par un sens et non par un lemme (FONDEMENTS § 2.7 : les
  connaissances portent sur des sens), ce critère tombe. Presque tous les cas `etablie` deviennent alors
  `etablie_sous_hypotheses` [sens].
- **Un point voisin :** pour une négation, le même lemme ne suffit jamais sous D30, puisqu'un sens du mot n'est pas inclus
  dans ses autres sens. D'où les cinq `decision_ouverte` ajoutées sur des négations.

## 19. Une négation seulement possible face à une affirmation de l'auteur (mn-012#3)

- L'auteur dit que la dame remet une bague, et l'inventaire dit qu'elle ne remet rien. « hand » a deux sens dans
  WordNet.
- Selon D30, la négation citée n'est que possible. L'atome serait alors établi sous l'hypothèse que la négation vise
  un autre sens, et non contradictoire.
- **Ce que fait la variante :** elle garde `contradictoire`. Une variante ne peut pas porter de `decision_ouverte`.
- **La question :** lequel de `contradictoire` et `etablie_sous_hypotheses` est le plus prudent ? BANCS § 7 ne range pas
  `contradictoire` dans l'ordre de sûreté.

## 20. « La Vierge » et le lemme « The_Virgin » (mn-004, 005, 013, 014, 016, 024)

- Dans WordNet 3.0, « virgin » n'a pas le sens de la mère du Christ. Seul le lemme composé « The_Virgin » (synset
  11161412) le donne.
- **Ce que font les cas :** ils supposent que la lecture prend « la Vierge » / « the Virgin » comme ce lemme (WOLF
  pour le français), des deux côtés.
- **La question :** est-ce une convention de lecture, ou une connaissance à écrire ? C'est la question 4 de la
  relecture B.
