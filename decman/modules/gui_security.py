import decman
from decman.plugins import pacman

from modules._systemd import reconcile_units


class SecurityGuiModule(decman.Module):
    """GUI-only security tools.

    Split from SecurityModule so headless/WSL roles don't pull the Qt
    bits of wireshark. The CLI `tshark` is in the upstream `wireshark-cli`
    package, add that to SecurityModule if needed on WSL.

    The `littlesnitch-bin` AUR package stays registered in SecurityModule
    but its systemd service is no longer auto-enabled.
    """

    def __init__(self):
        super().__init__("gui_security")

    @pacman.packages
    def pkgs(self) -> set[str]:
        return {"wireshark-qt"}

    def on_change(self, store):
        reconcile_units(self, store)
