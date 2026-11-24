/*  La scène d'une description (docs/PLAN_F3.md, étape 2) : ce que l'image montre, assemblé depuis les assertions
    admissibles (assertions:admissible/2 : affirmées, positives, de l'auteur, de portée « représenté », hors
    alternative ; l'ancrage F1 a déjà décidé de la portée).

    scene(+Faits, -Scene)
        Scene = scene(Participants, Actions, Relations)
        participant(E, Tete, Noms, Proprietes, Nombre, Passage, Saillance)
            E : l'entité canonique de sa classe de coréférence ; Noms : normalisés (JEROME) ; Nombre : entier ou inconnu ;
            Saillance : principal (un membre de sa classe est saillant, mondes.pl) ou composant
        action(V, Predicat, Roles, Passage)         Roles : Role-E (E canonique, participant de la scène)
        relation(A, E1, Rel, E2, Passage)
    elements_de_scene(+Scene, -Elements)
        el(Genre, Valeur, Porteur, Passage, Saillance), Genre : nom | mot | motif ; ce que la reconnaissance du sujet
        rapproche des profils (sujets.pl) ; une action est principale si l'un de ses participants l'est
*/
:- module(scene, [ scene/2, elements_de_scene/2 ]).
:- encoding(utf8).
:- use_module(assertions).
:- use_module(raisonnement, []).
:- use_module(sujets, []).

scene(Fs, scene(Ps, As, Rs)) :-
    findall(E, ( member(entite(E, _, _), Fs), assertions:admissible(Fs, E) ), Es0), sort(Es0, Es),
    findall(participant(C, T, Noms, Props, Nb, P, Sa),
            ( member(E, Es), canonique(Fs, Es, E, C), C == E, memberchk(entite(E, T, P), Fs),
              classe(Fs, Es, E, Cl),
              findall(K, ( member(X, Cl), member(nom(A, X, Nom, _), Fs), assertions:admissible(Fs, A),
                           raisonnement:normaliser_nom(Nom, K) ), Noms0), sort(Noms0, Noms),
              findall(Pr, ( member(X, Cl), member(propriete(A, X, Pr, _), Fs), assertions:admissible(Fs, A) ), Props0),
              sort(Props0, Props),
              ( member(X, Cl), memberchk(nombre(X, Nb), Fs) -> true ; Nb = inconnu ),
              ( member(X, Cl), memberchk(saillance(X, principal), Fs) -> Sa = principal ; Sa = composant ) ),
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

element(Ps, _, _, el(nom, K, E, P, Sa)) :- member(participant(E, _, Noms, _, _, P, Sa), Ps), member(K, Noms).
element(Ps, _, _, el(G, W, E, P, Sa)) :- member(participant(E, T, _, _, _, P, Sa), Ps), mot(T, W), genre(Ps, E, G).
element(Ps, _, _, el(G, W, E, P, Sa)) :-
    member(participant(E, _, _, Props, _, P, Sa), Ps), member(Pr, Props), mot(Pr, W), genre(Ps, E, G).
element(Ps, As, _, el(G, W, V, P, Sa)) :-
    member(action(V, Pr, Roles, P), As), mot(Pr, W),
    ( member(_-E, Roles), genre(Ps, E, mot) -> G = mot ; G = motif ),
    ( member(_-E, Roles), memberchk(participant(E, _, _, _, _, _, principal), Ps) -> Sa = principal ; Sa = composant ).
element(Ps, _, Rs, el(G, W, A, P, Sa)) :-
    member(relation(A, E1, Rel, E2, P), Rs), mot(Rel, W), ( genre(Ps, E1, mot), genre(Ps, E2, mot) -> G = mot ; G = motif ),
    ( memberchk(participant(E1, _, _, _, _, _, principal), Ps) -> Sa = principal ; Sa = composant ).

% une chose de la scène (« mot ») est un référent concret ou nommé ; un référent abstrait (« enlightenment »,
% « style », « tendency » : aucun sens de WordNet sous « physical entity ») n'est qu'un motif, avec ses propriétés, et
% une action sans participant concret aussi ; un motif peut appuyer une hypothèse de sujet, jamais la susciter.
% En français, sans wordnet, tout référent compte comme concret (mesuré à part).
genre(Ps, E, G) :-
    (   memberchk(participant(E, T, Noms, _, _, _, _), Ps), ( Noms \== [] ; \+ abstrait(T) ) -> G = mot ; G = motif ).

abstrait(T) :-
    atom(T), downcase_atom(T, W), T \== nom_propre,
    ( wordnet:s(_, _, W, n, _, _) -> true ; catch(morphologie:lemmes(W, n, [L|_]), _, fail), wordnet:s(_, _, L, n, _, _), W2 = L ),
    ( var(W2) -> W2 = W ; true ),
    \+ ( wordnet:s(S, _, W2, n, _, _), physique(S) ).

:- table physique/1.
physique(100001930).
physique(S) :- ( wordnet:hyp(S, P) ; wordnet:ins(S, P) ), physique(P).

% un mot de scène : un lemme alphabétique d'au moins trois lettres, hors classes fermées (une relation par
% préposition, « de », « of », n'est pas un élément ; les relations construites, « a_cote_de », non plus)
mot(X, W) :-
    atom(X), \+ sub_atom(X, _, _, _, '_'), downcase_atom(X, W), atom_length(W, N), N >= 3,
    atom_codes(W, Cs), forall(member(C, Cs), ( code_type(C, alpha), \+ code_type(C, digit(_)) ; C == 0'- )),
    \+ sujets:ferme(_, W).
