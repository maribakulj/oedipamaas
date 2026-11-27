/*  Le codage d'un texte par Iconclass avec le noyau (docs/PLAN_V1.md, C4 et C5) : la couche propre à Iconclass, au-
    dessus du noyau générique (docs/NOYAU.md). Les requêtes sont celles du compilateur des libellés
    (requetes_iconclass.pl), compilées une fois dans BASE/requetes_index.pl (outils/requetes/compiler_tout.pl) :
    requete_compilee(N, Langue, Type, Suffisante, Necessaire, Statut, Raisons, Famille).

    coder(+Langue, +Faits, +Mode, -Resultats)
    coder(+Langue, +Faits, +Mode, +Options, -Resultats)
        Faits : les assertions d'un document (interpretation.pl, ancrage compris) ; Mode : indexe | exhaustif
        Options : k(K) (le module de connaissances, sinon celui de la langue) ; normaliser(non) (le graphe tel quel) ;
                  budget(N) (par requête)
        Resultats : [code(N, Statut, Detail, annexe(Complet, Necessaire))], triés.
          Statut, d'après la condition SUFFISANTE seule :
            etabli          la suffisante est établie, la compilation est « compilee », sa famille de constructions est
                            justifiée (familles_justifiees/1 : C3.3, invariant I3), et le vérificateur accepte chaque
                            preuve (Detail : les preuves)
            etablissable    tout cela, sauf que la famille n'est pas encore justifiée : un candidat, jamais un code
            candidat        la suffisante est établie, mais la compilation n'est que partielle
            conditionnel    la suffisante n'est établie que sous hypothèses (distinction, sens, négation possible).
                            NE PAS EXPLOITER AUTOMATIQUEMENT (décision du 27/11) : les hypothèses de sens sont
                            rattachées aux lemmes, non aux occurrences, et ne sont pas confrontées entre elles ; deux
                            lectures exclusives d'une même occurrence peuvent justifier ensemble un code conditionnel
                            (docs/QUALIFICATION_NOYAU.md, § 10, L1)
            rejete_par_le_verificateur
            contradictoire  des appuis des deux signes
            non_certifie    vraie selon le graphe, non certifiable
            suffisante_ecartee  des substitutions de la suffisante sont réfutées (Detail : les réfutations, avec leur
                            portée et leurs fondements, D31) : la notation n'est PAS réfutée par là (une condition
                            suffisante réfutée ne dit rien de la notation)
            incomplet       le calcul de la suffisante s'est arrêté (budget) sans conclusion
            sans_suffisante la suffisante est inconnue ; le code n'est donné que pour sa condition nécessaire
            suffisante_mal_formee  la suffisante n'est pas une requête bien formée (Detail : les erreurs) : un défaut du
                            compilateur, signalé ; une nécessaire mal formée donne Necessaire = mal_formee
          Complet : complet | incomplet, si le calcul de l'une ou l'autre condition s'est arrêté avant la fin ; il est
                    gardé jusqu'à la sortie (un calcul incomplet ne donne jamais de conclusion négative)
          Necessaire : le statut du noyau pour la condition NÉCESSAIRE (etablie, ecartee, contradictoire, inconnue…),
                    ou aucune ; une nécessaire écartée réfute des substitutions, jamais la notation pour le document
        Un code est donné si la suffisante ou la nécessaire n'est pas inconnue. Les notations sont toutes données, sans
        réduction aux plus précises : l'arbre d'Iconclass est une ascendance documentaire, pas une implication
        (docs/PLAN_V1.md, I11) ; la réduction est une présentation, à part.

    Le graphe est d'abord normalisé (normalisation.pl : les deux formes d'une action, les rôles, les composés).

    L'index et sa complétude (docs/PLAN_V1.md, C5.3). Chaque requête (suffisante et nécessaire) est rangée sous une
    clé par clause de sa forme normale disjonctive : un atome lexical de la clause (un nom, sinon un type, un genre, un
    prédicat, une propriété, sinon une relation) ; une clause sans atome lexical est rangée sous « toujours ». Les clés
    d'un graphe sont les noms de ses entités et tous leurs alias (fermés, comme le noyau les ferme), et tous les nœuds
    que K atteint depuis chacun de ses mots, de quelque état qu'ils soient, identifiants de concepts (entiers) compris.
    Si une clause est satisfaite, son atome-clé a un appui, dont le mot atteint le type de l'atome par K : la clé est
    parmi celles du graphe. Toute requête qui peut être établie est donc essayée ; le mode exhaustif (toutes les
    requêtes) le vérifie (tests/plunit/test_codage.pl : mêmes résultats positifs dans les deux modes).
*/
:- module(codage, [ coder/4, coder/5, indexer/0 ]).
:- encoding(utf8).
:- use_module(library(lists)).
:- use_module(library(apply)).
:- use_module(library(pairs)).
:- use_module(satisfaction).
:- use_module(verificateur).
:- use_module(normalisation, []).
:- use_module(connaissances_en, []).
:- use_module(connaissances_fr, []).

k(en, connaissances_en).
k(fr, connaissances_fr).
k_de(L, Opts, K) :- ( memberchk(k(K0), Opts) -> K = K0 ; k(L, K) ).

% --- L'index --------------------------------------------------------------------------------------------------------

:- dynamic cle/3, indexe/0.        % cle(Cle, Langue, N) ; Cle : nom(K) | mot(T) | toujours (la clé en tête : l'index)

indexer :- indexe, !.
indexer :-
    forall(( requetes_index:requete_compilee(N, L, _, Qs, Qn, St, _, _), memberchk(St, [compilee, partielle]),
             member(requete(_, F), [Qs, Qn]), cas_dnf(F, As), cle_de_clause(As, C) ),
           assertz(cle(C, L, N))),
    assertz(indexe).
% un index refait (après un changement des requêtes compilées)
reindexer :- retractall(cle(_, _, _)), retractall(indexe), indexer.

cas_dnf(et(Fs), As) :- !, cas_liste(Fs, As).
cas_dnf(ou(Fs), As) :- !, member(F, Fs), cas_dnf(F, As).
cas_dnf(A, [A]).
cas_liste([], []).
cas_liste([F|Fs], As) :- cas_dnf(F, A1), cas_liste(Fs, A2), append(A1, A2, As).

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

% les clés d'un graphe : ses noms et tous leurs alias (fermeture réflexive, symétrique, transitive, comme le noyau),
% et tout ce que K atteint depuis ses mots, entiers compris
cles_du_graphe(K, G, Cs) :-
    findall(nom(C), ( member(nom(_, _, Nom, _), G), K:cle_de_nom(Nom, C0), alias_fermes(K, C0, Ca), member(C, Ca) ), Cn),
    findall(Cat-W, mot_du_graphe(G, Cat, W), CW0), sort(CW0, CW),
    findall(mot(X), ( member(Cat-W, CW), K:sens(Cat, W, S0), atteint(K, S0, X) ), Cm),
    append([[toujours], Cn, Cm], Cs0), sort(Cs0, Cs).
mot_du_graphe(G, n, W) :- member(entite(_, W, _), G), atom(W), W \== nom_propre.
mot_du_graphe(G, a, W) :- member(propriete(_, _, W, _), G), atom(W).
mot_du_graphe(G, v, W) :- member(evenement(_, W, _), G), atom(W).
mot_du_graphe(G, r, W) :- member(relation(_, _, W, _, _), G), atom(W).

alias_fermes(K, C, Cs) :- fermeture(K, [C], [C], Cs).
fermeture(K, Front, Vus, Cs) :-
    findall(Y, ( member(X, Front), ( K:alias(X, Y) ; K:alias(Y, X) ), \+ memberchk(Y, Vus) ), Ys0), sort(Ys0, Ys),
    ( Ys == [] -> Cs = Vus ; append(Vus, Ys, Vus1), fermeture(K, Ys, Vus1, Cs) ).

% les nœuds que K atteint par « sous » depuis S, chacun une fois
atteint(K, S, X) :- atteints(K, [S], [S], Xs), member(X, Xs).
atteints(K, Front, Vus, Xs) :-
    findall(Y, ( member(X, Front), K:sous(X, Y), \+ memberchk(Y, Vus) ), Ys0), sort(Ys0, Ys),
    ( Ys == [] -> Xs = Vus ; append(Vus, Ys, Vus1), atteints(K, Ys, Vus1, Xs) ).

% --- Le codage -------------------------------------------------------------------------------------------------------

coder(L, Fs, Mode, Resultats) :- coder(L, Fs, Mode, [], Resultats).
coder(L, Fs, Mode, Opts, Resultats) :-
    indexer, k_de(L, Opts, K),
    ( memberchk(normaliser(non), Opts) -> G = Fs ; normalisation:enrichir(L, Fs, G) ),
    (   Mode == exhaustif
    ->  findall(N, ( requetes_index:requete_compilee(N, L, _, _, _, St, _, _), memberchk(St, [compilee, partielle]) ),
                Ns0)
    ;   cles_du_graphe(K, G, Cs), findall(N, ( member(C, Cs), cle(C, L, N) ), Ns0)
    ),
    sort(Ns0, Ns),
    findall(N-(Qs-Qn), ( member(N, Ns), requetes_index:requete_compilee(N, L, _, Qs, Qn, _, _, _) ), NQs),
    findall(Q, ( member(_-(Q-_), NQs), Q \== aucune ), Suff),
    findall(Q, ( member(_-(_-Q), NQs), Q \== aucune ), Nec),
    ( memberchk(budget(B), Opts) -> Ob = [budget(B)] ; Ob = [] ),
    satisfaction:satisfaire_lot(K, G, Suff, Ob, Rs),
    satisfaction:satisfaire_lot(K, G, Nec, Ob, Rn),
    findall(Code, ( member(N-_, NQs), code(K, G, L, N, Rs, Rn, Code) ), Resultats0),
    sort(Resultats0, Resultats).

% le code d'une notation : la suffisante et la nécessaire, chacune pour elle-même
code(K, G, L, N, Rs, Rn, code(N, Statut, Detail, annexe(Complet, Necessaire))) :-
    requetes_index:requete_compilee(N, L, _, Qs, Qn, St, _, Fa),
    ( Qs \== aucune, memberchk(N-Res0, Rs) -> true ; Res0 = resultat(inconnue, [], complet) ),
    ( Qn \== aucune, memberchk(N-Ren, Rn) -> true ; Ren = resultat(aucune, [], complet) ),
    % une requête mal formée est une erreur du compilateur : elle est dite, jamais perdue en silence (audit final)
    ( Res0 = mal_formee(Es) -> Res = resultat(mal_formee, Es, complet) ; Res = Res0 ),
    ( Ren = mal_formee(_) -> Necessaire = mal_formee, Cn = complet ; Ren = resultat(Necessaire, _, Cn) ),
    Res = resultat(Ss, Els, Cs),
    statut(K, G, Qs, St, Fa, Ss, Els, Statut, Detail),
    ( ( Cs == incomplet ; Cn == incomplet ) -> Complet = incomplet ; Complet = complet ),
    ( Statut \== sans_suffisante -> true ; \+ memberchk(Necessaire, [aucune, inconnue]) ).

statut(K, G, Q, St, Fa, etablie, Ps, Statut, Ps) :- !,
    (   St == compilee, \+ forall(member(P, Ps), verifier(K, G, Q, P, accepte)) -> Statut = rejete_par_le_verificateur
    ;   St == compilee, famille_justifiee(Fa) -> Statut = etabli
    ;   St == compilee -> Statut = etablissable
    ;   forall(member(P, Ps), verifier(K, G, Q, P, accepte)) -> Statut = candidat
    ;   Statut = rejete_par_le_verificateur
    ).
% une conclusion sous hypothèses : conditionnelle, jamais un code établi
statut(K, G, Q, _, _, etablie_sous_hypotheses, Ps, Statut, Ps) :- !,
    ( forall(member(P, Ps), verifier(K, G, Q, P, accepte)) -> Statut = conditionnel ; Statut = rejete_par_le_verificateur ).
statut(_, _, _, _, _, contradictoire, D, contradictoire, D) :- !.
statut(_, _, _, _, _, non_certifiee, D, non_certifie, D) :- !.
statut(_, _, _, _, _, ecartee, D, suffisante_ecartee, D) :- !.
statut(_, _, _, _, _, incomplet, D, incomplet, D) :- !.
statut(_, _, _, _, _, inconnue, _, sans_suffisante, []).
statut(_, _, _, _, _, mal_formee, Es, suffisante_mal_formee, Es).

% les familles de constructions dont la suffisance est justifiée (C3.3 : un échantillon jugé par famille, borne
% supérieure de Wilson du taux de requêtes trop faibles ≤ 5 %) ; aucune ne l'est à ce jour
:- dynamic familles_justifiees/1.
famille_justifiee(F) :- familles_justifiees(Fs), memberchk(F, Fs), !.
