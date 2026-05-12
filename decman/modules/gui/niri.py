import decman
from decman.plugins import pacman, aur, systemd

from modules._systemd import reconcile_units


class NiriModule(decman.Module):
    """niri compositor + extras. Kept separate from WmModule so future
    non-niri hosts can opt out without touching the shared wm pieces.
    """

    def __init__(self):
        super().__init__("niri")

    @pacman.packages
    def pkgs(self) -> set[str]:
        return {
            "hyprpolkitagent",
            "niri",
            "xwayland-satellite",
        }

    @aur.packages
    def aurpkgs(self) -> set[str]:
        return {
            "libinput-gestures",
            "niri-float-sticky",
        }

    @systemd.user_units
    def user_units(self) -> dict[str, set[str]]:
        # hyprpolkitagent ships a user unit gated on WAYLAND_DISPLAY and
        # WantedBy=graphical-session.target. Enabling it makes pkexec /
        # NetworkManager / udisks prompts work inside niri.
        return {
            "sboynton": {
                "hyprpolkitagent.service",
            },
        }

    def on_change(self, store):
        reconcile_units(self, store)
