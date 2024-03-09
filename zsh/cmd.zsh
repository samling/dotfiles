fpath=($HOME/dotfiles/zsh $fpath)
fpath+=($HOME/dotfiles/zsh/pure)

autoload -Uz compinit bashcompinit

for dump in ~/.zcompdump(N.mh+24);do
  compinit
done
bashcompinit

autoload -U promptinit; promptinit
prompt pure
