/*  Les définitions des notations d'Iconclass (docs/FONDEMENTS.md, § 3 ; étape 1 de § 9), dans le langage des
    assertions, selon le type du libellé (libelles_iconclass:type_de_libelle/4) :

      classe    une union de têtes : un référent dont le type est l'une d'elles, avec ses modificateurs exigés
                (« dead bird » : bird + dead) et ses compléments (« woman with a child »)
      individu  un nom et ses variantes (« Lucy (Lucia) », le nom français) ; la description biographique (« apostle »,
                « first bishop of Rome ») n'est qu'une contrainte de compatibilité
      recit     la personne du récit (« (story of) Hercules (Heracles) »)
      attribut  un attribut et son porteur (« attributes of Cupid: blindfold »)
      genre     un genre ou un mode de l'œuvre (« landscapes », « portrayed alone »)
      concept   une idée personnifiée (« Loneliness; 'Solitudine' (Ripa) ») : têtes et titres cités
      scene     le graphe que le lecteur des textes tire du libellé (référents, événements, rôles, relations)
      rubrique  rien

    La lecture des classes, individus, attributs, genres et concepts suit la grammaire des libellés (têtes, « : »,
    énumérations, noms à majuscule) et non le lecteur des textes, qui n'est pas fait pour eux (même langage, pas même
    analyseur : FONDEMENTS § 3.1) ; celle des scènes passe par le lecteur des textes, et sa justesse se mesure.

    definition(+N, +Langue, -Def)
        Def = def(Type, Conditions, Marques)
        Conditions, termes :
          tete(R, [Mot…])               le référent R a pour type l'un de ces mots (union)
          nom(R, [Nom…])                le référent R porte l'un de ces noms (normalisés : PETER, LUCIA)
          propriete(R, Mot)             une propriété exigée du référent R
          complement(R, Rel, R2)        R est complété par R2 (« with », « avec », « of »)
          porteur(R, R2)                R est un attribut de R2
          compatible(R, Mot)            une description qui ne doit pas être contredite (individus)
          personne([Nom…])              la personne du récit ou de l'individu dont la notation fait partie (héritage, § 3.4)
          assertions(Faits)             le graphe d'une scène, assertions du lecteur
        Marques : celles du prétraitement (libelles_iconclass:pretraiter/3) de la partie propre.
*/
:- module(definitions, [ definition/3 ]).
:- encoding(utf8).
:- use_module(arbre).
:- use_module(library(pcre)).
:- use_module(library(yall)).
:- use_module(library(apply)).
:- use_module(library(lists)).
:- use_module(raisonnement, []).
:- use_module(interpretation, []).
:- use_module(libelles_iconclass, []).

definition(N, L, def(Type, Cs, Ms)) :-
    libelles_lus:type(N, Type),
    libelles_lus:partie(N, L, 1, _, Net, Ms, Ph), !,
    conditions(Type, N, L, Net, Ph, Ms, Cs0),
    heritage(Type, N, L, Hs),
    append(Cs0, Hs, Cs).

% --- Les mots d'une partie analysée ---------------------------------------------------------------------------------

mots([phrase(Ms)|_], Ms).                           % un libellé est une phrase (une partie propre)

% le lemme d'un mot ; en anglais, un nom passe par la morphologie de WordNet (« beasts » → beast)
% en français, sans lexique, le lemme d'UDPipe n'est gardé que s'il est attesté comme forme dans les libellés français
% (« bandeau » → « bandeare » ne l'est pas : on garde la forme), comme pour les profils (sujets.pl)
lemme(mot(_, F, L0, C, _, _, _, _, _), L) :-
    ( C == 'PROPN' -> L1 = F ; L1 = L0 ), downcase_atom(L1, L2),
    downcase_atom(F, Fm),
    (   C == 'NOUN', catch(morphologie:lemmes(Fm, n, [L3|_]), _, fail), \+ wordnet:s(_, _, L2, n, _, _) -> L = L3
    ;   C == 'NOUN', L2 \== Fm, \+ wordnet:s(_, _, L2, _, _, _), \+ forme_fr(L2) -> L = Fm
    ;   L = L2
    ).

:- table forme_fr/1.
forme_fr(W) :- formes_fr(Fs), memberchk(W, Fs).
:- table formes_fr/1.
formes_fr(Fs) :-
    findall(W, ( libelles_lus:partie(_, fr, _, _, _, _, Ph), member(phrase(Ms), Ph),
                 member(mot(_, F, _, _, _, _, _, _, _), Ms), downcase_atom(F, W) ), Ws),
    sort(Ws, Fs).

nominal(mot(_, _, _, C, _, _, _, _, _)) :- memberchk(C, ['NOUN', 'PROPN']).
propre(mot(_, F, _, _, _, _, _, _, _)) :- sub_atom(F, 0, 1, _, C), char_type(C, upper(_)).

% les segments d'une liste de mots, coupés par « , », « ; », « and », « or », « et », « ou » (hors parenthèses, déjà
% retirées)
segments(Ms, Ss) :- segments_(Ms, [], Ss0), exclude(==([]), Ss0, Ss).
segments_([], Acc, [S]) :- reverse(Acc, S).
segments_([M|Ms], Acc, [S|Ss]) :-
    M = mot(_, F, _, _, _, _, _, _, _), downcase_atom(F, W), memberchk(W, [',', ';', and, or, et, ou, '&']), !,
    reverse(Acc, S), segments_(Ms, [], Ss).
segments_([M|Ms], Acc, Ss) :- segments_(Ms, [M|Acc], Ss).

% après le dernier « : », le terme défini (« beasts of prey, predatory animals: lion ») ; sinon tout
defini(Ms, D) :- ( append(_, [mot(_, ':', _, _, _, _, _, _, _)|D0], Ms), \+ memberchk(mot(_, ':', _, _, _, _, _, _, _), D0) -> D = D0 ; D = Ms ).
avant_deux_points(Ms, A) :- ( append(A, [mot(_, ':', _, _, _, _, _, _, _)|_], Ms) -> true ; A = Ms ).

% la tête d'un segment : en anglais, le dernier nom avant la première préposition (« beasts of prey » : beasts ;
% « predatory animals » : animals) ; en français, le premier nom (« arbre fruitier », « femme avec un enfant »)
tete_segment(en, S, T, Avant, Apres) :-
    ( append(Av0, [P|Ap], S), P = mot(_, _, _, 'ADP', _, _, _, _, _), Av0 \== [] -> true ; Av0 = S, Ap = [], P = none ),
    include(nom_ou_connu, Av0, Ns), last(Ns, T), append(Avant, [T|_], Av0),
    ( P == none -> Apres = [] ; Apres = [P|Ap] ).
tete_segment(fr, S, T, Avant, Apres) :-
    append(Avant, [T|Apres], S), nom_ou_connu(T), !.

% un nom, ou un mot que l'étiqueteur a mal rangé sur un libellé d'un seul mot et que WordNet connaît comme nom
% (« hill » rangé en verbe)
nom_ou_connu(M) :- nominal(M), !.
nom_ou_connu(mot(_, F, _, C, _, _, _, _, _)) :-
    memberchk(C, ['VERB', 'ADJ', 'ADP', 'X', 'ADV', 'INTJ', 'NUM', 'SYM', 'DET', 'PRON']), downcase_atom(F, W),
    ( catch(morphologie:lemmes(W, n, [_|_]), _, fail) -> true ; wordnet:s(_, _, W, n, _, _) ).

modificateurs(Avant, Apres, Ps) :-
    findall(W, ( member(M, Avant), M = mot(_, _, _, 'ADJ', _, _, _, _, _), lemme(M, W) ), P1),
    findall(W, ( member(M, Apres), M = mot(_, _, _, 'ADJ', _, _, _, _, _), \+ apres_preposition(Apres, M), lemme(M, W) ), P2),
    append(P1, P2, Ps).
apres_preposition(Apres, M) :- append(A, [M|_], Apres), member(mot(_, _, _, 'ADP', _, _, _, _, _), A).

% les compléments prépositionnels d'une tête : « with a child » → complement(R, with, R2), tete(R2, [child])
complements(R, Apres, Cs) :-
    findall(C, complement_(R, Apres, C), Cs0), append(Cs0, Cs).
complement_(R, Apres, [complement(R, Rel, R2), tete(R2, [W])]) :-
    append(_, [P|Reste], Apres), P = mot(I, _, _, 'ADP', _, _, _, _, _), lemme(P, Rel),
    \+ memberchk(Rel, [of, de, du, des, 'd\'']),                 % « of » fait partie du nom (« beasts of prey »)
    append(_, [T|_], Reste), nominal(T), \+ propre(T), lemme(T, W), !,
    atomic_list_concat([c, I], '_', R2).

% les noms propres d'une liste de mots : les suites de mots à majuscule (avec « of », « the », « de » entre deux)
noms(Ms, Ks) :-
    findall(K, ( suite_propre(Ms, S), noms_de(S, K) ), Ks0), sort(Ks0, Ks).
suite_propre(Ms, S) :-
    append(Avant, [M|Reste], Ms), propre(M), \+ dans_une_suite(Avant),
    suite(Reste, S1), S = [M|S1].
% le mot précédent est à majuscule, ou c'est un lien (« of », « de ») précédé d'un mot à majuscule : on est dans un nom
dans_une_suite(Avant) :- last(Avant, P), propre(P), !.
dans_une_suite(Avant) :-
    append(_, [P, Li], Avant), propre(P), Li = mot(_, F, _, _, _, _, _, _, _), downcase_atom(F, W), memberchk(W, [of, the, de, du]).
suite([M|Ms], [M|S]) :- propre(M), !, suite(Ms, S).
suite([L, M|Ms], [L, M|S]) :- L = mot(_, F, _, _, _, _, _, _, _), downcase_atom(F, W), memberchk(W, [of, the, de, du]), propre(M), !, suite(Ms, S).
suite(_, []).
noms_de(S, K) :-
    findall(F, member(mot(_, F, _, _, _, _, _, _, _), S), Fs0),
    exclude(titre, Fs0, Fs), Fs \== [],
    atomic_list_concat(Fs, ' ', Nom0), raisonnement:normaliser_nom(Nom0, K0),
    atom_codes(K0, Cs0), exclude([C]>>memberchk(C, `;:,.`), Cs0, Cs), atom_codes(K1, Cs), normalize_space(atom(K), K1),
    K \== ''.
titre(F) :- downcase_atom(F, W), memberchk(W, ['st.', st, saint, sainte, ste, 'ste.', 's.']).

% --- Les conditions, par type ---------------------------------------------------------------------------------------

conditions(rubrique, _, _, _, _, _, []).
conditions(classe, _, L, _, Ph, Ms, Cs) :-
    mots(Ph, Ws0), defini(Ws0, Ws), segments(Ws, Ss),
    findall(seg(Tete, Ps, Co), ( member(S, Ss), tete_segment(L, S, T, Av, Ap), lemme(T, Tete),
                                 modificateurs(Av, Ap, Ps), complements(r, Ap, Co) ), Segs),
    Segs \== [],
    findall(Te, member(seg(Te, _, _), Segs), Tetes0), sort(Tetes0, Tetes),
    (   Segs = [seg(_, Ps1, Co1)] -> findall(propriete(r, P), member(P, Ps1), Pc), append([[tete(r, Tetes)], Pc, Co1], Cs0)
    ;   Cs0 = [tete(r, Tetes)]                       % une union : les modificateurs propres à chaque tête ne sont pas
    ),                                               % exigés de l'union (précision : on garde la seule tête commune)
    nom_et_type(Ms, Ph, Cs0, Cs).
% les noms d'un individu : ceux du premier segment de sa partie propre (« the apostle Peter », pas « first bishop of
% Rome »), le nom de la notation, ses variantes (parenthèses, autre langue) ; un gabarit a un nom à remplir
conditions(individu, N, L, _, Ph, Ms, Cs) :-
    mots(Ph, Ws), avant_deux_points(Ws, Ws0), premier_segment(Ws0, Ws1), noms(Ws1, Ks0),
    findall(K, ( member(variante(V), Ms), raisonnement:normaliser_nom(V, K) ), Vs),
    nom_de_la_notation(N, Kn),
    append([Kn, Ks0, Vs], Ks1), sort(Ks1, Ks),
    findall(compatible(r, W), ( member(M, Ws0), M = mot(_, _, _, 'NOUN', _, _, _, _, _), \+ propre(M), lemme(M, W) ), Cp),
    autre_langue(N, L, Ka),
    append(Ks, Ka, Ks2), sort(Ks2, Ks3),
    (   Ks3 \== [] -> Cs0 = [nom(r, Ks3)|Cp]
    ;   sub_atom(N, _, _, _, '(...)') -> Cs0 = [nom(r, a_remplir)|Cp]
    ),
    aspects(N, L, As), append(Cs0, As, Cs).

conditions(recit, N, L, Net, Ph, Ms, Cs) :- conditions(individu, N, L, Net, Ph, Ms, Cs).
conditions(attribut, _, L, _, Ph, _, [porteur(r, p)|Cs]) :-
    mots(Ph, Ws), avant_deux_points(Ws, Av), defini(Ws, D),
    ( noms(Av, [K|_]) -> Porteur = [nom(p, [K])] ; append(_, [mot(_, De, _, _, _, _, _, _, _)|Ap], Av), downcase_atom(De, Dm),
      memberchk(Dm, [of, de, du, des]), include(nominal, Ap, [T|_]) -> lemme(T, W), Porteur = [tete(p, [W])] ; Porteur = [] ),
    segments(D, Ss),
    findall(Te, ( member(S, Ss), tete_segment(L, S, T, _, _), lemme(T, Te) ), Tetes0), sort(Tetes0, Tetes), Tetes \== [],
    append([tete(r, Tetes)], Porteur, Cs).
conditions(genre, _, L, _, Ph, _, [genre(Tetes)]) :-
    mots(Ph, Ws), segments(Ws, Ss),
    findall(Te, ( member(S, Ss), ( tete_segment(L, S, T, _, _) -> true ; member(T, S), T = mot(_, _, _, 'VERB', _, _, _, _, _) ),
                  lemme(T, Te) ), Tetes0), sort(Tetes0, Tetes).
conditions(concept, _, L, Net, Ph, _, [concept(Tetes)|Ns]) :-
    mots(Ph, Ws), segments(Ws, Ss),
    findall(Te, ( member(S, Ss), \+ cite(S), tete_segment(L, S, T, _, _), lemme(T, Te) ), Tetes0), sort(Tetes0, Tetes),
    findall(nom(r, [K]), titre_cite(Net, K), Ns).
conditions(scene, _, L, Net, Ph, _, [assertions(Fs)]) :-
    interpretation:interpreter(Net, L, description, Ph, Fs0),
    include(utile, Fs0, Fs).

premier_segment(Ws, S) :- segments_(Ws, [], [S|_]), !.
premier_segment(Ws, Ws).

% les parties de gabarit d'une notation (« - miraculous activities and events », « - portrayed alone ») : un aspect
% exigé, par ses têtes
aspects(N, L, As) :-
    findall(aspect(T, Tetes), ( libelles_lus:aspect(N, R, T), libelles_lus:partie(N, L, R, gabarit, _, _, Ph),
                                mots(Ph, Ws), segments(Ws, Ss),
                                findall(Te, ( member(S, Ss), tete_d_aspect(T, L, S, Tt), lemme(Tt, Te) ), Tetes0),
                                sort(Tetes0, Tetes), Tetes \== [] ), As).

% la tête d'un aspect de genre ou de mode est son mot de représentation (« portrayed alone » : portray)
tete_d_aspect(genre, _, S, T) :- member(T, S), lemme(T, W), ( libelles_iconclass:genre(W) ; libelles_iconclass:genre_mode(W) ), !.
tete_d_aspect(_, L, S, T) :- tete_segment(L, S, T, _, _).
% un segment entre guillemets (un titre de Ripa : « 'Solitudine' »)
cite(S) :- member(mot(_, F, _, _, _, _, _, _, _), S), memberchk(F, ['\'', '‘', '’', '"']), !.
titre_cite(Net, K) :-
    atom_string(Net, S), re_foldl(cite_, "'(?<t>[^']+)'", S, [], Ks0, []),
    member(K1, Ks0), raisonnement:normaliser_nom(K1, K).
cite_(M, A, [T|A]) :- get_dict(t, M, T).

utile(F) :- F =.. [P|_], memberchk(P, [entite, nom, propriete, evenement, role, relation, modalite, polarite, alternative,
                                        coref]).

% « Mercury (planet) » : le type d'un nom
nom_et_type(Ms, Ph, Cs0, Cs) :-
    (   memberchk(type(T), Ms), mots(Ph, Ws), noms(Ws, [K|_])
    ->  Cs = [nom(r, [K]), tete(r, [T])]
    ;   Cs = Cs0
    ).

% le nom d'une notation à nom : 11H(PETER) → PETER ; 61B2(PETRARCA, Francesco) → PETRARCA FRANCESCO
nom_de_la_notation(N, [K]) :-
    sub_atom(N, B, 1, _, '('), sub_atom(N, _, 1, 0, ')'), B1 is B + 1, sub_atom(N, B1, _, 1, Nom),
    Nom \== '...', \+ sub_atom(Nom, 0, 1, _, '+'), !,
    raisonnement:normaliser_nom(Nom, K).
nom_de_la_notation(_, []).

% les noms de la même notation dans l'autre langue (« Pierre » pour PETER) : variantes du même individu
autre_langue(N, L, Ks) :-
    ( L == en -> L2 = fr ; L2 = en ),
    (   libelles_lus:partie(N, L2, 1, _, _, Ms, Ph)
    ->  mots(Ph, Ws), avant_deux_points(Ws, Ws0), premier_segment(Ws0, Ws1), noms(Ws1, Ks0),
        findall(K, ( member(variante(V), Ms), raisonnement:normaliser_nom(V, K) ), Vs), append(Ks0, Vs, Ks)
    ;   Ks = []
    ).

% --- L'héritage (§ 3.4) : la personne du récit ou de l'individu dont la notation fait partie ------------------------

heritage(Type, _, _, []) :- memberchk(Type, [individu, recit, rubrique]), !.
heritage(_, N, L, Hs) :-
    (   arbre:ancetre(N, A), libelles_lus:type(A, TA), memberchk(TA, [individu, recit]),
        definition(A, L, def(_, CsA, _)), memberchk(nom(_, Ks), CsA)
    ->  Hs = [personne(Ks)]
    ;   Hs = []
    ).
