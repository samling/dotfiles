import decman
from decman.plugins import pacman


class DracutModule(decman.Module):
    """Dracut initramfs + systemd kernel-install integration.

    Layered on top of `ArchKernelModule` for hosts that prefer dracut
    over mkinitcpio. EndeavourOS is the only flavour we manage that
    defaults to dracut, so this module is currently only registered
    from `hosts/xen.py`.

    Mutually exclusive with `MkinitcpioModule`: an EOS host filters
    `MkinitcpioModule` out of `GUI_MODULES` before adding this one,
    so dracut isn't competing with mkinitcpio's pacman hooks.
    """

    def __init__(self):
        super().__init__("host_dracut")

    @pacman.packages
    def pkgs(self) -> set[str]:
        return {
            "dracut",
            "kernel-install-for-dracut",
        }
