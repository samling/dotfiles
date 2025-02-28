# Builtin Replacements
function cat
    bat -pp $argv
end

function df
    duf -hide special,fuse $argv
end

function grep
    rg -u $argv
end

function top
    btop $argv
end

function watch
    viddy -d $argv
end

function vi
    nvim-maybe-profile $argv
end

function vim
    nvim-maybe-profile $argv
end

# ls functions
function ls
    lsd $argv
end

function l
    ls -a $argv
end

function ll
    ls -lahg $argv
end

function lll
    ls -lahg --blocks permission,user,group,size,date,name $argv
end

# Kubernetes functions
function k
    kubectl $argv
end

function kubectx
    env FZF_DEFAULT_OPTS='--reverse' kubectl ctx $argv
end

function kx
    env FZF_DEFAULT_OPTS='--reverse' kubectl ctx $argv
end

function kubens
    env FZF_DEFAULT_OPTS='--reverse' kubectl-ns $argv
end

function kn
    env FZF_DEFAULT_OPTS='--reverse' kubectl-ns $argv
end

# AI tools
function ai
    aichat $argv
end

# Other functions
function lg
    lazygit $argv
end

function yless
    jless --yaml $argv
end

function R
    # reload fish without re-sourcing everything
    exec $SHELL -l
end

function tmux
    direnv exec / tmux $argv
end
