from modules.common.locale import LocaleModule
from modules.common.users import UsersModule
from modules.wsl.windows import WindowsModule
from modules.wsl.work import WorkModule
from roles.common import MODULES as COMMON

# Deliberately omits host.* and gui.* modules: WSL2 boots the
# Microsoft kernel (no dracut/initramfs/EFI), inherits its network
# stack from Windows (no NetworkManager/iwd), has no real PCI/USB
# tree, and runs no compositor of its own (GUI apps via WSLg work
# but feh/imv/obs make no sense headless).
WSL_EXTRA_GROUPS: tuple[str, ...] = (
    "docker",
    "kvm",
    "libvirt",
)

MODULES = [
    UsersModule(
        extra_groups=WSL_EXTRA_GROUPS,
        # Same chicken-and-egg as roles/gui.py: package-owned groups
        # aren't created until their package installs, but useradd
        # --groups runs first. Pre-create idempotently.
        ensured_groups=WSL_EXTRA_GROUPS,
    ),
    LocaleModule(),

    *COMMON,

    WindowsModule(),
    WorkModule(),
]
