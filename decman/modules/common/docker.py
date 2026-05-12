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
            "erofs-utils",
            "libkrun",
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

    def files(self) -> dict[str, decman.File]:
        return {
            # docker-sandbox's EROFS snapshotter mounts rwlayer.img files
            # via loopback. The loop module isn't autoloaded on CachyOS, so
            # the sandboxd daemon fails on /dev/loop-control with ENOENT
            # the first time it tries to start a container.
            "/etc/modules-load.d/loop.conf": decman.File(
                content="loop\n",
                permissions=0o644,
                owner="root",
                group="root",
            ),
        }
