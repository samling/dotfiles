import decman
from decman.plugins import pacman


class DracutModule(decman.Module):
    """Dracut initramfs + systemd kernel-install integration.

    Layered on top of `ArchKernelModule` for hosts that prefer dracut
    over mkinitcpio. EndeavourOS hosts (ada and xen) register this for
    their systemd-boot setup. The installer must configure the bootloader
    and EFI mount; this module supplies the ongoing kernel integration.

    Mutually exclusive with `MkinitcpioModule`: each host chooses its
    initramfs module explicitly, so their pacman hooks don't compete.
    """

    def __init__(self):
        super().__init__("host_dracut")

    @pacman.packages
    def pkgs(self) -> set[str]:
        return {
            "dracut",
            "kernel-install-for-dracut",
        }
