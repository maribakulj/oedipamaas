#!/usr/bin/env bash
# La mesure de référence après D30 (lot 1 de la phase C3/C6/C7) : les mêmes jeux, les mêmes outils, trois réglages.
#
#   outils/mesure/reference_d30.sh BASE DONNEES SORTIE                    tout, en série (long : plusieurs heures)
#   outils/mesure/reference_d30.sh BASE DONNEES SORTIE preparer           1 et 2 : requêtes compilées, comparateur
#   outils/mesure/reference_d30.sh BASE DONNEES SORTIE tranche R J I N    une tranche du codage (R réglage, J jeu)
#   outils/mesure/reference_d30.sh BASE DONNEES SORTIE reunir R J N       réunit les N tranches, contrôle compris
#   outils/mesure/reference_d30.sh BASE DONNEES SORTIE controle J         l'accord indexé / exhaustif (3 fiches)
#
#     BASE     la base compilée ; requetes_index.pl y est recompilé (l'ancien est gardé : requetes_index_avant_d30.pl)
#     DONNEES  le dossier qui contient vertical/ (développement) et validation_m1/ (validation)
#     SORTIE   le dossier des résultats (hors dépôt)
# Réglages : d30 (tous les sens, normalisation par défaut) ; d30_sans_norm (OEDIPAMAAS_NORMALISATION=non) ;
# premier_sens (l'anglais au premier sens de WordNet, comme avant D30 : pour isoler l'effet de D30).
# Échantillon : une fiche sur PAS=5 (40 fiches par jeu). Limite d'un texte : INFERENCES=10⁹ inférences (environ deux
# minutes de processeur ; ne dépend ni de la machine ni de sa charge : reproductible), et un garde-fou de mur de
# DELAI=900 s. Chaque tranche écrit sa sortie et sa description (….passe.json : commit, réglage, fiches, analyses).
# Le résumé : python outils/mesure/resume_reference.py SORTIE
set -euo pipefail
BASE=$1; DONNEES=$2; SORTIE=$3; ETAPE=${4:-tout}
PAS=${PAS:-5}; INFERENCES=${INFERENCES:-1000000000}; DELAI=${DELAI:-900}
ICI=$(cd "$(dirname "$0")/../.." && pwd)
mkdir -p "$SORTIE"
export LANG=C.UTF-8 OEDIPAMAAS_ANALYSEUR=stanza

preparer () {
  [ -e "$BASE/requetes_index_avant_d30.pl" ] || cp "$BASE/requetes_index.pl" "$BASE/requetes_index_avant_d30.pl"
  ( time swipl "$ICI/outils/requetes/compiler_tout.pl" "$BASE" ) > "$SORTIE/compilation.log" 2>&1
  for J in vertical validation_m1; do
    swipl "$ICI/outils/requetes/compiler_vertical.pl" "$BASE" "$DONNEES/$J/fiches.json" "$SORTIE/compilees_$J.json" \
      > "$SORTIE/compiler_$J.log" 2>&1
    swipl "$ICI/outils/requetes/comparer.pl" "$BASE" "$SORTIE/compilees_$J.json" "$DONNEES/$J/requetes_reference.json" \
      "$SORTIE/comparaison_$J.json" > "$SORTIE/comparer_$J.log" 2>&1
    swipl "$ICI/outils/requetes/comparer.pl" "$BASE" "$SORTIE/compilees_$J.json" "$DONNEES/$J/requetes_reference.json" \
      "$SORTIE/comparaison_${J}_sans_norm.json" sans_normalisation > "$SORTIE/comparer_${J}_sans_norm.log" 2>&1
  done
}
tranche () {  # REGLAGE JEU I N
  local R=$1 J=$2 I=$3 N=$4 env=()
  case $R in d30_sans_norm) env=(OEDIPAMAAS_NORMALISATION=non) ;; premier_sens) env=(OEDIPAMAAS_SENS_EN=premier) ;; esac
  ( time env "${env[@]}" OEDIPAMAAS_INFERENCES="$INFERENCES" OEDIPAMAAS_DELAI="$DELAI" OEDIPAMAAS_TRANCHE="$I/$N" \
      swipl "$ICI/outils/vertical/coder.pl" "$BASE" "$DONNEES/$J/textes.json" "$SORTIE/codage_${R}_${J}_t${I}de${N}.json" \
      "$PAS" 0 ) > "$SORTIE/codage_${R}_${J}_t${I}de${N}.log" 2>&1
}
reunir () {  # REGLAGE JEU N
  local R=$1 J=$2 N=$3 ts=()
  for I in $(seq 1 "$N"); do ts+=("$SORTIE/codage_${R}_${J}_t${I}de${N}.json"); done
  python3 "$ICI/outils/mesure/reunir_tranches.py" "$SORTIE/codage_${R}_$J.json" "$DONNEES/$J/textes.json" "$PAS" "${ts[@]}"
}
controle () {  # JEU : les 3 premières fiches de l'échantillon, en mode indexé et exhaustif
  local J=$1
  OEDIPAMAAS_INFERENCES="$INFERENCES" OEDIPAMAAS_DELAI="$DELAI" swipl "$ICI/outils/vertical/coder.pl" "$BASE" \
    "$DONNEES/$J/textes.json" "$SORTIE/controle_$J.json" 50 3 > "$SORTIE/controle_$J.log" 2>&1
}
case $ETAPE in
  preparer) preparer ;;
  tranche) tranche "$5" "$6" "$7" "$8" ;;
  reunir) reunir "$5" "$6" "$7" ;;
  controle) controle "$5" ;;
  tout)
    preparer
    for R in d30 d30_sans_norm premier_sens; do for J in vertical validation_m1; do
      tranche "$R" "$J" 1 1; reunir "$R" "$J" 1; done; done
    for J in vertical validation_m1; do controle "$J"; done ;;
esac
git -C "$ICI" rev-parse HEAD > "$SORTIE/commit"
