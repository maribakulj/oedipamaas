# Questions ouvertes : cadres et structures argumentales (banc de développement, phase 1)

Les points où les documents sont muets, ambigus ou se contredisent, rencontrés en écrivant les 24 cas `sa-001` à
`sa-024`. Aucun n'a été tranché en silence : quand un statut en dépend, le cas porte une `decision_ouverte` et retient
l'option la plus faible.

## 1. La lecture des participants indirects

**Q1. Le rattachement ambigu d'un participe détaché** (`sa-010`, avec une `decision_ouverte`).
« Siméon reçoit l'Enfant des mains de Marie, le bénissant » : la norme grammaticale rattache le participe au sujet,
mais l'usage des notices ne la respecte pas toujours. Les documents ne disent pas si la lecture suit la norme (et le
statut est `etablie`), si l'ambiguïté devient une `alternative` qui n'appuie rien (`inconnue`), ou si elle devient une
hypothèse de lecture nommée (`etablie_sous_hypotheses`). FONDEMENTS § 8 range « les rôles des participes » parmi les
questions ouvertes, sans aller plus loin. Retenu : `inconnue`.

**Q2. Le rattachement ambigu d'une relative** (`sa-011`, avec une `decision_ouverte`).
« La servante de la dame qui verse l'eau » : la relative peut porter sur le nom tête ou sur le nom le plus proche.
Même question que Q1, pour les relatives. Retenu : `inconnue`.

**Q3. Une ambiguïté de lecture n'est pas une ambiguïté de sens.** La liste des `hypotheses_attendues` n'a pas de sorte
pour une ambiguïté syntaxique (rattachement, portée d'une coordination). `sens` ne convient pas, puisque le mot n'est
pas en cause ; `hypothese_interpretative` est l'abduction « au coût le plus haut », ce qui ne décrit pas une ambiguïté
de structure. Faut-il une sorte `lecture_supposee`, ou l'alternative suffit-elle toujours ? (`sa-010`, `sa-011`)

**Q4. La portée d'une modalité dans une coordination** (`sa-014`).
« kneels … and perhaps anoints » : j'ai lu que « perhaps » ne qualifie que le second verbe, et que le sujet partagé
ne transmet pas la modalité au premier. Les documents ne disent rien de la portée d'une modalité dans une coordination
de prédicats, ni de la réciproque (« perhaps kneels and anoints »).

## 2. Patient et thème, tenue et port

**Q5. La convention de rôle n'est pas écrite.** AUDIT § 3.3 renvoie à « une convention à fixer (`docs/BANC_GRAPHES.md`) ».
J'ai supposé que l'objet déplacé (lower, raise, lift, pour) est un thème, que l'objet porté (wear) est un thème et que
le porteur d'un vêtement est le sujet, que le ressuscité (raise%2:29:00) est un patient. Rien dans les documents
autorisés ne le fixe, ni quel rôle porte le sujet de wear (agent ? porteur ?). Comme la définition et le texte reçoivent
la même convention, les statuts n'en dépendent pas ; les graphes attendus, eux, en dépendent (`sa-015`, `sa-016`,
`sa-017`, `sa-018`).

**Q6. Le sens qui décide du rôle** (`sa-016`).
« relève » (soulever / ressusciter) : le sens choisit entre un thème déplacé et un patient changé. J'ai mis une seule
hypothèse `sens`. Mais la contre-expertise citée par FONDEMENTS § 3.2 dit que le rôle « dépend de la classe du
verbe » : faut-il, en plus du sens supposé, une connaissance de valence (VerbNet) dans K, et avec quelle sorte ? Les
sortes de K (§ 2.7) ne prévoient rien pour une valence.

**Q7. La tenue n'est pas le port, mais rien ne le dit dans K** (`sa-017`, variante de participant).
« holds a wreath of roses » contre « wears a wreath of roses » : j'ai mis `inconnue`, puisque rien ne nie le port.
C'est conforme au monde ouvert, mais une notice qui dit « tient à la main » et « tête nue » ne permet toujours pas
d'écarter le port sans une connaissance que les fondements ne prévoient pas (voir Q12).

## 3. Direction, source, destination

**Q8. « towards » et « to ».** Pour un mouvement en cours, une destination (« ascending to heaven ») et une direction
(« rises towards heaven ») ont-elles le même atome ? AUDIT § 3.3 dit que direction et source sont « écrites `lieu` ou
relation selon les cas », sans dire si une direction satisfait une destination. J'ai évité la question dans `sa-003`
(le texte dit « to heaven ») ; elle reste à trancher.

**Q9. Le véhicule et le moyen de transport** (`sa-003`).
« in a chariot of fire » : lieu, instrument, ou une relation ? Les six rôles du langage ne comptent pas de véhicule.

**Q10. Une seule destination ?** (`sa-004`).
« fuit la Judée vers la Galilée » ne nie pas « fuit en Égypte » : aucune connaissance ne dit qu'un mouvement n'a qu'une
destination, ni que deux lieux nommés sont distincts. `inconnue` est sûr, mais c'est un contre-modèle que l'humain
jugerait écarté. Faut-il une contrainte de cadre (une destination par mouvement), et de quelle sorte ?

## 4. Postures

**Q11. Postures : état ou processus maintenu, et rôle du porteur** (`sa-019` à `sa-022`).
ONTOLOGIE § 6 laisse la question ouverte. Je les ai traitées comme des états dont le porteur est le référent, avec le
support (trône, pierre) en relation. Le rôle du porteur, qui « a quelque chose d'un agent » (ONTOLOGIE § 1.2), n'est
pas fixé.

**Q12. Les incompatibilités : debout / assis, éveillé / endormi** (`sa-022`, avec une `decision_ouverte` ; aussi
`sa-019`, `sa-005`).
Les fondements (§ 2.7) ne comptent aucune incompatibilité parmi les sortes de connaissances, et § 3.3 ne propage une
négation que par une implication ou une équivalence. Une antonymie de WordNet n'a donc aucune force négative, et
« Jacob, éveillé » laisse « endormi » `inconnue`. C'est le point qui produit le plus de contre-modèles que l'humain
jugerait écartés. Faut-il une sorte « incompatibilité établie » (A ⇒ ¬B, avec contraposition) ?

**Q13. L'état d'un stade et l'événement qui le termine** (`sa-005`, `sa-013` : « vient de s'éveiller », « qui
s'éveille »).
ONTOLOGIE § 5 dit que nier un état ne nie pas l'événement qui l'a causé ; elle ne dit pas si un événement qui termine un
état (s'éveiller) nie cet état au moment figuré. J'ai mis `inconnue`.

## 5. Négation et rôles

**Q14. La cible contre le noyau 0.3 pour une description niée avec ses rôles** (`sa-002`, `sa-012`, `sa-018`,
variantes de `sa-010`, `sa-011`, `sa-017`, `sa-022`).
FONDEMENTS § 1.1 donne `ecartee` quand la conjonction vaut F. NOYAU § 1.1 (D41) ne dérive pas cette réfutation quand
aucun autre événement n'est dit. J'ai suivi la cible (`ecartee`), comme le demande le protocole. Il faut confirmer que
D41 est bien une incomplétude à combler, et non la sémantique voulue.

**Q15. Le rôle nié seul.** « slain not with a sword but with an axe » : le texte nie le rôle instrument d'un événement
affirmé. NOYAU § 1.1 dit qu'« un rôle n'est pas nié seul ». Il n'y a aucune manière d'écrire ce que le texte dit, et
c'est fréquent pour l'instrument et le moyen. Je n'en ai pas fait de variante, puisque le statut en dépend
(`sa-008`). Est-ce une extension à prévoir (un rôle nié d'un événement positif) ?

**Q16. La contraposition depuis une prémisse niée** (`sa-024`).
SPECIFICATION § 2 dit à la fois que « `deduire` ne part que de prémisses positives admissibles » et qu'« une négation
n'est propagée que par contraposition ». La réfutation par une condition nécessaire (FONDEMENTS § 2.7) part
justement d'une prémisse niée (« does not hold his quill »). Laquelle des deux phrases l'emporte, et dans quelle
opération (la déduction, ou la classification, qui traite les conditions nécessaires d'un libellé) ? Il faut aussi
dire comment cette réfutation porte sur un événement que rien ne lie (aucune écriture n'est dite) : c'est le cas D41,
sous une autre forme.

**Q17. La polysémie d'un verbe nié dont le contexte fixe le sens** (`sa-018`).
« ne porte pas encore la couronne », sur la tête : NOYAU § 2 dit qu'une négation n'est certaine que si chaque sens du mot
nié est couvert ; le protocole (§ 4) dit qu'une hypothèse de sens ne figure que si le texte laisse le sens ouvert. Le
contexte fixe ici le sens, mais qui le fixe, la lecture (C7) ou K ? Si personne ne le fait, la négation n'est que
possible, et le statut devient `inconnue`.

## 6. Contextes, sources, représentations emboîtées

**Q18. « Selon » : un énonciateur du figuré ou une source textuelle ?** (`sa-006`, variantes de `sa-008`, `sa-010`).
« According to the Medici inventory, the panel showed … » est un énonciateur cité qui décrit le figuré, d'où
`non_certifiee`. « Selon l'Évangile » ou « la Légende dorée rapporte » ouvre un contexte de source, d'où `inconnue`. Les
documents ne donnent pas de critère pour distinguer les deux lectures de « selon », alors que les statuts diffèrent.

**Q19. Une configuration figurée seulement dans une figuration emboîtée** (variantes de `sa-007`, `sa-015`).
Saint Luc peignant la Vierge n'est figuré que dans le petit tableau du chevalet. J'ai mis `inconnue` (FONDEMENTS § 2.5 :
ce qui n'est pas dans le contexte de la figuration n'établit rien). Mais une notation de classement viserait souvent
aussi le sujet d'un tableau dans le tableau. Faut-il une règle de satisfaction relative à un contexte emboîté ?

**Q20. L'apposition qui personnifie** (`sa-023`).
« Une femme couronnée, la Justice » a la forme d'une coréférence par apposition, mais dit une personnification. Rien
dans les documents ne dit comment la lecture distingue l'apposition d'identité (« Siméon, le vieillard ») de
l'apposition de concept. L'extension des référents conceptuels (AUDIT § 3.7) le suppose sans le dire.

## 7. Abduction et typicité

**Q21. Une hypothèse qui expliquerait une alternative du texte** (`sa-020`).
« soit debout, soit assis » : j'ai jugé que la posture typique du Baptiste n'explique aucun élément observé, donc que
l'abduction est inadmissible (SPECIFICATION § 4). Mais l'alternative elle-même est une assertion du texte ; une
hypothèse qui choisit une branche l'« explique »-t-elle ? Si oui, le statut devient `etablie_sous_hypotheses`.

**Q22. Les explications concurrentes absentes de K** (`sa-017`).
La couronne de roses est aussi attribuée à d'autres saintes ; K, tel que le cas l'écrit, n'en contient qu'une. Le
statut dépend donc de l'étendue de K, qui est écrite dans le cas : c'est conforme au protocole, mais un K plus complet
rendrait une ambiguïté rapportée. Faut-il que les cas d'identification par les attributs listent les concurrents
connus ?

## 8. Le protocole et le validateur

**Q23. Les extensions requises des variantes.** Le champ `extensions_requises` est au niveau du cas. Plusieurs cas ne
demandent aucune extension, mais une de leurs variantes en demande une (`changement_de_temps` : l'ancrage temporel,
dans `sa-003`, `sa-007`, `sa-016`, `sa-019`, `sa-022` ; la variante emboîtée de `sa-007`). Une phase qui reçoit le cas
fera échouer la variante. Faut-il un champ par variante ?

**Q24. Le nom de l'extension des relations entre événements** (`sa-015`).
La liste du validateur n'a pas accepté un nom propre aux relations d'ordre et de cause entre événements (AUDIT § 3.5
(4)). J'ai noté `ancrage_temporel`, puisque ONTOLOGIE § 2 range la simultanéité avec l'ancrage, mais ce sont deux
besoins distincts dans l'audit.

**Q25. Les variations hors liste.** Plusieurs variantes lèvent une ambiguïté ou changent un participant pour rendre
le cas positif (`sa-004`, `sa-008`, `sa-011`) : je les ai rangées sous `changement_de_participant`, faute d'une
variation « désambiguïsation ». La relation métamorphique attendue n'y est pas « même statut ».

**Q26. L'implication non attestée.** Le protocole (§ 4) dit qu'une connaissance non attestée ne fonde pas une
déduction. La table des fondements (§ 2.7) donne l'implication comme déductive, sans parler d'attestation. J'ai traité
toutes les implications de K comme attestées, et la seule connaissance dirigée non attestée (`sa-023`, recevoir ⇒
remettre) comme une `condition_suffisante` non attestée. Une implication non attestée donne-t-elle
`condition_suffisante_non_attestee` ?
