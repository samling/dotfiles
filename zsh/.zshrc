# Path to your oh-my-zsh configuration.
ZSH=$HOME/.oh-my-zsh

# Set name of the theme to load.
# Look in ~/.oh-my-zsh/themes/
# Optionally, if you set this to "random", it'll load a random theme each
# time that oh-my-zsh is loaded.
#ZSH_THEME="robbyrussell"

# Example aliases
# alias zshconfig="mate ~/.zshrc"
# alias ohmyzsh="mate ~/.oh-my-zsh"

# Set to this to use case-sensitive completion
# CASE_SENSITIVE="true"

# Comment this out to disable bi-weekly auto-update checks
# DISABLE_AUTO_UPDATE="true"

# Uncomment to change how many often would you like to wait before auto-updates occur? (in days)
# export UPDATE_ZSH_DAYS=13

# Uncomment following line if you want to disable colors in ls
# DISABLE_LS_COLORS="true"

# Uncomment following line if you want to disable autosetting terminal title.
# DISABLE_AUTO_TITLE="true"

# Uncomment following line if you want red dots to be displayed while waiting for completion
# COMPLETION_WAITING_DOTS="true"

# Which plugins would you like to load? (plugins can be found in ~/.oh-my-zsh/plugins/*)
# Custom plugins may be added to ~/.oh-my-zsh/custom/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
plugins=(git themes osx zsh-syntax-highlighting)

# GCC stuff
export ARCHFLAGS="-arch x86_64"

#eval $(dircolors -b $HOME/LS_COLORS)

ZSH_THEME='clean-check'
#ZSH_THEME='clean-sam'
#DEFAULT_USER='sboynton'

source $ZSH/oh-my-zsh.sh
unsetopt correct_all

# Setting up GMail in Mutt
MAIL=/var/spool/mail/sboynton && export MAIL

# Customize to your needs...
### Using MacPorts + Linux CoreUtils
#export PATH=/opt/local/libexec/gnubin:/opt/local/bin:/opt/local/sbin:/usr/local/bin:/bin:/usr/sbin:/sbin:/usr/bin:/opt/X11/bin:/usr/local/munki:/opt/local/bin:/opt/local/sbin

### Using Homebrew + Linux CoreUtils
#export PATH=/usr/local/opt/coreutils/libexec/gnubin:/opt/local/bin:/opt/local/sbin:/usr/local/bin:/usr/local/sbin:/bin:/usr/sbin:/sbin:/usr/bin:/opt/X11/bin:/usr/local/munki:/opt/local/bin:/opt/local/sbin

### Using Homebrew without Linux CoreUtils
export PATH=/Users/sboynton/scripts:/Users/sboynton/.local.bin:/usr/local/bin:/usr/local/sbin:/opt/local/bin:/opt/local/sbin:/usr/bin:/bin:/usr/sbin:/sbin:/opt/X11/bin:/usr/local/munki

###  Write TLS keys used by browser to flat file
#export SSLKEYLOGFILE=/Users/sboynton/Documents/Security/tlskeys

# Default
#export LSCOLORS='Gxfxcxdxbxegedabagacad'
# Matrix
#export LSCOLORS=Cafacadagaeaeaabagacad
# Molokai
export LSCOLORS='ExFxCxDxBxegedabagacad'

export TERM=xterm-256color
# GNU man pages
#export MANPATH="/usr/local/opt/coreutils/libexec/gnuman:$MANPATH"
