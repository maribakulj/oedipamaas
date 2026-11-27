#!/usr/bin/env bash
# La mesure des corrections de C3 (docs/mesures/C3_CORRECTIONS.md) : les mêmes jeux, les mêmes outils, au commit courant.
#   outils/mesure/c3_corrections.sh BASE DONNEES SORTIE
#     BASE     la base compilée (lue seulement : l'index des requêtes n'est pas recompilé)
#     DONNEES  le dossier qui contient vertical/, validation_m1/ et banc_graphes/
#     SORTIE   le dossier des résultats (hors dépôt) ; « avant » et « après » sont deux SORTIE, à deux commits
# Pour chaque jeu : les requêtes compilées des 200 fiches ; leur comparaison aux requêtes de référence (avec et sans
# normalisation, comme outils/mesure/reference_d30.sh preparer) ; les quatre conditions de l'expérience croisée
# (outils/croise/croiser.pl), sur les 40 fiches du banc de graphes.
# Le résumé : python outils/mesure/resumer_c3.py AVANT APRES
set -euo pipefail
BASE=$1; DONNEES=$2; SORTIE=$3
ICI=$(cd "$(dirname "$0")/../.." && pwd)
mkdir -p "$SORTIE"
export LANG=C.UTF-8
# COMMIT : pour une copie extraite d'un commit (git archive), qui n'est pas un dépôt
if [ -n "${COMMIT:-}" ]; then echo "$COMMIT" > "$SORTIE/commit"; : > "$SORTIE/arbre_modifie"
else git -C "$ICI" rev-parse HEAD > "$SORTIE/commit"
     git -C "$ICI" status --porcelain --untracked-files=no > "$SORTIE/arbre_modifie"; fi
B=$DONNEES/banc_graphes
for J in vertical validation_m1; do
  swipl "$ICI/outils/requetes/compiler_vertical.pl" "$BASE" "$DONNEES/$J/fiches.json" "$SORTIE/compilees_$J.json" \
    > "$SORTIE/compiler_$J.log" 2>&1
  swipl "$ICI/outils/requetes/comparer.pl" "$BASE" "$SORTIE/compilees_$J.json" "$DONNEES/$J/requetes_reference.json" \
    "$SORTIE/comparaison_$J.json" > "$SORTIE/comparer_$J.log" 2>&1
  swipl "$ICI/outils/requetes/comparer.pl" "$BASE" "$SORTIE/compilees_$J.json" "$DONNEES/$J/requetes_reference.json" \
    "$SORTIE/comparaison_${J}_sans_norm.json" sans_normalisation > "$SORTIE/comparer_${J}_sans_norm.log" 2>&1
  swipl "$ICI/outils/croise/croiser.pl" "$BASE" "$B/lecteur_$J.json" "$B/faits_reference_$J.json" \
    "$SORTIE/compilees_$J.json" "$DONNEES/$J/requetes_reference.json" "$DONNEES/$J/fiches.json" \
    "$SORTIE/croise_$J.json" > "$SORTIE/croise_$J.log" 2>&1
done
