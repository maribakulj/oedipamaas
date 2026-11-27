/*  Les options de sûreté du lecteur (expériences X1 à X3 ; docs/mesures/SURETE_LECTEUR.md) : chaque règle a son
    contre-exemple, écrit ici sur une analyse en dépendances faite à la main (sans analyseur) et sur un K minuscule
    (quelques synsets injectés, comme tests/plunit/test_normalisation.pl). Sans l'option, la règle ne s'applique pas :
    chaque test vérifie aussi le lecteur par défaut, qui reste celui d'avant les expériences. */
:- use_module('../../oedipamaas/socle/interpretation').
:- use_module(library(plunit)).
:- use_module(library(lists)).
:- encoding(utf8).

% --- un K minuscule : painting n'a qu'un sens, une création (certain) ; figure et ground en ont deux, dont un seul
% est une création (possible)
:- dynamic wordnet:s/6, wordnet:hyp/2, wordnet:ins/2, ressources:wolf/2.
k_essai :-
    retractall(wordnet:s(_, _, _, _, _, _)), retractall(wordnet:hyp(_, _)), retractall(wordnet:ins(_, _)),
    retractall(ressources:wolf(_, _)),
    forall(member(S-W, [100-creation, 101-painting, 103-figure, 104-figure, 105-ground, 106-ground, 107-person,
                        108-man]), assertz(wordnet:s(S, 1, W, n, 1, 0))),
    forall(member(S-P, [101-100, 103-100, 105-100, 104-107, 108-107]), assertz(wordnet:hyp(S, P))),
    assertz(ressources:wolf(199999999, rien)).
:- k_essai.

% --- l'analyse : chaque mot w(Forme, Lemme, Catégorie, Traits, Tête, Relation) ; les positions sont calculées
phrase_de(Texte, Ws, phrase(Ms)) :- mots(Ws, Texte, 1, 0, Ms).
mots([], _, _, _, []).
mots([w(Fo, Le, C, Tr, H, R)|Ws], Texte, I, P0, [mot(I, Fo, Le, C, Tr, H, R, D, F)|Ms]) :-
    sub_atom(Texte, D, L, _, Fo), D >= P0, !, F is D + L, I1 is I + 1, mots(Ws, Texte, I1, F, Ms).

lire(Options, Texte, Ws, Fs) :-
    phrase_de(Texte, Ws, P),
    (   Options == [] -> unsetenv('OEDIPAMAAS_SURETE')
    ;   atomic_list_concat(Options, ',', O), setenv('OEDIPAMAAS_SURETE', O)
    ),
    call_cleanup(interpretation:interpreter(Texte, en, description, [P], Fs), unsetenv('OEDIPAMAAS_SURETE')).

anges(Ws) :- Ws = [w('Two', two, 'NUM', ['NumType'='Card'], 2, nummod), w(angels, angel, 'NOUN', ['Number'='Plur'], 3, nsubj),
                   w(sing, sing, 'VERB', [], 0, root)].
peintre(Ws) :- Ws = [w('The', the, 'DET', ['Definite'='Def'], 2, det), w(painter, painter, 'NOUN', [], 3, nsubj),
                     w(places, place, 'VERB', [], 0, root), w(the, the, 'DET', ['Definite'='Def'], 5, det),
                     w(figure, figure, 'NOUN', [], 3, obj)].
un_peintre(Ws) :- Ws = [w('A', a, 'DET', ['Definite'='Ind'], 2, det), w(painter, painter, 'NOUN', [], 3, nsubj),
                        w(sits, sit, 'VERB', [], 0, root)].
affiche(Ws) :- Ws = [w('A', a, 'DET', ['Definite'='Ind'], 2, det), w(poster, poster, 'NOUN', [], 3, nsubj),
                     w(shows, show, 'VERB', [], 0, root), w(a, a, 'DET', ['Definite'='Ind'], 5, det),
                     w(woman, woman, 'NOUN', [], 3, obj)].
montre_lui(Ws) :- Ws = [w('The', the, 'DET', ['Definite'='Def'], 2, det), w(woman, woman, 'NOUN', [], 3, nsubj),
                        w(shows, show, 'VERB', [], 0, root), w(him, he, 'PRON', [], 3, iobj),
                        w(a, a, 'DET', ['Definite'='Ind'], 6, det), w(book, book, 'NOUN', [], 3, obj)].
dans(Nom, Ws) :- Ws = [w('In', in, 'ADP', [], 3, case), w(a, a, 'DET', ['Definite'='Ind'], 3, det),
                       w(Nom, Nom, 'NOUN', [], 7, obl), w(',', ',', 'PUNCT', [], 7, punct),
                       w(a, a, 'DET', ['Definite'='Ind'], 6, det), w(man, man, 'NOUN', [], 7, nsubj),
                       w(sits, sit, 'VERB', [], 0, root)].
spectateur(Ws) :- Ws = [w('The', the, 'DET', ['Definite'='Def'], 2, det), w(viewer, viewer, 'NOUN', [], 3, nsubj),
                        w(looks, look, 'VERB', [], 0, root)].
maniere(Ws) :- Ws = [w('A', a, 'DET', ['Definite'='Ind'], 2, det), w(cascade, cascade, 'NOUN', [], 3, nsubj),
                     w(falls, fall, 'VERB', [], 0, root), w(in, in, 'ADP', [], 6, case),
                     w(the, the, 'DET', ['Definite'='Def'], 6, det), w(manner, manner, 'NOUN', [], 3, obl),
                     w(of, of, 'ADP', [], 8, case), w('Poussin', 'Poussin', 'PROPN', [], 6, nmod)].
vasari(Ws) :- Ws = [w('According', accord, 'VERB', ['VerbForm'='Ger'], 3, case), w(to, to, 'ADP', [], 1, fixed),
                    w('Vasari', 'Vasari', 'PROPN', [], 7, obl), w(',', ',', 'PUNCT', [], 7, punct),
                    w(the, the, 'DET', ['Definite'='Def'], 6, det), w(bishop, bishop, 'NOUN', [], 7, nsubj),
                    w(holds, hold, 'VERB', [], 0, root), w(a, a, 'DET', ['Definite'='Ind'], 9, det),
                    w(book, book, 'NOUN', [], 7, obj)].
question(Ws) :- Ws = [w('We', we, 'PRON', [], 2, nsubj), w(ask, ask, 'VERB', [], 0, root),
                      w(whether, whether, 'SCONJ', [], 6, mark), w(the, the, 'DET', ['Definite'='Def'], 5, det),
                      w(boy, boy, 'NOUN', [], 6, nsubj), w(falls, fall, 'VERB', [], 2, ccomp),
                      w(or, or, 'CCONJ', [], 8, cc), w(plays, play, 'VERB', [], 6, conj)].
terre(Ws) :- Ws = [w('The', the, 'DET', ['Definite'='Def'], 2, det), w(land, land, 'NOUN', [], 4, nsubj),
                   w(perhaps, perhaps, 'ADV', [], 4, advmod), w(appears, appear, 'VERB', [], 0, root)].
inscription(Ws) :- Ws = [w('No', no, 'DET', [], 2, det), w(inscription, inscription, 'NOUN', [], 3, nsubj),
                         w(explains, explain, 'VERB', [], 0, root), w(them, they, 'PRON', [], 3, obj)].
os(Ws) :- Ws = [w('The', the, 'DET', ['Definite'='Def'], 2, det), w(bone, bone, 'NOUN', [], 4, 'nsubj:pass'),
                w(is, be, 'AUX', [], 4, 'aux:pass'), w(drawn, draw, 'VERB', ['VerbForm'='Part'], 0, root),
                w(',', ',', 'PUNCT', [], 8, punct), w(not, not, 'PART', [], 8, advmod),
                w(the, the, 'DET', ['Definite'='Def'], 8, det), w(body, body, 'NOUN', [], 2, conj)].

portee(Fs, E, P) :- memberchk(portee(E, P), Fs).
:- begin_tests(surete_lecteur).

% X1 : les nombres
test(nombre_dit) :-
    anges(Ws), lire([nombres], 'Two angels sing.', Ws, Fs), memberchk(nombre(e_1_2, 2), Fs),
    lire([], 'Two angels sing.', Ws, F0), \+ memberchk(nombre(_, _), F0).

% X2 : l'auteur, ses actes, la désignation
test(le_peintre_et_ses_actes) :-
    peintre(Ws), T = 'The painter places the figure.',
    lire([portees], T, Ws, Fs), portee(Fs, e_1_2, histoire), portee(Fs, v_1_3, oeuvre),
    lire([], T, Ws, F0), portee(F0, e_1_2, represente), portee(F0, v_1_3, represente).
test(un_peintre_est_une_figure) :-
    un_peintre(Ws), lire([portees], 'A painter sits.', Ws, Fs), portee(Fs, e_1_2, represente).
% la polysémie : figure n'est une création que dans un de ses sens ; l'option certain ne la prend pas
test(polyseme_seulement_possible) :-
    peintre(Ws), T = 'The painter places the figure.',
    lire([portees], T, Ws, Fs), portee(Fs, e_1_5, oeuvre),
    lire([portees, certain], T, Ws, Fc), portee(Fc, e_1_5, represente).
% le sujet d'un verbe de figuration ; pas celui qui montre quelque chose à quelqu'un
test(sujet_de_figuration) :-
    affiche(Ws), lire([portees], 'A poster shows a woman.', Ws, Fs), portee(Fs, e_1_2, oeuvre), portee(Fs, e_1_5, represente),
    lire([], 'A poster shows a woman.', Ws, F0), portee(F0, e_1_2, represente).
test(montrer_a_quelqu_un_est_une_action) :-
    montre_lui(Ws), lire([portees], 'The woman shows him a book.', Ws, Fs), portee(Fs, e_1_2, represente).
% le contenant de la scène : une œuvre certaine ; pas un lieu de la scène (ground : possible seulement), sauf doute
test(contenant_de_la_scene) :-
    dans(painting, W1), lire([portees], 'In a painting, a man sits.', W1, F1), portee(F1, e_1_3, oeuvre),
    portee(F1, e_1_6, represente),
    dans(ground, W2), lire([portees], 'In a ground, a man sits.', W2, F2), portee(F2, e_1_3, represente),
    lire([portees, doute], 'In a ground, a man sits.', W2, F3), portee(F3, e_1_3, oeuvre).
% le discours sur l'œuvre et le style
test(spectateur_et_style) :-
    spectateur(W1), lire([portees], 'The viewer looks.', W1, F1), portee(F1, e_1_2, non_ancre),
    maniere(W2), T = 'A cascade falls in the manner of Poussin.',
    lire([portees], T, W2, F2), portee(F2, e_1_6, non_ancre), portee(F2, e_1_8, non_ancre), portee(F2, e_1_2, represente),
    lire([], T, W2, F0), portee(F0, e_1_8, represente).
% les sources citées
test(selon_vasari) :-
    vasari(Ws), T = 'According to Vasari, the bishop holds a book.',
    lire([citations], T, Ws, Fs), memberchk(enonciateur(v_1_7, cite('Vasari')), Fs),
    memberchk(enonciateur(e_1_9, cite('Vasari')), Fs), memberchk(enonciateur(e_1_3, auteur), Fs),
    lire([], T, Ws, F0), memberchk(enonciateur(v_1_7, auteur), F0).

% X3 : la question indirecte, l'alternative d'événements, l'existence modalisée, la double négation, le nom nié
test(question_indirecte) :-
    question(Ws), T = 'We ask whether the boy falls or plays.',
    lire([modalites], T, Ws, Fs), memberchk(modalite(v_1_6, non_affirme), Fs), memberchk(modalite(v_1_8, non_affirme), Fs),
    memberchk(alternative(g_1_6, [v_1_6, v_1_8]), Fs), memberchk(modalite(v_1_2, affirme), Fs),
    lire([], T, Ws, F0), memberchk(modalite(v_1_6, affirme), F0), \+ memberchk(alternative(_, _), F0).
test(existence_modalisee) :-
    terre(Ws), T = 'The land perhaps appears.',
    lire([modalites], T, Ws, Fs), memberchk(modalite(e_1_2, possible), Fs),
    lire([], T, Ws, F0), memberchk(modalite(e_1_2, affirme), F0).
test(double_negation) :-
    inscription(Ws), T = 'No inscription explains them.',
    lire([modalites], T, Ws, Fs), memberchk(modalite(v_1_3, non_affirme), Fs), memberchk(polarite(e_1_2, neg), Fs),
    lire([], T, Ws, F0), memberchk(modalite(v_1_3, affirme), F0).
test(groupe_nominal_nie) :-
    os(Ws), T = 'The bone is drawn, not the body.',
    lire([negations], T, Ws, Fs), memberchk(polarite(e_1_8, neg), Fs), memberchk(polarite(e_1_2, pos), Fs),
    lire([], T, Ws, F0), memberchk(polarite(e_1_8, pos), F0).

:- end_tests(surete_lecteur).
