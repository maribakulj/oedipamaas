/*  Un module de connaissances pour l'essai de complexité (journal, D43) : une échelle de N losanges (héritage multiple,
    comme dans WordNet), 2^N chemins simples du bas vers le haut ; « cible » n'est atteinte de nulle part. */
:- module(connaissances_losange, [ sens/3, sous/2, inclus/2, cle_de_nom/2, alias/2, distincts_documentes/3, version/1 ]).
version('losange 1').
n(24).
sens(_, W, W) :- atom(W).
noeud(L, I, X) :- atom_concat(L, I, X).
sous(X, Y) :-
    n(N), member(L, [a, b]), between(0, N, I), I < N, noeud(L, I, X), I1 is I + 1, member(L2, [a, b]), noeud(L2, I1, Y).
inclus(X, Y) :- sous(X, Y).
cle_de_nom(Nom, C) :- upcase_atom(Nom, C).
alias(_, _) :- fail.
distincts_documentes(_, _, _) :- fail.
