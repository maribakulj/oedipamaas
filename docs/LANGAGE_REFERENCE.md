# Le langage de référence : syntaxe abstraite, formation, sémantique, interpréteur (version 1, 28/11)

**Pour qui :** la propriétaire ; puis ceux qui écriront les références des bancs, NOYAU 0.4 et le futur moteur.

**La demande (28/11).** « Je valide le principe d'une notation indépendante de Prolog. Complète sa spécification pour
représenter les contraintes sur plusieurs points, les formules composées, la quantification, les négations
propositionnelles, les conditions nécessaires et suffisantes structurées, les identifiants d'assertions et leur
provenance textuelle. Précise la différence entre un ensemble de concepts alternatifs, une union de concepts et une
conjonction de types. Ne confonds pas une notation JSON et une sémantique formelle. Je souhaite une syntaxe abstraite,
des règles de formation, une sémantique et un interpréteur de référence indépendant. L'oracle doit servir à éprouver
les propriétés du futur moteur, pas à recopier ses décisions. » Et : la prochaine étape fait progresser ensemble les
références sémantiques, le langage formel indépendant et l'oracle, sans refonte générale ni accumulation de règles
linguistiques.

**Ce que ce document fait.** Il donne quatre choses séparées, et les relie :
1. une **syntaxe abstraite**, une grammaire de productions numérotées G 1 à G 23 (§ 1) ;
2. des **règles de formation**, RF1 à RF31 (§ 2) ;
3. une **sémantique** : des modèles de Belnap indexés par interprétation, branche et contexte, la valeur d'une formule,
   les dérivations et les certifications, le profil, le statut synthétique et son ordre, la robustesse (§ 3). Elle
   reprend `docs/INTERPRETATIONS_ADMISSIBLES.md`, version 1.1 (« l'étude »), qui fait foi ; là où l'étude est
   incomplète ou contradictoire, le point est listé (§ 3.12), non corrigé en silence ;
4. une **syntaxe concrète JSON** (`nr-1`), qui n'est qu'une traduction de la syntaxe abstraite (§ 4).

Il dit aussi le rapport au noyau 0.3 (§ 5), l'interpréteur et l'oracle de propriétés (§ 6), ce que l'interpréteur a
révélé (§ 7), cinq cas réels des bancs (§ 8), et ce qui manque (§ 9).

**Ce qu'il ne fait pas.** Il ne change aucune référence adjugée ni aucun statut des bancs. Il n'ajoute aucune règle
linguistique. Il ne touche ni au noyau Prolog ni à son oracle (`tests/oracle/oracle_noyau.py`), qu'il n'importe pas.

**Les fichiers.**
- `semantique_reference/` : le paquet Python, bibliothèque standard seulement. `syntaxe.py` (la syntaxe abstraite),
  `formation.py` (les règles de formation), `connaissances.py` (l'ordre des types relatif à K), `interprete.py` (la
  sémantique), `inclusion.py` (le comparateur), `json_concret.py` (la syntaxe concrète), `banc.py` (les cas réels),
  `exemples/*.json` (cinq dossiers de cas réels).
- `tests/test_semantique_reference.py` (l'oracle de propriétés), `tests/semantique_reference_gen.py` (les générateurs),
  `tests/test_semantique_reference_exemples.py` (les cas réels).
- `docs/NOTATION_REFERENCE.md`, version 1 : la syntaxe concrète, pour ceux qui écrivent les références.

**Les abréviations.** « l'étude » : `docs/INTERPRETATIONS_ADMISSIBLES.md` 1.1 ; « déf. n » : sa définition n ; NOYAU :
`docs/NOYAU.md` 0.3 ; FS : `docs/FONDEMENTS_SEMANTIQUES.md` ; ONT : `docs/ONTOLOGIE_EVENTUALITES.md` ; le guide :
`docs/ANNOTATION_REFERENCE.md`. RS n : une règle sémantique du § 3 ; RF n : une règle de formation du § 2.

## 0. Trois choses à ne pas confondre

| | ce que c'est | où |
|---|---|---|
| la **syntaxe abstraite** | les objets du langage et leur structure : une assertion a un identifiant, un contenu, une qualification, une garde, une provenance | § 1, `syntaxe.py` |
| la **sémantique** | ce que ces objets veulent dire : sous une interprétation i, dans une branche w, dans un contexte π, la valeur de Belnap d'une définition sous une substitution σ ; puis le profil et son résumé | § 3, `interprete.py` |
| la **syntaxe concrète** | une écriture en JSON de la syntaxe abstraite ; `lire(écrire(x)) = x` | § 4, `json_concret.py`, `docs/NOTATION_REFERENCE.md` |

Une clé JSON n'a pas de sens par elle-même : `"polarite": "neg"` ne veut rien dire tant que RS 3 et RS 13 n'ont pas dit
ce qu'une proposition niée réfute. Le test `test_syntaxe_concrete_aller_retour` vérifie que la traduction est exacte ;
tous les autres tests portent sur la sémantique.

## 1. La syntaxe abstraite

### 1.1 La grammaire

```
G 1   Sorte        ::= individu | collection | concept | situation | etat | processus | changement
                       (une variable peut aussi être de sorte contexte, ou entite = individu ou collection)
G 2   Provenance   ::= ⟨document, langue, phrase, début, fin, extrait⟩
G 3   Chemin(π)    ::= principal · c₁ · … · π            (les ancêtres d'un contexte, de la racine à lui)
G 4   Contexte     ::= ⟨id, sorte, parent, ouvert_par, source⟩
                       sorte figurative : figuration (la racine), emboite, vision, reve, etat_d_origine
                       sorte non figurative : oeuvre, histoire, source, titre, inscription, deontique, parole
G 5   T            ::= c | ⊥ | Alt(p) | T ∪ … ∪ T | T ∩ … ∩ T
G 6   Référent     ::= ⟨id, sorte, contexte, situation, introduit_par⟩
G 7   t            ::= r | X                              (un référent, une variable)
G 8   α            ::= type(t) : T | propriete(t) : T | role_ρ(t, t) | relation(t, t) : T | nom_k(t)
                     | ancrage_a(t) | dans(t, t) | succede(t, t) | nombre_n(t)
                     | meme(t, t) | distinct(t, t) | meme_individu(t, t) | contexte_ouvert_s(C, t)
                     [ @ C ]                              (un atome de requête peut nommer son contexte)
G 9   Qualif       ::= ⟨polarité ∈ {pos, neg}, modalité ∈ {affirme, possible, supposee},
                        énonciateur ∈ {auteur, cite:X}, contexte [, nature, contenu]⟩
G 10  Garde        ::= ⋀ⱼ (pⱼ ∈ Wⱼ)                        (vide : toujours)
G 11  Prop         ::= ∃ x̄. α₁ ∧ … ∧ αₙ
G 12  Quant        ::= Q x ∈ Dom. R(x) [→ P(x)]
                       Q ∈ {aucun, tous, tous_sauf(Ē), seul(Ē), exactement(n), au_moins(n)}
G 13  Assertion    ::= ⟨id, contenu ∈ α ∪ Prop ∪ Quant, Qualif, Garde, Provenance⟩
G 14  F            ::= α | F ∧ … ∧ F | F ∨ … ∨ F | ¬F | ∃ x̄. F
                     | au_moins(n) x. F | exactement(n) x. F | aucun x. F | tous x. F → F | seul x. F → x ∈ Ȳ
                     | Selon(p, v₁ ↦ F, …, vₖ ↦ F)
G 15  Alternative  ::= ⟨id, branches = (Ā₁, …, Āₘ)⟩       (des suites d'identifiants d'assertions, m ≥ 2)
G 16  Point        ::= ⟨id, côté ∈ {D, Δ}, dimension, domaine V(p), ancre, provenance⟩
G 17  Contrainte   ::= ⟨id, forme, Interdits, source, sorte⟩
                       Interdits : un ensemble de combinaisons ((p₁, v₁), …, (pₖ, vₖ))
G 18  Préférence   ::= ⟨id, point, ordre⟩ | ⟨id, couplage(p, q)⟩
G 19  Description  ::= ⟨id, langue, texte, contextes, référents, assertions, alternatives, points_D,
                        contraintes_D, préférences_D⟩
G 20  Définition   ::= ⟨id, libellé, langue, variables typées, (F_s, statut_s), (F_n, statut_n), points_Δ,
                        contraintes_Δ, préférences_Δ, provenance⟩      statut ∈ {etablie, non_etablie}
G 21  K            ::= ⟨version, entrées⟩ ; une entrée : § 1.10
G 22  Hypothèse    ::= ⟨nature, contenu⟩
G 23  Cas          ::= ⟨D, Δ, K⟩
```

### 1.2 Les sortes, les identifiants, la provenance (G 1, G 2)

- **Les sortes** sont celles de FS § 2.1 et d'ONT § 1 : l'individu, la collection (un groupe pris comme un tout),
  le concept (un signifié), la situation, et les trois sortes d'éventualités : l'état (avec un porteur), le processus,
  l'événement de changement. Une propriété ordinaire n'est pas une sorte : c'est le prédicat `propriete` (ONT § 1.1).
- **Chaque objet a un identifiant** unique dans son espèce (RF1) : contexte, référent, assertion, alternative, point,
  contrainte, préférence, entrée de K. Une hypothèse, une preuve, une mesure citent ces identifiants.
- **La provenance** d'une assertion dit d'où elle vient dans le texte : le document, la langue, la phrase, les offsets
  [début, fin[ et l'extrait. Elle n'a **aucun effet sémantique** (RF19) : la sémantique ne la lit jamais, et un test le
  vérifie (`test_provenance_sans_effet`). L'**énonciateur** n'est pas dans la provenance mais dans la qualification,
  parce qu'il en a un (un appui d'une source citée ne certifie rien : déf. 2). La provenance garde la marque textuelle
  de l'énonciateur (« selon X ») comme un extrait.

### 1.3 Les contextes, les chemins, les situations (G 3, G 4, G 6)

- **Les contextes forment un arbre** de racine `principal`, la figuration de l'œuvre (RF2). Le **chemin** d'un contexte
  est la suite de ses ancêtres (FS § 2.5). Un contexte ouvert par une éventualité (une vision, un rêve, un contrat, une
  parole, une inscription) nomme cette éventualité (RF3).
- **Les contextes figuratifs** (figuration, emboîté, vision, rêve, état d'origine) sont ceux où une définition peut être
  satisfaite ; les autres (histoire, source, titre, contrat…) ne satisfont rien (le guide, § 3 ; T24).
- **Un référent** est une mention : il a un contexte d'origine, une situation (s'il est situé) et l'assertion qui
  l'introduit, de la forme positive `type(r, T)` (RF5). Un référent du contexte π est **accessible** depuis π et ses
  descendants, et seulement depuis eux (RF6, l'accessibilité de la DRT).
- **Une situation** est un référent de sorte `situation` (ONT § 4). `dans(x, s)` est la situation de x : un fait de
  structure, déclaré sur le référent. `succede(s₁, s₂)` est une assertion.

### 1.4 Les types : alternatifs, union, conjonction (G 5)

C'est la distinction que la propriétaire demande. Trois constructions, trois sens.

| construction | écriture | ce qu'elle dit | sous une interprétation i | exemple |
|---|---|---|---|---|
| **un ensemble de concepts alternatifs** | `Alt(p)`, p un point de sens de domaine V(p) = {c₁, …, cₖ} | un **point d'ambiguïté** : le texte laisse plusieurs lectures ; chacune choisit **une** valeur | le concept i(p) (ou ⊥) : une seule valeur par interprétation | « cavalier » : {écuyer, cavalier militaire, …} ; « angels » : {être spirituel, personne sainte, investisseur} |
| **une union de concepts** | `c₁ ∪ … ∪ cₖ` | un **type disjonctif**, dans une même interprétation : x est un c₁ ou un c₂, sans que rien ne dise lequel | inchangée : aucune interprétation ne la tranche | « either a monk or a nun » d'une seule figure ; « hermit, monk or nun » d'un libellé |
| **une conjonction de types** | `T₁ ∩ … ∩ Tₖ` | l'**intersection** : x est un T₁ et un T₂ | inchangée | « un saint évêque » ; les types d'une variable, réunis |

**Leur sémantique** (§ 3.4, RS 12, RS 13). Les trois se lisent dans l'ordre ⊑ que K donne aux types, et leurs effets
diffèrent :
- `x : Alt(p)` donne autant de **classes** du profil que de valeurs admissibles de p ; une conclusion vraie pour une
  seule valeur est `etablie_sous_hypotheses`, sous le cylindre [p ∈ {c}] (§ 3.9) ;
- `x : c₁ ∪ c₂` dans D appuie `type(X, c₁ ∪ c₂ ∪ c₃)`, mais **ni** `type(X, c₁)` **ni** `type(X, c₂)` (S3, S6) : une seule
  interprétation, la valeur N pour « un c₁ » ; le nier (« ni moine, ni moniale ») nie chacun de ses membres ;
- `x : c₁ ∩ c₂` appuie `type(X, c₁)` et `type(X, c₂)` (S5) ; le nier ne nie aucun de ses membres (la négation d'une
  conjonction ne se répartit pas : NOYAU § 1.1).

**Une alternative de l'auteur n'est aucune des trois** (G 15, étude § 3.4). « Soit Persée tue la Méduse, soit David tue
Goliath » est une disjonction d'**assertions**, qui peuvent porter sur des référents et des structures différents. Ses
branches sont des **cas** de la preuve (§ 3.8), non des valeurs à choisir. Quand l'alternative porte sur le seul type
d'un seul référent (« a seated figure, either a monk or a nun »), elle a le même effet qu'une union : les deux
représentations s'accordent (co-018, § 8), l'union donne une substitution uniforme, l'alternative deux cas.

**Le rapport à D30** est au § 5 : le noyau 0.3 lit le mot d'une définition comme l'**union** des sens de son lemme ; la
décision 3 de la propriétaire en fait un ensemble de concepts **alternatifs** (un point de Δ).

**⊥** est la valeur d'un point de sens dont le sens voulu manque à l'inventaire de K (étude § 3.2) ; il n'est écrit
que comme valeur de point (RF8). Sous ⊥, aucun lien et aucune négation : ⊥ n'est inclus dans rien, et rien n'est inclus
dans ⊥, pas même ⊥ (§ 3.4, S1).

### 1.5 Les points, les contraintes, les préférences (G 16 à G 18)

- **Un point** a un côté (D ou Δ), une dimension (les onze de l'étude, § 3.1), un domaine et une ancre (l'assertion ou
  le mot où il est). Un point de sens a pour valeurs des concepts ou ⊥ ; les autres, des étiquettes (`collective`,
  `intrinseque`…) dont l'effet passe par les **gardes** (G 10) : une assertion gardée par (p ∈ W) n'existe que dans les
  interprétations où i(p) ∈ W (« A, si p = v », étude § 9.1). Côté Δ, l'effet passe par `Selon` (G 14).
- **Une contrainte dure** est un ensemble de **combinaisons interdites** (étude § 3.3). Trois formes d'écriture, une
  seule sémantique :
  - `exclusion` : un point, des valeurs (« cavalier » n'est pas un adjectif) ;
  - `exclusion_conjointe` : **plusieurs points** à la fois (p₁ = v₁ ∧ p₂ = v₂ est interdit ; « Il » ne désigne pas
    Marie si p_accord = masculin) ;
  - `implication` entre valeurs : p = v ⇒ q ∈ W, c'est-à-dire l'interdiction de p = v ∧ q ∉ W ;
  - `restriction_de_selection` : une contrainte que K fonde (§ 3.1, RS 2), sur le point du prédicat et celui de son
    argument (ee-002 : la composante {tendre, cavalier}, étude § 3.7 (e)).
  Chacune a une source et une sorte (texte, lecteur, catégorie, cadre, accord, identité dite, connaissance
  documentaire). **Aucune ne relie un point de D et un point de Δ** (RF12, étude § 3.4).
- **Une préférence** ordonne les valeurs d'un point, ou couple deux points (« même lemme, même sens », qui peut
  traverser D et Δ). Elle n'interdit rien (étude § 4).

### 1.6 Les atomes, les qualifications, les gardes, les assertions (G 7 à G 13)

- **Les atomes** (G 8) : `type` et `propriete` (typés), `role` (une éventualité, un participant, un rôle ; `porteur` est
  le rôle d'un état), `relation` (typée par un concept de relation : partie, possession, position, représentation…),
  `nom` (une clé de nom propre), `ancrage` (en cours, antérieure, imminente, hors du temps figuré : ONT § 2), `dans`,
  `succede`, `nombre`, et les trois identités (§ 1.7).
- **La qualification** (G 9) : la polarité, la modalité, l'énonciateur, le contexte. `affirme` appuie ; `possible`
  n'appuie rien ; `supposee` appuie **sous une hypothèse**, dont la nature est donnée (§ 1.11). Une assertion
  supposée est la forme d'une hypothèse non lexicale que le lecteur propose (une abduction, une connaissance typique,
  une identité supposée, une convention).
- **Une assertion** (G 13) a un identifiant, un contenu, une qualification, une garde et une provenance. Une assertion
  **positive** est un atome ou une quantification ; une assertion **négative** est toujours une proposition (RF15).

### 1.7 La négation, la quantification, les identités, les alternatives (G 11, G 12, G 15)

- **Une proposition niée** (G 11) : ¬∃x̄. α₁ ∧ … ∧ αₙ, de l'auteur ou d'une source. Elle nie la conjonction entière,
  qui ne se répartit pas (NOYAU § 1.1). « Le roi n'est pas mort » s'écrit ¬∃s (mort(s) ∧ porteur(s, roi)) ; « pas de
  lion », ¬∃x lion(x) ; « ce personnage n'est pas un saint », ¬saint(p) (sans variable locale). La règle de l'entité nue
  niée du noyau confond les deux dernières ; le langage les sépare.
- **Une quantification énoncée** (G 12, étude § 6.4) : `aucun`, `tous`, `tous_sauf(Ē)`, `seul(Ē)`, `exactement(n)`,
  `au_moins(n)`, sur un domaine : le contexte de l'assertion, restreint à une situation si elle est donnée.
- **Les identités** : `meme` est la **coréférence** (deux mentions d'une même figure, fusionnées en une classe ; jamais
  à travers deux situations ni deux contextes : RF17) ; `distinct` dit deux individus ; `meme_individu` dit deux figures
  d'un même individu, **sans fusion** (étude § 7.4) ; elle traverse situations et contextes, et s'écrit dans le
  contexte le plus profond de ses deux figures (RF6 l'impose : pi-003, § 7).
- **Une alternative de l'auteur** (G 15) : des branches d'assertions (§ 1.4, § 3.8).

### 1.8 Les requêtes : les formules composées (G 14)

- **∧, ∨** ; **¬F**, la négation **propositionnelle** d'une sous-formule, paraconsistante (§ 3.5) ; **∃x̄. F**, la
  quantification existentielle explicite, à variables locales ;
- **les quantifications explicites** : `au_moins(n) x. R`, `exactement(n) x. R`, `aucun x. R` (= ¬∃x R),
  `tous x. R → P`, `seul x. R → x ∈ Ȳ` ;
- **`Selon(p, v ↦ F)`** : une formule qui dépend d'un point de Δ (la forme du libellé, un pluriel du libellé) ;
- **les contraintes de situation** (`dans`, `succede`) et **de contexte** : un atome peut nommer son contexte par une
  variable C, liée par `contexte_ouvert_s(C, E)` (le contexte de sorte s ouvert par l'éventualité E, enfant du contexte
  d'évaluation : « Pharaon voyant en rêve sept vaches maigres », étude § 7.1).

Les variables libres de la définition sont existentielles et typées ; celles d'un ∃ ou d'une quantification sont
locales (RF20). Une variable libre d'une négation est **gardée** : liée par un atome positif de la même sélection
(RF22, la négation gardée).

### 1.9 La définition : des conditions nécessaires et suffisantes structurées (G 20)

Une définition est une **paire de formules** (F_s, F_n), chacune avec son **statut d'entrée** (`etablie`,
`non_etablie`) : F_s ⇒ N (la condition suffisante) et N ⇒ F_n (la condition nécessaire). Une définition qui est une
équivalence a F_s = F_n (le cas des libellés ordinaires). Les variables de F_n sont parmi celles de F_s, et F_s doit
impliquer F_n (RF26 : le comparateur ne rend pas `non`).

**Ce qu'elle veut dire** (§ 3.6) : N est appuyée positivement sous σ par un appui positif de F_s, négativement par un
appui négatif de F_n (la contraposition de N ⇒ F_n). Une condition `non_etablie` ne fonde qu'une hypothèse de nature
`abduction` : une classification par une définition d'un autre statut (FS § 4). L'index lit F_n (§ 3.10).

### 1.10 Les connaissances formelles K (G 21)

Chaque entrée a un identifiant, une **source** (ressource, élément, validation) et un **statut** (`attestee`,
`non_attestee`). Une entrée non attestée ne fonde qu'une hypothèse, de nature `connaissance_non_attestee` (NOTATION § 5 ;
§ 3.12, L7).

| entrée | arguments | ce qu'elle permet (§ 3) |
|---|---|---|
| `inclusion` | sous ⊑ sur, entre concepts | l'ordre ⊑ (S2) : un appui positif monte, un appui négatif descend |
| `partie` | partie, tout | **aucune règle dans la version 1** (décision 37 : aucun transfert sans une règle dirigée ; le tout impliqué n'est pas présent) |
| `equivalence` | a ≡ b | les deux inclusions |
| `regle` : `implication`, `condition_suffisante`, `condition_necessaire` | prémisse ⇒ conclusion, des structures | la déduction dans son sens, et la contraposition (RS 7) |
| `regle` : `consequence_conditionnelle` | A ∧ C ⇒ B | la déduction seulement ; aucune négation ne passe (FS § 3.3) |
| `definition` | concept T, x, suffisante(x), nécessaire(x), statuts | suffisante ⇒ T(x), T(x) ⇒ nécessaire ; non établie : sous une hypothèse d'abduction |
| `typique` | a, b, forme | une hypothèse de nature `connaissance_typique` ; jamais une déduction (RS 8) |
| `incompatibilite` | a, b, forme (type, propriété, état, relation), indexation (porteur, moment, contexte), sorte | un appui négatif indexé (RS 9) |
| `antonymie`, `opposition_typique` | a, b | **rien** : une ressource, une opposition typique (étude § 6.1) ; un test le vérifie |
| `restriction_de_selection` | prédicat, rôle, type requis, domaine de validité | une contrainte dure, avec une incompatibilité de types attestée, dans son domaine (RS 2) |
| `alias` | deux clés | un même individu (clos) |
| `distinction` | deux clés | deux individus documentés |

### 1.11 Les hypothèses et leur nature (G 22)

Une hypothèse est un couple (nature, contenu). Les natures sont celles de la déf. 4 : `lecture(d)`, `identite`,
`abduction`, `connaissance_typique`, `identification_iconographique`, `convention` ; et `connaissance_non_attestee`,
que l'étude nomme au § 2.1 sans la mettre dans la déf. 4 (L7).

- **Une hypothèse de lecture n'est jamais écrite** : elle est un cylindre sur des points (§ 3.9). Une assertion supposée
  de nature `lecture` est mal formée (RF30).
- **Les autres naissent** d'une assertion supposée (sa nature, son contenu), d'une entrée `typique`, d'une entrée non
  attestée, d'une condition non établie (une définition de Δ ou de K).
- **La règle de conservation** (déf. 4) : aucune étape ne change une nature, ni ne fond deux hypothèses de natures
  différentes (T13).

## 2. Les règles de formation

Un cas est **bien formé** s'il ne viole aucune des 31 règles. `formation.verifier(cas)` rend les défauts ; chaque
message commence par la règle (« RF12 (indépendance) : … »). Les cas tirés par les générateurs sont tous bien formés,
et une mutation de chaque espèce importante est rejetée par la règle qu'elle viole (`test_formation_mutations_detectees`).

| | règle | énoncé |
|---|---|---|
| RF1 | identifiants | les identifiants sont uniques dans leur espèce |
| RF2 | arbre des contextes | les contextes forment un arbre de racine `principal`, de sorte `figuration` ; chaque parent existe ; sans cycle |
| RF3 | contextes ouverts | un contexte ouvert (vision, rêve, parole, contrat, inscription) nomme l'éventualité qui l'ouvre, d'un contexte ancêtre |
| RF4 | sortes | chaque référent, variable et contexte a une sorte de la liste |
| RF5 | référents | un référent a un contexte existant, une situation de son contexte ou d'un ancêtre, une assertion positive type(r, T) qui l'introduit dans son contexte (sauf une situation) |
| RF6 | accessibilité | un référent cité par une assertion du contexte π est de π ou d'un ancêtre de π |
| RF7 | arguments | le nombre d'arguments, le type, la valeur de chaque prédicat ; un rôle part d'une éventualité ; porteur est le rôle d'un état ; un ancrage porte sur une éventualité ; dans et succede portent sur des situations ; une requête n'a que des variables pour arguments |
| RF8 | types | une union ou une conjonction a au moins deux membres ; Alt(p) renvoie à un point de sens du même côté ; ⊥ n'est qu'une valeur de point |
| RF9 | points | un côté, une dimension de la liste, un domaine non vide sans répétition ; un point de sens a pour valeurs des concepts ou ⊥ |
| RF10 | gardes | sur des points existants du même côté, avec des valeurs de leur domaine |
| RF11 | une valeur par point | une garde n'a qu'une condition par point ; une combinaison interdite ne nomme pas deux fois un point (une interprétation est une fonction) |
| RF12 | indépendance | une contrainte dure ne relie jamais un point de D et un point de Δ |
| RF13 | contraintes et préférences | une contrainte a une source et des combinaisons de points et de valeurs existants ; une préférence ordonne des valeurs existantes et n'interdit rien |
| RF14 | qualifications | polarité, modalité, énonciateur (`auteur` ou `cite:X`), contexte existant ; une assertion supposée a une nature non lexicale ; une assertion affirmée n'en a pas |
| RF15 | négation propositionnelle | une assertion négative a pour contenu une proposition ; une positive est atomique ou une quantification, sans variable ; chaque variable locale apparaît dans un atome |
| RF16 | quantifications énoncées | la variable est dans la restriction ; aucune autre variable ; seul et tous_sauf nomment leurs membres ; exactement et au_moins ont un nombre ; tous a une portée |
| RF17 | identités | meme relie deux référents de même sorte, de même contexte, de même situation, positive, affirmée, de l'auteur ; jamais distinct(x, x) ; meme_individu relie des individus ou des collections |
| RF18 | alternatives | au moins deux branches non vides ; une assertion dans une branche au plus ; un référent introduit dans une branche n'est cité que dans elle |
| RF19 | provenance | 0 ≤ début ≤ fin, dans la longueur du texte ; aucun effet sémantique |
| RF20 | variables | chaque variable de la définition est déclarée une fois, avec une sorte ; les variables locales n'ombrent rien et ne sont déclarées qu'une fois |
| RF21 | portée | chaque variable libre est déclarée, et apparaît dans un atome hors de toute négation |
| RF22 | négation gardée | dans chaque sélection, les variables libres d'une feuille ¬, ∃ ou de quantification sont liées par un atome positif de la même sélection, hors d'elle |
| RF23 | identités de requête | les variables d'une identité sont liées par des atomes non identitaires de la même sélection ; jamais distinct(X, X) |
| RF24 | connecteurs | ∧ a au moins un enfant, ∨ au moins deux ; Selon porte sur un point de Δ et a un cas par valeur ; une quantification a son nombre, sa portée ou ses membres |
| RF25 | contextes de requête | une variable de contexte est liée par contexte_ouvert dans chaque sélection où elle sert |
| RF26 | conditions structurées | les variables de F_n sont parmi celles de F_s ; des statuts de la liste ; F_s ⇒ F_n (le comparateur ne rend pas `non` ; `indetermine` est un avertissement) |
| RF27 | entrées de K | une source, un statut ; une incompatibilité a une forme et une indexation qui contient porteur et contexte ; une règle n'emploie que ses variables et a une prémisse |
| RF28 | cohérence des noms | aucune paire de clés n'est à la fois alias (par la clôture) et distincte |
| RF29 | côtés | les points de D ne servent qu'à la description, ceux de Δ qu'à la définition |
| RF30 | hypothèses | une hypothèse de lecture n'est jamais écrite ; une assertion supposée a une nature non lexicale |
| RF31 | contextes d'évaluation | la racine est figurative |

## 3. La sémantique

Elle reprend l'étude, définition par définition. Les numéros RS sont ceux que cite le code.

### 3.1 Les interprétations (étude § 2.1, § 3.3, § 3.4)

- **Ω = ∏_{p ∈ P} V(p)**, P = P_D ⊎ P_Δ. Une interprétation i est une fonction : une valeur par point.
- **Les contraintes dures** sont celles de D, celles de Δ, et celles que K fonde (**RS 2**) : une restriction de
  sélection attestée R = (prédicat P, rôle ρ, requis Tr, domaine) interdit la combinaison (p_e = v_e, p_x = v_x) d'une
  assertion `role_ρ(e, x)` d'un contexte de son domaine, si v_e ⊑ P et qu'une incompatibilité attestée de forme `type`
  sépare Tr et v_x ; les gardes de l'assertion et des introductions s'ajoutent à la combinaison. Sans point, elle
  interdit la combinaison vide : I = ∅ (la personnification, étude § 3.7 (a)). Côté Δ, les contraintes sont écrites.
- **I = { i ∈ Ω : i ne viole aucune contrainte dure }** (T1). Les préférences ordonnent I ; elles ne le changent pas.
- **Les composantes** de l'hypergraphe des contraintes (étude § 3.7 (e)). Le calcul peut ne porter que sur les points
  dont dépend le résultat, fermés par les composantes : le profil est le même (T17).

### 3.2 La résolution : G_i = ρ(D, i), Q_i = ρ(Δ, i)

Sous i, la description résolue ne garde que les assertions dont la garde est vraie, et remplace chaque Alt(p) par le
concept i(p) (ou ⊥) ; la définition résolue remplace chaque Selon(p, …) par la formule de i(p). Plus aucun point ne
reste ouvert : c'est l'univocité de l'étude § 2.1. **Les branches** w des alternatives de l'auteur sont toutes les
combinaisons d'une branche par alternative ; dans la branche w, les assertions des autres branches sont absentes.

### 3.3 Le modèle de Belnap sous (i, w) : la base des faits signés

Sous (i, w), la description résolue donne une **base** : par contexte, des **faits positifs** et des **propositions
niées** (le modèle est indexé par le contexte ; la situation est un argument des atomes, non un second index : L21), chacun avec ses **fondements** (les énonciateurs, les assertions employées — les prémisses —, les entrées de K,
les hypothèses non lexicales avec leur nature). C'est la plus petite valuation qui contient ce que D affirme et nie,
close par K dans la direction de chaque connaissance (FS § 1.1), et par les propriétés du langage. Elle est en monde
ouvert : **rien n'y entre par absence**.

- **RS 1 (les appuis et la présence).** Une assertion n'appuie rien si elle est `possible`, ou si un référent qu'elle
  cite n'est pas présent (son assertion d'introduction absente, ou seulement possible). Les fondements d'un appui
  réunissent ceux de l'assertion et ceux de l'introduction de chaque référent cité : « l'auteur dit qu'il s'appelle
  Pierre » d'un homme dont seule une source dit qu'il est là n'est pas une prémisse de l'auteur (NOYAU D25).
  **Les classes de coréférence** sont la fermeture des `meme` ; les faits d'un membre valent pour sa classe.
- **RS 3 (ce que disent les assertions).** Une assertion positive atomique donne un fait ; une assertion négative donne
  sa proposition niée ; une quantification énoncée est gardée telle quelle (pour RS 10 et RS 11). Une assertion
  supposée donne un fait sous l'hypothèse (nature, contenu).
- **RS 4 (« aucun »).** `aucun x ∈ Dom. R(x) [∧ P(x)]` donne la proposition niée ¬∃x (R(x) ∧ P(x) [∧ dans(x, s)]),
  dans son contexte.
- **RS 5 (la situation).** `dans(r, s)` est un fait de structure, pour chaque référent présent et situé. Ce n'est pas un
  fondement négatif : l'étude ne le range pas parmi « ce qui donne un appui négatif, et seulement cela » (§ 6.3 ; § 7).
- **RS 6 (l'ancrage).** Une éventualité n'a qu'un ancrage par rapport au moment de sa situation : `ancrage(e, a)` donne
  ¬ancrage(e, a') pour a' ≠ a (étude § 6.2 : « une incompatibilité du langage » ; L8).
- **RS 7 (les règles de K).** Une règle P ⇒ C : pour chaque homomorphisme de la prémisse P dans les faits d'un contexte
  (les types entraînés par ⊑), les atomes de C dont les variables sont liées deviennent des faits ; sauf une conséquence
  conditionnelle, pour chaque liaison τ des variables communes telle que C[τ] est réfutée (RS 13), la proposition
  ¬∃(var(P) ∖ dom τ). P[τ] est ajoutée (la contraposition, étude § 6.3 point 5). Une définition conceptuelle de K
  donne deux règles (suffisante ⇒ T, T ⇒ nécessaire), sous l'hypothèse d'abduction si la condition n'est pas établie.
- **RS 8 (les connaissances typiques).** `typique(a, b)` : un fait de type a donne un fait de type b **supposé**, sous
  l'hypothèse (connaissance_typique, …). Jamais un fait sans hypothèse.
- **RS 9 (les incompatibilités indexées).** `incompatible(a, b)` attestée, de forme type, propriété ou relation : un
  fait de type ⊑ a donne la négation du même prédicat, des mêmes arguments, de type b, dans le même contexte ; de forme
  état : un état e de type ⊑ a, de porteur x, donne ¬∃S (b(S) ∧ porteur(S, x) [∧ dans(S, s_e) ∧ ancrage(S, τ_e)]) —
  la partie entre crochets si l'indexation contient le moment ; sans moment connu de e, rien (étude § 6.2). Les deux
  sens. Le porteur est la classe ; le contexte est celui du fait.
- **RS 10 (« tous », « seul »).** `tous x ∈ Dom. R → P` : pour chaque classe du domaine dont R est appuyée, les atomes
  de P deviennent des faits ; dont P est réfutée, ¬R devient une proposition niée. `tous_sauf(Ē)` de même, pour les
  seules classes établies distinctes de chaque exception. `seul(Ē) x. R` : pour chaque classe du domaine établie
  distincte de chaque élément de Ē, ¬R (étude § 6.4 ; rq-021#5 : une troisième personne donne B).
- **La clôture** applique RS 6 à RS 10 jusqu'au point fixe (fini : aucun référent n'est créé).

### 3.4 L'ordre des types et les appuis positifs (RS 12)

**L'ordre ⊑ relatif à K** est celui du treillis libre engendré par le préordre des concepts (Whitman) :
- **S1** ⊥ n'est inclus dans rien et rien n'est inclus dans ⊥ ;
- **S2** c ⊑ d entre concepts : la clôture réflexive et transitive des inclusions et des équivalences de K ;
- **S3** (A₁ ∪ … ∪ Aₙ) ⊑ B ssi chaque Aᵢ ⊑ B ; **S4** A ⊑ (B₁ ∩ … ∩ Bₙ) ssi A ⊑ chaque Bᵢ ;
- **S5** (A₁ ∩ … ∩ Aₙ) ⊑ B si un Aᵢ ⊑ B ; **S6** A ⊑ (B₁ ∪ … ∪ Bₙ) si A ⊑ un Bᵢ ; S5 et S6 sont essayées toutes deux.

Cet ordre est transitif, ce dont dépendent les propositions de sûreté (T21, T22). Il n'est pas distributif (une
incomplétude sûre). Une dérivation qui passe par une inclusion non attestée porte l'hypothèse
(connaissance_non_attestee, id).

**RS 12, l'appui positif d'un atome entièrement lié sous σ, dans le contexte π :**
- un atome typé `type(X, T)`, `propriete(X, T)`, `relation(X, Y) : T` est appuyé par des faits du même prédicat, des
  mêmes classes, du contexte π (celui de l'atome s'il nomme son contexte), dont la **conjonction des types** est ⊑ T ;
- les autres, par un fait égal (un nom à alias près) ;
- `meme(X, Y)` par la même classe ; `distinct(X, Y)` par une distinction établie (une assertion `distinct`) ou
  documentaire (deux clés que K distingue, aucune classe ne portant la clé de l'autre) ; `meme_individu(X, Y)` par la
  même classe ou un chemin d'assertions `meme_individu` ;
- `contexte_ouvert_s(C, E)` : σ(C) est un enfant de π, de sorte s, ouvert par un membre de σ(E).
`dans`, `succede` et les identités ne dépendent d'aucun contexte.

### 3.5 La valeur d'une formule : D⁺, D⁻, la négation propositionnelle (RS 11, RS 13)

**Les sélections.** La forme disjonctive de F : chaque sélection est une suite de **feuilles** — des atomes, des ¬G,
des ∃x̄. G, des quantifications. Une ∨ donne plusieurs sélections, une ∧ les combine.

**La valeur de F sous σ** (dans π, sous i et w) est la paire (D⁺, D⁻) de Belnap : N = (0, 0), V = (1, 0), F = (0, 1),
B = (1, 1). Chacune vient avec ses fondements.

- **D⁺(F, σ) = 1** s'il existe une sélection dont chaque feuille a un appui positif sous σ (un arbre positif, déf. 1),
  σ liant ses variables.
- **D⁻(F, σ) = 1** si **chaque** sélection est **réfutée** sous σ. Une sélection S est réfutée (**RS 13**) :
  - si l'une de ses feuilles l'est ; un atome seul l'est si son type est ⊑ l'**union des types niés** du même prédicat et
    des mêmes arguments (nier A et nier B nie A ∪ B), ou s'il est égal à une proposition niée atomique ; `meme` et
    `meme_individu` le sont par une distinction (la même classe dite deux : B) ; `distinct` ne l'est jamais (la même
    classe : une substitution invalide, NOYAU § 4.1) ;
  - ou si ses atomes **entraînent une proposition niée** de la base : un homomorphisme h de ¬∃x̄. φ dans S (chaque atome
    de φ a une image dans S qui l'entraîne : même prédicat, même valeur, même contexte, type de l'image ⊑ type de φ ;
    un référent de φ va sur une variable liée à sa classe ; une variable locale de φ va sur n'importe quel terme, lié
    ou non). La réfutation porte sur la conjonction entière, non sur un atome : c'est D41 levé (étude § 6.4). Une
    variable de S non liée par σ peut recevoir une variable locale de φ : « aucun ange » réfute « un ange » pour tout
    référent, sans liaison (une réfutation **fermée**, σ vide).
  Sur des formules sans négation ni proposition niée, D⁻ est l'arbre négatif de la déf. 1 (un enfant d'une ∧, tous ceux
  d'une ∨) : la forme disjonctive le généralise sans le changer.
- **La négation propositionnelle est paraconsistante** : **D⁺(¬G, σ) = D⁻(G, σ)** et **D⁻(¬G, σ) = D⁺(G, σ)**. Elle
  échange les appuis ; elle n'est jamais satisfaite par une absence ; ¬¬G a la valeur de G (testé).
- **L'existentielle explicite** : D⁺(∃x̄. G, σ) = 1 si G a un arbre positif qui étend σ sur x̄ ; **D⁻(∃x̄. G, σ) = D⁻(G,
  σ sans x̄)** : une réfutation qui vaut pour toute valeur de x̄. C'est pourquoi ¬∃x lion(x) d'une requête (« sans
  lion ») n'est appuyé que par une négation fermée du texte, jamais par le silence.
- **RS 11, les quantifications de la requête** :

| | appui positif | appui négatif |
|---|---|---|
| au_moins(n) x. R | n solutions de R deux à deux établies distinctes ; ou un énoncé au_moins(m) / exactement(m), m ≥ n, dont la description entraîne R | D⁻(∃x R) ; un énoncé exactement(m), m < n, entraîné par R |
| exactement(n) x. R | un énoncé exactement(n) de description équivalente | un énoncé exactement(m ≠ n) équivalent ; n + 1 solutions distinctes ; D⁻(∃x R) si n ≥ 1 |
| aucun x. R | D⁻(∃x R) | D⁺(∃x R) |
| tous x. R → P | un énoncé « tous » de restriction plus large et de portée plus étroite | un contre-exemple : R appuyée, P réfutée |
| seul x. R → x ∈ Ȳ | un énoncé « seul » dont les seuls sont parmi σ(Ȳ), de restriction plus large | un élément qui satisfait R, établi distinct de chaque σ(Y) |

L'exclusivité n'est jamais appuyée par le silence (rq-021 ; testé).

**La monotonie (lemme 1).** D⁺ et D⁻ ne font que croître quand K grandit, quand D dit plus, et quand σ lie plus de
variables (T12). C'est ce qui rend complète la recherche par arbres (§ 3.7).

### 3.6 La définition, les dérivations et les certifications (déf. 1, 2, 3)

Pour une définition (F_s, F_n) et σ sur les variables de F_s :
- **val(σ) = (D⁺(F_s, σ), D⁻(F_n, σ|var F_n))**, sans hypothèse et de tout énonciateur. Une condition non établie ajoute
  l'hypothèse (abduction, …) aux appuis de son signe.
- **C⁺ sous H** : σ lie exactement les variables d'une sélection (une solution, NOYAU § 4.3) ; un arbre positif de F_s
  n'a que des appuis de l'**auteur**, dont **aucune prémisse n'est niée** (une assertion employée, reprise telle
  qu'elle est dite, n'a pas d'appui négatif sous H), sous les hypothèses H ; et **F_n n'a aucun appui négatif sous σ et
  H** (de tout énonciateur).
- **C⁻ sous H** : un arbre négatif de F_n dont les fondements sont de l'auteur (ou du texte, ou de K), sous H ; et **F_s
  n'a aucun appui positif sous σ et H**.
- La certification est lue sur la **requête entière**, des deux côtés (L1) : c'est ce qui rend vraie T6 (C⁺ ⇒ D⁺ ∧ ¬D⁻,
  C⁻ ⇒ D⁻ ∧ ¬D⁺) en présence de propositions niées.
- **Les énonciateurs** de chaque signe ; **une contradiction** (val = B) est **interne** si un même énonciateur appuie
  les deux signes, **documentaire** sinon (NOYAU § 4.3).
- **Les affirmations** d'un résultat (déf. 3) sont les triplets (i, σ, H) de chaque signe et de chaque force.

### 3.7 Le résultat sous une interprétation et le statut local (déf. 5, étude § 3.7 (f))

- **La recherche** : les arbres positifs de F_s, les liaisons qui réfutent F_n (toutes, non les seules minimales : une
  plus grande peut porter une réfutation de l'auteur quand la plus petite n'est que d'une source), et leurs réunions.
  Chaque candidate est ensuite **évaluée par définition** (§ 3.6). La recherche est complète par la monotonie ; elle est
  confrontée à l'énumération exhaustive de toutes les substitutions partielles (T4).
- **Les lignes gardées** (NOYAU § 4.4) : les solutions certifiées, les réfutations certifiées, les substitutions
  minimales contradictoires, fausses, et vraies non certifiables.
- **Le statut local** st(i, w), dans l'ordre de NOYAU § 4.4 étendu : **E** (une solution certifiée sans hypothèse),
  **E_H** (certifiée seulement sous des hypothèses non lexicales ; leurs ensembles minimaux, avec leur nature), **B**
  (une substitution contradictoire), **NC⁺** (une vraie non certifiable), **R** (une réfutation certifiée sans
  hypothèse), **R_H**, **NC⁻** (une fausse non certifiable : fondée sur une source citée seulement ; la proposition de
  l'étude pour NOYAU 0.4, L13), **N**.
- **Le budget** (étude § 3.7 (f)) compte les substitutions évaluées. Interrompue, une classe est E si une solution
  certifiée **sans hypothèse** a été trouvée ; R si la recherche positive est finie sans aucun appui positif et qu'une
  réfutation certifiée a été trouvée ; **?** sinon (L3, L4). Une classe non atteinte est ?. Une erreur est une erreur.

**L22, une même substitution certifiée de chaque signe sous des hypothèses différentes (résolution du 28/11,
provisoire, à confirmer par la propriétaire ; `docs/mesures/FORMEL_BANCS.md`, § 2.4, dc-014).** Le statut local suivait un
ordre de priorité, E_H avant R_H. Une substitution σ certifiée positive sous H₁ et négative sous H₂, sans l'être d'aucun
signe sans hypothèse, donnait donc E_H, et la réfutation sous H₂ n'entrait pas dans le statut. C'est une priorité donnée
au positif, que la décision du 28/11 (§ 1) exclut. Pour une telle σ, la valeur est V sous H₁, F sous H₂ et B sous H₁ ∪ H₂.

- **Une ligne doublement conditionnelle** est une ligne dont C⁺ et C⁻ sont non vides et ne contiennent pas ∅.
- **Le statut local** se lit dans cet ordre, avec CP l'union des C⁺ des lignes :
  1. si ∅ ∈ CP : **E**, sans changement ;
  2. sinon, si CP ≠ ∅ et qu'au moins une ligne certifiée positive a un C⁻ vide : **E_H**, sans changement. Une
     solution non contestée suffit à la conclusion existentielle ; une réfutation qui porte sur une autre substitution
     n'y retire rien (c'est la question L6, distincte) ;
  3. sinon, si CP ≠ ∅, c'est-à-dire que toute ligne certifiée positive est doublement conditionnelle : **ER_H**, un
     nouveau statut local, avec deux familles d'ensembles minimaux d'hypothèses :
     - `hyps_plus`, les ensembles minimaux de CP ;
     - `hyps_moins`, les réunions minimales d'un ensemble de C⁻ par ligne certifiée positive : sous chacune, tout
       candidat appuyé positivement est réfuté. Une réfutation qui porte sur une autre substitution n'y entre pas. Elle
       reste dans les réfutations citées, au titre de L6. La première rédaction prenait aussi les C⁻ des lignes sans D⁺ :
       une réfutation sans hypothèse d'une autre figure y mettait ∅ et effaçait la famille négative.

     Chaque hypothèse garde sa nature ;
  4. sinon, la suite inchangée : B, NC⁺, R, R_H, NC⁻, N.
- **Dans la table de la déf. 10,** ER_H appartient à la fois à I⁺ (avec E, E_H) et à I⁻ (avec R, R_H). Un profil qui le
  contient tombe donc sur la ligne « des classes V et des classes F » : `divergent`, (ℓ⁺, ℓ⁻) = (2, 2), et le profil
  garde la classe avec ses deux familles d'hypothèses. Pour qu'une seule ligne vaille (T8), la ligne « toutes
  certifiées positives, dont une sous hypothèses » demande en plus I⁻ = ∅, et sa duale I⁺ = ∅. T8 porte alors sur les
  dix statuts locaux.
- **Le dual** (proposition 3) envoie ER_H sur ER_H, en échangeant `hyps_plus` et `hyps_moins`.
- **Le consensus des branches** (§ 3.8), signe par signe, car une alternative de l'auteur ne vaut d'un signe que si
  chaque branche le vaut. La première rédaction de cette règle, faite le même jour, donnait ER_H à tout mélange de {E,
  E_H, ER_H} : elle certifiait un signe négatif que les branches E et E_H n'ont pas. Elle est corrigée ainsi :
  - **le côté positif** vaut si toutes les branches sont dans {E, E_H, ER_H}. Ses ensembles d'hypothèses sont les
    réunions minimales d'un ensemble positif par branche, ∅ pour une branche E, comme pour E_H ;
  - **le côté négatif** vaut si toutes les branches sont dans {R, R_H, ER_H}, avec ses réunions minimales de la même
    façon ;
  - **les deux côtés valent** seulement si toutes les branches sont ER_H : le résultat est ER_H. Un seul côté donne E,
    E_H, R ou R_H par les règles existantes, une branche ER_H y apportant la famille du signe. Si aucun côté ne vaut,
    ER_H compte comme B dans les règles existantes ;
  - par exemple, {ER_H, E} donne E_H sous la famille positive de la branche ER_H ; {ER_H, R} donne R_H sous sa famille
    négative ; {ER_H, ER_H} donne ER_H.
- **Les mesures** (déf. 12) se lisent signe par signe : une référence ER_H n'est jamais « l'autre signe ». La
  restriction des signes envoie ER_H sur R_H quand le signe + n'est pas licencié, sur E_H quand le signe − ne l'est pas,
  et sur N quand aucun ne l'est.
- **Partout ailleurs** (mesures, index, comparateur, restriction des signes), ER_H compte à la fois comme E_H et comme
  R_H.
- **L22b, ouvert.** On ne tranche pas ici une ligne certifiée positive sous H et réfutée sans hypothèse, ni l'inverse.
  La certification les exclut déjà, puisque C⁺ demande l'absence d'appui négatif connu. Un test doit le vérifier.

### 3.8 Les alternatives de l'auteur : la preuve par cas (étude § 3.4 ; L9)

Sous i, la valeur est le **consensus** des branches : D⁺ si chaque branche a D⁺, D⁻ si chaque branche a D⁻ (la
rencontre dans l'ordre d'information de Belnap) ; certifiée d'un signe si chaque branche l'est, les hypothèses réunies
d'une branche à l'autre. Ainsi « V dans toutes les branches » donne E, « V dans une seule » donne N, les branches
rapportées (le guide, § 7, précision 3). **Une branche n'est jamais une hypothèse** : la choisir serait une abduction, qui
doit expliquer des observations (décision 33) ; aucune n'est produite.

### 3.9 Le profil, les classes, la robustesse, la certification par classe (déf. 6 à 9)

- **Le profil** Π = (I, R), par contexte figuratif. Deux interprétations de même résultat — même statut, mêmes
  hypothèses, mêmes lignes gardées, leurs substitutions écrites sur leurs **classes de mentions** — sont dans la même
  **classe** (L5). Chaque classe garde le résultat de chacune de ses interprétations : sa certification est une **preuve
  par cas** (déf. 8 ; T3).
- **La description exacte d'une classe** est l'ensemble de ses **cylindres maximaux** h (∅ ≠ [h] ⊆ la classe) : il est
  canonique ; les préférences ne font que l'ordonner (T19, L14). Chaque cylindre est habité : un **témoin** (étude § 3.7
  (a)) ; jamais un domaine vide.
- **La robustesse** (déf. 7) de chaque statut local et de chaque signe : totale, partielle, nulle, avec sa couverture.
  Une conclusion d'un signe est **uniforme** si une même substitution, au sens des mentions, est certifiée dans toutes
  ses classes et branches (∃σ∀i) ; **par cas** sinon (∀i∃σᵢ). `etablie_uniformement` est l'approximation du noyau 0.3.
- **L'ordre des profils** (déf. 9) se lit sur les affirmations ; les mesures de sûreté (déf. 12) le réalisent.

### 3.10 Le statut synthétique, son ordre, son dual, les mesures, l'index (déf. 10 à 12, étude § 3.6)

- **Syn(Π)** est la table de la déf. 10, chaque ligne écrite **indépendamment** des autres (`lignes_satisfaites`) : T8
  vérifie, sur tous les profils de zéro à quatre classes et des dix statuts locaux (neuf avant L22), qu'exactement une ligne vaut. Ses
  attributs : la ligne, le signe d'un NC, la couverture de chaque signe, les hypothèses par classe et par nature,
  l'uniformité, les témoins, les réfutations citées et si elles sont **fermées** (L6).
- **L'ordre** (déf. 11) : (ℓ⁺, ℓ⁻) par la table de l'étude ; ce que chaque niveau garantit est vérifié sur tous les
  profils abstraits (ℓ ≥ 1 : une dérivation de ce signe ; ℓ ≥ 2 : une classe certifiée ; ℓ = 3 : toutes, sans
  hypothèse). `aucune_interpretation` est en (0, 0), jamais en (3, 3).
- **Le dual** (proposition 3) : T7, sur les profils abstraits et les cas tirés.
- **Les mesures** (déf. 12) : e⁺_der, e⁺_cert, e⁻_der, e⁻_cert, d_nr, n_perdue, sur des interprétations appariées.
  `signes_licencies` et `restreindre` rendent, pour la notation, le seul signe que le comparateur licencie.
- **L'index** (étude § 3.6) : une notation n'est écartée de l'examen que si I ≠ ∅ et que F_n n'a d'appui positif, même
  sous hypothèse, dans aucune interprétation, aucune branche, aucun contexte figuratif. Une réfutation ne retire rien.

### 3.11 Le comparateur d'inclusion et les propositions de sûreté (étude § 2.6 ; NOYAU § 8)

**Q1 ⊆ Q2** (relativement à K) : toute description où Q1 est établie établit Q2. Pour chaque sélection S1 de Q1, le
comparateur cherche une sélection S2 de Q2 et un homomorphisme **h : var(S2) → var(S1)** (chaque atome de S2 entraîné
par son image : même prédicat, même valeur, type de S1 ⊑ type de S2 **par des inclusions attestées**). Les variables
liées par `meme` sont fusionnées, et les types d'une variable conjoints (une normalisation). Il rend :
- `oui`, avec h pour chaque sélection de Q1 (h dépend de la sélection, L11) ;
- `non`, avec un **contre-exemple** : le graphe canonique de S1 (un référent par variable, une assertion positive de
  l'auteur par atome), où Q1 est établie et Q2 ne l'est pas ; ou ce graphe plus un « jumeau » quand une identité `meme`
  de S2 tombe sur une seule variable de S1 sans coréférence dite ;
- `indetermine`, avec sa raison : une construction hors de la méthode (¬, ∃, quantification, ⊥), un cas insatisfiable,
  Q2 établie sur le graphe canonique sans homomorphisme (une règle de K, dont la négation n'est pas vérifiée).

**La transmission de la négation** (l'étape 3 de NOYAU § 8) est ici une conséquence de la sémantique, non un contrôle de
plus : les appuis négatifs passent par le même ordre ⊑ que les positifs (l'étude § 5.2 : « tous deux par inclus »), et
⊑ est transitif. Ce qui nie S2 sous σ ∘ h nie donc S1 sous σ. Les deux exceptions sont celles du noyau : le jumeau, et
une chaîne de `meme_individu` (une distinction entre ses bouts ne réfute aucun maillon).

**Les propositions de sûreté**, signe par signe (T21, T22) :
- **positive** : oui(Q1 ⊆ Q2) et D⁺(Q1, σ) ⇒ D⁺(Q2, σ ∘ h⁺) ;
- **négative** : oui(Q2 ⊆ Q1) et D⁻(Q1, τ ∘ h⁻) ⇒ D⁻(Q2, τ), sélection par sélection, pour τ close par les identités
  de Q2 (L10).
Le lion ailé est écrit à la main dans les deux sens (`test_lion_aile_dans_les_deux_sens`) : seul le positif est licencié
par Q_sys ⊆ Q_ref ; le rapporter comme une réfutation de la notation est une erreur e⁻_der, que la mesure détecte.

### 3.12 Les points où la version 1.1 est incomplète ou contradictoire

Ils ne sont pas corrigés dans l'étude. Le langage adopte une lecture, dite ici ; le § 7 dit lesquels l'interpréteur a
révélés par un test qui échouait.

- **L1, la certification est asymétrique dans la déf. 2.** C⁺ demande « l'absence d'appui négatif connu **pour ses
  atomes** », C⁻ « l'absence d'appui positif connu **de Q_i sous σ** ». Avec une proposition niée qui réfute une
  conjonction (D41, étude § 6.4), aucun atome n'est nié et la sélection l'est : la lecture par atomes certifierait une
  valeur B et violerait T6. Le langage lit les deux sur la requête entière.
- **L2, la déf. 1 ne dit pas l'arbre négatif des fondements nouveaux.** « Un enfant d'un `et`, tous ceux d'un `ou`,
  chaque atome lié par un appui négatif (§ 6.3) » ; or le § 6.3 range parmi les appuis négatifs des propositions niées
  et des quantifications, qui ne portent pas sur un atome. Le langage définit D⁻ par la réfutation des sélections
  (RS 13), qui redonne l'arbre négatif sans elles.
- **L3, l'interruption sous hypothèses.** Le § 3.7 (f), règle f1, dit qu'une classe interrompue où une solution
  certifiable a été trouvée « est E ou E_H, NOYAU § 4.5 » ; NOYAU § 4.5 et D32 interdisent de conclure « sous
  hypothèses » après une interruption (E_H dit qu'aucune solution sans hypothèse n'existe). Le langage suit NOYAU : E
  seulement ; E_H interrompu est ?.
- **L4, « l'absence établie de tout appui positif »** (f1, et le § 3.5 de l'étude) : de Q sous σ, ou de Q ? Seule la
  seconde rend le statut R sûr après une interruption (une autre substitution pourrait être E). Le langage lit « de Q ».
- **L5, « la même au sens des mentions » n'est pas transitive** (avoir une mention commune). La déf. 6 groupe pourtant
  les classes par cette relation. Le langage groupe par l'égalité des classes de mentions, et réserve la mention
  commune à l'uniformité (déf. 7).
- **L6, la déf. 10 ne distingue pas une réfutation fermée d'une réfutation « pour ces référents ».** Le statut local R
  est l'`ecartee` de NOYAU § 4.4, « écartée pour ces référents » ; la déf. 10 en fait `ecartee` pour la notation (ℓ⁻ = 3),
  même quand la réfutation porte sur un référent qu'aucun autre atome de la requête ne retient. Le langage suit la
  lettre de l'étude, et l'attribut `refutation_fermee` et la liste des réfutations citées le disent (§ 7, R5).
- **L7, une nature manque à la déf. 4.** L'étude (§ 2.1) dit qu'un statut st_K(i) peut demander « une connaissance non
  attestée », et NOTATION § 5 qu'une entrée non attestée « ne fonde qu'une hypothèse » ; la déf. 4 n'a pas cette nature.
  Le langage ajoute `connaissance_non_attestee`, distincte de toutes les autres.
- **L8, l'exclusivité de l'ancrage** est « une incompatibilité du langage » au § 6.2, et une « convention d'évaluation »
  non tranchée au § 8.4 (décision 26). Le langage la tient pour une propriété du langage (RS 6) ; la décision reste à la
  propriétaire.
- **L9, les alternatives de l'auteur.** L'étude (§ 3.4) en fait des cas de la preuve, mais ses déf. 1 et 5 ne donnent
  de valeur que par (i, σ). Le langage définit la valeur sous i par le consensus des branches (§ 3.8), ce qui redonne la
  règle du guide (§ 7, précision 3).
- **L10, h⁻ envoie une variable sur une classe de coréférence.** Le comparateur fusionne les variables liées par `meme`
  (comme NOYAU § 8 le fait par la coréférence du graphe canonique). La proposition 2 dit « toute substitution τ de
  Q_i » ; pour une τ qui lie X et pas Y alors que Q_i dit meme(X, Y), τ ∘ h⁻ lie plus que τ, et la transmission échoue.
  Elle vaut pour les τ closes par les identités de Q_i.
- **L11, h⁻ dépend de la sélection.** T22 parle d'un h⁻ ; pour une requête disjonctive, il y en a un par sélection, et
  la propriété vaut sélection par sélection.
- **L12, ⊥ rompt la réflexivité du comparateur.** ⊥ ⋢ ⊥ (étude § 3.2, § 5.2) : Q ⊆ Q n'est pas `oui` si Q a un type ⊥.
  Le langage rend `indetermine`.
- **L13, le signe de NC** est une proposition pour NOYAU 0.4 (étude § 3.5) : le langage la réalise (NC⁻), donc il ne
  lit pas NOYAU 0.3 sur ce point.
- **L14, le recouvrement minimal de la déf. 7 n'est pas unique**, donc « les plus préférés d'abord » n'en fait pas une
  fonction du profil, et T19 (« seul l'ordre des cylindres change ») ne vaut pas pour un recouvrement glouton. Le
  langage rend l'ensemble canonique des cylindres maximaux.
- **L15, T4 renvoie à « l'oracle actuel »**, qui ne connaît ni les points, ni les propositions niées, ni les contextes,
  et que l'indépendance interdit d'importer. T4 est lu comme une propriété de la résolution et de la recherche (§ 6).
- **L16, l'exemple 1 du § 3.7 (c)** écrit la couverture de mn-004 « [angels (D) = angels (Δ)] » : ce n'est pas un
  cylindre. Elle est l'union de trois cylindres, le préféré d'abord.
- **L17, le § 8.4 sur l'ajout d'une contrainte** : « un profil divergent peut devenir n'importe quel statut d'un seul
  signe, ou le rester » ; il peut aussi devenir contradictoire, non_certifiee, inconnue ou aucune_interpretation.
- **L18, T23 est trop forte** : « chaque C⁺ du petit K est, dans le grand, C⁺ ou B ». Il peut être NC⁺ : un grand K peut
  nier une prémisse de l'appui (« une lionne ») sans nier la requête (« un félin ») ; la valeur reste V.
- **L19, la numérotation de co-018.** L'étude cite « co-018#4 » (« either a monk or a nun ») ; le banc v3 la numérote
  n = 3. Ce n'est pas une question de sémantique.
- **L20, l'incompatibilité indexée de l'étude (§ 6.2) n'a pas de forme `relation`** ; la décision 9 en demande une (un
  ordre strict et son inverse). Le langage l'ajoute (la forme `relation` de G 21).
- **L21, l'index (π, s) de la déf. 5.** Le résultat y est donné « dans chaque chemin π et chaque situation s ». Une
  définition qui nomme deux situations (pi-003 : « in a later scene of the same picture ») ou en demande une seule
  (ee-019 : « while ») ne s'évalue pas « dans une situation s ». Le langage indexe le modèle par le contexte, et fait de la
  situation une variable de la substitution (`dans`, `succede`) : le résultat dit la situation de chaque solution, et une
  définition qui ne nomme aucune situation n'en contraint aucune (décision 14, la situation implicite).

## 4. La syntaxe concrète JSON (`nr-1`)

Elle est une **traduction** de la syntaxe abstraite, rien de plus ; `docs/NOTATION_REFERENCE.md` (version 1) la décrit
pour ceux qui écrivent les références. Les conventions :

| syntaxe abstraite | JSON |
|---|---|
| un référent r ; une variable X | `"r"` ; `"?X"` |
| un concept c ; ⊥ ; Alt(p) ; T₁ ∪ T₂ ; T₁ ∩ T₂ | `"wn30:…"` ; `"⊥"` ; `{"alternatifs": "p"}` ; `{"union": [T₁, T₂]}` ; `{"conjonction": [T₁, T₂]}` |
| un atome (G 8) | `{"pred": …, "args": [t…], "type": T, "valeur": v, "contexte": "?C"}` |
| ∧, ∨, ¬, ∃, quantification, Selon (G 14) | `{"et": […]}`, `{"ou": […]}`, `{"non": F}`, `{"existe": {"variables": [[x, sorte]], "corps": F}}`, `{"compte": {"quant", "n", "variable", "restriction", "portee", "membres"}}`, `{"selon": {"point", "cas": {v: F}}}` |
| une assertion (G 13) | `{"id", "contenu": {"atome": …} \| {"non": {"locales", "atomes"}} \| {"quantification": …}, "qualification", "garde": {p: [v…]}, "provenance"}` |
| une contrainte (G 17) | `{"id", "forme", "interdits": [{p₁: v₁, p₂: v₂}…], "source", "sorte"}` |
| une entrée de K (G 21) | `{"entree": "inclusion" \| "regle" \| …, "id", …, "source": {…}, "statut"}` |
| un cas (G 23) | `{"notation": "nr-1", "id", "description", "definition", "connaissances"}` |

Les valeurs par défaut ne s'écrivent pas (une assertion affirmée, positive, de l'auteur, dans `principal` ; une garde
vide ; une provenance vide). Le test d'aller-retour porte sur les cas tirés et les exemples, à travers une sérialisation
réelle ; il a trouvé une collision (la clé `sorte` d'une entrée et le champ `sorte` d'une incompatibilité), corrigée en
nommant l'espèce `entree`.

## 5. Le rapport au noyau 0.3

**Le fragment.** Le langage actuel du noyau (les assertions v1 de `docs/ASSERTIONS.md`, les requêtes UCQ sans négation
de NOYAU § 3) est le fragment suivant du langage :
- **les assertions** : une entité devient un référent et son assertion `type` ; un nom, une propriété, une relation,
  un rôle, un nombre, une coréférence, une distinction s'écrivent tels quels ; la polarité, la modalité, la portée et
  l'énonciateur deviennent une qualification (la portée du noyau est la projection plate du contexte, FS § 2.5) ; une
  alternative du noyau, qui n'appuie rien, devient une alternative de l'auteur (que le noyau ne traite pas par cas) ;
- **la négation** : une assertion niée du noyau devient une proposition niée, et le tableau de NOYAU § 1.1 se lit
  ainsi : une propriété ou une relation niée, un atome nié ; « l'entité nue niée, seule dans sa classe » (« pas de lion »)
  ¬∃x lion(x), de domaine le contexte ; « l'entité nue niée d'une classe qui a un membre présent » (« ce personnage
  n'est pas un saint ») ¬saint(e) ; un événement nié avec ses rôles, la proposition ¬∃v (evt(v) ∧ rôles), qui réfute
  par RS 13 sans exiger, comme le noyau, un autre événement présent ;
- **les requêtes** : et, ou, les atomes, meme, distincts, nombre ; sans ¬, sans ∃ explicite, sans quantification,
  sans contexte nommé, sans situation ; un seul contexte d'évaluation ; aucune alternative ; aucune définition
  structurée (F_s = F_n).

**Les sens et D30.** Dans le noyau 0.3, un mot du texte a ses sens (`K:sens`), un mot de la définition aussi, et la
règle D30 (NOYAU § 2) dit quand un lien est certain. Dans le langage :
- un mot w de D d'occurrence o devient un **point de D** p_o de domaine sens(w), **sans contrainte** ;
- un mot L de la définition devient le type **union** sens(L) (D30 : « un lemme y est satisfait par l'un quelconque
  de ses sens », étude § 5.3), non un point ;
- **le lien positif certain** de D30 (« pour tout s_D ∈ V(p_o), il existe s ∈ sens(L) tel que s_D ⊑ s ») est
  exactement « sous toute i, s_D = i(p_o) ⊑ ⋃ sens(L) » (S6) : Syn = `etablie` (ligne 4) ; un lien seulement possible
  est un cylindre : `etablie_sous_hypotheses` (ligne 6), et `sens_suppose` est l'abréviation de ce cylindre ;
- **la négation certaine** (« pour tout s_D et tout s ∈ sens(L), s ⊑ s_D ») est exactement « sous toute i,
  ⋃ sens(L) ⊑ i(p_o) » (S3), la réfutation de RS 13 ;
- **les lectures conjointes** (lot 4) sont l'univocité de i : une occurrence n'a qu'un sens par interprétation ; la
  limite que le noyau garde (les négations seulement possibles ne sont pas confrontées entre elles) disparaît ;
- **∃σ∀i** : le noyau certifie une substitution dont les liens valent pour tous les sens ; c'est
  `etablie_uniformement`, plus forte que l'`etablie` par cas (rq-010).

**D30 est donc le cas particulier « points de D sans contrainte, définition typée par l'union des sens de son
lemme »**, et la décision 3 de la propriétaire remplace l'union par un ensemble de concepts **alternatifs** (un point de
Δ). Le test `test_d30_cas_particulier` le montre : le même lemme « lion » des deux côtés donne `etablie` avec l'union, et
`etablie_sous_hypotheses` avec le point (deux cylindres, un par sens). Deux écarts restent, dits : la lexicalisation (un
pas de `sous` d'un sens vers son lemme) n'a pas de place dans le langage, parce qu'une requête typée par des sens
s'atteint par la seule inclusion (étude § 5.2) ; et `negation_autre_sens`, qui donnait au positif une priorité, devient
une classe F ou B du profil, que la table de la déf. 10 range sans priorité de signe.

## 6. L'interpréteur de référence et l'oracle de propriétés

**L'interpréteur** (`semantique_reference/`) est écrit d'après ce document seul ; il n'importe rien de `oedipamaas/` ni
de `tests/oracle/`. Il énumère exactement : Ω, I, les branches, les contextes, les substitutions candidates ; aucun
filtrage ne remplace une énumération. Chaque fonction cite la définition qu'elle réalise :

| définition | fonction |
|---|---|
| Ω, I, les contraintes dérivées, les composantes (étude § 2.1, § 3.3, § 3.4, § 3.7 (e)) | `omega`, `interpretations_admissibles`, `contraintes_derivees`, `composantes`, `points_utilises` |
| ρ(D, i), ρ(Δ, i) | `resoudre_description`, `resoudre_definition` |
| le modèle de Belnap sous (i, w) (RS 1 à RS 10) | `Base` |
| ⊑ (S1 à S6), les alias, les distinctions | `connaissances.Ordre` |
| D⁺, D⁻, ¬, ∃, les quantifications (déf. 1, RS 11 à RS 13) | `options_pos`, `options_neg`, `refutations_selection`, `compte_pos`, `compte_neg` |
| val, C⁺, C⁻ (déf. 2) | `ligne`, `premisses_niees` |
| le statut local, les lignes gardées, le budget (déf. 5, § 3.7 (f)) | `statut_local`, `retenues`, `evaluer_branche` |
| les alternatives de l'auteur | `branches_de`, `combiner_branches` |
| le profil, les cylindres, la robustesse, l'uniformité (déf. 6 à 8) | `profils`, `cylindres_maximaux`, `robustesse`, `uniforme`, `etablie_uniformement` |
| Syn, son ordre, son dual (déf. 10, 11, prop. 3) | `lignes_satisfaites`, `syn`, `niveaux`, `inferieur`, `dual_statuts`, `dual_nom` |
| les mesures, les signes licenciés, l'index (déf. 12, § 2.6, § 3.6) | `mesures`, `signes_licencies`, `restreindre`, `index_retient` |
| l'inclusion des requêtes (§ 2.6, NOYAU § 8) | `inclusion.comparer`, `graphe_canonique`, `composer` |

**L'oracle de propriétés** (`tests/test_semantique_reference.py`) éprouve des **propriétés** — sur des cas tirés au
hasard par `tests/semantique_reference_gen.py` (graine fixée ; descriptions, définitions, K et points ; chaque
construction du langage y figure, et chaque cas tiré est bien formé), et sur des exemples écrits. Il ne recopie aucune
table de décisions : les douze lignes de la déf. 10 n'y sont écrites qu'une fois, dans l'interpréteur, et T7, T8 et la
déf. 11 en vérifient les propriétés (fonction, dualité, garanties). La variable `SEMREF_GRAINE` change la graine pour
des essais ; la graine fixée et douze autres passent (§ 7).

| | propriété | test | résultat |
|---|---|---|---|
| T1 | I est exactement l'ensemble sans violation ; indépendant des préférences | `test_T1_…` | passe |
| T2 | aucune contrainte ne couple D et Δ ; I = I_D × I_Δ ; RF12 rejette le couplage | `test_T2_…` | passe |
| T3 | une valeur par point ; chaque prémisse d'une preuve est présente sous chaque i de sa classe | `test_T3_…` | passe, après une correction (§ 7, R7) |
| T4 | le résultat local est celui de ρ(D, i), ρ(Δ, i) évalués sans point, et celui de l'énumération exhaustive des substitutions (lu au § 3.12, L15) | `test_T4_…` | passe, après deux corrections (§ 7, R8) |
| T5 | les classes partitionnent I et portent leurs champs | `test_T5_…` | passe |
| T6 | C⁺ ⇒ D⁺ ∧ ¬D⁻ ; C⁻ ⇒ D⁻ ∧ ¬D⁺ ; val = (D⁺, D⁻) ; de même sous H | `test_T6_…` | passe (lecture L1) |
| T7 | Syn(Π̄) est le dual de Syn(Π) | `test_T7_…` | passe |
| T8 | la table est une fonction (énumération jusqu'à quatre classes) | `test_T8_…` | passe |
| T9 | I = ∅ ⇒ aucune_interpretation, aucune preuve, rien d'écarté de l'index | `test_T9_…` | passe |
| T10 | les témoins satisfont les contraintes ; aucun cylindre vide | `test_T10_…` | passe |
| T11 | ajouter une contrainte ne change aucun statut local ; Syn' est prévu | `test_T11_…` | passe ; le § 8.4 est incomplet (L17) |
| T12 | la monotonie des dérivations | `test_T12_…` | passe |
| T13 | la conservation des natures | `test_T13_…` | passe |
| T14 | une couverture totale sous hypothèses non lexicales n'est jamais etablie ni ecartee | `test_T14_…` | passe |
| T15 | V et F ⇒ divergent, deux preuves ; un seul B n'est jamais divergent | `test_T15_…` | passe, après une correction (§ 7, R7) |
| T16 | etablie ⇔ chaque classe certifiée ; l'uniformité recalculée indépendamment | `test_T16_…` | passe |
| T17 | le calcul par composantes est égal au calcul sur Ω | `test_T17_…` | passe |
| T18 | l'interruption : ?, incomplet ; E et R gardés ; rien d'autre | `test_T18_…` | passe (lecture L3, L4) |
| T19 | les préférences ne changent ni I, ni le profil, ni Syn, ni l'ensemble des cylindres | `test_T19_…` | passe (lecture L14) |
| T20 | l'index retient toute notation dérivable ; une négation n'en retire aucune | `test_T20_…` | passe |
| T21 | la sûreté positive | `test_T21_…` | passe, après une correction du comparateur (§ 7, R1) |
| T22 | la sûreté négative, et le lion ailé | `test_T22_…`, `test_lion_aile_…` | passe, sous la lecture L10 et L11 (§ 7, R2) |
| T23 | un C⁺ du petit K a dans le grand la valeur V ou B | `test_T23_…`, `test_T23_revele_…` | passe sous sa forme corrigée (L18) |
| T24 | des appuis seulement non figuratifs ne donnent jamais V dans la figuration | `test_T24_…` | passe |

**Les autres propriétés** : la provenance sans effet ; l'invariance de traduction **au niveau des profils** (des
référents, des assertions et des points renommés, l'ordre permuté, la langue changée : même profil, mêmes classes, même
Syn, mêmes natures) ; la négation propositionnelle qui échange les appuis, ¬¬F = F, et le silence jamais négatif ;
l'antonymie et l'opposition typique sans effet ; l'aller-retour JSON ; les mutations de formation ; les contre-exemples
du comparateur, chacun vérifié.

**Les exemples écrits** : le lion ailé dans les deux sens (avec la mesure e⁻_der et le comparateur muté) ; l'ensemble
vide (la personnification, une restriction hors de son domaine) ; mn-004 (neuf couples, trois F, six N, trois
cylindres) ; rq-010 (∀i∃σ contre ∃σ∀i) ; co-018#4 (l'alternative, l'union, les alternatifs, la conjonction) ; pi-003
(les natures lecture et identite gardées, n_perdue) ; un profil divergent (ep-009) ; une contradiction interne contre
une divergence, et une contradiction documentaire ; une hypothèse dont la nature est conservée (typique, non attestée,
abduction) ; un calcul interrompu (rq-010) ; une définition structurée (suffisante non établie, nécessaire établie) ;
les quantifications énoncées et de requête ; l'incompatibilité indexée par le moment ; D30 comme cas particulier.

**Pour éprouver le futur moteur.** Les propriétés ne dépendent pas de l'interpréteur : elles portent sur des profils
(un statut local par interprétation et par contexte, des lignes, des hypothèses avec leur nature, des couvertures). Le
moteur sera éprouvé de deux façons : (1) les mêmes générateurs, et le **profil** du moteur comparé à celui de
l'interpréteur, interprétation par interprétation (jamais le seul nom du statut) ; (2) les propriétés T1 à T24 appliquées
directement aux profils du moteur, qui peut filtrer, factoriser et borner son calcul : T17 (les composantes), T18 (le
budget) et T19 (les préférences) sont écrites pour cela. Les deux réfutations « pour ces référents » des exemples
ee-002#3 et ee-002#4 (§ 8 : `refutation_fermee` faux), et la réfutation fermée de mn-004 (vrai), en sont des cas
témoins pour R5.

**Lancer.** `python3 -m pytest tests/test_semantique_reference.py tests/test_semantique_reference_exemples.py` (57
tests, une dizaine de secondes) ; `python3 -m semantique_reference.banc` (les cas réels).

## 7. Ce que l'interpréteur a révélé

Les tests ont échoué avant de passer ; chaque échec est rangé ici : une incohérence ou une lacune de l'étude, ou une
erreur de l'interpréteur, dite telle.

- **R1, une inclusion non attestée ne licencie rien** (T21, la graine fixée). Le comparateur acceptait l'entraînement
  `c6 ∪ c2 ⊑ c4 ∪ c5` par une inclusion non attestée (c2 ⊑ c5) ; la sûreté positive échouait sans hypothèse.
  L'étude (§ 2.6) ne dit pas comment une entrée non attestée entre dans le comparateur. Le langage : le comparateur ne
  compte que les inclusions attestées ; une inclusion sous hypothèse ne licencie aucun signe.
- **R2, h⁻ va sur une classe de coréférence** (T22, la graine 5). Une paire où Q_i dit meme(Y, X) : pour τ = {X ↦ r}, Y
  non lié, Q_sys est réfutée sous τ ∘ h⁻ et Q_i ne l'est pas sous τ. La proposition 2 vaut pour les τ closes par les
  identités de Q_i (L10), et sélection par sélection (L11).
- **R3, la certification passe à NC⁺** (T23, construit) : L18.
- **R4, un profil divergent peut devenir contradictoire** (T11, construit) : L17.
- **R5, une réfutation « pour ces référents » fait `ecartee`** (L6). Dans « vêtu maintenant », une requête « nu,
  antérieur » est réfutée pour la substitution « S = l'état vêtu », par l'exclusivité de l'ancrage, alors que rien n'est
  dit d'un état nu ; le profil n'ayant rien d'autre, Syn = ecartee. C'est la lettre de l'étude (déf. 5 : NOYAU § 4.4) ;
  le jugement de référence dirait inconnue. Une première version de l'interpréteur ajoutait « un référent n'a qu'une
  situation » comme fondement négatif : pi-003 sans identité devenait `ecartee` (« écartée pour E₁ = l'événement de la
  seconde scène »), contre le § 8.4 de l'étude ; ce fondement n'est pas dans la liste fermée du § 6.3, et il a été
  retiré. Les deux disent la même chose : chaque exclusivité structurelle multiplie les réfutations relatives à des
  référents sans rapport, et la déf. 10 les compte comme des réfutations de la notation. **Une décision est à prendre**
  (pour NOYAU 0.4 et l'étude) : ne compter pour R que les réfutations dont la substitution lie chaque variable à un
  référent que la condition suffisante retient par ailleurs, ou les seules réfutations fermées, ou garder la lettre.
- **R6, la clé `sorte`** de la syntaxe concrète (l'aller-retour) : une erreur de la traduction, corrigée (§ 4).
- **R7, deux erreurs de l'interpréteur**, corrigées : une classe R_H sans ligne gardée (les réfutations certifiées sous
  hypothèses n'étaient pas gardées : T15, graine 2) ; une preuve de classe qui n'était celle que du premier membre (T3,
  graine 5) — la classe garde maintenant le résultat de chaque interprétation, ce qui est la preuve par cas de la déf. 8.
- **R8, deux erreurs de la recherche**, corrigées, que l'énumération exhaustive de T4 a montrées : une liaison mal
  sortée (une variable d'individu liée à un état) ; des réfutations minimales qui cachaient une réfutation plus grande
  de l'auteur derrière une plus petite d'une source citée (la certification en dépend).
- **R9, RF6 situe les identités qui traversent les contextes** (la formation de pi-003) : « cette moitié de manteau »
  relie un objet du rêve et un objet de la première scène ; seule l'assertion écrite dans le contexte du rêve les voit
  tous deux. L'étude (§ 7.4) dit que `meme_individu` traverse les contextes, sans dire où on l'écrit.
- **R10, la nécessité de la forme `relation` des incompatibilités** (L20) et de l'**étiquette `refutation_fermee`**
  (L6), apparues en écrivant les exemples ep-009 et mn-004.

## 8. Les cas réels des bancs

Cinq dossiers, dans `semantique_reference/exemples/` : la description et la définition tirées des bancs
(`a_annoter`), la provenance calculée sur le texte (chaque extrait est vérifié à ses offsets), les points, un K minimal,
et la **copie, sans modification,** de l'entrée adjugée (`reference/`). Le niveau (a) écrit les sens que le contexte
fixe et K\*, les postulats de signification ; le niveau (b), les points et les contraintes que K atteste.

| cas | niveau | calculé | référence | comparaison |
|---|---|---|---|---|
| ee-002 | (a) | etablie | etablie | égal |
| ee-002#0 (traduction) | (a) | etablie | etablie | égal ; même profil que le français (étude § 2.7) |
| ee-002 | (b) | etablie_sous_hypotheses : 12 interprétations, 1 E, 11 N ; le cylindre [cavalier ↦ 10185793, horseman ↦ 10185793] | etablie | écart de **K** : la glose de WordNet n'exclut ni les cinq autres sens de personne ni l'éleveur (étude § 1.1) ; la restriction de sélection exclut la pièce d'échecs et les documents sur la composante {tendre, cavalier} ; un affaiblissement, non une erreur |
| ee-002#2 (rôles inversés) | (a) | inconnue | inconnue | égal ; aucune asymétrie du don n'est attestée (décision 9) |
| ee-002#3 (vêtu, don antérieur) | (a) | ecartee | ecartee | égal ; par l'exclusivité de l'ancrage et l'incompatibilité indexée vêtu / nu |
| ee-002#4 (pas nu) | (a) | ecartee | ecartee | égal ; une proposition niée, au moment figuré |
| mn-004 | (a) | ecartee (réfutation fermée) ; état d'origine : inconnue | ecartee ; état d'origine : inconnue | égal, avec le contexte |
| mn-004 | (b) | ecartee_sous_hypotheses : 3 R, 6 N | ecartee | écart de **K** : aucune contrainte attestable sur « angels » (étude § 3.7 (c)) |
| mn-004#1 (deux anges) | (a) | etablie | etablie | égal |
| mn-004#2 (le contrat) | (a) | inconnue | inconnue | égal ; la négation est dans un contexte déontique |
| rq-010 | (a) | etablie, par cas, non uniforme | etablie | égal ; ∃σ∀i ne l'établit pas |
| rq-010#2 (collectif dit) | (a) | etablie | etablie | égal |
| rq-010#4 (« seem ») | (a) | etablie_sous_hypotheses [abduction] | etablie_sous_hypotheses [abduction] | égal, nature comprise |
| co-018#3 (alternative) | (a) | etablie, par cas | etablie | égal |
| co-018#3 (union) | (a) | etablie, uniforme | etablie | égal ; les deux représentations s'accordent |
| pi-003 | (b) | etablie_sous_hypotheses [identite] | etablie (étude § 8.4 ; pas de référence adjugée en v3) | écart de **représentation** : l'identité de Martin n'est pas dite ; une hypothèse de nature identite, gardée |
| pi-003 | (a) | etablie | etablie (idem) | égal ; l'identité tenue par le lecteur |
| pi-003#2 (« le même Martin ») | (a) | etablie | etablie (idem) | égal |

**Ce que ces cas montrent.** Aucun écart en (a). Les trois écarts de (b) sont ceux que l'étude prévoit (§ 1.4) : un
manque de K ou une identité non dite, mesurés comme des affaiblissements (déf. 12), jamais comme des erreurs de sûreté.
La famille `phenomenes_iconographiques` n'a pas de référence adjugée dans v3 : pi-003 est comparé au profil que
l'étude décrit. Les cinq dossiers se lisent et se vérifient par `test_semantique_reference_exemples.py`.

## 9. Ce qui manque

**L'écriture des 216 cas de base** (28/11) a relevé d'autres lacunes, numérotées L22 à L32 dans
`docs/mesures/FORMEL_BANCS.md`, § 4, et les constructions qui manquent aux 18 cas non représentés (§ 3). Elles ne sont
pas corrigées ici.

**Pour représenter les cas que le langage ne représente pas encore :**
- **les adjectifs de degré** et leur classe de comparaison (décision 30 : *young* / *old*) : l'indexation d'une
  incompatibilité ne connaît pas la classe ;
- **les modificateurs non intersectifs** (« un faux pistolet », « prétendu », « ancien ») : aucun opérateur ; seul
  l'ancrage antérieur dit « ancien » ;
- **les relations entre éventualités** (résultat, cause, but, simultanéité) : elles s'écrivent comme des `relation`,
  sans règle (un état résultant ne donne pas l'ancrage antérieur de son événement) ;
- **la partie et le tout** : l'entrée `partie` est inerte (décision 37) ; la transitivité de partie_de n'est pas une
  propriété du langage ;
- **les collections** : leurs membres et la distributivité des prédicats (décision 38, dans K) ; « deux anges » est
  une collection de type ange, sans membres reliés ;
- **les espèces, les génériques, la signification** (« le lion comme symbole », une personnification qui signifie un
  concept) : la sorte `concept` existe, sans relation de signification ;
- **l'abduction** : le langage reçoit les hypothèses (les assertions supposées, de leur nature) ; il ne les calcule pas,
  ni leurs concurrentes, ni leurs coûts ;
- **la décision documentaire `retenir`** (étude § 7.3), hors de la sémantique ;
- **le temps au-delà de l'ancrage et de la succession** (l'algèbre d'Allen, non nécessaire : étude § 9.7) ;
- **les contraintes dérivées côté Δ** (une restriction de sélection sur le libellé) : elles s'écrivent à la main ;
- **les alias et les distinctions non attestés** : sans effet dans la version 1 (une hypothèse de nature
  `connaissance_non_attestee` serait leur forme) ;
- **la quantification de la requête sur une situation** (« dans une même scène, tous… ») : le domaine d'une `Compte` est
  le contexte d'évaluation ;
- **la contrainte de situation implicite** (décision 14 : quand un libellé sans marque de simultanéité demande une seule
  situation) : la définition l'écrit ou non ; le langage ne la devine pas.

**Pour l'étude et le noyau,** les décisions que les points L1 à L21 demandent, et d'abord **R5** (ce que compte une
réfutation pour le statut R), **L3** (l'interruption sous hypothèses) et **L8** (l'ancrage : propriété du langage ou
convention).

**Pour l'interpréteur** : il est exact et lent par construction (l'énumération de Ω et des substitutions) ; un cas à
quatorze variables (pi-003) se calcule en une fraction de seconde, un cas à vingt points de domaine trois ne se
calculerait pas. Le budget le dit (`incomplet`) ; le moteur pourra filtrer, et le test différentiel comparera ses
profils à ceux de l'interpréteur.
