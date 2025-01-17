# fpath
#
fpath=($HOME/dotfiles/zsh $fpath)
fpath+=($HOME/dotfiles/zsh/pure)

# compinit
#
autoload -U +X compinit && compinit

autoload -Uz compinit bashcompinit

for dump in ~/.zcompdump(N.mh+24);do
  compinit
done
bashcompinit

autoload -U promptinit; promptinit

# Starship prompt
#
# eval "$(starship init zsh)"

# Pure prompt
#
prompt pure
