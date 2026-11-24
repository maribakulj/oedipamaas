# Refonte du raisonnement (24 novembre 2026)

Statut : proposition, à mettre à l'épreuve sur un banc d'essai (§ 5) avant tout développement en grand. Elle remplace
les rustines proposées après le jugement J2 (`docs/mesures/J2-descriptions.md`), qui n'ont pas été appliquées.

## 1. Pourquoi refondre

Sur des descriptions, la précision des codes établis est de 0,24 (T1) et 0,30 (T2). Chaque tour de jugement fait
apparaître une nouvelle famille d'erreurs (« Paris », « en bas », « niche », « Claude ») ; chaque correction ajoute une
liste d'exclusions. Cela ne converge pas : la cause n'est pas dans les cas, elle est dans la méthode.

Ce qui reste valable : l'architecture (texte → analyse → assertions → Prolog → codes avec preuves vérifiables), le
langage d'assertions, UDPipe et le CoNLL-U, la base Iconclass compilée, la commande sans Python, les tests. Ce qui
change : ce que le moteur raisonne.

## 2. Les quatre fondements

### F1. L'ancrage dans l'image remplace la présomption de représentation

Aujourd'hui, tout nom est présumé représenté, puis on retire ce qui ne l'est pas. Désormais **rien n'est représenté
sans ancrage** : une assertion n'a la portée `represente` que si le texte la rattache à l'image.

| Source | Ancrage |
|---|---|
| Sortie d'Opus (description visuelle) | donné par construction : le descripteur décrit ce qu'il voit ; ses entités sont ancrées |
| Cartel, notice, catalogue, article | à lire : un énoncé est ancré s'il est le complément d'un verbe ou d'une tournure de représentation (« représente », « on voit », « figure », « montre », *depicts*, *shows*, *we see*), s'il est placé dans l'image (« au premier plan », « à gauche », « au centre », *in the foreground*), ou s'il est le participant d'une action ou d'une posture d'une figure ancrée (« saint Jérôme, agenouillé, tient une pierre »), ou relié à une entité ancrée (« un lion à ses pieds »), ou coréférent d'une entité ancrée |

Tout le reste (biographie, style, provenance, technique, annotations, comparaisons, datations, locutions) a la
portée `non_ancre` : il n'établit rien, sans qu'il faille l'énumérer. Le défaut se renverse : la liste qu'on maintient
est celle, courte et générale, des marques de représentation, et non celle, infinie, des cas où l'on ne représente pas.

### F2. Une couche de sens : des concepts, pas des chaînes

Aujourd'hui, T2 cherche le mot du texte dans le libellé d'une notation. Désormais la correspondance passe par des
**sens** :

1. **Aligner Iconclass sur les sens, une fois, hors ligne.** Pour une notation dont le libellé définit un mot
   (« beasts of prey: lion »), on retient le sens de ce mot (synset WordNet) qui s'accorde avec la place de la
   notation dans l'arbre : sous « animals », le sens animal de *lion* ; sous « parts of a church », le sens
   architectural de *niche*. Une notation sans sens accordé ne peut pas être établie par T2. L'alignement se mesure à
   part (précision sur un échantillon).
2. **Choisir le sens du mot dans le texte**, parmi les seuls sens alignés sur Iconclass, par le contexte : les autres
   entités ancrées et leurs sens, la scène, la phrase. Plusieurs sens restent possibles : on s'abstient.
3. **En français**, le même chemin par un wordnet français relié à WordNet (Open Multilingual Wordnet / WOLF ;
   licence à vérifier), ou à défaut par les libellés français d'Iconclass alignés sur les libellés anglais de la même
   notation.

« Niche » d'une stèle, « tronc » d'arbre, « bas » d'une feuille, « Paris » la ville cessent d'être des correspondances
de chaînes et deviennent des sens qui ne s'accordent pas.

### F3. Le sujet d'abord, ses composants ensuite

Un catalogueur identifie d'abord le **sujet** (quel épisode, quelle personne, quelle allégorie, quel genre), puis code
ce qui compte dans la scène. Le moteur fera de même :

1. **La scène** : à partir des seules assertions ancrées, les participants, leurs actions, leurs attributs, le lieu.
2. **Les hypothèses de sujet** : personnes (nom et titre, ou attributs), épisodes (participants, action, objets
   attendus, tirés des libellés et des sources d'Iconclass), allégories, genres (portrait, paysage, nature morte).
   Chaque hypothèse est jugée par abduction : ce qu'elle explique des éléments ancrés, ce qu'elle attend et qui manque,
   ce qui la contredit.
3. **Les codes** : le sujet établi s'il est seul en tête et que ses conditions sont remplies ; puis les composants
   ancrés et pertinents (les participants, les objets décrits), pas chaque nom du texte.

Le titre (D15) entre ici comme indice : il peut renforcer une hypothèse de sujet que la description soutient déjà.

### F4. Un périmètre de V1 redéfini autour des sujets

Le découpage par types de preuve T1 à T6 certifiait d'abord ce qui semblait facile (noms, choses) et repoussait ce
qui fait la valeur d'Iconclass (épisodes, saints par leurs attributs, allégories). Nouveau découpage proposé :

| Preuve | Ce qu'elle établit | Conditions |
|---|---|---|
| S1 personne nommée et ancrée | un saint, un personnage biblique ou mythologique nommé avec son titre, ancré dans l'image | nom et titre, ancrage, pas d'homonyme de lieu ou d'autre personne |
| S2 chose ancrée | un objet, un animal, une plante, une figure ancrés, au sens désambiguïsé (F2) | ancrage, sens unique parmi les sens alignés |
| S3 épisode | un épisode reconnu par ses participants et son action | participants et action ancrés, conditions différentielles par rapport aux épisodes voisins |
| S4 genre | portrait, paysage, nature morte, scène de genre | la scène ancrée, dans son ensemble |
| S5 repli | l'ancêtre commun de lectures concurrentes | lectures toutes ancrées, liste complète par construction (F2) |

L'identification par les attributs seuls (Jérôme par le lion et le crâne, sans le nom) reste candidate en V1.

## 3. Ce que cela change dans le code

| Pièce | Changement |
|---|---|
| `interpretation.pl` | marques d'ancrage et propagation (F1) ; portée `non_ancre` par défaut hors des sorties d'Opus |
| langage d'assertions | valeur de portée `non_ancre` ; pour Opus, un adaptateur qui écrit des entités ancrées |
| nouveau `sens.pl` | alignement Iconclass → sens (compilé), choix du sens en contexte (F2) |
| nouveau `scene.pl` | scène, hypothèses de sujet, abduction (F3) |
| `raisonnement.pl` | preuves S1 à S5 au lieu de T1 à T6 ; T1 et T2 actuels deviennent des générateurs de candidats |
| tests | les paires minimales restent ; de nouvelles paires d'ancrage (« on voit un lion » / « le peintre aimait les lions ») |

## 4. Les corpus

Le moteur se mesure sur ce qu'il doit lire (D15) :

| Corpus | Langue | Nature | Licence |
|---|---|---|---|
| sorties d'Opus | EN | descriptions visuelles, la première cible | à fournir par la propriétaire du projet |
| Cleveland Museum of Art | EN | textes de cartels | CC0 |
| Art Institute of Chicago | EN | textes de salle | CC BY 4.0 |
| Wikipédia, sections « Description » | FR, EN | prose descriptive, avec les codes Iconclass de Wikidata | CC BY-SA 4.0 |
| Joconde, descriptions de l'image | FR | notices | Licence Ouverte |

## 5. Le banc d'essai, avant de construire

1. **30 descriptions** : 10 cartels (Cleveland, Chicago), 10 articles Wikipédia (5 FR, 5 EN), 10 notices Joconde ou
   sorties d'Opus.
2. **Une référence** pour chacune, établie à l'aveugle par le juge (modèle Opus, choix de la propriétaire) : les codes
   que la description permet d'établir, et pour chaque nom du texte s'il est ancré dans l'image.
3. **Un prototype** de F1, F2 et F3, petit, sur ces 30 textes seulement.
4. **La mesure** : précision et rappel des codes établis contre la référence, précision de l'ancrage, précision de
   l'alignement des sens.
5. **Le critère** : on construit en grand si la précision des codes établis atteint 0,85 sur le banc, avec un rappel
   qui ne soit pas négligeable (au moins 0,30). Sinon, on revoit la méthode à ce moment-là, sur preuves.

## 6. Risques

- **Choisir le sens d'un mot par des règles** est le cœur difficile du traitement de la langue : on n'y atteindra une
  haute précision qu'en s'abstenant souvent.
- **L'ancrage dans les cartels** : beaucoup de cartels décrivent sans marque explicite (« Saint Jérôme, agenouillé dans
  le désert… ») ; la propagation par les postures et les actions doit couvrir ces cas, à mesurer.
- **Le français** : la ressource lexicale (wordnet français) et sa licence restent à établir.
- **La reconnaissance des épisodes** demande les sources d'Iconclass (participants, actions attendus), que la base ne
  compile pas encore.
