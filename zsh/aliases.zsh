#####
##### Global Aliases
#####

###
### Reload zsh
###
alias R='cd $HOME && source .zshrc && cd - && echo ".zshrc reloaded"'

###
### Shortcuts
###
alias o="open"

###
### Redefining and extending existing functions
###
alias rm='rm -iv' # Prevent clobbering
alias cp='cp -iv' # Prevent clobbering
alias mv='mv -iv' # Prevent clobbering
alias which='type -a'
alias b64='base64'

###
### Directory changing
###

alias .='cd ..'
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias .....='cd ../../../..'
alias ......='cd ../../../../..'
alias .......='cd ../../../../../..'
alias ........='cd ../../../../../../..'
alias .........='cd ../../../../../../../..'
alias ..........='cd ../../../../../../../../..'
alias ...........='cd ../../../../../../../../../..'
alias ............='cd ../../../../../../../../../../..'
alias .............='cd ../../../../../../../../../../../..'
alias ..............='cd ../../../../../../../../../../../../..'
alias ...............='cd ../../../../../../../../../../../../../..'

###
### Utilities and Information
###
alias df="df -kH" # Clean disk info
alias v="clear"
alias ddi="sudo killall -INFO dd" # Shows progress of dd in the window that dd is running in

#####
##### Modify terminal behavior
#####

export HISTCONTROL=ignoreboth # Prevent duplicates in history
export HISTCONTROL=erasedups # Prevent duplicates in history
