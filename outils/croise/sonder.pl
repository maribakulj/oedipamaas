/*  La sonde des connaissances (27/11) : pour chaque atome manquant d'un échec de l'expérience croisée, ce que K sait.
        swipl outils/croise/sonder.pl BASE ECHECS.json FAITS_REFERENCE.json SORTIE.json
    ECHECS.json : la sortie de outils/croise/diagnostiquer.py (--json) ; FAITS_REFERENCE.json : les graphes de
    référence en assertions (outils/graphes/vers_faits.py).
    Pour chaque atome manquant à lien lexical (type, genre, propriete, evenement, relation) de mot demandé T :
      sens_demande    le nombre de sens que K donne à T dans sa catégorie (0 : T inconnu de K) ;
      mots_du_graphe  pour chaque mot W du graphe de la même catégorie : ses sens (0 : inconnu de K), un lien positif
                      de W vers T (le chemin), et s'il est certain (D30 : tous les sens de W atteignent T) ;
      ailleurs        les mots du graphe d'une autre catégorie qui ont le même lemme que T (un prédicat pour un type…).
    Rien n'est jugé ici : la cause est décidée ensuite, cas par cas.  */
:- initialization(main, main).
:- prolog_load_context(directory, D), atom_concat(D, '/../../oedipamaas/socle', S), asserta(user:file_search_path(socle, S)).
:- use_module(socle(oedipamaas)).
:- use_module(library(json)).

main :-
    current_prolog_flag(argv, [Base, Echecs, Faits, Sortie|_]),
    oedipamaas:charger_base(Base),
    atom_concat(Base, '/ressources.qlf', R), load_files(R, []),
    use_module(socle(codage)), use_module(socle(satisfaction)),
    lire(Echecs, Es), lire(Faits, Fs),
    findall(J, ( member(E, Es), sonder(E, Fs, J) ), Js),
    setup_call_cleanup(open(Sortie, write, S, [encoding(utf8)]), json_write_dict(S, Js, [width(140)]), close(S)),
    length(Js, N), format("~d échecs sondés~n", [N]).

lire(F, J) :- setup_call_cleanup(open(F, read, S, [encoding(utf8)]), json_read_dict(S, J), close(S)).

sonder(E, Fs, _{k: E.k, genre: E.genre, notation: E.notation, atomes: As}) :-
    once(( member(F, Fs), F.k =:= E.k, F.genre == E.genre )), atom_string(L, F.langue), codage:k(L, K),
    maplist(fait, F.faits, G),
    findall(A, ( member(S, E.manquants), term_string(T, S), sonder_atome(K, G, T, A) ), As).

fait(["texte", T], texte(T)) :- !.
fait([F|As], T) :- atom_string(Fa, F), maplist(arg_json, As, Bs), T =.. [Fa|Bs].
arg_json(X, X) :- number(X), !.
arg_json(X, A) :- string(X), !, atom_string(A, X).
arg_json(["cite", X], cite(A)) :- !, atom_string(A, X).
arg_json(L, As) :- is_list(L), !, maplist(arg_json, L, As).

categorie(type(_, T), n, T). categorie(genre(T), n, T). categorie(propriete(_, T), a, T).
categorie(evenement(_, T), v, T). categorie(relation(_, T, _), r, T).
mots(G, n, Ws) :- findall(W, ( member(entite(_, W, _), G), W \== nom_propre ), Ws0), sort(Ws0, Ws).
mots(G, a, Ws) :- findall(W, member(propriete(_, _, W, _), G), Ws0), sort(Ws0, Ws).
mots(G, v, Ws) :- findall(W, member(evenement(_, W, _), G), Ws0), sort(Ws0, Ws).
mots(G, r, Ws) :- findall(W, member(relation(_, _, W, _, _), G), Ws0), sort(Ws0, Ws).

sonder_atome(K, G, A, _{atome: As, mot: Ts, categorie: Cs, sens_demande: Nt, mots_du_graphe: Ms, ailleurs: Al}) :-
    categorie(A, Cat, T), !, format(string(As), "~q", [A]), atom_string(T, Ts), atom_string(Cat, Cs),
    nb_sens(K, Cat, T, Nt),
    mots(G, Cat, Ws),
    findall(_{mot: Wst, sens: Nw, lien: Ls, certain: Ce},
            ( member(W, Ws), atom_string(W, Wst), nb_sens(K, Cat, W, Nw),
              (   once(satisfaction:lien_pos(K, Cat, W, T, Lien)) -> format(string(Ls), "~q", [Lien]),
                  ( satisfaction:lien_pos_certain(K, Cat, W, T) -> Ce = true ; Ce = false )
              ;   Ls = null, Ce = null ) ),
            Ms),
    findall(_{categorie: C2s, mot: W2s}, ( member(C2, [n, a, v, r]), C2 \== Cat, mots(G, C2, W2), member(W2, W2),
                                            meme_lemme(T, W2), atom_string(C2, C2s), atom_string(W2, W2s) ), Al).
sonder_atome(_, _, A, _{atome: As, categorie: "sans_lien_lexical"}) :- format(string(As), "~q", [A]).

nb_sens(K, Cat, W, N) :- findall(S, K:sens(Cat, W, S), Ss0), sort(Ss0, Ss), include(integer, Ss, Is), length(Is, N).
% même lemme, ou l'un préfixe de l'autre sur au moins quatre lettres (singer / sing, death / die n'y sont pas : la
% dérivation n'est pas un préfixe ; elle est relevée par diagnostiquer.py)
meme_lemme(T, W) :- T == W, !.
meme_lemme(T, W) :- atom_length(T, Lt), atom_length(W, Lw), Lt >= 4, Lw >= 4,
    ( sub_atom(T, 0, Lw, _, W) ; sub_atom(W, 0, Lt, _, T) ), !.
