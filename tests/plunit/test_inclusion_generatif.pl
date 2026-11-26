/*  Qualification générative du comparateur (inclusion.pl ; docs/NOYAU.md, § 8 ; journal, D14) : les verdicts sont
    confrontés à des modèles, pas à une autre implémentation de l'inclusion.
      1. sûreté de « oui » : pour Q1 ⊆ Q2 rendu « oui », sur des graphes où Q1 est établie — le graphe canonique d'un cas
         de Q1, auquel on joint un graphe tiré au hasard (négations, sources citées, alternatives, coréférences vers les
         porteurs du cas) —, Q2 doit être établie ;
      2. justesse de « non » : le contre-exemple rendu établit Q1 et n'établit pas Q2 ;
      3. réflexivité, renommage des variables (le verdict ne dépend pas des noms), transitivité de « oui » ;
      4. les distributions des verdicts sont publiées (sortie d'erreur), y compris la part d'« indéterminé ».
    Les paires sont tirées par affaiblissement de Q1 (un conjoint retiré, un type remplacé par un plus général, une
    branche ajoutée, une contrainte retirée) et au hasard. Graine fixe.  */
:- use_module('../../oedipamaas/socle/requetes').
:- use_module('../../oedipamaas/socle/satisfaction').
:- use_module('../../oedipamaas/socle/inclusion').
:- use_module(connaissances_gen).
:- use_module(library(plunit)).
:- use_module(library(random)).
:- use_module(library(lists)).
:- use_module(library(apply)).
:- encoding(utf8).

:- consult(generateur_noyau).

k(connaissances_gen).
paires(N) :- ( getenv('OEDIPAMAAS_PAIRES_INCLUSION', A), atom_number(A, N0) -> N = N0 ; N = 300 ).

% --- Les affaiblissements ------------------------------------------------------------------------------------------

affaiblie(requete(_, F), requete(b, F2)) :-
    between(1, 50, _), random_between(1, 4, I), affaiblir(I, F, F2), F2 \== F,
    requetes:bien_formee(requete(b, F2), []), !.
affaiblie(requete(_, F), requete(b, F)).
affaiblir(1, et(Fs), F2) :- length(Fs, L), L >= 2, random_select(_, Fs, Fs1), ( Fs1 = [G] -> F2 = G ; F2 = et(Fs1) ).
affaiblir(2, F, F2) :- generaliser(F, F2).
affaiblir(3, F, ou([F, A])) :- atome_gen(A).
affaiblir(4, et(Fs), F2) :- select(C, Fs, Fs1), requetes:contrainte(C), !, ( Fs1 = [G] -> F2 = G ; F2 = et(Fs1) ).
generaliser(type(X, T), type(X, T2)) :- !, findall(P, connaissances_gen:sous(T, P), Ps), Ps \== [], random_member(T2, Ps).
generaliser(et(Fs), et(Fs2)) :- !, generaliser_un(Fs, Fs2).
generaliser(ou(Fs), ou(Fs2)) :- !, generaliser_un(Fs, Fs2).
generaliser(F, F).
generaliser_un(Fs, Fs2) :- nth1(I, Fs, F), generaliser(F, G), G \== F, !, nth1(I, Fs, _, R), nth1(I, Fs2, G, R).
generaliser_un(Fs, Fs).

% --- Les modèles : un cas de Q1, avec du bruit ----------------------------------------------------------------------

modele(Q1, G) :-
    Q1 = requete(_, F), findall(As, cas_de(F, As), Cas), Cas \== [], random_member(As, Cas),
    catch(canonique(As, G0), _, fail),
    graphe_aleatoire(Gr),
    findall(coref(P, E), ( member(entite(P, '$referent', _), G0), member(entite(E, _, _), Gr), peut_etre(0.25) ), Cor),
    negations_ciblees(G0, Ng),
    append([G0, Gr, Cor, Ng], G1), sort(G1, G),
    assertions:valider(G, []).

% des négations qui visent le cas : « pas de T » (entité nue, d'une source citée ou de l'auteur), un nom ou une
% propriété niés d'un porteur du cas
negations_ciblees(G0, Ng) :-
    findall(F, ( between(1, 3, I), peut_etre(0.5), atom_concat('$nie', I, A),
                 un_de([a, a1, a2, b, b1, top, c1, c2, lemme_a], W), un_de([auteur, cite(z)], En),
                 member(F, [entite(A, W, '$p'), polarite(A, neg), modalite(A, affirme), portee(A, represente),
                            enonciateur(A, En)]) ), Ns1),
    findall(F, ( member(entite(P, '$referent', _), G0), peut_etre(0.3), atom_concat(P, '_nom_nie', A),
                 un_de([x, xa, y, z], Nm),
                 member(F, [nom(A, P, Nm, '$p'), polarite(A, neg), modalite(A, affirme), portee(A, represente),
                            enonciateur(A, auteur)]) ), Ns2),
    findall(F, ( member(entite(P, '$referent', _), G0), peut_etre(0.2), atom_concat(P, '_prop_nie', A),
                 un_de([r, r1], Pr),
                 member(F, [propriete(A, P, Pr, '$p'), polarite(A, neg), modalite(A, affirme), portee(A, represente),
                            enonciateur(A, auteur)]) ), Ns3),
    append([Ns1, Ns2, Ns3], Ng).

etablie(K, G, Q) :- satisfaire(K, G, Q, resultat(etablie, _, complet)).
% les modèles sont des graphes de K⁺ (K et les mots « $noeud:T », NOYAU § 8) ; un comparateur qui n'a pas K⁺ (un
% mutant, une version ancienne) est confronté aux graphes de K
k_des_modeles(K, Ke) :- ( catch(inclusion:k_etendu(K, Ke), _, fail) -> true ; Ke = K ).

% Q1 ⊆ Q2 rendu « oui » : chaque modèle tiré où Q1 est établie établit Q2
sur_ses_modeles(Ke, Q1, Q2, Echecs) :-
    findall(G, ( between(1, 12, _), modele(Q1, G), etablie(Ke, G, Q1), \+ etablie(Ke, G, Q2) ), Echecs).

contre_exemple_valide(Ke, Q1, Q2, non(negation(As, T2))) :- !,
    canonique(As, G0), format(atom(M), "$noeud:~w", [T2]),
    append(G0, [entite('$nie', M, '$p'), polarite('$nie', neg), modalite('$nie', affirme), portee('$nie', represente),
                enonciateur('$nie', auteur)], G),
    etablie(Ke, G, Q1), \+ etablie(Ke, G, Q2).
contre_exemple_valide(Ke, Q1, Q2, non(As)) :- canonique(As, G), etablie(Ke, G, Q1), \+ etablie(Ke, G, Q2).

renommer(requete(I, F), requete(I, F2)) :- renommer_(F, F2).
renommer_(v(N), v(N2)) :- !, atom_concat(w_, N, N2).
renommer_(T, T2) :- compound(T), !, T =.. [F|As], maplist(renommer_, As, As2), T2 =.. [F|As2].
renommer_(T, T).

tirer_paires(N, Ps) :-
    findall(Q1-Q2, ( between(1, N, I), requete_aleatoire(Q1),
                     ( I mod 4 =:= 0 -> requete_aleatoire(Q2) ; affaiblie(Q1, Q2) ) ), Ps).

:- begin_tests(inclusion_generatif).

test(oui_sur_sur_les_modeles) :-
    set_random(seed(20261130)), paires(N), tirer_paires(N, Ps), k(K), k_des_modeles(K, Ke),
    findall(R, ( member(Q1-Q2, Ps), inclusion(K, aucune, Q1, Q2, R0), functor(R0, R, _) ), Rs),
    msort(Rs, Rs1), clumped(Rs1, Distribution),
    format(user_error, "~ninclusion, ~d paires : ~w~n", [N, Distribution]),
    findall(Q1-Q2-E, ( member(Q1-Q2, Ps), inclusion(K, aucune, Q1, Q2, oui), sur_ses_modeles(Ke, Q1, Q2, E), E \== [] ),
            Faux),
    ( Faux == [] -> true ; Faux = [X|_], format(user_error, "oui faux : ~q~n", [X]), fail ),
    memberchk(oui-_, Distribution), memberchk(non-_, Distribution).
test(non_a_un_contre_exemple_valide) :-
    set_random(seed(20261131)), paires(N), tirer_paires(N, Ps), k(K), k_des_modeles(K, Ke),
    forall(( member(Q1-Q2, Ps), inclusion(K, aucune, Q1, Q2, R), R = non(_) ),
           ( contre_exemple_valide(Ke, Q1, Q2, R) -> true ; format(user_error, "non faux : ~q~n", [Q1-Q2-R]), fail )).
test(reflexive_et_independante_des_noms) :-
    set_random(seed(20261132)), paires(N), k(K),
    findall(V, ( between(1, N, _), requete_aleatoire(Q), comparer(K, aucune, Q, Q, V0), functor(V0, V, _),
                 ( memberchk(V, [equivalentes, indetermine]) -> true ; format(user_error, "non réflexive : ~q~n", [Q]), fail ),
                 renommer(Q, Q2), comparer(K, aucune, Q, Q2, V2), functor(V2, V, _) ), Vs),
    msort(Vs, Vs1), clumped(Vs1, D), format(user_error, "réflexivité, ~d requêtes : ~w~n", [N, D]).
test(oui_transitif) :-
    set_random(seed(20261133)), paires(N), k(K),
    findall(t, ( between(1, N, _), requete_aleatoire(A), affaiblie(A, B), affaiblie(B, C),
                 inclusion(K, aucune, A, B, oui), inclusion(K, aucune, B, C, oui),
                 inclusion(K, aucune, A, C, R),
                 ( memberchk(R, [oui]) -> true ; R = indetermine(_) -> true
                 ; format(user_error, "non transitive : ~q~n", [A-B-C-R]), fail ) ), Ts),
    length(Ts, L), format(user_error, "transitivité : ~d chaînes A ⊆ B ⊆ C~n", [L]), L > 0.

:- end_tests(inclusion_generatif).
