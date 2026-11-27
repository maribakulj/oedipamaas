"""Le résumé avant / après d'une correction du compilateur (outils/mesure/c3_corrections.sh).

Usage : python outils/mesure/resumer_c3.py AVANT APRES [--json SORTIE]

1. Les statuts de compilation des 200 fiches de chaque jeu, et leurs transitions.
2. La comparaison aux requêtes de référence (outils/requetes/comparer.pl) : exacte, trop_forte, trop_faible,
   incomparable, indetermine, non_prise_en_charge, echec…
3. Les quatre conditions de l'expérience croisée, par genre de texte, en catégories séparées :
     etablie (déductif) | sous_hypotheses | sans_requete | interrompue (budget : interrompu, incomplet) |
     erreur (erreur, graphe_en_erreur) | echec_semantique (inconnue, ecartee, non_certifiee, contradictoire)
   et la qualification (codage.pl) pour les conditions à requête compilée.
4. Les établissements des conditions à requête compilée qui changent entre avant et après, chacun avec sa requête,
   son statut de compilation et ses hypothèses : à juger un par un (un succès d'une requête partielle n'est jamais
   qualifié ; un succès peut être fortuit). Rien n'est jugé ici."""
import argparse
import collections
import json
from pathlib import Path

JEUX = ("vertical", "validation_m1")
CONDITIONS = ("lecteur_compilee", "lecteur_reference", "reference_compilee", "reference_reference")


def categorie(s):
    if s == "etablie":
        return "etablie"
    if s == "etablie_sous_hypotheses":
        return "sous_hypotheses"
    if s == "sans_requete":
        return "sans_requete"
    if s in ("interrompu", "incomplet"):
        return "interrompue"
    if s in ("erreur", "graphe_en_erreur", "erreur_de_qualification"):
        return "erreur"
    return "echec_semantique"


CATS = ("etablie", "sous_hypotheses", "sans_requete", "interrompue", "erreur", "echec_semantique")


def genre(g):
    return "variante" if g.startswith("variante_") else g


def charger(d, nom):
    return json.loads((Path(d) / nom).read_text(encoding="utf-8"))


def resumer(d):
    out = {"commit": (Path(d) / "commit").read_text().strip()}
    for j in JEUX:
        c = charger(d, f"compilees_{j}.json")
        cmp_ = charger(d, f"comparaison_{j}.json")
        x = charger(d, f"croise_{j}.json")
        r = {"statuts": dict(collections.Counter(e["statut"] for e in c)),
             "comparaison": dict(collections.Counter(str(e["verdict"]) for e in cmp_)),
             "conditions": {}, "qualification": {}}
        for cond in CONDITIONS:
            t = collections.defaultdict(collections.Counter)
            q = collections.defaultdict(collections.Counter)
            for e in x:
                v = e["conditions"][cond]
                t[genre(e["genre"])][categorie(v["satisfaction"])] += 1
                q[genre(e["genre"])][str(v["qualification"])] += 1
            r["conditions"][cond] = {g: {k: n[k] for k in CATS} for g, n in t.items()}
            r["qualification"][cond] = {g: dict(n) for g, n in q.items()}
        out[j] = r
    return out


def changements(av, ap):
    """Les textes dont la catégorie change, dans une condition à requête compilée."""
    lignes = []
    for j in JEUX:
        A = {(e["k"], e["genre"]): e for e in charger(av, f"croise_{j}.json")}
        B = {(e["k"], e["genre"]): e for e in charger(ap, f"croise_{j}.json")}
        C = {e["k"]: e for e in charger(ap, f"compilees_{j}.json")}
        for k in sorted(A):
            for cond in ("lecteur_compilee", "reference_compilee"):
                a, b = A[k]["conditions"][cond], B[k]["conditions"][cond]
                if categorie(a["satisfaction"]) != categorie(b["satisfaction"]):
                    lignes.append({"jeu": j, "k": k[0], "genre": k[1], "notation": A[k]["notation"], "condition": cond,
                                   "avant": a["satisfaction"], "apres": b["satisfaction"],
                                   "qualification_apres": b["qualification"], "statut_compilation": C[k[0]]["statut"],
                                   "requete": C[k[0]]["suffisante"], "hypotheses": b.get("hypotheses", [])})
    return lignes


def main():
    ap_ = argparse.ArgumentParser()
    ap_.add_argument("avant")
    ap_.add_argument("apres")
    ap_.add_argument("--json")
    a = ap_.parse_args()
    R = {"avant": resumer(a.avant), "apres": resumer(a.apres), "changements": changements(a.avant, a.apres)}
    print(f"avant {R['avant']['commit']} ; après {R['apres']['commit']}")
    for j in JEUX:
        print(f"\n# {j}")
        for cle in ("statuts", "comparaison"):
            print(f"  {cle} : avant {R['avant'][j][cle]}\n  {' ' * len(cle)}   après {R['apres'][j][cle]}")
        for cond in CONDITIONS:
            for g in ("positif", "negatif", "indetermine", "variante"):
                av = R["avant"][j]["conditions"][cond].get(g)
                apr = R["apres"][j]["conditions"][cond].get(g)
                if av:
                    print(f"  {cond:20} {g:12} " + " | ".join(f"{c} {av[c]}→{apr[c]}" for c in CATS))
    print("\n# changements (conditions à requête compilée)")
    for l in R["changements"]:
        print(f"  {l['jeu'][:3]} {l['k']} {l['genre']} {l['notation']} {l['condition']} : {l['avant']} → {l['apres']}"
              f" ({l['statut_compilation']}, {l['qualification_apres']}) {l['hypotheses']}\n      {l['requete'][:200]}")
    if a.json:
        Path(a.json).write_text(json.dumps(R, ensure_ascii=False, indent=1), encoding="utf-8")


if __name__ == "__main__":
    main()
