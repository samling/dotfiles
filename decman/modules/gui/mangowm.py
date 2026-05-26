import decman
from decman.plugins import pacman, aur, systemd

from modules._systemd import reconcile_units


class MangoModule(decman.Module):
    """mangowm compositor + extras. Kept separate from WmModule so future
    non-mangowm hosts can opt out without touching the shared wm pieces.
    """

    def __init__(self):
        super().__init__("mangowm")

    @pacman.packages
    def pkgs(self) -> set[str]:
        return set()

    @aur.packages
    def aurpkgs(self) -> set[str]:
        return {
            "mangowm-git",
        }
