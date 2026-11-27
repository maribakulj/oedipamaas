# Les corrections prioritaires de C3 (27/11)

Les huit défauts du compilateur des libellés relevés par l'expérience croisée (`docs/EXPERIENCE_CROISEE.md`, § 6),
corrigés un par un. Ce sont des corrections linguistiques générales, sans règle propre à une notation. Chacune a son
contre-exemple dans `tests/plunit/test_compilateur.pl` (39 tests, dont 33 nouveaux ; sur le code d'avant, 32 des
nouveaux tests échouent, le dernier étant un test de non-régression de l'ellipse).

## 1. Les corrections

| # | défaut | correction | contre-exemple |
|---|---|---|---|
| D1 | énumération compilée en conjonction | une énumération sans verbe conjugué, sans auxiliaire et sans nom propre, dont chaque segment a une tête et dont les segments sont coordonnés (conj, list, parataxe), est une disjonction : scènes, aspects, et classes dont les segments sont verbaux (« recouvrir, tapisser ») ; dans une liste, un gérondif que l'analyseur rattache au premier segment reste une alternative | 47C35 « planing, filing, abrading » ; « baptism, consecration, taking vows… » ; pas « Shiva, god of… » (apposition), ni « domestic animals, kept in… » (modifieur) |
| D2 | nom d'action ou gérondif compilé en type | un nom d'action qui est toute la requête (de l'alternative), dont la première acception est une action et qui dérive d'un verbe (WordNet `der`, liens morphosémantiques ; en français l'acception la plus fréquente et un verbe de même radical), ou un gérondif que WordNet n'a pas pour nom, est l'événement de son verbe | 44G31 imprisonment → imprison ; 47G3355 upholstering → upholster ; pas « fire » quand d'autres conditions existent |
| D3 | composé coupé en variables sans lien | le modifieur d'un composé (`compound`) devient une propriété de sa tête (la forme du guide : `card{trade}`), réunie en un type quand la langue lexicalise le composé, soudé compris (« trademark ») ; un complément du nom que le lecteur n'a pas relié (« des » lu comme article) est relié par « de » / « of » ; la coordination elliptique ne reprend pas le contexte dans un segment qui a son propre modifieur, et en français le contexte avant est ce qui précède le premier nom (`definitions.pl`) | 46B355 « trade mark, trade token… » ; 42A111 « contrôle des naissances, contraception » |
| D4 | lemme au pluriel | un mot que la langue ne connaît pas, dont le singulier est connu, est mis au singulier (puis le composé lexicalisé est trouvé) | 31A22361 « organes sexuels mâles » → `organe sexuel` |
| D5 | sens faux (français) | la tête d'un gabarit est le mot que le libellé français nomme après « : » ; les mots de WOLF de tous les sens anglais du nom ne sont pas ceux du libellé | 46E43(ROCKET) : « fusée », plus « eruca sativa » |
| D6 | gabarit du parent conjoint sur la même variable | le genre d'un gabarit qu'aucun sens du nom n'atteint dans K n'est pas exigé, et la requête est partielle (`genre_du_gabarit_incompatible`) ; un nom que K ne connaît pas garde son genre, son seul accès | 46E43(ROCKET) « light, fire, smoke… used for signalling » |
| D7 | participe, complément de matière | un participe lu comme propriété est un événement (patient au passé, agent au présent) ; des verbes coordonnés sans sujet propre partagent le sujet ; un complément de matière (première acception : une substance) se lit aussi comme une propriété, en disjonction avec la lecture littérale | 71E3242 « a serpent of brass is made and is set on a pole » |
| D8 | glose d'un saint dans la condition suffisante | quand la première partie d'une subdivision de personne n'est que sa glose (noms, types, « of » vers un nom propre, aucun événement), la personne est donnée par ses noms ; la glose n'est ni suffisante ni nécessaire | 11H(CASSIAN)32, 11H(QUINTIN)0 |

**Deux garde-fous ont été ajoutés après la première mesure,** chacun avec son contre-exemple.
- **Un événement lu seul garde sa raison** `evenement_sans_participant`, et sa requête reste partielle. Une exemption
  rendait 33A132 « reconnaître, identifier » compilée et trop faible.
- **Un libellé qui dit plusieurs individus distincts** (« différents mammifères ») donne une requête partielle. Les
  requêtes ne comptent pas les référents. 43C11121 n'était partielle qu'à cause d'un lemme pluriel non couvert (D4) ;
  une fois ce défaut corrigé, elle devenait compilée et trop faible.

## 2. Les mesures, avant et après

- **Avant :** commit da2bf52, extrait par `git archive`.
- **Après :** commit 54805da, arbre propre.
- **Communs aux deux :** la même base, les mêmes données, les mêmes outils (`outils/mesure/c3_corrections.sh`), le
  résumé par `outils/mesure/resumer_c3.py`.
- **Les sorties** sont dans `/home/user/donnees/c3_corrections/`, hors dépôt :
  - `avant/` et `apres/` ;
  - les passes intermédiaires `apres_9a1f61d/`, `apres_68aeb3f/` et `apres_bed9ece/`, gardées.

**Les statuts de compilation** (200 fiches par jeu) :

| | compilée | partielle | non prise en charge |
|---|---|---|---|
| développement | 48 → 55 | 84 → 77 | 68 → 68 |
| validation | 41 → 51 | 92 → 82 | 67 → 67 |

**La comparaison aux requêtes de référence** (`comparer.pl`) :

| | exacte | trop forte | trop faible | incomparable | indéterminée |
|---|---|---|---|---|---|
| développement | 19 → 21 | 9 → 10 | 6 → 11 | 93 → 87 | 3 → 1 |
| validation | 21 → 28 | 18 → 13 | 8 → 9 | 83 → 81 | 1 → 0 |

- **Les nouvelles « trop faibles » du développement sont toutes partielles :** 43C11127, 46E43(ROCKET), 46C1211, 45F2,
  33A132. Elles ne peuvent rien qualifier.
- **Les requêtes compilées et trop faibles (dangereuses) :** en développement, 2 → 1 (49E39311(PELICAN) devient
  partielle par D6 ; 31A4624 reste) ; en validation, 2 → 2 (45M2 et 31B6263, inchangées, d'avant).

**Les quatre conditions de l'expérience croisée,** 40 textes positifs par jeu. Statuts : établie (déductive) / sous
hypothèses / sans requête / interrompue / erreur / échec sémantique.

| jeu | condition | avant | après |
|---|---|---|---|
| développement | lecteur, compilée | 2 / 0 / 15 / 0 / 0 / 23 | 4 / 0 / 15 / 0 / 0 / 21 |
| développement | référence, compilée | 2 / 0 / 15 / 0 / 0 / 23 | 4 / 0 / 15 / 0 / 0 / 21 |
| développement | lecteur, référence | 3 / 1 / 1 / 0 / 0 / 35 | inchangé |
| développement | référence, référence | 5 / 0 / 1 / 0 / 0 / 34 | inchangé |
| validation | lecteur, compilée | 1 / 1 / 12 / 0 / 0 / 26 | 0 / 2 / 12 / 0 / 0 / 26 |
| validation | référence, compilée | 0 / 1 / 12 / 0 / 0 / 27 | 0 / 1 / 12 / 0 / 0 / 27 |
| validation | lecteur, référence | 0 / 2 / 0 / 0 / 0 / 38 | inchangé |
| validation | référence, référence | 0 / 1 / 0 / 0 / 0 / 39 | inchangé |

Aucune interruption et aucune erreur, avant comme après. Les textes négatifs et indéterminés ne changent pas.

**Chaque changement, jugé un par un :**

- **42A111, développement, positif.** Il devient établi, déductivement, dans les deux conditions à requête compilée, et
  il est qualifié `etablissable`. C'est un vrai gain : l'alternative `contraception` est atteinte par « préservatif »
  et « pilules contraceptives ». Avant, la segmentation fautive exigeait « contrôle », « naissance » et
  « contraception » ensemble. Cette perte du compilateur relevée par l'expérience croisée est reprise.
- **11H(CASSIAN)32, développement, positif.** Il devient établi dans la condition (référence, compilée), mais la requête
  est partielle et la qualification n'est que `candidat`. L'aspect n'est pas relié à la personne : la requête dit
  « Cassian » et « un baptême », pas « le baptême de Cassian ». **Non qualifié, à ne pas compter comme un gain.**
- **46E43(ROCKET), développement, positif.** Il devient établi dans la condition (lecteur, compilée), avec une requête
  partielle et la qualification `candidat`. La requête n'est plus que `type(x, fusée)` (D6) : le succès est juste, mais
  il ne vérifie pas la signalisation. **Non qualifié, à ne pas compter comme un gain.**
- **46B355, validation, positif.** Le succès fortuit d'avant disparaît : « trade » venait de « ephemera of trade »,
  ailleurs de l'hypothèse fausse address → sign. La requête est maintenant compilée et exige `card{trade}` ; le texte
  dit `card{advertising}`. C'est une perte de succès, mais d'un succès sans raison.
- **47G3355, validation, variante de négation.** Le faux positif d'avant disparaît. Le lecteur lit toujours
  « upholstering » comme affirmé, mais la requête demande maintenant l'événement `upholster`, que ce graphe n'a pas.
  **C'est un effet de forme, non une correction de la sûreté du lecteur.** Le même graphe, avec l'événement mal lu,
  redeviendrait un faux positif.
- **47C35, validation, positif.** Il devient établi sous l'hypothèse shave → plane, avec une requête partielle :
  `conditionnel`. Le sens est juste (raboter), mais ce n'est pas exploitable.

## 3. Les quatre notations de l'expérience croisée

- **31A22361 :** la requête française devient `et([type(x, 'organe sexuel'), propriete(x, mâle)])`, **exacte** devant
  la référence. Le texte positif reste non établi : son graphe a « appareil génital », sans concept dans K, et
  « masculin » sur le tout (lexique et représentation, § 5 de l'expérience).
- **44G31 :** la requête devient `evenement(e, imprison)`, **exacte**. Le texte positif reste non établi : il décrit
  l'emprisonnement sans le nommer, ce qui relève de l'inférence.
- **46E43(ROCKET) :** « eruca sativa » et le genre conjoint sont retirés ; la requête est partielle. La fonction de
  signal n'est pas compilée (voir § 4).
- **31A3333 :** inchangée. Le compilateur n'y était pas en cause.

## 4. Ce qui n'est pas corrigé, et pourquoi

- **La canonisation côté graphes.** D2 met la requête dans la forme du guide (un événement). Un graphe du lecteur qui
  garde le nom d'action ne la satisfait plus : c'est ce qui retire le faux positif de 47G3355, et ce qui retirerait un
  vrai positif écrit de la même façon. Ramener les graphes du lecteur à la même forme est une canonisation des deux
  côtés. Elle n'est pas faite ici : elle relève de l'expérience contrôlée.
- **La fonction d'un gabarit** (« used for signalling », « comme moyen de signalisation »). Le gabarit n'est lu que
  pour ses têtes. Le lire comme un événement dont la chose est l'instrument demanderait de compiler sa partie
  verbale : D6 se borne à ne plus exiger une conjonction insatisfaisable.
- **Le nombre.** Le pluriel n'est pas compilé, ni « deux », ni « différents ». Le garde-fou rend la requête partielle ;
  il ne compile pas le nombre.
- **Les parties non lues.** Les parenthèses (« industrial processes ») ne sont pas lues, et un aspect n'est pas relié
  à la personne (`aspect_non_lie_a_la_personne`) : ces requêtes restent partielles.
- **« filing » (47C35)** reste un type : sa première acception dans WordNet n'est pas une action. La règle D2 est
  tenue, au prix de ce cas.
- **Les lectures fautives de l'analyseur.** Une liste mal analysée (« tourmenter, torturer des animaux », dont l'objet
  partagé n'est donné qu'au dernier segment) ou un objet en `obl:arg` non lu (« fixé à une hampe ») restent des
  défauts du lecteur. Leurs requêtes restent partielles.
- **Les comptes sont petits** : 40 positifs par jeu dans l'expérience croisée. Les gains qualifiés sont 1
  (développement) et 0 (validation) ; les retraits de succès fortuits ou de faux positifs sont 2.

## 5. Reproduction

```bash
outils/mesure/c3_corrections.sh BASE DONNEES SORTIE/apres
```

```bash
git archive da2bf52 outils oedipamaas | tar -x -C AVANT
cp outils/mesure/c3_corrections.sh AVANT/outils/mesure/
COMMIT=da2bf52 AVANT/outils/mesure/c3_corrections.sh BASE DONNEES SORTIE/avant
```

```bash
python outils/mesure/resumer_c3.py SORTIE/avant SORTIE/apres --json SORTIE/resume.json
```

- **BASE** est la base compilée (`requetes_index.pl` n'est pas recompilé ; la base est lue seulement).
- **DONNEES** contient `vertical/`, `validation_m1/` et `banc_graphes/`.
