/*  Les noms propres, module neutre : ce que le lecteur, K, le noyau et l'ancien raisonneur (raisonnement.pl) lisent
    en commun, sans qu'aucun ne dépende de l'autre.

    normaliser_nom(+Nom, -K)  un nom normalisé : capitales sans accents, espaces simples (« Jérôme » → JEROME)
    tete_mot_cle(+Mot, -Nom)  le nom d'un mot clé de la forme « Nom (rôle) » : « Pierre (St) » → « Pierre »
    sens_de_lieu(+Synset)     le sens WordNet est une instance ou une sorte de « location » (synset 100027167)

    Ces trois prédicats viennent de raisonnement.pl, déplacés sans changement (docs/INTEGRATION_NOYAU.md, § 2, étape 1).
    Ils ne lisent aucun fait dynamique ; seul sens_de_lieu/1 lit WordNet (wordnet:ins/2, wordnet:hyp/2), chargé par la
    base compilée.
*/
:- module(noms_propres, [ normaliser_nom/2,   % +Nom, -NomNormalisé
                          tete_mot_cle/2,     % +MotCle, -Nom
                          sens_de_lieu/1      % +Synset (tabulé)
                        ]).
:- encoding(utf8).

tete_mot_cle(Mot, Nom) :- ( sub_atom(Mot, B, _, _, ' (') -> sub_atom(Mot, 0, B, _, Nom) ; Nom = Mot ).

% un nom normalisé : capitales sans accents, espaces simples (« Jérôme » → JEROME)
normaliser_nom(Nom, K) :-
    atom_codes(Nom, Cs0), maplist(sans_accent, Cs0, Cs1), atom_codes(A, Cs1),
    upcase_atom(A, A1), normalize_space(atom(K), A1).

sans_accent(C0, C) :- ( accent(C0, C1) -> C = C1 ; C = C0 ).
accent(0'é, 0'e). accent(0'è, 0'e). accent(0'ê, 0'e). accent(0'ë, 0'e). accent(0'à, 0'a). accent(0'â, 0'a).
accent(0'î, 0'i). accent(0'ï, 0'i). accent(0'ô, 0'o). accent(0'ö, 0'o). accent(0'ù, 0'u). accent(0'û, 0'u).
accent(0'ü, 0'u). accent(0'ç, 0'c). accent(0'É, 0'E). accent(0'È, 0'E). accent(0'À, 0'A). accent(0'Ç, 0'C).

:- table sens_de_lieu/1.
sens_de_lieu(100027167) :- !.
sens_de_lieu(S) :- ( wordnet:ins(S, P) ; wordnet:hyp(S, P) ), sens_de_lieu(P), !.
