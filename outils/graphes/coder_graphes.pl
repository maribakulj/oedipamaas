/*  Le codage de graphes donnés (lot 5) : les graphes du lecteur (outils/graphes/lire.pl) ou les graphes de référence
    (outils/graphes/vers_faits.py), codés par les mêmes requêtes et le même noyau que outils/vertical/coder.pl.
        swipl outils/graphes/coder_graphes.pl BASE GRAPHES.json FICHES.json SORTIE.json
    GRAPHES.json : [{k, genre, langue, texte, faits}] ; FICHES.json : les fiches du jeu (la notation visée de chaque
    k). SORTIE.json : pour chaque texte, {k, genre, langue, notation, statut (de la notation visée), comptes (les codes
    de chaque statut), etablissables, candidats, conditionnels (les notations), mesure, erreurs (de validation)}.
    OEDIPAMAAS_INFERENCES=N : le budget d'inférences par texte (comme coder.pl) ; OEDIPAMAAS_NORMALISATION=non.
    La différence entre le codage des graphes de référence et celui des graphes du lecteur est l'effet de la lecture
    sur les codes Iconclass : mêmes requêtes, même noyau, même budget.  */
:- initialization(main, main).
:- prolog_load_context(directory, D), atom_concat(D, '/../../oedipamaas/socle', S), asserta(user:file_search_path(socle, S)).
:- use_module(socle(oedipamaas)).
:- use_module(library(json)).

main :-
    current_prolog_flag(argv, [Base, Entree, Fiches, Sortie|_]),
    oedipamaas:charger_base(Base),
    forall(member(F, ['/ressources.qlf', '/requetes_index']), ( atom_concat(Base, F, C), load_files(C, []) )),
    use_module(socle(codage)), codage:indexer,
    lire(Fiches, Fs), lire(Entree, Gs),
    findall(R, ( member(G, Gs), coder_un(Fs, G, R) ), Rs),
    setup_call_cleanup(open(Sortie, write, S, [encoding(utf8)]), json_write_dict(S, Rs, [width(140)]), close(S)),
    length(Rs, N), format("~d graphes codés~n", [N]).

lire(F, J) :- setup_call_cleanup(open(F, read, S, [encoding(utf8)]), json_read_dict(S, J), close(S)).

coder_un(Fs, G, _{k: K, genre: Ge, langue: L, notation: Ns, statut: St, comptes: Cp, etablissables: Eb,
                 candidats: Ca, conditionnels: Co, mesure: Me, erreurs: Ej}) :-
    K = G.k, Ge = G.genre, atom_string(L, G.langue),
    ( member(Fi, Fs), Fi.k =:= K -> atom_string(N, Fi.notation) ; N = inconnue ), atom_string(N, Ns),
    (   G.faits == "erreur" -> Faits = [], Err = [lecture_en_erreur]
    ;   maplist(fait, G.faits, Faits), assertions:valider(Faits, Err)
    ),
    maplist(terme_json, Err, Ej),
    ( getenv('OEDIPAMAAS_NORMALISATION', non) -> Opts = [normaliser(non)] ; Opts = [] ),
    ( getenv('OEDIPAMAAS_INFERENCES', I0), atom_number(I0, Imax) -> true ; Imax = 1000000000 ),
    statistics(cputime, C0), statistics(inferences, N0),
    (   Err \== [] -> Res = erreur
    ;   catch(call_with_inference_limit(codage:coder(L, Faits, indexe, Opts, Res0), Imax, Issue), E,
              ( print_message(error, E), Issue = erreur ))
    ->  ( Issue == inference_limit_exceeded -> Res = interrompu ; Issue == erreur -> Res = erreur ; Res = Res0 )
    ;   Res = erreur
    ),
    statistics(cputime, C1), statistics(inferences, N1), Cpu is C1 - C0, Inf is N1 - N0,
    Me = _{cpu: Cpu, inferences: Inf, assertions: Na}, length(Faits, Na),
    (   is_list(Res)
    ->  ( memberchk(code(N, S0, _, _), Res) -> St = S0 ; St = absent ),
        findall(S, member(code(_, S, _, _), Res), Ss), msort(Ss, Ss1), clumped(Ss1, Cl), dict_pairs(Cp, c, Cl),
        findall(X, member(code(X, etablissable, _, _), Res), Eb),
        findall(X, member(code(X, candidat, _, _), Res), Ca),
        findall(X, member(code(X, conditionnel, _, _), Res), Co)
    ;   St = Res, Cp = _{}, Eb = [], Ca = [], Co = []
    ).

% un fait JSON [Foncteur, Arg…] en terme : les chaînes en atomes (sauf le texte), ["cite", X] en cite(X)
fait(["texte", T], texte(T)) :- !.
fait([F|As], T) :- atom_string(Fa, F), maplist(arg_json, As, Bs), T =.. [Fa|Bs].
arg_json(X, X) :- number(X), !.
arg_json(X, A) :- string(X), !, atom_string(A, X).
arg_json(["cite", X], cite(A)) :- !, atom_string(A, X).
arg_json(L, As) :- is_list(L), !, maplist(arg_json, L, As).
terme_json(T, S) :- format(string(S), "~q", [T]).
