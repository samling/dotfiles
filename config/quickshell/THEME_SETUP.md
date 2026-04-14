# QuickShell Theme Setup Guide

This guide details the requirements and setup steps to properly configure themes for QuickShell, particularly for SystemTray icons and menus.

## Overview

QuickShell requires specific configuration to properly display system tray icons and menus with consistent theming. The main issue is that Qt applications (including QuickShell) need explicit configuration to use your system icon themes.

## Requirements

### 1. QApplication Mode
QuickShell must run in QApplication mode to support platform menus (system tray context menus).

**File: `shell.qml`**
```qml
//@ pragma UseQApplication

import qs.bar
import qs.osd
import Quickshell
```

### 2. Icon Theme
Install and configure a comprehensive icon theme that includes symbolic icons.

#### Install Papirus (Recommended)
```bash
sudo pacman -S papirus-icon-theme
```

#### Set System Icon Theme
```bash
gsettings set org.gnome.desktop.interface icon-theme 'Papirus-Dark'
```

### 3. Qt Theme Configuration
Configure Qt applications to use your icon theme.

#### Check Qt Platform Theme
```bash
echo $QT_QPA_PLATFORMTHEME
```
Should output: `qt6ct` or `qt5ct`

#### Create Qt6 Configuration
**File: `~/.config/qt6ct/qt6ct.conf`**
```ini
[Appearance]
icon_theme=Papirus-Dark
style=Fusion
custom_palette=true
color_scheme_path=/home/sboynton/.config/qt6ct/colors/catppuccin-mocha.conf

[Interface]
dialog_buttons_have_icons=1
menus_have_icons=true
show_shortcuts_in_context_menus=true
toolbutton_style=4

[Troubleshooting]
force_raster_widgets=1
```

**What each setting does:**
- `icon_theme=Papirus-Dark`: Use dark Papirus icons
- `style=Fusion`: Modern Qt widget style  
- `custom_palette=true`: Use custom colors instead of system theme
- `color_scheme_path=...catppuccin-mocha.conf`: Catppuccin Mocha color scheme for menu backgrounds
- `menus_have_icons=true`: Show icons in context menus (crucial for systray)
- `dialog_buttons_have_icons=1`: Show icons in dialog buttons
- `show_shortcuts_in_context_menus=true`: Display keyboard shortcuts
- `toolbutton_style=4`: Show text beside icons in toolbars
- `force_raster_widgets=1`: Compatibility setting for some graphics drivers

**Catppuccin Mocha Colors Used:**
- Background: `#1e1e2e` (Base)
- Menu background: `#313244` (Surface0)  
- Text: `#cdd6f4` (Text)
- Disabled text: `#6c7086` (Overlay0)
- Highlights: `#89b4fa` (Blue)

## Icon Theme Options

### Light Mode
```bash
gsettings set org.gnome.desktop.interface icon-theme 'Papirus'
# Edit ~/.config/qt6ct/qt6ct.conf and set:
# icon_theme=Papirus
# custom_palette=false
# (remove color_scheme_path line)
```

### Dark Mode (Generic)
```bash
gsettings set org.gnome.desktop.interface icon-theme 'Papirus-Dark'
# Edit ~/.config/qt6ct/qt6ct.conf and set:
# icon_theme=Papirus-Dark
# custom_palette=true  
# color_scheme_path=/usr/share/qt6ct/colors/darker.conf
```

### Dark Mode (Catppuccin Mocha)
```bash
gsettings set org.gnome.desktop.interface icon-theme 'Papirus-Dark'
# Edit ~/.config/qt6ct/qt6ct.conf and set:
# icon_theme=Papirus-Dark
# custom_palette=true  
# color_scheme_path=/home/sboynton/.config/qt6ct/colors/catppuccin-mocha.conf
```

Both provide dark icons AND dark menu backgrounds, with Catppuccin using the official Mocha color palette.

### Alternative Themes
Other themes with good symbolic icon support:
- `Adwaita` (default GNOME)
- `breeze` (KDE)
- `Numix` / `Numix-Circle`

## Environment Variables

Ensure these are set in your shell profile:

```bash
export QT_QPA_PLATFORMTHEME=qt6ct
export QT_STYLE_OVERRIDE=Fusion
```

## Troubleshooting

### Problem: "Could not load icon" warnings
**Cause**: Qt applications not using system icon theme
**Solution**: Configure qt6ct as described above

### Problem: System tray menus don't appear
**Cause**: QuickShell not in QApplication mode  
**Solution**: Add `//@ pragma UseQApplication` to shell.qml

### Problem: Icons appear as gray silhouettes
**Cause**: Monochrome icon mode enabled
**Solution**: Set `monochromeIcons: false` in Config.qml

### Problem: Context menus have no icons
**Cause**: Qt theme not configured properly
**Solution**: Ensure `menus_have_icons=true` in qt6ct.conf

## File Structure

After setup, your configuration should include:

```
~/.config/
├── quickshell/
│   ├── shell.qml                 # Has UseQApplication pragma
│   ├── common/Config.qml         # monochromeIcons: false
│   └── bar/
│       ├── SysTray.qml
│       └── SysTrayItem.qml
└── qt6ct/
    └── qt6ct.conf                # Icon theme configuration
```

## Verification

After setup, verify with:

1. **Check icon theme**: `gsettings get org.gnome.desktop.interface icon-theme`
2. **Check Qt config**: `cat ~/.config/qt6ct/qt6ct.conf | grep icon_theme`
3. **Test QuickShell**: Right-click system tray icons should show themed menus

## Notes

- Restart QuickShell after any configuration changes
- Some applications may override icon themes
- Papirus provides the most comprehensive icon coverage
- The setup works for both Qt5 and Qt6 applications
