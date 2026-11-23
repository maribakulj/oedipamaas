/*  Recherche des candidats (conception 1.0, § 8, première étape), sur les faits du module description.

    Chaque mention est découpée en mots (lettres, traits d'union, apostrophes), puis en suites d'un à quatre mots
    consécutifs qui ne commencent ni ne finissent par un mot vide ; chaque suite est cherchée telle quelle et par ses
    lemmes dans l'index d'Iconclass (lexique_index:entree/3), dans toutes les divisions, sans filtre.

    Pont WordNet : seulement les liens qui ne rendent pas le code plus précis que ce qui est décrit — synonyme,
    hyperonyme à deux pas au plus (la description dit « spaniel », Iconclass « dog »), dérivé, pertainym, adjectif
    similaire, « partie de » (la description dit « backrest », Iconclass « chair »). Jamais l'hyponyme ni le tout vers
    la partie : « bird » ne prouve pas « eagle ».

    Chaque candidat garde sa dérivation : p(Mention, Forme, Lien, Source). Classement provisoire, en attendant la
    décision apprise (§ 9) : BM25 (k1 = 1,2 ; b = 0,75, valeurs d'usage, non réglées) sur les formes distinctes qui
    atteignent directement la notation, un document étant l'ensemble des entrées d'une notation dans l'index (sa
    longueur corrige l'avantage des longs libellés), puis la même somme pour les formes atteintes par WordNet
    seulement. Les ancêtres des candidats sont rendus à part (ancetres_des_premiers/3) : ils ne prennent pas de place
    dans le classement.
*/
:- module(recherche, [ preparer/0,               % formes des mentions de la description courante, une fois
                       forme_mention/2,          % ?M, ?Forme
                       candidat/3,               % ?N, ?M, -Preuve
                       classement/2,             % +Max, -Liste de c(Notation, cle(Direct, WordNet), Nature)
                       classement_champs/3,      % +Champs, +Max, -Liste (mentions de ces champs seulement)
                       ancetres_des_premiers/3   % +Liste, +K, -Ancetres (parents canoniques des K premiers)
                     ]).

:- use_module(lexique).
:- use_module(morphologie).
:- use_module(libelles).
:- use_module(arbre).

% --- Découpage des mentions -----------------------------------------------------------------------------------------

mots_de_mention(Texte, Mots) :-
    lexique:forme_de(Texte, F),
    atom_codes(F, Cs),
    phrase(jetons(Mots), Cs).

jetons([M|Ms]) --> jeton(Cs), { Cs \== [] }, !, { atom_codes(M, Cs) }, jetons(Ms).
jetons(Ms) --> [_], !, jetons(Ms).
jetons([]) --> [].
jeton([C|Cs]) --> [C], { code_type(C, alpha), \+ code_type(C, digit(_)), C \== 0'_ ; C == 0'- }, !, jeton(Cs).
jeton([]) --> [].

extremite(M) :- atom_length(M, L), L >= 2, \+ libelles:mot_vide(M), \+ sub_atom(M, 0, _, _, '-').

suite(Mots, Suite) :-
    append(_, Fin, Mots),
    between(1, 4, K), length(Suite0, K), append(Suite0, _, Fin),
    Suite0 = [Premier|_], last(Suite0, Dernier),
    extremite(Premier), extremite(Dernier),
    atomic_list_concat(Suite0, ' ', Suite).

% les formes des mentions et les appuis des candidats sont calculés une fois par description (preparer/0) et gardés
% en faits, indexés par notation
:- dynamic fm/2, ap/3.
preparer :-
    retractall(fm(_, _)),
    retractall(ap(_, _, _)),
    forall(distinct(M-F, forme_mention_calculee(M, F)), assertz(fm(M, F))),
    forall(distinct(N-M-P, candidat_calcule(N, M, P)), assertz(ap(N, M, P))).

forme_mention(M, Forme) :- fm(M, Forme).

% une mention est lue telle quelle et avec ses traits d'union remplacés par des espaces : « half-length » donne
% « half-length », « half », « length » et « half length » (Iconclass écrit l'un ou l'autre)
forme_mention_calculee(M, Forme) :-
    description:mention(M, _, _, Texte00),
    avant_negation(Texte00, Texte0),
    (   Texte = Texte0
    ;   sub_atom(Texte0, _, _, _, '-'), atomic_list_concat(Morceaux, '-', Texte0), atomic_list_concat(Morceaux, ' ', Texte)
    ),
    mots_de_mention(Texte, Mots),
    distinct(Forme, ( suite(Mots, S), ( Forme = S ; morphologie:tous_lemmes(S, Ls), member(Forme, Ls) ) )).

% une négation porte sur ce qui la suit : on ne garde de la mention que ce qui la précède. Niée tout entière
% (« no landscape », « without frame », « not visible », « absence of colour ») elle ne donne aucune forme ; niée en
% son milieu (« depicted without a lion », « a saint, no lion visible ») elle garde ce qui précède la négation.
% Faute d'analyse de la portée, tout ce qui suit est écarté, même au-delà d'un « but » : précision d'abord.
avant_negation(Texte, Avant) :-
    downcase_atom(Texte, T),
    atomic_list_concat(['', T, ''], ' ', T1),
    findall(B, ( negation(Neg), atomic_list_concat([' ', Neg, ' '], Motif),
                 sub_atom(T1, B, _, _, Motif) ), Bs),
    (   negation_postposee(Post), atomic_list_concat([' ', Post, ' '], MotifP), sub_atom(T1, _, _, _, MotifP)
    ->  Avant = ''                                       % « lion absent », « skull missing » : la mention entière
    ;   Bs == []
    ->  Avant = Texte
    ;   min_list(Bs, B0),
        sub_atom(Texte, 0, B0, _, Avant0),
        normalize_space(atom(Avant), Avant0)
    ).

negation(no).
negation(not).
negation(without).
negation(neither).
negation(nor).
negation(never).
negation('lack of').
negation('absence of').

negation_postposee(absent).
negation_postposee(missing).
negation_postposee(invisible).

niee(Texte) :- avant_negation(Texte, '').

% --- Candidats ------------------------------------------------------------------------------------------------------

lien_admis(synonyme).
lien_admis(hyperonyme).
lien_admis(derive).
lien_admis(pertainym).
lien_admis(similaire).
lien_admis(partie_de).

candidat(N, M, P) :- ap(N, M, P).

candidat_calcule(N, M, p(M, F, egal, Src)) :-
    forme_mention(M, F),
    lexique_index:entree(F, N, Src).
candidat_calcule(N, M, p(M, G, wordnet(Rel, Pas, F), Src)) :-
    forme_mention(M, F),
    morphologie:forme_connue(F, _),
    lexique:voisin(F, G, Rel, Pas),
    lien_admis(Rel),
    \+ lexique_index:entree(F, N, _),
    lexique_index:entree(G, N, Src).

% --- Classement provisoire ------------------------------------------------------------------------------------------

k1(1.2).
b(0.75).

% statistiques de l'index, calculées une fois : nombre de notations, longueur de chaque document, longueur moyenne
:- dynamic stats/2, longueur/2.
statistiques :-
    (   stats(n, _) -> true
    ;   forall(distinct(N-C, aggregate(count, F^S^(lexique_index:entree(F, N, S)), C)), assertz(longueur(N, C))),
        aggregate_all(count, longueur(_, _), Nd), aggregate_all(sum(C), longueur(_, C), Tot),
        Moy is Tot / Nd, assertz(stats(n, Nd)), assertz(stats(moyenne, Moy))
    ).

:- table frequence/2.
frequence(F, D) :- aggregate_all(count, distinct(N, lexique_index:entree(F, N, _)), D).

poids(F, N, P) :-
    frequence(F, D), D > 0, stats(n, Nd), stats(moyenne, Moy),
    aggregate_all(count, lexique_index:entree(F, N, _), Tf),
    ( longueur(N, L) -> true ; L = Moy ),
    k1(K1), b(B),
    Idf is log(1 + (Nd - D + 0.5) / (D + 0.5)),
    P is Idf * Tf * (K1 + 1) / (Tf + K1 * (1 - B + B * L / Moy)).

classement(Max, Liste) :-
    classement_mentions(_, Max, Liste).

% le même classement, sur les seules mentions de certains champs (le sujet : l'énoncé principal de la description)
classement_champs(Champs, Max, Liste) :-
    classement_mentions(Champs, Max, Liste).

classement_mentions(Champs, Max, Liste) :-
    statistiques,
    findall(N-(Nature-F), ( candidat(N, M, p(_, F0, Lien, _)), dans_champs(M, Champs), nature(Lien, F0, F, Nature) ),
            Paires),
    sort(Paires, Uniques),
    group_pairs_by_key(Uniques, ParNotation),
    findall(c(N, cle(D, W), direct),
            ( member(N-Formes, ParNotation),
              somme_poids(direct, N, Formes, D), somme_poids(wordnet, N, Formes, W) ),
            Directs),
    sort(2, @>=, Directs, Tries),
    length(Tries, L), Max1 is min(Max, L), length(Liste, Max1), append(Liste, _, Tries).

dans_champs(_, Champs) :- var(Champs), !.
dans_champs(M, Champs) :- description:mention(M, C, _, _), memberchk(C, Champs).

% la forme qui compte pour le poids : celle de l'index (pour WordNet, la forme d'Iconclass atteinte)
nature(egal, F, F, direct).
nature(wordnet(_, _, _), G, G, wordnet).

somme_poids(Nature, N, Formes, S) :-
    findall(P, ( member(Nature-F, Formes), poids(F, N, P) ), Ps),
    sum_list(Ps, S).

ancetres_des_premiers(Liste, K, Ancetres) :-
    length(Liste, L), K1 is min(K, L), length(Premiers, K1), append(Premiers, _, Liste),
    findall(A, ( member(c(N, _, _), Premiers), arbre:ancetre(N, A) ), As0),
    findall(N, member(c(N, _, _), Premiers), Ns),
    sort(As0, As1), ord_subtract(As1, Ns, Ancetres).
