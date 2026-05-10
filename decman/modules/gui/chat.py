import decman
from decman.plugins import aur


class ChatModule(decman.Module):
    """Chat clients."""

    def __init__(self):
        super().__init__("chat")

    @aur.packages
    def aurpkgs(self) -> set[str]:
        return {"vesktop-bin"}
