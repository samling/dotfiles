import decman
from decman.plugins import pacman, aur, systemd

from modules._systemd import reconcile_units
from modules.common.archlinux import has_repo

# Packages CachyOS ships as native binaries. On cachyos hosts they
# come from the sync repo (declared @pacman); on EOS / vanilla Arch
# they still come from AUR. Declaring conditionally in both places
# keeps decman from rebuilding from source on cachyos and from
# orphan-removing the sync-installed copy.
_NATIVE_OR_AUR = {"swaylock-effects", "wlogout"}


class WmModule(decman.Module):

    def __init__(self):
        super().__init__("wm")

    @pacman.packages
    def pkgs(self) -> set[str]:
        base = {
            "awww",
            "cage",
            "fuzzel",
            "greetd",
            "greetd-regreet",
            "grim",
            "kitty",
            "quickshell",
            "rofi",
            "satty",
            "slurp",
            "swayidle",
            "wf-recorder",
            "wlr-randr",
            "wofi",
            "xterm",
        }
        if has_repo("cachyos"):
            base |= _NATIVE_OR_AUR
        return base

    @aur.packages
    def aurpkgs(self) -> set[str]:
        base = {
            "ghostty-nightly-bin",
            "wlrctl",
        }
        if not has_repo("cachyos"):
            base |= _NATIVE_OR_AUR
        return base

    @systemd.units
    def units(self) -> set[str]:
        # greetd is the login manager. Enable it system-wide so a
        # fresh host (titan) boots into the regreet TUI on tty1
        # instead of getty. Idempotent on hosts that already have it
        # enabled (xen).
        return {"greetd.service"}

    @systemd.user_units
    def user_units(self) -> dict[str, set[str]]:
        return {
            "sboynton": {
                "awww-change-wallpaper.timer",
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
