"""Les représentations formelles (a) des cas de base, recalculées par l'interpréteur de référence, contre la référence
adjugée.

    python3 outils/bancs/comparer_formel.py FORMEL_DIR REFERENCE_DIR SORTIE_DIR

FORMEL_DIR/<famille>.json : les représentations écrites dans la syntaxe concrète nr-1 (docs/LANGAGE_REFERENCE.md,
§ 4) par des rédacteurs qui n'ont vu ni la référence adjugée, ni K0-d30, ni le moteur. Un élément est représenté, ou
dit ce qui manque (`represente: false`, `manque`), ou renvoie à un dossier de semantique_reference/exemples/
(`represente: null`).

REFERENCE_DIR/<famille>.json : la référence adjugée (statut_reference, contexte_du_statut). Elle n'est lue qu'ici, après
l'écriture des représentations, et rien n'est réécrit d'un côté ni de l'autre d'après la comparaison.

Le statut calculé suit la règle par contexte (docs/ANNOTATION_REFERENCE.md, § 7.1) : les contextes figuratifs qui
prennent une valeur ; un seul statut, ou `par_contexte`. Les statuts se comparent sur les deux axes de la déf. 11
(docs/INTERPRETATIONS_ADMISSIBLES.md, 1.1), comptés à part. Écrit SORTIE_DIR/formel.json et SORTIE_DIR/formel.md."""
import collections
import glob
import json
import os
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parents[2]))
from semantique_reference import formation, interprete as I, json_concret as J  # noqa: E402

AXES = {"etablie": (3, 0), "etablie_sous_hypotheses": (2, 0), "ecartee": (0, 3), "ecartee_sous_hypotheses": (0, 2),
        "divergent": (2, 2), "contradictoire": (1, 1), "non_certifiee": (1, 0)}
SANS_VALEUR = {"inconnue", "aucune_interpretation", "incomplet", None}
EXEMPLES = Path(__file__).resolve().parents[2] / "semantique_reference" / "exemples"


def axes_nc(nom, signe=""):
    """Les coordonnées d'un statut ; un non_certifiee signé (étude 1.1, § 3.5) prend le côté de son signe."""
    if nom == "non_certifiee" and signe == "-":
        return (0, 1)
    return AXES.get(nom, (0, 0))


def par_contexte(res):
    """res : [(chemin, statut, axes)] -> (statut, chemins, axes), la règle du guide § 7.1."""
    pris = [r for r in res if r[1] not in SANS_VALEUR]
    if not pris:
        r = next(x for x in res if x[0] == I.RACINE)
        return r[1], [I.RACINE], r[2]
    valeurs = {r[1] for r in pris}
    ax = (max(r[2][0] for r in pris), max(r[2][1] for r in pris))
    if len(valeurs) == 1:
        return valeurs.pop(), [r[0] for r in pris], ax
    return "par_contexte", [r[0] for r in pris], ax


def evaluer_element(x):
    c = J.lire_cas(x)
    defauts = [str(f) for f in formation.verifier(c)]
    ev = I.evaluer(c)
    res = [(k, s.nom, axes_nc(s.nom, s.signe)) for k, s in ev.statuts.items()]
    statut, chemins, ax = par_contexte(res)
    p = ev.principal
    return {"statut": statut, "contextes": chemins, "axes": list(ax),
            "par_contexte": {k: n for k, n, _ in res}, "defauts": defauts,
            "hypotheses": sorted({h.nature for _, h in p.hypotheses}),
            "refutation_fermee": p.refutation_fermee if p.nom in ("ecartee", "ecartee_sous_hypotheses") else None}


def element_d_exemple(ident):
    f = EXEMPLES / f"{ident}.json"
    if not f.exists():
        return None
    for x in json.loads(f.read_text(encoding="utf-8"))["cas"]:
        if x["id"] == f"{ident} (a)":
            return x
    return None


def axes_reference(r):
    if r.get("statut_reference") == "par_contexte":
        cs = [AXES.get(e["statut"], (0, 0)) for e in r.get("resultats_par_contexte", [])]
        return (max(c[0] for c in cs), max(c[1] for c in cs))
    return AXES.get(r.get("statut_reference"), (0, 0))


def comparer(calc, ref):
    sens = []
    for i, nom in ((0, "positif"), (1, "negatif")):
        if calc[i] > ref[i]:
            sens.append(f"plus fort ({nom})")
        elif calc[i] < ref[i]:
            sens.append(f"plus faible ({nom})")
    return "égal" if not sens else ", ".join(sens)


def main():
    formel, refd, out = sys.argv[1:4]
    os.makedirs(out, exist_ok=True)
    REF = {}
    for f in glob.glob(os.path.join(refd, "*.json")):
        for c in json.load(open(f, encoding="utf-8")):
            REF[c["id"]] = c
    lignes, compte = [], collections.Counter()
    manques = collections.Counter()
    for f in sorted(glob.glob(os.path.join(formel, "*.json"))):
        d = json.load(open(f, encoding="utf-8"))
        for x in d["cas"]:
            ident = x["id"].split(" ")[0]  # « dc-001 (a) » : le niveau est noté dans l'identifiant
            ref = REF.get(ident)
            e = {"id": ident, "famille": d["famille"], "reference": ref and ref.get("statut_reference"),
                 "contexte_reference": ref and ref.get("contexte_du_statut")}
            if x.get("represente") is False:
                e["represente"] = False
                e["manque"] = [m.get("construction") for m in x.get("manque", [])]
                for m in e["manque"]:
                    manques[m] += 1
                compte[(d["famille"], "non représenté")] += 1
            else:
                source = x
                if x.get("represente") is None:
                    source = element_d_exemple(ident)
                    if source is None:
                        e["represente"] = None
                        compte[(d["famille"], "non fait")] += 1
                        lignes.append(e)
                        continue
                    e["source"] = "exemple"
                e["represente"] = True
                e.update(evaluer_element(source))
                e["ecrit"] = x.get("statut_calcule")
                ra = list(axes_reference(ref)) if ref else None
                e["axes_reference"] = ra
                e["comparaison"] = comparer(e["axes"], ra) if ref else None
                e["meme_statut"] = bool(ref) and e["statut"] == ref.get("statut_reference")
                compte[(d["famille"], "représenté")] += 1
                compte[(d["famille"], e["comparaison"])] += 1
            lignes.append(e)
    json.dump(lignes, open(os.path.join(out, "formel.json"), "w", encoding="utf-8"), ensure_ascii=False, indent=1)
    rep = [e for e in lignes if e.get("represente")]
    L = ["# Les représentations formelles (a) contre la référence adjugée\n",
         f"{len(lignes)} cas de base ; {len(rep)} représentés, "
         f"{sum(1 for e in lignes if e.get('represente') is False)} non représentés, "
         f"{sum(1 for e in lignes if e.get('represente') is None)} non faits.\n",
         "| famille | représentés | non représentés | égal | même statut | plus fort | plus faible |",
         "|---|---|---|---|---|---|---|"]
    for fam in sorted({e["famille"] for e in lignes}):
        es = [e for e in rep if e["famille"] == fam]
        L.append(f"| {fam} | {len(es)} | {compte[(fam, 'non représenté')]} | "
                 f"{sum(e['comparaison'] == 'égal' for e in es)} | {sum(e['meme_statut'] for e in es)} | "
                 f"{sum('plus fort' in (e['comparaison'] or '') for e in es)} | "
                 f"{sum('plus faible' in (e['comparaison'] or '') for e in es)} |")
    L += ["", "## Les écarts\n", "| cas | calculé | contextes | référence | contexte de la référence | comparaison | "
          "réfutation fermée |", "|---|---|---|---|---|---|---|"]
    for e in rep:
        if not e["meme_statut"] or e["comparaison"] != "égal":
            L.append(f"| {e['id']} | {e['statut']} | {', '.join(e['contextes'])} | {e['reference']} | "
                     f"{', '.join(e['contexte_reference'] or [])} | {e['comparaison']} | "
                     f"{'' if e['refutation_fermee'] is None else ('oui' if e['refutation_fermee'] else 'non')} |")
    L += ["", "## Ce qui manque, par construction\n"] + [f"- {m} : {n}" for m, n in manques.most_common()]
    defs = [e for e in rep if e["defauts"]]
    L += ["", f"## Défauts de formation : {len(defs)}"] + [f"- {e['id']} : {e['defauts']}" for e in defs]
    open(os.path.join(out, "formel.md"), "w", encoding="utf-8").write("\n".join(L) + "\n")
    print("\n".join(L))


if __name__ == "__main__":
    main()
