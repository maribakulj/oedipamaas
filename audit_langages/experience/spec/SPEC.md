# Spécification de la transformation de l'expérience (écrite avant les implémentations)

Elle est neutre vis-à-vis du langage : les deux implémentations (Python, Prolog) en dérivent, et la version Clojure
décrite au rapport en dériverait aussi. Le vocabulaire est celui de `docs/LANGAGE_REFERENCE.md` § 1.10 (statuts
`attestee` / `non_attestee`) et de `docs/MESURE_RESSOURCES_LEXICALES.md` § 11.2 (le fait fédéré, le vote, la famille).

## Entrées (l'échantillon, produit par `commun/extraire_echantillon.py`)

- `wolf.tab` : lignes `DECALAGE-POS<TAB>fra:lemma<TAB>lemme` de WOLF dans OMW 1.4 (WordNet 3.0 comme pivot).
- `wonef.xml` : éléments `<SYNSET>` de WoNeF 0.1, version F-score (identifiant `eng-30-DECALAGE-POS`, POS `b` = adverbe ;
  littéraux `<LITERAL lnote="sélecteur">lemme</LITERAL>`, `_EMPTY_` = pas de lexicalisation).
- `wn30_ids.txt` : les identifiants `DECALAGE-POS` de WordNet 3.0 (`s` rendu par `a`, comme OMW) : le pivot.
- `MANIFESTE.json` : empreintes SHA-256 des fichiers d'origine (portées dans les sources de K).

## Sorties : la base K, format canonique `k.tsv` (UTF-8, lignes triées par type puis identifiant, séparateur TAB)

```
S  id  ressource  version  sha256  couche_licence  famille
A  id  de_ressource  de_version  de_id  vers_ressource  vers_version  vers_id  methode  statut  attestation
E  id  genre  lemme  synset  source  localisateur  nature  detail  statut  attestation  couche_licence
V  id  lemme  synset  rang  familles  entrees  statut
```
Les champs absents sont vides. `familles` et `entrees` : listes séparées par `,` triées.

- **S** (source) : une ressource, sa version, l'empreinte du fichier lu, la couche de licence, la famille de vote.
  Trois sources : `src:wolf`, `src:wonef-f`, `src:wn30`.
- **A** (alignement) : l'identifiant d'un concept d'une ressource vers l'identifiant du pivot WordNet 3.0, avec les
  versions des deux bouts. Un par (ressource, synset) rencontré. WOLF : identité de décalage ; WoNeF : `eng-30-X-p` vers
  `X-p`, `b` vers `r`.
- **E** (entrée) : une lexicalisation `(lemme français, synset WordNet 3.0)` proposée par une ressource. `localisateur` :
  le numéro de ligne (WOLF) ou l'identifiant `eng-30-…` (WoNeF) ; `nature` = `alignement_automatique` ; `detail` = `wolf-omw`
  ou le sélecteur WoNeF (`lnote`, `sans_note` s'il manque). Statut `non_attestee`. Un littéral `_EMPTY_` ne crée aucune
  entrée : une absence vaut `inconnu`, jamais une exclusion.
- **V** (vote) : pour chaque couple (lemme normalisé : NFC, pliage de casse complet d'Unicode, NFC ; synset) proposé par au moins une famille : les
  familles qui le proposent, leur nombre (`rang`), les entrées qui le soutiennent. Le vote **classe** : il n'est jamais
  `attestee`.

## Les invariants (chacun a un code ; le contrôle rend les couples `CODE<TAB>identifiant`, triés, sans doublon)

| code | invariant |
|---|---|
| `INV1_SOURCE` | toute entrée E renvoie à une source S qui existe et dont ressource, version et empreinte sont non vides |
| `INV2_ALIGN_VERSION` | tout alignement A a ses deux ressources et ses deux versions non vides |
| `INV3_PIVOT` | tout alignement A vise `WordNet` `3.0` et un identifiant qui existe dans `wn30_ids.txt` |
| `INV4_VOTE_CLASSE` | tout vote V est `non_attestee` : il classe, il n'atteste pas |
| `INV5_ATTESTATION` | le statut d'une entrée ou d'un alignement est `attestee` ou `non_attestee` ; un `attestee` porte une attestation, un `non_attestee` n'en porte pas |
| `INV6_UNICITE` | les identifiants sont uniques dans chaque type |
| `INV7_ENTREE_ALIGNEE` | toute entrée E a un alignement A de sa source vers le pivot pour son synset |
| `INV8_VOTE` | `rang` = nombre de familles distinctes des sources des entrées ; les entrées citées existent et portent le couple du vote ; `familles` = familles de ces entrées |
| `INV9_LICENCE` | la couche de licence d'une entrée est celle de sa source |

## Compilation vers des faits Prolog (`k_faits.pl`, module `k_federe`)

Refusée (erreur, code de sortie non nul, aucun fichier) si le contrôle rend une violation. Sinon, chaînes en `"…"`, tri
par identifiant :
```
k_source(Id, Ressource, Version, Sha256, Couche, Famille).
k_sens(Categorie, Mot, TypeEntier, EntreeId, Statut).     % Categorie n|v|a|r ; TypeEntier = préfixe*100000000 + décalage
k_vote(Mot, TypeEntier, Rang, Familles).                  % Familles : liste de chaînes
```
Le préfixe est celui de `oedipamaas/socle/compiler_ressources.py` : n=1, v=2, a=3, r=4. `k_sens/5` est `K:sens/3` avec la
provenance (entrée) et le statut en plus.

**Révision de la spécification (v2).** La v1 disait « NFC et minuscules ». L'exécution sur les données complètes a montré
que les deux langages ne mettent pas « İstanbul » (U+0130) en minuscules de la même façon (Python : correspondance
complète d'Unicode, deux caractères ; SWI-Prolog `string_lower/2` : correspondance simple, un caractère). La v2 précise la
normalisation (pliage de casse complet) ; la divergence de la v1 est gardée dans `resultats/v1_divergence/`.

## Mutants (invariants contrôlés par injection)

`commun/fabriquer_mutants.py` écrit, à partir d'un `k.tsv` sain, des bases à un seul défaut chacune, avec le code attendu.
Le contrôle de chaque langage doit rendre exactement le couple attendu sur chaque mutant, et rien sur la base saine.
