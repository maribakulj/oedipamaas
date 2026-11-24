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

% elements(+Phrases, +Langue, +Sorte, -Elements)
elements(Phrases, L, Sorte, Els) :-
    findall(E, ( member(phrase(Ms0), Phrases), profondeurs(Ms0, 0, Ms), element(Ms, L, Sorte, E) ), Els0),
    sort(Els0, Els).

% chaque mot reçoit sa profondeur de parenthèse : t(Forme, Lemme, Categorie, Profondeur)
profondeurs([], _, []).
profondeurs([mot(_, F, Le, C, _, _, _, _, _)|Ms], P0, Ts) :-
    (   F == '(' -> P is P0 + 1, Ts = Ts1
    ;   F == ')' -> P is max(0, P0 - 1), Ts = Ts1
    ;   P = P0, Ts = [t(F, Le, C, P0)|Ts1]
    ),
    profondeurs(Ms, P, Ts1).

element(Ts, L, Sorte, nom-K) :-
    noms(Ts, L, Sorte, Noms), member(Fs0, Noms), maplist(sans_ponctuation, Fs0, Fs),
    atomic_list_concat(Fs, ' ', Nom), raisonnement:normaliser_nom(Nom, K), atom_length(K, N), N >= 2.

% « Rome; » : une ponctuation collée par la segmentation
sans_ponctuation(F0, F) :-
    atom_codes(F0, Cs0), reverse(Cs0, R0), garder_lettres_finales(R0, R), reverse(R, Cs), atom_codes(F, Cs).
garder_lettres_finales([C|Cs], R) :- \+ code_type(C, alpha), !, garder_lettres_finales(Cs, R).
garder_lettres_finales(Cs, Cs).
element(Ts, L, Sorte, mot-W) :-
    member(T, Ts), \+ dans_un_nom(T, L, Sorte), mot_plein(T, L, W).

majuscule(F) :- sub_atom(F, 0, 1, _, C), char_type(C, upper(_)), \+ char_type(C, digit(_)).

% un mot à majuscule compte comme nom, sauf dans la parenthèse d'un mot clé (un qualificatif)
mot_de_nom(t(F, _, _, P), Sorte) :- majuscule(F), \+ ( Sorte == mot_cle, P > 0 ).
dans_un_nom(T, _, Sorte) :- mot_de_nom(T, Sorte).

% les noms : suites maximales « Maj (lien Maj)* » à même profondeur
noms([], _, _, []).
noms([T|Ts], L, Sorte, Noms) :-
    (   mot_de_nom(T, Sorte)
    ->  T = t(F, _, _, P), suite_de_nom(Ts, L, Sorte, P, Fs, Reste), Noms = [[F|Fs]|Noms1], noms(Reste, L, Sorte, Noms1)
    ;   noms(Ts, L, Sorte, Noms)
    ).

suite_de_nom(Ts, L, Sorte, P, Fs, Reste) :-
    (   Ts = [T|Ts1], T = t(F, _, _, P), mot_de_nom(T, Sorte)
    ->  Fs = [F|Fs1], suite_de_nom(Ts1, L, Sorte, P, Fs1, Reste)
    ;   liens(Ts, L, P, Ls, [T|Ts1]), Ls \== [], T = t(F, _, _, P), mot_de_nom(T, Sorte)
    ->  append(Ls, [F|Fs1], Fs), suite_de_nom(Ts1, L, Sorte, P, Fs1, Reste)
    ;   Fs = [], Reste = Ts
    ).

liens([t(F, _, _, P)|Ts], L, P, [F|Fs], Reste) :- downcase_atom(F, W), lien_de_nom(L, W), !, liens(Ts, L, P, Fs, Reste).
liens(Ts, _, _, [], Ts).

% un mot plein est gardé par son lemme et, si le lemme n'est pas attesté, par sa forme : hors contexte, sur un mot clé
% isolé, le lemmatiseur se trompe (« livre » → livrer, « encens » → encen, « reed » → re) ; en anglais, un lemme est
% attesté si la morphologie de WordNet le donne pour la forme ; en français, sans lexique, jamais : la forme est
% toujours gardée aussi
lemme_atteste(en, F, W) :- catch(morphologie:tous_lemmes(F, Ls), _, fail), memberchk(W, Ls).
mot_plein(t(F, Le0, _, _), L, W) :-
    downcase_atom(F, Fm), \+ ferme(L, Fm),
    ( Le0 == '_' -> Le = F ; Le = Le0 ), downcase_atom(Le, Lm),
    ( W = Lm ; Fm \== Lm, \+ lemme_atteste(L, Fm, Lm), W = Fm ),
    \+ ferme(L, W), atom_length(W, N), N >= 3,
    atom_codes(W, Cs), forall(member(C, Cs), ( code_type(C, alpha), \+ code_type(C, digit(_)) ; C == 0'- )).

% --- Construction ----------------------------------------------------------------------------------------------------

:- dynamic lu/5.        % lu(N, Langue, Origine, Elements)  -- par partie de libellé ou par mot clé

construire_sujets(Fichier) :-
    retractall(lu(_, _, _, _, _)),
    forall(member(L, [en, fr]), analyser_langue(L)),
    setup_call_cleanup(open(Fichier, write, S, [encoding(utf8)]),
        ( format(S, ":- module(sujets_index, [profil/5, rarete/4]).~n:- encoding(utf8).~n", []),
          forall(profil_calcule(N, L, G, E, O), format(S, "profil(~q, ~q, ~q, ~q, ~q).~n", [N, L, G, E, O])),
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
    maplist(enregistrer(L), Tous, As).

enregistrer(L, t(N, O, Sorte, _), Ph) :- elements(Ph, L, Sorte, Els), assertz(lu(N, L, O, Sorte, Els)).

analyser_lot_(L, Lot, A) :- udpipe:analyser_lot(Lot, L, [syntaxe(false)], A), format(user_error, ".", []).

lots([], _, []) :- !.
lots(L, N, [P|Ps]) :- length(P, N), append(P, R, L), !, lots(R, N, Ps).
lots(L, _, [L]).

profil_calcule(N, L, G, E, O) :-
    distinct(N-L-G-E-O, ( lu(N, L, O, _, Els), member(G-E, Els) )).
profil_calcule(N, L, nom, E, herite) :-
    distinct(N-L-E, ( lu(N, L, propre, _, _), arbre:ancetre(N, A), notation_de_sujet(A),
                      lu(A, L, propre, _, Els), member(nom-E, Els), \+ ( lu(N, L, _, _, Els2), memberchk(nom-E, Els2) ) )).

porteur(O) :- memberchk(O, [propre, attribut, mot_cle]).

rarete_calculee(L, G, E, Nb) :-
    findall(L-G-E-N, ( lu(N, L, O, _, Els), porteur(O), member(G-E, Els) ), Xs0), sort(Xs0, Xs),
    findall(L-G-E, member(L-G-E-_, Xs), Cles0), msort(Cles0, Cles),
    clumped_(Cles, Comptes), member((L-G-E)-Nb, Comptes).

clumped_(Xs, Cs) :- clumped(Xs, Cs).

% pour essayer une lecture : elements_du_texte('bath of Venus', en, libelle, Parties)
elements_du_texte(T, L, Sorte, Parties) :-
    ( Sorte == libelle -> parties(T, L, Ps) ; Ps = [mot_cle-T] ),
    findall(S, ( member(_-P, Ps), atom_string(P, S) ), Ss),
    udpipe:analyser_lot(Ss, L, [syntaxe(false)], As),
    findall(O-Els, ( nth1(I, Ps, O-_), nth1(I, As, Ph), elements(Ph, L, Sorte, Els) ), Parties).

% la mesure de l'étiqueteur sur les libellés : mots en minuscules, hors classes fermées, qu'UDPipe range dans une
% classe fermée (ADP, DET, PRON, CCONJ, SCONJ, AUX, PART)
categories_fermees_fautives(Phrases, L, Nb-Tot) :-
    findall(C, ( member(phrase(Ms), Phrases), member(mot(_, F, _, C, _, _, _, _, _), Ms),
                 \+ majuscule(F), downcase_atom(F, W), atom_length(W, Lg), Lg >= 3, \+ ferme(L, W),
                 atom_codes(W, Cs), forall(member(X, Cs), code_type(X, alpha)) ), Cats),
    length(Cats, Tot),
    include([C]>>memberchk(C, ['ADP', 'DET', 'PRON', 'CCONJ', 'SCONJ', 'AUX', 'PART']), Cats, Fs), length(Fs, Nb).
