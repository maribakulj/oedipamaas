# Historique (version 1.0) : n'est plus le moteur en construction ; voir docs/HISTORIQUE.md.
"""Candidats d'un dossier de descriptions avec leurs traits de preuve (socle 1.0), pour apprendre et mesurer la
décision : une ligne JSON par image, {image, versions, codes: [{code, score, traits}]} (score : la part décrite,
provisoire). Aucune étiquette n'est lue ici.
Usage : python -m oedipamaas.socle.candidats BASE_V1/ DESCRIPTIONS/ SORTIE.jsonl[.gz] [BUDGET] (.gz : compressé)"""
import json
import sys
import time
from pathlib import Path

from oedipamaas.socle import coder, faits_description as fd

BUDGET = 60        # premiers par chacun des deux ordres (BM25, part décrite), avant spécialisations, clés et ancêtres


def main(base, dossier, sortie, budget=BUDGET):
    janus = coder.charger_moteur(base)
    janus.consult(str(Path(coder.__file__).resolve().parent / "traits.pl"))
    t0, n, erreurs = time.time(), 0, 0
    with coder.ouvrir_sortie(sortie) as out:
        for f in sorted(Path(dossier).glob("*.json")):
            ligne = {"image": f.stem, "versions": {"moteur": coder.version(), "etape": "candidats", "budget": int(budget)}}
            try:
                fd.charger(janus, fd.lire_fichier(f))
                janus.query_once("abolish_all_tables")
                r = janus.query_once("traits:candidats_traits(B, _L), "
                                     "findall([_N, _P, _T], (member([_N, _P, _T0], _L), "
                                     "findall([_K, _V], member(_K-_V, _T0), _T)), X)", {"B": int(budget)})
                ligne["codes"] = [{"code": c, "score": round(p, 4), "traits": {k: round(v, 4) for k, v in t}}
                                  for c, p, t in r["X"]]
            except Exception as e:
                ligne["erreur"] = f"{type(e).__name__}: {str(e)[:200]}"
                ligne["codes"] = []
                erreurs += 1
            out.write(json.dumps(ligne, ensure_ascii=False) + "\n")
            n += 1
    print(json.dumps({"images": n, "erreurs": erreurs, "s_par_image": round((time.time() - t0) / max(n, 1), 3)}))


if __name__ == "__main__":
    if len(sys.argv) not in (4, 5):
        raise SystemExit(__doc__)
    main(*sys.argv[1:])
