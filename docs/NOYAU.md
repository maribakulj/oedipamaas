# Le noyau logique : requêtes, satisfaction, preuves (M0, version 0.3, 26 novembre 2026)

**Version 0.2** (qualification formelle, 26/11) : la négation descend la hiérarchie par la seule inclusion ;
l'identité est en monde ouvert (trois régimes de distinction) ; la valeur d'une formule (Belnap) est séparée de sa
certification ; l'admissibilité reprend le contrat des assertions ; un budget de calcul ; un vérificateur qui
n'accepte qu'après avoir tout établi.

**Version 0.3** (qualification, cycle 3 ; journal `docs/QUALIFICATION_NOYAU.md`, D22 à D35) : une assertion niée
nie une description, qui ne se répartit pas sur ses atomes (§ 1.1) ; une liste de noms n'est niée que si chacun de
ses noms l'est ; un porteur n'est admissible que présent selon l'auteur ; une prémisse niée ne certifie rien ; les
contraintes ont quatre valeurs ; le nombre et les noms d'une distinction documentaire sont qualifiés ; un type entier
est nié comme un mot ; l'alias est clos ; un calcul interrompu ne conclut pas « sous hypothèses ».

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
  - `pos(Q)` : polarité positive, modalité « affirmé », portée C, hors de toute alternative, et chaque entité dont
    l'assertion parle (l'entité citée par un nom ou une propriété, les deux entités d'une relation, le participant
    d'un rôle ; c'est l'entité citée elle-même, pas un autre membre de sa classe) est **présente** : positive,
    affirmée, de portée C, hors de toute alternative ; Q est l'énonciateur de l'assertion si chacune de ces entités
    est présente selon l'auteur, et sinon l'énonciateur de celle qui ne l'est pas (D25 : « l'auteur dit qu'il
    s'appelle Pierre » d'un homme dont seul un catalogue dit qu'il est là n'est pas une prémisse de l'auteur) ;
  - `neg(Q)` : polarité négative, modalité « affirmé », portée C, hors de toute alternative, et chaque entité dont
    elle parle, autre qu'elle-même, présente (« le lion n'est pas mort » parle d'un lion qui est là) ; ce qu'un appui
    négatif nie est fixé au § 1.1 ;
  - aucun état sinon (une hypothèse, un titre, une alternative, un autre contexte) : l'assertion n'appuie rien, dans
    un sens ni dans l'autre.
  Un rôle positif a l'état de son événement et demande son participant présent. Positifs et négatifs portent leur
  énonciateur : un désaccord entre sources est gardé, avec ses sources (§ 4.3). `nombre/2` n'a pas de qualificatifs :
  il vaut ce que vaut son entité (il ne compte que si elle est présente, et n'est certifiable que si elle l'est selon
  l'auteur).

### 1.1 Ce que nie une assertion niée

La polarité porte sur toute la description que l'assertion introduit, et une négation de conjonction ne se répartit
pas : ¬(A ∧ B) n'implique ni ¬A ni ¬B (« pas de lion mort » ne dit pas « pas de lion » ; « Goliath ne décapite pas
David » ne dit rien d'une autre décapitation). Le noyau ne tire donc d'appui négatif que là où la négation est celle
d'un atome, ou là où la description niée est entièrement couverte :

| Assertion niée | Appui négatif de |
|---|---|
| `nom(A, E, Nom)`, E présente | `nom(X, Ks)` sous σ(X) la classe de E, si **chaque** clé de Ks est niée ainsi (une liste de noms est une disjonction, D24) |
| `propriete(A, E, W)`, E présente | `propriete(X, P)`, σ(X) la classe de E, P inclus dans W |
| `relation(A, E1, W, E2)`, présentes | `relation(X, R, Y)`, σ(X), σ(Y) les classes de E1, E2, R inclus dans W (orientée) |
| `entite(E, W)` **nue** (rien d'autre n'en est dit : ni nom, propriété, relation, rôle, nombre, distinction), dans une classe qui a un membre présent | `type(X, T)`, σ(X) cette classe, T inclus dans W (« ce personnage n'est pas un saint ») |
| `entite(E, W)` nue, seule dans sa classe | `type(X, T)` pour **tout** référent σ(X), T inclus dans W (« pas de lion » : aucun lion n'est figuré) |
| `entite(E, W)` nue, dans une classe d'autres membres dont aucun n'est présent | rien |
| `entite(E, W)` restreinte (« pas de lion mort ») | rien : la description niée n'est pas décomposée |
| `evenement(N, W)` et ses rôles `role(N, Ro, E)`, chaque participant E présent | `evenement(V, P)` pour un **autre** événement V présent qui a, pour chaque rôle de N, le même rôle vers un membre de la même classe, P inclus dans W (« Marie ne tient pas l'enfant » contredit « Marie tient l'enfant » ; un événement nié sans rôle nie tout événement de ce prédicat : la lecture la plus prudente) |
| `role(N, …)` d'un événement nié | rien : un rôle n'est pas nié seul |
| `entite(E, W)` nue de portée `oeuvre` | `genre(T)`, T inclus dans W (« pas un portrait mort » ne nie pas le genre) |

Ces règles sont saines (chaque appui négatif découle de l'assertion niée) mais incomplètes : la réfutation d'une
conjonction de la requête qui couvre exactement une description niée (« la femme tient l'enfant » contre « la femme ne
tient pas l'enfant » quand aucun autre événement n'est dit) n'est pas dérivée (journal, D41) ; c'est une perte dans le
sens sûr (moins de réfutations, aucune certification de plus).

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
l'autre sens et par la seule inclusion : `chemin_inclus(Type, [S0, …, Sn], Mot)` avec S0 le nœud du type demandé (le
type lui-même si c'est un identifiant de concept, un entier ; un de ses sens, `K:sens(Cat, Type, S0)`, si c'est un
mot : D27), `K:inclus(Si, Si+1)`, `K:sens(Cat, Mot, Sn)` (nier un type plus général nie les plus spécifiques : « pas
de félin » nie « lion » ; « pas de lion » ne nie pas « félin »). Les chemins sont simples : la hiérarchie peut avoir
des cycles. **L'alias** est clos par le noyau (réflexif, symétrique, transitif), quel que soit K (D33).

**La polysémie** (décision du propriétaire, 27/11 ; journal, D30). Les **sens conceptuels** d'un mot sont ses
identifiants de concepts (les entiers que K lui donne), s'il en a ; sinon ses sens tels que K les donne (le mot
lui-même, D20). Un mot polysémique n'établit pas tous ses sens à la fois :
- un lien positif part d'un sens conceptuel du mot ; il est **certain** si chacun des sens conceptuels atteint le type
  demandé (une conclusion commune à toutes les lectures), sinon il ne fonde qu'une **hypothèse** de sens
  (`sens_suppose(Mot, Type)`) ;
- une négation est **certaine** si chaque nœud du type demandé (le type lui-même s'il est un entier, sinon ses sens
  conceptuels) est inclus dans chaque sens conceptuel du mot nié ; sinon, si un couple l'est, elle n'est que
  **possible** : elle ne réfute rien et ne contredit rien déductivement, mais une conclusion positive qu'elle touche
  n'est plus établie que sous l'hypothèse qu'elle vise un autre sens (`negation_autre_sens(Atome)`) ;
- la lexicalisation (d'un concept vers son lemme) est un pas de `sous`, jamais d'`inclus` : « pas de pomme » ne nie pas
  « fruit » ;
- **limite connue (L1, journal § 10)** : une hypothèse de sens est rattachée au lemme (`sens_suppose(Mot, Type)`),
  non à l'occurrence, et les hypothèses d'une solution ne sont pas confrontées entre elles ; une même occurrence peut
  ainsi recevoir deux lectures exclusives dans une seule conclusion conditionnelle (« une pomme » établie comme
  végétal et comme objet, sous hypothèses). Une conclusion sous hypothèses de sens n'est donc pas une annotation
  exploitable automatiquement ;
- un appui ne certifie rien, même sous hypothèse, s'il n'a **aucune lecture** : aucun sens conceptuel du mot n'atteint
  le type sans que l'assertion, prise en ce sens, soit niée de façon certaine (« une pomme ; pas de fruit ; pas
  d'objet » : chaque sens de « pomme » est nié, et « pomme » ne s'y établit pas ; dernier audit, B3).
La désambiguïsation selon le contexte relève de C7 ; K ne choisit plus de sens en silence (l'anglais prenait le premier
sens de WordNet : il les prend tous).

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
  contrainte, ses variables sont celles d'atomes de la même sélection, si aucune contrainte n'est `distincts(X, X)`
  (qu'aucune substitution ne peut satisfaire), et si aucune contrainte ne porte sur une variable d'événement (les
  événements n'ont ni coréférence, ni distinction, ni nombre : `contrainte_sur_evenement`, D35).

**Le fragment.** Ce sont des formules existentielles positives (∃, ∧, ∨) à atomes typés, avec égalité et
différence, évaluées sur un graphe fini : l'équivalent d'unions de requêtes conjonctives. Il n'y a pas de négation
dans une requête, et aucune négation par échec dans une preuve. L'évaluation termine : le graphe est fini, la requête
aussi, et un lien est un chemin simple dans la hiérarchie de K (qui peut avoir des cycles : celle des verbes de WordNet
en a), cherché par un parcours en largeur où chaque nœud n'est vu qu'une fois (son coût est borné par le nombre de
nœuds atteignables, non par celui des chemins, exponentiel quand l'héritage est multiple). Le coût d'une requête est
celui d'un homomorphisme de graphes, exponentiel dans le nombre de variables ; le moteur lie d'abord les atomes les
plus sélectifs (§ 4). Une requête est un terme clos et acyclique ; sa bonne forme se vérifie en temps polynomial (la
liaison des contraintes sans énumérer les sélections).

## 4. La satisfaction

### 4.1 Les valeurs des atomes et des contraintes

Une **substitution** σ lie des variables (pas forcément toutes) à des référents (représentants de classe) ou à des
événements. Sous σ, un atome dont une variable n'est pas liée vaut **inconnu**. Sinon il a des appuis positifs
(liens positifs, état `pos`) et négatifs (liens négatifs, état `neg`), et sa valeur est la paire (positif, négatif)
de Belnap : (0,0) inconnu, (1,0) vrai, (0,1) faux, (1,1) contradictoire.

Une contrainte a, comme un atome, un appui positif et un appui négatif, indépendants (D29) :

| Contrainte, variables liées | appui positif | appui négatif |
|---|---|---|
| `meme(X, Y)` | même classe | une distinction établie (entre entités présentes selon l'auteur) ou documentaire entre les deux classes ; dans la classe, une telle distinction, ou deux noms admissibles que K dit deux individus, donnent (1,1) |
| `distincts(X, Y)` | classes différentes, distinction établie ou documentaire ; **supposée** : vraie sous hypothèse (§ 4.4) | aucun (la même classe : une substitution invalide, valeur (0,0), pas une réfutation) |
| `nombre(X, K)` | un membre **présent** de la classe a le nombre K (certifiable s'il est présent selon l'auteur) | un membre présent a un autre nombre |

Une contrainte dont une variable n'est pas liée vaut inconnu. Ce qui réfute une contrainte est une assertion du graphe
ou une distinction documentaire de K (la réfutation de `meme` par K est une conclusion relative à la source de K ;
journal, D31). **La distinction documentaire** ne repose que sur des noms admissibles (de l'auteur, d'un porteur
présent selon l'auteur et dont l'existence n'est pas niée, qu'aucune assertion niée de la classe, de porteur présent, ne contredit : D50 ; dernier audit, B1), et seulement si aucune des deux classes
ne porte, à alias près, le nom documenté de l'autre (D26). Les noms qu'une classe « porte », pour
cette exclusion, sont tous ceux qu'une assertion positive lui donne, quels que soient leurs autres qualificatifs et leur
porteur, contestés ou non (la lecture prudente). **La distinction supposée** ne repose que sur des noms d'un porteur
présent, qu'aucune assertion niée de la classe ne contredit, et suppose qu'aucun nom que l'une porte (au sens large ci-dessus,
même seulement possible ou contesté) n'est, à alias près, un nom que porte l'autre.

### 4.2 La valeur d'une formule

Elle se compose sur les paires : p ∧ q = (p⁺ ∧ q⁺, p⁻ ∨ q⁻) ; p ∨ q = (p⁺ ∨ q⁺, p⁻ ∧ q⁻). La conjonction d'un faux et
d'un inconnu est fausse ; la disjonction d'un contradictoire et d'un inconnu est vraie (elle a un appui positif, et
aucun appui négatif complet). Cette valeur dit ce que le graphe atteste ; ce qu'on peut en certifier est une autre
question (§ 4.3).

### 4.3 La certification

Une **solution certifiable** est une sélection (tous les enfants d'un `et`, un enfant d'un `ou`) et la substitution
de ses seules variables, telle que chaque atome sélectionné est vrai (1,0) avec un appui positif de l'auteur du texte
dont **aucune prémisse n'est niée** : l'atome reformé avec le mot même de l'appui (`type(X, W)` pour une entité de mot
W, `nom(X, [Clé])` pour un nom, etc. : « une lionne » ne certifie pas « un lion » quand le texte dit aussi « pas de
lionne ») ; l'existence de chaque entité que l'appui cite (le type de son mot n'est pas nié pour sa classe : « un
homme nommé Pierre ; il n'y a pas d'homme ») ; pour un rôle, son événement (« la femme ne tient pas l'enfant » ôte au
rôle de « la femme tient l'enfant » sa prémisse). Chaque contrainte sélectionnée est vraie et certifiable (ou vraie
sous hypothèse) ; une distinction établie ou un nombre ne sont certifiables que si l'existence de leurs entités n'est
pas niée de façon certaine ; une négation seulement possible de cette existence en fait une conclusion sous hypothèse
(`negation_autre_sens(type(R, W))` ; dernier audit, B2). Elle est **vraie** si elle n'emploie aucune
hypothèse, **vraie sous hypothèses** sinon (avec la liste de ses hypothèses).

Une substitution de valeur vraie qui n'a aucune solution certifiable sous elle (sa vérité passe par un atome
contradictoire, ou par la seule parole d'une source citée) est **non certifiable**. Un contradictoire est **interne**
si un même énonciateur appuie les deux signes d'un atome, **documentaire** sinon.

### 4.4 Le résultat d'une requête

Les substitutions examinées : les substitutions partielles des variables de la formule dont chaque variable liée est
**ancrée** (un atome de la formule qui la contient, entièrement lié, a sous elle un appui de l'un ou l'autre signe :
une variable liée à un référent dont rien n'est dit ne compte pas). On retient
- les solutions certifiables ;
- les substitutions minimales (au sens de l'inclusion des liaisons) de valeur contradictoire, de valeur fausse, et
  de valeur vraie non certifiable.

| Statut | Condition |
|---|---|
| `etablie` | une solution certifiable vraie (sans hypothèse) |
| `etablie_sous_hypotheses` | aucune vraie, une vraie sous hypothèses : une conclusion conditionnelle, ses hypothèses dans la preuve |
| `contradictoire` | aucune certifiable, une substitution contradictoire |
| `non_certifiee` | rien de cela, une substitution vraie non certifiable (sa vérité passe par la seule parole d'une source citée, ou par une prémisse niée) |
| `ecartee` | rien de cela, une substitution fausse : écartée **pour ces référents**. Chaque élément est `refutation(Sigma, substitution, Fondements)` : la portée est la substitution partielle (jamais la notation, ni le document), les fondements sont l'énonciateur de chaque appui négatif (`auteur`, `cite(Source)`), une distinction documentaire de K avec sa source (`documentaire(Source)`), ou une contrainte du graphe (`texte`) (décision du 27/11, D31) |
| `inconnue` | rien de cela ; `Partiel` dit quels atomes ont un appui positif quelque part (jamais une preuve) |
| `incomplet` | le budget (ou le temps) est épuisé avant qu'une solution certifiable vraie soit trouvée : aucune conclusion négative, et pas `etablie_sous_hypotheses`, qui dirait « aucune vraie » (D32) |

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
épuisé, le résultat est `etablie` s'il a trouvé une solution certifiable vraie, `incomplet` sinon. Une erreur
interne du calcul est une erreur, jamais un résultat de repli.

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
  Hypotheses      [distinction_supposee(X, Y, Noms1, Noms2) | sens_suppose(Mot, Type)
                   | negation_autre_sens(Atome), …]                 vide pour une preuve déductive
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
6. Chaque appui existe, est positif, de l'auteur, admissible (§ 1 : ses porteurs présents selon l'auteur), correspond
   à σ, et son lien est un chemin de K.
7. Chaque contrainte est vraie sous σ, par la justification qu'elle cite, et sans appui négatif (une classe dite une
   et deux, deux nombres) ; une distinction documentaire repose sur des noms admissibles et non partagés ; un nombre
   sur une entité présente selon l'auteur ; une hypothèse citée est dans la liste et y est légitime (les deux classes
   portent des noms non contredits, différents, sans alias, même par une chaîne) ; les hypothèses des atomes sont
   exactement celles que demandent les appuis cités (un sens supposé pour un lien qui n'est pas certain, une négation
   seulement possible de l'atome, de l'assertion citée, de l'existence d'une entité citée, de l'événement d'un rôle).
8. Aucun atome justifié n'a d'appui négatif sous σ, d'aucun énonciateur (§ 1.1), ni l'assertion qu'il cite, reformée
   avec son propre mot.

Il certifie qu'une conclusion découle de ses prémisses (le graphe, K, la requête, et les hypothèses listées). Il ne
certifie ni que la requête dit le libellé, ni que le graphe dit le texte, ni que le texte dit vrai de l'image.

**Le banc de mutations** (§ 7) : chaque preuve d'un test est altérée de toutes les façons suivantes, et chaque
altération doit être rejetée : un appui retiré, inexistant ou nié ; une valeur de σ changée ; une variable étrangère
ajoutée ; une seconde liaison ajoutée ; un rôle changé ; un pas de lien inventé ; un chemin déplacé ; une version ou
une empreinte changée ; le régime changé ; un terme parasite dans les justifications ; une hypothèse retirée ou
ajoutée ; et, l'empreinte recalculée pour que ce soit le contrôle visé qui rejette, le graphe altéré : l'assertion
citée niée, citée par une autre source, seulement possible, hors de l'image, doublée d'une négation d'une autre
source ou mise dans une alternative ; son porteur seulement possible ou cité ; le type demandé nié ; un autre nombre,
un nombre seulement possible ou cité ; une distinction dans une classe dite une.

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
- **L'oracle indépendant** (`tests/oracle/oracle_noyau.py`, Python, écrit d'après ce document seul, sans lire le code
  Prolog ; `tests/oracle/differentiel.py`) : le statut de l'oracle est confronté à celui des deux moteurs sur des cas
  tirés (graine fixe, deux générateurs) ; aucun désaccord exigé (`tests/test_oracle.py`). Ses lectures des points
  ambigus de ce document sont listées en bas de l'oracle (`AMBIGUITES`).
- **Les contre-exemples sémantiques** (`tests/plunit/test_noyau_semantique.pl`) : 74 cas dont le statut attendu est
  écrit d'après ce document seul, confrontés au moteur optimisé et au moteur de référence. Les deux moteurs peuvent
  partager une erreur de conception (ils sont écrits d'après la même spécification) ; ce banc n'en dépend pas.
- **Les tests savent échouer** : `outils/noyau/injection.py` injecte vingt-six défauts dans une copie du moteur
  optimisé (négation qui remonte la hiérarchie, distinction en monde fermé, référent porteur non vérifié, négation
  d'une alternative admise, certification malgré un appui négatif, source citée certifiée, conjonction où un faux ne
  suffit pas, budget épuisé pris pour une conclusion, rôle sans l'état de son événement, nombre hors de la classe ;
  et pour la version 0.3 : négation d'une description répartie, liste de noms niée par un seul nom, prémisse
  contredite certifiée, porteur d'une source citée certifié, nombre d'une entité seulement possible, contrainte à trois
  valeurs, distinction documentaire sur un nom cité, type entier jamais nié ; et, après l'audit final : existence du
  porteur ignorée, événement d'un rôle ignoré, identité contre K non réfutée), dix-sept dans une copie du vérificateur et
  huit dans le comparateur (§ 8) ;
  chacun doit faire échouer au moins un des bancs.

**Ce que ces tests mesurent, et ce qu'ils ne mesurent pas.** Sur les graphes et les requêtes formellement définis,
dont les réponses sont connues (les tests écrits à la main, les contre-exemples) ou calculées par l'oracle (les tests
génératifs), le noyau doit réussir à 100 % : c'est la correction du noyau logique, relative à cette spécification. Ils
ne disent rien de la justesse du lecteur (le graphe tiré d'un texte) ni du compilateur (la requête tirée d'un
libellé) : celles-là sont statistiques et se mesurent à part (`docs/mesures/`, `docs/PLAN_V1.md`, C3 et C6).

## 8. L'inclusion des requêtes

`inclusion.pl` décide si Q1 implique Q2, pour comparer une requête compilée à une requête de référence.

**La définition.** Q1 ⊆ Q2 si tout graphe où Q1 est `etablie` établit Q2. Les graphes sont ceux de **K⁺** : K, plus,
pour chaque nœud T de sa hiérarchie, un mot « $noeud:T » dont T est le seul sens, et pour chaque clé C un nom
« $cle:C ». Un type de requête n'est donc jamais lu comme un mot du texte (le mot « lion » désigne aussi une
célébrité, et `type(lion)` n'implique pas `type(félin)`) ; un contre-exemple peut employer un de ces mots.

**La méthode** (Chandra et Merlin, corrigée pour la sémantique du noyau ; journal, D37 à D40). Pour chaque cas de Q1
— une sélection, et un nom de chaque liste de noms (`nom(x, [DAVID, GOLIATH])` est deux cas, jamais une
conjonction) —, le graphe canonique du cas : une entité porteuse positive, affirmée, de l'auteur par variable de
référent, un événement porteur par variable d'événement, d'identifiants tirés d'une table ; un atome, une assertion
positive dont le mot est « $noeud:T » ; `meme` une coréférence, `distincts` une distinction établie, `nombre` un
nombre ; rien n'y est nié.
1. Le graphe canonique doit établir Q1 ; sinon (un cas insatisfaisable, `meme` et `distincts` sur les mêmes
   variables) : `indetermine(cas_non_etabli)`, jamais un contre-exemple.
2. S'il n'établit pas Q2 : `non(Cas)`, un contre-exemple (le graphe canonique est un modèle de Q1).
3. S'il l'établit par une preuve sans distinction documentaire (deux noms documentés ne disent pas que deux variables
   sont deux classes dans tout modèle : la même classe peut porter les deux noms) et dont chaque lien **transmet la
   négation** (pour chaque nœud S2 du type de Q2 que le lien négatif du noyau prend, un nœud du type de Q1 lui est
   inclus par `inclus` : alors ce qui nie Q2 nie Q1), le cas est inclus. Les noms (alias clos, liste niée seulement si
   chaque clé l'est), les rôles, les contraintes transmettent la négation par construction (§ 1.1, § 4.1).
4. Sinon, pour un type : le graphe canonique plus « pas de T2 » ; s'il établit Q1 et pas Q2, c'est un contre-exemple
   (`non(negation(Cas, T2))`) ; sinon `indetermine(negation_non_transmise)`.
5. Un `meme(X, Y)` de Q2 dont les deux variables tombent sur une classe que Q1 ne dit une par aucune coréférence (une
   seule de ses variables) ne transmet pas la négation : un modèle de Q1 peut y dire la classe une et deux. Le graphe
   canonique plus un « jumeau » (une entité coréférente au porteur et distincte de lui) est alors un contre-exemple
   (`non(jumeau(Cas, Porteur))`), s'il établit Q1 sans établir Q2 (audit final, B1).
Q1 ⊆ Q2 si chaque cas est inclus. **Pourquoi c'est sûr** : dans un graphe G où Q1 est certifiée par une substitution
σ, l'homomorphisme du graphe canonique vers G (σ) porte la preuve de Q2 ; chaque appui positif de Q2 est l'appui d'un
atome de Q1 (même assertion, lien prolongé), donc de l'auteur, admissible, de prémisse non niée ; un appui négatif de
Q2 serait, par la transmission, un appui négatif de Q1, exclu ; une prémisse de Q2 (porteur, événement d'un rôle) est
celle de l'atome de Q1 dont l'appui est le même ; un `meme` de Q2 tombe sur une classe que Q1 dit une, donc sans
distinction interne dans G. Cet argument est écrit, non démontré mécaniquement ; il
est mis à l'épreuve par les bancs ci-dessous.

**Hors de la méthode** : `indetermine(Raison)` — deux prédicats pour un même événement, une requête mal formée, un
budget épuisé, une normalisation qui échoue ou qui **change** le graphe canonique (la normalisation C7 n'est pas une
équivalence : la règle du participant unique n'est pas monotone ; journal, D37). Un verdict `indetermine` n'est ni
une inclusion ni une non-inclusion.

**Les tests.** `tests/plunit/test_inclusion.pl` (27 tests, attendus écrits à la main, avec des graphes-témoins évalués
par le moteur) : réflexivité, hyperonymie, transitivité, noms alternatifs, alias en chaîne, distinction, identité,
union, orientation, contre-exemples, insatisfiables, types entiers, lexicalisation, distinction documentaire,
hypothèse, normalisation. `tests/plunit/test_inclusion_generatif.pl` (300 paires tirées par affaiblissement et au
hasard, graine fixe) : chaque `oui` est confronté à des modèles (le graphe canonique d'un cas de Q1, joint à un graphe
tiré au hasard, à des coréférences vers ses porteurs et à des négations ciblées), chaque `non` à son contre-exemple ;
réflexivité, indépendance des noms de variables, transitivité. `outils/noyau/injection.py` injecte huit défauts dans
le comparateur ; chacun est détecté. Distribution (graine 20261130) : 228 `oui`, 70 `non`, 2 `indetermine`.
