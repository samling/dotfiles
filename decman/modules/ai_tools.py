from pathlib import Path

import decman
from decman.plugins import aur, pacman

from modules._systemd import reconcile_units

# Absolute path to the repo's pkgbuilds/ dir. decman chdirs into a
# temp build dir before copying PKGBUILDs, so relative paths break.
_PKGBUILDS = Path(__file__).resolve().parents[2] / "pkgbuilds"


class AIToolsModule(decman.Module):
    def __init__(self):
        super().__init__("ai_tools")

    @aur.packages
    def aurpkgs(self) -> set[str]:
        return {
            "rtk",
        }
