"""Précision des codes établis de la V1 contre le catalogue (borne basse : un code juste absent du catalogue compte
comme non confirmé). Usage : python outils/mesure/etablis.py REFERENCE.jsonl SORTIE.jsonl"""
import json
import random
import sys
from collections import Counter, defaultdict

sys.path.insert(0, __file__.rsplit("/", 1)[0])
from mesure import fermeture, intervalle, normaliser  # noqa: E402


def main(reference, sortie):
    ref = {json.loads(l)["id"]: json.loads(l)["codes"] for l in open(reference, encoding="utf-8")}
    par_type, exact, ferme = defaultdict(list), [], []
    docs, avec, erreurs, exemples = 0, 0, 0, defaultdict(list)
    for l in open(sortie, encoding="utf-8"):
        d = json.loads(l)
        docs += 1
        if "erreur" in d:
            erreurs += 1
            continue
        gold = [normaliser(c) for c in ref.get(d["document"], [])]
        fg = fermeture(gold)
        et = [c for c in d["etablis"] if not c["code"].startswith("86")]
        avec += bool(et)
        for c in et:
            ok_e, ok_f = normaliser(c["code"]) in gold, normaliser(c["code"]) in fg
            exact.append(ok_e)
            ferme.append(ok_f)
            par_type[c["type_preuve"]].append(ok_f)
            if not ok_f and len(exemples[c["type_preuve"]]) < 8:
                exemples[c["type_preuve"]].append({"code": c["code"], "texte": [p["texte"] for p in c["preuve"]["premisses"]],
                                                   "catalogue": gold[:6]})
    n = len(ferme)
    res = {"documents": docs, "erreurs": erreurs, "documents_avec_etabli": avec, "codes_etablis": n,
           "precision_exacte": round(sum(exact) / max(1, n), 4), "precision_exacte_ic95": intervalle([float(x) for x in exact]),
           "precision_hierarchique": round(sum(ferme) / max(1, n), 4),
           "precision_hierarchique_ic95": intervalle([float(x) for x in ferme]),
           "par_type": {t: {"n": len(v), "precision_hierarchique": round(sum(v) / len(v), 4)} for t, v in sorted(par_type.items())},
           "exemples_non_confirmes": exemples}
    print(json.dumps(res, ensure_ascii=False, indent=1))


if __name__ == "__main__":
    main(*sys.argv[1:3])
