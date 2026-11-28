# Révision de niveaux_representation (nr-001 à nr-024), après la relecture C et le § 4.1

J'ai fait la révision et l'harmonisation en un seul passage, parce que la règle d'harmonisation (BANCS § 4.1, point 2, et l'outil WOLF `sens_fr.py`) est arrivée avant que la révision soit écrite. La version 1 est gardée hors du dépôt, dans le brouillon de la session (`v1_niveaux_représentation.json`). Le validateur avec `--quotas` passe sans erreur : 24 cas, 120 variantes, 23 cas composés, dont 13 à trois phénomènes ou plus.

## 1. Les désaccords de la relecture C

| id | décision | ce qui a changé |
|---|---|---|
| nr-001 (+#1, #2, #5) : « beside them » contre « à droite » | **corrigé** | La définition ne demande plus « beside them ». La position « à droite » ne l'établissait pas. |
| nr-018 (+#1, #3, #4) : appui négatif tiré d'une antonymie | **corrigé** | Statut `ecartee` → `inconnue`, pour le cas et les variantes #1, #3 et #4. L'antonymie et la dérivation youth → young passent à `attestee: false`. Une `decision_ouverte` donne `ecartee` si une sorte « incompatibilité attestée » était admise (§ 4.1, 3). |
| nr-016#2 : négation d'une personnification vers un concept non présent | **corrigé** | Statut `ecartee` → `inconnue`. La variante porte sa propre `decision_ouverte` : le référent conceptuel lève-t-il l'exigence de présence de NOYAU § 1.1 ? |
| nr-024 (K) : signify ⇔ symbolize non fondée | **corrigé** | L'entrée passe à `attestee: false`. La variante #2 passe de `etablie` à `etablie_sous_hypotheses` [equivalence_non_attestee], comme la relecture le proposait. La description garde « signifies » : le pas lexical est testé, il reste. |
| nr-024 : décision ouverte manquante | **corrigé** | J'ai ajouté une `decision_ouverte` (énonciateur cité → `non_certifiee`, ou portée « source » → `inconnue`). Statut `non_certifiee` → `inconnue`, l'option la plus prudente (§ 4.1). Les variantes #1, #3 et #4 suivent. |
| nr-011 (K) : « bras brisé ⇒ blessé » donné pour attesté | **corrigé** | L'entrée passe à `attestee: false`, comme hypothèse de rédaction. Aucun statut n'en dépend. |
| nr-002 (K) : « an Adoration of the Magi » nomme la scène | **corrigé** | L'entrée devient une `relation_inconnue` non attestée. Aucun statut ne change : la variante #3 décrit la scène en toutes lettres. |
| noms entre langues (nr-001, nr-007#2, nr-008#1, nr-010, nr-013) | **corrigé** | Les alias sont écrits dans K (`identite_documentaire`). Ils sont attestés quand WOLF et WordNet les donnent : Marie-Madeleine, Vierge, Jérôme, Holopherne, Martin. Ils ne sont pas attestés pour Eustache, Sébastien, KATHERINA et IACOBVS, absents des deux ressources ; ces cas portent l'hypothèse `identite`. nr-013 passe de `etablie` à `etablie_sous_hypotheses` [identite, sens] ; une `decision_ouverte` donne `etablie` si `cle_de_nom` normalise les noms entre les langues. |
| sens et contexte : nr-022 (whiteness) | **corrigé** | `etablie` → `etablie_sous_hypotheses` [sens], avec une `decision_ouverte` (`tous_les_sens` / `sens_fixe_par_le_contexte`). Dans WOLF, « blancheur » a un sens (immaculateness) qui n'atteint pas le lemme white. |
| sens et contexte : nr-005#3 (death) | **contesté** | « Dido's death » et « the death of Dido » ont le même lemme. D'après BANCS § 4.1, 2 (« Ce que D30 dit exactement »), un mot de la définition est un type lemme, et le même lemme des deux côtés donne un lien certain. La variante reste `etablie`. |
| nr-005, nr-023 : clés inexistantes | **corrigé** | pyre%1:14:00:: (synset 07963494-n, qui contient pyre et funeral_pyre) et heaven%1:09:00::. Vérifiées avec sens.py. |
| nr-013#5 : le dessin sous-jacent | **corrigé** | La variante porte sa propre `decision_ouverte`. Le statut reste `inconnue`, le plus prudent. |
| nr-009 : critique cité et métaphore (question 10) | **corrigé** | J'ai ajouté une `decision_ouverte` : métaphore → `inconnue`, ou assertion d'une source citée → `non_certifiee`. Le statut `inconnue` est gardé. |
| nr-003, nr-017 : jugés conformes par la relecture | **revus par le § 4.1** | Voir ci-dessous : ils ne sont plus `ecartee`. |

## 2. Les autres changements du § 4.1

- **Sources.** Chaque entrée `attestee: true` a maintenant une source : un synset WordNet avec ses pointeurs (`@`, `#p`), ou une entrée WOLF. Les entrées qui n'avaient pour fondement qu'une glose ou une hypothèse de rédaction passent à `attestee: false`. Cela concerne nr-001, 003, 004, 006, 007, 009, 010, 011, 012, 013, 014, 017, 018, 022 et 024. Les relations implicites (WOLF, `@`, `#p`) qui ne servaient qu'à le dire sont retirées de K quand rien n'en dépend.
- **nr-017.** La condition nécessaire « blindfolded ⇒ blindfold » n'est fondée que sur la glose de blindfolded%5:00:00:blind:00 : elle n'est pas attestée. Dans WOLF, « bandeau » n'a que le sens headband, qui n'inclut pas blindfold. Le cas passe donc de `ecartee` à `inconnue`, et la traduction aussi. La traduction porte une `decision_ouverte` qui donne `ecartee` si la condition était attestée. La variante de portée (#5) est écrite en anglais (« she is blindfolded »), car aucun mot français de WOLF n'atteint blindfold. Elle reste `etablie`.
- **nr-003.** « Ange » (7 sens dans WOLF) et « angel » (4 sens dans WordNet) sont polysémiques : la négation n'est pas certaine. Le cas passe de `ecartee` à `inconnue`, avec une `decision_ouverte` (`sens_fixe_par_le_contexte` → `ecartee`). La variante de portée (#3) est en anglais : « planer » est absent de WOLF, et « crèche » n'y atteint pas manger.
- **nr-006.** Le cas est un contre-modèle par incompatibilité (main gauche contre main droite). La `decision_ouverte` a maintenant une option « incompatibilité attestée » → `ecartee` (§ 4.1, 3). La variante #3 ajoute les hypothèses `sens` (lever : 17 sens dans WOLF) et `equivalence_non_attestee` (« main droite »).
- **nr-014, nr-015.** L'extension `contenu_d_inscription` remplace `contexte_emboite`. Pour nr-015, l'alias KATHERINA n'est pas attesté : les deux sens de « Catherine » dans WordNet et dans WOLF sont d'autres personnes. Les hypothèses sont `connaissance_typique`, `identite` et `sens`.
- **`extensions_requises` sur des variantes.** Je les ai ajoutées sur nr-017#5, nr-018#2 et nr-024#2 (`referent_conceptuel`, quand le cas de base n'en a pas besoin).

## 3. Harmonisation (BANCS § 4.1, point 2, « Ce que D30 dit exactement » ; WOLF)

J'ai appliqué la règle à chaque mot dont dépend un atome de la définition, dans le cas de base et dans les variantes. Les sens WOLF des mots français ont été lus avec `sens_fr.py`.

**Remontés (le projet de révision les avait affaiblis à tort).** Aucun statut écrit n'est plus fort que dans la version 1. Mais trois affaiblissements que j'avais prévus dans mon projet de révision ont été abandonnés :
- nr-005#3 (death, même lemme) reste `etablie` ;
- les cas anglais au même lemme que la définition ne reçoivent plus d'hypothèse `sens` : nr-001#1, 004#1, 010#1, 013#1, 019, 021#2, 023#2 ;
- les relations de figuration (« symbolise », « represented as », « personification of ») et de position sont lues dans le vocabulaire de l'extension et du langage d'assertions, sans pas lexical dans K.

**Gardés comme pas lexicaux (définition non réécrite).** Pour éviter un pas lexical, j'avais réécrit la définition de nr-001 (« lifeless body », « knees »), de nr-017 (« with a blindfold ») et de nr-022/023/024 (« symbolizing »), et la description de nr-010 (« décapite ») et de nr-024 (« symbolizes »). Ces réécritures sont **annulées**. Les pas sont gardés avec une équivalence non attestée :
- nr-001 : corps sans vie → dead, étendu → lie, genoux → lap ;
- nr-010 : trancher la tête → behead ;
- nr-024 : signify → symbole ;
- nr-004 : à cheval → on horseback ;
- nr-007 : prier à genoux → kneeling in prayer ;
- nr-011#2 : brisé → broken.

**Affaiblis par WOLF** (un mot français dont certains sens, ou aucun, n'atteignent le lemme) :
- nr-001, 004, 010 : `etablie` → `etablie_sous_hypotheses` [equivalence_non_attestee, sens]. Leurs paraphrases et ajouts suivent.
- nr-007#2, 011#2 : `etablie` → `etablie_sous_hypotheses` [equivalence_non_attestee, sens].
- nr-020#2 et nr-015#2 : `etablie` → `etablie_sous_hypotheses` [sens]. « Prudence » a 8 sens WOLF ; « roue » en a 4 et « tient » 52. Le cas nr-015 ajoute `sens` à ses hypothèses.
- nr-008#1 : [identite, sens] (« bois », « cerf »).
- nr-016#1 : [connaissance_typique, sens] (« serpent », « femme »).
- nr-019#1 : `etablie` → `inconnue`. Aucun des 26 sens WOLF de « Force » n'est fortitude.
- nr-017 : « bandeau » ne vaut que headband ; voir ci-dessus.

Quelques mots ont été vérifiés certains : « décapiter » (1 sens, behead), « massue » (club), « miroir » (deux sens, tous deux mirror), « couteau » (3 sens, tous knife), « pureté » (3 sens, tous purity), « blessé » (wounded), « agenouiller » (kneel).

**Bilan, de la version 1 à cette version** (cas et variantes, 144 statuts) :
- 45 statuts plus faibles, 0 plus forts ;
- cas de base : `etablie` 1, `etablie_sous_hypotheses` 8, `inconnue` 15 ; aucun `ecartee` ni `non_certifiee` ;
- en version 1 : `etablie` 7, `etablie_sous_hypotheses` 2, `ecartee` 3, `inconnue` 11, `non_certifiee` 1.

Décisions ouvertes : 5 cas en version 1 ; maintenant 12 au niveau des cas (nr-002, 003, 006, 008, 009, 012, 013, 018, 021, 022, 023, 024) et 3 au niveau des variantes (nr-013#5, 016#2, 017#1).

## 4. Les points à signaler

- **La traduction change souvent le statut.** C'est le cas de nr-001, 004, 010, 013, 019 et 017. Les relations métamorphiques du § 2.2 du plan (« traduction : même statut ») seront violées par construction, parce que la polysémie de WOLF n'est pas celle de WordNet anglais, et que les noms latins ou français ne sont pas tous dans WOLF. Il faut décider si la relation de traduction est une invariance ou une mesure de la couverture lexicale.
- **Deux variantes de portée sont en anglais dans des cas français** (nr-003#3, nr-017#5), faute de mots français qui atteignent hover, manger et blindfold dans WOLF.
- **Les relations de position et de figuration** sont traitées comme du vocabulaire fermé du lecteur : au-dessus de, devant, symbolise, personnifie, représente (ASSERTIONS ; audit § 3.7). C'est mon choix. Si elles relèvent de K, nr-022, nr-023#2, nr-019 et les positions de nr-003 demanderont des équivalences.
- **« Signify »** est traité comme un pas lexical vers la relation de symbole, et **« symbolise »** comme la relation elle-même. La frontière se discute.
- **Restriction de sélection.** « The Child » / « l'Enfant », dans nr-003 et nr-012, est lu comme un nom de la même figure dans les deux langues. Aucune entrée de K ne le dit : c'est une restriction de sélection que je n'ai pas écrite, faute de ressource.

## 5. Rétablissement (28/11)

Décision de la propriétaire : les textes qui avaient été adaptés aux lacunes de WOLF ou de WordNet reprennent leur forme de la version 1 (`v1_avant_relecture/niveaux_representation.json`). Les statuts sont recalculés selon le § 4.1, point 2, avec les sens WOLF lus par `sens_fr.py`.

| élément | ce qui revient | statut avant → après |
|---|---|---|
| nr-003#3 (portée) | le texte français : « en ajoute deux qui planent au-dessus de l'étable », « l'Enfant couché dans la crèche ». « Crèche » n'a aucun sens WOLF qui atteigne manger, et « planer » est absent de WOLF. | `etablie` → `inconnue` |
| nr-017#5 (portée) | le texte français : « elle a les yeux bandés ». « Bandé » est absent de WOLF, et rien n'atteint blindfolded. L'extension `referent_conceptuel` de la variante est retirée. | `etablie` → `inconnue` |
| nr-015#4 (paraphrase) | « présente une roue brisée » à la place de « tient ». « Présenter » a 61 sens WOLF, et aucun n'atteint hold. | `etablie_sous_hypotheses` → `inconnue` |
| nr-023#2 (portée) | « whose colour here symbolizes heaven » à la place de « whose blue ». Rien dans K ne dit que la couleur du manteau bleu est le bleu. Une `decision_ouverte` est ajoutée à la variante. | `etablie` → `inconnue` |
| nr-013#1 (traduction) | « pierced with arrows » à la place de « pierced by ». Mêmes lemmes ; la préposition donne le rôle d'instrument. | `etablie` → `etablie` (inchangé) |
| nr-012#3 (temps) | « Christ Child » à la place de « Christ-child ». Je le rétablis dans le doute, car je l'avais aligné sur la définition. | `etablie` → `etablie` (inchangé ; suppose que `cle_de_nom` ignore le trait d'union) |

**Ce qui n'est pas rétabli :** nr-001, où « beside them » reste retiré de la définition. C'est une correction de sûreté demandée par la relecture C, non un contournement de WOLF. Les autres réécritures avaient déjà été annulées à l'harmonisation : nr-001, 007, 010, 017, 022, 023 et 024.

**Cas qui perdent leur variante de statut différent :** nr-003, nr-017 et nr-023. Je n'ai rien réécrit pour la retrouver, conformément à la consigne. Le validateur signale aussi nr-018. Ce cas n'a jamais eu de variante de portée, de modalité, de temps ou d'inversion de statut différent : sa seule variante de statut différent est un `changement_de_participant` (#2), et le cas de base est `inconnue` depuis la révision.

**Forme :** chaque variante de traduction déclare maintenant sa `langue`, comme l'exige le validateur.

**Validateur** (`--quotas`) : 24 cas de base, 120 variantes, 0 erreur, 4 exigences non remplies (nr-003, nr-017, nr-018, nr-023 : aucune variante de portée, de modalité, de temps ou d'inversion dont le statut diffère).
