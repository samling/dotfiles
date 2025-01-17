# fpath
#
fpath=($HOME/dotfiles/zsh $fpath)

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
eval "$(starship init zsh)"

# Pure prompt
#
# fpath+=($HOME/dotfiles/zsh/pure)
# prompt pure
