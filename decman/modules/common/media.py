import decman
from decman.plugins import pacman


class MediaModule(decman.Module):
    """CLI media tools: image/video processing, terminal viewers,
    yt-dlp, mpv. mpv is included even in headless roles because it
    works on WSLg and is the canonical local player.

    GUI media apps (feh, imv, obs-studio, playerctl, spotify) live
    in `modules.gui.media`. The validpgpkeys signers needed to
    build spotify/wlogout are imported by `roles.common._aur_keys`
    so MediaGuiModule loading after COMMON sees the keys ready.
    """

    def __init__(self):
        super().__init__("media")

    @pacman.packages
    def pkgs(self) -> set[str]:
        return {
            "chafa",
            "ffmpeg",
            "ffmpegthumbnailer",
            "imagemagick",
            "mpv",
            "oxipng",
            "yt-dlp",
        }
