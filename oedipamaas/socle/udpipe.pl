/*  L'analyseur syntaxique externe (cahier des charges, § 6.1) : UDPipe 1, binaire hors ligne, lancé par Prolog.

    analyser(+Texte, +Langue, -Phrases) : segmente, étiquette et analyse Texte (une chaîne) avec le modèle de la langue
    (fr, en), puis lit le CoNLL-U (conllu:conllu_phrases/2). Les positions des mots sont en caractères dans Texte.
    configuration(-Config) : le binaire, les modèles et leur empreinte, pour les versions de la sortie.

    Emplacements (dans l'ordre) : les drapeaux Prolog oedipamaas_udpipe et oedipamaas_modeles, sinon les variables
    d'environnement OEDIPAMAAS_UDPIPE (chemin du binaire) et OEDIPAMAAS_MODELES (dossier des modèles), sinon
    « udpipe » dans le PATH et le dossier courant. Le modèle de chaque langue est déclaré par modele/2.

    Le texte passe par un fichier temporaire (pas par un tube : un long texte bloquerait l'écriture tant que la sortie
    n'est pas lue).
*/
:- module(udpipe, [ analyser/3,        % +Texte, +Langue, -Phrases
                    configuration/1    % -Config
                  ]).
:- encoding(utf8).
:- use_module(library(process)).
:- use_module(library(readutil)).
:- use_module(library(crypto)).
:- use_module(library(dicts)).
:- use_module(conllu).

% modèles UD 2.5 (UDPipe 1, LINDAT 11234/1-3131) ; licence CC BY-NC-SA 4.0 : voir DECISIONS.md (D7)
modele(fr, 'french-gsd-ud-2.5-191206.udpipe').
modele(en, 'english-ewt-ud-2.5-191206.udpipe').

reglage(Drapeau, Env, Defaut, Valeur) :-
    (   current_prolog_flag(Drapeau, V0) -> Valeur = V0
    ;   getenv(Env, V1) -> Valeur = V1
    ;   Valeur = Defaut
    ).

binaire(B) :-
    reglage(oedipamaas_udpipe, 'OEDIPAMAAS_UDPIPE', udpipe, B0),
    (   B0 == udpipe -> absolute_file_name(path(udpipe), B, [access(execute)]) ; B = B0 ).

chemin_modele(Langue, Chemin) :-
    (   modele(Langue, Nom) -> true ; domain_error(langue, Langue) ),
    reglage(oedipamaas_modeles, 'OEDIPAMAAS_MODELES', '.', Dossier),
    directory_file_path(Dossier, Nom, Chemin),
    (   exists_file(Chemin) -> true ; existence_error(modele_udpipe, Chemin) ).

analyser(Texte, Langue, Phrases) :-
    binaire(B),
    chemin_modele(Langue, M),
    setup_call_cleanup(
        tmp_file_stream(text, Fichier, S0),
        ( set_stream(S0, encoding(utf8)), write(S0, Texte), close(S0),
          process_create(B, ['--tokenize', '--tokenizer=ranges', '--tag', '--parse', M, Fichier],
                         [stdout(pipe(Out)), stderr(null), process(Pid)]),
          set_stream(Out, encoding(utf8)),
          read_string(Out, _, Sortie), close(Out),
          process_wait(Pid, Statut) ),
        delete_file(Fichier)),
    (   Statut == exit(0) -> true ; throw(error(udpipe(Statut), _)) ),
    conllu_phrases(Sortie, Phrases).

configuration(_{binaire: B, modeles: Ms}) :-
    binaire(B),
    findall(L-_{fichier: Nom, sha256: H},
            ( modele(L, Nom), chemin_modele(L, C), sha256_fichier(C, H) ), Ps),
    dict_pairs(Ms, modeles, Ps).

sha256_fichier(C, H) :-
    setup_call_cleanup(open(C, read, S, [type(binary)]), read_string(S, _, Octets), close(S)),
    crypto_data_hash(Octets, H, [algorithm(sha256), encoding(octet)]).
