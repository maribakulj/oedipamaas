/*  Les gabarits à nom (conception 1.0, § 8 ; R3, taxinomie WordNet) : Iconclass ouvre 601 notations « (...) » à un
    nom libre ; celles dont le libellé dit « X (with NAME) » attendent le nom d'une chose de la sorte X — « insects
    (with NAME) », « flowers (with NAME) », « stringed instruments (with NAME) ». Seuls quelques noms y sont listés
    (25G41(ROSE)) ; les autres s'écrivent : la description dit « butterfly », WordNet range le papillon parmi les
    insectes, le moteur propose 25F711(BUTTERFLY).

    Sorte d'un gabarit : chaque élément de X (« plants and herbs » : plants, herbs ; « other percussion instruments » :
    percussion instruments), lu comme un nom commun de WordNet (la forme ou son lemme), sous ses sens dominants. Un
    élément que WordNet ne connaît pas (« predatory birds ») ne donne pas de sorte : rien n'est deviné.

    Une forme décrite W (nom commun, sens dominants) appartient à la sorte S si S est l'un de ses hyperonymes (classes
    d'instances comprises), à un pas ou plus : W plus précis que la sorte, jamais la sorte elle-même. Pour chaque W, on
    garde les gabarits les plus précis qui l'accueillent (25F33(...) « predatory birds » plutôt que 25F3(...) « birds »,
    quand les deux le peuvent), et on écarte ceux où Iconclass liste déjà ce nom (la recherche les trouve). Le nom
    s'écrit comme Iconclass écrit les siens : en capitales (25G41(TULIP)).

    Index (construit une fois, module gabarits_index) : sorte(Synset, Gabarit), nom_liste(Gabarit, Forme).
*/
:- module(noms, [ construire_gabarits/1,  % +Fichier
                  sortes/2,               % +Gabarit, -Synsets (calculées depuis le libellé)
                  gabarits_decrits/1      % -Liste de nomme(Code, Forme, Pas) pour la description courante
                ]).

:- use_module(lexique).
:- use_module(morphologie).
:- use_module(libelles).
:- use_module(notation).
:- use_module(specialisation).

% --- Index ----------------------------------------------------------------------------------------------------------

construire_gabarits(Fichier) :-
    setup_call_cleanup(
        open(Fichier, write, S, [encoding(utf8)]),
        ( format(S, ":- module(gabarits_index, [sorte/2, nom_liste/2]).~n:- encoding(utf8).~n", []),
          format(S, ":- discontiguous sorte/2, nom_liste/2.~n", []),
          forall(( gabarit_a_nom(G), sortes(G, Ss), member(Sy, Ss) ), format(S, "sorte(~q, ~q).~n", [Sy, G])),
          forall(( gabarit_a_nom(G), iconclass:enfant(G, N, _), N \== G, nom_de(N, F) ),
                 format(S, "nom_liste(~q, ~q).~n", [G, F])) ),
        close(S)).

% un gabarit ouvert à un nom de chose : notation « …(...) », libellé simple « X (with NAME) », et Iconclass y range
% surtout des noms communs — plus de la moitié de ses noms listés sont des noms communs de WordNet (25G41 : anemone,
% buttercup, carnation… ; mais 82B, « fictional animals, plants, objects », range Durindana et Baiardo, et 61D,
% « geographical names », n'en liste aucun : ils attendent des noms propres)
gabarit_a_nom(G) :-
    iconclass:n(G), sub_atom(G, _, _, 0, '(...)'),
    iconclass:libelle(G, en, T),
    sub_atom(T, B, _, 0, ' (with NAME)'), sub_atom(T, 0, B, _, X),
    \+ sub_atom(X, _, _, _, ' - '), \+ sub_atom(X, _, _, _, ':'),
    findall(F, ( iconclass:enfant(G, N, _), N \== G, nom_de(N, F) ), Fs),
    length(Fs, K), K > 0,
    aggregate_all(count, ( member(F, Fs), once(wordnet:s(_, _, F, n, _, _)) ), C),
    2 * C > K.

% une sorte est une chose physique (sous « physical entity » dans WordNet : animal, plante, minéral, instrument,
% pigment) ; un groupe, un peuple, un courant, un État sont des abstractions : « (with NAME) » y attend un nom propre
sortes(G, Synsets) :-
    iconclass:libelle(G, en, T), sub_atom(T, B, _, 0, ' (with NAME)'), sub_atom(T, 0, B, _, X),
    findall(Sy, ( element_de(X, E), forme_nominale(E, F), lexique:sens_dominant(F, Sy),
                  morphologie:forme_synset(F, n, Sy), physique(Sy) ), Ss0),
    sort(Ss0, Synsets).

physique(S) :-
    once(wordnet:s(P, _, 'physical entity', n, 1, _)),
    ( S == P -> true ; once(hyperonyme(S, P, _)) ).

% les éléments d'une sorte : « a, b and c » → a, b, c ; sans « other » ni « (other) » en tête
element_de(X, E) :-
    atomic_list_concat(Parties, ', ', X),
    member(P0, Parties),
    atomic_list_concat(Ps, ' and ', P0),
    member(P1, Ps),
    normalize_space(atom(P2), P1),
    sans_tete(P2, E),
    E \== ''.

% « (other) », « other » et le « and » d'une virgule d'Oxford (« …, and paints ») ôtés en tête
sans_tete(P, E) :-
    (   member(T, ['(other) ', 'other ', 'and ']), atom_concat(T, R, P) -> sans_tete(R, E) ; E = P ).

% la forme nominale d'un élément : elle-même ou l'un de ses lemmes, nom commun de WordNet
forme_nominale(E, F) :-
    lexique:forme_de(E, F0),
    distinct(F, ( F = F0 ; morphologie:tous_lemmes(F0, Ls), member(F, Ls) )),
    morphologie:forme_connue(F, n).

% le nom d'une notation nommée, sous sa forme (minuscules) : 25G41(ROSE) → rose
nom_de(N, F) :-
    catch(notation:analyser(N, Ns), _, fail), Ns \= composee(_),
    last(Ns, nom(Nom)), lexique:forme_de(Nom, F).

% --- Proposer des noms ----------------------------------------------------------------------------------------------

:- table hyperonyme/3.
hyperonyme(S, A, 1) :- monte(S, A).
hyperonyme(S, A, D) :- monte(S, B), hyperonyme(B, A, D0), D is D0 + 1.

monte(S, P) :- wordnet:hyp(S, P).
monte(S, P) :- wordnet:ins(S, P).

% gabarits_decrits(-Liste) : nomme(Code, Forme, Pas) pour chaque nom décrit qu'un gabarit accueille, Pas : le plus
% court chemin dans WordNet de la forme à la sorte du gabarit
gabarits_decrits(Liste) :-
    findall(nomme(C, W, D), nomme(C, W, D), L0),
    sort(L0, Liste).

nomme(Code, W, Pas) :-
    distinct(W, specialisation:decrit(W)),
    nom_commun(W, S),
    \+ gabarits_index:nom_liste(_, W),                  % un nom listé quelque part : la recherche le trouve
    \+ ( alternatives_index:nb_alt(N, J, 1), alternatives_index:alt(N, J, 1, W) ),   % une notation le dit déjà
                                                        % (« dog » : 34B11 ; pas 25F29(DOG), « other mammals »)
    findall(G-D, accueil(S, G, D), GDs0),
    GDs0 \== [],
    keysort(GDs0, GDs1), group_pairs_by_key(GDs1, Groupes),
    findall(G-Dm, ( member(G-Ds, Groupes), min_list(Ds, Dm) ), GDs),
    member(G-Pas, GDs),
    \+ ( member(G2-_, GDs), G2 \== G, plus_precis(G2, G) ),
    sub_atom(G, 0, _, 5, Base),                         % « 25G41(...) » → « 25G41 »
    upcase_atom(W, Nom),
    atomic_list_concat([Base, '(', Nom, ')'], Code).

% W, nom commun : un lemme de WordNet écrit en minuscules (ni nom propre ni abréviation : « Th », « Dutch »), plus
% souvent nom qu'autre chose (occurrences annotées : « grey » est d'abord un adjectif), pris dans son premier sens
% (« sitter » : celui qui pose, pas la couveuse)
nom_commun(W, S) :-
    atom_length(W, L), L >= 3,
    wordnet:s(S, _, W, n, 1, _),
    aggregate_all(max(C), wordnet:s(_, _, W, n, _, C), Cn),
    \+ ( wordnet:s(_, _, W, T, _, C2), T \== n, C2 > Cn ).

accueil(S, G, D) :-
    hyperonyme(S, A, D),
    gabarits_index:sorte(A, G).

% G2 est plus précis que G : sa base prolonge celle de G (25F33(...) sous 25F3(...))
plus_precis(G2, G) :-
    sub_atom(G2, 0, _, 5, B2), sub_atom(G, 0, _, 5, B),
    B2 \== B, sub_atom(B2, 0, _, _, B).
