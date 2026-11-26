/*  Les graphes du lecteur, pour le banc de graphes de référence (lot 5 ; docs/BANC_GRAPHES.md).
        OEDIPAMAAS_ANALYSEUR=stanza swipl outils/graphes/lire.pl BASE TEXTES.json SORTIE.json [PAS]
    TEXTES.json : [{k, langue, positif, negatif, indetermine, variantes?}] (le format des jeux de développement et de
    validation) ; PAS : une fiche sur PAS (le même échantillon que outils/vertical/coder.pl).
    SORTIE.json : pour chaque texte, {k, genre, langue, texte, faits, derivations, phrases}
      phrases      l'analyse en dépendances, chaque mot [Id, Forme, Lemme, Catégorie, Traits, Tête, Relation, Début, Fin]
      faits        les assertions du lecteur (interpretation.pl), chacune [Foncteur, Arg1, …] (les chaînes et les
                   atomes en chaînes, les nombres en nombres)
      derivations  les assertions que dériveraient les règles de la normalisation (normalisation:deriver/3, lot 3),
                   chacune {fait, regle, statut, sources} : pour mesurer chaque règle contre la référence
    Rien n'est jugé ici.  */
:- initialization(main, main).
:- prolog_load_context(directory, D), atom_concat(D, '/../../oedipamaas/socle', S), asserta(user:file_search_path(socle, S)).
:- use_module(socle(oedipamaas)).
:- use_module(socle(normalisation)).
:- use_module(library(json)).

main :-
    current_prolog_flag(argv, [Base, Entree, Sortie|Opt]),
    ( Opt = [P0|_] -> atom_number(P0, Pas) ; Pas = 1 ),
    oedipamaas:charger_base(Base),
    atom_concat(Base, '/ressources.qlf', R), load_files(R, []),
    lire(Entree, Fiches0),
    findall(F, ( nth1(I, Fiches0, F), (I - 1) mod Pas =:= 0 ), Fiches),
    findall(L-t(K, G, T), ( member(Fi, Fiches), atom_string(L, Fi.langue), K = Fi.k, textes(Fi, G, T) ), Ts),
    findall(L, member(L-_, Ts), Ls0), sort(Ls0, Ls),
    findall(J, ( member(L, Ls), findall(X, member(L-X, Ts), Xs), lire_lot(L, Xs, Js), member(J, Js) ), Res),
    setup_call_cleanup(open(Sortie, write, S, [encoding(utf8)]), json_write_dict(S, Res, [width(140)]), close(S)),
    length(Res, N), format("~d textes~n", [N]).

lire(F, J) :- setup_call_cleanup(open(F, read, S, [encoding(utf8)]), json_read_dict(S, J), close(S)).
textes(Fi, G, T) :- member(G, [positif, negatif, indetermine]), T = Fi.get(G).
textes(Fi, G, T) :- get_dict(variantes, Fi, Vs), dict_pairs(Vs, _, Ps), member(G0-T, Ps), atom_concat('variante_', G0, G).

lire_lot(L, Xs, Js) :-
    findall(T, member(t(_, _, T), Xs), Textes),
    udpipe:analyser_lot(Textes, L, Ps),
    findall(J, ( nth1(I, Xs, t(K, G, T)), nth1(I, Ps, Phrases), lire_texte(L, K, G, T, Phrases, J) ), Js).

lire_texte(L, K, G, T, Phrases, _{k: K, genre: G, langue: L, texte: T, faits: Fj, derivations: Dj, phrases: Pj}) :-
    maplist(phrase_json, Phrases, Pj),
    (   catch(interpretation:interpreter(T, L, description, 0, Phrases, Fs), E, ( print_message(error, E), fail ))
    ->  maplist(fait_json, Fs, Fj),
        ( catch(normalisation:deriver(L, Fs, Ds), E2, ( print_message(error, E2), fail )) -> true ; Ds = [] ),
        maplist(derivation_json, Ds, Dj)
    ;   Fj = erreur, Dj = []
    ).

% l'analyse en dépendances (pour classer les erreurs par construction) : [Id, Forme, Lemme, Catégorie, Traits, Tête,
% Relation, Début, Fin] par mot
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
