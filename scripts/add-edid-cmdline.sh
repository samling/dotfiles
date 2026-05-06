#!/usr/bin/env bash
# Append drm.edid_firmware=eDP-1:edid/edid_mclk_fix.bin to /etc/kernel/cmdline
# and rebuild initrds. Idempotent: re-running is a no-op once applied.
set -euo pipefail

CMDLINE=/etc/kernel/cmdline
PARAM='drm.edid_firmware=eDP-1:edid/edid_mclk_fix.bin'

if [[ $EUID -ne 0 ]]; then
  exec sudo -- "$0" "$@"
fi

if [[ ! -f $CMDLINE ]]; then
  echo "error: $CMDLINE does not exist" >&2
  exit 1
fi

if grep -qF "$PARAM" "$CMDLINE"; then
  echo "already present in $CMDLINE; nothing to do"
  exit 0
fi

cp -a "$CMDLINE" "$CMDLINE.bak.$(date +%Y%m%d%H%M%S)"

# Append on the same line; /etc/kernel/cmdline is a single line of params.
current=$(tr -d '\n' < "$CMDLINE")
printf '%s %s\n' "$current" "$PARAM" > "$CMDLINE"

echo "updated $CMDLINE:"
cat "$CMDLINE"

echo "running reinstall-kernels..."
reinstall-kernels
