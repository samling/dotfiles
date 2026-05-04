import decman
from decman.plugins import pacman, systemd

from modules._systemd import reconcile_units


class BluetoothModule(decman.Module):

    def __init__(self):
        super().__init__("bluetooth")

    @pacman.packages
    def pkgs(self) -> set[str]:
        return {
            "blueman",
            "bluez",
            "bluez-utils",
        }

    @systemd.units
    def units(self) -> set[str]:
        return {"bluetooth.service"}

    def on_change(self, store):
        reconcile_units(self, store)
