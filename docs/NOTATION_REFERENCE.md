# La notation de référence des bancs (version 0, 28/11, proposition)

**La demande de la propriétaire** (28/11, § 7) :
- prévoir, pour chaque cas, une **représentation formelle de référence**, dès que les constructions correspondantes sont
  spécifiées, éventuellement dans une notation indépendante de l'implémentation Prolog ;
- prévoir des **connaissances K formellement exploitables**, avec leurs sources, plutôt que décrites en prose.

**Le but :** garder possible l'expérience croisée, qui sépare la lecture, la compilation, les connaissances et le
raisonnement. Le même cas doit pouvoir être évalué avec le graphe de référence et la requête de référence (ce qui isole le
raisonnement et K), avec le graphe lu et la requête de référence (ce qui isole la lecture), et ainsi de suite.

**Ce que ce document n'est pas :**
- **ni une syntaxe du noyau :** la version 2 du langage d'assertions (`docs/TRAJECTOIRE.md`, S2 à S5) reste à spécifier.
  Cette notation est la forme dans laquelle les bancs écrivent leurs références. Pour le fragment que le langage actuel
  couvre, elle se traduit vers lui ;
- **ni un formalisme de plus :** elle n'introduit aucune notion que les fondements n'ont pas déjà
  (`docs/FONDEMENTS_SEMANTIQUES.md`, `docs/ONTOLOGIE_EVENTUALITES.md`, `docs/INTERPRETATIONS_ADMISSIBLES.md`). Elle les
  écrit.

**La forme :** du JSON, un objet par cas, dans le champ `representation_reference` du cas, et un objet par variante dont
la représentation diffère. La notation est versionnée (`"notation": "nr-0"`).

## 1. Les types sont des concepts, non des lemmes

**La décision de la propriétaire** (28/11, § 3) : les requêtes portent sur des concepts, des sens ou des ensembles de
sens explicitement admissibles. L'identité du lemme ne démontre pas l'identité du concept.

**Un type** est donc un **ensemble de concepts admissibles**, jamais un mot :

```json
{"concepts": ["wn30:10285313-n"], "mot": "cavalier", "langue": "fr"}
```

- `concepts` : des identifiants de synsets de WordNet 3.0 (`wn30:` décalage-catégorie), ou des concepts propres au
  projet (`oc:`) quand aucune ressource n'en a. C'est l'ensemble des sens que l'interprétation de référence **admet**,
  non tous les sens du dictionnaire ;
- `mot`, `langue` : la forme du texte, pour la mesure de la lecture et de la couverture de K. Elle ne fait pas le type ;
- **un concept propre** (`oc:`) est défini dans le fichier des concepts du banc, avec sa glose et ses alignements
  connus. WordNet et WOLF ne déterminent pas seuls l'ontologie (décision du 28/11, § 4).

**Les ambiguïtés que la référence ne tranche pas** sont des **points d'ambiguïté** (§ 4). Un type peut alors avoir
plusieurs ensembles, un par valeur du point.

## 2. La représentation d'une description

```json
{
 "notation": "nr-0",
 "contextes": [
   {"id": "c0", "sorte": "figuration"},
   {"id": "c1", "sorte": "oeuvre"}
 ],
 "situations": [{"id": "s0", "contexte": "c0"}],
 "referents": [
   {"id": "x1", "sorte": "individu", "type": {"concepts": ["wn30:10285313-n"], "mot": "cavalier", "langue": "fr"}},
   {"id": "x2", "sorte": "individu", "type": {"concepts": ["wn30:03050026-n"], "mot": "manteau", "langue": "fr"}},
   {"id": "x3", "sorte": "individu", "type": {"concepts": ["wn30:09838895-n"], "mot": "mendiant", "langue": "fr"}}
 ],
 "eventualites": [
   {"id": "e1", "sorte": "changement", "type": {"concepts": ["wn30:02199590-v"], "mot": "donner", "langue": "fr"},
    "situation": "s0", "ancrage": "en_cours",
    "participants": [{"role": "agent", "referent": "x1"}, {"role": "theme", "referent": "x2"},
                     {"role": "destinataire", "referent": "x3"}]},
   {"id": "e2", "sorte": "etat", "type": {"concepts": ["wn30:00457998-a"], "mot": "nu", "langue": "fr"},
    "situation": "s0", "ancrage": "en_cours", "porteur": "x3"}
 ],
 "proprietes": [{"porteur": "x2", "type": {"concepts": ["wn30:00381097-a"], "mot": "rouge", "langue": "fr"}}],
 "relations": [{"type": "oc:possession", "de": "x1", "a": "x2"}],
 "qualification_par_defaut": {"polarite": "pos", "modalite": "affirme", "enonciateur": "auteur", "contexte": "c0"}
}
```

Les identifiants de synsets de cet exemple montrent la forme. Ils sont à vérifier à l'écriture des références.

**Les éléments :**

| élément | ce qu'il porte | d'où il vient |
|---|---|---|
| `contextes` | un identifiant, une sorte, et pour un contexte emboîté son `parent` et ce qui l'ouvre | FONDEMENTS § 2.5 |
| `situations` | un contexte, un `moment` facultatif, une localisation facultative | ONTOLOGIE § 3, § 4 |
| `referents` | une sorte (individu, collection, concept, situation), un type, un `nombre`, des `noms` | FONDEMENTS § 2.1, § 2.6 |
| `eventualites` | une sorte (état, processus, changement), un type, une situation, un ancrage, des participants ou un porteur | ONTOLOGIE § 1, § 2 |
| `proprietes` | les propriétés ordinaires, non réifiées | ONTOLOGIE § 1.1 |
| `relations` | un type de relation (spatiale, méréologique, temporelle, de possession, de représentation), deux arguments | FONDEMENTS § 2.4 |
| `quantifications` | une quantification énoncée : sa sorte (`seul`, `tous`, `aucun_autre`, `tous_sauf`), son domaine, son exception | FONDEMENTS § 2.6 |
| `identites` | `meme` (coréférence), `distinct`, `meme_individu` (deux figures, un individu, sans fusion) | NOYAU § 1 ; ONTOLOGIE § 3 |
| `qualification` | sur chaque élément, ou par défaut : polarité, modalité, énonciateur, contexte | ASSERTIONS v1 |

**Les contextes.** Leurs sortes sont `figuration`, `oeuvre`, `histoire`, `source` (avec la source), `titre`,
`contenu` (avec l'éventualité qui l'ouvre : vision, rêve, ordre, parole, inscription, tentative) et `emboite` (avec le
support : tableau figuré, tapisserie, miroir, statue). Un contexte a au plus un parent. Le chemin d'un élément est la
suite des contextes, de la figuration principale à son contexte (décision du 28/11, § 6).

**La négation** est une qualification : `"polarite": "neg"` sur l'élément nié, avec sa portée. Une éventualité niée est
une éventualité dont la polarité est négative ; ses participants ne sont pas niés (ONTOLOGIE § 2).

## 3. La représentation d'une définition

```json
{
 "notation": "nr-0",
 "variables": [
   {"id": "X", "sorte": "individu", "type": {"concepts": ["wn30:10179911-n"], "mot": "horseman", "langue": "en"}},
   {"id": "Y", "sorte": "individu", "type": {"concepts": ["wn30:03050026-n"], "mot": "cloak", "langue": "en"}},
   {"id": "Z", "sorte": "individu", "type": {"concepts": ["wn30:09838895-n"], "mot": "beggar", "langue": "en"}},
   {"id": "E", "sorte": "changement", "type": {"concepts": ["wn30:02199590-v"], "mot": "give", "langue": "en"}},
   {"id": "S", "sorte": "etat", "type": {"concepts": ["wn30:00457998-a"], "mot": "naked", "langue": "en"}}
 ],
 "atomes": [
   {"participant": ["E", "agent", "X"]}, {"participant": ["E", "theme", "Y"]}, {"participant": ["E", "destinataire", "Z"]},
   {"porteur": ["S", "Z"]}, {"relation": ["oc:possession", "X", "Y"]}
 ],
 "contraintes": {"meme_situation": ["E", "S"], "contexte": "quelconque"}
}
```

**Les éléments propres à une définition :**
- **les variables sont typées par des ensembles de concepts.** La désambiguïsation du libellé est traitée comme celle de
  la description (décision du 28/11, § 3). Un libellé ambigu a ses propres points d'ambiguïté ;
- **`non`** : un atome nié, `{"non": {...}}`. Il est satisfait par un appui négatif, jamais par une absence ;
- **`contraintes.meme_situation`** : les variables qui doivent être satisfaites dans une même situation ;
- **`contraintes.contexte`** : `principal` (la figuration principale seulement) ou `quelconque` (tout contexte de
  figuration, emboîté compris). Ce qui est retourné porte alors le chemin et la situation (§ 6).

## 4. Les points d'ambiguïté et les interprétations admissibles

**Un point d'ambiguïté** est une variable de l'interprétation : sa sorte, ses valeurs, et les contraintes qui en
excluent. La forme suit `docs/INTERPRETATIONS_ADMISSIBLES.md` :

```json
{"points": [
  {"id": "a1", "sorte": "sens", "porte_sur": "e1", "valeurs": {"donner_transfert": ["wn30:02199590-v"],
                                                               "donner_autre": ["wn30:02200686-v"]},
   "exclusions": [{"valeur": "donner_autre", "par": "k:sel-12", "raison": "le thème est un objet concret"}],
   "preferences": []}
]}
```

**Les sortes de points :**
- `sens` : le sens lexical ;
- `rattachement` : syntaxique ;
- `coreference` ;
- `portee` : de la négation ou d'un quantificateur ;
- `distributivite` ;
- `cadre_de_reference` : la gauche et la droite ;
- `ancrage` : temporel ;
- `contexte` : le contexte de représentation ;
- `identite`.

**Une exclusion** cite ce qui la démontre : une entrée de K (§ 5), ou une contrainte du texte. **Une préférence**
ordonne des valeurs mais n'en exclut aucune. Une préférence statistique n'est jamais une exclusion (décision du 28/11,
§ 2).

**Les interprétations admissibles** sont les affectations des points qui respectent toutes les exclusions. Le statut de
référence se lit par supervaluation sur elles (`docs/INTERPRETATIONS_ADMISSIBLES.md`).

## 5. Les connaissances formelles

**Le champ `connaissances_formelles`** d'un cas remplace, à terme, la prose de `connaissances_supposees`. Chaque entrée
est une relation entre concepts, avec sa sorte, son indexation et sa source :

```json
{"id": "k:inc-3", "relation": "incompatibilite",
 "arguments": ["wn30:00457998-a", "wn30:00456199-a"],
 "indexation": {"meme_porteur": true, "meme_moment": true, "meme_contexte": true},
 "attestee": true, "source": {"ressource": "oc:incompatibilites", "element": "nu/vêtu", "validation": "à faire"}}
```

**Les sortes de relations :**
- `inclusion` (l'hyperonymie et l'instance) et `partie` ;
- `equivalence`, `condition_suffisante`, `condition_necessaire`, `implication`, `consequence_conditionnelle` ;
- `typique` (jamais déductive) ;
- `incompatibilite`, distincte de `antonymie` (lexicale) et de `opposition_typique` ;
- `restriction_de_selection`, qui fonde des exclusions de sens ;
- `alias` et `distinction` (noms propres).

**L'indexation** d'une incompatibilité dit à quelles conditions deux types s'excluent : même porteur, même moment ou
même situation, même contexte. Deux états peuvent s'exclure au même moment et se succéder (décision du 28/11, § 5).

**La source** donne la ressource, l'élément et la validation. Une entrée non attestée (`attestee: false`) ne fonde
qu'une hypothèse.

**Les K nommés.** Un statut démontrable (§ 7) se lit relativement à un **K nommé** : un ensemble d'entrées et de
ressources versionnées.
- `K0-d30` est le K des statuts harmonisés au 28/11 : WordNet 3.0 et WOLF tels quels, tous leurs sens, et les
  connaissances écrites des cas.
- D'autres K, par exemple un WOLF corrigé ou une table d'incompatibilités attestées, donnent d'autres statuts
  démontrables pour la même référence sémantique.

## 6. Ce que retourne une satisfaction

**La notation retournée** pour une définition satisfaite porte la notation, la valeur, et pour chaque solution :
- **le chemin de représentation :** les contextes, de la figuration principale au contexte de la solution ;
- **la situation ;**
- **la substitution ;**
- **l'interprétation :** les valeurs des points d'ambiguïté, avec leurs exclusions et leurs sources ;
- **les hypothèses.**

```json
{"notation": "nr-0", "valeur": "etablie_sous_hypotheses",
 "solutions": [{"chemin": ["c0", "c3"], "situation": "s2", "substitution": {"X": "x7", "E": "e4"},
                "interpretation": {"a1": "donner_transfert"}, "hypotheses": ["identite:x7=x1"]}]}
```

**La décision documentaire** de retenir la notation pour l'œuvre principale n'en fait pas partie (décision du 28/11,
§ 6). Elle se prend après, sur le chemin : une scène satisfaite dans une vision figurée est retournée avec son chemin, et
la décision de l'indexer pour l'œuvre relève d'une règle documentaire séparée.

## 7. Les trois niveaux de statut, dans un cas (schéma 3)

| niveau | champ | ce qui le fixe |
|---|---|---|
| (a) le statut sémantique de référence | `statut_reference`, `hypotheses_reference`, `justification_reference` | la signification de la description et de la définition, par supervaluation sur les interprétations admissibles ; ni WordNet, ni WOLF, ni le noyau |
| (b) le statut démontrable relativement à un K nommé | `statut_attendu`, aujourd'hui relativement à `K0-d30` ; à terme, une table `{K: statut}` | la représentation de référence et les connaissances formelles de ce K |
| (c) le statut obtenu par le système | hors du banc, dans les fichiers de mesure | le lecteur, le compilateur, K, le noyau |

**Les écarts mesurent chacun quelque chose :**
- (a) contre (b) : ce que K ne permet pas encore de démontrer, ou les erreurs de K ;
- (b) contre (c) : la lecture, la compilation et le raisonnement, séparables par l'expérience croisée.

**Ce qui garantit la sûreté :**
- (c) n'est jamais plus fort que (b) ;
- (b) n'est jamais plus fort que (a) si K est correct. Un (b) plus fort que (a) signale une erreur de K.

**La traduction** garde (a). Un écart de (b) entre deux langues est une mesure de la couverture de K (décision du 28/11,
§ 8).

**Les dépendances** (`dependances`) remplacent à terme la `decision_ouverte` unique. C'est une liste de dimensions, par
exemple le sens d'une occurrence, la convention temporelle, l'identité ou le contexte de représentation. Chacune a ses
options et le statut selon chaque combinaison (`docs/INTERPRETATIONS_ADMISSIBLES.md`, § 8).

## 8. Ce qui reste à faire

- **Fixer la liste des concepts propres** (`oc:`) et des relations. Seulement ce que les cas demandent.
- **Écrire la représentation de référence** de chaque cas dont les constructions sont spécifiées. Pour les autres, le
  cas dit l'extension qui manque (`extensions_requises`) et n'a pas de représentation.
- **Écrire la traduction automatique** de la notation vers le langage d'assertions actuel, pour le fragment couvert.
  Elle permet de mesurer le moteur actuel sur les graphes et requêtes de référence.
- **Contrôler les représentations** par un validateur : identifiants, sortes, contextes sans cycle, variables typées.
