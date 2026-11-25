# Le noyau logique : requêtes, satisfaction, preuves (M0, version 0.2, 26 novembre 2026)

**Version 0.2** (qualification formelle, 26/11) : la négation descend la hiérarchie par la seule inclusion ;
l'identité est en monde ouvert (trois régimes de distinction) ; la valeur d'une formule (Belnap) est séparée de sa
certification ; l'admissibilité reprend le contrat des assertions ; un budget de calcul ; un vérificateur qui
n'accepte qu'après avoir tout établi.

**Indépendance.** Le noyau ne connaît ni Iconclass ni WordNet : ni notation, ni arbre, ni libellé, ni ressource de
langue n'y entre. Ce qui est propre à Iconclass relève des connaissances (le module K), des définitions (les requêtes
qu'un compilateur tire des libellés) et des règles de composition (gabarits, clés, lettres doublées : C8) ; le seul
prédicat sur l'œuvre, `genre(T)`, est générique (il vaut pour toute classification d'œuvres). Un test le vérifie :
charger le noyau ne charge aucun de ces modules.

Ce document est la partie formelle de FONDEMENTS v3 (`docs/PLAN_V1.md`, C1 et C2) : le langage des requêtes, leur
satisfaction sur le graphe d'un texte, la forme des preuves et ce que le vérificateur contrôle. Le code suit ce texte :
`oedipamaas/socle/requetes.pl` (forme des requêtes), `satisfaction.pl` (le moteur), `verificateur.pl` (le
vérificateur, écrit à part). Les tests (`tests/plunit/test_noyau.pl`) ne portent que sur des graphes et des requêtes
écrits à la main : aucune erreur de langue ne peut y masquer une erreur de logique.

## 1. Le graphe d'un texte

Les assertions de `docs/ASSERTIONS.md` : `entite/3`, `nom/4`, `propriete/4`, `evenement/3`, `role/3`,
`relation/5`, `coref/2`, `distinct/2`, `nombre/2`, `polarite/2`, `modalite/2`, `portee/2`, `enonciateur/2`,
`alternative/2`, `passage/3`. Le graphe est validé (`assertions:valider/2`) avant toute évaluation ; un graphe invalide
donne une erreur structurée, jamais un résultat.

- **Les référents** sont les classes de coréférence établie (`coref/2`, fermeture réflexive, symétrique,
  transitive) ; le représentant d'une classe est son plus petit identifiant. Un nom, un type, une propriété d'un membre
  valent pour la classe. La coréférence possible n'est pas dans le graphe (C9).
- **Deux classes différentes ne sont pas, par là, deux individus.** Leur identité est inconnue, sauf
  - **distinction établie par le texte** : `distinct(E1, E2)` entre un membre de chacune (« un autre homme ») ;
  - **distinction documentaire** : des noms des deux classes que K donne pour deux individus, avec la source
    (`K:distincts_documentes(Cle1, Cle2, Source)`) ;
  - **distinction supposée** : les deux classes portent des noms propres, tous différents, sans alias connu ni
    distinction contraire ; c'est une **hypothèse révisable**, jamais une prémisse d'une preuve déductive (§ 4.4).
  Un nombre (« deux hommes ») dit une cardinalité ; il ne dit pas que deux mentions particulières sont deux de ces
  hommes.
- **L'état d'un appui**, pour une condition qui demande le contexte C (`represente` pour la figuration, `oeuvre` pour
  le classement) :
  - `pos(Q)` : polarité positive, modalité « affirmé », portée C, hors de toute alternative, et chaque référent dont
    l'assertion parle (l'entité d'un nom ou d'une propriété, les deux entités d'une relation, l'entité d'un rôle) a une
    entité positive, affirmée, de portée C, hors de toute alternative ; Q est l'énonciateur ;
  - `neg(Q)` : polarité négative, modalité « affirmé », portée C, hors de toute alternative, et chaque référent dont
    elle parle, autre qu'elle-même, a une entité positive comme ci-dessus (« le lion n'est pas mort » parle d'un lion
    qui est là) ;
  - aucun état sinon (une hypothèse, un titre, une alternative, un autre contexte) : l'assertion n'appuie rien, dans
    un sens ni dans l'autre.
  Un rôle a l'état de son événement, et demande l'entité de son participant positive. Positifs et négatifs portent leur
  énonciateur : un désaccord entre sources est gardé, avec ses sources (§ 4.3).

## 2. Les connaissances

Le moteur ne connaît aucun mot : il interroge un module de connaissances K.

| Primitive | Sens |
|---|---|
| `K:sens(Categorie, Mot, Type)` | un mot (catégorie `n`, `v`, `a`, `r`) désigne ce type ; un mot peut en désigner plusieurs |
| `K:sous(Type, Parent)` | un pas vers un type plus général : hyperonymie, instance, ou lexicalisation (d'un sens vers son lemme) |
| `K:inclus(Type, Parent)` | un pas d'**inclusion sémantique** seulement (hyperonymie, instance) : jamais une lexicalisation, une classe documentaire ou une association |
| `K:cle_de_nom(Nom, Cle)` | la forme normalisée d'un nom propre |
| `K:alias(Cle1, Cle2)` | deux noms d'un même individu, établi |
| `K:distincts_documentes(Cle1, Cle2, Source)` | deux noms de deux individus différents, selon une source |
| `K:version(V)` | la version des connaissances |

Un **lien positif** est un chemin simple `chemin(Mot, [T0, …, Tn])` : `K:sens(Cat, Mot, T0)`, `K:sous(Ti, Ti+1)`,
Tn le type demandé (un mot du texte va vers un type plus général : un lion est un félin). Un **lien négatif** va dans
l'autre sens et par la seule inclusion : `chemin_inclus(Type, [S0, …, Sn], Mot)` avec `K:sens(Cat, Type, S0)`,
`K:inclus(Si, Si+1)`, `K:sens(Cat, Mot, Sn)` (nier un type plus général nie les plus spécifiques : « pas de félin »
nie « lion » ; « pas de lion » ne nie pas « félin »). Les chemins sont simples : la hiérarchie peut avoir des cycles.

## 3. Le langage des requêtes

Une requête est `requete(Id, Formule)`. Les variables s'écrivent `v(Nom)`. Une formule :

```
F ::= et([F, …]) | ou([F, …]) | Atome | Contrainte
Atome ::= type(X, T)            le référent X a un type égal ou plus spécifique que T
        | nom(X, [Cle, …])      X porte l'un de ces noms (ou un alias établi)
        | propriete(X, P)       X a la propriété P (ou plus spécifique)
        | evenement(E, P)       E est un événement de prédicat P (ou plus spécifique)
        | role(E, R, X)         X a le rôle R dans E (agent, patient, theme, instrument, destinataire, lieu)
        | relation(X, R, Y)     une relation orientée R de X vers Y (ou plus spécifique)
        | genre(T)              l'œuvre est de genre T (ou plus spécifique) : un prédicat de l'œuvre, sans variable
Contrainte ::= meme(X, Y) | distincts(X, Y) | nombre(X, K)
```

- Toutes les variables sont **existentielles**, de portée la requête entière ; une variable de deux branches d'un
  `ou` est la même variable.
- **Aucune distinction implicite** : deux variables peuvent tomber sur le même référent, sauf `distincts(X, Y)` ; elles
  tombent sur le même référent si `meme(X, Y)`.
- **Une contrainte ne lie aucune variable** : ses variables doivent l'être par des atomes de la même sélection (un
  `distincts(X, Y)` dont Y n'apparaît que dans l'autre branche d'un `ou` n'est pas satisfait par cette branche).
- `nombre(X, K)` : le texte dit que X est au nombre de K (`nombre/2`).
- Une requête est **bien formée** si chaque variable apparaît dans au moins un atome (pas seulement dans une
  contrainte), si un `ou` a au moins deux branches et un `et` au moins une, si la sorte de chaque variable est unique
  (référent ou événement : premier argument de `evenement` et de `role`), si, dans chaque sélection qui contient une
  contrainte, ses variables sont celles d'atomes de la même sélection, et si aucune contrainte n'est `distincts(X, X)`
  (qu'aucune substitution ne peut satisfaire).

**Le fragment.** Ce sont des formules existentielles positives (∃, ∧, ∨) à atomes typés, avec égalité et
différence, évaluées sur un graphe fini : l'équivalent d'unions de requêtes conjonctives. Il n'y a pas de négation
dans une requête, et aucune négation par échec dans une preuve. L'évaluation termine : le graphe est fini, la requête
aussi, et un lien est un chemin simple dans la hiérarchie de K (qui peut avoir des cycles : celle des verbes de WordNet en a). Son coût est celui d'un homomorphisme de graphes, exponentiel dans le
nombre de variables seulement ; le moteur lie d'abord les atomes les plus sélectifs (§ 4).

## 4. La satisfaction

### 4.1 Les valeurs des atomes et des contraintes

Une **substitution** σ lie des variables (pas forcément toutes) à des référents (représentants de classe) ou à des
événements. Sous σ, un atome dont une variable n'est pas liée vaut **inconnu**. Sinon il a des appuis positifs
(liens positifs, état `pos`) et négatifs (liens négatifs, état `neg`), et sa valeur est la paire (positif, négatif)
de Belnap : (0,0) inconnu, (1,0) vrai, (0,1) faux, (1,1) contradictoire.

| Contrainte, variables liées | vrai (1,0) | faux (0,1) | inconnu (0,0) |
|---|---|---|---|
| `meme(X, Y)` | même classe | classes dont la distinction est établie ou documentaire | sinon |
| `distincts(X, Y)` | distinction établie ou documentaire | jamais | sinon (la même classe : une substitution invalide, pas une réfutation par le texte) ; **supposée** : vraie sous hypothèse (§ 4.4) |
| `nombre(X, K)` | un membre de la classe a le nombre K | un membre a un autre nombre | sinon |

Une contrainte dont une variable n'est pas liée vaut inconnu. Seul le texte réfute : une contrainte n'est fausse que
par une assertion du graphe (une distinction établie contre `meme`, un autre nombre contre `nombre`) ; une substitution
qui viole sa propre contrainte (x et y sur la même classe sous `distincts`) n'est pas une solution, et ne réfute rien.

### 4.2 La valeur d'une formule

Elle se compose sur les paires : p ∧ q = (p⁺ ∧ q⁺, p⁻ ∨ q⁻) ; p ∨ q = (p⁺ ∨ q⁺, p⁻ ∧ q⁻). La conjonction d'un faux et
d'un inconnu est fausse ; la disjonction d'un contradictoire et d'un inconnu est vraie (elle a un appui positif, et
aucun appui négatif complet). Cette valeur dit ce que le graphe atteste ; ce qu'on peut en certifier est une autre
question (§ 4.3).

### 4.3 La certification

Une **solution certifiable** est une sélection (tous les enfants d'un `et`, un enfant d'un `ou`) et la substitution
de ses seules variables, telle que chaque atome sélectionné est vrai (1,0) avec un appui positif de l'auteur du texte,
et chaque contrainte sélectionnée vraie (ou vraie sous hypothèse). Elle est **vraie** si elle n'emploie aucune
hypothèse, **vraie sous hypothèses** sinon (avec la liste de ses hypothèses).

Une substitution de valeur vraie qui n'a aucune solution certifiable sous elle (sa vérité passe par un atome
contradictoire, ou par la seule parole d'une source citée) est **non certifiable**. Un contradictoire est **interne**
si un même énonciateur appuie les deux signes d'un atome, **documentaire** sinon.

### 4.4 Le résultat d'une requête

Les substitutions examinées : toutes les substitutions partielles des variables de la formule. On retient
- les solutions certifiables ;
- les substitutions minimales (au sens de l'inclusion des liaisons) de valeur contradictoire, de valeur fausse, et
  de valeur vraie non certifiable.

| Statut | Condition |
|---|---|
| `etablie` | une solution certifiable vraie (sans hypothèse) |
| `etablie_sous_hypotheses` | aucune vraie, une vraie sous hypothèses : une conclusion conditionnelle, ses hypothèses dans la preuve |
| `contradictoire` | aucune certifiable, une substitution contradictoire ou vraie non certifiable |
| `ecartee` | rien de cela, une substitution fausse : écartée **pour ces référents** |
| `inconnue` | rien de cela ; `Partiel` dit quels atomes ont un appui positif quelque part (jamais une preuve) |
| `incomplet` | le budget de calcul est épuisé avant qu'une solution certifiable soit trouvée : aucune conclusion négative |

Un rôle inversé n'est pas une preuve négative (« Goliath tranche la tête de David » laisse « David tranche la tête de
Goliath » inconnue) ; une substitution fausse n'écarte pas la configuration ailleurs dans l'œuvre.

### 4.5 L'énumération et le budget

Le moteur optimisé ne parcourt pas toutes les substitutions partielles. Il cherche
- les solutions certifiables par des **arbres positifs** (tous les enfants d'un `et`, un d'un `ou`, chaque atome lié
  par un appui positif) ;
- les substitutions fausses par des **arbres négatifs** (un enfant d'un `et`, tous ceux d'un `ou`, chaque atome lié par
  un appui négatif, chaque contrainte fausse) ;
- les contradictoires par l'union d'un arbre positif et d'un arbre négatif ; les vraies non certifiables par des
  arbres positifs ;
puis calcule la valeur de chaque candidate et garde les minimales. C'est complet : la valeur positive et la valeur
négative d'une formule ne peuvent que croître quand on lie plus de variables, donc une substitution minimale de valeur
fausse est exactement les liaisons d'un arbre négatif, une contradictoire celles d'un arbre positif et d'un arbre
négatif, une vraie non certifiable celles d'un arbre positif.

Il lie d'abord les atomes les plus sélectifs. Son **budget** compte les appuis examinés (et les solutions gardées) ;
épuisé, le résultat est `incomplet` s'il n'a pas de solution certifiable, et ce qui a été trouvé de certifiable reste
vrai.

## 5. La preuve

```
preuve(Id, Versions, Regime, Sigma, Justifications, Hypotheses)
  Versions        [noyau(V), connaissances(V), graphe(Empreinte)]
  Regime          figuration | classement      (classement si tous les atomes de la requête sont des genres)
  Sigma           [v(Nom)-Valeur, …]           les variables des atomes justifiés, chacune une fois
  Justifications  [j(Chemin, Atome, Appui), …]
     Chemin       la position de l'atome dans la formule (liste d'indices à partir de 1)
     Appui        appui(Assertion, Entite, Passage, Lien) pour un atome ;
                  contrainte(etablie(distinct(E1, E2))) | contrainte(documentaire(C1, C2, Source))
                  | contrainte(hypothese) | contrainte(egalite) | contrainte(difference) | contrainte(nombre(E))
  Hypotheses      [distinction_supposee(X, Y, Noms1, Noms2), …]   vide pour une preuve déductive
```

L'empreinte est celle du graphe validé (`variant_sha1` de ses assertions triées).

## 6. Le vérificateur

Un programme distinct (`verificateur.pl`), qui ne partage avec le moteur que ce document, le graphe, le contrat des
assertions (`assertions.pl`) et les primitives de K. Il **n'accepte qu'après avoir établi positivement** chacun des
points suivants ; tout terme qu'il ne reconnaît pas est une raison de rejet.

1. La preuve a la forme du § 5 : termes clos, listes, une justification `j/3` par élément.
2. Les versions sont celles du noyau, de K et du graphe (empreinte recalculée sur le graphe validé).
3. Le régime est celui de la requête.
4. La sélection justifiée satisfait la formule ; chaque chemin désigne l'atome cité ; aucun n'est justifié deux fois.
5. σ lie exactement les variables des atomes justifiés, chacune une fois, à une valeur de la bonne sorte
   (représentant d'une classe, ou événement).
6. Chaque appui existe, est positif, de l'auteur, admissible (§ 1), correspond à σ, et son lien est un chemin de K.
7. Chaque contrainte est vraie sous σ, par la justification qu'elle cite ; une hypothèse citée est dans la liste et y
   est légitime (les deux classes portent des noms différents, sans alias, sans distinction contraire).
8. Aucun atome justifié n'a d'appui négatif sous σ, d'aucun énonciateur.

Il certifie qu'une conclusion découle de ses prémisses (le graphe, K, la requête, et les hypothèses listées). Il ne
certifie ni que la requête dit le libellé, ni que le graphe dit le texte, ni que le texte dit vrai de l'image.

**Le banc de mutations** (§ 7) : chaque preuve d'un test est altérée de toutes les façons suivantes, et chaque
altération doit être rejetée : un appui retiré, inexistant ou nié ; une valeur de σ changée ; une variable étrangère
ajoutée ; une seconde liaison ajoutée ; un rôle changé ; un pas de lien inventé ; un chemin déplacé ; une version ou
une empreinte changée ; le régime changé ; un terme parasite dans les justifications ; une hypothèse retirée.

## 7. Le moteur de référence, le moteur optimisé, et ce qui garantit qu'ils disent la même chose

- **Le moteur de référence** (`satisfaction_reference.pl`) écrit le § 4 le plus simplement possible : toutes les
  substitutions partielles des variables de la formule (une variable : non liée, ou chaque valeur de son domaine),
  celles dont chaque variable liée est ancrée (un atome de la formule qui la contient a, sous elles, un appui de l'un
  ou l'autre signe), la valeur de Belnap de toute la formule sous chacune, les minimales de chaque classe ; et, à part,
  toutes les solutions certifiables (sélection et substitution de ses variables). Sans ordre, sans index, sans budget.
- **Le moteur optimisé** (`satisfaction.pl`) cherche par arbres (§ 4.5), lie les atomes les plus sélectifs d'abord,
  charge chaque document dans un module temporaire, compte son budget. Il expose `solutions_classees/4`, la même vue
  que la référence : `vue(Certifiables, Contradictoires, NonCertifiees, Fausses)`.
- **La garantie** : toute optimisation doit préserver exactement la vue de la référence. Les tests génératifs
  (`tests/plunit/test_noyau_generatif.pl`, graine fixe) tirent 1 500 graphes (un à cinq référents ; noms dont des
  alias, une paire documentée distincte et des noms seulement différents ; propriétés, événements, rôles agent,
  patient, thème ; relations ; coréférences ; distinctions établies ; nombres ; polarités, modalités, portées,
  énonciateurs, alternatives ; une hiérarchie avec un cycle et un pas de lexicalisation qui n'est pas une inclusion)
  et 1 500 requêtes (profondeur un à trois, atomes et contraintes, et un gabarit de deux référents nommés et de leur
  distinction), et vérifient :
  1. la vue des deux moteurs est identique ;
  2. le statut est le même, quand le calcul est complet ;
  3. chaque preuve du moteur optimisé est acceptée par le vérificateur ;
  4. le vérificateur est sûr : une preuve altérée au hasard (substitution, appui, chemin, justification retirée ou
     doublée, variable étrangère, régime, hypothèse retirée, terme parasite) qu'il accepte est une solution certifiable
     de la référence ;
  5. les distributions effectives sont publiées (`docs/mesures/V2.md`), et chaque statut et chaque opérateur
     apparaissent.
- **Les contre-exemples sémantiques** (`tests/plunit/test_noyau_semantique.pl`) : quinze cas dont le statut attendu est
  écrit d'après ce document seul, confrontés au moteur optimisé et au moteur de référence. Les deux moteurs peuvent
  partager une erreur de conception (ils sont écrits d'après la même spécification) ; ce banc n'en dépend pas.
- **Les tests savent échouer** : `outils/noyau/injection.py` injecte dix défauts dans une copie du moteur optimisé
  (négation qui remonte la hiérarchie, distinction en monde fermé, référent porteur non vérifié, négation d'une
  alternative admise, certification malgré un appui négatif, source citée certifiée, conjonction où un faux ne suffit
  pas, budget épuisé pris pour une conclusion, rôle sans l'état de son événement, nombre hors de la classe) ; chacun
  doit faire échouer au moins un des bancs.

**Ce que ces tests mesurent, et ce qu'ils ne mesurent pas.** Sur les graphes et les requêtes formellement définis,
dont les réponses sont connues (les tests écrits à la main, les contre-exemples) ou calculées par l'oracle (les tests
génératifs), le noyau doit réussir à 100 % : c'est la correction du noyau logique, relative à cette spécification. Ils
ne disent rien de la justesse du lecteur (le graphe tiré d'un texte) ni du compilateur (la requête tirée d'un
libellé) : celles-là sont statistiques et se mesurent à part (`docs/mesures/`, `docs/PLAN_V1.md`, C3 et C6).

## 8. L'inclusion des requêtes

`inclusion.pl` décide si Q1 implique Q2 (tout modèle de Q1 établit Q2), pour comparer une requête compilée à une
requête de référence. Le critère est celui de Chandra et Merlin : pour chaque cas de Q1 — une sélection, et un nom de
chaque liste de noms alternatifs (`nom(x, [DAVID, GOLIATH])` est deux cas, jamais une conjonction) —, le graphe
canonique du cas établit Q2. Il vaut dans la sémantique du noyau parce que ce graphe est un modèle universel du cas :
chaque variable de référent est une entité positive, affirmée, de l'auteur, présente par une entité porteuse de type
neutre ; chaque variable d'événement, un événement porteur ; deux variables, deux entités d'identité inconnue ; un
atome, une assertion positive (rien n'y est réfuté) ; `meme` une coréférence, `distincts` une distinction établie,
`nombre` un nombre ; et « établit » est le statut `etablie` (une conclusion sous hypothèse ne vaut pas dans tous les
modèles). Le résultat est `oui`, `non(ContreExemple)` (le cas dont le graphe n'établit pas Q2 : un modèle de Q1 où Q2
n'est pas établie), ou `indetermine(Raison)` hors du fragment (deux prédicats pour un même événement, une requête mal
formée, un budget épuisé, un graphe canonique invalide). Le critère suppose les mêmes connaissances et la même
normalisation des deux côtés, et que la normalisation (C7) est une équivalence. Les tests (`tests/plunit/
test_inclusion.pl`) vérifient la réflexivité (y compris sur des requêtes tirées au hasard), l'hyperonymie, les noms
alternatifs, la distinction, l'identité, l'union, l'orientation des relations, et donnent les contre-exemples.
