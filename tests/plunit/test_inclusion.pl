/*  Tests de l'inclusion des requêtes (inclusion.pl ; docs/NOYAU.md, § 8), sans aucune donnée : les attendus sont
    écrits d'après la définition de l'inclusion (Q1 ⊆ Q2 : tout modèle de Q1 établit Q2).  */
:- use_module('../../oedipamaas/socle/inclusion').
:- use_module('../../oedipamaas/socle/requetes').
:- use_module(connaissances_essai).
:- use_module('../../oedipamaas/socle/satisfaction').
:- consult(test_noyau_semantique).          % graphe_cas/2
:- use_module(library(plunit)).
:- use_module(library(random)).
:- encoding(utf8).

k(connaissances_essai).
cmp(Q1, Q2, V) :- k(K), comparer(K, aucune, requete(a, Q1), requete(b, Q2), V).

:- begin_tests(inclusion).

test(reflexive_simple) :- cmp(type(v(x), lion), type(v(x), lion), equivalentes).
test(reflexive_propriete_seule) :-            % une requête faite d'une seule propriété s'implique elle-même
    cmp(propriete(v(x), mort), propriete(v(x), mort), equivalentes).
test(reflexive_role_seul) :- cmp(role(v(e), agent, v(x)), role(v(e), agent, v(x)), equivalentes).
test(hyperonymie) :- cmp(type(v(x), lionne), type(v(x), lion), incluse).          % une lionne est un lion
test(noms_alternatifs_ne_sont_pas_une_conjonction) :-
    cmp(nom(v(x), ['DAVID']), nom(v(x), ['DAVID', 'GOLIATH']), incluse),
    cmp(nom(v(x), ['DAVID', 'GOLIATH']), nom(v(x), ['DAVID']), contient).
test(distinction_exigee) :-                    % deux hommes, l'identité libre, n'impliquent pas deux hommes distincts
    cmp(et([type(v(x), homme), type(v(y), homme)]),
        et([type(v(x), homme), type(v(y), homme), distincts(v(x), v(y))]), contient).
% Attendu « equivalentes » jusqu'au cycle 6 ; `meme` a quatre valeurs (D29) : dans un modèle où la classe est dite
% une et deux (un jumeau coréférent et distinct), « x homme et saint » reste établie et `meme(x, y)` est contradictoire.
% L'inclusion n'est que dans un sens (audit final, B1).
test(identite) :-
    cmp(et([type(v(x), homme), type(v(y), saint), meme(v(x), v(y))]), et([type(v(x), homme), type(v(x), saint)]),
        incluse).
test(union) :- cmp(type(v(x), lionne), ou([type(v(x), lion), type(v(x), tigre)]), incluse).
test(relation_orientee) :-
    cmp(relation(v(x), avec, v(y)), relation(v(y), avec, v(x)), equivalentes),   % le nom des variables est libre
    cmp(et([type(v(x), femme), type(v(y), enfant), relation(v(x), avec, v(y))]),
        et([type(v(x), femme), type(v(y), enfant), relation(v(y), avec, v(x))]), incomparables(_, _)).
test(contre_exemple_donne) :-
    k(K), inclusion(K, aucune, requete(a, type(v(x), animal)), requete(b, type(v(x), lion)), non(As)),
    As == [type(v(x), animal)].
test(hors_du_fragment_indetermine) :-
    cmp(et([evenement(v(e), tenir), evenement(v(e), bercer)]), evenement(v(e), tenir), indetermine(_)).
test(mal_formee_indetermine) :- cmp(ou([type(v(x), a)]), type(v(x), a), indetermine(requete_mal_formee)).
test(reflexive_sur_des_requetes_tirees) :-     % la réflexivité, sur des requêtes tirées au hasard
    set_random(seed(11)),
    forall(between(1, 200, _), ( requete_tiree(F), ( cmp(F, F, V), memberchk(V, [equivalentes, indetermine(_)]) ) )).

% --- Contre-exemples de l'audit du comparateur (journal, D37 à D40), attendus d'après la définition seule ------------
test(distinction_documentaire_non_universelle) :-
    % la même classe peut porter DAVID et GOLIATH : Q1 y est établie, pas Q2 (x et y sur une seule classe)
    Q1 = et([nom(v(x), ['DAVID']), nom(v(y), ['GOLIATH'])]), Q2 = et([nom(v(x), ['DAVID']), nom(v(y), ['GOLIATH']), distincts(v(x), v(y))]),
    temoin([entite(e1, homme, p_1), nom(n1, e1, david, p_2), nom(n2, e1, goliath, p_3)], Q1, etablie),
    temoin([entite(e1, homme, p_1), nom(n1, e1, david, p_2), nom(n2, e1, goliath, p_3)], Q2, inconnue),
    cmp(Q1, Q2, V), V = indetermine(_).
test(hypothese_n_est_pas_une_inclusion) :-
    cmp(et([nom(v(x), ['ABEL']), nom(v(y), ['CAIN'])]), et([nom(v(x), ['ABEL']), nom(v(y), ['CAIN']), distincts(v(x), v(y))]),
        contient).
test(normalisation_non_equivalente) :-
    k(K), Q1 = requete(a, et([evenement(v(e), tenir), role(v(e), agent, v(x))])),
    Q2 = requete(b, et([evenement(v(e), tenir), role(v(e), patient, v(x))])),
    comparer(K, aucune, Q1, Q2, incomparables(_, _)),
    comparer(K, user:participant_unique, Q1, Q2, indetermine(normalisation_non_equivalente)),
    comparer(K, user:echoue, Q1, Q2, indetermine(normalisation_echouee)).
test(lexicalisation_ne_transmet_pas_la_negation) :-
    % fauve → félin n'est pas une inclusion : « un fauve ; pas de félin » établit Q1, pas Q2
    temoin([entite(e1, fauve, p_1), entite(e2, felin, p_2), neg(e2)], type(v(x), fauve), etablie),
    temoin([entite(e1, fauve, p_1), entite(e2, felin, p_2), neg(e2)], type(v(x), felin), contradictoire),
    k(K), inclusion(K, aucune, requete(a, type(v(x), fauve)), requete(b, type(v(x), felin)), non(negation(_, felin))).
test(le_type_n_est_pas_le_mot) :-             % le mot « lionne » a le sens 1001 ; le type lionne, non
    cmp(type(v(x), lionne), type(v(x), 1000), incomparables(_, _)),
    cmp(type(v(x), 1001), type(v(x), 1000), incluse).
test(types_entiers_reflexifs) :- cmp(type(v(x), 1000), type(v(x), 1000), equivalentes).
test(insatisfaisable_indeterminee) :-
    cmp(et([type(v(x), homme), type(v(y), homme), meme(v(x), v(y)), distincts(v(x), v(y))]), type(v(x), homme), V),
    V = indetermine(cas_non_etabli(_)).
test(variable_non_atomique_mal_formee) :-
    cmp(et([type(v(1), lion), type(v('1'), tigre)]), et([type(v(a), lion), type(v(a), tigre)]), indetermine(requete_mal_formee)).
test(alias_en_chaine) :- cmp(nom(v(x), ['JEROME']), nom(v(x), ['GIROLAMO']), equivalentes).
test(liste_de_noms_et_disjonction) :-
    cmp(nom(v(x), ['DAVID', 'GOLIATH']), ou([nom(v(x), ['DAVID']), nom(v(x), ['GOLIATH'])]), equivalentes).
test(transitivite_simple) :-
    cmp(type(v(x), lionne), type(v(x), lion), incluse), cmp(type(v(x), lion), type(v(x), felin), incluse),
    cmp(type(v(x), lionne), type(v(x), felin), incluse).

test(meme_ne_transmet_pas_sans_meme_dans_q1) :-   % audit final B1
    Q1 = type(v(x), saint), Q2 = et([type(v(x), saint), type(v(y), homme), meme(v(x), v(y))]),
    temoin([entite(e1, saint, p_1), entite(e2, saint, p_2), coref(e1, e2), distinct(e1, e2)], Q1, etablie),
    temoin([entite(e1, saint, p_1), entite(e2, saint, p_2), coref(e1, e2), distinct(e1, e2)], Q2, contradictoire),
    cmp(Q1, Q2, contient),
    % avec une coréférence de Q1 de chaque côté, l'identité se transmet (saint est sous homme dans K)
    cmp(et([type(v(x), saint), type(v(z), saint), meme(v(x), v(z))]), et([type(v(x), saint), type(v(y), homme), meme(v(x), v(y))]),
        equivalentes).

test(polysemie) :-                             % D30 : le lemme polysémique n'implique pas l'un de ses sens
    cmp(type(v(x), pomme), type(v(x), vegetal), incomparables(_, _)),
    cmp(type(v(x), 2001), type(v(x), vegetal), incluse).

:- end_tests(inclusion).

% un graphe-témoin, évalué par le moteur seul (graphe_cas de test_noyau_semantique)
temoin(Fs, F, Attendu) :- graphe_cas(Fs, G), k(K), satisfaire(K, G, requete(t, F), resultat(S, _, _)), S == Attendu.
% des normalisations pour le test : le participant unique devient aussi patient (non monotone) ; un échec
participant_unique(G0, G) :-
    findall(role(V, patient, E), ( member(role(V, agent, E), G0), \+ ( member(role(V, R, _), G0), R \== agent ) ), Rs),
    append(G0, Rs, G1), sort(G1, G).
echoue(_, _) :- fail.

requete_tiree(F) :- between(1, 200, _), formule(2, F), requetes:bien_formee(requete(r, F), []), !.
formule(P, F) :-
    random(X),
    (   P > 0, X < 0.3 -> random_between(2, 3, N), length(Fs, N), maplist(formule(P - 1), Fs), F = ou(Fs)
    ;   P > 0, X < 0.6 -> random_between(1, 3, N), length(Fs, N), maplist(formule(P - 1), Fs), F = et(Fs)
    ;   atome(F)
    ).
atome(A) :-
    random_member(X, [v(x), v(y)]), random_member(Y, [v(x), v(y)]), random_between(1, 8, I),
    (   I =:= 1 -> random_member(T, [lion, felin, homme]), A = type(X, T)
    ;   I =:= 2 -> random_member(Ks, [['DAVID'], ['DAVID', 'GOLIATH']]), A = nom(X, Ks)
    ;   I =:= 3 -> A = propriete(X, mort)
    ;   I =:= 4 -> A = evenement(v(e), tenir)
    ;   I =:= 5 -> A = role(v(e), agent, X)
    ;   I =:= 6 -> A = relation(X, avec, Y)
    ;   I =:= 7 -> A = distincts(X, Y)
    ;   A = genre(portrait)
    ).
