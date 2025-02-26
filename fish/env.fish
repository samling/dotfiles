# Environment
set -gx LC_ALL en_US.UTF-8
set -gx LANG en_US.UTF-8

# Colorized man pages
set -gx MANPAGER "sh -c 'col -bx | bat -l man -p --paging always'"

# Default editor
set -gx EDITOR vim

# FZF Configuration
set -gx FZF_TMUX 0
set -gx FZF_DEFAULT_COMMAND 'rg --files --no-ignore-vcs --hidden'
set -gx FZF_DEFAULT_OPTS '--exact --no-height'
set -gx FZF_ALT_C_OPTS "--height 50% --preview 'ls {1..} | bat --color=always -pl sh' --preview-window 'wrap,down,5' --bind '?:toggle-preview'"
set -gx FZF_CTRL_R_OPTS "--height 100% --preview 'echo {2..} | bat --color=always -pl sh' --preview-window 'wrap,down,5' --bind '?:toggle-preview'"
set -gx FZF_CTRL_T_OPTS "--height 100% --preview 'less {} | bat --color=always -pl sh' --preview-window 'wrap,down,25' --bind '?:toggle-preview'"

# GCC
set -gx ARCHFLAGS "-arch $(uname -m)"

# Kubernetes
# Consume all *.yaml kubeconfigs in ${HOME}/.kube/kubeconfigs
if command -q fd
    set -gx KUBECONFIG $HOME/.kube/config:(fd . $HOME/.kube/kubeconfigs -e yaml -e yml | string join ':')
else
    set -gx KUBECONFIG $HOME/.kube/config:(find $HOME/.kube/kubeconfigs \( -iname \*.yml -o -iname \*.yaml \) | string join ':')
end

# Pyenv
set -Ux PYENV_ROOT $HOME/.pyenv
fish_add_path $PYENV_ROOT/bin

# Kubernetes config
set -gx KUBECONFIG $HOME/.kube/config:(fd . $HOME/.kube/kubeconfigs -e yaml -e yml | string join ':') 