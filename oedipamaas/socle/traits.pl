/*  Traits de preuve des candidats (conception 1.0, § 9), pour la décision apprise. Que des quantités tirées de la
    preuve, jamais de trait de corpus (ni chapitre, ni fréquence dans un catalogue).

    candidats_traits(+Budget, -Liste) : la liste [Notation, Provisoire, Traits] des candidats d'une description :
    les Budget premiers par BM25 et les Budget premiers par part décrite, leurs spécialisations, leurs clés, et les
    ancêtres de tous (un ancêtre n'a souvent pas d'appui propre : il est candidat parce qu'un descendant l'est).
    Provisoire : la part décrite (dans [0, 1]), pour le témoin. Traits (paires Nom-Valeur, valeurs nulles omises) :
        bm25_direct, bm25_wordnet, inv_rang_bm25, inv_rang_part, part, nb_propres, prof,
        specialisee, cle, ancetre_seul, nb_mentions, nb_unites,
        src_mot_cle, src_libelle, src_attribut, src_renvoi, wn_synonyme, wn_hyperonyme, wn_derive, wn_autre,
        champ_<champ> (nombre de mentions directes par champ de la description),
        nom, lettre_doublee, enfants_candidats, parent_candidat
*/
:- module(traits, [ candidats_traits/2 ]).

:- use_module(recherche).
:- use_module(specialisation).
:- use_module(cles).
:- use_module(arbre).

:- dynamic rang_bm25/2, bm25/3, rang_part/2, spec/1, cle_prop/1, cand/1.

% appui(N, M, Forme, Lien, Source) : les appuis lexicaux, préparés une fois par description par la recherche
appui(N, M, F, L, S) :- recherche:candidat(N, M, p(M, F, L, S)).

contexte(Budget) :-
    maplist(retractall, [rang_bm25(_, _), bm25(_, _, _), rang_part(_, _), spec(_), cle_prop(_), cand(_)]),
    recherche:classement(1000000, L),
    forall(nth1(R, L, c(N, cle(D, W), _)), ( assertz(rang_bm25(N, R)), assertz(bm25(N, D, W)) )),
    specialisation:decrire,
    findall(P-D-N, ( bm25(N, D, _), ( specialisation:part_decrite(N, P0) -> P = P0 ; P = 0 ) ), T0),
    msort(T0, T1), reverse(T1, T2),
    forall(nth1(R, T2, _-_-N), assertz(rang_part(N, R))),
    premiers(rang_bm25, Budget, B1), premiers(rang_part, Budget, B2),
    specialisation:specialisees(B1, Sp),
    forall(member(N, Sp), assertz(spec(N))),
    append([B1, B2, Sp], S0), sort(S0, Soutenues),
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
trait(N, part, P) :- ( specialisation:part_decrite(N, P) -> true ; P = 0 ).
trait(N, nb_propres, K) :- ( propres_index:nb_propres(N, K) -> true ; K = 0 ).
trait(N, prof, P) :- ( catch(notation:profondeur(N, P), _, fail) -> true ; P = 0 ).
trait(N, specialisee, V) :- ( spec(N) -> V = 1 ; V = 0 ).
trait(N, cle, V) :- ( cle_prop(N) -> V = 1 ; V = 0 ).
trait(N, ancetre_seul, V) :- ( \+ bm25(N, _, _), \+ cle_prop(N), \+ spec(N) -> V = 1 ; V = 0 ).
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
