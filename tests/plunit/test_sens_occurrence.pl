/*  Les hypothèses de sens par occurrence et leur satisfaisabilité conjointe (lot 4 ; docs/QUALIFICATION_NOYAU.md,
    § 10, L1 ; docs/NOYAU.md, § 2 et § 4.3). Sans donnée : le K de test (« pomme » : un fruit, 2001, ou une pomme
    d'arrosoir, 2002 ; « poire » : un fruit, 2101, ou une forme, 2102).  */
:- use_module('../../oedipamaas/socle/satisfaction').
:- use_module('../../oedipamaas/socle/satisfaction_reference').
:- use_module('../../oedipamaas/socle/verificateur').
:- use_module(connaissances_essai).
:- use_module(library(plunit)).
:- use_module(library(lists)).
:- encoding(utf8).

:- consult(test_noyau_semantique).          % graphe_cas/2, les cas

k(connaissances_essai).
une_pomme(G) :- graphe_cas([entite(e1, pomme, p_1)], G).
pomme_poire(G) :- graphe_cas([entite(e1, pomme, p_1), entite(e2, poire, p_2), coref(e1, e2)], G).
vegetal_et(T, requete(q, et([type(v(x), vegetal), type(v(x), T)]))).

:- begin_tests(sens_occurrence).

test(l_hypothese_nomme_l_occurrence) :-
    une_pomme(G), k(K), satisfaire(K, G, requete(q, type(v(x), vegetal)), resultat(etablie_sous_hypotheses, [P], _)),
    P = preuve(_, _, _, _, _, Hs), Hs == [sens_suppose(e1, pomme, vegetal)],
    verifier(K, G, requete(q, type(v(x), vegetal)), P, accepte).
test(deux_lectures_exclusives_d_une_occurrence_ne_certifient_rien) :-
    une_pomme(G), k(K), vegetal_et(objet, Q),
    satisfaire(K, G, Q, resultat(non_certifiee, _, _)), statut_reference(K, G, Q, non_certifiee).
test(le_choix_revient_sur_le_premier_atome) :-
    pomme_poire(G), k(K), vegetal_et(objet, Q),
    satisfaire(K, G, Q, resultat(etablie_sous_hypotheses, [P], _)),
    P = preuve(_, _, _, _, Js, Hs),
    Hs == [sens_suppose(e1, pomme, objet), sens_suppose(e2, poire, vegetal)],
    memberchk(j([1], type(v(x), vegetal), appui(e2, e2, _, _)), Js),
    memberchk(j([2], type(v(x), objet), appui(e1, e1, _, _)), Js),
    verifier(K, G, Q, P, accepte).
test(le_moteur_de_reference_fait_le_meme_choix) :-
    pomme_poire(G), k(K), vegetal_et(objet, Q),
    solutions_classees(K, G, Q, V), vue_reference(K, G, Q, Vr), V == Vr.
% une preuve forgée qui donne à une même occurrence deux sens exclusifs est rejetée, par ce seul contrôle
test(preuve_forgee_rejetee_par_les_lectures_conjointes) :-
    une_pomme(G), k(K), vegetal_et(pomme, Q0),
    satisfaire(K, G, Q0, resultat(_, [preuve(_, Vs, Rg, S, _, _)], _)),
    vegetal_et(objet, Q),
    P = preuve(q, Vs, Rg, S, [j([1], type(v(x), vegetal), appui(e1, e1, p_1, chemin(pomme, [2001, fruit, vegetal]))),
                              j([2], type(v(x), objet), appui(e1, e1, p_1, chemin(pomme, [2002, objet])))],
               [sens_suppose(e1, pomme, objet), sens_suppose(e1, pomme, vegetal)]),
    verifier(K, G, Q, P, V), V == rejete([lectures_conjointes]).
% la condition B3 (une lecture au moins) est le cas d'un seul atome : « une pomme ; pas de fruit ; pas d'objet »
test(b3_est_le_cas_d_un_atome) :-
    graphe_cas([entite(e1, pomme, p_1), entite(e2, fruit, p_2), neg(e2), entite(e3, objet, p_3), neg(e3)], G), k(K),
    satisfaire(K, G, requete(q, type(v(x), pomme)), resultat(S, _, _)), S \== etablie, S \== etablie_sous_hypotheses.

:- end_tests(sens_occurrence).
