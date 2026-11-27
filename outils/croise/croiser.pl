/*  L'expérience croisée (27/11) : graphes du lecteur et graphes de référence, requêtes compilées et requêtes de
    référence, par le même noyau, les mêmes connaissances, les mêmes textes, les mêmes budgets.
        swipl outils/croise/croiser.pl BASE LECTEUR.json REFERENCE.json COMPILEES.json REQUETES_REF.json FICHES.json SORTIE.json
    LECTEUR.json : les graphes du lecteur (outils/graphes/lire.pl) ; REFERENCE.json : les graphes de référence en
    assertions (outils/graphes/vers_faits.py) ; COMPILEES.json : les requêtes compilées des notations
    (outils/requetes/compiler_vertical.pl) ; REQUETES_REF.json : les requêtes de référence ; FICHES.json : la
    notation visée de chaque fiche.
    Pour chaque texte et chaque condition (graphe × requête) :
      satisfaction    le statut du noyau pour la condition suffisante de la notation visée (etablie,
                      etablie_sous_hypotheses, non_certifiee, contradictoire, ecartee, inconnue, incomplet, interrompu),
                      et, s'il n'est pas établi, les atomes satisfaits et manquants (partiel/2 du noyau) ; idem pour la
                      condition nécessaire ;
      qualification   le statut du code par la règle du codage (codage.pl, statut/9 : etabli, etablissable, candidat,
                      conditionnel, …) : la requête compilée avec son statut de compilation et sa famille ; la requête
                      de référence comme une requête « compilee » de la famille « reference » (jamais justifiée) ;
      sans_requete    la notation n'a pas de condition suffisante dans cette source (non prise en charge).
    Budgets : celui du noyau par requête (budget/1), et OEDIPAMAAS_INFERENCES (10⁹ par défaut) par condition. Aucune
    normalisation.  */
:- initialization(main, main).
:- prolog_load_context(directory, D), atom_concat(D, '/../../oedipamaas/socle', S), asserta(user:file_search_path(socle, S)).
:- use_module(socle(oedipamaas)).
:- use_module(library(json)).

main :-
    current_prolog_flag(argv, [Base, Lecteur, Reference, Compilees, ReqRef, Fiches, Sortie|_]),
    oedipamaas:charger_base(Base),
    forall(member(F, ['/ressources.qlf', '/requetes_index']), ( atom_concat(Base, F, C), load_files(C, []) )),
    use_module(socle(codage)), use_module(socle(satisfaction)), use_module(socle(verificateur)),
    maplist(lire, [Lecteur, Reference, Compilees, ReqRef, Fiches], [Gl, Gr, Qc, Qr, Fs]),
    ( getenv('OEDIPAMAAS_INFERENCES', I0) -> atom_number(I0, Imax) ; Imax = 1000000000 ),
    findall(J, ( member(L, Gl), croiser_un(Imax, L, Gr, Qc, Qr, Fs, J) ), Js),
    setup_call_cleanup(open(Sortie, write, S, [encoding(utf8)]), json_write_dict(S, Js, [width(140)]), close(S)),
    length(Js, N), format("~d textes croisés~n", [N]).

lire(F, J) :- setup_call_cleanup(open(F, read, S, [encoding(utf8)]), json_read_dict(S, J), close(S)).

croiser_un(Imax, L, Gr, Qc, Qr, Fs, _{k: K, genre: G, langue: La, notation: Ns, compilation: Cst, conditions: Cs}) :-
    K = L.k, G = L.genre, atom_string(La, L.langue),
    once(( member(Fi, Fs), Fi.k =:= K )), Ns = Fi.notation,
    once(( member(R, Gr), R.k =:= K, R.genre == G )),
    once(( member(C, Qc), C.k =:= K )), Cst = C.statut,
    once(( member(Q, Qr), Q.k =:= K )),
    graphe(L.faits, Gl), graphe(R.faits, Gref),
    requetes_compilee(C, Sc, Nc, StC, FaC), requetes_reference(Q, Sr, Nr),
    findall(Nom-V, ( member(Nom-Gx-Sx-Nx-StX-FaX, [lecteur_compilee-Gl-Sc-Nc-StC-FaC, lecteur_reference-Gl-Sr-Nr-compilee-reference,
                                                     reference_compilee-Gref-Sc-Nc-StC-FaC,
                                                     reference_reference-Gref-Sr-Nr-compilee-reference]),
                     condition(Imax, La, Gx, Sx, Nx, StX, FaX, V) ), Ps),
    dict_pairs(Cs, c, Ps).

graphe("erreur", erreur) :- !.
graphe(Fj, G) :- maplist(fait, Fj, G).
fait(["texte", T], texte(T)) :- !.
fait([F|As], T) :- atom_string(Fa, F), maplist(arg_json, As, Bs), T =.. [Fa|Bs].
arg_json(X, X) :- number(X), !.
arg_json(X, A) :- string(X), !, atom_string(A, X).
arg_json(["cite", X], cite(A)) :- !, atom_string(A, X).
arg_json(L, As) :- is_list(L), !, maplist(arg_json, L, As).

requetes_compilee(C, Su, Ne, St, Fa) :-
    atom_string(St, C.statut), atom_string(Fa, C.famille),
    texte_requete(C.suffisante, Su), texte_requete(C.necessaire, Ne).
requetes_reference(Q, Su, Ne) :-
    texte_requete(Q.suffisante, Su), ( get_dict(necessaire, Q, N0), N0 \== null -> texte_requete(N0, Ne) ; Ne = aucune ).
texte_requete(S, aucune) :- ( S == "aucune" ; S == null ), !.
texte_requete(S, Q) :- term_string(Q, S).

condition(_, _, _, aucune, _, _, _, _{satisfaction: sans_requete, qualification: sans_requete}) :- !.
condition(_, _, erreur, _, _, _, _, _{satisfaction: graphe_en_erreur, qualification: graphe_en_erreur}) :- !.
condition(Imax, La, G, Su, Ne, St, Fa, _{satisfaction: Ss, partiel: Pj, hypotheses: Hj, qualification: Qu,
                                       necessaire: Sn, partiel_necessaire: Pnj, validation: Vj}) :-
    codage:k(La, K),
    assertions:valider(G, Ev), maplist(terme, Ev, Vj),
    resoudre(Imax, K, G, Su, Res),
    ( Res = resultat(Ss, Els, _) -> true ; Ss = Res, Els = [] ),
    partiel_json(Ss, Els, Pj), hypotheses_json(Ss, Els, Hj),
    (   Res = resultat(Ss1, Els1, _)
    ->  ( catch(codage:statut(K, G, Su, St, Fa, Ss1, Els1, Qu0, _), E, ( print_message(error, E), fail )) -> Qu = Qu0
        ; Qu = erreur_de_qualification )
    ;   Qu = Ss
    ),
    (   Ne == aucune -> Sn = aucune, Pnj = []
    ;   resoudre(Imax, K, G, Ne, Rn), ( Rn = resultat(Sn, Eln, _) -> partiel_json(Sn, Eln, Pnj) ; Sn = Rn, Pnj = [] )
    ).

resoudre(Imax, K, G, Q, Res) :-
    catch(call_with_inference_limit(satisfaction:satisfaire(K, G, Q, R0), Imax, I), E, ( print_message(error, E), I = erreur(E) )),
    (   I == inference_limit_exceeded -> Res = interrompu
    ;   I = erreur(_) -> Res = erreur
    ;   Res = R0
    ).

partiel_json(St, [partiel(Sat, Manq)], _{satisfaits: Sj, manquants: Mj}) :- memberchk(St, [inconnue, incomplet]), !,
    maplist(chemin_atome, Sat, Sj), maplist(chemin_atome, Manq, Mj).
partiel_json(_, _, []).
chemin_atome(_-A, S) :- terme(A, S).
hypotheses_json(etablie_sous_hypotheses, Ps, Hs) :- !,
    findall(S, ( member(preuve(_, _, _, _, _, H), Ps), member(X, H), terme(X, S) ), Hs0), sort(Hs0, Hs).
hypotheses_json(_, _, []).
terme(T, S) :- format(string(S), "~q", [T]).
