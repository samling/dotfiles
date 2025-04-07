function reload-zsh-configuration() {
  #cd $HOME && source .zshrc && cd - && echo ".zshrc reloaded"
  exec zsh && echo ".zshrc reloaded"

  # If we're in hyprland, update the instance signature to prevent
  # issues with stale signatures from restored tmux sessions
  if command -v -p hyprctl >/dev/null && command -v -p jq >/dev/null; then
    # echo "Updating HYPRLAND_INSTANCE_SIGNATURE"
    export HYPRLAND_INSTANCE_SIGNATURE=$(hyprctl instances -j | jq -r '.[0].instance')
  fi

}

# unlock bitwarden vault
function bw-unlock() {
  export BW_SESSION=$(bw unlock --raw --passwordfile=/home/$USERNAME/.bwpass)
}

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

nvim-maybe-profile() {
  if [ "$NVIM_PROFILE" == "true" ]; then
    echo "[DEBUG] Logging nvim startup profile to /tmp/nvim-profile.log"
    echo '[DEBUG] Run `unset NVIM_PROFILE` to disable'
    if [ -f /tmp/nvim-profile.log ]; then
      echo "[DEBUG] Previous log file found; removing it"
      rm -f /tmp/nvim-profile.log >/dev/null 2>&1
    fi

    nvim --startuptime /tmp/nvim-profile.log "$@"

    if [ $? -eq 0 ]; then
      echo "[DEBUG] Log file saved to /tmp/nvim-profile.log"
      if [ -f /tmp/nvim-profile.log ] && [ ! "$NVIM_PROFILE_SAVE_ON_EXIT" == "true" ]; then
        echo '[DEBUG] Set `NVIM_PROFILE_SAVE_ON_EXIT=true` to save the file instead'
        echo ""
        cat /tmp/nvim-profile.log
        echo ""
        echo '[DEBUG] Removing temporary log file'
        rm -f /tmp/nvim-profile.log >/dev/null 2>&1
      else
        echo '[DEBUG] Log file saved to /tmp/nvim-profile.log'
      fi
    fi
  else
    nvim "$@"
  fi
}
