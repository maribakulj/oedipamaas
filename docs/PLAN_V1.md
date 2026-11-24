# Plan technique de la V1 (25 novembre 2026)

Ce plan consolide les fondements v2 (`docs/FONDEMENTS.md`), les décisions D15 à D20 (`DECISIONS.md`), les quatre
propositions validées le 24/11 (statut de compilation, prototype vertical, projection, WOLF) et la seconde lecture
critique du même jour. Il dit, pour chaque chantier, ce qui est réutilisé, ce qui change, les invariants formels et
les critères de sortie. Aucun développement ne précède la validation de ce plan par la propriétaire.

**Le but de la V1.** Un moteur qui tire d'un texte libre (description visuelle d'Opus, cartel, notice, catalogue,
texte savant ; français et anglais) **toutes** les notations d'Iconclass que le texte justifie, chacune avec sa
preuve, et non seulement le sujet principal : vingt objets décrits doivent donner vingt codes. Hors ligne, sans LLM
(D20 : petits modèles locaux permis), précision d'abord.

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
| Ressources | WordNet 3.0, liens morphosémantiques (17 739), WOLF (102 671 paires ; 58 % des mots français des définitions, 86 % de leurs occurrences) | |

### 0.1 Le prototype vertical, premier passage (non corrigé)

Voir `docs/mesures/V2.md`, § « Prototype vertical » : 200 définitions, un texte positif, un négatif et un indéterminé
chacune, écrits à partir des libellés (donc un ensemble de **développement**, pas de validation). Les chiffres sont
l'état initial ; ils ne qualifient rien.

---

## 1. Les dix chantiers et leurs dépendances

```
 C1 sémantique formelle ──► C2 corrections logiques ──┬──► C3 qualification de la compilation ──┐
                                                      └──► C4 projection à quatre valeurs ──────┼──► C5 moteur exhaustif ──► M1
 C6 protocole expérimental (dès maintenant, en parallèle) ─────────────────────────────────────┘
 M1 ──► C7 couche sémantique ──┐
 M1 ──► C8 mécanismes d'Iconclass ──┼──► C9 abduction ──► C10 qualification et livraison (M2 = V1)
```

- **P0** (jalon M1, « le noyau est juste ») : C1 à C6.
- **P1** (jalon M2, « la V1 ») : C7 à C10.
- Un chantier P1 ne commence qu'après M1 : les mesures de M1 décident de ce que C7 et C8 doivent traiter d'abord
  (une ressource s'intègre quand une famille d'erreurs mesurée la demande, D17).

---

## 2. Les invariants formels

Ils valent pour tout le moteur. Chacun a son test, qui s'exécute à chaque modification (`tests/`) ; une modification
qui en casse un est refusée, quel que soit le gain de mesure.

| | Invariant | Test |
|---|---|---|
| I1 | **Pas de négation par échec.** Une exigence n'est fausse que par une assertion niée explicite, ou par un axiome de disjonction explicite (C2) appliqué à une preuve positive du même contexte. L'échec d'une preuve donne « inconnu ». | test de code : aucun `\+` de la projection ne produit « faux » ; paires « silence / négation » |
| I2 | **Un titre n'est jamais une preuve** (D15). | métamorphique : déplacer une phrase dans le titre fait passer un code d'établi à candidat |
| I3 | **Établi ⇒ condition suffisante vraie**, définition « compilée », aucune exigence contradictoire. | vérificateur de preuves (C10) |
| I4 | **L'index ne perd rien** : les résultats du moteur indexé sont ceux du moteur exhaustif (C5). | comparaison sur tout le banc de développement et de validation |
| I5 | **Une preuve se rejoue** : chaque exigence satisfaite cite son unité, l'assertion qui la porte et le passage du texte ; un vérificateur indépendant la revalide sans le moteur. | vérificateur de preuves |
| I6 | **Contextes séparés** : deux preuves de contextes différents (deux œuvres, le figuré et le monde réel, deux énonciateurs en désaccord) ne se combinent jamais en une seule preuve. | paires minimales |
| I7 | **Identité et distinction explicites** : deux unités d'une définition vont sur des référents distincts seulement si la définition le dit, sur le même seulement si elle le dit ; sinon les deux sont permis. La distinction se juge sur les **classes de coréférence** du texte, pas sur les identifiants. | paires : « Jérôme… le saint » ; « David et Goliath » |
| I8 | **Monotonie relative** : ajouter au texte une phrase sans rapport ne retire aucun code établi ; seule une preuve négative ou contradictoire peut en retirer un. | métamorphique : ajout de phrases neutres |
| I9 | **Reproductibilité** : mêmes versions (moteur, base, analyseur, règles) ⇒ même sortie, à l'octet. | double exécution |
| I10 | **Ce qui est écrit à la main** : des règles de langue et la grammaire des libellés d'Iconclass, plus les axiomes de disjonction de C2, chacun motivé par écrit ; jamais une connaissance iconographique (quel saint porte quelles clés). | revue : liste fermée des fichiers concernés |
| I11 | **Les ancêtres sont impliqués** : un code établi affirme ses ancêtres ; la sortie ne donne que le plus précis d'une branche. | test de code |

---

## 3. Les chantiers

### C1 — Formaliser la sémantique (P0)

**But.** Un texte de référence, FONDEMENTS v3, qui donne la signification exacte de chaque terme du langage
d'assertions et de chaque opération du moteur, avant toute modification du code.

**Contenu.**
1. **Les propositions et leurs preuves.** Une exigence p d'une définition a, dans un document, un ensemble de preuves
   positives Pos(p) et négatives Neg(p), chacune avec son assertion, son passage, son énonciateur et son contexte. La
   valeur de p suit la logique à quatre valeurs de Belnap, dans l'ordre de l'information :

   | Pos(p) | Neg(p) | valeur |
   |---|---|---|
   | ∅ | ∅ | inconnu |
   | ≠ ∅ | ∅ | vrai |
   | ∅ | ≠ ∅ | faux |
   | ≠ ∅ | ≠ ∅ | contradictoire |

   On ne construit pas de logique paraconsistante générale : les preuves sont gardées séparément et la valeur se lit à
   la fin. Une contradiction entre deux énonciateurs (« la notice identifie saint Pierre ; une étude récente le
   conteste ») est une sortie à part entière, qui dit les deux sources.
2. **Les contextes** (FONDEMENTS § 2) : l'œuvre ⊃ le figuré ⊃ le signifié ; le monde réel ; les autres œuvres. Ce
   qu'une preuve de chaque contexte peut fonder (la figuration demande le figuré ; le classement, l'œuvre ; la
   désignation, le figuré ou le signifié).
3. **La modalité** : « affirmé » fonde une preuve ; « probable », « possible », « traditionnel » fondent une
   hypothèse (C9), jamais une preuve ; « ancien » (autrefois attribué) et « non affirmé » ne fondent rien.
4. **La négation** : sa portée (« sans ailes » nie la partie, pas l'ange) ; l'inversion de l'ordre des types sous la
   négation ; la différence entre « ne pas pouvoir démontrer » (inconnu) et « le texte nie » (faux).
5. **Les alternatives** : « X ou Y » du texte, hypothèses exclusives ; aucune des deux n'établit, leur disjonction
   peut établir l'ancêtre commun.
6. **La quantification** : le nombre (« trois anges », « deux mains »), l'universel des définitions (« a woman
   holding a child » : il existe une femme et un enfant, liés par tenir), les pluriels.
7. **Les trois relations de preuve** (figuration, désignation, classement de l'œuvre) et, nouveau, les **régimes
   d'inférence** : généralisation taxonomique (un code affirme ses ancêtres), composition des notations (gabarits,
   clés, lettres doublées), abduction (C9). Pour chacun : ce qu'il peut établir et ce qu'il ne peut que suggérer.

**Réutilisé.** `docs/ASSERTIONS.md` (le langage), FONDEMENTS v2 (§ 2, 4, 5), `assertions.pl` (admissibilité,
validation).

**Sortie.** FONDEMENTS v3 validé par la propriétaire ; `ASSERTIONS.md` mis à jour (énonciateurs, quatre valeurs) ;
chaque terme a au moins une paire minimale qui le distingue de son voisin.

### C2 — Corriger les fondements logiques (P0)

**But.** Retirer de FONDEMENTS v2 les règles qui produisent des contradictions ou des conclusions artificielles.

1. **Les disjonctions.** La disjonction des catégories (lexfiles) de WordNet est **retirée** : ce sont des
   regroupements lexicographiques, pas des axiomes (un centaure, une statue de saint, l'Agneau, la Mort personnifiée
   les traversent). Elle est remplacée par une **liste explicite et courte** d'axiomes de disjonction entre sens de
   WordNet, chacun motivé, valable **dans un même contexte et pour un même référent** (le figuré : un référent n'est
   pas à la fois une femme et un homme, sauf hybride dit ; le signifié peut tout). Un axiome qui produit une fausse
   contradiction sur le banc est retiré, pas corrigé au cas par cas.
2. **La coréférence.** La projection travaille sur les classes de coréférence du texte (`coref/2`, reprises
   pronominales, appositions, « le saint »). Un nom donné à un membre de la classe l'est à toute la classe.
3. **Identité et distinction** (I7) : explicites dans la définition (`meme(R1, R2)`, `distincts(R1, R2)`). Deux noms
   propres différents d'un même libellé désignent deux individus (« David and Goliath ») ; cette règle de
   distinction n'est pas étendue aux noms communs (« a man looking at himself »).
4. **Le nom unique** n'est plus une règle de contradiction générale : deux noms d'un même individu (Saul, Paul ;
   Jérôme, Hieronymus) sont des variantes que donne Iconclass (noms de la notation, variantes, mots clés des deux
   langues). Deux noms sont contradictoires seulement si Iconclass les donne à deux notations différentes **et**
   qu'aucune ne donne l'autre en variante.
5. **Le monde fermé retiré** (FONDEMENTS § 4.4) :
   - **les exclusions** (« not in biblical context ») sont vraies si le texte donne un contexte **incompatible** avec
     le contexte exclu (une preuve positive), inconnues si le texte se tait ; un code dont l'exclusion est inconnue
     est candidat, pas établi ;
   - **« (other) »** : la classe résiduelle s'applique si la chose décrite est sous le parent **et** que chaque sœur
     nommée est fausse (pas inconnue) ; sinon, c'est le parent qui est établi ;
   - **la place propre l'emporte** reste, mais comme règle de choix entre deux codes vrais (11H(PETER) plutôt que
     61B2(PETER)), pas comme négation.

**Sortie.** FONDEMENTS v3 § « Contradictions » ; chacun des cinq points a ses paires minimales, et le prototype
vertical ne montre plus aucune contradiction qui ne soit pas dans le texte.

### C3 — Qualifier la compilation (P0)

**But.** Que chaque définition dise ce qu'elle garantit.

1. **Les bornes sémantiques.** Chaque notation reçoit deux conditions :
   - une **condition suffisante** Suff(N) : si elle est vraie, le texte décrit N. C'est la définition actuelle (tout
     ce que le libellé exige, sauf ce que la grammaire d'Iconclass marque comme facultatif), qui peut être trop forte
     (un code manqué), jamais trop faible ; pour un épisode, aussi le genre prochain et la différence spécifique
     (FONDEMENTS § 4.2), qui peuvent suffire sans tout le libellé, à mesurer ;
   - une **condition nécessaire** Néc(N) : si elle est fausse, le texte ne décrit pas N. Elle est faible : la tête ou
     le nom, sans les détails (une Annonciation demande Marie et l'ange ; nier l'ange l'écarte).
   - La décision : **établi** si Suff(N) est vraie ; **écarté** si Néc(N) est fausse ; **candidat** si Néc(N) est
     vraie sans Suff(N) ; **abstention** sinon. Le principe « sûr d'abord » devient l'énoncé : Suff(N) ⊨ N ⊨ Néc(N).
2. **Les dimensions du statut**, indépendantes :

   | Dimension | Valeurs | Calcul |
   |---|---|---|
   | validité | valide, invalide | forme de la définition (alternatives non vides, unités connues) |
   | couverture | complète, partielle | chaque mot plein et chaque relation du libellé (hors parties facultatives) a son unité et sa structure (rôle, lien, porteur) |
   | ambiguïté | univoque, ambiguë | une lecture du libellé (coordination, rattachement d'un complément) ou plusieurs ; un sens de mot déterminé ou non |
   | nature | exacte, conservatrice, convention | la définition dit le libellé ; elle est plus forte que lui (une parenthèse exigée par prudence) ; elle encode une convention documentaire d'Iconclass (« (other) », lettres doublées) |
   | validation | non évaluée, testée, jugée | testée : au moins un positif et un négatif passent ; jugée : un juge à l'aveugle l'a tenue pour juste |

   Seule une définition valide, complète et univoque établit. Une définition conservatrice établit (elle est sûre) ;
   ce statut dit qu'elle manquera des cas.
3. **La provenance** : chaque unité cite la partie du libellé dont elle vient (rang, parenthèse, gabarit, héritage).

**Réutilisé.** `definitions.pl`, `compilation.pl`, `libelles_iconclass.pl`, `outils/definitions/` (jugement à
l'aveugle).

**Sortie.** Jugement à l'aveugle de 140 définitions par type (en, fr) sur les deux bornes : Suff(N) jamais plus faible
que le libellé dans ≥ 95 % des cas jugés ; Néc(N) jamais plus forte que lui dans ≥ 95 % ; la couverture et l'ambiguïté
calculées concordent avec le juge dans ≥ 90 %.

### C4 — La projection à quatre valeurs (P0)

**But.** Évaluer Suff(N) et Néc(N) sur le graphe d'un texte.

1. Une unité se projette sur un **élément admissible** : `mot` par le sens (égal ou plus spécifique, sens choisis à la
   compilation), `nom` par les noms d'une classe de coréférence, `genre` sur l'œuvre.
2. **La structure** : les éléments d'une alternative sont liés dans le graphe du texte (rôles d'un même événement,
   relations, porteur d'une propriété, partie, coréférence ; borne de distance écrite et justifiée) ; les rôles de la
   définition et du texte se comparent (rôle inversé : faux) ; les relations orientées (« a child holding a woman's
   hand » n'est pas « a woman holding a child »).
3. **La quantification** (C1.6) : le nombre exigé (« three », « deux ») contre le nombre dit ou compté.
4. **Les quatre valeurs** par exigence (C1.1), les preuves positives et négatives gardées séparément, avec leurs
   énonciateurs.
5. **La sortie** : établi, candidat, écarté, contradictoire, chacun avec sa preuve (unité → assertion → passage) et,
   pour un candidat, ce qui manque.

**Réutilisé.** `projection.pl` (premier jet), `assertions.pl`, `compilation.pl` (sens).

**Sortie.** Toutes les paires minimales de C1 et C2 passent ; le prototype vertical de développement atteint les
critères de M1 (§ 4).

### C5 — Le moteur exhaustif de référence (P0)

**But.** Un oracle pour la recherche des définitions à projeter.

- **Le moteur exhaustif** projette **toutes** les définitions prises en charge sur chaque texte, sans index ni budget.
  Lent par construction ; il ne sert qu'à la mesure.
- **Le moteur indexé** ne projette que les définitions dont une unité peut être portée par un élément du texte (index
  des mots, de leurs hyperonymes, des noms, des genres). L'index est complet par construction si chaque unité d'une
  définition y figure ; I4 le vérifie : sur tous les textes des bancs, les deux moteurs donnent les mêmes résultats.
- Les gabarits à remplir (« (...) »), les clés (« (+…) ») et les notations construites (C8) passent par le même
  contrôle.

**Sortie.** I4 vrai sur le développement et la validation ; temps du moteur indexé mesuré (cible : moins de 5 s par
texte de 300 mots, analyse comprise).

### C6 — Le protocole expérimental (P0, dès maintenant)

1. **Trois ensembles de définitions**, tirés par strates (objets, vêtements et anatomie, personnes, actions et
   relations, scènes narratives, genres et allégories, attributs ; plus, nouveau, clés et gabarits) :

   | Ensemble | Taille | Usage |
   |---|---|---|
   | développement | 200 (tiré le 24/11, graine 20261129) | mise au point des règles générales |
   | validation | 200, sans recouvrement | mesure de la généralisation ; on lit les erreurs, on ne corrige que par familles de ≥ 3 cas qui existent aussi en développement |
   | qualification | 200, scellé | une seule mesure, à M1 puis à M2 ; jamais lu pendant le développement |

2. **Des textes qui ne paraphrasent pas les libellés.** Les textes du développement sont écrits à partir des libellés
   (risque de reprise de leurs mots). Ceux de la validation et de la qualification sont écrits par un rédacteur qui ne
   voit pas le libellé mais une description de la scène par un second rédacteur, avec la consigne de varier lexique
   et syntaxe.
3. **Les variantes systématiques** pour les définitions à relations (scènes, classes à complément, attributs) :

   | Variante | Attendu |
   |---|---|
   | la scène dite simplement (« une femme tient un enfant ») | établi |
   | une paraphrase (« une mère berce son nourrisson dans ses bras ») | établi si la normalisation le permet ; sinon mesuré comme rappel manqué |
   | rôles inversés (« un enfant tient la main d'une femme ») | non établi |
   | autre relation (« une femme regarde un enfant ») | non établi |
   | modalité (« une femme pourrait porter un enfant ») | candidat (hypothèse) |
   | négation (« une femme ne porte aucun enfant ») | écarté pour cette figure |
   | coprésence seule (« une femme et un enfant sont visibles ») | non établi |
   | hors de l'image (« le peintre eut une femme et un enfant ») | rien |
   | contradiction de sources | contradictoire, deux sources citées |

4. **Les faux positifs parmi toutes les notations.** Chaque texte est jugé sur **tous** les codes établis, pas
   seulement sur la notation visée : un code établi autre que la notation visée et ses ancêtres est jugé à la main
   (juste : le texte le décrit aussi ; faux : erreur du moteur).
5. **Les mesures par catégorie** (C10.2) dès M1.
6. **Les bancs de textes réels** restent : banc de développement (30 textes, sous-référence autorisée D19) et banc
   scellé (150 textes), pour la qualification M2.

**Sortie.** Les ensembles de validation et de qualification constitués et scellés avant que C4 ne soit terminé.

### C7 — La couche sémantique (P1)

Trois problèmes distincts, mesurés à part :
1. **Le lexique bilingue** (WOLF) : couverture et justesse des paires mot français / sens, mesurées sur le
   développement ; les mots français absents de WOLF (42 % des mots distincts des définitions) relevés par famille.
2. **La désambiguïsation** : les sens des mots des définitions (bilingue, hiérarchie, unique, aucun) jugés sur un
   tirage ; les sens des mots du texte (aujourd'hui le sens dominant en anglais, tous les sens de WOLF en français)
   choisis par le contexte du texte quand la mesure montre des erreurs (sens d'un verbe selon son objet : porter un
   manteau, un enfant, un regard).
3. **La normalisation des événements et des relations** : actif / passif (le lecteur), verbe / nom (« the
   crucifixion » / « crucified » : liens morphosémantiques, D17), paraphrases verbales (VerbNet, FrameNet, si une
   famille d'erreurs mesurée le demande).

**L'interface des ressources.** Un schéma unique de faits pour toute ressource externe, que le noyau lit sans la
connaître : `concept(Id, Source)`, `lexicalisation(Id, Langue, Libelle)`, `sous_classe(Id, Parent, Source)`,
`relation_semantique(Id1, Relation, Id2, Source)`. WordNet, les liens morphosémantiques et WOLF y passent d'abord ;
AAT (vocabulaire des vêtements et objets), Wikidata (alias des personnes), VerbNet, FrameNet s'y ajouteront quand une
famille d'erreurs mesurée les demande (tableau de correspondance erreur → ressource dans `DECISIONS.md`).

**Sortie.** Pour chaque ressource ajoutée : son gain mesuré sur la validation, et aucune perte de précision.

### C8 — Les mécanismes d'Iconclass (P1)

1. **Les gabarits à remplir** (« 25F23(...) », « 11H(...) ») : la notation construite à partir d'un nom ou d'un type
   du texte (T5 du cahier), validée par le type du gabarit.
2. **Les clés** (« (+…) ») : une propriété du même référent (T4).
3. **Les lettres doublées** (« AA », « FF ») : le trait déclencheur de la section (féminin, fabuleux, opposé) exigé,
   sinon le jumeau simple (T10).
4. **L'héritage typé** (FONDEMENTS § 3.4) : la personne du récit, le contexte d'un épisode ; vérifié sur toute la
   division 7, 9 et 11.
5. **Les compositions** : une notation et ses parties (« ~ » et gabarits), les renvois.

**Sortie.** Chaque mécanisme a sa strate dans les trois ensembles de C6, et y atteint les critères de M1.

### C9 — L'abduction iconographique (P1)

**But.** Tirer d'Iconclass lui-même des connaissances qui ne sont pas des définitions, et les faire servir à des
**hypothèses**, jamais à des preuves.

- Connaissances compilées (aucune écrite à la main, I10) : `alias_d_identite` (noms, variantes, mots clés),
  `attribut_possible` (« possible attributes: … »), `participant_du_recit` (les personnes d'un récit et de ses
  épisodes), `convention` (lettres doublées, « (other) »), `regle_de_classement` (gabarits, clés).
- Régimes : un attribut possible ne devient jamais une implication ; une combinaison d'attributs discriminants
  (rareté calculée sur Iconclass) donne une **hypothèse d'identité** (T7) ; participants, action et objets avec leurs
  rôles donnent une **hypothèse d'épisode** (T8) ; deux interprétations concurrentes sont comparées et données toutes
  deux.
- En V1, l'abduction produit des **candidats classés avec leurs raisons** ; elle n'établit rien. La certification de
  T7 et T8 vient version après version (cahier § 7.2).

**Sortie.** Sur la validation, le rappel des candidats d'identité et d'épisode mesuré (rappel@5), sans effet sur la
précision des codes établis.

### C10 — Qualifier et livrer la V1 (P1)

1. **Le vérificateur de preuves** : un programme distinct du moteur, qui relit une sortie et le texte et revalide
   chaque preuve (I3, I5).
2. **Les mesures par catégorie**, sur ce que le texte soutient (jugement à la main) :

   | Catégorie | Précision visée | Rappel visé |
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

   Ces cibles sont des **hypothèses de conception** (proposition de la seconde lecture critique du 24/11), à fixer
   par la propriétaire (décision D21) après la mesure de M1 sur la validation. Le critère de réception du cahier
   reste : précision de l'ensemble des codes établis ≥ 0,95, avec sa borne de confiance (Wilson) sur la qualification.
   Le rappel du sujet principal reste mesuré, mais n'est plus le critère.
3. **La ligne de base** : BM25 sur les libellés (version 0.2), mêmes textes, mêmes jugements ; tests métamorphiques
   et test de redondance (accord de l'audit du 24/11).
4. **La livraison** : la commande (`commande.pl`), l'adaptateur des sorties d'Opus, la reproductibilité (I9), la
   documentation d'installation et des licences.

**Sortie (M2 = V1).** Sur la qualification scellée et le banc scellé de 150 textes : précision des codes établis
≥ 0,95 (borne inférieure de Wilson ≥ 0,90), cibles de rappel par catégorie de D21, tous les invariants vrais.

---

## 4. Les jalons

**M1 — le noyau est juste** (fin de C1 à C6), mesuré sur la validation :
- précision des codes établis ≥ 0,95 (tous codes, notation visée ou non) ;
- positifs : la notation visée (ou un descendant) établie dans au moins 50 % des cas (premier seuil, relevé à D21) ;
- négatifs : la notation visée jamais établie (≤ 5 %) ;
- indéterminés : la notation visée jamais établie (≤ 5 %), candidate admise ;
- variantes de C6.3 : chaque ligne du tableau à son attendu dans ≥ 90 % des cas ;
- invariants I1 à I11 vrais ;
- comparaison avec la ligne de base BM25.

**M2 — la V1** : § C10.

---

## 5. Ce qui est réutilisé, ce qui change

| Composant | Réutilisé | Change |
|---|---|---|
| `udpipe.pl`, `conllu.pl`, `stanza_textes.py` | tel quel | Stanza par défaut pour les textes après M1 (D20 bis) |
| `interpretation.pl`, `mondes.pl`, `scene.pl` | lecteur et ancrage | coréférence complétée (C2.2), énonciateurs (C1.1), nombre (C1.6) |
| `assertions.pl`, `docs/ASSERTIONS.md` | langage et validation | quatre valeurs, énonciateurs, contextes |
| `libelles_iconclass.pl`, `definitions.pl` | grammaire des libellés, définitions (Suff) | Néc, provenance, identité / distinction explicites |
| `compilation.pl` | statut, sens | dimensions du statut (C3.2) |
| `projection.pl` | premier jet | quatre valeurs, coréférence, quantification, bornes |
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
- Les jugements sont faits à l'aveugle ; les bancs scellés ne sont lus qu'une fois par jalon.
- Aucune donnée (textes, libellés, jugements, base compilée) dans le dépôt.

## 7. Décisions demandées à la propriétaire

- **D21** : les cibles de précision et de rappel par catégorie (C10.2), après la mesure de M1.
- **D22** : la liste des axiomes de disjonction (C2.1), relue avant d'entrer dans le moteur.
- **D23** : la rédaction des textes de validation et de qualification par des agents (deux rédacteurs, C6.2), ou
  par une autre source (descriptions réelles jugées).
