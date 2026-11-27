"""L'analyse de l'expérience contrôlée des couches d'inférence (outils/inference/experience.pl).

Usage : python outils/inference/analyser.py CAUSES.json JEU=EXPERIENCE.json [JEU=EXPERIENCE.json …] [--json SORTIE]

CAUSES.json : les causes des échecs de (référence, référence) de la même version du banc (outils/croise/tableaux.py).

Pour chaque jeu et chaque configuration (base ; C, L, S, D seules ; C+L+S ; C+L+S+D ; et C+L+S+D sans chacune) :
  - les positifs en échec à la base (non établis déductivement), et parmi eux ceux que la configuration améliore
    (de non établi à sous hypothèses ou déductif, ou de sous hypothèses à déductif) ;
  - les atomes : parmi les atomes manquants des positifs en échec à la base, combien la configuration satisfait ;
  - les faux positifs : les négatifs, et les variantes (négation, modalité, hors image, autre relation, copréence,
    rôles inversés), que la configuration établit, déductivement ou sous hypothèses ; les indéterminés établis ;
  - l'inflation : le nombre moyen d'assertions ajoutées par texte ;
  - les règles citées par les preuves des positifs repris et des faux positifs.
Puis, pour chaque échec repris : la plus petite configuration qui le reprend (une couche seule si possible), et ses
causes diagnostiquées (provisoires). Un échec repris sous hypothèses n'est pas un échec résolu : il est compté à part."""
import argparse
import collections
import json
from pathlib import Path

CONFS = ("base", "c", "l", "s", "d", "cls", "clsd", "lsd", "csd", "cld")
NOMS = {"base": "base", "c": "C", "l": "L", "s": "S", "d": "D", "cls": "C+L+S", "clsd": "C+L+S+D",
        "lsd": "sans C", "csd": "sans L", "cld": "sans S"}
RANG = {"non_etablie": 0, "sous_hypotheses": 1, "deductive": 2}


def analyser(X, causes):
    out = {"textes": len(X), "configurations": {}}
    echecs = [x for x in X if x["genre"] == "positif" and x["configurations"]["base"]["conclusion"] != "deductive"]
    out["positifs"] = sum(x["genre"] == "positif" for x in X)
    out["echecs_a_la_base"] = len(echecs)
    for c in CONFS:
        d = collections.Counter()
        regles_repris, regles_fp = collections.Counter(), collections.Counter()
        repris, fps = [], []
        for x in X:
            v = x["configurations"][c]
            g = x["genre"]
            co = v["conclusion"]
            base_co = x["configurations"]["base"]["conclusion"]
            if g == "positif" and x in echecs:
                mb = set(x["configurations"]["base"]["manquants"])
                d["atomes_manquants_base"] += len(mb)
                d["atomes_repris"] += len(mb - set(v["manquants"])) if co == "non_etablie" else len(mb)
            if g == "positif" and x in echecs and RANG[co] > RANG[base_co]:
                d[f"repris_{co}"] += 1
                repris.append({"notation": x["notation"], "conclusion": co, "regles": [p["regle"] for p in v["citees"]]})
                regles_repris.update(p["regle"] for p in v["citees"])
            if (g == "negatif" or g.startswith("variante_")) and co != "non_etablie":
                base = x["configurations"]["base"]["conclusion"]
                nouveau = base == "non_etablie"
                d[f"faux_positifs_{co}"] += 1
                d["faux_positifs_nouveaux"] += nouveau
                fps.append({"k": x["k"], "genre": g, "notation": x["notation"], "conclusion": co, "nouveau": nouveau,
                            "regles": [p["regle"] for p in v["citees"]]})
                regles_fp.update(p["regle"] for p in v["citees"])
            if g == "indetermine" and co != "non_etablie":
                d[f"indetermines_{co}"] += 1
            d["ajoutees"] += v["ajoutees"]
        out["configurations"][c] = {"comptes": dict(d), "inflation": d["ajoutees"] / len(X) if X else 0,
                                    "repris": repris, "faux_positifs": fps,
                                    "regles_repris": dict(regles_repris), "regles_faux_positifs": dict(regles_fp)}
    par_k = {(c["k"], c["genre"]): c for c in causes}
    minimal = []
    for x in echecs:
        b = RANG[x["configurations"]["base"]["conclusion"]]
        ok = [c for c in CONFS[1:] if RANG[x["configurations"][c]["conclusion"]] > b]
        if not ok:
            continue
        seules = [c for c in ok if len(c) == 1]
        m = seules[0] if seules else min(ok, key=len)
        ca = par_k.get((x["k"], x["genre"]), {})
        minimal.append({"k": x["k"], "notation": x["notation"], "minimale": NOMS[m],
                        "couches_seules": [NOMS[c] for c in seules],
                        "conclusion": x["configurations"][m]["conclusion"],
                        "regles": [p["regle"] for p in x["configurations"][m]["citees"]],
                        "causes_diagnostiquees": ca.get("causes", []), "principale": ca.get("principale")})
    out["repris_par_couche_minimale"] = minimal
    out["couche_minimale"] = dict(collections.Counter(m["minimale"] for m in minimal))
    return out


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("causes")
    ap.add_argument("jeux", nargs="+")
    ap.add_argument("--json")
    a = ap.parse_args()
    causes = json.loads(Path(a.causes).read_text(encoding="utf-8"))
    sortie = {}
    for j in a.jeux:
        nom, f = j.split("=", 1)
        X = json.loads(Path(f).read_text(encoding="utf-8"))
        sortie[nom] = analyser(X, [c for c in causes if c["jeu"] == nom])
    for nom, s in sortie.items():
        print(f"\n# {nom} : {s['textes']} textes, {s['positifs']} positifs, {s['echecs_a_la_base']} en échec à la base\n")
        print("| configuration | repris déductivement | repris sous hypothèses | atomes manquants repris "
              "| faux positifs (dont nouveaux) | indéterminés établis | assertions ajoutées par texte |")
        print("|---|---|---|---|---|---|---|")
        for c in CONFS:
            d = s["configurations"][c]["comptes"]
            fp = d.get("faux_positifs_deductive", 0) + d.get("faux_positifs_sous_hypotheses", 0)
            ind = d.get("indetermines_deductive", 0) + d.get("indetermines_sous_hypotheses", 0)
            print(f"| {NOMS[c]} | {d.get('repris_deductive', 0)} | {d.get('repris_sous_hypotheses', 0)} | "
                  f"{d.get('atomes_repris', 0)} / {d.get('atomes_manquants_base', 0)} | "
                  f"{fp} ({d.get('faux_positifs_nouveaux', 0)}) | {ind} | {s['configurations'][c]['inflation']:.1f} |")
        print("\nRepris, par couche minimale :")
        for m in s["repris_par_couche_minimale"]:
            print(f"  {m['notation']} : {m['minimale']} ({m['conclusion']}) par {m['regles']} ; "
                  f"causes diagnostiquées {m['causes_diagnostiquees']}")
        fps = s["configurations"]["clsd"]["faux_positifs"]
        if fps:
            print("\nFaux positifs de C+L+S+D :")
            for f in fps:
                print(f"  {f['notation']} {f['genre']} : {f['conclusion']}{' (nouveau)' if f['nouveau'] else ''} par {f['regles']}")
    if a.json:
        Path(a.json).write_text(json.dumps(sortie, ensure_ascii=False, indent=1), encoding="utf-8")


if __name__ == "__main__":
    main()
