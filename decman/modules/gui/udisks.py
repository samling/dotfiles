import decman
from decman.plugins import pacman, systemd

from modules._systemd import reconcile_units


class UdisksModule(decman.Module):
    """Removable-media daemon + tray.

    Mirrors `modules/graphical/disk.nix` (udisks2 system-side, udiskie
    user-side). udiskie is launched as a user unit bound to
    graphical-session.target; the unit file lives under chezmoi's
    dot_config/systemd/user/.
    """

    def __init__(self):
        super().__init__("udisks")

    @pacman.packages
    def pkgs(self) -> set[str]:
        return {
            "udiskie",
            "udisks2",
        }

    @systemd.user_units
    def user_units(self) -> dict[str, set[str]]:
        return {"sboynton": {"udiskie.service"}}

    def on_change(self, store):
        reconcile_units(self, store)
