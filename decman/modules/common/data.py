import decman
from decman.plugins import pacman, aur


class DataModule(decman.Module):
    """Data tooling: databases, backups, container images, AI clients.

    Catch-all for data-adjacent CLI utilities that don't fit DevModule
    or KubernetesModule cleanly.
    """

    def __init__(self):
        super().__init__("data")

    @pacman.packages
    def pkgs(self) -> set[str]:
        return {
            "calibre",
            "postgresql",
            "restic",
            "serie",
            "skopeo",
        }

    @aur.packages
    def aurpkgs(self) -> set[str]:
        return {
            "kopia-bin",
            "pgloader",
            "vendir",
            "ytt",
        }
