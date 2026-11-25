# Plan technique de la V1 (25 novembre 2026, révision 2)

Ce plan consolide les fondements v2 (`docs/FONDEMENTS.md`), les décisions D15 à D20 (`DECISIONS.md`), les quatre
propositions validées le 24/11 (statut de compilation, prototype vertical, projection, WOLF) et la seconde lecture
critique du même jour. Il dit, pour chaque chantier, ce qui est réutilisé, ce qui change, les invariants formels et
les critères de sortie. Aucun développement ne précède la validation de ce plan par la propriétaire.

**Révision 2** (relecture critique du 25/11, 14 points, tous intégrés ; § 8) : la projection devient une satisfaction
de requêtes sur le graphe du texte (substitution globale, relations vérifiées positivement) ; la composition des
quatre valeurs est définie ; la hiérarchie d'Iconclass n'est plus lue comme une subsomption ; aucune distinction
d'identité n'est tirée d'une absence ; le lecteur, le compilateur et le moteur logique sont évalués séparément ; le
vérificateur de preuves passe en P0 ; quatre jalons (M0 à M3) ; un ensemble de qualification finale utilisé une seule
fois ; des exigences de livraison.

**Le but de la V1.** Un moteur qui tire d'un texte libre (description visuelle d'Opus, cartel, notice, catalogue,
texte savant ; français et anglais) **toutes** les notations d'Iconclass que le texte justifie, chacune avec sa
preuve et les référents qui la portent, et non seulement le sujet principal. L'unité d'évaluation est le couple
**(notation, référent du texte)** : un objet peut relever de plusieurs notations, plusieurs objets d'une même notation,
et certains d'aucune notation assez précise ; une description de vingt objets doit voir chacun de ses référents
indexé autant qu'Iconclass le permet. Hors ligne, sans LLM (D20 : petits modèles locaux permis), précision d'abord,
sans que l'abstention soit un moyen d'y parvenir (son taux est mesuré).

**Ce que ce plan n'est pas.** Ni une réécriture du dépôt, ni une liste d'heuristiques : chaque mécanisme a une
définition formelle (chantier 1) avant son code, et un critère de validation indépendant du banc sur lequel il a été
mis au point.

---

## 0. L'état mesuré au départ

| Pièce | État | Mesure |
|---|---|---|
| Lecture des textes | UDPipe 1 par défaut, Stanza en option (D20) | rappel des éléments de scène 0,948 (Stanza), 0,897 (UDPipe) |
| Ancrage dans l'image (deux mondes, saillance) | `mondes.pl`, `scene.pl` | faux ancrages des profils 34 % → 11 % |
| Définitions | `definitions.pl`, 80 000 définitions (en, fr) | 4e jugement à l'aveugle : 88 justes / 140 (en), 94 / 140 (fr) ; dangereuses 22 / 20 |
| Statut de compilation | `compilation.pl` (premier jet) | 63 452 compilées, 16 631 partielles, 1 311 non prises en charge |
| Sens des mots des définitions | bilingue (WordNet ∩ WOLF) 187 443, hiérarchie 41 338, unique 21 675, aucun 65 329 | non jugé |
| Projection | `projection.pl` (premier jet : liens, rôles inversés, trois valeurs) | prototype vertical : § 0.1 |
| Noyau logique (M0, M1 en partie) | `docs/NOYAU.md` ; `requetes.pl`, `satisfaction.pl`, `verificateur.pl` | 43 tests sur graphes écrits à la main (`tests/plunit/test_noyau.pl`), dont les variantes de C6.4 et un banc de 135 preuves altérées, toutes rejetées |
| Ressources | WordNet 3.0, liens morphosémantiques (17 739), WOLF (102 671 paires ; 58 % des mots français des définitions, 86 % de leurs occurrences) | |

### 0.1 Le prototype vertical, premier passage (non corrigé, 25/11)

Le premier jet de la projection, sur une fiche sur cinq de l'ensemble de développement (40 définitions, 120 textes,
Stanza, 60 s au plus par texte ; détail dans `docs/mesures/V2.md`) :

| Texte | notation visée établie (ou un descendant) | candidate | absente | délai dépassé |
|---|---|---|---|---|
| positif | 5 / 40 | 11 | 11 | 12 |
| négatif | 2 / 40 | 9 | 19 | 9 |
| indéterminé | 2 / 40 | 12 | 22 | 4 |

- **Rappel** : 5 positifs sur 40. **Faux établis** sur la notation visée : 4 sur 80 négatifs et indéterminés.
- **Codes établis hors de la branche de la notation visée** (arbre canonique) : 1 528 pour 95 textes traités, soit
  environ 16 par texte, non jugés ; les plus fréquents sont faux à la lecture et viennent de **définitions trop faibles**. Par exemple,
  31D82 n'exige que « individual » ou « name », 73D68 que « event », 22A que « matter », 43B8 que « show »,
  25G3(PEAR-TREE) que « tree ». S'y ajoutent l'œuvre elle-même prise pour un objet figuré (11Q611 « object »,
  59 fois) et des gabarits « (...) » établis.
- **Temps** : médiane 18 s par texte, 25 textes sur 120 au-delà de 60 s (retours en arrière combinatoires de la
  recherche d'unités liées).

Ces chiffres confirment C3 (le compilateur ne garantit pas la suffisance : des segments de coordination deviennent
des alternatives entières) et C4 (une projection à substitution globale, dont le coût est borné par la taille de la
requête). Ils sont le point de comparaison de M1, pas une qualification.

---

## 1. Les dix chantiers, les quatre jalons

```
 M0 spécification   C1 sémantique formelle ─► C2 corrections logiques ─► contrats (requête, preuve, sortie JSON)
                                                                │
 M1 noyau logique   C3 compilation en requêtes ─┐               │
                    C4 projection + vérificateur ┼─► C5 moteur exhaustif / indexé ─► prototype vertical (validation M1)
                    C6 évaluation par composant ─┘   (graphes et définitions annotés : chaque pièce mesurée seule)
                                                                │
 M2 couverture      C7 couche sémantique · C8 mécanismes d'Iconclass · C9 abduction (hypothèses)  (validation M2)
                                                                │
 M3 V1 qualifiée    C10 qualification finale (une seule mesure, version figée) et livraison opérationnelle
```

- **M0 — la spécification** : C1 et C2 écrits et validés ; le fragment logique, les contrats de la requête, de la
  preuve et de la sortie fixés. Rien n'est codé dans le noyau avant M0.
- **M1 — le noyau logique** : C3, C4 (avec le vérificateur), C5 ; mesuré sur l'ensemble de **validation M1**.
- **M2 — la couverture fonctionnelle** : C7, C8, C9 ; textes libres FR/EN et descriptions d'Opus ; mesuré sur
  l'ensemble de **validation M2**.
- **M3 — la V1 qualifiée** : version figée, mesurée **une seule fois** sur l'ensemble de qualification finale ;
  livraison (C10).
- **C6** (protocole et évaluation par composant) accompagne tout le développement, dès M0 : chaque mécanisme a sa
  mesure avant d'être construit.
- Une ressource s'intègre quand une famille d'erreurs mesurée la demande (D17) ; les mesures de M1 décident de l'ordre
  de C7 et C8.
- Une fois ce plan validé, les décisions de conception ne se rouvrent que par écrit, sur une famille d'erreurs mesurée
  qu'elles empêchent de corriger (§ 6).

---

## 2. Les invariants formels

Ils valent pour tout le moteur. Chacun a son test, qui s'exécute à chaque modification (`tests/`) ; une modification
qui en casse un est refusée, quel que soit le gain de mesure.

| | Invariant | Test |
|---|---|---|
| I1 | **Pas de négation par échec.** Une exigence n'est fausse que par une assertion niée explicite, ou par un axiome de disjonction explicite (C2) appliqué à une preuve positive du même contexte. L'échec d'une preuve donne « inconnu ». | test de code : aucune règle de la projection ne produit une preuve négative à partir d'un échec ; paires « silence / négation » |
| I2 | **Un titre n'est jamais une preuve de figuration** (D15). Ce que seul le titre dit est un indice (modalité `titre`). | métamorphique : déplacer une phrase dans le titre fait passer un code d'établi à candidat |
| I3 | **Établi ⇒ une substitution qui satisfait la condition suffisante**, dont la définition est valide, complète, univoque et dont la suffisance est justifiée (C3.2), sans preuve négative pour cette substitution. | vérificateur de preuves (C4.6) |
| I4 | **L'index ne perd rien** : sur le fragment logique de C5, les résultats du moteur indexé sont ceux du moteur exhaustif ; un argument écrit, règle par règle, et une comparaison automatisée. | comparaison sur les ensembles de développement et de validation |
| I5 | **Une preuve est une structure vérifiable** : versions des connaissances, règles et régime d'inférence employés, substitution des variables, assertions sources et leurs passages, conditions satisfaites. Le vérificateur la contrôle étape par étape, sans réexécuter le moteur. | vérificateur de preuves |
| I6 | **Contextes séparés** : deux preuves de contextes différents (deux œuvres, le figuré et le monde réel, deux énonciateurs en désaccord) ne se combinent jamais en une seule substitution. | paires minimales |
| I7 | **Identité et distinction explicites** : deux variables d'une requête vont sur des référents distincts seulement si la requête le dit, sur le même seulement si elle le dit ; sinon les deux sont permis. Aucune distinction ni identité n'est tirée d'une absence d'information (C2.3). | paires : « Jérôme… le saint » ; « David et Goliath » ; « un homme qui se regarde » |
| I8 | **Monotonie sur les faits sans rapport** : ajouter une phrase qui n'introduit aucun référent coréférent, aucune relation avec les référents existants et aucune négation ne retire aucun code établi. Une phrase qui touche le graphe (coréférence, levée d'ambiguïté, révision d'hypothèse) peut légitimement en retirer. | métamorphique : ajout de phrases sans rapport |
| I9 | **Reproductibilité** : mêmes versions (moteur, base, analyseur, règles) ⇒ même sortie, à l'octet. | double exécution, aussi en traitement concurrent |
| I10 | **Ce qui est écrit à la main** : des règles de langue et la grammaire des libellés d'Iconclass, plus les axiomes de disjonction de C2, chacun motivé par écrit ; jamais une connaissance iconographique (quel saint porte quelles clés). | revue : liste fermée des fichiers concernés |
| I11 | **La hiérarchie d'Iconclass n'est pas une subsomption.** Trois opérations distinctes : l'**implication** (une conclusion nouvelle) seulement par les liens dont la sémantique l'autorise (une classe sous une classe dont la tête est un hyperonyme : lion → animaux) ; l'**ascendance documentaire** (les ancêtres d'un code, toujours accessibles, jamais une conclusion : une colline n'est pas un paysage comme genre, un épisode n'établit pas un autre épisode du récit) ; la **réduction de redondance** (n'afficher que le plus précis), une option de présentation réversible. | test de code : aucun code établi par la seule ascendance ; sortie complète et sortie réduite comparées |

---

## 3. Les chantiers


### C1 — Formaliser la sémantique (P0, M0)

**But.** Un texte de référence, FONDEMENTS v3, qui donne la signification exacte de chaque terme du langage
d'assertions et de chaque opération du moteur, avant toute modification du noyau.

1. **Les preuves et les quatre valeurs.** Une proposition p (une condition d'une requête, sous une substitution σ) a,
   dans un document, un ensemble de preuves positives p⁺ et négatives p⁻, chacune avec son assertion, son passage,
   son énonciateur et son contexte. Sa valeur suit la logique de Belnap, dans l'ordre de l'information :

   | p⁺ | p⁻ | valeur |
   |---|---|---|
   | ∅ | ∅ | inconnu |
   | ≠ ∅ | ∅ | vrai |
   | ∅ | ≠ ∅ | faux |
   | ≠ ∅ | ≠ ∅ | contradictoire |

   On ne construit pas de logique paraconsistante générale : les preuves sont gardées séparément et la valeur se lit à
   la fin. Une contradiction entre deux énonciateurs (« la notice identifie saint Pierre ; une étude récente le
   conteste ») est une sortie à part entière, qui cite les deux sources.
2. **La composition**, sur les paires (p⁺, p⁻) :
   - ¬p = (p⁻, p⁺) ;
   - p ∧ q = (p⁺ ∧ q⁺, p⁻ ∨ q⁻) ;
   - p ∨ q = (p⁺ ∨ q⁺, p⁻ ∧ q⁻) ;
   - **l'existentiel** ∃σ. φ(σ) (une requête : « il existe une femme et un enfant qu'elle tient ») a pour preuve
     positive une substitution σ telle que φ(σ)⁺ ; sa preuve négative ne vient que d'une négation **universelle
     explicite** du texte dans le même contexte (« aucun enfant », « no wings ») : qu'une substitution échoue, ou
     qu'elle soit contredite (un rôle inversé), invalide **cette substitution**, pas la configuration ailleurs dans
     l'œuvre (un lion attaque un homme, puis l'homme attaque le lion) ;
   - les contextes et les sources quantifient de la même façon : une preuve positive dans le figuré et une preuve
     négative dans une autre œuvre ne se rencontrent pas (I6).
3. **Les contextes** (FONDEMENTS § 2) : l'œuvre ⊃ le figuré ⊃ le signifié ; le monde réel ; les autres œuvres. Ce
   qu'une preuve de chaque contexte peut fonder (la figuration demande le figuré ; le classement, l'œuvre ; la
   désignation, le figuré ou le signifié).
4. **La modalité** : « affirmé » fonde une preuve ; « probable », « possible », « traditionnel » fondent une
   hypothèse (C9), jamais une preuve ; « ancien » (autrefois attribué) et « non affirmé » ne fondent rien ; « titre »
   est un indice (D15, I2).
5. **La négation** : sa portée (« sans ailes » nie la partie, pas l'ange) ; la différence entre « ne pas pouvoir
   démontrer » (inconnu) et « le texte nie » (faux).
6. **Les alternatives** : « X ou Y » du texte, hypothèses exclusives ; aucune n'établit seule, leur disjonction peut
   établir ce qu'elles ont en commun.
7. **La quantification** : le nombre (« trois anges », « deux mains ») comme contrainte sur le nombre dit ou compté ;
   les pluriels ; « un des », « tous ».
8. **Les régimes d'inférence**, chacun avec ce qu'il peut établir et ce qu'il ne peut que suggérer : figuration,
   désignation, classement de l'œuvre (FONDEMENTS § 4) ; généralisation taxonomique (par les seuls liens d'implication,
   I11) ; composition des notations (gabarits, clés, lettres doublées) ; abduction (hypothèses seulement, C9).
9. **Le fragment logique** du moteur (repris par C5) : des **unions de requêtes conjonctives** à variables typées,
   avec contraintes d'égalité et de distinction, sur un graphe fini ; la taxinomie (hyperonymie, instances) est
   précalculée et finie ; aucune négation par échec dans une preuve ; l'évaluation termine (graphe fini, requêtes de
   taille bornée) et son coût est celui d'un homomorphisme de graphes, exponentiel seulement dans la taille de la
   requête (une dizaine de variables au plus).

**Réutilisé.** `docs/ASSERTIONS.md`, FONDEMENTS v2 (§ 2, 4, 5), `assertions.pl` (admissibilité, validation).

**Sortie.** FONDEMENTS v3 validé par la propriétaire ; `ASSERTIONS.md` mis à jour (énonciateurs, quatre valeurs) ;
chaque terme a au moins une paire minimale qui le distingue de son voisin.

### C2 — Corriger les fondements logiques (P0, M0)

1. **Les disjonctions.** La disjonction des catégories (lexfiles) de WordNet est **retirée** : ce sont des
   regroupements lexicographiques, pas des axiomes (un centaure, une statue de saint, l'Agneau, la Mort personnifiée
   les traversent). Elle est remplacée par une **liste explicite et courte** d'axiomes de disjonction entre sens de
   WordNet, chacun motivé, valable **dans un même contexte et pour un même référent** (dans le figuré, un référent
   n'est pas à la fois une femme et un homme, sauf hybride dit ; le signifié peut tout). Un axiome qui produit une
   fausse contradiction est retiré, pas corrigé au cas par cas (D22).
2. **La coréférence.** La projection travaille sur les classes de coréférence du texte (reprises pronominales,
   appositions, « le saint »). Une coréférence a un degré : **établie** (apposition, nom repris) ou **possible**
   (pronom ambigu, description définie lointaine). Une preuve n'emploie que des coréférences établies ; une
   coréférence possible ne sert qu'aux hypothèses. Une fusion erronée est une erreur du lecteur, mesurée en C6.
3. **Identité et distinction**, quatre états explicites, jamais déduits d'une absence :

   | Relation | Signification | Source |
   |---|---|---|
   | `meme(X, Y)` | identité établie | coréférence établie ; variantes et mots clés d'un même nom dans Iconclass |
   | `distincts(X, Y)` | distinction établie | la requête la pose (deux participants nommés d'un libellé : « David and Goliath ») ; le texte la dit (« deux hommes ») |
   | `alias_possible(X, Y)` | identité possible | hypothèse (C9) |
   | aucune | inconnu | tout le reste |

   Le principe du nom unique est retiré : deux noms différents ne sont pas, par là, deux personnes (Saul et Paul ;
   Jérôme et Hieronymus) ; l'absence d'équivalence dans Iconclass ne prouve aucune distinction.
4. **Le monde fermé retiré** (FONDEMENTS § 4.4) :
   - **les exclusions** (« not in biblical context ») sont vraies si le texte donne un contexte **incompatible** avec
     le contexte exclu (une preuve positive), inconnues si le texte se tait ; un code dont l'exclusion est inconnue
     est candidat, pas établi ;
   - **« (other) »** : la classe résiduelle s'applique si la chose décrite est sous le parent **et** que chaque sœur
     nommée est fausse (pas inconnue) ; sinon, c'est le parent qui est établi, s'il l'est par implication ;
   - **la place propre l'emporte** reste, comme règle de choix entre deux codes vrais (11H(PETER) plutôt que
     61B2(PETER)), pas comme négation.

**Sortie.** FONDEMENTS v3 § « Contradictions et identités » ; chacun des quatre points a ses paires minimales.

### C3 — Compiler les définitions en requêtes, et qualifier la compilation (P0, M1)

**Le constat.** La définition actuelle est **conçue** pour être trop forte plutôt que trop faible (tout ce que le
libellé dit est exigé, sauf ce que la grammaire d'Iconclass marque comme facultatif), mais **le compilateur ne le
garantit pas** : le quatrième jugement à l'aveugle compte encore 22 définitions dangereuses sur 140 en anglais, 20 en
français (conjonctions, alternatives, locutions, parenthèses, contextes), sur des tirages différents d'un jugement à
l'autre. La suffisance est donc une **prétention** du compilateur, que seule la validation justifie.

1. **Une définition est une requête**, un graphe à variables, pas une liste de mots : des variables typées (X : woman,
   Y : child), leurs noms, leurs propriétés, les événements et leurs rôles (tenir(E), agent(E, X), patient(E, Y)), les
   relations orientées, les contraintes `meme` / `distincts`, le nombre ; une union de telles requêtes pour les
   alternatives. Ce que le libellé relie (« woman holding a child », « dead bird », « attributes of Cupid: bow »)
   l'est dans la requête ; ce qu'il ne relie pas ne l'est pas.
2. **Deux bornes** :
   - la condition **suffisante** Suff(N), la requête ci-dessus ;
   - la condition **nécessaire** Néc(N), faible : les têtes ou les noms, sans les détails ; si elle est fausse, le
     texte ne décrit pas N (une Annonciation demande Marie et l'ange ; nier l'ange l'écarte) ;
   - la décision : **établi** si Suff(N) a une substitution vraie et que sa suffisance est justifiée ; **écarté** si
     Néc(N) est fausse ; **candidat** si Néc(N) est vraie sans Suff(N) ; **abstention** sinon. Le principe « sûr
     d'abord » devient la propriété **visée** Suff(N) ⊨ N ⊨ Néc(N), dont la validation mesure la tenue ;
   - pour un épisode, une seconde condition suffisante candidate : le genre prochain et la différence spécifique
     (FONDEMENTS § 4.2), à mesurer avant d'établir quoi que ce soit.
3. **Les dimensions du statut**, indépendantes :

   | Dimension | Valeurs | Calcul |
   |---|---|---|
   | validité | valide, invalide | forme de la requête (variables typées, alternatives non vides) |
   | couverture | complète, partielle | chaque mot plein et chaque relation du libellé (hors parties facultatives) a sa variable ou sa relation dans la requête |
   | ambiguïté | univoque, ambiguë | une lecture du libellé (coordination, rattachement d'un complément) ou plusieurs ; un sens de mot déterminé ou non |
   | nature | exacte, conservatrice, convention | la requête dit le libellé ; elle est plus forte que lui (une parenthèse exigée par prudence) ; elle encode une convention documentaire d'Iconclass (« (other) », lettres doublées) |
   | suffisance | prétendue, justifiée | justifiée : la famille de constructions du libellé (type, forme syntaxique) a été jugée à l'aveugle et ne compte aucune définition trop faible dans l'échantillon, avec sa borne de confiance |

   Seule une définition valide, complète, univoque et dont la suffisance est justifiée établit (I3). Les autres donnent
   au mieux des candidats. La justification se fait **par famille de constructions**, pas définition par définition :
   c'est ce qui permet de passer de 200 définitions à 80 000.
4. **La provenance** : chaque variable, relation et contrainte cite la partie du libellé dont elle vient (rang,
   parenthèse, gabarit, héritage).

**Réutilisé.** `libelles_iconclass.pl` (grammaire), `definitions.pl` (lecture des unités, à transformer en requêtes),
`compilation.pl` (statut, sens), `interpretation.pl` (le graphe des scènes, déjà un graphe), `outils/definitions/`
(jugement à l'aveugle).

**Sortie.** Jugement à l'aveugle, par famille de constructions : aucune définition trop faible dans les familles
déclarées justifiées (borne supérieure de Wilson du taux de trop faibles ≤ 5 %) ; Néc(N) jamais plus forte que le
libellé dans ≥ 95 % ; couverture et ambiguïté calculées concordantes avec le juge dans ≥ 90 % ; la part des 80 000
définitions dont la suffisance est justifiée, comptée et publiée.

### C4 — La projection et le vérificateur de preuves (P0, M1)

**Le constat.** Le premier jet (`projection.pl`) évalue les groupes d'exigences séparément (une même variable peut y
tomber sur deux référents différents), tient pour « liés » des éléments proches dans le graphe (deux liens au plus
d'un même nœud) et ne vérifie que l'absence d'un rôle inversé, pas la présence du rôle attendu. Ce n'est pas une
projection. Ce premier jet sert de point de comparaison ; il est remplacé.

1. **La satisfaction d'une requête** : chercher une **substitution globale** σ des variables de Suff(N) par les
   référents (classes de coréférence) et les événements du texte, **commune à toutes les conditions**, telle que :
   - chaque variable a un type égal ou plus spécifique (sens choisis à la compilation, C3, C7) ou porte l'un des noms ;
   - chaque relation et chaque rôle exigés sont **présents positivement** entre les images des variables (tenir(E) avec
     agent(E, σX) et patient(E, σY) ; la proximité dans le graphe ne prouve rien) ;
   - les contraintes `meme` / `distincts` et le nombre sont respectés ;
   - chaque condition est vraie au sens de C1 (preuve positive admissible, aucune preuve négative pour σ).
2. **Le résultat** : pour une notation, l'ensemble des substitutions qui la satisfont (une même notation peut être
   portée par plusieurs référents) ; une substitution invalidée par une contradiction est écartée, pas la notation
   (C1.2) ; Néc(N) évaluée à part.
3. **Les correspondances partielles** (une partie des conditions, ou des conditions sans leurs relations) sont gardées
   séparément des preuves complètes : elles alimentent les candidats et les hypothèses, jamais un code établi. La
   proximité dans le graphe peut servir à **chercher** des candidats, jamais à en prouver un.
4. **La sortie** : établi, candidat, écarté, contradictoire, abstention ; pour chaque code, ses substitutions (les
   référents qui le portent) et sa preuve.
5. **La preuve** (I5) : versions des connaissances ; notation, statut de sa définition et provenance ; régime
   d'inférence ; substitution ; pour chaque condition, l'assertion qui la porte, son passage, son énonciateur, et le
   lien employé (égalité, hyperonymie et son chemin, nom et sa variante) ; les preuves négatives considérées.
6. **Le vérificateur**, en même temps que la projection et non après : un programme distinct, qui ne partage avec le
   moteur que le format de la preuve et la base de connaissances ; il relit la preuve et le graphe du texte, et
   contrôle chaque étape (chaque assertion citée existe et est admissible ; chaque lien existe dans la base ; la
   substitution satisfait chaque condition ; la définition a bien ce statut). Il certifie qu'une conclusion découle de
   ses prémisses, pas que le texte dit vrai.

**Réutilisé.** `assertions.pl`, `compilation.pl` (sens), le premier jet de `projection.pl` (index, sens du texte).

**Sortie.** Toutes les paires minimales de C1 et C2 passent ; la projection atteint les critères de M1 sur des graphes
et des définitions annotés (C6.2) ; le vérificateur accepte 100 % des preuves du moteur sur la validation et rejette
100 % des preuves altérées d'un banc de mutations (assertion retirée, rôle changé, lien inventé).

### C5 — Le moteur exhaustif de référence et le moteur indexé (P0, M1)

1. **Le domaine des notations**, fini et explicite : les notations compilées ; les gabarits à remplir instanciés par
   les noms et les types présents dans le texte (gabarits × noms du texte de type compatible) ; les clés combinées aux
   codes établis du texte (codes × clés de leur section) ; les lettres doublées de ces codes. Rien d'autre n'est
   « exhaustif ».
2. **Le moteur exhaustif** évalue toutes les notations de ce domaine sur chaque texte, sans index ni budget, dans le
   fragment de C1.9 (il termine). Lent par construction ; il ne sert qu'à la mesure.
3. **Le moteur indexé** n'évalue que les notations dont une requête peut avoir une substitution. Sa complétude se
   démontre **règle par règle**, relativement à la sémantique effective du moteur : pour chaque manière dont une
   condition peut être vraie (type égal ou plus spécifique ; nom, variante, alias établi ; genre de l'œuvre à toute
   portée qu'il admet ; propriété dérivée ; relation normalisée ; composition), l'index produit la clé correspondante.
   Toute nouvelle règle d'inférence (C7, C8) vient avec sa clé d'index. Exemple d'écart déjà relevé dans le premier
   jet : la condition de genre accepte une entité à toute portée, que le générateur de candidats ne retient pas.
4. **La comparaison automatisée** des deux moteurs (I4) sur le développement et la validation, à chaque modification.
5. **Le temps** : protocole écrit (matériel, chargement à froid séparé de l'exécution à chaud, nombre de processus) ;
   latence médiane et p95, débit ; cible de conception : 5 s par texte de 300 mots à chaud, analyse comprise.

**Sortie.** L'argument de complétude écrit ; I4 vrai sur le développement et la validation ; les temps mesurés.

### C6 — Le protocole expérimental et l'évaluation par composant (P0, dès M0)

1. **Les ensembles** (définitions tirées par strates : objets, vêtements et anatomie, personnes, actions et
   relations, scènes narratives, genres et allégories, attributs, clés et gabarits) :

   | Ensemble | Contenu | Usage |
   |---|---|---|
   | développement | 200 définitions (tirage du 24/11, graine 20261129), textes écrits à partir des libellés | mise au point des règles générales |
   | validation M1 | 200 définitions nouvelles, textes écrits sans voir le libellé | choix de l'architecture et des ressources du noyau |
   | validation M2 | 200 autres, mêmes règles, plus des descriptions d'Opus et des notices réelles | derniers ajustements, contrôle de généralisation |
   | qualification finale | 200 définitions et leurs textes, plus le banc scellé de 150 textes réels (notices, cartels, descriptions) | **une seule mesure**, sur la version figée (M3) |

   Les erreurs de la validation se lisent ; on ne corrige que par familles de ≥ 3 cas qui existent aussi en
   développement. La qualification finale n'est lue par personne avant M3.
2. **L'évaluation par composant**, pour qu'une erreur soit attribuée à la pièce qui la commet :
   - **graphes de référence** : pour les textes du développement et de la validation M1, le graphe d'assertions
     annoté (entités, propriétés, rôles, relations orientées, coréférences, négations, modalités, contexte de l'œuvre) ;
   - **définitions de référence** : pour leurs 200 + 200 notations, la requête annotée ;
   - les mesures : le **lecteur** (graphe extrait contre graphe annoté, par catégorie d'élément : un rappel des mots ne
     dit pas qu'Hercule étrangle le lion, le rappel des rôles et des relations orientées le dit) ; le **compilateur**
     (requête compilée contre requête annotée) ; le **moteur logique** (projection des requêtes annotées sur les
     graphes annotés : il doit être juste sans aucune erreur de langue) ; puis la chaîne entière ;
   - l'annotation de référence est faite par des agents rédacteurs distincts de ceux des textes, et un échantillon de
     chaque lot est relu par la propriétaire (D23).
3. **Les textes** de la validation et de la qualification ne paraphrasent pas les libellés : un rédacteur décrit la
   scène sans voir le libellé, d'après la description d'un second rédacteur, avec la consigne de varier le lexique et
   la syntaxe ; la validation M2 et la qualification finale ajoutent des descriptions et des notices réelles.
4. **Les variantes systématiques** des définitions à relations (scènes, classes à complément, attributs) :

   | Variante | Attendu |
   |---|---|
   | la scène dite simplement (« une femme tient un enfant ») | établi |
   | une paraphrase (« une mère berce son nourrisson dans ses bras ») | établi si la normalisation le permet ; sinon rappel manqué, compté |
   | rôles inversés (« un enfant tient la main d'une femme ») | non établi |
   | autre relation (« une femme regarde un enfant ») | non établi |
   | modalité (« une femme pourrait porter un enfant ») | candidat (hypothèse) |
   | négation (« une femme ne porte aucun enfant ») | écarté pour cette figure |
   | coprésence seule (« une femme et un enfant sont visibles ») | non établi |
   | hors de l'image (« le peintre eut une femme et un enfant ») | rien |
   | deux scènes (« un lion attaque un homme ; plus loin, l'homme terrasse le lion ») | établi pour la seconde |
   | contradiction de sources | contradictoire, deux sources citées |

5. **Les faux positifs parmi toutes les notations** : chaque texte est jugé sur **tous** ses codes établis, pas
   seulement sur la notation visée.
6. **Les tests métamorphiques** (I2, I8) et le **test de redondance** (accord de l'audit du 24/11) sur chaque
   ensemble.

**Sortie.** Les ensembles de validation M1 et de qualification finale constitués et scellés, et les graphes et
définitions de référence du développement annotés, avant la fin de C4.

### C7 — La couche sémantique (P1, M2)

Trois problèmes distincts, mesurés à part :
1. **Le lexique bilingue** (WOLF) : couverture et justesse des paires mot français / sens ; les mots français absents
   (42 % des mots distincts des définitions) relevés par famille.
2. **La désambiguïsation** : les sens des mots des définitions (bilingue, hiérarchie, unique, aucun) jugés sur un
   tirage ; les sens des mots du texte (aujourd'hui le sens dominant en anglais, tous les sens de WOLF en français)
   choisis par le contexte quand la mesure montre des erreurs (le sens d'un verbe selon son objet : porter un manteau,
   un enfant, un regard).
3. **La normalisation des événements et des relations** : actif / passif (le lecteur), verbe / nom (« the
   crucifixion » / « crucified » : liens morphosémantiques, D17), paraphrases verbales (VerbNet, FrameNet, si une
   famille d'erreurs mesurée le demande). Chaque normalisation est une règle d'inférence, avec sa clé d'index (C5.3).

**L'interface des ressources.** Un schéma unique de faits que le noyau lit sans connaître la ressource :
`concept(Id, Source)`, `lexicalisation(Id, Langue, Libelle)`, `sous_classe(Id, Parent, Source)`,
`relation_semantique(Id1, Relation, Id2, Source)`. WordNet, les liens morphosémantiques et WOLF y passent d'abord ;
AAT (vêtements, objets), Wikidata (alias de personnes), VerbNet, FrameNet s'y ajouteront quand une famille d'erreurs
mesurée les demande (tableau erreur → ressource dans `DECISIONS.md`).

**Sortie.** Pour chaque ressource ajoutée : son gain mesuré sur la validation M2, aucune perte de précision, I4 vrai.

### C8 — Les mécanismes d'Iconclass (P1, M2)

1. **Les gabarits à remplir** (« 25F23(...) », « 11H(...) ») : la notation construite à partir d'un nom ou d'un type
   du texte (T5 du cahier), validée par le type du gabarit.
2. **Les clés** (« (+…) ») : une propriété du même référent (T4).
3. **Les lettres doublées** (« AA », « FF ») : le trait déclencheur de la section (féminin, fabuleux, opposé) exigé,
   sinon le jumeau simple (T10).
4. **L'héritage typé** (FONDEMENTS § 3.4) : la personne du récit, le contexte d'un épisode, vérifiés sur les
   divisions 7, 9 et 11 ; les liens d'implication de la hiérarchie (I11) relevés par type de lien.
5. **Les compositions** : une notation et ses parties (« ~ » et gabarits), les renvois.

**Sortie.** Chaque mécanisme a sa strate dans les ensembles de C6 et y atteint les critères de M2.

### C9 — L'abduction iconographique (P1, M2)

**But.** Tirer d'Iconclass des connaissances qui ne sont pas des définitions, et les faire servir à des
**hypothèses**, jamais à des preuves.

- Connaissances compilées (aucune écrite à la main, I10) : `alias_d_identite` (noms, variantes, mots clés),
  `attribut_possible` (« possible attributes: … »), `participant_du_recit`, `convention` (lettres doublées,
  « (other) »), `regle_de_classement` (gabarits, clés).
- Une hypothèse est une **explication** des observations : ce qu'elle explique (quelles observations, rattachées à
  quel référent : le lion et le crucifix **auprès du** vieillard, pas seulement présents), ce qu'elle laisse
  inexpliqué, les hypothèses avec lesquelles elle est incompatible, et l'observation qui les départagerait.
- En V1, l'abduction produit des **candidats avec ces quatre rubriques** ; elle n'établit rien. La certification de
  T7 (identité par attributs) et T8 (épisode) vient version après version (cahier § 7.2).

**Sortie.** Sur la validation M2, le rappel des hypothèses d'identité et d'épisode mesuré (rappel@5), sans effet sur
la précision des codes établis.

### C10 — Qualifier et livrer la V1 (P1, M3)

1. **Les mesures**, sur ce que le texte soutient (jugement à la main), l'unité étant le couple (notation, référent) :

   | Mesure | Ce qu'elle évalue |
   |---|---|
   | précision exacte | justesse des codes établis |
   | rappel exact | codes pertinents retrouvés |
   | rappel hiérarchique | un ancêtre juste compte pour partie (H-F1) |
   | couverture des référents | part des objets et personnages du texte qui reçoivent au moins une notation juste |
   | couverture relationnelle | part des actions et relations du texte indexées |
   | taux d'abstention | part de ce que le texte dit que le moteur ne sait pas traiter, par cause |
   | justesse des preuves | preuves jugées valides (et acceptées par le vérificateur) |
   | rappel des hypothèses | sujets plausibles proposés (rappel@5) |

   Les intervalles de confiance tiennent compte du regroupement par document (rééchantillonnage par document) : les
   codes d'un même texte ne sont pas indépendants. Une précision obtenue par abstention massive ne qualifie pas : la
   couverture des référents et le taux d'abstention sont des critères, pas des commentaires.
2. **Les cibles par catégorie** (D21, fixées par la propriétaire après M1) ; proposition de départ :

   | Catégorie | Précision | Rappel |
   |---|---|---|
   | objets explicitement décrits | 0,95 | 0,85 |
   | animaux et plantes | 0,95 | 0,85 |
   | vêtements et anatomie | 0,90 | 0,80 |
   | propriétés et postures (clés) | 0,90 | 0,80 |
   | relations explicites | 0,90 | 0,70 |
   | identités explicitement désignées | 0,90 | 0,80 |
   | épisodes explicitement nommés | 0,90 | 0,75 |
   | épisodes déduits | 0,85 | à mesurer |
   | allégories non explicites | à mesurer | à mesurer |

   Le critère de réception du cahier reste : précision de l'ensemble des codes établis ≥ 0,95.
3. **La ligne de base** : BM25 sur les libellés (version 0.2), mêmes textes, mêmes jugements.
4. **La livraison opérationnelle** :

   | Fonction | Exigence |
   |---|---|
   | interface | contrat JSON versionné (entrée, sortie, preuve), schéma publié, compatibilité déclarée |
   | lots | JSONL en entrée et en sortie, reprise après interruption |
   | isolation | aucun état partagé entre deux documents ; test de contamination |
   | erreurs | erreurs structurées (code, message, document) ; un document en erreur n'arrête pas le lot |
   | limites | délai par document ; un résultat incomplet est signalé comme tel, jamais présenté comme complet |
   | performance | latence médiane et p95, débit, mémoire et CPU, sur un matériel documenté |
   | concurrence | plusieurs processus en parallèle, mêmes sorties qu'en série (I9) |
   | installation | construction reproductible hors ligne (ressources, modèles, base compilée, empreintes) |
   | versions | moteur, base, analyseur et modèles, règles, connaissances, dans chaque sortie |
   | appel | CLI et bibliothèque Python ; l'adaptateur des sorties d'Opus |

**Sortie (M3 = V1).** Sur la qualification finale, mesurée une seule fois sur la version figée : précision des codes
établis ≥ 0,95 (borne inférieure ≥ 0,90, rééchantillonnage par document), cibles de D21, tous les invariants vrais,
les exigences de livraison satisfaites.

---

## 4. Les critères des jalons

**M0 — spécification** : FONDEMENTS v3 (C1, C2) validé ; le fragment logique, le format des requêtes, de la preuve et
de la sortie JSON écrits ; les paires minimales écrites (pas encore passées).

**M1 — noyau logique**, sur la validation M1 :
- moteur logique sur graphes et requêtes annotés : précision ≥ 0,98, rappel ≥ 0,90 (la logique seule, sans langue) ;
- chaîne entière : précision des codes établis ≥ 0,95 (tous codes, notation visée ou non) ;
- positifs : la notation visée établie (pour au moins un de ses référents) dans au moins 50 % des cas, **premier seuil
  de prototype, pas l'ambition de la V1** (relevé à D21) ;
- négatifs et indéterminés : la notation visée établie dans ≤ 5 % des cas ;
- variantes de C6.4 : chaque ligne à son attendu dans ≥ 90 % des cas ;
- vérificateur : C4.6 ; complétude de l'index : C5 ; invariants I1 à I11 vrais ;
- comparaison avec la ligne de base BM25.

**M2 — couverture fonctionnelle**, sur la validation M2 : les critères de M1, plus les cibles provisoires de D21 par
catégorie, sur textes libres FR/EN, descriptions d'Opus et notices réelles.

**M3 — V1 qualifiée** : § C10.

---

## 5. Ce qui est réutilisé, ce qui change

| Composant | Réutilisé | Change |
|---|---|---|
| `udpipe.pl`, `conllu.pl`, `stanza_textes.py` | tel quel | Stanza par défaut pour les textes après M1 (D20 bis) |
| `interpretation.pl`, `mondes.pl`, `scene.pl` | lecteur et ancrage | coréférence complétée (C2.2), énonciateurs (C1.1), nombre (C1.6) |
| `assertions.pl`, `docs/ASSERTIONS.md` | langage et validation | quatre valeurs, énonciateurs, contextes |
| `libelles_iconclass.pl`, `definitions.pl` | grammaire des libellés, lecture des unités | définitions compilées en requêtes (variables, relations, contraintes), Néc, provenance |
| `compilation.pl` | statut, sens | dimensions du statut (C3.2) |
| `projection.pl` | index, sens du texte ; le reste comme point de comparaison | satisfaction de requêtes à substitution globale, quatre valeurs, coréférence, quantification ; vérificateur distinct |
| `raisonnement.pl`, `sens.pl` | normalisation des noms | le reste est remplacé par la projection |
| `sujets.pl`, `hypotheses.pl` | rien (méthode des profils abandonnée) | historique |
| `compiler_*.py` | tels quels | interface des ressources (C7) |
| `outils/definitions/`, `outils/mesure/`, `outils/vertical/` | tirages, jugements, bancs | ensembles de validation et de qualification, variantes |
| version 0.2 | ligne de base BM25 | aucune |

---


## 6. Les règles de travail (inchangées)

- Une correction est une règle générale justifiée par une famille d'au moins trois cas, et elle passe par ces
  principes ; si une famille d'erreurs ne peut pas se corriger sans les contredire, c'est le principe qu'on
  réexamine, par écrit, avant de coder (`docs/PLAN_F3.md`, § 4).
- Les jugements sont faits à l'aveugle ; les ensembles scellés ne sont lus qu'au jalon qui leur revient.
- Aucune donnée (textes, libellés, jugements, base compilée) dans le dépôt.
- Ce plan validé, l'expérimentation arbitre : une décision de conception ne se rouvre que sur une famille d'erreurs
  mesurée.

## 7. Décisions demandées à la propriétaire

- **D21** : les cibles de précision et de rappel par catégorie (C10.2), après la mesure de M1.
- **D22** : la liste des axiomes de disjonction (C2.1), relue avant d'entrer dans le moteur.
- **D23** : l'annotation des graphes et des requêtes de référence et la rédaction des textes de validation par des
  agents distincts, avec relecture d'un échantillon par la propriétaire (C6.2, C6.3) ; ou une autre source.
- **D24** : les titres. D15 reste la règle du moteur (un titre ne prouve pas ce que l'image montre). Proposition à
  trancher : un mode « documentation complète » qui donnerait, **à part des codes établis**, les désignations que seul
  le titre fournit, avec le statut « désigné par le titre » (une désignation documentaire, jamais une figuration). Je
  recommande de le garder hors de la V1 si l'usage visé est l'indexation de ce que l'image montre.

## 8. La relecture critique du 25/11 et ce qu'elle a changé

| Point | Intégré | Où |
|---|---|---|
| 1. La suffisance prétendue n'est pas la suffisance justifiée | oui : le compilateur ne garantit pas « jamais trop faible » ; dimension « suffisance », justifiée par famille de constructions | C3, I3 |
| 2. Une vraie projection structurelle | oui : requêtes à variables, substitution globale, relations vérifiées positivement ; la proximité ne sert qu'à chercher | C3.1, C4 |
| 3. La hiérarchie n'est pas une subsomption | oui : implication, ascendance documentaire, réduction de redondance | I11 |
| 4. La composition des quatre valeurs ; un rôle inversé invalide une substitution | oui | C1.2, C4.2 |
| 5. Aucune distinction tirée d'une absence d'alias ; coréférences incertaines | oui : quatre états, coréférence établie / possible ; nom unique retiré | C2.2, C2.3 |
| 6. L'évaluation séparée du lecteur, du compilateur et du moteur logique | oui : graphes et requêtes annotés | C6.2, M1 |
| 7. Fragment logique, terminaison, domaine fini, complétude de l'index | oui ; l'écart de portée de la condition de genre est relevé | C1.9, C5 |
| 8. Pas le même ensemble scellé pour M1 et M2 ; des textes réels | oui : validation M1, validation M2, qualification finale unique | C6.1 |
| 9. Couples (notation, référent), rappel hiérarchique, abstention | oui | but, C10.1 |
| 10. Le vérificateur en P0 | oui, avec C4 | C4.6 |
| 11. Les titres | proposé comme décision, D15 maintenu par défaut | D24 |
| 12. La monotonie restreinte aux faits sans rapport | oui | I8 |
| 13. Les exigences de livraison | oui | C10.4 |
| 14. Quatre jalons | oui : M0 à M3 | § 1, § 4 |
