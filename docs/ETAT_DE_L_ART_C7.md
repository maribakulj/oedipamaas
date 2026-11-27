# État de l'art et ressources pour la couche sémantique C7

> **Statut.** Étude préparatoire de la phase C3/C6/C7, demandée par le propriétaire le 27/11, faite par un agent de
> recherche (sources publiques, et comptages en lecture seule sur les ressources installées hors du dépôt, marqués
> [L]). Vérifié à part, en exécutant le code : l'exemple de *deposition* (§ 0, preuve 2) — avant le lot 2,
> `nominalisation/3` donnait pour « deposition » les verbes *depose* et *deposit*, et « Deposition of Christ »
> produisait par défaut l'événement « depose » (destituer) ; après le lot 2, aucun ajout. Les licences et les
> chiffres signalés au § 12 restent à confirmer avant toute redistribution. Les recommandations sont des
> propositions : chaque brique retenue sera évaluée par un lot ciblé, avec ses mesures.


*Étude du 26 novembre 2026. Ce document ne modifie rien dans le dépôt.*

---

## 0. Résumé

**Le constat.** Aucune brique existante ne donne directement ce que demande C7 : une transformation du graphe qui soit
**hors ligne, sur CPU, en français et en anglais**, qui ne choisisse **jamais un sens en silence**, et qui donne à
chaque assertion dérivée sa **provenance** et son **statut** (certain ou hypothétique).

- Les **analyseurs sémantiques neuronaux** (AMR, UMR, UCCA, rôles sémantiques) rendent une analyse unique, avec des
  scores non calibrés.
- Leur qualité en français est faible. Les rôles PropBank projetés en français atteignent **50,2 de F1** sur les
  arguments (UP 2.0, § 5.3), et un analyseur AMR français sans données françaises obtient **54 à 66 Smatch** (§ 4.2).
- Les meilleurs modèles de sens des mots et de rôles sont sous licences **non commerciales** (CC BY-NC-SA ou
  CC BY-NC), incompatibles avec une diffusion sous MIT.

**Ce qui est utile.** Les **lexiques formels** contiennent les informations qui manquent aujourd'hui à
`normalisation.pl`, et ils se lisent de façon déterministe :

- **NOMLEX-PLUS / NomBank** : comment le complément d'un nom d'action réalise les arguments du verbe ;
- **PropBank (cadres unifiés) et VerbNet** : agent ou thème pour le participant unique d'un verbe intransitif ;
  rôles thématiques ;
- **Démonette-2 et Verb∋Net** : la dérivation et les classes verbales pour le français ;
- **règles de réécriture de graphes (Grew)** : passer de la syntaxe de surface à une syntaxe profonde.

**Quatre preuves concrètes**, tirées des ressources installées dans `/home/user/donnees` (comptages faits pour cette
étude, § 3.3 et § 3.6) :

1. **La règle « complément du nom d'action = patient » est fausse.** Dans les libellés anglais d'Iconclass, 597 noms
   d'action de NOMLEX-PLUS sont suivis de « of » (8 300 occurrences). Pour 79 d'entre eux, NOMLEX-PLUS dit que
   « of » peut réaliser le **sujet** du verbe (*death*, *arrival*, *flight*, *fall*, *return*, *temptation*…).
2. **La dérivation de WordNet n'est pas une équivalence.** *deposition* (la Déposition de croix, en histoire de l'art)
   a dans WordNet 3.0 deux sens de lexfile `noun.act`. Ils sont liés par dérivation à *depose* (« destituer ») et à
   *deposit / situate*. Selon la définition de `nominalisation/3`, « Deposition of Christ » peut donc produire
   l'événement « destituer le Christ », et le produire comme une prémisse certifiable.
3. **La correspondance « est dans le dictionnaire » ne vaut pas « a ce sens ici ».** NOMLEX-PLUS donne *cross*,
   *head*, *hand* et *figure* pour des nominalisations verbales. Ce sont aussi des mots parmi les plus fréquents des
   libellés d'Iconclass, où ils désignent des objets.
4. **WordNet a des sens d'artefact absents pour les sujets iconographiques.** *crucifixion* y a trois sens, dont aucun
   n'est « une représentation de la Crucifixion ». Or, dans un cartel, « une Crucifixion » est souvent un tableau.

**La recommandation.** C7 doit être une couche **« proposer, licencier, vérifier »** :

- **Proposer** : des analyses (UD, puis syntaxe profonde) et des ensembles de lectures lexicales candidates, jamais
  un choix.
- **Licencier** : une règle de dérivation n'est **certaine** que si **toutes** les lectures que donnent les lexiques
  (sens, cadres, réalisations des arguments) concordent. C'est la règle D30 étendue aux rôles et aux
  nominalisations. Sinon, l'assertion dérivée est une **hypothèse rattachée à l'occurrence**, avec sa provenance ;
  cela corrige L1 et L3 ensemble.
- **Vérifier** : c'est le noyau existant.

Trois développements propres à Oedipamaas sont justifiés, faute d'équivalent :

- le **licencieur épistémique** lui-même ;
- une **table « NomLex-FR » restreinte** au vocabulaire d'action d'Iconclass et des cartels : aucune ressource
  française ne donne la réalisation des arguments des noms déverbaux ;
- les **données de référence du domaine**.

Le premier lot à évaluer : les nominalisations (L2 et L3), puis le participant unique, puis la syntaxe profonde.

**Ce que les rôles sémantiques neuronaux et la désambiguïsation neuronale peuvent faire.** Ce sont au mieux des
**instruments d'évaluation** (détecteurs de désaccord) ou des **classeurs d'hypothèses**. Ils ne fondent jamais de
prémisse.

---

## 1. Le problème posé par le dépôt

Le problème a été relu dans `docs/ASSERTIONS.md`, `docs/PLAN_V1.md` (C3, C6, C7), `docs/NOYAU.md` § 2,
`docs/QUALIFICATION_NOYAU.md` § 10 et dans les en-têtes de `normalisation.pl` et `interpretation.pl`.

- **Le graphe** est composé d'entités, de noms, de propriétés, d'événements et de rôles (agent, patient, thème,
  instrument, destinataire, lieu), de relations orientées, de `coref`, `distinct`, `nombre`, d'alternatives, et de
  quatre qualificatifs obligatoires (polarité, modalité, portée, énonciateur).
- **Une prémisse admissible** est positive, affirmée, de portée `represente`, d'énonciateur `auteur`, et appartient à
  aucune alternative.
- **D30** (NOYAU § 2) : un mot n'établit de façon certaine que ce que **tous** ses sens conceptuels impliquent ;
  sinon, il ne fonde qu'une hypothèse `sens_suppose`.
- **L1** : les hypothèses de sens sont rattachées aux lemmes, pas aux occurrences.
- **L2** : `normalisation.pl` fait des inférences non valides :
  - R2 : le participant unique d'un événement reçoit à la fois agent, thème et patient ;
  - E2 : le complément d'un nom d'action est lu comme son patient ;
  - E1 et E2 : une dérivation morphologique est prise pour une équivalence.
- **L3** : les assertions dérivées n'ont ni provenance ni statut.
- **C7** (PLAN § 3) se compose de trois problèmes : le lexique bilingue (WOLF), la désambiguïsation et la
  normalisation des événements et des relations. Toute ressource passe par une **interface unique**
  (`concept/2`, `lexicalisation/3`, `sous_classe/3`, `relation_semantique/4`). Elle n'est ajoutée que si une
  **famille d'erreurs mesurée** la demande, et elle ne doit faire perdre **aucune précision**.
- **Les ressources déjà installées** (D17, `docs/INSTALLATION.md`) : WordNet 3.0, les liens morphosémantiques
  (17 739 compilés), WOLF par OMW 1.4 (102 671 paires ; licence CeCILL-C, lue dans
  `omw-1.4/fra/LICENSE`), VerbNet 3.3, FrameNet 1.7 et NomBank 1.0 (rapatriés, pas encore intégrés), UDPipe 1 et
  Stanza 1.10.1.
- **Le code est sous MIT.** D7 a déjà noté que les modèles UDPipe 1 (UD 2.5) sont sous CC BY-NC-SA.

**La question à laquelle C7 doit répondre.** Ce n'est pas « quelle est la meilleure analyse sémantique », mais
**« quelles transformations du graphe sont licenciées par des ressources vérifiables, et avec quel statut »**. Un
outil qui donne un seul étiquetage, même juste à 90 %, ne répond pas à cette question tel quel.

---

## 2. Méthode et conventions

- **Le classement** de chaque brique :
  - **(a)** réutilisable tel quel ;
  - **(b)** réutilisable avec adaptation (ce qu'il faut faire est dit) ;
  - **(c)** insuffisant pour notre problème (pourquoi est dit, avec la preuve).
- **Le niveau de preuve** de chaque fait :
  - **[V]** vérifié pendant l'étude sur la page officielle, le dépôt ou l'article ;
  - **[S]** source secondaire (un article qui cite, un miroir, un moteur de recherche) ;
  - **[L]** compté par moi sur les fichiers déjà installés dans `/home/user/donnees`, hors du dépôt (comptages
    indicatifs, faits avec des scripts simples non relus par un tiers) ;
  - **[NV]** non vérifié : je n'ai pas pu confirmer.
- **Aucun chiffre n'est donné sans source.** Les numéros entre crochets renvoient à la section 13.
- **Rien n'a été téléchargé** au-delà de pages web et de trois PDF d'articles, lus en texte. Les requêtes web ne
  portaient que sur des termes techniques génériques.
- **La compatibilité de licence** est jugée par rapport à un code sous MIT et à une base de connaissances compilée que
  l'on voudrait pouvoir redistribuer. Les licences **NC** (non commerciales) excluent la diffusion commerciale ; les
  licences **SA** (partage à l'identique) s'imposent aux données dérivées, pas au code ; la **GPL v3** est compatible
  si l'outil est appelé comme programme séparé. Ceci est une lecture technique, **pas un avis juridique**.

---

## 3. Lexiques de prédicats, de rôles, de valence et de dérivation

### 3.1 FrameNet (Berkeley), French FrameNet (ASFALDA), CALOR

| | FrameNet 1.7 | French FrameNet (ASFALDA) | CALOR |
|---|---|---|---|
| Contenu | cadres, éléments de cadre, unités lexicales, phrases annotées | cadres de FrameNet annotés sur le French Treebank | corpus encyclopédique d'histoire, en français, annoté en cadres de FrameNet |
| Taille | 1 222 fichiers de cadres, 13 572 unités lexicales (5 529 noms, 5 176 verbes, 2 392 adjectifs) [L] ; environ 200 000 phrases annotées [S][24] | 98 cadres, 662 mots déclencheurs, 872 sens, environ 13 000 cadres annotés [S][2] ; version 1.3 en ligne [V][3] | 1,3 million de mots, quatre sources [S][27] |
| Langue | anglais | français | français |
| Licence | CC BY 3.0 (`docs/INSTALLATION.md`) | **non dite** ; données « sur demande » [V][3] ; le French Treebank a ses propres conditions [NV] | DOI TIB [S][27] ; licence [NV] |
| Analyseurs | Open-SESAME ; frame-semantic-transformer (T5) : sur le test de FrameNet 1.7, identification du cadre 0,86 (T5-small) et 0,89 (T5-base), arguments 0,73 et 0,75 ; Open-SESAME : 0,87 et 0,61 [V][25] ; LOME (XLM-R, multilingue, Docker) [S][26] | aucun analyseur public trouvé [NV] | CRF, BiLSTM (2018) [S][27] |

**Ce que montrent les données installées [L].** J'ai cherché des mots de notre domaine dans l'index des unités
lexicales de FrameNet 1.7 :

- *crucifixion* et *crucify* sont dans **Killing** ;
- *baptism* est dans **Rite**, *abduction* dans **Kidnapping**, *adoration* dans **Experiencer_focus** ;
- *annunciation*, *martyrdom* et *flagellation* sont **absents** ;
- *hold* figure dans au moins sept cadres (Detaining, Containing, Manipulation, Opinion…).

FrameNet est donc à la fois **lacunaire** pour l'iconographie et **très polysémique** pour les verbes de base.

**Classement.**

- **FrameNet : (b), pour les paraphrases seulement.**
  - La hiérarchie de cadres (« Inheritance », « Using ») et les éléments de cadre partagés entre verbes et noms d'un
    même cadre sont une source de paraphrases entre prédicats : *kill / slay / execution* dans Killing.
  - Adaptation : l'utiliser **seulement** comme source de relations `relation_semantique(Prédicat1, meme_cadre,
    Prédicat2, framenet)`, et seulement au statut d'**hypothèse**. Deux unités d'un même cadre ne sont pas
    synonymes ; un cadre n'est pas une implication.
  - C'est utile à C9 (abduction) et à la mesure du rappel, pas à des preuves.
- **ASFALDA : (c) pour l'exécution, (b) pour l'évaluation si les données sont obtenues.** La couverture est petite
  (98 cadres), la licence n'est pas publiée, et les données sont sur demande.
- **CALOR : (b) comme données d'évaluation françaises hors du domaine**, si la licence le permet.
- **Les analyseurs de FrameNet : (c) comme source de prémisses.**
  - Ils sont en anglais seulement (frame-semantic-transformer) ou lourds (LOME, XLM-R).
  - Ils ne rendent qu'une seule analyse.
  - Les arguments sont justes à environ 0,75 de F1 au mieux [V][25] : environ un argument sur quatre est faux ou
    manquant.

### 3.2 VerbNet et Verb∋Net (VerbNet du français)

| | VerbNet | Verb∋Net (VerbeNet) |
|---|---|---|
| Version | 3.4 sur GitHub, « la plus récente » [V][5] ; 3.3 « dernière version publique » sur le site [V][6] | dépôt `aymara/verbenet` [V][7] |
| Taille | 329 fichiers de classes dans la 3.3 [L] ; dans la version étendue : 23 rôles thématiques, 94 prédicats sémantiques, 5 257 sens de verbes, 3 769 lemmes [V][6] | 229 classes, 97 sous-classes, 525 cadres, 4 177 paires verbe-classe, 2 827 verbes [V][7] |
| Contenu | classes de Levin, rôles thématiques, restrictions de sélection, cadres syntaxiques, sémantique en prédicats | classes et rôles portés sur le français à partir de LVF et du Lexique-Grammaire [S][8] |
| Licence | licence 3.0 de l'Université du Colorado, permissive, usage commercial permis [S][4] | **CC BY-SA 4.0** [V][7] |
| Format | XML, API Python | XML VerbNet, JSON Lines, paquet `pip`, jeux de données Hugging Face [V][7] |

**Classement.**

- **VerbNet : (b).**
  - Il donne la **table de correspondance entre rôles** : VerbNet distingue `Agent`, `Patient` et `Theme`. Le
    lecteur et le compilateur de libellés doivent projeter ces rôles sur les six rôles d'Oedipamaas **de la même
    façon**.
  - Il donne, avec PropBank, le rôle du participant unique d'un intransitif (§ 3.3).
  - Ses restrictions de sélection (`+animate`, `+concrete`) peuvent **écarter** des sens. Ce n'est permis que si la
    restriction est violée par **toutes** les lectures de l'argument ; sinon, elles ne font que classer des
    hypothèses.
  - Adaptation : il faut une table VerbNet → rôles Oedipamaas écrite **une fois**, versionnée, et appliquée des deux
    côtés (C3 et C7).
- **Verb∋Net : (b).** C'est la seule ressource libre trouvée qui donne des **rôles thématiques** à des verbes
  français.
  - Sa couverture (2 827 verbes) est à mesurer sur les verbes des libellés français d'Iconclass et des cartels.
  - La licence CC BY-SA s'impose à la base compilée qui en dériverait.

### 3.3 PropBank, NomBank, NOMLEX et NOMLEX-PLUS

| | PropBank (cadres unifiés) | NomBank 1.0 | NOMLEX-PLUS |
|---|---|---|---|
| Contenu | cadres numérotés (ARG0, ARG1…) unifiés pour les verbes, les noms, les adjectifs et les verbes supports [S][9] | arguments des noms du Penn Treebank ; chaque cadre nominal pointe vers son verbe (`source="verb-die.01"`) et sa classe VerbNet (`vncls`, `vntheta`) [L] | pour chaque nominalisation : le verbe, le type (VERB-NOM, SUBJ-NOM…), et pour chaque cadre, comment le sujet et l'objet du verbe sont réalisés dans le groupe nominal (DET-POSS, N-N-MOD, PP « of », « by ») [L][11] |
| Taille | v3.4 [V][9] ; 8 815 cadres distincts entre PropBank et NomBank [S][10] | 114 576 propositions sur 202 965 occurrences de noms [V][12] ; 4 706 fichiers de cadres [L] | 8 084 entrées dont 3 946 VERB-NOM [L] ; environ 1 000 entrées dans NOMLEX et environ 6 000 ajoutées [S][11] |
| Licence | **CC BY-SA 4.0** [V][9] | cadres « distribués avec permission » (NYU, `docs/INSTALLATION.md`) ; le corpus annoté demande une licence LDC du Treebank [V][12] | inclus dans le paquet NomBank de NLTK [L] ; licence propre [NV] (pages de NYU indisponibles pendant l'étude) |
| Langue | anglais | anglais | anglais |

**Ce que dit NOMLEX-PLUS sur la règle « complément = patient » [L].** J'ai compté par expression régulière ; le
comptage est indicatif et non relu.

- Parmi les 3 946 entrées VERB-NOM :
  - 3 389 permettent « of » pour l'**objet** du verbe ;
  - 282 permettent « of » pour le **sujet** du verbe ;
  - 168 permettent les deux.
- Exemples :
  - *death* : `:VERB "die" … :VERB-SUBJ ((DET-POSS) (PP :PVAL ("by" "of")))`. Dans « the death of X », X est le sujet
    de *die*. NomBank le donne comme ARG1 « the deceased », avec `vntheta="Theme"`.
  - *baptism*, *massacre*, *abduction*, *sacrifice*, *rape* : « of » n'est permis que pour l'objet.
- **Dans les libellés anglais d'Iconclass** (`txt/en`, 44 337 lignes), 597 noms VERB-NOM de NOMLEX-PLUS sont suivis
  immédiatement de « of » (8 300 occurrences). Pour 79 d'entre eux, « of » peut réaliser le sujet : *death*,
  *arrival*, *flight*, *fall*, *return*, *appearance*, *migration*, *dance*, *battle*, *temptation*, *confession*…
- **Conclusion.** La règle E2 de `normalisation.pl` donne le patient là où NOMLEX dit sujet pour une famille entière,
  et elle le donne comme prémisse certifiable.
- **Le piège inverse.** NOMLEX-PLUS classe aussi *cross*, *head*, *hand*, *figure* et *history* comme nominalisations
  verbales. Dans Iconclass, ce sont des objets ou des notions. Une entrée de dictionnaire ne prouve pas la lecture
  d'action : il faut la conjuguer à D30.

**Classement.**

- **NOMLEX-PLUS et les cadres de NomBank : (b), et c'est la brique la plus directement utile à C7.3 en anglais.**
  Adaptation :
  1. Compiler NOMLEX-PLUS en faits
     `realisation_nominale(Nom, Verbe, Cadre, Fonction_du_verbe, Realisation)`.
  2. Rattacher chaque nom à son cadre PropBank (par `source=` dans NomBank) et à son rôle VerbNet (par `vntheta`).
  3. **Licencier E2 seulement** si, pour ce nom, **toutes** les réalisations de « of » visent la même fonction du
     verbe, et si cette fonction a le même rôle Oedipamaas dans toutes les classes VerbNet candidates. Sinon, mettre
     une `alternative` explicite.
  4. Exiger en plus une lecture d'action du nom sous D30 (§ 10.3).
- **PropBank (cadres unifiés) : (b).**
  - Il donne l'identifiant canonique de prédicat : *crucify* et *crucifixion* sous un même cadre, quand le cadre
    unifié existe. C'est ce qui permet de **canoniser les deux côtés** au lieu de dupliquer les structures (E1 et
    E2).
  - Il dit si le sujet d'un intransitif est ARG0 (inergatif) ou ARG1 (inaccusatif) : c'est la réponse à R2.
  - La licence CC BY-SA s'impose à la base dérivée.
- **Le corpus annoté de NomBank : (c) pour l'exécution**, car il est soumis à la licence LDC. Il peut servir de
  référence d'évaluation si le laboratoire a cette licence [NV].

### 3.4 SemLink, Predicate Matrix, VerbAtlas

- **SemLink 2.0.**
  - Contenu : des correspondances PropBank ↔ VerbNet ↔ FrameNet, pour VerbNet 3.3, les cadres PropBank unifiés et
    FrameNet 1.7. WordNet n'y est relié que par les regroupements de sens d'OntoNotes [S][13].
  - Dépôt GitHub `cu-clear/semlink` : aucune licence affichée, aucune version publiée [V][14].
  - **Classement : (b)** comme source de correspondances. Sa licence est à éclaircir avant toute redistribution [NV].
- **Predicate Matrix 1.3.**
  - Contenu : l'intégration de FrameNet, VerbNet, PropBank, WordNet et NomBank, avec de l'espagnol, du catalan et du
    basque, **pas de français** [S][15].
  - Licence : CC BY 3.0 [S][15] ; la page officielle a renvoyé une erreur 503 pendant l'étude.
  - Point utile : sur 6 181 prédicats PropBank, 2 623 n'avaient pas de lien vers VerbNet dans SemLink [S][15]. Les
    correspondances de la Predicate Matrix sont en partie **calculées automatiquement**.
  - **Classement : (b) au statut d'hypothèse seulement.** Une correspondance calculée ne peut pas fonder un lien
    certain.
- **VerbAtlas.**
  - Contenu : 466 cadres et 26 rôles qui regroupent les synsets verbaux de WordNet ; correspondance manuelle avec
    PropBank (version 1.0) [S][16].
  - Licence : **non confirmée** [NV]. Les ressources apparentées du même laboratoire sont en CC BY-NC-SA (§ 5).
  - **Classement : (c)** tant que la licence n'est pas confirmée compatible. Le contenu, qui relie des sens WordNet à
    des cadres, serait pertinent.

### 3.5 La valence française : Dicovalence, LVF, Lefff

| | Dicovalence | LVF (Les Verbes Français) | Lefff |
|---|---|---|---|
| Contenu | cadres de valence ; une place se définit par les pronoms qui peuvent la remplir | 25 610 entrées classées en 14 classes, 54 sous-classes et 248 sous-sous-classes, sans rôles thématiques [S][8][17] | lexique morphologique et syntaxique ; cadres de sous-catégorisation profonds et redistributions (passif, etc.) [S][19] |
| Taille | plus de 3 700 verbes simples [S][18] | 25 610 entrées [S][17] | v3.5 [S][19] ; chiffres récents [NV] |
| Licence | LGPL-LR (annonce de 2006) [S][18] | **[NV]** : versions Excel (MoDyCo) et XML (RALI), conditions non trouvées ; la page du RALI a refusé l'accès | LGPL-LR [S][19] |

**Classement.**

- **Dicovalence : (b).** Il dit si un verbe a un emploi intransitif et de quel type. C'est un indice pour R2 en
  français (avec Verb∋Net), et pour savoir si le « de » d'un nom déverbal peut viser le sujet.
- **Lefff : (b).** Il donne les redistributions (passif, pronominal), utiles pour neutraliser la diathèse. C'est un
  complément à Grew (§ 4.1).
- **LVF : (c) en l'état**, tant que la licence n'est pas connue. Son contenu est d'ailleurs repris par Verb∋Net.

### 3.6 La morphologie dérivationnelle : liens morphosémantiques de WordNet, Démonette, DériF, Verbaction, Nomage, CatVar

- **Les liens morphosémantiques de WordNet 3.0.**
  - Contenu : 14 types de relations (agent, body-part, by-means-of, destination, event, instrument, location,
    material, property, result, state, undergoer, uses, vehicle) [V][20]. Le type `event` est décrit comme « en
    substance une relation d'identité ou d'égalité » [V][20].
  - Taille : 17 342 paires de synsets selon la description du fichier [S][20] ; 17 740 paires de littéraux selon un
    article de 2014 [S][21] ; 17 739 compilées par le projet.
  - **Classement : (b).** Ce sont des liens **entre sens**, pas entre mots : ils ne licencient E1 et E2 que pour les
    sens liés, donc sous D30.
- **La relation `der` de WordNet** (celle qu'utilise `nominalisation/3`).
  - Le cas *deposition* [L] : WordNet 3.0 lui donne quatre sens nominaux. Deux sont de lexfile `noun.act` :
    `00372448` « the act of putting something somewhere », lié par dérivation à {situate, fix, posit, deposit} ;
    `00208943` « the act of deposing someone », lié à {depose, force_out} et {dethrone}.
  - Aucun sens n'est la Déposition de croix. La règle actuelle accepte pourtant ces paires, puisqu'elle demande
    seulement un lien `der` et un lexfile d'action.
  - *crucifixion* a trois sens (`noun.act`, `noun.event`, `noun.act`) [L], dont aucun n'est l'œuvre qui représente
    la scène.
  - **Classement : (c) comme équivalence certaine ; (b) comme source d'hypothèses.**
- **Démonette-2.**
  - Contenu : une base dérivationnelle du français ; 222 118 paires de lexèmes avec affixes, type de construction et
    orientation [V][22].
  - Licence : **CC BY 4.0**, diffusion par OSF (DOI 10.17605/OSF.IO/DB2W8) [V][22]. Démonette-1 était en
    CC BY-NC-SA 3.0 [S][23].
  - Limite : elle décrit des relations **morphologiques**, en synchronie [S][23]. Elle ne dit pas comment les
    arguments sont réalisés.
  - **Classement : (b).** C'est la bonne source des paires verbe → nom d'action en français, à la place des liens
    `der` de WordNet transportés par WOLF : elle ne dépend pas de la couverture de WOLF (58 % des mots français des
    définitions, PLAN § 0).
- **Verbaction.**
  - Contenu : 9 393 couples verbe-nom d'action ; il est décrit comme « sans caractérisation sémantique ni information
    sur la structure argumentale » [S][28]. Licence [NV].
  - **Classement : (b)** pour vérifier la couverture de Démonette, si la licence le permet.
- **Nomage.**
  - Contenu : la lecture aspectuelle (événement, résultat, état) des noms déverbaux en contexte, sur le French
    Treebank ; 4 042 nominalisations analysées sur 11 800 candidates [S][29]. Disponibilité [NV].
  - Intérêt : c'est la preuve, pour le français, que l'ambiguïté **événement / résultat** des noms déverbaux est
    courante en contexte (« la construction », « la peinture »).
  - **Classement : (b)** comme référence pour mesurer, (c) pour l'exécution.
- **DériF** (l'analyseur de Namer, à base de règles, qui alimente Démonette) : disponibilité et licence [NV].
  **Classement : (c)**, inutile si Démonette-2 suffit.
- **CatVar** (anglais) : des groupes de dérivation entre catégories, construits en partie à partir de NOMLEX [S][30].
  Licence [NV]. **Classement : (c)**, NOMLEX-PLUS suffit et dit plus.

---

## 4. Représentations du sens et analyseurs

### 4.1 Les dépendances universelles enrichies (EUD) et la syntaxe profonde

- **La représentation enrichie de l'anglais** (*enhanced* et *enhanced++*) ajoute les sujets contrôlés
  (`nsubj:xsubj`), la propagation dans les coordinations, les relatives… Les convertisseurs sont dans Stanford
  CoreNLP [S][31].
- **Candito, Guillaume, Perrier et Seddah (2017)** étendent cette représentation au français et à l'anglais : ils
  **neutralisent des alternances syntaxiques** (diathèses) et ajoutent les sujets d'infinitifs contrôlés par des noms
  et des adjectifs, par des **règles déterministes de réécriture de graphes**. Évaluation sur un étalon de 200
  phrases, « avec une grande justesse » [S][32].
- **Deep-sequoia** : une annotation en syntaxe profonde du Sequoia (3 099 phrases), où les diathèses sont modélisées
  comme des redistributions d'un cadre canonique [S][33]. Licence [NV].
- **Grew** : l'outil de réécriture de graphes. Guillaume et Perrier en ont tiré un système de règles qui calcule les
  EUD à partir des UD de base, présenté à la tâche partagée IWPT 2021 [S][34]. Licence de l'outil [NV] (« distribué
  librement »).
- **IWPT 2021** : 17 langues ; l'annotation enrichie des treebanks français n'était **pas** dans les versions
  officielles d'UD [S][35]. Les systèmes neuronaux de la tâche (XLM-R, etc.) ne sont pas nécessaires ici.
- **Stanza** : pas de sortie enrichie confirmée [NV]. Ses LAS : 91,28 sur fr_gsd et 86,77 sur en_ewt (v1.5.1,
  UD 2.12) [V][36]. Le projet a mesuré pour Stanza un rappel de la scène de 0,948 contre 0,897 pour UDPipe 1
  (PLAN § 0).

**Classement : (b), et c'est une priorité.** Une couche de **règles Grew** (ou leur portage en Prolog) entre CoNLL-U et
`interpretation.pl` donnerait :

- le passif, les causatifs, le contrôle, les relatives et la coordination normalisés par des **règles nommées**, ce
  qui fait une provenance naturelle (`derive(A, grew:passif_canonique, …)`) ;
- une justesse **mesurée par des tiers** sur le français ;
- l'exécution sur CPU, sans modèle.

Cette couche remplacerait une partie des règles écrites à la main dans `interpretation.pl`, après mesure sur les paires
minimales. **Elle ne résout pas** la sémantique lexicale : qui est agent d'un intransitif, et ce que vise le
complément d'un nom.

### 4.2 AMR, et l'AMR en français

- **AMR 3.0** : 59 255 phrases anglaises, distribuées par le LDC sous licence [V][37].
- **Les meilleurs analyseurs** atteignent environ **84 à 85 Smatch** sur le test d'AMR 3.0 : SPRING 84,49, MBSE 83,74,
  l'analyseur à transitions d'IBM 81,28, selon une étude de 2026 [S][38].
- **amrlib** : un modèle BART-large à 83,7 ou 82,7 Smatch selon les sources [S][39]. Il tourne sur CPU (choix du
  périphérique) [V][40]. Le code de SPRING est en CC BY-NC-SA [S][39].
- **En français** :
  - un analyseur sans données françaises obtient de **54,2 à 66,0 Smatch** selon le jeu de test [S][41] ;
  - **ding-01** : environ 1 830 tours de parole, CC BY-SA, analyseur mBART à **68,1 Smatch** entraîné sur ding-01
    seul, **73,5** avec pré-entraînement, dans le domaine [V][42] ;
  - un analyseur publié à TALN 2026, entraîné sur ding-01, Le Petit Prince et Massive-AMR [S][41] : chiffres [NV]
    (article indisponible, erreur 503).
- **Incertitude** : la première étude de l'incertitude des analyseurs AMR (2026) conclut qu'elle est une dimension
  d'évaluation à part entière, distincte de la justesse [V][38].

**Classement : (c) comme représentation intermédiaire ou comme analyseur.**

- **En français**, la qualité est de 54 à 74 Smatch, souvent hors domaine.
- **Les modèles** sont des seq2seq de type BART ou mBART large. Ils tournent sur CPU, mais ce sont des générateurs dont
  la sortie n'a ni provenance ni alternatives.
- **AMR ne représente ni la portée ni la modalité épistémique** au-delà de `:polarity` et de quelques prédicats
  modaux. Il n'a pas l'équivalent de `portee(represente)` ni de `enonciateur`. *Ce point vient des consignes
  d'annotation d'AMR, que je n'ai pas relues pour cette étude.*
- **Les données d'AMR 3.0** sont sous licence LDC, et les conditions des modèles entraînés dessus sont à vérifier.

**Ce qui reste réutilisable : (b).** Les **cadres PropBank** qu'emploie AMR (§ 3.3), et les **consignes d'AMR** sur
les nominalisations (un nom d'action est représenté par le cadre du verbe). Elles confirment le choix de canoniser par
cadre.

### 4.3 UMR (Uniform Meaning Representation)

- **Les données** : UMR 2.0 couvre l'arapaho, le chinois, l'anglais et le navajo ; UMR 2.1 le tchèque et le latin.
  Il n'y a **pas de français** [S][43].
- **Les analyseurs** : la première tâche partagée d'analyse UMR a été lancée en janvier 2026 [S][43]. Il existe des
  analyseurs anglais (SETUP, Chun et Xue 2024) [S][43].
- **Classement : (c) comme outil ; (b) comme référence de conception.** UMR ajoute à AMR la modalité, l'aspect, la
  portée et une structure de document. Ce sont les dimensions les plus proches des qualificatifs de `ASSERTIONS.md`.
  Il vaut la peine de comparer les valeurs de modalité d'Oedipamaas à celles d'UMR, pour l'interopérabilité future,
  sans dépendre d'un analyseur.

### 4.4 UCCA

- **SemEval 2019, tâche 1** : anglais, allemand, français. Le français n'avait pas de données d'entraînement ; il
  était évalué sur *Vingt mille lieues sous les mers* ; l'analyseur de référence est TUPA [S][44].
- **Classement : (c).** La couche fondamentale d'UCCA étiquette les participants d'une scène par une seule catégorie
  (« A », participant), **sans distinguer l'agent du patient**. Or c'est exactement la distinction dont le noyau a
  besoin : « Goliath tranche la tête de David » n'est pas « David tranche la tête de Goliath ». *Ce point vient des
  consignes d'UCCA, que je n'ai pas relues ici.*

### 4.5 Universal Decompositional Semantics (UDS)

- **UDS 1.0 et Decomp** : des graphes à attributs réels (proto-rôles, factualité, généricité, temps…) sur l'English
  Web Treebank, construits sur PredPatt [S][45].
- **Licence** : code sous MIT, données sous CC BY-SA 4.0 ; le dépôt ne fournit pas d'analyseur [V][46].
- **Classement : (c)** comme outil : anglais seulement, pas d'analyseur. **(b) comme idée** : les **propriétés de
  proto-rôles** (volition, instigation, changement d'état) graduées justifient théoriquement un **macro-rôle
  « subissant »** qui réunisse patient et thème (§ 10.3).

---

## 5. L'étiquetage des rôles sémantiques (SRL)

### 5.1 Les systèmes anglais et multilingues

| Système | Inventaire, langues | Résultat publié | Licence | Statut |
|---|---|---|---|---|
| AllenNLP SRL-BERT (Shi et Lin 2019) | PropBank, anglais | 86,49 F1 sur OntoNotes [S][47] | code Apache 2.0 ; **dépôt archivé le 16/12/2022** [V][48] | non maintenu |
| multi-srl (Conia et Navigli, COLING 2020) | PropBank (CoNLL-2009 : anglais, tchèque, allemand, catalan, espagnol, chinois ; CoNLL-2012), VerbAtlas | environ 93,1 F1 sur CoNLL-2009 anglais ; environ 88,5 sur CoNLL-2012 (RoBERTa-large) [V][49] | **CC BY-NC 4.0** (code et modèles) [V][49] | pas de français |
| InVeRo-XL (EMNLP 2021, démo) | 7 inventaires, plus de 40 langues | — | modèle sur demande, **CC BY-NC-SA 4.0** [S][50] | API web, ou local sur demande |
| UniteD-SRL (données) | VerbAtlas ; chinois, anglais, **français**, espagnol ; parallèle et manuel [S][51] | — | **CC BY-NC-SA 4.0**, sur demande [V][52] | données d'évaluation |
| LOME | FrameNet, XLM-R, multilingue | « compétitif » selon les auteurs [S][26] | [NV] | Docker |
| frame-semantic-transformer | FrameNet, anglais | arguments 0,73 et 0,75 [V][25] | [NV] | T5-small ou base, faisable sur CPU [NV] |

### 5.2 Le SRL en français

- **Le corpus de référence** : 1 001 phrases d'Europarl annotées avec les cadres PropBank anglais (van der Plas et al.
  2010-2011) : 1 979 prédicats et 5 393 arguments [V][53][54].
- **UP 2.0** (IBM, LREC 2022) a projeté PropBank sur 23 langues, dont le français (outils : Stanza et SimAlign).
  - Sur ce corpus de référence, la meilleure configuration française donne : prédicats P 79,92, R 59,76,
    **F1 68,38** ; arguments P 58,47, R 43,94, **F1 50,17** [V][54].
  - Les auteurs signalent du **bruit d'annotation** dans le corpus de référence et pensent que la vraie justesse est
    un peu plus haute [V][54].
  - L'article est sous CC BY-NC 4.0 [V][54] ; la licence des données [NV].
- **CoNLL-2009 ne contient pas de français** [V][49].

**Classement.**

- **Tous les systèmes de SRL : (c) comme source de prémisses.** Il y a trois raisons, chacune suffisante :
  1. **La justesse** : en français, environ un argument sur deux est juste (F1 50,17, UP 2.0). En anglais, 86 à 93 de
     F1 laisse plus d'une erreur sur dix rôles, et une erreur de rôle est exactement l'erreur que le noyau ne doit
     pas certifier (rôles inversés, C6.4).
  2. **La forme de la sortie** : une seule étiquette par argument, pas un ensemble de lectures licenciées. Les scores
     softmax de ces modèles ne sont pas calibrés. Une étude le montre pour la désambiguïsation [V][62] ; pour le SRL,
     je n'ai pas trouvé d'étude de calibration [NV].
  3. **Les licences** : les meilleurs modèles multilingues sont en CC BY-NC (ou NC-SA).
- **Usage (b) possible, hors moteur** : un modèle de SRL comme **instrument de mesure**, c'est-à-dire un détecteur de
  désaccord entre le graphe du lecteur et une seconde analyse indépendante. Les désaccords seraient relus en
  priorité dans les lots de C6. Un modèle NC peut servir à la recherche et à l'évaluation interne s'il n'est pas
  livré [NV juridique].
- **Les données UniteD-SRL (français) et le corpus de référence de UP 2.0 : (b) pour l'évaluation** de la table des
  rôles (§ 10.3), sous leurs licences.

---

## 6. La désambiguïsation lexicale (WSD)

### 6.1 Les chiffres de référence

- **Anglais, tous les mots, ensemble « ALL » de Raganato et al. (2017)** :
  - sens le plus fréquent : **65,2** ;
  - UKB (PageRank personnalisé sur WordNet, réglages optimaux) : **67,3** [V][55] ;
  - systèmes supervisés de 2016-2017 : 68,8 à 71,5 [V][55] ;
  - ConSeC : **82,0** (SemCor) et **83,2** (SemCor et WNGT) [V][56] ;
  - EWISER : « dépasse le plafond de 80 % » [V][57].
- **XL-WSD** (AAAI 2021) [V][58] :
  - 18 langues ; inventaire unifié par BabelNet ; plus de 99 000 instances de référence.
  - Le test français contient 1 160 instances et 549 types de mots, et il n'a **que des noms** (la ventilation par
    catégorie ne donne une valeur que pour les noms).
  - Ses données françaises viennent de **SemEval-2013 tâche 12** (actualités du WMT) ; SemEval-2015 tâche 13 n'y
    fournit que l'italien et l'espagnol.
  - Scores F1 en français : sens le plus courant **59,31** ; SyntagRank (à base de connaissances) **69,57** ; Babelfy
    67,41 ; XLM-R large entraîné en anglais seulement **83,88**.
  - Licence **CC BY-NC** [V][59].
- **SemEval-2013 tâche 12**, français, inventaire BabelNet : sens le plus fréquent **0,453**, meilleur système
  (UMCC-DLSI) **0,605** [V][60]. Il y a 1 656 instances françaises selon notre lecture du tableau 1 de l'article.
- **FrSemCor** :
  - 12 917 occurrences de **noms** du Sequoia, annotées en 24 supersens (et des supersens complexes) ; annotation
    double et adjudication [S][61].
  - La licence est contradictoire : « Creative Commons » dans l'article, LGPL-LR sur le site [S][61].
  - Les supersens sont **proches des lexfiles de WordNet** (Act, Event, Artifact…) : c'est exactement le critère dont
    se sert `nominalisation/3`.

### 6.2 Les systèmes

| Système | Type | Langues | Licence | Sortie |
|---|---|---|---|---|
| UKB | PageRank personnalisé sur une base lexicale (WordNet et ses relations ; possible avec WOLF) | toutes celles de la base | **GPL v3**, C++ [V][63] | un rang (score PPR) pour chaque sens candidat |
| Lesk et ses variantes (NLTK, Lesk distributionnel) | chevauchement de gloses | celles des gloses | NLTK Apache 2.0 | des scores de chevauchement |
| SyntagRank | PageRank personnalisé sur SyntagNet (environ 90 000 collocations désambiguïsées à la main) [S][64] | multilingue (BabelNet) | API ; licence de BabelNet et de SyntagNet [NV] | — |
| EWISER | supervisé, graphe de WordNet, fairseq | anglais et un modèle multilingue | **CC BY-NC-SA 4.0** [V][57] | des logits sur les sens |
| ConSeC | supervisé | anglais | **CC BY-NC-SA 4.0** [V][56] | des scores |
| AMuSE-WSD | supervisé, XLM-R ; 40 langues ; images Docker CPU et GPU ; le modèle moyen (XLM-R base) donne la même sortie que le grand dans 98 % des cas, en deux fois moins de temps [S][65] | 40 langues | **CC BY-NC-SA 4.0** [V][66] | — |

**La calibration.** Liu et Liu (Findings ACL 2023) montrent que les probabilités de sortie d'un système de WSD de
pointe sont **inadéquates pour mesurer l'incertitude** : le softmax est trop confiant, et un score par
*Monte Carlo dropout* fait mieux [V][62]. Aucun système cité ne livre de distributions **calibrées** prêtes à
l'emploi.

**Classement.**

- **Tous les systèmes de WSD : (c) comme décision**, puisque D30 interdit de choisir. **(b) comme classeur
  d'hypothèses.**
- **UKB : (b), le premier candidat.** Il est hors ligne, en C++, déterministe, et sans licence NC (la GPL v3 est
  compatible s'il est appelé comme programme séparé). Il ne dépend que de WordNet 3.0, des liens de gloses, et de
  WOLF pour le français. Adaptations :
  1. une sortie **par occurrence** (`sens_suppose(Occ, Sens, Score, ukb)`), ce qui corrige L1 ;
  2. une **calibration a posteriori** sur une référence du domaine (§ 11) ;
  3. un usage **seulement** pour ordonner les candidats et les hypothèses de C9, jamais pour certifier.
- **Les modèles supervisés (EWISER, ConSeC, AMuSE) : (c) pour la livraison**, à cause des licences NC et de
  l'évaluation française limitée aux noms d'actualité. **(b) comme bornes supérieures** dans une évaluation interne.
- **XL-WSD français, SemEval-2013 et FrSemCor : (b) pour l'évaluation**, mais **hors domaine** (actualité, nouvelles,
  Sequoia). Ils ne remplacent pas une référence tirée des cartels et des libellés.

---

## 7. Coréférence et relations (en bref)

- **Stanza** (depuis 1.7.0) a un modèle de coréférence. Pour le français, le modèle par défaut est
  `udcoref_xlm-roberta-lora`, entraîné surtout sur CorefUD [V][67]. Le fichier français est ajouté avec le
  modèle 1.10.0 [S][68].
- **coreferee** : spaCy, avec des réseaux de neurones et des règles ; anglais, français, allemand, polonais ; maintenu
  par Explosion ; licence [NV] ; scores publiés [NV] [S][69].
- **Modèle français de Wilkens et al. (LREC 2020)** : entraîné sur Democrat (écrit) [S][70].
- **Classement : (b), au statut d'hypothèse.** Une coréférence neuronale donne `coref_possible`, qui sert à C9 et non à
  des preuves (NOYAU § 1 : « la coréférence possible n'est pas dans le graphe »). Les coréférences **syntaxiques
  déterministes** restent certaines au sens de l'analyse : apposition, attribut d'identité, pronom relatif, sujet
  contrôlé (que les règles EUD de § 4.1 donnent).
- **L'extraction de relations générale : (c).** Les relations de scène d'Oedipamaas (`tient`, `regarde`, `sur`,
  `a_cote_de`) viennent de la syntaxe et des prépositions. Aucun extracteur de relations généraliste trouvé n'a cet
  inventaire, ni en français.

---

## 8. Ressources du domaine

- **Iconclass.**
  - Données sous **CC0 1.0**, vérifié sur GitHub [V][71] et dans `iconclass-data/LICENSE` [L].
  - 40 717 notations de base dans `notations.txt` [L].
  - Textes dans 13 langues (cz, de, en, es, fi, fr, hu, it, jp, nl, pl, pt, zh) et mots clés dans 10 (cz, de, en, es,
    fi, fr, it, nl, pt, zh) [L]. Les mots clés français font 107 741 lignes, les anglais 104 338 [L].
  - **Classement : (a).** Ce sont les données sources. Les mots clés sont une source de `lexicalisation/3` et
    d'alias. Ils servent à C9 au statut d'**indices**, jamais de définitions (D10, D15).
- **Getty AAT.**
  - Toutes les données des vocabulaires Getty sont sous **ODC-By 1.0** [V][72].
  - Plus de 250 000 termes en 2014 [S][73] ; le français était partiel en 2014 [S][73] ; chiffres actuels [NV].
  - **Classement : (b)** pour les objets, les vêtements et les matériaux, déjà prévu au PLAN (§ C7). Il n'y a pas de
    lien avec WordNet : tout rapprochement AAT ↔ WordNet est une hypothèse, sauf alignement documenté.
- **CIDOC CRM.**
  - La version 7.1.3 correspond à ISO 21127:2023 ; la dernière version communautaire est la 7.3.2 (mars 2026)
    [S][74]. Une traduction française de la 7.1.3 est sous CC BY 4.0 [S][74] ; licence de la spécification anglaise
    [NV].
  - **Classement : (b) pour la sortie** (export des annotations : œuvre, item visuel, représente) ; **(c) pour la
    lecture**, car c'est une ontologie de documentation, sans lexique ni analyseur.
- **Les travaux sur Iconclass et les textes d'histoire de l'art.**
  - **Banar, Daelemans et Kestemont (JOCCH 2023)** traitent l'attribution de codes Iconclass comme une recherche
    croisée entre modalités (titres multilingues et images contre définitions). Le texte est plus discriminant que
    l'image ; les expériences hors domaine et sans exemple donnent de **mauvais résultats** [S][75].
  - **Springstein et al. (WACV 2024)** : classification hiérarchique sur plus de 20 000 concepts, à partir
    d'images ; des descriptions sont générées par des modèles de langue ; code sous `TIBHannover/iconclass-classification`
    [S][76].
  - **CARIS (2026)** : détection d'objets (YOLO) puis correspondances par règles avec des codes ; aucune mesure
    chiffrée [V][77].
  - **Iconclass AI Test Set** : environ 87 000 images codées [S][77].
  - **FRAME (2026)** : 200 descriptions d'images d'histoire de l'art (sources allemandes et anglaises, traduites en
    anglais par GPT-4o), annotées en entités (37 types), relations et **coréférence** ; **CC BY 4.0** [V][78].
  - **Classement.** Les classifieurs neuronaux Iconclass : (c), car ils rendent des scores, pas des preuves, et sont
    médiocres hors domaine [S][75]. Ils pourraient servir de **base de comparaison** pour le rappel. FRAME : (b)
    comme **référence indépendante en anglais** pour le lecteur (entités, relations, coréférence) ; la traduction par
    GPT-4o est à signaler.

---

## 9. Synthèse : le classement et les licences

| Brique | Classement | Ce qu'il faut adapter, ou la raison du refus | Licence | Compatible avec MIT et une base redistribuable |
|---|---|---|---|---|
| WordNet 3.0 | (a) en place | — | Princeton (permissive) | oui |
| WOLF (OMW 1.4) | (a) en place | couverture de 58 % | CeCILL-C [L] | oui (de type LGPL) |
| Liens morphosémantiques | (b) | liens entre sens, sous D30 | Princeton | oui |
| `der` de WordNet comme équivalence | (c) | *deposition* → *depose* (§ 3.6) | Princeton | — |
| FrameNet 1.7 | (b) | paraphrases au statut d'hypothèse ; lacunes iconographiques | CC BY 3.0 | oui (attribution) |
| ASFALDA | (c) / (b) en évaluation | 98 cadres, sur demande | [NV] | à vérifier |
| VerbNet 3.3 / 3.4 | (b) | table rôles VN → rôles Oedipamaas ; restrictions de sélection | Colorado (commercial permis) | oui |
| Verb∋Net | (b) | couverture à mesurer | CC BY-SA 4.0 | base dérivée en SA |
| Cadres PropBank (unifiés) | (b) | prédicat canonique ; ARG0 ou ARG1 des intransitifs | CC BY-SA 4.0 | base dérivée en SA |
| Cadres NomBank, NOMLEX-PLUS | (b), **priorité** | réalisation de « of » par nom ; licencier E2 | « avec permission » (NYU) [NV] | à confirmer avant redistribution |
| Corpus NomBank | (c) moteur / (b) évaluation | licence LDC | LDC | non pour la livraison |
| SemLink 2.0 | (b) | correspondances | non affichée [V] | à éclaircir |
| Predicate Matrix 1.3 | (b), hypothèses seulement | correspondances calculées | CC BY 3.0 [S] | oui |
| VerbAtlas | (c) en attente | licence non confirmée | [NV] | ? |
| Dicovalence | (b) | type d'intransitif, valence | LGPL-LR [S] | oui (données en LGPL-LR) |
| LVF | (c) | licence inconnue | [NV] | ? |
| Lefff | (b) | redistributions | LGPL-LR | oui |
| Démonette-2 | (b), **priorité FR** | paires verbe → nom d'action | CC BY 4.0 [V] | oui |
| Verbaction, Nomage, DériF, CatVar | (b) en évaluation / (c) | licences inconnues | [NV] | ? |
| Règles EUD et syntaxe profonde (Grew, Candito et al. 2017) | (b), **priorité** | portage ou appel, règles nommées | Grew [NV] | à vérifier |
| Stanza (analyse UD) | (a) en place | — | Apache 2.0 ; modèles sur treebanks CC BY-SA | oui (D18 bis) |
| Modèles UDPipe 1 et 2 | (a) en développement | modèles NC (D7) | CC BY-NC-SA | **non** pour la livraison |
| Analyseurs AMR | (c) | FR 54 à 74 Smatch ; ni modalité ni portée ; une seule sortie | modèles variés ; données LDC | — |
| UMR | (c) outil / (b) conception | pas de français | — | — |
| UCCA | (c) | participants non distingués | — | — |
| UDS / Decomp | (c) outil / (b) idée | anglais seulement, pas d'analyseur | MIT et CC BY-SA | — |
| SRL (AllenNLP, multi-srl, InVeRo-XL, LOME) | (c) moteur / (b) instrument | FR arguments à 50,17 F1 ; une seule sortie ; NC | NC pour les meilleurs | **non** pour la livraison |
| UniteD-SRL, référence FR d'UP 2.0 | (b) évaluation | — | NC-SA ; [NV] | évaluation interne |
| UKB | (b), **priorité WSD** | par occurrence, calibré, ordonnance seulement | GPL v3 | oui comme programme séparé |
| EWISER, ConSeC, AMuSE-WSD | (c) livraison / (b) bornes | NC ; FR limité aux noms | CC BY-NC-SA | **non** |
| XL-WSD, SemEval-2013, FrSemCor | (b) évaluation hors domaine | — | CC BY-NC ; [NV] ; contradictoire | évaluation interne |
| Coréférence Stanza, coreferee | (b) hypothèses | `coref_possible` seulement | Apache 2.0 (Stanza) ; [NV] | oui (Stanza) |
| Iconclass | (a) | — | CC0 | oui |
| AAT | (b) | objets et vêtements ; liens hypothétiques | ODC-By 1.0 | oui (attribution) |
| CIDOC CRM | (b) sortie | — | traduction FR CC BY 4.0 ; [NV] | probablement |
| FRAME | (b) évaluation | anglais, traduction par GPT-4o | CC BY 4.0 | oui |

---

## 10. L'architecture recommandée pour C7

### 10.1 Les principes

1. **Une transformation est une règle d'inférence nommée.** Toute assertion ajoutée porte
   `derive(A, Regle, Sources, Hypotheses, Statut)`, c'est-à-dire le lot L3. `Regle` cite la ressource et l'entrée
   (`nomlex:death:VERB-SUBJ:of`, `propbank:die.01:ARG1`, `grew:passif`), et `Sources` les assertions d'origine.
2. **La généralisation de D30.** Une transformation est **certaine** si et seulement si elle vaut pour **toutes** les
   lectures que les ressources admettent pour l'occurrence : tous les sens du mot, tous les cadres candidats, toutes
   les réalisations de l'argument. Sinon, elle est **hypothétique**. Elle est alors rattachée à **l'occurrence**
   (`sens_suppose(Occ, …)`, `cadre_suppose(Occ, …)`), ce qui corrige L1. Elle n'est jamais une prémisse déductive.
   Quand les lectures s'excluent, le lecteur l'écrit par une `alternative`.
3. **Canoniser des deux côtés plutôt qu'enrichir d'un côté.** Le compilateur de libellés (C3) et le lecteur (C7)
   projettent leurs prédicats sur le **même** identifiant canonique (cadre PropBank, ou à défaut synset du verbe) et
   sur le **même** vocabulaire de rôles. Une équivalence de définition appliquée symétriquement n'ajoute aucune
   prémisse ; les règles E1 et E2, elles, en ajoutaient. Le comparateur (`inclusion.pl`) cesse alors d'être en
   `indetermine` à cause de la normalisation.
4. **Proposer, licencier, vérifier.**
   - Les modèles (Stanza ; éventuellement UKB et la coréférence) **proposent**.
   - Les lexiques **licencient**, de façon déterministe et reproductible.
   - Le noyau **vérifie**.
   - Aucun modèle n'écrit une prémisse sans passer par un lexique.
5. **Une ressource à la fois, et chacune mesurée (D17).** Chaque règle a sa clé d'index (C5.3) et son test de
   non-régression sur les paires minimales.

### 10.2 Les couches

```
CoNLL-U (Stanza ; UDPipe en contrôle)
  │  C7.0  accord des deux analyseurs : un arc contesté donne une alternative ou incompris (à mesurer)
  ▼
C7.1  syntaxe profonde : règles nommées de réécriture de graphes (EUD et diathèses, Candito et al. 2017, Grew)
  ▼
interpretation.pl  (inchangé dans son contrat : assertions et qualificatifs)
  ▼
C7.2  ancrage lexical : pour chaque occurrence, l'ENSEMBLE de ses lectures
        EN : sens WordNet ; cadres PropBank (verbes, noms) ; classes et rôles VerbNet ; NOMLEX-PLUS pour les noms
        FR : sens WOLF ; Verb∋Net ; Dicovalence et Lefff ; Démonette-2 (nom → verbe) ; NomLex-FR restreint (§ 10.4)
  ▼
C7.3  licencieur (propre à Oedipamaas) : D30 généralisé ; certain, hypothétique ou alternative ; provenance
  ▼
C7.4  classement des hypothèses (facultatif) : UKB par occurrence, calibré ; coréférence possible (Stanza)
        → sert à C9 et à l'ordre des candidats, jamais aux codes établis
  ▼
noyau (satisfaction, preuve, vérificateur) : inchangé
```

Tout est hors ligne et sur CPU :

- C7.1 à C7.3 sont des règles et des tables, sans modèle ;
- UKB est un binaire C++ ;
- la coréférence de Stanza est un XLM-R avec LoRA, à mesurer en temps.

### 10.3 Que faire de chaque règle actuelle de `normalisation.pl`

| Règle actuelle | Problème (L2) | Remplacement | Statut obtenu |
|---|---|---|---|
| **R1** patient ↔ thème | une inférence ajoutée d'un seul côté | **un macro-rôle** (« subissant », d'après les proto-rôles de Dowty et l'idée d'UDS), défini **dans le vocabulaire** des deux côtés : la table VerbNet → Oedipamaas envoie Patient et Theme sur le même rôle. Ce n'est plus une règle. | une définition, sans inférence |
| **R2** le participant unique reçoit agent, thème et patient | faux en général | consulter les cadres PropBank candidats du verbe intransitif (ARG0 = inergatif → agent ; ARG1 = inaccusatif → subissant), et les rôles VerbNet ; en français, Verb∋Net et le type d'intransitif de Dicovalence | **certain** si tous les cadres candidats s'accordent ; sinon `alternative` ou un rôle sous-spécifié `participant` (à ajouter à ASSERTIONS : une décision de conception) |
| **E1** l'événement donne un nom d'action | une duplication du graphe | supprimée : la canonisation par cadre (principe 3) | — |
| **E2** le nom d'action donne l'événement, et le complément devient le patient | lecture d'action supposée ; « of » / « de » supposé objet | (i) lecture d'action : **certaine** seulement si **tous** les sens du nom (WordNet ou WOLF) sont des sens d'action liés au verbe (morphosémantique `event`, ou `der` vers ce verbe) ; sinon `sens_suppose(Occ, sens_action)`. Le sens d'artefact (« une Crucifixion », le tableau), absent de WordNet, est un cas connu (§ 3.6), d'où le point (iv). (ii) le complément : en anglais, NOMLEX-PLUS ; **certain** si toutes les réalisations de « of » pour ce nom visent la même fonction du verbe (*baptism*, *massacre* : objet), sinon une alternative (*temptation*, *death* : sujet possible). En français : la table NomLex-FR restreinte, à défaut une hypothèse. (iii) le rôle : celui de la fonction du verbe dans le cadre, par la table des rôles. (iv) la portée : un nom d'action complément d'un verbe de représentation ou en position de titre (« une Crucifixion ») est à mesurer. | certain, ou hypothèse avec provenance |
| **C1** les composés libres en « de » / « of » | une structure supposée | une hypothèse par défaut ; certaine seulement pour des patrons mesurés | hypothèse |
| **P1** le participe devient un événement | le rôle unique supposé thème | même traitement que R2 | comme R2 |

### 10.4 Où un développement propre à Oedipamaas est justifié

1. **Le licencieur épistémique (C7.3).**
   - Aucun outil trouvé ne produit des transformations **qualifiées** (certaine ou hypothétique) avec leur provenance.
   - Les SRL, WSD et AMR rendent une sortie unique et des scores non calibrés ([V][62] pour la WSD ; [V][38] pour
     l'AMR, où l'incertitude est une dimension à part).
   - Le licencieur est l'extension directe de D30. Son contrat se spécifie formellement et s'intègre au vérificateur.
2. **La table « NomLex-FR » restreinte.**
   - Il n'existe pas en français d'équivalent de NOMLEX qui donne la réalisation des arguments des noms déverbaux :
     - Démonette ne décrit que des relations morphologiques [S][23] ;
     - Verbaction est « sans information sur la structure argumentale » [S][28] ;
     - Nomage décrit l'aspect, non les arguments [S][29].
   - Le vocabulaire est **fermé** : les noms d'action des libellés français d'Iconclass, plus ceux des cartels du banc.
     En anglais, ce sont 597 noms suivis de « of » [L] ; le chiffre français est à compter.
   - Méthode proposée :
     1. amorcer par Démonette-2 (le verbe) et par l'entrée NOMLEX du nom anglais équivalent (lien WOLF, au statut
        d'hypothèse) ;
     2. faire **valider à la main**, en double annotation, la réalisation du « de » ;
     3. la provenance est « table Oedipamaas vN, validée le … ».
   - C'est une ressource de langue, non d'iconographie (règle du PLAN § 7).
3. **La table des rôles** VerbNet / PropBank → les six rôles et le macro-rôle, partagée par C3 et C7. Elle est petite,
   mais c'est une décision du projet.
4. **Les références du domaine** (§ 11). Aucune référence sémantique française sur des textes d'histoire de l'art n'a
   été trouvée. FRAME est en anglais et sans rôles d'événements.
5. **Le portage ou l'intégration des règles de syntaxe profonde.** Ce n'est développé que si l'appel à Grew n'est pas
   possible (licence, dépendance OCaml) [NV].

**Ce qu'il ne faut pas développer** : un analyseur de rôles neuronal, un analyseur AMR français ou un désambiguïsateur
supervisé maison. La preuve (§ 5 et § 6) montre que, même au meilleur niveau, ils n'atteignent pas la précision qu'une
prémisse exige. Leur sortie devrait de toute façon repasser par le licencieur.

---

## 11. Le plan d'évaluation, par priorité

Chaque mesure est faite **sur des références construites avant le réglage**, par des annotateurs distincts des
rédacteurs (C6.2), avec double annotation et adjudication sur un échantillon. Un même critère de sortie sert partout,
celui de C3 : **aucune dérivation certaine fausse dans l'échantillon**, avec une borne supérieure de Wilson ≤ 5 %. Il
faut pour cela au moins 73 cas certains jugés sans erreur, puisque 3,84 / (n + 3,84) ≤ 0,05 donne n ≥ 73. La
**couverture** (la part des dérivations certaines) et le **rappel des hypothèses** sont publiés.

1. **E1 : les nominalisations (L2 et L3, la priorité absolue).**
   - Référence : toutes les occurrences « N d'action + of / de + X »
     - des libellés anglais et français d'Iconclass (côté C3),
     - et des textes de développement (côté C7),
     - par strates de 200 + 200.
   - Pour chaque occurrence, l'annotateur dit : N est-il une action ici, ou un objet, une œuvre, un résultat ? Quel
     verbe ? Quel rôle pour X (agent, subissant, autre, aucun) ?
   - On compare trois versions : la règle actuelle ; la même filtrée par NOMLEX et Démonette ; la même plus D30
     appliqué à la lecture d'action.
   - Mesures : faux certains (le critère ci-dessus), couverture, effet sur les verdicts de C6.4 (paraphrase, rôles
     inversés).
   - Contrôle indépendant possible en français : la proportion d'occurrences annotées Act ou Event dans **FrSemCor**,
     pour les noms qui ont un sens `noun.act` dans WOLF. Elle teste l'hypothèse du lexfile sur un corpus annoté par
     d'autres.
2. **E2 : le participant unique (R2 et P1).**
   - Référence : les emplois intransitifs et les participes des libellés et des textes de développement.
   - Mesure : la justesse de la consultation PropBank / VerbNet / Verb∋Net / Dicovalence, et le taux d'alternatives
     produites.
   - Référence externe en français : le corpus de 1 001 phrases (UP 2.0), avec son bruit connu [V][54].
3. **E3 : le macro-rôle (R1).**
   - Vérifier sur les graphes et les définitions de référence de C6 que réunir patient et thème des deux côtés ne
     change aucun verdict des paires minimales (107) et des variantes de C6.4.
   - Compter les définitions dont la requête distinguait réellement patient et thème.
4. **E4 : la syntaxe profonde.**
   - Comparer les règles de réécriture et les règles actuelles d'`interpretation.pl` sur les paires minimales et sur
     les graphes annotés de C6 (rappel et précision des rôles et des relations orientées, par catégorie, C6.2).
   - Contrôle externe : deep-sequoia pour le français [S][33], si la licence le permet.
5. **E5 : les hypothèses de sens (UKB).**
   - Référence : les sens WordNet ou WOLF des mots pleins de 200 textes de développement.
   - Mesures :
     - le **rappel d'ensemble** (le bon sens est-il dans l'ensemble gardé ?), avec une cible de 99 % ou plus ;
     - la justesse au premier rang ;
     - la **calibration** (erreur de calibration attendue et score de Brier) après un étalonnage isotone appris sur
       une moitié et testé sur l'autre ;
     - l'effet sur le rappel à 5 de C9.
   - Contrôles hors domaine : XL-WSD français (noms) et SemEval-2013.
6. **E6 : la coréférence.**
   - La couche de coréférence de **FRAME** (anglais, CC BY 4.0) [V][78], et 50 cartels français annotés.
   - Mesures : la précision des `coref` certaines (syntaxiques) et le rappel des `coref_possible`.
7. **E7 : la couverture des lexiques en français.**
   - La part des verbes des libellés français et des cartels présents dans Verb∋Net, Dicovalence et Démonette-2.
   - La part des noms d'action présents dans Démonette-2.
   - Ces mesures décident de l'étendue de la table NomLex-FR.

**L'ordre recommandé** : E1, puis E3 (il ne coûte presque rien et simplifie E1 et E2), puis E2, E4, E7, E5 et E6.

---

## 12. Incertitudes et points non vérifiés

- **Licences à confirmer avant toute redistribution** :
  - NOMLEX-PLUS et les cadres de NomBank (pages de NYU indisponibles) ;
  - SemLink (aucune licence affichée) ;
  - VerbAtlas ;
  - LVF (page du RALI inaccessible) ;
  - ASFALDA ;
  - Verbaction, Nomage, DériF, CatVar ;
  - Grew ; deep-sequoia ;
  - coreferee ;
  - FrSemCor (sources contradictoires) ;
  - la spécification anglaise de CIDOC CRM.
- **Chiffres non obtenus** :
  - la taille actuelle du Lefff ;
  - les nombres actuels de l'AAT ;
  - les scores de l'analyseur AMR français de TALN 2026 ;
  - les scores de coreferee ;
  - la vitesse de Stanza sur CPU en français (à mesurer localement : le projet a déjà relevé 14 s contre 4 s pour
    UDPipe sur les paires, chargement compris, D20 bis).
- **Mes comptages [L]** (NOMLEX-PLUS, libellés d'Iconclass, FrameNet, WordNet) sont faits par expressions régulières.
  Ils sont **indicatifs** et à refaire proprement dans un script versionné si on les cite dans une décision. Le
  comptage des noms suivis de « of » ne regarde que le mot suivant.
- **Le comportement exact de `nominalisation/3` sur *deposition*** a été déduit de la lecture du code et de WordNet,
  **pas exécuté**.
- **Deux affirmations viennent de ma connaissance des consignes d'annotation**, non relues ici : UCCA ne distingue pas
  les participants ; AMR n'encode pas la portée.
- **La lecture juridique des licences** (NC et usage interne, SA et base dérivée, GPL et programme séparé) n'est **pas
  un avis juridique**.

---

## 13. Sources

1. Les documents du dépôt : `docs/ASSERTIONS.md`, `docs/PLAN_V1.md`, `docs/NOYAU.md`, `docs/QUALIFICATION_NOYAU.md`, `docs/INSTALLATION.md`, `DECISIONS.md`, `oedipamaas/socle/normalisation.pl`, `oedipamaas/socle/interpretation.pl`.
2. Djemaa et al., *Corpus Annotation within the French FrameNet: a Domain-by-domain Methodology*, LREC 2016. https://aclanthology.org/L16-1601/
3. ASFALDA, site du projet. https://sites.google.com/site/anrasfalda/ — version 1.3 : http://asfalda.linguist.univ-paris-diderot.fr/frameIndex.xml
4. VerbNet, licence. https://verbs.colorado.edu/~mpalmer/projects/verbnet/license.3.0.txt ; téléchargements : https://verbs.colorado.edu/verbnet_downloads/downloads.html
5. VerbNet, dépôt GitHub. https://github.com/cu-clear/verbnet
6. VerbNet, site. https://verbs.colorado.edu/verbnet/
7. Verb∋Net (VerbeNet), dépôt. https://github.com/aymara/verbenet
8. Pradet, Danlos et de Chalendar, *Adapting VerbNet to French using existing resources*, LREC 2014. https://aclanthology.org/L14-1204/ ; Danlos et al., *Un Verb@net du français*, TAL 2016. https://aclanthology.org/2016.tal-1.2.xml
9. PropBank, cadres. https://github.com/propbank/propbank-frames ; https://propbank.github.io ; *Description of PB3 changes*. https://github.com/propbank/propbank-documentation/blob/master/other-documentation/Description-of-PB3-changes.md
10. ACL 2024, article citant 8 815 cadres PropBank et NomBank. https://aclanthology.org/2024.acl-long.857.pdf
11. Macleod et al., *NOMLEX: a lexicon of nominalizations*, EURALEX 1998. https://euralex.org/publications/nomlex-a-lexicon-of-nominalizations/ ; NOMLEX-PLUS (rapport d'Illinois SRL). https://gitlab.engr.illinois.edu/cogcomp/illinois-srl/-/blob/e94d6880eb8f43219a3a02ca93731dac2da206ab/doc/report.org
12. NomBank v1.0, LDC2008T23. https://catalog.ldc.upenn.edu/LDC2008T23
13. Stowe et al., *SemLink 2.0: Chasing Lexical Resources*, IWCS 2021. https://aclanthology.org/2021.iwcs-1.21
14. SemLink, dépôt. https://github.com/cu-clear/semlink
15. Lopez de Lacalle et al., *A Multilingual Predicate Matrix*, LREC 2016. https://aclanthology.org/L16-1423/ ; page : https://adimen.ehu.eus/web/PredicateMatrix (503 pendant l'étude)
16. Di Fabio, Conia et Navigli, *VerbAtlas*, EMNLP-IJCNLP 2019. https://aclanthology.org/D19-1058/ ; annonce : https://lists.w3.org/Archives/Public/semantic-web/2020Mar/0067.html
17. Bibliographie Dubois et Dubois-Charlier (LVF, 25 610 entrées). https://hommagedubois.sciencesconf.org/data/pages/Bibliographie_Dubois_Charlier.pdf ; Abdi et Lapalme 2014. https://preview.aclanthology.org/fix_video/W14-6402.pdf
18. Dicovalence : annonce de 2006. https://listserv.linguistlist.org/pipermail/linguist/2006-December/033321.html ; manuel : https://repository.ortolang.fr/api/content/dicovalence/1/documentation/DicovalenceManuel_v20_100625.pdf
19. Sagot, *The Lefff…*, LREC 2010. https://aclanthology.org/L10-1487/ ; fiche Hugging Face : https://huggingface.co/datasets/sagot/lefff_morpho
20. Liens morphosémantiques de WordNet, README. https://wordnetcode.princeton.edu/standoff-files/morphosemantic-links-README.txt
21. CLIB 2014, article citant 17 740 paires. https://aclanthology.org/2014.clib-1.3.pdf
22. Annonce de Démonette-2 (2023). https://listserv.linguistlist.org/pipermail/linguist/2023-April/111805.html ; OSF : https://osf.io/db2w8/
23. Démonette-1.1 (2015). https://listserv.linguistlist.org/pipermail/linguist/2015-May/074409.html ; Namer, Hathout et al. 2023 : https://halshs.archives-ouvertes.fr/hal-04363595v1/file/lex33_namer_hathout_et_al._bat_pdf_5_12_2023.pdf
24. FrameNet, données. https://framenet.icsi.berkeley.edu/framenet_data ; statistiques secondaires : https://arxiv.org/pdf/2109.07725
25. Chanin, *Open-source Frame Semantic Parsing*, 2023. https://arxiv.org/abs/2303.12788
26. Xia et al., *LOME*, EACL 2021, démo. https://aclanthology.org/2021.eacl-demos.19
27. Marzinotto et al., *Semantic Frame Parsing for Information Extraction: the CALOR corpus*, LREC 2018. https://aclanthology.org/L18-1159/
28. Huyghe, article sur les noms d'action (Verbaction). https://unifr.ch/llf/fr/assets/public/articles_huyghe/Nouvelles%20publications_RH/huyghe_cdl105.pdf ; TALN 2011 : https://aclanthology.org/2011.jeptalnrecital-court.9.pdf
29. Balvet, Barque et Marín, *Building a Lexicon of French Deverbal Nouns from a Semantically Annotated Corpus*, LREC 2010. https://aclanthology.org/L10-1122/ ; WoLeR 2011 : https://halshs.archives-ouvertes.fr/halshs-01078047
30. Habash et Dorr, *A Categorial Variation Database for English*, NAACL 2003. https://aclanthology.org/N03-1013.xml
31. Schuster et Manning, *Enhanced English Universal Dependencies*, LREC 2016. https://aclanthology.org/L16-1376/
32. Candito, Guillaume, Perrier et Seddah, *Enhanced UD Parsing with Deep Syntax* (UDW 2017). https://preview.aclanthology.org/fix_video/W17-6507.pdf
33. Candito et al., *Deep Syntax Annotation of the Sequoia French Treebank*, LREC 2014. https://aclanthology.org/L14-1410/
34. Guillaume et Perrier, IWPT 2021 (réécriture de graphes vers les EUD). https://preview.aclanthology.org/fix_video/2021.iwpt-1.18.pdf
35. Tâche partagée IWPT 2021 sur les EUD. https://aclanthology.org/2021.iwpt-1/ ; https://arxiv.org/abs/2107.01982
36. Stanza, performances (v1.5.1, UD 2.12). https://stanfordnlp.github.io/stanza/performance.html
37. AMR 3.0, LDC2020T02. https://catalog.ldc.upenn.edu/LDC2020T02
38. Kumar et al., *How Reliable are AMR Parser Outputs? Uncertainty Estimation for AMR Parsing*, 2026. https://arxiv.org/abs/2610.13236
39. Modèles amrlib. https://github.com/bjascob/amrlib-models
40. Documentation d'amrlib. https://amrlib.readthedocs.io/en/latest/models/
41. Kang et al., analyseur AMR français sans données françaises, IWCS 2023. https://aclanthology.org/2023.iwcs-1.25.pdf ; TALN 2026 : https://talnarchives.atala.org/TALN/TALN-2026/19.pdf (503 pendant l'étude)
42. *ding-01 :ARG0: An AMR Corpus for Spontaneous French Dialogue*. https://arxiv.org/html/2508.12819v1
43. UMR : tâche partagée 2026. https://ceur-ws.org/Vol-4323/paper18.pdf ; SETUP : https://arxiv.org/html/2512.07068v1 ; LREC-COLING 2024 : https://aclanthology.org/2024.lrec-main.229.pdf
44. Hershcovich et al., *SemEval-2019 Task 1: Cross-lingual Semantic Parsing with UCCA*. https://aclanthology.org/S19-2001/
45. White et al., *The Universal Decompositional Semantics Dataset and Decomp Toolkit*, LREC 2020. https://aclanthology.org/2020.lrec-1.699/
46. Decomp, dépôt. https://github.com/decompositional-semantics-initiative/decomp
47. AllenNLP SRL-BERT (miroir de Papers with Code). https://astro.paperswithcode.com/lib/allennlp/srl-bert
48. AllenNLP, dépôt (archivé). https://github.com/allenai/allennlp
49. multi-srl (Conia et Navigli, COLING 2020). https://github.com/SapienzaNLP/multi-srl
50. Conia et al., *InVeRo-XL*, EMNLP 2021, démo. https://aclanthology.org/2021.emnlp-demo.36
51. Tripodi, Conia et Navigli, *UniteD-SRL*, Findings EMNLP 2021. https://aclanthology.org/2021.findings-emnlp.197
52. UniteD-SRL, dépôt. https://github.com/SapienzaNLP/united-srl
53. van der Plas, Samardžić et Merlo, *Cross-Lingual Validity of PropBank in the Manual Annotation of French*, LAW 2010. https://aclanthology.org/W10-1814/
54. Jindal et al., *Universal Proposition Bank 2.0*, LREC 2022 (tableaux 2 et 4 lus dans le PDF). https://aclanthology.org/2022.lrec-1.181.pdf
55. Agirre, López de Lacalle et Soroa, *The risk of sub-optimal use of Open Source NLP Software: UKB…*, 2018. https://arxiv.org/abs/1805.04277
56. ConSeC, dépôt. https://github.com/SapienzaNLP/consec ; article : https://aclanthology.org/2021.emnlp-main.112
57. EWISER, dépôt. https://github.com/SapienzaNLP/ewiser ; article : https://aclanthology.org/2020.acl-main.255
58. Pasini, Raganato et Navigli, *XL-WSD*, AAAI 2021 (tableaux 2 à 4 lus dans le PDF). https://ojs.aaai.org/index.php/AAAI/article/view/17609
59. XL-WSD, page du projet. https://sapienzanlp.github.io/xl-wsd/
60. Navigli, Jurgens et Vannella, *SemEval-2013 Task 12: Multilingual Word Sense Disambiguation* (tableaux lus dans le PDF). https://aclanthology.org/S13-2040
61. Barque et al., *FrSemCor*, LREC 2020. https://aclanthology.org/2020.lrec-1.724 ; site : https://frsemcor.github.io/FrSemCor
62. Liu et Liu, *Ambiguity Meets Uncertainty: Investigating Uncertainty Estimation for Word Sense Disambiguation*, Findings ACL 2023. https://aclanthology.org/2023.findings-acl.245
63. UKB, dépôt. https://github.com/asoroa/ukb
64. Scozzafava et al., *Personalized PageRank with Syntagmatic Information for Multilingual WSD*, ACL 2020, démo. https://aclanthology.org/2020.acl-demos.6
65. Orlando et al., *AMuSE-WSD*, EMNLP 2021, démo. https://aclanthology.org/2021.emnlp-demo.34 ; API : https://nlp.uniroma1.it/amuse-wsd/api-documentation
66. AMuSE-WSD, page « about » (licence). https://nlp.uniroma1.it/amuse-wsd/about
67. Stanza, coréférence. https://stanfordnlp.github.io/stanza/coref.html
68. Stanza, modèle français (dossier coref). https://huggingface.co/stanfordnlp/stanza-fr/tree/main/models/coref
69. coreferee. https://github.com/explosion/coreferee ; https://pypi.org/project/coreferee
70. Wilkens et al., *French Coreference for Spoken and Written Language*, LREC 2020. https://aclanthology.org/2020.lrec-1.10
71. Données d'Iconclass. https://github.com/iconclass/data ; https://iconclass.org/help/data
72. Getty, données et services des vocabulaires (ODC-By 1.0). https://www.getty.edu/research/tools/vocabularies/lod/
73. Entretien FAO et AIMS sur les vocabulaires Getty en données liées (2014). https://aims.fao.org/in-action/interviews/experiences-publishing-getty-vocabularies-lod
74. Versions de CIDOC CRM. https://cidoc-crm.org/versions-of-the-cidoc-crm ; traduction française : https://publications.gc.ca/collections/collection_2024/pch/CH44-185-2024-fra.pdf
75. Banar, Daelemans et Kestemont, *Transfer Learning for the Visual Arts: The Multi-Modal Retrieval of Iconclass Codes*, JOCCH 2023, DOI 10.1145/3575865 ; ICAART 2021 : https://www.scitepress.org/Papers/2021/103906
76. Springstein et al., *Visual Narratives: Large-Scale Hierarchical Classification of Art-Historical Images*, WACV 2024. https://openaccess.thecvf.com/content/WACV2024/html/Springstein_Visual_Narratives_Large-Scale_Hierarchical_Classification_of_Art-Historical_Images_WACV_2024_paper.html
77. Kutt et Baczyński, *Iconographic Classification and Content-Based Recommendation for Digitized Artworks* (CARIS), 2026. https://arxiv.org/html/2602.19698v1 ; Iconclass AI Test Set : https://iconclass.org/testset/
78. Schneider et al., *A Dataset for Named Entity Recognition and Relation Extraction from Art-historical Image Descriptions* (FRAME), 2026. https://arxiv.org/html/2602.19133v1

**Les ressources locales consultées en lecture seule** (marquées [L]) :

- `/home/user/donnees/ressources/x/nombank.1.0/` (`frames/`, `NOMLEX-plus.1.0`) ;
- `/home/user/donnees/ressources/x/framenet_v17/` (`luIndex.xml`, `frame/`, `lu/`) ;
- `/home/user/donnees/ressources/x/verbnet3.3/` ;
- `/home/user/donnees/ressources/omw/omw-1.4/fra/` ;
- `/home/user/donnees/WordNet-3.0/dict/` ;
- `/home/user/donnees/iconclass-data/` (`LICENSE`, `notations.txt`, `txt/`, `kw/`).
