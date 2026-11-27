/*  La normalisation des nominalisations (docs/PLAN_V1.md, C7.3) : une couche de langue, hors du noyau.

    NEUTRALISÉE (lot 2, 27/11 ; docs/QUALIFICATION_NOYAU.md, § 10, L2) : chaque règle a un statut épistémique
    (regle/3) ; aucune n'est une inférence certaine (le participant unique n'est pas à la fois agent, thème et
    patient ; le complément d'un nom d'action n'est pas toujours son patient ; une dérivation n'est pas toujours une
    équivalence ; un composé ne dit pas que son complément est figuré). enrichir/3 n'applique que les règles
    certaines : il rend le graphe inchangé. Les règles hypothétiques ne s'appliquent que sur demande (enrichir/4,
    regles(toutes)), jamais pour certifier ; le lot 3 leur donnera une provenance et le statut d'hypothèse.

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

    Les rôles (C7.3) : le patient et le thème (ce qui subit l'action, ce qui se déplace ou change) ne se distinguent
    pas sûrement, ni par le lecteur ni par un annotateur : chacun donne aussi l'autre. Le participant unique d'un
    événement (« l'arche flotte ») est l'agent ou le thème selon le verbe, que la syntaxe ne dit pas : il reçoit les
    deux. L'agent d'un événement à deux participants reste distinct : « Goliath tranche la tête de David » n'est pas
    « David tranche la tête de Goliath ».

    Les composés en « de », « of » que la langue ne lexicalise pas (« chaland de trait » n'est ni dans WordNet ni
    dans WOLF) ne sont pas une unité : une entité de ce type reçoit aussi la structure (une entité « chaland », une
    entité « trait », la relation de). Un composé lexicalisé (« mal de tête ») reste une unité.

    Le complément du nom d'action est lu comme le patient (« training of dogs », « dressage des chiens ») : la lecture
    usuelle du génitif d'un verbe transitif. Pour un verbe intransitif (« death of Anna »), elle est fausse ; elle se
    mesure (docs/mesures/V2.md).
*/
:- module(normalisation, [ enrichir/3, enrichir/4, regle/3, nominalisation/3 ]).
:- encoding(utf8).
:- use_module(library(lists)).
:- use_module(library(apply)).
:- discontiguous ajout/4.      % chaque règle est écrite avec ses prédicats auxiliaires

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

% --- Le statut épistémique des règles (lot 2 de la phase C3/C6/C7, décision du 27/11) --------------------------------
%
% regle(Nom, Statut, Raison) : Statut est certaine (une inférence valide : ce qu'elle ajoute est vrai partout où ses
% prémisses le sont) ou hypothetique (une lecture plausible, qui peut être fausse). Une règle hypothétique ne doit
% jamais introduire une prémisse que le noyau certifie : enrichir/3 n'applique que les règles certaines. Les règles
% hypothétiques ne s'appliquent que sur demande explicite (enrichir/4, regles(toutes)) : pour mesurer, et pour le lot 3,
% qui leur donnera une provenance et un statut d'hypothèse dans le graphe. Aucune des règles actuelles n'est certaine.
regle(r1, hypothetique, 'patient et thème ne sont pas équivalents (« la barque porte l’homme » : l’homme est le thème, rien ne le subit)').
regle(r2, hypothetique, 'le participant unique est l’agent ou le thème selon le verbe, jamais les deux (« l’arche flotte » : thème ; « l’homme court » : agent)').
regle(p1, hypothetique, 'un participe lu comme propriété dit un événement dont le rôle du référent dépend du verbe (« fallen angel » : thème ; « praying figure » : agent)').
regle(c1, hypothetique, 'un composé en « de » non lexicalisé ne dit pas que son complément est figuré (« chaland de trait » : il n’y a pas de trait dans l’image) ni que la tête est un hyperonyme sûr').
regle(e1, hypothetique, 'un nom dérivé d’un verbe n’en est pas toujours le nom d’action (« building » : le bâtiment ; « drawing » : le dessin), et le complément du nom n’est pas toujours le patient (« death of Anna » : Anna meurt)').
regle(e2, hypothetique, 'même raison que e1, dans l’autre sens : un nom d’action n’est pas toujours l’événement figuré, ni son complément le patient').

enrichir(L, G0, G) :- enrichir(L, [], G0, G).
% Options : regles(certaines) (par défaut) | regles(toutes) (les hypothétiques aussi : jamais pour certifier)
enrichir(L, Opts, G0, G) :-
    ( memberchk(regles(toutes), Opts) -> Statuts = [certaine, hypothetique] ; Statuts = [certaine] ),
    hors_alternatives(G0, Gs),
    findall(F, ( regle(R, St, _), memberchk(St, Statuts), ajout(R, L, Gs, F) ), Fs0), sort(Fs0, Fs),
    append(G0, Fs, G1), sort(G1, G2),
    findall(F, ( regle(R, St, _), memberchk(St, Statuts), ajout_de_role(R, G2, F) ), Rs0), sort(Rs0, Rs),
    append(G2, Rs, G3), sort(G3, G).

% R1 : patient et thème
ajout_de_role(r1, G, role(V, R2, X)) :-
    member(role(V, R1, X), G), ( R1 == patient -> R2 = theme ; R1 == theme -> R2 = patient ).
% R2 : le participant unique d'un événement est agent, thème et patient (la syntaxe ne dit pas lequel)
ajout_de_role(r2, G, role(V, R2, X)) :-
    member(evenement(V, _, _), G), findall(R-Y, member(role(V, R, Y), G), [_-X]),
    member(R2, [agent, theme, patient]).
% P1 : un participe lu comme propriété (« swimming mammal », « sitting figure ») : le verbe est un événement dont le
% référent est le participant unique ; un mot qui est aussi un adjectif de la langue reste une propriété seulement
ajout(p1, L, G, F) :-
    member(propriete(Q, X, P, Pa), G), atom(P), verbe_seulement(L, P),
    format(atom(Ev), "vp_~w", [Q]),
    ( F = evenement(Ev, P, Pa) ; F = role(Ev, theme, X) ; qualificatif(G, Q, Ev, F) ).
verbe_seulement(en, P) :- wordnet:s(_, _, P, v, _, _), \+ wordnet:s(_, _, P, a, _, _), \+ wordnet:s(_, _, P, s, _, _), !.
verbe_seulement(fr, P) :- ressources:wolf(S, P), S // 100000000 =:= 2,
    \+ ( ressources:wolf(S2, P), S2 // 100000000 =:= 3 ), !.
% C1 : un composé en « de » ou « of » non lexicalisé reçoit sa structure
ajout(c1, L, G, F) :-
    member(entite(E, W, Pa), G), atom(W), W \== nom_propre, compose_libre(L, W, A, B),
    format(atom(Ea), "ca_~w", [E]), format(atom(Eb), "cb_~w", [E]), format(atom(R), "cr_~w", [E]), genitif(L, Ge),
    (   F = entite(Ea, A, Pa) ; F = entite(Eb, B, Pa) ; F = relation(R, Ea, Ge, Eb, Pa)
    ;   member(X, [Ea, Eb, R]), qualificatif(G, E, X, F)
    ;   F = coref(E, Ea)
    ).
compose_libre(L, W, A, B) :-
    member(Sep, [' de ', ' du ', ' des ', ' d\'', ' of ']), sub_atom(W, Av, Ls, Ap, Sep), !,
    \+ lexicalise(L, W),
    sub_atom(W, 0, Av, _, A0), Debut is Av + Ls, sub_atom(W, Debut, Ap, 0, B0),
    retirer_article(A0, A), retirer_article(B0, B), A \== '', B \== ''.
retirer_article(X0, X) :-
    ( member(Art, ['la ', 'le ', 'les ', 'l\'', 'the ']), atom_concat(Art, X1, X0) -> X = X1 ; X = X0 ).
lexicalise(en, W) :- wordnet:s(_, _, W, n, _, _), !.
lexicalise(fr, W) :- ressources:wolf(S, W), S // 100000000 =:= 1, !.

% E1 : un événement donne son nom d'action
ajout(e1, L, G, F) :-
    member(evenement(V, P, Pa), G), atom(P), nominalisation(L, P, N),
    format(atom(E), "nv_~w_~w", [V, N]),
    (   F = entite(E, N, Pa)
    ;   qualificatif(G, V, E, F)
    ;   member(role(V, R, Y), G), memberchk(R, [patient, theme]), genitif(L, Ge),
        format(atom(A), "nr_~w_~w_~w", [V, N, Y]),
        ( F = relation(A, E, Ge, Y, Pa) ; qualificatif(G, V, A, F) )
    ).
% E2 : un nom d'action donne son événement
ajout(e2, L, G, F) :-
    member(entite(E, N, Pa), G), atom(N), N \== nom_propre, nominalisation(L, V, N),
    format(atom(Ev), "ve_~w_~w", [E, V]),
    (   F = evenement(Ev, V, Pa)
    ;   qualificatif(G, E, Ev, F)
    ;   member(relation(_, E2, R, Y, _), G), genitif_lu(L, R), meme_referent(G, E, E2), F = role(Ev, patient, Y)
    ).

% deux entités d'une même classe de coréférence (le complément d'un nom d'action peut être rattaché à une autre
% mention du même référent)
meme_referent(_, E, E) :- !.
meme_referent(G, E1, E2) :- atteint_coref(G, [E1], [E1], E2).
atteint_coref(_, _, Vus, E) :- memberchk(E, Vus), !.
atteint_coref(G, Front, Vus, E) :-
    findall(Y, ( member(X, Front), ( member(coref(X, Y), G) ; member(coref(Y, X), G) ), \+ memberchk(Y, Vus) ), Ys0),
    sort(Ys0, Ys), Ys \== [], append(Vus, Ys, Vus1), atteint_coref(G, Ys, Vus1, E).

qualificatif(G, De, A, F) :-
    member(Q, G), Q =.. [P, De, X], memberchk(P, [polarite, modalite, portee, enonciateur]), F =.. [P, A, X].
% une assertion d'une alternative (une hypothèse parmi d'autres) n'est pas enrichie : elle n'appuie rien (NOYAU § 1)
hors_alternatives(G, Gs) :-
    findall(A, ( member(alternative(_, As), G), member(A, As) ), Alts),
    exclude(membre_alternatif(Alts), G, Gs).
membre_alternatif(Alts, F) :- F =.. [P, A|_], memberchk(P, [entite, evenement, propriete, relation, nom]), memberchk(A, Alts).
