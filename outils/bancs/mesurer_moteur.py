"""La mesure du moteur actuel sur les bancs de développement de la phase 1 : le niveau (c), point de départ
(docs/INTERPRETATIONS_ADMISSIBLES.md, § 2.4 ; docs/BANCS_PHASE1.md, § 7 et § 9.4 ; rapport :
docs/mesures/MESURE_INITIALE_BANCS.md).

    python3 outils/bancs/mesurer_moteur.py [--dev DIR] [--base DIR] [--sortie RESULTATS.json] [--cas ID,ID…]
                                           [--representabilite JUGEMENTS.json] [--reference REFERENCE.json]
                                           [--brut BRUT.json] [--tableaux TABLEAUX.md]

Pour chaque cas et chaque variante :
  - le graphe du lecteur (le lecteur actuel, UDPipe 1 par défaut) ;
  - la requête compilée de la définition par l'ADAPTATEUR EXPÉRIMENTAL (outils/bancs/adaptateur_scene.pl : la
    définition compilée comme un libellé de scène, sans changer le compilateur), son statut de compilation, ses
    raisons, le chemin qu'un vrai libellé de cette forme prendrait, les limites de l'adaptateur ;
  - le statut du noyau (etablie, etablie_sous_hypotheses, ecartee, contradictoire, non_certifiee, inconnue,
    incomplet, erreur ; sans_requete quand l'adaptateur ne donne pas de requête), les hypothèses, la qualification
    (codage.pl), les temps ;
  - la comparaison de (c) à (b) = statut_attendu (relatif à K0-d30) : accord, (c) plus fort (une erreur de sûreté
    potentielle), (c) plus faible ; et à (a) dès que REFERENCE.json existe ({id: {statut_synthetique, variantes:
    {n: statut}}}, n le rang de la variante à partir de 0, comme docs/ANNOTATION_REFERENCE.md, § 6) ;
  - la représentabilité du cas (JUGEMENTS.json, un jugement écrit sur le texte), comparée à extensions_requises.

Les fichiers de cas ne sont que lus : leurs empreintes SHA-256 sont prises avant et après, et la mesure échoue si
elles changent. Rien n'est jugé ici, et aucune référence n'est révisée d'après les sorties.

--brut : reprend une sortie du moteur déjà calculée (la sortie brute de mesurer_moteur.pl, ou un RESULTATS.json
précédent), pour refaire les comptes (une représentabilité, une référence nouvelles) sans relancer le moteur."""
import argparse, collections, datetime, hashlib, json, os, pathlib, subprocess, sys, tempfile

ICI = pathlib.Path(__file__).resolve().parent
DEPOT = ICI.parent.parent
DEV = "/home/user/donnees/bancs_phase1/dev"
BASE = "/home/user/donnees/base"
SORTIE = "/home/user/donnees/bancs_phase1/v3/mesure_initiale/resultats.json"
REFERENCE = "/home/user/donnees/bancs_phase1/v3/reference.json"
JUGEMENTS = DEPOT / "docs" / "mesures" / "representabilite_dev.json"

STATUTS = ["etablie", "etablie_sous_hypotheses", "ecartee", "contradictoire", "non_certifiee", "inconnue",
           "incomplet", "erreur", "sans_requete"]

# Ce qu'affirme un statut (docs/INTERPRETATIONS_ADMISSIBLES.md, § 2.5) : on compare les statuts par ce qu'ils
# affirment, non par leur nom. « certifie » : une solution certifiable ; « conditionnel » : la même chose sous des
# hypothèses nommées ; « substitution » : une substitution vraie existe ; « appui_negatif » : un appui négatif connu ;
# « refute » : la requête est réfutée pour les référents cités. inconnue, incomplet, erreur, sans_requete n'affirment rien.
AFFIRME = {
    "etablie": {"certifie", "conditionnel", "substitution"},
    "etablie_sous_hypotheses": {"conditionnel"},
    "non_certifiee": {"substitution"},
    "contradictoire": {"substitution", "appui_negatif"},
    "ecartee": {"refute", "appui_negatif"},
}


def affirme(s):
    return AFFIRME.get(s, set())


def comparer(c, ref):
    """(c) contre une référence : accord, plus_fort (c affirme ce que la référence n'affirme pas : une erreur de sûreté
    potentielle, BANCS § 7), plus_faible (c affirme strictement moins). Incomparable (chacun affirme ce que l'autre
    n'affirme pas) est compté plus_fort : la sûreté prime."""
    if ref is None:
        return None
    a, b = affirme(c), affirme(ref)
    if a - b:
        return "plus_fort"
    if a == b:
        return "accord"
    return "plus_faible"


def surete_stricte(c, ref):
    """L'erreur de sûreté au sens de docs/BANCS_PHASE1.md, § 7 : etablie pour un statut qui n'est pas etablie, ou
    ecartee pour un statut qui n'affirme pas la réfutation. Une conclusion seulement sous hypothèses nommées n'en est
    pas une (elle est comptée plus forte, à part)."""
    if ref is None:
        return None
    return (c == "etablie" and ref != "etablie") or (c == "ecartee" and ref not in ("ecartee", "contradictoire"))


# les extensions qui ne sont pas des limites du langage d'assertions ou des requêtes, mais des opérations ou des
# connaissances (docs/AUDIT_EXPRESSIVITE.md, § 4 : la classification par définition, l'abduction)
HORS_LANGAGE = {"base_de_definitions", "abduction"}


def empreintes(d):
    return {f: hashlib.sha256((pathlib.Path(d) / f).read_bytes()).hexdigest()
            for f in sorted(os.listdir(d)) if f.endswith(".json")}


def charger_cas(d, ids=None):
    cas = []
    for f in sorted(os.listdir(d)):
        if f.endswith(".json"):
            for c in json.loads((pathlib.Path(d) / f).read_text(encoding="utf-8")):
                if ids is None or c["id"] in ids:
                    cas.append(c)
    return cas


def entree(cas):
    out = []
    for c in cas:
        ts = [{"n": "base", "langue": c["langue"], "description": c["description"]}]
        for i, v in enumerate(c["variantes"]):
            ts.append({"n": i, "langue": v.get("langue", c["langue"]), "description": v["description"]})
        out.append({"id": c["id"], "definition": c["definition"], "textes": ts})
    return out


def lancer(base, cas):
    env = dict(os.environ, LANG="C.UTF-8", LC_ALL="C.UTF-8")
    with tempfile.TemporaryDirectory() as t:
        e, s = pathlib.Path(t) / "entree.json", pathlib.Path(t) / "brut.json"
        e.write_text(json.dumps(entree(cas), ensure_ascii=False), encoding="utf-8")
        p = subprocess.run(["swipl", str(ICI / "mesurer_moteur.pl"), base, str(e), str(s)], env=env,
                           capture_output=True, text=True)
        journal = [l for l in p.stderr.splitlines() if not l.startswith("Warning")]
        if p.returncode != 0 or not s.exists():
            sys.exit(f"le moteur a échoué ({p.returncode}) :\n" + "\n".join(journal[-40:]))
        return json.loads(s.read_text(encoding="utf-8")), journal


def git(*args):
    try:
        return subprocess.run(["git", "-C", str(DEPOT), *args], capture_output=True, text=True, check=True).stdout.strip()
    except Exception:
        return None


def version_moteur():
    modifs = git("status", "--porcelain", "--", "oedipamaas")
    reglages = {k: os.environ.get(k) for k in ["OEDIPAMAAS_ANALYSEUR", "OEDIPAMAAS_SURETE", "OEDIPAMAAS_SENS_EN",
                                                "OEDIPAMAAS_REFONTE", "OEDIPAMAAS_INFERENCES", "OEDIPAMAAS_TEMPS"]}
    return {"commit": git("rev-parse", "HEAD"), "branche": git("rev-parse", "--abbrev-ref", "HEAD"),
            "reglages_du_moteur": reglages,
            "moteur_modifie_localement": bool(modifs), "modifications_du_moteur": modifs.splitlines() if modifs else [],
            "outils_de_mesure": {f: hashlib.sha256((ICI / f).read_bytes()).hexdigest()
                                 for f in ["mesurer_moteur.py", "mesurer_moteur.pl", "adaptateur_scene.pl"]}}


def a_un_atome(faits):
    return faits not in (None, "erreur") and any(f[0] in ("entite", "evenement") for f in faits)


def classer_echec(t, d):
    """L'étape où la paire s'arrête : lecture, compilation (adaptateur), noyau, erreur ; aucune si le noyau conclut
    (établie, sous hypothèses, écartée, contradictoire, non certifiée) ou si inconnue est un vrai échec sémantique."""
    st = t["noyau"]["statut"]
    if t["noyau"].get("etape") == "mesure":
        return "erreur"
    if t["lecture"] == "erreur":
        return "lecture"
    if st == "sans_requete":
        return "compilation"
    if st in ("incomplet", "erreur"):
        return "noyau"
    return None


def brut_depuis_resultats(r):
    """La sortie brute du moteur, reconstituée d'un RESULTATS.json précédent."""
    defs = [dict(c["adaptateur"], id=c["id"]) for c in r["cas"]]
    textes = [{"id": c["id"], "n": e["n"], "langue": e["langue"], "lecture": e["lecture"], "faits": e["faits"],
               "phrases": e["phrases"], "validation": e["validation"], "noyau": e["noyau"], "temps": e["temps"]}
              for c in r["cas"] for e in c["elements"]]
    v = {k: x for k, x in r["versions"].items() if k != "moteur"}
    return {"versions": v, "definitions": defs, "textes": textes}, r.get("journal", []), r["versions"]["moteur"]


def mots_de_la_requete(q):
    """Les mots portés par les atomes d'une requête (sa forme ~q), en minuscules."""
    import re
    return {w.lower() for x in re.findall(r"'([^']*)'|\b([a-zA-Z][\w-]*)\b", q) for w in re.split(r"[ _-]", x[0] or x[1]) if w}


def defauts_de_la_requete(d):
    """Ce que la requête de la définition perd, mot à mot (sur l'analyse Stanza) : les mots que mots_non_couverts/4 du
    compilateur ne contrôle pas (nom propre, nombre, interjection : seuls NOUN, VERB, ADJ le sont), et les participes
    ou gérondifs devenus des types (« kneeling », « reading »). Un diagnostic de la mesure, non une règle du moteur."""
    q = d["suffisante"]
    mq = mots_de_la_requete(q)
    perdus, types_ing = [], []
    for ph in d["phrases"]:
        for m in ph:
            forme, lemme, cat = m[1], m[2], m[3]
            if cat in ("PROPN", "NUM", "INTJ") and forme.lower() not in mq and lemme.lower() not in mq:
                perdus.append(f"{forme}/{cat}")
    import re
    for t in re.findall(r"type\(v\(\w+\),'?([\w -]+?)'?\)", q):
        if t.endswith("ing") and t not in ("king", "thing", "ring", "wing", "spring", "ceiling", "building", "painting", "clothing", "evening", "morning", "offspring", "string", "lightning"):
            types_ing.append(t)
    return {"mots_non_controles_perdus": perdus, "types_en_ing": types_ing,
            "type_st": "type(v(" in q and ",st)" in q, "nombre_dans_la_requete": "nombre(" in q}


def assembler(cas, brut, jugements, reference):
    defs = {d["id"]: d for d in brut["definitions"]}
    txt = {(t["id"], t["n"]): t for t in brut["textes"]}
    sortie = []
    for c in cas:
        d = defs[c["id"]]
        j = jugements.get(c["id"])
        ext = c.get("extensions_requises") or []
        rep = None
        if j:
            besoin_b = bool([e for e in ext if e != "aucune"])
            rep = dict(j)
            rep["extensions_requises_du_cas"] = ext
            if j["classe"] == "representable":
                rep["accord_extensions"] = "accord" if not besoin_b else "desaccord"
            elif j["classe"] == "non_representable":
                rep["accord_extensions"] = "accord" if besoin_b else "desaccord"
            else:
                rep["accord_extensions"] = "partielle_avec_extensions" if besoin_b else "partielle_sans_extension"
            commun = sorted(set(j.get("extensions", [])) & set(ext))
            rep["extensions_communes"] = commun
            # la même comparaison, sans les extensions qui sont des opérations (HORS_LANGAGE)
            besoin_l = bool([e for e in ext if e not in HORS_LANGAGE | {"aucune"}])
            if j["classe"] == "representable":
                rep["accord_extensions_du_langage"] = "accord" if not besoin_l else "desaccord"
            elif j["classe"] == "non_representable":
                rep["accord_extensions_du_langage"] = "accord" if besoin_l else "desaccord"
            else:
                rep["accord_extensions_du_langage"] = "partielle_avec_extensions" if besoin_l else "partielle_sans_extension"
        ref = reference.get(c["id"]) if reference is not None else None
        elems = []
        for n, x in [("base", c)] + list(enumerate(c["variantes"])):
            t = txt[(c["id"], n)]
            st = t["noyau"]["statut"]
            b = x["statut_attendu"]
            if ref is None:
                a = None
            elif n == "base":
                a = ref.get("statut_synthetique")
            else:
                a = (ref.get("variantes") or {}).get(str(n))
            elems.append({
                "n": n, "langue": t["langue"], "variation": x.get("variation", "base"), "sorte": x.get("sorte"),
                "description": x["description"],
                "statut_c": st, "noyau": t["noyau"], "statut_b": b, "hypotheses_b": x.get("hypotheses_attendues", []),
                "c_contre_b": comparer(st, b), "surete_stricte_b": surete_stricte(st, b),
                "decision_ouverte_b": x.get("decision_ouverte") or (c.get("decision_ouverte") if n != "base" else None),
                "statut_a": a, "c_contre_a": comparer(st, a) if a is not None else ("a_remplir" if reference is None else None),
                "surete_stricte_a": surete_stricte(st, a),
                "echec": classer_echec(t, d),
                "lecture": t["lecture"], "graphe_vide": not a_un_atome(t["faits"]), "validation": t["validation"],
                "faits": t["faits"], "phrases": t["phrases"], "temps": t["temps"],
                "extensions_requises_variante": x.get("extensions_requises") if n != "base" else None,
            })
        sortie.append({
            "id": c["id"], "famille": c["famille"], "langue": c["langue"], "sorte": c["sorte"],
            "definition": c["definition"], "extensions_requises": ext,
            "adaptateur": {k: d[k] for k in ["net", "chemin_reel", "limites", "statut_compilation", "raisons",
                                             "famille", "suffisante", "necessaire", "faits", "phrases", "temps"]},
            "defauts_de_la_requete": defauts_de_la_requete(d),
            "representabilite": rep, "elements": elems,
        })
    return sortie


def resume(sortie):
    """Les comptes du rapport."""
    R = {}
    tous = [(c, e) for c in sortie for e in c["elements"]]
    cnt = lambda it: dict(collections.Counter(it).most_common())
    R["n_cas"], R["n_elements"] = len(sortie), len(tous)
    R["n_variantes"] = len(tous) - len(sortie)
    R["statut_c"] = cnt(e["statut_c"] for _, e in tous)
    R["statut_c_base"] = cnt(e["statut_c"] for _, e in tous if e["n"] == "base")
    R["statut_b"] = cnt(e["statut_b"] for _, e in tous)

    def par(cle):
        m = collections.defaultdict(collections.Counter)
        for c, e in tous:
            m[cle(c, e)][e["statut_c"]] += 1
        return {k: dict(v) for k, v in sorted(m.items())}
    R["statut_c_par_famille"] = par(lambda c, e: c["famille"])
    R["statut_c_par_langue"] = par(lambda c, e: e["langue"])
    R["statut_c_par_sorte"] = par(lambda c, e: e["sorte"] or "?")
    R["statut_c_par_representabilite"] = par(lambda c, e: (c["representabilite"] or {}).get("classe", "non_jugee"))
    mat = collections.defaultdict(collections.Counter)
    for _, e in tous:
        mat[e["statut_b"]][e["statut_c"]] += 1
    R["matrice_b_lignes_c_colonnes"] = {k: dict(v) for k, v in sorted(mat.items())}
    R["c_contre_b"] = cnt(e["c_contre_b"] for _, e in tous)
    R["c_contre_b_par_famille"] = {f: dict(collections.Counter(e["c_contre_b"] for c, e in tous if c["famille"] == f))
                                   for f in sorted({c["famille"] for c in sortie})}
    R["c_contre_b_par_langue"] = {l: dict(collections.Counter(e["c_contre_b"] for _, e in tous if e["langue"] == l))
                                  for l in ("en", "fr")}
    R["c_contre_a"] = cnt(e["c_contre_a"] for _, e in tous)
    R["plus_fort_que_b"] = [{"id": c["id"], "n": e["n"], "langue": e["langue"], "variation": e["variation"],
                            "sorte": e["sorte"], "statut_b": e["statut_b"], "statut_c": e["statut_c"],
                            "hypotheses_c": e["noyau"].get("hypotheses", []),
                            "qualification": e["noyau"].get("qualification"),
                            "statut_compilation": c["adaptateur"]["statut_compilation"],
                            "suffisante": c["adaptateur"]["suffisante"]}
                           for c, e in tous if e["c_contre_b"] == "plus_fort"]
    for x, (c, e) in zip(R["plus_fort_que_b"], [(c, e) for c, e in tous if e["c_contre_b"] == "plus_fort"]):
        x["surete_stricte"] = e["surete_stricte_b"]
        d = e["decision_ouverte_b"]
        x["decision_ouverte_b"] = d.get("statut_selon_l_option") if d else None
        x["c_egal_a_une_option"] = bool(d) and e["statut_c"] in d.get("statut_selon_l_option", {}).values()
        x["description"] = e["description"]
    R["surete_stricte_b"] = sum(bool(e["surete_stricte_b"]) for _, e in tous)
    R["accords_informatifs"] = cnt(e["statut_c"] for _, e in tous if e["c_contre_b"] == "accord" and e["statut_c"] != "inconnue")
    R["surete_stricte_a"] = (sum(bool(e["surete_stricte_a"]) for _, e in tous)
                             if any(e["statut_a"] is not None for _, e in tous) else "a_remplir")
    R["echecs_par_etape"] = cnt(e["echec"] or "aucun" for _, e in tous)
    # les inconnues : combien d'atomes de la suffisante sont satisfaits, par langue du texte
    diag = {}
    for l in ("en", "fr"):
        xs = [e["noyau"].get("partiel") or {} for _, e in tous if e["langue"] == l and e["statut_c"] == "inconnue"]
        sat = sum(len(x.get("satisfaits", [])) for x in xs)
        man = sum(len(x.get("manquants", [])) for x in xs)
        ty = [a for x in xs for a in x.get("satisfaits", []) + x.get("manquants", []) if a.startswith(("type(", "evenement(", "propriete("))]
        tys = [a for x in xs for a in x.get("satisfaits", []) if a.startswith(("type(", "evenement(", "propriete("))]
        diag[l] = {"inconnues": len(xs), "atomes_satisfaits": sat, "atomes_manquants": man,
                   "part_satisfaite": round(sat / (sat + man), 3) if sat + man else None,
                   "part_des_atomes_lexicaux_satisfaits": round(len(tys) / len(ty), 3) if ty else None,
                   "un_seul_atome_manquant": sum(len(x.get("manquants", [])) == 1 for x in xs)}
    R["inconnues_diagnostic"] = diag
    R["graphes_vides"] = sum(e["graphe_vide"] for _, e in tous)
    R["graphes_signales_par_la_validation"] = sum(bool(e["validation"]) for _, e in tous)
    R["inconnue_avec_requete"] = sum(e["statut_c"] == "inconnue" for _, e in tous)
    R["compilation"] = cnt(c["adaptateur"]["statut_compilation"] for c in sortie)
    R["compilation_par_chemin_reel"] = {}
    for c in sortie:
        k = c["adaptateur"]["chemin_reel"]
        R["compilation_par_chemin_reel"].setdefault(k, collections.Counter())[c["adaptateur"]["statut_compilation"]] += 1
    R["compilation_par_chemin_reel"] = {k: dict(v) for k, v in R["compilation_par_chemin_reel"].items()}
    dq = [c["defauts_de_la_requete"] for c in sortie]
    R["defauts_de_la_requete"] = {
        "definitions_avec_un_mot_non_controle_perdu": sum(bool(x["mots_non_controles_perdus"]) for x in dq),
        "dont_declarees_compilees": sum(bool(x["mots_non_controles_perdus"]) for x, c in zip(dq, sortie)
                                        if c["adaptateur"]["statut_compilation"] == "compilee"),
        "mots_perdus_par_categorie": cnt(m.split("/")[-1] for x in dq for m in x["mots_non_controles_perdus"]),
        "definitions_avec_un_type_en_ing": sum(bool(x["types_en_ing"]) for x in dq),
        "definitions_avec_type_st": sum(x["type_st"] for x in dq),
        "requetes_avec_nombre": sum(x["nombre_dans_la_requete"] for x in dq),
        "definitions_avec_un_nombre": sum(any(m.endswith("/NUM") for m in x["mots_non_controles_perdus"]) or x["nombre_dans_la_requete"] for x in dq)}
    R["raisons_de_compilation"] = cnt(r.split("(")[0] for c in sortie for r in set(c["adaptateur"]["raisons"]))
    R["qualification"] = cnt(str(e["noyau"].get("qualification")) for _, e in tous)
    rep = [c["representabilite"] for c in sortie if c["representabilite"]]
    R["representabilite"] = cnt(r["classe"] for r in rep)
    R["representabilite_par_famille"] = {f: dict(collections.Counter(c["representabilite"]["classe"] for c in sortie
                                                                      if c["famille"] == f and c["representabilite"]))
                                         for f in sorted({c["famille"] for c in sortie})}
    R["representabilite_par_langue"] = {l: dict(collections.Counter(c["representabilite"]["classe"] for c in sortie
                                                                     if c["langue"] == l and c["representabilite"]))
                                        for l in ("en", "fr")}
    R["representabilite_contre_extensions_requises"] = cnt(r["accord_extensions"] for r in rep)
    R["representabilite_contre_extensions_du_langage"] = cnt(r["accord_extensions_du_langage"] for r in rep)
    R["representabilite_croisee"] = {k: dict(v) for k, v in sorted(
        _croiser(((c["representabilite"]["classe"],
                   "avec_extension" if [x for x in c["extensions_requises"] if x != "aucune"] else "aucune")
                  for c in sortie if c["representabilite"])).items())}
    R["representabilite_desaccords"] = [{"id": c["id"], "classe": c["representabilite"]["classe"],
                                         "extensions_jugees": c["representabilite"].get("extensions", []),
                                         "extensions_requises": c["extensions_requises"]}
                                        for c in sortie if c["representabilite"]
                                        and c["representabilite"]["accord_extensions"] == "desaccord"]
    R["extensions_recouvrement"] = cnt(
        ("identiques" if set(c["representabilite"].get("extensions", [])) == set(x for x in c["extensions_requises"] if x != "aucune")
         else "recouvrement" if c["representabilite"]["extensions_communes"] else "disjointes")
        for c in sortie if c["representabilite"] and c["representabilite"]["classe"] != "representable"
        and [x for x in c["extensions_requises"] if x != "aucune"])
    R["extensions_jugees"] = cnt(x for r in rep for x in r.get("extensions", []))
    R["extensions_requises_des_cas"] = cnt(x for c in sortie for x in c["extensions_requises"])
    R["legitimite_adaptateur"] = cnt(r.get("adaptateur", "?") for r in rep)
    R["legitimite_adaptateur_par_famille"] = {f: dict(collections.Counter(c["representabilite"]["adaptateur"] for c in sortie
                                                                          if c["famille"] == f and c["representabilite"]))
                                              for f in sorted({c["famille"] for c in sortie})}
    R["adaptateur_juge_contre_chemin_mecanique"] = {k: dict(v) for k, v in _croiser(
        ((c["representabilite"]["adaptateur"], c["adaptateur"]["chemin_reel"]) for c in sortie if c["representabilite"])).items()}
    R["compilation_par_legitimite"] = {k: dict(v) for k, v in _croiser(
        ((c["representabilite"]["adaptateur"], c["adaptateur"]["statut_compilation"]) for c in sortie if c["representabilite"])).items()}
    R["statut_c_par_legitimite"] = par(lambda c, e: (c["representabilite"] or {}).get("adaptateur", "non_jugee"))
    R["textes_francais_contre_definition_anglaise"] = sum(e["langue"] == "fr" for _, e in tous)
    R["temps"] = {"noyau_total": sum(e["temps"].get("noyau", 0) for _, e in tous),
                  "noyau_max": max((e["temps"].get("noyau", 0) for _, e in tous), default=0),
                  "lecture_total": sum(e["temps"].get("lecture", 0) for _, e in tous),
                  "adaptateur_total": sum(c["adaptateur"]["temps"] for c in sortie)}
    return R


def _croiser(paires):
    m = collections.defaultdict(collections.Counter)
    for a, b in paires:
        m[a][b] += 1
    return m


def tableaux(R, sortie):
    """Les tableaux du rapport, en Markdown."""
    L = []
    col = [s for s in STATUTS if s in R["statut_c"]]

    def table(titre, m, cles=None):
        L.append(f"### {titre}\n")
        L.append("| | " + " | ".join(col) + " | total |")
        L.append("|---" * (len(col) + 2) + "|")
        for k in cles or m:
            v = m.get(k, {})
            L.append(f"| {k} | " + " | ".join(str(v.get(s, 0)) for s in col) + f" | {sum(v.values())} |")
        L.append("")
    table("(c) par famille (cas et variantes)", R["statut_c_par_famille"])
    table("(c) par langue de la description", R["statut_c_par_langue"])
    table("(c) par sorte", R["statut_c_par_sorte"])
    table("(c) par classe de représentabilité", R["statut_c_par_representabilite"])
    table("Matrice : (b) en ligne, (c) en colonne", R["matrice_b_lignes_c_colonnes"])
    L.append("### (c) contre (b), par famille\n")
    L.append("| famille | accord | plus fort | plus faible |\n|---|---|---|---|")
    for f, v in R["c_contre_b_par_famille"].items():
        L.append(f"| {f} | {v.get('accord', 0)} | {v.get('plus_fort', 0)} | {v.get('plus_faible', 0)} |")
    L.append("")
    L.append("### Représentabilité, par famille\n")
    L.append("| famille | représentable | projection partielle | non représentable |\n|---|---|---|---|")
    for f, v in R["representabilite_par_famille"].items():
        L.append(f"| {f} | {v.get('representable', 0)} | {v.get('projection_partielle', 0)} | {v.get('non_representable', 0)} |")
    L.append("")
    return "\n".join(L)


def main():
    ap = argparse.ArgumentParser(description=__doc__.split("\n")[0])
    ap.add_argument("--dev", default=DEV)
    ap.add_argument("--base", default=BASE)
    ap.add_argument("--sortie", default=SORTIE)
    ap.add_argument("--cas", default=None, help="des identifiants séparés par des virgules (par défaut : tous)")
    ap.add_argument("--representabilite", default=str(JUGEMENTS))
    ap.add_argument("--reference", default=REFERENCE)
    ap.add_argument("--brut", default=None)
    ap.add_argument("--tableaux", default=None)
    a = ap.parse_args()
    avant = empreintes(a.dev)
    ids = set(a.cas.split(",")) if a.cas else None
    cas = charger_cas(a.dev, ids)
    if not cas:
        sys.exit("aucun cas")
    debut = datetime.datetime.now(datetime.timezone.utc).isoformat()
    vm = None
    if a.brut:
        b = json.loads(pathlib.Path(a.brut).read_text(encoding="utf-8"))
        brut, journal, vm = brut_depuis_resultats(b) if "cas" in b else (b, [], None)
        if "cas" in b:
            debut = b.get("date", debut)
    else:
        brut, journal = lancer(a.base, cas)
        vm = version_moteur()
    apres = empreintes(a.dev)
    if avant != apres:
        sys.exit("les fichiers de cas ont changé pendant la mesure")
    jugements = {}
    if a.representabilite and pathlib.Path(a.representabilite).exists():
        jugements = {j["id"]: j for j in json.loads(pathlib.Path(a.representabilite).read_text(encoding="utf-8"))["cas"]}
    # le niveau (a) : seulement si le fichier existe ; il n'est pas ouvert sinon
    reference = json.loads(pathlib.Path(a.reference).read_text(encoding="utf-8")) if pathlib.Path(a.reference).exists() else None
    sortie = assembler(cas, brut, jugements, reference)
    R = resume(sortie)
    res = {"mesure": "niveau (c), point de départ (docs/BANCS_PHASE1.md, § 9.4)",
           "date": debut, "versions": {"moteur": vm or version_moteur(), **brut["versions"]},
           "parametres": {"dev": a.dev, "cas": sorted(ids) if ids else "tous", "representabilite": a.representabilite,
                          "reference": a.reference if reference is not None else None,
                          "reference_disponible": reference is not None},
           "empreintes_des_cas": avant, "cas_inchanges": avant == apres,
           "resume": R, "journal": journal, "cas": sortie}
    p = pathlib.Path(a.sortie)
    p.parent.mkdir(parents=True, exist_ok=True)
    p.write_text(json.dumps(res, ensure_ascii=False, indent=1), encoding="utf-8")
    if a.tableaux:
        pathlib.Path(a.tableaux).write_text(tableaux(R, sortie), encoding="utf-8")
    print(f"{R['n_cas']} cas, {R['n_elements']} textes ; (c) : {R['statut_c']} ; (c)/(b) : {R['c_contre_b']}")


if __name__ == "__main__":
    main()
