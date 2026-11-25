/*  Le moteur de référence du noyau (docs/NOYAU.md, § 7) : la sémantique de la satisfaction, écrite le plus simplement
    possible, sans ordre de liaison, sans index, sans limite. Il énumère toutes les sélections de la formule et, pour
    chacune, toutes les substitutions de ses variables par toutes les valeurs du domaine. Lent par construction : il ne
    sert que d'oracle au moteur optimisé (satisfaction.pl), qui doit en reproduire exactement les solutions classées
    et le statut. Il ne réutilise aucun prédicat du moteur optimisé ni du vérificateur.

    solutions_reference(+K, +Graphe, +Requete, -Classees)   [c(Classe, Sigma, Selection)], trié
    statut_reference(+K, +Graphe, +Requete, -Statut)        etablie | contradictoire | ecartee | inconnue
*/
:- module(satisfaction_reference, [ solutions_reference/4, statut_reference/4 ]).
:- encoding(utf8).
:- use_module(library(lists)).
:- use_module(library(apply)).

statut_reference(K, G, Q, St) :-
    solutions_reference(K, G, Q, Cs),
    (   memberchk(c(vraie, _, _), Cs) -> St = etablie
    ;   memberchk(c(contradictoire, _, _), Cs) -> St = contradictoire
    ;   memberchk(c(contredite, _, _), Cs) -> St = ecartee
    ;   St = inconnue
    ).

solutions_reference(K, G, requete(_, F), Cs) :-
    findall(c(Cl, Sigma, Sel),
            ( selection(F, [], Sel0), sort(Sel0, Sel),
              variables_de(Sel, Vs), affectation(G, F, Vs, Sigma0), sort(Sigma0, Sigma),
              solution(K, G, Sel, Sigma), classe(K, G, Sel, Sigma, Cl) ),
            Cs0),
    sort(Cs0, Cs).

% --- Les sélections : tous les enfants d'un « et », un enfant d'un « ou » -----------------------------------------

selection(et(Fs), C, Sel) :- !, selections_et(Fs, C, 1, Sel).
selection(ou(Fs), C, Sel) :- !, nth1(I, Fs, F), append(C, [I], C1), selection(F, C1, Sel).
selection(A, C, [C-A]).
selections_et([], _, _, []).
selections_et([F|Fs], C, I, Sel) :-
    append(C, [I], C1), selection(F, C1, S1), I1 is I + 1, selections_et(Fs, C, I1, S2), append(S1, S2, Sel).

% --- Les substitutions : chaque variable, chaque valeur de son domaine --------------------------------------------

% les variables des atomes de la sélection (une contrainte ne lie pas de variable : docs/NOYAU.md, § 3)
variables_de(Sel, Vs) :- findall(V, ( member(_-A, Sel), \+ contrainte(A), sous_terme(A, V) ), Vs0), sort(Vs0, Vs).
sous_terme(v(N), v(N)) :- !.
sous_terme(T, V) :- compound(T), T =.. [_|As], member(A, As), sous_terme(A, V).

affectation(_, _, [], []).
affectation(G, F, [V|Vs], [V-X|S]) :- domaine(G, F, V, X), affectation(G, F, Vs, S).

% la sorte d'une variable : événement si elle est le premier argument d'un atome evenement ou role de la formule
domaine(G, F, V, X) :-
    (   evenementielle(F, V) -> setof(E, P^Pa^member(evenement(E, P, Pa), G), Es), member(X, Es)
    ;   setof(R, representant_de(G, R), Rs), member(X, Rs)
    ).
evenementielle(F, V) :- sous_formule(F, A), ( A = evenement(V0, _) ; A = role(V0, _, _) ), V0 == V, !.
sous_formule(F, F).
sous_formule(et(Fs), A) :- member(F, Fs), sous_formule(F, A).
sous_formule(ou(Fs), A) :- member(F, Fs), sous_formule(F, A).

% les classes de coréférence : R est le plus petit identifiant de sa composante
representant_de(G, R) :- member(entite(R, _, _), G), \+ ( classe_de(G, R, E), E @< R ).
classe_de(G, E, X) :- composante(G, [E], [E], C), member(X, C).
composante(_, [], C, C).
composante(G, [X|Xs], Vus, C) :-
    findall(Y, ( ( member(coref(X, Y), G) ; member(coref(Y, X), G) ), \+ memberchk(Y, Vus) ), Ys0), sort(Ys0, Ys),
    append(Vus, Ys, Vus1), append(Xs, Ys, Xs1), composante(G, Xs1, Vus1, C).
dans_la_classe(G, E, R) :- classe_de(G, R, E), !.

val(S, V, X) :- memberchk(V-X, S).

% --- La solution et sa classe --------------------------------------------------------------------------------------

solution(K, G, Sel, S) :-
    forall(member(_-A, Sel), ( contrainte(A) -> contrainte_vraie(G, S, A) ; once(signe_appui(K, G, S, A, _)) )).

classe(K, G, Sel, S, Cl) :-
    findall(Pos-Neg, ( member(_-A, Sel), \+ contrainte(A),
                       ( signe_appui(K, G, S, A, pos) -> Pos = oui ; Pos = non ),
                       ( signe_appui(K, G, S, A, neg) -> Neg = oui ; Neg = non ) ), Vs),
    (   \+ memberchk(non-_, Vs) -> ( memberchk(_-oui, Vs) -> Cl = contradictoire ; Cl = vraie )
    ;   Cl = contredite
    ).

contrainte(meme(_, _)).
contrainte(distincts(_, _)).
contrainte(nombre(_, _)).
contrainte_vraie(_, S, meme(X, Y)) :- val(S, X, A), val(S, Y, B), A == B.
contrainte_vraie(_, S, distincts(X, Y)) :- val(S, X, A), val(S, Y, B), A \== B.
contrainte_vraie(G, S, nombre(X, N)) :- val(S, X, R), member(nombre(E, N), G), dans_la_classe(G, E, R), !.

% --- Les appuis, d'après docs/NOYAU.md, § 1 et 4 ------------------------------------------------------------------

etat(G, A, Ctx, pos) :-
    memberchk(polarite(A, pos), G), memberchk(modalite(A, affirme), G), memberchk(enonciateur(A, auteur), G),
    memberchk(portee(A, Ctx), G), \+ ( member(alternative(_, As), G), memberchk(A, As) ).
etat(G, A, Ctx, neg) :- memberchk(polarite(A, neg), G), memberchk(modalite(A, affirme), G), memberchk(portee(A, Ctx), G).

% signe_appui(K, G, Sigma, Atome, Signe) : un appui de ce signe existe pour l'atome sous Sigma
signe_appui(K, G, S, type(X, T), Sg) :-
    val(S, X, R), member(entite(E, W, _), G), W \== nom_propre, dans_la_classe(G, E, R), etat(G, E, represente, Sg),
    monte(K, n, W, T).
signe_appui(K, G, S, nom(X, Ks), Sg) :-
    val(S, X, R), member(nom(A, E, Nom, _), G), dans_la_classe(G, E, R), etat(G, A, represente, Sg), nomme(K, Nom, Ks).
signe_appui(K, G, S, propriete(X, P), Sg) :-
    val(S, X, R), member(propriete(A, E, W, _), G), dans_la_classe(G, E, R), etat(G, A, represente, Sg),
    monte(K, a, W, P).
signe_appui(K, G, S, evenement(X, P), Sg) :-
    val(S, X, V), member(evenement(V, W, _), G), etat(G, V, represente, Sg), monte(K, v, W, P).
signe_appui(_, G, S, role(X, Ro, Y), Sg) :-
    val(S, X, V), val(S, Y, R), member(role(V, Ro, E), G), dans_la_classe(G, E, R), member(evenement(V, _, _), G),
    etat(G, V, represente, Sg).
signe_appui(K, G, S, relation(X, Re, Y), Sg) :-
    val(S, X, R1), val(S, Y, R2), member(relation(A, E1, W, E2, _), G), dans_la_classe(G, E1, R1),
    dans_la_classe(G, E2, R2), etat(G, A, represente, Sg), monte(K, r, W, Re).
signe_appui(K, G, _, genre(T), Sg) :-
    member(entite(E, W, _), G), W \== nom_propre, etat(G, E, oeuvre, Sg), monte(K, n, W, T).

% un mot du texte va au type T par K : un sens, puis des pas vers le haut
monte(K, C, W, T) :- K:sens(C, W, S0), atteint(K, S0, T), !.
atteint(_, S, T) :- S == T, !.
atteint(K, S, T) :- K:sous(S, S1), atteint(K, S1, T).

nomme(K, Nom, Ks) :- K:cle_de_nom(Nom, C), ( memberchk(C, Ks) -> true ; member(Ka, Ks), ( K:alias(C, Ka) ; K:alias(Ka, C) ) ), !.
