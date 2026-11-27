"""L'archive du banc de graphes (lot 5) : un manifeste et une archive compressée, pour que les données, les résultats
bruts, les versions et les commandes de reproduction restent accessibles hors de la machine de travail.

Usage : python outils/graphes/archiver.py DOSSIER_DU_BANC DOSSIER_DE_MESURE_LOT1 SORTIE.tar.gz [DOSSIER_CROISE]

DOSSIER_CROISE (facultatif) : l'expérience croisée (outils/croise/) ; ses causes d'échecs sont des décisions d'agent.

Écrit, dans DOSSIER_DU_BANC, MANIFESTE.json : chaque fichier (chemin relatif, taille, empreinte SHA-256, rôle), les
versions (commit du code de chaque passe, d'après les descriptions de passe), et le statut de chaque élément :
  « agents »  écrit par des agents annotateurs ou adjudicateurs (accord entre agents ; pas une validation humaine)
  « outil »   produit par un outil du dépôt (graphes du lecteur, mesures)
  « humain »  relu par une personne (aucun à ce jour)
puis l'archive SORTIE.tar.gz des deux dossiers et du manifeste. Rien n'est modifié dans les données."""
import hashlib
import json
import subprocess
import sys
import tarfile
import time
from pathlib import Path

ROLES = [
    ("guide_annotateur.md", "le guide remis aux annotateurs (§ 2 et § 3 de docs/BANC_GRAPHES.md)", "outil"),
    ("textes_", "les textes du banc (échantillon : une fiche sur cinq)", "outil"),
    ("lots/", "les lots remis aux annotateurs", "outil"),
    ("annotations/", "les annotations brutes (A : un annotateur par lot ; B1 : la seconde annotation)", "agents"),
    ("adjudication/", "les lots d'adjudication, les graphes adjugés et les journaux des changements", "agents"),
    ("reference_", "les références (brute : réunion des A ; adjugee ; sans suffixe : harmonisée, la référence)", "agents"),
    ("harmonisation_", "les journaux de l'harmonisation (décisions H1 à H4)", "outil"),
    ("outils/", "les scripts propres aux données (harmonisation)", "outil"),
    ("lecteur_", "les graphes du lecteur (outils/graphes/lire.pl)", "outil"),
    ("faits_reference_", "les références en assertions du noyau (outils/graphes/vers_faits.py)", "outil"),
    ("mesures/", "les résultats bruts des mesures (comparateur, analyse des rôles, codage)", "outil"),
    ("accord_", "l'accord des annotateurs (ancien emplacement)", "outil"),
    ("mesure_lecteur_", "les mesures du lecteur (ancien emplacement, références brutes)", "outil"),
]


def role(rel):
    for p, r, s in ROLES:
        if rel.startswith(p):
            return r, s
    return "autre", "outil"


CROISE = [
    ("causes_", "les causes des échecs de (graphe de référence, requête de référence), décidées cas par cas par un agent ;"
                " provisoires", "agents"),
    ("croise_", "les quatre conditions de l'expérience croisée (outils/croise/croiser.pl)", "outil"),
    ("echecs_", "les échecs et leurs atomes manquants (outils/croise/diagnostiquer.py)", "outil"),
    ("sonde_", "ce que K sait des atomes manquants (outils/croise/sonder.pl)", "outil"),
    ("classes_", "les classes mécaniques des atomes manquants (outils/croise/classer.py)", "outil"),
    ("tableaux", "les tableaux (outils/croise/tableaux.py)", "outil"),
]


def role_croise(rel):
    for p, r, s in CROISE:
        if rel.startswith(p):
            return r, s
    return "autre", "outil"


def sha(p):
    h = hashlib.sha256()
    with open(p, "rb") as f:
        for b in iter(lambda: f.read(1 << 20), b""):
            h.update(b)
    return h.hexdigest()


def main():
    banc, lot1, sortie = Path(sys.argv[1]), Path(sys.argv[2]), Path(sys.argv[3])
    croise = Path(sys.argv[4]) if len(sys.argv) > 4 else None
    depot = Path(__file__).resolve().parents[2]
    fichiers = []
    dossiers = [(banc, "banc_graphes"), (lot1, "reference_d30")] + ([(croise, "croise")] if croise else [])
    for base, nom in dossiers:
        for p in sorted(base.rglob("*")):
            if p.is_file() and p.name != "MANIFESTE.json":
                rel = str(p.relative_to(base))
                r, s = (role(rel) if nom == "banc_graphes" else role_croise(rel) if nom == "croise"
                        else ("la mesure de référence du lot 1", "outil"))
                fichiers.append({"chemin": f"{nom}/{rel}", "taille": p.stat().st_size, "sha256": sha(p), "role": r,
                                 "statut": s})
    commits = sorted({json.loads(p.read_text(encoding="utf-8")).get("commit", "?")
                      for p in lot1.glob("*.passe.json")})
    m = {"cree": time.strftime("%Y-%m-%dT%H:%M:%SZ", time.gmtime()),
         "commit_de_l_archiveur": subprocess.run(["git", "-C", str(depot), "rev-parse", "HEAD"], capture_output=True,
                                                 text=True).stdout.strip(),
         "commits_des_passes_du_lot1": commits,
         "validation_humaine": "aucune à ce jour : tout ce qui est « agents » est un accord entre agents",
         "reproduction": "docs/BANC_GRAPHES.md, § 5 (commandes)",
         "fichiers": fichiers}
    (banc / "MANIFESTE.json").write_text(json.dumps(m, ensure_ascii=False, indent=1), encoding="utf-8")
    with tarfile.open(sortie, "w:gz") as t:
        t.add(banc, arcname="banc_graphes")
        t.add(lot1, arcname="reference_d30")
        if croise:
            t.add(croise, arcname="croise")
    print(f"{len(fichiers)} fichiers ; {sortie} : {sortie.stat().st_size / 1e6:.1f} Mo")


if __name__ == "__main__":
    main()
