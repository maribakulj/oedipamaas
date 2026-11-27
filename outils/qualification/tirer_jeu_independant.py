"""Le tirage du jeu de qualification indépendant (docs/QUALIFICATION_SEMANTIQUE.md, § 4).

Usage : python outils/qualification/tirer_jeu_independant.py LIBELLES_EN_DIR LIBELLES_FR.tsv SORTIE.json
            --exclure FICHIER [FICHIER …] [--graine G] [--n 400] [--n-textes 100]

L'exclusion : toute notation qui apparaît dans un des fichiers consultés (une valeur de chaîne d'un JSON ou JSONL,
ou un mot d'un fichier texte, égale à une notation d'Iconclass), ET tout ancêtre d'une notation exclue (un préfixe),
ET tout descendant direct (un caractère de plus, ou un nom entre parenthèses : une mise au point sur un parent fuit
vers l'enfant). Exclure tous les descendants retirerait des divisions entières (un code court exclu comme 25H). Les rubriques (deux caractères au plus) sont exclues aussi : elles n'ont pas de condition propre.
Le tirage : stratifié par division (le premier caractère, 0 à 9), proportionnel à la taille de la strate restante,
avec la graine donnée ; puis un sous-ensemble pour les textes, tiré de même. La sortie donne, pour chaque notation,
ses libellés anglais et français, sa strate, et si elle est dans le sous-ensemble des textes ; et l'empreinte SHA-256
de son contenu, à publier dans le dépôt sans le contenu.
Les bancs scellés ne sont pas lus : l'exclusion de leurs notations est à faire par la propriétaire
(--exclure sur leurs références), et l'empreinte change alors."""
import argparse
import collections
import glob
import hashlib
import json
import random
import re
from pathlib import Path


def libelles(dossier):
    L = {}
    for f in sorted(glob.glob(str(Path(dossier) / "txt_en_*.txt"))):
        for ligne in open(f, encoding="utf-8"):
            if "|" in ligne:
                n, t = ligne.rstrip("\n").split("|", 1)
                L[n] = t
    return L


def chaines(x):
    if isinstance(x, str):
        yield x
    elif isinstance(x, dict):
        for v in x.values():
            yield from chaines(v)
    elif isinstance(x, list):
        for v in x:
            yield from chaines(v)


ANOMALIES = collections.Counter()


def notations_de(fichier, connues):
    p = Path(fichier)
    vues = set()
    if p.suffix in (".json", ".jsonl"):
        lignes = [p.read_text(encoding="utf-8")] if p.suffix == ".json" else p.read_text(encoding="utf-8").splitlines()
        for l in lignes:
            if not l.strip():
                continue
            try:
                valeurs = list(chaines(json.loads(l)))
            except json.JSONDecodeError:                # une ligne tronquée : ses chaînes entre guillemets, comptée
                ANOMALIES[str(p)] += 1
                valeurs = re.findall(r'"((?:[^"\\]|\\.)*)"', l)
            for s in valeurs:
                if s in connues:
                    vues.add(s)
                else:                                   # « requete('11H(PETER)', …) » : la notation dans une chaîne
                    for m in re.findall(r"'([^']+)'", s):
                        if m in connues:
                            vues.add(m)
    else:
        for mot in re.split(r"[\s,;|]+", p.read_text(encoding="utf-8")):
            if mot in connues:
                vues.add(mot)
    return vues


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("libelles_en")
    ap.add_argument("libelles_fr")
    ap.add_argument("sortie")
    ap.add_argument("--exclure", nargs="+", required=True)
    ap.add_argument("--graine", type=int, default=20261127)
    ap.add_argument("--n", type=int, default=400)
    ap.add_argument("--n-textes", type=int, default=100)
    a = ap.parse_args()
    en = libelles(a.libelles_en)
    fr = {}
    for l in open(a.libelles_fr, encoding="utf-8"):
        if "\t" in l:
            n, t = l.rstrip("\n").split("\t", 1)
            fr[n] = t
    connues = set(en)
    exclues = set()
    par_fichier = {}
    for f in a.exclure:
        v = notations_de(f, connues)
        par_fichier[f] = len(v)
        exclues |= v
    ex = sorted(exclues)

    def direct(e, n):                      # n est un descendant direct de e : un caractère de plus, ou un nom entre parenthèses
        r = n[len(e):]
        return n.startswith(e) and (len(r) == 1 or re.fullmatch(r"\([^()]*\)", r) is not None)

    def touche(n):
        return any(e.startswith(n) or direct(e, n) for e in ex)
    pool = [n for n in sorted(en) if len(n) > 2 and n not in exclues and not touche(n)]
    strates = collections.defaultdict(list)
    for n in pool:
        strates[n[0]].append(n)
    alea = random.Random(a.graine)
    tires = []
    for s in sorted(strates):
        k = round(a.n * len(strates[s]) / len(pool))
        tires += alea.sample(strates[s], min(k, len(strates[s])))
    tires = sorted(tires)[: a.n] if len(tires) > a.n else sorted(tires)
    textes = set(alea.sample(tires, min(a.n_textes, len(tires))))
    jeu = [{"notation": n, "strate": n[0], "libelle_en": en[n], "libelle_fr": fr.get(n), "textes": n in textes}
           for n in tires]
    contenu = json.dumps(jeu, ensure_ascii=False, indent=1, sort_keys=True)
    empreinte = hashlib.sha256(contenu.encode("utf-8")).hexdigest()
    Path(a.sortie).write_text(contenu, encoding="utf-8")
    resume = {"graine": a.graine, "notations": len(jeu), "textes": len(textes), "pool": len(pool),
              "exclues_directement": len(exclues), "exclusion_par_fichier": par_fichier,
              "lignes_illisibles": dict(ANOMALIES),
              "strates": {s: sum(1 for x in jeu if x["strate"] == s) for s in sorted(strates)}, "sha256": empreinte}
    Path(a.sortie + ".resume.json").write_text(json.dumps(resume, ensure_ascii=False, indent=1), encoding="utf-8")
    print(json.dumps({k: v for k, v in resume.items() if k != "exclusion_par_fichier"}, ensure_ascii=False))


if __name__ == "__main__":
    main()
