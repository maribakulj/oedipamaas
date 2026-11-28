# Étude comparative des ressources lexicales pour K

Version 1, 28/11/2026. Document d'étude : il ne décide rien. La seule recommandation (§7) est une **proposition**.

**Périmètre.** Il s'agit des ressources lexicales françaises et multilingues qu'un moteur hors ligne de raisonnement iconographique peut réutiliser. Ce moteur lit des descriptions d'œuvres en français et en anglais, et des définitions Iconclass en anglais. Aujourd'hui, la base de connaissances K repose sur WordNet 3.0 (anglais) et sur WOLF, pris dans l'Open Multilingual Wordnet 1.4 (`omw-1.4/fra/wn-data-fra.tab`). La consigne de la propriétaire sert de cadre à toute l'étude : WordNet et WOLF **restent des ressources de K** ; ils **ne déterminent pas seuls l'ontologie** du système.

**Conventions de marquage.** Chaque fait porte l'une des quatre marques suivantes.
- « vérifié » : j'ai consulté la page, le fichier ou l'article, et l'URL est donnée.
- « vérifié (local) » : j'ai lu un fichier de ressource déjà présent sous `/home/user/donnees/ressources` ou `/home/user/donnees/WordNet-3.0`, ou un fichier téléchargé pour l'étude.
- « mesuré » : chiffre que j'ai calculé moi-même (§2).
- « non vérifié » : connaissance antérieure, ou simple extrait de résultat de recherche dont je n'ai pas ouvert la page. Il faut alors confirmer avant de s'appuyer dessus.

**Ce que je n'ai pas fait.** Je n'ai lu aucun code du projet. J'ai seulement exécuté `outils/bancs/sens_fr.py`, comme la consigne le prévoit. Je n'ai pas ouvert `inventaire.json`, `repartition.json`, aucun autre jeu ni banc, ni rien sous `qualification_independante`. J'ai lu les fichiers `bancs_phase1/dev/*.json` uniquement pour en extraire les champs `description` (cas et variantes) en français. Je n'ai fait aucune opération git. Deux hôtes étaient injoignables depuis la session : `alpage.inria.fr` (ASFALDA) n'est pas autorisé par le réseau, et `wordnet.princeton.edu` a renvoyé un refus 403. Pour la licence de WordNet, j'ai donc lu le fichier `LICENSE` local.

---

## 1. Ce qu'on attend d'une ressource dans K

### 1.1 Des connaissances sur des sens, pas sur des mots

Une ressource n'est utile à K que si elle permet d'écrire des faits de la forme suivante :

> `fait(type, arguments sur des SENS, source, version, attestation, statut)`

Voici les types de faits qu'une ressource lexicale peut fournir.

| Type de fait | Exemple | Ce que la ressource doit fournir |
|---|---|---|
| Lexicalisation : tel mot peut exprimer tel sens | `fr:asseoir` → `sit%2:35:00::` | un couple (lemme, sens), avec langue et catégorie |
| Relation entre sens | `canvas%1:06:04::` hyponyme de `painting` | une relation typée entre identifiants de sens stables |
| Exclusion démontrée | « homme » et « femme » incompatibles pour un même individu | une relation explicitement négative : antonymie, disjonction ou incompatibilité attestée |
| Préférence | `kneel` : agent de préférence animé | une restriction de sélection, une fréquence, un ordre des sens |
| Nom propre et alias | « saint Jérôme » = « Hieronymus » = Q44248 | une entité, ses étiquettes et alias multilingues |
| Vocabulaire iconographique | Jérôme : lion, chapeau de cardinal, crâne… | un sujet, ses attributs, une notation de référence |

### 1.2 Trois exigences qui découlent de la consigne

1. **Source et attestation pour chaque fait.** K doit pouvoir dire d'où vient un fait (ressource, version, identifiant) et quel est son statut : attesté par la ressource, validé par un humain, ou dérivé. Un couple (lemme, synset) de WOLF reste un couple *proposé par un alignement en grande partie automatique* (§4.1). Il n'a pas la même valeur qu'un sens validé.
2. **Exclusions démontrées et préférences, à ne pas confondre.** Seule une relation négative explicite peut écarter une lecture : une antonymie, une disjonction déclarée, une incompatibilité attestée. Restrictions de sélection, ordre des sens et fréquences sont des préférences : elles classent les lectures et n'en écartent aucune. Enfin, **l'absence d'un fait n'est pas une négation** : une lacune de WOLF doit produire « inconnu », jamais « écarté ». Aucune ressource étudiée ne fournit d'incompatibilités générales. WordNet n'a que l'antonymie, surtout adjectivale, et ne déclare jamais ses co-hyponymes disjoints (vérifié (local) : liste des pointeurs dans `doc/html/wninput.5WN.html` de WordNet 3.0 — antonymie, hyperonymie, méronymies, attribut, implication, cause, *also see*, groupe verbal, dérivation, pertainymie, domaines ; aucun pointeur de disjonction). Les exclusions devront donc être rédigées et justifiées dans K. Elles ne s'importent pas.
3. **Une ontologie de travail propre, alignée sur des ressources.** WordNet fournit un inventaire de sens et une hiérarchie. Il ne doit pas être l'ontologie du moteur. Les types utilisés par le raisonnement (personne, saint, attribut, objet représenté, scène…) gagnent à être définis dans K, puis reliés à des synsets WordNet, à des entités Wikidata, à des concepts AAT et à des notations Iconclass. Chaque ressource devient ainsi une source de faits parmi d'autres, remplaçable.

### 1.3 Les six critères

On évalue chaque ressource sur six critères.
1. Couverture : lemmes, sens, expressions polylexicales, noms propres, vocabulaire iconographique et religieux.
2. Erreurs d'alignement : sens parasites, faux amis.
3. Granularité des sens.
4. Relations disponibles.
5. Licence : on distingue l'usage hors ligne de la redistribution.
6. Format et facilité d'intégration hors ligne.

---

## 2. Mesure locale de WOLF (OMW 1.4) sur les bancs

### 2.1 Protocole

**Corpus.** J'ai extrait toutes les descriptions en français de `/home/user/donnees/bancs_phase1/dev/*.json` (9 fichiers) :
- 108 descriptions de cas (`langue = fr`) ;
- 643 descriptions de variantes en français.

Au total, 751 textes distincts et 15 258 occurrences de mots pleins.

La langue d'une variante se détermine ainsi : on prend le champ `langue` de la variante quand il existe. À défaut, une variante de type `traduction` est dans l'autre langue que le cas. Sinon, elle est dans la langue du cas. J'ai contrôlé cette règle avec un détecteur à mots-outils : sur l'instantané final, il y a 0 désaccord.

**Instantané.** Les fichiers ont été modifiés pendant l'étude, entre 04:03 et 04:08 UTC. La mesure finale porte sur l'état de **04:17 UTC le 28/11**. J'ai conservé les empreintes SHA-256 dans le répertoire de travail. Une première mesure, faite à 04:04 sur 756 textes, donnait des chiffres à ±0,3 point de ceux-ci.

**Lemmatisation.** J'ai utilisé **Stanza 1.10.1**, modèles français par défaut (`tokenize, mwt, pos, lemma` ; tokenizer `combined`, lemmatiseur `combined_nocharlm`), installés sans réseau particulier. Les catégories universelles retenues sont NOUN, VERB, ADJ, ADV et PROPN. J'ai d'abord essayé spaCy 3.8 avec `fr_core_news_sm` 3.8.0, puis je l'ai écarté : il tronque les lemmes (« toil », « prêch », « évêqu ») et fait passer les types absents de WOLF à 31,9 %, au lieu de 13,8 % avec Stanza. Le choix du lemmatiseur pèse donc beaucoup sur la mesure, plus que WOLF lui-même pour les adjectifs.

Après Stanza, j'ai fait trois retouches à la main.
1. J'ai corrigé 21 erreurs de lemmatisation constatées, par exemple « peinter » → peindre, « giser »/« gîter » → gésir, « éau-forte » → eau-forte, « gri » → gris.
2. J'ai exclu les ordinaux romains (« xvie », « iie »…).
3. Pour un verbe absent, j'ai cherché aussi sa forme pronominale (« s'enfuir », « s'endormir », « s'accroupir » ont été récupérés ainsi).

Il reste quelques artefacts : « tandis » (pour *tandis que*), « endormi » lemmatisé comme verbe, « nu » étiqueté VERB. Ils représentent moins de 1 point.

**Recherche dans WOLF.** Pour les noms communs, verbes, adjectifs et adverbes, la recherche se fait en minuscules, avec la même catégorie (n, v, a, r) et la normalisation œ/oe. Pour les noms propres, la casse est respectée, avec une initiale majuscule. En minuscules, « pierre » (le minéral) passerait pour « Pierre », ce qui gonflerait la couverture à 77 %.

Pour l'échantillon, j'ai lu les sens avec `sens_fr.py` (WordNet 3.0 + WOLF). Le reste vient d'une lecture directe du `.tab`.

### 2.2 WOLF dans OMW 1.4 : chiffres globaux

Toutes les valeurs ci-dessous sont mesurées sur `wn-data-fra.tab`.

| Grandeur | Valeur |
|---|---|
| Couples (synset, lemme) | 102 671 |
| Lemmes distincts | 55 373, dont 17 014 polylexicaux et 12 057 à majuscule initiale |
| Synsets ayant au moins un lemme français | 59 091 sur 117 659 synsets WordNet 3.0, soit **50,2 %** |
| Noms | 42 908 / 82 115 synsets (52,3 %) |
| Verbes | 7 681 / 13 767 synsets (55,8 %) |
| Adjectifs | 6 945 / 18 156 synsets (38,3 %) |
| Adverbes | 1 557 / 3 621 synsets (43,0 %) |
| Synsets par lemme, sur tout WOLF | 1,85 en moyenne |
| En-tête du fichier | `WOLF (Wordnet Libre du Français) fra http://alpage.inria.fr/~sagot/wolf-en.html CeCILL-C` |

Le fichier ne contient **que des lexicalisations** : aucune relation propre au français, aucune définition française, aucun exemple. Toutes les relations utilisées viennent de WordNet 3.0 par l'identifiant de synset.

### 2.3 Couverture du vocabulaire des bancs

Ces chiffres sont mesurés sur l'instantané de 04:17. « Types » désigne les couples (lemme, catégorie). « Absent » signifie : aucun synset WOLF de la même catégorie pour ce lemme.

| Catégorie | Types | Types absents | Occurrences | Occurrences absentes | Synsets/lemme présent (moyenne / médiane) | Moyenne pondérée par les occurrences | Lemmes monosémiques |
|---|---|---|---|---|---|---|---|
| Noms | 969 | 97 (**10,0 %**) | 8 247 | 4,9 % | 5,45 / 4 | 6,98 | 15,3 % |
| Verbes | 424 | 71 (**16,7 %**) | 3 310 | 9,4 % | 11,64 / 7 | **18,5** | 11,9 % |
| Adjectifs | 214 | 57 (**26,6 %**) | 1 359 | 15,9 % | 6,46 / 4 | 10,11 | 22,3 % |
| Adverbes | 49 | 4 (8,2 %) | 631 | 6,2 % | 5,33 / 4 | 3,96 | 11,1 % |
| **Total (4 catégories)** | **1 656** | **229 (13,8 %)** | 13 547 | **7,1 %** | **7,09 / 5** | **9,87** | 15,1 % |
| Noms propres (casse respectée) | 222 | 100 (**45,0 %**) | 1 589 | 34,9 % | — | — | — |

On peut en tirer trois lectures.

**Il manque peu de mots fréquents, mais beaucoup de mots du domaine.** Environ un lemme plein sur sept manque (7 % des occurrences). Parmi les absents les plus fréquents :
- noms : prédelle (40 occurrences), palme (22), psautier (18), cruche (16), enluminure (14), lavis (14), recueil (13), frontispice (13), majolique (13), sébile (11), rinceau, polyptyque, serviteur, froc, damné, gouache, détrempe, légionnaire, larron, arcature, armoirie, bas-relief, lamentation, nativité, commanditaire, cuirasse, prophétesse, draperie, aiguière, dalmatique, offrande, décor, flacon ;
- verbes : couronner (39), trôner (17), sculpter (13), personnifier (10), encadrer (9), apprêter, nimber, enlacer, empoigner, accourir, renier, paître, enluminer, rehausser, draper ;
- adjectifs : rocheux (21), polychrome (14), voilé (14), historial, bruni, lacunaire, mitré, mural, stylisé, agenouillé, pictural, caravagesque ;
- adverbes : au-dessous (15), auprès (5).

**Ces lacunes viennent de WOLF, pas de WordNet.** Pour la plupart de ces mots, WordNet 3.0 a un équivalent anglais : *psalter, illumination, nativity, lamentation, crown* (verbe), *sculpt, frame, personify, enthrone, rocky, polychrome, mural, Salome, Tobit* sont dans les index de WordNet (vérifié (local) : `index.noun/verb/adj`). Ce qui manque, c'est l'alignement français. Font exception *predella* et *polyptych*, absents de WordNet 3.0, ainsi que *Book of Hours*, *Holy Family* et *Flight into Egypt*, absents eux aussi.

**Les noms propres sont mal couverts.** 45 % des types et 35 % des occurrences manquent. Le plus fréquent, « saint » (127 occurrences) en emploi de titre, n'a aucune entrée de nom propre. Manquent aussi Tobie (34), Jean-Baptiste (22), Sienne, Salomé, Tournai, Urbino, Souabe, Polyphème, Lerne, Agar, Pâris, Joachim, Naïm, Eulalie, Sébastien, Archélaüs, Hérodiade… Sont présents en revanche Christ, Vierge, Jérôme, Judith, Holopherne, Hérode, Samson, Abel, Caïn, Goliath, Dalila, Vénus, Minerve, Hercule et la plupart des grandes villes.

**Expressions polylexicales.** J'ai retenu 60 expressions de 2 ou 3 mots présentes dans les textes. Pour les sélectionner, j'ai repéré des n-grammes selon des motifs (NOM ADJ, ADJ NOM, NOM de/à/en NOM…) puis trié à la main. J'en ai écarté 4 purement compositionnelles (« vieillard barbu », « livre ouvert », « manteau rouge », « école vénitienne »). Sur les **56 expressions usuelles ou terminologiques** restantes, **18 sont dans WOLF (32 %) et 38 n'y sont pas (68 %)**.

| Dans WOLF | Absentes de WOLF |
|---|---|
| jeune femme, jeune fille, bras droit, arrière-plan, côte à côte, à cheval, pieds nus, nature morte, nouveau-né, couronne d'épines, histoire naturelle, jugement dernier, annonciation, Marie-Madeleine, saint Pierre, saint Paul, eau-forte, ange gardien | jeune homme (31 occurrences), main droite (40), main gauche (13), premier plan (19), à genoux (19), torse nu, mains jointes, scène de genre, peinture murale, tableau d'autel, fond d'or, livre d'heures (26), enfant de chœur, couronne de laurier, peau de bête, tronc d'arbre, monument funéraire, copie d'atelier, couche picturale, cabinet d'amateur, arts libéraux, Légende dorée, Fuite en Égypte, Christ en croix, Jugement de Pâris, Adoration des mages, Sainte Famille, (saint) Jean-Baptiste, saint Jérôme, saint Georges, saint Michel, saint Martin (22), bas-relief, or bruni, ange/archange Gabriel, archange Michel, Bible historiale |

Là encore, WordNet anglais a souvent l'équivalent : *young man, right hand, left hand, foreground, still life, genre painting, mural, altarpiece, choirboy, laurel wreath, tree trunk, liberal arts, bas relief, Saint Jerome, Saint George, Saint Martin, John the Baptist* (vérifié (local)).

**Contre-mesure Iconclass.** J'ai téléchargé les textes français d'Iconclass depuis le dépôt CC0 (§4.13). Sur les 177 lemmes absents de WOLF les plus fréquents (noms, verbes, adjectifs), **97 (54,8 %)** apparaissent sous une forme simple dans ces textes. Sur les 80 noms propres absents les plus fréquents, 42 y apparaissent. Ce qu'Iconclass ne couvre pas relève surtout de la technique et de l'objet : prédelle, enluminure, lavis, majolique, rinceau, polyptyque, gouache, détrempe, arcature, bas-relief, polychromie, statuette, chromolithographie. C'est précisément le domaine de l'AAT (§4.12). C'est une mesure rudimentaire (présence d'une forme fléchie simple), à lire comme un ordre de grandeur.

### 2.4 Ambiguïté : nombre de synsets par lemme présent

- Moyenne de **7,09 synsets par lemme** présent, médiane 5. Pondérée par les occurrences, la moyenne monte à **9,87**. Pour les verbes, elle atteint **18,5**.
- Sur tout WOLF, la moyenne n'est que de 1,85. Le vocabulaire des descriptions est le cœur polysémique de la langue.
- Lemmes les plus ambigus : donner (102 synsets), faire (98), mettre (78), tirer (63), présenter (61), passer (60), prendre (58), rendre (57), devenir (56), tenir (52, avec 234 occurrences), point (50).
- 318 lemmes ont 10 synsets ou plus, et 76 en ont plus de 20.
- Il y a **10 151 couples (lemme, synset)** pour les lemmes présents, dont 5 246 pour les 639 lemmes de fréquence ≥ 5. Cela donne l'ordre de grandeur d'une relecture (§5).

### 2.5 Échantillon de 30 lemmes jugés à la main

**Tirage.** Tirage aléatoire (graine 2811) parmi les lemmes présents de fréquence ≥ 2, stratifié selon la répartition des catégories : 18 noms, 7 verbes, 4 adjectifs, 1 adverbe. Cela fait 259 synsets.

**Jugement.** J'ai jugé chaque synset (gloses et exemples de WordNet) avec l'une des trois cotes suivantes.
- **O** : le mot français a réellement ce sens.
- **~** : douteux ou marginal. Le sens est possible en contexte, ou il revient en fait à une forme voisine (féminin, pronominal, mot apparenté).
- **X** : sens parasite. Le mot français ne peut pas exprimer ce concept. L'erreur vient presque toujours de la polysémie du mot anglais pivot.

| # | Lemme (cat.) | Fréq. | Synsets | O | ~ | X | Sens parasites typiques (X), et manques |
|---|---|---|---|---|---|---|---|
| 1 | scène (n) | 56 | 13 | 9 | 2 | 2 | *leg/stage* d'un voyage (étape), *microscope stage* (platine) |
| 2 | vert (n) | 5 | 8 | 2 | 1 | 5 | kétamine (*green*, argot), *park/common*, Green River, William Green |
| 3 | époux (n) | 8 | 4 | 3 | 1 | 0 | *wife* (relève d'« épouse ») |
| 4 | plan (n) | 11 | 11 | 9 | 1 | 1 | *gradient/slope*. **Manque** le plan pictural (*premier plan* = *foreground*) |
| 5 | tableau (n) | 36 | 18 | 8 | 2 | 8 | *array/raiment* (vêtements d'apparat), *board* (planche), BBS, *panel*, *board* = repas (« table »), *table* = tablée |
| 6 | banderole (n) | 5 | 3 | 1 | 1 | 1 | *striation* (bande de couleur) |
| 7 | abord (n) | 2 | 25 | 0 | 4 | 21 | relation, *landing* (atterrissage, palier), *acceptance*, *first base*, *admission fee*, *understanding*, *meeting*… Entrée presque entièrement fausse. **Manquent** « d'abord » et « abords » |
| 8 | voilier (n) | 3 | 2 | 2 | 0 | 0 | — |
| 9 | face (n) | 17 | 13 | 6 | 1 | 6 | *rigging/tackle*, *typeface*, *grimace*, *address*, *sports meet*, *softwood/deal* |
| 10 | cathédrale (n) | 2 | 2 | 2 | 0 | 0 | — |
| 11 | gerbe (n) | 2 | 1 | 1 | 0 | 0 | — |
| 12 | chaudron (n) | 4 | 1 | 1 | 0 | 0 | — |
| 13 | fleur (n) | 10 | 9 | 5 | 3 | 1 | *angiosperm* (plante à fleurs) |
| 14 | victoire (n) | 5 | 3 | 2 | 1 | 0 | — |
| 15 | chaire (n) | 10 | 1 | 1 | 0 | 0 | sens rattaché à un synset large (*dais, podium, pulpit, rostrum*). **Manque** la chaire universitaire |
| 16 | vernis (n) | 6 | 1 | 1 | 0 | 0 | — |
| 17 | balance (n) | 11 | 6 | 5 | 1 | 0 | — (le faux ami *balance* = équilibre est bien évité) |
| 18 | hydre (n) | 7 | 2 | 2 | 0 | 0 | **Manque** l'Hydre de Lerne (mythologie) |
| 19 | nager (v) | 5 | 2 | 1 | 1 | 0 | — |
| 20 | nu (v) | 5 | 3 | 0 | 0 | 3 | *bare/denude/publicize* : « nu » rattaché à des **verbes** anglais *bare*. Erreur de WOLF, rendue visible par une erreur d'étiquetage |
| 21 | jouer (v) | 14 | 42 | 29 | 9 | 4 | *play a hooked fish*, *play water from a hose*, *work a miracle*, *play well with the public*. Problème surtout de granularité |
| 22 | jeter (v) | 10 | 17 | 10 | 2 | 5 | *build* (« suspense was building »), *throw a pot*, *bewilder*, *cough up*, *attend to* |
| 23 | lever (v) | 71 | 17 | 4 | 3 | 10 | *lift fingerprints*, *scalp*, *suspend*, *elevate in rank*, *stand at stud*, *plagiarize*, *forgo*. **Manque** « se lever » (rangé sous l'entrée pronominale) |
| 24 | inscrire (v) | 17 | 13 | 8 | 1 | 4 | *commemorate*, *label*, *register* (orgue), *register* = remarquer |
| 25 | asseoir (v) | 141 | 9 | 3 | 1 | 5 | *ride a horse*, *be in session* (siéger), *pose* (poser), *baby-sit*, *the theater seats 2000*. **Manque** « asseoir son autorité » |
| 26 | deuxième (a) | 14 | 2 | 1 | 0 | 1 | *second* = partie de second violon (relève de « second ») |
| 27 | second (a) | 2 | 2 | 2 | 0 | 0 | — |
| 28 | large (a) | 6 | 19 | 4 | 4 | 11 | **Faux ami** : *big/large* (de grande taille), *huge/immense*, *bulky*, *capacious*, *abundant*, *copious*, *elongated*, *wide of the mark*, *wide-eyed* |
| 29 | intact (a) | 2 | 4 | 3 | 0 | 1 | *uncastrated* (relève d'« entier ») |
| 30 | plus (r) | 9 | 6 | 4 | 1 | 1 | *less* (sens inverse !) |
| | **Total** | | **259** | **129 (49,8 %)** | **40 (15,4 %)** | **90 (34,7 %)** | |

Ces résultats sont mesurés, et le jugement a été fait par un seul annotateur, l'auteur de l'étude. Une double annotation serait nécessaire avant tout usage chiffré.

**Synthèse de l'échantillon.**
- **34,7 % des synsets proposés sont parasites** et 15,4 % douteux. Sans les deux entrées atypiques (« abord » et « nu » verbe), il reste 231 synsets, dont 28,6 % parasites et 55,8 % corrects.
- **18 lemmes sur 30 ont au moins un sens parasite.** Seuls 12 sont propres, presque tous des noms concrets peu polysémiques : voilier, cathédrale, gerbe, chaudron, vernis, chaire, balance, hydre…
- Les erreurs suivent toutes le même mécanisme : un mot anglais polysémique sert de pivot, et tous ses synsets sont attribués au mot français. On le voit avec *large*, *table/board/array*, *sit*, *lift/raise*, *throw*, *green*, *face*, *bare*.
- **Les silences comptent autant que le bruit.** Le sens du domaine manque souvent alors que des sens parasites sont présents : plan pictural, « se lever » rangé ailleurs, Hydre de Lerne, « d'abord ».

**Contrôles ponctuels hors échantillon** (vérifié (local), `sens_fr.py`) :
- « Vierge » reçoit *doll*, *dummy* (mannequin), *mermaid* (sirène) et *maiden over* (cricket), à côté de *Virgin Mary*.
- « croix » reçoit *bad-tempered/crabby* (l'adjectif *cross*) et l'hybridation.
- « palmier » reçoit *palm* = paume de la main et *palm* = décoration, alors que « palme », 22 occurrences, est absent.

Pour un moteur d'iconographie chrétienne, ces trois cas sont graves.

**Conséquence pour K.** Un couple WOLF est une **hypothèse de lexicalisation**. Ce n'est pas un fait validé. Il ne peut servir ni à établir un sens à lui seul, ni à en écarter un. Et l'absence d'un lemme dans WOLF signale une lacune de la ressource, pas un fait de langue.

---

## 3. Tableau comparatif des ressources

Abréviations : hyp. = hyperonymie, mér. = méronymie, dér. = dérivation, ant. = antonymie, RS = restrictions de sélection, NP = noms propres.

| Ressource | 1. Couverture | 2. Alignement / bruit | 3. Granularité | 4. Relations | 5. Licence : usage hors ligne / redistribution | 6. Format, intégration hors ligne |
|---|---|---|---|---|---|---|
| **WordNet 3.0 (PWN)** | 117 659 synsets (vérifié (local)) ; NP partiels ; peu de vocabulaire iconographique (*predella* et *polyptych* absents) | sans objet (ressource source) | très fine, surtout pour les verbes | hyp., mér. (3 sortes), dér., ant., implication, cause, *similar-to*, attribut, domaines ; 35 cadres verbaux génériques (vérifié (local) `frames.vrb`) ; **pas de RS, pas de disjonction** | libre, avec notice obligatoire / redistribution libre avec notice (vérifié (local) `LICENSE`) | WNDB texte ; outils partout (NLTK, `wn`) ; très facile |
| **WOLF 1.0b4** (version complète) | tous les synsets de PWN, y compris vides (vérifié) ; taille non vérifiée | alignement semi-automatique ; ~86 % de précision citée pour une version de 2012 (vérifié via WoNeF 2014) | celle de PWN | aucune propre (hérite de PWN) | CeCILL-C (vérifié) / redistribution libre ; les modifications de la ressource restent sous CeCILL-C | XML (`wolf-1.0b4.xml.bz2`) ; lien GForge historique (vérifié) |
| **WOLF dans OMW 1.4** | 55 373 lemmes, 50,2 % des synsets ; bancs : 13,8 % des types et 7,1 % des occurrences absents ; NP 45 % absents ; expressions 68 % absentes (mesuré) | **34,7 % de sens parasites** sur l'échantillon (mesuré) | celle de PWN, avec en plus des sens parasites | aucune (lemmes seuls) | CeCILL-C (vérifié (local) en-tête et `LICENSE`) | TSV trivial ; déjà intégré |
| **WoNeF** (2014) | 3 versions : haute précision 15 625 couples, haute F-mesure 88 736, haute couverture 109 447 (vérifié) | 93,3 % de précision pour la haute précision ; F 70,9 % (vérifié) | celle de PWN | aucune propre | LGPL-LR (vérifié dans l'article) / redistribution libre | fichiers sur wonef.fr (non vérifié : site non ouvert) |
| **Open English WordNet** 2024/2025 | 2025+ : 161 875 mots, 120 564 synsets (vérifié) ; NP déplacés vers *Namenet* en 2025 (vérifié) | sans objet ; corrections manuelles uniquement (vérifié) | proche de PWN, quelques fusions et créations (non vérifié en détail) | celles de PWN : 419 226 relations dans 2025+ (vérifié) | CC BY 4.0 (vérifié) / redistribution libre avec attribution | WN-LMF XML, RDF, WNDB, JSON (vérifié) ; identifiants différents des offsets 3.0 (passer par CILI) |
| **OMW 2 / CILI** | 60 wordnets, 49 langues dans Cygnet (vérifié) ; le français reste WOLF (vérifié, `index.toml`) | identique à WOLF pour le français | — | celles des wordnets agrégés | licence de chaque wordnet ; CeCILL-C pour le français (vérifié) | WN-LMF ; paquet `omw-fr` dans `wn` (non vérifié en détail) |
| **JeuxDeMots / RezoJDM** | très grand réseau contributif (plus de 310 000 termes en 2010 ; non vérifié) ; riche en polylexicaux et en associations | pas d'alignement anglais ; bruit de contribution, pondéré par le vote | sens par « raffinements », hétérogènes | très nombreuses relations typées (association, hyp., partie, agent typique, lieu, caractéristique…) ; non vérifié en détail | CC BY-SA 2.0 annoncée en 2008 (vérifié, LinuxFr) ; mention « domaine public » ailleurs (non vérifié) ; **à clarifier** | dumps texte (non vérifié) ; volumineux |
| **Wiktionnaire / DBnary** | très large pour le français, y compris expressions et noms propres (non vérifié en chiffres) | traductions au niveau de l'article ou du sens, pas des synsets | sens lexicographiques de dictionnaire | synonymes, antonymes, hyp. partielles, dérivés, traductions, morphologie (vérifié pour les catégories générales) | CC BY-SA 4.0 (vérifié) / partage à l'identique | RDF Turtle par langue, archives Zenodo (vérifié) |
| **BabelNet** | énorme et multilingue | fusion automatique (WordNet, Wikipedia, Wiktionary, OMW…), avec bruit hérité | — | nombreuses relations | **non commerciale, réservée aux institutions de recherche, adaptations accessibles aux seuls instituts de recherche** (vérifié) | API ou dump sur demande ; **incompatible avec une diffusion libre** |
| **ConceptNet 5** | multilingue, assertions de bon sens | **reprend les erreurs de WOLF/OMW** (« vierge » → *doll*, *mermaid*, *maiden over* ; vérifié) | aucune notion de sens pour la plupart des nœuds | relations de bon sens (IsA, PartOf, UsedFor, AtLocation, CapableOf, Antonym, Synonym…) | CC BY-SA 4.0 (vérifié) / partage à l'identique | CSV d'assertions ; facile |
| **FrameNet 1.7** | 1 221 cadres, 13 572 unités lexicales (vérifié (local)) ; quelques cadres religieux (Religious_belief, Rite, Execution, Killing ; vérifié (local)) | sans objet (anglais) | cadres plus grossiers que WordNet | relations entre cadres : héritage, sous-cadre, usage, perspective, causatif, inchoatif, précède, voir aussi, métaphore (vérifié (local)) ; éléments de cadre ; types sémantiques | CC BY, tout usage y compris commercial, avec mention obligatoire (vérifié (local), notes de version 1.7) | XML ; lecteur NLTK |
| **FrameNet français (ASFALDA)** | 98 cadres, 662 mots déclencheurs, 872 sens, environ 13 000 annotations (non vérifié : extrait de recherche) ; 4 domaines : transactions, positions cognitives, communication, causalité | — | cadres de FrameNet | celles de FrameNet | « libre » (non vérifié ; site injoignable) | annotations sur le French Treebank et Sequoia |
| **VerbNet 3.3** | 329 fichiers de classes, 6 781 membres, 4 574 verbes distincts ; 5 493 membres ont une clé WordNet (mesuré local) | correspondances manuelles vers WordNet | classes de Levin, plus grossières que WordNet | rôles thématiques, **RS** (animate 338 occurrences, organization 179, concrete 110, location…), cadres syntaxiques, prédicats sémantiques ; correspondances PropBank et FrameNet | licence non lue dans l'archive (non vérifié ; réputée libre) | XML ; lecteur NLTK |
| **Verb∋Net / VerbeNet** (français) | traduction des classes VerbNet vers les verbes français, à partir de LVF et du Lexique-Grammaire (non vérifié : extraits d'articles) | correspondance de classes, partiellement manuelle | classes VerbNet | classes, rôles, alternations en cours d'adaptation | non vérifiée | même format que VerbNet annoncé (non vérifié) |
| **Lefff 3.5** | grand lexique morphosyntaxique (100 000 à 1 million de formes ; vérifié) | sans objet | aucune sémantique | morphologie, sous-catégorisation dans le Lefff complet | LGPL-LR (vérifié) | texte ; lemmatisation hors ligne |
| **LVF** (Dubois et Dubois-Charlier) | environ 25 600 entrées verbales (non vérifié : bibliographie) | — | emplois fins, classes sémantico-syntaxiques | schèmes syntaxiques, classes, opérateurs sémantiques | non vérifiée | tableur ou XML (MoDyCo, RALI ; non vérifié) |
| **Dicovalence** | 3 727 infinitifs, plus de 8 300 entrées (vérifié) | — | une entrée par cadre de valence | valence, paradigmes pronominaux, passifs, liens entre entrées | LGPL-LR (vérifié) | texte (ORTOLANG ; non vérifié) |
| **PropBank / French P7-PropBank / AnCora** | anglais ; prototypes français (Gardent et Cerisara ; van der Plas et al.) ; AnCora couvre l'espagnol et le catalan (non vérifié) | projection anglais → français, bruitée | rôles numérotés par prédicat | structures argumentales | variables (non vérifié) | peu utile hors corpus annoté |
| **Wikidata** | NP massifs, alias multilingues ; saints : Q44248 Jérôme = 8 alias anglais, propriétés P4185 et P1256 (vérifié) | identifiants stables, peu de bruit lexical ; complétude inégale (Jérôme : P4185 = lion, crâne seulement ; vérifié) | entités, pas sens lexicaux | type, partie de, attribut iconographique (P4185), notation Iconclass (P1256), dépeint (P180) et ses qualificatifs (P1354) (vérifié) | **CC0** (vérifié) / redistribution sans condition | dump JSON énorme ; extraction ciblée puis gel |
| **Getty AAT** (et **ULAN**, **TGN**) | AAT : objets, matériaux, techniques, styles ; termes français partiels (projet suisse CH-AAT ; non vérifié) | équivalents traduits sur la note d'application (non vérifié) | concepts de thésaurus | hiérarchies (facettes), termes associés ; ULAN : artistes et leurs rôles | **ODC-By 1.0** (non vérifié : extrait de recherche concordant) / redistribution avec attribution | RDF N-Triples mensuels, SPARQL ; migration de plateforme annoncée pour l'automne 2026 (non vérifié) |
| **Iconclass** | 43 588 notations dans l'arbre de base en anglais, **43 563 en français (99,9 %)** (mesuré sur les fichiers téléchargés) ; plus d'un million de nœuds avec les clés (vérifié) ; saints avec « attributs possibles » | traduction humaine des textes (non vérifié) | sujets iconographiques, classification hiérarchique | hiérarchie de notations, clés, renvois ; attributs en texte libre | **CC0** (vérifié) | texte structuré, SKOS et SQLite via scripts (vérifié) ; très facile |
| **Garnier / Joconde** | thésaurus iconographique Garnier (1984), 18 chapitres (vérifié) ; 16 listes Joconde (techniques, dénominations, auteurs, époques…) (vérifié) | — | descripteurs documentaires | hiérarchies, termes associés | listes Joconde : Licence ouverte Etalab (vérifié) ; Garnier : contenu du site sous Etalab 2.0 « sauf mention » (vérifié), licence propre du PDF non précisée | Joconde : SKOS ou CSV sur demande, Opentheso (vérifié) ; Garnier : **PDF** (vérifié), dérivé sur Opentheso th285 |

---

## 4. Fiches par ressource

### 4.1 WOLF (Wordnet Libre du Français)

**Versions et construction.**
- La dernière version annoncée est la **1.0b4** (vérifié : https://almanach.inria.fr/software_and_resources/custom/WOLF-en.html et http://pauillac.inria.fr/~sagot/index.html#wolf). Le lien de téléchargement historique est `gforge.inria.fr/frs/download.php/file/33496/wolf-1.0b4.xml.bz2` (vérifié). Je n'ai pas vérifié qu'il fonctionne encore.
- Versions antérieures citées : 0.1.4 (2008) et 1.0b (vérifié : article WoNeF, https://aclanthology.org/W14-0105.pdf).
- Méthode (vérifié, même page) :
  - *expand approach* : on garde la structure de Princeton WordNet et on traduit les littéraux ;
  - mots polysémiques : alignement de corpus parallèles en cinq langues, désambiguïsé par les wordnets de ces langues ;
  - mots monosémiques : lexiques bilingues tirés de Wikipédia et de thésaurus ;
  - extensions ultérieures : paires de traduction, nominalisations, grappes de mots, graphe des traductions du Wiktionnaire ;
  - contrôles : détection d'erreurs, validation manuelle d'une partie des candidats suspects, filtrage par la catégorie du Lefff.
- Qualité publiée : environ 77 000 couples avec 86 % de précision, d'après Sagot et Fišer 2012, cité par Pradet et al. 2014 (vérifié dans l'article WoNeF).

**Évaluation sur les six critères.**
1. Couverture : moyenne. Bonne sur le vocabulaire courant ; faible sur le vocabulaire iconographique, les noms propres et les expressions (§2.3).
2. Alignement : précision publiée d'environ 86 % au niveau des couples. Notre échantillon, pondéré par les lemmes polysémiques d'un corpus réel, trouve 35 % de couples parasites. Les deux chiffres sont compatibles : un lemme polysémique porte beaucoup de couples, et les erreurs s'y concentrent.
3. Granularité : celle de PWN.
4. Relations : aucune propre.
5. Licence : **CeCILL-C** (vérifié). C'est un copyleft faible, analogue à la LGPL. L'usage hors ligne est libre. Le moteur peut être diffusé sous une autre licence : ce qui doit rester sous CeCILL-C, ce sont la ressource et ses modifications (non vérifié : lecture juridique fine à faire).
6. Intégration : XML simple.

**Maintenance.** Je n'ai trouvé aucune version postérieure à 1.0b4. L'hébergement GForge de l'INRIA est historique (non vérifié qu'il soit fermé).

### 4.2 WOLF dans OMW 1.4

C'est ce qu'utilise K aujourd'hui (§2.2) : les lemmes seulement, sans relations, sans définitions françaises et sans indice de confiance. Sa licence est celle de WOLF : CeCILL-C (vérifié (local)). Je n'ai trouvé nulle part quelle sous-version de WOLF et quel filtrage OMW a retenus (non vérifié). Il faudrait le documenter avant de citer ce fichier comme « WOLF 1.0b4 ».

### 4.3 WoNeF

Pradet, de Chalendar et Baguenier Desormeaux, GWC 2014 (vérifié : https://aclanthology.org/W14-0105.pdf).
- **Construction** : elle prolonge JAWS (dictionnaires bilingues et modèle de langue syntaxique). Les traductions sont sélectionnées par des sélecteurs, dont l'un exploite les relations WordNet (méronymie…). Un vote entre sélecteurs produit la version haute précision.
- **Trois versions** :
  - haute précision : P = 93,3 %, 15 625 couples ;
  - haute F-mesure : F = 70,9 %, 88 736 couples ;
  - haute couverture : 109 447 couples.
- **Licence** : **LGPL-LR**, et « freely available on http://wonef.fr/ » (vérifié dans l'article ; site non ouvert).
- **Intérêt pour K** : c'est la seule source indépendante de WOLF pour corroborer un couple (lemme, synset). En revanche, la version haute précision est petite, et les versions larges sont plus bruitées que WOLF.
- **Risque** : ressource non maintenue depuis 2014 (non vérifié).

### 4.4 Open English WordNet (OEWN)

- **Éditions** : 2024 (01/11/2024), puis **2025 et 2025+ (31/12/2025)**. L'édition 2025 ne contient que les noms communs, verbes, adjectifs et adverbes. L'édition 2025+ y ajoute une sélection de noms propres tirés d'*Open English Namenet*, lui-même dérivé de Wikidata (vérifié : https://en-word.net/downloads et https://github.com/globalwordnet/english-wordnet).
- **Taille de 2025+** : 120 564 synsets, 419 226 relations (vérifié).
- **Contributions** : uniquement manuelles ; « nous ne pouvons pas accepter de résultats générés automatiquement qui n'ont pas été validés à la main » (vérifié).
- **Licence** : CC BY 4.0 (vérifié).
- **Formats** : WN-LMF, RDF, WNDB, JSON (vérifié).
- **Intérêt pour K** : WordNet anglais maintenu, sous une licence plus simple à citer, et dont les erreurs de PWN 3.0 sont corrigées.
- **Coût** : les identifiants changent. Il faut passer par les clés de sens ou par **CILI** (vérifié : CILI relie les versions, README OEWN), et WOLF reste aligné sur les offsets 3.0. Je n'ai pas vérifié en détail les nouveaux types de relations d'OEWN.

### 4.5 Open Multilingual Wordnet 2 / CILI

OMW 2 relie les wordnets par CILI. Le navigateur Cygnet annonce 60 wordnets pour 49 langues (vérifié : https://omwn.org/). Le paquet français y est toujours WOLF, sous CeCILL-C, avec pour URL la page de B. Sagot (vérifié : https://raw.githubusercontent.com/omwn/omw-data/main/index.toml). **OMW 2 n'apporte donc aucune amélioration au français.** Il change seulement le format (WN-LMF) et les liens (CILI).

### 4.6 JeuxDeMots / RezoJDM

- **Nature** : réseau lexico-sémantique du français construit par des jeux contributifs et des inférences (Lafourcade et Le Brun 2020, revue *Lexique* ; non vérifié au-delà du titre).
- **Points forts** :
  - nombreuses relations typées, qu'aucun wordnet ne donne : agent typique, patient typique, lieu, instrument, caractéristique, partie, associations ;
  - polylexicaux et vocabulaire courant ;
  - poids des relations.
- **Faiblesses** :
  - les « sens » sont des raffinements sans correspondance avec WordNet ;
  - la qualité est hétérogène ;
  - les relations négatives existent (non vérifié) mais leur statut d'« exclusion démontrée » serait discutable.
- **Licence** : un article de 2008 annonce « Creative Commons by-sa 2.0 » pour les données et GPLv3 pour les API (vérifié : https://linuxfr.org/news/jeuxdemots-un-jeu-en-ligne-pour-produire-des-donnees-lexicales). Un article de 2023 la classerait comme « domaine public » (non vérifié). La page « à propos » du site ne donne pas le texte de la licence dans ce que j'ai pu lire (vérifié : https://www.jeuxdemots.org/jdm-about.php). **La licence doit être clarifiée par écrit avant tout usage dans K.**

### 4.7 Wiktionnaire et DBnary

- **DBnary** extrait 28 éditions du Wiktionnaire, dont le français : entrées, sens, traductions, relations lexicales et morphologie (vérifié : https://kaiko.getalp.org/about-dbnary/).
- **Licence** : les données sont sous **CC BY-SA 4.0** et les extracteurs sous MIT (vérifié, même page). Les extractions sont refaites à chaque dump du Wiktionnaire et archivées sur Zenodo (vérifié).
- **Intérêt pour K** :
  - les définitions françaises, qui manquent à WOLF, permettent de juger un alignement ;
  - les traductions français → anglais se font au niveau du sens (avec une glose), ce qui donne un **second vote indépendant** de WOLF pour corroborer ou contester un couple ;
  - noms propres et expressions.
- **Coût** : le partage à l'identique s'applique à toute adaptation de la base. Les faits dérivés de DBnary devraient former une couche séparée sous CC BY-SA. Je n'ai pas mesuré la couverture du français.

### 4.8 BabelNet

La licence actuelle est la *BabelNet Non-Commercial License* (vérifié : https://babelnet.org/full-license).
- Usage réservé aux **institutions de recherche**.
- Interdiction de tout usage orienté vers un avantage commercial.
- Les adaptations ne peuvent être diffusées qu'aux institutions de recherche, sous la même licence, sans sous-licence.

**Conclusion : BabelNet est incompatible avec une diffusion libre du moteur.** Même un usage hors ligne pose problème si l'organisation n'est pas une institution de recherche. Sa construction automatique réutilise par ailleurs WordNet, OMW (donc WOLF) et Wiktionary : ce n'est pas une source indépendante. **À exclure de K.**

### 4.9 ConceptNet

- **Licence** : **CC BY-SA 4.0** (vérifié : https://github.com/commonsense/conceptnet5/wiki/Copying-and-sharing-ConceptNet).
- **Relations** : de bon sens (IsA, PartOf, UsedFor, AtLocation, CapableOf, Antonym…). Elles sont faibles ou contributives, et non désambiguïsées pour la plupart des nœuds.
- **Fait vérifié important** : la page `fr/vierge` donne comme synonymes *doll*, *dummy*, *mermaid*, *maiden over*, *Virgo*, avec pour sources DBpedia, les Wiktionnaires et **Open Multilingual WordNet** (vérifié : https://conceptnet.io/c/fr/vierge). **ConceptNet recopie les erreurs de WOLF.** On ne peut donc pas compter un accord entre ConceptNet et WOLF comme une corroboration.
- **Maintenance** : non maintenu activement depuis la version 5.7 de 2019 (non vérifié).

### 4.10 FrameNet et les FrameNet français

- **FrameNet 1.7** : 1 221 cadres, 13 572 unités lexicales, 107 textes annotés en continu (vérifié (local) : `framenet_v17/README.txt`).
- **Licence** : « Creative Commons Attribution-Only », tout usage y compris commercial, avec mention écrite de FrameNet obligatoire (vérifié (local) : `docs/GeneralReleaseNotes1.7.pdf`).
- **Relations entre cadres** : Inheritance, Subframe, Using, Perspective_on, Causative_of, Inchoative_of, Precedes, See_also, Metaphor, ReFraming_Mapping (vérifié (local) : `frRelation.xml`).
- **Cadres et unités utiles à l'iconographie** : `Religious_belief`, `Rite`, `Execution`, `Killing`, `Posture`, `Body_mark`, ainsi que les unités *baptize.v, behead.v, crucify.v, kneel.v, pray.v, crown.n/v, saint.n, depict.v, portray.v, painting.n* (vérifié (local)). Il n'y a pas de cadre `Martyrdom` ni `Prayer` (vérifié (local)).
- **Intérêt** : les cadres et éléments de cadre donnent les structures argumentales (qui couronne qui, avec quoi) dont K a besoin pour les scènes.
- **ASFALDA** (FrameNet français) : 98 cadres, 662 mots déclencheurs, 872 sens, environ 13 000 cadres annotés sur le French Treebank et Sequoia, restreints à quatre domaines (non vérifié : extraits de recherche sur https://aclanthology.org/L16-1601/). Ces domaines ne recoupent presque pas l'iconographie. Le site `alpage.inria.fr/asfalda` était injoignable depuis la session, d'où une licence non vérifiée.

### 4.11 VerbNet et Verb∋Net (VerbeNet)

- **VerbNet 3.3** (vérifié (local) `verbnet-3.3.tar.gz` ; vérifié https://verbs.colorado.edu/verbnet/) : 329 fichiers de classes, 272 sous-classes, 6 781 membres, 4 574 verbes distincts. **5 493 membres ont une correspondance WordNet** par clé de sens (mesuré local).
- **Restrictions de sélection** les plus fréquentes : animate (338), organization (179), concrete (110), location (59), region, state, body_part, solid, machine, comestible… (mesuré local).
- **Licence** : aucun fichier de licence dans l'archive (non vérifié ; à confirmer sur la page des téléchargements).
- **Pour K** : les restrictions de sélection sont **des préférences** (§1.2). « Agent [+animate] » permet de préférer une lecture, pas d'en exclure une : une statue, une allégorie ou un animal personnifié peuvent agir dans une image.
- **Verb∋Net / VerbeNet** (Danlos, Pradet et al., LREC 2014, TAL 2016) : les classes VerbNet sont transposées aux verbes français à partir de LVF et du Lexique-Grammaire, et les alternations sont en cours d'adaptation (non vérifié : extraits ; https://aclanthology.org/L14-1204/). Ni la distribution ni la licence ne sont vérifiées.

### 4.12 Lefff, LVF, Dicovalence

- **Lefff 3.5** : lexique morphologique et syntaxique ; la version Hugging Face ne fournit que la morphologie (forme, lemme, catégorie, traits). Licence **LGPL-LR** (vérifié : https://huggingface.co/datasets/sagot/lefff_morpho/blob/main/README.md). C'est le meilleur candidat pour une **lemmatisation hors ligne par dictionnaire**, qui réduirait la dépendance aux erreurs des lemmatiseurs statistiques constatées en §2.1. WOLF l'a d'ailleurs utilisé pour se filtrer.
- **LVF** (Dubois et Dubois-Charlier) : environ 25 600 entrées, refondues en 1994 et 2013, diffusées par MoDyCo (tableur) et le RALI (XML) (non vérifié : bibliographie, https://talep-archives.lis-lab.fr/FondamenTAL/Bibliographie_Jean_Dubois.pdf). Les emplois y sont distingués finement, avec des schèmes syntaxiques et des opérateurs sémantiques. **Licence non vérifiée** : à confirmer.
- **Dicovalence** : 3 727 infinitifs et plus de 8 300 entrées de valence (paradigmes pronominaux, constructions associées, passif), sous **LGPL-LR** (vérifié : https://listserv.linguistlist.org/pipermail/linguist/2006-December/033321.html). Le manuel 2.0 est hébergé sur ORTOLANG (non vérifié pour les données).

### 4.13 PropBank, AnCora, PropBank français

PropBank est anglais. AnCora porte sur l'espagnol et le catalan : il n'apporte rien au français, hors méthode (non vérifié). Côté français, il n'existe que des prototypes : P7-PropBank (Gardent et Cerisara), la projection anglais → français sur Europarl avec 1 000 phrases annotées à la main (van der Plas et al.), et des expériences d'étiquetage de rôles (non vérifié : extraits de recherche). **Il n'y a pas de PropBank français de référence à réutiliser.** Pour K, Dicovalence et VerbNet suffisent pour les structures argumentales.

### 4.14 Wikidata

- **Licence** : les données structurées sont sous **CC0** (vérifié : https://www.wikidata.org/wiki/Wikidata:Licensing).
- **Propriétés utiles** (vérifié) :
  - **P4185** « iconographic symbol » : https://www.wikidata.org/wiki/Property:P4185 (exemples : Pierre → clés, Laurent → gril) ;
  - **P1354** « shown with features », qualificatif de P180 « dépeint » : https://www.wikidata.org/wiki/Property:P1354 ;
  - **P1256**, notation Iconclass.
- **Exemple** : Q44248 (Jérôme) a 8 alias anglais (Hieronymus, St. Jerome, Jerome of Stridon…), P4185 = lion et crâne, et P1256 = `11H(JEROME)` (vérifié : https://www.wikidata.org/wiki/Q44248).
- **Complétude inégale** : pour les attributs de Jérôme, Iconclass liste en plus le livre, le chapeau de cardinal, le crucifix, le sablier et la pierre (§4.15). La page consultée n'affichait pas d'étiquette française, ce qui est sans doute un artefact de la vue (non vérifié).
- **Pour K** : c'est la meilleure source pour les noms propres (saints, personnages bibliques et mythologiques, lieux) et leurs alias français et anglais. Il faut l'extraire une fois, de façon ciblée (classes saint, personnage biblique, figure mythologique, lieux cités), et **geler l'extrait avec sa date**.

### 4.15 Getty AAT, ULAN (et TGN)

- **Licence** : ODC-By 1.0, avec une mention d'attribution prescrite. L'usage des URI canoniques de l'AAT suffit à l'attribution quand la mention complète n'est pas possible (non vérifié : extrait de recherche concordant ; page https://www.getty.edu/research/tools/vocabularies/lod/ non lisible par l'outil).
- **Formats** : N-Triples complets mis à jour chaque mois et SPARQL (non vérifié). Getty annonce une migration de plateforme à partir de l'automne 2026 (non vérifié : FAQ Getty par extrait).
- **Termes français** : ils viennent notamment du projet suisse de traduction (CH-AAT, SARI) (non vérifié : https://www.sari.uzh.ch/en/Projects/the-swiss-art-and-architecture-thesaurus-translation-project.html non ouvert).
- **Pour K** : l'AAT couvre exactement ce qui manque à WOLF et à Iconclass (§2.3) : techniques, matériaux, types d'objets (prédelle, lavis, gouache, polyptyque, détrempe, majolique, enluminure). Je n'ai pas mesuré la couverture française de l'AAT sur ces termes : c'est la prochaine mesure utile. L'**ULAN** couvre les artistes, utiles pour les attributions (« suiveur de… », « atelier de… »).

### 4.16 Iconclass

- **Licence et dépôt** : données sous **CC0** (vérifié : https://github.com/iconclass/data). Le dépôt contient des textes en cz, de, en, es, fi, **fr**, hu, it, jp, nl, pl, pt et zh, ainsi que des mots-clés (`kw`) et des clés (vérifié). On y trouve environ 40 000 nœuds de base et plus d'un million avec les clés (vérifié).
- **Mesure sur les fichiers téléchargés** : 43 588 notations anglaises et 43 563 françaises, soit **99,9 % de l'arbre traduit** (mesuré).
- **Exemple** : `11H(JEROME)|Jérôme, moine et ermite, attributs possibles : livre, chapeau de cardinal, crucifix, sablier, lion, tête de mort, caillou` (mesuré, fichier `txt_fr_0_1.txt`). Les attributs sont en **texte libre** : il faudra les extraire et les relier à des sens (WordNet, AAT) dans une étape contrôlée.
- **Pour K** : Iconclass est à la fois un vocabulaire cible (les définitions anglaises que lit le moteur) et une source de vocabulaire français aligné notation par notation. Ses traductions sont faites par des humains (non vérifié). Il ne donne aucune relation lexicale fine (pas de synonymie, pas de sens), mais une hiérarchie de sujets.

### 4.17 Thésaurus Garnier et vocabulaires Joconde

- **Thésaurus iconographique de F. Garnier** (1984) : republié en ligne en **PDF** le 04/06/2020 ; 18 chapitres thématiques (genres, nature, corps, vie sociale, religion, êtres imaginaires, sujets bibliques…), avec un index ; une liste dérivée sur Opentheso (th285) (vérifié : https://www.culture.gouv.fr/thematiques/musees/pour-les-professionnels/conserver-et-gerer-les-collections/informatiser-les-collections-d-un-musee-de-france/vocabulaires-scientifiques-du-service-des-musees-de-france/thesaurus-iconographique-systeme-descriptif-des-representations-de-francois-garnier).
- **Licence du Garnier** : la page indique que le contenu du site est sous Etalab 2.0 sauf mention contraire, mais ne précise pas de licence pour le PDF lui-même. **À confirmer.**
- **16 listes Joconde** (domaines, dénominations, auteurs, écoles, époques, matières et techniques, lieux, représentation…) : sous **Licence ouverte Etalab**, en SKOS, CSV ou PDF sur demande, et consultables sur Opentheso (vérifié : https://www.culture.gouv.fr/thematiques/musees/pour-les-professionnels/conserver-et-gerer-les-collections/informatiser-les-collections-d-un-musee-de-france/vocabulaires-scientifiques-du-service-des-musees-de-france/telecharger-les-vocabulaires-scientifiques-du-service-des-musees-de-france).
- **Pour K** : c'est la terminologie française muséale de référence : dénominations d'objets, techniques (« lavis », « détrempe », « burin »), représentation. C'est un complément naturel de l'AAT pour le français. Un PDF est coûteux à intégrer ; la liste Opentheso dérivée est plus exploitable.

### 4.18 Iconographie chrétienne : attributs des saints

On a trouvé quatre sources exploitables.
1. Les textes d'Iconclass (« attributs possibles », CC0).
2. Wikidata P4185 (CC0), plus incomplet.
3. Les chapitres « religion » et « sujets bibliques » du Garnier, en PDF, sous une licence à confirmer.
4. Les listes de Wikipédia « Saint symbolism », sous CC BY-SA (non vérifié pour leur contenu).

Un travail de recherche (https://arxiv.org/pdf/2102.02732, non ouvert) a constitué à la main une base associant saints et attributs, en notant qu'elle est incomplète.

**Pour K** : la relation « attribut iconographique de » est une **préférence d'identification** (un lion suggère Jérôme ou Marc). Ce n'est pas une exclusion : les attributs varient selon l'époque et la région (non vérifié : Wikipédia).

### 4.19 Autres ressources pertinentes repérées

- **WordNet morpho-semantic links** : `morphosemantic-links.xls`, déjà présent dans les ressources. Ces liens de dérivation sont typés sémantiquement (agent, instrument, résultat…) (vérifié (local) : le fichier existe ; contenu non analysé).
- **NomBank 1.0** : `nombank.1.0.zip`, déjà présent ; structures argumentales des noms anglais (non analysé).
- **Open English Namenet** : noms propres dérivés de Wikidata, publiés avec OEWN 2025 (vérifié).
- **SemLink** : correspondances entre PropBank, VerbNet et FrameNet (mentionné sur le site VerbNet ; vérifié).
- **Tables du Lexique-Grammaire** : LGPL-LR (non vérifié : extrait de recherche).
- **Lexique 3 et Morphalou** : lexiques de formes ; leurs licences ne sont pas vérifiées.

---

## 5. Combinaisons possibles et coût

Les coûts ci-dessous sont des **ordres de grandeur non vérifiés**. Ils supposent environ 20 secondes par couple (lemme, synset) pour un tri manuel avec glose, et le double pour une double annotation.

| # | Combinaison | Ce qu'elle apporte | Coût d'intégration | Coût de relecture | Licence de l'ensemble |
|---|---|---|---|---|---|
| A | **Statu quo** : PWN 3.0 + WOLF/OMW 1.4 | rien de plus | nul | nul | notice Princeton + CeCILL-C |
| B | **PWN 3.0 (ou OEWN 2025) comme inventaire anglais de travail + couche française corrigée** : un vote entre WOLF, WoNeF haute précision et les traductions DBnary, plus une relecture humaine du vocabulaire des bancs ; les rejets sont enregistrés comme faits (« `fr:large` n'exprime pas `large%3:00:00::`, relecture du 28/11 ») | une précision connue sur le vocabulaire réel ; des silences comblés (couronner → *crown*, plan → *foreground*) ; une traçabilité par couple | faible : trois fichiers de couples ; OEWN demande en plus un passage par CILI (moyen) | environ 5 250 couples pour les lemmes de fréquence ≥ 5, soit **~30 h**, ou ~60 h en double annotation ; ~10 150 couples pour tout le vocabulaire présent (~55 h) ; plus l'ajout des 229 lemmes absents | CeCILL-C + LGPL-LR (couches séparables) ; la couche DBnary, si elle est conservée, sous CC BY-SA |
| C | **+ Wikidata (CC0)** pour les noms propres, les alias fr/en, P4185 et P1256 | 45 % des types de noms propres manquent aujourd'hui ; « saint X », Tobie, Salomé, Jean-Baptiste, lieux | moyen : une requête ou un extrait ciblé du dump, gelé avec sa date | faible : contrôle des homonymes (Pierre, Marie, Jacques) | CC0, aucune contrainte |
| D | **+ Iconclass (CC0) + AAT (ODC-By) + listes Joconde (Etalab)** pour le vocabulaire iconographique et technique | sujets et attributs (Iconclass fr à 99,9 %), objets et techniques (AAT, Joconde) | moyen : Iconclass est trivial (texte) ; l'AAT est lourd (N-Triples), à extraire par facettes ; Joconde passe par une demande SKOS | moyen : extraction des « attributs possibles » vers des sens ; correspondances AAT ↔ WordNet à faire, puisqu'aucune n'est fournie | CC0 + attribution Getty + Etalab : compatibles avec une diffusion libre, attributions à porter |
| E | **+ cadres et restrictions** : FrameNet 1.7 et VerbNet 3.3 (anglais) ; Dicovalence, et éventuellement LVF (français) | structures argumentales, rôles, préférences de sélection | moyen : formats XML connus, lecteurs NLTK ; pour le français, la correspondance Dicovalence ↔ synsets n'existe pas | élevé si l'on aligne Dicovalence sur WordNet ; faible en usage seul (valence) | CC BY (FrameNet) + licence VerbNet (à vérifier) + LGPL-LR |
| F | **+ exclusions rédigées dans K** (incompatibilités, disjonctions), chacune avec sa source (antonymie WordNet quand elle existe, sinon justification humaine) | les seules exclusions démontrées utilisables | faible | moyen, au fil des besoins des bancs | propre au projet |
| G | **+ JeuxDeMots** pour les relations typées du français | agents et lieux typiques, associations | moyen à élevé : les sens ne sont pas alignés | élevé | **à clarifier** (CC BY-SA ou autre) |
| — | **BabelNet** | — | — | — | **non libre : exclu** |

**Ce qui n'est pas indépendant.** ConceptNet et BabelNet incorporent OMW, donc WOLF (vérifié pour ConceptNet, §4.9). Pour corroborer un couple WOLF, seuls WoNeF et DBnary/Wiktionnaire sont des sources raisonnablement indépendantes. WoNeF a toutefois appris ses seuils de sélection sur une évaluation manuelle de WOLF 1.0b (vérifié : article WoNeF). L'indépendance est donc partielle.

---

## 6. Risques

1. **Licences non libres ou floues.**
   - BabelNet est réservé à la recherche et non commercial (vérifié) : à exclure.
   - JeuxDeMots : licence contradictoire selon les sources.
   - LVF, VerbNet 3.3, ASFALDA, Verb∋Net : licences non vérifiées.
   - Thésaurus Garnier : licence du PDF non précisée.
2. **Partage à l'identique.** ConceptNet, DBnary/Wiktionnaire et Wikipédia sont sous CC BY-SA, et JeuxDeMots peut-être aussi. Tout fait qui en est dérivé et stocké dans K doit rester dans une couche séparable sous CC BY-SA, sous peine d'imposer cette licence à K entier. CeCILL-C et LGPL-LR imposent la même discipline, en plus faible, pour les modifications de WOLF, WoNeF, Lefff et Dicovalence (non vérifié juridiquement).
3. **Usage hors ligne et redistribution.** Toutes les ressources retenues en B à F permettent un usage hors ligne. Leur redistribution avec le moteur impose des attributions (Princeton, FrameNet, Getty, OEWN), le maintien des licences des couches (CeCILL-C, LGPL-LR), et rien pour CC0. Il faut un fichier `NOTICES` ou `SOURCES` par version de K.
4. **Ressources non maintenues.** Pas de version de WOLF après 1.0b4, avec un hébergement historique (GForge). WoNeF date de 2014, ASFALDA de 2016, Dicovalence 2.0 de 2010, LVF de 2013, et ConceptNet n'est plus actif (non vérifié). Il faut geler des copies locales et les citer par version et empreinte.
5. **Alignements automatiques.** WOLF, WoNeF, BabelNet et ConceptNet sont des projections automatiques ou semi-automatiques à partir d'un pivot anglais. Leurs erreurs sont **systématiques**, pas aléatoires : polysémie du pivot (*large, table, sit, lift, throw, green, cross, palm, virgin*), donc faux amis et sens inverses (« plus » → *less*). Elles se recopient d'une ressource à l'autre.
6. **Dérive des versions.** Passer de PWN 3.0 à OEWN change les identifiants. WOLF et VerbNet sont alignés sur PWN 3.0 (clés de sens 3.0 pour VerbNet, non vérifié en détail). Wikidata évolue en continu : il faut un extrait daté. Getty annonce une migration de plateforme à l'automne 2026 (non vérifié).
7. **Dépendance au lemmatiseur.** Sur le même corpus, spaCy `sm` et Stanza donnent 31,9 % et 13,8 % de types absents (§2.1). Une mesure de couverture, ou une décision de K, ne doit pas dépendre d'un lemmatiseur non figé. Un lemmatiseur fondé sur un dictionnaire (Lefff) rendrait ce point reproductible.
8. **Confusion entre préférences et exclusions.** Restrictions de sélection (VerbNet), attributs des saints (Iconclass, Wikidata) et ordre des sens sont des préférences. Les traiter comme des exclusions écarterait à tort des lectures iconographiques légitimes : allégories, personnifications, attributs variant selon l'époque.

---

## 7. Recommandation (**proposition**, rien n'est décidé)

1. **Ontologie de travail propre à K.** Les types du raisonnement seraient définis dans K et reliés à des synsets WordNet (PWN 3.0 dans un premier temps ; OEWN 2025 plus tard, via CILI), à des entités Wikidata, à des concepts AAT et à des notations Iconclass. WordNet et WOLF resteraient des **sources de faits** étiquetées (ressource, version, identifiant, statut). Aucune ne serait l'ontologie.
2. **Couche française corrigée.** Chaque couple WOLF garderait le statut « proposé par WOLF ». On lui ajouterait un vote avec WoNeF haute précision et les traductions DBnary, puis une **relecture humaine** du vocabulaire des bancs, en commençant par les 639 lemmes de fréquence ≥ 5 (environ 5 250 couples). Les rejets seraient enregistrés comme faits sourcés, et les absences signalées comme « inconnu », jamais comme exclusions.
3. **Noms propres et vocabulaire iconographique.**
   - Un extrait daté de **Wikidata** (CC0) pour les saints, les personnages bibliques et mythologiques et les lieux, avec les alias fr/en, P4185 et P1256.
   - **Iconclass** (CC0) en français et en anglais pour les sujets et les attributs.
   - **AAT** (ODC-By) et les **listes Joconde** (Etalab) pour les objets et les techniques.
4. **Cadres et préférences.** FrameNet 1.7 et VerbNet 3.3 pour l'anglais, Dicovalence pour la valence française. Leurs restrictions de sélection n'entreraient que comme **préférences**. Les **exclusions** seraient rédigées dans K, une à une, avec leur justification.
5. **Écarts et vérifications préalables.**
   - Écarter BabelNet.
   - Ne pas compter ConceptNet ni BabelNet comme corroboration de WOLF.
   - Avant tout usage, confirmer par écrit les licences de JeuxDeMots, LVF, VerbNet 3.3, ASFALDA et du PDF Garnier.
   - Prochaines mesures : couverture française de l'AAT et de DBnary sur les 229 lemmes absents ; taux d'accord WOLF/WoNeF/DBnary sur l'échantillon du §2.5.

---

## 8. Références

Les pages marquées « vérifié » ont été consultées le 28/11/2026.

**WordNet, wordnets et alignements**
- Princeton WordNet 3.0 : fichiers `LICENSE`, `dict/frames.vrb` et `index.*` (vérifié (local), `/home/user/donnees/WordNet-3.0/`).
- WOLF : https://almanach.inria.fr/software_and_resources/custom/WOLF-en.html et http://pauillac.inria.fr/~sagot/index.html#wolf (vérifié) ; Sagot B. et Fišer D., « Building a free French wordnet from multilingual resources », LREC 2008 (`citation.bib` local, vérifié (local)).
- OMW 1.4, WOLF : `/home/user/donnees/ressources/omw/omw-1.4/fra/` (`wn-data-fra.tab`, `LICENSE`, `citation.bib`) et `omw-1.4/README` (vérifié (local)).
- Pradet Q., de Chalendar G., Baguenier Desormeaux J., « WoNeF, an improved, expanded and evaluated automatic French translation of WordNet », GWC 2014 : https://aclanthology.org/W14-0105.pdf (vérifié).
- Open English WordNet : https://en-word.net/downloads et https://github.com/globalwordnet/english-wordnet (vérifié).
- OMW 2 et CILI : https://omwn.org/ et https://raw.githubusercontent.com/omwn/omw-data/main/index.toml (vérifié).

**Ressources contributives et multilingues**
- BabelNet Non-Commercial License : https://babelnet.org/full-license (vérifié).
- ConceptNet, licence : https://github.com/commonsense/conceptnet5/wiki/Copying-and-sharing-ConceptNet (vérifié) ; entrée https://conceptnet.io/c/fr/vierge (vérifié).
- DBnary : https://kaiko.getalp.org/about-dbnary/ (vérifié).
- JeuxDeMots : https://linuxfr.org/news/jeuxdemots-un-jeu-en-ligne-pour-produire-des-donnees-lexicales (vérifié) ; https://www.jeuxdemots.org/jdm-about.php (vérifié, sans texte de licence).

**Cadres, valence et lexiques**
- FrameNet 1.7 : `framenet_v17.zip` (README, `GeneralReleaseNotes1.7.pdf`, `frRelation.xml`, index) (vérifié (local)).
- ASFALDA : https://aclanthology.org/L16-1601/ (non vérifié : extrait de recherche ; site du projet injoignable).
- VerbNet : https://verbs.colorado.edu/verbnet/ (vérifié) ; `verbnet-3.3.tar.gz` (vérifié (local)).
- Verb∋Net : https://aclanthology.org/L14-1204/ (non vérifié : extrait de recherche).
- Lefff : https://huggingface.co/datasets/sagot/lefff_morpho/blob/main/README.md (vérifié).
- Dicovalence : https://listserv.linguistlist.org/pipermail/linguist/2006-December/033321.html (vérifié).
- LVF : https://talep-archives.lis-lab.fr/FondamenTAL/Bibliographie_Jean_Dubois.pdf (non vérifié : extrait de recherche).

**Entités et vocabulaires du patrimoine**
- Wikidata : https://www.wikidata.org/wiki/Wikidata:Licensing, https://www.wikidata.org/wiki/Property:P4185, https://www.wikidata.org/wiki/Property:P1354 et https://www.wikidata.org/wiki/Q44248 (vérifié).
- Iconclass : https://github.com/iconclass/data et https://github.com/iconclass/data/tree/main/txt (vérifié) ; fichiers `txt/fr` et `txt/en` téléchargés et mesurés (mesuré).
- Getty Vocabularies, LOD et licence : https://www.getty.edu/research/tools/vocabularies/lod/ (non vérifié : page non lisible par l'outil, extrait de recherche concordant).
- Thésaurus Garnier : https://www.culture.gouv.fr/thematiques/musees/pour-les-professionnels/conserver-et-gerer-les-collections/informatiser-les-collections-d-un-musee-de-france/vocabulaires-scientifiques-du-service-des-musees-de-france/thesaurus-iconographique-systeme-descriptif-des-representations-de-francois-garnier (vérifié).
- Vocabulaires Joconde : https://www.culture.gouv.fr/thematiques/musees/pour-les-professionnels/conserver-et-gerer-les-collections/informatiser-les-collections-d-un-musee-de-france/vocabulaires-scientifiques-du-service-des-musees-de-france/telecharger-les-vocabulaires-scientifiques-du-service-des-musees-de-france (vérifié).

**Outils de la mesure locale**
- Stanza 1.10.1, modèles `fr` par défaut (téléchargés depuis huggingface.co/stanfordnlp/stanza-fr) ; spaCy 3.8 avec `fr_core_news_sm` 3.8.0, essayé puis écarté.
- `sens_fr.py` (exécution seule).
- Scripts et sorties de la mesure dans le répertoire de travail de la session : `extraire.py`, `mesurer_stanza.py`, `analyse2.py`, `mwe.py`, `echantillon.txt`, `empreintes.txt`. Ce répertoire n'est pas durable.
