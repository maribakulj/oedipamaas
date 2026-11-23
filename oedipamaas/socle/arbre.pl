/*  L'arbre d'Iconclass (conception 1.0, § 5, pièce 2), sur les faits du module iconclass (compiler_iconclass.py).

    Iconclass n'est pas un simple arbre de préfixes :
    - une notation à lettre doublée est citée comme enfant par deux parents, son préfixe (11DD3 pour 11DD31) et son
      jumeau simple (11D31) ; le premier est le parent canonique, le second le jumeau ; quand le jumeau simple est le
      seul parent cité (une subdivision doublée rangée sous la lettre simple), il est le parent ;
    - un nom listé est enfant du gabarit (11H(JEROME) est enfant de 11H(...)), non du préfixe 11H ;
    - les données ont quelques défauts (un enfant sans enregistrement, un enfant cité par deux parents qui ne sont
      ni son préfixe ni son jumeau) : le parent canonique est alors le premier parent cité.
    Les notations à clé ne sont pas énumérées : leur parent est syntaxique (notation:parent_syntaxique/2), jusqu'à la
    notation de base.
*/
:- module(arbre, [ parent/2,          % ?N, ?P   parent canonique
                   jumeau/2,          % ?N, ?J   jumeau simple d'une notation à lettre doublée (cité comme parent)
                   autre_parent/2,    % ?N, ?P   autre parent cité (défauts des données)
                   ancetre/2,         % ?N, ?A   ancêtre strict par les parents canoniques
                   ancetre_ou_soi/2,  % ?N, ?A
                   enfants/2,         % +P, -Enfants (ordre d'Iconclass)
                   racine/1,          % ?N
                   connue/1,          % ?N       notation de base ou citée comme enfant
                   valide/1,          % +N       notation de base, ou notation à clé d'une famille valable
                   profondeur_arbre/2 % +N, -D   nombre d'ancêtres
                 ]).

:- use_module(notation).

connue(N) :- iconclass:n(N).
connue(N) :- iconclass:enfant(_, N, _), \+ iconclass:n(N).

parent(N, P) :-
    (   nonvar(N)
    ->  parent_de(N, P)
    ;   iconclass:enfant(P0, N, _), parent_de(N, P), P == P0
    ).

parent_de(N, P) :-
    (   iconclass:enfant(_, N, _)
    ->  (   notation:parent_syntaxique(N, S), iconclass:enfant(S, N, _)
        ->  P = S
        ;   once((iconclass:enfant(P0, N, _), \+ jumeau_cite(N, P0)))
        ->  P = P0
        ;   once(iconclass:enfant(P, N, _))                % seul parent cité : le jumeau simple
        )
    ;   \+ iconclass:n(N), notation:analyser(N, Niveaux), Niveaux \= composee(_),
        memberchk(cle(_), Niveaux)                       % notation à clé : parent syntaxique
    ->  notation:parent_syntaxique(N, P)
    ).

jumeau(N, J) :-
    iconclass:enfant(J, N, _),
    jumeau_cite(N, J),
    \+ parent(N, J).          % quand le jumeau est le seul parent cité, il est le parent, pas un jumeau

jumeau_cite(N, J) :-
    notation:analyser(N, Niveaux),
    Niveaux \= composee(_),
    append(Avant, [double(L)|Apres], Niveaux), !,
    append(Avant, [lettre(L)|Apres], Simple),
    notation:ecrire(Simple, J0),
    J == J0.

autre_parent(N, P) :-
    iconclass:enfant(P, N, _),
    \+ parent(N, P),
    \+ jumeau(N, P).

:- table ancetre/2.
ancetre(N, A) :- parent(N, P), ( A = P ; ancetre(P, A) ).

ancetre_ou_soi(N, N).
ancetre_ou_soi(N, A) :- ancetre(N, A).

enfants(P, Enfants) :-
    findall(R-N, (iconclass:enfant(P, N, R), parent(N, P)), Paires),
    keysort(Paires, Triees),
    pairs_values(Triees, Enfants).

racine(N) :- iconclass:n(N), \+ iconclass:enfant(_, N, _).

valide(N) :- connue(N), !.
valide(N) :-
    notation:analyser(N, Niveaux),
    Niveaux \= composee(_),
    append(Base0, [cle(S)], Niveaux),
    notation:ecrire(Base0, Base),
    connue(Base),
    iconclass:famille_cle(Base, K),
    notation:ecrire_niveaux(S, Suffixe),
    iconclass:suffixe_cle(K, Suffixe, _).

profondeur_arbre(N, D) :-
    aggregate_all(count, ancetre(N, _), D).
