"""La sous-référence « autorisée par le texte » (D19) : ne garde que ce que la description justifie.

Usage : python outils/mesure/sous_reference.py BANC.json REFERENCE.json SORTIE.json

Un code est gardé si la citation qui le justifie (« texte ») figure dans la description ; un code que seul le titre
justifie (la citation ne figure que dans le titre, ou nulle part) est retiré, conformément à D15. Le sujet est gardé si
son code est l'un des codes gardés ; sinon il devient null (sa phrase est gardée, marquée « non autorisé »). Les
éléments sont gardés si leur citation figure dans la description. Le compte rendu donne ce qui est retiré."""
import json
import sys


def main(banc, reference, sortie):
    textes = {d["id"]: d for d in json.load(open(banc, encoding="utf-8"))}
    out, retraits = [], []
    for r in json.load(open(reference, encoding="utf-8")):
        desc = textes[r["id"]]["description"]
        codes = [c for c in r.get("codes", []) if c.get("texte") and c["texte"] in desc]
        retraits += [(r["id"], c["code"], c.get("texte")) for c in r.get("codes", []) if c not in codes]
        elements = [e for e in r.get("elements", []) if e.get("texte") and e["texte"] in desc]
        s = dict(r.get("sujet") or {})
        if s.get("code") and s["code"] not in {c["code"] for c in codes}:
            retraits.append((r["id"], "sujet " + s["code"], "code du sujet sans citation dans la description"))
            s["code"], s["non_autorise"] = None, True
        out.append({**r, "elements": elements, "codes": codes, "sujet": s or None})
    json.dump(out, open(sortie, "w", encoding="utf-8"), ensure_ascii=False, indent=1)
    print(json.dumps({"codes_retires": len(retraits), "detail": retraits}, ensure_ascii=False, indent=1))


if __name__ == "__main__":
    main(*sys.argv[1:4])
