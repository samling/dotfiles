function wp --description 'watch the previous command'
    set -l last (history --max=1)
    if test -z "$last"
        echo "no previous command" >&2
        return 1
    end

    # Substitute leading `k ` (or bare `k`) with `kubectl `
    if string match -qr '^k( |$)' -- $last
        set last (string replace -r '^k( |$)' 'kubectl$1' -- $last)
    end

    if command -q viddy
        echo "Watching last command: viddy -n 1 $last"
        viddy -n 1 $last
    else if command -q watch
        echo "Watching last command: watch -n 1 $last"
        watch -n 1 $last
    else
        echo "neither viddy nor watch in PATH" >&2
        return 1
    end
end
