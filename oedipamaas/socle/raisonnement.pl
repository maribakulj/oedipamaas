/*  Le raisonnement de la V1 sur les assertions (cahier des charges, § 7) : types de preuve T1, T2 et T6.

    coder(+Faits, -Resultat) : Faits, les assertions validées d'un document (socle/assertions.pl) ; Resultat, un dict
    { etablis, candidats, contredits } dont chaque code porte sa preuve : la règle, les prémisses (assertions et
    passages) et les faits d'Iconclass. Rien n'est écrit dans la base : tout passe en argument.

    T1 nom explicite : une personne nommée, admissible, dont le nom est celui d'une notation à nom d'Iconclass (nom de
       la notation, ou mot clé, dans la langue du texte ou en anglais), sans ambiguïté ; un titre de saint restreint aux
       saints (11H, 11HH), un nom sans titre exclut les saints (« David » n'est pas saint David de Galles).
    T2 chose décrite : un référent admissible dont la tête est un élément du libellé principal d'une notation (« lion »
       pour « beasts of prey, predatory animals: lion », « skull » pour « (human) skull »), dans la langue du texte ;
       ni lettre doublée (T10 n'est pas certifiée), ni gabarit, ni libellé de contexte (« ~ »), ni lecture symbolique ;
       un seul candidat : établi.
    T6 repli : plusieurs candidats T1 ou T2 pour un même référent : leur plus proche ancêtre commun dans l'arbre, s'il
       n'est ni une racine ni un gabarit ; tous les candidats impliquent cet ancêtre.
    Contredit : un référent nié sur ce que l'image représente ; ses notations T2 sont rendues comme contredites.
    Candidats : les notations T1 ou T2 d'un référent non admissible (modalité, alternative, autre œuvre…) ou ambigu.

    preparer/0 construit une fois l'index des libellés (module raisonnement, faits def/3, en lecture seule ensuite).
*/
:- module(raisonnement, [ preparer/0,     % construit l'index des libellés (une fois)
                          coder/2,        % +Faits, -Resultat
                          verifier/2      % +Faits, +Code : la preuve d'un code établi se revérifie
                        ]).
:- encoding(utf8).
:- use_module(arbre).
:- use_module(notation).
:- use_module(assertions).
:- use_module(noms_propres).    % normaliser_nom, tete_mot_cle, sens_de_lieu : déplacés (module neutre)

:- dynamic def/3, nom_notation/2.

% T6 (repli sur l'ancêtre commun) est désactivé pour le jugement J2 (décision D11) : la liste des candidats n'est pas
% sûre d'être complète ; pour le réactiver : assertz(raisonnement:t6_actif)
:- dynamic t6_actif/0.          % def(Langue, Mot, Notation) ; nom_notation(NomNormalisé, Notation)

% --- Index des libellés ---------------------------------------------------------------------------------------------

preparer :-
    (   def(_, _, _) -> true
    ;   forall(( member(L, [en, fr]), iconclass:libelle(N, L, T), \+ sub_atom(N, _, _, _, '(...)'),
                 element_principal(N, L, T, W) ), assertz(def(L, W, N))),
        forall(( notation_a_nom(N, Nom), personne(N), normaliser_nom(Nom, K) ), assertz(nom_notation(K, N))),
        % un mot clé ne vaut pour nom que s'il en a la forme « Nom (rôle) » (« Pierre (St) », « Psammétique (roi) ») :
        % « Égypte », mot clé thématique de 98B(PSAMMETICHUS), n'est pas un nom de cette personne
        forall(( iconclass:mot_cle(N, L, Mot), memberchk(L, [en, fr]), notation_a_nom(N, _), personne(N),
                 sub_atom(Mot, _, _, _, ' ('), tete_mot_cle(Mot, Nom), normaliser_nom(Nom, K) ), assertz(nom_notation(K, N)))
    ).

% les éléments du libellé principal : première partie (avant « - »), première proposition (avant « ; ») si elle n'a
% pas de contexte (« ~ » : une chose dans un contexte n'est pas la chose), avant les attributs possibles ; le titre (« titre: suite ») et la suite, mais pour une notation à nom
% (25F23(LION)) la suite seulement, son titre nommant la catégorie (« beasts of prey ») ; chaque élément d'une
% énumération (« , » hors parenthèses), si tous sont courts (trois mots au plus : une liste de synonymes, pas une
% phrase « with book, skull, and lily ») ; en minuscules, sans article, sans les parenthèses de note (référence,
% « possibly », « e.g. ») ni un spécificatif de tête (« (human) skull ») ; les autres parenthèses restent dans
% l'élément (« lion (Son) », « dog (as messenger) » ne sont pas « lion », « dog ») ; en anglais, un élément d'un mot
% vaut aussi par ses lemmes (« landscapes » : « landscape »)
element_principal(N, L, T, W) :-
    premier_segment(T, " - ", P1), premier_segment(P1, "; ", P2),
    \+ sub_string(P2, _, _, _, "~"),                   % « Man ~ Community » : l'homme dans un contexte, pas l'homme
    P3 = P2,
    premier_segment(P3, "possible attributes", P4), premier_segment(P4, "attributs possibles", P5),
    (   dernier_segment(P5, ": ", Suite), premier_segment(P5, ": ", Titre)
    ->  ( Seg = Suite ; \+ notation_a_nom(N, _), Seg = Titre )
    ;   Seg = P5
    ),
    hors_parentheses_split(Seg, Items0),
    maplist(nettoyer_element, Items0, Items), Items \== [],
    \+ ( member(I, Items), sub_string(I, 0, _, _, "etc") ),
    \+ ( member(I, Items), symbolique(I) ),         % « crâne, symbole de 'Vanitas' » : une lecture (T11), pas la chose
    forall(member(I, Items), ( split_string(I, " ", "", Ms), length(Ms, Lg), Lg =< 3 )),
    member(I2, Items), I2 \== "",
    atom_string(W0, I2),
    (   W = W0
    ;   L == en, \+ sub_atom(W0, _, _, _, ' '), catch(morphologie:tous_lemmes(W0, Ls), _, fail), member(W, Ls), W \== W0
    ).

% découpe aux virgules qui ne sont pas entre parenthèses
hors_parentheses_split(S, Items) :-
    string_codes(S, Cs), decouper(Cs, 0, [], [], Items0), maplist(string_codes, Items, Items0).
decouper([], _, Cour, Acc, Items) :- reverse(Cour, C), reverse([C|Acc], Items).
decouper([0',|Cs], 0, Cour, Acc, Items) :- !, reverse(Cour, C), decouper(Cs, 0, [], [C|Acc], Items).
decouper([0'(|Cs], P, Cour, Acc, Items) :- !, P1 is P + 1, decouper(Cs, P1, [0'(|Cour], Acc, Items).
decouper([0')|Cs], P, Cour, Acc, Items) :- !, P1 is max(0, P - 1), decouper(Cs, P1, [0')|Cour], Acc, Items).
decouper([C|Cs], P, Cour, Acc, Items) :- decouper(Cs, P, [C|Cour], Acc, Items).

nettoyer_element(I0, I) :-
    normalize_space(string(I1), I0),
    sans_notes(I1, I2), string_lower(I2, I3), normalize_space(string(I4), I3),   % casse d'origine pour les notes
    sans_article(I4, I5), sans_et_final(I5, I).

% une parenthèse de note (chiffres d'une référence, « possibly », « e.g. »…) ou en tête (« (human) skull ») s'ôte
sans_notes(S0, S) :-
    (   sub_string(S0, B, _, _, "("), sub_string(S0, F, 1, _, ")"), F > B,
        \+ ( sub_string(S0, F2, 1, _, ")"), F2 > B, F2 < F ),
        L is F - B - 1, B1 is B + 1, sub_string(S0, B1, L, _, Dedans),
        ( B =:= 0 ; note(Dedans) )
    ->  sub_string(S0, 0, B, _, Av), F1 is F + 1, sub_string(S0, F1, _, 0, Ap),
        string_concat(Av, Ap, S1), sans_notes(S1, S)
    ;   S = S0
    ).
symbolique(I) :-
    member(P, ["symbol", "symbole", "emblem", "emblème", "attribute", "attribut", "personification", "personnification"]),
    sub_string(I, 0, _, _, P), !.

note(D) :- ( sub_string(D, _, 1, _, C), char_type(C, digit(_)) -> true
           ; string_lower(D, Dm),
             member(P, ["possibly", "il se peut", "e.g.", "i.e.", "or ", "ou ", "also", "aussi", "see ", "voir"]),
             sub_string(Dm, 0, _, _, P) ).

sans_article(S0, S) :-
    (   member(A, ["the ", "a ", "an ", "le ", "la ", "les ", "l'", "un ", "une ", "des "]), sub_string(S0, 0, LA, _, A)
    ->  sub_string(S0, LA, _, 0, S)
    ;   S = S0
    ).
sans_et_final(S0, S) :-
    (   member(A, ["and ", "et ", "or ", "ou "]), sub_string(S0, 0, LA, _, A) -> sub_string(S0, LA, _, 0, S) ; S = S0 ).

premier_segment(T, Sep, P) :- ( sub_string(T, B, _, _, Sep) -> sub_string(T, 0, B, _, P) ; P = T ).
dernier_segment(T, Sep, P) :- sub_string(T, B, L, _, Sep), \+ ( sub_string(T, B2, _, _, Sep), B2 > B ), !,
    Debut is B + L, sub_string(T, Debut, _, 0, P).

% une notation à nom : son dernier niveau est un nom (11H(JEROME)) ; le nom tel qu'Iconclass l'écrit
notation_a_nom(N, Nom) :-
    iconclass:n(N), notation:analyser(N, Niv), Niv \= composee(_), last(Niv, nom(Nom)).

% une notation à nom de personne : le libellé anglais de son gabarit parent parle de personnes (« male saints (with
% NAME) », « male persons from classical history », « heroes ») ; pas « knighthood order », « series of scenes »
:- table personne/1.
personne(N) :-
    arbre:parent(N, G), sub_atom(G, _, _, 0, '(...)'), iconclass:libelle(G, en, T0), downcase_atom(T0, T),
    once(( mot_de_personne(M), sub_atom(T, _, _, _, M) )),
    \+ ( mot_de_non_personne(X), sub_atom(T, _, _, _, X) ).
mot_de_personne(saints). mot_de_personne(persons). mot_de_personne(heroes). mot_de_personne(heroines).
mot_de_personne(gods). mot_de_personne(goddesses). mot_de_personne(deities). mot_de_personne(prophets).
mot_de_personne(sibyls). mot_de_personne(apostles). mot_de_personne(evangelists). mot_de_personne(martyrs).
mot_de_non_personne('scenes'). mot_de_non_personne('series').

% --- Candidats par référent -----------------------------------------------------------------------------------------

langue(Fs, L) :- memberchk(doc(L, _), Fs).

% T1 : les notations à nom d'une personne nommée
candidats_t1(Fs, E, Ns) :-
    memberchk(nom(_, E, Nom, _), Fs), memberchk(entite(E, Tete, _), Fs),
    \+ lieu(Fs, E),
    \+ nom_de_lieu(Nom),
    normaliser_nom(Nom, K),
    findall(N, ( nom_notation(K, N), filtre_titre(Tete, N) ), Ns0),
    sort(Ns0, Ns), Ns \== [].

% un nom propre en position de lieu n'est pas une personne : complément de lieu d'un événement, complément d'un nom
% par une préposition de lieu (« à Patmos », « in Egypt »), ou d'un nom de lieu ou de vue (« vue de Paris »)
lieu(Fs, E) :- memberchk(role(_, lieu, E), Fs), !.
lieu(Fs, E) :- member(relation(_, _, R, E, _), Fs), preposition_de_lieu(R), !.
lieu(Fs, E) :- member(relation(_, H, R, E, _), Fs), memberchk(R, [de, of, 'd\'']), memberchk(entite(H, T, _), Fs),
    tete_de_lieu(T), !.
preposition_de_lieu(P) :- memberchk(P, ['à', en, dans, vers, près, devant, derrière, sur, sous, in, at, to, near, from,
                                        towards, on, before, behind, under, outside, inside]).
tete_de_lieu(T) :- memberchk(T, [vue, view, paysage, landscape, environs, plan, carte, map, port, harbour, panorama,
                                 rue, street, ville, town, city, place, square, église, church, château, castle]).

% un nom qui a, dans WordNet, un sens de lieu (une instance ou une sorte de « location » : « Paris » la ville, à côté
% de Pâris le prince) n'est pas sûrement une personne : T1 s'abstient, le code reste candidat (jugement J2 : « Paris »
% dans une adresse, un lieu d'édition, « Notre-Dame de Paris »)
nom_de_lieu(Nom) :-
    normaliser_nom(Nom, K), downcase_atom(K, Km),
    catch(( wordnet:s(S, _, W, n, _, _), downcase_atom(W, Wm), Wm == Km, sens_de_lieu(S) ), _, fail), !.

titre_de_saint(T) :- memberchk(T, [saint, sainte, st, ste, 'st.', san, santa, santo, sankt]).

saint(N) :- ( sub_atom(N, 0, _, _, '11H(') ; sub_atom(N, 0, _, _, '11HH(') ), !.
filtre_titre(T, N) :- titre_de_saint(T), !, saint(N).
filtre_titre(_, N) :- \+ saint(N).

% T2 : les notations dont un élément du libellé principal est la tête du référent
candidats_t2(Fs, E, Ns) :-
    memberchk(entite(E, Tete, _), Fs), Tete \== nom_propre, langue(Fs, L),
    findall(N, def(L, Tete, N), Ns0),
    sort(Ns0, Ns1),
    exclude(lettre_doublee, Ns1, Ns2),
    include(sens_accorde(L, Tete), Ns2, Ns), Ns \== [].

% la couche de sens (REFONTE F2), quand elle est construite : la notation est alignée sur un sens de WordNet ; en
% anglais, ce sens est aussi le sens dominant du mot du texte (choix du sens élémentaire, avant le contexte) ; en
% français, faute de wordnet français pour l'instant, la notation doit seulement être alignée
sens_accorde(_, _, _) :- \+ current_predicate(sens:aligne/3), !.
sens_accorde(_, _, _) :- \+ sens:aligne(_, _, _), !.
sens_accorde(en, W, N) :- !, sens:aligne(N, _, S), sens_dominant_de(W, S), !.
sens_accorde(_, _, N) :- sens:aligne(N, _, _), !.

sens_dominant_de(W, S) :- wordnet:s(_, _, W, n, _, _), !,
    aggregate_all(max(F, S0), wordnet:s(S0, _, W, n, _, F), max(_, S)).
sens_dominant_de(W, S) :-
    catch(morphologie:tous_lemmes(W, Ls), _, fail), member(L, Ls), wordnet:s(_, _, L, n, _, _), !,
    aggregate_all(max(F, S0), wordnet:s(S0, _, L, n, _, F), max(_, S)).

% une notation à lettre doublée (féminin, fabuleux, opposé…) : son trait déclencheur n'est pas vérifié en V1 (T10 non
% certifié) ; elle ne sert pas à T2 (« crâne » ne doit pas aboutir au seul 31AA211, le crâne féminin)
lettre_doublee(N) :- notation:analyser(N, Niv), Niv \= composee(_), memberchk(double(_), Niv).

% le plus proche ancêtre commun (au sens de l'arbre) : un repli local, faute de savoir que la liste des candidats est
% complète — l'ancêtre a au moins trois ancêtres (« 25F2 », pas « 2 » ni « 25 »), aucun candidat n'est à plus de deux
% niveaux sous lui, et ce n'est pas un gabarit
ancetre_commun(Ns, A) :-
    Ns = [N1|Rs],
    findall(X, arbre:ancetre_ou_soi(N1, X), As1),
    include(commun_a(Rs), As1, Communs),
    Communs \== [],
    findall(P-X, ( member(X, Communs), arbre:profondeur_arbre(X, P) ), Ps), max_member(P0-A, Ps),
    P0 >= 3, \+ sub_atom(A, _, _, _, '(...)'),
    forall(member(N, Ns), ( arbre:profondeur_arbre(N, PN), PN - P0 =< 2 )).
commun_a(Rs, X) :- forall(member(R, Rs), arbre:ancetre_ou_soi(R, X)).

% --- Codage ---------------------------------------------------------------------------------------------------------

coder(Fs, _{etablis: Etablis, candidats: Candidats, contredits: Contredits}) :-
    preparer,
    findall(E, member(entite(E, _, _), Fs), Es),
    foldl(coder_entite(Fs), Es, r([], [], []), r(Et00, Ca00, Co0)),
    % une preuve qui ne se revérifie pas fait rétrograder le code (anomalie interne, signalée par sa raison)
    partition(verifier(Fs), Et00, Et0, Faux),
    findall(C, ( member(X, Faux), C = X.put(_{statut: candidat, raison: "preuve_non_verifiee"}) ), Cf),
    append(Ca00, Cf, Ca0),
    trier(Et0, Etablis), trier(Ca0, Candidats0), trier(Co0, Contredits),
    findall(C, ( member(C, Candidats0), \+ ( member(X, Etablis), X.code == C.code ) ), Candidats).

trier(L0, L) :- findall(K-X, ( member(X, L0), K = X.code-X.objet ), P), keysort(P, P1), pairs_values(P1, L2),
    list_to_set(L2, L).

coder_entite(Fs, E, r(Et0, Ca0, Co0), r(Et, Ca, Co)) :-
    (   memberchk(portee(E, oeuvre), Fs)                       % l'objet (huile, toile) : rien d'iconographique
    ->  Et = Et0, Ca = Ca0, Co = Co0
    ;   assertions:contredit(Fs, E)
    ->  ( candidats_t2(Fs, E, Ns) -> true ; Ns = [] ),
        findall(C, ( member(N, Ns), code(Fs, E, N, contredit, t2, C) ), Cs),
        append(Co0, Cs, Co), Et = Et0, Ca = Ca0
    ;   preuve_entite(Fs, E, Type, Ns)
    ->  (   admissible_entite(Fs, E, Type)
        ->  (   Ns = [N], hors_contexte_biblique_dans_un_recit(Fs, N)
            ->  code(Fs, E, N, candidat(recit_biblique), Type, Cd), Et = Et0, Ca = [Cd|Ca0]
            ;   Ns = [N]
            ->  code(Fs, E, N, etabli, Type, C), Et = [C|Et0], Ca = Ca0
            ;   t6_actif, ancetre_commun(Ns, A)
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

% une notation de personnage biblique « not in biblical context » (11I62(DAVID)…) dans un texte qui raconte (un
% événement est décrit) : Iconclass code alors l'épisode (71…, 73…), pas la personne hors récit (jugement J2)
hors_contexte_biblique_dans_un_recit(Fs, N) :-
    iconclass:libelle(N, en, L), sub_atom(L, _, _, _, 'not in biblical context'),
    memberchk(evenement(_, _, _), Fs).

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
    type_preuve(Type, TP, Regle, Iconclass0),
    ( Iconclass0 == [] -> Iconclass = [N] ; Iconclass = Iconclass0 ),
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

% --- Vérification d'une preuve --------------------------------------------------------------------------------------

% verifier(+Faits, +Code) : indépendamment de la façon dont le code a été produit — chaque prémisse est une assertion
% des faits, admissible, dont le passage cité est bien le texte source à ces positions ; la règle tient sur la base
% (T1 : la notation porte ce nom ; T2 : la tête est un élément de son libellé ; T6 : l'ancêtre commun de candidats qui
% tiennent eux-mêmes T1 ou T2, et le repli est local)
verifier(Fs, C) :-
    C.statut == etabli,
    E = C.objet, memberchk(entite(E, Tete, _), Fs),
    assertions:admissible(Fs, E),
    Ps = C.preuve.premisses, Ps \== [],
    forall(member(P, Ps), premisse_verifiee(Fs, P)),
    regle_tient(Fs, E, Tete, C.type_preuve, C.code, C.preuve.iconclass).

premisse_verifiee(Fs, P) :-
    term_string(T, P.assertion),
    (   T = entite(E, Tete) -> memberchk(entite(E, Tete, Id), Fs), A = E
    ;   T = nom(A, E, Nom) -> memberchk(nom(A, E, Nom, Id), Fs)
    ),
    assertions:admissible(Fs, A),
    [D, F] = P.passage, memberchk(passage(Id, D, F), Fs),
    memberchk(texte(Texte), Fs), L is F - D, sub_string(Texte, D, L, _, Tx), Tx == P.texte.

regle_tient(Fs, E, _, 'T1', N, _) :- candidats_t1(Fs, E, [N]).
regle_tient(Fs, E, Tete, 'T2', N, _) :- langue(Fs, L), def(L, Tete, N), candidats_t2(Fs, E, [N]).
regle_tient(Fs, E, _, 'T6', A, Ns) :-
    ( candidats_t1(Fs, E, Ns0) -> true ; candidats_t2(Fs, E, Ns0) ),
    msort(Ns, S), msort(Ns0, S), ancetre_commun(Ns0, A).
