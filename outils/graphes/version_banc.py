"""Une nouvelle version du banc, par errata (27/11) : les erreurs manifestes des références sont corrigées dans des
fichiers nouveaux ; les fichiers de la version précédente et les mesures faites sur elle ne changent pas.

Usage : python outils/graphes/version_banc.py ERRATA.json DOSSIER_SORTIE JEU=REFERENCE.json,REQUETES.json …

ERRATA.json : {"version", "principe", "non_corrige": [...], "errata": [{"id", "jeu", "k", "genre" (ou "*"), "objet",
"operation", "element", "avant", "apres", "raison", "nature"}]} avec :
  objet graphe,  operation predicat  : le prédicat de l'événement `element` passe de `avant` à `apres` ;
  objet requete, operation remplacer : la requête de référence de la fiche k passe de `avant` à `apres`
                                       ({"suffisante", "necessaire"}) ;
  objet fiche,   operation contester : le texte (k, genre) n'est plus compté (outils/croise/tableaux.py --errata).
Contrôles (un seul défaut, et rien n'est écrit) : chaque erratum s'applique exactement là où il le dit, et `avant`
est bien la valeur trouvée ; aucun erratum n'est appliqué deux fois.
Écrit, dans DOSSIER_SORTIE : reference_JEU_VERSION.json, requetes_reference_JEU_VERSION.json, et
journal_VERSION.json (chaque erratum appliqué, avec ses valeurs)."""
import copy
import json
import sys
from pathlib import Path


def charger(p):
    return json.loads(Path(p).read_text(encoding="utf-8"))


def appliquer(errata, jeux):
    defauts, journal = [], []
    sorties = {j: (copy.deepcopy(r), copy.deepcopy(q)) for j, (r, q) in jeux.items()}
    for e in errata["errata"]:
        if e["jeu"] not in sorties:
            defauts.append(f"{e['id']} : jeu inconnu {e['jeu']}")
            continue
        refs, reqs = sorties[e["jeu"]]
        if e["objet"] == "graphe" and e["operation"] == "predicat":
            gs = [g for g in refs if g["k"] == e["k"] and g["genre"] == e["genre"]]
            vs = [v for g in gs for v in g["evenements"] if v["id"] == e["element"]]
            if len(vs) != 1:
                defauts.append(f"{e['id']} : {len(vs)} événements {e['element']} pour ({e['k']}, {e['genre']})")
            elif vs[0]["predicat"] != e["avant"]:
                defauts.append(f"{e['id']} : prédicat {vs[0]['predicat']!r}, l'erratum attend {e['avant']!r}")
            else:
                vs[0]["predicat"] = e["apres"]
                journal.append(e)
        elif e["objet"] == "requete" and e["operation"] == "remplacer":
            qs = [q for q in reqs if q["k"] == e["k"]]
            if len(qs) != 1:
                defauts.append(f"{e['id']} : {len(qs)} requêtes pour la fiche {e['k']}")
            elif any(qs[0].get(c) != e["avant"][c] for c in e["avant"]):
                defauts.append(f"{e['id']} : la requête de la fiche {e['k']} n'est pas celle que l'erratum corrige")
            else:
                qs[0].update(e["apres"])
                qs[0]["erratum"] = e["id"]
                journal.append(e)
        elif e["objet"] == "fiche" and e["operation"] == "contester":
            if not any(g["k"] == e["k"] and g["genre"] == e["genre"] for g in refs):
                defauts.append(f"{e['id']} : aucun texte ({e['k']}, {e['genre']})")
            else:
                journal.append(e)
        else:
            defauts.append(f"{e['id']} : objet ou opération inconnus")
    ids = [e["id"] for e in errata["errata"]]
    defauts += [f"identifiant en double : {i}" for i in set(ids) if ids.count(i) > 1]
    return sorties, journal, defauts


def main():
    errata, sortie = charger(sys.argv[1]), Path(sys.argv[2])
    jeux = {}
    for a in sys.argv[3:]:
        j, fichiers = a.split("=", 1)
        r, q = fichiers.split(",")
        jeux[j] = (charger(r), charger(q))
    sorties, journal, defauts = appliquer(errata, jeux)
    if defauts:
        print("\n".join(defauts))
        raise SystemExit(1)
    v = errata["version"]
    sortie.mkdir(parents=True, exist_ok=True)
    for j, (r, q) in sorties.items():
        (sortie / f"reference_{j}_{v}.json").write_text(json.dumps(r, ensure_ascii=False, indent=1), encoding="utf-8")
        (sortie / f"requetes_reference_{j}_{v}.json").write_text(json.dumps(q, ensure_ascii=False, indent=1),
                                                                 encoding="utf-8")
    (sortie / f"journal_{v}.json").write_text(json.dumps({"version": v, "appliques": journal}, ensure_ascii=False,
                                                         indent=1), encoding="utf-8")
    print(f"{v} : {len(journal)} errata appliqués sur {len(sorties)} jeux")


if __name__ == "__main__":
    main()
