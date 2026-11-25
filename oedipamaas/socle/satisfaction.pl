/*  Le moteur de satisfaction des requêtes (docs/NOYAU.md, § 4 et 5).

    satisfaire(+K, +Graphe, +Requete, -Resultat)
        K        le module de connaissances (sens/3, sous/2, cle_de_nom/2, alias/2, version/1)
        Graphe   la liste des assertions d'un document (docs/ASSERTIONS.md)
        Requete  requete(Id, Formule) bien formée (requetes:bien_formee/2)
        Resultat resultat(Statut, Elements, Complet)
          Statut    etablie | contradictoire | ecartee | inconnue
          Elements  etablie : les preuves (une par substitution vraie et sélection) ;
                    contradictoire, ecartee : les substitutions, avec les atomes niés ou contradictoires ;
                    inconnue : partiel(Satisfaits, Manquants), les atomes qui ont, ou non, un appui positif quelque part
          Complet   complet | incomplet (au-delà de la limite de calcul)

    Le graphe est chargé dans un module temporaire, propre à l'appel : deux documents ne se mêlent jamais.
*/
:- module(satisfaction, [ satisfaire/4, satisfaire_lot/4, solutions_classees/4, version_noyau/1, limite/1 ]).
:- encoding(utf8).
:- use_module(library(lists)).
:- use_module(library(apply)).
:- use_module(library(pairs)).
:- use_module(library(solution_sequences)).
:- use_module(requetes).

version_noyau('noyau 0.1').
limite(200).

satisfaire(K, Graphe, requete(Id, F), Resultat) :-
    requetes:bien_formee(requete(Id, F), Es),
    (   Es \== [] -> throw(error(requete_mal_formee(Id, Es), _))
    ;   in_temporary_module(M, charger(M, Graphe), resoudre(K, M, Id, F, Resultat))
    ).

% satisfaire_lot(+K, +Graphe, +Requetes, -Resultats) : les mêmes résultats que satisfaire/4 pour chaque requête
% (Resultats : [Id-Resultat]), le graphe chargé une seule fois ; une requête mal formée donne mal_formee(Erreurs)
satisfaire_lot(K, Graphe, Qs, Rs) :-
    in_temporary_module(M, charger(M, Graphe), resoudre_toutes(K, M, Qs, Rs)).
resoudre_toutes(K, M, Qs, Rs) :- maplist(resoudre_une(K, M), Qs, Rs).
resoudre_une(K, M, requete(Id, F), Id-R) :-
    requetes:bien_formee(requete(Id, F), Es),
    ( Es \== [] -> R = mal_formee(Es) ; resoudre(K, M, Id, F, R) ).

% --- Le graphe -------------------------------------------------------------------------------------------------------

predicats([entite/3, nom/4, propriete/4, evenement/3, role/3, relation/5, coref/2, nombre/2, polarite/2, modalite/2,
           portee/2, enonciateur/2, alternative/2, passage/3, classe/2]).

charger(M, Graphe) :-
    predicats(Ps), forall(member(P, Ps), dynamic(M:P)),
    forall(( member(F, Graphe), functor(F, N, A), memberchk(N/A, Ps) ), assertz(M:F)),
    forall(M:entite(E, _, _), ( representant(M, E, R), assertz(M:classe(E, R)) )).

% le représentant d'une classe de coréférence : le plus petit identifiant de la composante de E
representant(M, E, R) :- composante(M, [E], [E], C), min_member(R, C).
composante(_, [], Vus, Vus).
composante(M, [X|Xs], Vus, C) :-
    findall(Y, ( ( M:coref(X, Y) ; M:coref(Y, X) ), \+ memberchk(Y, Vus) ), Ys0), sort(Ys0, Ys),
    append(Vus, Ys, Vus1), append(Xs, Ys, Xs1), composante(M, Xs1, Vus1, C).

% l'état d'une assertion pour un contexte (docs/NOYAU.md, § 1)
etat(M, A, Ctx, pos) :-
    M:polarite(A, pos), M:modalite(A, affirme), M:enonciateur(A, auteur), M:portee(A, Ctx),
    \+ ( M:alternative(_, As), memberchk(A, As) ).
etat(M, A, Ctx, neg) :- M:polarite(A, neg), M:modalite(A, affirme), M:portee(A, Ctx).

passage_de(M, A, P) :- ( M:entite(A, _, P) ; M:nom(A, _, _, P) ; M:propriete(A, _, _, P) ; M:evenement(A, _, P)
                       ; M:relation(A, _, _, _, P) ), !.

% --- Les liens (K) ---------------------------------------------------------------------------------------------------

lien(K, Cat, W, T, chemin(W, Ch)) :- K:sens(Cat, W, S0), once(chemin(K, S0, T, Ch)).
chemin(_, S, T, [S]) :- S == T, !.
chemin(K, S, T, [S|Ch]) :- K:sous(S, S1), chemin(K, S1, T, Ch).

lien_de_nom(K, Nom, Ks, L) :-
    K:cle_de_nom(Nom, C),
    (   memberchk(C, Ks) -> L = cle(C)
    ;   member(Ka, Ks), ( K:alias(C, Ka) ; K:alias(Ka, C) ) -> L = alias(C, Ka)
    ).

% --- Les appuis d'un atome -------------------------------------------------------------------------------------------

% appui(+K, +M, ?Atome, -Etat, -Appui) : Atome a ses variables remplacées par des valeurs ou des variables Prolog
appui(K, M, type(R, T), S, appui(E, E, P, L)) :-
    M:entite(E, W, P), W \== nom_propre, M:classe(E, R), etat(M, E, represente, S), lien(K, n, W, T, L).
appui(K, M, nom(R, Ks), S, appui(A, E, P, L)) :-
    M:nom(A, E, Nom, P), M:classe(E, R), etat(M, A, represente, S), lien_de_nom(K, Nom, Ks, L).
appui(K, M, propriete(R, Pr), S, appui(A, E, P, L)) :-
    M:propriete(A, E, W, P), M:classe(E, R), etat(M, A, represente, S), lien(K, a, W, Pr, L).
appui(K, M, evenement(V, Pr), S, appui(V, V, P, L)) :-
    M:evenement(V, W, P), etat(M, V, represente, S), lien(K, v, W, Pr, L).
appui(_, M, role(V, Ro, R), S, appui(role(V, Ro, E), E, P, egal)) :-
    M:role(V, Ro, E), M:classe(E, R), M:evenement(V, _, P), etat(M, V, represente, S).
appui(K, M, relation(R1, Re, R2), S, appui(A, E1, P, L)) :-
    M:relation(A, E1, W, E2, P), M:classe(E1, R1), M:classe(E2, R2), etat(M, A, represente, S), lien(K, r, W, Re, L).
appui(K, M, genre(T), S, appui(E, E, P, L)) :-
    M:entite(E, W, P), W \== nom_propre, etat(M, E, oeuvre, S), lien(K, n, W, T, L).

% --- La recherche des substitutions ----------------------------------------------------------------------------------

% solution(+K, +M, +F, -sol(Sigma, Selection)) : une substitution complète et la sélection d'atomes qu'elle satisfait
% (chaque atome a au moins un appui, de l'un ou l'autre signe ; chaque contrainte est vraie)
solution(K, M, F, sol(Sigma, Sel)) :-
    resoudre_buts(K, M, [g([], F)], [], Sigma0, [], Sel0),
    sort(Sigma0, Sigma), sort(Sel0, Sel).

resoudre_buts(_, _, [], S, S, Sel, Sel) :- !.
resoudre_buts(K, M, Gs, S0, S, Sel0, Sel) :-
    choisir(K, M, Gs, S0, G, Reste),
    resoudre_but(K, M, G, Reste, S0, S, Sel0, Sel).

% un « et » se déplie ; puis les contraintes dont les variables sont liées ; puis l'atome le plus sélectif ; un « ou »
% en dernier
choisir(_, _, Gs, _, g(C, et(Fs)), Reste) :- select(g(C, et(Fs)), Gs, Reste), !.
choisir(_, _, Gs, S, g(C, Co), Reste) :-
    select(g(C, Co), Gs, Reste), requetes:contrainte(Co), contrainte_prete(Co, S), !.
choisir(K, M, Gs, S, G, Reste) :-
    findall(N-g(C, A), ( member(g(C, A), Gs), requetes:atome(A), compte(K, M, A, S, N) ), Ns), Ns \== [], !,
    keysort(Ns, [_-G|_]), selectchk(G, Gs, Reste).
choisir(_, _, Gs, _, g(C, ou(Fs)), Reste) :- select(g(C, ou(Fs)), Gs, Reste), !.
choisir(_, _, Gs, _, G, Reste) :- select(G, Gs, Reste), !.          % une contrainte encore libre : échouera

compte(K, M, A, S, N) :- instancier(A, S, Ai, _), aggregate_all(count, appui(K, M, Ai, _, _), N).

resoudre_but(K, M, g(C, et(Fs)), Reste, S0, S, Sel0, Sel) :- !,
    findall(g(C1, Fi), ( nth1(I, Fs, Fi), append(C, [I], C1) ), Gs1),
    append(Gs1, Reste, Gs), resoudre_buts(K, M, Gs, S0, S, Sel0, Sel).
resoudre_but(K, M, g(C, ou(Fs)), Reste, S0, S, Sel0, Sel) :- !,
    nth1(I, Fs, Fi), append(C, [I], C1),
    resoudre_buts(K, M, [g(C1, Fi)|Reste], S0, S, Sel0, Sel).
resoudre_but(K, M, g(C, Co), Reste, S0, S, Sel0, Sel) :-
    requetes:contrainte(Co), !,
    contrainte_vraie(M, Co, S0, S1),
    resoudre_buts(K, M, Reste, S1, S, [C-Co|Sel0], Sel).
resoudre_but(K, M, g(C, A), Reste, S0, S, Sel0, Sel) :-
    instancier(A, S0, Ai, Liaisons),
    distinct(Ai, appui(K, M, Ai, _, _)),
    lier(Liaisons, S0, S1),
    resoudre_buts(K, M, Reste, S1, S, [C-A|Sel0], Sel).

% remplacer les variables v(N) liées par leur valeur, les autres par des variables Prolog
instancier(v(N), S, X, L) :- !, ( memberchk(v(N)-X0, S) -> X = X0, L = [] ; L = [v(N)-X] ).
instancier(T, S, Ti, L) :-
    compound(T), !, T =.. [F|As], foldl(instancier_arg(S), As, Ais, [], L), Ti =.. [F|Ais].
instancier(T, _, T, []).
instancier_arg(S, A, Ai, L0, L) :- instancier(A, S, Ai, La), append(L0, La, L).

lier(Ls, S0, S) :- foldl([V-X, A0, A]>>( memberchk(V-Y, A0) -> Y == X, A = A0 ; A = [V-X|A0] ), Ls, S0, S).

contrainte_prete(meme(X, Y), S) :- memberchk(X-_, S), memberchk(Y-_, S).
contrainte_prete(distincts(X, Y), S) :- memberchk(X-_, S), memberchk(Y-_, S).
contrainte_prete(nombre(X, _), S) :- memberchk(X-_, S).

contrainte_vraie(_, meme(X, Y), S, S) :- memberchk(X-A, S), memberchk(Y-B, S), A == B.
contrainte_vraie(_, distincts(X, Y), S, S) :- memberchk(X-A, S), memberchk(Y-B, S), A \== B.
contrainte_vraie(M, nombre(X, N), S, S) :- memberchk(X-R, S), M:classe(E, R), M:nombre(E, N), !.

% --- Le classement des substitutions et le résultat -----------------------------------------------------------------

% solutions_classees(+K, +Graphe, +Requete, -Classees) : toutes les solutions, chacune c(Classe, Sigma, Selection),
% triées ; sans limite de calcul. C'est la vue que le moteur de référence (satisfaction_reference.pl) doit reproduire
% exactement (docs/NOYAU.md, § 7)
solutions_classees(K, Graphe, requete(Id, F), Cs) :-
    requetes:bien_formee(requete(Id, F), []),
    in_temporary_module(M, charger(M, Graphe), toutes_classees(K, M, F, Cs)).
toutes_classees(K, M, F, Cs) :-
    findall(Sol, distinct(Sol, solution(K, M, F, Sol)), Sols),
    maplist(classe_brute(K, M), Sols, Cs0), sort(Cs0, Cs).
classe_brute(K, M, sol(Sigma, Sel), c(Classe, Sigma, Sel)) :- classer(K, M, sol(Sigma, Sel), c(Classe, _, _)).

resoudre(K, M, Id, F, resultat(Statut, Elements, Complet)) :-
    limite(Lim), Lim1 is Lim + 1,
    findall(Sol, limit(Lim1, distinct(Sol, solution(K, M, F, Sol))), Sols0),
    length(Sols0, N), ( N > Lim -> Complet = incomplet, length(Sols, Lim), append(Sols, _, Sols0) ; Complet = complet, Sols = Sols0 ),
    maplist(classer(K, M), Sols, Cs),
    (   include([c(vraie, _, _)]>>true, Cs, Vs), Vs \== []
    ->  Statut = etablie, regime(F, Rg), maplist(preuve(K, Id, Rg), Vs, Elements0), sort(Elements0, Elements)
    ;   include([c(contradictoire, _, _)]>>true, Cs, Xs), Xs \== []
    ->  Statut = contradictoire, maplist([c(_, Sg, D), contradictoire(Sg, D)]>>true, Xs, Elements)
    ;   include([c(contredite, _, _)]>>true, Cs, Ns), Ns \== []
    ->  Statut = ecartee, maplist([c(_, Sg, D), contredite(Sg, D)]>>true, Ns, Elements)
    ;   Statut = inconnue, partiel(K, M, F, P), Elements = [P]
    ).

% c(Classe, Sigma, Detail) ; Detail : pour une substitution vraie, la sélection et ses appuis positifs ; sinon les
% atomes niés ou contradictoires
classer(K, M, sol(Sigma, Sel), c(Classe, Sigma, Detail)) :-
    findall(C-A-Pos-Neg, ( member(C-A, Sel), requetes:atome(A), instancier(A, Sigma, Ai, _),
                           findall(Ap, appui(K, M, Ai, pos, Ap), Pos), findall(Ap, appui(K, M, Ai, neg, Ap), Neg) ), As),
    (   forall(member(_-_-Pos-_, As), Pos \== [])
    ->  (   member(_-_-_-[_|_], As)
        ->  Classe = contradictoire, findall(C-A-Neg, ( member(C-A-_-Neg, As), Neg \== [] ), Detail)
        ;   Classe = vraie, findall(C-A-Ap, ( member(C-A-[Ap|_]-_, As) ), Da),
            findall(C-Co-contrainte, ( member(C-Co, Sel), requetes:contrainte(Co) ), Dc),
            append(Da, Dc, D0), sort(D0, Detail)
        )
    ;   Classe = contredite, findall(C-A-Neg, ( member(C-A-[]-Neg, As) ), Detail)
    ).

regime(F, classement) :- requetes:atomes(F, As), forall(( member(_-A, As), requetes:atome(A) ), A = genre(_)), !.
regime(_, figuration).

preuve(K, Id, Rg, c(vraie, Sigma, Detail), preuve(Id, [noyau(V), connaissances(Vk)], Rg, Sigma, Js)) :-
    version_noyau(V), K:version(Vk),
    findall(j(C, A, Ap), member(C-A-Ap, Detail), Js).

% une correspondance partielle : les atomes qui ont un appui positif quelque part, sans substitution commune
partiel(K, M, F, partiel(Sat, Manq)) :-
    requetes:atomes(F, As),
    findall(C-A, ( member(C-A, As), requetes:atome(A), instancier(A, [], Ai, _), once(appui(K, M, Ai, pos, _)) ), Sat),
    findall(C-A, ( member(C-A, As), requetes:atome(A), \+ memberchk(C-A, Sat) ), Manq).
