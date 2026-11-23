# oedipamaas

Moteur iconographique : traduit une description d'image écrite en mots (sujet, personnes, objets, relations, concepts,
textes…) en codes [Iconclass](https://iconclass.org), chaque code avec sa preuve. Il tourne hors ligne, sans appel
payant, et se rejoue sur toutes les descriptions déjà faites. Conception : [CONCEPTION.md](CONCEPTION.md).

**État** : la version 1.0 (moteur Prolog, sans réseau de neurones, conception arrêtée) est en reconstruction. Les
commandes ci-dessous sont celles de la version 0.2, gardée comme ligne de base.

## Installation

Python ≥ 3.12 et [SWI-Prolog](https://www.swi-prolog.org) (≥ 9.1, pour le pont Janus).

```sh
pip install -e ".[prolog,semantique]"
git clone https://github.com/iconclass/data iconclass-data
```

## Utilisation

```sh
# 1. Compiler la base depuis Iconclass (hiérarchie, noms, attributs des saints, références de source…)
oedipamaas base iconclass-data base/

# 2. (facultatif) Vecteurs de sens des libellés pour la recherche sémantique
oedipamaas vecteurs base/ --revision <commit du modèle>

# Wikidata (facultatif) : alias des notations, à passer à « oedipamaas base … --wikidata p1256.json »
python -c "from oedipamaas import wikidata; wikidata.telecharger('p1256.json')"

# 3. Coder un dossier de descriptions (un JSON par image) ; --poids : régression logistique apprise
oedipamaas coder base/ descriptions/ codes.jsonl --semantique paraphrase-multilingual-MiniLM-L12-v2

# 4. Voir les preuves d'un code
oedipamaas expliquer base/ descriptions/exemple.json 11H(JEROME) --semantique paraphrase-multilingual-MiniLM-L12-v2
```

Le format des descriptions et celui de `codes.jsonl` sont décrits dans [CONCEPTION.md](CONCEPTION.md) (§ 8 et § 12).

## Tests

```sh
pytest tests
```

Les tests construisent une petite base Iconclass et n'utilisent que des descriptions écrites pour eux.

## Sources et licences

Iconclass (CC0), Wikidata (CC0), modèles de phrases sous licence Apache-2.0 ou MIT, SWI-Prolog (BSD-2).
