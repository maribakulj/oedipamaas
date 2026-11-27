"""Le premier classement des atomes manquants (27/11), d'après la sonde des connaissances (sonder.pl) : des catégories
mécaniques, à confirmer ou corriger cas par cas : la décision finale, avec sa raison, est écrite dans les causes
(croise/causes_ref_ref.json sur la branche de données ; outils/croise/tableaux.py la contrôle).

Usage : python outils/croise/classer.py ECHECS.json SONDE.json [--json SORTIE]
Catégories d'un atome manquant :
  requete_inconnue_de_K     le mot demandé n'a aucun sens conceptuel dans K (souvent un composé : « open air ») ; pour
                            une préposition, c'est la règle (chaque mot est un de ses sens) : la classe ne dit rien
  graphe_inconnu_de_K       un mot du graphe de la même catégorie, qui contient le mot demandé ou y est contenu,
                            n'a aucun sens dans K (un composé du graphe : « parish church »)
  autre_categorie           le graphe dit le même lemme dans une autre catégorie (un prédicat pour un type)
  appuye_seul               un mot du graphe a un lien vers le mot demandé : l'atome a un appui, c'est la conjonction
                            (variables, rôles, qualificatifs) qui échoue
  sans_lien                 aucun mot du graphe ne mène au mot demandé dans K : lexique (hyperonymie, synonymie
                            manquante) ou inférence (ce que le texte implique sans le dire)
  role, nom, contrainte     un atome sans lien lexical"""
import argparse
import collections
import json
import re
from pathlib import Path


def classer_atome(a):
    if a.get("categorie") == "sans_lien_lexical":
        f = a["atome"].split("(")[0]
        return {"role": "role", "nom": "nom"}.get(f, "contrainte")
    t = a["mot"]
    ws = a.get("mots_du_graphe", [])
    if any(w["lien"] for w in ws):
        return "appuye_seul"
    if a["sens_demande"] == 0:
        return "requete_inconnue_de_K"
    if any(w["sens"] == 0 and (t in w["mot"] or w["mot"] in t) for w in ws):
        return "graphe_inconnu_de_K"
    if a.get("ailleurs"):
        return "autre_categorie"
    return "sans_lien"


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("echecs")
    ap.add_argument("sonde")
    ap.add_argument("--json")
    a = ap.parse_args()
    E = {(e["k"], e["genre"]): e for e in json.loads(Path(a.echecs).read_text(encoding="utf-8"))}
    S = json.loads(Path(a.sonde).read_text(encoding="utf-8"))
    tous = collections.Counter()
    out = []
    for s in S:
        e = E[(s["k"], s["genre"])]
        cats = [(x["atome"], classer_atome(x), x) for x in s["atomes"]]
        tous.update(c for _, c, _ in cats)
        out.append({"k": s["k"], "genre": s["genre"], "notation": s["notation"], "compilation": e["compilation"],
                    "satisfaction": e["satisfaction"], "atomes": [{"atome": at, "classe": c} for at, c, _ in cats]})
        print(f"\n{s['k']} {s['genre']} {s['notation']} ({e['compilation']}, {e['satisfaction']})")
        print(f"  {e['texte'][:200]}")
        for at, c, x in cats:
            det = ""
            if "mots_du_graphe" in x:
                det = f" | K:{x['mot']}={x['sens_demande']} sens ; graphe : " + ", ".join(
                    f"{w['mot']}({w['sens']}{'→' if w['lien'] else ''})" for w in x["mots_du_graphe"][:8])
                if x.get("ailleurs"):
                    det += f" ; ailleurs : {[w['mot'] + '/' + w['categorie'] for w in x['ailleurs']]}"
            print(f"  - {at} : {c}{det}")
        if not cats:
            print("  - aucun atome manquant : la conjonction échoue")
    print("\n", dict(tous))
    if a.json:
        Path(a.json).write_text(json.dumps(out, ensure_ascii=False, indent=1), encoding="utf-8")


if __name__ == "__main__":
    main()
