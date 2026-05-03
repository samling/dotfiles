#=== fpath (must be at top)
fpath=($HOME/.zsh $fpath)
fpath+=($HOME/.local/share/zsh/pure)

#=== compinit
# Fast path: skip compaudit + dump rebuild unless ~/.zcompdump is older than 24h.
# Saves ~100ms per shell.
autoload -U compinit bashcompinit promptinit
if [[ -n ~/.zcompdump(#qN.mh+24) || ! -f ~/.zcompdump ]]; then
  compinit
else
  compinit -C
fi
promptinit
bashcompinit

#=== completion cache helper
# Runs `$2…` to generate a zsh completion script, caches it under
# ~/.cache/zsh-completions/$1, and sources the cache on subsequent shells.
# Rebuilds when the cache is >24h old or the generating binary is newer.
_cached_completion() {
  local name=$1; shift
  local cache_dir=${XDG_CACHE_HOME:-$HOME/.cache}/zsh-completions
  local cache=$cache_dir/$name.zsh
  [[ -d $cache_dir ]] || mkdir -p $cache_dir
  local bin=${commands[$1]}
  if [[ ! -s $cache || -n $cache(#qN.mh+24) || ( -n $bin && $bin -nt $cache ) ]]; then
    "$@" >| $cache 2>/dev/null
  fi
  [[ -s $cache ]] && source $cache
}

#=== asdf
command -v asdf >/dev/null && _cached_completion asdf asdf completion zsh

#=== colima
command -v colima >/dev/null && _cached_completion colima colima completion zsh

#=== direnv
command -v direnv >/dev/null && _cached_completion direnv direnv hook zsh

#=== flux
command -v flux >/dev/null && _cached_completion flux flux completion zsh

#=== fx
command -v fx >/dev/null && _cached_completion fx fx --comp zsh

#=== fzf
command -v fzf >/dev/null && _cached_completion fzf fzf --zsh

#=== kubectl
command -v kubectl >/dev/null && _cached_completion kubectl kubectl completion zsh

#=== kubecolor
command -v kubecolor >/dev/null && compdef kubecolor=kubectl

#=== plz
command -v plz >/dev/null && _cached_completion plz plz --completion_script

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
command -v talosctl >/dev/null && _cached_completion talosctl talosctl completion zsh
command -v talhelper >/dev/null && _cached_completion talhelper talhelper completion zsh

#=== uv
command -v uv >/dev/null && _cached_completion uv uv generate-shell-completion zsh

#=== vault
command -v vault >/dev/null && complete -o nospace -C vault vault

#=== vault
command -v vkv >/dev/null && _cached_completion vkv vkv completion zsh

#=== zellij
# Post-process the output (strip compdef mismatch) before caching.
if command -v zellij >/dev/null; then
  _zellij_gen() { zellij setup --generate-completion zsh | sed -Ee 's/^(_(zellij) ).*/compdef \1\2/'; }
  _cached_completion zellij _zellij_gen
  unset -f _zellij_gen
fi

#=== zoxide
command -v zoxide >/dev/null && _cached_completion zoxide zoxide init zsh --cmd cd
