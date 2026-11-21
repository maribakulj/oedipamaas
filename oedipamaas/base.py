"""Base compilée depuis le dépôt iconclass/data (CC0, commit épinglé).

Sorties dans un dossier :
- notations.jsonl : une notation par ligne (parent, profondeur, chapitre, libellé, mots clés, tête, nom, attributs,
  références, participants), lue par la recherche (Python) ;
- base.pl : les mêmes faits pour les règles (Prolog) ;
- manifeste.json : source, commit, comptes, empreintes.
"""

from __future__ import annotations

import hashlib
import json
import math
import re
import subprocess
from collections import defaultdict
from pathlib import Path

from . import references, texte

# Chapitres où un nom entre parenthèses désigne une personne, un lieu, un récit : codes à nom propre, proposés seulement
# par un nom de la description (famille B). Ailleurs (animaux, plantes, objets), le nom est un nom commun.
CHAPITRES_PROPRES = ("1", "6", "7", "8", "9")
_ATTRIBUTS = re.compile(r"possible attributes?:\s*(?P<a>[^;~]+?)(?:\s+-\s+|\s*;|\s*~|$)")
_NOM_PAR = re.compile(r"^[^(]*\((?P<nom>[^)+.][^)]*)\)$")


def enregistrements(chemin: Path):
    rec, cle = {}, None
    for ligne in chemin.read_text(encoding="utf8").splitlines():
        if ligne == "$":
            if rec:
                yield rec
            rec, cle = {}, None
        elif ligne.startswith("; ") and cle:
            rec[cle].append(ligne[2:])
        elif len(ligne) > 2 and ligne[1] == " ":
            cle = ligne[0]
            rec.setdefault(cle, []).append(ligne[2:])
    if rec:
        yield rec


def paires(dossier: Path):
    for f in sorted(dossier.glob("*.txt")):
        if f.name.endswith(("_keys.txt", "_refs.txt", "_shakespeare.txt")):
            continue
        for ligne in f.read_text(encoding="utf8").splitlines():
            if ligne.startswith("#") or ligne.count("|") != 1:
                continue
            n, t = ligne.split("|")
            if n and t.strip():
                yield n, t.strip()


def nom_propre(n: str) -> str | None:
    """Nom entre parenthèses d'une notation qui s'y termine (11H(JEROME) → « jerome ») ; ni clé (+…) ni gabarit (...)."""
    m = _NOM_PAR.match(n)
    if not m or m["nom"].startswith("+") or "..." in m["nom"]:
        return None
    return texte.norme(m["nom"])


def attributs(libelle: str) -> list[str]:
    m = _ATTRIBUTS.search(libelle)
    if not m:
        return []
    return sorted({texte.norme(a) for a in re.split(r",|\bor\b|\band\b", m["a"]) if texte.norme(a)})


def refs_du_libelle(libelle: str) -> list:
    """Références des seules parenthèses du libellé (le texte courant ne contient pas de référence)."""
    out = []
    for par in re.findall(r"\(([^()]*\d[^()]*)\)", libelle):
        out.extend(references.analyser(par))
    return sorted(set(out))


def participants(libelle: str, mots_cles: list[str]) -> list[str]:
    """Ce qu'un libellé narratif attend de l'image : ses noms propres (mots à majuscule hors début de segment) et ses
    mots clés, en forme normalisée."""
    noms = set()
    for seg in re.split(r"[:;~()]", libelle):
        for m in seg.strip().split():
            m = m.strip(",.'\"")
            if m[:1].isupper() and m.lower() not in texte.VIDES and len(m) > 2 and m != "St.":
                noms.add(texte.norme(re.sub(r"'s$", "", m)))
    kws = {texte.norme(re.sub(r"\s*\((?:St|Saint)\.?\)", "", k)) for k in mots_cles}
    return sorted(noms | {k for k in kws if k})


def cles(depot: Path) -> dict:
    """Clés d'Iconclass (keys.txt, txt_en_keys, kw_en_keys) : {famille (« 25Fk »): {suffixe (« 12 »): {texte, mots}}}.
    Une notation de la famille F peut porter la clé s de F : « 25F23(LION) » + « 12 » → « 25F23(LION)(+12) »."""
    familles = {}
    chemin = depot / "keys.txt"
    if not chemin.exists():
        return {}
    for r in enregistrements(chemin):
        k = r.get("K", [None])[0]
        if k:
            familles[k] = {s: {"texte": "", "mots": []} for s in r.get("S", [])}

    def lignes(f):
        f = Path(f)
        if f.exists():
            for ligne in f.read_text(encoding="utf8").splitlines():
                if ligne.count("|") == 1 and "k" in ligne.split("|")[0]:
                    cle, t = ligne.split("|")
                    i = cle.index("k") + 1
                    yield cle[:i], cle[i:], t.strip()
    for fam, s, t in lignes(depot / "txt" / "en" / "txt_en_keys.txt"):
        if fam in familles and s in familles[fam]:
            familles[fam][s]["texte"] = t
    for fam, s, m in lignes(depot / "kw" / "en" / "kw_en_keys.txt"):
        if fam in familles and s in familles[fam] and m:
            familles[fam][s]["mots"].append(m)
    return {f: {s: v for s, v in d.items() if v["texte"]} for f, d in familles.items()}


def commit_du_depot(depot: Path) -> str:
    try:
        return subprocess.run(["git", "-C", str(depot), "rev-parse", "HEAD"], capture_output=True, text=True,
                              check=True).stdout.strip()
    except (OSError, subprocess.CalledProcessError):
        return "inconnu"


def q(s) -> str:
    return "'" + str(s).replace("\\", "\\\\").replace("'", "\\'") + "'"


def compiler(depot: Path, sortie: Path, wikidata: Path | None = None) -> dict:
    """wikidata : instantané P1256 (voir wikidata.py) ; ses alias s'ajoutent aux notations connues."""
    depot, sortie = Path(depot), Path(sortie)
    sortie.mkdir(parents=True, exist_ok=True)
    alias_wd = {}
    if wikidata:
        from .wikidata import alias
        alias_wd = alias(Path(wikidata))
    parent, renvois, a_cle = {}, defaultdict(list), {}
    notations = []
    for r in enregistrements(depot / "notations.txt"):
        n = r.get("N", [None])[0]
        if not n:
            continue
        notations.append(n)
        for c in r.get("C", []):
            parent[c] = n
        renvois[n].extend(r.get("R", []))
        if r.get("K"):
            a_cle[n] = r["K"][0]
    connues = set(notations)
    libelles = {n: t for n, t in paires(depot / "txt" / "en") if n in connues}
    mots_cles = defaultdict(list)
    for n, m in paires(depot / "kw" / "en"):
        if n in connues:
            mots_cles[n].append(m)

    def ancetres(n):
        out, p = [], parent.get(n)
        while p is not None and p not in out:
            out.append(p)
            p = parent.get(p)
        return out

    # Rareté des attributs de saints : un attribut porté par peu de saints désigne mieux.
    porteurs = defaultdict(set)
    attrs = {}
    for n in notations:
        if n in libelles and nom_propre(n) and n.startswith(("11H(", "11HH(")):
            attrs[n] = attributs(libelles[n])
            for a in attrs[n]:
                porteurs[a].add(n)
    nb_saints = max(1, len(attrs))

    lignes = []
    faits = [":- discontiguous ic_parent/2, ic_ancetre/2, ic_prof/2, ic_texte/2, ic_mot/2, ic_nom/2, ic_attr/3, "
             "ic_ref/5, ic_part/2, ic_propre/1, ic_renvoi/2.",
             f"ic_nb_saints({nb_saints})."]
    comptes = defaultdict(int)
    for n in notations:
        anc = ancetres(n)
        nom = nom_propre(n)
        lib = libelles.get(n, "")
        kws = sorted(set(mots_cles.get(n, [])))
        rec = {"n": n, "parent": parent.get(n), "prof": len(anc), "chapitre": n[:1], "libelle": lib,
               "mots": kws, "tete": texte.tete(lib) if lib else "", "nom": nom,
               "propre": bool(nom) and n[:1] in CHAPITRES_PROPRES,
               "cle": n in a_cle, "famille_cle": a_cle.get(n), "gabarit": "(...)" in n}
        if n in attrs:
            rec["attributs"] = [[a, round(math.log(nb_saints / len(porteurs[a])), 4)] for a in attrs[n]]
        refs = refs_du_libelle(lib) if lib else []
        if refs:
            rec["refs"] = [list(r) for r in refs]
        if lib and n[:1] in ("1", "7", "8", "9"):
            rec["participants"] = participants(lib, kws)
        if n in alias_wd:
            rec["alias"] = alias_wd[n]
            comptes["notations_a_alias"] += 1
            comptes["alias"] += len(alias_wd[n])
        lignes.append(json.dumps(rec, ensure_ascii=False, sort_keys=True))
        # Faits Prolog
        if rec["parent"]:
            faits.append(f"ic_parent({q(n)}, {q(rec['parent'])}).")
        faits.extend(f"ic_ancetre({q(n)}, {q(a)})." for a in anc)
        faits.append(f"ic_prof({q(n)}, {len(anc)}).")
        if lib:
            faits.append(f"ic_texte({q(n)}, {q(lib)}).")
        faits.extend(f"ic_mot({q(n)}, {q(texte.norme(k))})." for k in kws if texte.norme(k))
        if nom:
            faits.append(f"ic_nom({q(nom)}, {q(n)}).")
            if rec["propre"]:
                faits.append(f"ic_propre({q(n)}).")
        for a, idf in rec.get("attributs", []):
            faits.append(f"ic_attr({q(n)}, {q(a)}, {idf}).")
        for o, livre, d, f in rec.get("refs", []):
            faits.append(f"ic_ref({q(n)}, {q(o)}, {livre}, {d if d is not None else 'none'}, "
                         f"{f if f is not None else 'none'}).")
        faits.extend(f"ic_part({q(n)}, {q(p)})." for p in rec.get("participants", []))
        faits.extend(f"ic_renvoi({q(n)}, {q(c)})." for c in renvois.get(n, []))
        comptes["notations"] += 1
        comptes["libelles"] += bool(lib)
        comptes["mots_cles"] += len(kws)
        comptes["noms"] += bool(nom)
        comptes["noms_propres"] += rec["propre"]
        comptes["saints_a_attributs"] += bool(rec.get("attributs"))
        comptes["references"] += len(rec.get("refs", []))
        comptes["notations_a_reference"] += bool(rec.get("refs"))
    (sortie / "notations.jsonl").write_text("\n".join(lignes) + "\n", encoding="utf8")
    (sortie / "base.pl").write_text("\n".join(faits) + "\n", encoding="utf8")
    les_cles = cles(depot)
    (sortie / "cles.json").write_text(json.dumps(les_cles, ensure_ascii=False, sort_keys=True) + "\n", encoding="utf8")
    comptes["familles_de_cles"] = len(les_cles)
    comptes["cles"] = sum(len(d) for d in les_cles.values())
    manifeste = {"source": "iconclass/data", "commit": commit_du_depot(depot), "comptes": dict(comptes),
                 "sha256": {f: hashlib.sha256((sortie / f).read_bytes()).hexdigest()
                            for f in ("notations.jsonl", "base.pl", "cles.json")}}
    if wikidata:
        manifeste["wikidata"] = {"fichier": Path(wikidata).name,
                                 "sha256": hashlib.sha256(Path(wikidata).read_bytes()).hexdigest()}
    (sortie / "manifeste.json").write_text(json.dumps(manifeste, indent=1, sort_keys=True) + "\n", encoding="utf8")
    return manifeste
