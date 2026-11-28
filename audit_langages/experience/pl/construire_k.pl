/*  Version Prolog de la transformation (spec/SPEC.md) : construire, contrôler, compiler. SWI-Prolog 11, bibliothèques
    livrées avec lui (sgml, xpath, unicode, apply, lists, pairs), aucun paquet à installer.

      LANG=C.UTF-8 swipl construire_k.pl construire ECHANTILLON_DIR K.tsv
      LANG=C.UTF-8 swipl construire_k.pl controler  K.tsv WN30_IDS.txt        % violations ; code 1 s'il y en a
      LANG=C.UTF-8 swipl construire_k.pl compiler   K.tsv WN30_IDS.txt K_FAITS.pl
*/
:- module(construire_k, [construire/2, controler/2, violation/2, compiler/3, lire_pivot/1]).
:- encoding(utf8).
:- use_module(library(sgml)).
:- use_module(library(xpath)).
:- use_module(library(unicode)).
:- use_module(library(readutil)).
:- use_module(library(apply)).
:- use_module(library(lists)).
:- use_module(library(pairs)).
:- use_module(library(json)).

% ------------------------------------------------------------------ le modèle : quatre types de faits (dynamiques)
:- dynamic source/6, alignement/10, entree/11, vote/7, pivot/1.
%  source(Id, Ressource, Version, Sha256, CoucheLicence, Famille)
%  alignement(Id, DeRessource, DeVersion, DeId, VersRessource, VersVersion, VersId, Methode, Statut, Attestation)
%  entree(Id, Genre, Lemme, Synset, Source, Localisateur, Nature, Detail, Statut, Attestation, CoucheLicence)
%  vote(Id, Lemme, Synset, Rang, Familles, Entrees, Statut)

types([source-6, alignement-10, entree-11, vote-7]).
code_type("S", source).  code_type("A", alignement).  code_type("E", entree).  code_type("V", vote).
prefixe(n, 1).  prefixe(v, 2).  prefixe(a, 3).  prefixe(r, 4).

raz :- forall(( types(Ts), member(N-A, Ts), functor(T, N, A) ), retractall(T)).

% NFC, pliage de casse complet, NFC (utf8proc : library(unicode)) ; v1 de la spec disait « minuscules » : string_lower/2
% (correspondance simple) et str.lower() de Python (correspondance complète) divergeaient sur « İ » (U+0130)
cle_vote(Lemme, Cle) :- unicode_map(Lemme, K0, [casefold, compose, stable]), atom_string(K0, Cle).

% ------------------------------------------------------------------ lecture et écriture du format canonique
lire_k(Fichier) :-
    raz,
    read_file_to_string(Fichier, S, []),
    split_string(S, "\n", "", Lignes),
    forall(( member(L, Lignes), L \== "" ),
           (   split_string(L, "\t", "", [Code|Champs]),
               code_type(Code, Nom),
               Fait =.. [Nom|Champs],                  % un nombre de champs faux : erreur (aucun repli silencieux)
               assertz(Fait)
           )).

ecrire_k(Fichier) :-
    setup_call_cleanup(open(Fichier, write, Out, [encoding(utf8)]),
        forall(( code_type(Code, Nom), types(Ts), memberchk(Nom-A, Ts), functor(T, Nom, A),
                 findall(T, T, Faits0), sort(1, @=<, Faits0, Faits) ),   % tri sur l'identifiant (premier argument)
               forall(member(F, Faits), ecrire_ligne(Out, Code, F))),
        close(Out)).
ecrire_ligne(Out, Code, F) :-
    F =.. [_|Champs], atomic_list_concat([Code|Champs], '\t', L), format(Out, "~w~n", [L]).

lire_pivot(Fichier) :-
    retractall(pivot(_)),
    read_file_to_string(Fichier, S, []),
    split_string(S, "\n", " ", Ids),
    forall(( member(I, Ids), I \== "" ), assertz(pivot(I))).

% ------------------------------------------------------------------ construire
construire(Dossier, Sortie) :-
    raz,
    directory_file_path(Dossier, 'MANIFESTE.json', Man),
    setup_call_cleanup(open(Man, read, In, [encoding(utf8)]), json_read_dict(In, J), close(In)),
    E = J.entrees,
    VWolf = "OMW 1.4 (fra)", VWonef = "0.1 fscore (2013-07-03)", VWn = "3.0",
    assertz(source("src:wolf", "WOLF", VWolf, E.wolf_sha256, "CeCILL-C", "WOLF")),
    assertz(source("src:wonef-f", "WoNeF", VWonef, E.wonef_sha256, "CC-BY-SA", "WoNeF")),
    assertz(source("src:wn30", "WordNet", VWn, E.wordnet_sha256_noun_verb_adj_adv_concatenes, "WordNet-3.0", "pivot")),
    construire_wolf(Dossier, VWolf, VWn),
    construire_wonef(Dossier, VWonef, VWn),
    construire_votes,
    ecrire_k(Sortie).

aligner(Src, Ress, Ver, DeId, Sid, Meth, VWn) :-
    format(string(Id), "aln:~s:~s", [Src, Sid]),
    (   alignement(Id, _, _, _, _, _, _, _, _, _) -> true
    ;   assertz(alignement(Id, Ress, Ver, DeId, "WordNet", VWn, Sid, Meth, "non_attestee", ""))
    ).

construire_wolf(Dossier, VWolf, VWn) :-
    directory_file_path(Dossier, 'wolf.tab', F),
    read_file_to_string(F, S, []),
    split_string(S, "\n", "", Ls0), exclude(==(""), Ls0, Ls),
    forall(nth1(N, Ls, L),
           (   split_string(L, "\t", "", [Sid, "fra:lemma", Lemme]),
               aligner("src:wolf", "WOLF", VWolf, Sid, Sid, "identité du décalage OMW", VWn),
               format(string(Id), "lex:src:wolf:~s:~s", [Sid, Lemme]),
               format(string(Loc), "ligne ~d", [N]),
               assertz(entree(Id, "lexicalisation", Lemme, Sid, "src:wolf", Loc, "alignement_automatique", "wolf-omw",
                              "non_attestee", "", "CeCILL-C"))
           )).

construire_wonef(Dossier, VWonef, VWn) :-
    directory_file_path(Dossier, 'wonef.xml', F),
    load_xml(F, DOM, [space(preserve)]),
    forall(xpath(DOM, //'SYNSET', Syn),
           (   xpath(Syn, 'ID'(text), Ident0), atom_string(Ident0, Ident),
               split_string(Ident, "-", "", ["eng", "30", Dec, Pos0]),
               ( Pos0 == "b" -> Pos = "r" ; Pos = Pos0 ),
               format(string(Sid), "~s-~s", [Dec, Pos]),
               findall(Lemme-Note, litteral(Syn, Lemme, Note), Lits),
               (   Lits == [] -> true
               ;   aligner("src:wonef-f", "WoNeF", VWonef, Ident, Sid, "identifiant eng-30 de WoNeF ; b vers r", VWn),
                   forall(member(Lemme-Note, Lits),
                          (   format(string(Id), "lex:src:wonef-f:~s:~s", [Sid, Lemme]),
                              assertz(entree(Id, "lexicalisation", Lemme, Sid, "src:wonef-f", Ident,
                                             "alignement_automatique", Note, "non_attestee", "", "CC-BY-SA"))
                          ))
               )
           )).

litteral(Syn, Lemme, Note) :-
    xpath(Syn, //'LITERAL', Lit),
    xpath(Lit, /self(text), L0), atom_string(L0, Lemme), Lemme \== "_EMPTY_",
    (   xpath(Lit, /self(@lnote), N0) -> atom_string(N0, Note) ; Note = "sans_note" ).

% le vote classe, il n'atteste pas : un par couple (lemme normalisé, synset)
construire_votes :-
    findall((Cle-Sid)-Id, ( entree(Id, _, Lemme, Sid, _, _, _, _, _, _, _), cle_vote(Lemme, Cle) ), Paires0),
    keysort(Paires0, Paires),
    group_pairs_by_key(Paires, Groupes),
    forall(member((Cle-Sid)-Ids, Groupes),
           (   findall(F, ( member(I, Ids), entree(I, _, _, _, Src, _, _, _, _, _, _), source(Src, _, _, _, _, F) ), Fs0),
               sort(Fs0, Fs), length(Fs, Rang),
               atomic_list_concat(Fs, ',', Fam0), atom_string(Fam0, Familles),
               msort(Ids, IdsT), atomic_list_concat(IdsT, ',', Ent0), atom_string(Ent0, Entrees),
               format(string(Vid), "vote:~s:~s", [Sid, Cle]),
               format(string(RangS), "~d", [Rang]),
               assertz(vote(Vid, Cle, Sid, RangS, Familles, Entrees, "non_attestee"))
           )).

% ------------------------------------------------------------------ contrôler : les invariants, une règle chacun
violation('INV1_SOURCE', Id) :-
    entree(Id, _, _, _, S, _, _, _, _, _, _),
    \+ ( source(S, R, V, H, _, _), R \== "", V \== "", H \== "" ).
violation('INV2_ALIGN_VERSION', Id) :-
    alignement(Id, R1, V1, _, R2, V2, _, _, _, _),
    \+ ( R1 \== "", V1 \== "", R2 \== "", V2 \== "" ).
violation('INV3_PIVOT', Id) :-
    alignement(Id, _, _, _, R, V, Cible, _, _, _),
    \+ ( R == "WordNet", V == "3.0", pivot(Cible) ).
violation('INV4_VOTE_CLASSE', Id) :-
    vote(Id, _, _, _, _, _, S), S \== "non_attestee".
violation('INV5_ATTESTATION', Id) :-
    (   entree(Id, _, _, _, _, _, _, _, S, A, _) ; alignement(Id, _, _, _, _, _, _, _, S, A) ),
    \+ (  S == "attestee", A \== "" ; S == "non_attestee", A == "" ).
violation('INV6_UNICITE', Id) :-
    types(Ts), member(N-Ar, Ts), functor(T, N, Ar), arg(1, T, Id), call(T),
    functor(T2, N, Ar), arg(1, T2, Id), aggregate_all(count, T2, C), C > 1.
violation('INV7_ENTREE_ALIGNEE', Id) :-
    entree(Id, _, _, Sid, S, _, _, _, _, _, _),
    \+ ( source(S, R, _, _, _, _), alignement(_, R, _, _, _, _, Sid, _, _, _) ).
violation('INV8_VOTE', Id) :-
    vote(Id, Lemme, Sid, Rang, Familles, Entrees, _),
    split_string(Entrees, ",", "", Ids0), exclude(==(""), Ids0, Ids),
    \+ (   Ids \== [],
           forall(member(I, Ids), ( entree(I, _, L, Sid, _, _, _, _, _, _, _), cle_vote(L, Lemme) )),
           findall(F, ( member(I, Ids), entree(I, _, _, _, S, _, _, _, _, _, _), source(S, _, _, _, _, F) ), Fs0),
           sort(Fs0, Fs), length(Fs, N), atom_string(N, Rang), atomic_list_concat(Fs, ',', FamS), atom_string(FamS, Familles)
       ).
violation('INV9_LICENCE', Id) :-
    entree(Id, _, _, _, S, _, _, _, _, _, C), source(S, _, _, _, C2, _), C \== C2.

controler(K, Violations) :-
    lire_k(K),
    findall(Code-Id, violation(Code, Id), Vs0), sort(Vs0, Violations).

% ------------------------------------------------------------------ compiler vers des faits Prolog
compiler(K, Pivot, Sortie) :-
    lire_pivot(Pivot), controler(K, Vs),
    (   Vs == [] -> true
    ;   Vs = [V|_], length(Vs, N), throw(error(compilation_refusee(N, V), _)) ),
    setup_call_cleanup(open(Sortie, write, Out, [encoding(utf8)]), ecrire_faits(Out), close(Out)).

ecrire_faits(Out) :-
    format(Out, ":- module(k_federe, [k_source/6, k_sens/5, k_vote/4]).~n:- encoding(utf8).~n", []),
    findall(source(I, R, V, H, C, F), source(I, R, V, H, C, F), Ss0), sort(1, @=<, Ss0, Ss),
    forall(member(source(I, R, V, H, C, F), Ss), format(Out, "k_source(~q, ~q, ~q, ~q, ~q, ~q).~n", [I, R, V, H, C, F])),
    findall(entree(I, L, Sy, St), entree(I, _, L, Sy, _, _, _, _, St, _, _), Es0), sort(1, @=<, Es0, Es),
    forall(member(entree(I, L, Sy, St), Es),
           (   entier(Sy, T, Pos), atom_string(StA, St), atom_string(PosA, Pos),
               format(Out, "k_sens(~w, ~q, ~d, ~q, ~w).~n", [PosA, L, T, I, StA]) )),
    findall(vote(I, L, Sy, Rg, Fa), vote(I, L, Sy, Rg, Fa, _, _), Vs0), sort(1, @=<, Vs0, Vs),
    forall(member(vote(_, L, Sy, Rg, Fa), Vs),
           (   entier(Sy, T, _), split_string(Fa, ",", "", Fams),
               format(Out, "k_vote(~q, ~d, ~s, ~q).~n", [L, T, Rg, Fams]) )).

entier(Synset, Entier, Pos) :-
    split_string(Synset, "-", "", [Dec, Pos]), number_string(D, Dec),
    atom_string(PA, Pos), prefixe(PA, P), Entier is P * 100000000 + D.

% ------------------------------------------------------------------ ligne de commande
:- initialization(main, main).
main(Argv) :-
    catch(commande(Argv, Code), E, ( print_message(error, E), Code = 2 )),
    halt(Code).
commande([construire, D, Out], 0) :- construire(D, Out).
commande([controler, K, Pivot], Code) :-
    lire_pivot(Pivot), controler(K, Vs),
    forall(member(C-I, Vs), format("~w\t~w~n", [C, I])),
    ( Vs == [] -> Code = 0 ; Code = 1 ).
commande([compiler, K, Pivot, Out], 0) :- compiler(K, Pivot, Out).
