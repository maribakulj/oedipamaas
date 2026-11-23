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
        ( format(S, ":- module(cles_index, [cle_parent/3, cle_nb/2, cle_propre/4]).~n:- encoding(utf8).~n", []),
          format(S, ":- discontiguous cle_parent/3, cle_nb/2, cle_propre/4.~n", []),
          forall(( iconclass:suffixe_cle(K, Suf, _), \+ sub_atom(Suf, _, _, _, q), Suf \== '0' ),
                 ( parent_suffixe(K, Suf, P),
                   format(S, "cle_parent(~q, ~q, ~q).~n", [K, Suf, P]),
                   mots_propres_cle(K, Suf, P, Mots),
                   length(Mots, Nb),
                   format(S, "cle_nb(~q, ~d).~n", [K-Suf, Nb]),
                   forall(nth1(I, Mots, M),
                          forall(formes(M, F), format(S, "cle_propre(~q, ~q, ~d, ~q).~n", [K, Suf, I, F]))) )) ),
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

% part distinctive : part des mots propres de S, absents de tous ses frères, qui sont décrits
part_distinctive(K, S, Part) :-
    cles_index:cle_parent(K, S, P),
    findall(I, ( cles_index:cle_propre(K, S, I, F), \+ ( cles_index:cle_parent(K, S2, P), S2 \== S,
                                                         cles_index:cle_propre(K, S2, _, F) ) ), Is0),
    sort(Is0, Is), length(Is, Nd), Nd > 0,
    aggregate_all(count, ( member(I, Is), once(( cles_index:cle_propre(K, S, I, F2), specialisation:decrit(F2) )) ),
                  D),
    Part is D / Nd.

% une famille est petite (au plus quelques centaines de suffixes) : on l'explore entière ; les catégories générales
% (« positions of the human figure ») ne sont presque jamais décrites et ne doivent pas barrer leurs enfants
propose(K, S) :-
    cles_index:cle_parent(K, S, _),
    part_distinctive(K, S, Pd), Pd > 0,
    cles_index:cle_parent(K, S, P),
    \+ ( cles_index:cle_parent(K, S2, P), S2 \== S, part_distinctive(K, S2, Pd2), Pd2 > Pd ).

cles_decrites(N, Codes) :-
    (   iconclass:famille_cle(N, K)
    ->  findall(C, ( propose(K, S), atomic_list_concat([N, '(+', S, ')'], C) ), Cs),
        sort(Cs, Codes)
    ;   Codes = []
    ).
