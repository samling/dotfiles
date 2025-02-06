#=== Builtin Replacements
alias cat="bat -pp"
alias df="duf -hide special,fuse"
alias find="fd"
alias grep="rg -u"
alias top="btop"
alias watch="viddy -d"
alias vi=nvim
alias vim=nvim

#=== cd
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

#=== Defaults
alias ddi="sudo killall -INFO dd" # Shows progress of dd in the window that dd is running in
alias df="df -kH" # Clean disk info
alias rm='rm -iv' # Prevent clobbering
alias cp='cp -iv' # Prevent clobbering
alias mv='mv -iv' # Prevent clobbering

#=== Extra tools
alias jinaai="curl https://r.jina.ai -H \"Authorization: Bearer ${JINA_AI_API_KEY}\""
alias lg="lazygit"
alias tldr="tealdeer"
alias yless="jless --yaml"

#=== Kubectl
alias k="kubectl"
alias kubectx="FZF_DEFAULT_OPTS='--reverse' kubectl ctx"
alias kx="FZF_DEFAULT_OPTS='--reverse' kubectl ctx"
alias kubens="FZF_DEFAULT_OPTS='--reverse' kubectl-ns"
alias kn="FZF_DEFAULT_OPTS='--reverse' kubectl-ns"

#=== ls
alias ls="lsd"
alias l="ls -a"
alias ll="ls -lahg"
alias lll="ls -lahg --blocks permission,user,group,size,date,name"

#=== Shortcuts
alias b64='base64'
alias o="open"
alias v="clear" # clear terminal
alias R='cd $HOME && source .zshrc && cd - && echo ".zshrc reloaded"' # reload zsh
alias which='type -a'

#=== Tmux
alias tmux="direnv exec / tmux"
