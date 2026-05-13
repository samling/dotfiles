#!/usr/bin/env bash
# Preview a path. Port of PatrickF1/fzf.fish's _fzf_preview_file.
# Respects $fzf_preview_file_cmd and $fzf_preview_dir_cmd overrides.

set -u
file_path="$*"

if [[ -L "$file_path" ]]; then
  target_path=$(realpath -- "$file_path" 2>/dev/null)
  printf '\033[33m%s\033[0m\n' "'$file_path' is a symlink to '$target_path'."
  exec "$0" "$target_path"
elif [[ -f "$file_path" ]]; then
  if [[ -n "${fzf_preview_file_cmd:-}" ]]; then
    eval "$fzf_preview_file_cmd \"\$file_path\""
  else
    bat --style=numbers --color=always -- "$file_path"
  fi
elif [[ -d "$file_path" ]]; then
  if [[ -n "${fzf_preview_dir_cmd:-}" ]]; then
    eval "$fzf_preview_dir_cmd \"\$file_path\""
  else
    command ls -A -F -- "$file_path"
  fi
elif [[ -c "$file_path" ]]; then
  printf '\033[31mCannot preview %s: character device file.\033[0m\n' "$file_path"
elif [[ -b "$file_path" ]]; then
  printf '\033[31mCannot preview %s: block device file.\033[0m\n' "$file_path"
elif [[ -S "$file_path" ]]; then
  printf '\033[31mCannot preview %s: socket.\033[0m\n' "$file_path"
elif [[ -p "$file_path" ]]; then
  printf '\033[31mCannot preview %s: named pipe.\033[0m\n' "$file_path"
else
  printf "%s doesn't exist.\n" "$file_path" >&2
fi
