# Le jeu de qualification indépendant (gelé, non scellé)

Branche orpheline : aucune histoire commune avec le code, jamais fusionnée.

**Gelé, non scellé** (précision de la propriétaire, 27/11) : une branche que les agents peuvent lire n'est pas hors de
leur portée. La conservation hors de portée est à organiser avec la propriétaire (`docs/QUALIFICATION_SEMANTIQUE.md`,
§ 4.1, sur la branche du code). Après une copie vérifiée, cette branche est à retirer.

**Ne pas ouvrir `jeu.json`.** Il ne doit être lu qu'une fois, pour la qualification, après que la propriétaire a
validé les bancs par famille (`docs/QUALIFICATION_SEMANTIQUE.md`, § 4, sur la branche du code). Aucun agent ne le lit
pour une mise au point, un diagnostic ou une vérification.

- `jeu.json` : 400 notations tirées (graine 20261127), stratifiées par division, avec leurs libellés, et un
  sous-ensemble de 100 pour les textes. L'empreinte SHA-256 de son contenu est publiée dans le dépôt.
- `jeu.json.resume.json` : le résumé du tirage (graine, tailles, strates, exclusions, empreinte), lisible.
- L'outil : `outils/qualification/tirer_jeu_independant.py` (branche du code).
- **Exclues :** les notations des jeux de développement et de validation, des requêtes de référence, des
  échantillons J2, des références des mesures J0 et J1, des tirages Joconde, avec leurs ancêtres et leurs descendants
  directs.
- **Non vérifié :** le recouvrement avec les bancs scellés (`banc_qualif*`, `banc_scelle`), dont les références ne
  sont pas lues. À vérifier par la propriétaire, en relançant l'outil avec ces références dans `--exclure`. L'empreinte
  changera alors.
