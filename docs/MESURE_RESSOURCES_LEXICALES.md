# Mesure des ressources lexicales françaises pour K

Version 1, 28/11/2026. Document de mesure : il ne décide rien. Il prolonge `docs/ETUDE_RESSOURCES_LEXICALES.md` (l'« étude »), dont il reprend les conventions et le vocabulaire. La seule partie normative, l'esquisse de l'interface K (§ 11), est une **proposition**.

**La demande de la propriétaire (28/11).** « Je souhaite une interface K fédérant les ressources existantes, avec une ontologie de travail propre pour les distinctions nécessaires au raisonnement. Je ne souhaite pas reconstruire manuellement une ontologie générale du monde. Le vote entre ressources peut proposer ou hiérarchiser des alignements, mais ne constitue pas une attestation de leur validité. Mesure d'abord les gains réels des différentes ressources, leurs erreurs corrélées, la couverture des sens utiles et les licences. Évalue notamment la capacité des vocabulaires patrimoniaux français, de WoNeF et de DBnary à compléter WOLF. Ne lance pas encore une campagne manuelle de plusieurs milliers de corrections ajustées au vocabulaire des bancs. Les données corrigées devront être évaluées sur des textes et des familles lexicales indépendants. »

**Marques.** Comme dans l'étude :
- « vérifié » : page consultée, URL donnée ;
- « vérifié (local) » : fichier téléchargé lu ;
- « mesuré » : chiffre calculé par les scripts de `outils/ressources/` ;
- « jugé » : **jugement d'agent**, par un seul annotateur (moi), sans double annotation ni adjudication. Ce n'est pas une validation. Les jugements sont des fichiers séparés (`outils/ressources/jugements/`), relisibles et remplaçables ;
- « non vérifié » : à confirmer.

**Ce que je n'ai pas fait.**
- Je n'ai lu aucun banc, aucun fichier sous `/home/user/donnees/bancs_phase1`, aucun jeu scellé, rien sous `qualification_independante`, aucun code du moteur.
- Je n'ai fait aucune opération git.
- Je n'ai corrigé aucune ressource. Les 629 couples, 30 occurrences, 160 expressions et 40 lemmes jugés pour la mesure ne sont **pas** des corrections et ne doivent pas entrer dans K tels quels (§ 12).
- Je n'ai envoyé aucun nom de personne ni de projet dans les requêtes réseau.

---

## 0. Résumé

1. **Obtention.** WoNeF (3 versions), DBnary (dumps fr et en complets), les 16 listes Joconde, le thésaurus Garnier (PDF par chapitre et liste Opentheso th285), Iconclass (textes et mots-clés français) et l'AAT (N-Triples, termes français) ont été obtenus. Trois points ont été bloqués : `referentiels.culture.fr` (refus 403 du pare-feu applicatif ; contourné par l'instance `opentheso.huma-num.fr`), `vocab.getty.edu` et `vocabularies.getty.edu` (refusés ; contourné par `aatdownloads.getty.edu`), et le PDF intégral du Garnier (transfert interrompu, pas de reprise possible ; contourné par les PDF des chapitres). Les PDF du Garnier sont des images sans couche texte (§ 1).
2. **Corpus indépendant des bancs.** 1 989 notices Joconde (87 069 mots, 276 musées) et 2 500 libellés français d'Iconclass (26 732 mots), tirés avec la graine 20261128 et lemmatisés par Stanza 1.10.1 (§ 2).
3. **Couverture et gain marginal sur WOLF** (Joconde, noms, verbes, adjectifs et adverbes, en types). WOLF seul : **70,0 %** des types et 88,2 % des occurrences. Gains : WoNeF F-score **+10,8 points**, WoNeF couverture +11,5, WoNeF précision +3,0, DBnary filtré +6,7, les quatre vocabulaires patrimoniaux ensemble +9,6. L'union de toutes les ressources atteint 91,8 %. Pour les **noms propres**, WOLF ne couvre que 15,5 % des types ; les listes Joconde et le Garnier les portent à 39,0 %, alors que WoNeF et DBnary n'apportent presque rien (§ 3).
4. **Expressions polylexicales.** Sur 42 termes du domaine jugés, WOLF en couvre **21 %**, WOLF + WoNeF + DBnary 43 %, WOLF + patrimoniaux **64 %**, toutes les ressources 71 %. Les listes Joconde sont, seules, la meilleure ressource (45 %) (§ 4).
5. **Précision des alignements proposés** (46 lemmes, 629 couples jugés). Couples parasites : WOLF **34,6 %**, WoNeF précision **3,7 %**, WoNeF F-score 17,3 %, WoNeF couverture 39,5 %, DBnary filtré 17,4 %, AAT pivot 38,9 %, DBnary brut 64,3 % (§ 6).
6. **Erreurs corrélées.** Les ressources qui alignent par **pivot anglais** partagent leurs erreurs. DBnary brut propose 61 % des erreurs de WOLF, et l'AAT pivot 76 % des siennes. Les erreurs communes à toutes les ressources (« salamandre » → *poker*, « pierre » → *stone*, l'unité de poids) viennent d'un mot anglais présent dans le synset lui-même. À l'inverse, **WoNeF F-score et DBnary filtré ne reprennent presque aucune erreur de WOLF** : 6 % et 3,6 % de ses erreurs, contre 47 % et 35 % de ses couples corrects. Le **vote** hiérarchise bien sans attester : 58 % d'erreurs avec une seule famille de ressources, 21 % avec deux, **10 % avec trois** (§ 7).
7. **Couverture des sens utiles** (30 occurrences en contexte). Le sens demandé existe dans WordNet pour 28 occurrences. WOLF le propose dans **22 cas** (79 % de 28), avec une médiane de 4 sens concurrents. L'union des ressources alignées le propose dans 24 cas, et l'union de toutes les ressources couvre 26 occurrences sur 30. Les vocabulaires patrimoniaux apportent ce qui n'est pas dans WordNet (« colophon ») ou mal aligné (« tardif », « satirique ») (§ 8).
8. **Familles lexicales.** Les mesures sont données par fichier lexicographique de WordNet (§ 9). Les patrimoniaux sont forts sur `noun.artifact`, `noun.substance`, `noun.plant` et `noun.animal`, et nuls sur les verbes. Le bruit de WOLF se concentre sur les verbes (`verb.social`, `verb.contact`, `verb.change`), sur `noun.person` et sur `noun.plant`.
9. **Licences** (§ 10). La licence de WoNeF est **discordante** : CC BY-SA 3.0 FR sur le site, LGPL-LR dans l'article. La licence du PDF Garnier reste à confirmer : c'est la numérisation d'un ouvrage édité par Le Léopard d'Or en 1984. Les autres licences sont vérifiées : Joconde (Licence ouverte), Iconclass (CC0), AAT (ODC-By 1.0), DBnary (CC BY-SA 4.0).

---

## 1. Ressources obtenues

Toutes les ressources ont été téléchargées le 28/11/2026, chacune dans un répertoire neuf de `/home/user/donnees/ressources/`. Chaque répertoire contient un `MANIFESTE.json` qui donne les URL, la date, la version, la licence et l'empreinte SHA-256 de chaque fichier (écrit par `outils/ressources/manifeste.py`). Les fichiers sont lus comme des données, jamais exécutés. Les scripts tournent avec `python3 -I`.

| Ressource | Répertoire | URL | Version | Licence | Fichiers principaux (SHA-256, 16 premiers caractères) |
|---|---|---|---|---|---|
| **WoNeF** | `wonef/` | `https://wonef.fr/data/wonef-{precision,fscore,coverage}-0.1.xml.bz2` (redirigé vers `wonef.pradet.me`) | 0.1, fichiers datés du 03/07/2013 | **discordante** : CC BY-SA 3.0 FR (page d'accueil du site, vérifié) ; LGPL-LR (article GWC 2014, cité par l'étude) | precision `f631e05a603d0403`, fscore `6f69ab14ee839a55`, coverage `98237b799decce25` |
| **DBnary** | `dbnary/` | `https://kaiko.getalp.org/static/ontolex/latest/{fr,en}_dbnary_*.ttl.bz2` | dump Wiktionnaire fr du 01/11/2026 (fichiers du 11/11) ; en : fichiers du 12/11 | données CC BY-SA 4.0, extracteurs MIT (page about-dbnary, vérifié) | fr ontolex `405ede1470335cc5` (118 Mo), en ontolex `33aec6c4d133f9a5` (221 Mo), fr enhancement `d0918cfb7e55e44e` |
| **Listes Joconde** (16) | `joconde_vocabulaires/` | `https://opentheso.huma-num.fr/api/all/theso?id=thNNN&format=turtle` (th284 à th306) | export du jour : ces listes vivent et sont enrichies au fil des versements | Licence ouverte Etalab (page « Télécharger les vocabulaires scientifiques », vérifié) | th290 DENO `1632c68647f5a529`, th291 TECH `0b4fa2e1775c9e6e`, th285 REPR `39836a71018afb70` (empreintes des 16 dans le manifeste) |
| **Garnier** | `garnier/` | 25 PDF de `https://www.culture.gouv.fr/mc/content/download/…` (liste dans `liste_urls.txt`) | ouvrage de 1984 (Le Léopard d'Or), PDF mis en ligne le 04/06/2020 | **à confirmer** (§ 10) | Index `86f2a3a24981dc01`, Introduction `68f45a0c6c28a974` ; PDF intégral **partiel** `20ea77d26f78090f` |
| **Iconclass** | `iconclass/` | `https://raw.githubusercontent.com/iconclass/data/0595358b…/` (`txt/fr`, `txt/en`, `kw/fr`, `notations.txt`, `LICENSE`) | commit `0595358b0e6e1635f254124ca37db49091102614`, égal au HEAD distant le 28/11 et identique au clone local | CC0 1.0 (fichier `LICENSE`, vérifié (local)) | `txt_fr_0_1.txt` `41be763f5d7586d6` |
| **AAT** | `aat/` | `http://aatdownloads.getty.edu/VocabData/explicit.zip` | LOD explicite, Last-Modified 17/10/2026 | ODC-By 1.0 (page du Download Center et `dcterms:license` de chaque concept, vérifié (local)) | `8330c9f3015d068a` (139 Mo) |
| WOLF (référence, déjà local) | `omw/omw-1.4/fra/` | — | OMW 1.4 | CeCILL-C | `wn-data-fra.tab` `0e6a4761389f6bcf` |

**Ce qui a été bloqué, et comment j'ai fait sans.**
- **`referentiels.culture.fr`**, l'adresse donnée par le ministère pour les listes Joconde, répond 403 « Attack detected » (pare-feu applicatif). L'API de l'instance Opentheso d'Huma-Num sert les mêmes thésaurus (`th284` à `th306`) en Turtle.
- **Getty** : `vocab.getty.edu` répond 403 et `vocabularies.getty.edu` est refusé par le mandataire (502). `aatdownloads.getty.edu` (le Download Center) et `data.getty.edu` répondent. J'ai pris le N-Triples explicite complet.
- **Garnier** : le PDF intégral s'interrompt à 8,35 Mo et le serveur refuse la reprise (`HTTP server doesn't seem to support byte ranges`). Il est conservé sous le nom `thesaurus_garnier_integral.PARTIEL.pdf`. Les 25 PDF par chapitre, plus l'index, l'introduction et le plan, sont complets (`chapitres/`). **Tous sont des numérisations en image (CCITT, 200 ppp) sans couche texte.** Je n'ai pas lancé d'OCR : aucun outil n'est installé, et en installer sortait du périmètre. La forme exploitable du Garnier est la **liste Opentheso th285** « Représentation – Joconde ». Ses 22 têtes reprennent les chapitres du Garnier (la nature, le corps et la vie matérielle, vie religieuse, sujet biblique, être imaginaire, ornement…), enrichis de listes ouvertes (quidams, noms de groupe, sujets mythologiques). Dans la suite, « **Garnier** » désigne th285 (vérifié (local)).
- **DBnary** n'est pas un sous-ensemble : les dumps fr et en sont complets. À la lecture (`lexiques.py`), je n'en retiens que trois choses : les entrées françaises (lemme, catégorie, nombre de sens), les traductions fr → en du Wiktionnaire français, et les traductions en → fr du Wiktionnaire anglais.
- `data.culture.gouv.fr` et `www.data.gouv.fr` ne répondaient pas, mais je n'en avais pas besoin.

**Constats faits en lisant les fichiers** (vérifié (local)).
- **WoNeF** reprend le squelette XML des wordnets de type BalkaNet : les 117 659 synsets, dont les vides (`_EMPTY_`). Chaque littéral porte dans `lnote` le **sélecteur** qui l'a retenu : `monosemous`, `uniq`, `multiplesource`, `levenshtein`, `simsyn`, `hyperhypo`, `meroholo`, `hyperlike`, `gold`. **8 586 définitions sont en français** (« concept formulant la catégorisation… »). Elles viennent probablement du XML de WOLF (non vérifié). Une partie des littéraux n'a pas de note (740 à 1 402 selon la version) : leur origine n'est pas documentée.
  - Couples distincts après normalisation (mesuré) : précision **19 649**, F-score **115 035**, couverture **136 793**. L'article annonce 15 625, 88 736 et 109 447, sans doute sur un autre périmètre (adverbes, littéraux « gold » ; non vérifié). Il faudra citer WoNeF par l'empreinte du fichier, pas par les chiffres de l'article.
  - Recouvrement avec WOLF, en couples : 45 % pour WoNeF précision, 30 % pour F-score, 28 % pour couverture. **WoNeF n'est donc pas une copie de WOLF.**
- **DBnary fr** compte 627 639 entrées et 710 965 sens d'après ses statistiques (vérifié (local)). Ses propres mesures de désambiguïsation des traductions donnent une précision de 0,82 (méthode `dbnary_tversky`). Les liens de traduction sont **au niveau du mot**, pas du synset : 195 676 traductions fr → en et 131 500 en → fr ont été lues.
- **Listes Joconde** : 129 940 libellés français pour 15 listes, plus 40 065 pour th285. Elles ne contiennent **aucun libellé anglais** et presque **aucun lien externe** : 1 471 `exactMatch` vers Frantiq, 122 vers DBpedia, 16 vers Iconclass, et rien vers l'AAT ou WordNet. Elles ne proposent donc aucun alignement sur WordNet. Ce sont des vocabulaires de **concepts propres**, avec leur hiérarchie.
- **AAT** : 18 426 concepts sur 59 412 (31 %) ont au moins un terme français, au pluriel (« prisons », « oracles »). Les concepts n'ont **aucun lien vers WordNet**. Ils ont des liens vers Wikidata (`AATOut_WikidataAlignment.nt`).

---

## 2. Protocole

### 2.1 Corpus indépendants des bancs

**Corpus Joconde** (`outils/ressources/corpus.py`).
- **Source** : `/home/user/donnees/joconde/tirage3.jsonl`, un tirage de 3 % de l'export POP du 24/11 (`joconde.csv`, Licence ouverte, 25 679 notices).
- **Exclusions** : tous les identifiants déjà passés dans les mesures J0 et J1 du moteur (`entree.jsonl`, `entree_desc.jsonl`, `tirage.jsonl`, soit 4 974 identifiants). Aucun fichier des bancs n'a été lu ni consulté pour l'exclusion.
- **Tirage** : graine 20261128, en deux strates. 1 200 notices dont la description compte au moins 15 mots, et 800 autres.
- **Plafond de 60 notices par musée.** Un premier tirage sans plafond comptait 30 % d'albums de dessins du Louvre (« folio », « contreplat », « album factice »). Je l'ai écarté avant toute mesure de sens. Résultat : 1 989 textes distincts, de **276 musées**, 87 069 mots.
- **Texte retenu** : titre + description + précisions sur le sujet. J'ai **exclu** les champs `sujet_garnier` et `domaine`, qui sont l'indexation par deux des vocabulaires mesurés.
- **Biais résiduel** : les catalogueurs écrivent avec les listes Joconde en tête (« mine de plomb », « lavis brun »). La couverture des listes Joconde est donc un peu surestimée sur ce corpus. C'est pour cela qu'il y a un second corpus.

**Corpus Iconclass.** 2 500 libellés français tirés avec la même graine parmi les 40 685 notations de base (`txt/fr`, clés exclues), soit 26 732 mots. Sur ce corpus, la ressource Iconclass est **exclue** des mesures, car elle serait circulaire.

### 2.2 Lemmatisation et recherche

- **Lemmatisation** : Stanza 1.10.1, modèles français locaux (`tokenize, mwt, pos, lemma`), comme dans l'étude. Catégories retenues : NOUN, VERB, ADJ, ADV, PROPN. Aucune correction manuelle : seules les formes avec chiffres et les ordinaux romains sont exclues.
- **Bruit de lemmatisation** (jugé, 40 types absents de WOLF tirés avec la graine) : 31 sont de **vraies lacunes** (cintré, replier, porte-mine, égorger, lessiveuse, semelle, grimaçant, vergé…), 8 sont des **erreurs de lemmatisation ou d'étiquetage** (« peinter », « feuillager », « jonquil », « lentille » adjectif…) et 1 est un mot étranger. Environ **20 % des absences mesurées sont du bruit de la mesure**, pas des lacunes.
- **Recherche** : comme dans l'étude.
  - Noms, verbes, adjectifs, adverbes : en minuscules, même catégorie, œ/oe normalisés. Pour un verbe, on essaie aussi « se X » ou « s'X ».
  - Noms propres : casse respectée.
  - Thésaurus : sans catégorie. Les qualificatifs entre parenthèses sont retirés. Pour l'AAT, des variantes au singulier sont produites mécaniquement, ce qui peut créer quelques faux singuliers.

### 2.3 Les ressources comparées, et comment chacune « propose » un sens

| Nom | Ce qui est proposé pour un lemme français | Méthode |
|---|---|---|
| `wolf` | synsets WordNet 3.0 | WOLF dans OMW 1.4 |
| `wonef_p`, `wonef_f`, `wonef_c` | synsets | WoNeF 0.1, versions précision, F-score et couverture |
| `dbnary_brut` | **tous** les synsets WordNet de **toutes** les traductions anglaises (fr → en et en → fr), de même catégorie | pivot anglais sans filtre ; défini pour la mesure, c'est la méthode naïve |
| `dbnary_filtre` | un synset de `dbnary_brut` n'est gardé que s'il est atteint par **au moins deux** traductions anglaises distinctes, ou si la traduction est **monosémique** dans WordNet | défini pour la mesure ; c'est la même famille d'heuristiques que les sélecteurs de WoNeF |
| `aat_pivot` | terme français → concept AAT → termes anglais du concept → synsets WordNet (noms) | défini pour la mesure |
| `dbnary_lex` | l'existence d'une entrée française de même catégorie (lexique, **sans** sens WordNet) | — |
| `joconde_listes` | concepts des 15 listes Joconde (hors th285) | concepts propres |
| `garnier_th285` | concepts de th285 | concepts propres |
| `iconclass_kw` | notations dont un mot-clé français est le lemme | concepts propres |
| `aat_fr` | concepts AAT dont un terme français est le lemme | concepts propres |

Les vocabulaires patrimoniaux ne proposent pas de synsets WordNet, sauf l'AAT par pivot : ils proposent leurs **propres concepts**, avec une hiérarchie.

---

## 3. Couverture des lemmes et gain marginal sur WOLF

### 3.1 Corpus Joconde

Le corpus compte 4 300 types de noms (28 053 occurrences), 1 141 de verbes (7 205), 1 264 d'adjectifs (6 727), 172 d'adverbes (1 362) et 2 725 de noms propres (5 772). « Types » désigne les couples (lemme, catégorie). Tous les chiffres sont mesurés.

| Ressource | Noms (types / occ.) | Verbes | Adjectifs | Adverbes | **4 catégories** | **Noms propres** |
|---|---|---|---|---|---|---|
| WOLF | 74,1 / 89,8 | 67,9 / 86,4 | 55,5 / 82,3 | 89,5 / 94,7 | **70,0 / 88,2** | **15,5 / 30,6** |
| WoNeF précision | 32,0 / 43,6 | 21,6 / 32,9 | 28,2 / 42,9 | 55,8 / 48,2 | 30,2 / 41,9 | 3,7 / 10,7 |
| WoNeF F-score | 77,4 / 89,8 | 72,0 / 82,3 | 68,2 / 87,8 | 79,7 / 68,0 | 74,8 / 87,5 | 10,9 / 24,4 |
| WoNeF couverture | 79,7 / 91,9 | 79,8 / 91,2 | 68,2 / 87,8 | 79,7 / 68,0 | 77,6 / 90,4 | 10,9 / 24,4 |
| DBnary filtré | 60,6 / 73,3 | 66,7 / 80,2 | 50,9 / 71,8 | 74,4 / 74,4 | 60,2 / 74,3 | 9,8 / 16,0 |
| DBnary brut | 82,4 / 94,8 | 83,3 / 94,4 | 69,1 / 90,3 | 91,9 / 96,1 | 80,3 / 94,1 | 16,6 / 33,6 |
| DBnary lexique (sans sens) | 91,1 / 97,9 | 90,5 / 97,4 | 83,5 / 92,8 | 93,6 / 89,2 | 89,6 / 96,8 | 38,9 / 49,8 |
| AAT pivot | 27,2 / 45,8 | — | — | — | 17,0 / 29,7 | 0,1 / 0,2 |
| Listes Joconde | 39,2 / 61,1 | 1,9 / 1,2 | 23,1 / 51,6 | 4,1 / 10,4 | 29,2 / 48,1 | **27,0 / 39,8** |
| Garnier (th285) | 35,2 / 52,1 | 2,5 / 3,4 | 12,1 / 26,2 | 2,3 / 2,1 | 24,7 / 38,4 | 23,6 / 34,4 |
| Iconclass (mots-clés) | 44,3 / 66,2 | 26,5 / 34,6 | 12,7 / 35,0 | 4,7 / 12,0 | 34,6 / 54,4 | 7,4 / 13,8 |
| AAT (termes français) | 29,0 / 47,3 | 1,0 / 2,0 | 9,9 / 24,2 | 2,9 / 1,5 | 20,2 / 34,8 | 0,2 / 0,3 |

**Unions** (4 catégories, types / occurrences ; noms propres, types / occurrences) :

| Union | 4 catégories | Noms propres |
|---|---|---|
| WOLF + WoNeF F-score | 80,9 / 94,0 | 16,5 / 32,4 |
| WOLF + WoNeF couverture | 81,6 / 94,4 | 16,5 / 32,4 |
| WOLF + DBnary filtré | 76,8 / 92,3 | 17,3 / 32,3 |
| WOLF + WoNeF F + DBnary filtré | **82,0 / 94,6** | 17,9 / 33,8 |
| WOLF + 4 patrimoniaux | 79,6 / 94,0 | **39,0 / 55,4** |
| les 4 patrimoniaux seuls | 55,3 / 74,5 | 36,3 / 51,5 |
| toutes les ressources alignées sur WordNet | 82,8 / 94,9 | 17,9 / 33,8 |
| **toutes les ressources** | **91,8 / 98,0** | **50,6 / 65,7** |

### 3.2 Gain marginal sur WOLF (Joconde)

« Récupérés » : types absents de WOLF (2 061 dans les 4 catégories, 2 302 noms propres) que la ressource couvre. « Points » : gain en points de couverture.

| Ressource | 4 cat. : récupérés (% des absents) | points types / occ. | Noms propres : récupérés | points types / occ. | Couples (lemme, synset) nouveaux sur des lemmes déjà dans WOLF |
|---|---|---|---|---|---|
| WoNeF précision | 208 (10,1 %) | +3,0 / +1,5 | 9 | +0,3 / +0,8 | 1 279 (pour 2 070 en commun) |
| WoNeF F-score | 746 (36,2 %) | **+10,8 / +5,8** | 26 | +1,0 / +1,8 | 10 492 (8 429 en commun) |
| WoNeF couverture | 793 (38,5 %) | +11,5 / +6,1 | 26 | +1,0 / +1,8 | 17 966 |
| DBnary filtré | 464 (22,5 %) | +6,7 / +4,1 | 49 | +1,8 / +1,7 | 3 436 (5 806 en commun) |
| DBnary brut | 798 (38,7 %) | +11,6 / +6,4 | 109 | +4,0 / +6,2 | 54 235 |
| DBnary lexique | 1 383 (67,1 %) | +20,1 / +9,3 | 716 | +26,3 / +25,6 | — |
| AAT pivot | 131 (6,4 %) | +1,9 / +1,5 | 0 | 0 | 2 234 |
| Listes Joconde | 432 (21,0 %) | +6,3 / +4,3 | **488** | **+17,9 / +19,6** | — |
| Garnier | 179 (8,7 %) | +2,6 / +1,4 | 362 | +13,3 / +14,1 | — |
| Iconclass | 169 (8,2 %) | +2,5 / +2,0 | 60 | +2,2 / +2,3 | — |
| AAT termes français | 206 (10,0 %) | +3,0 / +2,0 | 1 | 0 | — |

**Lecture.**
- **WoNeF F-score est le complément aligné le plus rentable.** Il ajoute 10,8 points de types avec une précision bien meilleure que WOLF (§ 6). WoNeF couverture n'ajoute que 0,7 point de plus, au prix d'un bruit de 39,5 %.
- **DBnary** a un lexique qui couvre 89,6 % des types, mais ses alignements sur WordNet sont, soit très bruités (version brute), soit nettement moins couvrants (version filtrée). Sa valeur propre est ailleurs : définitions françaises, sens du Wiktionnaire (5,4 par lemme en moyenne), et lemmes que WOLF ignore (« décor », 265 occurrences, est absent de WOLF ; DBnary filtré et WoNeF l'alignent).
- **Les vocabulaires patrimoniaux** apportent peu sur la langue générale (+9,6 points à eux quatre), mais beaucoup sur les **noms propres** (+23,5 points) et sur le **vocabulaire technique**. Exemples de lemmes absents de WOLF : pleurant (80 occurrences ; seulement Joconde, Garnier, Iconclass), lavis (38), gouache (37), rehaut (33), estampe, glaçure, orfèvrerie, camaïeu, moulure, galon, maroquin, enduit, rinceau.
- **Absents de tout** : surtout du bruit de lemmatisation (« peinter », « éau-forte », « gri »), du jargon de catalogage (« contreplat », « mi-corps », « demi-maroquin », « failletine ») et quelques adjectifs (« stylisé », « folioté »).

### 3.3 Corpus Iconclass (contrôle ; ressource Iconclass exclue)

Le corpus compte 1 955 types de noms, 537 de verbes, 370 d'adjectifs, 62 d'adverbes et 1 351 de noms propres.

| Ressource ou union | 4 catégories (types / occ.) | Noms propres (types / occ.) | Gain sur WOLF (points de types, 4 cat.) |
|---|---|---|---|
| WOLF | 85,9 / 92,7 | 28,7 / 41,7 | — |
| WoNeF F-score | 87,4 / 90,4 | 22,9 / 35,4 | +7,4 |
| DBnary filtré | 71,3 / 68,1 | 19,7 / 24,6 | +5,1 |
| Listes Joconde | 25,9 / 31,1 | 19,1 / 25,2 | +1,8 |
| Garnier | 34,6 / 49,8 | 38,3 / 42,0 | +1,8 (noms propres : **+18,8**) |
| AAT termes français | 18,2 / 20,1 | 0,1 / 0,1 | +1,5 |
| WOLF + WoNeF F + DBnary filtré | 94,2 / 97,1 | 33,5 / 46,0 | +8,3 |
| WOLF + patrimoniaux | 89,5 / 95,0 | **51,1 / 60,0** | +3,6 |
| toutes | 97,4 / 98,4 | 62,7 / 74,6 | +11,5 |

Le classement est le même sur les deux corpus. Le vocabulaire d'Iconclass est plus général, donc mieux couvert par WOLF. Les absents de WOLF les plus fréquents y sont religieux : « sainte » (103 occurrences), mésaventure, palme, intercesseur, vœu, patronne, houlette, aspergès, ciboire. WoNeF et le Garnier en couvrent la plupart.

---

## 4. Expressions polylexicales

**Repérage** (mesuré). J'ai repéré les candidats par motifs : NOM ADJ, ADJ NOM, NOM de/à/en/sur… NOM, NOM de DÉT NOM, NOM PROPRE + NOM PROPRE. Seuil : 3 occurrences sur Joconde (728 candidats), 2 sur Iconclass (532). Sans tri, la couverture est faible partout : de 5 à 13 % des candidats.

**Jugement** (jugé). Les 160 candidats Joconde les plus fréquents ont été classés en 42 termes ou expressions lexicalisées (T), 21 noms propres (N), 85 combinaisons compositionnelles (C) et 12 artefacts du repérage (`jugements/joconde_expressions.tsv`).

| Couverture (% des expressions) | 42 termes (T) | 21 noms propres (N) |
|---|---|---|
| WOLF | 21,4 | 14,3 |
| WoNeF F-score | 31,0 | 4,8 |
| DBnary filtré | 26,2 | 0 |
| DBnary lexique | 57,1 | 19,0 |
| AAT pivot / AAT termes français | 11,9 / 16,7 | 0 / 0 |
| **Listes Joconde** | **45,2** | **42,9** |
| Garnier | 9,5 | 19,0 |
| Iconclass | 7,1 | 4,8 |
| WOLF + WoNeF F + DBnary filtré | 42,9 | 14,3 |
| **WOLF + patrimoniaux** | **64,3** | **52,4** |
| toutes | 71,4 | 57,1 |

- **Absents de tout, parmi les termes** : huile sur toile, huile sur bois, album factice, contacts positifs, tranches dorées, pâte siliceuse, trait d'encadrement, bois de forme, plat supérieur, portrait en buste, mise au carreau, camaïeu bleu.
- **Les listes Joconde couvrent même 14 % des combinaisons compositionnelles** (« encre brune », « craie blanche ») : ce sont des termes de la liste TECH. C'est l'effet attendu du biais de catalogage (§ 2.1).
- **Sur Iconclass**, les expressions fréquentes sont des formules de la classification (« attributs possibles », « personnage de l'antiquité », « dévotion personnelle »), que **ni** WOLF, **ni** WoNeF, **ni** DBnary ne contiennent.

---

## 5. Nombre de sens par lemme

Mesuré sur le corpus Joconde, sur les types présents dans chaque ressource, 4 catégories.

| Ressource | Moyenne | Médiane | Moyenne pondérée par les occurrences | Lemmes monosémiques | Verbes (moyenne pondérée) |
|---|---|---|---|---|---|
| WOLF | 5,18 | 3 | **9,33** | 22,7 % | 18,8 |
| WoNeF précision | 1,77 | 1 | 1,92 | 54,5 % | 2,1 |
| WoNeF F-score | 4,01 | 3 | 6,06 | 25,7 % | 5,3 |
| WoNeF couverture | 5,78 | 4 | 9,55 | 20,8 % | 17,3 |
| DBnary filtré | 2,40 | 2 | 3,30 | 47,0 % | 5,3 |
| DBnary brut | 14,5 | 7 | **24,3** | 12,6 % | 48,5 |
| AAT pivot (noms) | 4,32 | 3 | 6,24 | 23,6 % | — |
| Sens propres du Wiktionnaire (DBnary) | 5,37 | 4 | 8,83 | 14,9 % | 11,7 |
| Listes Joconde (concepts par forme) | 1,25 | 1 | 1,39 | 80,0 % | — |
| Garnier (concepts par forme) | 1,02 | 1 | 1,01 | 98,5 % | — |
| AAT, termes français (concepts par forme) | 1,25 | 1 | 1,38 | 79,2 % | — |

La valeur d'Iconclass (30 notations par mot-clé) ne compte pas des sens mais des sujets qui contiennent le mot.

**Lecture.** Les vocabulaires patrimoniaux sont presque monosémiques **à l'intérieur de leur domaine**. Ils ne disent rien des autres sens : « plat » n'y est que la pièce de vaisselle, alors que la notice parle d'une « assiette plate » (§ 8). Leur faible nombre de sens n'est donc pas une précision, c'est un **périmètre**.

---

## 6. Jugement des alignements proposés

### 6.1 Échantillon

Le tirage a été fait par `echantillon.py tirer`, avec la graine 20261128.
- **Lemmes** : 46, tirés parmi les types Joconde de fréquence ≥ 2 qui ont au moins une proposition. Stratification par catégorie (20 noms, 10 verbes, 8 adjectifs, 4 adverbes, 4 noms propres) et par tranche de fréquence (≥ 20, 5–19, 2–4).
- **Couples jugés** : pour chaque lemme, l'union des couples proposés par WOLF, WoNeF P, F et C, DBnary filtré et AAT pivot, avec 40 couples au plus par lemme. S'y ajoutent au plus 8 couples proposés **seulement** par DBnary brut. Total : **629 couples**. Les taux sont pondérés par l'inverse du taux de tirage.
- **Cotes** (jugé, `jugements/alignements.tsv`) : **O** = le mot français peut exprimer ce concept ; **~** = douteux, marginal ou relevant d'une forme voisine ; **X** = parasite. Comme dans l'étude, la cote juge le **couple hors contexte** ; le contexte est l'objet du § 8.

### 6.2 Précision par ressource

| Ressource | Couples jugés | O | ~ | **X** | Intervalle grossier de X (±, à 95 %, hors effet de grappe) |
|---|---|---|---|---|---|
| WOLF | 254 | 48,7 % | 16,7 % | **34,6 %** | ± 6 |
| WoNeF précision | 27 | 81,5 % | 14,8 % | **3,7 %** | de 1 à 18 |
| WoNeF F-score | 133 | 63,2 % | 19,5 % | **17,3 %** | ± 6,5 |
| WoNeF couverture | 270 | 42,2 % | 18,4 % | 39,5 % | ± 6 |
| DBnary filtré | 79 | 64,0 % | 18,6 % | **17,4 %** | ± 8,5 |
| AAT pivot | 54 | 51,9 % | 9,3 % | 38,9 % | ± 13 |
| DBnary brut | 462 | 21,8 % | 13,9 % | 64,3 % | ± 4,5 |

- Le taux de WOLF (34,6 %) **reproduit exactement** celui de l'étude (34,7 %), obtenu sur un autre corpus (les bancs) et un autre tirage.
- Les couples d'un même lemme ne sont pas indépendants : les intervalles réels sont plus larges.

**Par catégorie** (part de X).

| Catégorie | WOLF | WoNeF F | WoNeF C | DBnary filtré | DBnary brut |
|---|---|---|---|---|---|
| Noms | 38 % | 23 % | 43 % | 14 % | 61 % |
| Verbes | 44 % | 32 % | 48 % | 29 % | 73 % |
| Adjectifs | 2 % | 3 % | 3 % | 0 % | 25 % |

Les adjectifs tirés (octogonal, double, dernier, photographique, antique, divers, futur, pluriel) sont propres ; le faux ami « large » de l'étude ne tombait pas dans le tirage.

**Par méthode d'alignement** (couples jugés ; O / ~ / X).
- Sélecteurs de WoNeF :
  - `levenshtein` : 32 / 5 / 7 ;
  - `monosemous` : 35 / 13 / 6 ;
  - `uniq` : 12 / 3 / 1 ;
  - `multiplesource` : 60 / 17 / 27 ;
  - `simsyn1.4` : 16 / 18 / **30** ;
  - `simsyn2.1` : 15 / 4 / **20** ;
  - `hyperhypo*` : 18 / 5 / 16.
- Règles de DBnary filtré : `multi` (au moins deux traductions) : 30 / 7 / 6 ; `mono` (traduction monosémique) : 20 / 8 / 8.

**Les sélecteurs fondés sur la monosémie ou sur la forme sont fiables. Les sélecteurs de similarité (`simsyn`) et de hiérarchie (`hyperhypo`) sont la source principale du bruit des versions larges de WoNeF.** Un futur K peut donc pondérer un couple WoNeF selon son sélecteur, que donne `lnote`.

### 6.3 Silences constatés

Le sens du domaine manque à **toutes** les ressources alignées :
- « semis » au sens de motif répété (« semis de fleurs de lys ») ;
- « emboîtage » (étui de livre) ;
- « esquisser » un geste ;
- « Europe », la princesse mythologique ;
- « baguette », la moulure de cadre ;
- « devise », l'emblème héraldique avec sa maxime : il est proposé par WoNeF, mais pas par WOLF.

---

## 7. Erreurs corrélées

### 7.1 Mesure

Pour deux ressources A et B, on compare la part des erreurs de A que B propose aussi à la part des couples **corrects** de A que B propose aussi (couples jugés, non pondérés). Le **rapport** des deux parts dit ce que vaut l'accord de B pour A :
- un rapport proche de 0 : B est un bon second avis pour A, car il ne reprend pas ses erreurs ;
- un rapport proche de 1 : l'accord de B ne distingue rien, B copie A ou partage sa méthode.

| A → B | B propose X % des erreurs de A | B propose Y % des couples corrects de A | rapport |
|---|---|---|---|
| WOLF → WoNeF précision | 1,2 | 16,9 | 0,07 |
| WOLF → DBnary filtré | **3,6** | 34,7 | **0,10** |
| WOLF → WoNeF F-score | **6,0** | 46,8 | **0,13** |
| WOLF → WoNeF couverture | 16,7 | 67,7 | 0,25 |
| WOLF → AAT pivot | 8,3 | 21,0 | 0,40 |
| WOLF → DBnary brut | **60,7** | 94,4 | **0,64** |
| WoNeF F-score → DBnary filtré | 0 | 35,7 | 0,00 |
| WoNeF F-score → WOLF | 21,7 | 69,0 | 0,31 |
| WoNeF F-score → WoNeF couverture | 95,7 | 100 | 0,96 (versions emboîtées) |
| DBnary filtré → WOLF | 21,4 | 86,0 | 0,25 |
| AAT pivot → DBnary brut | **76,2** | 100 | **0,76** |
| AAT pivot → WOLF | 33,3 | 92,9 | 0,36 |

### 7.2 Ce que montrent les chiffres

1. **Le pivot anglais est la cause commune.**
   - **DBnary brut** reprend 61 % des erreurs de WOLF. WOLF s'est construit en partie avec le graphe des traductions du Wiktionnaire et avec des lexiques bilingues (étude, § 4.1) ; DBnary brut fait de même par construction. C'est **une erreur de méthode partagée**, pas une copie.
   - **L'AAT pivot** partage 76 % de ses erreurs avec DBnary brut, par le même mécanisme. « pierre » → *stones* → les synsets de *Stone*, des personnes, et de *stone*, l'unité de poids.
2. **Les erreurs que toutes les ressources font ensemble** viennent d'un mot anglais qui **appartient au synset** :
   - « salamandre » → `03975926-n` (*poker, fire hook, salamander*), proposé par WOLF, WoNeF P, F et C, l'AAT et DBnary ;
   - « construction » → *construction, twist* (une interprétation) ;
   - « pierre » → *stone*, l'unité de poids ;
   - « vis » → *screw propeller* ;
   - « fixer » → *fix, prepare* ;
   - « cueillir » → *pluck* (les cordes).

   Aucun vote ne les détecte : il faut une relecture humaine, ou la glose française de DBnary.
3. **WoNeF F-score et DBnary filtré sont de bons seconds avis pour WOLF** : rapports de 0,13 et 0,10. Leurs propres erreurs sont surtout des sélecteurs de similarité (WoNeF) ou des traductions dites monosémiques à tort (DBnary). Elles diffèrent de celles de WOLF.
4. **WoNeF n'est pas indépendant de WOLF par sa forme.** Son XML porte 8 586 définitions françaises qui viennent probablement de WOLF (non vérifié). L'étude avait aussi noté que WoNeF avait appris ses seuils sur une évaluation de WOLF. Dans les erreurs, cette dépendance ne se voit **pas** : 6 % de recouvrement.
5. **ConceptNet et BabelNet**, que l'étude avait exclus comme sources de corroboration, n'ont pas été mesurés.

### 7.3 Le vote propose et ordonne, il n'atteste pas

On compte les familles indépendantes qui proposent un couple : WOLF ; WoNeF (une seule famille pour ses trois versions) ; DBnary filtré ; AAT pivot. Couples de la strate principale, pondérés :

| Familles en accord | Poids | O | **X** |
|---|---|---|---|
| 1 | 352 | 20,8 % | **58,0 %** |
| 2 | 88 | 55,3 % | 20,8 % |
| 3 | 63 | 85,6 % | **9,6 %** |
| 4 | 5 | 100 % | 0 % |

Le vote **ordonne** bien : le taux d'erreur est divisé par six entre une et trois familles. Mais il laisse **un couple sur dix faux à trois voix**, précisément les erreurs du § 7.2, point 2. Cela confirme la consigne : le vote peut hiérarchiser, il ne vaut pas attestation (§ 11).

---

## 8. Couverture des sens utiles (30 occurrences en contexte)

**Protocole** (`contexte.py`). Tirage avec la graine 20261128 de 30 occurrences de mots pleins du corpus Joconde, un lemme au plus une fois : 14 noms, 7 verbes, 5 adjectifs, 2 adverbes et 2 noms propres. Pour chacune, j'ai noté le sens que **demande le contexte** :
- un synset WordNet 3.0, cherché dans WordNet même si aucune ressource ne le propose (« | » quand deux synsets conviennent) ;
- ou « - » si aucun n'existe ;
- et les ressources patrimoniales dont un **concept** correspond à ce sens.

C'est un jugement d'agent (`jugements/contexte.tsv`). Un sens est utile s'il est celui que le contexte demande.

| Ressource | Occurrences dont le sens utile est proposé (sur 30) |
|---|---|
| sens utile existant dans WordNet | 28 |
| **WOLF** | **22** (79 % des 28) |
| WoNeF précision / F-score / couverture | 8 / 15 / 18 |
| DBnary filtré / brut | 12 / 24 |
| AAT pivot | 3 |
| union des ressources alignées sur WordNet | 24 |
| WOLF + WoNeF F + DBnary filtré | 23 |
| listes Joconde / Garnier / Iconclass / AAT termes français | 6 / 4 / 2 / 3 |
| WOLF + patrimoniaux | 25 |
| **toutes** | **26** |

**Ce que montrent les 30 occurrences.**
- **Quand WOLF a le sens utile, il le noie.** La médiane est de 4 sens concurrents. Pour « faire une halte », il y en a 98 ; pour « restera désert », 38 ; pour « il s'appelait », 36. Couvrir le sens utile n'est pas le désigner.
- **Les gains sur WOLF viennent de ressources différentes selon le cas** :
  - « tardif » (Antiquité tardive) : le sens manque à WOLF ; DBnary brut le propose, et la liste Joconde EPOQ a l'affixe « tardif » ;
  - « Verne » : seulement DBnary ;
  - « colophon » (note finale d'un livre) : WordNet n'a que l'emblème d'éditeur, mais l'AAT a le bon concept ;
  - « satirique » (étiqueté nom par Stanza dans un titre indexé Garnier) : seulement le Garnier.
- **Silences de toutes les ressources** :
  - « pique-cierge » : WordNet a *pricket*, mais aucun alignement français ;
  - « notice » de catalogue : WOLF ne propose que « critique », WoNeF « mode d'emploi » ;
  - « le parc est aménagé » (*landscape*) ;
  - le colonel « Andrieu ».
- **Un faux positif patrimonial instructif** : la liste Joconde des auteurs contient un artiste « Andrieu (18..-18..?) ». C'est un **homonyme**, pas l'individu du texte. Un nom est un point d'identité, jamais une identité (INTERPRETATIONS_ADMISSIBLES § 5.2 et § 7.4).
- **Les vocabulaires patrimoniaux n'ont que le sens de leur domaine.** « plat » n'y est que la pièce de vaisselle, « bouchon » que l'objet de table, « date » qu'un type d'inscription. Dans le texte, il s'agit d'une assiette plate, d'un bouchon d'encastrement et de la date d'un événement.

**Par famille lexicale.** Sur ces 30 occurrences, les sens utiles sont : 6 `adj.all`, 5 `noun.artifact`, 3 `verb.change`, 2 `noun.person`, 2 `noun.communication`, 2 `adv.all`, 2 hors WordNet, et une occurrence pour chacune des autres familles. Les effectifs sont trop faibles pour conclure par famille (`contexte_resultats.json`, champ `par_famille`).

---

## 9. Les familles lexicales (fichiers lexicographiques de WordNet)

**Définition de la famille d'un type.** C'est le fichier lexicographique **majoritaire** parmi les synsets que lui proposent WOLF, WoNeF F-score et DBnary filtré. Les types sans aucune proposition forment la famille « inconnue ». Par construction, l'union WOLF + WoNeF F + DBnary filtré couvre donc 100 % de chaque famille, sauf « inconnue ». Les chiffres par ressource se comparent **entre eux** (corpus Joconde, % des types de la famille couverts).

| Famille | Types | Occ. | WOLF | WoNeF P | WoNeF F | DBnary filtré | AAT pivot | Joconde | Garnier | Iconclass | AAT fr | WOLF + patrimoniaux |
|---|---|---|---|---|---|---|---|---|---|---|---|---|
| noun.artifact | 1 247 | 10 800 | 84,9 | 41,8 | 92,4 | 74,2 | 56,9 | **65,6** | 45,4 | 53,6 | 60,5 | 96,7 |
| **inconnue** | 1 240 | 2 354 | 0 | 0 | 0 | 0 | 2,3 | 15,9 | 7,4 | 5,4 | 5,8 | **24,4** |
| adj.all | 784 | 5 682 | 76,4 | 42,2 | **94,5** | 69,0 | 0 | 22,3 | 10,1 | 14,8 | 7,1 | 84,8 |
| noun.person | 436 | 2 565 | 87,6 | 32,3 | 93,1 | 75,0 | 13,5 | 25,2 | 38,1 | 51,4 | 13,8 | 92,4 |
| noun.act | 425 | 2 601 | 84,2 | 34,8 | 94,4 | 68,2 | 17,4 | 35,3 | 34,8 | 44,2 | 18,4 | 90,8 |
| noun.communication | 293 | 2 997 | 92,8 | 38,6 | 94,2 | 74,1 | 36,5 | 40,3 | 27,3 | 45,4 | 37,2 | 95,9 |
| noun.attribute | 183 | 1 041 | 86,3 | 34,4 | 94,5 | 72,7 | 12,6 | 19,1 | 20,8 | 47,0 | 13,1 | 90,2 |
| verb.contact | 174 | 1 504 | **69,5** | 35,1 | 92,0 | 84,5 | 0 | 0 | 3,4 | 42,5 | 1,7 | 73,0 |
| adv.all | 161 | 1 321 | 95,7 | 59,6 | 85,1 | 79,5 | 0 | 4,3 | 2,5 | 5,0 | 3,1 | 96,3 |
| noun.animal | 152 | 598 | 90,1 | 45,4 | 86,2 | 67,1 | 16,4 | 44,7 | **69,7** | 64,5 | 19,1 | 97,4 |
| verb.change | 151 | 653 | 82,8 | 32,5 | 88,1 | 71,5 | 0 | 0,7 | 2,6 | 23,8 | 0 | 84,1 |
| verb.communication | 136 | 907 | 90,4 | 24,3 | 87,5 | 83,1 | 0 | 1,5 | 1,5 | 34,6 | 0 | 92,6 |
| adj.pert | 135 | 498 | 76,3 | 19,3 | 89,6 | 76,3 | 0 | 31,9 | 32,6 | 14,8 | 32,6 | 88,1 |
| noun.cognition | 121 | 752 | 95,9 | 36,4 | 97,5 | 69,4 | 17,4 | 20,7 | 27,3 | 57,9 | 18,2 | 99,2 |
| noun.group | 92 | 608 | 92,4 | 39,1 | 96,7 | 66,3 | 10,9 | 23,9 | 33,7 | 57,6 | 13,0 | 95,7 |
| noun.location | 88 | 764 | 89,8 | 38,6 | 88,6 | 73,9 | 8,0 | 36,4 | 38,6 | 40,9 | 8,0 | 96,6 |
| noun.plant | 81 | 467 | 96,3 | 42,0 | 81,5 | 70,4 | 24,7 | 44,4 | **76,5** | 51,9 | 24,7 | 100 |
| verb.motion | 81 | 398 | 81,5 | 25,9 | 90,1 | 79,0 | 0 | 2,5 | 3,7 | 39,5 | 2,5 | 81,5 |
| noun.body | 71 | 1 040 | 90,1 | 46,5 | 84,5 | 71,8 | 11,3 | 26,8 | 35,2 | 53,5 | 12,7 | 93,0 |
| verb.social | 70 | 461 | 85,7 | 17,1 | 80,0 | 91,4 | 0 | 2,9 | 1,4 | 25,7 | 1,4 | 90,0 |
| verb.creation | 66 | 945 | **71,2** | 13,6 | 80,3 | 74,2 | 0 | 1,5 | 0 | 25,8 | 0 | 71,2 |
| verb.cognition | 64 | 409 | 95,3 | 17,2 | 87,5 | 73,4 | 0 | 0 | 0 | 18,8 | 1,6 | 95,3 |
| noun.substance | 63 | 470 | 95,2 | 31,7 | 85,7 | 71,4 | 65,1 | **74,6** | 22,2 | 44,4 | 65,1 | 98,4 |
| noun.food | 62 | 199 | 91,9 | 29,0 | 83,9 | 62,9 | 16,1 | 50,0 | 54,8 | 59,7 | 16,1 | 96,8 |
| noun.time | 58 | 531 | 100 | 31,0 | 87,9 | 84,5 | 3,4 | 12,1 | 46,6 | 63,8 | 3,4 | 100 |
| verb.possession | 56 | 493 | 85,7 | 28,6 | 87,5 | 87,5 | 0 | 0 | 3,6 | 35,7 | 0 | 85,7 |
| noun.state | 51 | 226 | 94,1 | 31,4 | 92,2 | 68,6 | 3,9 | 15,7 | 33,3 | 62,7 | 3,9 | 96,1 |
| verb.stative | 47 | 571 | 93,6 | 34,0 | 80,9 | 89,4 | 0 | 0 | 0 | 14,9 | 0 | 93,6 |
| noun.object | 44 | 324 | 88,6 | 59,1 | 95,5 | 84,1 | 9,1 | 36,4 | 59,1 | 68,2 | 9,1 | 90,9 |
| noun.event | 42 | 170 | 88,1 | 23,8 | 92,9 | 54,8 | 4,8 | 9,5 | 40,5 | 59,5 | 4,8 | 95,2 |

Les familles plus petites (de 27 à 1 type : `noun.quantity`, `verb.body`, `verb.perception`, `noun.possession`, `noun.feeling`, `verb.competition`, `verb.consumption`, `noun.Tops`, `verb.emotion`, `noun.shape`, `noun.phenomenon`, `noun.process`, `noun.relation`, `verb.weather`, `noun.motive`) sont dans `mesures.json`, champ `familles_types`. Les mêmes tableaux existent pour le corpus Iconclass.

**Précision des alignements par famille** (couples jugés, part de X ; seules les familles avec au moins 10 couples jugés pour WOLF).

| Famille | WOLF | WoNeF C | DBnary brut |
|---|---|---|---|
| adj.all | **2,6 %** (n = 38) | 2,8 % | 21,7 % |
| noun.artifact | 33 % (24) | 45 % | 50 % |
| noun.communication | 10 % (10) | 64 % | 42 % |
| adv.all | 33 % (12) | — | 54 % |
| noun.person | **53 %** (15) | 22 % | 74 % |
| verb.change | 49 % (20) | 54 % | 79 % |
| verb.communication | 37 % (15) | 13 % | 76 % |
| verb.contact | 52 % (17) | 40 % | 67 % |
| verb.stative | 35 % (13) | 19 % | 41 % |

Pour WoNeF F, DBnary filtré et l'AAT pivot, les effectifs sont faibles : voir `echantillon_resultats.json`, champ `par_lexname`. Le bruit de WOLF sur `noun.person` vient des homonymes propres du pivot anglais (*King*, *Stone*, *Peter* pour « pierre »).

**Proposition pour évaluer des corrections futures sur des familles indépendantes.** On peut regrouper les familles en deux lots de taille comparable, qui mêlent noms et verbes :
- **lot A** : `noun.artifact`, `noun.act`, `noun.attribute`, `verb.contact`, `verb.change`, `verb.creation`, `adj.pert` ;
- **lot B** : `noun.person`, `noun.communication`, `noun.cognition`, `noun.animal`, `noun.plant`, `verb.communication`, `verb.motion`, `verb.social`, `adv.all`.

Une correction conçue sur le lot A serait mesurée sur le lot B, et réciproquement, et toujours sur un corpus qui n'a pas servi à la concevoir : le tirage Joconde ci-dessus, ou un nouveau tirage avec une autre graine en excluant celui-ci. Pour une correction du **vocabulaire** plutôt que des **alignements**, la famille « inconnue » (1 240 types, sans proposition alignée) est un lot à part.

---

## 10. Licences

| Ressource | Licence | Statut | Usage hors ligne | Redistribution, et conséquence pour K |
|---|---|---|---|---|
| WOLF (OMW 1.4) | CeCILL-C | vérifié (local), étude | libre | couche séparable ; ses modifications restent sous CeCILL-C |
| **WoNeF 0.1** | **CC BY-SA 3.0 FR (site) / LGPL-LR (article)** | vérifié (site), vérifié dans l'étude (article) ; **discordance** | libre | à traiter comme CC BY-SA, la plus contraignante, jusqu'à clarification écrite ; couche séparée, partage à l'identique |
| DBnary (Wiktionnaire) | CC BY-SA 4.0 (données) ; MIT (extracteurs) | vérifié (page about-dbnary) | libre | couche séparée sous CC BY-SA ; attribution au Wiktionnaire |
| Listes Joconde (16) | Licence ouverte Etalab | vérifié (page du ministère) ; l'export Turtle ne porte aucun triplet de licence | libre | attribution (« Service des musées de France ») ; compatible avec une diffusion libre |
| **Garnier, PDF** | site : « sauf mention contraire, contenus sous licence etalab-2.0 » ; mais **le PDF numérise un ouvrage publié en 1984 par Le Léopard d'Or**, sans mention de licence dans les pages lues | **à confirmer** | lecture seulement | ne rien redistribuer du PDF avant confirmation ; utiliser th285 (Licence ouverte) |
| Garnier, liste th285 | Licence ouverte Etalab (c'est l'une des 16 listes) | vérifié | libre | comme Joconde |
| Iconclass | CC0 1.0 | vérifié (local) | libre | sans condition |
| AAT | ODC-By 1.0 | vérifié (local) | libre | attribution au J. Paul Getty Trust et aux contributeurs cités |

**Conséquence.** Trois licences demandent un **partage à l'identique** : WoNeF sous sa licence de site, DBnary et, s'il était un jour utilisé, ConceptNet. Il faut donc, dès la conception de l'interface K (§ 11), que chaque fait sache **de quelle couche de licence il dépend**. Un couple qui ne serait attesté que par un vote WoNeF + DBnary relèverait de CC BY-SA.

---

## 11. Esquisse de l'interface K fédérée (**proposition**, sans code)

### 11.1 Principes, tirés de la consigne et des mesures

1. **K fédère, il ne fusionne pas.** Chaque ressource reste une **source** versionnée, lue telle quelle, et chaque fait garde sa provenance. On ne reconstruit pas d'ontologie générale. WordNet sert d'inventaire de sens anglais ; WOLF, WoNeF et DBnary de lexicalisations françaises proposées ; Joconde, Garnier, l'AAT et Iconclass de vocabulaires de concepts propres.
2. **Le vote propose ou ordonne, il n'atteste jamais.** Les mesures le justifient : 9,6 % d'erreurs à trois voix (§ 7.3), et des erreurs communes à toutes les ressources (§ 7.2).
3. **Une absence vaut « inconnu ».** Environ 20 % des absences mesurées sont des erreurs de lemmatisation (§ 2.2), et le reste des lacunes de ressources (§ 3). Aucune absence n'est un fait de langue.
4. **L'ontologie de travail propre ne contient que les distinctions dont le raisonnement a besoin**, et chacune est reliée aux ressources par des alignements, eux aussi sourcés.

### 11.2 Le fait fédéré

Chaque entrée de K aurait la forme :

```
fait(
  type,           % lexicalisation | relation | alias | distinction | incompatibilite |
                  % restriction_de_selection | typique | alignement_concept
  arguments,      % des sens : wn30:…, aat:…, joconde:…, iconclass:…, wikidata:…, oc:…
  source: {ressource, version, empreinte_sha256, element},   % ex. wonef_f, 0.1, 6f69ab14…, synset/literal
  methode: {nature, detail},
                  % nature ∈ alignement_automatique | vote | relecture | redaction
                  % detail : pivot anglais, sélecteur WoNeF (lnote), règle DBnary (mono|multi),
                  % libellé de thésaurus, liste des sources votantes…
  statut,         % propose | attesté | rejeté
  attestation,    % pour « attesté » ou « rejeté » seulement : qui, quand, sur quel texte,
                  % avec quel guide
  couche_licence  % CC0 | Etalab | ODC-By | CeCILL-C | CC-BY-SA | projet
)
```

- **`propose`** est le statut de tout ce qui vient d'un alignement automatique (WOLF, WoNeF, DBnary, l'AAT par pivot) ou d'un vote. Un fait `propose` peut **ordonner** les hypothèses : c'est le module de préférences de INTERPRETATIONS_ADMISSIBLES § 9.3, que la certification ne consulte pas. Il peut aussi **ouvrir** une lecture. Il ne peut ni établir ni exclure.
- **`attesté`** ne s'obtient que par une **relecture humaine nommée**, ou par une ressource dont le fait est lui-même une décision éditoriale humaine : un libellé de thésaurus pour son propre concept (le concept TECH « lavis » est attesté **comme concept Joconde**, pas comme synset WordNet), une notation Iconclass pour son propre texte, une identité Wikidata.
- **`rejeté`** est un fait positif : « la relecture du jj/mm a établi que `fr:large` n'exprime pas `wn30:01382086-a` ». Il est sourcé comme une attestation. Seul un rejet peut retirer une lexicalisation proposée ; une absence ne le peut pas.
- **Le vote** est un fait dérivé, de méthode `vote`, qui liste ses votants et leurs **familles** (WOLF, WoNeF, DBnary, AAT ; les trois versions de WoNeF forment une seule famille, et DBnary brut ne vote pas). Il porte un rang, jamais un statut. Ses poids peuvent venir des mesures : rapports du § 7.1, précision par sélecteur du § 6.2.
- **Les K nommés** (NOTATION_REFERENCE § 5) deviennent des **ensembles de sources et de statuts**. Par exemple :
  - `K0-d30` = WordNet 3.0 + WOLF, tout en `propose` ;
  - `K1` = K0 + WoNeF F + DBnary filtré + les vocabulaires patrimoniaux, en `propose`, + les `attesté` et `rejeté` d'une relecture donnée.

  Un statut démontrable se lit toujours relativement à un K nommé.

### 11.3 L'ontologie de travail propre : les seules distinctions retenues

Elles sont tirées de `docs/INTERPRETATIONS_ADMISSIBLES.md` (IA) et de `docs/NOTATION_REFERENCE.md` (NR). Chacune est un concept `oc:` (NR § 1), défini avec sa glose et ses alignements connus, et rien de plus.

| Distinction | Pourquoi le raisonnement en a besoin | Ressources à aligner (faits `propose` ou `attesté`) |
|---|---|---|
| **Individu documenté / figure / mention** | la coréférence ne traverse pas les situations ; `meme_individu` sans fusion (IA § 7.4) | Wikidata (individus), listes Joconde AUTR, Garnier (noms) ; homonymes possibles (« Andrieu », § 8) |
| **Nom propre comme point d'identité**, avec `alias` et `distinction` | « St John » n'est pas un individu (IA § 5.2) ; les distinctions documentaires excluent (IA § 4.2, point 3) | Wikidata, Iconclass `11H(…)`, ULAN plus tard |
| **Types disjoints utilisés par les restrictions de sélection** : animé / artefact / lieu / substance | seule source d'exclusion de sens, avec son domaine de validité (IA § 4.2 et § 4.5) | grands nœuds WordNet (`noun.person`, `noun.artifact`…), facettes de l'AAT |
| **Contexte figuré / autre contexte** (source, contrat, rêve, vision) | la satisfaction est relative à un chemin ; le silence ou une négation dans un autre contexte ne vaut rien (IA § 6.5 et § 7) | aucune ressource ; rédigé dans K |
| **Œuvre et support / contenu figuré** : technique, matériau, dénomination, partie de l'objet (recto, revers, cadre), d'un côté ; ce qui est représenté, de l'autre | sans elle, « lavis », « plat », « bouchon », « recto » se lisent comme des objets représentés (§ 8) ; elle découle de la séparation entre contexte figuré et monde réel (IA § 7), c'est une extension que je propose | listes Joconde TECH, DENO, INSC ; AAT (facettes Objets, Matériaux, Processus et techniques) |
| **États incompatibles indexés** : debout / assis / couché, mort / vivant, éveillé / endormi, nu / vêtu ; avec porteur, moment, contexte | seul appui négatif attesté (IA § 6.1 à 6.3 ; NR § 5) | antonymie de WordNet **proposée** seulement ; l'incompatibilité est rédigée et attestée dans K |
| **Antonymie / incompatibilité / opposition typique**, trois relations distinctes | l'antonymie ne suffit jamais à exclure (IA § 6.1) | WordNet (pointeur `!`) → `propose` |
| **Relation typique** (attributs des saints, préférences) | préférence, jamais exclusion (IA § 4.3) | Iconclass (« attributs possibles »), Wikidata P4185 |
| **Inclusion entre sens et partie de** | les requêtes typées par des sens s'atteignent par inclusion (IA § 5.2) | hiérarchie WordNet (importée) ; hiérarchies des thésaurus (importées comme relations **internes** à chaque thésaurus) |

**Ce qu'on ne construit pas.** Aucune taxonomie générale propre. Les hiérarchies de WordNet, de l'AAT, du Garnier et des listes Joconde sont **lues**, chacune dans son espace de noms. Elles ne sont reliées entre elles que par des **alignements de concepts** sourcés, statut `propose` par défaut. Une distinction n'entre dans l'ontologie propre que si un cas en démontre le besoin.

### 11.4 Une absence vaut « inconnu »

- Ni la recherche d'un lemme sans résultat, ni un sens absent de toutes les ressources, ni un concept patrimonial sans alignement WordNet ne produit une exclusion. Ils produisent **`inconnu`**, avec la liste des sources interrogées et leurs versions, ce qui rend l'inconnu reproductible.
- Les vocabulaires patrimoniaux sont **sectoriels** (§ 5 et § 8). Que « plat » n'y soit que de la vaisselle ne dit rien d'autre. Chaque source déclare son **périmètre** (IA § 9.3, « déclaration de complétude par lexique ») ; hors de ce périmètre, son silence n'est pas consulté.

---

## 12. Ce que les mesures suggèrent pour la suite (propositions)

1. **Ajouter, en `propose`** :
   - **WoNeF F-score**, avec son sélecteur en `methode.detail` ;
   - **DBnary filtré**, avec la glose française du sens du Wiktionnaire quand elle existe ;
   - les **listes Joconde** et **th285** pour la technique, les dénominations et les noms propres ;
   - l'**AAT** (termes français) pour les concepts d'objets et de techniques.

   Tous sont mesurés ici sur des textes indépendants des bancs.
2. **Ne pas ajouter** WoNeF couverture, DBnary brut ni l'AAT par pivot comme sources de lexicalisation. Leur bruit est de 39 à 64 % et il est corrélé à celui de WOLF. Ils peuvent servir à des propositions en dernier rang.
3. **Avant toute relecture** :
   - lever la **discordance de licence de WoNeF** (§ 10) ;
   - confirmer la **licence du PDF Garnier** ;
   - remplacer, pour la reproductibilité, le lemmatiseur statistique par un lexique (Lefff ou DBnary), dont 20 % des absences mesurées dépendent.
4. **Si une relecture est décidée** :
   - elle porte sur des couples `propose` **ordonnés par le vote** (§ 7.3) : les couples à une seule voix d'abord, car 58 % d'entre eux sont faux ;
   - et sur les erreurs **communes à toutes les ressources** (§ 7.2), qu'aucun vote ne verra.

   On l'évalue sur le lot de familles qui ne l'a pas inspirée et sur un corpus tiré à part (§ 9). Les jugements de cette mesure sont faits par un agent seul : ils peuvent servir d'**amorce de guide**, pas de vérité de référence.

---

## 13. Reproduction

Les scripts sont dans `outils/ressources/`. Ils ne lisent les données qu'en lecture, ont leurs graines fixées et se lancent avec `python3 -I`. Ils écrivent dans `/home/user/donnees/mesure_ressources_lexicales/`.

```
python3 -I outils/ressources/manifeste.py          # MANIFESTE.json de chaque ressource (empreintes)
python3 -I outils/ressources/lexiques.py           # lexiques/*.tsv (WOLF, WoNeF, DBnary, Joconde, Garnier th285, Iconclass, AAT)
python3 -I outils/ressources/corpus.py             # corpus/ : tirages (graine 20261128) et lemmatisation Stanza
python3 -I outils/ressources/mesurer.py            # mesures.json, *_types.tsv, *_expressions.tsv
python3 -I outils/ressources/echantillon.py tirer       # fiche_alignements.tsv (629 couples)
python3 -I outils/ressources/echantillon.py depouiller  # echantillon_resultats.json (précision, corrélations, vote)
python3 -I outils/ressources/echantillon.py absents     # bruit de lemmatisation (40 types)
python3 -I outils/ressources/contexte.py tirer          # fiche_contexte.txt (30 occurrences)
python3 -I outils/ressources/contexte.py depouiller     # contexte_resultats.json
```

| Fichier | Contenu |
|---|---|
| `commun.py` | lecture de WordNet 3.0 (WNDB), normalisation, index de recherche |
| `jugements/alignements.tsv` | 629 couples cotés O / ~ / X (jugé) |
| `jugements/contexte.tsv` | 30 sens utiles (jugé) |
| `jugements/joconde_expressions.tsv` | 160 expressions T / N / C / A (jugé) |
| `jugements/absents_wolf.tsv` | 40 absents M / L / F / E (jugé) |

**Empreintes des corpus tirés** : textes Joconde `1067b5a6d131ce62…` ; textes Iconclass `99334eee2b27b77b…` (`corpus/manifeste.json`).

**Durée d'exécution** : environ 3 minutes pour DBnary, 25 minutes pour la lemmatisation Stanza sur 4 cœurs, moins d'une minute pour le reste.
