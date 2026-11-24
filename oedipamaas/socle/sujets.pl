/*  L'inventaire des sujets d'Iconclass (docs/PLAN_F3.md, étape 1) : le profil de chaque notation de sujet, compilé
    par programme depuis ses libellés, ses mots clés et ses ancêtres, sans rien écrire d'iconographique à la main.

    Notations de sujet : toutes. Le sujet d'une image peut être un épisode (7, 9), une personne (11H, 61B), mais aussi
    un genre (paysage 25H, nature morte 34B, scène de genre 41D) : 16 des 21 sujets de la référence du banc de
    développement sont hors des divisions 1, 7 et 9. Une notation à nom (« 61B2(...) historical person (with NAME) »)
    a un profil sans son nom : le nom se lit dans la scène (étape 3).

    Lecture des libellés. Les libellés d'Iconclass sont télégraphiques (« bath of Venus », « David beheads Goliath ») ;
    l'étiqueteur d'UDPipe, appris sur des phrases, s'y trompe parfois sur la catégorie (« bath » et « beheads » rangés
    en préposition : 0,9 % des mots pleins en anglais, 0,4 % en français, mesuré sur 2 000 libellés par
    categories_fermees_fautives/3), et la catégorie ne sert pas à la correspondance, qui passe par les sens et traverse
    les catégories (« beheads » et le mot clé « beheading »). On garde donc d'UDPipe la segmentation et les lemmes, et
    on reconnaît les mots par deux faits sûrs :
      - les classes fermées (articles, prépositions, pronoms, conjonctions, auxiliaires) sont des listes finies, écrites
        ici par langue (règle de langue, pas d'iconographie) ;
      - Iconclass écrit les noms propres, et eux seuls, avec une majuscule ; une suite de mots à majuscule, liés au
        besoin par « the », « of », « de », « des », « d' »…, est un seul nom (« John the Baptist », « Joseph
        d'Arimathie »).
    Tout autre mot alphabétique d'au moins trois lettres est un mot plein, gardé par son lemme et par sa forme. Les mots
    ne sont pas séparés ici en actions et objets.

    La structure des libellés, celle d'Iconclass :
      - « propre - gabarit ~ catégorie » : un libellé fabriqué depuis un gabarit (« the apostle Peter … - miraculous
        activities and events ~ male saint ») ; la première partie est propre à la notation (ou à sa personne), les
        suivantes viennent du gabarit ;
      - « possible attributes: … » / « attributs possibles : … » : la liste des attributs d'une personne ;
      - dans un mot clé, « Nom (qualificatif) » : la parenthèse qualifie (« Hesperides (Garden) »), ses mots sont des mots
        pleins ; dans un libellé, une parenthèse à majuscule est un autre nom (« Hercules (Heracles) »).

    Faits compilés (module sujets_index), langues en et fr :
        profil(N, Langue, Genre, Element, Origine)
            Genre   : nom (normalisé : HERCULES, JOHN THE BAPTIST) ou mot (lemme en minuscules)
            Origine : propre, attribut, gabarit, mot_cle, herite (un nom de la partie propre d'un ancêtre de sujet :
                      l'histoire, le cycle dont N fait partie)
        rarete(Langue, Genre, Element, Nb)  nombre de notations de sujet qui portent l'élément en propre, en attribut
                                            ou en mot clé
        exige(N, Langue, Nom)               les personnes que le sujet exige (exige_calcule/3)
    construire_sujets(+Fichier) écrit l'index ; demande UDPipe (OEDIPAMAAS_UDPIPE, OEDIPAMAAS_MODELES).
*/
:- module(sujets, [ construire_sujets/1,    % +Fichier
                    notation_de_sujet/1,    % ?N
                    elements_du_texte/4     % +Texte, +Langue, +Sorte (libelle | mot_cle), -Origine-Elements
                  ]).
:- encoding(utf8).
:- use_module(arbre).
:- use_module(udpipe).
:- use_module(raisonnement, []).
:- discontiguous element/4.

notation_de_sujet(N) :- iconclass:n(N).

% --- Langue : classes fermées et liens internes des noms --------------------------------------------------------------

ferme(en, W) :- memberchk(W, [the, a, an, this, that, these, those, his, her, its, their, our, your, my, some, any, all,
    each, every, both, either, neither, no, not, nor, and, or, but, of, in, on, at, by, for, with, without, from, to,
    into, onto, upon, out, off, over, under, above, below, before, after, behind, beside, besides, between, among,
    amongst, against, through, during, about, around, near, towards, toward, within, while, whilst, when, where,
    whom, who, whose, which, what, than, then, also, as, he, she, it, they, him, them, himself, herself, itself,
    themselves, one, ones, other, others, be, is, are, was, were, been, being, has, have, had, having, do, does, did,
    can, could, may, might, must, shall, should, will, would, very, too, so, such, there, here, how, why, etc,
    via, per, often, sometimes, usually, possibly, especially, also, only, just, still, yet, again, sometimes,
    whether, although, though, because, since, until, unless, if, once, mostly, partly, e]).
ferme(fr, W) :- memberchk(W, [le, la, les, un, une, des, du, de, au, aux, ce, cet, cette, ces, son, sa, ses, leur,
    leurs, mon, ma, mes, ton, ta, tes, notre, nos, votre, vos, quelque, quelques, tout, toute, tous, toutes, chaque,
    aucun, aucune, nul, nulle, et, ou, mais, ni, car, donc, or, que, qui, quoi, dont, où, lequel, laquelle, lesquels,
    lesquelles, en, dans, sur, sous, par, pour, avec, sans, vers, chez, entre, parmi, contre, avant, après, devant,
    derrière, pendant, depuis, selon, malgré, hors, près, auprès, autour, lors, il, elle, ils, elles, lui, eux, se,
    soi, on, celui, celle, ceux, celles, ceci, cela, être, avoir, faire, est, sont, était, étaient, été, ont, avait,
    peut, peuvent, pouvoir, très, trop, aussi, ainsi, comme, quand, puis, alors, encore, déjà, souvent, parfois,
    non, pas, plus, moins, ne, si, autre, autres, même, mêmes, etc, soit, part, lorsque, puisque, tandis, ici, là]).

lien_de_nom(en, W) :- memberchk(W, [the, of]).
lien_de_nom(fr, W) :- memberchk(W, [de, des, du, 'd\'', 'd’', la, le, les, 'l\'', 'l’']).

marque_d_attributs(en, 'possible attributes:').
marque_d_attributs(fr, 'attributs possibles :').
marque_d_attributs(fr, 'attributs possibles:').
marque_d_attributs(en, 'possible attribute:').
marque_d_attributs(fr, 'attribut possible :').
marque_d_attributs(fr, 'attribut possible:').

% --- La structure d'un libellé ---------------------------------------------------------------------------------------

% parties(+Texte, +Langue, -Parties) : Origine-Texte
parties(T, L, Parties) :-
    atomic_list_concat(Ps0, ' - ', T),
    findall(P, ( member(P0, Ps0), atomic_list_concat(Qs, ' ~ ', P0), member(P, Qs), P \== '' ), Ps),
    (   Ps = [Premiere|Suivantes]
    ->  attributs(Premiere, L, Tete),
        findall(gabarit-P, member(P, Suivantes), Gs),
        append(Tete, Gs, Parties)
    ;   Parties = []
    ).

attributs(P, L, Parties) :-
    (   marque_d_attributs(L, M), sub_atom(P, B, LM, _, M)
    ->  sub_atom(P, 0, B, _, Av), A is B + LM, sub_atom(P, A, _, 0, Ap),
        Parties = [propre-Av, attribut-Ap]
    ;   Parties = [propre-P]
    ).

% --- Les éléments d'un texte analysé ---------------------------------------------------------------------------------

% Le contexte de lecture : ctx(Langue, Sorte, Texte, NomsPermis)
%   Sorte : libelle | mot_cle ; Texte : la partie lue (les noms se prennent dans le texte, pas dans les jetons : « du »
%   reste « du ») ; NomsPermis : oui | non (en français, une partie dont la partie anglaise n'a aucun nom propre n'en a
%   pas non plus : les rubriques d'Iconclass s'écrivent avec des majuscules, « Religion et Magie », « Attente, Guet »)

% elements(+Phrases, +Ctx, -Elements)
elements(Phrases, Ctx, Els) :-
    findall(E, ( member(phrase(Ms), Phrases), lire(Ms, 0, non, non, -1, Ts), element(Ts, Ctx, E) ), Els0),
    sort(Els0, Els).

% chaque mot lu : t(Forme, Lemme, Profondeur, Debut, Fin, Nie, Cite) ; Profondeur : de parenthèse ; Nie : sous une
% négation (« angels without wings » : « wing » n'est pas un élément), jusqu'à la ponctuation suivante ; Cite : entre
% guillemets (un titre cité, « 'Augurio buono' (Ripa) », est un seul nom)
lire([], _, _, _, _, []).
lire([mot(I, F0, Le, C, Tr, H, R, D, Fi)|Ms], P0, N0, Q0, Av, Ts) :-    % « (Héraclès » : parenthèse collée au mot
    atom_length(F0, Lg), Lg > 1,
    (   sub_atom(F0, 0, 1, A, '(') -> sub_atom(F0, 1, A, 0, F1), Ms1 = [mot(I, '(', '(', 'PUNCT', [], H, R, D, D), mot(I, F1, Le, C, Tr, H, R, D, Fi)|Ms]
    ;   sub_atom(F0, B, 1, 0, ')') -> sub_atom(F0, 0, B, _, F1), Ms1 = [mot(I, F1, Le, C, Tr, H, R, D, Fi), mot(I, ')', ')', 'PUNCT', [], H, R, Fi, Fi)|Ms]
    ),
    !, lire(Ms1, P0, N0, Q0, Av, Ts).
lire([mot(_, F, Le, _, _, _, _, D, Fi)|Ms], P0, N0, Q0, Av, Ts) :-
    downcase_atom(F, W),
    (   F == '(' -> P is P0 + 1, N = N0, Q = Q0, Ts = Ts1
    ;   F == ')' -> P is max(0, P0 - 1), N = N0, Q = Q0, Ts = Ts1
    ;   guillemet(F), Q0 == non, apostrophe(F), D =:= Av -> P = P0, N = N0, Q = Q0, Ts = Ts1   % élision : « d' »
    ;   guillemet(F) -> P = P0, N = N0, ( Q0 == non -> Q = oui ; Q = non ), Ts = Ts1
    ;   ponctuation(F) -> P = P0, N = non, Q = Q0, Ts = [t(F, F, P0, D, Fi, non, Q0)|Ts1]   % elle coupe les noms
    ;   negation(W) -> P = P0, N = oui, Q = Q0, Ts = Ts1
    ;   P = P0, N = N0, Q = Q0, Ts = [t(F, Le, P0, D, Fi, N0, Q0)|Ts1]
    ),
    lire(Ms, P, N, Q, Fi, Ts1).

apostrophe(F) :- memberchk(F, ['\'', '’']).
guillemet(F) :- memberchk(F, ['\'', '‘', '’', '"', '“', '”', '«', '»']).
ponctuation(F) :- memberchk(F, [',', ';', ':', '.', '!', '?']).
negation(W) :- memberchk(W, [without, not, no, never, nor, sans, pas, non, ni, jamais, aucun, aucune]).

% les titres et dignités devant un nom ne font pas partie du nom (« St. Odilia », « King Necho II ») ; ils restent des
% mots
titre_devant(W) :- memberchk(W, [saint, sainte, st, 'st.', ste, 'ste.', s, 's.', san, santa, santo, sankt, king, queen,
    emperor, empress, pope, prophet, bishop, prince, princess, duke, count, lord, lady, sir, roi, reine, empereur,
    impératrice, pape, prophète, évêque, princesse, duc, comte, dame]).

majuscule(F) :- sub_atom(F, 0, 1, _, C), char_type(C, upper(_)), \+ char_type(C, digit(_)).
% un mot tout en capitales (« NAME », « II », « AA ») : un emplacement, un chiffre romain, une rubrique ; ni nom ni mot
capitales(F) :- atom_length(F, L), L >= 2, upcase_atom(F, F), \+ ( sub_atom(F, _, 1, _, C), char_type(C, digit(_)) ).

% un mot qui peut entrer dans un nom : à majuscule, hors parenthèse de mot clé (un qualificatif), hors négation
candidat_de_nom(t(F, _, P, _, _, non, _), ctx(_, Sorte, _, oui)) :-
    majuscule(F), \+ capitales(F), \+ ( Sorte == mot_cle, P > 0 ).

% les suites « Maj (lien Maj)* » à même profondeur, puis, en anglais, la vérification par WordNet : une suite est un
% nom si WordNet la connaît avec sa majuscule (« Wise Men », « Old Testament ») ; sinon chaque mot doit être un nom
% propre : connu de WordNet avec sa majuscule (« Peter », « Bible »), ou inconnu de lui en minuscules (« Hesperides ») ;
% « Magic », « Start », « Waiting » (rubriques) sont des mots communs
suites(Ts, Ctx, Suites) :-
    (   Ts = [] -> Suites = []
    ;   Ts = [T|Ts1], candidat_de_nom(T, Ctx)
    ->  T = t(_, _, P, _, _, _, _), suite(Ts1, Ctx, P, S, Reste), Suites = [[T|S]|Suites1], suites(Reste, Ctx, Suites1)
    ;   Ts = [_|Ts1], suites(Ts1, Ctx, Suites)
    ).
suite(Ts, Ctx, P, S, Reste) :-
    Ctx = ctx(L, _, _, _),
    (   Ts = [T|Ts1], T = t(_, _, P, _, _, _, _), candidat_de_nom(T, Ctx)
    ->  S = [T|S1], suite(Ts1, Ctx, P, S1, Reste)
    ;   liens(Ts, L, P, Ls, [T|Ts1]), Ls \== [], T = t(_, _, P, _, _, _, _), candidat_de_nom(T, Ctx)
    ->  append(Ls, [T|S1], S), suite(Ts1, Ctx, P, S1, Reste)
    ;   S = [], Reste = Ts
    ).
liens([T|Ts], L, P, [T|Ls], Reste) :-
    T = t(F, _, P, _, _, _, _), downcase_atom(F, W), lien_de_nom(L, W), !, liens(Ts, L, P, Ls, Reste).
liens(Ts, _, _, [], Ts).

% les noms d'une suite, après les titres et la vérification de langue
noms_de_suite(S0, Ctx, Noms) :-
    sans_titres(S0, S),
    (   S == [] -> Noms = []
    ;   Ctx = ctx(en, _, _, _), \+ connu_avec_majuscule(S, Ctx)
    ->  sous_suites_propres(S, Ctx, Noms)
    ;   Noms = [S]
    ).

sans_titres([T|Ts], S) :- T = t(F, _, _, _, _, _, _), downcase_atom(F, W), titre_devant(W), Ts \== [], !, sans_titres(Ts, S).
sans_titres(S, S).

connu_avec_majuscule(S, Ctx) :- texte_de_suite(S, Ctx, Nom), wordnet:s(_, _, Nom, n, _, _), !.

% en anglais, une suite que WordNet ne connaît pas se réduit à ses sous-suites de noms propres (les liens « of »,
% « the » n'y restent qu'entre deux noms propres)
sous_suites_propres(S, Ctx, Noms) :- sous_suites(S, [], Noms0), include(non_vide, Noms0, Noms1), maplist(sans_liens_aux_bords(Ctx), Noms1, Noms2), include(non_vide, Noms2, Noms).
sous_suites([], Acc, [R]) :- reverse(Acc, R).
sous_suites([T|Ts], Acc, Noms) :-
    T = t(F, _, _, _, _, _, _),
    (   ( majuscule(F) -> propre_en(F) ; true )
    ->  sous_suites(Ts, [T|Acc], Noms)
    ;   reverse(Acc, R), Noms = [R|Noms1], sous_suites(Ts, [], Noms1)
    ).
sans_liens_aux_bords(Ctx, S0, S) :-
    Ctx = ctx(L, _, _, _),
    exclude_debut(L, S0, S1), reverse(S1, R1), exclude_debut(L, R1, R2), reverse(R2, S).
exclude_debut(L, [t(F, _, _, _, _, _, _)|Ts], S) :- downcase_atom(F, W), lien_de_nom(L, W), !, exclude_debut(L, Ts, S).
exclude_debut(_, S, S).
non_vide(X) :- X \== [].

propre_en(F) :- wordnet:s(_, _, F, _, _, _), !.
propre_en(F) :-
    downcase_atom(F, W), \+ wordnet:s(_, _, W, _, _, _),
    \+ ( catch(morphologie:tous_lemmes(W, Ls), _, fail), member(X, Ls), wordnet:s(_, _, X, _, _, _) ).

% le texte d'une suite : pris dans la partie lue, de son premier à son dernier mot
texte_de_suite(S, ctx(_, _, Texte, _), Nom) :-
    S = [t(F0, _, _, D, _, _, _)|_], last(S, t(_, _, _, _, Fi, _, _)),
    (   integer(D), D >= 0, Fi > D, L is Fi - D, sub_atom(Texte, D, L, _, Nom0) -> true
    ;   findall(F, member(t(F, _, _, _, _, _, _), S), Fs), atomic_list_concat(Fs, ' ', Nom0), F0 = F0
    ),
    sans_ponctuation(Nom0, Nom).

% les noms d'un texte : les titres cités entre guillemets, puis les suites de mots à majuscule
noms_du_texte(Ts, Ctx, Noms) :-
    findall(C, cite(Ts, C), Cs),
    exclude([T]>>( T = t(_, _, _, _, _, _, oui) ), Ts, Ts1),
    suites(Ts1, Ctx, Ss),
    findall(N, ( member(S, Ss), noms_de_suite(S, Ctx, Ns), member(N, Ns) ), Ns1),
    append(Cs, Ns1, Noms).

cite(Ts, C) :-
    Ts = [_|_], append(_, [T0|Reste], Ts), T0 = t(F, _, _, _, _, _, oui), majuscule(F),
    \+ ( append(_, [Tp, T0|_], Ts), Tp = t(_, _, _, _, _, _, oui) ),           % début d'une citation
    citation([T0|Reste], C).
citation([T|Ts], [T|C]) :- T = t(_, _, _, _, _, _, oui), !, citation(Ts, C).
citation(_, []).

element(Ts, Ctx, G-K) :-
    Ctx = ctx(_, _, _, Permis), Permis == oui,
    noms_du_texte(Ts, Ctx, Noms), member(S, Noms),
    texte_de_suite(S, Ctx, Nom), raisonnement:normaliser_nom(Nom, K), atom_length(K, N), N >= 2,
    ( G = nom ; S = [t(_, _, 0, _, _, _, non)|_], G = exige ).     % hors parenthèse et hors citation : une personne
                                                                   % ou un lieu du sujet (exige/3, après les lieux)
element(Ts, Ctx, mot-W) :-
    Ctx = ctx(_, _, _, Permis),
    ( Permis == oui -> noms_du_texte(Ts, Ctx, Noms), append(Noms, DansNoms) ; DansNoms = [] ),
    member(T, Ts), \+ memberchk(T, DansNoms), T = t(F, _, _, _, _, non, _), \+ capitales(F),
    mot_plein(T, Ctx, W).

% « Rome; » : une ponctuation collée par la segmentation
sans_ponctuation(F0, F) :-
    atom_codes(F0, Cs0), reverse(Cs0, R0), garder_lettres_finales(R0, R), reverse(R, Cs), atom_codes(F, Cs).
garder_lettres_finales([C|Cs], R) :- \+ code_type(C, alpha), !, garder_lettres_finales(Cs, R).
garder_lettres_finales(Cs, Cs).

% un mot plein est gardé par son lemme, ou par sa forme quand le lemmatiseur se trompe hors contexte, sur un libellé
% télégraphique (« livre » → livrer, « encens » → encen, « reed » → re, « saint » → saindre) :
%   en anglais, le lemme d'UDPipe est gardé si la morphologie de WordNet le donne pour la forme ; sinon les lemmes de
%   WordNet pour la forme ; sinon le lemme et la forme ;
%   en français, sans lexique, c'est le corpus des libellés qui atteste : un mot est attesté s'il apparaît comme forme
%   et comme lemme dans les libellés et mots clés français ; on garde le lemme et la forme qui sont attestés (« mère »,
%   pas « mères » ; « saint », pas « saindre »), et le lemme si aucun ne l'est
mot_plein(t(F, Le0, _, _, _, _, _), ctx(L, _, _, _), W) :-
    downcase_atom(F, Fm), \+ ferme(L, Fm),
    ( Le0 == '_' -> Le = F ; Le = Le0 ), downcase_atom(Le, Lm),
    candidats_mot(L, Fm, Lm, Ws), member(W, Ws),
    \+ ferme(L, W), atom_length(W, N), N >= 3,
    atom_codes(W, Cs), forall(member(C, Cs), ( code_type(C, alpha), \+ code_type(C, digit(_)) ; C == 0'- )).

candidats_mot(en, Fm, Lm, Ws) :- !,
    (   catch(morphologie:tous_lemmes(Fm, Ls), _, fail), memberchk(Lm, Ls) -> Ws = [Lm]
    ;   connus_de_wordnet(Fm, Ks), Ks \== [] -> Ws = Ks             % « midwives » → midwife (UDPipe : midwive)
    ;   Fm == Lm -> Ws = [Lm]
    ;   Ws = [Lm, Fm]
    ).
candidats_mot(_, Fm, Lm, Ws) :-
    sort([Lm, Fm], Cs),
    include(atteste_fr, Cs, Ws0),
    ( Ws0 == [] -> Ws = [Lm] ; Ws = Ws0 ).

connus_de_wordnet(Fm, Ks) :-
    catch(morphologie:tous_lemmes(Fm, Ls), _, fail),
    include([X]>>once(wordnet:s(_, _, X, _, _, _)), Ls, Ks).

:- dynamic lemme_vu/1, forme_vue/1.
atteste_fr(W) :- lemme_vu(W), forme_vue(W).

% --- Construction ----------------------------------------------------------------------------------------------------

:- dynamic lu/5.        % lu(N, Langue, Origine, Elements)  -- par partie de libellé ou par mot clé

construire_sujets(Fichier) :-
    retractall(lu(_, _, _, _, _)),
    forall(member(L, [en, fr]), analyser_langue(L)),
    setup_call_cleanup(open(Fichier, write, S, [encoding(utf8)]),
        ( format(S, ":- module(sujets_index, [profil/5, rarete/4, exige/3]).~n:- encoding(utf8).~n", []),
          forall(profil_calcule(N, L, G, E, O), format(S, "profil(~q, ~q, ~q, ~q, ~q).~n", [N, L, G, E, O])),
          forall(exige_calcule(N, L, K), format(S, "exige(~q, ~q, ~q).~n", [N, L, K])),
          forall(rarete_calculee(L, G, E, Nb), format(S, "rarete(~q, ~q, ~q, ~d).~n", [L, G, E, Nb])) ),
        close(S)).

analyser_langue(L) :-
    findall(t(N, O, libelle, P), ( notation_de_sujet(N), iconclass:libelle(N, L, T), parties(T, L, Ps),
                                   member(O-P, Ps) ), Ls),
    findall(t(N, mot_cle, mot_cle, K), ( notation_de_sujet(N), iconclass:mot_cle(N, L, K) ), Ks),
    append(Ls, Ks, Tous),
    findall(S, ( member(t(_, _, _, P), Tous), atom_string(P, S) ), Textes),
    length(Textes, NT), format(user_error, "~w : ~d textes à analyser~n", [L, NT]),
    lots(Textes, 2000, Lots),
    concurrent_maplist(analyser_lot_(L), Lots, As0), append(As0, As),
    attestations(As),
    maplist(enregistrer(L), Tous, As).

attestations(As) :-
    retractall(lemme_vu(_)), retractall(forme_vue(_)),
    findall(Lm-Fm, ( member(Ph, As), member(phrase(Ms), Ph), member(mot(_, F, Le, _, _, _, _, _, _), Ms),
                     downcase_atom(F, Fm), downcase_atom(Le, Lm) ), Ps),
    findall(X, member(X-_, Ps), Ls0), sort(Ls0, Ls), forall(member(X, Ls), assertz(lemme_vu(X))),
    findall(X, member(_-X, Ps), Fs0), sort(Fs0, Fs), forall(member(X, Fs), assertz(forme_vue(X))).

enregistrer(L, t(N, O, Sorte, P), Ph) :-
    noms_permis(L, N, O, Sorte, Permis),
    elements(Ph, ctx(L, Sorte, P, Permis), Els), assertz(lu(N, L, O, Sorte, Els)).

% en français, une partie n'a de noms propres que si la partie anglaise de même origine en a (ou s'il n'y a pas de
% libellé anglais) ; un mot clé, si le libellé ou les mots clés anglais de la notation en ont
noms_permis(en, _, _, _, oui) :- !.
noms_permis(_, N, O, Sorte, Permis) :-
    (   \+ lu(N, en, _, _, _) -> Permis = oui
    ;   Sorte == libelle, lu(N, en, O, libelle, Els), memberchk(nom-_, Els) -> Permis = oui
    ;   Sorte == mot_cle, lu(N, en, O2, _, Els), memberchk(O2, [propre, mot_cle]), memberchk(nom-_, Els) -> Permis = oui
    ;   Permis = non
    ).

analyser_lot_(L, Lot, A) :- udpipe:analyser_lot(Lot, L, [syntaxe(false)], A), format(user_error, ".", []).

lots([], _, []) :- !.
lots(L, N, [P|Ps]) :- length(P, N), append(P, R, L), !, lots(R, N, Ps).
lots(L, _, [L]).

profil_calcule(N, L, G, E, O) :-
    distinct(N-L-G-E-O, ( lu(N, L, O, _, Els), member(G-E, Els), G \== exige )).
profil_calcule(N, L, nom, E, herite) :-
    distinct(N-L-E, ( lu(N, L, propre, _, _), arbre:ancetre(N, A),
                      lu(A, L, propre, _, Els), member(nom-E, Els), \+ ( lu(N, L, _, _, Els2), memberchk(nom-E, Els2) ) )).

% les personnes qu'un sujet exige (condition nécessaire, hypotheses.pl) : les noms de sa partie propre de libellé, hors
% parenthèse (« Hercules (Heracles) », « (Acts 6:1-6) ») et hors citation, sauf les lieux (« first bishop of Rome ») :
% en anglais, un nom que WordNet range sous « location » ; en français, un nom que la partie anglaise a aussi et qu'elle
% range sous « location » (« Rome ») ; sans cela, un nom français est exigé (Pierre n'est pas la ville du Dakota)
exige_calcule(N, L, K) :-
    distinct(N-L-K, ( lu(N, L, propre, libelle, Els), memberchk(exige-K, Els) )),
    \+ lieu(N, L, K).
lieu(_, en, K) :- nom_de_lieu(K).
lieu(N, fr, K) :- lu(N, en, _, _, Els), memberchk(nom-K, Els), nom_de_lieu(K).

% un nom (normalisé : NEW YORK) que WordNet range sous « location » (100027167), cherché sous sa forme à majuscules
% (New York) : une recherche directe, pas un parcours de WordNet
:- table nom_de_lieu/1.
nom_de_lieu(K) :-
    atomic_list_concat(Ms, ' ', K), maplist(capitaliser, Ms, Cs), atomic_list_concat(Cs, ' ', W),
    wordnet:s(S, _, W, n, _, _), raisonnement:sens_de_lieu(S), !.
capitaliser(M, C) :-
    downcase_atom(M, D), ( sub_atom(D, 0, 1, A, I) -> upcase_atom(I, IU), sub_atom(D, 1, A, 0, R), atom_concat(IU, R, C) ; C = D ).

porteur(O) :- memberchk(O, [propre, attribut, mot_cle]).

rarete_calculee(L, G, E, Nb) :-
    findall(L-G-E-N, ( lu(N, L, O, _, Els), porteur(O), member(G-E, Els), G \== exige ), Xs0), sort(Xs0, Xs),
    findall(L-G-E, member(L-G-E-_, Xs), Cles0), msort(Cles0, Cles),
    clumped_(Cles, Comptes), member((L-G-E)-Nb, Comptes).

clumped_(Xs, Cs) :- clumped(Xs, Cs).

% pour essayer une lecture : elements_du_texte('bath of Venus', en, libelle, Parties) (en français, noms toujours
% permis et sans attestation par le corpus)
elements_du_texte(T, L, Sorte, Parties) :-
    ( Sorte == libelle -> parties(T, L, Ps) ; Ps = [mot_cle-T] ),
    findall(S, ( member(_-P, Ps), atom_string(P, S) ), Ss),
    udpipe:analyser_lot(Ss, L, [syntaxe(false)], As),
    findall(O-Els, ( nth1(I, Ps, O-P), nth1(I, As, Ph), elements(Ph, ctx(L, Sorte, P, oui), Els) ), Parties).

% la mesure de l'étiqueteur sur les libellés : mots en minuscules, hors classes fermées, qu'UDPipe range dans une
% classe fermée (ADP, DET, PRON, CCONJ, SCONJ, AUX, PART)
categories_fermees_fautives(Phrases, L, Nb-Tot) :-
    findall(C, ( member(phrase(Ms), Phrases), member(mot(_, F, _, C, _, _, _, _, _), Ms),
                 \+ majuscule(F), downcase_atom(F, W), atom_length(W, Lg), Lg >= 3, \+ ferme(L, W),
                 atom_codes(W, Cs), forall(member(X, Cs), code_type(X, alpha)) ), Cats),
    length(Cats, Tot),
    include([C]>>memberchk(C, ['ADP', 'DET', 'PRON', 'CCONJ', 'SCONJ', 'AUX', 'PART']), Cats, Fs), length(Fs, Nb).
