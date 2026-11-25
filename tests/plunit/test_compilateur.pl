/*  Tests du compilateur des libellés en requêtes (requetes_iconclass.pl) qui ne demandent aucune donnée : les règles
    pures du compilateur. Les attendus suivent docs/NOYAU.md et docs/PLAN_V1.md (C3) ; chacun a d'abord échoué.  */
:- use_module('../../oedipamaas/socle/requetes_iconclass').
:- use_module(library(plunit)).
:- encoding(utf8).

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
