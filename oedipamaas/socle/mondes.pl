/*  L'ancrage dans l'image, version 2 : les deux mondes (docs/PLAN_F3.md, § 6, étape 2).

    Un texte sur une œuvre parle de deux mondes : le monde figuré (ce que l'image montre) et le monde réel (l'œuvre
    comme objet, sa création, son histoire, sa réception). Chaque proposition du texte appartient à l'un d'eux, et un
    référent appartient au monde de la proposition qui le régit. La décision se fait par des règles de langue
    explicites, sans iconographie et sans poids :

    1. Les ponts. Un verbe de création (« peindre », « depict », « représenter ») relie les deux mondes : ses
       compléments sont figurés ; son sujet (ou son agent au passif) est l'artiste, ou l'œuvre (monde réel). Un verbe de
       monstration (« montrer », « show », « présenter ») a des compléments figurés et un sujet qui est l'œuvre ou une
       figure. Un nom de représentation (« portrait de », « study of », « figure d'un ») a un complément figuré. Le
       verbe de pont lui-même n'est pas une action de la scène (portée « oeuvre »).
    2. Le temps. La description d'une image se fait au présent (présent de description) ou sans verbe (notice) ;
       l'histoire de l'œuvre et de l'artiste se raconte au passé. Une proposition finie au passé (ou au parfait,
       « a été exposé », « has been ») est du monde réel (« histoire »), sauf sous un pont ; une proposition finie au
       présent, ou sans verbe, est du monde figuré. Une proposition non finie (participe, gérondif, infinitif) prend le
       monde de ce à quoi elle se rattache.
    3. L'œuvre et ses producteurs. Un nom d'œuvre (« painting », « dessin ») désigne l'objet (« oeuvre ») ; une
       proposition au présent dont le sujet est un nom d'œuvre parle de l'œuvre (« This study conveys a sense of
       vitality ») ; le possesseur d'un nom d'œuvre est l'artiste (« Manet's painting ») ; un nom de producteur
       (« painter », « graveur ») est du monde réel, et les noms propres qui le sont une fois (sujet d'un verbe de
       création, possesseur d'une œuvre, apposés à un producteur) le sont partout dans le texte.
    4. Les verbes de l'histoire de l'œuvre (« exposer », « acquire ») et de sa fabrication (« coller », « imprimer »)
       sont du monde réel, à tout temps.

    Les listes ci-dessous sont des classes de mots de la langue des textes sur l'art (règles de langue écrites à la
    main, décision du cahier des charges), pas de l'iconographie.

    mondes(+FinTitre, +Ts, +Ents, +Fs0, -Fs) : requalifie la portée « represente » des assertions de Fs0 en
    « histoire » ou « oeuvre » selon le monde de leurs entités (ou de leur événement), et ajoute saillance(E, principal)
    pour les référents figurés que le texte donne pour le sujet de l'image ; FinTitre : la fin du titre dans le texte
    (0 sans titre).
*/
:- module(mondes, [ mondes/5, monde_entite/4 ]).
:- encoding(utf8).

% --- Classes de mots --------------------------------------------------------------------------------------------------

creation(L) :- memberchk(L, [peindre, dessiner, sculpter, graver, représenter, dépeindre, figurer, portraiturer,
    croquer, esquisser, modeler, paint, draw, sculpt, carve, engrave, etch, depict, portray, render, represent, sketch,
    picture, model]).
monstration(L) :- memberchk(L, [montrer, présenter, illustrer, apparaître, voir, apercevoir, distinguer, figurer,
    show, present, feature, display, illustrate, appear, see, capture]).
production(L) :- memberchk(L, [signer, annoter, inscrire, dater, numéroter, marquer, coller, monter, encadrer,
    imprimer, éditer, publier, rapporter, doubler, entoiler, sign, inscribe, date, annotate, number, mark, stamp,
    mount, frame, print, publish, glue, paste]).
% un adjectif de perception est un pont comme un verbe de monstration (« evident on the Virgin's cloak »)
perception(L) :- memberchk(L, [visible, evident, apparent, discernible, perceptible, reconnaissable, recognizable,
    recognisable]).
% un cadre de l'image : un référent qu'il situe est figuré, à tout temps (« The man on the left … has just been
% beaten »)
cadre(L) :- memberchk(L, [left, right, foreground, background, centre, center, middle, corner, top, bottom,
    distance, gauche, droite, 'premier-plan', 'arrière-plan', plan, fond, centre, milieu, coin, angle, haut, bas]).
histoire(L) :- memberchk(L, [exposer, acquérir, acheter, vendre, léguer, commander, attribuer, collectionner,
    étudier, exhibit, acquire, buy, sell, bequeath, commission, attribute, collect, study, donate, purchase, own]).

nom_d_oeuvre(L) :- memberchk(L, [painting, picture, drawing, study, sketch, engraving, print, etching, lithograph,
    woodcut, work, composition, portrait, panel, canvas, sheet, plate, sculpture, statue, pastel, watercolor,
    watercolour, miniature, illustration, photograph, tableau, peinture, dessin, étude, esquisse, croquis, gravure,
    estampe, lithographie, œuvre, oeuvre, panneau, toile, feuille, planche, aquarelle, gouache, photographie]).
nom_de_representation(L) :- nom_d_oeuvre(L).
nom_de_representation(L) :- memberchk(L, [figure, scene, view, image, representation, depiction, portrayal,
    scène, vue, représentation, effigie, effigy]).
producteur(L) :- memberchk(L, [painter, artist, sculptor, engraver, draughtsman, draftsman, printmaker, lithographer,
    photographer, architect, workshop, critic, collector, dealer, publisher, printer, peintre, artiste, sculpteur,
    graveur, dessinateur, lithographe, photographe, architecte, atelier, critique, collectionneur, marchand, éditeur,
    imprimeur]).

% --- Jetons : t(S, I, Forme, Lemme, Cat, Traits, Tete, Rel, D, F) ----------------------------------------------------

jeton(Ts, S, I, T) :- T = t(S, I, _, _, _, _, _, _, _, _), memberchk(T, Ts).
enfant(Ts, S, I, T) :- T = t(S, _, _, _, _, _, I, _, _, _), member(T, Ts).
rel_base(R0, R) :- ( sub_atom(R0, B, _, _, ':') -> sub_atom(R0, 0, B, _, R) ; R = R0 ).
lemme(t(_, _, _, L0, _, _, _, _, _, _), L) :- downcase_atom(L0, L).
trait(t(_, _, _, _, _, Tr, _, _, _, _), N, V) :- memberchk(N=V, Tr).

% une tête de proposition : un verbe, ou un prédicat nominal ou adjectival à copule
tete_de_proposition(_, T) :- T = t(_, _, _, _, 'VERB', _, _, _, _, _), !.
tete_de_proposition(_, T) :- T = t(_, _, _, _, 'ADJ', _, _, _, _, _), lemme(T, L), perception(L), !.
tete_de_proposition(Ts, T) :- T = t(S, I, _, _, _, _, _, _, _, _), enfant(Ts, S, I, X), X = t(_, _, _, _, _, _, _, cop, _, _), !.

auxiliaires(Ts, T, As) :-
    T = t(S, I, _, _, _, _, _, _, _, _),
    findall(X, ( enfant(Ts, S, I, X), X = t(_, _, _, _, _, _, _, R, _, _), rel_base(R, RB), memberchk(RB, [aux, cop]) ), As).

finie(Ts, T) :- ( trait(T, 'VerbForm', 'Fin') -> true ; auxiliaires(Ts, T, As), member(A, As), trait(A, 'VerbForm', 'Fin') ), !.

% au passé : le verbe fini ou un auxiliaire au passé ou à l'imparfait ; ou un parfait (« has been », « a été »,
% « est né » : auxiliaire de temps, pas de passif)
passee(Ts, T) :-
    (   trait(T, 'VerbForm', 'Fin'), ( trait(T, 'Tense', 'Past') ; trait(T, 'Tense', 'Imp') )
    ;   auxiliaires(Ts, T, As), member(A, As), trait(A, 'VerbForm', 'Fin'), ( trait(A, 'Tense', 'Past') ; trait(A, 'Tense', 'Imp') )
    ;   auxiliaires(Ts, T, As), member(A, As), A = t(_, _, _, _, _, _, _, R, _, _), lemme(A, LA),
        ( memberchk(LA, [have, avoir]), R \== 'aux:pass' ; R == 'aux:tense' )
    ), !.

passif(Ts, T) :-
    T = t(S, I, _, _, _, _, _, _, _, _),
    once(( enfant(Ts, S, I, X), X = t(_, _, _, _, _, _, _, R, _, _), memberchk(R, ['aux:pass', 'nsubj:pass']) )).

sujet_actif(Ts, P, A) :- A = t(_, _, _, _, _, _, _, R, _, _), rel_base(R, nsubj), R \== 'nsubj:pass', \+ passif(Ts, P).
agent(Ts, P, A) :-
    passif(Ts, P), A = t(S, IA, _, _, _, _, _, R, _, _), rel_base(R, obl),
    ( R == 'obl:agent' -> true ; enfant(Ts, S, IA, C), C = t(_, _, _, _, _, _, _, case, _, _), lemme(C, LC), memberchk(LC, [by, par]) ), !.

sujet_d_oeuvre(Ts, P) :-
    P = t(S, I, _, _, _, _, _, _, _, _), enfant(Ts, S, I, X), X = t(_, _, _, _, _, _, _, R, _, _), rel_base(R, nsubj),
    lemme(X, LX), nom_d_oeuvre(LX), !.

% --- Le monde d'un jeton ---------------------------------------------------------------------------------------------

% monde_nominal(+Ts, +T, -M) : le monde d'un référent dont T est le jeton tête
monde_nominal(Ts, T, M) :-
    lemme(T, L),
    (   nom_d_oeuvre(L) -> M = oeuvre
    ;   producteur(L) -> M = histoire
    ;   montre_ou_situe(Ts, T) -> M = represente
    ;   tete_de_proposition(Ts, T), T \= t(_, _, _, _, 'VERB', _, _, _, _, _) -> monde_proposition(Ts, T, M)
    ;   T = t(S, _, _, _, _, _, H, R, _, _),
        (   H =:= 0 -> M = represente                                   % sans verbe : une notice décrit
        ;   jeton(Ts, S, H, P), lemme(P, LP),
            (   R == 'nmod:poss', nom_d_oeuvre(LP) -> M = histoire          % « Manet's painting »
            ;   rel_base(R, nmod), nom_de_representation(LP) -> M = represente   % « portrait de X »
            ;   tete_de_proposition(Ts, P) -> monde_argument(Ts, P, T, M)
            ;   monde_nominal(Ts, P, M)          % épithète, apposition, coordination : le monde de son nom
            )
        )
    ).

% monde_argument(+Ts, +P, +A, -M) : le monde de l'argument A de la proposition de tête P
monde_argument(Ts, P, A, M) :-
    lemme(P, L), lemme(A, LA),
    (   creation(L)
    ->  (   ( sujet_actif(Ts, P, A) ; agent(Ts, P, A) ) -> ( nom_d_oeuvre(LA) -> M = oeuvre ; M = histoire )
        ;   M = represente
        )
    ;   ( monstration(L) ; perception(L) )
    ->  (   sujet_actif(Ts, P, A) -> ( nom_d_oeuvre(LA) -> M = oeuvre ; monde_proposition(Ts, P, M) )
        ;   M = represente
        )
    ;   production(L) -> M = oeuvre
    ;   histoire(L) -> M = histoire
    ;   sujet_d_oeuvre(Ts, P), \+ passee(Ts, P)                     % « cette estampe exalte la mémoire de ce
    ->  ( sujet_actif(Ts, P, A) -> M = oeuvre ; M = represente )   % militaire » : l'œuvre montre
    ;   monde_proposition(Ts, P, M)
    ).

% monde_proposition(+Ts, +P, -M) : le monde d'une proposition, par son temps
monde_proposition(Ts, P, M) :-
    (   passee(Ts, P) -> M = histoire
    ;   finie(Ts, P) -> M = represente
    ;   P = t(S, _, _, _, _, _, H, _, _, _), H > 0, jeton(Ts, S, H, Q)
    ->  (   tete_de_proposition(Ts, Q) -> monde_argument(Ts, Q, P, M) ; monde_nominal(Ts, Q, M) )
    ;   M = represente
    ).

% un référent que qualifie un participe de pont (« a devout woman, shown at lower right », « the watermill seen
% here ») ou que situe un cadre de l'image (« the man on the left ») est figuré, quel que soit le monde de la
% proposition qui le régit
montre_ou_situe(Ts, T) :-
    T = t(S, I, _, _, _, _, _, _, _, _),
    (   enfant(Ts, S, I, X), X = t(_, _, _, _, _, _, _, R, _, _), rel_base(R, acl), lemme(X, LX),
        ( creation(LX) ; monstration(LX) ), \+ trait(X, 'VerbForm', 'Fin')
    ;   enfant(Ts, S, I, X), X = t(_, IX, _, _, _, _, _, R, _, _), rel_base(R, nmod), lemme(X, LX), cadre(LX),
        enfant(Ts, S, IX, C), C = t(_, _, _, _, _, _, _, case, _, _)
    ), !.

% le monde d'un événement : un pont, une fabrication, une histoire ne sont pas des actions de la scène
monde_evenement(Ts, T, M) :-
    lemme(T, L),
    (   ( creation(L) ; monstration(L) ; production(L) ) -> M = oeuvre
    ;   histoire(L) -> M = histoire
    ;   monde_proposition(Ts, T, M)
    ).

% --- Les noms propres de l'artiste ----------------------------------------------------------------------------------

% un nom propre est celui d'un acteur du monde réel s'il l'est une fois : sujet ou agent d'un verbe de création,
% possesseur d'une œuvre, apposé à un producteur ou sujet d'une copule de producteur (« Béranger is known as a
% painter »)
nom_du_monde_reel(Ts, Ents, Fs, K) :-
    member(ent(E, _, _, T, _), Ents), memberchk(nom(_, E, Nom, _), Fs), cle(Nom, K),
    once(acteur_reel(Ts, T)).

acteur_reel(Ts, T) :-
    T = t(S, _, _, _, _, _, H, R, _, _), H > 0, jeton(Ts, S, H, P), lemme(P, LP),
    (   creation(LP), ( sujet_actif(Ts, P, T) ; agent(Ts, P, T) )
    ;   R == 'nmod:poss', nom_d_oeuvre(LP)
    ;   rel_base(R, appos), producteur(LP)
    ).
acteur_reel(Ts, T) :-                                      % apposition ou attribut : « X, a painter », « X is a painter »
    T = t(S, I, _, _, _, _, H, R, _, _),
    (   enfant(Ts, S, I, X), X = t(_, _, _, _, _, _, _, RX, _, _), rel_base(RX, appos), lemme(X, LX), producteur(LX)
    ;   rel_base(R, nsubj), H > 0, jeton(Ts, S, H, P), lemme(P, LP), producteur(LP)
    ;   rel_base(R, nsubj), H > 0, jeton(Ts, S, H, P), enfant(Ts, S, _, X), X = t(_, _, _, _, _, _, HX, _, _, _),
        P = t(_, IP, _, _, _, _, _, _, _, _), HX == IP, lemme(X, LX), producteur(LX)
    ).

cle(Nom, K) :- atom(Nom), downcase_atom(Nom, K0), normalize_space(atom(K), K0).

% --- Requalification -------------------------------------------------------------------------------------------------

monde_entite(Ts, Ents, E, M) :- member(ent(E, _, _, T, _), Ents), !, monde_nominal(Ts, T, M).

mondes(FinTitre, Ts, Ents, Fs0, Fs) :-
    findall(K, nom_du_monde_reel(Ts, Ents, Fs0, K), Ks0), sort(Ks0, Ks),
    findall(E-M, ( member(ent(E, _, _, T, _), Ents), monde_ent(Ts, Fs0, Ks, E, T, M) ), EMs),
    findall(V-M, ( member(evenement(V, _, passage_de(T)), Fs0), once(monde_evenement(Ts, T, M)) ), VMs),
    maplist(requalifier(Fs0, EMs, VMs), Fs0, Fs1),
    findall(saillance(E, principal),
            ( member(E-represente, EMs), member(ent(E, _, _, T, _), Ents), saillant(FinTitre, Ts, T) ), Ss),
    append(Fs1, Ss, Fs).

% --- La saillance : ce que le texte donne pour le sujet de l'image ---------------------------------------------------

% Un texte annonce le sujet de l'image par un pont (« depicts X », « X is shown », « Portrait de X », « study of a young
% woman ») ou le décrit d'emblée (sa première phrase du monde figuré, souvent sans verbe dans une notice : « Figure d'un
% jeune homme en pied, vêtu … »). Un référent est saillant s'il est dans le sous-arbre d'un complément de pont, ou dans
% la première phrase figurée ; les autres référents figurés sont des composants. Un sujet doit s'appuyer sur un élément
% saillant (hypotheses.pl).
saillant(F, Ts, T) :- \+ dans_le_titre(F, T), tete_saillante(Ts, H), sous_arbre(Ts, H, T), !.
saillant(F, Ts, T) :- T = t(S, _, _, _, _, _, _, _, _, _), premiere_phrase_figuree(F, Ts, S), !.

dans_le_titre(F, t(_, _, _, _, _, _, _, _, D, _)) :- D >= 0, D < F.

tete_saillante(Ts, A) :-
    member(P, Ts), lemme(P, LP), P = t(S, IP, _, _, _, _, _, _, _, _),
    (   ( creation(LP) ; monstration(LP) ; perception(LP) ), tete_de_proposition(Ts, P)
    ->  enfant(Ts, S, IP, A), A = t(_, _, _, _, _, _, _, R, _, _), rel_base(R, RB),
        memberchk(RB, [obj, obl, xcomp, iobj, nsubj, ccomp]), \+ sujet_actif(Ts, P, A), \+ agent(Ts, P, A)
    ;   nom_de_representation(LP)
    ->  enfant(Ts, S, IP, A), A = t(_, _, _, _, _, _, _, R, _, _), rel_base(R, nmod)
    ;   P = t(_, _, _, _, 'VERB', _, _, R, _, _), rel_base(R, acl), \+ trait(P, 'VerbForm', 'Fin'),
        ( creation(LP) ; monstration(LP) ), P = t(_, _, _, _, _, _, HP, _, _, _), jeton(Ts, S, HP, A)
    ).

sous_arbre(_, H, H).
sous_arbre(Ts, H, T) :-
    T = t(S, _, _, _, _, _, HT, _, _, _), HT > 0, H = t(S, IH, _, _, _, _, _, _, _, _),
    HT \== IH, jeton(Ts, S, HT, P), P \== T, sous_arbre(Ts, H, P).

% la première phrase de la description dont la racine est du monde figuré (une phrase du titre ne compte pas : elle
% n'a que la modalité « titre » et ne fonde rien)
premiere_phrase_figuree(F, Ts, S) :-
    findall(S0, ( member(R, Ts), R = t(S0, _, _, _, _, _, 0, _, _, _), \+ dans_le_titre(F, R) ), Ss0), sort(Ss0, Ss),
    member(S1, Ss), member(R1, Ts), R1 = t(S1, _, _, _, _, _, 0, _, _, _), racine_figuree(Ts, R1), !,
    S == S1.

racine_figuree(Ts, R) :-
    lemme(R, L),
    (   nom_de_representation(L) -> true
    ;   tete_de_proposition(Ts, R) -> monde_proposition(Ts, R, represente)
    ;   monde_nominal(Ts, R, represente)
    ).

monde_ent(Ts, Fs, Ks, E, T, M) :-
    (   memberchk(nom(_, E, Nom, _), Fs), cle(Nom, K), memberchk(K, Ks) -> M = histoire
    ;   once(monde_nominal(Ts, T, M))
    ).

requalifier(Fs, EMs, VMs, portee(A, represente), portee(A, P)) :- !,
    (   memberchk(V-MV, VMs), V == A -> P = MV
    ;   entites_de(Fs, A, Es), Es \== [],
        findall(M, ( member(E, Es), memberchk(E-M, EMs) ), Ms),
        (   member(M, Ms), M \== represente -> P = M ; P = represente )
    ;   P = represente
    ).
requalifier(_, _, _, F, F).

entites_de(Fs, A, Es) :-
    (   memberchk(entite(A, _, _), Fs) -> Es = [A]
    ;   memberchk(nom(A, E, _, _), Fs) -> Es = [E]
    ;   memberchk(propriete(A, E, _, _), Fs) -> Es = [E]
    ;   memberchk(relation(A, E1, _, E2, _), Fs) -> Es = [E1, E2]
    ;   Es = []
    ).
