#=== fpath (must be at top)
fpath=($HOME/.zsh $fpath)
fpath+=($HOME/.zsh/pure)

#=== compinit
autoload -U compinit bashcompinit promptinit
compinit
promptinit
bashcompinit

for dump in ~/.zcompdump(N.mh+24);do
  compinit
done

#=== asdf
command -v asdf >/dev/null && source <(asdf completion zsh)

#=== colima
command -v colima >/dev/null && source <(colima completion zsh)

#=== direnv
eval "$(direnv hook zsh)"

#=== flux
command -v flux >/dev/null && source <(flux completion zsh)

#=== fx
if [[ -x $(command -v fx) ]]; then
  source <(fx --comp zsh)
fi

#=== fzf
# [ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
#source "$(fzf --zsh)"
eval "$(fzf --zsh)"

#=== kubectl
source <(kubectl completion zsh)

#=== plz
source <(plz --completion_script)

#=== pure prompt
prompt pure

#=== pyenv
#if command -v pyenv &> /dev/null; then
#  # Activate pyenv
#  eval "$(pyenv init - zsh)"
#
#  # Activate pyenv-virtualenv only on directory changes
#  # https://github.com/pyenv/pyenv-virtualenv/issues/259#issuecomment-173112392
#  # Note: There is still a bit of slowness on actually changing directories; comenting out for now
#  # since I can live without it.
#  #
#  #eval "$(pyenv virtualenv-init - | sed s/precmd/chpwd/g)"
#  #_pyenv_virtualenv_hook
#fi

#=== starship prompt
#eval "$(starship init zsh)"

#=== talos
source <(talosctl completion zsh)
source <(talhelper completion zsh)

#=== uv
eval "$(uv generate-shell-completion zsh)"

#=== zellij
source <( zellij setup --generate-completion zsh | sed -Ee 's/^(_(zellij) ).*/compdef \1\2/' )

#=== zoxide
eval "$(zoxide init zsh --cmd cd)"
