/*  Le prototype vertical avec le noyau (C4, C5) : chaque texte est lu (lecteur, ancrage), normalisé, puis codé par
    les requêtes compilées (codage.pl).
        OEDIPAMAAS_ANALYSEUR=stanza swipl outils/vertical/coder.pl BASE TEXTES.json SORTIE.json [PAS [CONTROLE]]
    TEXTES.json : [{k, notation, langue, positif, negatif, indetermine, variantes?}] (ou sans notation : fiches.json
    est alors lu à côté pour la retrouver par k). PAS : une fiche sur PAS. CONTROLE : une fiche sur CONTROLE est aussi
    codée en mode exhaustif : CONTROLE est le nombre de fiches contrôlées, les premières de l'échantillon ; les deux
    modes doivent donner les mêmes codes (C5, I4).
    SORTIE.json : pour chaque fiche et chaque texte, le statut de la notation visée (etabli, candidat, ecarte,
    contradictoire, absent), à part un descendant établi (ascendance documentaire : jamais compté comme la notation
    visée, I11), les codes établis, ceux hors de la branche documentaire, et l'accord des deux modes.  */
:- initialization(main, main).
:- prolog_load_context(directory, D), atom_concat(D, '/../../oedipamaas/socle', S), asserta(user:file_search_path(socle, S)).
:- use_module(socle(oedipamaas)).
:- use_module(library(json)).

main :-
    current_prolog_flag(argv, [Base, Entree, Sortie|Opt]),
    ( Opt = [P0|_] -> atom_number(P0, Pas) ; Pas = 1 ),
    ( Opt = [_, C0|_] -> atom_number(C0, Controle) ; Controle = 0 ),
    oedipamaas:charger_base(Base),
    forall(member(F, ['/ressources.qlf', '/requetes_index']), ( atom_concat(Base, F, C), load_files(C, []) )),
    use_module(socle(codage)), codage:indexer,
    lire(Entree, Fiches0), notations(Entree, Fiches0, Fiches1),
    findall(F, ( nth1(I, Fiches1, F), (I - 1) mod Pas =:= 0 ), Fiches),
    findall(L-t(K, Genre, T), ( member(Fi, Fiches), atom_string(L, Fi.langue), K = Fi.k, textes(Fi, Genre, T) ), Ts),
    findall(L, member(L-_, Ts), Ls0), sort(Ls0, Ls),
    findall(K, ( nth1(I, Fiches, Fi), I =< Controle, K = Fi.k ), Ks), nb_setval(controlees, Ks),
    findall(R, ( member(L, Ls), findall(X, member(L-X, Ts), Xs), lire_et_coder(L, Xs, Controle, Rs), member(R, Rs) ), Res),
    findall(J, ( member(Fi, Fiches), fiche(Fi, Res, J) ), Js),
    setup_call_cleanup(open(Sortie, write, S, [encoding(utf8)]), json_write_dict(S, Js, [width(140)]), close(S)),
    length(Js, N), format("~d fiches~n", [N]).

lire(F, J) :- setup_call_cleanup(open(F, read, S, [encoding(utf8)]), json_read_dict(S, J), close(S)).
notations(_, Fs, Fs) :- Fs = [F|_], get_dict(notation, F, _), !.
notations(Entree, Fs0, Fs) :-
    file_directory_name(Entree, D), directory_file_path(D, 'fiches.json', Ff), lire(Ff, Fis),
    maplist([F0, F]>>( member(Fi, Fis), Fi.k =:= F0.k, F = F0.put(notation, Fi.notation) ), Fs0, Fs).

textes(Fi, G, T) :- member(G, [positif, negatif, indetermine]), T = Fi.get(G).
textes(Fi, G, T) :- get_dict(variantes, Fi, Vs), dict_pairs(Vs, _, Ps), member(G0-T, Ps), atom_concat('variante_', G0, G).

lire_et_coder(L, Xs, Controle, Rs) :-
    findall(T, member(t(_, _, T), Xs), Textes),
    udpipe:analyser_lot(Textes, L, Ps),
    findall(r(K, G, Res, Accord, Dt),
            ( nth1(I, Xs, t(K, G, T)), nth1(I, Ps, Phrases),
              get_time(T0), coder_texte(T, L, Phrases, indexe, Res), get_time(T1), Dt is T1 - T0,
              (   Controle > 0, nb_getval(controlees, Ks), memberchk(K, Ks), Res \== erreur
              ->  coder_texte(T, L, Phrases, exhaustif, Rx), ( Rx == Res -> Accord = egal ; Accord = different )
              ;   Accord = non_controle
              ) ),
            Rs).

coder_texte(T, L, Phrases, Mode, Res) :-
    (   catch(( interpretation:interpreter(T, L, description, 0, Phrases, Fs), codage:coder(L, Fs, Mode, Res0) ),
              E, ( print_message(error, E), fail ))
    ->  Res = Res0
    ;   Res = erreur
    ).

fiche(Fi, Res, J) :-
    atom_string(N, Fi.notation), K = Fi.k,
    findall(G-V, ( member(r(K0, G, R, A, Dt), Res), K0 =:= K, visee(N, R, A, Dt, V) ), Vs),
    dict_pairs(J0, _, Vs), J = J0.put(_{k: K, notation: Fi.notation, langue: Fi.langue}).

visee(_, erreur, _, _, _{statut: erreur}) :- !.
visee(N, R, A, Dt, _{statut: St, complet: Co, necessaire: Ne, descendant_etabli: De, etablis: Es, etablissables: Eb,
                     hors_branche: Hs, hors_branche_etablissables: Hb, accord: A, temps: Dt}) :-
    ( memberchk(code(N, S0, _, annexe(C0, N0)), R) -> St = S0, Co = C0, Ne = N0 ; St = absent, Co = null, Ne = null ),
    ( member(code(N2, etabli, _, _), R), arbre:ancetre(N2, N) -> De = N2 ; De = null ),
    findall(E, member(code(E, etabli, _, _), R), Es),
    findall(E, ( member(E, Es), E \== N, \+ arbre:ancetre(E, N), \+ arbre:ancetre(N, E) ), Hs),
    findall(E, member(code(E, etablissable, _, _), R), Eb),
    findall(E, ( member(E, Eb), E \== N, \+ arbre:ancetre(E, N), \+ arbre:ancetre(N, E) ), Hb).
