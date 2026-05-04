import decman
from decman.plugins import pacman, aur


class SecurityModule(decman.Module):

    def __init__(self):
        super().__init__("security")

    @pacman.packages
    def pkgs(self) -> set[str]:
        return {
            "bitwarden-cli",
            "tailscale",
            "wireshark-qt",
        }

    @aur.packages
    def aurpkgs(self) -> set[str]:
        return {
            "doppler-cli-bin",
            # littlesnitch is a custom nix package; no AUR equivalent.
            # Ship via CustomPackage(pkgbuild_directory=...) once a
            # PKGBUILD exists. vkv is in AUR as vkv-bin.
            # "vkv-bin",
        }
