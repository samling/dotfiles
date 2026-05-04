import decman
from decman.plugins import pacman


class HardwareModule(decman.Module):
    """Hardware introspection, USB, sensors, video capture.

    Hardware-host concerns. WSL has no real PCI/USB tree exposed,
    no v4l devices, no thermal sensors — these tools either fail
    or print nothing.
    """

    def __init__(self):
        super().__init__("host_hardware")

    @pacman.packages
    def pkgs(self) -> set[str]:
        return {
            "dmidecode",
            "hwdetect",
            "hwinfo",
            "lm_sensors",
            "lsscsi",
            "read-edid",
            "usb_modeswitch",
            "usbutils",
            "v4l-utils",
        }
