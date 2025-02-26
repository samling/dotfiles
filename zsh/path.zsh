# Reset PATH
#
unset PATH

# Essential paths
#
PATH=/usr/local
PATH=/usr/local/bin:$PATH
PATH=/usr/local/sbin:$PATH
PATH=/usr/bin:$PATH
PATH=/bin:$PATH
PATH=/usr/sbin:$PATH
PATH=/sbin:$PATH

# Local paths
#
PATH=$PATH:${HOME}/.local/bin

# Homebrew
#
PATH=$PATH:/opt/homebrew/sbin:/opt/homebrew/bin

# fzf
#
PATH=$PATH:${HOME}/.fzf/bin

# Final path export
#
export PATH
