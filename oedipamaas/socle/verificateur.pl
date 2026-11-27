/*  Le vérificateur des preuves (docs/NOYAU.md, version 0.3, § 6). Écrit à part du moteur (satisfaction.pl) et du
    moteur de référence, dont il ne réutilise aucun prédicat : il ne partage que la spécification, le graphe, le contrat
    des assertions (assertions.pl) et les primitives de K.

    verifier(+K, +Graphe, +Requete, +Preuve, -Verdict)
        Verdict = accepte | rejete(Raisons)
    Il n'accepte qu'après avoir établi positivement chacun des points du § 6 ; une preuve dont la forme n'est pas
    celle du § 5 est rejetée avant tout examen.
*/
:- module(verificateur, [ verifier/5 ]).
:- encoding(utf8).
:- use_module(library(lists)).
:- use_module(library(apply)).
:- use_module(assertions, [valider/2]).

% la version du noyau pour laquelle ce vérificateur est écrit
version_attendue('noyau 0.3').

verifier(K, G, Q, P, Verdict) :-
    (   \+ acyclic_term(Q-P)                            -> Verdict = rejete([terme_cyclique])
    ;   \+ assertions:valider(G, [])                    -> Verdict = rejete([graphe_invalide])
    ;   \+ forme_requete(Q)                             -> Verdict = rejete([requete_mal_formee])
    ;   \+ forme_preuve(P)                              -> Verdict = rejete([preuve_mal_formee])
    ;   findall(R, ( controle(Nom, K, G, Q, P), \+ catch(etabli(Nom, K, G, Q, P), E, echec_ou_ressource(E)), R = Nom ), Rs),
        ( Rs == [] -> Verdict = accepte ; Verdict = rejete(Rs) )
    ).

% une erreur dans un contrôle est un contrôle non établi (une raison de rejet) ; une exception de ressource (un budget
% d'inférences, une limite de temps, la mémoire, un abandon) n'est pas un verdict sur la preuve : elle est relancée
% (contrôle du lot 1 : un budget épuisé pendant la vérification rendait « rejete_par_le_verificateur » une preuve que
% le mode sans limite acceptait)
echec_ou_ressource(E) :- ressource(E), !, throw(E).
echec_ou_ressource(_) :- fail.
ressource(time_limit_exceeded).
ressource(time_limit_exceeded(_)).
ressource(inference_limit_exceeded).
ressource('$aborted').
ressource(unwind(_)).
ressource(error(resource_error(_), _)).

controle(N, _, _, _, _) :- member(N, [requete, versions, regime, chemins, selection, sigma, appuis, contraintes,
                                       hypotheses, pas_d_appui_negatif]).

% --- La forme (§ 5) --------------------------------------------------------------------------------------------------

forme_requete(requete(Id, F)) :-
    atom(Id), formule(F),
    \+ ( sous_formule(F, Co), contrainte(Co), vars(Co, Vc), member(V, Vc), evenementielle(F, V) ).  % D35
formule(et(Fs)) :- !, is_list(Fs), Fs \== [], maplist(formule, Fs).
formule(ou(Fs)) :- !, is_list(Fs), Fs = [_, _|_], maplist(formule, Fs).
formule(F) :- ground(F), ( atome(F) ; contrainte(F) ).
type_valide(T) :- ( atom(T) ; integer(T) ), !.
atome(type(v(X), T)) :- atom(X), type_valide(T).
atome(nom(v(X), Ks)) :- atom(X), is_list(Ks), Ks \== [], maplist(atom, Ks).
atome(propriete(v(X), P)) :- atom(X), type_valide(P).
atome(evenement(v(X), P)) :- atom(X), type_valide(P).
atome(role(v(X), R, v(Y))) :- atom(X), atom(R), atom(Y).
atome(relation(v(X), R, v(Y))) :- atom(X), type_valide(R), atom(Y).
atome(genre(T)) :- type_valide(T).
contrainte(meme(v(X), v(Y))) :- atom(X), atom(Y).
contrainte(distincts(v(X), v(Y))) :- atom(X), atom(Y).
contrainte(nombre(v(X), N)) :- atom(X), integer(N), N >= 1.

forme_preuve(P) :-
    ground(P), P = preuve(Id, Vs, Rg, S, Js, Hs), atom(Id),
    is_list(Vs), atom(Rg), is_list(S), is_list(Js), Js \== [], is_list(Hs),
    forall(member(X, S), ( X = v(N)-Val, atom(N), atom(Val) )),
    forall(member(J, Js), ( J = j(C, A, Ap), is_list(C), forall(member(I, C), ( integer(I), I >= 1 )),
                            ( atome(A) ; contrainte(A) ), forme_appui(A, Ap) )),
    forall(member(H, Hs), forme_hypothese(H)).
forme_hypothese(distinction_supposee(v(X), v(Y), N1, N2)) :- atom(X), atom(Y), is_list(N1), is_list(N2).
forme_hypothese(sens_suppose(W, T)) :- atom(W), type_valide(T).
forme_hypothese(negation_autre_sens(A)) :- compound(A).
forme_appui(A, appui(_, E, P, _)) :- atome(A), atom(E), atom(P).
forme_appui(A, contrainte(_)) :- contrainte(A).

% --- Les contrôles, chacun établi positivement (§ 6) -----------------------------------------------------------------

etabli(requete, _, _, requete(Id, _), preuve(Id2, _, _, _, _, _)) :- Id2 == Id.
etabli(versions, K, G, _, preuve(_, Vs, _, _, _, _)) :-
    version_attendue(Vn), K:version(Vk), msort(G, Gs), variant_sha1(Gs, H),
    Vs == [noyau(Vn), connaissances(Vk), graphe(H)].
etabli(regime, _, _, requete(_, F), preuve(_, _, Rg, _, _, _)) :-
    findall(A, ( sous_formule(F, A), atome(A) ), As),
    ( forall(member(A, As), A = genre(_)) -> Rg == classement ; Rg == figuration ).
etabli(chemins, _, _, requete(_, F), preuve(_, _, _, _, Js, _)) :-
    findall(C, member(j(C, _, _), Js), Cs), msort(Cs, Ss), sort(Cs, Ss),        % chaque chemin une fois
    forall(member(j(C, A, _), Js), ( position(F, C, A0), A0 == A )).
etabli(selection, _, _, requete(_, F), preuve(_, _, _, _, Js, _)) :-
    findall(C, member(j(C, _, _), Js), Cs), satisfait(F, [], Cs),
    forall(member(C, Cs), dans_la_selection(F, [], C, Cs)).
etabli(sigma, _, G, requete(_, F), preuve(_, _, _, S, Js, _)) :-
    findall(V, member(V-_, S), Ks), msort(Ks, Ks1), sort(Ks, Ks1),            % chaque variable une fois
    findall(V, ( member(j(_, A, _), Js), atome(A), vars(A, Va), member(V, Va) ), Vs0), sort(Vs0, Vs),
    sort(Ks, Vs),                                                             % exactement celles des atomes
    forall(( member(j(_, A, _), Js), contrainte(A), vars(A, Va), member(V, Va) ), memberchk(V, Vs)),
    forall(member(V-X, S), bonne_sorte(G, F, V, X)).
etabli(appuis, K, G, _, preuve(_, _, _, S, Js, _)) :-
    forall(( member(j(_, A, Ap), Js), atome(A) ), appui_positif(K, G, S, A, Ap)).
etabli(contraintes, K, G, _, preuve(_, _, _, S, Js, Hs)) :-
    forall(( member(j(_, Co, contrainte(J)), Js) ), contrainte_justifiee(K, G, S, Hs, Co, J)).
etabli(hypotheses, K, G, _, preuve(_, _, _, S, Js, Hs)) :-
    findall(X-Y, member(j(_, distincts(X, Y), contrainte(hypothese)), Js), Us0), sort(Us0, Us),
    findall(X-Y, member(distinction_supposee(X, Y, _, _), Hs), Hs1), msort(Hs1, Hs2), sort(Hs1, Hs2), Hs2 == Us,
    % les hypothèses des atomes (D30) : exactement celles que demandent les appuis cités
    findall(H, ( member(j(_, A, Ap), Js), atome(A), hypothese_requise(K, G, S, A, Ap, H) ), Hr1),
    % et celles des contraintes : l'existence seulement possiblement niée d'une entité (audit final, B2)
    findall(H, ( member(j(_, _, contrainte(J)), Js), entites_de_justification(J, Es), member(E, Es),
                 existence_seulement_possible(K, G, E, H) ), Hr2),
    append(Hr1, Hr2, Hr0), sort(Hr0, Hr),
    exclude([H]>>( H = distinction_supposee(_, _, _, _) ), Hs, Ha0), msort(Ha0, Ha), sort(Ha0, Ha), Ha == Hr.
etabli(pas_d_appui_negatif, K, G, _, preuve(_, _, _, S, Js, _)) :-
    \+ ( member(j(_, A, _), Js), atome(A), appui_negatif(K, G, S, A) ),
    % ni contre l'assertion citée, prise avec son propre mot (une lionne niée ne prouve pas un lion)
    \+ ( member(j(_, A, Ap), Js), atome(A), assertion_citee(A, Ap, B), appui_negatif(K, G, S, B) ),
    % ni contre l'existence d'une entité que l'appui cite, ni contre l'événement d'un rôle
    \+ ( member(j(_, A, Ap), Js), atome(A), A \= genre(_), entite_citee(G, Ap, E), inexistante(K, G, E) ),
    forall(( member(j(_, A, Ap), Js), atome(A) ), une_lecture(K, G, S, A, Ap)),
    \+ ( member(j(_, role(_, _, _), appui(role(V, _, _), _, _, _)), Js), member(evenement(V, W, _), G),
         appui_negatif(K, G, [v('$e')-V], evenement(v('$e'), W)) ).
entite_citee(_, appui(_, E, _, _), E).
entite_citee(G, appui(A, _, _, _), E2) :- memberchk(relation(A, _, _, E2, _), G).
% le texte nie que cette entité existe : le type de son mot est nié pour sa classe
inexistante(K, G, E) :-
    member(entite(E, W, _), G), W \== nom_propre, member(entite(R, _, _), G), meme_classe(G, E, R), representant(G, R),
    appui_negatif(K, G, [v('$p')-R], type(v('$p'), W)), !.

hypothese_requise(K, _, _, A, appui(_, _, _, chemin(W, _)), sens_suppose(W, T)) :-
    type_de(A, Cat, T), \+ positif_certain(K, Cat, W, T).
hypothese_requise(K, G, S, A, _, negation_autre_sens(Ai)) :- appui_negatif_possible(K, G, S, A), instancie(A, S, Ai).
hypothese_requise(K, G, S, A, Ap, negation_autre_sens(Bi)) :-
    assertion_citee(A, Ap, B), appui_negatif_possible(K, G, S, B), instancie(B, S, Bi).
hypothese_requise(K, G, _, A, Ap, negation_autre_sens(type(R, W))) :-
    A \= genre(_), entite_citee(G, Ap, E), member(entite(E, W, _), G), W \== nom_propre,
    member(entite(R, _, _), G), meme_classe(G, E, R), representant(G, R),
    appui_negatif_possible(K, G, [v('$p')-R], type(v('$p'), W)).
hypothese_requise(K, G, _, role(_, _, _), appui(role(V, _, _), _, _, _), negation_autre_sens(evenement(V, W))) :-
    member(evenement(V, W, _), G), appui_negatif_possible(K, G, [v('$e')-V], evenement(v('$e'), W)).
entites_de_justification(etablie(distinct(E1, E2)), [E1, E2]).
entites_de_justification(nombre(E), [E]).
existence_seulement_possible(K, G, E, negation_autre_sens(type(R, W))) :-
    member(entite(E, W, _), G), W \== nom_propre, member(entite(R, _, _), G), meme_classe(G, E, R), representant(G, R),
    appui_negatif_possible(K, G, [v('$p')-R], type(v('$p'), W)).
% une lecture au moins du mot de l'appui : un sens conceptuel qui atteint le type, l'assertion en ce sens non niée
% (audit final, B3)
une_lecture(K, G, S, A, Ap) :-
    (   assertion_citee(A, Ap, B), type_de(A, Cat, T), Ap = appui(_, _, _, chemin(W, _))
    ->  sens_du_mot(K, Cat, W, Ss), member(Sn, Ss), sous_atteint(K, [Sn], [Sn], T), au_sens(B, Sn, Bs),
        \+ appui_negatif(K, G, S, Bs), !
    ;   true
    ).
au_sens(type(X, _), Sn, type(X, Sn)). au_sens(propriete(X, _), Sn, propriete(X, Sn)).
au_sens(evenement(X, _), Sn, evenement(X, Sn)). au_sens(relation(X, _, Y), Sn, relation(X, Sn, Y)).
au_sens(genre(_), Sn, genre(Sn)).
type_de(type(_, T), n, T). type_de(genre(T), n, T). type_de(propriete(_, T), a, T). type_de(evenement(_, T), v, T).
type_de(relation(_, T, _), r, T).
instancie(v(N), S, X) :- !, memberchk(v(N)-X, S).
instancie(T, S, Ti) :- compound(T), !, T =.. [F|As], instancie_liste(As, S, Bs), Ti =.. [F|Bs].
instancie(T, _, T).
instancie_liste([], _, []).
instancie_liste([A|As], S, [B|Bs]) :- instancie(A, S, B), instancie_liste(As, S, Bs).

assertion_citee(type(X, _), appui(_, _, _, chemin(W, _)), type(X, W)).
assertion_citee(nom(X, _), appui(_, _, _, cle(C)), nom(X, [C])).
assertion_citee(nom(X, _), appui(_, _, _, alias(C, _)), nom(X, [C])).
assertion_citee(propriete(X, _), appui(_, _, _, chemin(W, _)), propriete(X, W)).
assertion_citee(evenement(X, _), appui(_, _, _, chemin(W, _)), evenement(X, W)).
assertion_citee(relation(X, _, Y), appui(_, _, _, chemin(W, _)), relation(X, W, Y)).
assertion_citee(genre(_), appui(_, _, _, chemin(W, _)), genre(W)).

% --- La formule ------------------------------------------------------------------------------------------------------

sous_formule(F, F).
sous_formule(et(Fs), A) :- member(F, Fs), sous_formule(F, A).
sous_formule(ou(Fs), A) :- member(F, Fs), sous_formule(F, A).

position(F, [], F).
position(et(Fs), [I|Is], A) :- nth1(I, Fs, F), position(F, Is, A).
position(ou(Fs), [I|Is], A) :- nth1(I, Fs, F), position(F, Is, A).

satisfait(et(Fs), C, Cs) :- !, forall(nth1(I, Fs, F), ( append(C, [I], C1), satisfait(F, C1, Cs) )).
satisfait(ou(Fs), C, Cs) :- !, once(( nth1(I, Fs, F), append(C, [I], C1), satisfait(F, C1, Cs) )).
satisfait(_, C, Cs) :- memberchk(C, Cs).

% un chemin justifié n'est pas dans une branche d'un « ou » autre que celle qui est justifiée
dans_la_selection(_, _, [], _) :- !.
dans_la_selection(et(Fs), P, [I|Is], Cs) :- !, nth1(I, Fs, F), append(P, [I], P1), dans_la_selection(F, P1, Is, Cs).
dans_la_selection(ou(Fs), P, [I|Is], Cs) :-
    nth1(I, Fs, F), append(P, [I], P1),
    \+ ( member(C2, Cs), append(P, [J|_], C2), J \== I ),                   % une seule branche du « ou »
    dans_la_selection(F, P1, Is, Cs).

vars(v(N), [v(N)]) :- !.
vars(T, Vs) :- compound(T), !, T =.. [_|As], foldl([A, V0, V]>>( vars(A, Va), append(V0, Va, V) ), As, [], Vs).
vars(_, []).

evenementielle(F, V) :- sous_formule(F, A), ( A = evenement(V0, _) ; A = role(V0, _, _) ), V0 == V, !.
bonne_sorte(G, F, V, X) :-
    (   evenementielle(F, V) -> memberchk(evenement(X, _, _), G)
    ;   memberchk(entite(X, _, _), G), representant(G, X)
    ).

val(S, V, X) :- memberchk(V-X, S).

% --- Le graphe, relu ici ---------------------------------------------------------------------------------------------

meme_classe(G, E, R) :- atteint(G, [E], [E], R).
atteint(_, _, Vus, R) :- memberchk(R, Vus), !.
atteint(G, Front, Vus, R) :-
    findall(Y, ( member(X, Front), ( member(coref(X, Y), G) ; member(coref(Y, X), G) ), \+ memberchk(Y, Vus) ), Ys0),
    sort(Ys0, Ys), Ys \== [], append(Vus, Ys, Vus1), atteint(G, Ys, Vus1, R).
representant(G, R) :- \+ ( member(entite(E, _, _), G), E @< R, meme_classe(G, E, R) ).
membres(G, R, Es) :- findall(E, ( member(entite(E, _, _), G), meme_classe(G, E, R) ), Es0), sort(Es0, Es).

qualifie(G, A, Pol, Ctx, Q) :-
    memberchk(polarite(A, Pol), G), memberchk(modalite(A, affirme), G), memberchk(portee(A, Ctx), G),
    memberchk(enonciateur(A, Q), G), \+ ( member(alternative(_, As), G), memberchk(A, As) ).
present(G, E) :- qualifie(G, E, pos, represente, _).
porteur_admis(G, E) :- qualifie(G, E, pos, represente, auteur).      % un porteur que l'auteur dit présent (§ 1)
sans_autre_dit(G, E) :-
    \+ member(nom(_, E, _, _), G), \+ member(propriete(_, E, _, _), G), \+ member(relation(_, E, _, _, _), G),
    \+ member(relation(_, _, _, E, _), G), \+ member(role(_, _, E), G), \+ member(nombre(E, _), G),
    \+ member(distinct(E, _), G), \+ member(distinct(_, E), G).
cles_equivalentes(_, A, B) :- A == B, !.
cles_equivalentes(K, A, B) :- alias_ferme(K, [A], [A], B).
alias_ferme(_, _, Vus, B) :- memberchk(B, Vus), !.
alias_ferme(K, Front, Vus, B) :-
    findall(Y, ( member(X, Front), ( K:alias(X, Y) ; K:alias(Y, X) ), \+ memberchk(Y, Vus) ), Ys0), sort(Ys0, Ys),
    Ys \== [], append(Vus, Ys, Vus1), alias_ferme(K, Ys, Vus1, B).

% un lien positif : sens puis des pas « sous », chemin simple, jusqu'au type demandé
lien_positif(K, Cat, W, T, chemin(W, [S0|Ch])) :- sens_du_mot(K, Cat, W, Ss), memberchk(S0, Ss), pas_sous(K, [S0|Ch], T).
pas_sous(_, [T0], T) :- T0 == T, !.
pas_sous(K, [S, S1|Ch], T) :- K:sous(S, S1), \+ memberchk(S, [S1|Ch]), pas_sous(K, [S1|Ch], T).

nom_valide(K, Nom, Ks, cle(C)) :- K:cle_de_nom(Nom, C), memberchk(C, Ks).
nom_valide(K, Nom, Ks, alias(C, Ka)) :- K:cle_de_nom(Nom, C), memberchk(Ka, Ks), C \== Ka, cles_equivalentes(K, C, Ka).

% un appui positif cité : il existe, de l'auteur, admissible, conforme à σ, de lien valide
appui_positif(K, G, S, type(X, T), appui(E, E, P, L)) :-
    member(entite(E, W, P), G), W \== nom_propre, val(S, X, R), meme_classe(G, E, R),
    qualifie(G, E, pos, represente, auteur), lien_positif(K, n, W, T, L).
appui_positif(K, G, S, nom(X, Ks), appui(A, E, P, L)) :-
    member(nom(A, E, Nom, P), G), val(S, X, R), meme_classe(G, E, R),
    qualifie(G, A, pos, represente, auteur), porteur_admis(G, E), nom_valide(K, Nom, Ks, L).
appui_positif(K, G, S, propriete(X, Pr), appui(A, E, P, L)) :-
    member(propriete(A, E, W, P), G), val(S, X, R), meme_classe(G, E, R),
    qualifie(G, A, pos, represente, auteur), porteur_admis(G, E), lien_positif(K, a, W, Pr, L).
appui_positif(K, G, S, evenement(X, Pr), appui(V, V, P, L)) :-
    val(S, X, V), member(evenement(V, W, P), G), qualifie(G, V, pos, represente, auteur), lien_positif(K, v, W, Pr, L).
appui_positif(_, G, S, role(X, Ro, Y), appui(role(V, Ro, E), E, P, egal)) :-
    val(S, X, V), val(S, Y, R), member(role(V, Ro, E), G), memberchk(evenement(V, _, P), G), meme_classe(G, E, R),
    qualifie(G, V, pos, represente, auteur), porteur_admis(G, E).
appui_positif(K, G, S, relation(X, Re, Y), appui(A, E1, P, L)) :-
    member(relation(A, E1, W, E2, P), G), val(S, X, R1), val(S, Y, R2), meme_classe(G, E1, R1), meme_classe(G, E2, R2),
    qualifie(G, A, pos, represente, auteur), porteur_admis(G, E1), porteur_admis(G, E2), lien_positif(K, r, W, Re, L).
appui_positif(K, G, _, genre(T), appui(E, E, P, L)) :-
    member(entite(E, W, P), G), W \== nom_propre, qualifie(G, E, pos, oeuvre, auteur), lien_positif(K, n, W, T, L).

% un appui négatif sous σ, de tout énonciateur, cherché dans tout le graphe (lien d'inclusion, dans l'autre sens)
% une entité niée dont rien d'autre n'est dit : contre sa classe si un membre en est présent, contre tout référent sinon
% appui_negatif : une négation certaine (pour chaque sens, D30) ; appui_negatif_possible : seulement pour un sens
appui_negatif(K, G, S, A) :- appui_negatif_m(certain, K, G, S, A).
appui_negatif_possible(K, G, S, A) :- A \= nom(_, _), appui_negatif_m(possible, K, G, S, A).
appui_negatif_m(Mo, K, G, S, type(X, T)) :-
    val(S, X, R), member(entite(E, W, _), G), W \== nom_propre, qualifie(G, E, neg, represente, _),
    sans_autre_dit(G, E), inclus_mode(Mo, K, n, T, W),
    (   member(entite(E2, _, _), G), meme_classe(G, E2, E), present(G, E2) -> meme_classe(G, E, R)
    ;   \+ ( member(entite(E2, _, _), G), E2 \== E, meme_classe(G, E2, E) )
    ).
% une liste de noms : chacun de ses noms nié
appui_negatif_m(certain, K, G, S, nom(X, Ks)) :-
    val(S, X, R),
    forall(member(Ki, Ks), ( member(nom(A, E, Nom, _), G), meme_classe(G, E, R), qualifie(G, A, neg, represente, _),
                              present(G, E), once(nom_valide(K, Nom, [Ki], _)) )).
appui_negatif_m(Mo, K, G, S, propriete(X, Pr)) :-
    val(S, X, R), member(propriete(A, E, W, _), G), meme_classe(G, E, R), qualifie(G, A, neg, represente, _),
    present(G, E), inclus_mode(Mo, K, a, Pr, W).
% un événement nié : contre un autre événement présent qui a chacun de ses rôles, vers les mêmes référents
appui_negatif_m(Mo, K, G, S, evenement(X, Pr)) :-
    val(S, X, V), qualifie(G, V, pos, represente, _),
    member(evenement(N, W, _), G), N \== V, qualifie(G, N, neg, represente, _), inclus_mode(Mo, K, v, Pr, W),
    forall(member(role(N, Ro, E), G), ( present(G, E), member(role(V, Ro, E2), G), meme_classe(G, E2, E) )).
appui_negatif_m(Mo, K, G, S, relation(X, Re, Y)) :-
    val(S, X, R1), val(S, Y, R2), member(relation(A, E1, W, E2, _), G), meme_classe(G, E1, R1), meme_classe(G, E2, R2),
    qualifie(G, A, neg, represente, _), present(G, E1), present(G, E2), inclus_mode(Mo, K, r, Re, W).
appui_negatif_m(Mo, K, G, _, genre(T)) :-
    member(entite(E, W, _), G), W \== nom_propre, qualifie(G, E, neg, oeuvre, _), sans_autre_dit(G, E),
    inclus_mode(Mo, K, n, T, W).

% T est inclus dans W : un sens de T monte par « inclus » jusqu'à un sens de W
% D30 : les sens conceptuels d'un mot (ses identifiants de concepts, s'il en a) ; les nœuds d'un type demandé
sens_du_mot(K, Cat, W, Ss) :-
    findall(S, K:sens(Cat, W, S), Ss0), sort(Ss0, Ss1), include(integer, Ss1, Is), ( Is == [] -> Ss = Ss1 ; Ss = Is ).
noeuds_du_type(_, _, T, [T]) :- integer(T), !.
noeuds_du_type(K, Cat, T, Ns) :- sens_du_mot(K, Cat, T, Ns).
% inclusion certaine : chaque nœud du type dans chaque sens du mot ; possible : un couple, et pas certaine
inclus_lien(K, Cat, T, W) :-
    noeuds_du_type(K, Cat, T, Ns), Ns \== [], sens_du_mot(K, Cat, W, Ws), Ws \== [],
    forall(( member(N, Ns), member(Sw, Ws) ), monte_inclus(K, N, Sw, [N])).
inclus_possible(K, Cat, T, W) :-
    noeuds_du_type(K, Cat, T, Ns), sens_du_mot(K, Cat, W, Ws), member(N, Ns), member(Sw, Ws), monte_inclus(K, N, Sw, [N]), !,
    \+ inclus_lien(K, Cat, T, W).
inclus_mode(certain, K, Cat, T, W) :- inclus_lien(K, Cat, T, W).
inclus_mode(possible, K, Cat, T, W) :- inclus_possible(K, Cat, T, W).
% un lien positif certain : chaque sens du mot atteint le type par « sous »
positif_certain(K, Cat, W, T) :-
    sens_du_mot(K, Cat, W, Ss), Ss \== [], forall(member(S0, Ss), sous_atteint(K, [S0], [S0], T)).
sous_atteint(_, _, Vus, T) :- memberchk(T, Vus), !.
sous_atteint(K, Front, Vus, T) :-
    findall(Y, ( member(X, Front), K:sous(X, Y), \+ memberchk(Y, Vus) ), Ys0), sort(Ys0, Ys),
    Ys \== [], append(Vus, Ys, Vus1), sous_atteint(K, Ys, Vus1, T).
monte_inclus(K, S, T, _) :- inclus_atteints(K, [S], [S], Ns), memberchk(T, Ns).
inclus_atteints(K, Front, Vus, Ns) :-
    findall(Y, ( member(X, Front), K:inclus(X, Y), \+ memberchk(Y, Vus) ), Ys0), sort(Ys0, Ys),
    ( Ys == [] -> Ns = Vus ; append(Vus, Ys, Vus1), inclus_atteints(K, Ys, Vus1, Ns) ).

% --- Les contraintes -------------------------------------------------------------------------------------------------

contrainte_justifiee(K, G, S, _, meme(X, Y), egalite) :-
    val(S, X, A), val(S, Y, B), A == B,
    % la classe n'est pas dite deux : ni par le texte (entre entités que l'auteur dit là), ni par K
    \+ ( member(distinct(E1, E2), G), meme_classe(G, E1, A), meme_classe(G, E2, A), porteur_admis(G, E1),
         porteur_admis(G, E2) ),
    \+ ( nom_admissible(K, G, A, C1), nom_admissible(K, G, A, C2), K:distincts_documentes(C1, C2, _) ).
contrainte_justifiee(K, G, S, _, distincts(X, Y), etablie(distinct(E1, E2))) :-
    val(S, X, A), val(S, Y, B), A \== B, meme_classe(G, E1, A), meme_classe(G, E2, B),
    ( memberchk(distinct(E1, E2), G) ; memberchk(distinct(E2, E1), G) ),
    porteur_admis(G, E1), porteur_admis(G, E2),          % une distinction entre deux entités que l'auteur dit là,
    \+ inexistante(K, G, E1), \+ inexistante(K, G, E2).   % et dont le texte ne nie pas l'existence
contrainte_justifiee(K, G, S, _, distincts(X, Y), documentaire(C1, C2, Src)) :-
    val(S, X, A), val(S, Y, B), A \== B, nom_admissible(K, G, A, C1), nom_admissible(K, G, B, C2),
    ( K:distincts_documentes(C1, C2, Src) ; K:distincts_documentes(C2, C1, Src) ),
    portes(K, G, A, N1), portes(K, G, B, N2),
    \+ ( member(C, N2), cles_equivalentes(K, C1, C) ), \+ ( member(C, N1), cles_equivalentes(K, C2, C) ).
contrainte_justifiee(K, G, S, Hs, distincts(X, Y), hypothese) :-
    val(S, X, A), val(S, Y, B), A \== B, memberchk(distinction_supposee(X, Y, N1, N2), Hs),
    noms(K, G, A, N1), noms(K, G, B, N2), N1 \== [], N2 \== [],
    portes(K, G, A, P1), portes(K, G, B, P2), \+ ( member(C1, P1), member(C2, P2), cles_equivalentes(K, C1, C2) ).
contrainte_justifiee(K, G, S, _, nombre(X, N), nombre(E)) :-
    val(S, X, R), memberchk(nombre(E, N), G), meme_classe(G, E, R), porteur_admis(G, E), \+ inexistante(K, G, E),
    \+ ( member(nombre(E2, N2), G), N2 \== N, meme_classe(G, E2, R), present(G, E2) ).   % aucun autre nombre

% un nom sur lequel une distinction documentaire repose : de l'auteur, porteur admis, non contredit dans la classe
nom_admissible(K, G, R, C) :-
    member(nom(A, E, Nom, _), G), meme_classe(G, E, R), qualifie(G, A, pos, represente, auteur), porteur_admis(G, E),
    \+ inexistante(K, G, E),                               % le porteur existe selon le texte (audit final, B1)
    K:cle_de_nom(Nom, C), \+ nie_dans_la_classe(K, G, R, C).

noms(K, G, R, Ns) :-
    findall(C, ( member(nom(A, E, Nom, _), G), meme_classe(G, E, R), qualifie(G, A, pos, represente, _),
                 present(G, E), K:cle_de_nom(Nom, C), \+ nie_dans_la_classe(K, G, R, C) ), Ns0), sort(Ns0, Ns).
portes(K, G, R, Ns) :-
    findall(C, ( member(nom(A, E, Nom, _), G), meme_classe(G, E, R), memberchk(polarite(A, pos), G),
                 K:cle_de_nom(Nom, C) ), Ns0), sort(Ns0, Ns).
nie_dans_la_classe(K, G, R, C) :-
    member(nom(A2, E2, Nom2, _), G), meme_classe(G, E2, R), qualifie(G, A2, neg, represente, _), present(G, E2),
    K:cle_de_nom(Nom2, C2), cles_equivalentes(K, C, C2), !.
