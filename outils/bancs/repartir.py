"""La répartition des bancs de la phase 1 entre développement et qualification (docs/BANCS_PHASE1.md, § 3).

    python3 outils/bancs/repartir.py bancs/phase1/inventaire.json bancs/phase1/repartition.json [--graine 20261127]

Elle se fait AVANT l'écriture de tout cas, sur deux axes indépendants :
  - les familles lexicales (fichiers lexicographiques de WordNet 3.0), réparties par partie du discours (adj, noun,
    verb, adv), environ 70/30 (adv.all, seul de sa catégorie, reste en développement) ;
  - les constructions, réparties dans chaque phénomène, environ 70/30, avec au moins une construction de chaque côté.
Un cas de développement n'emploie que des constructions et des familles lexicales de développement ; un cas de
qualification au moins une construction OU une famille lexicale de qualification (et, de préférence, les deux).
Les cas de base sont écrits séparément de chaque côté : un cas n'est jamais dérivé d'un cas de l'autre côté.
La répartition est déterministe pour une graine et un inventaire : son empreinte est écrite avec elle."""
import argparse, hashlib, json, os, random


def couper(elements, rng, part=0.3):
    """Mélange une liste triée et en met environ `part` en qualification, au moins un de chaque côté si possible."""
    xs = sorted(elements)
    rng.shuffle(xs)
    if len(xs) < 2:
        return xs, []
    k = min(len(xs) - 1, max(1, round(len(xs) * part)))
    return sorted(xs[k:]), sorted(xs[:k])


def repartir(inv, graine):
    rng = random.Random(graine)
    lex = {"developpement": [], "qualification": []}
    for pos in ("adj", "noun", "verb", "adv"):
        d, q = couper([l for l in inv["familles_lexicales"]["liste"] if l.startswith(pos + ".")], rng)
        lex["developpement"] += d
        lex["qualification"] += q
    cons = {}
    for f in sorted(inv["familles"]):
        for p in sorted(inv["familles"][f]["phenomenes"]):
            d, q = couper(inv["familles"][f]["phenomenes"][p], rng)
            cons.setdefault(f, {})[p] = {"developpement": d, "qualification": q}
    return {"familles_lexicales": {k: sorted(v) for k, v in lex.items()}, "constructions": cons}


def main():
    a = argparse.ArgumentParser()
    a.add_argument("inventaire"); a.add_argument("sortie"); a.add_argument("--graine", type=int, default=20261127)
    o = a.parse_args()
    brut = open(o.inventaire, "rb").read()
    r = repartir(json.loads(brut), o.graine)
    r = {"graine": o.graine, "inventaire_sha256": hashlib.sha256(brut).hexdigest(), **r}
    json.dump(r, open(o.sortie, "w"), ensure_ascii=False, indent=1)
    inv = json.loads(brut)
    vue = {"note": "La vue de développement de la répartition : ce que les rédacteurs de cas de développement reçoivent. "
                   "Dérivée de repartition.json par outils/bancs/repartir.py.",
           "graine": o.graine, "familles_lexicales": r["familles_lexicales"]["developpement"],
           "familles": {f: {"intitule": inv["familles"][f]["intitule"],
                            "phenomenes": {p: x["developpement"] for p, x in ps.items()}}
                        for f, ps in r["constructions"].items()}}
    json.dump(vue, open(os.path.join(os.path.dirname(o.sortie), "developpement.json"), "w"), ensure_ascii=False, indent=1)
    nd = sum(len(p["developpement"]) for f in r["constructions"].values() for p in f.values())
    nq = sum(len(p["qualification"]) for f in r["constructions"].values() for p in f.values())
    print(f"familles lexicales : {len(r['familles_lexicales']['developpement'])} dev, "
          f"{len(r['familles_lexicales']['qualification'])} qualif ; constructions : {nd} dev, {nq} qualif")


if __name__ == "__main__":
    main()
