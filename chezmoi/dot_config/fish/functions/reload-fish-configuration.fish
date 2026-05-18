function reload-fish-configuration --description 'exec fish; with `all`, also reload other tmux panes running fish'
    set -l scope here
    test (count $argv) -gt 0; and set scope $argv[1]

    if set -q TMUX; and test "$scope" = "all"
        set -l current_pane (tmux display-message -p '#{session_name}:#{window_index}.#{pane_index}')
        set -l count 0
        for line in (tmux list-panes -a -F '#{pane_current_command} #{session_name}:#{window_index}.#{pane_index}')
            set -l parts (string split ' ' -- $line)
            if test "$parts[1]" = "fish"; and test "$parts[2]" != "$current_pane"
                tmux send-keys -t "$parts[2]" C-c
                tmux send-keys -t "$parts[2]" 'exec fish' Enter
                set count (math $count + 1)
            end
        end
        echo "Reloading fish in $count other pane(s)..."
    end

    echo "Reloading current shell..."
    exec fish
end
