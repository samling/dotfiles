import decman
from decman.plugins import pacman, aur

class BaseModule(decman.Module):

    def __init__(self):
        # I'll intend this module to be a singleton (only one instance ever),
        # so I'll inline the module name
        super().__init__("base")

    @pacman.packages
    def pkgs(self) -> set[str]:
        return {
            "base",
            "base-devel",
            "btrfs-progs",
            "dosfstools",
            "efibootmgr",
            "efitools",
            "git",
            "linux",
            "linux-firmware",
            "linux-headers",
            "linux-lts",
            "linux-lts-headers",
        }

    @aur.packages
    def aurpkgs(self) -> set[str]:
        return {"decman"}
