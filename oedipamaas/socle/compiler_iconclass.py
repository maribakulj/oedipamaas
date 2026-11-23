"""Compile le dépôt iconclass/data en faits Prolog (socle 1.0, pièce 2). Transcription sans jugement : chaque fait
reprend un champ des fichiers du dépôt ; les règles (parent canonique, jumeaux, décomposition des libellés) sont en
Prolog (arbre.pl, libelles.pl).

Faits écrits dans iconclass.pl (module iconclass) :
  n(N)                        notation de base (champ N de notations.txt)
  enfant(P, N, Rang)          N cité comme enfant de P (champ C), dans l'ordre du fichier
  famille_cle(N, K)           famille de clés valable pour N (champ K)
  renvoi(N, M)                renvoi de N vers M (champ R)
  equivalent(N, M)            champ T (non documenté ; une occurrence)
  libelle(N, Langue, Texte)   txt/<langue>/txt_<langue>_*.txt (hors fichiers de clés)
  libelle_hors_arbre(N, Langue, Texte)   libellés sans enregistrement dans notations.txt (scènes de Shakespeare)
  mot_cle(N, Langue, Mot)     kw/<langue>/kw_<langue>_*.txt
  suffixe_cle(K, S, Rang)     suffixes de chaque famille (keys.txt, champs K, S et suites)
  libelle_cle(K, S, Langue, Texte)       txt/<langue>/txt_<langue>_keys.txt
  mot_cle_cle(K, S, Langue, Mot)         kw/<langue>/kw_<langue>_keys.txt
  renvoi_mot(Langue, Mot1, Relation, Mot2)   kw/<langue>/kw_<langue>_refs.txt (see, see also)
Écrit aussi manifeste.json : commit du dépôt, comptes par fait, empreinte du fichier.
Usage : python -m oedipamaas.socle.compiler_iconclass DEPOT_ICONCLASS SORTIE/"""
import hashlib
import json
import subprocess
import sys
from collections import Counter, defaultdict
from pathlib import Path


def q(s):
    """Atome Prolog entre apostrophes."""
    return "'" + s.replace("\\", "\\\\").replace("'", "\\'").replace("\n", "\\n") + "'"


def commit(depot):
    f = depot / "COMMIT"
    if f.exists():
        return f.read_text().strip()
    r = subprocess.run(["git", "-C", str(depot), "rev-parse", "HEAD"], capture_output=True, text=True, check=True)
    return r.stdout.strip()


def enregistrements(chemin):
    """Enregistrements « champ valeur » séparés par « $ » ; valeurs multiples sur des lignes « ; »."""
    rec, champ = {}, None
    for ligne in chemin.read_text(encoding="utf-8").splitlines():
        if ligne == "$":
            if rec:
                yield rec
            rec, champ = {}, None
        elif ligne.startswith("; ") and champ:
            rec[champ].append(ligne[2:])
        elif len(ligne) > 2 and ligne[1] == " " and ligne[0].isalpha():
            champ = ligne[0]
            rec.setdefault(champ, []).append(ligne[2:])
        elif ligne.startswith(("KW1 ", "REF ", "KW2 ")):
            champ = ligne[:3]
            rec.setdefault(champ, []).append(ligne[4:])
    if rec:
        yield rec


def paires(chemin):
    for ligne in chemin.read_text(encoding="utf-8").splitlines():
        if ligne.startswith("#") or "|" not in ligne:
            continue
        c, t = ligne.split("|", 1)
        if c.strip() and t.strip():
            yield c.strip(), t.strip()


def compiler(depot, sortie):
    depot, sortie = Path(depot), Path(sortie)
    sortie.mkdir(parents=True, exist_ok=True)
    faits, vus = defaultdict(list), set()
    for r in enregistrements(depot / "notations.txt"):
        n = r["N"][0]
        if n not in vus:
            vus.add(n)
            faits["n"].append(f"n({q(n)}).")
        for rang, e in enumerate(r.get("C", [])):
            faits["enfant"].append(f"enfant({q(n)}, {q(e)}, {rang}).")
        for k in r.get("K", []):
            faits["famille_cle"].append(f"famille_cle({q(n)}, {q(k)}).")
        for m in r.get("R", []):
            faits["renvoi"].append(f"renvoi({q(n)}, {q(m)}).")
        for m in r.get("T", []):
            faits["equivalent"].append(f"equivalent({q(n)}, {q(m)}).")
    familles = []
    for r in enregistrements(depot / "keys.txt"):
        k = r["K"][0]
        familles.append(k)
        for rang, s in enumerate(r.get("S", [])):
            faits["suffixe_cle"].append(f"suffixe_cle({q(k)}, {q(s)}, {rang}).")
    familles.sort(key=len, reverse=True)

    def famille_et_suffixe(code):
        for k in familles:                      # la plus longue famille qui préfixe le code
            if code.startswith(k):
                return k, code[len(k):]
        return None, None

    sans_famille = Counter()
    for dossier, pred, pred_cle in (("txt", "libelle", "libelle_cle"), ("kw", "mot_cle", "mot_cle_cle")):
        for d in sorted((depot / dossier).iterdir()):
            if not d.is_dir():
                continue
            langue = d.name
            for f in sorted(d.glob("*.txt")):
                if f.name.endswith("_refs.txt"):
                    for r in enregistrements(f):
                        for k1, rel, k2 in zip(r.get("KW1", []), r.get("REF", []), r.get("KW2", [])):
                            faits["renvoi_mot"].append(f"renvoi_mot({q(langue)}, {q(k1)}, {q(rel)}, {q(k2)}).")
                    continue
                cles = f.name.endswith("_keys.txt")
                hors = f.name.endswith("_shakespeare.txt")
                for c, t in paires(f):
                    if cles:
                        k, s = famille_et_suffixe(c)
                        if k is None:
                            sans_famille[f.name] += 1
                            continue
                        faits[pred_cle].append(f"{pred_cle}({q(k)}, {q(s)}, {q(langue)}, {q(t)}).")
                    elif hors and c not in vus:
                        faits["libelle_hors_arbre"].append(f"libelle_hors_arbre({q(c)}, {q(langue)}, {q(t)}).")
                    else:
                        faits[pred].append(f"{pred}({q(c)}, {q(langue)}, {q(t)}).")
    ordre = ("n", "enfant", "famille_cle", "renvoi", "equivalent", "libelle", "libelle_hors_arbre", "mot_cle",
             "suffixe_cle", "libelle_cle", "mot_cle_cle", "renvoi_mot")
    arites = {"n": 1, "enfant": 3, "famille_cle": 2, "renvoi": 2, "equivalent": 2, "libelle": 3,
              "libelle_hors_arbre": 3, "mot_cle": 3, "suffixe_cle": 3, "libelle_cle": 4, "mot_cle_cle": 4,
              "renvoi_mot": 4}
    entete = [":- module(iconclass, [" + ", ".join(f"{p}/{arites[p]}" for p in ordre) + "]).",
              ":- encoding(utf8).", ":- discontiguous " + ", ".join(f"{p}/{arites[p]}" for p in ordre) + "."]
    for p in ordre:
        if not faits[p]:
            entete.append(f":- dynamic {p}/{arites[p]}.")
    chemin = sortie / "iconclass.pl"
    with open(chemin, "w", encoding="utf-8") as out:
        out.write("\n".join(entete) + "\n")
        for p in ordre:
            out.write("\n".join(faits[p]) + ("\n" if faits[p] else ""))
    manifeste = {"source": "iconclass/data", "commit": commit(depot),
                 "comptes": {p: len(faits[p]) for p in ordre},
                 "suffixes_de_cle_sans_famille": dict(sans_famille),
                 "sha256": {"iconclass.pl": hashlib.sha256(chemin.read_bytes()).hexdigest()}}
    (sortie / "manifeste-iconclass.json").write_text(json.dumps(manifeste, ensure_ascii=False, indent=1) + "\n",
                                                     encoding="utf-8")
    return manifeste


if __name__ == "__main__":
    if len(sys.argv) != 3:
        raise SystemExit(__doc__)
    m = compiler(*sys.argv[1:])
    print(json.dumps(m["comptes"]), m["suffixes_de_cle_sans_famille"])
