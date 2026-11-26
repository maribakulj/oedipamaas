"""Compare des graphes d'assertions à des graphes de référence (lot 5 ; docs/BANC_GRAPHES.md, § 4).

Usage :
  python outils/graphes/comparer_graphes.py REFERENCES.json GRAPHES.json [--derivations] [--detail SORTIE.json]
  python outils/graphes/comparer_graphes.py --accord ANNOTATION_A.json ANNOTATION_B.json

REFERENCES.json : les graphes annotés (schéma du § 2 du guide), une liste d'objets {k, genre, langue, texte, entites,
evenements, relations, coref, distinct, alternatives}. GRAPHES.json : la sortie de outils/graphes/lire.pl (les faits du
lecteur), ou d'autres graphes annotés (--accord : l'accord entre deux annotateurs, par les mêmes mesures).

Les mesures, par catégorie (précision, rappel, F1, et les comptes) :
  entites       une entité de référence alignée sur une entité du graphe de même tête
  noms          (référent, nom)                        sous l'alignement
  proprietes    (référent, propriété)
  nombres       (référent, nombre), les nombres supérieurs à 1 (un singulier n'est pas un nombre dit)
  evenements    un événement de référence aligné sur un événement de même prédicat
  roles         (événement, rôle, référent)            « Hercule étrangle le lion » : le rôle et son sens
  roles_macro   la même chose, patient et thème confondus (la question E3 de l'étude)
  relations     (référent, relation, référent), orientée
  coref         les paires de mentions d'un même référent
  distinct      les paires de référents distincts
  negations     les assertions niées (polarité neg), sous l'alignement
  modalites     les assertions de modalité autre qu'affirme, avec leur modalité
  portees       les assertions de portée autre que represente, avec leur portée
  citations     les assertions d'un énonciateur cité
Un référent est une classe de coréférence : un rôle, une relation, un nom… est juste si son participant est aligné sur
une mention de la même classe de référence. Les entités et les événements sont alignés un à un (même tête ou même
prédicat : 2 points ; la tête du graphe dans la mention de référence : 1 point ; au moins 1 point), glouton par score
décroissant puis par position.

--derivations : chaque assertion dérivée (lire.pl, normalisation:deriver/3) est jugée contre la référence : juste si
elle ajoute un élément de référence qui manquait, fausse si elle ajoute un élément absent de la référence, sans effet
sinon ; par règle. C'est la mesure des règles hypothétiques (E1, E2, E3 de l'étude) sur des références construites
sans elles.

Rien ne dépend d'une ressource lexicale : les têtes et les prédicats sont comparés comme écrits (minuscules, espaces et
traits bas confondus). Une tête synonyme est une erreur de tête ; le rôle et la relation restent jugés par
l'alignement (le même passage)."""
import argparse
import collections
import json
import sys
import unicodedata
from pathlib import Path

CATEGORIES = ("entites", "noms", "proprietes", "nombres", "evenements", "roles", "roles_macro", "relations", "coref",
              "distinct", "negations", "modalites", "portees", "citations")
QUALIF_DEFAUT = {"polarite": "pos", "modalite": "affirme", "portee": "represente", "enonciateur": "auteur"}


def norm(x) -> str:
    s = unicodedata.normalize("NFC", str(x)).strip().lower().replace("_", " ")
    return " ".join(s.split())


def norm_nom(x) -> str:
    return norm(x).replace("’", "'")


# --- La forme commune : un graphe de mentions -------------------------------------------------------------------------

class Graphe:
    """Les mentions (entités, événements), leurs portées dans le texte, et les éléments à comparer."""

    def __init__(self, texte):
        self.texte = texte
        self.entites = {}       # id -> (tete, (debut, fin) ou None)
        self.evenements = {}    # id -> (predicat, (debut, fin) ou None, nom d'action ou None)
        self.noms, self.proprietes, self.nombres = [], [], []          # (entite, valeur, id d'assertion)
        self.roles, self.relations = [], []                            # (v, role, e) ; (e1, rel, e2, id)
        self.coref, self.distinct = [], []
        self.qualif = {}        # id d'assertion -> {polarite, modalite, portee, enonciateur}

    def classes(self):
        parent = {e: e for e in self.entites}

        def trouver(x):
            while parent[x] != x:
                parent[x] = parent[parent[x]]
                x = parent[x]
            return x
        for a, b in self.coref:
            if a in parent and b in parent:
                parent[trouver(a)] = trouver(b)
        return {e: trouver(e) for e in self.entites}


def portee_de_mention(texte, mention, deja):
    """La portée (début, fin) de la n-ième occurrence de la mention dans le texte (n : le nombre de fois qu'elle a déjà
    été prise), ou None si elle n'y est pas."""
    if not mention:
        return None
    m = str(mention)
    i, n = -1, deja.get(m, 0)
    for _ in range(n + 1):
        i = texte.find(m, i + 1)
        if i < 0:
            i = texte.lower().find(m.lower())
            break
    if i < 0:
        return None
    deja[m] = n + 1
    return (i, i + len(m))


def depuis_reference(r) -> Graphe:
    g = Graphe(r["texte"])
    deja = {}

    def qualif(ident, obj):
        g.qualif[ident] = {q: obj.get(q, d) for q, d in QUALIF_DEFAUT.items()}
    for e in r.get("entites", []):
        g.entites[e["id"]] = (norm(e["tete"]), portee_de_mention(g.texte, e.get("mention"), deja))
        qualif(e["id"], e)
        for i, n in enumerate(e.get("noms", [])):
            v, q = (n, {}) if isinstance(n, str) else (n["nom"], n)
            ident = f"{e['id']}#nom{i}"
            g.noms.append((e["id"], norm_nom(v), ident))
            qualif(ident, q)
        for i, p in enumerate(e.get("proprietes", [])):
            v, q = (p, {}) if isinstance(p, str) else (p["propriete"], p)
            ident = f"{e['id']}#prop{i}"
            g.proprietes.append((e["id"], norm(v), ident))
            qualif(ident, q)
        if e.get("nombre") is not None and int(e["nombre"]) > 1:      # « un » n'est pas un nombre dit (guide, § 3)
            g.nombres.append((e["id"], int(e["nombre"]), None))
    for v in r.get("evenements", []):
        g.evenements[v["id"]] = (norm(v["predicat"]), portee_de_mention(g.texte, v.get("mention"), deja),
                                 norm(v["nom_d_action"]) if v.get("nom_d_action") else None)
        qualif(v["id"], v)
        for role, es in v.get("roles", {}).items():
            for e in ([es] if isinstance(es, str) else es):
                g.roles.append((v["id"], role, e))
    for x in r.get("relations", []):
        g.relations.append((x["sujet"], norm(x["relation"]), x["objet"], x["id"]))
        qualif(x["id"], x)
    for c in r.get("coref", []):
        for a, b in zip(c, c[1:]):
            g.coref.append((a, b))
    for a, b in r.get("distinct", []):
        g.distinct.append((a, b))
    return g


def depuis_faits(r) -> Graphe:
    """Les faits de lire.pl ([Foncteur, Arg…]) ; les passages donnent les portées."""
    faits = r["faits"]
    g = Graphe(r["texte"])
    if faits == "erreur":
        g.erreur = True
        return g
    passages = {f[1]: (f[2], f[3]) for f in faits if f[0] == "passage"}
    alternatives = {a for f in faits if f[0] == "alternative" for a in f[2]}
    for f in faits:
        t = f[0]
        if t == "entite" and f[2] != "nom_propre":
            g.entites[f[1]] = (norm(f[2]), passages.get(f[3]))
        elif t == "entite":
            g.entites[f[1]] = ("", passages.get(f[3]))
        elif t == "evenement":
            g.evenements[f[1]] = (norm(f[2]), passages.get(f[3]), None)
        elif t == "nom":
            g.noms.append((f[2], norm_nom(f[3]), f[1]))
        elif t == "propriete":
            g.proprietes.append((f[2], norm(f[3]), f[1]))
        elif t == "nombre" and f[2] > 1:
            g.nombres.append((f[1], f[2], None))
        elif t == "role":
            g.roles.append((f[1], f[2], f[3]))
        elif t == "relation":
            g.relations.append((f[2], norm(f[3]), f[4], f[1]))
        elif t == "coref":
            g.coref.append((f[1], f[2]))
        elif t == "distinct":
            g.distinct.append((f[1], f[2]))
        elif t in QUALIF_DEFAUT:
            g.qualif.setdefault(f[1], dict(QUALIF_DEFAUT))[t] = f[2] if t != "enonciateur" else (
                f[2] if isinstance(f[2], str) else "cite")
    g.alternatives = alternatives
    return g


def ajouter_faits(g: Graphe, faits):
    """Ajoute des faits (une dérivation) à un graphe de lire.pl, sans passage : ils n'ont pas de portée propre."""
    h = Graphe(g.texte)
    h.__dict__.update({k: (v.copy() if isinstance(v, (dict, list)) else v) for k, v in g.__dict__.items()})
    for f in faits:
        t = f[0]
        if t == "entite":
            h.entites[f[1]] = (norm(f[2]) if f[2] != "nom_propre" else "", None)
        elif t == "evenement":
            h.evenements[f[1]] = (norm(f[2]), None, None)
        elif t == "propriete":
            h.proprietes.append((f[2], norm(f[3]), f[1]))
        elif t == "role":
            h.roles.append((f[1], f[2], f[3]))
        elif t == "relation":
            h.relations.append((f[2], norm(f[3]), f[4], f[1]))
        elif t == "coref":
            h.coref.append((f[1], f[2]))
        elif t in QUALIF_DEFAUT:
            h.qualif.setdefault(f[1], dict(QUALIF_DEFAUT))[t] = f[2] if t != "enonciateur" else (
                f[2] if isinstance(f[2], str) else "cite")
    return h


# --- L'alignement ------------------------------------------------------------------------------------------------------

def dans(portee_g, portee_r) -> bool:
    return bool(portee_g and portee_r and portee_r[0] <= portee_g[0] and portee_g[1] <= portee_r[1])


def chevauche(a, b) -> bool:
    return bool(a and b and a[0] < b[1] and b[0] < a[1])


def aligner(ref: dict, pred: dict, cle_ref=lambda x: x[0], cle_pred=lambda x: x[0], derivees=None):
    """Un à un : score 2 pour la même tête, +1 si la portée du graphe est dans celle de la référence (ou la
    chevauche) ; au moins 1 point. Une mention dérivée (sans portée) ne s'aligne que par sa tête, et seulement sur une
    mention de référence qui reste libre (derivees : ses identifiants, pour la placer après les mentions lues)."""
    paires = []
    for i, x in ref.items():
        for j, y in pred.items():
            s = (2 if cle_ref(x) and cle_ref(x) == cle_pred(y) else 0)
            if dans(y[1], x[1]) or chevauche(y[1], x[1]):
                s += 1
            elif s and x[1] and y[1]:
                s -= 1          # même tête, ailleurs dans le texte : une autre mention
            if s >= 1:
                derive = 1 if derivees and j in derivees else 0
                paires.append((-s, derive, (x[1] or (1e9,))[0], (y[1] or (1e9,))[0], i, j))
    paires.sort(key=lambda p: (p[0], p[1], p[2], p[3], str(p[4]), str(p[5])))
    a, pris = {}, set()
    for _, _, _, _, i, j in paires:
        if i not in a and j not in pris:
            a[i] = j
            pris.add(j)
    return a


# --- Les comptes -------------------------------------------------------------------------------------------------------

class Comptes:
    def __init__(self):
        self.c = {k: collections.Counter() for k in CATEGORIES}

    def ajouter(self, cat, vp, ref, pred):
        self.c[cat]["vp"] += vp
        self.c[cat]["ref"] += ref
        self.c[cat]["pred"] += pred

    def fusion(self, autre):
        for k in CATEGORIES:
            self.c[k].update(autre.c[k])

    def table(self):
        lignes = {}
        for k in CATEGORIES:
            vp, r, p = self.c[k]["vp"], self.c[k]["ref"], self.c[k]["pred"]
            P = vp / p if p else None
            R = vp / r if r else None
            F = 2 * P * R / (P + R) if P and R else (0.0 if (P is not None and R is not None) else None)
            lignes[k] = {"vp": vp, "ref": r, "pred": p, "precision": P, "rappel": R, "f1": F}
        return lignes


def ensemble_compare(cat, comptes, refs: set, preds: set, detail):
    vp = refs & preds
    comptes.ajouter(cat, len(vp), len(refs), len(preds))
    if detail is not None:
        detail[cat] = {"manquants": sorted(map(str, refs - preds)), "en_trop": sorted(map(str, preds - refs))}


def comparer(r: Graphe, g: Graphe, detail=None, derivees=None) -> Comptes:
    c = Comptes()
    if getattr(g, "erreur", False):
        g = Graphe(g.texte)
    ae = aligner(r.entites, g.entites, derivees=derivees)
    av = aligner(r.evenements, g.evenements, derivees=derivees)
    # une mention de référence par mention du graphe : les identifiants du graphe vus comme ceux de la référence
    inv_e = {j: i for i, j in ae.items()}
    inv_v = {j: i for i, j in av.items()}
    cr, cg = r.classes(), g.classes()
    # la classe de référence d'une entité du graphe : celle de sa mention alignée ; une mention non alignée est sa
    # propre classe (jamais juste)
    def classe_g(e):
        if e in inv_e:
            return cr[inv_e[e]]
        return ("hors", cg.get(e, e))

    def classe_r(e):
        return cr.get(e, ("inconnu", e))

    def ev_g(v):
        return inv_v.get(v, ("hors", v))
    # entités et événements : alignés et de même tête
    ensemble_compare("entites", c, {(i, x[0]) for i, x in r.entites.items()},
                     {(inv_e.get(j, ("hors", j)), y[0]) for j, y in g.entites.items() if y[0]}, detail)
    ensemble_compare("evenements", c, {(i, x[0]) for i, x in r.evenements.items()},
                     {(inv_v.get(j, ("hors", j)), y[0]) for j, y in g.evenements.items()}, detail)
    ensemble_compare("noms", c, {(classe_r(e), v) for e, v, _ in r.noms}, {(classe_g(e), v) for e, v, _ in g.noms},
                     detail)
    ensemble_compare("proprietes", c, {(classe_r(e), v) for e, v, _ in r.proprietes},
                     {(classe_g(e), v) for e, v, _ in g.proprietes}, detail)
    ensemble_compare("nombres", c, {(classe_r(e), v) for e, v, _ in r.nombres},
                     {(classe_g(e), v) for e, v, _ in g.nombres}, detail)
    ensemble_compare("roles", c, {(v, ro, classe_r(e)) for v, ro, e in r.roles},
                     {(ev_g(v), ro, classe_g(e)) for v, ro, e in g.roles}, detail)
    macro = lambda ro: "patient_theme" if ro in ("patient", "theme") else ro
    ensemble_compare("roles_macro", c, {(v, macro(ro), classe_r(e)) for v, ro, e in r.roles},
                     {(ev_g(v), macro(ro), classe_g(e)) for v, ro, e in g.roles}, detail)
    ensemble_compare("relations", c, {(classe_r(a), rel, classe_r(b)) for a, rel, b, _ in r.relations},
                     {(classe_g(a), rel, classe_g(b)) for a, rel, b, _ in g.relations}, detail)

    def paires_coref(gr, classes_, nom):
        par = collections.defaultdict(set)
        for e, k in classes_.items():
            par[k].add(nom(e))
        return {tuple(sorted(map(str, (a, b)))) for m in par.values() for a in m for b in m if str(a) < str(b)}
    ensemble_compare("coref", c, paires_coref(r, cr, lambda e: e),
                     paires_coref(g, {j: k for j, k in cg.items() if j in inv_e}, lambda j: inv_e[j]), detail)
    ensemble_compare("distinct", c, {tuple(sorted(map(str, (classe_r(a), classe_r(b))))) for a, b in r.distinct},
                     {tuple(sorted(map(str, (classe_g(a), classe_g(b))))) for a, b in g.distinct}, detail)
    # les qualificatifs : sur les assertions de référence et leurs correspondantes
    corr = {}                                       # id d'assertion du graphe -> id de référence
    corr.update(inv_e)
    corr.update(inv_v)
    for (e, v, ident) in g.noms:
        for (e2, v2, i2) in r.noms:
            if v == v2 and classe_g(e) == classe_r(e2):
                corr.setdefault(ident, i2)
    for (e, v, ident) in g.proprietes:
        for (e2, v2, i2) in r.proprietes:
            if v == v2 and classe_g(e) == classe_r(e2):
                corr.setdefault(ident, i2)
    for (a, rel, b, ident) in g.relations:
        for (a2, rel2, b2, i2) in r.relations:
            if rel == rel2 and classe_g(a) == classe_r(a2) and classe_g(b) == classe_r(b2):
                corr.setdefault(ident, i2)

    def qual(gr, q, defaut, nom):
        return {(nom(i), v[q]) for i, v in gr.qualif.items() if v[q] != defaut and not str(v[q]).startswith("#")}
    for cat, q in (("negations", "polarite"), ("modalites", "modalite"), ("portees", "portee"),
                   ("citations", "enonciateur")):
        d = QUALIF_DEFAUT[q]
        refs = qual(r, q, d, lambda i: i)
        preds = qual(g, q, d, lambda i: corr.get(i, ("hors", i)))
        if q == "enonciateur":
            refs = {(i, "cite") for i, _ in refs}
            preds = {(i, "cite") for i, _ in preds}
        ensemble_compare(cat, c, refs, preds, detail)
    return c


def charger(p):
    return json.loads(Path(p).read_text(encoding="utf-8"))


def cle(x):
    return (x["k"], x["genre"])


def imprimer(titre, comptes: Comptes):
    print(f"\n### {titre}\n")
    print("| catégorie | référence | graphe | justes | précision | rappel | F1 |")
    print("|---|---|---|---|---|---|---|")
    f = lambda x: "—" if x is None else f"{x:.2f}"
    for k, v in comptes.table().items():
        print(f"| {k} | {v['ref']} | {v['pred']} | {v['vp']} | {f(v['precision'])} | {f(v['rappel'])} | {f(v['f1'])} |")


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("references")
    ap.add_argument("graphes")
    ap.add_argument("--accord", action="store_true", help="GRAPHES est une seconde annotation")
    ap.add_argument("--derivations", action="store_true")
    ap.add_argument("--detail")
    a = ap.parse_args()
    R = {cle(x): x for x in charger(a.references)}
    G = {cle(x): x for x in charger(a.graphes)}
    communs = sorted(set(R) & set(G))
    if not communs:
        sys.exit("aucun texte commun")
    total, par_langue, details = Comptes(), collections.defaultdict(Comptes), []
    regles = collections.defaultdict(collections.Counter)
    erreurs = 0
    for k in communs:
        r = depuis_reference(R[k])
        g = depuis_reference(G[k]) if a.accord else depuis_faits(G[k])
        erreurs += getattr(g, "erreur", False)
        d = {} if a.detail else None
        c = comparer(r, g, d)
        total.fusion(c)
        par_langue[R[k]["langue"]].fusion(c)
        if a.detail:
            details.append({"k": k[0], "genre": k[1], "texte": R[k]["texte"], "detail": d})
        if a.derivations and not a.accord and not getattr(g, "erreur", False):
            base = {cat: v["vp"] for cat, v in c.table().items()}
            basep = {cat: v["pred"] for cat, v in c.table().items()}
            for der in G[k].get("derivations", []):
                if der["fait"][0] not in ("entite", "evenement", "role", "relation", "propriete", "coref"):
                    continue                     # un qualificatif dérivé suit son assertion : jugé avec elle
                h = ajouter_faits(g, [der["fait"]] + [s for s in der["sources"] if s not in G[k]["faits"]])
                ids = {der["fait"][1]} if der["fait"][0] in ("entite", "evenement") else set()
                c2 = comparer(r, h, derivees=ids).table()
                gain = sum(c2[cat]["vp"] - base[cat] for cat in ("roles", "relations", "evenements", "entites"))
                ajout = sum(c2[cat]["pred"] - basep[cat] for cat in ("roles", "relations", "evenements", "entites"))
                juge = "juste" if gain > 0 else ("fausse" if ajout > 0 else "sans_effet")
                regles[der["regle"]][juge] += 1
    print(f"{len(communs)} textes comparés ({len(R)} références, {len(G)} graphes) ; graphes en erreur : {erreurs}")
    imprimer("ensemble", total)
    for l, c in sorted(par_langue.items()):
        imprimer(f"langue {l}", c)
    if regles:
        print("\n### dérivations (lot 3), jugées contre la référence\n")
        print("| règle | justes | fausses | sans effet |\n|---|---|---|---|")
        for rg, n in sorted(regles.items()):
            print(f"| {rg} | {n['juste']} | {n['fausse']} | {n['sans_effet']} |")
    if a.detail:
        Path(a.detail).write_text(json.dumps({"total": total.table(), "par_langue": {l: c.table() for l, c in
                                                                                  par_langue.items()},
                                              "regles": regles, "textes": details}, ensure_ascii=False, indent=1),
                                  encoding="utf-8")


if __name__ == "__main__":
    main()
