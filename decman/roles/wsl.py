from modules.archlinux import ArchlinuxModule
from modules.base import BaseModule
from modules.core import CoreModule
from modules.dev import DevModule
from modules.networking import NetworkingModule
from modules.security import SecurityModule
from modules.shell import ShellModule
from modules.system import SystemModule

MODULES = [
    ArchlinuxModule(),
    BaseModule(),
    CoreModule(),
    DevModule(),
    NetworkingModule(),
    SecurityModule(),
    ShellModule(),
    SystemModule(),
]
