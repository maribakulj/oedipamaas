"""L'oracle Python du noyau (tests/oracle/oracle_noyau.py), écrit d'après docs/NOYAU.md seul, confronté aux deux
moteurs Prolog sur des cas tirés (graine fixe) : aucun désaccord (journal de qualification, D16)."""
import shutil
import subprocess
import sys
from pathlib import Path

import pytest

ICI = Path(__file__).resolve().parent


@pytest.mark.skipif(shutil.which("swipl") is None, reason="swipl absent")
@pytest.mark.parametrize("args", [["-n", "300"], ["-n", "300", "--jeu", "gen"]], ids=["oracle", "gen"])
def test_oracle_sans_desaccord(args, tmp_path):
    r = subprocess.run([sys.executable, str(ICI / "oracle" / "differentiel.py"), *args, "--sans-minimisation",
                        "--sortie", str(tmp_path / "desaccords.json")], capture_output=True, text=True, timeout=1800)
    assert r.returncode == 0, r.stdout + r.stderr
    assert "désaccords : 0" in r.stdout, r.stdout
