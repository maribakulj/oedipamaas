"""Compile WordNet 3.0 (Princeton) en un module Prolog (socle 1.0, pièce 3) : les faits de l'édition Prolog officielle
(WNprolog 3.0) gardés tels quels, et les listes d'exceptions de la morphologie (dict/*.exc), absentes de cette
édition, en faits exc/3. Transcription sans jugement.

Faits du module wordnet (schéma de WNprolog, prologdb(5WN)) :
  s(Synset, Rang, Mot, Type, Sens, Compte)   mots des synsets (Type : n, v, a, s, r)
  hyp(Synset, Hyperonyme)    ins(Synset, Classe)    der(S1, R1, S2, R2)    per(S1, R1, S2, R2)
  mm(S, Membre)  ms(S, Substance)  mp(S, Partie)    sim(S1, S2)
  exc(Type, Forme, Lemme)    exceptions de la morphologie (noun.exc, verb.exc, adj.exc, adv.exc)
  lexfile(Synset, Fichier)   le fichier lexicographique d'un synset nominal ou verbal (dict/data.noun, data.verb,
                             dict/lexnames : noun.person, noun.artifact, verb.motion…) ; deux fichiers nominaux
                             différents sont disjoints par construction (docs/FONDEMENTS.md, § 2)
Usage : python -m oedipamaas.socle.compiler_wordnet DOSSIER_WNPROLOG DOSSIER_DICT SORTIE/"""
import hashlib
import json
import re
import sys
from pathlib import Path

RELATIONS = {"s": 6, "hyp": 2, "ins": 2, "der": 4, "per": 4, "mm": 2, "ms": 2, "mp": 2, "sim": 2}
EXCEPTIONS = {"noun.exc": "n", "verb.exc": "v", "adj.exc": "a", "adv.exc": "r"}
# forme exacte de chaque fait (l'édition contient quelques lignes mal formées, écartées et comptées)
FORMES = {p: re.compile(rf"{p}\(" + ",".join([r"\d+"] * a) + r"\)\.") for p, a in RELATIONS.items()}
FORMES["s"] = re.compile(r"s\(\d+,\d+,'(?:[^']|'')*',[nvasr],\d+,\d+\)\.")


def q(s):
    return "'" + s.replace("\\", "\\\\").replace("'", "\\'") + "'"


def compiler(dossier_prolog, dossier_dict, sortie):
    dossier_prolog, dossier_dict, sortie = Path(dossier_prolog), Path(dossier_dict), Path(sortie)
    sortie.mkdir(parents=True, exist_ok=True)
    chemin = sortie / "wordnet.pl"
    comptes, empreintes, ecartees = {}, {}, {}
    exports = ", ".join(f"{p}/{a}" for p, a in RELATIONS.items()) + ", exc/3, lexfile/2"
    with open(chemin, "w", encoding="utf-8") as out:
        out.write(f":- module(wordnet, [{exports}]).\n:- encoding(utf8).\n")
        for p in RELATIONS:
            src = dossier_prolog / f"wn_{p}.pl"
            empreintes[src.name] = hashlib.sha256(src.read_bytes()).hexdigest()
            n = 0
            forme = FORMES[p]
            for ligne in src.read_text(encoding="latin-1").splitlines():
                if forme.fullmatch(ligne):
                    out.write(ligne + "\n")
                    n += 1
                elif re.match(rf"{p}\(", ligne):
                    ecartees[src.name] = ecartees.get(src.name, 0) + 1   # ligne mal formée de l'édition
            comptes[p] = n
        n = 0
        for nom, t in EXCEPTIONS.items():
            src = dossier_dict / nom
            empreintes[nom] = hashlib.sha256(src.read_bytes()).hexdigest()
            for ligne in src.read_text(encoding="latin-1").splitlines():
                mots = ligne.split()
                for lemme in mots[1:]:
                    out.write(f"exc({t}, {q(mots[0].replace('_', ' '))}, {q(lemme.replace('_', ' '))}).\n")
                    n += 1
        comptes["exc"] = n
        noms = {}
        for ligne in (dossier_dict / "lexnames").read_text(encoding="latin-1").splitlines():
            champs = ligne.split()
            if len(champs) >= 2:
                noms[champs[0]] = champs[1]
        empreintes["lexnames"] = hashlib.sha256((dossier_dict / "lexnames").read_bytes()).hexdigest()
        n = 0
        for nom, prefixe in (("data.noun", 1), ("data.verb", 2)):
            src = dossier_dict / nom
            empreintes[nom] = hashlib.sha256(src.read_bytes()).hexdigest()
            for ligne in src.read_text(encoding="latin-1").splitlines():
                if ligne.startswith("  "):
                    continue                                    # en-tête de licence
                champs = ligne.split(" ", 2)
                if len(champs) < 3 or not champs[0].isdigit():
                    continue
                out.write(f"lexfile({prefixe * 100000000 + int(champs[0])}, {q(noms[champs[1]])}).\n")
                n += 1
        comptes["lexfile"] = n
    manifeste = {"source": "WordNet 3.0 (Princeton), édition Prolog WNprolog 3.0, dict/*.exc, dict/data.noun, data.verb, lexnames",
                 "licence": "WordNet 3.0 license (Princeton University)", "comptes": comptes,
                 "lignes_mal_formees_ecartees": ecartees,
                 "sha256_sources": empreintes,
                 "sha256": {"wordnet.pl": hashlib.sha256(chemin.read_bytes()).hexdigest()}}
    (sortie / "manifeste-wordnet.json").write_text(json.dumps(manifeste, ensure_ascii=False, indent=1) + "\n",
                                                   encoding="utf-8")
    return manifeste


if __name__ == "__main__":
    if len(sys.argv) != 4:
        raise SystemExit(__doc__)
    print(json.dumps(compiler(*sys.argv[1:])["comptes"]))
