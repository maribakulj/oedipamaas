# Historique (version 1.0) : n'est plus le moteur en construction ; voir docs/HISTORIQUE.md.
"""Index dérivés de la base (socle 1.0), construits une fois à partir de iconclass.qlf et wordnet.qlf, puis compilés
(.qlf) : lexique_index (formes → notations), propres_index (mots propres), cles_index (clés), alternatives_index
(façons de nommer ce qui est propre à une notation), gabarits_index (sortes des gabarits à nom, noms listés),
cadres_index (cadre de chaque libellé : phase, têtes, compléments, contexte). Chaque index se reconstruit seul, les
autres restent tels quels.
Usage : python -m oedipamaas.socle.construire_base BASE_V1/ [lexique|propres|cles|alternatives|gabarits|cadres ...]"""
import sys
import time
from pathlib import Path

ICI = Path(__file__).resolve().parent
INDEX = {
    "lexique": ("lexique_index", "lexique:construire_index"),
    "propres": ("propres_index", "specialisation:construire_propres"),
    "cles": ("cles_index", "cles:construire_cles"),
    "alternatives": ("alternatives_index", "specialisation:construire_alternatives"),
    "gabarits": ("gabarits_index", "noms:construire_gabarits"),
    "cadres": ("cadres_index", "cadres:construire_cadres"),
}


def main(base, *noms):
    import janus_swi as janus
    base = Path(base).resolve()
    for f in ("iconclass.qlf", "wordnet.qlf"):
        janus.query_once(f"load_files('{base / f}', [redefine_module(true)])")
    for f in ("notation.pl", "arbre.pl", "libelles.pl", "morphologie.pl", "lexique.pl", "description.pl",
              "recherche.pl", "specialisation.pl", "cles.pl", "noms.pl", "cadres.pl"):
        janus.consult(str(ICI / f))
    janus.query_once("morphologie:indexer")
    for nom in noms or INDEX:
        module, but = INDEX[nom]
        t0 = time.time()
        pl = base / f"{module}.pl"
        janus.query_once(f"{but}('{pl}')")
        janus.query_once(f"qcompile('{pl}')")
        print(f"{module} : {pl.stat().st_size} octets, {time.time() - t0:.0f} s")
        janus.query_once(f"load_files('{base / (module + '.qlf')}', [redefine_module(true)])")


if __name__ == "__main__":
    if len(sys.argv) < 2 or not set(sys.argv[2:]) <= set(INDEX):
        raise SystemExit(__doc__)
    main(*sys.argv[1:])
