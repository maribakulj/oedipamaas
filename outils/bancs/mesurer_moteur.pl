/*  La mesure du moteur actuel sur les bancs de la phase 1 : le niveau (c) (docs/INTERPRETATIONS_ADMISSIBLES.md, § 2.4 ;
    docs/BANCS_PHASE1.md, § 9.4). Appelé par outils/bancs/mesurer_moteur.py, qui prépare l'entrée et compare.

        swipl outils/bancs/mesurer_moteur.pl BASE ENTREE.json SORTIE.json

    ENTREE.json : [{id, definition, textes: [{n, langue, description}]}] ; n = 0 pour la description du cas, i ≥ 1
    pour la i-ième variante.
    SORTIE.json : {versions, definitions: [{id, …}], textes: [{id, n, …}]}
      définition  l'adaptateur (adaptateur_scene.pl) : le texte prétraité, son analyse (Stanza), son graphe, la
                  requête suffisante et la nécessaire, le statut de compilation et ses raisons, la famille, le chemin
                  qu'un vrai libellé de cette forme prendrait, les limites de l'adaptateur
      texte       le graphe du lecteur (interpretation:interpreter/6, comme outils/graphes/lire.pl), sa validation, le
                  statut du noyau pour la suffisante (satisfaction:satisfaire/5, K de la langue du texte, comme
                  codage:k/2), les hypothèses, les atomes satisfaits et manquants, la qualification (codage:statut/9,
                  comme outils/croise/croiser.pl), les temps
    Rien n'est jugé ici. Aucune règle du moteur n'est changée. Budgets : celui du noyau (budget/1), une limite de
    OEDIPAMAAS_INFERENCES inférences (10⁹ par défaut) et de OEDIPAMAAS_TEMPS secondes (120 par défaut) par paire.
    Analyseurs : celui du moteur pour les textes (UDPipe 1 par défaut, Stanza si OEDIPAMAAS_ANALYSEUR=stanza : D20 bis),
    Stanza pour les définitions (celui des libellés : D18 bis).  */
:- initialization(main, main).
:- prolog_load_context(directory, D), atom_concat(D, '/../../oedipamaas/socle', S), asserta(user:file_search_path(socle, S)),
   asserta(user:file_search_path(bancs, D)).
:- use_module(socle(oedipamaas)).
:- use_module(library(json)).
:- use_module(library(process)).
:- use_module(library(lists)).
:- use_module(library(apply)).
:- use_module(library(pairs)).

main :-
    current_prolog_flag(argv, [Base, Entree, Sortie|_]),
    oedipamaas:charger_base(Base),
    atom_concat(Base, '/ressources.qlf', R), load_files(R, []),
    use_module(socle(codage)), use_module(socle(satisfaction)), use_module(socle(verificateur)),
    use_module(socle(requetes_iconclass)), use_module(socle(libelles_iconclass)), use_module(socle(sujets)),
    use_module(socle(conllu)), use_module(socle(udpipe)), use_module(socle(definitions)),
    use_module(bancs(adaptateur_scene)),
    lire(Entree, Cas),
    reglages(Imax, Tmax),
    length(Cas, NC), format(user_error, "~d cas~n", [NC]),
    definitions(Cas, Djs, Qs),
    format(user_error, "définitions compilées~n", []),
    textes(Cas, Qs, Imax, Tmax, Tjs),
    versions(Base, Vs),
    setup_call_cleanup(open(Sortie, write, S, [encoding(utf8)]),
                       json_write_dict(S, _{versions: Vs, definitions: Djs, textes: Tjs}, [width(0)]), close(S)),
    length(Tjs, NT), format(user_error, "~d textes mesurés~n", [NT]).

lire(F, J) :- setup_call_cleanup(open(F, read, S, [encoding(utf8)]), json_read_dict(S, J), close(S)).

reglages(Imax, Tmax) :-
    ( getenv('OEDIPAMAAS_INFERENCES', I0) -> atom_number(I0, Imax) ; Imax = 1000000000 ),
    ( getenv('OEDIPAMAAS_TEMPS', T0) -> atom_number(T0, Tmax) ; Tmax = 120 ).

% --- Les définitions --------------------------------------------------------------------------------------------------

definitions(Cas, Djs, Qs) :-
    findall(Id-Net, ( member(C, Cas), atom_string(Id, C.id),
                      adaptateur_scene:pretraiter_definition(C.definition, Net, _, _) ), Ps),
    pairs_values(Ps, Nets),
    stanza(en, Nets, Phs),
    findall(Dj-Q, ( member(C, Cas), atom_string(Id, C.id), nth1(I, Ps, Id-Net), nth1(I, Phs, Ph),
                         definition(Id, C.definition, Net, Ph, Dj, Q) ), DQ),
    pairs_keys_values(DQ, Djs, Qs).

definition(Id, Texte, Net, Ph, Dj, Id-Comp) :-
    statistics(cputime, T0),
    (   catch(adaptateur_scene:compiler_definition(Id, Texte, Ph, A), E, ( print_message(error, E), fail ))
    ->  A = adaptation(Comp, Chemin, Limites, Fs)
    ;   Comp = compilation(Id, en, scene, aucune, aucune, invalide, [erreur_adaptateur], scene-aucune),
        Chemin = inconnu, Limites = [], Fs = []
    ),
    statistics(cputime, T1), Dt is T1 - T0,
    Comp = compilation(_, _, _, Su, Ne, St, Rs, Fa),
    maplist(terme, Rs, Rsj), maplist(terme, Limites, Lj), maplist(fait_json, Fs, Fj), maplist(phrase_json, Ph, Pj),
    terme(Su, Suj), terme(Ne, Nej), terme(Fa, Faj),
    Dj = _{id: Id, net: Net, chemin_reel: Chemin, limites: Lj, faits: Fj, phrases: Pj,
           suffisante: Suj, necessaire: Nej, statut_compilation: St, raisons: Rsj, famille: Faj, temps: Dt}.

% Stanza par la frontière CoNLL-U (outils/definitions/stanza_conllu.py), comme les libellés : un appel pour tout le lot
stanza(L, Textes, Phs) :-
    tmp_file_stream(text, Entree, S0), set_stream(S0, encoding(utf8)),
    foldl(ecrire_texte(S0), Textes, 1, _),
    close(S0),
    tmp_file(stanza, Sortie),
    module_property(adaptateur_scene, file(F)), file_directory_name(F, D),
    atom_concat(D, '/../definitions/stanza_conllu.py', Script),
    ( getenv('OEDIPAMAAS_STANZA', Md) -> Args = [Script, L, Entree, Sortie, Md] ; Args = [Script, L, Entree, Sortie] ),
    process_create(path(python3), Args, [stderr(null), process(P)]), process_wait(P, exit(0)),
    read_file_to_string(Sortie, Txt, [encoding(utf8)]), split_string(Txt, "\n", "", Ls0), exclude(==(""), Ls0, Ls),
    maplist(phrases_conllu, Ls, Phs),
    delete_file(Entree), delete_file(Sortie).
ecrire_texte(S, T, K, K1) :- json_write_dict(S, _{k: K, texte: T}, [width(0)]), nl(S), K1 is K + 1.
phrases_conllu(Li, Ph) :- atom_json_dict(Li, Dl, []), get_dict(conllu, Dl, C), conllu:conllu_phrases(C, Ph).

% --- Les textes -------------------------------------------------------------------------------------------------------

textes(Cas, Qs, Imax, Tmax, Tjs) :-
    findall(La-t(Id, N, T), ( member(C, Cas), atom_string(Id, C.id), member(X, C.textes), atom_string(La, X.langue),
                              N = X.n, T = X.description ), Ts),
    findall(La, member(La-_, Ts), Ls0), sort(Ls0, Ls),
    findall(J, ( member(La, Ls), findall(X, member(La-X, Ts), Xs), lire_lot(La, Xs, Qs, Imax, Tmax, Js), member(J, Js) ), Tjs).

lire_lot(La, Xs, Qs, Imax, Tmax, Js) :-
    findall(T, member(t(_, _, T), Xs), Textes),
    length(Textes, NT), format(user_error, "~w : ~d textes à analyser~n", [La, NT]),
    statistics(walltime, [W0, _]),
    udpipe:analyser_lot(Textes, La, Ps),
    statistics(walltime, [W1, _]), Wa is (W1 - W0) / 1000 / max(1, NT),
    findall(J, ( nth1(I, Xs, t(Id, N, T)), nth1(I, Ps, Phrases), memberchk(Id-Comp, Qs),
                 (   catch(mesurer(La, Id, N, T, Phrases, Comp, Imax, Tmax, Wa, J0), E, ( print_message(error, E), fail ))
                 ->  J = J0
                 ;   format(user_error, "échec de la mesure : ~w ~w~n", [Id, N]),
                     J = _{id: Id, n: N, langue: La, lecture: inconnue, faits: [], phrases: [], validation: [],
                           noyau: _{statut: erreur, etape: mesure, detail: echec_de_la_mesure}, temps: _{}}
                 ),
                 ( I mod 100 =:= 0 -> format(user_error, "~w ~d/~d~n", [La, I, NT]) ; true ) ), Js).

mesurer(La, Id, N, T, Phrases, Comp, Imax, Tmax, Wa, J) :-
    statistics(cputime, T0),
    (   catch(interpretation:interpreter(T, La, description, 0, Phrases, Fs), E, ( print_message(error, E), fail ))
    ->  Lecture = ok
    ;   Lecture = erreur, Fs = erreur
    ),
    statistics(cputime, T1), Tl is T1 - T0,
    Comp = compilation(_, _, _, Su, _, St, _, Fa),
    (   Fs == erreur -> V = _{statut: erreur, etape: lecture}, Vj = []
    ;   catch(assertions:valider(Fs, Ev), _, Ev = [validation_impossible]), maplist(terme, Ev, Vj),
        (   Su == aucune -> V = _{statut: sans_requete, etape: compilation}
        ;   evaluer(La, Fs, Su, St, Fa, Imax, Tmax, V)
        )
    ),
    statistics(cputime, T2), Tn is T2 - T1,
    ( Fs == erreur -> Fj = erreur ; maplist(fait_json, Fs, Fj) ),
    maplist(phrase_json, Phrases, Pj),
    J = _{id: Id, n: N, langue: La, lecture: Lecture, faits: Fj, phrases: Pj, validation: Vj, noyau: V,
          temps: _{analyse_moyenne: Wa, lecture: Tl, noyau: Tn}}.

evaluer(La, G, Su, St, Fa, Imax, Tmax, V) :-
    codage:k(La, K),
    catch(call_with_inference_limit(satisfaction:satisfaire(K, G, Su, [temps(Tmax)], R0), Imax, I), E,
          ( print_message(error, E), I = erreur(E) )),
    (   I == inference_limit_exceeded -> V = _{statut: incomplet, etape: noyau, detail: limite_d_inferences}
    ;   I = erreur(E1) -> terme(E1, Ej), V = _{statut: erreur, etape: noyau, detail: Ej}
    ;   R0 = resultat(Ss, Els, Complet),
        partiel_json(Ss, Els, Pj), hypotheses_json(Ss, Els, Hj),
        (   catch(codage:statut(K, G, Su, St, Fa, Ss, Els, Qu0, _), E2, ( print_message(error, E2), fail )) -> Qu = Qu0
        ;   Qu = erreur_de_qualification
        ),
        ( Els = [temps_depasse] -> Det = temps_depasse ; Det = Complet ),
        V = _{statut: Ss, etape: noyau, detail: Det, hypotheses: Hj, partiel: Pj, qualification: Qu}
    ).

partiel_json(St, [partiel(Sat, Manq)], _{satisfaits: Sj, manquants: Mj}) :- memberchk(St, [inconnue, incomplet]), !,
    maplist(chemin_atome, Sat, Sj), maplist(chemin_atome, Manq, Mj).
chemin_atome(_-A, S) :- terme(A, S).
partiel_json(_, _, _{}).
hypotheses_json(etablie_sous_hypotheses, Ps, Hs) :- !,
    findall(S, ( member(preuve(_, _, _, _, _, H), Ps), member(X, H), terme(X, S) ), Hs0), sort(Hs0, Hs).
hypotheses_json(_, _, []).

% --- Les versions -----------------------------------------------------------------------------------------------------

versions(Base, _{noyau: Vn, connaissances: _{en: Ken, fr: Kfr}, base: Vb, analyseur_textes: Va, analyseur_definitions: Vd,
                 budget_noyau: B, limites: _{inferences: Imax, temps: Tmax}}) :-
    satisfaction:version_noyau(Vn0), atom_string(Vn0, Vn), satisfaction:budget(B),
    connaissances_en:version(Ken0), atom_string(Ken0, Ken), connaissances_fr:version(Kfr0), atom_string(Kfr0, Kfr),
    findall(F-H, ( member(F, ['manifeste-iconclass.json', 'manifeste-wordnet.json', 'manifeste-ressources.json']),
                   directory_file_path(Base, F, C), exists_file(C), lire(C, J), ( get_dict(commit, J, H0) -> true ; H0 = present ),
                   ( string(H0) -> H = H0 ; atom(H0) -> atom_string(H0, H) ; H = "present" ) ), FHs),
    dict_pairs(Mf, m, FHs), atom_string(Base, Bs), Vb = _{chemin: Bs, manifestes: Mf},
    (   getenv('OEDIPAMAAS_ANALYSEUR', stanza) -> Va = "stanza 1.10.1 (OEDIPAMAAS_ANALYSEUR=stanza)"
    ;   catch(udpipe:configuration(Cf), _, fail)
    ->  dict_pairs(Cf.modeles, _, Ms), findall(M, ( member(_-X, Ms), format(string(M), "~w ~w", [X.fichier, X.sha256]) ), Mss),
        atomic_list_concat(['udpipe 1'|Mss], ' ; ', Va0), atom_string(Va0, Va)
    ;   Va = "udpipe 1"
    ),
    Vd = "stanza 1.10.1 (outils/definitions/stanza_conllu.py, comme les libellés : D18 bis)",
    reglages(Imax, Tmax).

% --- JSON -------------------------------------------------------------------------------------------------------------

terme(T, S) :- format(string(S), "~q", [T]).
fait_json(F, [N|As]) :- F =.. [N0|As0], atom_string(N0, N), maplist(valeur_json, As0, As).
valeur_json(X, X) :- number(X), !.
valeur_json(X, S) :- atom(X), !, atom_string(X, S).
valeur_json(X, X) :- string(X), !.
valeur_json(X, L) :- is_list(X), !, maplist(valeur_json, X, L).
valeur_json(X, J) :- compound(X), !, fait_json(X, J).
phrase_json(phrase(Ms), J) :- maplist(mot_json, Ms, J).
mot_json(mot(I, Fo, Le, C, Tr, H, R, D, F), [I, Fos, Les, Cs, Trs, H, Rs, D, F]) :-
    maplist(en_chaine, [Fo, Le, C, R], [Fos, Les, Cs, Rs]), format(string(Trs), "~w", [Tr]).
en_chaine(X, S) :- ( string(X) -> S = X ; format(string(S), "~w", [X]) ).
