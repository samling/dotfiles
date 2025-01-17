# Enable profiling
#
# zmodload zsh/zprof

# Required
#
export ZSH_VERSION=$ZSH_VERSION
[ -f "${HOME}/dotfiles-private/github-token" ] && export GITHUB_TOKEN

# Source global config
#
source ~/dotfiles/zsh/plugins/zsh-history-substring-search.zsh
source ~/dotfiles/zsh/plugins/git-auto-fetch.plugin.zsh
source ~/dotfiles/zsh/cmd.zsh
source ~/dotfiles/zsh/env.zsh
source ~/dotfiles/zsh/path.zsh
source ~/dotfiles/zsh/opt.zsh
source ~/dotfiles/zsh/keys.zsh
source ~/dotfiles/zsh/aliases.zsh
source ~/dotfiles/zsh/functions.zsh
source ~/dotfiles/zsh/fnm.zsh

## Plugins
#
plugins=(git-auto-fetch)

# Source ${HOME}/dotfiles-private/zshrc.*.local files
#
LOCAL_DOTFILES_GIT=(${HOME}/dotfiles-private/zsh/zshrc.*.local)
if [[ ! -z ${LOCAL_DOTFILES_GIT} && ${LOCAL_DOTFILES_GIT} != "${HOME}/dotfiles-private/zsh/zshrc.*.local" ]]; then
    for dotfile in ${LOCAL_DOTFILES_GIT}; do
        #echo -e "Sourced local dotfile from git repo: $dotfile"
        source $dotfile
    done
fi

# Source ${HOME}/.zshrc.* files
#
LOCAL_DOTFILES=(${HOME}/.zshrc.*)
if [[ ! -z ${LOCAL_DOTFILES} && ${LOCAL_DOTFILES} != "${HOME}/.zshrc.*" ]]; then
    for dotfile in ${LOCAL_DOTFILES}; do
        #echo -e "Sourced local dotfile: $dotfile"
        source $dotfile
    done
fi

# Enable fuzzy finder
#
# [ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
source <(fzf --zsh)

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

# Run profiling
# zprof

# fnm
FNM_PATH="/home/sboynton/.local/share/fnm"
if [ -d "$FNM_PATH" ]; then
  export PATH="/home/sboynton/.local/share/fnm:$PATH"
  eval "`fnm env`"
fi

# fnm
FNM_PATH="/home/sboynton/.local/share/fnm"
if [ -d "$FNM_PATH" ]; then
  export PATH="/home/sboynton/.local/share/fnm:$PATH"
  eval "`fnm env`"
fi
