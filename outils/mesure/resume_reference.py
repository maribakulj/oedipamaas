"""Le résumé de la mesure de référence (outils/mesure/reference_d30.sh) : des tableaux en Markdown.

Usage : python outils/mesure/resume_reference.py SORTIE

Pour chaque jeu et chaque réglage du codage : le statut de la notation visée par genre de texte ; le nombre moyen de
codes de chaque statut par texte ; la part des textes au délai ou en erreur ; les temps (médiane, 95e centile) ; le
nombre moyen de codes conditionnels dont une preuve suppose un sens (D30). Pour le comparateur : les verdicts des
requêtes compilées, avec et sans normalisation. Rien n'est jugé ici : ce sont des comptes."""
import collections
import json
import statistics
import sys
from pathlib import Path

JEUX = {"vertical": "développement", "validation_m1": "validation"}
REGLAGES = {"d30": "D30, normalisation", "d30_sans_norm": "D30, sans normalisation",
            "premier_sens": "premier sens (anglais), normalisation"}
GENRES = ("positif", "negatif", "indetermine")
STATUTS = ("etabli", "etablissable", "candidat", "conditionnel", "contradictoire", "non_certifie",
           "suffisante_ecartee", "sans_suffisante", "incomplet", "rejete_par_le_verificateur")


def centile(xs, p):
    xs = sorted(xs)
    return xs[min(len(xs) - 1, int(round(p * (len(xs) - 1))))] if xs else 0.0


def codage(sortie):
    print("## Codage de bout en bout\n")
    for jeu, nom in JEUX.items():
        print(f"### {nom}\n")
        print("| réglage | genre | visée : " + " / ".join(["établie", "établissable", "candidate", "conditionnelle",
              "autre", "absente", "délai", "erreur"]) + " |")
        print("|---|---|---|")
        lignes_codes, lignes_temps = [], []
        for r, rn in REGLAGES.items():
            f = sortie / f"codage_{r}_{jeu}.json"
            if not f.exists():
                continue
            R = json.loads(f.read_text(encoding="utf-8"))
            temps, comptes, nsens, ntextes = [], collections.Counter(), 0, 0
            for g in GENRES:
                c = collections.Counter()
                for fi in R:
                    v = fi.get(g, {"statut": "absent"})
                    st = v["statut"]
                    c[st if st in ("etabli", "etablissable", "candidat", "conditionnel", "absent", "delai", "erreur")
                      else "autre"] += 1
                    if "temps" in v:
                        temps.append(v["temps"])
                    if isinstance(v.get("comptes"), dict):
                        ntextes += 1
                        comptes.update(v["comptes"])
                        nsens += v.get("conditionnels_par_sens", 0)
                print(f"| {rn} | {g} | " + " / ".join(str(c[k]) for k in ("etabli", "etablissable", "candidat",
                      "conditionnel", "autre", "absent", "delai", "erreur")) + " |")
            n = max(ntextes, 1)
            lignes_codes.append(f"| {rn} | {ntextes} | " + " | ".join(f"{comptes[s] / n:.1f}" for s in STATUTS)
                                + f" | {nsens / n:.1f} |")
            lignes_temps.append(f"| {rn} | {statistics.median(temps) if temps else 0:.1f} | {centile(temps, .95):.1f} |"
                                f" {max(temps) if temps else 0:.1f} |")
        print("\nCodes par texte (moyenne sur les textes codés) :\n")
        print("| réglage | textes | " + " | ".join(STATUTS) + " | conditionnels par sens supposé |")
        print("|---|---|" + "---|" * (len(STATUTS) + 1))
        print("\n".join(lignes_codes))
        print("\nTemps par texte (secondes) :\n")
        print("| réglage | médiane | 95e centile | maximum |\n|---|---|---|---|")
        print("\n".join(lignes_temps) + "\n")


def comparateur(sortie):
    print("## Comparateur (requêtes compilées contre requêtes de référence)\n")
    print("| jeu | normalisation | compilées | exactes | trop fortes | trop faibles | incomparables | indéterminées |"
          " échecs | sans référence |")
    print("|---|---|---|---|---|---|---|---|---|---|")
    for jeu, nom in JEUX.items():
        for suf, nn in (("", "oui"), ("_sans_norm", "non")):
            f = sortie / f"comparaison_{jeu}{suf}.json"
            if not f.exists():
                continue
            J = [j for j in json.loads(f.read_text(encoding="utf-8")) if j["statut"] == "compilee"]
            c = collections.Counter(j["verdict"] for j in J)
            print(f"| {nom} | {nn} | {len(J)} | {c['exacte']} | {c['trop_forte']} | {c['trop_faible']} |"
                  f" {c['incomparable']} | {c['indetermine']} | {c['echec']} | {c['sans_reference']} |")
    print()


def controle(sortie):
    print("## Accord des modes indexé et exhaustif (3 fiches par jeu)\n")
    for jeu, nom in JEUX.items():
        f = sortie / f"controle_{jeu}.json"
        if f.exists():
            c = collections.Counter(v.get("accord") for fi in json.loads(f.read_text(encoding="utf-8"))
                                    for g, v in fi.items() if g in GENRES and isinstance(v, dict))
            print(f"- {nom} : {dict(c)}")
    print()


if __name__ == "__main__":
    s = Path(sys.argv[1])
    comparateur(s)
    codage(s)
    controle(s)
