"""Tirage et dépouillement de l'échantillon d'alignements jugés.

Usage :
  python3 -I outils/ressources/echantillon.py tirer      -> fiche à juger
  python3 -I outils/ressources/echantillon.py depouiller -> précision, erreurs corrélées

Tirage (graine 20261128) parmi les types du corpus Joconde ayant au moins une
proposition WordNet dans l'une des ressources : 46 lemmes, stratifiés par
catégorie (NOUN 20, VERB 10, ADJ 8, ADV 4, PROPN 4) et par tranche de fréquence
(>= 20, 5-19, 2-4 occurrences ; répartition aussi égale que possible).
Pour chaque lemme, on juge l'union des couples (lemme, synset) proposés par
WOLF, WoNeF P/F/C, DBnary filtré et AAT pivot ; si l'union dépasse 40 couples,
on en tire 40 (poids = taille/40). Les couples proposés seulement par DBnary
brut sont tirés à part : au plus 8 par lemme (poids = taille/8).
Cotes (jugement d'agent, un seul annotateur, pas une validation) :
  O correct ; ~ douteux ou marginal ; X parasite.
Les jugements sont saisis dans outils/ressources/jugements/alignements.tsv.
"""
import json
import os
import random
import sys
from collections import Counter, defaultdict
from itertools import combinations

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from commun import SORTIE, Index, WordNet  # noqa: E402

GRAINE = 20261128
ICI = os.path.dirname(os.path.abspath(__file__))
JUG = os.path.join(ICI, "jugements", "alignements.tsv")
FICHE = os.path.join(SORTIE, "fiche_alignements.tsv")
JUGEES = ["wolf", "wonef_p", "wonef_f", "wonef_c", "dbnary_filtre", "aat_pivot"]
TOUTES = JUGEES + ["dbnary_brut"]
QUOTAS = {"NOUN": 20, "VERB": 10, "ADJ": 8, "ADV": 4, "PROPN": 4}
PLAF, PLAF_BRUT = 40, 8


def tranche(n):
    return "haute" if n >= 20 else ("moyenne" if n >= 5 else "basse")


def lire_types():
    p = os.path.join(SORTIE, "joconde_types.tsv")
    lignes = open(p, encoding="utf-8").read().splitlines()
    tete = lignes[0].split("\t")
    out = []
    for l in lignes[1:]:
        c = dict(zip(tete, l.split("\t")))
        out.append(c)
    return out


def tirer():
    wn = WordNet()
    idx = {r: Index(r) for r in TOUTES}
    types = [t for t in lire_types() if int(t["occ"]) >= 2 and t["upos"] in QUOTAS]
    rnd = random.Random(GRAINE)
    choisis = []
    for cat, q in QUOTAS.items():
        par_tr = defaultdict(list)
        for t in types:
            if t["upos"] == cat and any(int(t.get(r, "0") or 0) for r in TOUTES):
                par_tr[tranche(int(t["occ"]))].append(t)
        trs = ["haute", "moyenne", "basse"]
        base = [q // 3 + (1 if i < q % 3 else 0) for i in range(3)]
        for tr, n in zip(trs, base):
            pool = sorted(par_tr[tr], key=lambda t: t["lemme"])
            choisis += [(cat, tr, t) for t in rnd.sample(pool, min(n, len(pool)))]
    lignes = []
    plan = []
    for cat, tr, t in choisis:
        lem = t["lemme"]
        prop = {r: idx[r].chercher(lem, cat) for r in TOUTES}
        union = set().union(*[prop[r] for r in JUGEES])
        brut_seul = prop["dbnary_brut"] - union
        u = sorted(union)
        poids_u = 1.0
        if len(u) > PLAF:
            poids_u = len(u) / PLAF
            u = sorted(rnd.sample(u, PLAF))
        b = sorted(brut_seul)
        poids_b = 1.0
        if len(b) > PLAF_BRUT:
            poids_b = len(b) / PLAF_BRUT
            b = sorted(rnd.sample(b, PLAF_BRUT))
        plan.append({"lemme": lem, "upos": cat, "tranche": tr, "occ": int(t["occ"]), "famille": t["famille"],
                     "union": len(union), "brut_seul": len(brut_seul), "poids_union": poids_u, "poids_brut": poids_b,
                     "taille": {r: len(prop[r]) for r in TOUTES}})
        for s, w, strate in [(s, poids_u, "union") for s in u] + [(s, poids_b, "brut_seul") for s in b]:
            lex, mots, glose = wn.info(s) or ("?", [], "")
            flags = ",".join(r for r in TOUTES if s in prop[r])
            lignes.append([lem, cat, s, lex, " ".join(mots[:6]), glose[:220], flags, strate, "%.3f" % w])
    with open(FICHE, "w", encoding="utf-8") as f:
        f.write("lemme\tupos\tsynset\tlexname\tmots_en\tglose\tressources\tstrate\tpoids\n")
        for l in lignes:
            f.write("\t".join(l) + "\n")
    json.dump(plan, open(os.path.join(SORTIE, "plan_echantillon.json"), "w"), indent=1, ensure_ascii=False)
    print(len(choisis), "lemmes,", len(lignes), "couples à juger ->", FICHE, file=sys.stderr)


def depouiller():
    fiche = {}
    for l in open(FICHE, encoding="utf-8").read().splitlines()[1:]:
        c = l.split("\t")
        fiche[(c[0], c[1], c[2])] = c
    jug = {}
    for l in open(JUG, encoding="utf-8"):
        if l.startswith("#") or not l.strip():
            continue
        c = l.rstrip("\n").split("\t")
        jug[(c[0], c[1], c[2])] = c[3]
    manque = [k for k in fiche if k not in jug]
    if manque:
        print("non jugés :", len(manque), manque[:5], file=sys.stderr)
    res = {"couples_juges": len(jug), "par_ressource": {}, "par_categorie": {}, "par_lexname": {}}
    def agr(filtre):
        out = {}
        for r in TOUTES:
            w = Counter()
            n = 0
            for k, c in fiche.items():
                if k not in jug or not filtre(c):
                    continue
                if r in c[6].split(","):
                    w[jug[k]] += float(c[8]); n += 1
            tot = sum(w.values())
            if tot:
                out[r] = {"n_juges": n, "O": round(100 * w["O"] / tot, 1), "~": round(100 * w["~"] / tot, 1),
                          "X": round(100 * w["X"] / tot, 1)}
        return out
    res["par_ressource"] = agr(lambda c: True)
    for cat in QUOTAS:
        res["par_categorie"][cat] = agr(lambda c, cat=cat: c[1] == cat)
    lexs = sorted({c[3] for c in fiche.values()})
    for lx in lexs:
        a = agr(lambda c, lx=lx: c[3] == lx)
        if a:
            res["par_lexname"][lx] = a
    # erreurs corrélées : sur les couples de la strate « union »
    erreurs = defaultdict(set); props = defaultdict(set)
    for k, c in fiche.items():
        if k not in jug:
            continue
        for r in c[6].split(","):
            props[r].add(k)
            if jug[k] == "X":
                erreurs[r].add(k)
    paires = {}
    univers = {k for k, c in fiche.items() if k in jug}
    for a, b in combinations(TOUTES, 2):
        ea, eb = erreurs[a], erreurs[b]
        both = props[a] & props[b]
        # taux d'erreur de b sur les couples aussi proposés par a, vs taux global de b
        tb = len(eb) / len(props[b]) if props[b] else 0
        e_ab = len(ea & eb)
        partage = round(100 * e_ab / len(ea), 1) if ea else None
        paires[a + "|" + b] = {"erreurs_communes": e_ab, "erreurs_a": len(ea), "erreurs_b": len(eb),
                               "pct_erreurs_a_aussi_dans_b": partage,
                               "pct_erreurs_b_aussi_dans_a": round(100 * e_ab / len(eb), 1) if eb else None,
                               "couples_communs": len(both),
                               "taux_X_communs": round(100 * len([k for k in both if jug[k] == "X"]) / len(both), 1) if both else None,
                               "taux_X_b_global": round(100 * tb, 1)}
    res["erreurs_correlees"] = paires
    # Corrélation orientée : B propose-t-il les erreurs de A plus souvent que
    # ses couples corrects ? rapport = P(B | A, X) / P(B | A, O). Un rapport
    # proche de 1 : B ne distingue pas les erreurs de A (son accord ne vaut
    # pas corroboration) ; proche de 0 : B est un bon second avis pour A.
    oriente = {}
    for a in TOUTES:
        for b in TOUTES:
            if a == b:
                continue
            xa = [k for k in props[a] if jug[k] == "X"]
            oa = [k for k in props[a] if jug[k] == "O"]
            if not xa or not oa:
                continue
            px = sum(1 for k in xa if k in props[b]) / len(xa)
            po = sum(1 for k in oa if k in props[b]) / len(oa)
            oriente[a + ">" + b] = {"B_propose_erreurs_A_pct": round(100 * px, 1),
                                   "B_propose_corrects_A_pct": round(100 * po, 1),
                                   "rapport": round(px / po, 2) if po else None}
    res["correlation_orientee"] = oriente
    # erreurs uniques / partagées par profil de ressources
    prof = Counter()
    for k, c in fiche.items():
        if jug.get(k) == "X":
            prof[c[6]] += 1
    res["profils_erreurs"] = prof.most_common(25)
    profO = Counter()
    for k, c in fiche.items():
        if jug.get(k) == "O":
            profO[c[6]] += 1
    res["profils_corrects"] = profO.most_common(25)
    # vote : nombre de ressources indépendantes (familles WOLF / WoNeF / DBnary / AAT) proposant le couple
    fam = {"wolf": "WOLF", "wonef_p": "WoNeF", "wonef_f": "WoNeF", "wonef_c": "WoNeF",
           "dbnary_filtre": "DBnary", "dbnary_brut": "DBnary", "aat_pivot": "AAT"}
    vote = defaultdict(Counter)
    for k, c in fiche.items():
        if k in jug and c[7] == "union":
            nv = len({fam[r] for r in c[6].split(",") if r in fam and r != "dbnary_brut"})
            vote[nv][jug[k]] += float(c[8])
    res["vote"] = {str(n): {"poids": round(sum(v.values()), 1), "O": round(100 * v["O"] / sum(v.values()), 1),
                            "X": round(100 * v["X"] / sum(v.values()), 1)} for n, v in sorted(vote.items())}
    # taux d'erreur par méthode d'alignement (sélecteur WoNeF, règle DBnary)
    from commun import lire_lexique, norm
    meth = {}
    for nom in ("wonef_c", "dbnary_filtre"):
        notes = defaultdict(set)
        for forme, pos, cible, note in lire_lexique(nom):
            for x in note.split(";"):
                x = x.split("(")[0]
                if x and not x.startswith("en="):
                    notes[(norm(forme), cible)].add(x)
        par = defaultdict(Counter)
        for k, c in fiche.items():
            if k in jug and nom in c[6].split(","):
                for x in notes.get((norm(k[0]), k[2]), {"(aucune)"}):
                    par[x][jug[k]] += 1
        meth[nom] = {x: dict(v) for x, v in par.items()}
    res["par_methode"] = meth
    json.dump(res, open(os.path.join(SORTIE, "echantillon_resultats.json"), "w"), indent=1, ensure_ascii=False)
    print(json.dumps(res, indent=1, ensure_ascii=False))


def absents():
    """40 types (4 catégories) absents de WOLF, tirés avec la graine : on juge
    s'il s'agit d'une lacune de ressource (M) ou d'un bruit de la mesure
    (L lemmatisation ou étiquetage, F faute du texte source, E abréviation ou mot étranger)."""
    types = [t for t in lire_types() if t["upos"] in ("NOUN", "VERB", "ADJ", "ADV") and t["wolf"] == "0"]
    types.sort(key=lambda t: (t["lemme"], t["upos"]))
    rnd = random.Random(GRAINE)
    ech = rnd.sample(types, 40)
    pj = os.path.join(ICI, "jugements", "absents_wolf.tsv")
    if not os.path.exists(pj):
        for t in ech:
            print("%s\t%s\t%s" % (t["lemme"], t["upos"], t["occ"]))
        return
    jug = {}
    for l in open(pj, encoding="utf-8"):
        if not l.startswith("#") and l.strip():
            c = l.rstrip("\n").split("\t")
            jug[(c[0], c[1])] = c[2]
    cpt = Counter(jug.get((t["lemme"], t["upos"]), "?") for t in ech)
    print(json.dumps({"n": len(ech), "cotes": dict(cpt)}, ensure_ascii=False))
    json.dump({"n": len(ech), "cotes": dict(cpt)}, open(os.path.join(SORTIE, "absents_resultats.json"), "w"))


if __name__ == "__main__":
    {"tirer": tirer, "depouiller": depouiller, "absents": absents}[sys.argv[1]]()
