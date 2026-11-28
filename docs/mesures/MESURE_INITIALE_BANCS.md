# La mesure initiale du moteur sur les bancs de la phase 1 : le niveau (c), point de départ (28/11)

**Ce que c'est.** Le moteur actuel, passé une fois sur les 216 cas de développement et leurs 1 278 variantes
(1 494 textes), sans changer aucune de ses règles. C'est le niveau (c) de `docs/INTERPRETATIONS_ADMISSIBLES.md`
(§ 2.4) et le point de départ de `docs/BANCS_PHASE1.md` (§ 7, § 9.4). C'est un constat, non un objectif. **Aucune
référence n'a été modifiée d'après ces résultats,** et aucun fichier de cas n'a été écrit (empreintes SHA-256 prises
avant et après : identiques).

**Ce qu'il faut retenir.**
- **Le moteur conclut 31 fois sur 1 494,** toutes sur des textes anglais : 20 `etablie`, 10 `etablie_sous_hypotheses`,
  1 `ecartee`. Les 1 463 autres sont `inconnue`. Il n'y a ni erreur, ni interruption, ni budget épuisé, ni graphe vide.
- **Contre (b)** (`statut_attendu`, relatif à K0-d30) : 1 056 accords, dont 9 seulement ne sont pas `inconnue` des deux
  côtés ; 418 fois (c) est plus faible ; **20 fois (c) est plus fort** (§ 5), dont **12 erreurs de sûreté au sens strict**
  de BANCS § 7.
- **En français, rien ne conclut** (0 sur 751). La définition est en anglais et K français ne lexicalise que vers des
  lemmes français : 5,8 % des atomes lexicaux des requêtes trouvent un appui. C'est une limite du dispositif (la
  définition n'a pas de version française, qu'un vrai libellé aurait), non une mesure du lecteur français (§ 2.3).
- **La représentabilité** (jugée sur le texte, § 6) : 131 cas représentables, 34 en projection partielle,
  51 non représentables. Accord avec `extensions_requises` sur le besoin d'une extension : 146 cas sur 182 classés
  représentables ou non représentables (158 si l'on retire la base de définitions et l'abduction, qui sont des
  opérations).
- **L'adaptateur** traite 75 définitions en scène de façon légitime, 100 en scène mais sans l'héritage qu'un vrai
  libellé recevrait, et 41 qu'un vrai libellé ferait passer par un autre chemin du compilateur (§ 2). Plusieurs
  défauts relevés sont ceux du **compilateur réel**, non de l'adaptateur (§ 2.4).

## 1. Le protocole

**La chaîne,** pour chaque cas (`outils/bancs/mesurer_moteur.py`, qui appelle `outils/bancs/mesurer_moteur.pl`) :
1. **Le texte** (la description du cas, puis chaque variante) est lu par le lecteur du moteur, comme
   `outils/graphes/lire.pl` : UDPipe 1 (l'analyseur par défaut, D20 bis), puis `interpretation:interpreter/6`, sans
   option de sûreté (`OEDIPAMAAS_SURETE` absent : le lecteur par défaut, `docs/mesures/SURETE_LECTEUR.md`).
2. **La définition** est compilée par l'adaptateur expérimental (`outils/bancs/adaptateur_scene.pl`, § 2) : analysée
   par Stanza comme les libellés (D18 bis), puis compilée par le chemin « scene » du compilateur.
3. **Le noyau** (`satisfaction:satisfaire/5`, noyau 0.3) évalue la condition suffisante sur le graphe, avec le K de la
   langue du texte (`codage:k/2`). Budgets : celui du noyau (300 000 appuis), 10⁹ inférences et 120 s par paire.
4. **La qualification** (`codage:statut/9`) est notée à côté, comme dans `outils/croise/croiser.pl`.

**Ce qui est enregistré** pour chaque texte : le graphe lu, l'analyse, la validation du graphe, le statut du noyau
(`etablie`, `etablie_sous_hypotheses`, `ecartee`, `contradictoire`, `non_certifiee`, `inconnue`, `incomplet`,
`erreur` ; `sans_requete` si l'adaptateur ne donne pas de requête), ses hypothèses, les atomes satisfaits et manquants
d'une inconnue, la qualification, les temps. Pour chaque définition : son graphe, la suffisante et la nécessaire, le
statut de compilation et ses raisons, la famille, le chemin réel, les limites de l'adaptateur, les défauts relevés
mot à mot.

**Les versions** (dans `resultats.json`, champ `versions`) :
- le moteur : commit `750af13` de `claude/bancs-v3`, sans modification locale de `oedipamaas/` ; les empreintes des
  trois outils de mesure ;
- le noyau 0.3 ; K : « wordnet 3.0 ; wolf omw-1.4 » (en, fr) ;
- la base : `/home/user/donnees/base`, Iconclass `0595358b…` ;
- les analyseurs : UDPipe 1 avec les modèles UD 2.5 (empreintes), Stanza 1.10.1 pour les définitions.

**La comparaison des statuts** se fait par ce qu'ils affirment (INTERPRETATIONS § 2.5), non par leur nom :
- `etablie` affirme une solution certifiable (donc aussi le conditionnel et une substitution vraie) ;
- `etablie_sous_hypotheses`, le conditionnel ; `non_certifiee`, une substitution vraie ; `contradictoire`, une
  substitution vraie et un appui négatif ; `ecartee`, la réfutation ;
- `inconnue`, `incomplet`, `erreur`, `sans_requete` n'affirment rien.
- **(c) plus fort** que (b) : (c) affirme quelque chose que (b) n'affirme pas (une erreur de sûreté potentielle). Deux
  statuts incomparables sont comptés plus forts : la sûreté prime. **Plus faible** : (c) affirme strictement moins.
- **L'erreur de sûreté stricte** est celle de BANCS § 7 : `etablie` pour un statut autre, `ecartee` pour un statut qui
  ne réfute pas. Une conclusion seulement sous hypothèses nommées pour un (b) `inconnue` est plus forte, sans être une
  erreur stricte.

## 2. L'adaptateur, et ce qui n'est pas de lui

### 2.1 Ce qu'il fait

Le compilateur (`requetes_iconclass:compiler/3`) prend une **notation** de la base : il lit son libellé analysé
(`libelles_lus:partie/7`), son type (`definitions:type_libelle/2`) et sa place dans l'arbre (`arbre:ancetre/2`). Les
définitions des bancs sont inventées et n'ont rien de cela. L'adaptateur refait le chemin `compiler_(N, L, scene, …)`
en appelant les prédicats du compilateur sans les modifier :
- la partie propre (`sujets:parties/3`), prétraitée comme un libellé (`libelles_iconclass:pretraiter/3`) ;
- le graphe du lecteur sur la définition (`interpretation:interpreter/5`), puis `graphe_requete/5` ;
- `et_ou_un/2`, `necessaire/2`, `mots_non_couverts/4`, les parenthèses non lues ;
- le statut, comme `compiler/3` (invalide, non prise en charge, compilée, partielle), et la famille (`famille/3`).

**Ce qu'il n'a pas,** et que le compilateur réel aurait pour un vrai libellé : l'héritage de la personne ou du récit
ancêtre (`heritage/4`), les aspects des parties de gabarit (`aspects/4`), le type du libellé (il force « scene »), la
version française du libellé.

### 2.2 La légitimité, définition par définition

Chaque définition est jugée (`docs/mesures/representabilite_dev.json`, champ `adaptateur`) : un vrai libellé de ce
genre passerait-il par le chemin scene ? À côté, le chemin **mécanique** : `libelles_iconclass:type_de_libelle/4` sur
l'analyse de la définition, avec une notation fictive.

| jugement | définitions | chemin mécanique scene / classe | compilées / partielles | (c) conclut |
|---|---|---|---|---|
| `legitime` : la scène, sans contexte utile | 75 | 66 / 9 | 34 / 41 | 13 |
| `legitime_sans_heritage` : la scène, mais un vrai libellé serait une subdivision d'une personne ou d'un récit | 100 | 91 / 9 | 38 / 61 (+ 1 non prise en charge) | 12 |
| `autre_chemin` | 41 | 29 / 12 | 17 / 24 | 6 |

**Les 41 « autre chemin », par chemin :**
- **les personnifications et les concepts** (division 5) : non pris en charge par le compilateur réel (`type(concept)`)
  — ee-022, mn-003, nr-016 à nr-021, rq-013, sa-023 ; les couleurs symboles (nr-022 à nr-024) ;
- **les lettres doublées** (25FF, 11HH) : non pris en charge — les animaux fabuleux (co-003 à co-005, dc-001,
  dc-006, dc-008, mn-018), les saintes (dc-004, mn-023, nr-015, sa-017) ;
- **les individus** (11H(…), 92C…) : le compilateur réel ne garde que les noms, les attributs n'étant que possibles —
  dc-013 à dc-016, dc-019, pi-014 à pi-017, rq-017 ;
- **les gabarits** (`(...)`) : dc-017 (un monument), dc-018 (`25G3(LAUREL)`) ;
- **les genres et les classes** : dc-010, pi-019 (« still life »), nr-009 (« battle scene: »), pi-020 (« objects …: »),
  pi-004 (un récit, « the story of Joseph »).

**Les 9 + 9 « légitimes » que le type mécanique range en classe** sont des définitions sans verbe fini, où Stanza
étiquette le participe en nom (« hermit reading », « aged hermit kneeling », « John the Baptist preaching »). Un vrai
libellé de cette forme irait au chemin classe. Pour un seul segment sans « : », ce chemin lit le même graphe ; la
différence est faible.

### 2.3 Le français : une limite du dispositif

751 textes sont en français, contre une définition anglaise. Le moteur prend le K de la langue du texte (`codage:k/2`).
`connaissances_fr` relie un mot français à ses sens par WOLF, puis un sens à ses lemmes **français** (`sous/3`) : il
n'atteint jamais un lemme anglais de la requête. Seuls les noms propres et les rôles passent.
- **Le résultat :** aucune conclusion en français ; 28 % des atomes satisfaits dans les inconnues, et 5,8 % des atomes
  lexicaux (types, événements, propriétés), contre 65 % et 62 % en anglais.
- **À qui l'imputer :** un vrai libellé a sa version française, que `compiler(N, fr, …)` compile. Le défaut est celui
  de l'adaptateur et du banc (une définition sans version française), non celui du compilateur. Le niveau (c) français
  ne mesure donc ici ni le lecteur français ni WOLF. Le mesurer demanderait des définitions traduites, ou un K
  bilingue : l'un change les cas, l'autre les connaissances, et ni l'un ni l'autre n'est fait ici.
- Les 108 cas de base français ont des traductions anglaises parmi leurs variantes : c'est par elles seules que ces
  cas sont mesurés.

### 2.4 Les défauts du compilateur réel, que l'adaptateur ne fait que montrer

Ils viennent du chemin scene lui-même (le lecteur appliqué au libellé, puis `graphe_requete/5`) : un vrai libellé de
la même forme les aurait.
- **Le graphe de la requête n'est pas connexe** : 126 définitions sur 216 sont partielles, dont 124 par `non_lie`. Le
  lecteur ne relie pas un complément (« watching over a tomb », « leading a child by the hand »).
- **Les nombres ne sont jamais compilés.** `graphe_requete/5` n'a pas de condition pour `nombre/2`, et le lecteur
  par défaut n'en écrit pas (seulement avec l'option `nombres`). 17 définitions disent un nombre ; aucune requête n'a de
  contrainte `nombre`.
- **Les mots que `mots_non_couverts/4` ne contrôle pas** (seuls NOUN, VERB, ADJ le sont) : 19 définitions perdent un
  nombre, un nom propre ou un mot étiqueté interjection, et 8 d'entre elles sont pourtant déclarées `compilee`.
  - Exemple : rq-014, « Christ at table with the twelve apostles », devient
    `type(table) ∧ type(apostle) ∧ relation(table, with, apostle)`. Stanza étiquette « Christ » en interjection, et
    « twelve » n'est pas compilé. La requête est déclarée complète : c'est l'erreur de sûreté de rq-014 (§ 5).
  - « Christ » perdu de même dans ep-011.
- **Le « : » d'un libellé de scène lu comme une apposition** : 8 des 10 définitions à « : » reçoivent une contrainte
  `meme` entre le terme d'avant et un terme d'après (nr-002 : `meme(Adoration, king)` ; mn-010 : `meme(Nativity,
  child)` ; pi-020 : `meme(transience, skull)`). Ces requêtes sont insatisfiables par construction. Le type mécanique
  de ces libellés est scene (ils ont un verbe) : le compilateur réel ferait la même chose.
- **Les participes et gérondifs devenus des types** (19 définitions : `type(standing)`, `type(reading)`,
  `type(kneeling)`) et **« St » devenu un type** (25 définitions : `type(st) ∧ nom(MARGARET)`). Ce sont des défauts de
  lecture des deux côtés : « St » est lu de même dans les textes anglais, et `type(st)` y est satisfait par identité
  (mn-023).
- **L'énumération compilée en conjonction** (co-018, « hermit, monk or nun reading a book » : trois types
  conjoints), déjà relevée par `docs/EXPERIENCE_CROISEE.md` (§ 6, point 1).
- **La simultanéité, le but, l'ordre** (« while », « in order to », « before ») ne laissent aucune trace dans la
  requête : la requête est plus faible que la définition, sans raison de partialité (sa-015, § 5). C'est une limite du
  langage (§ 6), et le compilateur ne la signale pas.

## 3. Les comptes

**Par famille** (cas et variantes) :

| famille | textes | etablie | sous hypothèses | ecartee | inconnue | accord (b) | (c) plus fort | (c) plus faible |
|---|---|---|---|---|---|---|---|---|
| compositionnalite | 165 | 1 | 5 | 0 | 159 | 111 | 5 | 49 |
| definitions_classification | 165 | 4 | 0 | 0 | 161 | 120 | 1 | 44 |
| espace_partie_temps | 171 | 2 | 1 | 0 | 168 | 124 | 2 | 45 |
| evenements_etats | 181 | 0 | 3 | 1 | 177 | 126 | 3 | 52 |
| modalite_negation_contextes | 149 | 3 | 1 | 0 | 145 | 104 | 2 | 43 |
| niveaux_representation | 144 | 0 | 0 | 0 | 144 | 96 | 0 | 48 |
| phenomenes_iconographiques | 169 | 0 | 0 | 0 | 169 | 144 | 0 | 25 |
| reference_quantification | 183 | 6 | 0 | 0 | 177 | 130 | 5 | 48 |
| structures_argumentales | 167 | 4 | 0 | 0 | 163 | 101 | 2 | 64 |
| **total** | **1 494** | **20** | **10** | **1** | **1 463** | **1 056** | **20** | **418** |

**Par langue du texte :** en, 743 textes : 20 / 10 / 1 / 712 (accord 499, plus fort 20, plus faible 224) ; fr,
751 textes : 0 / 0 / 0 / 751 (accord 557, plus fort 0, plus faible 194). Cas de base : 5 conclusions sur 216, toutes
anglaises (3 `etablie`, 2 sous hypothèses).

**Par sorte :** positif 498 textes (8 / 6 / 0 / 484) ; négatif 176 (3 / 0 / 1 / 172) ; indéterminé 555
(8 / 4 / 0 / 543) ; contre-modèle 265 (1 / 0 / 0 / 264).

**Par classe de représentabilité** (§ 6 ; les variantes héritent de la classe de leur cas) :

| classe | cas | textes | etablie | sous hypothèses | ecartee | inconnue |
|---|---|---|---|---|---|---|
| représentable | 131 | 918 | 15 | 4 | 1 | 898 |
| projection partielle | 34 | 232 | 4 | 0 | 0 | 228 |
| non représentable | 51 | 344 | 1 | 6 | 0 | 337 |

Sur les 7 conclusions de cas non représentables, 4 sont plus fortes que (b) (ee-023 base, #1, #4 ; co-014 #0, § 5) ; les
3 autres sont d'accord avec (b) (co-020 #2) ou plus faibles (ep-018 #2, mn-006 #2).

**Les temps :** 20 s de noyau au total (au plus 0,13 s par paire), 5 s de lecture hors analyse, 0,4 s d'adaptateur ;
2 min 40 s de bout en bout, chargement et analyse compris.

## 4. La matrice (b) contre (c)

(b) en ligne, (c) en colonne, sur les 1 494 textes :

| (b) \ (c) | etablie | etablie_sous_hypotheses | ecartee | inconnue | total |
|---|---|---|---|---|---|
| etablie | **8** | 2 | 0 | 101 | 111 |
| etablie_sous_hypotheses | 0 | 0 | 0 | 270 | 270 |
| ecartee | 3 | 0 | **1** | 25 | 29 |
| non_certifiee | 3 | 0 | 0 | 18 | 21 |
| contradictoire | 0 | 0 | 0 | 2 | 2 |
| inconnue | 6 | 8 | 0 | **1 047** | 1 061 |

- **Accords :** 1 056, dont 1 047 `inconnue` des deux côtés. Les accords informatifs sont 9 : 8 `etablie`, 1 `ecartee`.
- **(c) plus faible :** 418. Ce sont les 270 `etablie_sous_hypotheses` de (b), toutes perdues, 103 `etablie`, 25
  `ecartee`, 18 `non_certifiee` et 2 `contradictoire`.
  - 101 `etablie` de (b) restent `inconnue`, 2 ne sont que sous hypothèses.
  - Parmi les inconnues anglaises, 155 n'ont qu'un atome manquant.
- **(c) plus fort :** 20, examinés au § 5.
- **(c) contre (a) :** à remplir (§ 7).

## 5. Les 20 cas où (c) est plus fort que (b), un par un

| élément | (b) | (c) | strict | qualification | ce qui se passe | où est la faute |
|---|---|---|---|---|---|---|
| rq-014 (base) | ecartee | etablie | oui | etablissable | « ten apostles » contre « twelve » : la requête a perdu « Christ » (interjection pour Stanza) et le nombre ; elle n'exige qu'une table avec des apôtres | compilateur réel (§ 2.4) ; le lecteur ne lit pas non plus le nombre du texte |
| rq-014 #5, #6 | ecartee | etablie | oui | etablissable | les mêmes, avec une figure ou une négation non liée | idem |
| rq-014 #3 | inconnue | etablie | oui | etablissable | le nombre est illisible, le contrat dit douze : la requête sans nombre est satisfaite | idem |
| dc-017 #2 | inconnue | etablie | oui | etablissable | « an invented amphitheatre inspired by the Colosseum » : le Colisée, simple modèle, est lu comme figuré, et la requête n'est qu'un nom | lecteur ; un référent conceptuel, que la variante introduit (le cas de base est représentable) |
| ep-003 #6 | non_certifiee | etablie | oui | etablissable | « According to the old catalogue quoted on the label, the etching shows … » : le contenu cité est lu comme affirmé par l'auteur | lecteur (énonciateur) ; disparaît avec les options de sûreté A |
| ep-016 #6 | non_certifiee | etablie | oui | etablissable | la même construction | idem |
| mn-023 #2 | non_certifiee | etablie | oui | candidat | « According to the inventory of 1620, the panel shows … » | idem ; la compilation partielle empêche le code établi |
| mn-023 #1 | inconnue | etablie | oui | candidat | « According to the Golden Legend, St Margaret emerged … ; here she stands in prayer » : le récit de la source est lu comme figuré | lecteur (portée source) ; avec les options de sûreté, `non_certifiee` |
| sa-015 #2 | inconnue | etablie | oui | candidat | « After Nicodemus has drawn the nail … » contre « while » : l'ordre et la simultanéité ne sont ni lus ni compilés | langage (relation entre éventualités) ; compilation partielle |
| sa-015 #4 | inconnue | etablie | oui | candidat | la scène est sculptée sur le flanc du sarcophage figuré (contexte emboîté) | langage (contexte emboîté) |
| rq-010 #1 | inconnue | etablie | oui | etablissable | « crowned by two angels » : (b) est l'option prudente d'une décision ouverte (lecture collective ou distributive) ; (c) vaut l'autre option, `etablie` | une décision ouverte ; le noyau ne lit qu'une lecture du pluriel |
| ee-023 (base), #1, #4 | inconnue | sous hypothèses (hand → give) | non | conditionnel | la scène est dans la tapisserie accrochée au mur : le lecteur la lit comme figurée | langage (contexte emboîté) ; (b) dépend d'une décision ouverte dont l'autre option est `etablie` |
| co-014 #0 (traduction) | inconnue | sous hypothèses (grave → tomb) | non | conditionnel | « A marble angel … watches over the grave » : la statue est lue comme un ange | langage (référent conceptuel) ; la décision ouverte du cas a `etablie_sous_hypotheses` pour option |
| co-016 (base), #1, #4, #5 | inconnue | sous hypothèses (girl → child) | non | conditionnel | (b) lit le composé « little girl », dont le sens n'atteint pas child ; le lecteur garde la tête « girl », dont un sens (daughter → child, offspring) atteint child. L'hypothèse est nommée, et fausse en contexte | lecteur (le composé lexicalisé) ; D30 sur un autre mot que (b) |

**Le bilan :**
- **12 erreurs strictes :**
  - 4 du compilateur réel (rq-014) ;
  - 4 du lecteur sur le discours cité ou rapporté (ep-003 #6, ep-016 #6, mn-023 #1, #2) ;
  - 3 d'une construction que le langage ne dit pas : un référent conceptuel (dc-017 #2), un ordre d'éventualités
    (sa-015 #2), un contexte emboîté (sa-015 #4) ;
  - 1 d'une décision ouverte (rq-010 #1).
- **8 conclusions sous hypothèses** pour un (b) `inconnue`. Aucune n'est une erreur stricte : l'hypothèse de sens est
  nommée, et elle est fausse en contexte (ee-023, co-014 : la scène ou la figure n'est pas au premier niveau ; co-016 :
  le sens de « girl »).
- **4 des 12 sont qualifiées `candidat`,** non `etablissable`, parce que la compilation est partielle : la règle du
  codage ne les coderait pas comme établies. Les 8 autres seraient `etablissable`.
- **Avec les options de sûreté A du lecteur** (`OEDIPAMAAS_SURETE=nombres,portees,citations,modalites,negations`,
  passe de sensibilité `sensibilite_surete_A.json`, non adoptées), il reste 8 erreurs strictes. Celles d'ep-003,
  d'ep-016 et de mn-023 #2 disparaissent, et mn-023 #1 devient `non_certifiee`. rq-014 reste : le nombre est lu dans le
  texte, mais pas compilé dans la requête.

## 6. La représentabilité

**La méthode** (`docs/mesures/representabilite_dev.json`). Le jugement porte sur la définition et la description du
cas de base, sans lire `extensions_requises`, ni la justification, ni les phénomènes. Il est fondé sur
`docs/AUDIT_EXPRESSIVITE.md` (faits F1 à F6, proposition 1, § 4), `docs/ASSERTIONS.md` et NOYAU § 3.
- **représentable :** tout ce dont le statut dépend peut être dit. Une ambiguïté que le langage dit par une
  alternative, une modalité, un énonciateur, une portée ou une assertion niée compte comme dicible.
- **projection partielle :** une partie ne peut pas être dite (elle est nommée), mais ce n'est pas l'élément qui
  décide du statut.
- **non représentable :** l'élément décisif ne peut pas être dit. Toute projection perd le statut ou affirme plus que
  le texte. Le cas est compté tel, sans projection forcée.
- **Ce n'est pas une limite du langage** quand il ne manque qu'une opération : la classification par définition
  (`base_de_definitions`) ou l'abduction. Elles sont notées à part (`operations_hors_langage`).
- **Ce sont des décisions d'agent, provisoires.**

**Les comptes :**

| famille | représentable | projection partielle | non représentable |
|---|---|---|---|
| compositionnalite | 15 | 2 | 7 |
| definitions_classification | 16 | 3 | 5 |
| espace_partie_temps | 15 | 5 | 4 |
| evenements_etats | 17 | 2 | 5 |
| modalite_negation_contextes | 14 | 2 | 8 |
| niveaux_representation | 10 | 7 | 7 |
| phenomenes_iconographiques | 9 | 6 | 9 |
| reference_quantification | 15 | 4 | 5 |
| structures_argumentales | 20 | 3 | 1 |
| **total** | **131** | **34** | **51** |

Par langue du cas : en, 66 / 17 / 25 ; fr, 65 / 17 / 26.

**Les extensions qui manquent** (jugées, cas non représentables et partiels) :
- référent conceptuel 21, relation entre éventualités 14, contexte emboîté 13, ancrage temporel 12 ;
- plusieurs situations 10, quantification énoncée 9, contenu d'inscription 7, modificateur non intersectif 6 ;
- identité entre situations 5, contexte d'éventualité 4, événement participant 3 ;
- négation dans la requête 2, collection 2, état réifié 1.

**La comparaison avec `extensions_requises`** (le besoin d'au moins une extension) :

| jugé \ cas | aucune | au moins une |
|---|---|---|
| représentable | 104 (accord) | 27 (désaccord) |
| projection partielle | 7 | 27 |
| non représentable | 9 (désaccord) | 42 (accord) |

- **Accords : 146 sur 182** cas classés représentables ou non représentables, et 36 désaccords. Sans `base_de_definitions`
  ni `abduction` du côté des cas : 158 accords et 24 désaccords.
- **Sur les extensions nommées** (cas partiels ou non représentables où le cas en demande) : 30 ensembles identiques,
  35 recouvrements partiels, 4 disjoints.
- **Les désaccords** tiennent à trois différences de critère, non à des erreurs de lecture. Ils sont listés dans
  `resultats.json`, `resume.representabilite_desaccords`.
  - **12 cas ne demandent qu'une opération** (`base_de_definitions`, `abduction`). Ici, ils sont représentables :
    dc-001, dc-002, dc-004, dc-005, dc-008, dc-009, dc-013, dc-015, dc-024, co-013, pi-015, pi-022.
  - **Les états et les pluriels.** Les cas demandent un `etat_reifie` pour des états adjectivaux ou verbaux
    (« frightened » / « a peur », « angry » / « in a rage », « withered », « crowned » : co-021, co-023, co-024, ee-004,
    ee-005, ee-006, nr-001), ou une `collection` pour des pluriels (ep-012, rq-009, rq-010, rq-012, rq-015).
    - Ici, la propriété et les agents multiples suffisent à dire chaque côté. L'écart entre les deux formes est une
      affaire de canonisation, non de langage.
    - Il faut une décision : faut-il compter la canonisation commune comme une extension ?
  - **9 cas non représentables ici sont `aucune` dans les cas :** mn-006, mn-008, mn-009, mn-010, nr-009, nr-024,
    pi-018, rq-022, sa-008.
    - Ce sont surtout des contre-modèles dont le statut (b) `inconnue` s'atteint par le silence. Les cas comptent ce
      qui empêche d'atteindre le statut ; ce jugement compte ce qui empêche de poser le cas.
    - L'ancrage, l'inscription ou le contexte qui décide n'y est pas dicible, mais son absence donne le bon statut par
      défaut.

## 7. Le niveau (a) : la colonne à remplir

Le niveau (a) n'est pas encore disponible. `mesurer_moteur.py` lit `/home/user/donnees/bancs_phase1/v3/reference.json`
dès qu'il existe, et ne l'ouvre pas sinon.
- **Le format :** `{id: {statut_synthetique, variantes: {n: statut}}}`, où n est le rang de la variante à partir de 0,
  comme `docs/ANNOTATION_REFERENCE.md` (§ 6).
- **Ce qui se calcule alors,** pour chaque élément : `statut_a`, `c_contre_a` (accord, plus fort, plus faible) et
  `surete_stricte_a` ; dans le résumé, `c_contre_a` et `surete_stricte_a`.
- **Aujourd'hui,** les 1 494 éléments portent `"c_contre_a": "a_remplir"`.
- **Il n'est pas nécessaire de relancer le moteur pour remplir la colonne.** `--brut` reprend un `resultats.json`
  précédent (§ 9). `tests/test_mesure_bancs.py` le vérifie avec une référence factice.

| | accord | (c) plus fort | (c) plus faible | erreurs strictes |
|---|---|---|---|---|
| (c) contre (b) | 1 056 | 20 | 418 | 12 |
| (c) contre (a) | à remplir | à remplir | à remplir | à remplir |

## 8. Les échecs par étape

| étape | textes |
|---|---|
| lecture (le lecteur échoue) | 0 |
| graphe vide ou refusé par la validation | 0 |
| compilation / adaptateur (pas de requête) | 0 |
| noyau (`incomplet`, `erreur`) | 0 |
| erreur de la mesure | 0 |
| le noyau conclut | 31 |
| `inconnue` avec une requête : un échec sémantique | 1 463 |

**Rien n'a planté.** Aucune exception, aucun budget ni aucune limite atteinte.

**Ce que disent les inconnues :**
- **La compilation :** 844 textes sur une requête partielle (`non_lie` : elle ne peut rien établir de connexe), 612 sur
  une requête compilée, et 7 sur la seule requête non prise en charge (mn-016, « the Child without a halo »).
- **La langue :** en français, l'appui manque presque toujours dès les types (§ 2.3) ; en anglais, 155 inconnues n'ont
  qu'un atome manquant.
- **La cause de chaque inconnue n'est pas décidée ici** : c'est le travail de l'expérience croisée, et l'attribution
  cas par cas demanderait une référence (a).

## 9. La reproduction

Avec l'environnement de `docs/INSTALLATION.md` (SWI-Prolog 11, la base sous `/home/user/donnees/base`,
`OEDIPAMAAS_UDPIPE` et `OEDIPAMAAS_MODELES`, Stanza 1.10.1 et ses modèles sous `/home/user/donnees/stanza`), depuis la
racine du dépôt :

```bash
python3 outils/bancs/mesurer_moteur.py \
  --dev /home/user/donnees/bancs_phase1/dev --base /home/user/donnees/base \
  --representabilite docs/mesures/representabilite_dev.json \
  --sortie /home/user/donnees/bancs_phase1/v3/mesure_initiale/resultats.json \
  --tableaux /home/user/donnees/bancs_phase1/v3/mesure_initiale/tableaux.md
```

(Ce sont les valeurs par défaut : `python3 outils/bancs/mesurer_moteur.py` suffit.)
- **La passe de sensibilité :** la même commande, précédée de
  `OEDIPAMAAS_SURETE=nombres,portees,citations,modalites,negations`, avec
  `--sortie …/mesure_initiale/sensibilite_surete_A.json`.
- **Refaire les comptes sans relancer le moteur** (une représentabilité ou une référence (a) nouvelles) :
  `--brut …/resultats.json --sortie AUTRE.json`.
- **Le test :** `python3 -m pytest tests/test_mesure_bancs.py`, qui lance la mesure sur trois cas et vérifie qu'elle
  tourne, que les statuts sont dans leur domaine, que la colonne (a) se calcule, et que les fichiers de cas ne changent
  pas.
- **Le moteur est déterministe :** deux passes complètes ont donné les mêmes comptes.

**Les fichiers :**
- `outils/bancs/mesurer_moteur.py`, `outils/bancs/mesurer_moteur.pl`, `outils/bancs/adaptateur_scene.pl` ;
- `docs/mesures/representabilite_dev.json` ;
- `/home/user/donnees/bancs_phase1/v3/mesure_initiale/` : `resultats.json` (31 Mo : graphes, analyses, requêtes et
  statuts), `tableaux.md`, `sensibilite_surete_A.json`.

## 10. Limites

- **L'adaptateur est expérimental** et attend la validation de la propriétaire. Ses chiffres disent ce que le chemin
  scene ferait de ces définitions, non ce que le compilateur ferait de vrais libellés : il n'a ni héritage, ni
  aspects, ni type, ni version française.
- **Le français n'est pas mesuré** (§ 2.3).
- **(b) est un statut relatif à K0-d30** sous les règles provisoires. Un écart avec (b) n'est pas encore un écart avec
  le sens : 5 des 20 éléments plus forts portent sur une décision ouverte de (b) (ee-023 base, #1, #4 ; co-014 #0 ;
  rq-010 #1), et (c) vaut l'une des options pour co-014 #0 et rq-010 #1.
- **La représentabilité et la légitimité de l'adaptateur** sont des jugements d'agent, provisoires, sur le cas de base
  seulement (une variante peut demander plus que son cas).
- **Les défauts de la requête** (§ 2.4) sont relevés par un diagnostic mot à mot (`defauts_de_la_requete`), à relire :
  la liste des gérondifs en particulier est faite par une règle simple.
