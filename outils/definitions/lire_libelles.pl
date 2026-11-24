/*  Lit une fois tous les libellés d'Iconclass (docs/FONDEMENTS.md, § 3 ; étape 1 de § 9), hors ligne :
        swipl outils/definitions/lire_libelles.pl BASE
    Pour chaque notation et chaque langue (en, fr) : les parties du libellé (propre, attributs, gabarit), chacune
    prétraitée (parenthèses classées, libelles_iconclass:pretraiter/3) et analysée par UDPipe (avec la syntaxe) ;
    puis le type de la partie propre, calculé sur l'anglais.
    Écrit BASE/libelles_lus.pl (module libelles_lus) :
        partie(N, Langue, Rang, Origine, Net, Marques, Phrases)
        type(N, Type)                    type de la partie propre (anglais ; à défaut français)
        aspect(N, Rang, Type)            type de chaque partie de gabarit (anglais)
    Demande UDPipe (OEDIPAMAAS_UDPIPE, OEDIPAMAAS_MODELES).  */
:- initialization(main, main).
:- prolog_load_context(directory, D), atom_concat(D, '/../../oedipamaas/socle', S), asserta(user:file_search_path(socle, S)).
:- use_module(socle(udpipe)).
:- use_module(socle(sujets)).
:- use_module(socle(libelles_iconclass)).

:- dynamic lu/7.

main :-
    current_prolog_flag(argv, [Base|_]),
    forall(member(Q, ['/iconclass.qlf', '/wordnet.qlf']), ( atom_concat(Base, Q, F), load_files(F, []) )),
    use_module(socle(morphologie)), use_module(socle(arbre)),
    forall(member(L, [en, fr]), lire_langue(L)),
    atom_concat(Base, '/libelles_lus.pl', Sortie),
    setup_call_cleanup(open(Sortie, write, S, [encoding(utf8)]),
        ( format(S, ":- module(libelles_lus, [partie/7, type/2, aspect/3]).~n:- encoding(utf8).~n", []),
          forall(lu(N, L, R, O, Net, Ms, Ph), format(S, "partie(~q, ~q, ~q, ~q, ~q, ~q, ~q).~n", [N, L, R, O, Net, Ms, Ph])),
          forall(type_calcule(N, T), format(S, "type(~q, ~q).~n", [N, T])),
          forall(aspect_calcule(N, R, T), format(S, "aspect(~q, ~q, ~q).~n", [N, R, T])) ),
        close(S)),
    format(user_error, "écrit ~w~n", [Sortie]).

lire_langue(L) :-
    findall(t(N, R, O, Net, Ms), ( iconclass:n(N), iconclass:libelle(N, L, T), sujets:parties(T, L, Ps),
                                    nth1(R, Ps, O-P), pretraiter(P, Net, Ms) ), Ts),
    findall(S, ( member(t(_, _, _, Net, _), Ts), atom_string(Net, S) ), Ss),
    length(Ss, NT), format(user_error, "~w : ~d parties~n", [L, NT]),
    lots(Ss, 2000, Lots),
    concurrent_maplist(analyser_lot_(L), Lots, As0), append(As0, As),
    maplist(enregistrer(L), Ts, As).

analyser_lot_(L, Lot, A) :- udpipe:analyser_lot(Lot, L, A), format(user_error, ".", []).
enregistrer(L, t(N, R, O, Net, Ms), Ph) :- assertz(lu(N, L, R, O, Net, Ms, Ph)).

lots([], _, []) :- !.
lots(L, N, [P|Ps]) :- length(P, N), append(P, R, L), !, lots(R, N, Ps).
lots(L, _, [L]).

type_calcule(N, T) :-
    distinct(N, lu(N, _, _, _, _, _, _)),
    (   lu(N, en, 1, _, _, Ms, Ph) -> true ; lu(N, fr, 1, _, _, Ms, Ph) ),
    once(type_de_libelle(N, Ph, Ms, T)).

aspect_calcule(N, R, T) :-
    lu(N, en, R, gabarit, _, Ms, Ph), once(type_de_libelle(N, Ph, Ms, T0)), T0 \== individu,
    ( T0 == rubrique -> T = classe ; T = T0 ).
