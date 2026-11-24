"""Mesure des sujets (docs/PLAN_F3.md, étape 3) contre la référence du banc de développement.

Usage : python outils/sujets/mesure_sujets.py REFERENCE.json SCENES.jsonl

Un sujet établi est exact s'il est le sujet de la référence ou l'un de ses codes ; juste s'il est un code de la
référence ou un ancêtre de l'un d'eux (trop général mais vrai) ; faux sinon. Le rappel des sujets compte les textes dont
le sujet de référence est retrouvé, exactement ou par un descendant établi."""
import json
import sys

sys.path.insert(0, __file__.rsplit("/", 2)[0] + "/mesure")
from mesure import normaliser, prefixes  # noqa: E402


def main(reference, scenes):
    ref = {r["id"]: r for r in json.load(open(reference, encoding="utf-8"))}
    n = exact = juste = 0
    a_sujet = trouves = 0
    detail = []
    for l in open(scenes, encoding="utf-8"):
        d = json.loads(l)
        r = ref.get(d["id"])
        if r is None:
            continue
        codes = {normaliser(c["code"]) for c in r.get("codes", [])}
        s = r.get("sujet") or {}
        sujet = normaliser(s["code"]) if isinstance(s, dict) and s.get("code") not in (None, "0") else None
        if sujet:
            codes.add(sujet)
            a_sujet += 1
        anc = set().union(*[prefixes(c) for c in codes]) if codes else set()
        etablis = [normaliser(e["notation"]) for e in d.get("sujets_etablis", [])]
        for e, brut in zip(etablis, d.get("sujets_etablis", [])):
            n += 1
            v = "exact" if e in codes else "juste" if e in anc else "faux"
            exact += v == "exact"
            juste += v in ("exact", "juste")
            detail.append((d["id"], e, v, [f'{a["element"]}<{a["scene"]}>' for a in brut["appuis"]][:8],
                           brut["distinctifs"]))
        if sujet and any(e == sujet or sujet in prefixes(e) for e in etablis):
            trouves += 1
    print(json.dumps({"sujets_etablis": n, "precision_exacte": round(exact / max(1, n), 3),
                      "precision_juste": round(juste / max(1, n), 3), "textes_a_sujet": a_sujet,
                      "sujets_retrouves": trouves, "rappel_sujets": round(trouves / max(1, a_sujet), 3)},
                     ensure_ascii=False))
    for x in detail:
        print(*x, sep="\t")


if __name__ == "__main__":
    main(*sys.argv[1:3])
