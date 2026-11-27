/*  Un module de connaissances écrit à la main pour les tests du noyau (docs/NOYAU.md, § 2) : chaque mot désigne le
    type de même nom, et une petite hiérarchie. Aucune ressource externe : les tests du noyau ne dépendent d'aucune
    donnée. */
:- module(connaissances_essai, [ sens/3, sous/2, inclus/2, cle_de_nom/2, alias/2, distincts_documentes/3, version/1 ]).
:- encoding(utf8).
:- discontiguous sens/3, sous/2.

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
sous(1001, lionne).               % le concept 1001 se lexicalise en « lionne » (D30 : seul sens conceptuel du mot)
sens(n, pomme, 2001).             % un mot polysémique (D30) : un fruit, ou une pomme d'arrosoir
sens(n, pomme, 2002).
sous(2001, fruit). sous(2002, objet). sous(fruit, vegetal).
sous(2001, pomme). sous(2002, pomme).   % leur lexicalisation
sens(n, poire, 2101).             % un autre mot polysémique (lot 4) : un fruit, ou une forme (sans objet)
sens(n, poire, 2102).
sous(2101, fruit). sous(2101, poire). sous(2102, forme). sous(2102, poire).
sens(n, lyre, 2201).              % trois sens (lot 4) : un instrument ; l'instrument qui est aussi une constellation ;
sens(n, lyre, 2202).              % une constellation
sens(n, lyre, 2203).
sens(n, lyre_celeste, 2202).      % un mot qui n'a que le sens du milieu
sous(2201, instrument). sous(2202, instrument). sous(2202, constellation). sous(2203, constellation).
sous(2201, lyre). sous(2202, lyre). sous(2203, lyre). sous(2202, lyre_celeste).
sous(fauve, felin).               % un pas qui n'est pas une inclusion (comme une lexicalisation)
sous(cycle_a, cycle_b).          % un cycle, comme dans la hiérarchie des verbes de WordNet
sous(cycle_b, cycle_a).

% chaque pas de hiérarchie est une inclusion sémantique, sauf fauve → félin
inclus(A, B) :- sous(A, B), A \== fauve, \+ ( integer(A), memberchk(B, [pomme, poire, lyre, lyre_celeste]) ).

cle_de_nom(Nom, C) :- upcase_atom(Nom, C).

distincts_documentes('DAVID', 'GOLIATH', 'source de test').

alias('HIERONYMUS', 'JEROME').
alias('JEROME', 'GIROLAMO').           % une chaîne : le noyau ferme l'alias
