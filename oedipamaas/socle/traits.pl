/*  Traits de preuve des candidats (conception 1.0, § 9), pour la décision apprise. Que des quantités tirées de la
    preuve, jamais de trait de corpus (ni chapitre, ni fréquence dans un catalogue).

    candidats_traits(+Budget, -Liste) : la liste [Notation, Provisoire, Traits] des candidats d'une description :
    les Budget premiers par BM25, par part décrite et par BM25 du sujet, les spécialisations des premiers, les
    explications par unité (sans budget : les notations les plus précises qu'une unité décrit entièrement, mot pour
    mot ou par le pont WordNet), les clés de tous ceux-là, et les ancêtres de tous (un ancêtre n'a souvent pas
    d'appui propre : il est candidat parce qu'un descendant l'est).
    Provisoire : la part décrite (dans [0, 1]), pour le témoin. Traits (paires Nom-Valeur, valeurs nulles omises) :
        bm25_direct, bm25_wordnet, inv_rang_bm25, inv_rang_part, bm25_sujet, inv_rang_sujet, inv_rang_min, part,
        nb_propres, prof, specialisee, cle, ancetre_seul, explication, unites_pleines, explication_pont,
        unites_pleines_pont, plein_<champ> (unités pleines par champ), part_unites, concurrents,
        ecart_profondeur_plus_un, nb_mentions, nb_unites,
        src_mot_cle, src_libelle, src_attribut, src_renvoi, wn_synonyme, wn_hyperonyme, wn_derive, wn_autre,
        champ_<champ> (nombre de mentions directes par champ de la description),
        nom, lettre_doublee, enfants_candidats, parent_candidat
*/
:- module(traits, [ candidats_traits/2 ]).

:- use_module(recherche).
:- use_module(specialisation).
:- use_module(cles).
:- use_module(arbre).

:- dynamic rang_bm25/2, bm25/3, rang_part/2, rang_sujet/2, bm25_sujet/2, spec/1, cle_prop/1, cand/1, expl/1,
           expl_pont/1, unite_expl/2, nb_unites_desc/1.

% les unités où N est pleine (mot pour mot ou par le pont WordNet), une fois par notation et par description
:- table unites_pleines_de/2.
unites_pleines_de(N, Us) :- findall(U, specialisation:pleine_large_dans(N, U), Us0), sort(Us0, Us).

% le champ d'une unité : « entities[3] » → entities, « subject.alternatives[1] » → subject, « period_style » tel quel
champ_de_unite(U, C) :-
    atom_codes(U, Cs),
    (   append(Avant, [X|_], Cs), memberchk(X, `[.`) -> atom_codes(C, Avant) ; C = U ).

% appui(N, M, Forme, Lien, Source) : les appuis lexicaux, préparés une fois par description par la recherche
appui(N, M, F, L, S) :- recherche:candidat(N, M, p(M, F, L, S)).

contexte(Budget) :-
    maplist(retractall, [rang_bm25(_, _), bm25(_, _, _), rang_part(_, _), rang_sujet(_, _), bm25_sujet(_, _), spec(_),
                         cle_prop(_), cand(_), expl(_), expl_pont(_), unite_expl(_, _), nb_unites_desc(_)]),
    recherche:classement(1000000, L),
    forall(nth1(R, L, c(N, cle(D, W), _)), ( assertz(rang_bm25(N, R)), assertz(bm25(N, D, W)) )),
    % troisième ordre : BM25 sur les seules mentions du sujet (titre, source, alternatives)
    recherche:classement_champs([subject], 1000000, LS),
    forall(nth1(R, LS, c(N, cle(D, _), _)), ( assertz(rang_sujet(N, R)), assertz(bm25_sujet(N, D)) )),
    specialisation:decrire,
    findall(P-D-N, ( bm25(N, D, _), ( specialisation:part_decrite(N, P0) -> P = P0 ; P = 0 ) ), T0),
    msort(T0, T1), reverse(T1, T2),
    forall(nth1(R, T2, _-_-N), assertz(rang_part(N, R))),
    premiers(rang_bm25, Budget, B1), premiers(rang_part, Budget, B2), premiers(rang_sujet, Budget, B3),
    specialisation:specialisees(B1, Sp),
    forall(member(N, Sp), assertz(spec(N))),
    % explications par unité : sans budget, toutes les notations les plus précises qu'une unité décrit entièrement
    findall(N, bm25(N, _, _), Lexicaux),
    specialisation:explications(Lexicaux, Ex),
    forall(member(N, Ex), assertz(expl(N))),
    % et de même par le pont WordNet (chaque mot tel quel ou par un lien admis par la recherche)
    specialisation:explications_pont(Lexicaux, ExP),
    forall(member(N, ExP), assertz(expl_pont(N))),
    % la structure de la description : les unités où chaque explication est pleine, le nombre d'unités décrites
    append(Ex, ExP, Expl0), sort(Expl0, Expl),
    forall(( member(N, Expl), unites_pleines_de(N, Us), member(U, Us) ), assertz(unite_expl(U, N))),
    aggregate_all(count, distinct(U, ( description:mention(M, _, _, _), specialisation:unite(M, U) )), NU),
    assertz(nb_unites_desc(NU)),
    append([B1, B2, B3, Sp, Ex, ExP], S0), sort(S0, Soutenues),
    forall(( member(N, Soutenues), cles:cles_decrites(N, Cs), member(C, Cs) ), assertz(cle_prop(C))),
    findall(C, cle_prop(C), Cl),
    append(Soutenues, Cl, Base0), sort(Base0, Base),
    findall(A, ( member(N, Base), arbre:ancetre(N, A) ), As),
    append(Base, As, Tous0), sort(Tous0, Tous),
    forall(member(N, Tous), assertz(cand(N))).

premiers(Rang, K, Ns) :-
    findall(N, ( call(Rang, N, R), R =< K ), Ns0), sort(Ns0, Ns).

candidats_traits(Budget, Liste) :-
    contexte(Budget),
    findall([N, Prov, Traits], ( cand(N), provisoire(N, Prov), traits_de(N, Traits) ), Liste).

provisoire(N, P) :- ( specialisation:part_decrite(N, P0) -> P = P0 ; P = 0.0 ).

traits_de(N, Traits) :-
    findall(K-V, ( trait(N, K, V), V =\= 0 ), Traits).

trait(N, bm25_direct, D) :- ( bm25(N, D, _) -> true ; D = 0 ).
trait(N, bm25_wordnet, W) :- ( bm25(N, _, W) -> true ; W = 0 ).
trait(N, inv_rang_bm25, V) :- ( rang_bm25(N, R) -> V is 1 / R ; V = 0 ).
trait(N, inv_rang_part, V) :- ( rang_part(N, R) -> V is 1 / R ; V = 0 ).
trait(N, bm25_sujet, V) :- ( bm25_sujet(N, V0) -> V = V0 ; V = 0 ).
trait(N, inv_rang_sujet, V) :- ( rang_sujet(N, R) -> V is 1 / R ; V = 0 ).
% le meilleur rang dans l'un des trois ordres (BM25, part décrite, BM25 du sujet) : un candidat placé haut par l'un
% d'eux ; sert aussi à choisir les candidats donnés à la décision
trait(N, inv_rang_min, V) :-
    (   aggregate_all(min(R), ( rang_bm25(N, R) ; rang_part(N, R) ; rang_sujet(N, R) ), Rm), Rm \== inf
    ->  V is 1 / Rm
    ;   V = 0
    ).
trait(N, part, P) :- ( specialisation:part_decrite(N, P) -> true ; P = 0 ).
trait(N, nb_propres, K) :- ( propres_index:nb_propres(N, K) -> true ; K = 0 ).
trait(N, prof, P) :- ( catch(notation:profondeur(N, P), _, fail) -> true ; P = 0 ).
trait(N, specialisee, V) :- ( spec(N) -> V = 1 ; V = 0 ).
trait(N, cle, V) :- ( cle_prop(N) -> V = 1 ; V = 0 ).
trait(N, ancetre_seul, V) :- ( \+ bm25(N, _, _), \+ cle_prop(N), \+ spec(N), \+ rang_sujet(N, _) -> V = 1 ; V = 0 ).
% explication par unité : la notation est la plus précise de celles qu'une unité décrit entièrement ; le nombre
% d'unités qui la décrivent entièrement (« river » dit par l'entité, le décor et un mot-clé)
trait(N, explication, V) :- ( expl(N) -> V = 1 ; V = 0 ).
trait(N, unites_pleines, C) :- aggregate_all(count, specialisation:pleine_dans(N, _), C).
% de même par le pont WordNet (une unité pleine telle quelle l'est aussi par le pont)
trait(N, explication_pont, V) :- ( expl_pont(N) -> V = 1 ; V = 0 ).
trait(N, unites_pleines_pont, C) :- unites_pleines_de(N, Us), length(Us, C).
% la structure de la description : dans quels champs N est pleine (le sujet, une personne, une entité, un mot-clé…) ;
% la part des unités de la description qu'elle explique ; ses concurrentes, les autres explications (hors de sa
% lignée) pleines dans l'une de ses unités ; l'écart à la plus profonde explication de son unité la plus favorable,
% plus un (1 : elle est la plus précise ; 0 : aucune unité pleine)
trait(N, K, C) :-
    member(Champ, [subject, persons, entities, relations, actions, gestures_emotions, concepts, roles, setting,
                   texts, genre_function, period_style, keywords]),
    atom_concat(plein_, Champ, K),
    unites_pleines_de(N, Us),
    aggregate_all(count, ( member(U, Us), champ_de_unite(U, Champ) ), C).
trait(N, part_unites, V) :-
    (   unites_pleines_de(N, Us), length(Us, K), nb_unites_desc(NU), NU > 0 -> V is K / NU ; V = 0 ).
trait(N, concurrents, C) :-
    unites_pleines_de(N, Us),
    aggregate_all(count, distinct(M, ( member(U, Us), unite_expl(U, M), M \== N,
                                       \+ arbre:ancetre(M, N), \+ arbre:ancetre(N, M) )), C).
trait(N, ecart_profondeur_plus_un, V) :-
    (   unites_pleines_de(N, Us), Us \== [], catch(notation:profondeur(N, P), _, fail),
        findall(E, ( member(U, Us),
                     findall(Q, ( unite_expl(U, M), catch(notation:profondeur(M, Q), _, fail) ), Qs), Qs \== [],
                     max_list(Qs, Qm), E is max(0, Qm - P) ), Es),
        Es \== []
    ->  min_list(Es, Em), V is Em + 1
    ;   V = 0
    ).
trait(N, nb_mentions, C) :- aggregate_all(count, distinct(M, recherche:candidat(N, M, p(_, _, egal, _))), C).
trait(N, nb_unites, C) :-
    aggregate_all(count, distinct(U, ( recherche:candidat(N, M, p(_, _, egal, _)), specialisation:unite(M, U) )), C).
trait(N, K, C) :-
    member(K-Motif, [src_mot_cle-mot_cle(_), src_libelle-mot_libelle, src_attribut-attribut, src_renvoi-renvoi(_)]),
    aggregate_all(count, distinct(F, recherche:candidat(N, _, p(_, F, egal, Motif))), C).
trait(N, K, C) :-
    member(K-R, [wn_synonyme-synonyme, wn_hyperonyme-hyperonyme, wn_derive-derive]),
    aggregate_all(count, distinct(F, recherche:candidat(N, _, p(_, F, wordnet(R, _, _), _))), C).
trait(N, wn_autre, C) :-
    aggregate_all(count, distinct(F, ( recherche:candidat(N, _, p(_, F, wordnet(R, _, _), _)),
                                       \+ memberchk(R, [synonyme, hyperonyme, derive]) )), C).
trait(N, K, C) :-
    member(Champ, [subject, persons, entities, relations, actions, gestures_emotions, concepts, roles, setting,
                   texts, genre_function, period_style, keywords]),
    atom_concat(champ_, Champ, K),
    aggregate_all(count, distinct(M, ( recherche:candidat(N, M, p(_, _, egal, _)),
                                       description:mention(M, Champ, _, _) )), C).
trait(N, nom, V) :-
    (   catch(notation:analyser(N, Ns), _, fail), Ns \= composee(_), ( memberchk(nom(_), Ns) ; memberchk(gabarit, Ns) )
    ->  V = 1 ; V = 0 ).
trait(N, lettre_doublee, V) :-
    ( catch(notation:analyser(N, Ns), _, fail), Ns \= composee(_), memberchk(double(_), Ns) -> V = 1 ; V = 0 ).
trait(N, enfants_candidats, C) :- aggregate_all(count, ( iconclass:enfant(N, E, _), cand(E) ), C).
trait(N, parent_candidat, V) :- ( arbre:parent(N, P), bm25(P, _, _) -> V = 1 ; V = 0 ).
