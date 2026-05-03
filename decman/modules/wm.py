import decman
from decman.plugins import pacman, aur


class WmModule(decman.Module):

    def __init__(self):
        super().__init__("wm")

    @pacman.packages
    def pkgs(self) -> set[str]:
        return {
            "awww",
            "cage",
            "greetd",
            "greetd-regreet",
            "grim",
            "hypridle",
            "hyprlock",
            "kitty",
            "niri",
            "quickshell",
            "rofi",
            "satty",
            "slurp",
            "wf-recorder",
            "wl-clipboard",
            "wtype",
            "xterm",
        }

    @aur.packages
    def aurpkgs(self) -> set[str]:
        return {"ghostty-nightly-bin"}
