/*  Spécialisation (conception 1.0, § 8) : descendre d'une notation sûre vers celles de ses enfants que la description
    soutient le mieux.

    Mots propres d'une notation : ses mots pleins absents du libellé de son parent (libelles:mots_propres/2), plus son
    nom entre parenthèses pour une notation à nom (le nom distingue le chêne de ses sœurs même si un autre chêne partage
    le mot). Part décrite d'un enfant : la part de ses mots propres dont une forme (le mot ou l'un de ses lemmes) est
    une forme de la description. À chaque nœud, on descend vers les enfants dont la part décrite est la plus grande
    parmi leurs sœurs, si elle n'est pas nulle (ex aequo gardés) : une comparaison entre sœurs, sans seuil écrit.

    Index (construit une fois) : propre(N, I, Forme), le I-ième mot propre de N sous chacune de ses formes ; et
    nb_propres(N, K).
*/
:- module(specialisation, [ construire_propres/1,   % +Fichier
                            construire_alternatives/1, % +Fichier (alternatives_index : alt/4, nb_alt/3)
                            alternatives/2,         % +N, -Alts (listes de mots propres, chacune suffisante)
                            decrire/0,              % les formes de la description courante (decrit/1, decrit_dans/2)
                            unite/2,                % +Mention, -Unite
                            part_decrite/2,         % +N, -Part
                            pleine_dans/2,          % ?N, ?Unite (l'unité décrit chacun des mots propres de N)
                            pleine_large_dans/2,    % ?N, ?Unite (de même, chaque mot tel quel ou par le pont WordNet)
                            libelle_admis/1,        % +N (contexte « ~ » dit ; jamais un libellé de phase)
                            mot_dit/1,              % +Mot (dit quelque part dans la description)
                            explications/2,         % +Ns, -Max (par unité, les plus profondes des notations pleines)
                            explications_pont/2,    % +Ns, -Max (de même, pleines par le pont WordNet compris)
                            explications_selon/3,   % +Pleine, +Ns, -Max (selon un critère d'unité pleine)
                            plus_precises/2,        % +Paires Unite-N triées, -Max (les plus précises par unité)
                            descente/2,             % +Depart, -Atteinte (enfants les mieux soutenus, en chaîne)
                            specialisees/2          % +Departs, -Atteintes (toutes, sans doublon)
                          ]).

:- use_module(libelles).
:- use_module(lexique).
:- use_module(morphologie).
:- use_module(arbre).
:- use_module(recherche).

:- dynamic decrit/1, decrit_dans/2, decrit_pont/2.

% --- Index des mots propres ----------------------------------------------------------------------------------------

construire_propres(Fichier) :-
    setup_call_cleanup(
        open(Fichier, write, S, [encoding(utf8)]),
        ( format(S, ":- module(propres_index, [propre/3, nb_propres/2]).~n:- encoding(utf8).~n:- discontiguous propre/3, nb_propres/2.~n", []),
          forall(iconclass:n(N),
                 ( mots_propres_ou_nom(N, Mots),
                   length(Mots, K),
                   (   K > 0
                   ->  format(S, "nb_propres(~q, ~d).~n", [N, K]),
                       forall(nth1(I, Mots, M),
                              forall(formes(M, F), format(S, "propre(~q, ~d, ~q).~n", [N, I, F])))
                   ;   true
                   ) )) ),
        close(S)).

mots_propres_ou_nom(N, Mots) :-
    (   libelles:mots_propres(N, Ms0) -> true ; Ms0 = [] ),
    (   notation:analyser(N, Niveaux), Niveaux \= composee(_), last(Niveaux, nom(T))
    ->  lexique:forme_de(T, Nom), ord_union(Ms0, [Nom], Mots)       % le nom, en dernier niveau
    ;   Mots = Ms0
    ).

formes(M, F) :-
    lexique:forme_de(M, F0),
    distinct(F, ( F = F0 ; morphologie:tous_lemmes(F0, Ls), member(F, Ls) )).

% --- Alternatives : les façons de nommer ce qui est propre à une notation ------------------------------------------

% alternatives(+N, -Alts) : des listes de mots dont chacune, tous ses mots décrits dans une même unité, suffit à dire
% ce qui est propre à N. Une notation à nom se dit par son nom. Sinon chaque élément du libellé (libelles:elements/2 :
% synonymes, « jar, jug ») par ses mots pleins absents du libellé du parent, parenthèses du parent ôtées (un élément
% tout entier dans le parent ne distingue rien ; « crown » sous « insignia… (crown, diadem…) » reste « crown ») ; si
% aucun élément n'a de mot propre, la distinction est dans les parenthèses (« historical persons
% (portraits and scenes from the life) », sous « historical events and situations; historical persons ») et leurs
% éléments en tiennent lieu ; à défaut, les mots propres, ensemble — et pour un libellé fabriqué (« … - BB - woman »,
% une base et le sens d'une lettre doublée ou d'un gabarit), avec chacune des alternatives de sa base : « woman » ne
% suffit pas à dire 61BB, il faut aussi le portrait.
:- table alternatives/2.
alternatives(N, Alts) :-
    (   catch(notation:analyser(N, Niveaux), _, fail), Niveaux \= composee(_), last(Niveaux, nom(T))
    ->  % un nom se dit par ses mots, tous dans une même unité, quels que soient leur ordre et la ponctuation :
        % « TASSO, Gerusalemme Liberata » par « Torquato Tasso, Gerusalemme Liberata, canto XIV »
        (   libelles:mots_pleins(T, Ms), Ms \== [] -> Alts = [Ms]
        ;   lexique:forme_de(T, Nom), Alts = [[Nom]]
        )
    ;   mots_du_parent(N, MP),
        (   libelles:elements(N, Es), propres_des(Es, MP, A1), A1 \== []
        ->  Alts = A1
        ;   libelles:precisions(N, Ps), propres_des(Ps, MP, A2), A2 \== []
        ->  Alts = A2
        ;   libelles:mots_propres(N, Ms), Ms \== []
        ->  (   libelles:partie(N, 2, _), arbre:parent(N, P), alternatives(P, AP), AP \== []
            ->  findall(A, ( member(A0, AP), ord_union(A0, Ms, A) ), A3), sort(A3, Alts)
            ;   Alts = [Ms]
            )
        ;   Alts = []
        )
    ).

mots_du_parent(N, MP) :-
    (   arbre:parent(N, P), libelles:mots_hors_parentheses(P, MP) -> true ; MP = [] ).

propres_des(Textes, MP, Alts) :-
    findall(Ms, ( member(E, Textes), libelles:mots_pleins(E, Ms0), ord_subtract(Ms0, MP, Ms), Ms \== [] ), A0),
    sort(A0, Alts).

% index (construit une fois) : alt(N, J, I, Forme), le I-ième mot de la J-ième alternative de N sous chacune de ses
% formes ; nb_alt(N, J, K)
construire_alternatives(Fichier) :-
    setup_call_cleanup(
        open(Fichier, write, S, [encoding(utf8)]),
        ( format(S, ":- module(alternatives_index, [alt/4, nb_alt/3]).~n:- encoding(utf8).~n:- discontiguous alt/4, nb_alt/3.~n", []),
          forall(iconclass:n(N),
                 ( alternatives(N, Alts),
                   forall(nth1(J, Alts, Mots),
                          ( length(Mots, K),
                            format(S, "nb_alt(~q, ~d, ~d).~n", [N, J, K]),
                            forall(nth1(I, Mots, M),
                                   forall(formes(M, F), format(S, "alt(~q, ~d, ~d, ~q).~n", [N, J, I, F]))) )) )) ),
        close(S)).

% --- Formes de la description ---------------------------------------------------------------------------------------

% decrit(F) : la forme est dans la description ; decrit_dans(F, Unite) : dans quelle unité (une entité
% « entities[3] », une entrée de champ « keywords[12] », le sujet « subject ») — pour les preuves qui doivent porter
% sur la même chose (une clé « à genoux » sur la figure qui est à genoux)
% decrit_pont(G, Unite) : G, mot d'une alternative, n'est pas dans l'unité mais l'une de ses formes y mène, depuis ses
% sens dominants (lexique:voisin_sens_dominant/4), par un lien que la recherche admet (recherche:lien_admis/1 : synonyme,
% hyperonyme à deux pas au plus, dérivé, pertainym, adjectif similaire, « partie de ») — « unidentified » dit
% « anonymous », « man » dit « person », « portrait » dit « portray » ; jamais l'hyponyme : « bird » ne dit pas
% « eagle »
decrire :-
    retractall(decrit(_)),
    retractall(decrit_dans(_, _)),
    retractall(decrit_pont(_, _)),
    forall(distinct(F-U, ( recherche:forme_mention(M, F), unite(M, U) )), assertz(decrit_dans(F, U))),
    % une relation (« e1 rides e2 ») dit un événement et ses participants : son unité reçoit les formes du type de
    % chaque entité qu'elle relie (« horse » pour e2) — « riding a horse » se prouve dans la relation même
    forall(distinct(F-U, participant(U, F)), ( decrit_dans(F, U) -> true ; assertz(decrit_dans(F, U)) )),
    forall(distinct(F, decrit_dans(F, _)), assertz(decrit(F))),
    (   current_predicate(alternatives_index:alt/4)
    ->  forall(distinct(G-U, ( decrit(F), morphologie:forme_connue(F, _), lexique:voisin_sens_dominant(F, G, R, _),
                               recherche:lien_admis(R), G \== F, once(alternatives_index:alt(_, _, _, G)),
                               decrit_dans(F, U), \+ decrit_dans(G, U) )),
               assertz(decrit_pont(G, U)))
    ;   true
    ).

dite_dans(F, U) :- decrit_dans(F, U).
dite_dans(F, U) :- decrit_pont(F, U).

% participant(-U, -F) : U est l'unité d'une relation (« relations[i] »), F une forme du type d'une entité qu'elle relie
% (son sujet ou son objet, identifiants d'entité)
participant(U, F) :-
    mention_participant(U, MT),
    recherche:forme_mention(MT, F).

% mention_participant(-U, -MT) : MT est la mention du type d'une entité que relie la relation d'unité U
mention_participant(U, MT) :-
    description:relation_i(I, S, _, O),
    format(atom(U), 'relations[~d]', [I]),
    ( Id = S ; Id = O ),
    findall(E, description:entite(E, _, _, _, _), Es), nth0(J, Es, Id),
    format(atom(CheminType), 'entities[~d].type', [J]),
    description:mention(MT, entities, CheminType, _).

unite(M, U) :-
    description:mention(M, _, Chemin, _),
    (   sub_atom(Chemin, B, _, _, ']') -> L is B + 1, sub_atom(Chemin, 0, L, _, U)
    ;   sub_atom(Chemin, B2, _, _, '.') -> sub_atom(Chemin, 0, B2, _, U)
    ;   U = Chemin
    ).

part_decrite(N, Part) :-
    propres_index:nb_propres(N, K),
    aggregate_all(count, distinct(I, ( propres_index:propre(N, I, F), decrit(F) )), D),
    Part is D / K.

% --- Explications par unité -----------------------------------------------------------------------------------------

% pleine_dans(N, U) : une même unité de la description (une entité, une entrée de champ, le sujet) décrit tous les
% mots de l'une des alternatives de N — la notation explique ce que dit cette unité, sans emprunter un mot à une
% autre chose décrite
pleine_dans(N, U) :-
    (   nonvar(N), \+ alternatives_index:nb_alt(N, _, _)
    ->  hors_index_pleine(decrit_dans, N, U)
    ;   distinct(U, ( alternatives_index:nb_alt(N, J, K), libelle_admis(N),
                      alternatives_index:alt(N, J, 1, F1), decrit_dans(F1, U),
                      forall(between(2, K, I), ( alternatives_index:alt(N, J, I, F), decrit_dans(F, U) -> true )) ))
    ).

% une notation absente de l'index (un nom écrit dans un gabarit, une clé) : ses alternatives calculées (alternatives/2),
% chaque mot dit dans l'unité par Dite (decrit_dans ou dite_dans)
hors_index_pleine(Dite, N, U) :-
    alternatives(N, Alts), libelle_admis(N),
    distinct(U, ( member(Ms, Alts), Ms = [M1|_], formes(M1, F1), call(Dite, F1, U),
                  forall(member(M, Ms), once(( formes(M, F), call(Dite, F, U) ))) )).

% pleine_large_dans(N, U) : de même, chaque mot de l'alternative dit dans l'unité tel quel ou par le pont WordNet
% (decrit_pont/2) — « unidentified man, sitter of the portrait » dit 61B11 « anonymous historical person portrayed »
% (anonymous, person, portrayed) sans en écrire un seul mot ; une preuve plus faible, gardée à part
pleine_large_dans(N, U) :-
    (   nonvar(N), \+ alternatives_index:nb_alt(N, _, _)
    ->  hors_index_pleine(dite_dans, N, U)
    ;   distinct(U, ( alternatives_index:nb_alt(N, J, K), libelle_admis(N),
                      alternatives_index:alt(N, J, 1, F1), dite_dans(F1, U),
                      forall(between(2, K, I), ( alternatives_index:alt(N, J, I, F), dite_dans(F, U) -> true )) ))
    ).

% ce que le libellé exige au-delà de ses mots propres pour qu'une unité l'explique : un libellé « concept ~ contexte »
% n'est dit que si chacun de ses mots (des deux côtés du « ~ ») est dit quelque part dans la description (« gods ~
% classical mythology » : des dieux hindous ne le disent pas) ; un libellé de phase (« after the battle », « before
% and after production ») ne l'est jamais par une unité : la phase n'est pas un mot de la description
libelle_admis(N) :-
    \+ libelles:phase(N, _),
    (   libelles:concept_contexte(N, _, _)
    ->  libelles:mots_du_sens(N, Ms), forall(member(M, Ms), mot_dit(M))
    ;   true
    ).

% mot_dit(+Mot) : le mot (ou l'un de ses lemmes) est dit quelque part dans la description, tel quel ou par le pont
mot_dit(M) :- once(( formes(M, F), dite_dans(F, _) )).

% explications(+Ns, -Max) : parmi les notations Ns, celles qui sont pleines dans une unité sans qu'aucun de leurs
% descendants le soit aussi dans la même unité — pour chaque chose décrite, les notations les plus précises qui
% l'expliquent entièrement (« river » : la rivière du paysage, pas seulement « paysages ») ; aucun classement, aucun
% budget : une notation entre parce qu'une unité la prouve
explications(Ns, Max) :- explications_selon(pleine_dans, Ns, Max).

% explications_pont(+Ns, -Max) : de même, sur les unités pleines par le pont WordNet compris
explications_pont(Ns, Max) :- explications_selon(pleine_large_dans, Ns, Max).

explications_selon(Pleine, Ns, Max) :-
    findall(U-N, ( member(N, Ns), call(Pleine, N, U) ), P0),
    sort(P0, P),
    plus_precises(P, Max).

% plus_precises(+Paires, -Max) : parmi des paires Unite-Notation triées, les notations qu'aucune autre de la même unité
% ne précise
plus_precises(P, Max) :-
    group_pairs_by_key(P, Groupes),                  % par unité : ses notations pleines
    findall(N, ( member(_-Pl, Groupes), member(N, Pl), \+ ( member(M, Pl), M \== N, arbre:ancetre(M, N) ) ), Ms),
    sort(Ms, Max).

% --- Descente -------------------------------------------------------------------------------------------------------

mieux_soutenus(X, Enfants) :-
    arbre:enfants(X, Cs),
    findall(P-C, ( member(C, Cs), part_decrite(C, P), P > 0 ), Ps),
    Ps \== [],
    max_member(Max-_, Ps),
    findall(C, member(Max-C, Ps), Enfants).

descente(X, Y) :-
    mieux_soutenus(X, Enfants),
    member(C, Enfants),
    ( Y = C ; descente(C, Y) ).

specialisees(Departs, Atteintes) :-
    findall(Y, ( member(X, Departs), descente(X, Y) ), Ys),
    sort(Ys, Atteintes).
