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
    forall(member(V-_, S), ( member(A, Ls), atome(A), sous_terme(A, V), lies(A, S),
                             once(( member(Sg, [pos, neg]), appui(K, G, S, A, Sg, _) )) )).   % negp n'ancre rien (D30)

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

% D30 : les sens conceptuels d'un mot (ses identifiants de concepts, entiers, s'il en a ; sinon ses sens)
conceptuels(K, C, W, Ss) :-
    findall(S, K:sens(C, W, S), Ss0), sort(Ss0, Ss1), include(integer, Ss1, Is), ( Is == [] -> Ss = Ss1 ; Ss = Is ).
noeuds(_, _, T, [T]) :- integer(T), !.
noeuds(K, C, T, Ns) :- conceptuels(K, C, T, Ns).
monte(K, Rel, C, Mot, T) :- conceptuels(K, C, Mot, Ss), member(S0, Ss), atteint(K, Rel, S0, T, [S0]), !.
% T est atteint depuis S : l'ensemble des nœuds atteignables, chacun vu une fois (pas d'énumération des chemins)
atteint(K, Rel, S, T, _) :- clos(K, Rel, [S], [S], Ns), memberchk(T, Ns).
clos(K, Rel, Front, Vus, Ns) :-
    findall(Y, ( member(X, Front), etape(K, Rel, X, Y), \+ memberchk(Y, Vus) ), Ys0), sort(Ys0, Ys),
    ( Ys == [] -> Ns = Vus ; append(Vus, Ys, Vus1), clos(K, Rel, Ys, Vus1, Ns) ).
etape(K, sous, S, S1) :- K:sous(S, S1).
etape(K, inclus, S, S1) :- K:inclus(S, S1).
positif(K, C, W, T) :- monte(K, sous, C, W, T).
positif_certain(K, C, W, T) :- conceptuels(K, C, W, Ss), Ss \== [], forall(member(S, Ss), atteint(K, sous, S, T, [S])).
% négation certaine : chaque nœud du type demandé inclus dans chaque sens du mot nié ; possible : pour un couple
negatif(K, C, T, W) :-
    noeuds(K, C, T, Ns), Ns \== [], conceptuels(K, C, W, Ws), Ws \== [],
    forall(( member(N, Ns), member(Sw, Ws) ), atteint(K, inclus, N, Sw, [N])).
negatif_possible(K, C, T, W) :-
    noeuds(K, C, T, Ns), conceptuels(K, C, W, Ws), member(N, Ns), member(Sw, Ws), atteint(K, inclus, N, Sw, [N]), !,
    \+ negatif(K, C, T, W).
negatif_mode(certain, K, C, T, W) :- negatif(K, C, T, W).
negatif_mode(possible, K, C, T, W) :- negatif_possible(K, C, T, W).
nomme(K, Nom, Ks) :- K:cle_de_nom(Nom, C), member(Ka, Ks), meme_cle(K, C, Ka), !.
% l'égalité des clés, aux alias près, fermés (réflexif, symétrique, transitif)
meme_cle(K, A, B) :- fermeture_alias(K, [A], Cs), memberchk(B, Cs).
fermeture_alias(K, Cs0, Cs) :-
    findall(Y, ( member(X, Cs0), ( K:alias(X, Y) ; K:alias(Y, X) ), \+ memberchk(Y, Cs0) ), Ys0), sort(Ys0, Ys),
    ( Ys == [] -> Cs = Cs0 ; append(Cs0, Ys, Cs1), fermeture_alias(K, Cs1, Cs) ).

% appui(K, G, S, Atome, Signe, Enonciateur) : un appui de ce signe existe pour l'atome entièrement lié sous S ; Signe :
% pos, neg (négation certaine, valable pour chaque sens : D30) ou negp (négation seulement possible, pour un sens)
appui(K, G, S, A, Sg, Q) :- Sg \== negp, appui_l(certain, K, G, S, A, Sg, Q).
appui(K, G, S, A, negp, Q) :- A \= nom(_, _), appui_l(possible, K, G, S, A, neg, Q).
appui_l(_, K, G, S, type(X, T), pos, Q) :-
    val(S, X, R), member(entite(E, W, _), G), W \== nom_propre, dans_la_classe(G, E, R), qualifie(G, E, pos, represente, Q),
    positif(K, n, W, T).
% une entité niée dont seul le type est dit : si un membre de sa classe est présent, elle dit que ce référent n'est pas
% un W ; sinon, qu'aucun W n'est figuré, et elle vaut contre tout référent
appui_l(Mode, K, G, S, type(X, T), neg, Q) :-
    val(S, X, R), member(entite(E, W, _), G), W \== nom_propre, qualifie(G, E, neg, represente, Q),
    seule_le_type(G, E), negatif_mode(Mode, K, n, T, W),
    composante(G, [E], [E], C), ( member(E2, C), present(G, E2) -> memberchk(R, C) ; C == [E] ).
appui_l(_, K, G, S, nom(X, Ks), pos, Q) :-
    val(S, X, R), member(nom(A, E, Nom, _), G), dans_la_classe(G, E, R), qualifie(G, A, pos, represente, Q0),
    present(G, E), nomme(K, Nom, Ks), source(G, Q0, [E], Q).
appui_l(_, K, G, S, nom(X, Ks), neg, Q) :-                  % « l'un de ces noms » n'est nié que si chacun l'est
    val(S, X, R), Ks = [K1|Kr], nom_nie(K, G, R, K1, Q), forall(member(Ki, Kr), nom_nie(K, G, R, Ki, _)).
appui_l(Mode, K, G, S, propriete(X, P), Sg, Q) :-
    val(S, X, R), member(propriete(A, E, W, _), G), dans_la_classe(G, E, R), qualifie(G, A, Sg, represente, Q0),
    present(G, E), ( Sg == pos -> positif(K, a, W, P), source(G, Q0, [E], Q) ; negatif_mode(Mode, K, a, P, W), Q = Q0 ).
appui_l(_, K, G, S, evenement(X, P), pos, Q) :-
    val(S, X, V), member(evenement(V, W, _), G), qualifie(G, V, pos, represente, Q), positif(K, v, W, P).
% un événement nié (prédicat W, rôles) : contre un autre événement présent qui a ces rôles vers les mêmes référents
appui_l(Mode, K, G, S, evenement(X, P), neg, Q) :-
    val(S, X, V), member(evenement(V, _, _), G), qualifie(G, V, pos, represente, _),
    member(evenement(N, W, _), G), N \== V, qualifie(G, N, neg, represente, Q), negatif_mode(Mode, K, v, P, W),
    forall(member(role(N, Ro, E), G),
           ( present(G, E), member(role(V, Ro, E2), G), composante(G, [E], [E], C), memberchk(E2, C) )).
appui_l(_, _, G, S, role(X, Ro, Y), pos, Q) :-
    val(S, X, V), val(S, Y, R), member(role(V, Ro, E), G), dans_la_classe(G, E, R), member(evenement(V, _, _), G),
    qualifie(G, V, pos, represente, Q0), present(G, E), source(G, Q0, [E], Q).
appui_l(Mode, K, G, S, relation(X, Re, Y), Sg, Q) :-
    val(S, X, R1), val(S, Y, R2), member(relation(A, E1, W, E2, _), G), dans_la_classe(G, E1, R1),
    dans_la_classe(G, E2, R2), qualifie(G, A, Sg, represente, Q0), present(G, E1), present(G, E2),
    ( Sg == pos -> positif(K, r, W, Re), source(G, Q0, [E1, E2], Q) ; negatif_mode(Mode, K, r, Re, W), Q = Q0 ).
appui_l(Mode, K, G, _, genre(T), Sg, Q) :-
    member(entite(E, W, _), G), W \== nom_propre, qualifie(G, E, Sg, oeuvre, Q),
    ( Sg == pos -> positif(K, n, W, T) ; seule_le_type(G, E), negatif_mode(Mode, K, n, T, W) ).

nom_nie(K, G, R, Ki, Q) :-
    member(nom(A, E, Nom, _), G), dans_la_classe(G, E, R), qualifie(G, A, neg, represente, Q), present(G, E),
    nomme(K, Nom, [Ki]).
% --- Les contraintes, d'après le § 4.1 ----------------------------------------------------------------------------

% v (vraie, certifiable) | h (sous hypothèse) | p (vraie, non certifiable) | b (contradictoire) | f | i
contrainte_val(K, G, S, meme(X, Y), V) :-
    val(S, X, A), val(S, Y, B),
    (   distinctes(K, G, A, B, D), D \== supposee -> Contre = oui
    ;   A == B, noms_surs(K, G, A, Ns), member(C1, Ns), member(C2, Ns), K:distincts_documentes(C1, C2, _) -> Contre = oui
    ;   Contre = non
    ),
    (   A == B -> ( Contre == oui -> V = b ; V = v )
    ;   Contre == oui -> V = f
    ;   V = i
    ).
contrainte_val(K, G, S, distincts(X, Y), V) :-
    val(S, X, A), val(S, Y, B),
    (   A == B -> V = i
    ;   member(distinct(E1, E2), G), ( dans_la_classe(G, E1, A), dans_la_classe(G, E2, B) ; dans_la_classe(G, E1, B),
        dans_la_classe(G, E2, A) ), present_auteur(G, E1), present_auteur(G, E2), \+ existence_niee(K, G, E1),
        \+ existence_niee(K, G, E2) -> V = v
    ;   distinctes(K, G, A, B, documentaire) -> V = v
    ;   distinctes(K, G, A, B, supposee) -> V = h
    ;   distinctes(K, G, A, B, etablie) -> V = p
    ;   V = i
    ).
contrainte_val(K, G, S, nombre(X, N), V) :-
    val(S, X, R),
    findall(Q-E, ( member(nombre(E, N), G), dans_la_classe(G, E, R), qualifie(G, E, pos, represente, Q) ), Pour),
    ( member(nombre(E, Mb), G), Mb \== N, dans_la_classe(G, E, R), present(G, E) -> Contre = oui ; Contre = non ),
    (   Pour == [] -> ( Contre == oui -> V = f ; V = i )
    ;   Contre == oui -> V = b
    ;   member(auteur-E, Pour), \+ existence_niee(K, G, E) -> V = v
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
    portes(K, G, A, P1), portes(K, G, B, P2), \+ ( member(C1, P1), member(C2, P2), meme_cle(K, C1, C2) ).
% les noms d'une classe sur lesquels une distinction documentaire peut reposer : de l'auteur, d'un porteur présent selon
% l'auteur, et qu'aucune assertion niée de la classe ne contredit
noms_surs(K, G, R, Ns) :-
    findall(C, ( member(nom(A, E, Nom, _), G), dans_la_classe(G, E, R), qualifie(G, A, pos, represente, auteur),
                 present_auteur(G, E), \+ existence_niee(K, G, E), K:cle_de_nom(Nom, C), \+ cle_niee(K, G, R, C) ), Ns0),
    sort(Ns0, Ns).
noms(K, G, R, Ns) :-
    findall(C, ( member(nom(A, E, Nom, _), G), dans_la_classe(G, E, R), qualifie(G, A, pos, represente, _),
                 present(G, E), K:cle_de_nom(Nom, C), \+ cle_niee(K, G, R, C) ), Ns0), sort(Ns0, Ns).
portes(K, G, R, Ns) :-
    findall(C, ( member(nom(A, E, Nom, _), G), dans_la_classe(G, E, R), memberchk(polarite(A, pos), G),
                 K:cle_de_nom(Nom, C) ), Ns0), sort(Ns0, Ns).
cle_niee(K, G, R, C) :-
    member(nom(A, E, Nom, _), G), dans_la_classe(G, E, R), qualifie(G, A, neg, represente, _), present(G, E),
    K:cle_de_nom(Nom, C2), meme_cle(K, C, C2), !.

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
% les prémisses d'un appui positif de l'auteur : l'assertion reformée avec son propre mot, l'existence de chaque entité
% qu'elle cite (le type de son mot n'est pas nié pour sa classe), et, pour un rôle, son événement ; une seule prémisse
% niée et l'appui ne certifie rien (§ 4.3)
premisse_non_niee(K, G, S, A, B, Es, Vs) :-
    mot_de_l_appui(K, G, S, A, B, Es, Vs), \+ appui(K, G, S, B, neg, _),
    forall(member(E, Es), \+ existence_niee(K, G, E)),
    forall(( member(V, Vs), member(evenement(V, W, _), G) ), \+ appui(K, G, [v('$e')-V], evenement(v('$e'), W), neg, _)).
% les hypothèses d'un appui (D30) : le sens supposé si le lien n'est pas certain ; une négation seulement possible de
% l'atome, de l'assertion avec son mot, de l'existence d'une entité citée, de l'événement d'un rôle
hypotheses_de(K, G, S, A, B, Es, Vs, Hs) :-
    findall(H, hypothese_de(K, G, S, A, B, Es, Vs, H), Hs0), sort(Hs0, Hs).
hypothese_de(K, _, _, A, B, _, _, sens_suppose(W, T)) :-
    mot_du_type(A, C, T), mot_du_type(B, C, W), \+ positif_certain(K, C, W, T).
hypothese_de(K, G, S, A, _, _, _, negation_autre_sens(Ai)) :- appui(K, G, S, A, negp, _), instancie(A, S, Ai).
hypothese_de(K, G, S, _, B, _, _, negation_autre_sens(Bi)) :- appui(K, G, S, B, negp, _), instancie(B, S, Bi).
hypothese_de(K, G, _, _, _, Es, _, negation_autre_sens(type(R, W))) :-
    member(E, Es), member(entite(E, W, _), G), W \== nom_propre, representant_de(G, R), dans_la_classe(G, E, R),
    appui(K, G, [v('$p')-R], type(v('$p'), W), negp, _).
hypothese_de(K, G, _, _, _, _, Vs, negation_autre_sens(evenement(V, W))) :-
    member(V, Vs), member(evenement(V, W, _), G), appui(K, G, [v('$e')-V], evenement(v('$e'), W), negp, _).
mot_du_type(type(_, T), n, T). mot_du_type(genre(T), n, T). mot_du_type(propriete(_, T), a, T).
mot_du_type(evenement(_, T), v, T). mot_du_type(relation(_, T, _), r, T).
instancie(v(N), S, X) :- !, memberchk(v(N)-X, S).
instancie(T, S, Ti) :- compound(T), !, T =.. [F|As], instancies(As, S, Bs), Ti =.. [F|Bs].
instancie(T, _, T).
instancies([], _, []).
instancies([A|As], S, [B|Bs]) :- instancie(A, S, B), instancies(As, S, Bs).
hypotheses_des_atomes([], _, _, _, []).
hypotheses_des_atomes([A|As], K, G, S, [H|Hs]) :-
    \+ appui(K, G, S, A, neg, _), hypotheses_atome(K, G, S, A, H), hypotheses_des_atomes(As, K, G, S, Hs).
% les hypothèses retenues d'un atome : celles de l'appui qui en demande le moins (puis le premier dans l'ordre standard)
hypotheses_atome(K, G, S, A, Hs) :-
    findall((L-Hs0), ( premisse_non_niee(K, G, S, A, B, Es, Vs), une_lecture(K, G, S, A, B),
                       hypotheses_de(K, G, S, A, B, Es, Vs, Hs0), length(Hs0, L) ),
            Ps), Ps \== [], msort(Ps, [_-Hs|_]).
% une lecture au moins : un sens conceptuel du mot de l'appui atteint le type, et l'assertion prise en ce sens n'est pas
% niée de façon certaine (audit final, B3)
une_lecture(K, G, S, A, B) :-
    (   mot_du_type(A, C, T), mot_du_type(B, C, W)
    ->  conceptuels(K, C, W, Ss), member(Sn, Ss), atteint(K, sous, Sn, T, [Sn]), en_ce_sens(B, Sn, Bs),
        \+ appui(K, G, S, Bs, neg, _), !
    ;   true
    ).
en_ce_sens(type(X, _), Sn, type(X, Sn)). en_ce_sens(propriete(X, _), Sn, propriete(X, Sn)).
en_ce_sens(evenement(X, _), Sn, evenement(X, Sn)). en_ce_sens(relation(X, _, Y), Sn, relation(X, Sn, Y)).
en_ce_sens(genre(_), Sn, genre(Sn)).
% les hypothèses d'existence d'une contrainte certifiable (distinction établie, nombre) : celles de la paire ou de
% l'entité qui en demande le moins (audit final, B2)
hypotheses_contrainte(K, G, S, distincts(X, Y), Hs) :-
    val(S, X, A), val(S, Y, B), A \== B,
    findall((L-H)-(E1-E2), ( member(distinct(F1, F2), G),
                             ( dans_la_classe(G, F1, A), dans_la_classe(G, F2, B), E1 = F1, E2 = F2
                             ; dans_la_classe(G, F1, B), dans_la_classe(G, F2, A), E1 = F2, E2 = F1 ),
                             present_auteur(G, E1), present_auteur(G, E2), \+ existence_niee(K, G, E1),
                             \+ existence_niee(K, G, E2), existence_possible(K, G, [E1, E2], H), length(H, L) ), Ps),
    Ps \== [], !, msort(Ps, [(_-Hs)-_|_]).
hypotheses_contrainte(K, G, S, nombre(X, N), Hs) :-
    val(S, X, R),
    findall((L-H)-E, ( member(nombre(E, N), G), dans_la_classe(G, E, R), present_auteur(G, E), \+ existence_niee(K, G, E),
                       existence_possible(K, G, [E], H), length(H, L) ), Ps),
    Ps \== [], !, msort(Ps, [(_-Hs)-_|_]).
hypotheses_contrainte(_, _, _, _, []).
existence_possible(K, G, Es, Hs) :-
    findall(negation_autre_sens(type(R, W)),
            ( member(E, Es), member(entite(E, W, _), G), W \== nom_propre, representant_de(G, R), dans_la_classe(G, E, R),
              appui(K, G, [v('$p')-R], type(v('$p'), W), negp, _) ), Hs0), sort(Hs0, Hs).
existence_niee(K, G, E) :-
    member(entite(E, W, _), G), W \== nom_propre, representant_de(G, R), dans_la_classe(G, E, R),
    appui(K, G, [v('$p')-R], type(v('$p'), W), neg, _), !.
mot_de_l_appui(K, G, S, type(X, T), type(X, W), [E], []) :-
    val(S, X, R), member(entite(E, W, _), G), W \== nom_propre, dans_la_classe(G, E, R),
    qualifie(G, E, pos, represente, auteur), positif(K, n, W, T).
mot_de_l_appui(K, G, S, nom(X, Ks), nom(X, [C]), [E], []) :-
    val(S, X, R), member(nom(A, E, Nom, _), G), dans_la_classe(G, E, R), qualifie(G, A, pos, represente, auteur),
    present_auteur(G, E), nomme(K, Nom, Ks), K:cle_de_nom(Nom, C).
mot_de_l_appui(K, G, S, propriete(X, P), propriete(X, W), [E], []) :-
    val(S, X, R), member(propriete(A, E, W, _), G), dans_la_classe(G, E, R), qualifie(G, A, pos, represente, auteur),
    present_auteur(G, E), positif(K, a, W, P).
mot_de_l_appui(K, G, S, evenement(X, P), evenement(X, W), [], []) :-
    val(S, X, V), member(evenement(V, W, _), G), qualifie(G, V, pos, represente, auteur), positif(K, v, W, P).
mot_de_l_appui(_, G, S, role(X, Ro, Y), role(X, Ro, Y), [E], [V]) :-
    val(S, X, V), val(S, Y, R), member(role(V, Ro, E), G), dans_la_classe(G, E, R), member(evenement(V, _, _), G),
    qualifie(G, V, pos, represente, auteur), present_auteur(G, E).
mot_de_l_appui(K, G, S, relation(X, Re, Y), relation(X, W, Y), [E1, E2], []) :-
    val(S, X, R1), val(S, Y, R2), member(relation(A, E1, W, E2, _), G), dans_la_classe(G, E1, R1),
    dans_la_classe(G, E2, R2), qualifie(G, A, pos, represente, auteur), present_auteur(G, E1), present_auteur(G, E2),
    positif(K, r, W, Re).
mot_de_l_appui(K, G, _, genre(T), genre(W), [], []) :-
    member(entite(E, W, _), G), W \== nom_propre, qualifie(G, E, pos, oeuvre, auteur), positif(K, n, W, T).

certifiable(K, G, Sel, S, Cl) :-
    findall(A, ( member(_-A, Sel), atome(A) ), As),
    hypotheses_des_atomes(As, K, G, S, Hss),
    forall(( member(_-C, Sel), contrainte(C) ), ( lies(C, S), contrainte_val(K, G, S, C, X), memberchk(X, [v, h]) )),
    findall(H, ( member(_-distincts(X, Y), Sel), contrainte_val(K, G, S, distincts(X, Y), h), val(S, X, A), val(S, Y, B),
                 noms(K, G, A, N1), noms(K, G, B, N2), H = distinction_supposee(X, Y, N1, N2) ), Hc),
    findall(H, ( member(_-C, Sel), contrainte(C), contrainte_val(K, G, S, C, v), hypotheses_contrainte(K, G, S, C, Hx),
                 member(H, Hx) ), Hk),
    append([Hc, Hk|Hss], Hs0), sort(Hs0, Hs),
    ( Hs == [] -> Cl = vraie ; Cl = sous_hypotheses(Hs) ).
