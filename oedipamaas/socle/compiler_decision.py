"""Compile une décision apprise (poids.json du noyau de calibration) en faits Prolog (socle 1.0, § 9) : les arbres
boostés deviennent des nœuds et des feuilles, leur réglage (k, seuil, critère ; g du F1 attendu) des faits ; la règle
qui les exécute est dans decision.pl. Aucune étiquette n'est dans ce fichier : seulement des seuils sur des traits de
preuve et des valeurs de feuilles.

Faits du module decision_poids :
  base(B)                                   valeur initiale (logit)
  noeud(Arbre, Noeud, Trait, Seuil, Gauche, Droite)   aller à gauche si la valeur du trait est ≤ Seuil
  feuille(Arbre, Noeud, Valeur)
  reglage(K, Seuil, Critere)                 sélection par grille (critère : p, ou esperance = p × (profondeur + 1))
  f1_attendu(G)                              sélection par F1 hiérarchique attendu (taille attendue de la vérité)
  provenance(Cle, Valeur)                    empreinte du fichier de poids, cible, nombre d'images d'apprentissage
Usage : python -m oedipamaas.socle.compiler_decision POIDS.json SORTIE.pl"""
import hashlib
import json
import sys
from pathlib import Path


def q(s):
    return "'" + str(s).replace("\\", "\\\\").replace("'", "\\'") + "'"


def compiler(chemin_poids, sortie):
    brut = Path(chemin_poids).read_bytes()
    p = json.loads(brut)
    a = p["arbres"]
    traits = a["traits"]
    lignes = [":- module(decision_poids, [base/1, noeud/6, feuille/3, reglage/3, f1_attendu/1, provenance/2]).",
              ":- discontiguous noeud/6, feuille/3.",
              f"base({a['base']!r}).",
              f"reglage({int(a['k'])}, {float(a['seuil'])!r}, {q(a['critere'])}).",
              f"f1_attendu({float(a['f1_attendu']['g'])!r}).",
              f"provenance(sha256, {q(hashlib.sha256(brut).hexdigest())}).",
              f"provenance(cible, {q(p.get('cible', ''))}).",
              f"provenance(images, {int(p.get('images', 0))}).",
              f"provenance(ecart_relecture, {float(a.get('ecart_relecture', 0.0))!r})."]
    for i, arbre in enumerate(a["foret"]):
        for n, (f, seuil, _manque_gauche, g, d, feuille, valeur) in enumerate(arbre):
            if feuille:
                lignes.append(f"feuille({i}, {n}, {float(valeur)!r}).")
            else:
                lignes.append(f"noeud({i}, {n}, {q(traits[f])}, {float(seuil)!r}, {g}, {d}).")
    Path(sortie).write_text("\n".join(lignes) + "\n", encoding="utf-8")
    return {"arbres": len(a["foret"]), "noeuds": sum(len(x) for x in a["foret"]), "traits": len(traits)}


if __name__ == "__main__":
    if len(sys.argv) != 3:
        raise SystemExit(__doc__)
    print(json.dumps(compiler(*sys.argv[1:])))
