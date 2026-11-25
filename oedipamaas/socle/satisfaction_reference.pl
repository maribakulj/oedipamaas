/*  Le moteur de référence du noyau (docs/NOYAU.md, version 0.2, § 4 et 7) : la sémantique écrite le plus simplement
    possible. Il énumère toutes les substitutions partielles des variables de la formule, garde celles dont chaque
    variable liée est ancrée (un atome de la formule qui la contient a, sous elles, un appui de l'un ou l'autre signe),
    calcule la valeur de Belnap de toute la formule sous chacune, et, à part, toutes les solutions certifiables
    (sélection et substitution de ses variables). Sans ordre, sans index, sans budget. Lent par construction : il ne
    sert que d'oracle au moteur optimisé (satisfaction.pl), qui doit en reproduire la vue et le statut exactement. Il
    ne réutilise aucun prédicat du moteur optimisé ni du vérificateur.

    vue_reference(+K, +Graphe, +Requete, -Vue)     vue(Certifiables, Contradictoires, NonCertifiees, Fausses)
    statut_reference(+K, +Graphe, +Requete, -Statut)
*/
:- module(satisfaction_reference, [ vue_reference/4, statut_reference/4 ]).
:- encoding(utf8).
:- use_module(library(lists)).
:- use_module(library(apply)).
:- use_module(library(pairs)).

statut_reference(K, G, Q, St) :-
    vue_reference(K, G, Q, vue(Cert, Cs, NCs, Fs)),
    (   memberchk(cert(vraie, _, _), Cert) -> St = etablie
    ;   Cert \== [] -> St = etablie_sous_hypotheses
    ;   Cs \== [] -> St = contradictoire
    ;   NCs \== [] -> St = non_certifiee
    ;   Fs \== [] -> St = ecartee
    ;   St = inconnue
    ).

vue_reference(K, G, requete(_, F), vue(Cert, Cmin, NCmin, Fmin)) :-
    vars_formule(F, Vs),
    findall(cert(Cl, S, Sel), ( selection(F, [], Sel0), sort(Sel0, Sel), vars_atomes(Sel, VsS),
                                totale(G, F, VsS, S0), sort(S0, S), certifiable(K, G, Sel, S, Cl) ), Cert0),
    sort(Cert0, Cert),
    findall(S-V, ( partielle(G, F, Vs, S0), sort(S0, S), ancree(K, G, F, S), valeur(K, G, F, S, V) ), SVs),
    findall(S, member(S-(1-1), SVs), Cs), minimales(Cs, Cmin),
    findall(S, ( member(S-(1-0), SVs), \+ ( member(cert(_, S2, _), Cert), inclus(S2, S) ) ), NCs), minimales(NCs, NCmin),
    findall(S, member(S-(0-1), SVs), Fs), minimales(Fs, Fmin).

% --- Formules, sélections, variables ---------------------------------------------------------------------------------

atome(type(_, _)). atome(nom(_, _)). atome(propriete(_, _)). atome(evenement(_, _)). atome(role(_, _, _)).
atome(relation(_, _, _)). atome(genre(_)).
contrainte(meme(_, _)). contrainte(distincts(_, _)). contrainte(nombre(_, _)).

feuilles(et(Fs), Ls) :- !, maplist(feuilles, Fs, Lss), append(Lss, Ls).
feuilles(ou(Fs), Ls) :- !, maplist(feuilles, Fs, Lss), append(Lss, Ls).
feuilles(L, [L]).

selection(et(Fs), C, Sel) :- !, selections_et(Fs, C, 1, Sel).
selection(ou(Fs), C, Sel) :- !, nth1(I, Fs, F), append(C, [I], C1), selection(F, C1, Sel).
selection(A, C, [C-A]).
selections_et([], _, _, []).
selections_et([F|Fs], C, I, Sel) :-
    append(C, [I], C1), selection(F, C1, S1), I1 is I + 1, selections_et(Fs, C, I1, S2), append(S1, S2, Sel).

sous_terme(v(N), v(N)) :- !.
sous_terme(T, V) :- compound(T), T =.. [_|As], member(A, As), sous_terme(A, V).
vars_formule(F, Vs) :- findall(V, ( feuilles(F, Ls), member(L, Ls), sous_terme(L, V) ), Vs0), sort(Vs0, Vs).
vars_atomes(Sel, Vs) :- findall(V, ( member(_-A, Sel), atome(A), sous_terme(A, V) ), Vs0), sort(Vs0, Vs).

evenementielle(F, V) :- feuilles(F, Ls), member(A, Ls), ( A = evenement(V0, _) ; A = role(V0, _, _) ), V0 == V, !.
domaine(G, F, V, X) :-
    (   evenementielle(F, V) -> setof(E, P^Pa^member(evenement(E, P, Pa), G), Es), member(X, Es)
    ;   setof(R, representant_de(G, R), Rs), member(X, Rs)
    ).
totale(_, _, [], []).
totale(G, F, [V|Vs], [V-X|S]) :- domaine(G, F, V, X), totale(G, F, Vs, S).
partielle(_, _, [], []).
partielle(G, F, [_|Vs], S) :- partielle(G, F, Vs, S).
partielle(G, F, [V|Vs], [V-X|S]) :- domaine(G, F, V, X), partielle(G, F, Vs, S).

val(S, V, X) :- memberchk(V-X, S).
lies(A, S) :- forall(sous_terme(A, V), memberchk(V-_, S)).
inclus(A, B) :- forall(member(X, A), memberchk(X, B)).
minimales(Ss0, Ms) :- sort(Ss0, Ss), findall(S, ( member(S, Ss), \+ ( member(T, Ss), T \== S, inclus(T, S) ) ), Ms).

% chaque variable liée est ancrée par un atome de la formule, entièrement lié, qui a un appui sous S
ancree(K, G, F, S) :-
    feuilles(F, Ls),
    forall(member(V-_, S), ( member(A, Ls), atome(A), sous_terme(A, V), lies(A, S), once(appui(K, G, S, A, _, _)) )).

% --- Les classes de coréférence ----------------------------------------------------------------------------------

composante(_, [], C, C).
composante(G, [X|Xs], Vus, C) :-
    findall(Y, ( ( member(coref(X, Y), G) ; member(coref(Y, X), G) ), \+ memberchk(Y, Vus) ), Ys0), sort(Ys0, Ys),
    append(Vus, Ys, Vus1), append(Xs, Ys, Xs1), composante(G, Xs1, Vus1, C).
representant_de(G, R) :- member(entite(R, _, _), G), composante(G, [R], [R], C), min_member(R, C).
dans_la_classe(G, E, R) :- composante(G, [R], [R], C), memberchk(E, C).

% --- Les états, d'après le § 1 -------------------------------------------------------------------------------------

qualifie(G, A, Pol, Ctx, Q) :-
    memberchk(polarite(A, Pol), G), memberchk(modalite(A, affirme), G), memberchk(portee(A, Ctx), G),
    memberchk(enonciateur(A, Q), G), \+ ( member(alternative(_, As), G), memberchk(A, As) ).
present(G, E) :- qualifie(G, E, pos, represente, _), !.

% --- Les liens, d'après le § 2 -------------------------------------------------------------------------------------

monte(K, Rel, C, Mot, T) :- K:sens(C, Mot, S0), atteint(K, Rel, S0, T, [S0]), !.
atteint(_, _, S, T, _) :- S == T, !.
atteint(K, Rel, S, T, Vus) :- etape(K, Rel, S, S1), \+ memberchk(S1, Vus), atteint(K, Rel, S1, T, [S1|Vus]).
etape(K, sous, S, S1) :- K:sous(S, S1).
etape(K, inclus, S, S1) :- K:inclus(S, S1).
positif(K, C, W, T) :- monte(K, sous, C, W, T).
negatif(K, C, T, W) :- K:sens(C, W, Sw), K:sens(C, T, St), atteint(K, inclus, St, Sw, [St]), !.
nomme(K, Nom, Ks) :- K:cle_de_nom(Nom, C), ( memberchk(C, Ks) -> true ; member(Ka, Ks), ( K:alias(C, Ka) ; K:alias(Ka, C) ) ), !.

% appui(K, G, S, Atome, Signe, Enonciateur) : un appui de ce signe existe pour l'atome entièrement lié sous S
appui(K, G, S, type(X, T), Sg, Q) :-
    val(S, X, R), member(entite(E, W, _), G), W \== nom_propre, dans_la_classe(G, E, R), qualifie(G, E, Sg, represente, Q),
    ( Sg == pos -> positif(K, n, W, T) ; negatif(K, n, T, W) ).
appui(K, G, S, nom(X, Ks), Sg, Q) :-
    val(S, X, R), member(nom(A, E, Nom, _), G), dans_la_classe(G, E, R), qualifie(G, A, Sg, represente, Q),
    present(G, E), nomme(K, Nom, Ks).
appui(K, G, S, propriete(X, P), Sg, Q) :-
    val(S, X, R), member(propriete(A, E, W, _), G), dans_la_classe(G, E, R), qualifie(G, A, Sg, represente, Q),
    present(G, E), ( Sg == pos -> positif(K, a, W, P) ; negatif(K, a, P, W) ).
appui(K, G, S, evenement(X, P), Sg, Q) :-
    val(S, X, V), member(evenement(V, W, _), G), qualifie(G, V, Sg, represente, Q),
    ( Sg == pos -> positif(K, v, W, P) ; negatif(K, v, P, W) ).
appui(_, G, S, role(X, Ro, Y), Sg, Q) :-
    val(S, X, V), val(S, Y, R), member(role(V, Ro, E), G), dans_la_classe(G, E, R), member(evenement(V, _, _), G),
    qualifie(G, V, Sg, represente, Q), present(G, E).
appui(K, G, S, relation(X, Re, Y), Sg, Q) :-
    val(S, X, R1), val(S, Y, R2), member(relation(A, E1, W, E2, _), G), dans_la_classe(G, E1, R1),
    dans_la_classe(G, E2, R2), qualifie(G, A, Sg, represente, Q), present(G, E1), present(G, E2),
    ( Sg == pos -> positif(K, r, W, Re) ; negatif(K, r, Re, W) ).
appui(K, G, _, genre(T), Sg, Q) :-
    member(entite(E, W, _), G), W \== nom_propre, qualifie(G, E, Sg, oeuvre, Q),
    ( Sg == pos -> positif(K, n, W, T) ; negatif(K, n, T, W) ).

% --- Les contraintes, d'après le § 4.1 ----------------------------------------------------------------------------

% v | h | f | i
contrainte_val(K, G, S, meme(X, Y), V) :-
    val(S, X, A), val(S, Y, B),
    ( A == B -> V = v ; distinctes(K, G, A, B, D), D \== supposee -> V = f ; V = i ).
contrainte_val(K, G, S, distincts(X, Y), V) :-
    val(S, X, A), val(S, Y, B),
    ( A == B -> V = i ; distinctes(K, G, A, B, D) -> ( D == supposee -> V = h ; V = v ) ; V = i ).
contrainte_val(_, G, S, nombre(X, N), V) :-
    val(S, X, R),
    (   member(nombre(E, N), G), dans_la_classe(G, E, R) -> V = v
    ;   member(nombre(E, M), G), M \== N, dans_la_classe(G, E, R) -> V = f
    ;   V = i
    ).

distinctes(_, G, A, B, etablie) :-
    member(distinct(E1, E2), G), ( dans_la_classe(G, E1, A), dans_la_classe(G, E2, B) ; dans_la_classe(G, E1, B),
    dans_la_classe(G, E2, A) ), !.
distinctes(K, G, A, B, documentaire) :-
    noms(K, G, A, N1), noms(K, G, B, N2), member(C1, N1), member(C2, N2),
    ( K:distincts_documentes(C1, C2, _) ; K:distincts_documentes(C2, C1, _) ), !.
distinctes(K, G, A, B, supposee) :-
    noms(K, G, A, N1), N1 \== [], noms(K, G, B, N2), N2 \== [],
    \+ ( member(C1, N1), member(C2, N2), ( C1 == C2 ; K:alias(C1, C2) ; K:alias(C2, C1) ) ).
noms(K, G, R, Ns) :-
    findall(C, ( member(nom(A, E, Nom, _), G), dans_la_classe(G, E, R), qualifie(G, A, pos, represente, _),
                 K:cle_de_nom(Nom, C) ), Ns0), sort(Ns0, Ns).

% --- La valeur de Belnap, d'après le § 4.2 ------------------------------------------------------------------------

valeur(K, G, et(Fs), S, P-N) :- !,
    valeurs(Fs, K, G, S, Vs), pairs_keys_values(Vs, Ps, Ns),
    ( memberchk(0, Ps) -> P = 0 ; P = 1 ), ( memberchk(1, Ns) -> N = 1 ; N = 0 ).
valeur(K, G, ou(Fs), S, P-N) :- !,
    valeurs(Fs, K, G, S, Vs), pairs_keys_values(Vs, Ps, Ns),
    ( memberchk(1, Ps) -> P = 1 ; P = 0 ), ( memberchk(0, Ns) -> N = 0 ; N = 1 ).
valeur(K, G, C, S, V) :- contrainte(C), !,
    ( lies(C, S), contrainte_val(K, G, S, C, X) -> ( memberchk(X, [v, h]) -> V = 1-0 ; X == f -> V = 0-1 ; V = 0-0 ) ; V = 0-0 ).
valeur(K, G, A, S, P-N) :-
    (   lies(A, S)
    ->  ( once(appui(K, G, S, A, pos, _)) -> P = 1 ; P = 0 ), ( once(appui(K, G, S, A, neg, _)) -> N = 1 ; N = 0 )
    ;   P = 0, N = 0
    ).

valeurs([], _, _, _, []).
valeurs([F|Fs], K, G, S, [V|Vs]) :- valeur(K, G, F, S, V), valeurs(Fs, K, G, S, Vs).

% --- La certification, d'après le § 4.3 ---------------------------------------------------------------------------

certifiable(K, G, Sel, S, Cl) :-
    forall(( member(_-A, Sel), atome(A) ), ( once(appui(K, G, S, A, pos, auteur)), \+ appui(K, G, S, A, neg, _) )),
    forall(( member(_-C, Sel), contrainte(C) ), ( lies(C, S), contrainte_val(K, G, S, C, X), memberchk(X, [v, h]) )),
    findall(H, ( member(_-distincts(X, Y), Sel), contrainte_val(K, G, S, distincts(X, Y), h), val(S, X, A), val(S, Y, B),
                 noms(K, G, A, N1), noms(K, G, B, N2), H = distinction_supposee(X, Y, N1, N2) ), Hs0), sort(Hs0, Hs),
    ( Hs == [] -> Cl = vraie ; Cl = sous_hypotheses(Hs) ).
