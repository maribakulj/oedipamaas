"""Écrit MANIFESTE.json (URL, date, version, licence, SHA-256) dans chaque
répertoire de ressource téléchargée pour la mesure du 28/11/2026.

Usage : python3 -I outils/ressources/manifeste.py
Lecture seule des fichiers (hachage) ; seul MANIFESTE.json est écrit.
"""
import hashlib
import json
import os
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from commun import RESSOURCES  # noqa: E402

META = {
    "wonef": {
        "urls": ["https://wonef.fr/data/wonef-precision-0.1.xml.bz2", "https://wonef.fr/data/wonef-fscore-0.1.xml.bz2",
                 "https://wonef.fr/data/wonef-coverage-0.1.xml.bz2"],
        "redirection": "wonef.fr -> wonef.pradet.me",
        "date": "2026-11-28",
        "version": "0.1 (fichiers datés du 03/07/2013, en-tête Last-Modified)",
        "licence": "CC BY-SA 3.0 FR d'après le site (page d'accueil) ; LGPL-LR d'après l'article GWC 2014 : DISCORDANCE à lever",
    },
    "dbnary": {
        "urls": ["https://kaiko.getalp.org/static/ontolex/latest/" + f for f in
                 ["fr_dbnary_ontolex.ttl.bz2", "fr_dbnary_enhancement.ttl.bz2", "fr_dbnary_lime.ttl.bz2",
                  "fr_dbnary_statistics.ttl.bz2", "en_dbnary_ontolex.ttl.bz2", "en_dbnary_enhancement.ttl.bz2"]],
        "date": "2026-11-28",
        "version": "extraction du dump Wiktionnaire fr 20261101 (fichiers du 11/11/2026) ; en : fichiers du 12/11/2026",
        "licence": "données CC BY-SA 4.0 (dérivées du Wiktionnaire) ; extracteurs MIT (page about-dbnary)",
        "sous_ensemble": "dumps complets téléchargés ; seuls retenus à la lecture : entrées fr (lemme, catégorie, nombre de sens), "
                         "traductions fr->en du Wiktionnaire fr et en->fr du Wiktionnaire en (outils/ressources/lexiques.py)",
    },
    "joconde_vocabulaires": {
        "urls": ["https://opentheso.huma-num.fr/api/all/theso?id=th%d&format=turtle" % n for n in
                 [284, 285, 286, 287, 288, 289, 290, 291, 292, 294, 295, 298, 302, 304, 305, 306]],
        "date": "2026-11-28",
        "version": "export Opentheso du jour (listes vivantes, enrichies au fil des versements Joconde)",
        "licence": "Licence ouverte Etalab (page « Télécharger les vocabulaires scientifiques du Service des musées de France »)",
        "note": "referentiels.culture.fr refuse la session (403 « Attack detected ») ; l'instance opentheso.huma-num.fr répond",
    },
    "garnier": {
        "urls": ["https://www.culture.gouv.fr/mc/content/download/... (voir liste_urls.txt)"],
        "date": "2026-11-28",
        "version": "Thésaurus iconographique, F. Garnier, Le Léopard d'Or, 1984 ; PDF mis en ligne le 04/06/2020",
        "licence": "site culture.gouv.fr : « sauf mention contraire, contenus sous licence etalab-2.0 » ; "
                   "le PDF est la numérisation d'un ouvrage édité (Le Léopard d'Or) sans mention de licence : À CONFIRMER",
        "note": "PDF numérisés en images (aucune couche texte) ; le PDF intégral s'interrompt (transfert partiel, reprise refusée) ; "
                "la version exploitable est la liste Opentheso th285",
    },
    "iconclass": {
        "urls": ["https://raw.githubusercontent.com/iconclass/data/0595358b0e6e1635f254124ca37db49091102614/"],
        "date": "2026-11-28",
        "version": "commit 0595358b0e6e1635f254124ca37db49091102614 (= HEAD distant le 28/11/2026)",
        "licence": "CC0 1.0 (fichier LICENSE)",
    },
    "aat": {
        "urls": ["http://aatdownloads.getty.edu/VocabData/explicit.zip"],
        "date": "2026-11-28",
        "version": "explicit.zip, Last-Modified 17/10/2026",
        "licence": "ODC-By 1.0 (page du Download Center et dcterms:license de chaque concept)",
        "note": "vocab.getty.edu : 403 ; vocabularies.getty.edu : tunnel refusé (502) ; aatdownloads.getty.edu et data.getty.edu répondent",
    },
}


def sha(p):
    h = hashlib.sha256()
    with open(p, "rb") as f:
        for b in iter(lambda: f.read(1 << 20), b""):
            h.update(b)
    return h.hexdigest()


if __name__ == "__main__":
    for nom, meta in META.items():
        d = os.path.join(RESSOURCES, nom)
        fichiers = {}
        for racine, _, fs in os.walk(d):
            for f in sorted(fs):
                if f == "MANIFESTE.json":
                    continue
                p = os.path.join(racine, f)
                fichiers[os.path.relpath(p, d)] = {"octets": os.path.getsize(p), "sha256": sha(p)}
        meta = dict(meta, fichiers=fichiers)
        json.dump(meta, open(os.path.join(d, "MANIFESTE.json"), "w"), indent=1, ensure_ascii=False)
        print(nom, len(fichiers), "fichiers", file=sys.stderr)
