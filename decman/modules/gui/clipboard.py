import decman
from decman.plugins import pacman, aur, systemd


class ClipboardModule(decman.Module):

    def __init__(self):
        super().__init__("clipboard")

    @pacman.packages
    def pkgs(self) -> set[str]:
        return {
            "wl-clipboard",
            "wtype",
        }

    @aur.packages
    def aurpkgs(self) -> set[str]:
        return {
            "clipse-gui",
            #"clipse-wayland-bin",
        }

    @systemd.user_units
    def user_units(self) -> dict[str, set[str]]:
        return {
            "sboynton": {
                "clipse-watch-image.service",
                "clipse-watch-text.service",
                # wl-paste-primary.service intentionally omitted: it mirrors the
                # primary selection (highlight) into the clipboard, which makes
                # every highlight overwrite the Ctrl-C buffer.
            },
        }
