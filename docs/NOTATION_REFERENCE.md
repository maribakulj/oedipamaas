# La notation de référence des bancs (version 1, 28/11)

**Journal.**
- **Version 0 (28/11, proposition).** Une notation JSON, `nr-0`.
- **Version 1 (28/11).** La propriétaire valide le principe d'une notation indépendante de Prolog et demande une
  syntaxe abstraite, des règles de formation, une sémantique et un interpréteur indépendant. Ils sont dans
  `docs/LANGAGE_REFERENCE.md`. Cette notation devient la **syntaxe concrète** de ce langage, `nr-1` : une traduction de
  sa syntaxe abstraite, sans sémantique propre. Ce qui change : les types (alternatifs, union, conjonction), les
  identifiants et la provenance des assertions, les gardes, les propositions niées, les quantifications, les
  contraintes sur plusieurs points, les définitions structurées (suffisante, nécessaire), les formules composées de la
  requête, les entrées de K avec leur statut. Les sections restent celles de la version 0.

**La demande de la propriétaire** (28/11, § 7) :
- prévoir, pour chaque cas, une **représentation formelle de référence**, dès que les constructions correspondantes sont
  spécifiées, dans une notation indépendante de l'implémentation Prolog ;
- prévoir des **connaissances K formellement exploitables**, avec leurs sources, plutôt que décrites en prose.

**Le but :** garder possible l'expérience croisée, qui sépare la lecture, la compilation, les connaissances et le
raisonnement : le même cas évalué avec le graphe de référence et la requête de référence (ce qui isole le raisonnement
et K), avec le graphe lu et la requête de référence (ce qui isole la lecture), et ainsi de suite.

**Ce que ce document n'est pas :**
- **ni la sémantique :** ce qu'une clé veut dire est au § 3 de `docs/LANGAGE_REFERENCE.md`, et l'interpréteur
  `semantique_reference/` la calcule. Une notation JSON n'est pas une sémantique formelle ;
- **ni une syntaxe du noyau :** pour le fragment que le noyau 0.3 couvre, la notation s'y traduit
  (`docs/LANGAGE_REFERENCE.md`, § 5) ;
- **ni un formalisme de plus :** elle n'introduit aucune notion que les fondements n'ont pas.

**La forme :** du JSON, un objet par cas, `{"notation": "nr-1", "id", "description", "definition", "connaissances"}`.
`semantique_reference/json_concret.py` le lit et l'écrit ; `lire(écrire(x)) = x`. Les valeurs par défaut ne s'écrivent
pas. Cinq cas réels écrits ainsi sont dans `semantique_reference/exemples/`.

**Les conventions de termes :** une chaîne est un identifiant de référent (ou de situation) ; une chaîne qui commence
par `?` est une variable (`"?X"`).

## 1. Les types sont des concepts, non des lemmes

**La décision de la propriétaire** (28/11, § 3) : les requêtes portent sur des concepts, des sens ou des ensembles de
sens explicitement admissibles. L'identité du lemme ne démontre pas l'identité du concept.

**Un type** s'écrit de quatre façons (`docs/LANGAGE_REFERENCE.md`, § 1.4, qui en donne le sens) :

| type | JSON | ce qu'il dit |
|---|---|---|
| un concept | `"wn30:10185793-n"` ou `"oc:moitie_manteau"` | un sens de WordNet 3.0 (`wn30:` décalage-catégorie), ou un concept propre (`oc:`) |
| un ensemble de concepts **alternatifs** | `{"alternatifs": "p1"}` | un point d'ambiguïté p1 (§ 4) : une seule valeur par interprétation |
| une **union** de concepts | `{"union": ["oc:moine", "oc:moniale"]}` | un type disjonctif dans une même interprétation |
| une **conjonction** de types | `{"conjonction": ["oc:saint", "oc:eveque"]}` | l'intersection |

- **Le mot et sa langue** ne font pas le type : ils sont dans la **provenance** de l'assertion (§ 2), pour mesurer la
  lecture et la couverture de K.
- **Un concept propre** (`oc:`) est défini dans le fichier des concepts du banc, avec sa glose et ses alignements
  connus. WordNet et WOLF ne déterminent pas seuls l'ontologie.
- **⊥** (`"⊥"`) n'est qu'une valeur de point : le sens voulu manque à l'inventaire de K.

## 2. La représentation d'une description

```json
{"id": "ee-002", "langue": "fr", "texte": "… Un cavalier en armure, monté sur un cheval blanc, tend son manteau …",
 "contextes": [{"id": "principal", "sorte": "figuration"},
               {"id": "reve", "sorte": "reve", "parent": "principal", "ouvert_par": "e2"}],
 "referents": [{"id": "s0", "sorte": "situation"},
               {"id": "c", "sorte": "individu", "situation": "s0", "introduit_par": "ic"},
               {"id": "e", "sorte": "changement", "situation": "s0", "introduit_par": "ie"}],
 "assertions": [
   {"id": "ic", "contenu": {"atome": {"pred": "type", "args": ["c"], "type": "wn30:10185793-n"}},
    "provenance": {"document": "ee-002", "langue": "fr", "phrase": 1, "debut": 62, "fin": 70, "extrait": "cavalier"}},
   {"id": "ra", "contenu": {"atome": {"pred": "role", "args": ["e", "c"], "valeur": "agent"}}},
   {"id": "ae", "contenu": {"atome": {"pred": "ancrage", "args": ["e"], "valeur": "en_cours"}}},
   {"id": "nn", "contenu": {"non": {"locales": [["s", "etat"]],
                                    "atomes": [{"pred": "type", "args": ["?s"], "type": "oc:nu"},
                                               {"pred": "role", "args": ["?s", "b"], "valeur": "porteur"}]}},
    "qualification": {"polarite": "neg"}},
   {"id": "aucun", "contenu": {"quantification": {"quant": "aucun", "variable": ["z", "entite"],
                                                  "restriction": [{"pred": "type", "args": ["?z"],
                                                                   "type": "wn30:09538915-n"}]}}},
   {"id": "mm", "contenu": {"atome": {"pred": "meme_individu", "args": ["m1", "m2"]}},
    "qualification": {"modalite": "supposee", "nature": "identite", "contenu": "même nom"}},
   {"id": "r0a", "contenu": {"atome": {"pred": "role", "args": ["e0", "g"], "valeur": "agent"}},
    "garde": {"p1": ["collective"]}}],
 "alternatives": [{"id": "alt", "branches": [["moine"], ["moniale"]]}],
 "points": [{"id": "p1", "cote": "D", "dimension": "pluriel", "domaine": ["collective", "distributive"]}],
 "contraintes": [{"id": "cadre", "forme": "exclusion", "interdits": [{"pe": "oc:tendre_etendre"}],
                  "source": "cadre de sous-catégorisation", "sorte": "cadre_de_sous_categorisation"}],
 "preferences": [{"id": "dom", "point": "d1", "ordre": ["wn30:09538915-n", "oc:personne_sainte"]}]}
```

(Un assemblage d'extraits des dossiers de `semantique_reference/exemples/`, pour montrer les formes.)

**Les éléments :**

| élément | ce qu'il porte | d'où il vient |
|---|---|---|
| `contextes` | un identifiant, une sorte (figuratives : `figuration`, `emboite`, `vision`, `reve`, `etat_d_origine` ; non figuratives : `oeuvre`, `histoire`, `source`, `titre`, `inscription`, `deontique`, `parole`), un `parent`, l'éventualité qui l'ouvre (`ouvert_par`), une `source` | FS § 2.5 ; LANGAGE § 1.3 |
| `referents` | une sorte (individu, collection, concept, situation, état, processus, changement), un contexte, une situation, l'assertion qui l'introduit | FS § 2.1 ; ONT § 1 |
| `assertions` | un **identifiant**, un contenu (un atome, une proposition niée, une quantification), une qualification, une garde, une **provenance** (document, langue, phrase, offsets, extrait) | LANGAGE § 1.6 |
| `alternatives` | des branches d'assertions : une alternative de l'auteur, traitée par cas | étude § 3.4 |
| `points`, `contraintes`, `preferences` | § 4 | étude § 3 |

**Les atomes** (`"atome"`) : `type`, `propriete`, `relation` (avec `type`) ; `role` (avec `valeur` : agent, patient,
theme, destinataire, instrument, lieu, porteur, co_agent) ; `nom` (`valeur` : la clé) ; `ancrage` (`valeur` :
en_cours, anterieure, imminente, hors_temps) ; `nombre` (`valeur`) ; `dans`, `succede` ; `meme`, `distinct`,
`meme_individu`. Un référent est introduit par son assertion `type`.

**La qualification** (par défaut : `pos`, `affirme`, `auteur`, `principal`) : `polarite`, `modalite` (`affirme`,
`possible`, `supposee`), `enonciateur` (`auteur` ou `cite:X`), `contexte` ; et, pour une assertion supposée, la `nature`
de l'hypothèse (`identite`, `abduction`, `connaissance_typique`, `identification_iconographique`, `convention`,
`connaissance_non_attestee` ; jamais `lecture`) et son `contenu`.

**La négation** est **propositionnelle** : une assertion négative a pour contenu `{"non": {"locales", "atomes"}}`, la
négation de la conjonction entière (¬∃ locales. ∧ atomes), qui ne se répartit pas. « Pas de lion mort » ne dit pas
« pas de lion ». Une éventualité niée est une proposition niée sur l'éventualité ; ses participants ne sont pas niés.

**La garde** (`{"p1": ["collective"]}`) : l'assertion n'existe que dans les interprétations où le point a l'une des
valeurs (« A, si p = v »).

## 3. La représentation d'une définition

```json
{"id": "co-018:def", "libelle": "hermit, monk or nun reading a book", "langue": "en",
 "variables": [["X", "individu"], ["E", "processus"], ["B", "individu"]],
 "suffisante": {"et": [{"pred": "type", "args": ["?X"], "type": {"union": ["oc:ermite", "oc:moine", "oc:moniale"]}},
                       {"pred": "type", "args": ["?E"], "type": "oc:lire"},
                       {"pred": "role", "args": ["?E", "?X"], "valeur": "agent"},
                       {"pred": "role", "args": ["?E", "?B"], "valeur": "theme"},
                       {"pred": "type", "args": ["?B"], "type": "oc:livre"}]},
 "necessaire": null, "statut_suffisance": "etablie", "statut_necessite": "etablie"}
```

**Les éléments propres à une définition :**
- **les variables** sont déclarées avec leur sorte (`entite` : individu ou collection ; `contexte`) ;
- **les conditions nécessaires et suffisantes structurées** : `suffisante` (F_s ⇒ N) et `necessaire` (N ⇒ F_n), chacune
  avec son statut (`etablie`, `non_etablie`) ; `necessaire` absente : la même que `suffisante` (une équivalence). Une
  condition non établie ne fonde qu'une hypothèse d'abduction ;
- **les formules composées** : `{"et": […]}`, `{"ou": […]}`, `{"non": F}` (la négation d'une sous-formule, satisfaite
  par un appui négatif, jamais par une absence ; ses variables libres gardées par un atome positif),
  `{"existe": {"variables": [["w", "individu"]], "corps": F}}`, et les quantifications explicites
  `{"compte": {"quant": "au_moins" | "exactement" | "aucun" | "tous" | "seul", "n", "variable", "restriction",
  "portee", "membres"}}` ;
- **les contraintes de situation** : `dans(?E, ?S)`, `succede(?S1, ?S2)` ; **de contexte** : un atome
  `{"pred": "contexte_ouvert", "args": ["?C", "?E"], "valeur": "reve"}` lie la variable de contexte ?C, et un atome
  `{"…", "contexte": "?C"}` est évalué dans ce contexte ; sans contexte nommé, la définition est neutre : évaluée dans
  chaque contexte figuratif ;
- **une formule qui dépend d'un point de Δ** : `{"selon": {"point": "f", "cas": {"liste_exemples": F₁, "liste_fermee":
  F₂}}}`.

## 4. Les points d'ambiguïté et les interprétations admissibles

```json
{"points": [{"id": "pc", "cote": "D", "dimension": "sens", "ancre": "ic",
             "domaine": ["wn30:10185793-n", "oc:cavalryman", "oc:piece_echecs", "⊥"]}],
 "contraintes": [{"id": "x1", "forme": "exclusion", "interdits": [{"pc": "oc:piece_echecs"}],
                  "source": "restriction de sélection de « tendre » (VerbNet [à vérifier])", "sorte": "texte"},
                 {"id": "x2", "forme": "exclusion_conjointe", "interdits": [{"pe": "oc:tendre_transfert",
                                                                            "pc": "oc:rider_clause"}],
                  "source": "…"},
                 {"id": "x3", "forme": "implication", "interdits": [{"p": "v", "q": "w2"}], "source": "…"}],
 "preferences": [{"id": "pr", "point": "pc", "ordre": ["wn30:10185793-n", "oc:cavalryman"]},
                 {"id": "lemme", "couplage": ["d1", "d2"], "source": "même lemme, même sens"}]}
```

- **Un point** a un côté (`D` ou `Δ`), l'une des onze dimensions (`sens`, `sens_relation`, `structure`, `coreference`,
  `portee`, `pluriel`, `cadre_de_reference`, `ancrage`, `contexte`, `identite`, `forme_du_libelle`), un domaine et une
  ancre. La définition a ses propres points (côté Δ), désambiguïsés comme ceux de la description.
- **Une contrainte dure** est une liste de **combinaisons interdites**, chacune un objet {point : valeur} : sur un point
  (`exclusion`), **sur plusieurs points** (`exclusion_conjointe`), ou une **implication entre valeurs**
  (`implication` : p = v ⇒ q ∈ W s'écrit en interdisant p = v avec chaque valeur de q hors de W). Elle a une source et
  une sorte. **Aucune ne relie un point de D et un point de Δ.** Une restriction de sélection de K fonde des contraintes
  que l'interpréteur dérive (`docs/LANGAGE_REFERENCE.md`, § 3.1).
- **Une préférence** ordonne des valeurs, ou couple deux points ; elle n'exclut rien. Une préférence statistique n'est
  jamais une exclusion.
- **Les interprétations admissibles** sont les affectations des points qui ne violent aucune contrainte. Le statut de
  référence se lit par supervaluation sur elles (`docs/INTERPRETATIONS_ADMISSIBLES.md`), et l'interpréteur le calcule.

## 5. Les connaissances formelles

**Le champ `connaissances`** d'un cas remplace, à terme, la prose de `connaissances_supposees`. Chaque entrée nomme son
espèce (`entree`), a un identifiant, une **source** et un **statut** :

```json
{"version": "K-ee-002", "entrees": [
  {"entree": "inclusion", "id": "k1", "sous": "oc:tendre_transfert", "sur": "oc:donner_transfert",
   "source": {"ressource": "WordNet 3.0", "validation": "à vérifier"}, "statut": "attestee"},
  {"entree": "incompatibilite", "id": "k2", "a": "oc:vetu", "b": "oc:nu", "forme": "etat",
   "indexation": ["porteur", "moment", "contexte"], "sorte": "contraires",
   "source": {"ressource": "oc:incompatibilites", "element": "nu/vêtu", "validation": "à faire"}, "statut": "attestee"},
  {"entree": "regle", "id": "k3", "sorte": "condition_necessaire", "variables": [["x", "individu"]],
   "premisse": [{"pred": "type", "args": ["?x"], "type": "oc:martyr"}],
   "conclusion": [{"pred": "propriete", "args": ["?x"], "type": "oc:saint"}],
   "source": {"ressource": "…"}, "statut": "attestee"},
  {"entree": "restriction_de_selection", "id": "k4", "predicat": "oc:transfert", "role": "agent", "requis": "oc:anime",
   "domaine": ["figuration"], "source": {"ressource": "VerbNet 3.3", "validation": "à vérifier"}, "statut": "attestee"}]}
```

**Les espèces d'entrées** (leur effet : `docs/LANGAGE_REFERENCE.md`, § 1.10 et § 3.3) :
- `inclusion` (l'hyperonymie et l'instance), `equivalence`, `partie` (sans règle d'évaluation dans la version 1) ;
- `regle`, de sorte `implication`, `condition_suffisante`, `condition_necessaire` (la déduction et la contraposition)
  ou `consequence_conditionnelle` (la déduction seulement) ;
- `definition` : une définition conceptuelle structurée (`concept`, `variable`, `suffisante`, `necessaire`, leurs
  statuts) ;
- `typique` (jamais déductive : une hypothèse de nature `connaissance_typique`) ;
- `incompatibilite`, de forme `type`, `propriete`, `etat` ou `relation`, distincte de `antonymie` (lexicale, sans effet)
  et de `opposition_typique` (sans effet) ;
- `restriction_de_selection`, qui fonde des exclusions de sens, dans son domaine de validité ;
- `alias` et `distinction` (noms propres).

**L'indexation** d'une incompatibilité dit à quelles conditions deux types s'excluent : le même porteur et le même
contexte toujours, le même moment (la même situation et le même ancrage) si `moment` y est. Deux états peuvent s'exclure
au même moment et se succéder.

**La source** donne la ressource, l'élément et la validation. Une entrée `non_attestee` ne fonde qu'une hypothèse, de
nature `connaissance_non_attestee`.

**Les K nommés.** Un statut démontrable (§ 7) se lit relativement à un **K nommé** (`version`) : un ensemble d'entrées et
de ressources versionnées.
- `K0-d30` est le K des statuts harmonisés au 28/11 : WordNet 3.0 et WOLF tels quels, tous leurs sens, et les
  connaissances écrites des cas.
- D'autres K, par exemple un WOLF corrigé ou une table d'incompatibilités attestées, donnent d'autres statuts
  démontrables pour la même référence sémantique. Un **K\*** (`K*-…`) écrit les postulats de signification qu'un
  jugement de référence (a) emploie.

## 6. Ce que retourne une satisfaction

**Le résultat** d'une définition sur une description n'est pas un nom de statut : c'est un **profil** par contexte
figuratif (`docs/LANGAGE_REFERENCE.md`, § 3.9), et son résumé :
- **les classes** d'interprétations, chacune décrite par ses cylindres maximaux (les valeurs des points) et un témoin ;
- **pour chaque classe** : son statut local, et ses substitutions gardées — chacune avec sa valeur de Belnap, ses
  énonciateurs, sa certification de chaque signe, les hypothèses non lexicales avec leur **nature**, et la preuve (les
  assertions employées, par leurs identifiants, donc leur provenance) ;
- **le chemin** de représentation (le contexte d'évaluation, et celui de chaque atome qui en nomme un) et **la
  situation** (une variable de la substitution) ;
- **le statut synthétique** et ses attributs : la couverture de chaque signe, les hypothèses par nature, l'uniformité,
  les réfutations citées.

```json
{"contexte": "principal", "statut": "etablie_sous_hypotheses", "ligne": 6,
 "couverture_plus": [{"pc": ["wn30:10185793-n"], "ph": ["wn30:10185793-n"]}],
 "classes": [{"cylindres": [{"pc": ["wn30:10185793-n"], "ph": ["wn30:10185793-n"]}], "statut_local": "E",
              "substitutions": [{"sigma": {"X": ["c"], "E": ["e"], "T": ["s0"]}, "valeur": "V",
                                 "certifiee_plus": [[]], "hypotheses": []}]},
             {"cylindres": ["…"], "statut_local": "N"}]}
```

(La forme que l'interpréteur rend en Python ; son écriture JSON est une convention d'affichage, non une référence à
annoter.)

**La décision documentaire** de retenir la notation pour l'œuvre principale n'en fait pas partie (décision du 28/11,
§ 6). Elle se prend après, sur le chemin.

## 7. Les trois niveaux de statut, dans un cas (schéma 3)

| niveau | champ | ce qui le fixe |
|---|---|---|
| (a) le statut sémantique de référence | `statut_reference`, `profil`, `points` (le guide `docs/ANNOTATION_REFERENCE.md`) ; une représentation (a) dans cette notation, avec un K\* | la signification de la description et de la définition, par supervaluation sur les interprétations admissibles ; ni WordNet, ni WOLF, ni le noyau |
| (b) le statut démontrable relativement à un K nommé | `statut_attendu`, aujourd'hui relativement à `K0-d30` ; à terme, une table `{K: profil}` ; une représentation (b) dans cette notation | la représentation de référence et les connaissances formelles de ce K |
| (c) le statut obtenu par le système | hors du banc, dans les fichiers de mesure | le lecteur, le compilateur, K, le noyau |

**Les écarts mesurent chacun quelque chose :**
- (a) contre (b) : ce que K ne permet pas encore de démontrer, ou les erreurs de K ;
- (b) contre (c) : la lecture, la compilation et le raisonnement, séparables par l'expérience croisée.

**Ce qui garantit la sûreté** (`docs/INTERPRETATIONS_ADMISSIBLES.md`, § 2.6), signe par signe :
- les dérivations de (c) sont des dérivations de (b), celles de (b) des dérivations de (a), si K est correct et que les
  requêtes sont incluses **dans le sens du signe** (le positif par Q_sys ⊆ Q_ref, le négatif par Q_ref ⊆ Q_sys) ;
- les certifications, non : leurs écarts se mesurent (les six mesures de la déf. 12).

**La traduction** garde (a), au niveau des **profils**, non du seul nom du statut. Un écart de (b) entre deux langues
mesure la couverture de K.

**Les dépendances** (`dependances`) remplacent à terme la `decision_ouverte` unique : chaque dimension devient un point,
une convention (une hypothèse de nature `convention`) ou une entrée de K, et l'interpréteur calcule le profil de chaque
combinaison d'options.

## 8. Ce qui reste à faire

- **Fixer la liste des concepts propres** (`oc:`) et des relations. Seulement ce que les cas demandent.
- **Écrire la représentation de référence** de chaque cas dont les constructions sont spécifiées ; cinq le sont
  (`semantique_reference/exemples/`). Pour les autres, le cas dit l'extension qui manque (`extensions_requises` ;
  `docs/LANGAGE_REFERENCE.md`, § 9).
- **Écrire la traduction automatique** de la notation vers le langage d'assertions actuel, pour le fragment couvert
  (`docs/LANGAGE_REFERENCE.md`, § 5). Elle permettra de mesurer le moteur actuel sur les graphes et requêtes de
  référence.
- **Le validateur est fait** : `semantique_reference/formation.py` contrôle les 31 règles de formation (identifiants,
  sortes, contextes sans cycle, accessibilité, variables typées, négation gardée, indépendance de D et de Δ…).
