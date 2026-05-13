# Essential paths. fish_add_path is idempotent + dedupes natively.
for dir in /usr/local /usr/local/bin /usr/local/sbin /usr/bin /bin /usr/sbin /sbin \
    $HOME/.local/usr/bin $HOME/.local/bin
    fish_add_path -gP $dir
end

# asdf shims
set -l asdf_data $ASDF_DATA_DIR
test -z "$asdf_data"; and set asdf_data $HOME/.asdf
fish_add_path -gP $asdf_data/shims

# Homebrew
fish_add_path -gP /opt/homebrew/sbin /opt/homebrew/bin

# fzf
fish_add_path -gP $HOME/.fzf/bin

# XDG_DATA_DIRS (system + flatpak)
set -l xdg_dirs /usr/share /usr/local/share \
    /var/lib/flatpak/exports/share \
    /var/lib/flatpak/exports/share/applications \
    $HOME/.local/share/flatpak/exports/share
if set -q XDG_DATA_DIRS
    set -gx XDG_DATA_DIRS (string join : $xdg_dirs $XDG_DATA_DIRS)
else
    set -gx XDG_DATA_DIRS (string join : $xdg_dirs)
end
