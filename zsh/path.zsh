# Reset PATH
#
unset PATH

# Homebrew
#
PATH=/opt/homebrew/sbin:/opt/homebrew/bin:$PATH


# Essential paths
#
PATH=$PATH:/usr/local:/usr/local/bin:/usr/local/sbin:/usr/bin:/bin:/usr/sbin:/sbin

# pip
#
PATH=$PATH:${HOME}/.local/bin

# Final path export
#
export PATH
