#!/usr/bin/env bash
set -euo pipefail

root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
qs="$root/chezmoi/dot_config/quickshell"

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

require_file "$qs/services/Log.qml"
require_file "$qs/services/Proc.qml"
require_file "$qs/services/ProgramChecker.qml"

require_text "$qs/services/Log.qml" 'function scoped(scope)'
require_text "$qs/services/Proc.qml" 'function run(id, command, callback, debounceMs, timeoutMs)'
require_text "$qs/services/ProgramChecker.qml" 'property bool fanStateAvailable'
require_text "$qs/services/ProgramChecker.qml" 'fanStateAvailable: "fan_state"'
require_text "$qs/services/SystemStats.qml" 'ProgramChecker.fanStateAvailable'
require_text "$qs/bar/CpuIndicator.qml" 'SystemStats.fanControlAvailable'

if grep -Fq 'command -v fan_state' "$qs/bar/CpuIndicator.qml"; then
  printf 'CpuIndicator.qml still performs its own fan_state dependency check\n' >&2
  exit 1
fi

printf 'quickshell infrastructure checks passed\n'
