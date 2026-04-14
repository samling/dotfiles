# Reset PATH
#
#unset PATH

# Essential paths
#
PATH=$PATH:/usr/local
PATH=$PATH:/usr/local/bin
PATH=$PATH:/usr/local/sbin
PATH=$PATH:/usr/bin
PATH=$PATH:/bin
PATH=$PATH:/usr/sbin
PATH=$PATH:/sbin
PATH=$PATH:${HOME}/.local/usr/bin
PATH=$PATH:${HOME}/.local/bin

#=== asdf
export PATH="${ASDF_DATA_DIR:-$HOME/.asdf}/shims:$PATH"

#=== XDG
export XDG_DATA_DIRS=/usr/share:/usr/local/share:$XDG_DATA_DIRS

#=== Flatpak
export XDG_DATA_DIRS=/var/lib/flatpak/exports/share:$XDG_DATA_DIRS
export XDG_DATA_DIRS=/var/lib/flatpak/exports/share/applications:$XDG_DATA_DIRS
export XDG_DATA_DIRS=$HOME/.local/share/flatpak/exports/share:$XDG_DATA_DIRS

# Homebrew
#
PATH=$PATH:/opt/homebrew/sbin:/opt/homebrew/bin

# fzf
#
PATH=$PATH:${HOME}/.fzf/bin

# Final path export
#
export PATH
