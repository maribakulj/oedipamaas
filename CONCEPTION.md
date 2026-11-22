# oedipamaas : document de conception

Version 0.2. Statut : conception arrêtée, construction en cours.

oedipamaas est un moteur iconographique. Il lit ce qu'un grand modèle de vision-langage (le **descripteur**) dit d'une
image, en mots, et le traduit en codes [Iconclass](https://iconclass.org), chaque code avec sa preuve. Les codes, avec
les objets et les relations situés dans l'image, servent de données d'entraînement à des modèles rapides.

La description est l'étape chère : elle est faite une fois par image. Le moteur, lui, ne coûte presque rien : il doit
pouvoir être amélioré puis rejoué sur toutes les descriptions déjà faites, sans appel payant.

## 0. En bref

**Principe : un moteur pour tout corpus et tout le vocabulaire d'Iconclass.** Ce qui décide ne vient que de trois
sources : la structure et les textes d'Iconclass, Wikidata (P1256), et quelques faits de langue documentés une fois
(pluriel, graphie, honorifiques). Les règles mesurent, elles ne filtrent pas : aucune constante de décision n'est écrite
à la main, aucune liste propre à un corpus, aucun correctif tiré d'une image vue. La décision est apprise à partir de
traits qui décrivent la preuve (jamais « ce que tel catalogue contient d'habitude »), et sa généralité se mesure hors
corpus : apprendre sur un corpus, mesurer sur un autre.

1. **Lire toute la description.** Le descripteur dit le sujet et sa source, les personnes, les objets avec leur boîte,
   les relations, les actions, les gestes et émotions, les concepts, les rôles, le cadre, les textes transcrits, le
   genre et la fonction. Chaque champ est lu et dirigé vers les chapitres d'Iconclass où il a du sens.
2. **Ne pas écrire de culture à la main : la compiler depuis Iconclass.** Iconclass contient déjà le raisonnement de
   l'iconographe : les libellés de 227 saints donnent leurs attributs possibles (« lion, skull, cardinal's hat… »),
   1 007 libellés citent leur source (1 244 références, passages bibliques comme « 1 Samuel 17 » ou d'Ovide), et
   chaque saint suit le même gabarit de vie (en groupe, jeunesse, miracles, martyre, portrait…). Les règles sont tirées de ces
   textes par programme.
3. **Chercher les candidats par le sens autant que par les mots.** Le descripteur écrit « David beheading Goliath »,
   Iconclass « David beheads Goliath with a sword » ; ailleurs, les mots diffèrent tout à fait pour un même sens. Une
   recherche sémantique (vecteurs de sens d'un modèle de phrases local) s'ajoute à la recherche lexicale.
4. **Prolog vérifie et combine, il ne cherche pas.** Python trouve les candidats. SWI-Prolog garde la base Iconclass et
   les règles : un saint nommé doit être appuyé par un fait, un épisode doit retrouver ses participants dans l'image,
   des frères à égalité se replient sur leur parent commun. La dérivation Prolog *est* la preuve du code.
5. **Deux probabilités par code.** `p_catalogue` : un catalogueur l'aurait-il écrit ? `p_juste` : le code est-il vrai
   de l'image ? Les catalogues sont incomplets ; la seconde se corrige par un jugement à l'aveugle.
6. **Rejouable.** Aucun appel à un modèle payant dans le moteur. Base, règles, poids et modèle de phrases sont
   versionnés ; mêmes entrées, mêmes octets en sortie.

## 1. But et périmètre

Le moteur fait :

- lire une description (format § 12) ;
- proposer des notations Iconclass candidates pour chaque élément de la description ;
- les vérifier, les combiner, en garder certaines, chacune avec un score, ses deux probabilités et sa preuve ;
- rattacher des codes aux objets situés (boîtes) et aux relations ;
- dire quelle partie de la description n'a servi à rien.

Il ne fait pas :

- regarder l'image (seul le descripteur la regarde, une fois) ;
- demander des codes au descripteur, ni appeler un modèle de langue ;
- tourner en production : ses sorties sont des données d'entraînement.

## 2. Pourquoi ces choix

Un premier prototype purement lexical (un terme de la description égal à la fin d'un libellé ou à un mot clé
d'Iconclass) montre trois choses :

- **la correspondance d'un mot isolé produit beaucoup de codes et peu de justes** : un mot n'a de sens qu'avec son
  contexte (le champ d'où il vient, ce qui l'appuie dans l'image) ;
- **les noms et le sujet sont les indices les plus sûrs** : l'identification d'une personne est la famille de règles
  la plus précise ;
- **les récits échappent aux mots** : dans la Bible, la littérature et la mythologie, la description contient souvent
  de quoi trouver le code, mais pas sous la forme du libellé. Il faut le sens, et les références de source.

Les bons codes sont souvent parmi les candidats, mais mal classés : le classement (un score calibré) est un levier à
part entière.

## 3. Architecture

```
description (JSON)
   │
   │  1. LECTURE (Python) : chaque champ devient des « mentions »
   │     mention = texte, champ, chemin JSON, confiance du descripteur, entité et boîte s'il y en a
   ▼
mentions ──► 2. RECHERCHE (Python) : candidats par mention
   │            index lexical (libellés, mots clés, noms, toutes langues)
   │            index sémantique (vecteurs de sens des libellés)
   │            routage : chaque champ vers ses chapitres (§ 5.2)
   ▼
faits d'image + candidats ──► 3. RAISONNEMENT (SWI-Prolog, base Iconclass compilée)
                                 vérifie, combine, exclut ; chaque appui garde ses faits
                                      │
                                      ▼
                               4. SCORE (Python) : score, hiérarchie (descendant ou parent,
                                  repli des récits à égalité, un seul sujet), p_catalogue, p_juste
                                      │
                                      ▼
                               5. SORTIE : codes.jsonl (codes, objets, relations, preuves,
                                  matériel non utilisé, versions)
```

Python et Prolog dans le même processus, par Janus (le pont Python ↔ SWI-Prolog livré avec SWI-Prolog). La base est
chargée une fois, compilée (`.qlf`) ; les faits de chaque image sont ajoutés, interrogés, retirés.

Pourquoi Prolog : les règles se lisent comme des phrases, la hiérarchie se parcourt naturellement, et la dérivation
d'un code donne sa preuve sans code supplémentaire. Pourquoi pas tout en Prolog : la recherche de voisins dans des
vecteurs et l'apprentissage des poids sont plus simples et plus rapides en Python.

## 4. Les connaissances : la base compilée

Une seule commande (`oedipamaas base`) construit la base depuis des sources épinglées ; la base porte l'empreinte de
chacune.

### 4.1 Iconclass (dépôt iconclass/data, CC0, commit épinglé)

| Ce qu'on en tire | Contenu | Sert à |
|---|---|---|
| Hiérarchie | 40 716 notations, parents, ancêtres pré-calculés, profondeur | cohérence, repli, crédit hiérarchique |
| Libellés et mots clés | anglais d'abord ; toutes les langues du dépôt ensuite | recherche lexicale ; noms et textes transcrits dans d'autres langues (« Hieronymus ») |
| Noms propres | noms entre parenthèses (JEROME), noms des libellés et mots clés (« Jerome (St.) ») | index des noms (famille B) |
| Attributs des saints | 227 saints à « possible attributes: … », chaque attribut pondéré par sa rareté | famille C |
| Références de source | 1 244 références dans 1 007 libellés (livre biblique, chapitre, versets ; Ovide, livre, vers) | famille D : la source donnée par le descripteur désigne directement une branche |
| Gabarits | structure commune des vies de saints (`11H(...)0` en groupe … `9` portrait) | famille E |
| Renvois | renvois entre notations | voisinage de recherche, jamais un code seul |
| Clés (+…) et noms libres (...) | 58 familles de clés, 2 780 clés (textes et mots clés) ; 1 184 gabarits à nom libre | codes à clé et gabarits instanciés, en option (§ 7.1) |
| Autres langues | libellés et mots clés des 12 autres langues du dépôt | expressions exactes (textes transcrits, descriptions dans une autre langue) |

Le libellé d'un code narratif contient souvent sa vérification : « 11H(JEROME)36 : St. Jerome as penitent in the
desert, half naked, kneeling before a crucifix and holding a stone… ; a skull… ». Les noms et les noms communs d'un
libellé sont extraits par programme comme ses **participants** attendus.

### 4.2 Wikidata (CC0)

- Propriété **P1256** « Iconclass notation » (environ 4 200 éléments : saints, personnages, thèmes) : on en tire les
  **alias multilingues** de ces éléments (Jérôme, Girolamo, Hieronymus…) vers la notation. Instantané daté, figé dans
  la base.
- Propriété **P1257** « depicts Iconclass notation » : **exclue**. Elle porte sur des œuvres ; certaines peuvent
  appartenir aux ensembles d'évaluation. L'utiliser ferait entrer la vérité de la mesure dans le moteur.

### 4.3 Le modèle de phrases (index sémantique)

Chaque notation est représentée par un vecteur de sens calculé sur « libellé + mots clés » (et le libellé du parent
pour les libellés courts). Candidats comparés, tous libres et utilisables hors ligne :

| Modèle | Paramètres | Licence |
|---|---|---|
| paraphrase-multilingual-MiniLM-L12-v2 | 118 M | Apache-2.0 |
| LaBSE | 471 M | Apache-2.0 |
| bge-m3 | 568 M | MIT |
| multilingual-e5-large | 560 M | MIT |

Les vecteurs d'Iconclass sont calculés une fois et versionnés avec la révision du modèle (40 716 × 1 024 en
demi-précision ≈ 80 Mo). Les vecteurs des mentions sont mis en cache par empreinte du texte.

### 4.4 Ce qui est écrit à la main

Seulement : la table de routage des champs (§ 5.2), la normalisation des noms (« Saint X » → X, « the Virgin » → Marie),
quelques synonymes de graphie (anglais américain → britannique), et des exceptions. Chaque exception est une clause
d'un seul fichier `regles/exceptions.pl`, avec un test et la mesure qui la justifie. Pas de liste de saints, d'épisodes
ou de symboles écrite à la main.

Pas de fréquences de catalogue dans le moteur : il reste indépendant des étiquettes, qui ne servent qu'à apprendre
quelques poids (§ 7).

## 5. La recherche des candidats

### 5.1 Lexicale et sémantique, les deux

- **Lexicale** : expression égale à un mot clé ou à la fin d'un libellé, tous les mots pleins d'un libellé présents,
  nom propre en mot entier. Précise quand elle touche, aveugle aux reformulations.
- **Sémantique** : les k plus proches libellés d'une mention dans l'espace des vecteurs. Trouve les reformulations,
  mais confond facilement des frères : 71H1443 « David beheads Goliath with a sword » et 71H145 « David with Goliath's
  head » sont tout près l'un de l'autre.
- **Fusion** : rang réciproque (somme de 1/(60 + rang) sur les deux listes), puis la vérification Prolog départage.

Règle de choix écrite d'avance, par champ, sur l'ensemble de développement : on garde la recherche sémantique pour un
champ si son rappel à 20 candidats (même branche) dépasse celui de la lexicale d'au moins 5 points ; la fusion si elle
ajoute au moins 3 points à la meilleure des deux ; sinon la lexicale seule.

### 5.2 Le champ d'origine : un trait, pas un filtre

Chaque mention interroge toutes les notations. Le champ d'où vient une preuve (sujet, personne, entité, relation,
action, geste, concept, rôle, cadre, texte, genre, mot clé) devient un trait du code ; c'est la décision apprise qui
dit ce que vaut, par exemple, un récit biblique proposé seulement par un objet. Le tableau ci-dessous dit ce qu'on
attend de chaque champ ; il n'est pas appliqué comme une règle.

| Champ | Chapitres visés d'abord | Ce que le moteur en fait |
|---|---|---|
| `subject.title`, `subject.alternatives` | 7 (Bible), 9 (mythologie), 8 (littérature), 11H/11HH (vies de saints), 61 (événements), 5 (allégories) | recherche sémantique ; candidats narratifs à vérifier (famille D) |
| `subject.source` | 7, 9, 8 | référence analysée (livre, chapitre, vers) comparée aux 1 244 références d'Iconclass |
| `subject.type` | aucun code seul | oriente le routage (récit biblique → 7 ; portrait → 61B, 31D ; paysage → 25H…) |
| `persons.who` | 11 (Christ, Marie, saints), 7 (personnages bibliques), 9 (dieux, héros), 82 (personnages littéraires), 61B (personnes historiques) | index des noms d'abord ; rôle sans nom → 3 et 4 |
| `persons.recognised_by` | aucun code seul | preuves d'appui pour vérifier un nom (familles B, C) |
| `entities` (type, attributs) | 2 (25F animaux, 25G plantes), 3 (31A corps, 31D âges), 4, 25-49 objets | lexicale + sémantique ; codes rattachés à l'entité et à sa boîte |
| `relations` | 33 (relations entre personnes), 34 (homme et animal), 46C (transport), 4 | la phrase « sujet relation objet » est cherchée ; les deux entités doivent exister |
| `actions` | 3, 4 (43 loisirs, 45 guerre, 47 métiers) ; vérification des épisodes 7-9 | sémantique |
| `gestures_emotions` | 31A23 (postures), 31A25 (gestes des bras et des mains), 56 (émotion) | sémantique |
| `concepts` | 5 (idées abstraites, personnifications), 1 | sémantique ; une personnification exige une figure dans les entités |
| `roles` | 32 (types humains), 4 (44 État, 45 militaires, 47 métiers) | lexicale + sémantique |
| `setting` | 25H (paysages), 25I (vues de ville), 23 (temps : mois, saisons, heures), 26 (météo), 41A (habitat) | lexicale + sémantique |
| `texts` | 49L8 (inscription) ; noms inscrits → 61B, 61E, 11H ; citations bibliques → 7 | noms et citations ; langue donnée par le descripteur |
| `genre_function` | 48 (art), 49M (imprimés, livres) | lexicale |
| `keywords` | 2, 4, 25-49 | lexicale + sémantique, poids plus faible |
| `period_style` | aucun | contexte seulement |

## 6. Le raisonnement symbolique

### 6.1 Les règles mesurent

Chaque règle Prolog rend un **trait** d'une notation : une quantité, avec les mentions qui la fondent. Aucune ne
retient ni n'écarte un code sur un seuil écrit à la main.

| Trait | Ce qu'il mesure | Source |
|---|---|---|
| similarités | cosinus et BM25 normalisé entre une mention et le libellé, selon que la mention vient du sujet ou d'ailleurs | recherche (§ 5) |
| couvertures | part pondérée par la rareté des mots de la mention couverte par la notation, et du libellé couverte par la mention | idem |
| expression exacte | la mention est un mot clé, la tête du libellé ou un alias Wikidata ; poids décroissant avec le nombre de notations qui la portent | Iconclass, Wikidata |
| nom | un nom propre d'Iconclass ou de Wikidata est dans la description ; contexte : personne nommée, honorifique devant (« saint… »), suivi d'un nombre (une référence), libre | idem |
| attributs | attributs possibles du saint vus dans la description : somme de leur rareté, nombre, part | libellés d'Iconclass |
| source | la référence donnée (« 1 Samuel 17 ») est celle de la notation, ou celle d'une histoire dont elle est un épisode | libellés d'Iconclass |
| participants | part des noms et mots clés du libellé narratif retrouvés hors des champs du sujet | idem |
| ancêtres reconnus | des mots clés ou têtes des ancêtres de la notation sont dans la description, et à quelle profondeur | hiérarchie d'Iconclass |
| identité héritée | un épisode de la vie d'un saint (11H(X)n) porte les traits de nom et d'attributs de X | structure d'Iconclass |
| structure | profondeur, récit ou non, descendants et frères parmi les candidats, champs d'où vient la preuve | idem |
| entités situées (option) | l'entité de la description qui propose le code : aire de sa boîte rapportée à la plus grande de l'image, proximité du centre, plan ; nombre d'entités distinctes qui l'appuient | boîtes de la description |
| relations (option) | une relation entre entités dont un bout ou les deux appuient le code, avec ou sans son prédicat (« beheads », « holds ») dans le libellé | relations de la description |

Une seule contrainte, structurelle : un code à nom propre (et ses sous-rubriques) affirme une identité ; sans nom ni
attribut vus, il n'est pas proposé. Le **repli sur le parent sûr** est aussi structurel : les ancêtres (deux niveaux) des
meilleurs codes deviennent candidats, avec les traits de leur descendant ; la décision apprend quand le plus général
est le meilleur pari. La projection finale garde le plus précis des codes retenus d'une même branche.

### 6.2 Compilé, documenté, appris

- **Compilé** : tout ce qui est culture (qui est qui, quel attribut, quel épisode, quelle source) vient d'Iconclass
  et de Wikidata, par programme.
- **Documenté une fois** : quelques faits de langue (pluriel, graphie britannique, honorifiques), sans rapport avec un
  corpus.
- **Appris** : la décision (§ 7), seulement à partir des traits, et validée hors corpus.

### 6.3 Ce que vérifie la vérification

Le descripteur *affirme* un sujet. Le moteur le croit d'autant plus que l'image le confirme : un épisode dont les
participants sont présents, un saint dont les attributs sont visibles. Un sujet sans appui reste candidat avec une
probabilité basse. Les alternatives du descripteur servent deux fois : comme candidats, et comme signal d'incertitude
(si plusieurs alternatives tombent dans la même branche, le parent commun est sûr).

## 7. Score, seuil et preuve

### 7.1 Le score

Chaque candidat retenu par le raisonnement porte quelques nombres (ses « traits », écrits dans la sortie) : contribution
de chaque règle, mesures brutes de la recherche (meilleur cosinus, couverture lexicale pondérée par la rareté des mots,
meilleur rang), confiance du descripteur, nombre de familles et de mentions qui l'appuient, profondeur et chapitre de la
notation, repli sur un ancêtre et nombre de descendants appuyés. Une **régression logistique** (quelques dizaines de poids, lisibles) les transforme en probabilités :

- `p_catalogue` : probabilité que le code (ou un de ses descendants) soit dans le catalogue de l'image, apprise sur un
  ensemble de développement étiqueté. Seuls les poids entrent dans le dépôt (`poids/vN.json`).
- `p_juste` : probabilité que le code soit vrai de l'image. Le catalogue étant incomplet, `p_catalogue` la sous-estime.
  On la corrige par famille avec le jugement à l'aveugle (§ 9.3).

La logistique est la décision par défaut : quelques centaines d'images ne nourrissent pas plus de quelques dizaines de
poids sans sur-apprentissage, et un poids se lit. Des arbres de gradient (profondeur 3) peuvent la remplacer
(`--decision arbres`) : ils sont appris avec elle, exportés dans le même fichier en JSON (évaluables sans bibliothèque,
relecture vérifiée à l'export) et gardent leur propre règle (k, seuil, critère). On choisit l'une ou l'autre sur une
mesure hors corpus.

Deux mécanismes généraux existent mais sont désactivés par défaut, faute de gain mesuré sur un premier corpus : les
**clés** (`--cles` : une clé d'Iconclass évoquée par la description donne le code à clé) et les **noms libres**
(`--gabarits` : un gabarit « with NAME » reçoit le nom d'une mention). Ils restent à rejuger quand le rappel des codes
de base aura progressé, car c'est lui qui les limite. La **structure de l'image** (`--structure-image` : entités
situées et relations, § 6.1) est désactivée jusqu'à sa mesure : sur un même découpage des images, la calibration avec
et sans ces traits, rien d'autre ne change.

### 7.2 Les seuils

- Pour la mesure contre le catalogue : seuil et nombre maximal de codes choisis sur une moitié de l'ensemble de
  développement, vérifiés sur l'autre moitié (partage par image, graine fixe). Jamais réglés sur l'ensemble de mesure.
- Pour l'entraînement : deux ensembles livrés, « style catalogue » (`p_catalogue` ≥ seuil) et « complet »
  (`p_juste` ≥ 0,5), et les probabilités elles-mêmes pour des cibles souples.

### 7.3 La preuve

Chaque code porte sa preuve : pour chaque appui, la règle, les faits cités tels que le descripteur les a écrits avec
leur chemin dans la description, le texte Iconclass reconnu, et la contribution au score. Une phrase la résume. La
commande `oedipamaas expliquer IMAGE CODE` affiche l'arbre entier, y compris pour un code écarté (et pourquoi).

## 8. Le format de sortie

Une ligne JSON par image dans `codes.jsonl`, plus un `manifeste.json` par lot (versions, comptes, empreintes des
descriptions lues, durée). Exemple **illustratif** (valeurs inventées, pour montrer la forme) :

```json
{"image": "exemple-0001",
 "versions": {"moteur": "0.1.0+g1a2b3c4", "base": "iconclass <commit> ; wikidata <date> ; <modèle> <révision>",
              "poids": "v1", "consigne": "v2 sha256:…", "description": "sha256:…"},
 "codes": [
  {"code": "11H(JEROME)", "statut": "retenu", "score": 2.31, "p_catalogue": 0.62, "p_juste": 0.88,
   "preuves": [
    {"regle": "B.nom", "faits": [{"chemin": "persons[0].who", "texte": "Saint Jerome"}],
     "iconclass": "Jerome (St.)", "contribution": 1.4},
    {"regle": "C.attributs", "faits": [{"chemin": "entities[3].type", "texte": "lion"},
                                       {"chemin": "keywords[12]", "texte": "cardinal's hat"}],
     "iconclass": "possible attributes: book, cardinal's hat, crucifix, hour-glass, lion, skull, stone",
     "contribution": 0.9}],
   "explication": "Saint nommé dans la description ; 2 de ses 7 attributs Iconclass sont visibles."}],
 "objets": [{"id": "e4", "type": "lion", "boite": [0.61, 0.55, 0.93, 0.97], "plan": "foreground",
             "codes": ["25F23(LION)"]}],
 "relations": [{"sujet": "e1", "relation": "looks_at", "objet": "e4", "codes": []}],
 "non_utilise": {"mentions": 37, "par_champ": {"keywords": 21, "setting": 4, "concepts": 2}}}
```

- **Statuts** : `retenu` (au-dessus du seuil) ou `candidat` (gardé pour l'explication et les cibles souples).
- **Codes** : notation Iconclass telle qu'elle est dans la base ; toute projection propre à une mesure reste du côté
  de la mesure.
- **Schéma** : `schemas/codes.schema.json`, versionné ; toute sortie est validée avant d'être écrite.
- **Déterminisme** : tri stable, nombres arrondis à 4 décimales, pas d'aléa. Test : deux passes, mêmes octets.
- **Description illisible** : ligne avec `"erreur"` et aucun code, comptée dans le manifeste.

## 9. L'évaluation, et ce qui compte comme « juste »

### 9.1 Trois niveaux de « juste »

| Niveau | Définition | Comment on le mesure |
|---|---|---|
| exact | même notation que le catalogue | contre les étiquettes |
| branche | ancêtre ou descendant d'un code du catalogue (crédit partiel du F1 hiérarchique) | contre les étiquettes |
| juste | le code dit vrai de l'image, à son niveau de généralité, qu'il soit au catalogue ou non | jugement à l'aveugle |

### 9.2 Les mesures

| Mesure | Question |
|---|---|
| rappel du catalogue, exact et branche, par chapitre | retrouve-t-on ce que le catalogue a ? |
| F1 hiérarchique, précision et rappel, par chapitre et par famille | les codes retenus sont-ils ceux du catalogue ? |
| précision réelle | les codes absents du catalogue sont-ils justes ? |
| couverture | la description est-elle utilisée ? (champ `non_utilise`, sans étiquette) |
| vitesse | rejouer est-il gratuit ? But : ≤ 1 s par image sur un processeur, dont ≤ 50 ms de Prolog |

Les étiquettes ne sont jamais lues sur le poste de développement : les mesures qui en ont besoin tournent sur une
machine de calcul séparée et ne renvoient que des agrégats. Deux ensembles : un ensemble de **développement** (règles,
poids, seuils) et un ensemble de **mesure** fixe, sur lequel rien n'est réglé.

### 9.3 Le jugement à l'aveugle

Il faut estimer la part des codes « hors catalogue » qui sont justes, sans ouvrir les étiquettes.

1. On tire 40 images de développement (graine fixe). On prend **tous** les codes retenus par le moteur pour ces images
   (≈ 200), sans savoir lesquels sont au catalogue.
2. On ajoute 30 leurres : des codes retenus pour *d'autres* images, du même chapitre. Ils mesurent l'indulgence du juge.
3. Le juge voit l'image et le libellé Iconclass, dans un ordre mélangé, sans savoir d'où vient le code. Il répond :
   juste / juste mais trop général / faux / ne sait pas.
4. Les réponses sont jointes aux étiquettes sur la machine de calcul. Ne reviennent que des agrégats : part de justes
   parmi les codes hors catalogue, parmi les codes au catalogue (contrôle : elle doit être haute), parmi les leurres
   (contrôle : elle doit être basse), par famille et par chapitre.

Avec ≈ 100 codes hors catalogue, la part de justes est connue à ± 10 points (intervalle à 95 %). Le juge est un humain ;
jamais un modèle de langue (le descripteur se jugerait lui-même).

### 9.4 Ce que les ensembles peuvent dire

- 300 images (≈ 1 350 codes vrais) : un écart de rappel d'environ 4 points se lit, en tenant compte des codes d'une
  même image, qui ne sont pas indépendants.
- 30 images : seulement les écarts de plus de 8 à 10 points.

## 10. Le dépôt et le code

```
oedipamaas/
  CONCEPTION.md            ce document
  README.md
  pyproject.toml           Python ≥ 3.12, dépendances épinglées
  oedipamaas/
    base/                  sources épinglées → base compilée (faits Prolog .qlf, index, vecteurs)
    lecture/               description → mentions
    recherche/             index lexical, index sémantique, routage, fusion
    regles/                *.pl : familles A-J, exceptions.pl
    score/                 traits, logistique, seuils
    sortie/                codes.jsonl, manifeste, validation du schéma
    cli.py                 oedipamaas base | coder | expliquer
  schemas/                 codes.schema.json, description.schema.json
  poids/                   v1.json … (poids appris, aucune étiquette)
  tests/                   descriptions synthétiques, déterminisme, schéma, vitesse
```

- **Tests sans étiquettes** : descriptions écrites pour les tests (saint Jérôme et son lion, David et Goliath avec sa
  source, une Annonciation sans nom, un paysage, un portrait avec inscription), chacune avec les codes attendus ;
  déterminisme ; validation du schéma ; vitesse.
- **Aucune donnée dans le dépôt** : ni image, ni description, ni étiquette, ni sortie. La base compilée se reconstruit
  par `oedipamaas base` ; ses gros fichiers (vecteurs) ne sont pas suivis par git.
- **Licences des sources** : Iconclass et Wikidata CC0 ; modèles de phrases Apache-2.0 ou MIT ; SWI-Prolog BSD-2.

## 11. Feuille de route

| Phase | Contenu |
|---|---|
| 1 | base anglaise compilée (hiérarchie, noms, attributs, références, gabarits) ; lecture des descriptions ; familles A (lexicale), B, C, D, I ; sortie `codes.jsonl` ; tests |
| 2 | index sémantique, comparaison des modèles par champ et par chapitre, fusion |
| 3 | calibration (`p_catalogue`), seuils |
| 4 | familles E, F, G, H, J ; base multilingue et alias Wikidata ; clés et noms libres si leur part le justifie |
| 5 | jugement à l'aveugle, `p_juste` |
| 6 | durcissement : installation neuve, documentation, version 1.0 |

## 12. Interface

**Entrée** : un fichier JSON par image. Le champ `brut` contient la réponse du descripteur, un objet JSON aux clés
suivantes (listes vides ou `null` quand rien ne s'applique) :

| Clé | Contenu |
|---|---|
| `subject` | `title`, `source`, `type`, `confidence`, `alternatives` |
| `persons` | liste de `who`, `recognised_by`, `confidence` |
| `entities` | liste de `id`, `type`, `attributes`, `plane`, `position`, `box` (fractions de la largeur et de la hauteur) |
| `relations` | triplets `[sujet, relation, objet]` |
| `actions`, `gestures_emotions`, `concepts`, `roles`, `setting`, `genre_function`, `keywords` | listes de courtes expressions anglaises |
| `texts` | liste de `transcription`, `language` |
| `period_style` | texte ou `null` |

Une description de l'ancien format (`entities`, `relations`, `scene`, `identification`) est lue par un adaptateur.

**Sortie** : `codes.jsonl` + `manifeste.json` (§ 8).

## 13. Risques et parades

| Risque | Parade |
|---|---|
| Le descripteur affirme un sujet célèbre que l'image ne montre pas | vérification par les participants (D) ; probabilité basse sans appui ; alternatives |
| Le descripteur reconnaît l'œuvre et récite ce qu'il en sait | chiffres séparés selon que la description nomme l'œuvre ou l'artiste ; rien n'est réglé sur l'ensemble de mesure |
| La recherche sémantique confond des frères | vérification, puis repli sur le parent commun (I) |
| Noms ambigus (Jean le Baptiste / l'Évangéliste) | un nom seul ne suffit pas : attributs et contexte exigés (B, C) |
| Le style du catalogue n'est pas la vérité | deux probabilités ; jugement à l'aveugle |
| Fuite de l'évaluation dans le moteur | P1257 exclue ; aucun réglage sur l'ensemble de mesure |
| Sur-apprentissage des poids | logistique à peu de poids ; deux moitiés de l'ensemble de développement |
| Trop de familles, pas assez de gain | une famille reste si elle ajoute sur l'ensemble de développement ; sinon elle est retirée |
