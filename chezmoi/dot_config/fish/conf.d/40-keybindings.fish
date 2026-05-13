# Keybindings. fish runs this hook when entering the default key mode.
function fish_user_key_bindings
    # C-x C-e: edit current command in $EDITOR
    bind \cx\ce edit_command_buffer

    # Alt-Backspace: kill word
    bind \e\x7f backward-kill-word

    # C-s: command-snippets widget
    bind \cs cs-exec-widget

    # Free C-l, C-j for tmux; free C-p, C-n (we use UP/DOWN for history)
    bind --erase \cl 2>/dev/null
    bind --erase \cj 2>/dev/null
    bind --erase \cp 2>/dev/null
    bind --erase \cn 2>/dev/null
end
