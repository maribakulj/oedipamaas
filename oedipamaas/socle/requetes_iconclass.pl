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
:- use_module(normalisation, []).
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
    tetes_du_nom(N, L, Nom, Ts), Ts \== [],
    findall(type(v(x), T), member(T, Ts), As), ou_ou_un(As, Fnom),
    % le genre que donne le libellé du gabarit (« bottles » pour PELICAN, « trees » pour PEAR-TREE) : sur la même
    % variable ; impliqué quand le nom n'a qu'un sens, il écarte les autres sens quand il en a plusieurs. Quand aucun
    % sens du nom n'atteint aucune tête du genre dans K (« light, fire, smoke… used for signalling : rocket »), la
    % conjonction serait insatisfaisable : le genre n'est pas exigé, et la requête le dit (D6)
    (   genre_du_gabarit(G, L, Gs), Gs \== []
    ->  (   genre_compatible(L, Ts, Gs)
        ->  findall(type(v(x), Tg), member(Tg, Gs), Ags), ou_ou_un(Ags, Fg), F = et([Fnom, Fg]), Rg = []
        ;   F = Fnom, Rg = [genre_du_gabarit_incompatible(G)]
        )
    ;   F = Fnom, Rg = []
    ),
    Fn = Fnom,
    ( L == fr, formes_anglaises(Nom, Ts) -> Rs0 = [nom_sans_traduction(Nom)] ; Rs0 = [] ), append(Rs0, Rg, Rs).
compiler_(N, L, T, T, F, Fn, Rs) :-                             % une subdivision dont la première partie n'est que
    T \== scene, ( memberchk(T, [individu, recit]) ; libelles_iconclass:gabarit_de_personnes(N) ),  % la glose de la
    subdivision_de_personne(N), glose(N, L), noms(N, L, Ks), Ks \== [], !,                         % personne (D8)
    aspects(N, L, Gs, Ra),
    append([[nom(v(p), Ks)], Gs], Cs), et_ou_un(Cs, F), Fn = nom(v(p), Ks), Rs = Ra.
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
compiler_(N, L, scene, scene, F, Fn, Rs) :-                    % une énumération sans verbe conjugué (D1) : des
    partie(N, L, Net, Ph), graphe(N, L, Net, Ph, Fs),            % alternatives, comme une classe
    graphe_requete(Fs, Ph, all, Cs0, Ra0), memberchk(non_lie(_), Ra0), \+ memberchk(meme(_, _), Cs0),   % une apposition
    enumeration(Ph, Ss), !,                                                                               % n'en est pas une
    alternatives(N, L, Fs, Ss, F, Fn, Rs).
compiler_(N, L, scene, scene, F, Fn, Rs) :- !,
    partie(N, L, Net, Ph), graphe(N, L, Net, Ph, Fs),
    graphe_requete(Fs, Ph, all, Cs0, Ra),
    heritage(N, L, Cs0, Cs1), liens_apres_heritage(Cs0, Cs1, Rh),
    aspects(N, L, Gs, Rg), append(Cs1, Gs, Cs),
    Cs \== [], et_ou_un(Cs, F), necessaire(Cs1, Fn), mots_non_couverts(L, Ph, Cs1, Rm),
    parentheses_non_lues(N, L, Rp), append([Ra, Rh, Rm, Rg, Rp], Rs).
compiler_(N, L, classe, classe, F, Fn, Rs) :- !,
    partie(N, L, Net, Ph), graphe(N, L, Net, Ph, Fs),
    definitions:mots(Ph, Ws0), definitions:defini(Ws0, Ws), definitions:segments_complets(L, Ws, Ss0),
    % des segments à tête verbale (« recouvrir, tapisser ») que segments_complets réunit faute de nom : l'énumération
    % les garde séparés (D1)
    ( enumeration(Ph, Se), length(Se, Ne), length(Ss0, N0), Ne > N0 -> Ss = Se ; Ss = Ss0 ),
    alternatives(N, L, Fs, Ss, F, Fn, Rs).

% les alternatives d'une énumération : une par segment, chacune le graphe du lecteur restreint à ses mots
alternatives(N, L, Fs, Ss, F, Fn, Rs) :-
    partie(N, L, _, Ph),
    findall(Cs1-Ra-S, ( member(S, Ss), debuts_du_segment(S, Ds), graphe_requete(Fs, Ph, debuts(Ds), Cs0, Ra0), Cs0 \== [],
                       heritage(N, L, Cs0, Cs1), liens_apres_heritage(Cs0, Cs1, Rh), append(Ra0, Rh, Ra) ), Alts0),
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
graphe_requete(Fs, Por, Cs, Rs) :- graphe_requete(Fs, [], Por, Cs, Rs).
% avec l'analyse du libellé (Ph), les conditions sont corrigées (corrections du 27/11, plus bas)
graphe_requete(Fs, Ph, Por, Cs, Rs) :-
    findall(E, ( member(entite(E, _, P), Fs), dans(Fs, P, Por) ), Es),
    findall(V, ( member(evenement(V, _, P), Fs), dans(Fs, P, Por) ), Vs),
    findall(C, condition(Fs, Es, Vs, C), Cs00), list_to_set(Cs00, Cs01),
    corriger_avant(Ph, Fs, Cs01, Cs02), composes(Cs02, Cs03), corriger_apres(Ph, Fs, Cs03, Cs0), list_to_set(Cs0, Cs1),
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
    (   L == en -> ( member(Sep, [' ', '', '-']), atomic_list_concat([P, T], Sep, W) )   % « trademark » (D3)
    ;   atomic_list_concat([T, P], ' ', W)
    ),
    lexicalise(L, W), !.
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
                              definitions:lemme(L, M, W), \+ couvert(Cs, W), \+ couvert_soude(Ph, Cs, W),
                              \+ ( singulier_de(L, W, Sg), couvert(Cs, Sg) ) ), Rs1),
    % un mot qui dit plusieurs individus distincts (« différents mammifères », « various ») : les requêtes compilées ne
    % comptent pas les référents ; la requête est partielle (27/11 : 43C11121 devenait compilée et trop faible une fois
    % son lemme pluriel couvert, D4)
    findall(pluralite(W), ( member(phrase(Ms), Ph), member(M, Ms), arg(2, M, F), downcase_atom(F, W),
                            pluralite_distincte(W) ), Rs2),
    append(Rs1, Rs2, Rs0), sort(Rs0, Rs).
pluralite_distincte(W) :- memberchk(W, [different, various, several, différents, différentes, divers, diverses, plusieurs]).
% un composé que la langue écrit soudé (« trademark » pour « trade mark », D3) couvre ses deux mots du libellé
couvert_soude(Ph, Cs, W) :-
    sous_condition(Cs, type(_, X)), atom(X), member(phrase(Ms), Ph), member(M1, Ms), member(M2, Ms),
    arg(1, M1, I1), I2 is I1 + 1, arg(1, M2, I2), arg(2, M1, F1), arg(2, M2, F2),
    downcase_atom(F1, A), downcase_atom(F2, B), ( atom_concat(A, B, X) ; atomic_list_concat([A, B], '-', X) ),
    ( W == A ; W == B ), !.
metalangage_mot(F) :- downcase_atom(F, W), ( metalangage(W) ; definitions:metalangage(W) ), !.
% un mot est couvert par un atome qui le porte comme mot entier : l'argument lui-même, ou l'un des mots d'un composé
% (séparés par une espace, un trait d'union ou une apostrophe) ; pour un nom, l'un de ses mots, en majuscules. Jamais
% une sous-chaîne : « woman » ne couvre pas « man » (docs/QUALIFICATION_NOYAU.md, D17)
couvert(Cs, W) :- sous_condition(Cs, C), arg(_, C, X), atom(X), ( X == W -> true ; mots_du_terme(X, Ms), memberchk(W, Ms) ), !.
couvert(Cs, W) :- sous_condition(Cs, nom(_, Ks)), member(K, Ks), upcase_atom(W, Wu), mots_du_terme(K, Ms), memberchk(Wu, Ms), !.
couvert(Cs, W) :-                                % un nom d'action ou un gérondif couvert par son événement (D2)
    nb_current(definitions_langue, L), sous_condition(Cs, evenement(_, V)), atom(V), forme_d_action(L, V, W), !.
sous_condition(Cs, C) :- member(C0, Cs), ( C0 = et(As) -> sous_condition(As, C) ; C0 = ou(As) -> sous_condition(As, C) ; C = C0 ).
mots_du_terme(X, Ms) :- split_string(X, " -'’", " -'’", Ps), exclude(==(""), Ps, Ps1), maplist(atom_string, Ms, Ps1).

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
                    graphe(N, L, Net, Ph, Fs), requete_de_partie(Fs, Ph, F, Ra0),
                    Ra = [aspect_non_lie_a_la_personne|Ra0] ), Ps),
    pairs_keys_values(Ps, Gs0, Rss), renommer_aspects(Gs0, 1, Gs), append(Rss, Rs1),
    % une partie de gabarit dont la lecture ne donne aucune condition (« ~ cold », un adjectif seul) n'est pas lue :
    % la requête n'en dit pas tout
    findall(aspect_non_lu(Net), ( libelles_lus:partie(N, L, R, gabarit, Net, _, Ph), R > 1,
                                  \+ definitions:lettres_doublees(Net), graphe(N, L, Net, Ph, Fs),
                                  graphe_requete(Fs, Ph, all, [], _),
                                  mots_non_couverts(L, Ph, [], [_|_]) ), Rs2),
    append(Rs1, Rs2, Rs0), sort(Rs0, Rs).
renommer_aspects([], _, []).
renommer_aspects([G|Gs], I, [G1|Gs1]) :- prefixer(I, G, G1), I1 is I + 1, renommer_aspects(Gs, I1, Gs1).
prefixer(I, v(X), v(Y)) :- !, format(atom(Y), "a~w_~w", [I, X]).
prefixer(I, T, T1) :- compound(T), !, T =.. [F|As], maplist(prefixer(I), As, As1), T1 =.. [F|As1].
prefixer(_, T, T).

% la personne du récit ou de l'individu dont la notation fait partie (FONDEMENTS § 3.4) : sur la variable qui porte
% déjà l'un de ses noms, sinon sur une variable de plus (la personne est dans l'image, son rôle n'est pas dit)
% la personne héritée ajoutée comme une variable de plus n'est liée à rien : la requête dirait sa présence, pas sa
% participation (D18) ; le graphe de la requête n'est plus connexe, elle est partielle et ne peut rien établir
liens_apres_heritage(Cs0, Cs1, Rs) :-
    (   Cs0 == Cs1 -> Rs = []
    ;   composantes(Cs1, Ks), Ks = [_, _|_] -> Rs = [personne_heritee_non_liee]
    ;   Rs = []
    ).

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
tetes_du_nom(_, en, Nom, Ts) :- formes_anglaises(Nom, Ts).
% en français, quand le libellé français nomme la chose après son dernier « : » (« … : fusée »), la tête est ce mot :
% les mots de WOLF de tous les sens anglais du nom (« rocket » : « eruca sativa », la roquette) ne sont pas ceux du
% libellé, et WOLF traduit même ce sens-là par « fusée » ; les sens de « fusée » sont ceux de K (D30) (D5)
tetes_du_nom(N, fr, _, [Tf]) :- terme_francais(N, Tf), !.
tetes_du_nom(_, fr, Nom, Ts) :-
    formes_anglaises(Nom, Fs),
    findall(W, ( member(F, Fs), wordnet:s(S, _, F, n, _, _), ressources:wolf(S, W) ), Ws0), sort(Ws0, Ts0),
    ( Ts0 == [] -> Ts = Fs ; Ts = Ts0 ).
terme_francais(N, Tf) :-
    libelles_lus:partie(N, fr, 1, _, Net, _, _), sub_atom(Net, B, 1, _, ':'), \+ ( sub_atom(Net, B2, 1, _, ':'), B2 > B ), !,
    B1 is B + 1, sub_atom(Net, B1, _, 0, T0), normalize_space(atom(T1), T0), downcase_atom(T1, Tf), Tf \== '',
    \+ sub_atom(Tf, _, _, _, ','), \+ sub_atom(Tf, _, _, _, ';').
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

% --- Les corrections du 27/11 (expérience croisée, docs/mesures/C3_CORRECTIONS.md) -----------------------------------
%
% Des corrections linguistiques générales, sans aucune règle propre à une notation. Chacune a son contre-exemple
% (tests/plunit/test_compilateur.pl).
%   D4  un mot sans sens dans la langue, dont le singulier en a un (« organes ») : le singulier
%   D3  un nom modifieur d'un composé (« trade card ») n'est pas une variable libre : il devient une propriété de sa
%       tête (« card{trade} », la forme du guide), que composes/2 réunit en un type quand la langue lexicalise le
%       composé ; un complément du nom que le lecteur n'a pas relié (« contrôle des naissances », où l'analyseur lit
%       « des » comme un article) est relié à sa tête par « de » / « of »
%   D7  un participe lu comme propriété (« a serpent … is made ») est un événement dont le porteur est le patient
%       (participe passé) ou l'agent (participe présent) ; un complément de matière (« of brass » : la première
%       acception du nom est une substance) se lit aussi comme une propriété (« serpent{brass} », la forme du guide)
%   D2  un nom d'action seul (« imprisonment ») ou un gérondif (« upholstering ») est l'événement de son verbe (la
%       forme du guide : une action est un événement), quand la première acception du nom est une action
%   D1  une énumération sans verbe conjugué (« planing, filing, abrading ») est une disjonction, comme une classe
%   D6  le genre d'un gabarit qu'aucun sens du nom n'atteint n'est pas exigé
%   D5  en français, les sens d'un nom de gabarit sont ceux que le libellé français nomme
%   D8  la glose d'une personne (« the schoolmaster, martyr and bishop, Cassian of Imola ») n'est pas une condition
%       suffisante : la personne est donnée par ses noms

corriger_avant(Ph, Fs, Cs0, Cs) :-
    nb_current(definitions_langue, L), !,
    maplist(singulier(L), Cs0, Cs1),
    ( Ph == [] -> Cs = Cs1 ; composes_syntaxiques(L, Ph, Fs, Cs1, Cs2), complements_non_lus(L, Ph, Fs, Cs2, Cs) ).
corriger_avant(_, _, Cs, Cs).
corriger_apres(Ph, Fs, Cs0, Cs) :-
    nb_current(definitions_langue, L), !,
    matieres(L, Cs0, Cs1),
    (   Ph == [] -> Cs = Cs1
    ;   participes(L, Ph, Fs, Cs1, Cs2), sujets_partages(Ph, Fs, Cs2, Cs3), actions(L, Ph, Fs, Cs3, Cs)
    ).
corriger_apres(_, _, Cs, Cs).

% D7 : deux verbes coordonnés sans sujet propre partagent le sujet du premier (« a serpent … is made and is set on a
% pole ») : le patient d'un passif, l'agent d'un actif
sujets_partages(Ph, Fs, Cs0, Cs) :-
    (   member(phrase(Ms), Ph), member(Mc, Ms), Mc = mot(Ic, _, _, 'VERB', Fc, Ih, conj, _, _),
        \+ ( member(mot(_, _, _, _, _, Ic, D, _, _), Ms), memberchk(D, [nsubj, 'nsubj:pass', csubj]) ),
        member(mot(_, _, _, 'NOUN', _, Ih, Ds, Ds0, _), Ms), memberchk(Ds, [nsubj, 'nsubj:pass']),
        member(entite(E, _, Pe), Fs), memberchk(passage(Pe, Ds0, _), Fs),
        arg(8, Mc, Dc), member(evenement(V, _, Pv), Fs), memberchk(passage(Pv, Dc, _), Fs),
        memberchk(evenement(v(V), _), Cs0), \+ memberchk(role(v(V), _, v(E)), Cs0),
        ( memberchk('Voice'='Pass', Fc) -> R = patient ; R = agent ),
        \+ memberchk(role(v(V), R, _), Cs0)
    ->  sujets_partages(Ph, Fs, [role(v(V), R, v(E))|Cs0], Cs)
    ;   Cs = Cs0
    ).

% le mot d'une assertion du graphe dans l'analyse du libellé : par le début de son passage
mot_du_passage(Fs, Ph, P, M) :-
    memberchk(passage(P, D, _), Fs), member(phrase(Ms), Ph), member(M, Ms), arg(8, M, D), !.
entite_du_mot(Fs, M, E) :- arg(8, M, D), member(entite(E, _, P), Fs), memberchk(passage(P, D, _), Fs), !.

% D4 : le singulier
singulier(L, type(X, W), type(X, S)) :- atom(W), \+ connu(L, n, W), singulier_de(L, W, S), connu(L, n, S), !.
singulier(L, propriete(X, W), propriete(X, S)) :- atom(W), \+ connu(L, a, W), singulier_de(L, W, S), connu(L, a, S), !.
singulier(_, C, C).
connu(en, n, W) :- wordnet:s(_, _, W, n, _, _), !.
connu(en, a, W) :- wordnet:s(_, _, W, P, _, _), memberchk(P, [a, s]), !.
connu(fr, n, W) :- ressources:wolf(S, W), S // 100000000 =:= 1, !.
connu(fr, a, W) :- ressources:wolf(S, W), S // 100000000 =:= 3, !.
singulier_de(en, W, S) :- wordnet:exc(n, W, S).
singulier_de(en, W, S) :- atom_concat(R, ies, W), atom_concat(R, y, S).
singulier_de(en, W, S) :- atom_concat(S, es, W).
singulier_de(en, W, S) :- atom_concat(S, s, W), \+ atom_concat(_, ss, W).
singulier_de(fr, W, S) :- atom_concat(R, aux, W), atom_concat(R, al, S).
singulier_de(fr, W, S) :- ( atom_concat(S, s, W) ; atom_concat(S, x, W) ), S \== ''.

% D3 : le nom modifieur d'un composé (« compound » de l'analyse) devient une propriété de sa tête
composes_syntaxiques(L, Ph, Fs, Cs0, Cs) :-
    (   member(phrase(Ms), Ph), member(Mm, Ms), Mm = mot(_, _, _, 'NOUN', _, Ih, compound, _, _),
        member(Mh, Ms), arg(1, Mh, Ih), arg(4, Mh, 'NOUN'),
        entite_du_mot(Fs, Mm, Em), entite_du_mot(Fs, Mh, Eh), Em \== Eh,
        select(type(v(Em), Tm), Cs0, Cs1), \+ autre_condition(Cs1, v(Em)), memberchk(type(v(Eh), _), Cs1)
    ->  composes_syntaxiques(L, Ph, Fs, [propriete(v(Eh), Tm)|Cs1], Cs)
    ;   Cs = Cs0
    ).
% un complément du nom de forme génitive que le lecteur n'a pas relié : « des », « du » lus comme articles (« contrôle
% des naissances »), ou « de », « of » sans relation lue
complements_non_lus(L, Ph, Fs, Cs0, Cs) :-
    (   member(phrase(Ms), Ph), member(Mc, Ms), Mc = mot(Ic, _, _, 'NOUN', _, Ih, nmod, _, _),
        member(Mh, Ms), arg(1, Mh, Ih), arg(4, Mh, 'NOUN'),
        member(mot(_, Fd, _, Cd, _, Ic, Dd, _, _), Ms), downcase_atom(Fd, D),
        genitif_du_libelle(L, Cd, Dd, D),
        entite_du_mot(Fs, Mc, Ec), entite_du_mot(Fs, Mh, Eh), Ec \== Eh,
        memberchk(type(v(Ec), _), Cs0), memberchk(type(v(Eh), _), Cs0), \+ relies(Cs0, v(Eh), v(Ec))
    ->  ( L == en -> R = of ; R = de ), complements_non_lus(L, Ph, Fs, [relation(v(Eh), R, v(Ec))|Cs0], Cs)
    ;   Cs = Cs0
    ).
genitif_du_libelle(fr, 'DET', det, D) :- memberchk(D, [des, du]).
genitif_du_libelle(fr, 'ADP', case, D) :- memberchk(D, [de, des, du, 'd\'', 'd’']).
genitif_du_libelle(en, 'ADP', case, of).
relies(Cs, X, Y) :- member(C, Cs), ( C = relation(A, _, B) ; C = role(A, _, B) ; C = meme(A, B) ),
    ( A == X, B == Y ; A == Y, B == X ), !.

% D7 : un complément de matière se lit aussi comme une propriété (une disjonction : la lecture littérale reste)
matieres(L, Cs0, Cs) :-
    (   select(relation(X, R, Y), Cs0, Cs1), memberchk(R, [of, de, en]), select(type(Y, T), Cs1, Cs2),
        \+ autre_condition(Cs2, Y), matiere(L, T)
    ->  matieres(L, [ou([propriete(X, T), et([relation(X, R, Y), type(Y, T)])])|Cs2], Cs)
    ;   Cs = Cs0
    ).
matiere(en, T) :- wordnet:s(S, _, T, n, 1, _), wordnet:lexfile(S, 'noun.substance'), !.
matiere(fr, T) :-                    % en français, sans ordre des sens : une acception de substance, aucune de personne
    ressources:wolf(S, T), S // 100000000 =:= 1, wordnet:lexfile(S, 'noun.substance'),
    \+ ( ressources:wolf(S2, T), S2 // 100000000 =:= 1, wordnet:lexfile(S2, 'noun.person') ), !.

% D7 : un participe lu comme propriété est un événement
participes(L, Ph, Fs, Cs0, Cs) :-
    (   select(propriete(v(E), P), Cs0, Cs1), member(propriete(Q, E, P0, Pp), Fs), mot(P0, P),
        mot_du_passage(Fs, Ph, Pp, M), arg(4, M, 'VERB'), arg(5, M, Ft), memberchk('VerbForm'='Part', Ft),
        verbe(L, P)
    ->  ( memberchk('Tense'='Pres', Ft) -> R = agent ; R = patient ),
        participes(L, Ph, Fs, [evenement(v(Q), P), role(v(Q), R, v(E))|Cs1], Cs)
    ;   Cs = Cs0
    ).
verbe(en, V) :- wordnet:s(_, _, V, v, _, _), !.
verbe(fr, V) :- ressources:wolf(S, V), S // 100000000 =:= 2, !.
verbe(fr, V) :- ( atom_concat(_, er, V) ; atom_concat(_, ir, V) ; atom_concat(_, re, V) ), !.   % un infinitif que WOLF n'a pas

% D2 : un nom d'action seul, ou un gérondif, est l'événement de son verbe
actions(L, Ph, Fs, Cs0, Cs) :-
    (   select(type(v(E), T), Cs0, []),                 % le nom d'action est toute la requête (de l'alternative) :
                                                        % ailleurs, il peut être un participant non relié (« fire »)
        member(entite(E, _, P), Fs), mot_du_passage(Fs, Ph, P, M), arg(4, M, 'NOUN'), arg(2, M, Forme0),
        downcase_atom(Forme0, Forme), verbe_d_action(L, T, Forme, V)
    ->  Cs = [evenement(v(E), V)]
    ;   Cs = Cs0
    ).
% en anglais : un gérondif (« upholstering ») dont WordNet n'a pas d'acception nominale autre qu'une action ; ou un nom
% dont la première acception est une action, dérivé d'un verbe (« imprisonment »)
verbe_d_action(en, _, Forme, V) :-
    atom_concat(R, ing, Forme), radical_de_gerondif(R, V), wordnet:s(_, _, V, v, _, _),
    \+ ( wordnet:s(S, _, Forme, n, _, _), wordnet:lexfile(S, F), \+ normalisation:lexfile_d_action(F) ), !.
verbe_d_action(en, T, _, V) :-
    wordnet:s(S, _, T, n, 1, _), wordnet:lexfile(S, F), normalisation:lexfile_d_action(F),
    normalisation:nominalisation(en, V, T), !.
% en français, WOLF n'ordonne pas les sens : l'acception la plus fréquente est celle dont les mots anglais ont le plus
% d'occurrences annotées dans WordNet ; elle est une action, et le verbe est de même radical
verbe_d_action(fr, T, _, V) :-
    synset_le_plus_frequent(T, S), wordnet:lexfile(S, F), normalisation:lexfile_d_action(F),
    normalisation:nominalisation(fr, V, T), V \== T, radical_commun(V, T), !.
synset_le_plus_frequent(T, S) :-
    findall(N-S0, ( ressources:wolf(S0, T), S0 // 100000000 =:= 1,
                    aggregate_all(sum(C), wordnet:s(S0, _, _, n, _, C), N) ), Ps),
    Ps \== [], max_member(_-S, Ps).
% le radical d'un gérondif : après consonne, voyelle, consonne non doublée, le « e » muet d'abord (« planing » : plane,
% « filing » : file ; « planning » : plan, « singing » : sing)
radical_de_gerondif(R, V) :- cvc(R), atom_concat(R, e, V).
radical_de_gerondif(R, R).
radical_de_gerondif(R, V) :- \+ cvc(R), atom_concat(R, e, V).
radical_de_gerondif(R, V) :-                                    % la consonne doublée (« setting » : set)
    atom_length(R, N), N > 2, sub_atom(R, _, 1, 0, C), sub_atom(R, _, 1, 1, C), sub_atom(R, 0, _, 1, V).
cvc(R) :-
    atom_chars(R, Cs), append(_, [C1, V, C2], Cs), voyelle(V), \+ voyelle(C1), \+ voyelle(C2), \+ memberchk(C2, [w, x, y]), !.
voyelle(C) :- memberchk(C, [a, e, i, o, u]).
radical_commun(V, T) :-
    ( atom_concat(Rv, er, V) ; atom_concat(Rv, ir, V) ; atom_concat(Rv, re, V) ), atom_length(Rv, N), N >= 4,
    sub_atom(T, 0, N, _, Rv), !.
forme_d_action(L, V, W) :-
    (   verbe_d_action(L, W, W, V0) -> V0 == V
    ;   L == en, atom_concat(R, ing, W), radical_de_gerondif(R, V)
    ).

% D1 : une énumération sans verbe conjugué ni auxiliaire ni nom propre, dont chaque segment a une tête (un nom, un
% verbe : gérondif, participe, infinitif) ; les segments d'exemple (« e.g. ») et « etc. » ne sont pas des alternatives
enumeration([phrase(Ms0)], Ss) :-
    definitions:defini(Ms0, Ms),
    memberchk(mot(_, ',', _, _, _, _, _, _, _), Ms),
    \+ ( member(M, Ms), arg(4, M, C), ( C == 'AUX' ; C == 'VERB', arg(5, M, Ft), memberchk('VerbForm'='Fin', Ft) ) ),
    definitions:segments(Ms, Ss0),
    exclude(definitions:segment_exemple, Ss0, Ss1), exclude(segment_etc, Ss1, Ss),
    Ss = [_, _|_], maplist(segment_a_tete, Ss), Ss = [_|Ss2], include(segment_parallele, Ss2, Sp), Sp \== [],
    forall(member(S, Ss2), ( memberchk(S, Sp) ; gerondif_de_liste(S) )),
    \+ ( member(M, Ms), arg(4, M, 'PROPN') ).    % un nom propre : une apposition (« Shiva, god of fertility »)
segment_etc(S) :- exclude([M]>>arg(4, M, 'PUNCT'), S, [mot(_, F, _, _, _, _, _, _, _)]), downcase_atom(F, W), memberchk(W, ['etc.', etc]).
segment_a_tete(S) :- member(M, S), arg(4, M, C), memberchk(C, ['NOUN', 'VERB']), !.
% un segment parallèle au premier : sa tête (le mot dont la tête syntaxique est hors du segment) est coordonnée, en
% liste ou en parataxe ; un participe qui modifie le premier (« domestic animals, kept in the house » : acl) ou une
% apposition n'est pas une alternative
segment_parallele(S) :-
    member(M, S), arg(6, M, H), \+ ( member(M2, S), arg(1, M2, H) ), arg(4, M, C), C \== 'PUNCT', !,
    arg(7, M, D), memberchk(D, [conj, list, parataxis, root]).
% dans une liste dont un autre segment est coordonné, un gérondif que l'analyseur rattache au premier comme modifieur
% (« baptism, consecration, taking vows… » : acl) est un segment parallèle ; seul, il resterait un modifieur
% (« a woman, holding a child »)
gerondif_de_liste(S) :-
    member(M, S), arg(6, M, H), \+ ( member(M2, S), arg(1, M2, H) ), arg(4, M, 'VERB'), !,
    arg(7, M, acl), arg(5, M, Ft), memberchk('VerbForm'='Part', Ft), memberchk('Tense'='Pres', Ft).

% une partie de libellé (un aspect) : sa requête ; une énumération y est une disjonction (D1)
requete_de_partie(Fs, Ph, F, Ra) :-
    graphe_requete(Fs, Ph, all, Cs, Ra0), Cs \== [],
    (   memberchk(non_lie(_), Ra0), \+ memberchk(meme(_, _), Cs), enumeration(Ph, Ss),
        findall(Fa-Rb, ( member(S, Ss), debuts_du_segment(S, Ds), graphe_requete(Fs, Ph, debuts(Ds), Ca, Rb),
                         Ca \== [], et_ou_un(Ca, Fa) ), Ps), Ps = [_, _|_]
    ->  pairs_keys_values(Ps, Fas, Rbs), ou_ou_un(Fas, F), append(Rbs, Ra1), sort(Ra1, Ra)
    ;   et_ou_un(Cs, F), Ra = Ra0
    ).

% D6 : un sens du nom atteint une tête du genre dans K (hyperonymie, instance)
genre_compatible(L, Ts, _) :- \+ ( member(T, Ts), synset_nom(L, T, _) ), !.   % un nom que K ne connaît pas : le genre
genre_compatible(L, Ts, Gs) :- member(T, Ts), member(G, Gs), atteint_genre(L, T, G), !.  % est son seul accès
atteint_genre(_, T, T) :- !.
atteint_genre(L, T, G) :- synset_nom(L, T, S), synset_nom(L, G, Sg), au_dessus(S, Sg), !.
synset_nom(en, W, S) :- wordnet:s(S, _, W, n, _, _).
synset_nom(fr, W, S) :- ressources:wolf(S, W), S // 100000000 =:= 1.
:- table au_dessus/2.
au_dessus(S, S).
au_dessus(S, P) :- ( wordnet:hyp(S, Q) ; wordnet:ins(S, Q) ), au_dessus(Q, P).

% D8 : la première partie d'une subdivision de personne n'est que sa glose : des noms, des types, des relations « of »,
% « de » vers un nom propre (un lieu), aucun événement
glose(N, L) :- partie(N, L, Net, Ph), graphe(N, L, Net, Ph, Fs), glose_faits(Fs).
glose_faits(Fs) :-
    \+ memberchk(evenement(_, _, _), Fs), memberchk(nom(_, _, _, _), Fs),
    forall(member(relation(_, _, R, E2, _), Fs), ( memberchk(R, [of, de, du, 'd\'']), memberchk(entite(E2, nom_propre, _), Fs) )).
