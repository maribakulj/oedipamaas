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
:- module(interpretation, [ interpreter/5,  % +Texte, +Langue, +Genre, +Phrases, -Faits
                            interpreter/6   % +Texte, +Langue, +Genre, +FinTitre, +Phrases, -Faits
                          ]).
:- encoding(utf8).
:- use_module(mondes, []).                 % l'ancrage, version 2
:- use_module(satisfaction, []).           % les liens lexicaux de K, pour les options de sûreté (X2)
:- use_module(connaissances_en, []).       % K (WordNet), lu seulement par les options de sûreté
:- use_module(connaissances_fr, []).       % K (WOLF)

% --- Les options de sûreté (expériences X1 à X3 de docs/EXPERIENCES_C7.md ; docs/mesures/SURETE_LECTEUR.md) --------
% OEDIPAMAAS_SURETE : une liste d'options séparées par des virgules ; sans elle, le lecteur est celui d'avant les
% expériences (aucune option). nombres (X1) ; portees, citations (X2, approche A) ; doute (X2, approche C : « dans le
% doute, non admissible ») ; certain (exploratoire, défini après la lecture de la validation : l'œuvre seulement par un
% lien certain dans K, D30).
option_surete(O) :- getenv('OEDIPAMAAS_SURETE', V), atomic_list_concat(Os, ',', V), memberchk(O, Os), !.

% --- Lexique grammatical (FR, EN) -----------------------------------------------------------------------------------

titre(saint). titre(sainte). titre(st). titre(ste). titre('st.'). titre(san). titre(santa). titre(santo).
titre(sankt).

negation_det(no). negation_det(neither). negation_det(aucun). negation_det(aucune). negation_det(nul). negation_det(nulle).
negation_case(sans). negation_case(without).
negation_cc(ni). negation_cc(nor). negation_cc(neither).
negation_adv(pas). negation_adv(not). negation_adv(jamais). negation_adv(never). negation_adv(point).
negation_adv(plus). negation_adv(nullement).
negation_adj(absent). negation_adj(absente). negation_adj(missing). negation_adj(invisible).
% X3 (option negations) : les autres adjectifs d'absence (« le bras a disparu ») ; pas « gone » (« his lantern gone
% out » : éteinte)
negation_adj(X) :- option_surete(negations), memberchk(X, [disparu, disparue, manquant, manquante]).

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
materiau(watercolor). materiau(tempera). materiau(détrempe). materiau(vélin). materiau(parchemin). materiau(carton).
materiau(percaline). materiau(chagrin). materiau(maroquin).

lieu_case(dans). lieu_case(sur). lieu_case(devant). lieu_case(derrière). lieu_case(sous). lieu_case(près).
lieu_case(in). lieu_case(on). lieu_case(before). lieu_case(behind). lieu_case(under). lieu_case(near).
lieu_case(at). lieu_case(beside).
instrument_case(avec). instrument_case(with).
agent_case(par). agent_case(by).

% --- Entrée ---------------------------------------------------------------------------------------------------------

interpreter(Texte, Langue, Genre, Phrases, Faits) :- interpreter(Texte, Langue, Genre, 0, Phrases, Faits).
% FinTitre : la fin du titre en tête du texte (0 sans titre) ; le titre n'est jamais ce qui annonce le sujet (D15)
interpreter(Texte, Langue, Genre, FinTitre, Phrases, Faits) :-
    b_setval(interpretation_langue, Langue),
    jetons(Phrases, Ts),
    entites(Ts, Ents),                       % liste de ent(E, Tete, ToksDuNom, TokTete, TokNom-ou-rien)
    findall(F, fait(Ts, Ents, F), Fs000),
    sort(Fs000, Fs00),                       % les doublons exacts (même fait trouvé deux fois) s'effacent
    maplist(nom_du_texte(Texte), Fs00, Fs01),
    identifiants_uniques(Fs01, Fs0),
    qualifier(Ts, Ents, Fs0, Fs10),
    ancrer(Genre, FinTitre, Ts, Ents, Fs10, Fs1),
    passages(Texte, Ts, Fs1, Ps),
    append([[texte(Texte), doc(Langue, Genre)], Ps, Fs1], Faits0),
    sort(Faits0, Faits1),
    ordonner(Faits1, Faits).

% deux faits distincts sous le même identifiant (deux prépositions sous un même nom, « à côté de » ; un adjectif
% épithète et attribut) : le second et les suivants reçoivent un suffixe (r_1_5, r_1_5_2…)
identifiants_uniques(Fs0, Fs) :- uniques(Fs0, [], Fs).
uniques([], _, []).
uniques([F0|Fs0], Vus0, [F|Fs]) :-
    (   F0 =.. [N, A|R], memberchk(N, [propriete, relation, evenement, nom])
    ->  (   selectchk(A-K0, Vus0, Vus1)
        ->  K is K0 + 1, atomic_list_concat([A, K], '_', A2), F =.. [N, A2|R], Vus = [A-K|Vus1]
        ;   F = F0, Vus = [A-1|Vus0]
        )
    ;   F = F0, Vus = Vus0
    ),
    uniques(Fs0, Vus, Fs).

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
% (pas une élision : « L’ », « S’ », « D’ », que l'analyseur range parfois en nom propre, ne sont pas des noms)
mot_du_nom(Ts, T) :- \+ est_titre(T), \+ elision(T), ( propre(T) -> true ; capitale_liee_a_un_titre(Ts, T) ).

elision(t(_, _, Fo, _, _, _, _, _, _, _)) :-
    atom_codes(Fo, Cs), include([C]>>code_type(C, alpha), Cs, Ls), length(Ls, N), N < 2.

capitale_liee_a_un_titre(Ts, T) :-
    T = t(S, I, Fo, _, C, _, H, _, _, _), I > 1, memberchk(C, ['ADJ', 'NOUN', 'X']), capitale(Fo),
    (   jeton(Ts, S, H, P), est_titre(P) -> true ; enfant(Ts, S, I, P), est_titre(P) ).

% une grappe : un nom propre en plusieurs mots, avec ses titres (flat, compound ; un titre aussi par nmod, appos)
lien_de_grappe(R) :- memberchk(R, [flat, compound]).
% une grappe est d'un seul tenant : entre un membre et sa tête, il n'y a que des mots du nom, des titres ou des mots de
% liaison (« Saint John the Baptist », « Catherine de Sienne ») ; sinon « Saint Lucy, identified by …; Saint Agnes »
% ferait un seul nom de trois saintes
dans_grappe(Ts, T) :-                    % T dépend d'un autre membre de grappe
    ( mot_du_nom(Ts, T) ; est_titre(T) ),
    T = t(S, I, _, _, _, _, H, R, _, _), rel_de_base(R, RB),
    d_un_seul_tenant(Ts, S, I, H),
    jeton(Ts, S, H, P), ( mot_du_nom(Ts, P) ; est_titre(P) ),
    (   lien_de_grappe(RB) -> true
    ;   memberchk(RB, [nmod, appos, amod]), ( est_titre(T) ; est_titre(P) ) -> true
    ;   % « Catherine de Sienne », « Catherine of Siena », « Antoine de Padoue » : un nom propre complément d'un nom
        % propre par « de »/« of » fait partie du nom (sinon Catherine de Sienne devient Catherine d'Alexandrie)
        % — seulement pour un nom qui porte un titre de saint (« Crucifixion de Rubens », « Sacrifice d'Isaac » restent
        % deux référents)
        RB == nmod, propre(T), propre(P), titre_attache(Ts, P),
        enfant(Ts, S, I, case, C), C = t(_, _, _, LC, _, _, _, _, _, _), memberchk(LC, [de, of, 'd\''])
    ).

d_un_seul_tenant(Ts, S, I, H) :-
    Min is min(I, H) + 1, Max is max(I, H) - 1,
    forall(between(Min, Max, K),
           ( jeton(Ts, S, K, X),
             ( mot_du_nom(Ts, X) ; est_titre(X)
             ; X = t(_, _, _, _, C, _, _, R, _, _), memberchk(C, ['DET', 'ADP']), rel_de_base(R, RB), memberchk(RB, [det, case])
             ) )).

% un titre (« saint », « sainte ») rattaché directement au nom propre P, comme dépendant ou comme tête
titre_attache(Ts, P) :-
    P = t(S, IP, _, _, _, _, HP, _, _, _),
    (   enfant(Ts, S, IP, X), est_titre(X) -> true
    ;   HP > 0, jeton(Ts, S, HP, X), est_titre(X)
    ), !.

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
    \+ nom_de_cadre_ou_de_locution(Ts, T),
    T = t(_, _, Fo, _, _, _, _, _, _, _), downcase_atom(Fo, Fm), \+ negation_adj(Fm),
    T = t(S, I, _, L, _, _, _, _, _, _),
    atomic_list_concat([e, S, I], '_', E).

% un nom qui ne désigne pas un référent (REFONTE F1) : le cadre spatial lui-même (« au premier plan », « at lower
% right » : le plan, la droite ne sont pas représentés), ou un nom commun au singulier sans déterminant dans un groupe
% prépositionnel figé (« en pied », « en bas », « at rest », « in profile », « by hand »)
% (prototype de la refonte, actif avec OEDIPAMAAS_REFONTE=1 ; défaut connu : le partitif nié « pas d'épée » est pris
% pour une locution)
nom_de_cadre_ou_de_locution(Ts, T) :-
    getenv('OEDIPAMAAS_REFONTE', '1'),
    T = t(S, I, _, L, 'NOUN', _, _, _, _, _),
    (   cadre_spatial(L) -> true
    ;   enfant(Ts, S, I, case, _), \+ enfant(Ts, S, I, det, _), \+ enfant(Ts, S, I, 'nmod:poss', _),
        \+ trait(T, 'Number', 'Plur'), \+ enfant(Ts, S, I, amod, _), \+ enfant(Ts, S, I, nmod, _)
    ), !.

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
% X3 (option modalites) : des événements en alternative (« s'il souffre ou s'il réfléchit », « whether he has fallen
% or is playing »)
fait(Ts, _, alternative(G, Vs)) :-
    option_surete(modalites),
    member(V1, Ts), V1 = t(S, I1, _, _, 'VERB', _, _, _, _, _), evenement_jeton(Ts, V1),
    findall(V, ( enfant(Ts, S, I1, conj, V2), V2 = t(_, I2, _, _, 'VERB', _, _, _, _, _), evenement_jeton(Ts, V2),
                 enfant(Ts, S, I2, cc, CC), CC = t(_, _, _, L, _, _, _, _, _, _), alternative_cc(L),
                 atomic_list_concat([v, S, I2], '_', V) ), Vs2),
    Vs2 \== [], atomic_list_concat([v, S, I1], '_', V0), sort([V0|Vs2], Vs),
    atomic_list_concat([g, S, I1], '_', G).
% « la figure est saint Pierre », « the saint is Jerome » : le sujet et le prédicat nominal désignent le même référent
fait(Ts, Ents, coref(E1, E2)) :-
    member(P, Ts), nominal(P), P = t(S, IP, _, _, _, _, _, _, _, _),
    enfant(Ts, S, IP, cop, _), enfant(Ts, S, IP, nsubj, Su),
    entite_du_jeton(Ts, Ents, Su, E1), entite_du_jeton(Ts, Ents, P, E2), E1 \== E2.
% l'apposition (« a short mantelet, a little cape », « Anna, Dido's sister ») : les deux noms désignent le même
% référent ; une coréférence établie (docs/PLAN_V1.md, C2.2)
fait(Ts, Ents, coref(E1, E2)) :-
    member(P, Ts), nominal(P), P = t(S, IP, _, _, _, _, _, _, _, _),
    enfant(Ts, S, IP, appos, A), nominal(A),
    entite_du_jeton(Ts, Ents, P, E1), entite_du_jeton(Ts, Ents, A, E2), E1 \== E2.
% X1 (docs/mesures/SURETE_LECTEUR.md) : un nombre dit (« two angels », « deux mains ») : un numéral cardinal
% (`nummod`) d'un nom ; seulement à partir de deux (« un » n'est pas un nombre dit : le guide du banc) ; un numéral
% qui ne se lit pas (« several », « quelques ») n'en donne aucun
fait(Ts, Ents, nombre(E, N)) :-
    option_surete(nombres),
    member(X, Ts), X = t(S, _, Fo, L, 'NUM', _, H, R, _, _), rel_de_base(R, nummod),
    jeton(Ts, S, H, Nn), nominal(Nn), entite_du_jeton(Ts, Ents, Nn, E),
    valeur_numerale(Fo, L, N), N >= 2.
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
qualificatif(Ts, Ents, Fs, A, enonciateur(A, En)) :-
    ( option_surete(citations), cite(Ts, Ents, Fs, A, Src) -> En = cite(Src) ; En = auteur ).

% X2, les sources citées : « according to Vasari, … », « selon Vasari, … » : ce qui dépend du verbe que la citation
% complète est énoncé par la source (le guide : `enonciateur`), sauf la source elle-même
cite(Ts, Ents, Fs, A, Src) :-
    jeton_de_assertion(Ts, Ents, Fs, A, T0),
    (   memberchk(nom(A, E, _, _), Fs) -> member(ent(E, _, _, T, _), Ents) ; T = T0 ),
    T = t(S, _, _, _, _, _, _, _, _, _),
    member(X, Ts), X = t(S, IX, _, _, _, _, HX, RX, _, _), nominal(X), rel_de_base(RX, obl),
    citation(Ts, X), HX > 0,
    dans_le_sous_arbre(Ts, T, HX), \+ dans_le_sous_arbre(Ts, T, IX),
    source_citee(Ts, Ents, X, Src), !.

% la préposition de citation : « selon », « according (to) » (les seules du guide : « according to Vasari »)
citation(Ts, t(S, I, _, _, _, _, _, _, _, _)) :-
    enfant(Ts, S, I, case, C), C = t(_, _, Fo, _, _, _, _, _, _, _), downcase_atom(Fo, F),
    memberchk(F, [selon, according]), !.

% la source : son nom propre s'il en a un, sinon le lemme de sa tête (« la légende », « the text »)
source_citee(_, Ents, X, Src) :-
    (   member(ent(_, _, Ns, _, Ms), Ents), memberchk(X, Ms), Ns \== []
    ->  findall(Fo, member(t(_, _, Fo, _, _, _, _, _, _, _), Ns), Fos), atomic_list_concat(Fos, ' ', Src)
    ;   X = t(_, _, _, Src, _, _, _, _, _, _)
    ).

% T est dans le sous-arbre du jeton I (de la même phrase), I compris
dans_le_sous_arbre(_, t(_, I, _, _, _, _, _, _, _, _), I) :- !.
dans_le_sous_arbre(Ts, t(S, _, _, _, _, _, H, _, _, _), I) :- H > 0, jeton(Ts, S, H, P), dans_le_sous_arbre(Ts, P, I).

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
    (   % X3 (option negations) : un groupe nominal nié par « not », « pas » (« only the bone is drawn, not the body »)
        option_surete(negations), nominal(T), enfant(Ts, S, I, advmod, N), N = t(_, _, _, LN, _, _, _, _, _, _),
        memberchk(LN, [not, pas])
    ;   enfant(Ts, S, I, det, D), D = t(_, _, _, L, _, _, _, _, _, _), negation_det(L)
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
% X3 (option modalites) : le contenu d'une question indirecte (« whether he has fallen or is playing », « s'il souffre
% ou s'il réfléchit ») et ce que dit une proposition complément d'un verbe nié (« what passes between them cannot be
% read ») ne sont pas affirmés (le guide : `non_affirme`, « le contenu d'une question »)
modalite_jeton(Ts, T, non_affirme) :- option_surete(modalites), dans_un_contenu_non_affirme(Ts, T), !.
% X3 : un être dont seule l'existence est modalisée (« où apparaissait peut-être la terre ») : le sujet d'un verbe de
% présence modalisé prend sa modalité
modalite_jeton(Ts, T, M) :-
    option_surete(modalites),
    T = t(S, _, _, _, _, _, H, R, _, _), H > 0, rel_de_base(R, nsubj),
    jeton(Ts, S, H, V), V = t(_, IV, _, LV, _, _, _, _, _, _), ( presence(LV) ; memberchk(LV, [exister, exist]) ),
    (   enfant(Ts, S, IV, advmod, X), X = t(_, _, _, L, _, _, _, _, _, _), modal_adv(L, M)
    ;   enfant(Ts, S, IV, aux, X), X = t(_, _, _, L, _, _, _, _, _, _), modal_verbe(L, M)
    ), !.
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

dans_un_contenu_non_affirme(Ts, T) :-
    T = t(S, I, _, _, _, _, _, _, _, _),
    member(V, Ts), V = t(S, IV, _, _, 'VERB', _, HV, RV, _, _),
    (   enfant(Ts, S, IV, mark, Mk), Mk = t(_, _, FoM, _, _, _, _, _, _, _), downcase_atom(FoM, FM),
        memberchk(FM, [whether, if, si, 's\'', 's’'])
    ;   rel_de_base(RV, RBV), memberchk(RBV, [ccomp, csubj, xcomp]), HV > 0, jeton(Ts, S, HV, P),
        verbe_nie_ou_impossible(Ts, P)
    ;   % la double négation (décision du 27/11) : l'événement dont le sujet est nié par « no », « aucun »
        enfant(Ts, S, IV, nsubj, Su), Su = t(_, ISu, _, _, _, _, _, _, _, _),
        enfant(Ts, S, ISu, det, D), D = t(_, _, _, LD, _, _, _, _, _, _), negation_det(LD), T == V
    ),
    dans_le_sous_arbre(Ts, T, IV), I \== HV, !.
% un verbe nié (« ne … pas », « not », « cannot »)
verbe_nie_ou_impossible(Ts, P) :- verbe_nie(Ts, P), !.
verbe_nie_ou_impossible(Ts, t(S, I, _, _, 'VERB', _, _, _, _, _)) :-
    enfant(Ts, S, I, aux, A), A = t(_, IA, _, _, _, _, _, _, _, _),
    ( enfant(Ts, S, IA, advmod, N) ; enfant(Ts, S, I, advmod, N) ), N = t(_, _, _, L, _, _, _, _, _, _), negation_adv(L), !.

% portée : ce qui dépend de « d'après », « after » est une autre œuvre ; un matériau, l'œuvre elle-même
porte(Ts, Ents, Fs, A, P) :-
    jeton_de_assertion(Ts, Ents, Fs, A, T0),
    (   memberchk(nom(A, E, _, _), Fs) -> member(ent(E, _, _, T, _), Ents)
    ;   memberchk(propriete(A, E, _, _), Fs) -> member(ent(E, _, _, T, _), Ents)
    ;   T = T0
    ),
    portee_jeton(Ts, T, P), !.
% X2 (option portees) : la portée dite par le discours sur l'œuvre ; pas pour une relation (« le centre de la
% composition » est une relation de l'image : sa portée n'est pas celle de son complément)
porte(Ts, Ents, Fs, A, P) :-
    option_surete(portees), \+ memberchk(relation(A, _, _, _, _), Fs),
    jeton_de_assertion(Ts, Ents, Fs, A, T0),
    (   memberchk(nom(A, E, _, _), Fs) -> member(ent(E, _, _, T, _), Ents)
    ;   memberchk(propriete(A, E, _, _), Fs) -> member(ent(E, _, _, T, _), Ents)
    ;   T = T0
    ),
    portee_du_discours(Ts, T, P), !.

% le support de l'œuvre (album, folio, recto, reliure, étiquette…) : une phrase dont la racine ou le sujet est un
% support parle de l'objet, pas de l'image ; un nom complément d'un support aussi (« le dos de l'album ») ; une
% technique introduite par « à »/« au » (« à la plume », « à la pierre noire », « au lavis ») (jugement J2)
support(album). support(carnet). support(folio). support(feuillet). support(recto). support(verso). support(reliure).
support(cartonnage). support(plat). support(gaine). support(étiquette). support(annotation). support(monture).
support(montage). support('passe-partout'). support(encadrement). support(filigrane). support(couverture).
support(page). support(planche). support(numéro). support(inventaire). support(cachet). support(marque).
technique(plume). technique(pierre). technique(sanguine). technique(lavis). technique(fusain). technique(mine).
technique(graphite). technique(crayon). technique(pinceau). technique(burin). technique(pointe). technique(rehaut).
technique(craie). technique(encre). technique(aquarelle). technique(gouache). technique(pastel). technique(huile).

phrase_de_support(Ts, S) :-
    member(R, Ts), R = t(S, _, _, LR, _, _, 0, _, _, _),
    (   support(LR) -> true
    ;   R = t(_, IR, _, _, _, _, _, _, _, _), enfant(Ts, S, IR, nsubj, X), X = t(_, _, _, LX, _, _, _, _, _, _), support(LX)
    ), !.

portee_jeton(Ts, T, oeuvre) :-
    T = t(S, I, _, L, _, _, H, _, _, _),
    (   phrase_de_support(Ts, S)
    ;   support(L)
    ;   technique(L), enfant(Ts, S, I, case, C), C = t(_, _, _, LC, _, _, _, _, _, _), memberchk(LC, ['à', au, aux, en])
    ;   H > 0, jeton(Ts, S, H, Par), Par = t(_, _, _, LP, _, _, _, _, _, _), support(LP)
    ), !.
portee_jeton(Ts, T, P) :-
    T = t(S, I, _, L, _, _, H, _, _, _),
    (   enfant(Ts, S, I, case, C), C = t(_, IC, _, LC, _, _, _, _, _, _),
        ( autre_oeuvre_case(LC) ; enfant(Ts, S, IC, fixed, Fx), Fx = t(_, _, _, LF, _, _, _, _, _, _), autre_oeuvre_case(LF) )
    ->  P = autre_oeuvre
    ;   materiau(L) -> P = oeuvre
    ;   H > 0, jeton(Ts, S, H, Par), nominal(Par), portee_jeton(Ts, Par, P), P == autre_oeuvre
    ).

% X2 (option portees) : la portée dite par le discours sur l'œuvre, d'après le guide du banc (docs/BANC_GRAPHES.md,
% « portee » et décisions du 27/11 : « le peintre a la portée histoire, ses actes sur l'image la portée oeuvre » ;
% H1 : un texte qui accompagne l'œuvre, `oeuvre` ; H2 : la notice, `non_ancre`) :
%   - l'auteur de l'œuvre, désigné (« le peintre », « the artist ») : `histoire` ;
%   - l'œuvre elle-même, désignée (« l'image », « this engraving », « la composition ») : `oeuvre` ; une création au
%     sens de K (WordNet : creation ; WOLF : création), hors de l'objet d'une action de figure (« il tient le livre ») ;
%   - le spectateur, la notice, le catalogue, l'historien : `non_ancre` ;
%   - un événement dont l'auteur ou l'œuvre est le sujet (« the painter places … », « the composition leads … ») :
%     `oeuvre` ; dont la notice est le sujet : `non_ancre`.
% « Désigné » : un déterminant défini, démonstratif ou possessif ; une mention indéfinie (« un peintre à son
% chevalet ») est une figure de la scène. Option doute (approche C) : les mêmes règles, et aussi les parties du plan de
% l'image (le premier plan, le fond : le cadre spatial) et la légende, `oeuvre`.
portee_du_discours(Ts, T, non_ancre) :- nominal(T), complement_d_un_style(Ts, T), !.
portee_du_discours(Ts, T, P) :- nominal(T), \+ propre(T), portee_nominale(Ts, T, P), !.
portee_du_discours(Ts, T, P) :-
    T = t(S, I, _, _, C, _, _, _, _, _), memberchk(C, ['VERB', 'ADJ']),
    (   enfant(Ts, S, I, nsubj, X) ; complement_d_agent(Ts, T, X) ),
    nominal(X), \+ propre(X), portee_nominale(Ts, X, P0),
    ( memberchk(P0, [histoire, oeuvre]) -> P = oeuvre ; P = P0 ), !.

portee_nominale(Ts, T, histoire) :- auteur_de_l_oeuvre(T), designe(Ts, T), !.
portee_nominale(Ts, T, oeuvre) :-
    ( option_surete(certain) -> l_oeuvre_certaine(T) ; l_oeuvre(T) ),
    designe(Ts, T), \+ objet_d_une_action_de_figure(Ts, T), !.
portee_nominale(Ts, T, oeuvre) :- sujet_d_une_figuration(Ts, T), !.
% le contenant de la scène (« Dans une gravure fantastique, … ») : une œuvre de façon certaine dans K (toutes ses
% lectures ; « dans un paysage », « on the ground » ne disent pas l'œuvre) ; avec l'option doute, possible suffit
portee_nominale(Ts, T, oeuvre) :-
    contenant_de_la_scene(Ts, T), ( option_surete(doute) -> l_oeuvre(T) ; l_oeuvre_certaine(T) ), !.
portee_nominale(_, t(_, _, _, L, _, _, _, _, _, _), non_ancre) :- discours_sur_l_oeuvre(L), !.
portee_nominale(Ts, T, oeuvre) :-
    option_surete(doute), T = t(_, _, _, L, _, _, _, _, _, _),
    ( cadre_spatial(L) ; texte_de_l_oeuvre(L), designe(Ts, T) ), !.

% le complément du nom d'un style (« à la manière de Poussin », nom propre compris) : non ancré comme lui
complement_d_un_style(Ts, t(S, _, _, _, _, _, H, R, _, _)) :-
    H > 0, rel_de_base(R, nmod), jeton(Ts, S, H, P), P = t(_, _, _, LP, _, _, _, _, _, _), style(LP), !.

% l'auteur : le praticien d'une technique de l'image (peindre, sculpter, photographier, graver, dessiner, illustrer,
% enluminer), ou un hyponyme dans K (« miniaturist » : painter) ; « artist » / « artiste » seulement comme mot (ses
% hyponymes dans K comprennent les musiciens, qui sont des figures)
auteur_de_l_oeuvre(t(_, _, _, L, _, _, _, _, _, _)) :-
    b_getval(interpretation_langue, La),
    (   memberchk(La-L, [en-artist, fr-artiste]) -> true
    ;   praticien(La, A), ( L == A -> true ; lien_lexical(La, L, A) )
    ), !.
praticien(en, A) :- member(A, [painter, sculptor, photographer, engraver, draftsman, draughtsman, illustrator, illuminator]).
praticien(fr, A) :- member(A, [peintre, sculpteur, photographe, graveur, dessinateur, illustrateur, enlumineur]).

% l'œuvre : une création, une représentation ou une œuvre d'art (art) dans K (WOLF n'a « tableau » que sous art) ;
% et les mots que le guide nomme pour l'objet matériel (la toile, le panneau, l'état, la technique, le cadre), pour la
% composition et pour le titre
l_oeuvre(t(_, _, _, L, _, _, _, _, _, _)) :-
    b_getval(interpretation_langue, La),
    (   mot_de_l_objet(La, L) -> true
    ;   ancre_de_l_oeuvre(La, A), lien_lexical(La, L, A)
    ), !.
l_oeuvre_certaine(t(_, _, _, L, _, _, _, _, _, _)) :-
    b_getval(interpretation_langue, La),
    (   mot_de_l_objet(La, L) -> true
    ;   ancre_de_l_oeuvre(La, A), lien_lexical_certain(La, L, A)
    ), !.
ancre_de_l_oeuvre(La, A) :- member(La-A, [en-creation, en-representation, en-art, fr-création, fr-représentation, fr-art]).
mot_de_l_objet(en, L) :- memberchk(L, [canvas, panel, sheet, state, technique, frame, composition, work, artwork, title]).
mot_de_l_objet(fr, L) :- memberchk(L, [toile, panneau, feuille, état, technique, cadre, composition, œuvre, titre]).

% ce qui parle de l'œuvre sans être figuré (guide : `non_ancre`, « biographie, style, jugement » ; H2 : la notice)
discours_sur_l_oeuvre(L) :- style(L), !.
discours_sur_l_oeuvre(L) :- memberchk(L, [viewer, spectator, beholder, catalogue, catalog, historian, scholar, critic,
    spectateur, notice, historien, critique]).
% le style (le guide : `non_ancre`)
style(L) :- memberchk(L, [manière, style, manner, façon]).
% le texte qui accompagne l'œuvre (H1) : approche C seulement (« legend », « légende » est aussi un récit)
texte_de_l_oeuvre(L) :- memberchk(L, [caption, legend, label, légende, cartel]).

designe(Ts, t(S, I, _, _, _, _, _, _, _, _)) :-
    (   enfant(Ts, S, I, det, D), D = t(_, _, Fo, L, _, Tr, _, _, _, _), downcase_atom(Fo, F),
        (   memberchk('Definite'='Def', Tr) ; memberchk('PronType'='Dem', Tr) ; memberchk('Poss'='Yes', Tr)
        ;   memberchk(F, [the, this, that, these, those, le, la, les, 'l\'', 'l’', ce, cet, cette, ces])
        ;   memberchk(L, [the, this, le, ce, son, sa, ses, his, her, its, their])
        )
    ;   enfant(Ts, S, I, 'nmod:poss', _)
    ), !.

% « Une affiche montre une jeune femme », « An anatomical plate shows a nude » : le sujet d'un verbe de figuration
% employé transitivement, sans destinataire (« elle lui montre le livre » est une action de figure), est l'image
sujet_d_une_figuration(Ts, t(S, _, _, _, _, _, H, R, _, _)) :-
    H > 0, rel_de_base(R, nsubj), R \== 'nsubj:pass',
    jeton(Ts, S, H, V), V = t(_, IV, _, LV, 'VERB', _, _, _, _, _), verbe_de_figuration(LV),
    enfant(Ts, S, IV, obj, _), \+ enfant(Ts, S, IV, iobj, _), \+ destinataire_oblique(Ts, S, IV), !.
verbe_de_figuration(L) :- memberchk(L, [représenter, montrer, dépeindre, illustrer, depict, represent, show, portray,
    illustrate]).
destinataire_oblique(Ts, S, IV) :-
    enfant(Ts, S, IV, obl, X), X = t(_, IX, _, _, _, _, _, _, _, _),
    enfant(Ts, S, IX, case, C), C = t(_, _, _, LC, _, _, _, _, _, _), memberchk(LC, ['à', to]), !.
% « Dans une gravure fantastique, … », « dessinée sur la feuille », « in this painting » : le contenant de la scène
contenant_de_la_scene(Ts, t(S, I, _, _, _, _, H, R, _, _)) :-
    H > 0, rel_de_base(R, obl), jeton(Ts, S, H, V), V = t(_, _, _, _, C, _, _, _, _, _), memberchk(C, ['VERB', 'ADJ']),
    enfant(Ts, S, I, case, Ca), Ca = t(_, _, _, LC, _, _, _, _, _, _), memberchk(LC, [dans, sur, in, on]), !.

objet_d_une_action_de_figure(Ts, t(S, _, _, _, _, _, H, R, _, _)) :-
    H > 0, rel_de_base(R, RB), memberchk(RB, [obj, obl, iobj]),
    jeton(Ts, S, H, V), V = t(_, _, _, LV, _, _, _, _, _, _), action_de_figure(LV), !.

% un lien de L vers A dans K (connaissances_en / connaissances_fr) ; possible suffit (la polysémie rend « image »,
% « picture » seulement possibles) : la règle rend non admissible, elle n'établit rien
lien_lexical(La, L, A) :-
    k_langue(La, K),
    (   once(K:sens(_, _, _)) -> true
    ;   throw(error(existence_error(connaissances, K), option_surete(portees)))
    ),
    once(satisfaction:lien_pos(K, n, L, A, _)).
lien_lexical_certain(La, L, A) :-
    k_langue(La, K),
    (   once(K:sens(_, _, _)) -> true
    ;   throw(error(existence_error(connaissances, K), option_surete(portees)))
    ),
    satisfaction:lien_pos_certain(K, n, L, A).
k_langue(en, connaissances_en). k_langue(fr, connaissances_fr).

% X1 : la valeur d'un numéral : en chiffres, ou un nombre cardinal en lettres (la classe grammaticale fermée des
% numéraux simples ; un composé « vingt-deux » n'est pas lu)
valeur_numerale(Fo, _, N) :- atom_number(Fo, N), integer(N), !.
valeur_numerale(Fo, L, N) :- downcase_atom(Fo, F), ( cardinal(F, N) -> true ; cardinal(L, N) ), !.
cardinal(one, 1). cardinal(two, 2). cardinal(three, 3). cardinal(four, 4). cardinal(five, 5). cardinal(six, 6).
cardinal(seven, 7). cardinal(eight, 8). cardinal(nine, 9). cardinal(ten, 10). cardinal(eleven, 11). cardinal(twelve, 12).
cardinal(thirteen, 13). cardinal(fourteen, 14). cardinal(fifteen, 15). cardinal(sixteen, 16). cardinal(seventeen, 17).
cardinal(eighteen, 18). cardinal(nineteen, 19). cardinal(twenty, 20). cardinal(thirty, 30). cardinal(forty, 40).
cardinal(fifty, 50). cardinal(hundred, 100). cardinal(thousand, 1000).
cardinal(un, 1). cardinal(une, 1). cardinal(deux, 2). cardinal(trois, 3). cardinal(quatre, 4). cardinal(cinq, 5).
cardinal(six, 6). cardinal(sept, 7). cardinal(huit, 8). cardinal(neuf, 9). cardinal(dix, 10). cardinal(onze, 11).
cardinal(douze, 12). cardinal(treize, 13). cardinal(quatorze, 14). cardinal(quinze, 15). cardinal(seize, 16).
cardinal(vingt, 20). cardinal(trente, 30). cardinal(quarante, 40). cardinal(cinquante, 50). cardinal(cent, 100).
cardinal(mille, 1000).

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

% --- Ancrage dans l'image (docs/REFONTE.md, F1) ----------------------------------------------------------------------

% Rien n'est représenté sans ancrage. Une description visuelle (genre « description » : la sortie d'un descripteur
% d'images, qui décrit ce qu'il voit) est ancrée par construction. Dans un cartel, une notice, un texte savant, une
% entité n'a la portée « represente » que si le texte la rattache à l'image : complément d'un verbe de représentation,
% placée dans un cadre spatial de l'image, sujet d'une posture ou d'une action de figure, ou porteuse d'une propriété
% de posture ; l'ancrage se propage par les relations, les rôles d'un même événement, la coordination, les compléments
% du nom et la coréférence. Le reste a la portée « non_ancre » : il n'établit rien.

% prototype de la refonte : actif seulement avec OEDIPAMAAS_REFONTE=1 (banc d'essai), en attendant la décision
ancrage_requis(Genre) :- getenv('OEDIPAMAAS_REFONTE', '1'), \+ memberchk(Genre, [description]).

ancrer(Genre, _, _, _, Fs, Fs) :- \+ ancrage_requis(Genre), !.
ancrer(_, FinTitre, Ts, Ents, Fs0, Fs) :-                % version 2, les deux mondes (mondes.pl) ; la version 1
    \+ getenv('OEDIPAMAAS_ANCRAGE', v1), !,               % reste pour la comparaison (OEDIPAMAAS_ANCRAGE=v1)
    mondes:mondes(FinTitre, Ts, Ents, Fs0, Fs).
ancrer(_, _, Ts, Ents, Fs0, Fs) :-
    findall(E, ( member(ent(E, _, _, T, _), Ents), ancre_base(Ts, T) ), B0), sort(B0, B),
    propager(Ts, Ents, Fs0, B, Anc),
    maplist(requalifier_portee(Fs0, Anc), Fs0, Fs).

requalifier_portee(Fs, Anc, portee(A, represente), portee(A, P)) :- !,
    (   entites_concernees(Fs, A, Es), Es \== [], \+ ( member(E, Es), memberchk(E, Anc) ) -> P = non_ancre
    ;   P = represente
    ).
requalifier_portee(_, _, F, F).

entites_concernees(Fs, A, Es) :-
    (   memberchk(entite(A, _, _), Fs) -> Es = [A]
    ;   memberchk(nom(A, E, _, _), Fs) -> Es = [E]
    ;   memberchk(propriete(A, E, _, _), Fs) -> Es = [E]
    ;   memberchk(relation(A, E1, _, E2, _), Fs) -> Es = [E1, E2]
    ;   memberchk(evenement(A, _, _), Fs) -> findall(E, member(role(A, _, E), Fs), Es)
    ;   Es = []
    ).

verbe_de_representation(L) :- memberchk(L, [représenter, figurer, montrer, peindre, dessiner, sculpter, graver, voir,
    apparaître, dépeindre, illustrer, présenter, depict, represent, show, portray, feature, see, appear, picture,
    paint, draw, render, illustrate, present, capture, carve, show]).
cadre_spatial(L) :- memberchk(L, [plan, 'premier-plan', 'arrière-plan', fond, centre, milieu, gauche, droite, coin,
    angle, foreground, background, left, right, center, centre, corner, middle, distance, side, top, bottom]).
verbe_d_inscription(L) :- memberchk(L, [signer, annoter, inscrire, dater, numéroter, marquer, sign, inscribe, date,
    annotate, number, mark, stamp, coller, monter, mount]).
action_de_figure(L) :- memberchk(L, [tenir, porter, regarder, lever, poser, agenouiller, asseoir, appuyer, marcher,
    courir, danser, jouer, lire, écrire, prier, combattre, tuer, embrasser, offrir, tendre, désigner, pointer, reposer,
    dormir, nourrir, allaiter, chevaucher, monter, couronner, bénir, frapper, contempler, écarter, tirer, saisir, entourer,
    hold, carry, wear, look, gaze, stand, sit, kneel, lie, lean, raise, point, read, write, pray, fight, kill, embrace,
    offer, play, dance, walk, ride, rest, sleep, nurse, crown, bless, strike, contemplate, draw, pull, grasp, surround,
    reach, turn, face, stare, watch, bend, rise, flank, accompany, present]).
posture(L) :- memberchk(L, [agenouillé, agenouiller, assis, asseoir, debout, couché, coucher, allongé, allonger, nu, vêtu,
    vêtir, drapé, draper, couronné, couronner, kneeling, kneel, seated, seat, standing, stand, lying, lie, reclining,
    recline, nude, naked, dressed, dress, clad, crowned, crown, wearing, wear]).

% les bases de l'ancrage, sur le jeton tête d'une entité
ancre_base(Ts, T) :-
    T = t(S, I, _, _, _, _, H, R, _, _), rel_de_base(R, RB),
    (   % complément ou sujet passif d'un verbe de représentation (« représente un diacre », « is shown »)
        H > 0, jeton(Ts, S, H, V), V = t(_, _, _, LV, _, _, _, _, _, _), verbe_de_representation(LV),
        memberchk(RB, [obj, obl, xcomp, nsubj, ccomp, iobj])
    ;   % un nom que complète un participe de représentation (« a devout woman, shown at lower right »)
        enfant(Ts, S, I, acl, P), P = t(_, _, _, LP, _, _, _, _, _, _), verbe_de_representation(LP)
    ;   % sujet ou objet d'une action ou d'une posture de figure (« a young girl draws back a curtain »)
        H > 0, jeton(Ts, S, H, V), V = t(_, IV, _, LV, CV, _, _, _, _, _), memberchk(CV, ['VERB', 'ADJ']),
        ( action_de_figure(LV) ; posture(LV) ), memberchk(RB, [nsubj, obj, 'nsubj:pass']),
        \+ verbe_d_inscription(LV), IV = IV
    ;   % porteur d'une propriété de posture (« un saint agenouillé », « a seated woman »)
        enfant(Ts, S, I, X), X = t(_, _, _, LX, _, _, _, RX, _, _), rel_de_base(RX, RBX),
        memberchk(RBX, [amod, acl]), posture(LX)
    ;   % placé dans l'image (« au premier plan », « in the lower-left corner »), hors des inscriptions
        cadre_de(Ts, T)
    ), !.

cadre_de(Ts, T) :-
    T = t(S, I, _, _, _, _, H, R, _, _),
    (   enfant(Ts, S, I, X), X = t(_, _, _, LX, _, _, _, RX, _, _), rel_de_base(RX, RBX), memberchk(RBX, [nmod, obl]),
        cadre_spatial(LX)
    ;   rel_de_base(R, RB), memberchk(RB, [nsubj, obj, 'nsubj:pass']), H > 0, jeton(Ts, S, H, V),
        V = t(_, IV, _, LV, _, _, _, _, _, _), \+ verbe_d_inscription(LV),
        enfant(Ts, S, IV, obl, X), X = t(_, _, _, LX, _, _, _, _, _, _), cadre_spatial(LX)
    ), !.

% propagation jusqu'au point fixe
propager(Ts, Ents, Fs, A0, A) :-
    findall(E2, ( member(E1, A0), voisin_ancre(Ts, Ents, Fs, E1, E2), \+ memberchk(E2, A0) ), N0), sort(N0, N),
    (   N == [] -> A = A0 ; append(A0, N, A1), sort(A1, A2), propager(Ts, Ents, Fs, A2, A) ).

voisin_ancre(_, _, Fs, E1, E2) :- member(relation(_, E1, _, E2, _), Fs).
voisin_ancre(_, _, Fs, E1, E2) :- member(relation(_, E2, _, E1, _), Fs).
voisin_ancre(_, _, Fs, E1, E2) :- member(role(V, _, E1), Fs), member(role(V, _, E2), Fs), E2 \== E1.
voisin_ancre(_, _, Fs, E1, E2) :- ( member(coref(E1, E2), Fs) ; member(coref(E2, E1), Fs) ).
voisin_ancre(Ts, Ents, _, E1, E2) :-                    % coordination et compléments du nom
    member(ent(E1, _, _, T1, _), Ents), T1 = t(S, I1, _, _, _, _, H1, R1, _, _),
    (   enfant(Ts, S, I1, RB, T2), memberchk(RB, [conj, nmod, appos])
    ;   rel_de_base(R1, RB1), memberchk(RB1, [conj, appos]), jeton(Ts, S, H1, T2)
    ),
    member(ent(E2, _, _, T2, _), Ents).

