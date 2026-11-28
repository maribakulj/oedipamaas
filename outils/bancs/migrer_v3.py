"""La migration des cas vers le schéma 3 (docs/BANCS_PHASE1.md, § 9 ; décisions de la propriétaire du 28/11, § 6).

    python3 outils/bancs/migrer_v3.py DEV_DIR V1_DIR SORTIE_DIR

Purement additive : rien n'est effacé. Pour chaque cas et chaque variante :
  - `statuts_relatifs` : le statut actuel (`statut_attendu`, ses hypothèses, sa decision_ouverte) devient un statut
    RELATIF, étiqueté par la version des connaissances, du langage, de la représentation et de la sémantique. C'est la
    convention historique K0-d30, non la sémantique cible ;
  - `historique.v1` : le statut de la version 1 (avant relecture), s'il existe ;
  - `statut_attendu` est gardé tel quel (compatibilité du validateur) ;
  - le statut de référence (a) n'est PAS écrit ici : il vient de la double annotation et de l'adjudication."""
import json, os, sys

K0 = {"nom": "K0-d30", "convention": "historique, non la sémantique cible",
      "connaissances": "WordNet 3.0 (hyperonymie, instance, partie) et WOLF par OMW 1.4, tous leurs sens ; les connaissances écrites du cas",
      "langage": "assertions v1 et requêtes UCQ sans négation (noyau 0.3)",
      "representation": "implicite : jugée par les rédacteurs, sans graphe ni requête de référence écrits",
      "semantique": "D30 lue à la lettre (docs/BANCS_PHASE1.md, § 4.1, règles provisoires du 27-28/11) : type lemme de la définition, tous les sens du mot du texte, relations hors de K",
      "date": "2026-11-28"}


def relatif(x):
    r = {"K": "K0-d30", "statut": x.get("statut_attendu"), "hypotheses": x.get("hypotheses_attendues", [])}
    if x.get("decision_ouverte"):
        r["decision_ouverte"] = x["decision_ouverte"]
    return r


def main():
    dev, v1d, sortie = sys.argv[1:4]
    for f in sorted(os.listdir(dev)):
        if not f.endswith(".json"):
            continue
        cas = json.load(open(os.path.join(dev, f)))
        p1 = os.path.join(v1d, f)
        v1 = {c["id"]: c for c in json.load(open(p1))} if os.path.exists(p1) else {}
        for c in cas:
            c["schema"] = 3
            c["statuts_relatifs"] = [relatif(c)]
            o = v1.get(c["id"])
            if o:
                c.setdefault("historique", {})["v1"] = {"statut": o.get("statut_attendu"),
                                                        "hypotheses": o.get("hypotheses_attendues", []),
                                                        "sorte": o.get("sorte")}
            for i, v in enumerate(c["variantes"]):
                v["statuts_relatifs"] = [relatif(v)]
                if o and i < len(o.get("variantes", [])) and o["variantes"][i].get("description") == v.get("description"):
                    v.setdefault("historique", {})["v1"] = {"statut": o["variantes"][i].get("statut_attendu")}
        json.dump(cas, open(os.path.join(sortie, f), "w"), ensure_ascii=False, indent=1)
    json.dump({"K0-d30": K0}, open(os.path.join(sortie, "K.json"), "w"), ensure_ascii=False, indent=1)


if __name__ == "__main__":
    main()
