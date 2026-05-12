import decman
from decman.plugins import pacman, systemd

from modules._systemd import reconcile_units


class KernelModule(decman.Module):
    """Microcode, kernel firmware blobs, zram-generator.

    Distro-agnostic bits every hardware-host wants regardless of which
    kernel / initramfs / bootloader it boots. The kernel packages
    themselves and the initramfs/bootloader stack live in separate
    modules:

    - `ArchKernelModule` (linux + linux-lts + dracut + kernel-install-
      for-dracut) for stock Arch / EndeavourOS hosts.
    - `CachyOSModule` (linux-cachyos + mkinitcpio + limine) for hosts
      that boot the CachyOS kernel stack.

    Splitting here means a host that wants the CachyOS stack can drop
    the Arch one without losing microcode/firmware/zram.

    Hardware-host concerns. Do NOT include in WSL roles - WSL2 boots
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
            "linux-firmware",
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
