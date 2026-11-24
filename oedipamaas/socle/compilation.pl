/*  Le statut de compilation d'une définition et le sens de ses mots (docs/FONDEMENTS.md, § 3 ; décision du 25/11 :
    seule une définition « compilée » peut établir un code).

    statut(+N, +Langue, +Def, -Statut, -Raisons)
      compilee              la définition dit tout ce que le libellé exige, avec sa structure : chaque unité d'une scène
                            est dans le graphe de sa lecture, chaque événement y a au moins un participant
      partielle             des mots du libellé ne sont exigés qu'en vrac (une scène dont un verbe n'a aucun participant
                            lu, ou dont une unité est hors du graphe) : la projection n'en tire qu'un candidat
      non_prise_en_charge   une rubrique, une clé « (+…) », un gabarit dont le nom est à remplir « (...) » ; et (écrit par
                            le compilateur) une notation dont la définition n'a pu être tirée (un individu sans nom sûr)
      invalide              une définition mal formée (une alternative vide)
    L'ambiguïté du libellé n'est pas un statut : la coordination est lue de la façon la plus exigeante (definitions.pl,
    segments_complets/3) et un mot dont le sens n'est pas déterminé n'est reconnu que tel quel (sens_de_mot/5).

    sens_de_mot(+N, +Langue, +Mot, -Synsets, -Origine)
      Les sens de WordNet 3.0 qu'un mot de la définition désigne, pour reconnaître dans un texte un mot plus spécifique
      (« lionne » pour « lion », « dague » pour « arme »). Dans l'ordre :
        bilingue    les sens que le mot partage avec un mot de la définition dans l'autre langue (les deux libellés
                    d'Iconclass sont des traductions l'un de l'autre : « lion » et « lion » ont en commun le seul sens
                    animal ; WOLF pour le français)
        hierarchie  les sens qui sont sous un sens d'un mot d'une notation ancêtre (« bat » sous « animals »)
        unique      tous les sens d'une même catégorie (lexfile) de WordNet : rien à choisir
        aucun       sinon : [] ; le mot n'est reconnu que tel quel (sûr d'abord)
      Par partie du discours : un nom et un verbe homographes sont choisis chacun de leur côté.
*/
:- module(compilation, [ statut/5, sens_de_mot/5, mots_de_definition/2, sous_sens/2, nombre_de/2 ]).
:- encoding(utf8).
:- use_module(arbre).
:- use_module(library(yall)).
:- use_module(library(ordsets)).
:- use_module(raisonnement, []).

% --- Le statut -------------------------------------------------------------------------------------------------------

statut(N, _, _, non_prise_en_charge, [cle]) :- sub_atom(N, _, _, _, '(+'), !.
statut(_, _, def(rubrique, _, _, _, _), non_prise_en_charge, [rubrique]) :- !.
statut(_, _, def(_, Ex, _, _, _), non_prise_en_charge, [nom_a_remplir]) :-
    member(un_de(As), Ex), member(A, As), memberchk(nom(a_remplir), A), !.
statut(_, _, def(_, Ex, _, _, _), invalide, [alternative_vide]) :-
    ( Ex == [] ; member(un_de(As), Ex), ( As == [] ; memberchk([], As) ) ), !.
statut(_, _, def(scene, Ex, _, Cs, _), partielle, Rs) :-
    ( memberchk(assertions(Fd), Cs) -> true ; Fd = [] ),
    findall(R, raison_partielle(Ex, Fd, R), Rs0), sort(Rs0, Rs), Rs \== [], !.
statut(_, _, _, compilee, []).

raison_partielle(_, Fd, evenement_sans_participant(P)) :-
    member(evenement(V, P, _), Fd), \+ ( member(role(V, _, E), Fd), member(entite(E, _, _), Fd) ).
raison_partielle(Ex, Fd, hors_du_graphe(W)) :-
    member(un_de(As), Ex), member(A, As), member(mot(W), A), \+ dans_le_graphe(Fd, W).
raison_partielle(Ex, Fd, hors_du_graphe(K)) :-
    member(un_de(As), Ex), member(A, As), member(nom([K|_]), A), \+ nom_du_graphe(Fd, K),
    \+ heritee(Ex, K).

dans_le_graphe(Fd, W) :-
    (   member(entite(_, T, _), Fd) ; member(evenement(_, T, _), Fd) ; member(propriete(_, _, T, _), Fd)
    ;   member(relation(_, _, T, _, _), Fd) ),
    atom(T), downcase_atom(T, W), !.
dans_le_graphe(Fd, W) :- nombre_de(W, K), memberchk(nombre(_, K), Fd), !.
dans_le_graphe(Fd, W) :-                                % un composé dont chaque mot plein est dans le graphe
    atomic_list_concat(Ps, ' ', W), Ps = [_, _|_], !,
    forall(( member(P0, Ps), atomic_list_concat(Qs, '\'', P0), last(Qs, P), atom_length(P, Lg), Lg > 3 ),
           dans_le_graphe(Fd, P)).
nom_du_graphe(Fd, K) :- member(nom(_, _, Nom, _), Fd), raisonnement:normaliser_nom(Nom, K), !.
% le nom de la personne dont la scène fait partie (héritage) n'est pas dans le libellé de la scène
heritee(Ex, K) :- member(un_de([[nom(Ks)]]), Ex), memberchk(K, Ks), !.

% --- Le sens des mots ------------------------------------------------------------------------------------------------

% les mots (unités mot et genre) d'une définition
mots_de_definition(def(_, Ex, _, _, _), Ws) :-
    findall(W, ( member(un_de(As), Ex), member(A, As), member(U, A), ( U = mot(W) ; U = genre(W) ), atom(W) ), Ws0),
    sort(Ws0, Ws).

% les sens d'un mot, dans une langue, pour une partie du discours (n, v, a)
sens_lex(en, W, Pos, S) :- wordnet:s(S, _, W, P0, _, _), pos(P0, Pos).
sens_lex(fr, W, Pos, S) :- ressources:wolf(S, W), Pre is S // 100000000, pos_prefixe(Pre, Pos).
pos(n, n). pos(v, v). pos(a, a). pos(s, a). pos(r, r).
pos_prefixe(1, n). pos_prefixe(2, v). pos_prefixe(3, a). pos_prefixe(4, r).

sens_de_mot(N, L, W, Ss, Origines) :-
    findall(Pos-S, sens_lex(L, W, Pos, S), PS0), sort(PS0, PS),
    pairs_keys(PS, Pos0), sort(Pos0, Poss),
    findall(Sp-O, ( member(Pos, Poss), findall(S, member(Pos-S, PS), Cands), choisir(N, L, W, Cands, Sp, O) ), R),
    pairs_keys(R, Sss), append(Sss, Ss0), sort(Ss0, Ss), pairs_values(R, Origines).

choisir(N, L, _, Cands, Sp, bilingue) :-
    autre(L, L2), mots_de_l_autre(N, L2, Ws2), Ws2 \== [],
    include(partage(L2, Ws2), Cands, Sp), Sp \== [], !.
choisir(N, L, _, Cands, Sp, hierarchie) :-
    findall(Sa, ( arbre:ancetre(N, A), mots_de(A, L, WsA), member(Wa, WsA), sens_lex(L, Wa, _, Sa) ), Sas0),
    sort(Sas0, Sas), Sas \== [],
    include(sous_l_un(Sas), Cands, Sp), Sp \== [], !.
choisir(_, _, _, Cands, Cands, unique) :-
    findall(Lf, ( member(S, Cands), wordnet:lexfile(S, Lf) ), Lfs0), sort(Lfs0, [_]), !.
choisir(_, _, _, _, [], aucun).

autre(en, fr). autre(fr, en).
mots_de_l_autre(N, L2, Ws) :- mots_de(N, L2, Ws).
mots_de(N, L, Ws) :- ( definitions_index:definition(N, L, D) -> mots_de_definition(D, Ws) ; Ws = [] ).

partage(L2, Ws2, S) :- member(W2, Ws2), sens_lex(L2, W2, _, S), !.
sous_l_un(Sas, S) :- member(Sa, Sas), sous_sens(S, Sa), !.

% S est A ou sous A (hyperonymie, instance), par l'ensemble des ascendants de S, calculé une fois
sous_sens(S, A) :- ascendants(S, As), memberchk(A, As).
:- table ascendants/2.
ascendants(S, As) :-
    findall(P, ( wordnet:hyp(S, P) ; wordnet:ins(S, P) ), Ps),
    foldl([P, A0, A1]>>( ascendants(P, Ap), ord_union(A0, Ap, A1) ), Ps, [S], As0), sort(As0, As).

% les nombres dits en lettres (une classe fermée : « three », « trois ») ; le lecteur les donne par nombre(E, K)
nombre_de(W, K) :- nombres(Ws), nth1(K, Ws, En/Fr), ( W == En ; W == Fr ), !.
nombres([one/un, two/deux, three/trois, four/quatre, five/cinq, six/six, seven/sept, eight/huit, nine/neuf, ten/dix,
         eleven/onze, twelve/douze]).
