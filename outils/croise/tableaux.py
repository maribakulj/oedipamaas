"""Les tableaux de l'expérience croisée : complétude, issues, qualification, attribution, causes.

Usage : python outils/croise/tableaux.py CAUSES.json JEU=CROISE.json [JEU=CROISE.json …] [--errata ERRATA.json]
                                        [--definition v1|v2] [--json SORTIE]

CROISE.json : la sortie de outils/croise/croiser.pl pour un jeu ; CAUSES.json : les causes décidées cas par cas pour
chaque échec de la condition (graphe de référence, requête de référence), une entrée par échec :
  {"jeu", "k", "genre", "notation", "causes": [...], "principale", "raison", "statut"}
avec causes parmi representation, lexique, desambiguisation, noyau, inference, erreur_reference. ERRATA.json : les
errata d'une version du banc (outils/graphes/version_banc.py) ; un texte « contesté » n'est pas évalué.

L'issue d'un texte dans une condition (une seule) :
  non évaluée  requete_absente (la notation n'a pas de condition suffisante dans cette source),
               gabarit_non_instancie (une notation « (...) » : la clé du nom n'est pas remplie), conteste (errata),
               graphe_en_erreur, erreur (une exception du noyau), interrompue (la limite d'inférences de la condition),
               incomplete (le budget du noyau, statut incomplet) ;
  évaluée      etablie (déductivement : sans hypothèse), etablie_sous_hypotheses, ecartee, non_certifiee,
               contradictoire, inconnue.
Un échec (définition v2, par défaut depuis le 27/11) est un texte évalué : positif dont la suffisante n'est pas
établie déductivement (« sous hypothèses » est un échec de la déduction, compté à part), ou négatif dont elle est
établie (déductivement ou sous hypothèses). La définition v1 (celle des premiers tableaux du 27/11) : un positif non
établi, même sous hypothèses, ou un négatif établi, sans exclure les gabarits ni les contestés.

Contrôle (un seul défaut, et rien n'est écrit) : chaque échec de reference_reference a exactement une entrée de
causes, et chaque entrée correspond à un échec.

Tableaux, par jeu :
  1. la complétude : les issues non évaluées, par condition et par genre ; à part, les graphes que la validation des
     assertions signale (ils sont évalués quand même) ;
  2. les issues évaluées, par condition et par genre ; la qualification (codage.pl, statut/9) ;
  3. l'attribution, sur les positifs évalués des deux côtés, par niveau : déductive (établie), sous hypothèses,
     non établie. Le lecteur : lecteur_reference contre reference_reference ; le compilateur : reference_compilee
     contre reference_reference. Chaque passage d'un niveau à l'autre est compté et nommé ;
  4. les causes des échecs de reference_reference : la principale, toutes, la cause seule, et leur statut.
Les causes sont des décisions d'agent : provisoires, jamais validées par ces tableaux."""
import argparse
import collections
import json
from pathlib import Path

CONDITIONS = ("lecteur_compilee", "lecteur_reference", "reference_compilee", "reference_reference")
ETABLI = ("etablie", "etablie_sous_hypotheses")
CAUSES = ("representation", "lexique", "desambiguisation", "noyau", "inference", "erreur_reference")
NON_EVALUEES = ("requete_absente", "gabarit_non_instancie", "conteste", "graphe_en_erreur", "erreur", "interrompue",
                "incomplete")
EVALUEES = ("etablie", "etablie_sous_hypotheses", "ecartee", "non_certifiee", "contradictoire", "inconnue")
NIVEAU = {"etablie": 2, "etablie_sous_hypotheses": 1}
NOMS_NIVEAU = {2: "deductive", 1: "sous_hypotheses", 0: "non_etablie"}


def genre_court(g):
    return "variante" if g.startswith("variante_") else g


def issue(x, c, contestes=frozenset()):
    s = x["conditions"][c]["satisfaction"]
    if (x["k"], x["genre"]) in contestes:
        return "conteste"
    if s == "sans_requete":
        return "requete_absente"
    if s in ("graphe_en_erreur", "erreur"):
        return s
    if s == "interrompu":
        return "interrompue"
    if s == "incomplet":
        return "incomplete"
    if "(...)" in x["notation"]:
        return "gabarit_non_instancie"
    if s not in EVALUEES:
        raise SystemExit(f"statut inconnu {s!r} ({x['k']}, {x['genre']}, {c})")
    return s


def echec(x, c="reference_reference", definition="v2", contestes=frozenset()):
    if definition == "v1":
        s = x["conditions"][c]["satisfaction"]
        if s == "sans_requete":
            return False
        return (x["genre"] == "positif" and s not in ETABLI) or (x["genre"] == "negatif" and s in ETABLI)
    i = issue(x, c, contestes)
    if i not in EVALUEES:
        return False
    return (x["genre"] == "positif" and i != "etablie") or (x["genre"] == "negatif" and i in ETABLI)


def compte(X, f):
    t = {}
    for c in CONDITIONS:
        t[c] = {}
        for x in X:
            t[c].setdefault(genre_court(x["genre"]), collections.Counter())[f(x, c)] += 1
    return t


def attribution(X, contestes=frozenset()):
    """Sur les positifs évalués des deux côtés : les passages de niveau (déductive, sous hypothèses, non établie) de
    reference_reference vers l'autre condition, avec les notations ; les positifs non évaluables, par raison."""
    P = [x for x in X if x["genre"] == "positif"]
    out = {"positifs": len(P),
           "reference_reference": dict(collections.Counter(issue(x, "reference_reference", contestes) for x in P))}
    for qui, c in (("lecteur", "lecteur_reference"), ("compilateur", "reference_compilee")):
        passages = collections.defaultdict(list)
        non_eval = collections.Counter()
        for x in P:
            a, b = issue(x, "reference_reference", contestes), issue(x, c, contestes)
            if a not in EVALUEES or b not in EVALUEES:
                non_eval[b if b not in EVALUEES else a] += 1
                continue
            na, nb = NIVEAU.get(a, 0), NIVEAU.get(b, 0)
            if na != nb:
                passages[f"{NOMS_NIVEAU[na]}->{NOMS_NIVEAU[nb]}"].append(x["notation"])
        out[qui] = {"passages": {k: sorted(v) for k, v in sorted(passages.items())},
                    "perd_la_deduction": sum(len(v) for k, v in passages.items() if k.startswith("deductive->")),
                    "gagne_la_deduction": sum(len(v) for k, v in passages.items() if k.endswith("->deductive")),
                    "non_evaluables": dict(non_eval)}
    return out


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("causes")
    ap.add_argument("jeux", nargs="+")
    ap.add_argument("--errata")
    ap.add_argument("--definition", choices=("v1", "v2"), default="v2")
    ap.add_argument("--json")
    a = ap.parse_args()
    causes = json.loads(Path(a.causes).read_text(encoding="utf-8"))
    contestes = collections.defaultdict(set)
    if a.errata:
        for e in json.loads(Path(a.errata).read_text(encoding="utf-8"))["errata"]:
            if e["objet"] == "fiche" and e["operation"] == "contester":
                contestes[e["jeu"]].add((e["k"], e["genre"]))
    defauts, sortie = [], {}
    vues = collections.Counter((c["jeu"], c["k"], c["genre"]) for c in causes)
    defauts += [f"causes en double : {k}" for k, n in vues.items() if n > 1]
    for c in causes:
        if c["principale"] not in CAUSES or any(x not in CAUSES for x in c["causes"]) or c["causes"][0] != c["principale"]:
            defauts.append(f"causes mal formées : {c['jeu']} {c['k']} {c['genre']}")
    jeux = {}
    for j in a.jeux:
        nom, f = j.split("=", 1)
        jeux[nom] = json.loads(Path(f).read_text(encoding="utf-8"))
    for nom, X in jeux.items():
        E = {(x["k"], x["genre"]) for x in X if echec(x, definition=a.definition, contestes=contestes[nom])}
        C = {(c["k"], c["genre"]) for c in causes if c["jeu"] == nom}
        defauts += [f"{nom} : échec sans cause {k}" for k in sorted(E - C)]
        defauts += [f"{nom} : cause sans échec {k}" for k in sorted(C - E)]
    defauts += [f"jeu inconnu : {j}" for j in sorted({c["jeu"] for c in causes} - set(jeux))]
    if defauts:
        print("\n".join(defauts))
        raise SystemExit(1)
    for nom, X in jeux.items():
        ct = contestes[nom]
        cs = [c for c in causes if c["jeu"] == nom]
        par_k = {(x["k"], x["genre"]): x for x in X}
        sous_hyp = sum(1 for c in cs if par_k[(c["k"], c["genre"])]["conditions"]["reference_reference"]["satisfaction"]
                       == "etablie_sous_hypotheses")
        sortie[nom] = {
            "definition": a.definition,
            "issues": compte(X, lambda x, c: issue(x, c, ct)),
            "graphes_signales_par_la_validation": compte(X, lambda x, c: bool(x["conditions"][c].get("validation"))),
            "qualification": compte(X, lambda x, c: str(x["conditions"][c]["qualification"])),
            "attribution": attribution(X, ct),
            "causes": {"echecs": len(cs), "dont_etablis_sous_hypotheses": sous_hyp,
                       "principale": dict(collections.Counter(c["principale"] for c in cs).most_common()),
                       "toutes": dict(collections.Counter(x for c in cs for x in c["causes"]).most_common()),
                       "seule": dict(collections.Counter(c["principale"] for c in cs if len(c["causes"]) == 1).most_common()),
                       "statut": dict(collections.Counter(c.get("statut", "?") for c in cs))},
        }
    for nom, s in sortie.items():
        print(f"\n# {nom} (définition {s['definition']})")
        for cle in ("issues", "qualification"):
            print(f"\n## {cle}")
            for c in CONDITIONS:
                print(f"  {c}")
                for g, n in s[cle][c].items():
                    print(f"    {g:12} " + ", ".join(f"{v} {m}" for v, m in sorted(n.items(), key=lambda t: -t[1])))
        print("\n## attribution (positifs ; niveaux : déductive, sous hypothèses, non établie)")
        print(f"  reference_reference : {s['attribution']['reference_reference']}")
        for qui in ("lecteur", "compilateur"):
            print(f"  {qui} : {s['attribution'][qui]}")
        print("\n## causes des échecs de reference_reference")
        for k, v in s["causes"].items():
            print(f"  {k}: {v}")
    if a.json:
        Path(a.json).write_text(json.dumps(sortie, ensure_ascii=False, indent=1, default=dict), encoding="utf-8")


if __name__ == "__main__":
    main()
