"""Recherche des notations candidates pour chaque mention : lexicale (BM25 sur libellés et mots clés, correspondances
exactes), noms propres, références de source ; routage des champs vers les chapitres."""

from __future__ import annotations

import json
import math
import re
from collections import defaultdict
from dataclasses import dataclass
from pathlib import Path

from . import references, texte
from .lecture import Description

# Chapitres où vivent les récits : une notation y est proposée seulement par le sujet (titre, alternatives, source).
RECITS = ("7", "8", "9")

# Champ → (chapitres permis, préfixes préférés). « * » : tous. Les récits et les codes à nom propre sont réglés à part.
ROUTAGE = {
    "subject.title": ("*", ("7", "9", "8", "11H", "11HH", "61", "5")),
    "subject.alternatives": ("*", ("7", "9", "8", "11H", "11HH", "61", "5")),
    "persons.who": ("01345", ("11", "31D", "32", "4")),
    "entities.type": ("1234", ("25F", "25G", "31", "4", "2")),
    "entities.attributes": ("1234", ("31", "4", "2")),
    "relations": ("12345", ("33", "34", "46C", "4")),
    "actions": ("12345", ("3", "4")),
    "gestures_emotions": ("35", ("31A23", "31A25", "56")),
    "concepts": ("125", ("5", "1")),
    "concepts.symbole": ("12345", ("1", "2", "4")),
    "roles": ("1345", ("32", "44", "45", "47", "4")),
    "setting": ("12345", ("25H", "25I", "23", "26", "41A")),
    "texts": ("4", ("49L",)),
    "genre_function": ("0145", ("48", "49M")),
    "keywords": ("1234", ("2", "4", "25", "31")),
}
# Synonymes de forme vers le vocabulaire d'Iconclass (écrits à la main, sans culture).
SYNONYMES = {"man": ("adult man",), "woman": ("adult woman",), "boy": ("child",), "girl": ("child",),
             "infant": ("baby",), "putto": ("putto", "cupid"), "ruins": ("ruin",)}
NARRATIFS = ("subject.title", "subject.alternatives")
CHAMPS_NOMS = ("persons.who", "subject.title", "subject.alternatives", "texts")
AUREOLES = frozenset({"halo", "nimbus", "aureole", "glory", "halo of light", "radiant halo", "gold halo"})
PREFIXES_SAINT = re.compile(r"^(?:saint|st|ste|s|ss|san|santa|sankt|sint|sanctus|sancta|divus|diva|blessed|holy)\s+")


@dataclass(frozen=True)
class Candidat:
    n: str
    k: int
    source: str      # lex | mot | tete | nom | ref
    score: float     # dans [0, 1]
    rang: int
    q_cov: float = 0.0
    d_cov: float = 0.0


class Base:
    """Notations compilées et index de recherche."""

    def __init__(self, dossier: Path):
        self.dossier = Path(dossier)
        self.n = {}
        for ligne in (self.dossier / "notations.jsonl").read_text(encoding="utf8").splitlines():
            r = json.loads(ligne)
            self.n[r["n"]] = r
        self.manifeste = json.loads((self.dossier / "manifeste.json").read_text(encoding="utf8"))
        self._sous_propre = {}
        self._index()

    def sous_propre(self, n: str) -> str | None:
        """Ancêtre (ou soi) à nom propre : 11H(JEROME)36 → 11H(JEROME)."""
        if n not in self._sous_propre:
            r, p = self.n.get(n), None
            while r is not None:
                if r.get("propre"):
                    p = r["n"]
                    break
                r = self.n.get(r["parent"]) if r["parent"] else None
            self._sous_propre[n] = p
        return self._sous_propre[n]

    def ancetres(self, n: str) -> list[str]:
        out, r = [], self.n.get(n)
        while r is not None and r["parent"]:
            out.append(r["parent"])
            r = self.n.get(r["parent"])
        return out

    def _index(self):
        self.postings = defaultdict(list)    # racine → [(notation, tf)]
        self.longueur = {}
        self.racines_libelle = {}
        self.par_mot = defaultdict(set)
        self.par_tete = defaultdict(set)
        self.par_nom = defaultdict(set)
        self.par_ref = defaultdict(list)      # (oeuvre, livre) → [(notation, ref)]
        for n, r in self.n.items():
            if r["gabarit"] or not r["libelle"]:
                continue
            for ref in r.get("refs", []):
                self.par_ref[(ref[0], ref[1])].append((n, tuple(ref)))
            if r.get("propre"):
                for nom in self._noms(r):
                    self.par_nom[nom].add(n)
                continue
            rl = [texte.racine(m) for m in texte.jetons(r["libelle"])]
            rk = [texte.racine(m) for k in r["mots"] for m in texte.jetons(k)]
            tf = defaultdict(int)
            for m in rl + rk:
                tf[m] += 1
            for m, c in tf.items():
                self.postings[m].append((n, c))
            self.longueur[n] = len(rl) + len(rk)
            self.racines_libelle[n] = set(rl)
            for k in r["mots"]:
                if texte.norme(k):
                    self.par_mot[texte.norme(k)].add(n)
            if r["tete"]:
                self.par_tete[r["tete"]].add(n)
        self.nb_docs = len(self.longueur)
        self.long_moy = sum(self.longueur.values()) / max(1, self.nb_docs)
        self.idf = {m: math.log(1 + (self.nb_docs - len(p) + 0.5) / (len(p) + 0.5)) for m, p in self.postings.items()}

    @staticmethod
    def _noms(r):
        noms = {r["nom"]} if r["nom"] else set()
        for k in r["mots"]:
            m = re.match(r"^([A-Z][^()]*?)\s*\((?:St|Saint)\.?\)$", k)
            if m:
                noms.add(texte.norme(m[1]))
        for alias in re.findall(r"\(([A-Z][a-z]+(?: [A-Z][a-z]+)*)\)", r["libelle"]):
            noms.add(texte.norme(alias))
        return {n for n in noms if len(n) > 2}

    def part_idf(self, commun: set[str], tout: set[str]) -> float:
        """Part, pondérée par la rareté, des mots de « tout » qui sont dans « commun »."""
        total = sum(self.idf.get(m, 0.0) for m in tout)
        return sum(self.idf.get(m, 0.0) for m in commun) / total if total else 0.0

    def bm25(self, requete: list[str], permis, k1=1.2, b=0.75, top=10):
        scores = defaultdict(float)
        for m in set(requete):
            idf = self.idf.get(m)
            if idf is None:
                continue
            for n, tf in self.postings[m]:
                if not permis(n):
                    continue
                norm = tf * (k1 + 1) / (tf + k1 * (1 - b + b * self.longueur[n] / self.long_moy))
                scores[n] += idf * norm
        return sorted(scores.items(), key=lambda x: (-x[1], len(x[0]), x[0]))[:top]


def _permis(base: Base, champ: str):
    chapitres, _ = ROUTAGE.get(champ, ("", ()))
    narratif = champ in NARRATIFS

    def ok(n):
        r = base.n[n]
        if chapitres != "*" and r["chapitre"] not in chapitres:
            return False
        if r["chapitre"] in RECITS and not narratif:
            return False
        if base.sous_propre(n) and not narratif:
            return False
        return True
    return ok


def bonus_routage(champ: str, n: str) -> float:
    _, prefs = ROUTAGE.get(champ, ("", ()))
    return 1.0 if any(n.startswith(p) for p in prefs) else 0.0


def nom_de_personne(s: str) -> str:
    return PREFIXES_SAINT.sub("", texte.norme(s))


def candidats(base: Base, desc: Description, top=10) -> list[Candidat]:
    out = []
    for m in desc.mentions:
        if m.champ == "subject.source":
            for ref in references.analyser(m.texte):
                trouves = [(n, r) for n, r in base.par_ref.get((ref[0], ref[1]), []) if references.recouvre(ref, r)]
                for i, (n, _) in enumerate(sorted(set(trouves))):
                    out.append(Candidat(n, m.k, "ref", 1.0, i))
            continue
        if m.champ in CHAMPS_NOMS:
            nom = nom_de_personne(m.texte)
            vus, pris = set(), []
            for cle, i, j in _sous_expressions(nom):
                if any(i < b and a < j for a, b in pris) or cle not in base.par_nom:
                    continue  # un nom plus long a déjà pris ces mots (« john the baptist » avant « john »)
                pris.append((i, j))
                for n in sorted(base.par_nom[cle]):
                    if n not in vus:
                        vus.add(n)
                        out.append(Candidat(n, m.k, "nom", 1.0 if cle == nom else 0.7, 0))
        if m.champ not in ROUTAGE:
            continue
        permis = _permis(base, m.champ)
        for forme in (m.norme,) + SYNONYMES.get(m.norme, ()):
            for source, index in (("mot", base.par_mot), ("tete", base.par_tete)):
                ns = [n for n in sorted(index.get(forme, ())) if permis(n)]
                poids = poids_exact(len(index.get(forme, ())))
                if poids:
                    out.extend(Candidat(n, m.k, source, poids, 0) for n in ns)
        req = [texte.racine(x) for x in texte.jetons(m.texte)]
        if not req:
            continue
        resultats = base.bm25(req, permis, top=top)
        if not resultats:
            continue
        smax = resultats[0][1]
        rq = set(req)
        for i, (n, s) in enumerate(resultats):
            rl = base.racines_libelle.get(n, set())
            rk = {texte.racine(x) for k in base.n[n]["mots"] for x in texte.jetons(k)}
            rqn = rq
            p = base.sous_propre(n)
            if p:
                # Sous un saint ou une personne nommée, le nom est déjà compté par la famille B : la couverture ne
                # mesure que le reste (l'épisode), pas « St. Jerome » répété dans chaque sous-rubrique.
                nom = {texte.racine(x) for x in texte.jetons(base.n[p]["nom"] or "")} | {"st", "saint"}
                rl, rk, rqn = rl - nom, rk - nom, rq - nom
            q_cov = base.part_idf(rqn & (rl | rk), rqn) if rqn else 0.0
            d_cov = base.part_idf(rqn & rl, rl)
            out.append(Candidat(n, m.k, "lex", round(s / smax, 4), i, round(q_cov, 4), round(d_cov, 4)))
    return out


def poids_exact(df: int) -> float:
    """Une expression égale à un mot clé ou à une tête de libellé désigne d'autant mieux qu'elle est rare."""
    if df == 0:
        return 0.0
    if df <= 3:
        return 1.0
    if df <= 10:
        return 0.6
    if df <= 40:
        return 0.3
    return 0.0


def _sous_expressions(nom: str):
    """« jerome », puis les groupes de mots d'un nom plus long (« john the baptist » dans « saint john the baptist
    preaching »), du plus long au plus court, sans mot vide seul."""
    ms = nom.split()
    out = []
    for longueur in range(len(ms), 0, -1):
        for i in range(len(ms) - longueur + 1):
            g = " ".join(ms[i:i + longueur])
            if longueur == 1 and (g in texte.VIDES or len(g) < 3):
                continue
            out.append((texte.norme(g), i, i + longueur))
    return out
