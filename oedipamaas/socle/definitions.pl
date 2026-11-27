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
:- module(definitions, [ definition/3, type_libelle/2 ]).
:- encoding(utf8).
:- use_module(arbre).
:- use_module(library(pcre)).
:- use_module(library(yall)).
:- use_module(library(apply)).
:- use_module(library(lists)).
:- use_module(raisonnement, []).
:- use_module(interpretation, []).
:- use_module(libelles_iconclass, []).
:- use_module(sujets, []).

% Le type est recalculé sur la lecture en cache (libelles_iconclass:type_de_libelle/4) : changer la typologie ne
% demande pas de relire les libellés
:- table type_libelle/2.
type_libelle(N, T) :-
    (   libelles_lus:partie(N, en, 1, _, _, Ms, Ph) -> true ; libelles_lus:partie(N, fr, 1, _, _, Ms, Ph) ),
    once(libelles_iconclass:type_de_libelle(N, Ph, Ms, T)).
aspect_type(N, R, T) :-
    libelles_lus:partie(N, en, R, gabarit, _, Ms, Ph), once(libelles_iconclass:type_de_libelle(N, Ph, Ms, T0)),
    T0 \== individu, ( T0 == rubrique -> T = classe ; T = T0 ).

% La définition est sûre d'abord (FONDEMENTS § 3, décision de la propriétaire du 24/11) : tout ce que le libellé dit
% est exigé, sauf ce que la grammaire d'Iconclass marque comme facultatif (parenthèses, « possible attributes »,
% renvois, alternatives, biographie d'un individu). Une erreur de lecture rend une définition trop forte (un code
% manqué), jamais trop faible (un code faux). L'analyse syntaxique n'ajoute que des contraintes (rôles, porteur).
%   def(Type, Exige, Compatible, Contraintes, Marques)
%     Exige        une liste de groupes, tous exigés ; un groupe : un_de([Alternative…]), une alternative : une liste
%                  d'unités toutes exigées ; une unité : mot(Lemme), nom([Nom…]) (l'un des noms), genre(Lemme) (un
%                  prédicat sur l'œuvre)
%     Compatible   des mots qui ne doivent pas être contredits (la biographie d'un individu)
%     Contraintes  les conditions structurées de la lecture (conditions/7 : rôles d'une scène, porteur d'un attribut)
definition(N, L, def(Type, Exige, Compatible, Contraintes, Ms)) :-
    b_setval(definitions_langue, L),
    type_libelle(N, Type),
    libelles_lus:partie(N, L, 1, _, Net, Ms, Ph), !,
    ( conditions(Type, N, L, Net, Ph, Ms, Cs0) -> true ; Cs0 = [] ),
    exigences_propres(Type, L, Ph, Cs0, Ms, E0),
    exigences_d_aspects(N, L, E1),
    heritage(Type, N, L, Hs),
    findall(un_de([[nom(Ks)]]), member(personne(Ks), Hs), E2),
    exigences_de_parentheses(L, Ms, E3),
    append([E0, E1, E2, E3], Exige),
    Exige \== [],
    findall(W, member(compatible(_, W), Cs0), Compatible),
    exclude(non_structurel, Cs0, Contraintes).

% (la tête, les noms et les propriétés du référent principal r sont déjà dans Exige ; ceux des autres référents, un
% complément « with a child », un porteur « of Cupid », restent : la projection en vérifie la structure)
non_structurel(C) :- C =.. [F|_], memberchk(F, [compatible, genre, concept, aspect, personne]), !.
non_structurel(C) :- C =.. [F, r|_], memberchk(F, [tete, nom, propriete]).

% Une parenthèse en minuscules qui n'est ni une alternative, ni un exemple, ni une définition, ni un renvoi peut porter
% toute la distinction de la notation (« (female) » d'une lettre doublée, « (doctrine on) ») : elle est exigée (sûr
% d'abord ; quand elle n'est qu'un détail, « (high) hill », la définition n'est que trop forte). Ses mots pleins, tous.
exigences_de_parentheses(L, Ms, Gs) :-
    findall(un_de([Us]), ( member(facultatif(C), Ms), mots_de_parenthese(L, C, Us), Us \== [] ), Gs).
mots_de_parenthese(L, C, Us) :-
    split_string(C, " ,;:/", " ,;:/.()'", Ps), exclude(==(""), Ps, Ps1),
    findall(mot(W), ( member(P0, Ps1), atom_string(P, P0), \+ mot_ferme(P), alphabetique(P), \+ metalangage(P),
                      downcase_atom(P, Pm), lemme_simple(L, Pm, W) ), Us0), list_to_set(Us0, Us).
lemme_simple(en, P, W) :- ( catch(morphologie:lemmes(P, n, [W|_]), _, fail) -> true ; W = P ), !.
lemme_simple(_, P, P).

% --- Ce que la partie propre exige, par type -------------------------------------------------------------------------

exigences_propres(rubrique, _, _, _, _, []).
exigences_propres(individu, _, _, Cs, _, [un_de([[nom(a_remplir)]])]) :- memberchk(nom(_, a_remplir), Cs), !.
exigences_propres(Type, _, _, Cs, _, [un_de([[nom(Ks)]])]) :-
    memberchk(Type, [individu, recit]), !, memberchk(nom(_, Ks), Cs), Ks \== a_remplir.
exigences_propres(concept, L, Ph, Cs, _, [un_de(Alts)]) :- !,
    ( memberchk(concept(Tetes), Cs) -> true ; Tetes = [] ),
    findall([nom([K])], member(nom(_, [K]), Cs), Ts),
    mots(Ph, Ws), segments(Ws, Ss),
    findall(A, ( member(S, Ss), \+ cite(S), unites(L, S, A), A \== [] ), As0),
    ( As0 == [] -> findall([mot(T)], member(T, Tetes), As1) ; As1 = As0 ),
    append(As1, Ts, Alts), Alts \== [].
exigences_propres(attribut, L, Ph, Cs, _, [un_de(Alts)|Porteur]) :- !,
    mots(Ph, Ws), defini(Ws, D), segments_complets(L, D, Ss),
    findall(A, ( member(S, Ss), unites(L, S, A), A \== [] ), Alts), Alts \== [],
    (   memberchk(nom(p, Ks), Cs) -> Porteur = [un_de([[nom(Ks)]])]
    ;   memberchk(tete(p, Ws2), Cs) -> findall([mot(W)], member(W, Ws2), Ap), Porteur = [un_de(Ap)]
    ;   Porteur = []
    ).
exigences_propres(Type, L, Ph, _, _, Groupes) :-          % classe, genre, scène
    mots(Ph, Ws0), ( Type == classe -> defini(Ws0, Ws) ; Ws = Ws0 ),
    ( Type == scene -> segments(Ws, Ss) ; segments_complets(L, Ws, Ss) ),
    findall(A, ( member(S, Ss), unites(L, S, A0), genres(Type, A0, A), A \== [] ), As),
    As \== [],
    (   Type == scene -> findall(un_de([A]), member(A, As), Groupes)      % une scène : tout ensemble
    ;   Groupes = [un_de(As)]                                              % une classe, un genre : l'une des têtes
    ).

% dans un libellé de genre, les mots de la représentation sont des prédicats sur l'œuvre
genres(genre, A0, A) :- !, maplist(genre_unite, A0, A).
genres(_, A, A).
genre_unite(mot(W), genre(W)) :- ( libelles_iconclass:genre(W) ; libelles_iconclass:genre_mode(W) ), !.
genre_unite(U, U).

% les parties de gabarit et de « ~ » : chacune exige l'un de ses segments (« martyrdom, suffering, misfortune,
% death » : l'un des quatre), chaque segment avec tous ses mots (« miraculous activities » : miraculous et activity)
% (un aspect qui redit la catégorie du gabarit de la personne, « ~ male saint » pour 11H(PETER)5, est impliqué par la
% personne elle-même : ses mots ne sont pas une condition nouvelle)
exigences_d_aspects(N, L, Gs) :-
    mots_du_gabarit_de_personne(N, L, Mg),
    findall(un_de(As), ( libelles_lus:partie(N, L, R, gabarit, Net, _, Ph), R > 1, \+ lettres_doublees(Net),
                         mots(Ph, Ws), segments_complets(L, Ws, Ss),
                         findall(A, ( member(S, Ss), unites(L, S, A0), exclude(impliquee(Mg), A0, A1),
                                      maplist(genre_unite, A1, A), A \== [] ), As),      % « portrayed » : sur l'œuvre
                         As \== [] ), Gs).

impliquee(Mg, mot(W)) :- memberchk(W, Mg), !.
impliquee(Mg, mot(W)) :- atomic_list_concat(Ps, ' ', W), Ps = [_, _|_], forall(member(P, Ps), ( memberchk(P, Mg) ; mot_ferme(P) )).

% les mots du libellé du gabarit de la personne dont la notation relève (11H(...) « male saints (with NAME) » :
% male, saint)
mots_du_gabarit_de_personne(N, L, Mg) :-
    (   libelles_iconclass:gabarit_ou_soi(N, G), libelles_iconclass:gabarit_de_personnes(N),
        libelles_lus:partie(G, L, 1, _, _, _, Ph)
    ->  mots(Ph, Ws), findall(W, ( member(M, Ws), M = mot(_, F, _, _, _, _, _, _, _), \+ mot_ferme(F), alphabetique(F),
                                    lemme(M, W) ), Mg)
    ;   Mg = []
    ).

% les unités d'un segment : ses noms propres (une suite de mots à majuscule, un nom), ses composés (WordNet en
% anglais, mots clés d'Iconclass en français), ses mots pleins ; ni mots des classes fermées, ni ponctuation
unites(L, S, Us) :-
    noms(S, Ks), findall(nom([K]), member(K, Ks), Un),
    findall(I, ( member(M, S), propre(M), M = mot(I, _, _, _, _, _, _, _, _) ), Ip),
    unites_mots(L, S, S, Ip, Um),
    append(Un, Um, Us0), list_to_set(Us0, Us).

% le métalangage d'Iconclass (« specific aspects », « etc. », « other ») ne décrit pas l'image : il n'est pas exigé
metalangage(F) :- downcase_atom(F, W), memberchk(W, [aspect, aspects, specific, etc, other, others, autre, autres, aspects]).

unites_mots(_, _, [], _, []).
unites_mots(L, S, [M|Ms], Couverts, Us) :-
    M = mot(I, F, _, _, _, _, _, _, _),
    (   ( memberchk(I, Couverts) ; mot_ferme(F) ; \+ alphabetique(F) ; titre(F) ; metalangage(F) )
    ->  unites_mots(L, S, Ms, Couverts, Us)
    ;   compose_couvrant(L, S, M, W, Cv)
    ->  append(Couverts, Cv, C1), Us = [mot(W)|Us1], unites_mots(L, S, Ms, C1, Us1)
    ;   lemme(M, W), Us = [mot(W)|Us1], unites_mots(L, S, Ms, Couverts, Us1)
    ).

% un composé dont M est le premier mot, et les mots qu'il couvre
compose_couvrant(en, S, M, W, Cv) :-
    append(_, [M, T|Ap], S), compose(en, [M, T|Ap], T, W), \+ sub_atom(W, _, _, _, ' of '), !,
    T = mot(J, _, _, _, _, _, _, _, _), Cv = [J].
compose_couvrant(en, S, M, W, Cv) :-
    append(_, [M|Ap], S), compose(en, [M|Ap], M, W), sub_atom(W, _, _, _, ' of '), !,
    Ap = [mot(J1, _, _, _, _, _, _, _, _), mot(J2, _, _, _, _, _, _, _, _)|_], Cv = [J1, J2].
compose_couvrant(fr, S, M, W, Cv) :-
    append(_, [M|Ap], S), compose(fr, [M|Ap], M, W), !,
    atomic_list_concat(Parts, ' ', W), length(Parts, K0),
    findall(J, ( between(1, 3, X), nth1(X, Ap, mot(J, _, _, _, _, _, _, _, _)) ), Js0),
    ( atom_length(W, _), sub_atom(W, _, _, _, '\'') -> K = K0 ; K is K0 - 1 ),
    length(Cv, K), append(Cv, _, Js0).

% --- Les mots d'une partie analysée ---------------------------------------------------------------------------------

mots([phrase(Ms)|_], Ms).                           % un libellé est une phrase (une partie propre)

% le lemme d'un mot ; en anglais, un nom passe par la morphologie de WordNet (« beasts » → beast)
% en français, sans lexique, le lemme d'UDPipe n'est gardé que s'il est attesté comme forme dans les libellés français
% (« bandeau » → « bandeare » ne l'est pas : on garde la forme), comme pour les profils (sujets.pl)
% (la langue est celle de la définition en cours : WordNet et sa morphologie ne jugent que l'anglais ; en français,
% « mars » n'est pas le pluriel de « mar »)
lemme(M, L) :- ( nb_current(definitions_langue, La) -> true ; La = en ), lemme(La, M, L).

lemme(en, mot(_, F, L0, C, _, _, _, _, _), L) :- !,
    ( C == 'PROPN' -> L1 = F ; L1 = L0 ), downcase_atom(L1, L2),
    downcase_atom(F, Fm),
    (   C == 'NOUN', catch(morphologie:lemmes(Fm, n, [L3|_]), _, fail), \+ wordnet:s(_, _, L2, n, _, _) -> L = L3
    ;   C == 'NOUN', sub_atom(L2, B, 1, A, '-'), A > 0, \+ sub_atom(L2, _, _, A, '-'),    % « dice-games » → dice-game
        sub_atom(L2, 0, B, _, Av), B1 is B + 1, sub_atom(L2, B1, A, 0, Ap),
        catch(morphologie:lemmes(Ap, n, [Ap1|_]), _, fail), Ap1 \== Ap
    ->  atomic_list_concat([Av, Ap1], '-', L)
    ;   L = L2
    ).
lemme(_, mot(_, F, L0, C, _, _, _, _, _), L) :-
    ( C == 'PROPN' -> L1 = F ; L1 = L0 ), downcase_atom(L1, L2),
    downcase_atom(F, Fm),
    (   C == 'NOUN', L2 \== Fm, \+ forme_fr(L2) -> L = Fm
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

% Les segments d'une énumération, lus de la façon la plus exigeante quand la coordination est ambiguë (sûr d'abord) :
%   - un segment « e.g. … » (un exemple) n'est pas une alternative ;
%   - un segment sans nom (« two », « miraculous ») n'est pas une alternative : il se joint au segment suivant (au
%     précédent s'il est le dernier) ;
%   - un segment elliptique reprend le contexte partagé (distribuer/3).
segments_complets(L, Ws, Ss) :-
    segments(Ws, Ss0),
    exclude(segment_exemple, Ss0, Ss1),
    joindre_sans_nom(Ss1, Ss2),
    distribuer(L, Ss2, Ss).

segment_exemple([mot(_, E, _, _, _, _, _, _, _), mot(_, '.', _, _, _, _, _, _, _), mot(_, G, _, _, _, _, _, _, _)|_]) :-
    downcase_atom(E, e), downcase_atom(G, g), !.
segment_exemple([mot(_, F, _, _, _, _, _, _, _)|_]) :- downcase_atom(F, W), memberchk(W, ['e.g.', eg, exemple, example, ex]), !.
segment_exemple([mot(_, P, _, _, _, _, _, _, _), mot(_, '.', _, _, _, _, _, _, _), mot(_, E, _, _, _, _, _, _, _)|_]) :-
    downcase_atom(P, p), downcase_atom(E, ex), !.

avec_nom(S) :- member(M, S), M = mot(_, F, _, _, _, _, _, _, _), \+ mot_ferme(F), alphabetique(F), nom_ou_connu(M), !.

joindre_sans_nom([], []).
joindre_sans_nom([S], [S]) :- !.
joindre_sans_nom([S1, S2|Ss], R) :-
    (   \+ avec_nom(S1) -> append(S1, S2, S12), joindre_sans_nom([S12|Ss], R)
    ;   Ss == [], \+ avec_nom(S2) -> append(S1, S2, S12), R = [S12]
    ;   R = [S1|R1], joindre_sans_nom([S2|Ss], R1)
    ).

adjectifs(S, As) :- include([M]>>( M = mot(_, _, _, 'ADJ', _, _, _, _, _) ), S, As).

% La coordination elliptique : un segment réduit à un groupe nominal sans verbe ni nom propre reprend le contexte
% partagé ; en anglais, ce qui précède la tête du premier segment (« hell represented as a cave or grotto » : hell
% represented as a grotto ; « miraculous activities and events » : miraculous events) ; en français aussi, puis ce qui
% suit la tête du dernier (« activités et événements miraculeux » : activités miraculeuses).
distribuer(_, [], []) :- !.
distribuer(_, [S], [S]) :- !.
distribuer(en, [S1|Ss], [S1|Ss1]) :- !,
    ( append(Contexte, [T|Reste], S1), nom_ou_connu(T), \+ ( member(T2, Reste), nom_ou_connu(T2) ) -> true ; Contexte = [] ),
    maplist(reprendre_avant(Contexte), Ss, Ss1).
distribuer(_, [S1|Ss0], Ss1) :-                          % en français : le contexte avant la tête (le premier nom :
    ( append(Cav, [T0|_], S1), nom_ou_connu(T0) -> true ; Cav = [] ),           % « contrôle des naissances » n'a
    maplist(reprendre_avant(Cav), Ss0, Ss00), Ss = [S1|Ss00],                   % pas de contexte avant), puis après
    last(Ss, Sd), ( append(Avant, [T|Contexte], Sd), nom_ou_connu(T), \+ ( member(T2, Avant), nom_ou_connu(T2) ) -> true ; Contexte = [] ),
    append(Av, [Sd], Ss), maplist(reprendre_apres(Contexte), Av, Av1), append(Av1, [Sd], Ss1).

reprendre_avant(C, S, S1) :- ( elliptique(S), un_seul_mot_plein(S), C \== [] -> append(C, S, S1) ; S1 = S ).
reprendre_apres(C, S, S1) :- ( elliptique(S), un_seul_mot_plein(S), C \== [] -> append(S, C, S1) ; S1 = S ).
% un segment qui a déjà son propre modifieur (« trade token » après « trade mark ») n'est pas elliptique : il ne
% reprend pas le contexte du premier (27/11, docs/mesures/C3_CORRECTIONS.md, D3)
un_seul_mot_plein(S) :- include([M]>>( arg(4, M, C), \+ memberchk(C, ['DET', 'ADP', 'PUNCT', 'CCONJ']) ), S, [_]).

% un segment elliptique : sans verbe, sans nom propre, sans préposition (un ou quelques mots autour d'un nom)
elliptique(S0) :-                       % (une préposition ou un article en tête : « de fruits »)
    ( S0 = [mot(_, _, _, C0, _, _, _, _, _)|S1], memberchk(C0, ['ADP', 'DET']) -> S = S1 ; S = S0 ),
    \+ ( member(M, S), M = mot(_, _, _, C, _, _, _, _, _), memberchk(C, ['VERB', 'PROPN', 'ADP', 'AUX']) ).


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
% (« hill » rangé en verbe) ; jamais un mot d'une classe fermée (« le », « un », « de » pris pour un nom) ni un mot
% sans lettre
nom_ou_connu(M) :- M = mot(_, F, _, _, _, _, _, _, _), ( mot_ferme(F) ; \+ alphabetique(F) ), !, fail.
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
    append(_, [P, Li], Avant), propre(P), Li = mot(_, F, _, _, _, _, _, _, _), downcase_atom(F, W),
    memberchk(W, [of, the, de, du, 'd\'', 'd’']).
suite([M|Ms], [M|S]) :- propre(M), !, suite(Ms, S).
suite([L, M|Ms], [L, M|S]) :-
    L = mot(_, F, _, _, _, _, _, _, _), downcase_atom(F, W), memberchk(W, [of, the, de, du, 'd\'', 'd’']), propre(M), !, suite(Ms, S).
suite(_, []).
noms_de(S, K) :-
    findall(F, member(mot(_, F, _, _, _, _, _, _, _), S), Fs0),
    exclude(titre, Fs0, Fs), Fs \== [],
    joindre(Fs, Nom0), raisonnement:normaliser_nom(Nom0, K0),           % « Pierre d'Alcantara »
    atom_codes(K0, Cs0), exclude([C]>>memberchk(C, `;:,.`), Cs0, Cs), atom_codes(K1, Cs), normalize_space(atom(K), K1),
    K \== ''.
titre(F) :- downcase_atom(F, W), memberchk(W, ['st.', st, saint, sainte, ste, 'ste.', 's.']).

mot_ferme(F) :- downcase_atom(F, W0), elision_retiree(W0, W), ( sujets:ferme(en, W) ; sujets:ferme(fr, W) ; atom_length(W, 1) ), !.
% « d' », « l' », « qu' » : le mot élidé (de, le, que) ; « d » seul a une lettre
elision_retiree(W0, W) :- ( ( sub_atom(W0, B, 1, 0, '\'') ; sub_atom(W0, B, 1, 0, '’') ), B > 0 -> sub_atom(W0, 0, B, _, W1), elide(W1, W) ; W = W0 ).
elide(d, de) :- !. elide(l, le) :- !. elide(qu, que) :- !. elide(s, se) :- !. elide(n, ne) :- !. elide(j, je) :- !.
elide(m, me) :- !. elide(t, te) :- !. elide(c, ce) :- !. elide(W, W).
alphabetique(F) :- atom_codes(F, Cs), Cs = [C|_], code_type(C, alpha), \+ code_type(C, digit(_)).

% Le lemme d'une tête, ou d'un composé dont elle est la tête : en anglais, un composé que WordNet connaît (« still
% life », « book of hours ») ; en français, un composé qui est un mot clé français d'Iconclass (« nature morte », « lit
% de mort », « maison d'arrêt ») : Iconclass lui-même fournit le lexique des composés
lemme_de_tete(L, S, T, W) :- compose(L, S, T, W), !.
lemme_de_tete(_, _, T, W) :- lemme(T, W).

compose(en, S, T, W) :-
    append(Av, [T|Ap], S),
    (   last(Av, M), M = mot(_, F, _, _, _, _, _, _, _), downcase_atom(F, Fm), lemme(T, Lt),
        atomic_list_concat([Fm, Lt], ' ', W), wordnet:s(_, _, W, n, _, _)
    ;   Ap = [mot(_, Of, _, _, _, _, _, _, _), X|_], downcase_atom(Of, of), nominal(X), lemme(T, Lt),
        X = mot(_, Fx, _, _, _, _, _, _, _), downcase_atom(Fx, Xm),
        atomic_list_concat([Lt, of, Xm], ' ', W), wordnet:s(_, _, W, n, _, _)
    ), !.
compose(fr, S, T, W) :-
    append(_, [T|Ap], S), T = mot(_, Ft, _, _, _, _, _, _, _),
    between(1, 3, K), length(Suite, K), append(Suite, _, Ap),
    findall(F, member(mot(_, F, _, _, _, _, _, _, _), [T|Suite]), Fs),
    joindre(Fs, W0), downcase_atom(W0, W1), re_replace("’"/g, "'", W1, W2), atom_string(W, W2),
    mot_cle_fr(W), Ft \== '', !.

% joindre des mots sans espace après une élision (« d' » + « arrêt » → « d'arrêt »)
joindre([F], F) :- !.
joindre([F|Fs], W) :- joindre(Fs, W1), ( ( sub_atom(F, _, 1, 0, '\'') ; sub_atom(F, _, 1, 0, '’') ) -> atom_concat(F, W1, W) ; atomic_list_concat([F, W1], ' ', W) ).

:- table mot_cle_fr/1.
mot_cle_fr(W) :- mots_cles_fr(Ws), memberchk(W, Ws).
:- table mots_cles_fr/1.
mots_cles_fr(Ws) :-
    findall(W, ( iconclass:mot_cle(_, fr, K), downcase_atom(K, W0), sub_atom(W0, _, _, _, ' '),
                 re_replace("’"/g, "'", W0, W1), atom_string(W, W1) ), Ws0),
    sort(Ws0, Ws).

% --- Les conditions, par type ---------------------------------------------------------------------------------------

conditions(rubrique, _, _, _, _, _, []).
conditions(classe, _, L, _, Ph, Ms, Cs) :-
    mots(Ph, Ws0), defini(Ws0, Ws), segments(Ws, Ss),
    findall(seg(Tete, Ps, Co), ( member(S, Ss), tete_segment(L, S, T, Av, Ap), lemme_de_tete(L, S, T, Tete),
                                 modificateurs(Av, Ap, Ps), complements(r, Ap, Co) ), Segs),
    Segs \== [],
    findall(Te, member(seg(Te, _, _), Segs), Tetes0), sort(Tetes0, Tetes),
    (   Segs = [seg(_, Ps1, Co1)] -> findall(propriete(r, P), member(P, Ps1), Pc), append([[tete(r, Tetes)], Pc, Co1], Cs0)
    ;   Cs0 = [tete(r, Tetes)]                       % une union : les modificateurs propres à chaque tête ne sont pas
    ),                                               % exigés de l'union (précision : on garde la seule tête commune)
    nom_et_type(Ms, Ph, Cs0, Cs).
% les noms d'un individu : ceux du premier segment de sa partie propre (« the apostle Peter », pas « first bishop of
% Rome »), le nom de la notation, ses variantes (parenthèses, autre langue) ; un gabarit a un nom à remplir
% Les noms : celui de la notation (11H(PETER)), les variantes entre parenthèses, et les mots clés d'Iconclass de la
% forme « Nom (rôle) » dans les deux langues (« Pierre (St) », « Jean Baptiste (St) ») ; à défaut de nom de notation
% (un récit : « (story of) Hercules »), les noms du premier segment. Les mots à majuscule qui ne sont pas le nom
% (« Dominican », « bishop of Rome ») n'en sont pas.
conditions(individu, N, L, _, Ph, Ms, Cs) :-
    mots(Ph, Ws), avant_deux_points(Ws, Ws0), premier_segment(Ws0, Ws1),
    nom_de_la_notation(N, Kn),
    noms(Ws1, Ks00), noms_de_la_personne(Kn, Ks00, Ks0),
    findall(K, ( member(variante(V), Ms), variante_propre(L, V), raisonnement:normaliser_nom(V, K) ), Vs),
    findall(K, ( member(L2, [en, fr]), iconclass:mot_cle(N, L2, Mc), sub_atom(Mc, _, _, _, ' ('),
                 sub_atom(Mc, 0, 1, _, Ini), char_type(Ini, upper(_)),
                 raisonnement:tete_mot_cle(Mc, Nom), raisonnement:normaliser_nom(Nom, K),
                 nom_de_la_personne(Mc, K, Kn) ), Kc),
    append([Kn, Ks0, Vs, Kc], Ks1), sort(Ks1, Ks),
    findall(compatible(r, W), ( member(M, Ws0), M = mot(_, _, _, 'NOUN', _, _, _, _, _), \+ propre(M), lemme(M, W) ), Cp),
    autre_langue(N, L, Ka0), noms_de_la_personne(Kn, Ka0, Ka),
    append(Ks, Ka, Ks2), sort(Ks2, Ks3),
    (   Ks3 \== [] -> Cs = [nom(r, Ks3)|Cp]
    ;   sub_atom(N, _, _, _, '(...)') -> Cs = [nom(r, a_remplir)|Cp]
    ).

conditions(recit, N, L, Net, Ph, Ms, Cs) :- conditions(individu, N, L, Net, Ph, Ms, Cs).
conditions(attribut, _, L, _, Ph, _, [porteur(r, p)|Cs]) :-
    mots(Ph, Ws), avant_deux_points(Ws, Av), defini(Ws, D),
    ( noms(Av, [K|_]) -> Porteur = [nom(p, [K])] ; append(_, [mot(_, De, _, _, _, _, _, _, _)|Ap], Av), downcase_atom(De, Dm),
      memberchk(Dm, [of, de, du, des]), include(nominal, Ap, [T|_]) -> lemme(T, W), Porteur = [tete(p, [W])] ; Porteur = [] ),
    segments(D, Ss),
    findall(Te, ( member(S, Ss), tete_segment(L, S, T, _, _), lemme_de_tete(L, S, T, Te) ), Tetes0), sort(Tetes0, Tetes),
    Tetes \== [],
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

% une variante entre parenthèses est un nom propre (en anglais, au sens de WordNet : « (Black) » n'en est pas un)
% (en anglais, aucun de ses mots n'est un mot commun de WordNet : « (Black) » n'est pas une variante, « (Heracles) »,
% « (Lucia) », « (Hieronymus) » en sont)
% (en anglais : chaque mot est inconnu de WordNet, ou y désigne un individu (une instance : « Heracles ») ; « Black »,
% « Franciscan » sont des classes de WordNet, pas des noms d'individus)
variante_propre(en, V) :- !, atom_string(A, V), atomic_list_concat(Ms, ' ', A), forall(member(M, Ms), mot_d_individu(M)).
variante_propre(_, _).
mot_d_individu(M) :-
    downcase_atom(M, W),
    \+ ( ( wordnet:s(S, _, W, n, _, _) ; wordnet:s(S, _, M, n, _, _) ; wordnet:s(S, _, W, a, _, _) ; wordnet:s(S, _, M, a, _, _) ),
         \+ wordnet:ins(S, _) ).

% un mot clé « Nom (rôle) » donne un nom de la personne si son rôle est un titre de personne (« (St) », « (Ste) »,
% « (San) ») ou s'il partage un mot avec le nom de la notation ; « Franciscans (order) », « Trajan (emperor) » pour
% saint Grégoire n'en sont pas
nom_de_la_personne(Mc, _, _) :-
    sub_atom(Mc, B, _, _, '('), sub_atom(Mc, B, _, 0, R0), downcase_atom(R0, R),
    re_match("^\\((st\\.?|ste\\.?|saint|sainte|san|santa|santo|sankt|sv\\.?|s\\.)\\)", R), !.
nom_de_la_personne(_, K, [Kn]) :-                    % le mot clé contient le nom entier de la notation
    atomic_list_concat(As, ' ', K), atomic_list_concat(Bs, ' ', Kn), subtract(Bs, As, []), !.

% un nom du premier segment (dans l'une ou l'autre langue) est un nom de la personne s'il partage un mot d'au moins
% quatre lettres avec le nom de la notation (« Pierre d'Alcantara » pour PETER OF ALCANTARA ; pas « Franciscan ») ;
% sans nom de notation (un récit : « (story of) Hercules »), tous les noms du premier segment
% un premier segment qui n'a qu'un nom (« l'apôtre Pierre », « Pierre d'Alcantara, moine franciscain ») le donne
% pour celui de la personne ; s'il en a plusieurs (« the Franciscan monk Peter of Alcantara »), seuls ceux qui
% partagent un mot avec le nom de la notation
noms_de_la_personne(_, [K], [K]) :- !.
noms_de_la_personne(Kn, Ks, Ks1) :- include(meme_personne(Kn), Ks, Ks1).

meme_personne([], _) :- !.
meme_personne([Kn], K) :-
    atomic_list_concat(As0, ' ', K), atomic_list_concat(Bs, ' ', Kn), maplist(sans_elision, As0, As),
    member(X, As), atom_length(X, Lg), Lg >= 4, memberchk(X, Bs), !.
sans_elision(A0, A) :- ( sub_atom(A0, B, 1, _, '\''), B =< 2 -> sub_atom(A0, _, _, 0, A1), B1 is B + 1, sub_atom(A0, B1, _, 0, A), A1 = A1 ; A = A0 ).

premier_segment(Ws, S) :- segments_(Ws, [], [S|_]), !.
premier_segment(Ws, Ws).

% les parties de gabarit d'une notation (« - miraculous activities and events », « - portrayed alone ») : un aspect
% exigé, par ses têtes
aspects(N, L, As) :-
    findall(aspect(T, Tetes, Ps), ( aspect_type(N, R, T), libelles_lus:partie(N, L, R, gabarit, Net, _, Ph),
                                    \+ lettres_doublees(Net),
                                    mots(Ph, Ws), segments(Ws, Ss),
                                    findall(Te, ( member(S, Ss), tete_d_aspect(T, L, S, Tt), lemme_de_tete(L, S, Tt, Te) ), Tetes0),
                                    sort(Tetes0, Tetes), Tetes \== [],
                                    ( Ss = [S1] -> tete_segment(L, S1, _, Av, Ap), modificateurs(Av, Ap, Ps) ; Ps = [] ) ),
            As).

% « - AA - », « - FF - » : la lettre doublée d'Iconclass, qui annonce la partie suivante (elle-même un aspect)
lettres_doublees(Net) :- atom_length(Net, Lg), Lg =< 3, upcase_atom(Net, Net).

% la tête d'un aspect de genre ou de mode est son mot de représentation (« portrayed alone » : portray)
tete_d_aspect(genre, _, S, T) :- member(T, S), lemme(T, W), ( libelles_iconclass:genre(W) ; libelles_iconclass:genre_mode(W) ), !.
tete_d_aspect(_, L, S, T) :- tete_segment(L, S, T, _, _).
% un segment entre guillemets (un titre de Ripa : « 'Solitudine' »)
cite(S) :- member(mot(_, F, _, _, _, _, _, _, _), S), memberchk(F, ['\'', '‘', '’', '"']), !.
titre_cite(Net, K) :-
    atom_string(Net, S),                         % une apostrophe entre deux lettres (« dell'Ingegno ») n'est pas un guillemet
    re_foldl(cite_, "(?<!\\w)'(?<t>(?:[^']|(?<=\\w)'(?=\\w))+)'(?!\\w)", S, [], Ks0, []),
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
% (le nom est entre la première parenthèse et sa fermante, où qu'elle soit : 11H(PETER OF ALCANTARA)8)
nom_de_la_notation(N, [K]) :-
    sub_atom(N, B, 1, _, '('), B1 is B + 1, sub_atom(N, E, 1, _, ')'), E > B1, !,
    Lg is E - B1, sub_atom(N, B1, Lg, _, Nom),
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
    (   arbre:ancetre(N, A), type_libelle(A, TA), memberchk(TA, [individu, recit]),
        definition(A, L, def(_, ExA, _, _, _)), memberchk(un_de([[nom(Ks)]]), ExA), Ks \== a_remplir
    ->  Hs = [personne(Ks)]
    ;   Hs = []
    ).
