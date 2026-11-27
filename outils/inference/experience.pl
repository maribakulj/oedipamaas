/*  L'expérience contrôlée des couches d'inférence (27/11) : sur les graphes de référence et les requêtes de
    référence (banc v2), ce qu'apportent séparément la canonisation (C), les connaissances lexicales (L) et le
    raisonnement situationnel (S), et leurs combinaisons ; par le même noyau, les mêmes connaissances K, les mêmes
    budgets. Le noyau n'est pas modifié : chaque couche AJOUTE au graphe des assertions, chacune avec sa provenance
    (couche, famille, ressource, statut, sources), ses qualificatifs (ceux de sa source) et un identifiant « x_… » ;
    les preuves du noyau disent ensuite lesquelles une conclusion cite.
        swipl outils/inference/experience.pl BASE WN MS.pl FAITS.json REQUETES.json CIBLES.json SORTIE.json
    WN : le dossier des fichiers Prolog de WordNet 3.0 (wn_ent.pl, wn_cs.pl, wn_sim.pl, wn_mp.pl, wn_hyp.pl,
    wn_der.pl, wn_at.pl, wn_ppl.pl) ; MS.pl : les liens morphosémantiques (outils/inference/morphosemantique.py) ;
    FAITS.json : les graphes de référence en assertions (outils/graphes/vers_faits.py) ; REQUETES.json : les requêtes
    de référence ; CIBLES.json : les textes à évaluer, [{"k", "genre"}].

    Les couches. Toutes sont dirigées par la requête : une assertion n'est ajoutée que si son mot est un mot de la
    requête (une abduction est dirigée par ce qu'elle explique ; cela borne l'inflation). Les ressources relient des
    SENS (WordNet 3.0 ; le français par l'alignement de WOLF, ses sens étant ceux de WordNet).
      C, canonisation (famille F1, équivalence de forme) :
        c_nominalisation  une entité de tête N, un verbe V de la requête : un lien morphosémantique event ou state entre
                          un sens de V et un sens de N (« death » / die) : un événement V ;
        c_evenement_nom   l'inverse : un événement W, un nom N de la requête, le même lien : une entité N ;
        c_nom_de_role     une entité N, un verbe V : un lien agent, undergoer, instrument, location, vehicle,
                          by_means_of (« singer » / sing) : un événement V dont N a le rôle correspondant ;
        c_role_vers_nom   l'inverse : un événement W dont X a un rôle, un nom N de la requête, le même lien : X est un N
                          (« a man singing » / singer) ;
        c_etat            une entité N reliée par of / de à X, une propriété A de la requête : un lien dérivationnel
                          ou d'attribut entre un sens de N et un sens de A (« baldness » / bald) : la propriété A de X ;
      L, connaissances lexicales :
        l_similaire       une propriété A, une propriété T de la requête : similar_to entre leurs sens (F1, affaiblie) ;
        l_compose         une entité dont la tête composée n'a aucun sens dans K : sa tête (le dernier mot en anglais,
                          le premier en français), si K la connaît (F1, composé endocentrique) ;
        l_nom_partiel     un nom propre qui est une partie d'un alias de la requête (« Judas ») : l'alias
                          (désambiguïsation des noms) ;
      S, raisonnement situationnel :
        s_implication     un événement W, un verbe V de la requête : entailment (F2 : « snore » ⇒ sleep, mêmes rôles)
                          ou cause (F4 : « kill » ⇒ die, le patient de W est le thème de V) entre leurs sens ;
        s_etat_evenement  une propriété A d'une entité X, un verbe V : un lien dérivationnel ou participe entre un sens
                          de A et un sens de V, ou par le nom d'état dérivé de A et le lien morphosémantique de ce nom à V,
                          directement ou après un similar_to (« lifeless » ~ dead → death, l'état de die) :
                          l'événement V dont X est le thème (F4) ;
        s_partie_tout     une entité P, un nom T de la requête : un sens de P est une partie (méronymie, avec
                          l'héritage par l'hyperonymie, trois pas au plus) d'un sens de T : une entité T, dont P est
                          une partie (« foredeck » / ship ; F3).
    Le statut d'une assertion ajoutée : « certain » si le lien vaut pour TOUS les sens du mot source (comme D30) et que
    la relation est une implication (event, state, entailment, cause, dérivation directe d'un état) ; « hypothese »
    sinon (un seul sens, similar_to, nom de rôle, composé, nom partiel, partie-tout).
      D, classification par définition : d_definition, les gloses de WordNet (en bas du fichier).
    Les configurations : base ; chaque couche seule (C, L, S, D) ; C+L+S ; C+L+S+D ; et l'ablation (C+L+S+D moins
    chacune). Pour un texte non établi, les atomes manquants (partiel/2 du noyau) : l'apport d'une couche se lit aussi
    atome par atome.
    Pour chaque texte et configuration : le statut du noyau ; s'il est établi, les assertions ajoutées que ses
    preuves citent, avec leur provenance ; et la conclusion : deductive (aucune hypothèse : ni de sens du noyau, ni
    d'assertion ajoutée hypothétique), sous_hypotheses (et lesquelles), ou non_etablie.  */
:- initialization(main, main).
:- prolog_load_context(directory, D), atom_concat(D, '/../../oedipamaas/socle', S), asserta(user:file_search_path(socle, S)).
:- use_module(socle(oedipamaas)).
:- use_module(library(json)).
:- dynamic compteur/1, k_anglais/1.
:- discontiguous ajout/6.

% chaque couche seule, les trois premières ensemble, les quatre ensemble, et les quatre moins chacune (l'ablation)
configurations([base-[], c-[c], l-[l], s-[s], d-[d], cls-[c, l, s], clsd-[c, l, s, d],
                lsd-[l, s, d], csd-[c, s, d], cld-[c, l, d]]).

main :-
    current_prolog_flag(argv, [Base, Wn, Ms, Faits, Reqs, Cibles, Sortie|_]),
    oedipamaas:charger_base(Base),
    atom_concat(Base, '/ressources.qlf', R), load_files(R, []),
    use_module(socle(codage)), use_module(socle(satisfaction)),
    forall(member(F, [wn_ent, wn_cs, wn_sim, wn_mp, wn_hyp, wn_der, wn_at, wn_ppl, wn_g]),
           ( atomic_list_concat([Wn, '/', F, '.pl'], P), load_files(wn:P, [silent(true)]) )),
    load_files(wn:Ms, [silent(true)]),
    codage:k(en, Ken), retractall(k_anglais(_)), asserta(k_anglais(Ken)),
    maplist(lire, [Faits, Reqs, Cibles], [Fs, Qs, Cs]),
    ( getenv('OEDIPAMAAS_INFERENCES', I0) -> atom_number(I0, Imax) ; Imax = 1000000000 ),
    configurations(Confs),
    findall(J, ( member(C, Cs), evaluer_texte(Imax, Confs, Fs, Qs, C, J) ), Js),
    setup_call_cleanup(open(Sortie, write, S, [encoding(utf8)]), json_write_dict(S, Js, [width(140)]), close(S)),
    length(Js, N), format("~d textes~n", [N]).

lire(F, J) :- setup_call_cleanup(open(F, read, S, [encoding(utf8)]), json_read_dict(S, J), close(S)).

evaluer_texte(Imax, Confs, Fs, Qs, C, _{k: K, genre: G, notation: N, configurations: Rs}) :-
    K = C.k, G = C.genre,
    once(( member(F, Fs), F.k =:= K, F.genre == G )), atom_string(La, F.langue),
    once(( member(Q0, Qs), Q0.k =:= K )), N = Q0.notation,
    term_string(Q, Q0.suffisante), Q = requete(_, Formule),
    maplist(fait, F.faits, G0), codage:k(La, Kn),
    findall(Nom-V, ( member(Nom-Couches, Confs), configuration(Imax, Kn, La, G0, Q, Formule, Couches, V) ), Ps),
    dict_pairs(Rs, r, Ps).

fait(["texte", T], texte(T)) :- !.
fait([F|As], T) :- atom_string(Fa, F), maplist(arg_json, As, Bs), T =.. [Fa|Bs].
arg_json(X, X) :- number(X), !.
arg_json(X, A) :- string(X), !, atom_string(A, X).
arg_json(["cite", X], cite(A)) :- !, atom_string(A, X).
arg_json(L, As) :- is_list(L), !, maplist(arg_json, L, As).

% --- une configuration ---------------------------------------------------------------------------------------------

configuration(Imax, K, La, G0, Q, F, Couches, _{statut: St, conclusion: Co, citees: Cj, ajoutees: Na,
                                              par_regle: Pr, hypotheses_de_sens: Hj, manquants: Mj}) :-
    retractall(compteur(_)), asserta(compteur(0)),
    mots_requete(F, Mots),
    findall(A, ( member(C, Couches), ajout(C, K, La, G0, Mots, A) ), As0),
    sort(As0, As),
    findall(X, ( member(ajout(Fs, _), As), member(X, Fs) ), Nouveaux),
    append(G0, Nouveaux, G),
    length(As, Na),
    findall(Rg, member(ajout(_, prov(Rg, _, _, _, _)), As), Rgs0), msort(Rgs0, Rgs), compter(Rgs, Pr),
    catch(call_with_inference_limit(satisfaction:satisfaire(K, G, Q, Res), Imax, I), E,
          ( print_message(error, E), I = erreur )),
    (   I == inference_limit_exceeded -> St = interrompu, Els = []
    ;   I == erreur -> St = erreur, Els = []
    ;   Res = resultat(St, Els, _)
    ),
    (   memberchk(St, [etablie, etablie_sous_hypotheses])
    ->  ids_cites(Els, Ids),
        findall(P, ( member(ajout(Fs, P), As), cite_un(Fs, Ids) ), Ps0), sort(Ps0, Ps),
        maplist(prov_json, Ps, Cj),
        findall(H, ( member(preuve(_, _, _, _, _, Hs), Els), member(H0, Hs), format(string(H), "~q", [H0]) ), Hj0),
        sort(Hj0, Hj),
        (   St == etablie, \+ member(prov(_, _, _, hypothese, _), Ps) -> Co = deductive
        ;   Co = sous_hypotheses
        )
    ;   Cj = [], Hj = [], Co = non_etablie
    ),
    ( memberchk(partiel(_, Manq), Els) -> findall(Ms, ( member(_-A, Manq), format(string(Ms), "~q", [A]) ), Mj) ; Mj = [] ).

compter([], _{}).
compter([X|Xs], D) :- compter(Xs, D0), ( get_dict(X, D0, N) -> N1 is N + 1 ; N1 = 1 ), put_dict(X, D0, N1, D).

ids_cites(Els, Ids) :-
    findall(X, ( member(preuve(_, _, _, S, Js, _), Els), member(T, [S, Js]), sous_terme(X, T), atom(X),
                 sub_atom(X, 0, 2, _, 'x_') ), Ids0),
    sort(Ids0, Ids).
sous_terme(X, X).
sous_terme(X, T) :- compound(T), arg(_, T, A), sous_terme(X, A).
cite_un(Fs, Ids) :- member(F, Fs), arg(1, F, A), atom(A), ord_memberchk(A, Ids), !.

prov_json(prov(Rg, Fa, Re, St, Src), _{regle: Rg, famille: Fa, ressource: Re, statut: St, source: S}) :-
    format(string(S), "~q", [Src]).

nouvel_id(Prefixe, Id) :-
    retract(compteur(N)), N1 is N + 1, asserta(compteur(N1)), format(atom(Id), "x_~w_~d", [Prefixe, N1]).

% les qualificatifs de la source, recopiés sur l'assertion ajoutée (une source niée donne une assertion niée)
qualifs(G, Src, Id, Qs) :-
    findall(Q, ( member(Q0, G), Q0 =.. [F, Src, V], memberchk(F, [polarite, modalite, portee, enonciateur]),
                 Q =.. [F, Id, V] ), Qs).

% --- les mots de la requête --------------------------------------------------------------------------------------

mots_requete(F, Mots) :- findall(M, mot(F, M), Ms0), sort(Ms0, Mots).
mot(type(_, W), n-W).
mot(propriete(_, W), a-W).
mot(evenement(_, W), v-W).
mot(nom(_, Ns), nom-Ns).
mot(et(L), M) :- member(X, L), mot(X, M).
mot(ou(L), M) :- member(X, L), mot(X, M).
mot(non(X), M) :- mot(X, M).

sens(K, C, W, Ss) :- findall(S, ( K:sens(C, W, S), integer(S) ), Ss0), sort(Ss0, Ss).
% le statut d'un lien d'un mot source vers une cible : certain si TOUS ses sens l'ont (supervaluation, D30)
statut_lien(SsSource, Lies, Implication, St) :-
    (   Implication == oui, SsSource \== [], forall(member(S, SsSource), memberchk(S, Lies)) -> St = certain
    ;   St = hypothese
    ).

% --- C : canonisation ------------------------------------------------------------------------------------------------

ajout(c, K, _, G, Mots, ajout([evenement(Id, V, P)|Qs], prov(c_nominalisation, f1, morphosemantique, St, N-V))) :-
    member(entite(E, N, P), G), N \== nom_propre, member(v-V, Mots),
    sens(K, n, N, Sn), sens(K, v, V, Sv), Sn \== [], Sv \== [],
    findall(X, ( member(X, Sn), member(Y, Sv), member(R, [event, state]), wn:ms(R, Y, X) ), L0), sort(L0, L), L \== [],
    statut_lien(Sn, L, oui, St), nouvel_id(c, Id), qualifs(G, E, Id, Qs).
ajout(c, K, _, G, Mots, ajout([entite(Id, N, P)|Qs], prov(c_evenement_nom, f1, morphosemantique, St, W-N))) :-
    member(evenement(Ev, W, P), G), member(n-N, Mots),
    sens(K, v, W, Sv), sens(K, n, N, Sn), Sn \== [], Sv \== [],
    findall(Y, ( member(X, Sn), member(Y, Sv), member(R, [event, state]), wn:ms(R, Y, X) ), L0), sort(L0, L), L \== [],
    statut_lien(Sv, L, oui, St), nouvel_id(c, Id), qualifs(G, Ev, Id, Qs).
ajout(c, K, _, G, Mots, ajout([evenement(Id, V, P), role(Id, Role, E)|Qs],
                               prov(c_nom_de_role, f1, morphosemantique, hypothese, N-V-Role))) :-
    member(entite(E, N, P), G), N \== nom_propre, member(v-V, Mots),
    sens(K, n, N, Sn), sens(K, v, V, Sv), Sn \== [], Sv \== [],
    role_morpho(R, Role), once(( member(X, Sn), member(Y, Sv), wn:ms(R, Y, X) )),
    nouvel_id(c, Id), qualifs(G, E, Id, Qs).
ajout(c, K, _, G, Mots, ajout([propriete(Id, X, A, P)|Qs], prov(c_etat, f1, wordnet_der_at, St, N-A))) :-
    member(entite(E, N, P), G), N \== nom_propre, member(relation(_, E, R, X, _), G), memberchk(R, [of, de]),
    member(a-A, Mots), sens(K, n, N, Sn), sens(K, a, A, Sa), Sn \== [], Sa \== [],
    findall(S, ( member(S, Sn), member(T, Sa), ( wn:der(S, _, T, _) ; wn:der(T, _, S, _) ; wn:at(S, T) ) ), L0),
    sort(L0, L), L \== [], statut_lien(Sn, L, oui, St), nouvel_id(c, Id), qualifs(G, E, Id, Qs).

ajout(c, K, _, G, Mots, ajout([entite(Id, N, P), coref(Id, X)|Qs],
                               prov(c_role_vers_nom, f1, morphosemantique, hypothese, W-Role-N))) :-
    member(evenement(Ev, W, P), G), member(role(Ev, Role, X), G), member(n-N, Mots),
    sens(K, v, W, Sv), sens(K, n, N, Sn), Sn \== [], Sv \== [],
    role_morpho(R, Role), once(( member(Y, Sv), member(Z, Sn), wn:ms(R, Y, Z) )),
    nouvel_id(c, Id), qualifs(G, X, Id, Qs).

ajout(c, K, _, G, Mots, ajout([entite(Id, N, P), relation(Ir, Id, R, X, P)|Qs], prov(c_etat_inverse, f1, wordnet_der_at, St, A-N))) :-
    member(propriete(Q, X, A, P), G), member(n-N, Mots), sens(K, a, A, Sa), sens(K, n, N, Sn), Sn \== [], Sa \== [],
    findall(S, ( member(S, Sa), member(T, Sn), ( wn:der(S, _, T, _) ; wn:der(T, _, S, _) ; wn:at(T, S) ) ), L0),
    sort(L0, L), L \== [], statut_lien(Sa, L, oui, St),
    ( K = connaissances_fr -> R = de ; R = of ),
    nouvel_id(c, Id), nouvel_id(c, Ir), qualifs(G, Q, Id, Q1), qualifs(G, Q, Ir, Q2), append(Q1, Q2, Qs).

role_morpho(agent, agent). role_morpho(undergoer, patient). role_morpho(instrument, instrument).
role_morpho(location, lieu). role_morpho(vehicle, instrument). role_morpho(by_means_of, instrument).

% --- L : connaissances lexicales -------------------------------------------------------------------------------------

ajout(l, K, _, G, Mots, ajout([propriete(Id, E, T, P)|Qs], prov(l_similaire, f1, wordnet_similar_to, hypothese, A-T))) :-
    member(propriete(Q, E, A, P), G), member(a-T, Mots), A \== T,
    sens(K, a, A, Sa), sens(K, a, T, St), Sa \== [], St \== [],
    once(( member(X, Sa), member(Y, St), similaires(X, Y) )),
    nouvel_id(l, Id), qualifs(G, Q, Id, Qs).
ajout(l, K, La, G, Mots, ajout([entite(Id, H, P), coref(Id, E)|Qs], prov(l_compose, f1, tete_du_compose, hypothese, N-H))) :-
    member(entite(E, N, P), G), N \== nom_propre, sub_atom(N, _, _, _, ' '), sens(K, n, N, []),
    atomic_list_concat(Ws, ' ', N), ( La == en -> last(Ws, H) ; Ws = [H|_] ),
    member(n-H, Mots), sens(K, n, H, Sh), Sh \== [],
    nouvel_id(l, Id), qualifs(G, E, Id, Qs).
ajout(l, _, _, G, Mots, ajout([nom(Id, E, Al, P)|Qs], prov(l_nom_partiel, desambiguisation, alias_de_la_requete, hypothese, Nm-Al))) :-
    member(nom(Ni, E, Nm, P), G), member(nom-Als, Mots), member(Al, Als),
    downcase_atom(Nm, Nm1), downcase_atom(Al, Al1), Nm1 \== Al1,
    atomic_list_concat(Tn, ' ', Nm1), atomic_list_concat(Ta, ' ', Al1),
    append(_, Suite, Ta), append(Tn, _, Suite),
    nouvel_id(l, Id), qualifs(G, Ni, Id, Qs).

similaires(X, Y) :- wn:sim(X, Y), !.
similaires(X, Y) :- wn:sim(Y, X), !.
similaires(X, Y) :- wn:sim(X, Z), wn:sim(Y, Z), !.        % deux satellites d'un même adjectif tête

% --- S : raisonnement situationnel -------------------------------------------------------------------------------

ajout(s, K, _, G, Mots, ajout([evenement(Id, V, P)|Rs], prov(s_implication, Fa, Re, St, W-V))) :-
    member(evenement(Ev, W, P), G), member(v-V, Mots), W \== V,
    sens(K, v, W, Sw), sens(K, v, V, Sv), Sw \== [], Sv \== [],
    member(Rel-Fa-Re, [ent-f2-wordnet_entailment, cs-f4-wordnet_cause]),
    findall(X, ( member(X, Sw), member(Y, Sv), Rel == ent, wn:ent(X, Y)
               ; member(X, Sw), member(Y, Sv), Rel == cs, wn:cs(X, Y) ), L0), sort(L0, L), L \== [],
    statut_lien(Sw, L, oui, St), nouvel_id(s, Id), qualifs(G, Ev, Id, Qs),
    findall(role(Id, R2, X2), ( member(role(Ev, R1, X2), G), roles_impliques(Rel, R1, R2) ), Rr),
    append(Rr, Qs, Rs).
ajout(s, K, _, G, Mots, ajout([evenement(Id, V, P), role(Id, theme, E)|Qs], prov(s_etat_evenement, f4, Re, St, A-V))) :-
    member(propriete(Q, E, A, P), G), member(v-V, Mots),
    sens(K, a, A, Sa), sens(K, v, V, Sv), Sa \== [], Sv \== [],
    (   findall(X, ( member(X, Sa), member(Y, Sv), etat_de(X, Y) ), L0),
        sort(L0, L), L \== [] -> statut_lien(Sa, L, oui, St), Re = wordnet_der_ppl_morphosemantique
    ;   once(( member(X, Sa), similaires(X, Z), member(Y, Sv), etat_de(Z, Y) )),
        St = hypothese, Re = wordnet_similar_to_der
    ),
    nouvel_id(s, Id), qualifs(G, Q, Id, Qs).
ajout(s, K, _, G, Mots, ajout([entite(Id, T, P), relation(Ir, E, of, Id, P)|Qs], prov(s_partie_tout, f3, wordnet_meronymie, hypothese, N-T))) :-
    member(entite(E, N, P), G), N \== nom_propre, member(n-T, Mots), N \== T,
    sens(K, n, N, Sn), sens(K, n, T, St), Sn \== [], St \== [],
    once(( member(X, Sn), member(Y, St), partie_de(X, Y, 3) )),
    nouvel_id(s, Id), nouvel_id(s, Ir), qualifs(G, E, Id, Q1), qualifs(G, E, Ir, Q2), append(Q1, Q2, Qs).

% l'adjectif X dit l'état d'un événement Y : dérivation ou participe directs, ou par le nom d'état ou d'événement
% dérivé de X (« dead » → death, l'état de die)
etat_de(X, Y) :- ( wn:der(X, _, Y, _) ; wn:der(Y, _, X, _) ; wn:ppl(X, _, Y, _) ), !.
etat_de(X, Y) :- wn:der(X, _, N, _), N >= 100000000, N < 200000000, member(R, [state, event, result]), wn:ms(R, Y, N), !.

roles_impliques(ent, R, R).
roles_impliques(cs, R1, theme) :- memberchk(R1, [patient, theme]).

% X est une partie de Y : méronymie (partie, membre, substance non comprises : partie seulement), et l'héritage par
% l'hyperonymie du tout (une partie d'un pont de navire est une partie du navire), N pas au plus
partie_de(X, Y, _) :- wn:mp(X, Y), !.
partie_de(X, Y, N) :- N > 1, N1 is N - 1, wn:mp(X, Z), ( wn:hyp(Z, Y) ; partie_de(Z, Y, N1) ; wn:hyp(Z, W), partie_de(W, Y, N1) ), !.

% --- D : classification par définition (les gloses de WordNet 3.0) ----------------------------------------------------
% Un nom T de la requête ; pour chacun de ses sens, sa glose (wn_g.pl). Les mots pleins de la glose sont pris en
% anglais (K anglais) : le premier nom est le genre, les autres mots pleins la différence. Une entité E du graphe est
% classée T si un sens de sa tête est le genre ou l'un de ses hyponymes (sous/2 de K), et si assez de mots de la
% différence (le tiers, un au moins) ont un sens commun avec un mot du voisinage de E : ses propriétés, les têtes des
% entités qu'une relation relie à E ou qui lui sont coréférentes, les prédicats des événements où E a un rôle, et les
% têtes des autres participants de ces événements. La comparaison se fait par les sens : un texte français est comparé
% à une glose anglaise par l'alignement de WOLF. Toujours une hypothèse : une glose n'est pas une définition
% nécessaire et suffisante, et l'appariement est partiel. Aucun mot n'est propre à une notation ou à l'iconographie.

vides([the, a, an, of, and, or, to, in, on, with, by, for, that, which, who, whom, whose, usually, especially,
       often, used, from, as, at, is, are, be, been, its, it, any, some, various, one, other, something, someone,
       very, more, most, such, into, than, this, these, those, has, have, having, not, no, etc, e, g, i,
       can, could, may, might, must, shall, should, will, would, do, does, did]).

ajout(d, K, _, G, Mots, ajout([entite(Id, T, P), coref(Id, E)|Qs], prov(d_definition, f1, wordnet_gloses, hypothese, T-S-Vus))) :-
    k_anglais(Ken), member(n-T, Mots), sens(K, n, T, St), St \== [],
    member(S, St), wn:g(S, Glose), mots_de_glose(Ken, Glose, [Genre|Diff]),
    member(entite(E, H, P), G), H \== nom_propre, H \== T, sens(K, n, H, Sh), Sh \== [],
    sens(Ken, n, Genre, Sg), once(( member(X, Sh), member(Y, Sg), sous_ou_egal(K, X, Y, 6) )),
    voisinage(K, G, E, Sv),
    findall(W, ( member(W, Diff), sens_tous(Ken, W, Sw), member(Z, Sw), memberchk(Z, Sv) ), Vus0), sort(Vus0, Vus),
    length(Diff, Nd), length(Vus, Nv), Nv >= max(1, Nd // 3),
    nouvel_id(d, Id), qualifs(G, E, Id, Qs).

mots_de_glose(Ken, Glose, [Genre|Diff]) :-
    ( sub_atom(Glose, B, _, _, ';') -> sub_atom(Glose, 0, B, _, G1) ; G1 = Glose ),
    downcase_atom(G1, G2), split_string(G2, " ,()'\".:-", " ,()'\".:-", Ts0),
    vides(Vs), findall(A, ( member(T0, Ts0), T0 \== "", atom_string(A0, T0), \+ memberchk(A0, Vs), lemme_anglais(Ken, A0, A) ), Ts),
    once(( append(_, [Genre|Reste], Ts), sens(Ken, n, Genre, [_|_]) )),
    findall(W, ( member(W, Reste), W \== Genre ), Diff0), sort(Diff0, Diff).

lemme_anglais(Ken, A, A) :- once(( member(C, [n, v, a]), sens(Ken, C, A, [_|_]) )), !.
lemme_anglais(Ken, A, L) :- member(Suf-Rep, [s-'', es-'', ies-y, ed-'', ing-'', d-'']), atom_concat(R0, Suf, A),
    atom_concat(R0, Rep, L), L \== '', once(( member(C, [n, v, a]), sens(Ken, C, L, [_|_]) )), !.

sens_tous(K, W, Ss) :- findall(S, ( member(C, [n, v, a]), K:sens(C, W, S), integer(S) ), Ss0), sort(Ss0, Ss).

sous_ou_egal(_, X, X, _) :- !.
sous_ou_egal(K, X, Y, N) :- N > 0, K:sous(X, Z), N1 is N - 1, sous_ou_egal(K, Z, Y, N1), !.

% les sens du voisinage de E (et de ses hyperonymes proches, deux pas : « lion » touche « animal ») ; seules les
% assertions admissibles comptent (affirmées, non niées, de l'image) : un indice nié ou modalisé n'en est pas un
voisinage(K, G, E, Sv) :-
    findall(W-C, ( mot_voisin(G, E, W, C, Ids), forall(member(I, Ids), admissible(G, I)) ), Ws),
    findall(S, ( member(W-C, Ws), K:sens(C, W, S0), integer(S0), sous_ou_egal_liste(K, S0, 2, S) ), Sv0), sort(Sv0, Sv).
sous_ou_egal_liste(_, S, _, S).
sous_ou_egal_liste(K, S, N, T) :- N > 0, K:sous(S, U), N1 is N - 1, sous_ou_egal_liste(K, U, N1, T).
mot_voisin(G, E, W, a, [I]) :- member(propriete(I, E, W, _), G).
mot_voisin(G, E, W, n, [I, Y]) :- member(relation(I, E, _, Y, _), G), member(entite(Y, W, _), G).
mot_voisin(G, E, W, n, [I, Y]) :- member(relation(I, Y, _, E, _), G), member(entite(Y, W, _), G).
mot_voisin(G, E, W, n, [Y]) :- ( member(coref(E, Y), G) ; member(coref(Y, E), G) ), member(entite(Y, W, _), G).
mot_voisin(G, E, W, v, [V]) :- member(role(V, _, E), G), member(evenement(V, W, _), G).
mot_voisin(G, E, W, n, [V, Y]) :- member(role(V, _, E), G), member(role(V, _, Y), G), Y \== E, member(entite(Y, W, _), G).
mot_voisin(G, E, W, a, [I]) :- ( member(coref(E, Y), G) ; member(coref(Y, E), G) ), member(propriete(I, Y, W, _), G).

admissible(G, I) :- \+ member(polarite(I, neg), G), \+ ( member(modalite(I, M), G), M \== affirme ),
    \+ ( member(portee(I, P), G), \+ memberchk(P, [represente, oeuvre]) ), \+ ( member(enonciateur(I, X), G), X \== auteur ).
