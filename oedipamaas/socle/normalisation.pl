/*  La normalisation des nominalisations (docs/PLAN_V1.md, C7.3) : une couche de langue, hors du noyau.

    enrichir(+Langue, +Graphe0, -Graphe)
        Ajoute à un graphe d'assertions la forme équivalente de chaque action dite par un verbe ou par un nom d'action :
          E1  un événement de prédicat V (« le chien est dressé ») donne aussi une entité de type N, le nom d'action de V
              (« dressage »), et son patient devient le complément de ce nom (« dressage du chien » : relation de, of) ;
          E2  une entité de type N, nom d'action d'un verbe V (« training of dogs »), donne aussi un événement de
              prédicat V, et le complément du nom (of, de) devient son patient.
        Les assertions ajoutées ont les qualificatifs de celle dont elles viennent (polarité, modalité, portée,
        énonciateur), et le même passage : elles disent la même chose, autrement. L'enrichissement n'est fait qu'une
        fois, sur les assertions d'origine.

    nominalisation(+Langue, ?Verbe, ?Nom)
        Nom est un nom d'action de Verbe : un lien de dérivation de WordNet (der/4) entre un sens verbal et un sens
        nominal qui est une action, un événement, un processus ou un phénomène (lexfile noun.act, noun.event,
        noun.process, noun.phenomenon : ni l'agent « trainer », ni l'instrument, ni la matière « dye »), ou un lien
        morphosémantique de type « event » ; en français, les mêmes liens entre les synsets de WOLF.

    Le complément du nom d'action est lu comme le patient (« training of dogs », « dressage des chiens ») : la lecture
    usuelle du génitif d'un verbe transitif. Pour un verbe intransitif (« death of Anna »), elle est fausse ; elle se
    mesure (docs/mesures/V2.md).
*/
:- module(normalisation, [ enrichir/3, nominalisation/3 ]).
:- encoding(utf8).
:- use_module(library(lists)).
:- use_module(library(apply)).

lexfile_d_action(F) :- memberchk(F, ['noun.act', 'noun.event', 'noun.process', 'noun.phenomenon']).

:- table nominalisation/3.
nominalisation(en, V, N) :-
    wordnet:s(Sv, Wv, V, v, _, _), ( wordnet:der(Sv, Wv, Sn, Wn) ; wordnet:der(Sn, Wn, Sv, Wv) ),
    wordnet:s(Sn, Wn, N, n, _, _), wordnet:lexfile(Sn, F), lexfile_d_action(F).
nominalisation(en, V, N) :- ressources:morphosem(_, V, event, _, N).
nominalisation(fr, V, N) :-
    ressources:wolf(Sv, V), Sv // 100000000 =:= 2,
    ( wordnet:der(Sv, _, Sn, _) ; wordnet:der(Sn, _, Sv, _) ; ressources:morphosem(Sv, _, event, Sn, _) ),
    Sn // 100000000 =:= 1, wordnet:lexfile(Sn, F), lexfile_d_action(F), ressources:wolf(Sn, N).

genitif(en, of).
genitif(fr, de).
genitif_lu(en, R) :- R == of.
genitif_lu(fr, R) :- memberchk(R, [de, du, des, 'd\'', 'd’']).

enrichir(L, G0, G) :-
    findall(F, ajout(L, G0, F), Fs0), sort(Fs0, Fs),
    append(G0, Fs, G1), sort(G1, G).

% E1 : un événement donne son nom d'action
ajout(L, G, F) :-
    member(evenement(V, P, Pa), G), atom(P), nominalisation(L, P, N),
    format(atom(E), "nv_~w_~w", [V, N]),
    (   F = entite(E, N, Pa)
    ;   qualificatif(G, V, E, F)
    ;   member(role(V, R, Y), G), memberchk(R, [patient, theme]), genitif(L, Ge),
        format(atom(A), "nr_~w_~w_~w", [V, N, Y]),
        ( F = relation(A, E, Ge, Y, Pa) ; qualificatif(G, V, A, F) )
    ).
% E2 : un nom d'action donne son événement
ajout(L, G, F) :-
    member(entite(E, N, Pa), G), atom(N), N \== nom_propre, nominalisation(L, V, N),
    format(atom(Ev), "ve_~w_~w", [E, V]),
    (   F = evenement(Ev, V, Pa)
    ;   qualificatif(G, E, Ev, F)
    ;   member(relation(_, E, R, Y, _), G), genitif_lu(L, R), F = role(Ev, patient, Y)
    ).

qualificatif(G, De, A, F) :-
    member(Q, G), Q =.. [P, De, X], memberchk(P, [polarite, modalite, portee, enonciateur]), F =.. [P, A, X].
qualificatif(G, De, A, alternative(Gr, [A|As])) :- member(alternative(Gr, As), G), memberchk(De, As).
