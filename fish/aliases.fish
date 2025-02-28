# Builtin Replacements
alias cat "bat -pp"
alias df "duf -hide special,fuse"
alias grep "rg -u"
alias top "btop"
alias watch "viddy -d"
alias vi "nvim-maybe-profile"
alias vim "nvim-maybe-profile"

# ls aliases
alias ls "lsd"
alias l "ls -a"
alias ll "ls -lahg"
alias lll "ls -lahg --blocks permission,user,group,size,date,name"

# Kubernetes aliases
alias k "kubectl"
alias kubectx "FZF_DEFAULT_OPTS='--reverse' kubectl ctx"
alias kx "FZF_DEFAULT_OPTS='--reverse' kubectl ctx"
alias kubens "FZF_DEFAULT_OPTS='--reverse' kubectl-ns"
alias kn "FZF_DEFAULT_OPTS='--reverse' kubectl-ns"

# AI tools
alias ai "aichat"
alias gpt "aichat -m openai:gpt-4-0125-preview"
alias claude "aichat -m claude:claude-3-sonnet-20240229"

# Other aliases
alias lg "lazygit"
alias yless "jless --yaml"
#alias R "source ~/.config/fish/config.fish"
alias R "exec $SHELL -l" # this seems to mitigate issues with various invocations being stacked multiple times from sourcing the config again
alias tmux "direnv exec / tmux" 
