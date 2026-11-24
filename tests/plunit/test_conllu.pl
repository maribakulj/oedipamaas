/*  Lecture du CoNLL-U (socle/conllu.pl) et appel d'UDPipe (socle/udpipe.pl, si OEDIPAMAAS_UDPIPE et
    OEDIPAMAAS_MODELES sont définis). */
:- use_module('../../oedipamaas/socle/conllu').
:- use_module('../../oedipamaas/socle/udpipe').
:- use_module(library(plunit)).
:- encoding(utf8).

% « Le chien du berger. » : « du » est un mot composé (de + le), ses deux mots prennent ses positions
exemple("# text = Le chien du berger.\n\c
1\tLe\tle\tDET\t_\tDefinite=Def|Number=Sing\t2\tdet\t_\tTokenRange=0:2\n\c
2\tchien\tchien\tNOUN\t_\tNumber=Sing\t0\troot\t_\tTokenRange=3:8\n\c
3-4\tdu\t_\t_\t_\t_\t_\t_\t_\tTokenRange=9:11\n\c
3\tde\tde\tADP\t_\t_\t5\tcase\t_\t_\n\c
4\tle\tle\tDET\t_\t_\t5\tdet\t_\t_\n\c
5\tberger\tberger\tNOUN\t_\t_\t2\tnmod\t_\tSpaceAfter=No|TokenRange=12:18\n\c
6\t.\t.\tPUNCT\t_\t_\t2\tpunct\t_\tTokenRange=18:19\n\n\c
1\tFin\tfin\tNOUN\t_\t_\t0\troot\t_\t_\n").

udpipe_configure :- getenv('OEDIPAMAAS_UDPIPE', _), getenv('OEDIPAMAAS_MODELES', _).

:- begin_tests(conllu).

test(deux_phrases) :-
    exemple(T), conllu:conllu_phrases(T, Ps), length(Ps, 2).

test(mots_et_positions) :-
    exemple(T), conllu:conllu_phrases(T, [phrase(Ms)|_]),
    length(Ms, 6),
    memberchk(mot(2, chien, chien, 'NOUN', ['Number'='Sing'], 0, root, 3, 8), Ms),
    memberchk(mot(3, de, de, 'ADP', [], 5, case, 9, 11), Ms),          % positions du jeton composé
    memberchk(mot(5, berger, berger, 'NOUN', [], 2, nmod, 12, 18), Ms).

test(sans_positions) :-
    exemple(T), conllu:conllu_phrases(T, [_, phrase([mot(1, 'Fin', fin, 'NOUN', [], 0, root, -1, -1)])]).

test(vide) :- conllu:conllu_phrases("", []).

:- end_tests(conllu).

:- begin_tests(udpipe, [condition(udpipe_configure)]).

% voix passive : le sujet passif et l'agent (« par David ») ; positions dans le texte
test(passif_fr) :-
    T = "Goliath est tué par David.",
    udpipe:analyser(T, fr, [phrase(Ms)]),
    memberchk(mot(_, 'Goliath', _, 'PROPN', _, V, 'nsubj:pass', 0, 7), Ms),
    memberchk(mot(V, _, tuer, _, _, 0, root, _, _), Ms),
    memberchk(mot(_, 'David', _, _, _, V, 'obl:agent', 20, 25), Ms).

test(passif_en) :-
    udpipe:analyser("Goliath is killed by David.", en, [phrase(Ms)]),
    memberchk(mot(_, 'Goliath', _, _, _, V, 'nsubj:pass', _, _), Ms),
    memberchk(mot(V, _, kill, _, _, 0, root, _, _), Ms).

test(positions_unicode) :-
    T = "Saint Jérôme et son lion.",
    udpipe:analyser(T, fr, [phrase(Ms)]),
    memberchk(mot(_, 'Jérôme', _, _, _, _, _, D, F), Ms),
    sub_string(T, D, 6, _, "Jérôme"), F - D =:= 6.

test(langue_inconnue, [throws(error(domain_error(langue, de), _))]) :-
    udpipe:analyser("Ein Hund.", de, _).

:- end_tests(udpipe).
