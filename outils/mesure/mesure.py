"""Mesure de référence (jalon J0.11) sur le corpus moissonné (outils/moisson/moisson.py) : partie « dev » seulement ;
la partie « test » n'est jamais lue ici.

  preparer CORPUS.jsonl DOSSIER [--n 1000] [--langue en]
      tire N œuvres de la partie dev qui ont un titre dans la langue (tirage par empreinte de l'identifiant, stable),
      écrit une description par œuvre (DOSSIER/descriptions/<id>.json, le titre comme sujet) et les codes de
      référence (DOSSIER/reference.jsonl)
  evaluer REFERENCE.jsonl SORTIE_CODER.jsonl [SORTIE_CANDIDATS.jsonl]
      BM25 (classement du socle, socle/coder.py) : F1 exact et H-F1 (Kiritchenko, préfixes par jetons) des k premiers ;
      rappel des candidats (socle/candidats.py) : part des codes de référence proposés exactement, et part couverte
      hiérarchiquement (H-rappel de l'ensemble des candidats) ; la division 86 est écartée des deux côtés.

Les codes de référence sont ceux du catalogue : un code juste absent du catalogue compte comme faux (§ 12.2 du cahier
des charges) ; ces chiffres servent de ligne de base, pas de mesure de la précision des codes établis.
"""
import argparse
import hashlib
import json
import random
import re
import sys
from pathlib import Path

PART = re.compile(r"\d\d?[A-Z]{0,2}\d*(?:\([^)]*\)\d*)*")
JETON = re.compile(r"\([^)]*\)|[A-Z]{1,2}|\d")


NOM = re.compile(r"\(([^+][^)]*)\)")


def normaliser(code):
    """Les noms entre parenthèses en capitales, comme Iconclass les écrit : un catalogue écrit « 11H(Jerome) »,
    Iconclass « 11H(JEROME) » ; les clés « (+…) » ne changent pas."""
    return NOM.sub(lambda m: "(" + m.group(1).upper() + ")", code.strip())


def prefixes(code):
    """Les nœuds affirmés par un code, par jetons (comme decision:prefixes/2 et la mesure du moteur)."""
    code = normaliser(code)
    out = {code}
    if all(PART.fullmatch(p) for p in code.split(":")):
        for p in code.split(":"):
            cur = ""
            for t in JETON.findall(p):
                cur += t
                out.add(cur)
    return out


def fermeture(codes):
    s = set()
    for c in codes:
        s |= prefixes(c)
    return s


def garder(code):
    return not code.startswith("86")


def f1(p, r):
    return 0.0 if p + r == 0 else 2 * p * r / (p + r)


def prf(pred, ref):
    pred, ref = {normaliser(c) for c in pred}, {normaliser(c) for c in ref}
    if not pred or not ref:
        return 0.0, 0.0, 0.0
    tp = len(pred & ref)
    p, r = tp / len(pred), tp / len(ref)
    return p, r, f1(p, r)


def lire_jsonl(chemin):
    with open(chemin, encoding="utf-8") as f:
        return [json.loads(x) for x in f if x.strip()]


def nom_fichier(ident):
    return ident.replace(":", "_")


def preparer(corpus, dossier, n=1000, langue="en"):
    d = Path(dossier)
    (d / "descriptions").mkdir(parents=True, exist_ok=True)
    oeuvres = [o for o in lire_jsonl(corpus) if o["partie"] == "dev" and langue in o["titres"]
               and any(garder(c) for c in o["codes"])]
    oeuvres.sort(key=lambda o: hashlib.sha256(o["id"].encode()).hexdigest())
    choix = sorted(oeuvres[:n], key=lambda o: o["id"])
    with open(d / "reference.jsonl", "w", encoding="utf-8") as ref:
        for o in choix:
            desc = {"subject": {"title": o["titres"][langue]}}
            (d / "descriptions" / f"{nom_fichier(o['id'])}.json").write_text(json.dumps(desc, ensure_ascii=False))
            ref.write(json.dumps({"image": nom_fichier(o["id"]), "source": o["source"], "titre": o["titres"][langue],
                                  "codes": sorted(c for c in o["codes"] if garder(c))}, ensure_ascii=False) + "\n")
    print(json.dumps({"oeuvres_dev_avec_titre": len(oeuvres), "tirees": len(choix), "langue": langue}))


def intervalle(valeurs, tirages=1000, graine=0):
    """Intervalle à 95 % de la moyenne par rééchantillonnage (graine fixe : rejouable)."""
    if not valeurs:
        return [0.0, 0.0]
    g = random.Random(graine)
    n = len(valeurs)
    moy = sorted(sum(g.choice(valeurs) for _ in range(n)) / n for _ in range(tirages))
    return [round(moy[int(0.025 * tirages)], 4), round(moy[int(0.975 * tirages) - 1], 4)]


def evaluer(reference, sortie_coder, sortie_candidats=None, ks=(1, 3, 5, 10)):
    ref = {r["image"]: r["codes"] for r in lire_jsonl(reference)}
    res = {"images": len(ref), "bm25": {}, "candidats": None}
    coder = {l["image"]: l for l in lire_jsonl(sortie_coder)}
    for k in ks:
        ex, hf = [], []
        for im, codes in ref.items():
            pred = [c["code"] for c in coder.get(im, {}).get("codes", []) if garder(c["code"])][:k]
            ex.append(prf(pred, codes)[2])
            hf.append(prf(fermeture(pred), fermeture(codes))[2])
        res["bm25"][f"k{k}"] = {"f1_exact": round(sum(ex) / len(ex), 4), "f1_exact_ic95": intervalle(ex),
                                "h_f1": round(sum(hf) / len(hf), 4), "h_f1_ic95": intervalle(hf)}
    res["erreurs_coder"] = sum(1 for l in coder.values() if "erreur" in l)
    if sortie_candidats:
        cands = {l["image"]: l for l in lire_jsonl(sortie_candidats)}
        rap, hrap, nb = [], [], []
        for im, codes in ref.items():
            pred = {c["code"] for c in cands.get(im, {}).get("codes", []) if garder(c["code"])}
            nb.append(len(pred))
            rap.append(len(pred & set(codes)) / len(codes))
            fr = fermeture(codes)
            hrap.append(len(fermeture(pred) & fr) / len(fr))
        res["candidats"] = {"rappel_exact": round(sum(rap) / len(rap), 4), "rappel_exact_ic95": intervalle(rap),
                            "h_rappel": round(sum(hrap) / len(hrap), 4), "h_rappel_ic95": intervalle(hrap),
                            "candidats_par_image": round(sum(nb) / len(nb), 1),
                            "erreurs": sum(1 for l in cands.values() if "erreur" in l)}
    print(json.dumps(res, ensure_ascii=False, indent=1))
    return res


if __name__ == "__main__":
    a = argparse.ArgumentParser(description=__doc__.split("\n")[0])
    s = a.add_subparsers(dest="cmd", required=True)
    p = s.add_parser("preparer")
    p.add_argument("corpus")
    p.add_argument("dossier")
    p.add_argument("--n", type=int, default=1000)
    p.add_argument("--langue", default="en")
    e = s.add_parser("evaluer")
    e.add_argument("reference")
    e.add_argument("sortie_coder")
    e.add_argument("sortie_candidats", nargs="?")
    x = a.parse_args()
    if x.cmd == "preparer":
        preparer(x.corpus, x.dossier, x.n, x.langue)
    else:
        evaluer(x.reference, x.sortie_coder, x.sortie_candidats)
    sys.exit(0)
