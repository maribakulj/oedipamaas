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
cas(un_lion_et_pas_de_lion,
    [entite(e1, lion, p_1), entite(e2, lion, p_2), neg(e2)], requete(q, type(v(x), lion)), contradictoire,
    'une entité niée dit qu’aucun référent de ce type n’est figuré (« pas de lion ») : elle contredit le lion affirmé').
cas(pas_d_animal_contredit_le_lion,
    [entite(e1, lion, p_1), entite(e2, animal, p_2), neg(e2)], requete(q, type(v(x), lion)), contradictoire,
    'nier le type plus général nie les plus spécifiques, pour tout référent').
cas(pas_de_lion_laisse_le_felin_affirme,
    [entite(e1, tigre, p_1), entite(e2, lion, p_2), neg(e2)], requete(q, type(v(x), felin)), etablie,
    'pas de lion ne dit rien des félins : le tigre reste un félin').
% Écrit d'abord avec l'attendu « etablie » (un événement nié sans participant ne nierait rien) ; la version 0.3 lit un
% événement nié comme la négation d'une description (§ 1) : sans rôle, il nie tout événement de ce prédicat. C'est la
% lecture la plus prudente (elle refuse de certifier plus souvent), retenue faute d'une décision contraire.
cas(un_tenir_nie_sans_participant_conteste_tout_tenir,
    [entite(e1, femme, p_1), entite(e2, enfant, p_2), evenement(v1, tenir, p_3), role(v1, agent, e1),
     role(v1, patient, e2), evenement(v2, tenir, p_4), neg(v2)],
    requete(q, et([type(v(x), femme), evenement(v(e), tenir), role(v(e), agent, v(x))])), contradictoire,
    '« personne ne tient rien » contredit « la femme tient l’enfant »').
cas(la_meme_action_niee_la_contredit,
    [entite(e1, femme, p_1), entite(e2, enfant, p_2), evenement(v1, tenir, p_3), role(v1, agent, e1),
     role(v1, patient, e2), evenement(v2, tenir, p_4), role(v2, agent, e1), role(v2, patient, e2), neg(v2)],
    requete(q, et([type(v(x), femme), evenement(v(e), tenir), role(v(e), agent, v(x))])), contradictoire,
    '« la femme tient l’enfant » et « la femme ne tient pas l’enfant »').
cas(une_action_niee_d_un_autre_ne_contredit_pas,
    [entite(e1, femme, p_1), entite(e2, enfant, p_2), entite(e3, homme, p_5), evenement(v1, tenir, p_3),
     role(v1, agent, e1), role(v1, patient, e2), evenement(v2, tenir, p_4), role(v2, agent, e3), neg(v2)],
    requete(q, et([type(v(x), femme), evenement(v(e), tenir), role(v(e), agent, v(x))])), etablie,
    '« l’homme ne tient rien » ne dit rien de ce que tient la femme').
% --- Contre-exemples de l'audit contradictoire du cycle 3 (journal, D23 à D35), attendus d'après la sémantique seule
cas(nier_un_nom_ne_nie_pas_la_liste,
    [entite(e1, homme, p_1), nom(n1, e1, pierre, p_2), neg(n1)], requete(q, nom(v(x), ['PIERRE', 'PAUL'])), inconnue,
    '« pas Pierre » ne dit pas « ni Pierre ni Paul » : une liste de noms est une disjonction (D24)').
cas(paul_qui_n_est_pas_pierre,
    [entite(e1, homme, p_1), nom(n1, e1, paul, p_2), nom(n2, e1, pierre, p_3), neg(n2)],
    requete(q, nom(v(x), ['PIERRE', 'PAUL'])), etablie, 'Paul, qui n’est pas Pierre, porte l’un des deux noms (D24)').
cas(ne_pas_terrasser_n_est_pas_ne_pas_attaquer,
    [entite(e1, homme, p_1), evenement(v1, terrasser, p_2), role(v1, agent, e1), neg(v1)],
    requete(q, et([evenement(v(e), attaquer), role(v(e), agent, v(x))])), inconnue,
    'on peut attaquer sans terrasser ; le rôle d’un événement nié n’est pas nié seul (D23)').
cas(goliath_ne_decapite_pas_david,
    [entite(e1, homme, p_1), nom(n1, e1, david, p_2), entite(e2, homme, p_3), nom(n2, e2, goliath, p_4),
     evenement(v1, decapiter, p_5), role(v1, agent, e2), role(v1, patient, e1), neg(v1)],
    requete(q, et([nom(v(x), ['DAVID']), nom(v(y), ['GOLIATH']), evenement(v(e), decapiter),
                   role(v(e), agent, v(x)), role(v(e), patient, v(y))])), inconnue,
    'nier qu’il soit décapité par Goliath ne nie pas que David décapite Goliath (D23)').
cas(pas_de_lion_mort_ne_nie_pas_les_lions,
    [entite(e1, lion, p_1), neg(e1), propriete(q1, e1, mort, p_2)],
    requete(q, et([type(v(x), lion), propriete(v(x), vivant)])), inconnue,
    '¬∃x (lion(x) ∧ mort(x)) n’implique pas ¬∃x lion(x) (D23)').
cas(un_lion_et_pas_de_lion_mort,
    [entite(e1, lion, p_1), entite(e2, lion, p_2), neg(e2), propriete(q2, e2, mort, p_3)],
    requete(q, type(v(x), lion)), etablie, 'un lion, et aucun lion mort : le lion reste affirmé (D23)').
cas(epee_niee_dans_la_main_d_un_autre,
    [entite(e1, ange, p_1), entite(e3, epee, p_3), relation(r1, e1, tenir, e3, p_4), entite(e4, saint, p_5),
     entite(e2, epee, p_2), neg(e2), relation(r2, e4, tenir, e2, p_6)],
    requete(q, et([type(v(x), epee), relation(v(y), tenir, v(x))])), etablie,
    '« le saint ne tient pas d’épée » ne nie pas l’épée de l’ange (D23)').
cas(ce_personnage_n_est_pas_un_saint,
    [entite(e1, homme, p_1), entite(e2, saint, p_2), neg(e2), coref(e1, e2), entite(e3, saint, p_3)],
    requete(q, type(v(x), saint)), etablie,
    'nier qu’un référent soit un saint (prédicatif, par coréférence) ne nie pas les autres saints').
cas(homme_present_selon_un_catalogue_seulement,
    [entite(e1, homme, p_1), enon(e1, cite(catalogue)), nom(n1, e1, pierre, p_2)], requete(q, nom(v(x), ['PIERRE'])),
    non_certifiee, 'l’existence du porteur ne repose que sur une source citée (D25)').
cas(agent_present_selon_un_catalogue_seulement,
    [entite(e1, homme, p_1), enon(e1, cite(catalogue)), evenement(v1, bercer, p_2), role(v1, agent, e1)],
    requete(q, et([evenement(v(e), bercer), role(v(e), agent, v(x))])), non_certifiee,
    'le participant n’est là que selon une source citée (D25)').
cas(david_selon_un_catalogue_seulement,
    [entite(e1, homme, p_1), nom(n1, e1, david, p_2), enon(n1, cite(catalogue)), entite(e2, homme, p_3),
     nom(n2, e2, goliath, p_4)],
    requete(q, et([type(v(x), homme), type(v(y), homme), distincts(v(x), v(y))])), etablie_sous_hypotheses,
    'une distinction documentaire ne repose pas sur la parole d’une source citée ; il reste l’hypothèse (D26)').
cas(nom_affirme_et_nie_ne_distingue_pas,
    [entite(e1, homme, p_1), nom(n1, e1, david, p_2), nom(n3, e1, david, p_5), neg(n3), entite(e2, homme, p_3),
     nom(n2, e2, goliath, p_4)],
    requete(q, et([type(v(x), homme), type(v(y), homme), distincts(v(x), v(y))])), inconnue,
    'un nom contredit ne fonde aucune distinction, ni documentaire ni supposée (D26)').
cas(deux_david_dont_un_goliath,
    [entite(e1, homme, p_1), nom(n1, e1, david, p_2), entite(e2, homme, p_3), nom(n2, e2, goliath, p_4),
     nom(n3, e2, david, p_5)],
    requete(q, et([nom(v(x), ['DAVID']), nom(v(y), ['DAVID']), distincts(v(x), v(y))])), inconnue,
    'les deux classes portent DAVID : rien ne les distingue (D26)').
cas(type_entier_nie,
    [entite(e1, lionne, p_1), neg(e1)], requete(q, type(v(x), 1001)), ecartee,
    'pas de lionne nie le concept de lionne, comme le mot (D27)').
cas(type_entier_contredit,
    [entite(e1, lionne, p_1), entite(e2, lionne, p_2), neg(e2), enon(e2, cite(etude)), coref(e1, e2)],
    requete(q, type(v(x), 1001)), contradictoire, 'l’étude nie ce que l’auteur affirme (D27)').
cas(nombre_seulement_possible,
    [entite(e1, ange, p_1), entite(e2, ange, p_2), mod(e2, possible), nombre(e2, 3), coref(e1, e2)],
    requete(q, et([type(v(x), ange), nombre(v(x), 3)])), inconnue, 'un nombre seulement possible ne prouve rien (D28)').
cas(nombre_possible_ne_refute_pas,
    [entite(e1, ange, p_1), entite(e2, ange, p_2), mod(e2, possible), nombre(e2, 3), coref(e1, e2)],
    requete(q, et([type(v(x), ange), nombre(v(x), 2)])), inconnue, 'ni ne réfute (D28)').
cas(nombre_d_une_autre_portee,
    [entite(e1, ange, p_1), entite(e2, ange, p_2), por(e2, histoire), nombre(e2, 3), coref(e1, e2)],
    requete(q, et([type(v(x), ange), nombre(v(x), 3)])), inconnue, 'le nombre de l’histoire n’est pas celui de l’image (D28)').
cas(nombre_dans_une_alternative,
    [entite(e1, ange, p_1), entite(e2, ange, p_2), entite(e3, ange, p_3), nombre(e2, 2), nombre(e3, 3),
     alternative_de(e2, e3), coref(e1, e2)],
    requete(q, et([type(v(x), ange), nombre(v(x), 2)])), inconnue, '« deux ou trois anges » (D28)').
cas(coreferents_et_distincts,
    [entite(e1, homme, p_1), entite(e2, homme, p_2), coref(e1, e2), distinct(e1, e2)],
    requete(q, et([type(v(x), homme), type(v(y), homme), meme(v(x), v(y))])), contradictoire,
    'le graphe dit à la fois le même et deux (D29)').
cas(deux_nombres,
    [entite(e1, ange, p_1), nombre(e1, 2), nombre(e1, 3)], requete(q, et([type(v(x), ange), nombre(v(x), 2)])),
    contradictoire, 'deux et trois à la fois (D29)').
cas(lionne_niee_ne_prouve_pas_un_lion,
    [entite(e1, lionne, p_1), entite(e2, lionne, p_2), neg(e2)], requete(q, type(v(x), lion)), non_certifiee,
    'la prémisse « une lionne » est contredite par « pas de lionne » : vrai selon le graphe, non certifiable').
cas(negation_du_type_demande,
    [entite(e1, fauve, p_1), entite(e2, felin, p_2), neg(e2)], requete(q, type(v(x), felin)), contradictoire,
    '« pas de félin » nie le type demandé, même quand le mot du texte n’y mène pas par inclusion').
cas(pas_de_felin_ne_nie_pas_le_mot_fauve,
    [entite(e1, fauve, p_1), entite(e2, felin, p_2), neg(e2)], requete(q, type(v(x), fauve)), etablie,
    'fauve → félin n’est pas une inclusion : nier félin ne nie pas fauve').
cas(alias_en_chaine,
    [entite(e1, homme, p_1), nom(n1, e1, girolamo, p_2)], requete(q, nom(v(x), ['HIERONYMUS'])), etablie,
    'HIERONYMUS ~ JEROME ~ GIROLAMO : l’alias est clos (D33)').
cas(hypothese_que_l_alias_interdit,
    [entite(e1, homme, p_1), nom(n1, e1, hieronymus, p_2), entite(e2, homme, p_3), nom(n2, e2, girolamo, p_4)],
    requete(q, et([nom(v(x), ['HIERONYMUS']), nom(v(y), ['GIROLAMO']), distincts(v(x), v(y))])), inconnue,
    'deux noms d’un même individu ne fondent aucune hypothèse de distinction (D33)').
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
