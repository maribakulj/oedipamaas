# Décisions provisoires

Prises pendant la boucle autonome, selon la règle 4 de `SUIVI.md` : l'option recommandée est appliquée, rien n'est
rendu irréversible. Chacune attend une validation.

| N° | Date | Décision | Pourquoi | Statut |
|---|---|---|---|---|
| D1 | 2026-11-23 | Les liens WordNet ne soutiennent des clés (+…) que depuis un **sens dominant** de la forme décrite (J0.6) | avec tous les sens, « standing » d'une autre entité donnait 31A(+51) ; le test existant l'interdit | provisoire — à valider |
| D2 | 2026-11-23 | La sélection par **F1 attendu** compte les nœuds par préfixes de jetons (`decision:prefixes/2`), comme la mesure, et non par l'arbre (J0.5) | g a été appris contre la mesure, qui compte ainsi ; c'est la fonction objectif, pas la hiérarchie du moteur | provisoire — à valider |
| D3 | 2026-11-23 | Une mention est **coupée au premier mot négatif** ; tout ce qui suit est écarté, même après « but » (J0.8) | précision d'abord, en attendant l'analyse de la portée au J1 | provisoire — remplacée au J1 |
| D4 | 2026-11-23 | Moisson : séparation dev / test **par collection** (Wikidata P195) quand elle est connue, **par œuvre** sinon (RKD : pas de collection dans la requête), 30 % en test, tirage par empreinte | séparation par collection demandée au § 12.1 ; la collection RKD demanderait la provenance | provisoire — à valider |
| D5 | 2026-11-23 | Dédoublonnage : une œuvre Wikidata portant un identifiant RKDimages (P350) présent dans la moisson RKD est écartée | ses codes viennent souvent du RKD par un robot (annexe A) | provisoire — à valider |
