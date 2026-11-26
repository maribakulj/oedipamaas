/*  Le prototype vertical (25/11) : 200 définitions variées, à faire marcher de bout en bout avant les 40 000.
        swipl outils/definitions/tirage_vertical.pl BASE SORTIE.json GRAINE [EXCLURE.json…]
    (EXCLURE : des fiches déjà tirées, dont les notations sont exclues : l'ensemble de validation est disjoint de
    celui de développement)
    Strates (type de libellé et division d'Iconclass) :
      objets et animaux      40   classe, divisions 2 et 4 (hors 41D, 31A)
      vêtements, anatomie    30   classe, 41D (vêtements) et 31A (corps humain)
      personnes              30   individu
      actions, relations     40   scene, divisions 3 et 4
      scènes narratives      30   scene, divisions 7 et 9
      genres, allégories     15   genre et concept
      attributs              15   attribut
    (les clés « (+…) » ne sont pas encore définies : hors du prototype, dit comme tel)
    Chaque fiche : notation, strate, langue du prototype (alternée en / fr), libellés en et fr.  */
:- initialization(main, main).
:- use_module(library(json)).
:- use_module(library(random)).
:- dynamic exclu/1.

main :-
    current_prolog_flag(argv, [Base, Sortie, G0|Exclus]), atom_number(G0, G), set_random(seed(G)),
    forall(( member(X, Exclus), setup_call_cleanup(open(X, read, Sx, [encoding(utf8)]), json_read_dict(Sx, Fx), close(Sx)),
             member(F, Fx), atom_string(Nx, F.notation) ), assertz(exclu(Nx))),
    atom_concat(Base, '/iconclass.qlf', Ic), load_files(Ic, []),
    atom_concat(Base, '/definitions_index', Di), load_files(Di, []),
    Strates = [s(objets, 40), s(vetements_anatomie, 30), s(personnes, 30), s(actions, 40), s(narratives, 30),
               s(genres_allegories, 15), s(attributs, 15)],
    foldl(tirer, Strates, [], Fs0), reverse(Fs0, Fs1), append(Fs1, Fs),
    numerote(Fs, 1, Js),
    setup_call_cleanup(open(Sortie, write, S, [encoding(utf8)]), json_write_dict(S, Js, [width(120)]), close(S)),
    length(Js, N), format("~d fiches~n", [N]).

tirer(s(St, K), Acc, [Pk|Acc]) :-
    findall(N, ( definitions_index:definition(N, en, def(T, _, _, _, _)), definitions_index:definition(N, fr, _),
                 strate(St, T, N), \+ sub_atom(N, _, _, _, '(+'), \+ exclu(N) ), Ns0), sort(Ns0, Ns),
    random_permutation(Ns, P), length(Pk0, K), append(Pk0, _, P),
    findall(St-N, member(N, Pk0), Pk).

strate(objets, classe, N) :- sub_atom(N, 0, 1, _, D), memberchk(D, ['2', '4']), \+ sub_atom(N, 0, 3, _, '41D').
strate(vetements_anatomie, classe, N) :- ( sub_atom(N, 0, 3, _, '41D') ; sub_atom(N, 0, 3, _, '31A') ).
strate(personnes, individu, _).
strate(actions, scene, N) :- sub_atom(N, 0, 1, _, D), memberchk(D, ['3', '4']).
strate(narratives, scene, N) :- sub_atom(N, 0, 1, _, D), memberchk(D, ['7', '9']).
strate(genres_allegories, T, _) :- memberchk(T, [genre, concept]).
strate(attributs, attribut, _).

numerote([], _, []).
numerote([St-N|Fs], K, [_{k: K, notation: N, strate: St, langue: L, libelle_en: E, libelle_fr: F}|Js]) :-
    ( K mod 2 =:= 1 -> L = en ; L = fr ),
    ( iconclass:libelle(N, en, E) -> true ; E = "" ), ( iconclass:libelle(N, fr, F) -> true ; F = "" ),
    K1 is K + 1, numerote(Fs, K1, Js).
