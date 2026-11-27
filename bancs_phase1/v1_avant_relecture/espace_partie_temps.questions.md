# Questions ouvertes : famille espace_partie_temps (relations spatiales, temporelles, causales, méréologiques)

Points où les documents (BANCS_PHASE1, FONDEMENTS_SEMANTIQUES, ONTOLOGIE_EVENTUALITES, SPECIFICATION_OPERATIONS,
QUALIFICATION_SEMANTIQUE § 2, NOYAU § 1 et § 4, AUDIT_EXPRESSIVITE § 3.5) sont muets, ambigus ou en tension, relevés
en écrivant les cas ep-001 à ep-024. Quand un statut en dépend, le cas porte une `decision_ouverte` et le statut le
plus prudent.

## A. Méréologie

1. **Le transfert d'un rôle de la partie au tout** (ep-002, ep-016, ep-014). « La foudre frappe le grand mât » :
   le voilier est-il frappé ? « Elle baise l'anneau » : baise-t-elle la main ? FONDEMENTS § 3.4 dit qu'une partie
   n'est pas son tout, mais rien ne dit si certains prédicats (frapper, toucher, tenir, baiser) se transmettent de la
   partie au tout, ou d'un objet porté à la partie qui le porte. Les cas suivent la lecture stricte : rien n'est
   transmis sans une règle de K. Faut-il une sorte de connaissance pour ces règles, avec une direction de négation ?

2. **Le tout d'une partie figurée seule est-il présent ?** (ep-014, decision_ouverte). « La main de Dieu sort d'un
   nuage » : Dieu est-il un référent figuré présent (au sens de l'admissibilité de NOYAU § 1), ou seulement un
   référent impliqué, hors de l'image ? Et l'agent de « la main bénit » est-il le tout ? FONDEMENTS § 2.4 dit que le
   tout est « impliqué si la partie est obligatoire », mais pas dans quel contexte ni avec quelle présence. La même
   question vaut pour une tête coupée (ep-013 : la définition ne demande pas le Baptiste, ce qui l'évite).

3. **« Supposé sinon » : la partie facultative et l'abduction** (ep-003, decision_ouverte). FONDEMENTS § 2.4 dit
   que le tout d'une partie facultative est « supposé ». Une roue détachée, appuyée contre un mur, appelle-t-elle
   encore un tout supposé ? Si oui, laquelle des explications concurrentes (chariot, moulin, rouet) ? D'après
   SPECIFICATION_OPERATIONS § 4, il faut une ambiguïté rapportée, mais on ne sait pas si elle laisse
   `etablie_sous_hypotheses` ou rien. Le cas retient `inconnue`.

4. **Partie obligatoire et polysémie du nom de partie** (ep-001). « Deck » n'implique un navire que dans un de ses
   sens. Les cas traitent ce choix comme une hypothèse de sens (D30). Mais les documents ne disent pas si le
   **contexte** (des marins, la mer) peut écarter le sens « porch » sans hypothèse. Cela relève de C7, que la phase
   ne spécifie pas. Le statut `etablie_sous_hypotheses` est donc conditionnel à l'absence de désambiguïsation.

5. **Ce qui fait d'une partie une partie « obligatoire ».** SPECIFICATION_OPERATIONS § 2 donne l'exemple du pont
   d'un navire. Pour « mainmast » (ep-002), la glose WordNet donne le tout (« of a sailing vessel »). Mais aucun
   document ne dit d'où vient l'attestation de l'obligation (la méronymie de WordNet ? la glose ? une validation ?),
   ni si une glose qui nomme un tout suffit. Les cas marquent ces implications `attestee: true` par hypothèse de
   rédaction.

6. **« Sans X », « il n'a pas de X » pour une partie** (ep-004, variante de modalité ; ep-012, variante de
   modalité). La négation porte sur une entité restreinte (une barbe de cet homme ; une matière de ce vêtement).
   NOYAU § 1.1 ne tire rien d'une entité restreinte niée, et D41 reconnaît que la réfutation d'une conjonction qui
   couvre exactement une description niée n'est pas dérivée. Selon la valuation cible (FONDEMENTS § 1.1), la
   définition est fausse pour ce référent : les variantes disent `ecartee`. C'est donc un écart assumé entre la cible
   et le noyau 0.3. Est-ce bien la cible voulue ? Et `ecartee` demande-t-il l'extension `negation_dans_la_requete`,
   ou seulement une règle de plus dans la table de NOYAU § 1.1 ?

## B. Position relative

7. **Le cadre de référence** (ep-009, decision_ouverte ; ep-008). AUDIT § 3.5 (3) signale « la gauche du spectateur
   ou celle du personnage » sans trancher. « À droite » sans point de référence, sur un tympan à Christ frontal,
   peut se lire dans les deux cadres. Les documents ne disent pas :
   - quel cadre prendre par défaut ;
   - si l'ambiguïté de cadre est une polysémie soumise à la supervaluation (D30) et à l'hypothèse de sens ;
   - si la latéralité d'une partie du corps (« sa main gauche », ep-010) est toujours intrinsèque.
   Le même problème vaut pour devant et derrière. Une figure qui s'éloigne a son « devant » orienté. « Kneeling
   before » est-il une relation d'orientation (faire face) ou de position ?

8. **L'exclusion mutuelle des relations spatiales, et l'inversion des rôles** (ep-005, ep-007, ep-008, ep-009,
   ep-010). Si K contenait que droite et gauche, devant et derrière, au-dessus et au-dessous s'excluent (ou
   l'asymétrie : above(X,Y) ⇒ ¬above(Y,X)), une inversion des rôles donnerait `ecartee` par contraposition. Or
   BANCS_PHASE1 § 4 et QUALIFICATION_SEMANTIQUE § 2.2 posent qu'un rôle inversé donne `inconnue`. Les cas
   s'abstiennent donc d'écrire ces exclusions dans K, ce qui préserve le principe. Mais il faut décider si le
   principe vaut « faute de K » ou « même avec K ». La géométrie élémentaire des relations spatiales est-elle une
   connaissance analytique (FONDEMENTS § 1.2 : les inclusions analytiques valent dans tout contexte) ?

9. **« Sur » et « au-dessus de »** (ep-006). Une couronne posée sur la tête est-elle « au-dessus de la tête » ? Le
   contact est-il inclus dans « au-dessus », ou exclu (« held above » suggère l'absence de contact) ? Le cas ne
   dépend pas de la réponse, parce que la tenue manque. Mais une définition « crown above the head » contre une
   description « crown on her head » en dépendrait directement.

10. **Les converses** (ep-005, paraphrase). Les cas traitent above(X,Y) ⇔ below(Y,X) comme une équivalence établie,
    donc une canonisation. FONDEMENTS § 3.2 n'énumère pas les converses parmi les canonisations. Faut-il les y
    ajouter, avec quelle attestation ? Et la paire below / beneath, deux synsets à la même glose, est-elle une seule
    relation ?

## C. Prépositions polysémiques

11. **Les restrictions de sélection sont-elles des connaissances de K ?** (ep-011, ep-013, ep-015, ep-016). Pour
    que la supervaluation établisse « de matière » ou « de possession » sans hypothèse, il faut que K exclue les
    autres sens par des conditions sur les arguments (« la possession exige un possesseur animé », « une épée n'est
    pas une partie d'une personne »). Les documents disent que K ordonne les sens des prépositions comme des types
    (FONDEMENTS § 2.4, AUDIT § 3.5), sans dire si ces contraintes en font partie, ni d'où elles viendraient. Sans
    elles, chacun de ces cas tombe à `etablie_sous_hypotheses` (sens). Les cas les écrivent dans K, comme
    attestées : c'est une hypothèse de rédaction à valider.

12. **Le composé lexicalisé contre la lecture compositionnelle** (ep-011). « Couronne d'épines » correspond à une
    entrée lexicalisée de WordNet (crown_of_thorns%1:06:00::, mais aussi une plante et un état). La lecture doit-elle
    prendre l'unité lexicale (et ses trois sens, avec l'hypothèse de sens qui en suit) ou la construction « N de N »
    (et la relation de matière) ? Les deux donnent des statuts différents. Le cas suppose la lecture
    compositionnelle.

13. **La possession inaliénable** (ep-013, ep-014, ep-015). « La tête du Baptiste », « lui tranche la tête » : partie
    ou possession ? Les cas tranchent par une implication attestée pour les noms de noun.body (partie). Les documents
    ne disent pas si le datif de possession inaliénable du français (« lui tranche la tête ») se lit comme une
    relation partie_de.

14. **La représentation, quatrième sens de « de »** (ep-013, variante « sculpted head »). Le sens représentation
    (« portrait of », « a sculpted head of the Baptist ») ne figure dans aucune construction de développement
    (`de_matiere`, `de_partie`, `de_possession`). Il interagit avec les modificateurs privatifs ou de mode
    d'existence (« sculpted »), sans que les documents disent comment.

## D. Temps entre événements

15. **« Avant de » quand le second événement n'est pas figuré** (ep-017, variante de temps ; ep-019 ; ep-024).
    ONTOLOGIE_EVENTUALITES § 2 donne quatre ancrages : en cours, antérieur, imminent, hors du temps figuré. Il n'y a
    pas d'ancrage « postérieur » au moment figuré. Or « avant de » introduit souvent un événement à venir (« il saisit
    le poisson avant de le vider », dans une seule scène). Cet événement est-il figuré, hors du temps figuré, ou dans
    un contexte d'intention ? Les cas n'emploient « avant de » qu'avec deux événements figurés (narration continue,
    registres) et laissent cette question ouverte.

16. **L'ordre de lecture des registres et de la narration continue** (ep-018, ep-017). Deux registres ou deux
    figures du même personnage ne disent pas leur ordre. Une convention (de haut en bas, de gauche à droite) est-elle
    une connaissance typique admissible pour une abduction ? Faut-il, à l'inverse, que la succession soit dite ? La
    relation « succession de situations » (ONTOLOGIE § 2) implique-t-elle la précédence des événements qu'elles
    contiennent ? Le cas ep-018 retient `inconnue`, faute de K.

17. **« Pendant que » : inclusion ou recouvrement ?** (ep-022, variante d'inversion). « A pendant que B » dit-il que
    A est inclus dans B (asymétrique), ou seulement que A et B se recouvrent (symétrique) ? Selon la réponse,
    « les soldats dorment pendant que le Christ sort » satisfait ou non « Christ rising while the soldiers sleep ».
    La variante retient `inconnue`, le statut prudent ; avec un recouvrement, ce serait `etablie`. Les documents ne
    donnent que « S tient pendant E » (ONTOLOGIE § 2).

18. **L'ordre temporel est-il un ordre strict analytique ?** (ep-017 et ep-018, variantes d'inversion). Si
    « avant » est un ordre strict dans K, l'inversion (« il vide le poisson avant de le saisir ») contredit la
    définition et donne `ecartee`. Sans cela, elle donne `inconnue`. C'est le même conflit qu'en 8, avec le principe
    du rôle inversé.

19. **La précédence entre un événement antérieur et un événement en cours.** Si un événement est ancré « antérieur »
    et un autre « en cours », la précédence s'ensuit-elle par la seule logique de l'ancrage ? Les documents ne le
    disent pas. Aucun cas n'en dépend (une variante qui en dépendait a été retirée de ep-024), mais la question se
    posera dès que l'ancrage temporel sera spécifié.

## E. Cause et but

20. **Le but n'est pas figuré : quel contexte ?** (ep-019, ep-020, ep-021). Le contenu d'un but (« pour le
    frapper ») est traité comme un événement participant sous un contexte propre (AUDIT § 3.3, (4)). Les documents
    nomment les contextes ouverts par « vision, rêve, ordre, tentative, parole, inscription », mais pas le **but**.
    Faut-il un contexte « visé » distinct ? La liste des extensions du validateur n'a rien de propre au but : les cas
    combinent `relation_entre_eventualites` et `evenement_participant`.

21. **La finalité dite par une source citée** (ep-021, decision_ouverte). La source dit-elle quelque chose de la
    scène figurée (énonciateur cité, portée represente, d'où `non_certifiee`), ou de son propre monde (d'où
    `inconnue`) ? NOYAU § 4.4 couvre le premier cas pour une assertion simple, mais ne dit rien d'une relation de but
    entre un événement de l'auteur et un contenu de la source (un chemin de contextes mêlé). La même question vaut
    pour ep-022 (variante de portée : `non_certifiee`, parce que la notice citée décrit le retable lui-même).

22. **La négation dans le monde figuré et le contenu du but** (ep-021). « No ship is visible » nie les navires du
    monde figuré. La flotte visée par le but est dans un autre contexte, que cette négation ne devrait pas atteindre
    (FONDEMENTS § 2.5, accessibilité). Mais les documents ne disent pas, dans l'autre sens, si une négation du monde
    figuré peut **réfuter** une définition qui demande que la flotte soit figurée. La définition de ep-021 ne le
    demande pas.

23. **Le but et la phase préparatoire** (ep-020). « Lève son bâton pour frapper » combine imminence et but.
    L'ontologie distingue bien la phase préparatoire de l'événement en cours (§ 1.2). Mais on ne sait pas si un geste
    suspendu dont le but est dit vaut « en cours » pour un événement de changement (la frappe), ni comment
    `ancrage_temporel` et `evenement_participant` se combinent sur une même éventualité.

## F. Questions de forme rencontrées

24. **Le pivot d'une construction prépositionnelle.** Les prépositions (« of », « de », « before », « while »,
    « pour ») n'ont pas toujours d'entrée dans WordNet. Les cas prennent comme pivot :
    - l'adverbe correspondant (above%4:02:01::, behind%4:02:00::, before%4:02:01:: et before%4:02:03::,
      simultaneously%4:02:00::) ;
    - un nom (purpose%1:09:00:: pour le but) ;
    - le nom de la tête ou du complément (thorn, leaf, head, sword, ring).

    BANCS_PHASE1 § 4 ne dit pas lequel est « le mot qui porte le phénomène principal » pour une relation. Pour
    « while », WordNet n'a qu'un nom de durée (noun.time) ; « simultaneously » a été préféré. Ce choix est
    conventionnel. Le pivot d'un contre-modèle est parfois un mot de la définition seule (ep-012 : leaf). Pour ep-012,
    « skin » au sens de peau animale relève de noun.animal, en qualification.

25. **La sorte d'une connaissance d'alias et de désignation.** Les sortes acceptées par le validateur n'ont ni
    « alias » ni « désignation » (nom propre → individu). Les cas ep-013 (« the Baptist ») et ep-010 (Pierre, apôtre)
    les écrivent comme `equivalence_etablie` ou `implication`. Il faudrait une sorte propre, ou dire que l'alias reste
    une primitive du noyau hors des sortes de FONDEMENTS § 2.7.

26. **Positif et statut sous hypothèses.** Les documents ne disent pas si un cas `positif` peut avoir pour statut
    `etablie_sous_hypotheses`. ep-001 le fait, l'hypothèse étant de sens seulement. Pour une hypothèse abductive
    (ep-003, option b), la sorte serait plutôt `indetermine`.

27. **Le contradictoire interne en variante** (ep-010, variante `composition`). Aucune variation du § 2.2 ne
    correspond à « l'auteur se contredit ». La variante est classée `composition`.
