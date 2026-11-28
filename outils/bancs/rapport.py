"""La couverture d'un côté des bancs de la phase 1 (docs/BANCS_PHASE1.md, § 5), pour la présentation à la propriétaire.

    python3 outils/bancs/rapport.py bancs/phase1/inventaire.json bancs/phase1/repartition.json COTE CAS.json... [--md SORTIE.md]

Pour le côté donné : les constructions employées et celles qui manquent, la matrice des compositions famille × famille,
les sortes et les statuts attendus (cas et variantes), les variations, les extensions et opérations requises, les
connaissances supposées par sorte et attestation, et les décisions ouvertes. Ne juge pas les statuts."""
import argparse, collections, itertools, json


def rapport(inv, rep, cote, cas):
    L = []
    fams = sorted(inv["familles"])
    vus = collections.Counter((p["famille"], p["phenomene"], p["construction"]) for c in cas for p in c["phenomenes"])
    princ = collections.Counter((c["phenomenes"][0]["phenomene"], c["phenomenes"][0]["construction"]) for c in cas)
    L.append(f"# La couverture du côté « {cote} »\n")
    nv = sum(len(c["variantes"]) for c in cas)
    L.append(f"{len(cas)} cas de base, {nv} variantes.\n")
    L.append("## Par famille\n")
    L.append("| famille | cas | composés (autre famille) | à 3 phénomènes ou plus | constructions du côté employées | dont comme principal |")
    L.append("|---|---|---|---|---|---|")
    manquent = []
    for f in fams:
        cs = [c for c in cas if c["famille"] == f]
        du = [(p, co) for p, x in rep["constructions"][f].items() for co in x[cote]]
        emp = [x for x in du if vus[(f,) + x]]
        pr = [x for x in du if princ[x]]
        manquent += [f"{f}/{p}/{co}" for p, co in du if not vus[(f, p, co)]]
        c2 = sum(1 for c in cs if any(p["famille"] != f for p in c["phenomenes"]))
        c3 = sum(1 for c in cs if len(c["phenomenes"]) >= 3)
        L.append(f"| {f} | {len(cs)} | {c2} | {c3} | {len(emp)}/{len(du)} | {len(pr)}/{len(du)} |")
    L.append(f"\n**Les constructions du côté jamais employées :** {', '.join(manquent) if manquent else 'aucune'}.\n")
    m = collections.Counter()
    for c in cas:
        for p in c["phenomenes"][1:]:
            if p["famille"] != c["famille"]:
                m[tuple(sorted((c["famille"], p["famille"])))] += 1
    vides = [f"{a} × {b}" for a, b in itertools.combinations(fams, 2) if not m[(a, b)]]
    L.append("## La matrice des compositions\n")
    L.append("| | " + " | ".join(f[:6] for f in fams) + " |")
    L.append("|---" * (len(fams) + 1) + "|")
    for a in fams:
        L.append(f"| {a} | " + " | ".join("—" if a == b else str(m[tuple(sorted((a, b)))]) for b in fams) + " |")
    L.append(f"\n**Les paires non couvertes :** {', '.join(vides) if vides else 'aucune'}.\n")

    def compte(titre, it):
        k = collections.Counter(it)
        L.append(f"## {titre}\n")
        L.append("| valeur | nombre |\n|---|---|")
        for v, n in k.most_common():
            L.append(f"| {v} | {n} |")
        L.append("")
    tout = [(c, c) for c in cas] + [(c, v) for c in cas for v in c["variantes"]]
    compte("Les sortes (cas de base)", (c["sorte"] for c in cas))
    compte("Les statuts attendus (cas de base)", (c["statut_attendu"] for c in cas))
    compte("Les statuts attendus (variantes)", (v["statut_attendu"] for c in cas for v in c["variantes"]))
    compte("Les hypothèses attendues (cas et variantes)", (h for _, v in tout for h in v.get("hypotheses_attendues", [])))
    compte("Les variations", (v["variation"] for c in cas for v in c["variantes"]))
    compte("Les variantes dont le statut diffère du cas de base, par variation",
           (v["variation"] for c in cas for v in c["variantes"] if v["statut_attendu"] != c["statut_attendu"]))
    compte("Les langues", (c["langue"] for c in cas))
    compte("Les familles lexicales des pivots", (c["pivot"]["famille_lexicale"] for c in cas))
    compte("Les opérations requises", (o for c in cas for o in c["operations_requises"]))
    compte("Les extensions requises", (x for c in cas for x in c["extensions_requises"]))
    compte("Les connaissances supposées (sorte, attestée)",
           (f"{k['sorte']} ({'attestée' if k['attestee'] else 'non attestée'})" for c in cas for k in c["connaissances_supposees"]))
    ds = [c for c in cas if c.get("decision_ouverte")]
    L.append(f"## Les décisions ouvertes ({len(ds)} cas)\n")
    for c in ds:
        d = c["decision_ouverte"]
        opts = "; ".join(f"{o} → {s}" for o, s in d.get("statut_selon_l_option", {}).items())
        L.append(f"- **{c['id']}** : {d['question']} ({opts}) ; retenu : {c['statut_attendu']}")
    return "\n".join(L) + "\n"


def main():
    a = argparse.ArgumentParser()
    a.add_argument("inventaire"); a.add_argument("repartition")
    a.add_argument("cote", choices=["developpement", "qualification"]); a.add_argument("cas", nargs="+")
    a.add_argument("--md")
    o = a.parse_args()
    t = rapport(json.load(open(o.inventaire)), json.load(open(o.repartition)), o.cote,
                [c for f in o.cas for c in json.load(open(f))])
    if o.md:
        open(o.md, "w").write(t)
    else:
        print(t)


if __name__ == "__main__":
    main()
