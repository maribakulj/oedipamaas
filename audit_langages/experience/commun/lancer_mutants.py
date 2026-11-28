#!/usr/bin/env python3
"""Lance le contrôle de chaque langage sur chaque mutant et compare à l'attendu (écrit à la main, jamais d'après une sortie).

Usage : python3 -I lancer_mutants.py MUTANTS_DIR WN30_IDS.txt CONTROLE_PY CONTROLE_PL RESULTAT.tsv
Rend, pour chaque mutant et chaque langage : exact (sortie = attendu), ou le détail des manques et des excès.
"""
import collections, os, subprocess, sys, time
from pathlib import Path

mut, ids, cpy, cpl, res = sys.argv[1:6]
attendus = collections.defaultdict(set)
for l in Path(mut, "attendus.tsv").read_text(encoding="utf-8").splitlines():
    m, c, i = l.split("\t")
    attendus[m].add((c, i))
env = {**os.environ, "LANG": "C.UTF-8"}
lignes = ["mutant\tlangage\tverdict\tmanquants\texcedentaires\tsecondes"]
bilan = collections.Counter()
for f in sorted(Path(mut).glob("M*.tsv")):
    nom = f.stem
    for langage, cmd in (("python", [sys.executable, "-I", cpy, "controler", str(f), ids]),
                         ("prolog", ["swipl", cpl, "controler", str(f), ids])):
        t0 = time.perf_counter()
        r = subprocess.run(cmd, capture_output=True, text=True, env=env)
        dt = time.perf_counter() - t0
        if r.returncode not in (0, 1):
            lignes.append(f"{nom}\t{langage}\tERREUR\t{r.stderr.strip()[:80]}\t\t{dt:.3f}"); bilan[(langage, "erreur")] += 1; continue
        obtenu = {tuple(x.split("\t")) for x in r.stdout.splitlines() if x}
        att = attendus.get(nom.split("_")[0] + "", set()) if False else {a for k, v in attendus.items() if nom.startswith(k) for a in v}
        man, exc = att - obtenu, obtenu - att
        verdict = "exact" if not man and not exc else "ECART"
        bilan[(langage, verdict)] += 1
        lignes.append(f"{nom}\t{langage}\t{verdict}\t{len(man)}\t{len(exc)}\t{dt:.3f}")
Path(res).write_text("\n".join(lignes) + "\n", encoding="utf-8")
print("\n".join(lignes))
print(dict(bilan))
