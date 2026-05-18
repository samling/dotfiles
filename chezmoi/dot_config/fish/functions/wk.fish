function wk --description 'watch kubectl: viddy or watch'
    if command -q viddy
        viddy -n 1 kubectl $argv
    else if test -x /usr/bin/watch
        /usr/bin/watch -n 1 kubectl $argv
    else
        echo "neither viddy nor watch found" >&2
        return 1
    end
end
