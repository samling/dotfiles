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
  RECENT_BRANCHES=$(for i in {1..10}; do echo -n "$i. "; git rev-parse --symbolic-full-name @{-$i} 2> /dev/null; done | fzf --tmux)
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
jwt-decode() {
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

function rgv () {
	rg --color=always --line-number --no-heading --smart-case "${*:-}" |
        fzf --ansi --height 80% --tmux 100%,80% \
            --color "hl:-1:underline,hl+:-1:underline:reverse" \
            --delimiter : \
            --preview 'bat --color=always {1} --highlight-line {2}' \
            --preview-window 'up,60%,border-bottom,+{2}+3/3,~3' \
            --bind 'enter:become(emacsclient -c -nw -a "vim" +{2} {1} || vim {1} +{2})'
}

function cleanssh() {
    pkill ssh-agent
    unset SSH_AGENT_PID
    unset SSH_AUTH_SOCK
    rm -f $SSH_AUTH_SOCK # ~/.ssh/ssh-agent.sock
    rm -f $HOME/.config/ssh-agent.pid
}

function startssh() {
  eval $(ssh-agent)
}

# watch kubernetes shorthand
function wk() {
  if [[ -x $(command -v viddy) ]]; then
    viddy -n 1 kubectl "$@"
  elif [[ -f /usr/bin/watch ]]; then
    /usr/bin/watch -n 1 kubectl "$@"
  fi
}

# watch previous command
wp() {
  local last_cmd

  # Get the previous command (the one before `wp`)
  last_cmd=$(history 2 | tail -n 1 | sed 's/^[[:space:]]*[0-9]\+[[:space:]]*//')

  if [[ -z $last_cmd ]]; then
    echo "No previous command found." >&2
    return 1
  fi

  # If the previous command starts with `k` (or is just `k`), swap to kubectl
  if [[ $last_cmd == "k" || $last_cmd == k\ * ]]; then
    last_cmd="kubectl ${last_cmd#k }"
  fi

  # Prefer viddy if available, fall back to watch
  if command -v viddy >/dev/null 2>&1; then
    echo "Watching last command: viddy -n 1 $last_cmd"
    viddy -n 1 "$last_cmd"
  elif command -v watch >/dev/null 2>&1; then
    echo "Watching last command: watch -n 1 $last_cmd"
    watch -n 1 "$last_cmd"
  else
    echo "Neither viddy nor watch found in PATH." >&2
    return 1
  fi
}

s_debug() {
  local config_file="$HOME/.ssh/config"
  local all_hosts=""
  
  echo "=== DEBUG: Checking main config file ==="
  echo "Config file: $config_file"
  
  # Function to extract hosts from a config file
  extract_hosts() {
    local file="$1"
    echo "  Checking file: $file"
    if [[ -r "$file" ]]; then
      local hosts=$("grep" -E '^Host ' "$file" 2>/dev/null | awk '{print $2}' | "grep" -v '\*')
      echo "  Found hosts: $hosts"
      echo "$hosts"
    else
      echo "  File not readable or doesn't exist"
    fi
  }
  
  # Get hosts from main config file
  echo "=== Getting hosts from main config ==="
  all_hosts=$(extract_hosts "$config_file")
  
  # Parse Include directives and get hosts from included files
  echo "=== Checking Include directives ==="
  while IFS= read -r include_line; do
    echo "Found include line: '$include_line'"
    
    # Remove "Include " from the beginning - using parameter expansion
    include_path="${include_line#Include }"
    echo "Extracted path: '$include_path'"
    
    # Expand the path properly using eval
    resolved_path=$(eval echo "$include_path")
    echo "Resolved path: '$resolved_path'"
    
    # Get hosts from included file
    included_hosts=$(extract_hosts "$resolved_path")
    if [[ -n "$included_hosts" ]]; then
      all_hosts="$all_hosts"$'\n'"$included_hosts"
    fi
  done < <("grep" -E '^Include ' "$config_file" 2>/dev/null)
  
  echo "=== Final host list ==="
  echo "$all_hosts" | sed '/^$/d' | sort -u
}

s() {
  local config_file="$HOME/.ssh/config"
  local temp_config=$(mktemp)
  
  # Function to extract hosts from a config file
  extract_hosts() {
    local file="$1"
    if [[ -r "$file" ]]; then
      "grep" -E '^Host ' "$file" 2>/dev/null | awk '{print $2}' | "grep" -v '\*'
    fi
  }
  
  # Function to append file contents to temp config
  append_config() {
    local file="$1"
    if [[ -r "$file" ]]; then
      cat "$file" >> "$temp_config"
      echo "" >> "$temp_config"  # Add blank line between files
    fi
  }
  
  # Start with main config file
  append_config "$config_file"
  local all_hosts=$(extract_hosts "$config_file")
  
  # Parse Include directives and append included files
  while IFS= read -r include_line; do
    # Remove "Include " from the beginning using parameter expansion
    include_path="${include_line#Include }"
    
    # Expand the path properly using eval for tilde expansion
    resolved_path=$(eval echo "$include_path")
    
    # Append the included file contents (but skip Include directives to avoid recursion)
    if [[ -r "$resolved_path" ]]; then
      "grep" -v '^Include ' "$resolved_path" >> "$temp_config"
      echo "" >> "$temp_config"
      
      # Get hosts from included file
      included_hosts=$(extract_hosts "$resolved_path")
      if [[ -n "$included_hosts" ]]; then
        all_hosts="$all_hosts"$'\n'"$included_hosts"
      fi
    fi
  done < <("grep" -E '^Include ' "$config_file" 2>/dev/null)
  
  # Remove empty lines, sort, deduplicate, and select with fzf
  local server
  server=$(echo "$all_hosts" | sed '/^$/d' | sort -u | fzf)
  
  if [[ -n "$server" ]]; then
    # Use the temporary combined config file
    ssh -F "$temp_config" "$server"
  fi
  
  # Clean up temporary file
  rm -f "$temp_config"
}

