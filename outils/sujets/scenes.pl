/*  Écrit la scène de chaque document (docs/PLAN_F3.md, étape 2), pour la mesure :
        OEDIPAMAAS_REFONTE=1 swipl outils/sujets/scenes.pl BASE ENTREE.json SORTIE.jsonl
    ENTREE.json : une liste de documents {id, langue, titre, description} (le banc) ; une ligne par document :
    le texte analysé, les éléments de scène (passage en caractères), et toutes les assertions avec leurs qualificatifs,
    pour classer ce que la scène perd (non lu, non ancré, nié, non affirmé, dans le titre…).  */
:- initialization(main, main).
:- prolog_load_context(directory, D), atom_concat(D, '/../../oedipamaas/socle', S), asserta(user:file_search_path(socle, S)).
:- use_module(library(json)).
:- use_module(socle(oedipamaas)).
:- use_module(socle(scene)).
:- use_module(socle(hypotheses)).

main :-
    current_prolog_flag(argv, [Base, Entree, Sortie|_]),
    setup_call_cleanup(open(Entree, read, S0, [encoding(utf8)]), json_read_dict(S0, Docs), close(S0)),
    oedipamaas:charger_base(Base),
    atom_concat(Base, '/sujets_index', I), load_files(I, [if(not_loaded)]),     % .qlf s'il existe
    findall(L, ( member(D, Docs), oedipamaas:langue_doc(D, L) ), Ls0), sort(Ls0, Ls),
    findall(L-As, ( member(L, Ls), oedipamaas:analyses_langue(Docs, L, As) ), ParLangue),
    setup_call_cleanup(open(Sortie, write, S, [encoding(utf8)]),
        forall(member(D, Docs), ( ligne(ParLangue, D, J), json_write_dict(S, J, [width(0)]), nl(S) )),
        close(S)).

ligne(ParLangue, D, J) :-
    oedipamaas:texte_et_titre(D, Texte, FinTitre), oedipamaas:langue_doc(D, L),
    memberchk(L-As, ParLangue), memberchk(D.id-Phrases, As),
    ( get_dict(genre, D, Ge0) -> atom_string(Ge, Ge0) ; Ge = inconnu ),   % comme la commande : l'ancrage (F1) sauf pour
    interpretation:interpreter(Texte, L, Ge, FinTitre, Phrases, Fs0),            % une description visuelle déclarée
    oedipamaas:dit_par_le_titre(FinTitre, Fs0, Fs),
    scene(Fs, Sc), elements_de_scene(Sc, Els),
    findall(_{genre: G, valeur: V, porteur: Po, debut: Db, fin: Fi, saillance: Sa},
            ( member(el(G, V, Po, P, Sa), Els), memberchk(passage(P, Db, Fi), Fs) ), JEls),
    findall(_{id: A, sorte: K, valeur: V, debut: Db, fin: Fi, polarite: Pol, modalite: Mod, portee: Por,
              alternative: Alt, admissible: Adm},
            ( member(F, Fs), assertion_de(F, A, K, V, P), memberchk(passage(P, Db, Fi), Fs),
              qualif(Fs, polarite, A, Pol), qualif(Fs, modalite, A, Mod), qualif(Fs, portee, A, Por),
              ( member(alternative(_, Xs), Fs), memberchk(A, Xs) -> Alt = true ; Alt = false ),
              ( assertions:admissible(Fs, A) -> Adm = true ; Adm = false ) ),
            JAs),
    findall(_{forme: Fo, lemme: Le, categorie: C, tete: H, relation: R, debut: Db, fin: Fi, phrase: K},
            ( nth1(K, Phrases, phrase(Ms)), member(mot(_, Fo, Le, C, _, H, R, Db, Fi), Ms) ), JMs),
    hypotheses:sujets(L, Els, Etablis, Candidats),
    maplist(sujet_json(Fs), Etablis, JE), maplist(sujet_json(Fs), Candidats, JC0),
    length(JC0, NC), ( NC > 30 -> length(JC, 30), append(JC, _, JC0) ; JC = JC0 ),
    J = _{id: D.id, texte: Texte, fin_titre: FinTitre, elements: JEls, assertions: JAs, mots: JMs,
          sujets_etablis: JE, sujets_candidats: JC, nb_candidats: NC}.

sujet_json(Fs, sujet(N, As, Ds), _{notation: N, appuis: JA, distinctifs: JD}) :-
    findall(_{genre: G, element: E, origine: O, scene: V, genre_scene: GS, saillance: Sa, passage: T},
            ( member(appui(G, E, O, V, P, GS-Sa), As), ( memberchk(passage(P, Db, Fi), Fs), memberchk(texte(Tx), Fs),
              Lg is Fi - Db, sub_atom(Tx, Db, Lg, _, T) -> true ; T = '' ) ), JA),
    findall(X, ( member(G-E, Ds), format(atom(X), "~w:~w", [G, E]) ), JD).

assertion_de(entite(E, T, P), E, entite, V, P) :- texte_json(T, V).
assertion_de(nom(A, _, N, P), A, nom, V, P) :- texte_json(N, V).
assertion_de(propriete(A, _, Pr, P), A, propriete, V, P) :- texte_json(Pr, V).
assertion_de(evenement(A, Pr, P), A, evenement, V, P) :- texte_json(Pr, V).
assertion_de(relation(A, _, R, _, P), A, relation, V, P) :- texte_json(R, V).

texte_json(X, V) :- ( atomic(X) -> V = X ; term_string(X, V) ).

qualif(Fs, Q, A, V) :- T =.. [Q, A, V0], ( memberchk(T, Fs) -> V = V0 ; V = null ).
