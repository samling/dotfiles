function startssh --description 'start ssh-agent and export its env vars (fish-native)'
    # ssh-agent -s emits Bourne-shell `VAR=val; export VAR;` lines + a trailing `echo`.
    # Strip the echo, convert export lines to fish `set -gx`.
    ssh-agent -s \
        | string match -v 'echo*' \
        | string replace -rf '^([A-Z_]+)=([^;]+);.*' 'set -gx $1 $2' \
        | source
end
