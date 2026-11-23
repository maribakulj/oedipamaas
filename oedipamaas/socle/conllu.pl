/*  Lecture du CoNLL-U (cahier des charges, § 6.1) : la seule frontière entre l'analyseur syntaxique et le moteur.

    conllu_phrases(+Texte, -Phrases) : Texte est la sortie d'un analyseur au format CoNLL-U (UDPipe 1 avec
    --tokenizer=ranges, ou tout autre analyseur qui écrit TokenRange=Debut:Fin dans la colonne MISC) ; Phrases est la
    liste des phrases, chacune phrase(Mots), chaque mot
        mot(Id, Forme, Lemme, Categorie, Traits, Tete, Relation, Debut, Fin)
    Id et Tete entiers (0 : racine) ; Categorie et Relation en atomes (« NOUN », « nsubj:pass ») ; Traits une liste
    Nom=Valeur (« Number=Sing ») ; Debut et Fin les positions en caractères dans le texte source (-1 si l'analyseur ne
    les donne pas). Les mots composés (lignes « 1-2 ») et les nœuds vides (« 1.1 ») sont ignorés : seuls les mots
    syntaxiques comptent ; un mot issu d'une contraction (« du » → « de » + « le ») reçoit les positions de son jeton.
*/
:- module(conllu, [ conllu_phrases/2   % +Texte, -Phrases
                  ]).
:- encoding(utf8).

conllu_phrases(Texte, Phrases) :-
    split_string(Texte, "\n", "\r", Lignes),
    phrases(Lignes, none, [], [], Phrases).

% phrases(+Lignes, +Etendue, +MotsCourants, +PhrasesAcc, -Phrases) ; Etendue : la dernière ligne de mot composé
% (Debut-Fin des identifiants, avec ses positions), pour donner ses positions aux mots qu'elle couvre
phrases([], _, Mots, Acc, Phrases) :-
    fin_phrase(Mots, Acc, Acc1),
    reverse(Acc1, Phrases).
phrases([L|Ls], Et, Mots, Acc, Phrases) :-
    (   L == ""
    ->  fin_phrase(Mots, Acc, Acc1),
        phrases(Ls, none, [], Acc1, Phrases)
    ;   sub_string(L, 0, 1, _, "#")
    ->  phrases(Ls, Et, Mots, Acc, Phrases)
    ;   split_string(L, "\t", "", Champs),
        length(Champs, 10)
    ->  Champs = [SId|_],
        (   sub_string(SId, _, _, _, "-")
        ->  etendue(Champs, Et1),
            phrases(Ls, Et1, Mots, Acc, Phrases)
        ;   sub_string(SId, _, _, _, ".")
        ->  phrases(Ls, Et, Mots, Acc, Phrases)
        ;   mot(Champs, Et, M),
            phrases(Ls, Et, [M|Mots], Acc, Phrases)
        )
    ;   phrases(Ls, Et, Mots, Acc, Phrases)                 % ligne mal formée : ignorée
    ).

fin_phrase([], Acc, Acc) :- !.
fin_phrase(Mots, Acc, [phrase(Ms)|Acc]) :- reverse(Mots, Ms).

etendue([SId, _, _, _, _, _, _, _, _, Misc], et(A, B, D, F)) :-
    split_string(SId, "-", "", [SA, SB]),
    number_string(A, SA), number_string(B, SB),
    positions(Misc, D, F).

mot([SId, Forme, Lemme, Cat, _, Traits, STete, Rel, _, Misc], Et,
    mot(Id, AForme, ALemme, ACat, LTraits, Tete, ARel, D, F)) :-
    number_string(Id, SId),
    atom_string(AForme, Forme), atom_string(ALemme, Lemme), atom_string(ACat, Cat), atom_string(ARel, Rel),
    ( number_string(Tete, STete) -> true ; Tete = -1 ),
    traits(Traits, LTraits),
    (   Et = et(A, B, D0, F0), Id >= A, Id =< B
    ->  D = D0, F = F0
    ;   positions(Misc, D, F)
    ).

traits("_", []) :- !.
traits(S, Ts) :-
    split_string(S, "|", "", Ps),
    findall(N=V, ( member(P, Ps), split_string(P, "=", "", [SN, SV]), atom_string(N, SN), atom_string(V, SV) ), Ts).

positions(Misc, D, F) :-
    split_string(Misc, "|", "", Ps),
    (   member(P, Ps), sub_string(P, 0, _, _, "TokenRange="), sub_string(P, 11, _, 0, R),
        split_string(R, ":", "", [SD, SF]), number_string(D, SD), number_string(F, SF)
    ->  true
    ;   D = -1, F = -1
    ).
