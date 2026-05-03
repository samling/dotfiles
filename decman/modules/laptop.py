import decman
from decman.plugins import pacman, aur


class LaptopModule(decman.Module):

    def __init__(self):
        super().__init__("laptop")

    @pacman.packages
    def pkgs(self) -> set[str]:
        return {"keyd"}

    @aur.packages
    def aurpkgs(self) -> set[str]:
        return {"asus-5606-fan-state"}
