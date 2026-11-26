"""Banc différentiel : oracle Python (oracle_noyau.py) contre les deux moteurs Prolog.

Tire N cas (graine fixe), les écrit dans un seul fichier Prolog, appelle swipl une fois :
  satisfaction:satisfaire(K, G, requete(q, F), resultat(S, _, _))
  satisfaction_reference:statut_reference(K, G, requete(q, F), S)
compare les trois statuts, écrit les désaccords (JSON), imprime la distribution des statuts de l'oracle,
puis minimise les cinq premiers désaccords.

Usage : python3 differentiel.py [-n 500] [--graine 20261126] [--jeu oracle|gen] [--sortie CHEMIN]
                                [--sans-minimisation] [--minimiser N] [--depot CHEMIN]
  --jeu oracle : le K et le générateur de oracle_noyau.py (types entiers, polysémie, alias non clos, ...) ;
  --jeu gen    : le K des tests génératifs (tests/plunit/connaissances_gen.pl) et la reproduction en Python
                 de leur générateur (genre, portée oeuvre, lemme_a, ...).
"""

from __future__ import annotations

import argparse
import collections
import json
import os
import subprocess
import sys
import tempfile
from dataclasses import replace

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import oracle_noyau as O  # noqa: E402

DEPOT = "/home/user/oedipamaas"
# --depot permet de charger les mêmes deux fichiers d'une autre copie du dépôt (par exemple une extraction
# de HEAD), par la même interface.
SATISFACTION = f"{DEPOT}/oedipamaas/socle/satisfaction.pl"
REFERENCE = f"{DEPOT}/oedipamaas/socle/satisfaction_reference.pl"
REP_PLUNIT = f"{DEPOT}/tests/plunit"


def choisir_depot(depot):
    global SATISFACTION, REFERENCE, REP_PLUNIT
    SATISFACTION = f"{depot}/oedipamaas/socle/satisfaction.pl"
    REFERENCE = f"{depot}/oedipamaas/socle/satisfaction_reference.pl"
    REP_PLUNIT = f"{depot}/tests/plunit"
SORTIE = ("/tmp/claude-0/-home-user-oedipamaas/d0859811-5c3e-5c8f-a763-617b9258ee72/scratchpad/oracle/"
          "desaccords.json")

PILOTE = r"""
:- use_module(library(time)).
:- use_module('%(sat)s').
:- use_module('%(ref)s').
:- use_module('%(k)s', []).

nom_statut(S, N) :- ( compound(S) -> functor(S, N, _) ; N = S ).

statut_optimise(G, F, N, D) :-
    catch(call_with_time_limit(30,
            (   satisfaction:satisfaire(%(km)s, G, requete(q, F), resultat(S, _, _))
            ->  nom_statut(S, N), D = S
            ;   N = echec, D = echec )),
          E, (N = erreur, D = E)).

statut_ref(G, F, N, D) :-
    catch(call_with_time_limit(30,
            (   satisfaction_reference:statut_reference(%(km)s, G, requete(q, F), S)
            ->  nom_statut(S, N), D = S
            ;   N = echec, D = echec )),
          E, (N = erreur, D = E)).

principal :-
    forall(cas(I, G, F),
           (   statut_optimise(G, F, S1, D1),
               statut_ref(G, F, S2, D2),
               ( S1 == erreur -> true ; true ),
               format("~w\t~w\t~w\t~q\t~q~n", [I, S1, S2, D1, D2]),
               flush_output )).

:- initialization((principal, halt), main).
"""


def ecrire_k(rep: str, K) -> str:
    if K.fichier:
        return K.fichier
    chemin = os.path.join(rep, "k_oracle.pl")
    with open(chemin, "w", encoding="utf-8") as f:
        f.write(O.pl_connaissances(K))
    return chemin


def executer_moteurs(cas: list, K, rep: str) -> list:
    """Un seul fichier Prolog, un seul appel à swipl ; rend [(statut_optimise, statut_reference, d1, d2)]."""
    chemin_k = ecrire_k(rep, K)
    chemin = os.path.join(rep, "cas.pl")
    with open(chemin, "w", encoding="utf-8") as f:
        f.write(":- encoding(utf8).\n")
        f.write(PILOTE % {"sat": SATISFACTION, "ref": REFERENCE, "k": chemin_k, "km": K.module})
        for i, (g, q) in enumerate(cas):
            f.write(f"cas({i}, {O.pl_graphe(g)}, {O.pl_formule(q)}).\n")
    env = dict(os.environ, LANG="C.UTF-8", LC_ALL="C.UTF-8")
    p = subprocess.run(["swipl", chemin], cwd=REP_PLUNIT, env=env, capture_output=True, text=True,
                       stdin=subprocess.DEVNULL,
                       timeout=60 + 70 * len(cas))
    res = {}
    for ligne in p.stdout.splitlines():
        parts = ligne.split("\t")
        if len(parts) == 5 and parts[0].isdigit():
            res[int(parts[0])] = (parts[1], parts[2], parts[3], parts[4])
    if len(res) != len(cas):
        sys.stderr.write(p.stderr[-4000:])
        raise RuntimeError(f"swipl n'a rendu que {len(res)} lignes sur {len(cas)}")
    return [res[i] for i in range(len(cas))]


# --- Minimisation -----------------------------------------------------------------------------------------

def _sans_ids(g: O.Graphe, ids: set) -> O.Graphe:
    """Retire des assertions (et tout ce qui s'y rapporte), en gardant un graphe valide."""
    ents = {e for e, _ in g.entites if e not in ids}
    evs = {v for v, _ in g.evenements if v not in ids}
    noms = tuple(x for x in g.noms if x[0] not in ids and x[1] in ents)
    props = tuple(x for x in g.proprietes if x[0] not in ids and x[1] in ents)
    rels = tuple(x for x in g.relations if x[0] not in ids and x[1] in ents and x[3] in ents)
    gardes = ents | evs | {x[0] for x in noms + props + rels}
    alts = []
    for gid, ms in g.alternatives:
        ms2 = tuple(m for m in ms if m in gardes)
        if len(ms2) >= 2:
            alts.append((gid, ms2))
    return O.Graphe(
        entites=tuple(x for x in g.entites if x[0] in ents), noms=noms, proprietes=props,
        evenements=tuple(x for x in g.evenements if x[0] in evs),
        roles=tuple(x for x in g.roles if x[0] in evs and x[2] in ents), relations=rels,
        corefs=tuple(x for x in g.corefs if x[0] in ents and x[1] in ents),
        distincts=tuple(x for x in g.distincts if x[0] in ents and x[1] in ents),
        nombres=tuple(x for x in g.nombres if x[0] in ents),
        qualifs=tuple(x for x in g.qualifs if x[0] in gardes), alternatives=tuple(alts))


def reductions_graphe(g: O.Graphe):
    for i in g.ids_assertions():
        yield _sans_ids(g, {i})
    for champ in ("roles", "corefs", "distincts", "nombres", "alternatives"):
        val = getattr(g, champ)
        for k in range(len(val)):
            yield replace(g, **{champ: val[:k] + val[k + 1:]})
    defaut = O.Qualif()
    for k, (i, q) in enumerate(g.qualifs):
        for attr in ("polarite", "modalite", "portee", "enonciateur"):
            if getattr(q, attr) != getattr(defaut, attr):
                q2 = replace(q, **{attr: getattr(defaut, attr)})
                yield replace(g, qualifs=g.qualifs[:k] + ((i, q2),) + g.qualifs[k + 1:])


def reductions_formule(f):
    if f[0] in ("et", "ou"):
        enfants = f[1]
        for e in enfants:                    # remplacer le nœud par un enfant
            yield e
        for k in range(len(enfants)):        # retirer un enfant
            yield (f[0], enfants[:k] + enfants[k + 1:])
        for k, e in enumerate(enfants):      # réduire un enfant
            for e2 in reductions_formule(e):
                yield (f[0], enfants[:k] + [e2] + enfants[k + 1:])
        if f[0] == "et" and len(enfants) == 1:
            yield enfants[0]


def minimiser(g, q, cible, K, rep):
    """Réduit (graphe, requête) tant que les trois statuts restent `cible`."""
    while True:
        candidats = []
        for g2 in reductions_graphe(g):
            if not O.valider(g2) and O.referents(g2) and O.statut(g2, K, q) == cible[0]:
                candidats.append((g2, q))
        for q2 in reductions_formule(q):
            if O.bien_formee(q2) and O.statut(g, K, q2) == cible[0]:
                candidats.append((g, q2))
        if not candidats:
            return g, q
        resultats = executer_moteurs(candidats, K, rep)
        for (g2, q2), r in zip(candidats, resultats):
            if (r[0], r[1]) == (cible[1], cible[2]):
                g, q = g2, q2
                break
        else:
            return g, q


def classes_vue(v):
    """Ce que l'oracle retient (§ 4.4), en clair, pour le JSON."""
    sub = lambda s: {k: (repr(val)) for k, val in sorted(s)}
    return {"certifiables": [{"sigma": sub(s), "hypotheses": [list(h) for h in hy]}
                             for _, s, hy in v.certifiables],
            "contradictoires": [sub(s) for s in v.contradictoires],
            "non_certifiees": [sub(s) for s in v.non_certifiees],
            "fausses": [sub(s) for s in v.fausses]}


def taille(g, q):
    return len(O.pl_graphe(g)) + len(O.pl_formule(q))


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("-n", type=int, default=500)
    ap.add_argument("--graine", type=int, default=20261126)
    ap.add_argument("--jeu", choices=("oracle", "gen"), default="oracle")
    ap.add_argument("--sortie", default=SORTIE)
    ap.add_argument("--sans-minimisation", action="store_true")
    ap.add_argument("--minimiser", type=int, default=5, help="nombre de désaccords à minimiser (un par motif)")
    ap.add_argument("--depot", default=DEPOT)
    ap.add_argument("--lecture", action="append", default=[],
                    help="cle=valeur : une variante de lecture de l'oracle (oracle_noyau.LECTURES)")
    args = ap.parse_args()
    choisir_depot(args.depot)
    for kv in args.lecture:
        cle, val = kv.split("=", 1)
        if cle not in O.LECTURES:
            ap.error(f"lecture inconnue : {cle}")
        O.LECTURES[cle] = {"True": True, "False": False}.get(val, val)
    if args.lecture:
        print("lectures :", O.LECTURES)

    K = O.k_gen(f"{REP_PLUNIT}/connaissances_gen.pl") if args.jeu == "gen" else O.k_de_test()
    cas = list(O.cas_aleatoires(args.graine, args.n, args.jeu))
    vues = []
    for g, q in cas:
        try:
            vues.append(O.vue(g, K, q))
        except O.MalFormee as e:
            vues.append(O.Vue("mal_formee"))
    oracle = [v.statut for v in vues]
    os.makedirs(os.path.dirname(args.sortie), exist_ok=True)
    rep = tempfile.mkdtemp(prefix="differentiel_", dir=os.path.dirname(args.sortie))
    moteurs = executer_moteurs(cas, K, rep)

    distribution = collections.Counter(oracle)
    print(f"{len(cas)} cas tirés (jeu {args.jeu}, graine {args.graine}), moteurs de {args.depot}")
    print("distribution des statuts :")
    d1 = collections.Counter(m[0] for m in moteurs)
    d2 = collections.Counter(m[1] for m in moteurs)
    print(f"  {'statut':26} {'oracle':>7} {'optimisé':>9} {'référence':>10}")
    for s_ in sorted(set(distribution) | set(d1) | set(d2)):
        print(f"  {s_:26} {distribution[s_]:7} {d1[s_]:9} {d2[s_]:10}")

    def accord(so, s1, s2):
        # § 3 : une requête mal formée est une erreur du moteur (satisfaire/4). Le moteur de référence
        # (statut_reference/4) ne contrôle pas la forme : il n'est pas comparé sur ces cas (compté à part).
        if so == "mal_formee":
            return s1 == "erreur"
        return so == s1 == s2
    mf = [(s1, s2) for so, (s1, s2, _, _) in zip(oracle, moteurs) if so == "mal_formee"]
    if mf:
        print(f"requêtes mal formées : {len(mf)} ; erreur du moteur optimisé : {sum(a == 'erreur' for a, _ in mf)} ; "
              f"statuts de la référence : {dict(collections.Counter(b for _, b in mf))}")

    desaccords = []
    for i, ((g, q), so, (s1, s2, dt1, dt2)) in enumerate(zip(cas, oracle, moteurs)):
        if not accord(so, s1, s2):
            desaccords.append({
                "indice": i, "oracle": so, "optimise": s1, "reference": s2,
                "detail_optimise": dt1, "detail_reference": dt2,
                "oracle_classes": classes_vue(vues[i]),
                "graphe": O.pl_graphe(g), "requete": O.pl_formule(q)})
    motifs = collections.Counter((d["oracle"], d["optimise"], d["reference"]) for d in desaccords)
    print(f"désaccords : {len(desaccords)}")
    for (a, b, c), n in motifs.most_common():
        print(f"  oracle={a:24} optimise={b:24} reference={c:24} {n}")

    if not args.sans_minimisation:
        vus = set()
        for d in desaccords:
            motif = (d["oracle"], d["optimise"], d["reference"])
            if motif in vus or len(vus) >= args.minimiser:
                continue
            vus.add(motif)
            g, q = cas[d["indice"]]
            gm, qm = minimiser(g, q, motif, K, rep)
            d["minimise"] = {"graphe": O.pl_graphe(gm), "requete": O.pl_formule(qm)}
            print(f"\n# cas {d['indice']} : oracle={d['oracle']} optimise={d['optimise']} "
                  f"reference={d['reference']}  (taille {taille(g, q)} -> {taille(gm, qm)})")
            print("  G =", d["minimise"]["graphe"])
            print("  F =", d["minimise"]["requete"])

    with open(args.sortie, "w", encoding="utf-8") as f:
        json.dump({"jeu": args.jeu, "graine": args.graine, "n": len(cas), "distribution_oracle": dict(distribution),
                   "desaccords": desaccords}, f, ensure_ascii=False, indent=1)
    print(f"\nécrit : {args.sortie}")


if __name__ == "__main__":
    main()
