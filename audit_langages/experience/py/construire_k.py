#!/usr/bin/env python3
"""Version Python de la transformation (spec/SPEC.md) : construire, contrôler, compiler. Bibliothèque standard seulement.

  python3 -I construire_k.py construire ECHANTILLON_DIR K.tsv
  python3 -I construire_k.py controler  K.tsv WN30_IDS.txt        # rend les violations ; code 1 s'il y en a
  python3 -I construire_k.py compiler   K.tsv WN30_IDS.txt K_FAITS.pl
"""
from __future__ import annotations

import json
import re
import sys
import unicodedata
import xml.etree.ElementTree as ET
from dataclasses import dataclass, fields
from pathlib import Path

PREFIXE = {"n": 1, "v": 2, "a": 3, "r": 4}


# ---------------------------------------------------------------- le modèle (les quatre types de la spécification)
@dataclass(frozen=True)
class Source:
    id: str; ressource: str; version: str; sha256: str; couche_licence: str; famille: str


@dataclass(frozen=True)
class Alignement:
    id: str; de_ressource: str; de_version: str; de_id: str
    vers_ressource: str; vers_version: str; vers_id: str; methode: str; statut: str; attestation: str


@dataclass(frozen=True)
class Entree:
    id: str; genre: str; lemme: str; synset: str; source: str; localisateur: str
    nature: str; detail: str; statut: str; attestation: str; couche_licence: str


@dataclass(frozen=True)
class Vote:
    id: str; lemme: str; synset: str; rang: str; familles: str; entrees: str; statut: str


TYPES = {"S": Source, "A": Alignement, "E": Entree, "V": Vote}


@dataclass(frozen=True)
class Violation:
    code: str
    id: str


def cle_vote(lemme: str) -> str:
    # NFC, pliage de casse complet (Unicode), NFC : « İstanbul » et « Istanbul » n'ont pas la même clé ; v1 de la spec
    # disait « minuscules » : str.lower() (correspondance complète) et string_lower/2 (correspondance simple) divergeaient
    return unicodedata.normalize("NFC", unicodedata.normalize("NFC", lemme).casefold())


# ---------------------------------------------------------------- lecture et écriture du format canonique
def lire_k(chemin):
    k = {t: [] for t in TYPES}
    for ligne in Path(chemin).read_text(encoding="utf-8").splitlines():
        if not ligne:
            continue
        t, *champs = ligne.split("\t")
        k[t].append(TYPES[t](*champs))
    return k


def ecrire_k(k, chemin):
    lignes = []
    for t, cls in TYPES.items():
        for x in sorted(k[t], key=lambda x: x.id):
            lignes.append("\t".join([t] + [getattr(x, f.name) for f in fields(cls)]))
    Path(chemin).write_text("\n".join(lignes) + "\n", encoding="utf-8")


# ---------------------------------------------------------------- construire
def construire(dossier):
    d = Path(dossier)
    man = json.loads((d / "MANIFESTE.json").read_text(encoding="utf-8"))["entrees"]
    v_wolf, v_wonef, v_wn = "OMW 1.4 (fra)", "0.1 fscore (2013-07-03)", "3.0"
    sources = [
        Source("src:wolf", "WOLF", v_wolf, man["wolf_sha256"], "CeCILL-C", "WOLF"),
        Source("src:wonef-f", "WoNeF", v_wonef, man["wonef_sha256"], "CC-BY-SA", "WoNeF"),
        Source("src:wn30", "WordNet", v_wn, man["wordnet_sha256_noun_verb_adj_adv_concatenes"], "WordNet-3.0", "pivot"),
    ]
    aligns, entrees = {}, {}

    def aligner(src, ressource, version, de_id, sid, methode):
        a = Alignement(f"aln:{src}:{sid}", ressource, version, de_id, "WordNet", v_wn, sid, methode, "non_attestee", "")
        aligns[a.id] = a

    for n, ligne in enumerate((d / "wolf.tab").read_text(encoding="utf-8").splitlines(), 1):
        sid, rel, lemme = ligne.split("\t")
        assert rel == "fra:lemma"
        aligner("src:wolf", "WOLF", v_wolf, sid, sid, "identité du décalage OMW")
        e = Entree(f"lex:src:wolf:{sid}:{lemme}", "lexicalisation", lemme, sid, "src:wolf", f"ligne {n}",
                   "alignement_automatique", "wolf-omw", "non_attestee", "", "CeCILL-C")
        entrees[e.id] = e
    for syn in ET.parse(d / "wonef.xml").getroot().iter("SYNSET"):
        ident = syn.findtext("ID")                       # eng-30-00001740-n
        _, _, decalage, pos = ident.split("-")
        sid = f"{decalage}-{'r' if pos == 'b' else pos}"
        lits = [(x.text, x.get("lnote")) for x in syn.iter("LITERAL") if x.text != "_EMPTY_"]
        if not lits:
            continue
        aligner("src:wonef-f", "WoNeF", v_wonef, ident, sid, "identifiant eng-30 de WoNeF ; b vers r")
        for lemme, note in lits:
            e = Entree(f"lex:src:wonef-f:{sid}:{lemme}", "lexicalisation", lemme, sid, "src:wonef-f", ident,
                       "alignement_automatique", note or "sans_note", "non_attestee", "", "CC-BY-SA")
            entrees[e.id] = e
    # le vote : un par couple (lemme normalisé, synset) ; il classe, il n'atteste pas
    groupes, famille = {}, {s.id: s.famille for s in sources}
    for e in entrees.values():
        groupes.setdefault((cle_vote(e.lemme), e.synset), []).append(e)
    votes = []
    for (lemme, sid), es in groupes.items():
        fams = sorted({famille[e.source] for e in es})
        votes.append(Vote(f"vote:{sid}:{lemme}", lemme, sid, str(len(fams)), ",".join(fams),
                          ",".join(sorted(e.id for e in es)), "non_attestee"))
    return {"S": sources, "A": list(aligns.values()), "E": list(entrees.values()), "V": votes}


# ---------------------------------------------------------------- contrôler : les invariants de la spécification
def controler(k, pivot):
    v = []
    src = {s.id: s for s in k["S"]}
    aln = {(a.de_ressource, a.vers_id) for a in k["A"]}
    ent = {e.id: e for e in k["E"]}
    for e in k["E"]:
        s = src.get(e.source)
        if s is None or not (s.ressource and s.version and s.sha256):
            v.append(Violation("INV1_SOURCE", e.id))
        if (s.ressource if s else None, e.synset) not in aln:
            v.append(Violation("INV7_ENTREE_ALIGNEE", e.id))
        if s is not None and e.couche_licence != s.couche_licence:
            v.append(Violation("INV9_LICENCE", e.id))
    for a in k["A"]:
        if not (a.de_ressource and a.de_version and a.vers_ressource and a.vers_version):
            v.append(Violation("INV2_ALIGN_VERSION", a.id))
        if not (a.vers_ressource == "WordNet" and a.vers_version == "3.0" and a.vers_id in pivot):
            v.append(Violation("INV3_PIVOT", a.id))
    for x in k["V"]:
        if x.statut != "non_attestee":
            v.append(Violation("INV4_VOTE_CLASSE", x.id))
        ids = [i for i in x.entrees.split(",") if i]
        if any(i not in ent or (cle_vote(ent[i].lemme), ent[i].synset) != (x.lemme, x.synset) for i in ids):
            v.append(Violation("INV8_VOTE", x.id))
        else:
            fams = sorted({src[ent[i].source].famille for i in ids if ent[i].source in src})
            if not ids or str(len(fams)) != x.rang or ",".join(fams) != x.familles:
                v.append(Violation("INV8_VOTE", x.id))
    for x in k["E"] + k["A"]:
        if x.statut not in ("attestee", "non_attestee") or (x.statut == "attestee") != bool(x.attestation):
            v.append(Violation("INV5_ATTESTATION", x.id))
    for t in TYPES:
        vus = set()
        for x in k[t]:
            if x.id in vus:
                v.append(Violation("INV6_UNICITE", x.id))
            vus.add(x.id)
    return sorted(set(v), key=lambda x: (x.code, x.id))


# ---------------------------------------------------------------- compiler vers des faits Prolog
def chaine(s):
    return '"' + s.replace("\\", "\\\\").replace('"', '\\"') + '"'


def compiler(k, pivot):
    violations = controler(k, pivot)
    if violations:
        raise ValueError(f"compilation refusée : {len(violations)} violation(s), la première {violations[0]}")
    src = {s.id: s for s in k["S"]}
    sorties = [":- module(k_federe, [k_source/6, k_sens/5, k_vote/4]).", ":- encoding(utf8)."]
    for s in sorted(k["S"], key=lambda s: s.id):
        sorties.append(f"k_source({', '.join(chaine(x) for x in (s.id, s.ressource, s.version, s.sha256, s.couche_licence, s.famille))}).")
    for e in sorted(k["E"], key=lambda e: e.id):
        decalage, pos = e.synset.split("-")
        sorties.append(f"k_sens({pos}, {chaine(e.lemme)}, {PREFIXE[pos] * 100000000 + int(decalage)}, {chaine(e.id)}, {e.statut}).")
    for x in sorted(k["V"], key=lambda x: x.id):
        decalage, pos = x.synset.split("-")
        fams = "[" + ",".join(chaine(f) for f in x.familles.split(",")) + "]"
        sorties.append(f"k_vote({chaine(x.lemme)}, {PREFIXE[pos] * 100000000 + int(decalage)}, {x.rang}, {fams}).")
    return "\n".join(sorties) + "\n"


def lire_pivot(chemin):
    return set(Path(chemin).read_text(encoding="utf-8").split())


def main(argv):
    cmd = argv[0]
    if cmd == "construire":
        ecrire_k(construire(argv[1]), argv[2])
    elif cmd == "controler":
        vs = controler(lire_k(argv[1]), lire_pivot(argv[2]))
        for x in vs:
            print(f"{x.code}\t{x.id}")
        return 1 if vs else 0
    elif cmd == "compiler":
        Path(argv[3]).write_text(compiler(lire_k(argv[1]), lire_pivot(argv[2])), encoding="utf-8")
    else:
        raise SystemExit(__doc__)
    return 0


if __name__ == "__main__":
    sys.exit(main(sys.argv[1:]))
