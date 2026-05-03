import decman
from decman.plugins import pacman, aur


class ArchlinuxModule(decman.Module):

    def __init__(self):
        super().__init__("archlinux")

    @pacman.packages
    def pkgs(self) -> set[str]:
        return {
            "downgrade",
            "pacman-contrib",
            "paru",
            "pkgfile",
            "rebuild-detector",
            "reflector",
            "reflector-simple",
            "yay",
        }

    @aur.packages
    def aurpkgs(self) -> set[str]:
        # Runtime dep of decman itself.
        return {"python-iniparse-git"}
