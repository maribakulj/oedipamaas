/*  Connaissances des tests génératifs du noyau : un petit vocabulaire et une petite hiérarchie (docs/NOYAU.md, § 2). */
:- module(connaissances_gen, [ sens/3, sous/2, cle_de_nom/2, alias/2, version/1 ]).
:- encoding(utf8).

version('gen 1').

sens(_, W, W) :- atom(W).

sous(a1, a). sous(a2, a). sous(a, top). sous(b1, b). sous(b, top).
sous(p1, p). sous(q, p0). sous(p, p0).
sous(r1, r).
sous(s1, s).

cle_de_nom(Nom, C) :- upcase_atom(Nom, C).
alias('XA', 'X').
