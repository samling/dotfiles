function bd --description 'base64 decode the first argument'
    printf '%s' $argv[1] | base64 -d
end
