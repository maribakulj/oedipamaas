"""Le statut de référence par contexte (docs/ANNOTATION_REFERENCE.md, § 7, règle 1, corrigée le 28/11 selon la décision 6
de la propriétaire) : une définition est satisfaite DANS le contexte où la scène est figurée (la figuration principale,
une vision, un rêve, un tableau figuré, l'état d'origine d'une œuvre altérée…), et le résultat garde son chemin. Retenir
la notation pour l'œuvre est une décision documentaire à part, que le statut ne prend pas.

    python3 outils/bancs/statut_par_contexte.py REFERENCE_DIR

Pour chaque cas et chaque variante, à partir du statut adjugé sur le contexte principal et des
`satisfactions_contextuelles` :
  - `resultats_par_contexte` : [{chemin, statut}], le principal compris ;
  - `statut_reference` :
      - le statut du seul contexte qui prend une valeur (les autres `inconnue`), ou le statut commun des contextes qui en
        prennent une ;
      - `par_contexte` si des contextes prennent des valeurs différentes : ni une divergence entre lectures, ni une
        priorité d'un signe ;
      - `inconnue` si aucun contexte ne prend de valeur ;
  - `contexte_du_statut` : les chemins qui portent ce statut ;
  - `historique.statut_contexte_principal` : le statut adjugé d'avant, gardé.
Idempotent : un élément déjà traité est recalculé depuis son historique."""
import glob, json, os, sys

SANS_VALEUR = {"inconnue", "aucune_interpretation", None}


def recalculer(x):
    h = x.setdefault("historique", {})
    principal = h.setdefault("statut_contexte_principal", x.get("statut_reference"))
    res = [{"chemin": "principal", "statut": principal}]
    res += [{"chemin": s.get("chemin"), "statut": s.get("statut")} for s in x.get("satisfactions_contextuelles") or []]
    x["resultats_par_contexte"] = res
    pris = [r for r in res if r["statut"] not in SANS_VALEUR]
    valeurs = {r["statut"] for r in pris}
    if not pris:
        x["statut_reference"], x["contexte_du_statut"] = principal, ["principal"]
    elif len(valeurs) == 1:
        x["statut_reference"], x["contexte_du_statut"] = valeurs.pop(), [r["chemin"] for r in pris]
    else:
        x["statut_reference"], x["contexte_du_statut"] = "par_contexte", [r["chemin"] for r in pris]
    return x["statut_reference"] != principal


def main():
    d = sys.argv[1]
    for f in sorted(glob.glob(os.path.join(d, "*.json"))):
        cas = json.load(open(f))
        n = sum(recalculer(x) for c in cas for x in [c] + c.get("variantes", []))
        json.dump(cas, open(f, "w"), ensure_ascii=False, indent=1)
        print(f"{os.path.basename(f)} : {n} statuts changés")


if __name__ == "__main__":
    main()
