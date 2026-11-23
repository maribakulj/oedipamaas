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
(cd $B && swipl -g "qcompile('iconclass.pl'), qcompile('wordnet.pl')" -t halt)
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
