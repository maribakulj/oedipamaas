/*  Le module de connaissances du noyau pour les textes en français (docs/NOYAU.md, § 2), sur WordNet 3.0 et WOLF.
    Les types d'une requête sont des lemmes ; un lemme est un nœud au-dessus de chacun de ses sens (un lemme d'une
    requête vaut l'union de ses sens, jusqu'à ce que la compilation choisisse des sens : C7). Un mot du texte désigne
    lui-même (égalité) et ses sens dans WOLF.
    Chargé après la base (wordnet, ressources).  */
:- module(connaissances_fr, [ sens/3, sous/2, inclus/2, cle_de_nom/2, alias/2, distincts_documentes/3, version/1 ]).
:- encoding(utf8).
:- use_module(connaissances_commun).

version(V) :- connaissances_commun:version(fr, V).
sens(C, W, S) :- connaissances_commun:sens(fr, C, W, S).
sous(S, P) :- connaissances_commun:sous(fr, S, P).
inclus(S, P) :- connaissances_commun:inclus(S, P).
distincts_documentes(_, _, _) :- fail.
cle_de_nom(Nom, C) :- connaissances_commun:cle_de_nom(Nom, C).
alias(_, _) :- fail.
