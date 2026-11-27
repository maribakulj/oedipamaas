"""L'échantillon de relecture humaine du banc (lot 5 ; docs/BANC_GRAPHES.md, § 1) : les graphes de référence d'un
tirage par strates, rendus lisibles, et une table à remplir, un élément par ligne.

Usage : python outils/graphes/echantillon_relecture.py REF_DEV.json REF_VALIDATION.json B1_DEV.json B1_VAL.json DOSSIER
        [--n-dev 10] [--n-val 20] [--graine 20261127]

Tirage : dans chaque jeu, par strates (langue × genre de texte), la moitié des textes parmi ceux qui ont été annotés
deux fois (l'adjudication y a tranché), l'autre moitié parmi les autres. Écrit :
  DOSSIER/relecture.md   chaque texte et son graphe (entités, événements et rôles, relations, coréférences,
                         qualificatifs), numéroté ;
  DOSSIER/relecture.tsv  un élément par ligne (jeu, k, genre, numéro, élément) avec deux colonnes à remplir :
                         jugement (juste | faux | douteux) et correction (libre) ; plus une ligne « manque » par texte
                         pour ce que le graphe aurait dû contenir.
Les jugements rendus mesurent l'accord entre les agents et une relectrice humaine (outils/graphes/accord_humain.py,
à écrire quand les jugements seront là) ; ils ne modifient pas la référence d'eux-mêmes."""
import argparse
import collections
import json
import random
from pathlib import Path

QUAL = (("polarite", "pos"), ("modalite", "affirme"), ("portee", "represente"), ("enonciateur", "auteur"))


def qualif(o):
    q = [f"{k}={o[k] if not isinstance(o[k], dict) else 'cité : ' + o[k].get('cite', '?')}"
         for k, d in QUAL if o.get(k, d) != d]
    return f" [{', '.join(q)}]" if q else ""


def elements(g):
    ents = {e["id"]: e for e in g.get("entites", [])}
    nom = lambda i: f"{ents[i]['tete']}#{i}" if i in ents else i
    out = []
    for e in g.get("entites", []):
        d = f"entité {nom(e['id'])} « {e.get('mention')} »"
        if e.get("noms"):
            d += " ; noms : " + ", ".join(n if isinstance(n, str) else n["nom"] + qualif(n) for n in e["noms"])
        if e.get("proprietes"):
            d += " ; propriétés : " + ", ".join(p if isinstance(p, str) else p["propriete"] + qualif(p)
                                               for p in e["proprietes"])
        if e.get("nombre"):
            d += f" ; nombre {e['nombre']}"
        out.append(d + qualif(e))
    for v in g.get("evenements", []):
        roles = "; ".join(f"{r} : " + ", ".join(nom(x) for x in ([es] if isinstance(es, str) else es))
                          for r, es in (v.get("roles") or {}).items())
        out.append(f"événement {v['predicat']}#{v['id']} « {v.get('mention')} »"
                   + (f" (nom d'action {v['nom_d_action']})" if v.get("nom_d_action") else "")
                   + (f" — {roles}" if roles else "") + qualif(v))
    for x in g.get("relations", []):
        out.append(f"relation {nom(x['sujet'])} —{x['relation']}→ {nom(x['objet'])}" + qualif(x))
    for c in g.get("coref", []):
        out.append("coréférence " + " = ".join(nom(i) for i in c))
    for c in g.get("distinct", []):
        out.append("distincts " + " ≠ ".join(nom(i) for i in c))
    for c in g.get("alternatives", []):
        out.append("alternative " + " | ".join(nom(i) for i in c))
    return out


def tirer(R, doubles, n, rng):
    strates = collections.defaultdict(list)
    for g in R:
        strates[(g["langue"], g["genre"] if g["genre"] in ("positif", "negatif", "indetermine") else "variante",
                 (g["k"], g["genre"]) in doubles)].append(g)
    ordre = sorted(strates)
    for s in ordre:
        rng.shuffle(strates[s])
    pris = []
    while len(pris) < n and any(strates.values()):
        for s in ordre:
            if strates[s] and len(pris) < n:
                pris.append(strates[s].pop())
    return pris


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("ref_dev")
    ap.add_argument("ref_val")
    ap.add_argument("b1_dev")
    ap.add_argument("b1_val")
    ap.add_argument("dossier")
    ap.add_argument("--n-dev", type=int, default=10)
    ap.add_argument("--n-val", type=int, default=20)
    ap.add_argument("--graine", type=int, default=20261127)
    a = ap.parse_args()
    rng = random.Random(a.graine)
    d = Path(a.dossier)
    d.mkdir(parents=True, exist_ok=True)
    md = ["# Relecture humaine du banc de graphes (échantillon)", "",
          "Pour chaque texte : chaque élément est-il juste d'après le guide (docs/BANC_GRAPHES.md, § 3) ? Les "
          "jugements vont dans relecture.tsv (colonnes jugement : juste, faux ou douteux ; correction : libre), et ce "
          "qui manque au graphe dans la ligne « manque » du texte.", ""]
    tsv = ["jeu\tk\tgenre\tnumero\telement\tjugement\tcorrection"]
    for jeu, fr, fb, n in (("developpement", a.ref_dev, a.b1_dev, a.n_dev), ("validation", a.ref_val, a.b1_val, a.n_val)):
        R = json.loads(Path(fr).read_text(encoding="utf-8"))
        doubles = {(g["k"], g["genre"]) for g in json.loads(Path(fb).read_text(encoding="utf-8"))}
        for g in tirer(R, doubles, n, rng):
            md += [f"## {jeu} — k {g['k']}, {g['genre']} ({g['langue']})"
                   + (" — annoté deux fois" if (g["k"], g["genre"]) in doubles else ""), "", f"> {g['texte']}", ""]
            for i, e in enumerate(elements(g), 1):
                md.append(f"{i}. {e}")
                tsv.append(f"{jeu}\t{g['k']}\t{g['genre']}\t{i}\t{e}\t\t")
            md.append("")
            tsv.append(f"{jeu}\t{g['k']}\t{g['genre']}\tmanque\t(ce qui manque au graphe)\t\t")
    (d / "relecture.md").write_text("\n".join(md) + "\n", encoding="utf-8")
    (d / "relecture.tsv").write_text("\n".join(tsv) + "\n", encoding="utf-8")
    print(f"{sum(1 for l in tsv[1:] if not l.split(chr(9))[3] == 'manque')} éléments, "
          f"{sum(1 for l in tsv[1:] if l.split(chr(9))[3] == 'manque')} textes")


if __name__ == "__main__":
    main()
