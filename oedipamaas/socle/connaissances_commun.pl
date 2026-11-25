/*  Ce que partagent connaissances_en et connaissances_fr (docs/NOYAU.md, § 2). Les nœuds des types : un synset
    (entier de l'édition Prolog de WordNet) ou un lemme (atome). */
:- module(connaissances_commun, []).
:- encoding(utf8).
:- use_module(raisonnement, []).

version(L, V) :- format(atom(V), "wordnet 3.0 ; wolf omw-1.4 ; ~w", [L]).

% le mot lui-même, puis ses sens
sens(_, _, W, W) :- atom(W).
sens(en, C, W, S) :- pos(C, P), once(( between(1, 80, K), member(P1, P), wordnet:s(S, _, W, P1, K, _) )).
sens(fr, C, W, S) :- prefixe(C, Pre), ressources:wolf(S, W), S // 100000000 =:= Pre.
pos(n, [n]). pos(v, [v]). pos(a, [a, s]).
prefixe(n, 1). prefixe(v, 2). prefixe(a, 3).

% un pas vers le haut : l'hyperonyme, l'instance de ; et d'un sens vers chacun de ses lemmes (dans la langue)
sous(_, S, P) :- integer(S), ( wordnet:hyp(S, P) ; wordnet:ins(S, P) ).
sous(en, S, W) :- integer(S), wordnet:s(S, _, W, _, _, _).
sous(fr, S, W) :- integer(S), ressources:wolf(S, W).

cle_de_nom(Nom, C) :- raisonnement:normaliser_nom(Nom, C).
