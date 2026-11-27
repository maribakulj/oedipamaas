"""Les décisions de non-admissibilité d'une lecture B, jugées contre la référence (27/11).

Usage : python outils/graphes/decisions_qualificatifs.py REFERENCES.json GRAPHES_A.json GRAPHES_B.json [SEUIL] [exemples]

Pour chaque entité ou événement que B rend non admissible alors que A le laissait admissible : la correspondante de
référence (l'alignement du comparateur, outils/graphes/comparer_graphes.py) est-elle non admissible (décision juste),
admissible (décision fausse : une rétrogradation), ou absente ? Par qualificatif donné et par tête (les têtes fausses
au moins SEUIL fois). Un diagnostic : il ne règle rien (docs/mesures/SURETE_LECTEUR.md, § 4)."""
import importlib.util, json, sys, collections
from pathlib import Path
spec = importlib.util.spec_from_file_location("cg", Path(__file__).resolve().parent / "comparer_graphes.py")
cg = importlib.util.module_from_spec(spec); spec.loader.exec_module(cg)
R = {cg.cle(x): x for x in cg.charger(sys.argv[1])}
A = {cg.cle(x): x for x in cg.charger(sys.argv[2])}
B = {cg.cle(x): x for x in cg.charger(sys.argv[3])}
par_val = collections.Counter(); par_tete = collections.Counter(); exemples = collections.defaultdict(list)
for k in sorted(set(R) & set(B)):
    r = cg.depuis_reference(R[k]); ga = cg.depuis_faits(A[k]); gb = cg.depuis_faits(B[k])
    inv_e = {j: i for i, j in cg.aligner(r.entites, gb.entites).items()}
    inv_v = {j: i for i, j in cg.aligner(r.evenements, gb.evenements).items()}
    for gid, (tete, _) in list(gb.entites.items()) + list(gb.evenements.items()):
        if ga.admissible(gid) and not gb.admissible(gid):
            q = gb.q(gid)
            val = ("portee=" + q[2]) if q[2] != "represente" else ("modalite=" + q[1]) if q[1] != "affirme" else (
                "neg" if q[0] == "neg" else "cite" if q[3] == "cite" else "alternative")
            ri = inv_e.get(gid, inv_v.get(gid))
            verdict = "sans_correspondante" if ri is None else ("juste" if not r.admissible(ri) else "fausse")
            par_val[(val, verdict)] += 1
            par_tete[(val, tete, verdict)] += 1
            if verdict == "fausse" and len(exemples[val]) < 6:
                exemples[val].append((k, tete, R[k]["texte"][:160]))
for (v, d), n in sorted(par_val.items()):
    print(f"{v:28} {d:20} {n}")
print("\nles têtes les plus souvent fausses :")
for (v, t, d), n in par_tete.most_common(200):
    if d == "fausse" and n >= int(sys.argv[4] if len(sys.argv) > 4 else 2):
        print(f"  {n} {v} {t}")
if len(sys.argv) > 5:
    for v, es in exemples.items():
        print("\n", v)
        for e in es:
            print("   ", e)
