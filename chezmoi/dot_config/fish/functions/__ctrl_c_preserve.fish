function __ctrl_c_preserve --description 'cancel: prepend partial cmd to fish_killring; recover with C-y'
    set -l buf (commandline)
    if test -n "$buf"
        # Push to the head of the kill-ring; yank (C-y) pulls it back.
        set -p fish_killring $buf
    end
    commandline -f cancel-commandline
end
