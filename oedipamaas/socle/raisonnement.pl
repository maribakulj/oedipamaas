/*  Le raisonnement de la V1 sur les assertions (cahier des charges, § 7) : types de preuve T1, T2 et T6.

    coder(+Faits, -Resultat) : Faits, les assertions validées d'un document (socle/assertions.pl) ; Resultat, un dict
    { etablis, candidats, contredits } dont chaque code porte sa preuve : la règle, les prémisses (assertions et
    passages) et les faits d'Iconclass. Rien n'est écrit dans la base : tout passe en argument.

    T1 nom explicite : une personne nommée, admissible, dont le nom est celui d'une notation à nom d'Iconclass (nom de
       la notation, ou mot clé, dans la langue du texte ou en anglais), sans ambiguïté ; un titre de saint restreint aux
       saints (11H, 11HH), un nom sans titre exclut les saints (« David » n'est pas saint David de Galles).
    T2 chose décrite : un référent admissible dont la tête est un élément du libellé principal d'une notation (« lion »
       pour « beasts of prey, predatory animals: lion », « skull » pour « death's head, skull »), dans la langue du
       texte ; une notation à lettre doublée s'efface devant son jumeau simple (T10 n'est pas encore certifiée) ; un
       seul candidat : établi.
    T6 repli : plusieurs candidats T1 ou T2 pour un même référent : leur plus proche ancêtre commun dans l'arbre, s'il
       n'est ni une racine ni un gabarit ; tous les candidats impliquent cet ancêtre.
    Contredit : un référent nié sur ce que l'image représente ; ses notations T2 sont rendues comme contredites.
    Candidats : les notations T1 ou T2 d'un référent non admissible (modalité, alternative, autre œuvre…) ou ambigu.

    preparer/0 construit une fois l'index des libellés (module raisonnement, faits def/3, en lecture seule ensuite).
*/
:- module(raisonnement, [ preparer/0,     % construit l'index des libellés (une fois)
                          coder/2         % +Faits, -Resultat
                        ]).
:- encoding(utf8).
:- use_module(arbre).
:- use_module(notation).
:- use_module(assertions).

:- dynamic def/3, nom_notation/2.          % def(Langue, Mot, Notation) ; nom_notation(NomNormalisé, Notation)

% --- Index des libellés ---------------------------------------------------------------------------------------------

preparer :-
    (   def(_, _, _) -> true
    ;   forall(( member(L, [en, fr]), iconclass:libelle(N, L, T), element_principal(T, W) ), assertz(def(L, W, N))),
        forall(( notation_a_nom(N, Nom), normaliser_nom(Nom, K) ), assertz(nom_notation(K, N))),
        forall(( iconclass:mot_cle(N, L, Mot), memberchk(L, [en, fr]), notation_a_nom(N, _),
                 tete_mot_cle(Mot, Nom), normaliser_nom(Nom, K) ), assertz(nom_notation(K, N)))
    ).

% les éléments du libellé principal : première partie (avant « - »), première proposition (avant « ; »), après le
% titre (« … : »), chaque élément d'une énumération (« , »), parenthèses ôtées, en minuscules
element_principal(T, W) :-
    premier_segment(T, " - ", P1), premier_segment(P1, "; ", P2),
    (   dernier_segment(P2, ": ", P3) -> true ; P3 = P2 ),
    split_string(P3, ",", " ", Items),
    member(I0, Items), sans_parentheses(I0, I1), normalize_space(string(I2), I1), I2 \== "",
    string_lower(I2, I3), atom_string(W, I3).

premier_segment(T, Sep, P) :- ( sub_string(T, B, _, _, Sep) -> sub_string(T, 0, B, _, P) ; P = T ).
dernier_segment(T, Sep, P) :- sub_string(T, B, L, _, Sep), \+ ( sub_string(T, B2, _, _, Sep), B2 > B ), !,
    Debut is B + L, sub_string(T, Debut, _, 0, P).

sans_parentheses(S0, S) :-
    (   sub_string(S0, B, _, _, "("), sub_string(S0, F, 1, _, ")"), F > B
    ->  sub_string(S0, 0, B, _, Av), F1 is F + 1, sub_string(S0, F1, _, 0, Ap),
        string_concat(Av, Ap, S1), sans_parentheses(S1, S)
    ;   S = S0
    ).

% une notation à nom : son dernier niveau est un nom (11H(JEROME)) ; le nom tel qu'Iconclass l'écrit
notation_a_nom(N, Nom) :-
    iconclass:n(N), notation:analyser(N, Niv), Niv \= composee(_), last(Niv, nom(Nom)).

tete_mot_cle(Mot, Nom) :- ( sub_atom(Mot, B, _, _, ' (') -> sub_atom(Mot, 0, B, _, Nom) ; Nom = Mot ).

% un nom normalisé : capitales sans accents, espaces simples (« Jérôme » → JEROME)
normaliser_nom(Nom, K) :-
    atom_codes(Nom, Cs0), maplist(sans_accent, Cs0, Cs1), atom_codes(A, Cs1),
    upcase_atom(A, A1), normalize_space(atom(K), A1).

sans_accent(C0, C) :- ( accent(C0, C1) -> C = C1 ; C = C0 ).
accent(0'é, 0'e). accent(0'è, 0'e). accent(0'ê, 0'e). accent(0'ë, 0'e). accent(0'à, 0'a). accent(0'â, 0'a).
accent(0'î, 0'i). accent(0'ï, 0'i). accent(0'ô, 0'o). accent(0'ö, 0'o). accent(0'ù, 0'u). accent(0'û, 0'u).
accent(0'ü, 0'u). accent(0'ç, 0'c). accent(0'É, 0'E). accent(0'È, 0'E). accent(0'À, 0'A). accent(0'Ç, 0'C).

% --- Candidats par référent -----------------------------------------------------------------------------------------

langue(Fs, L) :- memberchk(doc(L, _), Fs).

% T1 : les notations à nom d'une personne nommée
candidats_t1(Fs, E, Ns) :-
    memberchk(nom(_, E, Nom, _), Fs), memberchk(entite(E, Tete, _), Fs),
    normaliser_nom(Nom, K),
    findall(N, ( nom_notation(K, N), filtre_titre(Tete, N) ), Ns0),
    sort(Ns0, Ns), Ns \== [].

saint(N) :- ( sub_atom(N, 0, _, _, '11H(') ; sub_atom(N, 0, _, _, '11HH(') ), !.
filtre_titre(saint, N) :- !, saint(N).
filtre_titre(_, N) :- \+ saint(N).

% T2 : les notations dont un élément du libellé principal est la tête du référent
candidats_t2(Fs, E, Ns) :-
    memberchk(entite(E, Tete, _), Fs), Tete \== nom_propre, langue(Fs, L),
    findall(N, ( formes(L, Tete, W), def(L, W, N) ), Ns0),
    sort(Ns0, Ns1),
    exclude(double_avec_jumeau(Ns1), Ns1, Ns), Ns \== [].

formes(_, T, T).
formes(en, T, W) :- catch(morphologie:tous_lemmes(T, Ls), _, fail), member(W, Ls), W \== T.

% une notation à lettre doublée dont le jumeau simple est aussi candidat : le jumeau (le trait déclencheur de la lettre
% doublée n'est pas vérifié en V1)
double_avec_jumeau(Ns, N) :-
    notation:analyser(N, Niv), Niv \= composee(_),
    append(Av, [double(X)|Ap], Niv), append(Av, [lettre(X)|Ap], Simple), notation:ecrire(Simple, J),
    memberchk(J, Ns).

% le plus proche ancêtre commun (au sens de l'arbre), s'il n'est ni une racine ni un gabarit
ancetre_commun(Ns, A) :-
    Ns = [N1|Rs],
    findall(X, arbre:ancetre_ou_soi(N1, X), As1),
    include(commun_a(Rs), As1, Communs),
    Communs \== [],
    findall(P-X, ( member(X, Communs), arbre:profondeur_arbre(X, P) ), Ps), max_member(P0-A, Ps),
    P0 >= 1, \+ sub_atom(A, _, _, 0, '(...)').
commun_a(Rs, X) :- forall(member(R, Rs), arbre:ancetre_ou_soi(R, X)).

% --- Codage ---------------------------------------------------------------------------------------------------------

coder(Fs, _{etablis: Etablis, candidats: Candidats, contredits: Contredits}) :-
    preparer,
    findall(E, member(entite(E, _, _), Fs), Es),
    foldl(coder_entite(Fs), Es, r([], [], []), r(Et0, Ca0, Co0)),
    trier(Et0, Etablis), trier(Ca0, Candidats0), trier(Co0, Contredits),
    findall(C, ( member(C, Candidats0), \+ ( member(X, Etablis), X.code == C.code ) ), Candidats).

trier(L0, L) :- findall(K-X, ( member(X, L0), K = X.code-X.objet ), P), keysort(P, P1), pairs_values(P1, L2),
    list_to_set(L2, L).

coder_entite(Fs, E, r(Et0, Ca0, Co0), r(Et, Ca, Co)) :-
    (   assertions:contredit(Fs, E)
    ->  ( candidats_t2(Fs, E, Ns) -> true ; Ns = [] ),
        findall(C, ( member(N, Ns), code(Fs, E, N, contredit, t2, C) ), Cs),
        append(Co0, Cs, Co), Et = Et0, Ca = Ca0
    ;   preuve_entite(Fs, E, Type, Ns)
    ->  (   admissible_entite(Fs, E, Type)
        ->  (   Ns = [N]
            ->  code(Fs, E, N, etabli, Type, C), Et = [C|Et0], Ca = Ca0
            ;   ancetre_commun(Ns, A)
            ->  code(Fs, E, A, etabli, t6(Type, Ns), C),
                findall(Cd, ( member(N, Ns), code(Fs, E, N, candidat(ambigu), Type, Cd) ), Cds),
                Et = [C|Et0], append(Ca0, Cds, Ca)
            ;   findall(Cd, ( member(N, Ns), code(Fs, E, N, candidat(ambigu), Type, Cd) ), Cds),
                Et = Et0, append(Ca0, Cds, Ca)
            )
        ;   raison_non_admissible(Fs, E, R),
            findall(Cd, ( member(N, Ns), code(Fs, E, N, candidat(R), Type, Cd) ), Cds),
            Et = Et0, append(Ca0, Cds, Ca)
        ),
        Co = Co0
    ;   Et = Et0, Ca = Ca0, Co = Co0
    ).

preuve_entite(Fs, E, t1, Ns) :- candidats_t1(Fs, E, Ns), !.
preuve_entite(Fs, E, t2, Ns) :- candidats_t2(Fs, E, Ns).

% T1 demande l'entité et son nom admissibles ; T2 l'entité
admissible_entite(Fs, E, t1) :- assertions:admissible(Fs, E), memberchk(nom(A, E, _, _), Fs), assertions:admissible(Fs, A).
admissible_entite(Fs, E, t2) :- assertions:admissible(Fs, E).

raison_non_admissible(Fs, E, R) :-
    (   member(alternative(_, As), Fs), memberchk(E, As) -> R = alternative
    ;   memberchk(modalite(E, M), Fs), M \== affirme -> R = modalite(M)
    ;   memberchk(portee(E, P), Fs), P \== represente -> R = portee(P)
    ;   memberchk(enonciateur(E, Q), Fs), Q \== auteur -> R = enonciateur(Q)
    ;   R = non_admissible
    ).

% un code et sa preuve
code(Fs, E, N, Statut, Type, C) :-
    premisses(Fs, E, Type, Ps),
    ( iconclass:libelle(N, en, Lib) -> true ; Lib = '' ),
    type_preuve(Type, TP, Regle, Iconclass),
    statut_json(Statut, SJ, Raison),
    atom_concat('https://iconclass.org/', N, Uri),
    C0 = _{code: N, uri: Uri, libelle: Lib, statut: SJ, type_preuve: TP, objet: E,
           preuve: _{regle: Regle, premisses: Ps, iconclass: Iconclass}},
    ( Raison == none -> C = C0 ; C = C0.put(raison, Raison) ).

type_preuve(t1, 'T1', nom_explicite, []).
type_preuve(t2, 'T2', chose_decrite, []).
type_preuve(t6(T, Ns), 'T6', repli_ancetre_commun, Ns0) :- type_preuve(T, _, _, _), Ns0 = Ns.

statut_json(etabli, etabli, none).
statut_json(contredit, contredit, negation).
statut_json(candidat(R), candidat, RJ) :- term_string(R, RJ).

premisses(Fs, E, Type, Ps) :-
    findall(P, premisse(Fs, E, Type, P), Ps).

premisse(Fs, E, _, _{assertion: A, passage: [D, F], texte: T}) :-
    memberchk(entite(E, Tete, PId), Fs), term_string(entite(E, Tete), A), passage(Fs, PId, D, F, T).
premisse(Fs, E, T, _{assertion: A, passage: [D, F], texte: Tx}) :-
    ( T == t1 ; T = t6(t1, _) ),
    memberchk(nom(IdN, E, Nom, PId), Fs), term_string(nom(IdN, E, Nom), A), passage(Fs, PId, D, F, Tx).

passage(Fs, PId, D, F, T) :-
    memberchk(passage(PId, D, F), Fs), memberchk(texte(Texte), Fs),
    L is F - D, sub_string(Texte, D, L, _, T).
