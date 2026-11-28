/*  L'adaptateur EXPÉRIMENTAL des définitions inventées des bancs de la phase 1 (docs/BANCS_PHASE1.md, § 9.4, point 2).

    Les définitions des bancs n'ont pas de notation : le compilateur des libellés (requetes_iconclass:compiler/3) ne
    peut pas les prendre, parce qu'il lit le libellé analysé dans la base (libelles_lus:partie/7), son type
    (definitions:type_libelle/2) et sa place dans l'arbre (arbre:ancetre/2). Ce module compile une définition COMME UN
    LIBELLÉ DE SCÈNE, en appelant les prédicats du compilateur sans les modifier : le graphe que le lecteur tire du
    libellé devient la requête (le chemin « scene » de compiler_/7).

    compiler_definition(+Id, +Texte, +Phrases, -Resultat)
        Texte     la définition, telle quelle (anglais)
        Phrases   son analyse (Stanza, par la frontière CoNLL-U, comme les libellés : D18 bis), faite sur le texte
                  prétraité (Resultat.net)
        Resultat  adaptation(Compilation, Chemin, Limites, Faits)
          Compilation  compilation(Id, en, scene, Suff, Nec, Statut, Raisons, Famille), la forme de compiler/3
          Chemin       le type qu'un vrai libellé de cette forme recevrait (libelles_iconclass:type_de_libelle/4,
                       calculé sur la même analyse, avec une notation fictive) : scene, classe, genre, attribut, recit,
                       concept ; s'il n'est pas « scene », un vrai libellé passerait par un autre chemin du compilateur
          Limites      ce que l'adaptateur n'a pas, et que le compilateur réel aurait pour un vrai libellé :
                         sans_heritage           aucune notation ancêtre : pas de personne héritée (heritage/4)
                         sans_aspects            pas de parties de gabarit (« ~ », « - ») : aspects/4 non appelé
                         parties_non_lues(Ps)    des parties après la partie propre (sujets:parties/3), non compilées
                         chemin_reel(T)          le type de la forme n'est pas scene (voir Chemin)
          Faits        le graphe du lecteur sur la définition (interpretation:interpreter/5)

    Ce que fait l'adaptateur, pas à pas, comme compiler_(N, L, scene, scene, …) :
      1. interpretation:interpreter(Net, en, description, Phrases, Faits) (graphe/5 du compilateur) ;
      2. requetes_iconclass:graphe_requete(Faits, Phrases, all, Cs, Ra) ;
      3. pas d'héritage (Cs1 = Cs) ni d'aspects (Gs = []) : l'adaptateur n'a pas de notation ;
      4. la suffisante et_ou_un(Cs1), la nécessaire necessaire/2, les mots non couverts mots_non_couverts/4, les
         parenthèses non lues (sur les marques du prétraitement, comme parentheses_non_lues/3) ;
      5. le statut, comme compiler/3 : invalide si la requête est mal formée, non_prise_en_charge si une construction
         négative ou modale, compilee sans raison, partielle sinon ; la famille, famille/3.
    Rien n'est changé au compilateur : ce module n'appelle que ses prédicats.  */
:- module(adaptateur_scene, [ compiler_definition/4, pretraiter_definition/4, chemin_reel/3 ]).
:- encoding(utf8).
:- use_module(library(lists)).
:- use_module(library(apply)).

% la notation fictive : ni rubrique (plus de deux caractères), ni concept (ne commence pas par 5), sans parenthèse, sans
% libellé dans la base (aucun gabarit de personnes, aucun ancêtre)
notation_fictive('BANC').

% pretraiter_definition(+Texte, -Net, -Marques, -Autres) : la partie propre (sujets:parties/3), prétraitée comme un
% libellé (libelles_iconclass:pretraiter/3) ; Autres : les parties suivantes, que l'adaptateur ne compile pas
pretraiter_definition(Texte, Net, Ms, Autres) :-
    atom_string(T, Texte),
    (   sujets:parties(T, en, [_-P1|Ps]) -> true ; P1 = T, Ps = [] ),
    libelles_iconclass:pretraiter(P1, Net, Ms),
    findall(O-P, member(O-P, Ps), Autres).

% le type que recevrait un vrai libellé de cette forme
chemin_reel(Ph, Ms, T) :-
    notation_fictive(N),
    ( catch(once(libelles_iconclass:type_de_libelle(N, Ph, Ms, T0)), _, fail) -> T = T0 ; T = inconnu ).

compiler_definition(Id, Texte, Ph, adaptation(Compilation, Chemin, Limites, Faits)) :-
    b_setval(definitions_langue, en),
    pretraiter_definition(Texte, Net, Ms, Autres),
    chemin_reel(Ph, Ms, Chemin),
    findall(L, limite(Chemin, Autres, L), Limites),
    compiler_scene(Id, Net, Ms, Ph, Compilation, Faits).

limite(_, _, sans_heritage).
limite(_, _, sans_aspects).
limite(_, Autres, parties_non_lues(Autres)) :- Autres \== [].
limite(Chemin, _, chemin_reel(Chemin)) :- Chemin \== scene.

compiler_scene(Id, Net, Ms, Ph, compilation(Id, en, scene, Suff, Nec, Statut, Raisons, Famille), Faits) :-
    (   catch(scene_(Net, Ms, Ph, F, Fn, Rs0, Faits), E, ( Rs0 = [exception(E)], F = aucune, Faits = [] ))
    ->  (   F == aucune -> Suff = aucune, Nec = aucune, Statut = invalide, Raisons = Rs0, Famille = scene-aucune
        ;   Suff = requete(Id, F), Nec = requete(Id, Fn),
            requetes:bien_formee(Suff, Es), requetes:bien_formee(Nec, Esn), append([Es, Esn], Ef),
            (   Ef \== [] -> Statut = invalide, append(Rs0, [mal_formee(Ef)], Raisons)
            ;   member(R, Rs0), memberchk(R, [construction_negative(_), construction_modale(_)])
            ->  Statut = non_prise_en_charge, Raisons = Rs0
            ;   Rs0 == [] -> Statut = compilee, Raisons = []
            ;   Statut = partielle, Raisons = Rs0
            ),
            requetes_iconclass:famille(scene, F, Famille)
        )
    ;   Suff = aucune, Nec = aucune, Statut = invalide, Raisons = [echec], Famille = scene-aucune,
        ( var(Faits) -> Faits = [] ; true )
    ).

% compiler_(N, L, scene, scene, …) sans libelles_lus, sans héritage, sans aspects
scene_(Net, Ms, Ph, F, Fn, Rs, Fs) :-
    interpretation:interpreter(Net, en, description, Ph, Fs),
    requetes_iconclass:graphe_requete(Fs, Ph, all, Cs1, Ra),
    Cs1 \== [], requetes_iconclass:et_ou_un(Cs1, F), requetes_iconclass:necessaire(Cs1, Fn),
    requetes_iconclass:mots_non_couverts(en, Ph, Cs1, Rm),
    findall(parenthese_non_lue(C), ( member(facultatif(C), Ms), definitions:mots_de_parenthese(en, C, [_|_]) ), Rp),
    append([Ra, Rm, Rp], Rs).
