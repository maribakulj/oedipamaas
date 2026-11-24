/*  Tests du langage d'assertions (docs/ASSERTIONS.md) : « Saint Jérôme sans son lion ». */
:- use_module('../../oedipamaas/socle/assertions').
:- use_module(library(plunit)).
:- encoding(utf8).

q(A, Pol, Mod, Por, Qui, [polarite(A, Pol), modalite(A, Mod), portee(A, Por), enonciateur(A, Qui)]).

% « Saint Jérôme, sans son lion. » : e1 saint, nommé Jérôme ; e2 lion, nié
jerome(Fs) :-
    q(e1, pos, affirme, represente, auteur, Q1),
    q(n1, pos, affirme, represente, auteur, Q2),
    q(e2, neg, affirme, represente, auteur, Q3),
    append([[texte("Saint Jérôme, sans son lion."), doc(fr, cartel),
             passage(p1, 0, 12), passage(p2, 23, 27),
             entite(e1, saint, p1), nom(n1, e1, 'Jérôme', p1), entite(e2, lion, p2)], Q1, Q2, Q3], Fs).

:- begin_tests(assertions).

test(valide) :-
    jerome(Fs), assertions:valider(Fs, E), E == [].

test(admissibles, [set(A == [e1, n1])]) :-
    jerome(Fs), assertions:admissible(Fs, A).

test(contredit, [all(A == [e2])]) :-
    jerome(Fs), assertions:contredit(Fs, A).

test(qualificatif_manquant) :-
    jerome(Fs0), exclude(==(modalite(n1, affirme)), Fs0, Fs),
    assertions:valider(Fs, E), memberchk(qualificatif(modalite, n1, nombre(0)), E).

test(qualificatif_double) :-
    jerome(Fs0), assertions:valider([modalite(n1, possible)|Fs0], E),
    memberchk(qualificatif(modalite, n1, nombre(2)), E).

test(valeur_interdite) :-
    jerome(Fs0), once(select(portee(e2, represente), Fs0, portee(e2, ailleurs), Fs)),
    assertions:valider(Fs, E), memberchk(qualificatif(portee, e2, valeur(ailleurs)), E).

test(passage_hors_bornes) :-
    jerome(Fs0), once(select(passage(p2, 23, 27), Fs0, passage(p2, 23, 99), Fs)),
    assertions:valider(Fs, E), memberchk(passage(p2, hors_bornes), E).

test(entite_inconnue) :-
    jerome(Fs0), assertions:valider([propriete(x1, e9, nu, p1)|Fs0], E),
    memberchk(entite_inconnue(propriete(x1, e9, nu, p1)), E).

test(terme_inconnu) :-
    jerome(Fs0), assertions:valider([vu(e1)|Fs0], E), memberchk(inconnu(vu(e1)), E).

% une identification traditionnelle n'est pas admissible, et le nom d'une entité non admissible non plus
test(modalite_et_entite) :-
    jerome(Fs0), once(select(modalite(e1, affirme), Fs0, modalite(e1, traditionnel), Fs)),
    assertions:valider(Fs, []),
    \+ assertions:admissible(Fs, e1), \+ assertions:admissible(Fs, n1).

% deux hypothèses exclusives : aucune n'est admissible
test(alternative) :-
    jerome(Fs0), assertions:valider([alternative(g1, [e1, e2])|Fs0], []),
    \+ assertions:admissible([alternative(g1, [e1, e2])|Fs0], e1).

test(alternative_courte) :-
    jerome(Fs0), assertions:valider([alternative(g1, [e1])|Fs0], E), memberchk(alternative(g1, moins_de_deux), E).

% les rôles d'un événement : l'événement n'est admissible que si ses participants le sont
test(evenement) :-
    jerome(Fs0),
    q(v1, pos, affirme, represente, auteur, Qv),
    append([[evenement(v1, tenir, p1), role(v1, agent, e1), role(v1, theme, e2)], Qv, Fs0], Fs),
    assertions:valider(Fs, []),
    \+ assertions:admissible(Fs, v1).          % le lion (thème) est nié

test(identifiant_double) :-
    jerome(Fs0), assertions:valider([entite(e1, homme, p1)|Fs0], E), memberchk(identifiant_double(e1), E).

:- end_tests(assertions).
