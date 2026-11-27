"""La comparaison appariée de deux lectures du banc (27/11) : les mêmes fiches tirées pour les deux.

Usage : python outils/graphes/apparier.py REFERENCES.json GRAPHES_A.json GRAPHES_B.json [--tirages N] [--json SORTIE]
          [--attendus TEXTES.json PAS] [--premisses PREM_REF.json PREM_A.json PREM_B.json]

La présence (27/11) : chaque texte de la référence doit être dans A et dans B, et aucun texte de A ou de B hors de la
référence ; avec --attendus, chaque texte de l'échantillon (une fiche sur PAS de TEXTES.json : positif, négatif,
indéterminé, variantes) doit être dans la référence. Un défaut, et rien n'est calculé. Les graphes en erreur de chaque
côté sont comptés et dits (un graphe en erreur compte comme un graphe vide, jamais comme un texte absent).
--premisses : les sorties de premisses.pl pour la référence, A et B ; les mesures de l'admissibilité effective (les
prémisses que le noyau admet, porteurs, participants et événement d'un rôle compris) sont alors appariées aussi, et
le jalon est jugé sur elles comme sur les annotations.

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
               "surete:taux_promotion_effectif", "surete:couverture_effective", "surete:precision_effective",
               "surete:taux_promotion_effectif_roles", "surete:couverture_effective_roles",
               "surete:precision_effective_roles",
               "structure:roles", "qualifiee:roles", "structure:relations", "qualifiee:relations",
               "structure:entites", "qualifiee:entites", "structure:evenements", "qualifiee:evenements",
               "qualificatif:negations", "qualificatif:modalites", "qualificatif:portees", "qualificatif:citations",
               "structure:nombres")


def par_texte(R, G, premisses=None):
    return cg.evaluer(R, G, premisses=premisses)[6]


def textes_attendus(textes, pas):
    """Les textes de l'échantillon : une fiche sur PAS, chacun de ses textes (comme outils/mesure/reunir_tranches.py)."""
    out = set()
    for i, f in enumerate(textes):
        if i % pas:
            continue
        for g in ("positif", "negatif", "indetermine"):
            if g in f:
                out.add((f["k"], g))
        for g in (f.get("variantes") or {}):
            out.add((f["k"], f"variante_{g}"))
    return out


def controler_presence(R, A, B, attendus=None):
    defauts = []
    for nom, G in (("A", A), ("B", B)):
        manque = sorted(set(R) - set(G))
        hors = sorted(set(G) - set(R))
        if manque:
            defauts.append(f"{len(manque)} textes de la référence absents de {nom} : {manque[:5]}")
        if hors:
            defauts.append(f"{len(hors)} textes de {nom} hors de la référence : {hors[:5]}")
    if attendus is not None:
        manque = sorted(attendus - set(R))
        if manque:
            defauts.append(f"{len(manque)} textes attendus absents de la référence : {manque[:5]}")
    erreurs = {nom: sorted(k for k, x in G.items() if x.get("faits") == "erreur") for nom, G in (("A", A), ("B", B))}
    return defauts, erreurs


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("references")
    ap.add_argument("graphes_a")
    ap.add_argument("graphes_b")
    ap.add_argument("--tirages", type=int, default=1000)
    ap.add_argument("--json")
    ap.add_argument("--attendus", nargs=2, metavar=("TEXTES", "PAS"))
    ap.add_argument("--premisses", nargs=3, metavar=("PREM_REF", "PREM_A", "PREM_B"))
    a = ap.parse_args()
    R = {cg.cle(x): x for x in cg.charger(a.references)}
    A = {cg.cle(x): x for x in cg.charger(a.graphes_a)}
    B = {cg.cle(x): x for x in cg.charger(a.graphes_b)}
    att = textes_attendus(cg.charger(a.attendus[0]), int(a.attendus[1])) if a.attendus else None
    defauts, erreurs = controler_presence(R, A, B, att)
    if defauts:
        raise SystemExit("\n".join(defauts))
    pa = pb = None
    if a.premisses:
        Pr, Pa, Pb = ({cg.cle(x): x for x in cg.charger(f)} for f in a.premisses)
        pa, pb = (Pr, Pa), (Pr, Pb)
    app = cg.intervalles_apparies(par_texte(R, A, pa), par_texte(R, B, pb), a.tirages)
    j = cg.jalon(app)
    je = cg.jalon(app, effectif=True) if a.premisses else None
    print(f"{len(R)} textes présents des deux côtés{' (échantillon complet)' if att is not None else ''} ; graphes en "
          f"erreur : A {len(erreurs['A'])}, B {len(erreurs['B'])}")
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
          f"{'ATTEINT' if j['atteint'] else 'non atteint'} (sur les annotations)")
    if je is not None:
        r = app["rapport_promotion_effectif"]
        print(f"Rapport des promotions effectives B / A : {'[%.2f ; %.2f]' % tuple(r) if r else '—'} ; jalon sur les "
              f"prémisses du noyau : {'ATTEINT' if je['atteint'] else 'non atteint'}")
    if a.json:
        Path(a.json).write_text(json.dumps({"apparie": app, "jalon": j, "jalon_effectif": je, "erreurs": erreurs},
                                           ensure_ascii=False, indent=1), encoding="utf-8")


if __name__ == "__main__":
    main()
