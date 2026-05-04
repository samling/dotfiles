import decman
from decman.plugins import pacman, aur


class MediaModule(decman.Module):
    """Media tools: image/video viewers, recorders, players. Mixes the
    CLI tools from `modules/common/media.nix` with the GUI apps from
    the nix `graphical/media.nix` and `graphical/spotify.nix`.

    spotify's AUR PKGBUILD has validpgpkeys; the role file must register
    AurKeysModule (with fetch_spotify) before this module runs, so the
    aurbuilder keyring contains Spotify's signing key by the time
    makechrootpkg fires.

    The imv desktop entry + imv-open wrapper from the nix config
    aren't packaged here; drop the wrapper into ~/.local/bin via
    chezmoi if you want it.
    """

    def __init__(self):
        super().__init__("media")

    @pacman.packages
    def pkgs(self) -> set[str]:
        return {
            "chafa",
            "feh",
            "ffmpeg",
            "ffmpegthumbnailer",
            "imagemagick",
            "imv",
            "mpv",
            "obs-studio",
            "playerctl",
            "yt-dlp",
        }

    @aur.packages
    def aurpkgs(self) -> set[str]:
        return {"spotify"}
