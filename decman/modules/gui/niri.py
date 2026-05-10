import decman
from decman.plugins import pacman, aur


class NiriModule(decman.Module):
    """niri compositor + extras. Kept separate from WmModule so future
    non-niri hosts can opt out without touching the shared wm pieces.
    """

    def __init__(self):
        super().__init__("niri")

    @pacman.packages
    def pkgs(self) -> set[str]:
        return {
            "niri",
            "xwayland-satellite",
        }

    @aur.packages
    def aurpkgs(self) -> set[str]:
        return {
            "libinput-gestures",
            "niri-float-sticky",
        }
