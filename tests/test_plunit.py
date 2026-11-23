"""Les tests Prolog (plunit) de tests/plunit, lancés par swipl : un fichier, un processus."""
import shutil
import subprocess
from pathlib import Path

import pytest

ICI = Path(__file__).resolve().parent / "plunit"


@pytest.mark.skipif(shutil.which("swipl") is None, reason="swipl absent")
@pytest.mark.parametrize("fichier", sorted(ICI.glob("test_*.pl")), ids=lambda p: p.stem)
def test_plunit(fichier):
    r = subprocess.run(["swipl", "-g", "run_tests", "-t", "halt", str(fichier)], capture_output=True, text=True,
                       cwd=fichier.parent, env={"LANG": "C.UTF-8", "PATH": "/usr/bin:/bin:/usr/local/bin"})
    assert r.returncode == 0, r.stdout + r.stderr
