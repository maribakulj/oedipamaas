"""Les cas réels des bancs écrits dans la syntaxe concrète (semantique_reference/exemples/*.json), évalués par
l'interpréteur et comparés à leur référence adjugée, copiée dans le dossier sans modification (docs/LANGAGE_REFERENCE.md,
§ 8). Usage : python3 -m semantique_reference.banc
"""
from __future__ import annotations

import json
import sys
from pathlib import Path

from . import formation, interprete as I, json_concret as J

ICI = Path(__file__).resolve().parent / "exemples"


def dossiers() -> list:
    return sorted(ICI.glob("*.json"))


def evaluer_dossier(chemin) -> list:
    """Pour chaque cas du dossier : (identifiant, niveau, statut calculé, statut de référence, comparaison, détail)."""
    d = json.loads(Path(chemin).read_text(encoding="utf-8"))
    lignes = []
    for x in d["cas"]:
        c = J.lire_cas(x)
        defauts = formation.verifier(c)
        ev = I.evaluer(c)
        s = ev.principal
        ref = (x.get("reference_adjugee") or {}).get("statut_reference")
        p = ev.profils[I.RACINE]
        detail = {
            "classes": [(cl.statut, len(cl.interpretations)) for cl in p.classes],
            "hypotheses": sorted({(h.nature, h.contenu) for _, h in s.hypotheses}),
            "couverture_plus": s.couverture_plus, "couverture_moins": s.couverture_moins,
            "uniforme": s.uniforme_plus, "refutation_fermee": s.refutation_fermee,
            "contextes": {k: v.nom for k, v in ev.statuts.items() if k != I.RACINE},
            "defauts": [str(f) for f in defauts],
        }
        lignes.append((c.id, x["comparaison"]["niveau"], s.nom, ref, x["comparaison"], detail))
    return lignes


def main():
    for ch in dossiers():
        for (ident, niveau, calc, ref, comp, det) in evaluer_dossier(ch):
            marque = "=" if calc == ref else "≠"
            print(f"{ident:32} ({niveau}) calculé {calc:26} {marque} référence {ref or '—':26} "
                  f"classes {det['classes']} hyp {[n for n, _ in det['hypotheses']]} ctx {det['contextes']}"
                  + (f" DÉFAUTS {det['defauts']}" if det["defauts"] else ""))
    return 0


if __name__ == "__main__":
    sys.exit(main())
