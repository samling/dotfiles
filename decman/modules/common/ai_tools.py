import decman
from decman.plugins import aur, pacman, systemd

from modules._systemd import reconcile_units
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
            "paseo-desktop-bin",
            "rtk-bin",
        }

    @systemd.user_units
    def user_units(self) -> dict[str, set[str]]:
        return {
            "sboynton": {
                "paseo.service",
            },
        }

    def on_change(self, store):
        reconcile_units(self, store)
