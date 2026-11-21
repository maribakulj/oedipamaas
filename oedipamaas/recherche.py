"""Recherche des notations candidates pour chaque mention : lexicale (BM25 sur libellés et mots clés, expressions
exactes), sémantique (vecteurs), noms propres, références de source. Aucun filtre par chapitre ni liste écrite : chaque
mention interroge toutes les notations ; ce qui vaut quoi s'apprend ensuite à partir des traits."""

from __future__ import annotations

import json
import math
import re
from collections import defaultdict
from dataclasses import dataclass
from pathlib import Path

from . import references, texte
from .lecture import Description

# Champs dont le texte interroge Iconclass. « subject.source » passe par les références ; « period_style » (date,
# école) ne désigne pas une notation.
CHAMPS_RECHERCHE = ("subject.title", "subject.alternatives", "subject.type", "persons.who", "persons.recognised_by",
                    "entities.type", "entities.attributes", "relations", "actions", "gestures_emotions", "concepts",
                    "concepts.symbole", "roles", "setting", "texts", "genre_function", "keywords")
CHAMPS_NOMS = ("persons.who", "subject.title", "subject.alternatives", "texts")
# Honorifiques des noms de saints et de personnes sacrées (fait de langue : abréviations usuelles en anglais, latin,
# langues romanes et germaniques).
HONORIFIQUES = r"(?:saint|st|ste|s|ss|san|santa|sankt|sint|sanctus|sancta|divus|diva|blessed|holy)"
PREFIXES_SAINT = re.compile(rf"^{HONORIFIQUES}\s+")
_HONORIFIQUE_AVANT = re.compile(rf"\b{HONORIFIQUES}\s+$")


@dataclass(frozen=True)
class Candidat:
    n: str
    k: int
    source: str      # lex | sem | mot | tete | nom | ref
    score: float     # dans [0, 1]
    rang: int
    q_cov: float = 0.0
    d_cov: float = 0.0
    contexte: str = ""   # pour un nom : personne | honorifique | reference | libre


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
        self._ancetres = {}
        self._index()

    def sous_propre(self, n: str) -> str | None:
        """Ancêtre (ou soi) à nom propre : 11H(JEROME)36 → 11H(JEROME)."""
        if n not in self._sous_propre:
            p = next((a for a in [n] + self.ancetres(n) if self.n.get(a, {}).get("propre")), None)
            self._sous_propre[n] = p
        return self._sous_propre[n]

    def ancetres(self, n: str) -> list[str]:
        if n not in self._ancetres:
            out, r = [], self.n.get(n)
            while r is not None and r["parent"]:
                out.append(r["parent"])
                r = self.n.get(r["parent"])
            self._ancetres[n] = out
        return self._ancetres[n]

    def expressions(self, n: str) -> set[str]:
        """Mots clés et tête du libellé d'une notation, normalisés (pour reconnaître un ancêtre dans la description)."""
        r = self.n[n]
        return {texte.norme(k) for k in r["mots"] if texte.norme(k)} | ({r["tete"]} if r["tete"] else set())

    def _index(self):
        self.postings = defaultdict(list)    # racine → [(notation, tf)]
        self.longueur = {}
        self.racines_libelle = {}
        self.racines_mots = {}
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
            self.racines_mots[n] = set(rk)
            for k in r["mots"] + r.get("alias", []):    # alias Wikidata : expression exacte seulement
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
        for alias in r.get("alias", []):            # Wikidata (P1256) : « saint jerome », « hieronymus »…
            noms.add(PREFIXES_SAINT.sub("", alias))
        return {n for n in noms if len(n) > 2}

    def part_idf(self, commun: set[str], tout: set[str]) -> float:
        """Part, pondérée par la rareté, des mots de « tout » qui sont dans « commun »."""
        total = sum(self.idf.get(m, 0.0) for m in tout)
        return sum(self.idf.get(m, 0.0) for m in commun) / total if total else 0.0

    def couvertures(self, n: str, rq: set[str]) -> tuple[float, float]:
        """(part de la mention couverte par la notation, part du libellé couverte par la mention), pondérées par la
        rareté des mots. Sous un nom propre, le nom est compté par ailleurs : il est retiré des deux côtés."""
        rl, rk = self.racines_libelle.get(n, set()), self.racines_mots.get(n, set())
        p = self.sous_propre(n)
        if p:
            nom = {texte.racine(x) for x in texte.jetons(self.n[p]["nom"] or "")} | {"st", "saint"}
            rl, rk, rq = rl - nom, rk - nom, rq - nom
        q_cov = self.part_idf(rq & (rl | rk), rq) if rq else 0.0
        return round(q_cov, 4), round(self.part_idf(rq & rl, rl), 4)

    def bm25(self, requete: list[str], k1=1.2, b=0.75, top=10):
        scores = defaultdict(float)
        for m in set(requete):
            idf = self.idf.get(m)
            if idf is None:
                continue
            for n, tf in self.postings[m]:
                norm = tf * (k1 + 1) / (tf + k1 * (1 - b + b * self.longueur[n] / self.long_moy))
                scores[n] += idf * norm
        return sorted(scores.items(), key=lambda x: (-x[1], len(x[0]), x[0]))[:top]


def rarete_exacte(df: int) -> float:
    """Poids d'une expression égale à un mot clé ou à une tête de libellé : décroît avec le nombre de notations qui la
    portent (1 si une seule)."""
    return round(1.0 / (1.0 + math.log(df)), 4) if df else 0.0


def nom_de_personne(s: str) -> str:
    return PREFIXES_SAINT.sub("", texte.norme(s))


def fragments_de_noms(champ: str, texte_brut: str) -> list[tuple[str, int, str]]:
    """Groupes de mots où chercher un nom propre, avec leur contexte. Dans « persons.who », l'expression entière (le
    descripteur y nomme la personne) ; ailleurs, chaque groupe de mots, marqué « honorifique » s'il suit « saint »,
    « St. »…, « reference » s'il est suivi d'un nombre (« Mark 14 »), « libre » sinon. Rend (groupe, début, contexte)."""
    mots = texte.mots(texte_brut)
    if champ == "persons.who":
        nom = nom_de_personne(" ".join(mots))
        return [(nom, 0, "personne")] if nom else []
    out = []
    for longueur in range(min(5, len(mots)), 0, -1):
        for i in range(len(mots) - longueur + 1):
            g = mots[i:i + longueur]
            if (longueur == 1 and (g[0] in texte.VIDES or len(g[0]) < 3)) or g[0] in texte.VIDES:
                continue
            avant, apres = " ".join(mots[:i]) + " ", mots[i + longueur] if i + longueur < len(mots) else ""
            ctx = ("reference" if apres[:1].isdigit() else
                   "honorifique" if _HONORIFIQUE_AVANT.search(avant) else "libre")
            out.append((texte.norme(" ".join(g)), i, ctx))
    return out


def candidats_semantiques(base: Base, desc: Description, sem, top=8) -> list[Candidat]:
    import numpy as np
    masque = base.__dict__.get("_masque_sem")
    if masque is None:
        masque = base._masque_sem = np.array([n in base.longueur for n in sem.ids])
    out = []
    mentions = [m for m in desc.mentions if m.champ in CHAMPS_RECHERCHE]
    sem.encoder([m.texte for m in mentions])   # un seul passage du modèle pour toute l'image
    for m in mentions:
        rq = {texte.racine(x) for x in texte.jetons(m.texte)}
        for i, (n, s) in enumerate(sem.voisins(m.texte, masque, top=top)):
            q_cov, d_cov = base.couvertures(n, rq)
            out.append(Candidat(n, m.k, "sem", s, i, q_cov, d_cov))
    return out


def candidats(base: Base, desc: Description, top=10, sem=None) -> list[Candidat]:
    out = candidats_semantiques(base, desc, sem) if sem is not None else []
    for m in desc.mentions:
        if m.champ == "subject.source":
            for ref in references.analyser(m.texte):
                trouves = [(n, r) for n, r in base.par_ref.get((ref[0], ref[1]), []) if references.recouvre(ref, r)]
                for i, (n, _) in enumerate(sorted(set(trouves))):
                    out.append(Candidat(n, m.k, "ref", 1.0, i))
            continue
        if m.champ in CHAMPS_NOMS:
            vus, pris = set(), []
            for cle, i, ctx in fragments_de_noms(m.champ, m.texte):
                j = i + len(cle.split())
                if any(i < b and a < j for a, b in pris) or cle not in base.par_nom:
                    continue  # un nom plus long a déjà pris ces mots (« john the baptist » avant « john »)
                pris.append((i, j))
                for n in sorted(base.par_nom[cle]):
                    if n not in vus:
                        vus.add(n)
                        out.append(Candidat(n, m.k, "nom", 1.0, 0, contexte=ctx))
        if m.champ not in CHAMPS_RECHERCHE:
            continue
        for source, index in (("mot", base.par_mot), ("tete", base.par_tete)):
            ns = sorted(index.get(m.norme, ()))
            w = rarete_exacte(len(ns))
            out.extend(Candidat(n, m.k, source, w, 0) for n in ns[:50])
        req = [texte.racine(x) for x in texte.jetons(m.texte)]
        if not req:
            continue
        resultats = base.bm25(req, top=top)
        if not resultats:
            continue
        smax, rq = resultats[0][1], set(req)
        for i, (n, s) in enumerate(resultats):
            q_cov, d_cov = base.couvertures(n, rq)
            out.append(Candidat(n, m.k, "lex", round(s / smax, 4), i, q_cov, d_cov))
    return out
