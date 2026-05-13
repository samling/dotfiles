# Keybindings. fish runs this hook when entering the default key mode.
function fish_user_key_bindings
    # C-x C-e: edit current command in $EDITOR
    bind \cx\ce edit_command_buffer

    # Alt-Backspace: kill word
    bind \e\x7f backward-kill-word

    # C-s: command-snippets widget
    bind \cs cs-exec-widget

    # C-t: fzf file/directory search (replaces fish default `transpose-chars`).
    # fzf.fish ships _fzf_search_directory and binds it to Alt-C-F by default;
    # we override Ctrl-T here to match zsh muscle memory.
    if functions -q _fzf_search_directory
        bind \ct _fzf_search_directory
    end

    # Free C-l, C-j for tmux; free C-p, C-n (we use UP/DOWN for history)
    bind --erase \cl 2>/dev/null
    bind --erase \cj 2>/dev/null
    bind --erase \cp 2>/dev/null
    bind --erase \cn 2>/dev/null
end
