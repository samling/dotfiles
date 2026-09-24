import decman
from decman.plugins import pacman, aur

from modules._paths import PKGBUILDS as _PKGBUILDS


class CloudModule(decman.Module):

    def __init__(self):
        super().__init__("cloud")

    @pacman.packages
    def pkgs(self) -> set[str]:
        return {
            "aws-cli-v2"
        }

    @aur.packages
    def aurpkgs(self) -> set[str]:
        return set()
