function __ctrl_c_preserve --description 'cancel commandline but stash partial to the kill-ring (yankable with C-y)'
    set -l buf (commandline)
    if test -n "$buf"
        # kill-whole-line drops current input into the kill-ring,
        # then cancel-commandline prints the `^C` marker and gives a new prompt.
        commandline -f kill-whole-line
    end
    commandline -f cancel-commandline
end
