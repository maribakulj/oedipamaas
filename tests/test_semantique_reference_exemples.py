"""Les cas réels des bancs dans la syntaxe concrète (semantique_reference/exemples/), évalués par l'interpréteur et
comparés à leur référence adjugée, copiée dans chaque dossier sans modification (docs/LANGAGE_REFERENCE.md, § 8).

Chaque cas déclare sa comparaison : `egal` (le statut calculé est celui de la référence), ou `ecart` (avec le statut
calculé et la raison : la représentation, K, ou une référence discutable). Le test vérifie la déclaration ; il ne
change pas la référence."""
from __future__ import annotations

import json
import sys
from pathlib import Path

import pytest

ICI = Path(__file__).resolve().parent
sys.path.insert(0, str(ICI.parent))

from semantique_reference import banc, formation, interprete as I, json_concret as J  # noqa: E402

DOSSIERS = banc.dossiers()


def test_cinq_dossiers():
    assert {p.stem for p in DOSSIERS} >= {"ee-002", "mn-004", "rq-010", "pi-003", "co-018"}


@pytest.mark.parametrize("chemin", DOSSIERS, ids=[p.stem for p in DOSSIERS])
def test_dossier(chemin):
    d = json.loads(chemin.read_text(encoding="utf-8"))
    for x in d["cas"]:
        c = J.lire_cas(x)
        assert formation.verifier(c) == [], [str(f) for f in formation.verifier(c)]
        # la provenance cite le texte : chaque extrait est à ses offsets
        for a in c.description.assertions:
            p = a.provenance
            if p.extrait is not None and p.debut is not None:
                assert c.description.texte[p.debut:p.fin] == p.extrait, (c.id, a.id)
    for (ident, niveau, calc, ref, comp, det) in banc.evaluer_dossier(chemin):
        if comp["attendu"] == "egal":
            assert calc == ref, (ident, calc, ref, det)
        else:
            assert calc != ref and calc == comp["statut_calcule"] and comp["raison"], (ident, calc, ref)


def test_ee002_traduction_meme_profil():
    """Étude § 2.7 : la traduction anglaise d'ee-002 a le même profil que la description française (en (a))."""
    d = json.loads((ICI.parent / "semantique_reference" / "exemples" / "ee-002.json").read_text(encoding="utf-8"))
    cas = {x["id"]: J.lire_cas(x) for x in d["cas"]}
    a, b = I.evaluer(cas["ee-002 (a)"]), I.evaluer(cas["ee-002#0 (a)"])
    assert [cl.statut for cl in a.profils[I.RACINE].classes] == [cl.statut for cl in b.profils[I.RACINE].classes]
    assert a.principal.nom == b.principal.nom == "etablie"


def test_ee002_b_le_cylindre_et_la_composante():
    """ee-002 au niveau (b) (étude § 1.1, § 3.7 (e)) : la restriction de sélection (attestée avec l'incompatibilité
    artefact / animé) exclut la pièce d'échecs et les sens de document, sur la composante {tendre, cavalier} ; il
    reste six sens de personne × deux sens de « horseman » ; une seule classe établit, sous le choix conjoint."""
    d = json.loads((ICI.parent / "semantique_reference" / "exemples" / "ee-002.json").read_text(encoding="utf-8"))
    c = J.lire_cas(next(x for x in d["cas"] if x["id"] == "ee-002 (b)"))
    I_ = I.interpretations_admissibles(c)
    assert len(I_) == 12 and {i["pe"] for i in I_} == {"oc:tendre_transfert"}
    assert not any(i["pc"] in ("oc:piece_echecs", "oc:rider_clause", "oc:check_addition") for i in I_)
    comp = I.composantes(I.points_du_cas(c), I.contraintes_du_cas(c))
    assert {"pc", "pe"} in comp
    s = I.evaluer(c).principal
    assert s.couverture_plus == [{"pc": ("wn30:10185793-n",), "ph": ("wn30:10185793-n",)}]


def test_rq010_et_co018_par_cas():
    d = json.loads((ICI.parent / "semantique_reference" / "exemples" / "rq-010.json").read_text(encoding="utf-8"))
    c = J.lire_cas(d["cas"][0])
    ev = I.evaluer(c)
    assert ev.principal.nom == "etablie" and not ev.principal.uniforme_plus
    d = json.loads((ICI.parent / "semantique_reference" / "exemples" / "co-018.json").read_text(encoding="utf-8"))
    alt, un = (I.evaluer(J.lire_cas(x)) for x in d["cas"])
    assert alt.principal.nom == un.principal.nom == "etablie" and un.principal.uniforme_plus
