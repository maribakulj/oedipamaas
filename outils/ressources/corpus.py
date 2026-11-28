"""Tire les corpus indépendants des bancs et les lemmatise avec Stanza.

Usage : python3 -I outils/ressources/corpus.py [joconde] [iconclass]
Corpus :
  - joconde : notices de /home/user/donnees/joconde/tirage3.jsonl (export POP,
    Licence ouverte), en excluant tout identifiant déjà présent dans
    entree.jsonl, entree_desc.jsonl et tirage.jsonl (déjà passés dans les
    mesures J0/J1 du moteur). Deux strates tirées avec la graine 20261128 :
    1 200 notices dont la description a >= 15 mots, 800 autres notices, au plus
    60 notices par musée (sinon les albums du Louvre font 30 % du tirage).
    Texte = titre + description + précisions sur le sujet. Le champ
    « sujet_garnier » (indexation par le thésaurus Garnier) et « domaine »
    (liste DOMN) sont EXCLUS : ce sont des vocabulaires mesurés.
  - iconclass : 2 500 libellés français tirés (graine 20261128) parmi les
    notations de base (txt/fr hors clés).
Aucun fichier sous /home/user/donnees/bancs_phase1 n'est lu.
Sortie : /home/user/donnees/mesure_ressources_lexicales/corpus/
"""
import hashlib
import json
import os
import random
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from commun import DONNEES, RESSOURCES, SORTIE  # noqa: E402

GRAINE = 20261128
PLAFOND_MUSEE = 60
OUT = os.path.join(SORTIE, "corpus")
os.makedirs(OUT, exist_ok=True)


def tirer_joconde():
    d = os.path.join(DONNEES, "joconde")
    exclus = set()
    for f in ["entree.jsonl", "entree_desc.jsonl", "tirage.jsonl"]:
        for l in open(os.path.join(d, f), encoding="utf-8"):
            exclus.add(json.loads(l)["id"])
    longs, courts = [], []
    for l in open(os.path.join(d, "tirage3.jsonl"), encoding="utf-8"):
        r = json.loads(l)
        if r["id"] in exclus:
            continue
        titre = r.get("titre") or ""
        if titre.isupper():
            titre = titre.capitalize()
        parts = [x.strip() for x in [titre, r.get("description") or "", r.get("precisions_sujet") or ""] if x and x.strip()]
        if not parts:
            continue
        texte = ". ".join(p.rstrip(".") for p in parts) + "."
        (longs if len((r.get("description") or "").split()) >= 15 else courts).append((r["id"], texte, r.get("musee") or "?"))
    longs.sort(); courts.sort()
    rnd = random.Random(GRAINE)
    # Plafond par musée (PLAFOND_MUSEE notices au total) : sans lui, les albums
    # de dessins du Louvre font 30 % de l'échantillon (premier tirage, écarté).
    par_musee = {}
    choix = []
    for pool, n in ((longs, 1200), (courts, 800)):
        ordre = pool[:]
        rnd.shuffle(ordre)
        pris = 0
        for i, t, m in ordre:
            if par_musee.get(m, 0) >= PLAFOND_MUSEE:
                continue
            par_musee[m] = par_musee.get(m, 0) + 1
            choix.append((i, t))
            pris += 1
            if pris == n:
                break
    vus, docs = set(), []
    for i, t in choix:
        if t in vus:
            continue
        vus.add(t)
        docs.append({"id": i, "corpus": "joconde", "texte": t})
    return docs, {"eligibles_longs": len(longs), "eligibles_courts": len(courts), "exclus": len(exclus),
                  "plafond_par_musee": PLAFOND_MUSEE, "musees": len(par_musee)}


def tirer_iconclass():
    d = os.path.join(RESSOURCES, "iconclass", "txt", "fr")
    lignes = []
    for f in sorted(os.listdir(d)):
        if "keys" in f:
            continue
        for l in open(os.path.join(d, f), encoding="utf-8"):
            if "|" in l:
                n, t = l.rstrip("\n").split("|", 1)
                if t.strip():
                    lignes.append((n, t.strip()))
    lignes.sort()
    rnd = random.Random(GRAINE)
    choix = rnd.sample(lignes, 2500)
    return [{"id": "iconclass:" + n, "corpus": "iconclass", "texte": t} for n, t in choix], {"eligibles": len(lignes)}


def lemmatiser(docs, chemin):
    import stanza
    nlp = stanza.Pipeline("fr", dir=os.path.join(DONNEES, "stanza"), processors="tokenize,mwt,pos,lemma",
                          download_method=None, verbose=False)
    with open(chemin, "w", encoding="utf-8") as f:
        lot = 64
        for k in range(0, len(docs), lot):
            part = docs[k:k + lot]
            res = nlp.bulk_process([stanza.Document([], text=d["texte"]) for d in part])
            for d, doc in zip(part, res):
                phrases = []
                for s in doc.sentences:
                    phrases.append({"texte": s.text,
                                    "mots": [[w.text, w.lemma or w.text, w.upos] for w in s.words]})
                f.write(json.dumps({"id": d["id"], "corpus": d["corpus"], "phrases": phrases}, ensure_ascii=False) + "\n")
            print(k + len(part), "/", len(docs), file=sys.stderr)


if __name__ == "__main__":
    jd, js = tirer_joconde()
    idocs, ist = tirer_iconclass()
    man = {"graine": GRAINE, "joconde": dict(js, documents=len(jd)), "iconclass": dict(ist, documents=len(idocs))}
    for nom, docs in [("joconde", jd), ("iconclass", idocs)]:
        p = os.path.join(OUT, nom + "_textes.jsonl")
        with open(p, "w", encoding="utf-8") as f:
            for d in docs:
                f.write(json.dumps(d, ensure_ascii=False) + "\n")
        man[nom]["sha256_textes"] = hashlib.sha256(open(p, "rb").read()).hexdigest()
        man[nom]["mots_espaces"] = sum(len(d["texte"].split()) for d in docs)
    import stanza
    man["stanza"] = stanza.__version__
    json.dump(man, open(os.path.join(OUT, "manifeste.json"), "w"), indent=1, ensure_ascii=False)
    print(json.dumps(man, indent=1, ensure_ascii=False), file=sys.stderr)
    a_faire = sys.argv[1:] or ["joconde", "iconclass"]
    for nom, docs in [("joconde", jd), ("iconclass", idocs)]:
        if nom in a_faire:
            lemmatiser(docs, os.path.join(OUT, nom + "_stanza.jsonl"))
