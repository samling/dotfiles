#=== fpath (must be at top)
fpath=($HOME/dotfiles/zsh $fpath)
fpath+=($HOME/dotfiles/zsh/pure)

#=== compinit
autoload -U +X compinit && compinit

autoload -Uz compinit bashcompinit

for dump in ~/.zcompdump(N.mh+24);do
  compinit
done
bashcompinit

autoload -U promptinit; promptinit

#=== completions
source <(kubectl completion zsh)
command -v flux >/dev/null && source <(flux completion zsh)

#=== Direnv
eval "$(direnv hook zsh)"

#=== Starship prompt
# eval "$(starship init zsh)"

#=== Pure prompt
prompt pure

#=== Pyenv
if command -v pyenv &> /dev/null; then
  # Activate pyenv
  eval "$(pyenv init -)"

  # Activate pyenv-virtualenv only on directory changes
  # https://github.com/pyenv/pyenv-virtualenv/issues/259#issuecomment-173112392
  # Note: There is still a bit of slowness on actually changing directories; comenting out for now
  # since I can live without it.
  #
  #eval "$(pyenv virtualenv-init - | sed s/precmd/chpwd/g)"
  #_pyenv_virtualenv_hook
fi

#=== Zoxide
eval "$(zoxide init zsh --cmd cd)"
