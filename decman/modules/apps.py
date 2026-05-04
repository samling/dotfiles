import decman
from decman.plugins import pacman, aur, systemd

from modules._systemd import reconcile_units


class AppsModule(decman.Module):

    def __init__(self):
        super().__init__("apps")

    @pacman.packages
    def pkgs(self) -> set[str]:
        return {
            "firefox",
            "imv",
            "libdvdcss",
            "libgsf",
            "libopenraw",
            "obsidian",
            "poppler-glib",
            "thunar",
        }

    @aur.packages
    def aurpkgs(self) -> set[str]:
        return {
            "google-chrome",
            "vesktop-bin",
            "visual-studio-code-bin",
        }

    @systemd.user_units
    def user_units(self) -> dict[str, set[str]]:
        return {"sboynton": {"chrome-graceful-shutdown.service"}}

    def on_change(self, store):
        reconcile_units(self, store)
