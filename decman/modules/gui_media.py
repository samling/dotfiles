import decman
from decman.plugins import pacman, aur


class MediaGuiModule(decman.Module):
    """GUI media apps: image viewers, OBS, Spotify, media-key control.

    Split out of MediaModule so headless/WSL roles don't pull in GUI
    Electron/Qt apps. spotify's PKGBUILD has validpgpkeys; the role
    file must register AurKeysModule(.fetch_spotify()) before this
    module so the aurbuilder keyring contains Spotify's signing key
    by the time makechrootpkg fires.
    """

    def __init__(self):
        super().__init__("gui_media")

    @pacman.packages
    def pkgs(self) -> set[str]:
        return {
            "feh",
            "imv",
            "obs-studio",
            "playerctl",
        }

    @aur.packages
    def aurpkgs(self) -> set[str]:
        return {"spotify"}
