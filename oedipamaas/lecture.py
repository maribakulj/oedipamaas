"""Lecture d'une description : chaque champ devient des mentions (texte, champ, chemin, confiance, entité).

Deux formats : v2 (sujet, personnes, entités situées, relations, actions, gestes, concepts, rôles, cadre, textes, genre,
mots clés) et v1 (entités, relations, scène, identification), lue par un adaptateur.
"""

from __future__ import annotations

import hashlib
import json
import re
from dataclasses import dataclass, field
from pathlib import Path

from . import texte


@dataclass(frozen=True)
class Mention:
    k: int
    champ: str
    chemin: str
    texte: str
    norme: str
    confiance: float | None = None
    entite: str | None = None


@dataclass
class Description:
    image: str
    format: str
    mentions: list[Mention] = field(default_factory=list)
    entites: dict[str, str] = field(default_factory=dict)          # id → type normalisé
    attributs: list[tuple[str, str]] = field(default_factory=list)  # (id, attribut normalisé)
    boites: dict[str, dict] = field(default_factory=dict)           # id → {boite, plan, position}
    relations: list[tuple[str, str, str]] = field(default_factory=list)
    sujet_type: str | None = None
    sujet_confiance: float | None = None
    sha256: str = ""
    erreur: str | None = None

    def ajouter(self, champ, chemin, valeur, confiance=None, entite=None):
        if not isinstance(valeur, str) or not valeur.strip():
            return
        n = texte.norme(valeur)
        if n:
            self.mentions.append(Mention(len(self.mentions), champ, chemin, valeur.strip(), n, confiance, entite))


def extraire_json(brut: str) -> dict:
    brut = re.sub(r"^```(?:json)?\s*|\s*```$", "", brut.strip())
    debut, fin = brut.find("{"), brut.rfind("}")
    if debut < 0 or fin < debut:
        raise ValueError("aucun objet JSON")
    return json.loads(brut[debut:fin + 1])


def _conf(x):
    try:
        return round(float(x), 4)
    except (TypeError, ValueError):
        return None


def _liste(x):
    return x if isinstance(x, list) else []


def lire_fichier(chemin: Path) -> Description:
    chemin = Path(chemin)
    octets = chemin.read_bytes()
    try:
        env = json.loads(octets)
        d = extraire_json(env["brut"]) if isinstance(env, dict) and "brut" in env else env
        if not isinstance(d, dict):
            raise ValueError("la description n'est pas un objet")
    except (ValueError, KeyError, TypeError) as e:
        return Description(chemin.stem, "?", sha256=hashlib.sha256(octets).hexdigest(), erreur=str(e)[:200])
    desc = lire(d, chemin.stem)
    desc.sha256 = hashlib.sha256(octets).hexdigest()
    return desc


def lire(d: dict, image: str) -> Description:
    v2 = any(k in d for k in ("subject", "persons", "concepts", "actions", "keywords"))
    desc = Description(image, "v2" if v2 else "v1")
    # Entités et relations (communes aux deux formats)
    for i, e in enumerate(_liste(d.get("entities"))):
        if not isinstance(e, dict):
            continue
        eid = str(e.get("id", f"e{i}"))
        typ = texte.norme(e.get("type", ""))
        desc.entites[eid] = typ
        desc.ajouter("entities.type", f"entities[{i}].type", e.get("type"), entite=eid)
        for j, a in enumerate(_liste(e.get("attributes"))):
            desc.ajouter("entities.attributes", f"entities[{i}].attributes[{j}]", a, entite=eid)
            if isinstance(a, str) and texte.norme(a):
                desc.attributs.append((eid, texte.norme(a)))
        boite = e.get("box")
        if isinstance(boite, list) and len(boite) == 4 and all(isinstance(v, (int, float)) for v in boite):
            desc.boites[eid] = {"boite": [round(float(v), 4) for v in boite], "plan": e.get("plane"),
                                "position": e.get("position")}
    for i, r in enumerate(_liste(d.get("relations"))):
        if isinstance(r, list) and len(r) == 3 and all(isinstance(x, str) for x in r):
            a, rel, b = r
            desc.relations.append((a, texte.norme(rel), b))
            ta, tb = desc.entites.get(a, a), desc.entites.get(b, b)
            desc.ajouter("relations", f"relations[{i}]", f"{ta} {rel.replace('_', ' ')} {tb}", entite=a)
    if v2:
        _lire_v2(d, desc)
    else:
        _lire_v1(d, desc)
    return desc


def _lire_v2(d, desc):
    s = d.get("subject") if isinstance(d.get("subject"), dict) else {}
    conf = _conf(s.get("confidence"))
    desc.sujet_confiance = conf
    desc.sujet_type = texte.norme(s.get("type", "")) or None
    desc.ajouter("subject.title", "subject.title", s.get("title"), conf)
    desc.ajouter("subject.source", "subject.source", s.get("source"), conf)
    desc.ajouter("subject.type", "subject.type", s.get("type"), conf)
    for i, a in enumerate(_liste(s.get("alternatives"))):
        desc.ajouter("subject.alternatives", f"subject.alternatives[{i}]", a, None)
    for i, p in enumerate(_liste(d.get("persons"))):
        if not isinstance(p, dict):
            continue
        c = _conf(p.get("confidence"))
        desc.ajouter("persons.who", f"persons[{i}].who", p.get("who"), c)
        for j, r in enumerate(_liste(p.get("recognised_by"))):
            desc.ajouter("persons.recognised_by", f"persons[{i}].recognised_by[{j}]", r, c)
    for champ in ("actions", "gestures_emotions", "roles", "setting", "genre_function", "keywords"):
        for i, x in enumerate(_liste(d.get(champ))):
            desc.ajouter(champ, f"{champ}[{i}]", x)
    for i, x in enumerate(_liste(d.get("concepts"))):
        if isinstance(x, str) and ":" in x:
            idee, symbole = x.split(":", 1)
            desc.ajouter("concepts", f"concepts[{i}]", idee)
            desc.ajouter("concepts.symbole", f"concepts[{i}]", symbole)
        else:
            desc.ajouter("concepts", f"concepts[{i}]", x)
    for i, t in enumerate(_liste(d.get("texts"))):
        if isinstance(t, dict):
            desc.ajouter("texts", f"texts[{i}].transcription", t.get("transcription"))
    desc.ajouter("period_style", "period_style", d.get("period_style"))


def _lire_v1(d, desc):
    for i, x in enumerate(_liste(d.get("scene"))):
        desc.ajouter("setting", f"scene[{i}]", x)
    ident = d.get("identification") if isinstance(d.get("identification"), dict) else {}
    conf = _conf(ident.get("confidence"))
    desc.sujet_confiance = conf
    if ident.get("guess"):
        desc.ajouter("subject.title", "identification.guess", ident["guess"], conf)
        desc.ajouter("persons.who", "identification.guess", ident["guess"], conf)
    for i, b in enumerate(_liste(ident.get("based_on"))):
        desc.ajouter("persons.recognised_by", f"identification.based_on[{i}]", b, conf)
