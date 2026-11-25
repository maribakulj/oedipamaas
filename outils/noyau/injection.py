"""Injection de défauts dans le moteur optimisé du noyau, pour vérifier que les tests savent échouer.

Usage : python outils/noyau/injection.py

Chaque défaut est une altération d'une copie de oedipamaas/socle/satisfaction.pl, dans un dossier temporaire ; les
tests génératifs (tests/plunit/test_noyau_generatif.pl) sont lancés contre cette copie et doivent échouer. Le dépôt
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
    "négation sans modalité": (
        "etat(M, A, Ctx, neg) :- M:polarite(A, neg), M:modalite(A, affirme), M:portee(A, Ctx).",
        "etat(M, A, Ctx, neg) :- M:polarite(A, neg), M:portee(A, Ctx)."),
    "distinction inversée": (
        "contrainte_vraie(_, distincts(X, Y), S, S) :- memberchk(X-A, S), memberchk(Y-B, S), A \\== B.",
        "contrainte_vraie(_, distincts(X, Y), S, S) :- memberchk(X-A, S), memberchk(Y-B, S), A == B."),
    "rôle sans l'état de son événement": (
        "    M:role(V, Ro, E), M:classe(E, R), M:evenement(V, _, P), etat(M, V, represente, S).",
        "    M:role(V, Ro, E), M:classe(E, R), M:evenement(V, _, P), member(S, [pos])."),
    "contradiction prise pour vraie": (
        "        ->  Classe = contradictoire, findall",
        "        ->  Classe = vraie, findall"),
    "énonciateur ignoré": (
        "    M:polarite(A, pos), M:modalite(A, affirme), M:enonciateur(A, auteur), M:portee(A, Ctx),",
        "    M:polarite(A, pos), M:modalite(A, affirme), M:portee(A, Ctx),"),
    "alternative ignorée": (
        "    \\+ ( M:alternative(_, As), memberchk(A, As) ).\netat(M, A, Ctx, neg)",
        "    true.\netat(M, A, Ctx, neg)"),
    "nombre hors de la classe": (
        "contrainte_vraie(M, nombre(X, N), S, S) :- memberchk(X-R, S), M:classe(E, R), M:nombre(E, N), !.",
        "contrainte_vraie(M, nombre(X, N), S, S) :- memberchk(X-_, S), M:nombre(_, N), !."),
}


def main():
    source = (SOCLE / "satisfaction.pl").read_text(encoding="utf-8")
    non_detectees = []
    with tempfile.TemporaryDirectory() as d:
        d = Path(d)
        (d / "socle").mkdir()
        (d / "plunit").mkdir()
        for f in ("requetes.pl", "satisfaction_reference.pl", "verificateur.pl"):
            shutil.copy(SOCLE / f, d / "socle" / f)
        shutil.copy(TESTS / "connaissances_gen.pl", d / "plunit")
        test = (TESTS / "test_noyau_generatif.pl").read_text(encoding="utf-8")
        (d / "plunit" / "test.pl").write_text(test.replace("'../../oedipamaas/socle/", "'../socle/"), encoding="utf-8")
        for nom, (avant, apres) in FAUTES.items():
            if avant not in source:
                print(f"{nom} : motif introuvable (le moteur a changé, mettre l'injection à jour)")
                non_detectees.append(nom)
                continue
            (d / "socle" / "satisfaction.pl").write_text(source.replace(avant, apres, 1), encoding="utf-8")
            r = subprocess.run(["swipl", "-g", "run_tests", "-t", "halt", "test.pl"], cwd=d / "plunit",
                               capture_output=True, text=True, env={**os.environ, "LANG": "C.UTF-8"})
            print(f"{nom:36} {'détectée' if r.returncode else 'NON DÉTECTÉE'}")
            if not r.returncode:
                non_detectees.append(nom)
    sys.exit(1 if non_detectees else 0)


if __name__ == "__main__":
    main()
