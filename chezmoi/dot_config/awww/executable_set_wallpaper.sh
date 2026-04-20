#!/bin/sh
# Sets the wallpaper for a given display (or all displays) and generates a
# color scheme from the image via matugen.
#
# Usage:
#   set_wallpaper.sh IMAGE [OUTPUT]
#
# IMAGE  — path to the image file
# OUTPUT — optional awww output name (see awww-query(1)); omit to set all
#
# Requires: awww, matugen

IMAGE="$1"
OUTPUT="$2"

if [ -z "$IMAGE" ] || [ ! -f "$IMAGE" ]; then
	printf "Usage:\n\t\e[1m%s\e[0m \e[4mIMAGE\e[0m [\e[4mOUTPUT\e[0m]\n" "$0"
	exit 1
fi

# Set wallpaper via awww
RESIZE_TYPE="crop"
export AWWW_TRANSITION_FPS="${AWWW_TRANSITION_FPS:-60}"
export AWWW_TRANSITION_STEP="${AWWW_TRANSITION_STEP:-2}"

if [ -n "$OUTPUT" ]; then
	awww img --resize "$RESIZE_TYPE" --outputs "$OUTPUT" "$IMAGE"
else
	awww img --resize "$RESIZE_TYPE" "$IMAGE"
fi

# Generate MD3 color scheme from wallpaper via matugen
# (writes Colors.qml directly per ~/.config/matugen/config.toml)
matugen image --prefer saturation -t scheme-content "$IMAGE"

echo "Wallpaper set to: $IMAGE"
