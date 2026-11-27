# Questions ouvertes : famille reference_quantification (référence, identité, coréférence, quantification)

Points où les documents (BANCS_PHASE1, FONDEMENTS_SEMANTIQUES, ONTOLOGIE_EVENTUALITES, SPECIFICATION_OPERATIONS,
QUALIFICATION_SEMANTIQUE § 2, NOYAU § 1 et § 4, ASSERTIONS, AUDIT § 3.4) sont muets, ambigus ou se contredisent,
rencontrés en écrivant les 24 cas. Rien n'est tranché ici. Quand le statut en dépendait, le cas porte une
`decision_ouverte` et l'option la plus prudente.

## A. Coréférence

1. **Un pronom ambigu peut-il fonder une hypothèse d'identité ?** (rq-002 ; rq-001, variante d'ajout de figure)
   NOYAU § 1 (C9) dit que la coréférence possible n'est pas dans le graphe. BANCS_PHASE1 § 4 liste pourtant une
   sorte d'hypothèse `identite`, sans dire d'où elle vient. Quand « il » a deux antécédents compatibles, le statut
   est-il `inconnue` ou `etablie_sous_hypotheses` [identite] ? J'ai choisi `inconnue`.
2. **Désignation reprise ambiguë et monotonie.** (rq-004, deuxième variante `ajout_figure_non_liee`)
   QUALIFICATION_SEMANTIQUE § 2.2 attend « statut conservé » quand on ajoute une figure non liée, « hors identité ».
   Ajouter une figure qui devient un second antécédent possible (« the penitent ») fait passer le cas de `etablie` à
   `inconnue`. Il faut dire si cette variation est « non liée » : la frontière n'est écrite nulle part.
3. **Quelle connaissance sert à résoudre une reprise ?** (rq-002, variante `composition` : « le prélat »)
   La reprise par un hyperonyme (prélat ⊒ évêque) n'est désambiguïsée que si le lecteur sait qu'un diacre n'est pas un
   prélat. Est-ce une affaire de lecture (C7) ou de K, et faut-il une négation établie dans K ?
4. **Indéfini contre reprise.** (rq-005) Je tiens qu'« un saint » indéfini ouvre une nouvelle classe. Aucun document
   ne le dit explicitement : c'est une règle du lecteur.

## B. Collections, distributivité

5. **Supervaluation sur les lectures distributive et collective.** (rq-010)
   FONDEMENTS_SEMANTIQUES § 2.6 : le cas indécidé « reste une ambiguïté et n'est pas résolu par défaut ». D30 fixe la
   supervaluation pour les **sens** seulement. Une conclusion vraie dans les deux lectures (« Two angels crown her »
   ⇒ « crowned by angels ») est-elle établie ? Statut prudent choisi : `inconnue`. C'est à mes yeux la question la
   plus lourde de la famille : toute phrase plurielle non marquée en dépend.
6. **La lecture distributive peut-elle être une hypothèse, et de quelle sorte ?** (rq-011) Aucune sorte de la liste
   (`sens`, `hypothese_interpretative`…) ne la nomme. Option prudente : `inconnue`.
7. **Un collectif explicite réfute-t-il un libellé distributif ?** (rq-011, variante « offrent ensemble un unique
   coffret » ; rq-012, variante « each carries a bunch ») J'ai mis `inconnue` dans les deux sens. Il faudrait une
   connaissance qui dise qu'« un unique coffret offert ensemble » exclut « chacun un présent ».
8. **Un prédicat distributif sur un groupe vaut-il pour ses membres sans « chacun » ?** (rq-006 « les deux époux sont
   assis » ; rq-008 « les trois Grâces, nues » ; rq-009, variante `composition`) Pour dormir, être assis, être nu, la
   lecture distributive va de soi, mais aucun document ne dit d'où vient la distributivité d'un prédicat (de K ? du
   sens du verbe ?). J'ai écrit les cas pour que la définition soit satisfaite dans les deux lectures, ou j'ai mis
   « each » dans le texte.
9. **Une entité plurielle avec `nombre/2` est-elle déjà une collection ?** (rq-008, rq-014)
   Pour « les trois Grâces, nues » et « ten apostles », le langage actuel suffit (entité, nombre, propriété), d'où
   `extensions_requises: aucune`. Mais FONDEMENTS_SEMANTIQUES § 7 compte les collections parmi ce qui doit changer.
   Où passe la limite ? J'ai demandé `collection` seulement quand les membres, un agent collectif ou une paire
   coordonnée sont en jeu (rq-006, 007, 009, 010, 011, 012, 015, 021, 023, 024).
10. **Coordination et distinction.** (rq-021, rq-024) « Judith et sa servante », « Pierre, Jacques et Jean » : une
    coordination de deux syntagmes établit-elle que leurs référents sont distincts ? NOYAU § 1 ne donne pour
    distinction établie que « un autre », « l'un… l'autre ». J'ai donc mis « a third figure » dans rq-021 et une
    `distinction_documentaire` dans le K de rq-024. Question liée : une énumération de trois membres d'un groupe dit
    « les trois » établit-elle leur distinction (comptage) ? NOYAU § 1 dit qu'un nombre « ne dit pas que deux mentions
    particulières sont deux de ces hommes », ce qui semble l'exclure, même pour une apposition explicite.

## C. Nombres

11. **Nombre exact ou « au moins » ?** (rq-014) J'ai lu « ten apostles » comme une cardinalité exacte, qui réfute
    nombre(X, 12) (NOYAU § 4.1). Une définition « the twelve apostles » demande-t-elle le nombre exact du groupe
    figuré, ou douze membres distincts (« au moins k », AUDIT § 3.4) ? Les deux compilations donnent des statuts
    différents ici : `ecartee` contre `inconnue`.
12. **Le nombre d'une œuvre lacunaire.** (rq-014, variante `changement_de_portee`) Un nombre illisible, ou des figures
    détruites, relèvent de l'œuvre et non du figuré. Le figuré d'une fresque mutilée compte-t-il les figures perdues ?
    Les documents ne le disent pas.
13. **« Both », « autant de », « paire ».** (rq-015, rq-013 variante paraphrase) « Both » donne un nombre 2 par la
    lecture ; « autant de » donne un nombre par anaphore. Ces nombres anaphoriques ne sont décrits nulle part.

## D. Noms propres

14. **Alias, homologue, identité.** (rq-017) WordNet relie Minerva et Athena par « counterpart of » / « identified
    with », sans en faire un seul synset (alors qu'Hercules et Heracles en sont un). Est-ce un alias (un seul
    individu), une distinction documentaire, ou une relation inconnue ? Et une identité peut-elle être supposée sur une
    relation inconnue ? Statut prudent : `inconnue`.
15. **Nom partiel : `identite` ou `sens` ?** (rq-020, rq-019, rq-018 variante) La désambiguïsation de « John » entre
    le Baptiste et l'évangéliste est-elle une hypothèse d'identité, une hypothèse de sens (le nom comme mot
    polysémique), ou une abduction ? J'ai mis [identite, connaissance_typique]. Le pivot pose aussi problème : le mot
    du texte est « John », dont WordNet ne donne que l'évangéliste (john%1:18:00::) ; le sens visé, le Baptiste, n'est
    pas un sens de ce lemme. J'ai pris john%1:18:00::, faute de mieux.
16. **Ce qu'atteste un nom partiel.** (rq-019) « le Baptiste » est-il un alias établi de Jean-Baptiste (K attesté), ou
    toujours une désambiguïsation ? AUDIT § 3.4, (3) dit « désambiguïsation, non égalité de chaînes ». Je l'ai écrit
    attesté dans K, et le statut `etablie` en dépend.
17. **Le nom par une inscription.** (rq-017 ; rq-016 variante « Hercole » au revers) Une inscription de l'œuvre qui
    nomme une figure est-elle une assertion de nom sur la figure (portée ?), un contenu d'inscription (contexte ouvert,
    FONDEMENTS_SEMANTIQUES § 2.5), ou seulement un indice typique ? FONDEMENTS § 8 laisse ouvert « le contenu textuel
    des inscriptions ». J'ai mis `contexte_d_eventualite` et une connaissance typique non attestée. Le rattachement
    dépend aussi du nombre de figures (variante de rq-017 avec une Victoire).
18. **Les alias de traduction sont partout.** (rq-003, 015, 016, 019, 021, 022, 024) Chaque cas français avec une
    définition anglaise demande un alias (Tobie/Tobias, Loth/Lot, Pierre/Peter…). Ils sont écrits dans K, attestés.
    Les documents ne disent pas si la clé de nom (`cle_de_nom`) les couvre déjà ou s'il faut une base d'alias.
19. **Le nom dans l'histoire.** (rq-003 variante « le marché de 1512 le nomme Tobie » ; rq-006 variante des
    archives) Un nom ou une relation de mariage donnés par l'histoire de l'œuvre valent-ils pour le personnage figuré ?
    FONDEMENTS § 1.2 sépare le figuré et l'individu historique (désignation). J'ai mis `inconnue`. La règle de
    transfert de l'histoire au figuré (le donateur figuré est-il l'époux de la donatrice figurée ?) n'est pas écrite.

## E. Quantification énoncée

20. **Contradiction entre l'audit et les fondements sur « seul ».** (rq-021, rq-022) AUDIT § 3.4, (4) : « seul »,
    « tous », « aucun autre » ne demandent pas d'extension ; la propriété `seul`, le nombre ou une négation dite
    suffisent (« c'est donc (2), non (4) »). FONDEMENTS_SEMANTIQUES § 2.6 et § 7 comptent pourtant « les
    quantifications énoncées » parmi ce qui doit changer, sur une collection et un domaine. Pour « Judith et Holopherne
    seuls » (rq-021), une propriété `seul` sur deux individus ne dit pas la solitude conjointe : j'ai demandé
    `quantification_enoncee` et `collection`. Pour rq-022 (statut `inconnue`), aucune extension.
21. **« Tous sauf X » dit-il quelque chose de X ?** (rq-024, variante « tous dorment, sauf Pierre ») L'exception
    affirme-t-elle que X ne dort pas (statut `ecartee`), ou retire-t-elle seulement X du domaine (`inconnue`) ? Les
    documents citent « tous sauf Judas » sans le trancher. J'ai mis `inconnue`, l'option prudente.
22. **Domaine de la quantification.** (rq-021 : la sentinelle dehors ; rq-024 : Judas au fond ; rq-023 : le dragon de
    la marge) Je tiens que « seuls dans la tente », « les trois apôtres… tous » et « devant le tombeau » restreignent
    le domaine. FONDEMENTS § 2.6 nomme les domaines restreints sans dire comment le lecteur les fixe, ni ce qu'est le
    domaine par défaut (la scène ? l'œuvre ? la marge d'un manuscrit ?).
23. **Le sens de « seul » et les animaux.** (rq-022, variante « seul avec son lion ») « Alone » a un sens « sans
    compagnie » et un sens « exclusive of anyone or anything ». Un animal brise-t-il la solitude d'un ermite ? La
    conclusion en dépend : j'ai mis `etablie_sous_hypotheses` [sens]. Plus généralement, les libellés exclusifs
    quantifient-ils sur les personnes ou sur toutes les figures ?
24. **Réfuter un libellé exclusif par une figure ajoutée.** (rq-021, variante « a third figure… ») Le texte dit
    « alone » et décrit une troisième personne : j'ai mis `contradictoire` (interne). Mais la proposition 1 de l'audit
    (monotonie) dit qu'une condition non monotone n'est exprimable par aucune requête : la réfutation suppose donc
    soit `negation_dans_la_requete`, soit une règle qui confronte la quantification énoncée aux figures présentes. Les
    documents ne disent pas laquelle. Sans troisième personne explicitement distincte, il faudrait aussi K (une femme
    n'est pas Holopherne).
25. **« Seulement des femmes » et la présence d'hommes.** (rq-023) La négation dite (« pas seulement ») donne
    `ecartee`. La simple présence de Pierre et Jean n'y suffirait pas sans une disjonction homme/femme dans K et sans
    règle de confrontation (question 24).

## F. Négation, modalité, portée

26. **Événement nié avec ses rôles, sans autre événement.** (rq-007) La sémantique cible donne `ecartee` (v_D = F,
    FONDEMENTS § 1.1 ; QUALIFICATION § 2.2), mais le noyau 0.3 ne dérive pas cette réfutation (NOYAU § 1.1, D41). J'ai
    suivi la cible. Le banc compte donc un écart attendu avec le noyau actuel, à traiter comme incomplétude et non
    comme erreur de sûreté.
27. **Prémisse graduée.** (rq-003 « traditionnellement identifié » ; rq-005 « sans doute un saint » ; rq-014
    « probably ten ») FONDEMENTS § 5 cite une sorte d'hypothèse « prémisse graduée », absente de la liste des
    hypothèses de BANCS_PHASE1 § 4. J'ai mis `inconnue` (QUALIFICATION § 2.2 : établie seulement si affirmée), mais une
    lecture des fondements donnerait `etablie_sous_hypotheses`.
28. **Source citée ou portée source ?** (rq-007 « according to the 1547 inventory » : `non_certifiee` ; rq-021
    « according to the Book of Judith » : `inconnue`) Je distingue une source qui parle de l'image (énonciateur cité,
    portée represente) d'un texte qui parle du récit (portée source). La frontière dépend du lecteur, et rien ne dit
    comment classer un inventaire ou un catalogue de vente (rq-008, rq-017).
29. **Titre et alias.** (rq-018) Le nom complet n'est que dans le titre : `inconnue`. Mais si K contenait les
    attributs typiques (peau de bête), le titre pourrait-il servir d'observation pour une abduction ? SPECIFICATION
    § 4 dit qu'une explication explique des assertions de D ; un titre en est-il une ?

## G. Méta : le protocole et le validateur

30. **Variantes dont le statut change sans être une des variations nommées.** Pour lever une ambiguïté
    (rq-002, 010, 011, 012, 020, 021, 022, 023 : « composition »), j'ai employé la variation `composition`, la seule
    qui permette un changement « écrit au cas par cas ». Il manque peut-être une variation « désambiguïsation » ou
    « retrait de la quantification énoncée ».
31. **Sorte d'un cas sous hypothèses.** (rq-020) Un cas `etablie_sous_hypotheses` par abduction est-il un positif ou
    un indéterminé ? J'ai mis `positif`. Les variantes `non_certifiee` et `contradictoire` sont classées
    `indetermine`, faute de règle.
32. **Liste des extensions et des sortes de connaissances.** Elles ne sont écrites dans aucun document (« voir la
    liste du validateur ») : je les ai trouvées en soumettant des noms au validateur. Il n'y a pas de sorte pour un
    alias (j'ai employé `identite_documentaire`), et pas d'extension propre pour les espèces, les distributifs ou
    l'exception.
