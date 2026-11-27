"""Le contrôle de forme des graphes annotés (docs/BANC_GRAPHES.md, § 2 et § 3) : rien n'est jugé du sens.

Usage : python outils/graphes/valider_annotations.py ANNOTATIONS.json [TEXTES.json]
Rend 1 et liste les défauts s'il y en a : champs manquants, identifiants en double, références à des identifiants
inconnus, mentions absentes du texte, valeurs hors des domaines, textes différents de ceux donnés (TEXTES.json : la
liste {k, genre, langue, texte} remise à l'annotateur ; chacun doit avoir son graphe, et un seul)."""
import json
import sys
from pathlib import Path

ROLES = {"agent", "patient", "theme", "instrument", "destinataire", "lieu"}
POLARITES = {"pos", "neg"}
MODALITES = {"affirme", "probable", "possible", "traditionnel", "ancien", "non_affirme", "titre"}
PORTEES = {"represente", "oeuvre", "autre_oeuvre", "source", "histoire", "non_ancre"}


def defauts_qualif(o, ou):
    d = []
    if o.get("polarite", "pos") not in POLARITES:
        d.append(f"{ou} : polarite {o.get('polarite')}")
    if o.get("modalite", "affirme") not in MODALITES:
        d.append(f"{ou} : modalite {o.get('modalite')}")
    if o.get("portee", "represente") not in PORTEES:
        d.append(f"{ou} : portee {o.get('portee')}")
    en = o.get("enonciateur", "auteur")
    if not (en == "auteur" or (isinstance(en, dict) and set(en) == {"cite"} and isinstance(en["cite"], str))):
        d.append(f"{ou} : enonciateur {en}")
    return d


def defauts(g):
    d, ids = [], set()
    ou0 = f"{g.get('k')}/{g.get('genre')}"
    for c in ("k", "genre", "langue", "texte"):
        if c not in g:
            d.append(f"{ou0} : champ {c} manquant")
    texte = g.get("texte", "")
    for x in g.get("entites", []) + g.get("evenements", []) + g.get("relations", []):
        i = x.get("id")
        if not isinstance(i, str) or i in ids:
            d.append(f"{ou0} : identifiant {i} manquant ou en double")
        ids.add(i)
    ents = {e.get("id") for e in g.get("entites", [])}
    evs = {v.get("id") for v in g.get("evenements", [])}
    for e in g.get("entites", []):
        ou = f"{ou0} {e.get('id')}"
        if not isinstance(e.get("tete"), str) or not e["tete"].strip():
            d.append(f"{ou} : tete manquante")
        if e.get("mention") is not None and e["mention"] not in texte:
            d.append(f"{ou} : mention absente du texte : {e['mention']!r}")
        if e.get("nombre") is not None and not (isinstance(e["nombre"], int) and e["nombre"] >= 1):
            d.append(f"{ou} : nombre {e['nombre']}")
        d += defauts_qualif(e, ou)
        for p in e.get("proprietes", []) + e.get("noms", []):
            if isinstance(p, dict):
                d += defauts_qualif(p, ou)
            elif not isinstance(p, str):
                d.append(f"{ou} : propriété ou nom {p}")
    for v in g.get("evenements", []):
        ou = f"{ou0} {v.get('id')}"
        if not isinstance(v.get("predicat"), str) or not v["predicat"].strip():
            d.append(f"{ou} : predicat manquant")
        if v.get("mention") is not None and v["mention"] not in texte:
            d.append(f"{ou} : mention absente du texte : {v['mention']!r}")
        for r, es in (v.get("roles") or {}).items():
            if r not in ROLES:
                d.append(f"{ou} : rôle {r}")
            for e in ([es] if isinstance(es, str) else es):
                if e not in ents:
                    d.append(f"{ou} : rôle {r} vers {e}, inconnue")
        d += defauts_qualif(v, ou)
    for x in g.get("relations", []):
        ou = f"{ou0} {x.get('id')}"
        for c in ("sujet", "objet"):
            if x.get(c) not in ents:
                d.append(f"{ou} : {c} {x.get(c)} inconnu")
        if not isinstance(x.get("relation"), str):
            d.append(f"{ou} : relation manquante")
        d += defauts_qualif(x, ou)
    for c in g.get("coref", []) + g.get("distinct", []):
        if not (isinstance(c, list) and len(c) >= 2 and all(e in ents for e in c)):
            d.append(f"{ou0} : coref ou distinct {c}")
    for a in g.get("alternatives", []):
        if not (isinstance(a, list) and len(a) >= 2 and all(e in ents | evs for e in a)):
            d.append(f"{ou0} : alternative {a}")
    return d


def main():
    A = json.loads(Path(sys.argv[1]).read_text(encoding="utf-8"))
    D = [x for g in A for x in defauts(g)]
    if len(sys.argv) > 2:
        T = json.loads(Path(sys.argv[2]).read_text(encoding="utf-8"))
        attendus = {(t["k"], t["genre"]): t["texte"] for t in T}
        vus = {}
        for g in A:
            c = (g.get("k"), g.get("genre"))
            vus[c] = vus.get(c, 0) + 1
            if c in attendus and g.get("texte") != attendus[c]:
                D.append(f"{c} : texte différent de celui donné")
            if c not in attendus:
                D.append(f"{c} : texte non demandé")
        D += [f"{c} : {n} graphes" for c, n in vus.items() if n > 1]
        D += [f"{c} : sans graphe" for c in attendus if c not in vus]
    print("\n".join(D) if D else f"{len(A)} graphes, aucun défaut de forme")
    sys.exit(1 if D else 0)


if __name__ == "__main__":
    main()
