"""Le moteur : lecture → recherche → raisonnement (Prolog, par Janus) → score → hiérarchie → sortie."""

from __future__ import annotations

import json
import math
import subprocess
from collections import defaultdict
from pathlib import Path

from . import __version__, recherche, texte
from .lecture import Description
from .recherche import AUREOLES, PREFIXES_SAINT, Base

ICI = Path(__file__).resolve().parent
CHAMPS_ATTRIBUTS = ("entities.type", "entities.attributes", "keywords", "persons.recognised_by", "concepts.symbole",
                    "setting", "actions")
CHAMPS_PARTICIPANTS = ("persons.who", "persons.recognised_by", "entities.type", "entities.attributes", "actions",
                       "keywords", "relations", "gestures_emotions", "roles", "setting", "texts", "concepts",
                       "concepts.symbole")
BONUS_ROUTAGE = 0.5
BONUS_INDICE = 0.3
SEUIL = 2.0          # sans poids appris : seuil provisoire
MAX_RETENUS = 10
REGLES = ("A.tete", "A.mot", "A.libelle", "A.sens", "B.nom", "C.attributs", "C.sans_nom", "D.source", "D.titre",
          "D.sens", "D.participants", "S.titre", "S.sens")


def mesures_recherche(cands) -> dict:
    """Par notation, les mesures brutes de la recherche : meilleur cosinus, meilleure couverture lexicale, meilleur
    rang, nombre de mentions qui la proposent."""
    out = defaultdict(lambda: {"sem_max": 0.0, "lex_max": 0.0, "dcov_max": 0.0, "qcov_max": 0.0, "rang_min": 20.0,
                               "nb_propositions": 0.0})
    for c in cands:
        a = out[c.n]
        a["nb_propositions"] += 1
        if c.source == "sem":
            a["sem_max"] = max(a["sem_max"], c.score)
        if c.source == "lex":
            a["lex_max"] = max(a["lex_max"], c.score)
        if c.source in ("sem", "lex"):
            a["dcov_max"] = max(a["dcov_max"], c.d_cov)
            a["qcov_max"] = max(a["qcov_max"], c.q_cov)
            a["rang_min"] = min(a["rang_min"], float(c.rang))
    return out


def traits(c: dict, rang: int, nb_codes: int, desc: Description, base: Base, recherche_: dict | None = None) -> dict:
    """Ce que la calibration apprend à peser : contribution de chaque règle, forme de la preuve, place du code, mesures
    brutes de la recherche."""
    t = {r: 0.0 for r in REGLES}
    if recherche_ is not None and c["code"] in recherche_:
        t |= recherche_[c["code"]]
    else:
        t |= {"sem_max": 0.0, "lex_max": 0.0, "dcov_max": 0.0, "qcov_max": 0.0, "rang_min": 20.0,
              "nb_propositions": 0.0}
    for p in c["preuves"]:
        if p["regle"] in t:
            t[p["regle"]] = max(t[p["regle"]], p["contribution"])
    r = base.n[c["code"]]
    t |= {"routage": float(c.get("_routage", False)), "prof": float(r["prof"]),
          "nb_mentions": float(len(c["mentions"])), "nb_familles": float(len(c["familles"])),
          "second_recit": float(bool(c.get("second_recit"))),
          "repli": float(any(p["regle"] == "I.repli" for p in c["preuves"])),
          "descendant": float(any(p["regle"] == "I.descendant" for p in c["preuves"])),
          "rang": float(rang), "score": c["score"], "nb_codes_image": float(nb_codes),
          "conf_sujet": float(desc.sujet_confiance or 0.0), "v2": float(desc.format == "v2"),
          "cle": float(r["cle"]), "propre": float(bool(base.sous_propre(c["code"])))}
    for ch in "0123456789":
        t[f"ch{ch}"] = float(r["chapitre"] == ch)
    return {k: round(v, 4) for k, v in t.items()}


def version_git() -> str:
    try:
        sha = subprocess.run(["git", "-C", str(ICI), "rev-parse", "--short", "HEAD"], capture_output=True, text=True,
                             check=True).stdout.strip()
        sale = subprocess.run(["git", "-C", str(ICI), "status", "--porcelain", "--", "."], capture_output=True,
                              text=True, check=True).stdout.strip()
        return f"{__version__}+g{sha}{'.modifie' if sale else ''}"
    except (OSError, subprocess.CalledProcessError):
        return __version__


def q(s) -> str:
    return "'" + str(s).replace("\\", "\\\\").replace("'", "\\'") + "'"


class Moteur:
    def __init__(self, dossier_base: Path, poids: Path | None = None, semantique: str | None = None):
        import janus_swi as janus  # importé ici : la lecture et la recherche n'en ont pas besoin

        self.janus = janus
        self.base = Base(dossier_base)
        self.sem = None
        if semantique:
            from .semantique import IndexSemantique
            meta = json.loads((Path(dossier_base) / f"vecteurs-{semantique.split('/')[-1]}.json").read_text())
            self.sem = IndexSemantique(dossier_base, meta["modele"], meta["revision"])
        base_pl = Path(dossier_base) / "base.pl"
        janus.query_once(f"consult({q(base_pl)})")
        janus.query_once(f"consult({q(ICI / 'regles' / 'regles.pl')})")
        self.poids = json.loads(Path(poids).read_text()) if poids else None
        self.versions = {"moteur": version_git(),
                         "base": f"iconclass {self.base.manifeste.get('commit', '?')[:7]}",
                         "regles": "v1", "poids": self.poids["version"] if self.poids else None,
                         "semantique": f"{self.sem.modele_nom} {self.sem.revision}" if self.sem else None}

    def probabilite(self, t: dict) -> float:
        """Régression logistique apprise (poids/vN.json) : traits centrés-réduits, puis sigmoïde."""
        w = self.poids
        z = w["biais"] + sum(w["poids"][k] * (t.get(k, 0.0) - w["moyenne"][k]) / w["ecart"][k] for k in w["poids"])
        return 1.0 / (1.0 + math.exp(-max(-30.0, min(30.0, z))))

    # ---------------------------------------------------------------------------------------------------------------
    def faits(self, desc: Description, cands: list[recherche.Candidat]) -> list[str]:
        f = [f"m({m.k}, {q(m.champ)})" for m in desc.mentions]
        for c in cands:
            f.append(f"cand({q(c.n)}, {c.k}, {c.source}, {c.score}, {c.rang}, {c.q_cov}, {c.d_cov})")
        if desc.sujet_type:
            f.append(f"sujet_type({q(desc.sujet_type)})")
        for m in desc.mentions:
            if m.champ == "entities.attributes" and (m.norme in AUREOLES or {"halo", "nimbus"} & set(m.norme.split())):
                f.append(f"halo({m.k})")
            if m.champ == "persons.who" and PREFIXES_SAINT.match(texte.norme(m.texte)):
                f.append(f"dit_saint({m.k})")
        jet = {m.k: set(texte.jetons(m.texte)) for m in desc.mentions}
        noms_cands = {c.n for c in cands}
        # Attributs des saints candidats (nommés ou proposés par un attribut) et participants des récits candidats.
        saints = {n for n in noms_cands if n.startswith(("11H(", "11HH(")) and self.base.n[n].get("attributs")}
        saints |= self._saints_par_attribut(desc, jet)
        for n in sorted(saints):
            for a, idf in self.base.n[n]["attributs"]:
                ja = set(texte.jetons(a))
                for m in desc.mentions:
                    if ja and m.champ in CHAMPS_ATTRIBUTS and ja <= jet[m.k]:
                        f.append(f"attr_vu({q(n)}, {q(a)}, {idf}, {m.k})")
        for n in sorted(noms_cands):
            parts = self.base.n[n].get("participants")
            if not parts:
                continue
            f.append(f"part_total({q(n)}, {len(parts)})")
            for p in parts:
                jp = set(texte.jetons(p))
                for m in desc.mentions:
                    if jp and m.champ in CHAMPS_PARTICIPANTS and jp <= jet[m.k]:
                        f.append(f"part_vu({q(n)}, {q(p)}, {m.k})")
        return sorted(set(f))

    def _saints_par_attribut(self, desc, jet) -> set[str]:
        """Saints dont au moins deux attributs rares sont vus (famille C sans nom) : seulement s'il y a une auréole
        ou un saint dans la description."""
        if not any(m.champ == "entities.attributes" and "halo" in m.norme for m in desc.mentions) \
                and desc.sujet_type != "saint":
            return set()
        if not hasattr(self, "_par_attribut"):
            self._par_attribut = defaultdict(set)
            for n, r in self.base.n.items():
                for a, _ in r.get("attributs", []):
                    self._par_attribut[a].add(n)
        compte = defaultdict(int)
        for a, ns in self._par_attribut.items():
            ja = set(texte.jetons(a))
            if ja and any(ja <= jet[m.k] for m in desc.mentions if m.champ in CHAMPS_ATTRIBUTS):
                for n in ns:
                    compte[n] += 1
        return {n for n, c in compte.items() if c >= 2}

    # ---------------------------------------------------------------------------------------------------------------
    def coder(self, desc: Description) -> dict:
        sortie = {"image": desc.image, "format": desc.format,
                  "versions": self.versions | {"description": f"sha256:{desc.sha256}"}}
        if desc.erreur:
            return sortie | {"erreur": desc.erreur, "codes": [], "objets": [], "relations": [], "non_utilise": {}}
        cands = recherche.candidats(self.base, desc, sem=self.sem)
        j = self.janus
        j.query_once("vider")
        faits = self.faits(desc, cands)
        for fait in faits:
            j.query_once(f"assertz({fait})")
        appuis = j.query_once("appuis(L)")["L"]
        j.query_once("vider")
        par_code = defaultdict(list)
        for terme in appuis:
            n, regle, ks, poids = _decomposer(terme)
            par_code[n].append((regle, tuple(ks), float(poids)))
        # Un épisode de la vie d'un saint (11H(JEROME)36) affirme aussi le saint : il hérite des appuis d'identité
        # (nom, attributs) du saint quand celui-ci est appuyé.
        for n in list(par_code):
            p = self.base.sous_propre(n)
            if p and p != n and p in par_code and any(r.startswith("D.") for r, _, _ in par_code[n]):
                par_code[n] += [(r, ks, w) for r, ks, w in par_code[p] if r.startswith(("B.", "C."))]
        mentions = {m.k: m for m in desc.mentions}
        codes = []
        for n, aps in par_code.items():
            # Un appui par famille d'indices : l'ancrage (A) compte une fois (sa meilleure mention) ; les règles des
            # familles B, C, D apportent chacune un indice distinct (nom, attributs, titre, source, participants).
            meilleur = {}
            for regle, ks, p in aps:
                cle = "A" if regle.startswith("A.") else regle
                if p > meilleur.get(cle, (None, -1))[1]:
                    meilleur[cle] = (regle, p, ks)
            ks_tous = sorted({k for _, ks, _ in aps for k in ks})
            score = sum(p for _, p, _ in meilleur.values()) + BONUS_INDICE * max(0, len(meilleur) - 1)
            champs = {mentions[k].champ for k in ks_tous}
            routage = any(recherche.bonus_routage(c, n) for c in champs)
            if routage:
                score += BONUS_ROUTAGE
            preuves = [{"regle": regle, "faits": [{"chemin": mentions[k].chemin, "texte": mentions[k].texte}
                                                   for k in ks], "contribution": round(p, 4)}
                       for regle, ks, p in sorted(aps, key=lambda x: (-x[2], x[0], x[1]))]
            codes.append({"code": n, "score": round(score, 4), "familles": sorted({c[0] for c in meilleur}),
                          "iconclass": self.base.n[n]["libelle"], "preuves": preuves, "mentions": ks_tous,
                          "_routage": routage})
        codes = hierarchie(self.base, codes)
        codes.sort(key=lambda c: (-c["score"], len(c["code"]), c["code"]))
        brutes = mesures_recherche(cands)
        for i, c in enumerate(codes):
            c["traits"] = traits(c, i, len(codes), desc, self.base, brutes)
        codes += self.ancetres_candidats(codes)
        if self.poids:
            for c in codes:
                c["p_catalogue"] = round(self.probabilite(c["traits"]), 4)
            codes.sort(key=lambda c: (-c["p_catalogue"], -c["score"], len(c["code"]), c["code"]))
        rang = 0
        for c in codes:
            if self.poids:
                ok = c["p_catalogue"] >= self.poids["seuil"] and rang < self.poids["k"]
            else:
                ok = c["score"] >= SEUIL and rang < MAX_RETENUS and not c.get("second_recit")
            c["statut"] = "retenu" if ok else "candidat"
            rang += ok
        utilisees = {k for c in codes if c["statut"] == "retenu" for k in c["mentions"]}
        sortie["codes"] = [{k: v for k, v in c.items() if k not in ("mentions", "second_recit", "_routage")}
                           for c in codes]
        sortie["objets"] = self._objets(desc, codes)
        sortie["relations"] = [{"sujet": a, "relation": r, "objet": b} for a, r, b in desc.relations]
        non = defaultdict(int)
        for m in desc.mentions:
            if m.k not in utilisees:
                non[m.champ] += 1
        sortie["non_utilise"] = {"mentions": sum(non.values()), "sur": len(desc.mentions),
                                 "par_champ": dict(sorted(non.items()))}
        return sortie

    def ancetres_candidats(self, codes: list[dict], top: int = 15, prof_min: int = 2) -> list[dict]:
        """Repli sur le parent sûr : les ancêtres (jusqu'à deux niveaux, profondeur ≥ 2) des meilleurs codes deviennent
        candidats, avec les traits de leur meilleur descendant et l'écart de profondeur ; la calibration apprend quand
        le plus général est le meilleur pari."""
        presents = {c["code"] for c in codes}
        nouveaux = {}
        for c in codes[:top]:
            for ecart, a in enumerate(self.base.ancetres(c["code"])[:2], start=1):
                if a in presents or self.base.n[a]["prof"] < prof_min or self.base.n[a]["gabarit"]:
                    continue
                prec = nouveaux.get(a)
                if prec is None or c["score"] > prec["score"]:
                    t = dict(c["traits"]) | {"ancetre": 1.0, "ecart_prof": float(ecart),
                                             "prof": float(self.base.n[a]["prof"])}
                    nouveaux[a] = {"code": a, "score": c["score"], "familles": c["familles"] + ["I"],
                                   "iconclass": self.base.n[a]["libelle"], "mentions": c["mentions"],
                                   "preuves": [{"regle": "I.ancetre", "faits": [], "contribution": 0.0,
                                                "descendant": c["code"]}],
                                   "traits": t, "second_recit": True}   # jamais retenu sans poids appris
        for a, c in nouveaux.items():
            c["traits"]["nb_descendants"] = float(sum(1 for x in codes[:top] if a in self.base.ancetres(x["code"])))
        return sorted(nouveaux.values(), key=lambda c: (-c["score"], c["code"]))

    def _objets(self, desc, codes):
        par_entite = defaultdict(set)
        for c in codes:
            if c["statut"] != "retenu":
                continue
            for p in c["preuves"]:
                if p["regle"].startswith("A."):
                    for f in p["faits"]:
                        if f["chemin"].startswith("entities["):
                            i = int(f["chemin"][9:f["chemin"].index("]")])
                            par_entite[i].add(c["code"])
        out = []
        for i, (eid, typ) in enumerate(desc.entites.items()):
            o = {"id": eid, "type": typ, "codes": sorted(par_entite.get(i, ()))}
            o |= desc.boites.get(eid, {})
            out.append(o)
        return out


def _decomposer(terme):
    """Appui rendu par Prolog : [N, Regle, Mentions, Poids]."""
    n, regle, ks, poids = terme
    return str(n), str(regle), [int(k) for k in ks], poids


def hierarchie(base: Base, codes: list[dict]) -> list[dict]:
    """Famille I : un ancêtre et son descendant ne restent pas ensemble (le plus fort reste ; à égalité, le
    descendant, plus précis) ; deux récits frères presque à égalité se replient sur leur parent commun."""
    par_n = {c["code"]: c for c in codes}
    retires = set()
    for c in sorted(codes, key=lambda c: -base.n[c["code"]]["prof"]):
        for a in base.ancetres(c["code"]):
            if a not in par_n or a in retires or c["code"] in retires:
                continue
            anc = par_n[a]
            # Le descendant, plus précis, garde la place s'il est presque aussi fort que son ancêtre ; il ne cumule
            # pas les scores (sinon une chaîne d'ancêtres gonfle n'importe quel descendant).
            if c["score"] >= 0.9 * anc["score"]:
                retires.add(a)
                c["mentions"] = sorted(set(c["mentions"]) | set(anc["mentions"]))
                c["score"] = round(max(c["score"], anc["score"]), 4)
                c["preuves"] = c["preuves"] + [{"regle": "I.descendant", "faits": [], "contribution": 0.0,
                                                "remplace": a}]
            else:
                retires.add(c["code"])
    codes = [c for c in codes if c["code"] not in retires]
    return un_sujet(base, codes)


def un_sujet(base: Base, codes: list[dict]) -> list[dict]:
    """Un seul sujet narratif : le meilleur récit reste ; un frère presque à égalité le replie sur leur parent commun ;
    les autres récits de la même histoire (ancêtre commun de profondeur ≥ 3) passent au rang de candidats."""
    recits = sorted((c for c in codes if "D" in c["familles"]), key=lambda c: (-c["score"], c["code"]))
    if not recits:
        return codes
    tete_ = recits[0]
    second = recits[1] if len(recits) > 1 else None
    if second and second["score"] >= 0.85 * tete_["score"]:
        # Deux récits presque à égalité : on ne choisit pas, on remonte à leur ancêtre commun le plus profond, s'il
        # est assez précis (profondeur ≥ 3).
        lignee = [tete_["code"]] + base.ancetres(tete_["code"])
        autres = set([second["code"]] + base.ancetres(second["code"]))
        commun = next((a for a in lignee if a in autres), None)
        if commun and commun != tete_["code"] and base.n[commun]["prof"] >= 3:
            existant = next((c for c in codes if c["code"] == commun), None)
            parent = existant or {"code": commun, "score": tete_["score"], "familles": [],
                                  "iconclass": base.n[commun]["libelle"], "mentions": [], "preuves": []}
            parent["score"] = max(parent["score"], tete_["score"])
            parent["familles"] = sorted(set(parent["familles"]) | set(tete_["familles"]) | {"I"})
            parent["mentions"] = sorted(set(parent["mentions"]) | set(tete_["mentions"]) | set(second["mentions"]))
            parent["preuves"] = [{"regle": "I.repli", "faits": [], "contribution": 0.0,
                                  "freres": [tete_["code"], second["code"]]}] + tete_["preuves"]
            codes = [c for c in codes if c["code"] not in (tete_["code"], second["code"], commun)] + [parent]
            tete_ = parent
    # Un seul sujet narratif : les autres récits passent candidats, sauf une vraie alternative (≥ 60 % du meilleur,
    # dans une autre histoire).
    histoire = set([tete_["code"]] + base.ancetres(tete_["code"]))
    for c in codes:
        if c is tete_ or "D" not in c["familles"]:
            continue
        commun = histoire & set(base.ancetres(c["code"]))
        if c["score"] < 0.6 * tete_["score"] or any(base.n[a]["prof"] >= 3 for a in commun):
            c["second_recit"] = True
    return codes
