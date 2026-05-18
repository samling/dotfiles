import decman
from decman.plugins import pacman


class ArchKernelModule(decman.Module):
    """Stock Arch kernel packages.

    Just `linux` + `linux-lts` and their headers. Initramfs choice is
    a separate module (`MkinitcpioModule` for vanilla Arch / CachyOS,
    `DracutModule` for EndeavourOS) so a host can swap kernels and
    initramfs builders independently. Bootloader is also host-scoped.

    Pair with `KernelModule` (firmware / microcode / zram) and one
    of the initramfs modules. Hosts that boot a non-Arch kernel
    stack (e.g. titan on linux-cachyos) drop this module entirely.
    """

    def __init__(self):
        super().__init__("host_arch_kernel")

    @pacman.packages
    def pkgs(self) -> set[str]:
        return {
            "linux",
            "linux-headers",
            "linux-lts",
            "linux-lts-headers",
        }
