# Protocole de qualification humaine (25 novembre 2026)

Décision de la propriétaire (25/11) : le développement ne s'arrête pas sur l'annotation humaine. Les données de
développement et de validation sont produites par des agents (`docs/PLAN_V1.md`, C6) ; la qualification finale (M3) a
en plus un échantillon jugé par deux annotateurs humains, selon le protocole ci-dessous, dont la mise en œuvre sera
décidée plus tard.

## 1. Ce qui est jugé

Un échantillon **stratifié** de descriptions réelles (notices, cartels, descriptions visuelles d'Opus, textes
savants ; français et anglais), tiré de l'ensemble de qualification finale, jamais vu pendant le développement :

| Strate | Part de l'échantillon |
|---|---|
| langue (fr, en) | moitié chacune |
| genre du texte (notice, cartel, description visuelle, texte savant) | au moins 15 % chacun |
| catégories de C10 (objets, animaux et plantes, vêtements et anatomie, propriétés, relations, identités, épisodes, allégories) | au moins 30 couples (notation, référent) par catégorie |

Taille visée : environ 60 textes, de quoi juger au moins 300 couples (notation, référent) établis et 300 omissions
possibles.

## 2. Ce que fait un annotateur

À l'aveugle (il ne sait pas quel moteur, ni quelle version, a produit quoi), et indépendamment de l'autre :

1. **Les codes établis** : pour chaque couple (notation, référent) que le moteur établit, et pour un nombre égal de
   couples tirés de la ligne de base et mêlés aux premiers, « le texte le justifie », « ne le justifie pas », ou
   « ne sait pas » (la notation est obscure, le texte ambigu).
2. **Les omissions** : pour chaque texte, la liste des couples (notation, référent) que le texte justifie, de la
   façon la plus précise qu'Iconclass permet, à partir du texte seul (outil de recherche dans Iconclass fourni, pas
   les sorties du moteur).
3. **Les preuves** : pour un tiers des codes établis, la preuve montrée, « elle justifie le code » ou non.

Le guide d'annotation dit ce que « justifié par le texte » veut dire (ce que le texte met dans l'image, pas ce que
l'annotateur sait de l'œuvre ; un titre n'est pas une preuve : D15 ; une notation et ses ancêtres documentaires ne
sont pas la même réponse) et donne des exemples tirés des ensembles de développement, jamais de la qualification.

## 3. L'accord et les mesures

- **Accord entre annotateurs** : alpha de Krippendorff (nominal) sur les jugements des codes établis, par catégorie ;
  pour les omissions, accord sur les couples (F1 d'un annotateur contre l'autre). Un alpha inférieur à 0,67 sur une
  catégorie la rend non qualifiable : on revoit le guide sur une autre partie de l'échantillon, jamais sur celle-ci.
- **Arbitrage** : les désaccords sont tranchés par discussion des deux annotateurs ; la référence arbitrée est la
  vérité de la qualification ; l'accord avant arbitrage est publié.
- **Les mesures** de C10 (précision exacte, rappel exact et hiérarchique, couverture des référents et des relations,
  taux d'abstention, justesse des preuves), avec des intervalles par rééchantillonnage des documents.
- **Les agents contre les humains** : les mêmes textes sont annotés par l'agent annotateur des données de
  développement ; l'accord agent / humains est publié, pour savoir ce que valent les mesures faites sur les données
  d'agents.

## 4. Ce qui reste à décider

Qui sont les deux annotateurs (compétence en histoire de l'art et en Iconclass), le temps demandé (de l'ordre de
deux à trois jours chacun pour 60 textes), et l'outil d'annotation.
