/*  La projection (docs/FONDEMENTS.md, § 4 ; étape 3) : une notation s'applique à un texte si sa définition
    (definitions.pl, compilée par outils/definitions/compiler_definitions.pl) se projette tout entière, avec sa
    structure, sur ce que le texte met dans l'image.

    projeter(+Faits, +Langue, -Resultats)
        Faits : les assertions d'un document (interpretation.pl, ancrage compris) ; Langue : en | fr
        Resultats : une liste de resultat(N, Statut, Preuve) ; Statut :
          etabli     toutes les exigences sont vraies, chacune de ses alternatives se projette sur des éléments liés,
                     aucun rôle n'est contredit, et la définition est « compilee » (compilation.pl) ; seule la notation
                     la plus précise d'une branche est donnée (ses ancêtres établis sont impliqués)
          candidat   toutes vraies mais la définition n'est pas compilée, ou les éléments ne sont pas liés, ou une
                     partie seulement des exigences est vraie
          contredit  une exigence n'est portée que par un élément nié de l'image, ou un rôle est inversé
        Preuve : preuve(Satisfaites, Manques) ; une exigence satisfaite : porte(Unite, Assertion, Passage).

    Trois valeurs (FONDEMENTS § 4) : une exigence est vraie (un élément représenté la porte), fausse (seul un élément
    nié de l'image la porte), ou inconnue ; inconnue n'est jamais fausse et n'établit rien.

    Une unité de la définition et les éléments du texte :
      mot(W)    un élément (entité, propriété, événement, relation) admissible dont le lemme est W, ou dont un sens est
                sous un sens de W (sens choisis à la compilation : compilation:sens_de_mot/5 ; le sens dominant du mot
                du texte en anglais, ses sens de WOLF en français)
      nom(Ks)   une entité admissible qui porte l'un de ces noms ; deux unités nom d'une alternative vont à deux
                entités différentes (David n'est pas Goliath)
      genre(W)  un prédicat de l'œuvre : une entité de tête W (ou plus spécifique), affirmée, à toute portée
    Une alternative décrit une chose ou une situation : ses éléments sont liés dans le texte (tous à deux liens au plus
    d'un même nœud : rôles d'un même événement, relations, propriétés, coréférence) ; « a dead man ... a bird » n'est
    pas « dead bird ».
*/
:- module(projection, [ projeter/3 ]).
:- encoding(utf8).
:- use_module(arbre).
:- use_module(assertions).
:- use_module(compilation, [sous_sens/2]).
:- use_module(raisonnement, []).
:- use_module(library(ordsets)).

% --- Les éléments du texte -------------------------------------------------------------------------------------------

% element(Fs, Pos, Lemme, Assertion, Ancres, Etat) ; Etat : vrai (admissible) ou nie (nié dans l'image)
element(Fs, n, W, E, [E], Et) :- member(entite(E, T, _), Fs), T \== nom_propre, mot_de(T, W), etat(Fs, E, Et).
element(Fs, a, W, A, [E], Et) :- member(propriete(A, E, P, _), Fs), mot_de(P, W), etat(Fs, A, Et).
element(Fs, v, W, V, [V], Et) :- member(evenement(V, P, _), Fs), mot_de(P, W), etat(Fs, V, Et).
element(Fs, r, W, A, [E1, E2], Et) :- member(relation(A, E1, R, E2, _), Fs), mot_de(R, W), etat(Fs, A, Et).

mot_de(X, W) :- atom(X), downcase_atom(X, W).

etat(Fs, A, vrai) :- assertions:admissible(Fs, A), !.
etat(Fs, A, nie) :- assertions:contredit(Fs, A).

nom_du_texte(Fs, E, K, Et) :-
    member(nom(A, E, Nom, _), Fs), raisonnement:normaliser_nom(Nom, K), etat(Fs, A, Et).

% --- La correspondance d'un mot du texte et d'un mot de la définition ------------------------------------------------

correspond(_, _, _, W, W) :- !.
correspond(N, L, Pos, Wt, Wd) :-
    sens_definition(N, L, Wd, Sds), Sds \== [],
    sens_texte(L, Pos, Wt, St), member(Sd, Sds), sous_sens(St, Sd), !.

sens_definition(N, L, W, Ss) :- definitions_index:sens(N, L, W, Ss, _), !.
sens_definition(_, _, _, []).

% le sens d'un mot du texte : en anglais, le sens dominant de sa partie du discours (faute de désambiguïsation :
% précision d'abord) ; en français, ses sens dans WOLF
sens_texte(en, Pos, W, S) :- pos_wn(Pos, P), once(( between(1, 60, K), member(P1, P), wordnet:s(S, _, W, P1, K, _) )).
sens_texte(fr, Pos, W, S) :- prefixe(Pos, Pre), ressources:wolf(S, W), S // 100000000 =:= Pre.
pos_wn(n, [n]). pos_wn(v, [v]). pos_wn(a, [a, s]).
prefixe(n, 1). prefixe(v, 2). prefixe(a, 3).

% --- L'évaluation d'une alternative ---------------------------------------------------------------------------------

% unite(+Fs, +N, +L, +U, ?Etat, +Pris, -Porte, -Pris1)
unite(Fs, _, _, nom(Ks), Et, Pris, porte(nom(Ks), A, [E]), [E|Pris]) :-
    is_list(Ks), member(K, Ks), member(nom(A, E, Nom, _), Fs), raisonnement:normaliser_nom(Nom, K),
    \+ memberchk(E, Pris), etat(Fs, A, Et).
unite(Fs, N, L, mot(W), Et, Pris, porte(mot(W), A, As), Pris) :-
    element(Fs, Pos, Wt, A, As, Et), correspond(N, L, Pos, Wt, W).
unite(Fs, N, L, genre(W), Et, Pris, porte(genre(W), E, []), Pris) :-
    member(entite(E, T, _), Fs), mot_de(T, Wt), correspond(N, L, n, Wt, W),
    \+ memberchk(modalite(E, titre), Fs),                         % D15 : un titre n'est jamais une preuve
    ( memberchk(polarite(E, neg), Fs) -> Et = nie ; Et = vrai ).

unites(_, _, _, [], _, []).
unites(Fs, N, L, [U|Us], Pris, [P|Ps]) :- unite(Fs, N, L, U, vrai, Pris, P, Pris1), unites(Fs, N, L, Us, Pris1, Ps).

% alternative(+Fs, +N, +L, +Contraintes, +Alt, -Valeur, -Portes)
%   vrai : toutes les unités, sur des éléments liés, sans rôle inversé ; delie : toutes, mais pas liées ; nie : une
%   unité n'est portée que par un élément nié ; inconnu : il en manque
alternative(Fs, N, L, Cs, A, vrai, Ps) :-
    unites(Fs, N, L, A, [], Ps), lies(Fs, Ps), \+ role_inverse(Fs, N, L, Cs, Ps), !.
alternative(Fs, N, L, Cs, A, inverse, Ps) :-
    unites(Fs, N, L, A, [], Ps), lies(Fs, Ps), role_inverse(Fs, N, L, Cs, Ps), !.
alternative(Fs, N, L, _, A, delie, Ps) :- unites(Fs, N, L, A, [], Ps), !.
alternative(Fs, N, L, _, A, nie, [P]) :-
    member(U, A), \+ unite(Fs, N, L, U, vrai, [], _, _), unite(Fs, N, L, U, nie, [], P, _), !.
alternative(Fs, N, L, _, A, inconnu, Ms) :-
    findall(manque(U), ( member(U, A), \+ unite(Fs, N, L, U, vrai, [], _, _) ), Ms).

% un groupe un_de : la meilleure de ses alternatives
groupe(Fs, N, L, Cs, un_de(As), V, Ps) :-
    findall(V0-P0, ( member(A, As), alternative(Fs, N, L, Cs, A, V0, P0) ), R),
    (   member(V, [vrai, inverse, delie, nie]), memberchk(V-Ps, R) -> true
    ;   V = inconnu, Ps = []
    ).

% --- Les liens dans le texte -----------------------------------------------------------------------------------------

% les éléments d'une alternative (hors prédicats de l'œuvre) sont tous à deux liens au plus d'un même nœud
lies(Fs, Ps) :-
    findall(As, ( member(porte(_, _, As), Ps), As \== [] ), Ass),
    (   Ass = [] -> true
    ;   Ass = [_] -> true
    ;   Ass = [A1|Ar], voisinage(Fs, A1, V1), foldl(intersecter(Fs), Ar, V1, I), I \== []
    ).
intersecter(Fs, As, I0, I) :- voisinage(Fs, As, V), ord_intersection(I0, V, I).

% les nœuds à deux liens au plus de l'un des ancrages
voisinage(Fs, As, V) :-
    sort(As, V0), etendre(Fs, V0, V1), etendre(Fs, V1, V).
etendre(Fs, V0, V) :- findall(Y, ( member(X, V0), ( Y = X ; lien(Fs, X, Y) ) ), V1), sort(V1, V).

lien(Fs, X, Y) :- member(role(V, _, E), Fs), admis(Fs, V), ( X = V, Y = E ; X = E, Y = V ).
lien(Fs, X, Y) :- member(relation(A, E1, _, E2, _), Fs), admis(Fs, A), ( X = E1, Y = E2 ; X = E2, Y = E1 ).
lien(Fs, X, Y) :- member(coref(E1, E2), Fs), ( X = E1, Y = E2 ; X = E2, Y = E1 ).
admis(Fs, A) :- ( assertions:admissible(Fs, A) -> true ; assertions:contredit(Fs, A) ).

% --- Les rôles -------------------------------------------------------------------------------------------------------

% Un rôle inversé : un événement du libellé est porté par un événement du texte, et ce dernier donne un rôle à une
% entité qui porte une autre unité de l'alternative, alors que le libellé ne donne ce rôle qu'à d'autres participants
% (« Goliath beheads David », « the lion strangles Hercules »)
role_inverse(Fs, N, L, Cs, Ps) :-
    member(assertions(Fd), Cs),
    member(porte(mot(Wd), Vt, [Vt]), Ps), member(evenement(Vt, _, _), Fs),
    member(evenement(Vd, Pd, _), Fd), mot_de(Pd, Wd),
    member(role(Vt, R, Et), Fs),
    findall(D, ( member(role(Vd, R, Ed), Fd), descripteur(Fd, Ed, D) ), Ds), Ds \== [],
    member(porte(U, _, [Et]), Ps), U \== mot(Wd),
    \+ ( member(D, Ds), decrit(Fs, N, L, D, Et) ), !.

descripteur(Fd, E, nom(K)) :- member(nom(_, E, Nom, _), Fd), raisonnement:normaliser_nom(Nom, K).
descripteur(Fd, E, mot(W)) :- member(entite(E, T, _), Fd), T \== nom_propre, mot_de(T, W).
decrit(Fs, _, _, nom(K), E) :- nom_du_texte(Fs, E, K, _), !.
decrit(Fs, N, L, mot(W), E) :- member(entite(E, T, _), Fs), mot_de(T, Wt), correspond(N, L, n, Wt, W), !.

% --- L'évaluation d'une définition -----------------------------------------------------------------------------------

evaluer(Fs, N, L, def(Type, Exige, _, Cs, _), Valeur, Preuves, Manques) :-
    Type \== rubrique,
    findall(G-V-P, ( member(G, Exige), groupe(Fs, N, L, Cs, G, V, P) ), Rs),
    findall(P, member(_-vrai-P, Rs), Ps1), append(Ps1, Preuves),
    findall(G, ( member(G-V-_, Rs), V \== vrai ), Manques),
    (   memberchk(_-nie-_, Rs) -> Valeur = contredit
    ;   memberchk(_-inverse-_, Rs) -> Valeur = contredit
    ;   Manques == [] -> Valeur = vrai
    ;   Preuves \== [] -> Valeur = partiel
    ;   memberchk(_-delie-_, Rs) -> Valeur = partiel
    ;   Valeur = rien
    ).

% --- Les définitions à essayer : un index des unités ----------------------------------------------------------------

:- dynamic index/3.            % index(Langue, Cle, N) ; Cle : mot(W) | nom(K)
:- dynamic indexe/0.

indexer :- indexe, !.
indexer :-
    forall(( definitions_index:definition(N, L, def(_, Ex, _, _, _)), member(un_de(As), Ex), member(A, As), member(U, A),
             cle(U, C) ),
           assertz(index(L, C, N))),
    assertz(indexe).
cle(mot(W), mot(W)).
cle(genre(W), mot(W)).
cle(nom(Ks), nom(K)) :- is_list(Ks), member(K, Ks).

% les notations dont une unité porte un mot du texte, un mot plus général que lui, ou un nom du texte
a_essayer(Fs, L, Ns) :-
    findall(Pos-Wt, element(Fs, Pos, Wt, _, _, _), PW0), sort(PW0, PW),
    findall(N, ( member(_-Wt, PW), index(L, mot(Wt), N) ), N1),
    findall(Wd, ( member(Pos-Wt, PW), sens_texte(L, Pos, Wt, St), compilation:ascendants(St, Ss), member(Sd, Ss),
                  synonyme(L, Sd, Wd) ), Wds0), sort(Wds0, Wds),
    findall(N, ( member(Wd, Wds), index(L, mot(Wd), N) ), N2),
    findall(N, ( member(nom(_, _, Nom, _), Fs), raisonnement:normaliser_nom(Nom, K), index(L, nom(K), N) ), N3),
    append([N1, N2, N3], N0), sort(N0, Ns).
synonyme(en, S, W) :- wordnet:s(S, _, W, _, _, _).
synonyme(fr, S, W) :- ressources:wolf(S, W).

% --- La décision -----------------------------------------------------------------------------------------------------

projeter(Fs, L, Resultats) :-
    indexer,
    a_essayer(Fs, L, Ns),
    findall(r(N, V, P, M), ( member(N, Ns), definitions_index:definition(N, L, D),
                             evaluer(Fs, N, L, D, V, P, M), V \== rien ), Rs0),
    findall(N, ( member(r(N, vrai, _, _), Rs0), compilee(N, L) ), Es0),
    exclude(precise_par(Es0), Es0, Es),
    findall(resultat(N, etabli, preuve(P, [])), ( member(N, Es), memberchk(r(N, vrai, P, _), Rs0) ), Re),
    findall(resultat(N, candidat, preuve(P, M)), ( member(r(N, V, P, M), Rs0), memberchk(V, [vrai, partiel]),
                                                   \+ memberchk(N, Es0) ), Rc),
    findall(resultat(N, contredit, preuve(P, M)), member(r(N, contredit, P, M), Rs0), Rx),
    append([Re, Rc, Rx], Resultats).

compilee(N, L) :- definitions_index:statut(N, L, compilee, _).

precise_par(Es, N) :- member(N2, Es), N2 \== N, arbre:ancetre(N2, N), !.
