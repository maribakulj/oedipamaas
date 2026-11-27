/*  Tests du compilateur des libellés en requêtes (requetes_iconclass.pl) qui ne demandent aucune donnée : les règles
    pures du compilateur. Les attendus suivent docs/NOYAU.md et docs/PLAN_V1.md (C3) ; chacun a d'abord échoué.
    Les corrections fondées de la contre-expertise de la PR #16 (docs/mesures/C3_CONTRE_EXPERTISE.md) sont testées sur
    un petit lexique écrit ici (wordnet:s/6, lexfile/2, hyp/2, ressources:wolf/2), à la place de la base ; chacune
    échoue sans sa correction. Les tests de non-régression (« non_regression ») gardent une opération que la
    contre-expertise écarte hors du compilateur.  */
:- use_module('../../oedipamaas/socle/requetes_iconclass').
:- use_module(library(plunit)).
:- encoding(utf8).

:- dynamic sujets:ferme/2, wordnet:s/6, wordnet:lexfile/2, wordnet:hyp/2, wordnet:ins/2, wordnet:exc/3,
           ressources:wolf/2, libelles_lus:partie/7.

% le petit lexique : synset, numéro du mot, mot, catégorie, rang du sens, occurrences annotées
lexique([ s(101, 1, trademark, n, 1, 3), lexfile(101, 'noun.communication'),
          s(102, 1, card, n, 1, 3), lexfile(102, 'noun.artifact'),
          s(103, 1, trade, n, 1, 3), lexfile(103, 'noun.act'),
          s(110, 1, rocket, n, 1, 2), lexfile(110, 'noun.artifact'), s(111, 1, device, n, 1, 2),
          s(112, 1, light, n, 1, 2), hyp(110, 111),
          s(113, 1, blackbird, n, 1, 2), s(114, 1, bird, n, 1, 9),
          wolf(105512337, organe), wolf(105513302, 'organe sexuel'), wolf(301234567, sexuel),
          wolf(100000115, contrôle), wolf(100000116, naissance) ]).
avec_lexique :-
    abolish_all_tables,
    forall(member(F, [s/6, lexfile/2, hyp/2, ins/2, exc/3]), ( F = N/A, functor(H, N, A), retractall(wordnet:H) )),
    retractall(ressources:wolf(_, _)),
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

% --- Les corrections fondées (contre-expertise de la PR #16) ----------------------------------------------------------

:- begin_tests(corrections_fondees).

% D4 : « organes sexuels » : le singulier, puis le composé que WOLF lexicalise
test(singulier_puis_compose, Cs == [type(v(e), 'organe sexuel')]) :-
    langue(fr),
    requetes_iconclass:corriger([], [], [type(v(e), organes), propriete(v(e), sexuel)], Cs0),
    requetes_iconclass:composes(Cs0, Cs).
test(singulier_seulement_si_inconnu, C == type(v(e), organe)) :-
    langue(fr), requetes_iconclass:singulier(fr, type(v(e), organe), C).

% D3 restreint : un composé de deux noms que la langue lexicalise (« trade mark », écrit « trademark ») est un seul type
composes_ph([phrase([mot(1, trade, trade, 'NOUN', [], 2, compound, 0, 5), mot(2, Tete, Tete, 'NOUN', [], 0, root, 6, Fin)])],
            Tete, Fin).
faits_composes(Tete, Fin, [entite(e1, trade, p1), passage(p1, 0, 5), entite(e2, Tete, p2), passage(p2, 6, Fin)]).
test(compose_lexicalise, Cs == [type(v(e2), trademark)]) :-
    langue(en), composes_ph(Ph, mark, 10), faits_composes(mark, 10, Fs),
    requetes_iconclass:corriger(Ph, Fs, [type(v(e1), trade), type(v(e2), mark)], Cs).
test(compose_soude_couvre_ses_mots) :-
    composes_ph(Ph, mark, 10), requetes_iconclass:couvert_soude(Ph, [type(v(e2), trademark)], trade).
% non-régression : un composé que la langue ne lexicalise pas (« trade card ») n'est pas changé en propriété : sa
% relation implicite n'est pas dite ; les deux variables restent, et la requête est partielle (non_lie)
test(non_regression_compose_non_lexicalise, Cs == [type(v(e1), trade), type(v(e2), card)]) :-
    langue(en), composes_ph(Ph, card, 10), faits_composes(card, 10, Fs),
    requetes_iconclass:corriger(Ph, Fs, [type(v(e1), trade), type(v(e2), card)], Cs).
% non-régression : un adjectif et un nom ne sont jamais soudés (« black bird » n'est pas « blackbird »)
test(non_regression_adjectif_non_soude, Cs == [type(v(x), bird), propriete(v(x), black)]) :-
    langue(en), requetes_iconclass:composes([type(v(x), bird), propriete(v(x), black)], Cs).

% « contrôle des naissances » : « des » lu comme article, le complément relié par « de »
test(complement_non_lu, Cs == [relation(v(e1), de, v(e3)), type(v(e1), contrôle), type(v(e3), naissance)]) :-
    langue(fr),
    Ph = [phrase([mot(1, contrôle, contrôle, 'NOUN', [], 0, root, 0, 8), mot(2, des, un, 'DET', [], 3, det, 9, 12),
                  mot(3, naissances, naissance, 'NOUN', [], 1, nmod, 13, 23)])],
    Fs = [entite(e1, contrôle, p1), passage(p1, 0, 8), entite(e3, naissance, p3), passage(p3, 13, 23)],
    requetes_iconclass:corriger(Ph, Fs, [type(v(e1), contrôle), type(v(e3), naissance)], Cs).

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

:- end_tests(corrections_fondees).

% la coordination elliptique (definitions.pl) : un segment qui a son propre modifieur ne reprend pas le contexte ; en
% français, le contexte avant est ce qui précède le premier nom
:- use_module('../../oedipamaas/socle/definitions').
:- begin_tests(ellipse).
test(segment_complet_anglais, Ss == [[trade, mark], [trade, token]]) :-
    definitions:segments_complets(en, [mot(1, trade, trade, 'NOUN', [], 2, compound, 0, 5), mot(2, mark, mark, 'NOUN', [], 0, root, 6, 10),
        mot(3, ',', ',', 'PUNCT', [], 5, punct, 10, 11), mot(4, trade, trade, 'NOUN', [], 5, compound, 12, 17),
        mot(5, token, token, 'NOUN', [], 2, conj, 18, 23)], Ss0),
    maplist([S, Fs]>>findall(F, member(mot(_, F, _, _, _, _, _, _, _), S), Fs), Ss0, Ss).
% non-régression : un segment réduit à sa tête reprend le contexte partagé
test(non_regression_ellipse_anglaise, Ss == [[miraculous, activities], [miraculous, events]]) :-
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
