import decman

from modules.hardware.nvidia import NvidiaModule
from modules.host.arch_kernel import ArchKernelModule
from modules.host.dracut import DracutModule
from modules.host.endeavouros import EndeavourOSModule
from modules.work.work import WorkModule
from roles.gui import MODULES

# Workstation: EndeavourOS, Intel CPU, Turing-or-newer NVIDIA GPU.
# Keep Titan's shared desktop/development stack and work tools, but not
# GamesModule, CachyOS, Sunshine/USB streaming, UPS or server services.
# systemd-boot and the EFI mount are configured by the EOS installer;
# DracutModule provides kernel-install integration for subsequent updates.
decman.modules += MODULES + [
    ArchKernelModule(),
    DracutModule(),
    EndeavourOSModule(),
    NvidiaModule(include_32bit=False),
    WorkModule(),
]

assert decman.pacman is not None
decman.pacman.packages |= {
    # The shared firmware module also declares amd-ucode; both may safely
    # coexist, but Ada needs Intel microcode in its boot images.
    "intel-ucode",
    # DKMS covers both linux and linux-lts; ArchKernelModule supplies headers.
    "nvidia-open-dkms",
}
