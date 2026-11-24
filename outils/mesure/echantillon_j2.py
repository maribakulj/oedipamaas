"""Échantillon du jugement J2 (cahier des charges, § 12.4) : 50 codes établis par type de preuve (T1, T2) et par langue,
au plus un par document, tirés par empreinte (sha256 de « J2|document|code ») : rejouable à l'identique.

Usage : python outils/mesure/echantillon_j2.py SORTIE.json (ENTREE.jsonl:SORTIE_MOTEUR.jsonl:LANGUE:SOURCE)...
Chaque argument associe un fichier d'entrée de la commande Prolog, sa sortie, la langue et un nom de source. Les codes
du catalogue ne sont pas copiés dans l'échantillon : le jugement porte sur le texte seul."""
import hashlib
import json
import sys


def charger(entree, sortie, langue, source):
    textes = {json.loads(l)["id"]: json.loads(l)["texte"] for l in open(entree, encoding="utf-8")}
    for l in open(sortie, encoding="utf-8"):
        d = json.loads(l)
        if "erreur" in d:
            continue
        for c in d["etablis"]:
            yield dict(doc=d["document"], langue=langue, source=source, texte=textes[d["document"]], code=c["code"],
                       type=c["type_preuve"], libelle_en=c["libelle"], premisses=c["preuve"]["premisses"])


def main(sortie, specs, n=50):
    pool = [x for s in specs for x in charger(*s.split(":", 3))]
    ech = []
    for langue in ("en", "fr"):
        for typ in ("T1", "T2"):
            cands = sorted((x for x in pool if x["langue"] == langue and x["type"] == typ),
                           key=lambda x: hashlib.sha256(f"J2|{x['doc']}|{x['code']}".encode()).hexdigest())
            vus, pris = set(), []
            for x in cands:
                if x["doc"] not in vus:
                    vus.add(x["doc"])
                    pris.append(x)
                if len(pris) == n:
                    break
            ech += pris
    for i, x in enumerate(ech, 1):
        x["n"] = i
    json.dump(ech, open(sortie, "w", encoding="utf-8"), ensure_ascii=False)
    print(len(ech))


if __name__ == "__main__":
    main(sys.argv[1], sys.argv[2:])
