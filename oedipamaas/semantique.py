"""Recherche sémantique : vecteurs de sens des libellés Iconclass (calculés une fois, versionnés avec le modèle) et des
mentions (mis en cache par texte)."""

from __future__ import annotations

import hashlib
import json
from pathlib import Path

import numpy as np

MODELE_DEFAUT = "sentence-transformers/paraphrase-multilingual-MiniLM-L12-v2"


def texte_notation(r: dict, parent: dict | None) -> str:
    """Ce qu'on plonge pour une notation : son libellé, ses mots clés, et le libellé du parent si le sien est court."""
    lib = r["libelle"]
    if parent and len(lib.split()) <= 3 and parent.get("libelle"):
        lib = f"{lib} ({parent['libelle']})"
    mots = [k for k in r["mots"] if k.lower() not in lib.lower()][:12]
    return lib + (" ; " + ", ".join(mots) if mots else "")


def nom_fichier(modele: str) -> str:
    return "vecteurs-" + modele.split("/")[-1]


class IndexSemantique:
    def __init__(self, dossier_base: Path, modele: str = MODELE_DEFAUT, revision: str | None = None):
        self.dossier = Path(dossier_base)
        self.modele_nom, self.revision = modele, revision
        self._modele = None
        self._cache: dict[str, np.ndarray] = {}
        f = self.dossier / (nom_fichier(modele) + ".npy")
        meta = self.dossier / (nom_fichier(modele) + ".json")
        if not f.exists():
            raise FileNotFoundError(f"{f} : lancer d'abord « oedipamaas vecteurs »")
        self.vecteurs = np.load(f).astype(np.float32)
        self.meta = json.loads(meta.read_text())
        self.ids = self.meta["ids"]
        self.prefixe_requete = self.meta.get("prefixe_requete", "")
        self.position = {n: i for i, n in enumerate(self.ids)}
        cache = self.dossier / (nom_fichier(modele) + ".mentions.npz")
        if cache.exists():
            self.charger_cache(cache)

    def charger_cache(self, chemin: Path):
        """Vecteurs de mentions calculés ailleurs (même modèle, même révision) : le moteur rejoue sans le modèle."""
        z = np.load(chemin, allow_pickle=False)
        for t, v in zip(z["textes"].tolist(), z["vecteurs"]):
            self._cache[t] = v.astype(np.float32)

    def modele(self):
        if self._modele is None:
            from sentence_transformers import SentenceTransformer
            self._modele = SentenceTransformer(self.modele_nom, revision=self.revision, device="cpu")
        return self._modele

    def encoder(self, textes: list[str]) -> np.ndarray:
        manquants = [t for t in dict.fromkeys(textes) if t not in self._cache]
        if manquants:
            v = self.modele().encode([self.prefixe_requete + t for t in manquants], batch_size=64,
                                     normalize_embeddings=True, show_progress_bar=False)
            for t, x in zip(manquants, v):
                self._cache[t] = x.astype(np.float32)
        return np.stack([self._cache[t] for t in textes]) if textes else np.zeros((0, self.vecteurs.shape[1]))

    def voisins(self, texte: str, masque: np.ndarray, top: int = 10) -> list[tuple[str, float]]:
        """Les « top » notations les plus proches parmi celles que le masque permet (cosinus)."""
        q = self.encoder([texte])[0]
        s = self.vecteurs @ q
        s = np.where(masque, s, -1.0)
        idx = np.argpartition(-s, min(top, len(s) - 1))[:top]
        idx = idx[np.argsort(-s[idx], kind="stable")]
        return [(self.ids[i], round(float(s[i]), 4)) for i in idx if s[i] > -1.0]


PREFIXES = {"intfloat/multilingual-e5-large": ("query: ", "passage: "),
            "intfloat/multilingual-e5-base": ("query: ", "passage: ")}   # modèles qui veulent un préfixe


def calculer(dossier_base: Path, modele: str = MODELE_DEFAUT, revision: str | None = None, device: str = "cpu",
             mentions: list[str] | None = None) -> dict:
    """Plonge toutes les notations qui ont un libellé (hors gabarits) ; écrit vecteurs-<modèle>.npy (float16) et .json.
    Si « mentions » est donné, plonge aussi ces textes de descriptions (cache : vecteurs-<modèle>.mentions.npz)."""
    from sentence_transformers import SentenceTransformer

    dossier = Path(dossier_base)
    recs = [json.loads(x) for x in (dossier / "notations.jsonl").read_text(encoding="utf8").splitlines()]
    par_n = {r["n"]: r for r in recs}
    ids, textes = [], []
    for r in recs:
        if r["libelle"] and not r["gabarit"]:
            ids.append(r["n"])
            textes.append(texte_notation(r, par_n.get(r["parent"])))
    pq, pd = PREFIXES.get(modele, ("", ""))
    m = SentenceTransformer(modele, revision=revision, device=device)
    v = m.encode([pd + t for t in textes], batch_size=128, normalize_embeddings=True,
                 show_progress_bar=False).astype(np.float16)
    np.save(dossier / (nom_fichier(modele) + ".npy"), v)
    if mentions:
        mentions = sorted(set(mentions))
        vm = m.encode([pq + t for t in mentions], batch_size=128, normalize_embeddings=True,
                      show_progress_bar=False).astype(np.float16)
        np.savez(dossier / (nom_fichier(modele) + ".mentions.npz"), textes=np.array(mentions), vecteurs=vm)
    meta = {"modele": modele, "revision": revision, "ids": ids, "dimension": int(v.shape[1]),
            "prefixe_requete": pq, "prefixe_document": pd, "mentions": len(mentions or []),
            "sha256_textes": hashlib.sha256("\n".join(textes).encode()).hexdigest()}
    (dossier / (nom_fichier(modele) + ".json")).write_text(json.dumps(meta) + "\n")
    return {k: meta[k] for k in ("modele", "revision", "dimension")} | {"notations": len(ids)}
