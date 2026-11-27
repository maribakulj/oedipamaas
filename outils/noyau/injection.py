"""Injection de défauts dans le moteur optimisé du noyau, pour vérifier que les tests savent échouer.

Usage : python outils/noyau/injection.py

Chaque défaut est une altération d'une copie de oedipamaas/socle/satisfaction.pl, dans un dossier temporaire ; les
tests du noyau (déterministes, sémantiques, génératifs) sont lancés contre cette copie : au moins l'un d'eux doit
échouer. Un défaut que le moteur de référence partagerait n'est vu que par les tests déterministes et sémantiques, dont
les attendus ne dépendent d'aucun moteur. Le dépôt
n'est pas modifié. Un défaut non détecté est un trou dans les tests (docs/NOYAU.md, § 7)."""
import os
import shutil
import subprocess
import sys
import tempfile
from pathlib import Path

ICI = Path(__file__).resolve().parents[2]
SOCLE = ICI / "oedipamaas" / "socle"
TESTS = ICI / "tests" / "plunit"

FAUTES = {
    "négation qui remonte la hiérarchie": (
        "qualifie(M, E, neg, represente, Q), nue(M, E), lien_signe(Sg, K, n, T, W, L),",
        "qualifie(M, E, neg, represente, Q), nue(M, E), lien_pos(K, n, W, T, L),"),
    "distinction en monde fermé": (
        "    ;   V = i\n    ).\n% le nombre d'une entité",
        "    ;   V = v(differents)\n    ).\n% le nombre d'une entité"),
    "référent porteur non vérifié": (
        "present(M, E) :- qualifie(M, E, pos, represente, _), !.",
        "present(_, _)."),
    "négation dans une alternative admise": (
        "    \\+ ( M:alternative(_, As), memberchk(A, As) ).\npresent(M, E)",
        "    true.\npresent(M, E)"),
    "certification malgré un appui négatif": (
        "hypotheses_retenues(K, M, S, A, Hs) :- lie(A, S, Ai), \\+ appui(K, M, Ai, neg, _, _), appui_retenu(",
        "hypotheses_retenues(K, M, S, A, Hs) :- lie(A, S, Ai), appui_retenu("),
    "source citée certifiée": (
        "arbre(pos(auteur), K, M, F, F, [], [], S0, [], Sel0)",
        "arbre(pos(tout), K, M, F, F, [], [], S0, [], Sel0)"),
    "conjonction : un faux ne suffit pas": (
        "( memberchk(0, Ps) -> P = 0 ; P = 1 ), ( memberchk(1, Ns) -> N = 1 ; N = 0 ).\nvaleur(K, M, ou(Fs)",
        "( memberchk(0, Ps) -> P = 0 ; P = 1 ), ( memberchk(0, Ns) -> N = 0 ; N = 1 ).\nvaleur(K, M, ou(Fs)"),
    "budget épuisé pris pour une conclusion": (
        "        ;   Statut = incomplet, partiel(K, M, F, P), Elements = [P]",
        "        ;   Statut = ecartee, Elements = []"),
    "rôle sans l'état de son événement": (
        "M:role(V, Ro, E), M:classe(E, R), M:evenement(V, _, P), qualifie(M, V, pos, represente, Q0), present(M, E),",
        "M:role(V, Ro, E), M:classe(E, R), M:evenement(V, _, P), Q0 = auteur, present(M, E),"),
    "nombre hors de la classe": (
        "    findall((L-Hs)-F, ( M:classe(F, R), M:nombre(F, Nb), present_auteur(M, F), \\+ porteur_nie(K, M, F),",
        "    findall((L-Hs)-F, ( M:nombre(F, Nb), present_auteur(M, F), \\+ porteur_nie(K, M, F),"),
    # version 0.3 (journal, D23 à D33)
    "négation d'une description répartie": (
        "qualifie(M, E, neg, represente, Q), nue(M, E), lien_signe(Sg, K, n, T, W, L),",
        "qualifie(M, E, neg, represente, Q), lien_signe(Sg, K, n, T, W, L),"),
    "liste de noms niée par un seul nom": (
        "nom_nie(K, M, R, K1, Q, Ap), forall(member(Ki, Kr), nom_nie(K, M, R, Ki, _, _)).",
        "member(Ki, [K1|Kr]), nom_nie(K, M, R, Ki, Q, Ap)."),
    "prémisse contredite certifiée": (
        "conteste(K, M, Ai, Ap) :- base(Ai, Ap, B), once(appui_(K, M, B, neg, _, _)), !.",
        "conteste(_, _, _, _) :- fail."),
    "porteur d'une source citée certifié": (
        "Q0 == auteur, member(E, Es), \\+ present_auteur(M, E) -> once(qualifie(M, E, pos, represente, Q1)), Q = Q1",
        "fail -> true"),
    "nombre d'une entité seulement possible": (
        "M:classe(E, R), M:nombre(E, Nb), present(M, E) -> Pv = p",
        "M:classe(E, R), M:nombre(E, Nb) -> Pv = p"),
    "contrainte à trois valeurs": (
        "( A == B -> ( Neg == 1 -> V = b ; V = v(egalite) ) ; Neg == 1 -> V = f ; V = i ).",
        "( A == B -> V = v(egalite) ; Neg == 1 -> V = f ; V = i )."),
    "distinction documentaire sur un nom cité": (
        "qualifie(M, A, pos, represente, auteur), present_auteur(M, E),\n                 \\+ porteur_nie(K, M, E), ",
        "qualifie(M, A, pos, represente, _),\n                 \\+ porteur_nie(K, M, E), "),
    # audit final (cycle 7)
    "existence du porteur ignorée": (
        "conteste(K, M, Ai, Ap) :- porteur(M, Ai, Ap, E), porteur_nie(K, M, E), !.",
        "conteste(_, _, _, _) :- fail."),
    "événement d'un rôle ignoré": (
        "conteste(K, M, role(V, _, _), _) :- M:evenement(V, W, _), once(appui_(K, M, evenement(V, W), neg, _, _)), !.",
        ""),
    "identité contre K non réfutée": (
        "    ( ( distinction(K, M, A, B, D), D \\= supposee(_) ; A == B, documentee_dans(K, M, A) ) -> Neg = 1 ; Neg = 0 ),",
        "    ( distinction(K, M, A, B, D), D \\= supposee(_) -> Neg = 1 ; Neg = 0 ),"),
    # D30 (décision du 27/11)
    "lien d'un seul sens pris pour certain": (
        "    sens_conceptuels(K, Cat, W, Ss), Ss \\== [], forall(member(S, Ss), once(chemin_court(K, sous, S, T, _))).",
        "    sens_conceptuels(K, Cat, W, Ss), member(S, Ss), once(chemin_court(K, sous, S, T, _))."),
    "négation d'un seul sens prise pour certaine": (
        "    forall(( member(N, Ns), member(Sw, Ws) ), once(chemin_court(K, inclus, N, Sw, _))),",
        "    once(( member(N, Ns), member(Sw, Ws), chemin_court(K, inclus, N, Sw, _) )),"),
    # dernier audit (cycle 9)
    "documentaire sur un porteur inexistant": (
        "                 \\+ porteur_nie(K, M, E),                % le porteur existe selon le texte (audit final, B1)\n",
        ""),
    "existence d'une contrainte sans hypothèse": (
        "hypotheses_de_contrainte(K, M, v(nombre(E)), Hs) :- !, existence_supposee(K, M, [E], Hs).",
        "hypotheses_de_contrainte(_, _, v(nombre(_)), []) :- !."),
    "hypothèses sans lecture": (
        "appui_sain(K, M, Ai, Ap) :- appui_(K, M, Ai, pos, auteur, Ap), \\+ conteste(K, M, Ai, Ap), lecture_possible(K, M, Ai, Ap).",
        "appui_sain(K, M, Ai, Ap) :- appui_(K, M, Ai, pos, auteur, Ap), \\+ conteste(K, M, Ai, Ap)."),
    "type entier jamais nié": (
        "noeuds_demandes(_, _, T, [T]) :- integer(T), !.",
        "noeuds_demandes(_, _, T, []) :- integer(T), !."),
}


# les défauts du vérificateur : chacun doit faire accepter une preuve fausse que les bancs contiennent
FAUTES_VERIFICATEUR = {
    # lot 1 (contrôle indexé / exhaustif) : une exception de ressource n'est pas un verdict
    "budget épuisé pris pour un rejet": (
        "echec_ou_ressource(E) :- ressource(E), !, throw(E).",
        "echec_ou_ressource(_) :- fail, !."),
    "régime non contrôlé": (
        "    ( forall(member(A, As), A = genre(_)) -> Rg == classement ; Rg == figuration ).",
        "    true."),
    "empreinte du graphe non contrôlée": (
        "    Vs == [noyau(Vn), connaissances(Vk), graphe(H)].",
        "    Vs = [noyau(Vn), connaissances(Vk), graphe(_)], H = H."),
    "appui négatif ignoré": (
        "    \\+ ( member(j(_, A, _), Js), atome(A), appui_negatif(K, G, S, A) ),",
        "    true,"),
    # depuis le cycle 9, le contrôle de l'assertion citée est couvert par celui des lectures (une assertion niée de
    # façon certaine n'a aucune lecture) : retirer l'un seul donne un mutant équivalent ; on retire les deux
    "prémisse contredite acceptée": (
        "    \\+ ( member(j(_, A, Ap), Js), atome(A), assertion_citee(A, Ap, B), appui_negatif(K, G, S, B) ),\n    % ni contre l'existence d'une entité que l'appui cite, ni contre l'événement d'un rôle\n    \\+ ( member(j(_, A, Ap), Js), atome(A), A \\= genre(_), entite_citee(G, Ap, E), inexistante(K, G, E) ),\n    forall(( member(j(_, A, Ap), Js), atome(A) ), une_lecture(K, G, S, A, Ap)),\n",
        "    % ni contre l'existence d'une entité que l'appui cite, ni contre l'événement d'un rôle\n    \\+ ( member(j(_, A, Ap), Js), atome(A), A \\= genre(_), entite_citee(G, Ap, E), inexistante(K, G, E) ),\n"),
    "contrainte contradictoire acceptée": (
        "    \\+ ( member(distinct(E1, E2), G), meme_classe(G, E1, A), meme_classe(G, E2, A), porteur_admis(G, E1),\n         porteur_admis(G, E2) ),",
        "    true,"),
    "nombre non admissible accepté": (
        "val(S, X, R), memberchk(nombre(E, N), G), meme_classe(G, E, R), porteur_admis(G, E),",
        "val(S, X, R), memberchk(nombre(E, N), G), meme_classe(G, E, R),"),
    "sélection non contrôlée": (
        "    findall(C, member(j(C, _, _), Js), Cs), satisfait(F, [], Cs),",
        "    findall(C, member(j(C, _, _), Js), Cs),"),
    "liaisons non exactes": (
        "    sort(Ks, Vs),                                                             % exactement celles des atomes",
        "    true,"),
    "énonciateur de l'appui non contrôlé": (
        "    qualifie(G, E, pos, represente, auteur), lien_positif(K, n, W, T, L).\nappui_positif(K, G, S, nom(X, Ks)",
        "    qualifie(G, E, pos, represente, _), lien_positif(K, n, W, T, L).\nappui_positif(K, G, S, nom(X, Ks)"),
    "hypothèses non rapprochées": (
        "    findall(X-Y, member(distinction_supposee(X, Y, _, _), Hs), Hs1), msort(Hs1, Hs2), sort(Hs1, Hs2), Hs2 == Us,",
        "    true,"),
    "chemin d'un autre atome accepté": (
        "    forall(member(j(C, A, _), Js), ( position(F, C, A0), A0 == A )).",
        "    true."),
    "lien positif non contrôlé": (
        "lien_positif(K, Cat, W, T, chemin(W, [S0|Ch])) :- sens_du_mot(K, Cat, W, Ss), memberchk(S0, Ss), pas_sous(K, [S0|Ch], T).",
        "lien_positif(_, _, _, _, _)."),
    "porteur présent non contrôlé": (
        "present(G, E) :- qualifie(G, E, pos, represente, _).",
        "present(_, _)."),
    "existence du porteur non contrôlée": (
        "    \\+ ( member(j(_, A, Ap), Js), atome(A), A \\= genre(_), entite_citee(G, Ap, E), inexistante(K, G, E) ),",
        "    true,"),
    "événement d'un rôle non contrôlé": (
        "    \\+ ( member(j(_, role(_, _, _), appui(role(V, _, _), _, _, _)), Js), member(evenement(V, W, _), G),\n         appui_negatif(K, G, [v('$e')-V], evenement(v('$e'), W)) ).",
        "    true."),
    "sens supposé non exigé": (
        "    type_de(A, Cat, T), \\+ positif_certain(K, Cat, W, T).",
        "    type_de(A, Cat, T), fail, \\+ positif_certain(K, Cat, W, T)."),
    "porteur d'une source citée accepté": (
        "porteur_admis(G, E) :- qualifie(G, E, pos, represente, auteur).",
        "porteur_admis(G, E) :- qualifie(G, E, pos, represente, _)."),
}


# les défauts du comparateur (inclusion.pl) : chacun doit faire rendre un verdict faux que les bancs de l'inclusion
# (test_inclusion.pl, attendus écrits à la main ; test_inclusion_generatif.pl, confrontation à des modèles) voient
FAUTES_COMPARATEUR = {
    "budget épuisé pris pour indéterminé": (
        "          ;   ressource(E) -> throw(E)                  % un budget ou une limite de temps : jamais un verdict\n",
        ""),
    "cas non contrôlé (Q1 insatisfaisable)": (
        "    ;   St1 \\== etablie -> R = indetermine(cas_non_etabli(As))\n",
        ""),
    "négation non transmise acceptée": (
        "    forall(member(j(_, A, appui(_, _, _, L)), Js), transmet(K, A, L)),",
        "    true,"),
    "distinction documentaire acceptée": (
        "    \\+ member(j(_, _, contrainte(documentaire(_, _, _))), Js),",
        "    true,"),
    "normalisation prise pour une équivalence": (
        "    ( S0 == S1 -> G = G0 ; throw(fragment(normalisation_non_equivalente)) ),",
        "    G = G1, S0 = S1,"),
    "noms alternatifs pris pour une conjonction": (
        "cas_de(nom(X, Ks), [nom(X, [K])]) :- !, member(K, Ks).",
        "cas_de(nom(X, Ks), [nom(X, Ks)]) :- !."),
    "le type de Q1 pris pour un mot": (
        "mot(T, M) :- format(atom(M), \"$noeud:~w\", [T]).",
        "mot(T, T)."),
    "identité de Q2 sans identité de Q1": (
        "             aggregate_all(count, ( member(E, C), sub_atom(E, 0, 2, _, '$v') ), Nv), Nv >= 2 )).",
        "             true )).",),
    "statut sous hypothèses pris pour établi": (
        "    ( Complet == incomplet -> St = incomplet ; St = St0 ).",
        "    ( Complet == incomplet -> St = incomplet ; St0 == etablie_sous_hypotheses -> St = etablie ; St = St0 )."),
}

BANCS_NOYAU = ("test_noyau.pl", "test_noyau_semantique.pl", "test_noyau_robustesse.pl", "test_noyau_generatif.pl",
               "test_ressources.pl")
BANCS_INCLUSION = ("test_inclusion.pl", "test_inclusion_generatif.pl", "test_ressources.pl")


def essayer(d, nom, fichier, source, avant, apres, bancs=BANCS_NOYAU):
    if avant not in source:
        print(f"{nom} : motif introuvable (le code a changé, mettre l'injection à jour)")
        return False
    (d / "socle" / fichier).write_text(source.replace(avant, apres, 1), encoding="utf-8")
    par = []
    for f in bancs:
        r = subprocess.run(["swipl", "-g", "run_tests", "-t", "halt", f], cwd=d / "plunit",
                           capture_output=True, text=True, env={**os.environ, "LANG": "C.UTF-8"})
        if r.returncode:
            par.append(f.replace("test_noyau", "").replace("test_", "").replace(".pl", "").strip("_") or "deterministes")
    (d / "socle" / fichier).write_text(source, encoding="utf-8")
    print(f"{nom:42} {'détectée par ' + ', '.join(par) if par else 'NON DÉTECTÉE'}")
    return bool(par)


def main():
    non_detectees = []
    with tempfile.TemporaryDirectory() as d:
        d = Path(d)
        (d / "socle").mkdir()
        (d / "plunit").mkdir()
        for f in ("requetes.pl", "satisfaction.pl", "satisfaction_reference.pl", "verificateur.pl", "assertions.pl",
                  "inclusion.pl"):
            shutil.copy(SOCLE / f, d / "socle" / f)
        for f in ("connaissances_gen.pl", "connaissances_essai.pl", "connaissances_losange.pl", "generateur_noyau.pl"):
            shutil.copy(TESTS / f, d / "plunit")
        for f in BANCS_NOYAU + BANCS_INCLUSION:
            test = (TESTS / f).read_text(encoding="utf-8")
            (d / "plunit" / f).write_text(test.replace("'../../oedipamaas/socle/", "'../socle/"), encoding="utf-8")
        print("— moteur optimisé —")
        source = (SOCLE / "satisfaction.pl").read_text(encoding="utf-8")
        for nom, (avant, apres) in FAUTES.items():
            if not essayer(d, nom, "satisfaction.pl", source, avant, apres):
                non_detectees.append(nom)
        print("— vérificateur —")
        source = (SOCLE / "verificateur.pl").read_text(encoding="utf-8")
        for nom, (avant, apres) in FAUTES_VERIFICATEUR.items():
            if not essayer(d, nom, "verificateur.pl", source, avant, apres):
                non_detectees.append(nom)
        print("— comparateur —")
        source = (SOCLE / "inclusion.pl").read_text(encoding="utf-8")
        for nom, (avant, apres) in FAUTES_COMPARATEUR.items():
            if not essayer(d, nom, "inclusion.pl", source, avant, apres, BANCS_INCLUSION):
                non_detectees.append(nom)
    sys.exit(1 if non_detectees else 0)


if __name__ == "__main__":
    main()
