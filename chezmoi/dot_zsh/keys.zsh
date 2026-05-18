# Enable emacs mode (default)
bindkey -e

# Remove ctrl-l and ctrl-j to make way for tmux
bindkey -r '^l'
bindkey -r '^j'

# Bind UP and DOWN arrow keys (both CSI and SS3 escape sequences)
bindkey "^[[A" history-substring-search-up
bindkey "^[[B" history-substring-search-down
bindkey "^[OA" history-substring-search-up
bindkey "^[OB" history-substring-search-down

bindkey "^[[1;5C" forward-word
bindkey "^[[1;5D" backward-word

# Bind option-backspace to delete word
bindkey '^[^?' backward-kill-word

# Unbind ctrl-p/ctrl-n
bindkey -r "^p"
bindkey -r "^n"

# unbind ctrl-l (clear screen)
bindkey -r "^[^L"

#========= C-x C-e to edit the current command in $EDITOR

autoload -U edit-command-line
zle -N edit-command-line

__ctrl_x_clear_prefix_prompt() {
    if (( ${+__ctrl_x_saved_rprompt} )); then
        RPROMPT="$__ctrl_x_saved_rprompt"
        unset __ctrl_x_saved_rprompt
        zle reset-prompt
    fi
}

__ctrl_x_prefix() {
    (( ${+__ctrl_x_saved_rprompt} )) || __ctrl_x_saved_rprompt="${RPROMPT-}"
    if [[ -n "$__ctrl_x_saved_rprompt" ]]; then
        RPROMPT="%F{yellow}[C-x]%f ${__ctrl_x_saved_rprompt}"
    else
        RPROMPT="%F{yellow}[C-x]%f"
    fi
    zle reset-prompt
    local key
    read -k 1 key
    __ctrl_x_clear_prefix_prompt
    if [[ "$key" == e || "$key" == $'\x05' ]]; then
        zle edit-command-line
    elif [[ "$key" == $'\r' || "$key" == $'\n' ]]; then
        zle accept-line
    elif [[ "$key" == $'\e' ]]; then
        return 0
    else
        zle -U "$key"
    fi
}
zle -N __ctrl_x_prefix

bindkey '^X' __ctrl_x_prefix

#========= C-s to bring up the cs menu
# Disable terminal flow control (Ctrl+S/Ctrl+Q)
# This allows Ctrl+S to be used as a keybinding
stty -ixon 2>/dev/null

# Command snippets widget - runs cs exec and captures stdout
cs-exec-widget() {
    # Run cs exec and capture stdout (TUI displays on stderr)
    local cmd=$(cs exec)
    
    # Check if we got a command (not cancelled)
    if [[ $? -eq 0 && -n "$cmd" ]]; then
        # Insert at current position
        LBUFFER="${LBUFFER}${cmd}"
    fi
    
    # Redraw
    zle redisplay
}

# Register the widget
zle -N cs-exec-widget

# Bind Ctrl+S to the widget
bindkey '^S' cs-exec-widget

#========= fzf.fish-style search widgets (defined in functions.zsh)
# These override the stock Ctrl-T / Ctrl-R bindings that `fzf --zsh` installs
# in completions.zsh, which is why keys.zsh is sourced after completions.zsh.
bindkey '^T'   fzf-search-directory    # files under cwd (token-aware)
bindkey '^R'   fzf-search-history      # timestamped history
bindkey '^[^L' fzf-search-git-log      # Alt-Ctrl-L: commit hashes
bindkey '^[^B' fzf-search-git-branches # Alt-Ctrl-B: branch names
bindkey '^[^S' fzf-search-git-status   # Alt-Ctrl-S: changed paths
bindkey '^[^P' fzf-search-processes    # Alt-Ctrl-P: pids

# Tab: route `git (checkout|switch|rebase|merge|cherry-pick) <branch>` through
# the same picker as Alt-Ctrl-B; everything else falls through to fzf-tab.
bindkey '^I' fzf-tab-dispatch
