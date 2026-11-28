"""La mesure du moteur actuel sur les bancs de la phase 1 (outils/bancs/mesurer_moteur.py ; docs/mesures/
MESURE_INITIALE_BANCS.md) : la comparaison des statuts par ce qu'ils affirment, et, sur trois cas, que la mesure tourne
de bout en bout et ne modifie aucun fichier de cas. La partie de bout en bout demande la base, les cas et les
analyseurs ; sans eux, elle est sautée."""
import hashlib, json, os, pathlib, shutil, subprocess, sys

import pytest

R = pathlib.Path(__file__).resolve().parent.parent
sys.path.insert(0, str(R / "outils" / "bancs"))
import mesurer_moteur as mm  # noqa: E402

DEV = pathlib.Path(os.environ.get("OEDIPAMAAS_BANCS_DEV", "/home/user/donnees/bancs_phase1/dev"))
BASE = pathlib.Path(os.environ.get("OEDIPAMAAS_BASE", "/home/user/donnees/base"))
CAS = ["ee-001", "rq-014", "co-018"]


def test_comparer_par_les_affirmations():
    assert mm.comparer("etablie", "etablie") == "accord"
    assert mm.comparer("inconnue", "incomplet") == "accord"          # ni l'un ni l'autre n'affirme rien
    assert mm.comparer("etablie", "etablie_sous_hypotheses") == "plus_fort"
    assert mm.comparer("etablie_sous_hypotheses", "inconnue") == "plus_fort"
    assert mm.comparer("ecartee", "inconnue") == "plus_fort"
    assert mm.comparer("etablie", "ecartee") == "plus_fort"           # incomparable : la sûreté prime
    assert mm.comparer("inconnue", "etablie") == "plus_faible"
    assert mm.comparer("non_certifiee", "etablie") == "plus_faible"
    assert mm.comparer("sans_requete", "ecartee") == "plus_faible"
    assert mm.comparer("etablie", None) is None


def test_surete_stricte():
    assert mm.surete_stricte("etablie", "non_certifiee")
    assert mm.surete_stricte("ecartee", "inconnue")
    assert not mm.surete_stricte("etablie_sous_hypotheses", "inconnue")
    assert not mm.surete_stricte("ecartee", "contradictoire")


def empreintes(d):
    return {f.name: hashlib.sha256(f.read_bytes()).hexdigest() for f in sorted(d.iterdir()) if f.is_file()}


@pytest.fixture(scope="module")
def mesure(tmp_path_factory):
    if not (DEV.is_dir() and (BASE / "wordnet.qlf").exists() and shutil.which("swipl")
            and os.environ.get("OEDIPAMAAS_UDPIPE") and os.environ.get("OEDIPAMAAS_MODELES")):
        pytest.skip("la base, les cas ou les analyseurs manquent")
    try:
        import stanza  # noqa: F401
    except ImportError:
        pytest.skip("Stanza manque")
    t = tmp_path_factory.mktemp("mesure")
    # une référence (a) factice, pour vérifier que la colonne se calcule dès que le fichier existe
    ref = t / "reference.json"
    ref.write_text(json.dumps({"rq-014": {"statut_synthetique": "ecartee", "variantes": {"0": "ecartee"}}}))
    avant = empreintes(DEV)
    sortie = t / "resultats.json"
    p = subprocess.run([sys.executable, str(R / "outils/bancs/mesurer_moteur.py"), "--dev", str(DEV), "--base", str(BASE),
                        "--cas", ",".join(CAS), "--sortie", str(sortie), "--reference", str(ref)],
                       capture_output=True, text=True, timeout=600)
    assert p.returncode == 0, p.stderr[-3000:]
    return avant, empreintes(DEV), json.loads(sortie.read_text())


def test_les_cas_ne_sont_pas_modifies(mesure):
    avant, apres, r = mesure
    assert avant == apres
    assert r["cas_inchanges"] is True
    assert r["empreintes_des_cas"] == {k: v for k, v in avant.items() if k.endswith(".json")}


def test_chaque_variante_est_mesuree(mesure):
    _, _, r = mesure
    cas = {c["id"]: c for f in DEV.glob("*.json") for c in json.loads(f.read_text())}
    assert sorted(c["id"] for c in r["cas"]) == sorted(CAS)
    permis = set(mm.STATUTS)
    for c in r["cas"]:
        assert len(c["elements"]) == 1 + len(cas[c["id"]]["variantes"])
        assert c["adaptateur"]["statut_compilation"] in ("compilee", "partielle", "non_prise_en_charge", "invalide")
        assert c["adaptateur"]["chemin_reel"]
        for e in c["elements"]:
            assert e["statut_c"] in permis
            assert e["statut_b"] == (cas[c["id"]] if e["n"] == "base" else cas[c["id"]]["variantes"][e["n"]])["statut_attendu"]
            assert e["c_contre_b"] in ("accord", "plus_fort", "plus_faible")
            assert isinstance(e["faits"], list) and e["temps"]
    assert r["versions"]["moteur"]["commit"] and r["versions"]["noyau"]


def test_la_colonne_a_se_calcule_quand_la_reference_existe(mesure):
    _, _, r = mesure
    rq = next(c for c in r["cas"] if c["id"] == "rq-014")
    assert rq["elements"][0]["statut_a"] == "ecartee" and rq["elements"][0]["c_contre_a"] is not None
    assert rq["elements"][1]["statut_a"] == "ecartee"
    assert all(e["statut_a"] is None for c in r["cas"] if c["id"] != "rq-014" for e in c["elements"])
