import decman
from decman.plugins import pacman, aur


class ArchlinuxModule(decman.Module):

    def __init__(self):
        super().__init__("archlinux")

    @pacman.packages
    def pkgs(self) -> set[str]:
        return {
            "pacman-contrib",
            "pkgfile",
            "rebuild-detector",
            "reflector",
        }

    @aur.packages
    def aurpkgs(self) -> set[str]:
        return {
            "downgrade",
            "paru",
            # Runtime dep of decman itself.
            "python-iniparse-git",
            "reflector-simple",
            "yay",
        }
