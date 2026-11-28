/*  Tests plunit de la version Prolog : chaque mutant doit rendre exactement les violations attendues (écrites à la main).
    MUTANTS_DIR et WN30_IDS dans l'environnement ; LANG=C.UTF-8 swipl -g run_tests -t halt pl/test_k.pl  */
:- use_module(construire_k).
:- use_module(library(plunit)).
:- use_module(library(readutil)).
:- use_module(library(apply)).

mutant(M) :- getenv('MUTANTS_DIR', D), directory_files(D, Fs), member(F, Fs), file_name_extension(M, tsv, F), sub_atom(M, 0, _, _, 'M').
attendus(M, Ats) :-
    getenv('MUTANTS_DIR', D), directory_file_path(D, 'attendus.tsv', A),
    read_file_to_string(A, S, []), split_string(S, "\n", "", Ls),
    findall(C-I, ( member(L, Ls), L \== "", split_string(L, "\t", "", [Ms, Cs, I]), atom_string(M, Ms), atom_string(C, Cs) ), Ats0),
    sort(Ats0, Ats).

:- begin_tests(mutants).
test(mutant, [forall(mutant(M))]) :-
    getenv('MUTANTS_DIR', D), getenv('WN30_IDS', P),
    atomic_list_concat([D, '/', M, '.tsv'], F),
    lire_pivot(P), controler(F, Obtenu),
    attendus(M, Attendu), sort(Attendu, A),
    assertion(Obtenu == A).
test(compilation_refusee, [throws(error(compilation_refusee(_, _), _))]) :-
    getenv('MUTANTS_DIR', D), getenv('WN30_IDS', P),
    atomic_list_concat([D, '/M06_vote_atteste.tsv'], F),
    compiler(F, P, '/dev/null').
:- end_tests(mutants).
