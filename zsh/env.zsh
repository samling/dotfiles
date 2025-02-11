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

# View full path in preview window (?)
export FZF_ALT_C_OPTS="${FZF_ALT_C_OPTS:+$FZF_ALT_C_OPTS }--preview 'echo {}' --preview-window down:5:hidden:wrap --bind '?:toggle-preview'"

# View full command in preview window (?)
# export FZF_CTRL_R_OPTS="${FZF_CTRL_R_OPTS:+$FZF_CTRL_R_OPTS }--preview 'echo {}' --preview-window down:5:hidden:wrap --bind '?:toggle-preview'"
export FZF_CTRL_R_OPTS="--height 50% --preview 'echo {2..} | bat --color=always -pl sh' --preview-window 'wrap,down,5' --bind '?:toggle-preview'"

# Exact-match rather than fuzzy matching by default (use ' to negate)
export FZF_DEFAULT_OPTS="${FZF_DEFAULT_OPTS:+$FZF_DEFAULT_OPTS }--exact"

# Prevent fzf from reducing height to 40% by default
export FZF_DEFAULT_OPTS="${FZF_DEFAULT_OPTS:+$FZF_DEFAULT_OPTS }--no-height"

# Ctrl-T opts
export FZF_CTRL_T_OPTS=""

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
export PATH="$HOME/.pyenv/bin:$PATH"

#=== Rust
export PATH=$PATH:$HOME/.cargo/bin

#=== Snap
export PATH=$PATH:/snap/bin

#=== Terminal
export TERM=screen-256color

#=== VI Mode
export KEYTIMEOUT=1

#=== X11 Forwarding
export XAUTHORITY=$HOME/.Xauthority
