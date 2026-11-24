/*  La grammaire des libellés d'Iconclass (docs/FONDEMENTS.md, § 3) : comment Iconclass écrit, pas ce que les images
    montrent. Deux opérations, toutes deux hors ligne :

    pretraiter(+Texte, -Net, -Marques)
        Retire du libellé ses parenthèses et les classe (§ 3.3) ; Net est le texte que lit l'analyseur. Marques :
          gabarit                     « (...) », « (with NAME) », « (with BOOK CHAPTER:VERSE) » : un emplacement
          recit                       « (story of) », « (scenes from) » : la notation est l'histoire d'une personne
          variante(Nom)               « Hercules (Heracles) », « Lucy (Lucia) » : un autre nom du même individu
          nom(Nom)                    « (ALEXANDER THE GREAT) » : un nom en capitales, celui d'un individu
          type(Mot)                   « Venus (planet) », « Tigris (river) » : le type d'un nom
          renvoi(ripa)                « (Ripa) » : un renvoi à l'Iconologia, recueil de personnifications
          renvoi                      « (Ps. 9:9) », « (SHAKESPEARE, Henry VI …) », « (Acts 6:1-6) »
          numero(N)                   « (11) » : rang dans un cycle
          exclusion(Texte)            « (not in biblical context) », « (except the earth) »
          residuel                    « (other) »
          definition(Texte)           « (i.e. Mary with the Christ-child) » : fait partie de la définition
          exemple(Texte)              « (e.g. as Doctor of the Church) »
          alternative(Texte)          « (or standing beside) », « (alternatively she is riding on a dolphin) »
          qualificatif(Texte)         « (in general) », « (opposing concepts) », « (including …) » : métalangage
          facultatif(Texte)           toute autre parenthèse en minuscules : « (high) », « (with cross) », « (kneeling) »
        Une terminaison collée au mot (« saint(s) », « gen(us) ») est retirée sans marque : elle ne dit qu'un pluriel ou
        une variante d'écriture.

    type_de_libelle(+N, +Phrases, +Marques, -Type)
        Le type de la partie propre du libellé (§ 3.2) : rubrique, concept, individu, recit, attribut, genre, scene,
        classe ; calculé sur le libellé anglais (le français prend le type de sa notation). Une partie de gabarit
        (« - portrayed alone », « - miraculous activities ») se type à part : elle ajoute un aspect à la notation.

    Deux décisions de l'étiqueteur sont reprises par des faits plus sûrs : une classe fermée est finie (un mot hors de la
    liste, rangé en préposition ou en déterminant, est une erreur de l'étiqueteur, et WordNet dit alors si c'est un
    verbe : « David beheads Goliath ») ; un nom à parenthèse n'est une personne que si le gabarit parle de personnes,
    au sens de WordNet (« male saints (with NAME) », « historical person (with NAME) » : noun.person ; pas « attributes
    of Cupid (with NAME) »).
*/
:- module(libelles_iconclass, [ pretraiter/3, type_de_libelle/4, tete/2 ]).
:- encoding(utf8).
:- use_module(library(pcre)).
:- use_module(arbre).
:- use_module(sujets, []).

% --- Les parenthèses -------------------------------------------------------------------------------------------------

pretraiter(T0, Net, Marques) :-
    atom_string(T0, S0),
    re_replace("([A-Za-z])\\((s|us|u|es|i|a|e|is|ae|um|en|n|ux)\\)"/g, "$1", S0, S1),   % terminaisons collées
    parentheses(S1, Net0, Marques0),
    normalize_space(string(Net1), Net0), atom_string(Net, Net1),
    Marques = Marques0.

% parentheses(+S, -Net, -Marques) : de gauche à droite ; une parenthèse imbriquée reste dans le contenu de l'englobante
parentheses(S, Net, Ms) :-
    (   sub_string(S, B, 1, _, "("), fermante(S, B, F)
    ->  sub_string(S, 0, B, _, Av), L is F - B - 1, B1 is B + 1, sub_string(S, B1, L, _, C0),
        F1 is F + 1, sub_string(S, F1, _, 0, Ap),
        normalize_space(string(C), C0),
        avant(Av, MotAvant),
        classer(C, MotAvant, M),
        ( M = definition(_) -> string_concat(Av, " ", Av1), string_concat(Av1, C, Av2), Tete = Av2 ; Tete = Av ),
        parentheses(Ap, Net1, Ms1),
        string_concat(Tete, " ", Tete1), string_concat(Tete1, Net1, Net),
        Ms = [M|Ms1]
    ;   Net = S, Ms = []
    ).

fermante(S, B, F) :- string_length(S, Lg), B1 is B + 1, fermante_(S, B1, Lg, 1, F).
fermante_(S, I, Lg, P, F) :-
    I < Lg, sub_string(S, I, 1, _, C), I1 is I + 1,
    (   C == "(" -> P1 is P + 1, fermante_(S, I1, Lg, P1, F)
    ;   C == ")" -> ( P =:= 1 -> F = I ; P1 is P - 1, fermante_(S, I1, Lg, P1, F) )
    ;   fermante_(S, I1, Lg, P, F)
    ).

avant(Av, Mot) :-
    split_string(Av, " ", " ,;:", Ms0), exclude(==(""), Ms0, Ms), ( last(Ms, Mot) -> true ; Mot = "" ).

classer(C, _, gabarit) :- ( C == "..." ; re_match("^(with|avec) [A-Z][A-Z :]+$", C) ), !.
classer(C, _, recit) :- memberchk(C, ["story of", "scenes from", "histoire de", "histoire d'", "scènes de"]), !.
classer(C, _, numero(N)) :- number_string(N, C), integer(N), !.
classer(C, _, renvoi(ripa)) :- re_match("^Ripa\\b", C), !.        % l'Iconologia de Ripa : des personnifications
classer(C, _, renvoi) :-
    (   re_match("[0-9]+[:,.][0-9]", C)                         % chapitre et verset, acte et scène
    ;   re_match("^(Ovid|Ovide|Homer|Homère|Virgil|Virgile|Dante|Ariosto|Tasso|Boccaccio|Petrarch)\\b", C)
    ;   re_match("^[A-Z]{3,}, ", C)                              % « SHAKESPEARE, Henry VI, Part 2 … »
    ), !.
classer(C, _, nom(C)) :- re_match("^[A-Z][A-Z .&'-]+$", C), \+ re_match("^[A-Z]$", C), !.
classer(C, _, exclusion(C)) :- re_match("^(not |except |without |excluding |non |sauf |sans |hors |pas )", C), !.
classer(C, _, residuel) :- memberchk(C, ["other", "others", "autre", "autres"]), !.
classer(C, _, definition(D)) :- re_matchsub("^(i\\.e\\.|c\\.-à-d\\.|c'est-à-dire|namely)\\s*(?<d>.*)$", C, M, []), !, D = M.d.
classer(C, _, exemple(C)) :- re_match("^(e\\.g\\.|p\\. ?ex\\.|such as|for example|par exemple)", C), !.
classer(C, _, alternative(C)) :- re_match("^(or |alternatively|ou |ou bien |and/or )", C), !.
classer(C, _, qualificatif(C)) :-
    re_match("^(in general|en général|opposing concepts|concepts opposés|including |y compris|incl\\.)", C), !.
classer(C, MotAvant, variante(C)) :-                          % un nom après un nom : « Hercules (Heracles) »
    re_match("^[A-Z][a-zà-ÿ'-]+( [A-Z][a-zà-ÿ'-]+)*$", C), MotAvant \== "", re_match("^[A-Z]", MotAvant), !.
classer(C, MotAvant, type(C)) :-                              % un nom commun après un nom : « Venus (planet) »
    re_match("^[a-zà-ÿ]+$", C), MotAvant \== "", re_match("^[A-Z]", MotAvant), !.
classer(C, _, facultatif(C)).

% --- Le type de libellé ---------------------------------------------------------------------------------------------

% les mots de la représentation et des genres : la classe de langue des ponts nominaux (mondes.pl) et les noms de genre
genre(L) :- memberchk(L, [landscape, seascape, portrait, view, veduta, cityscape, townscape, panorama, representation,
    'still-life', depiction, paysage, marine, vue, représentation, 'nature morte', portraiture]).
genre_mode(L) :- memberchk(L, [portray, depict, represent, portraiturer, représenter, figurer]).

% la tête d'une partie de libellé analysée : la racine de la première phrase, ou son premier nom
tete([phrase(Ms)|_], T) :-
    (   member(T, Ms), T = mot(_, _, _, C, _, 0, _, _, _), memberchk(C, ['NOUN', 'PROPN', 'VERB', 'ADJ']) -> true
    ;   member(T, Ms), T = mot(_, _, _, 'NOUN', _, _, _, _, _) -> true
    ).

type_de_libelle(N, _, _, rubrique) :- atom_length(N, Lg), Lg =< 2, !.
type_de_libelle(N, _, _, concept) :- sub_atom(N, 0, 1, _, '5'), !.
type_de_libelle(_, Ph, _, attribut) :- relation_de_tete(Ph), !.
type_de_libelle(_, _, Ms, recit) :- memberchk(recit, Ms), !.
type_de_libelle(_, _, Ms, concept) :- memberchk(renvoi(ripa), Ms), !.
type_de_libelle(_, Ph, _, genre) :- tete(Ph, T), lemme_bas(T, L), ( genre(L) ; genre_mode(L) ), !.
type_de_libelle(_, Ph, _, scene) :- member(phrase(Ms), Ph), member(M, Ms), verbe(M), !.
type_de_libelle(_, Ph, _, scene) :- tete(Ph, T), T = mot(_, _, _, 'NOUN', _, _, _, _, _), lemme_bas(T, L), nom_d_evenement(L), !.
type_de_libelle(_, Ph, _, scene) :-                     % « bath of Venus » : un nom d'action suivi de « of » et d'un nom
    member(phrase(Ms), Ph), append(_, [T, mot(_, De, _, _, _, _, _, _, _)|Reste], Ms),      % propre (l'étiqueteur range
    downcase_atom(De, D), memberchk(D, [of, de, du, des]), nom(T), lemme_bas(T, L), nom_d_action(L),   % parfois « bath »
    Reste = [P|_], ( P = mot(_, _, _, 'PROPN', _, _, _, _, _) -> true ; P = mot(_, _, _, 'DET', _, _, _, _, _) ), !.   % en préposition)

type_de_libelle(N, _, _, individu) :- ( nom_de_notation(N) ; sub_atom(N, _, _, _, '(...)') ), gabarit_de_personnes(N), !.
type_de_libelle(_, _, _, classe).

% un nom : rangé en nom par l'étiqueteur, ou rangé en classe fermée alors que le mot n'en est pas et que WordNet le
% connaît comme nom
nom(mot(_, _, _, 'NOUN', _, _, _, _, _)) :- !.
nom(mot(_, F, _, C, _, _, _, _, _)) :-
    memberchk(C, ['ADP', 'DET', 'SCONJ', 'CCONJ', 'PRON', 'PART']), downcase_atom(F, W), \+ sujets:ferme(en, W),
    once(wordnet:s(_, _, W, n, _, _)).

% un verbe : rangé en verbe par l'étiqueteur, ou rangé en classe fermée alors que le mot n'en est pas (erreur de
% l'étiqueteur) et que la morphologie de WordNet en fait une forme verbale fléchie
verbe(mot(_, _, _, 'VERB', _, _, _, _, _)) :- !.
verbe(mot(_, F, _, C, _, _, _, _, _)) :-
    memberchk(C, ['ADP', 'DET', 'SCONJ', 'CCONJ', 'PRON', 'PART']), downcase_atom(F, W), \+ sujets:ferme(en, W),
    catch(morphologie:lemmes(W, v, Ls), _, fail), member(L, Ls), L \== W.

% le gabarit d'une notation à nom parle de personnes : la tête de son libellé (le dernier mot avant « of », « with »,
% une parenthèse ou une ponctuation : la tête d'un groupe nominal anglais précède ses compléments) a pour sens
% dominant une personne (« male saints », « historical person » ; pas « attributes of Cupid »)
% (chaque partie séparée par « ~ » compte : « representations ~ gods, demi-gods, heroes etc. (with NAME) »)
gabarit_de_personnes(N) :-
    gabarit_ou_soi(N, G), iconclass:libelle(G, en, T0),
    atomic_list_concat(Qs, ' ~ ', T0), member(T, Qs),
    atom_string(T, St), re_replace("(,|;|:|\\(| of | with | from | in | on | at | by | for | - ).*$", "", St, Tete),
    split_string(Tete, " ", " ", Ms), exclude(==(""), Ms, Ms1), last(Ms1, M0), atom_string(M1, M0), downcase_atom(M1, W),
    ( catch(morphologie:lemmes(W, n, [L|_]), _, fail) -> true ; L = W ),
    once(wordnet:s(S, _, L, n, 1, _)),
    ( wordnet:lexfile(S, 'noun.person') -> true ; sous_personne(S) ), !.   % « person » est dans noun.Tops

:- table sous_personne/1.
sous_personne(100007846).
sous_personne(S) :- wordnet:hyp(S, P), sous_personne(P).
% le gabarit d'une notation à nom (11H(PETER) → 11H(...)), ou la notation elle-même si c'est un gabarit
gabarit_ou_soi(N, N) :- sub_atom(N, _, _, 0, '(...)'), !.
gabarit_ou_soi(N, G) :- arbre:ancetre(N, G), sub_atom(G, _, _, 0, '(...)'), !.
gabarit_ou_soi(N, G) :- arbre:gabarit_de(N, G).


lemme_bas(mot(_, _, L0, _, _, _, _, _, _), L) :- downcase_atom(L0, L).

% (après les scènes : un épisode de la vie d'un saint, 11H(JEROME)3 « personal devotion of St. Jerome », est une scène
% dont le saint est le genre ; la notation du saint lui-même, 11H(JEROME), est un individu)

% une notation à nom propre (pas un gabarit) : 11H(PETER), 61B2(PETRARCA, Francesco)
nom_de_notation(N) :- sub_atom(N, B, 1, _, '('), \+ sub_atom(N, B, _, _, '(...)'), \+ sub_atom(N, B, 2, _, '(+'), !.

% « attributes of Cupid: blindfold », « parts of the church: … » : un nom relationnel avant « : »
relation_de_tete([phrase(Ms)|_]) :-
    member(mot(I, _, L0, 'NOUN', _, _, _, _, _), Ms), downcase_atom(L0, L),
    memberchk(L, [attribute, part, symbol, attribut, partie, symbole]),
    member(mot(J, ':', _, _, _, _, _, _, _), Ms), J > I, !.

% un nom qui a un sens d'acte (« bath », « adoration ») : avec un participant nommé, c'est une action
nom_d_action(L) :- wordnet:s(S, _, L, n, _, _), wordnet:lexfile(S, F), memberchk(F, ['noun.act', 'noun.event']), !.

% le sens dominant d'un nom est un acte, un événement, un processus (WordNet, fichiers lexicographiques)
nom_d_evenement(L) :-
    once(wordnet:s(S, _, L, n, 1, _)), wordnet:lexfile(S, F),
    memberchk(F, ['noun.act', 'noun.event', 'noun.process', 'noun.phenomenon']).

abstrait(L) :-
    once(wordnet:s(S, _, L, n, 1, _)), wordnet:lexfile(S, F),
    memberchk(F, ['noun.attribute', 'noun.cognition', 'noun.feeling', 'noun.state', 'noun.communication',
                  'noun.motive', 'noun.relation', 'noun.time']).
