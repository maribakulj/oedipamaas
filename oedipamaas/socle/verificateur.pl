/*  Le vérificateur des preuves (docs/NOYAU.md, version 0.2, § 6). Écrit à part du moteur (satisfaction.pl) et du
    moteur de référence, dont il ne réutilise aucun prédicat : il ne partage que la spécification, le graphe, le contrat
    des assertions (assertions.pl) et les primitives de K.

    verifier(+K, +Graphe, +Requete, +Preuve, -Verdict)
        Verdict = accepte | rejete(Raisons)
    Il n'accepte qu'après avoir établi positivement chacun des points du § 6 ; une preuve dont la forme n'est pas
    celle du § 5 est rejetée avant tout examen.
*/
:- module(verificateur, [ verifier/5 ]).
:- encoding(utf8).
:- use_module(library(lists)).
:- use_module(library(apply)).
:- use_module(assertions, [valider/2]).

% la version du noyau pour laquelle ce vérificateur est écrit
version_attendue('noyau 0.2').

verifier(K, G, Q, P, Verdict) :-
    (   \+ assertions:valider(G, [])                    -> Verdict = rejete([graphe_invalide])
    ;   \+ forme_requete(Q)                             -> Verdict = rejete([requete_mal_formee])
    ;   \+ forme_preuve(P)                              -> Verdict = rejete([preuve_mal_formee])
    ;   findall(R, ( controle(Nom, K, G, Q, P), \+ catch(etabli(Nom, K, G, Q, P), _, fail), R = Nom ), Rs),
        ( Rs == [] -> Verdict = accepte ; Verdict = rejete(Rs) )
    ).

controle(N, _, _, _, _) :- member(N, [requete, versions, regime, chemins, selection, sigma, appuis, contraintes,
                                       hypotheses, pas_d_appui_negatif]).

% --- La forme (§ 5) --------------------------------------------------------------------------------------------------

forme_requete(requete(Id, F)) :- atom(Id), formule(F).
formule(et(Fs)) :- !, is_list(Fs), Fs \== [], maplist(formule, Fs).
formule(ou(Fs)) :- !, is_list(Fs), Fs = [_, _|_], maplist(formule, Fs).
formule(F) :- ground(F), ( atome(F) ; contrainte(F) ).
atome(type(v(X), T)) :- atom(X), atom(T).
atome(nom(v(X), Ks)) :- atom(X), is_list(Ks), Ks \== [], maplist(atom, Ks).
atome(propriete(v(X), P)) :- atom(X), atom(P).
atome(evenement(v(X), P)) :- atom(X), atom(P).
atome(role(v(X), R, v(Y))) :- atom(X), atom(R), atom(Y).
atome(relation(v(X), R, v(Y))) :- atom(X), atom(R), atom(Y).
atome(genre(T)) :- atom(T).
contrainte(meme(v(X), v(Y))) :- atom(X), atom(Y).
contrainte(distincts(v(X), v(Y))) :- atom(X), atom(Y).
contrainte(nombre(v(X), N)) :- atom(X), integer(N), N >= 1.

forme_preuve(P) :-
    ground(P), P = preuve(Id, Vs, Rg, S, Js, Hs), atom(Id),
    is_list(Vs), atom(Rg), is_list(S), is_list(Js), Js \== [], is_list(Hs),
    forall(member(X, S), ( X = v(N)-Val, atom(N), atom(Val) )),
    forall(member(J, Js), ( J = j(C, A, Ap), is_list(C), forall(member(I, C), ( integer(I), I >= 1 )),
                            ( atome(A) ; contrainte(A) ), forme_appui(A, Ap) )),
    forall(member(H, Hs), ( H = distinction_supposee(v(X), v(Y), N1, N2), atom(X), atom(Y), is_list(N1), is_list(N2) )).
forme_appui(A, appui(_, E, P, _)) :- atome(A), atom(E), atom(P).
forme_appui(A, contrainte(_)) :- contrainte(A).

% --- Les contrôles, chacun établi positivement (§ 6) -----------------------------------------------------------------

etabli(requete, _, _, requete(Id, _), preuve(Id2, _, _, _, _, _)) :- Id2 == Id.
etabli(versions, K, G, _, preuve(_, Vs, _, _, _, _)) :-
    version_attendue(Vn), K:version(Vk), msort(G, Gs), variant_sha1(Gs, H),
    Vs == [noyau(Vn), connaissances(Vk), graphe(H)].
etabli(regime, _, _, requete(_, F), preuve(_, _, Rg, _, _, _)) :-
    findall(A, ( sous_formule(F, A), atome(A) ), As),
    ( forall(member(A, As), A = genre(_)) -> Rg == classement ; Rg == figuration ).
etabli(chemins, _, _, requete(_, F), preuve(_, _, _, _, Js, _)) :-
    findall(C, member(j(C, _, _), Js), Cs), msort(Cs, Ss), sort(Cs, Ss),        % chaque chemin une fois
    forall(member(j(C, A, _), Js), ( position(F, C, A0), A0 == A )).
etabli(selection, _, _, requete(_, F), preuve(_, _, _, _, Js, _)) :-
    findall(C, member(j(C, _, _), Js), Cs), satisfait(F, [], Cs),
    forall(member(C, Cs), dans_la_selection(F, [], C, Cs)).
etabli(sigma, _, G, requete(_, F), preuve(_, _, _, S, Js, _)) :-
    findall(V, member(V-_, S), Ks), msort(Ks, Ks1), sort(Ks, Ks1),            % chaque variable une fois
    findall(V, ( member(j(_, A, _), Js), atome(A), vars(A, Va), member(V, Va) ), Vs0), sort(Vs0, Vs),
    sort(Ks, Vs),                                                             % exactement celles des atomes
    forall(( member(j(_, A, _), Js), contrainte(A), vars(A, Va), member(V, Va) ), memberchk(V, Vs)),
    forall(member(V-X, S), bonne_sorte(G, F, V, X)).
etabli(appuis, K, G, _, preuve(_, _, _, S, Js, _)) :-
    forall(( member(j(_, A, Ap), Js), atome(A) ), appui_positif(K, G, S, A, Ap)).
etabli(contraintes, K, G, _, preuve(_, _, _, S, Js, Hs)) :-
    forall(( member(j(_, Co, contrainte(J)), Js) ), contrainte_justifiee(K, G, S, Hs, Co, J)).
etabli(hypotheses, _, _, _, preuve(_, _, _, _, Js, Hs)) :-
    findall(X-Y, member(j(_, distincts(X, Y), contrainte(hypothese)), Js), Us0), sort(Us0, Us),
    findall(X-Y, member(distinction_supposee(X, Y, _, _), Hs), Hs1), msort(Hs1, Hs2), sort(Hs1, Hs2), Hs2 == Us.
etabli(pas_d_appui_negatif, K, G, _, preuve(_, _, _, S, Js, _)) :-
    \+ ( member(j(_, A, _), Js), atome(A), appui_negatif(K, G, S, A) ).

% --- La formule ------------------------------------------------------------------------------------------------------

sous_formule(F, F).
sous_formule(et(Fs), A) :- member(F, Fs), sous_formule(F, A).
sous_formule(ou(Fs), A) :- member(F, Fs), sous_formule(F, A).

position(F, [], F).
position(et(Fs), [I|Is], A) :- nth1(I, Fs, F), position(F, Is, A).
position(ou(Fs), [I|Is], A) :- nth1(I, Fs, F), position(F, Is, A).

satisfait(et(Fs), C, Cs) :- !, forall(nth1(I, Fs, F), ( append(C, [I], C1), satisfait(F, C1, Cs) )).
satisfait(ou(Fs), C, Cs) :- !, once(( nth1(I, Fs, F), append(C, [I], C1), satisfait(F, C1, Cs) )).
satisfait(_, C, Cs) :- memberchk(C, Cs).

% un chemin justifié n'est pas dans une branche d'un « ou » autre que celle qui est justifiée
dans_la_selection(_, _, [], _) :- !.
dans_la_selection(et(Fs), P, [I|Is], Cs) :- !, nth1(I, Fs, F), append(P, [I], P1), dans_la_selection(F, P1, Is, Cs).
dans_la_selection(ou(Fs), P, [I|Is], Cs) :-
    nth1(I, Fs, F), append(P, [I], P1),
    \+ ( member(C2, Cs), append(P, [J|_], C2), J \== I ),                   % une seule branche du « ou »
    dans_la_selection(F, P1, Is, Cs).

vars(v(N), [v(N)]) :- !.
vars(T, Vs) :- compound(T), !, T =.. [_|As], foldl([A, V0, V]>>( vars(A, Va), append(V0, Va, V) ), As, [], Vs).
vars(_, []).

evenementielle(F, V) :- sous_formule(F, A), ( A = evenement(V0, _) ; A = role(V0, _, _) ), V0 == V, !.
bonne_sorte(G, F, V, X) :-
    (   evenementielle(F, V) -> memberchk(evenement(X, _, _), G)
    ;   memberchk(entite(X, _, _), G), representant(G, X)
    ).

val(S, V, X) :- memberchk(V-X, S).

% --- Le graphe, relu ici ---------------------------------------------------------------------------------------------

meme_classe(G, E, R) :- atteint(G, [E], [E], R).
atteint(_, _, Vus, R) :- memberchk(R, Vus), !.
atteint(G, Front, Vus, R) :-
    findall(Y, ( member(X, Front), ( member(coref(X, Y), G) ; member(coref(Y, X), G) ), \+ memberchk(Y, Vus) ), Ys0),
    sort(Ys0, Ys), Ys \== [], append(Vus, Ys, Vus1), atteint(G, Ys, Vus1, R).
representant(G, R) :- \+ ( member(entite(E, _, _), G), E @< R, meme_classe(G, E, R) ).
membres(G, R, Es) :- findall(E, ( member(entite(E, _, _), G), meme_classe(G, E, R) ), Es0), sort(Es0, Es).

qualifie(G, A, Pol, Ctx, Q) :-
    memberchk(polarite(A, Pol), G), memberchk(modalite(A, affirme), G), memberchk(portee(A, Ctx), G),
    memberchk(enonciateur(A, Q), G), \+ ( member(alternative(_, As), G), memberchk(A, As) ).
present(G, E) :- qualifie(G, E, pos, represente, _).

% un lien positif : sens puis des pas « sous », chemin simple, jusqu'au type demandé
lien_positif(K, Cat, W, T, chemin(W, [S0|Ch])) :- K:sens(Cat, W, S0), pas_sous(K, [S0|Ch], T).
pas_sous(_, [T0], T) :- T0 == T, !.
pas_sous(K, [S, S1|Ch], T) :- K:sous(S, S1), \+ memberchk(S, [S1|Ch]), pas_sous(K, [S1|Ch], T).

nom_valide(K, Nom, Ks, cle(C)) :- K:cle_de_nom(Nom, C), memberchk(C, Ks).
nom_valide(K, Nom, Ks, alias(C, Ka)) :- K:cle_de_nom(Nom, C), memberchk(Ka, Ks), ( K:alias(C, Ka) ; K:alias(Ka, C) ).

% un appui positif cité : il existe, de l'auteur, admissible, conforme à σ, de lien valide
appui_positif(K, G, S, type(X, T), appui(E, E, _, L)) :-
    member(entite(E, W, _), G), W \== nom_propre, val(S, X, R), meme_classe(G, E, R),
    qualifie(G, E, pos, represente, auteur), lien_positif(K, n, W, T, L).
appui_positif(K, G, S, nom(X, Ks), appui(A, E, _, L)) :-
    member(nom(A, E, Nom, _), G), val(S, X, R), meme_classe(G, E, R),
    qualifie(G, A, pos, represente, auteur), present(G, E), nom_valide(K, Nom, Ks, L).
appui_positif(K, G, S, propriete(X, Pr), appui(A, E, _, L)) :-
    member(propriete(A, E, W, _), G), val(S, X, R), meme_classe(G, E, R),
    qualifie(G, A, pos, represente, auteur), present(G, E), lien_positif(K, a, W, Pr, L).
appui_positif(K, G, S, evenement(X, Pr), appui(V, V, _, L)) :-
    val(S, X, V), member(evenement(V, W, _), G), qualifie(G, V, pos, represente, auteur), lien_positif(K, v, W, Pr, L).
appui_positif(_, G, S, role(X, Ro, Y), appui(role(V, Ro, E), E, _, egal)) :-
    val(S, X, V), val(S, Y, R), member(role(V, Ro, E), G), meme_classe(G, E, R),
    qualifie(G, V, pos, represente, auteur), present(G, E).
appui_positif(K, G, S, relation(X, Re, Y), appui(A, E1, _, L)) :-
    member(relation(A, E1, W, E2, _), G), val(S, X, R1), val(S, Y, R2), meme_classe(G, E1, R1), meme_classe(G, E2, R2),
    qualifie(G, A, pos, represente, auteur), present(G, E1), present(G, E2), lien_positif(K, r, W, Re, L).
appui_positif(K, G, _, genre(T), appui(E, E, _, L)) :-
    member(entite(E, W, _), G), W \== nom_propre, qualifie(G, E, pos, oeuvre, auteur), lien_positif(K, n, W, T, L).

% un appui négatif sous σ, de tout énonciateur, cherché dans tout le graphe (lien d'inclusion, dans l'autre sens)
appui_negatif(K, G, S, type(X, T)) :-
    val(S, X, R), member(entite(E, W, _), G), W \== nom_propre, meme_classe(G, E, R),
    qualifie(G, E, neg, represente, _), inclus_lien(K, n, T, W).
appui_negatif(K, G, S, nom(X, Ks)) :-
    val(S, X, R), member(nom(A, E, Nom, _), G), meme_classe(G, E, R), qualifie(G, A, neg, represente, _),
    present(G, E), once(nom_valide(K, Nom, Ks, _)).
appui_negatif(K, G, S, propriete(X, Pr)) :-
    val(S, X, R), member(propriete(A, E, W, _), G), meme_classe(G, E, R), qualifie(G, A, neg, represente, _),
    present(G, E), inclus_lien(K, a, Pr, W).
appui_negatif(K, G, S, evenement(X, Pr)) :-
    val(S, X, V), member(evenement(V, W, _), G), qualifie(G, V, neg, represente, _), inclus_lien(K, v, Pr, W).
appui_negatif(_, G, S, role(X, Ro, Y)) :-
    val(S, X, V), val(S, Y, R), member(role(V, Ro, E), G), meme_classe(G, E, R),
    qualifie(G, V, neg, represente, _), present(G, E).
appui_negatif(K, G, S, relation(X, Re, Y)) :-
    val(S, X, R1), val(S, Y, R2), member(relation(A, E1, W, E2, _), G), meme_classe(G, E1, R1), meme_classe(G, E2, R2),
    qualifie(G, A, neg, represente, _), present(G, E1), present(G, E2), inclus_lien(K, r, Re, W).
appui_negatif(K, G, _, genre(T)) :-
    member(entite(E, W, _), G), W \== nom_propre, qualifie(G, E, neg, oeuvre, _), inclus_lien(K, n, T, W).

% T est inclus dans W : un sens de T monte par « inclus » jusqu'à un sens de W
inclus_lien(K, Cat, T, W) :- K:sens(Cat, T, S0), K:sens(Cat, W, Sn), monte_inclus(K, S0, Sn, [S0]), !.
monte_inclus(_, S, T, _) :- S == T, !.
monte_inclus(K, S, T, Vus) :- K:inclus(S, S1), \+ memberchk(S1, Vus), monte_inclus(K, S1, T, [S1|Vus]).

% --- Les contraintes -------------------------------------------------------------------------------------------------

contrainte_justifiee(_, _, S, _, meme(X, Y), egalite) :- val(S, X, A), val(S, Y, B), A == B.
contrainte_justifiee(_, G, S, _, distincts(X, Y), etablie(distinct(E1, E2))) :-
    val(S, X, A), val(S, Y, B), A \== B, meme_classe(G, E1, A), meme_classe(G, E2, B),
    ( memberchk(distinct(E1, E2), G) ; memberchk(distinct(E2, E1), G) ).
contrainte_justifiee(K, G, S, _, distincts(X, Y), documentaire(C1, C2, Src)) :-
    val(S, X, A), val(S, Y, B), A \== B, noms(K, G, A, N1), noms(K, G, B, N2), memberchk(C1, N1), memberchk(C2, N2),
    ( K:distincts_documentes(C1, C2, Src) ; K:distincts_documentes(C2, C1, Src) ).
contrainte_justifiee(K, G, S, Hs, distincts(X, Y), hypothese) :-
    val(S, X, A), val(S, Y, B), A \== B, memberchk(distinction_supposee(X, Y, N1, N2), Hs),
    noms(K, G, A, N1), noms(K, G, B, N2), N1 \== [], N2 \== [],
    \+ ( member(C1, N1), member(C2, N2), ( C1 == C2 ; K:alias(C1, C2) ; K:alias(C2, C1) ) ).
contrainte_justifiee(_, G, S, _, nombre(X, N), nombre(E)) :-
    val(S, X, R), memberchk(nombre(E, N), G), meme_classe(G, E, R).

noms(K, G, R, Ns) :-
    findall(C, ( member(nom(A, E, Nom, _), G), meme_classe(G, E, R), qualifie(G, A, pos, represente, _),
                 K:cle_de_nom(Nom, C) ), Ns0), sort(Ns0, Ns).
