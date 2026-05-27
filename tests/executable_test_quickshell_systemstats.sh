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

reject_text() {
  local file="$1"
  local text="$2"
  if grep -Fq "$text" "$file"; then
    printf 'unexpected text in %s: %s\n' "$file" "$text" >&2
    exit 1
  fi
}

require_file "$qs/services/SystemStats.qml"
require_text "$qs/services/SystemStats.qml" 'property real cpuUsage'
require_text "$qs/services/SystemStats.qml" 'property real memUsage'
require_text "$qs/services/SystemStats.qml" 'property real diskUsage'
require_text "$qs/services/SystemStats.qml" 'property real gpuUsage'
require_text "$qs/services/SystemStats.qml" 'function refreshCpu()'
require_text "$qs/services/SystemStats.qml" 'function refreshGpu()'

for file in CpuIndicator.qml MemoryIndicator.qml DiskIndicator.qml GpuIndicator.qml; do
  require_text "$qs/bar/$file" 'SystemStats.'
  reject_text "$qs/bar/$file" 'Process {'
  reject_text "$qs/bar/$file" 'Timer {'
done

printf 'quickshell SystemStats checks passed\n'
