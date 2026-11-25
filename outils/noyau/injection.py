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
        "( S == pos -> lien_pos(K, n, W, T, L) ; lien_neg(K, n, T, W, L) ).\nappui_(K, M, nom(R, Ks)",
        "lien_pos(K, n, W, T, L).\nappui_(K, M, nom(R, Ks)"),
    "distinction en monde fermé": (
        "    ;   V = i\n    ).\ncontrainte_valeur(_, M, nombre(X, Nb), S, V) :-",
        "    ;   V = v(differents)\n    ).\ncontrainte_valeur(_, M, nombre(X, Nb), S, V) :-"),
    "référent porteur non vérifié": (
        "present(M, E) :- qualifie(M, E, pos, represente, _), !.",
        "present(_, _)."),
    "négation dans une alternative admise": (
        "    \\+ ( M:alternative(_, As), memberchk(A, As) ).\npresent(M, E)",
        "    true.\npresent(M, E)"),
    "certification malgré un appui négatif": (
        "    forall(( member(_-A, Sel), requetes:atome(A) ), ( lie(A, S, Ai), \\+ appui(K, M, Ai, neg, _, _) )),",
        "    true,"),
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
        "M:role(V, Ro, E), M:classe(E, R), M:evenement(V, _, P), qualifie(M, V, S, represente, Q), present(M, E).",
        "M:role(V, Ro, E), M:classe(E, R), M:evenement(V, _, P), member(S, [pos]), Q = auteur, present(M, E)."),
    "nombre hors de la classe": (
        "    (   M:classe(E, R), M:nombre(E, Nb) -> V = v(nombre(E))",
        "    (   M:nombre(E, Nb) -> V = v(nombre(E))"),
}


def main():
    source = (SOCLE / "satisfaction.pl").read_text(encoding="utf-8")
    non_detectees = []
    with tempfile.TemporaryDirectory() as d:
        d = Path(d)
        (d / "socle").mkdir()
        (d / "plunit").mkdir()
        for f in ("requetes.pl", "satisfaction_reference.pl", "verificateur.pl", "assertions.pl"):
            shutil.copy(SOCLE / f, d / "socle" / f)
        for f in ("connaissances_gen.pl", "connaissances_essai.pl"):
            shutil.copy(TESTS / f, d / "plunit")
        for f in ("test_noyau_generatif.pl", "test_noyau_semantique.pl", "test_noyau.pl"):
            test = (TESTS / f).read_text(encoding="utf-8")
            (d / "plunit" / f).write_text(test.replace("'../../oedipamaas/socle/", "'../socle/"), encoding="utf-8")
        for nom, (avant, apres) in FAUTES.items():
            if avant not in source:
                print(f"{nom} : motif introuvable (le moteur a changé, mettre l'injection à jour)")
                non_detectees.append(nom)
                continue
            (d / "socle" / "satisfaction.pl").write_text(source.replace(avant, apres, 1), encoding="utf-8")
            par = []
            for f in ("test_noyau.pl", "test_noyau_semantique.pl", "test_noyau_generatif.pl"):
                r = subprocess.run(["swipl", "-g", "run_tests", "-t", "halt", f], cwd=d / "plunit",
                                   capture_output=True, text=True, env={**os.environ, "LANG": "C.UTF-8"})
                if r.returncode:
                    par.append(f.replace("test_noyau", "").replace(".pl", "").strip("_") or "deterministes")
            print(f"{nom:42} {'détectée par ' + ', '.join(par) if par else 'NON DÉTECTÉE'}")
            if not par:
                non_detectees.append(nom)
    sys.exit(1 if non_detectees else 0)


if __name__ == "__main__":
    main()
