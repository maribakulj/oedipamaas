/*  La décision (conception 1.0, § 9), exécutée par Prolog sur les faits compilés depuis un apprentissage
    (compiler_decision.py, module decision_poids).

    p_catalogue(Traits, P) : probabilité que le code (ou un de ses descendants) soit au catalogue, à partir des traits
    de preuve du candidat (paires Nom-Valeur ; un trait absent vaut 0) : la base, plus la feuille atteinte dans chaque
    arbre (à gauche si la valeur est ≤ au seuil), puis la sigmoïde.
    retenus(Candidats, Codes) : sélection par le réglage appris (les k premiers de p ≥ seuil, classés par p ou par
    l'espérance p × (profondeur + 1)), puis les plus spécifiques (un ancêtre d'un code retenu n'est pas répété, au
    sens de l'arbre d'Iconclass : arbre:ancetre/2, avec gabarits, noms et lettres doublées), sans la division 86
    (comme la mesure).
*/
:- module(decision, [ p_catalogue/2,  % +Traits, -P
                      p_image/2,      % +Liste de c(Notation, Traits), -Liste de Notation-P (un ou deux étages)
                      prefixes/2,     % +Notation, -Prefixes (par jetons, comme la mesure ; la notation comprise)
                      retenus/2       % +Liste de c(Notation, P, Traits), -Codes
                    ]).

:- use_module(arbre).

% --- Deux étages ----------------------------------------------------------------------------------------------------

% p_image(+Candidats, -Ps) : les probabilités des candidats d'une image. Décision à un étage : p_catalogue de chacun.
% À deux étages (decision_poids:deux_etages) : le premier étage donne p1 ; la place de chaque candidat dans l'image
% d'après p1 s'ajoute à ses traits — 1/rang (p1 décroissant, puis la notation), p1 sur le plus fort p1 de l'image, le
% plus fort p1 de ses descendants candidats, le p1 de son plus proche ancêtre candidat, le nombre de candidats de son
% chapitre classés devant lui — et le second étage donne p (comme le noyau de calibration qui les a appris)
p_image(Cs, Ps) :-
    (   current_predicate(decision_poids:deux_etages/0)
    ->  findall(N-P1, ( member(c(N, T), Cs), p_etage(1, T, P1) ), P1s),
        contexte_image(P1s, Ctx),
        findall(N-P, ( member(c(N, T), Cs), get_assoc(N, Ctx, CT), append(T, CT, T2), p_etage(2, T2, P) ), Ps)
    ;   findall(N-P, ( member(c(N, T), Cs), p_catalogue(T, P) ), Ps)
    ).

p_etage(E, Traits, P) :-
    decision_poids:etage_base(E, B),
    aggregate_all(sum(V), ( arbre_etage(E, A), feuille_etage(E, Traits, A, 0, V) ), S),
    Z is max(-30.0, min(30.0, B + S)),
    P is 1 / (1 + exp(-Z)).

arbre_etage(E, A) :-
    distinct(A, ( decision_poids:etage_noeud(E, A, 0, _, _, _, _) ; decision_poids:etage_feuille(E, A, 0, _) )).

feuille_etage(E, Traits, A, N, V) :-
    (   decision_poids:etage_feuille(E, A, N, V0)
    ->  V = V0
    ;   decision_poids:etage_noeud(E, A, N, T, Seuil, G, D),
        valeur(Traits, T, X),
        ( X =< Seuil -> Suivant = G ; Suivant = D ),
        feuille_etage(E, Traits, A, Suivant, V)
    ).

contexte_image(P1s, Ctx) :-
    findall(NP-N, ( member(N-P, P1s), NP is -P ), L0), msort(L0, Ordre),
    Ordre = [PM0-_|_], PMax is -PM0,
    list_to_assoc(P1s, AP),
    % le plus fort p1 des descendants de chaque candidat
    foldl(descendants_de, P1s, t, Desc0), ( Desc0 == t -> empty_assoc(Desc) ; Desc = Desc0 ),
    empty_assoc(Vus0),
    numerote(Ordre, 1, AP, Desc, PMax, Vus0, _, Paires),
    list_to_assoc(Paires, Ctx).

descendants_de(M-P, D0, D) :-
    ( D0 == t -> empty_assoc(E0) ; E0 = D0 ),
    prefixes(M, As),
    foldl([A, X0, X]>>( A == M -> X = X0 ; ( get_assoc(A, X0, Q), Q >= P -> X = X0 ; put_assoc(A, X0, P, X) ) ),
          As, E0, D).

numerote([], _, _, _, _, Vus, Vus, []).
numerote([NP-N|R], I, AP, Desc, PMax, Vus0, Vus, [N-CT|Ps]) :-
    P is -NP,
    Inv is 1.0 / I,
    ( PMax > 0 -> Rap is P / PMax ; Rap = 0.0 ),
    ( get_assoc(N, Desc, MD) -> true ; MD = 0.0 ),
    prefixes(N, As0), exclude(==(N), As0, As),
    findall(Pr-A, ( member(A, As), get_assoc(A, AP, _), \+ sub_atom(A, _, _, _, ':'),
                    prefixes(A, PA), length(PA, Pr) ), PrAs),
    ( PrAs == [] -> PAnc = 0.0 ; max_member(_-AMax, PrAs), get_assoc(AMax, AP, PAnc) ),
    sub_atom(N, 0, 1, _, Ch),
    ( get_assoc(Ch, Vus0, Devant) -> true ; Devant = 0 ),
    CT = [inv_rang_image-Inv, p_sur_max_image-Rap, max_descendant-MD, p_ancetre_proche-PAnc,
          devant_dans_chapitre-Devant],
    D1 is Devant + 1, put_assoc(Ch, Vus0, D1, Vus1),
    I1 is I + 1,
    numerote(R, I1, AP, Desc, PMax, Vus1, Vus, Ps).

% prefixes(+N, -Ps) : comme la mesure (diag_metrics.ancestors) — si la notation est faite de parties bien formées
% (chiffre, chiffre ?, au plus deux lettres, chiffres, groupes « (…) » suivis de chiffres), ses préfixes par jetons
% (« (…) », une ou deux capitales, un chiffre), elle comprise ; sinon elle seule
prefixes(N, Ps) :-
    atom_codes(N, Cs),
    (   phrase(partie, Cs), phrase(jetons(Js), Cs)
    ->  cumuls(Js, [], Ps0), sort([N|Ps0], Ps)
    ;   Ps = [N]
    ).

partie --> chiffre, ( chiffre -> [] ; [] ), lettres_au_plus(2), chiffres, groupes.
lettres_au_plus(K) --> ( { K > 0 }, [C], { code_type(C, upper) } -> { K1 is K - 1 }, lettres_au_plus(K1) ; [] ).
chiffres --> ( chiffre -> chiffres ; [] ).
groupes --> ( "(", sans_fermante, ")" -> chiffres, groupes ; [] ).
sans_fermante --> ( [C], { C \== 0') } -> sans_fermante ; [] ).
chiffre --> [C], { code_type(C, digit) }.

jetons([J|Js]) --> jeton(J), !, jetons(Js).
jetons(Js) --> [_], !, jetons(Js).
jetons([]) --> [].
jeton(J) --> "(", sans_fermante_codes(Cs), ")", !, { append([0'(|Cs], [0')], J) }.
jeton([A, B]) --> [A, B], { code_type(A, upper), code_type(B, upper) }, !.
jeton([A]) --> [A], { code_type(A, upper) ; code_type(A, digit) }, !.
sans_fermante_codes([C|Cs]) --> [C], { C \== 0') }, !, sans_fermante_codes(Cs).
sans_fermante_codes([]) --> [].

cumuls([], _, []).
cumuls([J|Js], Acc0, [P|Ps]) :- append(Acc0, J, Acc), atom_codes(P, Acc), cumuls(Js, Acc, Ps).

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
    include([N]>>( \+ ( member(M, Ns), M \== N, arbre:ancetre(M, N) ) ), Ns, Codes).

division_86(N) :- sub_atom(N, 0, 2, _, '86').
