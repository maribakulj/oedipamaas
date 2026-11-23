"""Lecture d'une description en faits et recherche à plat (socle 1.0, pièce 4), sur un petit Iconclass et WordNet
réel (WORDNET_PROLOG, WORDNET_DICT) ; sauté si WordNet n'est pas disponible."""
import os
import tempfile
from pathlib import Path

import pytest

janus = pytest.importorskip("janus_swi")
SOCLE = Path(__file__).resolve().parent.parent / "oedipamaas" / "socle"
WNP, WND = os.environ.get("WORDNET_PROLOG"), os.environ.get("WORDNET_DICT")

NOTATIONS = ("N 1\nC 11\n$\nN 11\nC 11H\n$\nN 11H\nC 11H(...)\n$\nN 11H(...)\nC 11H(JEROME)\n$\nN 11H(JEROME)\n$\n"
             "N 2\nC 25\n$\nN 25\nC 25F\n$\nN 25F\nC 25F2\n$\nN 25F2\nC 25F23\n$\nN 25F23\nC 25F23(LION)\n$\n"
             "N 25F23(LION)\n$\nN 3\nC 31\n$\nN 31\nC 31A\n$\nN 31A\nC 31A2\n$\nN 31A2\nC 31A23\n$\nN 31A23\n"
             "C 31A231\n$\nN 31A231\n$\nN 4\nC 41\n$\nN 41\n$\n")
LIBELLES = ("11H(...)|male saint (with NAME)\n"
            "11H(JEROME)|Jerome, Father of the Church; possible attributes: book, cardinal's hat, lion, skull\n"
            "25F23(LION)|beasts of prey, predatory animals: lion\n31A231|kneeling figure\n41|material aspects\n")
MOTS = "25F23(LION)|lion\n31A231|kneeling\n11H(JEROME)|Jerome\n41|left\n"
DESCRIPTION = {"subject": {"title": "Saint Jerome in the wilderness", "source": None, "type": "religious",
                           "confidence": "high", "alternatives": []},
               "persons": [{"who": "Saint Jerome", "recognised_by": "lion and skull", "confidence": "high"}],
               "entities": [{"id": "e1", "type": "old man", "attributes": ["kneeling", "half naked"],
                             "plane": "foreground", "position": "left", "box": [0.1, 0.2, 0.5, 0.9]},
                            {"id": "e2", "type": "lioness", "attributes": [], "plane": "middle ground",
                             "position": "right", "box": [0.6, 0.5, 0.9, 0.9]},
                            {"id": "e3", "type": "feline", "attributes": [], "plane": "background",
                             "position": "left", "box": [0.0, 0.0, 0.1, 0.1]}],
               "relations": [["e1", "looks_at", "e2"]], "actions": ["praying"], "gestures_emotions": [],
               "concepts": [], "roles": [], "setting": ["rocky wilderness"],
               "texts": [{"transcription": "HIERONYMUS", "language": "Latin"}], "genre_function": [],
               "period_style": None, "keywords": []}


@pytest.mark.skipif(not (WNP and WND), reason="WORDNET_PROLOG et WORDNET_DICT non définis")
def test_lecture_et_recherche():
    from oedipamaas.socle import faits_description as fd
    from oedipamaas.socle.compiler_iconclass import compiler
    from oedipamaas.socle.compiler_wordnet import compiler as compiler_wn
    with tempfile.TemporaryDirectory() as t:
        d = Path(t) / "depot"
        for p in ("txt/en", "kw/en"):
            (d / p).mkdir(parents=True)
        (d / "notations.txt").write_text(NOTATIONS, encoding="utf-8")
        (d / "keys.txt").write_text("", encoding="utf-8")
        (d / "txt/en/txt_en_0_1.txt").write_text(LIBELLES, encoding="utf-8")
        (d / "kw/en/kw_en_0_1.txt").write_text(MOTS, encoding="utf-8")
        (d / "COMMIT").write_text("essai\n")
        base = Path(t) / "base"
        compiler(d, base)
        compiler_wn(WNP, WND, base)
        janus.query_once(f"load_files('{base / 'iconclass.pl'}', [redefine_module(true)])")
        janus.query_once(f"load_files('{base / 'wordnet.pl'}', [redefine_module(true)])")
        for f in ("lexique.pl", "description.pl", "recherche.pl"):
            janus.consult(str(SOCLE / f))
        janus.query_once("morphologie:indexer")
        janus.query_once("abolish_all_tables")
        janus.query_once(f"lexique:construire_index('{base / 'lexique_index.pl'}')")
        janus.query_once(f"load_files('{base / 'lexique_index.pl'}', [redefine_module(true)])")
        janus.query_once("retractall(recherche:stats(_, _)), retractall(recherche:longueur(_, _))")

        fd.charger(janus, DESCRIPTION)
        textes = {x["T"] for x in janus.query("description:mention(_, _, _, T)")}
        assert "left" not in textes and "foreground" not in textes and "Latin" not in textes   # mise en page
        assert "kneeling" in textes and "HIERONYMUS" in textes
        assert janus.query_once("description:entite(e2, lioness, 'middle ground', right, B)")["B"] == [0.6, 0.5, 0.9,
                                                                                                       0.9]

        def liens(n):
            return {x["L"] for x in janus.query("recherche:candidat(N, _, p(_, _, _L, _)), term_string(_L, L)",
                                                {"N": n})}
        assert "egal" in liens("31A231")                                   # « kneeling », mot clé et lemme
        assert "egal" in liens("11H(JEROME)")                              # « Jerome »
        assert "wordnet(hyperonyme,1,lioness)" in liens("25F23(LION)")     # la lionne est un lion
        assert not any("feline" in x for x in liens("25F23(LION)"))         # jamais par l'hyponyme
        # « left » est une position, pas une mention : aucune correspondance directe (WordNet peut y mener depuis
        # « looks_at », par polysémie : c'est un lien faible que la décision pèse)
        assert "egal" not in liens("41")
        r = janus.query_once("recherche:classement(10, _L), findall(_N, member(c(_N, _, _), _L), X), "
                             "recherche:ancetres_des_premiers(_L, 10, A)")
        assert {"25F23(LION)", "31A231", "11H(JEROME)"} <= set(r["X"])
        assert {"11H(...)", "11H", "25F2", "31A23"} <= set(r["A"])

        # spécialisation : de 31A23 (non décrit en propre ici), la descente va vers 31A231, dont le mot propre
        # « kneeling » est décrit ; de 25F23, vers le lion nommé
        janus.consult(str(SOCLE / "specialisation.pl"))
        propres = base / "propres_index.pl"
        janus.query_once(f"specialisation:construire_propres('{propres}')")
        janus.query_once(f"load_files('{propres}', [redefine_module(true)])")
        janus.query_once("specialisation:decrire")
        # mots propres de 31A231 : « kneeling » (décrit) et « figure » (non décrit) → la moitié
        assert janus.query_once("specialisation:part_decrite('31A231', P)")["P"] == 0.5
        s = janus.query_once("specialisation:specialisees(['31A23', '25F23'], S)")["S"]
        assert set(s) == {"31A231", "25F23(LION)"}, s

        # preuve : chaque appui cite le chemin JSON et le texte de la mention, la forme, le lien et l'entrée
        import json
        janus.consult(str(SOCLE / "preuve.pl"))
        p = json.loads(janus.query_once("preuve:preuve_lexicale('25F23(LION)', _D), preuve:preuve_json(_D, J)")["J"])
        assert p["regle"] == "lexical" and p["iconclass"] == "beasts of prey, predatory animals: lion"
        assert {"chemin": "entities[1].type", "texte": "lioness", "forme": "lion",
                "lien": "wordnet(hyperonyme,1,lioness)", "entree": "mot_cle(en)"} in p["appuis"]
        q = json.loads(janus.query_once("preuve:preuve_specialisation('31A23', '31A231', _D), "
                                        "preuve:preuve_json(_D, J)")["J"])
        assert q["mots_propres_decrits"] == ["kneeling"] and q["part_decrite"] == 0.5

        # traits de preuve des candidats, pour la décision apprise
        janus.consult(str(SOCLE / "cles.pl"))
        janus.query_once(f"cles:construire_cles('{base / 'cles_index.pl'}')")
        janus.query_once(f"load_files('{base / 'cles_index.pl'}', [redefine_module(true)])")
        janus.consult(str(SOCLE / "traits.pl"))
        t = janus.query_once("traits:candidats_traits(10, _L), member(['25F23(LION)', _P, _T], _L), "
                             "findall([_K, _V], member(_K-_V, _T), X)")["X"]
        t = dict(t)
        # appui direct « lion » dans persons.recognised_by ; la lionne (entité) passe par WordNet
        assert t["wn_hyperonyme"] == 1 and t["champ_persons"] >= 1 and t["nom"] == 1 and t["prof"] == 6, t
        a = dict(janus.query_once("traits:candidats_traits(10, _L), member(['25F2', _, _T], _L), "
                                  "findall([_K, _V], member(_K-_V, _T), X)")["X"])
        assert a.get("ancetre_seul") == 1 and a.get("enfants_candidats", 0) >= 1, a

        # « half-length » se lit aussi « half », « length »
        assert janus.query_once("recherche:forme_mention(_, length)")["truth"] is False  # pas encore décrit
        fd.charger(janus, dict(DESCRIPTION, keywords=["half-length portrait"]))
        assert janus.query_once("recherche:forme_mention(_, length)")["truth"]
        assert janus.query_once("recherche:forme_mention(_, 'half-length')")["truth"]
