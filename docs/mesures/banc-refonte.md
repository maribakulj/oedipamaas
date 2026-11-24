# Banc d'essai de la refonte (24 novembre 2026)

30 textes : 10 cartels du Cleveland Museum of Art (CC0), 10 textes de salle de l'Art Institute of Chicago (CC BY 4.0),
10 notices Joconde qui décrivent l'image. Référence établie à l'aveugle par un juge Opus : 97 éléments représentés,
80 codes Iconclass justifiés par la description (pas par le titre) ; 4 textes sans code (notices purement matérielles).
Mesure : `outils/mesure/banc.py` ; un code est « juste » s'il est un code de la référence ou l'un de ses ancêtres.

| Réglage | Codes établis | Exacts | Justes | Rappel |
|---|---|---|---|---|
| A. Moteur d'avant la refonte (ni ancrage ni sens) | 191 | 0,09 | 0,12 | 0,25 |
| B. Ancrage dans l'image (F1) | 42 | 0,17 | 0,21 | 0,11 |
| C. Ancrage et couche de sens (F1 + F2) | 30 | 0,17 | 0,20 | 0,09 |

**Critère du § 5 de `docs/REFONTE.md` (0,85 de précision) : non atteint, de loin.**

## Ce que montre le banc

1. **F1 (ancrage) fonctionne dans son rôle** : il divise par quatre le nombre de codes établis et double la précision,
   en écartant la biographie, le style, la provenance. Il coûte du rappel, en partie par erreurs d'UDPipe (« draws »
   étiqueté nom : la fille qui tire le rideau n'est plus ancrée) et par une propagation trop courte (« un diacre
   accompagné de saint Pierre » : saint Pierre n'hérite pas de l'ancrage).
2. **F2 (sens) écarte bien les mauvais sens** (« model », « life », « shift », « right ») mais ne règle pas le choix de
   la branche : la « tour » d'Avignon devient une tour d'église, les trois Grâces de Vénus deviennent les Grâces
   chrétiennes. Ce choix dépend du sujet de l'image, pas du mot.
3. **La référence code d'abord des sujets et des actions** : le Onzième Travail d'Hercule, Vénus au bain, les trois
   Grâces, saint Pierre, « il tient les pommes derrière le dos ». Un moteur qui part des mots n'y arrive pas, même
   quand il choisit bien ses mots : c'est F3 (le sujet d'abord), le fondement que le prototype n'a pas encore.

## État du code

Le prototype (F1 ancrage, F2 sens) est dans `interpretation.pl`, `sens.pl` et `raisonnement.pl`, actif seulement avec
`OEDIPAMAAS_REFONTE=1` ; sans ce réglage, le moteur se comporte comme avant et tous les tests passent. Défaut connu de
la règle des locutions : le partitif nié (« pas d'épée ») est pris pour une locution.
