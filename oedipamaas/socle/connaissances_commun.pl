/*  Ce que partagent connaissances_en et connaissances_fr (docs/NOYAU.md, § 2). Les nœuds des types : un synset
    (entier de l'édition Prolog de WordNet) ou un lemme (atome). */
:- module(connaissances_commun, []).
:- encoding(utf8).
:- use_module(raisonnement, []).

version(L, V) :- format(atom(V), "wordnet 3.0 ; wolf omw-1.4 ; ~w", [L]).

% le mot lui-même, et sa graphie avec espaces au lieu de traits d'union (et l'inverse : « water-bird », « water bird ») ;
% puis ses sens (de l'une et l'autre graphie)
sens(_, _, W, W) :- atom(W).
sens(_, _, W, W2) :- atom(W), graphie(W, W2).
sens(L, C, W, S) :- atom(W), graphie(W, W2), sens_(L, C, W2, S).
sens(L, C, W, S) :- sens_(L, C, W, S).
graphie(W, W2) :- sub_atom(W, _, _, _, '-'), atomic_list_concat(Ps, '-', W), atomic_list_concat(Ps, ' ', W2).
graphie(W, W2) :- sub_atom(W, _, _, _, ' '), atomic_list_concat(Ps, ' ', W), atomic_list_concat(Ps, '-', W2).
% tous les sens du mot (D30, décision du 27/11) : le premier sens de WordNet n'est pas choisi en silence ; le choix
% d'un sens est une désambiguïsation (C7), et le noyau ne tire d'un mot polysémique que ce que tous ses sens disent
sens_(en, C, W, S) :-
    (   getenv('OEDIPAMAAS_SENS_EN', premier)          % mesure seulement (l'effet de D30) : le premier sens, comme avant
    ->  pos(C, P), once(( between(1, 80, K), member(P1, P), wordnet:s(S, _, W, P1, K, _) ))
    ;   pos(C, P), member(P1, P), wordnet:s(S, _, W, P1, _, _)
    ).
sens_(fr, C, W, S) :- prefixe(C, Pre), ressources:wolf(S, W), S // 100000000 =:= Pre.
pos(n, [n]). pos(v, [v]). pos(a, [a, s]).
prefixe(n, 1). prefixe(v, 2). prefixe(a, 3).

% un pas vers le haut : l'hyperonyme, l'instance de ; et d'un sens vers chacun de ses lemmes (dans la langue)
sous(_, S, P) :- integer(S), ( wordnet:hyp(S, P) ; wordnet:ins(S, P) ).
sous(L, S, W) :- integer(S), lemme(L, S, W0), ( W = W0 ; graphie(W0, W) ).
lemme(en, S, W) :- wordnet:s(S, _, W, _, _, _).
lemme(fr, S, W) :- ressources:wolf(S, W).

% l'inclusion sémantique : l'hyperonymie et l'instance de WordNet, jamais la lexicalisation (d'un sens vers un lemme)
inclus(S, P) :- integer(S), ( wordnet:hyp(S, P) ; wordnet:ins(S, P) ).

cle_de_nom(Nom, C) :- raisonnement:normaliser_nom(Nom, C).
