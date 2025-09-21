#!/bin/sh
# For each display, changes the wallpaper to a different randomly chosen image in
# a given directory.

if [ $# -lt 1 ] || [ ! -d "$1" ]; then
	printf "Usage:\n\t\e[1m%s\e[0m \e[4mDIRECTORY\e[0m\n" "$0"
	printf "\tChanges the wallpaper to different randomly chosen images in DIRECTORY for each display.\n"
	exit 1
fi

# See swww-img(1)
RESIZE_TYPE="crop"
export SWWW_TRANSITION_FPS="${SWWW_TRANSITION_FPS:-60}"
export SWWW_TRANSITION_STEP="${SWWW_TRANSITION_STEP:-2}"

# Check if we have image files in the directory
image_count=$(find "$1" -type f | wc -l)
if [ "$image_count" -eq 0 ]; then
    echo "No image files found in directory: $1"
    exit 1
fi

# Set a different random image as wallpaper for each display
for d in $(swww query | cut -d: -f2 | tr -d ' '); do # see swww-query(1)
    # Select a random image for this display
    random_image=$(find "$1" -type f | shuf -n 1)
    swww img --resize "$RESIZE_TYPE" --outputs "$d" "$random_image"
    echo "Display $d: Wallpaper set to: $random_image"
done
