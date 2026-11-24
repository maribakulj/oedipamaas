/*  La commande de la V1 (cahier des charges, § 10, livrable 2), en Prolog seul : ni Python, ni Janus.

    swipl oedipamaas/socle/commande.pl --base BASE --entree ENTREE.jsonl --sortie SORTIE.jsonl
    swipl oedipamaas/socle/commande.pl --base BASE --texte "Saint Jérôme dans son étude." --langue fr
    (ce module est aussi une bibliothèque : analyser_documents/3 ; commande.pl n'en est que le point d'entrée)

    ENTREE.jsonl : un document par ligne, {"id": …, "description": …, "titre": …, "langue": "fr"|"en", "genre": …}
    (« texte » vaut « description » ; le titre est facultatif et n'est qu'un indice, D15 ; genre facultatif :
    titre, cartel, notice, description, savant ; « inconnu » par défaut). SORTIE.jsonl : une ligne par document (§ 9 :
    etablis, candidats, contredits, objets, incompris, versions), triée comme l'entrée ; plus SORTIE.manifeste.json.
    Un document illisible donne une ligne avec « erreur », comptée dans le manifeste, sans arrêter le lot.
    UDPipe : OEDIPAMAAS_UDPIPE et OEDIPAMAAS_MODELES (socle/udpipe.pl) ; BASE : le dossier de la base compilée
    (iconclass.qlf, wordnet.qlf).
*/
:- module(oedipamaas, [ analyser_documents/3,  % +Base, +Documents (dicts), -Resultats (dicts)
                        texte_et_titre/3,      % +Document, -Texte analysé, -Fin du titre (0 sans titre)
                        main/1                 % +Argv : la commande (socle/commande.pl)
                      ]).
:- encoding(utf8).
:- use_module(library(main)).
:- use_module(library(json)).
:- use_module(library(optparse)).
:- use_module(library(crypto)).
:- use_module(udpipe).
:- use_module(interpretation).
:- use_module(assertions).
:- use_module(raisonnement).


version_moteur('1.0.0-j1').

charger_base(Base) :-
    (   current_predicate(iconclass:n/1) -> true
    ;   forall(member(F, ['iconclass.qlf', 'wordnet.qlf']),
               ( directory_file_path(Base, F, C), load_files(C, [redefine_module(true)]) )),
        module_property(oedipamaas, file(Ici)), file_directory_name(Ici, Dir),
        directory_file_path(Dir, 'morphologie.pl', Morpho),
        use_module(Morpho),                              % après WordNet : son index se construit au chargement
        morphologie:indexer
    ),
    raisonnement:preparer,
    (   \+ getenv('OEDIPAMAAS_REFONTE', '1') -> true    % prototype de la refonte (banc d'essai) seulement
    ;   getenv('OEDIPAMAAS_SANS_SENS', _) -> true      % pour mesurer l'apport de la couche de sens
    ;   current_predicate(sens:aligne/3), sens:aligne(_, _, _) -> true
    ;   module_property(oedipamaas, file(Ici2)), file_directory_name(Ici2, Dir2),
        directory_file_path(Dir2, 'sens.pl', Sens), use_module(Sens), sens:aligner(_)
    ).

main(Argv) :-
    Spec = [[opt(base), type(atom), longflags([base]), default('')],
            [opt(entree), type(atom), longflags([entree]), default('')],
            [opt(sortie), type(atom), longflags([sortie]), default('')],
            [opt(texte), type(atom), longflags([texte]), default('')],
            [opt(langue), type(atom), longflags([langue]), default(fr)],
            [opt(genre), type(atom), longflags([genre]), default(inconnu)]],
    opt_parse(Spec, Argv, Opts, _),
    memberchk(base(Base), Opts),
    (   Base == '' -> format(user_error, "--base est requis~n", []), halt(2) ; true ),
    get_time(T0),
    (   memberchk(texte(Texte), Opts), Texte \== ''
    ->  memberchk(langue(L), Opts), memberchk(genre(G), Opts),
        atom_string(Texte, S),
        analyser_documents(Base, [_{id: "texte", texte: S, langue: L, genre: G}], [R]),
        json_write_dict(current_output, R, [width(100)]), nl
    ;   memberchk(entree(E), Opts), memberchk(sortie(Sortie), Opts), E \== '', Sortie \== ''
    ->  lire_jsonl(E, Docs),
        analyser_documents(Base, Docs, Rs),
        ecrire_jsonl(Sortie, Rs),
        get_time(T1),
        manifeste(Base, E, Sortie, Rs, T0, T1)
    ;   format(user_error, "usage : --base BASE (--texte T [--langue fr|en] | --entree E.jsonl --sortie S.jsonl)~n", []),
        halt(2)
    ).

% analyser_documents(+Base, +Docs, -Resultats) : un lot ; UDPipe une fois par langue ; chaque document isolé
analyser_documents(Base, Docs, Rs) :-
    charger_base(Base),
    versions(Base, Vs),
    findall(L, ( member(D, Docs), langue_doc(D, L) ), Ls0), sort(Ls0, Ls),
    findall(L-Analyses, ( member(L, Ls), analyses_langue(Docs, L, Analyses) ), ParLangue),
    maplist(resultat(Vs, ParLangue), Docs, Rs).

langue_doc(D, L) :- ( get_dict(langue, D, L0) -> atom_string(L, L0) ; L = fr ).

analyses_langue(Docs, L, Analyses) :-
    findall(Id-T, ( member(D, Docs), langue_doc(D, L), texte_doc(D, T), Id = D.id ), Paires),
    pairs_values(Paires, Textes),
    (   Textes == [] -> Analyses = []
    ;   catch(udpipe:analyser_lot(Textes, L, Ps), Err, ( print_message(error, Err), fail ))
    ->  pairs_keys(Paires, Ids), pairs_keys_values(Analyses, Ids, Ps)
    ;   Analyses = []
    ).

% le texte analysé : la description (champ « description », ou « texte »), précédée du titre s'il y en a un ; le titre
% seul est accepté mais ne donne aucun code établi (décision D15 : un titre est un indice, jamais une preuve)
texte_doc(D, T) :- texte_et_titre(D, T, _).
texte_et_titre(D, T, FinTitre) :-
    champ(D, titre, Ti), ( champ(D, description, De) -> true ; champ(D, texte, De) -> true ; De = "" ),
    !,
    string_length(Ti, FinTitre),
    (   De == "" -> T = Ti ; atomic_list_concat([Ti, '. ', De], A), atom_string(A, T) ).
texte_et_titre(D, T, 0) :- ( champ(D, description, T) -> true ; champ(D, texte, T) ).
champ(D, K, V) :- get_dict(K, D, V0), string(V0), split_string(V0, "", " \t\n", [V]), V \== "".

resultat(Vs, ParLangue, D, R) :-
    Id = D.get(id, ""),
    (   \+ texte_doc(D, _)
    ->  R0 = _{erreur: "texte absent ou vide"}
    ;   catch(resultat_(Vs, ParLangue, D, R0), Err, ( message_to_codes(Err, Msg), R0 = _{erreur: Msg} ))
    ->  true
    ;   R0 = _{erreur: "analyse impossible"}
    ),
    R = R0.put(document, Id).

message_to_codes(Err, Msg) :- message_to_codes(Err, [], Cs) -> string_codes(Msg, Cs) ; term_string(Err, Msg).
message_to_codes(E, _, Cs) :- catch(( message_to_codes_(E, Cs) ), _, fail).
message_to_codes_(E, Cs) :- format(codes(Cs), "~q", [E]).

resultat_(Vs, ParLangue, D, R) :-
    texte_et_titre(D, Texte, FinTitre), langue_doc(D, L),
    ( get_dict(genre, D, G0) -> atom_string(G, G0) ; G = inconnu ),
    memberchk(L-Analyses, ParLangue), memberchk(D.id-Phrases, Analyses),
    interpretation:interpreter(Texte, L, G, FinTitre, Phrases, Fs0),
    dit_par_le_titre(FinTitre, Fs0, Fs),
    assertions:valider(Fs, Err),
    (   Err \== [] -> term_string(Err, ES), R = _{erreur: ES}
    ;   raisonnement:coder(Fs, C),
        objets(Fs, Os), incompris(Fs, Is),
        crypto_data_hash(Texte, H, [algorithm(sha256)]),
        R = _{versions: Vs.put(entree, H), etablis: C.etablis, candidats: C.candidats,
              contredits: C.contredits, objets: Os, incompris: Is}
    ).

% ce qui n'est dit que dans le titre (passage entièrement dans le titre) : modalité « titre », un indice qui ne fonde
% aucun code établi ; ce que la description dit aussi reste porté par sa propre assertion
dit_par_le_titre(0, Fs, Fs) :- !.
dit_par_le_titre(Fin, Fs0, Fs) :-
    findall(A, ( member(F, Fs0), assertion_passage(F, A, P), memberchk(passage(P, _, F2), Fs0), F2 =< Fin ), As0),
    sort(As0, As),
    maplist(requalifier(As), Fs0, Fs).
assertion_passage(entite(E, _, P), E, P).
assertion_passage(nom(A, _, _, P), A, P).
assertion_passage(propriete(A, _, _, P), A, P).
assertion_passage(evenement(V, _, P), V, P).
assertion_passage(relation(A, _, _, _, P), A, P).
requalifier(As, modalite(A, M0), modalite(A, M)) :- !, ( memberchk(A, As), M0 == affirme -> M = titre ; M = M0 ).
requalifier(_, F, F).

objets(Fs, Os) :-
    findall(O, ( member(entite(E, Tete, P), Fs), memberchk(passage(P, D, F), Fs), texte_de(Fs, D, F, T),
                 ( memberchk(nom(_, E, Nom, _), Fs) -> true ; Nom = null ),
                 O = _{id: E, tete: Tete, nom: Nom, passage: [D, F], texte: T} ), Os).
incompris(Fs, Is) :-
    findall(_{passage: [D, F], texte: T, raison: R},
            ( member(incompris(P, R), Fs), memberchk(passage(P, D, F), Fs), texte_de(Fs, D, F, T) ), Is).
texte_de(Fs, D, F, T) :- memberchk(texte(Tx), Fs), L is F - D, sub_string(Tx, D, L, _, T).

% versions : moteur, base (manifeste d'Iconclass), analyseur et modèles, règles (empreinte des fichiers du moteur)
versions(Base, _{moteur: Vm, base: Vb, analyseur: Va, regles: Vr}) :-
    version_moteur(Vm),
    directory_file_path(Base, 'manifeste-iconclass.json', MI),
    (   exists_file(MI) -> setup_call_cleanup(open(MI, read, S), json_read_dict(S, J), close(S)),
        ( get_dict(commit, J, Cm) -> true ; Cm = inconnu ), format(string(Vb), "iconclass ~w ; wordnet 3.0", [Cm])
    ;   Vb = "inconnue"
    ),
    (   catch(udpipe:configuration(Cf), _, fail)
    ->  dict_pairs(Cf.modeles, _, Ms), findall(M, ( member(_-X, Ms), format(string(M), "~w ~w", [X.fichier, X.sha256]) ), Mss),
        atomic_list_concat(['udpipe'|Mss], ' ; ', Va0), atom_string(Va0, Va)
    ;   Va = "non configuré"
    ),
    module_property(oedipamaas, file(F)), file_directory_name(F, Dir),
    findall(C, ( member(X, [assertions, conllu, interpretation, raisonnement, udpipe, oedipamaas, arbre, notation]),
                 atom_concat(X, '.pl', Fx), directory_file_path(Dir, Fx, Px), read_file_to_string(Px, C, []) ), Cs),
    atomic_list_concat(Cs, Tout), crypto_data_hash(Tout, H, [algorithm(sha256)]),
    string_concat("sha256:", H, Vr).

lire_jsonl(F, Docs) :-
    setup_call_cleanup(open(F, read, S, [encoding(utf8)]), lire_lignes(S, Docs), close(S)).
lire_lignes(S, Docs) :-
    read_line_to_string(S, L),
    (   L == end_of_file -> Docs = []
    ;   L == "" -> lire_lignes(S, Docs)
    ;   catch(atom_json_dict(L, D, []), _, D = _{id: "?", erreur_lecture: L}), Docs = [D|R], lire_lignes(S, R)
    ).

ecrire_jsonl(F, Rs) :-
    setup_call_cleanup(open(F, write, S, [encoding(utf8)]),
                       forall(member(R, Rs), ( json_write_dict(S, R, [width(0)]), nl(S) )),
                       close(S)).

manifeste(Base, E, Sortie, Rs, T0, T1) :-
    versions(Base, Vs),
    length(Rs, N), aggregate_all(count, ( member(R, Rs), get_dict(erreur, R, _) ), Ne),
    aggregate_all(sum(K), ( member(R, Rs), get_dict(etablis, R, Et), length(Et, K) ), Net),
    read_file_to_string(Sortie, Out, []), crypto_data_hash(Out, H, [algorithm(sha256)]),
    D is T1 - T0, Ms is round(1000 * D / max(1, N)),
    M = _{versions: Vs, entree: E, documents: N, erreurs: Ne, codes_etablis: Net, duree_s: D, ms_par_document: Ms,
          sha256_sortie: H},
    file_name_extension(Racine, _, Sortie), atom_concat(Racine, '.manifeste.json', FM),
    setup_call_cleanup(open(FM, write, S), json_write_dict(S, M, [width(80)]), close(S)),
    json_write_dict(current_output, _{documents: N, erreurs: Ne, codes_etablis: Net, ms_par_document: Ms}, [width(0)]), nl.
