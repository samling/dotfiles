from modules.locale import LocaleModule
from modules.users import UsersModule
from modules.windows import WindowsModule
from modules.work import WorkModule
from roles.common import MODULES as COMMON

# Deliberately omits host_* and gui_* modules: WSL2 boots the
# Microsoft kernel (no dracut/initramfs/EFI), inherits its network
# stack from Windows (no NetworkManager/iwd), has no real PCI/USB
# tree, and runs no compositor of its own (GUI apps via WSLg work
# but feh/imv/obs make no sense headless).
MODULES = [
    UsersModule(extra_groups=(
        "docker",
        "kvm",
        "libvirt",
    )),
    LocaleModule(),

    *COMMON,

    WindowsModule(),
    WorkModule(),
]
