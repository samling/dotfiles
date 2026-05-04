import decman
from decman.plugins import pacman, systemd

from modules._systemd import reconcile_units


class SecurityGuiModule(decman.Module):
    """GUI-only security tools.

    Split from SecurityModule so headless/WSL roles don't pull the Qt
    bits of wireshark. The CLI `tshark` is in the upstream `wireshark-cli`
    package — add that to SecurityModule if needed on WSL.

    The `littlesnitch-bin` AUR package is registered in SecurityModule
    so its config files can live alongside the rest of the security
    stack on WSL too, but the systemd service is only enabled here
    (graphical-only) — the daemon's blocking dialog needs an X/wayland
    session to be useful.
    """

    def __init__(self):
        super().__init__("gui_security")

    @pacman.packages
    def pkgs(self) -> set[str]:
        return {"wireshark-qt"}

    @systemd.units
    def units(self) -> set[str]:
        return {"littlesnitch.service"}

    def on_change(self, store):
        reconcile_units(self, store)
