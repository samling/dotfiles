#!/usr/bin/env bash
# Usage: gesture.sh <gesture_name>
# Example: gesture.sh pinchin

set -euo pipefail

gesture="$1"
class=$(hyprctl activewindow -j | jq -r '.class')

show_indicator() {
  quickshell msg swipe show "$1" &
}

case "$class" in
  google-chrome*|chromium*)
    case "$gesture" in
      pinchin)  wtype -M ctrl -k t -m ctrl ;;  # close tab
      pinchout) wtype -M ctrl -k w -m ctrl ;;  # new tab
      left) show_indicator right; wtype -M alt -k Right -m alt ;; # forward
      right) show_indicator left; wtype -M alt -k Left -m alt ;; # back
    esac
    ;;
  firefox*)
    case "$gesture" in
      pinchin)  wtype -M ctrl -k t -m ctrl ;;
      pinchout) wtype -M ctrl -k w -m ctrl ;;
      left) show_indicator right; wtype -M alt -k Right -m alt ;; # forward
      right) show_indicator left; wtype -M alt -k Left -m alt ;; # back
    esac
    ;;
  *)
    # default / no-op
    ;;
esac
