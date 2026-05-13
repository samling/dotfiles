function __ctrl_c_preserve --description 'cancel: stash partial cmd in kill-ring, recover with C-y'
    set -l buf (commandline)
    if test -z "$buf"
        # empty line: fall through to default cancel (prints ^C, new prompt)
        commandline -f cancel-commandline
        return
    end

    # Move cursor to start of buffer, then kill to end-of-line.
    # kill-line stores the killed text in the kill-ring (yank with C-y).
    commandline -C 0
    commandline -f kill-line
    commandline -f cancel-commandline
end
