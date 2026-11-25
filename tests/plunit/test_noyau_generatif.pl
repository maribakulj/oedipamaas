/*  Tests génératifs du noyau (docs/NOYAU.md, § 7) : de petits graphes et de petites requêtes tirés au hasard (graine
    fixe), sur lesquels
      1. le moteur optimisé (satisfaction.pl) donne exactement les solutions classées du moteur de référence
         (satisfaction_reference.pl, énumération naïve) ;
      2. il en donne le statut, quand le calcul est complet ;
      3. chaque preuve qu'il produit est acceptée par le vérificateur ;
      4. le vérificateur est sûr : une preuve altérée au hasard qu'il accepte décrit une solution vraie du moteur de
         référence.
    Le nombre de cas (CAS) se règle par la variable d'environnement OEDIPAMAAS_CAS_GENERATIFS (1 500 par défaut).  */
:- use_module('../../oedipamaas/socle/requetes').
:- use_module('../../oedipamaas/socle/satisfaction').
:- use_module('../../oedipamaas/socle/satisfaction_reference').
:- use_module('../../oedipamaas/socle/verificateur').
:- use_module(connaissances_gen).
:- use_module(library(plunit)).
:- use_module(library(random)).
:- use_module(library(lists)).
:- use_module(library(apply)).
:- encoding(utf8).

cas_generatifs(N) :- ( getenv('OEDIPAMAAS_CAS_GENERATIFS', A), atom_number(A, N0) -> N = N0 ; N = 1500 ).

un_de(L, X) :- random_member(X, L).
peut_etre(P) :- random(X), X < P.

% --- Les graphes ---------------------------------------------------------------------------------------------------

graphe_aleatoire(G) :-
    random_between(1, 5, NE), numlist(1, NE, Is),
    maplist([I, E]>>atom_concat(e, I, E), Is, Es),
    findall(entite(E, T, p_0), ( member(E, Es), un_de([a, a1, a2, b, b1, top, nom_propre], T) ), Ents),
    findall(nom(N, E, Nm, p_0), ( member(E, Es), peut_etre(0.5), atom_concat(n_, E, N), un_de([x, xa, y], Nm) ), Noms1),
    % un second nom, parfois le même, pour que des appuis de signes opposés se rencontrent (contradictions)
    findall(nom(N, E, Nm, p_0), ( member(nom(_, E, Nm0, _), Noms1), peut_etre(0.4), atom_concat(m_, E, N),
                                  ( peut_etre(0.6) -> Nm = Nm0 ; un_de([x, y], Nm) ) ), Noms2),
    append(Noms1, Noms2, Noms),
    findall(propriete(Q, E, P, p_0), ( member(E, Es), peut_etre(0.3), atom_concat(q_, E, Q), un_de([r, r1], P) ), Props),
    random_between(0, 2, NV), ( NV =:= 0 -> Js = [] ; numlist(1, NV, Js) ),
    findall(evenement(V, P, p_0), ( member(J, Js), atom_concat(v, J, V), un_de([p, p1, q], P) ), Evs),
    findall(role(V, R, E), ( member(evenement(V, _, _), Evs), member(R, [agent, patient]), peut_etre(0.7),
                             un_de(Es, E) ), Roles),
    findall(relation(A, E1, Rl, E2, p_0), ( member(E1, Es), peut_etre(0.3), un_de(Es, E2), atom_concat(r_, E1, A),
                                            un_de([s, s1], Rl) ), Rels),
    findall(coref(E1, E2), ( member(E1, Es), member(E2, Es), E1 @< E2, peut_etre(0.15) ), Cor),
    findall(nombre(E, K), ( member(E, Es), peut_etre(0.2), random_between(1, 3, K) ), Nbs),
    append([Ents, Noms, Props, Evs, Roles, Rels, Cor, Nbs], G0),
    findall(A, ( member(F, G0), ident(F, A) ), As0), sort(As0, As),
    findall(Qf, ( member(A, As), qualifs(A, Qs), member(Qf, Qs) ), Qual),
    ( As = [A1, A2|_], peut_etre(0.1) -> Alt = [alternative(g1, [A1, A2])] ; Alt = [] ),
    append([G0, Qual, Alt, [passage(p_0, 0, 1)]], G).

ident(entite(A, _, _), A). ident(nom(A, _, _, _), A). ident(propriete(A, _, _, _), A). ident(evenement(A, _, _), A).
ident(relation(A, _, _, _, _), A).
qualifs(A, [polarite(A, Po), modalite(A, Mo), portee(A, Pr), enonciateur(A, En)]) :-
    ( peut_etre(0.2) -> Po = neg ; Po = pos ),
    ( peut_etre(0.1) -> Mo = possible ; Mo = affirme ),
    random(X), ( X < 0.8 -> Pr = represente ; X < 0.93 -> Pr = oeuvre ; Pr = histoire ),
    ( peut_etre(0.1) -> En = cite(z) ; En = auteur ).

% --- Les requêtes --------------------------------------------------------------------------------------------------

requete_aleatoire(requete(r, F)) :-
    between(1, 500, _), formule(2, F), requetes:bien_formee(requete(r, F), []), !.

formule(Pr, F) :-
    random(X),
    (   Pr > 0, X < 0.25 -> random_between(2, 3, N), length(Fs, N), maplist(formule(Pr - 1), Fs), F = ou(Fs)
    ;   Pr > 0, X < 0.55 -> random_between(1, 3, N), length(Fs, N), maplist(formule(Pr - 1), Fs), F = et(Fs)
    ;   X < 0.9 -> atome_gen(F)
    ;   contrainte_gen(F)
    ).
ref(v(V)) :- un_de([x, y, z], V).
atome_gen(A) :-
    random_between(1, 7, I),
    (   I =:= 1 -> ref(X), un_de([a, a1, b, top], T), A = type(X, T)
    ;   I =:= 2 -> ref(X), un_de([['X'], ['Y'], ['X', 'Y']], Ks), A = nom(X, Ks)
    ;   I =:= 3 -> ref(X), un_de([r, r1], P), A = propriete(X, P)
    ;   I =:= 4 -> un_de([p, p0, q], P), A = evenement(v(e), P)
    ;   I =:= 5 -> ref(X), un_de([agent, patient], R), A = role(v(e), R, X)
    ;   I =:= 6 -> ref(X), ref(Y), un_de([s, s1], R), A = relation(X, R, Y)
    ;   un_de([a, top], T), A = genre(T)
    ).
contrainte_gen(C) :-
    ref(X), ref(Y), random_between(1, 3, I),
    ( I =:= 1 -> C = meme(X, Y) ; I =:= 2 -> C = distincts(X, Y) ; random_between(1, 3, K), C = nombre(X, K) ).

% --- Les propriétés ------------------------------------------------------------------------------------------------

k(connaissances_gen).

cas(G, Q) :- graphe_aleatoire(G), requete_aleatoire(Q).

meme_solutions(G, Q) :-
    k(K), satisfaction:solutions_classees(K, G, Q, C1), satisfaction_reference:solutions_reference(K, G, Q, C2),
    C1 == C2.
meme_statut(G, Q) :-
    k(K), satisfaire(K, G, Q, resultat(S1, _, Complet)),
    ( Complet == incomplet -> true ; satisfaction_reference:statut_reference(K, G, Q, S2), S1 == S2 ).
preuves_acceptees(G, Q) :-
    k(K), satisfaire(K, G, Q, resultat(S, Ps, _)),
    ( S == etablie -> forall(member(P, Ps), verifier(K, G, Q, P, accepte)) ; true ).

% une altération au hasard d'une preuve
alterer(G, preuve(I, V, R, S, Js), preuve(I, V, R, S1, Js1)) :-
    random_between(1, 4, X),
    (   X =:= 1, S = [_|_] -> random_select(Va-_, S, S0), findall(E, member(entite(E, _, _), G), Es0),
        findall(E, member(evenement(E, _, _), G), Vs0), append(Es0, Vs0, Ds), random_member(D, Ds),
        S1 = [Va-D|S0], Js1 = Js
    ;   X =:= 2, Js = [_|_] -> S1 = S, random_select(_, Js, Js1)
    ;   X =:= 3, Js = [_|_] -> S1 = S, random_select(j(C, A, appui(_, E, P, L)), Js, Js0),
        findall(Id, ( member(F, G), ident(F, Id) ), Ids), random_member(Id, Ids),
        Js1 = [j(C, A, appui(Id, E, P, L))|Js0]
    ;   Js = [_|_] -> S1 = S, random_select(j(C, A, Ap), Js, Js0), random_between(1, 3, N),
        ( append(C0, [_], C) -> append(C0, [N], C1) ; C1 = [N] ), Js1 = [j(C1, A, Ap)|Js0]
    ;   S1 = S, Js1 = Js
    ).

% si le vérificateur accepte une preuve, sa substitution et sa sélection sont une solution vraie de la référence
verificateur_sur(G, Q) :-
    k(K), satisfaire(K, G, Q, resultat(S, Ps, _)),
    (   S == etablie
    ->  satisfaction_reference:solutions_reference(K, G, Q, Cs),
        forall(( member(P, Ps), between(1, 5, _), alterer(G, P, P2) ),
               (   verifier(K, G, Q, P2, accepte)
               ->  P2 = preuve(_, _, _, S2, Js2), findall(C-A, member(j(C, A, _), Js2), Sel0), sort(Sel0, Sel),
                   sort(S2, S2s), memberchk(c(vraie, S2s, Sel), Cs)
               ;   true ))
    ;   true
    ).

:- begin_tests(noyau_generatif).

test(moteur_optimise_egal_a_la_reference) :-
    set_random(seed(20261125)), cas_generatifs(N),
    findall(G-Q, ( between(1, N, _), cas(G, Q), \+ meme_solutions(G, Q) ), Ecarts),
    length(Ecarts, NE), ( NE > 0 -> Ecarts = [Ex|_], print_message(error, format("écart : ~q", [Ex])) ; true ),
    assertion(NE == 0).
test(meme_statut) :-
    set_random(seed(20261126)), cas_generatifs(N),
    findall(x, ( between(1, N, _), cas(G, Q), \+ meme_statut(G, Q) ), Ecarts), assertion(Ecarts == []).
test(preuves_acceptees) :-
    set_random(seed(20261127)), cas_generatifs(N),
    findall(x, ( between(1, N, _), cas(G, Q), \+ preuves_acceptees(G, Q) ), Ecarts), assertion(Ecarts == []).
test(verificateur_sur) :-
    set_random(seed(20261128)), cas_generatifs(N),
    findall(x, ( between(1, N, _), cas(G, Q), \+ verificateur_sur(G, Q) ), Ecarts), assertion(Ecarts == []).
test(les_cas_ne_sont_pas_triviaux) :-          % une part des requêtes est établie, une autre non
    set_random(seed(20261129)), k(K),
    findall(S, ( between(1, 400, _), cas(G, Q), satisfaire(K, G, Q, resultat(S, _, _)) ), Ss),
    forall(member(X, [etablie, inconnue, ecartee]), memberchk(X, Ss)).

:- end_tests(noyau_generatif).
