/*  Le moteur de référence du noyau (docs/NOYAU.md, version 0.3, § 4 et 7) : la sémantique écrite le plus simplement
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
present_auteur(G, E) :- qualifie(G, E, pos, represente, auteur), !.
% l'énonciateur d'un appui positif : l'auteur seulement si l'assertion et chacun de ses porteurs sont de l'auteur
source(G, Q0, Es, Q) :-
    (   Q0 == auteur, member(E, Es), \+ present_auteur(G, E) -> once(qualifie(G, E, pos, represente, Q))
    ;   Q = Q0
    ).
% rien n'est dit d'une entité niée que son type (§ 1)
seule_le_type(G, E) :-
    \+ member(nom(_, E, _, _), G), \+ member(propriete(_, E, _, _), G), \+ member(relation(_, E, _, _, _), G),
    \+ member(relation(_, _, _, E, _), G), \+ member(role(_, _, E), G), \+ member(nombre(E, _), G),
    \+ member(distinct(E, _), G), \+ member(distinct(_, E), G).

% --- Les liens, d'après le § 2 -------------------------------------------------------------------------------------

monte(K, Rel, C, Mot, T) :- K:sens(C, Mot, S0), atteint(K, Rel, S0, T, [S0]), !.
% T est atteint depuis S : l'ensemble des nœuds atteignables, chacun vu une fois (pas d'énumération des chemins)
atteint(K, Rel, S, T, _) :- clos(K, Rel, [S], [S], Ns), memberchk(T, Ns).
clos(K, Rel, Front, Vus, Ns) :-
    findall(Y, ( member(X, Front), etape(K, Rel, X, Y), \+ memberchk(Y, Vus) ), Ys0), sort(Ys0, Ys),
    ( Ys == [] -> Ns = Vus ; append(Vus, Ys, Vus1), clos(K, Rel, Ys, Vus1, Ns) ).
etape(K, sous, S, S1) :- K:sous(S, S1).
etape(K, inclus, S, S1) :- K:inclus(S, S1).
positif(K, C, W, T) :- monte(K, sous, C, W, T).
negatif(K, C, T, W) :- K:sens(C, W, Sw), depart(K, C, T, St), atteint(K, inclus, St, Sw, [St]), !.
depart(_, _, T, T) :- integer(T).
depart(K, C, T, St) :- atom(T), K:sens(C, T, St).
nomme(K, Nom, Ks) :- K:cle_de_nom(Nom, C), member(Ka, Ks), meme_cle(K, C, Ka), !.
% l'égalité des clés, aux alias près, fermés (réflexif, symétrique, transitif)
meme_cle(K, A, B) :- fermeture_alias(K, [A], Cs), memberchk(B, Cs).
fermeture_alias(K, Cs0, Cs) :-
    findall(Y, ( member(X, Cs0), ( K:alias(X, Y) ; K:alias(Y, X) ), \+ memberchk(Y, Cs0) ), Ys0), sort(Ys0, Ys),
    ( Ys == [] -> Cs = Cs0 ; append(Cs0, Ys, Cs1), fermeture_alias(K, Cs1, Cs) ).

% appui(K, G, S, Atome, Signe, Enonciateur) : un appui de ce signe existe pour l'atome entièrement lié sous S
appui(K, G, S, type(X, T), pos, Q) :-
    val(S, X, R), member(entite(E, W, _), G), W \== nom_propre, dans_la_classe(G, E, R), qualifie(G, E, pos, represente, Q),
    positif(K, n, W, T).
% une entité niée dont seul le type est dit : si un membre de sa classe est présent, elle dit que ce référent n'est pas
% un W ; sinon, qu'aucun W n'est figuré, et elle vaut contre tout référent
appui(K, G, S, type(X, T), neg, Q) :-
    val(S, X, R), member(entite(E, W, _), G), W \== nom_propre, qualifie(G, E, neg, represente, Q),
    seule_le_type(G, E), negatif(K, n, T, W),
    composante(G, [E], [E], C), ( member(E2, C), present(G, E2) -> memberchk(R, C) ; C == [E] ).
appui(K, G, S, nom(X, Ks), pos, Q) :-
    val(S, X, R), member(nom(A, E, Nom, _), G), dans_la_classe(G, E, R), qualifie(G, A, pos, represente, Q0),
    present(G, E), nomme(K, Nom, Ks), source(G, Q0, [E], Q).
appui(K, G, S, nom(X, Ks), neg, Q) :-                  % « l'un de ces noms » n'est nié que si chacun l'est
    val(S, X, R), Ks = [K1|Kr], nom_nie(K, G, R, K1, Q), forall(member(Ki, Kr), nom_nie(K, G, R, Ki, _)).
appui(K, G, S, propriete(X, P), Sg, Q) :-
    val(S, X, R), member(propriete(A, E, W, _), G), dans_la_classe(G, E, R), qualifie(G, A, Sg, represente, Q0),
    present(G, E), ( Sg == pos -> positif(K, a, W, P), source(G, Q0, [E], Q) ; negatif(K, a, P, W), Q = Q0 ).
appui(K, G, S, evenement(X, P), pos, Q) :-
    val(S, X, V), member(evenement(V, W, _), G), qualifie(G, V, pos, represente, Q), positif(K, v, W, P).
% un événement nié (prédicat W, rôles) : contre un autre événement présent qui a ces rôles vers les mêmes référents
appui(K, G, S, evenement(X, P), neg, Q) :-
    val(S, X, V), member(evenement(V, _, _), G), qualifie(G, V, pos, represente, _),
    member(evenement(N, W, _), G), N \== V, qualifie(G, N, neg, represente, Q), negatif(K, v, P, W),
    forall(member(role(N, Ro, E), G),
           ( present(G, E), member(role(V, Ro, E2), G), composante(G, [E], [E], C), memberchk(E2, C) )).
appui(_, G, S, role(X, Ro, Y), pos, Q) :-
    val(S, X, V), val(S, Y, R), member(role(V, Ro, E), G), dans_la_classe(G, E, R), member(evenement(V, _, _), G),
    qualifie(G, V, pos, represente, Q0), present(G, E), source(G, Q0, [E], Q).
appui(K, G, S, relation(X, Re, Y), Sg, Q) :-
    val(S, X, R1), val(S, Y, R2), member(relation(A, E1, W, E2, _), G), dans_la_classe(G, E1, R1),
    dans_la_classe(G, E2, R2), qualifie(G, A, Sg, represente, Q0), present(G, E1), present(G, E2),
    ( Sg == pos -> positif(K, r, W, Re), source(G, Q0, [E1, E2], Q) ; negatif(K, r, Re, W), Q = Q0 ).
appui(K, G, _, genre(T), Sg, Q) :-
    member(entite(E, W, _), G), W \== nom_propre, qualifie(G, E, Sg, oeuvre, Q),
    ( Sg == pos -> positif(K, n, W, T) ; negatif(K, n, T, W) ).

nom_nie(K, G, R, Ki, Q) :-
    member(nom(A, E, Nom, _), G), dans_la_classe(G, E, R), qualifie(G, A, neg, represente, Q), present(G, E),
    nomme(K, Nom, [Ki]).
% --- Les contraintes, d'après le § 4.1 ----------------------------------------------------------------------------

% v (vraie, certifiable) | h (sous hypothèse) | p (vraie, non certifiable) | b (contradictoire) | f | i
contrainte_val(K, G, S, meme(X, Y), V) :-
    val(S, X, A), val(S, Y, B),
    ( distinctes(K, G, A, B, D), D \== supposee -> Contre = oui ; Contre = non ),
    (   A == B -> ( Contre == oui -> V = b ; V = v )
    ;   Contre == oui -> V = f
    ;   V = i
    ).
contrainte_val(K, G, S, distincts(X, Y), V) :-
    val(S, X, A), val(S, Y, B),
    ( A == B -> V = i ; distinctes(K, G, A, B, D) -> ( D == supposee -> V = h ; V = v ) ; V = i ).
contrainte_val(_, G, S, nombre(X, N), V) :-
    val(S, X, R),
    findall(Q, ( member(nombre(E, N), G), dans_la_classe(G, E, R), qualifie(G, E, pos, represente, Q) ), Pour),
    ( member(nombre(E, Mb), G), Mb \== N, dans_la_classe(G, E, R), present(G, E) -> Contre = oui ; Contre = non ),
    (   Pour == [] -> ( Contre == oui -> V = f ; V = i )
    ;   Contre == oui -> V = b
    ;   memberchk(auteur, Pour) -> V = v
    ;   V = p
    ).

distinctes(_, G, A, B, etablie) :-
    member(distinct(E1, E2), G), ( dans_la_classe(G, E1, A), dans_la_classe(G, E2, B) ; dans_la_classe(G, E1, B),
    dans_la_classe(G, E2, A) ), present_auteur(G, E1), present_auteur(G, E2), !.
distinctes(K, G, A, B, documentaire) :-
    noms_surs(K, G, A, N1), noms_surs(K, G, B, N2), member(C1, N1), member(C2, N2),
    ( K:distincts_documentes(C1, C2, _) ; K:distincts_documentes(C2, C1, _) ),
    portes(K, G, A, T1), portes(K, G, B, T2),
    \+ ( member(T, T2), meme_cle(K, C1, T) ), \+ ( member(T, T1), meme_cle(K, C2, T) ), !.
distinctes(K, G, A, B, supposee) :-
    noms(K, G, A, N1), N1 \== [], noms(K, G, B, N2), N2 \== [],
    \+ ( member(C1, N1), member(C2, N2), meme_cle(K, C1, C2) ).
% les noms d'une classe sur lesquels une distinction documentaire peut reposer : de l'auteur, d'un porteur présent selon
% l'auteur, et qu'aucune assertion niée de la classe ne contredit
noms_surs(K, G, R, Ns) :-
    findall(C, ( member(nom(A, E, Nom, _), G), dans_la_classe(G, E, R), qualifie(G, A, pos, represente, auteur),
                 present_auteur(G, E), K:cle_de_nom(Nom, C), \+ cle_niee(K, G, R, C) ), Ns0),
    sort(Ns0, Ns).
noms(K, G, R, Ns) :-
    findall(C, ( member(nom(A, E, Nom, _), G), dans_la_classe(G, E, R), qualifie(G, A, pos, represente, _),
                 present(G, E), K:cle_de_nom(Nom, C), \+ cle_niee(K, G, R, C) ), Ns0), sort(Ns0, Ns).
portes(K, G, R, Ns) :-
    findall(C, ( member(nom(A, E, Nom, _), G), dans_la_classe(G, E, R), memberchk(polarite(A, pos), G),
                 K:cle_de_nom(Nom, C) ), Ns0), sort(Ns0, Ns).
cle_niee(K, G, R, C) :-
    member(nom(A, E, Nom, _), G), dans_la_classe(G, E, R), qualifie(G, A, neg, represente, _), K:cle_de_nom(Nom, C2),
    meme_cle(K, C, C2), !.

% --- La valeur de Belnap, d'après le § 4.2 ------------------------------------------------------------------------

valeur(K, G, et(Fs), S, P-N) :- !,
    valeurs(Fs, K, G, S, Vs), pairs_keys_values(Vs, Ps, Ns),
    ( memberchk(0, Ps) -> P = 0 ; P = 1 ), ( memberchk(1, Ns) -> N = 1 ; N = 0 ).
valeur(K, G, ou(Fs), S, P-N) :- !,
    valeurs(Fs, K, G, S, Vs), pairs_keys_values(Vs, Ps, Ns),
    ( memberchk(1, Ps) -> P = 1 ; P = 0 ), ( memberchk(0, Ns) -> N = 0 ; N = 1 ).
valeur(K, G, C, S, V) :- contrainte(C), !,
    ( lies(C, S), contrainte_val(K, G, S, C, X) -> paire(X, V) ; V = 0-0 ).
valeur(K, G, A, S, P-N) :-
    (   lies(A, S)
    ->  ( once(appui(K, G, S, A, pos, _)) -> P = 1 ; P = 0 ), ( once(appui(K, G, S, A, neg, _)) -> N = 1 ; N = 0 )
    ;   P = 0, N = 0
    ).

paire(v, 1-0). paire(h, 1-0). paire(p, 1-0). paire(b, 1-1). paire(f, 0-1). paire(i, 0-0).

valeurs([], _, _, _, []).
valeurs([F|Fs], K, G, S, [V|Vs]) :- valeur(K, G, F, S, V), valeurs(Fs, K, G, S, Vs).

% --- La certification, d'après le § 4.3 ---------------------------------------------------------------------------

% un appui positif de l'auteur dont l'assertion, prise avec son propre mot, n'a aucun appui négatif
premisse_non_niee(K, G, S, A) :- appui(K, G, S, A, pos, auteur), mot_de_l_appui(K, G, S, A, B), \+ appui(K, G, S, B, neg, _).
mot_de_l_appui(K, G, S, type(X, T), type(X, W)) :-
    val(S, X, R), member(entite(E, W, _), G), W \== nom_propre, dans_la_classe(G, E, R),
    qualifie(G, E, pos, represente, auteur), positif(K, n, W, T).
mot_de_l_appui(K, G, S, nom(X, Ks), nom(X, [C])) :-
    val(S, X, R), member(nom(A, E, Nom, _), G), dans_la_classe(G, E, R), qualifie(G, A, pos, represente, auteur),
    present_auteur(G, E), nomme(K, Nom, Ks), K:cle_de_nom(Nom, C).
mot_de_l_appui(K, G, S, propriete(X, P), propriete(X, W)) :-
    val(S, X, R), member(propriete(A, E, W, _), G), dans_la_classe(G, E, R), qualifie(G, A, pos, represente, auteur),
    present_auteur(G, E), positif(K, a, W, P).
mot_de_l_appui(K, G, S, evenement(X, P), evenement(X, W)) :-
    val(S, X, V), member(evenement(V, W, _), G), qualifie(G, V, pos, represente, auteur), positif(K, v, W, P).
mot_de_l_appui(K, G, S, role(X, Ro, Y), role(X, Ro, Y)) :- appui(K, G, S, role(X, Ro, Y), pos, auteur).
mot_de_l_appui(K, G, S, relation(X, Re, Y), relation(X, W, Y)) :-
    val(S, X, R1), val(S, Y, R2), member(relation(A, E1, W, E2, _), G), dans_la_classe(G, E1, R1),
    dans_la_classe(G, E2, R2), qualifie(G, A, pos, represente, auteur), present_auteur(G, E1), present_auteur(G, E2),
    positif(K, r, W, Re).
mot_de_l_appui(K, G, _, genre(T), genre(W)) :-
    member(entite(E, W, _), G), W \== nom_propre, qualifie(G, E, pos, oeuvre, auteur), positif(K, n, W, T).

certifiable(K, G, Sel, S, Cl) :-
    forall(( member(_-A, Sel), atome(A) ), ( \+ appui(K, G, S, A, neg, _), once(premisse_non_niee(K, G, S, A)) )),
    forall(( member(_-C, Sel), contrainte(C) ), ( lies(C, S), contrainte_val(K, G, S, C, X), memberchk(X, [v, h]) )),
    findall(H, ( member(_-distincts(X, Y), Sel), contrainte_val(K, G, S, distincts(X, Y), h), val(S, X, A), val(S, Y, B),
                 noms(K, G, A, N1), noms(K, G, B, N2), H = distinction_supposee(X, Y, N1, N2) ), Hs0), sort(Hs0, Hs),
    ( Hs == [] -> Cl = vraie ; Cl = sous_hypotheses(Hs) ).
