"""La comparaison appariée de deux lectures du banc (27/11) : les mêmes fiches tirées pour les deux.

Usage : python outils/graphes/apparier.py REFERENCES.json GRAPHES_A.json GRAPHES_B.json [--tirages N] [--json SORTIE]

A est la lecture de comparaison (le lecteur actuel), B la lecture candidate. Pour chaque mesure du comparateur
(comparer_graphes.py : F1 structure et qualifiée de chaque catégorie, taux de promotion, couverture et précision des
assertions admissibles), la valeur de A, celle de B, et l'intervalle à 95 % de la différence B − A par rééchantillonnage
des fiches, apparié : tous les textes d'une fiche sont tirés ensemble, et les mêmes fiches pour A et B. Pour le taux de
promotion, l'intervalle du rapport B / A. Puis le premier jalon de C7 (validé le 27/11) : les promotions au moins
divisées par deux (borne haute du rapport ≤ 0,5) et au plus cinq points de couverture perdus (borne basse de la
différence ≥ −0,05)."""
import argparse
import importlib.util
import json
from pathlib import Path

spec = importlib.util.spec_from_file_location("cg", Path(__file__).resolve().parent / "comparer_graphes.py")
cg = importlib.util.module_from_spec(spec)
spec.loader.exec_module(cg)

PRINCIPALES = ("surete:taux_promotion", "surete:couverture_admissible", "surete:precision_admissible",
               "structure:roles", "qualifiee:roles", "structure:relations", "qualifiee:relations",
               "structure:entites", "qualifiee:entites", "structure:evenements", "qualifiee:evenements",
               "qualificatif:negations", "qualificatif:modalites", "qualificatif:portees", "qualificatif:citations",
               "structure:nombres")


def par_texte(R, G):
    return cg.evaluer(R, G)[6]


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("references")
    ap.add_argument("graphes_a")
    ap.add_argument("graphes_b")
    ap.add_argument("--tirages", type=int, default=1000)
    ap.add_argument("--json")
    a = ap.parse_args()
    R = {cg.cle(x): x for x in cg.charger(a.references)}
    A = {cg.cle(x): x for x in cg.charger(a.graphes_a)}
    B = {cg.cle(x): x for x in cg.charger(a.graphes_b)}
    if set(A) != set(B):
        raise SystemExit(f"les deux lectures n'ont pas les mêmes textes : {len(set(A) ^ set(B))} de différence")
    app = cg.intervalles_apparies(par_texte(R, A), par_texte(R, B), a.tirages)
    j = cg.jalon(app)
    print(f"{app['fiches']} fiches, {app['tirages']} tirages appariés (graine {app['graine']})\n")
    print("| mesure | A | B | B − A (95 %) |\n|---|---|---|---|")
    for nom in PRINCIPALES:
        if nom in app["a"] and nom in app["b"] and nom in app["difference"]:
            b, h = app["difference"][nom]
            print(f"| {nom} | {app['a'][nom]:.3f} | {app['b'][nom]:.3f} | [{b:+.3f} ; {h:+.3f}] |")
    r = app["rapport_promotion"]
    print(f"\nRapport des promotions B / A : {'[%.2f ; %.2f]' % tuple(r) if r else '—'}")
    print(f"Jalon : promotions divisées par deux {'oui' if j['promotions_divisees_par_deux'] else 'non'} ; "
          f"couverture gardée (−5 points au plus) {'oui' if j['couverture_gardee'] else 'non'} ; "
          f"{'ATTEINT' if j['atteint'] else 'non atteint'}")
    if a.json:
        Path(a.json).write_text(json.dumps({"apparie": app, "jalon": j}, ensure_ascii=False, indent=1), encoding="utf-8")


if __name__ == "__main__":
    main()
