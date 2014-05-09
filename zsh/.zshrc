# Allows for addition of .zshrc.local for machine-specific things
if [[ -f ~/.zshrc.local ]]; then
    source ~/.zshrc.local
fi
unsetopt correct_all

# Path
#
source ~/dotfiles/zsh/path.zsh

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
