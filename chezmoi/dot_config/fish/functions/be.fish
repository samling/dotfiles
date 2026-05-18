function be --description 'base64 encode the first argument'
    printf '%s' $argv[1] | base64
end
