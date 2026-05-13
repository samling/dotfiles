function __ctrl_c_preserve --description 'C-c: clear input in place if partial, new prompt if empty'
    if test -z (commandline)
        # empty line: print ^C, give a fresh prompt below
        commandline -f cancel-commandline
    else
        # partial input: clear the buffer in place, preserve the prompt line
        commandline ""
    end
end
