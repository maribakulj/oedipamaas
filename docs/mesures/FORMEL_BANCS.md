# Les représentations formelles des cas de base, contre la référence adjugée (28/11)

**Ce qui est mesuré :** le statut que l'interpréteur de référence (`semantique_reference/`) calcule sur une
représentation formelle de chaque cas de base, au niveau (a), comparé au statut de référence adjugé par la double
annotation. Les deux jugements sont indépendants :
- **les représentations** sont écrites par trois rédacteurs, chacun avec trois familles et son propre dossier de
  brouillon. Ils n'ont vu ni la référence adjugée, ni les annotations, ni K0-d30, ni le moteur, ni ses sorties ;
- **la référence** a été adjugée avant que les représentations soient écrites.

Aucun des deux n'a été réécrit d'après la comparaison. Un écart n'est donc pas une erreur d'un côté : c'est un désaccord
à examiner, ou une limite du langage, de K\* ou de l'interpréteur.

**Les fichiers :**
- les représentations : `/home/user/donnees/bancs_phase1/v3/formel/<famille>.json` (syntaxe concrète nr-1) ;
- la comparaison : `formel_comparaison/formel.json` et `formel.md`, écrits par
  `python3 outils/bancs/comparer_formel.py …/v3/formel …/v3/reference …/v3/formel_comparaison`.

**Le calcul :** l'outil relit chaque représentation et la recalcule ; il ne prend pas le statut écrit par le rédacteur.
Il applique la règle par contexte (`docs/ANNOTATION_REFERENCE.md`, § 7.1) et compare sur les deux axes de la déf. 11,
comptés à part. Quatre cas viennent des dossiers d'exemples : ee-002 par renvoi ; mn-004, rq-010 et pi-003 recopiés sans les champs
de la référence. Le cas de base co-018 n'est pas fait, son exemple ne portant que la variante n = 3.

## 1. Les comptes

216 cas de base. 197 représentés, 18 non représentés, 1 non fait. Aucune représentation n'a de défaut de formation.

| famille | représentés | non représentés | égal à (a) | (formel) plus fort | (formel) plus faible |
|---|---|---|---|---|---|
| compositionnalite | 19 | 4 | 10 | 3 | 7 |
| definitions_classification | 23 | 1 | 19 | 2 | 3 |
| espace_partie_temps | 16 | 8 | 12 | 3 | 2 |
| evenements_etats | 22 | 2 | 15 | 0 | 7 |
| modalite_negation_contextes | 24 | 0 | 22 | 1 | 1 |
| niveaux_representation | 23 | 1 | 23 | 0 | 0 |
| phenomenes_iconographiques | 24 | 0 | 23 | 0 | 1 |
| reference_quantification | 23 | 1 | 23 | 0 | 0 |
| structures_argumentales | 23 | 1 | 21 | 0 | 2 |
| **total** | **197** | **18** | **168** | **9** | **23** |

Trois cas sont plus faibles sur un axe et plus forts sur l'autre (co-024, dc-005, ep-008). Ils sont comptés dans les
deux colonnes.

**Les contextes.** Les 7 cas que la référence établit dans un seul contexte emboîté le sont aussi dans la représentation,
au même chemin : la vision (dc-003, nr-021), le décor scénique (dc-018), la tapisserie (ee-023), le rêve
(mn-022), l'état d'origine (nr-012), la copie peinte (pi-007). Seul co-014 diffère (§ 2.4).

## 2. Les écarts, par cause

### 2.1 Une réfutation « pour ces référents » (8 cas, tous plus forts sur l'axe négatif)

co-004, co-024, dc-005, dc-020, ep-006, ep-008, ep-012, mn-006.

L'interpréteur suit la lettre de la déf. 10 : une réfutation certifiée pour une substitution donne `ecartee`, même
quand elle lie une variable à un référent que la condition suffisante ne retient pas. C'est le point L6 de
`docs/LANGAGE_REFERENCE.md` (§ 3.12), signalé aussi par les trois rédacteurs. **Aucune de ces réfutations n'est
fermée.** Exemple (mn-006) : D nie qu'Abraham sacrifie Isaac ; Δ demande un sacrifice d'un bélier. La réfutation porte
sur σ = {R ↦ Isaac}, et rien n'est dit d'un bélier sacrifié. La référence juge `inconnue`, et le rédacteur aussi.

**C'est l'argument le plus net en faveur d'une décision sur L6 :** n'écarter que par une réfutation fermée, ou par une
réfutation qui porte sur tous les candidats de la condition suffisante. Les 8 écarts tiennent à cette seule règle.

### 2.2 Des postulats de signification sans attestation extérieure (11 cas, plus faibles)

co-015, co-016, co-021, co-023, dc-016, ee-017, ee-018, ee-020, pi-001, sa-024 et, en partie, ee-011.

Les rédacteurs n'ont compté un postulat de K\* comme attesté que si WordNet 3.0 le donne : une hyperonymie, ou une glose
citée. Les autres (« tenir ⇒ avec », « frotter de ⊑ oindre », une incompatibilité de deux états) ont le statut non
attesté, et ne fondent qu'une hypothèse `connaissance_non_attestee` (L7). Les annotateurs, eux, les tenaient pour des
postulats que connaît un locuteur compétent (guide, § 1).

**L'écart ne porte pas sur le sens. Il porte sur ce qui atteste K\*.** C'est la question du § 5 de la décision du
28/11 : un K\* formel a besoin d'une source pour chaque postulat, et WordNet n'en fournit qu'une partie. Ces 11 cas
donnent la liste des postulats à attester ou à valider :
- par une ressource ;
- par la propriétaire ;
- ou en les déclarant postulats de travail de la sémantique de référence.

Ce n'est pas une campagne de corrections : c'est le relevé, cas par cas, de ce qui manque.

Un cas voisin, mn-015, est sous connaissance typique (« sur une échelle ⇒ debout »). La référence l'établit sans
hypothèse. Le langage n'a pas de forme typique à prémisse relationnelle.

### 2.3 Une identification ou une abduction que le rédacteur n'a pas posée (5 cas, plus faibles)

co-002, ee-004, ee-012, ee-013 et sa-014 sont `inconnue` dans la représentation et `etablie_sous_hypotheses` dans la
référence. Les annotateurs ont posé une hypothèse que le rédacteur a refusée, par exemple Orion pour ee-004, ou Emmaüs
pour ee-013. C'est le seuil de l'identification et de l'abduction, déjà une dépendance nommée de l'adjudication
(`BANCS_PHASE1.md`, § 9.5).

Sur la forme, l'écart est sans danger : un statut sous hypothèses contre `inconnue`. Il reste une question ouverte.

### 2.4 Des limites du langage ou de l'interpréteur

- **co-014 :** la statue d'ange veille sur une tombe du contexte principal. Un contexte emboîté ne voit pas les faits de
  ses ancêtres, et la tombe n'y est pas. Le contexte de la statue reste `inconnue`, là où la référence l'établit.
  - Les trois rédacteurs ont rencontré cette limite.
  - Dans nr-012 et sa-020, ils l'ont contournée en réécrivant les faits dans le contexte, sans effet sur le résultat.
- **dc-014 :** la roue de Catherine et le titulus « S. BARBARA ». La représentation porte une classe vraie sous une
  identification iconographique, et fausse sous une connaissance typique incompatible.
  - L'interpréteur rend `etablie_sous_hypotheses` : le statut local prend E_H dès qu'une certification positive existe,
    et la réfutation certifiée sous l'autre hypothèse reste dans les lignes sans entrer dans le statut. La déf. 10 n'a
    pas de ligne pour ce cas.
  - **C'est une priorité au positif, que la décision du 28/11 interdit.** La référence est `divergent`.
  - L'interpréteur n'est pas corrigé ici : il faut d'abord écrire la règle (le point L22 ci-dessous).
- **ep-007 :** un point de cadre de référence est écrit de chaque côté, donc le statut est `etablie_sous_hypotheses`.
  La référence fixe le cadre par le contexte.
- **ee-011 :** la référence est `divergent`, la représentation `etablie_sous_hypotheses`. Le rédacteur a ancré la chute
  en cours, et il l'a noté comme douteux.

### 2.5 Un écart de lecture

co-011 est `etablie` dans la représentation et `etablie_sous_hypotheses` dans la référence. Le rédacteur lit sans
hypothèse le dragon mort comme celui que le tueur a tué (une anaphore associative) ; les annotateurs en font une
hypothèse. C'est le seul écart plus fort sur l'axe positif.

## 3. Les cas non représentés : ce qui manque

18 cas. Pour chacun, le rédacteur a écrit la construction, l'extrait, ce qu'il faudrait, et pourquoi on ne peut pas
l'omettre (`formel/<famille>.json`, champ `manque`).

| construction manquante | cas |
|---|---|
| partie et tout : le tout qu'implique une partie, l'action ou la propriété d'une partie transférée au tout, l'objet porté et la main | ep-001, ep-002, ep-014, ep-016 |
| un modificateur non intersectif (« ancien », « former », « prétendu ») | co-008, co-009, co-010 |
| la relation de but vers une éventualité non affirmée | ep-019, ep-021 |
| la précédence entre éventualités, au-delà de `succede` et de l'ancrage | ep-017, ep-018 |
| la convention de l'imminent, comme hypothèse de nature `convention` | ee-008, ee-009 |
| l'unicité d'une destination, d'un cadre ou d'une place, et l'incompatibilité de deux lieux | sa-004, co-012, dc-021 |
| les membres d'une collection non énumérée et la distributivité | rq-009 |
| le nom d'une scène qui donne ses participants ; la relation d'une copie à son modèle | nr-002 |

**La convention de l'imminent ne s'exprime pas** par une assertion supposée de nature `convention`. RS 6 tire de
l'ancrage imminent, affirmé sans hypothèse, la négation de l'en cours, et cette négation est certifiée. La forme est à
écrire, et la décision 26 reste à prendre.

## 4. Les défauts et les lacunes du langage, relevés en écrivant les cas

Ils s'ajoutent aux points L1 à L21 de `docs/LANGAGE_REFERENCE.md`, § 3.12. Rien n'est corrigé ici.

- **L22, une réfutation sous une autre hypothèse disparaît du statut** (dc-014, § 2.4). Il faut une ligne de la déf. 10,
  ou un statut local, pour une classe vraie sous H1 et fausse sous H2 incomparables.
  **Résolu provisoirement le 28/11** par le statut local ER_H (`docs/LANGAGE_REFERENCE.md`, § 3.7, L22), à confirmer
  par la propriétaire. Les représentations n'ont pas été recalculées dans ce document.
- **L23, un contexte n'hérite d'aucun fait de son parent** (co-014, nr-012, sa-020). Il faut une règle de ce qui passe
  d'un contexte à un contexte emboîté : ce qui subsiste dans l'état d'origine, ou un référent du principal nommé dans
  une statue.
- **L24, une incompatibilité indexée par le moment demande `dans(?E, ?T)` dans la définition** (ee-017, ee-020,
  sa-020, sa-022). Sans cet atome, la réfutation ne rejoint pas une définition qui ne nomme aucune situation.
- **L25, une règle de K ne crée pas de référent** (ee-018, nr-002, la partie et le tout). Un état résultant conclu
  s'écrit comme une propriété.
- **L26, une connaissance typique à prémisse relationnelle ne s'écrit pas** (mn-015).
- **L27, la négation d'une quantification énoncée n'a pas de forme** (rq-023, « pas seulement ») ; **la portée d'une
  quantification ne peut pas introduire d'état réifié** (rq-024).
- **L28, un alias non attesté n'a aucun effet.** Il devrait fonder une hypothèse `connaissance_non_attestee` (rq-017).
- **L29, K n'a pas d'espèce d'entrée pour déclarer un concept de travail avec sa glose.** Les rédacteurs l'ont mise
  hors de ce que lit `lire_cas`.
- **L30, `distinct` ne se déduit pas de deux types incompatibles** (pi-021, main droite et main gauche).
- **L31, deux constructions sans contrôle de formation.** Un contexte emboîté ouvert par un individu (un tableau, une
  tapisserie) est accepté, mais rien ne le spécifie. Il n'existe pas de sorte de contexte pour l'œuvre d'un modèle ou
  d'un carton.
- **L32, la personnification et l'appartenance à une collection** sont écrites sans sémantique propre (`oc:personnifie`,
  `oc:membre_de`). C'est sans effet ici, puisque la description et la définition les écrivent de même.

## 5. Les cas douteux

Chaque rédacteur a écrit ses doutes dans les `remarques` du cas, une dizaine par groupe. Deux points sont à relever :
- **rq-016, rq-017, rq-023 :** le rédacteur a marqué attestés des postulats appuyés sur son seul jugement, contrairement
  à la consigne. Tenu pour non attesté, rq-016 deviendrait `etablie_sous_hypotheses`.
- **nr-018 :** « old man » est lu comme nom lexicalisé, ce qui permet l'incompatibilité avec « youth ». L'étude range
  ce cas parmi les adjectifs de degré ; avec « old » écrit comme propriété, le statut serait `inconnue`.

## 6. Ce que cela dit, et ce que cela ne dit pas

- **168 cas sur 197 ont le même statut, et le même contexte, que la référence adjugée.** C'est une concordance entre
  deux jugements faits par des agents d'un même modèle. Ce n'est pas une validation humaine (D23).
- **Les écarts se concentrent sur trois règles :**
  - la portée d'une réfutation (L6, 8 cas) ;
  - l'attestation des postulats de K\* (11 cas) ;
  - le seuil d'une identification ou d'une abduction (5 cas).

  Ces règles demandent une décision, non une correction des cas.
- **Les variantes ne sont pas encore représentées.** L'invariance de traduction et les relations métamorphiques se
  mesureront sur elles.
