# Plan F3 : le sujet d'abord (24 novembre 2026)

Décision de la propriétaire : voie 1 (symbolique pur, sans LLM à l'exécution), « bien, sans bricolage ». Ce plan
précise la méthode, les étapes, la mesure de chacune et les pièges à éviter. Il prolonge `docs/REFONTE.md` (F3) et
s'appuie sur ce que le banc d'essai a montré (`docs/mesures/banc-refonte.md`).

## 1. Le problème, posé exactement

Entrée : la **scène** d'une description, c'est-à-dire ses assertions ancrées dans l'image (F1) — des participants
(avec leur nom, leur titre, leur type), leurs actions et rôles, leurs attributs, les objets, le lieu.

Sortie : le ou les **sujets** de l'image dans Iconclass (un épisode, une personne, une allégorie, un genre), établis
ou seulement candidats, puis les **composants** codés dans le contexte de ce sujet.

La connaissance : Iconclass seul (libellés, mots clés, hiérarchie, gabarits), compilé par programme, et WordNet pour
les sens (F2). Rien d'iconographique n'est écrit à la main.

## 2. La méthode

**Un sujet d'Iconclass a un profil.** Chaque notation de sujet (récits bibliques et mythologiques, vies de saints,
allégories, genres) se décrit par ce que son libellé, ses mots clés et ses ancêtres disent qu'on y voit :

| Élément du profil | Tiré de | Exemple (94L332, « Hercules … the apples of the Hesperides ») |
|---|---|---|
| personnes | les noms du libellé et des gabarits ancêtres | Hercules (ancêtre 94L), Hesperides |
| actions | les verbes du libellé | steal |
| objets, êtres | les noms du libellé et les mots clés, par leurs sens (F2) | apple, tree, nymph, dragon |
| lieu | les noms de lieu du libellé | garden |

**Reconnaître un sujet, c'est expliquer la scène** (abduction), avec trois règles explicites, sans poids réglés à la
main :

1. **Génération** : seuls sont envisagés les sujets dont le profil partage avec la scène au moins un élément
   discriminant (une personne nommée, ou un élément rare dans Iconclass ; la rareté se calcule sur Iconclass).
2. **Condition nécessaire** : un sujet qui appartient à l'histoire d'une personne (sous un gabarit de personne, ou
   dont le libellé la nomme) exige que cette personne soit dans la scène, identifiée (nommée avec son titre, F1, D16).
3. **Condition différentielle** : un sujet n'est établi que si la scène contient ce qui le distingue de ses sœurs dans
   l'arbre (l'action ou l'objet propre à l'épisode, au sens F2) et qu'aucune autre hypothèse ne l'explique aussi bien ;
   sinon on se replie sur le parent commun qui, lui, est expliqué (l'histoire de la personne).

**La preuve d'un sujet** est la liste de ses appuis (élément du profil, passage du texte, sens) et la condition
différentielle satisfaite, revérifiable comme les autres preuves.

**Les composants** sont codés ensuite, dans le contexte du sujet : parmi les notations possibles d'un élément ancré, on
garde celles de la branche du sujet (les Grâces sous la mythologie quand le sujet est Vénus ; la tour profane quand le
sujet est un paysage).

## 3. Les étapes, et leur mesure

Chaque étape a une mesure qui lui est propre ; on ne passe à la suivante que si elle est faite. Les mesures portent sur
le **banc de développement** (les 30 textes actuels). Un **banc de qualification** de 40 textes nouveaux, à référence
établie à l'aveugle, est constitué dès l'étape 0 et **scellé** : on ne le regarde qu'une fois, à la fin.

| Étape | Ce qu'on construit | Ce qu'on mesure |
|---|---|---|
| 0. Le cadre | le banc de qualification (40 textes, référence à l'aveugle, scellée) ; les métriques : précision et rappel du sujet, des composants, de l'ancrage | — |
| 1. L'inventaire des sujets | les profils compilés de toutes les notations de sujet (`sujets.pl`), avec un index par élément | couverture (part des notations de sujet qui ont au moins deux éléments) ; justesse de 40 profils tirés au hasard, jugée à l'aveugle |
| 2. La scène | l'assemblage de la scène depuis les assertions ancrées : participants et identités, actions, objets, lieu | rappel et précision des éléments représentés contre les 97 éléments de la référence ; part des pertes dues à l'analyseur |
| 3. Les hypothèses de sujet | génération, conditions nécessaire et différentielle, décision (établi, candidat, repli), preuve | précision et rappel du sujet contre la référence ; part des erreurs par cause |
| 4. Les composants | codage des éléments ancrés dans le contexte du sujet | précision et rappel des codes de composants |
| 5. La qualification | une seule mesure sur le banc scellé | précision des codes établis, sujet et composants |

**Critère de réussite** (fixé maintenant, pas après coup) : sur le banc de qualification, précision des sujets établis
≥ 0,85 et précision de l'ensemble des codes établis ≥ 0,85, avec un rappel des sujets ≥ 0,30. Sinon, on s'arrête et on
rend compte de ce qui manque, sans abaisser le seuil.

## 4. Les pièges, et ce qu'on fait à la place

| Piège | Pourquoi c'est un piège | Ce qu'on fait |
|---|---|---|
| Corriger cas par cas les erreurs du banc | c'est le bricolage qui ne converge pas | toute correction est une règle générale, justifiée par une famille d'erreurs (au moins trois cas, sur plusieurs textes), et retestée sur les paires minimales |
| Régler le moteur sur les 30 textes | on mesurerait sa mémoire du banc, pas sa justesse | banc de qualification scellé, regardé une seule fois |
| Écrire de l'iconographie à la main (« Jérôme = lion + crâne ») | contraire au principe du projet, et sans fin | profils compilés d'Iconclass ; une lacune d'Iconclass reste une lacune, mesurée |
| Des poids et des seuils ajustés jusqu'à ce que « ça passe » | opaque, fragile, non explicable | règles de décision qualitatives (nécessaire, différentielle) ; la seule quantité, la rareté, se calcule sur Iconclass |
| Parcourir les 40 000 notations pour chaque texte | explosion combinatoire | index inversé par élément ; seules les hypothèses partageant un élément discriminant |
| Prendre les mots clés pour des conditions | les mots clés mêlent attributs, symboles, contextes | ils sont des appuis, jamais des conditions nécessaires |
| Se servir du titre pour établir le sujet | D15 | le titre ne fait que renforcer une hypothèse déjà soutenue par la description, et le compte rendu le dit |
| Contourner chaque erreur d'UDPipe | une rustine par erreur de l'analyseur | mesurer la part des pertes dues à l'analyseur (étape 2) ; si elle domine, changer d'analyseur par la frontière CoNLL-U, pas de rustines |
| Le français par les mots | pas de wordnet français : les mots français ne sont pas des sens | le français passe par les mots clés et libellés français d'Iconclass de la même notation ; sa couverture est mesurée à part |
| Élargir le périmètre en cours de route (OWL, Wikidata, nouvelles sources) | dispersion | rien de nouveau tant que l'étape 5 n'est pas faite |
| Un juge de la même famille de modèles que l'auteur | angles morts partagés | référence établie à l'aveugle ; la propriétaire peut contrôler un échantillon dans une page de jugement |

## 5. Ce qui n'est pas dans ce plan

L'identification d'une personne par ses seuls attributs (sans son nom) reste candidate ; les allégories reconnues par
leurs attributs aussi. Les clés (+…), les lettres doublées, les noms libres ne bougent pas. Le chemin des sorties
d'Opus (voie 2) n'est pas exclu : il pourra être mesuré avec le même cadre quand les données seront disponibles.

## 6. Corrections du plan en cours de route

- **Étape 1, périmètre des sujets** (24 novembre) : l'inventaire avait d'abord été restreint aux divisions 1, 7 et 9
  (religion, Bible, mythologie). Or 16 des 21 sujets de la référence du banc de développement sont ailleurs (paysages
  25H/25I, portraits 61B2(…), natures mortes 34B, scènes de genre 41D, figures 31D). Le profil est donc compilé pour
  toutes les notations ; une notation à nom a un profil sans son nom.
- **Étape 1, lecture des libellés** : la catégorie que donne l'étiqueteur n'est pas utilisée (les libellés sont
  télégraphiques, et la correspondance passe par les sens) ; les noms propres se reconnaissent à la majuscule, que
  Iconclass réserve aux noms ; les mots pleins par exclusion des classes fermées. Taux d'erreur de catégorie fermée
  de l'étiqueteur sur les libellés : 0,9 % (en), 0,4 % (fr), sur 2 000 libellés.
- **Étape 2, ancrage** : la version 1 (rien sans ancrage explicite) perdait la moitié des éléments ; la version 2 (les
  deux mondes, `mondes.pl` : ponts, temps, œuvre et producteurs, cadres de l'image) les retrouve, au prix d'une scène
  bruitée ; la saillance (ce que le texte donne pour le sujet) s'y ajoute comme assertion `saillance/2`.
- **Étape 3, conditions** : la condition nécessaire exige toutes les personnes du libellé propre (hors parenthèses et
  lieux), l'élément distinctif doit être discriminant et saillant, la meilleure explication écarte les hypothèses
  qu'une autre branche explique strictement mieux. Mesures et diagnostic : `docs/mesures/F3.md`.
- **Lacune du plan** : les personnes historiques nommées (S1, 61B2(NOM)) et les genres (S4) ne sont pas outillés ;
  ils font 15 des 20 sujets du banc de développement.
