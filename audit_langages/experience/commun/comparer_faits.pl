/*  Compare deux fichiers de faits compilés au niveau des termes (et non des octets), un fait par ligne, les deux
    premières lignes (module, encodage) mises à part.   LANG=C.UTF-8 swipl comparer_faits.pl A.pl B.pl  */
:- initialization(main, main).
:- use_module(library(readutil)).
termes(F, Ts) :-
    read_file_to_string(F, S, [encoding(utf8)]), split_string(S, "\n", "", [_, _|Ls0]), exclude(==(""), Ls0, Ls),
    maplist([L, T]>>term_string(T, L), Ls, Ts0), msort(Ts0, Ts).
main([A, B]) :- termes(A, TA), termes(B, TB), length(TA, NA), length(TB, NB),
    ( TA == TB -> format("termes identiques : ~d~n", [NA]), halt(0) ; format("DIFFERENTS : ~d contre ~d~n", [NA, NB]), halt(1) ).
