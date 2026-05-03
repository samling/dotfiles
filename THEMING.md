# Theming setup (Arch)

Replaces what `modules/graphical/theming.nix` did under home-manager. The files
in this repo cover everything declarative; the steps below are the bits that
live outside dotfiles (package installs, dconf state).

## One-time package installs

Repo:

```
sudo pacman -S papirus-icon-theme qt6ct
```

AUR (needed for the names referenced in `gtk-3.0/settings.ini`,
`gtk-4.0/settings.ini`, and `home.pointerCursor` in the old nix module):

```
yay -S catppuccin-gtk-theme-mocha rose-pine-cursor
```

Without these, GTK falls back silently and you'll get default icons/cursor
even though the config names a theme.

## One-time dconf settings

GTK reads these from dconf, not from a file we can ship:

```
gsettings set org.gnome.desktop.interface icon-theme        'Papirus-Dark'
gsettings set org.gnome.desktop.interface gtk-theme         'catppuccin-mocha-lavender-standard'
gsettings set org.gnome.desktop.interface cursor-theme      'BreezeX-RosePine-Linux'
gsettings set org.gnome.desktop.interface cursor-size        24
gsettings set org.gnome.desktop.interface color-scheme      'prefer-dark'
```

Verify with `gsettings get org.gnome.desktop.interface icon-theme`.

## Activating the Qt env vars

`environment.d/qt.conf` is read by the systemd user manager at login. To pick
it up without logging out:

```
systemctl --user import-environment QT_QPA_PLATFORMTHEME QT_STYLE_OVERRIDE
systemctl --user restart quickshell.service
```

Confirm with `systemctl --user show-environment | grep QT_`.

## regreet (login greeter)

regreet runs as the `greeter` user under greetd, so it doesn't read anything
from `$HOME` and chezmoi can't deploy its config directly. The desired
settings live in this repo at `etc/greetd/regreet.toml` (not under `dot_*`).
Install with:

```
sudo install -m 644 etc/greetd/regreet.toml /etc/greetd/regreet.toml
```

The catppuccin GTK theme and rose-pine cursor referenced there must be
installed system-wide (the AUR packages above put them in `/usr/share/themes`
and `/usr/share/icons`, which is where the `greeter` user looks). Papirus from
the official repo already lives there.

## Optional: Catppuccin Mocha qt6ct color scheme

`qt6ct/qt6ct.conf` ships pointing at `/usr/share/qt6ct/colors/darker.conf`
(installed with qt6ct). To use the Catppuccin palette from the quickshell
THEME_SETUP guide instead, drop a `qt6ct/colors/catppuccin-mocha.conf` into
this repo and change `color_scheme_path` to
`/home/sboynton/.config/qt6ct/colors/catppuccin-mocha.conf`.
