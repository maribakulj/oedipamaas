/*  La scène d'une description (docs/PLAN_F3.md, étape 2) : ce que l'image montre, assemblé depuis les assertions
    admissibles (assertions:admissible/2 : affirmées, positives, de l'auteur, de portée « représenté », hors
    alternative ; l'ancrage F1 a déjà décidé de la portée).

    scene(+Faits, -Scene)
        Scene = scene(Participants, Actions, Relations)
        participant(E, Tete, Noms, Proprietes, Nombre, Passage)
            E : l'entité canonique de sa classe de coréférence ; Noms : normalisés (JEROME) ; Nombre : entier ou inconnu
        action(V, Predicat, Roles, Passage)         Roles : Role-E (E canonique, participant de la scène)
        relation(A, E1, Rel, E2, Passage)
    elements_de_scene(+Scene, -Elements)
        el(Genre, Valeur, Porteur, Passage), Genre : nom | mot ; ce que la reconnaissance du sujet rapproche des
        profils (sujets.pl)
*/
:- module(scene, [ scene/2, elements_de_scene/2 ]).
:- encoding(utf8).
:- use_module(assertions).
:- use_module(raisonnement, []).
:- use_module(sujets, []).

scene(Fs, scene(Ps, As, Rs)) :-
    findall(E, ( member(entite(E, _, _), Fs), assertions:admissible(Fs, E) ), Es0), sort(Es0, Es),
    findall(participant(C, T, Noms, Props, Nb, P),
            ( member(E, Es), canonique(Fs, Es, E, C), C == E, memberchk(entite(E, T, P), Fs),
              classe(Fs, Es, E, Cl),
              findall(K, ( member(X, Cl), member(nom(A, X, Nom, _), Fs), assertions:admissible(Fs, A),
                           raisonnement:normaliser_nom(Nom, K) ), Noms0), sort(Noms0, Noms),
              findall(Pr, ( member(X, Cl), member(propriete(A, X, Pr, _), Fs), assertions:admissible(Fs, A) ), Props0),
              sort(Props0, Props),
              ( member(X, Cl), memberchk(nombre(X, Nb), Fs) -> true ; Nb = inconnu ) ),
            Ps),
    findall(action(V, Pr, Roles, P),
            ( member(evenement(V, Pr, P), Fs), assertions:admissible(Fs, V),
              findall(R-C, ( member(role(V, R, E), Fs), memberchk(E, Es), canonique(Fs, Es, E, C) ), Roles0),
              sort(Roles0, Roles) ),
            As),
    findall(relation(A, C1, Rel, C2, P),
            ( member(relation(A, E1, Rel, E2, P), Fs), assertions:admissible(Fs, A),
              canonique(Fs, Es, E1, C1), canonique(Fs, Es, E2, C2) ),
            Rs).

% la classe de coréférence d'une entité, restreinte aux entités admissibles ; son représentant : la plus petite
classe(Fs, Es, E, Cl) :- fermeture(Fs, Es, [E], [E], Cl0), sort(Cl0, Cl).
fermeture(_, _, [], Vu, Vu).
fermeture(Fs, Es, [X|Xs], Vu, Cl) :-
    findall(Y, ( ( memberchk(coref(X, Y), Fs) ; member(coref(X, Y), Fs) ; member(coref(Y, X), Fs) ),
                 memberchk(Y, Es), \+ memberchk(Y, Vu) ), Ys0), sort(Ys0, Ys),
    append(Vu, Ys, Vu1), append(Xs, Ys, File), fermeture(Fs, Es, File, Vu1, Cl).
canonique(Fs, Es, E, C) :- memberchk(E, Es), classe(Fs, Es, E, [C|_]).

elements_de_scene(scene(Ps, As, Rs), Els) :-
    findall(El, element(Ps, As, Rs, El), Els0), sort(Els0, Els).

element(Ps, _, _, el(nom, K, E, P)) :- member(participant(E, _, Noms, _, _, P), Ps), member(K, Noms).
element(Ps, _, _, el(mot, W, E, P)) :- member(participant(E, T, _, _, _, P), Ps), mot(T, W).
element(Ps, _, _, el(mot, W, E, P)) :- member(participant(E, _, _, Props, _, P), Ps), member(Pr, Props), mot(Pr, W).
element(_, As, _, el(mot, W, V, P)) :- member(action(V, Pr, _, P), As), mot(Pr, W).
element(_, _, Rs, el(mot, W, A, P)) :- member(relation(A, _, Rel, _, P), Rs), mot(Rel, W).

% un mot de scène : un lemme alphabétique d'au moins trois lettres, hors classes fermées (une relation par
% préposition, « de », « of », n'est pas un élément ; les relations construites, « a_cote_de », non plus)
mot(X, W) :-
    atom(X), \+ sub_atom(X, _, _, _, '_'), downcase_atom(X, W), atom_length(W, N), N >= 3,
    atom_codes(W, Cs), forall(member(C, Cs), ( code_type(C, alpha), \+ code_type(C, digit(_)) ; C == 0'- )),
    \+ sujets:ferme(_, W).
