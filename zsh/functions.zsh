function git-status {
    "find" . -type d -name '.git' | while read dir ; do sh -c "cd $dir/../ && git status -s | grep -q [azAZ09] && echo '\n\033[1m [ ${dir//\.git/} ]\n\033[m' && git status -s" ; done
}

function git-recent {
  RECENT_BRANCHES=$(for i in {1..10}; do echo -n "$i. "; git rev-parse --symbolic-full-name @{-$i} 2> /dev/null; done | fzf)
  PREV_BRANCH=$(echo $RECENT_BRANCHES | cut -d'.' -f2 | sed 's/refs\/heads\///g' | tr -d ' ')
  git checkout $PREV_BRANCH
}

# man pages + fzf
# dependencies: fzf, awk, bat, tr
fman() {
        man -k . |
        fzf --exact -q "$1" --prompt='man> '  --preview $'echo {} |
        tr -d \'()\' |
        awk \'{printf "%s ", $2} {print $1}\' |
        xargs -r man |
        col -bx |
        bat -l man -p --color always'|
        tr -d '()' | awk '{printf "%s ", $2} {print $1}' |
        xargs -r man
}
