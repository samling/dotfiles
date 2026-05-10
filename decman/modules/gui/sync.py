import decman
from decman.plugins import aur


class SyncModule(decman.Module):
    """File-sync clients (Insync for Google Drive)."""

    def __init__(self):
        super().__init__("sync")

    @aur.packages
    def aurpkgs(self) -> set[str]:
        return {"insync"}
