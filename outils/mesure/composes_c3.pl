/*  Les composés nominaux que la PR #16 change en propriétés (contre-expertise, opération D3) : pour chaque libellé
    distinct (anglais), le modifieur M et la tête H.
        swipl outils/mesure/composes_c3.pl BASE SITES.jsonl SORTIE.json
    Classes :
      lexicalise        WordNet a le composé (« M H », « MH » ou « M-H ») : composes/2 en fait un seul type, une
                        équivalence lexicale (le composé est un concept) ;
      matiere_espece    non lexicalisé, et tous les sens de M sont une matière ou une espèce (noun.substance,
                        noun.plant, noun.animal, noun.food) : la propriété est la forme du guide (« a stone bridge ») ;
      mixte             non lexicalisé, certains sens de M seulement sont une matière ou une espèce ;
      autre_relation    non lexicalisé, aucun sens de M n'est une matière ni une espèce : la relation implicite (but,
                        lieu, partie, thème…) n'est pas une propriété ;
      inconnu           M n'est pas dans WordNet.  */
:- initialization(main, main).
:- prolog_load_context(directory, D), atom_concat(D, '/../../oedipamaas/socle', S), asserta(user:file_search_path(socle, S)).
:- use_module(socle(oedipamaas)).
:- use_module(library(json)).

main :-
    current_prolog_flag(argv, [Base, Sites, Sortie|_]),
    oedipamaas:charger_base(Base), atom_concat(Base, '/ressources.qlf', R), load_files(R, []),
    setup_call_cleanup(open(Sites, read, In, [encoding(utf8)]), lire_lignes(In, Xs), close(In)),
    findall(Lib-M-H, ( member(X, Xs), X.op == "composes_syntaxiques", X.l == "en", Lib = X.libelle,
                       term_string(Ap, X.apres), member(propriete(_, M), Ap), atom_string(H, X.tete), H \== '' ), Ps0),
    sort(Ps0, Ps),
    findall(J, ( member(Lib-M-H, Ps), classer(M, H, C), J = _{libelle: Lib, modifieur: M, tete: H, classe: C} ), Js),
    setup_call_cleanup(open(Sortie, write, S, [encoding(utf8)]), json_write_dict(S, Js, [width(140)]), close(S)),
    findall(C, member(_{libelle: _, modifieur: _, tete: _, classe: C}, Js), Cs0), msort(Cs0, Cs), clumped(Cs, Cl),
    length(Js, N), format("~d libellés distincts : ~w~n", [N, Cl]).

lire_lignes(In, Xs) :-
    read_line_to_string(In, L),
    ( L == end_of_file -> Xs = [] ; atom_json_dict(L, X, []), Xs = [X|Xs1], lire_lignes(In, Xs1) ).

classer(M, H, lexicalise) :- member(Sep, [' ', '', '-']), atomic_list_concat([M, H], Sep, W), wordnet:s(_, _, W, n, _, _), !.
classer(M, _, C) :-
    findall(S, wordnet:s(S, _, M, n, _, _), Ss0), sort(Ss0, Ss),
    (   Ss == [] -> C = inconnu
    ;   include(matiere_espece, Ss, Ms), length(Ms, Nm), length(Ss, Ns),
        ( Nm =:= Ns -> C = matiere_espece ; Nm > 0 -> C = mixte ; C = autre_relation )
    ).
matiere_espece(S) :- wordnet:lexfile(S, F), memberchk(F, ['noun.substance', 'noun.plant', 'noun.animal', 'noun.food']).
