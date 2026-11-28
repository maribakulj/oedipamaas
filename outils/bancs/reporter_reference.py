"""Le report des références adjugées (niveau (a)) dans les cas du schéma 3 (docs/BANCS_PHASE1.md, § 9).

    python3 outils/bancs/reporter_reference.py REFERENCE_DIR CAS_DIR ANNOTATIONS_DIR

Pour chaque cas et chaque variante : `statut_reference`, `contexte_du_statut`, `resultats_par_contexte`,
`profil_reference`, `points_reference`, `dependances` (de l'adjudication), et `annotations` : les statuts synthétiques
des annotateurs A et B, gardés (jamais effacés). Les statuts relatifs à K (`statuts_relatifs`, `statut_attendu`) ne sont
pas touchés. La langue d'une traduction est déclarée si elle manque (la langue opposée à celle du cas)."""
import glob, json, os, sys


def main():
    refd, casd, annd = sys.argv[1:4]
    for f in sorted(glob.glob(os.path.join(casd, "*.json"))):
        fam = os.path.basename(f)[:-5]
        if fam == "K":
            continue
        ref = {c["id"]: c for c in json.load(open(os.path.join(refd, fam + ".json")))}
        ann = {k: {c["id"]: c for c in json.load(open(os.path.join(annd, f"{fam}.{k}.json")))} for k in "AB"}
        cas = json.load(open(f))
        for c in cas:
            r = ref[c["id"]]
            paires = [(c, r, {k: ann[k][c["id"]] for k in "AB"})]
            rv = {v["n"]: v for v in r.get("variantes", [])}
            for i, v in enumerate(c["variantes"]):
                av = {k: next((x for x in ann[k][c["id"]].get("variantes", []) if x["n"] == i), {}) for k in "AB"}
                paires.append((v, rv[i], av))
                if v.get("variation") == "traduction" and not v.get("langue"):
                    v["langue"] = "en" if c["langue"] == "fr" else "fr"
            for x, y, a in paires:
                x["statut_reference"] = y["statut_reference"]
                x["contexte_du_statut"] = y.get("contexte_du_statut")
                x["resultats_par_contexte"] = y.get("resultats_par_contexte")
                x["profil_reference"] = y.get("profil")
                x["points_reference"] = y.get("points")
                x["dependances"] = y.get("dependances") or []
                x["source_reference"] = y.get("source")
                x["annotations"] = {k: a[k].get("statut_synthetique") for k in "AB"}
        json.dump(cas, open(f, "w"), ensure_ascii=False, indent=1)
        print(fam, "reporté")


if __name__ == "__main__":
    main()
