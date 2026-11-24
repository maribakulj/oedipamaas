# oedipamaas : document de conception

> **Historique.** Ce document décrit la version 1.0 (lecture du JSON d'un descripteur d'images, recherche de
> candidats, traits, décision apprise). Il est remplacé par `CAHIER_DES_CHARGES.md` et `docs/FONDEMENTS.md` ; ce qui en
> reste dans le code est listé dans `docs/HISTORIQUE.md`.

Version 1.0. Statut : conception arrêtée après étude ; reconstruction en cours. Le code de la version 0.2 (recherche en
Python, modèle de phrases, décision logistique) reste dans l'historique comme ligne de base ; la version 1.0 le
remplace pièce par pièce, dans l'ordre du § 12.

oedipamaas est un moteur iconographique. Il lit ce qu'un grand modèle de vision-langage (le **descripteur**) dit d'une
image, en mots, et le traduit en codes [Iconclass](https://iconclass.org), chaque code avec sa preuve. Les codes, avec
les objets et les relations situés dans l'image, servent de données d'entraînement à des modèles rapides.

La description est l'étape chère : elle est faite une fois par image. Le moteur, lui, ne coûte presque rien : il doit
pouvoir être amélioré puis rejoué sur toutes les descriptions déjà faites, sans appel payant.

## 0. En bref

1. **Un moteur Prolog.** La connaissance est en faits ; la recherche des candidats, la vérification, la combinaison,
   le repli sur le parent et la décision sont des règles SWI-Prolog ; la dérivation d'un code est sa preuve. Python
   lit la description et l'écrit en faits, appelle le moteur par Janus, écrit la sortie ; des compilateurs hors ligne
   écrivent les sources en faits.
2. **Aucun réseau de neurones dans le moteur.** Les écarts de vocabulaire entre la description et Iconclass passent
   par des ressources symboliques compilées (Iconclass dans toutes ses langues, WordNet, Wikidata), chaque lien étant
   une étape de preuve nommée.
3. **Aucune culture écrite à la main.** Iconclass contient déjà le raisonnement de l'iconographe : attributs possibles
   des saints, sources des récits, gabarits de vie, familles de clés. Les règles en sont tirées par programme.
4. **Raisonner comme un iconographe** : un épisode se reconnaît à une combinaison de figures, d'actions et d'objets ;
   un saint à son nom et à ses attributs, jamais à un attribut seul ; une notation fine se justifie par ce qui la
   distingue de ses sœurs.
5. **Les règles mesurent, la décision apprend** : chaque règle rend une quantité nommée ; un apprenant peu profond,
   entraîné sur un corpus, est compilé en clauses Prolog et validé sur un autre corpus.
6. **Rejouable** : base, règles, clauses apprises et sources sont versionnées et épinglées ; mêmes entrées, mêmes
   octets en sortie.

## 1. But et périmètre

Le moteur fait : lire une description (format § 13) ; proposer des notations Iconclass pour chaque élément de la
description ; les vérifier, les combiner, en garder certaines, chacune avec sa probabilité et sa preuve ; rattacher des
codes aux objets situés (boîtes) et aux relations ; dire quelle partie de la description n'a servi à rien.

Il ne fait pas : regarder l'image ; demander des codes au descripteur ; appeler un modèle de langue ; tourner en
production (ses sorties sont des données d'entraînement).

## 2. Ce qu'Iconclass impose

La notation d'Iconclass n'est pas un simple arbre de préfixes. Comptes sur le dépôt `iconclass/data` (CC0) au commit
épinglé : 40 716 notations de base, 58 familles de clés (2 931 suffixes), 6 128 renvois. Six mécanismes se combinent,
chacun avec un sens propre à une plage de la hiérarchie :

| Mécanisme | Ce qu'il est | Ce que le moteur doit savoir |
|---|---|---|
| hiérarchie | division, chiffre, lettre, chiffres ; coder un descendant affirme ses ancêtres | l'arbre, le type de chaque niveau |
| lettre doublée | 5 607 notations ; sens selon la section (féminin, opposé, plein air, fabuleux, variante) ; deux parents (le parent doublé et le jumeau simple) | le sens de chaque préfixe et le trait de la description qui le déclenche |
| texte entre parenthèses | noms listés et gabarits « (...) » ouverts à tout nom (personne, ville, édifice…), selon une convention d'écriture | le type de nom attendu par chaque gabarit |
| chiffres structuraux | gabarits de vie appliqués aux saints, aux héros, aux personnages antiques : un chiffre = une catégorie d'épisode (jeunesse, miracle, martyre, portrait…) ; plus du tiers des notations de base | des tables chiffre → catégorie, reliées au vocabulaire d'action ; l'identité de la personne d'abord |
| clés (+…) | une famille par notation ; plus de 1,3 million de notations valides avec les clés | composer la clé à la demande, jamais énumérer ; relier chaque famille (posture, vue, nombre, matière, personnage sacré présent, mode de représentation) aux champs de la description |
| renvois et sources | renvois entre notations ; références bibliques et classiques dans les libellés | voisinage latéral ; passage source → figures, actions, objets attendus |

## 3. Ce que la littérature impose

- **Le texte bat l'image**, et une recherche lexicale sur une bonne description est déjà une base sérieuse (Banar et
  al. 2023 ; Thomas 2025 ; Thomas et Hintersteiner 2026) : chaque mesure du moteur donne BM25 sur les mêmes
  descriptions comme ligne de base.
- **Candidats à plat, contrôle par la hiérarchie** : un décodage de haut en bas perd les branches multiples ; on génère
  dans toutes les divisions, puis on vérifie, combine et replie avec l'arbre.
- **Le repli sur le parent est le levier de précision le plus fort** : décision explicite, graduée, rapportée en courbe
  (forme de règle de Deng et al. 2012).
- **Un attribut seul ne prouve rien** : objets vers sens symboliques sans contexte, identification des saints par
  leurs seuls attributs, tous deux faibles dans les travaux publiés ; on exige une combinaison, notée par abduction
  (éléments décrits utilisés moins éléments attendus absents), et l'interprétation cohérente la plus agrégée d'abord.
- **Visible n'est pas catalogué** : « vrai de l'image » et « écrit par un catalogueur » sont deux probabilités ; les
  indexeurs humains ne s'accordent qu'à moitié, la précision contre un catalogue a un plafond bas.
- **Décision lisible** : les systèmes d'indexation par thésaurus les plus proches (Maui, Annif) apprennent de petits
  arbres sur des traits lexicaux et de structure ; on compile ces arbres en clauses.

## 4. Architecture

```
description JSON ──(Python : lecture, aucun jugement)──► faits de la description
                                                              │
base compilée (faits) ───────────────────────────────────────►│ SWI-Prolog
  grammaire de la notation · arbre et jumeaux · libellés       │  1. recherche : candidats à plat, toutes divisions,
  décomposés · lexique (Iconclass toutes langues, WordNet,     │     chaque candidat avec sa dérivation lexicale
  Wikidata) · personnes et attributs · tables des chiffres     │  2. raisonnement par mécanisme (§ 8)
  structuraux · lettres doublées · gabarits · clés et leur     │  3. traits de preuve → décision (clauses apprises)
  sens · épisodes · sources · renvois · consignes              │  4. preuve de chaque code (méta-interpréteur)
                                                              ▼
                                      sortie JSON : codes, probabilités, preuve, objets et relations situés
```

## 5. La base, dans l'ordre de construction

Chaque contenu est compilé par programme depuis sa source épinglée.

1. **Grammaire de la notation** (DCG) : analyse et génération de toutes les formes, avec le type de chaque élément.
2. **L'arbre** : parent canonique, lien jumeau des lettres doublées, division, type de niveau ; ancêtres par une règle
   tabulée.
3. **Les libellés décomposés** : tête, contexte « ~ », spécification « : », partie « - » ; marques de récit, de
   visibilité, d'attributs possibles, de source ; consignes d'usage.
4. **Les sources** normalisées (livre, chapitre, verset ; Ovide…), propres et héritées.
5. **Les personnes** : saints, personnages bibliques, dieux, héros, personnages antiques et littéraires ; formes du
   nom ; attributs possibles avec leur rareté calculée sur Iconclass.
6. **Les tables de chiffres structuraux**, par plage.
7. **Les lettres doublées** : sens par préfixe et trait déclencheur.
8. **Les gabarits** : type de ce qu'ils nomment, noms listés, convention d'écriture.
9. **Les clés** : famille de chaque notation, suffixes hiérarchisés, textes, queues, sens fonctionnel de chaque
   famille.
10. **Les épisodes** : participants, action, objets, lieu, rang dans l'histoire ; du libellé, puis du passage source.
11. **Le lexique** : mots clés de toutes les langues, renvois entre mots clés, WordNet, alias Wikidata.
12. **Les renvois** entre notations, comme voisinage de recherche.
13. **Les consignes d'usage** : notation secondaire, variante, dépréciée et sa préférée, niveau le plus spécifique que
    la preuve soutient.

## 6. Les sources

| Source | Licence | Ce qui en est tiré |
|---|---|---|
| Iconclass (`iconclass/data`) | CC0 | tout ce qui précède |
| WordNet (Princeton 3.0, édition Prolog ; ou Open English WordNet) | type BSD ; CC BY 4.0 | morphologie, synonymes, hyperonymes et hyponymes à deux pas au plus, dérivés, parties |
| Wikidata | CC0 | formes de noms des entités liées à une notation (P1256), parties et ordre des cycles, exclusions, pont vers l'AAT |
| Bible (King James avec Apocryphes), Ovide (Perseus) ; index des personnes par verset (STEPBible TIPNR, Theographic) | domaine public ; CC BY(-SA) 4.0 | figures, actions et objets attendus d'un épisode, comme indices |
| Getty AAT | ODC-By 1.0 | vocabulaire technique de l'art absent de WordNet |

**Jamais de donnée d'œuvre** : ni Wikidata P1257 (notations posées sur des œuvres), ni le « depicts » des œuvres
(P180 inverse), ni aucun graphe d'énoncés sur des œuvres. Ces données peuvent contenir les œuvres d'un jeu de mesure.
Chaque extrait est figé (date, requête, empreinte). La base compilée reste hors du dépôt ; ses compilateurs y sont.

## 7. Le pont entre les mots

Une mention de la description atteint des notations par un chemin dont chaque pas est nommé (il devient un trait de
la décision) :

1. **Morphologie** (exceptions et règles de WordNet, génitif, trait d'union) → lemme ; égalité à un mot clé, à une
   tête de libellé, à un mot plein de libellé, dans toutes les langues d'Iconclass ; renvois entre mots clés.
2. **WordNet** : synonymie ; hyperonymie et hyponymie à deux pas au plus ; dérivation ; méronymie. Une pénalité de
   généralité **calculée** (profondeur depuis la racine, nombre de descendants, nombre de notations atteintes) remplace
   toute liste de mots génériques. Tous les sens d'un mot sont gardés ; le contexte choisit (§ 8).
3. **Noms propres** : formes d'Iconclass et alias Wikidata ; personnes bibliques par les index de versets.
4. **Vocabulaire technique** : Getty AAT.
5. **Renvois** entre notations : voisinage latéral seulement.

## 8. Le raisonnement, par mécanisme

- **Recherche à plat** : chaque mention propose les notations que le pont atteint, dans toutes les divisions, sans
  filtre de routage ; s'y ajoutent les ancêtres sûrs, les voisins par renvois, les notations des personnes reconnues,
  les épisodes des sources citées.
- **Choix du sens** : les autres mentions qui atteignent la même branche, le champ de la mention, la cohérence avec le
  sujet départagent les sens d'un mot ; l'accord devient un trait.
- **Spécialisation** : d'un candidat sûr, descendre vers l'enfant dont le trait distinctif (mot propre du libellé,
  absent des libellés des sœurs) est décrit.
- **Personnes, identité d'abord** : nom et attributs combinés, pondérés par leur rareté ; l'épisode d'une personne
  exige la preuve de la personne.
- **Gabarits de vie** : la catégorie d'épisode se prouve par l'action décrite, reliée au vocabulaire de la catégorie.
- **Épisodes** : abduction sur les participants, actions et objets attendus (libellé, puis passage source), plus
  l'accord de source ; les indices tirés d'un texte source sont pesés, jamais exigés.
- **Lettres doublées** : le trait déclencheur de la section est-il décrit ? sinon le jumeau simple.
- **Clés** : pour une notation prouvée, une clé de sa famille n'est proposée que si le champ de la description qui
  porte sa propriété la soutient ; une clé par notation dans la sortie.
- **Gabarits et noms libres** : un nom de la description, typé (personne, ville, édifice…), va au gabarit de son type,
  écrit selon la convention ; sans nom, seul le parent se justifie.
- **Repli sur le parent** : explicite et gradué ; le parent de frères à égalité ; la probabilité d'un parent au moins
  celle de ses enfants.
- **Exclusions** : les seules contradictions structurelles d'Iconclass (consignes, notation dépréciée…).

## 9. La décision

Traits : ceux de la preuve (force et nature du chemin lexical, rareté, part d'attendus décrits, écart aux sœurs,
profondeur, mécanisme, accord de source…), jamais un trait de corpus (chapitre, fréquence dans un catalogue). L'apprenant
(arbre peu profond ou liste de règles) est entraîné hors du moteur, sur un corpus de développement dont les étiquettes ne
quittent pas la plateforme de calcul ; il rend des **clauses Prolog** que le moteur exécute. Deux probabilités :
`p_catalogue` (un catalogueur l'aurait-il écrit ?) et `p_juste` (le code est-il vrai de l'image ?, corrigée par jugement
à l'aveugle). La généralité se mesure hors corpus : apprendre sur une collection, mesurer sur une autre.

## 10. La preuve

Un méta-interpréteur dérive chaque code sur les règles déclarées ; la preuve est l'arbre de la dérivation, avec, à
chaque feuille, le fait de la base (notation, libellé, entrée lexicale et sa source) ou de la description (champ et
chemin JSON). Elle est rendue lisible et en JSON.

## 11. L'évaluation

- **Couverture par pièce** : pour chaque code vrai, la description contient-elle de quoi le déduire ? le moteur
  l'envisage-t-il exactement, à la base de sa clé ou à son gabarit, à un ancêtre seulement ? Par mécanisme, profondeur,
  chapitre et champ porteur.
- **Qualité des codes retenus** : H-F1 (Kiritchenko), LCA-F, F1 exact ; par mécanisme et chapitre ; courbe précision /
  profondeur du repli ; intervalles par rééchantillonnage.
- **Lignes de base** dans chaque tableau : BM25 sur les mêmes descriptions, et la version précédente du moteur.
- **Hors corpus** et **jugement à l'aveugle** (image et code présentés sans dire d'où vient le code).

## 12. Feuille de route

| Phase | Contenu | Sortie |
|---|---|---|
| étude | Iconclass mécanisme par mécanisme ; pertes de la version 0.2 ; sources ; littérature | ce document |
| socle | grammaire de la notation, arbre et jumeaux, libellés décomposés, lexique (WordNet, mots clés toutes langues, alias), faits de la description, recherche à plat avec dérivation, méta-interpréteur, sortie | candidats trouvés et prouvés par Prolog ; couverture au moins celle de la version 0.2, sans modèle de phrases |
| connaissance par mécanisme | dans l'ordre des pertes mesurées : spécialisation, clés, personnes et gabarits de vie, épisodes et sources, lettres doublées, noms libres | couverture et qualité par mécanisme |
| décision | clauses apprises, validation hors corpus, jugement à l'aveugle | version 1.0 |

## 13. Interface

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

**Sortie** : une ligne JSON par image dans `codes.jsonl`, plus un `manifeste.json` par lot (versions, comptes,
empreintes des descriptions lues, durée). Exemple **illustratif** (valeurs inventées) :

```json
{"image": "exemple-0001",
 "versions": {"moteur": "1.0.0+g1a2b3c4", "base": "iconclass <commit> ; wordnet <édition> ; wikidata <date>",
              "decision": "<empreinte des clauses>", "description": "sha256:…"},
 "codes": [
  {"code": "11H(JEROME)", "statut": "retenu", "p_catalogue": 0.62,
   "preuve": {"regle": "personne_nommee",
              "faits": [{"chemin": "persons[0].who", "texte": "Saint Jerome"},
                        {"chemin": "entities[3].type", "texte": "lion"}],
              "iconclass": "possible attributes: book, cardinal's hat, crucifix, hour-glass, lion, skull, stone",
              "sous_preuves": []},
   "explication": "Saint nommé dans la description ; 2 de ses 7 attributs possibles sont décrits."}],
 "objets": [{"id": "e4", "type": "lion", "boite": [0.61, 0.55, 0.93, 0.97], "plan": "foreground",
             "codes": ["25F23(LION)"]}],
 "relations": [{"sujet": "e1", "relation": "looks_at", "objet": "e4", "codes": []}],
 "non_utilise": {"mentions": 37, "par_champ": {"keywords": 21, "setting": 4, "concepts": 2}}}
```

Statuts `retenu` et `candidat` ; notations telles qu'Iconclass les écrit ; tri stable, nombres arrondis à 4 décimales,
pas d'aléa ; une description illisible donne une ligne avec `"erreur"`, comptée dans le manifeste.

## 14. Risques et parades

| Risque | Parade |
|---|---|
| Le descripteur affirme un sujet célèbre que l'image ne montre pas | vérification par les participants et les objets attendus ; alternatives gardées |
| Le descripteur reconnaît l'œuvre et récite ce qu'il en sait | chiffres séparés selon que la description nomme l'œuvre ; rien n'est réglé sur un ensemble de mesure |
| Polysémie, liens WordNet trop généraux | deux pas au plus, pénalité de généralité calculée, choix du sens par le contexte, chemin gardé dans la preuve |
| Noms ambigus (Jean le Baptiste / l'Évangéliste) | un nom seul ne suffit pas : attributs et contexte |
| Le style du catalogue n'est pas la vérité | deux probabilités ; jugement à l'aveugle |
| Fuite de l'évaluation dans le moteur | aucune donnée d'œuvre (P1257, P180 inverse) ; aucun réglage sur un ensemble de mesure |
| Règles écrites pour un corpus | règles générales tirées d'Iconclass et de ses sources ; toute amélioration confirmée hors corpus |

## 15. Le dépôt

Code du moteur, compilateurs des sources, tests sur des descriptions synthétiques écrites pour les tests (avec les codes
attendus), déterminisme, validation du schéma, vitesse. Aucune donnée : ni image, ni description, ni étiquette, ni
sortie, ni base compilée. Licences : code sous la licence du dépôt ; SWI-Prolog BSD-2 ; sources selon le § 6.
