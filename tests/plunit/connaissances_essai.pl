/*  Un module de connaissances écrit à la main pour les tests du noyau (docs/NOYAU.md, § 2) : chaque mot désigne le
    type de même nom, et une petite hiérarchie. Aucune ressource externe : les tests du noyau ne dépendent d'aucune
    donnée. */
:- module(connaissances_essai, [ sens/3, sous/2, inclus/2, cle_de_nom/2, alias/2, distincts_documentes/3, version/1 ]).
:- encoding(utf8).

version('essai 1').

sens(_, W, W) :- atom(W).
sens(n, lionne, 1001).            % un identifiant de concept (comme un synset) ; 1001 est sous 1000

sous(lionne, lion).
sous(lion, felin).
sous(tigre, felin).
sous(felin, animal).
sous(mere, femme).
sous(femme, personne).
sous(homme, personne).
sous(saint, homme).
sous(nourrisson, enfant).
sous(enfant, personne).
sous(bercer, tenir).
sous(terrasser, attaquer).
sous(portrait_en_buste, portrait).
sous(1001, 1000).
sous(fauve, felin).               % un pas qui n'est pas une inclusion (comme une lexicalisation)
sous(cycle_a, cycle_b).          % un cycle, comme dans la hiérarchie des verbes de WordNet
sous(cycle_b, cycle_a).

% chaque pas de hiérarchie est une inclusion sémantique, sauf fauve → félin
inclus(A, B) :- sous(A, B), A \== fauve.

cle_de_nom(Nom, C) :- upcase_atom(Nom, C).

distincts_documentes('DAVID', 'GOLIATH', 'source de test').

alias('HIERONYMUS', 'JEROME').
alias('JEROME', 'GIROLAMO').           % une chaîne : le noyau ferme l'alias
