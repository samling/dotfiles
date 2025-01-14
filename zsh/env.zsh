# Environment
export LC_ALL=en_US.UTF-8
export LANG=en_US.UTF-8

# X11 Forwarding
export XAUTHORITY=$HOME/.Xauthority

# Default editor
export EDITOR="vim"

# fzf
export FZF_DEFAULT_COMMAND='rg --files --no-ignore-vcs --hidden'

# GCC
export ARCHFLAGS="-arch $(uname -m)"

# VI Mode
export KEYTIMEOUT=1
