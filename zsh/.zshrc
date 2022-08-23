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
LOCAL_DOTFILES=(${HOME}/zshrc-local/zshrc.*.local)
for dotfile in ${LOCAL_DOTFILES}; do
    source $dotfile
done

# Enable fuzzy finder
#
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
