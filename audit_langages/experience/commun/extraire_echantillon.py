#!/usr/bin/env python3
"""Étape commune de l'expérience (audit des langages) : tirer l'échantillon et l'index du pivot.

Usage : python3 -I extraire_echantillon.py SORTIE_DIR [--n-les-deux 200 --n-wolf 100 --n-wonef 100] [--graine S]
        [--complet]                # --complet : tout, sans tirage (pour la mesure d'échelle)

Entrées (lues seulement, données non fiables, jamais exécutées) :
  /home/user/donnees/ressources/omw/omw-1.4/fra/wn-data-fra.tab          WOLF dans OMW 1.4
  /home/user/donnees/ressources/wonef/wonef-fscore-0.1.xml.bz2            WoNeF 0.1, version F-score
  /home/user/donnees/WordNet-3.0/dict/data.{noun,verb,adj,adv}            pivot WordNet 3.0

Sorties dans SORTIE_DIR :
  wolf.tab         les lignes WOLF de l'échantillon, telles quelles
  wonef.xml        les éléments SYNSET de l'échantillon, tels quels, sous <WN>…</WN>
  wn30_ids.txt     tous les identifiants « décalage-pos » de WordNet 3.0 (s → a, comme OMW) : le pivot
  MANIFESTE.json   empreintes, graine, comptes

Ce que ce script ne fait pas : aucune interprétation. Le tirage est une empreinte (sha256 de graine:identifiant), donc
indépendante du langage et de l'ordre de lecture. Il n'y a pas de repli silencieux : un fichier absent arrête le script.
"""
import argparse, bz2, hashlib, json, re, sys
from pathlib import Path

WOLF = Path("/home/user/donnees/ressources/omw/omw-1.4/fra/wn-data-fra.tab")
WONEF = Path("/home/user/donnees/ressources/wonef/wonef-fscore-0.1.xml.bz2")
WN = Path("/home/user/donnees/WordNet-3.0/dict")
ID_WONEF = re.compile(r"<ID>eng-30-(\d{8})-([nvabr])</ID>")
LITERAL = re.compile(r"<LITERAL[^>]*>([^<]*)</LITERAL>")


def sha(p):
    h = hashlib.sha256()
    with open(p, "rb") as f:
        for bloc in iter(lambda: f.read(1 << 20), b""):
            h.update(bloc)
    return h.hexdigest()


def pivot():
    ids = []
    for nom, defaut in (("data.noun", "n"), ("data.verb", "v"), ("data.adj", "a"), ("data.adv", "r")):
        with open(WN / nom, encoding="utf-8") as f:
            for ligne in f:
                if ligne[:1].isdigit():
                    champs = ligne.split(" ", 3)
                    pos = champs[2]
                    ids.append(f"{champs[0]}-{'a' if pos == 's' else pos}")
    return sorted(ids)


def pos_omw(p):                       # WoNeF (BalkaNet) note les adverbes « b », OMW « r »
    return "r" if p == "b" else p


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("sortie")
    ap.add_argument("--n-les-deux", type=int, default=200)
    ap.add_argument("--n-wolf", type=int, default=100)
    ap.add_argument("--n-wonef", type=int, default=100)
    ap.add_argument("--graine", default="audit-langages-1")
    ap.add_argument("--complet", action="store_true")
    a = ap.parse_args()
    out = Path(a.sortie)
    out.mkdir(parents=True, exist_ok=False)          # un dossier neuf, jamais écrasé

    wolf = {}                                         # synset -> [lignes]
    for ligne in open(WOLF, encoding="utf-8"):
        if ligne.startswith("#"):
            continue
        c = ligne.rstrip("\n").split("\t")
        if len(c) == 3 and c[1] == "fra:lemma":
            wolf.setdefault(c[0], []).append(ligne if ligne.endswith("\n") else ligne + "\n")
    wonef = {}                                        # synset -> ligne XML
    with bz2.open(WONEF, "rt", encoding="utf-8") as f:
        for ligne in f:
            m = ID_WONEF.search(ligne)
            if m and ligne.startswith("<SYNSET>"):
                sid = f"{m.group(1)}-{pos_omw(m.group(2))}"
                # un synset n'a de lexicalisation que s'il a un littéral autre que _EMPTY_
                if any(x != "_EMPTY_" for x in LITERAL.findall(ligne)):
                    wonef[sid] = ligne if ligne.endswith("\n") else ligne + "\n"
    deux = sorted(set(wolf) & set(wonef))
    seul_wolf = sorted(set(wolf) - set(wonef))
    seul_wonef = sorted(set(wonef) - set(wolf))

    def tirer(liste, n):
        cle = lambda s: hashlib.sha256(f"{a.graine}:{s}".encode()).hexdigest()
        return sorted(liste, key=cle)[:n]

    if a.complet:
        choisis = set(deux) | set(seul_wolf) | set(seul_wonef)
    else:
        choisis = set(tirer(deux, a.n_les_deux)) | set(tirer(seul_wolf, a.n_wolf)) | set(tirer(seul_wonef, a.n_wonef))
    with open(out / "wolf.tab", "w", encoding="utf-8") as f:
        for s in sorted(choisis & set(wolf)):
            f.writelines(wolf[s])
    with open(out / "wonef.xml", "w", encoding="utf-8") as f:
        f.write("<?xml version='1.0' encoding='UTF-8'?>\n<WN>")
        for s in sorted(choisis & set(wonef)):
            f.write(wonef[s])
        f.write("</WN>\n")
    ids = pivot()
    (out / "wn30_ids.txt").write_text("\n".join(ids) + "\n", encoding="utf-8")
    man = {
        "graine": a.graine, "complet": a.complet,
        "strates": {"les_deux": len(deux), "wolf_seul": len(seul_wolf), "wonef_seul": len(seul_wonef)},
        "tires": {"synsets": len(choisis), "avec_wolf": len(choisis & set(wolf)), "avec_wonef": len(choisis & set(wonef))},
        "entrees": {"wolf": str(WOLF), "wolf_sha256": sha(WOLF), "wonef": str(WONEF), "wonef_sha256": sha(WONEF),
                    "wordnet": str(WN),
                    "wordnet_sha256_noun_verb_adj_adv_concatenes": hashlib.sha256(
                        b"".join(bytes.fromhex(sha(WN / n)) for n in ("data.noun", "data.verb", "data.adj", "data.adv"))
                    ).hexdigest()},
        "sorties_sha256": {n: sha(out / n) for n in ("wolf.tab", "wonef.xml", "wn30_ids.txt")},
        "pivot_ids": len(ids),
    }
    (out / "MANIFESTE.json").write_text(json.dumps(man, indent=1, ensure_ascii=False) + "\n", encoding="utf-8")
    print(json.dumps({k: man[k] for k in ("strates", "tires", "pivot_ids")}, ensure_ascii=False))


if __name__ == "__main__":
    main()
