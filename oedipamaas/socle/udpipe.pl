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
                    analyser_lot/3,    % +Textes, +Langue, -ListeDePhrases (un seul appel pour tout le lot)
                    analyser_lot/4,    % +Textes, +Langue, +Options, -ListeDePhrases ; syntaxe(false) : sans arbre
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

analyser(Texte, Langue, Phrases) :- analyser(Texte, Langue, [], Phrases).

% syntaxe(false) : segmentation, catégories et lemmes seulement (têtes à 0, relations « _ ») ; pour les compilateurs
% qui n'ont besoin que des lemmes (sujets.pl)
analyser(Texte, Langue, Options, Phrases) :-
    ( memberchk(syntaxe(false), Options) -> Parse = [] ; Parse = ['--parse'] ),
    binaire(B),
    chemin_modele(Langue, M),
    setup_call_cleanup(
        tmp_file_stream(text, Fichier, S0),
        ( set_stream(S0, encoding(utf8)), write(S0, Texte), close(S0),
          append([['--tokenize', '--tokenizer=ranges', '--tag'], Parse, [M, Fichier]], Args),
          process_create(B, Args,
                         [stdout(pipe(Out)), stderr(null), process(Pid)]),
          set_stream(Out, encoding(utf8)),
          read_string(Out, _, Sortie), close(Out),
          process_wait(Pid, Statut) ),
        delete_file(Fichier)),
    (   Statut == exit(0) -> true ; throw(error(udpipe(Statut), _)) ),
    conllu_phrases(Sortie, Phrases).

% analyser_lot(+Textes, +Langue, -Ls) : un seul appel d'UDPipe (le modèle est chargé une fois) ; les textes sont
% joints par une ligne vide (fin de paragraphe, donc de phrase) ; une ligne vide à l'intérieur d'un texte devient
% « espace + saut de ligne » (même longueur : les positions ne bougent pas) ; chaque phrase revient à son texte, ses
% positions ramenées au début du texte
analyser_lot(Textes, Langue, Ls) :- analyser_lot(Textes, Langue, [], Ls).
analyser_lot(Textes, Langue, Options, Ls) :-
    maplist(sans_ligne_vide, Textes, Textes1),
    atomic_list_concat(Textes1, '\n\n', Tout0), atom_string(Tout0, Tout),
    debuts(Textes1, 0, Debuts),
    analyser(Tout, Langue, Options, Phrases),
    maplist(phrases_du_texte(Phrases), Debuts, Textes1, Ls).

sans_ligne_vide(T0, T) :-
    split_string(T0, "", "", [S0]),
    re_vide(S0, T).

re_vide(S0, S) :-
    (   sub_string(S0, B, 2, A, "\n\n")
    ->  sub_string(S0, 0, B, _, Av), sub_string(S0, _, A, 0, Ap),
        string_concat(Av, " \n", X), string_concat(X, Ap, S1), re_vide(S1, S)
    ;   S = S0
    ).

debuts([], _, []).
debuts([T|Ts], D, [D|Ds]) :- string_length(T, L), D1 is D + L + 2, debuts(Ts, D1, Ds).

phrases_du_texte(Phrases, D0, Texte, Ps) :-
    string_length(Texte, L), Fin is D0 + L,
    findall(phrase(Ms),
            ( member(phrase(Ms0), Phrases), Ms0 = [mot(_, _, _, _, _, _, _, D1, _)|_], D1 >= D0, D1 < Fin,
              maplist(decaler(D0), Ms0, Ms) ),
            Ps).

decaler(D0, mot(I, Fo, L, C, Tr, H, R, D, F), mot(I, Fo, L, C, Tr, H, R, D1, F1)) :-
    (   D >= 0 -> D1 is D - D0, F1 is F - D0 ; D1 = D, F1 = F ).

configuration(_{binaire: B, modeles: Ms}) :-
    binaire(B),
    findall(L-_{fichier: Nom, sha256: H},
            ( modele(L, Nom), chemin_modele(L, C), sha256_fichier(C, H) ), Ps),
    dict_pairs(Ms, modeles, Ps).

sha256_fichier(C, H) :-
    setup_call_cleanup(open(C, read, S, [type(binary)]), read_string(S, _, Octets), close(S)),
    crypto_data_hash(Octets, H, [algorithm(sha256), encoding(octet)]).
