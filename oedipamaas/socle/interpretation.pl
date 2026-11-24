/*  Interprétation (cahier des charges, § 6.2) : des phrases analysées (CoNLL-U, socle/conllu.pl) aux assertions
    (docs/ASSERTIONS.md). Règles linguistiques générales, écrites à la main, pour le français et l'anglais, sur les
    étiquettes universelles (UD) ; aucune connaissance iconographique ici.

    interpreter(+Texte, +Langue, +Genre, +Phrases, -Faits)

    Couvert au J1 (le reste va dans incompris/2) :
    - référents : noms communs et noms propres ; un nom propre en plusieurs mots (flat, compound) est un seul nom ;
      un titre (« saint », « Saint ») rattaché à un nom propre en devient la tête (« Saint Jérôme » : entite saint,
      nom Jérôme) ;
    - propriétés : adjectifs épithètes (amod), participes sans complément (« agenouillé », « kneeling »), attributs
      (« le lion est couché », « the saint is old ») ;
    - événements et rôles : sujet → agent, objet → patient, sujet passif → patient, complément d'agent (« par »,
      « by » au passif) → agent, « avec »/« with » → instrument, compléments de lieu → lieu ; participe présent
      épithète (« un ange tenant une épée ») : le nom est l'agent ; participe passé : le patient ; relative (« qui
      tient ») : le pronom relatif est le nom qu'elle complète ;
    - relations : un nom complément d'un autre par une préposition (« un homme avec un chien ») ;
    - négation : « sans », « without », « no », « aucun », « ni … ni », « neither … nor », « absent », et la négation
      d'un verbe (« ne … pas », « not ») ; un verbe de présence nié (« n'est pas visible », « does not show ») nie ce
      qu'il présente ; l'objet d'un autre verbe nié est nié dans « pas de X », sinon non affirmé (D8) ;
    - modalité : « peut-être », « probablement », « may », « pouvoir », « sembler » ; « traditionnellement »,
      « dit » ; « autrefois », « formerly » ; elle s'étend aux compléments de l'événement ;
    - alternatives : « A ou B », « A or B » ;
    - portée : ce qui suit « d'après », « after » (une autre œuvre) ; les matériaux et techniques (l'œuvre).
*/
:- module(interpretation, [ interpreter/5   % +Texte, +Langue, +Genre, +Phrases, -Faits
                          ]).
:- encoding(utf8).

% --- Lexique grammatical (FR, EN) -----------------------------------------------------------------------------------

titre(saint). titre(sainte). titre(st). titre(ste). titre('st.'). titre(san). titre(santa). titre(santo).
titre(sankt).

negation_det(no). negation_det(neither). negation_det(aucun). negation_det(aucune). negation_det(nul). negation_det(nulle).
negation_case(sans). negation_case(without).
negation_cc(ni). negation_cc(nor). negation_cc(neither).
negation_adv(pas). negation_adv(not). negation_adv(jamais). negation_adv(never). negation_adv(point).
negation_adv(plus). negation_adv(nullement).
negation_adj(absent). negation_adj(absente). negation_adj(missing). negation_adj(invisible).

% verbes et adjectifs de présence : nier la présence nie ce qui est présenté
presence(visible). presence(présent). presence(present). presence(représenter). presence(represent).
presence(figurer). presence(montrer). presence(show). presence(depict). presence(apparaître). presence(appear).
presence(voir). presence(see). presence(représenté). presence(depicted). presence(shown).

modal_adv('peut-être', possible). modal_adv(perhaps, possible). modal_adv(possibly, possible).
modal_adv(maybe, possible). modal_adv(possiblement, possible).
modal_adv(probablement, probable). modal_adv(probably, probable). modal_adv(likely, probable).
modal_adv(vraisemblablement, probable). modal_adv(apparemment, probable). modal_adv(apparently, probable).
modal_adv(traditionnellement, traditionnel). modal_adv(traditionally, traditionnel).
modal_adv(autrefois, ancien). modal_adv(formerly, ancien). modal_adv(anciennement, ancien).
modal_adv(jadis, ancien). modal_adv(previously, ancien).
modal_verbe(pouvoir, possible). modal_verbe(may, possible). modal_verbe(might, possible).
modal_verbe(could, possible). modal_verbe(can, possible). modal_verbe(sembler, probable).
modal_verbe(seem, probable). modal_verbe(paraître, probable).
modal_verbe(dire, traditionnel). modal_verbe(call, traditionnel).

alternative_cc(ou). alternative_cc(or).

autre_oeuvre_case(après). autre_oeuvre_case(after).

materiau(huile). materiau(toile). materiau(panneau). materiau(papier). materiau(cuivre). materiau(encre).
materiau(craie). materiau(aquarelle). materiau(gouache). materiau(pastel). materiau(oil). materiau(canvas).
materiau(panel). materiau(paper). materiau(copper). materiau(ink). materiau(chalk). materiau(watercolour).
materiau(watercolor). materiau(tempera). materiau(détrempe).

lieu_case(dans). lieu_case(sur). lieu_case(devant). lieu_case(derrière). lieu_case(sous). lieu_case(près).
lieu_case(in). lieu_case(on). lieu_case(before). lieu_case(behind). lieu_case(under). lieu_case(near).
lieu_case(at). lieu_case(beside).
instrument_case(avec). instrument_case(with).
agent_case(par). agent_case(by).

% --- Entrée ---------------------------------------------------------------------------------------------------------

interpreter(Texte, Langue, Genre, Phrases, Faits) :-
    jetons(Phrases, Ts),
    entites(Ts, Ents),                       % liste de ent(E, Tete, ToksDuNom, TokTete, TokNom-ou-rien)
    findall(F, fait(Ts, Ents, F), Fs00),
    maplist(nom_du_texte(Texte), Fs00, Fs0),
    qualifier(Ts, Ents, Fs0, Fs1),
    passages(Texte, Ts, Fs1, Ps),
    append([[texte(Texte), doc(Langue, Genre)], Ps, Fs1], Faits0),
    sort(Faits0, Faits1),
    ordonner(Faits1, Faits).

nom_du_texte(Texte, nom(A, E, texte_de(Ns), P), nom(A, E, Nom, P)) :- !,
    bornes(passage_nom(Ns), D, F),
    (   D >= 0, L is F - D, sub_atom(Texte, D, L, _, Nom0) -> true
    ;   findall(Fo, member(t(_, _, Fo, _, _, _, _, _, _, _), Ns), Fos), atomic_list_concat(Fos, ' ', Nom0)
    ),
    sans_point_final(Nom0, Nom).
nom_du_texte(_, F, F).

sans_point_final(N0, N) :- ( sub_atom(N0, B, 1, 0, '.'), B > 1 -> sub_atom(N0, 0, B, _, N) ; N = N0 ).

% jetons : t(S, I, Forme, Lemme, Cat, Traits, Tete, Rel, D, F), S le numéro de phrase
jetons(Phrases, Ts) :-
    findall(t(S, I, Fo1, L, C, Tr, H, R, D, F),
            ( nth1(S, Phrases, phrase(Ms)), member(mot(I, Fo, L0, C, Tr, H, R, D, F), Ms),
              sans_point(Fo, C, Fo1), lemme(I, L0, Fo1, C, L) ),
            Ts).

% le lemme en minuscules, sauf pour un nom propre (la forme écrite) ; un nom commun en tête de phrase et en capitale
% (« Portrait », « Allégorie » : la forme ordinaire d'un titre) prend sa forme en minuscules, l'analyseur le
% lemmatisant mal (« Portrait » → « Portre »)
lemme(_, _, Fo, 'PROPN', Fo) :- !.
lemme(1, _, Fo, 'NOUN', L) :- capitale(Fo), !, downcase_atom(Fo, L).
lemme(_, L0, _, _, L) :- downcase_atom(L0, L).

capitale(Fo) :- sub_atom(Fo, 0, 1, _, C), upcase_atom(C, C), downcase_atom(C, Cm), Cm \== C.

% un nom propre suivi de son point final pris dans le même jeton (« David. ») : le point est retiré
sans_point(Fo, 'PROPN', Fo1) :- atom_length(Fo, N), N > 2, sub_atom(Fo, B, 1, 0, '.'), \+ sub_atom(Fo, _, _, 1, '.'), !,
    sub_atom(Fo, 0, B, _, Fo1).
sans_point(Fo, _, Fo).

jeton(Ts, S, I, T) :- T = t(S, I, _, _, _, _, _, _, _, _), memberchk(T, Ts).
enfant(Ts, S, I, T) :- T = t(S, _, _, _, _, _, I, _, _, _), member(T, Ts).
enfant(Ts, S, I, Rel, T) :- T = t(S, _, _, _, _, _, I, Rel0, _, _), member(T, Ts), rel_de_base(Rel0, Rel).

rel_de_base(R0, R) :- ( sub_atom(R0, B, _, _, ':') -> sub_atom(R0, 0, B, _, R) ; R = R0 ).

trait(t(_, _, _, _, _, Tr, _, _, _, _), N, V) :- memberchk(N=V, Tr).

% --- Référents ------------------------------------------------------------------------------------------------------

nominal(t(_, _, _, _, C, _, _, _, _, _)) :- memberchk(C, ['NOUN', 'PROPN']).
propre(t(_, _, _, _, 'PROPN', _, _, _, _, _)).
est_titre(t(_, _, Fo, L, _, _, _, _, _, _)) :- ( downcase_atom(Fo, F), titre(F) -> true ; titre(L) ).

% un mot du nom : un nom propre, ou un mot en capitale (hors début de phrase) rattaché à un titre (« Saint Jérôme »,
% où l'analyseur fait parfois de « Jérôme » un adjectif)
mot_du_nom(Ts, T) :- \+ est_titre(T), ( propre(T) -> true ; capitale_liee_a_un_titre(Ts, T) ).

capitale_liee_a_un_titre(Ts, T) :-
    T = t(S, I, Fo, _, C, _, H, _, _, _), I > 1, memberchk(C, ['ADJ', 'NOUN', 'X']), capitale(Fo),
    (   jeton(Ts, S, H, P), est_titre(P) -> true ; enfant(Ts, S, I, P), est_titre(P) ).

% une grappe : un nom propre en plusieurs mots, avec ses titres (flat, compound ; un titre aussi par nmod, appos)
lien_de_grappe(R) :- memberchk(R, [flat, compound]).
dans_grappe(Ts, T) :-                    % T dépend d'un autre membre de grappe
    ( mot_du_nom(Ts, T) ; est_titre(T) ),
    T = t(S, _, _, _, _, _, H, R, _, _), rel_de_base(R, RB),
    jeton(Ts, S, H, P), ( mot_du_nom(Ts, P) ; est_titre(P) ),
    (   lien_de_grappe(RB) -> true
    ;   memberchk(RB, [nmod, appos, amod]), ( est_titre(T) ; est_titre(P) )
    ).

racine_de_grappe(Ts, T) :- ( mot_du_nom(Ts, T) ; est_titre(T) ), \+ dans_grappe(Ts, T).

membres(Ts, R, Ms) :-
    findall(X, ( member(X, Ts), sous(Ts, X, R) ), Ms0),
    nom_ordonne([R|Ms0], Ms).

sous(Ts, X, R) :-
    dans_grappe(Ts, X), X = t(S, _, _, _, _, _, H, _, _, _), R = t(S, I, _, _, _, _, _, _, _, _),
    (   H == I -> true ; jeton(Ts, S, H, P), sous(Ts, P, R) ).

entites(Ts, Ents) :-
    findall(E, entite_de(Ts, E), Ents).

% ent(E, Tete, MotsDuNom, JetonTete, Membres)
entite_de(Ts, ent(E, Tete, Noms, TT, Ms)) :-
    member(T, Ts), racine_de_grappe(Ts, T),
    membres(Ts, T, Ms),
    include(mot_du_nom(Ts), Ms, Noms),
    (   Noms == [], \+ nominal(T) -> fail ; true ),
    TT = T,
    (   include(est_titre, Ms, [Ti|_]) -> Ti = t(_, _, _, LT0, _, _, _, _, _, _), downcase_atom(LT0, Tete)
    ;   Noms \== [] -> Tete = nom_propre
    ;   T = t(_, _, _, Tete, _, _, _, _, _, _)
    ),
    T = t(S, I, _, _, _, _, _, _, _, _),
    atomic_list_concat([e, S, I], '_', E).
entite_de(Ts, ent(E, L, [], T, [T])) :-
    member(T, Ts), nominal(T), \+ mot_du_nom(Ts, T), \+ est_titre(T), \+ propriete_en_ing(T),
    T = t(_, _, Fo, _, _, _, _, _, _, _), downcase_atom(Fo, Fm), \+ negation_adj(Fm),
    T = t(S, I, _, L, _, _, _, _, _, _),
    atomic_list_concat([e, S, I], '_', E).

% « a kneeling saint » : un nom composé en -ing devant un nom est une propriété (l'analyseur en fait un nom)
propriete_en_ing(t(_, _, Fo, _, 'NOUN', _, _, compound, _, _)) :- sub_atom(Fo, _, 3, 0, ing).

nom_ordonne(Toks, Tries) :-
    findall(I-T, ( member(T, Toks), T = t(_, I, _, _, _, _, _, _, _, _) ), P), keysort(P, P1), pairs_values(P1, Tries).

% l'entité d'un jeton (un membre de sa grappe, ou le nom lui-même)
entite_du_jeton(_, Ents, T, E) :-
    member(ent(E, _, _, _, Ms), Ents), memberchk(T, Ms), !.

% un pronom relatif (« qui », « who », « which ») : l'entité que la relative complète
referent(Ts, Ents, T, E) :-
    (   entite_du_jeton(Ts, Ents, T, E) -> true
    ;   T = t(S, _, _, _, 'PRON', _, H, _, _, _), trait(T, 'PronType', 'Rel'),
        jeton(Ts, S, H, V), V = t(_, _, _, _, _, _, HN, RV, _, _), rel_de_base(RV, acl),
        jeton(Ts, S, HN, N), entite_du_jeton(Ts, Ents, N, E)
    ).

% --- Faits ----------------------------------------------------------------------------------------------------------

fait(_, Ents, entite(E, Tete, passage_nom(Ms))) :- member(ent(E, Tete, _, _, Ms), Ents).
fait(_, Ents, nom(A, E, texte_de(Ns), passage_nom(Ns))) :-
    member(ent(E, _, Ns, _, _), Ents), Ns \== [],
    atom_concat(n_, E, A).
% propriétés : épithète, participe sans complément, attribut
fait(Ts, Ents, propriete(A, E, P, passage_de(T))) :-
    member(T, Ts), T = t(S, I, _, P, C, _, H, R, _, _),
    (   rel_de_base(R, amod), memberchk(C, ['ADJ', 'VERB'])
    ;   rel_de_base(R, acl), C == 'VERB', \+ a_complement(Ts, T), \+ relative(Ts, T)
    ;   participe_epithete(Ts, T)
    ),
    \+ negation_adj(P),
    jeton(Ts, S, H, N), entite_du_jeton(Ts, Ents, N, E),
    atomic_list_concat([q, S, I], '_', A).
fait(Ts, Ents, propriete(A, E, P, passage_de(T))) :-
    member(T, Ts), propriete_en_ing(T), T = t(S, I, _, P, _, _, H, _, _, _),
    jeton(Ts, S, H, N), entite_du_jeton(Ts, Ents, N, E),
    atomic_list_concat([q, S, I], '_', A).
fait(Ts, Ents, propriete(A, E, P, passage_de(T))) :-
    attribut(Ts, T, Sujet), T = t(S, I, _, P, _, _, _, _, _, _),
    \+ presence(P), \+ negation_adj(P),
    entite_du_jeton(Ts, Ents, Sujet, E),
    atomic_list_concat([q, S, I], '_', A).
% événements
fait(Ts, _, evenement(V, P, passage_de(T))) :-
    evenement_jeton(Ts, T), T = t(S, I, _, P, _, _, _, _, _, _),
    atomic_list_concat([v, S, I], '_', V).
fait(Ts, Ents, role(V, Role, E)) :-
    evenement_jeton(Ts, T), T = t(S, I, _, _, _, _, _, _, _, _),
    atomic_list_concat([v, S, I], '_', V),
    role_de(Ts, Ents, T, Role, E).
% relations entre référents : un nom complément d'un autre par une préposition
fait(Ts, Ents, relation(A, E1, Rel, E2, passage_de(T2))) :-
    member(T2, Ts), nominal(T2), T2 = t(S, I2, _, _, _, _, H, R, _, _), rel_de_base(R, nmod),
    jeton(Ts, S, H, T1), nominal(T1),
    enfant(Ts, S, I2, case, C), C = t(_, _, _, Rel, _, _, _, _, _, _),
    \+ negation_case(Rel), \+ autre_oeuvre_case(Rel),
    entite_du_jeton(Ts, Ents, T1, E1), entite_du_jeton(Ts, Ents, T2, E2), E1 \== E2,
    atomic_list_concat([r, S, I2], '_', A).
% alternatives : « A ou B »
fait(Ts, Ents, alternative(G, Es)) :-
    member(T1, Ts), nominal(T1), T1 = t(S, I1, _, _, _, _, _, _, _, _),
    findall(T2, ( enfant(Ts, S, I1, conj, T2), nominal(T2), T2 = t(_, I2, _, _, _, _, _, _, _, _),
                  enfant(Ts, S, I2, cc, CC), CC = t(_, _, _, L, _, _, _, _, _, _), alternative_cc(L) ), T2s),
    T2s \== [],
    findall(E, ( member(X, [T1|T2s]), entite_du_jeton(Ts, Ents, X, E) ), Es0), sort(Es0, Es),
    Es = [_, _|_],
    atomic_list_concat([g, S, I1], '_', G).
% « la figure est saint Pierre », « the saint is Jerome » : le sujet et le prédicat nominal désignent le même référent
fait(Ts, Ents, coref(E1, E2)) :-
    member(P, Ts), nominal(P), P = t(S, IP, _, _, _, _, _, _, _, _),
    enfant(Ts, S, IP, cop, _), enfant(Ts, S, IP, nsubj, Su),
    entite_du_jeton(Ts, Ents, Su, E1), entite_du_jeton(Ts, Ents, P, E2), E1 \== E2.
% incompris : relations que l'analyseur n'a pas su nommer
fait(Ts, _, incompris(passage_de(T), analyse_incertaine)) :-
    member(T, Ts), T = t(_, _, _, _, _, _, _, R, _, _), memberchk(R, [dep, orphan, reparandum]).

% « une femme couronnée à côté d'un homme » : un participe passé épithète, sans objet ni complément d'agent, est une
% propriété du nom (le complément de lieu peut lui être rattaché par l'analyseur)
participe_epithete(Ts, T) :-
    T = t(S, I, _, _, 'VERB', _, _, R, _, _), rel_de_base(R, acl), trait(T, 'VerbForm', 'Part'),
    \+ trait(T, 'Tense', 'Pres'), \+ relative(Ts, T),
    \+ enfant(Ts, S, I, obj, _), \+ complement_d_agent(Ts, T, _).

a_complement(Ts, t(S, I, _, _, _, _, _, _, _, _)) :-
    enfant(Ts, S, I, R, _), memberchk(R, [obj, iobj, obl, nsubj, ccomp, xcomp]), !.

relative(Ts, t(S, I, _, _, _, _, _, R, _, _)) :-
    ( sub_atom(R, _, _, _, relcl) -> true ; enfant(Ts, S, I, nsubj, P), P = t(_, _, _, _, 'PRON', _, _, _, _, _) ), !.

% attribut : un adjectif ou un participe prédicat, avec un sujet et sans objet (« le lion est couché »)
attribut(Ts, T, Sujet) :-
    member(T, Ts), T = t(S, I, _, _, C, _, _, _, _, _), memberchk(C, ['ADJ', 'VERB']),
    \+ complement_d_agent(Ts, T, _),
    ( C == 'ADJ' ; enfant(Ts, S, I, cop, _) ; enfant(Ts, S, I, aux, _) ),
    \+ enfant(Ts, S, I, obj, _), \+ enfant(Ts, S, I, obl, _),
    \+ ( C == 'VERB', \+ trait(T, 'VerbForm', 'Part'), \+ trait(T, 'VerbForm', 'Ger') ),
    once(( enfant(Ts, S, I, nsubj, Sujet) )).

evenement_jeton(Ts, T) :-
    member(T, Ts), T = t(_, _, _, _, 'ADJ', _, _, _, _, _), complement_d_agent(Ts, T, _).
evenement_jeton(Ts, T) :-
    member(T, Ts), T = t(_, _, _, L, 'VERB', _, _, R, _, _),
    \+ modal_verbe(L, _),
    \+ ( rel_de_base(R, amod) ),
    \+ ( rel_de_base(R, acl), \+ a_complement(Ts, T), \+ relative(Ts, T) ),
    \+ participe_epithete(Ts, T),
    \+ attribut(Ts, T, _).

role_de(Ts, Ents, T, Role, E) :-
    T = t(S, I, _, _, _, _, H, R, _, _),
    (   enfant(Ts, S, I, R0, X), R0 \== case,
        X = t(_, IX, _, _, _, _, _, RX, _, _),
        role_syntaxique(Ts, T, RX, S, IX, Role),
        referent(Ts, Ents, X, E)
    ;   rel_de_base(R, acl), \+ relative(Ts, T),
        jeton(Ts, S, H, N), entite_du_jeton(Ts, Ents, N, E),
        (   ( trait(T, 'Tense', 'Past') ; trait(T, 'Voice', 'Pass') ) -> Role = patient ; Role = agent )
    ).

role_syntaxique(Ts, V, nsubj, _, _, Role) :- ( complement_d_agent(Ts, V, _) -> Role = patient ; Role = agent ).
role_syntaxique(_, _, 'nsubj:pass', _, _, patient).
role_syntaxique(_, _, obj, _, _, patient).
role_syntaxique(_, _, iobj, _, _, destinataire).
role_syntaxique(_, _, 'obl:agent', _, _, agent).
role_syntaxique(Ts, V, RX, S, IX, Role) :-
    rel_de_base(RX, obl), RX \== 'obl:agent',
    enfant(Ts, S, IX, case, C), C = t(_, _, _, L, _, _, _, _, _, _),
    (   agent_case(L), ( passif(Ts, V) ; complement_d_agent(Ts, V, _) ) -> Role = agent
    ;   instrument_case(L) -> Role = instrument
    ;   lieu_case(L) -> Role = lieu
    ), !.

% un complément d'agent : « obl:agent », ou « par »/« by » d'un prédicat passif ou adjectival (« is slain by »)
complement_d_agent(Ts, V, X) :-
    V = t(S, I, _, _, C, _, _, _, _, _),
    (   enfant(Ts, S, I, X), X = t(_, _, _, _, _, _, _, 'obl:agent', _, _)
    ;   enfant(Ts, S, I, obl, X), X = t(_, IX, _, _, _, _, _, _, _, _),
        enfant(Ts, S, IX, case, Ca), Ca = t(_, _, _, L, _, _, _, _, _, _), agent_case(L),
        ( C == 'ADJ' ; passif(Ts, V) ; enfant(Ts, S, I, cop, _) )
    ), !.

passif(Ts, V) :-
    V = t(S, I, _, _, _, _, _, _, _, _),
    ( trait(V, 'Voice', 'Pass') ; enfant(Ts, S, I, 'aux:pass', _) ; enfant(Ts, S, I, aux, A), A = t(_, _, _, _, _, _, _, 'aux:pass', _, _) ), !.

% --- Qualificatifs --------------------------------------------------------------------------------------------------

qualifier(Ts, Ents, Fs0, Fs) :-
    findall(A, ( member(F, Fs0), id_assertion(F, A) ), As0), sort(As0, As),
    findall(Q, ( member(A, As), qualificatif(Ts, Ents, Fs0, A, Q) ), Qs),
    append(Fs0, Qs, Fs).

id_assertion(entite(E, _, _), E).
id_assertion(evenement(V, _, _), V).
id_assertion(nom(A, _, _, _), A).
id_assertion(propriete(A, _, _, _), A).
id_assertion(relation(A, _, _, _, _), A).

qualificatif(Ts, Ents, Fs, A, polarite(A, Pol)) :- ( nie(Ts, Ents, Fs, A) -> Pol = neg ; Pol = pos ).
qualificatif(Ts, Ents, Fs, A, modalite(A, Mod)) :- ( modalise(Ts, Ents, Fs, A, M) -> Mod = M ; Mod = affirme ).
qualificatif(Ts, Ents, Fs, A, portee(A, Por)) :- ( porte(Ts, Ents, Fs, A, P) -> Por = P ; Por = represente ).
qualificatif(_, _, _, A, enonciateur(A, auteur)).

jeton_de_assertion(_, Ents, Fs, A, T) :-
    (   member(ent(A, _, _, T, _), Ents) -> true
    ;   memberchk(evenement(A, _, passage_de(T)), Fs) -> true
    ;   memberchk(propriete(A, _, _, passage_de(T)), Fs) -> true
    ;   memberchk(relation(A, _, _, _, passage_de(T)), Fs) -> true
    ;   memberchk(nom(A, E, _, _), Fs), member(ent(E, _, _, T, _), Ents) -> true
    ).

% négation
nie(Ts, Ents, Fs, A) :-
    jeton_de_assertion(Ts, Ents, Fs, A, T0),
    (   memberchk(nom(A, E, _, _), Fs) -> member(ent(E, _, _, T, _), Ents) ; T = T0 ),
    nie_jeton(Ts, Ents, Fs, T), !.

nie_jeton(Ts, _, _, T) :-
    T = t(S, I, _, _, _, _, _, _, _, _),
    (   enfant(Ts, S, I, det, D), D = t(_, _, _, L, _, _, _, _, _, _), negation_det(L)
    ;   enfant(Ts, S, I, case, C), C = t(_, _, _, L, _, _, _, _, _, _), negation_case(L)
    ;   enfant(Ts, S, I, cc, C), C = t(_, _, _, L, _, _, _, _, _, _), negation_cc(L)
    ;   enfant(Ts, S, I, J), J = t(_, _, Fo, _, _, _, _, RJ, _, _), rel_de_base(RJ, RBJ),
        memberchk(RBJ, [amod, acl, appos, xcomp]), downcase_atom(Fo, FJ), negation_adj(FJ)
    ;   T = t(_, _, _, _, _, _, H, _, _, _), H > 0, jeton(Ts, S, H, P), P = t(_, _, FoP, _, _, _, _, _, _, _),
        downcase_atom(FoP, FP), negation_adj(FP)
    ;   argument_d_un_evenement_nie(Ts, T)
    ;   verbe_nie(Ts, T)
    ;   presence_niee(Ts, T)
    ), !.

% l'objet d'un verbe nié n'est pas affirmé (« l'ange ne tient pas d'épée ») : il est nié (décision D8)
% l'objet d'un verbe nié n'est nié que par la construction qui nie son existence (décision D8) : « pas de X »,
% « pas d'épée » (déterminant ou préposition « de » sous la négation), « not … any X » ; sinon il n'est que non affirmé
% (« il ne regarde pas le livre » ne nie pas le livre) : voir argument_non_affirme/2
argument_d_un_evenement_nie(Ts, T) :-
    argument_d_un_verbe_nie(Ts, T),
    T = t(S, I, _, _, _, _, _, _, _, _),
    (   enfant(Ts, S, I, case, C), C = t(_, _, _, L, _, _, _, _, _, _), memberchk(L, [de, 'd\''])
    ;   enfant(Ts, S, I, det, D), D = t(_, _, Fo, L, _, _, _, _, _, _), downcase_atom(Fo, F),
        ( memberchk(L, [any, de]) ; memberchk(F, [de, 'd\'']) )
    ), !.

argument_d_un_verbe_nie(Ts, T) :-
    T = t(S, _, _, _, _, _, H, R, _, _), rel_de_base(R, RB),
    ( memberchk(RB, [obj, iobj, obl]) ; R == 'nsubj:pass' ),          % le sujet actif reste affirmé
    jeton(Ts, S, H, V), verbe_nie(Ts, V).

argument_non_affirme(Ts, T) :- argument_d_un_verbe_nie(Ts, T), \+ argument_d_un_evenement_nie(Ts, T).

verbe_nie(Ts, T) :-
    T = t(S, I, _, _, 'VERB', _, _, _, _, _),
    enfant(Ts, S, I, advmod, N), N = t(_, _, _, L, _, _, _, _, _, _), negation_adv(L).

% un prédicat de présence nié nie ce qu'il présente : son sujet (intransitif, passif, adjectif) ou son objet
presence_niee(Ts, T) :-
    T = t(S, _, _, _, _, _, H, R, _, _),
    rel_de_base(R, RB), memberchk(RB, [nsubj, obj]),
    jeton(Ts, S, H, P), P = t(_, IP, _, LP, _, _, _, _, _, _), presence(LP),
    enfant(Ts, S, IP, advmod, N), N = t(_, _, _, L, _, _, _, _, _, _), negation_adv(L),
    (   RB == obj -> true ; \+ enfant(Ts, S, IP, obj, _) ).

% modalité : sur l'événement, sur ses compléments (patient, thème, identité « comme », « as »), sur un nom
modalise(Ts, Ents, Fs, A, M) :-
    jeton_de_assertion(Ts, Ents, Fs, A, T0),
    (   memberchk(nom(A, E, _, _), Fs) -> member(ent(E, _, _, T, _), Ents) ; T = T0 ),
    modalite_jeton(Ts, T, M), !.

modalite_jeton(Ts, T, non_affirme) :- argument_non_affirme(Ts, T), !.
modalite_jeton(Ts, T, M) :-
    T = t(S, I, _, _, _, _, H, R, _, _),
    (   enfant(Ts, S, I, advmod, X), X = t(_, _, _, L, _, _, _, _, _, _), modal_adv(L, M)
    ;   enfant(Ts, S, I, aux, X), X = t(_, _, _, L, _, _, _, _, _, _), modal_verbe(L, M)
    ;   H > 0, jeton(Ts, S, H, P), P = t(_, _, _, LP, _, _, _, _, _, _), rel_de_base(R, RB),
        (   memberchk(RB, [xcomp, ccomp]), modal_verbe(LP, M)
        ;   memberchk(RB, [obj, xcomp, ccomp, obl, advcl]), modalite_jeton(Ts, P, M)
        ;   RB == nsubj, enfant(Ts, S, H, 'aux:pass', _), modalite_jeton(Ts, P, M)
        ;   memberchk(RB, ['nsubj:pass']), modalite_jeton(Ts, P, M)
        )
    ), !.

% portée : ce qui dépend de « d'après », « after » est une autre œuvre ; un matériau, l'œuvre elle-même
porte(Ts, Ents, Fs, A, P) :-
    jeton_de_assertion(Ts, Ents, Fs, A, T0),
    (   memberchk(nom(A, E, _, _), Fs) -> member(ent(E, _, _, T, _), Ents)
    ;   memberchk(propriete(A, E, _, _), Fs) -> member(ent(E, _, _, T, _), Ents)
    ;   T = T0
    ),
    portee_jeton(Ts, T, P), !.

portee_jeton(Ts, T, P) :-
    T = t(S, I, _, L, _, _, H, _, _, _),
    (   enfant(Ts, S, I, case, C), C = t(_, IC, _, LC, _, _, _, _, _, _),
        ( autre_oeuvre_case(LC) ; enfant(Ts, S, IC, fixed, Fx), Fx = t(_, _, _, LF, _, _, _, _, _, _), autre_oeuvre_case(LF) )
    ->  P = autre_oeuvre
    ;   materiau(L) -> P = oeuvre
    ;   H > 0, jeton(Ts, S, H, Par), nominal(Par), portee_jeton(Ts, Par, P), P == autre_oeuvre
    ).

% --- Passages -------------------------------------------------------------------------------------------------------

% les termes passage_de(T) et passage_nom(Ns) deviennent des identifiants de passage, chacun avec ses positions
passages(_, _, Fs0, Ps) :-
    findall(X, ( member(F, Fs0), sous_terme_passage(F, X) ), Xs0), sort(Xs0, Xs),
    findall(passage(Id, D, Fin), ( member(X, Xs), id_passage(X, Id), bornes(X, D, Fin) ), Ps0),
    sort(Ps0, Ps).

sous_terme_passage(F, X) :- F =.. [_|Args], member(X, Args), compound(X), X =.. [N|_], memberchk(N, [passage_de, passage_nom]).

bornes(passage_de(t(_, _, _, _, _, _, _, _, D, F)), D, F).
bornes(passage_nom(Ns), D, F) :-
    findall(D0, member(t(_, _, _, _, _, _, _, _, D0, _), Ns), Ds), min_list(Ds, D),
    findall(F0, member(t(_, _, _, _, _, _, _, _, _, F0), Ns), Fs), max_list(Fs, F).

id_passage(passage_de(t(S, I, _, _, _, _, _, _, _, _)), Id) :- atomic_list_concat([p, S, I], '_', Id).
id_passage(passage_nom(Ns), Id) :-
    Ns = [t(S, I, _, _, _, _, _, _, _, _)|_], last(Ns, t(_, J, _, _, _, _, _, _, _, _)),
    atomic_list_concat([pn, S, I, J], '_', Id).

% remplace les termes passage_de/passage_nom par leurs identifiants
ordonner(Fs0, Fs) :-
    maplist(remplacer_passages, Fs0, Fs1),
    exclude(passage_sans_bornes, Fs1, Fs2),
    sort(Fs2, Fs).

remplacer_passages(F0, F) :-
    F0 =.. [N|Args0],
    maplist(arg_passage, Args0, Args),
    F =.. [N|Args].

arg_passage(X, Id) :- compound(X), X =.. [N|_], memberchk(N, [passage_de, passage_nom]), !, id_passage(X, Id).
arg_passage(X, X).

passage_sans_bornes(passage(_, D, F)) :- \+ ( integer(D), integer(F), D >= 0, D < F ).
