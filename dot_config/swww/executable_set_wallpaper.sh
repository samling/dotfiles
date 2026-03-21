#!/bin/sh
# Sets the wallpaper for a given display (or all displays) and generates a
# matugen color scheme from the image.
#
# Usage:
#   set_wallpaper.sh IMAGE [SOURCE_COLOR_INDEX] [OUTPUT]
#
# IMAGE              — path to the image file
# SOURCE_COLOR_INDEX — matugen source color index (0-3, default 0)
# OUTPUT             — optional swww output name (see swww-query(1)); omit to set all

IMAGE="$1"
SOURCE_COLOR_INDEX="${2:-0}"
OUTPUT="$3"

if [ -z "$IMAGE" ] || [ ! -f "$IMAGE" ]; then
	printf "Usage:\n\t\e[1m%s\e[0m \e[4mIMAGE\e[0m [\e[4mOUTPUT\e[0m]\n" "$0"
	exit 1
fi

# See swww-img(1)
RESIZE_TYPE="crop"
export SWWW_TRANSITION_FPS="${SWWW_TRANSITION_FPS:-60}"
export SWWW_TRANSITION_STEP="${SWWW_TRANSITION_STEP:-2}"

if [ -n "$OUTPUT" ]; then
	swww img --resize "$RESIZE_TYPE" --outputs "$OUTPUT" "$IMAGE"
else
	swww img --resize "$RESIZE_TYPE" "$IMAGE"
fi

matugen image --source-color-index "$SOURCE_COLOR_INDEX" --contrast 1.0 -t scheme-fidelity "$IMAGE"
echo "Wallpaper set to: $IMAGE"
