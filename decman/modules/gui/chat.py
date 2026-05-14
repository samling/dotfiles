import decman
from decman.plugins import aur, pacman

from modules.common.archlinux import has_repo

# vesktop-bin lives in the CachyOS native repo but is AUR-only on
# EOS / vanilla Arch. Mirrors the pattern in modules.gui.wm.
_NATIVE_OR_AUR = {"vesktop-bin"}


class ChatModule(decman.Module):
    """Chat clients."""

    def __init__(self):
        super().__init__("chat")

    @pacman.packages
    def pkgs(self) -> set[str]:
        base = {
            "signal-desktop"
        }
        if has_repo("cachyos"):
            base |= _NATIVE_OR_AUR
        return base

    @aur.packages
    def aurpkgs(self) -> set[str]:
        base: set[str] = set()
        if not has_repo("cachyos"):
            base |= _NATIVE_OR_AUR
        return base
