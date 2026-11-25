/*  Compare les requêtes compilées (requetes_iconclass.pl) aux requêtes de référence écrites à la main, par inclusion
    logique (docs/PLAN_V1.md, C3 et C6.2), avec le noyau lui-même.
        swipl outils/requetes/comparer.pl BASE COMPILEES.json REFERENCE.json SORTIE.json [sans_normalisation]

    Q1 implique Q2 (Q1 ⊆ Q2) si, pour chaque disjonction de Q1 mise en forme normale, le graphe canonique de ce cas
    (chaque variable devient un référent, chaque atome une assertion positive) satisfait Q2 : c'est le critère
    classique d'inclusion des requêtes conjonctives (Chandra et Merlin), étendu aux unions.
    Pour la condition suffisante :
      exacte          compilée ⊆ référence et référence ⊆ compilée
      trop_forte      compilée ⊆ référence seulement : sûre, mais manquera des cas
      trop_faible     référence ⊆ compilée seulement : dangereuse, elle établirait des codes que le libellé ne dit pas
      incomparable    ni l'une ni l'autre : elles disent des choses différentes (dangereuse jusqu'à preuve du contraire)
    Les correspondances de mots passent par connaissances_en / connaissances_fr (WordNet, WOLF).  */
:- initialization(main, main).
:- prolog_load_context(directory, D), atom_concat(D, '/../../oedipamaas/socle', S), asserta(user:file_search_path(socle, S)).
:- use_module(socle(oedipamaas)).
:- use_module(library(json)).

main :-
    current_prolog_flag(argv, [Base, Compilees, Reference, Sortie|_]),
    oedipamaas:charger_base(Base),
    atom_concat(Base, '/ressources.qlf', Res), load_files(Res, []),
    use_module(socle(satisfaction)), use_module(socle(connaissances_en), []), use_module(socle(connaissances_fr), []),
    use_module(socle(normalisation), []),
    ( current_prolog_flag(argv, [_, _, _, _, sans_normalisation|_]) -> nb_setval(normaliser, non) ; nb_setval(normaliser, oui) ),
    lire(Compilees, Cs), lire(Reference, Rs),
    findall(J, ( member(C, Cs), member(R, Rs), R.k =:= C.k, comparer(C, R, J) ), Js),
    setup_call_cleanup(open(Sortie, write, O, [encoding(utf8)]), json_write_dict(O, Js, [width(160)]), close(O)),
    length(Js, N), format("~d comparaisons~n", [N]).

lire(F, J) :- setup_call_cleanup(open(F, read, S, [encoding(utf8)]), json_read_dict(S, J), close(S)).

comparer(C, R, J) :-
    atom_string(L, C.langue), atom_concat(connaissances_, L, K),
    (   terme(C.suffisante, Qc), terme(R.get(suffisante, null), Qr)
    ->  verdict(K, Qc, Qr, V)
    ;   C.statut == "non_prise_en_charge" -> V = non_prise_en_charge
    ;   V = sans_reference
    ),
    J = _{k: C.k, notation: C.notation, langue: C.langue, type: C.type, statut: C.statut, famille: C.famille,
          verdict: V, compilee: C.suffisante, reference: R.get(suffisante, null)}.

terme(S, T) :- string(S), S \== "aucune", catch(term_string(T, S), _, fail), T = requete(_, _).

verdict(K, Qc, Qr, V) :-
    ( implique(K, Qc, Qr) -> A = oui ; A = non ),
    ( implique(K, Qr, Qc) -> B = oui ; B = non ),
    verdict_(A, B, V).
verdict_(oui, oui, exacte).
verdict_(oui, non, trop_forte).
verdict_(non, oui, trop_faible).
verdict_(non, non, incomparable).

% Q1 ⊆ Q2 : chaque cas de Q1 (forme normale disjonctive) satisfait Q2 sur son graphe canonique
implique(K, requete(_, F1), Q2) :-
    atom_concat(connaissances_, L, K),
    forall(cas(F1, Atomes), ( canonique(Atomes, G0), normaliser(L, G0, G),
                              catch(satisfaction:satisfaire(K, G, Q2, resultat(etablie, _, _)), _, fail) )).

% les deux formes d'une action (un verbe, un nom d'action) sont équivalentes : le graphe canonique les reçoit toutes les
% deux (normalisation.pl, C7.3), comme le graphe d'un texte
normaliser(L, G0, G) :- ( nb_getval(normaliser, oui) -> normalisation:enrichir(L, G0, G) ; G = G0 ).

cas(et(Fs), As) :- !, foldl([F, A0, A]>>( cas(F, Af), append(A0, Af, A) ), Fs, [], As).
cas(ou(Fs), As) :- !, member(F, Fs), cas(F, As).
cas(A, [A]).

% le graphe canonique : un référent par variable, une assertion positive par atome
canonique(As, G) :-
    foldl(canon, As, 1-[], _-G0), reverse(G0, G1),
    findall(Q, ( member(X, G1), id(X, I), qualif(I, Q) ), Qs0), append(Qs0, Qs),
    append(G1, Qs, G2), sort(G2, G).
canon(type(v(X), T), I-G, I1-[entite(X, T, p)|G]) :- I1 is I + 1.
canon(nom(v(X), [Kn|_]), I-G, I1-[nom(N, X, Kn, p), entite(X, nom_propre, p)|G]) :- format(atom(N), "n~w", [I]), I1 is I + 1.
canon(propriete(v(X), P), I-G, I1-[propriete(N, X, P, p)|G]) :- format(atom(N), "q~w", [I]), I1 is I + 1.
canon(evenement(v(X), P), I-G, I1-[evenement(X, P, p)|G]) :- I1 is I + 1.
canon(role(v(V), R, v(X)), I-G, I1-[role(V, R, X), entite(X, nom_propre, p)|G]) :- I1 is I + 1.
canon(relation(v(X), R, v(Y)), I-G, I1-[relation(N, X, R, Y, p)|G]) :- format(atom(N), "r~w", [I]), I1 is I + 1.
canon(genre(T), I-G, I1-[entite(N, T, p)|G]) :- format(atom(N), "genre__~w", [I]), I1 is I + 1.
canon(meme(v(X), v(Y)), I-G, I1-[coref(X, Y)|G]) :- I1 is I + 1.
canon(distincts(_, _), I-G, I-G).
canon(nombre(v(X), N), I-G, I1-[nombre(X, N)|G]) :- I1 is I + 1.

id(entite(I, _, _), I). id(nom(I, _, _, _), I). id(propriete(I, _, _, _), I). id(evenement(I, _, _), I).
id(relation(I, _, _, _, _), I).
qualif(I, [polarite(I, pos), modalite(I, affirme), portee(I, P), enonciateur(I, auteur)]) :-
    ( sub_atom(I, 0, _, _, genre__) -> P = oeuvre ; P = represente ).
