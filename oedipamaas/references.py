"""Références de source : passages bibliques et d'Ovide, dans les libellés Iconclass et dans les descriptions.

Une référence est un tuple (oeuvre, livre, debut, fin) : oeuvre = nom canonique du livre biblique (« 1 samuel ») ou
« ovide metamorphoses » ; livre = chapitre biblique ou livre des Métamorphoses ; debut, fin = versets ou vers
(None si la référence ne les donne pas).
"""

from __future__ import annotations

import re

LIVRES = {
    "genesis": "genesis", "gen": "genesis", "gn": "genesis", "exodus": "exodus", "exod": "exodus", "ex": "exodus",
    "leviticus": "leviticus", "lev": "leviticus", "numbers": "numbers", "num": "numbers",
    "deuteronomy": "deuteronomy", "deut": "deuteronomy", "joshua": "joshua", "josh": "joshua", "judges": "judges",
    "judg": "judges", "ruth": "ruth", "samuel": "samuel", "sam": "samuel", "kings": "kings", "kgs": "kings",
    "chronicles": "chronicles", "chron": "chronicles", "ezra": "ezra", "nehemiah": "nehemiah", "tobit": "tobit",
    "tobias": "tobit", "judith": "judith", "esther": "esther", "maccabees": "maccabees", "macc": "maccabees",
    "job": "job", "psalms": "psalms", "psalm": "psalms", "ps": "psalms", "proverbs": "proverbs", "prov": "proverbs",
    "ecclesiastes": "ecclesiastes", "eccles": "ecclesiastes", "eccl": "ecclesiastes", "song of solomon": "song",
    "song of sol": "song", "song of songs": "song", "canticles": "song", "wisdom": "wisdom",
    "ecclesiasticus": "sirach", "sirach": "sirach", "isaiah": "isaiah", "is": "isaiah", "isa": "isaiah",
    "jeremiah": "jeremiah", "jer": "jeremiah", "lamentations": "lamentations", "baruch": "baruch",
    "ezekiel": "ezekiel", "ezek": "ezekiel", "daniel": "daniel", "dan": "daniel", "hosea": "hosea", "joel": "joel",
    "amos": "amos", "obadiah": "obadiah", "jonah": "jonah", "micah": "micah", "nahum": "nahum",
    "habakkuk": "habakkuk", "zephaniah": "zephaniah", "haggai": "haggai", "zechariah": "zechariah",
    "malachi": "malachi", "esdras": "esdras", "matthew": "matthew", "matt": "matthew", "mt": "matthew",
    "mark": "mark", "mk": "mark", "luke": "luke", "lk": "luke", "john": "john", "jo": "john", "jn": "john",
    "acts": "acts", "romans": "romans", "rom": "romans", "corinthians": "corinthians", "cor": "corinthians",
    "galatians": "galatians", "ephesians": "ephesians", "philippians": "philippians", "colossians": "colossians",
    "thessalonians": "thessalonians", "timothy": "timothy", "titus": "titus", "hebrews": "hebrews",
    "james": "james", "peter": "peter", "revelation": "revelation", "rev": "revelation", "apocalypse": "revelation",
}
ROMAINS = {"i": 1, "ii": 2, "iii": 3, "iv": 4}

_NOMS = sorted(LIVRES, key=len, reverse=True)
_BIBLE = re.compile(
    r"(?<![a-z])(?:(?P<num>[1-4]|iv|iii|ii|i)\s*)?(?P<livre>" + "|".join(re.escape(n) for n in _NOMS) +
    r")\.?\s+(?P<ch>\d{1,3})(?:\s*[:,.]\s*(?P<v1>\d{1,3})(?:\s*[-–]\s*(?P<v2>\d{1,3}))?)?(?![\d])")
_OVIDE = re.compile(r"metamorphos[ei]s\s+(?:book\s+)?(?P<livre>[xvil]+|\d{1,2})\b(?:\s*[:,. ]\s*(?P<v1>\d{1,4})"
                    r"(?:\s*[-–]\s*(?P<v2>\d{1,4}))?)?")


def _romain(s: str) -> int | None:
    if s.isdigit():
        return int(s)
    valeurs = {"i": 1, "v": 5, "x": 10, "l": 50}
    total, prec = 0, 0
    for c in reversed(s):
        v = valeurs.get(c)
        if v is None:
            return None
        total, prec = (total - v, prec) if v < prec else (total + v, v)
    return total


def analyser(texte: str) -> list[tuple[str, int, int | None, int | None]]:
    """Toutes les références trouvées dans un texte (libellé Iconclass ou champ « source » d'une description)."""
    t = texte.lower()
    refs = []
    for m in _OVIDE.finditer(t):
        livre = _romain(m["livre"])
        if livre:
            refs.append(("ovide metamorphoses", livre, _int(m["v1"]), _int(m["v2"] or m["v1"])))
    for m in _BIBLE.finditer(t):
        livre = LIVRES[m["livre"]]
        if livre == "ovide":
            continue
        num = m["num"]
        if num:
            num = ROMAINS.get(num, num)
            livre = f"{num} {livre}"
        elif livre in ("samuel", "kings", "chronicles", "maccabees", "corinthians", "thessalonians", "timothy",
                       "peter", "esdras"):
            continue  # livre double sans numéro : ambigu
        refs.append((livre, int(m["ch"]), _int(m["v1"]), _int(m["v2"] or m["v1"])))
    return sorted(set(refs), key=lambda r: (r[0], r[1], r[2] or 0, r[3] or 0))


def _int(s):
    return int(s) if s else None


def recouvre(a, b) -> bool:
    """Deux références désignent-elles le même passage ? Même livre et chapitre ; versets recouvrants s'ils sont
    donnés des deux côtés."""
    if a[0] != b[0] or a[1] != b[1]:
        return False
    if a[2] is None or b[2] is None:
        return True
    return a[2] <= (b[3] or b[2]) and b[2] <= (a[3] or a[2])
