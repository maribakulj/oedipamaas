/*  Les clés (+…) (conception 1.0, § 8) : pour une notation soutenue, les clés de sa famille que la description porte.

    Chaque notation a une famille de clés (champ K d'Iconclass : 61Bk pour les portraits, 31k pour la figure humaine,
    25Fk pour les animaux…). Les suffixes d'une famille forment un arbre (« 5 » positions, « 54 » à genoux) ; le
    parent d'un suffixe est le suffixe privé de son dernier chiffre, s'il existe dans la famille. Mots propres d'un
    suffixe : les mots pleins de son texte absents du texte de son parent ; mots distinctifs : ses mots propres
    qu'aucun de ses frères ne porte. On propose N(+S) si un mot distinctif de S est décrit, avec la plus grande part
    distinctive parmi ses frères (« portrait » est commun à la caricature et aux variantes de composition : il ne
    fait rien proposer ; « half » distingue le portrait à mi-corps, « kneeling » la figure à genoux). Les queues
    (« q ») et la variante (+0) ne se proposent pas (rien dans une description ne dit « variante »).

    Index (construit une fois, module cles_index) : cle_parent(K, S, Parent), cle_nb(K, S, Nb), cle_propre(K, S, I, F).
*/
:- module(cles, [ construire_cles/1,  % +Fichier
                  part_cle/3,         % +K, +S, -Part
                  cles_decrites/2     % +Notation, -NotationsAClé
                ]).

:- use_module(libelles).
:- use_module(lexique).
:- use_module(morphologie).
:- use_module(specialisation).

construire_cles(Fichier) :-
    setup_call_cleanup(
        open(Fichier, write, S, [encoding(utf8)]),
        ( format(S, ":- module(cles_index, [cle_parent/3, cle_nb/2, cle_propre/4, cle_nd/2, cle_distinctif/4]).~n", []),
          format(S, ":- encoding(utf8).~n:- discontiguous cle_parent/3, cle_nb/2, cle_propre/4.~n", []),
          forall(( iconclass:suffixe_cle(K, Suf, _), \+ sub_atom(Suf, _, _, _, q), Suf \== '0' ),
                 ( parent_suffixe(K, Suf, P),
                   format(S, "cle_parent(~q, ~q, ~q).~n", [K, Suf, P]),
                   mots_propres_cle(K, Suf, P, Mots),
                   length(Mots, Nb),
                   format(S, "cle_nb(~q, ~d).~n", [K-Suf, Nb]),
                   forall(nth1(I, Mots, M),
                          forall(formes(M, F), format(S, "cle_propre(~q, ~q, ~d, ~q).~n", [K, Suf, I, F]))) )),
          % mots distinctifs : les mots propres dont aucune forme n'est une forme d'un mot propre d'un frère
          forall(( iconclass:suffixe_cle(K, Suf, _), \+ sub_atom(Suf, _, _, _, q), Suf \== '0' ),
                 ( parent_suffixe(K, Suf, P),
                   mots_propres_cle(K, Suf, P, Mots),
                   findall(F2, ( iconclass:suffixe_cle(K, S2, _), S2 \== Suf, \+ sub_atom(S2, _, _, _, q),
                                 S2 \== '0', parent_suffixe(K, S2, P), mots_propres_cle(K, S2, P, M2s),
                                 member(M2, M2s), formes(M2, F2) ), Fs0),
                   sort(Fs0, FormesFreres),
                   findall(I, ( nth1(I, Mots, M), \+ ( formes(M, F), memberchk(F, FormesFreres) ) ), Is),
                   length(Is, Nd),
                   format(S, "cle_nd(~q, ~d).~n", [K-Suf, Nd]),
                   forall(member(I, Is), ( nth1(I, Mots, M),
                                           forall(formes(M, F),
                                                  format(S, "cle_distinctif(~q, ~q, ~d, ~q).~n", [K, Suf, I, F])) )) )) ),
        close(S)).

parent_suffixe(K, Suf, P) :-
    (   atom_length(Suf, L), L > 1, sub_atom(Suf, 0, _, 1, P0), iconclass:suffixe_cle(K, P0, _)
    ->  P = P0
    ;   P = racine
    ).

texte_cle(K, Suf, T) :- ( iconclass:libelle_cle(K, Suf, en, T0) -> T = T0 ; T = '' ).

mots_propres_cle(K, Suf, P, Mots) :-
    texte_cle(K, Suf, T), libelles:mots_pleins(T, Ms),
    (   P == racine -> Mots = Ms
    ;   texte_cle(K, P, TP), libelles:mots_pleins(TP, MP), ord_subtract(Ms, MP, Mots)
    ).

formes(M, F) :-
    lexique:forme_de(M, F0),
    distinct(F, ( F = F0 ; morphologie:tous_lemmes(F0, Ls), member(F, Ls) )).

part_cle(K, Suf, Part) :-
    cles_index:cle_nb(K-Suf, Nb), Nb > 0,
    aggregate_all(count, distinct(I, ( cles_index:cle_propre(K, Suf, I, F), specialisation:decrit(F) )), D),
    Part is D / Nb.

% part distinctive : part des mots propres de S, absents de tous ses frères, qui sont décrits dans l'une des unités
% Us (les unités de la description qui soutiennent la notation)
% les formes qui soutiennent déjà la notation (Exclues) ne prouvent pas ses clés : « positions (of the human
% figure) » répète la figure humaine qui soutient 31A
part_distinctive(K, S, Us, Exclues, Part) :-
    cles_index:cle_nd(K-S, Nd), Nd > 0,
    aggregate_all(count, distinct(I, ( cles_index:cle_distinctif(K, S, I, F), \+ memberchk(F, Exclues),
                                       member(U, Us), specialisation:decrit_dans(F, U) )),
                  D),
    Part is D / Nd.

% une famille est petite (au plus quelques centaines de suffixes) : on l'explore entière ; les catégories générales
% (« positions of the human figure ») ne sont presque jamais décrites et ne doivent pas barrer leurs enfants. Les
% suffixes de premier niveau sont des facettes indépendantes (vue, position, nombre, sexe et âge…) qui s'appliquent
% ensemble ; plus bas, les frères s'excluent (debout ou à genoux) : seule la plus grande part est proposée.
propose(K, Us, Ex, S) :-
    cles_index:cle_parent(K, S, P),
    part_distinctive(K, S, Us, Ex, Pd), Pd > 0,
    (   P == racine
    ->  true
    ;   \+ ( cles_index:cle_parent(K, S2, P), S2 \== S, part_distinctive(K, S2, Us, Ex, Pd2), Pd2 > Pd )
    ).

% les unités et les formes qui soutiennent N : celles de ses appuis lexicaux directs
appuis_de(N, Us, Formes) :-
    findall(U-F, ( recherche:candidat(N, M, p(_, F, egal, _)), specialisation:unite(M, U) ), Ps),
    pairs_keys_values(Ps, Us0, Fs0),
    sort(Us0, Us), sort(Fs0, Formes).

cles_decrites(N, Codes) :-
    (   iconclass:famille_cle(N, K), appuis_de(N, Us, Ex), Us \== []
    ->  findall(C, ( propose(K, Us, Ex, S), atomic_list_concat([N, '(+', S, ')'], C) ), Cs),
        sort(Cs, Codes)
    ;   Codes = []
    ).
