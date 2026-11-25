/*  Le moteur de satisfaction des requêtes, optimisé (docs/NOYAU.md, version 0.2, § 4 et 5).

    satisfaire(+K, +Graphe, +Requete, -Resultat)
    satisfaire(+K, +Graphe, +Requete, +Options, -Resultat)      Options : [budget(N), temps(Secondes)]
        temps(S) : une limite de temps ; dépassée, le résultat est resultat(incomplet, [temps_depasse], incomplet),
                   même si une solution certifiable avait été trouvée (le calcul interrompu n'est pas mis en forme)
        K        le module de connaissances (docs/NOYAU.md, § 2)
        Graphe   la liste des assertions d'un document, validée (assertions:valider/2) ; invalide : une erreur
                 graphe_invalide(Erreurs)
        Requete  requete(Id, Formule), bien formée ; sinon une erreur requete_mal_formee(Id, Erreurs)
        Resultat resultat(Statut, Elements, Complet)
          Statut   etablie | etablie_sous_hypotheses | contradictoire | non_certifiee | ecartee | inconnue | incomplet
          Elements etablie, etablie_sous_hypotheses : les preuves (preuve/6) ;
                   contradictoire, non_certifiee, ecartee : les substitutions minimales, avec leur détail ;
                   inconnue, incomplet : partiel(Satisfaits, Manquants) (jamais une preuve)
          Complet  complet | incomplet (budget épuisé)

    solutions_classees(+K, +Graphe, +Requete, -Vue) : la vue que le moteur de référence doit reproduire exactement
        vue(Certifiables, Contradictoires, NonCertifiees, Fausses)
          Certifiables   [cert(Classe, Sigma, Selection)] ; Classe : vraie | sous_hypotheses(Hs)
          les trois autres : les substitutions minimales de chaque classe, triées

    Le graphe est chargé dans un module temporaire, propre à l'appel : deux documents ne se mêlent jamais.
*/
:- module(satisfaction, [ satisfaire/4, satisfaire/5, satisfaire_lot/4, solutions_classees/4, version_noyau/1,
                          budget/1, empreinte/2 ]).
:- encoding(utf8).
:- use_module(library(lists)).
:- use_module(library(apply)).
:- use_module(library(pairs)).
:- use_module(library(solution_sequences)).
:- use_module(library(yall)).
:- use_module(library(time)).
:- use_module(requetes).
:- use_module(assertions, [valider/2]).

version_noyau('noyau 0.2').
budget(300000).                  % appuis examinés par requête

satisfaire(K, G, Q, R) :- satisfaire(K, G, Q, [], R).
satisfaire(K, G, Q, Opts, R) :-
    ( Q = requete(Id, F) -> true ; throw(error(requete_mal_formee(inconnu, [pas_une_requete(Q)]), _)) ),
    controler(G, requete(Id, F)),
    (   memberchk(temps(T), Opts)
    ->  catch(call_with_time_limit(T, in_temporary_module(M, charger(M, G), resoudre(K, M, Id, F, Opts, R))),
              time_limit_exceeded, R = resultat(incomplet, [temps_depasse], incomplet))
    ;   in_temporary_module(M, charger(M, G), resoudre(K, M, Id, F, Opts, R))
    ).

satisfaire_lot(K, G, Qs, Rs) :-
    controler(G, requete(r, genre(x))),
    in_temporary_module(M, charger(M, G), resoudre_toutes(K, M, Qs, Rs)).
resoudre_toutes(K, M, Qs, Rs) :- maplist(resoudre_une(K, M), Qs, Rs).
resoudre_une(K, M, requete(Id, F), Id-R) :-
    requetes:bien_formee(requete(Id, F), Es),
    ( Es \== [] -> R = mal_formee(Es) ; resoudre(K, M, Id, F, [], R) ).

solutions_classees(K, G, requete(Id, F), Vue) :-
    controler(G, requete(Id, F)),
    in_temporary_module(M, charger(M, G), vue(K, M, F, [budget(inf)], Vue)).

controler(G, requete(Id, F)) :-
    requetes:bien_formee(requete(Id, F), Es),
    ( Es \== [] -> throw(error(requete_mal_formee(Id, Es), _)) ; true ),
    assertions:valider(G, Eg),
    ( Eg \== [] -> throw(error(graphe_invalide(Eg), _)) ; true ).

% l'empreinte d'un graphe : celle de ses assertions triées
empreinte(G, H) :- msort(G, Gs), variant_sha1(Gs, H).

% --- Le graphe -------------------------------------------------------------------------------------------------------

predicats([entite/3, nom/4, propriete/4, evenement/3, role/3, relation/5, coref/2, distinct/2, nombre/2, polarite/2,
           modalite/2, portee/2, enonciateur/2, alternative/2, passage/3, classe/2, empreinte/1, cert/1, compteur/1]).

charger(M, G) :-
    predicats(Ps), forall(member(P, Ps), dynamic(M:P)),
    forall(( member(F, G), functor(F, N, A), memberchk(N/A, Ps) ), assertz(M:F)),
    forall(M:entite(E, _, _), ( representant(M, E, R), assertz(M:classe(E, R)) )),
    empreinte(G, H), assertz(M:empreinte(H)).

representant(M, E, R) :- composante(M, [E], [E], C), min_member(R, C).
composante(_, [], Vus, Vus).
composante(M, [X|Xs], Vus, C) :-
    findall(Y, ( ( M:coref(X, Y) ; M:coref(Y, X) ), \+ memberchk(Y, Vus) ), Ys0), sort(Ys0, Ys),
    append(Vus, Ys, Vus1), append(Xs, Ys, Xs1), composante(M, Xs1, Vus1, C).
classes(M, Rs) :- setof(R, E^M:classe(E, R), Rs), !.
classes(_, []).

% --- Les états des appuis (§ 1) --------------------------------------------------------------------------------------

qualifie(M, A, Pol, Ctx, Q) :-
    M:polarite(A, Pol), M:modalite(A, affirme), M:portee(A, Ctx), M:enonciateur(A, Q),
    \+ ( M:alternative(_, As), memberchk(A, As) ).
present(M, E) :- qualifie(M, E, pos, represente, _), !.

% --- Les liens (§ 2) -------------------------------------------------------------------------------------------------

lien_pos(K, Cat, W, T, chemin(W, Ch)) :- K:sens(Cat, W, S0), once(monte(K, sous, S0, T, [S0], Ch)).
lien_neg(K, Cat, T, W, chemin_inclus(T, Ch, W)) :-
    K:sens(Cat, T, S0), K:sens(Cat, W, Sn), once(monte(K, inclus, S0, Sn, [S0], Ch)).
monte(_, _, S, T, _, [S]) :- S == T, !.
monte(K, P, S, T, Vus, [S|Ch]) :- pas(K, P, S, S1), \+ memberchk(S1, Vus), monte(K, P, S1, T, [S1|Vus], Ch).
pas(K, sous, S, S1) :- K:sous(S, S1).
pas(K, inclus, S, S1) :- K:inclus(S, S1).

lien_de_nom(K, Nom, Ks, L) :-
    K:cle_de_nom(Nom, C),
    (   memberchk(C, Ks) -> L = cle(C)
    ;   member(Ka, Ks), ( K:alias(C, Ka) ; K:alias(Ka, C) ) -> L = alias(C, Ka)
    ).

% --- Les appuis d'un atome -------------------------------------------------------------------------------------------

% appui(+K, +M, ?AtomeInstancie, ?Signe, -Enonciateur, -Appui) ; compte les appuis examinés (le budget)
appui(K, M, A, S, Q, Ap) :- appui_(K, M, A, S, Q, Ap), compter(M).

appui_(K, M, type(R, T), S, Q, appui(E, E, P, L)) :-
    M:entite(E, W, P), W \== nom_propre, M:classe(E, R), qualifie(M, E, S, represente, Q),
    ( S == pos -> lien_pos(K, n, W, T, L) ; lien_neg(K, n, T, W, L) ).
appui_(K, M, nom(R, Ks), S, Q, appui(A, E, P, L)) :-
    M:nom(A, E, Nom, P), M:classe(E, R), qualifie(M, A, S, represente, Q), present(M, E), lien_de_nom(K, Nom, Ks, L).
appui_(K, M, propriete(R, Pr), S, Q, appui(A, E, P, L)) :-
    M:propriete(A, E, W, P), M:classe(E, R), qualifie(M, A, S, represente, Q), present(M, E),
    ( S == pos -> lien_pos(K, a, W, Pr, L) ; lien_neg(K, a, Pr, W, L) ).
appui_(K, M, evenement(V, Pr), S, Q, appui(V, V, P, L)) :-
    M:evenement(V, W, P), qualifie(M, V, S, represente, Q),
    ( S == pos -> lien_pos(K, v, W, Pr, L) ; lien_neg(K, v, Pr, W, L) ).
appui_(_, M, role(V, Ro, R), S, Q, appui(role(V, Ro, E), E, P, egal)) :-
    M:role(V, Ro, E), M:classe(E, R), M:evenement(V, _, P), qualifie(M, V, S, represente, Q), present(M, E).
appui_(K, M, relation(R1, Re, R2), S, Q, appui(A, E1, P, L)) :-
    M:relation(A, E1, W, E2, P), M:classe(E1, R1), M:classe(E2, R2), qualifie(M, A, S, represente, Q),
    present(M, E1), present(M, E2),
    ( S == pos -> lien_pos(K, r, W, Re, L) ; lien_neg(K, r, Re, W, L) ).
appui_(K, M, genre(T), S, Q, appui(E, E, P, L)) :-
    M:entite(E, W, P), W \== nom_propre, qualifie(M, E, S, oeuvre, Q),
    ( S == pos -> lien_pos(K, n, W, T, L) ; lien_neg(K, n, T, W, L) ).

compter(M) :-
    nb_getval(satisfaction_budget, B),
    (   B == inf -> true
    ;   M:compteur(C0) -> C is C0 + 1, retract(M:compteur(C0)), assertz(M:compteur(C)),
        ( C > B -> throw(budget_epuise) ; true )
    ;   assertz(M:compteur(1))
    ).

% --- Les valeurs sous une substitution partielle (§ 4.1, 4.2) ----------------------------------------------------

% valeur(+K, +M, +F, +Sigma, -P-N) : la paire de Belnap
valeur(K, M, et(Fs), S, P-N) :- !,
    valeurs(Fs, K, M, S, Vs), pairs_keys_values(Vs, Ps, Ns),
    ( memberchk(0, Ps) -> P = 0 ; P = 1 ), ( memberchk(1, Ns) -> N = 1 ; N = 0 ).
valeur(K, M, ou(Fs), S, P-N) :- !,
    valeurs(Fs, K, M, S, Vs), pairs_keys_values(Vs, Ps, Ns),
    ( memberchk(1, Ps) -> P = 1 ; P = 0 ), ( memberchk(0, Ns) -> N = 0 ; N = 1 ).
valeur(K, M, C, S, V) :- requetes:contrainte(C), !,
    ( contrainte_valeur(K, M, C, S, X) -> ( memberchk(X, [v(_), h(_)]) -> V = 1-0 ; X == f -> V = 0-1 ; V = 0-0 ) ; V = 0-0 ).
valeur(K, M, A, S, P-N) :-
    (   lie(A, S, Ai)
    ->  ( once(appui(K, M, Ai, pos, _, _)) -> P = 1 ; P = 0 ), ( once(appui(K, M, Ai, neg, _, _)) -> N = 1 ; N = 0 )
    ;   P = 0, N = 0
    ).

valeurs([], _, _, _, []).
valeurs([F|Fs], K, M, S, [V|Vs]) :- valeur(K, M, F, S, V), valeurs(Fs, K, M, S, Vs).
lies([], _, []).
lies([A|As], S, [B|Bs]) :- lie(A, S, B), lies(As, S, Bs).

% lie(+Atome, +Sigma, -AtomeInstancie) : toutes les variables de l'atome sont liées
lie(v(Nm), S, X) :- !, memberchk(v(Nm)-X, S).
lie(T, S, Ti) :- compound(T), !, T =.. [F|As], lies(As, S, Bs), Ti =.. [F|Bs].
lie(T, _, T).

% la valeur d'une contrainte, ses variables liées : v(Justification) | h(Hypothese) | f | i
contrainte_valeur(K, M, meme(X, Y), S, V) :-
    memberchk(X-A, S), memberchk(Y-B, S),
    ( A == B -> V = v(egalite) ; distinction(K, M, A, B, D), D \= supposee(_) -> V = f ; V = i ).
contrainte_valeur(K, M, distincts(X, Y), S, V) :-
    memberchk(X-A, S), memberchk(Y-B, S),
    (   A == B -> V = i                    % une substitution invalide, pas une réfutation par le texte
    ;   distinction(K, M, A, B, D) -> ( D = supposee(Ns1-Ns2) -> V = h(distinction_supposee(X, Y, Ns1, Ns2)) ; V = v(D) )
    ;   V = i
    ).
contrainte_valeur(_, M, nombre(X, Nb), S, V) :-
    memberchk(X-R, S),
    (   M:classe(E, R), M:nombre(E, Nb) -> V = v(nombre(E))
    ;   M:classe(E, R), M:nombre(E, N2), N2 \== Nb -> V = f
    ;   V = i
    ).

% la distinction de deux classes (§ 1) : etablie(distinct(E1, E2)) | documentaire(C1, C2, Source) | supposee(Noms)
distinction(_, M, A, B, etablie(distinct(E1, E2))) :-
    M:classe(E1, A), M:classe(E2, B), ( M:distinct(E1, E2) ; M:distinct(E2, E1) ), !.
distinction(K, M, A, B, documentaire(C1, C2, Src)) :-
    noms_de_classe(K, M, A, Ns1), noms_de_classe(K, M, B, Ns2), member(C1, Ns1), member(C2, Ns2),
    ( K:distincts_documentes(C1, C2, Src) ; K:distincts_documentes(C2, C1, Src) ), !.
distinction(K, M, A, B, supposee(Ns1-Ns2)) :-
    noms_de_classe(K, M, A, Ns1), Ns1 \== [], noms_de_classe(K, M, B, Ns2), Ns2 \== [],
    \+ ( member(C1, Ns1), member(C2, Ns2), ( C1 == C2 ; K:alias(C1, C2) ; K:alias(C2, C1) ) ).
noms_de_classe(K, M, R, Ns) :-
    findall(C, ( M:classe(E, R), M:nom(A, E, Nom, _), qualifie(M, A, pos, represente, _), K:cle_de_nom(Nom, C) ), Ns0),
    sort(Ns0, Ns).

% --- Les arbres (§ 4.5) ----------------------------------------------------------------------------------------------

% arbre(+Signe, +K, +M, +F, +Chemin, +Sigma0, -Sigma, +Sel0, -Sel)
%   pos : tous les enfants d'un « et », un d'un « ou » ; chaque atome lié par un appui positif (d'un énonciateur Q :
%         auteur pour la certification, quelconque pour la valeur) ; chaque contrainte, ses variables déjà liées, vraie
%   neg : un enfant d'un « et », tous ceux d'un « ou » ; chaque atome lié par un appui négatif ; chaque contrainte
%         fausse, ses variables ancrées par un appui d'un atome de la formule qui les contient
arbre(Sg, K, M, F0, F, C, S0, S, Sel0, Sel) :-
    descendre(Sg, K, M, F0, [g(C, F)], S0, S, Sel0, Sel).

descendre(_, _, _, _, [], S, S, Sel, Sel) :- !.
descendre(Sg, K, M, F0, Gs, S0, S, Sel0, Sel) :-
    choisir(Sg, K, M, Gs, S0, G, Reste),
    developper(Sg, K, M, F0, G, Reste, S0, S, Sel0, Sel).

% l'ordre : les « et » et « ou » se déplient ; les contraintes prêtes ; puis l'atome le plus sélectif
choisir(_, _, _, Gs, _, g(C, X), Reste) :- select(g(C, X), Gs, Reste), ( X = et(_) ; X = ou(_) ), !.
choisir(pos, _, _, Gs, S, g(C, Co), Reste) :-
    select(g(C, Co), Gs, Reste), requetes:contrainte(Co), requetes:variables(Co, Vs),
    forall(member(V, Vs), memberchk(V-_, S)), !.
choisir(Sg, K, M, Gs, S, G, Reste) :-
    findall(N-g(C, A), ( member(g(C, A), Gs), requetes:atome(A), signe_appui(Sg, Sa), instancier(A, S, Ai, _),
                         aggregate_all(count, appui_(K, M, Ai, Sa, _, _), N) ), Ns), Ns \== [], !,
    keysort(Ns, [_-G|_]), selectchk(G, Gs, Reste).
choisir(_, _, _, [G|Reste], _, G, Reste).
signe_appui(pos(_), pos).
signe_appui(neg, neg).

developper(pos(Q), K, M, F0, g(C, et(Fs)), Reste, S0, S, Sel0, Sel) :- !,
    enfants(C, Fs, Gs), append(Gs, Reste, Gs1), descendre(pos(Q), K, M, F0, Gs1, S0, S, Sel0, Sel).
developper(pos(Q), K, M, F0, g(C, ou(Fs)), Reste, S0, S, Sel0, Sel) :- !,
    nth1(I, Fs, Fi), append(C, [I], C1), descendre(pos(Q), K, M, F0, [g(C1, Fi)|Reste], S0, S, Sel0, Sel).
developper(neg, K, M, F0, g(C, et(Fs)), Reste, S0, S, Sel0, Sel) :- !,
    nth1(I, Fs, Fi), append(C, [I], C1), descendre(neg, K, M, F0, [g(C1, Fi)|Reste], S0, S, Sel0, Sel).
developper(neg, K, M, F0, g(C, ou(Fs)), Reste, S0, S, Sel0, Sel) :- !,
    enfants(C, Fs, Gs), append(Gs, Reste, Gs1), descendre(neg, K, M, F0, Gs1, S0, S, Sel0, Sel).
developper(pos(Q), K, M, F0, g(C, Co), Reste, S0, S, Sel0, Sel) :- requetes:contrainte(Co), !,
    contrainte_valeur(K, M, Co, S0, X), memberchk(X, [v(_), h(_)]),
    descendre(pos(Q), K, M, F0, Reste, S0, S, [C-Co|Sel0], Sel).
developper(neg, K, M, F0, g(C, Co), Reste, S0, S, Sel0, Sel) :- requetes:contrainte(Co), !,
    requetes:variables(Co, Vs), foldl(ancrer(K, M, F0), Vs, S0, S1),
    contrainte_valeur(K, M, Co, S1, f),
    descendre(neg, K, M, F0, Reste, S1, S, [C-Co|Sel0], Sel).
developper(Sg, K, M, F0, g(C, A), Reste, S0, S, Sel0, Sel) :-
    instancier(A, S0, Ai, Ls), signe_appui(Sg, Sa),
    distinct(Ai, ( appui(K, M, Ai, Sa, Q, _), ( Sg = pos(Q0) -> ( Q0 == tout -> true ; Q == Q0 ) ; true ) )),
    lier(Ls, S0, S1),
    descendre(Sg, K, M, F0, Reste, S1, S, [C-A|Sel0], Sel).

enfants(C, Fs, Gs) :- findall(g(C1, Fi), ( nth1(I, Fs, Fi), append(C, [I], C1) ), Gs).

% ancrer une variable non liée : par un appui (de l'un ou l'autre signe) d'un atome de la formule qui la contient
ancrer(_, _, _, V, S, S) :- memberchk(V-_, S), !.
ancrer(K, M, F0, V, S0, S) :-
    requetes:atomes(F0, As), member(_-A, As), requetes:atome(A), requetes:variables(A, Va), memberchk(V, Va),
    instancier(A, S0, Ai, Ls), member(Sg, [pos, neg]), distinct(Ai, appui(K, M, Ai, Sg, _, _)), lier(Ls, S0, S).

instancier(v(N), S, X, L) :- !, ( memberchk(v(N)-X0, S) -> X = X0, L = [] ; L = [v(N)-X] ).
instancier(T, S, Ti, L) :-
    compound(T), !, T =.. [F|As], foldl(instancier_arg(S), As, Ais, [], L), Ti =.. [F|Ais].
instancier(T, _, T, []).
instancier_arg(S, A, Ai, L0, L) :- instancier(A, S, Ai, La), append(L0, La, L).
lier(Ls, S0, S) :- foldl([V-X, A0, A]>>( memberchk(V-Y, A0) -> Y == X, A = A0 ; A = [V-X|A0] ), Ls, S0, S).

% --- La vue : certifiables, et minimales de chaque classe (§ 4.3, 4.4) -------------------------------------------

vue(K, M, F, Opts, vue(Cert, Cmin, NCmin, Fmin)) :-
    ( memberchk(budget(B), Opts) -> true ; budget(B) ), nb_setval(satisfaction_budget, B),
    retractall(M:compteur(_)), retractall(M:cert(_)),
    % les certifiables : un arbre positif de l'auteur, sans appui négatif sous lui
    forall(distinct(X, ( arbre(pos(auteur), K, M, F, F, [], [], S0, [], Sel0), sort(S0, S), sort(Sel0, Sel),
                         X = S-Sel )),
           ( X = S-Sel, certifiable(K, M, S, Sel, Cl) -> assertz(M:cert(cert(Cl, S, Sel))) ; true )),
    findall(C, M:cert(C), Cert0), sort(Cert0, Cert),
    % les candidates : arbres positifs (de tout énonciateur) et négatifs, et leurs unions
    findall(S, ( arbre(pos(tout), K, M, F, F, [], [], S0, [], _), sort(S0, S) ), Ps0), sort(Ps0, Ps),
    findall(S, ( arbre(neg, K, M, F, F, [], [], S0, [], _), sort(S0, S) ), Ns0), sort(Ns0, Ns),
    findall(S, ( member(P, Ps), member(N, Ns), union_coherente(P, N, S) ), PNs0), sort(PNs0, PNs),
    findall(S, ( member(S, PNs), valeur(K, M, F, S, 1-1) ), Cs), minimales(Cs, Cmin),
    findall(S, ( member(S, Ps), valeur(K, M, F, S, 1-0), \+ ( member(cert(_, S2, _), Cert), sous_ensemble(S2, S) ) ),
            NCs), minimales(NCs, NCmin),
    findall(S, ( member(S, Ns), valeur(K, M, F, S, 0-1) ), Fs), minimales(Fs, Fmin).

certifiable(K, M, S, Sel, Cl) :-
    forall(( member(_-A, Sel), requetes:atome(A) ), ( lie(A, S, Ai), \+ appui(K, M, Ai, neg, _, _) )),
    findall(H, ( member(_-Co, Sel), requetes:contrainte(Co), contrainte_valeur(K, M, Co, S, h(H)) ), Hs0), sort(Hs0, Hs),
    ( Hs == [] -> Cl = vraie ; Cl = sous_hypotheses(Hs) ).

union_coherente(P, N, S) :-
    forall(( member(V-X, P), memberchk(V-Y, N) ), X == Y), append(P, N, S0), sort(S0, S).
sous_ensemble(A, B) :- forall(member(X, A), memberchk(X, B)).
minimales(Ss0, Ms) :- sort(Ss0, Ss), findall(S, ( member(S, Ss), \+ ( member(T, Ss), T \== S, sous_ensemble(T, S) ) ), Ms).

% --- Le résultat -----------------------------------------------------------------------------------------------------

resoudre(K, M, Id, F, Opts, resultat(Statut, Elements, Complet)) :-
    (   catch(( vue(K, M, F, Opts, Vue), Complet = complet ), budget_epuise, ( Complet = incomplet, Vue = epuise ))
    ->  true
    ;   Vue = vue([], [], [], []), Complet = complet
    ),
    nb_setval(satisfaction_budget, inf),          % la mise en forme du résultat (preuves) n'est pas comptée
    (   Vue == epuise
    ->  findall(C, M:cert(C), Cert0), sort(Cert0, Cert),
        (   statut_certifie(K, M, Id, F, Cert, Statut, Elements) -> true
        ;   Statut = incomplet, partiel(K, M, F, P), Elements = [P]
        )
    ;   Vue = vue(Cert, Cmin, NCmin, Fmin),
        (   statut_certifie(K, M, Id, F, Cert, Statut, Elements) -> true
        ;   Cmin \== [] -> Statut = contradictoire, maplist(contradiction(K, M, F), Cmin, Elements)
        ;   NCmin \== [] -> Statut = non_certifiee, Elements = NCmin
        ;   Fmin \== [] -> Statut = ecartee, Elements = Fmin
        ;   Statut = inconnue, partiel(K, M, F, P), Elements = [P]
        )
    ).

statut_certifie(K, M, Id, F, Cert, Statut, Elements) :-
    (   include([cert(vraie, _, _)]>>true, Cert, Vs), Vs \== [] -> Statut = etablie
    ;   Cert \== [] -> Statut = etablie_sous_hypotheses, Vs = Cert
    ),
    regime(F, Rg), maplist(preuve(K, M, Id, Rg), Vs, Ps0), sort(Ps0, Elements).

% un contradictoire, avec sa nature : interne (un même énonciateur des deux côtés) ou documentaire
contradiction(K, M, F, S, contradictoire(S, Nature, Atomes)) :-
    requetes:atomes(F, As),
    findall(A-Qp-Qn, ( member(_-A, As), requetes:atome(A), lie(A, S, Ai),
                       setof(Q, Ap^appui(K, M, Ai, pos, Q, Ap), Qp), setof(Q, Ap^appui(K, M, Ai, neg, Q, Ap), Qn) ), Atomes),
    ( member(_-Qp-Qn, Atomes), member(Q, Qp), memberchk(Q, Qn) -> Nature = interne ; Nature = documentaire ).

regime(F, classement) :- requetes:atomes(F, As), forall(( member(_-A, As), requetes:atome(A) ), A = genre(_)), !.
regime(_, figuration).

preuve(K, M, Id, Rg, cert(Cl, S, Sel), preuve(Id, [noyau(V), connaissances(Vk), graphe(H)], Rg, S, Js, Hs)) :-
    version_noyau(V), K:version(Vk), M:empreinte(H),
    findall(j(C, A, Ap), ( member(C-A, Sel), requetes:atome(A), lie(A, S, Ai),
                           once(appui(K, M, Ai, pos, auteur, Ap)) ), Ja),
    findall(j(C, Co, contrainte(J)), ( member(C-Co, Sel), requetes:contrainte(Co),
                                       contrainte_valeur(K, M, Co, S, X), justification(X, J) ), Jc),
    append(Ja, Jc, Js0), sort(Js0, Js),
    ( Cl = sous_hypotheses(Hs) -> true ; Hs = [] ).
justification(v(J), J).
justification(h(_), hypothese).

% une correspondance partielle : les atomes qui ont un appui positif quelque part
partiel(K, M, F, partiel(Sat, Manq)) :-
    nb_setval(satisfaction_budget, inf),
    requetes:atomes(F, As),
    findall(C-A, ( member(C-A, As), requetes:atome(A), instancier(A, [], Ai, _), once(appui_(K, M, Ai, pos, _, _)) ), Sat),
    findall(C-A, ( member(C-A, As), requetes:atome(A), \+ memberchk(C-A, Sat) ), Manq).
