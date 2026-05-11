"""Modules for a portable host. Layers laptop-specific bits on top
of the gui role.

Vendor-specific quirks (asusd, EDID firmware, fnlock, etc.) belong
in a host-scoped module under `modules/hardware/`, not here. This
file keeps to concerns that apply to every laptop we'd care to
manage: keyd remapping, the keyd group, the Parsec/joydev udev
workaround.
"""
from modules.common.locale import LocaleModule
from modules.common.users import UsersModule
from modules.laptop.laptop import LaptopModule
from roles.gui import GUI_ENSURED_GROUPS, GUI_GROUPS, GUI_MODULES

MODULES = [
    # Users first so its before_update creates managed groups; the
    # add_user_to_group calls run in after_update once packages that
    # provide each group (docker, libvirt, kvm, keyd, wireshark) are
    # installed.
    UsersModule(
        extra_groups=GUI_GROUPS + ("keyd",),
        managed_groups=("keyd",),
        ensured_groups=GUI_ENSURED_GROUPS,
    ),
    LocaleModule(),
    *GUI_MODULES,
    LaptopModule(),
]
