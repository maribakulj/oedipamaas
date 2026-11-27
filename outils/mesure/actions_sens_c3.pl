/*  La polysémie des noms d'action que la PR #16 change en événements (contre-expertise, opération D2) : pour chaque
    libellé distinct, les sens du nom (WordNet 3.0 en anglais ; WOLF en français), ceux qui sont des actions
    (noun.act, noun.event, noun.process, noun.phenomenon, la liste de normalisation:lexfile_d_action/1), et ceux
    qu'un lien dérivationnel ou morphosémantique (normalisation:nominalisation/3) relie au verbe choisi.
        swipl outils/mesure/actions_sens_c3.pl BASE SITES.jsonl SORTIE.json
    Classes : univoque (tous les sens sont des actions liées au verbe : l'équivalence vaut pour tous les sens, D30) ;
    polyseme (au moins un sens qui n'est pas une action : le premier sens, ou en français le plus fréquent, décide) ;
    sans_lien (aucun sens d'action relié au verbe : le verbe vient d'une autre voie).  */
:- initialization(main, main).
:- prolog_load_context(directory, D), atom_concat(D, '/../../oedipamaas/socle', S), asserta(user:file_search_path(socle, S)).
:- use_module(socle(oedipamaas)).
:- use_module(library(json)).

main :-
    current_prolog_flag(argv, [Base, Sites, Sortie|_]),
    oedipamaas:charger_base(Base), atom_concat(Base, '/ressources.qlf', R), load_files(R, []),
    use_module(socle(normalisation)),
    setup_call_cleanup(open(Sites, read, In, [encoding(utf8)]), lire_lignes(In, Xs), close(In)),
    findall(L-Lib-T-V, ( member(X, Xs), X.op == "actions", atom_string(L, X.l), Lib = X.libelle,
                         term_string(Av, X.avant), term_string(Ap, X.apres),
                         member(type(_, T), Av), member(evenement(_, V), Ap) ), Ps0),
    sort(Ps0, Ps),
    findall(J, ( member(L-Lib-T-V, Ps), classer(L, T, V, C, Ns, Na, Nl),
                 J = _{l: L, libelle: Lib, nom: T, verbe: V, classe: C, sens: Ns, sens_action: Na, sens_lies: Nl} ), Js),
    setup_call_cleanup(open(Sortie, write, S, [encoding(utf8)]), json_write_dict(S, Js, [width(140)]), close(S)),
    findall(L-C, member(_{l: L, libelle: _, nom: _, verbe: _, classe: C, sens: _, sens_action: _, sens_lies: _}, Js), Cs0),
    msort(Cs0, Cs), clumped(Cs, Cl), length(Js, N), format("~d libellés distincts : ~w~n", [N, Cl]).

lire_lignes(In, Xs) :-
    read_line_to_string(In, L),
    ( L == end_of_file -> Xs = [] ; atom_json_dict(L, X, []), Xs = [X|Xs1], lire_lignes(In, Xs1) ).

sens_du_nom(en, T, Ss) :- findall(S, wordnet:s(S, _, T, n, _, _), Ss0), sort(Ss0, Ss).
sens_du_nom(fr, T, Ss) :- findall(S, ( ressources:wolf(S, T), S // 100000000 =:= 1 ), Ss0), sort(Ss0, Ss).
action(S) :- wordnet:lexfile(S, F), normalisation:lexfile_d_action(F).
lie(L, S, V, T) :- action(S), normalisation:nominalisation(L, V, T),
    ( L == en -> once(( wordnet:s(S, _, T, n, _, _) )) ; true ).

classer(L, T, V, C, Ns, Na, Nl) :-
    sens_du_nom(L, T, Ss), length(Ss, Ns),
    include(action, Ss, As), length(As, Na),
    ( normalisation:nominalisation(L, V, T) -> Nl = Na ; Nl = 0 ),
    (   Nl =:= 0 -> C = sans_lien
    ;   Na =:= Ns -> C = univoque
    ;   C = polyseme
    ).
