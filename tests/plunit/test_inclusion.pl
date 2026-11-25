/*  Tests de l'inclusion des requêtes (inclusion.pl ; docs/NOYAU.md, § 8), sans aucune donnée : les attendus sont
    écrits d'après la définition de l'inclusion (Q1 ⊆ Q2 : tout modèle de Q1 établit Q2).  */
:- use_module('../../oedipamaas/socle/inclusion').
:- use_module('../../oedipamaas/socle/requetes').
:- use_module(connaissances_essai).
:- use_module(library(plunit)).
:- use_module(library(random)).
:- encoding(utf8).

k(connaissances_essai).
cmp(Q1, Q2, V) :- k(K), comparer(K, aucune, requete(a, Q1), requete(b, Q2), V).

:- begin_tests(inclusion).

test(reflexive_simple) :- cmp(type(v(x), lion), type(v(x), lion), equivalentes).
test(reflexive_propriete_seule) :-            % une requête faite d'une seule propriété s'implique elle-même
    cmp(propriete(v(x), mort), propriete(v(x), mort), equivalentes).
test(reflexive_role_seul) :- cmp(role(v(e), agent, v(x)), role(v(e), agent, v(x)), equivalentes).
test(hyperonymie) :- cmp(type(v(x), lionne), type(v(x), lion), incluse).          % une lionne est un lion
test(noms_alternatifs_ne_sont_pas_une_conjonction) :-
    cmp(nom(v(x), ['DAVID']), nom(v(x), ['DAVID', 'GOLIATH']), incluse),
    cmp(nom(v(x), ['DAVID', 'GOLIATH']), nom(v(x), ['DAVID']), contient).
test(distinction_exigee) :-                    % deux hommes, l'identité libre, n'impliquent pas deux hommes distincts
    cmp(et([type(v(x), homme), type(v(y), homme)]),
        et([type(v(x), homme), type(v(y), homme), distincts(v(x), v(y))]), contient).
test(identite) :-
    cmp(et([type(v(x), homme), type(v(y), saint), meme(v(x), v(y))]), et([type(v(x), homme), type(v(x), saint)]),
        equivalentes).
test(union) :- cmp(type(v(x), lionne), ou([type(v(x), lion), type(v(x), tigre)]), incluse).
test(relation_orientee) :-
    cmp(relation(v(x), avec, v(y)), relation(v(y), avec, v(x)), equivalentes),   % le nom des variables est libre
    cmp(et([type(v(x), femme), type(v(y), enfant), relation(v(x), avec, v(y))]),
        et([type(v(x), femme), type(v(y), enfant), relation(v(y), avec, v(x))]), incomparables(_, _)).
test(contre_exemple_donne) :-
    k(K), inclusion(K, aucune, requete(a, type(v(x), animal)), requete(b, type(v(x), lion)), non(As)),
    As == [type(v(x), animal)].
test(hors_du_fragment_indetermine) :-
    cmp(et([evenement(v(e), tenir), evenement(v(e), bercer)]), evenement(v(e), tenir), indetermine(_)).
test(mal_formee_indetermine) :- cmp(ou([type(v(x), a)]), type(v(x), a), indetermine(requete_mal_formee)).
test(reflexive_sur_des_requetes_tirees) :-     % la réflexivité, sur des requêtes tirées au hasard
    set_random(seed(11)),
    forall(between(1, 200, _), ( requete_tiree(F), ( cmp(F, F, V), memberchk(V, [equivalentes, indetermine(_)]) ) )).

:- end_tests(inclusion).

requete_tiree(F) :- between(1, 200, _), formule(2, F), requetes:bien_formee(requete(r, F), []), !.
formule(P, F) :-
    random(X),
    (   P > 0, X < 0.3 -> random_between(2, 3, N), length(Fs, N), maplist(formule(P - 1), Fs), F = ou(Fs)
    ;   P > 0, X < 0.6 -> random_between(1, 3, N), length(Fs, N), maplist(formule(P - 1), Fs), F = et(Fs)
    ;   atome(F)
    ).
atome(A) :-
    random_member(X, [v(x), v(y)]), random_member(Y, [v(x), v(y)]), random_between(1, 8, I),
    (   I =:= 1 -> random_member(T, [lion, felin, homme]), A = type(X, T)
    ;   I =:= 2 -> random_member(Ks, [['DAVID'], ['DAVID', 'GOLIATH']]), A = nom(X, Ks)
    ;   I =:= 3 -> A = propriete(X, mort)
    ;   I =:= 4 -> A = evenement(v(e), tenir)
    ;   I =:= 5 -> A = role(v(e), agent, X)
    ;   I =:= 6 -> A = relation(X, avec, Y)
    ;   I =:= 7 -> A = distincts(X, Y)
    ;   A = genre(portrait)
    ).
