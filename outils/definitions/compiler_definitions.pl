/*  Compile les définitions de toutes les notations (docs/FONDEMENTS.md, § 3), hors ligne, depuis la lecture des
    libellés (outils/definitions/lire_libelles.pl) :
        swipl outils/definitions/compiler_definitions.pl BASE
    Écrit BASE/definitions_index.pl :
      definition(N, Langue, Def)               definitions:definition/3
      statut(N, Langue, Statut, Raisons)       compilation:statut/5 ; une notation sans définition : non_prise_en_charge
      sens(N, Langue, Mot, Synsets, Origines)  compilation:sens_de_mot/5, pour chaque mot de la définition
    et les comptes par type et par statut sur la sortie d'erreur.
    NB : la lecture des libellés est à refaire quand libelles_iconclass.pl change (prétraitement, type).  */
:- initialization(main, main).
:- prolog_load_context(directory, D), atom_concat(D, '/../../oedipamaas/socle', S), asserta(user:file_search_path(socle, S)).
:- use_module(socle(oedipamaas)).

:- dynamic definitions_index:definition/3.

main :-
    current_prolog_flag(argv, [Base|_]),
    oedipamaas:charger_base(Base),
    atom_concat(Base, '/libelles_lus', Lus), load_files(Lus, []),
    atom_concat(Base, '/ressources.qlf', Res), load_files(Res, []),
    use_module(socle(definitions)), use_module(socle(compilation)),
    % 1. les définitions
    forall(( distinct(N, libelles_lus:partie(N, _, 1, _, _, _, _)), definitions:type_libelle(N, T), member(L, [en, fr]),
             libelles_lus:partie(N, L, 1, _, _, _, _) ),
           (   catch(definitions:definition(N, L, Def), E, ( print_message(error, E), fail ))
           ->  assertz(definitions_index:definition(N, L, Def)), compter(T, ok)
           ;   assertz(sans_definition(N, L, T)), compter(T, echec)
           )),
    % 2. statuts et sens (le sens bilingue lit la définition de l'autre langue, le sens hiérarchique celles des ancêtres)
    atom_concat(Base, '/definitions_index.pl', Sortie),
    setup_call_cleanup(open(Sortie, write, S, [encoding(utf8)]),
        ( format(S, ":- module(definitions_index, [definition/3, statut/4, sens/5]).~n:- encoding(utf8).~n", []),
          format(S, ":- discontiguous definition/3, statut/4, sens/5.~n", []),
          forall(definitions_index:definition(N, L, Def),
                 ( format(S, "definition(~q, ~q, ~q).~n", [N, L, Def]),
                   compilation:statut(N, L, Def, St, Rs), format(S, "statut(~q, ~q, ~q, ~q).~n", [N, L, St, Rs]),
                   compter(statut, St),
                   compilation:mots_de_definition(Def, Ws),
                   forall(member(W, Ws),
                          ( compilation:sens_de_mot(N, L, W, Ss, Os), format(S, "sens(~q, ~q, ~q, ~q, ~q).~n", [N, L, W, Ss, Os]),
                            forall(member(O, Os), compter(sens, O)) )) )),
          forall(sans_definition(N, L, T),
                 ( format(S, "statut(~q, ~q, non_prise_en_charge, [pas_de_definition(~q)]).~n", [N, L, T]),
                   compter(statut, non_prise_en_charge) )) ),
        close(S)),
    forall(compte(T, K, V), format(user_error, "~w ~w ~d~n", [T, K, V])).

:- dynamic compte/3, sans_definition/3.
compter(T, K) :- ( retract(compte(T, K, V0)) -> V is V0 + 1 ; V = 1 ), assertz(compte(T, K, V)).
