/*  Morphologie (conception 1.0, § 7, étape 1) : d'un mot écrit à ses lemmes, par le procédé de WordNet (morphy(7)) :
    les listes d'exceptions d'abord (mice → mouse), puis le mot lui-même s'il est un lemme, puis les règles de
    détachement des terminaisons, en ne gardant que les formes que WordNet connaît. Ce sont des faits généraux de la
    langue anglaise, documentés une fois (morphy(7)), non une liste écrite pour un corpus.

        noms     -s, -ses → -s, -xes → -x, -zes → -z, -ches → -ch, -shes → -sh, -men → -man, -ies → -y
        verbes   -s, -ies → -y, -es → -e, -es, -ed → -e, -ed, -ing → -e, -ing
        adjectifs -er, -est, -er → -e, -est → -e

    Une expression de plusieurs mots est d'abord cherchée entière ; sinon son dernier mot est lemmatisé (« crowns of
    thorns » → « crown of thorns » si WordNet la connaît, d'abord par le premier mot). Un mot que WordNet ignore (nom
    propre, terme technique) garde sa forme.
*/
:- module(morphologie, [ lemmes/3,      % +Mot, ?Type, -Lemmes   (Type : n, v, a, r ; liste triée, peut être vide)
                         lemme/2,       % +Mot, -Lemme           un lemme, tous types confondus, ou le mot lui-même
                         tous_lemmes/2, % +Mot, -Lemmes          tous les lemmes, tous types ; [Mot] si aucun
                         forme_connue/2, % ?Forme, ?Type         forme (minuscules) d'un lemme de WordNet
                         forme_synset/3  % ?Forme, ?Type, ?Synset
                       ]).

:- dynamic forme_connue/2, forme_synset/3.

indexer :-
    retractall(forme_connue(_, _)),
    retractall(forme_synset(_, _, _)),
    forall(wordnet:s(S, _, Mot, T0, _, _),
           ( type(T0, T), downcase_atom(Mot, F), assertz(forme_synset(F, T, S)) )),
    forall(distinct(F-T, forme_synset(F, T, _)), assertz(forme_connue(F, T))).

type(s, a) :- !.
type(T, T).

regle(n, s, '').    regle(n, ses, s).  regle(n, xes, x).  regle(n, zes, z).
regle(n, ches, ch). regle(n, shes, sh). regle(n, men, man). regle(n, ies, y).
regle(v, s, '').    regle(v, ies, y).  regle(v, es, e).   regle(v, es, '').
regle(v, ed, e).    regle(v, ed, '').  regle(v, ing, e).  regle(v, ing, '').
regle(a, er, '').   regle(a, est, '').  regle(a, er, e).   regle(a, est, e).

lemmes(Mot0, Type, Lemmes) :-
    downcase_atom(Mot0, Mot0m),
    normalize_space(atom(Mot), Mot0m),
    member(Type, [n, v, a, r]),
    findall(L, lemme_de(Mot, Type, L), Ls),
    sort(Ls, Lemmes).

lemme_de(Mot, T, L) :- wordnet:exc(T, Mot, L).
lemme_de(Mot, T, Mot) :- forme_connue(Mot, T).
lemme_de(Mot, T, L) :-
    regle(T, Fin, Rempl),
    atom_concat(Racine, Fin, Mot), Racine \== '',
    atom_concat(Racine, Rempl, L),
    forme_connue(L, T).
lemme_de(Mot, T, L) :-                          % expression : premier mot (« crowns of thorns »), puis dernier
    sub_atom(Mot, _, _, _, ' '),
    \+ forme_connue(Mot, T),
    atomic_list_concat(Mots, ' ', Mot),
    (   Mots = [M1|Reste], lemme_simple(M1, T, L1), L1 \== M1,
        atomic_list_concat([L1|Reste], ' ', L), forme_connue(L, T)
    ;   append(Debut, [Dernier], Mots), lemme_simple(Dernier, T, LD), LD \== Dernier,
        append(Debut, [LD], Mots2), atomic_list_concat(Mots2, ' ', L), forme_connue(L, T)
    ).

lemme_simple(M, T, L) :- wordnet:exc(T, M, L).
lemme_simple(M, T, L) :- regle(T, Fin, Rempl), atom_concat(R, Fin, M), R \== '', atom_concat(R, Rempl, L),
                         forme_connue(L, T).

tous_lemmes(Mot, Lemmes) :-
    findall(L, (lemmes(Mot, _, Ls), member(L, Ls)), L0),
    (   L0 == []
    ->  downcase_atom(Mot, M), normalize_space(atom(M1), M), Lemmes = [M1]
    ;   sort(L0, Lemmes)
    ).

% un seul lemme, dans l'ordre fixe des types de WordNet (n, v, a, r) ; le moteur, lui, garde tous les lemmes
% (tous_lemmes/2) et laisse le contexte choisir
lemme(Mot, Lemme) :-
    (   member(T, [n, v, a, r]), lemmes(Mot, T, [L|_]) -> Lemme = L
    ;   downcase_atom(Mot, M), normalize_space(atom(Lemme), M)
    ).

:- initialization(indexer, now).
