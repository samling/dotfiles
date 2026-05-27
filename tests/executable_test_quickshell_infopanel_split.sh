#!/usr/bin/env bash
set -euo pipefail

root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
qs="$root/chezmoi/dot_config/quickshell"
panel="$qs/bar/InfoPanel.qml"

require_file() {
  local file="$1"
  test -f "$file" || {
    printf 'missing required file: %s\n' "$file" >&2
    exit 1
  }
}

require_text() {
  local file="$1"
  local text="$2"
  grep -Fq "$text" "$file" || {
    printf 'missing expected text in %s: %s\n' "$file" "$text" >&2
    exit 1
  }
}

require_file "$qs/bar/InfoPanelHeader.qml"
require_file "$qs/bar/InfoPanelSubPanel.qml"
require_text "$panel" 'InfoPanelHeader {'
require_text "$panel" 'InfoPanelSubPanel {'

line_count="$(wc -l < "$panel")"
if (( line_count >= 1900 )); then
  printf 'InfoPanel.qml still too large after split: %s lines\n' "$line_count" >&2
  exit 1
fi

printf 'quickshell InfoPanel split checks passed\n'
