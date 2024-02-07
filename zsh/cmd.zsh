fpath=($HOME/dotfiles/zsh $fpath)
fpath+=($HOME/dotfiles/zsh/pure)

autoload -Uz compinit bashcompinit

compinit
bashcompinit

autoload -U promptinit; promptinit
prompt pure
