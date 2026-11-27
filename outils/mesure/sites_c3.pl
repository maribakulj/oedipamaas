/*  Les sites des transformations de la PR #16 (contre-expertise du 27/11) : pour chaque partie de libellé de la base,
    dans les deux langues, ce que chaque opération de #16 change aux conditions lues, opération par opération, chacune
    appliquée seule aux conditions de base (sans les corrections de #16).
        swipl outils/mesure/sites_c3.pl SOCLE BASE SORTIE.jsonl
    SOCLE : le dossier oedipamaas/socle d'une copie de la branche de #16 (claude/c3-corrections, 54805da) : ce script
    appelle ses prédicats internes (participes/5, sujets_partages/4, actions/5, composes_syntaxiques/5,
    complements_non_lus/5, matieres/3, enumeration/2) et ne marche qu'avec elle. Pour un composé, le site donne aussi
    la tête (« tete ») ; pour les autres, « tete » est vide.  */
:- initialization(main, main).
:- use_module(library(json)).

main :-
    current_prolog_flag(argv, [Socle, Base, Sortie|_]),
    asserta(user:file_search_path(socle, Socle)),
    use_module(socle(oedipamaas)),
    oedipamaas:charger_base(Base),
    forall(member(F, ['/ressources.qlf', '/libelles_lus', '/definitions_index']), ( atom_concat(Base, F, C), load_files(C, []) )),
    use_module(socle(requetes_iconclass)),
    findall(N-L-R, libelles_lus:partie(N, L, R, _, _, _, _), Ps0), sort(Ps0, Ps),
    length(Ps, Np), format(user_error, "~d parties~n", [Np]),
    concurrent_maplist(sites_un, Ps, Jss), append(Jss, Js),
    setup_call_cleanup(open(Sortie, write, S, [encoding(utf8)]),
        forall(member(J, Js), ( json_write_dict(S, J, [width(0)]), nl(S) )), close(S)),
    length(Js, Nj), format(user_error, "~d sites~n", [Nj]).

sites_un(N-L-R, Js) :-
    catch(sites(N, L, R, Js), E, ( print_message(error, E), Js = [] )), !.
sites_un(_, []).

sites(N, L, R, Js) :-
    libelles_lus:partie(N, L, R, Tp, Net, _, Ph), !,
    b_setval(definitions_langue, L), nb_setval(definitions_langue, L),
    ( definitions:type_libelle(N, Ty) -> true ; Ty = inconnu ),
    requetes_iconclass:graphe(N, L, Net, Ph, Fs),
    ( requetes_iconclass:graphe_requete(Fs, [], all, Cb, _) -> true ; Cb = [] ),
    findall(J, ( operation(Op, L, Ph, Fs, Cb, Avant, Apres),
                 format(string(Sa), "~q", [Avant]), format(string(Sb), "~q", [Apres]),
                 ( Op == composes_syntaxiques, member(propriete(X, _), Apres), member(type(Y, H), Cb), Y == X -> true ; H = '' ),
                 atom_string(N, Ns), J = _{n: Ns, l: L, r: R, partie: Tp, type: Ty, libelle: Net, op: Op, avant: Sa, apres: Sb,
                                           tete: H} ), Js).

operation(Op, L, Ph, Fs, Cb, Avant, Apres) :-
    member(Op-G, [participes-participes(L, Ph, Fs, Cb, C2), sujets_partages-sujets_partages(Ph, Fs, Cb, C2),
                  actions-actions(L, Ph, Fs, Cb, C2), composes_syntaxiques-composes_syntaxiques(L, Ph, Fs, Cb, C2),
                  complements_non_lus-complements_non_lus(L, Ph, Fs, Cb, C2), matieres-matieres(L, Cb, C2)]),
    catch(requetes_iconclass:G, _, fail), C2 \== Cb,
    subtract(Cb, C2, Avant), subtract(C2, Cb, Apres).
operation(enumeration, _, Ph, _, _, Ph2, Segs) :-
    catch(requetes_iconclass:enumeration(Ph, Ss), _, fail),
    findall(T, ( member(S, Ss), findall(F, ( member(M, S), arg(2, M, F) ), Fs), atomic_list_concat(Fs, ' ', T) ), Segs),
    Ph2 = segments.
