/*  L'admissibilité effective des prémisses (27/11) : pour chaque assertion d'un graphe, l'état d'appui que le noyau
    lui donne (docs/NOYAU.md, § 1), calculé par les prédicats du noyau lui-même (satisfaction:charger/2, qualifie/5,
    present/2, effectif/4), et non par les seuls qualificatifs de l'assertion.
        swipl outils/graphes/premisses.pl GRAPHES.json SORTIE.json
    GRAPHES.json : des graphes au format de lire.pl ([{k, genre, faits}] ; les graphes de référence passent par
    outils/graphes/vers_faits.py). Pour chaque texte : etats {Id: Etat} et roles [[Evenement, Role, Entite, Etat]], avec
    Etat parmi
      pos_auteur, pos_cite  un appui positif dans le contexte de la figuration (`represente`), de l'auteur ou d'une
                            source citée : polarité positive, modalité affirmée, portée represente, hors de toute
                            alternative, ET chaque entité dont l'assertion parle présente (une propriété, un nom : son
                            porteur ; une relation : ses deux entités ; un rôle : son événement positif et son
                            participant) ; l'énonciateur est celui de l'assertion, sauf si un porteur n'est présent que
                            selon une source citée (D25) ;
      neg_auteur, neg_cite  un appui négatif, aux mêmes conditions (les entités dont elle parle, autres qu'elle-même,
                            présentes) ;
      aucun                 l'assertion n'appuie rien, dans un sens ni dans l'autre (une hypothèse, un titre, une
                            alternative, un autre contexte, un porteur absent) ; un rôle d'un événement nié : aucun.
    Trois niveaux, à ne pas confondre (décision de la propriétaire, 27/11) :
      1. la qualification linguistique : les qualificatifs propres de l'assertion (ce que mesure le comparateur sans
         --premisses) ;
      2. l'appui contextuellement admissible : ce que cet outil calcule, l'état d'appui selon le noyau, porteurs,
         participants et événement d'un rôle compris ;
      3. la prémisse réellement certifiable : ce que la certification du noyau accepte en plus, et que cet outil NE
         calcule PAS. Il ne calcule ni les contestations qui dépendent de K (un porteur dont le type est nié par un lien
         lexical, une prémisse niée par un lien, la négation seulement possible d'un autre sens), ni les contraintes
         (les nombres, contredits par un autre nombre ; les distinctions et identités ; les distinctions
         documentaires), ni les lectures conjointes. Un appui de niveau 2 peut donc ne pas être certifiable.
    Un graphe invalide est signalé, jamais évalué (« invalide », avec les erreurs).  */
:- initialization(main, main).
:- prolog_load_context(directory, D), atom_concat(D, '/../../oedipamaas/socle', S), asserta(user:file_search_path(socle, S)).
:- use_module(socle(satisfaction)).
:- use_module(socle(assertions)).
:- use_module(library(json)).

main :-
    current_prolog_flag(argv, [Entree, Sortie|_]),
    setup_call_cleanup(open(Entree, read, S, [encoding(utf8)]), json_read_dict(S, Gs), close(S)),
    findall(J, ( member(G, Gs), etats_texte(G, J) ), Js),
    setup_call_cleanup(open(Sortie, write, O, [encoding(utf8)]), json_write_dict(O, Js, [width(140)]), close(O)),
    length(Js, N), format("~d graphes~n", [N]).

etats_texte(G, _{k: G.k, genre: G.genre, statut: erreur, etats: _{}, roles: []}) :- G.faits == "erreur", !.
etats_texte(G, J) :-
    maplist(fait, G.faits, Fs),
    assertions:valider(Fs, Es),
    (   Es \== []
    ->  maplist(terme, Es, Ej), J = _{k: G.k, genre: G.genre, statut: invalide, erreurs: Ej, etats: _{}, roles: []}
    ;   in_temporary_module(M, satisfaction:charger(M, Fs), etats(M, Ps, Rs)),
        dict_pairs(Ed, e, Ps),
        J = _{k: G.k, genre: G.genre, statut: valide, etats: Ed, roles: Rs}
    ).

fait(["texte", T], texte(T)) :- !.
fait([F|As], T) :- atom_string(Fa, F), maplist(arg_json, As, Bs), T =.. [Fa|Bs].
arg_json(X, X) :- number(X), !.
arg_json(X, A) :- string(X), !, atom_string(A, X).
arg_json(["cite", X], cite(A)) :- !, atom_string(A, X).
arg_json(L, As) :- is_list(L), !, maplist(arg_json, L, As).
terme(T, S) :- format(string(S), "~q", [T]).

etats(M, Ps, Rs) :-
    findall(Id-Et, ( assertion_id(M, Id), etat(M, Id, Et) ), Ps0), sort(Ps0, Ps),
    findall([V, R, E, Et], ( M:role(V, R, E), etat_role(M, V, E, Et) ), Rs0), sort(Rs0, Rs).

assertion_id(M, Id) :- ( M:entite(Id, _, _) ; M:nom(Id, _, _, _) ; M:propriete(Id, _, _, _) ; M:evenement(Id, _, _)
                    ; M:relation(Id, _, _, _, _) ).

% l'entité elle-même, l'événement : ses propres qualificatifs (une entité est son propre porteur)
etat(M, Id, Et) :- ( M:entite(Id, _, _) ; M:evenement(Id, _, _) ), !, signe(M, Id, [], Et).
etat(M, Id, Et) :- M:nom(Id, E, _, _), !, signe(M, Id, [E], Et).
etat(M, Id, Et) :- M:propriete(Id, E, _, _), !, signe(M, Id, [E], Et).
etat(M, Id, Et) :- M:relation(Id, E1, _, E2, _), !, signe(M, Id, [E1, E2], Et).

signe(M, Id, Porteurs, Et) :-
    (   satisfaction:qualifie(M, Id, pos, represente, Q0), forall(member(E, Porteurs), satisfaction:present(M, E))
    ->  satisfaction:effectif(M, Q0, Porteurs, Q), etiquette(pos, Q, Et)
    ;   satisfaction:qualifie(M, Id, neg, represente, Q), forall(member(E, Porteurs), satisfaction:present(M, E))
    ->  etiquette(neg, Q, Et)
    ;   Et = aucun
    ).

% un rôle a l'état de son événement et demande son participant présent ; un rôle d'un événement nié n'appuie rien
% seul (docs/NOYAU.md, § 1.1)
etat_role(M, V, E, Et) :-
    (   satisfaction:qualifie(M, V, pos, represente, Q0), satisfaction:present(M, E)
    ->  satisfaction:effectif(M, Q0, [E], Q), etiquette(pos, Q, Et)
    ;   Et = aucun
    ).

etiquette(S, auteur, Et) :- !, atomic_list_concat([S, auteur], '_', Et).
etiquette(S, _, Et) :- atomic_list_concat([S, cite], '_', Et).
