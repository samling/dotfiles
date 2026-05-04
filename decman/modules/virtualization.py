import decman
from decman.plugins import pacman, systemd

from modules._systemd import reconcile_units


class VirtualizationModule(decman.Module):
    """libvirt + qemu + virt-manager. Group membership (libvirt, kvm) is
    applied by UsersModule.
    """

    def __init__(self):
        super().__init__("virtualization")

    @pacman.packages
    def pkgs(self) -> set[str]:
        # iptables-nft / nftables / dnsmasq are declared by NetworkingModule
        # since they're not virtualization-specific.
        return {
            "edk2-ovmf",
            "libvirt",
            "qemu-desktop",
            "swtpm",
            "virt-manager",
        }

    @systemd.units
    def units(self) -> set[str]:
        return {"libvirtd.service"}

    def on_change(self, store):
        reconcile_units(self, store)
