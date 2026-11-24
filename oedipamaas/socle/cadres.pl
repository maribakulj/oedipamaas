/*  Les cadres des libellés (conception 1.0, R3) : ce que dit un libellé d'Iconclass, lu par une grammaire et non
    découpé en mots. Un libellé est une formule : une phase éventuelle (« before the battle »), des éléments (synonymes
    « ; », listes « , ») dont chacun a une ou plusieurs têtes coordonnées (« mother and child »), chacune avec ses
    modificateurs (« standing figure », « hunting dog »), des compléments après la tête (« portraits of Christ »,
    « hand in the sleeve »), des apartés entre parenthèses (laissés de côté : exemples, précisions facultatives) et un
    contexte après « ~ » (« gods ~ classical mythology »).

    La tête d'un élément est son dernier mot avant le premier mot de liaison (préposition, virgule) qui soit d'abord
    un nom pour WordNet (plus souvent nom qu'autre chose : « sitting » est d'abord un verbe, « Mary » un nom) ; un
    élément sans nom est une action (« training », « putting on ») : sa tête est son premier mot.

    Preuve d'un cadre par une unité de la description (une entité, une personne, une entrée de champ) : la notation n'y
    est expliquée que si **sa tête y est impliquée** — dite telle quelle ou par le pont, ou parce qu'une chose de
    l'unité en est une espèce (WordNet : « lioness » est un « lion », « man » une « person ») — ou, pour une tête
    héritée d'un ancêtre qui la définit (« standing figure » sous « the human figure »), par l'un des mots clés que
    Iconclass donne à cet ancêtre (man, woman, body) ; si son contexte est dit quelque part dans la description ; et
    jamais pour un libellé de phase. « Mary sitting or enthroned, the Christ-child on her knee » n'est pas expliquée
    par « dark knee-length garment » : le genou y est, Marie non.
*/
:- module(cadres, [ cadre/2,             % +N, -cadre(Phase, Elements, Contexte)
                    construire_cadres/1, % +Fichier (index cadres_index : cadre_i/4)
                    tetes/2,             % +N, -Tetes (formes, tous éléments)
                    preparer_cadres/0,   % fermeture des sens décrits, par unité (description courante)
                    tete_impliquee/3,    % +N, +Tete, ?Unite
                    cadre_prouve/2,      % +N, ?Unite
                    pleine_et_cadree/2   % ?N, ?Unite (pleine et cadre prouvé dans la même unité)
                  ]).

:- use_module(libelles).
:- use_module(lexique).
:- use_module(morphologie).
:- use_module(specialisation).
:- use_module(arbre).

:- dynamic sens_dans/2.

% --- Grammaire ------------------------------------------------------------------------------------------------------

% cadre(N, cadre(Phase, Elements, Contexte)) ; Elements : liste de element(Tetes, Complements), Tetes : liste de
% tete(Forme, Modificateurs) (Forme = action(Verbe) pour une action) ; lu dans l'index s'il est chargé, calculé sinon
% (clés, noms écrits dans un gabarit)
cadre(N, Cadre) :-
    (   current_predicate(cadres_index:cadre_i/4), cadres_index:cadre_i(N, P, E, X)
    ->  Cadre = cadre(P, E, X)
    ;   cadre_calcule(N, Cadre)
    ).

% index (construit une fois) : cadre_i(N, Phase, Elements, Contexte) pour chaque notation qui a un libellé
construire_cadres(Fichier) :-
    setup_call_cleanup(
        open(Fichier, write, S, [encoding(utf8)]),
        ( format(S, ":- module(cadres_index, [cadre_i/4]).~n:- encoding(utf8).~n", []),
          forall(( iconclass:n(N), iconclass:libelle(N, en, _), cadre_calcule(N, cadre(P, E, X)) ),
                 format(S, "cadre_i(~q, ~q, ~q, ~q).~n", [N, P, E, X])) ),
        close(S)).

% pleine_et_cadree(?N, ?U) : U dit toute une alternative de N (specialisation:pleine_large_dans/2) et prouve son cadre
pleine_et_cadree(N, U) :-
    specialisation:pleine_large_dans(N, U),
    cadre_prouve(N, U).

cadre_calcule(N, cadre(Phase, Elements, Contexte)) :-
    ( libelles:phase(N, Phase) -> true ; Phase = [] ),
    textes_elements(N, Textes),
    findall(E, ( member(T, Textes), element(T, E) ), Elements),
    (   libelles:concept_contexte(N, _, C0)
    ->  libelles:hors_parentheses(C0, C1), libelles:mots_pleins(C1, Contexte)
    ;   Contexte = []
    ).

% les textes des éléments : ceux de libelles:elements/2 pour un libellé simple ; pour un libellé fabriqué
% (« … - BB - woman »), ceux de sa première partie, la base
textes_elements(N, Textes) :-
    (   libelles:elements(N, Es), Es \== [] -> Textes = Es
    ;   libelles:principal(N, P), libelles:hors_parentheses(P, H), Textes = [H]
    ).

tetes(N, Tetes) :-
    cadre(N, cadre(_, Elements, _)),
    findall(T, ( member(element(Ts, _), Elements), member(tete(X, _), Ts), ( X = action(T) -> true ; T = X ) ), T0),
    sort(T0, Tetes).

element(Texte, element(Tetes, Complements)) :-
    jetons(Texte, Js0),
    action_et_objet(Js0, Tetes, Complements), !.
element(Texte, element(Tetes, Complements)) :-
    jetons(Texte, Js00),
    ( Js00 = [C0|Js01], memberchk(C0, [and, or]) -> true ; Js01 = Js00 ),
    proposition_participe(Js01, Js0, Participe),
    exclude(phase_ou_article, Js0, Js1),
    ( Js1 = [C|Js], memberchk(C, [and, or]) -> true ; Js = Js1 ),     % « …, or mule » : la suite d'une liste
    (   append(Avant, [L|Apres], Js), liaison(L) -> true ; Avant = Js, Apres = [] ),
    morceaux_coordonnes(Avant, Morceaux),
    findall(T, ( member(M, Morceaux), M \== [], tete_du_morceau(M, T) ), Tetes),
    Tetes \== [],
    append(Apres, Participe, Suite),
    findall(F, ( member(J, Suite), \+ liaison(J), \+ phase_ou_article(J), \+ memberchk(J, [and, or]),
                 nom_dominant(J, F) ), Complements).

% une proposition participe dans l'élément : un gérondif suivi d'un article ou d'un possessif, après la tête (« people
% spreading their clothes before Christ » : la tête est « people », le reste dit ce qu'ils font) ; Tete : ce qui la
% précède, Participe : la proposition (ses noms deviennent des compléments)
proposition_participe(Js, Tete, Participe) :-
    (   append(Tete, [G, Art|R], Js), Tete \== [],
        sub_atom(G, _, 3, 0, ing), \+ nom_dominant(G, _),
        memberchk(Art, [the, a, an, his, her, its, their])
    ->  Participe = [G, Art|R]
    ;   Tete = Js, Participe = []
    ).

% une action et son objet : un gérondif suivi d'un article (« opening the window », « killing the dragon ») — la tête
% est l'action ; « standing figure », sans article, est une figure qui se tient debout
action_et_objet([G, Art|Reste], [tete(action(G), [])], Complements) :-
    sub_atom(G, _, 3, 0, ing), \+ nom_dominant(G, _),
    memberchk(Art, [the, a, an, his, her, its, their]),
    findall(F, ( member(J, Reste), \+ liaison(J), \+ phase_ou_article(J), nom_dominant(J, F) ), Complements).

jetons(Texte, Jetons) :-
    downcase_atom(Texte, T),
    split_string(T, " ,;:", " ,;:'\"", Morceaux0),
    findall(A, ( member(S, Morceaux0), S \== "", atom_string(A, S) ), Jetons).

liaison(J) :- memberchk(J, [of, with, in, on, at, by, as, from, to, into, onto, for, under, over, near, among,
                            between, against, during, through, behind, beside, around, upon, towards, about, without,
                            before, after, while, whose, who, which, that, being, e, g, 'e.g.', 'i.e.', i]).

phase_ou_article(J) :- memberchk(J, [the, a, an, his, her, its, their, other, '(other)', some, two, three, one]).

morceaux_coordonnes(Js, Morceaux) :-
    atomic_list_concat(Js, ' ', T),
    atomic_list_concat(Ps, ' and ', T),
    findall(M, ( member(P, Ps), atomic_list_concat(Qs, ' or ', P), member(Q, Qs),
                 atomic_list_concat(M0, ' ', Q), exclude(==(''), M0, M) ), Morceaux).

% la tête d'un morceau : la plus longue fin de morceau que WordNet connaît comme nom dominant (« hunting dog »,
% « dry nurse »), sinon son dernier nom dominant ; sans nom, son premier mot (une action)
tete_du_morceau(M, tete(Tete, Modifs)) :-
    (   append(Mods, Fin, M), Fin \== [], atomic_list_concat(Fin, ' ', F0), nom_dominant(F0, Tete)
    ->  Modifs = Mods
    ;   append(Avant, [J|Apres], M), nom_dominant(J, Tete), \+ ( member(K, Apres), nom_dominant(K, _) )
    ->  append(Avant, Apres, Modifs)
    ;   M = [J|Modifs], verbe(J), lexique:forme_de(J, F)                % sans nom dominant, un verbe : une action
    ->  Tete = action(F)
    ;   append(Avant, [J|Apres], M), nom_possible(J, Tete), \+ ( member(K, Apres), nom_possible(K, _) )
    ->  append(Avant, Apres, Modifs)                                     % un nom tout de même (« ass »)
    ;   last(M, J), append(Modifs, [J], M), lexique:forme_de(J, Tete)   % inconnu de WordNet (un nom, un composé :
    ).                                                                   % « christ-child ») : dit tel quel

verbe(J) :- morphologie:tous_lemmes(J, Ls), member(L, [J|Ls]), morphologie:forme_connue(L, v), !.

nom_possible(J, F) :-
    atomic_list_concat(Ps, '-', J), atomic_list_concat(Ps, ' ', J1),
    morphologie:tous_lemmes(J1, Ls), member(F, [J1|Ls]), morphologie:forme_connue(F, n), !.

% nom_dominant(+Mot, -Forme) : le mot (traits d'union en espaces) ou l'un de ses lemmes est un nom de WordNet, plus
% souvent nom qu'autre chose — y compris que le verbe dont il serait une forme (« sitting » : sit ; « standing » :
% stand ; ce sont des verbes, pas des têtes)
nom_dominant(J, F) :-
    atomic_list_concat(Ps, '-', J), atomic_list_concat(Ps, ' ', J1),
    morphologie:tous_lemmes(J1, Ls),
    distinct(F, ( F = J1 ; member(F, Ls) )),
    nom_d_abord(F, [J1|Ls]), !.

nom_d_abord(F, Formes) :-
    once(morphologie:forme_synset(F, n, _)),                 % formes en minuscules : « virgin mary »
    aggregate_all(max(C), ( morphologie:forme_synset(F, n, S), occurrences(F, S, C) ), Cn),
    \+ ( member(G, Formes), morphologie:forme_synset(G, T, S2), T \== n, occurrences(G, S2, C2), C2 > Cn ).

occurrences(F, S, C) :- once(( wordnet:s(S, _, W, _, _, C), downcase_atom(W, F) )).

% --- Implication ----------------------------------------------------------------------------------------------------

% sens_dans(S, U) : S est un sens dominant d'une forme décrite dans l'unité U, ou l'un de ses hyperonymes
preparer_cadres :-
    retractall(sens_dans(_, _)),
    forall(distinct(S0-U, ( specialisation:decrit_dans(F, U), lexique:sens_dominant(F, S0) )), monter(S0, U)).

monter(S, U) :-
    (   sens_dans(S, U) -> true
    ;   assertz(sens_dans(S, U)),
        forall(( wordnet:hyp(S, P) ; wordnet:ins(S, P) ), monter(P, U))
    ).

% la tête est impliquée dans l'unité : dite (forme ou lemme, tel quel ou par le pont), ou l'un de ses sens de nom
% couvre une chose de l'unité
implique(T, U) :-
    (   specialisation:formes(T, F), specialisation:dite_dans(F, U) -> true
    ;   morphologie:forme_synset(T, n, S), sens_dans(S, U) -> true
    ).

% tete_impliquee(+N, +Tete, ?U) : impliquée telle quelle, ou par les mots clés de l'ancêtre qui la définit — le plus
% général des ancêtres stricts de N dont un élément a cette tête et qui porte des mots clés (« figure » : 31A « the
% human figure », mots clés man, woman, body ; jamais les mots clés de N lui-même, qui disent ses aspects : le genou
% de 11F422 ne dit pas Marie)
tete_impliquee(N, action(A), U) :- !,
    % une action se prouve par elle-même, dans ce que la description donne pour des actions (actions, gestes,
    % relations, le sujet) : « putting on stockings » n'est pas dit par « dark stockings », ni « opening the window »
    % par « open door frame » ; jamais par les mots clés d'un ancêtre, qui nomment les choses, pas l'action
    distinct(U, specialisation:decrit_dans(_, U)),
    champ_d_action(U),
    once(( specialisation:formes(A, F), specialisation:dite_dans(F, U) )).
tete_impliquee(N, T, U) :-
    acte(T), !,
    tete_impliquee(N, action(T), U).
tete_impliquee(N, T, U) :-
    distinct(U, specialisation:decrit_dans(_, U)),
    (   implique(T, U) -> true
    ;   ancetre_definissant(N, T, A),
        iconclass:mot_cle(A, en, K), lexique:forme_de(K, FK), implique(FK, U) -> true
    ).

% une action ne se prouve pas par la description d'une chose (les attributs d'une entité, les traits d'une personne :
% « open door frame », « arms raised ») ; partout ailleurs, oui (actions, gestes, relations, sujet, mots clés…)
champ_d_action(U) :-
    \+ sub_atom(U, 0, _, _, 'entities['), \+ sub_atom(U, 0, _, _, 'persons[').

% un nom qui nomme un acte (sous « human action » dans WordNet, par son sens dominant : « training », « raising »,
% « baptism ») est une action
acte(T) :-
    once(wordnet:s(P, _, 'human action', n, _, _)),
    once(( lexique:sens_dominant(T, S), morphologie:forme_synset(T, n, S), ( S == P ; monte_jusqua(S, P) ) )).

monte_jusqua(S, P) :- ( wordnet:hyp(S, Q) ; wordnet:ins(S, Q) ), ( Q == P -> true ; monte_jusqua(Q, P) ), !.

ancetre_definissant(N, T, A) :-
    findall(A0, ( arbre:ancetre(N, A0), tetes(A0, Ts), memberchk(T, Ts), once(iconclass:mot_cle(A0, en, _)) ), As),
    last(As, A).

% cadre_prouve(+N, ?U) : l'unité U prouve le cadre de N — pas de phase, une tête d'un élément impliquée dans U, le
% contexte dit quelque part
cadre_prouve(N, U) :-
    cadre(N, cadre([], Elements, Contexte)),
    forall(member(M, Contexte), mot_implique_partout(M)),
    distinct(U, ( member(element(Ts, Cs), Elements), member(tete(T, _), Ts), tete_impliquee(N, T, U),
                  forall(member(C, Cs), complement_implique(C, U)) )).

% un complément de l'élément (« portraits of Christ », « hand in the sleeve ») : impliqué dans la même unité, ou dans
% une unité liée (la description dit « e1 holds e3 ») — variante mesurée : n'importe où dans la description
:- dynamic portee_complements/1.
portee_complements(unite).
complement_implique(C, U) :-
    (   portee_complements(partout) -> mot_implique_partout(C)
    ;   ( implique(C, U) -> true ; specialisation:formes(C, F), specialisation:dite_dans(F, _), unite_liee(U, F) )
    ).

% une forme dite dans une unité liée à U par une relation de la description, dans son sens : l'entité de U (celle de
% la tête) en est le sujet, celle du complément l'objet — « e1 holds e3 » donne à la figure e1 l'objet e3, pas
% l'inverse
unite_liee(U, F) :-
    specialisation:dite_dans(F, U2), U2 \== U,
    entite_de_unite(U, E1), entite_de_unite(U2, E2),
    description:relation(E1, _, E2), !.

entite_de_unite(U, E) :-
    atom_concat('entities[', R, U), atom_concat(I0, ']', R), atom_number(I0, I),
    findall(E0, description:entite(E0, _, _, _, _), Es), nth0(I, Es, E).

mot_implique_partout(M) :-
    (   specialisation:mot_dit(M) -> true
    ;   specialisation:formes(M, F), morphologie:forme_synset(F, n, S), sens_dans(S, _) -> true
    ).
