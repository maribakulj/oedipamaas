"""Le moteur 1.0 de bout en bout : description → candidats et traits de preuve (Prolog) → décision apprise compilée
(Prolog) → codes retenus, avec leur probabilité et leur preuve. Une ligne JSON par image :
{image, versions, codes: [{code, statut, p_catalogue, preuve}]} — codes triés dans l'ordre de la décision (critère
appris : probabilité ou espérance), statut « retenu » ou « candidat ». Aucune étiquette n'est lue ici.

Les candidats donnés à la décision sont pris dans l'ordre de l'apprentissage (directs, spécialisés et à clé par part
décrite puis BM25, ancêtres ensuite), au plus MAX, comme dans le noyau qui a appris les poids.
Usage : python -m oedipamaas.socle.moteur BASE_V1/ DECISION.pl DESCRIPTIONS/ SORTIE.jsonl [MAX] [BUDGET] [ORDRE]
(ORDRE : part, celui de la première décision, ou rang_min ; toujours celui de l'apprentissage de DECISION)"""
import hashlib
import json
import sys
import time
from pathlib import Path

from oedipamaas.socle import coder, faits_description as fd
from oedipamaas.socle.candidats import BUDGET

MAX = 120


def atome(s):
    """Atome Prolog entre apostrophes (une notation peut contenir une apostrophe dans un nom)."""
    return "'" + s.replace("\\", "\\\\").replace("'", "\\'") + "'"


ORDRES = {
    # ordre de la première décision (mesurée sur P300) : part décrite, puis BM25
    "part": lambda c: (c["traits"].get("ancetre_seul", 0), -c["score"], -c["traits"].get("bm25_direct", 0.0),
                       c["code"]),
    # meilleur rang dans l'un des trois ordres (BM25, part décrite, BM25 du sujet)
    "rang_min": lambda c: (c["traits"].get("ancetre_seul", 0), -c["traits"].get("inv_rang_min", 0.0), -c["score"],
                           c["code"]),
}


def preuve(janus, c, retenus):
    t, n = c["traits"], c["code"]
    if t.get("cle"):
        base = n[:n.rindex("(+")]
        return {"regle": "cle", "base": base, "cle": n[n.rindex("(+"):]}
    if t.get("bm25_direct") or t.get("bm25_wordnet"):
        r = janus.query_once("preuve:preuve_lexicale(N, _D), preuve:preuve_json(_D, J)", {"N": n})
        if r["truth"]:
            d = json.loads(r["J"])
            d["appuis"] = d["appuis"][:5]          # les cinq premiers appuis (le reste est dans le nombre)
            d["nb_appuis"] = len(json.loads(r["J"])["appuis"])
            return d
    if t.get("specialisee"):
        return {"regle": "specialisation", "notation": n, "part_decrite": t.get("part", 0)}
    desc = [m for m in retenus if m != n and m.startswith(n)]
    return {"regle": "ancetre", "de": desc[:3]}


def main(base, decision, dossier, sortie, maximum=MAX, budget=BUDGET, nom_ordre="part"):
    ordre = ORDRES[nom_ordre]           # celui de l'apprentissage de la décision
    janus = coder.charger_moteur(base)
    for f in ("traits.pl", "preuve.pl", "decision.pl"):
        janus.consult(str(Path(coder.__file__).resolve().parent / f))
    janus.query_once(f"load_files('{Path(decision).resolve()}', [redefine_module(true)])")
    k, seuil, critere = (janus.query_once("decision_poids:reglage(K, S, C)")[x] for x in ("K", "S", "C"))
    empreinte = hashlib.sha256(Path(decision).read_bytes()).hexdigest()[:16]
    t0, n, erreurs = time.time(), 0, 0
    with open(sortie, "w", encoding="utf-8") as out:
        for f in sorted(Path(dossier).glob("*.json")):
            ligne = {"image": f.stem, "versions": {"moteur": coder.version(), "decision": empreinte,
                                                    "max": int(maximum), "budget": int(budget), "ordre": nom_ordre}}
            try:
                fd.charger(janus, fd.lire_fichier(f))
                janus.query_once("abolish_all_tables")
                r = janus.query_once("traits:candidats_traits(B, _L), findall([_N, _P, _T], (member([_N, _P, _T0], _L), "
                                     "findall([_K, _V], member(_K-_V, _T0), _T)), X)", {"B": int(budget)})
                cands = sorted(({"code": c, "score": p, "traits": dict(t)} for c, p, t in r["X"]), key=ordre)
                cands = cands[:int(maximum)]
                for c in cands:
                    tt = "[" + ",".join(f"{a}-{v!r}" for a, v in c["traits"].items()) + "]"
                    c["p"] = janus.query_once("atom_to_term(A, _T, _), decision:p_catalogue(_T, P)", {"A": tt})["P"]
                terme = "[" + ",".join(f"c({atome(c['code'])}, {c['p']!r}, [prof-{c['traits'].get('prof', 0)}])"
                                       for c in cands) + "]"
                ret = janus.query_once("atom_to_term(A, _C, _), decision:retenus(_C, X)", {"A": terme})["X"]
                cle = (lambda c: c["p"] * (c["traits"].get("prof", 0) + 1)) if critere == "esperance" else \
                    (lambda c: c["p"])
                cands.sort(key=lambda c: (-cle(c), c["code"]))
                ligne["codes"] = [{"code": c["code"], "statut": "retenu" if c["code"] in ret else "candidat",
                                   "p_catalogue": round(c["p"], 4),
                                   **({"preuve": preuve(janus, c, ret)} if c["code"] in ret else {})}
                                  for c in cands]
            except Exception as e:
                ligne["erreur"] = f"{type(e).__name__}: {str(e)[:200]}"
                ligne["codes"] = []
                erreurs += 1
            out.write(json.dumps(ligne, ensure_ascii=False) + "\n")
            n += 1
    print(json.dumps({"images": n, "erreurs": erreurs, "reglage": [k, seuil, critere],
                      "s_par_image": round((time.time() - t0) / max(n, 1), 3)}))


if __name__ == "__main__":
    if len(sys.argv) not in (5, 6, 7, 8):
        raise SystemExit(__doc__)
    main(*sys.argv[1:])
