/*  Compile les définitions de toutes les notations (docs/FONDEMENTS.md, § 3), hors ligne, depuis la lecture des
    libellés (outils/definitions/lire_libelles.pl) :
        swipl outils/definitions/compiler_definitions.pl BASE
    Écrit BASE/definitions_index.pl : definition(N, Langue, Def) (definitions:definition/3), et les comptes par type
    (définies, échecs) sur la sortie d'erreur.
    NB : la lecture des libellés est à refaire quand libelles_iconclass.pl change (prétraitement, type).  */
:- initialization(main, main).
:- prolog_load_context(directory, D), atom_concat(D, '/../../oedipamaas/socle', S), asserta(user:file_search_path(socle, S)).
:- use_module(socle(oedipamaas)).

main :-
    current_prolog_flag(argv, [Base|_]),
    oedipamaas:charger_base(Base),
    atom_concat(Base, '/libelles_lus', Lus), load_files(Lus, []),
    use_module(socle(definitions)),
    atom_concat(Base, '/definitions_index.pl', Sortie),
    setup_call_cleanup(open(Sortie, write, S, [encoding(utf8)]),
        ( format(S, ":- module(definitions_index, [definition/3]).~n:- encoding(utf8).~n", []),
          forall(( distinct(N, libelles_lus:partie(N, _, 1, _, _, _, _)), definitions:type_libelle(N, T), member(L, [en, fr]) ),
                 (   catch(definitions:definition(N, L, Def), E, ( print_message(error, E), fail ))
                 ->  format(S, "definition(~q, ~q, ~q).~n", [N, L, Def]), compter(T, ok)
                 ;   ( libelles_lus:partie(N, L, 1, _, _, _, _) -> compter(T, echec) ; true )
                 )) ),
        close(S)),
    forall(compte(T, K, V), format(user_error, "~w ~w ~d~n", [T, K, V])).

:- dynamic compte/3.
compter(T, K) :- ( retract(compte(T, K, V0)) -> V is V0 + 1 ; V = 1 ), assertz(compte(T, K, V)).
