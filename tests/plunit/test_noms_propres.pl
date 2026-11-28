/*  Tests de normaliser_nom/2, tete_mot_cle/2 et sens_de_lieu/1, les trois fonctions que l'étape 1 de
    docs/INTEGRATION_NOYAU.md (§ 2) déplace de raisonnement.pl vers le module neutre noms_propres.pl.

    SPÉCIFICATION. Ces fonctions n'ont pas de spécification écrite. Ce qui en tient lieu :
      - le commentaire de normaliser_nom dans raisonnement.pl : « un nom normalisé : capitales sans accents, espaces
        simples (« Jérôme » → JEROME) » ; docs/NOYAU.md, § 2 : K:cle_de_nom(Nom, Cle) est « la forme normalisée d'un nom
        propre », et l'alias (K:alias/2) relie « deux noms d'un même individu » : deux noms qui donnent la même clé sont
        donc pris pour un seul nom ;
      - le commentaire de tete_mot_cle : la tête d'un mot clé « Nom (rôle) » (« Pierre (St) », « Psammétique (roi) ») ;
      - le commentaire de nom_de_lieu : sens_de_lieu(S) est vrai si le synset S est une instance ou une sorte de
        « location » (synset WordNet 3.0 100027167), par ins/2 ou hyp/2, à un pas ou plus.
    Ce qui n'est pas écrit est un TEST DE CARACTÉRISATION : il fige le comportement du code au commit de la branche
    (git show HEAD:oedipamaas/socle/raisonnement.pl), sans dire qu'il est juste. Chaque test de ce genre porte le
    commentaire « CARACTÉRISATION » ; ceux dont le comportement paraît discutable portent en plus « QUESTION : ».
    Ne pas « corriger » un test de caractérisation pour suivre une évolution du code : changer le comportement est une
    décision, qui se prend d'abord (et qui change les clés de tout index construit : cles_index, propres_index…).

    APPEL. Avant l'étape 1 les trois prédicats sont définis dans raisonnement, après dans noms_propres et vus de
    raisonnement par importation (raisonnement les importe sans les réexporter). Les tests les appellent donc qualifiés par raisonnement:, qui les résout dans les
    deux états (avant : défini ; après : importé). Le groupe « etape1 » vérifie le déplacement lui-même (il échoue avant
    l'étape 1). Sans donnée : sens_de_lieu est essayé sur de petites facts wordnet:ins/2 et wordnet:hyp/2 écrites ici.

    GÉNÉRATIF. Les propriétés générales tirent des chaînes au hasard ; la graine est fixe (20261128) ou donnée par
    OEDIPAMAAS_GRAINE_NOMS ; un échec écrit la graine et la chaîne sur la sortie d'erreur.  */
:- use_module('../../oedipamaas/socle/raisonnement').
:- use_module(library(plunit)).
:- use_module(library(lists)).
:- use_module(library(apply)).
:- use_module(library(random)).
:- use_module(library(process)).
:- use_module(library(readutil)).
:- encoding(utf8).

:- dynamic wordnet:ins/2, wordnet:hyp/2, wordnet:s/6.

:- prolog_load_context(directory, D), asserta(dossier_des_tests(D)).

nn(Nom, K) :- raisonnement:normaliser_nom(Nom, K).
tete(Mot, Nom) :- raisonnement:tete_mot_cle(Mot, Nom).

% ===================================================================================================================
% normaliser_nom/2
% ===================================================================================================================

:- begin_tests(normaliser_nom_documente).

% -- la casse (documenté : « capitales ») ---------------------------------------------------------------------------
test(minuscules_en_capitales) :- nn('jean', 'JEAN').
test(casse_mixte) :- nn('jEaN pIeRRe', 'JEAN PIERRE').
test(deja_en_capitales) :- nn('JEAN', 'JEAN').
test(casse_indifferente) :- nn('Hieronymus Bosch', K), nn('HIERONYMUS BOSCH', K), nn('hieronymus bosch', K).
test(negatif_deux_noms_differents, [fail]) :- nn('Pierre', K), nn('Paul', K).
test(negatif_ordre_des_mots_compte, [fail]) :- nn('Jean Pierre', K), nn('Pierre Jean', K).

% -- les accents (documenté : « sans accents », « Jérôme » → JEROME) -------------------------------------------------
test(exemple_de_la_documentation) :- nn('Jérôme', 'JEROME').
test(accents_minuscules_courants) :-
    forall(member(Nom-K, [ 'é'-'E', 'è'-'E', 'ê'-'E', 'ë'-'E', 'à'-'A', 'â'-'A', 'î'-'I', 'ï'-'I', 'ô'-'O', 'ö'-'O',
                           'ù'-'U', 'û'-'U', 'ü'-'U', 'ç'-'C' ]),
           ( nn(Nom, K1), K1 == K )).
test(accents_capitales_courantes) :-       % seules É, È, À, Ç sont repliées parmi les capitales : voir la caractérisation
    forall(member(Nom-K, [ 'É'-'E', 'È'-'E', 'À'-'A', 'Ç'-'C' ]), ( nn(Nom, K1), K1 == K )).
test(avec_et_sans_accent_meme_cle) :- nn('Jérôme', K), nn('Jerome', K), nn('JEROME', K), nn('jérôme', K).
test(accent_et_casse_combines) :- nn('Ève', 'EVE'), nn('éve', 'EVE'), nn('Ésaïe', 'ESAIE').
test(negatif_une_autre_lettre_reste_une_autre_lettre, [fail]) :- nn('Jérôme', K), nn('Jerema', K).
test(negatif_l_accent_ne_cree_pas_d_homonymie_gratuite, [fail]) :- nn('Léon', K), nn('Leona', K).

% -- les espaces (documenté : « espaces simples ») -------------------------------------------------------------------
test(espaces_multiples) :- nn('Pierre   Martyr', 'PIERRE MARTYR').
test(espaces_de_bordure) :- nn('  Pierre Martyr  ', 'PIERRE MARTYR').
test(tabulation_et_fin_de_ligne) :- nn('Pierre\tMartyr', 'PIERRE MARTYR'), nn('Pierre\nMartyr', 'PIERRE MARTYR').
test(espace_insecable) :- nn('Pierre Martyr', 'PIERRE MARTYR'), nn('Pierre   Martyr', 'PIERRE MARTYR').
test(espaces_unicode_usuels) :-
    forall(member(C, [0x2009, 0x202f, 0x2003, 0x3000, 0x1680, 0x205f]),
           ( atom_codes(Nom, [0'p, C, 0'q]), nn(Nom, K), K == 'P Q' )).
test(chaine_vide) :- nn('', '').
test(que_des_espaces) :- nn('   ', ''), nn('  \t', '').
test(negatif_des_espaces_ne_sont_pas_supprimes, [fail]) :- nn('Pierre Martyr', K), nn('PierreMartyr', K).

% -- les formes de l'argument ----------------------------------------------------------------------------------------
test(chaine_acceptee_resultat_atome) :- nn("Jérôme", K), K == 'JEROME', atom(K).
test(nombre_accepte) :- nn(123, K), K == '123'.
test(un_atome_simple) :- nn(a, 'A').
test(non_instancie_est_une_erreur, [throws(error(instantiation_error, _))]) :- nn(_, _).
test(terme_compose_est_une_erreur, [throws(error(type_error(_, _), _))]) :- nn(f(x), _).
test(sortie_deja_liee_juste) :- nn('x', 'X').
test(sortie_deja_liee_fausse, [fail]) :- nn('x', 'y').
test(determinisme, [true(Ks == ['JEROME'])]) :- findall(K, nn('Jérôme', K), Ks).

% -- noms latins et composés (documenté seulement par « capitales, sans accents » ; le contenu reste intact) ---------
test(nom_latin) :- nn('Marcus Tullius Cicero', 'MARCUS TULLIUS CICERO'), nn('Publius Ovidius Naso', 'PUBLIUS OVIDIUS NASO').
test(nom_latin_latinise) :- nn('Hieronymus', 'HIERONYMUS').
test(nom_compose_a_particule) :- nn('Léonard de Vinci', 'LEONARD DE VINCI'), nn('Anne de Bretagne', 'ANNE DE BRETAGNE').
test(nom_compose_particule_collee_a_l_apostrophe) :- nn('Pierre d\'Alcantara', 'PIERRE D\'ALCANTARA').
test(numeraux_romains) :- nn('Louis XIV', 'LOUIS XIV'), nn('louis xiv', 'LOUIS XIV').
test(negatif_la_particule_compte, [fail]) :- nn('Van Gogh', K), nn('Gogh', K).

% -- l'idempotence ---------------------------------------------------------------------------------------------------
test(idempotence_sur_des_exemples) :-
    forall(member(Nom, [ 'Jérôme', 'Pierre d\'Alcantara', '  Saint  Pierre ', 'Hieronymus Bosch', '', 'Œdipe', 'Pâris',
                         'Jean-Baptiste', 'Pierre Martyr', 'Jeróme', 'ÀÂÄ', 'Zoë', 'ÿ', 'ß', 'Louis XIV' ]),
           ( nn(Nom, K1), nn(K1, K2), ( K1 == K2 -> true ; format(user_error, "non idempotent : ~q~n", [Nom]), fail ) )).

:- end_tests(normaliser_nom_documente).

% -------------------------------------------------------------------------------------------------------------------
% Les cas que la documentation ne tranche pas : CARACTÉRISATION du comportement de HEAD.
% -------------------------------------------------------------------------------------------------------------------
:- begin_tests(normaliser_nom_caracterisation).

% CARACTÉRISATION. Les apostrophes typographiques ne sont pas ramenées à l'apostrophe droite : « d'Alcantara » (U+0027)
% et « d’Alcantara » (U+2019, celle que produisent les traitements de texte) donnent deux clés. Le lecteur et l'index
% des noms propres se rejoignent donc ou non selon la typographie de la source.
% QUESTION : faut-il unifier ' ’ ʼ ` ? (Aujourd'hui non ; un nom écrit avec ’ n'est pas retrouvé.)
test(apostrophe_typographique_gardee) :-
    nn('Pierre d’Alcantara', K), K == 'PIERRE D’ALCANTARA'.
test(apostrophe_typographique_distincte_de_l_apostrophe_droite, [fail]) :-
    nn('Pierre d’Alcantara', K), nn('Pierre d\'Alcantara', K).
test(autres_apostrophes_gardees) :-
    nn('dʼA', 'DʼA'), nn('d`A', 'D`A').

% CARACTÉRISATION. « St », « Ste », « Saint » ne sont pas ramenés à une forme commune ; le point d'« St. » reste.
% QUESTION : « St Pierre », « St. Pierre » et « Saint Pierre » sont-ils un seul nom (alias) ou trois ? Le T1 de
% raisonnement.pl gère les titres de saint à part (titre_de_saint/1 sur la tête de l'entité), pas dans la clé.
test(st_ste_saint_gardes) :-
    nn('St Pierre', 'ST PIERRE'), nn('Ste Anne', 'STE ANNE'), nn('Sainte Anne', 'SAINTE ANNE'),
    nn('Saint Pierre', 'SAINT PIERRE'), nn('saint pierre', 'SAINT PIERRE'), nn('St. Pierre', 'ST. PIERRE').
test(st_et_saint_donnent_des_cles_distinctes, [fail]) :- nn('St Pierre', K), nn('Saint Pierre', K).
test(st_et_st_point_distincts, [fail]) :- nn('St Pierre', K), nn('St. Pierre', K).
test(ste_et_sainte_distincts, [fail]) :- nn('Ste Anne', K), nn('Sainte Anne', K).
test(autres_titres_gardes) :- nn('San Marco', 'SAN MARCO'), nn('Sankt Gallen', 'SANKT GALLEN').
test(le_titre_entre_parentheses_reste_dans_la_cle) :- nn('Pierre (St)', 'PIERRE (ST)'), nn('Pierre (roi)', 'PIERRE (ROI)').

% CARACTÉRISATION. Les tirets : ni le trait d'union, ni les tirets typographiques, ni le tiret bas ne sont ramenés à
% une forme commune ou à une espace.
% QUESTION : « Jean-Baptiste » et « Jean Baptiste » sont-ils le même nom ? (Aujourd'hui deux clés ; idem avec ‐ – —.)
test(trait_d_union_garde) :- nn('Jean-Baptiste', 'JEAN-BAPTISTE'), nn('Saint-Pierre', 'SAINT-PIERRE').
test(trait_d_union_et_espace_distincts, [fail]) :- nn('Jean-Baptiste', K), nn('Jean Baptiste', K).
test(tirets_typographiques_gardes) :-
    nn('Jean‐Baptiste', 'JEAN‐BAPTISTE'), nn('Jean–Baptiste', 'JEAN–BAPTISTE'),
    nn('Jean—Baptiste', 'JEAN—BAPTISTE').
test(trait_d_union_et_demi_cadratin_distincts, [fail]) :- nn('Jean-Baptiste', K), nn('Jean–Baptiste', K).
test(tiret_entoure_d_espaces_garde) :- nn('Jean - Baptiste', 'JEAN - BAPTISTE').
test(tiret_bas_garde) :- nn('Jean_Baptiste', 'JEAN_BAPTISTE').

% CARACTÉRISATION. La ponctuation est conservée telle quelle (aucune n'est retirée) : le point, la virgule, le
% point-virgule, les parenthèses ; une ponctuation finale change la clé.
% QUESTION : « Pierre » et « Pierre. » sont-ils le même nom ? (Aujourd'hui non.)
test(ponctuation_gardee) :-
    nn('Pierre.', 'PIERRE.'), nn('Pierre,', 'PIERRE,'), nn('D.A.V.I.D', 'D.A.V.I.D'),
    nn('Jean-Baptiste; l\'Évangéliste', 'JEAN-BAPTISTE; L\'EVANGELISTE').
test(ponctuation_finale_distingue, [fail]) :- nn('Pierre.', K), nn('Pierre', K).
test(parentheses_gardees) :- nn('Pierre (St)', K), K == 'PIERRE (ST)'.
test(parentheses_distinguent, [fail]) :- nn('Pierre (St)', K), nn('Pierre', K).
test(chiffres_gardes) :- nn('123', '123').
test(caracteres_de_largeur_nulle_gardes) :-          % U+200B et U+FEFF ne sont pas des espaces pour normalize_space
    nn('a​b', K1), atom_codes(K1, [0'A, 0x200b, 0'B]), nn('a﻿b', K2), atom_codes(K2, [0'A, 0xfeff, 0'B]).

% CARACTÉRISATION. Le repli des accents est une table de 14 minuscules (é è ê ë à â î ï ô ö ù û ü ç) et de 4
% capitales (É È À Ç), appliquée AVANT la mise en capitales. Les autres lettres accentuées ne sont pas repliées, et la
% mise en capitales d'une minuscule non repliée donne une capitale accentuée.
% QUESTION : un nom écrit en capitales (« JÉRÔME », fréquent dans les titres de l'iconographie) ne donne pas la même
% clé que le même nom en minuscules : « Ô », « Ê », « Î »… ne sont pas repliés. Faut-il les replier, en plus ?
test(capitale_non_repliee_o_circonflexe_donne_une_cle_differente_de_la_minuscule) :-
    nn('JÉRÔME', K1), K1 == 'JERÔME', nn('Jérôme', K2), K2 == 'JEROME', K1 \== K2.
test(capitales_non_repliees) :-
    forall(member(Nom, ['Ê', 'Â', 'Ô', 'Î', 'Ë', 'Ï', 'Ü', 'Ö', 'Ä', 'Ù', 'Û']),
           ( nn(Nom, K), K == Nom )).
test(minuscule_repliee_mais_pas_sa_capitale, [fail]) :- nn('ê', K), nn('Ê', K).
test(lettres_hors_de_la_table_passent_en_capitales_accentuees) :-
    nn('ä', 'Ä'), nn('á', 'Á'), nn('ã', 'Ã'), nn('ñ', 'Ñ'), nn('ø', 'Ø'), nn('ł', 'Ł'), nn('č', 'Č'), nn('ú', 'Ú').
test(trema_replie_sur_e_mais_pas_sur_a) :- nn('Zoë', 'ZOE'), nn('Märtha', 'MÄRTHA'), nn('Ñandú', 'ÑANDÚ').
test(y_trema) :- nn('ÿ', 'Ÿ').

% CARACTÉRISATION. Les ligatures et lettres spéciales ne sont pas décomposées : « Œdipe » (le nom du projet) et « Oedipe »
% sont deux clés ; « Ægidius » et « Aegidius » aussi ; « ß » reste ß (la mise en capitales de SWI-Prolog ne l'étend pas).
% QUESTION : faut-il décomposer Œ→OE, Æ→AE, ß→SS ? Les index de noms propres d'Iconclass (en ASCII) ne retrouvent pas
% « Œdipe » écrit avec la ligature.
test(ligatures_gardees) :-
    nn('Œdipe', 'ŒDIPE'), nn('œdipe', 'ŒDIPE'), nn('Ægidius', 'ÆGIDIUS'), nn('æ', 'Æ'), nn('Œ', 'Œ').
test(ligature_et_digraphe_distincts, [fail]) :- nn('Œdipe', K), nn('Oedipe', K).
test(eszett_garde) :- nn('ß', 'ß'), nn('straße', 'STRAßE').
test(ligature_de_presentation_gardee) :- nn('ﬁn', 'ﬁN').

% CARACTÉRISATION. La décomposition NFD n'est pas recomposée ni repliée : « é » écrit e + U+0301 donne E + U+0301, ce
% qui n'est ni « E » ni la forme précomposée repliée. Le même nom en NFC (« Jérôme ») et en NFD (« Jérôme ») a donc deux
% clés différentes. C'est le cas courant des textes venus de macOS ou d'extractions PDF.
% QUESTION : faut-il normaliser en NFD/NFC (et retirer les marques U+0300–U+036F) avant le repli ? (Aujourd'hui non.)
test(nfd_non_replie) :-
    nn('Jeróme', K), atom_codes(K, Cs), Cs == [0'J, 0'E, 0'R, 0'O, 0x301, 0'M, 0'E].
test(nfd_et_nfc_ont_des_cles_distinctes, [fail]) :- nn('Jeróme', K), nn('Jérome', K).
test(nfd_et_nfc_distincts_meme_pour_l_exemple_documente, [fail]) :- nn('Jérôme', K), nn('Jérôme', K).
test(nfd_isole) :- nn('é', K), atom_codes(K, [0'E, 0x301]).
test(cedille_nfd_non_replie) :- nn('ç', K), atom_codes(K, [0'C, 0x327]), nn('ç', 'C').

% CARACTÉRISATION. Deux noms différents que la clé confond : « Pâris » (le prince) et « Paris » (la ville) donnent
% PARIS. Le code le sait : nom_de_lieu/1 (sens_de_lieu) existe pour que T1 s'abstienne devant un nom qui a un sens de
% lieu ; la confusion est donc voulue en amont (index des noms de notations) mais reste une perte de distinction.
% QUESTION : jusqu'où la clé doit-elle confondre ? « Léon »/« Leon », « Pâris »/« Paris » : l'accent distingue parfois.
test(paris_et_paris_avec_accent_confondus) :- nn('Pâris', K), nn('Paris', K), K == 'PARIS'.
test(leon_avec_et_sans_accent_confondus) :- nn('Léon', K), nn('Leon', K).

% CARACTÉRISATION. Les alphabets non latins : la mise en capitales de SWI-Prolog s'applique, sans translittération ni
% repli des accents ; le sigma final devient Σ.
test(grec_et_cyrillique_en_capitales) :-
    nn('Σίσυφος', 'ΣΊΣΥΦΟΣ'), nn('Петр', 'ПЕТР'), nn('ς', 'Σ').
test(cjc_inchange) :- nn('日本', '日本').
test(i_sans_point) :- nn('ı', 'I'), nn('İstanbul', 'İSTANBUL').

% CARACTÉRISATION. Les accents tombent avant la mise en capitales ; une capitale accentuée de la table est repliée
% aussi : donc « É » (précomposé) → E mais « É » (NFD) non (voir plus haut).
test(replie_avant_la_mise_en_capitales_idempotent) :-
    nn('éé', K1), nn(K1, K2), K1 == 'EE', K2 == K1.

:- end_tests(normaliser_nom_caracterisation).

% ===================================================================================================================
% Propriétés générales de normaliser_nom/2 (générateur à graine)
% ===================================================================================================================
graine(S) :- ( getenv('OEDIPAMAAS_GRAINE_NOMS', A), atom_number(A, S0) -> S = S0 ; S = 20261128 ).
nombre_de_chaines(N) :- ( getenv('OEDIPAMAAS_NOMS_CHAINES', A), atom_number(A, N0) -> N = N0 ; N = 600 ).

% tout l'alphabet du problème : ASCII, accents repliés et non repliés, NFD, ligatures, espaces, apostrophes, tirets, points
pool_large([0'a, 0'b, 0'e, 0'i, 0'o, 0'p, 0'r, 0's, 0'z, 0'A, 0'E, 0'J, 0'P, 0'S, 0'T, 0'1,
            0'é, 0'è, 0'ê, 0'ë, 0'à, 0'â, 0'î, 0'ï, 0'ô, 0'ö, 0'ù, 0'û, 0'ü, 0'ç, 0'ä, 0'ñ, 0'ø, 0'ß,
            0'É, 0'È, 0'À, 0'Ç, 0'Ê, 0'Ô, 0'Ö, 0'Ÿ, 0'Œ, 0'œ, 0'Æ, 0'ÿ, 0'ǆ, 0'ﬁ, 0x130, 0x131, 0x3c3, 0x3c2, 0x1e9e,
            0x301, 0x308, 0x327,
            32, 32, 32, 9, 0x00a0, 0x2009, 0x3000, 0x200b,
            0'\', 0x2019, 0'`, 0'-, 0x2013, 0'_, 0'., 0',, 0'(, 0')]).
% le sous-ensemble où la casse est sans effet sur la clé (repliement documenté) : ASCII et É È À Ç / é è à ç
pool_replie([0'a, 0'b, 0'e, 0'i, 0'o, 0'p, 0'r, 0's, 0'z, 0'A, 0'J, 0'P, 0'é, 0'è, 0'à, 0'ç, 0'É, 0'È, 0'À, 0'Ç,
             32, 32, 9, 0x00a0, 0'-, 0'\']).
espaces_possibles([32, 9, 0x00a0, 0x2009, 0x3000, 0'\n]).

chaine_au_hasard(Pool, Cs) :- random_between(0, 14, L), length(Cs, L), maplist(code_au_hasard(Pool), Cs).
code_au_hasard(Pool, C) :- random_member(C, Pool).

pour_chaque_chaine(Pool, Prop) :-
    graine(S), nombre_de_chaines(N), set_random(seed(S)),
    forall(between(1, N, _),
           ( chaine_au_hasard(Pool, Cs), atom_codes(A, Cs),
             (   call(Prop, A) -> true
             ;   format(user_error, "propriété violée (graine ~w) sur ~q~n", [S, A]), fail ))).

% prédicats des propriétés (hors de l'unité de test, pour être appelés par pour_chaque_chaine/2)
idempotent(A) :- nn(A, K1), nn(K1, K2), K1 == K2.
forme_correcte(A) :-
    nn(A, K), atom(K), atom_codes(K, Cs),
    \+ append([32|_], _, Cs), \+ append(_, [32], Cs), \+ append(_, [32, 32|_], Cs),
    \+ ( member(C, Cs), memberchk(C, [0'\t, 0'\n, 0x00a0, 0x2009, 0x3000]) ).
espaces_indifferent(A) :-
    nn(A, K), atomic_list_concat(Ms, ' ', A),
    espaces_possibles(Es), random_member(E1, Es), random_member(E2, Es),
    atom_codes(S1, [E1, E2]), atomic_list_concat(Ms, S1, B),
    atom_concat(S1, B, B1), atom_concat(B1, S1, B2),
    nn(B2, K2), K2 == K.
casse_indifferente(A) :-
    nn(A, K), downcase_atom(A, B), upcase_atom(A, C),
    nn(B, KB), nn(C, KC), K == KB, K == KC.

:- begin_tests(normaliser_nom_general).

% idempotence : normaliser(normaliser(X)) = normaliser(X)
test(idempotence) :- pool_large(P), pour_chaque_chaine(P, user:idempotent).

% la clé est un atome, sans espace de bordure ni espace double ni espace autre que U+0020 parmi les espaces usuels
test(forme_de_la_cle) :- pool_large(P), pour_chaque_chaine(P, user:forme_correcte).

% l'ajout d'espaces (de toute sorte) entre deux mots ou aux bords ne change pas la clé
test(espaces_indifferents) :- pool_replie(P), pour_chaque_chaine(P, user:espaces_indifferent).

% la casse est sans effet sur la clé (pour les lettres que le repli traite : voir test des capitales Ô, Ê… plus haut)
test(casse_indifferente_sur_les_lettres_repliees) :- pool_replie(P), pour_chaque_chaine(P, user:casse_indifferente).

% propriété négative : la clé conserve la longueur des mots (deux noms de mots différents n'ont pas la même clé)
test(clef_distingue_deux_lettres_ascii) :-
    graine(S), set_random(seed(S)),
    forall(between(1, 200, _),
           ( random_between(0'a, 0'z, X), random_between(1, 25, D), Y is 0'a + (X - 0'a + D) mod 26,
             atom_codes(A, [X]), atom_codes(B, [Y]), nn(A, KA), nn(B, KB),
             (   KA \== KB -> true ; format(user_error, "confusion (graine ~w) : ~q ~q~n", [S, A, B]), fail ) )).

:- end_tests(normaliser_nom_general).

% ===================================================================================================================
% tete_mot_cle/2
% ===================================================================================================================

:- begin_tests(tete_mot_cle).

% documenté (commentaire de preparer/0 et de raisonnement.pl) : « Pierre (St) », « Psammétique (roi) »
test(mot_cle_a_role, [true(N == 'Pierre')]) :- tete('Pierre (St)', N).
test(mot_cle_a_role_roi, [true(N == 'Psammétique')]) :- tete('Psammétique (roi)', N).
test(tete_garde_ses_accents_et_sa_casse, [true(N == 'Psammétique')]) :- tete('Psammétique (roi)', N).
test(mot_cle_sans_role_est_sa_propre_tete, [true(N == 'Égypte')]) :- tete('Égypte', N).
test(determinisme, [true(Ns == ['Pierre'])]) :- findall(N, tete('Pierre (St)', N), Ns).
test(negatif_la_tete_n_est_pas_le_mot_entier, [fail]) :- tete('Pierre (St)', 'Pierre (St)').
test(negatif_le_role_n_est_pas_la_tete, [fail]) :- tete('Pierre (St)', 'St').
test(sortie_liee_juste) :- tete('Pierre (St)', 'Pierre').

% CARACTÉRISATION des cas limites (le code coupe à la PREMIÈRE occurrence de « espace + parenthèse ouvrante »)
test(premiere_parenthese_seulement, [true(N == 'Jean')]) :- tete('Jean (St) (apôtre)', N).
test(role_non_ferme_coupe_quand_meme, [true(N == 'Pierre')]) :- tete('Pierre (St', N).
test(role_vide_ou_espace, [true(N == 'Pierre')]) :- tete('Pierre ( )', N).
test(texte_apres_la_parenthese_ignore, [true(N == 'Pierre')]) :- tete('Pierre (St) ', N).
test(plusieurs_mots_dans_le_role, [true(N == 'Saint Pierre')]) :- tete('Saint Pierre (apostle, St)', N).
test(parenthese_collee_ne_coupe_pas, [true(N == 'Pierre(St)')]) :- tete('Pierre(St)', N).
test(parenthese_en_tete_sans_espace_ne_coupe_pas, [true(N == '(St)')]) :- tete('(St)', N).
test(parenthese_en_tete_apres_espace_donne_vide, [true(N == '')]) :- tete(' (St)', N).
test(mot_vide, [true(N == '')]) :- tete('', N).
test(parenthese_ouvrante_finale_coupe, [true(N == 'A')]) :- tete('A (', N).
test(espace_insecable_avant_la_parenthese_ne_coupe_pas, [true(N == 'Pierre (St)')]) :- tete('Pierre (St)', N).

% CARACTÉRISATION. La tête n'est pas nettoyée : une espace de trop avant la parenthèse reste dans la tête, et la tête
% n'est pas normalisée (c'est normaliser_nom qui s'en charge à l'appel suivant, dans preparer/0).
% QUESTION : « A  (B) » donne « A␣ » (avec son espace) ; sans conséquence tant que normaliser_nom suit, mais
% tete_mot_cle seul n'est pas propre.
test(espace_double_laisse_une_espace_en_queue, [true(N == 'Pierre ')]) :- tete('Pierre  (St)', N).
test(la_tete_se_normalise_ensuite, [true(K == 'PIERRE')]) :- tete('Pierre  (St)', N), nn(N, K).
test(chaine_acceptee_resultat_atome) :- tete("Pierre (St)", N), N == 'Pierre', atom(N).
test(non_instancie_est_une_erreur, [throws(error(instantiation_error, _))]) :- tete(_, _).
test(terme_compose_est_une_erreur, [throws(error(type_error(_, _), _))]) :- tete(f(x), _).

:- end_tests(tete_mot_cle).

% ===================================================================================================================
% sens_de_lieu/1 : sur de petites facts WordNet écrites ici (ins/2 : instance → classe ; hyp/2 : sorte → hyperonyme)
% ===================================================================================================================
% 100027167 est le synset « location » de WordNet 3.0.

lexique_de_lieux :-
    abolish_all_tables,
    retractall(wordnet:ins(_, _)), retractall(wordnet:hyp(_, _)),
    forall(member(F, [ ins(1, 2),                       % 1 instance de 2
                       hyp(2, 3), hyp(3, 100027167),    % 2 sorte de 3, 3 sorte de « location »
                       hyp(4, 100027167),               % 4 sorte directe de « location »
                       ins(5, 4),                       % 5 instance d'une sorte de lieu
                       hyp(10, 11), hyp(11, 12),        % une autre branche : 12 n'est pas un lieu
                       ins(13, 10),
                       hyp(20, 21), hyp(21, 20),        % un cycle hors des lieux
                       hyp(30, 31), hyp(31, 30), hyp(31, 4),      % un cycle qui rejoint les lieux
                       hyp(100027167, 99),              % « location » a elle-même un hyperonyme
                       hyp(40, 41), ins(40, 4)          % 40 : la première voie échoue, la seconde réussit
                     ]),
           ( F =.. [N, A, B], H =.. [N, A, B], assertz(wordnet:H) )).

:- begin_tests(sens_de_lieu, [setup(lexique_de_lieux), cleanup(( retractall(wordnet:ins(_, _)), retractall(wordnet:hyp(_, _)), abolish_all_tables )) ]).

% documenté : « une instance ou une sorte de location »
test(la_racine_location_est_un_lieu) :- raisonnement:sens_de_lieu(100027167).
test(une_sorte_directe) :- raisonnement:sens_de_lieu(4).
test(une_sorte_de_sorte) :- raisonnement:sens_de_lieu(3), raisonnement:sens_de_lieu(2).
test(une_instance_d_une_sorte_de_lieu) :- raisonnement:sens_de_lieu(1), raisonnement:sens_de_lieu(5).
test(determinisme, [true(N == 1)]) :- findall(x, raisonnement:sens_de_lieu(1), Xs), length(Xs, N).
test(negatif_une_autre_branche, [fail]) :- raisonnement:sens_de_lieu(12).
test(negatif_une_sorte_d_autre_chose, [fail]) :- raisonnement:sens_de_lieu(11).
test(negatif_une_instance_d_autre_chose, [fail]) :- raisonnement:sens_de_lieu(13).
test(negatif_le_synset_inconnu, [fail]) :- raisonnement:sens_de_lieu(999999999).

% cas limites révélés par le code
% CARACTÉRISATION. Le sens suit hyp/2 vers le HAUT seulement : l'hyperonyme du lieu n'est pas un lieu.
test(le_hyperonyme_de_location_n_est_pas_un_lieu, [fail]) :- raisonnement:sens_de_lieu(99).
% CARACTÉRISATION. La racine est un cas de base avec coupure : elle est vraie même si elle a des hyperonymes.
test(la_racine_est_vraie_malgre_son_hyperonyme) :- raisonnement:sens_de_lieu(100027167).
% un cycle de hyp/2 ne fait pas boucler (la clause est tabulée) et ne donne pas un lieu s'il ne rejoint pas la racine
test(cycle_hors_des_lieux_termine_et_echoue, [fail]) :- raisonnement:sens_de_lieu(20).
test(cycle_qui_rejoint_les_lieux_reussit) :- raisonnement:sens_de_lieu(30), raisonnement:sens_de_lieu(31).
% plusieurs voies : une seule suffit ; la première qui échoue n'empêche pas la suivante
test(une_voie_suffit) :- raisonnement:sens_de_lieu(40).

% CARACTÉRISATION. Les arguments qui ne sont pas des numéros de synset échouent simplement (pas d'erreur de type).
test(atome_non_synset_echoue, [fail]) :- raisonnement:sens_de_lieu(location).
test(numero_en_atome_echoue, [fail]) :- raisonnement:sens_de_lieu('100027167').
test(numero_en_chaine_echoue, [fail]) :- raisonnement:sens_de_lieu("100027167").
test(flottant_echoue, [fail]) :- raisonnement:sens_de_lieu(1.0).
% CARACTÉRISATION. Non instancié : réussit avec la racine (coupure de la première clause) sans énumérer les lieux.
% QUESTION : sens_de_lieu(-S) n'énumère pas les lieux ; il n'est utilisé qu'avec S lié (sujets.pl, nom_de_lieu) ; à
% laisser non spécifié ou à rendre une erreur d'instanciation ?
test(non_instancie_donne_la_racine_seulement, [true(L == [100027167])]) :- findall(S, raisonnement:sens_de_lieu(S), L).

% la table dépend des facts : après un changement de wordnet:hyp/2 et abolish_all_tables/0, la réponse suit
test(la_reponse_suit_les_facts, [cleanup(lexique_de_lieux)]) :-
    \+ raisonnement:sens_de_lieu(12),
    assertz(wordnet:hyp(12, 4)), abolish_all_tables,
    raisonnement:sens_de_lieu(12).

:- end_tests(sens_de_lieu).

% ===================================================================================================================
% ÉTAPE 1 de docs/INTEGRATION_NOYAU.md : le module neutre noms_propres, et la chaîne de chargement du noyau.
% Ces tests ÉCHOUENT avant l'étape 1 (c'est voulu : ils décrivent la cible) et passent après.
% ===================================================================================================================

% charge un module dans un processus neuf et dit si le module raisonnement est présent ensuite
charge_et_regarde(Chemin, Etat) :-
    dossier_des_tests(D), current_prolog_flag(executable, Swipl),
    format(atom(But), "( catch(use_module('~w/../../oedipamaas/socle/~w'), _, halt(2)), ( current_module(raisonnement) -> halt(3) ; halt(0) ) )", [D, Chemin]),
    setup_call_cleanup(
        process_create(Swipl, ['-g', But, '-t', 'halt(4)'], [ stdout(pipe(O)), stderr(pipe(E)), process(Pid), cwd(D),
                                                              environment(['LANG'='C.UTF-8']) ]),
        ( read_string(O, _, _), read_string(E, _, _), process_wait(Pid, exit(Etat)) ),
        ( close(O), close(E) )).

:- begin_tests(etape1).

% témoin (passe avant et après) : charger raisonnement charge bien raisonnement ; le détecteur n'est donc pas vide
test(temoin_charger_raisonnement_charge_raisonnement) :- charge_et_regarde(raisonnement, Etat), Etat == 3.
% ÉTAPE 1 : charger codage.pl ne charge pas raisonnement
test(etape1_codage_ne_charge_pas_raisonnement) :- charge_et_regarde(codage, Etat), Etat == 0.
% ÉTAPE 1 : la chaîne de K (les connaissances partagées) et du noyau ne charge pas raisonnement. Avant l'étape 1,
% satisfaction, verificateur, inclusion et normalisation ne le chargent déjà pas : ces quatre tests sont des gardes
% de non-régression et passent avant comme après ; codage et connaissances_commun, eux, échouent avant.
test(etape1_connaissances_commun_ne_charge_pas_raisonnement) :- charge_et_regarde(connaissances_commun, Etat), Etat == 0.
test(etape1_satisfaction_ne_charge_pas_raisonnement) :- charge_et_regarde(satisfaction, Etat), Etat == 0.
test(etape1_verificateur_ne_charge_pas_raisonnement) :- charge_et_regarde(verificateur, Etat), Etat == 0.
test(etape1_inclusion_ne_charge_pas_raisonnement) :- charge_et_regarde(inclusion, Etat), Etat == 0.
test(etape1_normalisation_ne_charge_pas_raisonnement) :- charge_et_regarde(normalisation, Etat), Etat == 0.
% ÉTAPE 1 : le module neutre lui-même ne dépend pas de raisonnement (échoue tant que le fichier n'existe pas)
test(etape1_le_module_noms_propres_ne_charge_pas_raisonnement) :- charge_et_regarde(noms_propres, Etat), Etat == 0.

% ÉTAPE 1 : les trois prédicats vivent dans noms_propres et raisonnement les importe
test(etape1_normaliser_nom_vient_de_noms_propres) :- vient_de(normaliser_nom(_, _), noms_propres).
test(etape1_tete_mot_cle_vient_de_noms_propres) :- vient_de(tete_mot_cle(_, _), noms_propres).
test(etape1_sens_de_lieu_vient_de_noms_propres) :- vient_de(sens_de_lieu(_), noms_propres).
test(etape1_noms_propres_les_exporte) :-
    forall(member(PI, [normaliser_nom/2, tete_mot_cle/2, sens_de_lieu/1]),
           ( noms_propres_charge, module_property(noms_propres, exports(Es)), memberchk(PI, Es) )).
% même comportement par les deux modules
test(etape1_memes_reponses_par_les_deux_modules) :-
    noms_propres_charge,
    forall(member(N, ['Jérôme', 'Pierre   d\'Alcantara', 'Œdipe', 'Jeróme', '']),
           ( noms_propres:normaliser_nom(N, K1), raisonnement:normaliser_nom(N, K2), K1 == K2 )),
    noms_propres:tete_mot_cle('Pierre (St)', 'Pierre').

noms_propres_charge :- ( current_module(noms_propres) -> true ; use_module('../../oedipamaas/socle/noms_propres') ).
vient_de(Tete, Module) :-
    predicate_property(raisonnement:Tete, imported_from(M)), M == Module.

:- end_tests(etape1).
