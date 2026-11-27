/*  Le prototype vertical avec le noyau (C4, C5) : chaque texte est lu (lecteur, ancrage), normalisé, puis codé par
    les requêtes compilées (codage.pl).
        OEDIPAMAAS_ANALYSEUR=stanza swipl outils/vertical/coder.pl BASE TEXTES.json SORTIE.json [PAS [CONTROLE]]
    TEXTES.json : [{k, notation, langue, positif, negatif, indetermine, variantes?}] (ou sans notation : fiches.json
    est alors lu à côté pour la retrouver par k). PAS : une fiche sur PAS. CONTROLE : une fiche sur CONTROLE est aussi
    codée en mode exhaustif : CONTROLE est le nombre de fiches contrôlées, les premières de l'échantillon ; les deux
    modes doivent donner les mêmes codes (C5, I4).
    SORTIE.json : pour chaque fiche et chaque texte, le statut de la notation visée (etabli, candidat, ecarte,
    contradictoire, absent), à part un descendant établi (ascendance documentaire : jamais compté comme la notation
    visée, I11), les codes établis, ceux hors de la branche documentaire, et l'accord des deux modes ; et, pour la
    mesure, le nombre de codes de chaque statut et le nombre de codes conditionnels dont une preuve suppose un sens.
    Variables d'environnement (mesure) :
      OEDIPAMAAS_NORMALISATION=non   le graphe du lecteur tel quel (codage:coder/5, normaliser(non))
      OEDIPAMAAS_DERIVATIONS=oui     la passe des assertions dérivées (lot 3 : codage:coder/5, derivations(oui)) ;
                                     ses codes sont conditionnel_par_derivation, jamais déductifs
      OEDIPAMAAS_INFERENCES=N        N inférences au plus par texte (lecture et codage) ; au-delà, le statut
                                     « interrompu » (cause inferences, et la phase) : la limite d'une mesure
      OEDIPAMAAS_DELAI=S             S secondes de mur au plus par texte : un garde-fou (cause mur)
      OEDIPAMAAS_INFERENCES_EXHAUSTIF=N  le budget du mode exhaustif (le contrôle ; sans limite par défaut) ; un
                                     contrôle interrompu donne l'accord « exhaustif_interrompu », jamais « different »
    Chaque texte a sa mesure (temps de mur et processeur, inférences, de la lecture et du codage ; taille du graphe) ;
    SORTIE.json.passe.json décrit la passe (réglage, tranche, fiches, commit, analyses, début et fin).
      OEDIPAMAAS_TRANCHE=I/N         la I-ième de N tranches de l'échantillon (pour des passes plus courtes)
      OEDIPAMAAS_SENS_EN=premier     (connaissances_commun.pl) l'anglais ne prend que le premier sens de WordNet,
                                     comme avant D30 : pour mesurer l'effet de D30, jamais par défaut  */
:- initialization(main, main).
:- prolog_load_context(directory, D), atom_concat(D, '/../../oedipamaas/socle', S), asserta(user:file_search_path(socle, S)).
:- use_module(socle(oedipamaas)).
:- use_module(library(json)).
:- use_module(library(time)).
:- use_module(library(process)).
:- use_module(library(readutil)).

main :-
    get_time(D0), nb_setval(debut, D0),
    version_du_code(Co, Mod), nb_setval(commit, Co), nb_setval(arbre_modifie, Mod),   % au départ : le code chargé
    current_prolog_flag(argv, [Base, Entree, Sortie|Opt]),
    ( Opt = [P0|_] -> atom_number(P0, Pas) ; Pas = 1 ),
    ( Opt = [_, C0|_] -> atom_number(C0, Controle) ; Controle = 0 ),
    oedipamaas:charger_base(Base),
    forall(member(F, ['/ressources.qlf', '/requetes_index']), ( atom_concat(Base, F, C), load_files(C, []) )),
    use_module(socle(codage)), codage:indexer,
    lire(Entree, Fiches0), notations(Entree, Fiches0, Fiches1),
    findall(F, ( nth1(I, Fiches1, F), (I - 1) mod Pas =:= 0 ), Fiches2),
    tranche(Fiches2, Fiches),
    findall(L-t(K, Genre, T), ( member(Fi, Fiches), atom_string(L, Fi.langue), K = Fi.k, textes(Fi, Genre, T) ), Ts),
    findall(L, member(L-_, Ts), Ls0), sort(Ls0, Ls),
    findall(K, ( nth1(I, Fiches, Fi), I =< Controle, K = Fi.k ), Ks), nb_setval(controlees, Ks),
    findall(R, ( member(L, Ls), findall(X, member(L-X, Ts), Xs), lire_et_coder(L, Xs, Controle, Rs), member(R, Rs) ), Res),
    findall(J, ( member(Fi, Fiches), fiche(Fi, Res, J) ), Js),
    setup_call_cleanup(open(Sortie, write, S, [encoding(utf8)]), json_write_dict(S, Js, [width(140)]), close(S)),
    length(Js, N), format("~d fiches~n", [N]),
    passe(Entree, Pas, Fiches, Passe), atom_concat(Sortie, '.passe.json', Sp),
    setup_call_cleanup(open(Sp, write, S2, [encoding(utf8)]), json_write_dict(S2, Passe, [width(140)]), close(S2)).

% La description de la passe, à côté de la sortie (SORTIE.passe.json) : de quoi la refaire et la contrôler
passe(Entree, Pas, Fiches, _{entree: Entree, pas: Pas, tranche: Tr, fiches: Ks, reglage: Env, commit: Co,
                             arbre_modifie: Mod, swipl: V,
                             processeurs: Np, analyses: As, debut: D0, fin: D1}) :-
    findall(K, ( member(F, Fiches), K = F.k ), Ks),
    ( getenv('OEDIPAMAAS_TRANCHE', Tr0) -> atom_string(Tr0, Tr) ; Tr = "1/1" ),
    findall(Nm-Vl, ( member(Nm, ['OEDIPAMAAS_ANALYSEUR', 'OEDIPAMAAS_NORMALISATION', 'OEDIPAMAAS_SENS_EN',
                                  'OEDIPAMAAS_INFERENCES', 'OEDIPAMAAS_DELAI', 'OEDIPAMAAS_DERIVATIONS']),
                     getenv(Nm, Vl0), atom_string(Vl0, Vl) ), Ev), dict_pairs(Env, r, Ev),
    nb_getval(commit, Co), nb_getval(arbre_modifie, Mod),
    current_prolog_flag(version, V), current_prolog_flag(cpu_count, Np),
    findall(A, analyse(A), As), nb_getval(debut, D0), get_time(D1).
prolog_load_context_dir(D) :- source_file(main, F), file_directory_name(F, D).
% le commit du code au départ de la passe, et si l'arbre de travail avait des modifications non commitées (alors le
% commit ne dit pas tout le code exécuté : la passe le dit, reunir_tranches.py la refuse)
version_du_code(Co, Mod) :-
    prolog_load_context_dir(Dir),
    ( git_ligne(Dir, ['rev-parse', 'HEAD'], Co0) -> Co = Co0 ; Co = inconnu ),
    ( git_ligne(Dir, ['status', '--porcelain', '--untracked-files=no'], _) -> Mod = true ; Mod = false ).
git_ligne(Dir, Args, L) :-
    catch(setup_call_cleanup(process_create(path(git), ['-C', Dir|Args], [stdout(pipe(O))]),
                             read_line_to_string(O, L), close(O)), _, fail),
    L \== end_of_file.

% OEDIPAMAAS_TRANCHE=I/N : la I-ième de N tranches de l'échantillon (une fiche sur N, à partir de la I-ième) ; les
% tranches se réunissent (outils/mesure/reunir_tranches.py) en la mesure entière
tranche(Fs0, Fs) :-
    (   getenv('OEDIPAMAAS_TRANCHE', T), split_string(T, "/", "", [I0, N0]), number_string(I, I0), number_string(N, N0)
    ->  findall(F, ( nth1(J, Fs0, F), (J - 1) mod N =:= I - 1 ), Fs)
    ;   Fs = Fs0
    ).

lire(F, J) :- setup_call_cleanup(open(F, read, S, [encoding(utf8)]), json_read_dict(S, J), close(S)).
notations(_, Fs, Fs) :- Fs = [F|_], get_dict(notation, F, _), !.
notations(Entree, Fs0, Fs) :-
    file_directory_name(Entree, D), directory_file_path(D, 'fiches.json', Ff), lire(Ff, Fis),
    maplist(avec_notation(Fis), Fs0, Fs).
% (un prédicat, pas une lambda : une variable libre d'une lambda de yall n'est pas partagée, et Fis y restait libre)
avec_notation(Fis, F0, F) :- member(Fi, Fis), Fi.k =:= F0.k, !, F = F0.put(notation, Fi.notation).

textes(Fi, G, T) :- member(G, [positif, negatif, indetermine]), T = Fi.get(G).
textes(Fi, G, T) :- get_dict(variantes, Fi, Vs), dict_pairs(Vs, _, Ps), member(G0-T, Ps), atom_concat('variante_', G0, G).

lire_et_coder(L, Xs, Controle, Rs) :-
    findall(T, member(t(_, _, T), Xs), Textes),
    get_time(A0), statistics(cputime, C0),
    udpipe:analyser_lot(Textes, L, Ps),
    get_time(A1), statistics(cputime, C1), Ma is A1 - A0, Ca is C1 - C0, length(Textes, Nt),
    assertz(analyse(_{langue: L, textes: Nt, mur: Ma, cpu_prolog: Ca})),
    findall(r(K, G, Res, Accord, Me),
            ( nth1(I, Xs, t(K, G, T)), nth1(I, Ps, Phrases),
              coder_texte(T, L, Phrases, indexe, Res, Me),
              (   Controle > 0, nb_getval(controlees, Ks), memberchk(K, Ks), \+ interrompu(Res)
              ->  % le mode exhaustif essaie toutes les requêtes : son budget est le sien (OEDIPAMAAS_INFERENCES_EXHAUSTIF,
                  % sans limite par défaut) ; interrompu, il ne dit rien de l'accord (jamais « different »)
                  setup_call_cleanup(budget_exhaustif(Ancien), coder_texte(T, L, Phrases, exhaustif, Rx, _),
                                     retablir_budget(Ancien)),
                  (   Rx = interrompu(_, _) -> Accord = exhaustif_interrompu
                  ;   Rx == Res -> Accord = egal
                  ;   Accord = different, ecrire_desaccord(K, G, Res, Rx)
                  )
              ;   Accord = non_controle
              ) ),
            Rs).
:- dynamic analyse/1.
interrompu(erreur).
% OEDIPAMAAS_CONTROLE_DIFF=DOSSIER : un désaccord des deux modes est écrit (les deux résultats, en termes) pour l'analyse
ecrire_desaccord(K, G, Ri, Rx) :-
    (   getenv('OEDIPAMAAS_CONTROLE_DIFF', D)
    ->  format(atom(F), "~w/desaccord_~w_~w.pl", [D, K, G]),
        setup_call_cleanup(open(F, write, S, [encoding(utf8)]),
                           ( format(S, "indexe(~q).~nexhaustif(~q).~n", [Ri, Rx]) ), close(S))
    ;   true
    ).
budget_exhaustif(Ancien) :-
    ( getenv('OEDIPAMAAS_INFERENCES', A) -> Ancien = A ; Ancien = aucun ),
    ( getenv('OEDIPAMAAS_INFERENCES_EXHAUSTIF', E) -> setenv('OEDIPAMAAS_INFERENCES', E) ; unsetenv('OEDIPAMAAS_INFERENCES') ).
retablir_budget(aucun) :- !, unsetenv('OEDIPAMAAS_INFERENCES').
retablir_budget(A) :- setenv('OEDIPAMAAS_INFERENCES', A).
interrompu(interrompu(_, _)).

% La mesure d'un texte (lot 1, instrumentée) : pour la lecture (interprétation, ancrage) et pour le codage, le temps
% de mur, le temps processeur et le nombre d'inférences ; la taille du graphe ; l'interruption, s'il y en a une, et
% la phase où elle a eu lieu. Deux limites :
%   OEDIPAMAAS_INFERENCES=N  un budget d'inférences par texte (lecture et codage ensemble) : une interruption qui ne
%                            dépend ni de la machine ni de sa charge, reproductible ;
%   OEDIPAMAAS_DELAI=S       une limite de temps de mur par texte, en garde-fou (dépend de la charge : jamais la
%                            limite d'une mesure, seulement sa sécurité).
% Res : la liste des codes, ou interrompu(Cause, Phase) (Cause : inferences | mur), ou erreur.
coder_texte(T, L, Phrases, Mode, Res, Me) :-
    ( getenv('OEDIPAMAAS_NORMALISATION', non) -> Opts0 = [normaliser(non)] ; Opts0 = [] ),
    ( getenv('OEDIPAMAAS_DERIVATIONS', oui) -> Opts = [derivations(oui)|Opts0] ; Opts = Opts0 ),
    ( getenv('OEDIPAMAAS_INFERENCES', I0), atom_number(I0, Imax) -> true ; Imax = inf ),
    ( getenv('OEDIPAMAAS_DELAI', D0), atom_number(D0, D) -> true ; D = inf ),
    nb_setval(phase, lecture),
    get_time(W0), statistics(cputime, C0), statistics(inferences, N0),
    Lire = ( interpretation:interpreter(T, L, description, 0, Phrases, Fs),
             get_time(W1), statistics(cputime, C1), statistics(inferences, N1),
             nb_setval(lecture, m(W1, C1, N1)), nb_setval(phase, codage),
             codage:coder(L, Fs, Mode, Opts, Res0), length(Fs, Na), nb_setval(assertions, Na) ),
    % Borne réussit toujours et lie Issue : ok, limite (le budget d'inférences) ou echec (la lecture ou le codage a
    % échoué : une erreur, jamais une interruption)
    (   Imax == inf
    ->  Borne = ( Lire -> Issue = ok ; Issue = echec )
    ;   Borne = ( call_with_inference_limit(Lire, Imax, R)
                -> ( R == inference_limit_exceeded -> Issue = limite ; Issue = ok ) ; Issue = echec )
    ),
    ( D == inf -> Appel = Borne ; Appel = call_with_time_limit(D, Borne) ),
    nb_setval(lecture, aucune), nb_setval(assertions, null),
    catch(Appel, E, ( E == time_limit_exceeded -> Issue = mur ; print_message(error, E), Issue = echec )),
    (   Issue == ok -> Res1 = Res0
    ;   Issue == echec -> Res1 = erreur
    ;   Res1 = Issue
    ),
    get_time(W2), statistics(cputime, C2), statistics(inferences, N2), nb_getval(phase, Ph),
    (   Res1 == limite -> Res = interrompu(inferences, Ph)
    ;   Res1 == mur -> Res = interrompu(mur, Ph)
    ;   Res = Res1
    ),
    nb_getval(lecture, Lm), nb_getval(assertions, Na1),
    (   Lm = m(W1, C1, N1)
    ->  Ml = _{mur: W1 - W0, cpu: C1 - C0, inferences: N1 - N0}, Mc = _{mur: W2 - W1, cpu: C2 - C1, inferences: N2 - N1}
    ;   Ml = _{mur: W2 - W0, cpu: C2 - C0, inferences: N2 - N0}, Mc = null
    ),
    evaluer(Ml, Mle), ( Mc == null -> Mce = null ; evaluer(Mc, Mce) ),
    Tm is W2 - W0,
    Me = _{lecture: Mle, codage: Mce, total_mur: Tm, assertions: Na1}.
evaluer(M0, M) :- dict_pairs(M0, T, Ps0), findall(K-V, ( member(K-E, Ps0), V is E ), Ps), dict_pairs(M, T, Ps).

fiche(Fi, Res, J) :-
    atom_string(N, Fi.notation), K = Fi.k,
    findall(G-V, ( member(r(K0, G, R, A, Me), Res), K0 =:= K, visee(N, R, A, Me, V0), V = V0.put(mesure, Me) ), Vs),
    dict_pairs(J0, _, Vs), J = J0.put(_{k: K, notation: Fi.notation, langue: Fi.langue}).

hyp_derivations(toutes(Hs), Hs) :- !.
hyp_derivations(Hs, Hs).

visee(_, erreur, _, Me, _{statut: erreur, temps: Me.total_mur}) :- !.
visee(_, interrompu(C, Ph), _, Me, _{statut: interrompu, interruption: C, phase: Ph, temps: Me.total_mur}) :- !.
visee(N, R, A, Me, _{statut: St, complet: Co, necessaire: Ne, descendant_etabli: De, etablis: Es, etablissables: Eb,
                     hors_branche: Hs, hors_branche_etablissables: Hb, accord: A, temps: Me.total_mur, comptes: Cp,
                     conditionnels_par_sens: Nsens, derivations_par_regle: Dr, visee_derivations: Vd}) :-
    findall(S, member(code(_, S, _, _), R), Ss), msort(Ss, Ss1), clumped(Ss1, Cl), dict_pairs(Cp, c, Cl),
    aggregate_all(count, ( member(code(_, conditionnel, Ps, _), R), member(preuve(_, _, _, _, _, Hs0), Ps),
                           memberchk(sens_suppose(_, _, _), Hs0) ), Nsens),
    % lot 3 : les règles des hypothèses de dérivation, sur tous les codes conditionnels par dérivation ; celles de la
    % notation visée
    findall(Rg, ( member(code(_, conditionnel_par_derivation, derivation(Hd, _), _), R), hyp_derivations(Hd, Hl),
                  member(derivation(_, Rg, _, _), Hl) ), Rgs), msort(Rgs, Rgs1), clumped(Rgs1, ClR), dict_pairs(Dr, d, ClR),
    (   memberchk(code(N, conditionnel_par_derivation, derivation(Hv, _), _), R)
    ->  hyp_derivations(Hv, Hvl), findall(Rg, member(derivation(_, Rg, _, _), Hvl), Vd0), msort(Vd0, Vd)
    ;   Vd = []
    ),
    ( memberchk(code(N, S0, _, annexe(C0, N0)), R) -> St = S0, Co = C0, Ne = N0 ; St = absent, Co = null, Ne = null ),
    ( member(code(N2, etabli, _, _), R), arbre:ancetre(N2, N) -> De = N2 ; De = null ),
    findall(E, member(code(E, etabli, _, _), R), Es),
    findall(E, ( member(E, Es), E \== N, \+ arbre:ancetre(E, N), \+ arbre:ancetre(N, E) ), Hs),
    findall(E, member(code(E, etablissable, _, _), R), Eb),
    findall(E, ( member(E, Eb), E \== N, \+ arbre:ancetre(E, N), \+ arbre:ancetre(N, E) ), Hb).
