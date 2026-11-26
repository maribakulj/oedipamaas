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
        "qualifie(M, E, neg, represente, Q), nue(M, E), lien_neg(K, n, T, W, L),",
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
        "( lie(A, S, Ai), \\+ appui(K, M, Ai, neg, _, _), once(appui_sain(K, M, Ai, _)) )),",
        "( lie(A, S, Ai), once(appui_sain(K, M, Ai, _)) )),"),
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
        "    (   M:classe(E, R), M:nombre(E, Nb), present_auteur(M, E) -> Pv = v(nombre(E))",
        "    (   M:nombre(E, Nb) -> Pv = v(nombre(E))"),
    # version 0.3 (journal, D23 à D33)
    "négation d'une description répartie": (
        "qualifie(M, E, neg, represente, Q), nue(M, E), lien_neg(K, n, T, W, L),",
        "qualifie(M, E, neg, represente, Q), lien_neg(K, n, T, W, L),"),
    "liste de noms niée par un seul nom": (
        "nom_nie(K, M, R, K1, Q, Ap), forall(member(Ki, Kr), nom_nie(K, M, R, Ki, _, _)).",
        "member(Ki, [K1|Kr]), nom_nie(K, M, R, Ki, Q, Ap)."),
    "prémisse contredite certifiée": (
        "appui_(K, M, Ai, pos, auteur, Ap), \\+ ( base(Ai, Ap, B), once(appui_(K, M, B, neg, _, _)) ).",
        "appui_(K, M, Ai, pos, auteur, Ap)."),
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
        "qualifie(M, A, pos, represente, auteur), present_auteur(M, E),\n                 K:cle_de_nom(Nom, C), \\+ nom_conteste(K, M, R, C) ), Ns0),",
        "qualifie(M, A, pos, represente, _),\n                 K:cle_de_nom(Nom, C) ), Ns0),"),
    "type entier jamais nié": (
        "noeud_demande(_, _, T, T) :- integer(T), !.",
        "noeud_demande(_, _, T, _) :- integer(T), !, fail."),
}


# les défauts du vérificateur : chacun doit faire accepter une preuve fausse que les bancs contiennent
FAUTES_VERIFICATEUR = {
    "régime non contrôlé": (
        "    ( forall(member(A, As), A = genre(_)) -> Rg == classement ; Rg == figuration ).",
        "    true."),
    "empreinte du graphe non contrôlée": (
        "    Vs == [noyau(Vn), connaissances(Vk), graphe(H)].",
        "    Vs = [noyau(Vn), connaissances(Vk), graphe(_)], H = H."),
    "appui négatif ignoré": (
        "    \\+ ( member(j(_, A, _), Js), atome(A), appui_negatif(K, G, S, A) ),",
        "    true,"),
    "prémisse contredite acceptée": (
        "    \\+ ( member(j(_, A, Ap), Js), atome(A), assertion_citee(A, Ap, B), appui_negatif(K, G, S, B) ).",
        "    true."),
    "contrainte contradictoire acceptée": (
        "    \\+ ( member(distinct(E1, E2), G), meme_classe(G, E1, A), meme_classe(G, E2, A) ).",
        "    true."),
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
        "    findall(X-Y, member(distinction_supposee(X, Y, _, _), Hs), Hs1), msort(Hs1, Hs2), sort(Hs1, Hs2), Hs2 == Us.",
        "    true."),
    "chemin d'un autre atome accepté": (
        "    forall(member(j(C, A, _), Js), ( position(F, C, A0), A0 == A )).",
        "    true."),
    "lien positif non contrôlé": (
        "lien_positif(K, Cat, W, T, chemin(W, [S0|Ch])) :- K:sens(Cat, W, S0), pas_sous(K, [S0|Ch], T).",
        "lien_positif(_, _, _, _, _)."),
    "porteur présent non contrôlé": (
        "present(G, E) :- qualifie(G, E, pos, represente, _).",
        "present(_, _)."),
    "porteur d'une source citée accepté": (
        "porteur_admis(G, E) :- qualifie(G, E, pos, represente, auteur).",
        "porteur_admis(G, E) :- qualifie(G, E, pos, represente, _)."),
}


def essayer(d, nom, fichier, source, avant, apres):
    if avant not in source:
        print(f"{nom} : motif introuvable (le code a changé, mettre l'injection à jour)")
        return False
    (d / "socle" / fichier).write_text(source.replace(avant, apres, 1), encoding="utf-8")
    par = []
    for f in ("test_noyau.pl", "test_noyau_semantique.pl", "test_noyau_robustesse.pl", "test_noyau_generatif.pl"):
        r = subprocess.run(["swipl", "-g", "run_tests", "-t", "halt", f], cwd=d / "plunit",
                           capture_output=True, text=True, env={**os.environ, "LANG": "C.UTF-8"})
        if r.returncode:
            par.append(f.replace("test_noyau", "").replace(".pl", "").strip("_") or "deterministes")
    (d / "socle" / fichier).write_text(source, encoding="utf-8")
    print(f"{nom:42} {'détectée par ' + ', '.join(par) if par else 'NON DÉTECTÉE'}")
    return bool(par)


def main():
    non_detectees = []
    with tempfile.TemporaryDirectory() as d:
        d = Path(d)
        (d / "socle").mkdir()
        (d / "plunit").mkdir()
        for f in ("requetes.pl", "satisfaction.pl", "satisfaction_reference.pl", "verificateur.pl", "assertions.pl"):
            shutil.copy(SOCLE / f, d / "socle" / f)
        for f in ("connaissances_gen.pl", "connaissances_essai.pl"):
            shutil.copy(TESTS / f, d / "plunit")
        for f in ("test_noyau_generatif.pl", "test_noyau_semantique.pl", "test_noyau.pl", "test_noyau_robustesse.pl"):
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
    sys.exit(1 if non_detectees else 0)


if __name__ == "__main__":
    main()
