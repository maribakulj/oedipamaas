/*  Les paires minimales (tests/plunit/paires.pl) : texte → UDPipe (un lot par langue) → interprétation →
    assertions validées → attentes. Sauté si UDPipe n'est pas configuré (OEDIPAMAAS_UDPIPE, OEDIPAMAAS_MODELES).
    Une entité se reconnaît à sa tête ou à son nom, sans tenir compte des capitales ; une propriété et un événement à
    la racine de leur lemme (ses cinq premières lettres au plus : « couronner », « couronné » ; « prier », « prie »),
    l'analyseur ne lemmatisant pas toujours de même. */
:- use_module('../../oedipamaas/socle/udpipe').
:- use_module('../../oedipamaas/socle/interpretation').
:- use_module('../../oedipamaas/socle/assertions').
:- use_module(library(plunit)).
:- encoding(utf8).
:- consult(paires).

:- dynamic analyse/2.
udpipe_configure :- getenv('OEDIPAMAAS_UDPIPE', _), getenv('OEDIPAMAAS_MODELES', _).

preparer :-
    retractall(analyse(_, _)),
    forall(member(L, [fr, en]),
           ( findall(T, ( paire(_, L, A, _, B, _), member(T, [A, B]) ), Ts0), sort(Ts0, Ts),
             udpipe:analyser_lot(Ts, L, Ps),
             forall(nth1(I, Ts, T), ( nth1(I, Ps, P), interpretation:interpreter(T, L, description, P, Fs),
                                      assertvar(T, Fs) )) )).
assertvar(T, Fs) :- assertz(analyse(T, Fs)).

meme(X, Y) :- downcase_atom(X, A), downcase_atom(Y, A).
meme_racine(Ps, L) :- is_list(Ps), !, member(P, Ps), meme_racine(P, L), !.
meme_racine(P, L) :-
    downcase_atom(P, P1), downcase_atom(L, L1),
    atom_length(P1, N1), atom_length(L1, N2), N is min(5, min(N1, N2)),
    sub_atom(P1, 0, N, _, R), sub_atom(L1, 0, N, _, R).

entite_x(Fs, X, E) :-
    (   member(entite(E, T, _), Fs), meme(T, X)
    ;   member(nom(_, E, N, _), Fs), meme(N, X)
    ).

attente(Fs, admis(X)) :- entite_x(Fs, X, E), assertions:admissible(Fs, E), !.
attente(Fs, pas_admis(X)) :- \+ ( entite_x(Fs, X, E), assertions:admissible(Fs, E) ).
attente(Fs, nie(X)) :- entite_x(Fs, X, E), assertions:contredit(Fs, E), !.
attente(Fs, pas_nie(X)) :- \+ attente(Fs, nie(X)).
attente(Fs, role(P, R, X)) :- member(evenement(V, P0, _), Fs), meme_racine(P, P0), member(role(V, R, E), Fs), entite_x(Fs, X, E), !.
attente(Fs, pas_role(P, R, X)) :- \+ attente(Fs, role(P, R, X)).
attente(Fs, prop(X, P)) :-
    entite_x(Fs, X, E), member(propriete(A, E, L, _), Fs), meme_racine(P, L), assertions:admissible(Fs, A), !.
attente(Fs, pas_prop(X, P)) :- \+ ( entite_x(Fs, X, E), member(propriete(_, E, L, _), Fs), meme_racine(P, L) ).
attente(Fs, modal(X, M)) :- entite_x(Fs, X, E), memberchk(modalite(E, M), Fs), !.
attente(Fs, alt(X, Y)) :- member(alternative(_, Es), Fs), entite_x(Fs, X, E1), memberchk(E1, Es), entite_x(Fs, Y, E2), memberchk(E2, Es), !.
attente(Fs, portee(X, P)) :- entite_x(Fs, X, E), memberchk(portee(E, P), Fs), !.
attente(Fs, rel(X, R, Y)) :- member(relation(_, E1, R0, E2, _), Fs), meme(R0, R), entite_x(Fs, X, E1), entite_x(Fs, Y, E2), !.

verifier(T, Attentes) :-
    analyse(T, Fs),
    assertions:valider(Fs, Err),
    (   Err == [] -> true ; format(user_error, "~n~s : assertions invalides ~q~n", [T, Err]), fail ),
    exclude(attente(Fs), Attentes, Ratees),
    (   Ratees == [] -> true
    ;   format(user_error, "~n« ~s » : attentes non tenues ~q~n", [T, Ratees]),
        forall(( member(F, Fs), \+ functor(F, texte, 1), \+ functor(F, passage, 3), \+ functor(F, enonciateur, 2),
                 \+ functor(F, portee, 2) ), format(user_error, "    ~q~n", [F])),
        fail
    ).

:- begin_tests(paires, [condition(udpipe_configure), setup(preparer)]).

test(paire, [forall(( paire(Id, _, A, AttA, B, AttB), \+ erreur_connue(Id, _) ))]) :-
    once(verifier(A, AttA)),
    once(verifier(B, AttB)).

test(paire_erreur_connue, [forall(( paire(Id, _, A, AttA, B, AttB), erreur_connue(Id, R) )), fixme(R)]) :-
    once(verifier(A, AttA)),
    once(verifier(B, AttB)).

:- end_tests(paires).
