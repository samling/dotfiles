#=== Environment
export LC_ALL=en_US.UTF-8
export LANG=en_US.UTF-8

#=== Colorized man pages
export MANPAGER="sh -c 'col -bx | bat -l man -p --paging always'"

#=== Default editor
export EDITOR="vim"

#=== fzf
# Enable separate tmux pane for fzf
export FZF_TMUX=0

# Set ag to be the default grep tool for fzf
export FZF_DEFAULT_COMMAND='ag -g ""'

# Unset opts to prevent appending multiple times in nested shells
unset FZF_ALT_C_OPTS FZF_CTRL_R_OPTS FZF_DEFAULT_OPTS

# Alt-C opts
# export FZF_ALT_C_OPTS="${FZF_ALT_C_OPTS:+$FZF_ALT_C_OPTS }--preview 'echo {}' --preview-window down:5:hidden:wrap --bind '?:toggle-preview'"
export FZF_ALT_C_OPTS="--height 50% --preview 'ls {1..} | bat --color=always -pl sh' --preview-window 'wrap,down,5' --bind '?:toggle-preview'"

# Ctrl-R opts
export FZF_CTRL_R_OPTS="--height 100% --preview 'echo {2..} | bat --color=always -pl sh' --preview-window 'wrap,down,5' --bind '?:toggle-preview'"

# Ctrl-T opts
export FZF_CTRL_T_OPTS="--height 100% --preview 'less {} | bat --color=always -pl sh' --preview-window 'wrap,down,25' --bind '?:toggle-preview'"

# Exact-match rather than fuzzy matching by default (use ' to negate)
export FZF_DEFAULT_OPTS="${FZF_DEFAULT_OPTS:+$FZF_DEFAULT_OPTS }--exact"

# Prevent fzf from reducing height to 40% by default
export FZF_DEFAULT_OPTS="${FZF_DEFAULT_OPTS:+$FZF_DEFAULT_OPTS }--no-height"

# Default command to run in fzf
export FZF_DEFAULT_COMMAND='rg --files --no-ignore-vcs --hidden'

#=== GCC
export ARCHFLAGS="-arch $(uname -m)"

#=== GoLang
unset GOROOT
unset GOPATH
export PATH=/usr/local/go/bin:$PATH
export PATH=$HOME/go/bin/:$PATH

#=== Krew
export PATH="${KREW_ROOT:-$HOME/.krew}/bin:$PATH"

#=== Kubernetes
# Consume all *.yaml kubeconfigs in ${HOME}/.kube/kubeconfigs
if command -v fd &> /dev/null; then
  export KUBECONFIG=${HOME}/.kube/config:$(for YAML in $(fd . ${HOME}/.kube/kubeconfigs -e yaml -e yml); do echo -n ":${YAML}"; done)
else
  export KUBECONFIG=${HOME}/.kube/config:$(for YAML in $(find ${HOME}/.kube/kubeconfigs \( -iname \*.yml -o -iname \*.yaml \)) ; do echo -n ":${YAML}"; done)
fi

#=== Locales
export LANG=en_US.UTF-8

#=== Pulumi
export PATH="$HOME/.pulumi/bin:$PATH"

#=== Pyenv
# export PATH="$HOME/.pyenv/bin:$PATH"
export PYENV_ROOT="$HOME/.pyenv"
[[ -d $PYENV_ROOT/bin ]] && export PATH="$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init - zsh)"

#=== Rust
export PATH=$PATH:$HOME/.cargo/bin

#=== Snap
export PATH=$PATH:/snap/bin

#=== Terminal
# export TERM=screen-256color

#=== VI Mode
export KEYTIMEOUT=1

#=== X11 Forwarding
export XAUTHORITY=$HOME/.Xauthority

#=== Zoxide
# export _ZO_FZF_OPTS="--exact --no-sort --bind=ctrl-z:ignore,btab:up,tab:down --cycle --keep-right --border=sharp --height=45% --info=inline --layout=reverse --tabstop=1 --exit-0 --preview='command -p ls {2..}'"
