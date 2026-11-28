"""Fonctions communes de la mesure des ressources lexicales françaises.

Lecture seule : ce module ne fait que lire les ressources téléchargées
(données non sûres, jamais exécutées) et WordNet 3.0. Les scripts qui
l'importent doivent être lancés avec `python3 -I` ; ils ajoutent eux-mêmes
leur propre répertoire (outils/ressources) à sys.path.
"""
import os
import re
import unicodedata
from collections import defaultdict

DONNEES = "/home/user/donnees"
RESSOURCES = os.path.join(DONNEES, "ressources")
WN_DICT = os.path.join(DONNEES, "WordNet-3.0", "dict")
SORTIE = os.path.join(DONNEES, "mesure_ressources_lexicales")
LEXIQUES = os.path.join(SORTIE, "lexiques")

# Ressources alignées sur WordNet 3.0 (cible = synset "XXXXXXXX-p")
RES_WN = ["wolf", "wonef_p", "wonef_f", "wonef_c", "dbnary_brut", "dbnary_filtre", "aat_pivot"]
# Vocabulaires patrimoniaux (cible = concept propre à la ressource)
RES_PAT = ["joconde_listes", "garnier_th285", "iconclass_kw", "aat_fr"]
# Lexique sans alignement (présence du lemme seulement)
RES_LEX = ["dbnary_lex"]

UPOS2WN = {"NOUN": "n", "VERB": "v", "ADJ": "a", "ADV": "r", "PROPN": "n"}


def nfc(s):
    return unicodedata.normalize("NFC", s)


def norm(s, garder_casse=False):
    """Normalisation d'une forme : NFC, apostrophe droite, œ→oe, espaces."""
    s = nfc(s).replace("’", "'").replace("ʼ", "'").replace("_", " ")
    s = s.replace("œ", "oe").replace("Œ", "Oe").replace("æ", "ae")
    s = re.sub(r"\s+", " ", s).strip()
    s = re.sub(r"\s*'\s*", "'", s)
    return s if garder_casse else s.lower()


def sans_qualificatif(s):
    """'aiguière (vase)' -> 'aiguière' ; 'X, Y' reste tel quel."""
    return re.sub(r"\s*\([^)]*\)\s*", " ", s).strip()


def singuliers(forme):
    """Variantes singulières grossières d'une forme française (mot à mot).

    Utilisé seulement pour les termes de thésaurus au pluriel (AAT fr).
    """
    mots = forme.split(" ")
    variantes = [forme]
    def sing(m):
        out = {m}
        if len(m) > 3 and m.endswith("aux"):
            out.add(m[:-3] + "al"); out.add(m[:-3] + "ail"); out.add(m[:-1])
        if len(m) > 3 and m.endswith("eux"):
            out.add(m[:-1])
        if len(m) > 2 and (m.endswith("s") or m.endswith("x")) and not m.endswith("ss"):
            out.add(m[:-1])
        return out
    if 1 <= len(mots) <= 4:
        import itertools
        choix = [sorted(sing(m)) if m not in ("de", "du", "des", "à", "en", "et", "la", "le", "les", "d'") else [m] for m in mots]
        for combi in itertools.islice(itertools.product(*choix), 16):
            variantes.append(" ".join(combi))
    return list(dict.fromkeys(variantes))


# ---------------------------------------------------------------- WordNet 3.0
class WordNet:
    """Lecture minimale de WordNet 3.0 (WNDB) : index, gloses, lexnames."""

    def __init__(self, d=WN_DICT):
        self.d = d
        self.lexnames = {}
        for l in open(os.path.join(d, "lexnames"), encoding="utf-8"):
            num, nom, _ = l.split()
            self.lexnames[int(num)] = nom
        self.index = {}  # (lemme_en, p) -> [synset ids dans l'ordre WordNet]
        for p, f in [("n", "noun"), ("v", "verb"), ("a", "adj"), ("r", "adv")]:
            for l in open(os.path.join(d, "index." + f), encoding="latin-1"):
                if l.startswith(" "):
                    continue
                c = l.split()
                lem, pos, nsyn, np_ = c[0], c[1], int(c[2]), int(c[3])
                offs = c[4 + np_ + 2:]
                self.index[(lem, p)] = [o + "-" + p for o in offs]
        self._data = {}
        self.exc = {}
        for p, f in [("n", "noun"), ("v", "verb"), ("a", "adj"), ("r", "adv")]:
            for l in open(os.path.join(d, f + ".exc"), encoding="latin-1"):
                c = l.split()
                if len(c) >= 2:
                    self.exc.setdefault((c[0], p), c[1])

    def _charger(self, p):
        if p in self._data:
            return
        f = {"n": "noun", "v": "verb", "a": "adj", "r": "adv"}[p]
        dd = {}
        for l in open(os.path.join(self.d, "data." + f), encoding="latin-1"):
            if l.startswith(" "):
                continue
            c = l.split(" ")
            off, lexf = c[0], int(c[1])
            w = int(c[3], 16)
            mots = [c[4 + 2 * i] for i in range(w)]
            glose = l.split("|", 1)[1].strip() if "|" in l else ""
            dd[off + "-" + p] = (self.lexnames[lexf], mots, glose)
        self._data[p] = dd

    def info(self, sid):
        p = sid[-1]
        self._charger(p)
        return self._data[p].get(sid)

    def lexname(self, sid):
        i = self.info(sid)
        return i[0] if i else "?"

    def synsets(self, lemme_en, p):
        """Synsets d'un lemme anglais, avec une lemmatisation simple (exc + suffixes)."""
        k = lemme_en.strip().lower().replace(" ", "_")
        if (k, p) in self.index:
            return self.index[(k, p)]
        if (k, p) in self.exc and (self.exc[(k, p)], p) in self.index:
            return self.index[(self.exc[(k, p)], p)]
        regles = {"n": [("ies", "y"), ("ses", "s"), ("xes", "x"), ("ches", "ch"), ("shes", "sh"), ("men", "man"), ("s", "")],
                  "v": [("ies", "y"), ("es", "e"), ("es", ""), ("ed", "e"), ("ed", ""), ("ing", "e"), ("ing", ""), ("s", "")],
                  "a": [("er", ""), ("est", ""), ("er", "e"), ("est", "e")], "r": []}[p]
        # pluriel du dernier mot seulement pour les composés
        for suf, rep in regles:
            if k.endswith(suf):
                c = k[: len(k) - len(suf)] + rep
                if (c, p) in self.index:
                    return self.index[(c, p)]
        return []


def lire_lexique(nom):
    """Lit lexiques/<nom>.tsv -> liste de (forme, pos, cible, note)."""
    out = []
    with open(os.path.join(LEXIQUES, nom + ".tsv"), encoding="utf-8") as f:
        for l in f:
            if l.startswith("#"):
                continue
            c = l.rstrip("\n").split("\t")
            while len(c) < 4:
                c.append("")
            out.append(tuple(c[:4]))
    return out


class Index:
    """Index de recherche d'une ressource.

    - ressources WordNet : (forme_norm, p) -> set(synsets) ; noms propres :
      forme à casse respectée (initiale majuscule) ;
    - vocabulaires patrimoniaux : forme_norm -> set(concepts), sans catégorie.
    """

    def __init__(self, nom):
        self.nom = nom
        self.wn = nom in RES_WN
        self.lex = nom in RES_LEX
        self.par_pos = defaultdict(set)      # (forme, p) -> cibles (minuscule)
        self.propres = defaultdict(set)      # forme casse respectée -> cibles
        self.sans_pos = defaultdict(set)     # forme -> cibles
        self.sans_pos_casse = defaultdict(set)
        for forme, pos, cible, note in lire_lexique(nom):
            fc = norm(forme, garder_casse=True)
            fl = fc.lower()
            if self.wn or self.lex:
                self.par_pos[(fl, pos)].add(cible)
                if fc[:1].isupper():
                    self.propres[fc].add(cible)
            else:
                self.sans_pos[fl].add(cible)
                if fc[:1].isupper():
                    self.sans_pos_casse[fc].add(cible)

    def chercher(self, lemme, upos):
        """Cibles proposées pour un lemme (ensemble vide = inconnu)."""
        if upos == "PROPN":
            fc = norm(lemme, garder_casse=True)
            fc = fc[:1].upper() + fc[1:]
            if self.wn or self.lex:
                return set(self.propres.get(fc, ()))
            return set(self.sans_pos_casse.get(fc, ()))
        fl = norm(lemme)
        cles = [fl]
        if upos == "VERB":
            cles += ["se " + fl, "s'" + fl]
        out = set()
        for k in cles:
            if self.wn or self.lex:
                out |= self.par_pos.get((k, UPOS2WN.get(upos, "x")), set())
            else:
                out |= self.sans_pos.get(k, set())
            if out:
                break
        return out

    def chercher_expr(self, variantes, upos_tete="NOUN"):
        out = set()
        for v in variantes:
            vl = norm(v)
            if self.wn or self.lex:
                for p in ("n", "v", "a", "r"):
                    out |= self.par_pos.get((vl, p), set())
                vc = norm(v, garder_casse=True)
                out |= self.propres.get(vc, set())
            else:
                out |= self.sans_pos.get(vl, set())
            if out:
                break
        return out
