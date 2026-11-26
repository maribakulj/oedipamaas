"""Harmonisation des références adjugées (27/11) : les décisions H1 à H4 de docs/BANC_GRAPHES.md, appliquées de la
même façon à tous les lots, avec un journal. Entrée : reference_JEU_adjugee.json (la réunion des lots adjugés) ;
sortie : reference_JEU.json (la référence du banc) et harmonisation_JEU_journal.json."""
import copy, json, sys
from pathlib import Path
B = Path(__file__).resolve().parents[1]
ACCOMPAGNE = {"texte", "text", "légende", "legende", "caption"}

def harmoniser(G, A_par_cle):
    J = []
    for g in G:
        c = (g["k"], g["genre"])
        ids = {e["id"]: e for e in g.get("entites", [])}
        for e in g.get("entites", []):
            t = e["tete"].lower()
            cible = "oeuvre" if t in ACCOMPAGNE else ("non_ancre" if t == "notice" else ("represente" if t == "inscription" else None))
            if cible and e.get("portee", "represente") != cible:
                J.append({"k": c[0], "genre": c[1], "regle": {"oeuvre": "H1", "non_ancre": "H2", "represente": "H3"}[cible],
                          "changement": f"{e['id']} « {e.get('mention')} » : portée {e.get('portee', 'represente')} → {cible}"})
                e["portee"] = cible if cible != "represente" else e.pop("portee", None) or "represente"
                if cible == "represente":
                    e.pop("portee", None)
            if t in ACCOMPAGNE | {"notice"}:
                cible_v = "oeuvre" if t in ACCOMPAGNE else "non_ancre"
                for v in g.get("evenements", []):
                    ags = v.get("roles", {}).get("agent", [])
                    ags = [ags] if isinstance(ags, str) else ags
                    if e["id"] in ags and v.get("portee", "represente") != cible_v:
                        J.append({"k": c[0], "genre": c[1], "regle": "H1" if cible_v == "oeuvre" else "H2",
                                  "changement": f"{v['id']} « {v.get('mention')} » (énoncé de {e['id']}) : portée {v.get('portee', 'represente')} → {cible_v}"})
                        v["portee"] = cible_v
        # H4 : un mouvement est un événement (« monter »), rétabli d'après l'annotation d'origine
        a = A_par_cle.get(c)
        if a:
            for v in a.get("evenements", []):
                if v["predicat"] in ("monter",) and not any(x["id"] == v["id"] for x in g.get("evenements", [])):
                    g.setdefault("evenements", []).append(copy.deepcopy(v))
                    sujets = v["roles"].get("agent", [])
                    lieux = v["roles"].get("lieu", [])
                    avant = len(g.get("relations", []))
                    g["relations"] = [r for r in g.get("relations", []) if not (r["sujet"] in sujets and r["objet"] in lieux)]
                    J.append({"k": c[0], "genre": c[1], "regle": "H4",
                              "changement": f"événement {v['id']} « {v['mention']} » rétabli (un mouvement) ; {avant - len(g['relations'])} relation(s) de position retirée(s)"})
    return J

for jeu in sys.argv[1:] or ("vertical", "validation_m1"):
    G = json.loads((B / f"reference_{jeu}_adjugee.json").read_text(encoding="utf-8"))
    A = {(g["k"], g["genre"]): g for g in json.loads((B / f"reference_{jeu}_brute.json").read_text(encoding="utf-8"))}
    J = harmoniser(G, A)
    (B / f"reference_{jeu}.json").write_text(json.dumps(G, ensure_ascii=False, indent=1), encoding="utf-8")
    (B / f"harmonisation_{jeu}_journal.json").write_text(json.dumps(J, ensure_ascii=False, indent=1), encoding="utf-8")
    import collections
    print(jeu, len(G), "graphes ;", dict(collections.Counter(j["regle"] for j in J)))
