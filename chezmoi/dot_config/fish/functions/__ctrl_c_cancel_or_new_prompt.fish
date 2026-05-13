function __ctrl_c_cancel_or_new_prompt --description 'C-c: cancel input, or create a fresh prompt if empty'
    if test -z (commandline)
        commandline -f execute
    else
        commandline -f cancel-commandline
    end
end
