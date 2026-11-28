"""L'interpréteur de référence du langage de référence d'oedipamaas (docs/LANGAGE_REFERENCE.md).

Indépendant du moteur Prolog et de l'oracle du noyau : il n'importe rien de oedipamaas/ ni de tests/oracle/.
Bibliothèque standard seulement.

  syntaxe.py       la syntaxe abstraite (§ 1)
  formation.py     les règles de formation (§ 2)
  connaissances.py l'ordre des types relatif à K (§ 3.4)
  interprete.py    la sémantique : interprétations, modèles de Belnap, profil, statut synthétique (§ 3)
  inclusion.py     le comparateur d'inclusion entre requêtes, dans les deux sens (§ 3.11, étude § 2.6)
  json_concret.py  la syntaxe concrète JSON (§ 4)
"""
VERSION = "langage-ref-1"
