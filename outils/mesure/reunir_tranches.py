"""Réunit les tranches d'une mesure de coder.pl (OEDIPAMAAS_TRANCHE=I/N) en un seul fichier, trié par fiche.

Usage : python outils/mesure/reunir_tranches.py SORTIE.json TRANCHE1.json TRANCHE2.json …
Chaque fiche doit être dans une tranche et une seule (sinon une erreur : rien n'est écrit)."""
import json
import sys
from pathlib import Path

sortie, tranches = Path(sys.argv[1]), [Path(t) for t in sys.argv[2:]]
fiches = [f for t in tranches for f in json.loads(t.read_text(encoding="utf-8"))]
ks = [f["k"] for f in fiches]
if len(ks) != len(set(ks)):
    sys.exit("une fiche est dans plusieurs tranches")
fiches.sort(key=lambda f: f["k"])
sortie.write_text(json.dumps(fiches, ensure_ascii=False, indent=1), encoding="utf-8")
print(f"{len(fiches)} fiches")
