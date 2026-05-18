# === Builtin replacements
alias cat="bat -pp"
alias df="duf -hide special,fuse"
alias diff="delta"
alias journalctl="SYSTEMD_LESS=FRXMK journalctl --no-pager"
alias top="btop -u 10"
alias watch="viddy -d"
alias vi=nvim
alias vim=nvim

# === cd dots: '..'='cd ../', '...'='cd ../../', up to 25
for i in (seq 2 25)
    set -l dots (string repeat -n $i .)
    set -l ups (string repeat -n (math $i - 1) '../')
    alias $dots "cd $ups"
end
alias .="cd ."

# === Defaults
alias ddi="sudo killall -INFO dd"
alias df="df -kH"
alias rm="rm -iv"
alias cp="cp -iv"
alias mv="mv -iv"

# === Extra tools
alias ai="aichat"
alias cm="chezmoi"
alias feh="feh -z --scale-down"
alias glaze="gpk"
alias jinaai='curl https://r.jina.ai -H "Authorization: Bearer $JINA_AI_API_KEY"'
alias lg="lazygit"
alias piper="pyenv local system && pyenv exec piper"
alias yless="jless --yaml"

# === Hyprland
alias hyprctl="hyprctl --instance 0"
alias hc="hyprctl --instance 0"
alias reload-waybar="systemctl --user restart waybar"
alias reload-ags="systemctl --user restart ags"
alias debug-waybar="env GTK_DEBUG=interactive waybar"

# === Kubectl
alias kubectl="kubecolor"
alias k="kubectl"
alias kubectx='FZF_DEFAULT_OPTS="$FZF_DEFAULT_OPTS --reverse" kubectl ctx'
alias kx='FZF_DEFAULT_OPTS="$FZF_DEFAULT_OPTS --reverse" kubectl ctx'
alias kubens='FZF_DEFAULT_OPTS="$FZF_DEFAULT_OPTS --reverse" kubectl-ns'
alias kn='FZF_DEFAULT_OPTS="$FZF_DEFAULT_OPTS --reverse" kubectl-ns'
alias kb='FZF_DEFAULT_OPTS="$FZF_DEFAULT_OPTS --reverse" kubie ctx'

# === ls
alias ls="lsd"
alias l="ls -a"
alias ll="ls -lahg"
alias lll="ls -lahg --blocks permission,user,group,size,date,name"

# === Shortcuts
alias b64="base64"
alias open="handlr open"
alias o="open"
alias v="clear -x"
alias R="reload-fish-configuration"
alias Ra="reload-fish-configuration all"
alias which="type -a"

# === Tmux
alias tmux="direnv exec / tmux"

# === Misc
alias nvault=vault
