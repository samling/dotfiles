import decman
from decman.plugins import aur, pacman


class AIToolsModule(decman.Module):
    def __init__(self):
        super().__init__("ai_tools")

    @pacman.packages
    def pkgs(self) -> set[str]:
        return {
            "aichat",
            # "opencode", # out of date in AUR
        }
    @aur.packages
    def aurpkgs(self) -> set[str]:
        return {
            "pi-coding-agent",
            "rtk",
        }
