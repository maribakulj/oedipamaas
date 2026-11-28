"""La comparaison des trois niveaux de statut sur les bancs (docs/INTERPRETATIONS_ADMISSIBLES.md, 1.1, § 2 et déf. 11).

    python3 outils/bancs/comparer_niveaux.py REFERENCE_DIR CAS_DIR RESULTATS_MOTEUR.json SORTIE_DIR

(a) le statut de référence adjugé (REFERENCE_DIR/<famille>.json) ; (b) le statut relatif à K0-d30 (CAS_DIR, champ
`statut_attendu`, convention historique) ; (c) le statut du moteur actuel (la mesure initiale). Écrit
SORTIE_DIR/reference.json (le format qu'attend outils/bancs/mesurer_moteur.py : le statut et ses deux coordonnées,
`axes` et `axes_variantes`, `par_contexte` déjà résolu par ses contextes) et SORTIE_DIR/niveaux.md.

Chaque statut reçoit ses deux coordonnées (ℓ⁺, ℓ⁻) de la définition 11 ; `par_contexte` prend, sur chaque axe, le
maximum de ses contextes. Un niveau inférieur PLUS FORT qu'un niveau supérieur sur un axe est un écart de sûreté sur
cet axe : (b) > (a), une erreur de K ou de représentation ; (c) > (a) ou (c) > (b), une erreur du système. Les deux axes
sont comptés à part, jamais additionnés. Les noms des statuts (b) et (c) sont ceux du noyau 0.3."""
import collections, glob, json, os, sys

AXES = {"etablie": (3, 0), "etablie_sous_hypotheses": (2, 0), "ecartee": (0, 3), "ecartee_sous_hypotheses": (0, 2),
        "divergent": (2, 2), "contradictoire": (1, 1), "non_certifiee": (1, 0), "inconnue": (0, 0),
        "incomplet": (0, 0), "aucune_interpretation": (0, 0), "erreur": (0, 0), None: (0, 0)}


def axes(x):
    if x.get("statut_reference") == "par_contexte":
        cs = [AXES.get(r["statut"], (0, 0)) for r in x.get("resultats_par_contexte", [])]
        return (max(c[0] for c in cs), max(c[1] for c in cs))
    return AXES.get(x.get("statut_reference"), (0, 0))


def charger(refd, casd, res):
    A, B = {}, {}
    for f in glob.glob(os.path.join(refd, "*.json")):
        for c in json.load(open(f)):
            A[c["id"]] = c
            for v in c.get("variantes", []):
                A[f"{c['id']}#{v['n']}"] = v
    for f in glob.glob(os.path.join(casd, "*.json")):
        if os.path.basename(f) == "K.json":
            continue
        for c in json.load(open(f)):
            B[c["id"]] = c.get("statut_attendu")
            for i, v in enumerate(c["variantes"]):
                B[f"{c['id']}#{i}"] = v.get("statut_attendu")
    C = {}
    R = json.load(open(res))
    for c in R["cas"]:
        for e in c["elements"]:
            k = c["id"] if e["n"] == "base" else f"{c['id']}#{e['n']}"
            C[k] = e["statut_c"]
    return A, B, C


def main():
    refd, casd, res, out = sys.argv[1:5]
    os.makedirs(out, exist_ok=True)
    A, B, C = charger(refd, casd, res)
    ref = {}
    for k, x in A.items():
        i, _, n = k.partition("#")
        e = ref.setdefault(i, {"statut_synthetique": None, "variantes": {}, "axes": None, "axes_variantes": {}})
        if n:
            e["variantes"][n] = x["statut_reference"]
            e["axes_variantes"][n] = list(axes(x))
        else:
            e["statut_synthetique"] = x["statut_reference"]
            e["axes"] = list(axes(x))
    json.dump(ref, open(os.path.join(out, "reference.json"), "w"), ensure_ascii=False, indent=1)
    L = ["# Les trois niveaux de statut sur les bancs de développement (28/11)\n",
         f"{len(A)} éléments en (a), {len(B)} en (b), {len(C)} en (c).\n"]
    for nom, X, Y in (("(b) contre (a)", B, None), ("(c) contre (a)", C, None), ("(c) contre (b)", C, B)):
        cpt = collections.Counter()
        for k, x in A.items():
            if k not in X:
                cpt["absent"] += 1
                continue
            haut = axes(x) if Y is None else AXES.get(Y.get(k), (0, 0))
            bas = AXES.get(X[k], (0, 0))
            for ax, i in (("positif", 0), ("negatif", 1)):
                if bas[i] > haut[i]:
                    cpt[f"plus fort sur l'axe {ax}"] += 1
                elif bas[i] < haut[i]:
                    cpt[f"plus faible sur l'axe {ax}"] += 1
            if bas == haut:
                cpt["égal sur les deux axes"] += 1
        L.append(f"## {nom}\n")
        L += [f"- {k} : {n}" for k, n in sorted(cpt.items())]
        L.append("")
    m = collections.Counter((x["statut_reference"], B.get(k)) for k, x in A.items())
    L.append("## La matrice (a) × (b)\n\n| (a) \\ (b) | " + " | ".join(sorted({b for _, b in m if b})) + " |")
    cols = sorted({b for _, b in m if b})
    L.append("|---" * (len(cols) + 1) + "|")
    for a in sorted({a for a, _ in m}):
        L.append(f"| {a} | " + " | ".join(str(m[(a, b)]) for b in cols) + " |")
    open(os.path.join(out, "niveaux.md"), "w").write("\n".join(L) + "\n")
    print("\n".join(L))


if __name__ == "__main__":
    main()
