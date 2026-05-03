import decman
from decman.plugins import pacman


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
