/*  La couche de sens (docs/REFONTE.md, F2) : aligner les notations d'Iconclass sur des sens de WordNet.

    Une notation dont le libellé principal définit un mot (raisonnement:def/3 : « beasts of prey, predatory animals:
    lion ») est alignée sur le sens de ce mot qui s'accorde avec sa place dans l'arbre : un hyperonyme du sens (ou le
    sens lui-même) porte un mot plein des libellés de ses ancêtres ou de son titre de libellé. Sous « animals », le
    sens animal de « lion » (102129165), pas Lion le signe (110265070) ; sous « parts of the church », le sens
    architectural de « niche », s'il en a un qui y mène, sinon rien.

    aligner(-Stats)        construit les faits aligne(Notation, Mot, Sens) (une fois ; en mémoire, lecture seule)
    aligne(?N, ?Mot, ?Sens)
    sens_de(+N, -Sens)     les sens alignés d'une notation
    Une notation sans sens aligné ne peut pas être établie par une chose décrite (S2).
*/
:- module(sens, [ aligner/1, aligne/3, sens_de/2, mots_de_contexte/2, note/3 ]).
:- encoding(utf8).
:- use_module(libelles).
:- use_module(arbre).
:- use_module(morphologie).

:- dynamic aligne/3.

sens_de(N, Ss) :- findall(S, aligne(N, _, S), Ss0), sort(Ss0, Ss).

% les sens nominaux d'un mot (WordNet écrit les noms composés avec des espaces)
sens_nominal(W, S) :- wordnet:s(S, _, W, n, _, _).
sens_nominal(W, S) :- \+ wordnet:s(_, _, W, n, _, _), catch(morphologie:tous_lemmes(W, Ls), _, fail),
    member(L, Ls), L \== W, wordnet:s(S, _, L, n, _, _).

% le contexte d'une notation, par niveau : 0 le titre de son propre libellé (« beasts of prey, predatory animals »),
% 1 le libellé de son parent, 2 celui du grand-parent, 3 au plus ; au-delà, les libellés deviennent trop généraux
% (« Christian religious places » ne dit rien de la niche)
mot_de_contexte(N, 0, M) :- titre_du_libelle(N, T), mot_singulier(T, M).
mot_de_contexte(N, L, M) :- ancetre_niveau(N, 1, L, A), iconclass:libelle(A, en, T), mot_singulier(T, M).

ancetre_niveau(N, L0, L, A) :-
    L0 =< 3, arbre:parent(N, P),
    (   sub_atom(P, _, _, 0, '(...)')                  % un gabarit ne compte pas comme niveau
    ->  ancetre_niveau(P, L0, L, A)
    ;   ( A = P, L = L0 ; L1 is L0 + 1, ancetre_niveau(P, L1, L, A) )
    ).

mots_de_contexte(N, Ms) :- findall(L-M, mot_de_contexte(N, L, M), Ms0), sort(Ms0, Ms).

mot_singulier(T, M) :- libelles:mots_pleins(T, Ws), member(W, Ws), forme_singuliere(W, M).

titre_du_libelle(N, T) :-
    iconclass:libelle(N, en, L), sub_atom(L, B, _, _, ': '), sub_atom(L, 0, B, _, T), !.

forme_singuliere(W, M) :- ( catch(morphologie:tous_lemmes(W, Ls), _, fail), Ls \== [] -> member(M, Ls) ; M = W ).

% distance d'un sens à ses hyperonymes (le sens lui-même : 0), au plus 10 pas
:- table distance_hyperonyme/3.
distance_hyperonyme(S, S, 0).
distance_hyperonyme(S, A, D) :- ( wordnet:hyp(S, P) ; wordnet:ins(S, P) ), distance_hyperonyme(P, A, D0), D is D0 + 1, D =< 10.

% la note d'un sens pour N : le meilleur (niveau du contexte × 10 + distance dans WordNet) sur les mots de contexte qu'un
% de ses hyperonymes porte ; les mots trop généraux ne comptent pas
note(N, S, Note) :-
    aggregate_all(min(X), ( mot_de_contexte(N, L, M), \+ trop_general(M),
                            wordnet:s(A, _, M, n, _, _), distance_hyperonyme(S, A, D), X is L * 10 + D ), Note),
    number(Note).

trop_general(W) :- memberchk(W, [entity, object, thing, matter, part, whole, abstraction, group, physical, unit, place,
                                  being, organism, person, people, man, woman, figure, other, kind, type, form, use,
                                  representation, scene, symbol, attribute, situation, condition, state, act, activity]).

frequence(W, S, F) :- ( wordnet:s(S, _, W, n, _, F0) -> F = F0 ; F = 0 ).

% pour un mot défini par N : les sens qui ont la meilleure note (au plus 39 : un contexte jusqu'au niveau 3), puis,
% à égalité, les plus fréquents
meilleurs_sens(N, W, Ss) :-
    findall(Note-S, ( sens_nominal(W, S), note(N, S, Note), Note =< 39 ), NS0),
    NS0 \== [],
    keysort(NS0, [Min-_|_]),
    findall(S, member(Min-S, NS0), Ex0), sort(Ex0, Ex),
    findall(F-S, ( member(S, Ex), frequence(W, S, F) ), FS), keysort(FS, FS1), last(FS1, Fmax-_),
    findall(S, member(Fmax-S, FS1), Ss).

% un mot dont le sens dominant porte au moins 70 % des emplois annotés de WordNet (et au moins 3) : « window » (72 sur
% 82), « angel », « hill » ; pas « model », « life », « shift », « right », vraiment ambigus
sens_quasi_unique(W0, S) :-
    ( wordnet:s(_, _, W0, n, _, _) -> W = W0 ; catch(morphologie:tous_lemmes(W0, Ls), _, fail), member(W, Ls),
      wordnet:s(_, _, W, n, _, _) ), !,
    aggregate_all(sum(F), wordnet:s(_, _, W, n, _, F), Tot), Tot >= 3,
    aggregate_all(max(F, S0), wordnet:s(S0, _, W, n, _, F), max(Fmax, S)),
    Fmax >= 0.7 * Tot.

aligner(_{notations: NN, alignees: NA, alignements: NS}) :-
    retractall(aligne(_, _, _)),
    forall(( distinct(N-W, ( raisonnement:def(en, W, N), \+ sub_atom(W, _, _, _, '(') )),
             (   meilleurs_sens(N, W, Ss) -> true
             ;   sens_quasi_unique(W, S0) -> Ss = [S0]     % sinon, un mot presque monosémique
             ),
             member(S, Ss) ),
           assertz(aligne(N, W, S))),
    aggregate_all(count, distinct(N, raisonnement:def(en, _, N)), NN),
    aggregate_all(count, distinct(N, aligne(N, _, _)), NA),
    aggregate_all(count, aligne(_, _, _), NS).
