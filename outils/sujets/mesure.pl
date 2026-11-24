/*  Mesure de l'inventaire des sujets (docs/PLAN_F3.md, étape 1) :
        swipl outils/sujets/mesure.pl BASE SORTIE.json
    couverture, par langue, sur les éléments propres à la notation (libellé propre, attributs, mots clés ; ni les
    parties de gabarit ni les noms hérités, que partagent toutes les sœurs) : part des notations qui en ont au moins
    deux ; part qui en ont au moins un discriminant (un nom, ou un mot porté par au plus 20 notations) ; tirage de 40
    profils (graine fixe) pour le jugement à l'aveugle.  */
:- initialization(main, main).
:- prolog_load_context(directory, D), atom_concat(D, '/../../oedipamaas/socle', S), asserta(user:file_search_path(socle, S)).
:- use_module(library(json)).
:- use_module(library(random)).
:- use_module(socle(sujets)).

main :-
    current_prolog_flag(argv, [Base, Sortie|_]),
    atom_concat(Base, '/iconclass.qlf', I), load_files(I, []),
    atom_concat(Base, '/sujets_index.pl', F), use_module(F),
    aggregate_all(count, notation_de_sujet(_), NS),
    findall(L-C, ( member(L, [en, fr]), couverture(L, C) ), Cs),
    ( current_prolog_flag(argv, [_, _, G|_]) -> atom_number(G, Graine) ; Graine = 20261124 ), set_random(seed(Graine)),
    findall(N, notation_de_sujet(N), Ns), random_permutation(Ns, P), length(T40, 40), append(T40, _, P),
    maplist(profil_json, T40, Tirage),
    dict_pairs(Couv, _, Cs),
    J = _{notations_de_sujet: NS, couverture: Couv, tirage: Tirage},
    setup_call_cleanup(open(Sortie, write, S, [encoding(utf8)]), json_write_dict(S, J, [width(120)]), close(S)),
    json_write_dict(current_output, Couv, [width(100)]), nl.

couverture(L, _{avec_libelle: NL, deux_elements: N2, part_deux: P2, discriminant: ND, part_discriminant: PD,
                elements_moyens: M}) :-
    findall(N, ( notation_de_sujet(N), iconclass:libelle(N, L, _) ), Ns), length(Ns, NL),
    findall(K, ( member(N, Ns), aggregate_all(count, distinct(G-E, ( sujets_index:profil(N, L, G, E, O), propre(O) )), K) ), Ks),
    include(<(1), Ks, K2), length(K2, N2), P2 is N2 / max(1, NL),
    sum_list(Ks, SK), M is SK / max(1, NL),
    aggregate_all(count, ( member(N, Ns), once(discriminant(N, L)) ), ND), PD is ND / max(1, NL).

propre(O) :- memberchk(O, [propre, attribut, mot_cle]).
discriminant(N, L) :- sujets_index:profil(N, L, nom, _, O), propre(O).
discriminant(N, L) :- sujets_index:profil(N, L, mot, E, O), propre(O), sujets_index:rarete(L, mot, E, R), R =< 20.

profil_json(N, _{notation: N, libelle_en: LE, libelle_fr: LF, mots_cles_en: KE, profil_en: PE, profil_fr: PF}) :-
    ( iconclass:libelle(N, en, LE) -> true ; LE = '' ), ( iconclass:libelle(N, fr, LF) -> true ; LF = '' ),
    findall(K, iconclass:mot_cle(N, en, K), KE),
    maplist(profil_l(N), [en, fr], [PE, PF]).

profil_l(N, L, Ps) :-
    findall(_{genre: G, element: E, origine: O, rarete: R},
            ( sujets_index:profil(N, L, G, E, O), ( sujets_index:rarete(L, G, E, R) -> true ; R = 0 ) ), Ps).
