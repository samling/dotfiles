# Allows for addition of .zshrc.local for machine-specific things
if [[ -f ~/.zshrc.local ]]; then
    source ~/.zshrc.local
fi
unsetopt correct_all

# Path
#
<<<<<<< HEAD
source ~/dotfiles/zsh/path.zsh
=======
# Using Homebrew without Linux CoreUtils
PATH=/usr/bin:/bin:/usr/sbin:/sbin:/usr/local/bin:/usr/local/sbin
export PATH=$PATH:/usr/local/rvm/bin:/opt/local/bin:/opt/local/sbin:/Users/sboynton/.local.bin:/opt/X11/bin:/usr/local/munki:/Users/sboynton/android/SDK/tools:/Users/sboynton/android/SDK/platform-tools:/Users/sboynton/android/Utilities/dex2jar:$HOME/.rbenv/bin:$HOME/.rbenv/shims
# eval "$(rbenv init -)"
#
# Using Homebrew + Linux CoreUtils
#export PATH=/usr/local/opt/coreutils/libexec/gnubin:/opt/local/bin:/opt/local/sbin:/usr/local/bin:/usr/local/sbin:/bin:/usr/sbin:/sbin:/usr/bin:/opt/X11/bin:/usr/local/munki:/opt/local/bin:/opt/local/sbin
>>>>>>> b2ebf2fd8a5e22bff951304448389ab4efd5efd6

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
