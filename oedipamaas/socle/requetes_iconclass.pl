/*  La compilation des libellés d'Iconclass en requêtes du noyau (docs/PLAN_V1.md, C3 ; docs/NOYAU.md, § 3).

    compiler(+N, +Langue, -Compilation)
        Compilation = compilation(N, Langue, Type, Suff, Nec, Statut, Raisons, Famille)
          Suff, Nec   requete(N, Formule) | aucune   la condition suffisante, la condition nécessaire
          Statut      compilee | partielle | non_prise_en_charge | invalide
          Raisons     ce qui rend la compilation partielle, ou pourquoi elle n'est pas prise en charge
          Famille     la famille de constructions (le type du libellé et la forme de la requête), unité de la mesure de
                      la suffisance (C3.3) : une famille se justifie par jugement, pas une définition

    Comment, par type de libellé (libelles_iconclass:type_de_libelle/4) :
      scene      le graphe que le lecteur des textes tire du libellé devient une requête : une variable par entité et
                 par événement, ses types, noms, propriétés, rôles et relations (un graphe conceptuel est une requête :
                 Sowa) ; les noms de la personne dont la scène fait partie y sont ajoutés (héritage)
      classe     les segments de l'énumération après « : » (definitions.pl, segments_complets/3) sont les alternatives
                 d'un « ou » ; chacune est le graphe du lecteur restreint à ses mots
      gabarit    une notation à nom construite sur un gabarit (25G3(PEAR-TREE) : « trees ») : le nom est la tête, le
                 libellé du gabarit son genre ; en français, les mots de WOLF des sens anglais du nom
      individu, recit   les noms (definitions.pl) ; les aspects (« ~ » et gabarits) en conjonction
      genre      genre(T), une alternative par tête
      attribut, concept, rubrique, « (...) », « (+…) »   non pris en charge à ce jalon (C8, C9)

    Une requête est partielle si son graphe n'est pas connexe (deux entités du libellé sans lien lu : « market
    cross » lu comme deux choses) ou si un mot plein du libellé n'y a pas d'atome. Elle ne peut alors pas établir.
*/
:- module(requetes_iconclass, [ compiler/3 ]).
:- encoding(utf8).
:- use_module(library(lists)).
:- use_module(library(apply)).
:- use_module(library(pairs)).
:- use_module(library(yall)).
:- use_module(requetes).
:- use_module(definitions, []).
:- use_module(interpretation, []).
:- use_module(raisonnement, []).
:- use_module(arbre).

compiler(N, L, compilation(N, L, Type, Suff, Nec, Statut, Raisons, Famille)) :-
    ( definitions:type_libelle(N, Type0) -> true ; Type0 = inconnu ),
    b_setval(definitions_langue, L),
    (   pas_pris_en_charge(N, Type0, R)
    ->  Type = Type0, Suff = aucune, Nec = aucune, Statut = non_prise_en_charge, Raisons = [R], Famille = Type0-aucune
    ;   catch(compiler_(N, L, Type0, Type, F, Fn, Rs0), E, ( Rs0 = [exception(E)], F = aucune, Type = Type0 ))
    ->  (   F == aucune -> Suff = aucune, Nec = aucune, Statut = invalide, Raisons = Rs0, Famille = Type-aucune
        ;   Suff = requete(N, F), Nec = requete(N, Fn),
            requetes:bien_formee(Suff, Es), requetes:bien_formee(Nec, Esn),
            append([Es, Esn], Ef),
            (   Ef \== [] -> Statut = invalide, append(Rs0, [mal_formee(Ef)], Raisons)
            ;   member(R, Rs0), memberchk(R, [construction_negative(_), construction_modale(_)])
            ->  Statut = non_prise_en_charge, Raisons = Rs0
            ;   Rs0 == [] -> Statut = compilee, Raisons = []
            ;   Statut = partielle, Raisons = Rs0
            ),
            famille(Type, F, Famille)
        )
    ;   Type = Type0, Suff = aucune, Nec = aucune, Statut = invalide, Raisons = [echec], Famille = Type0-aucune
    ).

pas_pris_en_charge(N, _, cle) :- sub_atom(N, _, _, _, '(+'), !.
pas_pris_en_charge(N, _, gabarit_a_remplir) :- sub_atom(N, _, _, _, '(...)'), !.
pas_pris_en_charge(_, T, type(T)) :- memberchk(T, [rubrique, attribut, concept, inconnu]), !.
% une section à lettres doublées (31AA : figure féminine ; 25FF : fabuleux ; 48CC, 25HH…) : le trait que la lettre
% doublée déclenche n'est pas dans le libellé de la notation ; sans lui la requête est trop faible (C8)
pas_pris_en_charge(N, _, lettres_doublees) :- lettres_doublees(N), !.

% --- Par type ---------------------------------------------------------------------------------------------------------

compiler_(N, L, T0, gabarit, F, Fn, Rs) :-                      % une notation à nom sur un gabarit de choses
    \+ memberchk(T0, [individu, recit]), \+ libelles_iconclass:gabarit_de_personnes(N), nom_de_gabarit(N, Nom, G), !,
    tetes_du_nom(L, Nom, Ts), Ts \== [],
    findall(type(v(x), T), member(T, Ts), As), ou_ou_un(As, Fnom),
    % le genre que donne le libellé du gabarit (« bottles » pour PELICAN, « trees » pour PEAR-TREE) : sur la même
    % variable ; impliqué quand le nom n'a qu'un sens, il écarte les autres sens quand il en a plusieurs
    (   genre_du_gabarit(G, L, Gs), Gs \== []
    ->  findall(type(v(x), Tg), member(Tg, Gs), Ags), ou_ou_un(Ags, Fg), F = et([Fnom, Fg])
    ;   F = Fnom
    ),
    Fn = Fnom,
    ( L == fr, formes_anglaises(Nom, Ts) -> Rs = [nom_sans_traduction(Nom)] ; Rs = [] ).
compiler_(N, L, T, scene, F, Fn, Rs) :-                         % une subdivision d'une personne (11I62(ADAM)11)
    T \== scene, ( memberchk(T, [individu, recit]) ; libelles_iconclass:gabarit_de_personnes(N) ),
    subdivision_de_personne(N), !,
    compiler_(N, L, scene, scene, F, Fn, Rs).
compiler_(N, L, T, T, F, Fn, Rs) :- memberchk(T, [individu, recit]), !,
    noms(N, L, Ks), Ks \== [],
    aspects(N, L, Gs, Ra),
    append([[nom(v(p), Ks)], Gs], Cs), et_ou_un(Cs, F), Fn = nom(v(p), Ks), Rs = Ra.
compiler_(N, L, genre, genre, F, F, []) :- !,
    definitions:definition(N, L, def(_, Ex, _, _, _)),
    findall(genre(W), ( member(un_de(As), Ex), member(A, As), member(U, A), ( U = genre(W) ; U = mot(W) ) ), Gs0),
    sort(Gs0, Gs), Gs \== [], ou_ou_un(Gs, F).
compiler_(N, L, scene, scene, F, Fn, Rs) :- !,
    partie(N, L, Net, Ph), graphe(N, L, Net, Ph, Fs),
    graphe_requete(Fs, all, Cs0, Ra),
    heritage(N, L, Cs0, Cs1),
    aspects(N, L, Gs, Rg), append(Cs1, Gs, Cs),
    Cs \== [], et_ou_un(Cs, F), necessaire(Cs1, Fn), mots_non_couverts(L, Ph, Cs1, Rm),
    parentheses_non_lues(N, L, Rp), append([Ra, Rm, Rg, Rp], Rs).
compiler_(N, L, classe, classe, F, Fn, Rs) :- !,
    partie(N, L, Net, Ph), graphe(N, L, Net, Ph, Fs),
    definitions:mots(Ph, Ws0), definitions:defini(Ws0, Ws), definitions:segments_complets(L, Ws, Ss),
    findall(Cs-Ra-S, ( member(S, Ss), debuts_du_segment(S, Ds), graphe_requete(Fs, debuts(Ds), Cs0, Ra), Cs0 \== [],
                       heritage(N, L, Cs0, Cs) ), Alts0),
    Alts0 \== [], tete_partagee_a_droite(L, Alts0, Alts),
    findall(Fa, ( member(Cs-_-_, Alts), et_ou_un(Cs, Fa) ), Fas), ou_ou_un(Fas, F0),
    aspects(N, L, Gs, Rg), ( Gs == [] -> F = F0 ; append([F0], Gs, Fg), F = et(Fg) ),
    parentheses_non_lues(N, L, Rp),
    findall(Fn1, ( member(Cs-_-_, Alts), necessaire(Cs, Fn1) ), Fns), ou_ou_un(Fns, Fn),
    findall(R, ( member(_-Ra-_, Alts), member(R, Ra) ), Rs0),
    findall(R, ( member(Cs-_-S, Alts), mots_non_couverts(L, [phrase(S)], Cs, Rm), member(R, Rm) ), Rs1),
    append([Rs0, Rs1, Rg, Rp], Rs2), sort(Rs2, Rs).

partie(N, L, Net, Ph) :- libelles_lus:partie(N, L, 1, _, Net, _, Ph), !.
graphe(_, L, Net, Ph, Fs) :- interpretation:interpreter(Net, L, description, Ph, Fs).

et_ou_un([A], A) :- !.
et_ou_un(As, et(As)).
ou_ou_un([A], A) :- !.
ou_ou_un(As0, ou(As)) :- sort(As0, As).

% --- Le graphe du lecteur devenu requête ------------------------------------------------------------------------------

% graphe_requete(+Faits, +Portee, -Conditions, -Raisons) : les assertions dont le passage est dans la portée (all, ou
% debuts(Ds) : le passage commence sur l'un des mots du segment, qui n'est pas toujours d'un seul tenant quand la
% coordination elliptique reprend un contexte partagé) ; une variable par entité, par événement
graphe_requete(Fs, Por, Cs, Rs) :-
    findall(E, ( member(entite(E, _, P), Fs), dans(Fs, P, Por) ), Es),
    findall(V, ( member(evenement(V, _, P), Fs), dans(Fs, P, Por) ), Vs),
    findall(C, condition(Fs, Es, Vs, C), Cs00), list_to_set(Cs00, Cs01), composes(Cs01, Cs0), list_to_set(Cs0, Cs1),
    distinctions(Cs1, Ds), append(Cs1, Ds, Cs),
    findall(R, raison(Fs, Es, Vs, Cs, R), Rs0), sort(Rs0, Rs).

dans(_, _, all) :- !.
dans(Fs, P, debuts(Ds)) :- memberchk(passage(P, Dp, _), Fs), memberchk(Dp, Ds).

condition(Fs, Es, _, type(v(E), T)) :- member(E, Es), member(entite(E, T0, _), Fs), T0 \== nom_propre, mot(T0, T).
condition(Fs, Es, _, nom(v(E), [K])) :-
    member(E, Es), member(nom(_, E, Nom, _), Fs), \+ mot_commun_en_tete(Fs, E, Nom, _), raisonnement:normaliser_nom(Nom, K).
condition(Fs, Es, _, type(v(E), W)) :- member(E, Es), member(nom(_, E, Nom, _), Fs), mot_commun_en_tete(Fs, E, Nom, W).
condition(Fs, Es, _, propriete(v(E), P)) :-
    member(E, Es), member(propriete(_, E, P0, _), Fs), mot(P0, P), \+ metalangage(P).
condition(Fs, _, Vs, evenement(v(V), P)) :- member(V, Vs), member(evenement(V, P0, _), Fs), mot(P0, P).
condition(Fs, Es, Vs, role(v(V), R, v(E))) :- member(V, Vs), member(role(V, R, E), Fs), memberchk(E, Es).
condition(Fs, Es, _, relation(v(E1), R, v(E2))) :-
    member(relation(_, E1, R0, E2, _), Fs), memberchk(E1, Es), memberchk(E2, Es), mot(R0, R).
condition(Fs, Es, _, meme(v(E1), v(E2))) :- member(coref(E1, E2), Fs), memberchk(E1, Es), memberchk(E2, Es).

mot(X, W) :- atom(X), downcase_atom(X, W).

% Iconclass met une majuscule au premier mot d'un libellé : un « nom » qui est le premier mot et un nom commun de la
% langue (un sens qui n'est pas une instance dans WordNet ; un mot de WOLF) est ce nom commun (« Isthmus »)
mot_commun_en_tete(Fs, E, Nom, W) :-
    member(entite(E, nom_propre, P), Fs), memberchk(passage(P, 0, _), Fs),
    \+ sub_atom(Nom, _, _, _, ' '), downcase_atom(Nom, W),
    nb_current(definitions_langue, L),
    (   L == en -> wordnet:s(S, _, W, n, _, _), \+ wordnet:ins(S, _)
    ;   ressources:wolf(S, W), S // 100000000 =:= 1, \+ wordnet:ins(S, _)
    ), !.
metalangage(W) :- memberchk(W, [other, others, autre, autres, specific, spécifique, various, divers]).

% Les composés que la langue lexicalise (WordNet en anglais, WOLF en français) sont un seul type, non une tête et
% son complément : « ring finger » (finger + ring), « mal de tête » (mal de tête), « organe sexuel » (organe + sexuel)
composes(Cs0, Cs) :-
    (   select(type(X, T), Cs0, Cs1), select(propriete(X, P), Cs1, Cs2), compose_de(T, P, W)
    ->  composes([type(X, W)|Cs2], Cs)
    ;   select(type(X, T1), Cs0, Cs1), select(relation(X, R, Y), Cs1, Cs2), memberchk(R, [of, de, du, des]),
        select(type(Y, T2), Cs2, Cs3), \+ autre_condition(Cs3, Y), compose_de_complement(T1, R, T2, W)
    ->  composes([type(X, W)|Cs3], Cs)
    ;   Cs = Cs0
    ).
compose_de(T, P, W) :-
    nb_current(definitions_langue, L),
    ( L == en -> atomic_list_concat([P, T], ' ', W) ; atomic_list_concat([T, P], ' ', W) ), lexicalise(L, W), !.
compose_de_complement(T1, R, T2, W) :-
    nb_current(definitions_langue, L), ( L == en -> R1 = of ; R1 = de ),
    member(R0, [R1, R]), atomic_list_concat([T1, R0, T2], ' ', W), lexicalise(L, W), !.
autre_condition(Cs, Y) :- member(C, Cs), arg(_, C, A), A == Y, !.
lexicalise(en, W) :- wordnet:s(_, _, W, n, _, _), !.
lexicalise(fr, W) :- ressources:wolf(S, W), S // 100000000 =:= 1, !.

% La tête partagée à droite (« skin and venereal diseases ») : la lecture la plus exigeante d'un segment réduit à un
% nom (« skin ») est le composé qu'il forme avec la tête du dernier segment, quand la langue le lexicalise (« skin
% disease ») ; sinon le segment reste tel quel
tete_partagee_a_droite(L, Alts0, Alts) :-
    (   last(Alts0, Cd-_-_), member(type(_, Td0), Cd), tete_finale(Td0, Td)
    ->  maplist(distribuer_a_droite(L, Td), Alts0, Alts)
    ;   Alts = Alts0
    ).
tete_finale(T, H) :- atomic_list_concat(Ps, ' ', T), last(Ps, H).
distribuer_a_droite(L, Td, [type(X, T)]-Ra-S, [type(X, W)]-Ra-S) :-
    ( L == en -> atomic_list_concat([T, Td], ' ', W) ; atomic_list_concat([Td, T], ' ', W) ),
    lexicalise(L, W), !.
distribuer_a_droite(_, _, A, A).

% deux noms propres différents d'un même libellé : deux individus (docs/PLAN_V1.md, C2.3)
distinctions(Cs, Ds) :-
    findall(distincts(X, Y), ( member(nom(X, [K1]), Cs), member(nom(Y, [K2]), Cs), X @< Y, K1 \== K2 ), Ds).

% une négation ou une modalité du libellé (« angels without wings », « possibly ») : le langage des requêtes n'a pas de
% négation, et la condition deviendrait positive ; la construction n'est pas prise en charge (docs/NOYAU.md, § 3)
raison(Fs, Es, Vs, _, construction_negative(A)) :-
    member(polarite(A, neg), Fs), ( memberchk(A, Es) ; memberchk(A, Vs) ; assertion_de_portee(Fs, Es, A) ).
raison(Fs, Es, Vs, _, construction_modale(M)) :-
    member(modalite(A, M), Fs), M \== affirme, ( memberchk(A, Es) ; memberchk(A, Vs) ; assertion_de_portee(Fs, Es, A) ).
assertion_de_portee(Fs, Es, A) :-
    ( member(propriete(A, E, _, _), Fs) ; member(nom(A, E, _, _), Fs) ; member(relation(A, E, _, _, _), Fs) ), memberchk(E, Es), !.
raison(Fs, Es, _, _, metalangage(W)) :- member(E, Es), member(propriete(_, E, P, _), Fs), mot(P, W), metalangage(W).
raison(_, _, _, Cs, non_lie(Xs)) :- composantes(Cs, Ks), Ks = [_, _|_], maplist([K, X]>>( K = [X|_] ), Ks, Xs).
raison(_, _, Vs, Cs, evenement_sans_participant(V)) :- member(V, Vs), \+ memberchk(role(v(V), _, _), Cs).

% les composantes connexes du graphe de la requête (variables liées par rôle, relation, meme)
composantes(Cs, Ks) :-
    requetes:variables(Cs, Vs0), exclude(sans_atome(Cs), Vs0, Vs),
    composantes_(Vs, Cs, Ks).
sans_atome(Cs, V) :- V = v(_), \+ atome_sur(Cs, V).
atome_sur(Cs, V) :- member(A, Cs), requetes:atome(A), requetes:variables(A, Va), memberchk(V, Va), !.
composantes_([], _, []).
composantes_([V|Vs], Cs, [K|Ks]) :- atteint(Cs, [V], [V], K), subtract(Vs, K, Vs1), composantes_(Vs1, Cs, Ks).
atteint(Cs, Front, Vus, K) :-
    findall(Y, ( member(X, Front), lien(Cs, X, Y), \+ memberchk(Y, Vus) ), Ys0), sort(Ys0, Ys),
    ( Ys == [] -> K = Vus ; append(Vus, Ys, V1), atteint(Cs, Ys, V1, K) ).
lien(Cs, X, Y) :- member(C, Cs), ( C = role(A, _, B) ; C = relation(A, _, B) ; C = meme(A, B) ), ( X == A, Y = B ; X == B, Y = A ).

% la condition nécessaire : les seuls types et noms
necessaire(Cs, Fn) :-
    include([C]>>( C = type(_, _) ; C = nom(_, _) ; C = genre(_) ), Cs, Ns0),
    ( Ns0 == [] -> include([C]>>( C = evenement(_, _) ), Cs, Ns) ; Ns = Ns0 ),
    Ns \== [], et_ou_un(Ns, Fn).

% un mot plein du libellé (nom, verbe, adjectif) sans atome dans la requête : la requête n'en dit pas tout
mots_non_couverts(L, Ph, Cs, Rs) :-
    findall(non_couvert(W), ( member(phrase(Ms), Ph), member(M, Ms), M = mot(_, F, _, C, _, _, _, _, _),
                              memberchk(C, ['NOUN', 'VERB', 'ADJ']), \+ definitions:mot_ferme(F), \+ metalangage_mot(F),
                              definitions:lemme(L, M, W), \+ couvert(Cs, W) ), Rs0), sort(Rs0, Rs).
metalangage_mot(F) :- downcase_atom(F, W), ( metalangage(W) ; definitions:metalangage(W) ), !.
couvert(Cs, W) :- member(C, Cs), arg(_, C, X), atom(X), ( X == W ; sub_atom(X, _, _, _, W) ), !.
couvert(Cs, W) :- member(nom(_, Ks), Cs), member(K, Ks), upcase_atom(W, Wu), sub_atom(K, _, _, _, Wu), !.

debuts_du_segment(S, Ds) :- findall(X, member(mot(_, _, _, _, _, _, _, X, _), S), Ds).

% une parenthèse en minuscules exigée par la grammaire des libellés (definitions.pl : « facultatif » au sens du
% prétraitement, qui la garde pour l'exiger) : ses mots ne sont pas lus en graphe à ce jalon ; la requête est partielle
parentheses_non_lues(N, L, Rs) :-
    ( libelles_lus:partie(N, L, 1, _, _, Ms, _) -> true ; Ms = [] ),
    findall(parenthese_non_lue(C), ( member(facultatif(C), Ms), definitions:mots_de_parenthese(L, C, [_|_]) ), Rs).

% une subdivision d'une notation de personne : du texte après la parenthèse du nom (11I62(ADAM)11, 11H(PETER)5)
subdivision_de_personne(N) :- sub_atom(N, _, 1, A, ')'), A > 0, \+ sub_atom(N, _, _, _, '(+'), !.

% --- Les noms, les aspects, l'héritage --------------------------------------------------------------------------------

noms(N, L, Ks) :- definitions:definition(N, L, def(_, Ex, _, _, _)), member(un_de([[nom(Ks)]]), Ex), is_list(Ks), !.

% les aspects d'une notation à personne (« - miraculous activities and events ») : le graphe de chaque partie de gabarit
aspects(N, L, Gs, Rs) :-
    findall(F-Ra, ( libelles_lus:partie(N, L, R, gabarit, Net, _, Ph), R > 1, \+ definitions:lettres_doublees(Net),
                    graphe(N, L, Net, Ph, Fs), graphe_requete(Fs, all, Cs, Ra0), Cs \== [],
                    et_ou_un(Cs, F), Ra = [aspect_non_lie_a_la_personne|Ra0] ), Ps),
    pairs_keys_values(Ps, Gs0, Rss), renommer_aspects(Gs0, 1, Gs), append(Rss, Rs1),
    % une partie de gabarit dont la lecture ne donne aucune condition (« ~ cold », un adjectif seul) n'est pas lue :
    % la requête n'en dit pas tout
    findall(aspect_non_lu(Net), ( libelles_lus:partie(N, L, R, gabarit, Net, _, Ph), R > 1,
                                  \+ definitions:lettres_doublees(Net), graphe(N, L, Net, Ph, Fs),
                                  graphe_requete(Fs, all, [], _),
                                  mots_non_couverts(L, Ph, [], [_|_]) ), Rs2),
    append(Rs1, Rs2, Rs0), sort(Rs0, Rs).
renommer_aspects([], _, []).
renommer_aspects([G|Gs], I, [G1|Gs1]) :- prefixer(I, G, G1), I1 is I + 1, renommer_aspects(Gs, I1, Gs1).
prefixer(I, v(X), v(Y)) :- !, format(atom(Y), "a~w_~w", [I, X]).
prefixer(I, T, T1) :- compound(T), !, T =.. [F|As], maplist(prefixer(I), As, As1), T1 =.. [F|As1].
prefixer(_, T, T).

% la personne du récit ou de l'individu dont la notation fait partie (FONDEMENTS § 3.4) : sur la variable qui porte
% déjà l'un de ses noms, sinon sur une variable de plus (la personne est dans l'image, son rôle n'est pas dit)
heritage(N, L, Cs0, Cs) :-
    (   arbre:ancetre(N, A), personne_de(A, L, Ks)
    ->  (   select(nom(X, [K]), Cs0, nom(X, Ks2), Cs), memberchk(K, Ks) -> union([K], Ks, Ks2)
        ;   member(nom(_, Ks1), Cs0), intersection(Ks1, Ks, [_|_]) -> Cs = Cs0
        ;   append(Cs0, [nom(v(personne), Ks)], Cs)
        )
    ;   Cs = Cs0
    ).

% la personne d'une notation ancêtre : un individu, un récit « (story of) X », ou un libellé « story of X »,
% « histoire de X » sans parenthèses (« story of Elijah (Elias) » : le même récit, que la typologie range en classe)
personne_de(A, L, Ks) :- definitions:type_libelle(A, TA), memberchk(TA, [individu, recit]), noms(A, L, Ks), !.
personne_de(A, L, Ks) :-
    libelles_lus:partie(A, L, 1, _, Net, _, Ph),
    member(Debut, ['story of ', 'the story of ', 'histoire de ', 'histoire d\'', 'l\'histoire de ']), atom_concat(Debut, _, Net),
    graphe(A, L, Net, Ph, Fs), findall(K, ( member(nom(_, _, Nom, _), Fs), raisonnement:normaliser_nom(Nom, K) ), Ks0),
    sort(Ks0, Ks), Ks \== [], !.

% --- Les notations à nom construites sur un gabarit -------------------------------------------------------------------

nom_de_gabarit(N, Nom, G) :-
    \+ sub_atom(N, _, _, _, '(...)'), sub_atom(N, B, 1, _, '('), \+ sub_atom(N, _, _, _, '(+'),
    sub_atom(N, 0, B, _, Racine), atom_concat(Racine, '(...)', G), iconclass:n(G),
    B1 is B + 1, sub_atom(N, E, 1, _, ')'), E > B1, !, Lg is E - B1, sub_atom(N, B1, Lg, _, Nom).

genre_du_gabarit(G, L, Ts) :-
    libelles_lus:partie(G, L, 1, _, Net, Ms, Ph),
    definitions:conditions(classe, G, L, Net, Ph, Ms, Cs), memberchk(tete(r, Ts), Cs), !.

% une notation d'une section à lettres doublées : une lettre majuscule répétée après la division (« 31AA4631 »,
% « 25FF711(…) », « 11HH(BARBARA)32 »)
lettres_doublees(N) :- atom_codes(N, Cs), append(_, [A, A|_], Cs), code_type(A, upper), \+ code_type(A, digit(_)),
    append(Av, [A, A|_], Cs), \+ ( member(X, Av), X == 0'( ), !.

% les têtes d'un nom de gabarit (PEAR-TREE) : en anglais, le lemme (« pear tree », « pear-tree ») ; en français, les
% mots de WOLF des sens anglais de ce lemme
tetes_du_nom(en, Nom, Ts) :- formes_anglaises(Nom, Ts).
tetes_du_nom(fr, Nom, Ts) :-
    formes_anglaises(Nom, Fs),
    findall(W, ( member(F, Fs), wordnet:s(S, _, F, n, _, _), ressources:wolf(S, W) ), Ws0), sort(Ws0, Ts0),
    ( Ts0 == [] -> Ts = Fs ; Ts = Ts0 ).
formes_anglaises(Nom, Ts) :-
    downcase_atom(Nom, W0), atomic_list_concat(Ps, '-', W0), atomic_list_concat(Ps, ' ', W1),
    findall(W, ( member(W, [W0, W1]), wordnet:s(_, _, W, n, _, _) ), Ws0), sort(Ws0, Ws),
    ( Ws == [] -> Ts = [W0] ; Ts = Ws ).

% --- Les familles ---------------------------------------------------------------------------------------------------

% la forme d'une requête : le type du libellé, le nombre d'alternatives (1, 2 ou plus) et, pour chacune, les sortes
% d'atomes qu'elle contient (sans les mots) ; « classe/1/[propriete,type] »
famille(Type, F, Type/NA/Formes) :-
    ( F = ou(As) -> length(As, NA0), ( NA0 > 2 -> NA = n ; NA = NA0 ) ; As = [F], NA = 1 ),
    findall(Fo, ( member(A, As), forme(A, Fo) ), Fos0), sort(Fos0, Formes).
forme(A, Fo) :- requetes:atomes(A, Xs), findall(P, ( member(_-X, Xs), functor(X, P, _) ), Ps), sort(Ps, Fo).
