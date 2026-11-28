"""L'ordre des types relatif à K (docs/LANGAGE_REFERENCE.md, § 3.4) : la clôture de l'inclusion entre concepts, et
l'ordre ⊑ entre expressions de types (concept, union, conjonction, ⊥), qui est l'ordre du treillis libre engendré par
le préordre des concepts (règles de Whitman). Les alias et les distinctions documentaires de clés de noms (§ 3.4).

Une inclusion non attestée ne fonde qu'une hypothèse (NOTATION § 5) : `sous` rend l'ensemble des entrées non
attestées qu'emploie la dérivation la plus économe, de nature `connaissance_non_attestee` (signalé au § 3.12 du
document : la définition 4 de l'étude ne nomme pas cette nature).
"""
from __future__ import annotations

from collections import deque
from functools import lru_cache

from .syntaxe import (Alias, Alternatifs, Concept, Conjonction, Connaissances, Distinction, Equivalence, Inclusion,
                      Inconnu, Union)


class ErreurType(Exception):
    """Un type non résolu (un point) est arrivé là où seule une interprétation fixée a un sens."""


class Ordre:
    """§ 3.4, l'ordre ⊑ relatif à K. Construit une fois par K."""

    def __init__(self, K: Connaissances):
        self.K = K
        self.aretes: dict[str, list] = {}  # concept -> [(concept plus général, id, attestée)]
        for e in K.entrees:
            if isinstance(e, Inclusion):
                self.aretes.setdefault(e.sous, []).append((e.sur, e.id, e.statut == "attestee"))
            elif isinstance(e, Equivalence):
                self.aretes.setdefault(e.a, []).append((e.b, e.id, e.statut == "attestee"))
                self.aretes.setdefault(e.b, []).append((e.a, e.id, e.statut == "attestee"))
        # § 3.4 : les alias sont clos (réflexifs, symétriques, transitifs), quelle que soit la forme de K.
        self._parent: dict[str, str] = {}
        for e in K.entrees:
            if isinstance(e, Alias) and e.statut == "attestee":
                self._unir(e.cle1, e.cle2)
        self.distinctions = [e for e in K.entrees if isinstance(e, Distinction) and e.statut == "attestee"]
        self._cache_concepts: dict = {}
        self._cache_sous: dict = {}

    # --- l'inclusion entre concepts : un plus court chemin en nombre d'entrées non attestées (0-1 BFS) ----------
    def concept_sous(self, c: str, d: str):
        """c ⊑ d par la clôture réflexive et transitive de l'inclusion de K. Rend None (non), ou l'ensemble (gelé)
        des identifiants d'entrées non attestées du chemin le plus économe (vide : une inclusion attestée)."""
        cle = (c, d)
        if cle in self._cache_concepts:
            return self._cache_concepts[cle]
        meilleur = {c: frozenset()}
        file = deque([c])
        while file:
            x = file.popleft()
            for (y, ident, attestee) in self.aretes.get(x, ()):
                cout = meilleur[x] if attestee else meilleur[x] | {ident}
                if y not in meilleur or len(cout) < len(meilleur[y]):
                    meilleur[y] = cout
                    if attestee:
                        file.appendleft(y)
                    else:
                        file.append(y)
        r = meilleur.get(d)
        self._cache_concepts[cle] = r
        return r

    # --- l'ordre entre expressions de types : le treillis libre (Whitman) ------------------------------------
    def sous(self, a, b):
        """a ⊑ b (§ 3.4, règles S1 à S6). Rend None, ou l'ensemble des entrées non attestées employées.
        S1 ⊥ n'est inclus dans rien et rien n'est inclus dans ⊥ (étude § 3.2 : sous ⊥, aucun lien).
        S2 c ⊑ d entre concepts : la clôture de K.
        S3 (A1 ∪ … ∪ An) ⊑ B ssi chaque Ai ⊑ B.          S4 A ⊑ (B1 ∩ … ∩ Bn) ssi A ⊑ chaque Bi.
        S5 (A1 ∩ … ∩ An) ⊑ B si un Ai ⊑ B.               S6 A ⊑ (B1 ∪ … ∪ Bn) si A ⊑ un Bi.
        S5 et S6 sont essayées toutes deux quand elles s'appliquent (la condition de Whitman) : l'ordre obtenu est
        transitif, ce dont dépendent les propositions de sûreté (T21, T22)."""
        cle = (a, b)
        if cle in self._cache_sous:
            return self._cache_sous[cle]
        r = self._sous(a, b)
        self._cache_sous[cle] = r
        return r

    def _sous(self, a, b):
        if isinstance(a, Alternatifs) or isinstance(b, Alternatifs):
            raise ErreurType(f"type non résolu : {a} ⊑ {b}")
        if isinstance(a, Inconnu) or isinstance(b, Inconnu):
            return None  # S1
        if isinstance(a, Union):  # S3
            acc = frozenset()
            for m in a.membres:
                r = self.sous(m, b)
                if r is None:
                    return None
                acc |= r
            return acc
        if isinstance(b, Conjonction):  # S4
            acc = frozenset()
            for m in b.membres:
                r = self.sous(a, m)
                if r is None:
                    return None
                acc |= r
            return acc
        if isinstance(a, Concept) and isinstance(b, Concept):  # S2
            return self.concept_sous(a.id, b.id)
        candidats = []
        if isinstance(a, Conjonction):  # S5
            for m in a.membres:
                r = self.sous(m, b)
                if r is not None:
                    candidats.append(r)
        if isinstance(b, Union):  # S6
            for m in b.membres:
                r = self.sous(a, m)
                if r is not None:
                    candidats.append(r)
        if not candidats:
            return None
        return min(candidats, key=lambda s: (len(s), sorted(s)))

    # --- les noms ------------------------------------------------------------------------------------------
    def _racine(self, k: str) -> str:
        while self._parent.get(k, k) != k:
            k = self._parent[k]
        return k

    def _unir(self, a: str, b: str):
        ra, rb = self._racine(a), self._racine(b)
        if ra != rb:
            self._parent[max(ra, rb)] = min(ra, rb)

    def meme_cle(self, k1: str, k2: str) -> bool:
        """Deux clés de nom désignent-elles le même individu par la clôture des alias ? (§ 3.4)"""
        return self._racine(k1) == self._racine(k2)

    def distinction_documentee(self, k1: str, k2: str):
        """L'entrée de K qui dit que k1 et k2 sont deux individus documentés différents, ou None (§ 3.4)."""
        for d in self.distinctions:
            if (self.meme_cle(k1, d.cle1) and self.meme_cle(k2, d.cle2)) or \
               (self.meme_cle(k1, d.cle2) and self.meme_cle(k2, d.cle1)):
                return d
        return None


@lru_cache(maxsize=64)
def _ordre_cache(K: Connaissances) -> Ordre:
    return Ordre(K)


def ordre(K: Connaissances) -> Ordre:
    """L'ordre ⊑ de K, mémorisé (K est immuable)."""
    return _ordre_cache(K)
