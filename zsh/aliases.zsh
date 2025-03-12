#=== Builtin Replacements
alias cat="bat -pp"
alias df="duf -hide special,fuse"
# alias find="fd" # use find and fd separately
alias grep="rg -u"
alias top="btop"
alias watch="viddy -d"
alias vi=nvim-maybe-profile
alias vim=nvim-maybe-profile

#=== cd
# Create aliases for up to 15 directories (offset by 1: '..'='cd ../', '...'='cd ../../', etc.)
for i in {2..25}; do
  alias "$(printf '%0.s.' $(seq 1 $i))"="cd $(printf '../%.0s' $(seq 1 $((i-1))))"
done
alias .="cd ." # Don't go anywhere with one dot

#=== Defaults
alias ddi="sudo killall -INFO dd" # Shows progress of dd in the window that dd is running in
alias df="df -kH" # Clean disk info
alias rm='rm -iv' # Prevent clobbering
alias cp='cp -iv' # Prevent clobbering
alias mv='mv -iv' # Prevent clobbering

#=== Extra tools
alias ai="aichat"
alias feh="feh -z --scale-down"
alias gpt-"aichat -m openai:gpt-4o-2024-11-20"
alias claude="aichat -m claude:claude-3-5-sonnet-latest"
alias jinaai="curl https://r.jina.ai -H \"Authorization: Bearer ${JINA_AI_API_KEY}\""
alias lg="lazygit"
alias piper="pyenv local system && pyenv exec piper"
alias yless="jless --yaml"

#=== Hyprland
alias hyprctl="hyprctl --instance 0" # avoids tmux-inside-hyprland issues
alias reload-waybar="pkill waybar && hyprctl dispatch exec waybar"

#=== Kubectl
alias k="kubectl"
alias kubectx="FZF_DEFAULT_OPTS='--reverse' kubectl ctx"
alias kx="FZF_DEFAULT_OPTS='--reverse' kubectl ctx"
alias kubens="FZF_DEFAULT_OPTS='--reverse' kubectl-ns"
alias kn="FZF_DEFAULT_OPTS='--reverse' kubectl-ns"

#=== ls
alias ls="lsd"
alias l="ls -a"
alias ll="ls -lahg"
alias lll="ls -lahg --blocks permission,user,group,size,date,name"

#=== Shortcuts
alias b64='base64'
alias o="open"
alias v="clear" # clear terminal
alias R='cd $HOME && source .zshrc && cd - && echo ".zshrc reloaded"' # reload zsh
alias which='type -a'

#=== Tmux
alias tmux="direnv exec / tmux"

#=== Zellij
alias zellij="bash ~/dotfiles/zellij/scripts/new-zellij-session.sh"
