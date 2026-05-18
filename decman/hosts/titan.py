import decman
from decman.plugins import systemd

from modules._systemd import reconcile_units
from modules.hardware.nvidia import NvidiaModule
from modules.host.cachyos import CachyOSModule
from modules.host.mkinitcpio import MkinitcpioModule
from modules.work.work import WorkModule
from roles.gui import MODULES


class TitanServicesModule(decman.Module):

    def __init__(self):
        super().__init__("titan_services")

    @systemd.user_units
    def user_units(self) -> dict[str, set[str]]:
        return {
            "sboynton": {
                "sunshine.service",
            },
        }

    def on_change(self, store):
        reconcile_units(self, store)

# CachyOS on bare metal with an nvidia GPU. Also the work machine,
# so WorkModule layers in the work-only toolchain (aws/azure/teleport
# /vault/slack/...).
#
# Composition on top of the gui role:
#
# - MkinitcpioModule supplies the initramfs builder (CachyOS default,
#   also vanilla Arch default).
# - CachyOSModule supplies the cachyos kernels (linux-cachyos +
#   linux-cachyos-lts + their nvidia-open module variants), limine
#   bootloader, plymouth splash, and a pile of installer-shipped
#   packages pinned so decman doesn't remove them on first apply.
# - NvidiaModule supplies the nvidia userspace (utils, settings,
#   opencl, libva, vulkan ICDs, lib32 variants for steam/wine).
# - WorkModule supplies work-only packages plus the
#   /etc/environment.d entry that pins TELEPORT_TOOLS_VERSION=off.
#
# No ArchKernelModule - linux / linux-lts would just sit alongside
# the cachyos kernels wasting disk. Pruning the installer-shipped
# extras pinned in CachyOSModule is a follow-up.
decman.modules += MODULES + [
    MkinitcpioModule(),
    CachyOSModule(),
    NvidiaModule(),
    TitanServicesModule(),
    WorkModule(),
]

# Per-host packages. Layered on top of role / module packages.
decman.pacman.packages |= set()
decman.aur.packages |= {
    "sunshine-beta-bin",
}
