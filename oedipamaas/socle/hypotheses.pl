/*  Les hypothèses de sujet (docs/PLAN_F3.md, étape 3) : reconnaître le sujet d'une image, c'est expliquer sa scène
    par le profil d'une notation d'Iconclass (sujets.pl), avec des règles qualitatives, sans poids.

    Correspondance d'un élément de scène et d'un élément de profil, dans la langue du texte : même nom normalisé ; même
    mot (lemme ou forme) ; en anglais aussi un lemme de WordNet de la forme. (Les liens de dérivation de WordNet ont été
    essayés et retirés : ils rapprochent « hold » de « holder », « identify » de « identity », « fowl » de « fowler ».)

    1. Génération : une notation est envisagée si son profil porte un nom de la scène (à toute origine), ou un mot rare
       de la scène (porté en propre, attribut ou mot clé par au plus 20 notations d'Iconclass : la seule quantité, et
       elle se calcule sur Iconclass). Un motif (référent abstrait) n'en suscite aucune.
    2. Condition nécessaire : une notation dont le libellé nomme des personnes (sujets_index:exige/3 : les noms de sa
       partie propre, hors parenthèses et hors lieux) exige qu'elles soient toutes dans la scène, nommées ; une notation
       qui n'en nomme pas exige celles de l'ancêtre le plus proche qui en nomme (l'histoire dont elle fait partie).
    3. Condition différentielle : la scène contient un élément discriminant propre à la notation (un nom de sa partie
       propre, ou un mot rare, en propre, attribut ou mot clé) qu'aucune de ses sœurs n'a en propre : ce qui la
       distingue d'elles. Et elle est expliquée par au moins deux éléments du texte (deux mots différents de la scène :
       un nom seul ne fait pas un sujet ; un motif compte comme appui).
    4. Meilleure explication : une notation est écartée si une notation d'une autre branche explique strictement plus
       d'éléments du texte ; deux notations de branches différentes qui expliquent les mêmes éléments ne sont ni l'une
       ni l'autre établies (la scène ne les départage pas). Dans une même branche, on garde la plus précise.
    5. Saillance : l'élément distinctif vient d'un référent que le texte donne pour le sujet de l'image (saillance
       principale, mondes.pl) ; un élément semé ailleurs dans le texte fait un composant, pas un sujet.
    Les notations générées qui satisfont la condition nécessaire et ont au moins un appui propre, sans être établies,
    sont candidates.

    sujets(+Langue, +Elements, -Etablis, -Candidats)
        Elements : el(Genre, Valeur, Porteur, Passage, Saillance) (scene:elements_de_scene/2)
        Etablis, Candidats : sujet(N, Appuis, Distinctifs)
        Appuis : appui(Genre, Element, Origine, Valeur, Passage, GenreScene-Saillance)
*/
:- module(hypotheses, [ sujets/4 ]).
:- encoding(utf8).
:- use_module(arbre).

seuil_de_rarete(20).

origine_propre(O) :- memberchk(O, [propre, attribut, mot_cle]).

% --- Correspondance --------------------------------------------------------------------------------------------------

correspond(_, el(nom, K, _, _, _), nom, K).
correspond(L, el(G, W, _, _, _), mot, E) :- memberchk(G, [mot, motif]), equivalent(L, W, E).

equivalent(_, W, W).
equivalent(en, W, E) :- catch(morphologie:tous_lemmes(W, Ls), _, fail), member(E, Ls), E \== W.

% --- Génération -----------------------------------------------------------------------------------------------------

generee(L, Els, N) :-
    member(El, Els), El = el(G, _, _, _, _), G \== motif,
    correspond(L, El, GP, E),
    (   GP == nom -> sujets_index:profil(N, L, nom, E, _)
    ;   seuil_de_rarete(R0), sujets_index:rarete(L, mot, E, R), R =< R0,
        sujets_index:profil(N, L, mot, E, O), origine_propre(O)
    ).

% les appuis de N : chaque élément de son profil que la scène porte
appuis(L, Els, N, Appuis) :-
    findall(appui(GP, E, O, V, P, GS),
            ( sujets_index:profil(N, L, GP, E, O), member(El, Els), El = el(G, V, _, P, Sa), GS = G-Sa,
              correspond(L, El, GP, E) ),
            Appuis0),
    sort(Appuis0, Appuis).

% --- Conditions ------------------------------------------------------------------------------------------------------

% les personnes que le sujet exige : celles de son libellé, sinon celles de l'ancêtre le plus proche qui en nomme
% (les divisions et sections d'Iconclass, notations d'un ou deux caractères, sont des rubriques : « 34 Man and Animal »
% n'exige personne)
noms_exiges(_, N, []) :- atom_length(N, Lg), Lg =< 2, !.
noms_exiges(L, N, Noms) :-
    (   findall(K, sujets_index:exige(N, L, K), Ks), Ks \== [] -> Noms = Ks
    ;   arbre:parent(N, P) -> noms_exiges(L, P, Noms)
    ;   Noms = []
    ).

necessaire(L, N, Appuis) :-
    noms_exiges(L, N, Noms),
    forall(member(K, Noms), memberchk(appui(nom, K, _, _, _, _), Appuis)).

% les éléments discriminants propres à N que la scène porte par un référent saillant (une chose ou un nom : un motif ne
% distingue pas) et qu'aucune sœur n'a en propre
distinctifs(L, N, Appuis, Ds) :-
    findall(GP-E, ( member(appui(GP, E, O, _, _, G-principal), Appuis), origine_propre(O), G \== motif,
                    discriminant(L, GP, E, O),
                    \+ ( soeur(N, S), sujets_index:profil(S, L, GP, E, O2), origine_propre(O2) ) ), Ds0),
    sort(Ds0, Ds).

discriminant(_, nom, _, propre) :- !.
discriminant(L, mot, E, _) :- seuil_de_rarete(R0), sujets_index:rarete(L, mot, E, R), R =< R0.

soeur(N, S) :- arbre:parent(N, P), arbre:enfants(P, Es), member(S, Es), S \== N.

assez_d_appuis(Appuis) :-
    appuis_vus(Appuis, Vs), length(Vs, K), K >= 2.

% --- Décision --------------------------------------------------------------------------------------------------------

sujets(L, Els, Etablis, Candidats) :-
    findall(N, distinct(N, generee(L, Els, N)), Ns),
    findall(h(N, Appuis, Ds, Statut),
            ( member(N, Ns), appuis(L, Els, N, Appuis), necessaire(L, N, Appuis),
              distinctifs(L, N, Appuis, Ds),
              (   Ds \== [], assez_d_appuis(Appuis) -> Statut = etabli
              ;   member(appui(_, _, O, _, _, _), Appuis), origine_propre(O) -> Statut = candidat
              ) ),
            Hs),
    findall(N-A-D, member(h(N, A, D, etabli), Hs), Es0),
    findall(N-A, member(h(N, A, _, _), Hs), Tous),
    exclude(mieux_explique(Tous), Es0, Es1),
    exclude(ambigu(Es1), Es1, Es2a),
    exclude(precise_par(Es2a), Es2a, Es2),
    findall(sujet(N, A, D), member(N-A-D, Es2), Etablis),
    findall(sujet(N, A, D), ( member(h(N, A, D, S), Hs), ( S == candidat ; \+ memberchk(N-_-_, Es2) ) ), Candidats).

% une notation établie qu'une notation établie plus profonde de la même branche précise
precise_par(Es, N-_-_) :- member(N2-_-_, Es), N2 \== N, arbre:ancetre(N2, N), !.

% une notation qu'une hypothèse d'une autre branche explique strictement mieux (plus d'éléments du texte)
mieux_explique(Tous, N-A-_) :-
    appuis_vus(A, V),
    member(N2-A2, Tous), N2 \== N, \+ arbre:ancetre(N2, N), \+ arbre:ancetre(N, N2),
    appuis_vus(A2, V2), ord_subset(V, V2), V2 \== V, !.

% deux notations établies de branches différentes, avec les mêmes appuis : la scène ne les départage pas
ambigu(Es, N-A-_) :-
    member(N2-A2-_, Es), N2 \== N, \+ arbre:ancetre(N2, N), \+ arbre:ancetre(N, N2),
    appuis_vus(A, V), appuis_vus(A2, V), !.
appuis_vus(A, V) :- findall(X, member(appui(_, _, _, X, _, _), A), V0), sort(V0, V).
