/*  Le prototype vertical, de bout en bout (25/11) : chaque texte de test est lu (lecteur des textes, ancrage dans
    l'image), puis projeté sur les définitions compilées (projection.pl).
        OEDIPAMAAS_ANALYSEUR=stanza swipl outils/vertical/projeter.pl BASE TEXTES.json SORTIE.json [PAS [DELAI]]
    PAS : ne garder qu'une fiche sur PAS (1 par défaut) ; DELAI : secondes par texte (60 par défaut ; au-delà, statut
    « delai », compté comme tel). L'avancement s'écrit sur la sortie d'erreur.
    TEXTES.json : [{k, notation, langue, positif, negatif, indetermine, note}] (un positif dit ce que la notation
    décrit ; un négatif une situation proche qui ne l'est pas ; un indéterminé un texte qui n'en dit pas assez).
    SORTIE.json : pour chaque fiche et chaque texte, le statut de la notation visée (etabli, candidat, contredit,
    absent ; « etabli_par_descendant » si un descendant est établi), et tous les codes établis, avec leur preuve.  */
:- initialization(main, main).
:- prolog_load_context(directory, D), atom_concat(D, '/../../oedipamaas/socle', S), asserta(user:file_search_path(socle, S)).
:- use_module(socle(oedipamaas)).
:- use_module(library(json)).
:- use_module(library(time)).

main :-
    current_prolog_flag(argv, [Base, Entree, Sortie|Opt]),
    ( Opt = [P0|_] -> atom_number(P0, Pas) ; Pas = 1 ),
    ( Opt = [_, D0|_] -> atom_number(D0, Delai) ; Delai = 60 ), nb_setval(delai, Delai),
    oedipamaas:charger_base(Base),
    forall(member(F, ['/ressources.qlf', '/definitions_index']), ( atom_concat(Base, F, C), load_files(C, []) )),
    use_module(socle(projection)),
    setup_call_cleanup(open(Entree, read, S0, [encoding(utf8)]), json_read_dict(S0, Fiches0), close(S0)),
    findall(F, ( nth1(I, Fiches0, F), (I - 1) mod Pas =:= 0 ), Fiches),
    findall(L-k(K, Genre, T), ( member(Fi, Fiches), atom_string(L, Fi.langue), K = Fi.k,
                                member(Genre, [positif, negatif, indetermine]), T = Fi.get(Genre) ), Ts),
    findall(L, member(L-_, Ts), Ls0), sort(Ls0, Ls),
    findall(R, ( member(L, Ls), findall(X, member(L-X, Ts), Xs), lire(L, Xs, Rs), member(R, Rs) ), Res),
    findall(J, ( member(Fi, Fiches), fiche(Fi, Res, J) ), Js),
    setup_call_cleanup(open(Sortie, write, S, [encoding(utf8)]), json_write_dict(S, Js, [width(140)]), close(S)),
    length(Js, N), format("~d fiches~n", [N]).

lire(L, Xs, Rs) :-
    findall(T, member(k(_, _, T), Xs), Textes),
    udpipe:analyser_lot(Textes, L, Ps),
    findall(r(K, G, Res), ( nth1(I, Xs, k(K, G, T)), nth1(I, Ps, Phrases), projeter_texte(T, L, Phrases, Res) ), Rs).

projeter_texte(T, L, Phrases, Res) :-
    nb_getval(delai, Delai), get_time(T0),
    (   catch(call_with_time_limit(Delai, ( interpretation:interpreter(T, L, description, 0, Phrases, Fs),
                                            projection:projeter(Fs, L, Res0) )),
              E, ( E = time_limit_exceeded -> Res0 = delai ; print_message(error, E), Res0 = erreur ))
    ->  Res = Res0
    ;   Res = erreur
    ),
    get_time(T1), Dt is T1 - T0, ( Res == delai -> D = " (délai)" ; D = "" ), format(user_error, "texte ~1f s~w~n", [Dt, D]).

fiche(Fi, Res, J) :-
    atom_string(N, Fi.notation), K = Fi.k,
    findall(G-V, ( member(G, [positif, negatif, indetermine]), memberchk(r(K, G, R), Res), visee(N, R, V) ), Vs),
    dict_pairs(J0, _, Vs),
    J = J0.put(_{k: K, notation: Fi.notation, langue: Fi.langue}).

visee(_, erreur, _{statut: erreur}) :- !.
visee(_, delai, _{statut: delai}) :- !.
visee(N, R, _{statut: St, etablis: Es, preuve: P}) :-
    (   memberchk(resultat(N, S0, Pr), R) -> St = S0, term_string(Pr, P)
    ;   member(resultat(N2, etabli, Pr), R), arbre:ancetre(N2, N) -> St = etabli_par_descendant, term_string(N2-Pr, P)
    ;   St = absent, P = ""
    ),
    findall(E, member(resultat(E, etabli, _), R), Es).
