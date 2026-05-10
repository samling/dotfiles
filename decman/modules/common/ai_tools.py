import decman
from decman.plugins import aur


class AIToolsModule(decman.Module):
    def __init__(self):
        super().__init__("ai_tools")

    @aur.packages
    def aurpkgs(self) -> set[str]:
        return {
            "rtk",
        }
