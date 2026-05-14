import decman

from modules.hardware.zenbook import ZenbookModule
from modules.host.arch_kernel import ArchKernelModule
from modules.host.dracut import DracutModule
from modules.host.endeavouros import EndeavourOSModule
from modules.host.keyd import KeydModule
from roles.gui import MODULES

# Asus UM5606 (Ryzen AI / Radeon 880M) on EndeavourOS.
# - ArchKernelModule: linux + linux-lts.
# - DracutModule: initramfs (EOS default; vanilla/Cachy use mkinitcpio).
# - EndeavourOSModule: EOS keyring/mirrorlist/branding.
# - ZenbookModule: vendor quirks (asusd, EDID, fnlock, fan).
# - KeydModule: per-host config via etc/keyd/<hostname>.conf. Declares
#   its own `keyd` group needs; UsersModule picks them up by scan.
decman.modules += MODULES + [
    KeydModule(),
    ArchKernelModule(),
    DracutModule(),
    EndeavourOSModule(),
    ZenbookModule(),
]

# Per-host packages. Layered on top of role / module packages.
decman.pacman.packages |= set()
decman.aur.packages |= set()
