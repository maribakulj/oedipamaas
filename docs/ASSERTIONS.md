# Le langage d'assertions, version 1 (provisoire)

Contrat central de la V1 (cahier des charges, § 5) : ce que la lecture d'un texte produit et ce que le raisonnement
consomme. Indépendant d'Iconclass. Les noms sont **provisoires** (décision D6, `DECISIONS.md`) jusqu'à la fin du J1.

## Forme

Les assertions d'un document sont une **liste de termes Prolog**, passée en argument : jamais de faits dynamiques
partagés (principe 5 : isolation par document). Le module `oedipamaas/socle/assertions.pl` les valide.

Chaque assertion a un **identifiant** (un atome) ; ses qualificatifs (polarité, modalité, portée, énonciateur) s'y
rattachent. Les identifiants d'assertion sont : `E` d'une entité, `V` d'un événement, `A` d'un nom, d'une propriété ou
d'une relation. Tous sont uniques dans le document.

## Termes

| Terme | Sens |
|---|---|
| `texte(T)` | le texte source (une chaîne) ; les positions s'y rapportent |
| `doc(Langue, Genre)` | `Langue` : `fr`, `en` ; `Genre` : `titre`, `cartel`, `notice`, `description`, `savant`, `inconnu` |
| `passage(P, Debut, Fin)` | un passage : positions en caractères, `0 ≤ Debut < Fin ≤ longueur(T)` |
| `entite(E, Tete, P)` | un référent (figure, animal, objet, lieu, inscription…) ; `Tete` : le lemme de sa tête (`lion`, `saint`) |
| `nom(A, E, Nom, P)` | un nom propre donné au référent `E` (`'Jérôme'`, `'Goliath'`) |
| `propriete(A, E, Prop, P)` | une propriété du référent `E` (`couronne`, `agenouille`, `rouge`) |
| `nombre(E, N)` | le nombre du référent quand il est dit (entier ≥ 1) |
| `evenement(V, Predicat, P)` | une action ou une situation (`tuer`, `tenir`, `prier`) |
| `role(V, Role, E)` | le rôle de `E` dans `V` : `agent`, `patient`, `theme`, `instrument`, `destinataire`, `lieu` ; actif et passif ramenés aux mêmes rôles |
| `relation(A, E1, Rel, E2, P)` | relation orientée : `E1` est le sujet, `E2` l'objet (`tient`, `regarde`, `a_cote_de`, `sur`) |
| `polarite(A, Pol)` | `pos` (affirmé) ou `neg` (nié) |
| `modalite(A, Mod)` | `affirme`, `probable`, `possible`, `traditionnel` (« traditionnellement identifié »), `ancien` (« autrefois attribué »), `non_affirme` (mentionné sans être affirmé : l'objet d'un verbe nié, « il ne regarde pas le livre »), `titre` (dit seulement par le titre de l'œuvre : un indice, jamais une preuve) |
| `portee(A, Por)` | `represente` (ce que l'image montre), `oeuvre` (l'objet : technique, état, support), `autre_oeuvre`, `source` (un texte, un récit), `histoire` (provenance, attribution), `non_ancre` (le texte ne rattache pas l'énoncé à l'image : biographie, style, commentaire ; défaut hors des descriptions visuelles, REFONTE F1) |
| `enonciateur(A, Qui)` | `auteur` (l'auteur du texte) ou `cite(X)` (une autorité citée) |
| `alternative(G, [A1, A2, …])` | hypothèses mutuellement exclusives (au moins deux) |
| `coref(E1, E2)` | deux entités désignent le même référent |
| `incompris(P, Raison)` | passage non interprété ; `Raison` : un atome (`analyse_incertaine`, `hors_couverture`…) |
| `saillance(E, principal)` | le référent `E` est donné par le texte pour le sujet de l'image : complément d'un pont (« depicts X », « Portrait de X »), ou dans la première phrase figurée de la description (ancrage version 2, `mondes.pl`) ; les autres référents figurés sont des composants |

Chaque identifiant d'assertion porte **exactement un** terme de chaque qualificatif : la lecture les écrit toujours,
il n'y a pas de valeur par défaut (une valeur implicite serait une décision cachée).

## Prémisse admissible

Une assertion `A` peut fonder un code **établi** si et seulement si :

- `polarite(A, pos)`, `modalite(A, affirme)`, `portee(A, represente)`, `enonciateur(A, auteur)` ;
- `A` n'appartient à aucune `alternative` ;
- pour un nom, une propriété ou une relation : chaque entité qu'elle concerne est elle-même admissible.

Une assertion `polarite(A, neg)` de portée `represente` peut **contredire** un candidat. Une **absence de mention** ne
contredit jamais rien. Les autres assertions ne servent qu'aux candidats.

## Validation

`assertions:valider(+Faits, -Erreurs)` rend la liste des erreurs (vide si tout va bien) :

- un seul `texte/1` et un seul `doc/2`, aux valeurs permises ;
- passages dans les bornes du texte, identifiants uniques ;
- toute référence (passage, entité, événement, assertion) existe ;
- chaque assertion a exactement un terme de chaque qualificatif, aux valeurs permises ;
- rôles et valeurs dans leurs domaines ; alternatives d'au moins deux assertions ; `coref` entre entités.

Une liste d'assertions invalide n'entre pas dans le raisonnement : le document reçoit une erreur structurée.
