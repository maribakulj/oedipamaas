# La spécification de K, la base de connaissances fédérée (version 0.1, 28/11, provisoire)

**Ce que c'est.** Le contrat unique, neutre et versionné de K, décidé par la propriétaire le 28/11
(`docs/ARCHITECTURE_LANGAGES.md`, § 4). Toute implémentation s'y conforme et cite la version de la spécification
qu'elle suit :
- le constructeur de K, en Prolog ;
- l'interface que consomme le noyau (`docs/NOYAU.md`, § 2) ;
- la syntaxe des connaissances de l'interpréteur de référence (`docs/LANGAGE_REFERENCE.md`, § 1.10), qui reste écrite
  indépendamment.

L'unité du langage ne garantit pas l'unité de la sémantique : c'est ce document qui la porte.

**Ce que ce n'est pas.** Ce n'est ni une ontologie générale, ni un dictionnaire, ni un raisonneur. K fédère des
ressources, garde la provenance de chacune, qualifie ce qu'elles proposent, et compile ce qui est qualifié vers le
noyau.

**Ses sources :**
- l'esquisse de `docs/MESURE_RESSOURCES_LEXICALES.md`, § 11 ;
- les décisions de la propriétaire du 28/11 ;
- le pilote de `docs/AUDIT_LANGAGES.md`, § 6, et la reproduction de ses problèmes (§ 6.1 ci-dessous).

**Les numéros de règle** sont stables. Une règle retirée garde son numéro, marqué « retiré ».

## 1. Les opérations, et ce qu'elles ont le droit de faire

K se construit en cinq opérations distinctes. **Aucune des quatre premières ne raisonne** : elles ne dérivent ni valeur
logique, ni statut de requête, ni preuve.

| opération | entrée | sortie | ce qu'elle peut faire | ce qu'elle ne fait jamais |
|---|---|---|---|---|
| **K1. importer** | un fichier de ressource | des entrées brutes, avec leur provenance | lire ; calculer l'empreinte du fichier effectivement lu ; signaler une erreur de syntaxe ou d'encodage | corriger, filtrer en silence, dédupliquer |
| **K2. transformer** | des entrées brutes | des entrées normalisées et des alignements proposés | calculer des clés (§ 4) ; aligner par une méthode déclarée ; voter | effacer la forme d'origine ; fusionner deux entrées ; donner un statut autre que `proposée` |
| **K3. valider** | les entrées, les alignements et les jugements | des violations d'invariants (§ 6) | contrôler, et échouer explicitement | réparer, ou ignorer une violation |
| **K4. compiler** | ce qui est validé | un module de faits pour le noyau, avec son manifeste | écrire des faits, avec la provenance et les versions | écrire un fait sans provenance, ou un fait dont le statut effectif ne le permet pas (§ 3.4) |
| **K5. raisonner** | le module compilé | — | c'est le noyau, hors de K | — |

**Une erreur est une erreur.** Un ensemble attendu vide, un fichier tronqué, une ligne mal formée ou une arité
inattendue arrêtent l'opération avec un message qui nomme la règle. Ils ne donnent jamais un code de sortie nul avec
une sortie vide.

## 2. Le modèle

### 2.1 Les ressources

Chaque ressource a :
- un `id` stable (`wordnet30`, `wolf`, `wonef_f`, `dbnary_fr`, `aat`, `joconde_th284`…) ;
- une `version`, prise telle quelle de la ressource (une chaîne, non interprétée) ;
- une `licence` exacte, avec ses obligations : attribution, partage à l'identique, et ce qui est permis pour la
  redistribution publique ;
- la `source` de téléchargement et sa date ;
- l'`empreinte` sha256 de chaque fichier lu.

### 2.2 Les entrées

**Une entrée** est ce qu'une ressource dit, à l'unité où elle le dit. C'est par exemple un littéral d'un synset WOLF,
un sens DBnary ou un concept de l'AAT. Elle a :
- `ressource` et `version` ;
- `id_origine`, l'identifiant dans la ressource, ou, à défaut, l'adresse de l'élément lu (fichier, ligne ou nœud) ;
- `forme_origine`, la chaîne telle que lue, octet pour octet après le décodage déclaré ;
- `provenance` : le fichier, son empreinte, la ligne ou le nœud ;
- ses attributs propres : la catégorie, la langue, les notes de la ressource (par exemple le `lnote` de WoNeF), sans
  interprétation.

**L'identité d'une entrée** est le triplet (`ressource`, `version`, `id_origine`). Elle ne passe jamais par une forme
normalisée. Quand la ressource ne donne pas d'identifiant à l'unité lue, comme un littéral WOLF dans son synset,
`id_origine` est l'identifiant de l'unité englobante suivi de la **forme d'origine exacte**, sans normalisation.

Il en découle trois choses :
- « Chose » et « chose », ou « été » en NFC et en NFD, sont deux entrées d'un même synset. Leur clé de vote commune les
  fait voter ensemble (§ 4), et la collision est rapportée (INV-N1). C'est la réponse à l'escalade du rapport de
  robustesse (§ 6.1).
- Deux entrées de même identité et de contenus différents sont une violation (INV-ID2).
- Deux entrées identiques en tout sont un doublon de la ressource : il est signalé et compté, jamais fusionné en silence
  (INV-ID3).

### 2.3 Les concepts

Un identifiant conceptuel est un espace de noms suivi d'un identifiant de la ressource : `wn30:02084071-n`,
`aat:300033618`, `joconde:th291/…`, `iconclass:…`. **Un identifiant conceptuel ne se dérive jamais d'une chaîne
normalisée** (§ 4).

Les concepts de travail `oc:` sont déclarés dans K. Chacun a sa glose, sa justification (le cas ou la règle qui en
demande la distinction) et ses alignements, eux-mêmes sourcés. On n'en crée que si un cas démontre le besoin de la
distinction.

### 2.4 Les relations

Une relation a :
- une `espece` : `lexicalisation` (une entrée vers un concept), `inclusion`, `partie`, `alias`, `distinction`,
  `incompatibilite` (indexée par le porteur, le moment et le contexte), `restriction_de_selection`, `typique` ou
  `alignement_concept` ;
- ses arguments ;
- sa `methode` : `lecture` (dite par la ressource elle-même), `alignement_automatique` (par un pivot, avec la règle),
  `vote` ou `redaction` ;
- sa provenance.

**Les espèces ne se mélangent pas.** L'antonymie de WordNet est une relation `typique` d'opposition proposée. Ce n'est
jamais une `incompatibilite` (`docs/INTERPRETATIONS_ADMISSIBLES.md`, § 6.1).

### 2.5 L'origine d'une connaissance : un postulat de référence ou une ressource externe

La propriétaire a demandé de distinguer ces deux origines le 28/11. Chaque relation de K a une `origine` :
- **`ressource_externe`** : la relation vient d'une ressource (§ 2.1). Sa qualification suit le § 3 ;
- **`postulat_reference`** : la relation est un postulat de signification de la sémantique de référence (K\*,
  `docs/INTERPRETATIONS_ADMISSIBLES.md`, § 2.2 ; le guide d'annotation, § 1). Elle n'a pas besoin d'une ressource pour
  valoir au niveau (a). Elle doit en revanche être déclarée, avec :
  - son énoncé ;
  - sa justification ;
  - la version de la sémantique de référence qui l'admet ;
  - les cas qui l'emploient.

  Elle n'est **pas** `attestée` au sens du § 3 : ce statut est réservé à ce qu'une ressource ou une relecture nommée
  établit.

**Ce que cela règle,** sous réserve de la confirmation de la propriétaire. Les deux pilotes de représentation formelle
se sont heurtés à la même contradiction (`docs/mesures/FORMEL_BANCS.md`, § 2.2 ; `QUALIFICATION_DELEGATION.md`, § 2) :
- un postulat du guide (« tenir ⇒ avec ») est un `postulat_reference` ; il vaut au niveau (a) sans attestation ;
- au niveau (b), relatif à un K nommé, il ne vaut que si ce K l'inclut. Un K nommé dit lesquels il inclut.

## 3. La qualification : les jugements et les statuts

### 3.1 Trois statuts de qualification

`proposée`, `attestée` et `rejetée` qualifient une relation d'origine `ressource_externe`. Ce sont des statuts de
**qualification des connaissances**. Ils ne sont ni des valeurs logiques (V, F, B, N), ni des statuts de satisfaction
d'une requête (`etablie`, `ecartee`…), et ne s'y traduisent pas directement : le § 3.4 dit ce que le noyau en fait.

- **`proposée`** est le statut de tout ce que produit une méthode automatique : un alignement par pivot ou un vote.
- **`attestée`** ne s'obtient que de deux façons :
  - une relecture humaine nommée ;
  - une ressource dont le fait est une décision éditoriale humaine, comme un libellé de thésaurus pour son propre
    concept ou une hiérarchie interne à un thésaurus.
- **`rejetée`** est un fait positif : une relation examinée et refusée, avec la même traçabilité qu'une attestation.
  **Le rejet d'une inclusion n'est pas une preuve de disjonction entre les concepts.** Rejeter « A ⊑ B » n'établit ni
  « A et B incompatibles », ni « aucun A n'est B ». Le rejet retire la relation. Il ne crée aucun appui négatif.

### 3.2 Les jugements, conservés

**Un jugement** porte sur une relation. Il a :
- un `statut`, parmi les trois ;
- une `source`, une personne ou une ressource ;
- une `methode` ;
- un `perimetre` : la langue, le domaine, le contexte d'emploi ou le K nommé pour lequel il vaut ;
- une `version`, celle de la relation jugée et celle du guide de relecture ;
- une `date` et une `justification`.

**Les jugements ne s'écrasent jamais.** Un nouveau jugement s'ajoute. Les précédents restent, et leurs contradictions
aussi. L'historique est en ajout seul (INV-J1).

### 3.3 Le statut effectif

Le statut effectif d'une relation, pour un périmètre donné, se **calcule** sur l'ensemble de ses jugements par une
règle déclarée et versionnée. Il ne se stocke pas à la place des jugements.

**La règle de la version 0.1,** proposée et à confirmer :
1. sans jugement, le statut est `proposée` si la relation vient d'une méthode automatique, `attestée` si elle est une
   lecture d'une ressource éditoriale (§ 3.1) ;
2. avec des jugements de même périmètre qui s'accordent, le statut est le leur ;
3. avec des jugements de même périmètre qui se contredisent (`attestée` et `rejetée`), la relation est **contestée**.
   Ce n'est pas un quatrième statut, mais un état du calcul. Pour le noyau, elle compte comme `proposée` : elle ne
   fonde qu'une hypothèse. La contradiction est rapportée ;
4. un jugement d'un autre périmètre ne s'applique pas.

### 3.4 Ce que le noyau reçoit

| statut effectif | ce que la relation peut fonder |
|---|---|
| `attestée` | un appui certain, dans son périmètre |
| `proposée`, ou contestée | une hypothèse seulement, de nature `connaissance_non_attestee` (`LANGAGE_REFERENCE.md`, § 3.12, L7). Elle peut ordonner des hypothèses ; elle ne peut ni établir ni exclure |
| `rejetée` | rien : la relation n'est pas compilée comme appui. Le rejet est compilé comme fait de qualification, pour la trace |

Une relation d'origine `postulat_reference` n'est compilée que dans un K nommé qui la déclare (§ 2.5).

## 4. Les chaînes : formes d'origine et clés

**La forme d'origine est toujours gardée** (`forme_origine`, § 2.2). La normalisation ne la remplace pas. Elle calcule
des **clés**, chacune pour un usage, et n'efface aucune distinction sémantique ou documentaire.

| clé | usage | calcul (version 0.1) | ce qu'elle peut confondre |
|---|---|---|---|
| `cle_recherche` | trouver une entrée à partir d'un mot du texte | NFC, puis pliage de casse complet (Unicode CaseFolding, statut C et F), puis NFC ; toute suite de caractères `White_Space` (dont U+00A0) réduite à une espace U+0020 ; aucun retrait de diacritique ; pas de NFKC, qui confondrait des distinctions typographiques et documentaires | la casse, les variantes d'espace |
| `cle_vote` | compter les voix sur un même couple (forme, concept) | la `cle_recherche` | la même chose ; une confusion qui changerait un vote est rapportée (INV-N2) |
| identifiant conceptuel | désigner un concept | l'identifiant de la ressource (§ 2.3), jamais une chaîne normalisée | rien |

- **Une collision est rapportée, pas fusionnée.** Deux formes d'origine différentes de même clé sont deux entrées, liées
  par leur clé commune (INV-N1).
- **Une forme suspecte est signalée, pas corrigée.** Un caractère de contrôle C1 (U+0080 à U+009F) dans une forme
  d'origine en est un exemple : c'est le cas des 16 entrées WOLF d'OMW où U+009C remplace « œ »
  (`docs/AUDIT_LANGAGES.md`, § 6.5). L'entrée garde sa forme d'origine et reçoit l'attribut `forme_suspecte`. Une
  correction éventuelle est une relation `proposée` vers la forme corrigée, avec sa raison (INV-N3).
- **La v1 du pilote divergeait** entre Python et Prolog sur « İ » : la mise en minuscules simple n'est pas le pliage
  complet. Le pliage complet est donc exigé, et un test le vérifie.

## 5. Les versions et le manifeste

- **La spécification** a une version, ici 0.1. Toute implémentation la cite.
- **Un K construit** a pour version l'empreinte de ses entrées : la version de la spécification, la version du
  constructeur, la liste des ressources avec leur version et l'empreinte de chaque fichier lu, la règle du statut
  effectif (§ 3.3), et le K nommé.
- **Le module compilé** porte cette version (`K:version/1`, `NOYAU.md`, § 2) et un manifeste qui l'énumère.
- **Un K nommé** (`NOTATION_REFERENCE.md`, § 5) est un ensemble de ressources, de statuts admis et de postulats de
  référence déclarés. K0-d30 en est un, historique : WordNet 3.0 et WOLF, tout en `proposée`.

## 6. Les invariants

Ce sont les contrôles de K3. Chaque violation nomme sa règle.

### 6.1 Ce que la reproduction du pilote a montré

La reproduction des problèmes du pilote a été faite le 28/11. Le rapport est
`/home/user/donnees/audit_langages/robustesse/RAPPORT.md`, avec ses reproductions et `rejouer_robustesse.sh`. Elle
montre que **le pilote prouve la faisabilité, pas la robustesse** : son accord à l'octet entre Python et Prolog tient à
ce que les données réelles ne contiennent ni virgule dans un lemme, ni doublon, ni séparateur dans un champ.

- **INV7 ne comparait jamais les versions,** seulement le nom de la ressource.
- **INV8 ne vérifiait pas l'exhaustivité d'un vote :** un vote supprimé ou amputé passait.
- **Les empreintes étaient recopiées du manifeste,** jamais calculées sur le fichier lu.
- **Les séparateurs n'étaient pas échappés.** Une virgule produit un faux positif. Une tabulation ou un retour à la
  ligne dans un littéral donne un K corrompu avec un code de sortie nul. U+0085, U+2028 et CRLF font diverger les deux
  langages. Un littéral vide plante d'un côté et crée une entrée vide de l'autre.
- **La provenance ne passait pas dans les faits compilés :** ni la ligne ou le nœud lu, ni l'identifiant d'origine, ni
  le sélecteur, ni les entrées d'un vote.
- **Une ligne d'arité fausse était ignorée en silence** côté Prolog.
- **Les données mal formées passaient.** Un XML tronqué ou un UTF-8 invalide ne donnait qu'un avertissement, et le
  résultat dépendait de la locale. Un fichier vide et une ressource sans entrée donnaient un code nul.
- **Les doublons divergeaient :** Python écrasait la dernière occurrence sans trace, Prolog gardait deux faits.
- **M01** (la source inexistante) : l'attendu écrit à la main donne INV1 et INV7 ; les deux implémentations donnent en
  plus INV8, parce que le vote qui cite l'entrée orpheline n'a plus de famille. La cascade dépendait des données. Ce
  résultat défavorable est **gardé** : l'attendu du pilote n'est pas modifié. La règle du § 6.2 fixe celui des
  implémentations futures.

### 6.2 Les violations primaires et dérivées

**Une violation est primaire ou dérivée.**
- **Elle est primaire** quand l'objet en cause viole l'invariant par lui-même.
- **Elle est dérivée** quand l'invariant ne peut pas être évalué, ou échoue, parce qu'un objet dont il dépend viole déjà
  un invariant. C'est le cas d'une entrée sans source déclarée, d'un alignement vers un pivot inconnu, ou d'un vote qui
  cite une entrée orpheline.

**Les violations dérivées sont toujours rapportées,** quelles que soient les données : un vote qui cite une entrée
orpheline viole INV-V1, qu'il cite ou non d'autres entrées de la même famille. Chacune nomme la violation primaire dont
elle dérive. On ne supprime aucune violation, et la cascade ne dépend jamais des données.

Pour M01, l'attendu d'une implémentation conforme à la version 0.1 est donc : INV-R1 primaire, puis INV-A1 et INV-V1
dérivées de celle-ci.

### 6.3 La sérialisation et la lecture

- **Le format d'échange de K** entre les opérations, et le module compilé, sont des **termes Prolog** écrits avec
  quotation (`writeq`, ou `format` avec `~q`) et relus par `read_term`. Aucun format à séparateurs textuels n'est
  canonique, ce qui ferme les ambiguïtés du rapport (§ 4 de celui-ci). Un export à séparateurs (TSV) pour la lecture
  humaine est permis. Il est dérivé, jamais relu comme source.
- **Chaque format d'entrée a un lecteur qui déclare son encodage et ses fins de ligne.** Le résultat ne dépend pas de la
  locale. U+0085, U+2028 et U+2029, à l'intérieur d'un champ, sont des caractères, pas des fins de ligne.
- **Un caractère de contrôle dans une forme d'origine** (C0 hors des fins de ligne du format, ou C1) la rend
  `forme_suspecte` (INV-N3). La forme est gardée telle quelle, échappée par la quotation.
- **Une forme d'origine vide, ou faite seulement d'espaces,** est une violation primaire (INV-E2). Elle n'est jamais une
  entrée vide.
- **Le constructeur relit ce qu'il a écrit.** Avant de livrer, il vérifie l'aller-retour : la relecture redonne les mêmes
  termes.
- **Les codes de sortie sont distincts :**

  | code | sens |
  |---|---|
  | 0 | succès, sans violation |
  | 1 | des violations d'invariants, rapportées |
  | 2 | une entrée illisible ou mal formée |
  | 3 | une erreur interne |

### 6.4 Les règles

| règle | énoncé |
|---|---|
| INV-R1 | toute entrée a une ressource déclarée, avec sa version, sa licence et sa famille |
| INV-R2 | l'empreinte enregistrée est celle du fichier **effectivement lu**, calculée à la lecture sur les octets lus ; une empreinte déclarée qui diffère est une violation |
| INV-R3 | une erreur de syntaxe ou de décodage est une erreur de lecture (code 2), jamais un avertissement |
| INV-ID1 | `id_origine` est non vide |
| INV-ID2 | deux entrées de même identité ont le même contenu |
| INV-ID3 | un doublon exact de la ressource est compté et rapporté, jamais fusionné en silence |
| INV-A1 | tout alignement cite sa méthode, la version de la ressource source et celle du pivot. Elles se comparent par **égalité exacte des chaînes** à celles des ressources déclarées : une version qui diffère d'un caractère est une violation |
| INV-A2 | la cible d'un alignement existe dans la version citée du pivot |
| INV-V1 | **un vote est un fait dérivé, qui se recalcule.** Pour chaque couple (clé de vote, concept), l'ensemble de ses entrées et de ses familles est recalculé à partir des entrées et des alignements. Le vote enregistré doit lui être égal : il doit exister, citer toutes ses entrées et toutes ses familles, et rien d'autre. Deux versions d'une même ressource forment une seule famille |
| INV-V2 | un vote ne donne jamais un statut autre que `proposée` |
| INV-Q1 | `attestée` et `rejetée` ont une source et une méthode de relecture nommées |
| INV-Q2 | aucune relation d'origine `postulat_reference` ne porte un statut de qualification |
| INV-J1 | l'historique des jugements est en ajout seul |
| INV-N1 | une collision de clés est rapportée |
| INV-N2 | une collision qui change un vote est rapportée avec le vote |
| INV-N3 | une forme suspecte est signalée et gardée |
| INV-C1 | tout fait compilé porte l'identifiant de sa provenance, que le manifeste résout jusqu'au fichier lu (avec son empreinte), à la ligne ou au nœud, et à l'`id_origine` ; un vote compilé cite ses entrées |
| INV-C2 | le lecteur du module compilé vérifie l'arité de chaque fait, et refuse un fait inattendu (code 2) |
| INV-C3 | aucun fait n'est compilé comme appui si son statut effectif ne le permet pas (§ 3.4) |
| INV-E1 | un ensemble attendu non vide qui est vide est une erreur. Les ensembles attendus sont déclarés par ressource : ses entrées, ses alignements, les lignes d'un fichier |
| INV-E2 | une forme d'origine vide ou faite seulement d'espaces est une violation primaire |
| INV-L1 | la licence de chaque ressource est vérifiée avant tout archivage public d'un fichier qui en dérive |

**Les tests d'une implémentation** reprennent les reproductions du rapport comme tests de non-régression, avec les
attendus de cette spécification.

## 7. Ce qui reste ouvert

1. ~~Les invariants du pilote~~ : traités au § 6 (28/11).
2. **La règle du statut effectif** (§ 3.3), et en particulier le traitement d'une relation contestée. C'est à confirmer
   par la propriétaire.
3. **La lecture du § 2.5** sur les postulats de référence, à confirmer par la propriétaire.
4. **Les périmètres :** leur vocabulaire (langue, domaine, contexte) reste à fixer sur les premiers cas réels.
5. **Le format concret du module compilé et de son manifeste.** Il suivra l'interface du noyau, et la mesure sur DBnary
   et l'AAT pour le traitement par flux.
6. **La couche de licence de K.** L'audit du 28/11 (`/home/user/donnees/audit_licences/RAPPORT.md`) a trouvé :
   - **Joconde :** le ministère et data.gouv.fr disent Licence ouverte Etalab, alors que 13 des 16 exports portent
     `dcterms:rights "CC-BY-SA"`. C'est un champ libre de l'outil d'export, sans version ni URL. La recommandation est de
     traiter ces 13 listes comme CC-BY-SA pour toute diffusion publique de données dérivées, et d'écrire au Service des
     musées de France ; la décision revient à la propriétaire ;
   - **WoNeF :** deux licences discordantes, CC BY-SA 3.0 FR et LGPL-LR. Elle est traitée comme CC BY-SA en attendant
     les auteurs ;
   - **DBnary :** CC BY-SA 4.0 ;
   - **l'AAT :** ODC-By 1.0 ;
   - **Iconclass :** CC0 ;
   - **WOLF :** CeCILL-C ;
   - **WordNet** et **VerbNet** : des licences permissives, avec une notice obligatoire.

   Un K compilé et diffusé hérite donc d'obligations de **partage à l'identique** dès qu'il contient des dérivés de
   DBnary, de WoNeF ou des listes Joconde (si CC-BY-SA s'applique). Le manifeste de K doit les porter (§ 5), et une
   diffusion publique les vérifie (INV-L1).
