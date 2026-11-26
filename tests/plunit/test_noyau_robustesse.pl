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
% D35 : une contrainte ne porte que sur des référents
test(contrainte_sur_un_evenement, [throws(error(requete_mal_formee(q, [contrainte_sur_evenement(v(e))]), _))]) :-
    graphe([entite(e1, homme, p_1), evenement(v1, bercer, p_2), role(v1, agent, e1)], G), k(K),
    satisfaire(K, G, requete(q, et([evenement(v(e), bercer), role(v(e), agent, v(x)), distincts(v(e), v(x))])), _).
% D32 : un calcul interrompu qui n'a trouvé qu'une solution sous hypothèse ne dit pas « aucune vraie »
test(budget_et_hypothese) :-
    graphe([entite(e1, homme, p_1), nom(n1, e1, abel, p_2), entite(e2, homme, p_3), nom(n2, e2, cain, p_4),
            entite(e3, lion, p_5)], G), k(K),
    Q = requete(q, ou([et([nom(v(x), ['ABEL']), nom(v(y), ['CAIN']), distincts(v(x), v(y))]), type(v(z), lion)])),
    satisfaire(K, G, Q, resultat(etablie, _, complet)),
    forall(between(1, 6, B), ( satisfaire(K, G, Q, [budget(B)], resultat(St, _, C)),
                               ( C == complet -> St == etablie ; memberchk(St, [etablie, incomplet]) ) )).
% D43 : une hiérarchie à 2^24 chemins simples ; le lien est cherché en temps polynomial, dans les trois programmes
test(hierarchie_en_losanges, [setup(use_module(connaissances_losange))]) :-
    graphe([entite(e1, a0, p_1), entite(e2, cible, p_2), neg(e2)], G),
    satisfaire(connaissances_losange, G, requete(q, type(v(x), cible)), [temps(20)], resultat(S1, _, complet)),
    S1 == ecartee,
    satisfaire(connaissances_losange, G, requete(q, type(v(x), b24)), [temps(20)], resultat(etablie, [P], complet)),
    verifier(connaissances_losange, G, requete(q, type(v(x), b24)), P, accepte),
    statut_reference(connaissances_losange, G, requete(q, type(v(x), cible)), ecartee).
% D42 : un graphe non clos est invalide (une variable libre unifierait avec tout)
test(graphe_non_clos, [throws(error(graphe_invalide(_), _))]) :-
    graphe([entite(e1, lion, p_1)], G0), selectchk(entite(e1, lion, p_1), G0, entite(e1, _, p_1), G), k(K),
    satisfaire(K, G, requete(q, type(v(x), lion)), _).
test(verificateur_graphe_non_clos) :-
    graphe([entite(e1, lion, p_1)], G0), k(K), satisfaire(K, G0, requete(q, type(v(x), lion)), resultat(etablie, [P], _)),
    selectchk(entite(e1, lion, p_1), G0, entite(e1, _, p_1), G),
    verifier(K, G, requete(q, type(v(x), tigre)), P, rejete(_)).
test(identifiant_non_atomique, [throws(error(graphe_invalide(_), _))]) :-
    graphe([entite(7, lion, p_1)], G), k(K), satisfaire(K, G, requete(q, type(v(x), lion)), _).
% V-V8 : le passage cité par un appui est celui de l'assertion
test(passage_de_l_appui_controle) :-
    graphe([entite(e1, lion, p_1)], G), k(K), satisfaire(K, G, requete(q, type(v(x), lion)), resultat(etablie, [P0], _)),
    P0 = preuve(I, V, R, S, [j(C, A, appui(X, E, _, L))], H),
    verifier(K, G, requete(q, type(v(x), lion)), preuve(I, V, R, S, [j(C, A, appui(X, E, p_ailleurs, L))], H), rejete(_)).
% V-V4 : une distinction vers une entité seulement possible ne distingue rien
test(distinction_vers_un_possible) :-
    graphe([entite(e1, homme, p_1), entite(e3, homme, p_2), mod(e3, possible), entite(e2, homme, p_3), coref(e2, e3),
            distinct(e1, e3)], G), k(K),
    Q = requete(q, et([type(v(x), homme), type(v(y), homme), distincts(v(x), v(y))])),
    satisfaire(K, G, Q, resultat(St, _, _)), St \== etablie, statut_reference(K, G, Q, St).
% D44 : requêtes non closes ou cycliques, options invalides, lots : des erreurs structurées, jamais un échec silencieux
test(requete_non_close, [throws(error(requete_mal_formee(r, [non_close]), _))]) :-
    graphe([entite(e1, lion, p_1)], G), k(K), satisfaire(K, G, requete(r, _), _).
test(contrainte_non_close, [throws(error(requete_mal_formee(r, [non_close]), _))]) :-
    graphe([entite(e1, lion, p_1)], G), k(K), satisfaire(K, G, requete(r, et([type(v(x), lion), distincts(v(x), _)])), _).
test(requete_cyclique, [throws(error(requete_mal_formee(r, [cyclique]), _))]) :-
    graphe([entite(e1, lion, p_1)], G), k(K), F = et([type(v(x), lion), F]), satisfaire(K, G, requete(r, F), _).
test(verificateur_requete_cyclique) :-
    graphe([entite(e1, lion, p_1)], G), k(K), satisfaire(K, G, requete(q, type(v(x), lion)), resultat(etablie, [P], _)),
    F = et([type(v(x), lion), F]), verifier(K, G, requete(q, F), P, rejete(_)).
test(variable_non_atomique, [throws(error(requete_mal_formee(r, [variable(v(1))]), _))]) :-
    graphe([entite(e1, lion, p_1)], G), k(K), satisfaire(K, G, requete(r, type(v(1), lion)), _).
test(options_invalides) :-
    graphe([entite(e1, lion, p_1)], G), k(K), Q = requete(q, type(v(x), lion)),
    forall(member(O, [[budget(abc)], [budget(_)], [budget(0)], [budget(-3)], [temps(abc)], [temps(0)], options]),
           catch(( satisfaire(K, G, Q, O, _), fail ), error(options_invalides(_), _), true)).
test(nom_non_atomique, [throws(error(graphe_invalide(_), _))]) :-
    graphe([entite(e1, homme, p_1), nom(n1, e1, f(x), p_2)], G), k(K), satisfaire(K, G, requete(q, nom(v(x), ['X'])), _).
test(lot_avec_un_intrus) :-
    graphe([entite(e1, lion, p_1)], G), k(K),
    satisfaire_lot(K, G, [requete(a, type(v(x), lion)), pas_une_requete], [a-resultat(etablie, _, _), inconnu-mal_formee(_)]).
% D44 : la liaison des contraintes se vérifie sans énumérer les sélections (2^30 ici)
test(liaison_sans_enumerer_les_selections) :-
    numlist(1, 30, Is), findall(ou([type(v(x), lion), type(v(x), tigre)]), member(_, Is), Os),
    append(Os, [distincts(v(x), v(y)), type(v(y), lion)], Fs),
    call_with_time_limit(5, requetes:bien_formee(requete(r, et(Fs)), Es)), Es == [],
    call_with_time_limit(5, requetes:bien_formee(requete(r, et([ou([type(v(x), lion), type(v(y), lion)]), distincts(v(x), v(y))])), Es2)),
    Es2 = [contrainte_non_liee(_)].
% audit final N4 : le vérificateur refuse une requête dont une contrainte porte sur des événements
test(verificateur_contrainte_sur_evenements) :-
    graphe([entite(e1, homme, p_1), evenement(v1, tenir, p_2), role(v1, agent, e1)], G), k(K),
    satisfaire(K, G, requete(q, et([evenement(v(e), tenir), evenement(v(f), tenir)])), resultat(etablie, [P0], _)),
    P0 = preuve(I, V, R, S, Js, H), S = [_, v(f)-F],
    P = preuve(I, V, R, S, [j([3], meme(v(e), v(f)), contrainte(egalite))|Js], H), F == v1,
    verifier(K, G, requete(q, et([evenement(v(e), tenir), evenement(v(f), tenir), meme(v(e), v(f))])), P, rejete(_)).
% D31 : une réfutation dit sa portée (la substitution) et ses fondements (sources, connaissance documentaire)
test(refutation_par_une_source_citee) :-
    graphe([entite(e1, homme, p_1), nom(n1, e1, pierre, p_2), neg(n1), enon(n1, cite(etude))], G), k(K),
    satisfaire(K, G, requete(q, nom(v(x), ['PIERRE'])), resultat(ecartee, [refutation(S, substitution, Fs)], complet)),
    S == [v(x)-e1], Fs == [cite(etude)].
test(refutation_documentaire_garde_sa_source) :-
    graphe([entite(e1, homme, p_1), nom(n1, e1, david, p_2), entite(e2, homme, p_3), nom(n2, e2, goliath, p_4)], G), k(K),
    satisfaire(K, G, requete(q, et([nom(v(x), ['DAVID']), nom(v(y), ['GOLIATH']), meme(v(x), v(y))])),
               resultat(ecartee, Els, complet)),
    forall(member(E, Els), ( E = refutation(_, substitution, Fs), memberchk(documentaire('source de test'), Fs) )).
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
