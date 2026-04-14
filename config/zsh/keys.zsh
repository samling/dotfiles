# Enable emacs mode (default)
bindkey -e

# Remove ctrl-l and ctrl-j to make way for tmux
bindkey -r '^l'
bindkey -r '^j'

# Bind UP and DOWN arrow keys
bindkey "^[[A" history-substring-search-up
bindkey "^[[B" history-substring-search-down

bindkey "^[[1;5C" forward-word
bindkey "^[[1;5D" backward-word

# Bind option-backspace to delete word
bindkey '^[^?' backward-kill-word

# Unbind ctrl-p/ctrl-n
bindkey -r "^p"
bindkey -r "^n"

#========= C-x C-e to edit the current command in $EDITOR

autoload -U edit-command-line
zle -N edit-command-line
bindkey '^xe' edit-command-line
bindkey '^x^e' edit-command-line

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
