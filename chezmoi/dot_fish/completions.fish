# Completions setup
# Note: Fish handles most completions automatically

# Colima completion
if type -q colima
    colima completion fish | source
end

# Flux completion
if type -q flux
    flux completion fish | source
end

# Kubectl completion
if type -q kubectl
    kubectl completion fish | source
end

# Zoxide (better cd)
#if type -q zoxide
#    zoxide init fish | source
#end 
