/*  Tests du codage (codage.pl), sans donnée : un index de requêtes compilées écrit ici, les K de test. Contre-exemples
    du 27/11 : la complétude perdue entre le noyau et le résultat ; l'index qui excluait les types entiers et ne fermait
    pas les alias ; la condition suffisante et la nécessaire confondues (une suffisante réfutée prise pour une notation
    réfutée).  */
:- use_module('../../oedipamaas/socle/codage').
:- use_module('../../oedipamaas/socle/requetes').
:- use_module(connaissances_essai).
:- use_module(connaissances_gen, []).          % appelé qualifié ; connaissances_essai est importé
:- use_module(library(plunit)).
:- use_module(library(lists)).
:- use_module(library(apply)).
:- use_module(library(random)).
:- encoding(utf8).

:- consult(test_noyau_semantique).          % graphe_cas/2
:- consult(generateur_noyau).               % graphe_aleatoire/1, requete_aleatoire/1

:- dynamic requetes_index:requete_compilee/8.

index_essai :-
    retractall(requetes_index:requete_compilee(_, _, _, _, _, _, _, _)),
    forall(entree(N, Su, Ne, St), assertz(requetes_index:requete_compilee(N, essai, classe, Su, Ne, St, [], f))),
    codage:reindexer.
entree('A', requete('A', type(v(x), lion)), aucune, compilee).
entree('B', requete('B', type(v(x), 1000)), aucune, compilee).                    % un type entier
entree('C', requete('C', nom(v(x), ['HIERONYMUS'])), aucune, compilee).           % par une chaîne d'alias
entree('D', requete('D', et([type(v(x), homme), nom(v(x), ['PIERRE'])])), requete('D', type(v(x), homme)), compilee).
entree('E', requete('E', role(v(e), agent, v(x))), aucune, partielle).            % sans atome lexical : « toujours »
entree('F', requete('F', type(v(x), tigre)), requete('F', type(v(x), felin)), compilee).
entree('G', requete('G', ou([type(v(x), lion)])), requete('G', type(v(x), lion)), compilee).   % suffisante mal formée

graphe_essai(G) :-
    graphe_cas([entite(e1, lionne, p_1), entite(e2, homme, p_2), nom(n1, e2, pierre, p_3), neg(n1),
                entite(e3, homme, p_4), nom(n2, e3, girolamo, p_5), evenement(v1, tenir, p_6), role(v1, agent, e3)], G).

coder_essai(Mode, Opts, R) :- graphe_essai(G), coder(essai, G, Mode, [k(connaissances_essai), normaliser(non)|Opts], R).

positifs(R, Ps) :-
    findall(N-S, ( member(code(N, S, _, _), R), memberchk(S, [etabli, etablissable, candidat, conditionnel]) ), Ps0),
    sort(Ps0, Ps).

:- begin_tests(codage, [setup(index_essai)]).

test(type_entier_trouve_par_l_index) :-
    coder_essai(indexe, [], R), memberchk(code('B', etablissable, _, annexe(complet, aucune)), R).
test(alias_en_chaine_trouve_par_l_index) :-
    coder_essai(indexe, [], R), memberchk(code('C', etablissable, _, _), R).
test(indexe_egal_exhaustif) :-
    coder_essai(indexe, [], Ri), coder_essai(exhaustif, [], Rx), positifs(Ri, Pi), positifs(Rx, Px), Pi == Px, Pi \== [].
test(suffisante_refutee_n_est_pas_la_notation_refutee) :-
    coder_essai(exhaustif, [], R), memberchk(code('D', S, _, annexe(_, Nec)), R),
    S == suffisante_ecartee, Nec == etablie.            % la nécessaire (un homme) est établie
test(necessaire_seule) :-                                % la suffisante (un tigre) est inconnue ; la nécessaire établie
    coder_essai(exhaustif, [], R), memberchk(code('F', sans_suffisante, [], annexe(complet, etablie)), R).
test(incomplet_garde_jusqu_a_la_sortie) :-
    coder_essai(exhaustif, [budget(1)], R),
    forall(member(code(_, S, _, annexe(C, _)), R), ( S == incomplet -> C == incomplet ; true )),
    once(member(code(_, _, _, annexe(incomplet, _)), R)).
test(mal_formee_signalee_jamais_perdue) :-
    coder_essai(exhaustif, [], R), memberchk(code('G', suffisante_mal_formee, _, annexe(complet, etablie)), R).
test(rejet_explicite_de_rien) :-                          % aucun statut ne dit « notation réfutée »
    coder_essai(exhaustif, [], R), \+ member(code(_, ecarte, _, _), R).

:- end_tests(codage).

% --- Indexé et exhaustif : mêmes résultats positifs, sur des graphes et des requêtes tirés ---------------------------

index_genere(N) :-
    retractall(requetes_index:requete_compilee(_, _, _, _, _, _, _, _)),
    forall(between(1, N, I), ( atom_concat(q, I, Id), requete_aleatoire(requete(_, F)),
                               assertz(requetes_index:requete_compilee(Id, gen, classe, requete(Id, F), aucune, compilee, [], f)) )),
    forall(member(Id-F, [qi1-type(v(x), 801), qi2-type(v(x), a1), qa-nom(v(x), ['X']), qb-nom(v(x), ['XA'])]),
           assertz(requetes_index:requete_compilee(Id, gen, classe, requete(Id, F), aucune, compilee, [], f))),
    codage:reindexer.

:- begin_tests(codage_generatif).

test(indexe_egal_exhaustif_sur_des_tirages) :-
    set_random(seed(20261127)), index_genere(80),
    findall(G, ( between(1, 120, _), graphe_aleatoire(G) ), Gs),
    forall(member(G, Gs),
           ( coder(gen, G, indexe, [k(connaissances_gen), normaliser(non)], Ri),
             coder(gen, G, exhaustif, [k(connaissances_gen), normaliser(non)], Rx),
             positifs(Ri, Pi), positifs(Rx, Px),
             ( Pi == Px -> true ; format(user_error, "indexé ~w, exhaustif ~w~n", [Pi, Px]), fail ) )),
    aggregate_all(count, ( member(G, Gs), coder(gen, G, exhaustif, [k(connaissances_gen), normaliser(non)], R),
                           positifs(R, [_|_]) ), Np),
    Np > 10.

:- end_tests(codage_generatif).
