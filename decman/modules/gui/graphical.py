import decman
from decman.plugins import pacman, aur


class GraphicalModule(decman.Module):
    """Anything that has to be present for a graphical session to work:
    fonts, GTK/Qt theming bits, xdg portal stack, file-manager + its
    thumbnail backends, cursor/icon themes.
    """

    def __init__(self):
        super().__init__("graphical")

    @pacman.packages
    def pkgs(self) -> set[str]:
        return {
            "accountsservice",
            "brightnessctl",
            "cantarell-fonts",
            "dconf",
            "gnome-power-manager",
            "gsfonts",
            "gvfs",
            # libdvdcss / libgsf / libopenraw / poppler-glib are tumbler
            # thumbnail backends — they belong with thunar+tumbler, not
            # in an apps grab-bag.
            "libdvdcss",
            "libgsf",
            "libopenraw",
            "mesa-utils",
            "noto-fonts",
            "noto-fonts-cjk",
            "noto-fonts-emoji",
            "noto-fonts-extra",
            "nwg-look",
            "papirus-icon-theme",
            "poppler-glib",
            "power-profiles-daemon",
            "qt6ct",
            "thunar",
            "thunar-archive-plugin",
            "thunar-volman",
            "ttf-bitstream-vera",
            "ttf-dejavu",
            "ttf-iosevkaterm-nerd",
            "ttf-jetbrains-mono",
            "ttf-liberation",
            "ttf-opensans",
            "tumbler",
            "upower",
            "vulkan-radeon",
            "xdg-desktop-portal",
            "xdg-desktop-portal-gnome",
            "xdg-desktop-portal-gtk",
            "xdg-desktop-portal-hyprland",
            "xdg-desktop-portal-wlr",
            "xdg-user-dirs",
            "xdg-utils",
            "xf86-input-libinput",
            "xfconf",
            "xorg-server",
            "xorg-xdpyinfo",
            "xorg-xinit",
            "xorg-xinput",
            "xorg-xkill",
            "xorg-xrandr",
            "yazi",
        }

    @aur.packages
    def aurpkgs(self) -> set[str]:
        return {
            "catppuccin-gtk-theme-mocha",
            "matugen-bin",
            "rose-pine-cursor",
            "wallust",
        }

    def after_update(self, store):
        # Pre-create the XDG user dirs declared in chezmoi's
        # dot_config/user-dirs.dirs. The shipped user-dirs.conf has
        # `enabled=False` so xdg-user-dirs-update won't recreate
        # missing dirs at login. mkdir -p is idempotent.
        decman.prg(
            [
                "bash", "-c",
                'mkdir -p '
                '"$HOME/Downloads" '
                '"$HOME/Documents" '
                '"$HOME/Music" '
                '"$HOME/Pictures" '
                '"$HOME/Pictures/Screenshots" '
                '"$HOME/Videos" '
                '"$HOME/Templates" '
                '"$HOME/Public"\n',
            ],
            user="sboynton",
            mimic_login=True,
            check=False,
        )
