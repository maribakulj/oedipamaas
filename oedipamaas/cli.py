"""Ligne de commande : oedipamaas base | coder | expliquer."""

from __future__ import annotations

import argparse
import hashlib
import json
import sys
import time
from pathlib import Path


def cmd_base(a):
    from .base import compiler

    m = compiler(Path(a.depot), Path(a.sortie), Path(a.wikidata) if a.wikidata else None)
    print(json.dumps(m["comptes"], ensure_ascii=False, sort_keys=True))


def cmd_coder(a):
    from .lecture import lire_fichier
    from .moteur import Moteur

    moteur = Moteur(Path(a.base), a.poids, a.semantique, cles=a.cles, gabarits=a.gabarits, decision=a.decision,
                    profondeur=(a.profondeur_lex, a.profondeur_sem), structure_image=a.structure_image)
    fichiers = sorted(Path(a.descriptions).glob("*.json"))
    if a.limite:
        fichiers = fichiers[: a.limite]
    sortie = Path(a.sortie)
    sortie.parent.mkdir(parents=True, exist_ok=True)
    t0, erreurs, retenus = time.time(), 0, 0
    with open(sortie, "w", encoding="utf8") as f:
        for chemin in fichiers:
            r = moteur.coder(lire_fichier(chemin))
            erreurs += "erreur" in r
            retenus += sum(c["statut"] == "retenu" for c in r["codes"])
            f.write(json.dumps(r, ensure_ascii=False, sort_keys=True) + "\n")
    duree = time.time() - t0
    manifeste = {"versions": moteur.versions, "descriptions": len(fichiers), "erreurs": erreurs,
                 "codes_retenus": retenus, "duree_s": round(duree, 1),
                 "ms_par_image": round(1000 * duree / max(1, len(fichiers)), 1),
                 "sha256_sortie": hashlib.sha256(sortie.read_bytes()).hexdigest()}
    sortie.with_suffix(".manifeste.json").write_text(json.dumps(manifeste, indent=1, sort_keys=True) + "\n")
    print(json.dumps(manifeste, ensure_ascii=False))


def cmd_vecteurs(a):
    from .semantique import calculer

    print(json.dumps(calculer(Path(a.base), a.modele, a.revision), ensure_ascii=False))


def cmd_expliquer(a):
    from .lecture import lire_fichier
    from .moteur import Moteur

    r = Moteur(Path(a.base), a.poids, a.semantique).coder(lire_fichier(Path(a.description)))
    codes = [c for c in r["codes"] if not a.code or c["code"] == a.code]
    if not codes:
        print(f"{a.code} : aucun appui dans cette description")
    for c in codes[: a.top]:
        print(f"{c['code']}  {c['statut']}  score {c['score']}  — {c['iconclass']}")
        for p in c["preuves"]:
            faits = " ; ".join(f"{f['chemin']} « {f['texte']} »" for f in p["faits"])
            extra = p.get("remplace") or p.get("freres") or ""
            print(f"    {p['regle']:<15} +{p['contribution']:<6} {faits} {extra}")


def main(argv=None):
    p = argparse.ArgumentParser(prog="oedipamaas")
    s = p.add_subparsers(dest="cmd", required=True)
    b = s.add_parser("base", help="compiler la base depuis un clone de iconclass/data")
    b.add_argument("depot")
    b.add_argument("sortie")
    b.add_argument("--wikidata", help="instantané P1256 (oedipamaas.wikidata.telecharger) : alias des notations")
    b.set_defaults(f=cmd_base)
    c = s.add_parser("coder", help="coder un dossier de descriptions (*.json) vers codes.jsonl")
    c.add_argument("base")
    c.add_argument("descriptions")
    c.add_argument("sortie")
    c.add_argument("--limite", type=int)
    c.add_argument("--poids", help="poids appris (poids/vN.json) ; sinon score et seuil provisoires")
    c.add_argument("--semantique", help="modèle de phrases dont les vecteurs sont dans la base (ex. paraphrase-multilingual-MiniLM-L12-v2)")
    c.add_argument("--cles", action="store_true", help="proposer aussi les codes à clé (+…)")
    c.add_argument("--gabarits", action="store_true", help="instancier aussi les gabarits à nom libre (X(NOM))")
    c.add_argument("--decision", default="logistique", choices=("logistique", "arbres"),
                   help="décision apprise à utiliser (les arbres doivent être dans le fichier de poids)")
    c.add_argument("--profondeur-lex", type=int, default=10, help="voisins lexicaux par mention")
    c.add_argument("--profondeur-sem", type=int, default=8, help="voisins sémantiques par mention")
    c.add_argument("--structure-image", action="store_true",
                   help="traits des entités situées (boîte, plan) et des relations entre entités")
    c.set_defaults(f=cmd_coder)
    v = s.add_parser("vecteurs", help="calculer les vecteurs de sens des libellés (recherche sémantique)")
    v.add_argument("base")
    v.add_argument("--modele", default="sentence-transformers/paraphrase-multilingual-MiniLM-L12-v2")
    v.add_argument("--revision", help="révision épinglée du modèle (empreinte de commit)")
    v.set_defaults(f=cmd_vecteurs)
    e = s.add_parser("expliquer", help="afficher les preuves des codes d'une description")
    e.add_argument("base")
    e.add_argument("description")
    e.add_argument("code", nargs="?")
    e.add_argument("--top", type=int, default=15)
    e.add_argument("--poids")
    e.add_argument("--semantique", help="modèle de phrases dont les vecteurs sont dans la base (ex. paraphrase-multilingual-MiniLM-L12-v2)")
    e.set_defaults(f=cmd_expliquer)
    a = p.parse_args(argv)
    a.f(a)


if __name__ == "__main__":
    sys.exit(main())
