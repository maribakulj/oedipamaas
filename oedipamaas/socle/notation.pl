/*  Grammaire de la notation Iconclass (conception 1.0, § 5, pièce 1).

    Une notation simple s'analyse en une liste de niveaux, du plus général au plus particulier ; chaque préfixe de la
    liste est un ancêtre syntaxique (« coder un descendant affirme ses ancêtres ») :

        chiffre(D)   un chiffre (division, sous-division, chiffres de la hiérarchie ou chiffres structuraux)
        lettre(L)    une capitale, J exclu
        double(L)    une lettre doublée (« HH ») : un seul niveau
        gabarit      le texte « (...) » d'un gabarit ouvert à tout nom
        nom(T)       un texte entre parenthèses (nom propre, titre, référence), T atome tel qu'écrit
        cle(S)       une clé « (+S) » ; S est la liste des niveaux de son suffixe (chiffres, et parfois un nom ou un
                     gabarit) ; chaque chiffre du suffixe est un niveau, comme le veut la hiérarchie des clés

    Une notation composée « A:B » s'analyse en composee([NA, NB, ...]), chaque partie étant une liste de niveaux.
    Le type sémantique d'un chiffre (hiérarchie ou chiffre structural) n'est pas syntaxique : il vient des
    déclarations d'Iconclass (autre pièce de la base).

    Forme machine : sans espaces hors des parenthèses (« 25 F 23 » s'écrit « 25F23 ») ; les espaces des noms sont
    gardés, ramenés à un seul et rognés. L'analyse accepte les espaces de l'édition imprimée.
*/
:- module(notation, [ analyser/2,            % +Atome, -Notation (liste de niveaux ou composee(Parties))
                      ecrire/2,              % +Notation, -Atome (forme machine)
                      normaliser/2,          % +Atome, -Atome (forme machine)
                      ancetre_syntaxique/2,  % +Atome, ?Ancetre (préfixes, la notation comprise)
                      parent_syntaxique/2,   % +Atome, -Parent (le préfixe d'un niveau de moins)
                      profondeur/2,          % +Atome, -N (nombre de niveaux)
                      sans_cle/2             % +Atome, -Atome (la notation sans sa clé)
                    ]).

:- use_module(library(dcg/basics), [blanks//0]).

analyser(Atome, Notation) :-
    atom_codes(Atome, Codes),
    phrase(notation(Notation), Codes), !.

ecrire(composee(Parties), Atome) :- !,
    maplist(ecrire_simple, Parties, Textes),
    atomic_list_concat(Textes, ':', Atome).
ecrire(Niveaux, Atome) :-
    ecrire_simple(Niveaux, Atome).

normaliser(Atome, Forme) :-
    analyser(Atome, N),
    ecrire(N, Forme).

ancetre_syntaxique(Atome, Ancetre) :-
    analyser(Atome, N),
    prefixe_notation(N, P),
    ecrire(P, Ancetre).

parent_syntaxique(Atome, Parent) :-
    analyser(Atome, N),
    N \= composee(_),
    retirer_dernier(N, P),
    P \== [],
    ecrire(P, Parent).

profondeur(Atome, Profondeur) :-
    analyser(Atome, N),
    (   N = composee(Parties)
    ->  maplist(length, Parties, Ls), sum_list(Ls, Profondeur)
    ;   length(N, Profondeur)
    ).

sans_cle(Atome, Base) :-
    analyser(Atome, N),
    retirer_cles(N, B),
    ecrire(B, Base).

% --- Préfixes -------------------------------------------------------------------------------------------------------

% Les ancêtres d'une notation simple sont ses préfixes non vides ; une clé à suffixe de plusieurs niveaux donne un
% ancêtre par niveau du suffixe. Ceux d'une composée sont les ancêtres de chacune de ses parties, et elle-même.
prefixe_notation(composee(Parties), P) :- !,
    (   P = composee(Parties)
    ;   member(Partie, Parties), prefixe_simple(Partie, P)
    ).
prefixe_notation(N, P) :-
    prefixe_simple(N, P).

prefixe_simple(Niveaux, P) :-
    append(Avant, [cle(S)], Niveaux), !,
    (   prefixe_simple(Avant, P)
    ;   append(Sp, _, S), Sp \== [], append(Avant, [cle(Sp)], P)
    ).
prefixe_simple(Niveaux, P) :-
    append(P, _, Niveaux),
    P \== [].

retirer_dernier(N, P) :-
    append(Avant, [cle(S)], N), !,
    (   append(S1, [_], S), S1 \== []
    ->  append(Avant, [cle(S1)], P)
    ;   P = Avant
    ).
retirer_dernier(N, P) :-
    append(P, [_], N).

retirer_cles(composee(Ps), composee(Bs)) :- !, maplist(retirer_cles, Ps, Bs).
retirer_cles(N, B) :- exclude(est_cle, N, B).

est_cle(cle(_)).

% --- Analyse --------------------------------------------------------------------------------------------------------

notation(N) -->
    blanks, simple(P), blanks,
    (   ":"
    ->  plus_de_parties(Ps), { N = composee([P|Ps]) }
    ;   { N = P }
    ).

plus_de_parties([P|Ps]) -->
    blanks, simple(P), blanks,
    (   ":" -> plus_de_parties(Ps) ; { Ps = [] } ).

% division, puis la suite (chiffres, lettres, parenthèse, chiffres, clés)
simple([chiffre(D)|R]) -->
    chiffre(D), suite(R).

suite(R) --> blancs_internes, element(E), !, { R = [E|R1] }, suite(R1).
suite([]) --> [].

element(chiffre(D)) --> chiffre(D).
element(X) --> lettre_ou_double(X).
element(cle(S)) --> "(+", blanks, suffixe(S), blanks, ")".
element(gabarit) --> "(...)".
element(nom(T)) --> "(", texte_nom(Cs), ")", { Cs \== [], nettoyer(Cs, T) }.

% Une lettre doublée est un seul niveau ; deux lettres différentes ne se suivent jamais.
lettre_ou_double(double(L)) --> lettre(L), lettre(L), !.
lettre_ou_double(lettre(L)) --> lettre(L).

chiffre(D) --> [C], { code_type(C, digit(D)) }.

lettre(L) --> [C], { C >= 0'A, C =< 0'Z, C =\= 0'J, char_code(L, C) }.

% espaces de l'édition imprimée entre deux éléments
blancs_internes --> " ", !, blancs_internes.
blancs_internes --> [].

% suffixe de clé : chiffres, éventuellement suivis d'un nom ou d'un gabarit (« 52(GYROSCOPE) », « 21(...) »)
suffixe([chiffre(D)|R]) --> chiffre(D), suffixe_suite(R).
suffixe_suite([chiffre(D)|R]) --> chiffre(D), !, suffixe_suite(R).
suffixe_suite([gabarit]) --> "(...)", !.
suffixe_suite([nom(T)]) --> "(", texte_nom(Cs), ")", !, { Cs \== [], nettoyer(Cs, T) }.
suffixe_suite([]) --> [].

% texte d'un nom : tout sauf les parenthèses (aucune parenthèse imbriquée dans les données)
texte_nom([C|Cs]) --> [C], { C \== 0'(, C \== 0') }, !, texte_nom(Cs).
texte_nom([]) --> [].

nettoyer(Codes, Atome) :-
    atom_codes(A0, Codes),
    normalize_space(atom(Atome), A0).

% --- Écriture -------------------------------------------------------------------------------------------------------

ecrire_simple(Niveaux, Atome) :-
    maplist(texte_niveau, Niveaux, Textes),
    atomic_list_concat(Textes, Atome).

texte_niveau(chiffre(D), T) :- atom_number(T, D).
texte_niveau(lettre(L), L).
texte_niveau(double(L), T) :- atom_concat(L, L, T).
texte_niveau(gabarit, '(...)').
texte_niveau(nom(N), T) :- atomic_list_concat(['(', N, ')'], T).
texte_niveau(cle(S), T) :-
    maplist(texte_niveau, S, Ts),
    atomic_list_concat(['(+'|Ts], T0),
    atom_concat(T0, ')', T).
