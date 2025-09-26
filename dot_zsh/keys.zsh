# Enable emacs mode (default)
bindkey -e

# Remove ctrl-l and ctrl-j to make way for tmux
bindkey -r '^l'
bindkey -r '^j'

# Bind UP and DOWN arrow keys
bindkey "^[[A" history-substring-search-up
bindkey "^[[B" history-substring-search-down

bindkey "^[[1;5C" forward-word
bindkey "^[[1;5D" backward-word

# Bind option-backspace to delete word
bindkey '^[^?' backward-kill-word

# Unbind ctrl-p/ctrl-n
bindkey -r "^p"
bindkey -r "^n"

#========= C-x C-e to edit the current command in $EDITOR

autoload -U edit-command-line
zle -N edit-command-line
bindkey '^xe' edit-command-line
bindkey '^x^e' edit-command-line

#========= C-s to bring up the cs menu

function cs-select() {
  RBUFFER=$(cs exec)
  CURSOR=$#BUFFER
  zle redisplay
}
zle -N cs-select
stty -ixon
bindkey -r '^s'
bindkey '^s' cs-select
