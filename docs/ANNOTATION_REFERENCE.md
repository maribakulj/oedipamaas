# Le guide de l'annotation sémantique de référence (version 1, 28/11)

**Ce qu'on juge :** le **statut sémantique de référence**, le niveau (a) de `docs/INTERPRETATIONS_ADMISSIBLES.md`, § 2.
La question est : la description satisfait-elle la définition, pour un lecteur compétent qui lit la notice dans son
contexte ?

**Ce qu'on ne juge pas :**
- ce que WordNet, WOLF ou un dictionnaire permettent de démontrer ;
- ce que le moteur ferait.

Ces deux niveaux, (b) et (c), sont mesurés ailleurs. L'annotateur ne les voit pas et ne les cherche pas.

**Les décisions de la propriétaire (28/11) qui s'appliquent :**
- la supervaluation porte sur les interprétations **contextuellement admissibles**, non sur tous les sens d'un
  dictionnaire ;
- une définition peut être établie sous certaines interprétations et écartée sous d'autres : on garde **les deux**
  (option B, le profil complet) ;
- une scène figurée dans un tableau figuré, une vision ou un récit peut satisfaire une définition **dans son propre
  contexte**, avec son chemin ;
- le silence du texte n'est jamais une preuve négative.

## 1. Ce que l'annotateur sait et ce qu'il ne sait pas

**Ce qu'il sait :** la signification ordinaire des mots et des constructions, du français et de l'anglais, et les
postulats de signification. Ce sont les inclusions et les incompatibilités analytiques qu'un locuteur compétent connaît :
- une petite fille est un enfant ;
- un roi est un souverain ;
- mort et vivant s'excluent pour un même être au même moment.

C'est K\* (`docs/INTERPRETATIONS_ADMISSIBLES.md`, § 2.2).

**Ce qui n'est pas un postulat de signification, et reste une hypothèse s'il sert :**
- **une connaissance typique :** un homme tonsuré est d'ordinaire un moine ;
- **une identification iconographique :** une femme à la roue est d'ordinaire sainte Catherine ;
- **une explication :** des flèches font penser à saint Sébastien ;
- **une identité non dite :** un personnage est le même que l'autre.

Chacune garde sa nature dans le profil (§ 3).

**Ce qu'il ne fait pas :**
- consulter un dictionnaire ou une ressource lexicale ;
- lire les fichiers de cas complets, les révisions ou les relectures ;
- chercher ce que d'autres ont jugé.

## 2. Les points d'ambiguïté

**Un point d'ambiguïté** est un endroit où **le texte, lu en contexte**, laisse vraiment plusieurs interprétations à un
lecteur compétent. C'est là, et seulement là, que la référence se divise. Ce n'est pas une polysémie du dictionnaire que
le contexte écarte.

**Le cas ordinaire.** Le « cavalier » d'un vitrail qui « donne son manteau à un mendiant » n'est pas une pièce
d'échecs. Ce n'est pas un point.

**Les onze dimensions**, celles du § 3.1 de l'étude :

| dimension | exemple |
|---|---|
| `sens` | un mot dont deux sens restent possibles dans ce contexte |
| `sens_relation` | le « de » de partie ou de possession |
| `structure` | le rattachement d'un participe ou d'une relative |
| `coreference` | « il » avec deux antécédents possibles |
| `portee` | d'une négation ou d'un « peut-être » |
| `pluriel` | « deux anges la couronnent » : ensemble, ou chacun |
| `cadre_de_reference` | « à droite » : de la figure, ou du spectateur |
| `ancrage` | en cours, accompli, imminent |
| `contexte` | une assertion figurée, ou dite d'une source, ou dans une vision |
| `identite` | deux figures pour un même personnage |
| `forme_du_libelle` | « e.g. » ; « instruments » au pluriel |

**La définition a ses propres points.** On les cherche comme pour la description (décision du 28/11, § 3).

**Pour chaque point,** on donne :
- un identifiant ;
- la dimension ;
- sur quoi il porte, en citant le texte ;
- les valeurs admissibles.

## 3. Le profil

**Une classe** est une combinaison de valeurs des points. Les classes qui donnent le même résultat se regroupent. Pour
chaque classe, on donne :

**`valeur`** : la valeur de Belnap de la définition dans cette interprétation, sur ce que l'auteur affirme du figuré :
- `V` : satisfaite ;
- `F` : réfutée ;
- `B` : les deux, c'est-à-dire une **contradiction interne** à l'interprétation. Ce n'est pas une divergence entre deux
  interprétations ;
- `N` : ni l'un ni l'autre.

**Ce qui fonde un `F`, et seulement cela :**
- un appui négatif dit (une négation de l'auteur) ;
- une incompatibilité analytique avec ce qui est dit ;
- une quantification dite (« seul », « aucun ») ;
- une contrainte du texte.

Jamais l'absence d'une mention.

**`contexte`** :
- `principal` : la figuration de l'œuvre ;
- un chemin : par exemple `principal > vision de saint Jean` ou `principal > tableau figuré au mur`.

Un contexte qui n'est pas de figuration ne satisfait rien. C'est le cas de l'histoire de l'œuvre, d'une attribution,
d'une source qui raconte et non qui décrit l'image, ou d'un titre seul.

**`enonciateur`** :
- `auteur` ;
- `cite` : la valeur ne vient que d'une source citée (« selon X »).

**`hypotheses`** : ce qu'il faut supposer, en plus du choix de lecture, pour que la valeur tienne. Chacune garde sa
`nature`, qui ne se mélange jamais avec les autres :
- `connaissance_typique` ;
- `abduction` ;
- `identite` ;
- `identification_iconographique` ;
- `convention` : une convention d'évaluation non tranchée, par exemple que l'imminent compte comme en cours.

Chaque hypothèse a aussi son `contenu`.

**Le choix de lecture** est la classe elle-même. Ce n'est pas une hypothèse de la liste.

**L'ensemble vide.** Si aucune interprétation n'est admissible (une description incohérente), on l'écrit
(`"profil": []`, avec une remarque). Rien n'est alors certifié.

## 4. Le statut synthétique

Il **résume** le profil. Il **ne le remplace pas** (décision du 28/11, § 1).

**Ce tableau suit la définition 10 de `docs/INTERPRETATIONS_ADMISSIBLES.md` (version 1.1, § 3.5), qui fait foi ; ses lignes s'excluent : une classe `B` jointe à des classes `V` (ou `F`) sans classe du signe opposé donne `etablie_sous_hypotheses` (ou `ecartee_sous_hypotheses`), la classe `B` restant au profil ; `contradictoire` et `non_certifiee` ne valent qu'en l'absence de toute classe `V` ou `F` d'énonciateur `auteur`.**

| le profil | le statut synthétique |
|---|---|
| toutes les classes `V`, sans hypothèse, énonciateur auteur | `etablie` |
| toutes les classes `F`, sans hypothèse | `ecartee` |
| au moins une classe `V`, aucune `F` ; ou des `V` sous hypothèses | `etablie_sous_hypotheses` |
| au moins une classe `F`, aucune `V` ; ou des `F` sous hypothèses | `ecartee_sous_hypotheses` |
| des classes `V` et des classes `F` | `divergent`, le profil gardant les deux |
| une classe `B` | `contradictoire` (avec les autres classes dans le profil) |
| les valeurs ne viennent que d'un énonciateur cité | `non_certifiee` |
| toutes les classes `N` | `inconnue` |
| profil vide | `aucune_interpretation` |

**Aucune priorité n'est donnée au positif :** un profil divergent n'est ni « établi sous hypothèses » ni « inconnu ».

**Le contexte d'une solution** apparaît dans le profil, non dans le statut synthétique. Une définition satisfaite dans
une vision est `etablie` avec le contexte `principal > vision…`. Retenir la notation pour l'œuvre est une décision
documentaire à part, qu'on ne prend pas ici.

## 5. Les variantes

- **Chaque variante est jugée pour elle-même,** avec la même définition, sans regarder le jugement du cas de base avant
  d'avoir fait le sien.
- **Une traduction fidèle a le même profil que son cas.** Si une traduction n'est pas fidèle, on l'écrit
  (`"traduction_infidele": true`, avec la raison). On ne change pas son jugement pour qu'il ressemble.
- **Un doute** s'écrit (`"doute": "…"`). On ne le lisse pas.

## 6. La forme de la sortie

Un fichier JSON par famille et par annotateur : une liste, un objet par cas.

```json
{"id": "ee-002",
 "points": [{"id": "p1", "dimension": "ancrage", "porte_sur": "« donne »", "valeurs": ["en_cours", "accompli"]}],
 "profil": [{"classe": {"p1": "en_cours"}, "valeur": "V", "contexte": "principal", "enonciateur": "auteur",
             "hypotheses": []},
            {"classe": {"p1": "accompli"}, "valeur": "V", "contexte": "principal", "enonciateur": "auteur",
             "hypotheses": []}],
 "statut_synthetique": "etablie",
 "justification": "…",
 "doute": null,
 "variantes": [{"n": 0, "points": [], "profil": [], "statut_synthetique": "…", "justification": "…",
                "doute": null, "traduction_infidele": false}]}
```

La justification est courte : ce qui fonde chaque valeur, et pourquoi les autres lectures sont exclues par le contexte.

## 7. Les précisions pour l'adjudication (version 1.1, 28/11)

Les annotateurs ont rencontré trois lacunes du guide. Ils les ont réglées chacun à sa façon. L'adjudication applique les
règles ci-dessous à toutes les familles, sans changer les jugements initiaux, qui sont gardés.

**1. Un contexte n'est pas une lecture.** Un résultat qui diffère selon le contexte n'est pas une divergence entre
interprétations. Par exemple, une scène réfutée pour l'œuvre telle qu'elle est aujourd'hui, mais satisfaite dans son
état d'origine, ou satisfaite dans une vision et non dans la scène principale.
- **Le statut synthétique se lit sur le contexte principal :** la figuration de l'œuvre telle que la notice la décrit.
- **Les autres contextes** donnent chacun leur résultat, dans `satisfactions_contextuelles` : le chemin, le statut, la
  classe. Une vision, un tableau figuré ou un récit en font partie, de même que l'état d'origine d'une œuvre altérée,
  sous le chemin `principal > état d'origine`.
- **Seule une divergence entre lectures donne `divergent`.** Une différence entre contextes n'en donne jamais.
- **Retenir une notation** pour l'œuvre à partir d'un contexte emboîté reste une décision documentaire, que l'annotation
  ne prend pas.

**2. Une convention n'est pas une lecture.** Quand le résultat dépend d'une convention d'évaluation non tranchée, on
garde deux choses distinctes :
- le point d'ancrage, pour ce que le texte laisse ouvert : par exemple la phase préparatoire contre l'imminence ;
- l'hypothèse de nature `convention`, pour ce que la sémantique n'a pas fixé : par exemple que l'imminent compte comme
  en cours.

`docs/ONTOLOGIE_EVENTUALITES.md`, § 1.2 range la phase préparatoire dans l'en cours.

**3. Une alternative de l'auteur n'est pas une ambiguïté.** « Soit Persée, soit David » est une disjonction dite.
- Elle se traite par cas, chaque branche gardant sa nature ; ce n'est pas un point d'ambiguïté.
- Si la définition est vraie dans toutes les branches, la valeur est `V`.
- Si elle n'est vraie que dans certaines, la valeur est `N`, et les branches sont rapportées.

**Les champs ajoutés par des annotateurs** (`nature_variante`, `raison_infidelite`, deux lignes de preuve pour une même
classe) sont gardés. `traduction_infidele` ne vaut que pour une traduction. Une reformulation dans la même langue qui
change le sens se signale par `paraphrase_infidele`.
