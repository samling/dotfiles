#!/bin/sh
# Sets the wallpaper for a given display (or all displays) and generates a
# color scheme from the image via pywal16.
#
# Usage:
#   set_wallpaper.sh IMAGE [OUTPUT]
#
# IMAGE  — path to the image file
# OUTPUT — optional swww output name (see swww-query(1)); omit to set all
#
# Requires: swww, wal (pywal16)

IMAGE="$1"
OUTPUT="$2"

if [ -z "$IMAGE" ] || [ ! -f "$IMAGE" ]; then
	printf "Usage:\n\t\e[1m%s\e[0m \e[4mIMAGE\e[0m [\e[4mOUTPUT\e[0m]\n" "$0"
	exit 1
fi

# Set wallpaper via swww
RESIZE_TYPE="crop"
export SWWW_TRANSITION_FPS="${SWWW_TRANSITION_FPS:-60}"
export SWWW_TRANSITION_STEP="${SWWW_TRANSITION_STEP:-2}"

if [ -n "$OUTPUT" ]; then
	swww img --resize "$RESIZE_TYPE" --outputs "$OUTPUT" "$IMAGE"
else
	swww img --resize "$RESIZE_TYPE" "$IMAGE"
fi

# Extract colors and render templates (skip terminal, tty, wallpaper, reload)
wal -i "$IMAGE" -s -t -n -e -q 2>/dev/null

# Copy rendered Colors.qml to Quickshell and trigger reload
cp ~/.cache/wal/colors-quickshell ~/.config/quickshell/common/Colors.qml
mkdir -p ~/.cache/matugen
touch ~/.cache/matugen/quickshell-reload-trigger

echo "Wallpaper set to: $IMAGE"
