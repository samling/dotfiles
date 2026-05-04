import decman
from decman.plugins import pacman, aur, systemd

from modules._systemd import reconcile_units


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
            "kitty",
            "niri",
            "quickshell",
            "rofi",
            "satty",
            "slurp",
            "swayidle",
            "wf-recorder",
            "xterm",
        }

    @aur.packages
    def aurpkgs(self) -> set[str]:
        return {
            "ghostty-nightly-bin",
            "swaylock-effects",
        }

    @systemd.user_units
    def user_units(self) -> dict[str, set[str]]:
        return {
            "sboynton": {
                "awww.service",
                "quickshell.service",
                "swayidle.service",
            },
        }

    def on_change(self, store):
        reconcile_units(self, store)

    def files(self) -> dict[str, decman.File]:
        return {
            "/etc/greetd/config.toml": decman.File(
                source_file="../etc/greetd/config.toml",
                permissions=0o644,
                owner="root",
                group="root",
            ),
            "/etc/greetd/regreet-config.kdl": decman.File(
                source_file="../etc/greetd/regreet-config.kdl",
                permissions=0o644,
                owner="root",
                group="root",
            ),
            "/etc/greetd/regreet.toml": decman.File(
                source_file="../etc/greetd/regreet.toml",
                permissions=0o644,
                owner="root",
                group="root",
            ),
            "/etc/sudoers.d/quickshell": decman.File(
                source_file="../etc/sudoers.d/quickshell",
                permissions=0o440,
                owner="root",
                group="root",
            ),
        }
