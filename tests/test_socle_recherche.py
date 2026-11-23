"""Lecture d'une description en faits et recherche à plat (socle 1.0, pièce 4), sur un petit Iconclass et WordNet
réel (WORDNET_PROLOG, WORDNET_DICT) ; sauté si WordNet n'est pas disponible."""
import os
import tempfile
from pathlib import Path

import pytest

janus = pytest.importorskip("janus_swi")
SOCLE = Path(__file__).resolve().parent.parent / "oedipamaas" / "socle"
WNP, WND = os.environ.get("WORDNET_PROLOG"), os.environ.get("WORDNET_DICT")

NOTATIONS = ("N 1\nC 11\n$\nN 11\nC 11H\n; 11F\n$\nN 11H\nC 11H(...)\n$\nN 11H(...)\nC 11H(JEROME)\n$\nN 11H(JEROME)\n$\n"
             "N 11F\nC 11F4\n$\nN 11F4\nC 11F42\n$\nN 11F42\nC 11F422\n$\nN 11F422\n$\n"
             "N 2\nC 25\n$\nN 25\nC 25F\n$\nN 25F\nC 25F2\n; 25F7\n$\nN 25F2\nC 25F23\n$\nN 25F23\nC 25F23(LION)\n$\n"
             "N 25F7\nC 25F71\n$\nN 25F71\nC 25F711\n$\nN 25F711\nC 25F711(...)\n$\nN 25F711(...)\nC 25F711(ANT)\n$\n"
             "N 25F711(ANT)\n$\n"
             "N 25F23(LION)\n$\nN 3\nC 31\n$\nN 31\nC 31A\n$\nN 31A\nC 31A2\n$\nN 31A2\nC 31A23\n$\nN 31A23\n"
             "C 31A231\n; 31A232\n$\nN 31A231\n$\nN 31A232\n$\nN 4\nC 41\n$\nN 41\n$\n")
LIBELLES = ("11H(...)|male saint (with NAME)\n"
            "11H(JEROME)|Jerome, Father of the Church; possible attributes: book, cardinal's hat, lion, skull\n"
            "25F23(LION)|beasts of prey, predatory animals: lion\n31A231|kneeling figure\n41|material aspects\n"
            "31A232|kneeling figure ~ portrait\n"
            "25F711(...)|insects (with NAME)\n25F711(ANT)|insects: ant\n"
            "11F|the Virgin Mary\n11F4|Madonna: i.e. Mary with the Christ-child\n"
            "11F42|Madonna: Mary sitting or enthroned, the Christ-child in her lap\n"
            "11F422|Mary sitting or enthroned, the Christ-child on her knee\n")
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
        alternatives = base / "alternatives_index.pl"
        janus.query_once(f"specialisation:construire_alternatives('{alternatives}')")
        janus.query_once(f"load_files('{alternatives}', [redefine_module(true)])")
        janus.consult(str(SOCLE / "noms.pl"))
        gabarits = base / "gabarits_index.pl"
        janus.query_once(f"noms:construire_gabarits('{gabarits}')")
        janus.query_once(f"load_files('{gabarits}', [redefine_module(true)])")
        # le lion nommé se dit par son nom ; « kneeling figure », par ses deux mots
        assert janus.query_once("specialisation:alternatives('25F23(LION)', X)")["X"] == [["lion"]]
        assert janus.query_once("specialisation:alternatives('31A231', X)")["X"] == [["figure", "kneeling"]]
        janus.query_once("specialisation:decrire")
        # mots propres de 31A231 : « kneeling » (décrit) et « figure » (non décrit) → la moitié
        assert janus.query_once("specialisation:part_decrite('31A231', P)")["P"] == 0.5
        s = janus.query_once("specialisation:specialisees(['31A23', '25F23'], S)")["S"]
        assert set(s) == {"31A231", "25F23(LION)"}, s
        # explications par unité : le lion nommé est dit par une même unité (persons, « lion and skull ») ; 31A231
        # ne l'est qu'à moitié (« figure » manque) ; une entrée « kneeling figure » le décrit entièrement
        assert janus.query_once("specialisation:pleine_dans('25F23(LION)', U)")["U"] == "persons[0]"
        assert janus.query_once("specialisation:pleine_dans('31A231', _)")["truth"] is False
        # un nom se dit par ses mots, quels que soient leur ordre et la ponctuation ; une notation absente de l'index
        # (ici, hors des notations de l'essai) prend ses alternatives calculées
        a = janus.query_once("specialisation:alternatives('83(TASSO, Gerusalemme Liberata)', A)")["A"]
        assert a == [["gerusalemme", "liberata", "tasso"]], a
        fd.charger(janus, dict(DESCRIPTION, subject={"title": "Armida and Rinaldo",
                                                     "source": "Torquato Tasso, Gerusalemme Liberata, canto XIV"}))
        janus.query_once("specialisation:decrire")
        u = {x["U"] for x in janus.query("specialisation:pleine_dans('83(TASSO, Gerusalemme Liberata)', U)")}
        assert u == {"subject"}, u
        fd.charger(janus, dict(DESCRIPTION, keywords=["kneeling figure"]))
        janus.query_once("specialisation:decrire")
        assert janus.query_once("specialisation:pleine_dans('31A231', U)")["U"] == "keywords[0]"
        x = janus.query_once("specialisation:explications(['31A231', '25F23(LION)', '31A23'], X)")["X"]
        assert x == ["25F23(LION)", "31A231"], x
        # par le pont WordNet : la lionne dit « lion » (hyperonyme) et rend le lion nommé plein dans son entité ; le
        # félin ne le dit pas (ce serait l'hyponyme) ; « HIERONYMUS » dit « jerome » (synonyme) ; la relation où la
        # lionne est regardée (relations[0]) la dit aussi
        u = {x["U"] for x in janus.query("specialisation:pleine_large_dans('25F23(LION)', U)")}
        assert u == {"persons[0]", "entities[1]", "relations[0]"}, u
        assert janus.query_once("specialisation:decrit_pont(jerome, 'texts[0]')")["truth"]
        assert not janus.query_once("specialisation:decrit_pont(lion, 'entities[2]')")["truth"]
        # une relation dit un événement et ses participants : « e1 looks_at e2 » reçoit « old man » et « lioness »
        assert janus.query_once("specialisation:decrit_dans(lioness, 'relations[0]')")["truth"]
        assert janus.query_once("specialisation:decrit_dans(man, 'relations[0]')")["truth"]
        assert not janus.query_once("specialisation:decrit_dans(feline, 'relations[0]')")["truth"]   # e3 n'y est pas
        x = janus.query_once("specialisation:explications_pont(['31A231', '25F23(LION)', '31A23', '25F23'], X)")["X"]
        assert x == ["25F23(LION)", "31A231"], x
        # « kneeling figure ~ portrait » : l'unité dit « kneeling figure », mais rien ne dit le portrait → pas pleine ;
        # dès que la description le dit (ailleurs), elle l'est
        assert not janus.query_once("specialisation:pleine_dans('31A232', _)")["truth"]
        fd.charger(janus, dict(DESCRIPTION, keywords=["kneeling figure", "portrait"]))
        janus.query_once("specialisation:decrire")
        assert janus.query_once("specialisation:pleine_dans('31A232', U)")["U"] == "keywords[0]"

        # cadres des libellés : la tête de chaque élément, ses modificateurs, ses compléments, le contexte, la phase
        janus.consult(str(SOCLE / "cadres.pl"))
        def cadre(n):
            return janus.query_once("cadres:cadre(N, _C), term_string(_C, S)", {"N": n})["S"]
        assert cadre("31A232") == "cadre([],[element([tete(figure,[kneeling])],[])],[portrait])"
        assert cadre("25F23(LION)") == "cadre([],[element([tete(lion,[])],[])],[])"
        assert cadre("11F422") == ("cadre([],[element([tete(mary,[sitting]),tete(action(enthroned),[])],[]),"
                                   "element([tete('christ-child',[])],[knee])],[])")
        # preuve du cadre : la lionne (une espèce de lion) et « lion and skull » prouvent 25F23(LION) là où elles
        # le disent ; « kneeling figure » prouve 31A232 dans son unité, le portrait étant dit ailleurs
        janus.query_once("cadres:preparer_cadres")
        assert janus.query_once("cadres:pleine_et_cadree('31A232', U)")["U"] == "keywords[0]"
        fd.charger(janus, DESCRIPTION)
        janus.query_once("specialisation:decrire")
        janus.query_once("cadres:preparer_cadres")
        u = {x["U"] for x in janus.query("cadres:pleine_et_cadree('25F23(LION)', U)")}
        assert u == {"persons[0]", "entities[1]", "relations[0]"}, u
        # têtes des phrases de la description, lues par la grammaire des libellés : « Saint Jerome in the wilderness »
        # a pour tête Jérôme, la nature sauvage n'en est que le lieu ; une relation a pour têtes celles de ses
        # participants ; la preuve par les têtes garde ici les trois unités du lion
        assert janus.query_once("cadres:tete_dans(jerome, subject)")["truth"]
        assert not janus.query_once("cadres:tete_dans(wilderness, subject)")["truth"]
        assert janus.query_once("cadres:tete_dans(man, 'relations[0]')")["truth"]
        u = {x["U"] for x in janus.query("cadres:pleine_et_cadree_par_tete('25F23(LION)', U)")}
        assert u == {"persons[0]", "entities[1]", "relations[0]"}, u
        # 11F422 est pleine par « bare knee » (son seul mot propre), mais son cadre veut Marie ou l'Enfant : rien
        # ne les dit → pas d'explication selon le cadre
        fd.charger(janus, dict(DESCRIPTION, keywords=["bare knee"]))
        janus.query_once("specialisation:decrire")
        janus.query_once("cadres:preparer_cadres")
        assert janus.query_once("specialisation:pleine_large_dans('11F422', 'keywords[0]')")["truth"]
        assert not janus.query_once("cadres:pleine_et_cadree('11F422', _)")["truth"]
        # une mention niée ne dit rien : « no lion » ne donne pas la forme « lion »
        fd.charger(janus, dict(DESCRIPTION, keywords=["no lion"]))
        assert not janus.query_once("description:mention(_M, keywords, _, _), recherche:forme_mention(_M, lion)")["truth"]
        fd.charger(janus, DESCRIPTION)
        janus.query_once("specialisation:decrire")

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
        assert t["explication"] == 1 and t["unites_pleines"] == 1, t       # « lion and skull » le dit entièrement
        assert t["explication_pont"] == 1 and t["unites_pleines_pont"] == 3, t     # la lionne et son regard, par le pont
        # couverture : dans « Saint Jerome / lion and skull » (persons[0]), le lion ne rend compte que d'un mot sur
        # quatre, Jérôme de bien plus (son nom, et le lion et le crâne, ses attributs possibles) : c'est lui qui
        # explique l'unité ; « lioness » n'est pas une entrée du lion (il n'y vient que par le pont)
        assert abs(t["couverture_max"] - 0.25) < 1e-9 and "meilleure_couverture" not in t, t
        jr = dict(janus.query_once("traits:candidats_traits(10, _L), member(['11H(JEROME)', _, _T], _L), "
                                   "findall([_K, _V], member(_K-_V, _T), X)")["X"])
        assert jr["meilleure_couverture"] == 1 and jr["couverture_max"] >= 0.75, jr
        # explication économe : Jérôme, qui rend compte du plus, est choisi le premier ; le lion n'y vient pas avant lui
        assert jr["rang_econome"] == 1.0 and jr["apport_econome"] > 0, jr
        assert t.get("rang_econome", 0) < 1, t
        # structure : pleine dans une personne, une entité et une relation, 3 des 9 unités décrites ; une concurrente,
        # Jérôme, plein dans la même personne (« Saint Jerome… lion and skull ») ; la plus précise de ses unités
        assert t["plein_persons"] == 1 and t["plein_entities"] == 1 and "plein_subject" not in t, t
        assert t.get("plein_relations") == 1, t
        assert abs(t["part_unites"] - 3 / 9) < 1e-4 and t["concurrents"] == 1 and t["ecart_profondeur_plus_un"] == 1, t
        j = dict(janus.query_once("traits:candidats_traits(10, _L), member(['11H(JEROME)', _, _T], _L), "
                                  "findall([_K, _V], member(_K-_V, _T), X)")["X"])
        assert j["plein_subject"] == 1 and j["plein_texts"] == 1 and j["concurrents"] == 1, j    # « HIERONYMUS »
        a = dict(janus.query_once("traits:candidats_traits(10, _L), member(['25F2', _, _T], _L), "
                                  "findall([_K, _V], member(_K-_V, _T), X)")["X"])
        assert a.get("ancetre_seul") == 1 and a.get("enfants_candidats", 0) >= 1, a
        fd.charger(janus, dict(DESCRIPTION, keywords=["kneeling figure"]))
        k = dict(janus.query_once("traits:candidats_traits(10, _L), member(['31A231', _, _T], _L), "
                                  "findall([_K, _V], member(_K-_V, _T), X)")["X"])
        assert k["explication"] == 1 and k["unites_pleines"] == 1, k

        # gabarit à nom : « insects (with NAME) » range surtout des noms communs (ANT) ; la description dit « a
        # butterfly » et « an ant » : WordNet range le papillon parmi les insectes → 25F711(BUTTERFLY), écrit en
        # capitales ; la fourmi est déjà listée (25F711(ANT)) : rien n'est inventé pour elle
        assert janus.query_once("gabarits_index:sorte(_, '25F711(...)')")["truth"]
        fd.charger(janus, dict(DESCRIPTION, keywords=["a butterfly", "an ant"]))
        janus.query_once("abolish_all_tables")
        janus.query_once("specialisation:decrire")
        g = janus.query_once("noms:gabarits_decrits(_L), findall([_C, _W, _D], member(nomme(_C, _W, _D), _L), X)")["X"]
        assert [c for c, _, _ in g] == ["25F711(BUTTERFLY)"] and g[0][1] == "butterfly" and g[0][2] >= 1, g
        b = dict(janus.query_once("traits:candidats_traits(10, _L), member(['25F711(BUTTERFLY)', _, _T], _L), "
                                  "findall([_K, _V], member(_K-_V, _T), X)")["X"])
        assert b["nomme_gabarit"] == 1 and b["pas_taxonomiques"] >= 1 and b["plein_keywords"] == 1, b
        assert "ancetre_seul" not in b, b

        # « half-length » se lit aussi « half », « length »
        assert janus.query_once("recherche:forme_mention(_, length)")["truth"] is False  # pas encore décrit
        fd.charger(janus, dict(DESCRIPTION, keywords=["half-length portrait"]))
        assert janus.query_once("recherche:forme_mention(_, length)")["truth"]
        assert janus.query_once("recherche:forme_mention(_, 'half-length')")["truth"]
