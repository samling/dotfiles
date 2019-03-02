# Enable vi mode
#bindkey -v

# Remove ctrl-l and ctrl-j to make way for tmux
bindkey -r '^l'
bindkey -r '^j'

# Bind UP and DOWN arrow keys
bindkey "^[[A" history-substring-search-up
bindkey "^[[B" history-substring-search-down

bindkey "^[[1;5C" forward-word
bindkey "^[[1;5D" backward-word
