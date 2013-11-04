# Path to your oh-my-zsh configuration.
ZSH=$HOME/.oh-my-zsh

# Set name of the theme to load.
# Look in ~/.oh-my-zsh/themes/
ZSH_THEME='custom'

# Need to be below theme
source $ZSH/oh-my-zsh.sh
if [[ -f .zshrc.local ]]; then
    source .zshrc.local
fi
unsetopt correct_all

# Path
#
# Using Homebrew without Linux CoreUtils
export PATH=/usr/local/rvm/bin:/usr/local/bin:/usr/local/sbin:/opt/local/bin:/opt/local/sbin:/Users/sboynton/.local.bin:/usr/bin:/bin:/usr/sbin:/sbin:/opt/X11/bin:/usr/local/munki:$PATH
#
# Using Homebrew + Linux CoreUtils
#export PATH=/usr/local/opt/coreutils/libexec/gnubin:/opt/local/bin:/opt/local/sbin:/usr/local/bin:/usr/local/sbin:/bin:/usr/sbin:/sbin:/usr/bin:/opt/X11/bin:/usr/local/munki:/opt/local/bin:/opt/local/sbin

# GNU man pages
#export MANPATH="/usr/local/opt/coreutils/libexec/gnuman:$MANPATH"

# Which plugins would you like to load? (plugins can be found in ~/.oh-my-zsh/plugins/*)
# Custom plugins may be added to ~/.oh-my-zsh/custom/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
plugins=(git themes osx zsh-syntax-highlighting)

# Environment
export TERM=xterm-256color
export LC_ALL=en_US.UTF-8
export LANG=en_US.UTF-8

# Default editor
export EDITOR="vim"

# Remove ctrl-l and ctrl-j to make way for tmux
bindkey -r '^l'
bindkey -r '^j'

# Tmux
export TMUX_POWERLINE_SEG_WETHER_LOCATION="2411898"

# Tmuxinator
source ~/dotfiles/tmux/completion/tmuxinator.zsh

# GCC
export ARCHFLAGS="-arch x86_64"

# Ruby
#export RBENV_ROOT="$(brew --prefix rbenv)"
#export GEM_HOME="$(brew --prefix)/opt/gems"
#export GEM_PATH="$(brew --prefix)/opt/gems"
#PATH=$PATH:$HOME/.rvm/bin # Add RVM to PATH for scripting

# Setting up GMail in Mutt
#MAIL=/var/spool/mail/sboynton && export MAIL

###  Write TLS keys used by browser to flat file
#export SSLKEYLOGFILE=/Users/sboynton/Documents/Security/tlskeys

### LS_COLORS
#
# Matrix
# export LSCOLORS=Cafacadagaeaeaabagacad
# Molokai
export LSCOLORS='ExFxCxDxBxegedabagacad'
# Template
# export LSCOLORS='xxxxxxxxxxxxxxxxxxxxxx'
#
# From the man pages:
#
# Default: exfxcxdxbxegedabagacad
#
# a     black
# b     red
# c     green
# d     brown
# e     blue
# f     magenta
# g     cyan
# h     light grey
# A     bold black, usually shows up as dark grey
# B     bold red
# C     bold green
# D     bold brown, usually shows up as yellow
# E     bold blue
# F     bold magenta
# G     bold cyan
# H     bold light grey; looks like bright white
# x     default foreground or background 
#
# 1.   directory
# 2.   symbolic link
# 3.   socket
# 4.   pipe
# 5.   executable
# 6.   block special
# 7.   character special
# 8.   executable with setuid bit set
# 9.   executable with setgid bit set
# 10.  directory writable to others, with sticky bit
# 11.  directory writable to others, without sticky bit
