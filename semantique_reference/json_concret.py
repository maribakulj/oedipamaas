"""La syntaxe concrète JSON (notation `nr-1`) : une traduction de la syntaxe abstraite (docs/LANGAGE_REFERENCE.md, § 4 ;
docs/NOTATION_REFERENCE.md, version 1). Elle ne porte aucune sémantique : `lire(ecrire(x)) == x` (un test le vérifie),
et toute la sémantique est dans interprete.py.

Les conventions :
- un terme est une chaîne ; « ?X » est une variable, toute autre chaîne un identifiant de référent (ou de situation) ;
- un type est une chaîne (un concept), ou {"alternatifs": point}, {"union": [T…]}, {"conjonction": [T…]} ; « ⊥ »
  se lit ⊥ (il n'est permis que comme valeur de point, RF8) ;
- les valeurs par défaut (qualification affirmée, positive, de l'auteur, dans `principal` ; garde vide ; provenance
  vide) ne sont pas écrites.
"""
from __future__ import annotations

import json
from dataclasses import fields

from . import syntaxe as S

NOTATION = "nr-1"


# --- les termes et les types --------------------------------------------------------------------------------

def lire_terme(t):
    if isinstance(t, str) and t.startswith("?"):
        return S.Var(t[1:])
    return t


def ecrire_terme(t):
    return "?" + t.nom if isinstance(t, S.Var) else t


def lire_type(t):
    if t is None:
        return None
    if isinstance(t, str):
        return S.INCONNU if t == S.VALEUR_INCONNUE else S.Concept(t)
    if "alternatifs" in t:
        return S.Alternatifs(t["alternatifs"])
    if "union" in t:
        return S.Union(tuple(lire_type(m) for m in t["union"]))
    if "conjonction" in t:
        return S.Conjonction(tuple(lire_type(m) for m in t["conjonction"]))
    raise ValueError(f"type inconnu : {t}")


def ecrire_type(t):
    if t is None:
        return None
    if isinstance(t, S.Concept):
        return t.id
    if isinstance(t, S.Inconnu):
        return S.VALEUR_INCONNUE
    if isinstance(t, S.Alternatifs):
        return {"alternatifs": t.point}
    if isinstance(t, S.Union):
        return {"union": [ecrire_type(m) for m in t.membres]}
    if isinstance(t, S.Conjonction):
        return {"conjonction": [ecrire_type(m) for m in t.membres]}
    raise TypeError(t)


# --- les atomes et les formules -------------------------------------------------------------------------------

def lire_atome(d) -> S.Atome:
    ctx = d.get("contexte")
    return S.Atome(d["pred"], tuple(lire_terme(t) for t in d["args"]), lire_type(d.get("type")), d.get("valeur"),
                   lire_terme(ctx) if ctx is not None else None)


def ecrire_atome(a: S.Atome) -> dict:
    d = {"pred": a.pred, "args": [ecrire_terme(t) for t in a.args]}
    if a.type is not None:
        d["type"] = ecrire_type(a.type)
    if a.valeur is not None:
        d["valeur"] = a.valeur
    if a.contexte is not None:
        d["contexte"] = ecrire_terme(a.contexte)
    return d


def lire_formule(d):
    if d is None:
        return None
    if "pred" in d:
        return lire_atome(d)
    if "et" in d:
        return S.Et(tuple(lire_formule(f) for f in d["et"]))
    if "ou" in d:
        return S.Ou(tuple(lire_formule(f) for f in d["ou"]))
    if "non" in d:
        return S.Non(lire_formule(d["non"]))
    if "existe" in d:
        e = d["existe"]
        return S.Existe(tuple(tuple(v) for v in e["variables"]), lire_formule(e["corps"]))
    if "compte" in d:
        c = d["compte"]
        return S.Compte(c["quant"], c.get("n"), tuple(c["variable"]), lire_formule(c["restriction"]),
                        lire_formule(c.get("portee")), tuple(lire_terme(m) for m in c.get("membres", [])))
    if "selon" in d:
        s = d["selon"]
        return S.Selon(s["point"], tuple((v, lire_formule(f)) for v, f in s["cas"].items()))
    raise ValueError(f"formule inconnue : {d}")


def ecrire_formule(F):
    if F is None:
        return None
    if isinstance(F, S.Atome):
        return ecrire_atome(F)
    if isinstance(F, S.Et):
        return {"et": [ecrire_formule(f) for f in F.enfants]}
    if isinstance(F, S.Ou):
        return {"ou": [ecrire_formule(f) for f in F.enfants]}
    if isinstance(F, S.Non):
        return {"non": ecrire_formule(F.corps)}
    if isinstance(F, S.Existe):
        return {"existe": {"variables": [list(v) for v in F.variables], "corps": ecrire_formule(F.corps)}}
    if isinstance(F, S.Compte):
        c = {"quant": F.quant, "variable": list(F.variable), "restriction": ecrire_formule(F.restriction)}
        if F.n is not None:
            c["n"] = F.n
        if F.portee is not None:
            c["portee"] = ecrire_formule(F.portee)
        if F.membres:
            c["membres"] = [ecrire_terme(m) for m in F.membres]
        return {"compte": c}
    if isinstance(F, S.Selon):
        return {"selon": {"point": F.point, "cas": {v: ecrire_formule(f) for v, f in F.cas}}}
    raise TypeError(F)


# --- les assertions ---------------------------------------------------------------------------------------

def _lire_dc(cls, d):
    return cls(**{f.name: (tuple(d[f.name]) if isinstance(d.get(f.name), list) else d[f.name])
                  for f in fields(cls) if f.name in d})


def _ecrire_dc(x, defaut) -> dict:
    return {f.name: getattr(x, f.name) for f in fields(x) if getattr(x, f.name) != getattr(defaut, f.name)}


def lire_contenu(d):
    if "atome" in d:
        return lire_atome(d["atome"])
    if "non" in d:
        n = d["non"]
        return S.Proposition(tuple(tuple(v) for v in n.get("locales", [])), tuple(lire_atome(a) for a in n["atomes"]))
    if "quantification" in d:
        q = d["quantification"]
        return S.Quantification(q["quant"], q.get("n"), tuple(q["variable"]),
                                tuple(lire_atome(a) for a in q["restriction"]),
                                tuple(lire_atome(a) for a in q.get("portee", [])), tuple(q.get("membres", [])),
                                q.get("situation"))
    raise ValueError(f"contenu inconnu : {d}")


def ecrire_contenu(c) -> dict:
    if isinstance(c, S.Atome):
        return {"atome": ecrire_atome(c)}
    if isinstance(c, S.Proposition):
        d = {"atomes": [ecrire_atome(a) for a in c.atomes]}
        if c.locales:
            d["locales"] = [list(v) for v in c.locales]
        return {"non": d}
    if isinstance(c, S.Quantification):
        q = {"quant": c.quant, "variable": list(c.variable), "restriction": [ecrire_atome(a) for a in c.restriction]}
        if c.n is not None:
            q["n"] = c.n
        if c.portee:
            q["portee"] = [ecrire_atome(a) for a in c.portee]
        if c.membres:
            q["membres"] = list(c.membres)
        if c.situation is not None:
            q["situation"] = c.situation
        return {"quantification": q}
    raise TypeError(c)


def lire_garde(d) -> S.Garde:
    return S.Garde(tuple((p, tuple(vs)) for p, vs in (d or {}).items()))


def ecrire_garde(g: S.Garde):
    return {p: list(vs) for (p, vs) in g.conditions}


def lire_assertion(d) -> S.Assertion:
    return S.Assertion(d["id"], lire_contenu(d["contenu"]), _lire_dc(S.Qualification, d.get("qualification", {})),
                       lire_garde(d.get("garde")), _lire_dc(S.Provenance, d.get("provenance", {})))


def ecrire_assertion(a: S.Assertion) -> dict:
    d = {"id": a.id, "contenu": ecrire_contenu(a.contenu)}
    q = _ecrire_dc(a.qualification, S.Qualification())
    if q:
        d["qualification"] = q
    if a.garde.conditions:
        d["garde"] = ecrire_garde(a.garde)
    p = _ecrire_dc(a.provenance, S.Provenance())
    if p:
        d["provenance"] = p
    return d


# --- points, contraintes, préférences ---------------------------------------------------------------------

def lire_point(d) -> S.Point:
    return S.Point(d["id"], d["cote"], d["dimension"], tuple(d["domaine"]), d.get("ancre"),
                   _lire_dc(S.Provenance, d.get("provenance", {})))


def ecrire_point(p: S.Point) -> dict:
    d = {"id": p.id, "cote": p.cote, "dimension": p.dimension, "domaine": list(p.domaine)}
    if p.ancre is not None:
        d["ancre"] = p.ancre
    pr = _ecrire_dc(p.provenance, S.Provenance())
    if pr:
        d["provenance"] = pr
    return d


def lire_contrainte(d) -> S.Contrainte:
    return S.Contrainte(d["id"], d["forme"], tuple(tuple(sorted(c.items())) for c in d["interdits"]), d["source"],
                        d.get("sorte", "texte"))


def ecrire_contrainte(c: S.Contrainte) -> dict:
    d = {"id": c.id, "forme": c.forme, "interdits": [dict(comb) for comb in c.interdits], "source": c.source}
    if c.sorte != "texte":
        d["sorte"] = c.sorte
    return d


def exclusion(ident, point, valeurs, source, sorte="texte") -> S.Contrainte:
    """La forme `exclusion` : le point p ne prend aucune de ces valeurs."""
    return S.Contrainte(ident, "exclusion", tuple(((point, v),) for v in valeurs), source, sorte)


def exclusion_conjointe(ident, combinaisons, source, sorte="texte") -> S.Contrainte:
    """La forme `exclusion_conjointe` : ces combinaisons de valeurs de plusieurs points sont interdites."""
    return S.Contrainte(ident, "exclusion_conjointe", tuple(tuple(sorted(c.items())) for c in combinaisons),
                        source, sorte)


def implication(ident, si, alors_point, alors_valeurs, domaine_alors, source, sorte="texte") -> S.Contrainte:
    """La forme `implication` : si p = v (si est un dict), alors q ∈ W ; elle interdit p = v ∧ q ∉ W."""
    interdits = tuple(tuple(sorted(list(si.items()) + [(alors_point, w)])) for w in domaine_alors
                      if w not in alors_valeurs)
    return S.Contrainte(ident, "implication", interdits, source, sorte)


def lire_preference(d) -> S.Preference:
    return S.Preference(d["id"], d.get("point"), tuple(d.get("ordre", [])), tuple(d.get("couplage", [])),
                        d.get("source", ""))


def ecrire_preference(p: S.Preference) -> dict:
    d = {"id": p.id}
    if p.point is not None:
        d["point"] = p.point
    if p.ordre:
        d["ordre"] = list(p.ordre)
    if p.couplage:
        d["couplage"] = list(p.couplage)
    if p.source:
        d["source"] = p.source
    return d


# --- la description, la définition ------------------------------------------------------------------------

def lire_description(d) -> S.Description:
    return S.Description(
        d["id"], d.get("langue", "fr"), d.get("texte", ""),
        tuple(_lire_dc(S.Contexte, c) for c in d.get("contextes", [{"id": S.RACINE, "sorte": "figuration"}])),
        tuple(_lire_dc(S.Referent, r) for r in d.get("referents", [])),
        tuple(lire_assertion(a) for a in d.get("assertions", [])),
        tuple(S.Alternative(a["id"], tuple(tuple(b) for b in a["branches"]),
                            _lire_dc(S.Provenance, a.get("provenance", {}))) for a in d.get("alternatives", [])),
        tuple(lire_point(p) for p in d.get("points", [])),
        tuple(lire_contrainte(c) for c in d.get("contraintes", [])),
        tuple(lire_preference(p) for p in d.get("preferences", [])))


def ecrire_description(D: S.Description) -> dict:
    d = {"id": D.id, "langue": D.langue}
    if D.texte:
        d["texte"] = D.texte
    d["contextes"] = [_ecrire_dc(c, S.Contexte(c.id, c.sorte)) | {"id": c.id, "sorte": c.sorte} for c in D.contextes]
    d["referents"] = [_ecrire_dc(r, S.Referent(r.id, r.sorte)) | {"id": r.id, "sorte": r.sorte} for r in D.referents]
    d["assertions"] = [ecrire_assertion(a) for a in D.assertions]
    for nom, xs, f in (("alternatives", D.alternatives,
                        lambda a: {"id": a.id, "branches": [list(b) for b in a.branches]}),
                       ("points", D.points, ecrire_point), ("contraintes", D.contraintes, ecrire_contrainte),
                       ("preferences", D.preferences, ecrire_preference)):
        if xs:
            d[nom] = [f(x) for x in xs]
    return d


def lire_definition(d) -> S.Definition:
    return S.Definition(
        d["id"], d.get("libelle", ""), d.get("langue", "en"), tuple(tuple(v) for v in d.get("variables", [])),
        lire_formule(d["suffisante"]), lire_formule(d.get("necessaire")), d.get("statut_suffisance", "etablie"),
        d.get("statut_necessite", "etablie"), tuple(lire_point(p) for p in d.get("points", [])),
        tuple(lire_contrainte(c) for c in d.get("contraintes", [])),
        tuple(lire_preference(p) for p in d.get("preferences", [])), _lire_dc(S.Provenance, d.get("provenance", {})))


def ecrire_definition(Dl: S.Definition) -> dict:
    d = {"id": Dl.id, "libelle": Dl.libelle, "langue": Dl.langue, "variables": [list(v) for v in Dl.variables],
         "suffisante": ecrire_formule(Dl.suffisante)}
    if Dl.necessaire is not None:
        d["necessaire"] = ecrire_formule(Dl.necessaire)
    if Dl.statut_suffisance != "etablie":
        d["statut_suffisance"] = Dl.statut_suffisance
    if Dl.statut_necessite != "etablie":
        d["statut_necessite"] = Dl.statut_necessite
    for nom, xs, f in (("points", Dl.points, ecrire_point), ("contraintes", Dl.contraintes, ecrire_contrainte),
                       ("preferences", Dl.preferences, ecrire_preference)):
        if xs:
            d[nom] = [f(x) for x in xs]
    p = _ecrire_dc(Dl.provenance, S.Provenance())
    if p:
        d["provenance"] = p
    return d


# --- K ----------------------------------------------------------------------------------------------------

SORTES_K = {
    "inclusion": S.Inclusion, "partie": S.Partie, "equivalence": S.Equivalence, "regle": S.Regle,
    "definition": S.DefinitionK, "typique": S.Typique, "incompatibilite": S.Incompatibilite,
    "antonymie": S.Antonymie, "opposition_typique": S.OppositionTypique,
    "restriction_de_selection": S.RestrictionSelection, "alias": S.Alias, "distinction": S.Distinction,
}
NOM_K = {v: k for k, v in SORTES_K.items()}
CHAMPS_ATOMES = ("premisse", "conclusion", "suffisante", "necessaire")


def lire_entree(d):
    """Une entrée de K : `entree` en nomme l'espèce (inclusion, regle, incompatibilite…) ; `sorte` est un champ
    de l'entrée elle-même (la sorte d'une règle, d'une incompatibilité)."""
    cls = SORTES_K[d["entree"]]
    kw = {}
    for f in fields(cls):
        if f.name not in d:
            continue
        v = d.get(f.name)
        if f.name == "source":
            v = S.Source(**v)
        elif f.name in CHAMPS_ATOMES:
            v = tuple(lire_atome(a) for a in v)
        elif f.name in ("variables", "locales"):
            v = tuple(tuple(x) for x in v)
        elif isinstance(v, list):
            v = tuple(v)
        kw[f.name] = v
    return cls(**kw)


def ecrire_entree(e) -> dict:
    d = {"entree": NOM_K[type(e)]}
    for f in fields(e):
        v = getattr(e, f.name)
        if f.name == "source":
            v = {k: x for k, x in vars(v).items() if x}
        elif f.name in CHAMPS_ATOMES:
            v = [ecrire_atome(a) for a in v]
        elif isinstance(v, tuple):
            v = [list(x) if isinstance(x, tuple) else x for x in v]
        d[f.name] = v
    return d


def lire_connaissances(d) -> S.Connaissances:
    return S.Connaissances(d.get("version", "K"), tuple(lire_entree(e) for e in d.get("entrees", [])))


def ecrire_connaissances(K: S.Connaissances) -> dict:
    return {"version": K.version, "entrees": [ecrire_entree(e) for e in K.entrees]}


# --- le cas -----------------------------------------------------------------------------------------------

def lire_cas(d) -> S.Cas:
    if d.get("notation") != NOTATION:
        raise ValueError(f"notation {d.get('notation')!r} : attendu {NOTATION!r}")
    return S.Cas(d["id"], lire_description(d["description"]), lire_definition(d["definition"]),
                 lire_connaissances(d.get("connaissances", {})), d.get("remarques", ""))


def ecrire_cas(c: S.Cas) -> dict:
    d = {"notation": NOTATION, "id": c.id, "description": ecrire_description(c.description),
         "definition": ecrire_definition(c.definition), "connaissances": ecrire_connaissances(c.connaissances)}
    if c.remarques:
        d["remarques"] = c.remarques
    return d


def charger(chemin) -> dict:
    with open(chemin, encoding="utf-8") as f:
        return json.load(f)


def lire_fichier(chemin) -> S.Cas:
    return lire_cas(charger(chemin))


def ecrire_fichier(c: S.Cas, chemin):
    with open(chemin, "w", encoding="utf-8") as f:
        json.dump(ecrire_cas(c), f, ensure_ascii=False, indent=1)
        f.write("\n")
