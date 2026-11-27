"""La cohérence de la canonisation des deux côtés (contre-expertise de la PR #16, point 6) : ce que les graphes du
banc écrivent là où #16 réécrit les requêtes.

Usage : python outils/mesure/coherence_c3.py BANC_GRAPHES_DIR SORTIE.json

Sur les deux jeux du banc (graphes de référence, d'après le guide ; graphes du lecteur) :
  - les noms d'action : les événements de la référence qui ont un `nom_d_action` (le guide les écrit en événements) ;
    combien de fois le graphe du lecteur du même texte a une entité de cette tête (il garde le nom) et combien de fois
    il a l'événement du même prédicat ;
  - les participes : les propriétés de la référence (le guide écrit en propriété un participe d'état résultant) et les
    propriétés du lecteur dont le mot est le prédicat d'un événement ailleurs dans le banc (un verbe), comptées.
#16 réécrit les noms d'action des requêtes en événements, et tous les participes des requêtes en événements : la
requête ne peut alors rencontrer ni l'entité du lecteur, ni la propriété d'état de la référence."""
import collections
import json
import sys
from pathlib import Path


def norm(x):
    return " ".join(str(x).lower().replace("_", " ").split())


def main():
    B, sortie = Path(sys.argv[1]), Path(sys.argv[2])
    out = {}
    for j in ("vertical", "validation_m1"):
        R = {(g["k"], g["genre"]): g for g in json.loads((B / f"reference_{j}.json").read_text(encoding="utf-8"))}
        L = {(g["k"], g["genre"]): g for g in json.loads((B / f"lecteur_{j}.json").read_text(encoding="utf-8"))}
        c = collections.Counter()
        verbes = {norm(v["predicat"]) for g in R.values() for v in g["evenements"]}
        for k, g in R.items():
            lu = L.get(k)
            if not lu or lu["faits"] == "erreur":
                continue
            tetes = {norm(f[2]) for f in lu["faits"] if f[0] == "entite"}
            preds = {norm(f[2]) for f in lu["faits"] if f[0] == "evenement"}
            for v in g["evenements"]:
                if v.get("nom_d_action"):
                    c["reference_nom_d_action"] += 1
                    na = norm(v["nom_d_action"])
                    c["lecteur_entite_du_nom"] += na in tetes
                    c["lecteur_evenement"] += norm(v["predicat"]) in preds
            for e in g["entites"]:
                for p in e.get("proprietes", []):
                    w = norm(p if isinstance(p, str) else p["propriete"])
                    c["reference_proprietes"] += 1
                    c["reference_proprietes_participes"] += w.endswith(("ed", "en", "é", "ée", "és", "ées", "u", "i", "it"))
            for f in lu["faits"]:
                if f[0] == "propriete":
                    c["lecteur_proprietes"] += 1
                    c["lecteur_proprietes_verbales"] += norm(f[3]) in verbes
        out[j] = dict(c)
    sortie.write_text(json.dumps(out, ensure_ascii=False, indent=1), encoding="utf-8")
    print(json.dumps(out, ensure_ascii=False, indent=1))


if __name__ == "__main__":
    main()
