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
Décision à deux étages (poids["deux_etages"]) : deux_etages, etage_base(E, B), etage_noeud(E, A, N, Trait, Seuil, G,
D), etage_feuille(E, A, N, V) pour E = 1 (sur les traits) et E = 2 (sur les traits et la place du candidat dans son
image : inv_rang_image, p_sur_max_image, max_descendant, p_ancetre_proche, devant_dans_chapitre) ; reglage et
f1_attendu sont alors ceux des deux étages (decision:p_image/2 les exécute).
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
    out = {"arbres": len(a["foret"]), "noeuds": sum(len(x) for x in a["foret"]), "traits": len(traits)}
    de = p.get("deux_etages")
    if de:      # deux étages : le premier sur les traits, le second sur les traits et la place dans l'image
        lignes[0] = lignes[0].replace("provenance/2]).", "provenance/2, deux_etages/0, etage_base/2, etage_noeud/7, "
                                                         "etage_feuille/4]).")
        lignes[1] = ":- discontiguous noeud/6, feuille/3, etage_noeud/7, etage_feuille/4."
        lignes = [x for x in lignes if not x.startswith(("reglage(", "f1_attendu("))]
        lignes += ["deux_etages.", f"reglage({int(de['k'])}, {float(de['seuil'])!r}, {q(de['critere'])}).",
                   f"f1_attendu({float(de['f1_attendu']['g'])!r}).",
                   f"provenance(ecart_relecture_deux_etages, {float(de.get('ecart_relecture', 0.0))!r})."]
        noms = {1: de["traits"], 2: de["traits"] + de["contexte"]}
        for e in (1, 2):
            etage = de[f"etage{e}"]
            lignes.append(f"etage_base({e}, {float(etage['base'])!r}).")
            for i, arbre in enumerate(etage["foret"]):
                for n, (f, seuil, _mg, g, d, feuille, valeur) in enumerate(arbre):
                    lignes.append(f"etage_feuille({e}, {i}, {n}, {float(valeur)!r})." if feuille else
                                  f"etage_noeud({e}, {i}, {n}, {q(noms[e][f])}, {float(seuil)!r}, {g}, {d}).")
        out["deux_etages"] = {e: len(de[f"etage{e}"]["foret"]) for e in (1, 2)}
    Path(sortie).write_text("\n".join(lignes) + "\n", encoding="utf-8")
    return out


if __name__ == "__main__":
    if len(sys.argv) != 3:
        raise SystemExit(__doc__)
    print(json.dumps(compiler(*sys.argv[1:])))
