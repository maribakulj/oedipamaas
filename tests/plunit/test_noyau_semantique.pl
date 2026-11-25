/*  Le banc des contre-exemples sémantiques du noyau (docs/NOYAU.md, version 0.2) : pour chaque cas, le statut attendu
    est écrit d'après la spécification seule, à la main, avant d'avoir exécuté quoi que ce soit ; il est confronté au
    moteur optimisé ET au moteur de référence. Les deux moteurs peuvent partager une erreur de conception ; ce banc ne
    dépend d'aucun d'eux.  */
:- use_module('../../oedipamaas/socle/satisfaction').
:- use_module('../../oedipamaas/socle/satisfaction_reference').
:- use_module('../../oedipamaas/socle/verificateur').
:- use_module(connaissances_essai).
:- use_module(library(plunit)).
:- use_module(library(lists)).
:- use_module(library(apply)).
:- encoding(utf8).

graphe(Fs0, G) :-
    exclude(marqueur, Fs0, Fs1), include(marqueur, Fs0, Ms),
    findall(A, ( member(F, Fs1), identifiant(F, A) ), As),
    findall(Q, ( member(A, As), qualificatif(A, Ms, Q) ), Qs),
    findall(passage(P, 0, 1), ( member(F, Fs1), identifiant(F, _), arg(_, F, P), atom(P), sub_atom(P, 0, 2, _, p_) ), Ps0),
    sort(Ps0, Ps), append([[texte("x"), doc(fr, inconnu)], Fs1, Qs, Ps], G).
marqueur(neg(_)). marqueur(mod(_, _)). marqueur(por(_, _)). marqueur(enon(_, _)).
identifiant(entite(A, _, _), A). identifiant(nom(A, _, _, _), A). identifiant(propriete(A, _, _, _), A).
identifiant(evenement(A, _, _), A). identifiant(relation(A, _, _, _, _), A).
qualificatif(A, Ms, polarite(A, Po)) :- ( memberchk(neg(A), Ms) -> Po = neg ; Po = pos ).
qualificatif(A, Ms, modalite(A, M)) :- ( memberchk(mod(A, M), Ms) -> true ; M = affirme ).
qualificatif(A, Ms, portee(A, P)) :- ( memberchk(por(A, P), Ms) -> true ; P = represente ).
qualificatif(A, Ms, enonciateur(A, Q)) :- ( memberchk(enon(A, Q), Ms) -> true ; Q = auteur ).

% cas(Nom, Faits, Requete, StatutAttendu, Pourquoi)
cas(pas_de_lion_ne_nie_pas_felin,
    [entite(e1, lion, p_1), neg(e1)], requete(q, type(v(x), felin)), inconnue,
    'ne pas être un lion ne dit rien de félin : la négation descend la hiérarchie, elle ne la remonte pas').
cas(pas_de_felin_nie_lion,
    [entite(e1, felin, p_1), neg(e1)], requete(q, type(v(x), lion)), ecartee,
    'nier un type plus général nie les plus spécifiques').
cas(deux_mentions_sans_coreference,
    [entite(e1, homme, p_1), entite(e2, homme, p_2)],
    requete(q, et([type(v(x), homme), type(v(y), homme), distincts(v(x), v(y))])), inconnue,
    'deux identifiants ne sont pas deux individus : identité inconnue').
cas(distinction_etablie,
    [entite(e1, homme, p_1), entite(e2, homme, p_2), distinct(e1, e2)],
    requete(q, et([type(v(x), homme), type(v(y), homme), distincts(v(x), v(y))])), etablie,
    'le texte dit qu’ils sont deux').
cas(noms_differents_hypothese,
    [entite(e1, homme, p_1), nom(n1, e1, abel, p_2), entite(e2, homme, p_3), nom(n2, e2, cain, p_4)],
    requete(q, et([nom(v(x), ['ABEL']), nom(v(y), ['CAIN']), distincts(v(x), v(y))])), etablie_sous_hypotheses,
    'des noms différents sans alias : une hypothèse révisable, pas une preuve').
cas(noms_documentes_distincts,
    [entite(e1, homme, p_1), nom(n1, e1, david, p_2), entite(e2, homme, p_3), nom(n2, e2, goliath, p_4)],
    requete(q, et([nom(v(x), ['DAVID']), nom(v(y), ['GOLIATH']), distincts(v(x), v(y))])), etablie,
    'K documente deux individus : une preuve relative à cette source').
cas(conjonction_faux_et_inconnu,
    [entite(e1, lion, p_1), neg(e1)], requete(q, et([type(v(x), lion), propriete(v(x), mort)])), ecartee,
    'sous x = e1, faux ∧ inconnu = faux').
cas(disjonction_contradictoire_et_inconnu,
    [entite(e1, homme, p_1), nom(n1, e1, pierre, p_2), nom(n2, e1, pierre, p_3), neg(n2), enon(n2, cite(etude))],
    requete(q, ou([nom(v(x), ['PIERRE']), type(v(x), lion)])), non_certifiee,
    'contradictoire ∨ inconnu est vrai (Belnap), mais aucune preuve ne passe hors de la composante contradictoire').
cas(contradiction_de_sources,
    [entite(e1, homme, p_1), nom(n1, e1, pierre, p_2), nom(n2, e1, pierre, p_3), neg(n2), enon(n2, cite(etude))],
    requete(q, et([type(v(x), homme), nom(v(x), ['PIERRE'])])), contradictoire,
    'un catalogue et une étude en désaccord : le désaccord est gardé').
cas(propriete_d_un_referent_hypothetique,
    [entite(e1, homme, p_1), mod(e1, possible), propriete(q1, e1, mort, p_2)], requete(q, propriete(v(x), mort)), inconnue,
    'une propriété d’un référent seulement possible ne prouve rien').
cas(negation_dans_une_alternative,
    [entite(e1, homme, p_1), nom(n1, e1, pierre, p_2), nom(n2, e1, paul, p_3), nom(n3, e1, pierre, p_4), neg(n3),
     alternative_de(n3, n2)],
    requete(q, nom(v(x), ['PIERRE'])), etablie,
    'une négation qui n’est qu’une hypothèse ne réfute pas une conclusion affirmée').
cas(source_citee_seule,
    [entite(e1, homme, p_1), nom(n1, e1, pierre, p_2), enon(n1, cite(catalogue))], requete(q, nom(v(x), ['PIERRE'])),
    non_certifiee, 'la seule parole d’une source citée : vrai selon le graphe, non certifiable').
cas(role_inverse_n_est_pas_une_negation,
    [entite(e1, homme, p_1), nom(n1, e1, david, p_2), entite(e2, homme, p_3), nom(n2, e2, goliath, p_4),
     evenement(v1, decapiter, p_5), role(v1, agent, e2), role(v1, patient, e1)],
    requete(q, et([nom(v(x), ['DAVID']), nom(v(y), ['GOLIATH']), distincts(v(x), v(y)), evenement(v(e), decapiter),
                   role(v(e), agent, v(x)), role(v(e), patient, v(y))])), inconnue,
    'Goliath tranche la tête de David ne nie pas que David tranche celle de Goliath').
cas(nombre_contredit_par_le_texte,
    [entite(e1, ange, p_1), nombre(e1, 3)], requete(q, et([type(v(x), ange), nombre(v(x), 2)])), ecartee,
    'le texte dit trois anges').
cas(meme_contre_distinction_etablie,
    [entite(e1, homme, p_1), entite(e2, femme, p_2), distinct(e1, e2)],
    requete(q, et([type(v(x), homme), type(v(y), femme), meme(v(x), v(y))])), ecartee,
    'une identité exigée là où le texte dit deux référents').
cas(genre_de_l_oeuvre_seulement,
    [entite(e1, portrait, p_1)], requete(q, genre(portrait)), inconnue,
    'un portrait dans la scène n’est pas le genre de l’œuvre').

% une alternative entre deux assertions : le marqueur alternative_de(A, B) devient alternative(g_A, [A, B])
graphe_cas(Fs0, G) :-
    exclude([F]>>( F = alternative_de(_, _) ), Fs0, Fs1), graphe(Fs1, G0),
    findall(alternative(Gr, [A, B]), ( member(alternative_de(A, B), Fs0), atom_concat(g_, A, Gr) ), Alts),
    append(G0, Alts, G).

:- begin_tests(noyau_semantique).

test(moteur_optimise, [forall(cas(N, Fs, Q, Attendu, _))]) :-
    graphe_cas(Fs, G), satisfaire(connaissances_essai, G, Q, resultat(S, _, _)),
    ( S == Attendu -> true ; format(user_error, "~w : attendu ~w, obtenu ~w~n", [N, Attendu, S]), fail ).
test(moteur_de_reference, [forall(cas(N, Fs, Q, Attendu, _))]) :-
    graphe_cas(Fs, G), statut_reference(connaissances_essai, G, Q, S),
    ( S == Attendu -> true ; format(user_error, "~w : attendu ~w, obtenu ~w~n", [N, Attendu, S]), fail ).
test(preuves_acceptees, [forall(cas(_, Fs, Q, _, _))]) :-
    graphe_cas(Fs, G), satisfaire(connaissances_essai, G, Q, resultat(_, Els, _)),
    forall(( member(P, Els), P = preuve(_, _, _, _, _, _) ), verifier(connaissances_essai, G, Q, P, accepte)).

:- end_tests(noyau_semantique).
