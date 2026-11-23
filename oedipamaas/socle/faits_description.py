"""Une description (consigne v2) en faits Prolog (socle 1.0, pièce 4). Transcription sans jugement : chaque chaîne
devient une mention avec son champ et son chemin JSON (pour la preuve) ; entités, relations, personnes, sujet et
textes gardent leur structure. Aucun mot n'est choisi, filtré ni corrigé ici.

Faits du module description (remplacés à chaque image) :
  mention(M, Champ, Chemin, Texte)          toute chaîne de tout champ (identifiants d'entité et boîtes exceptés)
  entite(E, Type, Plan, Position, Boite)    Boite : [x0, y0, x1, y1] en fractions, ou []
  attribut(E, Texte)
  relation(Sujet, Predicat, Objet)          sujets et objets : identifiants d'entité ou textes
  relation_i(I, Sujet, Predicat, Objet)     la même, avec sa place I (l'unité relations[I])
  personne(I, Nom, ReconnuPar, Confiance)
  sujet(Titre, Source, Type, Confiance)     alternative(I, Texte)
  texte_transcrit(I, Transcription, Langue)
"""
import json
import re
from pathlib import Path

CHAMPS = ("subject", "persons", "entities", "relations", "actions", "gestures_emotions", "concepts", "roles", "setting",
          "texts", "genre_function", "period_style", "keywords")
# Champs de mise en page et de métadonnées, gardés dans les faits structurés (entite/5, texte_transcrit/3) mais pas
# comme mentions : ils situent les objets ou qualifient la description, ils ne disent pas ce que l'image montre.
IGNORES = {"id", "box", "confidence", "plane", "position", "language"}


def extraire_json(brut):
    brut = re.sub(r"^```(?:json)?\s*|\s*```$", "", brut.strip())
    debut, fin = brut.find("{"), brut.rfind("}")
    if debut < 0 or fin < debut:
        raise ValueError("aucun objet JSON dans la réponse du descripteur")
    return json.loads(brut[debut:fin + 1])


def lire_fichier(chemin):
    env = json.loads(Path(chemin).read_text(encoding="utf-8"))
    return extraire_json(env["brut"]) if isinstance(env, dict) and "brut" in env else env


def q(s):
    return "'" + str(s).replace("\\", "\\\\").replace("'", "\\'").replace("\n", " ") + "'"


def nombre(x):
    try:
        return repr(float(x))
    except (TypeError, ValueError):
        return "0.0"


def chaines(o, chemin):
    """(chemin, texte) de toutes les chaînes d'un objet JSON, identifiants et boîtes exceptés."""
    if isinstance(o, str):
        if o.strip() and not re.fullmatch(r"e\d+", o.strip()):
            yield chemin, o
    elif isinstance(o, dict):
        for k, v in o.items():
            if k not in IGNORES:
                yield from chaines(v, f"{chemin}.{k}")
    elif isinstance(o, list):
        for i, v in enumerate(o):
            yield from chaines(v, f"{chemin}[{i}]")


def faits(d):
    """Liste des faits (textes Prolog) d'une description lue."""
    out, m = [], 0
    for champ in CHAMPS:
        for chemin, texte in chaines(d.get(champ), champ):
            m += 1
            out.append(f"mention({m}, {q(champ)}, {q(chemin)}, {q(texte)})")
    for i, e in enumerate(d.get("entities") or []):
        if not isinstance(e, dict):
            continue
        eid = str(e.get("id") or f"e{i}")
        boite = e.get("box") if isinstance(e.get("box"), list) and len(e.get("box")) == 4 else []
        out.append(f"entite({q(eid)}, {q(e.get('type') or '')}, {q(e.get('plane') or '')}, "
                   f"{q(e.get('position') or '')}, [{', '.join(nombre(x) for x in boite)}])")
        for a in e.get("attributes") or []:
            if isinstance(a, str) and a.strip():
                out.append(f"attribut({q(eid)}, {q(a)})")
    for i, r in enumerate(d.get("relations") or []):
        if isinstance(r, list) and len(r) == 3:
            out.append(f"relation({q(r[0])}, {q(r[1])}, {q(r[2])})")
            out.append(f"relation_i({i}, {q(r[0])}, {q(r[1])}, {q(r[2])})")     # sa place : l'unité relations[i]
    for i, p in enumerate(d.get("persons") or []):
        if isinstance(p, dict) and p.get("who"):
            out.append(f"personne({i}, {q(p['who'])}, {q(p.get('recognised_by') or '')}, "
                       f"{q(p.get('confidence') or '')})")
    s = d.get("subject") or {}
    if isinstance(s, dict) and (s.get("title") or s.get("source")):
        out.append(f"sujet({q(s.get('title') or '')}, {q(s.get('source') or '')}, {q(s.get('type') or '')}, "
                   f"{q(s.get('confidence') or '')})")
        for i, a in enumerate(s.get("alternatives") or []):
            if isinstance(a, str) and a.strip():
                out.append(f"alternative({i}, {q(a)})")
    for i, t in enumerate(d.get("texts") or []):
        if isinstance(t, dict) and t.get("transcription"):
            out.append(f"texte_transcrit({i}, {q(t['transcription'])}, {q(t.get('language') or '')})")
    return out


def charger(janus, d):
    """Remplace les faits du module description par ceux de la description d."""
    janus.query_once("description:effacer")
    for f in faits(d):
        janus.query_once("term_string(_T, S), assertz(description:_T)", {"S": f})
    # formes des mentions, une fois par description, si la recherche est chargée
    janus.query_once("( current_predicate(recherche:preparer/0) -> recherche:preparer ; true )")
