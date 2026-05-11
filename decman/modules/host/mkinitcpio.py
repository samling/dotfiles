import decman
from decman.plugins import pacman


class MkinitcpioModule(decman.Module):
    """Mkinitcpio initramfs builder.

    Vanilla Arch and CachyOS default. Layered separately from
    `ArchKernelModule` (kernel pkgs) and `KernelModule` (firmware /
    microcode / zram) so a host can pick its initramfs builder
    independently of its kernel.

    Not registered by any role - initramfs is a system-level
    decision, orthogonal to GUI/laptop concerns. Each host registers
    its initramfs builder explicitly from `hosts/<name>.py`
    (`MkinitcpioModule` for Arch / CachyOS, `DracutModule` for EOS).
    """

    def __init__(self):
        super().__init__("host_mkinitcpio")

    @pacman.packages
    def pkgs(self) -> set[str]:
        return {
            "mkinitcpio",
        }
