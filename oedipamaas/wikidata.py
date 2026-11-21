"""Alias Wikidata (CC0) des notations Iconclass : éléments portant la propriété P1256 « Iconclass notation », avec
leurs libellés et alias en quelques langues. La propriété P1257 « depicts Iconclass notation » (portée par des œuvres)
n'est jamais utilisée : elle ferait entrer dans le moteur la vérité d'œuvres qui peuvent servir à l'évaluation."""

from __future__ import annotations

import json
import re
import urllib.parse
import urllib.request
from pathlib import Path

from . import texte

REQUETE = """SELECT ?i ?v (GROUP_CONCAT(DISTINCT ?l; SEPARATOR="|") AS ?libelles) WHERE {
  ?i wdt:P1256 ?v .
  OPTIONAL { ?i rdfs:label|skos:altLabel ?l . FILTER(LANG(?l) IN ("en","fr","de","nl","it","es","la")) }
} GROUP BY ?i ?v"""


def telecharger(sortie: Path) -> int:
    """Instantané de P1256 (une requête) ; à dater et à garder avec la base."""
    donnees = urllib.parse.urlencode({"query": REQUETE}).encode()
    req = urllib.request.Request("https://query.wikidata.org/sparql", data=donnees,
                                 headers={"Accept": "application/sparql-results+json",
                                          "User-Agent": "oedipamaas/0.1 (iconclass engine)"})
    with urllib.request.urlopen(req, timeout=180) as r:
        brut = r.read()
    Path(sortie).write_bytes(brut)
    return len(json.loads(brut)["results"]["bindings"])


def alias_valide(a: str) -> bool:
    """Écarte les abréviations (« Jr », « Jer. »), les sigles et les libellés trop longs."""
    a = a.strip()
    if len(a) < 4 or len(a.split()) > 6 or a.isupper() or a.endswith("."):
        return False
    return bool(re.search(r"[A-Za-zÀ-ÿ]{3}", a))


def alias(chemin: Path) -> dict[str, list[str]]:
    """{notation: [alias normalisés]} depuis l'instantané."""
    out: dict[str, set[str]] = {}
    for b in json.loads(Path(chemin).read_text(encoding="utf8"))["results"]["bindings"]:
        n = b["v"]["value"].strip()
        for a in (b.get("libelles", {}).get("value") or "").split("|"):
            if alias_valide(a) and texte.norme(a):
                out.setdefault(n, set()).add(texte.norme(a))
    return {n: sorted(v) for n, v in out.items()}
