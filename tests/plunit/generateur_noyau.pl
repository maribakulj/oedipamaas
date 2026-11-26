/*  Le générateur des tests génératifs du noyau (graine fixée par l'appelant) : de petits graphes et de petites
    requêtes sur le module de connaissances connaissances_gen. Partagé par test_noyau_generatif.pl et
    test_inclusion_generatif.pl.  */
:- use_module(library(random)).
:- use_module(library(lists)).
:- use_module(library(apply)).
:- use_module(library(yall)).

cas_generatifs(N) :- ( getenv('OEDIPAMAAS_CAS_GENERATIFS', A), atom_number(A, N0) -> N = N0 ; N = 1500 ).

un_de(L, X) :- random_member(X, L).
peut_etre(P) :- random(X), X < P.

% --- Les graphes ---------------------------------------------------------------------------------------------------

graphe_aleatoire(G) :-
    random_between(1, 5, NE), numlist(1, NE, Is),
    maplist([I, E]>>atom_concat(e, I, E), Is, Es),
    findall(entite(E, T, p_0), ( member(E, Es), un_de([a, a1, a2, b, b1, top, c1, lemme_a, poly, nom_propre], T) ), Ents),
    findall(nom(N, E, Nm, p_0), ( member(E, Es), peut_etre(0.5), atom_concat(n_, E, N), un_de([x, xa, y, z], Nm) ), Noms1),
    % un second nom, parfois le même, pour que des appuis de signes opposés se rencontrent (contradictions)
    findall(nom(N, E, Nm, p_0), ( member(nom(_, E, Nm0, _), Noms1), peut_etre(0.4), atom_concat(m_, E, N),
                                  ( peut_etre(0.6) -> Nm = Nm0 ; un_de([x, y], Nm) ) ), Noms2),
    append(Noms1, Noms2, Noms),
    findall(propriete(Q, E, P, p_0), ( member(E, Es), peut_etre(0.3), atom_concat(q_, E, Q), un_de([r, r1], P) ), Props),
    random_between(0, 2, NV), ( NV =:= 0 -> Js = [] ; numlist(1, NV, Js) ),
    findall(evenement(V, P, p_0), ( member(J, Js), atom_concat(v, J, V), un_de([p, p1, q], P) ), Evs),
    findall(role(V, R, E), ( member(evenement(V, _, _), Evs), member(R, [agent, patient, theme]), peut_etre(0.6),
                             un_de(Es, E) ), Roles),
    findall(relation(A, E1, Rl, E2, p_0), ( member(E1, Es), peut_etre(0.3), un_de(Es, E2), atom_concat(r_, E1, A),
                                            un_de([s, s1], Rl) ), Rels),
    findall(coref(E1, E2), ( member(E1, Es), member(E2, Es), E1 @< E2, peut_etre(0.15) ), Cor),
    findall(distinct(E1, E2), ( member(E1, Es), member(E2, Es), E1 @< E2, \+ memberchk(coref(E1, E2), Cor),
                                peut_etre(0.15) ), Dis),
    findall(nombre(E, K), ( member(E, Es), peut_etre(0.2), random_between(1, 3, K) ), Nbs),
    append([Ents, Noms, Props, Evs, Roles, Rels, Cor, Dis, Nbs], G0),
    findall(A, ( member(F, G0), ident(F, A) ), As0), sort(As0, As),
    findall(Qf, ( member(A, As), qualifs(A, Qs), member(Qf, Qs) ), Qual),
    ( As = [A1, A2|_], peut_etre(0.1) -> Alt = [alternative(g1, [A1, A2])] ; Alt = [] ),
    append([[texte("x"), doc(fr, inconnu)], G0, Qual, Alt, [passage(p_0, 0, 1)]], G).

ident(entite(A, _, _), A). ident(nom(A, _, _, _), A). ident(propriete(A, _, _, _), A). ident(evenement(A, _, _), A).
ident(relation(A, _, _, _, _), A).
qualifs(A, [polarite(A, Po), modalite(A, Mo), portee(A, Pr), enonciateur(A, En)]) :-
    ( peut_etre(0.2) -> Po = neg ; Po = pos ),
    ( peut_etre(0.1) -> Mo = possible ; Mo = affirme ),
    random(X), ( X < 0.8 -> Pr = represente ; X < 0.93 -> Pr = oeuvre ; Pr = histoire ),
    ( peut_etre(0.1) -> En = cite(z) ; En = auteur ).

% --- Les requêtes --------------------------------------------------------------------------------------------------

requete_aleatoire(requete(r, F)) :-
    peut_etre(0.3), !,                        % deux référents nommés et leur distinction (hypothèses, documents)
    un_de([['X'], ['XA']], K1), un_de([['Y'], ['Z']], K2),
    un_de([distincts(v(x), v(y)), meme(v(x), v(y))], C), F = et([nom(v(x), K1), nom(v(y), K2), C]).
requete_aleatoire(requete(r, F)) :-
    between(1, 500, _), random_between(1, 3, P), formule(P, F), requetes:bien_formee(requete(r, F), []), !.

formule(Pr, F) :-
    random(X),
    (   Pr > 0, X < 0.25 -> random_between(2, 3, N), length(Fs, N), maplist(formule(Pr - 1), Fs), F = ou(Fs)
    ;   Pr > 0, X < 0.55 -> random_between(1, 3, N), length(Fs, N), maplist(formule(Pr - 1), Fs), F = et(Fs)
    ;   X < 0.8 -> atome_gen(F)
    ;   contrainte_gen(F)
    ).
ref(v(V)) :- un_de([x, y, z], V).
atome_gen(A) :-
    random_between(1, 7, I),
    (   I =:= 1 -> ref(X), un_de([a, a1, b, top, c2, lemme_a, poly, b1], T), A = type(X, T)
    ;   I =:= 2 -> ref(X), un_de([['X'], ['Y'], ['Z'], ['X', 'Y']], Ks), A = nom(X, Ks)
    ;   I =:= 3 -> ref(X), un_de([r, r1], P), A = propriete(X, P)
    ;   I =:= 4 -> un_de([p, p0, q], P), A = evenement(v(e), P)
    ;   I =:= 5 -> ref(X), un_de([agent, patient, theme], R), A = role(v(e), R, X)
    ;   I =:= 6 -> ref(X), ref(Y), un_de([s, s1], R), A = relation(X, R, Y)
    ;   un_de([a, top], T), A = genre(T)
    ).
contrainte_gen(C) :-
    ref(X), ref(Y), random_between(1, 3, I),
    ( I =:= 1 -> C = meme(X, Y) ; I =:= 2 -> C = distincts(X, Y) ; random_between(1, 3, K), C = nombre(X, K) ).

