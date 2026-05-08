from modules.audio import AudioModule
from modules.aur_keys import AurKeysModule
from modules.bluetooth import BluetoothModule
from modules.browsers import BrowsersModule
from modules.chat import ChatModule
from modules.clipboard import ClipboardModule
from modules.editors_gui import EditorsGuiModule
from modules.endeavouros import EndeavourOSModule
from modules.games import GamesModule
from modules.graphical import GraphicalModule
from modules.gui_media import MediaGuiModule
from modules.gui_security import SecurityGuiModule
from modules.host_disks import DisksModule
from modules.host_hardware import HardwareModule
from modules.host_kernel import KernelModule
from modules.host_networking import HostNetworkingModule
from modules.laptop import LaptopModule
from modules.locale import LocaleModule
from modules.niri import NiriModule
from modules.printing import PrintingModule
from modules.remote_desktop import RemoteDesktopModule
from modules.sync import SyncModule
from modules.tailscale import TailscaleModule
from modules.udisks import UdisksModule
from modules.users import UsersModule
from modules.wm import WmModule
from roles.common import MODULES as COMMON


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

    *COMMON,

    AudioModule(),
    BluetoothModule(),
    BrowsersModule(),
    ChatModule(),
    ClipboardModule(),
    DisksModule(),
    EditorsGuiModule(),
    EndeavourOSModule(),
    GamesModule(),
    GraphicalModule(),
    HardwareModule(),
    HostNetworkingModule(),
    KernelModule(),
    LaptopModule(),
    MediaGuiModule(),
    NiriModule(),
    PrintingModule(),
    RemoteDesktopModule(),
    SecurityGuiModule(),
    SyncModule(),
    TailscaleModule(),
    UdisksModule(),
    WmModule(),
]
