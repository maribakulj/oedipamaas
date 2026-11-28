"""Fermeture des use_module internes (modules .pl de oedipamaas/socle) à partir de points d'entrée. Lecture seule."""
import re, sys, pathlib
S = pathlib.Path("/home/user/oedipamaas-v3-wt/oedipamaas/socle")
mods = {p.stem: p for p in S.glob("*.pl")}
def deps(p):
    t = p.read_text(encoding="utf-8")
    out = set()
    for m in re.finditer(r":-\s*(?:use_module|ensure_loaded|consult)\(\s*([a-z_][a-z0-9_]*)\s*(?:,|\))", t):
        if m.group(1) in mods: out.add(m.group(1))
    # références qualifiées module:pred (chargement dynamique éventuel) : on ne les compte pas comme chargement
    return out
G = {m: deps(p) for m, p in mods.items()}
def closure(starts):
    seen = set(); st = list(starts)
    while st:
        x = st.pop()
        if x in seen or x not in G: continue
        seen.add(x); st += list(G[x])
    return seen
def lines(ms): return sum(len([l for l in mods[m].read_text(encoding='utf-8').splitlines()]) for m in ms)
for nom, starts in [("CLI (oedipamaas.pl)", ["oedipamaas"]), ("codage (noyau + compilateur)", ["codage"]),
                    ("noyau seul (satisfaction+verificateur+requetes+assertions)", ["satisfaction","verificateur","requetes","assertions"]),
                    ("definitions+requetes_iconclass", ["definitions","requetes_iconclass"])]:
    c = closure(starts)
    print(nom, len(c), "fichiers,", lines(c), "lignes :", " ".join(sorted(c)))
tous = set(mods)
atteints = closure(["oedipamaas","codage","definitions","requetes_iconclass","inclusion","satisfaction_reference","normalisation","interpretation"])
print("\nnon atteints par ces entrées :", " ".join(sorted(tous-atteints)))
