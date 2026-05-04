import decman
from decman.plugins import pacman, aur, systemd

from modules._systemd import reconcile_units


class DockerModule(decman.Module):
    """Docker daemon. Membership in the `docker` group is added by
    UsersModule when callers pass docker into extra_groups.
    """

    def __init__(self):
        super().__init__("docker")

    @pacman.packages
    def pkgs(self) -> set[str]:
        return {
            "docker",
            "docker-buildx",
            "docker-compose",
        }

    @aur.packages
    def aurpkgs(self) -> set[str]:
        return {
            "docker-sandbox-bin",
        }

    @systemd.units
    def units(self) -> set[str]:
        return {"docker.service"}

    def on_change(self, store):
        reconcile_units(self, store)
