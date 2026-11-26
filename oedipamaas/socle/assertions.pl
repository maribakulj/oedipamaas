/*  Le langage d'assertions, version 1 (cahier des charges, § 5 ; docs/ASSERTIONS.md).

    Les assertions d'un document sont une liste de termes passée en argument (jamais de faits dynamiques partagés).
    valider(+Faits, -Erreurs) : la liste des erreurs, vide si la liste est valide.
    assertion(+Faits, ?A)     : A est un identifiant d'assertion (entité, événement, nom, propriété, relation).
    admissible(+Faits, ?A)    : A peut fonder un code établi (affirmée, positive, sur ce que l'image représente, par
                                l'auteur, hors de toute alternative ; et les entités qu'elle concerne aussi).
    contredit(+Faits, ?A)     : A est niée, sur ce que l'image représente.
*/
:- module(assertions, [ valider/2,      % +Faits, -Erreurs
                        assertion/2,    % +Faits, ?A
                        admissible/2,   % +Faits, ?A
                        contredit/2     % +Faits, ?A
                      ]).
:- encoding(utf8).

% --- Domaines -------------------------------------------------------------------------------------------------------

langue(fr).
langue(en).
genre(titre).
genre(cartel).
genre(notice).
genre(description).
genre(savant).
genre(inconnu).
role_permis(agent).
role_permis(patient).
role_permis(theme).
role_permis(instrument).
role_permis(destinataire).
role_permis(lieu).

qualificatif(polarite, [pos, neg]).
qualificatif(modalite, [affirme, probable, possible, traditionnel, ancien, non_affirme, titre]).
qualificatif(portee, [represente, oeuvre, autre_oeuvre, source, histoire, non_ancre]).
qualificatif(enonciateur, [auteur, cite(_)]).

% --- Identifiants ---------------------------------------------------------------------------------------------------

assertion(Fs, A) :- member(F, Fs), id_assertion(F, A).

id_assertion(entite(E, _, _), E).
id_assertion(evenement(V, _, _), V).
id_assertion(nom(A, _, _, _), A).
id_assertion(propriete(A, _, _, _), A).
id_assertion(relation(A, _, _, _, _), A).

entites_de(Fs, A, Es) :-
    (   memberchk(nom(A, E, _, _), Fs) -> Es = [E]
    ;   memberchk(propriete(A, E, _, _), Fs) -> Es = [E]
    ;   memberchk(relation(A, E1, _, E2, _), Fs) -> Es = [E1, E2]
    ;   memberchk(evenement(A, _, _), Fs) -> findall(E, member(role(A, _, E), Fs), Es)
    ;   Es = []
    ).

% --- Admissibilité --------------------------------------------------------------------------------------------------

admissible(Fs, A) :-
    assertion(Fs, A),
    qualifiee_admissible(Fs, A),
    entites_de(Fs, A, Es),
    forall(member(E, Es), qualifiee_admissible(Fs, E)).

qualifiee_admissible(Fs, A) :-
    memberchk(polarite(A, pos), Fs),
    memberchk(modalite(A, affirme), Fs),
    memberchk(portee(A, represente), Fs),
    memberchk(enonciateur(A, auteur), Fs),
    \+ ( member(alternative(_, As), Fs), memberchk(A, As) ).

contredit(Fs, A) :-
    assertion(Fs, A),
    memberchk(polarite(A, neg), Fs),
    memberchk(portee(A, represente), Fs).

% --- Validation -----------------------------------------------------------------------------------------------------

valider(Fs, Erreurs) :-
    (   \+ acyclic_term(Fs) -> Erreurs = [cyclique]
    ;   is_list(Fs)
    ->  findall(E, erreur(Fs, E), Es0),
        sort(Es0, Erreurs)
    ;   Erreurs = [pas_une_liste]
    ).

erreur(Fs, inconnu(F)) :- member(F, Fs), \+ terme_connu(F).
erreur(Fs, non_clos(F)) :- member(F, Fs), \+ ground(F).               % une variable libre unifierait avec tout
erreur(Fs, mot(F)) :-                                                    % un mot, un nom propre : un atome
    member(F, Fs), ground(F), mot_de(F, W), \+ atom(W).
erreur(Fs, identifiant(I)) :-
    member(F, Fs), ( id_assertion(F, I) ; F = passage(I, _, _) ; F = alternative(I, _) ), \+ atom(I).
erreur(Fs, texte(nombre(N))) :- aggregate_all(count, member(texte(_), Fs), N), N =\= 1.
erreur(Fs, texte(pas_une_chaine)) :- member(texte(T), Fs), \+ string(T).
erreur(Fs, doc(nombre(N))) :- aggregate_all(count, member(doc(_, _), Fs), N), N =\= 1.
erreur(Fs, doc(langue(L))) :- member(doc(L, _), Fs), \+ langue(L).
erreur(Fs, doc(genre(G))) :- member(doc(_, G), Fs), \+ genre(G).
erreur(Fs, passage(P, hors_bornes)) :-
    member(passage(P, D, F), Fs),
    (   memberchk(texte(T), Fs), string(T) -> string_length(T, L) ; L = 0 ),
    \+ ( integer(D), integer(F), D >= 0, D < F, F =< L ).
erreur(Fs, identifiant_double(I)) :-
    findall(I0, ( member(F, Fs), ( id_assertion(F, I0) ; F = passage(I0, _, _) ; F = alternative(I0, _) ) ), Is),
    msort(Is, Tries), append(_, [I, I|_], Tries).
erreur(Fs, passage_inconnu(F)) :-
    member(F, Fs), passage_de(F, P), \+ memberchk(passage(P, _, _), Fs).
erreur(Fs, entite_inconnue(F)) :-
    member(F, Fs), entite_citee(F, E), \+ memberchk(entite(E, _, _), Fs).
erreur(Fs, evenement_inconnu(F)) :-
    member(F, Fs), F = role(V, _, _), \+ memberchk(evenement(V, _, _), Fs).
erreur(Fs, role(R)) :- member(role(_, R, _), Fs), \+ role_permis(R).
erreur(Fs, nombre(E, N)) :- member(nombre(E, N), Fs), \+ ( integer(N), N >= 1 ).
erreur(Fs, qualificatif(Q, A, nombre(N))) :-
    assertion(Fs, A), qualificatif(Q, _),
    aggregate_all(count, ( member(F, Fs), F =.. [Q, A0, _], A0 == A ), N), N =\= 1.
erreur(Fs, qualificatif(Q, A, valeur(V))) :-
    qualificatif(Q, Permis), member(F, Fs), F =.. [Q, A, V], \+ memberchk(V, Permis).
erreur(Fs, qualificatif(Q, A, assertion_inconnue)) :-
    qualificatif(Q, _), member(F, Fs), F =.. [Q, A, _], \+ assertion(Fs, A).
erreur(Fs, alternative(G, moins_de_deux)) :- member(alternative(G, As), Fs), \+ ( is_list(As), length(As, L), L >= 2 ).
erreur(Fs, alternative(G, assertion_inconnue(A))) :-
    member(alternative(G, As), Fs), is_list(As), member(A, As), \+ assertion(Fs, A).

terme_connu(texte(_)).
terme_connu(doc(_, _)).
terme_connu(passage(_, _, _)).
terme_connu(entite(_, _, _)).
terme_connu(nom(_, _, _, _)).
terme_connu(propriete(_, _, _, _)).
terme_connu(nombre(_, _)).
terme_connu(evenement(_, _, _)).
terme_connu(role(_, _, _)).
terme_connu(relation(_, _, _, _, _)).
terme_connu(polarite(_, _)).
terme_connu(modalite(_, _)).
terme_connu(portee(_, _)).
terme_connu(enonciateur(_, _)).
terme_connu(alternative(_, _)).
terme_connu(coref(_, _)).
terme_connu(distinct(_, _)).
terme_connu(incompris(_, _)).
terme_connu(saillance(_, principal)).

passage_de(entite(_, _, P), P).
passage_de(nom(_, _, _, P), P).
passage_de(propriete(_, _, _, P), P).
passage_de(evenement(_, _, P), P).
passage_de(relation(_, _, _, _, P), P).
passage_de(incompris(P, _), P).

entite_citee(nom(_, E, _, _), E).
entite_citee(propriete(_, E, _, _), E).
entite_citee(nombre(E, _), E).
entite_citee(saillance(E, _), E).
entite_citee(role(_, _, E), E).
entite_citee(relation(_, E, _, _, _), E).
entite_citee(relation(_, _, _, E, _), E).
entite_citee(coref(E, _), E).
entite_citee(coref(_, E), E).
entite_citee(distinct(E, _), E).
entite_citee(distinct(_, E), E).

mot_de(entite(_, W, _), W). mot_de(nom(_, _, W, _), W). mot_de(propriete(_, _, W, _), W).
mot_de(evenement(_, W, _), W). mot_de(relation(_, _, W, _, _), W).
