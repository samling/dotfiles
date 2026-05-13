function cs-exec-widget --description 'insert output of `cs exec` at the cursor'
    set -l cmd (cs exec)
    if test $status -eq 0; and test -n "$cmd"
        commandline -i -- $cmd
    end
    commandline -f repaint
end
