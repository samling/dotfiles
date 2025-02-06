# Reset PATH
#
unset PATH

# Essential paths
#
PATH=$PATH:/usr/local:/usr/local/bin:/usr/local/sbin:/usr/bin:/bin:/usr/sbin:/sbin

# Homebrew
#
PATH=/opt/homebrew/sbin:/opt/homebrew/bin:$PATH

# pip
#
PATH=$PATH:${HOME}/.local/bin

# fzf
#
PATH=$PATH:${HOME}/.fzf/bin

# Final path export
#
export PATH
