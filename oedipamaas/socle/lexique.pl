/*  Le lexique (conception 1.0, § 7) : l'index des formes d'Iconclass et le pont WordNet.

    Index (construit une fois par construire_index/1, chargé ensuite comme module lexique_index) :
        entree(Forme, Notation, Source)
    Forme : expression en minuscules, espaces normalisés ; pour l'anglais, la forme écrite et ses lemmes. Sources :
        mot_cle(Langue)   un mot clé de la notation, dans l'une des langues d'Iconclass
        mot_libelle       un mot plein du libellé anglais
        attribut          un attribut possible (« possible attributes: … »)
        renvoi(Mot)       « see » entre mots clés : la forme renvoie au mot clé Mot de la notation

    Pont WordNet : voisin(Forme, Autre, Relation, Pas), sur les synsets de la forme : synonymie (même synset),
    hyperonymie et hyponymie à deux pas au plus (classes d'instances comprises), dérivation, pertainym, similarité
    d'adjectifs, méronymie et holonymie. La généralité d'un synset (profondeur depuis la racine, nombre de
    descendants) est calculée, jamais écrite : elle devient un trait de la décision.
*/
:- module(lexique, [ construire_index/1,  % +Fichier
                     forme_de/2,          % +Texte, -Forme
                     voisin/4,            % +Forme, -Autre, -Relation, -Pas
                     synset_general/3,    % +Synset, -Profondeur, -Descendants
                     generalite_forme/3   % +Forme, -ProfondeurMin, -DescendantsMax
                   ]).

:- use_module(morphologie).
:- use_module(libelles).

forme_de(Texte, Forme) :-
    downcase_atom(Texte, T0),
    normalize_space(atom(T1), T0),
    atom_codes(T1, Cs),
    exclude(guillemet, Cs, Cs1),
    atom_codes(T2, Cs1),
    normalize_space(atom(Forme), T2).

guillemet(0'').
guillemet(0'").

% --- Index ----------------------------------------------------------------------------------------------------------

construire_index(Fichier) :-
    setup_call_cleanup(open(Fichier, write, S, [encoding(utf8)]),
                       ( format(S, ":- module(lexique_index, [entree/3]).~n:- encoding(utf8).~n", []),
                         forall(distinct(F-N-Src, source_entree(F, N, Src)),
                                format(S, "entree(~q, ~q, ~q).~n", [F, N, Src])) ),
                       close(S)).

formes_anglaises(Texte, F) :-
    forme_de(Texte, F0),
    (   F = F0
    ;   morphologie:tous_lemmes(F0, Ls), member(F, Ls), F \== F0
    ).

source_entree(F, N, mot_cle(en)) :-
    iconclass:mot_cle(N, en, M),
    formes_anglaises(M, F).
source_entree(F, N, mot_cle(L)) :-
    iconclass:mot_cle(N, L, M), L \== en,
    forme_de(M, F).
source_entree(F, N, mot_libelle) :-
    iconclass:libelle(N, en, _),
    libelles:mots_du_libelle(N, Ms),
    member(M, Ms),
    formes_anglaises(M, F).
source_entree(F, N, attribut) :-
    iconclass:libelle(N, en, _),
    libelles:attributs_possibles(N, As),
    member(A, As),
    formes_anglaises(A, F).
source_entree(F, N, renvoi(K2)) :-
    iconclass:renvoi_mot(en, K1, see, K2),
    forme_de(K2, F2),
    iconclass:mot_cle(N, en, M2), forme_de(M2, F2),
    formes_anglaises(K1, F).

% --- Pont WordNet ---------------------------------------------------------------------------------------------------

synset(F, S) :- morphologie:forme_synset(F, _, S).

mots_du_synset(S, G) :- wordnet:s(S, _, Mot, _, _, _), downcase_atom(Mot, G).

monte(S, P) :- wordnet:hyp(S, P).
monte(S, P) :- wordnet:ins(S, P).

voisin(F, G, Relation, Pas) :-
    synset(F, S),
    voisin_synset(S, S2, Relation, Pas),
    mots_du_synset(S2, G),
    G \== F.

voisin_synset(S, S, synonyme, 0).
voisin_synset(S, S2, hyperonyme, 1) :- monte(S, S2).
voisin_synset(S, S2, hyperonyme, 2) :- monte(S, S1), monte(S1, S2).
voisin_synset(S, S2, hyponyme, 1) :- monte(S2, S).
voisin_synset(S, S2, hyponyme, 2) :- monte(S1, S), monte(S2, S1).
voisin_synset(S, S2, derive, 1) :- wordnet:der(S, _, S2, _).
voisin_synset(S, S2, pertainym, 1) :- wordnet:per(S, _, S2, _).
voisin_synset(S, S2, pertainym, 1) :- wordnet:per(S2, _, S, _).
voisin_synset(S, S2, similaire, 1) :- wordnet:sim(S, S2).
% sens des faits vérifié sur les données (mp(dossier, chaise)) : la partie d'abord, le tout ensuite
voisin_synset(S, S2, partie_de, 1) :- ( wordnet:mp(S, S2) ; wordnet:mm(S, S2) ; wordnet:ms(S, S2) ).
voisin_synset(S, S2, a_pour_partie, 1) :- ( wordnet:mp(S2, S) ; wordnet:mm(S2, S) ; wordnet:ms(S2, S) ).

% généralité calculée : profondeur depuis la racine (chemin le plus court) et nombre de descendants
:- table profondeur/2.
profondeur(S, 0) :- \+ monte(S, _), !.
profondeur(S, P) :- aggregate_all(min(P1), (monte(S, H), profondeur(H, P1)), P0), P is P0 + 1.

:- table descendants/2.
descendants(S, N) :- aggregate_all(count, descendant(S, _), N).

:- table descendant/2.
descendant(S, D) :- monte(D, S).
descendant(S, D) :- monte(D1, S), descendant(D1, D).

synset_general(S, P, N) :- profondeur(S, P), descendants(S, N).

generalite_forme(F, Pmin, Nmax) :-
    findall(P-N, (synset(F, S), synset_general(S, P, N)), L),
    L \== [],
    pairs_keys_values(L, Ps, Ns),
    min_list(Ps, Pmin), max_list(Ns, Nmax).
