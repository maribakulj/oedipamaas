/*  Décomposition des libellés anglais d'Iconclass (conception 1.0, § 5, pièce 2, contenu 3).

    Syntaxe interne d'un libellé, lue dans les données (aucune liste écrite pour un corpus) :
        libellé     ::= partie (" - " partie)*         les parties d'un libellé fabriqué : la notation propre, puis
                                                        le libellé de son gabarit (catégorie d'épisode, sens d'une
                                                        lettre doublée…)
        partie      ::= proposition ("; " proposition)*   synonymes, attributs possibles, indices visuels, suite
        proposition ::= [titre ": "] corps             titre puis spécification ou récit
        corps       ::= concept [" ~ " contexte]
    et des consignes : « : Use N » (notation dépréciée, N préférée), « (N.B. secondary notation(s) only) », un
    libellé qui commence par « other » (notation résiduelle). Les séparateurs ne comptent qu'hors des parenthèses.

    Mots pleins : minuscules, lettres seules, trois lettres au moins, hors des mots vides (liste fixe ci-dessous, faits
    de langue). Mots propres d'une notation : ses mots pleins absents du libellé de son parent ; c'est ce qui la
    distingue de ses sœurs (spécialisation).
*/
:- module(libelles, [ partie/3,               % ?N, ?I, ?Texte        I-ième partie (« - »), à partir de 1
                      propositions/2,         % +N, -Liste            propositions de la première partie
                      principal/2,            % ?N, ?Texte            première proposition de la première partie
                      elements/2,             % ?N, -Textes           ce qui nomme N à lui seul (alternatives)
                      precisions/2,           % ?N, -Textes           éléments des parenthèses de la principale
                      mots_hors_parentheses/2, % ?N, -Mots            mots pleins du libellé, parenthèses ôtées
                      titre_et_suite/3,       % ?N, ?Titre, ?Suite    proposition principale « titre: suite »
                      concept_contexte/3,     % ?N, ?Concept, ?Contexte   « concept ~ contexte »
                      attributs_possibles/2,  % ?N, -Attributs        « possible attributes: a, b (c), d »
                      indice_visuel/2,        % ?N, ?Proposition      usually, sometimes, often
                      consigne/2,             % ?N, ?Consigne         secondaire, preferer(M), residuel
                      mots_pleins/2,          % +Texte, -Mots
                      mot_vide/1,             % ?Mot                  mots vides (faits de langue, liste fixe)
                      mots_du_libelle/2,      % ?N, -Mots             mots pleins de tout le libellé anglais
                      mots_propres/2,         % ?N, -Mots             mots pleins absents du libellé du parent
                      mots_distinctifs/2      % ?N, -Mots             mots propres absents des libellés des sœurs
                    ]).

:- use_module(arbre).

libelle_en(N, T) :- iconclass:libelle(N, en, T).

% --- Découpage hors parenthèses ------------------------------------------------------------------------------------

% decouper(+Texte, +Separateur, -Morceaux) : morceaux rognés, au niveau 0 des parenthèses
decouper(Texte, Sep, Morceaux) :-
    atom_codes(Texte, Cs), atom_codes(Sep, Ss),
    decouper_codes(Cs, Ss, 0, [], Ms0),
    maplist(rogner, Ms0, Morceaux).

decouper_codes([], _, _, Acc, [M]) :- !, reverse(Acc, M).
decouper_codes(Cs, Ss, 0, Acc, [M|Ms]) :-
    append(Ss, Reste, Cs), !,
    reverse(Acc, M),
    decouper_codes(Reste, Ss, 0, [], Ms).
decouper_codes([C|Cs], Ss, P, Acc, Ms) :-
    (   C == 0'( -> P1 is P + 1
    ;   C == 0'), P > 0 -> P1 is P - 1
    ;   P1 = P
    ),
    decouper_codes(Cs, Ss, P1, [C|Acc], Ms).

rogner(Codes, Atome) :-
    atom_codes(A, Codes),
    normalize_space(atom(Atome), A).

% --- Parties, propositions ------------------------------------------------------------------------------------------

partie(N, I, Texte) :-
    libelle_en(N, T),
    decouper(T, ' - ', Ps),
    nth1(I, Ps, Texte).

propositions(N, Props) :-
    partie(N, 1, P),
    decouper(P, '; ', Props).

principal(N, Texte) :-
    propositions(N, [P0|_]),
    sans_consigne(P0, Texte).

% « titre : Use … » et « (N.B. …) » ne font pas partie du sens
sans_consigne(P, Texte) :-
    (   sub_atom(P, B, _, _, ' : Use ') -> sub_atom(P, 0, B, _, T1) ; T1 = P ),
    (   sub_atom(T1, B2, _, _, ' (N.B.') -> sub_atom(T1, 0, B2, _, T2) ; T2 = T1 ),
    normalize_space(atom(Texte), T2).

% elements(?N, -Textes) : les textes dont chacun, à lui seul, nomme ce que désigne N, pour un libellé simple (sans
% « - ») : les propositions de la première partie (synonymes séparés par « ; »), sauf les attributs possibles et les
% indices visuels ; dans chacune, la spécification après « titre: » (« insects: butterfly »), le concept avant « ~ »
% (« wine ~ alcoholic drinks »), sans les précisions entre parenthèses ; puis ses éléments séparés par « , »
% (« jar, jug (used as drinking-vessel) » : « jar », « jug »).
elements(N, Textes) :-
    libelle_en(N, T0),
    sans_consigne(T0, T),
    decouper(T, ' - ', [Partie]),
    decouper(Partie, '; ', Props),
    findall(E, ( member(P, Props), nommante(P), corps_nommant(P, C0), hors_parentheses(C0, C),
                 decouper(C, ', ', Es), member(E, Es), E \== '' ), Textes).

% precisions(?N, -Textes) : les éléments des parenthèses de la proposition principale, séparés par « , », « and » et
% « or » (« historical persons (portraits and scenes from the life) » : « portraits », « scenes from the life »)
precisions(N, Textes) :-
    principal(N, P),
    corps_nommant(P, C),
    findall(E, ( entre_parentheses(C, X), decouper(X, ', ', Xs), member(X1, Xs),
                 atomic_list_concat(Ys, ' and ', X1), member(Y, Ys), atomic_list_concat(Zs, ' or ', Y),
                 member(Z, Zs), normalize_space(atom(E), Z), E \== '' ), Textes).

% les mots du libellé hors parenthèses : un parent énumère souvent ses enfants entre parenthèses (« insignia and
% symbols of sovereignty (crown, diadem, sceptre…) ») ; ces mots-là n'appartiennent pas au parent
mots_hors_parentheses(N, Mots) :-
    libelle_en(N, T0),
    sans_consigne(T0, T),
    hors_parentheses(T, S),
    mots_pleins(S, Mots).

nommante(P) :-
    \+ sub_atom(P, _, _, _, 'possible attributes'),
    mots_pleins(P, Ms),
    \+ ( member(M, Ms), memberchk(M, [usually, sometimes, often]) ).

corps_nommant(P, C) :-
    (   decouper(P, ': ', [_, S0|Rs]) -> atomic_list_concat([S0|Rs], ': ', S) ; S = P ),
    (   decouper(S, ' ~ ', [C0, _|_]) -> C = C0 ; C = S ).

% le texte sans ce qui est entre parenthèses (à tous les niveaux)
hors_parentheses(T, S) :-
    atom_codes(T, Cs),
    hors(Cs, 0, Ds),
    atom_codes(S0, Ds),
    normalize_space(atom(S), S0).

hors([], _, []).
hors([C|Cs], P, Ds) :-
    (   C == 0'( -> P1 is P + 1, Ds = Ds1
    ;   C == 0'), P > 0 -> P1 is P - 1, Ds = Ds1
    ;   P > 0 -> P1 = P, Ds = Ds1
    ;   P1 = P, Ds = [C|Ds1]
    ),
    hors(Cs, P1, Ds1).

% entre_parentheses(+T, -X) : le contenu de chaque parenthèse de premier niveau
entre_parentheses(T, X) :-
    atom_codes(T, Cs),
    dedans(Cs, 0, [], Xs),
    member(X0, Xs),
    atom_codes(X1, X0),
    normalize_space(atom(X), X1).

dedans([], _, _, []).
dedans([C|Cs], P, Acc, Xs) :-
    (   C == 0'(, P =:= 0 -> dedans(Cs, 1, [], Xs)
    ;   C == 0'( -> P1 is P + 1, dedans(Cs, P1, [C|Acc], Xs)
    ;   C == 0'), P =:= 1 -> reverse(Acc, X), Xs = [X|Xs1], dedans(Cs, 0, [], Xs1)
    ;   C == 0'), P > 1 -> P1 is P - 1, dedans(Cs, P1, [C|Acc], Xs)
    ;   P > 0 -> dedans(Cs, P, [C|Acc], Xs)
    ;   dedans(Cs, P, Acc, Xs)
    ).

titre_et_suite(N, Titre, Suite) :-
    principal(N, P),
    decouper(P, ': ', [Titre, Suite0|Rs]),
    atomic_list_concat([Suite0|Rs], ': ', Suite).

concept_contexte(N, Concept, Contexte) :-
    principal(N, P),
    decouper(P, ' ~ ', [Concept, Contexte]).

% « possible attributes: a, b (c, d), e » ou « possible attributes of X (…): a, b »
attributs_possibles(N, Attributs) :-
    propositions(N, Props),
    once(( member(Prop, Props), sub_atom(Prop, B, L, _, 'possible attributes') )),
    Debut is B + L,
    sub_atom(Prop, Debut, _, 0, Reste),
    (   sub_atom(Reste, D, _, _, ': ') -> D1 is D + 2, sub_atom(Reste, D1, _, 0, Liste) ; Liste = Reste ),
    decouper(Liste, ', ', Attributs0),
    exclude(==(''), Attributs0, Attributs).

indice_visuel(N, Prop) :-
    libelle_en(N, T),
    decouper(T, '; ', Props),
    member(Prop, Props),
    mots_pleins(Prop, Ms),
    once((member(M, Ms), memberchk(M, [usually, sometimes, often]))).

consigne(N, preferer(M)) :-
    libelle_en(N, T),
    sub_atom(T, B, L, _, ' : Use '), Debut is B + L,
    sub_atom(T, Debut, _, 0, M0),
    normalize_space(atom(M1), M0),
    (   notation:normaliser(M1, M) -> true ; M = M1 ).
consigne(N, secondaire) :-
    libelle_en(N, T),
    sub_atom(T, _, _, _, 'N.B. secondary notation').
consigne(N, residuel) :-
    libelle_en(N, T),
    sub_atom(T, 0, _, _, 'other ').

% --- Mots -----------------------------------------------------------------------------------------------------------

mot_vide(M) :- memberchk(M, [the, and, for, with, from, into, onto, upon, their, they, them, this, that, which, other,
                             others, some, being, been, have, having, also, such, when, where, while, about, over,
                             under, after, before, between, without, within, against, through, there, here, these,
                             those, his, her, its, who, has, was, are, not, but, him, she, one, etc,
                             of, in, on, at, to, is, an, as, by, or, be, it, a, he, we, us, if, so, no, do]).

mots_pleins(Texte, Mots) :-
    downcase_atom(Texte, T),
    split_string(T, "", "", [S]),
    re_split_lettres(S, Morceaux),
    include(plein, Morceaux, Mots0),
    sort(Mots0, Mots).

re_split_lettres(S, Morceaux) :-
    string_codes(S, Cs),
    phrase(morceaux(Ms), Cs),
    maplist([C, A]>>atom_codes(A, C), Ms, Morceaux).

morceaux([M|Ms]) --> lettres(M), { M \== [] }, !, separateurs, morceaux(Ms).
morceaux(Ms) --> [_], !, separateurs, morceaux(Ms).
morceaux([]) --> [].
lettres([C|Cs]) --> [C], { code_type(C, alpha), \+ code_type(C, digit(_)), C \== 0'_ }, !, lettres(Cs).
lettres([]) --> [].
separateurs --> [C], { \+ code_type(C, alpha) }, !, separateurs.
separateurs --> [].

plein(M) :- atom_length(M, L), L >= 3, \+ mot_vide(M).

mots_du_libelle(N, Mots) :-
    libelle_en(N, T),
    mots_pleins(T, Mots).

% sur tout le libellé (sans ses consignes) : dans un libellé fabriqué, ce qui distingue la notation de ses sœurs est
% souvent dans la seconde partie (la catégorie d'épisode), la première reprenant la personne
mots_propres(N, Mots) :-
    libelle_en(N, T),
    sans_consigne(T, T1),
    mots_pleins(T1, Ms),
    (   arbre:parent(N, Parent), libelle_en(Parent, TP)
    ->  mots_pleins(TP, MP), ord_subtract(Ms, MP, Mots)
    ;   Mots = Ms
    ).

% ce qui distingue une notation de ses sœurs : ses mots propres qu'aucune sœur ne porte (la catégorie d'épisode d'un
% libellé fabriqué, l'espèce, la posture…), au cœur de la spécialisation
mots_distinctifs(N, Mots) :-
    mots_propres(N, Ms),
    (   arbre:parent(N, P)
    ->  findall(S, (iconclass:enfant(P, S, _), S \== N, arbre:parent(S, P)), Soeurs),
        foldl(retirer_mots_de, Soeurs, Ms, Mots)
    ;   Mots = Ms
    ).

retirer_mots_de(S, Ms0, Ms) :-
    (   mots_du_libelle(S, MS) -> ord_subtract(Ms0, MS, Ms) ; Ms = Ms0 ).
