#!/usr/bin/env bash
# Preview a line of `git status --short` as a labeled diff.
# Port of PatrickF1/fzf.fish's _fzf_preview_changed_file. Respects $fzf_diff_highlighter.

set -u
line="$*"
index_status="${line:0:1}"
working_tree_status="${line:1:1}"
path="${line:3}"

# git status --short double-quotes paths with funky chars; strip surrounding quotes.
if [[ ${path:0:1} == '"' && ${path: -1} == '"' ]]; then
  path="${path:1:${#path}-2}"
fi

report_diff_type() {
  local label="$1"
  local pad
  pad=$(printf '%*s' $((${#label} + 2)) '' | tr ' ' '─')
  printf '\033[33m'
  printf '╭%s╮\n' "$pad"
  printf '│ %s │\n' "$label"
  printf '╰%s╯\n' "$pad"
  printf '\033[0m'
}

run_diff() {
  if [[ -n "${fzf_diff_highlighter:-}" ]]; then
    git diff "$@" | eval "$fzf_diff_highlighter"
  else
    git diff "$@"
  fi
}

# Untracked.
if [[ "$index_status" == '?' ]]; then
  report_diff_type Untracked
  exec "$(dirname -- "$0")/fzf_preview_file.sh" "$path"
fi

# Unmerged (statuses are mutually exclusive with other states).
case "${index_status}${working_tree_status}" in
  DD | AU | UD | UA | DU | AA | UU)
    report_diff_type Unmerged
    run_diff --color=always -- "$path"
    exit 0
    ;;
esac

if [[ "$index_status" != ' ' ]]; then
  report_diff_type Staged
  if [[ "$index_status" == 'R' ]]; then
    # "old -> new"; diff orig vs renamed so the patch isn't shown as a full add.
    orig_path="${path%% -> *}"
    new_path="${path##* -> }"
    run_diff --staged --color=always -- "$orig_path" "$new_path"
    path="$new_path"
  else
    run_diff --staged --color=always -- "$path"
  fi
fi
if [[ "$working_tree_status" != ' ' ]]; then
  report_diff_type Unstaged
  run_diff --color=always -- "$path"
fi
