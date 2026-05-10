import decman
from decman.plugins import pacman, systemd

from modules._systemd import reconcile_units


class SystemModule(decman.Module):
    """Generic CLI system utilities that work everywhere.

    Hardware-specific bits (kernel, hwinfo, raid, lvm, crypto,
    microcode, firmware, zram) live under `modules/host/`; the gui
    role pulls them in, WSL omits them. Generic filesystem userland
    (mkfs.*, fsck.*, ntfs-3g) lives in `modules.common.filesystems`
    and ships everywhere.
    """

    def __init__(self):
        super().__init__("system")

    @pacman.packages
    def pkgs(self) -> set[str]:
        return {
            "dialog",
            "diffutils",
            "ex-vi-compat",
            "haveged",
            "inetutils",
            "less",
            "logrotate",
            "lsb-release",
            "man-db",
            "man-pages",
            "mtools",
            "nano",
            "nano-syntax-highlighting",
            "openssh",
            "perl",
            "socat",
            "sudo",
            "sysfsutils",
            "systemd-sysvcompat",
            "texinfo",
            "which",
        }

    @systemd.units
    def units(self) -> set[str]:
        return {"systemd-oomd.service"}

    def on_change(self, store):
        reconcile_units(self, store)

    def files(self) -> dict[str, decman.File]:
        return {
            # Mirrors `systemd.oomd.enableUserSlices = true`.
            "/etc/systemd/system/user-.slice.d/50-oomd.conf": decman.File(
                content=(
                    "[Slice]\n"
                    "ManagedOOMSwap=auto\n"
                    "ManagedOOMMemoryPressure=kill\n"
                ),
                permissions=0o644,
                owner="root",
                group="root",
            ),
        }
