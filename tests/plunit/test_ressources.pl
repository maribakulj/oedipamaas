/*  Une exception de ressource (budget d'inférences, limite de temps) n'est jamais un verdict (contrôle indexé /
    exhaustif du lot 1, 27/11) : le vérificateur la relance au lieu de rejeter la preuve, le comparateur au lieu de
    rendre « indéterminé ».  */
:- use_module('../../oedipamaas/socle/satisfaction').
:- use_module('../../oedipamaas/socle/verificateur').
:- use_module('../../oedipamaas/socle/inclusion').
:- use_module(connaissances_essai).
:- use_module(library(plunit)).
:- encoding(utf8).

:- consult(test_noyau_semantique).          % graphe_cas/2

preuve_essai(G, Q, P) :-
    graphe_cas([entite(e1, lionne, p_1), entite(e2, homme, p_2), evenement(v1, tenir, p_3), role(v1, agent, e2),
                role(v1, theme, e1)], G),
    Q = requete(q, et([type(v(x), lion), type(v(y), homme), evenement(v(e), tenir), role(v(e), agent, v(y)),
                       role(v(e), theme, v(x))])),
    satisfaire(connaissances_essai, G, Q, resultat(etablie, [P], _)).

:- begin_tests(ressources).

test(la_preuve_est_acceptee_sans_limite) :-
    preuve_essai(G, Q, P), verifier(connaissances_essai, G, Q, P, accepte).
test(un_budget_epuise_dans_le_verificateur_n_est_pas_un_rejet) :-
    % pour chaque budget, de trop petit à suffisant : l'issue est l'acceptation ou le budget épuisé, jamais un rejet
    preuve_essai(G, Q, P),
    statistics(inferences, I0), verifier(connaissances_essai, G, Q, P, accepte), statistics(inferences, I1),
    N is I1 - I0, Pas is max(1, N // 200),
    forall(between(0, 201, J),
           ( L is 1 + J * Pas,
             call_with_inference_limit(verifier(connaissances_essai, G, Q, P, V), L, Issue),
             (   ( Issue == inference_limit_exceeded ; V == accepte ) -> true
             ;   format(user_error, "budget ~w : verdict ~w~n", [L, V]), fail
             ) )).
test(une_limite_de_temps_dans_le_verificateur_est_relancee) :-
    preuve_essai(G, Q, P),
    catch(call_with_time_limit(0.000001, ( repeat, verifier(connaissances_essai, G, Q, P, _), fail )), E, true),
    ( E == time_limit_exceeded ; E = time_limit_exceeded(_) ), !.
test(un_budget_epuise_dans_le_comparateur_n_est_pas_un_verdict) :-
    Q1 = requete(a, et([type(v(x), lion), evenement(v(e), tenir), role(v(e), agent, v(x))])),
    Q2 = requete(b, et([type(v(x), felin), evenement(v(e), tenir), role(v(e), agent, v(x))])),
    statistics(inferences, I0), once(inclusion(connaissances_essai, aucune, Q1, Q2, R0)), statistics(inferences, I1),
    N is I1 - I0, Pas is max(1, N // 200),
    forall(between(0, 201, J),
           ( L is 1 + J * Pas,
             call_with_inference_limit(inclusion(connaissances_essai, aucune, Q1, Q2, R), L, Issue),
             (   ( Issue == inference_limit_exceeded ; R == R0 ) -> true
             ;   format(user_error, "budget ~w : verdict ~w (sans limite : ~w)~n", [L, R, R0]), fail
             ) )).

:- end_tests(ressources).
