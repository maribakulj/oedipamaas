"""Mesures de couverture, gains marginaux sur WOLF, sens par lemme,
expressions polylexicales et familles lexicales (fichiers lexicographiques).

Usage : python3 -I outils/ressources/mesurer.py
Entrées : corpus/*_stanza.jsonl et lexiques/*.tsv (voir corpus.py, lexiques.py).
Sortie : /home/user/donnees/mesure_ressources_lexicales/mesures.json
         et types.tsv / expressions.tsv (détail par type, pour les tirages).
"""
import json
import os
import re
import statistics
import sys
from collections import Counter, defaultdict

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from commun import SORTIE, Index, WordNet, norm, RES_WN, RES_PAT, RES_LEX, UPOS2WN  # noqa: E402

CATS = ["NOUN", "VERB", "ADJ", "ADV", "PROPN"]
CATS4 = ["NOUN", "VERB", "ADJ", "ADV"]
RE_ORD = re.compile(r"^(?:x{0,3}(?:ix|iv|vi{0,3}|i{1,3})|x{1,3})(?:e|er|ème|eme)$")
RE_MOT = re.compile(r"^[^\W\d_][\w'\-]*$")
ADP_EXPR = {"de", "à", "en", "d'", "du", "des", "au", "aux", "sur", "sous"}

RESSOURCES = RES_WN + RES_PAT + RES_LEX
UNIONS = {
    "WOLF+WoNeF_F": ["wolf", "wonef_f"],
    "WOLF+WoNeF_C": ["wolf", "wonef_c"],
    "WOLF+DBnary_filtre": ["wolf", "dbnary_filtre"],
    "WOLF+DBnary_brut": ["wolf", "dbnary_brut"],
    "WOLF+WoNeF_F+DBnary_filtre": ["wolf", "wonef_f", "dbnary_filtre"],
    "WOLF+patrimoniaux": ["wolf"] + RES_PAT,
    "WOLF+WoNeF_F+DBnary_filtre+AAT_pivot": ["wolf", "wonef_f", "dbnary_filtre", "aat_pivot"],
    "patrimoniaux": RES_PAT,
    "toutes_alignees_WN": [r for r in RES_WN if r != "dbnary_brut"],
    "toutes": RESSOURCES,
}


def garder(lemme, upos):
    if upos not in CATS:
        return False
    l = lemme.lower()
    if not RE_MOT.match(lemme) or len(lemme) < 2:
        return False
    if upos != "PROPN" and RE_ORD.match(l) and l not in ("vie", "vive"):
        return False
    return True


def cle_type(lemme, upos):
    return (norm(lemme, garder_casse=True) if upos == "PROPN" else norm(lemme), upos)


def lire_corpus(nom):
    p = os.path.join(SORTIE, "corpus", nom + "_stanza.jsonl")
    docs = [json.loads(l) for l in open(p, encoding="utf-8")]
    return docs


def compter_types(docs):
    occ = Counter()
    for d in docs:
        for ph in d["phrases"]:
            for t, lem, up in ph["mots"]:
                if garder(lem, up):
                    occ[cle_type(lem, up)] += 1
    return occ


def expressions(docs):
    """Candidats polylexicaux par motifs ; renvoie {surface: (freq, variantes)}."""
    cand = Counter()
    var = {}
    for d in docs:
        for ph in d["phrases"]:
            m = [(t, lem, up) for t, lem, up in ph["mots"]]
            n = len(m)
            for i in range(n):
                pats = []
                if i + 1 < n:
                    a, b = m[i], m[i + 1]
                    if (a[2], b[2]) in {("NOUN", "ADJ"), ("ADJ", "NOUN"), ("PROPN", "PROPN"), ("NOUN", "PROPN"), ("ADJ", "PROPN")}:
                        pats.append([a, b])
                if i + 2 < n:
                    a, b, c = m[i], m[i + 1], m[i + 2]
                    if a[2] in ("NOUN", "PROPN") and b[0].lower() in ADP_EXPR and c[2] in ("NOUN", "PROPN"):
                        pats.append([a, b, c])
                if i + 3 < n:
                    a, b, c, e = m[i], m[i + 1], m[i + 2], m[i + 3]
                    if a[2] in ("NOUN", "PROPN") and b[0].lower() in ("de", "à") and c[2] == "DET" and e[2] in ("NOUN", "PROPN"):
                        pats.append([a, b, c, e])
                for p in pats:
                    if not all(RE_MOT.match(x[0]) for x in p):
                        continue
                    surf = " ".join(x[0] for x in p)
                    surf = re.sub(r"(\b[dlDL]') ", r"\1", surf)
                    # « de le » / « à le » (mwt) -> du / au
                    surf = surf.replace(" de le ", " du ").replace(" de les ", " des ").replace(" à le ", " au ").replace(" à les ", " aux ")
                    k = norm(surf)
                    if any(x[2] == "PROPN" for x in p):
                        k = norm(surf, garder_casse=True)
                    cand[k] += 1
                    if k not in var:
                        lemj = " ".join(x[1] for x in p)
                        tete = " ".join([p[0][1]] + [x[0] for x in p[1:]])
                        var[k] = [surf, lemj, tete, surf.replace(" ", "-")]
    return cand, var


def stats_sens(nb):
    if not nb:
        return {}
    vals = [v for v, _ in nb]
    pond = sum(v * w for v, w in nb) / sum(w for _, w in nb)
    return {"moyenne": round(statistics.mean(vals), 2), "mediane": statistics.median(vals),
            "moyenne_ponderee_occ": round(pond, 2), "monosemiques_pct": round(100 * sum(1 for v in vals if v == 1) / len(vals), 1)}


def mesurer_corpus(nom, docs, idx, wn, exclure=()):
    occ = compter_types(docs)
    res = {"types": {}, "occurrences": {}}
    for c in CATS:
        res["types"][c] = sum(1 for k in occ if k[1] == c)
        res["occurrences"][c] = sum(v for k, v in occ.items() if k[1] == c)
    trouve = {}
    for r in RESSOURCES:
        if r in exclure:
            continue
        trouve[r] = {k: idx[r].chercher(k[0], k[1]) for k in occ}
    def couverture(cov):
        out = {}
        for c in CATS + ["4cat"]:
            ks = [k for k in occ if (k[1] == c if c != "4cat" else k[1] in CATS4)]
            nt = len(ks); no = sum(occ[k] for k in ks)
            ct = sum(1 for k in ks if cov(k)); co = sum(occ[k] for k in ks if cov(k))
            out[c] = {"types": ct, "types_pct": round(100 * ct / nt, 1) if nt else None,
                      "occ_pct": round(100 * co / no, 1) if no else None}
        return out
    res["couverture"] = {r: couverture(lambda k, r=r: bool(trouve[r][k])) for r in trouve}
    res["unions"] = {}
    for u, membres in UNIONS.items():
        ms = [m for m in membres if m in trouve]
        res["unions"][u] = couverture(lambda k, ms=ms: any(trouve[m][k] for m in ms))
    # gain marginal sur WOLF
    absent = [k for k in occ if not trouve["wolf"][k]]
    res["absents_wolf"] = {c: {"types": sum(1 for k in absent if k[1] == c),
                               "occ": sum(occ[k] for k in absent if k[1] == c)} for c in CATS}
    gain = {}
    for r in trouve:
        if r == "wolf":
            continue
        g = {}
        for c in CATS + ["4cat"]:
            ks = [k for k in absent if (k[1] == c if c != "4cat" else k[1] in CATS4)]
            rec = [k for k in ks if trouve[r][k]]
            tot_t = sum(1 for k in occ if (k[1] == c if c != "4cat" else k[1] in CATS4))
            tot_o = sum(occ[k] for k in occ if (k[1] == c if c != "4cat" else k[1] in CATS4))
            g[c] = {"types_recuperes": len(rec),
                    "pct_des_absents": round(100 * len(rec) / len(ks), 1) if ks else None,
                    "points_types": round(100 * len(rec) / tot_t, 1) if tot_t else None,
                    "points_occ": round(100 * sum(occ[k] for k in rec) / tot_o, 1) if tot_o else None}
        # nouvelles paires (lemme, synset) sur les lemmes déjà dans WOLF
        if r in RES_WN:
            nv = sum(len(trouve[r][k] - trouve["wolf"][k]) for k in occ if trouve["wolf"][k] and k[1] in CATS4)
            comm = sum(len(trouve[r][k] & trouve["wolf"][k]) for k in occ if k[1] in CATS4)
            tot = sum(len(trouve[r][k]) for k in occ if k[1] in CATS4)
            g["paires"] = {"total": tot, "communes_wolf": comm, "nouvelles_sur_lemmes_wolf": nv}
        gain[r] = g
    res["gain_sur_wolf"] = gain
    # sens par lemme
    res["sens_par_lemme"] = {}
    for r in trouve:
        res["sens_par_lemme"][r] = {c: stats_sens([(len(trouve[r][k]), occ[k]) for k in occ if k[1] == c and trouve[r][k]])
                                     for c in CATS4 + ["4cat"] if c != "4cat"}
        res["sens_par_lemme"][r]["4cat"] = stats_sens([(len(trouve[r][k]), occ[k]) for k in occ if k[1] in CATS4 and trouve[r][k]])
    # sens propres du Wiktionnaire (DBnary) : somme des sens des entrées (lemme, catégorie)
    if "dbnary_lex" in trouve:
        sens_wk = defaultdict(int)
        from commun import lire_lexique
        for forme, pos, cible, note in lire_lexique("dbnary_lex"):
            m = re.search(r"sens=(\d+)", note)
            if m:
                sens_wk[(norm(forme), pos)] += int(m.group(1))
        d = {}
        for c in CATS4:
            d[c] = stats_sens([(sens_wk[(k[0], UPOS2WN[c])], occ[k]) for k in occ if k[1] == c and sens_wk.get((k[0], UPOS2WN[c]))])
        d["4cat"] = stats_sens([(sens_wk[(k[0], UPOS2WN[k[1]])], occ[k]) for k in occ if k[1] in CATS4 and sens_wk.get((k[0], UPOS2WN[k[1]]))])
        res["sens_par_lemme"]["dbnary_sens_wiktionnaire"] = d
    # absents les plus fréquents
    absents_tous = [k for k in occ if k[1] in CATS4 and not any(trouve[r][k] for r in trouve)]
    res["absents_de_tout_top"] = [[k[0], k[1], occ[k]] for k in sorted(absents_tous, key=lambda k: -occ[k])[:60]]
    res["absents_wolf_top"] = {c: [[k[0], occ[k], [r for r in trouve if trouve[r][k]]] for k in sorted([k for k in absent if k[1] == c], key=lambda k: -occ[k])[:40]] for c in CATS}
    # familles lexicales : lexname majoritaire des synsets WOLF ∪ WoNeF_F ∪ DBnary_filtre
    fam = {}
    for k in occ:
        if k[1] not in CATS4:
            continue
        ss = set()
        for r in ("wolf", "wonef_f", "dbnary_filtre"):
            if r in trouve:
                ss |= trouve[r][k]
        cnt = Counter(wn.lexname(s) for s in ss)
        fam[k] = sorted(cnt.items(), key=lambda x: (-x[1], x[0]))[0][0] if cnt else "inconnue"
    familles = defaultdict(dict)
    for f in sorted(set(fam.values())):
        ks = [k for k in fam if fam[k] == f]
        d = {"types": len(ks), "occ": sum(occ[k] for k in ks)}
        for r in list(trouve) + list(UNIONS):
            if r in trouve:
                cov = [k for k in ks if trouve[r][k]]
            else:
                ms = [m for m in UNIONS[r] if m in trouve]
                cov = [k for k in ks if any(trouve[m][k] for m in ms)]
            d[r] = round(100 * len(cov) / len(ks), 1)
        familles[f] = d
    res["familles_types"] = familles
    # paires proposées par lexname (lemmes du corpus)
    pl = defaultdict(Counter)
    for r in RES_WN:
        if r not in trouve:
            continue
        for k in occ:
            if k[1] in CATS4:
                for s in trouve[r][k]:
                    pl[wn.lexname(s)][r] += 1
    res["paires_par_lexname"] = {f: dict(c) for f, c in sorted(pl.items())}
    # expressions polylexicales
    cand, var = expressions(docs)
    seuil = 3 if nom == "joconde" else 2
    retenues = [k for k, v in cand.items() if v >= seuil]
    cov_e = {}
    for r in trouve:
        if r == "dbnary_brut":
            continue
        cov_e[r] = {k for k in retenues if idx[r].chercher_expr(var[k])}
    res["expressions"] = {"seuil_freq": seuil, "candidats": len(retenues),
                          "occ": sum(cand[k] for k in retenues),
                          "couverture_pct": {r: round(100 * len(v) / len(retenues), 1) for r, v in cov_e.items()},
                          "couverture_occ_pct": {r: round(100 * sum(cand[k] for k in v) / sum(cand[k] for k in retenues), 1) for r, v in cov_e.items()}}
    eu = {}
    for u, membres in UNIONS.items():
        ms = [m for m in membres if m in cov_e]
        s = set().union(*[cov_e[m] for m in ms]) if ms else set()
        eu[u] = round(100 * len(s) / len(retenues), 1)
    res["expressions"]["unions_pct"] = eu
    # sous-ensemble jugé à la main (jugement d'agent) : T terminologique ou
    # lexicalisée, N nom propre, C compositionnelle
    pj = os.path.join(os.path.dirname(os.path.abspath(__file__)), "jugements", nom + "_expressions.tsv")
    if os.path.exists(pj):
        tag = {}
        for l in open(pj, encoding="utf-8"):
            if l.startswith("#") or not l.strip():
                continue
            c = l.rstrip("\n").split("\t")
            tag[c[0]] = c[1]
        jug = {}
        for t in ("T", "N", "C"):
            ks = [k for k in tag if tag[k] == t and k in cand]
            if not ks:
                continue
            d = {"n": len(ks), "occ": sum(cand[k] for k in ks)}
            for r in cov_e:
                d[r] = round(100 * sum(1 for k in ks if k in cov_e[r]) / len(ks), 1)
            for u, membres in UNIONS.items():
                ms = [m for m in membres if m in cov_e]
                d[u] = round(100 * sum(1 for k in ks if any(k in cov_e[m] for m in ms)) / len(ks), 1)
            d["absentes_de_tout"] = [k for k in ks if not any(k in cov_e[r] for r in cov_e)][:40]
            jug[t] = d
        res["expressions"]["jugees"] = jug
    # détail pour les tirages
    with open(os.path.join(SORTIE, nom + "_types.tsv"), "w", encoding="utf-8") as f:
        f.write("lemme\tupos\tocc\tfamille\t" + "\t".join(trouve) + "\n")
        for k in sorted(occ, key=lambda k: -occ[k]):
            f.write("%s\t%s\t%d\t%s\t%s\n" % (k[0], k[1], occ[k], fam.get(k, "-"),
                                              "\t".join(str(len(trouve[r][k])) for r in trouve)))
    with open(os.path.join(SORTIE, nom + "_expressions.tsv"), "w", encoding="utf-8") as f:
        f.write("expression\tfreq\t" + "\t".join(cov_e) + "\n")
        for k in sorted(retenues, key=lambda k: -cand[k]):
            f.write("%s\t%d\t%s\n" % (k, cand[k], "\t".join("1" if k in cov_e[r] else "0" for r in cov_e)))
    return res


def taille_ressources(idx, wn):
    out = {}
    for r in RESSOURCES:
        ix = idx[r]
        if ix.wn or ix.lex:
            formes = {f for f, p in ix.par_pos}
            paires = sum(len(v) for v in ix.par_pos.values())
            syn = set().union(*ix.par_pos.values()) if ix.wn else set()
            d = {"formes": len(formes), "paires": paires,
                 "polylexicales": sum(1 for f in formes if " " in f or "-" in f)}
            if ix.wn:
                d["synsets"] = len(syn)
                d["synsets_par_pos"] = dict(Counter(s[-1] for s in syn))
                pp = Counter()
                for (f, p), v in ix.par_pos.items():
                    pp[p] += len(v)
                d["paires_par_pos"] = dict(pp)
            out[r] = d
        else:
            formes = set(ix.sans_pos)
            out[r] = {"formes": len(formes), "concepts": len(set().union(*ix.sans_pos.values())),
                      "polylexicales": sum(1 for f in formes if " " in f)}
    return out


if __name__ == "__main__":
    wn = WordNet()
    idx = {r: Index(r) for r in RESSOURCES}
    print("index chargés", file=sys.stderr)
    resultat = {"tailles": taille_ressources(idx, wn)}
    resultat["joconde"] = mesurer_corpus("joconde", lire_corpus("joconde"), idx, wn)
    # Sur le corpus Iconclass, la ressource Iconclass est circulaire : exclue.
    resultat["iconclass"] = mesurer_corpus("iconclass", lire_corpus("iconclass"), idx, wn, exclure=("iconclass_kw",))
    json.dump(resultat, open(os.path.join(SORTIE, "mesures.json"), "w"), indent=1, ensure_ascii=False)
    print("ok", file=sys.stderr)
