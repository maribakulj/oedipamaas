/*  L'inclusion des requêtes du noyau (docs/NOYAU.md, § 8) : Q1 implique-t-elle Q2 ?

    inclusion(+K, +Normaliser, +Q1, +Q2, -R)
        R = oui | non(ContreExemple) | indetermine(Raison)
        Normaliser : un prédicat d'arité 2 (Graphe0, Graphe) appliqué à chaque graphe canonique (la normalisation de la
        langue, C7), ou « aucune »
    comparer(+K, +Normaliser, +Q1, +Q2, -Verdict)
        Verdict = equivalentes | incluse | contient | incomparables(CE1, CE2) | indetermine(Raison)
          incluse : Q1 ⊆ Q2 seulement (Q1 est plus forte) ; contient : Q2 ⊆ Q1 seulement

    Le critère : Q1 ⊆ Q2 si et seulement si, pour chaque cas de Q1 (une sélection de sa forme normale disjonctive, et un
    nom de chaque liste de noms alternatifs : « nom(x, [DAVID, GOLIATH]) » est deux cas, jamais une conjonction), le
    graphe canonique du cas établit Q2. C'est le critère de Chandra et Merlin pour les requêtes conjonctives ; il vaut
    ici parce que le graphe canonique est un modèle universel du cas, dans la sémantique du noyau :
      - chaque variable de référent est une entité positive, affirmée, de l'auteur, sans autre type que les siens (une
        entité porteuse de type neutre « $referent » la rend présente même si le cas ne lui donne aucun type) ; deux
        variables sont deux entités dont l'identité est inconnue (ni coréférence ni distinction) ;
      - un atome est une assertion positive, sans négation : le graphe canonique ne réfute rien ;
      - `meme(X, Y)` est une coréférence ; `distincts(X, Y)` une distinction établie (`distinct/2`) ; `nombre(X, N)`
        un nombre : chacune est exactement ce que la contrainte exige, rien de plus ;
      - « établit » veut dire le statut `etablie` : une conclusion sous hypothèse (deux noms différents, une distinction
        supposée) ne compte pas, puisqu'elle ne vaut pas dans tous les modèles du cas.
    Un cas dont le graphe canonique n'établit pas Q2 est un contre-exemple : un modèle de Q1 où Q2 est fausse ou
    inconnue. Le critère suppose que K et la normalisation sont les mêmes des deux côtés, et que la normalisation est
    une équivalence ; hors de là (un budget épuisé, un graphe canonique invalide, une requête mal formée), le résultat
    est indéterminé, jamais une inclusion ou une non-inclusion.
*/
:- module(inclusion, [ inclusion/5, comparer/5, cas_de/2, canonique/2 ]).
:- encoding(utf8).
:- use_module(library(lists)).
:- use_module(library(apply)).
:- use_module(requetes).
:- use_module(satisfaction).

comparer(K, N, Q1, Q2, V) :-
    inclusion(K, N, Q1, Q2, R12), inclusion(K, N, Q2, Q1, R21),
    (   ( R12 = indetermine(X) ; R21 = indetermine(X) ) -> V = indetermine(X)
    ;   R12 == oui, R21 == oui -> V = equivalentes
    ;   R12 == oui -> V = incluse
    ;   R21 == oui -> V = contient
    ;   R12 = non(C1), R21 = non(C2), V = incomparables(C1, C2)
    ).

inclusion(_, _, Q1, Q2, indetermine(requete_mal_formee)) :-
    ( \+ requetes:bien_formee(Q1, []) ; \+ requetes:bien_formee(Q2, []) ), !.
inclusion(K, N, requete(_, F1), Q2, R) :-
    findall(As, cas_de(F1, As), Cas),
    catch(premier_contre_exemple(K, N, Cas, Q2, R), E, ( E = fragment(X) -> R = indetermine(X) ; R = indetermine(E) )).

premier_contre_exemple(_, _, [], _, oui).
premier_contre_exemple(K, N, [As|Cas], Q2, R) :-
    canonique(As, G0), normaliser(N, G0, G),
    satisfaction:satisfaire(K, G, Q2, resultat(St, _, Complet)),
    (   Complet == incomplet -> R = indetermine(budget)
    ;   St == etablie -> premier_contre_exemple(K, N, Cas, Q2, R)
    ;   R = non(As)
    ).

normaliser(aucune, G, G) :- !.
normaliser(N, G0, G) :- call(N, G0, G).

% les cas d'une formule : une sélection, et un nom de chaque liste de noms
cas_de(et(Fs), As) :- !, cas_liste(Fs, As).
cas_de(ou(Fs), As) :- !, member(F, Fs), cas_de(F, As).
cas_de(nom(X, Ks), [nom(X, [K])]) :- !, member(K, Ks).
cas_de(A, [A]).
cas_liste([], []).
cas_liste([F|Fs], As) :- cas_de(F, A1), cas_liste(Fs, A2), append(A1, A2, As).

% le graphe canonique d'un cas ; les identifiants sont préfixés (« $v_x », « $t1 ») pour ne jamais rencontrer ceux
% d'une requête ; chaque variable de référent a une entité porteuse de type neutre, chaque variable d'événement un
% événement porteur de prédicat neutre
canonique(As, G) :-
    requetes:variables(As, Vs),
    findall(V, ( member(A, As), ( A = evenement(V, _) ; A = role(V, _, _) ) ), Evs0), sort(Evs0, Evs),
    % un événement n'a qu'un prédicat : deux atomes evenement sur une même variable sortent du fragment
    (   member(evenement(V1, P1), As), member(evenement(V2, P2), As), V1 == V2, P1 \== P2
    ->  throw(fragment(deux_predicats_pour_un_evenement))
    ;   true
    ),
    findall(F, ( member(V, Vs), id(V, I),
                 (   memberchk(V, Evs) -> ( member(evenement(V0, P), As), V0 == V -> true ; P = '$evenement' ),
                     F = evenement(I, P, '$p')
                 ;   F = entite(I, '$referent', '$p') ) ), Porteurs),
    foldl(canon, As, 1-[], _-Fs0), reverse(Fs0, Fs1),
    append(Porteurs, Fs1, Fs2),
    findall(Q, ( member(F, Fs2), identifiant(F, I), qualificatifs(F, I, Qs), member(Q, Qs) ), Qual),
    append([[texte("x"), doc(fr, inconnu), passage('$p', 0, 1)], Fs2, Qual], G0), sort(G0, G).

id(v(X), I) :- atom_concat('$v_', X, I).
num(P, N, I) :- format(atom(I), "$~w~w", [P, N]).

canon(type(V, T), N-G, N1-[entite(E, T, '$p'), coref(E, I)|G]) :- id(V, I), num(t, N, E), N1 is N + 1.
canon(nom(V, [K]), N-G, N1-[nom(A, I, K, '$p')|G]) :- id(V, I), num(n, N, A), N1 is N + 1.
canon(propriete(V, P), N-G, N1-[propriete(A, I, P, '$p')|G]) :- id(V, I), num(q, N, A), N1 is N + 1.
canon(evenement(_, _), N-G, N1-G) :- N1 is N + 1.                 % porté par l'événement de la variable
canon(role(V, R, X), N-G, N1-[role(I, R, J)|G]) :- id(V, I), id(X, J), N1 is N + 1.
canon(relation(X, R, Y), N-G, N1-[relation(A, I, R, J, '$p')|G]) :- id(X, I), id(Y, J), num(r, N, A), N1 is N + 1.
canon(genre(T), N-G, N1-[entite(E, T, '$p')|G]) :- num(genre__, N, E), N1 is N + 1.
canon(meme(X, Y), N-G, N1-[coref(I, J)|G]) :- id(X, I), id(Y, J), N1 is N + 1.
canon(distincts(X, Y), N-G, N1-[distinct(I, J)|G]) :- id(X, I), id(Y, J), N1 is N + 1.
canon(nombre(X, K), N-G, N1-[nombre(I, K)|G]) :- id(X, I), N1 is N + 1.

identifiant(entite(I, _, _), I). identifiant(nom(I, _, _, _), I). identifiant(propriete(I, _, _, _), I).
identifiant(evenement(I, _, _), I). identifiant(relation(I, _, _, _, _), I).
qualificatifs(F, I, [polarite(I, pos), modalite(I, affirme), portee(I, P), enonciateur(I, auteur)]) :-
    ( F = entite(_, _, _), sub_atom(I, 0, _, _, '$genre__') -> P = oeuvre ; P = represente ).
