"""Ordres des candidats avant la décision (socle 1.0) : ancêtres seuls toujours après les autres ; « expl » met les
explications par unité devant, les plus souvent dites d'abord, puis l'ordre « part »."""
import pytest

pytest.importorskip("janus_swi")
from oedipamaas.socle.moteur import ORDRES  # noqa: E402

CANDS = [
    {"code": "A", "score": 0.9, "traits": {"bm25_direct": 3.0}},
    {"code": "B", "score": 0.5, "traits": {"explication": 1, "unites_pleines": 1}},
    {"code": "C", "score": 0.2, "traits": {"explication": 1, "unites_pleines": 3}},
    {"code": "D", "score": 1.0, "traits": {"ancetre_seul": 1, "explication": 1, "unites_pleines": 5}},
    {"code": "E", "score": 0.9, "traits": {"bm25_direct": 5.0}},
]


def test_sortie_compressee(tmp_path):
    import gzip
    import json
    from oedipamaas.socle.coder import ouvrir_sortie
    for nom in ("x.jsonl", "x.jsonl.gz"):
        with ouvrir_sortie(tmp_path / nom) as out:
            out.write(json.dumps({"image": "é", "codes": []}, ensure_ascii=False) + "\n")
    assert gzip.decompress((tmp_path / "x.jsonl.gz").read_bytes()) == (tmp_path / "x.jsonl").read_bytes()


def test_ordres():
    assert [c["code"] for c in sorted(CANDS, key=ORDRES["part"])] == ["E", "A", "B", "C", "D"]
    assert [c["code"] for c in sorted(CANDS, key=ORDRES["expl"])] == ["C", "B", "E", "A", "D"]
