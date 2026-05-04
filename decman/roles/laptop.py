from modules.apps import AppsModule
from modules.archlinux import ArchlinuxModule
from modules.audio import AudioModule
from modules.base import BaseModule
from modules.bluetooth import BluetoothModule
from modules.clipboard import ClipboardModule
from modules.core import CoreModule
from modules.desktop import DesktopModule
from modules.dev import DevModule
from modules.endeavouros import EndeavourOSModule
from modules.laptop import LaptopModule
from modules.networking import NetworkingModule
from modules.printing import PrintingModule
from modules.security import SecurityModule
from modules.shell import ShellModule
from modules.system import SystemModule
from modules.wm import WmModule

MODULES = [
    AppsModule(),
    ArchlinuxModule(),
    AudioModule(),
    BaseModule(),
    BluetoothModule(),
    ClipboardModule(),
    CoreModule(),
    DesktopModule(),
    DevModule(),
    EndeavourOSModule(),
    LaptopModule(),
    NetworkingModule(),
    PrintingModule(),
    SecurityModule(),
    ShellModule(),
    SystemModule(),
    WmModule(),
]
