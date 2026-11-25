/*  Compile en requêtes (requetes_iconclass.pl) les notations d'une liste de fiches, dans leur langue.
        swipl outils/requetes/compiler_vertical.pl BASE FICHES.json SORTIE.json
    SORTIE.json : [{k, notation, langue, type, statut, raisons, famille, suffisante, necessaire}] (termes en chaînes).  */
:- initialization(main, main).
:- prolog_load_context(directory, D), atom_concat(D, '/../../oedipamaas/socle', S), asserta(user:file_search_path(socle, S)).
:- use_module(socle(oedipamaas)).
:- use_module(library(json)).

main :-
    current_prolog_flag(argv, [Base, Entree, Sortie|_]),
    oedipamaas:charger_base(Base),
    forall(member(F, ['/ressources.qlf', '/libelles_lus', '/definitions_index']), ( atom_concat(Base, F, C), load_files(C, []) )),
    use_module(socle(requetes_iconclass)),
    setup_call_cleanup(open(Entree, read, S0, [encoding(utf8)]), json_read_dict(S0, Fs), close(S0)),
    findall(J, ( member(Fi, Fs), atom_string(N, Fi.notation), atom_string(L, Fi.langue),
                 requetes_iconclass:compiler(N, L, compilation(_, _, T, Su, Ne, St, Rs, Fa)),
                 maplist(chaine, [Su, Ne, Rs, Fa], [Sus, Nes, Rss, Fas]),
                 J = _{k: Fi.k, notation: Fi.notation, langue: Fi.langue, type: T, statut: St, raisons: Rss,
                       famille: Fas, suffisante: Sus, necessaire: Nes} ), Js),
    setup_call_cleanup(open(Sortie, write, O, [encoding(utf8)]), json_write_dict(O, Js, [width(160)]), close(O)),
    length(Js, K), format("~d compilées~n", [K]).
chaine(T, S) :- with_output_to(string(S), print(T)).
