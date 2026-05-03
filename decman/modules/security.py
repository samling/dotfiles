import decman
from decman.plugins import pacman, aur


class SecurityModule(decman.Module):

    def __init__(self):
        super().__init__("security")

    @pacman.packages
    def pkgs(self) -> set[str]:
        return {"tailscale"}

    @aur.packages
    def aurpkgs(self) -> set[str]:
        return {"doppler-cli-bin"}
