/*  Le codage d'un texte par Iconclass avec le noyau (docs/PLAN_V1.md, C4 et C5) : la couche propre à Iconclass, au-
    dessus du noyau générique (docs/NOYAU.md). Les requêtes sont celles du compilateur des libellés
    (requetes_iconclass.pl), compilées une fois dans BASE/requetes_index.pl (outils/requetes/compiler_tout.pl).

    coder(+Langue, +Faits, +Mode, -Resultats)
        Faits : les assertions d'un document (interpretation.pl, ancrage compris) ; Mode : indexe | exhaustif
        Resultats : [code(N, Statut, Detail)], Statut :
          etabli          la requête suffisante a une substitution vraie, la compilation est « compilee », sa famille
                          de constructions est justifiée (familles_justifiees/1 : C3.3, invariant I3), et le
                          vérificateur accepte chaque preuve (Detail : les preuves)
          etablissable    tout cela, sauf que la famille n'est pas encore justifiée : un candidat, jamais un code
                          établi ; compté à part dans les mesures, pour savoir ce que la justification débloquera
          candidat        la requête suffisante a une substitution vraie, mais la compilation n'est que partielle
          contradictoire  des appuis des deux signes
          ecarte          la requête n'a que des substitutions contredites (pour ces référents)
        Les notations sont toutes données, sans réduction aux plus précises : l'arbre d'Iconclass est une ascendance
        documentaire, pas une implication (docs/PLAN_V1.md, I11) ; la réduction est une présentation, à part.

    Le graphe est d'abord normalisé (normalisation.pl : les deux formes d'une action, les rôles, les composés).

    L'index et sa complétude (docs/PLAN_V1.md, C5.3). Chaque requête est rangée sous une clé par clause de sa forme
    normale disjonctive : un atome lexical de la clause (un nom, sinon un type, un genre, un prédicat, une propriété,
    sinon une relation) ; une clause sans atome lexical est rangée sous « toujours ». Les clés d'un graphe sont les
    noms de ses entités (et leurs alias) et tous les nœuds que K atteint depuis chacun de ses mots, de quelque état
    qu'ils soient. Si une clause est satisfaite, son atome-clé a un appui, dont le mot atteint le type de l'atome par
    K : la clé est parmi celles du graphe. Toute requête qui peut être établie est donc essayée ; le mode exhaustif
    (toutes les requêtes) le vérifie (outils/vertical/coder.pl, comparaison des deux modes).
*/
:- module(codage, [ coder/4, indexer/0 ]).
:- encoding(utf8).
:- use_module(library(lists)).
:- use_module(library(apply)).
:- use_module(library(pairs)).
:- use_module(library(yall)).
:- use_module(satisfaction).
:- use_module(verificateur).
:- use_module(normalisation, []).
:- use_module(connaissances_en, []).
:- use_module(connaissances_fr, []).

k(en, connaissances_en).
k(fr, connaissances_fr).

% --- L'index --------------------------------------------------------------------------------------------------------

:- dynamic cle/3, indexe/0.        % cle(Langue, Cle, N) ; Cle : nom(K) | mot(T) | toujours

indexer :- indexe, !.
indexer :-
    forall(( requetes_index:requete_compilee(N, L, _, requete(_, F), _, St, _, _), memberchk(St, [compilee, partielle]),
             cas_dnf(F, As), cle_de_clause(As, C) ),
           assertz(cle(L, C, N))),
    assertz(indexe).

cas_dnf(et(Fs), As) :- !, foldl([F, A0, A]>>( cas_dnf(F, Af), append(A0, Af, A) ), Fs, [], As).
cas_dnf(ou(Fs), As) :- !, member(F, Fs), cas_dnf(F, As).
cas_dnf(A, [A]).

% la clé d'une clause : un nom (rare), sinon un mot ; une clause sans atome lexical : toujours
cle_de_clause(As, nom(K)) :- member(nom(_, Ks), As), !, member(K, Ks).
cle_de_clause(As, mot(T)) :-
    member(P, [type, genre, evenement, propriete, relation]), member(A, As), cle_mot(P, A, T), !.
cle_de_clause(_, toujours).
cle_mot(type, type(_, T), T).
cle_mot(genre, genre(T), T).
cle_mot(evenement, evenement(_, T), T).
cle_mot(propriete, propriete(_, T), T).
cle_mot(relation, relation(_, T, _), T).

% les clés d'un graphe : ses noms, et tout ce que K atteint depuis ses mots
cles_du_graphe(L, G, Cs) :-
    k(L, K),
    findall(nom(C), ( member(nom(_, _, Nom, _), G), K:cle_de_nom(Nom, C0), ( C = C0 ; K:alias(C0, C) ; K:alias(C, C0) ) ), Cn),
    findall(Cat-W, mot_du_graphe(G, Cat, W), CW0), sort(CW0, CW),
    findall(mot(X), ( member(Cat-W, CW), K:sens(Cat, W, S0), atteint(K, S0, X), atom(X) ), Cm),
    append([[toujours], Cn, Cm], Cs0), sort(Cs0, Cs).
mot_du_graphe(G, n, W) :- member(entite(_, W, _), G), atom(W), W \== nom_propre.
mot_du_graphe(G, a, W) :- member(propriete(_, _, W, _), G), atom(W).
mot_du_graphe(G, v, W) :- member(evenement(_, W, _), G), atom(W).
mot_du_graphe(G, r, W) :- member(relation(_, _, W, _, _), G), atom(W).

:- table atteint/3.
atteint(_, S, S).
atteint(K, S, X) :- K:sous(S, S1), atteint(K, S1, X).

% --- Le codage -------------------------------------------------------------------------------------------------------

coder(L, Fs, Mode, Resultats) :-
    indexer, k(L, K),
    normalisation:enrichir(L, Fs, G),
    (   Mode == exhaustif
    ->  findall(N, ( requetes_index:requete_compilee(N, L, _, Q, _, St, _, _), Q \== aucune,
                     memberchk(St, [compilee, partielle]) ), Ns0)
    ;   cles_du_graphe(L, G, Cs), findall(N, ( member(C, Cs), cle(L, C, N) ), Ns0)
    ),
    sort(Ns0, Ns),
    findall(Q, ( member(N, Ns), requetes_index:requete_compilee(N, L, _, Q, _, _, _, _) ), Qs),
    satisfaction:satisfaire_lot(K, G, Qs, Rs),
    findall(Code, ( member(N-R, Rs), code(K, G, L, N, R, Code) ), Resultats0),
    sort(Resultats0, Resultats).

code(K, G, L, N, resultat(etablie, Ps, _), code(N, Statut, Ps)) :-
    requetes_index:requete_compilee(N, L, _, Q, _, St, _, Fa),
    (   St == compilee, \+ forall(member(P, Ps), verifier(K, G, Q, P, accepte)) -> Statut = rejete_par_le_verificateur
    ;   St == compilee, famille_justifiee(Fa) -> Statut = etabli
    ;   St == compilee -> Statut = etablissable
    ;   Statut = candidat
    ).

% les familles de constructions dont la suffisance est justifiée (C3.3 : un échantillon jugé par famille, borne
% supérieure de Wilson du taux de requêtes trop faibles ≤ 5 %) ; aucune ne l'est à ce jour
:- dynamic familles_justifiees/1.
famille_justifiee(F) :- familles_justifiees(Fs), memberchk(F, Fs), !.
code(_, _, _, N, resultat(contradictoire, D, _), code(N, contradictoire, D)).
code(_, _, _, N, resultat(ecartee, D, _), code(N, ecarte, D)).
