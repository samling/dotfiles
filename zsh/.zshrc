# Required
#
export ZSH_VERSION=$ZSH_VERSION
[ -f "${HOME}/dotfiles-private/github-token" ] && export GITHUB_TOKEN

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

# Prompt functions
#
source ~/dotfiles/zsh/PS1.zsh

# Source ${HOME}/dotfiles-private/zshrc.*.local files
#
LOCAL_DOTFILES_GIT=(${HOME}/dotfiles-private/zsh/zshrc.*.local)
if [[ ! -z ${LOCAL_DOTFILES_GIT} && ${LOCAL_DOTFILES_GIT} != "${HOME}/dotfiles-private/zsh/zshrc.*.local" ]]; then
    for dotfile in ${LOCAL_DOTFILES_GIT}; do
        #echo -e "Sourced local dotfile from git repo: $dotfile"
        source $dotfile
    done
fi

LOCAL_DOTFILES=(${HOME}/.zshrc.*)
if [[ ! -z ${LOCAL_DOTFILES} && ${LOCAL_DOTFILES} != "${HOME}/.zshrc.*" ]]; then
    for dotfile in ${LOCAL_DOTFILES}; do
        #echo -e "Sourced local dotfile: $dotfile"
        source $dotfile
    done
fi

# Enable fuzzy finder
#
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

# >>> conda initialize >>>
# !! Contents within this block are managed by 'conda init' !!
__conda_setup="$('/home/sboynton/miniconda3/bin/conda' 'shell.zsh' 'hook' 2> /dev/null)"
if [ $? -eq 0 ]; then
    eval "$__conda_setup"
else
    if [ -f "/home/sboynton/miniconda3/etc/profile.d/conda.sh" ]; then
        . "/home/sboynton/miniconda3/etc/profile.d/conda.sh"
    else
        export PATH="/home/sboynton/miniconda3/bin:$PATH"
    fi
fi
unset __conda_setup
# <<< conda initialize <<<

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion
