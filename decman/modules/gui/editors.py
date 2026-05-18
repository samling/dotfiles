import decman
from decman.plugins import pacman, aur


class EditorsGuiModule(decman.Module):
    """Graphical editors / note apps. Kept separate from EditorsModule
    (which is the CLI / LSP / formatter layer that WSL also wants) so
    headless roles don't pull in GUI Electron apps.
    """

    def __init__(self):
        super().__init__("editors_gui")

    @pacman.packages
    def pkgs(self) -> set[str]:
        return {"obsidian"}

    @aur.packages
    def aurpkgs(self) -> set[str]:
        return {
            "bruno-bin",
            "postman-bin",
            "visual-studio-code-bin",
        }
