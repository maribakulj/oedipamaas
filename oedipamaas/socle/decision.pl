/*  La décision (conception 1.0, § 9), exécutée par Prolog sur les faits compilés depuis un apprentissage
    (compiler_decision.py, module decision_poids).

    p_catalogue(Traits, P) : probabilité que le code (ou un de ses descendants) soit au catalogue, à partir des traits
    de preuve du candidat (paires Nom-Valeur ; un trait absent vaut 0) : la base, plus la feuille atteinte dans chaque
    arbre (à gauche si la valeur est ≤ au seuil), puis la sigmoïde.
    retenus(Candidats, Codes) : sélection par le réglage appris (les k premiers de p ≥ seuil, classés par p ou par
    l'espérance p × (profondeur + 1)), puis les plus spécifiques (un ancêtre d'un code retenu n'est pas répété), sans
    la division 86 (comme la mesure).
*/
:- module(decision, [ p_catalogue/2,  % +Traits, -P
                      retenus/2       % +Liste de c(Notation, P, Traits), -Codes
                    ]).

valeur(Traits, T, V) :- ( memberchk(T-V0, Traits) -> V = V0 ; V = 0 ).

feuille_atteinte(Traits, A, N, V) :-
    (   decision_poids:feuille(A, N, V0)
    ->  V = V0
    ;   decision_poids:noeud(A, N, T, Seuil, G, D),
        valeur(Traits, T, X),
        ( X =< Seuil -> Suivant = G ; Suivant = D ),
        feuille_atteinte(Traits, A, Suivant, V)
    ).

p_catalogue(Traits, P) :-
    decision_poids:base(B),
    aggregate_all(sum(V), ( arbre(A), feuille_atteinte(Traits, A, 0, V) ), S),
    Z is B + S,
    P is 1 / (1 + exp(-Z)).

% chaque arbre a un nœud 0 : une division, ou une feuille seule
arbre(A) :- distinct(A, ( decision_poids:noeud(A, 0, _, _, _, _) ; decision_poids:feuille(A, 0, _) )).

retenus(Candidats, Codes) :-
    decision_poids:reglage(K, Seuil, Critere),
    findall(V-N, ( member(c(N, P, Traits), Candidats), P >= Seuil, cle_tri(Critere, P, Traits, V) ), Vs),
    sort(1, @>=, Vs, Tries),
    length(Tries, L), K1 is min(K, L), length(Premiers, K1), append(Premiers, _, Tries),
    pairs_values(Premiers, Ns),
    plus_specifiques(Ns, Codes0),
    exclude(division_86, Codes0, Codes).

cle_tri(esperance, P, Traits, V) :- !, valeur(Traits, prof, Prof), V is P * (Prof + 1).
cle_tri(_, P, _, P).

plus_specifiques(Ns, Codes) :-
    include([N]>>( \+ ( member(M, Ns), M \== N, notation:ancetre_syntaxique(M, N) ) ), Ns, Codes).

division_86(N) :- sub_atom(N, 0, 2, _, '86').
