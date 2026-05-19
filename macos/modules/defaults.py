# macOS preferences applied via `defaults write` (safe to re-run).
from pyinfra.operations import server

# (domain, key, type, value).
DEFAULTS = [
    # Keyboard: enable key repeat (vim-style editing) and speed it up.
    ("NSGlobalDomain", "ApplePressAndHoldEnabled", "-bool", "false"),
    ("NSGlobalDomain", "KeyRepeat", "-int", "2"),
    ("NSGlobalDomain", "InitialKeyRepeat", "-int", "15"),
    # Finder: show extensions, path/status bars, list view, sane search.
    ("NSGlobalDomain", "AppleShowAllExtensions", "-bool", "true"),
    ("com.apple.finder", "ShowPathbar", "-bool", "true"),
    ("com.apple.finder", "ShowStatusBar", "-bool", "true"),
    ("com.apple.finder", "FXPreferredViewStyle", "-string", "Nlsv"),
    ("com.apple.finder", "_FXSortFoldersFirst", "-bool", "true"),
    ("com.apple.finder", "FXDefaultSearchScope", "-string", "SCcf"),
    ("com.apple.finder", "FXEnableExtensionChangeWarning", "-bool", "false"),
    # Stop .DS_Store files on network and USB volumes.
    ("com.apple.desktopservices", "DSDontWriteNetworkStores", "-bool", "true"),
    ("com.apple.desktopservices", "DSDontWriteUSBStores", "-bool", "true"),
    # Dock: auto-hide, no recent apps, stable Spaces order.
    ("com.apple.dock", "autohide", "-bool", "true"),
    ("com.apple.dock", "show-recents", "-bool", "false"),
    ("com.apple.dock", "mru-spaces", "-bool", "false"),
    # Expand save and print dialogs by default.
    ("NSGlobalDomain", "NSNavPanelExpandedStateForSaveMode", "-bool", "true"),
    ("NSGlobalDomain", "PMPrintingExpandedStateForPrint", "-bool", "true"),
]

for domain, key, vtype, value in DEFAULTS:
    server.shell(
        name=f"defaults write {domain} {key}",
        commands=[f'defaults write {domain} {key} {vtype} "{value}"'],
    )

if DEFAULTS:
    server.shell(
        name="restart Dock and Finder",
        commands=["killall Dock Finder SystemUIServer 2>/dev/null || true"],
    )
