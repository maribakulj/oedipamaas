/*  Tests du compilateur des libellés en requêtes (requetes_iconclass.pl) qui ne demandent aucune donnée : les règles
    pures du compilateur. Les attendus suivent docs/NOYAU.md et docs/PLAN_V1.md (C3) ; chacun a d'abord échoué.
    Les corrections du 27/11 (docs/mesures/C3_CORRECTIONS.md, D1 à D8) sont testées sur un petit lexique écrit ici
    (wordnet:s/6, lexfile/2, der/4, hyp/2, ressources:wolf/2), à la place de la base.  */
:- use_module('../../oedipamaas/socle/requetes_iconclass').
:- use_module(library(plunit)).
:- encoding(utf8).

:- dynamic sujets:ferme/2, wordnet:s/6, wordnet:lexfile/2, wordnet:der/4, wordnet:hyp/2, wordnet:ins/2, wordnet:exc/3,
           ressources:wolf/2, ressources:morphosem/5, libelles_lus:partie/7.

% le petit lexique : synset, numéro du mot, mot, catégorie, rang du sens, occurrences annotées
lexique([ s(101, 1, trademark, n, 1, 3), lexfile(101, 'noun.communication'),
          s(102, 1, card, n, 1, 3), lexfile(102, 'noun.artifact'),
          s(103, 1, trade, n, 1, 3), lexfile(103, 'noun.act'),
          s(104, 1, brass, n, 1, 11), lexfile(104, 'noun.substance'),
          s(105, 1, serpent, n, 1, 1), lexfile(105, 'noun.animal'),
          s(201, 1, make, v, 1, 9), s(202, 1, pray, v, 1, 2), s(203, 1, set, v, 1, 5),
          s(204, 1, upholster, v, 1, 1), s(205, 1, plane, v, 1, 1), s(206, 1, plan, v, 1, 4),
          s(207, 1, imprison, v, 1, 3), s(106, 1, imprisonment, n, 1, 3), lexfile(106, 'noun.act'),
          der(207, 1, 106, 1),
          s(108, 1, fire, n, 1, 9), lexfile(108, 'noun.event'), s(208, 1, fire, v, 1, 9), der(208, 1, 108, 1),
          s(110, 1, rocket, n, 1, 2), lexfile(110, 'noun.artifact'), s(111, 1, device, n, 1, 2),
          s(112, 1, light, n, 1, 2), hyp(110, 111),
          wolf(105512337, organe), wolf(105513302, 'organe sexuel'), wolf(301234567, sexuel), wolf(301234568, mâle),
          wolf(100000115, contrôle), wolf(100000116, naissance) ]).
avec_lexique :-
    abolish_all_tables,
    forall(member(F, [s/6, lexfile/2, der/4, hyp/2, ins/2, exc/3]), ( F = N/A, functor(H, N, A), retractall(wordnet:H) )),
    retractall(ressources:wolf(_, _)), retractall(ressources:morphosem(_, _, _, _, _)),
    lexique(Fs), forall(member(F, Fs), ( F = wolf(_, _) -> assertz(ressources:F) ; assertz(wordnet:F) )).
langue(L) :- avec_lexique, nb_setval(definitions_langue, L).

:- begin_tests(compilateur).

% D17 : un mot plein du libellé n'est couvert que par un atome qui le porte comme mot entier ; une sous-chaîne ne
% couvre rien (« woman » ne couvre pas « man »), sans quoi une requête incomplète passerait pour compilée
test(sous_chaine_ne_couvre_pas) :- \+ requetes_iconclass:couvert([type(v(x), woman)], man).
test(nom_sous_chaine_ne_couvre_pas) :- \+ requetes_iconclass:couvert([nom(v(x), ['ANTONY'])], ant).
test(mot_entier_couvre) :- requetes_iconclass:couvert([type(v(x), man)], man).
test(mot_d_un_compose_couvre) :-
    requetes_iconclass:couvert([type(v(x), 'ring finger')], finger),
    requetes_iconclass:couvert([type(v(x), 'mal de tête')], tête).
test(mot_d_un_nom_couvre) :- requetes_iconclass:couvert([nom(v(x), ['MARK ANTONY'])], antony).
test(trait_d_union) :- requetes_iconclass:couvert([type(v(x), 'water-bird')], bird).

:- end_tests(compilateur).

% --- Les corrections du 27/11 ------------------------------------------------------------------------------------------

:- begin_tests(corrections_c3).

% D4 : « organes sexuels » : le singulier, puis le composé que WOLF lexicalise
test(singulier_puis_compose, Cs == [type(v(e), 'organe sexuel')]) :-
    langue(fr),
    requetes_iconclass:corriger_avant([], [], [type(v(e), organes), propriete(v(e), sexuel)], Cs0),
    requetes_iconclass:composes(Cs0, Cs).
test(singulier_seulement_si_inconnu, C == type(v(e), organe)) :-
    langue(fr), requetes_iconclass:singulier(fr, type(v(e), organe), C).

% D3 : le modifieur d'un composé devient une propriété de sa tête, ou le composé soudé que la langue lexicalise
composes_ph([phrase([mot(1, trade, trade, 'NOUN', [], 2, compound, 0, 5), mot(2, Tete, Tete, 'NOUN', [], 0, root, 6, Fin)])],
            Tete, Fin).
faits_composes(Tete, Fin, [entite(e1, trade, p1), passage(p1, 0, 5), entite(e2, Tete, p2), passage(p2, 6, Fin)]).
test(modifieur_en_propriete, Cs == [type(v(e2), card), propriete(v(e2), trade)]) :-
    langue(en), composes_ph(Ph, card, 10), faits_composes(card, 10, Fs),
    requetes_iconclass:corriger_avant(Ph, Fs, [type(v(e1), trade), type(v(e2), card)], Cs0),
    requetes_iconclass:composes(Cs0, Cs1), msort(Cs1, Cs2), reverse(Cs2, Cs).
test(compose_soude, Cs == [type(v(e2), trademark)]) :-
    langue(en), composes_ph(Ph, mark, 10), faits_composes(mark, 10, Fs),
    requetes_iconclass:corriger_avant(Ph, Fs, [type(v(e1), trade), type(v(e2), mark)], Cs0),
    requetes_iconclass:composes(Cs0, Cs).
test(compose_soude_couvre_ses_mots) :-
    composes_ph(Ph, mark, 10), requetes_iconclass:couvert_soude(Ph, [type(v(e2), trademark)], trade).
% « contrôle des naissances » : « des » lu comme article, le complément relié par « de »
test(complement_non_lu, Cs == [relation(v(e1), de, v(e3)), type(v(e1), contrôle), type(v(e3), naissance)]) :-
    langue(fr),
    Ph = [phrase([mot(1, contrôle, contrôle, 'NOUN', [], 0, root, 0, 8), mot(2, des, un, 'DET', [], 3, det, 9, 12),
                  mot(3, naissances, naissance, 'NOUN', [], 1, nmod, 13, 23)])],
    Fs = [entite(e1, contrôle, p1), passage(p1, 0, 8), entite(e3, naissance, p3), passage(p3, 13, 23)],
    requetes_iconclass:corriger_avant(Ph, Fs, [type(v(e1), contrôle), type(v(e3), naissance)], Cs).

% D7 : le participe passé est un événement dont le porteur est le patient ; le présent, l'agent
participe(Forme, Lemme, Ft, Cs) :-
    langue(en),
    Ph = [phrase([mot(1, figure, figure, 'NOUN', [], 2, nsubj, 0, 6), mot(2, Forme, Lemme, 'VERB', Ft, 0, root, 7, 13)])],
    Fs = [entite(e1, figure, p1), passage(p1, 0, 6), propriete(q2, e1, Lemme, p2), passage(p2, 7, 13)],
    requetes_iconclass:participes(en, Ph, Fs, [type(v(e1), figure), propriete(v(e1), Lemme)], Cs).
test(participe_passe, Cs == [evenement(v(q2), make), role(v(q2), patient, v(e1)), type(v(e1), figure)]) :-
    participe(made, make, ['Tense'='Past', 'VerbForm'='Part'], Cs).
test(participe_present, Cs == [evenement(v(q2), pray), role(v(q2), agent, v(e1)), type(v(e1), figure)]) :-
    participe(praying, pray, ['Tense'='Pres', 'VerbForm'='Part'], Cs).
test(adjectif_non_participe, Cs == [type(v(e1), figure), propriete(v(e1), pray)]) :-
    participe(prayful, pray, [], Cs).
% D7 : la matière, aussi comme propriété (la lecture littérale reste)
test(matiere, Cs == [ou([propriete(v(s), brass), et([relation(v(s), of, v(b)), type(v(b), brass)])]), type(v(s), serpent)]) :-
    langue(en), requetes_iconclass:matieres(en, [relation(v(s), of, v(b)), type(v(b), brass), type(v(s), serpent)], Cs).
test(pas_de_matiere, Cs == [relation(v(s), of, v(b)), type(v(b), card), type(v(s), serpent)]) :-
    langue(en), requetes_iconclass:matieres(en, [relation(v(s), of, v(b)), type(v(b), card), type(v(s), serpent)], Cs).
% D7 : deux participes coordonnés partagent le sujet (« a serpent is made and is set on a pole »)
test(sujet_partage, [true(memberchk(role(v(v9), patient, v(e2)), Cs))]) :-
    Ph = [phrase([mot(2, serpent, serpent, 'NOUN', [], 6, 'nsubj:pass', 2, 9),
                  mot(6, made, make, 'VERB', ['Voice'='Pass'], 0, root, 22, 26),
                  mot(9, set, set, 'VERB', ['Voice'='Pass'], 6, conj, 34, 37)])],
    Fs = [entite(e2, serpent, p2), passage(p2, 2, 9), evenement(v9, set, p9), passage(p9, 34, 37)],
    requetes_iconclass:sujets_partages(Ph, Fs, [type(v(e2), serpent), evenement(v(v9), set)], Cs).

% D2 : un gérondif ou un nom d'action, seul, est l'événement de son verbe
action(Forme, T, Cs0, Cs) :-
    langue(en), atom_length(Forme, N),
    Ph = [phrase([mot(1, Forme, T, 'NOUN', [], 0, root, 0, N)])], Fs = [entite(e1, T, p1), passage(p1, 0, N)],
    requetes_iconclass:actions(en, Ph, Fs, Cs0, Cs).
test(gerondif, Cs == [evenement(v(e1), upholster)]) :- action(upholstering, upholstering, [type(v(e1), upholstering)], Cs).
test(gerondif_e_muet, Cs == [evenement(v(e1), plane)]) :- action(planing, plane, [type(v(e1), plane)], Cs).
test(nom_d_action, Cs == [evenement(v(e1), imprison)]) :- action(imprisonment, imprisonment, [type(v(e1), imprisonment)], Cs).
% un nom d'action parmi d'autres conditions peut être un participant non relié (« hail and fire fall ») : inchangé
test(nom_d_action_non_seul, Cs == [type(v(e1), fire), type(v(e2), hail)]) :-
    action(fire, fire, [type(v(e1), fire), type(v(e2), hail)], Cs).
test(nom_d_action_couvert) :- langue(en), requetes_iconclass:couvert([evenement(v(e), imprison)], imprisonment).

% D1 : une énumération sans verbe conjugué est une disjonction ; pas une apposition, ni un participe qui modifie
enum([M|Ms]) :- M = mot(1, planing, plane, 'NOUN', [], 0, root, 0, 7),
    Ms = [mot(2, ',', ',', 'PUNCT', [], 3, punct, 7, 8), mot(3, filing, filing, 'NOUN', [], 1, parataxis, 9, 15),
          mot(4, ',', ',', 'PUNCT', [], 5, punct, 15, 16), mot(5, abrading, abrade, 'VERB', ['VerbForm'='Part'], 1, parataxis, 17, 25)].
test(enumeration, N == 3) :- enum(Ms), requetes_iconclass:enumeration([phrase(Ms)], Ss), length(Ss, N).
test(enumeration_pas_d_apposition, fail) :-
    requetes_iconclass:enumeration([phrase([mot(1, 'Shiva', 'Shiva', 'PROPN', [], 0, root, 0, 5),
        mot(2, ',', ',', 'PUNCT', [], 3, punct, 5, 6), mot(3, god, god, 'NOUN', [], 1, parataxis, 7, 10)])], _).
test(enumeration_pas_de_modifieur, fail) :-
    requetes_iconclass:enumeration([phrase([mot(1, animals, animal, 'NOUN', [], 0, root, 0, 7),
        mot(2, ',', ',', 'PUNCT', [], 3, punct, 7, 8), mot(3, kept, keep, 'VERB', ['VerbForm'='Part'], 1, acl, 9, 13)])], _).
test(enumeration_gerondif_de_liste, N == 3) :-
    requetes_iconclass:enumeration([phrase([mot(1, baptism, baptism, 'NOUN', [], 0, root, 0, 7),
        mot(2, ',', ',', 'PUNCT', [], 3, punct, 7, 8), mot(3, consecration, consecration, 'NOUN', [], 1, conj, 9, 21),
        mot(4, ',', ',', 'PUNCT', [], 5, punct, 21, 22),
        mot(5, taking, take, 'VERB', ['Tense'='Pres', 'VerbForm'='Part'], 1, acl, 23, 29),
        mot(6, vows, vow, 'NOUN', [], 5, obj, 30, 34)])], Ss), length(Ss, N).
test(enumeration_gerondif_seul_modifieur, fail) :-
    requetes_iconclass:enumeration([phrase([mot(1, woman, woman, 'NOUN', [], 0, root, 0, 5),
        mot(2, ',', ',', 'PUNCT', [], 3, punct, 5, 6),
        mot(3, holding, hold, 'VERB', ['Tense'='Pres', 'VerbForm'='Part'], 1, acl, 7, 14),
        mot(4, child, child, 'NOUN', [], 3, obj, 15, 20)])], _).
test(enumeration_pas_de_verbe_conjugue, fail) :-
    requetes_iconclass:enumeration([phrase([mot(1, man, man, 'NOUN', [], 2, nsubj, 0, 3),
        mot(2, sings, sing, 'VERB', ['VerbForm'='Fin'], 0, root, 4, 9), mot(3, ',', ',', 'PUNCT', [], 4, punct, 9, 10),
        mot(4, dances, dance, 'VERB', ['VerbForm'='Fin'], 2, conj, 11, 17)])], _).

% D6 : le genre d'un gabarit qu'aucun sens du nom n'atteint ; un nom inconnu de K garde son genre
test(genre_incompatible, fail) :- langue(en), requetes_iconclass:genre_compatible(en, [rocket], [light]).
test(genre_compatible) :- langue(en), requetes_iconclass:genre_compatible(en, [rocket], [device]).
test(genre_nom_inconnu) :- langue(en), requetes_iconclass:genre_compatible(en, [pelicanbottle], [light]).

% D5 : en français, la tête d'un gabarit est le mot que le libellé français nomme après « : »
test(tete_du_libelle_francais, Ts == [fusée]) :-
    langue(fr), retractall(libelles_lus:partie(_, _, _, _, _, _, _)),
    assertz(libelles_lus:partie('46E43(ROCKET)', fr, 1, propre, 'lumière, feu, fumée, etc. comme moyen de signalisation : fusée', [], [])),
    requetes_iconclass:tetes_du_nom('46E43(ROCKET)', fr, 'ROCKET', Ts).

% D8 : la glose d'une personne (des noms, des types, « of » vers un lieu) ; une scène n'en est pas une
test(glose) :-
    requetes_iconclass:glose_faits([entite(e1, martyr, p1), entite(e2, nom_propre, p2), nom(n2, e2, 'Quintin', p2),
                                    entite(e3, nom_propre, p3), nom(n3, e3, 'Vermand', p3), relation(r1, e1, of, e3, p3)]).
test(pas_de_glose, fail) :-
    requetes_iconclass:glose_faits([entite(e1, nom_propre, p1), nom(n1, e1, 'Adam', p1), entite(e2, founder, p2),
                                    relation(r1, e1, as, e2, p2)]).

% « différents mammifères » : plusieurs individus distincts, que les requêtes ne comptent pas ; la requête est partielle
test(pluralite, [true(memberchk(pluralite(différents), Rs))]) :-
    langue(fr),
    requetes_iconclass:mots_non_couverts(fr, [phrase([mot(1, différents, différent, 'ADJ', [], 2, amod, 0, 10),
        mot(2, mammifères, mammifère, 'NOUN', [], 0, root, 11, 21)])], [type(v(x), mammifère)], Rs).

:- end_tests(corrections_c3).

% la coordination elliptique (definitions.pl) : un segment qui a son propre modifieur ne reprend pas le contexte ; en
% français, le contexte avant est ce qui précède le premier nom
:- use_module('../../oedipamaas/socle/definitions').
:- begin_tests(ellipse).
test(segment_complet_anglais, Ss == [[trade, mark], [trade, token]]) :-
    definitions:segments_complets(en, [mot(1, trade, trade, 'NOUN', [], 2, compound, 0, 5), mot(2, mark, mark, 'NOUN', [], 0, root, 6, 10),
        mot(3, ',', ',', 'PUNCT', [], 5, punct, 10, 11), mot(4, trade, trade, 'NOUN', [], 5, compound, 12, 17),
        mot(5, token, token, 'NOUN', [], 2, conj, 18, 23)], Ss0),
    maplist([S, Fs]>>findall(F, member(mot(_, F, _, _, _, _, _, _, _), S), Fs), Ss0, Ss).
test(ellipse_anglaise, Ss == [[miraculous, activities], [miraculous, events]]) :-
    definitions:segments_complets(en, [mot(1, miraculous, miraculous, 'ADJ', [], 2, amod, 0, 10),
        mot(2, activities, activity, 'NOUN', [], 0, root, 11, 21), mot(3, and, and, 'CCONJ', [], 4, cc, 22, 25),
        mot(4, events, event, 'NOUN', [], 2, conj, 26, 32)], Ss0),
    maplist([S, Fs]>>findall(F, member(mot(_, F, _, _, _, _, _, _, _), S), Fs), Ss0, Ss).
test(contexte_francais, [nondet, true(Ss == [[contrôle, des, naissances], [contraception]])]) :-
    definitions:segments_complets(fr, [mot(1, contrôle, contrôle, 'NOUN', [], 0, root, 0, 8), mot(2, des, un, 'DET', [], 3, det, 9, 12),
        mot(3, naissances, naissance, 'NOUN', [], 1, nmod, 13, 23), mot(4, ',', ',', 'PUNCT', [], 5, punct, 23, 24),
        mot(5, contraception, contraception, 'NOUN', [], 1, nmod, 25, 38)], Ss0),
    maplist([S, Fs]>>findall(F, member(mot(_, F, _, _, _, _, _, _, _), S), Fs), Ss0, Ss).
:- end_tests(ellipse).
