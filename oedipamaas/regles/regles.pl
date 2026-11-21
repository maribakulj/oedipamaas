% Règles du moteur : faits d'une image et correspondances (posés par Python) → appuis des notations.
% Charger après base.pl. Faits d'image (module courant, retirés entre deux images) :
%   m(K, Champ)                        mention K et son champ
%   cand(N, K, Source, S, Rang, Q, D)  candidat N pour la mention K ; Source = lex | mot | tete | nom | ref
%   attr_vu(N, A, Idf, K)              attribut A du saint N vu dans la mention K (Idf = rareté)
%   part_vu(N, P, K)                   participant P du récit N vu dans la mention K (hors champs du sujet)
%   part_total(N, T)                   nombre de participants attendus du récit N
%   halo(K), dit_saint(K)              auréole vue ; personne nommée « saint … »
%   sujet_type(T)                      type de sujet donné par le descripteur
% Sortie : appui(N, Regle, Mentions, Poids) ; bloque(N, Raison).

:- dynamic m/2, cand/7, attr_vu/4, part_vu/3, part_total/2, halo/1, dit_saint/1, sujet_type/1.
:- discontiguous appui/4.

champ_sujet('subject.title').
champ_sujet('subject.alternatives').

saint(N) :- sub_atom(N, 0, _, _, '11H(').
saint(N) :- sub_atom(N, 0, _, _, '11HH(').

recit(N) :- sub_atom(N, 0, 1, _, C), memberchk(C, ['7', '8', '9']).
recit(N) :- sous_propre(N, P), P \== N.

sous_propre(N, N) :- ic_propre(N), !.
sous_propre(N, P) :- ic_ancetre(N, P), ic_propre(P), !.

% --- A ancrage : une mention hors sujet, ancrée sur un libellé ou un mot clé --------------------------------------
appui(N, 'A.tete', [K], P) :- cand(N, K, tete, S, _, _, _), m(K, C), \+ champ_sujet(C), P is 1.5 * S.
appui(N, 'A.mot', [K], S) :- cand(N, K, mot, S, _, _, _), m(K, C), \+ champ_sujet(C).
appui(N, 'A.libelle', [K], P) :-
    cand(N, K, lex, _, _, Q, D), m(K, C), \+ champ_sujet(C),
    once(( D >= 0.5 ; Q >= 1.0, D >= 0.34 )),
    P is 0.6 * D + 0.4 * Q.

% A.sens : voisin sémantique d'une mention hors sujet (cosinus S ; au-dessous de 0,6, rien).
appui(N, 'A.sens', [K], P) :-
    cand(N, K, sem, S, _, _, _), S >= 0.6, m(K, C), \+ champ_sujet(C),
    P is 2.0 * (S - 0.5).

% --- B nom : un code à nom propre, nommé et appuyé par au moins un autre fait --------------------------------------
appui(N, 'B.nom', [K], P) :-
    cand(N, K, nom, S, _, _, _), once(soutien_nom(N, K, _)),
    P is 2.0 * S.
soutien_nom(N, _, K2) :- attr_vu(N, _, I, K2), I >= 2.0.   % un attribut assez rare (« book » ne désigne personne)
soutien_nom(N, _, K2) :- saint(N), ( halo(K2) ; dit_saint(K2) ).
soutien_nom(N, _, K2) :- saint(N), sujet_type(saint), m(K2, 'subject.type').
soutien_nom(N, K, K2) :- part_vu(N, P, K2), K2 \== K, \+ ic_nom(P, N).   % un participant autre que le nom lui-même
nomme(N) :- appui(N, 'B.nom', _, _), !.
un_saint_nomme :- cand(S, _, nom, _, _, _, _), saint(S), nomme(S), !.

% --- C attributs du saint ---------------------------------------------------------------------------------------------
attributs_vus(N, Ks, Somme, Nb) :-
    setof(A-I, K^attr_vu(N, A, I, K), AI), length(AI, Nb),
    findall(I, member(_-I, AI), Is), sum_list(Is, Somme),
    setof(K, A^I^attr_vu(N, A, I, K), Ks).
appui(N, 'C.attributs', Ks, P) :-
    attributs_vus(N, Ks, Somme, _), saint(N), nomme(N),
    P is min(2.0, Somme / 5).
appui(N, 'C.sans_nom', Ks, P) :-
    \+ un_saint_nomme,
    attributs_vus(N, Ks, Somme, Nb), saint(N), \+ nomme(N), Nb >= 2, Somme >= 6,
    once(( halo(_) ; dit_saint(_) ; sujet_type(saint) )),
    P is min(2.5, Somme / 4).

% --- D épisode : source, titre, participants --------------------------------------------------------------------------
appui(N, 'D.source', [K], 1.5) :- cand(N, K, ref, _, _, _, _).
% La source désigne l'histoire ; un épisode de cette histoire, appuyé par le titre, en profite.
appui(N, 'D.source', [K], 1.2) :-
    titre(N), \+ cand(N, _, ref, _, _, _, _),
    once(( cand(A, K, ref, _, _, _, _), ic_ancetre(N, A) )).
titre(N) :-
    cand(N, K, _, _, _, _, _), m(K, C), champ_sujet(C),
    once(( appui(N, 'D.titre', _, _) ; appui(N, 'D.sens', _, _) )).
% Le titre appuie un récit (D.titre) ; sur un code non narratif (paysage, chasse…), c'est un appui de sujet (S.titre).
appui(N, R, [K], P) :-
    cand(N, K, lex, S, _, Q, D), m(K, C), champ_sujet(C),
    once(( D >= 0.34 ; Q >= 0.5 )),
    ( C == 'subject.title' -> F = 2.0 ; F = 1.0 ),
    P is F * S * (0.5 + 0.5 * D),
    ( recit(N) -> R = 'D.titre' ; R = 'S.titre' ).
appui(N, R, [K], 2.0) :-
    cand(N, K, Src, _, _, _, _), memberchk(Src, [mot, tete]), m(K, 'subject.title'),
    ( recit(N) -> R = 'D.titre' ; R = 'S.titre' ).
% Le titre rapproché par le sens (cosinus S ≥ 0,55) : D.sens pour un récit, S.sens sinon.
appui(N, R, [K], P) :-
    cand(N, K, sem, S, _, _, _), S >= 0.55, m(K, C), champ_sujet(C),
    ( C == 'subject.title' -> F = 2.0 ; F = 1.0 ),
    P is F * 2.0 * (S - 0.45),
    ( recit(N) -> R = 'D.sens' ; R = 'S.sens' ).
appui(N, 'D.participants', Ks, P) :-
    part_total(N, T), T > 0, recit(N),
    setof(K, Pa^part_vu(N, Pa, K), Ks),
    setof(Pa, K^part_vu(N, Pa, K), Pas), length(Pas, Vus),
    once(( appui(N, 'D.titre', _, _) ; appui(N, 'D.sens', _, _) ; appui(N, 'D.source', _, _) )),
    P is 1.5 * Vus / T.

% --- Blocages (J, et codes non appuyés) -----------------------------------------------------------------------------------
bloque(N, nom_sans_appui) :- ic_propre(N), \+ nomme(N), \+ appui(N, 'C.sans_nom', _, _).
bloque(N, ancetre_non_nomme) :-
    sous_propre(N, P), P \== N, \+ nomme(P), \+ appui(P, 'C.sans_nom', _, _).
bloque('49L8', sans_texte_transcrit) :- \+ m(_, texts).

% Tous les appuis non bloqués d'une image : liste de [N, Regle, Mentions, Poids], triée.
appuis(L) :-
    findall([N, R, Ks, P], ( appui(N, R, Ks, P), \+ bloque(N, _) ), L0),
    sort(L0, L).

vider :-
    retractall(m(_, _)), retractall(cand(_, _, _, _, _, _, _)), retractall(attr_vu(_, _, _, _)),
    retractall(part_vu(_, _, _)), retractall(part_total(_, _)), retractall(halo(_)), retractall(dit_saint(_)),
    retractall(sujet_type(_)).
