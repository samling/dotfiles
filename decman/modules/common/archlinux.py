import decman
from decman.plugins import pacman, aur


def has_repo(name: str) -> bool:
    """True if /etc/pacman.conf has the named repo section enabled.

    Used by modules whose packages may ship as native binaries on some
    Arch derivatives (EOS, CachyOS) and need to be declared via
    @pacman.packages there but @aur.packages elsewhere, so decman
    doesn't needlessly rebuild from AUR.
    """
    try:
        with open("/etc/pacman.conf") as f:
            for line in f:
                stripped = line.strip()
                if stripped.startswith("#"):
                    continue
                if stripped == f"[{name}]":
                    return True
    except FileNotFoundError:
        pass
    return False


def _has_eos_repo() -> bool:
    return has_repo("endeavouros")


def _has_native_aur_helper_repo() -> bool:
    """True if the host distro ships paru / yay / downgrade as native
    binaries (currently EOS or CachyOS). On other Arch derivatives,
    these come from the AUR.
    """
    return _has_eos_repo() or has_repo("cachyos")


_NATIVE_OR_AUR = {"downgrade", "paru", "yay"}


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
        if _has_native_aur_helper_repo():
            base |= _NATIVE_OR_AUR
        return base

    @aur.packages
    def aurpkgs(self) -> set[str]:
        base = {
            # Runtime dep of decman itself.
            # "python-iniparse-git",
        }
        if not _has_native_aur_helper_repo():
            base |= _NATIVE_OR_AUR
        return base
