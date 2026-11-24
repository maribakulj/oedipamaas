"""Tire un banc de textes, disjoint des bancs existants (D19).

Usage : python outils/mesure/tirer_banc.py SORTIE.json GRAINE N_CLEVELAND N_CHICAGO N_JOCONDE BANC_EXCLU.json...

Viviers : /home/user/donnees/cartels/{cleveland,chicago}.jsonl (cartels CC0 et CC BY 4.0) et
/home/user/donnees/joconde/entree_desc.jsonl (notices de Joconde dont la description porte sur l'image).
Seul filtre : une description de 200 à 1 500 caractères (comme les bancs précédents) ; aucun filtre sur le contenu, une
notice qui ne décrit rien de l'image fait partie du banc. Le tirage est l'ordre de sha256(graine + id) : rejouable."""
import hashlib
import json
import sys

VIVIERS = {"cleveland": "/home/user/donnees/cartels/cleveland.jsonl",
           "chicago": "/home/user/donnees/cartels/chicago.jsonl",
           "joconde": "/home/user/donnees/joconde/entree_desc.jsonl"}


def main(sortie, graine, n_cma, n_aic, n_joc, *exclus):
    deja = {d["id"] for f in exclus for d in json.load(open(f, encoding="utf-8"))}
    out = []
    for v, n in (("cleveland", int(n_cma)), ("chicago", int(n_aic)), ("joconde", int(n_joc))):
        docs = [json.loads(l) for l in open(VIVIERS[v], encoding="utf-8")]
        docs = [d for d in docs if d["id"] not in deja and 200 <= len(d.get("description") or "") <= 1500]
        docs.sort(key=lambda d: hashlib.sha256((graine + d["id"]).encode()).hexdigest())
        out += [{"id": d["id"], "langue": d["langue"], "titre": d.get("titre") or "", "description": d["description"]}
                for d in docs[:n]]
    for i, d in enumerate(out, 1):
        d["n"] = i
    json.dump(out, open(sortie, "w", encoding="utf-8"), ensure_ascii=False, indent=1)
    print(len(out), "textes")


if __name__ == "__main__":
    main(*sys.argv[1:])
