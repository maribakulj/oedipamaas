/*  Le vérificateur des preuves (docs/NOYAU.md, § 6). Écrit à part du moteur (satisfaction.pl), dont il ne réutilise
    aucun prédicat : il ne partage que la spécification, le graphe, la requête et les primitives de K.

    verifier(+K, +Graphe, +Requete, +Preuve, -Verdict)
        Verdict = accepte | rejete(Raisons)

    Il certifie qu'une conclusion découle de ses prémisses (le graphe, K, la requête) ; il ne dit rien de la justesse
    de la requête, du graphe ni du texte.
*/
:- module(verificateur, [ verifier/5 ]).
:- encoding(utf8).
:- use_module(library(lists)).
:- use_module(library(apply)).

verifier(K, Graphe, requete(Id, F), Preuve, Verdict) :-
    findall(R, raison(K, Graphe, Id, F, Preuve, R), Rs0), sort(Rs0, Rs),
    ( Rs == [] -> Verdict = accepte ; Verdict = rejete(Rs) ).

% --- Les raisons de rejet (une par règle de NOYAU.md, § 6) ----------------------------------------------------------

raison(_, _, _, _, P, forme(P)) :- \+ P = preuve(_, _, _, _, _).
raison(_, _, Id, _, preuve(Id2, _, _, _, _), autre_requete(Id2)) :- Id2 \== Id.
% 1. les versions
raison(K, _, _, _, preuve(_, Vs, _, _, _), versions(Vs)) :-
    \+ ( is_list(Vs), memberchk(connaissances(Vk), Vs), K:version(Vk), memberchk(noyau(Vn), Vs),
         version_attendue(Vn) ).
% 2. la sélection justifiée satisfait la formule
raison(_, _, _, F, preuve(_, _, _, _, Js), selection_insuffisante) :-
    is_list(Js), findall(C, member(j(C, _, _), Js), Cs), \+ satisfait(F, [], Cs).
% 3. chaque chemin désigne l'atome cité, une fois
raison(_, _, _, F, preuve(_, _, _, _, Js), chemin(C, A)) :-
    member(j(C, A, _), Js), \+ ( position(F, C, A0), A0 =@= A ).
raison(_, _, _, _, preuve(_, _, _, _, Js), deux_fois(C)) :-
    findall(C0, member(j(C0, _, _), Js), Cs), msort(Cs, Ss), append(_, [C, C|_], Ss).
% σ lie chaque variable des atomes justifiés, et rien d'autre
raison(_, _, _, _, preuve(_, _, _, S, Js), variable_libre(V)) :-
    member(j(_, A, _), Js), vars(A, Vs), member(V, Vs), \+ memberchk(V-_, S).
% 4 et 5. chaque appui existe, est positif, correspond à σ, et son lien est valide
raison(K, G, _, _, preuve(_, _, _, S, Js), appui(C, Raison)) :-
    member(j(C, A, Ap), Js), \+ contrainte(A), \+ appui_valide(K, G, S, A, Ap, _), appui_raison(K, G, S, A, Ap, Raison).
% 6. chaque contrainte est vraie sous σ
raison(_, G, _, _, preuve(_, _, _, S, Js), contrainte(C, Co)) :-
    member(j(C, Co, J), Js), contrainte(Co), \+ ( J == contrainte, contrainte_vraie(G, S, Co) ).
% 7. aucun atome justifié n'a d'appui négatif sous σ
raison(K, G, _, _, preuve(_, _, _, S, Js), nie(C, Neg)) :-
    member(j(C, A, _), Js), \+ contrainte(A), appui_negatif(K, G, S, A, Neg).

appui_raison(_, _, _, _, Ap, appui_mal_forme(Ap)) :- \+ Ap = appui(_, _, _, _), !.
appui_raison(_, G, _, _, appui(X, _, _, _), inexistant(X)) :- \+ existe(G, X), !.
appui_raison(_, _, _, _, _, ne_prouve_pas).

% la version du noyau pour laquelle ce vérificateur est écrit (docs/NOYAU.md)
version_attendue('noyau 0.1').

contrainte(meme(_, _)).
contrainte(distincts(_, _)).
contrainte(nombre(_, _)).

% --- La formule ------------------------------------------------------------------------------------------------------

satisfait(et(Fs), C, Cs) :- !, forall(nth1(I, Fs, F), ( append(C, [I], C1), satisfait(F, C1, Cs) )).
satisfait(ou(Fs), C, Cs) :- !, nth1(I, Fs, F), append(C, [I], C1), satisfait(F, C1, Cs), !.
satisfait(_, C, Cs) :- memberchk(C, Cs).

position(F, [], F).
position(et(Fs), [I|Is], A) :- nth1(I, Fs, F), position(F, Is, A).
position(ou(Fs), [I|Is], A) :- nth1(I, Fs, F), position(F, Is, A).

vars(v(N), [v(N)]) :- !.
vars(T, Vs) :- compound(T), !, T =.. [_|As], foldl([A, V0, V]>>( vars(A, Va), append(V0, Va, V) ), As, [], Vs).
vars(_, []).

val(S, v(N), X) :- memberchk(v(N)-X, S).

% --- Le graphe, relu ici -------------------------------------------------------------------------------------------

existe(G, role(V, R, E)) :- !, memberchk(role(V, R, E), G).
existe(G, X) :- ( memberchk(entite(X, _, _), G) ; memberchk(nom(X, _, _, _), G) ; memberchk(propriete(X, _, _, _), G)
                ; memberchk(evenement(X, _, _), G) ; memberchk(relation(X, _, _, _, _), G) ), !.

% la même classe de coréférence : E et R sont reliés par une chaîne de coref/2
meme_classe(G, E, R) :- atteint(G, [E], [E], R).
atteint(_, _, Vus, R) :- memberchk(R, Vus), !.
atteint(G, Front, Vus, R) :-
    findall(Y, ( member(X, Front), ( member(coref(X, Y), G) ; member(coref(Y, X), G) ), \+ memberchk(Y, Vus) ), Ys0),
    sort(Ys0, Ys), Ys \== [], append(Vus, Ys, Vus1), atteint(G, Ys, Vus1, R).
% R est bien le représentant de sa classe (le plus petit identifiant)
representant(G, R) :- \+ ( member(entite(E, _, _), G), E @< R, meme_classe(G, E, R) ).

positif(G, A, Ctx) :-
    memberchk(polarite(A, pos), G), memberchk(modalite(A, affirme), G), memberchk(enonciateur(A, auteur), G),
    memberchk(portee(A, Ctx), G), \+ ( member(alternative(_, As), G), memberchk(A, As) ).
negatif(G, A, Ctx) :- memberchk(polarite(A, neg), G), memberchk(modalite(A, affirme), G), memberchk(portee(A, Ctx), G).

% un lien : chaque pas est une primitive de K
lien_valide(K, Cat, W, T, chemin(W, [S0|Ch])) :- K:sens(Cat, W, S0), pas(K, [S0|Ch], T).
pas(_, [T], T0) :- T == T0, !.
pas(K, [S, S1|Ch], T) :- K:sous(S, S1), pas(K, [S1|Ch], T).
nom_valide(K, Nom, Ks, cle(C)) :- K:cle_de_nom(Nom, C), memberchk(C, Ks).
nom_valide(K, Nom, Ks, alias(C, Ka)) :- K:cle_de_nom(Nom, C), memberchk(Ka, Ks), ( K:alias(C, Ka) ; K:alias(Ka, C) ).

% appui_valide(K, G, S, Atome, Appui, Etat) : Etat est le signe de l'assertion ; positif exigé ici
appui_valide(K, G, S, A, Ap, pos) :- appui_signe(K, G, S, A, Ap, positif).

appui_signe(K, G, S, type(X, T), appui(E, E, P, L), Sg) :-
    member(entite(E, W, P), G), W \== nom_propre, val(S, X, R), representant(G, R), meme_classe(G, E, R),
    signe(Sg, G, E, represente), lien_valide(K, n, W, T, L).
appui_signe(K, G, S, nom(X, Ks), appui(A, E, P, L), Sg) :-
    member(nom(A, E, Nom, P), G), val(S, X, R), representant(G, R), meme_classe(G, E, R),
    signe(Sg, G, A, represente), nom_valide(K, Nom, Ks, L).
appui_signe(K, G, S, propriete(X, Pr), appui(A, E, P, L), Sg) :-
    member(propriete(A, E, W, P), G), val(S, X, R), representant(G, R), meme_classe(G, E, R),
    signe(Sg, G, A, represente), lien_valide(K, a, W, Pr, L).
appui_signe(K, G, S, evenement(X, Pr), appui(V, V, P, L), Sg) :-
    val(S, X, V), member(evenement(V, W, P), G), signe(Sg, G, V, represente), lien_valide(K, v, W, Pr, L).
appui_signe(_, G, S, role(X, Ro, Y), appui(role(V, Ro, E), E, P, egal), Sg) :-
    val(S, X, V), val(S, Y, R), member(role(V, Ro, E), G), representant(G, R), meme_classe(G, E, R),
    member(evenement(V, _, P), G), signe(Sg, G, V, represente).
appui_signe(K, G, S, relation(X, Re, Y), appui(A, E1, P, L), Sg) :-
    member(relation(A, E1, W, E2, P), G), val(S, X, R1), val(S, Y, R2), representant(G, R1), representant(G, R2),
    meme_classe(G, E1, R1), meme_classe(G, E2, R2), signe(Sg, G, A, represente), lien_valide(K, r, W, Re, L).
appui_signe(K, G, _, genre(T), appui(E, E, P, L), Sg) :-
    member(entite(E, W, P), G), W \== nom_propre, signe(Sg, G, E, oeuvre), lien_valide(K, n, W, T, L).

signe(positif, G, A, Ctx) :- positif(G, A, Ctx).
signe(negatif, G, A, Ctx) :- negatif(G, A, Ctx).

% un appui négatif sous σ, cherché dans tout le graphe (le lien est recherché, pas donné)
appui_negatif(K, G, S, A, X) :-
    appui_signe_cherche(K, G, S, A, X).
appui_signe_cherche(K, G, S, type(X, T), E) :-
    member(entite(E, W, _), G), W \== nom_propre, val(S, X, R), meme_classe(G, E, R), negatif(G, E, represente),
    lien_existe(K, n, W, T).
appui_signe_cherche(K, G, S, nom(X, Ks), A) :-
    member(nom(A, E, Nom, _), G), val(S, X, R), meme_classe(G, E, R), negatif(G, A, represente),
    once(nom_valide(K, Nom, Ks, _)).
appui_signe_cherche(K, G, S, propriete(X, Pr), A) :-
    member(propriete(A, E, W, _), G), val(S, X, R), meme_classe(G, E, R), negatif(G, A, represente),
    lien_existe(K, a, W, Pr).
appui_signe_cherche(K, G, S, evenement(X, Pr), V) :-
    val(S, X, V), member(evenement(V, W, _), G), negatif(G, V, represente), lien_existe(K, v, W, Pr).
appui_signe_cherche(_, G, S, role(X, Ro, Y), role(V, Ro, E)) :-
    val(S, X, V), val(S, Y, R), member(role(V, Ro, E), G), meme_classe(G, E, R), negatif(G, V, represente).
appui_signe_cherche(K, G, S, relation(X, Re, Y), A) :-
    member(relation(A, E1, W, E2, _), G), val(S, X, R1), val(S, Y, R2), meme_classe(G, E1, R1), meme_classe(G, E2, R2),
    negatif(G, A, represente), lien_existe(K, r, W, Re).
appui_signe_cherche(K, G, _, genre(T), E) :-
    member(entite(E, W, _), G), W \== nom_propre, negatif(G, E, oeuvre), lien_existe(K, n, W, T).

lien_existe(K, Cat, W, T) :- K:sens(Cat, W, S0), monte(K, S0, T), !.
monte(_, S, T) :- S == T, !.
monte(K, S, T) :- K:sous(S, S1), monte(K, S1, T).

contrainte_vraie(_, S, meme(X, Y)) :- val(S, X, A), val(S, Y, B), A == B.
contrainte_vraie(_, S, distincts(X, Y)) :- val(S, X, A), val(S, Y, B), A \== B.
contrainte_vraie(G, S, nombre(X, N)) :- val(S, X, R), member(nombre(E, N), G), meme_classe(G, E, R), !.
