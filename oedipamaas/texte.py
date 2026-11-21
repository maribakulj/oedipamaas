"""Normalisation des expressions anglaises : minuscules, graphie britannique, singulier, mots pleins."""

from __future__ import annotations

import re
import unicodedata

VIDES = frozenset("""
a an the and or of in on at to by for with from into onto upon over under near before behind between among
his her its their this that these those which who whom whose is are was were be being been has have had
as also such some other others another one two three very more most all any each both few several many much
""".split())

# Anglais américain → britannique (Iconclass écrit en anglais britannique).
GRAPHIES = {
    "armor": "armour", "armored": "armoured", "color": "colour", "colored": "coloured", "harbor": "harbour",
    "center": "centre", "gray": "grey", "jewelry": "jewellery", "honor": "honour", "labor": "labour",
    "favor": "favour", "neighbor": "neighbour", "plow": "plough", "theater": "theatre", "sabre": "sabre",
    "saber": "sabre", "mustache": "moustache", "ax": "axe", "pajamas": "pyjamas", "cozy": "cosy",
}

# Pluriels irréguliers fréquents dans les descriptions.
IRREGULIERS = {
    "men": "man", "women": "woman", "children": "child", "feet": "foot", "teeth": "tooth", "geese": "goose",
    "mice": "mouse", "oxen": "ox", "sheep": "sheep", "deer": "deer", "fish": "fish", "putti": "putto",
    "cherubim": "cherub", "seraphim": "seraph", "leaves": "leaf", "wolves": "wolf", "knives": "knife",
    "loaves": "loaf", "calves": "calf", "halves": "half", "shelves": "shelf", "thieves": "thief", "wives": "wife",
    "lives": "life", "staves": "staff", "people": "person", "dice": "die",
}

_INVARIABLES = ("ss", "us", "is", "ys", "os")


def sans_accents(s: str) -> str:
    return "".join(c for c in unicodedata.normalize("NFKD", s) if not unicodedata.combining(c))


def singulier(mot: str) -> str:
    if mot in IRREGULIERS:
        return IRREGULIERS[mot]
    if len(mot) <= 3 or mot.endswith(_INVARIABLES):
        return mot
    if mot.endswith("ies") and len(mot) > 4:
        return mot[:-3] + "y"
    if mot.endswith(("ches", "shes", "sses", "xes", "zes")):
        return mot[:-2]
    if mot.endswith("s"):
        return mot[:-1]
    return mot


def mots(s: str) -> list[str]:
    """Mots d'une expression, en minuscules, sans ponctuation (l'apostrophe des possessifs est gardée)."""
    s = sans_accents(str(s)).lower().replace("_", " ")
    s = re.sub(r"[‘’`]", "'", s)
    return [m.strip("'") for m in re.findall(r"[a-z0-9][a-z0-9'\-]*", s) if m.strip("'")]


def norme(s: str) -> str:
    """Forme de comparaison : minuscules, graphie britannique, dernier mot au singulier, sans article initial."""
    ms = [GRAPHIES.get(m, m) for m in mots(s)]
    while ms and ms[0] in ("a", "an", "the"):
        ms = ms[1:]
    if ms:
        ms[-1] = singulier(ms[-1])
    return " ".join(ms)


def jetons(s: str) -> list[str]:
    """Mots pleins, au singulier et en graphie britannique, sans possessif."""
    out = []
    for m in mots(s):
        m = re.sub(r"'s?$", "", m)
        if m not in VIDES and len(m) > 1:
            out.append(singulier(GRAPHIES.get(m, m)))
    return out


def racine(m: str) -> str:
    """Racine grossière d'un mot plein (« beheading », « beheads » → « behead ») pour la recherche lexicale."""
    for fin, garde in (("ings", 5), ("ing", 5), ("edly", 6), ("ed", 5), ("ies", 5), ("es", 5), ("s", 4)):
        if m.endswith(fin) and len(m) > garde:
            m = m[: -len(fin)]
            break
    if len(m) > 4 and m[-1] == m[-2] and m[-1] not in "lsz":
        m = m[:-1]  # « stabbing » → « stabb » → « stab »
    return m


def racines(s: str) -> list[str]:
    return [racine(m) for m in jetons(s)]


def tete(libelle: str) -> str:
    """Tête d'un libellé Iconclass : dernier segment après « : » ou « ; », dernière virgule, sans parenthèse finale."""
    t = re.sub(r"\s*\([^)]*\)\s*$", "", libelle)
    t = t.split(" ~ ")[0]
    t = re.split(r"[:;]", t)[-1]
    return norme(t.split(",")[-1]) if t.strip() else ""
