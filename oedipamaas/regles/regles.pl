% Règles du moteur (v2) : elles MESURENT, elles ne filtrent pas. Chaque règle rend un trait (nom, valeur, mentions)
% pour une notation ; la décision (retenir ou non) est apprise ailleurs, à partir de ces traits. Aucun seuil écrit.
% Seules contraintes : celles qu'impose la structure d'Iconclass (un code à nom propre affirme une identité).
% Charger après base.pl. Faits d'image (posés par Python, retirés entre deux images) :
%   m(K, Champ)                        mention K et son champ
%   cand(N, K, Source, S, Rang, Q, D)  candidat N pour la mention K ; Source = lex | sem | mot | tete | nom | ref ;
%                                      S = similarité (cosinus, BM25 normalisé, ou rareté du mot exact), Q et D =
%                                      couvertures (part pondérée par la rareté des mots de la mention, du libellé)
%   nom_ctx(N, K, Ctx)                 contexte d'un nom trouvé : honorifique (« saint… » avant), reference (suivi
%                                      d'un nombre), personne (dans persons.who)
%   attr_vu(N, A, Idf, K)              attribut A (Iconclass, « possible attributes ») du saint N vu dans la mention K
%   part_vu(N, P, K), part_total(N, T) participants du libellé narratif N vus (hors champs du sujet) ; leur nombre
%   anc_vu(N, Prof, K)                 un mot clé ou la tête d'un ancêtre de N (profondeur Prof) est la mention K
% Structure de l'image (option du moteur) :
%   ent(E, Aire, Centre, Plan)         entité située E : aire de sa boîte / la plus grande de l'image, proximité du
%                                      centre (1 au centre, 0 au coin), plan (premier, milieu, fond)
%   appui_ent(N, E, K)                 la mention K, qui décrit l'entité E, propose N
%   rel_vu(N, I, A, R, B, Ks)          relation I (sujet, prédicat, objet) : A, B = 1 si l'entité sujet, objet appuie N ;
%                                      R = 1 si le prédicat est dans le libellé de N ; Ks = mentions des deux bouts
% Sortie : traits(L), L = [[N, Trait, Valeur, Mentions], ...] ; codes bloqués exclus.

:- dynamic m/2, cand/7, nom_ctx/3, attr_vu/4, part_vu/3, part_total/2, anc_vu/3, ent/4, appui_ent/3, rel_vu/6.
:- discontiguous trait/4.

champ_sujet('subject.title').
champ_sujet('subject.alternatives').

% D'où vient une mention : le sujet, l'ensemble de la description, ou un autre champ.
origine(C, sujet) :- champ_sujet(C), !.
origine(description, globale) :- !.
origine(_, autre).

sous_propre(N, N) :- ic_propre(N), !.
sous_propre(N, P) :- ic_ancetre(N, P), ic_propre(P), !.

recit(N) :- sub_atom(N, 0, 1, _, C), memberchk(C, ['7', '8', '9']), !.
recit(N) :- sous_propre(N, P), P \== N.

% --- Recherche : similarités et couvertures, séparées selon que la mention vient du sujet ou non -------------------
trait(N, T, S, [K]) :-
    cand(N, K, Src, S, _, _, _), memberchk(Src, [lex, sem]), m(K, C), origine(C, Ou),
    atomic_list_concat([Src, '_', Ou], T).
trait(N, T, D, [K]) :-
    cand(N, K, Src, _, _, _, D), memberchk(Src, [lex, sem]), m(K, C), origine(C, Ou),
    atomic_list_concat([dcov_, Ou], T).
trait(N, T, Q, [K]) :-
    cand(N, K, Src, _, _, Q, _), memberchk(Src, [lex, sem]), m(K, C), origine(C, Ou),
    atomic_list_concat([qcov_, Ou], T).
trait(N, T, W, [K]) :-                                  % expression égale à un mot clé ou à la tête du libellé
    cand(N, K, Src, W, _, _, _), memberchk(Src, [mot, tete]), m(K, C), origine(C, Ou),
    atomic_list_concat(['exact_', Src, '_', Ou], T).

% --- Noms propres -----------------------------------------------------------------------------------------------------
trait(N, nom, S, [K]) :- cand(N, K, nom, S, _, _, _).
trait(N, T, 1.0, [K]) :- nom_ctx(N, K, Ctx), atom_concat(nom_, Ctx, T).

% --- Attributs des saints (Iconclass) ---------------------------------------------------------------------------------
trait(N, attributs_idf, Somme, Ks) :-
    setof(A-I, K^attr_vu(N, A, I, K), AI), findall(I, member(_-I, AI), Is), sum_list(Is, Somme),
    setof(K, A^I^attr_vu(N, A, I, K), Ks).
trait(N, attributs_nb, Nb, Ks) :-
    setof(A, I^K^attr_vu(N, A, I, K), As), length(As, Nb), setof(K, A^I^attr_vu(N, A, I, K), Ks).
trait(N, attributs_part, P, Ks) :-                      % part des attributs possibles du saint qui sont vus
    setof(A, I^K^attr_vu(N, A, I, K), As), length(As, Nb),
    aggregate_all(count, ic_attr(N, _, _), Tot), Tot > 0, P is Nb / Tot,
    setof(K, A^I^attr_vu(N, A, I, K), Ks).

% --- Source et participants d'un récit (Iconclass) --------------------------------------------------------------------
trait(N, source_exacte, 1.0, [K]) :- cand(N, K, ref, _, _, _, _).
trait(N, source_ancetre, 1.0, [K]) :-                   % la source désigne une histoire dont N est un épisode
    candidat(N), \+ cand(N, _, ref, _, _, _, _),
    once(( cand(A, K, ref, _, _, _, _), ic_ancetre(N, A) )).
trait(N, participants_part, P, Ks) :-
    part_total(N, T), T > 0,
    setof(K, Pa^part_vu(N, Pa, K), Ks), setof(Pa, K^part_vu(N, Pa, K), Pas), length(Pas, Vus),
    P is Vus / T.
trait(N, recit_sans_sujet, 1.0, []) :-                  % récit proposé par aucun champ du sujet
    candidat(N), recit(N), \+ ( cand(N, K, _, _, _, _, _), m(K, C), champ_sujet(C) ).

% --- Ancêtres : la description dit-elle ce que disent les ancêtres de N ? -------------------------------------------
trait(N, ancetres_vus, Nb, Ks) :-
    candidat(N), setof(P, K^anc_vu(N, P, K), Ps), length(Ps, Nb), setof(K, P^anc_vu(N, P, K), Ks).
trait(N, ancetre_vu_prof_max, Max, []) :-
    candidat(N), setof(P, K^anc_vu(N, P, K), Ps), max_list(Ps, Max).

% --- Un épisode de la vie d'un saint (11H(X)n) affirme aussi le saint : il porte les traits d'identité de X ----------
trait(N, T2, V, Ks) :-
    candidat(N), sous_propre(N, P), P \== N,
    member(T, [nom, attributs_idf, attributs_nb, attributs_part]), trait(P, T, V, Ks),
    atom_concat(T, '_du_saint', T2).

% --- Structure de l'image : l'entité qui appuie le code, sa place, les relations qui le portent ----------------------
trait(N, saillance_aire, A, [K]) :- appui_ent(N, E, K), ent(E, A, _, _).
trait(N, saillance_centre, C, [K]) :- appui_ent(N, E, K), ent(E, _, C, _).
trait(N, T, 1.0, [K]) :- appui_ent(N, E, K), ent(E, _, _, P), P \== '', atom_concat(plan_, P, T).
trait(N, entites_appui, Nb, Ks) :-
    candidat(N), setof(E, K^appui_ent(N, E, K), Es), length(Es, Nb), setof(K, E^appui_ent(N, E, K), Ks).
trait(N, relation_bouts, V, Ks) :- rel_vu(N, _, A, _, B, Ks), V is A + B.
trait(N, relation_predicat, 1.0, Ks) :- rel_vu(N, _, _, 1, _, Ks).
trait(N, relation_complete, 1.0, Ks) :- rel_vu(N, _, 1, 1, 1, Ks).
trait(N, relations_nb, Nb, []) :-
    candidat(N), aggregate_all(count, rel_vu(N, _, _, _, _, _), Nb), Nb > 0.

candidat(N) :- cand(N, _, _, _, _, _, _).
candidat(N) :- attr_vu(N, _, _, _).

% --- Contraintes structurelles : un code à nom propre (ou sa sous-rubrique) affirme une identité ; il lui faut un
% nom vu ou des attributs vus. ------------------------------------------------------------------------------------------
identite_vue(P) :- once(( cand(P, _, nom, _, _, _, _) ; attr_vu(P, _, _, _) )).
bloque(N) :- sous_propre(N, P), \+ identite_vue(P).

traits(L) :-
    findall([N, T, V, Ks], ( trait(N, T, V, Ks), \+ bloque(N) ), L0),
    sort(L0, L).

vider :-
    retractall(m(_, _)), retractall(cand(_, _, _, _, _, _, _)), retractall(nom_ctx(_, _, _)),
    retractall(attr_vu(_, _, _, _)), retractall(part_vu(_, _, _)), retractall(part_total(_, _)),
    retractall(anc_vu(_, _, _)), retractall(ent(_, _, _, _)), retractall(appui_ent(_, _, _)),
    retractall(rel_vu(_, _, _, _, _, _)).
