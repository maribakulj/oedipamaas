/*  La normalisation neutralisée (lot 2 de la phase C3/C6/C7 ; docs/QUALIFICATION_NOYAU.md, § 10, L2) : aucune règle
    hypothétique n'introduit de prémisse par défaut. Sans donnée : seules les règles qui ne demandent pas WordNet (R1,
    R2) sont appliquées en mode explicite ; les autres sont vérifiées par leur statut.  */
:- use_module('../../oedipamaas/socle/normalisation').
:- use_module('../../oedipamaas/socle/satisfaction').
:- use_module(connaissances_essai).
:- use_module(library(plunit)).
:- use_module(library(lists)).
:- encoding(utf8).

:- consult(test_noyau_semantique).          % graphe_cas/2

% « l'arche flotte » : un participant unique ; « la barque porte l'homme » : un thème
arche(G) :- graphe_cas([entite(e1, arche, p_1), evenement(v1, flotter, p_2), role(v1, theme, e1)], G).
barque(G) :- graphe_cas([entite(e1, barque, p_1), entite(e2, homme, p_2), evenement(v1, porter, p_3),
                         role(v1, agent, e1), role(v1, theme, e2)], G).

:- begin_tests(normalisation).

test(aucune_regle_certaine) :- \+ regle(_, certaine, _).
test(chaque_regle_a_une_raison) :-
    forall(regle(R, St, Raison), ( atom(R), memberchk(St, [certaine, hypothetique]), atom(Raison), Raison \== '' )),
    findall(R, regle(R, _, _), Rs), msort(Rs, Rs1), Rs1 == [c1, e1, e2, p1, r1, r2].
test(par_defaut_le_graphe_est_inchange) :-
    arche(G1), enrichir(en, G1, H1), msort(G1, S1), msort(H1, S1b), S1 == S1b,
    barque(G2), enrichir(fr, G2, H2), msort(G2, S2), msort(H2, S2b), S2 == S2b.
test(le_participant_unique_n_est_plus_agent) :-
    % avant le lot 2 : « l'arche flotte » établissait « l'arche est l'agent d'un flotter »
    arche(G0), enrichir(en, G0, G),
    satisfaire(connaissances_essai, G, requete(q, et([evenement(v(e), flotter), role(v(e), agent, v(x))])),
               resultat(St, _, _)),
    St \== etablie.
test(le_theme_n_est_plus_patient) :-
    barque(G0), enrichir(fr, G0, G),
    satisfaire(connaissances_essai, G, requete(q, et([evenement(v(e), porter), role(v(e), patient, v(x))])),
               resultat(St, _, _)),
    St \== etablie.
test(les_hypothetiques_restent_definies) :-     % R2 existe toujours, avec sa provenance, sans s'appliquer
    arche(G0), once(normalisation:ajout_de_role(r2, G0, role(v1, agent, e1), [evenement(v1, flotter, p_2), role(v1, theme, e1)])).

:- end_tests(normalisation).

% --- La provenance (lot 3) : chaque assertion dérivée dit sa règle, son statut et ses sources ------------------------

% un WordNet minimal, pour E2 sans donnée : « training » est le nom d'action de « train » (noun.act)
:- dynamic wordnet:s/6, wordnet:der/4, wordnet:lexfile/2, ressources:morphosem/5.
wordnet_essai :-
    retractall(wordnet:s(_, _, _, _, _, _)), retractall(wordnet:der(_, _, _, _)), retractall(wordnet:lexfile(_, _)),
    assertz(wordnet:s(201, 1, train, v, 1, 0)), assertz(wordnet:s(101, 1, training, n, 1, 0)),
    assertz(wordnet:der(201, 1, 101, 1)), assertz(wordnet:lexfile(101, 'noun.act')),
    abolish_all_tables.
% « training of dogs »
dressage(G) :- graphe_cas([entite(e1, training, p_1), entite(e2, dog, p_2), relation(r1, e1, of, e2, p_3)], G).

:- begin_tests(provenance, [setup(wordnet_essai)]).

test(chaque_derivation_a_sa_regle_son_statut_ses_sources) :-
    dressage(G0), deriver(en, G0, Ds), Ds \== [],
    forall(member(D, Ds), ( D = derivation(F, R, St, Ss), regle(R, St, _), \+ memberchk(F, G0), is_list(Ss), Ss \== [] )).
test(les_sources_premieres_sont_du_graphe) :-          % une source est du graphe, ou une autre dérivation
    dressage(G0), deriver(en, G0, Ds),
    forall(( member(derivation(_, _, _, Ss), Ds), member(S, Ss) ),
           ( memberchk(S, G0) -> true ; memberchk(derivation(S, _, _, _), Ds) )).
test(nominalisation_avec_provenance) :-
    dressage(G0), deriver(en, G0, Ds),
    memberchk(derivation(evenement(ve_e1_train, train, p_1), e2, hypothetique, [entite(e1, training, p_1)]), Ds),
    memberchk(derivation(role(ve_e1_train, patient, e2), e2, hypothetique, Ss), Ds),
    msort(Ss, Ss1), msort([entite(e1, training, p_1), relation(r1, e1, of, e2, p_3)], Ss1).
test(une_chaine_de_derivations) :-                     % R2 sur l'événement que E2 a dérivé : la chaîne est suivie
    dressage(G0), deriver(en, G0, Ds),
    memberchk(derivation(role(ve_e1_train, agent, e2), r2, hypothetique, _), Ds),
    derivations_requises(Ds, [role(ve_e1_train, agent, e2)], Rs),
    forall(member(F, [role(ve_e1_train, agent, e2), evenement(ve_e1_train, train, p_1), role(ve_e1_train, patient, e2)]),
           memberchk(derivation(F, _, _, _), Rs)),
    forall(( member(derivation(_, _, _, Ss), Rs), member(S, Ss) ),
           ( memberchk(S, G0) -> true ; memberchk(derivation(S, _, _, _), Rs) )).
test(enrichir_est_la_projection_des_derivations) :-
    dressage(G0), deriver(en, G0, Ds), enrichir(en, [regles(toutes)], G0, G),
    findall(F, member(derivation(F, _, _, _), Ds), Fs), append(G0, Fs, G1), sort(G1, G1s), G == G1s,
    enrichir(en, G0, Gc), msort(G0, G0s), Gc == G0s.                 % aucune règle certaine : rien par défaut

:- end_tests(provenance).
