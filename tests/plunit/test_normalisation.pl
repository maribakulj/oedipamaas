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
test(les_hypothetiques_restent_definies) :-     % R2 existe toujours (lot 3 : avec une provenance), sans s'appliquer
    arche(G0), normalisation:ajout_de_role(r2, G0, role(v1, agent, e1)).

:- end_tests(normalisation).
