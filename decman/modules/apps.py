import decman
from decman.plugins import pacman, aur


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
