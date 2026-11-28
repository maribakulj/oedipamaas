"""La comparaison de deux annotations sémantiques indépendantes (niveau (a) ; docs/ANNOTATION_REFERENCE.md), avant
l'adjudication (docs/BANCS_PHASE1.md, § 9.3).

    python3 outils/bancs/comparer_annotations.py A.json B.json [--json SORTIE.json]

Pour chaque cas et chaque variante : l'accord sur le statut synthétique, sur l'ensemble des valeurs de Belnap du
profil (ce qui est affirmé positivement, négativement), sur les dimensions des points d'ambiguïté, sur la nature des
hypothèses et sur les contextes. Puis l'accord observé et le kappa de Cohen sur le statut synthétique. Rien n'est
tranché : les désaccords sont listés pour l'adjudicateur."""
import argparse, collections, json


def resume(x):
    prof = x.get("profil") or []
    return {"statut": x.get("statut_synthetique"),
            "valeurs": sorted({p.get("valeur") for p in prof}),
            "dimensions": sorted({p.get("dimension") for p in x.get("points") or []}),
            "natures": sorted({h.get("nature") for p in prof for h in p.get("hypotheses") or []}),
            "contextes": sorted({str(p.get("contexte")) for p in prof}),
            "doute": bool(x.get("doute")), "infidele": bool(x.get("traduction_infidele"))}


def elements(annot):
    for c in annot:
        yield c["id"], resume(c)
        for v in c.get("variantes", []):
            yield f"{c['id']}#{v['n']}", resume(v)


def kappa(paires):
    n = len(paires)
    if not n:
        return None
    po = sum(a == b for a, b in paires) / n
    ca, cb = collections.Counter(a for a, _ in paires), collections.Counter(b for _, b in paires)
    pe = sum(ca[k] * cb[k] for k in set(ca) | set(cb)) / (n * n)
    return None if pe == 1 else (po - pe) / (1 - pe)


def comparer(A, B):
    ea, eb = dict(elements(A)), dict(elements(B))
    ids = sorted(set(ea) | set(eb))
    manquants = [i for i in ids if i not in ea or i not in eb]
    communs = [i for i in ids if i in ea and i in eb]
    des = []
    for i in communs:
        a, b = ea[i], eb[i]
        champs = [k for k in ("statut", "valeurs", "dimensions", "natures", "contextes") if a[k] != b[k]]
        if champs:
            des.append({"id": i, "champs": champs, "A": a, "B": b})
    paires = [(ea[i]["statut"], eb[i]["statut"]) for i in communs]
    return {"elements": len(communs), "manquants": manquants,
            "accord_statut": sum(a == b for a, b in paires) / len(paires) if paires else None,
            "kappa_statut": kappa(paires),
            "accord_valeurs": sum(ea[i]["valeurs"] == eb[i]["valeurs"] for i in communs) / len(communs) if communs else None,
            "desaccords": des,
            "confusion": collections.Counter(f"{a} | {b}" for a, b in paires if a != b).most_common()}


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("a"); ap.add_argument("b"); ap.add_argument("--json")
    o = ap.parse_args()
    r = comparer(json.load(open(o.a)), json.load(open(o.b)))
    print(f"{r['elements']} éléments communs, {len(r['manquants'])} manquants d'un côté")
    print(f"accord sur le statut synthétique : {r['accord_statut']:.3f}, kappa : {r['kappa_statut']}")
    print(f"accord sur les valeurs du profil : {r['accord_valeurs']:.3f} ; {len(r['desaccords'])} désaccords")
    for k, n in r["confusion"][:15]:
        print(f"  {n:4d}  {k}")
    if o.json:
        json.dump(r, open(o.json, "w"), ensure_ascii=False, indent=1)


if __name__ == "__main__":
    main()
