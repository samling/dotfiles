# Reset PATH
#
unset PATH

# Essential paths
#
PATH=$PATH:/usr/local
PATH=$PATH:/usr/local/bin
PATH=$PATH:/usr/local/sbin
PATH=$PATH:/usr/bin
PATH=$PATH:/bin
PATH=$PATH:/usr/sbin
PATH=$PATH:/sbin

# Local paths (put first in order to take precedence)
#
PATH=$PATH:${HOME}/.local/bin

#=== XDG
export XDG_DATA_DIRS=/usr/share:/usr/local/share:$XDG_DATA_DIRS

# Homebrew
#
PATH=$PATH:/opt/homebrew/sbin:/opt/homebrew/bin

# fzf
#
PATH=$PATH:${HOME}/.fzf/bin

# Final path export
#
export PATH
