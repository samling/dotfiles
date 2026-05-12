import decman

from modules.hardware.zenbook import ZenbookModule
from modules.host.arch_kernel import ArchKernelModule
from modules.host.dracut import DracutModule
from modules.host.endeavouros import EndeavourOSModule
from roles.laptop import MODULES

# Asus UM5606 (Ryzen AI / Radeon 880M) running EndeavourOS.
# ArchKernelModule supplies the kernel packages (linux + linux-lts);
# DracutModule supplies the initramfs builder (EOS default; vanilla
# Arch / CachyOS use MkinitcpioModule instead);
# EndeavourOSModule pulls EOS keyring / mirrorlist / branding;
# ZenbookModule layers vendor quirks (asusd, EDID firmware, fnlock,
# fan control) on top of the generic laptop role.
decman.modules += MODULES + [
    ArchKernelModule(),
    DracutModule(),
    EndeavourOSModule(),
    ZenbookModule(),
]
