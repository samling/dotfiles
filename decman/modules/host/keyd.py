"""keyd + its byproduct workarounds. Opt-in per host.

Main config: `etc/keyd/<hostname>.conf`, falls back to `default.conf`.
Declares the `keyd` group via `user_groups` / `managed_user_groups`
so `UsersModule` picks it up automatically - no host-file plumbing
needed.
"""

import socket
from pathlib import Path

import decman
from decman.plugins import pacman, systemd

from modules._systemd import reconcile_units

# decman runs source.py with CWD=decman/, so File.source_file paths
# resolve relative to that. Conf files live one level up.
_SRC_REL = "../etc/keyd"
_SRC_ABS = Path(__file__).resolve().parents[3] / "etc" / "keyd"


def _host_conf() -> str:
    slug = socket.gethostname().replace("-", "_").lower()
    name = f"{slug}.conf" if (_SRC_ABS / f"{slug}.conf").is_file() else "default.conf"
    return f"{_SRC_REL}/{name}"


class KeydModule(decman.Module):
    # Consumed by UsersModule.before_update via attr scan on
    # decman.modules. keyd has no PKGBUILD-shipped group, so it's
    # decman-managed (groupadd) rather than ensured (pre-create).
    user_groups = ("keyd",)
    managed_user_groups = ("keyd",)

    def __init__(self):
        super().__init__("host_keyd")

    @pacman.packages
    def pkgs(self) -> set[str]:
        return {"keyd"}

    @systemd.units
    def units(self) -> set[str]:
        return {"keyd.service"}

    @systemd.user_units
    def user_units(self) -> dict[str, set[str]]:
        return {"sboynton": {"keyd-application-mapper.service"}}

    def on_change(self, store):
        reconcile_units(self, store)

    def files(self) -> dict[str, decman.File]:
        return {
            "/etc/keyd/default.conf": decman.File(
                source_file=_host_conf(),
                permissions=0o644,
                owner="root",
                group="root",
            ),
            # libinput sees keyd's virtual devices and would apply the
            # wrong quirks otherwise.
            "/etc/libinput/local-overrides.quirks": decman.File(
                source_file=f"{_SRC_REL}/libinput-overrides.quirks",
                permissions=0o644,
                owner="root",
                group="root",
            ),
            # keyd's virtual pointer advertises ABS_X/ABS_Y; joydev
            # spawns /dev/input/jsN and Parsec misdetects it as a
            # gamepad. See parsec_phantom_gamepad memory.
            "/etc/udev/rules.d/99-keyd-no-joystick.rules": decman.File(
                source_file=f"{_SRC_REL}/99-keyd-no-joystick.rules",
                permissions=0o644,
                owner="root",
                group="root",
            ),
            # Run keyd as the keyd group so the user-side
            # keyd-application-mapper can talk to its socket.
            "/etc/systemd/system/keyd.service.d/group.conf": decman.File(
                content="[Service]\nGroup=keyd\n",
                permissions=0o644,
                owner="root",
                group="root",
            ),
        }
