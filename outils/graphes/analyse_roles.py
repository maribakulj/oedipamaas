"""Les erreurs de rôle par construction linguistique (lot 5 ; docs/BANC_GRAPHES.md, § 4).

Usage : python outils/graphes/analyse_roles.py REFERENCES.json GRAPHES.json [--json SORTIE.json]

GRAPHES.json : la sortie de outils/graphes/lire.pl, avec l'analyse en dépendances (« phrases »). Pour chaque rôle de
référence (événement, rôle, participant), la construction est lue dans l'analyse du lecteur (Stanza), sur les mots
des mentions de référence :
  forme de l'événement : actif (verbe conjugué), passif (Voice=Pass, ou un dépendant :pass), participe (sans
    auxiliaire), gerondif, infinitif, relative (acl:relcl), nom_d_action (un nom), adjectif, autre ;
  relation du participant à l'événement : la relation de dépendance du mot tête du participant quand sa tête est le
    mot de l'événement (nsubj, obj, obl…), « tete_du_participe » quand c'est l'événement qui dépend du participant
    (« a kneeling man »), « indirecte » sinon (coordination, contrôle, relative, pronom…), « introuvable » si une
    mention n'est pas dans le texte.
Puis, pour chaque construction : les rôles de référence, ceux que le graphe a justes, ceux qu'il a sous un autre rôle
(et lequel), ceux qu'il n'a pas (l'événement aligné, ou non). C'est une analyse sur l'analyse syntaxique du lecteur :
une erreur d'analyse se range dans la construction que l'analyseur a vue."""
import argparse
import collections
import importlib.util
import json
from pathlib import Path

ICI = Path(__file__).resolve().parent
spec = importlib.util.spec_from_file_location("cg", ICI / "comparer_graphes.py")
cg = importlib.util.module_from_spec(spec)
spec.loader.exec_module(cg)


def mots(lu):
    """[(phrase, id, forme, lemme, cat, traits, tete, rel, debut, fin)]"""
    out = []
    for s, ph in enumerate(lu.get("phrases") or []):
        for m in ph:
            out.append((s, *m))
    return out


def dans_portee(m, portee):
    return portee and portee[0] <= m[8] and m[9] <= portee[1]


def mot_de(ms, portee, preferes):
    cands = [m for m in ms if dans_portee(m, portee)]
    if not cands:
        return None
    for cat in preferes:
        for m in cands:
            if m[4] == cat:
                return m
    return cands[0]


def tete_de_mention(ms, portee):
    """Le mot de la mention dont la tête syntaxique est hors de la mention."""
    cands = [m for m in ms if dans_portee(m, portee)]
    ids = {(m[0], m[1]) for m in cands}
    for m in cands:
        if (m[0], m[6]) not in ids:
            return m
    return cands[0] if cands else None


def forme(ms, v):
    s, i, cat, tr, rel = v[0], v[1], v[4], v[5], v[7]
    enfants = [m for m in ms if m[0] == s and m[6] == i]
    if cat == "NOUN":
        return "nom_d_action"
    if cat == "ADJ":
        return "adjectif"
    if cat not in ("VERB", "AUX"):
        return "autre"
    if "Voice=Pass" in tr or any(":pass" in m[7] for m in enfants):
        return "passif"
    if rel == "acl:relcl":
        return "relative"
    aux = any(m[7].startswith("aux") for m in enfants)
    if "VerbForm=Ger" in tr:
        return "gerondif"
    if "VerbForm=Part" in tr and not aux:
        return "participe"
    if "VerbForm=Inf" in tr:
        return "infinitif"
    return "actif"


def relation(v, e):
    if v is None or e is None:
        return "introuvable"
    if v[0] == e[0] and e[6] == v[1]:
        return e[7]
    if v[0] == e[0] and v[6] == e[1]:
        return "tete_du_participe"
    return "indirecte"


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("references")
    ap.add_argument("graphes")
    ap.add_argument("--json")
    a = ap.parse_args()
    R = {(x["k"], x["genre"]): x for x in json.loads(Path(a.references).read_text(encoding="utf-8"))}
    G = {(x["k"], x["genre"]): x for x in json.loads(Path(a.graphes).read_text(encoding="utf-8"))}
    par_forme = collections.defaultdict(collections.Counter)
    par_relation = collections.defaultdict(collections.Counter)
    croise = collections.defaultdict(collections.Counter)      # (forme, relation, rôle de référence) -> issue
    for k in sorted(set(R) & set(G)):
        r, g = cg.depuis_reference(R[k]), cg.depuis_faits(G[k])
        if g.erreur:
            continue
        ms = mots(G[k])
        ae = cg.aligner(r.entites, g.entites)
        av = cg.aligner(r.evenements, g.evenements)
        cr = r.classes()
        inv_e = {j: i for i, j in ae.items()}
        pred = collections.defaultdict(set)
        for v, ro, e in g.roles:
            if e in inv_e:
                pred[(v, cr[inv_e[e]])].add(ro)
        for v, ro, e in r.roles:
            pv = r.evenements[v][1]
            pe = r.entites.get(e, (None, None))[1]
            mv = mot_de(ms, pv, ("VERB", "AUX", "NOUN", "ADJ"))
            me = tete_de_mention(ms, pe)
            f = forme(ms, mv) if mv else "introuvable"
            rel = relation(mv, me)
            if v not in av:
                issue = "evenement_non_aligne"
            else:
                lus = pred.get((av[v], cr.get(e)), set())
                issue = "juste" if ro in lus else (("lu_" + "+".join(sorted(lus))) if lus else "absent")
            par_forme[f][issue] += 1
            par_relation[rel][issue] += 1
            croise[(f, rel, ro)][issue] += 1

    def table(titre, d):
        issues = ["juste", "absent", "evenement_non_aligne"]
        autres = sorted({i for c in d.values() for i in c if i not in issues})
        print(f"\n### {titre}\n")
        print("| construction | rôles | " + " | ".join(issues + autres) + " | part juste |")
        print("|---|---|" + "---|" * (len(issues) + len(autres) + 1))
        for c, n in sorted(d.items(), key=lambda x: -sum(x[1].values())):
            t = sum(n.values())
            print(f"| {c} | {t} | " + " | ".join(str(n[i]) for i in issues + autres) + f" | {n['juste'] / t:.0%} |")
    table("par forme de l'événement", par_forme)
    table("par relation du participant à l'événement", par_relation)
    print("\n### les croisements les plus fréquents (forme, relation, rôle de référence)\n")
    print("| forme | relation | rôle | rôles | juste | absent | sous un autre rôle |\n|---|---|---|---|---|---|---|")
    for (f, rel, ro), n in sorted(croise.items(), key=lambda x: -sum(x[1].values()))[:30]:
        t = sum(n.values())
        autre = ", ".join(f"{i[3:]} {c}" for i, c in n.items() if i.startswith("lu_"))
        print(f"| {f} | {rel} | {ro} | {t} | {n['juste']} | {n['absent']} | {autre or '—'} |")
    if a.json:
        Path(a.json).write_text(json.dumps({"par_forme": par_forme, "par_relation": par_relation,
                                            "croise": {"|".join(k): v for k, v in croise.items()}},
                                           ensure_ascii=False, indent=1), encoding="utf-8")


if __name__ == "__main__":
    main()
