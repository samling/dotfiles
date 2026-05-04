from modules.archlinux import ArchlinuxModule
from modules.audio import AudioModule
from modules.aur_keys import AurKeysModule
from modules.base import BaseModule
from modules.bluetooth import BluetoothModule
from modules.browsers import BrowsersModule
from modules.chat import ChatModule
from modules.claude_code import ClaudeCodeModule
from modules.clipboard import ClipboardModule
from modules.core import CoreModule
from modules.dev import DevModule
from modules.docker import DockerModule
from modules.editors import EditorsModule
from modules.editors_gui import EditorsGuiModule
from modules.endeavouros import EndeavourOSModule
from modules.games import GamesModule
from modules.git import GitModule
from modules.graphical import GraphicalModule
from modules.kubernetes import KubernetesModule
from modules.laptop import LaptopModule
from modules.locale import LocaleModule
from modules.media import MediaModule
from modules.networking import NetworkingModule
from modules.niri import NiriModule
from modules.printing import PrintingModule
from modules.remote_desktop import RemoteDesktopModule
from modules.security import SecurityModule
from modules.shell import ShellModule
from modules.sync import SyncModule
from modules.system import SystemModule
from modules.tailscale import TailscaleModule
from modules.udisks import UdisksModule
from modules.users import UsersModule
from modules.virtualization import VirtualizationModule
from modules.wm import WmModule


def _aur_keys() -> AurKeysModule:
    keys = AurKeysModule()
    keys.fetch_spotify()
    keys.fetch_wlogout()
    return keys


MODULES = [
    # Users first so its before_update creates managed groups; the
    # add_user_to_group calls run in after_update once packages that
    # provide each group (docker, libvirt, kvm, keyd, wireshark) are
    # installed.
    UsersModule(
        extra_groups=(
            "docker",
            "keyd",
            "kvm",
            "libvirt",
            "wireshark",
        ),
        managed_groups=("keyd",),
    ),
    # AurKeysModule must follow UsersModule so the aurbuilder user
    # exists by the time GPGReceiver tries to import keys for it.
    _aur_keys(),
    LocaleModule(),

    ArchlinuxModule(),
    AudioModule(),
    BaseModule(),
    BluetoothModule(),
    BrowsersModule(),
    ChatModule(),
    ClaudeCodeModule(),
    ClipboardModule(),
    CoreModule(),
    DevModule(),
    DockerModule(),
    EditorsModule(),
    EditorsGuiModule(),
    EndeavourOSModule(),
    GamesModule(),
    GitModule(),
    GraphicalModule(),
    KubernetesModule(),
    LaptopModule(),
    MediaModule(),
    NetworkingModule(),
    NiriModule(),
    PrintingModule(),
    RemoteDesktopModule(),
    SecurityModule(),
    ShellModule(),
    SyncModule(),
    SystemModule(),
    TailscaleModule(),
    UdisksModule(),
    VirtualizationModule(),
    WmModule(),
]
