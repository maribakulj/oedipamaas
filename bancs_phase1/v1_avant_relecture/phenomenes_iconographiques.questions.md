# Phénomènes iconographiques : les questions ouvertes rencontrées en écrivant les cas de développement

Les cas sont dans `phenomenes_iconographiques.json` (pi-001 à pi-024). Ce fichier liste les points où les documents
(BANCS_PHASE1, FONDEMENTS_SEMANTIQUES, ONTOLOGIE_EVENTUALITES, SPECIFICATION_OPERATIONS, QUALIFICATION_SEMANTIQUE,
NOYAU, ASSERTIONS, AUDIT_EXPRESSIVITE) sont muets, ambigus ou en tension. Quand le statut en dépendait, le cas porte une
`decision_ouverte`, et son `statut_attendu` est l'option la plus faible.

## A. Les questions qui fixent un statut (cas avec `decision_ouverte`)

1. **L'identité d'un personnage à travers les situations, quand le texte ne la dit pas** (pi-003 ; et, par contraste,
   pi-001 et pi-004). Deux figures qui portent le même nom propre (« saint Martin » à gauche, « saint Martin » à
   droite) figurent-elles le même individu ? FONDEMENTS § 8 et ONTOLOGIE § 6 laissent la question ouverte. Trois
   réponses sont possibles : la désignation commune d'un même individu historique suffit (`etablie`) ; le même nom fonde
   une hypothèse d'identité, symétrique de la « distinction supposée » du noyau pour des noms différents
   (`etablie_sous_hypotheses`, mais aucune sorte d'hypothèse du protocole ne s'appelle ainsi : `identite` ?) ; il faut
   une identité dite (`inconnue`, retenu). Question liée : une reprise par pronom ou par « le même » d'une situation à
   l'autre (pi-001, pi-004) est-elle une coréférence (qui fusionnerait les figures, ce qu'ONTOLOGIE § 3 interdit) ou
   l'assertion de la relation « même individu dans une autre situation » ? La lecture doit trancher, et les documents ne
   disent pas comment.

2. **La satisfaction relative à une situation** (pi-005, et les variantes de registres de pi-004). Une définition sans
   relation explicite entre ses éléments (« Hagar and Ishmael in the wilderness, with an angel and a spring ») est-elle
   satisfaite quand ses éléments sont répartis sur deux registres ? ONTOLOGIE § 4 et § 6 le laissent aux bancs. Si la
   réponse est « par situation », il faut aussi dire quand une définition l'exige : toujours, ou seulement pour les
   définitions de scène (et non pour les attributs ou les genres) ? Le comportement actuel (tout le graphe) donnerait
   `etablie`, l'option prudente `inconnue`.

3. **Une scène figurée seulement dans une figuration emboîtée satisfait-elle une définition de scène ?** (pi-007 ;
   aussi pi-006, pi-008, pi-009, et les variantes de vision de pi-010.) FONDEMENTS § 1.2 et § 2.5 séparent les domaines
   des contextes, mais ne disent pas si une définition qui ne nomme aucun contexte (« Christ crucified between the two
   thieves ») est satisfaite par un Calvaire peint dans un tableau figuré. Pour Iconclass, un tableau dans le tableau est
   souvent indexé par son sujet ; pour la sémantique, ce n'est pas le monde figuré de premier niveau. Même question pour
   la tapisserie figurée et le miroir (non couvert : pas de construction de développement pour le miroir).

4. **Le statut qui suit une ambiguïté rapportée** (pi-014, pi-020, pi-022). SPEC § 4 dit que deux explications de même
   coût menant à des notations différentes (ou à aucune) rendent une « ambiguïté rapportée, jamais tranchée en
   silence », mais ne dit pas quel est alors le statut de la requête qui correspond à l'une d'elles :
   `etablie_sous_hypotheses` avec la concurrente dans la preuve, ou `inconnue` ? Le choix change tous les cas
   d'identification par attribut partagé (deux saints, un même attribut), de nom partiel, et d'iconologie abduite.
   `inconnue` est retenu partout ; si l'autre option est choisie, ces cas et leurs variantes passent à
   `etablie_sous_hypotheses`.

5. **Le nom partiel** (pi-014). « St John », forme commune à l'Évangéliste et au Baptiste : quelle sorte d'hypothèse
   fonde-t-il (`identite` ? `abduction` ?), et la connaissance « forme partielle de deux noms documentés comme distincts »
   est-elle un alias non établi, une distinction documentaire, ou une relation inconnue ? Le noyau (§ 2) n'a que l'alias
   établi et les distinctions documentées ; ni l'un ni l'autre ne dit « forme partielle ». J'ai écrit `relation_inconnue`,
   faute de mieux (voir C.1).

## B. Les points où les documents sont muets ou ambigus, sans changer le statut de base

6. **Le contexte de la succession entre épisodes** (pi-004, pi-005). « The lower tier shows the next scene of the
   story » : la succession est-elle une relation entre situations figurées (dans le figuré), ou un fait du récit (le
   contexte de la source, qui n'appuie rien dans le figuré, FONDEMENTS § 2.5) ? J'ai écrit les descriptions pour que
   l'auteur l'affirme des scènes figurées. Mais une juxtaposition sans ordre dit (deux registres seulement) laisse-t-elle
   l'ordre inconnu, ou l'ordre de lecture (haut avant bas, gauche avant droite) est-il une connaissance typique ? Et
   « précède » contre « suit » (variante d'inversion de pi-004) : sans une connaissance d'asymétrie dans K, l'inversion
   donne `inconnue` ; avec elle, `ecartee`. K devrait-il contenir l'asymétrie de la succession comme implication
   analytique ?

7. **La distinction entre figures et la distinction entre individus** (pi-002). `distinct/2` (ASSERTIONS, NOYAU § 1)
   est une distinction entre référents. Dans une narration continue, deux figures sont toujours deux figures ; « another
   young man » dit deux individus. Il faut que la relation « même individu dans une autre situation » soit réfutable
   par une distinction dite, sans que deux figures soient tenues pour distinctes au sens de `distinct/2` par le seul fait
   d'être deux figures. J'ai écrit `ecartee`, en supposant que « another » réfute l'identité d'individu.

8. **Le contenu d'une inscription et le nom d'une figure** (pi-017, pi-018). FONDEMENTS § 8 laisse ouvert « le contenu
   textuel des inscriptions ». Quand l'auteur écrit « une banderole porte son nom : S. NICOLAVS », l'assertion est de
   l'auteur et suffit (`etablie`). Quand il écrit seulement « une banderole porte l'inscription S. NICOLAVS », le lien
   entre le texte inscrit et le nom de la figure voisine est une connaissance typique (variante de pi-017 :
   `etablie_sous_hypotheses`) — ou bien la lecture doit-elle l'établir (le titulus est une convention) ? Et une
   signature dans la planche (« HIERONYMUS … FECIT », pi-018) : la distinction entre inscription sur l'œuvre (portée
   oeuvre) et inscription figurée (une banderole dans la scène) n'est pas dite pour un vitrail, où la banderole est à la
   fois peinte et partie du support.

9. **Une étiquette ou un titre ajouté par un tiers** (variante de pi-017, variantes de pi-013 et pi-022). Une
   étiquette de restaurateur qui « désigne » la figure : est-ce une source citée (`non_certifiee`, retenu), un titre
   (`modalite(titre)`, qui donne `inconnue`), ou de l'histoire de l'œuvre ? ASSERTIONS n'a pas de modalité ou de portée
   pour « dit par un tiers sur l'œuvre ».

10. **Les prémisses graduées** (variantes « peut-être », « probably », « traditionnellement », dans presque tous les
    cas). AUDIT § 3.6 (5) annonce une opération qui ferait entrer `probable` et `traditionnel` dans les hypothèses
    d'une preuve ; elle n'est spécifiée ni dans SPEC ni dans la liste des sortes d'hypothèses du protocole (aucune sorte
    « prémisse graduée »). J'ai donc écrit `inconnue` pour ces variantes. Si l'opération est adoptée, elles passent à
    `etablie_sous_hypotheses`, avec une sorte d'hypothèse à créer.

11. **Le niveau iconologique énoncé et nié** (pi-019, et sa variante niée). Un concept signifié (la fugacité) est un
    référent conceptuel, « sans présence à vérifier » (AUDIT § 3.7). Mais la règle de négation du noyau (§ 1.1) demande
    que les entités d'une relation niée soient présentes : une relation de signification niée (« ces objets ne sont pas
    des signes de la fugacité ») donne-t-elle un appui négatif ? J'ai écrit `ecartee`, en supposant qu'un référent
    conceptuel compte comme admissible pour la négation. À fixer avec l'extension des référents conceptuels.

12. **La signification portée par le cadre ou une devise** (variante de pi-020 : un cadre du XIXe siècle portant
    MEMENTO MORI). Une devise sur le cadre dit-elle quelque chose du signifié de l'image (le niveau iconologique), ou
    seulement de l'œuvre et de son histoire ? `inconnue` retenu ; le contexte du « signifié » (FONDEMENTS § 2.5) n'a pas
    de règle d'admissibilité écrite.

13. **Le lieu nié d'un lieu absent** (pi-024, et la réflexion qui l'a précédé). « L'artiste n'a pas situé la prédication
    à Alexandrie » nie une relation dont une entité (Alexandrie) n'est pas présente : selon NOYAU § 1.1, aucun appui
    négatif ; selon la valuation de Belnap de FONDEMENTS § 1.1, l'atome est dit faux. J'ai écrit pi-024 pour éviter la
    tension (le nom est nié d'une ville présente : « la ville n'est pas Alexandrie »), mais la tension reste : la cible
    garde-t-elle l'exigence de présence pour les entités d'une relation niée quand l'entité est un lieu réel ou un
    concept ?

14. **Les faits encyclopédiques et le lieu réel** (pi-023, pi-024). FONDEMENTS § 1.2 dit que les faits du monde réel ne
    sont pas importés dans la scène. Mais une définition comme « a view of Venice » demande l'identité du lieu figuré
    avec un lieu réel : c'est la désignation (FONDEMENTS.md § 4.2) appliquée aux lieux, que les documents ne décrivent
    que pour les personnes. Faut-il une relation « le lieu figuré désigne Venise » distincte de « l'œuvre est à Venise » ?
    Les cas supposent que oui ; aucune extension du validateur ne la nomme (je n'ai mis que `aucune`, la portée
    `histoire` suffisant pour le contre-modèle).

15. **Le sens d'un mot dans le contenu d'un rêve** (pi-012). La supervaluation des sens (D30) s'applique-t-elle dans un
    contexte emboîté comme dans le figuré ? « Winged dragon breathing fire » : le sens du lézard planeur n'atteint pas
    « imaginary creature », d'où `etablie_sous_hypotheses [sens]`. Mais « breathing fire » exclut ce sens par une
    connaissance du monde absente de K ; la désambiguïsation (C7) devrait-elle pouvoir s'appuyer sur les autres
    propriétés dites, et alors la conclusion deviendrait-elle `etablie` ?

16. **Le niveau préiconographique et le genre** (pi-021, pi-022). Le passage de « Judith » à « une femme » est une
    inclusion (`etablie`), le passage inverse une abduction. Mais K dit-il que Judith est une femme ? Je l'ai écrit dans
    K comme attesté (« inclusion lexicale ») sans pouvoir le vérifier (sens.py ne donne que les sens, non les
    hyperonymes). De même, « Holofernes » (un général) n'est pas, par l'hyperonymie, un homme : une définition
    « a man's severed head » ne serait pas satisfaite par « the head of Holofernes ». Les connaissances de genre
    (masculin, féminin) des noms de personnes ne sont dans aucune ressource citée par les fondements.

17. **Un attribut nié et l'identification** (pi-016). La négation de la tenue (« he does not hold the gridiron ») réfute
    la requête ; mais une négation de l'attribut lui-même (« no keys ») ne réfute pas l'identité, puisqu'une
    connaissance typique ne propage aucune négation (FONDEMENTS § 3.3). Les cas le supposent ; c'est cohérent avec les
    documents, mais aucun ne le dit pour les attributs identifiants en particulier.

## C. Les points de forme (protocole et validateur)

1. **Les sortes de connaissances du validateur** n'ont ni l'alias, ni la distinction documentaire, ni la forme
   partielle d'un nom, qui sont pourtant des primitives de K (NOYAU § 2 : `alias`, `distincts_documentes`). J'ai écrit
   les alias comme `equivalence_etablie` (pi-001, 005, 013, 017, 018, 024) et la forme partielle comme
   `relation_inconnue` (pi-014). Faut-il ajouter ces sortes ?

2. **Les extensions d'un cas et celles de ses variantes.** `extensions_requises` est au niveau du cas. Plusieurs
   variantes demandent une extension que le cas de base ne demande pas (pi-017 : la variante de portée demande le
   contexte de l'inscription et l'abduction ; pi-009 : la variante de portée demande le contexte emboîté ; pi-013 et
   pi-018 : les variantes de portée). Une phase qui sélectionne les cas par leurs extensions manquera ces variantes. Faut-il
   des `extensions_requises` par variante ?

3. **Les extensions d'un cas à `decision_ouverte`.** Pour pi-014, pi-020 et pi-022, le statut retenu (`inconnue`) ne
   demande aucune extension, mais l'autre option en demande (abduction, référent conceptuel). J'ai écrit les extensions
   nécessaires pour poser la question (pi-020, pi-022) sauf pour pi-014 (`aucune`). La règle « ce sans quoi le statut ne
   peut pas être atteint » ne dit pas laquelle des options compte.

4. **La liste des extensions acceptées par le validateur** n'est pas dans les documents que les rédacteurs reçoivent
   (le protocole renvoie à « la liste du validateur », dont je n'ai pas lu le code). Je l'ai retrouvée en essayant des
   noms et en lisant les erreurs : `ancrage_temporel`, `quantification_enoncee`, `evenement_participant`,
   `base_de_definitions`, `contexte_emboite`, `referent_conceptuel`, `collection`, `situation_referent`,
   `identite_entre_situations`, `modificateur_non_intersectif`, `relation_entre_eventualites`, `etat_reifie`,
   `abduction`, `negation_dans_la_requete`, `aucune`. Je n'en ai trouvé aucune pour le contenu d'une inscription ni pour
   les sens des relations ; la liste devrait être écrite dans le protocole.

5. **L'étiquette des variantes qui ajoutent une information** (pi-003, pi-014, pi-015, pi-020, pi-022 : un nom, un
   attribut, une identité dite). Aucune variation du § 2.2 ne s'appelle « ajout d'un indice » ; j'ai employé
   `composition` ou `changement_de_participant`, dont ce n'est pas exactement le sens.

6. **Le miroir et l'identification par le contexte narratif** sont dans les phénomènes couverts (BANCS § 2) mais
   n'ont pas de construction dans la vue de développement : aucun cas de développement ne les porte comme phénomène
   principal. Leur qualification ne mesurera donc que la généralisation.
