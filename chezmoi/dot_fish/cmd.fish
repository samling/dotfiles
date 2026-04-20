# Direnv hook
if type -q direnv
    direnv hook fish | source
end

#=== FZF
fzf --fish | source
#set -g direnv_fish_mode disable_arrow

# Pyenv initialization
if type -q pyenv
    pyenv init - fish | source
    # Note: virtualenv-init is handled differently in Fish
    # Use virtualfish instead if you need virtualenv features
end

#=== Zoxide
zoxide init --cmd cd fish | source
