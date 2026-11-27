"""Réunit les tranches d'une mesure de coder.pl (OEDIPAMAAS_TRANCHE=I/N), après en avoir contrôlé la complétude.

Usage : python outils/mesure/reunir_tranches.py SORTIE.json TEXTES.json PAS TRANCHE1.json TRANCHE2.json …

Contrôles (un seul défaut, et rien n'est écrit) :
  - chaque tranche a sa description (TRANCHE.json.passe.json) ; toutes ont le même commit (lu au départ de la passe,
    sur un arbre de travail sans modification), le même réglage, la même entrée et le même pas, et leurs numéros sont
    exactement 1/N … N/N ;
  - les fiches réunies sont exactement celles de l'échantillon (une fiche sur PAS de TEXTES.json), chacune dans une
    seule tranche, et celles que la description de sa tranche annonce ;
  - chaque texte de chaque fiche (positif, négatif, indéterminé, variantes) a un résultat, y compris « interrompu » ou
    « erreur » : un texte absent est un défaut, jamais un zéro.
SORTIE.json : les fiches, triées ; SORTIE.json.passe.json : la description commune, les tranches et leurs analyses."""
import json
import sys
from pathlib import Path


def textes_de(fiche):
    gs = [g for g in ("positif", "negatif", "indetermine") if g in fiche]
    return gs + [f"variante_{g}" for g in (fiche.get("variantes") or {})]


def main():
    sortie, entree, pas = Path(sys.argv[1]), Path(sys.argv[2]), int(sys.argv[3])
    tranches = [Path(t) for t in sys.argv[4:]]
    defauts = []
    passes = []
    for t in tranches:
        p = Path(str(t) + ".passe.json")
        if not p.exists():
            defauts.append(f"{t} : pas de description de passe")
            continue
        passes.append(json.loads(p.read_text(encoding="utf-8")))
    if passes:
        if any(p.get("arbre_modifie") for p in passes):
            defauts.append("une tranche a tourné sur un arbre de travail modifié : son commit ne dit pas son code")
        for cle in ("commit", "reglage", "entree", "pas"):
            vs = {json.dumps(p[cle], sort_keys=True) for p in passes}
            if len(vs) > 1:
                defauts.append(f"des tranches de {cle} différents : {sorted(vs)}")
        nums = sorted(p["tranche"] for p in passes)
        n = {int(x.split("/")[1]) for x in nums}
        if len(n) != 1 or nums != sorted(f"{i}/{list(n)[0]}" for i in range(1, list(n)[0] + 1)):
            defauts.append(f"tranches incomplètes ou en double : {nums}")
        if any(p["pas"] != pas for p in passes):
            defauts.append("pas différent de celui demandé")
    attendues = [f for i, f in enumerate(json.loads(entree.read_text(encoding="utf-8"))) if i % pas == 0]
    fiches, vues = [], {}
    for t, p in zip(tranches, passes):
        fs = json.loads(t.read_text(encoding="utf-8"))
        if sorted(f["k"] for f in fs) != sorted(p["fiches"]):
            defauts.append(f"{t} : fiches différentes de celles de sa passe")
        for f in fs:
            vues[f["k"]] = vues.get(f["k"], 0) + 1
            fiches.append(f)
    defauts += [f"fiche {k} dans {n} tranches" for k, n in vues.items() if n > 1]
    ka = {f["k"] for f in attendues}
    defauts += [f"fiche {k} manquante" for k in sorted(ka - set(vues))]
    defauts += [f"fiche {k} hors de l'échantillon" for k in sorted(set(vues) - ka)]
    par_k = {f["k"]: f for f in fiches}
    for f in attendues:
        r = par_k.get(f["k"])
        if r is None:
            continue
        for g in textes_de(f):
            if not isinstance(r.get(g), dict) or "statut" not in r[g]:
                defauts.append(f"fiche {f['k']} : texte {g} sans résultat")
    if defauts:
        print("\n".join(defauts))
        sys.exit(1)
    fiches.sort(key=lambda f: f["k"])
    sortie.write_text(json.dumps(fiches, ensure_ascii=False, indent=1), encoding="utf-8")
    commune = {k: passes[0][k] for k in ("commit", "reglage", "entree", "pas", "swipl", "processeurs")}
    commune["tranches"] = [{k: p[k] for k in ("tranche", "fiches", "debut", "fin", "analyses")} for p in passes]
    Path(str(sortie) + ".passe.json").write_text(json.dumps(commune, ensure_ascii=False, indent=1), encoding="utf-8")
    nt = sum(len(textes_de(f)) for f in attendues)
    print(f"{len(fiches)} fiches, {nt} textes, {len(passes)} tranches : complet")


if __name__ == "__main__":
    main()
