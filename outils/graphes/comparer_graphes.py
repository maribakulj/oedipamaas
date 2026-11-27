"""Compare des graphes d'assertions à des graphes de référence (lot 5 ; docs/BANC_GRAPHES.md, § 4).

Usage :
  python outils/graphes/comparer_graphes.py REFERENCES.json GRAPHES.json [options]
  python outils/graphes/comparer_graphes.py --accord ANNOTATION_A.json ANNOTATION_B.json [options]
Options :
  --alignement optimal|glouton   l'appariement des mentions (optimal par défaut : affectation de poids maximal)
  --referents classes|mentions   un participant est juste s'il est aligné sur une mention de la même classe de
                                 coréférence de référence (classes, défaut), ou sur la mention annotée elle-même
                                 (mentions : la mesure sans l'aide des coréférences de référence)
  --ordre-inverse                les mentions répétées prennent leurs occurrences dans l'ordre inverse (sensibilité)
  --derivations                  juge chaque dérivation du lecteur (lire.pl), canonisée, avec ses dépendances
  --detail SORTIE.json           tout, texte par texte
  --json SORTIE.json             les tables seulement

REFERENCES.json : les graphes annotés (schéma du § 2 du guide). GRAPHES.json : la sortie de outils/graphes/lire.pl
(les faits du lecteur), ou d'autres graphes annotés (--accord).

Les mesures, par catégorie (précision, rappel, F1, comptes), en deux versions :
  structure   l'élément seul (la tête, le prédicat, le rôle et ses deux bouts…)
  qualifiee   l'élément et les qualificatifs de son assertion (polarité, modalité, portée, énonciateur, appartenance à
              une alternative) : une assertion entièrement qualifiée ; un rôle prend ceux de son événement
Catégories : entites, noms, proprietes, nombres (> 1), evenements, roles, roles_macro (patient et thème confondus),
relations (orientées), coref (paires de mentions), distinct, et les qualificatifs eux-mêmes (negations, modalites,
portees, citations, alternatives : les assertions qui les portent, sous la correspondance des assertions).
La sûreté : parmi les assertions de référence NON admissibles (niées, modalisées, d'une autre portée que represente,
d'une source citée, ou d'une alternative) qui ont une correspondante dans le graphe, celles que le graphe rend
admissibles (positives, affirmées, figurées, de l'auteur, hors alternative) : une promotion, la faute qui compromet le
noyau. À l'inverse, les rétrogradations (admissible en référence, non admissible dans le graphe : une perte, sans
danger pour la sûreté).
Les rôles : la matrice de confusion (rôle de référence × rôle du graphe, « aucun » compris), sur les paires
(événement, participant) dont l'un des deux graphes donne un rôle.

Alignement : un poids par paire (mention de référence, mention du graphe) : 2 pour la même tête (ou le même
prédicat), +1 si la portée du graphe est dans celle de la référence (ou la chevauche), -1 si les deux ont la même
tête mais ailleurs dans le texte ; une paire de poids < 1 n'est jamais alignée. L'appariement optimal maximise la
somme des poids (algorithme hongrois), à égalité la proximité des positions ; le glouton prend les paires par poids
décroissant puis par position. Les mentions répétées prennent leurs occurrences dans l'ordre de la liste annotée, en
mots entiers d'abord.

Dérivations (--derivations), chacune avec les dérivations dont elle dépend (ses sources dérivées, de proche en
proche), canonisée selon le guide (une action est un événement : l'entité « nom d'action » d'E1 est la forme non
conforme de son événement source, et sa relation « of » / « de » celle du rôle source), puis classée :
  non_conforme   sa forme n'est pas celle du guide (E1) ; son contenu canonisé est jugé ensuite (compté deux fois)
  non_evaluee    (E1) son contenu canonisé est déjà dans le graphe : la dérivation n'ajoute rien de comparable, et sa
                 forme propre (le nom d'action, son sens, le complément pris pour le patient) n'a pas d'équivalent dans
                 le guide. Ce n'est PAS un jugement de justesse : seules ses sources sont jugées (sources_justes,
                 sources_fausses), et ce qu'elle dit de plus n'est pas évalué
  redondante     (hors E1) son contenu canonisé est déjà dans le graphe, ou n'y change rien
  gain           elle ajoute au moins un élément juste, et aucun faux
  gain_et_erreur elle ajoute au moins un élément juste et au moins un faux (une même transformation) : comptée
                 ici, jamais comme un gain ; l'origine de son erreur est comptée à part (_regle, _heritee)
  erreur         elle n'ajoute que des éléments faux ; _regle si ses sources lues sont justes, _heritee sinon
Les éléments ajoutés sont aussi comptés un à un, par règle : elements_justes (vrais positifs ajoutés) et elements_faux
(prédictions ajoutées qui ne sont pas des vrais positifs).
Une source lue est juste si la référence a le même élément, entièrement : une entité alignée de même tête ; un
événement aligné de même prédicat ; un rôle entre l'événement et le référent que la référence relie, avec la même
étiquette ; une relation de même étiquette entre les mêmes référents ; une propriété de même mot sur le même référent ;
et, pour chacune, les mêmes qualificatifs (polarité, modalité, portée, énonciateur, alternative ; ceux de l'événement
pour un rôle). La source qu'une règle réécrit, dans une forme que le guide n'a pas, n'est jugée que sur ce que la règle
garde (REECRIT : l'étiquette du rôle de R1 et R2, la propriété participe de P1, le nom d'action et sa relation
génitive d'E2 ; leurs qualificatifs n'ont pas de correspondant et ne sont pas comparés). La raison de
chaque source fausse est comptée (sources_fausses:mention, :tete, :predicat, :role, :etiquette_role, :relation,
:propriete, :qualificatifs).

Rien ne dépend d'une ressource lexicale : têtes et prédicats comparés comme écrits (minuscules, espaces et traits bas
confondus ; la forme pronominale française d'un prédicat est celle du verbe)."""
import argparse
import collections
import itertools
import json
import re
import sys
import unicodedata
from pathlib import Path

STRUCTURELLES = ("entites", "noms", "proprietes", "nombres", "evenements", "roles", "roles_macro", "relations")
QUALIFICATIFS = ("negations", "modalites", "portees", "citations", "alternatives")
QUALIF_DEFAUT = {"polarite": "pos", "modalite": "affirme", "portee": "represente", "enonciateur": "auteur"}
ROLES = ("agent", "patient", "theme", "instrument", "destinataire", "lieu")
ADMISSIBLE = ("pos", "affirme", "represente", "auteur", False)


def norm(x) -> str:
    s = unicodedata.normalize("NFC", str(x)).strip().lower().replace("_", " ")
    return " ".join(s.split())


def norm_pred(x) -> str:
    s = norm(x).replace("’", "'")
    for p in ("se ", "s'"):
        if s.startswith(p):
            return s[len(p):].strip()
    return s


def norm_nom(x) -> str:
    return norm(x).replace("’", "'")


# --- La forme commune --------------------------------------------------------------------------------------------------

class Graphe:
    def __init__(self, texte):
        self.texte = texte
        self.entites = {}        # id -> (tete, portee ou None)
        self.evenements = {}     # id -> (predicat, portee ou None)
        self.noms, self.proprietes, self.nombres = [], [], []           # (entite, valeur, id d'assertion)
        self.roles, self.relations = [], []                             # (v, role, e) ; (e1, rel, e2, id)
        self.coref, self.distinct = [], []
        self.qualif = {}         # id d'assertion -> {polarite, modalite, portee, enonciateur}
        self.alternatives = set()
        self.erreur = False

    def q(self, ident):
        """La signature qualifiée d'une assertion : (polarité, modalité, portée, énonciateur, en alternative)."""
        d = self.qualif.get(ident, QUALIF_DEFAUT)
        en = d.get("enonciateur", "auteur")
        return (d.get("polarite", "pos"), d.get("modalite", "affirme"), d.get("portee", "represente"),
                "auteur" if en == "auteur" else "cite", ident in self.alternatives)

    def admissible(self, ident):
        return self.q(ident) == ADMISSIBLE

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

    def copie(self):
        h = Graphe(self.texte)
        for k, v in self.__dict__.items():
            setattr(h, k, v.copy() if isinstance(v, (dict, list, set)) else v)
        return h


def occurrences(texte, m):
    motif = r"(?<!\w)" + re.escape(m) + r"(?!\w)"
    for occ in (list(re.finditer(motif, texte)), list(re.finditer(motif, texte, re.I)),
                list(re.finditer(re.escape(m), texte, re.I))):
        if occ:
            return [(o.start(), o.end()) for o in occ]
    return []


def depuis_reference(r, ordre_inverse=False) -> Graphe:
    """Les mentions répétées prennent leurs occurrences dans l'ordre de la liste annotée (entités, puis événements),
    ou dans l'ordre inverse (ordre_inverse : pour mesurer la sensibilité de la mesure à cette convention)."""
    g = Graphe(r["texte"])
    mentions = [x.get("mention") for x in r.get("entites", []) + r.get("evenements", [])]
    total = collections.Counter(m for m in mentions if m)
    vues = collections.Counter()

    def place(m):
        if not m:
            return None
        occ = occurrences(g.texte, str(m))
        if not occ:
            return None
        n = vues[m]
        vues[m] += 1
        i = (total[m] - 1 - n) if ordre_inverse else n
        return occ[max(0, min(i, len(occ) - 1))]

    def qualif(ident, obj):
        q = {k: obj.get(k, d) for k, d in QUALIF_DEFAUT.items()}
        if q["enonciateur"] != "auteur":
            q["enonciateur"] = "cite"
        g.qualif[ident] = q
    for e in r.get("entites", []):
        g.entites[e["id"]] = (norm(e["tete"]), place(e.get("mention")))
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
            g.nombres.append((e["id"], int(e["nombre"]), e["id"]))
    for v in r.get("evenements", []):
        g.evenements[v["id"]] = (norm_pred(v["predicat"]), place(v.get("mention")))
        qualif(v["id"], v)
        for role, es in (v.get("roles") or {}).items():
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
    for alt in r.get("alternatives", []):
        g.alternatives |= set(alt)
    return g


def ajouter(g: Graphe, f, passages=None):
    """Ajoute un fait du lecteur ([Foncteur, Arg…]) à un graphe."""
    passages = passages or {}
    t = f[0]
    if t == "entite":
        g.entites[f[1]] = (norm(f[2]) if f[2] != "nom_propre" else "", passages.get(f[3]))
    elif t == "evenement":
        g.evenements[f[1]] = (norm_pred(f[2]), passages.get(f[3]))
    elif t == "nom":
        g.noms.append((f[2], norm_nom(f[3]), f[1]))
    elif t == "propriete":
        g.proprietes.append((f[2], norm(f[3]), f[1]))
    elif t == "nombre" and isinstance(f[2], int) and f[2] > 1:
        g.nombres.append((f[1], f[2], f[1]))
    elif t == "role":
        g.roles.append((f[1], f[2], f[3]))
    elif t == "relation":
        g.relations.append((f[2], norm(f[3]), f[4], f[1]))
    elif t == "coref":
        g.coref.append((f[1], f[2]))
    elif t == "distinct":
        g.distinct.append((f[1], f[2]))
    elif t == "alternative":
        g.alternatives |= set(f[2])
    elif t in QUALIF_DEFAUT:
        g.qualif.setdefault(f[1], dict(QUALIF_DEFAUT))[t] = f[2] if t != "enonciateur" else (
            f[2] if f[2] == "auteur" else "cite")


def depuis_faits(r) -> Graphe:
    g = Graphe(r["texte"])
    if r["faits"] == "erreur":
        g.erreur = True
        return g
    passages = {f[1]: (f[2], f[3]) for f in r["faits"] if f[0] == "passage"}
    for f in r["faits"]:
        ajouter(g, f, passages)
    return g


# --- L'appariement -----------------------------------------------------------------------------------------------------

def hongrois(poids):
    """Affectation de poids maximal d'une matrice rectangulaire (liste de listes ; None : paire interdite) ; rend
    {ligne: colonne}. Algorithme hongrois (potentiels), O(n³), sur la matrice carrée complétée."""
    n_l = len(poids)
    n_c = len(poids[0]) if n_l else 0
    n = max(n_l, n_c)
    if n == 0:
        return {}
    grand = 1 + max([abs(p) for ligne in poids for p in ligne if p is not None] or [0])
    cout = [[(grand - poids[i][j]) if i < n_l and j < n_c and poids[i][j] is not None else 2 * grand
             for j in range(n)] for i in range(n)]
    INF = float("inf")
    u, v, p, way = [0.0] * (n + 1), [0.0] * (n + 1), [0] * (n + 1), [0] * (n + 1)
    for i in range(1, n + 1):
        p[0] = i
        j0 = 0
        minv = [INF] * (n + 1)
        used = [False] * (n + 1)
        while True:
            used[j0] = True
            i0, delta, j1 = p[j0], INF, 0
            for j in range(1, n + 1):
                if not used[j]:
                    c = cout[i0 - 1][j - 1] - u[i0] - v[j]
                    if c < minv[j]:
                        minv[j], way[j] = c, j0
                    if minv[j] < delta:
                        delta, j1 = minv[j], j
            for j in range(n + 1):
                if used[j]:
                    u[p[j]] += delta
                    v[j] -= delta
                else:
                    minv[j] -= delta
            j0 = j1
            if p[j0] == 0:
                break
        while True:
            j1 = way[j0]
            p[j0] = p[j1]
            j0 = j1
            if j0 == 0:
                break
    res = {}
    for j in range(1, n + 1):
        i = p[j]
        if i and i <= n_l and j <= n_c and poids[i - 1][j - 1] is not None:
            res[i - 1] = j - 1
    return res


def dans(a, b) -> bool:
    return bool(a and b and b[0] <= a[0] and a[1] <= b[1])


def chevauche(a, b) -> bool:
    return bool(a and b and a[0] < b[1] and b[0] < a[1])


def poids_paire(x, y):
    s = 2 if x[0] and x[0] == y[0] else 0
    if dans(y[1], x[1]) or chevauche(y[1], x[1]):
        s += 1
    elif s and x[1] and y[1]:
        s -= 1
    return s


def aligner(ref: dict, pred: dict, methode="optimal", derivees=None):
    """{id de référence: id du graphe}. Une mention dérivée (derivees) passe après une mention lue à poids égal."""
    R, P = list(ref), list(pred)
    if not R or not P:
        return {}
    if methode == "glouton":
        paires = []
        for i in R:
            for j in P:
                s = poids_paire(ref[i], pred[j])
                if s >= 1:
                    d = 1 if derivees and j in derivees else 0
                    paires.append((-s, d, (ref[i][1] or (1e9,))[0], (pred[j][1] or (1e9,))[0], str(i), str(j), i, j))
        paires.sort(key=lambda t: t[:6])
        a, pris = {}, set()
        for *_, i, j in paires:
            if i not in a and j not in pris:
                a[i] = j
                pris.add(j)
        return a
    W = []
    for i in R:
        ligne = []
        for j in P:
            s = poids_paire(ref[i], pred[j])
            if s < 1:
                ligne.append(None)
                continue
            px, py = ref[i][1], pred[j][1]
            prox = 1.0 / (1 + abs(px[0] - py[0])) if px and py else 0.0
            d = 0.01 if derivees and j in derivees else 0.0
            ligne.append(s * 10 + prox - d)
        W.append(ligne)
    return {R[i]: P[j] for i, j in hongrois(W).items()}


# --- Les comptes -------------------------------------------------------------------------------------------------------

class Comptes:
    def __init__(self):
        self.c = collections.defaultdict(collections.Counter)

    def ajouter(self, cat, vp, ref, pred):
        self.c[cat]["vp"] += vp
        self.c[cat]["ref"] += ref
        self.c[cat]["pred"] += pred

    def fusion(self, autre):
        for k, v in autre.c.items():
            self.c[k].update(v)

    def table(self):
        t = {}
        for k in sorted(self.c):
            vp, r, p = self.c[k]["vp"], self.c[k]["ref"], self.c[k]["pred"]
            P = vp / p if p else None
            R = vp / r if r else None
            F = 2 * P * R / (P + R) if P and R else (0.0 if (P is not None and R is not None) else None)
            t[k] = {"vp": vp, "ref": r, "pred": p, "precision": P, "rappel": R, "f1": F}
        return t


class Resultat:
    def __init__(self):
        self.comptes = Comptes()
        self.securite = collections.Counter()
        self.confusion = collections.Counter()      # (rôle de référence ou « aucun », rôle du graphe ou « aucun »)
        self.detail = {}
        self.promotions = []

    def fusion(self, autre):
        self.comptes.fusion(autre.comptes)
        self.securite.update(autre.securite)
        self.confusion.update(autre.confusion)


def assertions(g: Graphe):
    """Les identifiants des assertions qualifiables d'un graphe : entités (têtes), noms, propriétés, événements,
    relations."""
    return (set(g.entites) | set(g.evenements) | {a for _, _, a in g.noms} | {a for _, _, a in g.proprietes}
            | {i for _, _, _, i in g.relations})


def comparer(r: Graphe, g: Graphe, methode="optimal", referents="classes", derivees=None, detail=False) -> Resultat:
    res = Resultat()
    if g.erreur:
        g = Graphe(g.texte)
    ae = aligner(r.entites, g.entites, methode, derivees)
    av = aligner(r.evenements, g.evenements, methode, derivees)
    inv_e = {j: i for i, j in ae.items()}
    inv_v = {j: i for i, j in av.items()}
    cr = r.classes() if referents == "classes" else {e: e for e in r.entites}

    def classe_g(e):
        return cr[inv_e[e]] if e in inv_e else ("hors", e)

    def classe_r(e):
        return cr.get(e, ("inconnu", e))

    def ev_g(v):
        return inv_v.get(v, ("hors", v))

    def macro(ro):
        return "patient_theme" if ro in ("patient", "theme") else ro
    R = {
        "entites": [((i, x[0]), i) for i, x in r.entites.items()],
        "evenements": [((i, x[0]), i) for i, x in r.evenements.items()],
        "noms": [((classe_r(e), v), a) for e, v, a in r.noms],
        "proprietes": [((classe_r(e), v), a) for e, v, a in r.proprietes],
        "nombres": [((classe_r(e), v), a) for e, v, a in r.nombres],
        "roles": [((v, ro, classe_r(e)), v) for v, ro, e in r.roles],
        "roles_macro": [((v, macro(ro), classe_r(e)), v) for v, ro, e in r.roles],
        "relations": [((classe_r(a), rel, classe_r(b)), i) for a, rel, b, i in r.relations],
    }
    G = {
        "entites": [((inv_e.get(j, ("hors", j)), y[0]), j) for j, y in g.entites.items() if y[0]],
        "evenements": [((inv_v.get(j, ("hors", j)), y[0]), j) for j, y in g.evenements.items()],
        "noms": [((classe_g(e), v), a) for e, v, a in g.noms],
        "proprietes": [((classe_g(e), v), a) for e, v, a in g.proprietes],
        "nombres": [((classe_g(e), v), a) for e, v, a in g.nombres],
        "roles": [((ev_g(v), ro, classe_g(e)), v) for v, ro, e in g.roles],
        "roles_macro": [((ev_g(v), macro(ro), classe_g(e)), v) for v, ro, e in g.roles],
        "relations": [((classe_g(a), rel, classe_g(b)), i) for a, rel, b, i in g.relations],
    }
    correspondance = {}            # id d'assertion du graphe -> id de référence
    for cat in STRUCTURELLES:
        rs = {k for k, _ in R[cat]}
        ps = {k for k, _ in G[cat]}
        res.comptes.ajouter("structure:" + cat, len(rs & ps), len(rs), len(ps))
        rq = {(k, r.q(a)) for k, a in R[cat]}
        pq = {(k, g.q(a)) for k, a in G[cat]}
        res.comptes.ajouter("qualifiee:" + cat, len(rq & pq), len(rq), len(pq))
        if detail:
            res.detail[cat] = {"manquants": sorted(map(str, rs - ps)), "en_trop": sorted(map(str, ps - rs))}
        if cat in ("noms", "proprietes", "relations", "nombres"):
            par_cle = collections.defaultdict(list)
            for k, a in R[cat]:
                par_cle[k].append(a)
            for k, a in G[cat]:
                if k in par_cle:
                    correspondance.setdefault(a, par_cle[k][0])
    correspondance.update(inv_e)
    correspondance.update(inv_v)

    def paires(classes_, nom):
        par = collections.defaultdict(set)
        for e, k in classes_.items():
            par[k].add(nom(e))
        return {tuple(sorted(map(str, (a, b)))) for m in par.values() for a in m for b in m if str(a) < str(b)}
    rc = paires(r.classes(), lambda e: e)
    pc = paires({j: k for j, k in g.classes().items() if j in inv_e}, lambda j: inv_e[j])
    res.comptes.ajouter("structure:coref", len(rc & pc), len(rc), len(pc))
    rd = {tuple(sorted(map(str, (classe_r(a), classe_r(b))))) for a, b in r.distinct}
    pd = {tuple(sorted(map(str, (classe_g(a), classe_g(b))))) for a, b in g.distinct}
    res.comptes.ajouter("structure:distinct", len(rd & pd), len(rd), len(pd))
    # les qualificatifs, assertion par assertion, sous la correspondance
    ids_r = set(r.qualif) | r.alternatives
    ids_g = set(g.qualif) | g.alternatives
    for cat, val, defaut in (("negations", 0, "pos"), ("modalites", 1, "affirme"), ("portees", 2, "represente"),
                             ("citations", 3, "auteur"), ("alternatives", 4, False)):
        refs = {(i, r.q(i)[val]) for i in ids_r if r.q(i)[val] != defaut}
        preds = {(correspondance.get(i, ("hors", i)), g.q(i)[val]) for i in ids_g if g.q(i)[val] != defaut}
        res.comptes.ajouter("qualificatif:" + cat, len(refs & preds), len(refs), len(preds))
    # la sûreté
    inv_corr = collections.defaultdict(list)
    for gi, ri in correspondance.items():
        inv_corr[ri].append(gi)
    for ri in ids_r:
        if r.admissible(ri):
            res.securite["reference_admissible_total"] += 1      # avec ou sans correspondante : la couverture
        if ri not in inv_corr:
            continue
        qr = r.q(ri)
        adm_g = any(g.admissible(gi) for gi in inv_corr[ri])
        if qr != ADMISSIBLE:
            res.securite["reference_non_admissible"] += 1
            if adm_g:
                res.securite["promotion"] += 1
                motifs = []
                for motif, val in (("neg", 0), ("modalite", 1), ("portee", 2), ("cite", 3), ("alternative", 4)):
                    if qr[val] != ADMISSIBLE[val]:
                        res.securite["promotion_" + motif] += 1
                        motifs.append(f"{motif}={qr[val]}")
                quoi = (r.entites.get(ri) or r.evenements.get(ri) or ("assertion",))[0]
                res.promotions.append({"assertion": ri, "tete": quoi, "motifs": motifs})
        else:
            res.securite["reference_admissible"] += 1
            if not adm_g:
                res.securite["retrogradation"] += 1
            else:
                res.securite["admissible_garde"] += 1
    # la précision des assertions admissibles du graphe : toutes, y compris celles qui n'ont aucune correspondante dans
    # la référence (une prémisse admissible que la référence n'a pas est une prémisse fausse)
    for gi in assertions(g):
        if g.admissible(gi):
            res.securite["graphe_admissible_total"] += 1
            ri = correspondance.get(gi)
            if ri is not None and not isinstance(ri, tuple) and r.admissible(ri):
                res.securite["graphe_admissible_juste"] += 1
            elif ri is None or isinstance(ri, tuple):
                res.securite["graphe_admissible_sans_correspondante"] += 1
    # la matrice de confusion des rôles
    ref_pairs = collections.defaultdict(set)
    for v, ro, e in r.roles:
        ref_pairs[(v, classe_r(e))].add(ro)
    pred_pairs = collections.defaultdict(set)
    for v, ro, e in g.roles:
        pred_pairs[(ev_g(v), classe_g(e))].add(ro)
    for k in set(ref_pairs) | set(pred_pairs):
        a, b = ref_pairs.get(k, set()), pred_pairs.get(k, set())
        for ro in a & b:
            res.confusion[(ro, ro)] += 1
        for x, y in itertools.zip_longest(sorted(a - b), sorted(b - a), fillvalue="aucun"):
            res.confusion[(x, y)] += 1
    return res


# --- Les dérivations -----------------------------------------------------------------------------------------------

def requises(der, toutes, faits_lus):
    """La dérivation et celles dont elle dépend (ses sources absentes du graphe lu), de proche en proche."""
    par_fait = {}
    for d in toutes:
        par_fait.setdefault(json.dumps(d["fait"]), d)
    lus = {json.dumps(f) for f in faits_lus}
    chaine, file, vus = [der], list(der["sources"]), set()
    while file:
        s = json.dumps(file.pop())
        if s in lus or s in vus:
            continue
        vus.add(s)
        if s in par_fait:
            chaine.append(par_fait[s])
            file.extend(par_fait[s]["sources"])
    return chaine


def qualificatifs_de(ident, toutes):
    return [d["fait"] for d in toutes if d["fait"][0] in QUALIF_DEFAUT and d["fait"][1] == ident]


def canoniser(chaine):
    """Les faits canonisés d'une chaîne de dérivations ; et si sa forme est non conforme au guide. E1 : l'entité
    nv_V_N (le nom d'action de l'événement V) est V lui-même ; sa relation of / de vers Y est le rôle (patient ou
    thème) de Y dans V que donne sa source."""
    faits, non_conforme = [], False
    for d in chaine:
        f = d["fait"]
        if d["regle"] == "e1":
            non_conforme = True
            if f[0] == "relation":
                faits += [s for s in d["sources"] if s[0] == "role"]
            continue
        faits.append(f)
    return faits, non_conforme


# la source qu'une règle réécrit, par construction, dans une forme que le guide n'a pas : elle n'est jugée que sur ce que
# la règle garde (R1, R2 : l'événement et le participant, non l'étiquette ; P1 : le porteur de la propriété participe ;
# E2 : la mention du nom d'action, qui doit être dans la référence comme entité ou comme événement, et le complément
# de sa relation « of » / « de »)
REECRIT = {"r1": {"role"}, "r2": {"role"}, "p1": {"propriete"}, "e2": {"entite", "relation"}}


def raisons_sources(chaine, faits_lus, r: Graphe, g: Graphe, methode, referents):
    """Les raisons pour lesquelles des sources lues (non dérivées) de la chaîne sont fausses au regard de la référence ;
    [] si toutes sont justes. Chaque source est comparée entièrement : son mot, ses référents, son étiquette, ses
    qualificatifs."""
    lus = {json.dumps(f) for f in faits_lus}
    srcs = [(d["regle"], s) for d in chaine for s in d["sources"] if json.dumps(s) in lus]
    inv_e = {j: i for i, j in aligner(r.entites, g.entites, methode).items()}
    inv_v = {j: i for i, j in aligner(r.evenements, g.evenements, methode).items()}
    cr = r.classes() if referents == "classes" else {e: e for e in r.entites}
    roles_ref = collections.defaultdict(set)
    for v, ro, e in r.roles:
        roles_ref[(v, cr.get(e))].add(ro)
    rels_ref = {(cr.get(a), rel, cr.get(b)): i for a, rel, b, i in r.relations}
    props_ref = {(cr.get(e), v): i for e, v, i in r.proprietes}
    raisons = []

    def qualifies(id_g, id_r):
        if g.q(id_g) != r.q(id_r):
            raisons.append("qualificatifs")
    for regle, s in srcs:
        t = s[0]
        reecrit = t in REECRIT.get(regle, ())
        if reecrit and t == "entite":
            pos = g.entites.get(s[1], ("", None))[1]
            if not pos or not any(x[1] and (dans(pos, x[1]) or chevauche(pos, x[1]))
                                  for x in list(r.entites.values()) + list(r.evenements.values())):
                raisons.append("mention")
            continue
        if reecrit and t in ("relation", "propriete"):
            porteur = s[4] if t == "relation" else s[2]
            if porteur not in inv_e:
                raisons.append("mention")
            continue
        if t == "entite" and s[2] != "nom_propre":
            if s[1] not in inv_e:
                raisons.append("mention")
            elif r.entites[inv_e[s[1]]][0] != norm(s[2]):
                raisons.append("tete")
            else:
                qualifies(s[1], inv_e[s[1]])
        elif t == "evenement":
            if s[1] not in inv_v:
                raisons.append("mention")
            elif r.evenements[inv_v[s[1]]][0] != norm_pred(s[2]):
                raisons.append("predicat")
            else:
                qualifies(s[1], inv_v[s[1]])
        elif t == "role":
            if s[1] not in inv_v or s[3] not in inv_e:
                raisons.append("mention")
                continue
            ref = roles_ref.get((inv_v[s[1]], cr.get(inv_e[s[3]])))
            if not ref:
                raisons.append("role")
            elif s[2] not in ref and not reecrit:
                raisons.append("etiquette_role")
            else:
                qualifies(s[1], inv_v[s[1]])
        elif t == "relation":
            if s[2] not in inv_e or s[4] not in inv_e:
                raisons.append("mention")
                continue
            k = (cr.get(inv_e[s[2]]), norm(s[3]), cr.get(inv_e[s[4]]))
            if k not in rels_ref:
                raisons.append("relation")
            else:
                qualifies(s[1], rels_ref[k])
        elif t == "propriete":
            if s[2] not in inv_e:
                raisons.append("mention")
                continue
            k = (cr.get(inv_e[s[2]]), norm(s[3]))
            if k not in props_ref:
                raisons.append("propriete")
            else:
                qualifies(s[1], props_ref[k])
    return raisons


def sources_justes(chaine, faits_lus, r: Graphe, g: Graphe, methode, referents):
    """Les sources lues (non dérivées) de la chaîne sont-elles toutes justes, entièrement, au regard de la référence ?"""
    return not raisons_sources(chaine, faits_lus, r, g, methode, referents)


def juger_derivations(rlu, gref: Graphe, glu: Graphe, methode, referents):
    """{règle: Counter(catégorie)} pour les dérivations d'un texte."""
    toutes = rlu.get("derivations", [])
    faits = rlu["faits"]
    out = collections.defaultdict(collections.Counter)
    tb = comparer(gref, glu, methode, referents).comptes.table()
    passages = {f[1]: (f[2], f[3]) for f in faits if f[0] == "passage"}
    lus = {json.dumps(f) for f in faits}
    cats = ("structure:roles", "structure:relations", "structure:evenements", "structure:entites",
            "structure:proprietes")
    for d in toutes:
        if d["fait"][0] not in ("entite", "evenement", "role", "relation", "propriete", "coref"):
            continue                                  # un qualificatif dérivé suit son assertion
        chaine = requises(d, toutes, faits)
        canon, non_conforme = canoniser(chaine)
        n = out[d["regle"]]
        if non_conforme:
            n["non_conforme"] += 1
        nouveaux = [f for f in canon if json.dumps(f) not in lus]
        if not nouveaux:
            if non_conforme:
                n["non_evaluee"] += 1
                raisons = raisons_sources(chaine, faits, gref, glu, methode, referents)
                n["non_evaluee_sources_justes" if not raisons else "non_evaluee_sources_fausses"] += 1
                for x in sorted(set(raisons)):
                    n["sources_fausses:" + x] += 1
            else:
                n["redondante"] += 1
            continue
        h = glu.copie()
        for f in nouveaux:
            ajouter(h, f, passages)
            for qf in qualificatifs_de(f[1], toutes):
                ajouter(h, qf)
        ids = {f[1] for f in nouveaux if f[0] in ("entite", "evenement")}
        t2 = comparer(gref, h, methode, referents, derivees=ids).comptes.table()
        vp = max(0, sum(t2[c]["vp"] - tb[c]["vp"] for c in cats))
        fp = max(0, sum(t2[c]["pred"] - tb[c]["pred"] for c in cats) - vp)
        n["elements_justes"] += vp
        n["elements_faux"] += fp
        if fp == 0 and (vp > 0 or not non_conforme):
            n["gain" if vp > 0 else "redondante"] += 1
            continue
        if fp == 0:                                   # E1 qui n'ajoute rien de comparable : non évaluée
            raisons = raisons_sources(chaine, faits, gref, glu, methode, referents)
            n["non_evaluee"] += 1
            n["non_evaluee_sources_justes" if not raisons else "non_evaluee_sources_fausses"] += 1
            for x in sorted(set(raisons)):
                n["sources_fausses:" + x] += 1
            continue
        raisons = raisons_sources(chaine, faits, gref, glu, methode, referents)
        origine = "heritee" if raisons else "regle"
        n[("gain_et_erreur_" if vp > 0 else "erreur_") + origine] += 1
        for x in sorted(set(raisons)):
            n["sources_fausses:" + x] += 1
    return out


# --- Le programme ------------------------------------------------------------------------------------------------------

def charger(p):
    return json.loads(Path(p).read_text(encoding="utf-8"))


def cle(x):
    return (x["k"], x["genre"])


def f2(x):
    return "—" if x is None else f"{x:.2f}"


def prf(s):
    return f"{f2(s['precision'])} / {f2(s['rappel'])} / {f2(s['f1'])}"


def imprimer(titre, res: Resultat):
    print(f"\n### {titre}\n")
    t = res.comptes.table()
    print("| catégorie | référence | graphe | structure : P / R / F1 | qualifiée : P / R / F1 |")
    print("|---|---|---|---|---|")
    for cat in STRUCTURELLES:
        s, q = t.get("structure:" + cat), t.get("qualifiee:" + cat)
        if s:
            print(f"| {cat} | {s['ref']} | {s['pred']} | {prf(s)} | {prf(q)} |")
    for cat in ("coref", "distinct"):
        s = t.get("structure:" + cat)
        if s:
            print(f"| {cat} | {s['ref']} | {s['pred']} | {prf(s)} | — |")
    for cat in QUALIFICATIFS:
        s = t.get("qualificatif:" + cat)
        if s:
            print(f"| {cat} | {s['ref']} | {s['pred']} | {prf(s)} | — |")
    S = res.securite
    n = S["reference_non_admissible"]
    if n:
        print(f"\nSûreté : {n} assertions de référence non admissibles ont une correspondante ; le graphe en rend "
              f"admissibles {S['promotion']} ({S['promotion'] / n:.0%}) : niées {S['promotion_neg']}, modalisées "
              f"{S['promotion_modalite']}, d'une autre portée {S['promotion_portee']}, citées {S['promotion_cite']}, "
              f"en alternative {S['promotion_alternative']}. Rétrogradées : {S['retrogradation']} sur "
              f"{S['reference_admissible']} admissibles.")
    m = metriques_surete(S)
    if m["couverture_admissible"] is not None:
        print(f"Couverture : {S['admissible_garde']} des {S['reference_admissible_total']} assertions admissibles de la "
              f"référence ont une correspondante admissible ({m['couverture_admissible']:.0%}) ; taux de promotion "
              f"{m['taux_promotion']:.0%}. Les deux se lisent ensemble : ne rien rendre admissible n'a aucune "
              f"promotion et aucune couverture.")
    if m["precision_admissible"] is not None:
        print(f"Précision : {S['graphe_admissible_juste']} des {S['graphe_admissible_total']} assertions admissibles du "
              f"graphe ont une correspondante admissible ({m['precision_admissible']:.0%}) ; "
              f"{S['graphe_admissible_sans_correspondante']} n'ont aucune correspondante.")


def metriques_surete(S):
    """Le taux de promotion (parmi les assertions non admissibles de la référence qui ont une correspondante), la
    couverture des assertions admissibles (parmi toutes celles de la référence, avec ou sans correspondante : la part
    qui a une correspondante admissible), et la précision des assertions admissibles du graphe (parmi toutes celles du
    graphe, avec ou sans correspondante : la part dont la correspondante de référence existe et est admissible)."""
    n, t, a = S["reference_non_admissible"], S["reference_admissible_total"], S["graphe_admissible_total"]
    return {"taux_promotion": S["promotion"] / n if n else None,
            "couverture_admissible": S["admissible_garde"] / t if t else None,
            "precision_admissible": S["graphe_admissible_juste"] / a if a else None}


def intervalles(par_texte, tirages=1000, graine=20261127, niveau=0.95):
    """Les intervalles de rééchantillonnage, par fiche : les textes d'une même fiche (positif, négatif, indéterminé,
    variantes) ne sont pas indépendants ; on tire des fiches avec remise, chacune avec tous ses textes. Pour chaque
    catégorie, le F1 structure et qualifié ; pour la sûreté, le taux de promotion et la couverture admissible.
    {mesure: [borne basse, borne haute]} (percentiles)."""
    par_fiche = par_fiches(par_texte)
    fiches = sorted(par_fiche)
    valeurs = collections.defaultdict(list)
    for tirage in tirer(fiches, tirages, graine):
        for nom, v in mesures(fusionner(par_fiche, tirage)).items():
            valeurs[nom].append(v)
    return {"fiches": len(fiches), "tirages": tirages, "graine": graine, "niveau": niveau,
            "intervalles": {nom: bornes(vs, niveau) for nom, vs in valeurs.items()}}


def par_fiches(par_texte):
    par_fiche = collections.defaultdict(Resultat)
    for (k, _), res in par_texte.items():
        par_fiche[k].fusion(res)
    return par_fiche


def tirer(fiches, tirages, graine):
    """Les tirages de fiches avec remise (une liste de fiches par tirage), reproductibles."""
    import random
    alea = random.Random(graine)
    return [[alea.choice(fiches) for _ in fiches] for _ in range(tirages)]


def fusionner(par_fiche, tirage):
    tot = Resultat()
    for k in tirage:
        tot.fusion(par_fiche[k])
    return tot


def mesures(res: Resultat):
    """Les mesures d'un résultat : le F1 de chaque catégorie, et les trois mesures de sûreté."""
    m = {cat: v["f1"] for cat, v in res.comptes.table().items() if v["f1"] is not None}
    m.update({"surete:" + k: v for k, v in metriques_surete(res.securite).items() if v is not None})
    return m


def bornes(vs, niveau=0.95):
    vs = sorted(vs)
    a = (1 - niveau) / 2
    return [vs[int(a * (len(vs) - 1))], vs[int((1 - a) * (len(vs) - 1))]]


def intervalles_apparies(par_texte_a, par_texte_b, tirages=1000, graine=20261127, niveau=0.95):
    """La comparaison appariée de deux lectures B et A du même banc : les mêmes fiches tirées pour les deux, et, pour
    chaque mesure, l'intervalle de la différence B − A ; pour le taux de promotion, aussi celui du rapport B / A. Seules
    les fiches communes aux deux sont tirées."""
    fa, fb = par_fiches(par_texte_a), par_fiches(par_texte_b)
    fiches = sorted(set(fa) & set(fb))
    diff, rapport = collections.defaultdict(list), []
    for tirage in tirer(fiches, tirages, graine):
        ma, mb = mesures(fusionner(fa, tirage)), mesures(fusionner(fb, tirage))
        for nom in set(ma) & set(mb):
            diff[nom].append(mb[nom] - ma[nom])
        pa, pb = ma.get("surete:taux_promotion"), mb.get("surete:taux_promotion")
        if pa and pb is not None:
            rapport.append(pb / pa)
    tot_a, tot_b = fusionner(fa, fiches), fusionner(fb, fiches)
    return {"fiches": len(fiches), "tirages": tirages, "graine": graine, "niveau": niveau,
            "a": mesures(tot_a), "b": mesures(tot_b),
            "difference": {nom: bornes(vs, niveau) for nom, vs in diff.items()},
            "rapport_promotion": bornes(rapport, niveau) if rapport else None}


def jalon(app, rapport_max=0.5, perte_couverture_max=0.05):
    """Le premier jalon de C7, validé le 27/11 : les promotions au moins divisées par deux (borne haute du rapport
    apparié B / A au plus rapport_max) et au plus cinq points de couverture perdus (borne basse de la différence
    appariée B − A au moins −perte_couverture_max)."""
    r = app["rapport_promotion"]
    c = app["difference"].get("surete:couverture_admissible")
    promotions = r is not None and r[1] <= rapport_max
    couverture = c is not None and c[0] >= -perte_couverture_max
    return {"promotions_divisees_par_deux": promotions, "couverture_gardee": couverture,
            "atteint": promotions and couverture, "rapport_promotion": r, "difference_couverture": c}


def imprimer_confusion(res: Resultat):
    lignes = ROLES + ("aucun",)
    print("\nMatrice de confusion des rôles (lignes : référence ; colonnes : graphe) :\n")
    print("| référence \\ graphe | " + " | ".join(lignes) + " |")
    print("|---|" + "---|" * len(lignes))
    for a in lignes:
        print(f"| {a} | " + " | ".join(str(res.confusion.get((a, b), 0)) for b in lignes) + " |")


def evaluer(R, G, accord=False, derivations=False, alignement="optimal", referents="classes", ordre_inverse=False,
            detail=False):
    communs = sorted(set(R) & set(G))
    total, par_langue, details = Resultat(), collections.defaultdict(Resultat), []
    regles = collections.defaultdict(collections.Counter)
    erreurs = 0
    par_texte = {}
    for k in communs:
        r = depuis_reference(R[k], ordre_inverse)
        g = depuis_reference(G[k], ordre_inverse) if accord else depuis_faits(G[k])
        erreurs += g.erreur
        res = comparer(r, g, alignement, referents, detail=detail)
        par_texte[k] = res
        total.fusion(res)
        par_langue[R[k]["langue"]].fusion(res)
        if detail:
            details.append({"k": k[0], "genre": k[1], "texte": R[k]["texte"], "detail": res.detail,
                            "promotions": res.promotions})
        if derivations and not accord and not g.erreur:
            for rg, c in juger_derivations(G[k], r, g, alignement, referents).items():
                regles[rg].update(c)
    return communs, erreurs, total, par_langue, regles, details, par_texte


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("references")
    ap.add_argument("graphes")
    ap.add_argument("--accord", action="store_true")
    ap.add_argument("--derivations", action="store_true")
    ap.add_argument("--alignement", choices=("optimal", "glouton"), default="optimal")
    ap.add_argument("--referents", choices=("classes", "mentions"), default="classes")
    ap.add_argument("--ordre-inverse", action="store_true")
    ap.add_argument("--detail")
    ap.add_argument("--json")
    ap.add_argument("--intervalles", type=int, default=0, metavar="TIRAGES",
                    help="intervalles à 95 %% par rééchantillonnage des fiches (0 : aucun)")
    a = ap.parse_args()
    R = {cle(x): x for x in charger(a.references)}
    G = {cle(x): x for x in charger(a.graphes)}
    communs, erreurs, total, par_langue, regles, details, par_texte = evaluer(
        R, G, a.accord, a.derivations, a.alignement, a.referents, a.ordre_inverse, bool(a.detail))
    if not communs:
        sys.exit("aucun texte commun")
    print(f"{len(communs)} textes comparés ({len(R)} références, {len(G)} graphes) ; graphes en erreur : {erreurs} ;"
          f" alignement {a.alignement}, référents {a.referents}{', ordre inverse' if a.ordre_inverse else ''}")
    imprimer("ensemble", total)
    imprimer_confusion(total)
    for l, res in sorted(par_langue.items()):
        imprimer(f"langue {l}", res)
    if regles:
        print("\n### Dérivations, canonisées, avec leurs dépendances\n")
        cats = ("non_conforme", "non_evaluee", "redondante", "gain", "gain_et_erreur_regle", "gain_et_erreur_heritee",
                "erreur_regle", "erreur_heritee", "elements_justes", "elements_faux")
        exclusives = cats[1:8]
        print("| règle | jugées | " + " | ".join(cats) + " |\n|---|---|" + "---|" * len(cats))
        for rg, n in sorted(regles.items()):
            tot = sum(n[c] for c in exclusives)
            print(f"| {rg} | {tot} | " + " | ".join(str(n[c]) for c in cats) + " |")
        print("\nSources fausses, par raison : " + "; ".join(
            f"{rg} " + ", ".join(f"{k.split(':')[1]} {v}" for k, v in sorted(n.items()) if k.startswith("sources_fausses:"))
            for rg, n in sorted(regles.items())))
    sortie = {"textes": len(communs), "alignement": a.alignement, "referents": a.referents,
              "ordre_inverse": a.ordre_inverse, "total": total.comptes.table(), "securite": dict(total.securite),
              "confusion": {f"{x}>{y}": n for (x, y), n in total.confusion.items()},
              "par_langue": {l: {"comptes": v.comptes.table(), "securite": dict(v.securite)}
                             for l, v in par_langue.items()},
              "regles": {k: dict(v) for k, v in regles.items()},
              "surete": metriques_surete(total.securite)}
    if a.intervalles:
        iv = intervalles(par_texte, a.intervalles)
        sortie["intervalles"] = iv
        print(f"\nIntervalles à 95 % (rééchantillonnage de {iv['fiches']} fiches, {iv['tirages']} tirages) :")
        for nom in ("structure:roles", "qualifiee:roles", "structure:relations", "qualifiee:relations",
                    "surete:taux_promotion", "surete:couverture_admissible"):
            if nom in iv["intervalles"]:
                b, h = iv["intervalles"][nom]
                print(f"  {nom} : [{b:.3f} ; {h:.3f}]")
    if a.json:
        Path(a.json).write_text(json.dumps(sortie, ensure_ascii=False, indent=1), encoding="utf-8")
    if a.detail:
        sortie["textes_detail"] = details
        Path(a.detail).write_text(json.dumps(sortie, ensure_ascii=False, indent=1), encoding="utf-8")


if __name__ == "__main__":
    main()
