/*  Compare les requêtes compilées (requetes_iconclass.pl) aux requêtes de référence écrites à la main, par inclusion
    logique (docs/PLAN_V1.md, C3 et C6.2), avec le noyau lui-même.
        swipl outils/requetes/comparer.pl BASE COMPILEES.json REFERENCE.json SORTIE.json [sans_normalisation]

    L'inclusion est celle de oedipamaas/socle/inclusion.pl (docs/NOYAU.md, § 8) : graphe canonique de chaque cas
    (sélection et nom choisi dans chaque liste de noms), contraintes rendues par des assertions, statut `etablie`
    exigé ; hors du fragment, « indetermine ».
    Pour la condition suffisante :
      exacte          compilée ⊆ référence et référence ⊆ compilée
      trop_forte      compilée ⊆ référence seulement : sûre, mais manquera des cas
      trop_faible     référence ⊆ compilée seulement : dangereuse, elle établirait des codes que le libellé ne dit pas
      incomparable    ni l'une ni l'autre : chacune a un contre-exemple (dangereuse jusqu'à preuve du contraire)
      indetermine     l'inclusion n'est pas décidée par la méthode (hors du fragment, budget) : ni sûre ni dangereuse
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
    use_module(socle(normalisation), []), use_module(socle(inclusion), []),
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

% le verdict, par inclusion.pl (docs/NOYAU.md, § 8) : la compilée contre la référence
verdict(K, Qc, Qr, V) :-
    atom_concat(connaissances_, L, K),
    ( nb_getval(normaliser, oui) -> N = normalisation:enrichir(L) ; N = aucune ),
    inclusion:comparer(K, N, Qc, Qr, R),
    verdict_(R, V).
verdict_(equivalentes, exacte).
verdict_(incluse, trop_forte).
verdict_(contient, trop_faible).
verdict_(incomparables(_, _), incomparable).
verdict_(indetermine(_), indetermine).
