import decman
from decman.plugins import aur, pacman

from modules.common.archlinux import has_repo

class GuiHardwareModule(decman.Module):
    """Hardware clients."""

    def __init__(self):
        super().__init__("hardware")

    @pacman.packages
    def pkgs(self) -> set[str]:
        # return {
        #     "solaar"
        # }
        return set()

    @aur.packages
    def aurpkgs(self) -> set[str]:
        return {
            "logiops"
        }
