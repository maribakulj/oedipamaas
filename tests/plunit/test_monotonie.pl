/*  La monotonie (docs/AUDIT_EXPRESSIVITE.md, § 2, proposition 1), mise à l'épreuve : un graphe G et une requête Q
    tirés au hasard (le générateur du noyau, graine fixe) ; quand Q est établie (déductivement, calcul complet), on
    ajoute à G les assertions positives, affirmées, de l'auteur, de portée represente, hors alternative, d'un second
    graphe tiré (identifiants renommés), et parfois une coréférence entre un nouveau référent et un ancien ; Q doit
    rester établie (ou le calcul devenir incomplet, ce qui n'est pas une conclusion).
    Deux variantes tirées : sans nom ajouté ; avec des noms ajoutés, où des contre-exemples sont ATTENDUS pour les
    requêtes à meme/distincts (un nom ajouté peut défaire une distinction documentaire, D26, une coréférence rendre une
    identité contradictoire, D12) : le test les compte et vérifie qu'il n'y en a aucun pour les requêtes sans
    contrainte d'identité. Le générateur ne produit pas toujours ces contre-exemples : deux sont écrits à la main.  */
:- use_module('../../oedipamaas/socle/requetes').
:- use_module('../../oedipamaas/socle/satisfaction').
:- use_module(connaissances_gen).
:- use_module(library(plunit)).
:- use_module(library(random)).
:- use_module(library(lists)).
:- use_module(library(apply)).
:- encoding(utf8).

:- consult(generateur_noyau).

k(connaissances_gen).

positif(G, A) :- memberchk(polarite(A, pos), G), memberchk(modalite(A, affirme), G), memberchk(portee(A, represente), G),
    memberchk(enonciateur(A, auteur), G), \+ ( member(alternative(_, As), G), memberchk(A, As) ).

% les assertions positives d'un second graphe, renommées (préfixe m_), ancrées au passage de G
extension(G2, Noms, Ext) :-
    findall(E, ( member(entite(E, _, _), G2), positif(G2, E) ), Es),
    findall(F, ( member(F0, G2), garder(F0, G2, Es, Noms), renommer(F0, F) ), Fs0),
    findall(Q, ( member(F0, G2), ident(F0, A), garder(F0, G2, Es, Noms), member(Q0, [polarite(A, pos), modalite(A, affirme),
                 portee(A, represente), enonciateur(A, auteur)]), renommer(Q0, Q) ), Qs),
    append(Fs0, Qs, Ext).
garder(entite(E, _, _), _, Es, _) :- memberchk(E, Es).
garder(nom(A, E, _, _), G, Es, oui) :- memberchk(E, Es), positif(G, A).
garder(propriete(A, E, _, _), G, Es, _) :- memberchk(E, Es), positif(G, A).
garder(evenement(V, _, _), G, _, _) :- positif(G, V).
garder(role(V, _, E), G, Es, _) :- positif(G, V), memberchk(E, Es).
garder(relation(A, E1, _, E2, _), G, Es, _) :- positif(G, A), memberchk(E1, Es), memberchk(E2, Es).
garder(coref(E1, E2), _, Es, _) :- memberchk(E1, Es), memberchk(E2, Es).
garder(distinct(E1, E2), _, Es, _) :- memberchk(E1, Es), memberchk(E2, Es).
garder(nombre(E, _), _, Es, _) :- memberchk(E, Es).
renommer(F0, F) :- F0 =.. [N|As], maplist(renommer_arg, As, Bs), F =.. [N|Bs].
renommer_arg(p_0, p_0) :- !.
renommer_arg(X, Y) :- atom(X), ( sub_atom(X, 0, _, _, e) ; sub_atom(X, 0, _, _, v) ; sub_atom(X, 0, _, _, n_)
    ; sub_atom(X, 0, _, _, m_) ; sub_atom(X, 0, _, _, q_) ; sub_atom(X, 0, _, _, r_) ), atom_length(X, L), L =< 5,
    \+ memberchk(X, [entite]), !, atom_concat(z_, X, Y).
renommer_arg(X, X).

identite(requete(_, F)) :- sous_f(F, C), memberchk(C, [meme(_, _), distincts(_, _)]), !.
sous_f(X, X).
sous_f(et(Fs), X) :- member(F, Fs), sous_f(F, X).
sous_f(ou(Fs), X) :- member(F, Fs), sous_f(F, X).

% un cas : (Avant, Apres) quand Q est établie sur G, sinon rien
cas(Noms, Q, St2) :-
    k(K), graphe_aleatoire(G), requete_aleatoire(Q),
    satisfaire(K, G, Q, [budget(200000)], resultat(etablie, _, complet)),
    graphe_aleatoire(G2), extension(G2, Noms, Ext0),
    findall(E, member(entite(E, _, _), Ext0), Nouveaux), findall(E, member(entite(E, _, _), G), Anciens),
    ( Nouveaux = [N|_], Anciens = [A|_], peut_etre(0.5) -> Ext = [coref(N, A)|Ext0] ; Ext = Ext0 ),
    append(G, Ext, G1),
    satisfaire(K, G1, Q, [budget(200000)], resultat(St2, _, _)).

:- begin_tests(monotonie).

test(sans_nom_ajoute) :-
    set_random(seed(20261201)), cas_generatifs(N),
    findall(St-Q, ( between(1, N, _), cas(non, Q, St) ), Tous),
    length(Tous, NT), aggregate_all(count, member(etablie-_, Tous), NG),
    format(user_error, "monotonie, sans nom ajouté : ~d cas établis étendus, ~d restés établis~n", [NT, NG]),
    assertion(NT >= 100),
    exclude([S-_]>>memberchk(S, [etablie, incomplet]), Tous, Ecarts),
    length(Ecarts, NE), ( NE > 0 -> Ecarts = [Ex|_], print_message(error, format("contre-exemple : ~q", [Ex])) ; true ),
    assertion(NE == 0).

test(avec_noms_ajoutes_seulement_l_identite) :-
    set_random(seed(20261202)), cas_generatifs(N),
    findall(I-St, ( between(1, N, _), cas(oui, Q, St), ( identite(Q) -> I = identite ; I = autre ) ), Tous),
    length(Tous, NT), assertion(NT >= 100),
    exclude([_-S]>>memberchk(S, [etablie, incomplet]), Tous, Ecarts),
    include([I-_]>>( I == autre ), Ecarts, Autres),
    aggregate_all(count, member(identite-_, Ecarts), NI),
    length(Autres, NA),
    format(user_error, "monotonie, noms ajoutés : ~d cas étendus, ~d contre-exemples sur meme/distincts, ~d ailleurs~n",
           [NT, NI, NA]),
    assertion(Autres == []).

% le contre-exemple écrit : la monotonie est fausse, par conception, pour l'identité (D26, D12)
q(A, [polarite(A, pos), modalite(A, affirme), portee(A, represente), enonciateur(A, auteur)]).
deux_noms(G) :-
    findall(Q, ( member(A, [e1, e2, n1, n2]), q(A, Qs), member(Q, Qs) ), Qu),
    append([[texte("x"), doc(fr, inconnu), passage(p_0, 0, 1), entite(e1, nom_propre, p_0), entite(e2, nom_propre, p_0),
             nom(n1, e1, x, p_0), nom(n2, e2, z, p_0)], Qu], G).

test(contre_exemple_un_nom_ajoute_defait_une_distinction_documentaire) :-
    k(K), deux_noms(G), Q = requete(r, et([nom(v(a), ['X']), nom(v(b), ['Z']), distincts(v(a), v(b))])),
    satisfaire(K, G, Q, resultat(etablie, _, _)),              % X et Z : deux individus selon K
    q(n3, Q3), append([G, [nom(n3, e2, x, p_0)], Q3], G2),       % le porteur de Z porte aussi X (positif, de l'auteur)
    satisfaire(K, G2, Q, resultat(S, _, _)), assertion(S \== etablie).

test(contre_exemple_une_coreference_ajoutee_rend_une_identite_contradictoire) :-
    k(K), deux_noms(G), Q = requete(r, et([nom(v(a), ['X']), nom(v(b), ['Z']), meme(v(a), v(b))])),
    append(G, [coref(e1, e2)], G2), satisfaire(K, G2, Q, resultat(S, _, _)), assertion(S == contradictoire).

:- end_tests(monotonie).
