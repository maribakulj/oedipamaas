# Installation de l'environnement de développement

Commandes exécutées et vérifiées le 23 novembre 2026 (Ubuntu 24.04, Python 3.13). Les sources, la base compilée et
les corpus vont dans `/home/user/donnees/`, hors du dépôt.

## Outils

SWI-Prolog ≥ 9.2 est nécessaire pour Janus : les paquets Ubuntu (9.0.4) sont trop anciens, on prend le PPA officiel.

```bash
add-apt-repository -y ppa:swi-prolog/stable
apt-get update
DEBIAN_FRONTEND=noninteractive apt-get install -y swi-prolog-nox
pip install janus-swi pytest
pip install -e .
```

Version obtenue : SWI-Prolog 11.0.0.

## Sources

```bash
mkdir -p /home/user/donnees && cd /home/user/donnees
GIT_LFS_SKIP_SMUDGE=1 git clone --depth 1 https://github.com/iconclass/data iconclass-data
curl -sSfLO https://wordnetcode.princeton.edu/3.0/WNprolog-3.0.tar.gz
curl -sSfLO https://wordnetcode.princeton.edu/3.0/WordNet-3.0.tar.gz
tar xzf WNprolog-3.0.tar.gz && tar xzf WordNet-3.0.tar.gz
```

Commit d'Iconclass utilisé : `0595358b0e6e1635f254124ca37db49091102614`.

## Base compilée

```bash
B=/home/user/donnees/base && mkdir -p $B
python3 -m oedipamaas.socle.compiler_iconclass /home/user/donnees/iconclass-data $B
python3 -m oedipamaas.socle.compiler_wordnet /home/user/donnees/prolog /home/user/donnees/WordNet-3.0/dict $B
python3 -m oedipamaas.socle.compiler_ressources /home/user/donnees/ressources $B   # demande xlrd (compilation)
(cd $B && swipl -g "qcompile('iconclass.pl'), qcompile('wordnet.pl'), qcompile('ressources.pl')" -t halt)
python3 -m oedipamaas.socle.construire_base $B
```

## Tests

```bash
export ICONCLASS_DATA=/home/user/donnees/iconclass-data
export WORDNET_PROLOG=/home/user/donnees/prolog
export WORDNET_DICT=/home/user/donnees/WordNet-3.0/dict
python3 -m pytest -q
```

Sans ces variables, les tests qui demandent les données réelles sont sautés.

## Analyseur syntaxique (UDPipe 1)

Compilé depuis les sources (branche `stable`, version 1.4.0, commit `a0e72fc`) ; modèles UD 2.5 de LINDAT.

```bash
cd /home/user/donnees
GIT_LFS_SKIP_SMUDGE=1 git clone --depth 1 --branch stable https://github.com/ufal/udpipe udpipe-src
(cd udpipe-src/src && make -j8 exe)
mkdir -p udpipe-modeles && cd udpipe-modeles
B=https://lindat.mff.cuni.cz/repository/bitstream/handle/11234/1-3131
curl -sSfLO $B/french-gsd-ud-2.5-191206.udpipe
curl -sSfLO $B/english-ewt-ud-2.5-191206.udpipe
```

Empreintes : `french-gsd-ud-2.5-191206.udpipe` `3b10b4c8…bea30`, `english-ewt-ud-2.5-191206.udpipe`
`784bd0fa…d9957`. **Licence des modèles : CC BY-NC-SA 4.0 (non commerciale)** — voir `DECISIONS.md` (D7).

```bash
export OEDIPAMAAS_UDPIPE=/home/user/donnees/udpipe-src/src/udpipe
export OEDIPAMAAS_MODELES=/home/user/donnees/udpipe-modeles
```

## La commande de la V1 (Prolog seul)

```bash
export OEDIPAMAAS_UDPIPE=/home/user/donnees/udpipe-src/src/udpipe
export OEDIPAMAAS_MODELES=/home/user/donnees/udpipe-modeles
swipl oedipamaas/socle/commande.pl --base /home/user/donnees/base --texte "Saint Jérôme dans son étude." --langue fr
swipl oedipamaas/socle/commande.pl --base /home/user/donnees/base --entree documents.jsonl --sortie codes.jsonl
```

`documents.jsonl` : une ligne `{"id": …, "texte": …, "langue": "fr"|"en", "genre": …}` par document. Les tests de bout
en bout demandent en plus `OEDIPAMAAS_BASE=/home/user/donnees/base`.

## Ressources de langue (D17)

Rapatriées dans `/home/user/donnees/ressources/` (hors dépôt). Les liens morphosémantiques sont compilés
(`compiler_ressources.py`, module `ressources`) ; les autres le seront à leur tour. Le moteur ne s'en sert qu'au fur et à
mesure de leur intégration, une à la fois, chacune avec sa mesure.

| Ressource | Source | Licence |
|---|---|---|
| Liens morphosémantiques de WordNet 3.0 | `https://wordnetcode.princeton.edu/standoff-files/morphosemantic-links.xls` | licence de WordNet 3.0 (Princeton) |
| VerbNet 3.3 | `https://verbs.colorado.edu/verb-index/vn/verbnet-3.3.tar.gz` | « distributed with permission of the author » (University of Colorado) ; à reconfirmer avant toute redistribution |
| FrameNet 1.7 | `https://raw.githubusercontent.com/nltk/nltk_data/gh-pages/packages/corpora/framenet_v17.zip` | Creative Commons Attribution 3.0 Unported |
| NomBank 1.0 | `https://raw.githubusercontent.com/nltk/nltk_data/gh-pages/packages/corpora/nombank.1.0.zip` | « distributed with permission » (NYU) ; les fichiers qui demandent une licence LDC (COMNOM, impression) ne sont pas inclus ; à reconfirmer avant toute redistribution |

```bash
R=/home/user/donnees/ressources && mkdir -p $R && cd $R
curl -sSLO https://wordnetcode.princeton.edu/standoff-files/morphosemantic-links.xls
curl -sSLO https://verbs.colorado.edu/verb-index/vn/verbnet-3.3.tar.gz
curl -sSLO https://raw.githubusercontent.com/nltk/nltk_data/gh-pages/packages/corpora/framenet_v17.zip
curl -sSLO https://raw.githubusercontent.com/nltk/nltk_data/gh-pages/packages/corpora/nombank.1.0.zip
```
