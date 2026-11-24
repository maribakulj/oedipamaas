/*  De bout en bout (cahier des charges, J1.6, J1.7) : texte → UDPipe → assertions → T1, T2, T6 → sortie, preuves
    vérifiées. Demande la base compilée (OEDIPAMAAS_BASE : dossier d'iconclass.qlf et wordnet.qlf) et UDPipe
    (OEDIPAMAAS_UDPIPE, OEDIPAMAAS_MODELES) ; sinon sauté. */
:- use_module('../../oedipamaas/socle/oedipamaas').
:- use_module('../../oedipamaas/socle/raisonnement').
:- use_module(library(plunit)).
:- use_module(library(json)).
:- use_module(library(yall)).
:- encoding(utf8).

configure :- getenv('OEDIPAMAAS_BASE', _), getenv('OEDIPAMAAS_UDPIPE', _), getenv('OEDIPAMAAS_MODELES', _).

docs([ _{id: "cartel_fr", texte: "Saint Jérôme dans son étude, avec un lion et un crâne.", langue: "fr", genre: "cartel"},
       _{id: "titre_fr", texte: "Saint Jérôme pénitent, sans son lion.", langue: "fr", genre: "titre"},
       _{id: "cartel_en", texte: "Saint Jerome in his study with a lion and a skull.", langue: "en", genre: "cartel"},
       _{id: "negation_en", texte: "Saint Jerome without his lion.", langue: "en", genre: "titre"},
       _{id: "modalite_en", texte: "The scene may represent the Annunciation.", langue: "en"},
       _{id: "alternative_en", texte: "Saint Peter or Saint Paul.", langue: "en"},
       _{id: "ambigu_fr", texte: "Saint Jean.", langue: "fr"},
       _{id: "paysage_fr", texte: "Un chien et un cheval dans un paysage.", langue: "fr"},
       _{id: "vide", texte: "", langue: "fr"},
       _{id: "ville_fr", texte: "Vue de Paris.", langue: "fr"},
       _{id: "lieu_fr", texte: "Saint Jean à Patmos.", langue: "fr"},
       _{id: "egypte_fr", texte: "La Fuite en Égypte.", langue: "fr"},
       _{id: "ordre_en", texte: "John.", langue: "en"} ]).

:- dynamic resultat/2.
preparer :-
    retractall(resultat(_, _)),
    getenv('OEDIPAMAAS_BASE', B), docs(Ds), oedipamaas:analyser_documents(B, Ds, Rs),
    forall(member(R, Rs), assertz(resultat(R.document, R))).

etablis_codes(Id, Cs) :- resultat(Id, R), findall(C, ( member(X, R.etablis), C = X.code ), Cs).
codes(Id, K, Cs) :- resultat(Id, R), get_dict(K, R, L), findall(C, ( member(X, L), C = X.code ), Cs).

:- begin_tests(bout_en_bout, [condition(configure), setup(preparer)]).

test(cartel_fr) :-
    etablis_codes("cartel_fr", Cs),
    memberchk('11H(JEROME)', Cs), memberchk('25F23(LION)', Cs).

test(titre_fr_negation) :-
    etablis_codes("titre_fr", Cs), memberchk('11H(JEROME)', Cs), \+ memberchk('25F23(LION)', Cs),
    codes("titre_fr", contredits, Co), memberchk('25F23(LION)', Co).

test(cartel_en) :-
    etablis_codes("cartel_en", Cs),
    memberchk('11H(JEROME)', Cs), memberchk('25F23(LION)', Cs), memberchk('31A211', Cs).

test(negation_en) :-
    etablis_codes("negation_en", Cs), \+ memberchk('25F23(LION)', Cs),
    codes("negation_en", contredits, Co), memberchk('25F23(LION)', Co).

% « may represent » : l'Annonciation n'est pas établie, elle reste candidate avec sa raison
test(modalite) :-
    etablis_codes("modalite_en", Cs), \+ ( member(C, Cs), sub_atom(C, 0, _, _, '73A') ),
    resultat("modalite_en", R), member(X, R.candidats), sub_atom(X.code, 0, _, _, '73A5'), !,
    sub_string(X.raison, 0, _, _, "modalite").

% deux hypothèses exclusives : ni Pierre ni Paul
test(alternative) :-
    etablis_codes("alternative_en", Cs), \+ memberchk('11H(PETER)', Cs), \+ memberchk('11H(PAUL)', Cs).

% « Saint Jean » : plusieurs saints Jean, aucun établi
test(ambigu) :-
    etablis_codes("ambigu_fr", Cs), \+ ( member(C, Cs), sub_atom(C, 0, _, _, '11H(JOHN') ),
    codes("ambigu_fr", candidats, Ca), memberchk('11H(JOHN)', Ca).

test(paysage) :- etablis_codes("paysage_fr", Cs), memberchk('25H', Cs), memberchk('34B11', Cs).

% T1 : seulement des personnes (D12 et corrections) ; un nom en position de lieu n'est pas une personne
test(ville) :- etablis_codes("ville_fr", Cs), \+ memberchk('95A(PARIS)', Cs).
test(lieu) :- etablis_codes("lieu_fr", Cs), \+ ( member(C, Cs), sub_atom(C, _, _, _, 'PATMOS') ).
test(mot_cle_thematique) :- etablis_codes("egypte_fr", Cs), \+ ( member(C, Cs), sub_atom(C, 0, _, _, '98B') ).
test(pas_un_ordre) :-
    codes("ordre_en", etablis, Et), codes("ordre_en", candidats, Ca), append(Et, Ca, Cs),
    \+ memberchk('46A1241(ST. JOHN)', Cs).

test(vide) :- resultat("vide", R), get_dict(erreur, R, _).

% chaque code établi se revérifie ; chaque prémisse cite le texte exact à ses positions
test(preuves) :-
    forall(( docs(Ds), member(D, Ds), resultat(D.id, R), get_dict(etablis, R, Et), member(C, Et) ),
           ( C.statut == etabli, C.preuve.premisses \== [],
             forall(member(P, C.preuve.premisses),
                    ( [Deb, Fin] = P.passage, L is Fin - Deb, sub_string(D.texte, Deb, L, _, T), T == P.texte )) )).

% une preuve falsifiée ne se vérifie pas
test(preuve_falsifiee) :-
    getenv('OEDIPAMAAS_BASE', _),
    T = "Saint Jerome with a lion.",
    udpipe:analyser(T, en, Ps), interpretation:interpreter(T, en, titre, Ps, Fs),
    raisonnement:coder(Fs, R), member(C, R.etablis), C.code == '25F23(LION)', !,
    raisonnement:verifier(Fs, C),
    [P|Ps2] = C.preuve.premisses, P2 = P.put(texte, "tiger"),
    C2 = C.put(preuve, C.preuve.put(premisses, [P2|Ps2])),
    \+ raisonnement:verifier(Fs, C2),
    C3 = C.put(code, '25F23(TIGER)'), \+ raisonnement:verifier(Fs, C3).

test(determinisme) :-
    getenv('OEDIPAMAAS_BASE', B), docs(Ds),
    oedipamaas:analyser_documents(B, Ds, R1), oedipamaas:analyser_documents(B, Ds, R2),
    maplist([R, J]>>with_output_to(string(J), json_write_dict(current_output, R, [width(0)])), R1, J1),
    maplist([R, J]>>with_output_to(string(J), json_write_dict(current_output, R, [width(0)])), R2, J2),
    J1 == J2.                                  % mêmes octets en sortie

:- end_tests(bout_en_bout).
