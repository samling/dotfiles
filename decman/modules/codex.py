from pathlib import Path

import decman
from decman.plugins import pacman

from modules._systemd import reconcile_units

# Absolute path to the repo's pkgbuilds/ dir. decman chdirs into a
# temp build dir before copying PKGBUILDs, so relative paths break.
_PKGBUILDS = Path(__file__).resolve().parents[2] / "pkgbuilds"


class CodexModule(decman.Module):
    def __init__(self):
        super().__init__("codex")

    @pacman.packages
    def pkgs(self) -> set[str]:
        return {
            "openai-codex",
        }
