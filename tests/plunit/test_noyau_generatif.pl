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

cas_generatifs(N) :- ( getenv('OEDIPAMAAS_CAS_GENERATIFS', A), atom_number(A, N0) -> N = N0 ; N = 1500 ).

un_de(L, X) :- random_member(X, L).
peut_etre(P) :- random(X), X < P.

% --- Les graphes ---------------------------------------------------------------------------------------------------

graphe_aleatoire(G) :-
    random_between(1, 5, NE), numlist(1, NE, Is),
    maplist([I, E]>>atom_concat(e, I, E), Is, Es),
    findall(entite(E, T, p_0), ( member(E, Es), un_de([a, a1, a2, b, b1, top, c1, lemme_a, nom_propre], T) ), Ents),
    findall(nom(N, E, Nm, p_0), ( member(E, Es), peut_etre(0.5), atom_concat(n_, E, N), un_de([x, xa, y, z], Nm) ), Noms1),
    % un second nom, parfois le même, pour que des appuis de signes opposés se rencontrent (contradictions)
    findall(nom(N, E, Nm, p_0), ( member(nom(_, E, Nm0, _), Noms1), peut_etre(0.4), atom_concat(m_, E, N),
                                  ( peut_etre(0.6) -> Nm = Nm0 ; un_de([x, y], Nm) ) ), Noms2),
    append(Noms1, Noms2, Noms),
    findall(propriete(Q, E, P, p_0), ( member(E, Es), peut_etre(0.3), atom_concat(q_, E, Q), un_de([r, r1], P) ), Props),
    random_between(0, 2, NV), ( NV =:= 0 -> Js = [] ; numlist(1, NV, Js) ),
    findall(evenement(V, P, p_0), ( member(J, Js), atom_concat(v, J, V), un_de([p, p1, q], P) ), Evs),
    findall(role(V, R, E), ( member(evenement(V, _, _), Evs), member(R, [agent, patient, theme]), peut_etre(0.6),
                             un_de(Es, E) ), Roles),
    findall(relation(A, E1, Rl, E2, p_0), ( member(E1, Es), peut_etre(0.3), un_de(Es, E2), atom_concat(r_, E1, A),
                                            un_de([s, s1], Rl) ), Rels),
    findall(coref(E1, E2), ( member(E1, Es), member(E2, Es), E1 @< E2, peut_etre(0.15) ), Cor),
    findall(distinct(E1, E2), ( member(E1, Es), member(E2, Es), E1 @< E2, \+ memberchk(coref(E1, E2), Cor),
                                peut_etre(0.15) ), Dis),
    findall(nombre(E, K), ( member(E, Es), peut_etre(0.2), random_between(1, 3, K) ), Nbs),
    append([Ents, Noms, Props, Evs, Roles, Rels, Cor, Dis, Nbs], G0),
    findall(A, ( member(F, G0), ident(F, A) ), As0), sort(As0, As),
    findall(Qf, ( member(A, As), qualifs(A, Qs), member(Qf, Qs) ), Qual),
    ( As = [A1, A2|_], peut_etre(0.1) -> Alt = [alternative(g1, [A1, A2])] ; Alt = [] ),
    append([[texte("x"), doc(fr, inconnu)], G0, Qual, Alt, [passage(p_0, 0, 1)]], G).

ident(entite(A, _, _), A). ident(nom(A, _, _, _), A). ident(propriete(A, _, _, _), A). ident(evenement(A, _, _), A).
ident(relation(A, _, _, _, _), A).
qualifs(A, [polarite(A, Po), modalite(A, Mo), portee(A, Pr), enonciateur(A, En)]) :-
    ( peut_etre(0.2) -> Po = neg ; Po = pos ),
    ( peut_etre(0.1) -> Mo = possible ; Mo = affirme ),
    random(X), ( X < 0.8 -> Pr = represente ; X < 0.93 -> Pr = oeuvre ; Pr = histoire ),
    ( peut_etre(0.1) -> En = cite(z) ; En = auteur ).

% --- Les requêtes --------------------------------------------------------------------------------------------------

requete_aleatoire(requete(r, F)) :-
    peut_etre(0.3), !,                        % deux référents nommés et leur distinction (hypothèses, documents)
    un_de([['X'], ['XA']], K1), un_de([['Y'], ['Z']], K2),
    un_de([distincts(v(x), v(y)), meme(v(x), v(y))], C), F = et([nom(v(x), K1), nom(v(y), K2), C]).
requete_aleatoire(requete(r, F)) :-
    between(1, 500, _), random_between(1, 3, P), formule(P, F), requetes:bien_formee(requete(r, F), []), !.

formule(Pr, F) :-
    random(X),
    (   Pr > 0, X < 0.25 -> random_between(2, 3, N), length(Fs, N), maplist(formule(Pr - 1), Fs), F = ou(Fs)
    ;   Pr > 0, X < 0.55 -> random_between(1, 3, N), length(Fs, N), maplist(formule(Pr - 1), Fs), F = et(Fs)
    ;   X < 0.8 -> atome_gen(F)
    ;   contrainte_gen(F)
    ).
ref(v(V)) :- un_de([x, y, z], V).
atome_gen(A) :-
    random_between(1, 7, I),
    (   I =:= 1 -> ref(X), un_de([a, a1, b, top, c2, lemme_a], T), A = type(X, T)
    ;   I =:= 2 -> ref(X), un_de([['X'], ['Y'], ['Z'], ['X', 'Y']], Ks), A = nom(X, Ks)
    ;   I =:= 3 -> ref(X), un_de([r, r1], P), A = propriete(X, P)
    ;   I =:= 4 -> un_de([p, p0, q], P), A = evenement(v(e), P)
    ;   I =:= 5 -> ref(X), un_de([agent, patient, theme], R), A = role(v(e), R, X)
    ;   I =:= 6 -> ref(X), ref(Y), un_de([s, s1], R), A = relation(X, R, Y)
    ;   un_de([a, top], T), A = genre(T)
    ).
contrainte_gen(C) :-
    ref(X), ref(Y), random_between(1, 3, I),
    ( I =:= 1 -> C = meme(X, Y) ; I =:= 2 -> C = distincts(X, Y) ; random_between(1, 3, K), C = nombre(X, K) ).

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
