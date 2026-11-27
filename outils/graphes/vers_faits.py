"""Les graphes annotés (le banc de référence) en assertions du noyau (docs/ASSERTIONS.md), au format de lire.pl.

Usage : python outils/graphes/vers_faits.py REFERENCES.json SORTIE.json

Pour coder les graphes de référence comme ceux du lecteur (outils/graphes/coder_graphes.pl) : la différence des deux
codages est l'effet de la lecture sur les codes Iconclass, toutes choses égales par ailleurs (mêmes requêtes, même
noyau). Conversion :
  - une entité a pour tête son lemme ; une entité nommée dont la tête est son nom (« hercules ») a la tête nom_propre,
    comme le lecteur l'écrit ; chaque nom est une assertion nom/4 ; chaque propriété une assertion propriete/4 ;
  - un nombre (> 1 : un singulier n'est pas un nombre dit) est nombre/2 ;
  - les mentions donnent les passages (la portée dans le texte ; une mention introuvable : le texte entier) ;
  - chaque assertion a ses quatre qualificatifs, explicitement ; les alternatives et les coréférences, distinctions
    sont recopiées.
Les têtes et prédicats sont pris tels qu'annotés (lemmes de la langue du texte) : un lemme que les connaissances ne
connaissent pas ne mène à rien, comme pour le lecteur."""
import collections
import importlib.util
import json
import sys
from pathlib import Path

ICI = Path(__file__).resolve().parent
spec = importlib.util.spec_from_file_location("cg", ICI / "comparer_graphes.py")
cg = importlib.util.module_from_spec(spec)
spec.loader.exec_module(cg)


def atome(x):
    return cg.norm(x)


def vers_faits(r):
    texte = r["texte"]
    F = [["texte", texte], ["doc", r["langue"], "description"]]
    passages = {}
    mentions = [x.get("mention") for x in r.get("entites", []) + r.get("evenements", [])]
    total = collections.Counter(m for m in mentions if m)
    vues = collections.Counter()

    def passage(m):
        occ = cg.occurrences(texte, str(m)) if m else []
        if occ:
            i = min(vues[m], len(occ) - 1)
            vues[m] += 1
            d, f = occ[i]
        else:
            d, f = 0, len(texte)
        cle = (d, f)
        if cle not in passages:
            passages[cle] = f"p{len(passages) + 1}"
        return passages[cle]

    def qualifs(ident, o):
        en = o.get("enonciateur", "auteur")
        return [["polarite", ident, o.get("polarite", "pos")], ["modalite", ident, o.get("modalite", "affirme")],
                ["portee", ident, o.get("portee", "represente")],
                ["enonciateur", ident, "auteur" if en == "auteur" else ["cite", atome(en.get("cite", "x"))]]]
    pass_e = {}
    for e in r.get("entites", []):
        p = passage(e.get("mention"))
        pass_e[e["id"]] = p
        noms = [n if isinstance(n, str) else n["nom"] for n in e.get("noms", [])]
        tete = "nom_propre" if noms and cg.norm(e["tete"]) in {cg.norm(n) for n in noms} else atome(e["tete"])
        F.append(["entite", e["id"], tete, p])
        F += qualifs(e["id"], e)
        for i, n in enumerate(e.get("noms", [])):
            v, q = (n, {}) if isinstance(n, str) else (n["nom"], n)
            F.append(["nom", f"{e['id']}_n{i}", e["id"], v, p])
            F += qualifs(f"{e['id']}_n{i}", q)
        for i, x in enumerate(e.get("proprietes", [])):
            v, q = (x, {}) if isinstance(x, str) else (x["propriete"], x)
            F.append(["propriete", f"{e['id']}_q{i}", e["id"], atome(v), p])
            F += qualifs(f"{e['id']}_q{i}", q)
        if e.get("nombre") is not None and int(e["nombre"]) > 1:
            F.append(["nombre", e["id"], int(e["nombre"])])
    for v in r.get("evenements", []):
        p = passage(v.get("mention"))
        F.append(["evenement", v["id"], cg.norm_pred(v["predicat"]), p])
        F += qualifs(v["id"], v)
        for role, es in (v.get("roles") or {}).items():
            for e in ([es] if isinstance(es, str) else es):
                F.append(["role", v["id"], role, e])
    for x in r.get("relations", []):
        p = pass_e.get(x["sujet"]) or passage(None)
        F.append(["relation", x["id"], x["sujet"], atome(x["relation"]), x["objet"], p])
        F += qualifs(x["id"], x)
    for c in r.get("coref", []):
        for a, b in zip(c, c[1:]):
            F.append(["coref", a, b])
    for a, b in r.get("distinct", []):
        F.append(["distinct", a, b])
    for i, alt in enumerate(r.get("alternatives", [])):
        F.append(["alternative", f"g{i}", alt])
    F += [["passage", p, d, f] for (d, f), p in passages.items()]
    return F


def main():
    R = json.loads(Path(sys.argv[1]).read_text(encoding="utf-8"))
    out = [{"k": r["k"], "genre": r["genre"], "langue": r["langue"], "texte": r["texte"], "faits": vers_faits(r),
            "derivations": []} for r in R]
    Path(sys.argv[2]).write_text(json.dumps(out, ensure_ascii=False, indent=1), encoding="utf-8")
    print(f"{len(out)} graphes")


if __name__ == "__main__":
    main()
