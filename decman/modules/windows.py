import decman
from decman.plugins import aur, pacman


class WindowsModule(decman.Module):
    """Windows interop and cross-compilation tooling. Loaded only on
    hosts that target Windows (currently WSL); the mingw toolchain is
    over a gigabyte and isn't worth carrying on Linux-only hosts.
    """

    def __init__(self):
        super().__init__("windows")

    @pacman.packages
    def pkgs(self) -> set[str]:
        return {
            "mingw-w64-gcc",
        }

    @aur.packages
    def aurpkgs(self) -> set[str]:
        return {
            "win32yank-bin",
        }
