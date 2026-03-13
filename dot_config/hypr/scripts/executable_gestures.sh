#!/usr/bin/env bash
# Usage: gesture.sh <gesture_name>
# Example: gesture.sh pinchin

set -euo pipefail

gesture="$1"
class=$(hyprctl activewindow -j | jq -r '.class')

case "$class" in
  google-chrome*|chromium*)
    case "$gesture" in
      pinchin)  wtype -M ctrl -k t -m ctrl ;;  # close tab
      pinchout) wtype -M ctrl -k w -m ctrl ;;  # new tab
    esac
    ;;
  firefox*)
    case "$gesture" in
      pinchin)  wtype -M ctrl -k t -m ctrl ;;
      pinchout) wtype -M ctrl -k w -m ctrl ;;
    esac
    ;;
  *)
    # default / no-op
    ;;
esac
```

Then in your Hyprland config:
```
gesture = 3, pinchin, dispatcher, exec, ~/.config/hypr/scripts/gesture.sh pinch_in
gesture = 3, pinchout, dispatcher, exec, ~/.config/hypr/scripts/gesture.sh pinch_out
