% Historique (version 1.0) : n'est plus le moteur en construction ; voir docs/HISTORIQUE.md.
/*  La preuve d'un code (conception 1.0, § 10), rendue en JSON.

    Trois règles, pour l'instant (les règles d'iconographe de R3 s'y ajouteront) :
    - lexical : une mention de la description (champ, chemin JSON, texte) donne une forme (le mot, ou un lemme), qui
      est une entrée de l'index d'Iconclass pour la notation (mot clé, mot du libellé, attribut possible, renvoi), ou
      qui y mène par un lien WordNet nommé (synonyme, hyperonyme à un ou deux pas, dérivé…) ;
    - specialisation : une notation soutenue a pour enfant la notation, dont une part des mots propres est décrite, la
      plus grande parmi ses sœurs ;
    - ancetre : la notation est l'ancêtre d'un code prouvé (coder un descendant affirme ses ancêtres).
    Chaque feuille cite le fait de la description (chemin, texte) ou de la base (libellé, entrée de l'index).
*/
:- module(preuve, [ preuve_lexicale/2,       % +N, -Dict
                    preuve_specialisation/3, % +Depart, +N, -Dict
                    preuve_json/2            % +Dict, -Atome JSON
                  ]).

:- use_module(library(json)).
:- use_module(recherche).
:- use_module(specialisation).

libelle(N, T) :- ( iconclass:libelle(N, en, T0) -> T = T0 ; T = '' ).

preuve_lexicale(N, _{regle: lexical, notation: N, iconclass: Lib, appuis: Appuis}) :-
    libelle(N, Lib),
    findall(A, appui(N, A), As0),
    sort(As0, Appuis),
    Appuis \== [].

appui(N, _{chemin: Chemin, texte: Texte, forme: F, lien: Lien, entree: Src}) :-
    recherche:candidat(N, M, p(M, F, Lien0, Src0)),
    description:mention(M, _, Chemin, Texte),
    term_string(Lien0, Lien),
    term_string(Src0, Src).

preuve_specialisation(Depart, N,
                      _{regle: specialisation, notation: N, iconclass: Lib, depuis: Depart, part_decrite: Part,
                        mots_propres_decrits: Mots}) :-
    libelle(N, Lib),
    specialisation:part_decrite(N, Part),
    % un mot par mot propre décrit, sous sa forme écrite (la première forme de l'index)
    findall(W, ( distinct(I, ( propres_index:propre(N, I, F), specialisation:decrit(F) )),
                 once(propres_index:propre(N, I, W)) ),
            Ws),
    sort(Ws, Mots).

preuve_json(Dict, Atome) :-
    with_output_to(atom(Atome), json_write_dict(current_output, Dict, [width(0)])).
