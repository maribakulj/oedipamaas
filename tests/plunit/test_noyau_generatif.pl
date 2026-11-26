/*  Tests génératifs du noyau (docs/NOYAU.md, § 7) : de petits graphes et de petites requêtes tirés au hasard (graine
    fixe), sur lesquels
      1. le moteur optimisé (satisfaction.pl) donne exactement la vue du moteur de référence (satisfaction_reference.pl,
         énumération naïve de toutes les substitutions partielles) : solutions certifiables, et substitutions minimales
         contradictoires, vraies non certifiables, fausses ;
      2. il en donne le statut, quand le calcul est complet ;
      3. chaque preuve qu'il produit est acceptée par le vérificateur ;
      4. le vérificateur est sûr : une preuve altérée au hasard qu'il accepte décrit une solution vraie du moteur de
         référence.
    Le nombre de cas (CAS) se règle par la variable d'environnement OEDIPAMAAS_CAS_GENERATIFS (1 500 par défaut).
    Les distributions effectives (statuts, preuves, altérations rejetées, opérateurs) sont publiées sur la sortie
    d'erreur par le dernier test, qui exige que chaque statut et chaque opérateur apparaissent.  */
:- use_module('../../oedipamaas/socle/requetes').
:- use_module('../../oedipamaas/socle/satisfaction').
:- use_module('../../oedipamaas/socle/satisfaction_reference').
:- use_module('../../oedipamaas/socle/verificateur').
:- use_module(connaissances_gen).
:- use_module(library(plunit)).
:- use_module(library(random)).
:- use_module(library(lists)).
:- use_module(library(apply)).
:- encoding(utf8).

:- consult(generateur_noyau).          % graphe_aleatoire/1, requete_aleatoire/1, cas_generatifs/1

% --- Les propriétés ------------------------------------------------------------------------------------------------

k(connaissances_gen).

cas(G, Q) :- graphe_aleatoire(G), requete_aleatoire(Q).

meme_solutions(G, Q) :-
    k(K), satisfaction:solutions_classees(K, G, Q, V1), satisfaction_reference:vue_reference(K, G, Q, V2),
    V1 == V2.
meme_statut(G, Q) :-
    k(K), satisfaire(K, G, Q, resultat(S1, _, Complet)),
    ( Complet == incomplet -> true ; satisfaction_reference:statut_reference(K, G, Q, S2), S1 == S2 ).
preuves_acceptees(G, Q) :-
    k(K), satisfaire(K, G, Q, resultat(_, Els, _)),
    forall(( member(P, Els), P = preuve(_, _, _, _, _, _) ), verifier(K, G, Q, P, accepte)).

% une altération au hasard d'une preuve (et son nom, pour les distributions)
alterer(G, preuve(I, V, R, S, Js, H), P2, Nom) :-
    random_between(1, 8, X),
    (   X =:= 1, S = [_|_] -> Nom = sigma, random_select(Va-_, S, S0), findall(E, member(entite(E, _, _), G), Es0),
        findall(E, member(evenement(E, _, _), G), Vs0), append(Es0, Vs0, Ds), random_member(D, Ds),
        P2 = preuve(I, V, R, [Va-D|S0], Js, H)
    ;   X =:= 2, Js = [_, _|_] -> Nom = retire, random_select(_, Js, Js1), P2 = preuve(I, V, R, S, Js1, H)
    ;   X =:= 3 -> Nom = appui, random_select(J, Js, Js0),
        ( J = j(C, A, appui(_, E, Pa, L)) -> findall(Id, ( member(F, G), ident(F, Id) ), Ids), random_member(Id, Ids),
                                             P2 = preuve(I, V, R, S, [j(C, A, appui(Id, E, Pa, L))|Js0], H)
        ;   P2 = preuve(I, V, R, S, [J, J|Js0], H) )
    ;   X =:= 4 -> Nom = chemin, random_select(j(C, A, Ap), Js, Js0), random_between(1, 3, N),
        ( append(C0, [_], C) -> append(C0, [N], C1) ; C1 = [N] ), P2 = preuve(I, V, R, S, [j(C1, A, Ap)|Js0], H)
    ;   X =:= 5 -> Nom = variable_etrangere, P2 = preuve(I, V, R, [v(etrangere)-e1|S], Js, H)
    ;   X =:= 6 -> Nom = regime, ( R == figuration -> R2 = classement ; R2 = figuration ), P2 = preuve(I, V, R2, S, Js, H)
    ;   X =:= 7, H = [_|H1] -> Nom = hypothese, P2 = preuve(I, V, R, S, Js, H1)
    ;   Nom = parasite, P2 = preuve(I, V, R, S, [parasite|Js], H)
    ).

% si le vérificateur accepte une preuve altérée, sa substitution et sa sélection sont une solution certifiable de la
% référence
verificateur_sur(G, Q, Bilan) :-
    k(K), satisfaire(K, G, Q, resultat(_, Els, _)),
    include([P]>>( P = preuve(_, _, _, _, _, _) ), Els, Ps),
    (   Ps == [] -> Bilan = []
    ;   satisfaction_reference:vue_reference(K, G, Q, vue(Cert, _, _, _)),
        findall(Nom-V, ( member(P, Ps), between(1, 5, _), alterer(G, P, P2, Nom), P2 \== P,
                         (   verifier(K, G, Q, P2, accepte)
                         ->  P2 = preuve(_, _, _, S2, Js2, _), findall(C-A, member(j(C, A, _), Js2), Sel0),
                             sort(Sel0, Sel), sort(S2, S2s), ( memberchk(cert(_, S2s, Sel), Cert) -> V = acceptee_juste ; V = acceptee_fausse )
                         ;   V = rejetee ) ), Bilan)
    ).

operateurs(requete(_, F), Ops) :- findall(O, ( sous(F, X), functor(X, O, _) ), Ops0), sort(Ops0, Ops).
sous(F, F).
sous(et(Fs), X) :- member(F, Fs), sous(F, X).
sous(ou(Fs), X) :- member(F, Fs), sous(F, X).

:- begin_tests(noyau_generatif).

test(moteur_optimise_egal_a_la_reference) :-
    set_random(seed(20261125)), cas_generatifs(N),
    findall(G-Q, ( between(1, N, _), cas(G, Q), \+ meme_solutions(G, Q) ), Ecarts),
    length(Ecarts, NE), ( NE > 0 -> Ecarts = [Ex|_], print_message(error, format("écart : ~q", [Ex])) ; true ),
    assertion(NE == 0).
test(meme_statut) :-
    set_random(seed(20261126)), cas_generatifs(N),
    findall(x, ( between(1, N, _), cas(G, Q), \+ meme_statut(G, Q) ), Ecarts), assertion(Ecarts == []).
test(preuves_acceptees) :-
    set_random(seed(20261127)), cas_generatifs(N),
    findall(x, ( between(1, N, _), cas(G, Q), \+ preuves_acceptees(G, Q) ), Ecarts), assertion(Ecarts == []).
test(verificateur_sur) :-
    set_random(seed(20261128)), cas_generatifs(N),
    findall(B, ( between(1, N, _), cas(G, Q), verificateur_sur(G, Q, B0), member(B, B0) ), Bs),
    exclude([_-V]>>( V \== acceptee_fausse ), Bs, Fausses), assertion(Fausses == []).
test(distributions_publiees) :-                 % ce que les cas ont effectivement exercé ; chaque statut et opérateur
    set_random(seed(20261129)), cas_generatifs(N), k(K),
    findall(S-Ops-NP, ( between(1, N, _), cas(G, Q), satisfaire(K, G, Q, resultat(S, Els, _)), operateurs(Q, Ops),
                        include([P]>>( P = preuve(_, _, _, _, _, _) ), Els, Ps), length(Ps, NP) ), L),
    findall(S, member(S-_-_, L), Ss), msort(Ss, Ss1), clumped(Ss1, Cs), format(user_error, "statuts : ~w~n", [Cs]),
    findall(O, ( member(_-Ops-_, L), member(O, Ops) ), Os), msort(Os, Os1), clumped(Os1, Co),
    format(user_error, "opérateurs : ~w~n", [Co]),
    aggregate_all(sum(NP), member(_-_-NP, L), TP), aggregate_all(count, ( member(_-_-NP, L), NP > 1 ), Multi),
    format(user_error, "preuves : ~d ; requêtes à plusieurs preuves : ~d~n", [TP, Multi]),
    set_random(seed(20261128)),
    findall(B, ( between(1, N, _), cas(G, Q), verificateur_sur(G, Q, B0), member(B, B0) ), Bs),
    msort(Bs, Bs1), clumped(Bs1, Cb), format(user_error, "altérations : ~w~n", [Cb]),
    forall(member(X, [etablie, etablie_sous_hypotheses, contradictoire, non_certifiee, ecartee, inconnue]), memberchk(X, Ss)),
    forall(member(X, [et, ou, type, nom, propriete, evenement, role, relation, genre, meme, distincts, nombre]), memberchk(X, Os)).

:- end_tests(noyau_generatif).
