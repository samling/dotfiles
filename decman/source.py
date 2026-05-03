import decman

from modules.apps import AppsModule
from modules.archlinux import ArchlinuxModule
from modules.audio import AudioModule
from modules.base import BaseModule
from modules.bluetooth import BluetoothModule
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

# Roots for transitive-dep clusters that would otherwise be GC'd as orphans.
# Their forward-dep closure (pactree -u) covers ~260 dep-only packages.
decman.pacman.packages |= {
    "meson",
    "ninja",
    "pandoc-cli",
    "python-build",
    "python-installer",
    "python-pygments",
    "python-pyproject-hooks",
    "python-pytest",
    "python-pytest-mock",
    "python-setuptools",
    "python-setuptools-scm",
    "python-six",
    "python-tests",
    "python-wheel",
    "rustup",
    "zig",
}

decman.modules += [
    AppsModule(),
    ArchlinuxModule(),
    AudioModule(),
    BaseModule(),
    BluetoothModule(),
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
