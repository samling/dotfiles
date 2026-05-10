import decman
from decman.plugins import pacman, systemd

from modules._systemd import reconcile_units


class KernelModule(decman.Module):
    """Linux kernel, kernel firmware, microcode, initramfs, zram.

    Hardware-host concerns. Do NOT include in WSL roles — WSL2 boots
    the Microsoft kernel, dracut has no /boot to write to, and zram
    duplicates the .wslconfig swap setting.
    """

    def __init__(self):
        super().__init__("host_kernel")

    @pacman.packages
    def pkgs(self) -> set[str]:
        return {
            "amd-ucode",
            "b43-fwcutter",
            "dracut",
            "kernel-install-for-dracut",
            "linux",
            "linux-firmware",
            "linux-headers",
            "linux-lts",
            "linux-lts-headers",
            "sof-firmware",
            "wireless-regdb",
            "zram-generator",
        }

    @systemd.units
    def units(self) -> set[str]:
        return set()

    def on_change(self, store):
        reconcile_units(self, store)

    def files(self) -> dict[str, decman.File]:
        return {
            # ram/2 matches NixOS' zramSwap.enable default; cap at 8G so
            # a 64G workstation doesn't reserve 32G.
            "/etc/systemd/zram-generator.conf": decman.File(
                content=(
                    "[zram0]\n"
                    "zram-size = min(ram / 2, 8192)\n"
                    "compression-algorithm = zstd\n"
                ),
                permissions=0o644,
                owner="root",
                group="root",
            ),
        }
