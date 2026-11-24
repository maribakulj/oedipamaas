"""Mesure de la scène (docs/PLAN_F3.md, étape 2) contre les éléments de la référence du banc de développement.

Usage : python outils/sujets/mesure_scene.py REFERENCE.json SCENES.jsonl [DETAIL.json]

Un élément de la référence (une citation de la description) est retrouvé si un élément de scène a un passage qui
le chevauche. Sinon, sa perte est classée par ce que la lecture en a fait :
  non_lu          aucune assertion ne chevauche la citation (l'analyseur ou les règles de lecture n'en ont rien tiré)
  non_ancre       lu, mais d'une autre portée que « représenté » (l'ancrage F1 ne l'a pas mis dans l'image)
  nie, modalite, alternative, titre   lu, mais nié, non affirmé, en alternative, ou dit par le seul titre
  sans_element    lu et admissible, mais sans élément de scène (relation par préposition, mot trop court)
Les mots de l'analyseur qui couvrent chaque citation perdue sont joints au détail, pour juger la part des pertes dues
à l'analyseur.
Les éléments de scène hors de toute citation de la référence sont comptés à part (« hors référence ») : la référence
ne liste pas tout ce qui est représenté, leur justesse se juge sur échantillon."""
import collections
import json
import sys


def chevauche(a, b):
    return a[0] < b[1] and b[0] < a[1]


def cause(ass, span):
    lues = [a for a in ass if chevauche((a["debut"], a["fin"]), span)]
    if not lues:
        return "non_lu"
    if any(a["admissible"] for a in lues):
        return "sans_element"
    if any(a["modalite"] == "titre" for a in lues):
        return "titre"
    if all(a["portee"] != "represente" for a in lues):
        return "non_ancre"
    if any(a["polarite"] == "neg" for a in lues):
        return "nie"
    if any(a["alternative"] for a in lues):
        return "alternative"
    return "modalite"


def main(reference, scenes, detail=None):
    ref = {r["id"]: r for r in json.load(open(reference, encoding="utf-8"))}
    tot = trouves = 0
    causes = collections.Counter()
    els_tot = els_hors = 0
    pertes, hors = [], []
    for l in open(scenes, encoding="utf-8"):
        d = json.loads(l)
        r = ref.get(d["id"])
        if r is None:
            continue
        texte = d["texte"]
        debut_desc = d["fin_titre"] + 2 if d["fin_titre"] else 0
        spans = []
        for e in r.get("elements", []):
            i = texte.find(e["texte"], debut_desc)
            if i < 0:
                i = texte.find(e["texte"])
            if i < 0:
                causes["citation_introuvable"] += 1
                tot += 1
                continue
            span = (i, i + len(e["texte"]))
            spans.append(span)
            tot += 1
            if any(chevauche((x["debut"], x["fin"]), span) for x in d["elements"]):
                trouves += 1
            else:
                c = cause(d["assertions"], span)
                causes[c] += 1
                mots = [f'{m["forme"]}/{m["categorie"]}/{m["relation"]}' for m in d["mots"]
                        if chevauche((m["debut"], m["fin"]), span)]
                pertes.append({"id": d["id"], "citation": e["texte"], "quoi": e.get("quoi"), "cause": c,
                               "mots": mots,
                               "assertions": [(a["sorte"], a["valeur"], a["portee"], a["modalite"], a["polarite"])
                                              for a in d["assertions"]
                                              if chevauche((a["debut"], a["fin"]), span)]})
        for x in d["elements"]:
            els_tot += 1
            if not any(chevauche((x["debut"], x["fin"]), s) for s in spans):
                els_hors += 1
                hors.append({"id": d["id"], "genre": x["genre"], "valeur": x["valeur"],
                             "passage": texte[x["debut"]:x["fin"]]})
    res = {"elements_reference": tot, "retrouves": trouves, "rappel": round(trouves / max(1, tot), 3),
           "pertes": dict(causes.most_common()),
           "elements_de_scene": els_tot, "hors_reference": els_hors,
           "part_hors_reference": round(els_hors / max(1, els_tot), 3)}
    print(json.dumps(res, ensure_ascii=False, indent=1))
    if detail:
        json.dump({"mesure": res, "pertes": pertes, "hors_reference": hors}, open(detail, "w", encoding="utf-8"),
                  ensure_ascii=False, indent=1)


if __name__ == "__main__":
    main(*sys.argv[1:4])
