/*  L'inclusion des requêtes du noyau (docs/NOYAU.md, § 8) : Q1 implique-t-elle Q2 ?

    inclusion(+K, +Normaliser, +Q1, +Q2, -R)
        R = oui | non(ContreExemple) | indetermine(Raison)
        Normaliser : un prédicat d'arité 2 (Graphe0, Graphe) appliqué à chaque graphe canonique (la normalisation de la
        langue, C7), ou « aucune »
    comparer(+K, +Normaliser, +Q1, +Q2, -Verdict)
        Verdict = equivalentes | incluse | contient | incomparables(CE1, CE2) | indetermine(Raison)
          incluse : Q1 ⊆ Q2 seulement (Q1 est plus forte) ; contient : Q2 ⊆ Q1 seulement

    Q1 ⊆ Q2 : tout graphe où Q1 est `etablie` établit Q2, les graphes étant ceux des mots de K⁺ (K, plus, pour chaque
    nœud T de sa hiérarchie, un mot dont T est le seul sens, et pour chaque clé de nom, un nom dont c'est la clé).

    La méthode (Chandra et Merlin, corrigée pour la sémantique du noyau ; journal, D37 à D40) : pour chaque cas de Q1
    (une sélection de sa forme normale disjonctive, et un nom de chaque liste de noms : « nom(x, [DAVID, GOLIATH]) »
    est deux cas, jamais une conjonction), le graphe canonique du cas :
      - chaque variable de référent est une entité porteuse positive, affirmée, de l'auteur ; chaque variable
        d'événement un événement porteur ; deux variables, deux entités d'identité inconnue ; leurs identifiants sont
        tirés d'une table (« $v1 », « $v2 »), jamais du nom de la variable ;
      - un type T est une entité dont le mot est « $noeud:T », dont le seul sens est le nœud T (jamais le mot T, qui a
        ses propres sens : « lion » est aussi une célébrité) ; de même pour une propriété, un prédicat, une relation,
        un genre ; un nom de clé C est le nom « $cle:C » ;
      - `meme` une coréférence, `distincts` une distinction établie, `nombre` un nombre ; rien n'y est nié.
    Le cas est contrôlé : son graphe canonique doit établir Q1 (sinon le cas est insatisfaisable ou hors de la méthode :
    indéterminé, jamais un contre-exemple). S'il établit Q2 par une preuve
      - qui ne passe par aucune distinction documentaire (deux noms documentés distincts ne disent pas que deux
        variables sont deux classes dans tous les modèles : la même classe peut porter les deux noms), et
      - dont chaque lien transmet la négation (pour chaque nœud S2 du type de Q2, un nœud du type de Q1 lui est inclus
        par `inclus` : alors tout ce qui nie le type de Q2 nie celui de Q1, et la certification de Q1 dans un graphe
        garantit celle de Q2),
    le cas est inclus. S'il n'établit pas Q2, c'est un contre-exemple (un modèle de Q1 où Q2 n'est pas établie). Une
    preuve dont un lien ne transmet pas la négation : pour un type, on ajoute « pas de T2 » au graphe canonique, et si
    ce graphe établit encore Q1 sans établir Q2, c'est un contre-exemple ; sinon, indéterminé.
    La normalisation n'est pas une équivalence (elle n'est pas monotone : le participant unique) : un graphe canonique
    qu'elle change rend le résultat indéterminé. Un budget épuisé, une requête mal formée, un fragment non pris en
    charge (deux prédicats pour un événement) : indéterminé, jamais une inclusion ni une non-inclusion.
*/
:- module(inclusion, [ inclusion/5, comparer/5, cas_de/2, canonique/2 ]).
:- encoding(utf8).
:- use_module(library(lists)).
:- use_module(library(apply)).
:- use_module(requetes).
:- use_module(satisfaction).

comparer(K, N, Q1, Q2, V) :-
    inclusion(K, N, Q1, Q2, R12), inclusion(K, N, Q2, Q1, R21),
    (   ( R12 = indetermine(X) ; R21 = indetermine(X) ) -> V = indetermine(X)
    ;   R12 == oui, R21 == oui -> V = equivalentes
    ;   R12 == oui -> V = incluse
    ;   R21 == oui -> V = contient
    ;   R12 = non(C1), R21 = non(C2), V = incomparables(C1, C2)
    ).

inclusion(_, _, Q1, Q2, indetermine(requete_mal_formee)) :-
    ( \+ requetes:bien_formee(Q1, []) ; \+ requetes:bien_formee(Q2, []) ), !.
inclusion(K, N, Q1, Q2, R) :-
    Q1 = requete(_, F1),
    k_etendu(K, Ke),
    findall(As, cas_de(F1, As), Cas),
    catch(premier_contre_exemple(Ke, N, Cas, Q1, Q2, R), E,
          ( E = fragment(X) -> R = indetermine(X) ; R = indetermine(erreur(E)) )).

premier_contre_exemple(_, _, [], _, _, oui).
premier_contre_exemple(K, N, [As|Cas], Q1, Q2, R) :-
    canonique(As, G0),
    (   normaliser(N, G0, G1) -> true ; throw(fragment(normalisation_echouee)) ),
    sort(G0, S0), sort(G1, S1),
    ( S0 == S1 -> G = G0 ; throw(fragment(normalisation_non_equivalente)) ),
    etablit(K, G, Q1, St1, _),
    (   St1 == incomplet -> R = indetermine(budget)
    ;   St1 \== etablie -> R = indetermine(cas_non_etabli(As))
    ;   etablit(K, G, Q2, St2, Ps),
        (   St2 == incomplet -> R = indetermine(budget)
        ;   St2 \== etablie -> R = non(As)
        ;   member(P, Ps), preuve_sure(K, G, P) -> premier_contre_exemple(K, N, Cas, Q1, Q2, R)
        ;   contre_exemple_par_negation(K, G, Q1, Q2, Ps, As, R0) -> R = R0
        ;   contre_exemple_par_jumeau(K, G, Q1, Q2, Ps, As, R0) -> R = R0
        ;   R = indetermine(negation_non_transmise(As))
        )
    ).

etablit(K, G, Q, St, Els) :-
    satisfaction:satisfaire(K, G, Q, resultat(St0, Els, Complet)),
    ( Complet == incomplet -> St = incomplet ; St = St0 ).

normaliser(aucune, G, G) :- !.
normaliser(N, G0, G) :- call(N, G0, G).

% une preuve sûre : aucune distinction documentaire, chaque lien transmet la négation, et chaque `meme` de Q2 tombe
% sur une classe que Q1 dit une par une coréférence (deux de ses variables) : sinon un modèle de Q1 peut dire cette
% classe une et deux à la fois, et `meme` y est contradictoire (audit final, B1)
preuve_sure(K, G, preuve(_, _, _, S, Js, _)) :-
    \+ member(j(_, _, contrainte(documentaire(_, _, _))), Js),
    forall(member(j(_, A, appui(_, _, _, L)), Js), transmet(K, A, L)),
    forall(member(j(_, meme(X, _), contrainte(egalite)), Js),
           ( memberchk(X-I, S), classe_canonique(G, I, C),
             aggregate_all(count, ( member(E, C), sub_atom(E, 0, 2, _, '$v') ), Nv), Nv >= 2 )).
classe_canonique(G, I, C) :- clos_coref(G, [I], [I], C).
clos_coref(G, Front, Vus, C) :-
    findall(Y, ( member(X, Front), ( member(coref(X, Y), G) ; member(coref(Y, X), G) ), \+ memberchk(Y, Vus) ), Ys0),
    sort(Ys0, Ys), ( Ys == [] -> C = Vus ; append(Vus, Ys, Vus1), clos_coref(G, Ys, Vus1, C) ).
transmet(K, A, chemin(Mot, _)) :- !,
    categorie(A, Cat, T2), atom_concat('$noeud:', X, Mot), noeud_de(X, T1),
    noeuds(K, Cat, T1, N1), noeuds(K, Cat, T2, N2),
    % une négation possible de Q2 (un couple) en est une de Q1 ; une négation certaine de Q2 (chaque nœud) aussi (D30)
    N1 \== [], N2 \== [],
    forall(member(S2, N2), ( member(S1, N1), inclus_ou_egal(K, S1, S2) )),
    forall(member(S1, N1), ( member(S2, N2), inclus_ou_egal(K, S1, S2) )).
transmet(_, _, _).                              % un nom (clé ou alias clos), un rôle : la négation suit (§ 1.1)

categorie(type(_, T), n, T). categorie(genre(T), n, T). categorie(propriete(_, T), a, T).
categorie(evenement(_, T), v, T). categorie(relation(_, T, _), r, T).
noeud_de(X, N) :- ( atom_number(X, N0), integer(N0) -> N = N0 ; N = X ).
% les nœuds d'un type demandé, tels que le lien négatif du noyau les prend (NOYAU § 2)
noeuds(_, _, T, [T]) :- integer(T), !.
noeuds(K, Cat, T, Ns) :-                         % les sens conceptuels, comme le noyau les prend (NOYAU § 2, D30)
    findall(S, K:sens(Cat, T, S), Ns0), sort(Ns0, Ns1), include(integer, Ns1, Is), ( Is == [] -> Ns = Ns1 ; Ns = Is ).
inclus_ou_egal(K, S1, S2) :- clos_inclus(K, [S1], [S1], Ns), memberchk(S2, Ns).
clos_inclus(K, Front, Vus, Ns) :-
    findall(Y, ( member(X, Front), K:inclus(X, Y), \+ memberchk(Y, Vus) ), Ys0), sort(Ys0, Ys),
    ( Ys == [] -> Ns = Vus ; append(Vus, Ys, Vus1), clos_inclus(K, Ys, Vus1, Ns) ).

% un jumeau : une entité coréférente au porteur d'une variable de Q2 et distincte de lui ; la classe est dite une et
% deux, ce qui ne touche que les `meme` ; s'il établit encore Q1 sans établir Q2, c'est un contre-exemple
contre_exemple_par_jumeau(K, G, Q1, Q2, Ps, As, non(jumeau(As, I))) :-
    member(preuve(_, _, _, S, Js, _), Ps), member(j(_, meme(X, _), contrainte(egalite)), Js), memberchk(X-I, S),
    append(G, [entite('$jumeau', '$referent', '$p'), polarite('$jumeau', pos), modalite('$jumeau', affirme),
               portee('$jumeau', represente), enonciateur('$jumeau', auteur), coref(I, '$jumeau'),
               distinct(I, '$jumeau')], G2),
    etablit(K, G2, Q1, etablie, _), etablit(K, G2, Q2, St2, _), St2 \== etablie, St2 \== incomplet, !.

% « pas de T2 » ajouté au graphe canonique : un modèle de Q1 où Q2 n'est pas établie, s'il l'est encore
contre_exemple_par_negation(K, G, Q1, Q2, Ps, As, non(negation(As, T2))) :-
    member(preuve(_, _, _, _, Js, _), Ps), member(j(_, type(_, T2), appui(_, _, _, L)), Js), \+ transmet(K, type(_, T2), L),
    mot(T2, Mot),
    append(G, [entite('$nie', Mot, '$p'), polarite('$nie', neg), modalite('$nie', affirme),
               portee('$nie', represente), enonciateur('$nie', auteur)], G2),
    etablit(K, G2, Q1, etablie, _), etablit(K, G2, Q2, St2, _), St2 \== etablie, St2 \== incomplet, !.

% les cas d'une formule : une sélection, et un nom de chaque liste de noms
cas_de(et(Fs), As) :- !, cas_liste(Fs, As).
cas_de(ou(Fs), As) :- !, member(F, Fs), cas_de(F, As).
cas_de(nom(X, Ks), [nom(X, [K])]) :- !, member(K, Ks).
cas_de(A, [A]).
cas_liste([], []).
cas_liste([F|Fs], As) :- cas_de(F, A1), cas_liste(Fs, A2), append(A1, A2, As).

% le graphe canonique d'un cas ; les identifiants viennent d'une table (« $v1 ») et sont préfixés pour ne jamais
% rencontrer ceux d'une requête ; chaque variable de référent a une entité porteuse de type neutre, chaque variable
% d'événement un événement porteur de prédicat neutre
canonique(As, G) :-
    requetes:variables(As, Vs),
    findall(V, ( member(A, As), ( A = evenement(V, _) ; A = role(V, _, _) ) ), Evs0), sort(Evs0, Evs),
    % un événement n'a qu'un prédicat : deux atomes evenement sur une même variable sortent du fragment
    (   member(evenement(V1, P1), As), member(evenement(V2, P2), As), V1 == V2, P1 \== P2
    ->  throw(fragment(deux_predicats_pour_un_evenement))
    ;   true
    ),
    findall(F, ( member(V, Vs), id(Vs, V, I),
                 (   memberchk(V, Evs) -> ( member(evenement(V0, P), As), V0 == V -> mot(P, Mp) ; Mp = '$evenement' ),
                     F = evenement(I, Mp, '$p')
                 ;   F = entite(I, '$referent', '$p') ) ), Porteurs),
    foldl(canon(Vs), As, 1-[], _-Fs0), reverse(Fs0, Fs1),
    append(Porteurs, Fs1, Fs2),
    findall(Q, ( member(F, Fs2), identifiant(F, I), qualificatifs(F, I, Qs), member(Q, Qs) ), Qual),
    append([[texte("x"), doc(fr, inconnu), passage('$p', 0, 1)], Fs2, Qual], G0), sort(G0, G).

id(Vs, V, I) :- nth1(N, Vs, V0), V0 == V, !, format(atom(I), "$v~w", [N]).
num(P, N, I) :- format(atom(I), "$~w~w", [P, N]).
mot(T, M) :- format(atom(M), "$noeud:~w", [T]).
cle(C, M) :- format(atom(M), "$cle:~w", [C]).

canon(Vs, type(V, T), N-G, N1-[entite(E, M, '$p'), coref(E, I)|G]) :- id(Vs, V, I), num(t, N, E), mot(T, M), N1 is N + 1.
canon(Vs, nom(V, [K]), N-G, N1-[nom(A, I, M, '$p')|G]) :- id(Vs, V, I), num(n, N, A), cle(K, M), N1 is N + 1.
canon(Vs, propriete(V, P), N-G, N1-[propriete(A, I, M, '$p')|G]) :- id(Vs, V, I), num(q, N, A), mot(P, M), N1 is N + 1.
canon(_, evenement(_, _), N-G, N1-G) :- N1 is N + 1.                 % porté par l'événement de la variable
canon(Vs, role(V, R, X), N-G, N1-[role(I, R, J)|G]) :- id(Vs, V, I), id(Vs, X, J), N1 is N + 1.
canon(Vs, relation(X, R, Y), N-G, N1-[relation(A, I, M, J, '$p')|G]) :-
    id(Vs, X, I), id(Vs, Y, J), num(r, N, A), mot(R, M), N1 is N + 1.
canon(_, genre(T), N-G, N1-[entite(E, M, '$p')|G]) :- num(genre__, N, E), mot(T, M), N1 is N + 1.
canon(Vs, meme(X, Y), N-G, N1-[coref(I, J)|G]) :- id(Vs, X, I), id(Vs, Y, J), N1 is N + 1.
canon(Vs, distincts(X, Y), N-G, N1-[distinct(I, J)|G]) :- id(Vs, X, I), id(Vs, Y, J), N1 is N + 1.
canon(Vs, nombre(X, K), N-G, N1-[nombre(I, K)|G]) :- id(Vs, X, I), N1 is N + 1.

identifiant(entite(I, _, _), I). identifiant(nom(I, _, _, _), I). identifiant(propriete(I, _, _, _), I).
identifiant(evenement(I, _, _), I). identifiant(relation(I, _, _, _, _), I).
qualificatifs(F, I, [polarite(I, pos), modalite(I, affirme), portee(I, P), enonciateur(I, auteur)]) :-
    ( F = entite(_, _, _), sub_atom(I, 0, _, _, '$genre__') -> P = oeuvre ; P = represente ).

% K⁺ : K, plus un mot « $noeud:T » dont le seul sens est le nœud T, et un nom « $cle:C » dont la clé est C. Un module
% par K, créé une fois ; tout le reste est délégué à K.
k_etendu(K, Ke) :-
    atom_concat('inclusion_etendu__', K, Ke),
    (   current_predicate(Ke:sens/3) -> true
    ;   forall(member(Cl, [ ( sens(C, W, S) :- ( atom(W), atom_concat('$noeud:', X, W) -> inclusion:noeud_de(X, S)
                                                                                         ; K:sens(C, W, S) ) ),
                             ( sous(A, B) :- K:sous(A, B) ),
                             ( inclus(A, B) :- K:inclus(A, B) ),
                             ( cle_de_nom(N, C) :- ( atom(N), atom_concat('$cle:', C0, N) -> C = C0 ; K:cle_de_nom(N, C) ) ),
                             ( alias(A, B) :- K:alias(A, B) ),
                             ( distincts_documentes(A, B, S) :- K:distincts_documentes(A, B, S) ),
                             ( version(V) :- K:version(V) ) ]),
               assertz(Ke:Cl))
    ).
