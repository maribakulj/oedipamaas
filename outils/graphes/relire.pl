/*  Relire un banc sans réanalyser (27/11) : l'interprétation (interpretation.pl) et les dérivations de la
    normalisation, refaites sur l'analyse en dépendances que lire.pl a gardée (`phrases`), sans appeler Stanza.
        swipl outils/graphes/relire.pl BASE LECTEUR.json SORTIE.json
    LECTEUR.json : une sortie de outils/graphes/lire.pl ; SORTIE.json : le même format. Sert aux expériences du lecteur
    (docs/mesures/SURETE_LECTEUR.md), où seule l'interprétation change : la mesure finale de chaque version est refaite
    par lire.pl, et les deux doivent donner les mêmes faits (contrôle de l'expérience). Une phrase dont les traits ne se
    relisent pas est une erreur, jamais une approximation.  */
:- initialization(main, main).
:- prolog_load_context(directory, D), atom_concat(D, '/../../oedipamaas/socle', S), asserta(user:file_search_path(socle, S)).
:- use_module(socle(oedipamaas)).
:- use_module(socle(normalisation)).
:- use_module(library(json)).

main :-
    current_prolog_flag(argv, [Base, Entree, Sortie|_]),
    oedipamaas:charger_base(Base),
    atom_concat(Base, '/ressources.qlf', R), load_files(R, []),
    setup_call_cleanup(open(Entree, read, S0, [encoding(utf8)]), json_read_dict(S0, Xs), close(S0)),
    maplist(relire_texte, Xs, Js),
    setup_call_cleanup(open(Sortie, write, S, [encoding(utf8)]), json_write_dict(S, Js, [width(140)]), close(S)),
    length(Js, N), format("~d textes relus~n", [N]).

relire_texte(X, J) :-
    atom_string(L, X.langue), atom_string(G, X.genre),
    maplist(phrase_de_json, X.phrases, Phrases),
    atom_string(T, X.texte),
    lire_texte(L, X.k, G, T, Phrases, J).

phrase_de_json(Ms, phrase(Mots)) :- maplist(mot_de_json, Ms, Mots).
mot_de_json([I, Fo, Le, C, Tr, H, R, D, F], mot(I, Foa, Lea, Ca, Trs, H, Ra, D, F)) :-
    maplist(atom_string, [Foa, Lea, Ca, Ra], [Fo, Le, C, R]),
    traits(Tr, Trs).
traits("[]", []) :- !.
traits(S, Ts) :-
    (   string_concat("[", S1, S), string_concat(S2, "]", S1)
    ->  split_string(S2, ",", "", Ps), maplist(trait, Ps, Ts)
    ;   throw(error(traits_illisibles(S), _))
    ).
trait(P, N=V) :-
    (   split_string(P, "=", "", [Ns, Vs]) -> atom_string(N, Ns), atom_string(V, Vs)
    ;   throw(error(trait_illisible(P), _))
    ).

% la même mise en forme que lire.pl
lire_texte(L, K, G, T, Phrases, _{k: K, genre: G, langue: L, texte: T, faits: Fj, derivations: Dj, phrases: Pj}) :-
    maplist(phrase_json, Phrases, Pj),
    (   catch(interpretation:interpreter(T, L, description, 0, Phrases, Fs), E, ( print_message(error, E), fail ))
    ->  maplist(fait_json, Fs, Fj),
        ( catch(normalisation:deriver(L, Fs, Ds), E2, ( print_message(error, E2), fail )) -> true ; Ds = [] ),
        maplist(derivation_json, Ds, Dj)
    ;   Fj = erreur, Dj = []
    ).
phrase_json(phrase(Ms), J) :- maplist(mot_json, Ms, J).
mot_json(mot(I, Fo, Le, C, Tr, H, R, D, F), [I, Fos, Les, Cs, Trs, H, Rs, D, F]) :-
    maplist(en_chaine, [Fo, Le, C, R], [Fos, Les, Cs, Rs]), format(string(Trs), "~w", [Tr]).
en_chaine(X, S) :- ( string(X) -> S = X ; format(string(S), "~w", [X]) ).
fait_json(F, [N|As]) :- F =.. [N0|As0], atom_string(N0, N), maplist(valeur_json, As0, As).
valeur_json(X, X) :- number(X), !.
valeur_json(X, S) :- atom(X), !, atom_string(X, S).
valeur_json(X, X) :- string(X), !.
valeur_json(X, L) :- is_list(X), !, maplist(valeur_json, X, L).
valeur_json(X, J) :- compound(X), !, fait_json(X, J).
derivation_json(derivation(F, R, St, Ss), _{fait: Fj, regle: R, statut: St, sources: Sj}) :-
    fait_json(F, Fj), maplist(fait_json, Ss, Sj).
