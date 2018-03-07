function body_alias() {
    sed -n "$1","$2"p "$3"        
}

function git-status-all {
    find . -type d -name '.git' | while read dir ; do sh -c "cd $dir/../ && git status -s | grep -q [azAZ09] && echo '\n\033[1m [ ${dir//\.git/} ]\n\033[m' && git status -s" ; done
}
