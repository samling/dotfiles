# Completions setup
# Note: Fish handles most completions automatically

# Colima completion
if type -q colima
    colima completion fish | source
end

# Direnv hook
if type -q direnv
    direnv hook fish | source
end

# Flux completion
if type -q flux
    flux completion fish | source
end

# Kubectl completion
if type -q kubectl
    kubectl completion fish | source
end

# Pyenv initialization
if type -q pyenv
    pyenv init - fish | source
    # Note: virtualenv-init is handled differently in Fish
    # Use virtualfish instead if you need virtualenv features
end

# Zoxide (better cd)
if type -q zoxide
    zoxide init fish | source
end 