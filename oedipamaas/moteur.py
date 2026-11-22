"""Le moteur : lecture → recherche → traits (Prolog, par Janus) → décision apprise → projection → sortie.

Aucune constante de décision n'est écrite ici : les règles rendent des traits, la décision vient d'un fichier de poids
appris (régression logistique). Sans poids, tous les codes restent candidats, classés par leur meilleure preuve.
"""

from __future__ import annotations

import json
import math
import subprocess
from collections import defaultdict
from pathlib import Path

from . import __version__, recherche, texte
from .lecture import Description
from .recherche import Base

ICI = Path(__file__).resolve().parent
# Famille de chaque champ de la description (traits « champ_<famille> » : d'où vient la preuve).
FAMILLES_CHAMPS = {
    "subject.title": "sujet", "subject.alternatives": "sujet", "subject.type": "sujet", "subject.source": "sujet",
    "persons.who": "personne", "persons.recognised_by": "personne", "entities.type": "entite",
    "entities.attributes": "entite", "relations": "relation", "actions": "action", "gestures_emotions": "geste",
    "concepts": "concept", "concepts.symbole": "concept", "roles": "role", "setting": "cadre", "texts": "texte",
    "genre_function": "genre", "keywords": "motcle", "period_style": "epoque", "description": "globale"}
# Champs où l'on cherche les attributs d'un saint et les participants d'un récit (tout ce qui décrit l'image, hors
# sujet : la vérification doit venir d'ailleurs que de l'affirmation).
CHAMPS_INDICES = tuple(c for c, f in FAMILLES_CHAMPS.items() if f not in ("sujet", "globale"))
# Traits dont le plus grand dit la meilleure preuve d'un code (classement des candidats quand il n'y a pas de poids,
# et budget des candidats envoyés à la décision) ; tous dans [0, 1].
PREUVES = ("sem_sujet", "sem_autre", "dcov_sujet", "dcov_autre", "exact_mot_sujet", "exact_mot_autre",
           "exact_tete_sujet", "exact_tete_autre", "nom", "source_exacte")
BUDGET_SAINTS = 10      # saints proposés par leurs attributs seuls, par image (budget de calcul, pas une décision)
BUDGET_REPLI = 15       # meilleurs codes dont les ancêtres deviennent candidats
BUDGET_SORTIE = 120     # codes écrits par image (stockage ; les retenus sont toujours en tête)
BUDGET_CLES = 20        # meilleurs codes qui peuvent recevoir une clé (+…)
CLES_PAR_CODE = 2       # clés gardées par code de base (les mieux évoquées)
BUDGET_GABARITS = 30    # meilleurs codes dont on instancie le gabarit « with NAME » s'ils en ont un
NOMS_PAR_GABARIT = 2    # noms essayés par gabarit
CHAMPS_NOMMABLES = ("entities.type", "keywords", "persons.who", "setting", "texts")   # champs qui nomment une chose
GABARITS_PAR_IMAGE = 10 # instanciations gardées par image (les mieux accordées au gabarit)


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


def ordre_de_preuve(c) -> tuple:
    """Meilleure preuve d'abord, puis la plus abondante (classement sans poids, et budget des candidats)."""
    return (-c["traits"]["preuve_max"], -c["traits"]["preuve_somme"], c["code"])


class Moteur:
    def __init__(self, dossier_base: Path, poids: Path | None = None, semantique: str | None = None,
                 cles: bool = False, gabarits: bool = False):
        """cles : proposer les codes à clé (+…). Désactivé par défaut : sur un premier corpus, la base des codes vrais
        à clé était rarement candidate, et les clés proposées presque toujours fausses (le mécanisme reste)."""
        import janus_swi as janus  # importé ici : la lecture et la recherche n'en ont pas besoin

        self.janus = janus
        self.cles = cles
        # gabarits : instancier les gabarits « with NAME » (« X(NOM) »). Désactivé par défaut : sur un premier corpus,
        # les codes instanciés étaient rarement justes (poids appris négatifs) ; le mécanisme reste.
        self.gabarits = gabarits
        self.base = Base(dossier_base)
        self.sem = None
        if semantique:
            from .semantique import IndexSemantique
            meta = json.loads((Path(dossier_base) / f"vecteurs-{semantique.split('/')[-1]}.json").read_text())
            self.sem = IndexSemantique(dossier_base, meta["modele"], meta["revision"])
        janus.query_once(f"consult({q(Path(dossier_base) / 'base.pl')})")
        janus.query_once(f"consult({q(ICI / 'regles' / 'regles.pl')})")
        self.poids = json.loads(Path(poids).read_text()) if poids else None
        self.versions = {"moteur": version_git(),
                         "base": f"iconclass {self.base.manifeste.get('commit', '?')[:7]}"
                                 + (" + wikidata" if "wikidata" in self.base.manifeste else ""),
                         "regles": "v2", "poids": self.poids["version"] if self.poids else None,
                         "semantique": f"{self.sem.modele_nom} {self.sem.revision}" if self.sem else None}
        self.noms_listes = {r["nom"] for r in self.base.n.values() if r.get("nom")}
        self._par_attribut = defaultdict(set)
        for n, r in self.base.n.items():
            for a, _ in r.get("attributs", []):
                self._par_attribut[a].add(n)

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
            if c.source == "nom":
                f.append(f"nom_ctx({q(c.n)}, {c.k}, {c.contexte})")
        jet = {m.k: set(texte.jetons(m.texte)) for m in desc.mentions}
        indices = [m for m in desc.mentions if m.champ in CHAMPS_INDICES]
        noms_cands = {c.n for c in cands}
        # Attributs : les saints nommés, et les saints dont des attributs sont vus (les BUDGET_SAINTS plus rares).
        vus = defaultdict(list)
        for a, ns in self._par_attribut.items():
            ja = set(texte.jetons(a))
            ks = [m.k for m in indices if ja and ja <= jet[m.k]]
            if ks:
                for n in ns:
                    vus[n].append((a, ks))
        idf = {n: dict(self.base.n[n]["attributs"]) for n in vus}
        par_rarete = sorted(vus, key=lambda n: (-sum(idf[n][a] for a, _ in vus[n]), n))
        saints = set(par_rarete[:BUDGET_SAINTS]) | {n for n in noms_cands if n in vus}
        for n in sorted(saints):
            for a, ks in vus[n]:
                f.extend(f"attr_vu({q(n)}, {q(a)}, {idf[n][a]}, {k})" for k in ks)
        # Participants des récits candidats, et ancêtres reconnus dans la description.
        normes = defaultdict(list)
        for m in desc.mentions:
            normes[m.norme].append(m.k)
        for n in sorted(noms_cands | saints):
            parts = self.base.n[n].get("participants")
            if parts:
                f.append(f"part_total({q(n)}, {len(parts)})")
                for p in parts:
                    jp = set(texte.jetons(p))
                    f.extend(f"part_vu({q(n)}, {q(p)}, {m.k})" for m in indices if jp and jp <= jet[m.k])
            for a in self.base.ancetres(n):
                prof = self.base.n[a]["prof"]
                if prof >= 1:
                    for e in self.base.expressions(a):
                        f.extend(f"anc_vu({q(n)}, {prof}, {k})" for k in normes.get(e, ()))
        return sorted(set(f))

    # ---------------------------------------------------------------------------------------------------------------
    def coder(self, desc: Description) -> dict:
        sortie = {"image": desc.image, "format": desc.format,
                  "versions": self.versions | {"description": f"sha256:{desc.sha256}"}}
        if desc.erreur:
            return sortie | {"erreur": desc.erreur, "codes": [], "objets": [], "relations": [], "non_utilise": {}}
        cands = recherche.candidats(self.base, desc, sem=self.sem)
        j = self.janus
        j.query_once("vider")
        for fait in self.faits(desc, cands):
            j.query_once(f"assertz({fait})")
        lignes = j.query_once("traits(L)")["L"]
        j.query_once("vider")
        mentions = {m.k: m for m in desc.mentions}
        par_code = {}
        for n, t, v, ks in lignes:
            n, t, v, ks = str(n), str(t), float(v), [int(k) for k in ks]
            c = par_code.setdefault(n, {"code": n, "traits": {}, "preuves": [], "mentions": set()})
            if v > c["traits"].get(t, float("-inf")):
                c["traits"][t] = round(v, 4)
            c["preuves"].append({"regle": t, "valeur": round(v, 4),
                                 "faits": [{"chemin": mentions[k].chemin, "texte": mentions[k].texte} for k in ks]})
            c["mentions"] |= set(ks)
        descendants, enfants = defaultdict(int), defaultdict(int)
        for m in par_code:
            for a in self.base.ancetres(m):
                descendants[a] += 1
            enfants[self.base.n[m]["parent"]] += 1
        for c in par_code.values():
            self._structure(c, par_code, mentions, descendants, enfants)
        codes = sorted(par_code.values(), key=ordre_de_preuve)
        # Preuve relative : la place du code parmi ceux de la même description (comparaison interne, pas un a priori).
        meilleure = max((c["traits"]["preuve_somme"] for c in codes), default=0.0) or 1.0
        for i, c in enumerate(codes):
            c["traits"]["rang_preuve"] = float(i)
            c["traits"]["preuve_relative"] = round(c["traits"]["preuve_somme"] / meilleure, 4)
        codes += self._ancetres_candidats(codes[:BUDGET_REPLI], par_code)
        if self.cles:
            codes += self._codes_a_cle(desc, codes[:BUDGET_CLES], mentions)
        if self.gabarits:
            codes += self._gabarits_instancies(codes[:BUDGET_GABARITS], par_code, mentions)
        self._decider(codes)
        codes = codes[:BUDGET_SORTIE]     # les retenus sont en tête (ordre de la décision)
        for c in codes:
            c["iconclass"] = self.base.libelle(c["code"])
            c["preuves"] = sorted(c["preuves"], key=lambda p: (-p["valeur"], p["regle"], str(p["faits"])))[:5]
        utilisees = {k for c in codes if c["statut"] == "retenu" for k in c["mentions"]}
        sortie["codes"] = [{k: v for k, v in c.items() if k != "mentions"} for c in codes]
        sortie["objets"] = self._objets(desc, codes)
        sortie["relations"] = [{"sujet": a, "relation": r, "objet": b} for a, r, b in desc.relations]
        non = defaultdict(int)
        for m in desc.mentions:
            if m.k not in utilisees:
                non[m.champ] += 1
        sortie["non_utilise"] = {"mentions": sum(non.values()), "sur": len(desc.mentions),
                                 "par_champ": dict(sorted(non.items()))}
        return sortie

    def _structure(self, c, par_code, mentions, descendants, enfants):
        """Traits de structure : place de la notation dans Iconclass et parmi les autres candidats, champs d'où vient
        sa preuve. Rien sur ce qu'un catalogue contient d'habitude."""
        n, r, t = c["code"], self.base.n[c["code"]], c["traits"]
        t["prof"] = float(r["prof"])
        t["recit"] = float(r["chapitre"] in ("7", "8", "9") or (self.base.sous_propre(n) or n) != n)
        t["propre"] = float(bool(self.base.sous_propre(n)))
        t["nb_mentions"] = float(len(c["mentions"]))
        t["nb_traits"] = float(len([k for k in t if k in PREUVES or k.startswith(("attributs", "source", "nom"))]))
        for fam in {FAMILLES_CHAMPS.get(mentions[k].champ, "autre") for k in c["mentions"]}:
            t[f"champ_{fam}"] = 1.0
        t["nb_descendants"] = float(descendants.get(n, 0))
        t["nb_freres"] = float(enfants.get(r["parent"], 1) - 1)
        t["ancetres_candidats"] = float(sum(1 for a in self.base.ancetres(n) if a in par_code))
        t["preuve_max"] = max([t.get(k, 0.0) for k in PREUVES] + [0.0])
        t["preuve_somme"] = round(sum(t.get(k, 0.0) for k in PREUVES), 4)

    def _ancetres_candidats(self, meilleurs, par_code) -> list[dict]:
        """Repli sur le parent sûr : les ancêtres (deux niveaux) des meilleurs codes deviennent candidats, avec les
        traits de leur meilleur descendant et l'écart de profondeur ; la décision apprend quand le plus général est le
        meilleur pari."""
        nouveaux = {}
        for c in meilleurs:
            for ecart, a in enumerate(self.base.ancetres(c["code"])[:2], start=1):
                r = self.base.n[a]
                if a in par_code or r["gabarit"] or r["prof"] < 1:
                    continue
                if a not in nouveaux or c["traits"]["preuve_max"] > nouveaux[a]["traits"]["preuve_max"]:
                    t = dict(c["traits"]) | {"ancetre": 1.0, "ecart_prof": float(ecart), "prof": float(r["prof"])}
                    nouveaux[a] = {"code": a, "traits": t, "mentions": set(c["mentions"]),
                                   "preuves": [{"regle": "repli_sur_ancetre", "valeur": 0.0, "faits": [],
                                                "descendant": c["code"]}]}
        compte = defaultdict(int)
        for m in par_code:
            for a in self.base.ancetres(m):
                if a in nouveaux:
                    compte[a] += 1
        for a, c in nouveaux.items():
            c["traits"]["nb_descendants"] = float(compte[a])
        return sorted(nouveaux.values(), key=lambda c: c["code"])

    def _gabarits_instancies(self, meilleurs, par_code, mentions) -> list[dict]:
        """Gabarits « with NAME » d'Iconclass (« 25G4(...) », fleurs nommées) : si un candidat est le parent d'un
        gabarit, chaque mention courte (≤ 3 mots, champ d'objet ou de personne) qui l'a proposé donne « 25G4(TULIP) »,
        nom en majuscules ; traits du parent plus « gabarit »."""
        gabarits = self.base.gabarits_par_parent
        out = {}
        for c in meilleurs:
            if "ancetre" in c["traits"]:
                continue
            # Le parent du gabarit : le candidat lui-même (« 25G4 »), ou celui d'un nom listé (« 25G4(ROSE) », enfant
            # du gabarit « 25G4(...) »).
            p = c["code"] if c["code"] in gabarits else None
            if p is None:
                par = self.base.n.get(c["code"], {}).get("parent")
                if par and self.base.n.get(par, {}).get("gabarit") and par.endswith("(...)"):
                    p = self.base.n[par]["parent"]
            if p not in gabarits:
                continue
            for k in sorted(c["mentions"]):
                m = mentions[k]
                if m.champ not in CHAMPS_NOMMABLES or not 0 < len(m.norme.split()) <= 3:
                    continue
                if m.norme in self.noms_listes:     # nom déjà listé par Iconclass (« tulip ») : pas de nom libre
                    continue
                nom = recherche.nom_de_personne(m.texte).upper() if m.champ == "persons.who" else m.norme.upper()
                n = f"{p}({nom})"
                if n in par_code or n in self.base.n or n in out:
                    continue
                t = dict(c["traits"]) | {"gabarit": 1.0, "gabarit_mots": float(len(nom.split())),
                                         "gabarit_sim": self._accord(m.texte, p), "prof": c["traits"]["prof"] + 1}
                out[n] = {"code": n, "traits": t, "mentions": set(c["mentions"]),
                          "preuves": [{"regle": "gabarit", "valeur": 0.0, "gabarit": gabarits[p],
                                       "faits": [{"chemin": m.chemin, "texte": m.texte}]}]}
                if sum(1 for x in out if x.startswith(p + "(")) >= NOMS_PAR_GABARIT:
                    break
        gardes = sorted(out.values(), key=lambda c: (-c["traits"]["gabarit_sim"], c["code"]))[:GABARITS_PAR_IMAGE]
        return sorted(gardes, key=lambda c: c["code"])

    def _accord(self, texte_mention: str, n: str) -> float:
        """Cosinus entre une mention et le libellé d'une notation (0 sans recherche sémantique)."""
        if self.sem is None or n not in self.sem.position:
            return 0.0
        v = self.sem.encoder([texte_mention])[0]
        return round(float(self.sem.vecteurs[self.sem.position[n]] @ v), 4)

    def _codes_a_cle(self, desc, meilleurs, mentions) -> list[dict]:
        """Clés d'Iconclass : un candidat de la famille F, et une clé s de F que la description évoque (texte ou mot
        clé de la clé), donnent le candidat « N(+s) », avec les traits de N et ceux de la clé."""
        vues = defaultdict(list)
        for fam, s, k, exacte, q_, d in self.base.cles_vues(desc):
            vues[fam].append((s, k, exacte, q_, d))
        out = {}
        for c in meilleurs:
            r = self.base.n.get(c["code"])
            if not r or not r.get("famille_cle") or r["famille_cle"] not in vues:
                continue
            for s, k, exacte, q_, d in vues[r["famille_cle"]]:
                n = f"{c['code']}(+{s})"
                if n not in out:
                    out[n] = {"code": n, "mentions": set(c["mentions"]), "preuves": [],
                              "traits": dict(c["traits"]) | {"cle": 1.0, "cle_exacte": 0.0, "cle_qcov": 0.0,
                                                             "cle_dcov": 0.0, "prof": float(r["prof"] + 1),
                                                             "ancetre": 0.0}}
                t = out[n]["traits"]          # plusieurs mentions peuvent évoquer la même clé : le plus fort reste
                t["cle_exacte"], t["cle_qcov"], t["cle_dcov"] = (max(t["cle_exacte"], exacte), max(t["cle_qcov"], q_),
                                                                 max(t["cle_dcov"], d))
                out[n]["mentions"].add(k)
                out[n]["preuves"].append({"regle": "cle", "valeur": max(d, exacte), "cle": s,
                                          "faits": [{"chemin": mentions[k].chemin, "texte": mentions[k].texte}]})
        # Budget : par code de base, les CLES_PAR_CODE clés les mieux évoquées.
        par_base = defaultdict(list)
        for c in out.values():
            par_base[self.base.sans_cle(c["code"])].append(c)
        gardes = [c for cs in par_base.values() for c in sorted(
            cs, key=lambda c: (-c["traits"]["cle_exacte"], -c["traits"]["cle_dcov"], c["code"]))[:CLES_PAR_CODE]]
        return sorted(gardes, key=lambda c: c["code"])

    def _decider(self, codes):
        """Décision apprise : probabilité, puis les k meilleurs selon le critère des poids (probabilité, ou espérance
        de nœuds justes = probabilité × (profondeur + 1), qui découle du F1 hiérarchique), au-dessus du seuil ; enfin
        la projection la plus précise (un ancêtre dit par un descendant retenu repasse candidat). Sans poids : aucun
        code retenu, classement par la meilleure preuve."""
        for c in codes:
            c["statut"] = "candidat"
        if not self.poids:
            codes.sort(key=ordre_de_preuve)
            return
        for c in codes:
            c["p_catalogue"] = round(self.probabilite(c["traits"]), 4)
        esperance = self.poids.get("critere") == "esperance"

        def cle(c):
            v = c["p_catalogue"] * (c["traits"]["prof"] + 1) if esperance else c["p_catalogue"]
            return (-v, c["code"])
        codes.sort(key=cle)
        choisis = [c for c in codes if c["p_catalogue"] >= self.poids["seuil"]][: self.poids["k"]]
        for c in choisis:
            c["statut"] = "retenu"
        retenus = {c["code"] for c in choisis}
        impliques = {a for n in retenus for a in self.base.ancetres(n)}
        for c in choisis:
            if c["code"] in impliques:
                c["statut"], c["implicite"] = "candidat", True

    def _objets(self, desc, codes):
        par_entite = defaultdict(set)
        for c in codes:
            if c["statut"] != "retenu":
                continue
            for p in c["preuves"]:
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
