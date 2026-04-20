# Use emacs key bindings (default in Fish)
fish_default_key_bindings

# Remove Ctrl-l and Ctrl-j for tmux
bind --erase \cl
bind --erase \cj

# Bind up/down for history search
bind \e\[A history-search-backward
bind \e\[B history-search-forward

# Bind Ctrl+Left/Right for word navigation
bind \e\[1\;5C forward-word
bind \e\[1\;5D backward-word

# Bind Alt+Backspace to delete word
bind \e\[3\;3~ backward-kill-word

# Unbind Ctrl-p/Ctrl-n
bind --erase \cp
bind --erase \cn

# Reload fish config
function R
    source ~/.config/fish/config.fish
    echo "Fish config reloaded"
end
