!/bin/bash

# https://www.reddit.com/r/hyprland/comments/136gptg/hyprland_with_waybar_config_reloading/

# Kill and restart waybar whenever its config files change
CONFIG_FILE="$HOME/.config/waybar/config.jsonc"

while true; do
  inotifywait -e modify $CONFIG_FILE
  pkill waybar
  waybar &
done
