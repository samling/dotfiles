# show status of subdirectories that are git repositories
function git-status {
    "find" . -type d -name '.git' | while read dir ; do sh -c "cd $dir/../ && git status -s | grep -q [azAZ09] && echo '\n\033[1m [ ${dir//\.git/} ]\n\033[m' && git status -s" ; done
}

# show recent git branches in fzf and check out selection
function git-recent {
  RECENT_BRANCHES=$(for i in {1..10}; do echo -n "$i. "; git rev-parse --symbolic-full-name @{-$i} 2> /dev/null; done | fzf)
  PREV_BRANCH=$(echo $RECENT_BRANCHES | cut -d'.' -f2 | sed 's/refs\/heads\///g' | tr -d ' ')
  git checkout $PREV_BRANCH
}

# unset AWS vars
function unset-aws() {
  echo "Unsetting AWS_* variables"
  env | "grep" -e '^AWS' | cut -f1 -d'='| while read var; do echo -e "Unsetting ${var}" && unset $var; done
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

# decode JWTs
jwtdecode() {
  if [[ -x $(command -v jq) ]]; then
    jq -R 'split(".") | .[0],.[1] | @base64d | fromjson' <<< "${1}"
    echo "Signature: $(echo "${1}" | awk -F'.' '{print $3}')"
  fi
}

