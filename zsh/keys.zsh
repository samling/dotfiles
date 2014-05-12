# Remove ctrl-l and ctrl-j to make way for tmux
bindkey -r '^l'
bindkey -r '^j'

# Bind UP and DOWN arrow keys
bindkey "^[[A" history-substring-search-up
bindkey "^[[B" history-substring-search-down
