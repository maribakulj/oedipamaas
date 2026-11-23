"""Les tests Prolog (plunit) de tests/plunit, lancés par swipl : un fichier, un processus. Les tests d'UDPipe
demandent OEDIPAMAAS_UDPIPE (le binaire) et OEDIPAMAAS_MODELES (le dossier des modèles), ceux de bout en bout aussi
OEDIPAMAAS_BASE (la base compilée) ; sinon ils sont sautés."""
import os
import shutil
import subprocess
from pathlib import Path

import pytest

ICI = Path(__file__).resolve().parent / "plunit"


@pytest.mark.skipif(shutil.which("swipl") is None, reason="swipl absent")
@pytest.mark.parametrize("fichier", sorted(ICI.glob("test_*.pl")), ids=lambda p: p.stem)
def test_plunit(fichier):
    r = subprocess.run(["swipl", "-g", "run_tests", "-t", "halt", str(fichier)], capture_output=True, text=True,
                       cwd=fichier.parent, env={**os.environ, "LANG": "C.UTF-8"})
    assert r.returncode == 0, r.stdout + r.stderr
