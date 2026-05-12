# Theming setup (Arch)

Replaces what `modules/graphical/theming.nix` did under home-manager. The
declarative bits live in `chezmoi/` (config files) and `decman/` (packages,
regreet system files); the steps below are what still has to be done by hand
(dconf state, picking up Qt env vars without re-login).

Package note: the configs in `gtk-3.0/settings.ini` and `gtk-4.0/settings.ini`
reference `catppuccin-mocha-lavender-standard+default`. The AUR package installs
each variant with a `+default` suffix (plus `+default-hdpi` / `+default-xhdpi`).
Drop the suffix and GTK silently falls back to Adwaita. The symptom is GTK3 apps
like Thunar and clipse-gui showing up in light mode while GTK4/libadwaita apps
look fine (those ignore `gtk-theme` entirely and just track `color-scheme`).

## One-time dconf settings

GTK reads these from dconf, not from a file we can ship:

```
gsettings set org.gnome.desktop.interface icon-theme        'Papirus-Dark'
gsettings set org.gnome.desktop.interface gtk-theme         'catppuccin-mocha-lavender-standard+default'
gsettings set org.gnome.desktop.interface cursor-theme      'BreezeX-RosePine-Linux'
gsettings set org.gnome.desktop.interface cursor-size        24
gsettings set org.gnome.desktop.interface color-scheme      'prefer-dark'
```

Verify with `gsettings get org.gnome.desktop.interface gtk-theme` (the value
must exactly match an entry in `/usr/share/themes`, including the `+default`
suffix). Re-run these whenever the theme name in `settings.ini` changes:
GTK3 apps prefer the dconf value over `settings.ini`, so a stale dconf entry
silently breaks theming even when the on-disk config is correct.

## Activating the Qt env vars

`environment.d/qt.conf` is read by the systemd user manager at login. To pick
it up without logging out:

```
systemctl --user import-environment QT_QPA_PLATFORMTHEME QT_STYLE_OVERRIDE
systemctl --user restart quickshell.service
```

Confirm with `systemctl --user show-environment | grep QT_`.

## Optional: Catppuccin Mocha qt6ct color scheme

`qt6ct/qt6ct.conf` ships pointing at `/usr/share/qt6ct/colors/darker.conf`
(installed with qt6ct). To use the Catppuccin palette from the quickshell
THEME_SETUP guide instead, drop a `qt6ct/colors/catppuccin-mocha.conf` into
this repo and change `color_scheme_path` to
`/home/sboynton/.config/qt6ct/colors/catppuccin-mocha.conf`.
