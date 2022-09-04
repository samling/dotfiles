# Plugins
#
source ~/dotfiles/zsh/zsh-history-substring-search.zsh

# Commands
#
source ~/dotfiles/zsh/cmd.zsh

# Environment
#
source ~/dotfiles/zsh/env.zsh

# Path
#
source ~/dotfiles/zsh/path.zsh

# Setopt
#
source ~/dotfiles/zsh/opt.zsh

# Prompt theme
#
source ~/dotfiles/zsh/prompt.zsh

# Key bindings
#
source ~/dotfiles/zsh/keys.zsh

# Tmuxinator
source ~/dotfiles/tmux/completion/tmuxinator.zsh

# LS_COLORS
#
source ~/dotfiles/zsh/lscolors.zsh

# Custom aliases
#
source ~/dotfiles/zsh/aliases/custom.zsh

# Custom functions
#
source ~/dotfiles/zsh/functions.zsh

# Source ${HOME}/zshrc-local/zshrc.*.local files
#
LOCAL_DOTFILES_GIT=(${HOME}/zshrc-local/zshrc.*.local)
if [[ ! -z ${LOCAL_DOTFILES_GIT} && ${LOCAL_DOTFILES_GIT} != "${HOME}/zshrc-local/zshrc.*.local" ]]; then
    for dotfile in ${LOCAL_DOTFILES_GIT}; do
        echo -e "Sourced local dotfile from git repo: $dotfile"
        source $dotfile
    done
fi

LOCAL_DOTFILES=(${HOME}/.zshrc.*)
if [[ ! -z ${LOCAL_DOTFILES} && ${LOCAL_DOTFILES} != "${HOME}/.zshrc.*" ]]; then
    for dotfile in ${LOCAL_DOTFILES}; do
        echo -e "Sourced local dotfile: $dotfile"
        source $dotfile
    done
fi

# Enable fuzzy finder
#
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
