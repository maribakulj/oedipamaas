/*  Tire des définitions à juger à l'aveugle, par type de libellé (docs/FONDEMENTS.md, § 9, étape 1) :
        swipl outils/definitions/tirage_jugement.pl BASE SORTIE.json PAR_TYPE GRAINE
    Pour chaque type, PAR_TYPE notations tirées au hasard (graine fixe) qui ont un libellé anglais et français ; pour
    chacune : les libellés, le type, et la définition rendue lisible (anglais et français).  */
:- initialization(main, main).
:- use_module(library(json)).
:- use_module(library(random)).

main :-
    current_prolog_flag(argv, [Base, Sortie, PT0, G0|_]), atom_number(PT0, PT), atom_number(G0, G),
    atom_concat(Base, '/iconclass.qlf', Ic), load_files(Ic, []),
    atom_concat(Base, '/libelles_lus', Lus), load_files(Lus, []),
    atom_concat(Base, '/definitions_index', Di), load_files(Di, []),
    set_random(seed(G)),
    Ts = [attribut, classe, concept, genre, individu, recit, scene],
    findall(J, ( member(T, Ts), T \== rubrique,
                 findall(N, ( definitions_index:definition(N, en, def(T, _, _, _, _)),
                              definitions_index:definition(N, fr, _) ), Ns),
                 random_permutation(Ns, P), length(P, LP), K is min(PT, LP), length(Pk, K), append(Pk, _, P),
                 member(N, Pk), fiche(N, T, J) ), Js),
    setup_call_cleanup(open(Sortie, write, S, [encoding(utf8)]), json_write_dict(S, Js, [width(120)]), close(S)),
    length(Js, NJ), format("~d fiches~n", [NJ]).

fiche(N, T, _{notation: N, type: T, libelle_en: LE, libelle_fr: LF, definition_en: DE, definition_fr: DF}) :-
    ( iconclass:libelle(N, en, LE) -> true ; LE = "" ), ( iconclass:libelle(N, fr, LF) -> true ; LF = "" ),
    rendu(N, en, DE), rendu(N, fr, DF).

rendu(N, L, R) :-
    (   definitions_index:definition(N, L, def(_, Ex, Cp, Ct, _))
    ->  maplist(groupe_texte, Ex, Gs), atomic_list_concat(Gs, " ET ", G),
        ( Cp == [] -> C = "" ; atomic_list_concat(Cp, ", ", C0), format(atom(C), " | compatible (non exigé) : ~w", [C0]) ),
        ( Ct == [] -> K = "" ; maplist(cond_texte, Ct, Ks0), atomic_list_concat(Ks0, " ; ", K0), format(atom(K), " | contraintes : ~w", [K0]) ),
        format(atom(R), "EXIGE : ~w~w~w", [G, C, K])
    ;   R = "(aucune)"
    ).

groupe_texte(un_de([A]), T) :- !, alt_texte(A, T).
groupe_texte(un_de(As), T) :- maplist(alt_texte, As, Ts), atomic_list_concat(Ts, " OU ", T0), format(atom(T), "(~w)", [T0]).
alt_texte(A, T) :- maplist(unite_texte, A, Ts), atomic_list_concat(Ts, " + ", T0), ( A = [_] -> T = T0 ; format(atom(T), "[~w]", [T0]) ).
unite_texte(mot(W), T) :- format(atom(T), "~w", [W]).
unite_texte(nom(a_remplir), "NOM(à remplir)") :- !.
unite_texte(nom(Ks), T) :- atomic_list_concat(Ks, "|", K), format(atom(T), "NOM(~w)", [K]).
unite_texte(genre(W), T) :- format(atom(T), "GENRE-DE-L-OEUVRE(~w)", [W]).

cond_texte(assertions(Fs), T) :- !,
    findall(X, ( member(F, Fs), assertion_texte(Fs, F, X) ), Xs), atomic_list_concat(Xs, " ; ", T0),
    format(atom(T), "scène lue : {~w}", [T0]).
cond_texte(C, T) :- format(atom(T), "~w", [C]).

assertion_texte(Fs, entite(E, Tete, _), X) :- ( memberchk(nom(_, E, Nom, _), Fs) -> format(atom(X), "~w=~w", [E, Nom]) ; format(atom(X), "~w:~w", [E, Tete]) ), qualif(Fs, E, X).
assertion_texte(_, evenement(V, P, _), X) :- format(atom(X), "action ~w(~w)", [V, P]).
assertion_texte(_, role(V, R, E), X) :- format(atom(X), "~w de ~w = ~w", [R, V, E]).
assertion_texte(_, relation(_, E1, R, E2, _), X) :- format(atom(X), "~w ~w ~w", [E1, R, E2]).
assertion_texte(_, propriete(_, E, P, _), X) :- format(atom(X), "~w est ~w", [E, P]).
assertion_texte(_, alternative(_, As), X) :- format(atom(X), "alternative ~w", [As]).
assertion_texte(Fs, modalite(A, M), X) :- M \== affirme, memberchk(entite(A, _, _), Fs), format(atom(X), "~w ~w", [A, M]).
assertion_texte(Fs, polarite(A, neg), X) :- memberchk(entite(A, _, _), Fs), format(atom(X), "~w nié", [A]).
qualif(_, _, _).
