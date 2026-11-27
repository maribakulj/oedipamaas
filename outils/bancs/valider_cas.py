"""Le contrôle des cas des bancs de la phase 1 (docs/BANCS_PHASE1.md, § 4).

    python3 outils/bancs/valider_cas.py bancs/phase1/inventaire.json bancs/phase1/repartition.json COTE CAS.json...
        [--wordnet DICT]   (le répertoire dict de WordNet 3.0, pour vérifier la famille lexicale du pivot)

COTE : developpement ou qualification. Chaque fichier contient une liste de cas de base. Le contrôle :
  - la forme de chaque cas et de chaque variante ;
  - chaque (famille, phénomène, construction) existe dans l'inventaire ;
  - le côté : en développement, toutes les constructions et la famille lexicale du pivot sont de développement ; en
    qualification, au moins l'une d'elles est de qualification ;
  - le pivot est un SENS (une clé de sens de WordNet 3.0) ; son fichier lexicographique est la famille lexicale
    déclarée (si --wordnet) ;
  - les quotas de composition, par famille principale : au moins 40 % des cas à deux phénomènes ou plus dont un d'une
    autre famille, au moins 10 % à trois ou plus ;
  - les identifiants uniques.
Il ne juge pas le statut attendu : c'est l'affaire de la relecture (D23). Sortie : un rapport, et un code d'erreur s'il
y a une erreur de forme ou de côté (les quotas sont rapportés, et comptés comme erreurs avec --quotas)."""
import argparse, collections, json, os, sys

STATUTS = {"etablie", "etablie_sous_hypotheses", "contradictoire", "non_certifiee", "ecartee", "inconnue"}
HYPOTHESES = {"sens", "equivalence_non_attestee", "condition_suffisante_non_attestee", "consequence_conditionnelle",
              "connaissance_typique", "hypothese_interpretative", "abduction", "identite", "relation_inconnue"}
SORTES = {"positif", "negatif", "indetermine", "contre_modele"}
VARIATIONS = {"paraphrase", "traduction", "changement_de_participant", "inversion_des_roles", "changement_de_portee",
              "changement_de_modalite", "changement_de_temps", "ajout_figure_non_liee", "ajout_negation_non_liee",
              "composition"}
OPERATIONS = {"lecture", "canonisation", "deduction", "classification", "abduction", "aucune"}
CHAMPS = {"id", "famille", "phenomenes", "pivot", "langue", "sorte", "description", "definition", "statut_attendu",
          "hypotheses_attendues", "connaissances_supposees", "operations_requises", "extensions_requises",
          "justification", "variantes"}
FACULTATIFS = {"graphe_attendu", "requete_attendue", "remarque", "decision_ouverte"}
CONNAISSANCES = {"equivalence_etablie", "condition_suffisante", "condition_necessaire", "implication",
                 "consequence_conditionnelle", "connaissance_typique", "hypothese_interpretative", "relation_inconnue",
                 "distinction_documentaire", "identite_documentaire"}
EXTENSIONS = {"aucune", "etat_reifie", "situation_referent", "plusieurs_situations", "ancrage_temporel",
              "evenement_participant", "contexte_d_eventualite", "contexte_emboite", "referent_conceptuel",
              "negation_dans_la_requete", "modificateur_non_intersectif", "quantification_enoncee", "collection",
              "identite_entre_situations", "relation_entre_eventualites", "base_de_definitions", "abduction",
              "contenu_d_inscription"}


def lexfiles(dico):
    """clé de sens de WordNet 3.0 -> fichier lexicographique, d'après index.sense et lexnames."""
    noms = {}
    for l in open(os.path.join(dico, "lexnames")):
        n, nom, _ = l.split()
        noms[int(n)] = nom
    r = {}
    for l in open(os.path.join(dico, "index.sense")):
        cle = l.split()[0]
        r[cle] = noms[int(cle.split("%")[1].split(":")[1])]
    return r


def controler(cas, inv, rep, cote, lex=None):
    erreurs, ids = [], set()
    autre = "qualification" if cote == "developpement" else "developpement"

    def err(c, m):
        erreurs.append(f"{c.get('id', '?')} : {m}")

    def un(c, v, ou):
        for k in ("sorte", "statut_attendu", "hypotheses_attendues", "description"):
            if k not in v:
                err(c, f"{ou} : champ {k} manquant")
        if v.get("statut_attendu") not in STATUTS:
            err(c, f"{ou} : statut {v.get('statut_attendu')!r}")
        if v.get("sorte") not in SORTES:
            err(c, f"{ou} : sorte {v.get('sorte')!r}")
        for h in v.get("hypotheses_attendues", []):
            if h not in HYPOTHESES:
                err(c, f"{ou} : hypothèse {h!r}")
        if (v.get("statut_attendu") == "etablie_sous_hypotheses") != bool(v.get("hypotheses_attendues")):
            err(c, f"{ou} : des hypothèses attendues si et seulement si etablie_sous_hypotheses")

    for c in cas:
        manque, trop = CHAMPS - set(c), set(c) - CHAMPS - FACULTATIFS
        if manque or trop:
            err(c, f"champs manquants {sorted(manque)}, inconnus {sorted(trop)}")
            continue
        if c["id"] in ids:
            err(c, "identifiant répété")
        ids.add(c["id"])
        if c["famille"] not in inv["familles"]:
            err(c, f"famille {c['famille']!r}")
            continue
        if not c["phenomenes"] or c["phenomenes"][0]["famille"] != c["famille"]:
            err(c, "le premier phénomène est celui de la famille du cas")
        cotes = []
        for p in c["phenomenes"]:
            f, ph, co = p.get("famille"), p.get("phenomene"), p.get("construction")
            if co not in inv["familles"].get(f, {}).get("phenomenes", {}).get(ph, []):
                err(c, f"construction inconnue {f}/{ph}/{co}")
                continue
            cotes.append("q" if co in rep["constructions"][f][ph]["qualification"] else "d")
        pv = c["pivot"]
        lf = pv.get("famille_lexicale")
        if lf in rep["familles_lexicales"]["qualification"]:
            cotes.append("q")
        elif lf in rep["familles_lexicales"]["developpement"]:
            cotes.append("d")
        else:
            err(c, f"famille lexicale {lf!r}")
        cle = pv.get("cle_de_sens", "")
        if not cle.lower().startswith(pv.get("lemme", "?").replace(" ", "_").lower() + "%"):
            err(c, f"la clé de sens {cle!r} n'est pas une clé du lemme {pv.get('lemme')!r}")
        elif lex is not None and lex.get(cle.lower()) != lf:
            err(c, f"la clé de sens {cle!r} est dans {lex.get(cle.lower())}, non dans {lf}")
        if cote == "developpement" and "q" in cotes:
            err(c, "une construction ou la famille lexicale est de qualification")
        if cote == "qualification" and "q" not in cotes:
            err(c, "aucune construction ni famille lexicale de qualification")
        if c["langue"] not in ("fr", "en"):
            err(c, f"langue {c['langue']!r}")
        for o in c["operations_requises"]:
            if o not in OPERATIONS:
                err(c, f"opération {o!r}")
        for x in c["extensions_requises"]:
            if x not in EXTENSIONS:
                err(c, f"extension {x!r}")
        for k in c["connaissances_supposees"]:
            if not isinstance(k, dict) or k.get("sorte") not in CONNAISSANCES or "contenu" not in k \
                    or not isinstance(k.get("attestee"), bool):
                err(c, f"connaissance supposée mal formée {k!r}")
            elif k["attestee"] and not str(k.get("source", "")).strip():
                err(c, f"connaissance attestée sans source (§ 4.1) : {k['contenu'][:60]!r}")
        d = c.get("decision_ouverte")
        if d is not None and (not isinstance(d, dict) or "question" not in d
                              or not all(x in STATUTS for x in d.get("statut_selon_l_option", {}).values())):
            err(c, f"decision_ouverte mal formée {d!r}")
        un(c, c, "cas")
        for i, v in enumerate(c["variantes"]):
            if v.get("variation") not in VARIATIONS:
                err(c, f"variante {i} : variation {v.get('variation')!r}")
            for x in v.get("extensions_requises", []):
                if x not in EXTENSIONS:
                    err(c, f"variante {i} : extension {x!r}")
            un(c, v, f"variante {i}")
    return erreurs


def quotas(cas):
    r = {}
    par = collections.defaultdict(list)
    for c in cas:
        par[c["famille"]].append(c)
    for f, cs in sorted(par.items()):
        deux = sum(1 for c in cs if len(c["phenomenes"]) >= 2 and any(p["famille"] != f for p in c["phenomenes"]))
        trois = sum(1 for c in cs if len(c["phenomenes"]) >= 3)
        r[f] = {"cas": len(cs), "composes_2": deux, "composes_3": trois,
                "ok": deux >= 0.4 * len(cs) and trois >= 0.1 * len(cs)}
    return r


def couverture(cas, inv):
    vus = collections.Counter((p["famille"], p["phenomene"], p["construction"]) for c in cas for p in c["phenomenes"])
    matrice = collections.Counter(tuple(sorted({c["famille"], p["famille"]})) for c in cas for p in c["phenomenes"][1:]
                                  if p["famille"] != c["famille"])
    return vus, matrice


def main():
    a = argparse.ArgumentParser()
    a.add_argument("inventaire"); a.add_argument("repartition")
    a.add_argument("cote", choices=["developpement", "qualification"]); a.add_argument("cas", nargs="+")
    a.add_argument("--wordnet"); a.add_argument("--quotas", action="store_true")
    o = a.parse_args()
    inv, rep = json.load(open(o.inventaire)), json.load(open(o.repartition))
    cas = [c for f in o.cas for c in json.load(open(f))]
    lex = lexfiles(o.wordnet) if o.wordnet else None
    es = controler(cas, inv, rep, o.cote, lex)
    q = quotas([c for c in cas if isinstance(c, dict) and "phenomenes" in c and "famille" in c])
    for e in es:
        print("ERREUR", e)
    nv = sum(len(c.get("variantes", [])) for c in cas)
    print(f"{len(cas)} cas de base, {nv} variantes, {len(es)} erreurs")
    for f, x in q.items():
        print(f"  {f} : {x['cas']} cas, composés ≥2 : {x['composes_2']}, ≥3 : {x['composes_3']}"
              f"{'' if x['ok'] else '  (quotas non atteints)'}")
    sys.exit(1 if es or (o.quotas and not all(x["ok"] for x in q.values())) else 0)


if __name__ == "__main__":
    main()
