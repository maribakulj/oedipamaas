"""Textes français pour le jugement J2 : un tirage des notices de la base Joconde (musées de France, Licence Ouverte
v2.0, data.gouv.fr jeu 5b448216a3a729752eb11d6f). Le fichier (≈ 1,25 Go) est lu en flux, sans être stocké ; une notice
est gardée si l'empreinte de sa référence tombe sous le seuil (tirage stable, sans aléa) et si elle a un titre.

Ces notices n'ont pas de codes Iconclass (Joconde indexe avec le thésaurus Garnier) : elles servent à juger la
précision des codes établis, pas à mesurer le rappel. Le champ « sujet » (Garnier) est gardé pour information.

Usage : python outils/moisson/joconde.py SORTIE.jsonl [--part 0.005]
"""
import argparse
import codecs
import csv
import datetime
import hashlib
import json
import sys
import urllib.request

URL = "https://ministere-culture.s3.sbg.io.cloud.ovh.net/POP/joconde.csv"
AGENT = "oedipamaas-moisson/0.1 (offline Iconclass evaluation)"


def lignes(url):
    req = urllib.request.Request(url, headers={"User-Agent": AGENT})
    with urllib.request.urlopen(req, timeout=600) as r:
        yield from codecs.iterdecode(r, "utf-8", errors="replace")


def main(sortie, part=0.005):
    csv.field_size_limit(10 ** 8)
    seuil = int(part * 2 ** 32)
    lus = gardes = 0
    debut = datetime.datetime.now(datetime.timezone.utc).isoformat(timespec="seconds")
    with open(sortie, "w", encoding="utf-8") as out:
        lecteur = csv.DictReader(lignes(URL), delimiter="|")
        for d in lecteur:
            lus += 1
            ref = (d.get("Reference") or "").strip()
            titre = (d.get("Titre") or "").strip()
            if not ref or not titre:
                continue
            if int(hashlib.sha256(ref.encode()).hexdigest()[:8], 16) >= seuil:
                continue
            o = {"id": f"joconde:{ref}", "titre": titre,
                 "description": (d.get("Description") or "").strip(),
                 "precisions_sujet": (d.get("Precisions_sujets_representes") or "").strip(),
                 "sujet_garnier": (d.get("Sujet_Represente") or "").strip(),
                 "domaine": (d.get("Domaine") or "").strip(), "musee": (d.get("Nom_officiel_musee") or "").strip()}
            out.write(json.dumps(o, ensure_ascii=False, sort_keys=True) + "\n")
            gardes += 1
            if lus % 100000 == 0:
                print(f"  {lus} lues, {gardes} gardées", file=sys.stderr)
    m = {"date": debut, "source": URL, "licence": "Licence Ouverte v2.0", "part": part, "lues": lus, "gardees": gardes}
    with open(sortie.rsplit(".", 1)[0] + ".manifeste.json", "w", encoding="utf-8") as f:
        json.dump(m, f, ensure_ascii=False, indent=1)
    print(json.dumps(m, ensure_ascii=False))


if __name__ == "__main__":
    a = argparse.ArgumentParser(description=__doc__.split("\n")[0])
    a.add_argument("sortie")
    a.add_argument("--part", type=float, default=0.005)
    x = a.parse_args()
    main(x.sortie, x.part)
