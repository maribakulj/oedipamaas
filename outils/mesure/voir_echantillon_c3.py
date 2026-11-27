"""Affiche une catégorie d'un échantillon de la contre-expertise (outils/mesure/echantillonner_c3.py), pour le jugement.

Usage : python outils/mesure/voir_echantillon_c3.py ECHANTILLONS.json CATEGORIE"""
import json
import sys

E = json.load(open(sys.argv[1], encoding="utf-8"))["echantillons"][sys.argv[2]]
for i, x in enumerate(E):
    print(f"{i:2d} {x['n']} {x['l']} r{x['r']} {x['type']} | {x['libelle'][:150]}")
    print(f"     {x['avant'][:150]}  =>  {x['apres'][:200]}")
