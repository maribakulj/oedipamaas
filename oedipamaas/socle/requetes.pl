/*  Le langage des requêtes du noyau (docs/NOYAU.md, § 3) : forme et parcours.

    bien_formee(+Requete, -Erreurs)     Erreurs = [] si la requête est bien formée
    atomes(+Formule, -Atomes)           [Chemin-Atome] de tous les atomes et contraintes, dans l'ordre de la formule
    sous_formule(+Formule, +Chemin, -F) la sous-formule à cette position (indices à partir de 1)
    variables(+Terme, -Vs)              les variables v(_) d'un terme, sans doublon
    sorte(+Formule, +V, -Sorte)         referent | evenement
*/
:- module(requetes, [ bien_formee/2, atomes/2, sous_formule/3, variables/2, sorte/3, atome/1, contrainte/1 ]).
:- encoding(utf8).
:- use_module(library(lists)).
:- use_module(library(apply)).

atome(type(_, _)).
atome(nom(_, _)).
atome(propriete(_, _)).
atome(evenement(_, _)).
atome(role(_, _, _)).
atome(relation(_, _, _)).
atome(genre(_)).
contrainte(meme(_, _)).
contrainte(distincts(_, _)).
contrainte(nombre(_, _)).

roles([agent, patient, theme, instrument, destinataire, lieu]).

atomes(F, As) :- atomes(F, [], As0), reverse(As0, As1), As = As1.
atomes(F, Ch, As) :- atomes_(F, Ch, [], As).
atomes_(et(Fs), Ch, A0, A) :- !, enfants(Fs, Ch, 1, A0, A).
atomes_(ou(Fs), Ch, A0, A) :- !, enfants(Fs, Ch, 1, A0, A).
atomes_(F, Ch, A0, [C-F|A0]) :- reverse(Ch, C).
enfants([], _, _, A, A).
enfants([F|Fs], Ch, I, A0, A) :- atomes_(F, [I|Ch], A0, A1), I1 is I + 1, enfants(Fs, Ch, I1, A1, A).

sous_formule(F, [], F) :- !.
sous_formule(et(Fs), [I|Is], G) :- !, nth1(I, Fs, F), sous_formule(F, Is, G).
sous_formule(ou(Fs), [I|Is], G) :- nth1(I, Fs, F), sous_formule(F, Is, G).

variables(T, Vs) :- findall(V, sous_terme_variable(T, V), Vs0), list_to_set(Vs0, Vs).
sous_terme_variable(v(N), v(N)) :- !.
sous_terme_variable(T, V) :- compound(T), T \= v(_), T =.. [_|As], member(A, As), sous_terme_variable(A, V).

sorte(F, V, evenement) :- atomes(F, As), ( member(_-evenement(V, _), As) ; member(_-role(V, _, _), As) ), !.
sorte(_, _, referent).

bien_formee(requete(Id, F), Es) :- !,
    findall(E, erreur(F, E), Es0),
    ( atom(Id) -> Es = Es0 ; Es = [identifiant(Id)|Es0] ).
bien_formee(R, [pas_une_requete(R)]).

erreur(F, forme(G)) :- sous_terme_formule(F, G), \+ forme_connue(G).
erreur(F, ou_a_une_branche(G)) :- sous_terme_formule(F, G), G = ou(Fs), length(Fs, L), L < 2.
erreur(F, et_vide) :- sous_terme_formule(F, et([])).
erreur(F, variable_sans_atome(V)) :-
    atomes(F, As), variables(F, Vs), member(V, Vs),
    \+ ( member(_-A, As), atome(A), variables(A, Va), memberchk(V, Va) ).
erreur(F, deux_sortes(V)) :-
    atomes(F, As), variables(F, Vs), member(V, Vs),
    ( member(_-evenement(V, _), As) ; member(_-role(V, _, _), As) ),
    ( member(_-type(V, _), As) ; member(_-nom(V, _), As) ; member(_-propriete(V, _), As)
    ; member(_-role(_, _, V), As) ; member(_-relation(V, _, _), As) ; member(_-relation(_, _, V), As) ).
erreur(F, role_inconnu(R)) :- atomes(F, As), member(_-role(_, R, _), As), roles(Rs), \+ memberchk(R, Rs).
erreur(F, argument(A)) :- atomes(F, As), member(_-A, As), \+ arguments_valides(A).

forme_connue(et(L)) :- is_list(L).
forme_connue(ou(L)) :- is_list(L).
forme_connue(A) :- atome(A).
forme_connue(C) :- contrainte(C).

sous_terme_formule(F, F).
sous_terme_formule(et(Fs), G) :- is_list(Fs), member(F, Fs), sous_terme_formule(F, G).
sous_terme_formule(ou(Fs), G) :- is_list(Fs), member(F, Fs), sous_terme_formule(F, G).

arguments_valides(type(v(_), T)) :- atom(T).
arguments_valides(nom(v(_), Ks)) :- is_list(Ks), Ks \== [], maplist(atom, Ks).
arguments_valides(propriete(v(_), P)) :- atom(P).
arguments_valides(evenement(v(_), P)) :- atom(P).
arguments_valides(role(v(_), R, v(_))) :- atom(R).
arguments_valides(relation(v(_), R, v(_))) :- atom(R).
arguments_valides(genre(T)) :- atom(T).
arguments_valides(meme(v(_), v(_))).
arguments_valides(distincts(v(_), v(_))).
arguments_valides(nombre(v(_), K)) :- integer(K), K >= 1.
