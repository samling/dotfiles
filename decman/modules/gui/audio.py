import decman
from decman.plugins import pacman


class AudioModule(decman.Module):

    def __init__(self):
        super().__init__("audio")

    @pacman.packages
    def pkgs(self) -> set[str]:
        return {
            "alsa-firmware",
            "alsa-plugins",
            "alsa-utils",
            "gst-libav",
            "gst-plugin-pipewire",
            "gst-plugin-va",
            "gst-plugins-bad",
            "gst-plugins-ugly",
            "pavucontrol",
            "pipewire-alsa",
            "pipewire-jack",
            "pipewire-pulse",
            "rtkit",
            "wireplumber",
        }
