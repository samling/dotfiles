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
plugins=(git themes osx ssh-agent zsh-syntax-highlighting)

# GCC stuff
export ARCHFLAGS="-arch x86_64"

#eval $(dircolors -b $HOME/LS_COLORS)

ZSH_THEME='sam'
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
export PATH=/Users/sboynton/scripts:/Users/sboynton/scripts/sdk/APK-Multi-Tool:/Users/sboynton/scripts/sdk/platform-tools:/opt/local/bin:/opt/local/sbin:/Users/sboynton/.local/bin:/usr/local/bin:/usr/local/sbin:/bin:/usr/sbin:/sbin:/usr/bin:/opt/X11/bin:/usr/local/munki:/opt/local/bin:/opt/local/sbin

### Rainbarf

## zsh-specific includes
#zmodload -i zsh/datetime
#zmodload -i zsh/stat
#
## store the chart
#RAINBARF_OUT=~/.rainbarf.out
## update period, in seconds
#TMOUT=1
#
## update chart, avoid multiple instances
#rainbarf instances
#rainbarf_update() {
#    # check if non-existent or outdated
#    if [[ \
#        (! -e $RAINBARF_OUT) \
#        || ($(stat +mtime $RAINBARF_OUT) -lt $(($EPOCHSECONDS - $TMOUT))) \
#        ]]; then
#        # rainbarf options should go to ~/.rainbarf.out
#        rainbarf --notmux > $RAINBARF_OUT
#    fi
#}
#rainbarf_update
#
## in-place prompt update hook
#TRAPALRM() {
#    rainbarf_update
#    zle reset-prompt
#}
#
## insert into prompt
#setopt PROMPT_SUBST
#PS1="\$(cat $RAINBARF_OUT)$PS1"
PS1="$PS1"

# Default
#export LSCOLORS='Gxfxcxdxbxegedabagacad'
# Matrix
#export LSCOLORS=Cafacadagaeaeaabagacad
# Molokai
export LSCOLORS='ExFxCxDxBxegedabagacad'

# GNU man pages
#export MANPATH="/usr/local/opt/coreutils/libexec/gnuman:$MANPATH"
