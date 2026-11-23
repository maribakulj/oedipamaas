/*  Point d'entrée de la commande (socle/oedipamaas.pl, main/1) :
    swipl oedipamaas/socle/commande.pl --base BASE --entree ENTREE.jsonl --sortie SORTIE.jsonl */
:- use_module(oedipamaas).
:- initialization(main, main).
main :- current_prolog_flag(argv, Argv), oedipamaas:main(Argv).
