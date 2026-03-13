#!/bin/sh
# Claude Code statusLine command
# Inspired by ~/.zsh/prompt.zsh

input=$(cat)
cwd=$(echo "$input" | jq -r '.cwd')

# Abbreviate home directory with ~
home="$HOME"
short_cwd=$(echo "$cwd" | sed "s|^$home|~|")

# Shorten to last 4 path components (matching %(5~|%-1~/…/%3~|%4~) logic)
component_count=$(echo "$short_cwd" | tr -cd '/' | wc -c)
if [ "$component_count" -gt 4 ]; then
  first=$(echo "$short_cwd" | cut -d'/' -f1-2)
  last3=$(echo "$short_cwd" | rev | cut -d'/' -f1-3 | rev)
  short_cwd="$first/.../$last3"
fi

# Git info
git_branch=$(git -C "$cwd" symbolic-ref -q --short HEAD 2>/dev/null \
  || git -C "$cwd" name-rev --name-only --no-undefined --always HEAD 2>/dev/null)

git_part=""
if [ -n "$git_branch" ]; then
  git_base=$(git -C "$cwd" rev-parse --show-toplevel 2>/dev/null | xargs basename 2>/dev/null)
  git_state=""

  num_ahead=$(git -C "$cwd" log --no-optional-locks --oneline "@{u}.." 2>/dev/null | wc -l | tr -d ' ')
  [ "$num_ahead" -gt 0 ] && git_state="${git_state}\033[31m${num_ahead}A\033[0m"

  num_behind=$(git -C "$cwd" log --no-optional-locks --oneline "..@{u}" 2>/dev/null | wc -l | tr -d ' ')
  [ "$num_behind" -gt 0 ] && git_state="${git_state}\033[36m${num_behind}B\033[0m"

  git_dir=$(git -C "$cwd" rev-parse --git-dir 2>/dev/null)
  if [ -n "$git_dir" ] && [ -r "$git_dir/MERGE_HEAD" ]; then
    git_state="${git_state}\033[1;35m⚡︎\033[0m"
  fi

  if git -C "$cwd" ls-files --no-optional-locks --other --exclude-standard 2>/dev/null | grep -q .; then
    git_state="${git_state}\033[1;31m●\033[0m"
  fi

  if ! git -C "$cwd" diff --no-optional-locks --quiet 2>/dev/null; then
    git_state="${git_state}\033[1;33m●\033[0m"
  fi

  if ! git -C "$cwd" diff --no-optional-locks --cached --quiet 2>/dev/null; then
    git_state="${git_state}\033[1;32m●\033[0m"
  fi

  git_info="\033[34m${git_base}\033[37m:\033[33m${git_branch}\033[0m"
  [ -n "$git_state" ] && git_info="$git_info $git_state"
  git_part=" | $git_info"
fi

# Model info
model=$(echo "$input" | jq -r '.model.display_name // empty')
model_part=""
[ -n "$model" ] && model_part=" | \033[37m${model}\033[0m"

# Context usage
used_pct=$(echo "$input" | jq -r '.context_window.used_percentage // empty')
ctx_part=""
if [ -n "$used_pct" ]; then
  used_int=$(printf "%.0f" "$used_pct")
  ctx_part=" | ctx:${used_int}%"
fi

printf "\033[34m${short_cwd}\033[0m${git_part}${model_part}${ctx_part}\n"
