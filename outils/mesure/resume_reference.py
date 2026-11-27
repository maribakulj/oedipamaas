"""Le résumé de la mesure de référence (outils/mesure/reference_d30.sh) : des tableaux en Markdown.

Usage : python outils/mesure/resume_reference.py SORTIE

Pour chaque jeu et chaque réglage du codage (SORTIE/codage_REGLAGE_JEU.json, réunis par reunir_tranches.py) :
  - le statut de la notation visée, par genre de texte ;
  - le nombre moyen de codes de chaque statut par texte, sur les textes codés, et sur les textes codés dans tous les
    réglages (un texte interrompu n'a pas de comptes : sans cela, chaque réglage est moyenné sur d'autres textes) ;
  - le nombre moyen de preuves, parmi celles des codes conditionnels, qui supposent un sens (D30 ; un code peut en avoir
    plusieurs : ce n'est pas un nombre de codes) ;
  - les performances : temps processeur et inférences de la lecture et du codage (médiane, 95e centile, maximum), le
    temps de mur, la taille des graphes ;
  - les interruptions : leur nombre par cause (budget d'inférences, garde-fou de mur), par phase, par langue, par genre,
    par longueur du texte.
Pour le comparateur : les verdicts des requêtes compilées, avec et sans normalisation. Rien n'est jugé ici."""
import collections
import json
import statistics
import sys
from pathlib import Path

JEUX = {"vertical": "développement", "validation_m1": "validation"}
REGLAGES = {"d30": "D30, normalisation", "d30_sans_norm": "D30, sans normalisation",
            "premier_sens": "premier sens (anglais), normalisation"}
GENRES_VISES = ("positif", "negatif", "indetermine")
STATUTS = ("etabli", "etablissable", "candidat", "conditionnel", "contradictoire", "non_certifie",
           "suffisante_ecartee", "sans_suffisante", "incomplet", "rejete_par_le_verificateur")


def centile(xs, p):
    xs = sorted(xs)
    return xs[min(len(xs) - 1, int(round(p * (len(xs) - 1))))] if xs else 0.0


def stats(xs, fmt="{:.1f}"):
    if not xs:
        return "— / — / —"
    return " / ".join(fmt.format(x) for x in (statistics.median(xs), centile(xs, .95), max(xs)))


def resultats(f):
    """[(k, genre, langue, résultat)] de tous les textes (variantes comprises)."""
    out = []
    for fi in json.loads(f.read_text(encoding="utf-8")):
        for g, v in fi.items():
            if isinstance(v, dict) and "statut" in v:
                out.append((fi["k"], g, fi["langue"], v))
    return out


def longueurs(entree):
    """La longueur (caractères) de chaque texte du jeu de données (l'entrée de la passe), si on la trouve."""
    L = {}
    p = Path(entree) if entree else None
    if p and p.exists():
        for fi in json.loads(p.read_text(encoding="utf-8")):
            for g in GENRES_VISES:
                if g in fi:
                    L[(fi["k"], g)] = len(fi[g])
            for g, t in (fi.get("variantes") or {}).items():
                L[(fi["k"], f"variante_{g}")] = len(t)
    return L


def tranche_l(n):
    return "<200" if n < 200 else ("200–499" if n < 500 else "≥500")


def codage(sortie):
    print("## Codage de bout en bout\n")
    for jeu, nom in JEUX.items():
        R = {r: resultats(sortie / f"codage_{r}_{jeu}.json") for r in REGLAGES
             if (sortie / f"codage_{r}_{jeu}.json").exists()}
        if not R:
            continue
        print(f"### {nom}\n")
        entree = None
        for r in R:
            p = sortie / f"codage_{r}_{jeu}.json.passe.json"
            if p.exists():
                P = json.loads(p.read_text(encoding="utf-8"))
                entree = P.get("entree")
                print(f"- {REGLAGES[r]} : commit {P['commit'][:7]}, réglage {P['reglage']}, {P['processeurs']} "
                      f"processeurs, {len(P.get('tranches', [])) or 1} tranche(s)")
        print("\nNotation visée :\n")
        print("| réglage | genre | établie | établissable | candidate | conditionnelle | autre | absente | interrompu |"
              " erreur |")
        print("|---|---|---|---|---|---|---|---|---|---|")
        for r, X in R.items():
            for g in GENRES_VISES:
                c = collections.Counter()
                for k, g2, l, v in X:
                    if g2 == g:
                        st = v["statut"]
                        c[st if st in ("etabli", "etablissable", "candidat", "conditionnel", "absent", "interrompu",
                                       "erreur") else "autre"] += 1
                print(f"| {REGLAGES[r]} | {g} | " + " | ".join(str(c[s]) for s in (
                    "etabli", "etablissable", "candidat", "conditionnel", "autre", "absent", "interrompu", "erreur"))
                      + " |")
        codes = {r: {(k, g): v for k, g, l, v in X if isinstance(v.get("comptes"), dict)} for r, X in R.items()}
        vues = [("sur les textes codés de chaque réglage", None)]
        if len(codes) > 1:
            communs = set.intersection(*(set(c) for c in codes.values()))
            vues.append((f"sur les {len(communs)} textes codés dans tous les réglages", communs))
        for titre, ens in vues:
            print(f"\nCodes par texte, {titre} :\n")
            print("| réglage | textes | " + " | ".join(STATUTS) + " | preuves conditionnelles supposant un sens |")
            print("|---|---|" + "---|" * (len(STATUTS) + 1))
            for r, c in codes.items():
                ts = list(c) if ens is None else [t for t in c if t in ens]
                n = max(len(ts), 1)
                cp = collections.Counter()
                for t in ts:
                    cp.update(c[t]["comptes"])
                ns = sum(c[t].get("conditionnels_par_sens", 0) for t in ts)
                print(f"| {REGLAGES[r]} | {len(ts)} | " + " | ".join(f"{cp[s] / n:.1f}" for s in STATUTS)
                      + f" | {ns / n:.1f} |")
        print("\nPerformances par texte (médiane / 95e centile / maximum ; textes interrompus compris) :\n")
        print("| réglage | lecture, cpu (s) | codage, cpu (s) | codage, millions d'inférences | mur total (s) |"
              " assertions du graphe |")
        print("|---|---|---|---|---|---|")
        for r, X in R.items():
            M = [v["mesure"] for *_, v in X if "mesure" in v]
            lc = [m["lecture"]["cpu"] for m in M if m.get("lecture")]
            cc = [m["codage"]["cpu"] for m in M if m.get("codage")]
            ci = [m["codage"]["inferences"] / 1e6 for m in M if m.get("codage")]
            mu = [m["total_mur"] for m in M]
            na = [m["assertions"] for m in M if m.get("assertions") is not None]
            print(f"| {REGLAGES[r]} | {stats(lc, '{:.2f}')} | {stats(cc)} | {stats(ci, '{:.0f}')} | {stats(mu)} |"
                  f" {stats(na, '{:.0f}')} |")
        L = longueurs(entree)
        print("\nInterruptions :\n")
        print("| réglage | textes | interrompus | cause | phase | langue | genre | par longueur (interrompus / textes) |")
        print("|---|---|---|---|---|---|---|---|")
        fmt = lambda c: ", ".join(f"{a} {b}" for a, b in sorted(c.items(), key=str)) or "—"
        for r, X in R.items():
            I = [(k, g, l, v) for k, g, l, v in X if v["statut"] == "interrompu"]
            cause = collections.Counter(v.get("interruption") for *_, v in I)
            phase = collections.Counter(v.get("phase") for *_, v in I)
            lang = collections.Counter(l for _, _, l, _ in I)
            genre = collections.Counter(g if g in GENRES_VISES else "variante" for _, g, _, _ in I)
            longu = collections.Counter(tranche_l(L[(k, g)]) for k, g, _, _ in I if (k, g) in L)
            tot_l = collections.Counter(tranche_l(L[(k, g)]) for k, g, _, _ in X if (k, g) in L)
            fl = ", ".join(f"{a} {longu.get(a, 0)}/{b}" for a, b in sorted(tot_l.items())) or "—"
            print(f"| {REGLAGES[r]} | {len(X)} | {len(I)} | {fmt(cause)} | {fmt(phase)} | {fmt(lang)} | {fmt(genre)}"
                  f" | {fl} |")
        print()


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
            c = collections.Counter(v.get("accord") for *_, v in resultats(f))
            print(f"- {nom} : {dict(c)}")
    print()


if __name__ == "__main__":
    s = Path(sys.argv[1])
    comparateur(s)
    codage(s)
    controle(s)
