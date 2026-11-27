# État de l'art : ressources et méthodes réutilisables pour une couche d'inférence hors ligne

*Version du 27 novembre 2026. Étude documentaire, sans expérimentation, écrite par un agent : chaque affirmation porte
sa marque de vérification ([W] vérifié en ligne, [M] de mémoire, [NV] non vérifié). Les gloses WordNet citées ont été
revérifiées sur les fichiers locaux de WordNet 3.0 (`docs/INFERENCES.md`) ; les licences restent à confirmer avant
toute redistribution. L'expérience contrôlée qui en découle est dans `docs/INFERENCES.md`, § 5.*

---

## 0. Lecture rapide

- **Échecs de représentation (classe a)** : ils relèvent de la **canonisation**. Les meilleures ressources déjà disponibles sont :
  - en anglais : les liens *derivationally related form* et les **liens morphosémantiques** de WordNet 3.0 (rôles `event`, `agent`, `result`, `instrument`, `state`, etc.), les **rolesets unifiés de PropBank** (alias nominaux et adjectivaux d'un même prédicat) et NomBank ;
  - dans les deux langues, de façon partielle : les **unités lexicales FrameNet** (un nom et un verbe qui évoquent le même cadre) ;
  - en français : le **Réseau Lexical du Français** (fonctions lexicales du type S0, V0, A0), les **tables du Lexique-Grammaire** (noms prédicatifs) et certaines relations de **JeuxDeMots**.
- **Liens lexicaux manquants (classe b)** : WordNet en contient déjà beaucoup que le noyau n'exploite pas (`similar_to`, `attribute`, `pertainym`, `participle`, méronymie, `entailment`, `cause`). La ressource la plus rentable reste toutefois **les gloses** : celles de WordNet (anglais) et les définitions du Wiktionnaire (français, via DBnary). Compilées en graphes par le propre analyseur du système, elles permettent une **classification par définition**. Exemples : « organe de l'odorat » → nez, « sommet du crâne rasé en couronne » → tonsure, « cinquante ans de mariage » → noces d'or.
- **Inférence contextuelle (classe c)** :
  - connaissance certaine au niveau du schéma : les **relations entre cadres de FrameNet** (Causative_of, Inchoative_of, Subframe, Precedes) et les **prédicats sémantiques de VerbNet 3.4** (pré- et post-états de sous-événements) ;
  - génératrices d'hypothèses seulement : ConceptNet, ATOMIC-2020, VerbOcean, les schémas narratifs et les relations « typiques » de JeuxDeMots.
- **Moteur d'abduction** : l'**abduction pondérée de Hobbs** est le cadre de référence. Elle se réalise hors ligne en ILP (Henry, Phillip), en MaxSAT ou en ASP (clingo, `#minimize`). Le plus simple pour un noyau Prolog est de porter un **ensemble d'hypothèses (étiquette)** sur chaque conclusion, comme une ATMS. C'est le **même mécanisme** que les « hypothèses de sens » de la supervaluation : une conclusion est certaine si et seulement si son étiquette est vide.
- **Point faible : le français.**
  - FrameNet français (ASFALDA) : une centaine de cadres seulement.
  - Verb∋Net : licence et distribution non vérifiées.
  - WOLF et OMW : pas de relations lexicales entre mots (dérivation, pertainymie), et peu de gloses.
  - ConceptNet français : surtout issu du Wiktionnaire.
  - JeuxDeMots est la ressource française la plus riche en relations situationnelles (agent, patient, instrument, lieu, conséquence, cause, avant/après). Elle est produite par des joueurs et par des bots d'inférence, et sa licence reste à reconfirmer.
- **Licences** : la plupart sont permissives (WordNet, VerbNet, FrameNet, CIDOC CRM, AAT, Iconclass, Wikidata, ATOMIC-2020, GenericsKB, Quasimodo, IICONGRAPH). Plusieurs sont en **partage à l'identique** : ConceptNet, ESO, PropBank frames, JeuxDeMots (à reconfirmer), Wiktionnaire. SUMO est sous **GPL**. Les **LGPL-LR** et **CeCILL-C** (Lexique-Grammaire, Dicovalence, WOLF) imposent un copyleft faible. D'où la recommandation de **modules K séparés par licence**.

---

## 1. Cadre d'analyse

### 1.1 Les quatre opérations

| Opération | Ce qu'elle produit | Statut dans le noyau à quatre valeurs |
|---|---|---|
| **Canonisation** | Réécriture du graphe et de la requête vers une même forme (par exemple : nom d'événement → événement + prédicat verbal ; propriété → état) | Transformation, sans valeur de vérité propre. Elle doit être **sûre** : une équivalence seulement, sinon elle devient une hypothèse. |
| **Déduction** | Conséquences certaines de K et du graphe | Valeurs T/F (avec B en cas de conflit), éventuellement sous hypothèse de sens |
| **Abduction** | Hypothèses qui expliquent le texte | **Jamais assertées.** Elles sont portées par une étiquette d'hypothèse et classées par coût. |
| **Classification** | Catégorie d'une chose ou d'une situation décrite | Déductive si la définition est nécessaire et suffisante ; abductive si elle est seulement typique ou partielle |

### 1.2 Les cinq familles d'inférence contextuelle

1. **F1. Équivalences sémantiques** : synonymie, nominalisation, conversion (acheter/vendre), paraphrase définitionnelle.
2. **F2. Conséquences logiques** : hyperonymie, implication lexicale (*snore* ⇒ *sleep*), partie-tout obligatoire.
3. **F3. Connaissance des situations** : scripts et cadres (mariage : mariés, gâteau, portrait).
4. **F4. Relations états-événements** : pré- et post-conditions, état résultant, causalité (*mort* ⇐ *mourir* ⇐ *tuer*).
5. **F5. Hypothèses interprétatives** : par exemple « ils deviennent une maison religieuse sous sa conduite » → il fonde un ordre.

### 1.3 Critère d'admission dans K proposé

Le noyau distingue trois statuts possibles pour une connaissance K :

- **Certaine** : relation **définitionnelle ou lexicale**, curée à la main par des lexicographes (hyperonymie, synonymie de synset, implication et cause dans WordNet, Causative_of et Inchoative_of dans FrameNet, post-états de VerbNet). La supervaluation sur les sens s'applique toujours.
- **Génératrice d'hypothèses** : relation **typique, défaisable ou statistique** (co-hyponymie, `similar_to`, UsedFor, HasSubevent, happens-before, attributs de saints, mots-clés). Elle entre dans l'abduction avec un coût et n'est jamais assertée.
- **Inutilisable** :
  - connaissance **générée par un grand modèle de langue** (ATOMIC-10x, COMET, CANDLE et apparentés) : circularité avec la contrainte « pas de LLM » ;
  - licence incompatible ;
  - ressource introuvable hors ligne.

### 1.4 Légende de vérification

- **[W]** : vérifié en ligne lors de cette étude (page officielle ou dépôt du projet, sauf mention « source secondaire »).
- **[M]** : de mémoire, non revérifié.
- **[NV]** : non vérifié, ou contradictions entre sources.

---

## 2. Sémantique des cadres

### 2.1 FrameNet (Berkeley)

**Contenu.**
- Cadres (situations types) avec leurs éléments (Frame Elements, FE), unités lexicales (LU) et corpus annoté.
- Les LU couvrent **verbes, noms et adjectifs** (ainsi que quelques adverbes et prépositions). Par exemple, *die.v*, *death.n* et *dead.a* appartiennent à des cadres liés.
- Version publiée : **1.7**. Le site indique que les données en ligne sont plus récentes que la 1.7, mais moins contrôlées. [W]
- Taille : environ 1 200 cadres et 13 000 LU. [M, ordre de grandeur]

**Relations entre cadres.** Inheritance, Using, Subframe, Precedes, Perspective_on, Causative_of, Inchoative_of, See_also (et, selon les versions, ReFraming_Mapping ou Metaphor). [M] Pour le projet, elles se répartissent ainsi :
- **Inheritance** : sous-type de situation. → déduction (F2), certaine.
- **Perspective_on** : achat et vente comme perspectives d'un même transfert commercial. → **canonisation** (F1). C'est exactement l'équivalence « vendre/acheter » à réécrire.
- **Causative_of / Inchoative_of** : du type *Killing* → *Death* et *Death* → *Dead_or_alive*. → F4 (état ↔ événement ↔ cause). [M, chaîne à vérifier dans les données] Si cette chaîne est bien présente et si *lifeless.a* est une LU de *Dead_or_alive* (à vérifier), alors « corps sans vie » → mort est un parcours de K, pas une règle écrite à la main.
- **Subframe / Precedes** : scénarios composites découpés en étapes ordonnées (procès pénal, transfert commercial). → F3, scripts. Le sens « étape → scénario complet » est **abductif**. Le sens « scénario → existence d'étapes » est plus fort, mais pas toujours réalisé.
- **Using** : dépendance faible. → hypothèse seulement.

**Opérations servies.**
- canonisation (LU de catégories différentes dans un même cadre ; Perspective_on) ;
- déduction (Inheritance, Causative_of, Inchoative_of) ;
- abduction (Subframe, Precedes, Using) ;
- classification (LU nominales qui évoquent un cadre, par exemple *upholstery*, *imprisonment*).

**Couverture.** Anglais. Le français passe par ASFALDA, réduit (voir 2.2).

**Licence.** CC BY selon des sources secondaires : un miroir Hugging Face indique CC BY 2.0, un paquet tiers CC BY 3.0 pour la 1.5. Les anciennes versions (1.3) étaient sous licence ICSI restrictive. **Texte de licence officiel de la 1.7 non consulté (le site est rendu en JavaScript) [NV].**

**Disponibilité.** XML téléchargeable sur demande via le site, et distribué aussi dans `nltk_data` (`framenet_v17`). [M] Quelques centaines de Mo avec le corpus annoté. [M]

**Maturité.** Ressource de référence, mais maintenance lente (la 1.7 date de 2016 environ). [M]

**Alimentation du noyau.**
- **Certaine** : Inheritance, Perspective_on, Causative_of, Inchoative_of, et l'appartenance de deux LU à un même cadre (canonisation), toujours sous hypothèse de sens (une LU est un sens).
- **Hypothèse** : Subframe, Precedes, Using.

**Risques.**
- Couverture lexicale trouée.
- Cadres trop génériques pour l'iconographie.
- L'appartenance à un cadre **n'est pas l'équivalence** : *death.n* et *die.v* sont bien équivalents comme événements, mais *corpse.n* évoque aussi *Dead_or_alive*. Il faut donc distinguer les LU « cibles » d'événement des LU de participants (types sémantiques des LU, marquage des FE).

### 2.2 FrameNet français (ASFALDA) et autres ressources françaises

**Contenu.** Cadres adaptés de Berkeley, lexique de LU françaises et annotations en corpus. Chiffres de 2016 : **98 cadres, 662 mots évoquant un cadre, 872 sens, environ 13 000 occurrences annotées**. [W, article LREC 2016] Les domaines sont restreints (transactions commerciales, communication, cognition, causalité, positions spatiales…). [M]

**Disponibilité et licence.** Le projet ANR s'est terminé en juin 2016 [W]. Les données « DATA 1.3 » sont consultables en ligne, et la page du projet renvoie vers un contact pour les obtenir [W]. **Licence non trouvée [NV].**

**Rôle.** Utile pour aligner quelques LU françaises sur les cadres anglais. Trop petit pour la couverture. Rôle : **certain** pour les relations héritées de Berkeley, si la licence le permet.

**Autres ressources françaises de type cadre :**
- **Réseau Lexical du Français** (RL-fr, ATILF), fondé sur la théorie Sens-Texte. Son export sur ORTOLANG est sous **CC BY 4.0** [W, annonce LINGUIST 2017]. Il contient des **fonctions lexicales** : S0 (nom d'action : *mourir* → *mort*), V0 (verbe), A0 (adjectif), S1 (agent), Sinstr, Sloc, Sres (résultat), Able, etc. [M] C'est **la ressource française la plus directement utile pour la canonisation** (classe a). Taille et couverture exactes non vérifiées [NV].
- **JeuxDeMots** (section 4.6) : il a des relations de rôles (agent, patient, instrument, lieu) qui jouent le rôle de pseudo-cadres.

---

## 3. Lexiques verbaux et structure des événements

### 3.1 VerbNet 3.x et GL-VerbNet

**Contenu.**
- Classes de Levin étendues, avec rôles thématiques, restrictions de sélection, cadres syntaxiques et **prédicats sémantiques** (motion, contact, cause, has_state, has_location, has_possession…) indexés par un **variable d'événement**.
- Dans 3.4, la représentation est réécrite selon le **Lexique Génératif (GL-VerbNet)** : sous-événements ordonnés e1, e2, e3, avec états avant et après et négations explicites, par exemple `has_location(e1, Theme, Initial_Location)` puis `¬has_location(e3, …)`. [M ; un dossier `vn-gl` existe dans le dépôt [W]]
- Dernière version publique : **3.4**. [W, dépôt `cu-clear/verbnet`]
- Taille : de l'ordre de 300 classes principales et plus de 6 000 membres verbaux. [M, ordre de grandeur]

**Opérations et familles.**
- **F4** surtout : post-états (*break* → l'objet est cassé), pré-conditions (*arrive* : être ailleurs avant).
- **F2** : cause.
- Déduction : du verbe vers l'état résultant.
- **Abduction** dans le sens inverse : de l'état résultant vers le verbe. Elle n'est sûre que pour les états qui ne peuvent être que des résultats (être mort suppose d'être mort, donc un événement de mort pour un être vivant). Une porte ouverte, en revanche, n'implique pas qu'on l'a ouverte.

**Couverture.** Anglais. Pour le français, voir Verb∋Net (3.5).

**Licence.** Licence de l'Université du Colorado, qui couvre « VerbNet 3.0 ou 3.X » [W] :
- utilisation, copie, modification et distribution libres, pour tout usage, sans redevance ;
- conserver l'avis de copyright ;
- citer Kipper et al. ;
- ne pas utiliser le nom de CU dans la publicité.

Elle est permissive. Le dépôt GitHub n'affiche pas de fichier de licence distinct [W].

**Disponibilité.** XML sur GitHub, quelques Mo. [M]

**Alimentation du noyau.**
- **Certaine** pour les post-états et les pré-conditions attachés à une classe, sous hypothèse de sens. Un verbe appartient à plusieurs classes : c'est donc exactement le cas d'usage de la supervaluation.
- **Hypothèse** pour l'inversion état → événement, sauf pour les états marqués comme résultats obligatoires.

**Risques.**
- Les prédicats ont une granularité hétérogène.
- Il faut un **schéma de traduction** des prédicats VerbNet vers les relations du graphe. Ce schéma est générique et unique, pas iconographique, mais il est écrit à la main.
- Les verbes ne sont membres que de quelques classes, et les noms ne sont pas couverts (d'où PropBank, NomBank, SemLink).

### 3.2 PropBank (frames unifiées)

**Contenu.** Rolesets par sens de prédicat (Arg0…Arg5, ArgM). Les frames « unifiées » (3.x) rattachent les **alias nominaux et adjectivaux** à un même roleset, par exemple un nom d'événement et un adjectif à un sens verbal. [M ; une version d'« unification » est mentionnée dans le dépôt [W]]

**Opérations.** **Canonisation (F1)** : le nom et le verbe ont le même roleset et les mêmes arguments. C'est la solution directe aux couples *imprisonment/imprison* et *death/die*.

**Licence.** Fichiers de frames sous **CC BY-SA 4.0**, dernière version **3.4** [W, `propbank/propbank-frames`]. Les corpus annotés dépendent de corpus LDC sous licence et sont inutilisables pour redistribuer, mais ils ne sont pas nécessaires ici.

**Couverture.** Anglais (d'autres PropBanks existent, sans française publique connue [M]).

**Rôle.** **Certain** pour la canonisation (alias ↔ roleset), sous hypothèse de sens.

**Risques.**
- Le partage à l'identique contamine le module K qui l'incorpore.
- Les rôles Arg0/Arg1 ne sont pas des rôles thématiques : il faut passer par SemLink pour obtenir agent, patient, etc.

### 3.3 NomBank

**Contenu.** Structure argumentale des noms (nominalisations, noms relationnels), alignée sur les rolesets PropBank. Environ 4 700 frames nominales. [M]

**Rôle.** Canonisation nom → verbe avec projection des arguments. Par exemple, dans « emprisonnement de X par Y », X = Arg1 et Y = Arg0. **Certain** sous sens.

**Licence.** NYU, **non vérifiée [NV]**. Les frames étaient diffusées librement [M] ; le corpus dépend du Penn Treebank (LDC).

**Risque.** Ressource ancienne (2004-2008 environ) dont la maintenance est en grande partie absorbée par PropBank unifié. [M]

### 3.4 SemLink 2 et Predicate Matrix

**SemLink 2** :
- correspondances VerbNet ↔ PropBank (rôle à rôle) et VerbNet ↔ FrameNet ;
- bâti sur VerbNet 3.3, les frames PropBank unifiées et FrameNet 1.7 ;
- au format JSON (`pb-vn2.json`, `vn-fn2.json`) [W] ;
- **licence non indiquée sur le dépôt [NV]**.

Rôle : **pivot de canonisation** entre les rôles PropBank et les rôles du graphe (agent, patient, thème, instrument, destinataire, lieu). **Certain** pour les correspondances curées à la main.

**Predicate Matrix 1.3** (EHU) :
- intègre FrameNet, VerbNet, PropBank, WordNet, ESO et NomBank, avec des extensions automatiques des correspondances ;
- multilingue (espagnol, catalan, basque, **pas de français** [M]) ;
- sous **CC BY 3.0** [W, page projet via résultat de recherche ; la page était indisponible (503) lors de la vérification directe] ;
- au format tabulaire, tar.gz. [W]

Rôle : **hypothèse** pour les correspondances automatiques, **certaine** pour celles qui viennent de SemLink. Il faut conserver la colonne de provenance.

Risque : bruit des correspondances automatiques.

### 3.5 Ressources verbales françaises

- **Verb∋Net (Danlos, Pradet, de Chalendar et al.)** : adaptation de VerbNet au français à partir de LVF et du Lexique-Grammaire (LREC 2014 ; TAL 2016). [W pour les publications]
  - Disponibilité et **licence non trouvées [NV]**.
  - Si elle est obtenue, c'est le meilleur pont pour transporter les prédicats sémantiques de VerbNet (F4) vers le français. Rôle : **certain** sous sens, après vérification.
- **Dicovalence** (van den Eynde et Mertens) :
  - cadres valenciels de **plus de 3 700 verbes** simples [W, manuel v2.0] ;
  - licence **LGPL-LR** selon l'annonce de 2006 [W]. Une fiche Lindat indique CC BY 4.0, ce qui contredit l'annonce [NV]. Hébergé sur ORTOLANG [W, documentation].
  - Rôle : syntaxe vers rôles, utile pour l'analyseur plus que pour K. Peu d'apport inférentiel.
- **LVF, Les Verbes Français (Dubois et Dubois-Charlier)** :
  - **25 610 entrées** [W, bibliographie], avec classes syntactico-sémantiques et opérateurs sémantiques ;
  - versions Excel (MoDyCo) et XML (RALI) [W] ;
  - contient aussi, je crois, des informations de dérivation (noms en *-ment*, *-age*, adjectifs en *-able*) [M, à vérifier] ;
  - **licence non trouvée [NV]**.
  - Rôle potentiel : canonisation française (classe a) et classes d'événements.
- **Lexique-Grammaire (tables, LIGM ; version 3.4, E. Tolone)** :
  - tables de verbes, de **noms prédicatifs** (avec verbes supports) et d'expressions figées, au format CSV ;
  - **67 tables de verbes et 13 872 entrées** (5 738 verbes simples distincts) selon un miroir [W] ;
  - sous **LGPL-LR** [W].
  - Rôle : **canonisation** des constructions à verbe support (« faire une promenade » ≡ « se promener »). **Certain** sous sens.

---

## 4. WordNet au-delà de l'hyperonymie, et équivalents français

### 4.1 Relations de WordNet 3.0 sous-exploitées

| Relation | Exemple type | Opération / famille | Statut proposé |
|---|---|---|---|
| **entailment** (verbe ⇒ verbe) | *snore* ⇒ *sleep* | Déduction, F2/F4 | Certaine (sous sens) |
| **cause** (verbe → verbe) | *kill* → *die* | Déduction, F4 | Certaine (sous sens) |
| **derivationally related form** (lien entre mots) | *imprison* ↔ *imprisonment* | Canonisation, F1 | Certaine pour l'alignement ; la *nature* du lien est donnée par les liens morphosémantiques |
| **attribute** (nom ↔ adjectif) | attribut nominal ↔ valeurs adjectivales | Canonisation propriété ↔ nom d'état | Certaine |
| **similar_to** (adjectifs satellites) | *perfumed* ~ *fragrant* (à vérifier dans les données) | F1 affaiblie | **Hypothèse** : la similarité n'est pas la synonymie |
| **pertainym** (adjectif relationnel → nom) | *dental* → *tooth* | Canonisation adjectif relationnel → relation | Certaine |
| **participle** (adjectif → verbe) | adjectif participial → verbe | Canonisation propriété → état résultant, F4 | Certaine pour l'alignement ; le passage à l'événement passé est une hypothèse |
| **meronymy** (part, member, substance) | *deck* partie de *ship* | F2 (le tout existe) | Hypothèse à faible coût (le tout n'est pas toujours obligatoire) |
| **sister terms** (co-hyponymes) | *splint* / *brace* | — | **Hypothèse** seulement : ce ne sont jamais des équivalents |
| **antonymy** | *alive* / *dead* | Valeur F dans Belnap | Certaine (exclusion), utile pour produire F et B |
| **glosses** (définitions) | *nose* : « the organ of smell… » [M] | **Classification par définition**, F1 | Certaine si la définition est appariée entièrement et le genre commun respecté ; hypothèse sinon |

**Liens morphosémantiques (fichier à part de Princeton).** Ce sont des liens nom-verbe dérivationnels **typés par 14 relations** : agent, body-part, by-means-of, destination, **event**, instrument, location, material, property, **result**, **state**, undergoer, uses, vehicle [W, README]. Ils sont faits pour WordNet 3.0 [W], au format tableur (`.xls`) [W]. Le nombre de liens n'est pas indiqué dans le README (de l'ordre de 17 000 [M, NV]).

C'est **la ressource anglaise la plus adaptée à la classe (a)** :
- *death*–*die* (`event`) ;
- *imprisonment*–*imprison* (`event` ou `state`) ;
- *upholsterer*–*upholster* (`agent`).

Comme les liens portent sur des synsets, ils s'intègrent directement à la supervaluation.

**Gloses.** Corpus de gloses désambiguïsées de Princeton (« Gloss Corpus », fichiers à part) et eXtended WordNet (formes logiques des gloses, Moldovan et al.). [M, disponibilité et licence de XWN NV] La méthode recommandée est de **ne pas** reprendre ces formes logiques, mais de **compiler les gloses avec le propre analyseur texte → graphe du système**. On obtient des graphes définitionnels dans la même forme que les requêtes, et classification et abduction se réduisent alors à l'appariement de graphes. Exemples :
- « golden liquid pressed from olives » → *olive oil* : la glose contient « oil from olives » [M] ;
- « top of the skull shaved » → *tonsure* ;
- « fifty years of married life » → *golden wedding (anniversary)* [M].

**Licence de WordNet 3.0.** Licence Princeton, permissive de type BSD : usage, copie, modification et distribution libres avec l'avis de copyright, et interdiction d'utiliser le nom de Princeton dans la publicité [W, rappel sur la page de licence de ConceptNet]. Open English WordNet (CC BY 4.0, mises à jour régulières [M]) est une alternative maintenue, mais elle n'a pas les mêmes identifiants que la 3.0.

**Risques.**
- Gloses courtes et parfois circulaires.
- `similar_to` est hétérogène.
- La méronymie n'indique pas si la partie est obligatoire.
- WordNet n'est plus développé à Princeton (Wikipedia, 2026 [W, source secondaire]).

### 4.2 WOLF et OMW (français)

- **OMW, paquet français** : il **est WOLF** (WOrdnet Libre du Français, Sagot et Fišer 2008), sous **CeCILL-C v1** [W, `index.toml` de `omwn/omw-data`]. CeCILL-C est un copyleft faible, compatible LGPL [W].
- **Contenu** : littéraux français attachés aux synsets de PWN, construits automatiquement (corpus parallèles, Wiktionnaire, dictionnaires bilingues). Les relations **entre synsets** (hyperonymie, méronymie, `entailment`, `cause`, `attribute`, `similar_to`) sont **héritées** de PWN par l'alignement.
- **Limites pour la classe (a)** :
  - les relations **entre mots** (dérivation, pertainymie, participe, antonymie lexicale) ne se transfèrent pas : elles relient des formes anglaises ;
  - **peu ou pas de gloses françaises** [M] ;
  - bruit de construction automatique, et nombreux synsets sans littéral français [M].
- **Rôle** : certain pour les relations synset-synset (comme l'anglais), sous hypothèse de sens. Il faut le **compléter** pour les dérivations et les définitions.

### 4.3 WoNeF

Traduction automatique de WordNet vers le français (Pradet, de Chalendar, Baguenier-Desormeaux, GWC 2014), publiée en plusieurs variantes (haute précision, haute couverture). [W pour la publication ; M pour les variantes] **Licence et téléchargement non trouvés [NV].** Rôle possible : complément de littéraux français de WOLF, en ne gardant que la variante haute précision et en marquant les entrées comme hypothèses.

### 4.4 Définitions françaises : Wiktionnaire et DBnary

DBnary extrait le Wiktionnaire en RDF (Lemon/OntoLex). Il fournit définitions, synonymes, dérivés et traductions. Licence héritée du Wiktionnaire, **CC BY-SA** [M ; la version exacte (3.0 ou 4.0) est NV].

Rôle : **source de gloses françaises** pour la classification par définition. Les définitions ne sont pas désambiguïsées, donc :
- statut **hypothèse** par défaut ;
- **certain** seulement si l'entrée est monosémique.

### 4.5 Autres ressources dérivationnelles françaises

Démonette (base dérivationnelle), Verbaction (couples verbe / nom d'action), Lefff (morphologie, LGPL-LR [M]). **Licences de Démonette et de Verbaction non vérifiées [NV].** Elles sont très ciblées sur la classe (a) en français et méritent une vérification prioritaire.

### 4.6 JeuxDeMots (JDM, LIRMM)

**Contenu.**
- Réseau lexico-sémantique français construit par des jeux (validation par paires de joueurs) et enrichi par des **bots d'inférence** (Lafourcade et Le Brun, *Lexique* 2020). [W]
- Relations **typées et pondérées**. La liste officielle (`RELATION_LIST.txt` de la page de dumps) compte **165 identifiants de types** [W]. On y trouve notamment :
  - `r_isa`, `r_has_part` et `r_holo` ;
  - `r_syn`, `r_syn_strict`, `r_equiv` et `r_anto` ;
  - **`r_agent`, `r_patient`, `r_instr`, `r_lieu`** (et leurs inverses) ;
  - `r_carac` ;
  - **`r_has_conseq`** et **`r_has_causatif`** ;
  - **`r_telic_role`** et `r_agentif_role` (rôles qualia) ;
  - `r_product_of`, `r_action_lieu` et `r_lieu_action` ;
  - **`r_prev` et `r_succ`**, `r_successeur-time`, `r_has_predecesseur-time`, `r_successeur-logic` et `r_predecesseur-logic`.
- Je crois aussi que JDM a des **poids négatifs** qui marquent une relation jugée fausse [M]. Pour un noyau de Belnap, c'est une source naturelle de valeurs F et B.
- Je crois enfin qu'il existe des relations morphologiques ou de famille dérivationnelle [M, à vérifier dans `RELATION_LIST.txt`].

**Taille.** Plus de 310 000 termes et 6,5 millions de relations dans un article ancien [W]. Bien plus aujourd'hui [M, chiffre actuel NV].

**Licence.** **CC BY-SA** selon des sources de 2008-2009 (LinuxFr, article LIRMM : « by-sa 2.0 » pour les données, GPLv3 pour les API) [W, source secondaire]. **Aucune mention de licence sur la page de dumps [W].** La licence actuelle est **à reconfirmer auprès des auteurs [NV]**.

**Disponibilité.** Dumps téléchargeables depuis `jeuxdemots.org/JDM-LEXICALNET-FR/` (liste générée dynamiquement) [W]. Format texte propriétaire, à convertir.

**Opérations et familles.**
- F1 (`r_syn`, `r_equiv`) ;
- F2 (`r_isa`, `r_holo`) ;
- **F3** (`r_agent`, `r_instr`, `r_lieu`, `r_action_lieu`) ;
- **F4** (`r_has_conseq`, `r_has_causatif`, `r_prev`, `r_succ`) ;
- classification et abduction.

**Rôle.**
- `r_isa`, `r_syn_strict` et l'antonymie, avec un poids élevé : **certain** après évaluation sur échantillon (sinon hypothèse).
- Tout le reste : **hypothèse**, avec un coût dérivé du poids.

**Risques.**
- Le crowdsourcing ludique favorise les **associations** plutôt que les relations logiques.
- Une partie des relations est **inférée automatiquement** par le système lui-même : risque de propagation d'erreurs. Il faudrait pouvoir filtrer par provenance (joueur ou bot), ce qui n'a pas été vérifié.
- Les termes sont désambiguïsés par des « raffinements » de sens : leur alignement avec WOLF n'existe pas, à construire.
- Licence SA.

---

## 5. Ontologies d'événements et de situations

### 5.1 ESO, Event and Implied Situation Ontology (NewsReader)

**Contenu.** Ontologie OWL 2, version 2.0 stable [W] :
- 63 classes d'événements ;
- **123 assertions de situation** (pré-, pendant, post-situation, par exemple *Buying* : avant, A a l'objet et B l'argent ; après, l'inverse) ;
- 58 propriétés et 65 rôles ;
- correspondances SKOS vers SUMO (46) et vers FrameNet (103 cadres, 131 FE) [W].

**Domaine.** Automobile et financier [W], donc **peu pertinent pour l'iconographie**.

**Licence.** **CC BY-SA 4.0** [W, README].

**Rôle.** **Certain** pour F4 sur ses rares classes pertinentes (transfert, changement de possession, déplacement). C'est surtout un **modèle de représentation** des pré- et post-situations à imiter, plutôt qu'une source de contenu.

### 5.2 SEM, LODE, CIDOC CRM, DOLCE/DnS

- **SEM** (Simple Event Model) et **LODE** (Linking Open Descriptions of Events) : schémas minimaux (événement, acteur, lieu, temps). Ce sont des **modèles de structure**, sans connaissance inférentielle. Licences non vérifiées [NV]. Rôle : aucun pour K. Ils peuvent servir d'inspiration pour l'export.
- **CIDOC CRM** (7.1.3, février 2024) : ontologie de référence du patrimoine.
  - Événements (E5 Event, E7 Activity, E12 Production, E67 Birth, E69 Death, E85 Joining, E66 Formation…). [M pour les numéros de classes, à vérifier]
  - Licence **CC BY 4.0** (avis sur la page officielle de la 7.1.3) [W].
  - Il y a une initiative de traduction française [W].
  - Rôle : **taxonomie d'événements certaine** mais très générale. Utile pour l'interopérabilité avec les notices de musées (événements de production, de représentation), pas pour l'inférence contextuelle.
- **DOLCE / DUL (DOLCE+DnS Ultralite)** : distinctions fondatrices (endurant/perdurant, situation/description). Licence non vérifiée [NV]. Rôle : **aucun en contenu**. Il peut aider à cadrer la distinction **état / événement / propriété** qui cause les échecs de la classe (a).

### 5.3 SUMO et sa correspondance avec WordNet

**Contenu.** Ontologie de haut niveau en SUO-KIF, avec ses ontologies de domaine et des **correspondances vers tous les synsets de WordNet** (équivalence, subsomption, instance) [W, site]. SUMO contient des **axiomes** (par exemple sur la mort ou sur le changement d'état) [M].

**Licence.** Le dépôt `ontologyportal/sumo` est sous **GNU GPL** [W]. Le site dit que SUMO est « gratuit et propriété de l'IEEE » [W]. La licence des fichiers de correspondance WordNet n'est pas précisée à part [NV].

**Rôle.**
- **Certain** pour quelques axiomes de F4, après traduction de KIF vers Prolog.
- Les correspondances WordNet → SUMO, établies à la main mais assez grossières : **hypothèse**.

**Risques.**
- GPL : copyleft fort sur un K redistribué qui l'incorpore.
- Logique du premier ordre riche, difficile à traduire fidèlement en logique à quatre valeurs.

### 5.4 OpenCyc

Retiré par Cycorp en **2017** [W, source secondaire]. La dernière version (licence Apache 2.0 sur SourceForge [W]) circule encore. Les archives 2012 sont signalées comme corrompues à plusieurs endroits, et des OWL plus anciens restent disponibles [W, source secondaire]. **NextKB** (Northwestern) intègre l'ontologie OpenCyc sous **CC BY 4.0** [W, source secondaire].

Rôle : **non recommandé** pour une petite expérience (statut flou, ressource figée, alignement WordNet à refaire). NextKB est à examiner plus tard [NV].

### 5.5 VerbOcean

Relations entre verbes extraites du web par patrons lexico-syntaxiques (Chklovski et Pantel, 2004) : similarity, strength, antonymy, **enablement**, **happens-before** [M]. Environ 3 500 verbes et 22 000 relations [M, NV]. Anglais seulement. **Licence non vérifiée [NV].**

Rôle : **hypothèse** pour F3 et F4 (par exemple *arrest* happens-before *imprison*). Risque : bruit élevé, car fondé sur la cooccurrence de patrons.

### 5.6 Schémas narratifs (Chambers et Jurafsky)

Chaînes et schémas d'événements à protagoniste partagé, appris de manière non supervisée sur du texte journalistique. La base compte **environ 5 000 événements uniques** regroupés en schémas de taille 6 à 12, plus des ordonnancements temporels de verbes, en fichiers texte [W, LREC 2010 et miroir USNA]. **Licence non vérifiée [NV].**

Rôle : **hypothèse** F3. Risques :
- domaine journalistique (crimes, affaires), donc **faible adéquation** aux scènes iconographiques ;
- associations statistiques, pas des scripts au sens strict.

### 5.7 DeScript et ressources de scripts

**DeScript** (Wanzare et al., LREC 2016) :
- 40 scénarios × 100 descriptions de séquences d'événements, collectées par crowdsourcing (Mechanical Turk), avec des alignements partiels [W] ;
- licence non trouvée [NV] ;
- page de téléchargement sur le site de l'autrice [W].

Rôle : **hypothèse** F3 pour des scénarios quotidiens (aller chez le coiffeur, faire un gâteau…). Peu iconographique, mais il est proche de cas comme « tapisser un siège » ou « fêter un anniversaire ».

**Ressources voisines** : InScript (histoires annotées par script), OMICS, RKP/SMILE (Regneri et al.) [M, licences NV]. Toutes sont en anglais.

---

## 6. Connaissance de sens commun

### 6.1 ConceptNet 5 (5.7)

**Contenu.**
- Graphe multilingue d'assertions : IsA, PartOf, **UsedFor**, CapableOf, **AtLocation**, **HasPrerequisite**, **HasSubevent**, HasFirstSubevent, HasLastSubevent, **Causes**, MotivatedByGoal, HasProperty, MadeOf, ReceivesAction, Synonym, RelatedTo, DerivedFrom, FormOf, etc. [M]
- Sources : Open Mind Common Sense (crowdsourcé), Wiktionnaire, WordNet, DBpedia, OpenCyc, jeux (Verbosity), JMDict, CLDR… [W, page de licence pour une partie de la liste]
- **10 langues « cœur »**, dont le **français** (vocabulaire français annoncé à plus de 3 millions de termes, chiffre de 2016) [W, page Languages]. Je crois que les relations de sens commun (UsedFor, HasSubevent…) en français sont **beaucoup moins nombreuses** que les relations lexicales issues du Wiktionnaire [M].
- Données brutes 5.7 sur Zenodo, publiées le 27 février 2019 [W]. Le fichier d'assertions fait de l'ordre de quelques centaines de Mo compressé [M].

**Licence.** **CC BY-SA 4.0**. Attribution et partage à l'identique obligatoires, pas de restriction supplémentaire. Le Wiktionnaire et DBpedia sont sous CC BY-SA 3.0, et WordNet garde sa propre licence [W].

**Construction.** Surtout crowdsourcée et extraite. **Pas générée par un modèle neuronal**. Les plongements Numberbatch sont un produit séparé et ne sont pas à utiliser.

**Maintenance.** Peu d'évolution depuis 2019 [M].

**Rôle.** **Hypothèse** uniquement (F3, F4, F5), avec un coût par relation et par source.

**Risques.**
- Bruit élevé dans OMCS.
- RelatedTo n'est pas utilisable.
- **Circularité possible avec WordNet**, que ConceptNet importe déjà : il ne faut pas compter deux fois la même évidence.
- Partage à l'identique.

### 6.2 ATOMIC et ATOMIC-2020

**ATOMIC (2019)** : connaissance « si-alors » sur des événements du type « PersonX … », organisée en relations d'intention, de besoin préalable (xNeed), d'effet (xEffect, oEffect), de réaction et de désir. Elle a été crowdsourcée sur Mechanical Turk [M].

**ATOMIC-2020** :
- **environ 1,33 million de tuples, 23 relations** [W, article] ;
- relations sociales, physiques (objets : ObjectUse, AtLocation, MadeUpOf…) et événementielles (isBefore, isAfter, HasSubEvent, Causes, xReason…) [M pour la liste] ;
- composée d'ATOMIC, de nouveaux tuples crowdsourcés et d'un sous-ensemble de ConceptNet [M] ;
- évaluation humaine sur échantillon : 91,3 % d'acceptation [W].
- **Licence** : jeu de données sous **CC BY** (le dépôt n'indique pas la version) ; le code est sous Apache 2.0 [W]. Un miroir indique CC BY 4.0 [W, source secondaire].
- Anglais seulement.

**Attention à la circularité.** Les **modèles COMET** entraînés sur ATOMIC, et les graphes **ATOMIC-10x** (distillation symbolique de GPT-3), sont **générés par modèle** : ils sont **exclus**. ATOMIC-2020 lui-même est d'origine humaine [M, à confirmer dans l'article].

**Rôle.** **Hypothèse** F4 (xNeed ≈ pré-condition, xEffect ≈ post-condition) et F3.

**Risques.**
- Événements formulés en langue libre (« PersonX goes to the store ») : il faut les **analyser** avec le pipeline du système pour obtenir des graphes, ce qui ajoute du bruit.
- Biais social et mental, peu physique.

### 6.3 WebChild

Plus de 4 millions d'assertions désambiguïsées sur les sens WordNet (propriétés, parties, comparatifs, activités, spatial), avec 19 relations fines et une précision annoncée supérieure à 80 % [W]. Extraction automatique du web (méthodes de graphes et de propagation, pas de LLM [M]). **Aucune licence indiquée sur la page [W].** Rôle : **hypothèse**. Intérêt : les assertions sont **déjà ancrées sur des sens WordNet**, donc compatibles avec la supervaluation. Utilisation bloquée tant que la licence n'est pas clarifiée.

### 6.4 Quasimodo

Propriétés **saillantes** extraites des journaux de requêtes et des forums de questions-réponses, au format sujet-prédicat-objet avec un score de saillance (modèle supervisé classique), un indicateur de négation et un score d'unicité [W]. Version 4.3, **CC BY 2.0** (données et code) [W]. Anglais. Rôle : **hypothèse**, surtout pour la classification (propriétés typiques d'un concept).

### 6.5 Ascent et Ascent++

Assertions de sens commun **avec facettes** (sous-groupes, aspects), extraites du web : C4 pour Ascent++, qui compte environ 2 millions d'assertions en CSV [W]. Licence : Ascent v1 sous CC BY 4.0 selon sa page de téléchargement [W, source secondaire] ; **Ascent++ non vérifiée [NV]**. Le pipeline d'extraction utilise des composants neuronaux de taille modérée [M, à vérifier]. Ce ne sont pas des LLM génératifs, mais il faut le signaler. Rôle : **hypothèse**.

### 6.6 GenericsKB

**3,4 millions de phrases génériques** (« les olives sont pressées pour faire de l'huile »), dont un sous-ensemble « Best » de 1 020 868 phrases [W]. **CC BY 4.0** [W]. Phrases extraites de corpus. Le filtrage de « généricité » utilise un classifieur appris (de type BERT selon mes souvenirs [M]). Anglais.

Rôle : **hypothèse**, après analyse des phrases en graphes. Intérêt : il est **proche des gloses**, donc utile pour la classe (c), par exemple le liquide pressé des olives.

### 6.7 Ressources générées par LLM (à exclure)

ATOMIC-10x, les sorties COMET, CANDLE et tous les graphes « distillés » d'un grand modèle [M] sont **à exclure**. Ils violent l'esprit de la contrainte « pas de LLM » : ce serait une connaissance de LLM figée.

---

## 7. Méthodes d'abduction hors ligne sur connaissance symbolique

### 7.1 Abduction pondérée de Hobbs (« Interpretation as Abduction »)

**Principe** (Hobbs, Stickel, Appelt, Martin, *Artificial Intelligence* 1993 [M]) :
- Interpréter un texte, c'est trouver la **preuve la moins coûteuse** de sa forme logique.
- Chaque littéral observé a un **coût d'hypothèse**.
- Rétro-chaîner sur un axiome `P1^w1 ∧ P2^w2 → Q` remplace l'hypothèse de Q par celles de P1 et P2, au coût `w_i × coût(Q)`.
- **L'unification (factorisation)** de deux hypothèses identiques ne coûte qu'une fois. C'est ce qui récompense les explications **cohérentes** qui relient plusieurs indices : la couronne dorée, le couple, les cinquante ans et le gâteau s'unifient tous dans *noces d'or*.

**Adéquation au projet.**
- Les axiomes peuvent être **produits automatiquement** à partir de K, sans règles iconographiques : relations de cadres, liens morphosémantiques, gloses compilées en graphes, ConceptNet. C'est ce qu'a fait Ovchinnikova (axiomes tirés de WordNet et FrameNet ; système Mini-TACITUS ; thèse et livre de 2012 environ, évaluation sur RTE) [M].
- La **classification** devient l'abduction d'un littéral de catégorie, et la **canonisation** une abduction à coût nul sur des équivalences.

### 7.2 Abduction par ILP : Henry et Phillip

- **Inoue et Inui (2011)** reformulent la recherche de la meilleure explication pondérée comme un **programme linéaire en nombres entiers** [W]. Plans de coupe pour passer à l'échelle (travaux ultérieurs) [W].
- **Henry** (premier système, Inoue) puis **Phillip** (`kazeto/phillip`) : C++11, Python 2.7, solveur ILP Gurobi ou **LPSolve** (libre), sortie XML [W]. **Licence du dépôt non vérifiée [NV].** Il semble peu maintenu (Python 2.7) [W, indirect].
- **Reformulation en MaxSAT pondéré partiel** (Sasaki et al.) : nettement plus rapide que l'ILP selon les auteurs, l'ILP étant limité à environ 100 règles et observations [W, source secondaire].
- Applications connues : coréférence (Inoue, Ovchinnikova, Inui, Hobbs 2012), RTE, compréhension de récits [M].

### 7.3 Programmation logique abductive (ALP) et ASP

- **ALP** (Kakas, Kowalski, Toni) : programme + **abductibles** + **contraintes d'intégrité**. Procédures SLDNFA, CIFF, SCIFF [M]. Elles se réalisent **directement en Prolog** par un méta-interprète qui accumule les abductibles. C'est l'option la plus naturelle pour un noyau Prolog existant.
- **ASP (clingo, licence MIT [M])** : les abductibles sont des règles de choix `{ h(X) } :- candidat(X).`, les contraintes d'intégrité deviennent des contraintes, et le coût passe par `#minimize { C,H : h(H), cout(H,C) }`. L'énumération des **k meilleures explications** passe par l'optimisation itérée. L'ASP gère bien l'unification de Hobbs (une hypothèse partagée n'est comptée qu'une fois).
- Risque : explosion de la phase de **grounding** si K est volumineux. Il faut d'abord extraire le sous-graphe de K pertinent pour un texte (voisinage borné).

### 7.4 Programmation logique probabiliste (ProbLog) et logique de Markov

- **ProbLog** (KU Leuven, licence Apache 2.0 [M, NV]) : faits probabilistes, inférence MAP et marginale. L'abduction se fait par requête MAP sur les faits abductibles. Avantage : sémantique probabiliste claire. Inconvénient : il faut des **probabilités** calibrées, que les ressources n'ont pas (les poids de ConceptNet ou de JDM ne sont pas des probabilités).
- **Logique de Markov** : abduction en MLN (Kate et Mooney 2009 ; Singla et Mooney 2011, reconnaissance de plans) et mise en œuvre de l'abduction de Hobbs en MLN (Blythe et al. 2011) [M]. Outils Alchemy et Tuffy, vieillissants [M].
- **Évaluation sur récits.**
  - COPA (Roemmele, Bejan, Gordon 2011) : choix de la cause ou de l'effet plausible. Les méthodes symboliques et statistiques historiques (Gordon et al., causalité apprise sur des récits personnels) restent loin des modèles neuronaux [M].
  - Plans et récits : ACCEL (Ng et Mooney 1992), corpus Monroe [M].
  - Aucun banc d'essai d'abduction sur **descriptions d'œuvres** n'est connu.

### 7.5 Modèles de coût, classement et séparation hypothèses/assertions

**Coût proposé (inspiré de Hobbs) :**
- coût de base par type de relation et par ressource (source certaine : 0 ; WordNet `similar_to` < co-hyponymie < ConceptNet UsedFor < JDM association) ;
- multiplication le long des chaînes ;
- **bonus d'unification** quand une hypothèse explique plusieurs nœuds du graphe ;
- pénalité de spécificité excessive.

Les coûts doivent être **appris ou réglés sur un jeu de développement**, pas écrits cas par cas.

**Séparation.** Chaque conclusion porte une **étiquette** = ensemble d'hypothèses (sens choisis, abductibles, sources typiques), comme les environnements d'une ATMS (de Kleer) [M].
- *Certain* : étiquette vide, ou vraie pour tous les sens (supervaluation).
- *Sous hypothèse* : étiquette non vide.
- La valeur de Belnap s'évalue **par étiquette**. Un conflit entre deux hypothèses ne produit pas B sur les faits : il produit des explications concurrentes.

Le noyau a déjà ce mécanisme pour les sens. **Il suffit de généraliser l'étiquette** : le format de sortie existant (« sous hypothèse de sens ») devient « sous hypothèses {sens(w,s), abd(h1), …} ».

**Sortie.** Top-k explications avec leur coût, leur étiquette et la provenance de chaque axiome. **Rien n'est réinjecté comme fait** dans le graphe.

---

## 8. Connaissance iconographique et patrimoniale réutilisable

### 8.1 Iconclass (hiérarchie et mots-clés)

**Contenu.**
- Environ **40 000 notations de base**, et plus d'un million avec les « clés » et extensions [W, README].
- Textes (libellés) et **mots-clés** dans plusieurs langues : anglais, allemand, français, italien, néerlandais et d'autres [M ; la liste exacte n'a pas été vérifiée].
- Placeholders entre parenthèses pour les noms propres (`11H(...)`) [W].

**Licence.** Dépôt `iconclass/data` sous **CC0 1.0** [W]. Formats : fichiers texte structurés (`notations.txt`, dossiers `kw/` et `txt/`), scripts de génération SKOS et SQLite ; SKOS/RDF et JSON-LD par notation en ligne [W].

**Rôle.**
- La **hiérarchie** est une subdivision **thématique**, pas toujours un « est-un ». La traiter comme certaine seulement pour « est une spécification de ».
- Les **mots-clés** sont des **termes d'indexation**, pas des définitions. Ils servent d'**hypothèses** pour enrichir les requêtes compilées depuis les libellés (classification abductive). Leur avantage : ils viennent du système de classification lui-même, ce ne sont pas des règles écrites par le projet.

**Risques.**
- Circularité si les mots-clés sont aussi utilisés pour fabriquer les requêtes et pour les évaluer.
- Mots-clés inégaux d'une langue à l'autre.

### 8.2 Getty AAT

Thésaurus d'art et d'architecture (objets, matériaux, activités, styles, rôles). Il est sous **ODC-By 1.0**, l'URI canonique suffisant pour l'attribution [W]. Téléchargement complet en N-Triples mis à jour mensuellement, et point SPARQL [W]. Termes français partiels [M, NV].

Rôle : **certain** pour la hiérarchie générique (« damas » → tissu, « tapissier » → artisan) ; c'est un complément de WordNet sur le vocabulaire matériel. Il faut l'aligner avec WordNet, ce qui donne au mieux une **hypothèse** d'alignement. La Getty Iconography Authority existe, mais son statut de données ouvertes n'a pas été vérifié [NV].

### 8.3 Wikidata (données CC0 [M])

Propriétés vérifiées [W] :
- **P180 *depicts*** : entité représentée ; inverse **P1299 *depicted by***.
- **P921 *main subject*** : sujet principal, propriété liée.
- **P1354 *shown with features*** : qualificatif de P180 pour les éléments secondaires.
- **P4878 *symbolizes*** : symbolisme, aussi qualificatif de P180. Rarement utilisé selon IICONGRAPH [W].
- **P4185 *iconographic symbol*** : élément qui accompagne un personnage. Exemples : saint Pierre et les clefs, saint Laurent et le gril [W]. **C'est la propriété des attributs de saints.**
- **P1256 *Iconclass notation*** (pour un concept) et **P1257 *depicts Iconclass notation*** (pour une œuvre) [W].

Rôle :
- **P4185** : **hypothèse** de classification (un attribut suggère un personnage, mais plusieurs saints partagent des attributs).
- **P1257 + P180** : sur les œuvres, cela forme un **corpus d'alignement libellé Iconclass ↔ entités représentées**. Il peut servir à *évaluer*, et à *apprendre des coûts*, pas à écrire des règles.

Risques : saisie participative hétérogène et couverture inégale.

### 8.4 Ontologie ICON et IICONGRAPH

- **ICON** formalise les trois niveaux de Panofsky (préiconographique, iconographique, iconologique). Ontologie sous **CC BY 4.0** [W, fiche du brouillon].
- **IICONGRAPH** : graphe qui réingénierie les énoncés iconographiques d'**ArCo** (patrimoine italien) et de Wikidata. Version 1.0 du 8 décembre 2023, **CC BY 4.0**, dépôt Zenodo (deux DOI cités, 10294588 et 10294589, à départager) [W].

Rôle : **modèle de représentation** (séparer « ce qui est vu » et « ce que cela signifie », ce qui recoupe la séparation assertion / hypothèse) et **données d'évaluation**. Le contenu inférentiel réutilisable est faible.

---

## 9. Petits modèles hors ligne (option comparative seulement)

**Statut obligatoire** : « **classification par un modèle** ». Les sorties portent une étiquette `source=modèle(nom,version)`, ne deviennent **jamais** une connaissance certaine et n'entrent pas dans K. Elles servent seulement de point de comparaison mesuré, ou de générateur de candidats.

| Modèle | Usage | Taille | Licence | Langues |
|---|---|---|---|---|
| `cross-encoder/nli-deberta-v3-xsmall` | NLI (implication, neutre, contradiction) | ≈ 70,8 M paramètres | Apache 2.0 [W] | Anglais (SNLI 91,6 %, MNLI-mm 87,8 %) [W] |
| `MoritzLaurer/mDeBERTa-v3-base-xnli-multilingual-nli-2mil7` | NLI multilingue | ≈ 0,3 G paramètres | MIT [W] | 27 langues d'affinage, dont le français (XNLI-fr 82,3 %) [W] |
| Modèles de plongements multilingues compacts (par exemple la famille *paraphrase-multilingual-MiniLM*) | Recherche de gloses candidates | ≈ 100 M | Apache 2.0 [M, NV] | Multilingue |
| Étiqueteurs SRL et analyseurs FrameNet (AllenNLP SRL, open-sesame, LOME…) | Rôles ou cadres | quelques centaines de M | Apache 2.0 pour AllenNLP [M, NV] ; projet archivé [M] | Surtout anglais ; **pas d'étiqueteur FrameNet français mûr connu** [M] |

Usages pertinents :
- NLI entre la description et la paraphrase verbale d'un libellé Iconclass, comme **base de comparaison** ;
- **classement** des hypothèses produites par l'abduction symbolique (un réordonnancement mesuré, séparé du noyau).

Risques : données d'entraînement (MNLI, SNLI) sans rapport avec le domaine, effets de surface, et irreproductibilité si les versions ne sont pas figées.

---

## 10. Tableau de synthèse

Légende :
- **Op.** : C = canonisation, D = déduction, A = abduction, Cl = classification.
- **Fam.** : F1 à F5 (section 1.2).
- **Rôle** : **Cert.** = connaissance certaine (toujours sous sens) ; **Hyp.** = génératrice d'hypothèses ; **Non** = non utilisable ; **Modèle** = classification par modèle hors K.

| Ressource / méthode | Op. | Fam. | FR | Licence | Hors ligne | Rôle |
|---|---|---|---|---|---|---|
| WordNet 3.0 : hyper/hyponymie, `entailment`, `cause`, `attribute`, `pertainym`, `participle`, antonymie | C, D | F1, F2, F4 | via WOLF (relations synset) | Princeton, permissive [W] | oui | **Cert.** |
| WordNet `similar_to`, co-hyponymes, méronymie | A, Cl | F1, F2 | via WOLF | idem | oui | **Hyp.** |
| Liens morphosémantiques WN | C | F1, F4 | non | Princeton [M] (README sans mention) | oui (xls) | **Cert.** |
| Gloses WN (+ Gloss Corpus) compilées en graphes | Cl, A | F1 | non | Princeton [M] | oui | **Cert.** si l'appariement est complet, sinon **Hyp.** |
| Open English WordNet | C, D | F1, F2 | non | CC BY 4.0 [M] | oui | Cert. (alternative à la 3.0) |
| WOLF / OMW-fr | C, D | F1, F2 | **oui** | CeCILL-C v1 [W] | oui | **Cert.** (synsets), bruité |
| WoNeF | C | F1 | oui | **NV** | NV | Hyp. |
| Wiktionnaire / DBnary (définitions FR) | Cl, A | F1 | **oui** | CC BY-SA [M, version NV] | oui | **Hyp.** (Cert. si monosémique) |
| JeuxDeMots | C, D, A, Cl | F1 à F4 | **oui** | CC BY-SA ? (sources 2008) **à reconfirmer** | oui (dumps) [W] | Cert. (isa, syn strict, anto, poids fort) ; sinon **Hyp.** |
| Réseau Lexical du Français | **C** | F1, F4 | **oui** | CC BY 4.0 [W, annonce] | oui (ORTOLANG) | **Cert.** |
| Démonette, Verbaction | C | F1 | oui | **NV** | NV | Cert. si obtenus |
| FrameNet 1.7 : LU, Inheritance, Perspective_on, Causative_of, Inchoative_of | C, D, Cl | F1, F2, F4 | non | CC BY (sources secondaires) **NV** | oui | **Cert.** |
| FrameNet : Subframe, Precedes, Using | A | F3 | non | idem | oui | **Hyp.** |
| ASFALDA (FrameNet FR) | C, Cl | F1, F3 | oui (98 cadres) | **NV** | sur demande | Cert. (petit) |
| VerbNet 3.4 / GL-VerbNet | D, (A) | F4 | non | CU, permissive [W] | oui | **Cert.** (sens direct) ; Hyp. (inversion) |
| PropBank frames 3.4 (unifiées) | C | F1 | non | CC BY-SA 4.0 [W] | oui | **Cert.** |
| NomBank | C | F1 | non | **NV** | oui [M] | Cert. |
| SemLink 2 | C | F1 | non | **NV** (non indiquée) | oui | Cert. |
| Predicate Matrix 1.3 | C | F1 | non (es, ca, eu) | CC BY 3.0 [W, indirect] | oui | Cert. (partie SemLink) / Hyp. (partie automatique) |
| Verb∋Net | C, D | F4 | **oui** | **NV** | NV | Cert. si obtenu |
| Dicovalence | (C) | — | oui | LGPL-LR [W] / CC BY 4.0 ? (contradiction) | oui | Analyseur, pas K |
| LVF | C | F1, F4 | oui | **NV** | oui [W] | Cert. si licence OK |
| Lexique-Grammaire 3.4 | C | F1 | oui | LGPL-LR [W] | oui | **Cert.** (verbes supports) |
| ESO 2.0 | D | F4 | non | CC BY-SA 4.0 [W] | oui | Cert. (peu pertinent) |
| SEM, LODE, DOLCE/DUL | — | — | — | NV | oui | **Non** (modèles de structure) |
| CIDOC CRM 7.1.3 | D | F2 | traduction FR [W] | CC BY 4.0 [W] | oui | Cert. (très général) |
| SUMO + correspondance WN | D | F2, F4 | non | GPL [W] | oui | Cert. (axiomes) / Hyp. (correspondance) ; **licence contraignante** |
| OpenCyc / NextKB | D | F2, F4 | non | Apache 2.0 (historique) / CC BY 4.0 (NextKB) [W, secondaire] | partiel | **Non** pour l'instant |
| VerbOcean | A | F3, F4 | non | **NV** | oui [M] | Hyp. |
| Schémas narratifs (Chambers) | A | F3 | non | **NV** | oui [W] | Hyp. (domaine inadapté) |
| DeScript | A | F3 | non | **NV** | oui [W] | Hyp. |
| ConceptNet 5.7 | A, Cl | F3, F4, F5 | oui (surtout lexical) | CC BY-SA 4.0 [W] | oui | **Hyp.** |
| ATOMIC-2020 | A | F3, F4 | non | CC BY [W] | oui | **Hyp.** |
| ATOMIC-10x, COMET, graphes distillés de LLM | — | — | — | — | — | **Non** (circularité) |
| WebChild | A, Cl | F3 | non | **non indiquée** [W] | oui | Hyp. (bloqué par la licence) |
| Quasimodo 4.3 | A, Cl | F3 | non | CC BY 2.0 [W] | oui | Hyp. |
| Ascent / Ascent++ | A, Cl | F3 | non | v1 CC BY 4.0 / ++ **NV** | oui [W] | Hyp. |
| GenericsKB | A, Cl | F1, F3 | non | CC BY 4.0 [W] | oui | Hyp. |
| Iconclass (hiérarchie) | Cl | F2 | **oui** | CC0 [W] | oui | Cert. (« spécifie ») |
| Iconclass (mots-clés) | Cl, A | F1 | **oui** | CC0 [W] | oui | **Hyp.** |
| Getty AAT | D, Cl | F2 | partiel [NV] | ODC-By 1.0 [W] | oui | Cert. (hiérarchie) ; alignement Hyp. |
| Wikidata P180, P1354, P4878, P4185, P1256, P1257 | Cl, A | F3, F5 | **oui** | CC0 [M] | oui (dump) | **Hyp.** + évaluation |
| ICON / IICONGRAPH | — | F5 | partiel | CC BY 4.0 [W] | oui | Modèle de représentation + évaluation |
| Abduction pondérée (Hobbs), ALP en Prolog | A, Cl | F3 à F5 | — | méthode | oui | **Moteur recommandé** |
| clingo (ASP) | A | — | — | MIT [M] | oui | Moteur alternatif |
| Phillip / Henry (ILP) | A | — | — | **NV** | oui (C++, Python 2.7) | Référence, peu maintenu |
| ProbLog / MLN | A | — | — | ProbLog Apache 2.0 [M, NV] | oui | Secondaire (probabilités non calibrées) |
| NLI cross-encoder (xsmall EN, mDeBERTa multilingue) | Cl | — | mDeBERTa oui | Apache 2.0 / MIT [W] | oui | **Modèle**, comparaison seulement |
| Étiqueteurs SRL, analyseurs FrameNet | (C) | — | faible | NV | oui | **Modèle** |

---

## 11. Recommandation : une petite expérience contrôlée

### 11.1 Principe

- **Corpus** : les cibles en échec de l'expérience croisée (graphes et requêtes annotés à la main), chacune **étiquetée par sa classe d'échec** (a), (b) ou (c).
- **Méthode** : ajouter **une famille de ressources à la fois**, mesurer, puis cumuler.
- **Tout est hors ligne** : téléchargement unique, empreintes (sommes de contrôle) des fichiers et versions figées.

### 11.2 Ressources de canonisation (classe a) : à faire en premier

1. **Liens morphosémantiques de WordNet 3.0** (fichier Princeton, déjà compatible 3.0) : relations `event`, `state`, `result`, `agent` et `instrument`, pour les couples nom ↔ verbe (*death/die*, *imprisonment/imprison*). Coût : très faible. Licence permissive.
2. **`derivationally related form`, `attribute`, `pertainym`, `participle` de WordNet 3.0** (déjà dans la base) : couples propriété ↔ nom d'état (*bald/baldness*) et adjectif relationnel → relation.
3. **Frames PropBank 3.4 unifiées** (alias nominaux et adjectivaux) **+ SemLink 2** (rôles), dans un **module K séparé** à cause de BY-SA.
4. **Français** :
   - le **Réseau Lexical du Français** (S0, V0, A0, Sres ; CC BY 4.0) ;
   - les **tables de noms prédicatifs du Lexique-Grammaire** (LGPL-LR) ;
   - à défaut ou en complément, les **relations de JDM** : il faut d'abord **confirmer la licence**, puis prendre les relations morphologiques si elles existent [à vérifier].

Une **règle de canonisation générique unique** suffit, par exemple « un nom lié par `event` à un verbe se réécrit en nœud événement + prédicat verbal ». Elle s'applique **des deux côtés** (graphe et requête). C'est une règle linguistique, pas iconographique.

### 11.3 Ressources de connaissance lexicale (classe b)

1. **WordNet 3.0** : `similar_to` (hypothèse), méronymie (hypothèse à faible coût, pour *foredeck* → *ship*), co-hyponymie (hypothèse, pour *splint/brace*), `entailment` et `cause` (certains).
2. **Gloses WordNet compilées par l'analyseur du système** (anglais) et **définitions du Wiktionnaire via DBnary** (français, module BY-SA). Elles servent à la classification par définition : nez, tonsure, huile d'olive, noces d'or. C'est probablement **le meilleur rapport gain/coût** pour une partie des cas (c).
3. **Getty AAT** (ODC-By) pour le vocabulaire matériel (tissus, outils, métiers), en module optionnel.

### 11.4 Ressources de connaissance situationnelle (classes c et F3/F4)

1. **FrameNet 1.7 : relations entre cadres** (Causative_of, Inchoative_of, Perspective_on comme certaines ; Subframe, Precedes, Using comme hypothèses), sous réserve de confirmer la licence. Déjà dans `nltk_data`.
2. **VerbNet 3.4 (GL)** : post-états et pré-conditions, licence permissive. Seulement le **sens direct** comme certain.
3. **ConceptNet 5.7** (UsedFor, AtLocation, HasSubevent, HasPrerequisite, Causes, MadeOf) comme **générateur d'hypothèses**, en module BY-SA, avec un coût par relation. Il **n'apporte pas grand-chose en français**, ce qu'il faut mesurer.
4. Plus tard seulement : ATOMIC-2020 (xNeed/xEffect, anglais), GenericsKB, Iconclass (mots-clés), Wikidata P4185.

### 11.5 Moteur et mesures

- **Moteur** : méta-interprète abductif en Prolog, dans le noyau existant :
  - abductibles = relations « Hyp. » ;
  - coût de type Hobbs avec bonus d'unification ;
  - profondeur bornée ;
  - **étiquettes d'hypothèses unifiées avec les hypothèses de sens**.
  
  En parallèle, si nécessaire, une traduction ASP (clingo, `#minimize`) pour vérifier l'optimalité sur de petits cas.
- **Mesures, par langue et par classe d'échec** :
  - taux de cibles résolues **avec certitude** ;
  - taux de cibles résolues **sous hypothèse**, avec le rang de la bonne hypothèse (MRR, rappel@k) ;
  - **faux positifs certains**, qui doivent rester à zéro : c'est le critère d'admission dans « Cert. » ;
  - nombre moyen d'hypothèses par texte (inflation) ;
  - apport marginal de chaque ressource (ablation).
- **Comparaison optionnelle** : le cross-encoder NLI multilingue sur les paires (description, paraphrase du libellé), présenté comme « classification par un modèle », sur les mêmes cibles.

### 11.6 Ce qu'il ne faut pas faire au départ

- Pas de SUMO (GPL, traduction KIF coûteuse).
- Pas d'OpenCyc.
- Pas de schémas narratifs ni de VerbOcean (bruit, domaine inadapté).
- Aucune ressource générée par LLM.
- Pas de mots-clés Iconclass à la fois pour construire et pour évaluer (circularité).

---

## 12. Ce qui n'a pas pu être vérifié, et doutes

- **FrameNet 1.7** : texte de licence officiel non consulté (site en JavaScript). Les sources secondaires divergent entre CC BY 2.0 et 3.0. Les chaînes *Killing* → *Death* → *Dead_or_alive* et la LU *lifeless.a* sont de mémoire et à vérifier dans les données.
- **JeuxDeMots** : licence actuelle non affichée sur la page de dumps. La mention CC BY-SA date de 2008-2009. Ni la présence de poids négatifs ni celle de relations morphologiques n'ont été vérifiées. Taille actuelle inconnue. Impossible de distinguer les relations ajoutées par des joueurs de celles inférées par des bots (non vérifié).
- **ASFALDA, Verb∋Net, LVF, WoNeF, NomBank, SemLink, VerbOcean, schémas narratifs, DeScript, Phillip, Démonette, Verbaction** : licence non trouvée.
- **Dicovalence** : LGPL-LR (annonce de 2006) contre CC BY 4.0 (fiche Lindat). Contradiction non résolue.
- **Predicate Matrix** : licence CC BY 3.0 relevée dans un résultat de recherche ; la page officielle était indisponible (503) lors de la consultation.
- **WebChild** : aucune licence indiquée sur la page officielle.
- **Ascent++** : licence et part de composants neuronaux non vérifiées.
- **ATOMIC-2020** : la version exacte de CC BY n'est pas précisée dans le dépôt. L'origine entièrement humaine du jeu est de mémoire.
- **Iconclass** : la liste exacte des langues des mots-clés n'a pas été vérifiée. CC0 est vérifié sur le dépôt GitHub, mais pas sur iconclass.org.
- **Wikidata** : la licence CC0 des données est de mémoire. Les numéros de propriétés sont vérifiés.
- **Getty AAT** : couverture française et statut ouvert de la Getty Iconography Authority non vérifiés.
- **Chiffres de mémoire** (ordres de grandeur) : nombre de cadres et de LU de FrameNet, de classes de VerbNet, de liens morphosémantiques, de frames NomBank, et taille de VerbOcean.
- **Modèles** : licences des étiqueteurs SRL, des analyseurs FrameNet et des modèles de plongements non vérifiées.
- **Avertissement juridique** : les remarques sur la compatibilité des licences (BY-SA, GPL, CeCILL-C, LGPL-LR) sont des indications techniques, pas un avis juridique. La notion d'« adaptation » d'une base de données est à faire confirmer avant redistribution.

---

## Sources consultées (vérifications en ligne)

- ConceptNet : licence (wiki GitHub `commonsense/conceptnet5`, page « Copying and sharing ConceptNet ») ; langues (page « Languages ») ; Zenodo 5.7.
- ATOMIC-2020 : dépôt `allenai/comet-atomic-2020` ; arXiv 2010.05953.
- FrameNet : framenet.icsi.berkeley.edu (indication de version) ; sources secondaires (ruby-framenet, miroir HF).
- ASFALDA : ACL Anthology L14-1411 et L16-1601 ; site Google du projet ANR.
- VerbNet : `verbs.colorado.edu/~mpalmer/projects/verbnet/license.3.0.txt` ; dépôt `cu-clear/verbnet`.
- PropBank : dépôt `propbank/propbank-frames`. SemLink : dépôt `cu-clear/semlink`.
- Predicate Matrix : adimen.ehu.eus (via résultat de recherche).
- Verb∋Net : ACL Anthology L14-1204 ; TAL 2016.
- Dicovalence : manuel sur ORTOLANG ; annonce LINGUIST 2006. LVF : bibliographie MoDyCo / RALI.
- Lexique-Grammaire : infolingu.univ-eiffel.fr ; ligm.univ-eiffel.fr/~tolone.
- WordNet : README des liens morphosémantiques (wordnetcode.princeton.edu/standoff-files).
- OMW : `omwn/omw-data`, `index.toml` (entrée omw-fr).
- WOLF : Sagot et Fišer 2008. WoNeF : ACL Anthology W14-0105.
- JeuxDeMots : jeuxdemots.org/JDM-LEXICALNET-FR/ et `RELATION_LIST.txt` ; LinuxFr 2008 ; publications LIRMM.
- Réseau Lexical du Français : annonce LINGUIST List 28.3687.
- ESO : dépôt `RoxaneSegers/ESO-Ontology` ; ACL Anthology L16-1233.
- SUMO : dépôt `ontologyportal/sumo` ; ontologyportal.org. OpenCyc : mkbergman.com (2017), SourceForge, NextKB (Northwestern).
- CIDOC CRM : cidoc-crm.org (version 7.1.3).
- Schémas narratifs : ACL Anthology L10-1029 ; usna.edu/Users/cs/nchamber/data/schemas. DeScript : ACL Anthology L16-1556.
- Commonsense : WebChild, Quasimodo et Ascent++ (pages mpi-inf.mpg.de) ; GenericsKB (carte Hugging Face).
- Phillip : wiki GitHub `kazeto/phillip`. Inoue et Inui 2011.
- Iconclass : dépôt `iconclass/data` ; iconclass.org/help/lod. Getty : getty.edu/research/tools/vocabularies.
- Wikidata : pages des propriétés P180, P1299, P1354, P4878, P4185, P1256, P1257.
- IICONGRAPH : arXiv 2402.00048 ; Zenodo 10294589. ICON : w3id.org/icon.
- Modèles : cartes Hugging Face `cross-encoder/nli-deberta-v3-xsmall` et `MoritzLaurer/mDeBERTa-v3-base-xnli-multilingual-nli-2mil7`.
