import decman
from decman.plugins import aur, pacman

from modules.common.archlinux import has_repo

# parsec-bin lives in the CachyOS native repo but is AUR-only on
# EOS / vanilla Arch. Mirrors the pattern in modules.gui.wm.
_NATIVE_OR_AUR = {"parsec-bin"}


class RemoteDesktopModule(decman.Module):
    """Remote-desktop clients (Parsec)."""

    def __init__(self):
        super().__init__("remote_desktop")

    @pacman.packages
    def pkgs(self) -> set[str]:
        base: set[str] = set()
        if has_repo("cachyos"):
            base |= _NATIVE_OR_AUR
        return base

    @aur.packages
    def aurpkgs(self) -> set[str]:
        base: set[str] = {
            "rustdesk-bin",
        }
        if not has_repo("cachyos"):
            base |= _NATIVE_OR_AUR
        return base
