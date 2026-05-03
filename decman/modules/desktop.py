import decman
from decman.plugins import pacman, aur


class DesktopModule(decman.Module):

    def __init__(self):
        super().__init__("desktop")

    @pacman.packages
    def pkgs(self) -> set[str]:
        return {
            "accountsservice",
            "brightnessctl",
            "cantarell-fonts",
            "gsfonts",
            "gtk-layer-shell",
            "mesa-utils",
            "noto-fonts",
            "noto-fonts-cjk",
            "noto-fonts-emoji",
            "noto-fonts-extra",
            "papirus-icon-theme",
            "power-profiles-daemon",
            "qt6ct",
            "ttf-bitstream-vera",
            "ttf-dejavu",
            "ttf-iosevkaterm-nerd",
            "ttf-liberation",
            "ttf-opensans",
            "upower",
            "vulkan-radeon",
            "xdg-desktop-portal-gnome",
            "xdg-user-dirs",
            "xdg-utils",
            "xdotool",
            "xf86-input-libinput",
            "xorg-server",
            "xorg-xdpyinfo",
            "xorg-xinit",
            "xorg-xinput",
            "xorg-xkill",
            "xorg-xrandr",
        }

    @aur.packages
    def aurpkgs(self) -> set[str]:
        return {
            "catppuccin-gtk-theme-mocha",
            "clipse-gui",
            "clipse-wayland-bin",
            "rose-pine-cursor",
            "wallust",
        }
