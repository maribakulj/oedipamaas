/*  Tests du noyau logique (docs/NOYAU.md) : requêtes, satisfaction, preuves et vérificateur, sur des graphes et des
    requêtes écrits à la main, sans lecteur de textes ni ressource : aucune erreur de langue ne peut y masquer une
    erreur de logique. Les variantes de docs/PLAN_V1.md (C6.4) sont reprises une à une.  */
:- use_module('../../oedipamaas/socle/requetes').
:- use_module('../../oedipamaas/socle/satisfaction').
:- use_module('../../oedipamaas/socle/verificateur').
:- use_module(connaissances_essai).
:- use_module(library(plunit)).
:- use_module(library(lists)).
:- use_module(library(apply)).
:- encoding(utf8).

k(connaissances_essai).

% --- Les graphes ---------------------------------------------------------------------------------------------------

% graphe(+Faits0, -Graphe) : chaque assertion reçoit les qualificatifs par défaut (positive, affirmée, représentée, de
% l'auteur), sauf ceux que donnent les marqueurs neg(A), mod(A, M), por(A, P), enon(A, Q) ; un passage par assertion
graphe(Fs0, G) :-
    exclude(marqueur, Fs0, Fs1), include(marqueur, Fs0, Ms),
    findall(A, ( member(F, Fs1), identifiant(F, A) ), As),
    findall(Q, ( member(A, As), qualificatif(A, Ms, Q) ), Qs),
    findall(passage(P, 0, 1), ( member(F, Fs1), passage_de(F, P) ), Ps0), sort(Ps0, Ps),
    append([[texte("x"), doc(fr, inconnu)], Fs1, Qs, Ps], G).
marqueur(neg(_)). marqueur(mod(_, _)). marqueur(por(_, _)). marqueur(enon(_, _)).
identifiant(entite(A, _, _), A). identifiant(nom(A, _, _, _), A). identifiant(propriete(A, _, _, _), A).
identifiant(evenement(A, _, _), A). identifiant(relation(A, _, _, _, _), A).
passage_de(F, P) :- identifiant(F, _), arg(_, F, P), atom(P), sub_atom(P, 0, 2, _, p_), !.
qualificatif(A, Ms, polarite(A, Po)) :- ( memberchk(neg(A), Ms) -> Po = neg ; Po = pos ).
qualificatif(A, Ms, modalite(A, M)) :- ( memberchk(mod(A, M), Ms) -> true ; M = affirme ).
qualificatif(A, Ms, portee(A, P)) :- ( memberchk(por(A, P), Ms) -> true ; P = represente ).
qualificatif(A, Ms, enonciateur(A, Q)) :- ( memberchk(enon(A, Q), Ms) -> true ; Q = auteur ).

% « une femme tient un enfant »
q_tenir(requete(tenir, et([type(v(x), femme), type(v(y), enfant), evenement(v(e), tenir),
                           role(v(e), agent, v(x)), role(v(e), patient, v(y))]))).

femme_enfant(Extra, G) :-
    append([entite(e1, femme, p_1), entite(e2, enfant, p_2)], Extra, Fs), graphe(Fs, G).
tient(Agent, Patient, Pred, Extra, G) :-
    femme_enfant([evenement(v1, Pred, p_3), role(v1, agent, Agent), role(v1, patient, Patient)|Extra], G).

resultat(G, Q, S) :- k(K), satisfaire(K, G, Q, resultat(S, _, _)).
resultat(G, Q, S, El) :- k(K), satisfaire(K, G, Q, resultat(S, El, _)).

% toutes les preuves d'un résultat établi sont acceptées par le vérificateur
preuves_acceptees(G, Q) :-
    k(K), satisfaire(K, G, Q, resultat(etablie, Ps, _)), Ps \== [],
    forall(member(P, Ps), verifier(K, G, Q, P, accepte)).
preuves_acceptees_toutes(G, Q) :-
    k(K), satisfaire(K, G, Q, resultat(_, Ps, _)), Ps = [preuve(_, _, _, _, _, _)|_],
    forall(member(P, Ps), verifier(K, G, Q, P, accepte)).

:- begin_tests(independance).

test(le_noyau_ne_charge_ni_iconclass_ni_wordnet) :-   % docs/NOYAU.md : l'indépendance du noyau
    forall(member(M, [iconclass, wordnet, ressources, arbre, libelles_lus, definitions_index]), \+ current_module(M)).
test(le_noyau_ne_nomme_aucun_de_ces_modules) :-
    forall(( member(F, ['requetes.pl', 'satisfaction.pl', 'satisfaction_reference.pl', 'verificateur.pl']),
             atom_concat('../../oedipamaas/socle/', F, C), read_file_to_string(C, S, []) ),
           forall(member(M, ["iconclass:", "wordnet:", "ressources:", "arbre:", "libelles_lus:", "definitions_index:"]),
                  \+ sub_string(S, _, _, _, M))).

:- end_tests(independance).

:- begin_tests(requetes).

test(bien_formee) :- q_tenir(Q), bien_formee(Q, []).
test(variable_seulement_dans_une_contrainte) :-
    bien_formee(requete(r, et([type(v(x), femme), distincts(v(x), v(y))])), Es), memberchk(variable_sans_atome(v(y)), Es).
test(ou_a_une_branche) :- bien_formee(requete(r, ou([type(v(x), femme)])), Es), Es = [ou_a_une_branche(_)].
test(role_inconnu) :- bien_formee(requete(r, et([evenement(v(e), tenir), role(v(e), porteur, v(x)), type(v(x), f)])), Es),
    memberchk(role_inconnu(porteur), Es).
test(deux_sortes) :- bien_formee(requete(r, et([evenement(v(e), tenir), type(v(e), femme)])), Es),
    memberchk(deux_sortes(v(e)), Es).
test(atomes_et_chemins) :-
    atomes(et([type(v(x), a), ou([type(v(x), b), nom(v(x), ['C'])])]), As),
    As == [[1]-type(v(x), a), [2, 1]-type(v(x), b), [2, 2]-nom(v(x), ['C'])].
test(mal_formee_refusee, [throws(error(requete_mal_formee(r, _), _))]) :-
    k(K), satisfaire(K, [], requete(r, ou([type(v(x), a)])), _).

:- end_tests(requetes).

:- begin_tests(variantes).          % docs/PLAN_V1.md, C6.4 : « une femme tient un enfant »

test(dite_simplement) :-
    tient(e1, e2, tenir, [], G), q_tenir(Q), resultat(G, Q, etablie, [P]),
    P = preuve(tenir, _, figuration, S, _, []), S == [v(e)-v1, v(x)-e1, v(y)-e2], preuves_acceptees(G, Q).
test(paraphrase_par_la_hierarchie) :-          % « une mère berce son nourrisson » (bercer sous tenir dans K)
    graphe([entite(e1, mere, p_1), entite(e2, nourrisson, p_2), evenement(v1, bercer, p_3),
            role(v1, agent, e1), role(v1, patient, e2)], G),
    q_tenir(Q), resultat(G, Q, etablie), preuves_acceptees(G, Q).
test(roles_inverses) :- tient(e2, e1, tenir, [], G), q_tenir(Q), resultat(G, Q, inconnue).
test(autre_relation) :- tient(e1, e2, regarder, [], G), q_tenir(Q), resultat(G, Q, inconnue).
test(modalite_possible) :-
    tient(e1, e2, tenir, [mod(v1, possible)], G), q_tenir(Q), resultat(G, Q, inconnue, [partiel(Sat, Manq)]),
    memberchk([1]-type(v(x), femme), Sat), memberchk([3]-evenement(v(e), tenir), Manq).
% Attendu « ecartee » jusqu'à la version 0.2 : l'événement nié était lu comme « v1 n'est pas un tenir », et la
% substitution e = v1 réfutait la requête ; cette lecture répartit la négation d'une description sur ses atomes et
% écarte aussi « David décapite Goliath » de « Goliath ne décapite pas David » (journal, D23). La version 0.3 ne nie
% que le prédicat d'un autre événement présent qui a les mêmes rôles : ici il n'y en a pas, et la réfutation, juste
% dans ce cas, n'est plus dérivée : une perte dans le sens sûr (D41).
test(negation) :- tient(e1, e2, tenir, [neg(v1)], G), q_tenir(Q), resultat(G, Q, inconnue).
test(coprésence_seule) :- femme_enfant([], G), q_tenir(Q), resultat(G, Q, inconnue).
test(hors_de_l_image) :-
    tient(e1, e2, tenir, [por(e1, histoire), por(e2, histoire), por(v1, histoire)], G), q_tenir(Q),
    resultat(G, Q, inconnue).
test(deux_scenes) :-                           % « un lion attaque un homme ; plus loin, l'homme terrasse le lion »
    graphe([entite(e1, lion, p_1), entite(e2, homme, p_2), evenement(v1, attaquer, p_3),
            role(v1, agent, e1), role(v1, patient, e2), evenement(v2, terrasser, p_4),
            role(v2, agent, e2), role(v2, patient, e1)], G),
    Q = requete(attaque, et([type(v(x), homme), type(v(y), lion), evenement(v(e), attaquer),
                             role(v(e), agent, v(x)), role(v(e), patient, v(y))])),
    resultat(G, Q, etablie, [preuve(_, _, _, S, _, _)]), memberchk(v(e)-v2, S), preuves_acceptees(G, Q).
test(sources_contradictoires) :-               % la notice nomme Pierre ; une étude le nie
    graphe([entite(e1, homme, p_1), nom(n1, e1, pierre, p_2), nom(n2, e1, pierre, p_3), neg(n2), enon(n2, cite(etude))], G),
    resultat(G, requete(pierre, et([type(v(x), homme), nom(v(x), ['PIERRE'])])), contradictoire).
test(titre_seul) :-
    tient(e1, e2, tenir, [mod(e1, titre), mod(e2, titre), mod(v1, titre)], G), q_tenir(Q), resultat(G, Q, inconnue).

:- end_tests(variantes).

q_decapite(requete(david, et([nom(v(x), ['DAVID']), nom(v(y), ['GOLIATH']), distincts(v(x), v(y)),
                              evenement(v(e), decapiter), role(v(e), agent, v(x)), role(v(e), patient, v(y))]))).
david(A, P, G) :-
    graphe([entite(e1, homme, p_1), nom(n1, e1, david, p_2), entite(e2, homme, p_3), nom(n2, e2, goliath, p_4),
            evenement(v1, decapiter, p_5), role(v1, agent, A), role(v1, patient, P)], G).
q_regarde(D, requete(regarde, et([type(v(x), homme), type(v(y), homme), evenement(v(e), regarder),
                                  role(v(e), agent, v(x)), role(v(e), patient, v(y))|D]))).
soi_meme(G) :- graphe([entite(e1, homme, p_1), evenement(v1, regarder, p_2), role(v1, agent, e1), role(v1, patient, e1)], G).

:- begin_tests(identites).

test(coreference) :-                           % « un homme… le saint… Jérôme »
    graphe([entite(e1, homme, p_1), entite(e2, saint, p_2), coref(e1, e2), nom(n1, e2, jerome, p_3)], G),
    Q = requete(jerome, et([type(v(x), homme), nom(v(x), ['JEROME'])])),
    resultat(G, Q, etablie, [preuve(_, _, _, S, _, _)]), S == [v(x)-e1], preuves_acceptees(G, Q).
test(alias) :-
    graphe([entite(e1, saint, p_1), nom(n1, e1, hieronymus, p_2)], G),
    Q = requete(jerome, nom(v(x), ['JEROME'])), resultat(G, Q, etablie), preuves_acceptees(G, Q).
test(sans_coreference_pas_de_fusion) :-        % seule une fusion indue des deux entités satisferait la requête
    graphe([entite(e1, lion, p_1), entite(e2, homme, p_2), nom(n1, e2, jerome, p_3)], G),
    Q = requete(jerome, et([type(v(x), lion), nom(v(x), ['JEROME'])])), resultat(G, Q, inconnue),
    graphe([entite(e1, lion, p_1), entite(e2, homme, p_2), nom(n1, e2, jerome, p_3), coref(e1, e2)], G2),
    resultat(G2, Q, etablie).
test(david_et_goliath) :- david(e1, e2, G), q_decapite(Q), resultat(G, Q, etablie), preuves_acceptees(G, Q).
test(goliath_et_david) :- david(e2, e1, G), q_decapite(Q), resultat(G, Q, inconnue).
test(distinction_documentaire_dans_la_preuve) :-    % K documente David et Goliath comme deux individus
    david(e1, e2, G), q_decapite(Q), resultat(G, Q, etablie, [preuve(_, _, _, _, Js, [])]),
    memberchk(j(_, distincts(_, _), contrainte(documentaire('DAVID', 'GOLIATH', _))), Js).
test(distinction_supposee_conditionnelle) :-        % des noms différents, sans alias : une hypothèse, jamais une preuve
    graphe([entite(e1, homme, p_1), nom(n1, e1, abel, p_2), entite(e2, homme, p_3), nom(n2, e2, cain, p_4)], G),
    Q = requete(ac, et([nom(v(x), ['ABEL']), nom(v(y), ['CAIN']), distincts(v(x), v(y))])),
    resultat(G, Q, etablie_sous_hypotheses, [preuve(_, _, _, _, _, [distinction_supposee(v(x), v(y), ['ABEL'], ['CAIN'])])]),
    preuves_acceptees_toutes(G, Q).
test(deux_mentions_identite_inconnue) :-            % deux identifiants, sans nom ni distinction : identité inconnue
    graphe([entite(e1, homme, p_1), entite(e2, homme, p_2)], G),
    resultat(G, requete(d, et([type(v(x), homme), type(v(y), homme), distincts(v(x), v(y))])), inconnue).
test(distinction_etablie_par_le_texte) :-
    graphe([entite(e1, homme, p_1), entite(e2, homme, p_2), distinct(e1, e2)], G),
    Q = requete(d, et([type(v(x), homme), type(v(y), homme), distincts(v(x), v(y))])),
    resultat(G, Q, etablie), preuves_acceptees(G, Q).
test(meme_referent_permis) :-                  % « un homme se regarde » : rien n'interdit x = y
    soi_meme(G), q_regarde([], Q), resultat(G, Q, etablie, [preuve(_, _, _, S, _, _)]),
    memberchk(v(x)-e1, S), memberchk(v(y)-e1, S), preuves_acceptees(G, Q).
test(distincts_explicites) :- soi_meme(G), q_regarde([distincts(v(x), v(y))], Q), resultat(G, Q, inconnue).
test(meme_explicite) :-
    graphe([entite(e1, homme, p_1), entite(e2, homme, p_2), evenement(v1, regarder, p_3), role(v1, agent, e1),
            role(v1, patient, e2)], G),
    q_regarde([meme(v(x), v(y))], Q), resultat(G, Q, inconnue).

:- end_tests(identites).

:- begin_tests(formules).

test(union) :-
    graphe([entite(e1, lionne, p_1)], G), Q = requete(fauve, ou([type(v(x), tigre), type(v(x), lion)])),
    resultat(G, Q, etablie, [preuve(_, _, _, _, [j(C, _, appui(e1, e1, p_1, chemin(lionne, [lionne, lion])))], [])]),
    C == [2], preuves_acceptees(G, Q).
test(jamais_vers_le_bas) :-                     % « un animal » ne dit pas « un lion »
    graphe([entite(e1, animal, p_1)], G), resultat(G, requete(lion, type(v(x), lion)), inconnue).
test(propriete_du_meme_referent) :-
    graphe([entite(e1, homme, p_1), propriete(q1, e1, mort, p_2), entite(e2, oiseau, p_3)], G),
    resultat(G, requete(oiseau_mort, et([type(v(x), oiseau), propriete(v(x), mort)])), inconnue),
    resultat(G, requete(homme_mort, et([type(v(x), homme), propriete(v(x), mort)])), etablie).
test(relation_orientee) :-
    graphe([entite(e1, femme, p_1), entite(e2, enfant, p_2), relation(r1, e2, avec, e1, p_3)], G),
    resultat(G, requete(f_avec_e, et([type(v(x), femme), type(v(y), enfant), relation(v(x), avec, v(y))])), inconnue),
    resultat(G, requete(e_avec_f, et([type(v(x), femme), type(v(y), enfant), relation(v(y), avec, v(x))])), etablie).
test(nombre) :-
    graphe([entite(e1, ange, p_1), nombre(e1, 3)], G),
    Q3 = requete(trois, et([type(v(x), ange), nombre(v(x), 3)])), resultat(G, Q3, etablie), preuves_acceptees(G, Q3),
    resultat(G, requete(deux, et([type(v(x), ange), nombre(v(x), 2)])), ecartee).    % le texte dit trois
test(genre_de_l_oeuvre) :-
    graphe([entite(e1, portrait_en_buste, p_1), por(e1, oeuvre)], G),
    Q = requete(portrait, genre(portrait)), resultat(G, Q, etablie, [preuve(_, _, classement, [], _, [])]),
    preuves_acceptees(G, Q).
test(portrait_dans_la_scene_n_est_pas_le_genre) :-
    graphe([entite(e1, portrait, p_1)], G), resultat(G, requete(portrait, genre(portrait)), inconnue).
test(plusieurs_referents) :-                    % une notation portée par deux référents : deux preuves
    graphe([entite(e1, lion, p_1), entite(e2, lion, p_2)], G),
    Q = requete(lion, type(v(x), lion)), resultat(G, Q, etablie, Ps), length(Ps, 2), preuves_acceptees(G, Q).
test(budget_epuise_aucune_conclusion_negative) :-   % le budget épuisé avant une solution : incomplet, jamais écartée
    findall(entite(F, femme, p_1), ( between(1, 30, I), atom_concat(f, I, F) ), Fs),
    append(Fs, [entite(c1, enfant, p_2), neg(c1)], X), graphe(X, G), k(K),
    satisfaire(K, G, requete(fe, et([type(v(x), femme), type(v(y), enfant)])), [budget(1)], resultat(St, _, incomplet)),
    St == incomplet.
test(budget_epuise_apres_une_solution) :-           % ce qui a été trouvé de certifiable reste vrai
    findall(entite(F, femme, p_1), ( between(1, 30, I), atom_concat(f, I, F) ), Fs),
    graphe(Fs, G), k(K),
    satisfaire(K, G, requete(f, type(v(x), femme)), [budget(1)], resultat(etablie, [_|_], incomplet)).
test(ordre_de_liaison_rapide) :-                % 200 entités, un nom rare : le nom est lié d'abord
    findall(entite(E, homme, p_1), ( between(1, 200, I), atom_concat(h, I, E) ), Hs),
    append(Hs, [nom(n1, h77, jerome, p_2), evenement(v1, prier, p_3), role(v1, agent, h77)], X), graphe(X, G), k(K),
    statistics(cputime, T0),
    satisfaire(K, G, requete(r, et([type(v(x), homme), evenement(v(e), prier), role(v(e), agent, v(x)),
                                    nom(v(x), ['JEROME'])])), resultat(etablie, [_], complet)),
    statistics(cputime, T1), T1 - T0 < 2.0.
test(hierarchie_cyclique) :-                   % le noyau termine, et le vérificateur aussi
    graphe([entite(e1, cycle_a, p_1)], G),
    Q = requete(c, type(v(x), cycle_b)), resultat(G, Q, etablie), preuves_acceptees(G, Q),
    resultat(G, requete(d, type(v(x), ailleurs)), inconnue).
test(isolation_des_documents) :-
    graphe([entite(e1, lion, p_1)], G1), graphe([entite(e1, tigre, p_1)], G2),
    resultat(G1, requete(l, type(v(x), lion)), etablie),
    resultat(G2, requete(l, type(v(x), lion)), inconnue),
    resultat(G1, requete(l, type(v(x), lion)), etablie).

:- end_tests(formules).

% --- Le banc de mutations (docs/NOYAU.md, § 6) : toute preuve altérée est rejetée --------------------------------------

cas(G, Q) :- tient(e1, e2, tenir, [], G), q_tenir(Q).
cas(G, Q) :- graphe([entite(e1, mere, p_1), entite(e2, nourrisson, p_2), evenement(v1, bercer, p_3),
                     role(v1, agent, e1), role(v1, patient, e2)], G), q_tenir(Q).
cas(G, Q) :- david(e1, e2, G), q_decapite(Q).
cas(G, Q) :- graphe([entite(e1, homme, p_1), nom(n1, e1, abel, p_2), entite(e2, homme, p_3), nom(n2, e2, cain, p_4)], G),
             Q = requete(ac, et([nom(v(x), ['ABEL']), nom(v(y), ['CAIN']), distincts(v(x), v(y))])).
cas(G, Q) :- graphe([entite(e1, homme, p_1), entite(e2, homme, p_2), distinct(e1, e2)], G),
             Q = requete(d, et([type(v(x), homme), type(v(y), homme), distincts(v(x), v(y))])).
cas(G, Q) :- graphe([entite(e1, portrait_en_buste, p_1), por(e1, oeuvre)], G), Q = requete(portrait, genre(portrait)).
cas(G, Q) :- graphe([entite(e1, homme, p_1), entite(e2, saint, p_2), coref(e1, e2), nom(n1, e2, jerome, p_3)], G),
             Q = requete(jerome, et([type(v(x), homme), nom(v(x), ['JEROME'])])).
cas(G, Q) :- graphe([entite(e1, lionne, p_1)], G), Q = requete(fauve, ou([type(v(x), tigre), type(v(x), lion)])).
cas(G, Q) :- graphe([entite(e1, ange, p_1), nombre(e1, 3), entite(e2, ange, p_2)], G),
             Q = requete(trois, et([type(v(x), ange), nombre(v(x), 3)])).
cas(G, Q) :- graphe([entite(e1, fauve, p_1)], G), Q = requete(felin, type(v(x), felin)).   % fauve → félin, hors inclusion
cas(G, Q) :- graphe([entite(e1, homme, p_1), entite(e2, saint, p_2), coref(e1, e2)], G),
             Q = requete(meme, et([type(v(x), homme), type(v(y), saint), meme(v(x), v(y))])).
cas(G, Q) :- graphe([entite(e1, ange, p_1), entite(e2, ange, p_2), coref(e1, e2), nombre(e2, 3)], G),
             Q = requete(trois_par_coreference, et([type(v(x), ange), nombre(v(x), 3)])).

% mutation(+Graphe, +Preuve, -Graphe2, -Preuve2, -Nom)
mutation(G, preuve(I, V, R, S, Js, H), G, preuve(I, V, R, S, Js1, H), retire(C)) :- select(j(C, _, _), Js, Js1).
mutation(G, preuve(I, V, R, S, Js, H), G, preuve(I, V, R, S, Js1, H), inexistant(C)) :-
    select(j(C, A, appui(_, E, P, L)), Js, j(C, A, appui(x_inexistant, E, P, L)), Js1).
% les altérations du graphe : l'empreinte de la preuve est recalculée sur le graphe altéré (une preuve forgée pour
% lui), pour que ce soit le contrôle visé qui la rejette, et non celui de l'empreinte
mutation(G, P, G2, P2, Nom) :-
    P = preuve(_, _, _, _, Js, _), member(j(_, _, appui(X0, E, _, _)), Js), ( X0 = role(X, _, _) -> true ; X = X0 ),
    alteration_du_graphe(G, X, E, G2, Nom), reforger(P, G2, P2).
alteration_du_graphe(G, X, _, G2, nie(X)) :- selectchk(polarite(X, pos), G, polarite(X, neg), G2).
alteration_du_graphe(G, X, _, G2, citee(X)) :- selectchk(enonciateur(X, auteur), G, enonciateur(X, cite(autre)), G2).
alteration_du_graphe(G, X, _, G2, possible(X)) :- selectchk(modalite(X, affirme), G, modalite(X, possible), G2).
alteration_du_graphe(G, X, _, G2, hors_image(X)) :- selectchk(portee(X, represente), G, portee(X, histoire), G2).
alteration_du_graphe(G, X, E, G2, porteur_cite(E)) :-
    E \== X, selectchk(enonciateur(E, auteur), G, enonciateur(E, cite(autre)), G2).
alteration_du_graphe(G, X, E, G2, porteur_possible(E)) :-
    E \== X, selectchk(modalite(E, affirme), G, modalite(E, possible), G2).
alteration_du_graphe(G, X, _, G2, negation_ajoutee(X)) :-              % un double nié de l'assertion, d'une autre source
    member(F, G), F =.. [P, X|As], memberchk(P, [entite, nom, propriete, evenement, relation]),
    atom_concat(X, '_nie', Y), F2 =.. [P, Y|As], memberchk(portee(X, Po), G),
    findall(role(Y, Ro, E), memberchk(role(X, Ro, E), G), Rs),          % un événement nié garde ses participants
    append([G, [F2|Rs], [polarite(Y, neg), modalite(Y, affirme), portee(Y, Po), enonciateur(Y, cite(etude))]], G2).
alteration_du_graphe(G, X, _, G2, dans_une_alternative(X)) :-
    member(F, G), F =.. [P, X|As], memberchk(P, [entite, nom, propriete, evenement, relation]),
    atom_concat(X, '_autre', Y), F2 =.. [P, Y|As],
    append(G, [F2, polarite(Y, pos), modalite(Y, affirme), portee(Y, represente), enonciateur(Y, auteur),
               alternative(g_mut, [X, Y])], G2).
% les altérations qui visent une contrainte : un autre nombre, un nombre seulement possible ou cité, une distinction
% dans une classe dite une
mutation(G, P, G2, P2, Nom) :-
    P = preuve(_, _, _, _, Js, _), member(j(_, nombre(_, N), contrainte(nombre(E))), Js),
    member(Alt-Nom, [ajout(nombre(E, N1))-autre_nombre(E), modalite(E, possible)-nombre_possible(E),
                     enonciateur(E, cite(autre))-nombre_cite(E)]),
    N1 is N + 1,
    (   Alt = ajout(F) -> append(G, [F], G2)
    ;   Alt =.. [Q, _, V], Q0 =.. [Q, E, _], selectchk(Q0, G, Alt, G2), Q0 \== Alt, V \== x
    ),
    reforger(P, G2, P2).
% « pas de T » ajouté, pour le type demandé lui-même (et non pour le mot du texte)
mutation(G, P, G2, P2, type_demande_nie(T)) :-
    P = preuve(_, _, _, _, Js, _), member(j(_, type(_, T), appui(_, _, Pa, _)), Js), atom(T),
    append(G, [entite(t_nie, T, Pa), polarite(t_nie, neg), modalite(t_nie, affirme), portee(t_nie, represente),
               enonciateur(t_nie, cite(etude))], G2),
    reforger(P, G2, P2).
mutation(G, P, G2, P2, distinction_dans_la_classe(E1, E2)) :-
    P = preuve(_, _, _, _, Js, _), member(j(_, meme(_, _), contrainte(egalite)), Js), member(coref(E1, E2), G),
    append(G, [distinct(E1, E2)], G2), reforger(P, G2, P2).
reforger(preuve(I, [Vn, Vk, _], R, S, Js, H), G2, preuve(I, [Vn, Vk, graphe(H2)], R, S, Js, H)) :-
    satisfaction:empreinte(G2, H2).
mutation(G, preuve(I, V, R, S, Js, H), G, preuve(I, V, R, S, Js, [distinction_supposee(v(x), v(y), ['A'], ['B'])|H]),
         hypothese_ajoutee).
mutation(G, preuve(I, V, R, S, Js, H), G, preuve(I, V, R, S1, Js, H), sigma(Va)) :-
    select(Va-Val, S, Va-Autre, S1), member(Autre, [e1, e2, v1, x_ailleurs]), Autre \== Val.
mutation(G, preuve(I, V, R, S, Js, H), G, preuve(I, V, R, [v(etrangere)-e1|S], Js, H), variable_etrangere).
mutation(G, preuve(I, V, R, [Va-X|S], Js, H), G, preuve(I, V, R, [Va-X, Va-autre|S], Js, H), seconde_liaison).
mutation(G, preuve(I, V, R, S, Js, H), G, preuve(I, V, R, S, Js1, H), role(C)) :-
    select(j(C, role(E, agent, X), Ap), Js, j(C, role(E, patient, X), Ap), Js1).
mutation(G, preuve(I, V, R, S, Js, H), G, preuve(I, V, R, S, Js1, H), lien(C)) :-
    select(j(C, A, appui(X, E, P, chemin(W, [W0|Ch]))), Js, j(C, A, appui(X, E, P, chemin(W, [W0, invente|Ch]))), Js1).
mutation(G, preuve(I, V, R, S, Js, H), G, preuve(I, V, R, S, Js1, H), branche(C)) :-
    select(j(C, A, Ap), Js, j(C1, A, Ap), Js1), C \== [], last(C, N), N1 is N + 1, append(C0, [N], C), append(C0, [N1], C1).
mutation(G, preuve(I, [_|Vs], R, S, Js, H), G, preuve(I, [noyau('noyau 0.0')|Vs], R, S, Js, H), version).
mutation(G, preuve(I, [A, B, _], R, S, Js, H), G, preuve(I, [A, B, graphe(empreinte_fausse)], R, S, Js, H), empreinte).
mutation(G, preuve(I, V, R, S, Js, H), G, preuve(I, V, R2, S, Js, H), regime) :-
    ( R == figuration -> R2 = classement ; R2 = figuration ).
mutation(G, preuve(I, V, R, S, Js, H), G, preuve(I, V, R, S, [parasite|Js], H), terme_parasite).
mutation(G, preuve(I, V, R, S, Js, [_|H]), G, preuve(I, V, R, S, Js, H), hypothese_retiree).

:- begin_tests(verificateur).

test(preuves_du_moteur_acceptees) :- forall(cas(G, Q), preuves_acceptees_toutes(G, Q)).
test(toute_mutation_rejetee) :-
    findall(G-Nom, ( cas(G, Q), k(K), satisfaire(K, G, Q, resultat(St, Ps, _)), memberchk(St, [etablie, etablie_sous_hypotheses]), member(P, Ps),
                   mutation(G, P, G2, P2, Nom), P2-G2 \== P-G,
                   \+ verifier(K, G2, Q, P2, rejete(_)) ), Acceptees),
    assertion(Acceptees == []).
test(banc_de_mutations_non_vide) :-
    aggregate_all(count, ( cas(G, Q), k(K), satisfaire(K, G, Q, resultat(St, Ps, _)), memberchk(St, [etablie, etablie_sous_hypotheses]), member(P, Ps),
                           mutation(G, P, _, _, _) ), N),
    N >= 40.
test(preuve_rejetee_si_le_graphe_nie_aussi) :-    % une négation ajoutée au graphe, hors de l'appui cité
    F0 = [entite(e1, homme, p_1), nom(n1, e1, pierre, p_2)],
    graphe(F0, G), k(K),
    Q = requete(pierre, et([type(v(x), homme), nom(v(x), ['PIERRE'])])),
    satisfaire(K, G, Q, resultat(etablie, [P], _)),
    append(F0, [nom(n2, e1, pierre, p_3), neg(n2), enon(n2, cite(etude))], F3), graphe(F3, G3),
    verifier(K, G3, Q, P, rejete(_)),
    satisfaire(K, G3, Q, resultat(contradictoire, [contradictoire(_, documentaire, _)], _)).
test(sigma_sur_un_membre_et_non_le_representant) :-
    graphe([entite(e1, homme, p_1), entite(e2, saint, p_2), coref(e1, e2), nom(n1, e2, jerome, p_3)], G), k(K),
    Q = requete(jerome, et([type(v(x), homme), nom(v(x), ['JEROME'])])),
    satisfaire(K, G, Q, resultat(etablie, [preuve(I, V, R, [v(x)-e1], Js, H)], _)),
    verifier(K, G, Q, preuve(I, V, R, [v(x)-e2], Js, H), rejete(_)).
test(preuve_d_une_autre_requete_rejetee) :-
    cas(G, Q), !, k(K), satisfaire(K, G, Q, resultat(etablie, [P|_], _)),
    verifier(K, G, requete(autre, type(v(x), femme)), P, rejete(_)).

:- end_tests(verificateur).
