from modules.archlinux import ArchlinuxModule
from modules.base import BaseModule
from modules.claude_code import ClaudeCodeModule
from modules.core import CoreModule
from modules.data import DataModule
from modules.dev import DevModule
from modules.docker import DockerModule
from modules.editors import EditorsModule
from modules.git import GitModule
from modules.kubernetes import KubernetesModule
from modules.locale import LocaleModule
from modules.media import MediaModule
from modules.networking import NetworkingModule
from modules.security import SecurityModule
from modules.shell import ShellModule
from modules.system import SystemModule
from modules.users import UsersModule
from modules.virtualization import VirtualizationModule
from modules.windows import WindowsModule
from modules.work import WorkModule

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

    ArchlinuxModule(),
    BaseModule(),
    ClaudeCodeModule(),
    CoreModule(),
    DataModule(),
    DevModule(),
    DockerModule(),
    EditorsModule(),
    GitModule(),
    KubernetesModule(),
    MediaModule(),
    NetworkingModule(),
    SecurityModule(),
    ShellModule(),
    SystemModule(),
    VirtualizationModule(),
    WindowsModule(),
    WorkModule(),
]
