#!/bin/bash

# https://www.reddit.com/r/hyprland/comments/136gptg/hyprland_with_waybar_config_reloading/

# Kill and restart waybar whenever its config files change
CONFIG_FILE="$HOME/.config/waybar/config.jsonc"
STYLE_FILE="$HOME/.config/waybar/style.css"
LOCK_FILE="/tmp/waybar_watchdog.lock"

# Clean up lockfile when this script exits
cleanup() {
  rm -f "$LOCK_FILE"
}
trap cleanup EXIT

# Check if there's an existing lockfile to prevent multiple executions
if [ -e "$LOCK_FILE" ] && kill -0 "$(cat $LOCK_FILE)" 2>/dev/null; then
  echo "Another instance of the waybar watchdog script is already running."
  exit 1
fi

# Save this script's PID to the lockfile
echo $$ > "$LOCK_FILE"

restart_waybar() {
  pkill waybar
  sleep 0.5
  waybar >/dev/null 2>&1 &
}

while true; do
  inotifywait -e modify "${CONFIG_FILE}" "${STYLE_FILE}"
  restart_waybar
done
