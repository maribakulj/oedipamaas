"""Construit des lexiques normalisés (TSV) à partir des ressources téléchargées.

Usage : python3 -I outils/ressources/lexiques.py [nom ...]
Sortie : /home/user/donnees/mesure_ressources_lexicales/lexiques/<nom>.tsv
Colonnes : forme, pos (n/v/a/r pour WordNet ; x pour un thésaurus), cible, note.

Les fichiers source sont des données non sûres : ils sont seulement lus
(bz2/zip/XML/Turtle/texte), jamais exécutés. Le Turtle de DBnary et
d'Opentheso est lu bloc par bloc avec des expressions régulières (pas de
bibliothèque RDF disponible) ; seuls les triplets utiles sont retenus.
"""
import bz2
import codecs
import json
import os
import re
import sys
import zipfile
import xml.etree.ElementTree as ET
from collections import defaultdict, Counter

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from commun import RESSOURCES, LEXIQUES, WordNet, norm, sans_qualificatif, singuliers  # noqa: E402

os.makedirs(LEXIQUES, exist_ok=True)
STATS = {}


def ecrire(nom, lignes, entete):
    p = os.path.join(LEXIQUES, nom + ".tsv")
    n = 0
    with open(p, "w", encoding="utf-8") as f:
        f.write("# " + entete + "\n")
        for l in lignes:
            f.write("\t".join(x.replace("\t", " ").replace("\n", " ") for x in l) + "\n")
            n += 1
    print(nom, n, "lignes", file=sys.stderr)
    STATS[nom] = n


def turtle_str(s):
    """Décode les échappements d'un littéral Turtle."""
    if "\\" not in s:
        return s
    try:
        return codecs.decode(s.encode("utf-8").decode("unicode_escape").encode("latin-1"), "utf-8")
    except Exception:
        return re.sub(r"\\u([0-9A-Fa-f]{4})", lambda m: chr(int(m.group(1), 16)), s).replace('\\"', '"')


def blocs_turtle(chemin):
    """Itère sur les blocs (séparés par une ligne vide) d'un Turtle « joli »."""
    op = bz2.open if chemin.endswith(".bz2") else open
    with op(chemin, "rt", encoding="utf-8", errors="replace") as f:
        buf = []
        for l in f:
            if l.strip() == "":
                if buf:
                    yield "".join(buf)
                    buf = []
            else:
                buf.append(l)
        if buf:
            yield "".join(buf)


# ------------------------------------------------------------------ WOLF
def wolf():
    p = os.path.join(RESSOURCES, "omw", "omw-1.4", "fra", "wn-data-fra.tab")
    out = []
    for l in open(p, encoding="utf-8"):
        if l.startswith("#"):
            continue
        sid, rel, lem = l.rstrip("\n").split("\t")
        if rel != "fra:lemma":
            continue
        pp = sid[-1]
        pp = "a" if pp == "s" else pp
        out.append((lem, pp, sid[:-1] + pp, ""))
    ecrire("wolf", out, "WOLF dans OMW 1.4 (wn-data-fra.tab), CeCILL-C")


# ------------------------------------------------------------------ WoNeF
def wonef():
    for court, v in [("p", "precision"), ("f", "fscore"), ("c", "coverage")]:
        p = os.path.join(RESSOURCES, "wonef", "wonef-%s-0.1.xml.bz2" % v)
        out = []
        with bz2.open(p) as f:
            for ev, el in ET.iterparse(f, events=("end",)):
                if el.tag != "SYNSET":
                    continue
                sid = el.findtext("ID") or ""
                m = re.match(r"eng-30-(\d{8})-([nvarb])", sid)
                if m:
                    pp = {"b": "r"}.get(m.group(2), m.group(2))
                    for lit in el.iter("LITERAL"):
                        t = (lit.text or "").strip()
                        if t and t != "_EMPTY_":
                            out.append((t, pp, m.group(1) + "-" + pp, lit.get("lnote", "")))
                el.clear()
        ecrire("wonef_" + court, out, "WoNeF 0.1 %s (wonef.fr) ; note = lnote (sélecteurs)" % v)


# ------------------------------------------------------------------ DBnary
POS_LEXINFO = {"noun": "n", "properNoun": "n", "verb": "v", "adjective": "a", "adverb": "r"}
RE_LABEL = re.compile(r'rdfs:label\s+"((?:[^"\\]|\\.)*)"@(\w+)')
RE_POS = re.compile(r"lexinfo:partOfSpeech\s+lexinfo:(\w+)")
RE_WF = re.compile(r'dbnary:writtenForm\s+"((?:[^"\\]|\\.)*)"@([\w-]+)')
RE_TGT = re.compile(r"dbnary:targetLanguage\s+lexvo:(\w+)")
RE_OF = re.compile(r"dbnary:isTranslationOf\s+(\S+?)\s*[;.]")
RE_SENSES = re.compile(r"ontolex:sense\s+([^;.]*(?:\s*,\s*[^;.]*)*)")
RE_WS = re.compile(r"^(\w+):__ws_\d+[a-z]?_(.*)$")


def entree_de(x):
    m = RE_WS.match(x)
    return m.group(1) + ":" + m.group(2) if m else x


def dbnary_lire(chemin, langue_cible, lang_label):
    entrees = {}
    trads = []
    for b in blocs_turtle(chemin):
        sujet = b.split(None, 1)[0] if b.strip() else ""
        if "ontolex:LexicalEntry" in b and "rdfs:label" in b:
            m = RE_LABEL.search(b)
            mp = RE_POS.search(b)
            if m and m.group(2) == lang_label:
                nsens = 0
                ms = RE_SENSES.search(b)
                if ms:
                    nsens = ms.group(1).count("__ws_")
                entrees[sujet] = (turtle_str(m.group(1)), mp.group(1) if mp else "", nsens)
        elif "dbnary:Translation" in b:
            mt = RE_TGT.search(b)
            if not mt or mt.group(1) != langue_cible:
                continue
            mw = RE_WF.search(b)
            mo = RE_OF.search(b)
            if mw and mo:
                trads.append((entree_de(mo.group(1)), turtle_str(mw.group(1))))
    return entrees, trads


def dbnary():
    wn = WordNet()
    d = os.path.join(RESSOURCES, "dbnary")
    ent_fr, tr_fr = dbnary_lire(os.path.join(d, "fr_dbnary_ontolex.ttl.bz2"), "eng", "fr")
    print("fr: entrées", len(ent_fr), "traductions vers en", len(tr_fr), file=sys.stderr)
    ent_en, tr_en = dbnary_lire(os.path.join(d, "en_dbnary_ontolex.ttl.bz2"), "fra", "en")
    print("en: entrées", len(ent_en), "traductions vers fr", len(tr_en), file=sys.stderr)
    lex = []
    for eid, (lab, pos, ns) in ent_fr.items():
        p = POS_LEXINFO.get(pos)
        if p:
            lex.append((lab, p, eid, "sens=%d;pos=%s" % (ns, pos)))
    ecrire("dbnary_lex", lex, "DBnary fr : entrées lexicales (lemme, pos), note = nombre de sens Wiktionnaire")
    # paires (fr, p) -> {en: directions}
    paires = defaultdict(lambda: defaultdict(set))
    for eid, en in tr_fr:
        if eid in ent_fr:
            lab, pos, _ = ent_fr[eid]
            p = POS_LEXINFO.get(pos)
            if p:
                paires[(lab, p)][en.strip()].add("fr>en")
    for eid, fr in tr_en:
        if eid in ent_en:
            lab, pos, _ = ent_en[eid]
            p = POS_LEXINFO.get(pos)
            if p:
                fr = re.sub(r"^(le|la|les|l'|un|une)\s+", "", fr.strip())
                paires[(fr, p)][lab.strip()].add("en>fr")
    trad, brut, filtre = [], [], []
    for (fr, p), ens in paires.items():
        par_syn = defaultdict(set)
        mono = set()
        for en, dirs in ens.items():
            trad.append((fr, p, en, ",".join(sorted(dirs))))
            ss = wn.synsets(en, p)
            for s in ss:
                par_syn[s].add(en)
            if len(ss) == 1:
                mono.add(ss[0])
        for s, ens_s in par_syn.items():
            note = "en=" + "|".join(sorted(ens_s))
            brut.append((fr, p, s, note))
            if s in mono or len(ens_s) >= 2:
                filtre.append((fr, p, s, note + (";mono" if s in mono else ";multi")))
    ecrire("dbnary_trad", trad, "DBnary : paires de traduction fr-en (fr>en : Wiktionnaire fr ; en>fr : Wiktionnaire en)")
    ecrire("dbnary_brut", brut, "DBnary pivot brut : tous les synsets WordNet des traductions anglaises")
    ecrire("dbnary_filtre", filtre, "DBnary pivot filtré : synset atteint par >=2 traductions, ou traduction monosémique")


# ------------------------------------------------------------------ Joconde
RE_CONCEPT = re.compile(r"^<([^>]+)>\s+a\s+skos:Concept")
RE_LAB = re.compile(r'skos:(prefLabel|altLabel)\s+((?:"(?:[^"\\]|\\.)*"@[\w-]+\s*,?\s*)+)')
RE_LIT = re.compile(r'"((?:[^"\\]|\\.)*)"@([\w-]+)')


def joconde():
    """15 listes Joconde -> joconde_listes ; th285 (Représentation, structure
    du thésaurus Garnier enrichie) -> garnier_th285.

    Les PDF du Garnier (culture.gouv.fr) sont des images numérisées sans
    couche texte : la version exploitable du Garnier est la liste th285.
    """
    d = os.path.join(RESSOURCES, "joconde_vocabulaires")
    sorties = {"joconde_listes": [], "garnier_th285": []}
    for f in sorted(os.listdir(d)):
        if not f.endswith(".ttl"):
            continue
        th = f[:-4]
        out = sorties["garnier_th285" if th == "th285" else "joconde_listes"]
        for b in blocs_turtle(os.path.join(d, f)):
            m = RE_CONCEPT.match(b)
            if not m:
                continue
            for ml in RE_LAB.finditer(b):
                for lit in RE_LIT.finditer(ml.group(2)):
                    if lit.group(2).startswith("fr"):
                        t = turtle_str(lit.group(1))
                        out.append((t, "x", m.group(1), th + ":" + ml.group(1)))
                        t2 = sans_qualificatif(t)
                        if t2 and t2 != t:
                            out.append((t2, "x", m.group(1), th + ":" + ml.group(1) + ":sans_qualif"))
    ecrire("joconde_listes", sorties["joconde_listes"],
           "15 listes d'autorités Joconde (Opentheso th284-th306 sauf th285, Licence ouverte) ; note = liste:type")
    ecrire("garnier_th285", sorties["garnier_th285"],
           "Liste Représentation - Joconde (th285) = thésaurus Garnier enrichi, Licence ouverte")


# ------------------------------------------------------------------ Iconclass
def iconclass():
    d = os.path.join(RESSOURCES, "iconclass", "kw", "fr")
    out = []
    for f in sorted(os.listdir(d)):
        for l in open(os.path.join(d, f), encoding="utf-8"):
            if "|" in l:
                notation, kw = l.rstrip("\n").split("|", 1)
                kw = kw.strip()
                if kw:
                    out.append((kw, "x", notation, f))
    ecrire("iconclass_kw", out, "Iconclass, mots-clés français (kw/fr), CC0")


# ------------------------------------------------------------------ AAT
def aat():
    wn = WordNet()
    z = zipfile.ZipFile(os.path.join(RESSOURCES, "aat", "explicit.zip"))
    lit = {}
    pref = {}
    liens = []
    rx = re.compile(rb'^<([^>]+)> <([^>]+)> (.*) \.\s*$')
    for l in z.open("AATOut_2Terms.nt"):
        m = rx.match(l)
        if not m:
            continue
        s, p, o = m.group(1).decode(), m.group(2).decode(), m.group(3).decode()
        if p.endswith("#term") and s.startswith("http://vocab.getty.edu/aat/term/"):
            mo = re.match(r'"(.*)"@([\w-]+)$', o)
            if mo:
                lit[s] = (turtle_str(mo.group(1)), mo.group(2))
        elif p.endswith("skos-xl#prefLabel") or p.endswith("skos-xl#altLabel"):
            liens.append((s, o.strip("<>"), "pref" if "pref" in p else "alt"))
    par_concept = defaultdict(lambda: {"fr": [], "en": []})
    for c, t, typ in liens:
        if t in lit:
            forme, lg = lit[t]
            lg2 = lg.split("-")[0]
            if lg2 in ("fr", "en") and not forme.startswith("<"):
                par_concept[c][lg2].append((forme, typ))
    fr_out, piv = [], []
    for c, d in par_concept.items():
        cid = c.rsplit("/", 1)[-1]
        if not d["fr"]:
            continue
        syns = set()
        for en, _ in d["en"]:
            syns.update(wn.synsets(sans_qualificatif(en), "n"))
        for forme, typ in d["fr"]:
            f0 = sans_qualificatif(forme)
            for v in singuliers(f0.lower() if not f0[:1].isupper() else f0):
                fr_out.append((v, "x", "aat:" + cid, typ + (";sing" if v != f0 else "")))
                for s in syns:
                    piv.append((v, "n", s, "aat:" + cid))
    ecrire("aat_fr", fr_out, "AAT (Getty, ODC-By 1.0), termes français ; variantes singulières grossières")
    ecrire("aat_pivot", piv, "AAT pivot : terme fr -> concept AAT -> termes anglais -> synsets WordNet (n)")
    STATS["aat_concepts_fr"] = len(par_concept) and sum(1 for d in par_concept.values() if d["fr"])
    STATS["aat_concepts"] = len(par_concept)


if __name__ == "__main__":
    taches = {"wolf": wolf, "wonef": wonef, "dbnary": dbnary, "joconde": joconde,
              "iconclass": iconclass, "aat": aat}
    noms = sys.argv[1:] or list(taches)
    for n in noms:
        taches[n]()
    p = os.path.join(LEXIQUES, "stats_%s.json" % "_".join(noms))
    json.dump(STATS, open(p, "w"), indent=1, ensure_ascii=False)
