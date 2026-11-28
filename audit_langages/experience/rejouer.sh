#!/usr/bin/env bash
# Rejoue l'expérience (audit des langages) de bout en bout dans un dossier de sortie NEUF.
#   ./rejouer.sh SORTIE_DIR [complet]
# Prérequis : python3 (3.13 ici), swipl 11.0.0 avec les paquets livrés (sgml, xpath, unicode), pytest (pour py/test_k.py).
# Aucune installation, aucun accès au réseau. Les ressources sont lues dans /home/user/donnees/ressources (MANIFESTEs).
set -euo pipefail
ICI=$(cd "$(dirname "$0")" && pwd); OUT=$1; MODE=${2:-echantillon}
export LANG=C.UTF-8
mkdir -p "$OUT"; [ -z "$(ls -A "$OUT")" ] || { echo "dossier non vide : $OUT" >&2; exit 2; }
if [ "$MODE" = complet ]; then E=$OUT/echantillon; python3 -I "$ICI/commun/extraire_echantillon.py" "$E" --complet
else E=$OUT/echantillon; python3 -I "$ICI/commun/extraire_echantillon.py" "$E"; fi
python3 -I "$ICI/py/construire_k.py" construire "$E" "$OUT/k_py.tsv"
swipl "$ICI/pl/construire_k.pl" construire "$E" "$OUT/k_pl.tsv"
cmp "$OUT/k_py.tsv" "$OUT/k_pl.tsv" && echo "K identiques (octets) entre Python et Prolog"
python3 -I "$ICI/py/construire_k.py" controler "$OUT/k_py.tsv" "$E/wn30_ids.txt" && echo "Python : aucune violation"
swipl "$ICI/pl/construire_k.pl" controler "$OUT/k_pl.tsv" "$E/wn30_ids.txt" && echo "Prolog : aucune violation"
python3 -I "$ICI/py/construire_k.py" compiler "$OUT/k_py.tsv" "$E/wn30_ids.txt" "$OUT/k_faits_py.pl"
swipl "$ICI/pl/construire_k.pl" compiler "$OUT/k_pl.tsv" "$E/wn30_ids.txt" "$OUT/k_faits_pl.pl"
swipl "$ICI/commun/comparer_faits.pl" -- "$OUT/k_faits_py.pl" "$OUT/k_faits_pl.pl"
if [ "$MODE" != complet ]; then
  python3 -I "$ICI/commun/fabriquer_mutants.py" "$OUT/k_py.tsv" "$OUT/mutants"
  python3 -I "$ICI/commun/lancer_mutants.py" "$OUT/mutants" "$E/wn30_ids.txt" "$ICI/py/construire_k.py" "$ICI/pl/construire_k.pl" "$OUT/mutants.tsv" | tail -1
  (cd "$ICI/py" && MUTANTS_DIR="$OUT/mutants" WN30_IDS="$E/wn30_ids.txt" python3 -m pytest -q -p no:cacheprovider test_k.py | tail -3) || true
  (cd "$ICI/pl" && MUTANTS_DIR="$OUT/mutants" WN30_IDS="$E/wn30_ids.txt" swipl -g run_tests -t halt test_k.pl 2>&1 | tail -3) || true
fi
