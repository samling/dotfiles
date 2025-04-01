#!/bin/sh

active_window_info=$(hyprctl activewindow -j)

# Check if hyprctl command was successful and returned valid JSON
if [ $? -ne 0 ] || ! echo "$active_window_info" | jq -e . > /dev/null 2>&1; then
  echo "{}" # Output empty JSON if no active window or error
  exit 0
fi

# Extract the class, using title as a fallback if class is empty/null
window_class=$(echo "$active_window_info" | jq -r '.class // empty')
if [ -z "$window_class" ]; then
  window_title=$(echo "$active_window_info" | jq -r '.title // empty')
  # Use title only if it's not empty
  if [ -n "$window_title" ]; then
     # Basic placeholder or use title directly if preferred
     # We need *something* to display, but maybe not the full title
     # Let's use a generic icon or placeholder if class is missing
     # For now, let's just output the title if class is missing.
     # A better approach might involve more complex mapping.
     echo "$active_window_info" | jq --arg class "$window_title" '{text: $class, class: "active"}'
  else
    echo "{}" # Output empty JSON if both class and title are empty
  fi
else
  # Output JSON with class and the "active" CSS class
  echo "$active_window_info" | jq --arg class "$window_class" '{text: $class, class: "active"}'
fi 