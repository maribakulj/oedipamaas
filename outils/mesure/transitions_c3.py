"""Les transitions de la comparaison aux requêtes de référence entre deux mesures de C3 (avant, après) : pour chaque
fiche dont le statut de compilation ou le verdict change, l'un et l'autre ; et le compte des requêtes « compilées et
trop faibles » (les dangereuses : une requête compilée qui demande moins que la référence peut établir à tort).

Usage : python outils/mesure/transitions_c3.py AVANT APRES"""
import json
import sys
from pathlib import Path

av, ap = Path(sys.argv[1]), Path(sys.argv[2])
for j in ("vertical", "validation_m1"):
    A = {x["k"]: x for x in json.loads((av / f"comparaison_{j}.json").read_text(encoding="utf-8"))}
    B = {x["k"]: x for x in json.loads((ap / f"comparaison_{j}.json").read_text(encoding="utf-8"))}
    dangereuses = lambda X: sorted(x["notation"] for x in X.values() if x["verdict"] == "trop_faible" and x["statut"] == "compilee")
    print(f"# {j} : compilées et trop faibles {len(dangereuses(A))} -> {len(dangereuses(B))} : {dangereuses(B)}")
    for k in sorted(B):
        a, b = A[k], B[k]
        if (a["verdict"], a["statut"]) != (b["verdict"], b["statut"]):
            print(f"  {k} {b['notation']} : {a['statut']} {a['verdict']} -> {b['statut']} {b['verdict']} | {str(b['compilee'])[:160]}")
