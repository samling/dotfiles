# Plugins
#
source ~/dotfiles/zsh/zsh-history-substring-search.zsh

# Path
#
source ~/dotfiles/zsh/path.zsh

# Setopt
#
source ~/dotfiles/zsh/opt.zsh

# Prompt theme
#
source ~/dotfiles/zsh/theme.zsh

# Environment
#
source ~/dotfiles/zsh/env.zsh

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
source ~/dotfiles/zsh/custom.zsh

# Custom functions
#
source ~/dotfiles/zsh/functions.zsh

# Allows for addition of .zshrc.local for machine-specific things
if [[ -f $HOME/.zshrc.local ]]; then
    source $HOME/.zshrc.local
fi

