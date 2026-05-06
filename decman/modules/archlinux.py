import decman
from decman.plugins import pacman, aur


def _has_eos_repo() -> bool:
    """True if /etc/pacman.conf has the endeavouros repo enabled.

    The same packages (paru, yay, downgrade, reflector-simple) ship from
    the EOS native repo on EndeavourOS but must be built from the AUR on
    pure Arch. Switch the declaration based on what's actually available.
    """
    try:
        with open("/etc/pacman.conf") as f:
            for line in f:
                stripped = line.strip()
                if stripped.startswith("#"):
                    continue
                if stripped == "[endeavouros]":
                    return True
    except FileNotFoundError:
        pass
    return False


_EOS_OR_AUR = {"downgrade", "paru", "yay"}


class ArchlinuxModule(decman.Module):

    def __init__(self):
        super().__init__("archlinux")

    @pacman.packages
    def pkgs(self) -> set[str]:
        base = {
            "pacman-contrib",
            "pkgfile",
            "rebuild-detector",
            "reflector",
        }
        if _has_eos_repo():
            base |= _EOS_OR_AUR
        return base

    @aur.packages
    def aurpkgs(self) -> set[str]:
        base = {
            # Runtime dep of decman itself.
            "python-iniparse-git",
        }
        if not _has_eos_repo():
            base |= _EOS_OR_AUR
        return base
