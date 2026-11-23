/*  Les faits d'une description (conception 1.0, § 4), écrits par faits_description.py ; remplacés à chaque image. */
:- module(description, [ mention/4, entite/5, attribut/2, relation/3, personne/4, sujet/4, alternative/2,
                         texte_transcrit/3, effacer/0 ]).

:- dynamic mention/4, entite/5, attribut/2, relation/3, personne/4, sujet/4, alternative/2, texte_transcrit/3.

effacer :-
    forall(member(P/A, [mention/4, entite/5, attribut/2, relation/3, personne/4, sujet/4, alternative/2,
                        texte_transcrit/3]),
           ( functor(T, P, A), retractall(T) )).
