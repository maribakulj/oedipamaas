/*  Spécialisation (conception 1.0, § 8) : descendre d'une notation sûre vers celles de ses enfants que la description
    soutient le mieux.

    Mots propres d'une notation : ses mots pleins absents du libellé de son parent (libelles:mots_propres/2), plus son
    nom entre parenthèses pour une notation à nom (le nom distingue le chêne de ses sœurs même si un autre chêne partage
    le mot). Part décrite d'un enfant : la part de ses mots propres dont une forme (le mot ou l'un de ses lemmes) est
    une forme de la description. À chaque nœud, on descend vers les enfants dont la part décrite est la plus grande
    parmi leurs sœurs, si elle n'est pas nulle (ex aequo gardés) : une comparaison entre sœurs, sans seuil écrit.

    Index (construit une fois) : propre(N, I, Forme), le I-ième mot propre de N sous chacune de ses formes ; et
    nb_propres(N, K).
*/
:- module(specialisation, [ construire_propres/1,   % +Fichier
                            decrire/0,              % les formes de la description courante (decrit/1)
                            part_decrite/2,         % +N, -Part
                            descente/2,             % +Depart, -Atteinte (enfants les mieux soutenus, en chaîne)
                            specialisees/2          % +Departs, -Atteintes (toutes, sans doublon)
                          ]).

:- use_module(libelles).
:- use_module(lexique).
:- use_module(morphologie).
:- use_module(arbre).
:- use_module(recherche).

:- dynamic decrit/1.

% --- Index des mots propres ----------------------------------------------------------------------------------------

construire_propres(Fichier) :-
    setup_call_cleanup(
        open(Fichier, write, S, [encoding(utf8)]),
        ( format(S, ":- module(propres_index, [propre/3, nb_propres/2]).~n:- encoding(utf8).~n:- discontiguous propre/3, nb_propres/2.~n", []),
          forall(iconclass:n(N),
                 ( mots_propres_ou_nom(N, Mots),
                   length(Mots, K),
                   (   K > 0
                   ->  format(S, "nb_propres(~q, ~d).~n", [N, K]),
                       forall(nth1(I, Mots, M),
                              forall(formes(M, F), format(S, "propre(~q, ~d, ~q).~n", [N, I, F])))
                   ;   true
                   ) )) ),
        close(S)).

mots_propres_ou_nom(N, Mots) :-
    (   libelles:mots_propres(N, Ms0) -> true ; Ms0 = [] ),
    (   notation:analyser(N, Niveaux), Niveaux \= composee(_), last(Niveaux, nom(T))
    ->  lexique:forme_de(T, Nom), ord_union(Ms0, [Nom], Mots)       % le nom, en dernier niveau
    ;   Mots = Ms0
    ).

formes(M, F) :-
    lexique:forme_de(M, F0),
    distinct(F, ( F = F0 ; morphologie:tous_lemmes(F0, Ls), member(F, Ls) )).

% --- Formes de la description ---------------------------------------------------------------------------------------

decrire :-
    retractall(decrit(_)),
    forall(distinct(F, recherche:forme_mention(_, F)), assertz(decrit(F))).

part_decrite(N, Part) :-
    propres_index:nb_propres(N, K),
    aggregate_all(count, distinct(I, ( propres_index:propre(N, I, F), decrit(F) )), D),
    Part is D / K.

% --- Descente -------------------------------------------------------------------------------------------------------

mieux_soutenus(X, Enfants) :-
    arbre:enfants(X, Cs),
    findall(P-C, ( member(C, Cs), part_decrite(C, P), P > 0 ), Ps),
    Ps \== [],
    max_member(Max-_, Ps),
    findall(C, member(Max-C, Ps), Enfants).

descente(X, Y) :-
    mieux_soutenus(X, Enfants),
    member(C, Enfants),
    ( Y = C ; descente(C, Y) ).

specialisees(Departs, Atteintes) :-
    findall(Y, ( member(X, Departs), descente(X, Y) ), Ys),
    sort(Ys, Atteintes).
