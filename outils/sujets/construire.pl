/*  Compile l'inventaire des sujets (docs/PLAN_F3.md, étape 1), hors ligne, une fois :
        swipl outils/sujets/construire.pl BASE
    écrit BASE/sujets_index.pl ; demande UDPipe (OEDIPAMAAS_UDPIPE, OEDIPAMAAS_MODELES).  */
:- initialization(main, main).
:- prolog_load_context(directory, D), atom_concat(D, '/../../oedipamaas/socle', S), asserta(user:file_search_path(socle, S)).
:- use_module(socle(raisonnement)).
:- use_module(socle(sujets)).

main :-
    current_prolog_flag(argv, [Base|_]),
    forall(member(Q, ['/iconclass.qlf', '/wordnet.qlf']), ( atom_concat(Base, Q, I), load_files(I, []) )),
    use_module(socle(morphologie)),                     % après WordNet : son index se construit au chargement
    atom_concat(Base, '/sujets_index.pl', F),
    statistics(walltime, _), construire_sujets(F), statistics(walltime, [_, T]),
    format(user_error, "écrit ~w en ~1f s~n", [F, T / 1000]).
