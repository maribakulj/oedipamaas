/*  Diagnostic de l'étape 3 : pour chaque sujet de la référence du banc de développement, la condition où il tombe.
        swipl outils/sujets/diagnostic.pl BASE REFERENCE.json SCENES.jsonl
    (lecture seule ; la référence de développement seulement, jamais celle du banc de qualification)  */
:- initialization(main, main).
:- prolog_load_context(directory, D), atom_concat(D, '/../../oedipamaas/socle', S), asserta(user:file_search_path(socle, S)).
:- use_module(library(json)).
:- use_module(socle(arbre)).
:- use_module(socle(hypotheses)).

main :-
    current_prolog_flag(argv, [Base, Ref, Scenes|_]),
    forall(member(F, ['/iconclass.qlf', '/wordnet.qlf']), ( atom_concat(Base, F, Q), load_files(Q, []) )),
    use_module(socle(morphologie)),
    atom_concat(Base, '/sujets_index', I), load_files(I, []),
    setup_call_cleanup(open(Ref, read, S0, [encoding(utf8)]), json_read_dict(S0, Rs), close(S0)),
    read_file_to_string(Scenes, Txt, [encoding(utf8)]), split_string(Txt, "\n", "", Ls),
    forall(( member(L, Ls), L \== "", atom_json_dict(L, D, []), member(R, Rs), R.id == D.id,
             is_dict(R.get(sujet)), C = R.sujet.get(code), C \== null, C \== "0" ),
           diagnostiquer(D, C)).

diagnostiquer(D, C0) :-
    atom_string(N, C0), ( sub_atom(D.id, 0, _, _, joconde) -> L = fr ; L = en ),
    findall(el(G, V, x, p(Db), Sa), ( member(E, D.elements), atom_string(G, E.genre), val(E.valeur, V),
                                       atom_string(Sa, E.saillance), Db = E.debut ), Els),
    (   \+ arbre:valide(N) -> Etat = notation_hors_base
    ;   \+ hypotheses:generee(L, Els, N) -> Etat = non_generee
    ;   hypotheses:appuis(L, Els, N, A), \+ hypotheses:necessaire(L, N, A) -> hypotheses:noms_exiges(L, N, Ns), Etat = personnes_absentes(Ns)
    ;   hypotheses:appuis(L, Els, N, A), hypotheses:distinctifs(L, N, A, []) -> Etat = sans_distinctif
    ;   hypotheses:appuis(L, Els, N, A), \+ hypotheses:assez_d_appuis(A) -> Etat = un_seul_appui
    ;   Etat = conditions_satisfaites
    ),
    ( hypotheses:appuis(L, Els, N, A2) -> findall(E-V, member(appui(_, E, _, V, _, _), A2), Ap) ; Ap = [] ),
    findall(V-Sa, ( member(el(G, V, _, _, Sa), Els), G \== motif ), Vs0), sort(Vs0, Vs), length(Vs, NV),
    format("~w ~w ~w  appuis=~w  (scene: ~w elements)~n", [D.id, N, Etat, Ap, NV]).

val(S, V) :- ( string(S) -> atom_string(V, S) ; V = S ).
