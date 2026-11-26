/*  Connaissances des tests génératifs du noyau : un petit vocabulaire et une petite hiérarchie (docs/NOYAU.md, § 2). */
:- module(connaissances_gen, [ sens/3, sous/2, inclus/2, cle_de_nom/2, alias/2, distincts_documentes/3, version/1 ]).
:- encoding(utf8).

version('gen 1').

sens(_, W, W) :- atom(W).
sens(_, poly, 801).                  % un mot polysémique (D30) : deux concepts, qui se lexicalisent en « poly »
sens(_, poly, 802).

sous(a1, a). sous(a2, a). sous(a, top). sous(b1, b). sous(b, top).
sous(p1, p). sous(q, p0). sous(p, p0).
sous(r1, r).
sous(s1, s).

sous(c1, c2). sous(c2, c1).          % un cycle
sous(lemme_a, a).                    % un pas de lexicalisation : sous, mais pas inclus
sous(801, a1). sous(802, b1). sous(801, poly). sous(802, poly).
inclus(A, B) :- sous(A, B), A \== lemme_a, B \== poly.

cle_de_nom(Nom, C) :- upcase_atom(Nom, C).
distincts_documentes('X', 'Z', gen).
alias('XA', 'X').
