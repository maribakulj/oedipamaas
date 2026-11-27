# Définitions conceptuelles, classification : les questions ouvertes (banc de développement, phase 1)

Les points où les documents (BANCS_PHASE1, FONDEMENTS_SEMANTIQUES, ONTOLOGIE_EVENTUALITES, SPECIFICATION_OPERATIONS,
QUALIFICATION_SEMANTIQUE § 2, NOYAU, ASSERTIONS, AUDIT_EXPRESSIVITE § 3.8) sont muets, ambigus ou se contredisent,
rencontrés en écrivant les 24 cas. Quand le statut en dépend, le cas porte une `decision_ouverte` et son statut est
l'option la plus faible.

## A. Les questions qui fixent un statut (avec `decision_ouverte`)

1. **Le contenu d'une figuration emboîtée satisfait-il une définition de configuration figurée ?** (dc-003 ; aussi
   dc-021, variante `changement_de_portee`, l'estampe épinglée au mur). FONDEMENTS § 2.5 dit qu'un référent du contenu
   d'une vision n'est pas un référent du monde figuré. Aucun document ne dit si « angel holding a chalice » est satisfait
   par l'ange d'une vision que l'image montre. Iconclass le classerait d'ordinaire. Le statut retenu est `inconnue`,
   ou `etablie` si le contenu emboîté satisfait.

2. **Une condition nécessaire satisfaite peut-elle proposer une abduction ?** (dc-007). Le tableau de FONDEMENTS § 2.7
   dit « jamais pour l'établissement ». SPECIFICATION § 4 énumère les sortes qui proposent une hypothèse (typique,
   interprétative, conséquence conditionnelle, relation inconnue), sans la condition nécessaire et sans l'exclure.
   Pourtant T ⇒ Def relie bien T à l'observation Def, ce qui est la forme d'une explication (§ 5). Le statut retenu est
   `inconnue`, ou `etablie_sous_hypotheses` si elle propose.

3. **Le seuil d'appariement partiel n'est pas fixé** (dc-009). SPECIFICATION § 3.2 exige « un seuil sur les atomes
   satisfaits, fixé à l'avance », sans le donner. Il faut aussi dire s'il se compte en atomes de la structure ou en
   attributs typiques, et si un attribut contraire non nié (« la tête est nue » contre « chapeau ») compte contre.

4. **Le nom d'une inscription du cadre est-il un nom de la figure ?** (dc-014 ; aussi dc-013 et dc-015). FONDEMENTS § 8
   laisse ouvert le contenu textuel des inscriptions, et le cadre est de portée « œuvre ». Si l'inscription nomme la
   figure, l'identification par attribut contredit le nom par la distinction documentaire, et le statut est `inconnue` ;
   sinon, `etablie_sous_hypotheses`.

5. **Une substitution énoncée vaut-elle négation ?** (dc-016). « The copyist replaced them with the book » implique que
   les tenailles ne sont pas dans la copie. Les documents ne disent pas si une implication de ce genre est un appui
   négatif dit (`ecartee`) ou seulement une information sur l'autre œuvre (`inconnue`). Plus largement : la lecture
   doit-elle écrire comme négations les absences impliquées par le texte (« remplacé », « à la place de », « perdu ») ?

6. **Le décor qui figure un X** (dc-018). Pour un laurier de carton sur une scène, trois lectures sont possibles :
   composé de matière intersectif (`etablie`), privatif dans le même contexte (`ecartee`), ou X du seul contexte emboîté
   du décor (`inconnue`). FONDEMENTS § 1.2 ne connaît que le privatif strict et le mode d'existence. SPECIFICATION § 1
   exclut qu'un composé reçoive une propriété par la syntaxe, mais ne dit rien du type de la tête.

7. **« Portrait de X en Y »** (dc-019). Le portrait historié n'est décrit nulle part. Y est-il une désignation de la
   figure (`etablie`), ou un rôle (seule l'identification par attributs reste, `etablie_sous_hypotheses`) ? Une
   difficulté de plus : si K contenait une distinction documentaire entre X et Y, l'identité de la figure avec Y
   deviendrait inadmissible, ou contradictoire pour `meme`. Le régime de l'identité du NOYAU (§ 1) n'a pas de relation
   « figure X sous les traits de Y ». Le cas a été écrit sans cette distinction dans K, pour ne pas tomber dans ce trou.

8. **La classe de « prétendu »** (dc-020). L'inventaire range « prétendu » parmi les adjectifs privatifs (la vue de
   développement, `adjectif_privatif/pretendu`). Les fondements ne décrivent que « faux » (privatif strict). En langue,
   « prétendu » ou « so-called » est non subsectif : un prétendu voleur peut être un voleur. Le statut retenu est
   `inconnue`, ou `ecartee` si « prétendu » est privatif. AUDIT § 3.2 fixe en revanche « ancien évêque » comme non-évêque,
   ce qui donne `ecartee` à la variante « ancien moine ».

9. **Co-localisation, et positions entre registres** (dc-023). ONTOLOGIE § 4 et § 6 laissent ouverte la satisfaction
   relative à une situation. En plus : « au-dessus » entre deux registres d'une page est-il une relation du figuré, ou
   une relation de mise en page (œuvre) ? Le statut retenu est `inconnue`, ou `etablie` si la satisfaction porte sur
   toute l'œuvre.

## B. Les points tranchés par les documents, mais en tension

10. **Le type d'un personnage tiré d'une source ou de l'histoire** (dc-004). FONDEMENTS § 1.2 n'importe pas les faits
    encyclopédiques dans la scène. Le martyre de sainte Eulalie, dit « selon la Passion », ne fait donc pas de la figure
    une « female martyr », et le statut est `inconnue`. C'est fixé par les documents, mais c'est contraire à la pratique
    de classement d'Iconclass, où « martyr » qualifie la figure du saint martyr. À confirmer par la propriétaire : un
    type obtenu par désignation (la figure désigne un individu qui, dans la source, est un martyr) ne passe-t-il jamais
    au figuré ?

11. **La condition nécessaire contre l'identification par le nom** (dc-005). Le géant est nommé Polyphème, mais l'auteur
    nie l'œil unique au milieu du front : le type « cyclope » est réfuté, et la définition « the cyclops Polyphemus » est
    écartée pour ce référent. C'est conforme à la contraposition (§ 2.7, § 3.3), mais des peintres ont donné deux yeux à
    Polyphème, et Iconclass le classerait sous Polyphème. Une condition nécessaire d'un concept (cyclope) vaut-elle pour
    un individu nommé, dont le type viendrait de la désignation ? Une définition qui mêle un nom et un type
    (« the cyclops Polyphemus ») doit-elle être compilée en conjonction ?

12. **L'hypothèse de sens : « que le texte laisse ouverts » contre D30.** BANCS_PHASE1 § 4 ne met `sens` que si le texte
    laisse plusieurs sens ouverts. NOYAU § 2 (D30) rend un lien certain seulement si chaque sens conceptuel du mot atteint
    le type, la désambiguïsation par le contexte relevant de C7. Presque tout mot d'une périphrase est polysémique dans
    WordNet (« fish », « woman », « light », « vessel », « gridiron », « tower »). Ici `sens` est réservé aux cas où le
    contexte ne désambiguïse pas (dc-018, variante au laurier à terre). Les cas dc-001, dc-003, dc-013, dc-015 et dc-024
    sont établis, ou sous la seule hypothèse typique, parce que le contexte désambiguïse. Un moteur sans C7 rendra
    `etablie_sous_hypotheses` [sens] : ce n'est pas une erreur de sûreté (plus faible), mais l'écart sera compté.
    Faut-il écrire l'attendu selon la désambiguïsation humaine, ou selon D30 sans C7 ?

13. **Les hypothèses d'une traduction.** La polysémie d'un mot français n'est pas celle du mot anglais (« gril » contre
    « gridiron », « roue » contre « wheel »). Le statut d'une traduction est le même. La liste des hypothèses peut ne pas
    l'être, si K a un lexique français propre. Les documents ne disent pas quels sens anglais K donne à un mot français.
    Les traductions de ce fichier gardent la même liste d'hypothèses.

14. **La sorte d'un cas `contradictoire`.** La variante `changement_de_participant` de dc-006 (« a white unicorn which
    does not have a horn ») rend `contradictoire` (interne : V par le mot, F par la contraposition). Le plan
    (QUALIFICATION_SEMANTIQUE § 2.1) n'a que quatre sortes. Elle est classée `indetermine`, faute de mieux.

15. **La sorte d'un cas `inconnue` qui est un négatif.** dc-014, dc-020 et dc-022 sont des configurations voisines qui ne
    satisfont pas la définition. Leur statut est `inconnue`, non `ecartee`, faute d'appui négatif. Le plan les appelle
    « négatifs » (§ 2.1 : « une configuration voisine qui ne la satisfait pas »). La frontière entre `negatif` et
    `indetermine` est floue, quand les deux donnent `inconnue`.

16. **La négation d'une description restreinte qui couvre la condition nécessaire** (dc-005, dc-006, dc-008). « Aucun œil
    au milieu du front » nie une entité restreinte : NOYAU § 1.1 n'en tire rien (D41, perte dans le sens sûr). La
    sémantique cible (FONDEMENTS § 1.1, § 3.3) la tient pour F et réfute par contraposition. L'attendu est écrit selon la
    cible (`ecartee`). Le moteur actuel rendra `inconnue`, sans erreur de sûreté. Il faut aussi dire comment une
    condition nécessaire structurée (« un œil unique au milieu du front ») est réfutée par la négation d'une de ses
    parties (« un œil au milieu du front »), un pas que ni le noyau ni la spécification de la classification ne décrivent.

17. **Les implications entre catégories** (dc-008). « Son corps n'est pas chevalin » réfute « un corps de cheval » par une
    implication entre un nom et un adjectif de relation (`adj.pert`). AUDIT § 4 demande ces relations entre catégories
    dans K, sans en fixer la forme ni la direction de négation.

18. **« Aucune autre figure dans K » n'est pas « d'un seul ».** La construction `attribut_typique_d_un_seul` suppose que
    l'attribut n'appartient qu'à un individu. En monde ouvert, que K n'en connaisse pas d'autre ne prouve rien (§ 2.7).
    L'identification reste donc sous hypothèse, avec des concurrentes « non calculées » faute de connaissance. Faut-il
    une attestation de l'unicité (une connaissance de sorte propre), et la preuve doit-elle dire qu'aucune concurrente
    n'était connue à cette version de K ? (dc-013 à dc-016)

19. **La modalité traditionnelle et l'abduction** (dc-015). L'identification « traditionnelle » n'est pas une prémisse.
    Elle pourrait entrer comme prémisse graduée (AUDIT § 3.6), et l'attribut typique fonde aussi une hypothèse. Laquelle
    est l'explication minimale ? Quel est le coût d'une prémisse graduée (SPECIFICATION § 4 n'en donne pas) ? Le statut
    ne change pas, la liste des hypothèses si. Même question pour le titre (dc-012) : un titre peut-il entrer comme
    prémisse graduée ? ASSERTIONS dit « un indice, jamais une preuve ».

20. **Un état de conservation qui retire une figure** (dc-006 et dc-024, variantes `changement_de_portee`). « La corne a
    été découpée », « le disque de lumière est entièrement perdu ». La négation porte sur l'œuvre, non sur le figuré, et
    l'attendu retenu est `inconnue`. Les documents ne disent pas si ce que l'œuvre figurait à l'origine, et ne montre
    plus, est encore « figuré ».

21. **Les entités non figurées dans une périphrase.** En écrivant (cas abandonné), la périphrase de « widow » (« une femme
    dont le mari est mort ») cite un référent qui n'est pas dans l'image. La certification demande chaque entité de
    l'appui présente (NOYAU § 1). Une structure de la base de définitions peut-elle exiger un participant qui n'a pas à
    être figuré ? Les documents ne le disent pas.

22. **La compilation d'une définition à colonne** (dc-012). Dans « Mary with the Child … led by Joseph (flight into
    Egypt) », le nom de la situation est-il un atome de la requête (un type de situation, à classer), ou seulement une
    étiquette ? Le statut de la variante `composition` (`etablie`) suppose une étiquette.

23. **Le sens du mot de la définition.** Le pivot fixe le sens visé (hermit%1:18:01::, martyr%1:18:01::,
    pilgrim%1:18:01::). Le compilateur choisit-il ce sens, ou est-ce une hypothèse de sens côté requête ? SPECIFICATION
    § 3.1 dit « déductif, sous les hypothèses de sens de l'entrée », sans dire si ces hypothèses figurent dans
    `hypotheses_attendues`. Ici, elles n'y figurent pas.
