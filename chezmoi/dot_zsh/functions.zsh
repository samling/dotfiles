function reload-zsh-configuration() {
  local scope="${1:-here}" # "here" (default) or "all"

  if [ -n "$TMUX" ] && [ "$scope" = "all" ]; then
    local current_pane count=0
    current_pane=$(tmux display-message -p '#{session_name}:#{window_index}.#{pane_index}')
    tmux list-panes -a -F '#{pane_current_command} #{session_name}:#{window_index}.#{pane_index}' \
      | awk '/^zsh /{print $2}' \
      | while read pane; do
          [ "$pane" = "$current_pane" ] && continue
          tmux send-keys -t "$pane" C-c
          tmux send-keys -t "$pane" 'exec zsh' Enter
          count=$((count + 1))
        done
    echo "Reloading zsh in $count other pane(s)..."
  fi

  echo "Reloading current shell..."
  exec zsh
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
  RECENT_BRANCHES=$(for i in {1..10}; do echo -n "$i. "; git rev-parse --symbolic-full-name @{-$i} 2> /dev/null; done | fzf --popup)
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

function bd() {
  printf '%s' "$1" | base64 -d
}

function be() {
  printf '%s' "$1" | base64
}

function reset_terminal_colors() {
  # - \033]104\033\\ — reset all 256 palette colors to terminal defaults
  # - \033]110\033\\ — reset foreground color
  # - \033]111\033\\ — reset background color
  # - \033]112\033\\ — reset cursor color
  #
  # \033] starts the command, \033\\ ends it (String Terminator).

  printf '\033]104\033\\\033]110\033\\\033]111\033\\\033]112\033\\'
}

# ============================================================================
# fzf.fish-style search widgets (port of https://github.com/PatrickF1/fzf.fish)
# Bindings live in keys.zsh; preview helpers in ~/.zsh/scripts/fzf_preview_*.sh.
#
# Per-widget option overrides honored just like fzf.fish:
#   $fzf_directory_opts $fzf_git_log_opts $fzf_git_status_opts
#   $fzf_git_branch_opts $fzf_processes_opts $fzf_history_opts $fzf_fd_opts
#   $fzf_git_log_format $fzf_git_branch_format $fzf_history_time_format
#   $fzf_diff_highlighter $fzf_preview_file_cmd $fzf_preview_dir_cmd
# ============================================================================

# Whitespace tokenization. Sets reply=(token prefix suffix).
__fzf_fish_current_token() {
  local lbuf="$LBUFFER" rbuf="$RBUFFER" left right
  left="${lbuf##*[[:space:]]}"
  right="${rbuf%%[[:space:]]*}"
  reply=("${left}${right}" "${lbuf%"$left"}" "${rbuf#"$right"}")
}

__fzf_fish_replace_token() {
  local replacement="$1"
  local -a reply
  __fzf_fish_current_token
  LBUFFER="${reply[2]}${replacement}"
  RBUFFER="${reply[3]}"
}

# Shell-quote each element only if needed, then join with spaces.
__fzf_fish_join_quoted() {
  local -a out
  local p
  for p in "$@"; do out+=("${(q-)p}"); done
  print -r -- "${(j: :)out}"
}

# Search Directory: fd + bat preview; token-aware (dir/<cursor> searches inside).
__fzf_search_directory() {
  emulate -L zsh
  setopt local_options no_nomatch
  local fd_cmd
  fd_cmd=$(command -v fdfind || command -v fd || print -r -- fd)

  local -a reply
  __fzf_fish_current_token
  local token="${reply[1]}"
  # Tilde-expand only (no eval) to avoid running arbitrary buffer text.
  local expanded_token="${~token}"

  local -a fd_args fzf_args
  fd_args=(--color=always)
  [[ -n "${fzf_fd_opts:-}" ]] && fd_args+=(${=fzf_fd_opts})
  fzf_args=(--multi --ansi --layout=reverse)

  local result
  if [[ "$expanded_token" == */ && -d "$expanded_token" ]]; then
    fd_args+=(--base-directory="$expanded_token")
    fzf_args+=(--prompt="Directory ${expanded_token}> "
               --preview="${HOME}/.zsh/scripts/fzf_preview_file.sh ${(q)expanded_token}{}")
    [[ -n "${fzf_directory_opts:-}" ]] && fzf_args+=(${=fzf_directory_opts})
    result=$("$fd_cmd" "${fd_args[@]}" 2>/dev/null | SHELL=/bin/bash fzf "${fzf_args[@]}")
    if [[ $? -eq 0 && -n "$result" ]]; then
      local -a paths prefixed
      paths=("${(@f)result}")
      local p
      for p in "${paths[@]}"; do
        [[ -n "$p" ]] && prefixed+=("${expanded_token}${p}")
      done
      __fzf_fish_replace_token "$(__fzf_fish_join_quoted "${prefixed[@]}")"
    fi
  else
    fzf_args+=(--prompt='Directory> '
               --query="$expanded_token"
               --preview="${HOME}/.zsh/scripts/fzf_preview_file.sh {}")
    [[ -n "${fzf_directory_opts:-}" ]] && fzf_args+=(${=fzf_directory_opts})
    result=$("$fd_cmd" "${fd_args[@]}" 2>/dev/null | SHELL=/bin/bash fzf "${fzf_args[@]}")
    if [[ $? -eq 0 && -n "$result" ]]; then
      local -a paths kept
      paths=("${(@f)result}")
      local p
      for p in "${paths[@]}"; do
        [[ -n "$p" ]] && kept+=("$p")
      done
      __fzf_fish_replace_token "$(__fzf_fish_join_quoted "${kept[@]}")"
    fi
  fi
  zle reset-prompt
}
zle -N __fzf_search_directory

# Search Git Log: insert selected commit hash(es).
__fzf_search_git_log() {
  emulate -L zsh
  if ! git rev-parse --git-dir >/dev/null 2>&1; then
    zle -M '_fzf_search_git_log: Not in a git repository.'
    return
  fi
  local fmt="${fzf_git_log_format:-%C(bold blue)%h%C(reset) - %C(cyan)%ad%C(reset) %C(yellow)%d%C(reset) %C(normal)%s%C(reset)  %C(dim normal)[%an]%C(reset)}"
  local preview_cmd='git show --color=always --stat --patch {1}'
  [[ -n "${fzf_diff_highlighter:-}" ]] && preview_cmd="$preview_cmd | $fzf_diff_highlighter"

  local -a reply
  __fzf_fish_current_token
  local query="${reply[1]}"

  local -a fzf_args
  fzf_args=(--ansi --multi --scheme=history
            --prompt='Git Log> '
            --preview="$preview_cmd"
            --query="$query")
  [[ -n "${fzf_git_log_opts:-}" ]] && fzf_args+=(${=fzf_git_log_opts})

  local selected
  selected=$(git log --no-show-signature --color=always --format=format:"$fmt" --date=short \
             | SHELL=/bin/bash fzf "${fzf_args[@]}") || { zle reset-prompt; return }

  local -a hashes
  local line abbrev full
  while IFS= read -r line; do
    [[ -z "$line" ]] && continue
    abbrev="${line%% *}"
    full=$(git rev-parse "$abbrev" 2>/dev/null) || continue
    hashes+=("$full")
  done <<< "$selected"

  (( ${#hashes} )) && __fzf_fish_replace_token "${(j: :)hashes}"
  zle reset-prompt
}
zle -N __fzf_search_git_log

# Search Git Branches: insert selected branch name(s). Local + remote, sorted
# by most-recent commit. Symbolic refs (origin/HEAD) are dropped via the
# %(if)%(symref) conditional, so they don't appear in the picker.
__fzf_search_git_branches() {
  emulate -L zsh
  if ! git rev-parse --git-dir >/dev/null 2>&1; then
    zle -M '_fzf_search_git_branches: Not in a git repository.'
    return
  fi
  local fmt="${fzf_git_branch_format:-%(color:bold blue)%(refname:short)%(color:reset) %(color:cyan)%(committerdate:relative)%(color:reset) %(color:yellow)%(upstream:track)%(color:reset) %(subject)  %(color:dim normal)[%(authorname)]%(color:reset)}"
  local preview_cmd='git log --color=always --oneline --graph --decorate -20 {1}'

  local -a reply
  __fzf_fish_current_token
  local query="${reply[1]}"

  local -a fzf_args
  fzf_args=(--ansi --multi
            --prompt='Git Branches> '
            --preview="$preview_cmd"
            --query="$query")
  [[ -n "${fzf_git_branch_opts:-}" ]] && fzf_args+=(${=fzf_git_branch_opts})

  local selected
  selected=$(git for-each-ref --color=always \
               --sort=-committerdate \
               --format="%(if)%(symref)%(then)%(else)${fmt}%(end)" \
               refs/heads refs/remotes \
             | awk 'NF' \
             | SHELL=/bin/bash fzf "${fzf_args[@]}") || { zle reset-prompt; return }

  local -a branches
  local line name
  while IFS= read -r line; do
    [[ -z "$line" ]] && continue
    name="${line%% *}"
    [[ -n "$name" ]] && branches+=("$name")
  done <<< "$selected"

  (( ${#branches} )) && __fzf_fish_replace_token "$(__fzf_fish_join_quoted "${branches[@]}")"
  zle reset-prompt
}
zle -N __fzf_search_git_branches

# Tab dispatcher: when the current command is a git subcommand whose first
# positional arg is a branch/ref, invoke __fzf_search_git_branches so the
# picker matches Alt-Ctrl-B. Otherwise fall through to fzf-tab's completion.
# Skips interception once a `--` boundary appears (user wants file completion).
__fzf_tab_dispatch() {
  emulate -L zsh
  if [[ "$LBUFFER" =~ '(^|[;&|]|&&|\|\|)[[:space:]]*git[[:space:]]+(checkout|switch|rebase|merge|cherry-pick)[[:space:]]+([^|;&]*)$' ]]; then
    local tail="${match[3]}"
    if [[ "$tail" != *' -- '* && "$tail" != '-- '* && "$tail" != '--' ]]; then
      __fzf_search_git_branches
      return
    fi
  fi
  zle fzf-tab-complete
}
zle -N __fzf_tab_dispatch

# Search Git Status: insert selected path(s); handles "R old -> new" renames.
__fzf_search_git_status() {
  emulate -L zsh
  if ! git rev-parse --git-dir >/dev/null 2>&1; then
    zle -M '_fzf_search_git_status: Not in a git repository.'
    return
  fi

  local -a reply
  __fzf_fish_current_token
  local query="${reply[1]}"

  local -a fzf_args
  fzf_args=(--ansi --multi
            --prompt='Git Status> '
            --query="$query"
            --preview="${HOME}/.zsh/scripts/fzf_preview_changed_file.sh {}"
            --nth='2..')
  [[ -n "${fzf_git_status_opts:-}" ]] && fzf_args+=(${=fzf_git_status_opts})

  local selected
  selected=$(git -c color.status=always status --short \
             | fzf_diff_highlighter="${fzf_diff_highlighter:-}" SHELL=/bin/bash \
               fzf "${fzf_args[@]}") || { zle reset-prompt; return }

  local -a paths
  local line
  while IFS= read -r line; do
    [[ -z "$line" ]] && continue
    if [[ "${line:0:1}" == 'R' ]]; then
      paths+=("${line##* -> }")
    else
      paths+=("${line:3}")
    fi
  done <<< "$selected"

  (( ${#paths} )) && __fzf_fish_replace_token "$(__fzf_fish_join_quoted "${paths[@]}")"
  zle reset-prompt
}
zle -N __fzf_search_git_status

# Search Processes: insert selected pid(s).
__fzf_search_processes() {
  emulate -L zsh
  local ps_cmd
  ps_cmd=$(command -v ps || print -r -- ps)
  local ps_preview_fmt='pid,ppid=PARENT,user,%cpu,rss=RSS_IN_KB,start=START_TIME,command'

  local -a reply
  __fzf_fish_current_token
  local query="${reply[1]}"

  local -a fzf_args
  fzf_args=(--multi --ansi
            --prompt='Processes> '
            --query="$query"
            --header-lines=1
            --preview="$ps_cmd -o '$ps_preview_fmt' -p {1} || echo 'Cannot preview {1} because it exited.'"
            --preview-window='bottom:4:wrap')
  [[ -n "${fzf_processes_opts:-}" ]] && fzf_args+=(${=fzf_processes_opts})

  local selected
  selected=$("$ps_cmd" -A -opid,command \
             | SHELL=/bin/bash fzf "${fzf_args[@]}") || { zle reset-prompt; return }

  local -a pids
  local line pid
  while IFS= read -r line; do
    pid="${line## }"
    pid="${pid%% *}"
    [[ -n "$pid" ]] && pids+=("$pid")
  done <<< "$selected"

  (( ${#pids} )) && __fzf_fish_replace_token "${(j: :)pids}"
  zle reset-prompt
}
zle -N __fzf_search_processes

# Search History: timestamped picker; replaces the whole buffer.
# Multi-line commands are joined with " ↵ " for fzf display and restored on selection.
__fzf_search_history() {
  emulate -L zsh
  local fmt="${fzf_history_time_format:-%m-%d %H:%M:%S}"
  local query="${LBUFFER}${RBUFFER}"

  local selected
  selected=$(
    fc -rl -t "$fmt" 1 2>/dev/null |
      awk '
        /^[[:space:]]*[0-9]+\*?[[:space:]]/ {
          if (buf != "") print buf
          sub(/^[[:space:]]*[0-9]+\*?[[:space:]]+/, "")
          if (match($0, /  +/)) {
            ts = substr($0, 1, RSTART - 1)
            cmd = substr($0, RSTART + RLENGTH)
            buf = ts " │ " cmd
          } else {
            buf = $0
          }
          next
        }
        { buf = buf " ↵ " $0 }
        END { if (buf != "") print buf }
      ' |
      SHELL=/bin/bash fzf \
        --no-multi \
        --scheme=history \
        --prompt='History> ' \
        --query="$query" \
        --preview='printf "%s\n" {} | sed -e "s/^[^│]*│ //" -e "s/ ↵ /\n/g" | bat --color=always -pl bash --paging=never' \
        --preview-window='bottom:3:wrap' \
        ${=fzf_history_opts:-}
  ) || { zle reset-prompt; return }

  local cmd="${selected#*│ }"
  cmd="${cmd// ↵ /$'\n'}"
  LBUFFER="$cmd"
  RBUFFER=""
  zle reset-prompt
}
zle -N __fzf_search_history

# https://junegunn.github.io/fzf/tips/ripgrep-integration/
function fzg() ( # fuzzygrep
  RELOAD='reload:rg --column --color=always --smart-case {q} || :'
  OPENER='if [[ $FZF_SELECT_COUNT -eq 0 ]]; then
            vim {1} +{2}     # No selection. Open the current line in Vim.
          else
            vim +cw -q {+f}  # Build quickfix list for the selected items.
          fi'
  fzf --disabled --ansi --multi \
      --bind "start:$RELOAD" --bind "change:$RELOAD" \
      --bind "enter:become:$OPENER" \
      --bind "ctrl-o:execute:$OPENER" \
      --bind 'alt-a:select-all,alt-d:deselect-all,ctrl-/:toggle-preview' \
      --delimiter : \
      --preview 'bat --style=full --color=always --highlight-line {2} {1}' \
      --preview-window '~4,+{2}+4/3,<80(up)' \
      --query "$*"
)
