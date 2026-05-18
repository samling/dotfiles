import decman
from decman.plugins import pacman, aur, systemd

from modules._paths import PKGBUILDS as _PKGBUILDS
from modules._systemd import reconcile_units


class DockerModule(decman.Module):
    """Docker daemon. Membership in the `docker` group is added by
    UsersModule when callers pass docker into extra_groups.

    `docker-sbx-bin` is a local PKGBUILD (pkgbuilds/docker-sbx-bin/)
    instead of the AUR `docker-sandbox-bin`. The latter ships only
    /usr/bin/sbx and is missing the bundled libkrun.so, mkfs.erofs,
    nerdbox-kernel, and nerdbox-initrd under /usr/libexec/ that sbx
    resolves relative to its own binary. Without them sandboxd
    cannot bring up a microVM via libkrun and falls back to a
    host-side ext4-on-loop mount path that needs CAP_SYS_ADMIN -
    which a non-root user-mode daemon cannot satisfy, so sandbox
    creation fails with EPERM on mount(). The local PKGBUILD pulls
    the upstream tarball from docker/sbx-releases and installs the
    full libexec tree, so the microVM path works and no host loop
    devices are involved.

    `erofs-utils` (mkfs.erofs in $PATH) is still listed because the
    host-side containerd inside sandboxd probes for it and skips its
    EROFS differ plugin when missing. sbx ships its own copy under
    /usr/libexec, but that isn't on containerd's PATH.
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
        }

    @aur.custom_packages
    def custompkgs(self) -> set[aur.CustomPackage]:
        return {
            aur.CustomPackage(
                pkgname="docker-sbx-bin",
                pkgbuild_directory=str(_PKGBUILDS / "docker-sbx-bin"),
            ),
        }

    @systemd.units
    def units(self) -> set[str]:
        return {"docker.service"}

    def on_change(self, store):
        reconcile_units(self, store)
