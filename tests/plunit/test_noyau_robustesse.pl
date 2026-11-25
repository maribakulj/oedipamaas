/*  Robustesse du noyau (docs/QUALIFICATION_NOYAU.md, D11 à D13, D19, D21) : entrées invalides, reproductibilité,
    isolation et concurrence, identifiants de concepts, limite de temps. Sans donnée.  */
:- use_module('../../oedipamaas/socle/satisfaction').
:- use_module('../../oedipamaas/socle/satisfaction_reference').
:- use_module('../../oedipamaas/socle/verificateur').
:- use_module(connaissances_essai).
:- use_module(library(plunit)).
:- use_module(library(lists)).
:- use_module(library(apply)).
:- use_module(library(random)).
:- encoding(utf8).

:- consult(test_noyau_semantique).          % graphe/2, graphe_cas/2, cas/5

k(connaissances_essai).

:- begin_tests(noyau_robustesse).

% D11 : une entrée invalide donne une erreur structurée, jamais un résultat
test(graphe_pas_une_liste, [throws(error(graphe_invalide([pas_une_liste]), _))]) :-
    k(K), satisfaire(K, pas_une_liste, requete(q, type(v(x), lion)), _).
test(graphe_terme_inconnu, [throws(error(graphe_invalide(_), _))]) :-
    graphe([entite(e1, lion, p_1)], G), k(K), satisfaire(K, [bizarre(1)|G], requete(q, type(v(x), lion)), _).
test(graphe_identifiant_double, [throws(error(graphe_invalide(_), _))]) :-
    graphe([entite(e1, lion, p_1), nom(e1, e1, pierre, p_1)], G), k(K), satisfaire(K, G, requete(q, type(v(x), lion)), _).
test(graphe_qualificatif_manquant, [throws(error(graphe_invalide(_), _))]) :-
    graphe([entite(e1, lion, p_1)], G0), selectchk(polarite(e1, pos), G0, G), k(K),
    satisfaire(K, G, requete(q, type(v(x), lion)), _).
test(graphe_role_vers_un_evenement_absent, [throws(error(graphe_invalide(_), _))]) :-
    graphe([entite(e1, lion, p_1), role(v9, agent, e1)], G), k(K), satisfaire(K, G, requete(q, type(v(x), lion)), _).
test(requete_mal_formee, [throws(error(requete_mal_formee(q, _), _))]) :-
    graphe([entite(e1, lion, p_1)], G), k(K), satisfaire(K, G, requete(q, ou([type(v(x), lion)])), _).
test(requete_pas_une_requete, [throws(error(requete_mal_formee(_, _), _))]) :-
    graphe([entite(e1, lion, p_1)], G), k(K), satisfaire(K, G, pas_une_requete, _).
test(verificateur_graphe_invalide) :-
    k(K), verifier(K, [bizarre], requete(q, type(v(x), lion)), preuve(q, [], figuration, [], [], []), rejete([graphe_invalide])).
test(verificateur_preuve_non_close) :-
    graphe([entite(e1, lion, p_1)], G), k(K), verifier(K, G, requete(q, type(v(x), lion)), preuve(q, _, _, _, _, _), rejete(_)).
test(verificateur_liste_impropre) :-
    graphe([entite(e1, lion, p_1)], G), k(K), Q = requete(q, type(v(x), lion)),
    satisfaire(K, G, Q, resultat(etablie, [preuve(I, V, R, S, [J], H)], _)),
    verifier(K, G, Q, preuve(I, V, R, S, [J|impropre], H), rejete(_)).

% D13 : même entrée, même sortie ; le graphe permuté donne le même résultat et la même empreinte
test(reproductible) :-
    forall(cas(_, Fs, Q, _, _), ( graphe_cas(Fs, G), k(K), satisfaire(K, G, Q, R1), satisfaire(K, G, Q, R2), R1 == R2 )).
test(ordre_des_faits_sans_effet) :-
    set_random(seed(3)),
    forall(cas(_, Fs, Q, _, _), ( graphe_cas(Fs, G), random_permutation(G, Gp), k(K),
                                   satisfaire(K, G, Q, R1), satisfaire(K, Gp, Q, R2), R1 == R2 )).
test(empreinte_independante_de_l_ordre) :-
    graphe_cas([entite(e1, lion, p_1), entite(e2, homme, p_2)], G), reverse(G, Gr),
    empreinte(G, H1), empreinte(Gr, H2), H1 == H2.

% D12 : des appels concurrents (plusieurs fils) donnent les résultats des appels en série
test(concurrence) :-
    findall(G-Q, ( cas(_, Fs, Q, _, _), graphe_cas(Fs, G) ), Ps),
    k(K), maplist([G-Q, R]>>satisfaire(connaissances_essai, G, Q, R), Ps, Rs1), K == connaissances_essai,
    concurrent_maplist([G-Q, R]>>satisfaire(connaissances_essai, G, Q, R), Ps, Rs2),
    Rs1 == Rs2.
test(aucun_module_temporaire_laisse) :-
    findall(M, ( current_module(M), sub_atom(M, 0, _, _, 'tmp-') ), Avant),
    forall(( cas(_, Fs, Q, _, _), graphe_cas(Fs, G) ), ( k(K), satisfaire(K, G, Q, _) )),
    catch(( graphe([entite(e1, lion, p_1)], G2), k(K2), satisfaire(K2, G2, requete(q, ou([type(v(x), a)])), _) ), _, true),
    findall(M, ( current_module(M), sub_atom(M, 0, _, _, 'tmp-') ), Apres),
    length(Avant, N1), length(Apres, N2), N2 =< N1.

% D19 : un type de requête peut être un identifiant de concept de K (un entier), pas seulement un lemme
test(type_concept_entier) :-
    graphe([entite(e1, lionne, p_1)], G), k(K),
    satisfaire(K, G, requete(q, type(v(x), 1000)), resultat(etablie, [P], _)),
    verifier(K, G, requete(q, type(v(x), 1000)), P, accepte),
    statut_reference(K, G, requete(q, type(v(x), 1000)), etablie).

% D21 : une limite de temps ; dépassée avant une solution certifiable, le résultat est incomplet, jamais négatif
test(limite_de_temps) :-
    findall(entite(F, femme, p_1), ( between(1, 12, I), atom_concat(f, I, F) ), Fs),
    findall(relation(R, F1, avec, F2, p_1), ( member(entite(F1, _, _), Fs), member(entite(F2, _, _), Fs),
                                              atomic_list_concat([r, F1, F2], '_', R) ), Rs),
    append(Fs, Rs, X), graphe(X, G), k(K),
    Q = requete(q, et([relation(v(a), avec, v(b)), relation(v(b), avec, v(c)), relation(v(c), avec, v(d)),
                       relation(v(d), avec, v(a))])),        % 12^4 solutions : le calcul dure
    satisfaire(K, G, Q, [temps(0.05)], resultat(S, _, C)), S == incomplet, C == incomplet.

:- end_tests(noyau_robustesse).
