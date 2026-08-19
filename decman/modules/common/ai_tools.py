import decman
from decman.plugins import aur, pacman

from modules.common.archlinux import has_repo

_NATIVE_OR_AUR = {"chatgpt-desktop-bin"}

class AIToolsModule(decman.Module):
    def __init__(self):
        super().__init__("ai_tools")

    @pacman.packages
    def pkgs(self) -> set[str]:
        base = {
            "aichat",
            # "opencode", # out of date in AUR
        }
        if has_repo("cachyos"):
            base |= _NATIVE_OR_AUR
        return base

    @aur.packages
    def aurpkgs(self) -> set[str]:
        return {
            "dabri",
            "rtk-bin",
        }
