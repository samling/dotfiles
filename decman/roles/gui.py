"""Modules for any GUI host (desktop or laptop).

Composes COMMON with the host-bound packages every real Linux
machine needs (kernel, RAID/EFI/SMART, real-hardware NetworkManager,
etc.) and the graphical-session stack (Wayland compositor, audio,
browsers, fonts, the rest).

`MODULES` exported here is the role's full list — it works as-is for
desktops. `roles/laptop.py` reuses `GUI_MODULES` and `GUI_GROUPS` to
layer keyd on top without re-listing every module.

Deliberate exclusions from GUI_MODULES:
- EndeavourOSModule: distro-specific. EOS hosts register it in their
  `hosts/<name>.py` so a stock-Arch desktop can join the gui role
  cleanly.
- ZenbookModule and any other vendor-specific module: those are
  per-host concerns and live under `modules/hardware/`.
"""
from modules.common.locale import LocaleModule
from modules.common.users import UsersModule
from modules.gui.audio import AudioModule
from modules.gui.bluetooth import BluetoothModule
from modules.gui.browsers import BrowsersModule
from modules.gui.chat import ChatModule
from modules.gui.clipboard import ClipboardModule
from modules.gui.editors import EditorsGuiModule
from modules.gui.games import GamesModule
from modules.gui.graphical import GraphicalModule
from modules.gui.media import MediaGuiModule
from modules.gui.niri import NiriModule
from modules.gui.printing import PrintingModule
from modules.gui.remote_desktop import RemoteDesktopModule
from modules.gui.security import SecurityGuiModule
from modules.gui.sync import SyncModule
from modules.gui.tailscale import TailscaleModule
from modules.gui.udisks import UdisksModule
from modules.gui.wm import WmModule
from modules.host.disks import DisksModule
from modules.host.hardware import HardwareModule
from modules.host.kernel import KernelModule
from modules.host.networking import HostNetworkingModule
from roles.common import MODULES as COMMON

# Baseline supplementary groups for any GUI host. `roles/laptop.py`
# extends this with `keyd`.
GUI_GROUPS: tuple[str, ...] = (
    "docker",
    "kvm",
    "libvirt",
    "wireshark",
)

# Subset of GUI_GROUPS that aren't present until their owning package
# installs (docker → docker.service sysusers, libvirt → libvirt-daemon
# sysusers, qemu-base → kvm via /usr/lib/sysusers.d/qemu.conf,
# wireshark-cli → wireshark via .install). On a fresh host the
# packages haven't installed yet when UserManager runs useradd, so
# `--groups docker,...` fails. UsersModule pre-creates anything in
# `ensured_groups` with `groupadd --system`; later sysusers files
# matching the same name are no-ops.
GUI_ENSURED_GROUPS: tuple[str, ...] = GUI_GROUPS

# Module list shared by the gui role and anything that extends it
# (currently just `roles/laptop.py`). UsersModule and LocaleModule
# are constructed by each leaf role so per-host group membership
# and ordering stay explicit there.
GUI_MODULES = [
    *COMMON,
    DisksModule(),
    HardwareModule(),
    KernelModule(),
    HostNetworkingModule(),
    AudioModule(),
    BluetoothModule(),
    BrowsersModule(),
    ChatModule(),
    ClipboardModule(),
    EditorsGuiModule(),
    GamesModule(),
    GraphicalModule(),
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

# Default gui role (desktop). Hosts wanting EOS branding or laptop
# quirks build their own MODULES from GUI_MODULES + extras, or use
# `roles/laptop.py`.
MODULES = [
    UsersModule(
        extra_groups=GUI_GROUPS,
        ensured_groups=GUI_ENSURED_GROUPS,
    ),
    LocaleModule(),
    *GUI_MODULES,
]
