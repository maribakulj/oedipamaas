#!/usr/bin/env bash
# La mesure de référence après D30 (lot 1 de la phase C3/C6/C7) : les mêmes jeux, les mêmes outils, trois réglages.
#   outils/mesure/reference_d30.sh BASE DONNEES SORTIE [PAS] [DELAI]
#     BASE     la base compilée (ressources, requêtes compilées) ; requetes_index.pl y est recompilé (une copie de
#              l'ancien est gardée à côté, requetes_index_avant_d30.pl, s'il n'y en a pas déjà une)
#     DONNEES  le dossier qui contient vertical/ (développement) et validation_m1/ (validation)
#     SORTIE   le dossier des résultats (hors dépôt)
#     PAS      une fiche sur PAS (5 par défaut : 40 fiches, 120 textes par jeu)
#     DELAI    secondes au plus par texte (120 par défaut)
# Réglages : d30 (par défaut : tous les sens, normalisation) ; d30_sans_norm (sans normalisation) ; premier_sens
# (l'anglais au premier sens de WordNet, comme avant D30 : pour isoler l'effet de D30, jamais un réglage de travail).
# Le résumé : python outils/mesure/resume_reference.py SORTIE
set -euo pipefail
BASE=$1; DONNEES=$2; SORTIE=$3; PAS=${4:-5}; DELAI=${5:-120}
ICI=$(cd "$(dirname "$0")/../.." && pwd)
mkdir -p "$SORTIE"
export LANG=C.UTF-8 OEDIPAMAAS_ANALYSEUR=stanza

# 1. les requêtes compilées de toute la base, avec le code de ce commit
[ -e "$BASE/requetes_index_avant_d30.pl" ] || cp "$BASE/requetes_index.pl" "$BASE/requetes_index_avant_d30.pl"
( time swipl "$ICI/outils/requetes/compiler_tout.pl" "$BASE" ) > "$SORTIE/compilation.log" 2>&1

# 2. le comparateur (C3) : compilées des deux jeux contre leurs références, avec et sans normalisation
for J in vertical validation_m1; do
  swipl "$ICI/outils/requetes/compiler_vertical.pl" "$BASE" "$DONNEES/$J/fiches.json" "$SORTIE/compilees_$J.json" \
    > "$SORTIE/compiler_$J.log" 2>&1
  swipl "$ICI/outils/requetes/comparer.pl" "$BASE" "$SORTIE/compilees_$J.json" "$DONNEES/$J/requetes_reference.json" \
    "$SORTIE/comparaison_$J.json" > "$SORTIE/comparer_$J.log" 2>&1
  swipl "$ICI/outils/requetes/comparer.pl" "$BASE" "$SORTIE/compilees_$J.json" "$DONNEES/$J/requetes_reference.json" \
    "$SORTIE/comparaison_${J}_sans_norm.json" sans_normalisation > "$SORTIE/comparer_${J}_sans_norm.log" 2>&1
done

# 3. le codage de bout en bout (C4, C5), trois réglages, les deux jeux, en parallèle
coder () {  # REGLAGE JEU
  local R=$1 J=$2 env=()
  case $R in d30_sans_norm) env=(OEDIPAMAAS_NORMALISATION=non) ;; premier_sens) env=(OEDIPAMAAS_SENS_EN=premier) ;; esac
  ( time env "${env[@]}" OEDIPAMAAS_DELAI="$DELAI" swipl "$ICI/outils/vertical/coder.pl" "$BASE" \
      "$DONNEES/$J/textes.json" "$SORTIE/codage_${R}_$J.json" "$PAS" 0 ) > "$SORTIE/codage_${R}_$J.log" 2>&1
}
for R in d30 d30_sans_norm premier_sens; do
  for J in vertical validation_m1; do coder "$R" "$J" & done
  wait
done
# 4. l'accord des modes indexé et exhaustif, sur les 3 premières fiches de chaque jeu (réglage d30)
for J in vertical validation_m1; do
  OEDIPAMAAS_DELAI="$DELAI" swipl "$ICI/outils/vertical/coder.pl" "$BASE" "$DONNEES/$J/textes.json" \
    "$SORTIE/controle_$J.json" 50 3 > "$SORTIE/controle_$J.log" 2>&1 &
done
wait
git -C "$ICI" rev-parse HEAD > "$SORTIE/commit"
