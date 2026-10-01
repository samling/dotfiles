import decman
from decman.plugins import aur, pacman, systemd

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
            # "hyprpolkitagent",
            "niri",
            "xwayland-satellite",
        }

    @aur.packages
    def aurpkgs(self) -> set[str]:
        return {
            "libinput-gestures",
            "monique",
            "niri-float-sticky",
            "sunsetr",
        }

    @systemd.user_units
    def user_units(self) -> dict[str, set[str]]:
        # No user units currently enabled; {} would be a dict, not a set.
        return {"sboynton": set()}

    def on_change(self, store):
        reconcile_units(self, store)
