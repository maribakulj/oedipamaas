"""Coder un dossier de descriptions avec le socle 1.0 (recherche à plat, classement provisoire) : sortie au format
des codes du moteur (une ligne JSON par image : image, codes [{code, cle, nature}], versions), pour les mesures de
couverture. Pas encore de décision ni de preuve rendue (pièces suivantes).
Usage : python -m oedipamaas.socle.coder BASE_V1/ DESCRIPTIONS/ SORTIE.jsonl [MAX]"""
import json
import subprocess
import sys
import time
from pathlib import Path

ICI = Path(__file__).resolve().parent
MAX = 500
K_ANCETRES = 120        # ancêtres des 120 premiers candidats (le budget de la version 0.2), rendus à part


def charger_moteur(base):
    import janus_swi as janus
    base = Path(base)
    for f in ("iconclass.qlf", "wordnet.qlf", "lexique_index.qlf", "propres_index.qlf"):
        janus.query_once(f"load_files('{base / f}', [redefine_module(true)])")
    for f in ("notation.pl", "arbre.pl", "libelles.pl", "morphologie.pl", "lexique.pl", "description.pl",
              "recherche.pl", "specialisation.pl"):
        janus.consult(str(ICI / f))
    janus.query_once("morphologie:indexer")
    return janus


def version():
    r = subprocess.run(["git", "-C", str(ICI), "rev-parse", "--short", "HEAD"], capture_output=True, text=True)
    sale = subprocess.run(["git", "-C", str(ICI), "status", "--porcelain"], capture_output=True, text=True).stdout
    return f"1.0.0a+g{r.stdout.strip()}{'.modifie' if sale.strip() else ''}"


def main(base, dossier, sortie, maximum=MAX):
    from oedipamaas.socle import faits_description as fd
    janus = charger_moteur(base)
    t0, n, erreurs = time.time(), 0, 0
    with open(sortie, "w", encoding="utf-8") as out:
        for f in sorted(Path(dossier).glob("*.json")):
            ligne = {"image": f.stem, "versions": {"moteur": version(), "etape": "recherche"}}
            try:
                fd.charger(janus, fd.lire_fichier(f))
                janus.query_once("abolish_all_tables")
                r = janus.query_once("recherche:classement(Max, _L), "
                                     "findall([_N, _D, _W, _Na], member(c(_N, cle(_D, _W), _Na), _L), X), "
                                     "recherche:ancetres_des_premiers(_L, K, A)",
                                     {"Max": int(maximum), "K": K_ANCETRES})
                ligne["codes"] = [{"code": c, "cle": [round(d, 4), round(w, 4)], "nature": na}
                                  for c, d, w, na in r["X"]]
                ligne["ancetres_des_premiers"] = {"k": K_ANCETRES, "codes": list(r["A"])}
                # spécialisation : descente depuis les K premiers candidats (soutenus eux-mêmes par la description,
                # pas leurs ancêtres) vers les enfants les mieux soutenus
                departs = [c["code"] for c in ligne["codes"][:K_ANCETRES]]
                s = janus.query_once("specialisation:decrire, specialisation:specialisees(D, S)", {"D": departs})
                ligne["specialisees"] = list(s["S"])
                # second ordre (abduction) : part décrite des mots propres de chaque candidat, puis BM25 ; sur tous
                # les candidats directs, pas seulement les premiers de BM25
                t = janus.query_once("recherche:classement(1000000, _L), "
                                     "findall([_P, _D, _N], (member(c(_N, cle(_D, _), _), _L), "
                                     "(specialisation:part_decrite(_N, _P0) -> _P = _P0 ; _P = 0)), _T), "
                                     "msort(_T, _T1), reverse(_T1, _T2), length(_T2, _Lg), _K is min(Max, _Lg), "
                                     "length(_T3, _K), append(_T3, _, _T2), findall(_X, member([_, _, _X], _T3), X)",
                                     {"Max": int(maximum)})
                ligne["par_part"] = list(t["X"])
            except Exception as e:          # une description illisible : ligne d'erreur, comptée
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
