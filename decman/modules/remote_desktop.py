import decman
from decman.plugins import aur


class RemoteDesktopModule(decman.Module):
    """Remote-desktop clients (Parsec)."""

    def __init__(self):
        super().__init__("remote_desktop")

    @aur.packages
    def aurpkgs(self) -> set[str]:
        return {"parsec-bin"}
