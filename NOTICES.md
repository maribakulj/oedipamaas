# Notices des ressources tierces de cette archive

Cette branche de données contient des fichiers tirés de ressources tierces, ou qui en reprennent des identifiants.
Chaque ressource garde sa licence, ses droits et ses conditions. Les textes de licence sont recopiés tels quels dans
`licences/`. L'audit qui fonde cette notice a été fait le 28/11 (`audit_licences/RAPPORT.md` de l'espace de travail ;
résumé ci-dessous).

**La licence propre des contenus originaux de l'archive** (annotations, références adjugées, mesures, rapports) n'est
pas encore décidée par la propriétaire du projet. En attendant, aucune licence n'est accordée sur eux au-delà de ce que
permet la loi.

| ressource | où dans l'archive | licence | ce que la licence demande |
|---|---|---|---|
| **VerbNet 3.3**, University of Colorado | `c3_contre_expertise/verbnet/verbnet3.3/` (copie conforme) ; `c3_contre_expertise/roles_verbnet.json` (dérivé) | VerbNet 3.0 License (also applies to VerbNet 3.X versions) : `licences/VERBNET_LICENSE.txt`, recopiée de https://verbs.colorado.edu/~mpalmer/projects/verbnet/license.3.0.txt le 28/11 | la notice de copyright et la clause de non-garantie sur toutes les copies ; ne pas utiliser le nom de l'université dans la publicité. Citation demandée : Kipper, Korhonen, Ryant et Palmer, « A Large-scale Classification of English Verbs », *Language Resources and Evaluation* 42(1), 2008, p. 21-40 ; et/ou Kipper Schuler, Korhonen et Brown, « VerbNet overview, extensions, mappings and apps », tutoriel NAACL-HLT 2009 |
| **WordNet 3.0**, Princeton University | identifiants de synsets et clés de sens dans les bancs ; 259 gloses dans `bancs_phase1/etude_ressources/echantillon.txt` | WordNet 3.0 license : `licences/WORDNET_LICENSE.txt`, recopiée du fichier `LICENSE` de la distribution | la notice de copyright et la clause de non-garantie sur toutes les copies, modifications comprises ; ne pas utiliser le nom de Princeton dans la publicité |
| **WOLF** (Sagot et Fišer), version de l'Open Multilingual Wordnet 1.4 | `bancs_phase1/etude_ressources/` (listes de lemmes et d'expressions trouvées dans WOLF) ; l'historique de la branche (commit 5279353) contient une copie de WOLF retirée depuis du haut de la branche | CeCILL-C : `licences/WOLF_CeCILL-C.txt`, recopiée du fichier `LICENSE` de `omw-1.4/fra` | une copie de la licence et la notice de non-garantie ; une version modifiée reste sous CeCILL-C, avec la notice des modifications. Attribution : Benoît Sagot et Darja Fišer, WOLF (WordNet Libre du Français), http://alpage.inria.fr/~sagot/wolf-en.html |
| **WoNeF** (Pradet, de Chalendar, Baguenier Desormeaux) | rien au haut de la branche ; l'historique (commit 5279353) contient des extraits retirés depuis | licence discordante : CC BY-SA 3.0 FR (site), LGPL-LR (article de 2014). Traitée comme CC BY-SA, par prudence, en attendant la réponse des auteurs | attribution ; partage à l'identique des adaptations |
| **Iconclass** | notations et libellés dans les bancs | CC0 1.0 | aucune. Citation demandée par courtoisie : Iconclass, https://iconclass.org |
| **FrameNet 1.7** | noms de cadres seulement (`inference/`) | CC BY 3.0, d'après la distribution NLTK (à confirmer) | attribution : FrameNet, International Computer Science Institute, Berkeley |

**Ce que l'archive ne contient pas :**
- **aucune donnée** de DBnary, de l'AAT, des listes Joconde ni du Garnier : leurs noms seuls y figurent ;
- **aucune suite de douze mots ou plus** commune avec les notices de musées échantillonnées.

**Les fichiers retirés du haut de la branche** pour une licence à vérifier sont listés, avec leurs empreintes, dans
`audit_langages/RETIRES.tsv`. Ils restent dans l'historique.
