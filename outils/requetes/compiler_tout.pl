/*  Compile en requêtes (requetes_iconclass.pl) toutes les notations de la base, dans les deux langues, en parallèle.
        swipl outils/requetes/compiler_tout.pl BASE [LIMITE]
    Écrit BASE/requetes_index.pl : requete_compilee(N, Langue, Type, Suff, Nec, Statut, Raisons, Famille)
    (LIMITE : les LIMITE premières notations seulement, pour mesurer le temps). Comptes par statut sur la sortie
    d'erreur.  */
:- initialization(main, main).
:- prolog_load_context(directory, D), atom_concat(D, '/../../oedipamaas/socle', S), asserta(user:file_search_path(socle, S)).
:- use_module(socle(oedipamaas)).

main :-
    current_prolog_flag(argv, [Base|Opt]),
    oedipamaas:charger_base(Base),
    forall(member(F, ['/ressources.qlf', '/libelles_lus', '/definitions_index']), ( atom_concat(Base, F, C), load_files(C, []) )),
    use_module(socle(requetes_iconclass)),
    findall(N-L, ( distinct(N, libelles_lus:partie(N, _, 1, _, _, _, _)), member(L, [en, fr]),
                   libelles_lus:partie(N, L, 1, _, _, _, _) ), Ps0),
    ( Opt = [Lim0|_] -> atom_number(Lim0, Lim), length(Ps, Lim), append(Ps, _, Ps0) ; Ps = Ps0 ),
    length(Ps, Total), format(user_error, "~d compilations~n", [Total]),
    get_time(T0),
    concurrent_maplist(compiler_un, Ps, Cs),
    get_time(T1), Dt is T1 - T0, format(user_error, "~1f s~n", [Dt]),
    atom_concat(Base, '/requetes_index.pl', Sortie),
    setup_call_cleanup(open(Sortie, write, S, [encoding(utf8)]),
        ( format(S, ":- module(requetes_index, [requete_compilee/8]).~n:- encoding(utf8).~n", []),
          forall(member(C, Cs), ( C = compilation(A, B, T, Su, Ne, St, Rs, Fa),
                                  format(S, "requete_compilee(~q, ~q, ~q, ~q, ~q, ~q, ~q, ~q).~n", [A, B, T, Su, Ne, St, Rs, Fa]) )) ),
        close(S)),
    findall(St, member(compilation(_, _, _, _, _, St, _, _), Cs), Sts), msort(Sts, Ss), clumped(Ss, Cl),
    format(user_error, "~w~n", [Cl]).

compiler_un(N-L, C) :-
    (   catch(requetes_iconclass:compiler(N, L, C0), E, ( C0 = compilation(N, L, inconnu, aucune, aucune, invalide, [exception(E)], aucune) ))
    ->  C = C0
    ;   C = compilation(N, L, inconnu, aucune, aucune, invalide, [echec], aucune)
    ).
