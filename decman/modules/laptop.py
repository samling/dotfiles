import decman
from decman.plugins import pacman, systemd

from modules._systemd import reconcile_units


class LaptopModule(decman.Module):
    """Generic laptop concerns — applies to any portable, no
    vendor-specific assumptions. Vendor-specific quirks (EDID, fan
    control, asus-wmi, etc.) belong in a host-scoped module like
    ZenbookModule.
    """

    def __init__(self):
        super().__init__("laptop")

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
            "/etc/keyd/app.conf": decman.File(
                source_file="../etc/keyd/app.conf",
                permissions=0o644,
                owner="root",
                group="root",
            ),
            "/etc/keyd/default.conf": decman.File(
                source_file="../etc/keyd/default.conf",
                permissions=0o644,
                owner="root",
                group="root",
            ),
            # libinput quirks for keyd's virtual devices; lives under
            # etc/keyd/ in the source for thematic grouping.
            "/etc/libinput/local-overrides.quirks": decman.File(
                source_file="../etc/keyd/libinput-overrides.quirks",
                permissions=0o644,
                owner="root",
                group="root",
            ),
            # Run keyd as the keyd group so keyd-application-mapper
            # (running as the user) can talk to the keyd socket.
            "/etc/systemd/system/keyd.service.d/group.conf": decman.File(
                content="[Service]\nGroup=keyd\n",
                permissions=0o644,
                owner="root",
                group="root",
            ),
        }
