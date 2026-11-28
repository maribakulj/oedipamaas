/*  Mesure annexe : lire un fichier Turtle SKOS avec library(semweb/turtle) de SWI-Prolog (rien à installer) ; compte les
    triplets et les concepts SKOS.   LANG=C.UTF-8 swipl turtle_prolog.pl -- FICHIER.ttl  */
:- use_module(library(semweb/turtle)).
:- use_module(library(semweb/rdf11)).
:- initialization(main, main).
main([F]) :-
    statistics(cputime, T0),
    rdf_create_graph(g), rdf_load(F, [format(turtle), graph(g), silent(true)]),
    aggregate_all(count, rdf(_, _, _, g), N),
    aggregate_all(count, rdf(_, rdf:type, 'http://www.w3.org/2004/02/skos/core#Concept', g), C),
    aggregate_all(count, rdf(_, 'http://www.w3.org/2004/02/skos/core#broader', _, g), B),
    statistics(cputime, T1), T is T1 - T0,
    format("triplets ~d ; concepts ~d ; broader ~d ; ~2f s CPU~n", [N, C, B, T]), statistics(memory, [Ko|_]) , format("memoire ~d Ko~n", [Ko]).
