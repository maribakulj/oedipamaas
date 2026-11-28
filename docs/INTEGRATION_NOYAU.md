# L'intégration du noyau dans la commande publique : la spécification (version 0.1, 28/11, proposition)

**La décision de la propriétaire (28/11).** La coexistence de deux raisonneurs actifs est un défaut architectural
prioritaire. Elle a fixé ce qui suit :
- la commande publique appelle le noyau actuel par `codage.pl`, avec ses mécanismes de vérification et de
  certification ;
- l'intégration se prépare sans modifier les fondements sémantiques, et sans prétendre que le noyau est qualifié pour
  la production ;
- les fonctions de `raisonnement.pl` encore légitimement réutilisées sont séparées de l'ancien algorithme ;
- l'ancien raisonneur reste comme baseline historique, derrière des commandes explicitement identifiées comme telles ;
- l'API publique est indépendante du langage : un protocole JSON/JSONL versionné. Un client Python facultatif peut
  l'appeler, sans logique métier ;
- les dépendances sont distinguées par catégorie.

**L'instruction :** l'analyse du 28/11, `/home/user/donnees/integration_noyau/ANALYSE.md`, avec ses mesures et ses
options E1 à E10. Ce document les tranche, sous réserve de la propriétaire. Aucune règle du noyau n'est modifiée.

## 1. Ce que l'analyse a établi

1. **La commande publique** (`swipl oedipamaas/socle/commande.pl`) passe par `raisonnement:coder`, l'algorithme T1/T2.
   Le noyau n'est appelé que par des outils et des tests.
2. **Le noyau dépend lui-même de `raisonnement.pl`,** par K : `cle_de_nom` appelle `raisonnement:normaliser_nom`.
   Charger `codage` charge donc l'ancien raisonneur.
3. **Trois fonctions de `raisonnement.pl` sont légitimement réutilisées :** `normaliser_nom` (16 appels, aucun test
   dédié), `tete_mot_cle` et `sens_de_lieu`. Le reste est T1/T2, et T6 est du code mort.
4. **`charger_base` paie environ 4 s de `raisonnement:preparer` et 1,6 s de `morphologie`,** dont ni le lecteur ni le
   noyau n'ont besoin. Quinze outils l'appellent.
5. **Le noyau ne rend aucun `etabli` aujourd'hui :** `familles_justifiees/1` n'est affirmé nulle part, et son meilleur
   statut est donc `etablissable`. Sa sortie est faite de termes Prolog, sans JSON de preuve.
6. **Des écarts de sens avec T1/T2 ont été mesurés sur dix textes inventés :**
   - `25F23(LION)` passe de « établi » à `conditionnel` ;
   - les négations ne laissent plus de trace ;
   - « Saint Jean » donne deux codes établissables ;
   - les candidats avec une cause disparaissent ;
   - 100 à 270 codes par texte ne tiennent qu'à leur condition nécessaire.
7. **Le coût :** une médiane d'environ 3 s par texte pour le noyau, contre environ 0 s pour T1/T2. Les cibles du cahier
   des charges (100 ms pour un titre, 2 s pour une page) ne sont pas atteintes.
8. **`pyproject.toml` décrit encore la version 0.2 :** `pip install` installe l'ancienne CLI Python. Stanza et `xlrd` n'y
   sont pas déclarés.
9. **Des défauts de la commande :**
   - un `id` manquant arrête tout le lot ;
   - les erreurs sont des chaînes sans code ;
   - une option inconnue lève une exception brute ;
   - le chemin de Stanza est codé en dur ;
   - `OEDIPAMAAS_REFONTE` change les sorties sans figurer dans `versions`.

## 2. Les étapes

**Étape 1 : séparer les fonctions réutilisées.** C'est une refactorisation sans changement de comportement.
- `normaliser_nom`, `tete_mot_cle` et `sens_de_lieu` passent dans un module neutre, `oedipamaas/socle/noms.pl`, que
  `raisonnement.pl`, K et le noyau importent.
- Le noyau et `codage.pl` ne chargent plus `raisonnement.pl`. Un test le vérifie sur la vraie chaîne de chargement, et
  pas seulement sur un K de test.
- `charger_base` sépare ce dont le lecteur et le noyau ont besoin de ce que seul T1/T2 demande (`preparer`).
- **Critère d'acceptation :** tous les tests existants passent sans modification, et les sorties de la commande sont
  identiques à l'octet près sur les textes de l'analyse. Des tests dédiés couvrent `normaliser_nom` : aujourd'hui, aucun.

**Étape 2 : la commande sur le noyau, et la baseline historique.**
- `commande.pl` appelle `codage.pl` et le noyau.
- L'ancien chemin reste disponible sous un nom explicite : `commande_historique_t1t2.pl`, ou une option
  `--raisonneur historique-t1t2`. Sa sortie porte `"raisonneur": "historique-t1t2"` et `"qualification": "baseline
  historique"`.
- Les deux chemins écrivent le protocole du § 3.

**Étape 3 : les dépendances et la distribution.**
- `pyproject.toml` ne décrit plus la commande comme un paquet Python. Le moteur est distribué comme moteur Prolog (§ 4).
- Les extras Python sont nommés par catégorie, et la version 0.2 est marquée historique.

## 3. Le protocole JSON/JSONL, version 1.0

**Le protocole est indépendant du langage.** Il est spécifié ici et vérifié par un validateur de schéma écrit en Prolog.
Un client, en Python ou dans un autre langage, ne fait que l'écrire et le lire.

**L'entrée :** une ligne JSON par document.

| champ | statut | contenu |
|---|---|---|
| `protocole` | facultatif | `"1.0"` |
| `id` | obligatoire | une chaîne ou un entier |
| `texte`, ou `titre` et `description` | au moins un | le texte |
| `langue` | facultatif | `"fr"` ou `"en"` |
| `genre` | facultatif | `titre`, `cartel`, `notice`, `description`, `savant` ou `inconnu` |
| `options` | facultatif | `{"budget": n, "delai_ms": n, "diagnostic": bool}` |

Une ligne fautive donne une ligne de sortie `erreur` pour ce document ; elle n'arrête pas le lot. **C'est E5 et le
défaut 9.**

**La sortie :** une ligne JSON par document, dans l'ordre de l'entrée.

```json
{"protocole": "1.0", "document": "…",
 "raisonneur": "noyau-0.3",
 "qualification": "noyau 0.3, non qualifié pour la production ; aucune famille justifiée",
 "versions": {"moteur": "…", "noyau": "…", "regles": "…", "base": "…", "k": "…", "analyseur": "…",
              "reglages": {"refonte": false, "genre_par_defaut": "inconnu", "surete": []}},
 "complet": true,
 "codes": [{"notation": "25F23(LION)", "statut": "conditionnel", "exploitable": false,
            "complet": true, "hypotheses": [{"nature": "…", "contenu": "…"}],
            "preuves": [{"referents": {"…": "…"}, "certification": "…", "terme": "…"}]}],
 "ecartes": [{"notation": "…", "portee": "substitution", "referents": {"…": "…"}, "fondements": ["…"]}],
 "diagnostic": {"sans_suffisante": ["…"]},
 "erreur": null}
```

**Les choix, avec l'option de l'analyse qu'ils retiennent :**

| | choix | raison |
|---|---|---|
| **E1** | (b) : **une liste unique `codes`,** dont le `statut` est celui du noyau, tel quel (`etabli`, `etablissable`, `candidat`, `conditionnel`…). Plus de liste `etablis` | on ne renomme aucun statut. L'option (d) est exclue : elle compterait `etablissable` comme établi et contredirait I3 (« établi ⇒ famille justifiée »). Le changement de forme est une version majeure du protocole |
| **E2** | (c) : **les réfutations dans `ecartes`,** avec leur portée (la substitution) et leurs fondements. Plus de `contredits` | le noyau n'a pas de statut « notation contredite » (D31). Une réfutation pour des référents ne réfute pas la notation (L6) |
| **E3** | `conditionnel` est émis avec `"exploitable": false` | rien n'est caché, et le drapeau porte la consigne « ne pas exploiter automatiquement » |
| **E4** | `sans_suffisante` ne figure que dans `diagnostic`, et seulement si l'option le demande | ce ne sont pas des candidats |
| **E5** | `complet` par document et par code. Un budget et un délai explicites ; leurs valeurs par défaut sont dans `versions.reglages`. Un document interrompu n'est jamais présenté comme complet | PLAN C10 |
| **E6** | un élément par notation, avec la liste de ses preuves par référents. La réduction aux codes les plus précis est une présentation à part, absente de la version 1.0 | I11 |
| **E7** | la raison d'un non-établissement n'est pas restituée en 1.0 | la recalculer serait une logique hors du noyau, et étendre le noyau sort du périmètre. **C'est une perte mesurée par rapport à T1/T2,** à documenter |
| **E8** | les corrections propres à T1/T2 (lieu, récit biblique, titre de saint, ordres) ne sont pas reprises | elles relèvent de la compilation des requêtes ou de K. Les écarts sont mesurés contre la baseline (§ 5) |
| **E9** | le champ `qualification` est obligatoire | le noyau n'est pas qualifié pour la production |
| **E10** | `versions.reglages` porte tout réglage qui change la sortie, dont `OEDIPAMAAS_REFONTE`. Le chemin de Stanza devient une option ou une variable documentée, jamais une valeur codée en dur | la reproductibilité |

**Le protocole est versionné en semver.** Un champ ajouté fait monter la version mineure ; un changement de forme ou de
sens, la version majeure. La version 1.0 est la première ; l'ancienne sortie n'avait pas de version.

## 4. Les dépendances par catégorie

| catégorie | dépendances | qui en a besoin |
|---|---|---|
| exécution du noyau et de la commande | SWI-Prolog 11 et la base compilée (Iconclass, WordNet, K) | le moteur seul |
| lecture linguistique | UDPipe 1 (binaire) et ses modèles ; facultativement Stanza (processus Python externe) | la commande, par la frontière CoNLL-U |
| compilation des connaissances | SWI-Prolog ; les scripts Python de compilation existants, jusqu'à leur remplacement par K (`ARCHITECTURE_LANGAGES.md`, § 5) | la construction de la base |
| vérification indépendante | Python 3, pytest | l'oracle et l'interpréteur de référence |
| expérimentation et mesure | Python 3 ; `xlrd` tant qu'il sert | les outils de `outils/` |
| historique, version 0.2 | `numpy`, `sentence-transformers`, Janus | figé |

## 5. La vérification

- **Étape 1 :** les sorties de la commande sont identiques à l'octet près avant et après. Les tests existants passent
  sans modification.
- **Étape 2 :**
  - le validateur de schéma accepte toutes les sorties, et refuse des sorties mutées ;
  - les tests de bout en bout couvrent les deux raisonneurs ;
  - la baseline historique produit exactement l'ancienne sortie, enveloppée dans le protocole ;
  - un test texte → noyau tourne sur la vraie base, dans un job de CI qui la construit ou la télécharge, ou en local s'il
    ne le peut pas. Aucun test de ce genre n'existe aujourd'hui.
- **Les écarts entre les deux raisonneurs** sont mesurés sur les textes de développement, jamais sur les données de
  qualification. Ils sont publiés sans être corrigés dans les règles du noyau.
- **Une revue Opus ciblée,** puisque la modification touche la commande et la certification exposée.

## 6. Ce qui reste à la propriétaire

- **E1 et E2 :** la forme du protocole, et en particulier l'abandon des listes `etablis` et `contredits`.
- **E7 :** accepter, en version 1.0, la perte de la raison d'un non-établissement.
- **Le coût :** une médiane de 3 s par texte, au-dessus des cibles du cahier des charges. C'est un sujet de performance
  du noyau, distinct de cette intégration.
